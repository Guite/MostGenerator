package org.zikula.modulestudio.generator.cartridges.symfony.controller

import de.guite.modulestudio.metamodel.Action
import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.DeleteAction
import de.guite.modulestudio.metamodel.DetailAction
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.StringField
import de.guite.modulestudio.metamodel.StringRole
import java.util.List
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.application.ImportList
import org.zikula.modulestudio.generator.cartridges.symfony.controller.action.AjaxController
import org.zikula.modulestudio.generator.cartridges.symfony.controller.action.InlineRedirect
import org.zikula.modulestudio.generator.cartridges.symfony.controller.action.LoggableHistory
import org.zikula.modulestudio.generator.cartridges.symfony.controller.action.LoggableUndelete
import org.zikula.modulestudio.generator.cartridges.symfony.controller.action.MassHandling
import org.zikula.modulestudio.generator.cartridges.symfony.controller.config.ConfigureActions
import org.zikula.modulestudio.generator.cartridges.symfony.controller.config.ConfigureCrud
import org.zikula.modulestudio.generator.cartridges.symfony.controller.config.ConfigureFields
import org.zikula.modulestudio.generator.cartridges.symfony.controller.config.ConfigureFilters
import org.zikula.modulestudio.generator.cartridges.symfony.controller.menu.ExtensionMenu
import org.zikula.modulestudio.generator.cartridges.symfony.controller.menu.MenuBuilder
import org.zikula.modulestudio.generator.cartridges.symfony.smallstuff.Routing
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils
import org.zikula.modulestudio.generator.extensions.WorkflowExtensions

class ControllerLayer {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelExtensions = new ModelExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils
    extension WorkflowExtensions = new WorkflowExtensions

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
        entities.forEach[generateController(fsa)]
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
                protected readonly EntityInitializer $entityInitializer,
                «IF !getAllEntityFields.filter(StringField).filter[#[StringRole.COUNTRY, StringRole.CURRENCY, StringRole.LANGUAGE, StringRole.LOCALE, StringRole.TIME_ZONE].contains(role)].empty»
                    protected readonly RequestStack $requestStack,
                «ENDIF»
                «IF hasDetailAction || hasEditAction»
                    protected readonly EntityDisplayHelper $entityDisplayHelper,
                «ENDIF»
                «IF hasListFieldsEntity»
                    protected readonly ListEntriesHelper $listEntriesHelper,
                «ENDIF»
                «IF hasEditAction»
                    protected readonly ModelHelper $modelHelper,
                «ENDIF»
                protected readonly PermissionHelper $permissionHelper,
                «IF hasUploadFieldsEntity»
                    protected readonly UploadHelper $uploadHelper,
                    «IF !getUploadFieldsEntity.filter[f|!f.isOnlyImageField].empty»
                        protected readonly UploaderHelper $uploaderHelper,
                    «ENDIF»
                «ENDIF»
                «IF hasDateIntervalFieldsEntity»
                    protected readonly ViewHelper $viewHelper,
                «ENDIF»
                «IF hasVisibleWorkflow»
                    protected readonly WorkflowHelper $workflowHelper,
                «ENDIF»
                «IF hasLocaleFieldsEntity»
                    #[Autowire(param: 'kernel.enabled_locales')]
                    protected readonly array $enabledLocales,
                «ENDIF»
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

            public function createEntity(string $entityFqcn): «name.formatForCodeCapital»
            {
                $entity = parent::createEntity($entityFqcn);

                return $this->entityInitializer->init«name.formatForCodeCapital»($entity);
            }

            «FOR action : actions»
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
        if (hasEditAction) {
            imports.add(app.appNamespace + '\\Helper\\ModelHelper')
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
            'Zikula\\CoreBundle\\Translation\\TranslatorTrait',
            app.appNamespace + '\\Entity\\Initializer\\EntityInitializer'
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
        if (hasIndexAction || hasEditAction) {
            imports.add('Symfony\\Component\\HttpFoundation\\RedirectResponse')
        }
        if (hasIndexAction) {
            imports.add('Symfony\\Component\\Routing\\RouterInterface')
        }
        if (hasDetailAction || hasDeleteAction) {
            imports.add('Symfony\\Component\\HttpKernel\\Exception\\NotFoundHttpException')
        }
        if (hasEditAction && app.needsInlineEditing) {
            imports.add('Zikula\\CoreBundle\\Response\\PlainResponse')
        }
        if (hasIndexAction || hasDeleteAction) {
            imports.add('Symfony\\Component\\Security\\Core\\User\\UserInterface')
            imports.add('Symfony\\Component\\Security\\Http\\Attribute\\CurrentUser')
        }
        if (ownerPermission && hasDeleteAction) {
            imports.add('Zikula\\UsersBundle\\UsersConstant')
        }
        imports.addAll(commonAppImports)
        if (hasLocaleFieldsEntity) {
            imports.add('Symfony\\Component\\DependencyInjection\\Attribute\\Autowire')
        }
        if (hasListFieldsEntity) {
            imports.add(app.appNamespace + '\\Helper\\ListEntriesHelper')
        }
        if (hasUploadFieldsEntity) {
            imports.add(app.appNamespace + '\\Helper\\UploadHelper')
        }
        if (hasVisibleWorkflow) {
            imports.add(app.appNamespace + '\\Helper\\WorkflowHelper')
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
            'Symfony\\Component\\Routing\\Requirement\\Requirement',
            app.appNamespace + '\\Controller\\Base\\Abstract' + name.formatForCodeCapital + 'Controller'
        ])
        if (hasIndexAction || hasDeleteAction) {
            imports.add('Psr\\Log\\LoggerInterface')
            if (hasIndexAction) {
                imports.add('EasyCorp\\Bundle\\EasyAdminBundle\\Dto\\BatchActionDto')
                imports.add('Symfony\\Component\\HttpFoundation\\RedirectResponse')
                imports.add('Symfony\\Component\\Routing\\RouterInterface')
            }
            imports.add('Symfony\\Component\\Security\\Core\\User\\UserInterface')
            imports.add('Symfony\\Component\\Security\\Http\\Attribute\\CurrentUser')
        }
        imports.addAll(commonAppImports)
        imports
    }

    def private actionsWithOldMethod(Entity it) {
        actions.reject(DeleteAction)
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
            «FOR action : actionsWithOldMethod.reject(DetailAction)»
                «actionImpl(action, false)»

            «ENDFOR»
            «IF loggable»
                «new LoggableUndelete().generate(it, false)»
                «new LoggableHistory().generate(it, false)»
            «ENDIF»
            «FOR action : actionsWithOldMethod.filter(DetailAction)»
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
