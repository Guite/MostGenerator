package org.zikula.modulestudio.generator.cartridges.zclassic.controller

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.ItemActions
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.GeneratorSettingsExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class LinkContainer {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension GeneratorSettingsExtensions = new GeneratorSettingsExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelExtensions = new ModelExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    FileHelper fh = new FileHelper

    def generate(Application it, IFileSystemAccess fsa) {
        println('Generating link container class')
        generateClassPair(fsa, getAppSourceLibPath + 'Container/LinkContainer.php',
            fh.phpFileContent(it, linkContainerBaseImpl), fh.phpFileContent(it, linkContainerImpl)
        )
        println('Generating item actions menu class')
        generateClassPair(fsa, getAppSourceLibPath + 'Menu/ItemActionsMenu.php',
            fh.phpFileContent(it, itemActionsMenuBaseImpl), fh.phpFileContent(it, itemActionsMenuImpl)
        )
    }

    def private linkContainerBaseImpl(Application it) '''
        namespace «appNamespace»\Container\Base;

        use Symfony\Component\Routing\RouterInterface;
        use Zikula\Common\Translator\TranslatorInterface;
        use Zikula\Common\Translator\TranslatorTrait;
        use Zikula\Core\Doctrine\EntityAccess;
        use Zikula\Core\LinkContainer\LinkContainerInterface;
        «IF generateAccountApi»
            use Zikula\ExtensionsModule\Api\VariableApi;
        «ENDIF»
        use Zikula\PermissionsModule\Api\PermissionApi;
        «IF generateAccountApi || hasEditActions»
            use Zikula\UsersModule\Api\CurrentUserApi;
        «ENDIF»
        use «appNamespace»\Helper\ControllerHelper;

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

            «IF generateAccountApi»
                /**
                 * @var VariableApi
                 */
                protected $variableApi;

            «ENDIF»
            «IF generateAccountApi || hasEditActions»
                /**
                 * @var CurrentUserApi
                 */
                private $currentUserApi;

            «ENDIF»
            /**
             * @var ControllerHelper
             */
            protected $controllerHelper;

            /**
             * LinkContainer constructor.
             *
             * @param TranslatorInterface $translator       Translator service instance
             * @param Routerinterface     $router           Router service instance
             * @param PermissionApi       $permissionApi    PermissionApi service instance
             «IF generateAccountApi»
             * @param VariableApi         $variableApi      VariableApi service instance
             «ENDIF»
             «IF generateAccountApi || hasEditActions»
             * @param CurrentUserApi      $currentUserApi   CurrentUserApi service instance
             «ENDIF»
             * @param ControllerHelper    $controllerHelper ControllerHelper service instance
             */
            public function __construct(TranslatorInterface $translator, RouterInterface $router, PermissionApi $permissionApi«IF generateAccountApi», VariableApi $variableApi«ENDIF»«IF generateAccountApi || hasEditActions», CurrentUserApi $currentUserApi«ENDIF», ControllerHelper $controllerHelper)
            {
                $this->setTranslator($translator);
                $this->router = $router;
                $this->permissionApi = $permissionApi;
                «IF generateAccountApi»
                    $this->variableApi = $variableApi;
                «ENDIF»
                «IF generateAccountApi || hasEditActions»
                    $this->currentUserApi = $currentUserApi;
                «ENDIF»
                $this->controllerHelper = $controllerHelper;
            }

            «setTranslatorMethod»

            /**
             * Returns available header links.
             *
             * @param string $type The type to collect links for
             *
             * @return array Array of header links
             */
            public function getLinks($type = LinkContainerInterface::TYPE_ADMIN)
            {
                $contextArgs = ['api' => 'linkContainer', 'action' => 'getLinks'];
                $allowedObjectTypes = $this->controllerHelper->getObjectTypes('api', $contextArgs);
        
                $permLevel = LinkContainerInterface::TYPE_ADMIN == $type ? ACCESS_ADMIN : ACCESS_READ;

                // Create an array of links to return
                $links = [];

                «IF generateAccountApi»
                    if (LinkContainerInterface::TYPE_ACCOUNT == $type) {
                        $useAccountPage = $this->variableApi->get('«appName»', 'useAccountPage', true);
                        if (false === $useAccountPage) {
                            return $links;
                        }

                        if (!$this->permissionApi->hasPermission($this->getBundleName() . '::', '::', ACCESS_OVERVIEW)) {
                            return $links;
                        }

                        «FOR entity : getAllEntities.filter[standardFields && ownerPermission]»
                            $objectType = '«entity.name.formatForCode»';
                            if ($this->permissionApi->hasPermission($this->getBundleName() . ':' . ucfirst($objectType) . ':', '::', ACCESS_READ)) {
                                $links[] = [
                                    'url' => $this->router->generate('«appName.formatForDB»_' . strtolower($objectType) . '_view', ['own' => 1]),
                                    'text' => $this->__('My «entity.nameMultiple.formatForDisplay»'),
                                    'icon' => 'list-alt'
                                ];
                            }
                        «ENDFOR»
                        if ($this->permissionApi->hasPermission($this->getBundleName() . '::', '::', ACCESS_ADMIN)) {
                            $links[] = [
                                'url' => $this->router->generate('«appName.formatForDB»_«getLeadingEntity.name.formatForDB»_admin«getLeadingEntity.getPrimaryAction»'),
                                'text' => $this->__('«name.formatForDisplayCapital» Backend'),
                                'icon' => 'wrench'
                            ];
                        }

                        return $links;
                    }

                «ENDIF»

                $routeArea = LinkContainerInterface::TYPE_ADMIN == $type ? 'admin' : '';
                «val menuLinksHelper = new MenuLinksHelperFunctions»
                «menuLinksHelper.generate(it)»

                return $links;
            }

            /**
             * Returns the name of the providing bundle.
             *
             * @return string The bundle name
             */
            public function getBundleName()
            {
                return '«appName»';
            }
        }
    '''

    def private linkContainerImpl(Application it) '''
        namespace «appNamespace»\Container;

        use «appNamespace»\Container\Base\AbstractLinkContainer;

        /**
         * This is the link container service implementation class.
         */
        class LinkContainer extends AbstractLinkContainer
        {
            // feel free to add own extensions here
        }
    '''

    def private itemActionsMenuBaseImpl(Application it) '''
        namespace «appNamespace»\Menu\Base;

        use Knp\Menu\FactoryInterface;
        use Knp\Menu\MenuItem;
        use Symfony\Component\DependencyInjection\ContainerAwareInterface;
        use Symfony\Component\DependencyInjection\ContainerAwareTrait;
        use Zikula\Common\Translator\TranslatorTrait;
        «FOR entity : getAllEntities»
            use «appNamespace»\Entity\«entity.name.formatForCodeCapital»Entity;
        «ENDFOR»

        /**
         * This is the item actions menu implementation class.
         */
        class AbstractItemActionsMenu implements ContainerAwareInterface
        {
            use ContainerAwareTrait;
            use TranslatorTrait;

            «setTranslatorMethod»

            /**
             * Builds the menu.
             *
             * @param FactoryInterface $factory Menu factory
             * @param array            $options Additional options
             *
             * @return MenuItem The assembled menu
             */
            public function menu(FactoryInterface $factory, array $options)
            {
                $menu = $factory->createItem('itemActions');
                if (!isset($options['entity']) || !isset($options['area']) || !isset($options['context'])) {
                    return $menu;
                }

                $this->setTranslator($this->container->get('translator.default'));

                $entity = $options['entity'];
                $routeArea = $options['area'];
                $context = $options['context'];

                $permissionApi = $this->container->get('zikula_permissions_module.api.permission');
                $currentUserApi = $this->container->get('zikula_users_module.current_user');
                $menu->setChildrenAttribute('class', 'list-inline');

                «new ItemActions().itemActionsImpl(it)»

                return $menu;
            }
        }
    '''

    def private itemActionsMenuImpl(Application it) '''
        namespace «appNamespace»\Menu;

        use «appNamespace»\Menu\Base\AbstractItemActionsMenu;

        /**
         * This is the item actions menu implementation class.
         */
        class ItemActionsMenu extends AbstractItemActionsMenu
        {
            // feel free to add own extensions here
        }
    '''
}
