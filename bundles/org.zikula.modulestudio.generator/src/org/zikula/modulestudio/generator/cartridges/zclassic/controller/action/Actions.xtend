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
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.ControllerHelperFunctions
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.GeneratorSettingsExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Actions {
    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension GeneratorSettingsExtensions = new GeneratorSettingsExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
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
            $utilArgs = ['controller' => '«name.formatForCode»', 'action' => '«action.name.formatForCode.toFirstLower»'];
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
        «IF hasViewAction»
            return $this->redirectToRoute('«app.appName.formatForDB»_«name.formatForDB»_' . ($isAdmin ? 'admin' : '') . 'view');

        «ENDIF»
        $templateParameters = [
            'routeArea' => $isAdmin ? 'admin' : ''
        ];

        // return index template
        return $this->render('@«app.appName»/«name.formatForCodeCapital»/index.html.twig', $templateParameters);
    '''

    def private dispatch actionImplBody(Entity it, ViewAction action) '''
        $repository = $this->get('«app.appService».' . $objectType . '_factory')->getRepository();
        $repository->setRequest($request);
        $viewHelper = $this->get('«app.appService».view_helper');
        $templateParameters = [
            'routeArea' => $isAdmin ? 'admin' : ''
        ];
        «IF app.hasUploads»
            $imageHelper = $this->get('«app.appService».image_helper');
        «ENDIF»
        $selectionHelper = $this->get('«app.appService».selection_helper');
        «IF tree != EntityTreeType.NONE»

            $tpl = $request->query->getAlpha('tpl', '');
            if ($tpl == 'tree') {
                $trees = $selectionHelper->getAllTrees($objectType);
                $templateParameters['trees'] = $trees;
                $templateParameters = array_merge($templateParameters, $repository->getAdditionalTemplateParameters(«IF app.hasUploads»$imageHelper, «ENDIF»'controllerAction', $utilArgs));
                «IF app.needsFeatureActivationHelper»
                    $templateParameters['featureActivationHelper'] = $this->get('«app.appService».feature_activation_helper');
                «ENDIF»
                // fetch and return the appropriate template
                return $viewHelper->processTemplate($objectType, 'view', $templateParameters);
            }
        «ENDIF»

        // convenience vars to make code clearer
        $currentUrlArgs = [];
        $where = '';

        «prepareViewUrlArgs»

        $additionalParameters = $repository->getAdditionalTemplateParameters(«IF app.hasUploads»$imageHelper, «ENDIF»'controllerAction', $utilArgs);

        $resultsPerPage = 0;
        if ($showAllEntries != 1) {
            // the number of items displayed on a page for pagination
            $resultsPerPage = $num;
            if (in_array($resultsPerPage, [0, 10])) {
                $resultsPerPage = $this->getVar($objectType . 'EntriesPerPage', 10);
            }
        }

        // parameter for used sorting field
        «new ControllerHelperFunctions().defaultSorting(action, app)»

        // parameter for used sort order
        $sortdir = strtolower($sortdir);

        «sortableColumns»

        $templateParameters['sort'] = $sort;
        $templateParameters['sortdir'] = $sortdir;
        $templateParameters['num'] = $resultsPerPage;

        $tpl = '';
        if ($request->isMethod('POST')) {
            $tpl = $request->request->getAlnum('tpl', '');
        } elseif ($request->isMethod('GET')) {
            $tpl = $request->query->getAlnum('tpl', '');
        }
        $templateParameters['tpl'] = $tpl;

        $quickNavForm = $this->createForm('«app.appNamespace»\Form\Type\QuickNavigation\\' . ucfirst($objectType) . 'QuickNavType', $templateParameters);
        if ($quickNavForm->handleRequest($request) && $quickNavForm->isSubmitted()) {
            $quickNavData = $quickNavForm->getData();
            foreach ($quickNavData as $fieldName => $fieldValue) {
                if ($fieldName == 'routeArea') {
                    continue;
                }
                if ($fieldName == 'all') {
                    $showAllEntries = $additionalUrlParameters['all'] = $templateParameters['all'] = $fieldValue;
                } elseif ($fieldName == 'own') {
                    $showOwnEntries = $additionalUrlParameters['own'] = $templateParameters['own'] = $fieldValue;
                } elseif ($fieldName == 'num') {
                    $resultsPerPage = $additionalUrlParameters['num'] = $fieldValue;
                } else {
                    // set filter as query argument, fetched inside repository
                    $request->query->set($fieldName, $fieldValue);
                }
            }
        }
        $sortableColumns->setOrderBy($sortableColumns->getColumn($sort), strtoupper($sortdir));
        $sortableColumns->setAdditionalUrlParameters($additionalUrlParameters);

        if ($showAllEntries == 1) {
            // retrieve item list without pagination
            $entities = $selectionHelper->getEntities($objectType, [], $where, $sort . ' ' . $sortdir);
        } else {
            // the current offset which is used to calculate the pagination
            $currentPage = $pos;

            // retrieve item list with pagination
            list($entities, $objectCount) = $selectionHelper->getEntitiesPaginated($objectType, $where, $sort . ' ' . $sortdir, $currentPage, $resultsPerPage);

            $templateParameters['currentPage'] = $currentPage;
            $templateParameters['pager'] = ['numitems' => $objectCount, 'itemsperpage' => $resultsPerPage];
        }

        «IF categorisable»
            $featureActivationHelper = $this->get('«app.appService».feature_activation_helper');
            if ($featureActivationHelper->isEnabled(FeatureActivationHelper::CATEGORIES, $objectType)) {
                $filteredEntities = [];
                foreach ($entities as $entity) {
                    if ($this->get('«app.appService».category_helper')->hasPermission($entity)) {
                        $filteredEntities[] = $entity;
                    }
                }
                $entities = $filteredEntities;
            }

        «ENDIF»
        foreach ($entities as $k => $entity) {
            $entity->initWorkflow();
        }
        «prepareViewItems»
    '''

    def private sortableColumns(Entity it) '''
        $sortableColumns = new SortableColumns($this->get('router'), '«app.appName.formatForDB»_«name.toLowerCase»_' . ($isAdmin ? 'admin' : '') . 'view', 'sort', 'sortdir');
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

        $additionalUrlParameters = [
            'all' => $showAllEntries,
            'own' => $showOwnEntries,
            'num' => $resultsPerPage
        ];
        foreach ($additionalParameters as $parameterName => $parameterValue) {
            if (false !== stripos($parameterName, 'thumbRuntimeOptions')) {
                continue;
            }
            $additionalUrlParameters[$parameterName] = $parameterValue;
        }
    '''

    def private addSortColumn(Entity it, String columnName) '''
        new Column('«columnName.formatForCode»'),
    '''

    def private prepareViewUrlArgs(Entity it) '''
        $showOwnEntries = $request->query->getInt('own', $this->getVar('showOnlyOwnEntries', 0));
        $showAllEntries = $request->query->getInt('all', 0);

        «IF app.generateCsvTemplates»
            if (!$showAllEntries) {
                $csv = $request->getRequestFormat() == 'csv' ? 1 : 0;
                if ($csv == 1) {
                    $showAllEntries = 1;
                }
            }

        «ENDIF»
        $templateParameters['own'] = $showAllEntries;
        $templateParameters['all'] = $showOwnEntries;
        if ($showAllEntries == 1) {
            $currentUrlArgs['all'] = 1;
        }
        if ($showOwnEntries == 1) {
            $currentUrlArgs['own'] = 1;
        }
    '''

    def private prepareViewItems(Entity it) '''
        «IF !skipHookSubscribers»

            // build RouteUrl instance for display hooks
            $currentUrlArgs['_locale'] = $request->getLocale();
            $currentUrlObject = new RouteUrl('«app.appName.formatForDB»_«name.formatForCode»_' . /*($isAdmin ? 'admin' : '') . */'view', $currentUrlArgs);
        «ENDIF»

        $templateParameters['items'] = $entities;
        $templateParameters['sort'] = $sort;
        $templateParameters['sortdir'] = $sortdir;
        $templateParameters['num'] = $resultsPerPage;
        «IF !skipHookSubscribers»
        $templateParameters['currentUrlObject'] = $currentUrlObject;
        «ENDIF»
        $templateParameters = array_merge($templateParameters, $additionalParameters);

        $templateParameters['sort'] = $sortableColumns->generateSortableColumns();
        $templateParameters['quickNavForm'] = $quickNavForm->createView();

        $templateParameters['showAllEntries'] = $templateParameters['all'];
        $templateParameters['showOwnEntries'] = $templateParameters['own'];
        «IF app.needsFeatureActivationHelper»

            $templateParameters['featureActivationHelper'] = $this->get('«app.appService».feature_activation_helper');
        «ENDIF»

        $modelHelper = $this->get('«app.appService».model_helper');
        $templateParameters['canBeCreated'] = $modelHelper->canBeCreated($objectType);

        // fetch and return the appropriate template
        return $viewHelper->processTemplate($objectType, 'view', $templateParameters);
    '''

    def private dispatch actionImplBody(Entity it, DisplayAction action) '''
        $repository = $this->get('«app.appService».' . $objectType . '_factory')->getRepository();
        $repository->setRequest($request);

        $entity = $«name.formatForCode»;

        $entity->initWorkflow();

        «prepareDisplayPermissionCheck»

        «action.permissionCheck("' . ucfirst($objectType) . '", "$instanceId . ")»
        «IF categorisable»
            $featureActivationHelper = $this->get('«app.appService».feature_activation_helper');
            if ($featureActivationHelper->isEnabled(FeatureActivationHelper::CATEGORIES, $objectType)) {
                if (!$this->get('«app.appService».category_helper')->hasPermission($entity)) {
                    throw new AccessDeniedException();
                }
            }
        «ENDIF»

        «processDisplayOutput»
    '''

    def private prepareDisplayPermissionCheck(Entity it) '''
        // «IF !skipHookSubscribers»build RouteUrl instance for display hooks; also «ENDIF»create identifier for permission check
        «IF !skipHookSubscribers»
            $currentUrlArgs = $entity->createUrlArgs();
        «ENDIF»
        $instanceId = $entity->createCompositeIdentifier();
        «IF !skipHookSubscribers»
            $currentUrlArgs['id'] = $instanceId; // TODO remove this
            $currentUrlArgs['_locale'] = $request->getLocale();
            $currentUrlObject = new RouteUrl('«app.appName.formatForDB»_«name.formatForCode»_' . /*($isAdmin ? 'admin' : '') . */'display', $currentUrlArgs);
        «ENDIF»
    '''

    def private processDisplayOutput(Entity it) '''
        $viewHelper = $this->get('«app.appService».view_helper');
        $templateParameters = [
            'routeArea' => $isAdmin ? 'admin' : ''
        ];
        $templateParameters[$objectType] = $entity;
        «IF !skipHookSubscribers»
        $templateParameters['currentUrlObject'] = $currentUrlObject;
        «ENDIF»
        «IF app.hasUploads»
            $imageHelper = $this->get('«app.appService».image_helper');
        «ENDIF»
        $templateParameters = array_merge($templateParameters, $repository->getAdditionalTemplateParameters(«IF app.hasUploads»$imageHelper, «ENDIF»'controllerAction', $utilArgs));
        «IF app.needsFeatureActivationHelper»
            $templateParameters['featureActivationHelper'] = $this->get('«app.appService».feature_activation_helper');
        «ENDIF»

        // fetch and return the appropriate template
        $response = $viewHelper->processTemplate($objectType, 'display', $templateParameters);
        «IF app.generateIcsTemplates»

            $format = $request->getRequestFormat();
            if ($format == 'ics') {
                $fileName = $objectType . '_' . (property_exists($entity, 'slug') ? $entity['slug'] : $entity->getTitleFromDisplayPattern()) . '.ics';
                $response->headers->set('Content-Disposition', 'attachment; filename=' . $fileName);
            }
        «ENDIF»

        return $response;
    '''

    def private dispatch actionImplBody(Entity it, EditAction action) '''
        $repository = $this->get('«app.appService».' . $objectType . '_factory')->getRepository();

        $templateParameters = [
            'routeArea' => $isAdmin ? 'admin' : ''
        ];
        «IF app.hasUploads»
            $imageHelper = $this->get('«app.appService».image_helper');
        «ENDIF»
        $templateParameters = array_merge($templateParameters, $repository->getAdditionalTemplateParameters(«IF app.hasUploads»$imageHelper, «ENDIF»'controllerAction', $utilArgs));

        // delegate form processing to the form handler
        $formHandler = $this->get('«app.appService».form.handler.«name.formatForDB»');
        $result = $formHandler->processForm($templateParameters);
        if ($result instanceof RedirectResponse) {
            return $result;
        }

        $viewHelper = $this->get('«app.appService».view_helper');
        $templateParameters = $formHandler->getTemplateParameters();
        «IF app.needsFeatureActivationHelper»
            $templateParameters['featureActivationHelper'] = $this->get('«app.appService».feature_activation_helper');
        «ENDIF»

        // fetch and return the appropriate template
        return $viewHelper->processTemplate($objectType, 'edit', $templateParameters);
    '''

    def private dispatch actionImplBody(Entity it, DeleteAction action) '''
        $entity = $«name.formatForCode»;

        $logger = $this->get('logger');
        $logArgs = ['app' => '«app.appName»', 'user' => $this->get('zikula_users_module.current_user')->get('uname'), 'entity' => '«name.formatForDisplay»', 'id' => $entity->createCompositeIdentifier()];

        $entity->initWorkflow();

        // determine available workflow actions
        $workflowHelper = $this->get('«app.appService».workflow_helper');
        $actions = $workflowHelper->getActionsForObject($entity);
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

        $form = $this->createForm('«app.appNamespace»\Form\DeleteEntityType', $entity);

        if ($form->handleRequest($request)->isValid()) {
            if ($form->get('delete')->isClicked()) {
                «deletionProcess(action)»
            } elseif ($form->get('cancel')->isClicked()) {
                $this->addFlash('status', $this->__('Operation cancelled.'));

                return $this->redirectToRoute($redirectRoute);
            }
        }

        $repository = $this->get('«app.appService».' . $objectType . '_factory')->getRepository();

        $viewHelper = $this->get('«app.appService».view_helper');
        $templateParameters = [
            'routeArea' => $isAdmin ? 'admin' : '',
            'deleteForm' => $form->createView()
        ];

        $templateParameters[$objectType] = $entity;
        «IF app.hasUploads»
            $imageHelper = $this->get('«app.appService».image_helper');
        «ENDIF»
        $templateParameters = array_merge($templateParameters, $repository->getAdditionalTemplateParameters(«IF app.hasUploads»$imageHelper, «ENDIF»'controllerAction', $utilArgs));

        // fetch and return the appropriate template
        return $viewHelper->processTemplate($objectType, 'delete', $templateParameters);
    '''

    def private deletionProcess(Entity it, DeleteAction action) '''
        «IF !skipHookSubscribers»
            $hookHelper = $this->get('«app.appService».hook_helper');
            // Let any hooks perform additional validation actions
            $hookType = 'validate_delete';
            $validationHooksPassed = $hookHelper->callValidationHooks($entity, $hookType);
            if ($validationHooksPassed) {
                «performDeletion(action)»
                «deletePostProcessing(action)»
            }
        «ELSE»
            «performDeletion(action)»
            «deletePostProcessing(action)»
        «ENDIF»
    '''

    def private performDeletion(Entity it, DeleteAction action) '''
        // execute the workflow action
        $success = $workflowHelper->executeAction($entity, $deleteActionId);
        if ($success) {
            $this->addFlash('status', $this->__('Done! Item deleted.'));
            $logger->notice('{app}: User {user} deleted the {entity} with id {id}.', $logArgs);
        }
    '''

    def private deletePostProcessing(Entity it, DeleteAction action) '''
        «IF !skipHookSubscribers»

            // Let any hooks know that we have deleted the «name.formatForDisplay»
            $hookType = 'process_delete';
            $hookHelper->callProcessHooks($entity, $hookType, null);
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
