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
                «IF targets('3.0')»ExtensionEvents«ELSE»CoreEvents«ENDIF»::«IF targets('3.0')»EXTENSION«ELSE»MODULE«ENDIF»_INSTALL     => ['«IF targets('3.0')»extension«ELSE»module«ENDIF»Installed', 5],
                «IF targets('3.0')»ExtensionEvents«ELSE»CoreEvents«ENDIF»::«IF targets('3.0')»EXTENSION«ELSE»MODULE«ENDIF»_POSTINSTALL => ['«IF targets('3.0')»extension«ELSE»module«ENDIF»PostInstalled', 5],
                «IF targets('3.0')»ExtensionEvents«ELSE»CoreEvents«ENDIF»::«IF targets('3.0')»EXTENSION«ELSE»MODULE«ENDIF»_UPGRADE     => ['«IF targets('3.0')»extension«ELSE»module«ENDIF»Upgraded', 5],
                «IF targets('3.0')»ExtensionEvents«ELSE»CoreEvents«ENDIF»::«IF targets('3.0')»EXTENSION«ELSE»MODULE«ENDIF»_ENABLE      => ['«IF targets('3.0')»extension«ELSE»module«ENDIF»Enabled', 5],
                «IF targets('3.0')»ExtensionEvents«ELSE»CoreEvents«ENDIF»::«IF targets('3.0')»EXTENSION«ELSE»MODULE«ENDIF»_DISABLE     => ['«IF targets('3.0')»extension«ELSE»module«ENDIF»Disabled', 5],
                «IF targets('3.0')»ExtensionEvents«ELSE»CoreEvents«ENDIF»::«IF targets('3.0')»EXTENSION«ELSE»MODULE«ENDIF»_REMOVE      => ['«IF targets('3.0')»extension«ELSE»module«ENDIF»Removed', 5]
            ];
        }

        /**
         * Listener for the `«IF targets('3.0')»extension«ELSE»module«ENDIF».install` event.
         *
         * Called after a«IF targets('3.0')»n extension«ELSE» module«ENDIF» has been successfully installed.
         * The event allows accessing the «IF targets('3.0')»extension«ELSE»module«ENDIF» bundle and the extension
         * information array using `$event->get«IF targets('3.0')»Extension«ELSE»Module«ENDIF»()` and `$event->get«IF targets('3.0')»Info«ELSE»ModInfo«ENDIF»()`.
         *
         «commonExample.generalEventProperties(it, false)»
         */
        public function «IF targets('3.0')»extension«ELSE»module«ENDIF»Installed(«IF targets('3.0')»Extension«ELSE»Module«ENDIF»StateEvent $event)«IF targets('3.0')»: void«ENDIF»
        {
        }

        /**
         * Listener for the `«IF targets('3.0')»extension«ELSE»module«ENDIF».postinstall` event.
         *
         * Called after a«IF targets('3.0')»n extension«ELSE» module«ENDIF» has been installed (on reload of the extensions view).
         * The event allows accessing the «IF targets('3.0')»extension«ELSE»module«ENDIF» bundle and the extension
         * information array using `$event->get«IF targets('3.0')»Extension«ELSE»Module«ENDIF»()` and `$event->get«IF targets('3.0')»Info«ELSE»ModInfo«ENDIF»()`.
         *
         «commonExample.generalEventProperties(it, false)»
         */
        public function «IF targets('3.0')»extension«ELSE»module«ENDIF»PostInstalled(«IF targets('3.0')»Extension«ELSE»Module«ENDIF»StateEvent $event)«IF targets('3.0')»: void«ENDIF»
        {
            «IF amountOfExampleRows > 0»
                $«IF targets('3.0')»extension«ELSE»module«ENDIF» = $event->get«IF targets('3.0')»Extension«ELSE»Module«ENDIF»();
                if (null === $«IF targets('3.0')»extension«ELSE»module«ENDIF») {
                    return;
                }

                if ('«appName»' === $«IF targets('3.0')»extension«ELSE»module«ENDIF»->getName()) {
                    $this->exampleDataHelper->createDefaultData();
                }
            «ENDIF»
        }

        /**
         * Listener for the `«IF targets('3.0')»extension«ELSE»module«ENDIF».upgrade` event.
         *
         * Called after a«IF targets('3.0')»n extension«ELSE» module«ENDIF» has been successfully upgraded.
         * The event allows accessing the «IF targets('3.0')»extension«ELSE»module«ENDIF» bundle and the extension
         * information array using `$event->get«IF targets('3.0')»Extension«ELSE»Module«ENDIF»()` and `$event->get«IF targets('3.0')»Info«ELSE»ModInfo«ENDIF»()`.
         *
         «commonExample.generalEventProperties(it, false)»
         */
        public function «IF targets('3.0')»extension«ELSE»module«ENDIF»Upgraded(«IF targets('3.0')»Extension«ELSE»Module«ENDIF»StateEvent $event)«IF targets('3.0')»: void«ENDIF»
        {
        }

        /**
         * Listener for the `«IF targets('3.0')»extension«ELSE»module«ENDIF».enable` event.
         *
         * Called after a«IF targets('3.0')»n extension«ELSE» module«ENDIF» has been successfully enabled.
         * The event allows accessing the «IF targets('3.0')»extension«ELSE»module«ENDIF» bundle and the extension
         * information array using `$event->get«IF targets('3.0')»Extension«ELSE»Module«ENDIF»()` and `$event->get«IF targets('3.0')»Info«ELSE»ModInfo«ENDIF»()`.
         *
         «commonExample.generalEventProperties(it, false)»
         */
        public function «IF targets('3.0')»extension«ELSE»module«ENDIF»Enabled(«IF targets('3.0')»Extension«ELSE»Module«ENDIF»StateEvent $event)«IF targets('3.0')»: void«ENDIF»
        {
        }

        /**
         * Listener for the `«IF targets('3.0')»extension«ELSE»module«ENDIF».disable` event.
         *
         * Called after a«IF targets('3.0')»n extension«ELSE» module«ENDIF» has been successfully disabled.
         * The event allows accessing the module bundle and the extension
         * information array using `$event->get«IF targets('3.0')»Extension«ELSE»Module«ENDIF»()` and `$event->get«IF targets('3.0')»Info«ELSE»ModInfo«ENDIF»()`.
         *
         «commonExample.generalEventProperties(it, false)»
         */
        public function «IF targets('3.0')»extension«ELSE»module«ENDIF»Disabled(«IF targets('3.0')»Extension«ELSE»Module«ENDIF»StateEvent $event)«IF targets('3.0')»: void«ENDIF»
        {
        }

        /**
         * Listener for the `«IF targets('3.0')»extension«ELSE»module«ENDIF».remove` event.
         *
         * Called after a«IF targets('3.0')»n extension«ELSE» module«ENDIF» has been successfully removed.
         * The event allows accessing the module bundle and the extension
         * information array using `$event->get«IF targets('3.0')»Extension«ELSE»Module«ENDIF»()` and `$event->get«IF targets('3.0')»Info«ELSE»ModInfo«ENDIF»()`.
         *
         «commonExample.generalEventProperties(it, false)»
         */
        public function «IF targets('3.0')»extension«ELSE»module«ENDIF»Removed(«IF targets('3.0')»Extension«ELSE»Module«ENDIF»StateEvent $event)«IF targets('3.0')»: void«ENDIF»
        {
            «IF hasUiHooksProviders»
                $«IF targets('3.0')»extension«ELSE»module«ENDIF» = $event->get«IF targets('3.0')»Extension«ELSE»Module«ENDIF»();
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
