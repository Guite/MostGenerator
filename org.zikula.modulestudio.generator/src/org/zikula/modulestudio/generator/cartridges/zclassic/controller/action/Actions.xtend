package org.zikula.modulestudio.generator.cartridges.zclassic.controller.action

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Action
import de.guite.modulestudio.metamodel.modulestudio.AdminController
import de.guite.modulestudio.metamodel.modulestudio.AjaxController
import de.guite.modulestudio.metamodel.modulestudio.Application
import de.guite.modulestudio.metamodel.modulestudio.Controller
import de.guite.modulestudio.metamodel.modulestudio.CustomAction
import de.guite.modulestudio.metamodel.modulestudio.DeleteAction
import de.guite.modulestudio.metamodel.modulestudio.DisplayAction
import de.guite.modulestudio.metamodel.modulestudio.EditAction
import de.guite.modulestudio.metamodel.modulestudio.Entity
import de.guite.modulestudio.metamodel.modulestudio.EntityTreeType
import de.guite.modulestudio.metamodel.modulestudio.MainAction
import de.guite.modulestudio.metamodel.modulestudio.NamedObject
import de.guite.modulestudio.metamodel.modulestudio.ViewAction
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.ControllerHelper
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.FormHandler
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Actions {

    @Inject extension ControllerExtensions = new ControllerExtensions
    @Inject extension FormattingExtensions = new FormattingExtensions
    @Inject extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    @Inject extension ModelExtensions = new ModelExtensions
    @Inject extension Utils = new Utils

    Application app

    new(Application app) {
        this.app = app
    }

    def actionImpl(Action it) '''
        «IF it instanceof MainAction»
            // parameter specifying which type of objects we are treating
            $objectType = $«IF app.targets('1.3.5')»this->«ENDIF»request->query->filter('ot', '«app.getLeadingEntity.name.formatForCode»', «IF !app.targets('1.3.5')»false, «ENDIF»FILTER_SANITIZE_STRING);

            $permLevel = «IF controller instanceof AdminController»ACCESS_ADMIN«ELSE»«getPermissionAccessLevel»«ENDIF»;
            «permissionCheck('', '')»
        «ELSE»
            «IF app.targets('1.3.5')»
                $controllerHelper = new «app.appName»_Util_Controller($this->serviceManager);
            «ELSE»
                $controllerHelper = $this->serviceManager->get('«app.appName.formatForDB».controller_helper');
            «ENDIF»

            // parameter specifying which type of objects we are treating
            $objectType = $«IF app.targets('1.3.5')»this->«ENDIF»request->query->filter('ot', '«app.getLeadingEntity.name.formatForCode»', «IF !app.targets('1.3.5')»false, «ENDIF»FILTER_SANITIZE_STRING);
            $utilArgs = array('controller' => '«controller.formattedName»', 'action' => '«name.formatForCode.toFirstLower»');
            if (!in_array($objectType, $controllerHelper->getObjectTypes('controllerAction', $utilArgs))) {
                $objectType = $controllerHelper->getDefaultObjectType('controllerAction', $utilArgs);
            }
            $permLevel = «IF controller instanceof AdminController»ACCESS_ADMIN«ELSE»«getPermissionAccessLevel»«ENDIF»;
            «permissionCheck("' . ucwords($objectType) . '", '')»
        «ENDIF»
        «actionImplBody»
    '''

    def private redirectLegacyAction(Action it) '''
        «IF !app.targets('1.3.5')»
            // forward GET parameters
            $redirectArgs = $this->request->query->«IF app.targets('1.3.5')»getCollection«ELSE»all«ENDIF»();

            // remove unrequired fields
            if (isset($redirectArgs['module'])) {
                unset($redirectArgs['module']);
            }
            if (isset($redirectArgs['type'])) {
                unset($redirectArgs['type']);
            }
            if (isset($redirectArgs['func'])) {
                unset($redirectArgs['func']);
            }
            if (isset($redirectArgs['ot'])) {
                unset($redirectArgs['ot']);
            }

            // add information about legacy controller type (admin/user)
            $redirectArgs['lct'] = '«controller.formattedName»';

        «ENDIF»
        // redirect to entity controller
        «IF app.targets('1.3.5')»
            «/*
            $redirectUrl = ModUtil::url($this->name, $objectType, '«name.formatForCode»', $redirectArgs);

            return $this->redirect($redirectUrl); */»
            System::queryStringSetVar('lct', '«controller.formattedName»');
            $this->request->query->set('lct', '«controller.formattedName»');

            return ModUtil::func($this->name, $objectType, '«name.formatForCode»', array('lct' => '«controller.formattedName»'));
        «ELSE»
            $logger = $this->serviceManager->get('logger');
            $logger->warning('{app}: The {controller} controller\'s {action} action is deprecated. Please use entity-related controllers instead.', array('app' => '«app.appName»', 'controller' => '«controller.name.formatForDisplay»', 'action' => '«name.formatForDisplay»'));

            $redirectUrl = $this->serviceManager->get('router')->generate('«app.appName.formatForDB»_' . $objectType . '_«name.formatForCode»', $redirectArgs);

            return new RedirectResponse(System::normalizeUrl($redirectUrl));
        «ENDIF»
    '''

    def actionImpl(Entity it, Action action) '''
        «IF it instanceof MainAction»
            «permissionCheck('', '')»
        «ELSE»
            «IF app.targets('1.3.5')»
                $controllerHelper = new «app.appName»_Util_Controller($this->serviceManager);
            «ELSE»
                $controllerHelper = $this->serviceManager->get('«app.appName.formatForDB».controller_helper');
            «ENDIF»

            // parameter specifying which type of objects we are treating
            $objectType = '«name.formatForCode»';
            $utilArgs = array('controller' => '«name.formatForCode»', 'action' => '«action.name.formatForCode.toFirstLower»');
            $permLevel = $legacyControllerType == 'admin' ? ACCESS_ADMIN : «action.getPermissionAccessLevel»;
            «action.permissionCheck("' . ucwords($objectType) . '", '')»
        «ENDIF»
        «actionImplBody(it, action)»
    '''

    /**
     * Permission checks in system use cases.
     */
    def private permissionCheck(Action it, String objectTypeVar, String instanceId) '''
        «IF app.targets('1.3.5')»
            $this->throwForbiddenUnless(SecurityUtil::checkPermission($this->name . ':«objectTypeVar»:', «instanceId»'::', $permLevel), LogUtil::getErrorMsgPermission());
        «ELSE»
            if (!SecurityUtil::checkPermission($this->name . ':«objectTypeVar»:', «instanceId»'::', $permLevel)) {
                throw new AccessDeniedException();
            }
        «ENDIF»
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

    def private dispatch actionImplBody(Action it) {
    }

    def private dispatch actionImplBody(Entity it, Action action) {
    }

    def private dispatch actionImplBody(MainAction it) '''
        «IF controller instanceof AjaxController»
        «ELSE»
            «IF controller.hasActions('view')»

                «IF app.targets('1.3.5')»
                    $redirectUrl = ModUtil::url($this->name, '«controller.formattedName»', 'view', array('lct' => '«controller.formattedName»'));

                    return $this->redirect($redirectUrl);
                «ELSE»
                    $redirectUrl = $this->serviceManager->get('router')->generate('«app.appName.formatForDB»_' . $objectType . '_view', array('lct' => '«controller.formattedName»'));

                    return new RedirectResponse(System::normalizeUrl($redirectUrl));
                «ENDIF»
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
        «ENDIF»
    '''

    def private dispatch actionImplBody(Entity it, MainAction action) '''
        «IF app.hasAdminController && app.getAllAdminControllers.head.hasActions('view')»

            if ($legacyControllerType == 'admin') {
                «redirectFromIndexToView(app.getAllAdminControllers.head)»
            }
        «ENDIF»
        «IF app.hasUserController && app.getAllUserControllers.head.hasActions('view')»

            if ($legacyControllerType != 'admin') {
                «redirectFromIndexToView(app.getMainUserController)»
            }
        «ENDIF»

        // set caching id
        $this->view->setCacheId('«name.formatForCode»_«IF app.targets('1.3.5')»main«ELSE»index«ENDIF»');

        // return «IF app.targets('1.3.5')»main«ELSE»index«ENDIF» template
        «IF app.targets('1.3.5')»
            return $this->view->fetch('«name.formatForCode»/main.tpl');
        «ELSE»
            return $this->response($this->view->fetch('«name.formatForCodeCapital»/index.tpl'));
        «ENDIF»
    '''

    def private redirectFromIndexToView(Entity it, Controller controller) '''

        «IF app.targets('1.3.5')»
            $redirectUrl = ModUtil::url($this->name, '«name.formatForCode»', 'view', array('lct' => $legacyControllerType));

            return $this->redirect($redirectUrl);
        «ELSE»
            $redirectUrl = $this->serviceManager->get('router')->generate('«app.appName.formatForDB»_«name.formatForCode»_view', array('lct' => $legacyControllerType));

            return new RedirectResponse(System::normalizeUrl($redirectUrl));
        «ENDIF»
    '''

    def private actionImplBodyAjaxView(ViewAction it) '''
        «IF app.targets('1.3.5')»
            $entityClass = $this->name . '_Entity_' . ucwords($objectType);
            $repository = $this->entityManager->getRepository($entityClass);
            $repository->setControllerArguments(array());
        «ELSE»
            $repository = $this->serviceManager->get('«app.appName.formatForDB».' . $objectType . '_factory')->getRepository();
            $repository->setRequest($this->request);
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
            $sortdir = $this->request->query->filter('sortdir', '', FILTER_SANITIZE_STRING);
        «ELSE»
            $sortdir = $request->query->filter('sortdir', '', false, FILTER_SANITIZE_STRING);
        «ENDIF»
        $sortdir = strtolower($sortdir);
        if ($sortdir != 'asc' && $sortdir != 'desc') {
            $sortdir = 'asc';
        }

        // convenience vars to make code clearer
        $currentUrlArgs = array('ot' => $objectType);

        «IF app.targets('1.3.5')»
            $where = $this->request->query->filter('where', '');
        «ELSE»
            $where = $request->query->filter('where', '', false);
        «ENDIF»
        $where = str_replace('"', '', $where);

        $selectionArgs = array(
            'ot' => $objectType,
            'where' => $where,
            'orderBy' => $sort . ' ' . $sortdir
        );

        «prepareViewUrlArgs(false)»

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

        $resultsPerPage = 0;
        if ($showAllEntries == 1) {
            // retrieve item list without pagination
            $entities = ModUtil::apiFunc($this->name, 'selection', 'getEntities', $selectionArgs);
            $objectCount = count($entities);
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

            // retrieve item list with pagination
            $selectionArgs['currentPage'] = $currentPage;
            $selectionArgs['resultsPerPage'] = $resultsPerPage;
            list($entities, $objectCount) = ModUtil::apiFunc($this->name, 'selection', 'getEntitiesPaginated', $selectionArgs);
        }

        foreach ($entities as $k => $entity) {
            $entity->initWorkflow();
        }
        «prepareViewItemsAjax(controller)»
    '''

    def private dispatch actionImplBody(ViewAction it) '''
        «IF controller instanceof AjaxController»
            «actionImplBodyAjaxView»
        «ELSE»
            «redirectLegacyAction»
        «ENDIF»
    '''

    def private dispatch actionImplBody(Entity it, ViewAction action) '''
        «IF app.targets('1.3.5')»
            $entityClass = $this->name . '_Entity_' . ucwords($objectType);
            $repository = $this->entityManager->getRepository($entityClass);
            $repository->setControllerArguments(array());
        «ELSE»
            $repository = $this->serviceManager->get('«app.appName.formatForDB».' . $objectType . '_factory')->getRepository();
            $repository->setRequest($this->request);
        «ENDIF»
        «IF app.targets('1.3.5')»
            $viewHelper = new «app.appName»_Util_View($this->serviceManager);
        «ELSE»
            $viewHelper = $this->serviceManager->get('«app.appName.formatForDB».view_helper');
        «ENDIF»
        «IF tree != EntityTreeType.NONE»

            $tpl = $«IF app.targets('1.3.5')»this->«ENDIF»request->query->filter('tpl', '', «IF !app.targets('1.3.5')»false, «ENDIF»FILTER_SANITIZE_STRING);
            if ($tpl == 'tree') {
                $trees = ModUtil::apiFunc($this->name, 'selection', 'getAllTrees', array('ot' => $objectType));
                $this->view->assign('trees', $trees)
                           ->assign($repository->getAdditionalTemplateParameters('controllerAction', $utilArgs));
                // fetch and return the appropriate template
                return $viewHelper->processTemplate($this->view, $objectType, 'view', «IF app.targets('1.3.5')»array()«ELSE»$request«ENDIF»);
            }
        «ENDIF»

        // parameter for used sorting field
        «IF app.targets('1.3.5')»
            $sort = $this->request->query->filter('sort', '', FILTER_SANITIZE_STRING);
        «ENDIF»
        «new ControllerHelper().defaultSorting(it)»

        «IF app.targets('1.3.5')»
            // parameter for used sort order
            $sortdir = $this->request->query->filter('sortdir', '', FILTER_SANITIZE_STRING);
            $sortdir = strtolower($sortdir);
            if ($sortdir != 'asc' && $sortdir != 'desc') {
                $sortdir = 'asc';
            }
        «ELSE»
            // parameter for used sort order
            $sortdir = strtolower($sortdir);
        «ENDIF»

        // convenience vars to make code clearer
        $currentUrlArgs = array();

        $where = '';

        $selectionArgs = array(
            'ot' => $objectType,
            'where' => $where,
            'orderBy' => $sort . ' ' . $sortdir
        );

        «prepareViewUrlArgs(true)»

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

        $templateFile = $viewHelper->getViewTemplate($this->view, $objectType, 'view', «IF app.targets('1.3.5')»array()«ELSE»$request«ENDIF»);
        $cacheId = 'view|ot_' . $objectType . '_sort_' . $sort . '_' . $sortdir;
        $resultsPerPage = 0;
        if ($showAllEntries == 1) {
            // set cache id
            $this->view->setCacheId($cacheId . '_all_1_own_' . $showOwnEntries . '_' . $accessLevel);

            // if page is cached return cached content
            if ($this->view->is_cached($templateFile)) {
                return $viewHelper->processTemplate($this->view, $objectType, 'view', «IF app.targets('1.3.5')»array()«ELSE»$request«ENDIF», $templateFile);
            }

            // retrieve item list without pagination
            $entities = ModUtil::apiFunc($this->name, 'selection', 'getEntities', $selectionArgs);
        } else {
            // the current offset which is used to calculate the pagination
            «IF app.targets('1.3.5')»
                $currentPage = (int) $this->request->query->filter('pos', 1, FILTER_VALIDATE_INT);
            «ELSE»
                $currentPage = $pos;
            «ENDIF»

            // the number of items displayed on a page for pagination
            «IF app.targets('1.3.5')»
                $resultsPerPage = (int) $this->request->query->filter('num', 0, FILTER_VALIDATE_INT);
            «ELSE»
                $resultsPerPage = $num;
            «ENDIF»
            if ($resultsPerPage == 0) {
                $resultsPerPage = $this->getVar('pageSize', 10);
            }

            // set cache id
            $this->view->setCacheId($cacheId . '_amount_' . $resultsPerPage . '_page_' . $currentPage . '_own_' . $showOwnEntries . '_' . $accessLevel);

            // if page is cached return cached content
            if ($this->view->is_cached($templateFile)) {
                return $viewHelper->processTemplate($this->view, $objectType, 'view', «IF app.targets('1.3.5')»array()«ELSE»$request«ENDIF», $templateFile);
            }

            // retrieve item list with pagination
            $selectionArgs['currentPage'] = $currentPage;
            $selectionArgs['resultsPerPage'] = $resultsPerPage;
            list($entities, $objectCount) = ModUtil::apiFunc($this->name, 'selection', 'getEntitiesPaginated', $selectionArgs);

            $this->view->assign('currentPage', $currentPage)
                       ->assign('pager', array('numitems'     => $objectCount,
                                               'itemsperpage' => $resultsPerPage));
        }

        foreach ($entities as $k => $entity) {
            $entity->initWorkflow();
        }
        «prepareViewItemsEntity»
    '''

    def private prepareViewUrlArgs(NamedObject it, Boolean hasView) '''
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
                $csv = $request->getRequestFormat() == 'csv' ? 1 : 0;
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
    '''

    def private prepareViewItemsEntity(Entity it) '''

        // build ModUrl instance for display hooks
        $currentUrlObject = new «IF app.targets('1.3.5')»Zikula_«ENDIF»ModUrl($this->name, '«name.formatForCode»', 'view', ZLanguage::getLanguageCode(), $currentUrlArgs);

        // assign the object data, sorting information and details for creating the pager
        $this->view->assign('items', $entities)
                   ->assign('sort', $sort)
                   ->assign('sdir', $sortdir)
                   ->assign('pageSize', $resultsPerPage)
                   ->assign('currentUrlObject', $currentUrlObject)
                   ->assign($repository->getAdditionalTemplateParameters('controllerAction', $utilArgs));

        «IF app.targets('1.3.5')»
            $modelHelper = new «app.appName»_Util_Model($this->serviceManager);
        «ELSE»
            $modelHelper = $this->serviceManager->get('«app.appName.formatForDB».model_helper');
        «ENDIF»
        $this->view->assign('canBeCreated', $modelHelper->canBeCreated($objectType));

        // fetch and return the appropriate template
        return $viewHelper->processTemplate($this->view, $objectType, 'view', «IF app.targets('1.3.5')»array()«ELSE»$request«ENDIF», $templateFile);
    '''

    def private prepareViewItemsAjax(Controller it) '''
        $items = array();
        «IF app.hasListFields»
            «IF app.targets('1.3.5')»
                $listHelper = new «app.appName»_Util_ListEntries($this->serviceManager);
            «ELSE»
                $listHelper = $this->serviceManager->get('«app.appName.formatForDB».listentries_helper');
            «ENDIF»

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

        $result = array('objectCount' => $objectCount,
                        'items' => $items);

        return new «IF app.targets('1.3.5')»Zikula_Response_Ajax«ELSE»AjaxResponse«ENDIF»($result);
    '''

    def private dispatch actionImplBody(DisplayAction it) '''
        «IF controller instanceof AjaxController»
            «actionImplBodyAjaxDisplay»
        «ELSE»
            «redirectLegacyAction»
        «ENDIF»
    '''

    def private actionImplBodyAjaxDisplay(DisplayAction it) '''
        «IF app.targets('1.3.5')»
            $entityClass = $this->name . '_Entity_' . ucwords($objectType);
            $repository = $this->entityManager->getRepository($entityClass);
            $repository->setControllerArguments(array());
        «ELSE»
            $repository = $this->serviceManager->get('«app.appName.formatForDB».' . $objectType . '_factory')->getRepository();
            $repository->setRequest($this->request);
        «ENDIF»

        $idFields = ModUtil::apiFunc($this->name, 'selection', 'getIdFields', array('ot' => $objectType));

        // retrieve identifier of the object we wish to view
        $idValues = $controllerHelper->retrieveIdentifier($this->request, array(), $objectType, $idFields);
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

        $entity->initWorkflow();

        $instanceId = $entity->createCompositeIdentifier();

        «permissionCheck("' . ucwords($objectType) . '", "$instanceId . ")»

        $result = array(
            'result' => true,
            $objectType => $entity->toArray()
        );

        return new «IF app.targets('1.3.5')»Zikula_Response_Ajax«ELSE»AjaxResponse«ENDIF»($result);
    '''

    def private dispatch actionImplBody(Entity it, DisplayAction action) '''
        «IF app.targets('1.3.5')»
            $entityClass = $this->name . '_Entity_' . ucwords($objectType);
            $repository = $this->entityManager->getRepository($entityClass);
            $repository->setControllerArguments(array());

            $idFields = ModUtil::apiFunc($this->name, 'selection', 'getIdFields', array('ot' => $objectType));

            // retrieve identifier of the object we wish to view
            $idValues = $controllerHelper->retrieveIdentifier($this->request, array(), $objectType, $idFields);
            $hasIdentifier = $controllerHelper->isValidIdentifier($idValues);

            $this->throwNotFoundUnless($hasIdentifier, $this->__('Error! Invalid identifier received.'));

            $selectionArgs = array('ot' => $objectType, 'id' => $idValues);
            «IF hasSluggableFields»
                if ($legacyControllerType == 'user') {
                    $selectionArgs['slug'] = $slug;
                }
            «ENDIF»

            $entity = ModUtil::apiFunc($this->name, 'selection', 'getEntity', $selectionArgs);
            $this->throwNotFoundUnless($entity != null, $this->__('No such item.'));
            unset($idValues);
        «ELSE»
            $repository = $this->serviceManager->get('«app.appName.formatForDB».' . $objectType . '_factory')->getRepository();

            $entity = $«name.formatForCode»;
        «ENDIF»

        $entity->initWorkflow();

        «prepareDisplayPermissionCheck»

        «action.permissionCheck("' . ucwords($objectType) . '", "$instanceId . ")»

        «processDisplayOutput»
    '''

    def private prepareDisplayPermissionCheck(Entity it) '''
        // build ModUrl instance for display hooks; also create identifier for permission check
        $currentUrlArgs = $entity->createUrlArgs();
        $instanceId = $entity->createCompositeIdentifier();
        $currentUrlArgs['id'] = $instanceId; // TODO remove this
        $currentUrlObject = new «IF app.targets('1.3.5')»Zikula_«ENDIF»ModUrl($this->name, '«name.formatForCode»', 'display', ZLanguage::getLanguageCode(), $currentUrlArgs);
    '''

    def private processDisplayOutput(Entity it) '''
        «IF app.targets('1.3.5')»
            $viewHelper = new «app.appName»_Util_View($this->serviceManager);
        «ELSE»
            $viewHelper = $this->serviceManager->get('«app.appName.formatForDB».view_helper');
        «ENDIF»
        $templateFile = $viewHelper->getViewTemplate($this->view, $objectType, 'display', «IF app.targets('1.3.5')»array()«ELSE»$request«ENDIF»);

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
        return $viewHelper->processTemplate($this->view, $objectType, 'display', «IF app.targets('1.3.5')»array()«ELSE»$request«ENDIF», $templateFile);
    '''

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

        $instanceId = $entity->createCompositeIdentifier();

        «permissionCheck("' . ucwords($objectType) . '", "$instanceId . ")»

        $result = array(
            'result' => false,
            $objectType => $entity->toArray()
        );

        $hookAreaPrefix = $entity->getHookAreaPrefix();
        $hookType = 'validate_edit';
        // Let any hooks perform additional validation actions
        «IF app.targets('1.3.5')»
            $hook = new Zikula_ValidationHook($hookAreaPrefix . '.' . $hookType, new Zikula_Hook_ValidationProviders());
            $validators = $this->notifyHooks($hook)->getValidators();
        «ELSE»
            $hook = new ValidationHook(new ValidationProviders());
            $validators = $this->dispatchHooks($hookAreaPrefix . '.' . $hookType, $hook)->getValidators();
        «ENDIF»
        if (!$validators->hasErrors()) {
            foreach ($idFields as $idField) {
                unset($data[$idField]);
            }
            foreach ($data as $key => $value) {
                $entity[$key] = $value;
            }
            $this->entityManager->persist($entity);
            $this->entityManager->flush();

            $hookType = 'process_edit';
            $url = null;
            if ($action != 'delete') {
                $urlArgs = $entity->createUrlArgs();
                $url = new «IF app.targets('1.3.5')»Zikula_«ENDIF»ModUrl($this->name, «IF app.targets('1.3.5')»FormUtil::getPassedValue('type', 'user', 'GETPOST')«ELSE»$objectType«ENDIF», 'display', ZLanguage::getLanguageCode(), $urlArgs);
            }

            «IF app.targets('1.3.5')»
                $hook = new Zikula_ProcessHook($hookAreaPrefix . '.' . $hookType, $entity->createCompositeIdentifier(), $url);
                $this->notifyHooks($hook);
            «ELSE»
                $hook = new ProcessHook($entity->createCompositeIdentifier(), $url);
                $this->dispatchHooks($hookAreaPrefix . '.' . $hookType, $hook);

                $logger = $this->serviceManager->get('logger');
                $logger->notice('{app}: User {user} updated the {entity} with id {id} using ajax.', array('app' => '«app.appName»', 'user' => UserUtil::getVar('uname'), 'entity' => $objectType, 'id' => $instanceId));
            «ENDIF»
        }

        $result = array(
            'result' => true,
            $objectType => $entity->toArray()
        );

        return new «IF app.targets('1.3.5')»Zikula_Response_Ajax«ELSE»AjaxResponse«ENDIF»($result);
                    '''
            default: '''
        «redirectLegacyAction»
                    '''
        }
    }

    def private dispatch actionImplBody(Entity it, EditAction action) '''
        «/* new ActionHandler().formCreate(appName, controller.formattedName, 'edit')*/»
        // create new Form reference
        $view = FormUtil::newForm($this->name, $this);

        // build form handler class name
        «IF app.targets('1.3.5')»
            $handlerClass = $this->name . '_Form_Handler_«name.formatForCodeCapital»_Edit';
        «ELSE»
            $handlerClass = '\\«app.vendor.formatForCodeCapital»\\«app.name.formatForCodeCapital»Module\\Form\\Handler\\«name.formatForCodeCapital»\\EditHandler';
        «ENDIF»

        // determine the output template
        «IF app.targets('1.3.5')»
            $viewHelper = new «app.appName»_Util_View($this->serviceManager);
        «ELSE»
            $viewHelper = $this->serviceManager->get('«app.appName.formatForDB».view_helper');
        «ENDIF»
        $template = $viewHelper->getViewTemplate($this->view, $objectType, 'edit', «IF app.targets('1.3.5')»array()«ELSE»$request«ENDIF»);

        // execute form using supplied template and page event handler
        return «IF !app.targets('1.3.5')»new Response(«ENDIF»$view->execute($template, new $handlerClass())«IF !app.targets('1.3.5')»)«ENDIF»;
    '''

    def private dispatch actionImplBody(DeleteAction it) '''
        «redirectLegacyAction»
    '''

    def private dispatch actionImplBody(Entity it, DeleteAction action) '''
        «IF app.targets('1.3.5')»
            $idFields = ModUtil::apiFunc($this->name, 'selection', 'getIdFields', array('ot' => $objectType));

            // retrieve identifier of the object we wish to delete
            $idValues = $controllerHelper->retrieveIdentifier($this->request, array(), $objectType, $idFields);
            $hasIdentifier = $controllerHelper->isValidIdentifier($idValues);

            $this->throwNotFoundUnless($hasIdentifier, $this->__('Error! Invalid identifier received.'));

            $selectionArgs = array('ot' => $objectType, 'id' => $idValues);
            «IF hasSluggableFields»
                if ($legacyControllerType == 'user') {
                    $selectionArgs['slug'] = $slug;
                }
            «ENDIF»

            $entity = ModUtil::apiFunc($this->name, 'selection', 'getEntity', $selectionArgs);
            $this->throwNotFoundUnless($entity != null, $this->__('No such item.'));
        «ELSE»
            $entity = $«name.formatForCode»;
        «ENDIF»

        $entity->initWorkflow();

        «IF app.targets('1.3.5')»
            $workflowHelper = new «app.appName»_Util_Workflow($this->serviceManager);
        «ELSE»
            $workflowHelper = $this->serviceManager->get('«app.appName.formatForDB».workflow_helper');
        «ENDIF»
        $deleteActionId = 'delete';
        $deleteAllowed = false;
        $actions = $workflowHelper->getActionsForObject($entity);
        if ($actions === false || !is_array($actions)) {
            «IF app.targets('1.3.5')»
                return LogUtil::registerError($this->__('Error! Could not determine workflow actions.'));
            «ELSE»
                $this->request->getSession()->getFlashBag()->add('error', $this->__('Error! Could not determine workflow actions.'));
                $logger = $this->serviceManager->get('logger');
                $logger->error('{app}: User {user} tried to delete the {entity} with id {id}, but failed to determine available workflow actions.', array('app' => '«app.appName»', 'user' => UserUtil::getVar('uname'), 'entity' => '«name.formatForDisplay»', 'id' => $entity->createCompositeIdentifier()));
                return false;
            «ENDIF»
        }
        foreach ($actions as $actionId => $action) {
            if ($actionId != $deleteActionId) {
                continue;
            }
            $deleteAllowed = true;
            break;
        }
        if (!$deleteAllowed) {
            «IF app.targets('1.3.5')»
                return LogUtil::registerError($this->__('Error! It is not allowed to delete this «name.formatForDisplay».'));
            «ELSE»
                $this->request->getSession()->getFlashBag()->add('error', $this->__('Error! It is not allowed to delete this «name.formatForDisplay».'));
                $logger = $this->serviceManager->get('logger');
                $logger->error('{app}: User {user} tried to delete the {entity} with id {id}, but this action was not allowed.', array('app' => '«app.appName»', 'user' => UserUtil::getVar('uname'), 'entity' => '«name.formatForDisplay»', 'id' => $entity->createCompositeIdentifier()));
                return false;
            «ENDIF»
        }

        $confirmation = (bool) $«IF app.targets('1.3.5')»this->«ENDIF»request->request->filter('confirmation', false, «IF !app.targets('1.3.5')»false, «ENDIF»FILTER_VALIDATE_BOOLEAN);
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
                    «IF app.targets('1.3.5')»
                        $this->registerStatus($this->__('Done! Item deleted.'));
                    «ELSE»
                        $this->request->getSession()->getFlashBag()->add('status', $this->__('Done! Item deleted.'));
                        $logger = $this->serviceManager->get('logger');
                        $logger->notice('{app}: User {user} deleted the {entity} with id {id}.', array('app' => '«app.appName»', 'user' => UserUtil::getVar('uname'), 'entity' => '«name.formatForDisplay»', 'id' => $entity->createCompositeIdentifier()));
                    «ENDIF»
                }

                // Let any hooks know that we have created, updated or deleted the «name.formatForDisplay»
                $hookType = 'process_delete';
                «IF app.targets('1.3.5')»
                    $hook = new Zikula_ProcessHook($hookAreaPrefix . '.' . $hookType, $entity->createCompositeIdentifier());
                    $this->notifyHooks($hook);
                «ELSE»
                    $hook = new ProcessHook($entity->createCompositeIdentifier());
                    $this->dispatchHooks($hookAreaPrefix . '.' . $hookType, $hook);
                «ENDIF»

                // The «name.formatForDisplay» was deleted, so we clear all cached pages this item.
                $cacheArgs = array('ot' => $objectType, 'item' => $entity);
                ModUtil::apiFunc($this->name, 'cache', 'clearItemCache', $cacheArgs);

                «IF app.hasAdminController && app.hasUserController»
                if ($legacyControllerType == 'admin') {
                    «redirectAfterDeletion(app.getAllAdminControllers.head)»
                } else {
                    «redirectAfterDeletion(app.getMainUserController)»
                }
                «ELSEIF app.hasAdminController»
                    «redirectAfterDeletion(app.getAllAdminControllers.head)»
                «ELSEIF app.hasUserController»
                    «redirectAfterDeletion(app.getMainUserController)»
                «ENDIF»
                «IF app.targets('1.3.5')»
                    return $this->redirect($redirectUrl);
                «ELSE»
                    return new RedirectResponse(System::normalizeUrl($redirectUrl));
                «ENDIF»
            }
        }

        «IF app.targets('1.3.5')»
            $entityClass = $this->name . '_Entity_' . ucwords($objectType);
            $repository = $this->entityManager->getRepository($entityClass);
        «ELSE»
            $repository = $this->serviceManager->get('«app.appName.formatForDB».' . $objectType . '_factory')->getRepository();
        «ENDIF»

        // set caching id
        $this->view->setCaching(Zikula_View::CACHE_DISABLED);

        // assign the object we loaded above
        $this->view->assign($objectType, $entity)
                   ->assign($repository->getAdditionalTemplateParameters('controllerAction', $utilArgs));

        // fetch and return the appropriate template
        «IF app.targets('1.3.5')»
            $viewHelper = new «app.appName»_Util_View($this->serviceManager);
        «ELSE»
            $viewHelper = $this->serviceManager->get('«app.appName.formatForDB».view_helper');
        «ENDIF»

        return $viewHelper->processTemplate($this->view, $objectType, 'delete', «IF app.targets('1.3.5')»array()«ELSE»$request«ENDIF»);
    '''

    def private redirectAfterDeletion(Entity it, Controller controller) '''
        «IF app.targets('1.3.5')»
            // redirect to the «IF controller.hasActions('view')»list of «nameMultiple.formatForDisplay»«ELSE»main page«ENDIF»
            $redirectUrl = ModUtil::url($this->name, '«name.formatForCode»', '«IF controller.hasActions('view')»view«ELSE»main«ENDIF»', array('lct' => $legacyControllerType));
        «ELSE»
            // redirect to the «IF controller.hasActions('view')»list of «nameMultiple.formatForDisplay»«ELSE»index page«ENDIF»
            $redirectUrl = $this->serviceManager->get('router')->generate('«app.appName.formatForDB»_«name.formatForCode»_«IF controller.hasActions('view')»view«ELSE»index«ENDIF»', array('lct' => $legacyControllerType));
        «ENDIF»
    '''

    def private dispatch actionImplBody(CustomAction it) '''
        «IF controller instanceof AdminController
            && (name == 'config' || name == 'modifyconfig' || name == 'preferences')»
            «new FormHandler().formCreate(it, app.appName, 'modify')»
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

    def private dispatch actionImplBody(Entity it, CustomAction action) '''
        /** TODO: custom logic */

        // return template
        «IF app.targets('1.3.5')»
            return $this->view->fetch('«name.formatForCode»/«action.name.formatForCode.toFirstLower».tpl');
        «ELSE»
            return $this->response($this->view->fetch('«name.formatForCodeCapital»/«action.name.formatForCode.toFirstLower».tpl'));
        «ENDIF»
    '''
}
