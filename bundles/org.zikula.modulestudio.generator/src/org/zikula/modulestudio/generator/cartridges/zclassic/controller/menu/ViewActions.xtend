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
                        $menu->addChild(«IF !app.targets('3.0')»$this->__(«ENDIF»'Add root node'«IF !app.targets('3.0')»«IF !app.isSystemModule», '«app.appName.formatForDB»'«ENDIF»)«ENDIF», [
                            'uri' => 'javascript:void(0)',
                        ])
                            ->setLinkAttribute('id', 'treeAddRoot')
                            ->setLinkAttribute('class', '«IF app.targets('3.0')»d-none«ELSE»hidden«ENDIF»')
                            ->setLinkAttribute('data-object-type', $objectType)
                            ->setAttribute('icon', 'fa«IF app.targets('3.0')»s«ENDIF» fa-plus')
                        ;
                    }
                «ENDIF»
                $menu->addChild(«IF !app.targets('3.0')»$this->__(«ENDIF»'Switch to table view'«IF !app.targets('3.0')»«IF !app.isSystemModule», '«app.appName.formatForDB»'«ENDIF»)«ENDIF», [
                    'route' => $routePrefix . $routeArea . 'view',
                ])
                    ->setAttribute('icon', 'fa«IF app.targets('3.0')»s«ENDIF» fa-table')
                ;
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
                $menu->addChild(«IF !app.targets('3.0')»$this->__(«ENDIF»'Switch to hierarchy view'«IF !app.targets('3.0')»«IF !app.isSystemModule», '«app.appName.formatForDB»'«ENDIF»)«ENDIF», [
                    'route' => $routePrefix . $routeArea . 'view',
                    'routeParameters' => ['tpl' => 'tree'],
                ])
                    ->setAttribute('icon', 'fa«IF app.targets('3.0')»s«ENDIF» fa-code-«IF app.targets('3.0')»branch«ELSE»fork«ENDIF»')
                ;
            «ENDIF»
            «IF geographical»
                $menu->addChild(«IF !app.targets('3.0')»$this->__(«ENDIF»'Show map'«IF !app.targets('3.0')»«IF !app.isSystemModule», '«app.appName.formatForDB»'«ENDIF»)«ENDIF», [
                    'route' => $routePrefix . $routeArea . 'view',
                    'routeParameters' => ['tpl' => 'map', 'all' => 1],
                ])
                    ->setAttribute('icon', 'fa«IF app.targets('3.0')»s«ENDIF» fa-map«IF !app.targets('3.0')»-o«ENDIF»')
                ;
            «ENDIF»
            «linkToggleOwner»
            «IF loggable»
                if ($this->permissionHelper->mayAccessHistory) {
                    // check if there exist any deleted «nameMultiple.formatForDisplay»
                    $hasDeletedEntities = false;
                    if ($this->permissionHelper->hasPermission(ACCESS_EDIT)) {
                        $hasDeletedEntities = $this->loggableHelper->hasDeletedEntities($objectType);
                    }
                    if ($hasDeletedEntities) {
                        $menu->addChild(«IF !app.targets('3.0')»$this->__(«ENDIF»'View deleted «nameMultiple.formatForDisplay»'«IF !app.targets('3.0')»«IF !app.isSystemModule», '«app.appName.formatForDB»'«ENDIF»)«ENDIF», [
                            'route' => $routePrefix . $routeArea . 'view',
                            'routeParameters' => ['deleted' => 1],
                        ])
                            ->setAttribute('icon', 'fa«IF app.targets('3.0')»s«ENDIF» fa-trash-«IF app.targets('3.0')»alt«ELSE»o«ENDIF»')
                            «IF app.targets('3.0') && !app.isSystemModule»
                                ->setExtra('translation_domain', '«name.formatForCode»')
                            «ENDIF»
                        ;
                    }
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
                $menu->addChild(«IF !application.targets('3.0')»$this->__(«ENDIF»'Create «name.formatForDisplay»'«IF !application.targets('3.0')»«IF !application.isSystemModule», '«application.appName.formatForDB»'«ENDIF»)«ENDIF», [
                    'route' => $routePrefix . $routeArea . 'edit',
                ])
                    ->setAttribute('icon', 'fa«IF application.targets('3.0')»s«ENDIF» fa-plus')
                    «IF application.targets('3.0') && !application.isSystemModule»
                        ->setExtra('translation_domain', '«name.formatForCode»')
                    «ENDIF»
                ;
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
            $menu->addChild(«IF !application.targets('3.0')»$this->__(«ENDIF»'Back to paginated view'«IF !application.targets('3.0')»«IF !application.isSystemModule», '«application.appName.formatForDB»'«ENDIF»)«ENDIF», [
                'route' => $routePrefix . $routeArea . 'view',
                'routeParameters' => $routeParameters,
            ])
                ->setAttribute('icon', 'fa«IF application.targets('3.0')»s«ENDIF» fa-table')
            ;
        } else {
            $routeParameters['all'] = 1;
            $menu->addChild(«IF !application.targets('3.0')»$this->__(«ENDIF»'Show all entries'«IF !application.targets('3.0')»«IF !application.isSystemModule», '«application.appName.formatForDB»'«ENDIF»)«ENDIF», [
                'route' => $routePrefix . $routeArea . 'view',
                'routeParameters' => $routeParameters,
            ])
                ->setAttribute('icon', 'fa«IF application.targets('3.0')»s«ENDIF» fa-table')
            ;
        }
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
            $routeParameters['own'] = 0;
            $menu->addChild(«IF !application.targets('3.0')»$this->__(«ENDIF»'Show also entries from other users'«IF !application.targets('3.0')»«IF !application.isSystemModule», '«application.appName.formatForDB»'«ENDIF»)«ENDIF», [
                'route' => $routePrefix . $routeArea . 'view',
                'routeParameters' => $routeParameters,
            ])
                ->setAttribute('icon', 'fa«IF application.targets('3.0')»s«ENDIF» fa-users')
            ;
        } else {
            $routeParameters['own'] = 1;
            $menu->addChild(«IF !application.targets('3.0')»$this->__(«ENDIF»'Show only own entries'«IF !application.targets('3.0')»«IF !application.isSystemModule», '«application.appName.formatForDB»'«ENDIF»)«ENDIF», [
                'route' => $routePrefix . $routeArea . 'view',
                'routeParameters' => $routeParameters,
            ])
                ->setAttribute('icon', 'fa«IF application.targets('3.0')»s«ENDIF» fa-user')
            ;
        }
    '''
}
