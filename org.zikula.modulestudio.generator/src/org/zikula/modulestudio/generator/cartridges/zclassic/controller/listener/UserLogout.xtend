package org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener

import de.guite.modulestudio.metamodel.modulestudio.Application

class UserLogout {

    def generate(Application it, Boolean isBase) '''
        /**
         * Listener for the `module.users.ui.logout.succeeded` event.
         *
         * Occurs right after a successful logout.
         * All handlers are notified.
         * The event's subject contains the user's user record.
         *
         * @param Zikula_Event $event The event instance.
         */
        public static function succeeded(Zikula_Event $event)
        {
            «IF !isBase»
                parent::succeeded($event);
            «ENDIF»
        }
    '''
}
