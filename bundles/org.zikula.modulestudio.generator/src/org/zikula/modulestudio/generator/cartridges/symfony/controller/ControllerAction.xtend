package org.zikula.modulestudio.generator.cartridges.symfony.controller

import de.guite.modulestudio.metamodel.Action
import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.CustomAction
import de.guite.modulestudio.metamodel.DeleteAction
import de.guite.modulestudio.metamodel.DetailAction
import de.guite.modulestudio.metamodel.EditAction
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.IndexAction
import org.zikula.modulestudio.generator.cartridges.symfony.controller.action.ActionRoute
import org.zikula.modulestudio.generator.cartridges.symfony.controller.action.Actions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions

class ControllerAction {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions

    ActionRoute routeAnnotation
    Actions actionsImpl

    new(Application app) {
        routeAnnotation = new ActionRoute()
        actionsImpl = new Actions(app)
    }

    def generate(Entity it, Action action, Boolean isBase) '''
        «action.actionDoc(it, isBase)»
        public function «action.methodName»(
            «methodArguments(it, action)»
        ): Response {
            «IF isBase»
                «actionsImpl.actionImpl(it, action)»
            «ELSE»
                return $this->«action.methodName»(
                    «methodArgsCall(it, action)»
                );
            «ENDIF»
        }
    '''

    def private actionDoc(Action it, Entity entity, Boolean isBase) '''
        «IF isBase»
            /**
             * «actionDocMethodDescription»
            «actionDocMethodDocumentation»
             *
             * @throws AccessDeniedException Thrown if the user doesn't have required permissions
             «IF it instanceof DetailAction»
             * @throws NotFoundHttpException Thrown if «entity.name.formatForDisplay» to be displayed isn't found
             «ELSEIF it instanceof EditAction»
             * @throws RuntimeException Thrown if another critical error occurs (e.g. workflow actions not available)
             «ELSEIF it instanceof DeleteAction»
             * @throws NotFoundHttpException Thrown if «entity.name.formatForDisplay» to be deleted isn't found
             * @throws RuntimeException Thrown if another critical error occurs (e.g. workflow actions not available)
             «ENDIF»
             «IF it instanceof IndexAction || it instanceof EditAction»
             * @throws Exception
             «ENDIF»
             */
        «ENDIF»
        «IF !isBase»
            «routeAnnotation.generate(it)»
        «ENDIF»
    '''

    def private actionDocMethodDescription(Action it) {
        switch it {
            IndexAction: 'This action provides an item list overview.'
            DetailAction: 'This action provides a item detail view.'
            EditAction: 'This action provides a handling of edit requests.'
            DeleteAction: 'This action provides a handling of simple delete requests.'
            CustomAction: 'This is a custom action.'
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

    def private methodName(Action it) '''«name.formatForCode.toFirstLower»OLD'''

    def private dispatch methodArguments(Entity it, Action action) '''
        Request $request
    '''
    def private dispatch methodArgsCall(Entity it, Action action) {
        '''
            $request
        '''
    }

    def private dispatch methodArguments(Entity it, IndexAction action) '''
        Request $request,
        RouterInterface $router,
        ControllerHelper $controllerHelper,
        ViewHelper $viewHelper,
        «IF loggable»
            LoggableHelper $loggableHelper,
        «ENDIF»
        string $sort,
        string $sortdir,
        int $page,
        int $num
    '''
    def private dispatch methodArgsCall(Entity it, IndexAction action) {
        '''
            $request,
            $router,
            $controllerHelper,
            $viewHelper,«IF loggable»
            $loggableHelper,«ENDIF»
            $sort,
            $sortdir,
            $page,
            $num
        '''
    }

    def private dispatch methodArguments(Entity it, DetailAction action) '''
        Request $request,
        ControllerHelper $controllerHelper,
        ViewHelper $viewHelper,
        «name.formatForCodeCapital»RepositoryInterface $repository,
        «IF loggable»
            LoggableHelper $loggableHelper,
        «ENDIF»
        ?«name.formatForCodeCapital» $«name.formatForCode» = null,
        «IF hasUniqueSlug»string $slug = ''«ELSE»int $id = 0«ENDIF»
    '''
    def private dispatch methodArgsCall(Entity it, DetailAction action) {
        '''
            $request,
            $controllerHelper,
            $viewHelper,
            $repository,«IF loggable»
            $loggableHelper,«ENDIF»
            $«name.formatForCode»,
            $«IF hasUniqueSlug»slug«ELSE»id«ENDIF»
        '''
    }

    def private dispatch methodArguments(Entity it, EditAction action) '''
        Request $request,
        ControllerHelper $controllerHelper,
        ViewHelper $viewHelper,
        EditHandler $formHandler
    '''
    def private dispatch methodArgsCall(Entity it, EditAction action) {
        '''
            $request,
            $controllerHelper,
            $viewHelper,
            $formHandler
        '''
    }

    def private dispatch methodArguments(Entity it, DeleteAction action) '''
        Request $request,
        LoggerInterface $logger,
        ControllerHelper $controllerHelper,
        ViewHelper $viewHelper,
        «name.formatForCodeCapital»RepositoryInterface $repository,
        WorkflowHelper $workflowHelper,
        #[CurrentUser] ?UserInterface $currentUser,
        «IF hasUniqueSlug»string $slug«ELSE»int $id«ENDIF»
    '''
    def private dispatch methodArgsCall(Entity it, DeleteAction action) {
        '''
            $request,
            $logger,
            $controllerHelper,
            $viewHelper,
            $repository,
            $workflowHelper,
            $currentUser,
            $«IF hasUniqueSlug»slug«ELSE»id«ENDIF»
        '''
    }

    def private hasUniqueSlug(Entity it) {
        hasSluggableFields && slugUnique
    }
}
