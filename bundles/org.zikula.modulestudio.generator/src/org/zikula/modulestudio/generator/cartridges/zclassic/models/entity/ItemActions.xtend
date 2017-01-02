package org.zikula.modulestudio.generator.cartridges.zclassic.models.entity

import de.guite.modulestudio.metamodel.AdminController
import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Controller
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.EntityTreeType
import de.guite.modulestudio.metamodel.ManyToManyRelationship
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.UrlExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ItemActions {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension ModelJoinExtensions = new ModelJoinExtensions
    extension NamingExtensions = new NamingExtensions
    extension UrlExtensions = new UrlExtensions
    extension Utils = new Utils

    def itemActionsImpl(Application app) '''
        «/* TODO this needs to be cleaned for version 0.7.1 after #715 has been done */»
        $currentLegacyControllerType = $area != '' ? $area : 'user';
        $currentFunc = $context;

        «FOR entity : app.getAllEntities»
            if ($entity instanceof «entity.name.formatForCodeCapital»Entity) {
                $component = '«app.appName»:«entity.name.formatForCodeCapital»:';
                $instance = «entity.idFieldsAsParameterCode('entity')» . '::';

            «FOR controller : app.getAdminAndUserControllers»
                if ($currentLegacyControllerType == '«controller.formattedName»') {
                    «entity.itemActionsTargetingDisplay(app, controller)»
                    «entity.itemActionsTargetingEdit(app, controller)»
                    «entity.itemActionsTargetingView(app, controller)»
                    «entity.itemActionsForAddingRelatedItems(app, controller)»
                }
            «ENDFOR»
            }
        «ENDFOR»
    '''

    def private itemActionsTargetingDisplay(Entity it, Application app, Controller controller) '''
        «IF controller.hasActions('view')»
            if (in_array($currentFunc, ['index', 'view'])) {
                «IF it.hasActions('display') && controller.tempIsAdminController && application.hasUserController && application.getMainUserController.hasActions('display')»
                    $menu->addChild($this->__('Preview'), [
                        'route' => '«app.appName.formatForDB»_«name.formatForDB»_display',
                        'routeParameters' => [«routeParams('entity', false)»]
                    ])->setAttribute('icon', 'fa fa-search-plus');
                    $menu[$this->__('Preview')]->setLinkAttribute('target', '_blank');
                    $menu[$this->__('Preview')]->setLinkAttribute('title', $this->__('Open preview page'));
                «ENDIF»
                «IF it.hasActions('display') && controller.hasActions('display')»
                    $menu->addChild($this->__('Details'), [
                        'route' => '«app.appName.formatForDB»_«name.formatForDB»_«IF controller instanceof AdminController»admin«ENDIF»display',
                        'routeParameters' => [«routeParams('entity', false)»]
                    ])->setAttribute('icon', 'fa fa-eye');
                    $menu[$this->__('Details')]->setLinkAttribute('title', str_replace('"', '', $entity->getTitleFromDisplayPattern()));
                «ENDIF»
            }
        «ENDIF»
    '''

    def private itemActionsTargetingEdit(Entity it, Application app, Controller controller) '''
        «IF controller.hasActions('view') || controller.hasActions('display')»
            if (in_array($currentFunc, ['index', 'view', 'display'])) {
                «IF it.hasActions('edit') && controller.hasActions('edit')»
                    if ($permissionApi->hasPermission($component, $instance, ACCESS_EDIT)) {
                        «IF ownerPermission && standardFields»
                            $uid = $currentUserApi->get('uid');
                            // only allow editing for the owner or people with higher permissions
                            if ($entity->getCreatedUserId()->getUid() == $uid || $permissionApi->hasPermission($component, $instance, ACCESS_ADD)) {
                                «itemActionsForEditAction(controller)»
                            }
                        «ELSE»
                            «itemActionsForEditAction(controller)»
                        «ENDIF»
                    }
                «ENDIF»
                «IF it.hasActions('delete') && controller.hasActions('delete')»
                    if ($permissionApi->hasPermission($component, $instance, ACCESS_DELETE)) {
                        $menu->addChild($this->__('Delete'), [
                            'route' => '«app.appName.formatForDB»_«name.formatForDB»_«IF controller instanceof AdminController»admin«ENDIF»delete',
                            'routeParameters' => [«routeParams('entity', false)»]
                        ])->setAttribute('icon', 'fa fa-trash-o');
                        $menu[$this->__('Delete')]->setLinkAttribute('title', $this->__('Delete this «name.formatForDisplay»'));
                    }
                «ENDIF»
            }
        «ENDIF»
    '''

    def private itemActionsTargetingView(Entity it, Application app, Controller controller) '''
        «IF it.hasActions('display') && controller.hasActions('display')»
            if ($currentFunc == 'display') {
                «IF controller.hasActions('view')»
                    $title = $this->__('Back to overview');
                    $menu->addChild($title, [
                        'route' => '«app.appName.formatForDB»_«name.formatForDB»_«IF controller instanceof AdminController»admin«ENDIF»view'
                    ])->setAttribute('icon', 'fa fa-reply');
                    $menu[$title]->setLinkAttribute('title', $title);
                «ENDIF»
            }
        «ENDIF»
    '''

    def private itemActionsForAddingRelatedItems(Entity it, Application app, Controller controller) '''
        «val refedElems = getOutgoingJoinRelations.filter[e|e.target.application == it.application] + incoming.filter(ManyToManyRelationship).filter[e|e.source.application == it.application]»
        «IF !refedElems.empty && controller.hasActions('edit')»

            // more actions for adding new related items
            $authAdmin = $permissionApi->hasPermission($component, $instance, ACCESS_ADMIN);
            «/* TODO review the permission levels and maybe define them for each related entity
              * ACCESS_ADMIN for admin controllers else: «IF relatedEntity.workflow == EntityWorkflowType::NONE»EDIT«ELSE»COMMENT«ENDIF»
              */»
            $uid = $currentUserApi->get('uid');
            if ($authAdmin || (isset($uid) && $entity->getCreatedUserId()->getUid() == $uid)) {
                «FOR elem : refedElems»

                    «val useTarget = (elem.source == it)»
                    «val relationAliasName = elem.getRelationAliasName(useTarget).formatForCode.toFirstLower»
                    «val relationAliasNameParam = elem.getRelationAliasName(!useTarget).formatForCodeCapital»
                    «val otherEntity = (if (!useTarget) elem.source else elem.target)»
                    «val many = elem.isManySideDisplay(useTarget)»
                    «IF !many»
                        if (!isset($entity->«relationAliasName») || null === $entity->«relationAliasName») {
                            $title = $this->__('Create «otherEntity.name.formatForDisplay»');
                            $menu->addChild($title, [
                                'route' => '«app.appName.formatForDB»_«otherEntity.name.formatForDB»_«IF controller instanceof AdminController»admin«ENDIF»edit',
                                'routeParameters' => ['«relationAliasNameParam.formatForDB»' => «idFieldsAsParameterCode('entity')»]
                            ])->setAttribute('icon', 'fa fa-plus');
                            $menu[$title]->setLinkAttribute('title', $title);
                        }
                    «ELSE»
                        $title = $this->__('Create «otherEntity.name.formatForDisplay»');
                        $menu->addChild($title, [
                            'route' => '«app.appName.formatForDB»_«otherEntity.name.formatForDB»_«IF controller instanceof AdminController»admin«ENDIF»edit',
                            'routeParameters' => ['«relationAliasNameParam.formatForDB»' => «idFieldsAsParameterCode('entity')»]
                        ])->setAttribute('icon', 'fa fa-plus');
                        $menu[$title]->setLinkAttribute('title', $title);
                    «ENDIF»
                «ENDFOR»
            }
        «ENDIF»
    '''

    def private tempIsAdminController(Controller it) {
        switch it {
            AdminController: true
            default: false
        }
    }

    def private itemActionsForEditAction(Entity it, Controller controller) '''
        «IF !readOnly»«/*create is allowed, but editing not*/»
            $menu->addChild($this->__('Edit'), [
                'route' => '«application.appName.formatForDB»_«name.formatForDB»_«IF controller instanceof AdminController»admin«ENDIF»edit',
                'routeParameters' => [«routeParams('entity', false)»]
            ])->setAttribute('icon', 'fa fa-pencil-square-o');
            $menu[$this->__('Edit')]->setLinkAttribute('title', $this->__('Edit this «name.formatForDisplay»'));
        «ENDIF»
        «IF tree == EntityTreeType.NONE»
            $menu->addChild($this->__('Reuse'), [
                'route' => '«application.appName.formatForDB»_«name.formatForDB»_«IF controller instanceof AdminController»admin«ENDIF»edit',
                'routeParameters' => [«routeParams('entity', false, 'astemplate')»]
            ])->setAttribute('icon', 'fa fa-files-o');
            $menu[$this->__('Reuse')]->setLinkAttribute('title', $this->__('Reuse for new «name.formatForDisplay»'));
        «ENDIF»
    '''
}
