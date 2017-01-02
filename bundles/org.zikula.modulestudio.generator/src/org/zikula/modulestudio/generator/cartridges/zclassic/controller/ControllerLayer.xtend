package org.zikula.modulestudio.generator.cartridges.zclassic.controller

import de.guite.modulestudio.metamodel.Action
import de.guite.modulestudio.metamodel.AdminController
import de.guite.modulestudio.metamodel.AjaxController
import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Controller
import de.guite.modulestudio.metamodel.DisplayAction
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.ModuleStudioFactory
import de.guite.modulestudio.metamodel.NamedObject
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.additions.Ajax
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.additions.ExternalController
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.additions.Routing
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.additions.Scribite
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.formtype.QuickNavigation
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
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ControllerLayer {

    extension CollectionUtils = new CollectionUtils
    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension GeneratorSettingsExtensions = new GeneratorSettingsExtensions
    extension ModelExtensions = new ModelExtensions
    extension ModelJoinExtensions = new ModelJoinExtensions
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

        if (needsConfig) {
            val factory = ModuleStudioFactory.eINSTANCE
            val additionalConfigController = factory.createCustomController => [
                name = 'config'
            ]
            additionalConfigController.actions += factory.createCustomAction => [
                name = 'config'
            ]
            controllers += additionalConfigController
        }

        // controllers and apis
        controllers.forEach[generateControllerAndApi(fsa)]
        getAllEntities.forEach[generateController(fsa)]

        new Routing().generate(it, fsa)
        if (hasViewActions) {
            new QuickNavigation().generate(it, fsa)
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
        app.generateClassPair(fsa, app.getAppSourceLibPath + 'Controller/' + name.formatForCodeCapital + 'Controller.php',
            fh.phpFileContent(app, controllerBaseImpl), fh.phpFileContent(app, controllerImpl)
        )

        var linkContainer = new LinkContainer
        linkContainer.generate(it, fsa)
    }

    /**
     * Creates controller class files for every Entity instance.
     */
    def private generateController(Entity it, IFileSystemAccess fsa) {
        println('Generating "' + name.formatForDisplay + '" controller classes')
        app.generateClassPair(fsa, app.getAppSourceLibPath + 'Controller/' + name.formatForCodeCapital + 'Controller.php',
            fh.phpFileContent(app, entityControllerBaseImpl), fh.phpFileContent(app, entityControllerImpl)
        )
    }

    def private controllerBaseImpl(Controller it) '''
        «val isAjaxController = (it instanceof AjaxController)»
        «controllerBaseImports»
        /**
         * «name» controller class.
         */
        abstract class Abstract«name.formatForCodeCapital»Controller extends AbstractController
        {
            «FOR action : actions»
                «IF app.needsConfig && isConfigController && action.name.formatForCode == 'config'»
                    «configAction(true)»
                «ELSE»
                    «actionHelper.generate(action, true)»
                «ENDIF»

            «ENDFOR»
            «IF hasActions('edit') && app.needsAutoCompletion»

                «handleInlineRedirect(true)»
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
        abstract class Abstract«name.formatForCodeCapital»Controller extends AbstractController
        {
            «FOR action : actions»
                «adminAndUserImpl(action, true)»
            «ENDFOR»
            «IF hasActions('view')»

                «handleSelectedObjects(true, true)»
                «handleSelectedObjects(true, false)»
            «ENDIF»
            «IF hasActions('edit') && app.needsAutoCompletion»

                «handleInlineRedirect(true)»
            «ENDIF»
        }
    '''

    def private controllerBaseImports(Controller it) '''
        «val isAdminController = (it instanceof AdminController)»
        «val isAjaxController = (it instanceof AjaxController)»
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
        «IF hasActions('edit') && app.needsAutoCompletion»
            use JCSSUtil;
        «ENDIF»
        use ModUtil;
        use RuntimeException;
        «IF (hasActions('view') && isAdminController) || hasActions('index') || hasActions('delete')»
            use System;
        «ENDIF»
        use Zikula\Core\Controller\AbstractController;
        use Zikula\Core\RouteUrl;
        «controllerBaseImportsResponse»
        «IF app.hasCategorisableEntities»
            use «app.appNamespace»\Helper\FeatureActivationHelper;
        «ENDIF»

    '''

    def private entityControllerBaseImports(Entity it) '''
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
        «IF hasActions('edit') && app.needsAutoCompletion»
            use JCSSUtil;
        «ENDIF»
        use ModUtil;
        use RuntimeException;
        «IF (hasActions('view') && app.hasAdminController) || hasActions('index') || hasActions('delete')»
            use System;
        «ENDIF»
        «IF hasActions('view')»
            use Zikula\Component\SortableColumns\Column;
            use Zikula\Component\SortableColumns\SortableColumns;
        «ENDIF»
        use Zikula\Core\Controller\AbstractController;
        «IF !skipHookSubscribers»
            use Zikula\Core\RouteUrl;
        «ENDIF»
        «entityControllerBaseImportsResponse»
        «IF app.hasCategorisableEntities»
            use «app.appNamespace»\Helper\FeatureActivationHelper;
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

    def private handleSelectedObjects(Entity it, Boolean isBase, Boolean isAdmin) '''
        «handleSelectedObjectsDocBlock(isBase)»
        public function «IF isAdmin»adminH«ELSE»h«ENDIF»andleSelectedEntriesAction(Request $request)
        {
            «IF isBase»
                return $this->handleSelectedEntriesActionInternal($request, «isAdmin.displayBool»);
            «ELSE»
                return parent::«IF isAdmin»adminH«ELSE»h«ENDIF»andleSelectedEntriesAction($request);
            «ENDIF»
        }
        «IF isBase && !isAdmin»

            /**
             * This method includes the common implementation code for adminHandleSelectedEntriesAction() and handleSelectedEntriesAction().
             */
            protected function handleSelectedEntriesActionInternal(Request $request, $isAdmin = false)
            {
                «handleSelectedObjectsBaseImpl»
            }
        «ENDIF»
    '''

    def private handleSelectedObjectsDocBlock(Entity it, Boolean isBase) '''
        /**
         * Process status changes for multiple items.
         *
         * This function processes the items selected in the admin view page.
         * Multiple items may have their state changed or be deleted.
         «IF !isBase»
         *
         * @Route("/«nameMultiple.formatForCode»/handleSelectedEntries",
         *        methods = {"POST"}
         * )
         «ENDIF»
         *
         * @param Request $request Current request instance
         *
         * @return bool true on sucess, false on failure
         *
         * @throws RuntimeException Thrown if executing the workflow action fails
         */
    '''

    def private handleSelectedObjectsBaseImpl(Entity it) '''
        $objectType = '«name.formatForCode»';

        // Get parameters
        $action = $request->request->get('action', null);
        $items = $request->request->get('items', null);

        $action = strtolower($action);

        $workflowHelper = $this->get('«app.appService».workflow_helper');
        «IF !skipHookSubscribers»
            $hookHelper = $this->get('«app.appService».hook_helper');
        «ENDIF»
        $logger = $this->get('logger');
        $userName = $this->get('zikula_users_module.current_user')->get('uname');

        // process each item
        foreach ($items as $itemid) {
            // check if item exists, and get record instance
            $selectionHelper = $this->get('«app.appService».selection_helper');
            $entity = $selectionHelper->getEntity($objectType, $itemid«IF app.hasSluggable», ''«ENDIF», false);

            $entity->initWorkflow();

            // check if $action can be applied to this entity (may depend on it's current workflow state)
            $allowedActions = $workflowHelper->getActionsForObject($entity);
            $actionIds = array_keys($allowedActions);
            if (!in_array($action, $actionIds)) {
                // action not allowed, skip this object
                continue;
            }

            «IF !skipHookSubscribers»
                // Let any hooks perform additional validation actions
                $hookType = $action == 'delete' ? 'validate_delete' : 'validate_edit';
                $validationHooksPassed = $hookHelper->callValidationHooks($entity, $hookType);
                if (!$validationHooksPassed) {
                    continue;
                }

            «ENDIF»
            $success = false;
            try {
                if ($action != 'delete' && !$entity->validate()) {
                    continue;
                }
                // execute the workflow action
                $success = $workflowHelper->executeAction($entity, $action);
            } catch(\Exception $e) {
                $this->addFlash('error', $this->__f('Sorry, but an error occured during the %s action.', ['%s' => $action]) . '  ' . $e->getMessage());
                $logger->error('{app}: User {user} tried to execute the {action} workflow action for the {entity} with id {id}, but failed. Error details: {errorMessage}.', ['app' => '«app.appName»', 'user' => $userName, 'action' => $action, 'entity' => '«name.formatForDisplay»', 'id' => $itemid, 'errorMessage' => $e->getMessage()]);
            }

            if (!$success) {
                continue;
            }

            if ($action == 'delete') {
                $this->addFlash('status', $this->__('Done! Item deleted.'));
                $logger->notice('{app}: User {user} deleted the {entity} with id {id}.', ['app' => '«app.appName»', 'user' => $userName, 'entity' => '«name.formatForDisplay»', 'id' => $itemid]);
            } else {
                $this->addFlash('status', $this->__('Done! Item updated.'));
                $logger->notice('{app}: User {user} executed the {action} workflow action for the {entity} with id {id}.', ['app' => '«app.appName»', 'user' => $userName, 'action' => $action, 'entity' => '«name.formatForDisplay»', 'id' => $itemid]);
            }
            «IF !skipHookSubscribers»

                // Let any hooks know that we have updated or deleted an item
                $hookType = $action == 'delete' ? 'process_delete' : 'process_edit';
                $url = null;
                if ($action != 'delete') {
                    $urlArgs = $entity->createUrlArgs();
                    $urlArgs['_locale'] = $request->getLocale();
                    $url = new RouteUrl('«app.appName.formatForDB»_«name.formatForCode»_' . /*($isAdmin ? 'admin' : '') . */'display', $urlArgs);
                }
                $hookHelper->callProcessHooks($entity, $hookType, $url);
            «ENDIF»
        }

        return $this->redirectToRoute('«app.appName.formatForDB»_«name.formatForDB»_' . ($isAdmin ? 'admin' : '') . 'index');
    '''

    def private handleInlineRedirect(NamedObject it, Boolean isBase) '''
        «handleInlineRedirectDocBlock(isBase)»
        public function handleInlineRedirectAction($idPrefix, $commandName, $id = 0)
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
         «IF it instanceof Entity && !isBase»
         *
         * @Route("/«name.formatForCode»/handleInlineRedirect/{idPrefix}/{commandName}/{id}",
         *        requirements = {"id" = "\d+"},
         *        defaults = {"commandName" = "", "id" = 0},
         *        methods = {"GET"}
         * )
         «ENDIF»
         *
         * @param string  $idPrefix    Prefix for inline window element identifier
         * @param string  $commandName Name of action to be performed (create or edit)
         * @param integer $id          Id of created item (used for activating auto completion after closing the modal window)
         *
         * @return boolean Whether the inline redirect has been performed or not
         */
    '''

    def private handleInlineRedirectBaseImpl(NamedObject it) '''
        «IF it instanceof Controller»
            $id = (int) $this->request->query->filter('id', 0, FILTER_VALIDATE_INT);
            $idPrefix = $this->request->query->filter('idPrefix', '', FILTER_SANITIZE_STRING);
            $commandName = $this->request->query->filter('commandName', '', FILTER_SANITIZE_STRING);
        «ENDIF»
        if (empty($idPrefix)) {
            return false;
        }

        $templateParameters = [
            'itemId' => $id,
            'idPrefix' => $idPrefix,
            'commandName' => $commandName,
            'jcssConfig' => JCSSUtil::getJSConfig()
        ];

        «val typeName = if (it instanceof Controller) it.formattedName else if (it instanceof Entity) it.name.formatForCode»
        return new PlainResponse($this->get('twig')->render('@«app.appName»/«typeName.toFirstUpper»/inlineRedirectHandler.html.twig', $templateParameters));
    '''

    def private configAction(Controller it, Boolean isBase) '''
        «configDocBlock(isBase)»
        public function configAction(Request $request)
        {
            «IF isBase»
                «configBaseImpl»
            «ELSE»
                return parent::configAction($request);
            «ENDIF»
        }
    '''

    def private configDocBlock(Controller it, Boolean isBase) '''
        /**
         * This method takes care of the application configuration.
         «IF !isBase»
         *
         * @Route("/config",
         *        methods = {"GET", "POST"}
         * )
         * @Theme("admin")
         «ENDIF»
         *
         * @param Request $request Current request instance
         *
         * @return string Output
         *
         * @throws AccessDeniedException Thrown if the user doesn't have required permissions
         */
    '''

    def private configBaseImpl(Controller it) '''
        if (!$this->hasPermission($this->name . '::', '::', ACCESS_ADMIN)) {
            throw new AccessDeniedException();
        }

        $form = $this->createForm('«app.appNamespace»\Form\AppSettingsType');

        if ($form->handleRequest($request)->isValid()) {
            if ($form->get('save')->isClicked()) {
                «IF app.hasUserGroupSelectors»
                    $formData = $form->getData();
                    foreach (['«app.getUserGroupSelectors.map[name.formatForCode].join('\', \'')»'] as $groupFieldName) {
                        $formData[$groupFieldName] = is_object($formData[$groupFieldName]) ? $formData[$groupFieldName]->getGid() : $formData[$groupFieldName];
                    }
                    $this->setVars($formData);
                «ELSE»
                    $this->setVars($form->getData());
                «ENDIF»

                $this->addFlash('status', $this->__('Done! Module configuration updated.'));
                $userName = $this->get('zikula_users_module.current_user')->get('uname');
                $this->get('logger')->notice('{app}: User {user} updated the configuration.', ['app' => '«app.appName»', 'user' => $userName]);
            } elseif ($form->get('cancel')->isClicked()) {
                $this->addFlash('status', $this->__('Operation cancelled.'));
            }

            // redirect to config page again (to show with GET request)
            return $this->redirectToRoute('«app.appName.formatForDB»_«app.configController.formatForDB»_config');
        }

        $templateParameters = [
            'form' => $form->createView()
        ];

        // render the config form
        return $this->render('@«app.appName»/«app.configController.formatForCodeCapital»/config.html.twig', $templateParameters);
    '''

    def private controllerImpl(Controller it) '''
        namespace «app.appNamespace»\Controller;

        use «app.appNamespace»\Controller\Base\Abstract«name.formatForCodeCapital»Controller;

        «IF it instanceof AjaxController»
            use Sensio\Bundle\FrameworkExtraBundle\Configuration\Method;
        «ENDIF»
        use Sensio\Bundle\FrameworkExtraBundle\Configuration\Route;
        use Symfony\Component\HttpFoundation\Request;
        use Zikula\ThemeModule\Engine\Annotation\Theme;

        /**
         * «name» controller class providing navigation and interaction functionality.
        «IF it instanceof AjaxController»
         «' '»*
         «' '»* @Route("/ajax")
        «ENDIF»
         */
        class «name.formatForCodeCapital»Controller extends Abstract«name.formatForCodeCapital»Controller
        {
            «FOR action : actions»
                «IF action.name.formatForCode != 'config'»
                    «actionHelper.generate(action, false)»

                «ENDIF»
            «ENDFOR»
            «IF hasActions('edit') && app.needsAutoCompletion»

                «handleInlineRedirect(false)»
            «ENDIF»
            «IF app.needsConfig && isConfigController»

                «configAction(false)»
            «ENDIF»
            «IF it instanceof AjaxController»
                «new Ajax().additionalAjaxFunctions(it, app)»
            «ENDIF»

            // feel free to add your own controller methods here
        }
    '''

    def private entityControllerImpl(Entity it) '''
        namespace «app.appNamespace»\Controller;

        use «app.appNamespace»\Controller\Base\Abstract«name.formatForCodeCapital»Controller;

        use RuntimeException;
        use Symfony\Component\HttpFoundation\Request;
        use Symfony\Component\Security\Core\Exception\AccessDeniedException;
        «IF hasActions('display') || hasActions('edit') || hasActions('delete')»
            use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;
        «ENDIF»
        use Sensio\Bundle\FrameworkExtraBundle\Configuration\Route;
        use Zikula\ThemeModule\Engine\Annotation\Theme;
        use «app.appNamespace»\Entity\«name.formatForCodeCapital»Entity;

        /**
         * «name.formatForDisplayCapital» controller class providing navigation and interaction functionality.
         */
        class «name.formatForCodeCapital»Controller extends Abstract«name.formatForCodeCapital»Controller
        {
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

                «handleSelectedObjects(false, true)»
                «handleSelectedObjects(false, false)»
            «ENDIF»
            «IF hasActions('edit') && app.needsAutoCompletion»

                «handleInlineRedirect(false)»
            «ENDIF»

            // feel free to add your own controller methods here
        }
    '''

    def private adminAndUserImpl(Entity it, Action action, Boolean isBase) '''
        «actionHelper.generate(it, action, isBase, true)»

        «actionHelper.generate(it, action, isBase, false)»
    '''
}
