package org.zikula.modulestudio.generator.cartridges.zclassic.controller

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

    def generate(Action it) '''
        «actionDoc(null)»
        public function «methodName»«IF app.targets('1.3.5')»()«ELSE»Action(«methodArgs»)«ENDIF»
        {
            «actionImpl»
        }
        «/* this line is on purpose */»
    '''

    def generate(Entity it, Action action) '''
        «action.actionDoc(it)»
        public function «action.methodName»«IF app.targets('1.3.5')»()«ELSE»Action(«methodArgs(it, action)»)«ENDIF»
        {
            $legacyControllerType = $this->request->query->filter('lct', 'user', FILTER_SANITIZE_STRING);
            System::queryStringSetVar('type', $legacyControllerType);
            $this->request->query->set('type', $legacyControllerType);

            «IF softDeleteable && !app.targets('1.3.5')»
                if ($legacyControllerType == 'admin') {
                    //$this->entityManager->getFilters()->disable('softdeleteable');
                } else {
                    $this->entityManager->getFilters()->enable('softdeleteable');
                }

            «ENDIF»
            «actionImpl(it, action)»
        }
        «/* this line is on purpose */»
    '''

    def private actionDoc(Action it, Entity entity) '''
        /**
         * «actionDocMethodDescription»
        «actionDocMethodDocumentation»
        «IF !app.targets('1.3.5') && entity !== null»
            «actionRoute(entity)»
        «ENDIF»
         *
        «actionDocMethodParams(entity !== null)»
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
            ViewAction: 'This method provides a item list overview.'
            DisplayAction: 'This method provides a item detail view.'
            EditAction: 'This method provides a handling of edit requests.'
            DeleteAction: 'This method provides a handling of simple delete requests.'
            CustomAction: 'This is a custom method.'
            default: ''
        }
    }

    def private actionDocMethodDocumentation(Action it) {
        if (documentation !== null && documentation != '') {
            ' * ' + documentation.replace('*/', '*')
        } else {
            ''
        }
    }

    def private actionDocMethodParams(Action it, Boolean skipOtParam) {
        if (!controller.container.application.targets('1.3.5') && it instanceof MainAction) {
            if (skipOtParam) '' else ' * @param string  $ot           Treated object type.\n'
        } else if (!(it instanceof MainAction || it instanceof CustomAction)) {
            (if (skipOtParam) '' else ' * @param string  $ot           Treated object type.\n')
            + '''«actionDocAdditionalParams»'''
            + ' * @param string  $tpl          Name of alternative template (to be used instead of the default template).\n'
            + (if (controller.container.application.targets('1.3.5')) ' * @param boolean $raw          Optional way to display a template instead of fetching it (required for standalone output).\n' else '')
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

    def private dispatch methodName(Action it) '''«name.formatForCode.toFirstLower»'''

    def private dispatch methodName(MainAction it) '''«IF app.targets('1.3.5')»main«ELSE»index«ENDIF»'''

    def private methodArgs(Action action) '''Request $request''' 

    def private dispatch methodArgs(Entity it, Action action) '''Request $request''' 

    def private dispatch actionRoute(Action it, Entity entity) '''
    '''

    def private dispatch actionRoute(MainAction it, Entity entity) '''
         «' '»*
         «' '»* @Route("/%«app.appName.formatForDB».routing.«entity.name.formatForCode».plural%",
         «' '»*        name = "«app.appName.formatForDB»_«entity.name.formatForCode»_index",
         «' '»*        methods = {"GET"}
         «' '»* )
    '''

    def private dispatch actionRoute(ViewAction it, Entity entity) '''
         «' '»*
         «' '»* @Route("/%«app.appName.formatForDB».routing.«name.formatForCode».plural%/{sort}/{sortdir}/{pos}/{num}.{_format}",
         «' '»*        name = "«app.appName.formatForDB»_«entity.name.formatForCode»_view",
         «' '»*        requirements = {"sortdir" = "asc|desc", "pos" => "\d+", "num" => "\d+", "_format" = "%«app.appName.formatForDB».routing.formats.view%"},
         «' '»*        defaults = {"sort" = "", "sortdir" = "asc", "pos" = 1, "num" = 0, "_format" = "html"},
         «' '»*        methods = {"GET"}
         «' '»* )
    '''

    def private actionRouteForSingleEntity(Entity it, Action action) '''
         «' '»*
         «' '»* @Route("/%«app.appName.formatForDB».routing.«name.formatForCode».singular%/«IF !(action instanceof DisplayAction)»«action.name.formatForCode»/«ENDIF»«actionRouteParamsForSingleEntity(action)».{_format}",
         «' '»*        name = "«app.appName.formatForDB»_«name.formatForCode»_«action.name.formatForCode»",
         «' '»*        requirements = {«actionRouteRequirementsForSingleEntity(action)», "_format" = "«IF action instanceof DisplayAction»%«app.appName.formatForDB».routing.formats.display%«ELSE»html«ENDIF»"},
         «' '»*        defaults = {"_format" = "html"}
         «' '»*        methods = {"GET"«IF action instanceof EditAction || action instanceof DeleteAction», "POST"«ENDIF»}
         «' '»* )
    '''

    def private actionRouteParamsForSingleEntity(Entity it, Action action) {
        var output = ''
        if (hasSluggableFields && !(action instanceof EditAction)) {
            output = '{slug}'
            if (slugUnique) {
                return output
            }
            output = output + '.'
        }
        if (hasCompositeKeys) {
            var i = 0
            for (pkField : getPrimaryKeyFields) {
                if (i > 0) {
                    output = output + '_'
                }
                output = output + '{' + pkField.name.formatForCode + '}'
                i = i + 1
            }
        } else {
            output = output + '{' + getFirstPrimaryKey.name.formatForCode + '}'
        }
        output
    }

    def private actionRouteRequirementsForSingleEntity(Entity it, Action action) {
        var output = ''
        if (hasSluggableFields && !(action instanceof EditAction)) {
            output = '''"slug" = "[^/.]+"'''
            if (slugUnique) {
                return output
            }
        }
        if (hasCompositeKeys) {
            for (pkField : getPrimaryKeyFields) {
                if (output != '') {
                    output = output + ', '
                }
                output = output + '''"«pkField.name.formatForCode»" = "\d+"'''
            }
        } else {
            if (output != '') {
                output = output + ', '
            }
            output = '''"«getFirstPrimaryKey.name.formatForCode»" = "\d+"'''
        }
        output
    }

    def private methodArgsForSingleEntity(Entity it) {
        var output = ''
        if (hasSluggableFields) {
            output = '$slug'
            if (slugUnique) {
                return output
            }
        }
        if (hasCompositeKeys) {
            for (pkField : getPrimaryKeyFields) {
                if (output != '') {
                    output = ', ' + output
                }
                output = output + '$' + pkField.name.formatForCode
            }
        } else {
            if (output != '') {
                output = ', ' + output
            }
            output = output + '$' + getFirstPrimaryKey.name.formatForCode
        }
        output
    }

    def private dispatch methodArgs(Entity it, DisplayAction action) '''«methodArgsForSingleEntity»»''' 

    def private dispatch actionRoute(DisplayAction it, Entity entity) '''
        «actionRouteForSingleEntity(entity, it)»
    '''

    def private dispatch methodArgs(Entity it, EditAction action) '''Request $request«/* TODO migrate to Symfony forms #416 */»''' 

    def private dispatch actionRoute(EditAction it, Entity entity) '''
        «actionRouteForSingleEntity(entity, it)»
    '''

    def private dispatch methodArgs(Entity it, DeleteAction action) '''«methodArgsForSingleEntity»»''' 

    def private dispatch actionRoute(DeleteAction it, Entity entity) '''
        «actionRouteForSingleEntity(entity, it)»
    '''

    def private dispatch actionRoute(CustomAction it, Entity entity) '''
         «' '»*
         «' '»* @Route("/%«app.appName.formatForDB».routing.«entity.name.formatForCode».plural%/«name.formatForCode»",
         «' '»*        name = "«app.appName.formatForDB»_«entity.name.formatForCode»_«name.formatForCode»",
         «' '»*        methods = {"GET", "POST"}
         «' '»* )
    '''

    def private actionImpl(Action it) '''
        «IF it instanceof MainAction»
            // parameter specifying which type of objects we are treating
            $objectType = $«IF app.targets('1.3.5')»this->«ENDIF»request->query->filter('ot', '«app.getLeadingEntity.name.formatForCode»', «IF !app.targets('1.3.5')»false, «ENDIF»FILTER_SANITIZE_STRING);

            $permLevel = «IF controller instanceof AdminController»ACCESS_ADMIN«ELSE»«getPermissionAccessLevel»«ENDIF»;
            «permissionCheck('', '')»
        «ELSE»
            $controllerHelper = new «IF app.targets('1.3.5')»«app.appName»_Util_Controller«ELSE»ControllerUtil«ENDIF»($this->serviceManager«IF !app.targets('1.3.5')», ModUtil::getModule($this->name)«ENDIF»);

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

        // redirect to entity controller
        «IF app.targets('1.3.5')»
            $redirectUrl = ModUtil::url($this->name, $objectType, '«name.formatForCode»', $redirectArgs);

            return $this->redirect($redirectUrl);
        «ELSE»
            $redirectUrl = $this->serviceManager->get('router')->generate('«app.appName.formatForDB»_' . $objectType . '_«name.formatForCode»', $redirectArgs);

            return new RedirectResponse(System::normalizeUrl($redirectUrl));
        «ENDIF»
    '''

    def private actionImpl(Entity it, Action action) '''
        «IF it instanceof MainAction»
            «permissionCheck('', '')»
        «ELSE»
            $controllerHelper = new «IF app.targets('1.3.5')»«app.appName»_Util_Controller«ELSE»ControllerUtil«ENDIF»($this->serviceManager«IF !app.targets('1.3.5')», ModUtil::getModule($this->name)«ENDIF»);

            // parameter specifying which type of objects we are treating
            $objectType = '«name.formatForCode»';
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
                    $redirectUrl = ModUtil::url($this->name, '«controller.formattedName»', 'view');

                    return $this->redirect($redirectUrl);
                «ELSE»
                    $redirectUrl = $this->serviceManager->get('router')->generate('«app.appName.formatForDB»_' . $objectType . '_view');

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
        «ELSE»
            $entityClass = '«app.vendor.formatForCodeCapital»«app.name.formatForCodeCapital»Module:' . ucwords($objectType) . 'Entity';
        «ENDIF»
        $repository = $this->entityManager->getRepository($entityClass);
        «IF app.targets('1.3.5')»
            $repository->setControllerArguments(array());
        «ELSE»
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

        «IF app.targets('1.3.5')»
            $where = $this->request->query->filter('where', '');
        «ELSE»
            $where = $request->query->filter('where', '', false);
        «ENDIF»
        $where = str_replace('"', '', $where);

        $selectionArgs = array(
            'ot' => $objectType,
            'where' => $where,
            'orderBy' => $sort . ' ' . $sdir
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
        «ELSE»
            $entityClass = '«app.vendor.formatForCodeCapital»«app.name.formatForCodeCapital»Module:' . ucwords($objectType) . 'Entity';
        «ENDIF»
        $repository = $this->entityManager->getRepository($entityClass);
        «IF app.targets('1.3.5')»
            $repository->setControllerArguments(array());
        «ELSE»
            $repository->setRequest($this->request);
        «ENDIF»
        $viewHelper = new «IF app.targets('1.3.5')»«app.appName»_Util_View«ELSE»ViewUtil«ENDIF»($this->serviceManager«IF !app.targets('1.3.5')», ModUtil::getModule($this->name)«ENDIF»);
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
        $currentUrlArgs = array();

        $where = '';

        $selectionArgs = array(
            'ot' => $objectType,
            'where' => $where,
            'orderBy' => $sort . ' ' . $sdir
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
        $cacheId = 'view|ot_' . $objectType . '_sort_' . $sort . '_' . $sdir;
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
                $csv = ($request->query->filter('_format', 'html', false, FILTER_SANITIZE_STRING) == 'csv') ? 1 : 0;
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
                   ->assign('sdir', $sdir)
                   ->assign('pageSize', $resultsPerPage)
                   ->assign('currentUrlObject', $currentUrlObject)
                   ->assign($repository->getAdditionalTemplateParameters('controllerAction', $utilArgs));

        $modelHelper = new «IF app.targets('1.3.5')»«app.appName»_Util_Model«ELSE»ModelUtil«ENDIF»($this->serviceManager«IF !app.targets('1.3.5')», ModUtil::getModule($this->name)«ENDIF»);
        $this->view->assign('canBeCreated', $modelHelper->canBeCreated($objectType));

        // fetch and return the appropriate template
        return $viewHelper->processTemplate($this->view, $objectType, 'view', «IF app.targets('1.3.5')»array()«ELSE»$request«ENDIF», $templateFile);
    '''

    def private prepareViewItemsAjax(Controller it) '''
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
        «ELSE»
            $entityClass = '«app.vendor.formatForCodeCapital»«app.name.formatForCodeCapital»Module:' . ucwords($objectType) . 'Entity';
        «ENDIF»
        $repository = $this->entityManager->getRepository($entityClass);
        «IF app.targets('1.3.5')»
            $repository->setControllerArguments(array());
        «ELSE»
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
        «ELSE»
            $entityClass = '«app.vendor.formatForCodeCapital»«app.name.formatForCodeCapital»Module:' . ucwords($objectType) . 'Entity';
        «ENDIF»
        $repository = $this->entityManager->getRepository($entityClass);
        «IF app.targets('1.3.5')»
            $repository->setControllerArguments(array());
        «ELSE»
            $repository->setRequest($this->request);
        «ENDIF»

        «IF app.targets('1.3.5')»
            $idFields = ModUtil::apiFunc($this->name, 'selection', 'getIdFields', array('ot' => $objectType));

            // retrieve identifier of the object we wish to view
            $idValues = $controllerHelper->retrieveIdentifier($this->request, array(), $objectType, $idFields);
            $hasIdentifier = $controllerHelper->isValidIdentifier($idValues);

            $this->throwNotFoundUnless($hasIdentifier, $this->__('Error! Invalid identifier received.'));

            $selectionArgs = array('ot' => $objectType, 'id' => $idValues);
        «ELSE»
            $hasIdentifier = «IF hasSluggableFields»!empty($slug)«IF !slugUnique» && «ENDIF»«ENDIF»«IF !(hasSluggableFields && slugUnique)»«FOR pkField : primaryKeyFields SEPARATOR ' && '»!empty($«pkField.name.formatForCode»)«ENDFOR»«ENDIF»;

            if (!$hasIdentifier) {
                throw new NotFoundHttpException($this->__('Error! Invalid identifier received.'));
            }

            $selectionArgs = array('ot' => $objectType);
        «ENDIF»

        «IF hasSluggableFields»
            if ($legacyControllerType == 'user') {
                $selectionArgs['slug'] = $slug;
            }
        «ENDIF»
        «IF !app.targets('1.3.5') && !(hasSluggableFields && slugUnique)»
            «FOR pkField : primaryKeyFields»
                $selectionArgs['«pkField.name.formatForCode»'] = $«pkField.name.formatForCode»;
            «ENDFOR»
        «ENDIF»

        $entity = ModUtil::apiFunc($this->name, 'selection', 'getEntity', $selectionArgs);
        «IF app.targets('1.3.5')»
            $this->throwNotFoundUnless($entity != null, $this->__('No such item.'));
        «ELSE»
            if ($entity === null) {
                throw new NotFoundHttpException($this->__('No such item.'));
            }
        «ENDIF»
        unset($idValues);

        $entity->initWorkflow();

        «prepareDisplayPermissionCheck»

        «action.permissionCheck("' . ucwords($objectType) . '", "$instanceId . ")»

        «processDisplayOutput»
    '''

    def private prepareDisplayPermissionCheck(Entity it) '''
        // build ModUrl instance for display hooks; also create identifier for permission check
        $currentUrlArgs = array();
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
        $currentUrlObject = new «IF app.targets('1.3.5')»Zikula_«ENDIF»ModUrl($this->name, '«name.formatForCode»', 'display', ZLanguage::getLanguageCode(), $currentUrlArgs);
    '''

    def private processDisplayOutput(Entity it) '''
        $viewHelper = new «IF app.targets('1.3.5')»«app.appName»_Util_View«ELSE»ViewUtil«ENDIF»($this->serviceManager«IF !app.targets('1.3.5')», ModUtil::getModule($this->name)«ENDIF»);
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
        $viewHelper = new «IF app.targets('1.3.5')»«app.appName»_Util_View«ELSE»ViewUtil«ENDIF»($this->serviceManager«IF !app.targets('1.3.5')», ModUtil::getModule($this->name)«ENDIF»);
        $template = $viewHelper->getViewTemplate($this->view, $objectType, 'edit', «IF app.targets('1.3.5')»array()«ELSE»$request«ENDIF»);

        // execute form using supplied template and page event handler
        return $view->execute($template, new $handlerClass());
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
        «ELSE»
            $hasIdentifier = «IF hasSluggableFields»!empty($slug)«IF !slugUnique» && «ENDIF»«ENDIF»«IF !(hasSluggableFields && slugUnique)»«FOR pkField : primaryKeyFields SEPARATOR ' && '»!empty($«pkField.name.formatForCode»)«ENDFOR»«ENDIF»;

            if (!$hasIdentifier) {
                throw new NotFoundHttpException($this->__('Error! Invalid identifier received.'));
            }

            $selectionArgs = array('ot' => $objectType);
        «ENDIF»

        «IF hasSluggableFields»
            if ($legacyControllerType == 'user') {
                $selectionArgs['slug'] = $slug;
            }
        «ENDIF»
        «IF !app.targets('1.3.5') && !(hasSluggableFields && slugUnique)»
            «FOR pkField : primaryKeyFields»
                $selectionArgs['«pkField.name.formatForCode»'] = $«pkField.name.formatForCode»;
            «ENDFOR»
        «ENDIF»

        $entity = ModUtil::apiFunc($this->name, 'selection', 'getEntity', $selectionArgs);
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
            «IF app.targets('1.3.5')»
                return LogUtil::registerError($this->__('Error! Could not determine workflow actions.'));
            «ELSE»
                $this->request->getSession()->getFlashBag()->add('error', $this->__('Error! Could not determine workflow actions.'));
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
                return false;
            «ENDIF»
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
        «ELSE»
            $entityClass = '«app.vendor.formatForCodeCapital»«app.name.formatForCodeCapital»Module:' . ucwords($objectType) . 'Entity';
        «ENDIF»
        $repository = $this->entityManager->getRepository($entityClass);

        // set caching id
        $this->view->setCaching(Zikula_View::CACHE_DISABLED);

        // assign the object we loaded above
        $this->view->assign($objectType, $entity)
                   ->assign($repository->getAdditionalTemplateParameters('controllerAction', $utilArgs));

        // fetch and return the appropriate template
        $viewHelper = new «IF app.targets('1.3.5')»«app.appName»_Util_View«ELSE»ViewUtil«ENDIF»($this->serviceManager«IF !app.targets('1.3.5')», ModUtil::getModule($this->name)«ENDIF»);

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
