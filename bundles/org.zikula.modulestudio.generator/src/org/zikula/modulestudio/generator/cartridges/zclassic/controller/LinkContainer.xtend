package org.zikula.modulestudio.generator.cartridges.zclassic.controller

import de.guite.modulestudio.metamodel.AdminController
import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Controller
import de.guite.modulestudio.metamodel.UserController
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.ItemActions
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.GeneratorSettingsExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

// 1.4+ only
class LinkContainer {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension GeneratorSettingsExtensions = new GeneratorSettingsExtensions
    extension ModelExtensions = new ModelExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    FileHelper fh = new FileHelper
    Application app

    def generate(Controller it, IFileSystemAccess fsa) {
        app = application
        println('Generating link container class')
        app.generateClassPair(fsa, app.getAppSourceLibPath + 'Container/LinkContainer.php',
            fh.phpFileContent(app, linkContainerBaseImpl), fh.phpFileContent(app, linkContainerImpl)
        )
        println('Generating item actions menu class')
        app.generateClassPair(fsa, app.getAppSourceLibPath + 'Menu/ItemActionsMenu.php',
            fh.phpFileContent(app, itemActionsMenuBaseImpl), fh.phpFileContent(app, itemActionsMenuImpl)
        )
    }

    // 1.4+ only
    def private linkContainerBaseImpl(Controller it) '''
        namespace «app.appNamespace»\Container\Base;

        use Symfony\Component\Routing\RouterInterface;
        «IF app.generateAccountApi»
            use UserUtil;
        «ENDIF»
        use Zikula\Common\Translator\TranslatorInterface;
        use Zikula\Common\Translator\TranslatorTrait;
        use Zikula\Core\Doctrine\EntityAccess;
        use Zikula\Core\LinkContainer\LinkContainerInterface;
        use Zikula\PermissionsModule\Api\PermissionApi;
        «IF app.generateAccountApi»
            use Zikula\ExtensionsModule\Api\VariableApi;
        «ENDIF»
        «IF app.generateAccountApi || !app.controllers.filter[c|c.hasActions('edit')].empty»
            use Zikula\UsersModule\Api\CurrentUserApi;
        «ENDIF»
        use «app.appNamespace»\Helper\ControllerHelper;

        /**
         * This is the link container service implementation class.
         */
        abstract class AbstractLinkContainer implements LinkContainerInterface
        {
            use TranslatorTrait;

            /**
             * @var RouterInterface
             */
            protected $router;

            /**
             * @var PermissionApi
             */
            protected $permissionApi;

            /**
             * @var ControllerHelper
             */
            protected $controllerHelper;

            «IF app.generateAccountApi»
                /**
                 * @var VariableApi
                 */
                protected $variableApi;

            «ENDIF»
            «IF app.generateAccountApi || !app.controllers.filter[c|c.hasActions('edit')].empty»
                /**
                 * @var CurrentUserApi
                 */
                private $currentUserApi;

            «ENDIF»
            /**
             * Constructor.
             * Initialises member vars.
             *
             * @param TranslatorInterface $translator       Translator service instance
             * @param Routerinterface     $router           Router service instance
             * @param PermissionApi       $permissionApi    PermissionApi service instance
             * @param ControllerHelper    $controllerHelper ControllerHelper service instance
             «IF app.generateAccountApi»
             * @param VariableApi         $variableApi      VariableApi service instance
             «ENDIF»
             «IF app.generateAccountApi || !app.controllers.filter[c|c.hasActions('edit')].empty»
             * @param CurrentUserApi      $currentUserApi   CurrentUserApi service instance
             «ENDIF»
             */
            public function __construct(TranslatorInterface $translator, RouterInterface $router, PermissionApi $permissionApi, ControllerHelper $controllerHelper«IF app.generateAccountApi», VariableApi $variableApi«ENDIF»«IF app.generateAccountApi || !app.controllers.filter[c|c.hasActions('edit')].empty», CurrentUserApi $currentUserApi«ENDIF»)
            {
                $this->setTranslator($translator);
                $this->router = $router;
                $this->permissionApi = $permissionApi;
                $this->controllerHelper = $controllerHelper;
                «IF app.generateAccountApi»
                    $this->variableApi = $variableApi;
                «ENDIF»
                «IF app.generateAccountApi || !app.controllers.filter[c|c.hasActions('edit')].empty»
                    $this->currentUserApi = $currentUserApi;
                «ENDIF»
            }

            /**
             * Sets the translator.
             *
             * @param TranslatorInterface $translator Translator service instance
             */
            public function setTranslator(/*TranslatorInterface */$translator)
            {
                $this->translator = $translator;
            }

            /**
             * Returns available header links.
             *
             * @param string $type The type to collect links for
             *
             * @return array Array of header links
             */
            public function getLinks($type = LinkContainerInterface::TYPE_ADMIN)
            {
                $utilArgs = ['api' => 'linkContainer', 'action' => 'getLinks'];
                $allowedObjectTypes = $this->controllerHelper->getObjectTypes('api', $utilArgs);
        
                $permLevel = LinkContainerInterface::TYPE_ADMIN == $type ? ACCESS_ADMIN : ACCESS_READ;

                // Create an array of links to return
                $links = [];

                «IF app.generateAccountApi»
                    if (LinkContainerInterface::TYPE_ACCOUNT == $type) {
                        $useAccountPage = $this->variableApi->get('«app.appName»', 'useAccountPage', true);
                        if (false === $useAccountPage) {
                            return $links;
                        }

                        $userName = isset($args['uname']) ? $args['uname'] : $this->currentUserApi->get('uname');
                        // does this user exist?
                        if (false === UserUtil::getIdFromName($userName)) {
                            // user does not exist
                            return $links;
                        }

                        if (!$this->permissionApi->hasPermission($this->getBundleName() . '::', '::', ACCESS_OVERVIEW)) {
                            return $links;
                        }

                        «IF !app.getAllUserControllers.empty && app.getMainUserController.hasActions('view')»
                            «FOR entity : app.getAllEntities.filter[standardFields && ownerPermission]»
                                $objectType = '«entity.name.formatForCode»';
                                if ($this->permissionApi->hasPermission($this->getBundleName() . ':' . ucfirst($objectType) . ':', '::', ACCESS_READ)) {
                                    $links[] = [
                                        'url' => $this->router->generate('«app.appName.formatForDB»_' . strtolower($objectType) . '_view', ['own' => 1]),
                                        'text' => $this->__('My «entity.nameMultiple.formatForDisplay»'),
                                        'icon' => 'list-alt'
                                    ];
                                }
                            «ENDFOR»
                        «ENDIF»
                        «IF !app.getAllAdminControllers.empty»
                            if ($this->permissionApi->hasPermission($this->getBundleName() . '::', '::', ACCESS_ADMIN)) {
                                $links[] = [
                                    'url' => $this->router->generate('«app.appName.formatForDB»_admin_index'),
                                    'text' => $this->__('«app.name.formatForDisplayCapital» Backend'),
                                    'icon' => 'wrench'
                                ];
                            }
                        «ENDIF»

                        return $links;
                    }

                «ENDIF»
                «/* TODO legacy, see #715 - remove also temporary addition of user controller in PersistenceTransformer class */»
                «val linkControllers = app.getAdminAndUserControllers»
                «val menuLinksHelper = new MenuLinksHelperFunctions»
                «FOR linkController : linkControllers»
                    if («IF linkController instanceof AdminController»LinkContainerInterface::TYPE_ADMIN«ELSEIF linkController instanceof UserController»LinkContainerInterface::TYPE_USER«ELSE»'«linkController.name.formatForCode»'«ENDIF» == $type) {
                        «menuLinksHelper.generate(linkController)»
                    }
                «ENDFOR»

                return $links;
            }

            /**
             * Returns the name of the providing bundle.
             *
             * @return string The bundle name
             */
            public function getBundleName()
            {
                return '«app.appName»';
            }
        }
    '''

    def private linkContainerImpl(Controller it) '''
        namespace «app.appNamespace»\Container;

        use «app.appNamespace»\Container\Base\AbstractLinkContainer;

        /**
         * This is the link container service implementation class.
         */
        class LinkContainer extends AbstractLinkContainer
        {
            // feel free to add own extensions here
        }
    '''

    def private itemActionsMenuBaseImpl(Controller it) '''
        namespace «app.appNamespace»\Menu\Base;

        use Knp\Menu\FactoryInterface;
        use Symfony\Component\DependencyInjection\ContainerAwareInterface;
        use Symfony\Component\DependencyInjection\ContainerAwareTrait;
        use Zikula\Common\Translator\TranslatorTrait;
        «FOR entity : app.entities»
            use «app.appNamespace»\Entity\«entity.name.formatForCodeCapital»Entity;
        «ENDFOR»

        /**
         * This is the item actions menu implementation class.
         */
        class AbstractItemActionsMenu implements ContainerAwareInterface
        {
            use ContainerAwareTrait;
            use TranslatorTrait;

            /**
             * Sets the translator.
             *
             * @param TranslatorInterface $translator Translator service instance
             */
            public function setTranslator(/*TranslatorInterface */$translator)
            {
                $this->translator = $translator;
            }

            /**
             * Builds the menu.
             *
             * @param FactoryInterface $factory Menu factory
             * @param array            $options Additional options
             *
             * @return \Knp\Menu\MenuItem The assembled menu
             */
            public function menu(FactoryInterface $factory, array $options)
            {
                $menu = $factory->createItem('itemActions');
                if (!isset($options['entity']) || !isset($options['area']) || !isset($options['context'])) {
                    return $menu;
                }

                $this->setTranslator($this->container->get('translator'));

                $entity = $options['entity'];
                $area = $options['area'];
                $context = $options['context'];

                $permissionApi = $this->container->get('zikula_permissions_module.api.permission');
                $currentUserApi = $this->container->get('zikula_users_module.current_user');
                $menu->setChildrenAttribute('class', 'list-inline');

                «new ItemActions().itemActionsImpl(app)»

                return $menu;
            }
        }
    '''

    def private itemActionsMenuImpl(Controller it) '''
        namespace «app.appNamespace»\Menu;

        use «app.appNamespace»\Menu\Base\AbstractItemActionsMenu;

        /**
         * This is the item actions menu implementation class.
         */
        class ItemActionsMenu extends AbstractItemActionsMenu
        {
            // feel free to add own extensions here
        }
    '''
}
