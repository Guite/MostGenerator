package org.zikula.modulestudio.generator.cartridges.zclassic.models.entity

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.EntityTreeType
import de.guite.modulestudio.metamodel.EntityWorkflowType
import de.guite.modulestudio.metamodel.ItemActionsStyle
import de.guite.modulestudio.metamodel.ManyToManyRelationship
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
        «IF app.hasEditActions || !app.relations.empty»
            $currentUserId = $currentUserApi->isLoggedIn() ? $currentUserApi->get('uid') : UsersConstant::USER_ID_ANONYMOUS;
        «ENDIF»
        «FOR entity : app.getAllEntities»
            if ($entity instanceof «entity.name.formatForCodeCapital»Entity) {
                $component = '«app.appName»:«entity.name.formatForCodeCapital»:';
                $instance = $entity->getKey() . '::';
                $routePrefix = '«app.appName.formatForDB»_«entity.name.formatForDB»_';
                «IF (entity.hasEditAction && entity.ownerPermission) || (entity.standardFields && !app.relations.empty)»
                    $isOwner = $currentUserId > 0 && null !== $entity->getCreatedBy() && $currentUserId == $entity->getCreatedBy()->getUid();
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
                $title = $this->__('Preview', '«app.appName.formatForDB»');
                $menu->addChild($title, [
                    'route' => $routePrefix . 'display',
                    'routeParameters' => $entity->createUrlArgs()
                ]);
                $menu[$title]->setLinkAttribute('target', '_blank');
                $menu[$title]->setLinkAttribute('title', $this->__('Open preview page', '«app.appName.formatForDB»'));
                «app.addLinkClass('default')»
                «app.addIcon('search-plus')»
            }
            if ($context != 'display') {
                $title = $this->__('Details', '«app.appName.formatForDB»');
                $menu->addChild($title, [
                    'route' => $routePrefix . $routeArea . 'display',
                    'routeParameters' => $entity->createUrlArgs()
                ]);
                $menu[$title]->setLinkAttribute('title', str_replace('"', '', $entityDisplayHelper->getFormattedTitle($entity)));
                «app.addLinkClass('default')»
                «app.addIcon('eye')»
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
                «IF loggable»
                    if (in_array($context, ['view', 'display'])) {
                        $logEntriesRepo = $this->container->get('«app.appService».entity_factory')->getObjectManager()->getRepository('«app.appName»:«name.formatForCodeCapital»LogEntryEntity');
                        $logEntries = $logEntriesRepo->getLogEntries($entity);
                        if (count($logEntries) > 1) {
                            $title = $this->__('History', '«app.appName.formatForDB»');
                            $menu->addChild($title, [
                                'route' => $routePrefix . $routeArea . 'loggablehistory',
                                'routeParameters' => $entity->createUrlArgs()
                            ]);
                            $menu[$title]->setLinkAttribute('title', $this->__('Watch version history', '«app.appName.formatForDB»'));
                            «app.addLinkClass('default')»
                            «app.addIcon('history')»
                        }
                    }
                «ENDIF»
            }
        «ENDIF»
        «IF hasDeleteAction»
            if ($permissionApi->hasPermission($component, $instance, ACCESS_DELETE)) {
                $title = $this->__('Delete', '«app.appName.formatForDB»');
                $menu->addChild($title, [
                    'route' => $routePrefix . $routeArea . 'delete',
                    'routeParameters' => $entity->createUrlArgs()
                ]);
                $menu[$title]->setLinkAttribute('title', $this->__('Delete this «name.formatForDisplay»', '«app.appName.formatForDB»'));
                «app.addLinkClass('danger')»
                «app.addIcon('trash-o')»
            }
        «ENDIF»
    '''

    def private itemActionsTargetingView(Entity it, Application app) '''
        «IF hasDisplayAction && hasViewAction»
            if ($context == 'display') {
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
        «val refedElems = getOutgoingJoinRelations.filter[r|r.target.application == it.application && r.target instanceof Entity && (r.target as Entity).hasEditAction]
            + incoming.filter(ManyToManyRelationship).filter[r|r.source.application == it.application && r.source instanceof Entity && (r.source as Entity).hasEditAction]»
        «IF !refedElems.empty»

            // more actions for adding new related items
            «FOR elem : refedElems»
                «val useTarget = (elem.source == it)»
                «val relationAliasName = elem.getRelationAliasName(useTarget).formatForCode.toFirstLower»
                «val relationAliasNameParam = elem.getRelationAliasName(!useTarget)»
                «val otherEntity = (if (!useTarget) elem.source else elem.target)»

                $relatedComponent = '«app.appName»:«otherEntity.name.formatForCodeCapital»:';
                $relatedInstance = $entity->getKey() . '::';
                if («IF standardFields»$isOwner || «ENDIF»$permissionApi->hasPermission($relatedComponent, $relatedInstance, ACCESS_«IF (otherEntity as Entity).ownerPermission»ADD«ELSEIF (otherEntity as Entity).workflow == EntityWorkflowType.NONE»EDIT«ELSE»COMMENT«ENDIF»)) {
                    «val many = elem.isManySideDisplay(useTarget)»
                    «IF !many»
                        if (!isset($entity->«relationAliasName») || null === $entity->«relationAliasName») {
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
                            'routeParameters' => ['«relationAliasNameParam»' => $entity->getKey()]
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
                'routeParameters' => $entity->createUrlArgs()
            ]);
            $menu[$title]->setLinkAttribute('title', $this->__('Edit this «name.formatForDisplay»', '«application.appName.formatForDB»'));
            «application.addLinkClass('default')»
            «application.addIcon('pencil-square-o')»
        «ENDIF»
        «IF tree == EntityTreeType.NONE»
            $title = $this->__('Reuse', '«application.appName.formatForDB»');
            $menu->addChild($title, [
                'route' => $routePrefix . $routeArea . 'edit',
                'routeParameters' => ['astemplate' => $entity->getKey()]
            ]);
            $menu[$title]->setLinkAttribute('title', $this->__('Reuse for new «name.formatForDisplay»', '«application.appName.formatForDB»'));
            «application.addLinkClass('default')»
            «application.addIcon('files-o')»
        «ENDIF»
    '''

    def private addLinkClass(Application it, String linkClass) '''
        «IF viewActionsStyle.hasButtons && displayActionsStyle.hasButtons»
            $menu[$title]->setLinkAttribute('class', 'btn btn-sm btn-«linkClass»');
        «ELSEIF viewActionsStyle.hasButtons && !displayActionsStyle.hasButtons»
            if ($context == 'view') {
                $menu[$title]->setLinkAttribute('class', 'btn btn-sm btn-«linkClass»');
            }
        «ELSEIF !viewActionsStyle.hasButtons && displayActionsStyle.hasButtons»
            if ($context == 'display') {
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
            if ($context == 'view') {
                $menu[$title]->setAttribute('icon', 'fa fa-«icon»');
            }
        «ELSEIF !viewActionsWithIcons && displayActionsWithIcons»
            if ($context == 'display') {
                $menu[$title]->setAttribute('icon', 'fa fa-«icon»');
            }
        «ENDIF»
    '''
}
