package org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener

import de.guite.modulestudio.metamodel.Application

class UserLogoutListener {

    def generate(Application it) '''
        public static function getSubscribedEvents(): array
        {
            return [
                UserPostLogoutSuccessEvent::class => ['succeeded', 5],
            ];
        }

        /**
         * Listener for the `UserPostLogoutSuccessEvent`.
         *
         * Occurs right after a successful logout.
         */
        public function succeeded(UserPostLogoutSuccessEvent $event): void
        {
        }
    '''
}
