package org.zikula.modulestudio.generator.cartridges.zclassic.controller.subscriber

import de.guite.modulestudio.metamodel.Application

class UserLogoutSubscriber {

    def generate(Application it) '''
        public static function getSubscribedEvents(): array
        {
            return [
                UserPostLogoutSuccessEvent::class => ['succeeded', 5],
            ];
        }

        /**
         * Subscriber for the `UserPostLogoutSuccessEvent`.
         *
         * Occurs right after a successful logout.
         */
        public function succeeded(UserPostLogoutSuccessEvent $event): void
        {
        }
    '''
}
