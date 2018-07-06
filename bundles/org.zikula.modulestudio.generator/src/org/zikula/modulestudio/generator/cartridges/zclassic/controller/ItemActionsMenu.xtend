package org.zikula.modulestudio.generator.cartridges.zclassic.controller

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.ItemActions
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ItemActionsMenu {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelExtensions = new ModelExtensions
    extension Utils = new Utils

    def generate(Application it, IMostFileSystemAccess fsa) {
        'Generating item actions menu class'.printIfNotTesting(fsa)
        fsa.generateClassPair('Menu/ItemActionsMenu.php', itemActionsMenuBaseImpl, itemActionsMenuImpl)
    }

    def private itemActionsMenuBaseImpl(Application it) '''
        namespace «appNamespace»\Menu\Base;

        use Knp\Menu\FactoryInterface;
        use Knp\Menu\MenuItem;
        use Symfony\Component\DependencyInjection\ContainerAwareInterface;
        use Symfony\Component\DependencyInjection\ContainerAwareTrait;
        use Zikula\Common\Translator\TranslatorTrait;
        «IF hasEditActions || !relations.empty»
            use Zikula\UsersModule\Constant as UsersConstant;
        «ENDIF»
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
             * @param array            $options List of additional options
             *
             * @return MenuItem The assembled menu
             */
            public function menu(FactoryInterface $factory, array $options = [])
            {
                $menu = $factory->createItem('itemActions');
                if (!isset($options['entity']) || !isset($options['area']) || !isset($options['context'])) {
                    return $menu;
                }

                $this->setTranslator($this->container->get('translator.default'));

                $entity = $options['entity'];
                $routeArea = $options['area'];
                $context = $options['context'];

                $permissionHelper = $this->container->get('«appService».permission_helper');
                $currentUserApi = $this->container->get('zikula_users_module.current_user');
                «IF hasDisplayActions»
                    $entityDisplayHelper = $this->container->get('«appService».entity_display_helper');
                «ENDIF»
                «IF hasLoggable»

                    // return empty menu for preview of deleted items
                    $request = $this->container->get('request_stack')->getMasterRequest();
                    $routeName = $request->get('_route');
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
