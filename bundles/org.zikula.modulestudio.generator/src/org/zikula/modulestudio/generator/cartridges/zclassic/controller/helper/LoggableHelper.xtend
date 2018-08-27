package org.zikula.modulestudio.generator.cartridges.zclassic.controller.helper

import de.guite.modulestudio.metamodel.Application
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

        use Doctrine\Common\Persistence\Event\LifecycleEventArgs;
        use Doctrine\ORM\Id\AssignedGenerator;
        use Doctrine\ORM\Mapping\ClassMetadata;
        use Zikula\Core\Doctrine\EntityAccess;
        use «appNamespace»\Entity\Factory\EntityFactory;
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
        /**
         * @var EntityFactory
         */
        protected $entityFactory;

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

        /**
         * LoggableHelper constructor.
         *
         * @param EntityFactory $entityFactory EntityFactory service instance
         * @param EntityLifecycleListener $entityLifecycleListener Entity lifecycle subscriber
         «IF hasLoggableTranslatable»
         * @param TranslatableHelper $translatableHelper TranslatableHelper service instance
         «ENDIF»
         */
        public function __construct(
            EntityFactory $entityFactory,
            EntityLifecycleListener $entityLifecycleListener«IF hasLoggableTranslatable»,
            TranslatableHelper $translatableHelper«ENDIF»
        ) {
            $this->entityFactory = $entityFactory;
            $this->entityLifecycleListener = $entityLifecycleListener;
            «IF hasLoggableTranslatable»
                $this->translatableHelper = $translatableHelper;
            «ENDIF»
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
    '''

    def private determineDiffViewParameters(Application it) '''
        /**
         * Determines template parameters for diff view.
         *
         * @param array $logEntries List of log entries for currently treated entity instance
         *
         * @return array
         */
        public function determineDiffViewParameters($logEntries)
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
                    if (is_array($value)) {
                        $value = is_array(reset($value)) ? 'Array' : implode(', ', $value);
                    }
                    if ($logEntry->getVersion() <= $minVersion) {
                        $diffValues[$field]['old'] = $value;
                        $diffValues[$field]['new'] = $value;
                    } elseif ($logEntry->getVersion() <= $maxVersion) {
                        $diffValues[$field]['new'] = $value;
                        $diffValues[$field]['changed'] = $diffValues[$field]['new'] != $diffValues[$field]['old'];
                    }
                }
            }

            return [$minVersion, $maxVersion, $diffValues];
        }
    '''

    def private getVersionFieldName(Application it) '''
        /**
         * Return name of the version field for the given object type.
         *
         * @param string $objectType Currently treated entity type
         *
         * @return string
         */
        public function getVersionFieldName($objectType = '')
        {
            $versionFieldMap = [
                «FOR entity : getLoggableEntities»
                    '«entity.name.formatForCode»' => '«entity.getVersionField.name.formatForCode»',
                «ENDFOR»
            ];

            return isset($versionFieldMap[$objectType]) ? $versionFieldMap[$objectType] : '';
        }
    '''

    def private hasHistoryItems(Application it) '''
        /**
         * Checks whether a history may be shown for the given entity instance.
         *
         * @param EntityAccess $entity Currently treated entity instance
         *
         * @return boolean
         */
        public function hasHistoryItems($entity)
        {
            $objectType = $entity->get_objectType();
            $versionField = $this->getVersionFieldName($objectType);
            $getter = 'get' . ucfirst($versionField);

            /** alternative (with worse performance)
             * $entityManager = $this->entityFactory->getObjectManager();
             * $logEntriesRepository = $entityManager->getRepository('«appName»:' . ucfirst($objectType) . 'LogEntryEntity');
             * $logEntries = $logEntriesRepository->getLogEntries($entity);
             * return count($logEntries) > 1;
             */

            return $entity->$getter() > 1;
        }
    '''

    def private hasDeletedEntities(Application it) '''
        /**
         * Checks whether deleted entities exist for the given object type.
         *
         * @param string $objectType Currently treated entity type
         *
         * @return boolean
         */
        public function hasDeletedEntities($objectType = '')
        {
            $entityManager = $this->entityFactory->getObjectManager();
            $logEntriesRepository = $entityManager->getRepository('«appName»:' . ucfirst($objectType) . 'LogEntryEntity');

            return count($logEntriesRepository->selectDeleted(1)) > 0;
        }
    '''

    def private getDeletedEntities(Application it) '''
        /**
         * Returns deleted entities for the given object type.
         *
         * @param string $objectType Currently treated entity type
         *
         * @return array
         */
        public function getDeletedEntities($objectType = '')
        {
            $entityManager = $this->entityFactory->getObjectManager();
            $logEntriesRepository = $entityManager->getRepository('«appName»:' . ucfirst($objectType) . 'LogEntryEntity');

            return $logEntriesRepository->selectDeleted();
        }
    '''

    def private revert(Application it) '''
        /**
         * Sets the given entity to back to a specific version.
         *
         * @param EntityAccess $entity           Currently treated entity instance
         * @param integer      $requestedVersion Target version
         * @param boolean      $detach           Whether to detach the entity or not
         *
         * @return EntityAccess The reverted entity instance
         */
        public function revert($entity, $requestedVersion = 1, $detach = false)
        {
            $entityManager = $this->entityFactory->getObjectManager();
            $objectType = $entity->get_objectType();

            $logEntriesRepository = $entityManager->getRepository('«appName»:' . ucfirst($objectType) . 'LogEntryEntity');
            $logEntries = $logEntriesRepository->getLogEntries($entity);
            if (count($logEntries) < 2) {
                return $entity;
            }

            // revert to requested version
            $logEntriesRepository->revert($entity, $requestedVersion);
            if (true === $detach) {
                // detach the entity to avoid persisting it
                $entityManager->detach($entity);
            }

            $entity = $this->revertPostProcess($entity);

            return $entity;
        }
    '''

    def private restoreDeletedEntity(Application it) '''
        /**
         * Resets a deleted entity back to the last version before it's deletion.
         *
         * @param string  $objectType Currently treated entity type
         * @param integer $id         The entity's identifier
         *
         * @return EntityAccess|null The restored entity instance
         */
        public function restoreDeletedEntity($objectType = '', $id = 0)
        {
            if (!$id) {
                return null;
            }

            $methodName = 'create' . ucfirst($objectType);
            $entity = $this->entityFactory->$methodName();
            $idField = $this->entityFactory->getIdField($objectType);
            $entity->[$idField] = $id;

            $entityManager = $this->entityFactory->getObjectManager();
            $logEntriesRepository = $entityManager->getRepository('«appName»:' . ucfirst($objectType) . 'LogEntryEntity');
            $logEntries = $logEntriesRepository->getLogEntries($entity);
            $lastVersionBeforeDeletion = null;
            foreach ($logEntries as $logEntry) {
                if ('remove' != $logEntry->getAction()) {
                    $lastVersionBeforeDeletion = $logEntry->getVersion();
                    break;
                }
            }
            if (null === $lastVersionBeforeDeletion) {
                return null;
            }

            $objectType = $entity->get_objectType();
            $versionField = $this->getVersionFieldName($objectType);

            $logEntriesRepository->revert($entity, $lastVersionBeforeDeletion);
            $versionSetter = 'set' . ucfirst($versionField);
            $entity->$versionSetter($lastVersionBeforeDeletion + 2);

            $entity = $this->revertPostProcess($entity);

            return $entity;
        }
    '''

    def private revertPostProcess(Application it) '''
        /**
         * Performs actions after reverting an entity to a previous revision.
         *
         * @param EntityAccess $entity Currently treated entity instance
         *
         * @return EntityAccess The processed entity instance
         */
        protected function revertPostProcess($entity)
        {
            $objectType = $entity->get_objectType();

            «IF hasTrees && !getTreeEntities.filter[loggable].empty»
                if (in_array($objectType, ['«getTreeEntities.filter[loggable].map[name.formatForCode].join('\', \'')»'])) {
                    // check if parent is still valid
                    $repository = $this->entityFactory->getRepository($objectType);
                    $parentId = $entity->getParent()->getId();
                    $parent = $parentId ? $repository->find($parentId) : null;
                    if (in_array('Doctrine\Common\Proxy\Proxy', class_implements($parent), true)) {
                        // look for a root node to use as parent
                        $parentNode = $repository->findOneBy(['lvl' => 0]);
                        $entity->setParent($parentNode);
                    }
                }

            «ENDIF»
            «IF hasLoggableTranslatable»
                if (in_array($objectType, ['«getLoggableTranslatableEntities.map[name.formatForCode].join('\', \'')»'])) {
                    $entity = $this->translatableHelper->setEntityFieldsFromLogData($entity);
                }
            «ENDIF»

            $eventArgs = new LifecycleEventArgs($entity, $entityManager);
            $this->entityLifecycleListener->postLoad($eventArgs);

            return $entity;
        }
    '''

    def private undeleteEntity(Application it) '''
        /**
         * Persists a formerly entity again.
         *
         * @param EntityAccess $entity Currently treated entity instance
         *
         * @return EntityAccess|null The restored entity instance
         *
         * @throws Exception If something goes wrong
         */
        public function undelete($entity)
        {
            $entityManager = $this->entityFactory->getObjectManager();

            $metadata = $entityManager->getClassMetaData(get_class($entity));
            $metadata->setIdGeneratorType(ClassMetadata::GENERATOR_TYPE_NONE);
            $metadata->setIdGenerator(new AssignedGenerator());

            $versionField = $metadata->versionField;
            $metadata->setVersioned(false);
            $metadata->setVersionField(null);

            $entityManager->persist($entity);
            $entityManager->flush($entity);

            $metadata->setVersioned(true);
            $metadata->setVersionField($versionField);
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
