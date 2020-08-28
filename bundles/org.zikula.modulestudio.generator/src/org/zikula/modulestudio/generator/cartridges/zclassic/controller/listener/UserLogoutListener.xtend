package org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.extensions.Utils

class UserLogoutListener {

    extension Utils = new Utils

    CommonExample commonExample = new CommonExample()

    def generate(Application it) '''
        public static function getSubscribedEvents()
        {
            return [
                «IF targets('3.0')»
                    UserPostLogoutSuccessEvent::class => ['succeeded', 5],
                «ELSE»
                    AccessEvents::LOGOUT_SUCCESS => ['succeeded', 5],
                «ENDIF»
            ];
        }

        /**
         «IF targets('3.0')»
         * Listener for the `UserPostLogoutSuccessEvent`.
         *
         * Occurs right after a successful logout.
         «ELSE»
         * Listener for the `module.users.ui.logout.succeeded` event.
         *
         * Occurs right after a successful logout. All handlers are notified.
         * The event's subject contains the user's UserEntity.
         * Args contain array of `['authentication_method' => $authenticationMethod,
         *                         'uid'                   => $uid];`
         *
         «commonExample.generalEventProperties(it, false)»
         «ENDIF»
         */
        public function succeeded(«IF targets('3.0')»UserPostLogoutSuccessEvent«ELSE»GenericEvent«ENDIF» $event)«IF targets('3.0')»: void«ENDIF»
        {
        }
    '''
}
