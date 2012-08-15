package org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener

import de.guite.modulestudio.metamodel.modulestudio.Application

class Users {

    def generate(Application it, Boolean isBase) '''
        /**
         * Listener for the `module.users.config.updated` event.
         *
         * Occurs after the Users module configuration has been
         * updated via the administration interface.
         *
         * @param Zikula_Event $event The event instance.
         */
        public static function configUpdated(Zikula_Event $event)
        {
            «IF !isBase»
                parent::configUpdated($event);
            «ENDIF»
        }
    '''
}
