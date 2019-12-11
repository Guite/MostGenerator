package org.zikula.modulestudio.generator.cartridges.zclassic.models.entity

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.EntityTreeType
import de.guite.modulestudio.metamodel.EntityWorkflowType
import de.guite.modulestudio.metamodel.ItemActionsStyle
import de.guite.modulestudio.metamodel.ManyToManyRelationship
import de.guite.modulestudio.metamodel.ManyToOneRelationship
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ItemActions {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelExtensions = new ModelExtensions
    extension ModelJoinExtensions = new ModelJoinExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    def itemActionsImpl(Application app) '''
        «IF (!app.getAllEntities.filter[ownerPermission].empty && (app.hasEditActions || app.hasDeleteActions)) || !app.relations.empty»
            $currentUserId = $this->currentUserApi->isLoggedIn()
                ? $this->currentUserApi->get('uid')
                : UsersConstant::USER_ID_ANONYMOUS
            ;
        «ENDIF»
        «FOR entity : app.getAllEntities»
            if ($entity instanceof «entity.name.formatForCodeCapital»Entity) {
                $routePrefix = '«app.appName.formatForDB»_«entity.name.formatForDB»_';
                «IF (entity.ownerPermission && (entity.hasEditAction || entity.hasDeleteAction)) || (entity.standardFields && !app.relations.empty)»
                    $isOwner = 0 < $currentUserId
                        && null !== $entity->getCreatedBy()
                        && $currentUserId === $entity->getCreatedBy()->getUid()
                    ;
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
            if ('admin' === $routeArea) {
                $title = $this->__('Preview', '«app.appName.formatForDB»');
                $previewRouteParameters = $entity->createUrlArgs();
                $previewRouteParameters['preview'] = 1;
                $menu->addChild($title, [
                    'route' => $routePrefix . 'display',
                    'routeParameters' => $previewRouteParameters
                ]);
                $menu[$title]->setLinkAttribute('target', '_blank');
                $menu[$title]->setLinkAttribute('title',
                    $this->__('Open preview page', '«app.appName.formatForDB»')
                );
                «app.addLinkClass('default')»
                «app.addIcon('search-plus')»
            }
            if ('display' !== $context) {
                $title = $this->__('Details', '«app.appName.formatForDB»');
                $menu->addChild($title, [
                    'route' => $routePrefix . $routeArea . 'display',
                    'routeParameters' => $entity->createUrlArgs()
                ]);
                $entityTitle = $this->entityDisplayHelper->getFormattedTitle($entity);
                $menu[$title]->setLinkAttribute('title',
                    str_replace('"', '', $entityTitle)
                );
                «app.addLinkClass('default')»
                «app.addIcon('eye')»
            }
        «ENDIF»
    '''

    def private itemActionsTargetingEdit(Entity it, Application app) '''
        «IF hasEditAction»
            if ($this->permissionHelper->mayEdit($entity)) {
                «IF ownerPermission»
                    // only allow editing for the owner or people with higher permissions
                    if ($isOwner || $this->permissionHelper->hasEntityPermission($entity, ACCESS_ADD)) {
                        «itemActionsForEditAction»
                    }
                «ELSE»
                    «itemActionsForEditAction»
                «ENDIF»
            }
        «ENDIF»
        «IF loggable»
            if ($this->permissionHelper->mayAccessHistory($entity)) {
                if (in_array($context, ['view', 'display']) && $this->loggableHelper->hasHistoryItems($entity)) {
                    $title = $this->__('History', '«app.appName.formatForDB»');
                    $menu->addChild($title, [
                        'route' => $routePrefix . $routeArea . 'loggablehistory',
                        'routeParameters' => $entity->createUrlArgs()
                    ]);
                    $menu[$title]->setLinkAttribute('title',
                        $this->__('Watch version history', '«app.appName.formatForDB»')
                    );
                    «app.addLinkClass('default')»
                    «app.addIcon('history')»
                }
            }
        «ENDIF»
        «IF hasDeleteAction»
            if ($this->permissionHelper->mayDelete($entity)«IF ownerPermission» || ($isOwner && $this->permissionHelper->mayEdit($entity))«ENDIF») {
                $title = $this->__('Delete', '«app.appName.formatForDB»');
                $menu->addChild($title, [
                    'route' => $routePrefix . $routeArea . 'delete',
                    'routeParameters' => $entity->createUrlArgs()
                ]);
                $menu[$title]->setLinkAttribute('title',
                    $this->__('Delete this «name.formatForDisplay»', '«app.appName.formatForDB»')
                );
                «app.addLinkClass('danger')»
                «app.addIcon('trash-o')»
            }
        «ENDIF»
    '''

    def private itemActionsTargetingView(Entity it, Application app) '''
        «IF hasDisplayAction && hasViewAction»
            if ('display' === $context) {
                $title = $this->__('«nameMultiple.formatForDisplayCapital» list', '«app.appName.formatForDB»');
                $menu->addChild($title, [
                    'route' => $routePrefix . $routeArea . 'view'
                ]);
                $menu[$title]->setLinkAttribute('title', $title);
                «app.addLinkClass('default')»
                «app.addIcon('reply')»
            }
        «ENDIF»
    '''

    def private itemActionsForAddingRelatedItems(Entity it, Application app) '''
        «val refedElems = getEditableJoinRelations(false).filter[r|(r.target as Entity).hasEditAction && !(r instanceof ManyToOneRelationship)]
            + incoming.filter(ManyToManyRelationship).filter[r|r.bidirectional && r.source.application == it.application && r.source instanceof Entity && (r.source as Entity).hasEditAction]»
        «IF !refedElems.empty»

            // more actions for adding new related items
            «FOR elem : refedElems»
                «val useTarget = (elem.source == it)»
                «val relationAliasName = elem.getRelationAliasName(useTarget).formatForCodeCapital»
                «val relationAliasNameParam = elem.getRelationAliasName(!useTarget)»
                «val otherEntity = (if (!useTarget) elem.source else elem.target)»

                if («IF standardFields»$isOwner || «ENDIF»$this->permissionHelper->hasComponentPermission('«otherEntity.name.formatForCode»', ACCESS_«IF otherEntity instanceof Entity && (otherEntity as Entity).ownerPermission»ADD«ELSEIF (otherEntity as Entity).workflow == EntityWorkflowType.NONE»EDIT«ELSE»COMMENT«ENDIF»)) {
                    «val many = elem.isManySideDisplay(useTarget)»
                    «IF !many»
                        if (null === $entity->get«relationAliasName»()) {
                            $title = $this->__('Create «elem.getRelationAliasName(useTarget).formatForDisplay»', '«app.appName.formatForDB»');
                            $menu->addChild($title, [
                                'route' => '«app.appName.formatForDB»_«otherEntity.name.formatForDB»_' . $routeArea . 'edit',
                                'routeParameters' => ['«relationAliasNameParam»' => $entity->«IF hasSluggableFields && slugUnique»getSlug()«ELSE»getKey()«ENDIF»]
                            ]);
                            $menu[$title]->setLinkAttribute('title', $title);
                            «app.addLinkClass('default')»
                            «app.addIcon('plus')»
                        }
                    «ELSE»
                        $title = $this->__('Create «elem.getRelationAliasName(useTarget).formatForDisplay»', '«app.appName.formatForDB»');
                        $menu->addChild($title, [
                            'route' => '«app.appName.formatForDB»_«otherEntity.name.formatForDB»_' . $routeArea . 'edit',
                            'routeParameters' => ['«relationAliasNameParam»' => $entity->«IF hasSluggableFields && slugUnique»getSlug()«ELSE»getKey()«ENDIF»]
                        ]);
                        $menu[$title]->setLinkAttribute('title', $title);
                        «app.addLinkClass('default')»
                        «app.addIcon('plus')»
                    «ENDIF»
                }
            «ENDFOR»
        «ENDIF»
    '''

    def private itemActionsForEditAction(Entity it) '''
        «IF !readOnly»«/*create is allowed, but editing not*/»
            $title = $this->__('Edit', '«application.appName.formatForDB»');
            $menu->addChild($title, [
                'route' => $routePrefix . $routeArea . 'edit',
                'routeParameters' => $entity->createUrlArgs(«IF hasSluggableFields && slugUnique»true«ENDIF»)
            ]);
            $menu[$title]->setLinkAttribute('title',
                $this->__('Edit this «name.formatForDisplay»', '«application.appName.formatForDB»')
            );
            «application.addLinkClass('default')»
            «application.addIcon('pencil-square-o')»
        «ENDIF»
        $title = $this->__('Reuse', '«application.appName.formatForDB»');
        $menu->addChild($title, [
            'route' => $routePrefix . $routeArea . 'edit',
            'routeParameters' => ['astemplate' => $entity->getKey()]
        ]);
        $menu[$title]->setLinkAttribute('title',
            $this->__('Reuse for new «name.formatForDisplay»', '«application.appName.formatForDB»')
        );
        «application.addLinkClass('default')»
        «application.addIcon('files-o')»
        «IF tree != EntityTreeType.NONE»
            if ($this->permissionHelper->hasEntityPermission($entity, ACCESS_ADD)) {
                $title = $this->__('Add sub «name.formatForDisplay»', '«application.appName.formatForDB»');
                $menu->addChild($title, [
                    'route' => $routePrefix . $routeArea . 'edit',
                    'routeParameters' => ['parent' => $entity->getKey()]
                ]);
                $menu[$title]->setLinkAttribute('title',
                    $this->__('Add a sub «name.formatForDisplay» to this «name.formatForDisplay»', '«application.appName.formatForDB»')
                );
                «application.addLinkClass('default')»
                «application.addIcon('child')»
            }
        «ENDIF»
    '''

    def private addLinkClass(Application it, String linkClass) '''
        «IF viewActionsStyle.hasButtons && displayActionsStyle.hasButtons»
            $menu[$title]->setLinkAttribute('class', 'btn btn-sm btn-«linkClass»');
        «ELSEIF viewActionsStyle.hasButtons && !displayActionsStyle.hasButtons»
            if ('view' === $context) {
                $menu[$title]->setLinkAttribute('class', 'btn btn-sm btn-«linkClass»');
            }
        «ELSEIF !viewActionsStyle.hasButtons && displayActionsStyle.hasButtons»
            if ('display' === $context) {
                $menu[$title]->setLinkAttribute('class', 'btn btn-sm btn-«linkClass»');
            }
        «ENDIF»
    '''

    def private hasButtons(ItemActionsStyle style) {
        #[ItemActionsStyle.BUTTON, ItemActionsStyle.BUTTON_GROUP].contains(style)
    }

    def private addIcon(Application it, String icon) '''
        «IF viewActionsWithIcons && displayActionsWithIcons»
            $menu[$title]->setAttribute('icon', 'fa fa-«icon»');
        «ELSEIF viewActionsWithIcons && !displayActionsWithIcons»
            if ('view' === $context) {
                $menu[$title]->setAttribute('icon', 'fa fa-«icon»');
            }
        «ELSEIF !viewActionsWithIcons && displayActionsWithIcons»
            if ('display' === $context) {
                $menu[$title]->setAttribute('icon', 'fa fa-«icon»');
            }
        «ENDIF»
    '''
}
