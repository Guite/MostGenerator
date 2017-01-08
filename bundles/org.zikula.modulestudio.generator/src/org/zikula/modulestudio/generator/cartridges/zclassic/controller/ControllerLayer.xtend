package org.zikula.modulestudio.generator.cartridges.zclassic.controller

import de.guite.modulestudio.metamodel.Action
import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.DisplayAction
import de.guite.modulestudio.metamodel.Entity
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.action.InlineRedirect
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.action.MassHandling
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.additions.AjaxController
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.additions.ConfigController
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.additions.ExternalController
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.additions.Routing
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.additions.Scribite
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.formtype.QuickNavigation
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

        // controller classes
        getAllEntities.forEach[generateController(fsa)]
        new AjaxController().generate(it, fsa)
        if (needsConfig) {
            new ConfigController().generate(it, fsa)
        }

        new LinkContainer().generate(it, fsa)
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
            «IF hasViewAction»

                «new MassHandling().generate(it, true)»
            «ENDIF»
            «IF hasEditAction && app.needsAutoCompletion»

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
        «IF hasIndexAction || hasViewAction || hasDeleteAction»
            use Symfony\Component\HttpFoundation\RedirectResponse;
        «ENDIF»
        use Sensio\Bundle\FrameworkExtraBundle\Configuration\Cache;
        «IF hasDisplayAction || hasDeleteAction»
            use Sensio\Bundle\FrameworkExtraBundle\Configuration\ParamConverter;
        «ENDIF»
        use Sensio\Bundle\FrameworkExtraBundle\Configuration\Route;
        «IF hasViewAction»
            use Zikula\Component\SortableColumns\Column;
            use Zikula\Component\SortableColumns\SortableColumns;
        «ENDIF»
        use Zikula\Core\Controller\AbstractController;
        «IF hasEditAction && app.needsAutoCompletion»
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
            «IF hasViewAction»

                «new MassHandling().generate(it, false)»
            «ENDIF»
            «IF hasEditAction && app.needsAutoCompletion»

                «new InlineRedirect().generate(it, false)»
            «ENDIF»

            // feel free to add your own controller methods here
        }
    '''

    def private adminAndUserImpl(Entity it, Action action, Boolean isBase) '''
        «actionHelper.generate(it, action, isBase, true)»

        «actionHelper.generate(it, action, isBase, false)»
    '''
}
