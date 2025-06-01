package org.zikula.modulestudio.generator.cartridges.symfony.controller.menu

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.ManyToManyRelationship
import de.guite.modulestudio.metamodel.ManyToOneRelationship
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ItemActions {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelJoinExtensions = new ModelJoinExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    def actionsImpl(Application it) '''
        «IF (!entities.filter[ownerPermission].empty && (hasEditActions || hasDeleteActions)) || !relations.empty»
            $currentUserId = $this->security->getUser()?->getId() ?? UsersConstant::USER_ID_ANONYMOUS;
        «ENDIF»
        «FOR entity : entities»
            if ($entity instanceof «entity.name.formatForCodeCapital»Entity) {
                «entity.actionsImpl»
            }
        «ENDFOR»
    '''

    def private actionsImpl(Entity it) '''
        $routePrefix = '«application.appName.formatForDB»_«name.formatForDB»_';
        «IF (ownerPermission && (hasEditAction || hasDeleteAction)) || (standardFields && !application.relations.empty)»
            $isOwner = 0 < $currentUserId && $currentUserId === $entity->getCreatedBy()?->getId();
        «ENDIF»
        «IF hasDetailAction || hasEditAction || loggable || hasDeleteAction»

        «ENDIF»
        «itemActionsTargetingDisplay(application)»
        «itemActionsTargetingEdit(application)»
        «itemActionsTargetingView(application)»
        «itemActionsForAddingRelatedItems(application)»
    '''

    def private itemActionsTargetingDisplay(Entity it, Application app) '''
        «IF hasDetailAction»
            if ('admin' === $routeArea) {
                $previewRouteParameters = $entity->createUrlArgs();
                $previewRouteParameters['preview'] = 1;
                $menu->addChild('Preview', [
                    'route' => $routePrefix . 'detail',
                    'routeParameters' => $previewRouteParameters,
                ])
                    ->setLinkAttribute('target', '_blank')
                    ->setLinkAttribute('title', 'Open preview page')
                    «app.addLinkClass('secondary')»
                    «app.addIcon('search-plus')»
                ;
            }
            if ('detail' !== $context) {
                $entityTitle = $this->entityDisplayHelper->getFormattedTitle($entity);
                $menu->addChild('Details', [
                    'route' => $routePrefix . 'detail',
                    'routeParameters' => $entity->createUrlArgs(),
                ])
                    ->setLinkAttribute('title', str_replace('"', '', $entityTitle))
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
                    if ($isOwner || $this->permissionHelper->hasEntityPermission($entity/*, ACCESS_ADD*/)) {
                        «itemActionsForEditAction»
                    }
                «ELSE»
                    «itemActionsForEditAction»
                «ENDIF»
            }
        «ENDIF»
        «IF loggable»
            if ($this->permissionHelper->mayAccessHistory($entity)) {
                if (in_array($context, ['index', 'detail'], true) && $this->loggableHelper->hasHistoryItems($entity)) {
                    $menu->addChild('History', [
                        'route' => $routePrefix . 'loggablehistory',
                        'routeParameters' => $entity->createUrlArgs(),
                    ])
                        ->setLinkAttribute('title', 'Watch version history')
                        «app.addLinkClass('secondary')»
                        «app.addIcon('history')»
                    ;
                }
            }
        «ENDIF»
        «IF hasDeleteAction»
            if ($this->permissionHelper->mayDelete($entity)«IF ownerPermission» || ($isOwner && $this->permissionHelper->mayEdit($entity))«ENDIF») {
                $menu->addChild('Delete', [
                    'route' => $routePrefix . 'delete',
                    'routeParameters' => $entity->createUrlArgs(),
                ])
                    ->setLinkAttribute('title', 'Delete this «name.formatForDisplay»')
                    «app.addLinkClass('danger')»
                    «app.addIcon('trash-alt')»
                    ->setExtra('translation_domain', '«name.formatForCode»')
                ;
            }
        «ENDIF»
    '''

    def private itemActionsTargetingView(Entity it, Application app) '''
        «IF hasDetailAction && hasIndexAction»
            if ('detail' === $context) {
                $menu->addChild('«nameMultiple.formatForDisplayCapital» list', [
                    'route' => $routePrefix . 'index',
                ])
                    «app.addLinkClass('secondary')»
                    «app.addIcon('reply')»
                    ->setExtra('translation_domain', '«name.formatForCode»')
                ;
            }
        «ENDIF»
    '''

    def private itemActionsForAddingRelatedItems(Entity it, Application app) '''
        «val refedElems = getCommonRelations(false).filter[r|r.target.hasEditAction && !(r instanceof ManyToOneRelationship)]
            + incoming.filter(ManyToManyRelationship).filter[r|r.bidirectional && r.source.application == it.application && r.source.hasEditAction]»
        «IF !refedElems.empty»

            // more actions for adding new related items
            «FOR elem : refedElems»
                «val useTarget = (elem.source == it)»
                «val relationAliasName = elem.getRelationAliasName(useTarget).formatForCodeCapital»
                «val relationAliasNameParam = elem.getRelationAliasName(!useTarget)»
                «val otherEntity = (if (!useTarget) elem.source else elem.target)»

                if («IF standardFields»$isOwner || «ENDIF»$this->permissionHelper->hasComponentPermission('«otherEntity.name.formatForCode»', ACCESS_«IF otherEntity.ownerPermission»ADD«ELSEIF !otherEntity.approval»EDIT«ELSE»COMMENT«ENDIF»)) {
                    «val many = elem.isManySideDisplay(useTarget)»
                    «IF !many»
                        if (null === $entity->get«relationAliasName»()) {
                            $menu->addChild('Create «elem.getRelationAliasName(useTarget).formatForDisplay»', [
                                'route' => '«app.appName.formatForDB»_«otherEntity.name.formatForDB»_' . 'edit',
                                'routeParameters' => ['«relationAliasNameParam»' => $entity->«IF hasSluggableFields»getSlug()«ELSE»getKey()«ENDIF»],
                            ])
                                «app.addLinkClass('secondary')»
                                «app.addIcon('plus')»
                                ->setExtra('translation_domain', '«name.formatForCode»')
                            ;
                        }
                    «ELSE»
                        $menu->addChild('Create «elem.getRelationAliasName(useTarget).formatForDisplay»', [
                            'route' => '«app.appName.formatForDB»_«otherEntity.name.formatForDB»_' . 'edit',
                            'routeParameters' => ['«relationAliasNameParam»' => $entity->«IF hasSluggableFields»getSlug()«ELSE»getKey()«ENDIF»],
                        ])
                            «app.addLinkClass('secondary')»
                            «app.addIcon('plus')»
                            ->setExtra('translation_domain', '«name.formatForCode»')
                        ;
                    «ENDIF»
                }
            «ENDFOR»
        «ENDIF»
    '''

    def private itemActionsForEditAction(Entity it) '''
        $menu->addChild('Edit', [
            'route' => $routePrefix . 'edit',
            'routeParameters' => $entity->createUrlArgs(«IF hasSluggableFields»true«ENDIF»),
        ])
            ->setLinkAttribute('title', 'Edit this «name.formatForDisplay»')
            «application.addLinkClass('secondary')»
            «application.addIcon('edit')»
            ->setExtra('translation_domain', '«name.formatForCode»')
        ;
        $menu->addChild('Reuse', [
            'route' => $routePrefix . 'edit',
            'routeParameters' => ['astemplate' => $entity->getKey()],
        ])
            ->setLinkAttribute('title', 'Reuse for new «name.formatForDisplay»')
            «application.addLinkClass('secondary')»
            «application.addIcon('copy')»
            ->setExtra('translation_domain', '«name.formatForCode»')
        ;
        «IF tree»
            if ($this->permissionHelper->hasEntityPermission($entity/*, ACCESS_ADD*/)) {
                $menu->addChild('Add sub «name.formatForDisplay»', [
                    'route' => $routePrefix . 'edit',
                    'routeParameters' => ['parent' => $entity->getKey()],
                ])
                    ->setLinkAttribute(
                        'title',
                        'Add a sub «name.formatForDisplay» to this «name.formatForDisplay»'
                    )
                    «application.addLinkClass('secondary')»
                    «application.addIcon('child')»
                    ->setExtra('translation_domain', '«name.formatForCode»')
                ;
            }
        «ENDIF»
    '''

    def private addLinkClass(Application it, String linkClass) '''
        ->setLinkAttribute('class', 'btn btn-sm btn-«linkClass»')
    '''

    def private addIcon(Application it, String icon) '''
        ->setAttribute('icon', 'fas fa-«icon»')
    '''
}
