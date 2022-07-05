package org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.extensions.Utils

class ModuleInstallerListener {

    extension Utils = new Utils

    def generate(Application it) '''
        «IF amountOfExampleRows > 0»
            public function __construct(protected ExampleDataHelper $exampleDataHelper)
            {
            }

        «ENDIF»
        public static function getSubscribedEvents()
        {
            return [
                ExtensionPostInstallEvent::class => ['extensionInstalled', 5],
                ExtensionPostCacheRebuildEvent::class => ['extensionPostInstalled', 5],
                ExtensionPostUpgradeEvent::class => ['extensionUpgraded', 5],
                ExtensionPostEnabledEvent::class => ['extensionEnabled', 5],
                ExtensionPostDisabledEvent::class => ['extensionDisabled', 5],
                ExtensionPostRemoveEvent::class => ['extensionRemoved', 5],
            ];
        }

        /**
         * Listener for the `ExtensionPostInstallEvent`.
         *
         * Occurs when an extension has been successfully installed but before the Cache has been reloaded.
         */
        public function extensionInstalled(ExtensionPostInstallEvent $event): void
        {
        }

        /**
         * Listener for the `ExtensionPostCacheRebuildEvent`.
         *
         * Occurs when an extension has been successfully installed
         * and then the cache has been reloaded after a second request.
         */
        public function extensionPostInstalled(ExtensionPostCacheRebuildEvent $event): void
        {
            «IF amountOfExampleRows > 0»
                $extension = $event->getExtensionBundle();
                if (null === $extension) {
                    return;
                }

                if ('«appName»' === $extension->getName()) {
                    $this->exampleDataHelper->createDefaultData();
                }
            «ENDIF»
        }

        /**
         * Listener for the `ExtensionPostUpgradeEvent`.
         *
         * Occurs when an extension has been upgraded to a newer version.
         */
        public function extensionUpgraded(ExtensionPostUpgradeEvent $event): void
        {
        }

        /**
         * Listener for the `ExtensionPostEnabledEvent`.
         *
         * Occurs when an extension has been enabled after it was previously disabled.
         */
        public function extensionEnabled(ExtensionPostEnabledEvent $event): void
        {
        }

        /**
         * Listener for the `ExtensionPostDisabledEvent`.
         *
         * Occurs when an extension has been disabled.
         */
        public function extensionDisabled(ExtensionPostDisabledEvent $event): void
        {
        }

        /**
         * Listener for the `ExtensionPostRemoveEvent`.
         *
         * Occurs when an extension has been removed entirely.
         */
        public function extensionRemoved(ExtensionPostRemoveEvent $event): void
        {
        }
    '''
}
