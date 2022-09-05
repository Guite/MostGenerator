package org.zikula.modulestudio.generator.cartridges.zclassic.controller

import de.guite.modulestudio.metamodel.Action
import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.DetailAction
import de.guite.modulestudio.metamodel.Entity
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.action.InlineRedirect
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.action.LoggableHistory
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.action.LoggableUndelete
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.action.MassHandling
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.additions.AjaxController
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.formtype.QuickNavigationType
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.menu.ExtensionMenu
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.menu.MenuBuilder
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.Routing
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.DateTimeExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ControllerLayer {

    extension ControllerExtensions = new ControllerExtensions
    extension DateTimeExtensions = new DateTimeExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    Application app
    ControllerAction actionHelper

    /**
     * Entry point for the controller creation.
     */
    def void generate(Application it, IMostFileSystemAccess fsa) {
        this.app = it
        this.actionHelper = new ControllerAction(app)

        // controller classes
        getAllEntities.forEach[generateController(fsa)]
        new AjaxController().generate(it, fsa)

        new ExtensionMenu().generate(it, fsa)
        new MenuBuilder().generate(it, fsa)
        new Routing().generate(it, fsa)
        if (hasIndexActions) {
            new QuickNavigationType().generate(it, fsa)
        }
    }

    /**
     * Creates controller class files for every Entity instance.
     */
    def private generateController(Entity it, IMostFileSystemAccess fsa) {
        ('Generating "' + name.formatForDisplay + '" controller classes').printIfNotTesting(fsa)
        fsa.generateClassPair('Controller/' + name.formatForCodeCapital + 'Controller.php', entityControllerBaseImpl, entityControllerImpl)
    }

    def private entityControllerBaseImpl(Entity it) '''
        «entityControllerBaseImports»
        /**
         * «name.formatForDisplayCapital» controller base class.
         */
        abstract class Abstract«name.formatForCodeCapital»Controller extends AbstractCrudController
        {
            use TranslatorTrait;
        
            public function __construct(TranslatorInterface $translator)
            {
                $this->setTranslator($translator);
            }

            public static function getEntityFqcn(): string
            {
                return «name.formatForCodeCapital»::class;
            }

            public function configureCrud(Crud $crud): Crud
            {
                return $crud
                    ->setEntityLabelInSingular(
                        fn (?«name.formatForCodeCapital» $«name.formatForCode», ?string $pageName) => $«name.formatForCode» ?? '«name.formatForDisplayCapital»'
                    )
                    ->setEntityLabelInPlural('«nameMultiple.formatForDisplayCapital»')
                    ->setPageTitle(Crud::PAGE_INDEX, t('%entity_label_plural% list'))
                    ->setPageTitle(Crud::PAGE_NEW, t('New %entity_label_singular%'))
                    ->setPageTitle(Crud::PAGE_DETAIL, fn («name.formatForCodeCapital» $«name.formatForCode») => (string) $«name.formatForCode»)
                    ->setPageTitle(Crud::PAGE_EDIT, fn («name.formatForCodeCapital» $«name.formatForCode») => sprintf(t('Edit %s'), (string) $«name.formatForCode»))
                    «IF null !== documentation && !documentation.replaceAll('\\s+', '').empty»
                        ->setHelp(Crud::PAGE_INDEX, t('«documentation.replaceAll('\'', '"')»'))
                    «ENDIF»
                ;
            }

            «FOR action : getAllEntityActions»
                «actionImpl(action, true)»

            «ENDFOR»
            «IF hasIndexAction»
                «new MassHandling().generate(it, true)»
            «ENDIF»
            «IF loggable»
                «new LoggableUndelete().generate(it, true)»
                «new LoggableHistory().generate(it, true)»
            «ENDIF»
            «IF hasEditAction && app.needsInlineEditing»
                «new InlineRedirect().generate(it, true)»
            «ENDIF»
        }
    '''

    def private commonAppImports(Entity it) '''
        use «entityClassName('', false)»;
        «IF loggable»
            use «app.appNamespace»\Entity\«name.formatForCodeCapital»LogEntry;
        «ENDIF»
        «IF hasEditAction»
            use «app.appNamespace»\Form\Handler\«name.formatForCodeCapital»\EditHandler;
        «ENDIF»
        «IF hasIndexAction || hasDetailAction || hasEditAction || hasDeleteAction»
            use «app.appNamespace»\Helper\ControllerHelper;
        «ENDIF»
        «IF (hasDetailAction && app.generateIcsTemplates && hasStartAndEndDateField) || (hasEditAction && app.needsInlineEditing)»
            use «app.appNamespace»\Helper\EntityDisplayHelper;
        «ENDIF»
        «IF loggable»
            use «app.appNamespace»\Helper\LoggableHelper;
        «ENDIF»
        use «app.appNamespace»\Helper\PermissionHelper;
        «IF loggable && hasTranslatableFields»
            use «app.appNamespace»\Helper\TranslatableHelper;
        «ENDIF»
        «IF hasIndexAction || hasDetailAction || hasEditAction || hasDeleteAction»
            use «app.appNamespace»\Helper\ViewHelper;
        «ENDIF»
        «IF hasIndexAction || hasDeleteAction || loggable»
            use «app.appNamespace»\Helper\WorkflowHelper;
        «ENDIF»
        «IF hasIndexAction || hasDetailAction || (hasEditAction && app.needsInlineEditing) || hasDeleteAction || loggable»
            use «app.appNamespace»\Repository\«name.formatForCodeCapital»RepositoryInterface;
            «IF loggable»
                use «app.appNamespace»\Repository\«name.formatForCodeCapital»LogEntryRepositoryInterface;
            «ENDIF»
        «ENDIF»
    '''

    def private entityControllerBaseImports(Entity it) '''
        namespace «app.appNamespace»\Controller\Base;

        use EasyCorp\Bundle\EasyAdminBundle\Config\Crud;
        use EasyCorp\Bundle\EasyAdminBundle\Controller\AbstractCrudController;
        «IF hasIndexAction || hasEditAction»
            use Exception;
        «ENDIF»
        «IF hasIndexAction || hasDeleteAction»
            use Psr\Log\LoggerInterface;
        «ENDIF»
        «IF hasIndexAction || hasEditAction || hasDeleteAction»
            use RuntimeException;
        «ENDIF»
        «IF hasEditAction»
            use Symfony\Component\HttpFoundation\RedirectResponse;
        «ENDIF»
        use Symfony\Component\HttpFoundation\Request;
        use Symfony\Component\HttpFoundation\Response;
        «IF hasIndexAction»
            use Symfony\Component\Routing\RouterInterface;
        «ENDIF»
        «IF hasDetailAction || hasDeleteAction»
            use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;
        «ENDIF»
        use Symfony\Component\Security\Core\Exception\AccessDeniedException;
        use Symfony\Contracts\Translation\TranslatorInterface;
        use Zikula\Bundle\CoreBundle\Translation\TranslatorTrait;
        «IF hasDeleteAction»
            use Zikula\Bundle\FormExtensionBundle\Form\Type\DeletionType;
        «ENDIF»
        «IF hasIndexAction»
            use Zikula\Component\SortableColumns\Column;
            use Zikula\Component\SortableColumns\SortableColumns;
        «ENDIF»
        «IF hasEditAction && app.needsInlineEditing»
            use Zikula\Bundle\CoreBundle\Response\PlainResponse;
        «ENDIF»
        «IF hasIndexAction || hasDeleteAction»
            use Zikula\UsersBundle\Api\ApiInterface\CurrentUserApiInterface;
        «ENDIF»
        «IF ownerPermission && hasDeleteAction»
            use Zikula\UsersBundle\UsersConstant;
        «ENDIF»
        «commonAppImports»

    '''

    def private entityControllerImpl(Entity it) '''
        namespace «app.appNamespace»\Controller;

        use «app.appNamespace»\Controller\Base\Abstract«name.formatForCodeCapital»Controller;
        «IF hasIndexAction || hasDeleteAction»
            use Psr\Log\LoggerInterface;
        «ENDIF»
        «IF hasIndexAction»
            use Symfony\Component\HttpFoundation\RedirectResponse;
        «ENDIF»
        use Symfony\Component\HttpFoundation\Request;
        use Symfony\Component\HttpFoundation\Response;
        use Symfony\Component\Routing\Annotation\Route;
        «IF hasIndexAction»
            use Symfony\Component\Routing\RouterInterface;
        «ENDIF»
        use Zikula\ThemeBundle\Engine\Annotation\Theme;
        «IF hasIndexAction || hasDeleteAction»
            use Zikula\UsersBundle\Api\ApiInterface\CurrentUserApiInterface;
        «ENDIF»
        «commonAppImports»

        /**
         * «name.formatForDisplayCapital» controller class providing navigation and interaction functionality.
         */
        #[Route('/«application.name.formatForDB»')]
        class «name.formatForCodeCapital»Controller extends Abstract«name.formatForCodeCapital»Controller
        {
            «/* put display method at the end to avoid conflict between delete/edit and display for slugs */»
            «FOR action : getAllEntityActions.reject(DetailAction)»
                «actionImpl(action, false)»

            «ENDFOR»
            «IF loggable»
                «new LoggableUndelete().generate(it, false)»
                «new LoggableHistory().generate(it, false)»
            «ENDIF»
            «FOR action : getAllEntityActions.filter(DetailAction)»
                «actionImpl(action, false)»

            «ENDFOR»
            «IF hasIndexAction»
                «new MassHandling().generate(it, false)»
            «ENDIF»
            «IF hasEditAction && app.needsInlineEditing»
                «new InlineRedirect().generate(it, false)»
            «ENDIF»

            // feel free to add your own controller methods here
        }
    '''

    def private actionImpl(Entity it, Action action, Boolean isBase) '''
        «actionHelper.generate(it, action, isBase)»
    '''
}
