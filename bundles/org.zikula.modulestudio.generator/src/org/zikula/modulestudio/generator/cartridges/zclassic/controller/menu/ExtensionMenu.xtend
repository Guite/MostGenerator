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
            /**
             * @var FactoryInterface
             */
            protected $factory;

            «IF generateAccountApi»
                /**
                 * @var VariableApiInterface
                 */
                protected $variableApi;

                /**
                 * @var CurrentUserApiInterface
                 */
                protected $currentUserApi;

            «ENDIF»
            /**
             * @var ControllerHelper
             */
            protected $controllerHelper;

            /**
             * @var PermissionHelper
             */
            protected $permissionHelper;

            public function __construct(
                FactoryInterface $factory,
                «IF generateAccountApi»
                    VariableApiInterface $variableApi,
                    CurrentUserApiInterface $currentUserApi,
                «ENDIF»
                ControllerHelper $controllerHelper,
                PermissionHelper $permissionHelper
            ) {
                $this->factory = $factory;
                «IF generateAccountApi»
                    $this->variableApi = $variableApi;
                    $this->currentUserApi = $currentUserApi;
                «ENDIF»
                $this->controllerHelper = $controllerHelper;
                $this->permissionHelper = $permissionHelper;
            }

            public function get(string $type = self::TYPE_ADMIN): ?ItemInterface
            {
                «IF !isSystemModule»
                    $contextArgs = ['api' => 'extensionMenu', 'action' => 'get'];
                «ENDIF»
                $allowedObjectTypes = $this->controllerHelper->getObjectTypes('api'«IF !isSystemModule», $contextArgs«ENDIF»);
        
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
                                        «IF !isSystemModule»
                                            ->setExtra('translation_domain', '«entity.name.formatForCode»')
                                        «ENDIF»
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
