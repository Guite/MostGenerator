package org.zikula.modulestudio.generator.cartridges.zclassic.controller

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.ItemActions
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
        use Symfony\Component\EventDispatcher\EventDispatcherInterface;
        «IF targets('3.0')»
            use Symfony\Component\EventDispatcher\LegacyEventDispatcherProxy;
        «ENDIF»
        use Symfony\Component\HttpFoundation\RequestStack;
        use Zikula\Common\Translator\TranslatorInterface;
        use Zikula\Common\Translator\TranslatorTrait;
        «IF hasEditActions || !relations.empty»
            use Zikula\UsersModule\Constant as UsersConstant;
        «ENDIF»
        «FOR entity : getAllEntities»
            use «appNamespace»\Entity\«entity.name.formatForCodeCapital»Entity;
        «ENDFOR»
        use «appNamespace»\«name.formatForCodeCapital»Events;
        use «appNamespace»\Event\ConfigureItemActionsMenuEvent;
        «IF hasDisplayActions»
            use «appNamespace»\Helper\EntityDisplayHelper;
        «ENDIF»
        «IF hasLoggable»
            use «appNamespace»\Helper\LoggableHelper;
        «ENDIF»
        use «appNamespace»\Helper\PermissionHelper;
        use Zikula\UsersModule\Api\ApiInterface\CurrentUserApiInterface;

        /**
         * Menu builder base class.
         */
        class AbstractMenuBuilder
        {
            use TranslatorTrait;

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

            public function __construct(
                TranslatorInterface $translator,
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
                CurrentUserApiInterface $currentUserApi
            ) {
                $this->setTranslator($translator);
                $this->factory = $factory;
                «IF targets('3.0')»
                    $this->eventDispatcher = LegacyEventDispatcherProxy::decorate($eventDispatcher);
                «ELSE»
                    $this->eventDispatcher = $eventDispatcher;
                «ENDIF»
                $this->requestStack = $requestStack;
                $this->permissionHelper = $permissionHelper;
                «IF hasDisplayActions»
                    $this->entityDisplayHelper = $entityDisplayHelper;
                «ENDIF»
                «IF hasLoggable»
                    $this->loggableHelper = $loggableHelper;
                «ENDIF»
                $this->currentUserApi = $currentUserApi;
            }

            «setTranslatorMethod»

            /**
             * Builds the item actions menu.
             «IF !targets('3.0')»
             *
             * @param array $options List of additional options
             *
             * @return ItemInterface The assembled menu
             «ENDIF»
             */
            public function createItemActionsMenu(array $options = [])«IF targets('3.0')»: ItemInterface«ENDIF»
            {
                $menu = $this->factory->createItem('itemActions');
                if (!isset($options['entity'], $options['area'], $options['context'])) {
                    return $menu;
                }

                $entity = $options['entity'];
                $routeArea = $options['area'];
                $context = $options['context'];
                «IF hasLoggable»

                    // return empty menu for preview of deleted items
                    $routeName = $this->requestStack->getMasterRequest()->get('_route');
                    if (false !== stripos($routeName, 'displaydeleted')) {
                        return $menu;
                    }
                «ENDIF»
                $menu->setChildrenAttribute('class', 'list-inline item-actions');

                «IF targets('3.0')»
                    $this->eventDispatcher->dispatch(
                        new ConfigureItemActionsMenuEvent($this->factory, $menu, $options),
                        «name.formatForCodeCapital»Events::MENU_ITEMACTIONS_PRE_CONFIGURE
                    );
                «ELSE»
                    $this->eventDispatcher->dispatch(
                        «name.formatForCodeCapital»Events::MENU_ITEMACTIONS_PRE_CONFIGURE,
                        new ConfigureItemActionsMenuEvent($this->factory, $menu, $options)
                    );
                «ENDIF»

                «new ItemActions().itemActionsImpl(it)»

                «IF targets('3.0')»
                    $this->eventDispatcher->dispatch(
                        new ConfigureItemActionsMenuEvent($this->factory, $menu, $options),
                        «name.formatForCodeCapital»Events::MENU_ITEMACTIONS_POST_CONFIGURE
                    );
                «ELSE»
                    $this->eventDispatcher->dispatch(
                        «name.formatForCodeCapital»Events::MENU_ITEMACTIONS_POST_CONFIGURE,
                        new ConfigureItemActionsMenuEvent($this->factory, $menu, $options)
                    );
                «ENDIF»

                return $menu;
            }
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
