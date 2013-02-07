package org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Application
import org.zikula.modulestudio.generator.extensions.Utils

class UserLogout {
    @Inject extension Utils = new Utils()

    def generate(Application it, Boolean isBase) '''
        /**
         * Listener for the `module.users.ui.logout.succeeded` event.
         *
         * Occurs right after a successful logout.
         * All handlers are notified.
         * The event's subject contains the user's user record.
         * Args contain array of `array('authentication_method' => $authenticationMethod,
         *                              'uid'                   => $uid));`
         *
         * @param «IF targets('1.3.5')»Zikula_Event«ELSE»GenericEvent«ENDIF» $event The event instance.
         */
        public static function succeeded(«IF targets('1.3.5')»Zikula_Event«ELSE»GenericEvent«ENDIF» $event)
        {
            «IF !isBase»
                parent::succeeded($event);
            «ENDIF»
        }
    '''
}
