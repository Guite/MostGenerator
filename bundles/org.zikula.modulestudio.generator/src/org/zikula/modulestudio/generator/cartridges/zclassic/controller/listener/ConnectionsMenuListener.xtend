package org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ConnectionsMenuListener {

    extension FormattingExtensions = new FormattingExtensions
    extension Utils = new Utils

    def generate(Application it) '''
        public function __construct(
            protected TranslatorInterface $translator,
            protected PermissionApiInterface $permissionApi
        ) {
        }

        public static function getSubscribedEvents()
        {
            return [
                ConnectionsMenuEvent::class => ['addMenuItem', 5],
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
}
