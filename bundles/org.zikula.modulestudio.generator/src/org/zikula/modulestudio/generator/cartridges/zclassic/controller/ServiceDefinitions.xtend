package org.zikula.modulestudio.generator.cartridges.zclassic.controller

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.MappedSuperClass
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.GeneratorSettingsExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils
import org.zikula.modulestudio.generator.extensions.WorkflowExtensions

/**
 * Service definitions in YAML format.
 */
class ServiceDefinitions {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension GeneratorSettingsExtensions = new GeneratorSettingsExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelJoinExtensions = new ModelJoinExtensions
    extension ModelExtensions = new ModelExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils
    extension WorkflowExtensions = new WorkflowExtensions

    String modPrefix = ''

    def private generateServiceFile(Application it, IFileSystemAccess fsa, String fileName, CharSequence content) {
        var definitionFilePath = getResourcesPath + 'config/' + fileName + '.yml'
        if (!shouldBeSkipped(definitionFilePath)) {
            if (shouldBeMarked(definitionFilePath)) {
                definitionFilePath = getResourcesPath + 'config/' + fileName + '.generated.yml'
            }
            fsa.generateFile(definitionFilePath, content)
        }
    }

    /**
     * Entry point for service definitions.
     * This generates YAML files describing DI configuration.
     */
    def generate(Application it, IFileSystemAccess fsa) {
        modPrefix = appService

        generateServiceFile(fsa, 'services', mainServiceFile)
        if (hasUploads) {
            generateServiceFile(fsa, 'uploadHandler', uploadHandler)
        }
        generateServiceFile(fsa, 'linkContainer', linkContainer)
        generateServiceFile(fsa, 'entityFactories', entityFactories)
        generateServiceFile(fsa, 'eventSubscriber', eventSubscriber)
        if (hasEditActions) {
            generateServiceFile(fsa, 'formFields', formFields)
        }
        generateServiceFile(fsa, 'forms', forms)
        generateServiceFile(fsa, 'helpers', helpers)
        generateServiceFile(fsa, 'twig', twig)
        generateServiceFile(fsa, 'logger', logger)
    }

    def private mainServiceFile(Application it) '''
        imports:
        «IF hasUploads»
            «'  '»- { resource: 'uploadHandler.yml' }
        «ENDIF»
          - { resource: 'linkContainer.yml' }
          - { resource: 'entityFactories.yml' }
          - { resource: 'eventSubscriber.yml' }
        «IF hasEditActions»
            «'  '»- { resource: 'formFields.yml' }
        «ENDIF»
          - { resource: 'forms.yml' }
          - { resource: 'helpers.yml' }
          - { resource: 'twig.yml' }
          - { resource: 'logger.yml' }
        «IF hasImageFields»

        parameters:
            liip_imagine.cache.signer.class: «appNamespace»\Imagine\Cache\DummySigner
        «ENDIF»
    '''

    def private uploadHandler(Application it) '''
        services:
            «servicesUploadHandler»
    '''

    def private servicesUploadHandler(Application it) '''
        # Upload handler class
        «modPrefix».upload_handler:
            class: «appNamespace»\UploadHandler
            arguments:
                - "@translator.default"
                - "@zikula_users_module.current_user"
                - "@zikula_extensions_module.api.variable"
    '''

    def private linkContainer(Application it) '''
        services:
            «modPrefix».link_container:
                class: «appNamespace»\Container\LinkContainer
                arguments:
                    - "@translator.default"
                    - "@router"
                    - "@zikula_permissions_module.api.permission"
                    - "@«modPrefix».controller_helper"
                    «IF generateAccountApi»
                        - "@zikula_extensions_module.api.variable"
                    «ENDIF»
                    «IF generateAccountApi || hasEditActions»
                        - "@zikula_users_module.current_user"
                    «ENDIF»
                tags:
                    - { name: zikula.link_container }
    '''

    def private entityFactories(Application it) '''
        services:
            «servicesEntityFactories»
    '''

    def private servicesEntityFactories(Application it) '''
        # Entity factory classes
        «FOR entity : entities»
            «modPrefix».«entity.name.formatForCode»_factory:
                class: «appNamespace»\Entity\Factory\«entity.name.formatForCodeCapital»Factory
                arguments:
                    - "@«entityManagerService»"
                    - «appNamespace»\Entity\«entity.name.formatForCodeCapital»Entity

        «ENDFOR»
    '''

    def private eventSubscriber(Application it) '''
        services:
            «servicesEventSubscriber»
    '''

    def private servicesEventSubscriber(Application it) '''
        # Event subscriber and listener classes
        «modPrefix».entity_lifecycle_listener:
            class: «appNamespace»\Listener\EntityLifecycleListener
            tags:
                - { name: doctrine.event_subscriber }

        «FOR className : getSubscriberNames»
            «modPrefix».«className.toLowerCase»_listener:
                class: «appNamespace»\Listener\«className»Listener
                tags:
                    - { name: kernel.event_subscriber }

        «ENDFOR»
    '''

    def private getSubscriberNames(Application it) {
        var listeners = newArrayList(
            'Core', 'Kernel', 'Installer', 'ModuleDispatch', 'Mailer', 'Page', 'Theme', 'View',
            'UserLogin', 'UserLogout', 'User', 'UserRegistration', 'Users', 'Group')

        val needsDetailContentType = generateDetailContentType && hasDisplayActions
        if (generatePendingContentSupport || generateListContentType || needsDetailContentType) {
            listeners.add('ThirdParty')
        }

        listeners
    }

    def private formFields(Application it) '''
        services:
            «formFieldsHelper»
    '''

    def private formFieldsHelper(Application it) '''
        # Form field types
        «val nsBase = appNamespace + '\\Form\\Type\\'»
        «IF hasColourFields»

            «modPrefix».form.type.field.colour:
                class: «nsBase»Field\ColourType
                tags:
                    - { name: form.type }
        «ENDIF»
        «IF hasGeographical»

            «modPrefix».form.type.field.geo:
                class: «nsBase»Field\GeoType
                tags:
                    - { name: form.type }
        «ENDIF»
        «IF hasMultiListFields»

            «modPrefix».form.type.field.multilist:
                class: «nsBase»Field\MultiListType
                arguments:
                    - "@«modPrefix».listentries_helper"
                tags:
                    - { name: form.type }
        «ENDIF»
        «IF hasTrees»

            «modPrefix».form.type.field.entitytree:
                class: «nsBase»Field\EntityTreeType
                tags:
                    - { name: form.type }
        «ENDIF»
        «IF hasUploads»

            «modPrefix».form.type.field.upload:
                class: «nsBase»Field\UploadType
                arguments:
                    - "@translator.default"
                tags:
                    - { name: form.type }
        «ENDIF»
        «IF hasUserFields»

            «modPrefix».form.type.field.user:
                class: «nsBase»Field\UserType
                tags:
                    - { name: form.type }
        «ENDIF»
        «IF needsAutoCompletion»

            «modPrefix».form.type.field.autocompletionrelation:
                class: «nsBase»Field\AutoCompletionRelationType
                arguments:
                    - "@translator.default"
                    - "@«entityManagerService»"
                tags:
                    - { name: form.type }
        «ENDIF»
    '''

    def private forms(Application it) '''
        services:
            «formsHelper»
    '''

    def private formsHelper(Application it) '''
        # Form types
        «val nsBase = appNamespace + '\\Form\\Type\\'»
        «IF hasViewActions»
            «FOR entity : getAllEntities.filter[hasViewAction]»

                «modPrefix».form.type.«entity.name.formatForDB»quicknav:
                    class: «nsBase»QuickNavigation\«entity.name.formatForCodeCapital»QuickNavType
                    arguments:
                        - "@translator.default"
                        - "@request_stack"
                        «IF entity.hasListFieldsEntity»
                            - "@«modPrefix».listentries_helper"
                        «ENDIF»
                        «IF needsFeatureActivationHelper»
                            - "@«modPrefix».feature_activation_helper"
                        «ENDIF»
                    tags:
                        - { name: form.type }
            «ENDFOR»
        «ENDIF»
        «IF hasEditActions»
            «FOR entity : entities.filter[e|e instanceof MappedSuperClass || (e as Entity).hasEditAction]»
                «IF entity instanceof Entity»

                    «modPrefix».form.handler.«entity.name.formatForDB»:
                        class: «nsBase.replace('Type\\', '')»Handler\«entity.name.formatForCodeCapital»\EditHandler
                        arguments:
                            - "@service_container"
                            - "@translator.default"
                            - "@request_stack"
                            - "@router"
                        tags:
                            - { name: form.type }
                «ENDIF»

                «modPrefix».form.type.«entity.name.formatForDB»:
                    class: «nsBase»«entity.name.formatForCodeCapital»Type
                    arguments:
                        - "@translator.default"
                        - "@«modPrefix».«entity.name.formatForCode»_factory"
                        «IF entity instanceof Entity && (entity as Entity).hasTranslatableFields»
                            - "@zikula_extensions_module.api.variable"
                            - "@«modPrefix».translatable_helper"
                        «ENDIF»
                        «IF entity.hasListFieldsEntity»
                            - "@«modPrefix».listentries_helper"
                        «ENDIF»
                        «IF needsFeatureActivationHelper»
                            - "@«modPrefix».feature_activation_helper"
                        «ENDIF»
                    tags:
                        - { name: form.type }
            «ENDFOR»
        «ENDIF»
        «IF hasDeleteActions»

            «modPrefix».form.type.deleteentity:
                class: «nsBase.replace('Type\\', '')»DeleteEntityType
                arguments:
                    - "@translator.default"
                tags:
                    - { name: form.type }
        «ENDIF»
        «IF generateListBlock»

            «modPrefix».form.type.block.itemlist:
                class: «nsBase.replace('Form\\Type\\', '')»Block\Form\Type\ItemListBlockType
                arguments:
                    - "@translator.default"
                tags:
                    - { name: form.type }
        «ENDIF»
        «IF generateExternalControllerAndFinder»
            «FOR entity : getAllEntities»

                «modPrefix».form.type.«entity.name.formatForDB»finder:
                    class: «nsBase»Finder\«entity.name.formatForCodeCapital»FinderType
                    arguments:
                        - "@translator.default"
                        «IF needsFeatureActivationHelper»
                            - "@«modPrefix».feature_activation_helper"
                        «ENDIF»
                    tags:
                        - { name: form.type }
            «ENDFOR»
        «ENDIF»
        «IF needsConfig»

            «modPrefix».form.type.appsettings:
                class: «nsBase.replace('Type\\', '')»AppSettingsType
                arguments:
                    - "@translator.default"
                    - "@zikula_extensions_module.api.variable"
                    «IF hasUserGroupSelectors»
                        - "@zikula_groups_module.group_repository"
                    «ENDIF»
                tags:
                    - { name: form.type }
        «ENDIF»
    '''

    def private helpers(Application it) '''
        services:
            «servicesHelper»
    '''

    def private servicesHelper(Application it) '''
        # Helper classes
        «val nsBase = appNamespace + '\\Helper\\'»
        «IF hasAutomaticArchiving»
            «modPrefix».archive_helper:
                class: «nsBase»ArchiveHelper
                arguments:
                    - "@service_container"
                    - "@translator.default"
                    - "@session"
                    - "@logger"
                    - "@zikula_permissions_module.api.permission"
                    - "@«modPrefix».workflow_helper"
                    «IF hasHookSubscribers»
                        - "@«modPrefix».hook_helper"
                    «ENDIF»
        «ENDIF»
        «IF hasCategorisableEntities»
            «modPrefix».category_helper:
                class: «nsBase»CategoryHelper
                arguments:
                    - "@service_container"
                    - "@translator.default"
                    - "@session"
                    - "@logger"
                    - "@request_stack"
                    - "@zikula_users_module.current_user"
                    - "@zikula_categories_module.api.category_registry"
                    - "@zikula_categories_module.api.category_permission"

        «ENDIF»
        «modPrefix».controller_helper:
            class: «nsBase»ControllerHelper
            arguments:
                - "@service_container"
                - "@translator.default"
                «IF hasUploads»
                    - "@session"
                «ENDIF»
                «IF hasUploads || hasGeographical»
                    - "@logger"
                «ENDIF»
        «IF needsFeatureActivationHelper»

            «modPrefix».feature_activation_helper:
                class: «nsBase»FeatureActivationHelper
        «ENDIF»
        «IF hasHookSubscribers»

            «modPrefix».hook_helper:
                class: «nsBase»HookHelper
                arguments:
                    - "@hook_dispatcher"
        «ENDIF»
        «IF hasUploads»

            «modPrefix».image_helper:
                class: «nsBase»ImageHelper
                arguments:
                    - "@translator.default"
                    - "@session"
                    - "@zikula_extensions_module.api.variable"
        «ENDIF»
        «IF hasListFields»

            «modPrefix».listentries_helper:
                class: «nsBase»ListEntriesHelper
                arguments:
                    - "@translator.default"
        «ENDIF»

        «modPrefix».model_helper:
            class: «nsBase»ModelHelper
            arguments:
                - "@service_container"
        «IF needsApproval»

            «modPrefix».notification_helper:
                class: «nsBase»NotificationHelper
                arguments:
                    - "@translator.default"
                    - "@session"
                    - "@router"
                    - "@kernel"
                    - "@request_stack"
                    - "@zikula_extensions_module.api.variable"
                    - "@twig"
                    - "@zikula_mailer_module.api.mailer"
                    - "@«modPrefix».workflow_helper"
        «ENDIF»

        «modPrefix».selection_helper:
            class: «nsBase»SelectionHelper
            arguments:
                - "@service_container"
                - "@«entityManagerService»"
                - "@translator.default"
                - "@«modPrefix».controller_helper"
        «IF hasTranslatable»

            «modPrefix».translatable_helper:
                class: «nsBase»TranslatableHelper
                arguments:
                    - "@service_container"
                    - "@translator.default"
                    - "@request_stack"
                    - "@zikula_extensions_module.api.variable"
        «ENDIF»

        «modPrefix».view_helper:
            class: «nsBase»ViewHelper
            arguments:
                - "@service_container"
                - "@translator.default"

        «modPrefix».workflow_helper:
            class: «nsBase»WorkflowHelper
            arguments:
                - "@service_container"
                - "@translator.default"
    '''

    def private twig(Application it) '''
        services:
            «servicesTwig»
    '''

    def private servicesTwig(Application it) '''
        # Twig extension
        «val nsBase = appNamespace + '\\Twig\\'»
        «modPrefix».twig_extension:
            class: «nsBase»TwigExtension
            arguments:
                - "@translator.default"
                «IF hasTrees»
                    - "@router"
                «ENDIF»
                «IF generateIcsTemplates && hasEntitiesWithIcsTemplates»
                    - "@request_stack"
                «ENDIF»
                - "@zikula_extensions_module.api.variable"
                - "@«modPrefix».workflow_helper"
                «IF hasUploads»
                    - "@«modPrefix».view_helper"
                «ENDIF»
                «IF hasListFields»
                    - "@«modPrefix».listentries_helper"
                «ENDIF»
            public: false
            tags:
                - { name: twig.extension }
    '''

    def private logger(Application it) '''
        services:
            «servicesLogger»
    '''

    def private servicesLogger(Application it) '''
        # Log processor
        «modPrefix».log.processor:
            class: Monolog\Processor\PsrLogMessageProcessor
            tags:
                - { name: monolog.processor }
    '''
}
