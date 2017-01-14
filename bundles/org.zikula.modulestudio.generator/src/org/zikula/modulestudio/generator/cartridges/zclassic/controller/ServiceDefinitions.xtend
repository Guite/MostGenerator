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
        generateServiceFile(fsa, 'linkContainer', linkContainer)
        generateServiceFile(fsa, 'entityFactory', entityFactory)
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
          - { resource: 'linkContainer.yml' }
          - { resource: 'entityFactory.yml' }
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

    def private linkContainer(Application it) '''
        services:
            «modPrefix».link_container:
                class: «appNamespace»\Container\LinkContainer
                arguments:
                    - "@translator.default"
                    - "@router"
                    - "@zikula_permissions_module.api.permission"
                    «IF generateAccountApi»
                        - "@zikula_extensions_module.api.variable"
                    «ENDIF»
                    «IF generateAccountApi || hasEditActions»
                        - "@zikula_users_module.current_user"
                    «ENDIF»
                    - "@«modPrefix».controller_helper"
                tags:
                    - { name: zikula.link_container }
    '''

    def private entityFactory(Application it) '''
        services:
            «servicesEntityFactory»
    '''

    def private servicesEntityFactory(Application it) '''
        # Entity factory class
        «modPrefix».entity_factory:
            class: «appNamespace»\Entity\Factory\«name.formatForCodeCapital»Factory
            arguments:
                - "@«entityManagerService»"
    '''

    def private eventSubscriber(Application it) '''
        services:
            «servicesEventSubscriber»
    '''

    def private servicesEventSubscriber(Application it) '''
        # Event subscriber and listener classes
        «modPrefix».entity_lifecycle_listener:
            class: «appNamespace»\Listener\EntityLifecycleListener
            arguments:
                - "@service_container"
            tags:
                - { name: doctrine.event_subscriber }

        «FOR className : getSubscriberNames»
            «modPrefix».«className.toLowerCase»_listener:
                class: «appNamespace»\Listener\«className»Listener
                «IF className == 'ThirdParty' && needsApproval && generatePendingContentSupport»
                    arguments:
                        - "@«modPrefix».workflow_helper"
                «ELSEIF className == 'User' && (hasStandardFieldEntities || hasUserFields)»
                    arguments:
                        - "@translator.default"
                        - "@«modPrefix».entity_factory"
                        - "@zikula_users_module.current_user"
                        - "@logger"
                «ELSEIF className == 'IpTrace'»
                    arguments:
                        - "@gedmo_doctrine_extensions.listener.ip_traceable"
                        - "@request_stack"
                «ENDIF»
                tags:
                    - { name: kernel.event_subscriber }

        «ENDFOR»
        «IF getSubscriberNames.contains('IpTrace')»
            gedmo_doctrine_extensions.listener.ip_traceable:
                class: Gedmo\IpTraceable\IpTraceableListener
                public: false
                calls:
                    - [setAnnotationReader, ["@annotation_reader"]]
                tags:
                    - { name: doctrine.event_subscriber, connection: default }

        «ENDIF»
    '''

    def private getSubscriberNames(Application it) {
        var listeners = newArrayList(
            'Core', 'Kernel', 'Installer', 'ModuleDispatch', 'Mailer', 'Page', 'Theme', 'View',
            'UserLogin', 'UserLogout', 'User', 'UserRegistration', 'Users', 'Group')

        val needsDetailContentType = generateDetailContentType && hasDisplayActions
        if (generatePendingContentSupport || generateListContentType || needsDetailContentType) {
            listeners.add('ThirdParty')
        }
        if (!getAllEntities.filter[hasIpTraceableFields].empty) {
            listeners.add('IpTrace')
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
                    - "@request_stack"
                    - "@«modPrefix».image_helper"
                    - "@«modPrefix».upload_helper"
                tags:
                    - { name: form.type }
        «ENDIF»
        «IF needsUserAutoCompletion»

            «modPrefix».form.type.field.user:
                class: «nsBase»Field\UserType
                arguments:
                    - "@zikula_users_module.user_repository"
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
                        «IF !entity.getBidirectionalIncomingJoinRelationsWithOneSource.filter[source instanceof Entity].empty»
                            - "@request_stack"
                        «ENDIF»
                        «IF entity.hasListFieldsEntity»
                            - "@«modPrefix».listentries_helper"
                        «ENDIF»
                        «IF entity.hasLocaleFieldsEntity && targets('1.4-dev')»
                            - "@zikula_settings_module.locale_api"
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
                            - "@kernel"
                            - "@translator.default"
                            - "@form.factory"
                            - "@request_stack"
                            - "@router"
                            - "@logger"
                            - "@zikula_permissions_module.api.permission"
                            «IF hasTranslatable || needsApproval»
                                - "@zikula_extensions_module.api.variable"
                            «ENDIF»
                            - "@zikula_users_module.current_user"
                            «IF needsApproval»
                                - "@zikula_groups_module.group_application_repository"
                            «ENDIF»
                            - "@«modPrefix».entity_factory"
                            - "@«modPrefix».controller_helper"
                            - "@«modPrefix».model_helper"
                            - "@«modPrefix».selection_helper"
                            - "@«modPrefix».workflow_helper"
                            «IF hasHookSubscribers»
                                - "@«modPrefix».hook_helper"
                            «ENDIF»
                            «IF hasTranslatable»
                                - "@«modPrefix».translatable_helper"
                            «ENDIF»
                            «IF needsFeatureActivationHelper»
                                - "@«modPrefix».feature_activation_helper"
                            «ENDIF»
                        calls:
                            - [setLockingApi, ["@?zikula_pagelock_module.api.locking"]]
                        tags:
                            - { name: form.type }
                «ENDIF»

                «modPrefix».form.type.«entity.name.formatForDB»:
                    class: «nsBase»«entity.name.formatForCodeCapital»Type
                    arguments:
                        - "@translator.default"
                        - "@«modPrefix».entity_factory"
                        «IF entity instanceof Entity && (entity as Entity).hasTranslatableFields»
                            - "@zikula_extensions_module.api.variable"
                            - "@«modPrefix».translatable_helper"
                        «ENDIF»
                        «IF entity.hasListFieldsEntity»
                            - "@«modPrefix».listentries_helper"
                        «ENDIF»
                        «IF entity.hasLocaleFieldsEntity && targets('1.4-dev')»
                            - "@zikula_settings_module.locale_api"
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
                    - "@translator.default"
                    - "@session"
                    - "@logger"
                    - "@zikula_permissions_module.api.permission"
                    - "@«modPrefix».entity_factory"
                    - "@«modPrefix».workflow_helper"
                    «IF hasHookSubscribers»
                        - "@«modPrefix».hook_helper"
                    «ENDIF»

        «ENDIF»
        «IF hasCategorisableEntities»
            «modPrefix».category_helper:
                class: «nsBase»CategoryHelper
                arguments:
                    - "@translator.default"
                    - "@session"
                    - "@request_stack"
                    - "@logger"
                    - "@zikula_users_module.current_user"
                    - "@zikula_categories_module.api.category_registry"
                    - "@zikula_categories_module.api.category_permission"

        «ENDIF»
        «modPrefix».controller_helper:
            class: «nsBase»ControllerHelper
            arguments:
                «IF hasUploads»
                    - "@translator.default"
                «ENDIF»
                - "@request_stack"
                «IF hasUploads»
                    - "@session"
                «ENDIF»
                «IF hasUploads || hasGeographical»
                    - "@logger"
                «ENDIF»
                «IF hasViewActions»
                    - "@form.factory"
                    - "@zikula_extensions_module.api.variable"
                «ENDIF»
                «IF hasGeographical»
                    - "@zikula_users_module.current_user"
                «ENDIF»
                - "@«modPrefix».entity_factory"
                «IF hasViewActions && hasEditActions»
                    - "@«modPrefix».model_helper"
                «ENDIF»
                - "@«modPrefix».selection_helper"
                «IF hasUploads»
                    - "@«modPrefix».image_helper"
                «ENDIF»
                «IF needsFeatureActivationHelper»
                    - "@«modPrefix».feature_activation_helper"
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
                - "@«modPrefix».entity_factory"
        «IF needsApproval»

            «modPrefix».notification_helper:
                class: «nsBase»NotificationHelper
                arguments:
                    - "@kernel"
                    - "@translator.default"
                    - "@session"
                    - "@router"
                    - "@request_stack"
                    - "@zikula_extensions_module.api.variable"
                    - "@twig"
                    - "@zikula_mailer_module.api.mailer"
                    - "@zikula_groups_module.group_repository"
                    - "@zikula_users_module.user_repository"
                    - "@«modPrefix».workflow_helper"
        «ENDIF»

        «modPrefix».selection_helper:
            class: «nsBase»SelectionHelper
            arguments:
                - "@translator.default"
                - "@«modPrefix».entity_factory"
        «IF hasTranslatable»

            «modPrefix».translatable_helper:
                class: «nsBase»TranslatableHelper
                arguments:
                    - "@translator.default"
                    - "@request_stack"
                    - "@zikula_extensions_module.api.variable"
                    «IF targets('1.4-dev')»
                        - "@zikula_settings_module.locale_api"
                    «ENDIF»
                    - "@«modPrefix».entity_factory"
        «ENDIF»
        «IF hasUploads»

            «modPrefix».upload_helper:
                class: «nsBase»UploadHelper
                arguments:
                    - "@translator.default"
                    - "@session"
                    - "@logger"
                    - "@zikula_users_module.current_user"
                    - "@zikula_extensions_module.api.variable"
                    - "%datadir%"
        «ENDIF»

        «modPrefix».view_helper:
            class: «nsBase»ViewHelper
            arguments:
                - "@templating"«/* this does not use "@twig" on purpose */»
                - "@request_stack"
                - "@zikula_permissions_module.api.permission"
                - "@zikula_extensions_module.api.variable"
                - "@«modPrefix».controller_helper"

        «modPrefix».workflow_helper:
            class: «nsBase»WorkflowHelper
            arguments:
                - "@translator.default"
                «IF needsApproval»
                    - "@logger"
                    - "@zikula_permissions_module.api.permission"
                    - "@«modPrefix».entity_factory"
                «ENDIF»
                - "@«modPrefix».listentries_helper"
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
