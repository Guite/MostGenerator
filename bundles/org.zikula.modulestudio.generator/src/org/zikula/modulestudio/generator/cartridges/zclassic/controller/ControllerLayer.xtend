package org.zikula.modulestudio.generator.cartridges.zclassic.controller

import de.guite.modulestudio.metamodel.Action
import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.DetailAction
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.StringField
import de.guite.modulestudio.metamodel.StringRole
import java.util.List
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.application.ImportList
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.action.InlineRedirect
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.action.LoggableHistory
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.action.LoggableUndelete
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.action.MassHandling
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.additions.AjaxController
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.config.ConfigureActions
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.config.ConfigureCrud
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.config.ConfigureFields
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.config.ConfigureFilters
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.menu.ExtensionMenu
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.menu.MenuBuilder
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.Routing
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ControllerLayer {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelExtensions = new ModelExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    Application app
    ControllerAction actionHelper
    List<ControllerMethodInterface> configureMethods

    /**
     * Entry point for the controller creation.
     */
    def void generate(Application it, IMostFileSystemAccess fsa) {
        this.app = it
        this.actionHelper = new ControllerAction(app)
        this.configureMethods = #[
            new ConfigureCrud(),
            new ConfigureFields(),
            new ConfigureFilters(),
            new ConfigureActions()
        ]

        // controller classes
        getAllEntities.forEach[generateController(fsa)]
        new AjaxController().generate(it, fsa)

        new ExtensionMenu().generate(it, fsa)
        new MenuBuilder().generate(it, fsa)
        new Routing().generate(it, fsa)
    }

    /**
     * Creates controller class files for every Entity instance.
     */
    def private generateController(Entity it, IMostFileSystemAccess fsa) {
        ('Generating "' + name.formatForDisplay + '" controller classes').printIfNotTesting(fsa)
        configureMethods.forEach[m|m.init(it)]
        fsa.generateClassPair('Controller/' + name.formatForCodeCapital + 'Controller.php', entityControllerBaseImpl, entityControllerImpl)
    }

    def private entityControllerBaseImpl(Entity it) '''
        namespace «app.appNamespace»\Controller\Base;

        «collectBaseImports.print»

        /**
         * «name.formatForDisplayCapital» controller base class.
         */
        abstract class Abstract«name.formatForCodeCapital»Controller extends AbstractCrudController
        {
            use TranslatorTrait;
        
            public function __construct(
                TranslatorInterface $translator,
                «IF !getAllEntityFields.filter(StringField).filter[#[StringRole.COUNTRY, StringRole.CURRENCY, StringRole.LANGUAGE, StringRole.LOCALE, StringRole.TIME_ZONE].contains(role)].empty»
                    protected readonly RequestStack $requestStack,
                «ENDIF»
                «IF hasLocaleFieldsEntity»
                    protected readonly LocaleApiInterface $localeApi,
                «ENDIF»
                «IF hasListFieldsEntity»
                    protected readonly ListEntriesHelper $listEntriesHelper,
                «ENDIF»
                «IF hasUploadFieldsEntity»
                    protected readonly UploadHelper $uploadHelper,
                «ENDIF»
                protected readonly PermissionHelper $permissionHelper«IF hasDetailAction || hasEditAction»,
                protected readonly EntityDisplayHelper $entityDisplayHelper«ENDIF»
            ) {
                $this->setTranslator($translator);
            }

            public static function getEntityFqcn(): string
            {
                return «name.formatForCodeCapital»::class;
            }
            «FOR method : configureMethods»

                «method.generateMethod(it)»
            «ENDFOR»

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

    def private commonAppImports(Entity it) {
        val imports = newArrayList
        imports.add(entityClassName('', false))
        if (loggable) {
            imports.add(app.appNamespace + '\\Entity\\' + name.formatForCodeCapital + 'LogEntry')
        }
        if (hasEditAction) {
            imports.add(app.appNamespace + '\\Form\\Handler\\' + name.formatForCodeCapital + '\\EditHandler')
        }
        if (hasIndexAction || hasDetailAction || hasEditAction || hasDeleteAction) {
            imports.add(app.appNamespace + '\\Helper\\ControllerHelper')
        }
        if (hasDetailAction || hasEditAction) {
            imports.add(app.appNamespace + '\\Helper\\EntityDisplayHelper')
        }
        if (loggable) {
            imports.add(app.appNamespace + '\\Helper\\LoggableHelper')
        }
        imports.add(app.appNamespace + '\\Helper\\PermissionHelper')
        if (loggable && hasTranslatableFields) {
            imports.add(app.appNamespace + '\\Helper\\TranslatableHelper')
        }
        if (hasIndexAction || hasDetailAction || hasEditAction || hasDeleteAction) {
            imports.add(app.appNamespace + '\\Helper\\ViewHelper')
        }
        if (hasIndexAction || hasDeleteAction || loggable) {
            imports.add(app.appNamespace + '\\Helper\\WorkflowHelper')
        }
        if (hasIndexAction || hasDetailAction || (hasEditAction && app.needsInlineEditing) || hasDeleteAction || loggable) {
            imports.add(app.appNamespace + '\\Repository\\' + name.formatForCodeCapital + 'RepositoryInterface')
            if (loggable) {
                imports.add(app.appNamespace + '\\Repository\\' + name.formatForCodeCapital + 'LogEntryRepositoryInterface')
            }
        }
        imports
    }

    def private collectBaseImports(Entity it) {
        val imports = new ImportList
        configureMethods.forEach[c|imports.addAll(c.imports(it))]
        imports.addAll(#[
            'EasyCorp\\Bundle\\EasyAdminBundle\\Controller\\AbstractCrudController',
            'Symfony\\Component\\HttpFoundation\\Request',
            'Symfony\\Component\\HttpFoundation\\Response',
            'Symfony\\Component\\Security\\Core\\Exception\\AccessDeniedException',
            'function Symfony\\Component\\Translation\\t',
            'Symfony\\Contracts\\Translation\\TranslatorInterface',
            'Zikula\\CoreBundle\\Translation\\TranslatorTrait'
        ])
        if (hasIndexAction || hasEditAction) {
            imports.add('Exception')
        }
        if (hasIndexAction || hasDeleteAction) {
            imports.add('Psr\\Log\\LoggerInterface')
        }
        if (hasIndexAction || hasEditAction || hasDeleteAction) {
            imports.add('RuntimeException')
        }
        if (hasEditAction) {
            imports.add('Symfony\\Component\\HttpFoundation\\RedirectResponse')
        }
        if (hasIndexAction) {
            imports.add('Symfony\\Component\\Routing\\RouterInterface')
        }
        if (hasDetailAction || hasDeleteAction) {
            imports.add('Symfony\\Component\\HttpKernel\\Exception\\NotFoundHttpException')
        }
        if (hasDeleteAction) {
            imports.add('Zikula\\FormExtensionBundle\\Form\\Type\\DeletionType')
        }
        if (hasEditAction && app.needsInlineEditing) {
            imports.add('Zikula\\CoreBundle\\Response\\PlainResponse')
        }
        if (hasIndexAction || hasDeleteAction) {
            imports.add('Zikula\\UsersBundle\\Api\\ApiInterface\\CurrentUserApiInterface')
        }
        if (ownerPermission && hasDeleteAction) {
            imports.add('Zikula\\UsersBundle\\UsersConstant')
        }
        imports.addAll(commonAppImports)
        if (hasLocaleFieldsEntity) {
            imports.add('Zikula\\CoreBundle\\Api\\ApiInterface\\LocaleApiInterface')
        }
        if (hasListFieldsEntity) {
            imports.add(app.appNamespace + '\\Helper\\ListEntriesHelper')
        }
        if (hasUploadFieldsEntity) {
            imports.add(app.appNamespace + '\\Helper\\UploadHelper')
        }
        if (!getAllEntityFields.filter(StringField).filter[#[StringRole.COUNTRY, StringRole.CURRENCY, StringRole.LANGUAGE, StringRole.LOCALE, StringRole.TIME_ZONE].contains(role)].empty) {
            imports.add('Symfony\\Component\\HttpFoundation\\RequestStack')
        }
        imports
    }

    def private collectImplImports(Entity it) {
        val imports = new ImportList
        imports.addAll(#[
            'Symfony\\Component\\HttpFoundation\\Request',
            'Symfony\\Component\\HttpFoundation\\Response',
            'Symfony\\Component\\Routing\\Annotation\\Route',
            app.appNamespace + '\\Controller\\Base\\Abstract' + name.formatForCodeCapital + 'Controller'
        ])
        if (hasIndexAction || hasDeleteAction) {
            imports.add('Psr\\Log\\LoggerInterface')
            if (hasIndexAction) {
                imports.add('Symfony\\Component\\HttpFoundation\\RedirectResponse')
                imports.add('Symfony\\Component\\Routing\\RouterInterface')
            }
            imports.add('Zikula\\UsersBundle\\Api\\ApiInterface\\CurrentUserApiInterface')
        }
        imports.addAll(commonAppImports)
        imports
    }

    def private entityControllerImpl(Entity it) '''
        namespace «app.appNamespace»\Controller;

        «collectImplImports.print»

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
