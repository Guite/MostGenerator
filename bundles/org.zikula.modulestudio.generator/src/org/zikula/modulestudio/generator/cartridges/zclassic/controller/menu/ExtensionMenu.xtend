package org.zikula.modulestudio.generator.cartridges.zclassic.controller.menu

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ExtensionMenu {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension Utils = new Utils

    def generate(Application it, IMostFileSystemAccess fsa) {
        'Generating extension menu class'.printIfNotTesting(fsa)
        fsa.generateClassPair('Menu/ExtensionMenu.php', extensionMenuBaseImpl, extensionMenuImpl)
    }

    def private extensionMenuBaseImpl(Application it) '''
        namespace «appNamespace»\Menu\Base;

        use Knp\Menu\FactoryInterface;
        use Knp\Menu\ItemInterface;
        «IF generateAccountApi»
            use Zikula\ExtensionsModule\Api\ApiInterface\VariableApiInterface;
        «ENDIF»
        use Zikula\MenuModule\ExtensionMenu\ExtensionMenuInterface;
        «IF generateAccountApi»
            use Zikula\UsersModule\Api\ApiInterface\CurrentUserApiInterface;
        «ENDIF»
        use «appNamespace»\Helper\ControllerHelper;
        use «appNamespace»\Helper\PermissionHelper;

        /**
         * This is the extension menu service base class.
         */
        abstract class AbstractExtensionMenu implements ExtensionMenuInterface
        {
            public function __construct(
                protected FactoryInterface $factory,
                «IF generateAccountApi»
                    protected VariableApiInterface $variableApi,
                    protected CurrentUserApiInterface $currentUserApi,
                «ENDIF»
                protected ControllerHelper $controllerHelper,
                protected PermissionHelper $permissionHelper
            ) {
            }

            public function get(string $type = self::TYPE_ADMIN): ?ItemInterface
            {
                $contextArgs = ['api' => 'extensionMenu', 'action' => 'get'];
                $allowedObjectTypes = $this->controllerHelper->getObjectTypes('api', $contextArgs);
        
                $permLevel = self::TYPE_ADMIN === $type ? ACCESS_ADMIN : ACCESS_READ;

                $menu = $this->factory->createItem('«appName.formatForDB»' . ucfirst($type) . 'Menu');

                if (self::TYPE_ACCOUNT === $type) {
                    «IF generateAccountApi»
                        if (!$this->currentUserApi->isLoggedIn()) {
                            return null;
                        }
                        if (!$this->permissionHelper->hasPermission(ACCESS_OVERVIEW)) {
                            return null;
                        }

                        «FOR entity : getAllEntities.filter[hasViewAction && standardFields]»
                            if (true === $this->variableApi->get('«appName»', 'linkOwn«entity.nameMultiple.formatForCodeCapital»OnAccountPage', true)) {
                                $objectType = '«entity.name.formatForCode»';
                                if ($this->permissionHelper->hasComponentPermission($objectType, ACCESS_READ)) {
                                    $routeParameters = ['own' => 1];
                                    «IF entity.ownerPermission»
                                        $showOnlyOwnEntries = (bool) $this->variableApi->get('«appName»', '«entity.name.formatForCode»PrivateMode');
                                        if (true === $showOnlyOwnEntries) {
                                            $routeParameters = [];
                                        }
                                    «ENDIF»
                                    $menu->addChild('My «entity.nameMultiple.formatForDisplay»', [
                                        'route' => '«appName.formatForDB»_' . mb_strtolower($objectType) . '_view',
                                        'routeParameters' => $routeParameters,
                                    ])
                                        ->setAttribute('icon', 'fas fa-list-alt')
                                        ->setExtra('translation_domain', '«entity.name.formatForCode»')
                                    ;
                                }
                            }

                        «ENDFOR»
                        if ($this->permissionHelper->hasPermission(ACCESS_ADMIN)) {
                            $menu->addChild('«name.formatForDisplayCapital» Backend', [
                                'route' => '«appName.formatForDB»_«getLeadingEntity.name.formatForDB»_admin«getLeadingEntity.getPrimaryAction»',
                            ])
                                ->setAttribute('icon', 'fas fa-wrench')
                            ;
                        }

                    «ENDIF»
                    return 0 === $menu->count() ? null : $menu;
                }

                $routeArea = self::TYPE_ADMIN === $type ? 'admin' : '';
                «val menuLinksHelper = new MenuLinksHelperFunctions»
                «menuLinksHelper.generate(it)»

                return 0 === $menu->count() ? null : $menu;
            }

            public function getBundleName(): string
            {
                return '«appName»';
            }
        }
    '''

    def private extensionMenuImpl(Application it) '''
        namespace «appNamespace»\Menu;

        use «appNamespace»\Menu\Base\AbstractExtensionMenu;

        /**
         * This is the extension menu service implementation class.
         */
        class ExtensionMenu extends AbstractExtensionMenu
        {
            // feel free to add own extensions here
        }
    '''
}
