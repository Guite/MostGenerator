package org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener

import de.guite.modulestudio.metamodel.modulestudio.Application

class ModuleInstaller {

    def generate(Application it, Boolean isBase) '''
        /**
         * Listener for the `installer.module.installed` event.
         *
         * Called after a module is successfully installed.
         * Receives `$modinfo` as args.
         *
         * @param Zikula_Event $event The event instance.
         */
        public static function moduleInstalled(Zikula_Event $event)
        {
            «IF !isBase»
                parent::moduleInstalled($event);
            «ENDIF»
        }

        /**
         * Listener for the `installer.module.upgraded` event.
         *
         * Called after a module is successfully upgraded.
         * Receives `$modinfo` as args.
         *
         * @param Zikula_Event $event The event instance.
         */
        public static function moduleUpgraded(Zikula_Event $event)
        {
            «IF !isBase»
                parent::moduleUpgraded($event);
            «ENDIF»
        }

        /**
         * Listener for the `installer.module.uninstalled` event.
         *
         * Called after a module is successfully uninstalled.
         * Receives `$modinfo` as args.
         *
         * @param Zikula_Event $event The event instance.
         */
        public static function moduleUninstalled(Zikula_Event $event)
        {
            «IF !isBase»
                parent::moduleUninstalled($event);
            «ENDIF»
        }

        /**
         * Listener for the `installer.subscriberarea.uninstalled` event.
         *
         * Called after a hook subscriber area is unregistered.
         * Receives args['areaid'] as the areaId. Use this to remove orphan data associated with this area.
         *
         * @param Zikula_Event $event The event instance.
         */
        public static function subscriberAreaUninstalled(Zikula_Event $event)
        {
            «IF !isBase»
                parent::subscriberAreaUninstalled($event);
            «ENDIF»
        }
    '''
}
