package org.zikula.modulestudio.generator.cartridges.zclassic.controller

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Action
import de.guite.modulestudio.metamodel.modulestudio.AdminController
import de.guite.modulestudio.metamodel.modulestudio.AjaxController
import de.guite.modulestudio.metamodel.modulestudio.Application
import de.guite.modulestudio.metamodel.modulestudio.Controller
import de.guite.modulestudio.metamodel.modulestudio.CustomAction
import de.guite.modulestudio.metamodel.modulestudio.CustomController
import de.guite.modulestudio.metamodel.modulestudio.DeleteAction
import de.guite.modulestudio.metamodel.modulestudio.DisplayAction
import de.guite.modulestudio.metamodel.modulestudio.EditAction
import de.guite.modulestudio.metamodel.modulestudio.MainAction
import de.guite.modulestudio.metamodel.modulestudio.UserController
import de.guite.modulestudio.metamodel.modulestudio.ViewAction
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ControllerAction {
    @Inject extension ControllerExtensions = new ControllerExtensions()
    @Inject extension FormattingExtensions = new FormattingExtensions()
    @Inject extension ModelBehaviourExtensions = new ModelBehaviourExtensions()
    @Inject extension ModelExtensions = new ModelExtensions()
    @Inject extension Utils = new Utils()

    Application app

    new(Application app) {
        this.app = app
    }

    def dispatch generate(Action it) '''
        «actionDoc»
        public function «name.formatForCode.toFirstLower»«IF !app.targets('1.3.5')»Action«ENDIF»(array $args = array())
        {
            «IF app.hasSoftDeleteable && !app.targets('1.3.5')»
                «IF controller.tempIsAdminController»
                $this->entityManager->getFilters()->disable('soft-deleteable');
                «ELSE»
                $this->entityManager->getFilters()->enable('soft-deleteable');
                «ENDIF»
            «ENDIF»
            «actionImpl»
        }
        «/* this line is on purpose */»
    '''

    def dispatch generate(MainAction it) '''
        «actionDoc»
        public function «IF !app.targets('1.3.5')»indexAction«ELSE»main«ENDIF»(array $args = array())
        {
            «IF app.hasSoftDeleteable && !app.targets('1.3.5')»
                «IF controller.tempIsAdminController»
                $this->entityManager->getFilters()->disable('soft-deleteable');
                «ELSE»
                $this->entityManager->getFilters()->enable('soft-deleteable');
                «ENDIF»
            «ENDIF»
            «actionImpl»
        }
        «/* this line is on purpose */»
    '''

    def private actionDoc(Action it) '''
        /**
         * «actionDocMethodDescription»
        «actionDocMethodDocumentation»
         *
         * @param array $args List of arguments.
        «actionDocMethodParams»
         *
         * @return mixed Output.
         */
    '''

    def private actionDocMethodDescription(Action it) {
        switch it {
            MainAction: 'This method is the default function handling the ' + controller.formattedName + ' area called without defining arguments.'
            ViewAction: 'This method provides a generic item list overview.'
            DisplayAction: 'This method provides a generic item detail view.'
            EditAction: 'This method provides a generic handling of all edit requests.'
            DeleteAction: 'This method provides a generic handling of simple delete requests.'
            CustomAction: 'This is a custom method. Documentation for this will be improved in later versions.'
            default: ''
        }
    }

    def private actionDocMethodDocumentation(Action it) {
        if (documentation != null && documentation != '') {
            ' * ' + documentation.replaceAll('*/', '*')
        }
        else ''
    }

    def private actionDocMethodParams(Action it) {
        if (!tempIsIndexAction && !tempIsCustomAction) {
            ' * @param string  $ot           Treated object type.\n'
            + '''«actionDocAdditionalParams»'''
            + ' * @param string  $tpl          Name of alternative template (for alternative display options, feeds and xml output)\n'
            + ' * @param boolean $raw          Optional way to display a template instead of fetching it (needed for standalone output)\n'
        }
    }

    def private actionDocAdditionalParams(Action it) {
        switch it {
            ViewAction:
                 ' * @param string  $sort         Sorting field.\n'
               + ' * @param string  $sortdir      Sorting direction.\n'
               + ' * @param int     $pos          Current pager position.\n'
               + ' * @param int     $num          Amount of entries to display.\n'
            DeleteAction:
                 ' * @param int     $id           Identifier of entity to be deleted.\n'
               + ' * @param boolean $confirmation Confirm the deletion, else a confirmation page is displayed.\n'
            default: ''
        }
    }

    def private tempIsIndexAction(Action it) {
        switch it {
            MainAction: true
            default: false
        }
    }

    def private tempIsCustomAction(Action it) {
        switch it {
            CustomAction: true
            default: false
        }
    }

    def private actionImpl(Action it) '''
        «IF tempIsIndexAction»
            «permissionCheck('', '')»
        «ELSE»
            $controllerHelper = new \«app.appName»«IF app.targets('1.3.5')»_Util_Controller«ELSE»\Util\ControllerUtil«ENDIF»($this->serviceManager);

            // parameter specifying which type of objects we are treating
            $objectType = (isset($args['ot']) && !empty($args['ot'])) ? $args['ot'] : $this->request->query->filter('ot', '«app.getLeadingEntity.name.formatForCode»', FILTER_SANITIZE_STRING);
            $utilArgs = array('controller' => '«controller.formattedName»', 'action' => '«name.formatForCode.toFirstLower»');
            if (!in_array($objectType, $controllerHelper->getObjectTypes('controllerAction', $utilArgs))) {
                $objectType = $controllerHelper->getDefaultObjectType('controllerAction', $utilArgs);
            }
            «permissionCheck("' . ucwords($objectType) . '", '')»
        «ENDIF»
        «actionImplBody»
    '''

    /**
     * Permission checks in system use cases.
     */
    def private permissionCheck(Action it, String objectTypeVar, String instanceId) {
        switch controller {
            AdminController: '''
                        $this->throwForbiddenUnless(\SecurityUtil::checkPermission($this->name . ':«objectTypeVar»:', «instanceId»'::', ACCESS_ADMIN), \LogUtil::getErrorMsgPermission());
                    '''
            default: '''
                        $this->throwForbiddenUnless(\SecurityUtil::checkPermission($this->name . ':«objectTypeVar»:', «instanceId»'::', «getPermissionAccessLevel»), \LogUtil::getErrorMsgPermission());
                    '''
        }
    }

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

    def private dispatch actionImplBody(Action it) {
    }

    def private dispatch actionImplBody(MainAction it) {
        switch controller {
            UserController: '''
                        // set caching id
                        $this->view->setCacheId('«IF app.targets('1.3.5')»main«ELSE»index«ENDIF»');

                        // return «IF app.targets('1.3.5')»main«ELSE»index«ENDIF» template
                        «IF app.targets('1.3.5')»
                        return $this->view->fetch('«controller.formattedName»/main.tpl');
                        «ELSE»
                        return $this->response($this->view->fetch('«controller.formattedName.toFirstUpper»/index.tpl'));
                        «ENDIF»
                    '''
            AdminController: '''
                        // set caching id
                        $this->view->setCacheId('«IF app.targets('1.3.5')»main«ELSE»index«ENDIF»');

                        «/*
                        «IF controller.container.application.needsConfig»
                            // call config method
                            return $this->config();
                        «ELSE»
                        */»
                        // return «IF app.targets('1.3.5')»main«ELSE»index«ENDIF» template
                        «IF app.targets('1.3.5')»
                        return $this->view->fetch('«controller.formattedName»/main.tpl');
                        «ELSE»
                        return $this->response($this->view->fetch('«controller.formattedName.toFirstUpper»/index.tpl'));
                        «ENDIF»
                        «/*«ENDIF»*/»
                    '''
            AjaxController: ''
            CustomController: '''
                        // set caching id
                        $this->view->setCacheId('«IF app.targets('1.3.5')»main«ELSE»index«ENDIF»');

                        // return «IF app.targets('1.3.5')»main«ELSE»index«ENDIF» template
                        «IF app.targets('1.3.5')»
                        return $this->view->fetch('«controller.formattedName»/main.tpl');
                        «ELSE»
                        return $this->response($this->view->fetch('«controller.formattedName.toFirstUpper»/index.tpl'));
                        «ENDIF»
                    '''
        }
    }

    def private dispatch actionImplBody(ViewAction it) '''
        $repository = $this->entityManager->getRepository($this->name . '_Entity_' . ucfirst($objectType));
        $viewHelper = new \«app.appName»«IF app.targets('1.3.5')»_Util_View«ELSE»\Util\ViewUtil«ENDIF»($this->serviceManager);
        «IF controller.container.application.hasTrees»

            $tpl = (isset($args['tpl']) && !empty($args['tpl'])) ? $args['tpl'] : $this->request->query->filter('tpl', '', FILTER_SANITIZE_STRING);
            if ($tpl == 'tree') {
                $trees = \ModUtil::apiFunc($this->name, 'selection', 'getAllTrees', array('ot' => $objectType));
                $this->view->assign('trees', $trees)
                           ->assign($repository->getAdditionalTemplateParameters('controllerAction', $utilArgs));
                // fetch and return the appropriate template
                return $viewHelper->processTemplate($this->view, '«controller.formattedName»', $objectType, 'view', $args);
            }
        «ENDIF»

        // parameter for used sorting field
        $sort = (isset($args['sort']) && !empty($args['sort'])) ? $args['sort'] : $this->request->query->filter('sort', '', FILTER_SANITIZE_STRING);
        «new ControllerHelper().defaultSorting(it)»

        // parameter for used sort order
        $sdir = (isset($args['sortdir']) && !empty($args['sortdir'])) ? $args['sortdir'] : $this->request->query->filter('sortdir', '', FILTER_SANITIZE_STRING);
        $sdir = strtolower($sdir);
        if ($sdir != 'asc' && $sdir != 'desc') {
            $sdir = 'asc';
        }

        // convenience vars to make code clearer
        $currentUrlArgs = array('ot' => $objectType);

        $selectionArgs = array(
            'ot' => $objectType,
            'where' => '',
            'orderBy' => $sort . ' ' . $sdir
        );

        $showOwnEntries = (int) (isset($args['own']) && !empty($args['own'])) ? $args['own'] : $this->request->query->filter('own', 0, FILTER_VALIDATE_INT);
        $showAllEntries = (int) (isset($args['all']) && !empty($args['all'])) ? $args['all'] : $this->request->query->filter('all', 0, FILTER_VALIDATE_INT);

        $this->view->assign('showOwnEntries', $showOwnEntries)
                   ->assign('showAllEntries', $showAllEntries);
        if ($showOwnEntries == 1) {
            $currentUrlArgs['own'] = 1;
        }
        if ($showAllEntries == 1) {
            $currentUrlArgs['all'] = 1;
        }

        // prepare access level for cache id
        $accessLevel = ACCESS_READ;
        $component = '«app.appName»:' . ucwords($objectType) . ':';
        $instance = '::';
        if (\SecurityUtil::checkPermission($component, $instance, ACCESS_COMMENT)) {
            $accessLevel = ACCESS_COMMENT;
        }
        if (\SecurityUtil::checkPermission($component, $instance, ACCESS_EDIT)) {
            $accessLevel = ACCESS_EDIT;
        }

        $templateFile = $viewHelper->getViewTemplate($this->view, '«controller.formattedName»', $objectType, 'view', $args);
        $cacheId = 'view|ot_' . $objectType . '_sort_' . $sort . '_' . $sdir;

        $resultsPerPage = 0;
        if ($showAllEntries == 1) {
            // set cache id
            $this->view->setCacheId($cacheId . '_all_1_own_' . $showOwnEntries . '_' . $accessLevel);

            // if page is cached return cached content
            if ($this->view->is_cached($templateFile)) {
                return $viewHelper->processTemplate($this->view, '«controller.formattedName»', $objectType, 'view', $args, $templateFile);
            }

            // retrieve item list without pagination
            $entities = \ModUtil::apiFunc($this->name, 'selection', 'getEntities', $selectionArgs);
        } else {
            // the current offset which is used to calculate the pagination
            $currentPage = (int) (isset($args['pos']) && !empty($args['pos'])) ? $args['pos'] : $this->request->query->filter('pos', 1, FILTER_VALIDATE_INT);

            // the number of items displayed on a page for pagination
            $resultsPerPage = (int) (isset($args['num']) && !empty($args['num'])) ? $args['num'] : $this->request->query->filter('num', 0, FILTER_VALIDATE_INT);
            if ($resultsPerPage == 0) {
                $csv = (int) (isset($args['usecsv']) && !empty($args['usecsv'])) ? $args['usecsv'] : $this->request->query->filter('usecsvext', 0, FILTER_VALIDATE_INT);
                $resultsPerPage = ($csv == 1) ? 999999 : $this->getVar('pageSize', 10);
            }

            // set cache id
            $this->view->setCacheId($cacheId . '_amount_' . $resultsPerPage . '_page_' . $currentPage . '_own_' . $showOwnEntries . '_' . $accessLevel);

            // if page is cached return cached content
            if ($this->view->is_cached($templateFile)) {
                return $viewHelper->processTemplate($this->view, '«controller.formattedName»', $objectType, 'view', $args, $templateFile);
            }

            // retrieve item list with pagination
            $selectionArgs['currentPage'] = $currentPage;
            $selectionArgs['resultsPerPage'] = $resultsPerPage;
            list($entities, $objectCount) = \ModUtil::apiFunc($this->name, 'selection', 'getEntitiesPaginated', $selectionArgs);

            $this->view->assign('currentPage', $currentPage)
                       ->assign('pager', array('numitems'     => $objectCount,
                                               'itemsperpage' => $resultsPerPage));
        }

        // build ModUrl instance for display hooks
        $currentUrlObject = new Zikula_ModUrl($this->name, '«controller.formattedName»', 'view', ZLanguage::getLanguageCode(), $currentUrlArgs);

        // assign the object data, sorting information and details for creating the pager
        $this->view->assign('items', $entities)
                   ->assign('sort', $sort)
                   ->assign('sdir', $sdir)
                   ->assign('pageSize', $resultsPerPage)
                   ->assign('currentUrlObject', $currentUrlObject)
                   ->assign($repository->getAdditionalTemplateParameters('controllerAction', $utilArgs));

        // fetch and return the appropriate template
        return $viewHelper->processTemplate($this->view, '«controller.formattedName»', $objectType, 'view', $args, $templateFile);
    '''

    def private dispatch actionImplBody(DisplayAction it) '''
        $repository = $this->entityManager->getRepository($this->name . '_Entity_' . ucfirst($objectType));

        $idFields = \ModUtil::apiFunc($this->name, 'selection', 'getIdFields', array('ot' => $objectType));

        // retrieve identifier of the object we wish to view
        $idValues = $controllerHelper->retrieveIdentifier($this->request, $args, $objectType, $idFields);
        $hasIdentifier = $controllerHelper->isValidIdentifier($idValues);
        «controller.checkForSlug»
        $this->throwNotFoundUnless($hasIdentifier, $this->__('Error! Invalid identifier received.'));

        $entity = \ModUtil::apiFunc($this->name, 'selection', 'getEntity', array('ot' => $objectType, 'id' => $idValues«controller.addSlugToSelection»));
        $this->throwNotFoundUnless($entity != null, $this->__('No such item.'));
        unset($idValues);

        «controller.prepareDisplayPermissionCheck»

        «permissionCheck("' . ucwords($objectType) . '", "$instanceId . ")»

        «controller.processDisplayOutput»
    '''

    def private checkForSlug(Controller it) {
        switch it {
            UserController: '''

                        // check for unique permalinks (without id)
                        $hasSlug = false;
                        $slug = '';
                        if ($hasIdentifier === false) {
                            $entityClass = $this->name . '_Entity_' . ucfirst($objectType);
                            $objectTemp = new $entityClass();
                            $hasSlug = $objectTemp->get_hasUniqueSlug();
                            if ($hasSlug) {
                                $slug = (isset($args['slug']) && !empty($args['slug'])) ? $args['slug'] : $this->request->query->filter('slug', '', FILTER_SANITIZE_STRING);
                                $hasSlug = (!empty($slug));
                            }
                        }
                        $hasIdentifier |= $hasSlug;
                    '''
            default: ''
        }
    }

    def private addSlugToSelection(Controller it) {
        switch it {
            UserController: ', \'slug\' => $slug'
            default: ''
        }
    }

    def private prepareDisplayPermissionCheckWithoutCurrentUrlArgs() '''
        // create identifier for permission check
        $instanceId = '';
        foreach ($idFields as $idField) {
            if (!empty($instanceId)) {
                $instanceId .= '_';
            }
            $instanceId .= $entity[$idField];
        }
    '''

    def private prepareDisplayPermissionCheck(Controller it) {
        switch it {
            AjaxController: prepareDisplayPermissionCheckWithoutCurrentUrlArgs
            default: '''
        // build ModUrl instance for display hooks; also create identifier for permission check
        $currentUrlArgs = array('ot' => $objectType);
        $instanceId = '';
        foreach ($idFields as $idField) {
            $currentUrlArgs[$idField] = $entity[$idField];
            if (!empty($instanceId)) {
                $instanceId .= '_';
            }
            $instanceId .= $entity[$idField];
        }
        $currentUrlArgs['id'] = $instanceId;
        if (isset($entity['slug'])) {
            $currentUrlArgs['slug'] = $entity['slug'];
        }
        $currentUrlObject = new Zikula_ModUrl($this->name, '«formattedName»', 'display', ZLanguage::getLanguageCode(), $currentUrlArgs);
                    '''
        }
    }

    def private processDisplayOutput(Controller it) {
        switch it {
            AjaxController: '''
        return new Zikula_Response_Ajax(array('result' => true, $objectType => $entity->toArray()));
                    '''
            default: '''
        $viewHelper = new \«app.appName»«IF app.targets('1.3.5')»_Util_View«ELSE»\Util\ViewUtil«ENDIF»($this->serviceManager);
        $templateFile = $viewHelper->getViewTemplate($this->view, '«formattedName»', $objectType, 'display', $args);

        // set cache id
        $component = $this->name . ':' . ucwords($objectType) . ':';
        $instance = $instanceId . '::';
        $accessLevel = ACCESS_READ;
        if (\SecurityUtil::checkPermission($component, $instance, ACCESS_COMMENT)) {
            $accessLevel = ACCESS_COMMENT;
        }
        if (\SecurityUtil::checkPermission($component, $instance, ACCESS_EDIT)) {
            $accessLevel = ACCESS_EDIT;
        }
        $this->view->setCacheId($objectType . '|' . $instanceId . '|a' . $accessLevel);

        // assign output data to view object.
        $this->view->assign($objectType, $entity)
                   ->assign('currentUrlObject', $currentUrlObject)
                   ->assign($repository->getAdditionalTemplateParameters('controllerAction', $utilArgs));

        // fetch and return the appropriate template
        return $viewHelper->processTemplate($this->view, '«formattedName»', $objectType, 'display', $args, $templateFile);
                    '''
        }
    }

    def private dispatch actionImplBody(EditAction it) {
        switch controller {
            AjaxController: '''
        $this->checkAjaxToken();
        $idFields = \ModUtil::apiFunc($this->name, 'selection', 'getIdFields', array('ot' => $objectType));

        $data = (isset($args['data']) && !empty($args['data'])) ? $args['data'] : $this->request->query->filter('data', null);
        $data = json_decode($data, true);

        $idValues = array();
        foreach ($idFields as $idField) {
            $idValues[$idField] = isset($data[$idField]) ? $data[$idField] : '';
        }
        $hasIdentifier = $controllerHelper->isValidIdentifier($idValues);
        $this->throwNotFoundUnless($hasIdentifier, $this->__('Error! Invalid identifier received.'));

        $entity = \ModUtil::apiFunc($this->name, 'selection', 'getEntity', array('ot' => $objectType, 'id' => $idValues));
        $this->throwNotFoundUnless($entity != null, $this->__('No such item.'));
        unset($idValues);

        «prepareDisplayPermissionCheckWithoutCurrentUrlArgs»

        «permissionCheck("' . ucwords($objectType) . '", "$instanceId . ")»

        // TODO: call pre edit validate hooks
        foreach ($idFields as $idField) {
            unset($data[$idField]);
        }
        foreach ($data as $key => $value) {
            $entity[$key] = $value;
        }
        $this->entityManager->persist($entity);
        $this->entityManager->flush();
        // TODO: call post edit process hooks

        return new Zikula_Response_Ajax(array('result' => true, $objectType => $entity->toArray()));
                    '''
            default: '''
        «/* new ActionHandler().formCreate(appName, controller.formattedName, 'edit')*/»
        // create new Form reference
        $view = \FormUtil::newForm($this->name, $this);

        // build form handler class name
        «IF app.targets('1.3.5')»
        $handlerClass = $this->name . '_Form_Handler_«controller.formattedName.toFirstUpper»_' . ucfirst($objectType) . '_Edit';
        «ELSE»
        $handlerClass = '\\' . $this->name . '\Form\Handler\«controller.formattedName.toFirstUpper»\' . ucfirst($objectType) . '\Edit';
        «ENDIF»

        // determine the output template
        $viewHelper = new \«app.appName»«IF app.targets('1.3.5')»_Util_View«ELSE»\Util\ViewUtil«ENDIF»($this->serviceManager);
        $template = $viewHelper->getViewTemplate($this->view, '«controller.formattedName»', $objectType, 'edit', $args);

        // execute form using supplied template and page event handler
        return $view->execute($template, new $handlerClass());
                    '''
        }
    }

    def private dispatch actionImplBody(DeleteAction it) '''
        $idFields = \ModUtil::apiFunc($this->name, 'selection', 'getIdFields', array('ot' => $objectType));

        // retrieve identifier of the object we wish to delete
        $idValues = $controllerHelper->retrieveIdentifier($this->request, $args, $objectType, $idFields);
        $hasIdentifier = $controllerHelper->isValidIdentifier($idValues);

        $this->throwNotFoundUnless($hasIdentifier, $this->__('Error! Invalid identifier received.'));

        $entity = \ModUtil::apiFunc($this->name, 'selection', 'getEntity', array('ot' => $objectType, 'id' => $idValues));
        $this->throwNotFoundUnless($entity != null, $this->__('No such item.'));

        $workflowHelper = new \«app.appName»«IF app.targets('1.3.5')»_Util_Workflow«ELSE»\Util\WorkflowUtil«ENDIF»($this->serviceManager);
        $deleteActionId = 'delete';
        $deleteAllowed = false;
        $actions = $workflowHelper->getActionsForObject($entity);
        if ($actions === false || !is_array($actions)) {
            return \LogUtil::registerError($this->__('Error! Could not determine workflow actions.'));
        }
        foreach ($actions as $actionId => $action) {
            if ($actionId != $deleteActionId) {
                continue;
            }
            $deleteAllowed = true;
            break;
        }
        if (!$deleteAllowed) {
            return \LogUtil::registerError($this->__('Error! It is not allowed to delete this entity.'));
        }

        $confirmation = (bool) (isset($args['confirmation']) && !empty($args['confirmation'])) ? $args['confirmation'] : $this->request->request->filter('confirmation', false, FILTER_VALIDATE_BOOLEAN);
        if ($confirmation) {
            $this->checkCsrfToken();

            $hookAreaPrefix = $entity->getHookAreaPrefix();
            $hookType = 'validate_delete';
            // Let any hooks perform additional validation actions
            «IF app.targets('1.3.5')»
            $hook = new Zikula_ValidationHook($hookAreaPrefix . '.' . $hookType, new Zikula_Hook_ValidationProviders());
            $validators = $this->notifyHooks($hook)->getValidators();
            «ELSE»
            $hook = new \Zikula\Core\Hook\ValidationHook(new \Zikula\Core\Hook\ValidationProviders());
            $validators = $this->dispatchHooks($hookAreaPrefix . '.' . $hookType, $hook)->getValidators();
            «ENDIF»
            if (!$validators->hasErrors()) {
                // execute the workflow action
                $success = $workflowHelper->executeAction($entity, $deleteActionId);
                if ($success) {
                    $this->registerStatus($this->__('Done! Item deleted.'));
                }

                // Let any hooks know that we have created, updated or deleted an item
                $hookType = 'process_delete';
                «IF app.targets('1.3.5')»
                $hook = new Zikula_ProcessHook($hookAreaPrefix . '.' . $hookType, $entity->createCompositeIdentifier());
                $this->notifyHooks($hook);
                «ELSE»
                $hook = new \Zikula\Core\Hook\ProcessHook($entity->createCompositeIdentifier());
                $this->dispatchHooks($hookAreaPrefix . '.' . $hookType, $hook);
                «ENDIF»

                // An item was deleted, so we clear all cached pages this item.
                $cacheArgs = array('ot' => $objectType, 'item' => $entity);
                \ModUtil::apiFunc($this->name, 'cache', 'clearItemCache', $cacheArgs);

                // redirect to the «IF controller.hasActions('view')»list of the current object type«ELSE»«IF app.targets('1.3.5')»main«ELSE»index«ENDIF» page«ENDIF»
                $this->redirect(\ModUtil::url($this->name, '«controller.formattedName»', «IF controller.hasActions('view')»'view',
                                                                                            array('ot' => $objectType)«ELSE»'«IF app.targets('1.3.5')»main«ELSE»index«ENDIF»'«ENDIF»));
            }
        }

        $repository = $this->entityManager->getRepository('«app.appName»_Entity_' . ucfirst($objectType));

        // set caching id
        $this->view->setCaching(Zikula_View::CACHE_DISABLED);

        // assign the object we loaded above
        $this->view->assign($objectType, $entity)
                   ->assign($repository->getAdditionalTemplateParameters('controllerAction', $utilArgs));

        // fetch and return the appropriate template
        $viewHelper = new \«app.appName»«IF app.targets('1.3.5')»_Util_View«ELSE»\Util\ViewUtil«ENDIF»($this->serviceManager);
        return $viewHelper->processTemplate($this->view, '«controller.formattedName»', $objectType, 'delete', $args);
    '''

    def private dispatch actionImplBody(CustomAction it) '''
        «IF controller.tempIsAdminController
            && (name == 'config' || name == 'modifyconfig' || name == 'preferences')»
            «new FormHandler().formCreate(it, app.appName, controller, 'modify')»
        «ELSE»
            /** TODO: custom logic */
        «ENDIF»

        // return template
        «IF app.targets('1.3.5')»
        return $this->view->fetch('«controller.formattedName»/«name.formatForCode.toFirstLower».tpl');
        «ELSE»
        return $this->response($this->view->fetch('«controller.formattedName.toFirstUpper»/«name.formatForCode.toFirstLower».tpl'));
        «ENDIF»
    '''

    def private tempIsAdminController(Controller it) {
        switch it {
            AdminController: true
            default: false
        }
    }
}
