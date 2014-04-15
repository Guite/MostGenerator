package org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener

import de.guite.modulestudio.metamodel.modulestudio.Application
import com.google.inject.Inject
import org.zikula.modulestudio.generator.extensions.Utils

class ModuleInstaller {
    @Inject extension Utils = new Utils

    def generate(Application it, Boolean isBase) '''
        /**
         * Listener for the `«IF targets('1.3.5')»installer.module.installed«ELSE»module.install«ENDIF»` event.
         *
         * Called after a module has been successfully installed.
         * Receives `$modinfo` as args.
         *
         * @param «IF targets('1.3.5')»Zikula_Event«ELSE»ModuleStateEvent«ENDIF» $event The event instance.
         */
        public static function moduleInstalled(«IF targets('1.3.5')»Zikula_Event«ELSE»ModuleStateEvent«ENDIF» $event)
        {
            «IF !isBase»
                parent::moduleInstalled($event);
            «ENDIF»
        }

        /**
         * Listener for the `«IF targets('1.3.5')»installer.module.upgraded«ELSE»module.upgrade«ENDIF»` event.
         *
         * Called after a module has been successfully upgraded.
         * Receives `$modinfo` as args.
         *
         * @param «IF targets('1.3.5')»Zikula_Event«ELSE»ModuleStateEvent«ENDIF» $event The event instance.
         */
        public static function moduleUpgraded(«IF targets('1.3.5')»Zikula_Event«ELSE»ModuleStateEvent«ENDIF» $event)
        {
            «IF !isBase»
                parent::moduleUpgraded($event);
            «ENDIF»
        }
        «IF !targets('1.3.5')»

            /**
             * Listener for the `module.enable` event.
             *
             * Called after a module has been successfully enabled.
             * Receives `$modinfo` as args.
             */
            public static function moduleEnabled(«IF targets('1.3.5')»Zikula_Event«ELSE»ModuleStateEvent«ENDIF» $event)
            {
                «IF !isBase»
                    parent::moduleEnabled($event);
                «ENDIF»
            }

            /**
             * Listener for the `module.disable` event.
             *
             * Called after a module has been successfully disabled.
             * Receives `$modinfo` as args.
             */
            public static function moduleDisabled(«IF targets('1.3.5')»Zikula_Event«ELSE»ModuleStateEvent«ENDIF» $event)
            {
                «IF !isBase»
                    parent::moduleDisabled($event);
                «ENDIF»
            }
        «ENDIF»

        /**
         * Listener for the `«IF targets('1.3.5')»installer.module.uninstalled«ELSE»module.remove«ENDIF»` event.
         *
         * Called after a module has been successfully «IF targets('1.3.5')»uninstalled«ELSE»removed«ENDIF».
         * Receives `$modinfo` as args.
         *
         * @param «IF targets('1.3.5')»Zikula_Event«ELSE»GenericEvent«ENDIF» $event The event instance.
         */
        public static function module«IF targets('1.3.5')»Uninstalled«ELSE»Removed«ENDIF»(«IF targets('1.3.5')»Zikula_Event«ELSE»ModuleStateEvent«ENDIF» $event)
        {
            «IF !isBase»
                parent::moduleUninstalled($event);
            «ENDIF»
        }

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
        «IF !targets('1.3.5')»

            /**
             * Makes our handlers known to the event system.
             */
            public static function getSubscribedEvents()
            {
                «IF isBase»
                    return array(
                        CoreEvents::MODULE_INSTALL              => array('moduleInstalled', 5),
                        CoreEvents::MODULE_UPGRADE              => array('moduleUpgraded', 5),
                        CoreEvents::MODULE_ENABLE               => array('moduleEnabled', 5),
                        CoreEvents::MODULE_DISABLE              => array('moduleDisabled', 5),
                        CoreEvents::MODULE_REMOVE               => array('moduleRemoved', 5),
                        'installer.subscriberarea.uninstalled'  => array('subscriberAreaUninstalled', 5)
                    );
                «ELSE»
                    return parent::getSubscribedEvents();
                «ENDIF»
            }
        «ENDIF»
    '''
}
