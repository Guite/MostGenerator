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

    def actionImpl(Action it) '''
        «IF it instanceof MainAction»
            // parameter specifying which type of objects we are treating
            «IF isLegacy»
                $objectType = $this->request->query->filter('ot', '«app.getLeadingEntity.name.formatForCode»', FILTER_SANITIZE_STRING);
            «ELSE»
                $objectType = $request->query->getAlnum('ot', '«app.getLeadingEntity.name.formatForCode»');
            «ENDIF»

            $permLevel = «IF controller instanceof AdminController»ACCESS_ADMIN«ELSE»«getPermissionAccessLevel»«ENDIF»;
            «permissionCheck('', '')»
        «ELSE»
            «IF isLegacy»
                $controllerHelper = new «app.appName»_Util_Controller($this->serviceManager);
            «ELSE»
                $controllerHelper = $this->get('«app.appService».controller_helper');
            «ENDIF»

            // parameter specifying which type of objects we are treating
            «IF isLegacy»
                $objectType = $this->request->query->filter('ot', '«app.getLeadingEntity.name.formatForCode»', FILTER_SANITIZE_STRING);
            «ELSE»
                $objectType = $request->query->getAlnum('ot', '«app.getLeadingEntity.name.formatForCode»');
            «ENDIF»
            $utilArgs = «IF isLegacy»array(«ELSE»[«ENDIF»'controller' => '«controller.formattedName»', 'action' => '«name.formatForCode.toFirstLower»'«IF isLegacy»)«ELSE»]«ENDIF»;
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
            $logger->warning('{app}: The {controller} controller\'s {action} action is deprecated. Please use entity-related controllers instead.', ['app' => '«app.appName»', 'controller' => '«controller.name.formatForDisplay»', 'action' => '«name.formatForDisplay»']);

            return $this->redirectToRoute('«app.appName.formatForDB»_' . strtolower($objectType) . '_' . $routeArea . '«name.formatForDB»', $redirectArgs);
        «ENDIF»
    '''

    def actionImpl(Entity it, Action action) '''
        «IF it instanceof MainAction»
            «permissionCheck('', '')»
        «ELSE»
            «IF isLegacy»
                $controllerHelper = new «app.appName»_Util_Controller($this->serviceManager);
            «ELSE»
                $controllerHelper = $this->get('«app.appService».controller_helper');
            «ENDIF»

            // parameter specifying which type of objects we are treating
            $objectType = '«name.formatForCode»';
            $utilArgs = «IF isLegacy»array(«ELSE»[«ENDIF»'controller' => '«name.formatForCode»', 'action' => '«action.name.formatForCode.toFirstLower»'«IF isLegacy»)«ELSE»]«ENDIF»;
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

                    return $this->redirectToRoute('«app.appName.formatForDB»_' . strtolower($objectType) . '_' . $routeArea . 'view');
                «ENDIF»
            «ELSEIF controller.isConfigController»
                // redirect to config action
                «IF isLegacy»
                    $redirectUrl = ModUtil::url($this->name, '«controller.formattedName»', 'config', array('lct' => '«controller.formattedName»'));

                    return $this->redirect($redirectUrl);
                «ELSE»
                    $routeArea = '«IF controller instanceof AdminController»admin«ENDIF»';

                    return $this->redirectToRoute('«app.appName.formatForDB»_«controller.formattedName.toLowerCase»_' . $routeArea . 'config');
                «ENDIF»
            «ELSE»
                «redirectLegacyAction»
«/*
                «IF isLegacy»
                    // set caching id
                    $this->view->setCacheId('main');
                «ELSE»
                    $templateParameters = [
                        'routeArea' => $isAdmin ? 'admin' : ''
                    ];
                «ENDIF»

                // return «IF isLegacy»main«ELSE»index«ENDIF» template
                «IF isLegacy»
                    return $this->view->fetch('«controller.formattedName»/main.tpl');
                «ELSE»
                    return $this->render('@«app.appName»/«controller.formattedName.toFirstUpper»/index.html.twig', $templateParameters);
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

        «IF isLegacy»
            // set caching id
            $view = Zikula_View::getInstance('«app.appName»', false);
            $this->view->setCacheId('«name.formatForCode»_main');
        «ELSE»
            $templateParameters = [
                'routeArea' => $isAdmin ? 'admin' : ''
            ];
        «ENDIF»

        // return «IF isLegacy»main«ELSE»index«ENDIF» template
        «IF isLegacy»
            return $this->view->fetch('«name.formatForCode»/main.tpl');
        «ELSE»
            return $this->render('@«app.appName»/«name.formatForCodeCapital»/index.html.twig', $templateParameters);
        «ENDIF»
    '''

    def private redirectFromIndexToView(Entity it, Controller controller) '''

        «IF isLegacy»
            $redirectUrl = ModUtil::url($this->name, '«name.formatForCode»', 'view', array('lct' => $legacyControllerType));

            return $this->redirect($redirectUrl);
        «ELSE»
            return $this->redirectToRoute('«app.appName.formatForDB»_«name.formatForDB»_' . ($isAdmin ? 'admin' : '') . 'view');
        «ENDIF»
    '''

    def private actionImplBodyAjaxView(ViewAction it) '''
        «IF isLegacy»
            $entityClass = $this->name . '_Entity_' . ucfirst($objectType);
            $repository = $this->entityManager->getRepository($entityClass);
            $repository->setControllerArguments(array());
        «ELSE»
            $repository = $this->get('«app.appService».' . $objectType . '_factory')->getRepository();
            $repository->setRequest($request);
        «ENDIF»

        // parameter for used sorting field
        «IF isLegacy»
            $sort = $this->request->query->filter('sort', '', FILTER_SANITIZE_STRING);
        «ELSE»
            $sort = $request->query->getAlnum('sort', '');
        «ENDIF»
        «new ControllerHelperFunctions().defaultSorting(it, app)»

        // parameter for used sort order
        «IF isLegacy»
            $sortdir = $this->request->query->filter('sortdir', '', FILTER_SANITIZE_STRING);
        «ELSE»
            $sortdir = $request->query->getAlpha('sortdir', '');
        «ENDIF»
        $sortdir = strtolower($sortdir);
        if ($sortdir != 'asc' && $sortdir != 'desc') {
            $sortdir = 'asc';
        }

        // convenience vars to make code clearer
        $currentUrlArgs = «IF isLegacy»array(«ELSE»[«ENDIF»'ot' => $objectType«IF isLegacy»)«ELSE»]«ENDIF»;

        «IF isLegacy»
            $where = $this->request->query->get('where', '');
        «ELSE»
            $where = $request->query->get('where', '');
        «ENDIF»
        $where = str_replace('"', '', $where);

        $selectionArgs = «IF isLegacy»array(«ELSE»[«ENDIF»
            'ot' => $objectType,
            'where' => $where,
            'orderBy' => $sort . ' ' . $sortdir
        «IF isLegacy»)«ELSE»]«ENDIF»;

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
                $currentPage = $request->query->getInt('pos', 1);
            «ENDIF»

            // the number of items displayed on a page for pagination
            «IF isLegacy»
                $resultsPerPage = (int) $this->request->query->filter('num', 0, FILTER_VALIDATE_INT);
            «ELSE»
                $resultsPerPage = $request->query->getInt('num', 0);
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

            $repository = $this->get('«app.appService».' . $objectType . '_factory')->getRepository();
            $repository->setRequest($request);
        «ENDIF»
        «IF isLegacy»
            $viewHelper = new «app.appName»_Util_View($this->serviceManager);
        «ELSE»
            $viewHelper = $this->get('«app.appService».view_helper');
            $templateParameters = [
                'routeArea' => $isAdmin ? 'admin' : ''
            ];
        «ENDIF»
        «IF tree != EntityTreeType.NONE»

            «IF isLegacy»
                $tpl = $this->request->query->filter('tpl', '', FILTER_SANITIZE_STRING);
            «ELSE»
                $tpl = $request->query->getAlpha('tpl', '');
            «ENDIF»
            if ($tpl == 'tree') {
                $trees = ModUtil::apiFunc($this->name, 'selection', 'getAllTrees', «IF isLegacy»array(«ELSE»[«ENDIF»'ot' => $objectType«IF isLegacy»)«ELSE»]«ENDIF»);
                «IF isLegacy»
                    $this->view->assign('trees', $trees)
                               ->assign($repository->getAdditionalTemplateParameters('controllerAction', $utilArgs));
                «ELSE»
                    $templateParameters['trees'] = $trees;
                    $templateParameters = array_merge($templateParameters, $repository->getAdditionalTemplateParameters('controllerAction', $utilArgs));
                «ENDIF»
                // fetch and return the appropriate template
                «IF isLegacy»
                    return $viewHelper->processTemplate($this->view, $objectType, 'view', array());
                «ELSE»
                    return $viewHelper->processTemplate($this->get('twig'), $objectType, 'view', $request, $templateParameters);
                «ENDIF»
            }
        «ENDIF»

        // convenience vars to make code clearer
        $currentUrlArgs = «IF isLegacy»array()«ELSE»[]«ENDIF»;
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
        «new ControllerHelperFunctions().defaultSorting(it, app)»

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

        $selectionArgs = «IF isLegacy»array(«ELSE»[«ENDIF»
            'ot' => $objectType,
            'where' => $where,
            'orderBy' => $sort . ' ' . $sortdir
        «IF isLegacy»)«ELSE»]«ENDIF»;
        «IF isLegacy»

            // prepare access level for cache id
            $accessLevel = ACCESS_READ;
            $component = '«app.appName»:' . ucfirst($objectType) . ':';
            $instance = '::';
            if (SecurityUtil::checkPermission($component, $instance, ACCESS_COMMENT)) {
                $accessLevel = ACCESS_COMMENT;
            }
            if (SecurityUtil::checkPermission($component, $instance, ACCESS_EDIT)) {
                $accessLevel = ACCESS_EDIT;
            }

            $templateFile = $viewHelper->getViewTemplate($this->view, $objectType, 'view', array());
            $cacheId = $objectType . '_view|_sort_' . $sort . '_' . $sortdir;
        «ENDIF»
        if ($showAllEntries == 1) {
            «IF isLegacy»
                // set cache id
                $this->view->setCacheId($cacheId . '_all_1_own_' . $showOwnEntries . '_' . $accessLevel);

                // if page is cached return cached content
                if ($this->view->is_cached($templateFile)) {
                    return $viewHelper->processTemplate($this->view, $objectType, 'view', array(), $templateFile);
                }

            «ENDIF»
            // retrieve item list without pagination
            $entities = ModUtil::apiFunc($this->name, 'selection', 'getEntities', $selectionArgs);
        } else {
            // the current offset which is used to calculate the pagination
            «IF isLegacy»
                $currentPage = (int) $this->request->query->filter('pos', 1, FILTER_VALIDATE_INT);
            «ELSE»
                $currentPage = $pos;
            «ENDIF»

            «IF isLegacy»
                // set cache id
                $this->view->setCacheId($cacheId . '_amount_' . $resultsPerPage . '_page_' . $currentPage . '_own_' . $showOwnEntries . '_' . $accessLevel);

                // if page is cached return cached content
                if ($this->view->is_cached($templateFile)) {
                    return $viewHelper->processTemplate($this->view, $objectType, 'view', array(), $templateFile);
                }

            «ENDIF»
            // retrieve item list with pagination
            $selectionArgs['currentPage'] = $currentPage;
            $selectionArgs['resultsPerPage'] = $resultsPerPage;
            list($entities, $objectCount) = ModUtil::apiFunc($this->name, 'selection', 'getEntitiesPaginated', $selectionArgs);

            «IF isLegacy»
                $this->view->assign('currentPage', $currentPage)
                           ->assign('pager', array('numitems'     => $objectCount,
                                                   'itemsperpage' => $resultsPerPage));
            «ELSE»
                $templateParameters['currentPage'] = $currentPage;
                $templateParameters['pager'] = ['numitems' => $objectCount, 'itemsperpage' => $resultsPerPage];
            «ENDIF»
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
                «addSortColumn('createdUserId')»
                «addSortColumn('createdDate')»
                «addSortColumn('updatedUserId')»
                «addSortColumn('updatedDate')»
            «ENDIF»
        ]);
        $sortableColumns->setOrderBy($sortableColumns->getColumn($sort), strtoupper($sortdir));

        $additionalUrlParameters = [
            'all' => $showAllEntries,
            'own' => $showOwnEntries,
            'pageSize' => $resultsPerPage
        ];
        $additionalUrlParameters = array_merge($additionalUrlParameters, $additionalParameters);
        $sortableColumns->setAdditionalUrlParameters($additionalUrlParameters);
    '''

    def private addSortColumn(Entity it, String columnName) '''
        new Column('«columnName.formatForCode»'),
    '''

    def private prepareViewUrlArgs(NamedObject it, Boolean hasView) '''
        «IF isLegacy»
            $showOwnEntries = (int) $this->request->query->filter('own', $this->getVar('showOnlyOwnEntries', 0), FILTER_VALIDATE_INT);
            $showAllEntries = (int) $this->request->query->filter('all', 0, FILTER_VALIDATE_INT);
        «ELSE»
            $showOwnEntries = $request->query->getInt('own', $this->getVar('showOnlyOwnEntries', 0));
            $showAllEntries = $request->query->getInt('all', 0);
        «ENDIF»

        «IF app.generateCsvTemplates»
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

        «ENDIF»
        «IF hasView»
            «IF isLegacy»
                $this->view->assign('showOwnEntries', $showOwnEntries)
                           ->assign('showAllEntries', $showAllEntries);
            «ELSE»
                $templateParameters['showOwnEntries'] = $showOwnEntries;
                $templateParameters['showAllEntries'] = $showAllEntries;
            «ENDIF»
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

        «IF isLegacy»
            // assign the object data, sorting information and details for creating the pager
            $this->view->assign('items', $entities)
                       ->assign('sort', $sort)
                       ->assign('sdir', $sortdir)
                       ->assign('pageSize', $resultsPerPage)
                       ->assign('currentUrlObject', $currentUrlObject)
                       ->assign($additionalParameters);
        «ELSE»
            $templateParameters['items'] = $entities;
            $templateParameters['sort'] = $sort;
            $templateParameters['sdir'] = $sortdir;
            $templateParameters['pagesize'] = $resultsPerPage;
            $templateParameters['currentUrlObject'] = $currentUrlObject;
            $templateParameters = array_merge($templateParameters, $additionalParameters);

            $formOptions = [
                'all' => $templateParameters['showAllEntries'],
                'own' => $templateParameters['showOwnEntries']
            ];
            $form = $this->createForm('«app.appNamespace»\Form\Type\QuickNavigation\\' . ucfirst($objectType) . 'QuickNavType', $templateParameters, $formOptions);

            $templateParameters['sort'] = $sortableColumns->generateSortableColumns();
            $templateParameters['quickNavForm'] = $form->createView();

            «/* shouldn't be necessary
            if ($form->handleRequest($request)->isValid() && $form->get('update')->isClicked()) {
                $templateParameters = array_merge($templateParameters, $form->getData());
            }
 
            */»
        «ENDIF»

        «IF isLegacy»
            $modelHelper = new «app.appName»_Util_Model($this->serviceManager);
            $this->view->assign('canBeCreated', $modelHelper->canBeCreated($objectType));
        «ELSE»
            $modelHelper = $this->get('«app.appService».model_helper');
            $templateParameters['canBeCreated'] = $modelHelper->canBeCreated($objectType);
        «ENDIF»

        // fetch and return the appropriate template
        «IF isLegacy»
            return $viewHelper->processTemplate($this->view, $objectType, 'view', array(), $templateFile);
        «ELSE»
            return $viewHelper->processTemplate($this->get('twig'), $objectType, 'view', $request, $templateParameters);
        «ENDIF»
    '''

    def private prepareViewItemsAjax(Controller it) '''
        $items = «IF isLegacy»array()«ELSE»[]«ENDIF»;
        «IF app.hasListFields»
            «IF isLegacy»
                $listHelper = new «app.appName»_Util_ListEntries($this->serviceManager);
            «ELSE»
                $listHelper = $this->get('«app.appService».listentries_helper');
            «ENDIF»

            $listObjectTypes = «IF isLegacy»array(«ELSE»[«ENDIF»«FOR entity : app.getListEntities SEPARATOR ', '»'«entity.name.formatForCode»'«ENDFOR»«IF isLegacy»)«ELSE»]«ENDIF»;
            $hasListFields = in_array($objectType, $listObjectTypes);

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

        $result = «IF isLegacy»array(«ELSE»[«ENDIF»
            'objectCount' => $objectCount,
            'items' => $items
        «IF isLegacy»)«ELSE»]«ENDIF»;

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
            $repository = $this->get('«app.appService».' . $objectType . '_factory')->getRepository();
            $repository->setRequest($request);
        «ENDIF»

        $idFields = ModUtil::apiFunc($this->name, 'selection', 'getIdFields', «IF isLegacy»array(«ELSE»[«ENDIF»'ot' => $objectType«IF isLegacy»)«ELSE»]«ENDIF»);

        // retrieve identifier of the object we wish to view
        $idValues = $controllerHelper->retrieveIdentifier($«IF isLegacy»this->«ENDIF»request, «IF isLegacy»array()«ELSE»[]«ENDIF», $objectType, $idFields);
        $hasIdentifier = $controllerHelper->isValidIdentifier($idValues);

        «IF isLegacy»
            $this->throwNotFoundUnless($hasIdentifier, $this->__('Error! Invalid identifier received.'));
        «ELSE»
            if (!$hasIdentifier) {
                throw new NotFoundHttpException($this->__('Error! Invalid identifier received.'));
            }
        «ENDIF»

        $entity = ModUtil::apiFunc($this->name, 'selection', 'getEntity', «IF isLegacy»array(«ELSE»[«ENDIF»'ot' => $objectType, 'id' => $idValues«IF isLegacy»)«ELSE»]«ENDIF»);
        «IF isLegacy»
            $this->throwNotFoundUnless(null !== $entity, $this->__('No such item.'));
        «ELSE»
            if (null === $entity) {
                throw new NotFoundHttpException($this->__('No such item.'));
            }
        «ENDIF»
        unset($idValues);

        $entity->initWorkflow();

        $instanceId = $entity->createCompositeIdentifier();

        «permissionCheck("' . ucfirst($objectType) . '", "$instanceId . ")»

        $result = «IF isLegacy»array(«ELSE»[«ENDIF»
            'result' => true,
            $objectType => $entity->toArray()
        «IF isLegacy»)«ELSE»]«ENDIF»;

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

            $repository = $this->get('«app.appService».' . $objectType . '_factory')->getRepository();
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
            $viewHelper = $this->get('«app.appService».view_helper');
            $templateParameters = [
                'routeArea' => $isAdmin ? 'admin' : ''
            ];
        «ENDIF»
        «IF isLegacy»
            $templateFile = $viewHelper->getViewTemplate($this->view, $objectType, 'display', array());

            // set cache id
            $component = $this->name . ':' . ucfirst($objectType) . ':';
            $instance = $instanceId . '::';
            $accessLevel = ACCESS_READ;
            if (SecurityUtil::checkPermission($component, $instance, ACCESS_COMMENT)) {
                $accessLevel = ACCESS_COMMENT;
            }
            if (SecurityUtil::checkPermission($component, $instance, ACCESS_EDIT)) {
                $accessLevel = ACCESS_EDIT;
            }
            $this->view->setCacheId($objectType . '_display|' . $instanceId . '|a' . $accessLevel);

            // assign output data to view object.
            $this->view->assign($objectType, $entity)
                       ->assign('currentUrlObject', $currentUrlObject)
                       ->assign($repository->getAdditionalTemplateParameters('controllerAction', $utilArgs));
        «ELSE»
            $templateParameters[$objectType] = $entity;
            $templateParameters['currentUrlObject'] = $currentUrlObject;
            $templateParameters = array_merge($templateParameters, $repository->getAdditionalTemplateParameters('controllerAction', $utilArgs));
        «ENDIF»

        // fetch and return the appropriate template
        «IF isLegacy»
            return $viewHelper->processTemplate($this->view, $objectType, 'display', array(), $templateFile);
        «ELSE»
            return $viewHelper->processTemplate($this->get('twig'), $objectType, 'display', $request, $templateParameters);
        «ENDIF»
    '''

    def private dispatch actionImplBody(EditAction it) {
        switch controller {
            AjaxController: '''
        $this->checkAjaxToken();
        $idFields = ModUtil::apiFunc($this->name, 'selection', 'getIdFields', «IF isLegacy»array(«ELSE»[«ENDIF»'ot' => $objectType«IF isLegacy»)«ELSE»]«ENDIF»);

        «IF isLegacy»
            $data = $this->request->query->get('data', null);
        «ELSE»
            $data = $request->query->get('data', null);
        «ENDIF»
        $data = json_decode($data, true);

        $idValues = «IF isLegacy»array()«ELSE»[]«ENDIF»;
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

        $entity = ModUtil::apiFunc($this->name, 'selection', 'getEntity', «IF isLegacy»array(«ELSE»[«ENDIF»'ot' => $objectType, 'id' => $idValues«IF isLegacy»)«ELSE»]«ENDIF»);
        «IF isLegacy»
            $this->throwNotFoundUnless(null !== $entity, $this->__('No such item.'));
        «ELSE»
            if (null === $entity) {
                throw new NotFoundHttpException($this->__('No such item.'));
            }
        «ENDIF»
        unset($idValues);

        $instanceId = $entity->createCompositeIdentifier();

        «permissionCheck("' . ucfirst($objectType) . '", "$instanceId . ")»

        $result = «IF isLegacy»array(«ELSE»[«ENDIF»
            'result' => false,
            $objectType => $entity->toArray()
        «IF isLegacy»)«ELSE»]«ENDIF»;

        $hasErrors = false;
        «IF app.hasHookSubscribers»
            if ($entity->supportsHookSubscribers()) {
                «IF isLegacy»
                    $hookHelper = new «app.appName»_Util_Hook($this->serviceManager);
                «ELSE»
                    $hookHelper = $this->get('«app.appService».hook_helper');
                «ENDIF»
                // Let any hooks perform additional validation actions
                $hookType = 'validate_edit';
                $validationHooksPassed = $hookHelper->callValidationHooks($entity, $hookType);
                $hasErrors = !$validationHooksPassed;
            }
        «ENDIF»

        if (!$hasErrors) {
            foreach ($idFields as $idField) {
                unset($data[$idField]);
            }
            foreach ($data as $key => $value) {
                $entity[$key] = $value;
            }
            $this->entityManager->persist($entity);
            $this->entityManager->flush();
            «IF app.hasHookSubscribers»

                if ($entity->supportsHookSubscribers()) {
                    $hookType = 'process_edit';
                    $url = null;
                    if ($action != 'delete') {
                        $urlArgs = $entity->createUrlArgs();
                        «IF isLegacy»
                            $url = new Zikula_ModUrl($this->name, FormUtil::getPassedValue('type', 'user', 'GETPOST'), 'display', ZLanguage::getLanguageCode(), $urlArgs);
                        «ELSE»
                            $url = new RouteUrl('«app.appName.formatForDB»_' . $objectType . '_' . ($isAdmin ? 'admin' : '') . 'display', $urlArgs);
                        «ENDIF»
                    }
                    $hookHelper->callProcessHooks($entity, $hookType, $url);
                }
            «ENDIF»
            «IF !isLegacy»

                $logger = $this->get('logger');
                $logArgs = ['app' => '«app.appName»', 'user' => $this->get('zikula_users_module.current_user')->get('uname'), 'entity' => $objectType, 'id' => $instanceId];
                $logger->notice('{app}: User {user} updated the {entity} with id {id} using ajax.', $logArgs);
            «ENDIF»
        }

        $result = «IF isLegacy»array(«ELSE»[«ENDIF»
            'result' => true,
            $objectType => $entity->toArray()
        «IF isLegacy»)«ELSE»]«ENDIF»;

        return new «IF isLegacy»Zikula_Response_Ajax«ELSE»AjaxResponse«ENDIF»($result);
                    '''
            default: '''
        «redirectLegacyAction»
                    '''
        }
    }

    def private dispatch actionImplBody(Entity it, EditAction action) '''
        «IF isLegacy»
            // create new Form reference
            $view = FormUtil::newForm($this->name, $this);

            // build form handler class name
            $handlerClass = $this->name . '_Form_Handler_«name.formatForCodeCapital»_Edit';

            // determine the output template
            $viewHelper = new «app.appName»_Util_View($this->serviceManager);
            $template = $viewHelper->getViewTemplate($this->view, $objectType, 'edit', array());

            // execute form using supplied template and page event handler
            return $view->execute($template, new $handlerClass());
        «ELSE»
            // temporary workarounds
            // let repository know if we are in admin or user area
            $request->query->set('lct', $isAdmin ? 'admin' : 'user');
            // let entities know if we are in admin or user area
            System::queryStringSetVar('lct', $isAdmin ? 'admin' : 'user');

            $repository = $this->get('«app.appService».' . $objectType . '_factory')->getRepository();

            $templateParameters = [
                'routeArea' => $isAdmin ? 'admin' : ''
            ];
            $templateParameters = array_merge($templateParameters, $repository->getAdditionalTemplateParameters('controllerAction', $utilArgs));

            // delegate form processing to the form handler
            $formHandler = $this->get('«app.appService».form.handler.«name.formatForDB»');
            $formHandler->processForm($templateParameters);

            $viewHelper = $this->get('«app.appService».view_helper');
            $templateParameters = $formHandler->getTemplateParameters();

            // fetch and return the appropriate template
            return $viewHelper->processTemplate($this->get('twig'), $objectType, 'edit', $request, $templateParameters);
        «ENDIF»
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

            $flashBag = $request->getSession()->getFlashBag();
            $logger = $this->get('logger');
            $logArgs = ['app' => '«app.appName»', 'user' => $this->get('zikula_users_module.current_user')->get('uname'), 'entity' => '«name.formatForDisplay»', 'id' => $entity->createCompositeIdentifier()];
        «ENDIF»

        $entity->initWorkflow();

        // determine available workflow actions
        «IF isLegacy»
            $workflowHelper = new «app.appName»_Util_Workflow($this->serviceManager);
        «ELSE»
            $workflowHelper = $this->get('«app.appService».workflow_helper');
        «ENDIF»
        $actions = $workflowHelper->getActionsForObject($entity);
        if ($actions === false || !is_array($actions)) {
            «IF isLegacy»
                return LogUtil::registerError($this->__('Error! Could not determine workflow actions.'));
            «ELSE»
                $flashBag->add(\Zikula_Session::MESSAGE_ERROR, $this->__('Error! Could not determine workflow actions.'));
                $logger->error('{app}: User {user} tried to delete the {entity} with id {id}, but failed to determine available workflow actions.', $logArgs);
                throw new \RuntimeException($this->__('Error! Could not determine workflow actions.'));
            «ENDIF»
        }

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
                $flashBag->add(\Zikula_Session::MESSAGE_ERROR, $this->__('Error! It is not allowed to delete this «name.formatForDisplay».'));
                $logger->error('{app}: User {user} tried to delete the {entity} with id {id}, but this action was not allowed.', $logArgs);

                return $this->redirectToRoute($redirectRoute);
            «ENDIF»
        }

        «IF isLegacy»
            $confirmation = (bool) $this->request->request->filter('confirmation', false, FILTER_VALIDATE_BOOLEAN);
            if ($confirmation) {
                «deletionProcess(action)»
            }
        «ELSE»
            $form = $this->createForm('«app.appNamespace»\Form\DeleteEntityType');

            if ($form->handleRequest($request)->isValid()) {
                if ($form->get('delete')->isClicked()) {
                    «deletionProcess(action)»
                } elseif ($form->get('cancel')->isClicked()) {
                    $this->addFlash(\Zikula_Session::MESSAGE_STATUS, $this->__('Operation cancelled.'));

                    return $this->redirectToRoute($redirectRoute);
                }
            }
        «ENDIF»

        «IF isLegacy»
            $entityClass = $this->name . '_Entity_' . ucfirst($objectType);
            $repository = $this->entityManager->getRepository($entityClass);
        «ELSE»
            $repository = $this->get('«app.appService».' . $objectType . '_factory')->getRepository();
        «ENDIF»

        «IF isLegacy»
            $viewHelper = new «app.appName»_Util_View($this->serviceManager);
        «ELSE»
            $viewHelper = $this->get('«app.appService».view_helper');
            $templateParameters = [
                'routeArea' => $isAdmin ? 'admin' : '',
                'deleteForm' => $form->createView()
            ];
        «ENDIF»

        «IF isLegacy»
            // set caching id
            $this->view->setCaching(Zikula_View::CACHE_DISABLED);

            // assign the object we loaded above
            $this->view->assign($objectType, $entity)
                       ->assign($repository->getAdditionalTemplateParameters('controllerAction', $utilArgs));
        «ELSE»
            $templateParameters[$objectType] = $entity;
            $templateParameters = array_merge($templateParameters, $repository->getAdditionalTemplateParameters('controllerAction', $utilArgs));
        «ENDIF»

        // fetch and return the appropriate template
        «IF isLegacy»
            return $viewHelper->processTemplate($this->view, $objectType, 'delete', array());
        «ELSE»
            return $viewHelper->processTemplate($this->get('twig'), $objectType, 'delete', $request, $templateParameters);
        «ENDIF»
    '''

    def private deletionProcess(Entity it, DeleteAction action) '''
        «IF isLegacy»
            $this->checkCsrfToken();

        «ENDIF»
        «IF !skipHookSubscribers»
            «IF isLegacy»
                $hookHelper = new «app.appName»_Util_Hook($this->serviceManager);
            «ELSE»
                $hookHelper = $this->get('«app.appService».hook_helper');
            «ENDIF»
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
            «IF isLegacy»
                $this->registerStatus($this->__('Done! Item deleted.'));
            «ELSE»
                $flashBag->add(\Zikula_Session::MESSAGE_STATUS, $this->__('Done! Item deleted.'));
                $logger->notice('{app}: User {user} deleted the {entity} with id {id}.', $logArgs);
            «ENDIF»
        }
    '''

    def private deletePostProcessing(Entity it, DeleteAction action) '''
        «IF !skipHookSubscribers»

            // Let any hooks know that we have deleted the «name.formatForDisplay»
            $hookType = 'process_delete';
            $hookHelper->callProcessHooks($entity, $hookType, null);
        «ENDIF»

        «IF isLegacy»
            // The «name.formatForDisplay» was deleted, so we clear all cached pages this item.
            $cacheArgs = array('ot' => $objectType, 'item' => $entity);
            ModUtil::apiFunc($this->name, 'cache', 'clearItemCache', $cacheArgs);

            return $this->redirect($redirectUrl);
        «ELSE»
            return $this->redirectToRoute($redirectRoute);
        «ENDIF»
    '''

    def private redirectAfterDeletion(Entity it, Controller controller) '''
        «IF isLegacy»
            // redirect to the «IF controller.hasActions('view')»list of «nameMultiple.formatForDisplay»«ELSE»main page«ENDIF»
            $redirectUrl = ModUtil::url($this->name, '«name.formatForCode»', '«IF controller.hasActions('view')»view«ELSE»main«ENDIF»', array('lct' => $legacyControllerType));
        «ELSE»
            // redirect to the «IF controller.hasActions('view')»list of «nameMultiple.formatForDisplay»«ELSE»index page«ENDIF»
            $redirectRoute = '«app.appName.formatForDB»_«name.formatForDB»_' . ($isAdmin ? 'admin' : '') . '«IF controller.hasActions('view')»view«ELSE»index«ENDIF»';
        «ENDIF»
    '''

    def private dispatch actionImplBody(CustomAction it) '''
        «IF isLegacy && controller instanceof AdminController
            && (name == 'config' || name == 'modifyconfig' || name == 'preferences')»
            «val actionName = 'modify'»
            // Create new Form reference
            $view = FormUtil::newForm('«app.appName.formatForCode»', $this);

            $handlerClass = '«app.appName»_Form_Handler_«controller.name.formatForCodeCapital»_«actionName.formatForCodeCapital»';

            // Execute form using supplied template and page event handler
            return $view->execute('«controller.formattedName.toFirstUpper»/«actionName.formatForCode.toFirstLower».«IF controller.application.targets('1.3.x')»tpl«ELSE»html.twig«ENDIF»', new $handlerClass());
        «ELSE»
            /** TODO: custom logic */
        «ENDIF»

        «IF controller instanceof AjaxController»
            return new «IF isLegacy»Zikula_Response_Ajax«ELSE»AjaxResponse«ENDIF»(«IF isLegacy»array(«ELSE»[«ENDIF»'result' => true«IF isLegacy»)«ELSE»]«ENDIF»);
        «ELSE»
            // return template
            «IF isLegacy»
                return $this->view->fetch('«controller.formattedName»/«name.formatForCode.toFirstLower».tpl');
            «ELSE»
                return $this->render('@«app.appName»/«controller.formattedName.toFirstUpper»/«name.formatForCode.toFirstLower».html.twig');
            «ENDIF»
        «ENDIF»
    '''

    def private dispatch actionImplBody(Entity it, CustomAction action) '''
        /** TODO: custom logic */
        «IF !isLegacy»

            $templateParameters = [
                'routeArea' => $isAdmin ? 'admin' : ''
            ];
        «ENDIF»

        // return template
        «IF isLegacy»
            return $this->view->fetch('«name.formatForCode»/«action.name.formatForCode.toFirstLower».tpl');
        «ELSE»
            return $this->render('@«app.appName»/«name.formatForCodeCapital»/«action.name.formatForCode.toFirstLower».html.twig', $templateParameters);
        «ENDIF»
    '''

    def private isLegacy() {
        app.targets('1.3.x')
    }
}
