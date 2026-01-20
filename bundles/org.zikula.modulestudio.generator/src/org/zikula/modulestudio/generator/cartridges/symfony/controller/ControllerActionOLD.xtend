package org.zikula.modulestudio.generator.cartridges.symfony.controller

import de.guite.modulestudio.metamodel.Action
import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.CustomAction
import de.guite.modulestudio.metamodel.DeleteAction
import de.guite.modulestudio.metamodel.DetailAction
import de.guite.modulestudio.metamodel.EditAction
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.IndexAction
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ControllerActionOLD {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension Utils = new Utils

    Application app

    new(Application app) {
        this.app = app
    }

    def generate(Entity it, Action action, Boolean isBase) '''
        «action.actionDoc(it, isBase)»
        public function «action.methodName»(
            «methodArguments(it, action)»
        ): Response {
            «IF isBase»
                «actionImpl(it, action)»
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
        «IF hasSluggableFields»string $slug = ''«ELSE»int $id = 0«ENDIF»
    '''
    def private dispatch methodArgsCall(Entity it, DetailAction action) {
        '''
            $request,
            $controllerHelper,
            $viewHelper,
            $repository,«IF loggable»
            $loggableHelper,«ENDIF»
            $«name.formatForCode»,
            $«IF hasSluggableFields»slug«ELSE»id«ENDIF»
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
        «IF hasSluggableFields»string $slug«ELSE»int $id«ENDIF»
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
            $«IF hasSluggableFields»slug«ELSE»id«ENDIF»
        '''
    }

    // TODO DeleteAction is not generated anymore
    // but kept here because of workflow usage that needs to be added to EAB

    def actionImpl(Entity it, Action action) '''
        «IF action instanceof DetailAction || action instanceof DeleteAction»
            «IF action instanceof DetailAction»
                if (null === $«name.formatForCode») {
                    $«name.formatForCode» = $repository->«IF hasSluggableFields»selectBySlug($slug)«ELSE»selectById($id)«ENDIF»;
                }
            «ELSEIF action instanceof DeleteAction»
                $«name.formatForCode» = $repository->«IF hasSluggableFields»selectBySlug($slug)«ELSE»selectById($id)«ENDIF»;
            «ENDIF»
            if (null === $«name.formatForCode») {
                throw new NotFoundHttpException(
                    $this->trans(
                        'No such «name.formatForDisplay» found.',
                        [],
                        '«name.formatForCode»'
                    )
                );
            }

        «ENDIF»
        $objectType = '«name.formatForCode»';
        // permission check
        $isAdminArea = $request->attributes->get('isAdminArea', false);
        /*$permLevel = $isAdminArea ? ACCESS_ADMIN : «getPermissionAccessLevel(action)»;
        «IF action instanceof IndexAction && tree»
            if (!$isAdminArea && 'tree' === $request->query->getAlnum('tpl')) {
                $permLevel = ACCESS_EDIT;
            }
        «ELSEIF action instanceof DetailAction && loggable»
            $route = $request->attributes->get('_route', '');
            if (!$isAdminArea && '«application.appName.formatForDB»_«name.formatForDB»_displaydeleted' === $route) {
                $permLevel = ACCESS_EDIT;
            }
        «ENDIF»
        */
        «IF action instanceof DetailAction || action instanceof DeleteAction»
            if (!$this->permissionHelper->hasEntityPermission($«name.formatForCode»/*, $permLevel*/)) {
                «IF ownerPermission && action instanceof DeleteAction»
                    if ($isAdminArea) {
                        throw new AccessDeniedException();
                    }
                    $currentUserId = $currentUser?->getId() ?? UsersConstant::USER_ID_ANONYMOUS;
                    $isOwner = 0 < $currentUserId && $currentUserId === $«name.formatForCode»->getCreatedBy()?->getId();
                    if (!$isOwner || !$this->permissionHelper->mayEdit($«name.formatForCode»)) {
                        throw new AccessDeniedException();
                    }
                «ELSE»
                    throw new AccessDeniedException();
                «ENDIF»
            }
        «ELSE»
            if (!$this->permissionHelper->hasComponentPermission($objectType/*, $permLevel*/)) {
                throw new AccessDeniedException();
            }
        «ENDIF»

        «actionImplBody(it, action)»
    '''

    def private dispatch actionImplBody(Entity it, Action action) {
    }

    def private dispatch actionImplBody(Entity it, IndexAction action) '''
        $templateParameters = [];
        «IF loggable»

            // check if deleted entities should be displayed
            $viewDeleted = $request->query->getInt('deleted');
            if (1 === $viewDeleted && $this->permissionHelper->hasComponentPermission('«name.formatForCode»'/*, ACCESS_EDIT*/)) {
                $templateParameters['deletedEntities'] = $loggableHelper->getDeletedEntities($objectType);

                return $viewHelper->processTemplate($objectType, 'viewDeleted', $templateParameters);
            }
        «ENDIF»

        $request->query->set('sort', $sort);
        $request->query->set('sortdir', $sortdir);
        $request->query->set('page', $page);
        $request->query->set('num', $num);

        $routeName = '«app.appName.formatForDB»_«name.toLowerCase»_index';
        «IF tree»

            if ('tree' === $request->query->getAlnum('tpl')) {
                $templateParameters = $controllerHelper->processIndexActionParameters(
                    $objectType,
                    $templateParameters
                );

                // fetch and return the appropriate template
                return $viewHelper->processTemplate($objectType, 'index', $templateParameters);
            }
        «ENDIF»

        $templateParameters = $controllerHelper->processIndexActionParameters(
            $objectType,
            $templateParameters
        );

        // filter by permissions
        $templateParameters['items'] = $this->permissionHelper->filterCollection(
            $objectType,
            $templateParameters['items'],
            $permLevel
        );

        // fetch and return the appropriate template
        return $viewHelper->processTemplate($objectType, 'index', $templateParameters);
    '''

    def private dispatch actionImplBody(Entity it, DetailAction action) '''
        «IF approval»
            if (
                'approved' !== $«name.formatForCode»->getWorkflowState()
                && !$this->permissionHelper->hasEntityPermission($«name.formatForCode»/*, ACCESS_EDIT*/)
            ) {
                throw new AccessDeniedException();
            }

        «ENDIF»
        «IF loggable»
            $requestedVersion = $request->query->getInt('version');
            $isAdminArea = $request->attributes->get('isAdminArea', false);
            $versionPermLevel = $isAdminArea ? ACCESS_ADMIN : ACCESS_EDIT;
            if (0 < $requestedVersion && $this->permissionHelper->hasEntityPermission($«name.formatForCode»/*, $versionPermLevel*/)) {
                // preview of a specific version is desired, but detach entity
                $«name.formatForCode» = $loggableHelper->revert($«name.formatForCode», $requestedVersion, true);
            }

        «ENDIF»
        $templateParameters = [
            $objectType => $«name.formatForCode»,
        ];

        $templateParameters = $controllerHelper->processDetailActionParameters($objectType, $templateParameters);

        «processDisplayOutput»
    '''

    def private processDisplayOutput(Entity it) '''
        // fetch and return the appropriate template
        return $viewHelper->processTemplate($objectType, 'detail', $templateParameters);
    '''

    def private dispatch actionImplBody(Entity it, EditAction action) '''
        $templateParameters = [];

        // delegate form processing to the form handler
        $result = $formHandler->processForm($templateParameters);
        if ($result instanceof RedirectResponse) {
            return $result;
        }

        $templateParameters = $formHandler->getTemplateParameters();

        $templateParameters = $controllerHelper->processEditActionParameters($objectType, $templateParameters);

        // fetch and return the appropriate template
        return $viewHelper->processTemplate($objectType, 'edit', $templateParameters);
    '''

    def private dispatch actionImplBody(Entity it, DeleteAction action) '''
        $logArgs = ['app' => '«app.appName»', 'user' => $currentUser?->getUserIdentifier(), 'entity' => '«name.formatForDisplay»', 'id' => $«name.formatForCode»->getKey()];

        // determine available workflow actions
        $actions = $workflowHelper->getActionsForObject($«name.formatForCode»);
        if (false === $actions || !is_array($actions)) {
            $this->addFlash('error', 'Error! Could not determine workflow actions.');
            $logger->error('{app}: User {user} tried to delete the {entity} with id {id}, but failed to determine available workflow actions.', $logArgs);
            throw new RuntimeException($this->trans('Error! Could not determine workflow actions.'));
        }

        // redirect to the «IF hasIndexAction»list of «nameMultiple.formatForDisplay»«ELSE»«primaryAction» page«ENDIF»
        $redirectRoute = '«app.appName.formatForDB»_«name.formatForDB»_«IF hasIndexAction»index«ELSE»«primaryAction»«ENDIF»';

        // check whether deletion is allowed
        $deleteActionId = 'delete';
        $deleteAllowed = false;
        foreach ($actions as $actionId => $action) {
            if ($actionId != $deleteActionId) {
                continue;
            }
            $deleteAllowed = true;
            break;
        }
        if (!$deleteAllowed) {
            $this->addFlash(
                'error',
                $this->trans(
                    'Error! It is not allowed to delete this «name.formatForDisplay».',
                    [],
                    '«name.formatForCode»'
                )
            );
            $logger->error('{app}: User {user} tried to delete the {entity} with id {id}, but this action was not allowed.', $logArgs);

            return $this->redirectToRoute($redirectRoute);
        }

        $form = $this->createForm(DeletionType::class, $«name.formatForCode»);

        $form->handleRequest($request);
        if ($form->isSubmitted()«/* && $form->isValid() - also allow deletion of entities that are not valid */») {
            if ($form->get('delete')->isClicked()) {
                «deletionProcess(action)»
            } elseif ($form->get('cancel')->isClicked()) {
                $this->addFlash('status', 'Operation cancelled.');

                return $this->redirectToRoute($redirectRoute);
            }
        }

        $templateParameters = [
            'deleteForm' => $form,
            $objectType => $«name.formatForCode»,
        ];

        $templateParameters = $controllerHelper->processDeleteActionParameters($objectType, $templateParameters);

        // fetch and return the appropriate template
        return $viewHelper->processTemplate($objectType, 'delete', $templateParameters);
    '''

    def private deletionProcess(Entity it, DeleteAction action) '''
        «IF loggable»
            $«name.formatForCode»->set_actionDescriptionForLogEntry('_HISTORY_«name.formatForCode.toUpperCase»_DELETED');
        «ENDIF»
        «performDeletionAndRedirect(action)»
    '''

    def private performDeletionAndRedirect(Entity it, DeleteAction action) '''
        // execute the workflow action
        $success = $workflowHelper->executeAction($«name.formatForCode», $deleteActionId);
        if ($success) {
            $this->addFlash(
                'status',
                $this->trans(
                    'Done! «name.formatForDisplayCapital» deleted.',
                    [],
                    '«name.formatForCode»'
                )
            );
            $logger->notice('{app}: User {user} deleted the {entity} with id {id}.', $logArgs);
        }

        return $this->redirectToRoute($redirectRoute);
    '''

    def private dispatch actionImplBody(Entity it, CustomAction action) '''
        «/* TODO custom logic */»
        $templateParameters = [];

        // return template
        return $this->render('@«app.vendorAndName»/«name.formatForCodeCapital»/«action.name.formatForCode.toFirstLower».html.twig', $templateParameters);
    '''
}
