package org.zikula.modulestudio.generator.cartridges.zclassic.controller

import de.guite.modulestudio.metamodel.Action
import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.CustomAction
import de.guite.modulestudio.metamodel.DeleteAction
import de.guite.modulestudio.metamodel.DisplayAction
import de.guite.modulestudio.metamodel.EditAction
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.MainAction
import de.guite.modulestudio.metamodel.ViewAction
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.action.Actions
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.action.Annotations
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.DateTimeExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ControllerAction {

    extension ControllerExtensions = new ControllerExtensions
    extension DateTimeExtensions = new DateTimeExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension Utils = new Utils

    Application app
    Actions actionsImpl

    new(Application app) {
        this.app = app
        actionsImpl = new Actions(app)
    }

    def generate(Entity it, Action action, Boolean isBase, Boolean isAdmin) '''
        «IF !isBase»
            «action.actionDoc(it, isBase, isAdmin)»
            public function «action.methodName(isAdmin)»Action(
                «methodArguments(it, action, false)»
            )«IF app.targets('3.0')»: Response«ENDIF» {
                return $this->«action.methodName(false)»Internal(«methodArgsCall(it, action, isAdmin)»);
            }
        «ELSEIF isBase && !isAdmin»
            «action.actionDoc(it, isBase, isAdmin)»
            protected function «action.methodName(false)»Internal(
                «methodArguments(it, action, true)»
            )«IF app.targets('3.0')»: Response«ENDIF» {
                «actionsImpl.actionImpl(it, action)»
            }
        «ENDIF»
    '''

    def private actionDoc(Action it, Entity entity, Boolean isBase, Boolean isAdmin) '''
        /**
         «IF isBase»
         * «actionDocMethodDescription(isAdmin)»
         «ENDIF»
        «IF isBase»«actionDocMethodDocumentation»
        «ELSE»
        «new Annotations(app).generate(it, entity, isAdmin)»
        «ENDIF»
        «IF isBase»
         *
        «IF !app.targets('3.0')»
         * @param Request $request
        «actionDocMethodParams(entity, it)»
         *
         * @return Response Output
         *
         «ENDIF»
         * @throws AccessDeniedException Thrown if the user doesn't have required permissions
         «IF it instanceof DisplayAction»
         * @throws NotFoundHttpException Thrown if «entity.name.formatForDisplay» to be displayed isn't found
         «ELSEIF it instanceof EditAction»
         * @throws RuntimeException Thrown if another critical error occurs (e.g. workflow actions not available)
         «ELSEIF it instanceof DeleteAction»
         * @throws NotFoundHttpException Thrown if «entity.name.formatForDisplay» to be deleted isn't found
         * @throws RuntimeException Thrown if another critical error occurs (e.g. workflow actions not available)
         «ENDIF»
         «IF it instanceof ViewAction || it instanceof EditAction»
         * @throws Exception
         «ENDIF»
        «ENDIF»
         */
    '''

    def private actionDocMethodDescription(Action it, Boolean isAdmin) {
        switch it {
            MainAction: 'This is the default action handling the ' + controllerName + (if (isAdmin) ' admin' else '') + ' area called without defining arguments.'
            ViewAction: 'This action provides an item list overview' + (if (isAdmin) ' in the admin area' else '') + '.'
            DisplayAction: 'This action provides a item detail view' + (if (isAdmin) ' in the admin area' else '') + '.'
            EditAction: 'This action provides a handling of edit requests' + (if (isAdmin) ' in the admin area' else '') + '.'
            DeleteAction: 'This action provides a handling of simple delete requests' + (if (isAdmin) ' in the admin area' else '') + '.'
            CustomAction: 'This is a custom action' + (if (isAdmin) ' in the admin area' else '') + '.'
            default: ''
        }
    }

    def private actionDocMethodDocumentation(Action it) {
        if (null !== documentation && !documentation.empty) {
            ' * ' + documentation.replace('*/', '*')
        } else {
            ''
        }
    }

    def private actionDocMethodParams(Entity it, Action action) {
        if (!(action instanceof MainAction || action instanceof CustomAction)) {
            '''«actionDocAdditionalParams(action, it)»'''
        }
    }

    def private actionDocAdditionalParams(Action it, Entity refEntity) {
        switch it {
            ViewAction:
                if (app.targets('3.0')) {
                    if (refEntity.categorisable) {
                        ' * @param CategoryHelper $categoryHelper\n'
                      + ' * @param FeatureActivationHelper $featureActivationHelper\n'
                    } else {''}
                    +
                    if (refEntity.loggable) '@param LoggableHelper $loggableHelper\n' else ''
                } else {''}
               + ' * @param string $sort Sorting field\n'
               + ' * @param string $sortdir Sorting direction\n'
               + ' * @param int $pos Current pager position\n'
               + ' * @param int $num Amount of entries to display\n'
            DisplayAction:
                if (app.targets('3.0')) {
                    ' * @param EntityFactory $entityFactory\n'
                    +
                    if (refEntity.categorisable) {
                        ' * @param CategoryHelper $categoryHelper\n'
                      + ' * @param FeatureActivationHelper $featureActivationHelper\n'
                    } else {''}
                    +
                    if (refEntity.loggable) '@param LoggableHelper $loggableHelper\n' else ''
                    +
                    if (app.generateIcsTemplates && refEntity.hasStartAndEndDateField) '@param EntityDisplayHelper $entityDisplayHelper\n' else ''
                } else ''
                +
                if (refEntity.hasUniqueSlug) {
                    ' * @param string $slug Slug of treated ' + refEntity.name.formatForDisplay + ' instance\n'
                } else {
                    ' * @param int $id Identifier of treated ' + refEntity.name.formatForDisplay + ' instance\n'
                }
            EditAction:
                if (app.targets('3.0')) {
                    ' * @param EditHandler $formHandler\n'
                } else ''
            DeleteAction:
                if (app.targets('3.0')) {
                    ' * @param EntityFactory $entityFactory\n'
                  + ' * @param CurrentUserApiInterface $currentUserApi\n'
                  + ' * @param WorkflowHelper $workflowHelper\n'
                  + if (!refEntity.skipHookSubscribers) ' * @param HookHelper $hookHelper\n' else ''
                } else {
                    ''
                }
                +
                if (refEntity.hasUniqueSlug) {
                    ' * @param string $slug Slug of treated ' + refEntity.name.formatForDisplay + ' instance\n'
                } else {
                    ' * @param int $id Identifier of treated ' + refEntity.name.formatForDisplay + ' instance\n'
                }
            default: ''
        }
    }

    def private dispatch methodName(Action it, Boolean isAdmin) '''«IF !isAdmin»«name.formatForCode.toFirstLower»«ELSE»admin«name.formatForCodeCapital»«ENDIF»'''

    def private dispatch methodName(MainAction it, Boolean isAdmin) '''«IF isAdmin»adminIndex«ELSE»index«ENDIF»'''

    def private dispatch methodArguments(Entity it, Action action, Boolean internalMethod) '''
        «IF application.targets('3.0')»
            Request $request,
            PermissionHelper $permissionHelper«IF internalMethod»,
            bool $isAdmin = false«ENDIF»
        «ELSE»
            Request $request«IF internalMethod»,
            $isAdmin = false«ENDIF»
        «ENDIF»
    '''
    def private dispatch methodArgsCall(Entity it, Action action, Boolean isAdmin) {
        if (application.targets('3.0')) {
            '''$request, $permissionHelper, «isAdmin.displayBool»'''
        } else {
            '''$request, «isAdmin.displayBool»'''
        }
    }

    def private dispatch methodArguments(Entity it, ViewAction action, Boolean internalMethod) '''
        «IF application.targets('3.0')»
            Request $request,
            PermissionHelper $permissionHelper,
            ControllerHelper $controllerHelper,
            ViewHelper $viewHelper,
            «IF categorisable»
                CategoryHelper $categoryHelper,
                FeatureActivationHelper $featureActivationHelper,
            «ENDIF»
            «IF loggable»
                LoggableHelper $loggableHelper,
            «ENDIF»
            string $sort,
            string $sortdir,
            int $pos,
            int $num«IF internalMethod»,
            bool $isAdmin = false«ENDIF»
        «ELSE»
            Request $request,
            $sort,
            $sortdir,
            $pos,
            $num«IF internalMethod»,
            $isAdmin = false«ENDIF»
        «ENDIF»
    '''
    def private dispatch methodArgsCall(Entity it, ViewAction action, Boolean isAdmin) {
        if (application.targets('3.0')) {
            '''$request, $permissionHelper, $controllerHelper, $viewHelper, «IF categorisable»$categoryHelper, $featureActivationHelper, «ENDIF»«IF loggable»$loggableHelper, «ENDIF»$sort, $sortdir, $pos, $num, «isAdmin.displayBool»'''
        } else {
            '''$request, $sort, $sortdir, $pos, $num, «isAdmin.displayBool»'''
        }
    }

    def private dispatch methodArguments(Entity it, DisplayAction action, Boolean internalMethod) '''
        «IF application.targets('3.0')»
            Request $request,
            PermissionHelper $permissionHelper,
            ControllerHelper $controllerHelper,
            ViewHelper $viewHelper,
            EntityFactory $entityFactory,
            «IF categorisable»
                CategoryHelper $categoryHelper,
                FeatureActivationHelper $featureActivationHelper,
            «ENDIF»
            «IF loggable»
                LoggableHelper $loggableHelper,
            «ENDIF»
            «IF app.generateIcsTemplates && hasStartAndEndDateField»
                EntityDisplayHelper $entityDisplayHelper,
            «ENDIF»
            «name.formatForCodeCapital»Entity $«name.formatForCode» = null,
            «IF hasUniqueSlug»string $slug = ''«ELSE»int $id = 0«ENDIF»«IF internalMethod»,
            bool $isAdmin = false«ENDIF»
        «ELSE»
            Request $request,
            «name.formatForCodeCapital»Entity $«name.formatForCode» = null,
            «IF hasUniqueSlug»string $slug = ''«ELSE»int $id = 0«ENDIF»«IF internalMethod»,
            $isAdmin = false«ENDIF»
        «ENDIF»
    '''
    def private dispatch methodArgsCall(Entity it, DisplayAction action, Boolean isAdmin) {
        if (application.targets('3.0')) {
            '''$request, $permissionHelper, $controllerHelper, $viewHelper, $entityFactory, «IF categorisable»$categoryHelper, $featureActivationHelper, «ENDIF»«IF loggable»$loggableHelper, «ENDIF»«IF app.generateIcsTemplates && hasStartAndEndDateField» $entityDisplayHelper, «ENDIF»$«name.formatForCode», $«IF hasUniqueSlug»slug«ELSE»id«ENDIF», «isAdmin.displayBool»'''
        } else {
            '''$request, $«name.formatForCode», $«IF hasUniqueSlug»slug«ELSE»id«ENDIF», «isAdmin.displayBool»'''
        }
    }

    def private dispatch methodArguments(Entity it, EditAction action, Boolean internalMethod) '''
        «IF application.targets('3.0')»
            Request $request,
            PermissionHelper $permissionHelper,
            ControllerHelper $controllerHelper,
            ViewHelper $viewHelper,
            EditHandler $formHandler«IF internalMethod»,
            bool $isAdmin = false«ENDIF»
        «ELSE»
            Request $request«IF internalMethod»,
            $isAdmin = false«ENDIF»
        «ENDIF»
    '''
    def private dispatch methodArgsCall(Entity it, EditAction action, Boolean isAdmin) {
        if (application.targets('3.0')) {
            '''$request, $permissionHelper, $controllerHelper, $viewHelper, $formHandler, «isAdmin.displayBool»'''
        } else {
            '''$request, «isAdmin.displayBool»'''
        }
    }

    def private dispatch methodArguments(Entity it, DeleteAction action, Boolean internalMethod) '''
        «IF application.targets('3.0')»
            Request $request,
            PermissionHelper $permissionHelper,
            ControllerHelper $controllerHelper,
            ViewHelper $viewHelper,
            EntityFactory $entityFactory,
            CurrentUserApiInterface $currentUserApi,
            WorkflowHelper $workflowHelper,
            «IF !skipHookSubscribers»
                HookHelper $hookHelper,
            «ENDIF»
            «IF hasUniqueSlug»string $slug«ELSE»int $id«ENDIF»«IF internalMethod»,
            bool $isAdmin = false«ENDIF»
        «ELSE»
            Request $request,
            $«IF hasUniqueSlug»slug«ELSE»id«ENDIF»«IF internalMethod»,
            $isAdmin = false«ENDIF»
        «ENDIF»
    '''
    def private dispatch methodArgsCall(Entity it, DeleteAction action, Boolean isAdmin) {
        if (application.targets('3.0')) {
            '''$request, $permissionHelper, $controllerHelper, $viewHelper, $entityFactory, $currentUserApi, $workflowHelper, «IF !skipHookSubscribers»$hookHelper, «ENDIF»$«IF hasUniqueSlug»slug«ELSE»id«ENDIF», «isAdmin.displayBool»'''
        } else {
            '''$request, $«IF hasUniqueSlug»slug«ELSE»id«ENDIF», «isAdmin.displayBool»'''
        }
    }

    def private hasUniqueSlug(Entity it) {
        hasSluggableFields && slugUnique
    }
}
