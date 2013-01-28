package org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener

import de.guite.modulestudio.metamodel.modulestudio.Application
import com.google.inject.Inject
import org.zikula.modulestudio.generator.extensions.Utils

class ModuleInstaller {
    @Inject extension Utils = new Utils()

    def generate(Application it, Boolean isBase) '''
        /**
         * Listener for the `installer.module.installed` event.
         *
         * Called after a module is successfully installed.
         * Receives `$modinfo` as args.
         *
         * @param «IF targets('1.3.5')»Zikula_Event«ELSE»\Zikula\Core\Event\GenericEvent«ENDIF» $event The event instance.
         */
        public static function moduleInstalled(«IF targets('1.3.5')»Zikula_Event«ELSE»\Zikula\Core\Event\GenericEvent«ENDIF» $event)
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
         * @param «IF targets('1.3.5')»Zikula_Event«ELSE»\Zikula\Core\Event\GenericEvent«ENDIF» $event The event instance.
         */
        public static function moduleUpgraded(«IF targets('1.3.5')»Zikula_Event«ELSE»\Zikula\Core\Event\GenericEvent«ENDIF» $event)
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
         * @param «IF targets('1.3.5')»Zikula_Event«ELSE»\Zikula\Core\Event\GenericEvent«ENDIF» $event The event instance.
         */
        public static function moduleUninstalled(«IF targets('1.3.5')»Zikula_Event«ELSE»\Zikula\Core\Event\GenericEvent«ENDIF» $event)
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
         * @param «IF targets('1.3.5')»Zikula_Event«ELSE»\Zikula\Core\Event\GenericEvent«ENDIF» $event The event instance.
         */
        public static function subscriberAreaUninstalled(«IF targets('1.3.5')»Zikula_Event«ELSE»\Zikula\Core\Event\GenericEvent«ENDIF» $event)
        {
            «IF !isBase»
                parent::subscriberAreaUninstalled($event);
            «ENDIF»
        }
    '''
}
