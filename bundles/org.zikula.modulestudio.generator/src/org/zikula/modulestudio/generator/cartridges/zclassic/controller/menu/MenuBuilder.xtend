package org.zikula.modulestudio.generator.cartridges.zclassic.controller.menu

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.menu.ItemActions
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.menu.ViewActions
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class MenuBuilder {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelExtensions = new ModelExtensions
    extension Utils = new Utils

    def generate(Application it, IMostFileSystemAccess fsa) {
        'Generating menu builder class'.printIfNotTesting(fsa)
        fsa.generateClassPair('Menu/MenuBuilder.php', menuBuilderBaseImpl, menuBuilderImpl)
    }

    def private menuBuilderBaseImpl(Application it) '''
        namespace «appNamespace»\Menu\Base;

        use Knp\Menu\FactoryInterface;
        use Knp\Menu\ItemInterface;
        use Symfony\Contracts\EventDispatcher\EventDispatcherInterface;
        use Symfony\Component\HttpFoundation\RequestStack;
        «IF hasViewActions»
            use Zikula\ExtensionsModule\Api\ApiInterface\VariableApiInterface;
        «ENDIF»
        use Zikula\UsersModule\Api\ApiInterface\CurrentUserApiInterface;
        «IF (!getAllEntities.filter[ownerPermission].empty && (hasEditActions || hasDeleteActions)) || !relations.empty»
            use Zikula\UsersModule\Constant as UsersConstant;
        «ENDIF»
        «FOR entity : getAllEntities»
            use «appNamespace»\Entity\«entity.name.formatForCodeCapital»Entity;
        «ENDFOR»
        use «appNamespace»\Event\ItemActionsMenuPostConfigurationEvent;
        use «appNamespace»\Event\ItemActionsMenuPreConfigurationEvent;
        «IF hasViewActions»
            use «appNamespace»\Event\ViewActionsMenuPostConfigurationEvent;
            use «appNamespace»\Event\ViewActionsMenuPreConfigurationEvent;
        «ENDIF»
        «IF hasDisplayActions»
            use «appNamespace»\Helper\EntityDisplayHelper;
        «ENDIF»
        «IF hasLoggable»
            use «appNamespace»\Helper\LoggableHelper;
        «ENDIF»
        «IF hasViewActions && hasEditActions»
            use «appNamespace»\Helper\ModelHelper;
        «ENDIF»
        use «appNamespace»\Helper\PermissionHelper;

        /**
         * Menu builder base class.
         */
        class AbstractMenuBuilder
        {
            «menuBuilderClassBaseImpl»
        }
    '''

    def private menuBuilderClassBaseImpl(Application it) '''
        /**
         * @var FactoryInterface
         */
        protected $factory;

        /**
         * @var EventDispatcherInterface
         */
        protected $eventDispatcher;

        /**
         * @var RequestStack
         */
        protected $requestStack;

        /**
         * @var PermissionHelper
         */
        protected $permissionHelper;
        «IF hasDisplayActions»

            /**
             * @var EntityDisplayHelper
             */
            protected $entityDisplayHelper;
        «ENDIF»
        «IF hasLoggable»

            /**
             * @var LoggableHelper
             */
            protected $loggableHelper;
        «ENDIF»

        /**
         * @var CurrentUserApiInterface
         */
        protected $currentUserApi;
        «IF hasViewActions»

            /**
             * @var VariableApiInterface
             */
            protected $variableApi;
        «ENDIF»
        «IF hasViewActions && hasEditActions»

            /**
             * @var ModelHelper
             */
            protected $modelHelper;
        «ENDIF»

        public function __construct(
            FactoryInterface $factory,
            EventDispatcherInterface $eventDispatcher,
            RequestStack $requestStack,
            PermissionHelper $permissionHelper,
            «IF hasDisplayActions»
                EntityDisplayHelper $entityDisplayHelper,
            «ENDIF»
            «IF hasLoggable»
                LoggableHelper $loggableHelper,
            «ENDIF»
            CurrentUserApiInterface $currentUserApi«IF hasViewActions»,
            VariableApiInterface $variableApi«ENDIF»«IF hasViewActions && hasEditActions»,
            ModelHelper $modelHelper«ENDIF»
        ) {
            $this->factory = $factory;
            $this->eventDispatcher = $eventDispatcher;
            $this->requestStack = $requestStack;
            $this->permissionHelper = $permissionHelper;
            «IF hasDisplayActions»
                $this->entityDisplayHelper = $entityDisplayHelper;
            «ENDIF»
            «IF hasLoggable»
                $this->loggableHelper = $loggableHelper;
            «ENDIF»
            $this->currentUserApi = $currentUserApi;
            «IF hasViewActions»
                $this->variableApi = $variableApi;
            «ENDIF»
            «IF hasViewActions && hasEditActions»
                $this->modelHelper = $modelHelper;
            «ENDIF»
        }

        «createMenu('item')»
        «IF hasViewActions»

            «createMenu('view')»
        «ENDIF»
    '''

    def private createMenu(Application it, String actionType) '''
        /**
         * Builds the «actionType» actions menu.
         */
        public function create«actionType.toFirstUpper»ActionsMenu(array $options = []): ItemInterface
        {
            $menu = $this->factory->createItem('«actionType»Actions');
            «IF 'item' == actionType»
                if (!isset($options['entity'], $options['area'], $options['context'])) {
                    return $menu;
                }

                $entity = $options['entity'];
                $routeArea = $options['area'];
                $context = $options['context'];
                «IF hasLoggable»

                    if (\is_callable([$this->requestStack, 'getMainRequest'])) {
                        $mainRequest = $this->requestStack->getMainRequest(); // symfony 5.3+
                    } else {
                        $mainRequest = $this->requestStack->getMasterRequest();
                    }
                    // return empty menu for preview of deleted items
                    $routeName = $mainRequest->get('_route');
                    if (false !== mb_stripos($routeName, 'displaydeleted')) {
                        return $menu;
                    }
                «ENDIF»
            «ELSEIF 'view' == actionType»
                if (!isset($options['objectType'], $options['area'])) {
                    return $menu;
                }

                $objectType = $options['objectType'];
                $routeArea = $options['area'];
            «ENDIF»
            $menu->setChildrenAttribute('class', 'nav «actionType»-actions');

            $this->eventDispatcher->dispatch(
                new «actionType.toFirstUpper»ActionsMenuPreConfigurationEvent($this->factory, $menu, $options)
            );

            «IF 'item' == actionType»
                «new ItemActions().actionsImpl(it)»
            «ELSEIF 'view' == actionType»
                «new ViewActions().actionsImpl(it)»
            «ENDIF»

            $this->eventDispatcher->dispatch(
                new «actionType.toFirstUpper»ActionsMenuPostConfigurationEvent($this->factory, $menu, $options)
            );

            return $menu;
        }
    '''

    def private menuBuilderImpl(Application it) '''
        namespace «appNamespace»\Menu;

        use «appNamespace»\Menu\Base\AbstractMenuBuilder;

        /**
         * Menu builder implementation class.
         */
        class MenuBuilder extends AbstractMenuBuilder
        {
            // feel free to add own extensions here
        }
    '''
}
