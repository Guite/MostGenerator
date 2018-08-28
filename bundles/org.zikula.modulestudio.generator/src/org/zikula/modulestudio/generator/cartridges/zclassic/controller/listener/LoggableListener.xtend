package org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener

import de.guite.modulestudio.metamodel.Application

class LoggableListener {

    def generate(Application it) '''
        /**
         * @var EntityDisplayHelper
         */
        protected $entityDisplayHelper;

        /**
         * @var LoggableHelper
         */
        protected $loggableHelper;

        /**
         * LoggableListener constructor.
         *
         * @param EntityDisplayHelper $entityDisplayHelper EntityDisplayHelper service instance
         * @param LoggableHelper      $loggableHelper      LoggableHelper service instance
         */
        public function __construct(
            EntityDisplayHelper $entityDisplayHelper,
            LoggableHelper $loggableHelper
        ) {
            parent::__construct();
            $this->entityDisplayHelper = $entityDisplayHelper;
            $this->loggableHelper = $loggableHelper;
        }

        /**
         * @inheritDoc
         */
        protected function prePersistLogEntry($logEntry, $object)
        {
            parent::prePersistLogEntry($logEntry, $object);

            $objectType = $object->get_objectType();

            $versionFieldName = $this->loggableHelper->getVersionFieldName($objectType);
            $versionGetter = 'get' . ucfirst($versionFieldName);

            // workaround to set correct version after restore of item
            if (BaseListener::ACTION_CREATE == $logEntry->getAction() && $logEntry->getVersion() < $object->$versionGetter()) {
                $logEntry->setVersion($object->$versionGetter());
            }

            if (!method_exists($logEntry, 'setActionDescription')) {
                return;
            }

            if (BaseListener::ACTION_REMOVE == $logEntry->getAction()) {
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

        /**
         * @inheritDoc
         * /
        protected function createLogEntry($action, $object, LoggableAdapter $ea)
        {
            $logEntry = parent::createLogEntry($action, $object, $ea);

            // ...

            // note in getObjectChangeSetData() there is both the old data (in $changes[0]) as well as the new data (in $changes[1]) available
        }

         */»
    '''
}
