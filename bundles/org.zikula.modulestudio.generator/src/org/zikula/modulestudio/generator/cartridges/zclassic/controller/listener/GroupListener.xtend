package org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.extensions.Utils

class GroupListener {

    extension Utils = new Utils

    CommonExample commonExample = new CommonExample()

    def generate(Application it) '''
        public static function getSubscribedEvents()
        {
            return [
                «IF targets('3.0')»
                    GroupPostCreatedEvent::class => ['create', 5],
                    GroupPostUpdatedEvent::class => ['update', 5],
                    GroupPreDeletedEvent::class => ['preDelete', 5],
                    GroupPostDeletedEvent::class => ['delete', 5],
                    GroupPostUserAddedEvent::class => ['addUser', 5],
                    GroupPostUserRemovedEvent::class=> ['removeUser', 5],
                    GroupApplicationPostProcessedEvent::class => ['applicationProcessed', 5],
                    GroupApplicationPostCreatedEvent::class => ['newApplication', 5],
                «ELSE»
                    GroupEvents::GROUP_CREATE => ['create', 5],
                    GroupEvents::GROUP_UPDATE => ['update', 5],
                    GroupEvents::GROUP_DELETE => ['delete', 5],
                    GroupEvents::GROUP_ADD_USER => ['addUser', 5],
                    GroupEvents::GROUP_REMOVE_USER => ['removeUser', 5],
                    GroupEvents::GROUP_APPLICATION_PROCESSED => ['applicationProcessed', 5],
                    GroupEvents::GROUP_NEW_APPLICATION => ['newApplication', 5],
                «ENDIF»
            ];
        }

        /**
         «IF targets('3.0')»
         * Listener for the `GroupPostCreatedEvent`.
         *
         * Occurs after a group is created.
         «ELSE»
         * Listener for the `group.create` event.
         *
         * Occurs after a group is created. All handlers are notified.
         * The full group record created is available as the subject.
         *
         «commonExample.generalEventProperties(it, false)»
         «ENDIF»
         */
        public function create(«IF targets('3.0')»GroupPostCreatedEvent«ELSE»GenericEvent«ENDIF» $event)«IF targets('3.0')»: void«ENDIF»
        {
        }

        /**
         «IF targets('3.0')»
         * Listener for the `GroupPostUpdatedEvent`.
         *
         * Occurs after a group is updated.
         «ELSE»
         * Listener for the `group.update` event.
         *
         * Occurs after a group is updated. All handlers are notified.
         * The full updated group record is available as the subject.
         *
         «commonExample.generalEventProperties(it, false)»
         «ENDIF»
         */
        public function update(«IF targets('3.0')»GroupPostUpdatedEvent«ELSE»GenericEvent«ENDIF» $event)«IF targets('3.0')»: void«ENDIF»
        {
        }
        «IF targets('3.0')»

        /**
         * Listener for the `GroupPreDeletedEvent`.
         *
         * Occurs before a group is deleted from the system.
         */
        public function preDelete(GroupPreDeletedEvent $event): void
        {
        }
        «ENDIF»

        /**
         «IF targets('3.0')»
         * Listener for the `GroupPostDeletedEvent`.
         *
         * Occurs after a group is deleted from the system.
         «ELSE»
         * Listener for the `group.delete` event.
         *
         * Occurs after a group is deleted from the system. All handlers are notified.
         * The full group record deleted is available as the subject.
         *
         «commonExample.generalEventProperties(it, false)»
         «ENDIF»
         */
        public function delete(«IF targets('3.0')»GroupPostDeletedEvent«ELSE»GenericEvent«ENDIF» $event)«IF targets('3.0')»: void«ENDIF»
        {
        }

        /**
         «IF targets('3.0')»
         * Listener for the `GroupPostUserAddedEvent`.
         *
         * Occurs after a user is added to a group.
         «ELSE»
         * Listener for the `group.adduser` event.
         *
         * Occurs after a user is added to a group. All handlers are notified.
         * It does not apply to pending membership requests.
         * The uid and gid are available as the subject.
         *
         «commonExample.generalEventProperties(it, false)»
         «ENDIF»
         */
        public function addUser(«IF targets('3.0')»GroupPostUserAddedEvent«ELSE»GenericEvent«ENDIF» $event)«IF targets('3.0')»: void«ENDIF»
        {
        }

        /**
         «IF targets('3.0')»
         * Listener for the `GroupPostUserRemovedEvent`.
         *
         * Occurs after a user is removed from a group.
         «ELSE»
         * Listener for the `group.removeuser` event.
         *
         * Occurs after a user is removed from a group. All handlers are notified.
         * The uid and gid are available as the subject.
         *
         «commonExample.generalEventProperties(it, false)»
         «ENDIF»
         */
        public function removeUser(«IF targets('3.0')»GroupPostUserRemovedEvent«ELSE»GenericEvent«ENDIF» $event)«IF targets('3.0')»: void«ENDIF»
        {
        }

        /**
         «IF targets('3.0')»
         * Listener for the `GroupApplicationPostProcessedEvent`.
         *
         * Occurs after a group application has been processed.
         «ELSE»
         * Listener for the `group.application.processed` event.
         *
         * Occurs after a group application has been processed.
         * The subject is the GroupApplicationEntity.
         * Arguments are the form data from \Zikula\GroupsModule\Form\Type\ManageApplicationType
         *
         «commonExample.generalEventProperties(it, false)»
         «ENDIF»
         */
        public function applicationProcessed(«IF targets('3.0')»GroupApplicationPostProcessedEvent«ELSE»GenericEvent«ENDIF» $event)«IF targets('3.0')»: void«ENDIF»
        {
        }

        /**
         «IF targets('3.0')»
         * Listener for the `GroupApplicationPostCreatedEvent`.
         *
         * Occurs after the successful creation of a group application.
         «ELSE»
         * Listener for the `group.application.new` event.
         *
         * Occurs after the successful creation of a group application.
         * The subject is the GroupApplicationEntity.
         *
         «commonExample.generalEventProperties(it, false)»
         «ENDIF»
         */
        public function newApplication(«IF targets('3.0')»GroupApplicationPostCreatedEvent«ELSE»GenericEvent«ENDIF» $event)«IF targets('3.0')»: void«ENDIF»
        {
        }
    '''
}
