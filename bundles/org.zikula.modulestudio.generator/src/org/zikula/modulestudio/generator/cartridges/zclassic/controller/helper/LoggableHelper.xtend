package org.zikula.modulestudio.generator.cartridges.zclassic.controller.helper

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Entity
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class LoggableHelper {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension Utils = new Utils

    /**
     * Entry point for the helper class creation.
     */
    def generate(Application it, IMostFileSystemAccess fsa) {
        if (!hasLoggable) {
            return
        }
        'Generating helper class for loggable behaviour'.printIfNotTesting(fsa)
        fsa.generateClassPair('Helper/LoggableHelper.php', loggableFunctionsBaseImpl, loggableFunctionsImpl)
    }

    def private loggableFunctionsBaseImpl(Application it) '''
        namespace «appNamespace»\Helper\Base;

        «IF !targets('3.0')»
            use Doctrine\Common\Persistence\Event\LifecycleEventArgs;
        «ENDIF»
        «IF hasTrees && !getTreeEntities.filter[loggable].empty»
            use Doctrine\Common\Proxy\Proxy;
        «ENDIF»
        use Doctrine\ORM\Id\AssignedGenerator;
        use Doctrine\ORM\Mapping\ClassMetadata;
        «IF targets('3.0')»
            use Doctrine\Persistence\Event\LifecycleEventArgs;
        «ENDIF»
        use Exception;
        use Gedmo\Loggable\Entity\MappedSuperclass\AbstractLogEntry;
        use Gedmo\Loggable\LoggableListener;
        «IF targets('3.0')»
            use Symfony\Contracts\Translation\TranslatorInterface;
        «ELSE»
            use Zikula\Common\Translator\TranslatorInterface;
        «ENDIF»
        use Zikula\Common\Translator\TranslatorTrait;
        use Zikula\Core\Doctrine\EntityAccess;
        use «appNamespace»\Entity\Factory\EntityFactory;
        use «appNamespace»\Helper\EntityDisplayHelper;
        «IF hasLoggableTranslatable»
            use «appNamespace»\Helper\TranslatableHelper;
        «ENDIF»
        use «appNamespace»\Listener\EntityLifecycleListener;

        /**
         * Helper base class for loggable behaviour.
         */
        abstract class AbstractLoggableHelper
        {
            «helperBaseImpl»
        }
    '''

    def private helperBaseImpl(Application it) '''
        use TranslatorTrait;

        /**
         * @var EntityFactory
         */
        protected $entityFactory;

        /**
         * @var EntityDisplayHelper
         */
        protected $entityDisplayHelper;

        /**
         * @var EntityLifecycleListener
         */
        protected $entityLifecycleListener;
        «IF hasLoggableTranslatable»

            /**
             * @var TranslatableHelper
             */
            protected $translatableHelper;
        «ENDIF»

        public function __construct(
            TranslatorInterface $translator,
            EntityFactory $entityFactory,
            EntityDisplayHelper $entityDisplayHelper,
            EntityLifecycleListener $entityLifecycleListener«IF hasLoggableTranslatable»,
            TranslatableHelper $translatableHelper«ENDIF»
        ) {
            $this->setTranslator($translator);
            $this->entityFactory = $entityFactory;
            $this->entityDisplayHelper = $entityDisplayHelper;
            $this->entityLifecycleListener = $entityLifecycleListener;
            «IF hasLoggableTranslatable»
                $this->translatableHelper = $translatableHelper;
            «ENDIF»
        }
        «IF !targets('3.0')»

            «setTranslatorMethod»
        «ENDIF»

        «determineDiffViewParameters»

        «getVersionFieldName»

        «hasHistoryItems»

        «hasDeletedEntities»

        «getDeletedEntities»

        «revert»

        «restoreDeletedEntity»

        «revertPostProcess»

        «undeleteEntity»

        «translateActionDescription»
    '''

    def private determineDiffViewParameters(Application it) '''
        /**
         * Determines template parameters for diff view.
         «IF !targets('3.0')»
         *
         * @param array $logEntries List of log entries for currently treated entity instance
         * @param array $versions List of desired version numbers
         *
         * @return array
         «ENDIF»
         */
        public function determineDiffViewParameters(«IF targets('3.0')»array «ENDIF»$logEntries, «IF targets('3.0')»array «ENDIF»$versions)«IF targets('3.0')»: array«ENDIF»
        {
            $minVersion = $maxVersion = 0;
            if ($versions[0] < $versions[1]) {
                $minVersion = $versions[0];
                $maxVersion = $versions[1];
            } else {
                $minVersion = $versions[1];
                $maxVersion = $versions[0];
            }
            $logEntries = array_reverse($logEntries);

            $diffValues = [];
            foreach ($logEntries as $logEntry) {
                if (null === $logEntry->getData()) {
                    continue;
                }
                foreach ($logEntry->getData() as $field => $value) {
                    if (!isset($diffValues[$field])) {
                        $diffValues[$field] = [
                            'old' => '',
                            'new' => '',
                            'changed' => false
                        ];
                    }
                    if ($logEntry->getVersion() <= $minVersion) {
                        $diffValues[$field]['old'] = $value;
                        $diffValues[$field]['new'] = $value;
                    } elseif ($logEntry->getVersion() <= $maxVersion) {
                        $diffValues[$field]['new'] = $value;
                        $diffValues[$field]['changed'] = $diffValues[$field]['new'] !== $diffValues[$field]['old'];
                    }
                }
            }

            return [$minVersion, $maxVersion, $diffValues];
        }
    '''

    def private getVersionFieldName(Application it) '''
        /**
         * Return name of the version field for the given object type.
         «IF !targets('3.0')»
         *
         * @param string $objectType Currently treated entity type
         *
         * @return string|null
         «ENDIF»
         */
        public function getVersionFieldName(«IF targets('3.0')»string «ENDIF»$objectType = '')«IF targets('3.0')»: ?string«ENDIF»
        {
            $versionFieldMap = [
                «FOR entity : getLoggableEntities»
                    '«entity.name.formatForCode»' => '«entity.getVersionField.name.formatForCode»',
                «ENDFOR»
            ];

            «IF targets('3.0')»
                return $versionFieldMap[$objectType] ?? null;
            «ELSE»
                return isset($versionFieldMap[$objectType]) ? $versionFieldMap[$objectType] : null;
            «ENDIF»
        }
    '''

    def private hasHistoryItems(Application it) '''
        /**
         * Checks whether a history may be shown for the given entity instance.
         «IF !targets('3.0')»
         *
         * @param EntityAccess $entity Currently treated entity instance
         *
         * @return bool
         «ENDIF»
         */
        public function hasHistoryItems(EntityAccess $entity)«IF targets('3.0')»: bool«ENDIF»
        {
            $objectType = $entity->get_objectType();
            $versionFieldName = $this->getVersionFieldName($objectType);

            if (null !== $versionFieldName) {
                $versionGetter = 'get' . ucfirst($versionFieldName);

                return 1 < $entity->$versionGetter();
            }

            // alternative (with worse performance)
            $entityManager = $this->entityFactory->getEntityManager();
            $logEntriesRepository = $entityManager->getRepository(
                '«appName»:' . ucfirst($objectType) . 'LogEntryEntity'
            );
            $logEntries = $logEntriesRepository->getLogEntries($entity);

            return 1 < count($logEntries);
        }
    '''

    def private hasDeletedEntities(Application it) '''
        /**
         * Checks whether deleted entities exist for the given object type.
         «IF !targets('3.0')»
         *
         * @param string $objectType Currently treated entity type
         *
         * @return bool
         «ENDIF»
         */
        public function hasDeletedEntities(«IF targets('3.0')»string «ENDIF»$objectType = '')«IF targets('3.0')»: bool«ENDIF»
        {
            $entityManager = $this->entityFactory->getEntityManager();
            $logEntriesRepository = $entityManager->getRepository(
                '«appName»:' . ucfirst($objectType) . 'LogEntryEntity'
            );

            return 0 < count($logEntriesRepository->selectDeleted(1));
        }
    '''

    def private getDeletedEntities(Application it) '''
        /**
         * Returns deleted entities for the given object type.
         «IF !targets('3.0')»
         *
         * @param string $objectType Currently treated entity type
         *
         * @return array
         «ENDIF»
         */
        public function getDeletedEntities(«IF targets('3.0')»string «ENDIF»$objectType = '')«IF targets('3.0')»: array«ENDIF»
        {
            $entityManager = $this->entityFactory->getEntityManager();
            $logEntriesRepository = $entityManager->getRepository(
                '«appName»:' . ucfirst($objectType) . 'LogEntryEntity'
            );

            return $logEntriesRepository->selectDeleted();
        }
    '''

    def private revert(Application it) '''
        /**
         * Sets the given entity to back to a specific version.
         «IF !targets('3.0')»
         *
         * @param EntityAccess $entity Currently treated entity instance
         * @param int $requestedVersion Target version
         * @param bool $detach Whether to detach the entity or not
         *
         * @return EntityAccess The reverted entity instance
         «ENDIF»
         */
        public function revert(EntityAccess $entity, «IF targets('3.0')»int «ENDIF»$requestedVersion = 1, «IF targets('3.0')»bool «ENDIF»$detach = false)«IF targets('3.0')»: EntityAccess«ENDIF»
        {
            $entityManager = $this->entityFactory->getEntityManager();
            $objectType = $entity->get_objectType();

            $logEntriesRepository = $entityManager->getRepository(
                '«appName»:' . ucfirst($objectType) . 'LogEntryEntity'
            );
            $logEntries = $logEntriesRepository->getLogEntries($entity);
            if (2 > count($logEntries)) {
                return $entity;
            }

            // revert to requested version
            $logEntriesRepository->revert($entity, $requestedVersion);
            if (true === $detach) {
                // detach the entity to avoid persisting it
                $entityManager->detach($entity);
            }

            return $this->revertPostProcess($entity);
        }
    '''

    def private restoreDeletedEntity(Application it) '''
        /**
         * Resets a deleted entity back to the last version before it's deletion.
         «IF !targets('3.0')»
         *
         * @param string $objectType Currently treated entity type
         * @param int $id The entity's identifier
         *
         * @return EntityAccess|null The restored entity instance
         «ENDIF»
         */
        public function restoreDeletedEntity(«IF targets('3.0')»string «ENDIF»$objectType = '', «IF targets('3.0')»int «ENDIF»$id = 0)«IF targets('3.0')»: ?EntityAccess«ENDIF»
        {
            if (!$id) {
                return null;
            }

            $methodName = 'create' . ucfirst($objectType);
            $entity = $this->entityFactory->$methodName();
            $idField = $this->entityFactory->getIdField($objectType);
            $setter = 'set' . ucfirst($idField);
            $entity->$setter($id);

            $entityManager = $this->entityFactory->getEntityManager();
            $logEntriesRepository = $entityManager->getRepository(
                '«appName»:' . ucfirst($objectType) . 'LogEntryEntity'
            );
            $logEntries = $logEntriesRepository->getLogEntries($entity);
            $lastVersionBeforeDeletion = null;
            foreach ($logEntries as $logEntry) {
                if (LoggableListener::ACTION_REMOVE !== $logEntry->getAction()) {
                    $lastVersionBeforeDeletion = $logEntry->getVersion();
                    break;
                }
            }
            if (null === $lastVersionBeforeDeletion) {
                return null;
            }

            $objectType = $entity->get_objectType();
            $versionFieldName = $this->getVersionFieldName($objectType);

            $logEntriesRepository->revert($entity, $lastVersionBeforeDeletion);
            if (null !== $versionFieldName) {
                $versionSetter = 'set' . ucfirst($versionFieldName);
                $entity->$versionSetter($lastVersionBeforeDeletion + 2);
            }

            $entity->set_actionDescriptionForLogEntry(
                '_HISTORY_' . strtoupper($objectType) . '_RESTORED'
                . '|%version%=' . $lastVersionBeforeDeletion
            );

            return $this->revertPostProcess($entity);
        }
    '''

    def private revertPostProcess(Application it) '''
        /**
         * Performs actions after reverting an entity to a previous revision.
         «IF !targets('3.0')»
         *
         * @param EntityAccess $entity Currently treated entity instance
         *
         * @return EntityAccess The processed entity instance
         «ENDIF»
         */
        protected function revertPostProcess(EntityAccess $entity)«IF targets('3.0')»: EntityAccess«ENDIF»
        {
            $objectType = $entity->get_objectType();

            «IF hasTrees && !getTreeEntities.filter[loggable].empty»
                if (in_array($objectType, ['«getTreeEntities.filter[loggable].map[name.formatForCode].join('\', \'')»'], true)) {
                    // check if parent is still valid
                    $repository = $this->entityFactory->getRepository($objectType);
                    $parentId = $entity->getParent()->getId();
                    $parent = $parentId ? $repository->find($parentId) : null;
                    if (in_array(Proxy::class, class_implements($parent), true)) {
                        // look for a root node to use as parent
                        $parentNode = $repository->findOneBy(['lvl' => 0]);
                        $entity->setParent($parentNode);
                    }
                }

            «ENDIF»
            «IF hasLoggableTranslatable»
                if (in_array($objectType, ['«getLoggableTranslatableEntities.map[name.formatForCode].join('\', \'')»'], true)) {
                    $entity = $this->translatableHelper->setEntityFieldsFromLogData($entity);
                }
            «ENDIF»

            $eventArgs = new LifecycleEventArgs($entity, $this->entityFactory->getEntityManager());
            $this->entityLifecycleListener->postLoad($eventArgs);

            return $entity;
        }
    '''

    def private undeleteEntity(Application it) '''
        /**
         * Persists a formerly entity again.
         «IF !targets('3.0')»
         *
         * @param EntityAccess $entity Currently treated entity instance
         «ENDIF»
         *
         * @throws Exception If something goes wrong
         */
        public function undelete(EntityAccess $entity)«IF targets('3.0')»: void«ENDIF»
        {
            $entityManager = $this->entityFactory->getEntityManager();

            $metadata = $entityManager->getClassMetaData(get_class($entity));
            $metadata->setIdGeneratorType(ClassMetadata::GENERATOR_TYPE_NONE);
            $metadata->setIdGenerator(new AssignedGenerator());

            $versionField = $metadata->versionField;
            $metadata->setVersioned(false);
            $metadata->setVersionField(null);

            $entityManager->persist($entity);
            $entityManager->flush();

            $metadata->setVersioned(true);
            $metadata->setVersionField($versionField);
        }
    '''

    def private translateActionDescription(Application it) '''
        /**
         * Returns the translated clear text action description for a given log entry.
         «IF !targets('3.0')»
         *
         * @param AbstractLogEntry $logEntry
         *
         * @return string
         «ENDIF»
         */
        public function translateActionDescription(AbstractLogEntry $logEntry)«IF targets('3.0')»: string«ENDIF»
        {
            $textAndParam = explode('|', $logEntry->getActionDescription());
            $text = $textAndParam[0];
            $parametersStr = 1 < count($textAndParam) ? $textAndParam[1] : '';

            $parameters = [];
            $parametersStr = explode(',', $parametersStr);
            foreach ($parametersStr as $parameterStr) {
                $varAndValue = explode('=', $parameterStr);
                if (2 === count($varAndValue)) {
                    $parameters[$varAndValue[0]] = $varAndValue[1];
                }
            }

            return $this->translateActionDescriptionInternal($text, $parameters);
        }

        /**
         * Returns the translated clear text action description for a given log entry.
         «IF !targets('3.0')»
         *
         * @param string $text The constant which is replaced by a corresponding Gettext call
         * @param array $parameters Optional additional parameters for the Gettext call
         *
         * @return string The resulting description
         «ENDIF»
         */
        protected function translateActionDescriptionInternal(«IF targets('3.0')»string «ENDIF»$text = '', array $parameters = [])«IF targets('3.0')»: string«ENDIF»
        {
            «IF !isSystemModule»
                $this->translator->setDomain('«appName.formatForDB»');
            «ENDIF»
            $actionTranslated = '';
            switch ($text) {
                «FOR entity : getLoggableEntities»
                    «entity.actionDescriptions('_HISTORY_' + entity.name.formatForCode.toUpperCase + '_', entity.name.formatForDisplayCapital)»
                «ENDFOR»
                default:
                    $actionTranslated = $text;
            }

            return $actionTranslated;
        }
    '''

    def private actionDescriptions(Entity it, String constantPrefix, String displayName) '''
        case '«constantPrefix»CREATED':
            $actionTranslated = $this->«IF application.targets('3.0')»trans«ELSE»__«ENDIF»('«displayName» created');
            break;
        case '«constantPrefix»UPDATED':
            $actionTranslated = $this->«IF application.targets('3.0')»trans«ELSE»__«ENDIF»('«displayName» updated');
            break;
        case '«constantPrefix»CLONED':
            if (isset($parameters['%«name.formatForCode»%']) && is_numeric($parameters['%«name.formatForCode»%'])) {
                $originalEntity = $this->entityFactory->getRepository('«name.formatForCode»')->selectById($parameters['%«name.formatForCode»%']);
                if (null !== $originalEntity) {
                    $parameters['%«name.formatForCode»%'] = $this->entityDisplayHelper->getFormattedTitle($originalEntity);
                }
            }
            $actionTranslated = $this->«IF application.targets('3.0')»trans«ELSE»__f«ENDIF»('«displayName» cloned from «name.formatForDisplay» "%«name.formatForCode»%"', $parameters);
            break;
        case '«constantPrefix»RESTORED':
            $actionTranslated = $this->«IF application.targets('3.0')»trans«ELSE»__f«ENDIF»('«displayName» restored from version "%version%"', $parameters);
            break;
        case '«constantPrefix»DELETED':
            $actionTranslated = $this->«IF application.targets('3.0')»trans«ELSE»__«ENDIF»('«displayName» deleted');
            break;
        «IF hasTranslatableFields»«/* currently not used by default but provided for convenience */»
            case '«constantPrefix»TRANSLATION_CREATED':
                $actionTranslated = $this->«IF application.targets('3.0')»trans«ELSE»__«ENDIF»('«displayName» translation created');
                break;
            case '«constantPrefix»TRANSLATION_UPDATED':
                $actionTranslated = $this->«IF application.targets('3.0')»trans«ELSE»__«ENDIF»('«displayName» translation updated');
                break;
            case '«constantPrefix»TRANSLATION_DELETED':
                $actionTranslated = $this->«IF application.targets('3.0')»trans«ELSE»__«ENDIF»('«displayName» translation deleted');
                break;
        «ENDIF»
    '''

    def private loggableFunctionsImpl(Application it) '''
        namespace «appNamespace»\Helper;

        use «appNamespace»\Helper\Base\AbstractLoggableHelper;

        /**
         * Helper implementation class for loggable behaviour.
         */
        class LoggableHelper extends AbstractLoggableHelper
        {
            // feel free to add your own convenience methods here
        }
    '''
}
