package org.zikula.modulestudio.generator.cartridges.symfony.controller.menu

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.application.ImportList
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class MenuBuilder {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension Utils = new Utils

    def generate(Application it, IMostFileSystemAccess fsa) {
        'Generating menu builder class'.printIfNotTesting(fsa)
        fsa.generateClassPair('Menu/MenuBuilder.php', menuBuilderBaseImpl, menuBuilderImpl)
    }

    def private collectBaseImports(Application it) {
        val imports = new ImportList
        imports.addAll(#[
            'Symfony\\Bundle\\SecurityBundle\\Security',
            'Symfony\\Component\\HttpFoundation\\RequestStack',
            appNamespace + '\\Helper\\PermissionHelper'
        ])
        if ((!entities.filter[ownerPermission].empty && (hasEditActions || hasDeleteActions)) || !relations.empty) {
            imports.add('Zikula\\UsersBundle\\UsersConstant')
        }
        for (entity : entities) {
            imports.add(appNamespace + '\\Entity\\' + entity.name.formatForCodeCapital)
        }
        if (hasDetailActions) {
            imports.add(appNamespace + '\\Helper\\EntityDisplayHelper')
        }
        if (hasLoggable) {
            imports.add(appNamespace + '\\Helper\\LoggableHelper')
        }
        if (hasIndexActions && hasEditActions) {
            imports.add(appNamespace + '\\Helper\\ModelHelper')
        }
        imports
    }

    def private menuBuilderBaseImpl(Application it) '''
        namespace «appNamespace»\Menu\Base;

        «collectBaseImports.print»

        /**
         * Menu builder base class.
         */
        class AbstractMenuBuilder
        {
            «menuBuilderClassBaseImpl»
        }
    '''

    def private menuBuilderClassBaseImpl(Application it) '''
        public function __construct(
            protected readonly RequestStack $requestStack,
            protected readonly PermissionHelper $permissionHelper,
            «IF hasDetailActions»
                protected readonly EntityDisplayHelper $entityDisplayHelper,
            «ENDIF»
            «IF hasLoggable»
                protected readonly LoggableHelper $loggableHelper,
            «ENDIF»
            protected readonly Security $security,
            «IF hasIndexActions && hasEditActions»
                protected readonly ModelHelper $modelHelper,
            «ENDIF»
            «IF hasIndexActions»
                protected readonly array $listViewConfig,
            «ENDIF»
        ) {
        }

        «createMenu('item')»
        «IF hasIndexActions»

            «createMenu('index')»
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

                    $mainRequest = $this->requestStack->getMainRequest();
                    // return empty menu for preview of deleted items
                    $routeName = $mainRequest->get('_route');
                    if (false !== mb_stripos($routeName, 'displaydeleted')) {
                        return $menu;
                    }
                «ENDIF»
            «ELSEIF 'index' == actionType»
                if (!isset($options['objectType'], $options['area'])) {
                    return $menu;
                }

                $objectType = $options['objectType'];
                $routeArea = $options['area'];
            «ENDIF»
            $menu->setChildrenAttribute('class', 'nav «actionType»-actions');

            «IF 'item' == actionType»
                «new ItemActions().actionsImpl(it)»
            «ELSEIF 'index' == actionType»
                «new IndexActions().actionsImpl(it)»
            «ENDIF»

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
