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
    def generate(Application it, IFileSystemAccess fsa) {
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
        fsa.generateFile(getAppSourcePath(app.appName) + baseClassController.asFile, controllerBaseFile)
        fsa.generateFile(getAppSourcePath(app.appName) + implClassController.asFile, controllerFile)
        println('Generating "' + formattedName + '" api classes')
        fsa.generateFile(getAppSourcePath(app.appName) + baseClassApi.asFile, apiBaseFile)
        fsa.generateFile(getAppSourcePath(app.appName) + implClassApi.asFile, apiFile)
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
        /**
         * «name» controller class.
         */
        class «baseClassController» extends Zikula_«IF !isAjaxController»AbstractController«ELSE»Controller_AbstractAjax«ENDIF»
        {
            «IF isAjaxController»

            «ELSE»
                «new ControllerHelper().controllerPostInitialize(it, isUserController)»
            «ENDIF»

            «val actionHelper = new ControllerAction()»
            «FOR action : actions»«actionHelper.generate(action, app)»«ENDFOR»
            «IF hasActions('view') && isAdminController»

                «handleSelectedObjects»
            «ENDIF»
            «IF hasActions('edit')»

                /**
                 * This method cares for a redirect within an inline frame.
                 *
                 * @return boolean
                 */
                public function handleInlineRedirect()
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
                               ->assign('jcssConfig', JCSSUtil::getJSConfig())
                               ->display('«formattedName»/inlineRedirectHandler.tpl');
                    return true;
                }
            «ENDIF»
            «IF app.needsConfig && isConfigController»

                /**
                 * This method takes care of the application configuration.
                 *
                 * @return string Output
                 */
                public function config()
                {
                    $this->throwForbiddenUnless(SecurityUtil::checkPermission($this->name . '::', '::', ACCESS_ADMIN));

                    // Create new Form reference
                    $view = FormUtil::newForm($this->name, $this);

                    // Execute form using supplied template and page event handler
                    return $view->execute('«app.configController.formatForDB»/config.tpl', new «app.appName»_Form_Handler_«app.configController.formatForDB.toFirstUpper»_Config());
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
        public function handleselectedentries($args)
        {
            $this->checkCsrfToken();

            $returnUrl = ModUtil::url($this->name, 'admin', 'main');

            // Determine object type
            $objectType = isset($args['ot']) ? $args['ot'] : $this->request->getPost()->get('ot', '');
            if (!$objectType) {
                return System::redirect($returnUrl);
            }
            $returnUrl = ModUtil::url($this->name, 'admin', 'view', array('ot' => $objectType));

            // Get other parameters
            $items = isset($args['items']) ? $args['items'] : $this->request->getPost()->get('items', null);
            $action = isset($args['action']) ? $args['action'] : $this->request->getPost()->get('action', null);
            $action = strtolower($action);

            $workflowHelper = new «app.appName»_Util_Workflow($this->serviceManager);

            // process each item
            foreach ($items as $itemid) {
                // check if item exists, and get record instance
                $selectionArgs = array('ot' => $objectType, 'id' => $itemid, 'useJoins' => false);
                $entity = ModUtil::apiFunc($this->name, 'selection', 'getEntity', $selectionArgs);

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
                $hook = new Zikula_ValidationHook($hookAreaPrefix . '.' . $hookType, new Zikula_Hook_ValidationProviders());
                $validators = $this->notifyHooks($hook)->getValidators();
                if ($validators->hasErrors()) {
                    continue;
                }

                $success = false;
                try {
                    // execute the workflow action
                    $success = $workflowHelper->executeAction($entity, $action);
                } catch(Exception $e) {
                    LogUtil::registerError($this->__f('Sorry, but an unknown error occured during the %s action. Please apply the changes again!', array($action)));
                }

                if (!$success) {
                    continue;
                }

                if ($action == 'delete') {
                    LogUtil::registerStatus($this->__('Done! Item deleted.'));
                }
                else {
                    LogUtil::registerStatus($this->__('Done! Item updated.'));
                }

                // Let any hooks know that we have updated or deleted an item
                $hookType = $action == 'delete' ? 'process_delete' : 'process_edit';
                $url = null;
                if ($action != 'delete') {
                    $urlArgs = array('ot' => $this->objectType);
                    $urlArgs = $this->addIdentifiersToUrlArgs($urlArgs);
                    if (isset($this->entityRef['slug'])) {
                        $urlArgs['slug'] = $this->entityRef['slug'];
                    }
                    $url = new Zikula_ModUrl($this->name, '«formattedName»', 'display', ZLanguage::getLanguageCode(), $urlArgs);
                }
                $hook = new Zikula_ProcessHook($hookAreaPrefix . '.' . $hookType, $entity->createCompositeIdentifier(), $url);
                $this->notifyHooks($hook);

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
        /**
         * This is the «name» controller class providing navigation and interaction functionality.
         */
        class «implClassController» extends «baseClassController»
        {
            // feel free to add your own controller methods here
        }
    '''



    def private apiBaseImpl(Controller it) '''
        /**
         * This is the «name» api helper class.
         */
        class «baseClassApi» extends Zikula_AbstractApi
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
                «IF hasActions('view')»
                    «FOR entity : app.getAllEntities»
                        if (SecurityUtil::checkPermission($this->name . ':«entity.name.formatForCodeCapital»:', '::', ACCESS_«menuLinksPermissionLevel»)) {
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
                        $links[] = array('url' => ModUtil::url($this->name, '«userController.formattedName»', «userController.mainUrlDetails»),
                                         'text' => $this->__('Frontend'),
                                         'title' => $this->__('Switch to user area.'),
                                         'class' => 'z-icon-es-home');
                    }
                    '''
            UserController case !container.getAdminControllers.isEmpty: '''
                    «val adminController = container.getAdminControllers.head»
                    if (SecurityUtil::checkPermission($this->name . '::', '::', ACCESS_ADMIN)) {
                        $links[] = array('url' => ModUtil::url($this->name, '«adminController.formattedName»', «adminController.mainUrlDetails»),
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
        /**
         * This is the «name» api helper class.
         */
        class «implClassApi» extends «baseClassApi»
        {
            // feel free to add own api methods here
        }
    '''

    def private mainUrlDetails(Controller it) {
        if (hasActions('main')) '\'main\''
        else if (hasActions('view')) '\'view\', array(\'ot\' => \'' + container.application.getLeadingEntity.name.formatForCode + '\')'
        else if (container.application.needsConfig && isConfigController) '\'config\''
        else '\'hooks\''
    }
}
