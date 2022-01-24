package org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.extensions.FormattingExtensions

class LoggableListener {

    extension FormattingExtensions = new FormattingExtensions

    def generate(Application it) '''
        public function __construct(
            protected EntityDisplayHelper $entityDisplayHelper,
            protected LoggableHelper $loggableHelper
        ) {
            parent::__construct();
        }

        protected function prePersistLogEntry($logEntry, $object)
        {
            /** @var EntityAccess $object */
            if (!$this->isEntityManagedByThisBundle($object) || !method_exists($object, 'get_objectType')) {
                return;
            }

            parent::prePersistLogEntry($logEntry, $object);

            $objectType = $object->get_objectType();

            $versionFieldName = $this->loggableHelper->getVersionFieldName($objectType);
            $versionGetter = 'get' . ucfirst($versionFieldName);

            // workaround to set correct version after restore of item
            if (
                BaseListener::ACTION_CREATE === $logEntry->getAction()
                && $logEntry->getVersion() < $object->$versionGetter()
            ) {
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
                $logEntry->setActionDescription('_HISTORY_' . mb_strtoupper($objectType) . '_UPDATED');
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
         */
        protected function isEntityManagedByThisBundle(object $entity): bool
        {
            $entityClassParts = explode('\\', $entity::class);

            if ('DoctrineProxy' === $entityClassParts[0] && '__CG__' === $entityClassParts[1]) {
                array_shift($entityClassParts);
                array_shift($entityClassParts);
            }

            return '«vendor.formatForCodeCapital»' === $entityClassParts[0] && '«name.formatForCodeCapital»Module' === $entityClassParts[1];
        }
    '''
}
