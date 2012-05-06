package org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener

import de.guite.modulestudio.metamodel.modulestudio.Application

class UserLogout {

    def generate(Application it) '''
        /**
         * Listener for the `module.users.ui.logout.succeeded` event.
         *
         * Occurs right after a successful logout.
         * All handlers are notified.
         * The event's subject contains the user's user record.
         */
        public static function succeeded(Zikula_Event $event)
        {
        }
    '''
}
