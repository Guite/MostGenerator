package org.zikula.modulestudio.generator.cartridges.zclassic.controller

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.AdminController
import de.guite.modulestudio.metamodel.modulestudio.AjaxController
import de.guite.modulestudio.metamodel.modulestudio.Application
import de.guite.modulestudio.metamodel.modulestudio.Controller
import de.guite.modulestudio.metamodel.modulestudio.Entity
import de.guite.modulestudio.metamodel.modulestudio.EntityTreeType
import de.guite.modulestudio.metamodel.modulestudio.NamedObject
import de.guite.modulestudio.metamodel.modulestudio.UserController
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.additions.Ajax
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.additions.ExternalController
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.additions.Routing
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.additions.Scribite
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.additions.UrlRoutingLegacy
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.apis.ShortUrlsLegacy
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.javascript.DisplayFunctions
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.javascript.EditFunctions
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.javascript.Finder
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.javascript.TreeFunctions
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.javascript.Validation
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.GeneratorSettingsExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ControllerLayer {
    @Inject extension ControllerExtensions = new ControllerExtensions
    @Inject extension FormattingExtensions = new FormattingExtensions
    @Inject extension GeneratorSettingsExtensions = new GeneratorSettingsExtensions
    @Inject extension ModelExtensions = new ModelExtensions
    @Inject extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    @Inject extension NamingExtensions = new NamingExtensions
    @Inject extension Utils = new Utils

    FileHelper fh = new FileHelper
    Application app

    /**
     * Entry point for the controller creation.
     */
    def void generate(Application it, IFileSystemAccess fsa) {
        this.app = it

        // controllers and apis
        getAllControllers.forEach[generateControllerAndApi(fsa)]
        getAllEntities.forEach[generateController(fsa)]

        new UtilMethods().generate(it, fsa)
        if (targets('1.3.5')) {
            if (hasUserController) {
                new UrlRoutingLegacy().generate(it, fsa)
            }
        } else {
            new Routing().generate(it, fsa)
        }

        if (generateExternalControllerAndFinder) {
            // controller for external calls
            new ExternalController().generate(it, fsa)

            if (generateScribitePlugins) {
                // Scribite integration
                new Scribite().generate(it, fsa)
            }
        }

        // JavaScript
        if (generateExternalControllerAndFinder) {
            new Finder().generate(it, fsa)
        }
        if (hasEditActions) {
            new EditFunctions().generate(it, fsa)
        }
        new DisplayFunctions().generate(it, fsa)
        if (hasTrees) {
            new TreeFunctions().generate(it, fsa)
        }
        new Validation().generate(it, fsa)
    }

    /**
     * Creates controller and api class files for every Controller instance.
     */
    def private generateControllerAndApi(Controller it, IFileSystemAccess fsa) {
        println('Generating "' + formattedName + '" controller classes')
        app.generateClassPair(fsa, app.getAppSourceLibPath + 'Controller/' + name.formatForCodeCapital + (if (app.targets('1.3.5')) '' else 'Controller') + '.php',
            fh.phpFileContent(app, controllerBaseImpl), fh.phpFileContent(app, controllerImpl)
        )

        println('Generating "' + formattedName + '" api classes')
        app.generateClassPair(fsa, app.getAppSourceLibPath + 'Api/' + name.formatForCodeCapital + (if (app.targets('1.3.5')) '' else 'Api') + '.php',
            fh.phpFileContent(app, apiBaseImpl), fh.phpFileContent(app, apiImpl)
        )
    }

    /**
     * Creates controller class files for every Entity instance.
     */
    def private generateController(Entity it, IFileSystemAccess fsa) {
        println('Generating "' + name.formatForDisplay + '" controller classes')
        app.generateClassPair(fsa, app.getAppSourceLibPath + 'Controller/' + name.formatForCodeCapital + (if (app.targets('1.3.5')) '' else 'Controller') + '.php',
            fh.phpFileContent(app, entityControllerBaseImpl), fh.phpFileContent(app, entityControllerImpl)
        )
    }

    def private controllerBaseImpl(Controller it) '''
        «val isAjaxController = (it instanceof AjaxController)»
        «controllerBaseImports»
        /**
         * «name» controller class.
         */
        class «IF app.targets('1.3.5')»«app.appName»_Controller_Base_«name.formatForCodeCapital»«ELSE»«name.formatForCodeCapital»Controller«ENDIF» extends Zikula_«IF !isAjaxController»AbstractController«ELSE»Controller_AbstractAjax«ENDIF»
        {
            «IF isAjaxController»

            «ELSE»
                «val isUserController = (it instanceof UserController)»
                «new ControllerHelper().controllerPostInitialize(it, isUserController, '')»
            «ENDIF»

            «val actionHelper = new ControllerAction(app)»
            «FOR action : actions»«actionHelper.generate(action, true)»«ENDFOR»
            «IF hasActions('edit')»

                «handleInlineRedirect(true)»
            «ENDIF»
            «IF app.needsConfig && isConfigController»

                «configAction(true)»
            «ENDIF»
            «IF isAjaxController»
                «new Ajax().additionalAjaxFunctions(it, app)»
            «ENDIF»
        }
    '''

    def private entityControllerBaseImpl(Entity it) '''
        «entityControllerBaseImports»
        /**
         * «name.formatForDisplayCapital» controller base class.
         */
        class «IF app.targets('1.3.5')»«app.appName»_Controller_Base_«name.formatForCodeCapital»«ELSE»«name.formatForCodeCapital»Controller«ENDIF» extends Zikula_AbstractController
        {
            «new ControllerHelper().controllerPostInitialize(it, false, '')»

            «val actionHelper = new ControllerAction(app)»
            «FOR action : app.getActionsOfAdminAndUserControllers»«actionHelper.generate(it, action, true)»«ENDFOR»
            «IF hasActions('view') && app.hasAdminController»

                «handleSelectedObjects(true)»
            «ENDIF»
            «IF hasActions('edit')»

                «handleInlineRedirect(true)»
            «ENDIF»
        }
    '''

    def private controllerBaseImports(Controller it) '''
        «val isAdminController = (it instanceof AdminController)»
        «val isAjaxController = (it instanceof AjaxController)»
        «IF !app.targets('1.3.5')»
            namespace «app.appNamespace»\Controller\Base;

            «IF app.needsConfig && isConfigController»
                use «app.appNamespace»\Form\Handler\«app.configController.formatForDB.toFirstUpper»\ConfigHandler;

            «ENDIF»
            use Symfony\Component\HttpFoundation\Request;
            «IF (app.needsConfig && isConfigController) || hasActions('edit')»
                use Symfony\Component\HttpFoundation\Response;
            «ENDIF»
            use Symfony\Component\Security\Core\Exception\AccessDeniedException;
            «IF hasActions('display') || hasActions('edit') || hasActions('delete')»
                use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;
            «ENDIF»
            «IF hasActions('main') || hasActions('view') || hasActions('delete')»
                use Symfony\Component\HttpFoundation\RedirectResponse;
            «ENDIF»
            «IF isAjaxController»
                «IF !app.getAllUserFields.empty»
                    use Doctrine\ORM\AbstractQuery;
                «ENDIF»
                use DataUtil;
            «ENDIF»
            «IF hasActions('edit')»
                use JCSSUtil;
            «ENDIF»
            use ModUtil;
            use SecurityUtil;
            «IF (hasActions('view') && isAdminController) || hasActions('main') || hasActions('delete')»
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
            «controllerBaseImportsResponse»

        «ENDIF»
    '''

    def private entityControllerBaseImports(Entity it) '''
        «IF !app.targets('1.3.5')»
            namespace «app.appNamespace»\Controller\Base;

            use «entityClassName('', false)»;
            use Symfony\Component\HttpFoundation\Request;
            use Symfony\Component\Security\Core\Exception\AccessDeniedException;
            «IF hasActions('display') || hasActions('edit') || hasActions('delete')»
                use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;
            «ENDIF»
            «IF hasActions('main') || hasActions('view') || hasActions('delete')»
                use Symfony\Component\HttpFoundation\RedirectResponse;
            «ENDIF»
            use Sensio\Bundle\FrameworkExtraBundle\Configuration\Cache;
            «IF hasActions('display') || hasActions('delete')»
                use Sensio\Bundle\FrameworkExtraBundle\Configuration\ParamConverter;
            «ENDIF»
            use Sensio\Bundle\FrameworkExtraBundle\Configuration\Route;
            use FormUtil;
            «IF hasActions('edit')»
                use JCSSUtil;
            «ENDIF»
            use ModUtil;
            use SecurityUtil;
            «IF (hasActions('view') && app.hasAdminController) || hasActions('main') || hasActions('delete')»
                use System;
            «ENDIF»
            use Zikula_AbstractController;
            use Zikula_View;
            use ZLanguage;
            «IF (hasActions('view') && app.hasAdminController) || hasActions('delete')»
                use Zikula\Core\Hook\ProcessHook;
                use Zikula\Core\Hook\ValidationHook;
                use Zikula\Core\Hook\ValidationProviders;
            «ENDIF»
            use Zikula\Core\ModUrl;
            «entityControllerBaseImportsResponse»

        «ENDIF»
    '''

    def private controllerBaseImportsResponse(Controller it) '''
        «IF it instanceof AjaxController»
            use Zikula\Core\Response\Ajax\AjaxResponse;
            use Zikula\Core\Response\Ajax\BadDataResponse;
            use Zikula\Core\Response\Ajax\FatalResponse;
            use Zikula\Core\Response\Ajax\NotFoundResponse;
        «ENDIF»
        use Zikula\Core\Response\PlainResponse;
    '''

    def private entityControllerBaseImportsResponse(Entity it) '''
        use Zikula\Core\Response\PlainResponse;
    '''

    def private handleSelectedObjects(Entity it, Boolean isBase) '''
        «handleSelectedObjectsDocBlock(isBase)»
        public function handleSelectedEntries«IF app.targets('1.3.5')»()«ELSE»Action(Request $request)«ENDIF»
        {
            «IF isBase»
                «handleSelectedObjectsBaseImpl»
            «ELSE»
                return parent::handleSelectedEntriesAction($request);
            «ENDIF»
        }
    '''

    def private handleSelectedObjectsDocBlock(Entity it, Boolean isBase) '''
        /**
         * Process status changes for multiple items.
         *
         * This function processes the items selected in the admin view page.
         * Multiple items may have their state changed or be deleted.
         «IF !app.targets('1.3.5') && !isBase»
         *
         * @Route("/%«app.appName.formatForDB».routing.«name.formatForCode».plural%/handleSelectedEntries",
         *        name = "«app.appName.formatForDB»_«name.formatForCode»_handleSelectedEntries",
         *        methods = {"POST"}
         * )
         «ENDIF»
         *
         * @param string $action The action to be executed.
         * @param array  $items  Identifier list of the items to be processed.
         *
         * @return bool true on sucess, false on failure.
         «IF !app.targets('1.3.5')»
         *
         * @throws RuntimeException Thrown if executing the workflow action fails
         «ENDIF»
         */
    '''

    def private handleSelectedObjectsBaseImpl(Entity it) '''
        $this->checkCsrfToken();

        «IF app.targets('1.3.5')»
            $redirectUrl = ModUtil::url($this->name, 'admin', 'main', array('ot' => '«name.formatForCode»'));
        «ELSE»
            $redirectUrl = $this->serviceManager->get('router')->generate('«app.appName.formatForDB»_«name.formatForCode»_index', array('lct' => 'admin'));
        «ENDIF»

        $objectType = '«name.formatForCode»';

        // Get parameters
        $action = $«IF app.targets('1.3.5')»this->«ENDIF»request->request->get('action', null);
        $items = $«IF app.targets('1.3.5')»this->«ENDIF»request->request->get('items', null);

        $action = strtolower($action);

        «IF app.targets('1.3.5')»
            $workflowHelper = new «app.appName»_Util_Workflow($this->serviceManager);
        «ELSE»
            $workflowHelper = $this->serviceManager->get('«app.appName.formatForDB».workflow_helper');
        «ENDIF»

        // process each item
        foreach ($items as $itemid) {
            // check if item exists, and get record instance
            $selectionArgs = array('ot' => $objectType,
                                   'id' => $itemid,
                                   'useJoins' => false);
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
                «IF app.targets('1.3.5')»
                    LogUtil::registerError($this->__f('Sorry, but an unknown error occured during the %s action. Please apply the changes again!', array($action)));
                «ELSE»
                    $this->request->getSession()->getFlashBag()->add('error', $this->__f('Sorry, but an unknown error occured during the %s action. Please apply the changes again!', array($action)));
                    $logger = $this->serviceManager->get('logger');
                    $logger->error('{app}: User {user} tried to execute the {action} workflow action for the {entity} with id {id}, but failed. Error details: {errorMessage}.', array('app' => '«app.appName»', 'user' => UserUtil::getVar('uname'), 'action' => $action, 'entity' => '«name.formatForDisplay»', 'id' => $itemid, 'errorMessage' => $e->getMessage()));
                «ENDIF»
            }

            if (!$success) {
                continue;
            }

            if ($action == 'delete') {
                «IF app.targets('1.3.5')»
                    LogUtil::registerStatus($this->__('Done! Item deleted.'));
                «ELSE»
                    $this->request->getSession()->getFlashBag()->add('status', $this->__('Done! Item deleted.'));
                    $logger = $this->serviceManager->get('logger');
                    $logger->notice('{app}: User {user} deleted the {entity} with id {id}.', array('app' => '«app.appName»', 'user' => UserUtil::getVar('uname'), 'entity' => '«name.formatForDisplay»', 'id' => $itemid));
                «ENDIF»
            } else {
                «IF app.targets('1.3.5')»
                    LogUtil::registerStatus($this->__('Done! Item updated.'));
                «ELSE»
                    $this->request->getSession()->getFlashBag()->add('status', $this->__('Done! Item updated.'));
                    $logger = $this->serviceManager->get('logger');
                    $logger->notice('{app}: User {user} executed the {action} workflow action for the {entity} with id {id}.', array('app' => '«app.appName»', 'user' => UserUtil::getVar('uname'), 'action' => $action, 'entity' => '«name.formatForDisplay»', 'id' => $itemid));
                «ENDIF»
            }

            // Let any hooks know that we have updated or deleted an item
            $hookType = $action == 'delete' ? 'process_delete' : 'process_edit';
            $url = null;
            if ($action != 'delete') {
                $urlArgs = $entity->createUrlArgs();
                $url = new «IF app.targets('1.3.5')»Zikula_«ENDIF»ModUrl($this->name, '«name.formatForCode»', 'display', ZLanguage::getLanguageCode(), $urlArgs);
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

        «IF app.targets('1.3.5')»
            return $this->redirect($redirectUrl);
        «ELSE»
            return new RedirectResponse(System::normalizeUrl($redirectUrl));
        «ENDIF»
    '''

    def private handleInlineRedirect(NamedObject it, Boolean isBase) '''
        «handleInlineRedirectDocBlock(isBase)»
        public function handleInlineRedirect«IF app.targets('1.3.5')»()«ELSE»Action($idPrefix, $commandName, $id = 0)«ENDIF»
        {
            «IF isBase»
                «handleInlineRedirectBaseImpl»
            «ELSE»
                return parent::handleInlineRedirectAction($idPrefix, $commandName, $id);
            «ENDIF»
        }
    '''

    def private handleInlineRedirectDocBlock(NamedObject it, Boolean isBase) '''
        /**
         * This method cares for a redirect within an inline frame.
         «IF it instanceof Entity && !app.targets('1.3.5') && !isBase»
         *
         * @Route("/%«app.appName.formatForDB».routing.«name.formatForCode».singular%/handleInlineRedirect/{idPrefix}/{commandName}/{id}",
         *        name = "«app.appName.formatForDB»_«name.formatForCode»_handleInlineRedirect",
         *        requirements = {"id" = "\d+"},
         *        defaults = {"commandName" = "", "id" = 0},
         *        methods = {"GET"}
         * )
         «ENDIF»
         *
         * @param string  $idPrefix    Prefix for inline window element identifier.
         * @param string  $commandName Name of action to be performed (create or edit).
         * @param integer $id          Id of created item (used for activating auto completion after closing the modal window).
         *
         * @return boolean Whether the inline redirect has been performed or not.
         */
    '''

    def private handleInlineRedirectBaseImpl(NamedObject it) '''
        «IF app.targets('1.3.5') || it instanceof Controller»
            $id = (int) $this->request->query->filter('id', 0, FILTER_VALIDATE_INT);
            $idPrefix = $this->request->query->filter('idPrefix', '', FILTER_SANITIZE_STRING);
            $commandName = $this->request->query->filter('commandName', '', FILTER_SANITIZE_STRING);
        «ENDIF»
        if (empty($idPrefix)) {
            return false;
        }

        $this->view->assign('itemId', $id)
                   ->assign('idPrefix', $idPrefix)
                   ->assign('commandName', $commandName)
                   ->assign('jcssConfig', JCSSUtil::getJSConfig());

        «var typeName = ''»
        «IF it instanceof Controller»
            «{typeName = it.formattedName; ''}»
        «ELSEIF it instanceof Entity»
            «{typeName = it.name.formatForCode; ''}»
        «ENDIF»
        «IF app.targets('1.3.5')»
            $this->view->display('«typeName»/inlineRedirectHandler.tpl');

            return true;
        «ELSE»
            return new PlainResponse($this->view->display('«typeName.toFirstUpper»/inlineRedirectHandler.tpl'));
        «ENDIF»
    '''

    def private configAction(Controller it, Boolean isBase) '''
        «configDocBlock(isBase)»
        public function config«IF !app.targets('1.3.5')»Action«ENDIF»()
        {
            «IF isBase»
                «configBaseImpl»
            «ELSE»
                return parent::configAction();
            «ENDIF»
        }
    '''

    def private configDocBlock(Controller it, Boolean isBase) '''
        /**
         * This method takes care of the application configuration.
         «IF !app.targets('1.3.5') && !isBase»
         *
         * @Route("/config",
         *        name = "«app.appName.formatForDB»_«formattedName»_config",
         *        methods = {"GET", "POST"}
         * )
         «ENDIF»
         *
         * @return string Output
         «IF !app.targets('1.3.5')»
         *
         * @throws AccessDeniedException Thrown if the user doesn't have required permissions
         «ENDIF»
         */
    '''

    def private configBaseImpl(Controller it) '''
        «IF app.targets('1.3.5')»
            $this->throwForbiddenUnless(SecurityUtil::checkPermission($this->name . '::', '::', ACCESS_ADMIN));
        «ELSE»
            if (!SecurityUtil::checkPermission($this->name . '::', '::', ACCESS_ADMIN)) {
                throw new AccessDeniedException();
            }
        «ENDIF»

        // Create new Form reference
        $view = FormUtil::newForm($this->name, $this);

        $templateName = '«IF app.targets('1.3.5')»«app.configController.formatForDB»«ELSE»«app.configController.formatForCodeCapital»«ENDIF»/config.tpl';

        // Execute form using supplied template and page event handler
        return «IF !app.targets('1.3.5')»new Response(«ENDIF»$view->execute($templateName, new «IF app.targets('1.3.5')»«app.appName»_Form_Handler_«app.configController.formatForDB.toFirstUpper»_Config«ELSE»ConfigHandler«ENDIF»())«IF !app.targets('1.3.5')»)«ENDIF»;
    '''

    def private controllerImpl(Controller it) '''
        «IF !app.targets('1.3.5')»
            namespace «app.appNamespace»\Controller;

            use «app.appNamespace»\Controller\Base\«name.formatForCodeCapital»Controller as Base«name.formatForCodeCapital»Controller;

        «ENDIF»
        /**
         * «name» controller class providing navigation and interaction functionality.
         */
        «IF app.targets('1.3.5')»
        class «app.appName»_Controller_«name.formatForCodeCapital» extends «app.appName»_Controller_Base_«name.formatForCodeCapital»
        «ELSE»
        class «name.formatForCodeCapital»Controller extends Base«name.formatForCodeCapital»Controller
        «ENDIF»
        {
            «IF !app.targets('1.3.5')»
                «/* not required as no routes are used here
                «val actionHelper = new ControllerAction(app)»
                «FOR action : actions»«actionHelper.generate(action, false)»«ENDFOR»*/»
                «IF hasActions('edit')»
                    «handleInlineRedirect(false)»

                «ENDIF»
                «IF app.needsConfig && isConfigController»
                    «configAction(false)»

                «ENDIF»
            «ENDIF»
            // feel free to add your own controller methods here
        }
    '''

    def private entityControllerImpl(Entity it) '''
        «IF !app.targets('1.3.5')»
            namespace «app.appNamespace»\Controller;

            use «app.appNamespace»\Controller\Base\«name.formatForCodeCapital»Controller as Base«name.formatForCodeCapital»Controller;

            use RuntimeException;
            use Symfony\Component\Security\Core\Exception\AccessDeniedException;
            «IF hasActions('display') || hasActions('edit') || hasActions('delete')»
                use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;
            «ENDIF»
            use Sensio\Bundle\FrameworkExtraBundle\Configuration\Route;
            use «app.appNamespace»\Entity\«name.formatForCodeCapital»Entity;

        «ENDIF»
        /**
         * «name.formatForDisplayCapital» controller class providing navigation and interaction functionality.
         */
        «IF app.targets('1.3.5')»
        class «app.appName»_Controller_«name.formatForCodeCapital» extends «app.appName»_Controller_Base_«name.formatForCodeCapital»
        «ELSE»
        class «name.formatForCodeCapital»Controller extends Base«name.formatForCodeCapital»Controller
        «ENDIF»
        {
            «IF !app.targets('1.3.5')»
                «val actionHelper = new ControllerAction(app)»
                «FOR action : app.getActionsOfAdminAndUserControllers»«actionHelper.generate(it, action, false)»«ENDFOR»
                «IF hasActions('view') && app.hasAdminController»

                    «handleSelectedObjects(false)»
                «ENDIF»
                «IF hasActions('edit')»

                    «handleInlineRedirect(false)»
                «ENDIF»

            «ENDIF»
            // feel free to add your own controller methods here
        }
    '''


    def private apiBaseImpl(Controller it) '''
        «val isUserController = (it instanceof UserController)»
        «val isAjaxController = (it instanceof AjaxController)»
        «IF !app.targets('1.3.5')»
            namespace «app.appNamespace»\Api\Base;

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

                «IF app.targets('1.3.5')»
                    $controllerHelper = new «app.appName»_Util_Controller($this->serviceManager);
                «ELSE»
                    $controllerHelper = $this->serviceManager->get('«app.appName.formatForDB».controller_helper');
                «ENDIF»
                $utilArgs = array('api' => '«it.formattedName»', 'action' => 'getlinks');
                $allowedObjectTypes = $controllerHelper->getObjectTypes('api', $utilArgs);

                «IF hasActions('view')»
                    «FOR entity : app.getAllEntities»
                        if (in_array('«entity.name.formatForCode»', $allowedObjectTypes)
                            && SecurityUtil::checkPermission($this->name . ':«entity.name.formatForCodeCapital»:', '::', ACCESS_«menuLinksPermissionLevel»)) {
                            «IF app.targets('1.3.5')»
                                $links[] = array('url' => ModUtil::url($this->name, '«formattedName»', 'view', array('ot' => '«entity.name.formatForCode»'«IF entity.tree != EntityTreeType.NONE», 'tpl' => 'tree'«ENDIF»)),
                            «ELSE»
                                $links[] = array('url' => $this->serviceManager->get('router')->generate('«app.appName.formatForDB»_«entity.name.formatForCode»_view', array('lct' => '«formattedName»'«IF entity.tree != EntityTreeType.NONE», 'tpl' => 'tree'«ENDIF»)),
                            «ENDIF»
                                             'text' => $this->__('«entity.nameMultiple.formatForDisplayCapital»'),
                                             'title' => $this->__('«entity.name.formatForDisplayCapital» list'));
                        }
                    «ENDFOR»
                «ENDIF»
                «IF app.needsConfig && isConfigController»
                    if (SecurityUtil::checkPermission($this->name . '::', '::', ACCESS_ADMIN)) {
                        «IF app.targets('1.3.5')»
                            $links[] = array('url' => ModUtil::url($this->name, '«app.configController.formatForDB»', 'config'),
                        «ELSE»
                            $links[] = array('url' => $this->serviceManager->get('router')->generate('«app.appName.formatForDB»_«app.configController.formatForDB»_config'),
                        «ENDIF»
                                         'text' => $this->__('Configuration'),
                                         'title' => $this->__('Manage settings for this application')«IF !app.targets('1.3.5')»,
                                         'icon' => 'wrench'«ENDIF»);
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
            AdminController case !container.getUserControllers.empty: '''
                    «val userController = container.getUserControllers.head»
                    if (SecurityUtil::checkPermission($this->name . '::', '::', ACCESS_READ)) {
                        $links[] = array('url' => ModUtil::url($this->name, '«userController.formattedName»', «userController.indexUrlDetails»),
                                         'text' => $this->__('Frontend'),
                                         'title' => $this->__('Switch to user area.'),
                                         «IF container.application.targets('1.3.5')»'class' => 'z-icon-es-home'«ELSE»'icon' => 'home'«ENDIF»);
                    }
                    '''
            UserController case !container.getAdminControllers.empty: '''
                    «val adminController = container.getAdminControllers.head»
                    if (SecurityUtil::checkPermission($this->name . '::', '::', ACCESS_ADMIN)) {
                        $links[] = array('url' => ModUtil::url($this->name, '«adminController.formattedName»', «adminController.indexUrlDetails»),
                                         'text' => $this->__('Backend'),
                                         'title' => $this->__('Switch to administration area.'),
                                         «IF container.application.targets('1.3.5')»'class' => 'z-icon-es-options'«ELSE»'icon' => 'wrench'«ENDIF»);
                    }
                    '''
        }
    }

    def private menuLinksPermissionLevel(Controller it) {
        switch it {
            AdminController case !container.getUserControllers.empty: 'ADMIN'
            default: 'READ'
        }
    }

    def private additionalApiMethods(Controller it) {
        switch it {
            UserController: if (container.application.targets('1.3.5')) new ShortUrlsLegacy(app).generate(it) else ''
            default: ''
        }
    }

    def private apiImpl(Controller it) '''
        «IF !app.targets('1.3.5')»
            namespace «app.appNamespace»\Api;

            use «app.appNamespace»\Api\Base\«name.formatForCodeCapital»Api as Base«name.formatForCodeCapital»Api;

        «ENDIF»
        /**
         * This is the «name» api helper class.
         */
        «IF app.targets('1.3.5')»
        class «app.appName»_Api_«name.formatForCodeCapital» extends «app.appName»_Api_Base_«name.formatForCodeCapital»
        «ELSE»
        class «name.formatForCodeCapital»Api extends Base«name.formatForCodeCapital»Api
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
