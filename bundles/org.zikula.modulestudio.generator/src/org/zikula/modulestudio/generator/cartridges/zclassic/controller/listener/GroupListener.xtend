package org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener

import de.guite.modulestudio.metamodel.Application

class GroupListener {

    def generate(Application it) '''
        public static function getSubscribedEvents()
        {
            return [
                GroupPostCreatedEvent::class => ['create', 5],
                GroupPostUpdatedEvent::class => ['update', 5],
                GroupPreDeletedEvent::class => ['preDelete', 5],
                GroupPostDeletedEvent::class => ['delete', 5],
                GroupPostUserAddedEvent::class => ['addUser', 5],
                GroupPostUserRemovedEvent::class => ['removeUser', 5],
                GroupApplicationPostProcessedEvent::class => ['applicationProcessed', 5],
                GroupApplicationPostCreatedEvent::class => ['newApplication', 5],
            ];
        }

        /**
         * Listener for the `GroupPostCreatedEvent`.
         *
         * Occurs after a group is created.
         */
        public function create(GroupPostCreatedEvent $event): void
        {
        }

        /**
         * Listener for the `GroupPostUpdatedEvent`.
         *
         * Occurs after a group is updated.
         */
        public function update(GroupPostUpdatedEvent $event): void
        {
        }

        /**
         * Listener for the `GroupPreDeletedEvent`.
         *
         * Occurs before a group is deleted from the system.
         */
        public function preDelete(GroupPreDeletedEvent $event): void
        {
        }

        /**
         * Listener for the `GroupPostDeletedEvent`.
         *
         * Occurs after a group is deleted from the system.
         */
        public function delete(GroupPostDeletedEvent $event): void
        {
        }

        /**
         * Listener for the `GroupPostUserAddedEvent`.
         *
         * Occurs after a user is added to a group.
         */
        public function addUser(GroupPostUserAddedEvent $event): void
        {
        }

        /**
         * Listener for the `GroupPostUserRemovedEvent`.
         *
         * Occurs after a user is removed from a group.
         */
        public function removeUser(GroupPostUserRemovedEvent $event): void
        {
        }

        /**
         * Listener for the `GroupApplicationPostProcessedEvent`.
         *
         * Occurs after a group application has been processed.
         */
        public function applicationProcessed(GroupApplicationPostProcessedEvent $event): void
        {
        }

        /**
         * Listener for the `GroupApplicationPostCreatedEvent`.
         *
         * Occurs after the successful creation of a group application.
         */
        public function newApplication(GroupApplicationPostCreatedEvent $event): void
        {
        }
    '''
}
