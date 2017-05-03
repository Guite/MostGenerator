package org.zikula.modulestudio.generator.cartridges.zclassic.controller

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.ArrayField
import de.guite.modulestudio.metamodel.AuthMethodType
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
        generateServiceFile(fsa, 'authentication', authentication)
        generateServiceFile(fsa, 'linkContainer', linkContainer)
        generateServiceFile(fsa, 'entityFactory', entityFactory)
        generateServiceFile(fsa, 'eventSubscriber', eventSubscriber)
        if (hasListFields) {
            generateServiceFile(fsa, 'validators', validators)
        }
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
          «IF authenticationMethod != AuthMethodType.NONE»
              - { resource: 'authentication.yml' }
          «ENDIF»
          - { resource: 'linkContainer.yml' }
          - { resource: 'entityFactory.yml' }
          - { resource: 'eventSubscriber.yml' }
        «IF hasListFields»
            «'  '»- { resource: 'validators.yml' }
        «ENDIF»
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

    def private authentication(Application it) '''
        services:
            «modPrefix».authentication_method.«name.formatForDB»_authentication
            class: «appNamespace»\AuthenticationMethod\«name.formatForCodeCapital»AuthenticationMethod
            arguments:
                - "@translator.default"
                - "@session"
                «IF authenticationMethod == AuthMethodType.REMOTE»
                    - '@request_stack'
                    - "@router"
                «ENDIF»
                - "@«modPrefix».entity_factory"
                - "@zikula_extensions_module.api.variable"
                - "@zikula_zauth_module.api.password"
            tags:
                - { name: zikula.authentication_method, alias: '«name.formatForDB»_authentication' }
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
        # Entity factory
        «modPrefix».entity_factory:
            class: «appNamespace»\Entity\Factory\EntityFactory
            arguments:
                - "@«entityManagerService»"
                - "@«modPrefix».entity_initialiser"
                - "@«modPrefix».collection_filter_helper"
                «IF hasTranslatable»
                    - "@«modPrefix».feature_activation_helper"
                «ENDIF»

        # Entity initialiser
        «modPrefix».entity_initialiser:
            class: «appNamespace»\Entity\Factory\EntityInitialiser
            «IF !getAllListFields.filter[name != 'workflowState'].empty || hasGeographical»
                arguments:
                «IF !getAllListFields.filter[name != 'workflowState'].empty»
                    - "@«modPrefix».listentries_helper"
                «ENDIF»
                «IF hasGeographical»
                    - "@=service('zikula_extensions_module.api.variable').get('«appName»', 'defaultLatitude', 0.00)"
                    - "@=service('zikula_extensions_module.api.variable').get('«appName»', 'defaultLongitude', 0.00)"
                «ENDIF»
            «ENDIF»
    '''

    def private eventSubscriber(Application it) '''
        services:
            «servicesEventSubscriber»
    '''

    def private servicesEventSubscriber(Application it) '''
        # Event subscribers and listeners
        «modPrefix».entity_lifecycle_listener:
            class: «appNamespace»\Listener\EntityLifecycleListener
            arguments:
                - "@service_container"
                - "@event_dispatcher"
                - "@logger"
                «IF !targets('1.5')»
                    - "@translator.default"
                «ENDIF»
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
        «IF targets('1.5')»
            «modPrefix».workflow_events_listener:
                class: «appNamespace»\Listener\WorkflowEventsListener
                arguments:
                    - "@zikula_permissions_module.api.permission"
                    «IF needsApproval»
                        - "@«modPrefix».notification_helper"
                    «ENDIF»
                tags:
                    - { name: kernel.event_subscriber }

        «ENDIF»
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
            'Kernel', 'Installer', 'ModuleDispatch', 'Mailer', 'Theme',
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

    def private validators(Application it) '''
        services:
            «validatorServices»
    '''

    def private validatorServices(Application it) '''
        # Custom validators
        «modPrefix».validator.list_entry.validator:
            class: «appNamespace»\Validator\Constraints\ListEntryValidator
            arguments:
                - "@translator.default"
                - "@«modPrefix».listentries_helper"
            tags:
                - { name: validator.constraint_validator, alias: «modPrefix».validator.list_entry.validator }
    '''

    def private formFields(Application it) '''
        services:
            «formFieldsHelper»
    '''

    def private formFieldsHelper(Application it) '''
        # Form field types
        «val nsBase = appNamespace + '\\Form\\Type\\'»
        «IF !entities.filter[e|!e.fields.filter(ArrayField).empty].empty»

            «modPrefix».form.type.field.array:
                class: «nsBase»Field\ArrayType
                tags:
                    - { name: form.type }
        «ENDIF»
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
        «IF hasTranslatable»

            «modPrefix».form.type.field.translation:
                class: «nsBase»Field\TranslationType
                tags:
                    - { name: form.type }
        «ENDIF»
        «IF hasTrees»

            «modPrefix».form.type.field.entitytree:
                class: «nsBase»Field\EntityTreeType
                arguments:
                    - "@«modPrefix».entity_display_helper"
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
                    - "@router"
                    - "@«modPrefix».entity_factory"
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
                            - "@«modPrefix».entity_display_helper"
                        «ENDIF»
                        «IF entity.hasListFieldsEntity»
                            - "@«modPrefix».listentries_helper"
                        «ENDIF»
                        «IF entity.hasLocaleFieldsEntity»
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
                        «IF !entity.incoming.empty || !entity.outgoing.empty»
                            - "@«modPrefix».collection_filter_helper"
                            - "@«modPrefix».entity_display_helper"
                        «ENDIF»
                        «IF entity instanceof Entity && (entity as Entity).hasTranslatableFields»
                            - "@zikula_extensions_module.api.variable"
                            - "@«modPrefix».translatable_helper"
                        «ENDIF»
                        «IF entity.hasListFieldsEntity»
                            - "@«modPrefix».listentries_helper"
                        «ENDIF»
                        «IF entity.hasLocaleFieldsEntity»
                            - "@zikula_settings_module.locale_api"
                        «ENDIF»
                        «IF needsFeatureActivationHelper»
                            - "@«modPrefix».feature_activation_helper"
                        «ENDIF»
                    tags:
                        - { name: form.type }
            «ENDFOR»
        «ENDIF»
        «IF hasDeleteActions && !targets('1.5')»

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
            «FOR entity : getAllEntities.filter[hasDisplayAction]»

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

            «modPrefix».form.type.config:
                class: «nsBase»ConfigType
                arguments:
                    - "@translator.default"
                    - "@=service('zikula_extensions_module.api.variable').getAll('«appName»')"
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
        # Helper services
        «val nsBase = appNamespace + '\\Helper\\'»
        «IF hasAutomaticArchiving»
            «modPrefix».archive_helper:
                class: «nsBase»ArchiveHelper
                arguments:
                    - "@translator.default"
                    - "@request_stack"
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
                    - "@request_stack"
                    - "@logger"
                    - "@zikula_users_module.current_user"
                    «IF targets('1.5')»
                        - "@zikula_categories_module.category_registry_repository"
                    «ELSE»
                        - "@zikula_categories_module.api.category_registry"
                    «ENDIF»
                    - "@zikula_categories_module.api.category_permission"

        «ENDIF»
        «modPrefix».collection_filter_helper:
            class: «nsBase»CollectionFilterHelper
            arguments:
                - "@request_stack"
                «IF hasStandardFieldEntities»
                    - "@zikula_users_module.current_user"
                «ENDIF»
                «IF hasCategorisableEntities»
                    - "@«modPrefix».category_helper"
                «ENDIF»
                - "@=service('zikula_extensions_module.api.variable').get('«appName»', 'showOnlyOwnEntries', false)"
                «IF supportLocaleFilter»
                    - "@=service('zikula_extensions_module.api.variable').get('«appName»', 'filterDataByLocale', false)"
                «ENDIF»

        «modPrefix».controller_helper:
            class: «nsBase»ControllerHelper
            arguments:
                «IF hasUploads»
                    - "@translator.default"
                «ENDIF»
                - "@request_stack"
                «IF hasAutomaticArchiving»
                    - "@«modPrefix».archive_helper"
                «ENDIF»
                «IF hasUploads || hasGeographical»
                    - "@logger"
                «ENDIF»
                «IF hasViewActions»
                    - "@form.factory"
                «ENDIF»
                «IF hasViewActions || hasGeographical»
                    - "@zikula_extensions_module.api.variable"
                «ENDIF»
                «IF hasGeographical»
                    - "@zikula_users_module.current_user"
                «ENDIF»
                - "@«modPrefix».entity_factory"
                - "@«modPrefix».collection_filter_helper"
                «IF hasViewActions && hasEditActions»
                    - "@«modPrefix».model_helper"
                «ENDIF»
                «IF hasUploads»
                    - "@«modPrefix».image_helper"
                «ENDIF»
                «IF needsFeatureActivationHelper»
                    - "@«modPrefix».feature_activation_helper"
                «ENDIF»

        «modPrefix».entity_display_helper:
            class: «nsBase»EntityDisplayHelper
            arguments:
                - "@translator.default"
                «IF hasAbstractDateFields || hasDecimalOrFloatNumberFields»
                    - "@request_stack"
                «ENDIF»
                «IF hasListFields»
                    - "@«modPrefix».listentries_helper"
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
                    - "@«modPrefix».entity_display_helper"
                    - "@«modPrefix».workflow_helper"
        «ENDIF»
        «IF generateSearchApi»

            «modPrefix».search_helper:
                class: «nsBase»SearchHelper
                arguments:
                    - "@translator.default"
                    - "@zikula_permissions_module.api.permission"
                    «IF !targets('1.5')»
                        - "@templating.engine.twig"
                    «ENDIF»
                    - "@session"
                    - "@request_stack"
                    - "@«modPrefix».entity_factory"
                    - "@«modPrefix».controller_helper"
                    - "@«modPrefix».entity_display_helper"
                    «IF hasCategorisableEntities»
                        - "@«modPrefix».feature_activation_helper"
                        - "@«modPrefix».category_helper"
                    «ENDIF»
                tags:
                    - { name: zikula.searchable_module, bundleName: «appName» }
        «ENDIF»
        «IF hasTranslatable»

            «modPrefix».translatable_helper:
                class: «nsBase»TranslatableHelper
                arguments:
                    - "@translator.default"
                    - "@request_stack"
                    - "@zikula_extensions_module.api.variable"
                    - "@zikula_settings_module.locale_api"
                    - "@«modPrefix».entity_factory"
        «ENDIF»
        «IF hasUploads»

            «modPrefix».upload_helper:
                class: «nsBase»UploadHelper
                arguments:
                    - "@translator.default"
                    - "@session"
                    - "@liip_imagine.cache.manager"
                    - "@logger"
                    - "@zikula_users_module.current_user"
                    - "@=service('zikula_extensions_module.api.variable').getAll('«appName»')"
                    - "%datadir%"
        «ENDIF»

        «modPrefix».view_helper:
            class: «nsBase»ViewHelper
            arguments:
                - "@twig"
                - "@twig.loader"
                - "@request_stack"
                - "@zikula_permissions_module.api.permission"
                - "@zikula_extensions_module.api.variable"
                - "@zikula_core.common.theme.pagevars"
                - "@«modPrefix».controller_helper"

        «modPrefix».workflow_helper:
            class: «nsBase»WorkflowHelper
            arguments:
                - "@translator.default"
                «IF targets('1.5')»
                    - "@workflow.registry"
                «ENDIF»
                «IF targets('1.5') || needsApproval»
                    - "@logger"
                    - "@zikula_permissions_module.api.permission"
                    «IF targets('1.5')»
                        - "@zikula_users_module.current_user"
                    «ENDIF»
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
                «IF needsUserAvatarSupport»
                    - "@zikula_users_module.user_repository"
                «ENDIF»
                «IF hasTrees»
                    - "@«modPrefix».entity_factory"
                «ENDIF»
                - "@«modPrefix».entity_display_helper"
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
