package org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener

import de.guite.modulestudio.metamodel.Application

class UserLogout {

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
                    AccessEvents::LOGOUT_SUCCESS => ['succeeded', 5]
                ];
            «ELSE»
                return parent::getSubscribedEvents();
            «ENDIF»
        }

        «IF isBase»
        /**
         * Listener for the `module.users.ui.logout.succeeded` event.
         *
         * Occurs right after a successful logout. All handlers are notified.
         * The event's subject contains the user's UserEntity.
         * Args contain array of `['authentication_method' => $authenticationMethod,
         *                         'uid'                   => $uid];`
         *
         * @param GenericEvent $event The event instance
         */
        «ELSE»
            /**
             * @inheritDoc
             */
        «ENDIF»
        public function succeeded(GenericEvent $event)
        {
            «IF !isBase»
                parent::succeeded($event);

                «commonExample.generalEventProperties(it)»
            «ENDIF»
        }
    '''
}
