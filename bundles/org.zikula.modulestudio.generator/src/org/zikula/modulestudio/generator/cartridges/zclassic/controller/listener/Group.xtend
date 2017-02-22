package org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener

import de.guite.modulestudio.metamodel.Application

class Group {

    CommonExample commonExample = new CommonExample()

    def generate(Application it, Boolean isBase) '''
        «IF isBase»
            /**
             * Makes our handlers known to the event system.
             */
        «ELSE»
            /**
             * @inheritDoc
             */
        «ENDIF»
        public static function getSubscribedEvents()
        {
            «IF isBase»
                return [
                    GroupEvents::GROUP_CREATE      => ['create', 5],
                    GroupEvents::GROUP_UPDATE      => ['update', 5],
                    GroupEvents::GROUP_DELETE      => ['delete', 5],
                    GroupEvents::GROUP_ADD_USER    => ['addUser', 5],
                    GroupEvents::GROUP_REMOVE_USER => ['removeUser', 5],
                    GroupEvents::GROUP_APPLICATION_PROCESSED => ['applicationProcessed', 5],
                    GroupEvents::GROUP_NEW_APPLICATION => ['newApplication', 5]
                ];
            «ELSE»
                return parent::getSubscribedEvents();
            «ENDIF»
        }

        «IF isBase»
        /**
         * Listener for the `group.create` event.
         *
         * Occurs after a group is created. All handlers are notified.
         * The full group record created is available as the subject.
         *
         * @param GenericEvent $event The event instance
         */
        «ELSE»
            /**
             * @inheritDoc
             */
        «ENDIF»
        public function create(GenericEvent $event)
        {
            «IF !isBase»
                parent::create($event);

                «commonExample.generalEventProperties(it)»
            «ENDIF»
        }

        «IF isBase»
        /**
         * Listener for the `group.update` event.
         *
         * Occurs after a group is updated. All handlers are notified.
         * The full updated group record is available as the subject.
         *
         * @param GenericEvent $event The event instance
         */
        «ELSE»
            /**
             * @inheritDoc
             */
        «ENDIF»
        public function update(GenericEvent $event)
        {
            «IF !isBase»
                parent::update($event);

                «commonExample.generalEventProperties(it)»
            «ENDIF»
        }

        «IF isBase»
        /**
         * Listener for the `group.delete` event.
         *
         * Occurs after a group is deleted from the system. All handlers are notified.
         * The full group record deleted is available as the subject.
         *
         * @param GenericEvent $event The event instance
         */
        «ELSE»
            /**
             * @inheritDoc
             */
        «ENDIF»
        public function delete(GenericEvent $event)
        {
            «IF !isBase»
                parent::delete($event);

                «commonExample.generalEventProperties(it)»
            «ENDIF»
        }

        «IF isBase»
        /**
         * Listener for the `group.adduser` event.
         *
         * Occurs after a user is added to a group. All handlers are notified.
         * It does not apply to pending membership requests.
         * The uid and gid are available as the subject.
         *
         * @param GenericEvent $event The event instance
         */
        «ELSE»
            /**
             * @inheritDoc
             */
        «ENDIF»
        public function addUser(GenericEvent $event)
        {
            «IF !isBase»
                parent::addUser($event);

                «commonExample.generalEventProperties(it)»
            «ENDIF»
        }

        «IF isBase»
        /**
         * Listener for the `group.removeuser` event.
         *
         * Occurs after a user is removed from a group. All handlers are notified.
         * The uid and gid are available as the subject.
         *
         * @param GenericEvent $event The event instance
         */
        «ELSE»
            /**
             * @inheritDoc
             */
        «ENDIF»
        public function removeUser(GenericEvent $event)
        {
            «IF !isBase»
                parent::removeUser($event);

                «commonExample.generalEventProperties(it)»
            «ENDIF»
        }

        «IF isBase»
        /**
         * Listener for the `group.application.processed` event.
         *
         * Occurs after a group application has been processed.
         * The subject is the GroupApplicationEntity.
         * Arguments are the form data from \Zikula\GroupsModule\Form\Type\ManageApplicationType
         *
         * @param GenericEvent $event The event instance
         */
        «ELSE»
            /**
             * @inheritDoc
             */
        «ENDIF»
        public function applicationProcessed(GenericEvent $event)
        {
            «IF !isBase»
                parent::applicationProcessed($event);

                «commonExample.generalEventProperties(it)»
            «ENDIF»
        }

        «IF isBase»
        /**
         * Listener for the `group.application.new` event.
         *
         * Occurs after the successful creation of a group application.
         * The subject is the GroupApplicationEntity.
         *
         * @param GenericEvent $event The event instance
         */
        «ELSE»
            /**
             * @inheritDoc
             */
        «ENDIF»
        public function newApplication(GenericEvent $event)
        {
            «IF !isBase»
                parent::newApplication($event);

                «commonExample.generalEventProperties(it)»
            «ENDIF»
        }
    '''
}
