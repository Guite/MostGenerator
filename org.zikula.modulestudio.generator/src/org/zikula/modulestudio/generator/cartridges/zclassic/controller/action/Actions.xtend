package org.zikula.modulestudio.generator.cartridges.zclassic.controller.action

import de.guite.modulestudio.metamodel.Action
import de.guite.modulestudio.metamodel.AdminController
import de.guite.modulestudio.metamodel.AjaxController
import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Controller
import de.guite.modulestudio.metamodel.CustomAction
import de.guite.modulestudio.metamodel.DeleteAction
import de.guite.modulestudio.metamodel.DisplayAction
import de.guite.modulestudio.metamodel.EditAction
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.EntityTreeType
import de.guite.modulestudio.metamodel.MainAction
import de.guite.modulestudio.metamodel.NamedObject
import de.guite.modulestudio.metamodel.OneToManyRelationship
import de.guite.modulestudio.metamodel.OneToOneRelationship
import de.guite.modulestudio.metamodel.ViewAction
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.ControllerHelper
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.FormHandler
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Actions {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelExtensions = new ModelExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    Application app

    new(Application app) {
        this.app = app
    }

    def actionImpl(Action it) '''
        «IF it instanceof MainAction»
            // parameter specifying which type of objects we are treating
            $objectType = $«IF isLegacy»this->«ENDIF»request->query->filter('ot', '«app.getLeadingEntity.name.formatForCode»', «IF !isLegacy»false, «ENDIF»FILTER_SANITIZE_STRING);

            $permLevel = «IF controller instanceof AdminController»ACCESS_ADMIN«ELSE»«getPermissionAccessLevel»«ENDIF»;
            «permissionCheck('', '')»
        «ELSE»
            «IF isLegacy»
                $controllerHelper = new «app.appName»_Util_Controller($this->serviceManager);
            «ELSE»
                $controllerHelper = $this->get('«app.appName.formatForDB».controller_helper');
            «ENDIF»

            // parameter specifying which type of objects we are treating
            $objectType = $«IF isLegacy»this->«ENDIF»request->query->filter('ot', '«app.getLeadingEntity.name.formatForCode»', «IF !isLegacy»false, «ENDIF»FILTER_SANITIZE_STRING);
            $utilArgs = array('controller' => '«controller.formattedName»', 'action' => '«name.formatForCode.toFirstLower»');
            if (!in_array($objectType, $controllerHelper->getObjectTypes('controllerAction', $utilArgs))) {
                $objectType = $controllerHelper->getDefaultObjectType('controllerAction', $utilArgs);
            }
            $permLevel = «IF controller instanceof AdminController»ACCESS_ADMIN«ELSE»«getPermissionAccessLevel»«ENDIF»;
            «permissionCheck("' . ucfirst($objectType) . '", '')»
        «ENDIF»
        «actionImplBody»
    '''

    def private redirectLegacyAction(Action it) '''

        «IF !isLegacy»
            // forward GET parameters
            $redirectArgs = $this->request->query->«IF isLegacy»getCollection«ELSE»all«ENDIF»();

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

            $routeArea = '«IF controller instanceof AdminController»admin«ENDIF»';

        «ENDIF»
        // redirect to entity controller
        «IF isLegacy»
            «/*
            $redirectUrl = ModUtil::url($this->name, $objectType, '«name.formatForCode»', $redirectArgs);

            return $this->redirect($redirectUrl); */»
            System::queryStringSetVar('lct', '«controller.formattedName»');
            $this->request->query->set('lct', '«controller.formattedName»');

            return ModUtil::func($this->name, $objectType, '«name.formatForCode»', array('lct' => '«controller.formattedName»'));
        «ELSE»
            $logger = $this->get('logger');
            $logger->warning('{app}: The {controller} controller\'s {action} action is deprecated. Please use entity-related controllers instead.', array('app' => '«app.appName»', 'controller' => '«controller.name.formatForDisplay»', 'action' => '«name.formatForDisplay»'));

            $redirectUrl = $this->get('router')->generate('«app.appName.formatForDB»_' . strtolower($objectType) . '_' . $routeArea . '«name.formatForDB»', $redirectArgs);

            return new RedirectResponse(System::normalizeUrl($redirectUrl));
        «ENDIF»
    '''

    def actionImpl(Entity it, Action action) '''
        «IF it instanceof MainAction»
            «permissionCheck('', '')»
        «ELSE»
            «IF isLegacy»
                $controllerHelper = new «app.appName»_Util_Controller($this->serviceManager);
            «ELSE»
                $controllerHelper = $this->get('«app.appName.formatForDB».controller_helper');
            «ENDIF»

            // parameter specifying which type of objects we are treating
            $objectType = '«name.formatForCode»';
            $utilArgs = array('controller' => '«name.formatForCode»', 'action' => '«action.name.formatForCode.toFirstLower»');
            «IF isLegacy»
                $permLevel = $legacyControllerType == 'admin' ? ACCESS_ADMIN : «action.getPermissionAccessLevel»;
            «ELSE»
                $permLevel = $isAdmin ? ACCESS_ADMIN : «action.getPermissionAccessLevel»;
            «ENDIF»
            «action.permissionCheck("' . ucfirst($objectType) . '", '')»
        «ENDIF»
        «actionImplBody(it, action)»
    '''

    /**
     * Permission checks in system use cases.
     */
    def private permissionCheck(Action it, String objectTypeVar, String instanceId) '''
        «IF isLegacy»
            $this->throwForbiddenUnless(SecurityUtil::checkPermission($this->name . ':«objectTypeVar»:', «instanceId»'::', $permLevel), LogUtil::getErrorMsgPermission());
        «ELSE»
            if (!$this->hasPermission($this->name . ':«objectTypeVar»:', «instanceId»'::', $permLevel)) {
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
                // redirect to view action
                «IF isLegacy»
                    $redirectUrl = ModUtil::url($this->name, '«controller.formattedName»', 'view', array('lct' => '«controller.formattedName»'));

                    return $this->redirect($redirectUrl);
                «ELSE»
                    $routeArea = '«IF controller instanceof AdminController»admin«ENDIF»';
                    $redirectUrl = $this->get('router')->generate('«app.appName.formatForDB»_' . strtolower($objectType) . '_' . $routeArea . 'view');

                    return new RedirectResponse(System::normalizeUrl($redirectUrl));
                «ENDIF»
            «ELSEIF controller.isConfigController»
                // redirect to config action
                «IF isLegacy»
                    $redirectUrl = ModUtil::url($this->name, '«controller.formattedName»', 'config', array('lct' => '«controller.formattedName»'));

                    return $this->redirect($redirectUrl);
                «ELSE»
                    $routeArea = '«IF controller instanceof AdminController»admin«ENDIF»';
                    $redirectUrl = $this->get('router')->generate('«app.appName.formatForDB»_«controller.formattedName.toLowerCase»_' . $routeArea . 'config');

                    return new RedirectResponse(System::normalizeUrl($redirectUrl));
                «ENDIF»
            «ELSE»
                «redirectLegacyAction»
«/*                // set caching id
                «IF !isLegacy»
                    $view = Zikula_View::getInstance('«appName»', false);
                    $view->assign('routeArea', $isAdmin ? 'admin' : '');
                «ENDIF»
                $«IF isLegacy»this->«ENDIF»view->setCacheId('«IF isLegacy»main«ELSE»index«ENDIF»');

                // return «IF isLegacy»main«ELSE»index«ENDIF» template
                «IF isLegacy»
                    return $this->view->fetch('«controller.formattedName»/main.tpl');
                «ELSE»
                    return $this->response($view->fetch('«controller.formattedName.toFirstUpper»/index.tpl'));
                «ENDIF»*/»
            «ENDIF»
        «ENDIF»
    '''

    def private dispatch actionImplBody(Entity it, MainAction action) '''
        «IF app.hasAdminController && app.getAllAdminControllers.head.hasActions('view')»

            if («IF isLegacy»$legacyControllerType == 'admin'«ELSE»$isAdmin«ENDIF») {
                «redirectFromIndexToView(app.getAllAdminControllers.head)»
            }
        «ENDIF»
        «IF app.hasUserController && app.getAllUserControllers.head.hasActions('view')»

            if («IF isLegacy»$legacyControllerType == 'admin'«ELSE»!$isAdmin«ENDIF») {
                «redirectFromIndexToView(app.getMainUserController)»
            }
        «ENDIF»

        // set caching id
        «IF !isLegacy»
            $view = Zikula_View::getInstance('«app.appName»', false);
        «ENDIF»
        $«IF isLegacy»this->«ENDIF»view->setCacheId('«name.formatForCode»_«IF isLegacy»main«ELSE»index«ENDIF»');

        // return «IF isLegacy»main«ELSE»index«ENDIF» template
        «IF isLegacy»
            return $this->view->fetch('«name.formatForCode»/main.tpl');
        «ELSE»
            return $this->response($view->fetch('«name.formatForCodeCapital»/index.tpl'));
        «ENDIF»
    '''

    def private redirectFromIndexToView(Entity it, Controller controller) '''

        «IF isLegacy»
            $redirectUrl = ModUtil::url($this->name, '«name.formatForCode»', 'view', array('lct' => $legacyControllerType));

            return $this->redirect($redirectUrl);
        «ELSE»
            $redirectUrl = $this->get('router')->generate('«app.appName.formatForDB»_«name.formatForDB»_' . ($isAdmin ? 'admin' : '') . 'view');

            return new RedirectResponse(System::normalizeUrl($redirectUrl));
        «ENDIF»
    '''

    def private actionImplBodyAjaxView(ViewAction it) '''
        «IF isLegacy»
            $entityClass = $this->name . '_Entity_' . ucfirst($objectType);
            $repository = $this->entityManager->getRepository($entityClass);
            $repository->setControllerArguments(array());
        «ELSE»
            $repository = $this->get('«app.appName.formatForDB».' . $objectType . '_factory')->getRepository();
            $repository->setRequest($request);
        «ENDIF»

        // parameter for used sorting field
        «IF isLegacy»
            $sort = $this->request->query->filter('sort', '', FILTER_SANITIZE_STRING);
        «ELSE»
            $sort = $request->query->filter('sort', '', false, FILTER_SANITIZE_STRING);
        «ENDIF»
        «new ControllerHelper().defaultSorting(it, app)»

        // parameter for used sort order
        «IF isLegacy»
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

        «IF isLegacy»
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
        $component = '«app.appName»:' . ucfirst($objectType) . ':';
        $instance = '::';
        if («IF isLegacy»SecurityUtil::check«ELSE»$this->has«ENDIF»Permission($component, $instance, ACCESS_COMMENT)) {
            $accessLevel = ACCESS_COMMENT;
        }
        if («IF isLegacy»SecurityUtil::check«ELSE»$this->has«ENDIF»Permission($component, $instance, ACCESS_EDIT)) {
            $accessLevel = ACCESS_EDIT;
        }

        $resultsPerPage = 0;
        if ($showAllEntries == 1) {
            // retrieve item list without pagination
            $entities = ModUtil::apiFunc($this->name, 'selection', 'getEntities', $selectionArgs);
            $objectCount = count($entities);
        } else {
            // the current offset which is used to calculate the pagination
            «IF isLegacy»
                $currentPage = (int) $this->request->query->filter('pos', 1, FILTER_VALIDATE_INT);
            «ELSE»
                $currentPage = (int) $request->query->filter('pos', 1, false, FILTER_VALIDATE_INT);
            «ENDIF»

            // the number of items displayed on a page for pagination
            «IF isLegacy»
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
        «IF isLegacy»
            $entityClass = $this->name . '_Entity_' . ucfirst($objectType);
            $repository = $this->entityManager->getRepository($entityClass);
            $repository->setControllerArguments(array());
        «ELSE»
            // temporary workarounds
            // let repository know if we are in admin or user area
            $request->query->set('lct', $isAdmin ? 'admin' : 'user');
            // let entities know if we are in admin or user area
            System::queryStringSetVar('lct', $isAdmin ? 'admin' : 'user');

            $repository = $this->get('«app.appName.formatForDB».' . $objectType . '_factory')->getRepository();
            $repository->setRequest($request);
        «ENDIF»
        «IF isLegacy»
            $viewHelper = new «app.appName»_Util_View($this->serviceManager);
        «ELSE»
            $view = Zikula_View::getInstance('«app.appName»', false);
            $view->assign('routeArea', $isAdmin ? 'admin' : '');
            $viewHelper = $this->get('«app.appName.formatForDB».view_helper');
        «ENDIF»
        «IF tree != EntityTreeType.NONE»

            $tpl = $«IF isLegacy»this->«ENDIF»request->query->filter('tpl', '', «IF !isLegacy»false, «ENDIF»FILTER_SANITIZE_STRING);
            if ($tpl == 'tree') {
                $trees = ModUtil::apiFunc($this->name, 'selection', 'getAllTrees', array('ot' => $objectType));
                $«IF isLegacy»this->«ENDIF»view->assign('trees', $trees)
                «IF isLegacy»      «ENDIF»     ->assign($repository->getAdditionalTemplateParameters('controllerAction', $utilArgs));
                // fetch and return the appropriate template
                return $viewHelper->processTemplate($«IF isLegacy»this->«ENDIF»view, $objectType, 'view', «IF isLegacy»array()«ELSE»$request«ENDIF»);
            }
        «ENDIF»

        // convenience vars to make code clearer
        $currentUrlArgs = array();
        $where = '';

        «prepareViewUrlArgs(true)»

        $additionalParameters = $repository->getAdditionalTemplateParameters('controllerAction', $utilArgs);

        $resultsPerPage = 0;
        if ($showAllEntries != 1) {
            // the number of items displayed on a page for pagination
            «IF isLegacy»
                $resultsPerPage = (int) $this->request->query->filter('num', 0, FILTER_VALIDATE_INT);
            «ELSE»
                $resultsPerPage = $num;
            «ENDIF»
            if ($resultsPerPage == 0) {
                $resultsPerPage = $this->getVar('pageSize', 10);
            }
        }

        // parameter for used sorting field
        «IF isLegacy»
            $sort = $this->request->query->filter('sort', '', FILTER_SANITIZE_STRING);
        «ENDIF»
        «new ControllerHelper().defaultSorting(it, app)»

        «IF isLegacy»
            // parameter for used sort order
            $sortdir = $this->request->query->filter('sortdir', '', FILTER_SANITIZE_STRING);
            $sortdir = strtolower($sortdir);
            if ($sortdir != 'asc' && $sortdir != 'desc') {
                $sortdir = 'asc';
            }
        «ELSE»
            // parameter for used sort order
            $sortdir = strtolower($sortdir);

            «sortableColumns»
        «ENDIF»

        $selectionArgs = array(
            'ot' => $objectType,
            'where' => $where,
            'orderBy' => $sort . ' ' . $sortdir
        );

        // prepare access level for cache id
        $accessLevel = ACCESS_READ;
        $component = '«app.appName»:' . ucfirst($objectType) . ':';
        $instance = '::';
        if («IF isLegacy»SecurityUtil::check«ELSE»$this->has«ENDIF»Permission($component, $instance, ACCESS_COMMENT)) {
            $accessLevel = ACCESS_COMMENT;
        }
        if («IF isLegacy»SecurityUtil::check«ELSE»$this->has«ENDIF»Permission($component, $instance, ACCESS_EDIT)) {
            $accessLevel = ACCESS_EDIT;
        }

        $templateFile = $viewHelper->getViewTemplate($«IF isLegacy»this->«ENDIF»view, $objectType, 'view', «IF isLegacy»array()«ELSE»$request«ENDIF»);
        $cacheId = $objectType . '_view|_sort_' . $sort . '_' . $sortdir;
        if ($showAllEntries == 1) {
            // set cache id
            $«IF isLegacy»this->«ENDIF»view->setCacheId($cacheId . '_all_1_own_' . $showOwnEntries . '_' . $accessLevel);

            // if page is cached return cached content
            if ($«IF isLegacy»this->«ENDIF»view->is_cached($templateFile)) {
                return $viewHelper->processTemplate($«IF isLegacy»this->«ENDIF»view, $objectType, 'view', «IF isLegacy»array()«ELSE»$request«ENDIF», $templateFile);
            }

            // retrieve item list without pagination
            $entities = ModUtil::apiFunc($this->name, 'selection', 'getEntities', $selectionArgs);
        } else {
            // the current offset which is used to calculate the pagination
            «IF isLegacy»
                $currentPage = (int) $this->request->query->filter('pos', 1, FILTER_VALIDATE_INT);
            «ELSE»
                $currentPage = $pos;
            «ENDIF»

            // set cache id
            $«IF isLegacy»this->«ENDIF»view->setCacheId($cacheId . '_amount_' . $resultsPerPage . '_page_' . $currentPage . '_own_' . $showOwnEntries . '_' . $accessLevel);

            // if page is cached return cached content
            if ($«IF isLegacy»this->«ENDIF»view->is_cached($templateFile)) {
                return $viewHelper->processTemplate($«IF isLegacy»this->«ENDIF»view, $objectType, 'view', «IF isLegacy»array()«ELSE»$request«ENDIF», $templateFile);
            }

            // retrieve item list with pagination
            $selectionArgs['currentPage'] = $currentPage;
            $selectionArgs['resultsPerPage'] = $resultsPerPage;
            list($entities, $objectCount) = ModUtil::apiFunc($this->name, 'selection', 'getEntitiesPaginated', $selectionArgs);

            $«IF isLegacy»this->«ENDIF»view->assign('currentPage', $currentPage)
            «IF isLegacy»      «ENDIF»     ->assign('pager', array('numitems'     => $objectCount,
            «IF isLegacy»      «ENDIF»                             'itemsperpage' => $resultsPerPage));
        }

        foreach ($entities as $k => $entity) {
            $entity->initWorkflow();
        }
        «prepareViewItemsEntity»
    '''

    def private sortableColumns(Entity it) '''
        $sortableColumns = new SortableColumns($this->get('router'), '«app.appName.formatForDB»_«name.toLowerCase»_' . ($isAdmin ? 'admin' : '') . 'view', 'sort', 'sortdir');
        «val listItemsFields = getDisplayFieldsForView»
        «val listItemsIn = incoming.filter(OneToManyRelationship).filter[bidirectional && source instanceof Entity]»
        «val listItemsOut = outgoing.filter(OneToOneRelationship).filter[target instanceof Entity]»
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
            «addSortColumn('createdUserId')»
            «addSortColumn('createdDate')»
            «addSortColumn('updatedUserId')»
            «addSortColumn('updatedDate')»
        «ENDIF»
        $sortableColumns->setOrderBy($sortableColumns->getColumn($sort), strtoupper($sortdir));

        $additionalUrlParameters = array(
            'all' => $showAllEntries,
            'own' => $showOwnEntries,
            'pageSize' => $resultsPerPage
        );
        $additionalUrlParameters = array_merge($additionalUrlParameters, $additionalParameters);
        $sortableColumns->setAdditionalUrlParameters($additionalUrlParameters);
    '''

    def private addSortColumn(Entity it, String columnName) '''
        $sortableColumns->addColumn(new Column('«columnName.formatForCode»'));
    '''

    def private prepareViewUrlArgs(NamedObject it, Boolean hasView) '''
        «IF isLegacy»
            $showOwnEntries = (int) $this->request->query->filter('own', $this->getVar('showOnlyOwnEntries', 0), FILTER_VALIDATE_INT);
            $showAllEntries = (int) $this->request->query->filter('all', 0, FILTER_VALIDATE_INT);
        «ELSE»
            $showOwnEntries = (int) $request->query->filter('own', $this->getVar('showOnlyOwnEntries', 0), false, FILTER_VALIDATE_INT);
            $showAllEntries = (int) $request->query->filter('all', 0, false, FILTER_VALIDATE_INT);
        «ENDIF»

        if (!$showAllEntries) {
            «IF isLegacy»
                $csv = (int) $this->request->query->filter('usecsvext', 0, FILTER_VALIDATE_INT);
            «ELSE»
                $csv = $request->getRequestFormat() == 'csv' ? 1 : 0;
            «ENDIF»
            if ($csv == 1) {
                $showAllEntries = 1;
            }
        }

        «IF hasView»
            $«IF isLegacy»this->«ENDIF»view->assign('showOwnEntries', $showOwnEntries)
            «IF isLegacy»      «ENDIF»     ->assign('showAllEntries', $showAllEntries);
        «ENDIF»
        if ($showOwnEntries == 1) {
            $currentUrlArgs['own'] = 1;
        }
        if ($showAllEntries == 1) {
            $currentUrlArgs['all'] = 1;
        }
    '''

    def private prepareViewItemsEntity(Entity it) '''
        «IF !skipHookSubscribers»

            // build ModUrl instance for display hooks
            $currentUrlObject = new «IF isLegacy»Zikula_«ENDIF»ModUrl($this->name, '«name.formatForCode»', 'view', ZLanguage::getLanguageCode(), $currentUrlArgs);
        «ENDIF»

        // assign the object data, sorting information and details for creating the pager
        $«IF isLegacy»this->«ENDIF»view->assign('items', $entities)
                   «IF isLegacy»
        «IF isLegacy»      «ENDIF»     ->assign('sort', $sort)
                   «ELSE»
        «IF isLegacy»      «ENDIF»     ->assign('sort', $sortableColumns->generateSortableColumns())
                   «ENDIF»
        «IF isLegacy»      «ENDIF»     ->assign('sdir', $sortdir)
        «IF isLegacy»      «ENDIF»     ->assign('pageSize', $resultsPerPage)
        «IF isLegacy»      «ENDIF»     ->assign('currentUrlObject', $currentUrlObject)
        «IF isLegacy»      «ENDIF»     ->assign($additionalParameters);

        «IF isLegacy»
            $modelHelper = new «app.appName»_Util_Model($this->serviceManager);
        «ELSE»
            $modelHelper = $this->get('«app.appName.formatForDB».model_helper');
        «ENDIF»
        $«IF isLegacy»this->«ENDIF»view->assign('canBeCreated', $modelHelper->canBeCreated($objectType));

        // fetch and return the appropriate template
        return $viewHelper->processTemplate($«IF isLegacy»this->«ENDIF»view, $objectType, 'view', «IF isLegacy»array()«ELSE»$request«ENDIF», $templateFile);
    '''

    def private prepareViewItemsAjax(Controller it) '''
        $items = array();
        «IF app.hasListFields»
            «IF isLegacy»
                $listHelper = new «app.appName»_Util_ListEntries($this->serviceManager);
            «ELSE»
                $listHelper = $this->get('«app.appName.formatForDB».listentries_helper');
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

        return new «IF isLegacy»Zikula_Response_Ajax«ELSE»AjaxResponse«ENDIF»($result);
    '''

    def private dispatch actionImplBody(DisplayAction it) '''
        «IF controller instanceof AjaxController»
            «actionImplBodyAjaxDisplay»
        «ELSE»
            «redirectLegacyAction»
        «ENDIF»
    '''

    def private actionImplBodyAjaxDisplay(DisplayAction it) '''
        «IF isLegacy»
            $entityClass = $this->name . '_Entity_' . ucfirst($objectType);
            $repository = $this->entityManager->getRepository($entityClass);
            $repository->setControllerArguments(array());
        «ELSE»
            $repository = $this->get('«app.appName.formatForDB».' . $objectType . '_factory')->getRepository();
            $repository->setRequest($request);
        «ENDIF»

        $idFields = ModUtil::apiFunc($this->name, 'selection', 'getIdFields', array('ot' => $objectType));

        // retrieve identifier of the object we wish to view
        $idValues = $controllerHelper->retrieveIdentifier($this->request, array(), $objectType, $idFields);
        $hasIdentifier = $controllerHelper->isValidIdentifier($idValues);

        «IF isLegacy»
            $this->throwNotFoundUnless($hasIdentifier, $this->__('Error! Invalid identifier received.'));
        «ELSE»
            if (!$hasIdentifier) {
                throw new NotFoundHttpException($this->__('Error! Invalid identifier received.'));
            }
        «ENDIF»

        $entity = ModUtil::apiFunc($this->name, 'selection', 'getEntity', array('ot' => $objectType, 'id' => $idValues));
        «IF isLegacy»
            $this->throwNotFoundUnless($entity != null, $this->__('No such item.'));
        «ELSE»
            if ($entity === null) {
                throw new NotFoundHttpException($this->__('No such item.'));
            }
        «ENDIF»
        unset($idValues);

        $entity->initWorkflow();

        $instanceId = $entity->createCompositeIdentifier();

        «permissionCheck("' . ucfirst($objectType) . '", "$instanceId . ")»

        $result = array(
            'result' => true,
            $objectType => $entity->toArray()
        );

        return new «IF isLegacy»Zikula_Response_Ajax«ELSE»AjaxResponse«ENDIF»($result);
    '''

    def private dispatch actionImplBody(Entity it, DisplayAction action) '''
        «IF isLegacy»
            $entityClass = $this->name . '_Entity_' . ucfirst($objectType);
            $repository = $this->entityManager->getRepository($entityClass);
            $repository->setControllerArguments(array());

            $idFields = ModUtil::apiFunc($this->name, 'selection', 'getIdFields', array('ot' => $objectType));

            // retrieve identifier of the object we wish to view
            $idValues = $controllerHelper->retrieveIdentifier($this->request, array(), $objectType, $idFields);
            $hasIdentifier = $controllerHelper->isValidIdentifier($idValues);

            // check for unique permalinks (without id)
            $hasSlug = false;
            $slug = '';
            if ($hasIdentifier === false) {
                $entityClass = $this->name . '_Entity_' . ucfirst($objectType);
                $meta = $this->entityManager->getClassMetadata($entityClass);
                $hasSlug = $meta->hasField('slug') && $meta->isUniqueField('slug');
                if ($hasSlug) {
                    $slug = $this->request->query->filter('slug', '', FILTER_SANITIZE_STRING);
                    $hasSlug = (!empty($slug));
                }
            }
            $hasIdentifier |= $hasSlug;

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
            // temporary workarounds
            // let repository know if we are in admin or user area
            $request->query->set('lct', $isAdmin ? 'admin' : 'user');
            // let entities know if we are in admin or user area
            System::queryStringSetVar('lct', $isAdmin ? 'admin' : 'user');

            $repository = $this->get('«app.appName.formatForDB».' . $objectType . '_factory')->getRepository();
            $repository->setRequest($request);

            $entity = $«name.formatForCode»;

        «ENDIF»

        $entity->initWorkflow();

        «prepareDisplayPermissionCheck»

        «action.permissionCheck("' . ucfirst($objectType) . '", "$instanceId . ")»

        «processDisplayOutput»
    '''

    def private prepareDisplayPermissionCheck(Entity it) '''
        // «IF !skipHookSubscribers»build ModUrl instance for display hooks; also «ENDIF»create identifier for permission check
        «IF !skipHookSubscribers»
            $currentUrlArgs = $entity->createUrlArgs();
        «ENDIF»
        $instanceId = $entity->createCompositeIdentifier();
        «IF !skipHookSubscribers»
            $currentUrlArgs['id'] = $instanceId; // TODO remove this
            $currentUrlObject = new «IF isLegacy»Zikula_«ENDIF»ModUrl($this->name, '«name.formatForCode»', 'display', ZLanguage::getLanguageCode(), $currentUrlArgs);
        «ENDIF»
    '''

    def private processDisplayOutput(Entity it) '''
        «IF isLegacy»
            $viewHelper = new «app.appName»_Util_View($this->serviceManager);
        «ELSE»
            $view = Zikula_View::getInstance('«app.appName»', false);
            $view->assign('routeArea', $isAdmin ? 'admin' : '');
            $viewHelper = $this->get('«app.appName.formatForDB».view_helper');
        «ENDIF»
        $templateFile = $viewHelper->getViewTemplate($«IF isLegacy»this->«ENDIF»view, $objectType, 'display', «IF isLegacy»array()«ELSE»$request«ENDIF»);

        // set cache id
        $component = $this->name . ':' . ucfirst($objectType) . ':';
        $instance = $instanceId . '::';
        $accessLevel = ACCESS_READ;
        if («IF isLegacy»SecurityUtil::check«ELSE»$this->has«ENDIF»Permission($component, $instance, ACCESS_COMMENT)) {
            $accessLevel = ACCESS_COMMENT;
        }
        if («IF isLegacy»SecurityUtil::check«ELSE»$this->has«ENDIF»Permission($component, $instance, ACCESS_EDIT)) {
            $accessLevel = ACCESS_EDIT;
        }
        $«IF isLegacy»this->«ENDIF»view->setCacheId($objectType . '_display|' . $instanceId . '|a' . $accessLevel);

        // assign output data to view object.
        $«IF isLegacy»this->«ENDIF»view->assign($objectType, $entity)
        «IF isLegacy»      «ENDIF»     ->assign('currentUrlObject', $currentUrlObject)
        «IF isLegacy»      «ENDIF»     ->assign($repository->getAdditionalTemplateParameters('controllerAction', $utilArgs));

        // fetch and return the appropriate template
        return $viewHelper->processTemplate($«IF isLegacy»this->«ENDIF»view, $objectType, 'display', «IF isLegacy»array()«ELSE»$request«ENDIF», $templateFile);
    '''

    def private dispatch actionImplBody(EditAction it) {
        switch controller {
            AjaxController: '''
        $this->checkAjaxToken();
        $idFields = ModUtil::apiFunc($this->name, 'selection', 'getIdFields', array('ot' => $objectType));

        $data = $this->request->query->filter('data', null«IF !isLegacy», false«ENDIF»);
        $data = json_decode($data, true);

        $idValues = array();
        foreach ($idFields as $idField) {
            $idValues[$idField] = isset($data[$idField]) ? $data[$idField] : '';
        }
        $hasIdentifier = $controllerHelper->isValidIdentifier($idValues);
        «IF isLegacy»
            $this->throwNotFoundUnless($hasIdentifier, $this->__('Error! Invalid identifier received.'));
        «ELSE»
            if (!$hasIdentifier) {
                throw new NotFoundHttpException($this->__('Error! Invalid identifier received.'));
            }
        «ENDIF»

        $entity = ModUtil::apiFunc($this->name, 'selection', 'getEntity', array('ot' => $objectType, 'id' => $idValues));
        «IF isLegacy»
            $this->throwNotFoundUnless($entity != null, $this->__('No such item.'));
        «ELSE»
            if ($entity === null) {
                throw new NotFoundHttpException($this->__('No such item.'));
            }
        «ENDIF»
        unset($idValues);

        $instanceId = $entity->createCompositeIdentifier();

        «permissionCheck("' . ucfirst($objectType) . '", "$instanceId . ")»

        $result = array(
            'result' => false,
            $objectType => $entity->toArray()
        );

        $hasErrors = false;
        if ($entity->supportsHookSubscribers()) {
            $hookAreaPrefix = $entity->getHookAreaPrefix();
            $hookType = 'validate_edit';
            // Let any hooks perform additional validation actions
            «IF isLegacy»
                $hook = new Zikula_ValidationHook($hookAreaPrefix . '.' . $hookType, new Zikula_Hook_ValidationProviders());
                $validators = $this->notifyHooks($hook)->getValidators();
            «ELSE»
                $hook = new ValidationHook(new ValidationProviders());
                $validators = $this->dispatchHooks($hookAreaPrefix . '.' . $hookType, $hook)->getValidators();
            «ENDIF»
            $hasErrors = $validators->hasErrors();
        }

        if (!$hasErrors) {
            foreach ($idFields as $idField) {
                unset($data[$idField]);
            }
            foreach ($data as $key => $value) {
                $entity[$key] = $value;
            }
            $this->entityManager->persist($entity);
            $this->entityManager->flush();

            if ($entity->supportsHookSubscribers()) {
                $hookType = 'process_edit';
                $url = null;
                if ($action != 'delete') {
                    $urlArgs = $entity->createUrlArgs();
                    $url = new «IF isLegacy»Zikula_«ENDIF»ModUrl($this->name, «IF isLegacy»FormUtil::getPassedValue('type', 'user', 'GETPOST')«ELSE»$objectType«ENDIF», 'display', ZLanguage::getLanguageCode(), $urlArgs);
                }

                «IF isLegacy»
                    $hook = new Zikula_ProcessHook($hookAreaPrefix . '.' . $hookType, $entity->createCompositeIdentifier(), $url);
                    $this->notifyHooks($hook);
                «ELSE»
                    $hook = new ProcessHook($entity->createCompositeIdentifier(), $url);
                    $this->dispatchHooks($hookAreaPrefix . '.' . $hookType, $hook);
                «ENDIF»
            }
            «IF !isLegacy»

                $logger = $this->get('logger');
                $logger->notice('{app}: User {user} updated the {entity} with id {id} using ajax.', array('app' => '«app.appName»', 'user' => UserUtil::getVar('uname'), 'entity' => $objectType, 'id' => $instanceId));
            «ENDIF»
        }

        $result = array(
            'result' => true,
            $objectType => $entity->toArray()
        );

        return new «IF isLegacy»Zikula_Response_Ajax«ELSE»AjaxResponse«ENDIF»($result);
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
        «IF isLegacy»
            $handlerClass = $this->name . '_Form_Handler_«name.formatForCodeCapital»_Edit';
        «ELSE»
            $handlerClass = '\\«app.vendor.formatForCodeCapital»\\«app.name.formatForCodeCapital»Module\\Form\\Handler\\«name.formatForCodeCapital»\\EditHandler';
        «ENDIF»

        // determine the output template
        «IF isLegacy»
            $viewHelper = new «app.appName»_Util_View($this->serviceManager);
        «ELSE»
            $view->assign('routeArea', $isAdmin ? 'admin' : '');
            $viewHelper = $this->get('«app.appName.formatForDB».view_helper');
        «ENDIF»
        $template = $viewHelper->getViewTemplate($«IF isLegacy»this->«ENDIF»view, $objectType, 'edit', «IF isLegacy»array()«ELSE»$request«ENDIF»);

        «IF !isLegacy»
            // temporary workaround until Symfony forms are adopted (#416)
            // let legacy forms know if we are in admin or user area
            $request->query->set('lct', $isAdmin ? 'admin' : 'user');

        «ENDIF»
        // execute form using supplied template and page event handler
        return «IF !isLegacy»$this->response(«ENDIF»$view->execute($template, new $handlerClass())«IF !isLegacy»)«ENDIF»;
    '''

    def private dispatch actionImplBody(DeleteAction it) '''
        «redirectLegacyAction»
    '''

    def private dispatch actionImplBody(Entity it, DeleteAction action) '''
        «IF isLegacy»
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

        // determine available workflow actions
        «IF isLegacy»
            $workflowHelper = new «app.appName»_Util_Workflow($this->serviceManager);
        «ELSE»
            $workflowHelper = $this->get('«app.appName.formatForDB».workflow_helper');
        «ENDIF»
        $actions = $workflowHelper->getActionsForObject($entity);
        if ($actions === false || !is_array($actions)) {
            «IF isLegacy»
                return LogUtil::registerError($this->__('Error! Could not determine workflow actions.'));
            «ELSE»
                $this->request->getSession()->getFlashBag()->add('error', $this->__('Error! Could not determine workflow actions.'));
                $logger = $this->get('logger');
                $logger->error('{app}: User {user} tried to delete the {entity} with id {id}, but failed to determine available workflow actions.', array('app' => '«app.appName»', 'user' => UserUtil::getVar('uname'), 'entity' => '«name.formatForDisplay»', 'id' => $entity->createCompositeIdentifier()));
                throw new \RuntimeException($this->__('Error! Could not determine workflow actions.'));
            «ENDIF»
        }

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
            «IF isLegacy»
                return LogUtil::registerError($this->__('Error! It is not allowed to delete this «name.formatForDisplay».'));
            «ELSE»
                $this->request->getSession()->getFlashBag()->add('error', $this->__('Error! It is not allowed to delete this «name.formatForDisplay».'));
                $logger = $this->get('logger');
                $logger->error('{app}: User {user} tried to delete the {entity} with id {id}, but this action was not allowed.', array('app' => '«app.appName»', 'user' => UserUtil::getVar('uname'), 'entity' => '«name.formatForDisplay»', 'id' => $entity->createCompositeIdentifier()));
            «ENDIF»
        }

        $confirmation = (bool) $«IF isLegacy»this->«ENDIF»request->request->filter('confirmation', false, «IF !isLegacy»false, «ENDIF»FILTER_VALIDATE_BOOLEAN);
        if ($confirmation && $deleteAllowed) {
            $this->checkCsrfToken();

            $hasErrors = false;
            if ($entity->supportsHookSubscribers()) {
                $hookAreaPrefix = $entity->getHookAreaPrefix();
                $hookType = 'validate_delete';
                // Let any hooks perform additional validation actions
                «IF isLegacy»
                    $hook = new Zikula_ValidationHook($hookAreaPrefix . '.' . $hookType, new Zikula_Hook_ValidationProviders());
                    $validators = $this->notifyHooks($hook)->getValidators();
                «ELSE»
                    $hook = new ValidationHook(new ValidationProviders());
                    $validators = $this->dispatchHooks($hookAreaPrefix . '.' . $hookType, $hook)->getValidators();
                «ENDIF»
                $hasErrors = $validators->hasErrors();
            }

            if (!$hasErrors) {
                // execute the workflow action
                $success = $workflowHelper->executeAction($entity, $deleteActionId);
                if ($success) {
                    «IF isLegacy»
                        $this->registerStatus($this->__('Done! Item deleted.'));
                    «ELSE»
                        $this->request->getSession()->getFlashBag()->add('status', $this->__('Done! Item deleted.'));
                        $logger = $this->get('logger');
                        $logger->notice('{app}: User {user} deleted the {entity} with id {id}.', array('app' => '«app.appName»', 'user' => UserUtil::getVar('uname'), 'entity' => '«name.formatForDisplay»', 'id' => $entity->createCompositeIdentifier()));
                    «ENDIF»
                }

                if ($entity->supportsHookSubscribers()) {
                    // Let any hooks know that we have created, updated or deleted the «name.formatForDisplay»
                    $hookType = 'process_delete';
                    «IF isLegacy»
                        $hook = new Zikula_ProcessHook($hookAreaPrefix . '.' . $hookType, $entity->createCompositeIdentifier());
                        $this->notifyHooks($hook);
                    «ELSE»
                        $hook = new ProcessHook($entity->createCompositeIdentifier());
                        $this->dispatchHooks($hookAreaPrefix . '.' . $hookType, $hook);
                    «ENDIF»
                }

                // The «name.formatForDisplay» was deleted, so we clear all cached pages this item.
                $cacheArgs = array('ot' => $objectType, 'item' => $entity);
                ModUtil::apiFunc($this->name, 'cache', 'clearItemCache', $cacheArgs);

                «IF app.hasAdminController && app.hasUserController»
                if («IF isLegacy»$legacyControllerType == 'admin'«ELSE»$isAdmin«ENDIF») {
                    «redirectAfterDeletion(app.getAllAdminControllers.head)»
                } else {
                    «redirectAfterDeletion(app.getMainUserController)»
                }
                «ELSEIF app.hasAdminController»
                    «redirectAfterDeletion(app.getAllAdminControllers.head)»
                «ELSEIF app.hasUserController»
                    «redirectAfterDeletion(app.getMainUserController)»
                «ENDIF»
                «IF isLegacy»
                    return $this->redirect($redirectUrl);
                «ELSE»
                    return new RedirectResponse(System::normalizeUrl($redirectUrl));
                «ENDIF»
            }
        }

        «IF isLegacy»
            $entityClass = $this->name . '_Entity_' . ucfirst($objectType);
            $repository = $this->entityManager->getRepository($entityClass);
        «ELSE»
            $repository = $this->get('«app.appName.formatForDB».' . $objectType . '_factory')->getRepository();
            $view = Zikula_View::getInstance('«app.appName»', false);
            $view->assign('routeArea', $isAdmin ? 'admin' : '');
        «ENDIF»

        // set caching id
        $«IF isLegacy»this->«ENDIF»view->setCaching(Zikula_View::CACHE_DISABLED);

        // assign the object we loaded above
        $«IF isLegacy»this->«ENDIF»view->assign($objectType, $entity)
        «IF isLegacy»      «ENDIF»     ->assign($repository->getAdditionalTemplateParameters('controllerAction', $utilArgs));

        // fetch and return the appropriate template
        «IF isLegacy»
            $viewHelper = new «app.appName»_Util_View($this->serviceManager);
        «ELSE»
            $viewHelper = $this->get('«app.appName.formatForDB».view_helper');
        «ENDIF»

        return $viewHelper->processTemplate($«IF isLegacy»this->«ENDIF»view, $objectType, 'delete', «IF isLegacy»array()«ELSE»$request«ENDIF»);
    '''

    def private redirectAfterDeletion(Entity it, Controller controller) '''
        «IF isLegacy»
            // redirect to the «IF controller.hasActions('view')»list of «nameMultiple.formatForDisplay»«ELSE»main page«ENDIF»
            $redirectUrl = ModUtil::url($this->name, '«name.formatForCode»', '«IF controller.hasActions('view')»view«ELSE»main«ENDIF»', array('lct' => $legacyControllerType));
        «ELSE»
            // redirect to the «IF controller.hasActions('view')»list of «nameMultiple.formatForDisplay»«ELSE»index page«ENDIF»
            $redirectUrl = $this->get('router')->generate('«app.appName.formatForDB»_«name.formatForDB»_' . ($isAdmin ? 'admin' : '') . '«IF controller.hasActions('view')»view«ELSE»index«ENDIF»');
        «ENDIF»
    '''

    def private dispatch actionImplBody(CustomAction it) '''
        «IF controller instanceof AdminController
            && (name == 'config' || name == 'modifyconfig' || name == 'preferences')»
            «new FormHandler().formCreate(it, app.appName, 'modify')»
        «ELSE»
            /** TODO: custom logic */
        «ENDIF»

        «IF !isLegacy»
            $view = Zikula_View::getInstance('«app.appName»', false);

        «ENDIF»
        «IF controller instanceof AjaxController»
            return new «IF isLegacy»Zikula_Response_Ajax«ELSE»AjaxResponse«ENDIF»(array('result' => true));
        «ELSE»
            // return template
            «IF isLegacy»
                return $this->view->fetch('«controller.formattedName»/«name.formatForCode.toFirstLower».tpl');
            «ELSE»
                return $this->response($view->fetch('«controller.formattedName.toFirstUpper»/«name.formatForCode.toFirstLower».tpl'));
            «ENDIF»
        «ENDIF»
    '''

    def private dispatch actionImplBody(Entity it, CustomAction action) '''
        /** TODO: custom logic */

        «IF !isLegacy»
            $view = Zikula_View::getInstance('«app.appName»', false);
            $view->assign('routeArea', $isAdmin ? 'admin' : '');

        «ENDIF»
        // return template
        «IF isLegacy»
            return $this->view->fetch('«name.formatForCode»/«action.name.formatForCode.toFirstLower».tpl');
        «ELSE»
            return $this->response($view->fetch('«name.formatForCodeCapital»/«action.name.formatForCode.toFirstLower».tpl'));
        «ENDIF»
    '''

    def private isLegacy() {
        app.targets('1.3.x')
    }
}
