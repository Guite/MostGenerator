package org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener

import de.guite.modulestudio.metamodel.modulestudio.Application
import com.google.inject.Inject
import org.zikula.modulestudio.generator.extensions.Utils

class ModuleInstaller {
    @Inject extension Utils = new Utils

    def generate(Application it, Boolean isBase) '''
        /**
         * Listener for the `installer.module.installed` event.
         *
         * Called after a module has been successfully installed.
         * Receives `$modinfo` as args.
         *
         * @param «IF targets('1.3.5')»Zikula_Event«ELSE»GenericEvent«ENDIF» $event The event instance.
         */
        public static function moduleInstalled(«IF targets('1.3.5')»Zikula_Event«ELSE»GenericEvent«ENDIF» $event)
        {
            «IF !isBase»
                parent::moduleInstalled($event);
            «ENDIF»
        }

        /**
         * Listener for the `installer.module.upgraded` event.
         *
         * Called after a module has been successfully upgraded.
         * Receives `$modinfo` as args.
         *
         * @param «IF targets('1.3.5')»Zikula_Event«ELSE»GenericEvent«ENDIF» $event The event instance.
         */
        public static function moduleUpgraded(«IF targets('1.3.5')»Zikula_Event«ELSE»GenericEvent«ENDIF» $event)
        {
            «IF !isBase»
                parent::moduleUpgraded($event);
            «ENDIF»
        }

        /**
         * Listener for the `installer.module.uninstalled` event.
         *
         * Called after a module has been successfully uninstalled.
         * Receives `$modinfo` as args.
         *
         * @param «IF targets('1.3.5')»Zikula_Event«ELSE»GenericEvent«ENDIF» $event The event instance.
         */
        public static function moduleUninstalled(«IF targets('1.3.5')»Zikula_Event«ELSE»GenericEvent«ENDIF» $event)
        {
            «IF !isBase»
                parent::moduleUninstalled($event);
            «ENDIF»
        }
        «IF !targets('1.3.5')»

            /**
             * Listener for the `installer.module.activated` event.
             *
             * Called after a module has been successfully activated.
             * Receives `$modinfo` as args.
             */
            public static function moduleActivated(«IF targets('1.3.5')»Zikula_Event«ELSE»GenericEvent«ENDIF» $event)
            {
                «IF !isBase»
                    parent::moduleActivated($event);
                «ENDIF»
            }

            /**
             * Listener for the `installer.module.deactivated` event.
             *
             * Called after a module has been successfully deactivated.
             * Receives `$modinfo` as args.
             */
            public static function moduleDeactivated(«IF targets('1.3.5')»Zikula_Event«ELSE»GenericEvent«ENDIF» $event)
            {
                «IF !isBase»
                    parent::moduleDeactivated($event);
                «ENDIF»
            }
        «ENDIF»

        /**
         * Listener for the `installer.subscriberarea.uninstalled` event.
         *
         * Called after a hook subscriber area has been unregistered.
         * Receives args['areaid'] as the areaId. Use this to remove orphan data associated with this area.
         *
         * @param «IF targets('1.3.5')»Zikula_Event«ELSE»GenericEvent«ENDIF» $event The event instance.
         */
        public static function subscriberAreaUninstalled(«IF targets('1.3.5')»Zikula_Event«ELSE»GenericEvent«ENDIF» $event)
        {
            «IF !isBase»
                parent::subscriberAreaUninstalled($event);
            «ENDIF»
        }
    '''
}
