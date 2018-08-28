package org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener

import de.guite.modulestudio.metamodel.Application

class UserLogoutListener {

    CommonExample commonExample = new CommonExample()

    def generate(Application it) '''
        /**
         * Makes our handlers known to the event system.
         */
        public static function getSubscribedEvents()
        {
            return [
                AccessEvents::LOGOUT_SUCCESS => ['succeeded', 5]
            ];
        }

        /**
         * Listener for the `module.users.ui.logout.succeeded` event.
         *
         * Occurs right after a successful logout. All handlers are notified.
         * The event's subject contains the user's UserEntity.
         * Args contain array of `['authentication_method' => $authenticationMethod,
         *                         'uid'                   => $uid];`
         *
         «commonExample.generalEventProperties(it, false)»
         * @param GenericEvent $event The event instance
         */
        public function succeeded(GenericEvent $event)
        {
        }
    '''
}
