package org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ModuleInstaller {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension Utils = new Utils

    CommonExample commonExample = new CommonExample()

    def generate(Application it) '''
        «IF amountOfExampleRows > 0»
            /**
             * @var ExampleDataHelper
             */
            protected $exampleDataHelper

        «ENDIF»
        «IF hasUiHooksProviders»
            /**
             * @var EntityFactory
             */
            protected $entityFactory;

        «ENDIF»
        «IF amountOfExampleRows > 0 || hasUiHooksProviders»
            /**
             * InstallerListener constructor.
             *
             «IF amountOfExampleRows > 0»
             * @param ExampleDataHelper $exampleDataHelper Example data helper service instance
             «ENDIF»
             «IF hasUiHooksProviders»
             * @param EntityFactory $entityFactory EntityFactory service instance
             «ENDIF»
             */
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
        /**
         * Makes our handlers known to the event system.
         */
        public static function getSubscribedEvents()
        {
            return [
                CoreEvents::MODULE_INSTALL             => ['moduleInstalled', 5],
                CoreEvents::MODULE_POSTINSTALL         => ['modulePostInstalled', 5],
                CoreEvents::MODULE_UPGRADE             => ['moduleUpgraded', 5],
                CoreEvents::MODULE_ENABLE              => ['moduleEnabled', 5],
                CoreEvents::MODULE_DISABLE             => ['moduleDisabled', 5],
                CoreEvents::MODULE_REMOVE              => ['moduleRemoved', 5]
            ];
        }

        /**
         * Listener for the `module.install` event.
         *
         * Called after a module has been successfully installed.
         * The event allows accessing the module bundle and the extension
         * information array using `$event->getModule()` and `$event->getModInfo()`.
         *
         «commonExample.generalEventProperties(it)»
         *
         * @param ModuleStateEvent $event The event instance
         */
        public function moduleInstalled(ModuleStateEvent $event)
        {
        }

        /**
         * Listener for the `module.postinstall` event.
         *
         * Called after a module has been installed (on reload of the extensions view).
         * The event allows accessing the module bundle and the extension
         * information array using `$event->getModule()` and `$event->getModInfo()`.
         *
         «commonExample.generalEventProperties(it)»
         *
         * @param ModuleStateEvent $event The event instance
         */
        public function modulePostInstalled(ModuleStateEvent $event)
        {
            «IF amountOfExampleRows > 0»
                $module = $event->getModule();
                if (null === $module) {
                    return;
                }

                if ($module->getName() === '«appName»') {
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
         «commonExample.generalEventProperties(it)»
         *
         * @param ModuleStateEvent $event The event instance
         */
        public function moduleUpgraded(ModuleStateEvent $event)
        {
        }

        /**
         * Listener for the `module.enable` event.
         *
         * Called after a module has been successfully enabled.
         * The event allows accessing the module bundle and the extension
         * information array using `$event->getModule()` and `$event->getModInfo()`.
         *
         «commonExample.generalEventProperties(it)»
         *
         * @param ModuleStateEvent $event The event instance
         */
        public function moduleEnabled(ModuleStateEvent $event)
        {
        }

        /**
         * Listener for the `module.disable` event.
         *
         * Called after a module has been successfully disabled.
         * The event allows accessing the module bundle and the extension
         * information array using `$event->getModule()` and `$event->getModInfo()`.
         *
         «commonExample.generalEventProperties(it)»
         *
         * @param ModuleStateEvent $event The event instance
         */
        public function moduleDisabled(ModuleStateEvent $event)
        {
        }

        /**
         * Listener for the `module.remove` event.
         *
         * Called after a module has been successfully removed.
         * The event allows accessing the module bundle and the extension
         * information array using `$event->getModule()` and `$event->getModInfo()`.
         *
         «commonExample.generalEventProperties(it)»
         *
         * @param ModuleStateEvent $event The event instance
         */
        public function moduleRemoved(ModuleStateEvent $event)
        {
            «IF hasUiHooksProviders»
                $module = $event->getModule();
                if (null === $module || $module->getName() === '«appName»') {
                    return;
                }

                // delete any existing hook assignments for the removed module
                $qb = $this->entityFactory->getObjectManager()->createQueryBuilder();
                $qb->delete('«vendor.formatForCodeCapital + '\\' + name.formatForCodeCapital + 'Module\\Entity\\HookAssignmentEntity'»', 'tbl')
                   ->where('tbl.subscriberOwner = :moduleName')
                   ->setParameter('moduleName', $module->getName());

                $query = $qb->getQuery();
                $query->execute();
            «ENDIF»
        }
    '''
}
