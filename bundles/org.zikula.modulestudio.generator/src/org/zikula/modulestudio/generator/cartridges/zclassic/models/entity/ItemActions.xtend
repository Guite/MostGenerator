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

    // 1.3.x only
    def prepareItemActions(Entity it, Application app) '''
        /**
         * Collect available actions for this entity.
         */
        protected function prepareItemActions()
        {
            if (!empty($this->_actions)) {
                return;
            }

            $currentLegacyControllerType = FormUtil::getPassedValue('lct', 'user', 'GETPOST', FILTER_SANITIZE_STRING);
            $currentFunc = FormUtil::getPassedValue('func', 'main', 'GETPOST', FILTER_SANITIZE_STRING);
            $component = '«app.appName»:«name.formatForCodeCapital»:';
            $instance = «idFieldsAsParameterCode('this')» . '::';
            $dom = ZLanguage::getModuleDomain('«app.appName»');
            «FOR controller : app.getAdminAndUserControllers»
                if ($currentLegacyControllerType == '«controller.formattedName»') {
                    «itemActionsTargetingDisplay(app, controller)»
                    «itemActionsTargetingEdit(app, controller)»
                    «itemActionsTargetingView(app, controller)»
                    «itemActionsForAddingRelatedItems(app, controller)»
                }
            «ENDFOR»
        }
    '''

    // 1.4.x only
    def itemActionsImpl(Application app) '''
        «/* TODO this needs to be cleaned for version 0.7.1 after #260 and #715 are done */»
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
            if (in_array($currentFunc, «IF app.isLegacy»array(«ELSE»[«ENDIF»'«IF app.isLegacy»main«ELSE»index«ENDIF»', 'view'«IF app.isLegacy»)«ELSE»]«ENDIF»)) {
                «IF it.hasActions('display') && controller.tempIsAdminController && application.hasUserController && application.getMainUserController.hasActions('display')»
                    «IF app.isLegacy»
                        $this->_actions[] = array(
                            'url' => array(
                                'type' => 'user',
                                'func' => 'display',
                                'arguments' => array('ot' => '«name.formatForCode»', «routeParamsLegacy('this', false, true)»)
                            ),
                            'icon' => 'preview',
                            'linkTitle' => __('Open preview page', $dom),
                            'linkText' => __('Preview', $dom)
                        );
                    «ELSE»
                        $menu->addChild($this->__('Preview'), [
                            'route' => '«app.appName.formatForDB»_«name.formatForDB»_display',
                            'routeParameters' => [«routeParams('entity', false)»]
                        ])->setAttribute('icon', 'fa fa-search-plus');
                        $menu[$this->__('Preview')]->setLinkAttribute('target', '_blank');
                        $menu[$this->__('Preview')]->setLinkAttribute('title', $this->__('Open preview page'));
                    «ENDIF»
                «ENDIF»
                «IF it.hasActions('display') && controller.hasActions('display')»
                    «IF app.isLegacy»
                        $this->_actions[] = array(
                            'url' => array(
                                'type' => '«controller.formattedName»',
                                'func' => 'display',
                                'arguments' => array('ot' => '«name.formatForCode»', «routeParamsLegacy('this', false, true)»)
                            ),
                            'icon' => 'display',
                            'linkTitle' => str_replace('"', '', $this->getTitleFromDisplayPattern()),
                            'linkText' => __('Details', $dom)
                        );
                    «ELSE»
                        $menu->addChild($this->__('Details'), [
                            'route' => '«app.appName.formatForDB»_«name.formatForDB»_«IF controller instanceof AdminController»admin«ENDIF»display',
                            'routeParameters' => [«routeParams('entity', false)»]
                        ])->setAttribute('icon', 'fa fa-eye');
                        $menu[$this->__('Details')]->setLinkAttribute('title', str_replace('"', '', $entity->getTitleFromDisplayPattern()));
                    «ENDIF»
                «ENDIF»
            }
        «ENDIF»
    '''

    def private itemActionsTargetingEdit(Entity it, Application app, Controller controller) '''
        «IF controller.hasActions('view') || controller.hasActions('display')»
            if (in_array($currentFunc, «IF app.isLegacy»array(«ELSE»[«ENDIF»'«IF app.isLegacy»main«ELSE»index«ENDIF»', 'view', 'display'«IF app.isLegacy»)«ELSE»]«ENDIF»)) {
                «IF it.hasActions('edit') && controller.hasActions('edit')»
                    if («IF app.isLegacy»SecurityUtil::check«ELSE»$permissionApi->has«ENDIF»Permission($component, $instance, ACCESS_EDIT)) {
                        «IF ownerPermission && standardFields»
                            $uid = «IF app.isLegacy»UserUtil::getVar('uid')«ELSE»$currentUserApi->get('uid')«ENDIF»;
                            // only allow editing for the owner or people with higher permissions
                            if («IF app.isLegacy»$this«ELSE»$entity«ENDIF»->getCreatedUserId() == $uid || «IF app.isLegacy»SecurityUtil::check«ELSE»$permissionApi->has«ENDIF»Permission($component, $instance, ACCESS_ADD)) {
                                «itemActionsForEditAction(controller)»
                            }
                        «ELSE»
                            «itemActionsForEditAction(controller)»
                        «ENDIF»
                    }
                «ENDIF»
                «IF it.hasActions('delete') && controller.hasActions('delete')»
                    if («IF app.isLegacy»SecurityUtil::check«ELSE»$permissionApi->has«ENDIF»Permission($component, $instance, ACCESS_DELETE)) {
                        «IF app.isLegacy»
                            $this->_actions[] = array(
                                'url' => array(
                                    'type' => '«controller.formattedName»',
                                    'func' => 'delete',
                                    'arguments' => array('ot' => '«name.formatForCode»', «routeParamsLegacy('this', false, false)»)
                                ),
                                'icon' => 'delete',
                                'linkTitle' => __('Delete this «name.formatForDisplay»', $dom),
                                'linkText' => __('Delete', $dom)
                            );
                        «ELSE»
                            $menu->addChild($this->__('Delete'), [
                                'route' => '«app.appName.formatForDB»_«name.formatForDB»_«IF controller instanceof AdminController»admin«ENDIF»delete',
                                'routeParameters' => [«routeParams('entity', false)»]
                            ])->setAttribute('icon', 'fa fa-trash-o');
                            $menu[$this->__('Delete')]->setLinkAttribute('title', $this->__('Delete this «name.formatForDisplay»'));
                        «ENDIF»
                    }
                «ENDIF»
            }
        «ENDIF»
    '''

    def private itemActionsTargetingView(Entity it, Application app, Controller controller) '''
        «IF it.hasActions('display') && controller.hasActions('display')»
            if ($currentFunc == 'display') {
                «IF controller.hasActions('view')»
                    $title = «IF !app.isLegacy»$this->«ENDIF»__('Back to overview'«IF app.isLegacy», $dom«ENDIF»);
                    «IF app.isLegacy»
                        $this->_actions[] = array(
                            'url' => array(
                                'type' => '«controller.formattedName»',
                                'func' => 'view',
                                'arguments' => array('ot' => '«name.formatForCode»')
                            ),
                            'icon' => 'back',
                            'linkTitle' => $title,
                            'linkText' => $title
                        );
                    «ELSE»
                        $menu->addChild($title, [
                            'route' => '«app.appName.formatForDB»_«name.formatForDB»_«IF controller instanceof AdminController»admin«ENDIF»view'
                        ])->setAttribute('icon', 'fa fa-reply');
                        $menu[$title]->setLinkAttribute('title', $title);
                    «ENDIF»
                «ENDIF»
            }
        «ENDIF»
    '''

    def private itemActionsForAddingRelatedItems(Entity it, Application app, Controller controller) '''
        «val refedElems = getOutgoingJoinRelations.filter[e|e.target.application == it.application] + incoming.filter(ManyToManyRelationship).filter[e|e.source.application == it.application]»
        «IF !refedElems.empty && controller.hasActions('edit')»

            // more actions for adding new related items
            $authAdmin = «IF app.isLegacy»SecurityUtil::check«ELSE»$permissionApi->has«ENDIF»Permission($component, $instance, ACCESS_ADMIN);
            «/* TODO review the permission levels and maybe define them for each related entity
              * ACCESS_ADMIN for admin controllers else: «IF relatedEntity.workflow == EntityWorkflowType::NONE»EDIT«ELSE»COMMENT«ENDIF»
              */»
            $uid = «IF app.isLegacy»UserUtil::getVar('uid')«ELSE»$currentUserApi->get('uid')«ENDIF»;
            if ($authAdmin || (isset($uid) && «IF app.isLegacy»$this«ELSE»$entity«ENDIF»->getCreatedUserId() != '' && «IF app.isLegacy»$this«ELSE»$entity«ENDIF»->getCreatedUserId() == $uid)) {
                «FOR elem : refedElems»

                    «val useTarget = (elem.source == it)»
                    «val relationAliasName = elem.getRelationAliasName(useTarget).formatForCode.toFirstLower»
                    «val relationAliasNameParam = elem.getRelationAliasName(!useTarget).formatForCodeCapital»
                    «val otherEntity = (if (!useTarget) elem.source else elem.target)»
                    «val many = elem.isManySideDisplay(useTarget)»
                    «IF !many»
                        if (!isset(«IF app.isLegacy»$this«ELSE»$entity«ENDIF»->«relationAliasName») || null === «IF app.isLegacy»$this«ELSE»$entity«ENDIF»->«relationAliasName») {
                            $title = «IF !app.isLegacy»$this->«ENDIF»__('Create «otherEntity.name.formatForDisplay»'«IF app.isLegacy», $dom«ENDIF»);
                            «IF app.isLegacy»
                                $urlArgs = array(
                                    'ot' => '«otherEntity.name.formatForCode»',
                                    '«relationAliasNameParam.formatForDB»' => «idFieldsAsParameterCode('this')»
                                );
                                $this->_actions[] = array(
                                    'url' => array(
                                        'type' => '«controller.formattedName»',
                                        'func' => 'edit',
                                        'arguments' => $urlArgs
                                    ),
                                    'icon' => 'add',
                                    'linkTitle' => $title,
                                    'linkText' => $title
                                );
                            «ELSE»
                                $menu->addChild($title, [
                                    'route' => '«app.appName.formatForDB»_«otherEntity.name.formatForDB»_«IF controller instanceof AdminController»admin«ENDIF»edit',
                                    'routeParameters' => ['«relationAliasNameParam.formatForDB»' => «idFieldsAsParameterCode('entity')»]
                                ])->setAttribute('icon', 'fa fa-plus');
                                $menu[$title]->setLinkAttribute('title', $title);
                            «ENDIF»
                        }
                    «ELSE»
                        $title = «IF !app.isLegacy»$this->«ENDIF»__('Create «otherEntity.name.formatForDisplay»'«IF app.isLegacy», $dom«ENDIF»);
                        «IF app.isLegacy»
                            $urlArgs = array(
                                'ot' => '«otherEntity.name.formatForCode»',
                                '«relationAliasNameParam.formatForDB»' => «idFieldsAsParameterCode('this')»
                            );
                            $this->_actions[] = array(
                                'url' => array(
                                    'type' => '«controller.formattedName»',
                                    'func' => 'edit',
                                    'arguments' => $urlArgs
                                ),
                                'icon' => 'add',
                                'linkTitle' => $title,
                                'linkText' => $title
                            );
                        «ELSE»
                            $menu->addChild($title, [
                                'route' => '«app.appName.formatForDB»_«otherEntity.name.formatForDB»_«IF controller instanceof AdminController»admin«ENDIF»edit',
                                'routeParameters' => ['«relationAliasNameParam.formatForDB»' => «idFieldsAsParameterCode('entity')»]
                            ])->setAttribute('icon', 'fa fa-plus');
                            $menu[$title]->setLinkAttribute('title', $title);
                        «ENDIF»
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
            «IF application.isLegacy»
                $this->_actions[] = array(
                    'url' => array(
                        'type' => '«controller.formattedName»',
                        'func' => 'edit',
                        'arguments' => array('ot' => '«name.formatForCode»', «routeParamsLegacy('this', false, false)»)
                    ),
                    'icon' => 'edit',
                    'linkTitle' => __('Edit this «name.formatForDisplay»', $dom),
                    'linkText' => __('Edit', $dom)
                );
            «ELSE»
                $menu->addChild($this->__('Edit'), [
                    'route' => '«application.appName.formatForDB»_«name.formatForDB»_«IF controller instanceof AdminController»admin«ENDIF»edit',
                    'routeParameters' => [«routeParams('entity', false)»]
                ])->setAttribute('icon', 'fa fa-pencil-square-o');
                $menu[$this->__('Edit')]->setLinkAttribute('title', $this->__('Edit this «name.formatForDisplay»'));
            «ENDIF»
        «ENDIF»
        «IF tree == EntityTreeType.NONE»
            «IF application.isLegacy»
                $this->_actions[] = array(
                    'url' => array(
                        'type' => '«controller.formattedName»',
                        'func' => 'edit',
                        'arguments' => array('ot' => '«name.formatForCode»', «routeParamsLegacy('this', false, false, 'astemplate')»)
                    ),
                    'icon' => 'saveas',
                    'linkTitle' => __('Reuse for new «name.formatForDisplay»', $dom),
                    'linkText' => __('Reuse', $dom)
                );
            «ELSE»
                $menu->addChild($this->__('Reuse'), [
                    'route' => '«application.appName.formatForDB»_«name.formatForDB»_«IF controller instanceof AdminController»admin«ENDIF»edit',
                    'routeParameters' => [«routeParams('entity', false, 'astemplate')»]
                ])->setAttribute('icon', 'fa fa-files-o');
                $menu[$this->__('Reuse')]->setLinkAttribute('title', $this->__('Reuse for new «name.formatForDisplay»'));
            «ENDIF»
        «ENDIF»
    '''

    def private isLegacy(Application it) {
        targets('1.3.x')
    }
}
