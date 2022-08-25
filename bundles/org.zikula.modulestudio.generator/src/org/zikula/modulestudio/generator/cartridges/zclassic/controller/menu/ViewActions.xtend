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
        $mainRequest = $this->requestStack->get«IF targets('3.1')»Main«ELSE»Master«ENDIF»Request();
        $query = $mainRequest->query;
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
            $showOnlyOwn = 'admin' !== $routeArea && $this->listViewConfig['«name.formatForSnakeCase»_private_mode'];
        «ENDIF»
        «IF tree != EntityTreeType.NONE»
            if ('tree' === $currentTemplate) {
                «IF hasEditAction»
                    if ($this->permissionHelper->hasComponentPermission($objectType, ACCESS_«IF workflow == EntityWorkflowType.NONE»EDIT«ELSE»COMMENT«ENDIF»)) {
                        $menu->addChild('Add root node', [
                            'uri' => 'javascript:void(0)',
                        ])
                            ->setLinkAttribute('id', 'treeAddRoot')
                            ->setLinkAttribute('class', 'd-none')
                            ->setLinkAttribute('data-object-type', $objectType)
                            ->setAttribute('icon', 'fas fa-plus')
                        ;
                    }
                «ENDIF»
                $menu->addChild('Switch to table view', [
                    'route' => $routePrefix . $routeArea . 'view',
                ])
                    ->setAttribute('icon', 'fas fa-table')
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
                $menu->addChild('Switch to hierarchy view', [
                    'route' => $routePrefix . $routeArea . 'view',
                    'routeParameters' => ['tpl' => 'tree'],
                ])
                    ->setAttribute('icon', 'fas fa-code-branch')
                ;
            «ENDIF»
            «IF geographical»
                $menu->addChild('Show map', [
                    'route' => $routePrefix . $routeArea . 'view',
                    'routeParameters' => ['tpl' => 'map', 'all' => 1],
                ])
                    ->setAttribute('icon', 'fas fa-map')
                ;
            «ENDIF»
            «linkToggleOwner»
            «IF loggable»
                if ($this->permissionHelper->mayUseHistory($objectType)) {
                    // check if there exist any deleted «nameMultiple.formatForDisplay»
                    $hasDeletedEntities = false;
                    if ($this->permissionHelper->hasPermission(ACCESS_EDIT)) {
                        $hasDeletedEntities = $this->loggableHelper->hasDeletedEntities($objectType);
                    }
                    if ($hasDeletedEntities) {
                        $menu->addChild('View deleted «nameMultiple.formatForDisplay»', [
                            'route' => $routePrefix . $routeArea . 'view',
                            'routeParameters' => ['deleted' => 1],
                        ])
                            ->setAttribute('icon', 'fas fa-trash-alt')
                            ->setExtra('translation_domain', '«name.formatForCode»')
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
                $menu->addChild('Create «name.formatForDisplay»', [
                    'route' => $routePrefix . $routeArea . 'edit',
                ])
                    ->setAttribute('icon', 'fas fa-plus')
                    ->setExtra('translation_domain', '«name.formatForCode»')
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
            $menu->addChild('Back to paginated view', [
                'route' => $routePrefix . $routeArea . 'view',
                'routeParameters' => $routeParameters,
            ])
                ->setAttribute('icon', 'fas fa-table')
            ;
        } else {
            $routeParameters['all'] = 1;
            $menu->addChild('Show all entries', [
                'route' => $routePrefix . $routeArea . 'view',
                'routeParameters' => $routeParameters,
            ])
                ->setAttribute('icon', 'fas fa-table')
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
            $menu->addChild('Show also entries from other users', [
                'route' => $routePrefix . $routeArea . 'view',
                'routeParameters' => $routeParameters,
            ])
                ->setAttribute('icon', 'fas fa-users')
            ;
        } else {
            $routeParameters['own'] = 1;
            $menu->addChild('Show only own entries', [
                'route' => $routePrefix . $routeArea . 'view',
                'routeParameters' => $routeParameters,
            ])
                ->setAttribute('icon', 'fas fa-user')
            ;
        }
    '''
}
