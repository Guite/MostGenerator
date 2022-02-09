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

        «IF hasTrees && !getTreeEntities.filter[loggable].empty»
            use Doctrine\Common\Proxy\Proxy;
        «ENDIF»
        use Doctrine\ORM\EntityRepository;
        use Doctrine\ORM\Id\AssignedGenerator;
        use Doctrine\ORM\Mapping\ClassMetadata;
        use Doctrine\Persistence\Event\LifecycleEventArgs;
        use Exception;
        use Gedmo\Loggable\Entity\MappedSuperclass\AbstractLogEntry;
        use Gedmo\Loggable\LoggableListener;
        use Symfony\Contracts\Translation\TranslatorInterface;
        use Zikula\Bundle\CoreBundle\Translation\TranslatorTrait;
        use «appNamespace»\Entity\EntityInterface;
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

        public function __construct(
            TranslatorInterface $translator,
            protected EntityFactory $entityFactory,
            protected EntityDisplayHelper $entityDisplayHelper,
            protected EntityLifecycleListener $entityLifecycleListener«IF hasLoggableTranslatable»,
            protected TranslatableHelper $translatableHelper«ENDIF»
        ) {
            $this->setTranslator($translator);
        }

        «determineDiffViewParameters»

        «getVersionFieldName»

        «hasHistoryItems»

        «hasDeletedEntities»

        «getDeletedEntities»

        «revert»

        «restoreDeletedEntity»

        «revertPostProcess»

        «undeleteEntity»

        «updateUserName»

        «translateActionDescription»

        «getLogEntryRepository»
    '''

    def private determineDiffViewParameters(Application it) '''
        /**
         * Determines template parameters for diff view.
         */
        public function determineDiffViewParameters(array $logEntries, array $versions): array
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
                            'changed' => false,
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
         */
        public function getVersionFieldName(string $objectType = ''): ?string
        {
            $versionFieldMap = [
                «FOR entity : getLoggableEntities»
                    '«entity.name.formatForCode»' => '«entity.getVersionField.name.formatForCode»',
                «ENDFOR»
            ];

            return $versionFieldMap[$objectType] ?? null;
        }
    '''

    def private hasHistoryItems(Application it) '''
        /**
         * Checks whether a history may be shown for the given entity instance.
         */
        public function hasHistoryItems(EntityInterface $entity): bool
        {
            $objectType = $entity->get_objectType();
            $versionFieldName = $this->getVersionFieldName($objectType);

            if (null !== $versionFieldName) {
                $versionGetter = 'get' . ucfirst($versionFieldName);

                return 1 < $entity->$versionGetter();
            }

            // alternative (with worse performance)
            $logEntriesRepository = $this->getLogEntryRepository($objectType);
            $logEntries = $logEntriesRepository->getLogEntries($entity);

            return 1 < count($logEntries);
        }
    '''

    def private hasDeletedEntities(Application it) '''
        /**
         * Checks whether deleted entities exist for the given object type.
         */
        public function hasDeletedEntities(string $objectType = ''): bool
        {
            $logEntriesRepository = $this->getLogEntryRepository($objectType);

            return 0 < count($logEntriesRepository->selectDeleted(1));
        }
    '''

    def private getDeletedEntities(Application it) '''
        /**
         * Returns deleted entities for the given object type.
         */
        public function getDeletedEntities(string $objectType = ''): array
        {
            $logEntriesRepository = $this->getLogEntryRepository($objectType);

            return $logEntriesRepository->selectDeleted();
        }
    '''

    def private revert(Application it) '''
        /**
         * Sets the given entity to back to a specific version.
         */
        public function revert(EntityInterface $entity, int $requestedVersion = 1, bool $detach = false): EntityInterface
        {
            $objectType = $entity->get_objectType();
            $logEntriesRepository = $this->getLogEntryRepository($objectType);
            $logEntries = $logEntriesRepository->getLogEntries($entity);
            if (2 > count($logEntries)) {
                return $entity;
            }

            // revert to requested version
            $logEntriesRepository->revert($entity, $requestedVersion);
            if (true === $detach) {
                // detach the entity to avoid persisting it
                $entityManager = $this->entityFactory->getEntityManager();
                $entityManager->detach($entity);
            }

            return $this->revertPostProcess($entity);
        }
    '''

    def private restoreDeletedEntity(Application it) '''
        /**
         * Resets a deleted entity back to the last version before it's deletion.
         */
        public function restoreDeletedEntity(string $objectType = '', int $id = 0): ?EntityInterface
        {
            if (!$id) {
                return null;
            }

            $methodName = 'create' . ucfirst($objectType);
            $entity = $this->entityFactory->$methodName();
            $idField = $this->entityFactory->getIdField($objectType);
            $setter = 'set' . ucfirst($idField);
            $entity->$setter($id);

            $logEntriesRepository = $this->getLogEntryRepository($objectType);
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
                '_HISTORY_' . mb_strtoupper($objectType) . '_RESTORED'
                . '|%version%=' . $lastVersionBeforeDeletion
            );

            return $this->revertPostProcess($entity);
        }
    '''

    def private revertPostProcess(Application it) '''
        /**
         * Performs actions after reverting an entity to a previous revision.
         */
        protected function revertPostProcess(EntityInterface $entity): EntityInterface
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
         *
         * @throws Exception If something goes wrong
         */
        public function undelete(EntityInterface $entity): void
        {
            $entityManager = $this->entityFactory->getEntityManager();

            $metadata = $entityManager->getClassMetaData($entity::class);
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
         */
        public function translateActionDescription(AbstractLogEntry $logEntry): string
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
         */
        protected function translateActionDescriptionInternal(string $text = '', array $parameters = []): string
        {
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

    def private updateUserName(Application it) '''
        /**
         * Updates a changed user name in all log entries for a given object type.
         */
        public function updateUserName(string $objectType, string $oldUserName, string $newUserName): void
        {
            $logEntriesRepository = $this->getLogEntryRepository($objectType);
            $logEntriesRepository->updateUserName($oldUserName, $newUserName);
        }
    '''

    def private actionDescriptions(Entity it, String constantPrefix, String displayName) '''
        case '«constantPrefix»CREATED':
            $actionTranslated = $this->trans('«displayName» created'«IF !application.isSystemModule», [], '«name.formatForCode»'«ENDIF»);
            break;
        case '«constantPrefix»UPDATED':
            $actionTranslated = $this->trans('«displayName» updated'«IF !application.isSystemModule», [], '«name.formatForCode»'«ENDIF»);
            break;
        case '«constantPrefix»CLONED':
            if (isset($parameters['%«name.formatForCode»%']) && is_numeric($parameters['%«name.formatForCode»%'])) {
                $originalEntity = $this->entityFactory->getRepository('«name.formatForCode»')->selectById($parameters['%«name.formatForCode»%']);
                if (null !== $originalEntity) {
                    $parameters['%«name.formatForCode»%'] = $this->entityDisplayHelper->getFormattedTitle($originalEntity);
                }
            }
            $actionTranslated = $this->trans('«displayName» cloned from «name.formatForDisplay» "%«name.formatForCode»%"', $parameters«IF !application.isSystemModule», [], '«name.formatForCode»'«ENDIF»);
            break;
        case '«constantPrefix»RESTORED':
            $actionTranslated = $this->trans('«displayName» restored from version "%version%"', $parameters«IF !application.isSystemModule», [], '«name.formatForCode»'«ENDIF»);
            break;
        case '«constantPrefix»DELETED':
            $actionTranslated = $this->trans('«displayName» deleted'«IF !application.isSystemModule», [], '«name.formatForCode»'«ENDIF»);
            break;
        «IF hasTranslatableFields»«/* currently not used by default but provided for convenience */»
            case '«constantPrefix»TRANSLATION_CREATED':
                $actionTranslated = $this->trans('«displayName» translation created'«IF !application.isSystemModule», [], '«name.formatForCode»'«ENDIF»);
                break;
            case '«constantPrefix»TRANSLATION_UPDATED':
                $actionTranslated = $this->trans('«displayName» translation updated'«IF !application.isSystemModule», [], '«name.formatForCode»'«ENDIF»);
                break;
            case '«constantPrefix»TRANSLATION_DELETED':
                $actionTranslated = $this->trans('«displayName» translation deleted'«IF !application.isSystemModule», [], '«name.formatForCode»'«ENDIF»);
                break;
        «ENDIF»
    '''

    def private getLogEntryRepository(Application it) '''
        private function getLogEntryRepository(string $objectType = ''): EntityRepository
        {
            $entityManager = $this->entityFactory->getEntityManager();

            return $entityManager->getRepository(
                '«appName»:' . ucfirst($objectType) . 'LogEntryEntity'
            );
        }
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
