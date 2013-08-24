package org.zikula.modulestudio.generator.cartridges.zclassic.controller

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.AdminController
import de.guite.modulestudio.metamodel.modulestudio.Application
import de.guite.modulestudio.metamodel.modulestudio.Controller
import de.guite.modulestudio.metamodel.modulestudio.UserController
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.additions.Ajax
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.additions.ExternalController
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.additions.Scribite
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.additions.UrlRouting
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.apis.Category
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.apis.Selection
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.apis.ShortUrls
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.javascript.DisplayFunctions
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.javascript.EditFunctions
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.javascript.Finder
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.javascript.TreeFunctions
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.javascript.Validation
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ControllerLayer {
    @Inject extension ControllerExtensions = new ControllerExtensions()
    @Inject extension FormattingExtensions = new FormattingExtensions()
    @Inject extension ModelExtensions = new ModelExtensions()
    @Inject extension ModelBehaviourExtensions = new ModelBehaviourExtensions()
    @Inject extension NamingExtensions = new NamingExtensions()
    @Inject extension Utils = new Utils()

    FileHelper fh = new FileHelper()
    Application app

    /**
     * Entry point for the controller creation.
     */
    def void generate(Application it, IFileSystemAccess fsa) {
        this.app = it
        getAllControllers.forEach(e|e.generate(fsa))
        // controller for external calls
        new ExternalController().generate(it, fsa)
        // selection api
        new Selection().generate(it, fsa)
        if (hasCategorisableEntities)
            new Category().generate(it, fsa)
        new UtilMethods().generate(it, fsa)
        if (hasUserController)
            new UrlRouting().generate(it, fsa)
        // scribite integration
        new Scribite().generate(it, fsa)

        // JavaScript
        new Finder().generate(it, fsa)
        if (hasEditActions)
            new EditFunctions().generate(it, fsa)
        new DisplayFunctions().generate(it, fsa)
        if (hasTrees)
            new TreeFunctions().generate(it, fsa)
        new Validation().generate(it, fsa)
    }

    /**
     * Creates controller and api class files for every Controller instance.
     */
    def private generate(Controller it, IFileSystemAccess fsa) {
        println('Generating "' + formattedName + '" controller classes')
        val controllerPath = app.getAppSourceLibPath + 'Controller/'
        val controllerClassSuffix = if (!app.targets('1.3.5')) 'Controller' else ''
        val controllerFileName = name.formatForCodeCapital + controllerClassSuffix + '.php'
        fsa.generateFile(controllerPath + 'Base/' + controllerFileName, controllerBaseFile)
        fsa.generateFile(controllerPath + controllerFileName, controllerFile)

        println('Generating "' + formattedName + '" api classes')
        val apiPath = app.getAppSourceLibPath + 'Api/'
        val apiClassSuffix = if (!app.targets('1.3.5')) 'Api' else ''
        val apiFileName = name.formatForCodeCapital + apiClassSuffix + '.php'
        fsa.generateFile(apiPath + 'Base/' + apiFileName, apiBaseFile)
        fsa.generateFile(apiPath + apiFileName, apiFile)
    }

    def private controllerBaseFile(Controller it) '''
        «fh.phpFileHeader(app)»
        «controllerBaseImpl»
    '''

    def private controllerFile(Controller it) '''
        «fh.phpFileHeader(app)»
        «controllerImpl»
    '''

    def private apiBaseFile(Controller it) '''
        «fh.phpFileHeader(app)»
        «apiBaseImpl»
    '''

    def private apiFile(Controller it) '''
        «fh.phpFileHeader(app)»
        «apiImpl»
    '''

    def private controllerBaseImpl(Controller it) '''
        «IF !app.targets('1.3.5')»
            namespace «app.appName»\Controller\Base;

            «IF app.needsConfig && isConfigController»
                use «app.appName»\Form\Handler\«app.configController.formatForDB.toFirstUpper»\ConfigHandler;
            «ENDIF»
            use «app.appName»\Util\ControllerUtil;
            «IF isAjaxController && app.hasImageFields»
                use «app.appName»\Util\ImageUtil;
            «ENDIF»
            use «app.appName»\Util\ViewUtil;
            «IF (isAjaxController && app.hasTrees) || (hasActions('view') && isAdminController) || hasActions('delete')»
                use «app.appName»\Util\WorkflowUtil;
            «ENDIF»

            «IF isAjaxController»
                use DataUtil;
                «IF !app.getAllUserFields.isEmpty»
                    use Doctrine\ORM\AbstractQuery;
                «ENDIF»
            «ENDIF»
            use FormUtil;
            «IF hasActions('edit')»
                use JCSSUtil;
            «ENDIF»
            use LogUtil;
            use ModUtil;
            use SecurityUtil;
            «IF hasActions('view') && isAdminController»
                use System;
            «ENDIF»
            use Zikula_«IF !isAjaxController»AbstractController«ELSE»Controller_AbstractAjax«ENDIF»;
            use Zikula_View;
            use ZLanguage;
            «IF (hasActions('view') && isAdminController) || hasActions('delete')»
                use Zikula\Core\Hook\ProcessHook;
                use Zikula\Core\Hook\ValidationHook;
                use Zikula\Core\Hook\ValidationProviders;
            «ENDIF»
            use Zikula\Core\ModUrl;
            «IF isAjaxController»
                use Zikula\Core\Response\Ajax\AjaxResponse;
                use Zikula\Core\Response\Ajax\BadDataResponse;
                use Zikula\Core\Response\Ajax\FatalResponse;
                use Zikula\Core\Response\Ajax\NotFoundResponse;
                use Zikula\Core\Response\Ajax\Plain;
            «ENDIF»
            use Zikula\Core\Response\PlainResponse;

        «ENDIF»
        /**
         * «name» controller class.
         */
        class «IF app.targets('1.3.5')»«app.appName»_Controller_Base_«name.formatForCodeCapital»«ELSE»«name.formatForCodeCapital»Controller«ENDIF» extends Zikula_«IF !isAjaxController»AbstractController«ELSE»Controller_AbstractAjax«ENDIF»
        {
            «IF isAjaxController»

            «ELSE»
                «new ControllerHelper().controllerPostInitialize(it, isUserController, '')»
            «ENDIF»

            «val actionHelper = new ControllerAction(app)»
            «FOR action : actions»«actionHelper.generate(action)»«ENDFOR»
            «IF hasActions('view') && isAdminController»

                «handleSelectedObjects»
            «ENDIF»
            «IF hasActions('edit')»

                /**
                 * This method cares for a redirect within an inline frame.
                 *
                 * @return boolean
                 */
                public function handleInlineRedirect«IF !app.targets('1.3.5')»Action«ENDIF»()
                {
                    $itemId = (int) $this->request->query->filter('id', 0, FILTER_VALIDATE_INT);
                    $idPrefix = $this->request->query->filter('idp', '', FILTER_SANITIZE_STRING);
                    $commandName = $this->request->query->filter('com', '', FILTER_SANITIZE_STRING);
                    if (empty($idPrefix)) {
                        return false;
                    }

                    $this->view->assign('itemId', $itemId)
                               ->assign('idPrefix', $idPrefix)
                               ->assign('commandName', $commandName)
                               ->assign('jcssConfig', JCSSUtil::getJSConfig());

                    «IF app.targets('1.3.5')»
                    $view->display('«formattedName»/inlineRedirectHandler.tpl');

                    return true;
                    «ELSE»
                    return new PlainResponse($view->display('«formattedName.toFirstUpper»/inlineRedirectHandler.tpl'));
                    «ENDIF»
                }
            «ENDIF»
            «IF app.needsConfig && isConfigController»

                /**
                 * This method takes care of the application configuration.
                 *
                 * @return string Output
                 */
                public function config«IF !app.targets('1.3.5')»Action«ENDIF»()
                {
                    $this->throwForbiddenUnless(SecurityUtil::checkPermission($this->name . '::', '::', ACCESS_ADMIN));

                    // Create new Form reference
                    $view = FormUtil::newForm($this->name, $this);

                    $templateName = '«IF app.targets('1.3.5')»«app.configController.formatForDB»«ELSE»«app.configController.formatForCodeCapital»«ENDIF»/config.tpl';

                    // Execute form using supplied template and page event handler
                    return $view->execute($templateName, new «IF app.targets('1.3.5')»«app.appName»_Form_Handler_«app.configController.formatForDB.toFirstUpper»_Config«ELSE»ConfigHandler«ENDIF»());
                }
            «ENDIF»
            «new Ajax().additionalAjaxFunctions(it, app)»
        }
    '''

    def private handleSelectedObjects(Controller it) '''
        /**
         * Process status changes for multiple items.
         *
         * This function processes the items selected in the admin view page.
         * Multiple items may have their state changed or be deleted.
         *
         * @param array  items  Identifier list of the items to be processed.
         * @param string action The action to be executed.
         *
         * @return bool true on sucess, false on failure.
         */
        public function handleselectedentries«IF !app.targets('1.3.5')»Action«ENDIF»(array $args = array())
        {
            $this->checkCsrfToken();

            $returnUrl = ModUtil::url($this->name, 'admin', '«IF app.targets('1.3.5')»main«ELSE»index«ENDIF»');

            // Determine object type
            $objectType = isset($args['ot']) ? $args['ot'] : $this->request->request->get('ot', '');
            if (!$objectType) {
                return System::redirect($returnUrl);
            }
            $returnUrl = ModUtil::url($this->name, 'admin', 'view', array('ot' => $objectType));

            // Get other parameters
            $items = isset($args['items']) ? $args['items'] : $this->request->request->get('items', null);
            $action = isset($args['action']) ? $args['action'] : $this->request->request->get('action', null);
            $action = strtolower($action);

            $workflowHelper = new «IF app.targets('1.3.5')»«app.appName»_Util_Workflow«ELSE»WorkflowUtil«ENDIF»($this->serviceManager«IF !app.targets('1.3.5')», ModUtil::getModule($this->name)«ENDIF»);

            // process each item
            foreach ($items as $itemid) {
                // check if item exists, and get record instance
                $selectionArgs = array('ot' => $objectType, 'id' => $itemid, 'useJoins' => false);
                $entity = ModUtil::apiFunc($this->name, 'selection', 'getEntity', $selectionArgs);

                $entity->initWorkflow();

                // check if $action can be applied to this entity (may depend on it's current workflow state)
                $allowedActions = $workflowHelper->getActionsForObject($entity);
                $actionIds = array_keys($allowedActions);
                if (!in_array($action, $actionIds)) {
                    // action not allowed, skip this object
                    continue;
                }

                $hookAreaPrefix = $entity->getHookAreaPrefix();

                // Let any hooks perform additional validation actions
                $hookType = $action == 'delete' ? 'validate_delete' : 'validate_edit';
                «IF app.targets('1.3.5')»
                $hook = new Zikula_ValidationHook($hookAreaPrefix . '.' . $hookType, new Zikula_Hook_ValidationProviders());
                $validators = $this->notifyHooks($hook)->getValidators();
                «ELSE»
                $hook = new ValidationHook(new ValidationProviders());
                $validators = $this->dispatchHooks($hookAreaPrefix . '.' . $hookType, $hook)->getValidators();
                «ENDIF»
                if ($validators->hasErrors()) {
                    continue;
                }

                $success = false;
                try {
                    // execute the workflow action
                    $success = $workflowHelper->executeAction($entity, $action);
                } catch(\Exception $e) {
                    LogUtil::registerError($this->__f('Sorry, but an unknown error occured during the %s action. Please apply the changes again!', array($action)));
                }

                if (!$success) {
                    continue;
                }

                if ($action == 'delete') {
                    LogUtil::registerStatus($this->__('Done! Item deleted.'));
                } else {
                    LogUtil::registerStatus($this->__('Done! Item updated.'));
                }

                // Let any hooks know that we have updated or deleted an item
                $hookType = $action == 'delete' ? 'process_delete' : 'process_edit';
                $url = null;
                if ($action != 'delete') {
                    $urlArgs = $entity->createUrlArgs();
                    $url = new «IF app.targets('1.3.5')»Zikula_«ENDIF»ModUrl($this->name, '«formattedName»', 'display', ZLanguage::getLanguageCode(), $urlArgs);
                }
                «IF app.targets('1.3.5')»
                $hook = new Zikula_ProcessHook($hookAreaPrefix . '.' . $hookType, $entity->createCompositeIdentifier(), $url);
                $this->notifyHooks($hook);
                «ELSE»
                $hook = new ProcessHook($entity->createCompositeIdentifier(), $url);
                $this->dispatchHooks($hookAreaPrefix . '.' . $hookType, $hook);
                «ENDIF»

                // An item was updated or deleted, so we clear all cached pages for this item.
                $cacheArgs = array('ot' => $objectType, 'item' => $entity);
                ModUtil::apiFunc($this->name, 'cache', 'clearItemCache', $cacheArgs);
            }

            // clear view cache to reflect our changes
            $this->view->clear_cache();

            return System::redirect($returnUrl);
        }
    '''


    def private controllerImpl(Controller it) '''
        «val app = container.application»
        «IF !app.targets('1.3.5')»
            namespace «app.appName»\Controller;

        «ENDIF»
        /**
         * This is the «name» controller class providing navigation and interaction functionality.
         */
        «IF app.targets('1.3.5')»
        class «app.appName»_Controller_«name.formatForCodeCapital» extends «app.appName»_Controller_Base_«name.formatForCodeCapital»
        «ELSE»
        class «name.formatForCodeCapital»Controller extends Base\«name.formatForCodeCapital»Controller
        «ENDIF»
        {
            // feel free to add your own controller methods here
        }
    '''



    def private apiBaseImpl(Controller it) '''
        «val app = container.application»
        «IF !app.targets('1.3.5')»
            namespace «app.appName»\Api\Base;

            «IF isUserController»
                use «app.appName»\RouterFacade;
                use «app.appName»\Util\ControllerUtil;
                use LogUtil;
            «ENDIF»
            use ModUtil;
            use SecurityUtil;
            «IF isUserController»
                use System;
            «ENDIF»
            use Zikula_AbstractApi;

        «ENDIF»
        /**
         * This is the «name» api helper class.
         */
        class «IF app.targets('1.3.5')»«app.appName»_Api_Base_«name.formatForCodeCapital»«ELSE»«name.formatForCodeCapital»Api«ENDIF» extends Zikula_AbstractApi
        {
            «IF !isAjaxController»
            /**
             * Returns available «name.formatForDB» panel links.
             *
             * @return array Array of «name.formatForDB» links.
             */
            public function getlinks()
            {
                $links = array();

                «menuLinksBetweenControllers»

                $controllerHelper = new «IF app.targets('1.3.5')»«app.appName»_Util_Controller«ELSE»ControllerUtil«ENDIF»($this->serviceManager«IF !app.targets('1.3.5')», ModUtil::getModule($this->name)«ENDIF»);
                $utilArgs = array('api' => '«it.formattedName»', 'action' => 'getlinks');
                $allowedObjectTypes = $controllerHelper->getObjectTypes('api', $utilArgs);

                «IF hasActions('view')»
                    «FOR entity : app.getAllEntities»
                        if (in_array('«entity.name.formatForCode»', $allowedObjectTypes)
                            && SecurityUtil::checkPermission($this->name . ':«entity.name.formatForCodeCapital»:', '::', ACCESS_«menuLinksPermissionLevel»)) {
                            $links[] = array('url' => ModUtil::url($this->name, '«formattedName»', 'view', array('ot' => '«entity.name.formatForCode»')),
                                             'text' => $this->__('«entity.nameMultiple.formatForDisplayCapital»'),
                                             'title' => $this->__('«entity.name.formatForDisplayCapital» list'));
                        }
                    «ENDFOR»
                «ENDIF»
                «IF app.needsConfig && isConfigController»
                    if (SecurityUtil::checkPermission($this->name . '::', '::', ACCESS_ADMIN)) {
                        $links[] = array('url' => ModUtil::url($this->name, '«app.configController.formatForDB»', 'config'),
                                         'text' => $this->__('Configuration'),
                                         'title' => $this->__('Manage settings for this application'));
                    }
                «ENDIF»

                return $links;
            }
            «ENDIF»
            «additionalApiMethods»
        }
    '''

    def private menuLinksBetweenControllers(Controller it) {
        switch it {
            AdminController case !container.getUserControllers.isEmpty: '''
                    «val userController = container.getUserControllers.head»
                    if (SecurityUtil::checkPermission($this->name . '::', '::', ACCESS_READ)) {
                        $links[] = array('url' => ModUtil::url($this->name, '«userController.formattedName»', «userController.indexUrlDetails»),
                                         'text' => $this->__('Frontend'),
                                         'title' => $this->__('Switch to user area.'),
                                         'class' => 'z-icon-es-home');
                    }
                    '''
            UserController case !container.getAdminControllers.isEmpty: '''
                    «val adminController = container.getAdminControllers.head»
                    if (SecurityUtil::checkPermission($this->name . '::', '::', ACCESS_ADMIN)) {
                        $links[] = array('url' => ModUtil::url($this->name, '«adminController.formattedName»', «adminController.indexUrlDetails»),
                                         'text' => $this->__('Backend'),
                                         'title' => $this->__('Switch to administration area.'),
                                         'class' => 'z-icon-es-options');
                    }
                    '''
        }
    }

    def private menuLinksPermissionLevel(Controller it) {
        switch it {
            AdminController case !container.getUserControllers.isEmpty: 'ADMIN'
            default: 'READ'
        }
    }

    def private additionalApiMethods(Controller it) {
        switch it {
            UserController: new ShortUrls(app).generate(it)
            default: ''
        }
    }

    def private apiImpl(Controller it) '''
        «val app = container.application»
        «IF !app.targets('1.3.5')»
            namespace «app.appName»\Api;

        «ENDIF»
        /**
         * This is the «name» api helper class.
         */
        «IF app.targets('1.3.5')»
        class «app.appName»_Api_«name.formatForCodeCapital» extends «app.appName»_Api_Base_«name.formatForCodeCapital»
        «ELSE»
        class «name.formatForCodeCapital»Api extends Base\«name.formatForCodeCapital»Api
        «ENDIF»
        {
            // feel free to add own api methods here
        }
    '''

    def private indexUrlDetails(Controller it) {
        if (hasActions('index')) '\'' + (if (app.targets('1.3.5')) 'main' else 'index') + '\''
        else if (hasActions('view')) '\'view\', array(\'ot\' => \'' + container.application.getLeadingEntity.name.formatForCode + '\')'
        else if (container.application.needsConfig && isConfigController) '\'config\''
        else '\'hooks\''
    }
}
