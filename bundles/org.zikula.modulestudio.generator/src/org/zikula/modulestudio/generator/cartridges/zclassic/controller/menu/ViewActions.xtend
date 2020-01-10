package org.zikula.modulestudio.generator.cartridges.zclassic.controller.menu

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.EntityTreeType
import de.guite.modulestudio.metamodel.EntityWorkflowType
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ViewActions {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension Utils = new Utils

    def actionsImpl(Application it) '''
        $query = $this->requestStack->getMasterRequest()->query;
        $currentTemplate = $query->getAlnum('tpl', '');
        «FOR entity : getAllEntities.filter[hasViewAction]»
            if ('«entity.name.formatForCode»' === $objectType) {
                «entity.actionsImpl(it)»
            }
        «ENDFOR»
    '''

    def private actionsImpl(Entity it, Application app) '''
        $routePrefix = '«app.appName.formatForDB»_«name.formatForDB»_';
        «IF ownerPermission»
            $showOnlyOwn = 'admin' !== $routeArea && $this->variableApi->get('«app.appName»', '«name.formatForCode»PrivateMode', false);
        «ENDIF»
        «IF tree != EntityTreeType.NONE»
            if ('tree' === $currentTemplate) {
                «IF hasEditAction»
                    if ($this->permissionHelper->hasComponentPermission($objectType, ACCESS_«IF workflow == EntityWorkflowType.NONE»EDIT«ELSE»COMMENT«ENDIF»)) {
                        $title = $this->«IF app.targets('3.0')»trans«ELSE»__«ENDIF»('Add root node', «IF app.targets('3.0')»[], «ENDIF»'«app.appName.formatForDB»');
                        $menu->addChild($title, [
                            'uri' => 'javascript:void(0)'
                        ]);
                        $menu[$title]->setLinkAttribute('id', 'treeAddRoot');
                        $menu[$title]->setLinkAttribute('class', '«IF app.targets('3.0')»d-none«ELSE»hidden«ENDIF»');
                        $menu[$title]->setLinkAttribute('data-object-type', $objectType);
                        $menu[$title]->setLinkAttribute('title', $title);
                        $menu[$title]->setAttribute('icon', 'fa fa-plus');
                    }
                «ENDIF»
                $title = $this->«IF app.targets('3.0')»trans«ELSE»__«ENDIF»('Switch to table view', «IF app.targets('3.0')»[], «ENDIF»'«app.appName.formatForDB»');
                $menu->addChild($title, [
                    'route' => $routePrefix . $routeArea . 'view'
                ]);
                $menu[$title]->setLinkAttribute('title', $title);
                $menu[$title]->setAttribute('icon', 'fa fa-table');
            }
        «ENDIF»
        «IF geographical»
            if ('map' === $currentTemplate) {
                «linkToEntityCreation»
                «linkTogglePagination»
                «linkToggleOwner»
            }
        «ENDIF»
        if (!in_array($currentTemplate, [«IF tree != EntityTreeType.NONE»'tree'«IF geographical», «ENDIF»«ENDIF»«IF geographical»'map'«ENDIF»])) {
            «linkToEntityCreation»
            «linkTogglePagination»
            «IF tree != EntityTreeType.NONE»
                $title = $this->«IF app.targets('3.0')»trans«ELSE»__«ENDIF»('Switch to hierarchy view', «IF app.targets('3.0')»[], «ENDIF»'«app.appName.formatForDB»');
                $menu->addChild($title, [
                    'route' => $routePrefix . $routeArea . 'view',
                    'routeParameters' => ['tpl' => 'tree']
                ]);
                $menu[$title]->setLinkAttribute('title', $title);
                $menu[$title]->setAttribute('icon', 'fa fa-code-«IF app.targets('3.0')»branch«ELSE»fork«ENDIF»');
            «ENDIF»
            «IF geographical»
                $title = $this->«IF app.targets('3.0')»trans«ELSE»__«ENDIF»('Show map', «IF app.targets('3.0')»[], «ENDIF»'«app.appName.formatForDB»');
                $menu->addChild($title, [
                    'route' => $routePrefix . $routeArea . 'view',
                    'routeParameters' => ['tpl' => 'map', 'all' => 1]
                ]);
                $menu[$title]->setLinkAttribute('title', $title);
                $menu[$title]->setAttribute('icon', 'fa fa-map«IF !app.targets('3.0')»-o«ENDIF»');
            «ENDIF»
            «linkToggleOwner»
            «IF loggable»
                // check if there exist any deleted «nameMultiple.formatForDisplay»
                $hasDeletedEntities = false;
                if ($this->permissionHelper->hasPermission(ACCESS_EDIT)) {
                    $hasDeletedEntities = $this->loggableHelper->hasDeletedEntities($objectType);
                }
                if ($hasDeletedEntities) {
                    $title = $this->«IF app.targets('3.0')»trans«ELSE»__«ENDIF»('View deleted «nameMultiple.formatForDisplay»', «IF app.targets('3.0')»[], «ENDIF»'«app.appName.formatForDB»');
                    $menu->addChild($title, [
                        'route' => $routePrefix . $routeArea . 'view',
                        'routeParameters' => ['deleted' => 1]
                    ]);
                    $menu[$title]->setLinkAttribute('title', $title);
                    $menu[$title]->setAttribute('icon', 'fa fa-trash-«IF app.targets('3.0')»alt«ELSE»o«ENDIF»');
                }
            «ENDIF»
        }
    '''

    def private linkToEntityCreation(Entity it) '''
        «IF hasEditAction»
            «linkToEntityCreationImpl»
        «ENDIF»
    '''
    def private linkToEntityCreationImpl(Entity it) '''
        $canBeCreated = $this->modelHelper->canBeCreated($objectType);
        if ($canBeCreated) {
            if ($this->permissionHelper->hasComponentPermission($objectType, ACCESS_«IF workflow == EntityWorkflowType.NONE»EDIT«ELSE»COMMENT«ENDIF»)) {
                $title = $this->«IF application.targets('3.0')»trans«ELSE»__«ENDIF»('Create «name.formatForDisplay»', «IF application.targets('3.0')»[], «ENDIF»'«application.appName.formatForDB»');
                $menu->addChild($title, [
                    'route' => $routePrefix . $routeArea . 'edit'
                ]);
                $menu[$title]->setLinkAttribute('title', $title);
                $menu[$title]->setAttribute('icon', 'fa fa-plus');
            }
        }
    '''

    def private linkTogglePagination(Entity it) '''
        $routeParameters = $query->all();
        if (1 === $query->getInt('own')«IF ownerPermission» && !$showOnlyOwn«ENDIF») {
            $routeParameters['own'] = 1;
        } else {
            unset($routeParameters['own']);
        }
        if (1 === $query->getInt('all')) {
            unset($routeParameters['all']);
            $title = $this->«IF application.targets('3.0')»trans«ELSE»__«ENDIF»('Back to paginated view', «IF application.targets('3.0')»[], «ENDIF»'«application.appName.formatForDB»');
        } else {
            $routeParameters['all'] = 1;
            $title = $this->«IF application.targets('3.0')»trans«ELSE»__«ENDIF»('Show all entries', «IF application.targets('3.0')»[], «ENDIF»'«application.appName.formatForDB»');
        }
        $menu->addChild($title, [
            'route' => $routePrefix . $routeArea . 'view',
            'routeParameters' => $routeParameters
        ]);
        $menu[$title]->setLinkAttribute('title', $title);
        $menu[$title]->setAttribute('icon', 'fa fa-table');
    '''

    def private linkToggleOwner(Entity it) '''
        «IF standardFields»
            if («IF ownerPermission»!$showOnlyOwn && «ENDIF»$this->permissionHelper->hasComponentPermission($objectType, ACCESS_«IF workflow == EntityWorkflowType.NONE»EDIT«ELSE»COMMENT«ENDIF»)) {
                «linkToggleOwnerImpl»
            }
        «ENDIF»
    '''

    def private linkToggleOwnerImpl(Entity it) '''
        $routeParameters = $query->all();
        if (1 === $query->getInt('own')) {
            unset($routeParameters['own']);
            $title = $this->«IF application.targets('3.0')»trans«ELSE»__«ENDIF»('Show also entries from other users', «IF application.targets('3.0')»[], «ENDIF»'«application.appName.formatForDB»');
            $icon = 'users';
        } else {
            $routeParameters['own'] = 1;
            $title = $this->«IF application.targets('3.0')»trans«ELSE»__«ENDIF»('Show only own entries', «IF application.targets('3.0')»[], «ENDIF»'«application.appName.formatForDB»');
            $icon = 'user';
        }
        $menu->addChild($title, [
            'route' => $routePrefix . $routeArea . 'view',
            'routeParameters' => $routeParameters
        ]);
        $menu[$title]->setLinkAttribute('title', $title);
        $menu[$title]->setAttribute('icon', 'fa fa-' . $icon);
    '''
}
