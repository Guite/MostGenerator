package org.zikula.modulestudio.generator.cartridges.zclassic.controller.action

import de.guite.modulestudio.metamodel.Action
import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.CustomAction
import de.guite.modulestudio.metamodel.DeleteAction
import de.guite.modulestudio.metamodel.DisplayAction
import de.guite.modulestudio.metamodel.EditAction
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.EntityTreeType
import de.guite.modulestudio.metamodel.MainAction
import de.guite.modulestudio.metamodel.OneToManyRelationship
import de.guite.modulestudio.metamodel.OneToOneRelationship
import de.guite.modulestudio.metamodel.ViewAction
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.GeneratorSettingsExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Actions {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension GeneratorSettingsExtensions = new GeneratorSettingsExtensions
    extension ModelExtensions = new ModelExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    Application app

    new(Application app) {
        this.app = app
    }

    def actionImpl(Entity it, Action action) '''
        «IF it instanceof MainAction»
            «permissionCheck('', '')»
        «ELSE»
            // parameter specifying which type of objects we are treating
            $objectType = '«name.formatForCode»';
            $permLevel = $isAdmin ? ACCESS_ADMIN : «action.getPermissionAccessLevel»;
            «action.permissionCheck("' . ucfirst($objectType) . '", '')»
        «ENDIF»
        «actionImplBody(it, action)»
    '''

    /**
     * Permission checks in system use cases.
     */
    def private permissionCheck(Action it, String objectTypeVar, String instanceId) '''
        if (!$this->hasPermission($this->name . ':«objectTypeVar»:', «instanceId»'::', $permLevel)) {
            throw new AccessDeniedException();
        }
    '''

    def private getPermissionAccessLevel(Action it) {
        switch it {
            MainAction: 'ACCESS_OVERVIEW'
            ViewAction: 'ACCESS_READ'
            DisplayAction: 'ACCESS_READ'
            EditAction: 'ACCESS_EDIT'
            DeleteAction: 'ACCESS_DELETE'
            CustomAction: 'ACCESS_OVERVIEW'
            default: 'ACCESS_ADMIN'
        }
    }

    def private dispatch actionImplBody(Entity it, Action action) {
    }

    def private dispatch actionImplBody(Entity it, MainAction action) '''
        $templateParameters = [
            'routeArea' => $isAdmin ? 'admin' : ''
        ];

        «IF hasViewAction»
            return $this->redirectToRoute('«app.appName.formatForDB»_«name.formatForDB»_' . $templateParameters['routeArea'] . 'view');

        «ENDIF»
        // return index template
        return $this->render('@«app.appName»/«name.formatForCodeCapital»/index.html.twig', $templateParameters);
    '''

    def private dispatch actionImplBody(Entity it, ViewAction action) '''
        $templateParameters = [
            'routeArea' => $isAdmin ? 'admin' : ''
        ];
        $controllerHelper = $this->get('«app.appService».controller_helper');
        $viewHelper = $this->get('«app.appService».view_helper');

        // parameter for used sort order
        $sortdir = strtolower($sortdir);
        $request->query->set('sort', $sort);
        $request->query->set('sortdir', $sortdir);

        $sortableColumns = new SortableColumns($this->get('router'), '«app.appName.formatForDB»_«name.toLowerCase»_' . ($isAdmin ? 'admin' : '') . 'view', 'sort', 'sortdir');
        «IF tree != EntityTreeType.NONE»

            if ('tree' == $request->query->getAlnum('tpl', '')) {
                $templateParameters = $controllerHelper->processViewActionParameters($objectType, $sortableColumns, $templateParameters«IF app.hasHookSubscribers», «(!skipHookSubscribers).displayBool»«ENDIF»);

                // fetch and return the appropriate template
                return $viewHelper->processTemplate($objectType, 'view', $templateParameters);
            }
        «ENDIF»

        «initSortableColumns»

        $templateParameters = $controllerHelper->processViewActionParameters($objectType, $sortableColumns, $templateParameters«IF app.hasHookSubscribers», «(!skipHookSubscribers).displayBool»«ENDIF»);

        «IF categorisable»
            $featureActivationHelper = $this->get('«app.appService».feature_activation_helper');
            if ($featureActivationHelper->isEnabled(FeatureActivationHelper::CATEGORIES, $objectType)) {
                $templateParameters['items'] = $this->get('«app.appService».category_helper')->filterEntitiesByPermission($templateParameters['items']);
            }

        «ENDIF»
        foreach ($templateParameters['items'] as $k => $entity) {
            $entity->initWorkflow();
        }

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
        // create identifier for permission check
        $instanceId = $«name.formatForCode»->createCompositeIdentifier();
        «action.permissionCheck("' . ucfirst($objectType) . '", "$instanceId . ")»

        $«name.formatForCode»->initWorkflow();
        «IF loggable»
            $requestedVersion = $request->query->getInt('version', 0);
            if ($requestedVersion > 0) {
                // preview of a specific version is desired
                $entityManager = $this->get('«application.appService».entity_factory')->getObjectManager();
                $logEntriesRepo = $entityManager->getRepository('«application.appName»:«name.formatForCodeCapital»LogEntryEntity');
                $logEntries = $logEntriesRepo->getLogEntries($«name.formatForCode»);
                if (count($logEntries) > 1) {
                    // revert to requested version but detach to avoid persisting it
                    $logEntriesRepo->revert($«name.formatForCode», $requestedVersion);
                    $entityManager->detach($«name.formatForCode»);
                }
            }
        «ENDIF»
        $templateParameters = [
            'routeArea' => $isAdmin ? 'admin' : '',
            $objectType => $«name.formatForCode»
        ];
        «IF categorisable»

            $featureActivationHelper = $this->get('«app.appService».feature_activation_helper');
            if ($featureActivationHelper->isEnabled(FeatureActivationHelper::CATEGORIES, $objectType)) {
                if (!$this->get('«app.appService».category_helper')->hasPermission($«name.formatForCode»)) {
                    throw new AccessDeniedException();
                }
            }
        «ENDIF»

        $controllerHelper = $this->get('«app.appService».controller_helper');
        $templateParameters = $controllerHelper->processDisplayActionParameters($objectType, $templateParameters«IF app.hasHookSubscribers», «(!skipHookSubscribers).displayBool»«ENDIF»);

        «processDisplayOutput»
    '''

    def private processDisplayOutput(Entity it) '''
        // fetch and return the appropriate template
        $response = $this->get('«app.appService».view_helper')->processTemplate($objectType, 'display', $templateParameters);
        «IF app.generateIcsTemplates»

            $format = $request->getRequestFormat();
            if ($format == 'ics') {
                $fileName = $objectType . '_' . (property_exists($«name.formatForCode», 'slug') ? $«name.formatForCode»['slug'] : $«name.formatForCode»->getTitleFromDisplayPattern()) . '.ics';
                $response->headers->set('Content-Disposition', 'attachment; filename=' . $fileName);
            }
        «ENDIF»

        return $response;
    '''

    def private dispatch actionImplBody(Entity it, EditAction action) '''
        $templateParameters = [
            'routeArea' => $isAdmin ? 'admin' : ''
        ];

        $controllerHelper = $this->get('«app.appService».controller_helper');
        $templateParameters = $controllerHelper->processEditActionParameters($objectType, $templateParameters);

        // delegate form processing to the form handler
        $formHandler = $this->get('«app.appService».form.handler.«name.formatForDB»');
        $result = $formHandler->processForm($templateParameters);
        if ($result instanceof RedirectResponse) {
            return $result;
        }

        $templateParameters = $formHandler->getTemplateParameters();

        // fetch and return the appropriate template
        return $this->get('«app.appService».view_helper')->processTemplate($objectType, 'edit', $templateParameters);
    '''

    def private dispatch actionImplBody(Entity it, DeleteAction action) '''
        $logger = $this->get('logger');
        $logArgs = ['app' => '«app.appName»', 'user' => $this->get('zikula_users_module.current_user')->get('uname'), 'entity' => '«name.formatForDisplay»', 'id' => $«name.formatForCode»->createCompositeIdentifier()];

        $«name.formatForCode»->initWorkflow();

        // determine available workflow actions
        $workflowHelper = $this->get('«app.appService».workflow_helper');
        $actions = $workflowHelper->getActionsForObject($«name.formatForCode»);
        if (false === $actions || !is_array($actions)) {
            $this->addFlash('error', $this->__('Error! Could not determine workflow actions.'));
            $logger->error('{app}: User {user} tried to delete the {entity} with id {id}, but failed to determine available workflow actions.', $logArgs);
            throw new \RuntimeException($this->__('Error! Could not determine workflow actions.'));
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
            $this->addFlash('error', $this->__('Error! It is not allowed to delete this «name.formatForDisplay».'));
            $logger->error('{app}: User {user} tried to delete the {entity} with id {id}, but this action was not allowed.', $logArgs);

            return $this->redirectToRoute($redirectRoute);
        }

        $form = $this->createForm('«app.appNamespace»\Form\DeleteEntityType', $«name.formatForCode»);

        if ($form->handleRequest($request)->isValid()) {
            if ($form->get('delete')->isClicked()) {
                «deletionProcess(action)»
            } elseif ($form->get('cancel')->isClicked()) {
                $this->addFlash('status', $this->__('Operation cancelled.'));

                return $this->redirectToRoute($redirectRoute);
            }
        }

        $templateParameters = [
            'routeArea' => $isAdmin ? 'admin' : '',
            'deleteForm' => $form->createView(),
            $objectType => $«name.formatForCode»
        ];

        $controllerHelper = $this->get('«app.appService».controller_helper');
        $templateParameters = $controllerHelper->processDeleteActionParameters($objectType, $templateParameters«IF app.hasHookSubscribers», «(!skipHookSubscribers).displayBool»«ENDIF»);

        // fetch and return the appropriate template
        return $this->get('«app.appService».view_helper')->processTemplate($objectType, 'delete', $templateParameters);
    '''

    def private deletionProcess(Entity it, DeleteAction action) '''
        «IF !skipHookSubscribers»
            $hookHelper = $this->get('«app.appService».hook_helper');
            // Let any hooks perform additional validation actions
            $validationHooksPassed = $hookHelper->callValidationHooks($«name.formatForCode», 'validate_delete');
            if ($validationHooksPassed) {
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
            $this->addFlash('status', $this->__('Done! Item deleted.'));
            $logger->notice('{app}: User {user} deleted the {entity} with id {id}.', $logArgs);
        }
        «IF !skipHookSubscribers»

            // Let any hooks know that we have deleted the «name.formatForDisplay»
            $hookHelper->callProcessHooks($«name.formatForCode», 'process_delete', null);
        «ENDIF»

        return $this->redirectToRoute($redirectRoute);
    '''

    def private dispatch actionImplBody(Entity it, CustomAction action) '''
        /** TODO: custom logic */

        $templateParameters = [
            'routeArea' => $isAdmin ? 'admin' : ''
        ];

        // return template
        return $this->render('@«app.appName»/«name.formatForCodeCapital»/«action.name.formatForCode.toFirstLower».html.twig', $templateParameters);
    '''
}
