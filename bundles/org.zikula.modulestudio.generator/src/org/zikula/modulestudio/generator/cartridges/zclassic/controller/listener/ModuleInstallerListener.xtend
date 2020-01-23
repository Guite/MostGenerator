package org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ModuleInstallerListener {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension Utils = new Utils

    CommonExample commonExample = new CommonExample()

    def generate(Application it) '''
        «IF amountOfExampleRows > 0»
            /**
             * @var ExampleDataHelper
             */
            protected $exampleDataHelper;

        «ENDIF»
        «IF hasUiHooksProviders»
            /**
             * @var EntityFactory
             */
            protected $entityFactory;

        «ENDIF»
        «IF amountOfExampleRows > 0 || hasUiHooksProviders»
            public function __construct(
                «IF amountOfExampleRows > 0»
                    ExampleDataHelper $exampleDataHelper«IF hasUiHooksProviders»,«ENDIF»
                «ENDIF»
                «IF hasUiHooksProviders»
                    EntityFactory $entityFactory
                «ENDIF»
            ) {
                «IF amountOfExampleRows > 0»
                    $this->exampleDataHelper = $exampleDataHelper;
                «ENDIF»
                «IF hasUiHooksProviders»
                    $this->entityFactory = $entityFactory;
                «ENDIF»
            }

        «ENDIF»
        public static function getSubscribedEvents()
        {
            return [
                «IF targets('3.0')»ExtensionEvents«ELSE»CoreEvents«ENDIF»::MODULE_INSTALL     => ['moduleInstalled', 5],
                «IF targets('3.0')»ExtensionEvents«ELSE»CoreEvents«ENDIF»::MODULE_POSTINSTALL => ['modulePostInstalled', 5],
                «IF targets('3.0')»ExtensionEvents«ELSE»CoreEvents«ENDIF»::MODULE_UPGRADE     => ['moduleUpgraded', 5],
                «IF targets('3.0')»ExtensionEvents«ELSE»CoreEvents«ENDIF»::MODULE_ENABLE      => ['moduleEnabled', 5],
                «IF targets('3.0')»ExtensionEvents«ELSE»CoreEvents«ENDIF»::MODULE_DISABLE     => ['moduleDisabled', 5],
                «IF targets('3.0')»ExtensionEvents«ELSE»CoreEvents«ENDIF»::MODULE_REMOVE      => ['moduleRemoved', 5]
            ];
        }

        /**
         * Listener for the `module.install` event.
         *
         * Called after a module has been successfully installed.
         * The event allows accessing the module bundle and the extension
         * information array using `$event->getModule()` and `$event->getModInfo()`.
         *
         «commonExample.generalEventProperties(it, false)»
         */
        public function moduleInstalled(ModuleStateEvent $event)«IF targets('3.0')»: void«ENDIF»
        {
        }

        /**
         * Listener for the `module.postinstall` event.
         *
         * Called after a module has been installed (on reload of the extensions view).
         * The event allows accessing the module bundle and the extension
         * information array using `$event->getModule()` and `$event->getModInfo()`.
         *
         «commonExample.generalEventProperties(it, false)»
         */
        public function modulePostInstalled(ModuleStateEvent $event)«IF targets('3.0')»: void«ENDIF»
        {
            «IF amountOfExampleRows > 0»
                $module = $event->getModule();
                if (null === $module) {
                    return;
                }

                if ('«appName»' === $module->getName()) {
                    $this->exampleDataHelper->createDefaultData();
                }
            «ENDIF»
        }

        /**
         * Listener for the `module.upgrade` event.
         *
         * Called after a module has been successfully upgraded.
         * The event allows accessing the module bundle and the extension
         * information array using `$event->getModule()` and `$event->getModInfo()`.
         *
         «commonExample.generalEventProperties(it, false)»
         */
        public function moduleUpgraded(ModuleStateEvent $event)«IF targets('3.0')»: void«ENDIF»
        {
        }

        /**
         * Listener for the `module.enable` event.
         *
         * Called after a module has been successfully enabled.
         * The event allows accessing the module bundle and the extension
         * information array using `$event->getModule()` and `$event->getModInfo()`.
         *
         «commonExample.generalEventProperties(it, false)»
         */
        public function moduleEnabled(ModuleStateEvent $event)«IF targets('3.0')»: void«ENDIF»
        {
        }

        /**
         * Listener for the `module.disable` event.
         *
         * Called after a module has been successfully disabled.
         * The event allows accessing the module bundle and the extension
         * information array using `$event->getModule()` and `$event->getModInfo()`.
         *
         «commonExample.generalEventProperties(it, false)»
         */
        public function moduleDisabled(ModuleStateEvent $event)«IF targets('3.0')»: void«ENDIF»
        {
        }

        /**
         * Listener for the `module.remove` event.
         *
         * Called after a module has been successfully removed.
         * The event allows accessing the module bundle and the extension
         * information array using `$event->getModule()` and `$event->getModInfo()`.
         *
         «commonExample.generalEventProperties(it, false)»
         */
        public function moduleRemoved(ModuleStateEvent $event)«IF targets('3.0')»: void«ENDIF»
        {
            «IF hasUiHooksProviders»
                $module = $event->getModule();
                if (null === $module || '«appName»' === $module->getName()) {
                    return;
                }

                // delete any existing hook assignments for the removed module
                $qb = $this->entityFactory->getEntityManager()->createQueryBuilder();
                $qb->delete('«vendor.formatForCodeCapital + '\\' + name.formatForCodeCapital + 'Module\\Entity\\HookAssignmentEntity'»', 'tbl')
                   ->where('tbl.subscriberOwner = :moduleName')
                   ->setParameter('moduleName', $module->getName());

                $query = $qb->getQuery();
                $query->execute();
            «ENDIF»
        }
    '''
}
