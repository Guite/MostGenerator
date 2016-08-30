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
            if ($entity instanceof «entity.name.formatForCode»Entity) {
                $component = '«app.appName»:«entity.name.formatForCodeCapital»:';
                $instance = «entity.idFieldsAsParameterCode('this')» . '::';

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
                «IF controller.tempIsAdminController && application.hasUserController && application.getMainUserController.hasActions('display')»
                    «returnVar»[] = «IF app.isLegacy»array(«ELSE»[«ENDIF»
                        «IF app.isLegacy»
                            'url' => array(
                                'type' => 'user',
                                'func' => 'display',
                                'arguments' => array('ot' => '«name.formatForCode»', «routeParamsLegacy('this', false, true)»)
                            ),
                        «ELSE»
                            'url' => $this->router->generate('«app.appName.formatForDB»_«name.formatForDB»_display', [«routeParams('this', false)»]),
                        «ENDIF»
                        'icon' => '«IF app.isLegacy»preview«ELSE»search-plus«ENDIF»',
                        'linkTitle' => «IF !app.isLegacy»$this->«ENDIF»__('Open preview page'«IF app.isLegacy», $dom«ENDIF»),
                        'linkText' => «IF !app.isLegacy»$this->«ENDIF»__('Preview'«IF app.isLegacy», $dom«ENDIF»)
                    «IF app.isLegacy»)«ELSE»]«ENDIF»;
                «ENDIF»
                «IF controller.hasActions('display')»
                    «returnVar»[] = «IF app.isLegacy»array(«ELSE»[«ENDIF»
                        «IF app.isLegacy»
                            'url' => array(
                                'type' => '«controller.formattedName»',
                                'func' => 'display',
                                'arguments' => array('ot' => '«name.formatForCode»', «routeParamsLegacy('this', false, true)»)
                            ),
                        «ELSE»
                            'url' => $this->router->generate('«app.appName.formatForDB»_«name.formatForDB»_«IF controller instanceof AdminController»admin«ENDIF»display', [«routeParams('this', false)»]),
                        «ENDIF»
                        'icon' => '«IF app.isLegacy»display«ELSE»eye«ENDIF»',
                        'linkTitle' => str_replace('"', '', «entityVar»->getTitleFromDisplayPattern()),
                        'linkText' => «IF !app.isLegacy»$this->«ENDIF»__('Details'«IF app.isLegacy», $dom«ENDIF»)
                    «IF app.isLegacy»)«ELSE»]«ENDIF»;
                «ENDIF»
            }
        «ENDIF»
    '''

    def private itemActionsTargetingEdit(Entity it, Application app, Controller controller) '''
        «IF controller.hasActions('view') || controller.hasActions('display')»
            if (in_array($currentFunc, «IF app.isLegacy»array(«ELSE»[«ENDIF»'«IF app.isLegacy»main«ELSE»index«ENDIF»', 'view', 'display'«IF app.isLegacy»)«ELSE»]«ENDIF»)) {
                «IF controller.hasActions('edit')»
                    if («IF app.isLegacy»SecurityUtil::check«ELSE»$this->permissionApi->has«ENDIF»Permission($component, $instance, ACCESS_EDIT)) {
                        «IF ownerPermission && standardFields»
                            $uid = «IF app.isLegacy»UserUtil::getVar('uid')«ELSE»$this->currentUserApi->get('uid')«ENDIF»;
                            // only allow editing for the owner or people with higher permissions
                            if («entityVar»->createdUserId == $uid || «IF app.isLegacy»SecurityUtil::check«ELSE»$this->permissionApi->has«ENDIF»Permission($component, $instance, ACCESS_ADD)) {
                                «itemActionsForEditAction(controller)»
                            }
                        «ELSE»
                            «itemActionsForEditAction(controller)»
                        «ENDIF»
                    }
                «ENDIF»
                «IF controller.hasActions('delete')»
                    if («IF app.isLegacy»SecurityUtil::check«ELSE»$this->permissionApi->has«ENDIF»Permission($component, $instance, ACCESS_DELETE)) {
                        «returnVar»[] = «IF app.isLegacy»array(«ELSE»[«ENDIF»
                            «IF app.isLegacy»
                                'url' => array(
                                    'type' => '«controller.formattedName»',
                                    'func' => 'delete',
                                    'arguments' => array('ot' => '«name.formatForCode»', «routeParamsLegacy('this', false, false)»)
                                ),
                            «ELSE»
                                'url' => $this->router->generate('«app.appName.formatForDB»_«name.formatForDB»_«IF controller instanceof AdminController»admin«ENDIF»delete', [«routeParams('this', false)»]),
                            «ENDIF»
                            'icon' => '«IF app.isLegacy»delete«ELSE»trash-o«ENDIF»',
                            'linkTitle' => «IF !app.isLegacy»$this->«ENDIF»__('Delete'«IF app.isLegacy», $dom«ENDIF»),
                            'linkText' => «IF !app.isLegacy»$this->«ENDIF»__('Delete'«IF app.isLegacy», $dom«ENDIF»)
                        «IF app.isLegacy»)«ELSE»]«ENDIF»;
                    }
                «ENDIF»
            }
        «ENDIF»
    '''

    def private itemActionsTargetingView(Entity it, Application app, Controller controller) '''
        «IF controller.hasActions('display')»
            if ($currentFunc == 'display') {
                «IF controller.hasActions('view')»
                    «returnVar»[] = «IF app.isLegacy»array(«ELSE»[«ENDIF»
                        «IF app.isLegacy»
                            'url' => array(
                                'type' => '«controller.formattedName»',
                                'func' => 'view',
                                'arguments' => array('ot' => '«name.formatForCode»')
                            ),
                        «ELSE»
                            'url' => $this->router->generate('«app.appName.formatForDB»_«name.formatForDB»_«IF controller instanceof AdminController»admin«ENDIF»view'),
                        «ENDIF»
                        'icon' => '«IF app.isLegacy»back«ELSE»reply«ENDIF»',
                        'linkTitle' => «IF !app.isLegacy»$this->«ENDIF»__('Back to overview'«IF app.isLegacy», $dom«ENDIF»),
                        'linkText' => «IF !app.isLegacy»$this->«ENDIF»__('Back to overview'«IF app.isLegacy», $dom«ENDIF»)
                    «IF app.isLegacy»)«ELSE»]«ENDIF»;
                «ENDIF»
            }
        «ENDIF»
    '''

    def private itemActionsForAddingRelatedItems(Entity it, Application app, Controller controller) '''
        «val refedElems = getOutgoingJoinRelations.filter[e|e.target.application == it.application] + incoming.filter(ManyToManyRelationship).filter[e|e.source.application == it.application]»
        «IF !refedElems.empty && controller.hasActions('edit')»

            // more actions for adding new related items
            $authAdmin = «IF app.isLegacy»SecurityUtil::check«ELSE»$this->permissionApi->has«ENDIF»Permission($component, $instance, ACCESS_ADMIN);
            «/* TODO review the permission levels and maybe define them for each related entity
              * ACCESS_ADMIN for admin controllers else: «IF relatedEntity.workflow == EntityWorkflowType::NONE»EDIT«ELSE»COMMENT«ENDIF»
              */»
            $uid = «IF app.isLegacy»UserUtil::getVar('uid')«ELSE»$this->currentUserApi->get('uid')«ENDIF»;
            if ($authAdmin || (isset($uid) && isset(«entityVar»->createdUserId) && «entityVar»->createdUserId == $uid)) {
                «FOR elem : refedElems»

                    «val useTarget = (elem.source == it)»
                    «val relationAliasName = elem.getRelationAliasName(useTarget).formatForCode.toFirstLower»
                    «val relationAliasNameParam = elem.getRelationAliasName(!useTarget).formatForCodeCapital»
                    «val otherEntity = (if (!useTarget) elem.source else elem.target)»
                    «val many = elem.isManySideDisplay(useTarget)»
                    «IF !many»
                        if (!isset(«entityVar»->«relationAliasName») || null === «entityVar»->«relationAliasName») {
                            «IF app.isLegacy»
                                $urlArgs = array(
                                    'ot' => '«otherEntity.name.formatForCode»',
                                    '«relationAliasNameParam.formatForDB»' => «idFieldsAsParameterCode('this')»
                                );
                            «ELSE»
                                $urlArgs = ['«relationAliasNameParam.formatForDB»' => «idFieldsAsParameterCode('this')»];
                            «ENDIF»
                            if ($currentFunc == 'view') {
                                $urlArgs['returnTo'] = '«controller.formattedName»View«name.formatForCodeCapital»';
                            } elseif ($currentFunc == 'display') {
                                $urlArgs['returnTo'] = '«controller.formattedName»Display«name.formatForCodeCapital»';
                            }
                            «returnVar»[] = «IF app.isLegacy»array(«ELSE»[«ENDIF»
                                «IF app.isLegacy»
                                    'url' => array(
                                        'type' => '«controller.formattedName»',
                                        'func' => 'edit',
                                        'arguments' => $urlArgs
                                    ),
                                «ELSE»
                                    'url' => $this->router->generate('«app.appName.formatForDB»_«otherEntity.name.formatForDB»_«IF controller instanceof AdminController»admin«ENDIF»edit', $urlArgs),
                                «ENDIF»
                                'icon' => '«IF app.isLegacy»add«ELSE»plus«ENDIF»',
                                'linkTitle' => «IF !app.isLegacy»$this->«ENDIF»__('Create «otherEntity.name.formatForDisplay»'«IF app.isLegacy», $dom«ENDIF»),
                                'linkText' => «IF !app.isLegacy»$this->«ENDIF»__('Create «otherEntity.name.formatForDisplay»'«IF app.isLegacy», $dom«ENDIF»)
                            «IF app.isLegacy»)«ELSE»]«ENDIF»;
                        }
                    «ELSE»
                        «IF app.isLegacy»
                            $urlArgs = array(
                                'ot' => '«otherEntity.name.formatForCode»',
                                '«relationAliasNameParam.formatForDB»' => «idFieldsAsParameterCode('this')»
                            );
                        «ELSE»
                            $urlArgs = ['«relationAliasNameParam.formatForDB»' => «idFieldsAsParameterCode('this')»];
                        «ENDIF»
                        if ($currentFunc == 'view') {
                            $urlArgs['returnTo'] = '«controller.formattedName»View«name.formatForCodeCapital»';
                        } elseif ($currentFunc == 'display') {
                            $urlArgs['returnTo'] = '«controller.formattedName»Display«name.formatForCodeCapital»';
                        }
                        «returnVar»[] = «IF app.isLegacy»array(«ELSE»[«ENDIF»
                            «IF app.isLegacy»
                                'url' => array(
                                    'type' => '«controller.formattedName»',
                                    'func' => 'edit',
                                    'arguments' => $urlArgs
                                ),
                            «ELSE»
                                'url' => $this->router->generate('«app.appName.formatForDB»_«otherEntity.name.formatForDB»_«IF controller instanceof AdminController»admin«ENDIF»edit', $urlArgs),
                            «ENDIF»
                            'icon' => '«IF app.isLegacy»add«ELSE»plus«ENDIF»',
                            'linkTitle' => «IF !app.isLegacy»$this->«ENDIF»__('Create «otherEntity.name.formatForDisplay»'«IF app.isLegacy», $dom«ENDIF»),
                            'linkText' => «IF !app.isLegacy»$this->«ENDIF»__('Create «otherEntity.name.formatForDisplay»'«IF app.isLegacy», $dom«ENDIF»)
                        «IF app.isLegacy»)«ELSE»]«ENDIF»;
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
            «returnVar»[] = «IF application.isLegacy»array(«ELSE»[«ENDIF»
                «IF application.isLegacy»
                    'url' => array(
                        'type' => '«controller.formattedName»',
                        'func' => 'edit',
                        'arguments' => array('ot' => '«name.formatForCode»', «routeParamsLegacy('this', false, false)»)
                    ),
                «ELSE»
                    'url' => $this->router->generate('«application.appName.formatForDB»_«name.formatForDB»_«IF controller instanceof AdminController»admin«ENDIF»edit', [«routeParams('this', false)»]),
                «ENDIF»
                'icon' => '«IF application.isLegacy»edit«ELSE»pencil-square-o«ENDIF»',
                'linkTitle' => «IF !application.isLegacy»$this->«ENDIF»__('Edit'«IF application.isLegacy», $dom«ENDIF»),
                'linkText' => «IF !application.isLegacy»$this->«ENDIF»__('Edit'«IF application.isLegacy», $dom«ENDIF»)
            «IF application.isLegacy»)«ELSE»]«ENDIF»;
        «ENDIF»
        «IF tree == EntityTreeType.NONE»
            «returnVar»[] = «IF application.isLegacy»array(«ELSE»[«ENDIF»
                «IF application.isLegacy»
                    'url' => array(
                        'type' => '«controller.formattedName»',
                        'func' => 'edit',
                        'arguments' => array('ot' => '«name.formatForCode»', «routeParamsLegacy('this', false, false, 'astemplate')»)
                    ),
                «ELSE»
                    'url' => $this->router->generate('«application.appName.formatForDB»_«name.formatForDB»_«IF controller instanceof AdminController»admin«ENDIF»edit', [«routeParams('this', false, 'astemplate')»]),
                «ENDIF»
                'icon' => '«IF application.isLegacy»saveas«ELSE»files-o«ENDIF»',
                'linkTitle' => «IF !application.isLegacy»$this->«ENDIF»__('Reuse for new item'«IF application.isLegacy», $dom«ENDIF»),
                'linkText' => «IF !application.isLegacy»$this->«ENDIF»__('Reuse'«IF application.isLegacy», $dom«ENDIF»)
            «IF application.isLegacy»)«ELSE»]«ENDIF»;
        «ENDIF»
    '''

    def private entityVar(Entity it) '''«IF application.isLegacy»$this«ELSE»$entity«ENDIF»'''

    def private returnVar(Entity it) '''«IF application.isLegacy»$this->_actions«ELSE»$links«ENDIF»'''

    def private isLegacy(Application it) {
        targets('1.3.x')
    }
}
