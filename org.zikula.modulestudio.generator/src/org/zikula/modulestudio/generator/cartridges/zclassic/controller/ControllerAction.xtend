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
    @Inject extension ControllerExtensions = new ControllerExtensions
    @Inject extension FormattingExtensions = new FormattingExtensions
    @Inject extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    @Inject extension ModelExtensions = new ModelExtensions
    @Inject extension Utils = new Utils

    Application app

    new(Application app) {
        this.app = app
    }

    def dispatch generate(Action it) '''
        «actionDoc»
        public function «name.formatForCode.toFirstLower»«IF app.targets('1.3.5')»()«ELSE»Action(Request $request)«ENDIF»
        {
            «IF app.hasSoftDeleteable && !app.targets('1.3.5')»
                «IF controller.tempIsAdminController»
                //$this->entityManager->getFilters()->disable('softdeleteable');
                «ELSE»
                $this->entityManager->getFilters()->enable('softdeleteable');
                «ENDIF»
            «ENDIF»
            «actionImpl»
        }
        «/* this line is on purpose */»
    '''

    def dispatch generate(MainAction it) '''
        «actionDoc»
        public function «IF app.targets('1.3.5')»main()«ELSE»indexAction(Request $request)«ENDIF»
        {
            «IF app.hasSoftDeleteable && !app.targets('1.3.5')»
                «IF controller.tempIsAdminController»
                //$this->entityManager->getFilters()->disable('softdeleteable');
                «ELSE»
                $this->entityManager->getFilters()->enable('softdeleteable');
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
        «actionDocMethodParams»
         *
         * @return mixed Output.
         «IF !app.targets('1.3.5')»
         *
         * @throws AccessDeniedException Thrown if the user doesn't have required permissions
         «IF it instanceof DisplayAction»
         * @throws NotFoundHttpException     Thrown if item to be displayed isn't found
         «ELSEIF it instanceof EditAction»
         * @throws NotFoundHttpException     Thrown if item to be edited isn't found
         «ELSEIF it instanceof DeleteAction»
         * @throws NotFoundHttpException     Thrown if item to be deleted isn't found
         «ENDIF»
         «ENDIF»
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
        if (documentation !== null && documentation != '') {
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
            $controllerHelper = new «IF app.targets('1.3.5')»«app.appName»_Util_Controller«ELSE»ControllerUtil«ENDIF»($this->serviceManager«IF !app.targets('1.3.5')», ModUtil::getModule($this->name)«ENDIF»);

            // parameter specifying which type of objects we are treating
            $objectType = $«IF app.targets('1.3.5')»this->«ENDIF»request->query->filter('ot', '«app.getLeadingEntity.name.formatForCode»', «IF !app.targets('1.3.5')»false, «ENDIF»FILTER_SANITIZE_STRING);
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
                    «IF app.targets('1.3.5')»
                        $this->throwForbiddenUnless(SecurityUtil::checkPermission($this->name . ':«objectTypeVar»:', «instanceId»'::', ACCESS_ADMIN), LogUtil::getErrorMsgPermission());
                    «ELSE»
                        if (!SecurityUtil::checkPermission($this->name . ':«objectTypeVar»:', «instanceId»'::', ACCESS_ADMIN)) {
                            throw new AccessDeniedException();
                        }
                    «ENDIF»
                    '''
            default: '''
                    «IF app.targets('1.3.5')»
                        $this->throwForbiddenUnless(SecurityUtil::checkPermission($this->name . ':«objectTypeVar»:', «instanceId»'::', «getPermissionAccessLevel»), LogUtil::getErrorMsgPermission());
                    «ELSE»
                        if (!SecurityUtil::checkPermission($this->name . ':«objectTypeVar»:', «instanceId»'::', «getPermissionAccessLevel»)) {
                            throw new AccessDeniedException();
                        }
                    «ENDIF»
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
                        «IF controller.hasActions('view')»
                            return $this->redirect(ModUtil::url($this->name, '«controller.formattedName»', 'view'));
                        «ELSE»
                            // set caching id
                            $this->view->setCacheId('«IF app.targets('1.3.5')»main«ELSE»index«ENDIF»');

                            // return «IF app.targets('1.3.5')»main«ELSE»index«ENDIF» template
                            «IF app.targets('1.3.5')»
                            return $this->view->fetch('«controller.formattedName»/main.tpl');
                            «ELSE»
                            return $this->response($this->view->fetch('«controller.formattedName.toFirstUpper»/index.tpl'));
                            «ENDIF»
                        «ENDIF»
                    '''
            AdminController: '''
                        «IF controller.hasActions('view')»
                            return $this->redirect(ModUtil::url($this->name, '«controller.formattedName»', 'view'));
                        «ELSE»
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
                        «ENDIF»
                    '''
            AjaxController: ''
            CustomController: '''
                        «IF controller.hasActions('view')»
                            return $this->redirect(ModUtil::url($this->name, '«controller.formattedName»', 'view'));
                        «ELSE»
                            // set caching id
                            $this->view->setCacheId('«IF app.targets('1.3.5')»main«ELSE»index«ENDIF»');

                            // return «IF app.targets('1.3.5')»main«ELSE»index«ENDIF» template
                            «IF app.targets('1.3.5')»
                            return $this->view->fetch('«controller.formattedName»/main.tpl');
                            «ELSE»
                            return $this->response($this->view->fetch('«controller.formattedName.toFirstUpper»/index.tpl'));
                            «ENDIF»
                        «ENDIF»
                    '''
        }
    }

    def private dispatch actionImplBody(ViewAction it) '''
        «val hasView = !(controller instanceof AjaxController)»
        «IF app.targets('1.3.5')»
            $entityClass = $this->name . '_Entity_' . ucwords($objectType);
        «ELSE»
            $entityClass = '\\«app.vendor.formatForCodeCapital»\\«app.name.formatForCodeCapital»Module\\Entity\\' . ucwords($objectType) . 'Entity';
        «ENDIF»
        $repository = $this->entityManager->getRepository($entityClass);
        «IF app.targets('1.3.5')»
            $repository->setControllerArguments(array());
        «ELSE»
            $repository->setRequest($this->request);
        «ENDIF»
        «IF hasView»
            $viewHelper = new «IF app.targets('1.3.5')»«app.appName»_Util_View«ELSE»ViewUtil«ENDIF»($this->serviceManager«IF !app.targets('1.3.5')», ModUtil::getModule($this->name)«ENDIF»);
            «IF app.hasTrees»

                $tpl = $«IF app.targets('1.3.5')»this->«ENDIF»request->query->filter('tpl', '', «IF !app.targets('1.3.5')»false, «ENDIF»FILTER_SANITIZE_STRING);
                if ($tpl == 'tree') {
                    $trees = ModUtil::apiFunc($this->name, 'selection', 'getAllTrees', array('ot' => $objectType));
                    $this->view->assign('trees', $trees)
                               ->assign($repository->getAdditionalTemplateParameters('controllerAction', $utilArgs));
                    // fetch and return the appropriate template
                    return $viewHelper->processTemplate($this->view, '«controller.formattedName»', $objectType, 'view', «IF app.targets('1.3.5')»array()«ELSE»$request«ENDIF»);
                }
            «ENDIF»
        «ENDIF»

        // parameter for used sorting field
        «IF app.targets('1.3.5')»
            $sort = $this->request->query->filter('sort', '', FILTER_SANITIZE_STRING);
        «ELSE»
            $sort = $request->query->filter('sort', '', false, FILTER_SANITIZE_STRING);
        «ENDIF»
        «new ControllerHelper().defaultSorting(it)»

        // parameter for used sort order
        «IF app.targets('1.3.5')»
            $sdir = $this->request->query->filter('sortdir', '', FILTER_SANITIZE_STRING);
        «ELSE»
            $sdir = $request->query->filter('sortdir', '', false, FILTER_SANITIZE_STRING);
        «ENDIF»
        $sdir = strtolower($sdir);
        if ($sdir != 'asc' && $sdir != 'desc') {
            $sdir = 'asc';
        }

        // convenience vars to make code clearer
        $currentUrlArgs = array('ot' => $objectType);

        «IF controller instanceof AjaxController»
            «IF app.targets('1.3.5')»
                $where = $this->request->query->filter('where', '');
            «ELSE»
                $where = $request->query->filter('where', '', false);
            «ENDIF»
            $where = str_replace('"', '', $where);
        «ELSE»
            $where = '';
        «ENDIF»

        $selectionArgs = array(
            'ot' => $objectType,
            'where' => $where,
            'orderBy' => $sort . ' ' . $sdir
        );

        «IF app.targets('1.3.5')»
            $showOwnEntries = (int) $this->request->query->filter('own', $this->getVar('showOnlyOwnEntries', 0), FILTER_VALIDATE_INT);
            $showAllEntries = (int) $this->request->query->filter('all', 0, FILTER_VALIDATE_INT);
        «ELSE»
            $showOwnEntries = (int) $request->query->filter('own', $this->getVar('showOnlyOwnEntries', 0), false, FILTER_VALIDATE_INT);
            $showAllEntries = (int) $request->query->filter('all', 0, false, FILTER_VALIDATE_INT);
        «ENDIF»

        if (!$showAllEntries) {
            «IF app.targets('1.3.5')»
                $csv = (int) $this->request->query->filter('usecsvext', 0, FILTER_VALIDATE_INT);
            «ELSE»
                $csv = (int) $request->query->filter('usecsvext', 0, false, FILTER_VALIDATE_INT);
            «ENDIF»
            if ($csv == 1) {
                $showAllEntries = 1;
            }
        }

        «IF hasView»
            $this->view->assign('showOwnEntries', $showOwnEntries)
                       ->assign('showAllEntries', $showAllEntries);
        «ENDIF»
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
        if (SecurityUtil::checkPermission($component, $instance, ACCESS_COMMENT)) {
            $accessLevel = ACCESS_COMMENT;
        }
        if (SecurityUtil::checkPermission($component, $instance, ACCESS_EDIT)) {
            $accessLevel = ACCESS_EDIT;
        }

        «IF hasView»
            $templateFile = $viewHelper->getViewTemplate($this->view, '«controller.formattedName»', $objectType, 'view', «IF app.targets('1.3.5')»array()«ELSE»$request«ENDIF»);
            $cacheId = 'view|ot_' . $objectType . '_sort_' . $sort . '_' . $sdir;
        «ENDIF»
        $resultsPerPage = 0;
        if ($showAllEntries == 1) {
            «IF hasView»
                // set cache id
                $this->view->setCacheId($cacheId . '_all_1_own_' . $showOwnEntries . '_' . $accessLevel);

                // if page is cached return cached content
                if ($this->view->is_cached($templateFile)) {
                    return $viewHelper->processTemplate($this->view, '«controller.formattedName»', $objectType, 'view', «IF app.targets('1.3.5')»array()«ELSE»$request«ENDIF», $templateFile);
                }

            «ENDIF»
            // retrieve item list without pagination
            $entities = ModUtil::apiFunc($this->name, 'selection', 'getEntities', $selectionArgs);
            «IF !hasView»
                $objectCount = count($entities);
            «ENDIF»
        } else {
            // the current offset which is used to calculate the pagination
            «IF app.targets('1.3.5')»
                $currentPage = (int) $this->request->query->filter('pos', 1, FILTER_VALIDATE_INT);
            «ELSE»
                $currentPage = (int) $request->query->filter('pos', 1, false, FILTER_VALIDATE_INT);
            «ENDIF»

            // the number of items displayed on a page for pagination
            «IF app.targets('1.3.5')»
                $resultsPerPage = (int) $this->request->query->filter('num', 0, FILTER_VALIDATE_INT);
            «ELSE»
                $resultsPerPage = (int) $request->query->filter('num', 0, false, FILTER_VALIDATE_INT);
            «ENDIF»
            if ($resultsPerPage == 0) {
                $resultsPerPage = $this->getVar('pageSize', 10);
            }

            «IF hasView»
                // set cache id
                $this->view->setCacheId($cacheId . '_amount_' . $resultsPerPage . '_page_' . $currentPage . '_own_' . $showOwnEntries . '_' . $accessLevel);

                // if page is cached return cached content
                if ($this->view->is_cached($templateFile)) {
                    return $viewHelper->processTemplate($this->view, '«controller.formattedName»', $objectType, 'view', «IF app.targets('1.3.5')»array()«ELSE»$request«ENDIF», $templateFile);
                }

            «ENDIF»
            // retrieve item list with pagination
            $selectionArgs['currentPage'] = $currentPage;
            $selectionArgs['resultsPerPage'] = $resultsPerPage;
            list($entities, $objectCount) = ModUtil::apiFunc($this->name, 'selection', 'getEntitiesPaginated', $selectionArgs);
            «IF hasView»

                $this->view->assign('currentPage', $currentPage)
                           ->assign('pager', array('numitems'     => $objectCount,
                                                   'itemsperpage' => $resultsPerPage));
           «ENDIF»
        }

        foreach ($entities as $k => $entity) {
            $entity->initWorkflow();
        }
        «IF hasView»

            // build ModUrl instance for display hooks
            $currentUrlObject = new «IF app.targets('1.3.5')»Zikula_«ENDIF»ModUrl($this->name, '«controller.formattedName»', 'view', ZLanguage::getLanguageCode(), $currentUrlArgs);

            // assign the object data, sorting information and details for creating the pager
            $this->view->assign('items', $entities)
                       ->assign('sort', $sort)
                       ->assign('sdir', $sdir)
                       ->assign('pageSize', $resultsPerPage)
                       ->assign('currentUrlObject', $currentUrlObject)
                       ->assign($repository->getAdditionalTemplateParameters('controllerAction', $utilArgs));

            $modelHelper = new «IF app.targets('1.3.5')»«app.appName»_Util_Model«ELSE»ModelUtil«ENDIF»($this->serviceManager«IF !app.targets('1.3.5')», ModUtil::getModule($this->name)«ENDIF»);
            $this->view->assign('canBeCreated', $modelHelper->canBeCreated($objectType));

            // fetch and return the appropriate template
            return $viewHelper->processTemplate($this->view, '«controller.formattedName»', $objectType, 'view', «IF app.targets('1.3.5')»array()«ELSE»$request«ENDIF», $templateFile);
        «ELSE»
            $items = array();
            «IF app.hasListFields»
                $listHelper = new «IF app.targets('1.3.5')»«app.appName»_Util_ListEntries«ELSE»ListEntriesUtil«ENDIF»($this->serviceManager«IF !app.targets('1.3.5')», ModUtil::getModule($this->name)«ENDIF»);
                $listObjectTypes = array(«FOR entity : app.getListEntities SEPARATOR ', '»'«entity.name.formatForCode»'«ENDFOR»);
                $hasListFields = (in_array($objectType, $listObjectTypes));

                foreach ($entities as $item) {
                    $currItem = $item->toArray();
                    if ($hasListFields) {
                        // convert list field values to their corresponding labels
                        switch ($objectType) {
                            «FOR entity : app.getListEntities»
                                case '«entity.name.formatForCode»':
                                    «FOR field : entity.getListFieldsEntity»
                                        $currItem['«field.name.formatForCode»'] = $listHelper->resolve($currItem['«field.name.formatForCode»'], $objectType, '«field.name.formatForCode»', ', ');
                                    «ENDFOR»
                                    break;
                            «ENDFOR»
                        }
                    }
                    $items[] = $currItem;
                }
            «ELSE»
                foreach ($entities as $item) {
                    $items[] = $item->toArray();
                }
            «ENDIF»

            $result = array('objectCount' => $objectCount, 'items' => $items);

            return new «IF app.targets('1.3.5')»Zikula_Response_Ajax«ELSE»AjaxResponse«ENDIF»($result);
        «ENDIF»
    '''

    def private dispatch actionImplBody(DisplayAction it) '''
        «IF app.targets('1.3.5')»
            $entityClass = $this->name . '_Entity_' . ucwords($objectType);
        «ELSE»
            $entityClass = '\\«app.vendor.formatForCodeCapital»\\«app.name.formatForCodeCapital»Module\\Entity\\' . ucwords($objectType) . 'Entity';
        «ENDIF»
        $repository = $this->entityManager->getRepository($entityClass);
        «IF app.targets('1.3.5')»
            $repository->setControllerArguments(array());
        «ELSE»
            $repository->setRequest($this->request);
        «ENDIF»

        $idFields = ModUtil::apiFunc($this->name, 'selection', 'getIdFields', array('ot' => $objectType));

        // retrieve identifier of the object we wish to view
        $idValues = $controllerHelper->retrieveIdentifier(«IF app.targets('1.3.5')»$this->request, array()«ELSE»$this->request, array()«ENDIF», $objectType, $idFields);
        $hasIdentifier = $controllerHelper->isValidIdentifier($idValues);
        «controller.checkForSlug»
        «IF app.targets('1.3.5')»
            $this->throwNotFoundUnless($hasIdentifier, $this->__('Error! Invalid identifier received.'));
        «ELSE»
            if (!$hasIdentifier) {
                throw new NotFoundHttpException($this->__('Error! Invalid identifier received.'));
            }
        «ENDIF»

        $entity = ModUtil::apiFunc($this->name, 'selection', 'getEntity', array('ot' => $objectType, 'id' => $idValues«controller.addSlugToSelection»));
        «IF app.targets('1.3.5')»
            $this->throwNotFoundUnless($entity != null, $this->__('No such item.'));
        «ELSE»
            if ($entity === null) {
                throw new NotFoundHttpException($this->__('No such item.'));
            }
        «ENDIF»
        unset($idValues);

        $entity->initWorkflow();

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
                            «IF app.targets('1.3.5')»
                                $entityClass = $this->name . '_Entity_' . ucwords($objectType);
                            «ELSE»
                                $entityClass = '\\«app.vendor.formatForCodeCapital»\\«app.name.formatForCodeCapital»Module\\Entity\\' . ucwords($objectType) . 'Entity';
                            «ENDIF»
                            $meta = $this->entityManager->getClassMetadata($entityClass);
                            $hasSlug = $meta->hasField('slug') && $meta->isUniqueField('slug');
                            if ($hasSlug) {
                                «IF app.targets('1.3.5')»
                                    $slug = $this->request->query->filter('slug', '', FILTER_SANITIZE_STRING);
                                «ELSE»
                                    $slug = $request->query->filter('slug', '', false, FILTER_SANITIZE_STRING);
                                «ENDIF»
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
        $currentUrlObject = new «IF app.targets('1.3.5')»Zikula_«ENDIF»ModUrl($this->name, '«formattedName»', 'display', ZLanguage::getLanguageCode(), $currentUrlArgs);
                    '''
        }
    }

    def private processDisplayOutput(Controller it) {
        switch it {
            AjaxController: '''
        return new «IF app.targets('1.3.5')»Zikula_Response_Ajax«ELSE»AjaxResponse«ENDIF»(array('result' => true, $objectType => $entity->toArray()));
                    '''
            default: '''
        $viewHelper = new «IF app.targets('1.3.5')»«app.appName»_Util_View«ELSE»ViewUtil«ENDIF»($this->serviceManager«IF !app.targets('1.3.5')», ModUtil::getModule($this->name)«ENDIF»);
        $templateFile = $viewHelper->getViewTemplate($this->view, '«formattedName»', $objectType, 'display', «IF app.targets('1.3.5')»array()«ELSE»$request«ENDIF»);

        // set cache id
        $component = $this->name . ':' . ucwords($objectType) . ':';
        $instance = $instanceId . '::';
        $accessLevel = ACCESS_READ;
        if (SecurityUtil::checkPermission($component, $instance, ACCESS_COMMENT)) {
            $accessLevel = ACCESS_COMMENT;
        }
        if (SecurityUtil::checkPermission($component, $instance, ACCESS_EDIT)) {
            $accessLevel = ACCESS_EDIT;
        }
        $this->view->setCacheId($objectType . '|' . $instanceId . '|a' . $accessLevel);

        // assign output data to view object.
        $this->view->assign($objectType, $entity)
                   ->assign('currentUrlObject', $currentUrlObject)
                   ->assign($repository->getAdditionalTemplateParameters('controllerAction', $utilArgs));

        // fetch and return the appropriate template
        return $viewHelper->processTemplate($this->view, '«formattedName»', $objectType, 'display', «IF app.targets('1.3.5')»array()«ELSE»$request«ENDIF», $templateFile);
                    '''
        }
    }

    def private dispatch actionImplBody(EditAction it) {
        switch controller {
            AjaxController: '''
        $this->checkAjaxToken();
        $idFields = ModUtil::apiFunc($this->name, 'selection', 'getIdFields', array('ot' => $objectType));

        $data = $this->request->query->filter('data', null«IF !app.targets('1.3.5')», false«ENDIF»);
        $data = json_decode($data, true);

        $idValues = array();
        foreach ($idFields as $idField) {
            $idValues[$idField] = isset($data[$idField]) ? $data[$idField] : '';
        }
        $hasIdentifier = $controllerHelper->isValidIdentifier($idValues);
        «IF app.targets('1.3.5')»
            $this->throwNotFoundUnless($hasIdentifier, $this->__('Error! Invalid identifier received.'));
        «ELSE»
            if (!$hasIdentifier) {
                throw new NotFoundHttpException($this->__('Error! Invalid identifier received.'));
            }
        «ENDIF»

        $entity = ModUtil::apiFunc($this->name, 'selection', 'getEntity', array('ot' => $objectType, 'id' => $idValues));
        «IF app.targets('1.3.5')»
            $this->throwNotFoundUnless($entity != null, $this->__('No such item.'));
        «ELSE»
            if ($entity === null) {
                throw new NotFoundHttpException($this->__('No such item.'));
            }
        «ENDIF»
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

        return new «IF app.targets('1.3.5')»Zikula_Response_Ajax«ELSE»AjaxResponse«ENDIF»(array('result' => true, $objectType => $entity->toArray()));
                    '''
            default: '''
        «/* new ActionHandler().formCreate(appName, controller.formattedName, 'edit')*/»
        // create new Form reference
        $view = FormUtil::newForm($this->name, $this);

        // build form handler class name
        «IF app.targets('1.3.5')»
        $handlerClass = $this->name . '_Form_Handler_«controller.formattedName.toFirstUpper»_' . ucfirst($objectType) . '_Edit';
        «ELSE»
        $handlerClass = '\\«app.vendor.formatForCodeCapital»\\«app.name.formatForCodeCapital»Module\\Form\\Handler\\«controller.formattedName.toFirstUpper»\\' . ucfirst($objectType) . '\\EditHandler';
        «ENDIF»

        // determine the output template
        $viewHelper = new «IF app.targets('1.3.5')»«app.appName»_Util_View«ELSE»ViewUtil«ENDIF»($this->serviceManager«IF !app.targets('1.3.5')», ModUtil::getModule($this->name)«ENDIF»);
        $template = $viewHelper->getViewTemplate($this->view, '«controller.formattedName»', $objectType, 'edit', «IF app.targets('1.3.5')»array()«ELSE»$request«ENDIF»);

        // execute form using supplied template and page event handler
        return $view->execute($template, new $handlerClass());
                    '''
        }
    }

    def private dispatch actionImplBody(DeleteAction it) '''
        $idFields = ModUtil::apiFunc($this->name, 'selection', 'getIdFields', array('ot' => $objectType));

        // retrieve identifier of the object we wish to delete
        $idValues = $controllerHelper->retrieveIdentifier(«IF app.targets('1.3.5')»$this->request, array()«ELSE»$this->request, array()«ENDIF», $objectType, $idFields);
        $hasIdentifier = $controllerHelper->isValidIdentifier($idValues);

        «IF app.targets('1.3.5')»
            $this->throwNotFoundUnless($hasIdentifier, $this->__('Error! Invalid identifier received.'));
        «ELSE»
            if (!$hasIdentifier) {
                throw new NotFoundHttpException($this->__('Error! Invalid identifier received.'));
            }
        «ENDIF»

        $entity = ModUtil::apiFunc($this->name, 'selection', 'getEntity', array('ot' => $objectType, 'id' => $idValues));
        «IF app.targets('1.3.5')»
            $this->throwNotFoundUnless($entity != null, $this->__('No such item.'));
        «ELSE»
            if ($entity === null) {
                throw new NotFoundHttpException($this->__('No such item.'));
            }
        «ENDIF»

        $entity->initWorkflow();

        $workflowHelper = new «IF app.targets('1.3.5')»«app.appName»_Util_Workflow«ELSE»WorkflowUtil«ENDIF»($this->serviceManager«IF !app.targets('1.3.5')», ModUtil::getModule($this->name)«ENDIF»);
        $deleteActionId = 'delete';
        $deleteAllowed = false;
        $actions = $workflowHelper->getActionsForObject($entity);
        if ($actions === false || !is_array($actions)) {
            «IF app.targets('1.3.5')»return LogUtil::registerError«ELSE»throw new \RuntimeException«ENDIF»($this->__('Error! Could not determine workflow actions.'));
        }
        foreach ($actions as $actionId => $action) {
            if ($actionId != $deleteActionId) {
                continue;
            }
            $deleteAllowed = true;
            break;
        }
        if (!$deleteAllowed) {
            «IF app.targets('1.3.5')»return LogUtil::registerError«ELSE»throw new \RuntimeException«ENDIF»($this->__('Error! It is not allowed to delete this entity.'));
        }

        $confirmation = (bool) $this->request->request->filter('confirmation', false, «IF !app.targets('1.3.5')»false, «ENDIF»FILTER_VALIDATE_BOOLEAN);
        if ($confirmation) {
            $this->checkCsrfToken();

            $hookAreaPrefix = $entity->getHookAreaPrefix();
            $hookType = 'validate_delete';
            // Let any hooks perform additional validation actions
            «IF app.targets('1.3.5')»
            $hook = new Zikula_ValidationHook($hookAreaPrefix . '.' . $hookType, new Zikula_Hook_ValidationProviders());
            $validators = $this->notifyHooks($hook)->getValidators();
            «ELSE»
            $hook = new ValidationHook(new ValidationProviders());
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
                $hook = new ProcessHook($entity->createCompositeIdentifier());
                $this->dispatchHooks($hookAreaPrefix . '.' . $hookType, $hook);
                «ENDIF»

                // An item was deleted, so we clear all cached pages this item.
                $cacheArgs = array('ot' => $objectType, 'item' => $entity);
                ModUtil::apiFunc($this->name, 'cache', 'clearItemCache', $cacheArgs);

                // redirect to the «IF controller.hasActions('view')»list of the current object type«ELSE»«IF app.targets('1.3.5')»main«ELSE»index«ENDIF» page«ENDIF»
                $this->redirect(ModUtil::url($this->name, '«controller.formattedName»', «IF controller.hasActions('view')»'view',
                                                                                            array('ot' => $objectType)«ELSE»'«IF app.targets('1.3.5')»main«ELSE»index«ENDIF»'«ENDIF»));
            }
        }

        «IF app.targets('1.3.5')»
            $entityClass = $this->name . '_Entity_' . ucwords($objectType);
        «ELSE»
            $entityClass = '\\«app.vendor.formatForCodeCapital»\\«app.name.formatForCodeCapital»Module\\Entity\\' . ucwords($objectType) . 'Entity';
        «ENDIF»
        $repository = $this->entityManager->getRepository($entityClass);

        // set caching id
        $this->view->setCaching(Zikula_View::CACHE_DISABLED);

        // assign the object we loaded above
        $this->view->assign($objectType, $entity)
                   ->assign($repository->getAdditionalTemplateParameters('controllerAction', $utilArgs));

        // fetch and return the appropriate template
        $viewHelper = new «IF app.targets('1.3.5')»«app.appName»_Util_View«ELSE»ViewUtil«ENDIF»($this->serviceManager«IF !app.targets('1.3.5')», ModUtil::getModule($this->name)«ENDIF»);

        return $viewHelper->processTemplate($this->view, '«controller.formattedName»', $objectType, 'delete', «IF app.targets('1.3.5')»array()«ELSE»$request«ENDIF»);
    '''

    def private dispatch actionImplBody(CustomAction it) '''
        «IF controller.tempIsAdminController
            && (name == 'config' || name == 'modifyconfig' || name == 'preferences')»
            «new FormHandler().formCreate(it, app.appName, controller, 'modify')»
        «ELSE»
            /** TODO: custom logic */
        «ENDIF»

        «IF controller instanceof AjaxController»
            return new «IF app.targets('1.3.5')»Zikula_Response_Ajax«ELSE»AjaxResponse«ENDIF»(array('result' => true));
        «ELSE»
            // return template
            «IF app.targets('1.3.5')»
            return $this->view->fetch('«controller.formattedName»/«name.formatForCode.toFirstLower».tpl');
            «ELSE»
            return $this->response($this->view->fetch('«controller.formattedName.toFirstUpper»/«name.formatForCode.toFirstLower».tpl'));
            «ENDIF»
        «ENDIF»
    '''

    def private tempIsAdminController(Controller it) {
        switch it {
            AdminController: true
            default: false
        }
    }
}
