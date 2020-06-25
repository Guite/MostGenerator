package org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ConnectionsMenuListener {

    extension FormattingExtensions = new FormattingExtensions
    extension Utils = new Utils

    CommonExample commonExample = new CommonExample()

    def generate(Application it) '''
        /**
         * @var TranslatorInterface
         */
        protected $translator;

        /**
         * @var PermissionApiInterface
         */
        protected $permissionApi;

        public function __construct(
            TranslatorInterface $translator,
            PermissionApiInterface $permissionApi
        ) {
            $this->translator = $translator;
            $this->permissionApi = $permissionApi;
        }

        public static function getSubscribedEvents()
        {
            return [
                ConnectionsMenuEvent::class => ['addMenuItem', 5]
            ];
        }

        /**
         * Listener for the `ConnectionsMenuEvent`.
         *
         * Occurs when building admin menu items.
         * Listener can be used provide menu items to other extensions.
         * Adds sublinks to a 'Connections' menu that is appended to all extensions if populated.
         *
         * You can add data like this:
         *
         *     `if (!$this->permissionApi->hasPermission($event->getExtensionName() . '::', '::', ACCESS_ADMIN)) {
         *          return;
         *      }
         *
         *      if ('ZikulaUsersModule' === $event->getExtensionName()) {
         *          // only add to menu for the Users module
         *          $event->addChild($this->translator->trans('«vendorAndName.formatForDisplayCapital»'), [
         *              'route' => '«appName.formatForDB»_user_index',
         *              'routeParameters' => ['moduleName' => $event->getExtensionName()]
         *          ]);
         *      }`
         */
        public function addMenuItem(ConnectionsMenuEvent $event): void
        {
        }
    '''

    def generateLegacy(Application it) '''
        public static function getSubscribedEvents()
        {
            return [
                'module_dispatch.service_links' => ['serviceLinks', 5]
            ];
        }

        /**
         * Listener for the `module_dispatch.service_links` event.
         *
         * Occurs when building admin menu items.
         * Adds sublinks to a Services menu that is appended to all modules if populated.
         * Triggered by module_dispatch.postexecute in bootstrap.
         *
         * Inject router and translator services and format data like this:
         *     `$event->data[] = [
         *         'url' => $router->generate('«appName.formatForDB»_user_index'),
         *         'text' => $translator->«IF targets('3.0')»trans«ELSE»__«ENDIF»('Link text')
         *     ];`
         *
         «commonExample.generalEventProperties(it, false)»
         */
        public function serviceLinks(GenericEvent $event)«IF targets('3.0')»: void«ENDIF»
        {
        }
    '''
}
