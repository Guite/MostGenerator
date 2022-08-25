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
    Annotations annotations
    Actions actionsImpl

    new(Application app) {
        this.app = app
        annotations = new Annotations(app)
        actionsImpl = new Actions(app)
    }

    def generate(Entity it, Action action, Boolean isBase, Boolean isAdmin) '''
        «IF !isBase»
            «action.actionDoc(it, isBase, isAdmin)»
            public function «action.methodName(isAdmin)»«IF !application.targets('3.1')»Action«ENDIF»(
                «methodArguments(it, action, false)»
            ): Response {
                return $this->«action.methodName(false)»Internal(
                    «methodArgsCall(it, action, isAdmin)»
                );
            }
        «ELSEIF isBase && !isAdmin»
            «action.actionDoc(it, isBase, isAdmin)»
            protected function «action.methodName(false)»Internal(
                «methodArguments(it, action, true)»
            ): Response {
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
        «ENDIF»
        «IF isBase»
         *
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
        «IF !isBase»
            «annotations.generate(it, entity, isAdmin, false)»
        «ENDIF»
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
            ' * ' + documentation.replace('*/', '*') + (if (!documentation.endsWith('.')) '.')
        } else {
            ''
        }
    }

    def private dispatch methodName(Action it, Boolean isAdmin) '''«IF !isAdmin»«name.formatForCode.toFirstLower»«ELSE»admin«name.formatForCodeCapital»«ENDIF»'''

    def private dispatch methodName(MainAction it, Boolean isAdmin) '''«IF isAdmin»adminIndex«ELSE»index«ENDIF»'''

    def private dispatch methodArguments(Entity it, Action action, Boolean internalMethod) '''
        Request $request,
        PermissionHelper $permissionHelper«IF internalMethod»,
        bool $isAdmin = false«ENDIF»
    '''
    def private dispatch methodArgsCall(Entity it, Action action, Boolean isAdmin) {
        '''
            $request,
            $permissionHelper,
            «isAdmin.displayBool»
        '''
    }

    def private dispatch methodArguments(Entity it, ViewAction action, Boolean internalMethod) '''
        Request $request,
        RouterInterface $router,
        PermissionHelper $permissionHelper,
        ControllerHelper $controllerHelper,
        ViewHelper $viewHelper,
        «IF loggable»
            LoggableHelper $loggableHelper,
        «ENDIF»
        string $sort,
        string $sortdir,
        int $page,
        int $num«IF internalMethod»,
        bool $isAdmin = false«ENDIF»
    '''
    def private dispatch methodArgsCall(Entity it, ViewAction action, Boolean isAdmin) {
        '''
            $request,
            $router,
            $permissionHelper,
            $controllerHelper,
            $viewHelper,«IF loggable»
            $loggableHelper,«ENDIF»
            $sort,
            $sortdir,
            $page,
            $num,
            «isAdmin.displayBool»
        '''
    }

    def private dispatch methodArguments(Entity it, DisplayAction action, Boolean internalMethod) '''
        Request $request,
        PermissionHelper $permissionHelper,
        ControllerHelper $controllerHelper,
        ViewHelper $viewHelper,
        «name.formatForCodeCapital»RepositoryInterface $repository,
        «IF loggable»
            LoggableHelper $loggableHelper,
        «ENDIF»
        «IF app.generateIcsTemplates && hasStartAndEndDateField»
            EntityDisplayHelper $entityDisplayHelper,
        «ENDIF»
        ?«name.formatForCodeCapital»Entity $«name.formatForCode» = null,
        «IF hasUniqueSlug»string $slug = ''«ELSE»int $id = 0«ENDIF»«IF internalMethod»,
        bool $isAdmin = false«ENDIF»
    '''
    def private dispatch methodArgsCall(Entity it, DisplayAction action, Boolean isAdmin) {
        '''
            $request,
            $permissionHelper,
            $controllerHelper,
            $viewHelper,
            $repository,«IF loggable»
            $loggableHelper,«ENDIF»«IF app.generateIcsTemplates && hasStartAndEndDateField»
            $entityDisplayHelper,«ENDIF»
            $«name.formatForCode»,
            $«IF hasUniqueSlug»slug«ELSE»id«ENDIF»,
            «isAdmin.displayBool»
        '''
    }

    def private dispatch methodArguments(Entity it, EditAction action, Boolean internalMethod) '''
        Request $request,
        PermissionHelper $permissionHelper,
        ControllerHelper $controllerHelper,
        ViewHelper $viewHelper,
        EditHandler $formHandler«IF internalMethod»,
        bool $isAdmin = false«ENDIF»
    '''
    def private dispatch methodArgsCall(Entity it, EditAction action, Boolean isAdmin) {
        '''
            $request,
            $permissionHelper,
            $controllerHelper,
            $viewHelper,
            $formHandler,
            «isAdmin.displayBool»
        '''
    }

    def private dispatch methodArguments(Entity it, DeleteAction action, Boolean internalMethod) '''
        Request $request,
        LoggerInterface $logger,
        PermissionHelper $permissionHelper,
        ControllerHelper $controllerHelper,
        ViewHelper $viewHelper,
        «name.formatForCodeCapital»RepositoryInterface $repository,
        CurrentUserApiInterface $currentUserApi,
        WorkflowHelper $workflowHelper,
        «IF hasUniqueSlug»string $slug«ELSE»int $id«ENDIF»«IF internalMethod»,
        bool $isAdmin = false«ENDIF»
    '''
    def private dispatch methodArgsCall(Entity it, DeleteAction action, Boolean isAdmin) {
        '''
            $request,
            $logger,
            $permissionHelper,
            $controllerHelper,
            $viewHelper,
            $repository,
            $currentUserApi,
            $workflowHelper,
            $«IF hasUniqueSlug»slug«ELSE»id«ENDIF»,
            «isAdmin.displayBool»
        '''
    }

    def private hasUniqueSlug(Entity it) {
        hasSluggableFields && slugUnique
    }
}
