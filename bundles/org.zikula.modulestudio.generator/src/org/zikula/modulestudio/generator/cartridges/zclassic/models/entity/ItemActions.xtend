package org.zikula.modulestudio.generator.cartridges.zclassic.models.entity

import de.guite.modulestudio.metamodel.Application
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
        «IF app.hasEditActions || !app.relations.empty»
            $currentUserId = $currentUserApi->isLoggedIn() ? $currentUserApi->get('uid') : 1;
        «ENDIF»
        «FOR entity : app.getAllEntities»
            if ($entity instanceof «entity.name.formatForCodeCapital»Entity) {
                $component = '«app.appName»:«entity.name.formatForCodeCapital»:';
                $instance = «entity.idFieldsAsParameterCode('entity')» . '::';
                $routePrefix = '«app.appName.formatForDB»_«entity.name.formatForDB»_';
                «IF entity.standardFields»
                    $isOwner = $currentUserId > 0 && $currentUserId == $entity->getCreatedBy()->getUid();
                «ENDIF»

                «entity.itemActionsTargetingDisplay(app)»
                «entity.itemActionsTargetingEdit(app)»
                «entity.itemActionsTargetingView(app)»
                «entity.itemActionsForAddingRelatedItems(app)»
            }
        «ENDFOR»
    '''

    def private itemActionsTargetingDisplay(Entity it, Application app) '''
        «IF hasDisplayAction»
            if ($routeArea == 'admin') {
                $menu->addChild($this->__('Preview'), [
                    'route' => $routePrefix . 'display',
                    'routeParameters' => [«routeParams('entity', false)»]
                ])->setAttribute('icon', 'fa fa-search-plus');
                $menu[$this->__('Preview')]->setLinkAttribute('target', '_blank');
                $menu[$this->__('Preview')]->setLinkAttribute('title', $this->__('Open preview page'));
            }
            if ($context != 'display') {
                $menu->addChild($this->__('Details'), [
                    'route' => $routePrefix . $routeArea . 'display',
                    'routeParameters' => [«routeParams('entity', false)»]
                ])->setAttribute('icon', 'fa fa-eye');
                $menu[$this->__('Details')]->setLinkAttribute('title', str_replace('"', '', $entity->getTitleFromDisplayPattern()));
            }
        «ENDIF»
    '''

    def private itemActionsTargetingEdit(Entity it, Application app) '''
        «IF hasEditAction»
            if ($permissionApi->hasPermission($component, $instance, ACCESS_EDIT)) {
                «IF ownerPermission»
                    // only allow editing for the owner or people with higher permissions
                    if ($isOwner || $permissionApi->hasPermission($component, $instance, ACCESS_ADD)) {
                        «itemActionsForEditAction»
                    }
                «ELSE»
                    «itemActionsForEditAction»
                «ENDIF»
            }
        «ENDIF»
        «IF hasDeleteAction»
            if ($permissionApi->hasPermission($component, $instance, ACCESS_DELETE)) {
                $menu->addChild($this->__('Delete'), [
                    'route' => $routePrefix . $routeArea . 'delete',
                    'routeParameters' => [«routeParams('entity', false)»]
                ])->setAttribute('icon', 'fa fa-trash-o');
                $menu[$this->__('Delete')]->setLinkAttribute('title', $this->__('Delete this «name.formatForDisplay»'));
            }
        «ENDIF»
    '''

    def private itemActionsTargetingView(Entity it, Application app) '''
        «IF hasDisplayAction && hasViewAction»
            if ($context == 'display') {
                $title = $this->__('Back to overview');
                $menu->addChild($title, [
                    'route' => $routePrefix . $routeArea . 'view'
                ])->setAttribute('icon', 'fa fa-reply');
                $menu[$title]->setLinkAttribute('title', $title);
            }
        «ENDIF»
    '''

    def private itemActionsForAddingRelatedItems(Entity it, Application app) '''
        «val refedElems = getOutgoingJoinRelations.filter[e|e.target.application == it.application && e.target instanceof Entity && (e.target as Entity).hasEditAction]
            + incoming.filter(ManyToManyRelationship).filter[e|e.source.application == it.application && e.source instanceof Entity && (e.source as Entity).hasEditAction]»
        «IF !refedElems.empty»

            // more actions for adding new related items
            $authAdmin = $permissionApi->hasPermission($component, $instance, ACCESS_ADMIN);
            «/* TODO review the permission levels and maybe define them for each related entity
              * ACCESS_ADMIN for admin controllers else: «IF relatedEntity.ownerPermission»ADD«ELSEIF relatedEntity.workflow == EntityWorkflowType::NONE»EDIT«ELSE»COMMENT«ENDIF»
              */»
            if ($isOwner || $authAdmin) {
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
                                'route' => '«app.appName.formatForDB»_«otherEntity.name.formatForDB»_' . $routeArea . 'edit',
                                'routeParameters' => ['«relationAliasNameParam.formatForDB»' => «idFieldsAsParameterCode('entity')»]
                            ])->setAttribute('icon', 'fa fa-plus');
                            $menu[$title]->setLinkAttribute('title', $title);
                        }
                    «ELSE»
                        $title = $this->__('Create «otherEntity.name.formatForDisplay»');
                        $menu->addChild($title, [
                            'route' => '«app.appName.formatForDB»_«otherEntity.name.formatForDB»_' . $routeArea . 'edit',
                            'routeParameters' => ['«relationAliasNameParam.formatForDB»' => «idFieldsAsParameterCode('entity')»]
                        ])->setAttribute('icon', 'fa fa-plus');
                        $menu[$title]->setLinkAttribute('title', $title);
                    «ENDIF»
                «ENDFOR»
            }
        «ENDIF»
    '''

    def private itemActionsForEditAction(Entity it) '''
        «IF !readOnly»«/*create is allowed, but editing not*/»
            $menu->addChild($this->__('Edit'), [
                'route' => $routePrefix . $routeArea . 'edit',
                'routeParameters' => [«routeParams('entity', false)»]
            ])->setAttribute('icon', 'fa fa-pencil-square-o');
            $menu[$this->__('Edit')]->setLinkAttribute('title', $this->__('Edit this «name.formatForDisplay»'));
        «ENDIF»
        «IF tree == EntityTreeType.NONE»
            $menu->addChild($this->__('Reuse'), [
                'route' => $routePrefix . $routeArea . 'edit',
                'routeParameters' => [«routeParams('entity', false, 'astemplate')»]
            ])->setAttribute('icon', 'fa fa-files-o');
            $menu[$this->__('Reuse')]->setLinkAttribute('title', $this->__('Reuse for new «name.formatForDisplay»'));
        «ENDIF»
    '''
}
