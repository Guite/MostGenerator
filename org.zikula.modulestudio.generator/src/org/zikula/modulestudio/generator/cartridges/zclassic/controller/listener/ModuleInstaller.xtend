package org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.extensions.Utils

class ModuleInstaller {
    extension Utils = new Utils

    CommonExample commonExample = new CommonExample()

    def generate(Application it, Boolean isBase) '''
        «IF !targets('1.3.x')»
            «IF isBase»
                /**
                 * Makes our handlers known to the event system.
                 */
            «ELSE»
                /**
                 * {@inheritdoc}
                 */
            «ENDIF»
            public static function getSubscribedEvents()
            {
                «IF isBase»
                    return [
                        CoreEvents::MODULE_INSTALL             => ['moduleInstalled', 5],
                        CoreEvents::MODULE_POSTINSTALL         => ['modulePostInstalled', 5],
                        CoreEvents::MODULE_UPGRADE             => ['moduleUpgraded', 5],
                        CoreEvents::MODULE_ENABLE              => ['moduleEnabled', 5],
                        CoreEvents::MODULE_DISABLE             => ['moduleDisabled', 5],
                        CoreEvents::MODULE_REMOVE              => ['moduleRemoved', 5],
                        'installer.subscriberarea.uninstalled' => ['subscriberAreaUninstalled', 5]
                    ];
                «ELSE»
                    return parent::getSubscribedEvents();
                «ENDIF»
            }

        «ENDIF»
        «IF isBase»
        /**
         * Listener for the `«IF targets('1.3.x')»installer.module.installed«ELSE»module.install«ENDIF»` event.
         *
         * Called after a module has been successfully installed.
         * Receives `$modinfo` as args.
         *
         * @param «IF targets('1.3.x')»Zikula_Event«ELSE»ModuleStateEvent«ENDIF» $event The event instance
         */
        «ELSE»
            /**
             * {@inheritdoc}
             */
        «ENDIF»
        public «IF targets('1.3.x')»static «ENDIF»function moduleInstalled(«IF targets('1.3.x')»Zikula_Event«ELSE»ModuleStateEvent«ENDIF» $event)
        {
            «IF !isBase»
                parent::moduleInstalled($event);

                «commonExample.generalEventProperties(it)»
            «ENDIF»
        }

        «IF !targets('1.3.x')»
            «IF isBase»
            /**
             * Listener for the `module.postinstall` event.
             *
             * Called after a module has been installed (on reload of the extensions view).
             * Receives `$modinfo` as args.
             *
             * @param ModuleStateEvent $event The event instance
             */
            «ELSE»
                /**
                 * {@inheritdoc}
                 */
            «ENDIF»
            public function modulePostInstalled(ModuleStateEvent $event)
            {
                «IF !isBase»
                    parent::modulePostInstalled($event);

                    «commonExample.generalEventProperties(it)»
                «ENDIF»
            }

        «ENDIF»
        «IF isBase»
        /**
         * Listener for the `«IF targets('1.3.x')»installer.module.upgraded«ELSE»module.upgrade«ENDIF»` event.
         *
         * Called after a module has been successfully upgraded.
         * Receives `$modinfo` as args.
         *
         * @param «IF targets('1.3.x')»Zikula_Event«ELSE»ModuleStateEvent«ENDIF» $event The event instance
         */
        «ELSE»
            /**
             * {@inheritdoc}
             */
        «ENDIF»
        public «IF targets('1.3.x')»static «ENDIF»function moduleUpgraded(«IF targets('1.3.x')»Zikula_Event«ELSE»ModuleStateEvent«ENDIF» $event)
        {
            «IF !isBase»
                parent::moduleUpgraded($event);

                «commonExample.generalEventProperties(it)»
            «ENDIF»
        }
        «IF !targets('1.3.x')»

            «IF isBase»
            /**
             * Listener for the `module.enable` event.
             *
             * Called after a module has been successfully enabled.
             * Receives `$modinfo` as args.
             *
             * @param «IF targets('1.3.x')»Zikula_Event«ELSE»ModuleStateEvent«ENDIF» $event The event instance
             */
            «ELSE»
                /**
                 * {@inheritdoc}
                 */
            «ENDIF»
            public function moduleEnabled(«IF targets('1.3.x')»Zikula_Event«ELSE»ModuleStateEvent«ENDIF» $event)
            {
                «IF !isBase»
                    parent::moduleEnabled($event);

                    «commonExample.generalEventProperties(it)»
                «ENDIF»
            }

            «IF isBase»
            /**
             * Listener for the `module.disable` event.
             *
             * Called after a module has been successfully disabled.
             * Receives `$modinfo` as args.
             *
             * @param «IF targets('1.3.x')»Zikula_Event«ELSE»ModuleStateEvent«ENDIF» $event The event instance
             */
            «ELSE»
                /**
                 * {@inheritdoc}
                 */
            «ENDIF»
            public function moduleDisabled(«IF targets('1.3.x')»Zikula_Event«ELSE»ModuleStateEvent«ENDIF» $event)
            {
                «IF !isBase»
                    parent::moduleDisabled($event);

                    «commonExample.generalEventProperties(it)»
                «ENDIF»
            }
        «ENDIF»

        «IF isBase»
        /**
         * Listener for the `«IF targets('1.3.x')»installer.module.uninstalled«ELSE»module.remove«ENDIF»` event.
         *
         * Called after a module has been successfully «IF targets('1.3.x')»uninstalled«ELSE»removed«ENDIF».
         * Receives `$modinfo` as args.
         *
         * @param «IF targets('1.3.x')»Zikula_Event«ELSE»ModuleStateEvent«ENDIF» $event The event instance
         */
        «ELSE»
            /**
             * {@inheritdoc}
             */
        «ENDIF»
        public «IF targets('1.3.x')»static «ENDIF»function module«IF targets('1.3.x')»Uninstalled«ELSE»Removed«ENDIF»(«IF targets('1.3.x')»Zikula_Event«ELSE»ModuleStateEvent«ENDIF» $event)
        {
            «IF !isBase»
                parent::module«IF targets('1.3.x')»Uninstalled«ELSE»Removed«ENDIF»($event);

                «commonExample.generalEventProperties(it)»
            «ENDIF»
        }

        «IF isBase»
        /**
         * Listener for the `installer.subscriberarea.uninstalled` event.
         *
         * Called after a hook subscriber area has been unregistered.
         * Receives args['areaid'] as the areaId. Use this to remove orphan data associated with this area.
         *
         * @param «IF targets('1.3.x')»Zikula_Event«ELSE»GenericEvent«ENDIF» $event The event instance
         */
        «ELSE»
            /**
             * {@inheritdoc}
             */
        «ENDIF»
        public «IF targets('1.3.x')»static «ENDIF»function subscriberAreaUninstalled(«IF targets('1.3.x')»Zikula_Event«ELSE»GenericEvent«ENDIF» $event)
        {
            «IF !isBase»
                parent::subscriberAreaUninstalled($event);

                «commonExample.generalEventProperties(it)»
            «ENDIF»
        }
    '''
}
