package org.zikula.modulestudio.generator.cartridges.zclassic.controller.action

import de.guite.modulestudio.metamodel.Action
import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.CustomAction
import de.guite.modulestudio.metamodel.DeleteAction
import de.guite.modulestudio.metamodel.DisplayAction
import de.guite.modulestudio.metamodel.EditAction
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.EntityTreeType
import de.guite.modulestudio.metamodel.EntityWorkflowType
import de.guite.modulestudio.metamodel.MainAction
import de.guite.modulestudio.metamodel.OneToManyRelationship
import de.guite.modulestudio.metamodel.OneToOneRelationship
import de.guite.modulestudio.metamodel.ViewAction
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.DateTimeExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Actions {

    extension ControllerExtensions = new ControllerExtensions
    extension DateTimeExtensions = new DateTimeExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    Application app

    new(Application app) {
        this.app = app
    }

    def actionImpl(Entity it, Action action) '''
        «IF action instanceof DisplayAction || action instanceof DeleteAction»
            «IF action instanceof DisplayAction»
                if (null === $«name.formatForCode») {
                    $«name.formatForCode» = $entityFactory->getRepository('«name.formatForCode»')->«IF hasSluggableFields && slugUnique»selectBySlug($slug)«ELSE»selectById($id)«ENDIF»;
                }
            «ELSEIF action instanceof DeleteAction»
                $«name.formatForCode» = $entityFactory->getRepository('«name.formatForCode»')->«IF hasSluggableFields && slugUnique»selectBySlug($slug)«ELSE»selectById($id)«ENDIF»;
            «ENDIF»
            if (null === $«name.formatForCode») {
                throw new NotFoundHttpException(
                    $this->trans(
                        'No such «name.formatForDisplay» found.'«IF !application.isSystemModule»,
                        [],
                        '«name.formatForCode»'«ENDIF»
                    )
                );
            }

        «ENDIF»
        $objectType = '«name.formatForCode»';
        // permission check
        $permLevel = $isAdmin ? ACCESS_ADMIN : «getPermissionAccessLevel(action)»;
        «IF action instanceof ViewAction && tree != EntityTreeType.NONE»
            if (!$isAdmin && 'tree' === $request->query->getAlnum('tpl')) {
                $permLevel = ACCESS_EDIT;
            }
        «ELSEIF action instanceof DisplayAction && loggable»
            $route = $request->attributes->get('_route', '');
            if (!$isAdmin && '«application.appName.formatForDB»_«name.formatForDB»_displaydeleted' === $route) {
                $permLevel = ACCESS_EDIT;
            }
        «ENDIF»
        «IF action instanceof DisplayAction || action instanceof DeleteAction»
            if (!$permissionHelper->hasEntityPermission($«name.formatForCode», $permLevel)) {
                «IF ownerPermission && standardFields && action instanceof DeleteAction»
                    if ($isAdmin) {
                        throw new AccessDeniedException();
                    }
                    $currentUserId = $currentUserApi->isLoggedIn() ? $currentUserApi->get('uid') : UsersConstant::USER_ID_ANONYMOUS;
                    $isOwner = $currentUserId > 0 && null !== $«name.formatForCode»->getCreatedBy() && $currentUserId === $«name.formatForCode»->getCreatedBy()->getUid();
                    if (!$isOwner || !$permissionHelper->mayEdit($«name.formatForCode»)) {
                        throw new AccessDeniedException();
                    }
                «ELSE»
                    throw new AccessDeniedException();
                «ENDIF»
            }
        «ELSE»
            if (!$permissionHelper->hasComponentPermission($objectType, $permLevel)) {
                throw new AccessDeniedException();
            }
        «ENDIF»

        «actionImplBody(it, action)»
    '''

    def private dispatch actionImplBody(Entity it, Action action) {
    }

    def private dispatch actionImplBody(Entity it, MainAction action) '''
        $templateParameters = [
            'routeArea' => $isAdmin ? 'admin' : '',
        ];

        «IF hasViewAction»
            return $this->redirectToRoute('«app.appName.formatForDB»_«name.formatForDB»_' . $templateParameters['routeArea'] . 'view');
        «ELSE»
            // return index template
            return $this->render('@«app.appName»/«name.formatForCodeCapital»/«IF app.separateAdminTemplates»' . ($isAdmin ? 'Admin/' : '') . '«ENDIF»index.html.twig', $templateParameters);
        «ENDIF»
    '''

    def private dispatch actionImplBody(Entity it, ViewAction action) '''
        $templateParameters = [
            'routeArea' => $isAdmin ? 'admin' : '',
        ];
        «IF loggable»

            // check if deleted entities should be displayed
            $viewDeleted = $request->query->getInt('deleted');
            if (1 === $viewDeleted && $permissionHelper->hasComponentPermission('«name.formatForCode»', ACCESS_EDIT)) {
                $templateParameters['deletedEntities'] = $loggableHelper->getDeletedEntities($objectType);

                return $viewHelper->processTemplate($objectType, 'viewDeleted', $templateParameters);
            }
        «ENDIF»

        $request->query->set('sort', $sort);
        $request->query->set('sortdir', $sortdir);
        $request->query->set('page', $page);

        $routeName = '«app.appName.formatForDB»_«name.toLowerCase»_' . ($isAdmin ? 'admin' : '') . 'view';
        $sortableColumns = new SortableColumns($router, $routeName, 'sort', 'sortdir');
        «IF tree != EntityTreeType.NONE»

            if ('tree' === $request->query->getAlnum('tpl')) {
                $templateParameters = $controllerHelper->processViewActionParameters(
                    $objectType,
                    $sortableColumns,
                    $templateParameters«IF app.hasHookSubscribers»,
                    «(!skipHookSubscribers).displayBool»«ENDIF»
                );

                // fetch and return the appropriate template
                return $viewHelper->processTemplate($objectType, 'view', $templateParameters);
            }
        «ENDIF»

        «initSortableColumns»

        $templateParameters = $controllerHelper->processViewActionParameters(
            $objectType,
            $sortableColumns,
            $templateParameters«IF app.hasHookSubscribers»,
            «(!skipHookSubscribers).displayBool»«ENDIF»
        );

        // filter by permissions
        $templateParameters['items'] = $permissionHelper->filterCollection(
            «IF !app.isSystemModule»
                $objectType,
            «ENDIF»
            $templateParameters['items'],
            $permLevel
        );

        // fetch and return the appropriate template
        return $viewHelper->processTemplate($objectType, 'view', $templateParameters);
    '''

    def private initSortableColumns(Entity it) '''
        «val listItemsFields = getSortingFields»
        «val listItemsIn = incoming.filter(OneToManyRelationship).filter[bidirectional && source instanceof Entity]»
        «val listItemsOut = outgoing.filter(OneToOneRelationship).filter[target instanceof Entity]»
        $sortableColumns->addColumns([
            «FOR field : listItemsFields»
                «addSortColumn(field.name)»
            «ENDFOR»
            «FOR relation : listItemsIn»
                «addSortColumn(relation.getRelationAliasName(false))»
            «ENDFOR»
            «FOR relation : listItemsOut»
                «addSortColumn(relation.getRelationAliasName(true))»
            «ENDFOR»
            «IF geographical»
                «addSortColumn('latitude')»
                «addSortColumn('longitude')»
            «ENDIF»
            «IF standardFields»
                «addSortColumn('createdBy')»
                «addSortColumn('createdDate')»
                «addSortColumn('updatedBy')»
                «addSortColumn('updatedDate')»
            «ENDIF»
        ]);
    '''

    def private addSortColumn(Entity it, String columnName) '''
        new Column('«columnName.formatForCode»'),
    '''

    def private dispatch actionImplBody(Entity it, DisplayAction action) '''
        «IF workflow != EntityWorkflowType.NONE»
            if (
                'approved' !== $«name.formatForCode»->getWorkflowState()
                && !$permissionHelper->hasEntityPermission($«name.formatForCode», ACCESS_EDIT)
            ) {
                throw new AccessDeniedException();
            }

        «ENDIF»
        «IF loggable»
            $requestedVersion = $request->query->getInt('version');
            $versionPermLevel = $isAdmin ? ACCESS_ADMIN : ACCESS_EDIT;
            if (0 < $requestedVersion && $permissionHelper->hasEntityPermission($«name.formatForCode», $versionPermLevel)) {
                // preview of a specific version is desired, but detach entity
                $«name.formatForCode» = $loggableHelper->revert($«name.formatForCode», $requestedVersion, true);
            }

        «ENDIF»
        $templateParameters = [
            'routeArea' => $isAdmin ? 'admin' : '',
            $objectType => $«name.formatForCode»,
        ];

        $templateParameters = $controllerHelper->processDisplayActionParameters(
            $objectType,
            $templateParameters«IF app.hasHookSubscribers»,
            $«name.formatForCode»->supportsHookSubscribers()«ENDIF»
        );

        «processDisplayOutput»
    '''

    def private processDisplayOutput(Entity it) '''
        // fetch and return the appropriate template
        $response = $viewHelper->processTemplate($objectType, 'display', $templateParameters);
        «IF app.generateIcsTemplates && hasStartAndEndDateField»

            if ('ics' === $request->getRequestFormat()) {
                $fileName = $objectType . '_' .
                    (property_exists($«name.formatForCode», 'slug')
                        ? $«name.formatForCode»['slug']
                        : $entityDisplayHelper->getFormattedTitle($«name.formatForCode»)
                    ) . '.ics'
                ;
                $response->headers->set('Content-Disposition', 'attachment; filename=' . $fileName);
            }
        «ENDIF»

        return $response;
    '''

    def private dispatch actionImplBody(Entity it, EditAction action) '''
        $templateParameters = [
            'routeArea' => $isAdmin ? 'admin' : '',
        ];

        // delegate form processing to the form handler
        $result = $formHandler->processForm($templateParameters);
        if ($result instanceof RedirectResponse) {
            return $result;
        }

        $templateParameters = $formHandler->getTemplateParameters();

        $templateParameters = $controllerHelper->processEditActionParameters(
            $objectType,
            $templateParameters«IF app.hasHookSubscribers»,
            $templateParameters['«name.formatForCode»']->supportsHookSubscribers()«ENDIF»
        );

        // fetch and return the appropriate template
        return $viewHelper->processTemplate($objectType, 'edit', $templateParameters);
    '''

    def private dispatch actionImplBody(Entity it, DeleteAction action) '''
        $logArgs = ['app' => '«app.appName»', 'user' => $currentUserApi->get('uname'), 'entity' => '«name.formatForDisplay»', 'id' => $«name.formatForCode»->getKey()];

        // determine available workflow actions
        $actions = $workflowHelper->getActionsForObject($«name.formatForCode»);
        if (false === $actions || !is_array($actions)) {
            $this->addFlash('error', 'Error! Could not determine workflow actions.');
            $logger->error('{app}: User {user} tried to delete the {entity} with id {id}, but failed to determine available workflow actions.', $logArgs);
            throw new RuntimeException($this->trans('Error! Could not determine workflow actions.'));
        }

        // redirect to the «IF hasViewAction»list of «nameMultiple.formatForDisplay»«ELSE»index page«ENDIF»
        $redirectRoute = '«app.appName.formatForDB»_«name.formatForDB»_' . ($isAdmin ? 'admin' : '') . '«IF hasViewAction»view«ELSE»index«ENDIF»';

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
                «IF application.isSystemModule»
                    'Error! It is not allowed to delete this «name.formatForDisplay».'
                «ELSE»
                    $this->trans(
                        'Error! It is not allowed to delete this «name.formatForDisplay».',
                        [],
                        '«name.formatForCode»'
                    )
                «ENDIF»
            );
            $logger->error('{app}: User {user} tried to delete the {entity} with id {id}, but this action was not allowed.', $logArgs);

            return $this->redirectToRoute($redirectRoute);
        }

        $form = $this->createForm(DeletionType::class, $«name.formatForCode»);
        «IF !skipHookSubscribers»
            if ($«name.formatForCode»->supportsHookSubscribers()) {
                // call form aware display hooks
                $formHook = $hookHelper->callFormDisplayHooks($form, $«name.formatForCode», FormAwareCategory::TYPE_DELETE);
            }
        «ENDIF»

        $form->handleRequest($request);
        if ($form->isSubmitted() && $form->isValid()) {
            if ($form->get('delete')->isClicked()) {
                «deletionProcess(action)»
            } elseif ($form->get('cancel')->isClicked()) {
                $this->addFlash('status', 'Operation cancelled.');

                return $this->redirectToRoute($redirectRoute);
            }
        }

        $templateParameters = [
            'routeArea' => $isAdmin ? 'admin' : '',
            'deleteForm' => $form->createView(),
            $objectType => $«name.formatForCode»,
        ];
        «IF !skipHookSubscribers»
            if ($«name.formatForCode»->supportsHookSubscribers()) {
                $templateParameters['formHookTemplates'] = $formHook->getTemplates();
            }
        «ENDIF»

        $templateParameters = $controllerHelper->processDeleteActionParameters(
            $objectType,
            $templateParameters«IF app.hasHookSubscribers»,
            $«name.formatForCode»->supportsHookSubscribers()«ENDIF»
        );

        // fetch and return the appropriate template
        return $viewHelper->processTemplate($objectType, 'delete', $templateParameters);
    '''

    def private deletionProcess(Entity it, DeleteAction action) '''
        «IF loggable»
            $«name.formatForCode»->set_actionDescriptionForLogEntry('_HISTORY_«name.formatForCode.toUpperCase»_DELETED');
        «ENDIF»
        «IF !skipHookSubscribers»
            if ($«name.formatForCode»->supportsHookSubscribers()) {
                // let any ui hooks perform additional validation actions
                $validationErrors = $hookHelper->callValidationHooks($«name.formatForCode», UiHooksCategory::TYPE_VALIDATE_DELETE);
                if (0 < count($validationErrors)) {
                    foreach ($validationErrors as $message) {
                        $this->addFlash('error', $message);
                    }
                } else {
                    «performDeletionAndRedirect(action)»
                }
            } else {
                «performDeletionAndRedirect(action)»
            }
        «ELSE»
            «performDeletionAndRedirect(action)»
        «ENDIF»
    '''

    def private performDeletionAndRedirect(Entity it, DeleteAction action) '''
        // execute the workflow action
        $success = $workflowHelper->executeAction($«name.formatForCode», $deleteActionId);
        if ($success) {
            $this->addFlash(
                'status',
                «IF application.isSystemModule»
                    'Done! «name.formatForDisplayCapital» deleted.'
                «ELSE»
                    $this->trans(
                        'Done! «name.formatForDisplayCapital» deleted.',
                        [],
                        '«name.formatForCode»'
                    )
                «ENDIF»
            );
            $logger->notice('{app}: User {user} deleted the {entity} with id {id}.', $logArgs);
        }
        «IF !skipHookSubscribers»

            if ($«name.formatForCode»->supportsHookSubscribers()) {
                // call form aware processing hooks
                $hookHelper->callFormProcessHooks($form, $«name.formatForCode», FormAwareCategory::TYPE_PROCESS_DELETE);

                // let any ui hooks know that we have deleted the «name.formatForDisplay»
                $hookHelper->callProcessHooks($«name.formatForCode», UiHooksCategory::TYPE_PROCESS_DELETE);
            }
        «ENDIF»

        return $this->redirectToRoute($redirectRoute);
    '''

    def private dispatch actionImplBody(Entity it, CustomAction action) '''
        «/* TODO custom logic */»
        $templateParameters = [
            'routeArea' => $isAdmin ? 'admin' : '',
        ];

        // return template
        return $this->render('@«app.appName»/«name.formatForCodeCapital»/«IF app.separateAdminTemplates»' . ($isAdmin ? 'Admin/' : '') . '«ENDIF»«action.name.formatForCode.toFirstLower».html.twig', $templateParameters);
    '''
}
