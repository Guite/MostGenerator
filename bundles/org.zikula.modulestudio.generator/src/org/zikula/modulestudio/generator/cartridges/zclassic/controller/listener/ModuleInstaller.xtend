package org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener

import de.guite.modulestudio.metamodel.Application

class ModuleInstaller {

    CommonExample commonExample = new CommonExample()

    def generate(Application it, Boolean isBase) '''
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

        «IF isBase»
        /**
         * Listener for the `module.install` event.
         *
         * Called after a module has been successfully installed.
         * Receives `$modinfo` as args.
         *
         * @param ModuleStateEvent $event The event instance
         */
        «ELSE»
            /**
             * {@inheritdoc}
             */
        «ENDIF»
        public function moduleInstalled(ModuleStateEvent $event)
        {
            «IF !isBase»
                parent::moduleInstalled($event);

                «commonExample.generalEventProperties(it)»
            «ENDIF»
        }

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

        «IF isBase»
        /**
         * Listener for the `module.upgrade` event.
         *
         * Called after a module has been successfully upgraded.
         * Receives `$modinfo` as args.
         *
         * @param ModuleStateEvent $event The event instance
         */
        «ELSE»
            /**
             * {@inheritdoc}
             */
        «ENDIF»
        public function moduleUpgraded(ModuleStateEvent $event)
        {
            «IF !isBase»
                parent::moduleUpgraded($event);

                «commonExample.generalEventProperties(it)»
            «ENDIF»
        }

        «IF isBase»
        /**
         * Listener for the `module.enable` event.
         *
         * Called after a module has been successfully enabled.
         * Receives `$modinfo` as args.
         *
         * @param ModuleStateEvent $event The event instance
         */
        «ELSE»
            /**
             * {@inheritdoc}
             */
        «ENDIF»
        public function moduleEnabled(ModuleStateEvent $event)
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
         * @param ModuleStateEvent $event The event instance
         */
        «ELSE»
            /**
             * {@inheritdoc}
             */
        «ENDIF»
        public function moduleDisabled(ModuleStateEvent $event)
        {
            «IF !isBase»
                parent::moduleDisabled($event);

                «commonExample.generalEventProperties(it)»
            «ENDIF»
        }

        «IF isBase»
        /**
         * Listener for the `module.remove` event.
         *
         * Called after a module has been successfully removed.
         * Receives `$modinfo` as args.
         *
         * @param ModuleStateEvent $event The event instance
         */
        «ELSE»
            /**
             * {@inheritdoc}
             */
        «ENDIF»
        public function moduleRemoved(ModuleStateEvent $event)
        {
            «IF !isBase»
                parent::moduleRemoved($event);

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
         * @param GenericEvent $event The event instance
         */
        «ELSE»
            /**
             * {@inheritdoc}
             */
        «ENDIF»
        public function subscriberAreaUninstalled(GenericEvent $event)
        {
            «IF !isBase»
                parent::subscriberAreaUninstalled($event);

                «commonExample.generalEventProperties(it)»
            «ENDIF»
        }
    '''
}
