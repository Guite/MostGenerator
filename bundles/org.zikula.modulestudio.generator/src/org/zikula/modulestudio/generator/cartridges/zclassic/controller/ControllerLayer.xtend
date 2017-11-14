package org.zikula.modulestudio.generator.cartridges.zclassic.controller

import de.guite.modulestudio.metamodel.Action
import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.DisplayAction
import de.guite.modulestudio.metamodel.Entity
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.action.InlineRedirect
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.action.LoggableHistory
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.action.MassHandling
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.additions.AjaxController
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.additions.ConfigController
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.additions.ExternalController
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.additions.Routing
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.additions.Scribite
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.formtype.QuickNavigationType
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

        // controller classes
        getAllEntities.forEach[generateController(fsa)]
        new AjaxController().generate(it, fsa)
        if (needsConfig) {
            new ConfigController().generate(it, fsa)
        }

        new LinkContainer().generate(it, fsa)
        new ItemActionsMenu().generate(it, fsa)
        new Routing().generate(it, fsa)
        if (hasViewActions) {
            new QuickNavigationType().generate(it, fsa)
        }

        if (generateExternalControllerAndFinder) {
            // controller for external calls
            new ExternalController().generate(it, fsa)

            if (generateScribitePlugins) {
                // Scribite integration
                new Scribite().generate(it, fsa)
            }
        }
    }

    /**
     * Creates controller class files for every Entity instance.
     */
    def private generateController(Entity it, IFileSystemAccess fsa) {
        println('Generating "' + name.formatForDisplay + '" controller classes')
        app.generateClassPair(fsa, 'Controller/' + name.formatForCodeCapital + 'Controller.php',
            fh.phpFileContent(app, entityControllerBaseImpl), fh.phpFileContent(app, entityControllerImpl)
        )
    }

    def private entityControllerBaseImpl(Entity it) '''
        «entityControllerBaseImports»
        /**
         * «name.formatForDisplayCapital» controller base class.
         */
        abstract class Abstract«name.formatForCodeCapital»Controller extends AbstractController
        {
            «FOR action : getAllEntityActions»
                «adminAndUserImpl(action, true)»
            «ENDFOR»
            «IF hasViewAction»

                «new MassHandling().generate(it, true)»
            «ENDIF»
            «IF loggable»

                «new LoggableHistory().generate(it, true)»
            «ENDIF»
            «IF hasEditAction && app.needsInlineEditing»

                «new InlineRedirect().generate(it, true)»
            «ENDIF»
        }
    '''

    def private entityControllerBaseImports(Entity it) '''
        namespace «app.appNamespace»\Controller\Base;

        «IF hasEditAction || hasDeleteAction»
            use RuntimeException;
        «ENDIF»
        use Symfony\Component\HttpFoundation\Request;
        use Symfony\Component\Security\Core\Exception\AccessDeniedException;
        «IF hasDisplayAction || hasEditAction || hasDeleteAction»
            use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;
        «ENDIF»
        «IF hasIndexAction || hasViewAction || hasEditAction || hasDeleteAction»
            use Symfony\Component\HttpFoundation\RedirectResponse;
        «ENDIF»
        «IF (hasViewAction || hasDeleteAction) && !skipHookSubscribers»
            «IF hasDeleteAction»
                use Zikula\Bundle\HookBundle\Category\FormAwareCategory;
            «ENDIF»
            use Zikula\Bundle\HookBundle\Category\UiHooksCategory;
        «ENDIF»
        «IF hasViewAction»
            use Zikula\Component\SortableColumns\Column;
            use Zikula\Component\SortableColumns\SortableColumns;
        «ENDIF»
        use Zikula\Core\Controller\AbstractController;
        «IF hasEditAction && app.needsInlineEditing»
            use Zikula\Core\Response\PlainResponse;
        «ENDIF»
        «IF !skipHookSubscribers»
            use Zikula\Core\RouteUrl;
        «ENDIF»
        use «entityClassName('', false)»;
        «IF app.hasCategorisableEntities»
            use «app.appNamespace»\Helper\FeatureActivationHelper;
        «ENDIF»

    '''

    def private entityControllerImpl(Entity it) '''
        namespace «app.appNamespace»\Controller;

        use «app.appNamespace»\Controller\Base\Abstract«name.formatForCodeCapital»Controller;

        «IF hasEditAction || hasDeleteAction»
            use RuntimeException;
        «ENDIF»
        «/*use Sensio\Bundle\FrameworkExtraBundle\Configuration\Cache;*/»
        «IF hasDisplayAction || hasDeleteAction»
            use Sensio\Bundle\FrameworkExtraBundle\Configuration\ParamConverter;
        «ENDIF»
        use Sensio\Bundle\FrameworkExtraBundle\Configuration\Route;
        use Symfony\Component\HttpFoundation\Request;
        use Symfony\Component\Security\Core\Exception\AccessDeniedException;
        «IF hasDisplayAction || hasEditAction || hasDeleteAction»
            use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;
        «ENDIF»
        use Zikula\ThemeModule\Engine\Annotation\Theme;
        use «entityClassName('', false)»;

        /**
         * «name.formatForDisplayCapital» controller class providing navigation and interaction functionality.
         */
        class «name.formatForCodeCapital»Controller extends Abstract«name.formatForCodeCapital»Controller
        {
            «IF hasSluggableFields»«/* put display method at the end to avoid conflict between delete/edit and display for slugs */»
                «FOR action : getAllEntityActions.exclude(DisplayAction)»
                    «adminAndUserImpl(action as Action, false)»
                «ENDFOR»
                «IF loggable && hasDisplayAction»
                    «displayDeletedAction»
                «ENDIF»
                «FOR action : getAllEntityActions.filter(DisplayAction)»
                    «adminAndUserImpl(action, false)»
                «ENDFOR»
            «ELSE»
                «IF loggable && hasDisplayAction»
                    «displayDeletedAction»
                «ENDIF»
                «FOR action : getAllEntityActions»
                    «adminAndUserImpl(action, false)»
                «ENDFOR»
            «ENDIF»
            «IF hasViewAction»

                «new MassHandling().generate(it, false)»
            «ENDIF»
            «IF loggable»

                «new LoggableHistory().generate(it, false)»
            «ENDIF»
            «IF hasEditAction && app.needsInlineEditing»

                «new InlineRedirect().generate(it, false)»
            «ENDIF»

            // feel free to add your own controller methods here
        }
    '''

    def private displayDeletedAction(Entity it) '''
        «displayDeletedSingleAction(true)»

        «displayDeletedSingleAction(false)»

        «restoreDeletedEntity»
    '''

    def private displayDeletedSingleAction(Entity it, Boolean isAdmin) '''
        /**
         * Displays a deleted «name.formatForDisplay».
         *
         * @Route("/«IF isAdmin»admin/«ENDIF»«name.formatForCode»/deleted/{id}.{_format}",
         *        requirements = {"id" = "\d+", "_format" = "html"},
         *        defaults = {"_format" = "html"},
         *        methods = {"GET"}
         * )
         «IF isAdmin»
         * @Theme("admin")
         «ENDIF»
         *
         * @param Request $request Current request instance
         * @param integer $id      Identifier of entity
         *
         * @return Response Output
         *
         * @throws AccessDeniedException Thrown if the user doesn't have required permissions
         * @throws NotFoundHttpException Thrown if «name.formatForDisplay» to be displayed isn't found
         */
        public function «IF isAdmin»adminD«ELSE»d«ENDIF»isplayDeletedAction(Request $request, $id = 0)
        {
            $«name.formatForCode» = $this->restoreDeletedEntity($id);

            $undelete = $request->query->getInt('undelete', 0);
            if ($undelete == 1) {
                $actionObject->setWorkflowState('initial');
                try {
                    // execute the workflow action
                    $workflowHelper = $this->get('«application.appService».workflow_helper');
                    $success = $workflowHelper->executeAction($«name.formatForCode», 'submit');

                    if ($success) {
                        $this->addFlash('status', $this->__('Done! Reinserted «name.formatForDisplay».'));
                    } else {
                        $this->addFlash('error', $this->__('Error! Reinserting «name.formatForDisplay» failed.'));
                    }
                } catch (\Exception $exception) {
                    $this->addFlash('error', $this->__f('Sorry, but an error occured during the %action% action. Please apply the changes again!', ['%action%' => 'submit']) . '  ' . $exception->getMessage());
                }

                $request->query->set('«getPrimaryKey.name.formatForCode»', $«name.formatForCode»->get«getPrimaryKey.name.formatForCodeCapital»());
                $request->query->remove('undelete');

                return $this->redirectToRoute('«application.appName.formatForDB»_«name.formatForDB»_«IF isAdmin»admin«ENDIF»display', $request->query->all());
            }

            return parent::«IF isAdmin»adminD«ELSE»d«ENDIF»isplayAction($request, $«name.formatForCode»);
        }
    '''

    def private restoreDeletedEntity(Entity it) '''
        /**
         * Resets a deleted «name.formatForDisplay» back to the last version before it's deletion.
         *
         * @return «name.formatForCodeCapital»Entity The restored entity
         *
         * @throws NotFoundHttpException Thrown if «name.formatForDisplay» isn't found
         */
        protected function restoreDeletedEntity($id = 0)
        {
            if (!$id) {
                throw new NotFoundHttpException($this->__('No such «name.formatForDisplay» found.'));
            }

            $entityFactory = $this->get('«application.appService».entity_factory');
            $«name.formatForCode» = $entityFactory->create«name.formatForCodeCapital»();
            $«name.formatForCode»->set«getPrimaryKey.name.formatForCodeCapital»($id);
            $entityManager = $entityFactory->getObjectManager();
            $logEntriesRepository = $entityManager->getRepository('«application.appName»:«name.formatForCodeCapital»LogEntryEntity');
            $logEntries = $logEntriesRepository->getLogEntries($«name.formatForCode»);
            $lastVersionBeforeDeletion = null;
            foreach ($logEntries as $logEntry) {
                if ($logEntry->getAction() != 'remove') {
                    $lastVersionBeforeDeletion = $logEntry->getVersion();
                    break;
                }
            }
            if (null === $lastVersionBeforeDeletion) {
                throw new NotFoundHttpException($this->__('No such «name.formatForDisplay» found.'));
            }

            $logEntriesRepository->revert($«name.formatForCode», $lastVersionBeforeDeletion);

            return $«name.formatForCode»;
        }
    '''

    def private adminAndUserImpl(Entity it, Action action, Boolean isBase) '''
        «actionHelper.generate(it, action, isBase, true)»

        «actionHelper.generate(it, action, isBase, false)»
    '''
}
