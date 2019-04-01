package org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class LoggableListener {

    extension FormattingExtensions = new FormattingExtensions
    extension Utils = new Utils

    def generate(Application it) '''
        /**
         * @var EntityDisplayHelper
         */
        protected $entityDisplayHelper;

        /**
         * @var LoggableHelper
         */
        protected $loggableHelper;

        public function __construct(
            EntityDisplayHelper $entityDisplayHelper,
            LoggableHelper $loggableHelper
        ) {
            parent::__construct();
            $this->entityDisplayHelper = $entityDisplayHelper;
            $this->loggableHelper = $loggableHelper;
        }

        protected function prePersistLogEntry($logEntry, $object)
        {
            parent::prePersistLogEntry($logEntry, $object);

            /** @var EntityAccess $object */
            if (!$this->isEntityManagedByThisBundle($object) || !method_exists($object, 'get_objectType')) {
                return;
            }

            $objectType = $object->get_objectType();

            $versionFieldName = $this->loggableHelper->getVersionFieldName($objectType);
            $versionGetter = 'get' . ucfirst($versionFieldName);

            // workaround to set correct version after restore of item
            if (BaseListener::ACTION_CREATE === $logEntry->getAction() && $logEntry->getVersion() < $object->$versionGetter()) {
                $logEntry->setVersion($object->$versionGetter());
            }

            if (!method_exists($logEntry, 'setActionDescription')) {
                return;
            }

            if (BaseListener::ACTION_REMOVE === $logEntry->getAction()) {
                // provide title to make the object identifiable in the list of deleted entities
                $logEntry->setActionDescription($this->entityDisplayHelper->getFormattedTitle($object));

                return;
            }

            if (method_exists($object, 'get_actionDescriptionForLogEntry')) {
                $logEntry->setActionDescription($object->get_actionDescriptionForLogEntry());
            }
            if (!$logEntry->getActionDescription()) {
                // treat all changes without an explicit description as update
                $logEntry->setActionDescription('_HISTORY_' . strtoupper($objectType) . '_UPDATED');
            }
        }«/*
         * to add post-processing we could do:
         *
        use Gedmo\Loggable\Mapping\Event\LoggableAdapter;

        protected function createLogEntry($action, $object, LoggableAdapter $ea)
        {
            $logEntry = parent::createLogEntry($action, $object, $ea);

            // ...

            // note in getObjectChangeSetData() there is both the old data (in $changes[0]) as well as the new data (in $changes[1]) available
        }

         */»

        protected function createLogEntry($action, $object, LoggableAdapter $ea)
        {
            if (!$this->isEntityManagedByThisBundle($object) || !method_exists($object, 'get_objectType')) {
                return;
            }

            return parent::createLogEntry($action, $object, $ea);
        }

        /**
         * Checks whether this listener is responsible for the given entity or not.
         *
         * @param EntityAccess $entity The given entity
         «IF !targets('3.0')»
         *
         * @return bool True if entity is managed by this listener, false otherwise
         «ENDIF»
         */
        protected function isEntityManagedByThisBundle($entity)«IF targets('3.0')»: bool«ENDIF»
        {
            $entityClassParts = explode('\\', get_class($entity));

            if ('DoctrineProxy' === $entityClassParts[0] && '__CG__' === $entityClassParts[1]) {
                array_shift($entityClassParts);
                array_shift($entityClassParts);
            }

            return '«vendor.formatForCodeCapital»' === $entityClassParts[0] && '«name.formatForCodeCapital»Module' === $entityClassParts[1];
        }
    '''
}
