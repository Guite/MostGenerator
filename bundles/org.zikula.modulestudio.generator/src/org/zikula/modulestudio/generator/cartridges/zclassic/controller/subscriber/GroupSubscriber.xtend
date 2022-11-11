package org.zikula.modulestudio.generator.cartridges.zclassic.controller.subscriber

import de.guite.modulestudio.metamodel.Application

class GroupSubscriber {

    def generate(Application it) '''
        public static function getSubscribedEvents(): array
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
         * Subscriber for the `GroupPostCreatedEvent`.
         *
         * Occurs after a group is created.
         */
        public function create(GroupPostCreatedEvent $event): void
        {
        }

        /**
         * Subscriber for the `GroupPostUpdatedEvent`.
         *
         * Occurs after a group is updated.
         */
        public function update(GroupPostUpdatedEvent $event): void
        {
        }

        /**
         * Subscriber for the `GroupPreDeletedEvent`.
         *
         * Occurs before a group is deleted from the system.
         */
        public function preDelete(GroupPreDeletedEvent $event): void
        {
        }

        /**
         * Subscriber for the `GroupPostDeletedEvent`.
         *
         * Occurs after a group is deleted from the system.
         */
        public function delete(GroupPostDeletedEvent $event): void
        {
        }

        /**
         * Subscriber for the `GroupPostUserAddedEvent`.
         *
         * Occurs after a user is added to a group.
         */
        public function addUser(GroupPostUserAddedEvent $event): void
        {
        }

        /**
         * Subscriber for the `GroupPostUserRemovedEvent`.
         *
         * Occurs after a user is removed from a group.
         */
        public function removeUser(GroupPostUserRemovedEvent $event): void
        {
        }

        /**
         * Subscriber for the `GroupApplicationPostProcessedEvent`.
         *
         * Occurs after a group application has been processed.
         */
        public function applicationProcessed(GroupApplicationPostProcessedEvent $event): void
        {
        }

        /**
         * Subscriber for the `GroupApplicationPostCreatedEvent`.
         *
         * Occurs after the successful creation of a group application.
         */
        public function newApplication(GroupApplicationPostCreatedEvent $event): void
        {
        }
    '''
}
