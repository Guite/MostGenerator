package org.zikula.modulestudio.generator.cartridges.zclassic.controller

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class LinkContainer {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelExtensions = new ModelExtensions
    extension Utils = new Utils

    def generate(Application it, IMostFileSystemAccess fsa) {
        'Generating link container class'.printIfNotTesting(fsa)
        fsa.generateClassPair('Container/LinkContainer.php', linkContainerBaseImpl, linkContainerImpl)
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
        use «appNamespace»\Helper\ControllerHelper;
        use «appNamespace»\Helper\PermissionHelper;

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
             * @var PermissionHelper
             */
            protected $permissionHelper;

            /**
             * LinkContainer constructor.
             *
             * @param TranslatorInterface  $translator       Translator service instance
             * @param Routerinterface      $router           Router service instance
             «IF generateAccountApi»
             * @param VariableApiInterface $variableApi      VariableApi service instance
             «ENDIF»
             * @param ControllerHelper     $controllerHelper ControllerHelper service instance
             * @param PermissionHelper     $permissionHelper PermissionHelper service instance
             */
            public function __construct(
                TranslatorInterface $translator,
                RouterInterface $router,
                «IF generateAccountApi»
                    VariableApiInterface $variableApi,
                «ENDIF»
                ControllerHelper $controllerHelper,
                PermissionHelper $permissionHelper
            ) {
                $this->setTranslator($translator);
                $this->router = $router;
                «IF generateAccountApi»
                    $this->variableApi = $variableApi;
                «ENDIF»
                $this->controllerHelper = $controllerHelper;
                $this->permissionHelper = $permissionHelper;
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
                        if (!$this->permissionHelper->hasPermission(ACCESS_OVERVIEW)) {
                            return $links;
                        }

                        «FOR entity : getAllEntities.filter[hasViewAction && standardFields]»
                            if (true === $this->variableApi->get('«appName»', 'linkOwn«entity.nameMultiple.formatForCodeCapital»OnAccountPage', true)) {
                                $objectType = '«entity.name.formatForCode»';
                                if ($this->permissionHelper->hasComponentPermission($objectType, ACCESS_READ)) {
                                    $routeArgs = ['own' => 1];
                                    «IF entity.ownerPermission»
                                        $showOnlyOwnEntries = (bool)$this->variableApi->get('«appName»', '«entity.name.formatForCode»PrivateMode', false);
                                        if (true == $showOnlyOwnEntries) {
                                            $routeArgs = [];
                                        }
                                    «ENDIF»
                                    $links[] = [
                                        'url' => $this->router->generate('«appName.formatForDB»_' . strtolower($objectType) . '_view', $routeArgs),
                                        'text' => $this->__('My «entity.nameMultiple.formatForDisplay»'«IF !isSystemModule», '«appName.formatForDB»'«ENDIF»),
                                        'icon' => 'list-alt'
                                    ];
                                }
                            }

                        «ENDFOR»
                        if ($this->permissionHelper->hasPermission(ACCESS_ADMIN)) {
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
