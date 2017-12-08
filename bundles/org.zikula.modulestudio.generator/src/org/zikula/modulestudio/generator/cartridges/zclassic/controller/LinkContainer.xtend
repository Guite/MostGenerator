package org.zikula.modulestudio.generator.cartridges.zclassic.controller

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class LinkContainer {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelExtensions = new ModelExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    FileHelper fh = new FileHelper

    def generate(Application it, IFileSystemAccess fsa) {
        'Generating link container class'.printIfNotTesting(fsa)
        generateClassPair(fsa, 'Container/LinkContainer.php',
            fh.phpFileContent(it, linkContainerBaseImpl), fh.phpFileContent(it, linkContainerImpl)
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
            use Zikula\ExtensionsModule\Api\ApiInterface\VariableApiInterface;
        «ENDIF»
        use Zikula\PermissionsModule\Api\ApiInterface\PermissionApiInterface;
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
             * @var PermissionApiInterface
             */
            protected $permissionApi;

            «IF generateAccountApi»
                /**
                 * @var VariableApiInterface
                 */
                protected $variableApi;

            «ENDIF»
            /**
             * @var ControllerHelper
             */
            protected $controllerHelper;

            /**
             * LinkContainer constructor.
             *
             * @param TranslatorInterface    $translator       Translator service instance
             * @param Routerinterface        $router           Router service instance
             * @param PermissionApiInterface $permissionApi    PermissionApi service instance
             «IF generateAccountApi»
             * @param VariableApiInterface   $variableApi      VariableApi service instance
             «ENDIF»
             * @param ControllerHelper       $controllerHelper ControllerHelper service instance
             */
            public function __construct(
                TranslatorInterface $translator,
                RouterInterface $router,
                PermissionApiInterface $permissionApi,
                «IF generateAccountApi»
                    VariableApiInterface $variableApi,
                «ENDIF»
                ControllerHelper $controllerHelper
            ) {
                $this->setTranslator($translator);
                $this->router = $router;
                $this->permissionApi = $permissionApi;
                «IF generateAccountApi»
                    $this->variableApi = $variableApi;
                «ENDIF»
                $this->controllerHelper = $controllerHelper;
            }

            «setTranslatorMethod»

            /**
             * Returns available header links.
             *
             * @param string $type The type to collect links for
             *
             * @return array List of header links
             */
            public function getLinks($type = LinkContainerInterface::TYPE_ADMIN)
            {
                $contextArgs = ['api' => 'linkContainer', 'action' => 'getLinks'];
                $allowedObjectTypes = $this->controllerHelper->getObjectTypes('api', $contextArgs);
        
                $permLevel = LinkContainerInterface::TYPE_ADMIN == $type ? ACCESS_ADMIN : ACCESS_READ;

                // Create an array of links to return
                $links = [];

                if (LinkContainerInterface::TYPE_ACCOUNT == $type) {
                    «IF generateAccountApi»
                        if (!$this->permissionApi->hasPermission($this->getBundleName() . '::', '::', ACCESS_OVERVIEW)) {
                            return $links;
                        }

                        «FOR entity : getAllEntities.filter[hasViewAction && standardFields]»
                            if (true === $this->variableApi->get('«appName»', 'linkOwn«entity.nameMultiple.formatForCodeCapital»OnAccountPage', true)) {
                                $objectType = '«entity.name.formatForCode»';
                                if ($this->permissionApi->hasPermission($this->getBundleName() . ':' . ucfirst($objectType) . ':', '::', ACCESS_READ)) {
                                    $links[] = [
                                        'url' => $this->router->generate('«appName.formatForDB»_' . strtolower($objectType) . '_view', ['own' => 1]),
                                        'text' => $this->__('My «entity.nameMultiple.formatForDisplay»'«IF !isSystemModule», '«appName.formatForDB»'«ENDIF»),
                                        'icon' => 'list-alt'
                                    ];
                                }
                            }

                        «ENDFOR»
                        if ($this->permissionApi->hasPermission($this->getBundleName() . '::', '::', ACCESS_ADMIN)) {
                            $links[] = [
                                'url' => $this->router->generate('«appName.formatForDB»_«getLeadingEntity.name.formatForDB»_admin«getLeadingEntity.getPrimaryAction»'),
                                'text' => $this->__('«name.formatForDisplayCapital» Backend'«IF !isSystemModule», '«appName.formatForDB»'«ENDIF»),
                                'icon' => 'wrench'
                            ];
                        }

                    «ENDIF»

                    return $links;
                }

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
}
