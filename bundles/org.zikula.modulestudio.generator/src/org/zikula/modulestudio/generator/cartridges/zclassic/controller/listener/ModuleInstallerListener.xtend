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
                «IF targets('3.0')»
                    ExtensionPostInstallEvent::class      => ['extensionInstalled', 5],
                    ExtensionPostCacheRebuildEvent::class => ['extensionPostInstalled', 5],
                    ExtensionPostUpgradeEvent::class      => ['extensionUpgraded', 5],
                    ExtensionPostEnabledEvent::class      => ['extensionEnabled', 5],
                    ExtensionPostDisabledEvent::class     => ['extensionDisabled', 5],
                    ExtensionPostRemoveEvent::class       => ['extensionRemoved', 5]
                «ELSE»
                    CoreEvents::MODULE_INSTALL     => ['moduleInstalled', 5],
                    CoreEvents::MODULE_POSTINSTALL => ['modulePostInstalled', 5],
                    CoreEvents::MODULE_UPGRADE     => ['moduleUpgraded', 5],
                    CoreEvents::MODULE_ENABLE      => ['moduleEnabled', 5],
                    CoreEvents::MODULE_DISABLE     => ['moduleDisabled', 5],
                    CoreEvents::MODULE_REMOVE      => ['moduleRemoved', 5]
                «ENDIF»
            ];
        }

        /**
         «IF targets('3.0')»
         * Listener for the `ExtensionPostInstallEvent`.
         *
         * Occurs when an extension has been successfully installed but before the Cache has been reloaded.
         «ELSE»
         * Listener for the `«IF targets('3.0')»extension«ELSE»module«ENDIF».install` event.
         *
         * Called after a«IF targets('3.0')»n extension«ELSE» module«ENDIF» has been successfully installed.
         * The event allows accessing the «IF targets('3.0')»extension«ELSE»module«ENDIF» bundle and the extension
         * information array using `$event->get«IF targets('3.0')»Extension«ELSE»Module«ENDIF»()` and `$event->get«IF targets('3.0')»Info«ELSE»ModInfo«ENDIF»()`.
         *
         «commonExample.generalEventProperties(it, false)»
         «ENDIF»
         */
        public function «IF targets('3.0')»extension«ELSE»module«ENDIF»Installed(«IF targets('3.0')»ExtensionPostInstallEvent«ELSE»ModuleStateEvent«ENDIF» $event)«IF targets('3.0')»: void«ENDIF»
        {
        }

        /**
         «IF targets('3.0')»
         * Listener for the `ExtensionPostCacheRebuildEvent`.
         *
         * Occurs when an extension has been successfully installed
         * and then the Cache has been reloaded after a second Request.
         «ELSE»
         * Listener for the `«IF targets('3.0')»extension«ELSE»module«ENDIF».postinstall` event.
         *
         * Called after a«IF targets('3.0')»n extension«ELSE» module«ENDIF» has been installed (on reload of the extensions view).
         * The event allows accessing the «IF targets('3.0')»extension«ELSE»module«ENDIF» bundle and the extension
         * information array using `$event->get«IF targets('3.0')»Extension«ELSE»Module«ENDIF»()` and `$event->get«IF targets('3.0')»Info«ELSE»ModInfo«ENDIF»()`.
         *
         «commonExample.generalEventProperties(it, false)»
         «ENDIF»
         */
        public function «IF targets('3.0')»extension«ELSE»module«ENDIF»PostInstalled(«IF targets('3.0')»ExtensionPostCacheRebuildEvent«ELSE»ModuleStateEvent«ENDIF» $event)«IF targets('3.0')»: void«ENDIF»
        {
            «IF amountOfExampleRows > 0»
                $«IF targets('3.0')»extension«ELSE»module«ENDIF» = $event->get«IF targets('3.0')»ExtensionBundle«ELSE»Module«ENDIF»();
                if (null === $«IF targets('3.0')»extension«ELSE»module«ENDIF») {
                    return;
                }

                if ('«appName»' === $«IF targets('3.0')»extension«ELSE»module«ENDIF»->getName()) {
                    $this->exampleDataHelper->createDefaultData();
                }
            «ENDIF»
        }

        /**
         «IF targets('3.0')»
         * Listener for the `ExtensionPostUpgradeEvent`.
         *
         * Occurs when an extension has been upgraded to a newer version.
         «ELSE»
         * Listener for the `«IF targets('3.0')»extension«ELSE»module«ENDIF».upgrade` event.
         *
         * Called after a«IF targets('3.0')»n extension«ELSE» module«ENDIF» has been successfully upgraded.
         * The event allows accessing the «IF targets('3.0')»extension«ELSE»module«ENDIF» bundle and the extension
         * information array using `$event->get«IF targets('3.0')»Extension«ELSE»Module«ENDIF»()` and `$event->get«IF targets('3.0')»Info«ELSE»ModInfo«ENDIF»()`.
         *
         «commonExample.generalEventProperties(it, false)»
         «ENDIF»
         */
        public function «IF targets('3.0')»extension«ELSE»module«ENDIF»Upgraded(«IF targets('3.0')»ExtensionPostUpgradeEvent«ELSE»ModuleStateEvent«ENDIF» $event)«IF targets('3.0')»: void«ENDIF»
        {
        }

        /**
         «IF targets('3.0')»
         * Listener for the `ExtensionPostEnabledEvent`.
         *
         * Occurs when an extension has been enabled after it was previously disabled.
         «ELSE»
         * Listener for the `«IF targets('3.0')»extension«ELSE»module«ENDIF».enable` event.
         *
         * Called after a«IF targets('3.0')»n extension«ELSE» module«ENDIF» has been successfully enabled.
         * The event allows accessing the «IF targets('3.0')»extension«ELSE»module«ENDIF» bundle and the extension
         * information array using `$event->get«IF targets('3.0')»Extension«ELSE»Module«ENDIF»()` and `$event->get«IF targets('3.0')»Info«ELSE»ModInfo«ENDIF»()`.
         *
         «commonExample.generalEventProperties(it, false)»
         «ENDIF»
         */
        public function «IF targets('3.0')»extension«ELSE»module«ENDIF»Enabled(«IF targets('3.0')»ExtensionPostEnabledEvent«ELSE»ModuleStateEvent«ENDIF» $event)«IF targets('3.0')»: void«ENDIF»
        {
        }

        /**
         «IF targets('3.0')»
         * Listener for the `ExtensionPostDisabledEvent`.
         *
         * Occurs when an extension has been disabled.
         «ELSE»
         * Listener for the `«IF targets('3.0')»extension«ELSE»module«ENDIF».disable` event.
         *
         * Called after a«IF targets('3.0')»n extension«ELSE» module«ENDIF» has been successfully disabled.
         * The event allows accessing the module bundle and the extension
         * information array using `$event->get«IF targets('3.0')»Extension«ELSE»Module«ENDIF»()` and `$event->get«IF targets('3.0')»Info«ELSE»ModInfo«ENDIF»()`.
         *
         «commonExample.generalEventProperties(it, false)»
         «ENDIF»
         */
        public function «IF targets('3.0')»extension«ELSE»module«ENDIF»Disabled(«IF targets('3.0')»ExtensionPostDisabledEvent«ELSE»ModuleStateEvent«ENDIF» $event)«IF targets('3.0')»: void«ENDIF»
        {
        }

        /**
         «IF targets('3.0')»
         * Listener for the `ExtensionPostRemoveEvent`.
         *
         * Occurs when an extension has been removed entirely.
         «ELSE»
         * Listener for the `«IF targets('3.0')»extension«ELSE»module«ENDIF».remove` event.
         *
         * Called after a«IF targets('3.0')»n extension«ELSE» module«ENDIF» has been successfully removed.
         * The event allows accessing the module bundle and the extension
         * information array using `$event->get«IF targets('3.0')»Extension«ELSE»Module«ENDIF»()` and `$event->get«IF targets('3.0')»Info«ELSE»ModInfo«ENDIF»()`.
         *
         «commonExample.generalEventProperties(it, false)»
         «ENDIF»
         */
        public function «IF targets('3.0')»extension«ELSE»module«ENDIF»Removed(«IF targets('3.0')»ExtensionPostRemoveEvent«ELSE»ModuleStateEvent«ENDIF» $event)«IF targets('3.0')»: void«ENDIF»
        {
            «IF hasUiHooksProviders»
                $«IF targets('3.0')»extension«ELSE»module«ENDIF» = $event->get«IF targets('3.0')»ExtensionBundle«ELSE»Module«ENDIF»();
                if (null === $«IF targets('3.0')»extension«ELSE»module«ENDIF» || '«appName»' === $«IF targets('3.0')»extension«ELSE»module«ENDIF»->getName()) {
                    return;
                }

                // delete any existing hook assignments for the removed «IF targets('3.0')»extension«ELSE»module«ENDIF»
                $qb = $this->entityFactory->getEntityManager()->createQueryBuilder();
                $qb->delete('«vendor.formatForCodeCapital + '\\' + name.formatForCodeCapital + 'Module\\Entity\\HookAssignmentEntity'»', 'tbl')
                   ->where('tbl.subscriberOwner = :«IF targets('3.0')»extension«ELSE»module«ENDIF»Name')
                   ->setParameter('«IF targets('3.0')»extension«ELSE»module«ENDIF»Name', $«IF targets('3.0')»extension«ELSE»module«ENDIF»->getName());

                $query = $qb->getQuery();
                $query->execute();
            «ENDIF»
        }
    '''
}
