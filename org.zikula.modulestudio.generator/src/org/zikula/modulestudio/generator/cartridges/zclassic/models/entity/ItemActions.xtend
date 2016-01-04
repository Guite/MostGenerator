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
            $currentFunc = FormUtil::getPassedValue('func', '«IF app.targets('1.3.x')»main«ELSE»index«ENDIF»', 'GETPOST', FILTER_SANITIZE_STRING);
            $component = '«app.appName»:«name.formatForCodeCapital»:';
            $instance = «idFieldsAsParameterCode('this')» . '::';
            «val appName = app.appName»
            $dom = ZLanguage::getModuleDomain('«appName»');
            «IF !app.targets('1.3.x')»
                $serviceManager = ServiceUtil::getManager();
                $permissionHelper = $serviceManager->get('zikula_permissions_module.api.permission');
            «ENDIF»
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

    def private itemActionsTargetingDisplay(Entity it, Application app, Controller controller) '''
        «IF controller.hasActions('view')»
            if (in_array($currentFunc, «IF app.targets('1.3.x')»array(«ELSE»[«ENDIF»'«IF app.targets('1.3.x')»main«ELSE»index«ENDIF»', 'view'«IF app.targets('1.3.x')»)«ELSE»]«ENDIF»)) {
                «IF controller.tempIsAdminController && application.hasUserController && application.getMainUserController.hasActions('display')»
                    $this->_actions[] = «IF app.targets('1.3.x')»array(«ELSE»[«ENDIF»
                        «IF app.targets('1.3.x')»
                            'url' => array('type' => 'user', 'func' => 'display', 'arguments' => array('ot' => '«name.formatForCode»', «routeParamsLegacy('this', false, true)»)),
                        «ELSE»
                            'url' => ['type' => '«name.formatForCode»', 'func' => 'display', 'arguments' => [«routeParams('this', false)»]],
                        «ENDIF»
                        'icon' => '«IF app.targets('1.3.x')»preview«ELSE»search-plus«ENDIF»',
                        'linkTitle' => __('Open preview page', $dom),
                        'linkText' => __('Preview', $dom)
                    «IF app.targets('1.3.x')»)«ELSE»]«ENDIF»;
                «ENDIF»
                «IF controller.hasActions('display')»
                    $this->_actions[] = «IF app.targets('1.3.x')»array(«ELSE»[«ENDIF»
                        «IF app.targets('1.3.x')»
                            'url' => array('type' => '«controller.formattedName»', 'func' => 'display', 'arguments' => array('ot' => '«name.formatForCode»', «routeParamsLegacy('this', false, true)»)),
                        «ELSE»
                            'url' => ['type' => '«name.formatForCode»', 'func' => '«IF controller instanceof AdminController»admin«ENDIF»display', 'arguments' => [«routeParams('this', false)»]],
                        «ENDIF»
                        'icon' => '«IF app.targets('1.3.x')»display«ELSE»eye«ENDIF»',
                        'linkTitle' => str_replace('"', '', $this->getTitleFromDisplayPattern())«/*__('Open detail page', $dom)*/»,
                        'linkText' => __('Details', $dom)
                    «IF app.targets('1.3.x')»)«ELSE»]«ENDIF»;
                «ENDIF»
            }
        «ENDIF»
    '''

    def private itemActionsTargetingEdit(Entity it, Application app, Controller controller) '''
        «IF controller.hasActions('view') || controller.hasActions('display')»
            if (in_array($currentFunc, «IF app.targets('1.3.x')»array(«ELSE»[«ENDIF»'«IF app.targets('1.3.x')»main«ELSE»index«ENDIF»', 'view', 'display'«IF app.targets('1.3.x')»)«ELSE»]«ENDIF»)) {
                «IF controller.hasActions('edit')»
                    if («IF app.targets('1.3.x')»SecurityUtil::check«ELSE»$permissionHelper->has«ENDIF»Permission($component, $instance, ACCESS_EDIT)) {
                        «IF ownerPermission && standardFields»
                            // only allow editing for the owner or people with higher permissions
                            if ($this['createdUserId'] == UserUtil::getVar('uid') || «IF app.targets('1.3.x')»SecurityUtil::check«ELSE»$permissionHelper->has«ENDIF»Permission($component, $instance, ACCESS_ADD)) {
                                «itemActionsForEditAction(controller)»
                            }
                        «ELSE»
                            «itemActionsForEditAction(controller)»
                        «ENDIF»
                    }
                «ENDIF»
                «IF controller.hasActions('delete')»
                    if («IF app.targets('1.3.x')»SecurityUtil::check«ELSE»$permissionHelper->has«ENDIF»Permission($component, $instance, ACCESS_DELETE)) {
                        $this->_actions[] = «IF app.targets('1.3.x')»array(«ELSE»[«ENDIF»
                            «IF app.targets('1.3.x')»
                                'url' => array('type' => '«controller.formattedName»', 'func' => 'delete', 'arguments' => array('ot' => '«name.formatForCode»', «routeParamsLegacy('this', false, false)»)),
                            «ELSE»
                                'url' => ['type' => '«name.formatForCode»', 'func' => '«IF controller instanceof AdminController»admin«ENDIF»delete', 'arguments' => [«routeParams('this', false)»]],
                            «ENDIF»
                            'icon' => '«IF app.targets('1.3.x')»delete«ELSE»trash-o«ENDIF»',
                            'linkTitle' => __('Delete', $dom),
                            'linkText' => __('Delete', $dom)
                        «IF app.targets('1.3.x')»)«ELSE»]«ENDIF»;
                    }
                «ENDIF»
            }
        «ENDIF»
    '''

    def private itemActionsTargetingView(Entity it, Application app, Controller controller) '''
        «IF controller.hasActions('display')»
            if ($currentFunc == 'display') {
                «IF controller.hasActions('view')»
                    $this->_actions[] = «IF app.targets('1.3.x')»array(«ELSE»[«ENDIF»
                        «IF app.targets('1.3.x')»
                            'url' => array('type' => '«controller.formattedName»', 'func' => 'view', 'arguments' => array('ot' => '«name.formatForCode»')),
                        «ELSE»
                            'url' => ['type' => '«name.formatForCode»', 'func' => '«IF controller instanceof AdminController»admin«ENDIF»view', 'arguments' => []],
                        «ENDIF»
                        'icon' => '«IF app.targets('1.3.x')»back«ELSE»reply«ENDIF»',
                        'linkTitle' => __('Back to overview', $dom),
                        'linkText' => __('Back to overview', $dom)
                    «IF app.targets('1.3.x')»)«ELSE»]«ENDIF»;
                «ENDIF»
            }
        «ENDIF»
    '''

    def private itemActionsForAddingRelatedItems(Entity it, Application app, Controller controller) '''
        «val refedElems = getOutgoingJoinRelations.filter[e|e.target.application == it.application] + incoming.filter(ManyToManyRelationship).filter[e|e.source.application == it.application]»
        «IF !refedElems.empty && controller.hasActions('edit')»

            // more actions for adding new related items
            $authAdmin = «IF app.targets('1.3.x')»SecurityUtil::check«ELSE»$permissionHelper->has«ENDIF»Permission($component, $instance, ACCESS_ADMIN);
            «/* TODO review the permission levels and maybe define them for each related entity
              * ACCESS_ADMIN for admin controllers else: «IF relatedEntity.workflow == EntityWorkflowType::NONE»EDIT«ELSE»COMMENT«ENDIF»
              */»
            $uid = UserUtil::getVar('uid');
            if ($authAdmin || (isset($uid) && isset($this->createdUserId) && $this->createdUserId == $uid)) {
                «FOR elem : refedElems»

                    «val useTarget = (elem.source == it)»
                    «val relationAliasName = elem.getRelationAliasName(useTarget).formatForCode.toFirstLower»
                    «val relationAliasNameParam = elem.getRelationAliasName(!useTarget).formatForCodeCapital»
                    «val otherEntity = (if (!useTarget) elem.source else elem.target)»
                    «val many = elem.isManySideDisplay(useTarget)»
                    «IF !many»
                        if (!isset($this->«relationAliasName») || $this->«relationAliasName» == null) {
                            «IF app.targets('1.3.x')»
                                $urlArgs = array('ot' => '«otherEntity.name.formatForCode»',
                                                 '«relationAliasNameParam.formatForDB»' => «idFieldsAsParameterCode('this')»);
                            «ELSE»
                                $urlArgs = ['«relationAliasNameParam.formatForDB»' => «idFieldsAsParameterCode('this')»];
                            «ENDIF»
                            if ($currentFunc == 'view') {
                                $urlArgs['returnTo'] = '«controller.formattedName»View«name.formatForCodeCapital»';
                            } elseif ($currentFunc == 'display') {
                                $urlArgs['returnTo'] = '«controller.formattedName»Display«name.formatForCodeCapital»';
                            }
                            $this->_actions[] = «IF app.targets('1.3.x')»array(«ELSE»[«ENDIF»
                                «IF app.targets('1.3.x')»
                                    'url' => array('type' => '«controller.formattedName»', 'func' => 'edit', 'arguments' => $urlArgs),
                                «ELSE»
                                    'url' => ['type' => '«otherEntity.name.formatForCode»', 'func' => '«IF controller instanceof AdminController»admin«ENDIF»edit', 'arguments' => $urlArgs],
                                «ENDIF»
                                'icon' => '«IF app.targets('1.3.x')»add«ELSE»plus«ENDIF»',
                                'linkTitle' => __('Create «otherEntity.name.formatForDisplay»', $dom),
                                'linkText' => __('Create «otherEntity.name.formatForDisplay»', $dom)
                            «IF app.targets('1.3.x')»)«ELSE»]«ENDIF»;
                        }
                    «ELSE»
                        «IF app.targets('1.3.x')»
                            $urlArgs = array('ot' => '«otherEntity.name.formatForCode»',
                                             '«relationAliasNameParam.formatForDB»' => «idFieldsAsParameterCode('this')»);
                        «ELSE»
                            $urlArgs = ['«relationAliasNameParam.formatForDB»' => «idFieldsAsParameterCode('this')»];
                        «ENDIF»
                        if ($currentFunc == 'view') {
                            $urlArgs['returnTo'] = '«controller.formattedName»View«name.formatForCodeCapital»';
                        } elseif ($currentFunc == 'display') {
                            $urlArgs['returnTo'] = '«controller.formattedName»Display«name.formatForCodeCapital»';
                        }
                        $this->_actions[] = «IF app.targets('1.3.x')»array(«ELSE»[«ENDIF»
                            «IF app.targets('1.3.x')»
                                'url' => array('type' => '«controller.formattedName»', 'func' => 'edit', 'arguments' => $urlArgs),
                            «ELSE»
                                'url' => ['type' => '«otherEntity.name.formatForCode»', 'func' => '«IF controller instanceof AdminController»admin«ENDIF»edit', 'arguments' => $urlArgs],
                            «ENDIF»
                            'icon' => '«IF app.targets('1.3.x')»add«ELSE»plus«ENDIF»',
                            'linkTitle' => __('Create «otherEntity.name.formatForDisplay»', $dom),
                            'linkText' => __('Create «otherEntity.name.formatForDisplay»', $dom)
                        «IF app.targets('1.3.x')»)«ELSE»]«ENDIF»;
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
            $this->_actions[] = «IF application.targets('1.3.x')»array(«ELSE»[«ENDIF»
                «IF application.targets('1.3.x')»
                    'url' => array('type' => '«controller.formattedName»', 'func' => 'edit', 'arguments' => array('ot' => '«name.formatForCode»', «routeParamsLegacy('this', false, false)»)),
                «ELSE»
                    'url' => ['type' => '«name.formatForCode»', 'func' => '«IF controller instanceof AdminController»admin«ENDIF»edit', 'arguments' => [«routeParams('this', false)»]],
                «ENDIF»
                'icon' => '«IF application.targets('1.3.x')»edit«ELSE»pencil-square-o«ENDIF»',
                'linkTitle' => __('Edit', $dom),
                'linkText' => __('Edit', $dom)
            «IF application.targets('1.3.x')»)«ELSE»]«ENDIF»;
        «ENDIF»
        «IF tree == EntityTreeType.NONE»
            $this->_actions[] = «IF application.targets('1.3.x')»array(«ELSE»[«ENDIF»
                «IF application.targets('1.3.x')»
                    'url' => array('type' => '«controller.formattedName»', 'func' => 'edit', 'arguments' => array('ot' => '«name.formatForCode»', «routeParamsLegacy('this', false, false, 'astemplate')»)),
                «ELSE»
                    'url' => ['type' => '«name.formatForCode»', 'func' => '«IF controller instanceof AdminController»admin«ENDIF»edit', 'arguments' => [«routeParams('this', false, 'astemplate')»]],
                «ENDIF»
                'icon' => '«IF application.targets('1.3.x')»saveas«ELSE»files-o«ENDIF»',
                'linkTitle' => __('Reuse for new item', $dom),
                'linkText' => __('Reuse', $dom)
            «IF application.targets('1.3.x')»)«ELSE»]«ENDIF»;
        «ENDIF»
    '''
}