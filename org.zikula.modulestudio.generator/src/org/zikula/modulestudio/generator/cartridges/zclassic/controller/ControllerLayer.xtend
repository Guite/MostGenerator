package org.zikula.modulestudio.generator.cartridges.zclassic.controller

import de.guite.modulestudio.metamodel.Action
import de.guite.modulestudio.metamodel.AdminController
import de.guite.modulestudio.metamodel.AjaxController
import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Controller
import de.guite.modulestudio.metamodel.DisplayAction
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.EntityTreeType
import de.guite.modulestudio.metamodel.NamedObject
import de.guite.modulestudio.metamodel.UserController
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
import org.zikula.modulestudio.generator.extensions.CollectionUtils
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.GeneratorSettingsExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ControllerLayer {

    extension CollectionUtils = new CollectionUtils
    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension GeneratorSettingsExtensions = new GeneratorSettingsExtensions
    extension ModelExtensions = new ModelExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    FileHelper fh = new FileHelper
    Application app
    ControllerAction actionHelper

    /**
     * Entry point for the controller creation.
     */
    def void generate(Application it, IFileSystemAccess fsa) {
        this.app = it
        this.actionHelper = new ControllerAction(app)

        // controllers and apis
        controllers.forEach[generateControllerAndApi(fsa)]
        getAllEntities.forEach[generateController(fsa)]

        if (isLegacy) {
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
        app.generateClassPair(fsa, app.getAppSourceLibPath + 'Controller/' + name.formatForCodeCapital + (if (isLegacy) '' else 'Controller') + '.php',
            fh.phpFileContent(app, controllerBaseImpl), fh.phpFileContent(app, controllerImpl)
        )

        if (isLegacy) {
            println('Generating "' + formattedName + '" api classes')
            app.generateClassPair(fsa, app.getAppSourceLibPath + 'Api/' + name.formatForCodeCapital + '.php',
                fh.phpFileContent(app, apiBaseImpl), fh.phpFileContent(app, apiImpl)
            )
        } else {
            println('Generating link container class')
            app.generateClassPair(fsa, app.getAppSourceLibPath + 'Container/LinkContainer.php',
                fh.phpFileContent(app, linkContainerBaseImpl), fh.phpFileContent(app, linkContainerImpl)
            )
        }
    }

    /**
     * Creates controller class files for every Entity instance.
     */
    def private generateController(Entity it, IFileSystemAccess fsa) {
        println('Generating "' + name.formatForDisplay + '" controller classes')
        app.generateClassPair(fsa, app.getAppSourceLibPath + 'Controller/' + name.formatForCodeCapital + (if (isLegacy) '' else 'Controller') + '.php',
            fh.phpFileContent(app, entityControllerBaseImpl), fh.phpFileContent(app, entityControllerImpl)
        )
    }

    def private controllerBaseImpl(Controller it) '''
        «val isAjaxController = (it instanceof AjaxController)»
        «controllerBaseImports»
        /**
         * «name» controller class.
         */
        class «IF isLegacy»«app.appName»_Controller_Base_«name.formatForCodeCapital» extends Zikula_«IF !isAjaxController»AbstractController«ELSE»Controller_AbstractAjax«ENDIF»«ELSE»«name.formatForCodeCapital»Controller extends AbstractController«ENDIF»
        {
            «IF isAjaxController»

            «ELSEIF isLegacy»
                «val isUserController = (it instanceof UserController)»
                «new ControllerHelperFunctions().controllerPostInitialize(it, isUserController, '')»
            «ENDIF»

            «FOR action : actions»
                «actionHelper.generate(action, true)»

            «ENDFOR»
            «IF hasActions('edit')»

                «handleInlineRedirect(true)»
            «ENDIF»
            «IF app.needsConfig && isConfigController»

                «configAction(true)»
            «ENDIF»
            «IF isAjaxController»
                «new Ajax().additionalAjaxFunctionsBase(it, app)»
            «ENDIF»
        }
    '''

    def private entityControllerBaseImpl(Entity it) '''
        «entityControllerBaseImports»
        /**
         * «name.formatForDisplayCapital» controller base class.
         */
        class «IF isLegacy»«app.appName»_Controller_Base_«name.formatForCodeCapital» extends Zikula_AbstractController«ELSE»«name.formatForCodeCapital»Controller extends AbstractController«ENDIF»
        {
            «IF isLegacy»
                «new ControllerHelperFunctions().controllerPostInitialize(it, false, '')»

            «ENDIF»
            «FOR action : actions»
                «adminAndUserImpl(action, true)»
            «ENDFOR»
            «IF hasActions('view')»

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
        «IF !isLegacy»
            namespace «app.appNamespace»\Controller\Base;

            use Symfony\Component\HttpFoundation\Request;
            use Symfony\Component\Security\Core\Exception\AccessDeniedException;
            «IF hasActions('display') || hasActions('edit') || hasActions('delete')»
                use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;
            «ENDIF»
            «IF hasActions('index') || hasActions('view') || hasActions('delete') || (app.needsConfig && isConfigController)»
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
            «IF (hasActions('view') && isAdminController) || hasActions('index') || hasActions('delete')»
                use System;
            «ENDIF»
            use UserUtil;
            use ZLanguage;
            use Zikula\Core\Controller\AbstractController;
            «IF (hasActions('view') && isAdminController) || hasActions('delete')»
                use Zikula\Core\Hook\ProcessHook;
                use Zikula\Core\Hook\ValidationHook;
                use Zikula\Core\Hook\ValidationProviders;
            «ENDIF»
            use Zikula\Core\RouteUrl;
            «controllerBaseImportsResponse»

        «ENDIF»
    '''

    def private entityControllerBaseImports(Entity it) '''
        «IF !isLegacy»
            namespace «app.appNamespace»\Controller\Base;

            use «entityClassName('', false)»;
            use Symfony\Component\HttpFoundation\Request;
            use Symfony\Component\Security\Core\Exception\AccessDeniedException;
            «IF hasActions('display') || hasActions('edit') || hasActions('delete')»
                use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;
            «ENDIF»
            «IF hasActions('index') || hasActions('view') || hasActions('delete')»
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
            «IF (hasActions('view') && app.hasAdminController) || hasActions('index') || hasActions('delete')»
                use System;
            «ENDIF»
            use UserUtil;
            use ZLanguage;
            «IF hasActions('view')»
                use Zikula\Component\SortableColumns\Column;
                use Zikula\Component\SortableColumns\SortableColumns;
            «ENDIF»
            use Zikula\Core\Controller\AbstractController;
            «IF (hasActions('view') && app.hasAdminController) || hasActions('delete')»
                use Zikula\Core\Hook\ProcessHook;
                use Zikula\Core\Hook\ValidationHook;
                use Zikula\Core\Hook\ValidationProviders;
            «ENDIF»
            use Zikula\Core\ModUrl;
            use Zikula\Core\RouteUrl;
            «entityControllerBaseImportsResponse»
            use Zikula\Core\Theme\Annotation\Theme;

        «ENDIF»
    '''

    def private controllerBaseImportsResponse(Controller it) '''
        «IF it instanceof AjaxController»
            use Zikula\Core\Response\Ajax\AjaxResponse;
            use Zikula\Core\Response\Ajax\BadDataResponse;
            use Zikula\Core\Response\Ajax\FatalResponse;
            use Zikula\Core\Response\Ajax\NotFoundResponse;
            use Symfony\Component\HttpFoundation\JsonResponse;
        «ENDIF»
        use Zikula\Core\Response\PlainResponse;
    '''

    def private entityControllerBaseImportsResponse(Entity it) '''
        use Zikula\Core\Response\PlainResponse;
    '''

    def private handleSelectedObjects(Entity it, Boolean isBase) '''
        «handleSelectedObjectsDocBlock(isBase)»
        public function handleSelectedEntries«IF isLegacy»()«ELSE»Action(Request $request)«ENDIF»
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
         «IF !isLegacy && !isBase»
         *
         * @Route("/«nameMultiple.formatForCode»/handleSelectedEntries",
         *        methods = {"POST"}
         * )
         «ENDIF»
         *
         * @param string $action The action to be executed.
         * @param array  $items  Identifier list of the items to be processed.
         *
         * @return bool true on sucess, false on failure.
         «IF !isLegacy»
         *
         * @throws RuntimeException Thrown if executing the workflow action fails
         «ENDIF»
         */
    '''

    def private handleSelectedObjectsBaseImpl(Entity it) '''
        $this->checkCsrfToken();

        $objectType = '«name.formatForCode»';

        // Get parameters
        $action = $«IF isLegacy»this->«ENDIF»request->request->get('action', null);
        $items = $«IF isLegacy»this->«ENDIF»request->request->get('items', null);

        $action = strtolower($action);

        «IF isLegacy»
            $workflowHelper = new «app.appName»_Util_Workflow($this->serviceManager);
        «ELSE»
            $workflowHelper = $this->get('«app.appName.formatForDB».workflow_helper');
            $flashBag = $this->request->getSession()->getFlashBag();
            $logger = $this->get('logger');
        «ENDIF»

        // process each item
        foreach ($items as $itemid) {
            // check if item exists, and get record instance
            $selectionArgs = «IF isLegacy»array(«ELSE»[«ENDIF»
                'ot' => $objectType,
                'id' => $itemid,
                'useJoins' => false
            «IF isLegacy»)«ELSE»]«ENDIF»;
            $entity = ModUtil::apiFunc($this->name, 'selection', 'getEntity', $selectionArgs);

            $entity->initWorkflow();

            // check if $action can be applied to this entity (may depend on it's current workflow state)
            $allowedActions = $workflowHelper->getActionsForObject($entity);
            $actionIds = array_keys($allowedActions);
            if (!in_array($action, $actionIds)) {
                // action not allowed, skip this object
                continue;
            }
            «IF !skipHookSubscribers»

                $hookAreaPrefix = $entity->getHookAreaPrefix();

                // Let any hooks perform additional validation actions
                $hookType = $action == 'delete' ? 'validate_delete' : 'validate_edit';
                «IF isLegacy»
                    $hook = new Zikula_ValidationHook($hookAreaPrefix . '.' . $hookType, new Zikula_Hook_ValidationProviders());
                    $validators = $this->notifyHooks($hook)->getValidators();
                «ELSE»
                    $hook = new ValidationHook(new ValidationProviders());
                    $validators = $this->dispatchHooks($hookAreaPrefix . '.' . $hookType, $hook)->getValidators();
                «ENDIF»
                if ($validators->hasErrors()) {
                    continue;
                }
            «ENDIF»

            $success = false;
            try {
                if (!$entity->validate()) {
                    continue;
                }
                // execute the workflow action
                $success = $workflowHelper->executeAction($entity, $action);
            } catch(\Exception $e) {
                «IF isLegacy»
                    LogUtil::registerError($this->__f('Sorry, but an unknown error occured during the %s action. Please apply the changes again!', array($action)));
                «ELSE»
                    $flashBag->add(\Zikula_Session::MESSAGE_ERROR, $this->__f('Sorry, but an unknown error occured during the %s action. Please apply the changes again!', [$action]));
                    $logger->error('{app}: User {user} tried to execute the {action} workflow action for the {entity} with id {id}, but failed. Error details: {errorMessage}.', ['app' => '«app.appName»', 'user' => UserUtil::getVar('uname'), 'action' => $action, 'entity' => '«name.formatForDisplay»', 'id' => $itemid, 'errorMessage' => $e->getMessage()]);
                «ENDIF»
            }

            if (!$success) {
                continue;
            }

            if ($action == 'delete') {
                «IF isLegacy»
                    LogUtil::registerStatus($this->__('Done! Item deleted.'));
                «ELSE»
                    $flashBag->add(\Zikula_Session::MESSAGE_STATUS, $this->__('Done! Item deleted.'));
                    $logger->notice('{app}: User {user} deleted the {entity} with id {id}.', ['app' => '«app.appName»', 'user' => UserUtil::getVar('uname'), 'entity' => '«name.formatForDisplay»', 'id' => $itemid]);
                «ENDIF»
            } else {
                «IF isLegacy»
                    LogUtil::registerStatus($this->__('Done! Item updated.'));
                «ELSE»
                    $flashBag->add(\Zikula_Session::MESSAGE_STATUS, $this->__('Done! Item updated.'));
                    $logger->notice('{app}: User {user} executed the {action} workflow action for the {entity} with id {id}.', ['app' => '«app.appName»', 'user' => UserUtil::getVar('uname'), 'action' => $action, 'entity' => '«name.formatForDisplay»', 'id' => $itemid]);
                «ENDIF»
            }
            «IF !skipHookSubscribers»

                // Let any hooks know that we have updated or deleted an item
                $hookType = $action == 'delete' ? 'process_delete' : 'process_edit';
                $url = null;
                if ($action != 'delete') {
                    $urlArgs = $entity->createUrlArgs();
                    «IF isLegacy»
                        $url = new Zikula_ModUrl($this->name, '«name.formatForCode»', 'display', ZLanguage::getLanguageCode(), $urlArgs);
                    «ELSE»
                        $url = new RouteUrl('«app.appName.formatForDB»_«name.formatForCode»_display', $urlArgs);
                    «ENDIF»
                }
                «IF isLegacy»
                    $hook = new Zikula_ProcessHook($hookAreaPrefix . '.' . $hookType, $entity->createCompositeIdentifier(), $url);
                    $this->notifyHooks($hook);
                «ELSE»
                    $hook = new ProcessHook($entity->createCompositeIdentifier(), $url);
                    $this->dispatchHooks($hookAreaPrefix . '.' . $hookType, $hook);
                «ENDIF»
            «ENDIF»
            «IF isLegacy»

                // An item was updated or deleted, so we clear all cached pages for this item.
                $cacheArgs = array('ot' => $objectType, 'item' => $entity);
                ModUtil::apiFunc($this->name, 'cache', 'clearItemCache', $cacheArgs);
            «ENDIF»
        }

        «IF isLegacy»
            // clear view cache to reflect our changes
            $this->view->clear_cache();

            $redirectUrl = ModUtil::url($this->name, 'admin', 'main', array('ot' => '«name.formatForCode»'));

            return $this->redirect($redirectUrl);
        «ELSE»
            return $this->redirectToRoute('«app.appName.formatForDB»_«name.formatForDB»_adminindex');
        «ENDIF»
    '''

    def private handleInlineRedirect(NamedObject it, Boolean isBase) '''
        «handleInlineRedirectDocBlock(isBase)»
        public function handleInlineRedirect«IF isLegacy»()«ELSE»Action($idPrefix, $commandName, $id = 0)«ENDIF»
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
         «IF it instanceof Entity && !isLegacy && !isBase»
         *
         * @Route("/«name.formatForCode»/handleInlineRedirect/{idPrefix}/{commandName}/{id}",
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
        «IF isLegacy || it instanceof Controller»
            $id = (int) $this->request->query->filter('id', 0, FILTER_VALIDATE_INT);
            $idPrefix = $this->request->query->filter('idPrefix', '', FILTER_SANITIZE_STRING);
            $commandName = $this->request->query->filter('commandName', '', FILTER_SANITIZE_STRING);
        «ENDIF»
        if (empty($idPrefix)) {
            return false;
        }

        «IF isLegacy»
            $this->view->assign('itemId', $id)
                       ->assign('idPrefix', $idPrefix)
                       ->assign('commandName', $commandName)
                       ->assign('jcssConfig', JCSSUtil::getJSConfig());
        «ELSE»
            $templateParameters = [
                'itemId' => $id,
                'idPrefix' => $idPrefix,
                'commandName' => $commandName,
                'jcssConfig' => JCSSUtil::getJSConfig()
            ];
        «ENDIF»

        «val typeName = if (it instanceof Controller) it.formattedName else if (it instanceof Entity) it.name.formatForCode»
        «IF isLegacy»
            $this->view->display('«typeName»/inlineRedirectHandler.tpl');

            return true;
        «ELSE»
            return new PlainResponse($this->get('twig')->render('@«app.appName»/«typeName.toFirstUpper»/inlineRedirectHandler.html.twig', $templateParameters));
        «ENDIF»
    '''

    def private configAction(Controller it, Boolean isBase) '''
        «configDocBlock(isBase)»
        public function config«IF !isLegacy»Action«ENDIF»(«IF !isLegacy»Request $request«ENDIF»)
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
         «IF !isLegacy && !isBase»
         *
         * @Route("/config",
         *        methods = {"GET", "POST"}
         * )
         «ENDIF»
         *
         * @return string Output
         «IF !isLegacy»
         *
         * @throws AccessDeniedException Thrown if the user doesn't have required permissions
         «ENDIF»
         */
    '''

    def private configBaseImpl(Controller it) '''
        «IF isLegacy»
            $this->throwForbiddenUnless(SecurityUtil::checkPermission($this->name . '::', '::', ACCESS_ADMIN));
        «ELSE»
            if (!$this->hasPermission($this->name . '::', '::', ACCESS_ADMIN)) {
                throw new AccessDeniedException();
            }
        «ENDIF»

        «IF isLegacy»
            // Create new Form reference
            $view = \FormUtil::newForm($this->name, $this);

            $templateName = '«app.configController.formatForDB»/config.tpl';

            // Execute form using supplied template and page event handler
            return $view->execute($templateName, new «app.appName»_Form_Handler_«app.configController.formatForDB.toFirstUpper»_Config());
        «ELSE»
            $form = $this->createForm('«app.appNamespace»\Form\AppSettingsType');

            if ($form->handleRequest($request)->isValid()) {
                $this->setVars($form->getData());

                if ($form->get('save')->isClicked()) {
                    $this->addFlash(\Zikula_Session::MESSAGE_STATUS, $this->__('Done! Module configuration updated.'));
                    $this->get('logger')->notice('{app}: User {user} updated the configuration.', ['app' => '«app.appName»', 'user' => \UserUtil::getVar('uname')]);
                } elseif ($form->get('cancel')->isClicked()) {
                    $this->addFlash(\Zikula_Session::MESSAGE_STATUS, $this->__('Operation cancelled.'));
            	}

                // redirect to config page again (to show with GET request)
                return $this->redirectToRoute('«app.appName.formatForDB»_«app.configController.formatForDB»_config');
            }

            $templateParameters = [
                'form' => $form->createView()
            ];

            // render the config form
            return $this->render('@«app.appName»/«app.configController.formatForCodeCapital»/config.html.twig', $templateParameters);
        «ENDIF»
    '''

    def private controllerImpl(Controller it) '''
        «IF !isLegacy»
            namespace «app.appNamespace»\Controller;

            use «app.appNamespace»\Controller\Base\«name.formatForCodeCapital»Controller as Base«name.formatForCodeCapital»Controller;

            «IF it instanceof AjaxController»
                use Sensio\Bundle\FrameworkExtraBundle\Configuration\Method;
            «ENDIF»
            use Sensio\Bundle\FrameworkExtraBundle\Configuration\Route;
            use Symfony\Component\HttpFoundation\Request;

        «ENDIF»
        /**
         * «name» controller class providing navigation and interaction functionality.
        «IF !isLegacy && it instanceof AjaxController»
         «' '»*
         «' '»* @Route("/ajax")
        «ENDIF»
         */
        «IF isLegacy»
        class «app.appName»_Controller_«name.formatForCodeCapital» extends «app.appName»_Controller_Base_«name.formatForCodeCapital»
        «ELSE»
        class «name.formatForCodeCapital»Controller extends Base«name.formatForCodeCapital»Controller
        «ENDIF»
        {
            «IF !isLegacy»
                «FOR action : actions»
                    «actionHelper.generate(action, false)»

                «ENDFOR»
                «IF hasActions('edit')»

                    «handleInlineRedirect(false)»
                «ENDIF»
                «IF app.needsConfig && isConfigController»

                    «configAction(false)»
                «ENDIF»
                «IF it instanceof AjaxController»
                    «new Ajax().additionalAjaxFunctions(it, app)»
                «ENDIF»
            «ENDIF»
            // feel free to add your own controller methods here
        }
    '''

    def private entityControllerImpl(Entity it) '''
        «IF !isLegacy»
            namespace «app.appNamespace»\Controller;

            use «app.appNamespace»\Controller\Base\«name.formatForCodeCapital»Controller as Base«name.formatForCodeCapital»Controller;

            use RuntimeException;
            use Symfony\Component\HttpFoundation\Request;
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
        «IF isLegacy»
        class «app.appName»_Controller_«name.formatForCodeCapital» extends «app.appName»_Controller_Base_«name.formatForCodeCapital»
        «ELSE»
        class «name.formatForCodeCapital»Controller extends Base«name.formatForCodeCapital»Controller
        «ENDIF»
        {
            «IF !isLegacy»
                «IF hasSluggableFields»«/* put display method at the end to avoid conflict between delete/edit and display for slugs */»
                    «FOR action : actions.exclude(DisplayAction)»
                        «adminAndUserImpl(action as Action, false)»
                    «ENDFOR»
                    «FOR action : actions.filter(DisplayAction)»
                        «adminAndUserImpl(action, false)»
                    «ENDFOR»
                «ELSE»
                    «FOR action : actions»
                        «adminAndUserImpl(action, false)»
                    «ENDFOR»
                «ENDIF»
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

    def private adminAndUserImpl(Entity it, Action action, Boolean isBase) '''
        «IF !isLegacy»
            «actionHelper.generate(it, action, isBase, true)»

        «ENDIF»
        «actionHelper.generate(it, action, isBase, false)»
    '''

    // 1.3.x only
    def private apiBaseImpl(Controller it) '''
        «val isAjaxController = (it instanceof AjaxController)»
        /**
         * This is the «name» api helper class.
         */
        class «app.appName»_Api_Base_«name.formatForCodeCapital» extends Zikula_AbstractApi
        {
            «IF !isAjaxController»
            /**
             * Returns available «name.formatForDB» panel links.
             *
             * @return array Array of «name.formatForDB» links.
             */
            public function getLinks()
            {
                $links = array();

                $controllerHelper = new «app.appName»_Util_Controller($this->serviceManager);
                $utilArgs = array('api' => '«it.formattedName»', 'action' => 'getLinks');
                $allowedObjectTypes = $controllerHelper->getObjectTypes('api', $utilArgs);

                $currentType = $this->request->query->filter('type', '«app.getLeadingEntity.name.formatForCode»', FILTER_SANITIZE_STRING);
                $currentLegacyType = $this->request->query->filter('lct', 'user', FILTER_SANITIZE_STRING);
                $permLevel = in_array('admin', array($currentType, $currentLegacyType)) ? ACCESS_ADMIN : ACCESS_READ;

                «getLinksBody»

                return $links;
            }
            «ENDIF»
            «additionalApiMethods»
        }
    '''

    // 1.4+ only
    def private linkContainerBaseImpl(Controller it) '''
        namespace «app.appNamespace»\Container\Base;

        use ModUtil;
        use ServiceUtil;
        use Symfony\Component\Routing\RouterInterface;
        use Zikula\Common\Translator\Translator;
        use Zikula\Core\LinkContainer\LinkContainerInterface;

        /**
         * This is the link container service implementation class.
         */
        class LinkContainer implements LinkContainerInterface
        {
            /**
             * @var Translator
             */
            protected $translator;

            /**
             * @var RouterInterface
             */
            protected $router;

            /**
             * Constructor.
             * Initialises member vars.
             *
             * @param Translator      $translator Translator service instance.
             * @param Routerinterface $router     The router service.
             */
            public function __construct($translator, RouterInterface $router)
            {
                $this->translator = $translator;
                $this->router = $router;
            }

            /**
             * Returns available header links.
             *
             * @return array Array of header links.
             */
            public function getLinks($type = LinkContainerInterface::TYPE_ADMIN)
            {
                $links = [];
                $serviceManager = ServiceUtil::getManager();
                $request = $serviceManager->get('request_stack')->getCurrentRequest();

                $controllerHelper = $serviceManager->get('«app.appName.formatForDB».controller_helper');
                $utilArgs = ['api' => '«it.formattedName»', 'action' => 'getLinks'];
                $allowedObjectTypes = $controllerHelper->getObjectTypes('api', $utilArgs);
        
                $permLevel = LinkContainerInterface::TYPE_ADMIN == $type ? ACCESS_ADMIN : ACCESS_READ;

                $permissionHelper = $serviceManager->get('zikula_permissions_module.api.permission');

                «/* legacy, see #715 */»
                «var linkControllers = application.controllers.filter(AdminController) + application.controllers.filter(UserController)»
                «FOR linkController : linkControllers»
                    if ('«linkController.name.formatForCode»' == $type) {
                        «getLinksBody(linkController)»
                    }
                «ENDFOR»

                return $links;
            }

            public function getBundleName()
            {
                return '«app.appName»';
            }
        }
    '''

    def private getLinksBody(Controller it) '''
        «menuLinksBetweenControllers»

        «IF it instanceof AdminController || it instanceof UserController»
            «FOR entity : app.getAllEntities.filter[hasActions('view')]»
                «entity.menuLinkToViewAction(it)»
            «ENDFOR»
            «IF app.needsConfig && isConfigController»
                if («IF isLegacy»SecurityUtil::check«ELSE»$permissionHelper->has«ENDIF»Permission(«IF isLegacy»$this->name«ELSE»$this->getBundleName()«ENDIF» . '::', '::', ACCESS_ADMIN)) {
                    «IF isLegacy»
                        $links[] = array(
                            'url' => ModUtil::url($this->name, '«app.configController.formatForDB»', 'config'),
                    «ELSE»
                        $links[] = [
                            'url' => $this->router->generate('«app.appName.formatForDB»_«app.configController.formatForDB»_config'),
                    «ENDIF»
                         'text' => $this->«IF !isLegacy»translator->«ENDIF»__('Configuration'),
                         'title' => $this->«IF !isLegacy»translator->«ENDIF»__('Manage settings for this application')«IF !isLegacy»,
                         'icon' => 'wrench'«ENDIF»
                     «IF isLegacy»)«ELSE»]«ENDIF»;
                }
            «ENDIF»
        «ENDIF»
    '''

    def private menuLinkToViewAction(Entity it, Controller controller) '''
        if (in_array('«name.formatForCode»', $allowedObjectTypes)
            && «IF isLegacy»SecurityUtil::check«ELSE»$permissionHelper->has«ENDIF»Permission(«IF isLegacy»$this->name«ELSE»$this->getBundleName()«ENDIF» . ':«name.formatForCodeCapital»:', '::', $permLevel)) {
            «IF isLegacy»
                $links[] = array(
                    'url' => ModUtil::url($this->name, '«controller.formattedName»', 'view', array('ot' => '«name.formatForCode»'«IF tree != EntityTreeType.NONE», 'tpl' => 'tree'«ENDIF»)),
            «ELSE»
                $links[] = [
                    'url' => $this->router->generate('«app.appName.formatForDB»_«name.formatForDB»_«IF controller instanceof AdminController»admin«ENDIF»view'«IF tree != EntityTreeType.NONE», array('tpl' => 'tree')«ENDIF»),
            «ENDIF»
                 'text' => $this->«IF !isLegacy»translator->«ENDIF»__('«nameMultiple.formatForDisplayCapital»'),
                 'title' => $this->«IF !isLegacy»translator->«ENDIF»__('«name.formatForDisplayCapital» list')
             «IF isLegacy»)«ELSE»]«ENDIF»;
        }
    '''

    def private menuLinksBetweenControllers(Controller it) {
        switch it {
            AdminController case !application.getAllUserControllers.empty: '''
                    «val userController = application.getAllUserControllers.head»
                    if («IF isLegacy»SecurityUtil::check«ELSE»$permissionHelper->has«ENDIF»Permission(«IF isLegacy»$this->name«ELSE»$this->getBundleName()«ENDIF» . '::', '::', ACCESS_READ)) {
                        «IF isLegacy»
                            $links[] = array(
                                'url' => ModUtil::url($this->name, '«userController.formattedName»', «userController.indexUrlDetails13»),
                        «ELSE»
                            $links[] = [
                                'url' => $this->router->generate('«app.appName.formatForDB»_«userController.formattedName»_«userController.indexUrlDetails14»),«/* end quote missing here on purpose */»
                        «ENDIF»
                             'text' => $this->«IF !isLegacy»translator->«ENDIF»__('Frontend'),
                             'title' => $this->«IF !isLegacy»translator->«ENDIF»__('Switch to user area.'),
                             «IF isLegacy»'class' => 'z-icon-es-home'«ELSE»'icon' => 'home'«ENDIF»
                         «IF isLegacy»)«ELSE»]«ENDIF»;
                    }
                    '''
            UserController case !application.getAllAdminControllers.empty: '''
                    «val adminController = application.getAllAdminControllers.head»
                    if («IF isLegacy»SecurityUtil::check«ELSE»$permissionHelper->has«ENDIF»Permission(«IF isLegacy»$this->name«ELSE»$this->getBundleName()«ENDIF» . '::', '::', ACCESS_ADMIN)) {
                        «IF isLegacy»
                            $links[] = array(
                                'url' => ModUtil::url($this->name, '«adminController.formattedName»', «adminController.indexUrlDetails13»),
                        «ELSE»
                            $links[] = [
                                'url' => $this->router->generate('«app.appName.formatForDB»_«adminController.formattedName»_«adminController.indexUrlDetails14»),«/* end quote missing here on purpose */»
                        «ENDIF»
                             'text' => $this->«IF !isLegacy»translator->«ENDIF»__('Backend'),
                             'title' => $this->«IF !isLegacy»translator->«ENDIF»__('Switch to administration area.'),
                             «IF isLegacy»'class' => 'z-icon-es-options'«ELSE»'icon' => 'wrench'«ENDIF»
                         «IF isLegacy»)«ELSE»]«ENDIF»;
                    }
                    '''
        }
    }

    // 1.3.x only
    def private additionalApiMethods(Controller it) {
        switch it {
            UserController: if (isLegacy) new ShortUrlsLegacy(app).generate(it) else ''
            default: ''
        }
    }

    // 1.3.x only
    def private apiImpl(Controller it) '''
        /**
         * This is the «name» api helper class.
         */
        class «app.appName»_Api_«name.formatForCodeCapital» extends «app.appName»_Api_Base_«name.formatForCodeCapital»
        {
            // feel free to add own api methods here
        }
    '''

    // 1.4+ only
    def private linkContainerImpl(Controller it) '''
        namespace «app.appNamespace»\Container;

        use «app.appNamespace»\Container\Base\LinkContainer as BaseLinkContainer;

        /**
         * This is the link container service implementation class.
         */
        class LinkContainer extends BaseLinkContainer
        {
            // feel free to add own extensions here
        }
    '''

    def private indexUrlDetails14(Controller it) {
        if (hasActions('index')) 'index\''
        else if (hasActions('view')) 'view\', [\'ot\' => \'' + application.getLeadingEntity.name.formatForCode + '\']'
        else if (application.needsConfig && isConfigController) 'config\''
        else 'hooks\''
    }

    def private indexUrlDetails13(Controller it) {
        if (hasActions('index')) '\'main\''
        else if (hasActions('view')) '\'view\', array(\'ot\' => \'' + application.getLeadingEntity.name.formatForCode + '\')'
        else if (application.needsConfig && isConfigController) '\'config\''
        else '\'hooks\''
    }

    def private isLegacy() {
        app.targets('1.3.x')
    }
}
