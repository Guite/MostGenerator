package org.zikula.modulestudio.generator.cartridges.zclassic.controller.action

import de.guite.modulestudio.metamodel.Action
import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.CustomAction
import de.guite.modulestudio.metamodel.DeleteAction
import de.guite.modulestudio.metamodel.DetailAction
import de.guite.modulestudio.metamodel.EditAction
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.EntityTreeType
import de.guite.modulestudio.metamodel.EntityWorkflowType
import de.guite.modulestudio.metamodel.IndexAction
import de.guite.modulestudio.metamodel.OneToManyRelationship
import de.guite.modulestudio.metamodel.OneToOneRelationship
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
        «IF action instanceof DetailAction || action instanceof DeleteAction»
            «IF action instanceof DetailAction»
                if (null === $«name.formatForCode») {
                    $«name.formatForCode» = $repository->«IF hasSluggableFields && slugUnique»selectBySlug($slug)«ELSE»selectById($id)«ENDIF»;
                }
            «ELSEIF action instanceof DeleteAction»
                $«name.formatForCode» = $repository->«IF hasSluggableFields && slugUnique»selectBySlug($slug)«ELSE»selectById($id)«ENDIF»;
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
        $permLevel = $isAdmin ? ACCESS_ADMIN : «getPermissionAccessLevel(action)»;
        «IF action instanceof IndexAction && tree != EntityTreeType.NONE»
            if (!$isAdmin && 'tree' === $request->query->getAlnum('tpl')) {
                $permLevel = ACCESS_EDIT;
            }
        «ELSEIF action instanceof DetailAction && loggable»
            $route = $request->attributes->get('_route', '');
            if (!$isAdmin && '«application.appName.formatForDB»_«name.formatForDB»_displaydeleted' === $route) {
                $permLevel = ACCESS_EDIT;
            }
        «ENDIF»
        «IF action instanceof DetailAction || action instanceof DeleteAction»
            if (!$permissionHelper->hasEntityPermission($«name.formatForCode», $permLevel)) {
                «IF ownerPermission && action instanceof DeleteAction»
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

    def private dispatch actionImplBody(Entity it, IndexAction action) '''
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
        $request->query->set('num', $num);

        $routeName = '«app.appName.formatForDB»_«name.toLowerCase»_' . ($isAdmin ? 'admin' : '') . 'index';
        $sortableColumns = new SortableColumns($router, $routeName, 'sort', 'sortdir');
        «IF tree != EntityTreeType.NONE»

            if ('tree' === $request->query->getAlnum('tpl')) {
                $templateParameters = $controllerHelper->processIndexActionParameters(
                    $objectType,
                    $sortableColumns,
                    $templateParameters
                );

                // fetch and return the appropriate template
                return $viewHelper->processTemplate($objectType, 'index', $templateParameters);
            }
        «ENDIF»

        «initSortableColumns»

        $templateParameters = $controllerHelper->processIndexActionParameters(
            $objectType,
            $sortableColumns,
            $templateParameters
        );

        // filter by permissions
        $templateParameters['items'] = $permissionHelper->filterCollection(
            $objectType,
            $templateParameters['items'],
            $permLevel
        );

        // fetch and return the appropriate template
        return $viewHelper->processTemplate($objectType, 'index', $templateParameters);
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

    def private dispatch actionImplBody(Entity it, DetailAction action) '''
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

        $templateParameters = $controllerHelper->processDetailActionParameters($objectType, $templateParameters);

        «processDisplayOutput»
    '''

    def private processDisplayOutput(Entity it) '''
        // fetch and return the appropriate template
        $response = $viewHelper->processTemplate($objectType, 'detail', $templateParameters);
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

        $templateParameters = $controllerHelper->processEditActionParameters($objectType, $templateParameters);

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

        // redirect to the «IF hasIndexAction»list of «nameMultiple.formatForDisplay»«ELSE»«primaryAction» page«ENDIF»
        $redirectRoute = '«app.appName.formatForDB»_«name.formatForDB»_' . ($isAdmin ? 'admin' : '') . '«IF hasIndexAction»index«ELSE»«primaryAction»«ENDIF»';

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
            'routeArea' => $isAdmin ? 'admin' : '',
            'deleteForm' => $form->createView(),
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
        $templateParameters = [
            'routeArea' => $isAdmin ? 'admin' : '',
        ];

        // return template
        return $this->render('@«app.vendorAndName»/«name.formatForCodeCapital»/«action.name.formatForCode.toFirstLower».html.twig', $templateParameters);
    '''
}
