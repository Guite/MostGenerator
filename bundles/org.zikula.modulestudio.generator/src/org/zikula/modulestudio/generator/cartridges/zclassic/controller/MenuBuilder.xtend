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
        use Symfony\Component\HttpFoundation\RequestStack;
        use Zikula\Common\Translator\TranslatorInterface;
        use Zikula\Common\Translator\TranslatorTrait;
        «IF hasEditActions || !relations.empty»
            use Zikula\UsersModule\Constant as UsersConstant;
        «ENDIF»
        «FOR entity : getAllEntities»
            use «appNamespace»\Entity\«entity.name.formatForCodeCapital»Entity;
        «ENDFOR»
        «IF hasLoggable»
            use «appNamespace»\Entity\Factory\EntityFactory;
        «ENDIF»
        «IF hasDisplayActions»
            use «appNamespace»\Helper\EntityDisplayHelper;
        «ENDIF»
        use «appNamespace»\Helper\PermissionHelper;
        use Zikula\UsersModule\Api\ApiInterface\CurrentUserApiInterface;

        /**
         * This is the menu builder implementation class.
         */
        class AbstractMenuBuilder
        {
            use TranslatorTrait;

            /**
             * @var FactoryInterface
             */
            protected $factory;

            /**
             * @var RequestStack
             */
            protected $requestStack;
            «IF hasLoggable»

                /**
                 * @var EntityFactory
                 */
                protected $entityFactory;
            «ENDIF»

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

            /**
             * @var CurrentUserApiInterface
             */
            protected $currentUserApi;

            /**
             * MenuBuilder constructor.
             *
             * @param TranslatorInterface     $translator          Translator service instance
             * @param FactoryInterface        $factory             Factory service instance
             * @param RequestStack            $requestStack        RequestStack service instance
             «IF hasLoggable»
             * @param EntityFactory           $entityFactory       EntityFactory service instance
             «ENDIF»
             * @param PermissionHelper        $permissionHelper    PermissionHelper service instance
             «IF hasDisplayActions»
             * @param EntityDisplayHelper     $entityDisplayHelper EntityDisplayHelper service instance
             «ENDIF»
             * @param CurrentUserApiInterface $currentUserApi      CurrentUserApi service instance
             */
            public function __construct(
                TranslatorInterface $translator,
                FactoryInterface $factory,
                RequestStack $requestStack,
                «IF hasLoggable»
                    EntityFactory $entityFactory,
                «ENDIF»
                PermissionHelper $permissionHelper,
                «IF hasDisplayActions»
                    EntityDisplayHelper $entityDisplayHelper,
                «ENDIF»
                CurrentUserApiInterface $currentUserApi)
            {
                $this->setTranslator($translator);
                $this->factory = $factory;
                $this->requestStack = $requestStack;
                «IF hasLoggable»
                    $this->entityFactory = $entityFactory;
                «ENDIF»
                $this->permissionHelper = $permissionHelper;
                «IF hasDisplayActions»
                    $this->entityDisplayHelper = $entityDisplayHelper;
                «ENDIF»
                $this->currentUserApi = $currentUserApi;
            }

            «setTranslatorMethod»

            /**
             * Builds the item actions menu.
             *
             * @param array $options List of additional options
             *
             * @return ItemInterface The assembled menu
             */
            public function createItemActionsMenu(array $options = [])
            {
                $menu = $this->factory->createItem('itemActions');
                if (!isset($options['entity']) || !isset($options['area']) || !isset($options['context'])) {
                    return $menu;
                }

                $entity = $options['entity'];
                $routeArea = $options['area'];
                $context = $options['context'];
                «IF hasLoggable»

                    // return empty menu for preview of deleted items
                    $routeName = $this->requestStack->getMasterRequest()->get('_route');
                    if (stristr($routeName, 'displaydeleted')) {
                        return $menu;
                    }
                «ENDIF»
                $menu->setChildrenAttribute('class', 'list-inline item-actions');

                «new ItemActions().itemActionsImpl(it)»

                return $menu;
            }
        }
    '''

    def private menuBuilderImpl(Application it) '''
        namespace «appNamespace»\Menu;

        use «appNamespace»\Menu\Base\AbstractMenuBuilder;

        /**
         * This is the menu builder implementation class.
         */
        class MenuBuilder extends AbstractMenuBuilder
        {
            // feel free to add own extensions here
        }
    '''
}
