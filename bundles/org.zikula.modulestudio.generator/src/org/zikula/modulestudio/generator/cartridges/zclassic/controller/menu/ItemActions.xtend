package org.zikula.modulestudio.generator.cartridges.zclassic.controller.menu

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

    def actionsImpl(Application it) '''
        «IF (!getAllEntities.filter[ownerPermission].empty && (hasEditActions || hasDeleteActions)) || !relations.empty»
            $currentUserId = $this->currentUserApi->isLoggedIn()
                ? $this->currentUserApi->get('uid')
                : UsersConstant::USER_ID_ANONYMOUS
            ;
        «ENDIF»
        «FOR entity : getAllEntities»
            if ($entity instanceof «entity.name.formatForCodeCapital»Entity) {
                «entity.actionsImpl»
            }
        «ENDFOR»
    '''

    def private actionsImpl(Entity it) '''
        $routePrefix = '«application.appName.formatForDB»_«name.formatForDB»_';
        «IF (ownerPermission && (hasEditAction || hasDeleteAction)) || (standardFields && !application.relations.empty)»
            $isOwner = 0 < $currentUserId
                && null !== $entity->getCreatedBy()
                && $currentUserId === $entity->getCreatedBy()->getUid()
            ;
        «ENDIF»
        «IF hasDisplayAction || hasEditAction || loggable || hasDeleteAction»

        «ENDIF»
        «itemActionsTargetingDisplay(application)»
        «itemActionsTargetingEdit(application)»
        «itemActionsTargetingView(application)»
        «itemActionsForAddingRelatedItems(application)»
    '''

    def private itemActionsTargetingDisplay(Entity it, Application app) '''
        «IF hasDisplayAction»
            if ('admin' === $routeArea) {
                $previewRouteParameters = $entity->createUrlArgs();
                $previewRouteParameters['preview'] = 1;
                $menu->addChild('Preview', [
                    'route' => $routePrefix . 'display',
                    'routeParameters' => $previewRouteParameters,
                ])
                    ->setLinkAttribute('target', '_blank')
                    ->setLinkAttribute(
                        'title',
                        'Open preview page'
                    )
                    «app.addLinkClass('secondary')»
                    «app.addIcon('search-plus')»
                ;
            }
            if ('display' !== $context) {
                $entityTitle = $this->entityDisplayHelper->getFormattedTitle($entity);
                $menu->addChild('Details', [
                    'route' => $routePrefix . $routeArea . 'display',
                    'routeParameters' => $entity->createUrlArgs(),
                ])
                    ->setLinkAttribute(
                        'title',
                        str_replace('"', '', $entityTitle)
                    )
                    «app.addLinkClass('secondary')»
                    «app.addIcon('eye')»
                ;
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
                    $menu->addChild('History', [
                        'route' => $routePrefix . $routeArea . 'loggablehistory',
                        'routeParameters' => $entity->createUrlArgs(),
                    ])
                        ->setLinkAttribute(
                            'title',
                            'Watch version history'
                        )
                        «app.addLinkClass('secondary')»
                        «app.addIcon('history')»
                    ;
                }
            }
        «ENDIF»
        «IF hasDeleteAction»
            if ($this->permissionHelper->mayDelete($entity)«IF ownerPermission» || ($isOwner && $this->permissionHelper->mayEdit($entity))«ENDIF») {
                $menu->addChild('Delete', [
                    'route' => $routePrefix . $routeArea . 'delete',
                    'routeParameters' => $entity->createUrlArgs(),
                ])
                    ->setLinkAttribute(
                        'title',
                        'Delete this «name.formatForDisplay»'
                    )
                    «app.addLinkClass('danger')»
                    «app.addIcon('trash')»
                    «IF !app.isSystemModule»
                        ->setExtra('translation_domain', '«name.formatForCode»')
                    «ENDIF»
                ;
            }
        «ENDIF»
    '''

    def private itemActionsTargetingView(Entity it, Application app) '''
        «IF hasDisplayAction && hasViewAction»
            if ('display' === $context) {
                $menu->addChild('«nameMultiple.formatForDisplayCapital» list', [
                    'route' => $routePrefix . $routeArea . 'view',
                ])
                    «app.addLinkClass('secondary')»
                    «app.addIcon('reply')»
                    «IF !app.isSystemModule»
                        ->setExtra('translation_domain', '«name.formatForCode»')
                    «ENDIF»
                ;
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
                            $menu->addChild('Create «elem.getRelationAliasName(useTarget).formatForDisplay»', [
                                'route' => '«app.appName.formatForDB»_«otherEntity.name.formatForDB»_' . $routeArea . 'edit',
                                'routeParameters' => ['«relationAliasNameParam»' => $entity->«IF hasSluggableFields && slugUnique»getSlug()«ELSE»getKey()«ENDIF»],
                            ])
                                «app.addLinkClass('secondary')»
                                «app.addIcon('plus')»
                                «IF !app.isSystemModule»
                                    ->setExtra('translation_domain', '«name.formatForCode»')
                                «ENDIF»
                            ;
                        }
                    «ELSE»
                        $menu->addChild('Create «elem.getRelationAliasName(useTarget).formatForDisplay»', [
                            'route' => '«app.appName.formatForDB»_«otherEntity.name.formatForDB»_' . $routeArea . 'edit',
                            'routeParameters' => ['«relationAliasNameParam»' => $entity->«IF hasSluggableFields && slugUnique»getSlug()«ELSE»getKey()«ENDIF»],
                        ])
                            «app.addLinkClass('secondary')»
                            «app.addIcon('plus')»
                            «IF !app.isSystemModule»
                                ->setExtra('translation_domain', '«name.formatForCode»')
                            «ENDIF»
                        ;
                    «ENDIF»
                }
            «ENDFOR»
        «ENDIF»
    '''

    def private itemActionsForEditAction(Entity it) '''
        «IF !readOnly»«/*create is allowed, but editing not*/»
            $menu->addChild('Edit', [
                'route' => $routePrefix . $routeArea . 'edit',
                'routeParameters' => $entity->createUrlArgs(«IF hasSluggableFields && slugUnique»true«ENDIF»),
            ])
                ->setLinkAttribute(
                    'title',
                    'Edit this «name.formatForDisplay»'
                )
                «application.addLinkClass('secondary')»
                «application.addIcon('edit')»
                «IF !application.isSystemModule»
                    ->setExtra('translation_domain', '«name.formatForCode»')
                «ENDIF»
            ;
        «ENDIF»
        $menu->addChild('Reuse', [
            'route' => $routePrefix . $routeArea . 'edit',
            'routeParameters' => ['astemplate' => $entity->getKey()],
        ])
            ->setLinkAttribute(
                'title',
                'Reuse for new «name.formatForDisplay»'
            )
            «application.addLinkClass('secondary')»
            «application.addIcon('copy')»
            «IF !application.isSystemModule»
                ->setExtra('translation_domain', '«name.formatForCode»')
            «ENDIF»
        ;
        «IF tree != EntityTreeType.NONE»
            if ($this->permissionHelper->hasEntityPermission($entity, ACCESS_ADD)) {
                $menu->addChild('Add sub «name.formatForDisplay»', [
                    'route' => $routePrefix . $routeArea . 'edit',
                    'routeParameters' => ['parent' => $entity->getKey()],
                ])
                    ->setLinkAttribute(
                        'title',
                        'Add a sub «name.formatForDisplay» to this «name.formatForDisplay»'
                    )
                    «application.addLinkClass('secondary')»
                    «application.addIcon('child')»
                    «IF !application.isSystemModule»
                        ->setExtra('translation_domain', '«name.formatForCode»')
                    «ENDIF»
                ;
            }
        «ENDIF»
    '''

    def private addLinkClass(Application it, String linkClass) '''
        «IF viewActionsStyle.hasButtons && displayActionsStyle.hasButtons»
            ->setLinkAttribute('class', 'btn btn-sm btn-«linkClass»')
        «ELSEIF viewActionsStyle.hasButtons && !displayActionsStyle.hasButtons»
            ->setLinkAttribute('class', 'view' === $context ? 'btn btn-sm btn-«linkClass»' : '')
        «ELSEIF !viewActionsStyle.hasButtons && displayActionsStyle.hasButtons»
            ->setLinkAttribute('class', 'display' === $context ? 'btn btn-sm btn-«linkClass»' : '')
        «ENDIF»
    '''

    def private hasButtons(ItemActionsStyle style) {
        #[ItemActionsStyle.BUTTON, ItemActionsStyle.BUTTON_GROUP].contains(style)
    }

    def private addIcon(Application it, String icon) '''
        «IF viewActionsWithIcons && displayActionsWithIcons»
            ->setAttribute('icon', 'fas fa-«icon»')
        «ELSEIF viewActionsWithIcons && !displayActionsWithIcons»
            ->setAttribute('icon', 'view' === $context ? 'fas fa-«icon»' : '')
        «ELSEIF !viewActionsWithIcons && displayActionsWithIcons»
            ->setAttribute('icon', 'display' === $context ? 'fas fa-«icon»' : '')
        «ENDIF»
    '''
}
