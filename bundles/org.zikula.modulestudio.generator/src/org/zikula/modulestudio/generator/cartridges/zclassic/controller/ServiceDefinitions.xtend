package org.zikula.modulestudio.generator.cartridges.zclassic.controller

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.ArrayField
import de.guite.modulestudio.metamodel.AuthMethodType
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.HookProviderMode
import de.guite.modulestudio.metamodel.ListField
import de.guite.modulestudio.metamodel.MappedSuperClass
import de.guite.modulestudio.metamodel.StringField
import de.guite.modulestudio.metamodel.StringRole
import de.guite.modulestudio.metamodel.UploadField
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.DateTimeExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
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
    extension DateTimeExtensions = new DateTimeExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelJoinExtensions = new ModelJoinExtensions
    extension ModelExtensions = new ModelExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils
    extension WorkflowExtensions = new WorkflowExtensions

    IMostFileSystemAccess fsa
    String modPrefix = ''
    Boolean needsDetailContentType

    def private generateServiceFile(Application it, String fileName, CharSequence content) {
        val definitionFilePath = getResourcesPath + 'config/' + fileName + '.yml'
        fsa.generateFile(definitionFilePath, content)
    }

    /**
     * Entry point for service definitions.
     * This generates YAML files describing DI configuration.
     */
    def generate(Application it, IMostFileSystemAccess fsa) {
        this.fsa = fsa
        modPrefix = appService
        needsDetailContentType = generateDetailContentType && hasDisplayActions

        generateServiceFile('services', mainServiceFile)
        if (authenticationMethod != AuthMethodType.NONE) {
            generateServiceFile('authentication', authentication)
        }
        if (!variables.empty) {
            generateServiceFile('appSettings', appSettings)
        }
        generateServiceFile('menu', menu)
        generateServiceFile('entityFactory', entityFactory)
        generateServiceFile('eventSubscriber', eventSubscriber)
        if (hasListFields) {
            generateServiceFile('validators', validators)
        }
        if (hasEditActions || needsConfig) {
            generateServiceFile('formFields', formFields)
        }
        generateServiceFile('forms', forms)
        generateServiceFile('helpers', helpers)
        if (hasHookSubscribers || hasHookProviders) {
            generateServiceFile('hooks', hooks)
        }
        generateServiceFile('twig', twig)
        generateServiceFile('logger', logger)
        if (targets('2.0') && (generateListContentType || needsDetailContentType)) {
            generateServiceFile('contentTypes', contentTypes)
        }
    }

    def private mainServiceFile(Application it) '''
        imports:
          «IF authenticationMethod != AuthMethodType.NONE»
              - { resource: 'authentication.yml' }
          «ENDIF»
          «IF !variables.empty»
              - { resource: 'appSettings.yml' }
          «ENDIF»
          - { resource: 'menu.yml' }
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
        «IF hasHookSubscribers || hasHookProviders»
            «'  '»- { resource: 'hooks.yml' }
        «ENDIF»
          - { resource: 'twig.yml' }
          - { resource: 'logger.yml' }
        «IF targets('2.0') && (generateListContentType || needsDetailContentType)»
            «'  '»- { resource: 'contentTypes.yml' }
        «ENDIF»
        «IF hasImageFields || !getAllVariables.filter(UploadField).filter[isImageField].empty»

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
                    - "@request_stack"
                    - "@router"
                «ENDIF»
                - "@«modPrefix».entity_factory"
                - "@zikula_extensions_module.api.variable"
                - "@zikula_zauth_module.api.password"
            tags:
                - { name: zikula.authentication_method, alias: '«name.formatForDB»_authentication' }
    '''

    def private appSettings(Application it) '''
        services:
            «modPrefix».app_settings:
                class: «appNamespace»\AppSettings
                arguments:
                    - "@zikula_extensions_module.api.variable"
                    «IF hasUserVariables»
                        - "@zikula_users_module.user_repository"
                    «ENDIF»
                    «IF hasUserGroupSelectors»
                        - "@zikula_groups_module.group_repository"
                    «ENDIF»
                    «IF hasLoggable»
                        - "@«modPrefix».entity_factory"
                    «ENDIF»
    '''

    def private menu(Application it) '''
        services:
            «modPrefix».link_container:
                class: «appNamespace»\Container\LinkContainer
                arguments:
                    - "@translator.default"
                    - "@router"
                    «IF generateAccountApi»
                        - "@zikula_extensions_module.api.variable"
                    «ENDIF»
                    - "@«modPrefix».controller_helper"
                    - "@«modPrefix».permission_helper"
                «IF targets('2.0')»
                    tags: ['zikula.link_container']
                «ELSE»
                    tags:
                        - { name: zikula.link_container }
                «ENDIF»
            «modPrefix».menu_builder:
                class: «appNamespace»\Menu\MenuBuilder
                arguments:
                    - "@translator.default"
                    - "@knp_menu.factory"
                    - "@event_dispatcher"
                    - "@request_stack"
                    - "@«modPrefix».permission_helper"
                    «IF hasDisplayActions»
                        - "@«modPrefix».entity_display_helper"
                    «ENDIF»
                    «IF hasLoggable»
                        - "@«modPrefix».loggable_helper"
                    «ENDIF»
                    - "@zikula_users_module.current_user"
                tags:
                    - { name: knp_menu.menu_builder, method: createItemActionsMenu, alias: «vendorAndName.toFirstLower»MenuItemActions }
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
            «IF supportLocaleFilter || !getAllListFields.filter[name != 'workflowState'].empty || hasGeographical»
                arguments:
                    «IF supportLocaleFilter»
                        - "@request_stack"
                    «ENDIF»
                    - "@«modPrefix».permission_helper"
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
            «IF targets('2.0')»
                tags: ['doctrine.event_subscriber']
            «ELSE»
                tags:
                    - { name: doctrine.event_subscriber }
            «ENDIF»

        «FOR className : getSubscriberNames»
            «modPrefix».«className.toLowerCase»_listener:
                class: «appNamespace»\Listener\«className»Listener
                «IF className == 'Installer' && (amountOfExampleRows > 0 || hasUiHooksProviders)»
                    arguments:
                        «IF amountOfExampleRows > 0»
                            - "@«modPrefix».example_data_helper"
                        «ENDIF»
                        «IF hasUiHooksProviders»
                            - "@«modPrefix».entity_factory"
                        «ENDIF»
                «ELSEIF className == 'ThirdParty' && (generateScribitePlugins || (needsApproval && generatePendingContentSupport))»
                    arguments:
                        «IF generateScribitePlugins»
                            - "@filesystem"
                            - "@request_stack"
                        «ENDIF»
                        «IF needsApproval && generatePendingContentSupport»
                            - "@«modPrefix».workflow_helper"
                        «ENDIF»
                «ELSEIF className == 'User' && (hasStandardFieldEntities || hasUserFields || hasUserVariables)»
                    arguments:
                        «IF hasStandardFieldEntities || hasUserFields»
                        - "@translator.default"
                        - "@«modPrefix».entity_factory"
                        - "@zikula_users_module.current_user"
                        - "@logger"
                        «ENDIF»
                        «IF hasUserVariables»
                        - "@zikula_extensions_module.api.variable"
                        «ENDIF»
                «ELSEIF className == 'IpTrace'»
                    arguments:
                        - "@gedmo_doctrine_extensions.listener.ip_traceable"
                        - "@request_stack"
                «ELSEIF className == 'Loggable'»
                    arguments:
                        - "@«modPrefix».entity_display_helper"
                        - "@«modPrefix».loggable_helper"
                «ENDIF»
                «IF className != 'Loggable'»
                    «IF targets('2.0')»
                        tags: ['kernel.event_subscriber']
                    «ELSE»
                        tags:
                            - { name: kernel.event_subscriber }
                    «ENDIF»
                «ENDIF»

        «ENDFOR»
        «modPrefix».workflow_events_listener:
            class: «appNamespace»\Listener\WorkflowEventsListener
            arguments:
                - "@«modPrefix».entity_factory"
                - "@«modPrefix».permission_helper"
                «IF needsApproval»
                    - "@«modPrefix».notification_helper"
                «ENDIF»
            «IF targets('2.0')»
                tags: ['kernel.event_subscriber']
            «ELSE»
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
        «IF hasSluggable»
            stof_doctrine_extensions.listener.sluggable:
                class: '%stof_doctrine_extensions.listener.sluggable.class%'
                tags:
                    - { name: doctrine.event_subscriber, connection: default }
                calls:
                    - [ setAnnotationReader, ["@annotation_reader"] ]
                    - [ setTransliterator, [[«appNamespace»\Helper\SlugTransliterator, 'transliterate']]]

        «ENDIF»
    '''

    def private getSubscriberNames(Application it) {
        var listeners = newArrayList(
            'Kernel', 'Installer', 'ModuleDispatch', 'Mailer', 'Theme',
            'UserLogin', 'UserLogout', 'User', 'UserRegistration', 'Users', 'Group')

        val needsDetailContentType = generateDetailContentType && hasDisplayActions
        if ((needsApproval && generatePendingContentSupport) || ((generateListContentType || needsDetailContentType) && !targets('2.0')) || generateScribitePlugins) {
            listeners += 'ThirdParty'
        }
        if (!getAllEntities.filter[hasIpTraceableFields].empty) {
            listeners += 'IpTrace'
        }
        if (hasLoggable) {
            listeners += 'Loggable'
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
        «IF !entities.filter[e|!e.fields.filter(ArrayField).empty].empty || !getAllVariables.filter(ArrayField).empty»

            «modPrefix».form.type.field.array:
                class: «nsBase»Field\ArrayType
                «IF targets('2.0')»
                    tags: ['form.type']
                «ELSE»
                    tags:
                        - { name: form.type }
                «ENDIF»
        «ENDIF»
        «IF hasColourFields && !targets('2.0')»

            «modPrefix».form.type.field.colour:
                class: «nsBase»Field\ColourType
                «IF targets('2.0')»
                    tags: ['form.type']
                «ELSE»
                    tags:
                        - { name: form.type }
                «ENDIF»
        «ENDIF»
        «IF hasGeographical»

            «modPrefix».form.type.field.geo:
                class: «nsBase»Field\GeoType
                «IF targets('2.0')»
                    tags: ['form.type']
                «ELSE»
                    tags:
                        - { name: form.type }
                «ENDIF»
        «ENDIF»
        «IF hasMultiListFields || !getAllVariables.filter(ListField).filter[multiple].empty»

            «modPrefix».form.type.field.multilist:
                class: «nsBase»Field\MultiListType
                arguments:
                    - "@«modPrefix».listentries_helper"
                «IF targets('2.0')»
                    tags: ['form.type']
                «ELSE»
                    tags:
                        - { name: form.type }
                «ENDIF»
        «ENDIF»
        «IF hasTelephoneFields && !targets('2.0')»

            «modPrefix».form.type.field.tel:
                class: «nsBase»Field\TelType
                «IF targets('2.0')»
                    tags: ['form.type']
                «ELSE»
                    tags:
                        - { name: form.type }
                «ENDIF»
        «ENDIF»
        «IF hasTranslatable»

            «modPrefix».form.type.field.translation:
                class: «nsBase»Field\TranslationType
                «IF targets('2.0')»
                    tags: ['form.type']
                «ELSE»
                    tags:
                        - { name: form.type }
                «ENDIF»
        «ENDIF»
        «IF hasTrees»

            «modPrefix».form.type.field.entitytree:
                class: «nsBase»Field\EntityTreeType
                arguments:
                    - "@«modPrefix».entity_display_helper"
                «IF targets('2.0')»
                    tags: ['form.type']
                «ELSE»
                    tags:
                        - { name: form.type }
                «ENDIF»
        «ENDIF»
        «IF hasUploads»

            «modPrefix».form.type.field.upload:
                class: «nsBase»Field\UploadType
                arguments:
                    - "@translator.default"
                    - "@«modPrefix».image_helper"
                    - "@«modPrefix».upload_helper"
                «IF targets('2.0')»
                    tags: ['form.type']
                «ELSE»
                    tags:
                        - { name: form.type }
                «ENDIF»
        «ENDIF»
        «IF hasAutoCompletionRelation»

            «modPrefix».form.type.field.autocompletionrelation:
                class: «nsBase»Field\AutoCompletionRelationType
                arguments:
                    - "@router"
                    - "@«modPrefix».entity_factory"
                «IF targets('2.0')»
                    tags: ['form.type']
                «ELSE»
                    tags:
                        - { name: form.type }
                «ENDIF»
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
                    «IF targets('2.0')»
                        tags: ['form.type']
                    «ELSE»
                        tags:
                            - { name: form.type }
                    «ENDIF»
            «ENDFOR»
        «ENDIF»
        «IF hasEditActions»

            «modPrefix».form.handler.common:
                abstract: true
                arguments:
                    - "@kernel"
                    - "@translator.default"
                    - "@form.factory"
                    - "@request_stack"
                    - "@router"
                    - "@logger"
                    «IF hasTranslatable || needsApproval || hasStandardFieldEntities»
                        - "@zikula_extensions_module.api.variable"
                    «ENDIF»
                    - "@zikula_users_module.current_user"
                    «IF needsApproval»
                        - "@zikula_groups_module.group_application_repository"
                    «ENDIF»
                    - "@«modPrefix».entity_factory"
                    - "@«modPrefix».controller_helper"
                    - "@«modPrefix».model_helper"
                    - "@«modPrefix».permission_helper"
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

            «FOR entity : entities.filter[it instanceof MappedSuperClass || (it as Entity).hasEditAction]»
                «IF entity instanceof Entity»

                    «modPrefix».form.handler.«entity.name.formatForDB»:
                        class: «nsBase.replace('Type\\', '')»Handler\«entity.name.formatForCodeCapital»\EditHandler
                        parent: «modPrefix».form.handler.common
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
                        «IF entity.hasUploadFieldsEntity»
                            - "@«modPrefix».upload_helper"
                        «ENDIF»
                        «IF entity.hasLocaleFieldsEntity»
                            - "@zikula_settings_module.locale_api"
                        «ENDIF»
                        «IF needsFeatureActivationHelper»
                            - "@«modPrefix».feature_activation_helper"
                        «ENDIF»
                    «IF targets('2.0')»
                        tags: ['form.type']
                    «ELSE»
                        tags:
                            - { name: form.type }
                    «ENDIF»
            «ENDFOR»
        «ENDIF»
        «IF generateListBlock»

            «modPrefix».form.type.block.itemlist:
                class: «nsBase.replace('Form\\Type\\', '')»Block\Form\Type\ItemListBlockType
                arguments:
                    - "@translator.default"
                    «IF hasCategorisableEntities»
                        - "@zikula_categories_module.category_repository"
                    «ENDIF»
                «IF targets('2.0')»
                    tags: ['form.type']
                «ELSE»
                    tags:
                        - { name: form.type }
                «ENDIF»
        «ENDIF»
        «IF generateDetailBlock && hasDisplayActions»

            «modPrefix».form.type.block.item:
                class: «nsBase.replace('Form\\Type\\', '')»Block\Form\Type\ItemBlockType
                arguments:
                    - "@translator.default"
                    - "@«modPrefix».entity_factory"
                    - "@«modPrefix».entity_display_helper"
                «IF targets('2.0')»
                    tags: ['form.type']
                «ELSE»
                    tags:
                        - { name: form.type }
                «ENDIF»
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
                    «IF targets('2.0')»
                        tags: ['form.type']
                    «ELSE»
                        tags:
                            - { name: form.type }
                    «ENDIF»
            «ENDFOR»
        «ENDIF»
        «IF needsConfig»

            «modPrefix».form.type.config:
                class: «nsBase»ConfigType
                arguments:
                    - "@translator.default"
                    «IF !getAllVariables.filter(ListField).empty»
                        - "@«modPrefix».listentries_helper"
                    «ENDIF»
                    «IF hasUploadVariables»
                        - "@«modPrefix».upload_helper"
                    «ENDIF»
                    «IF !getAllVariables.filter(StringField).filter[role == StringRole.LOCALE].empty»
                        - "@zikula_settings_module.locale_api"
                    «ENDIF»
                «IF targets('2.0')»
                    tags: ['form.type']
                «ELSE»
                    tags:
                        - { name: form.type }
                «ENDIF»
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
                    - "@«modPrefix».entity_factory"
                    - "@«modPrefix».permission_helper"
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
                    - "@zikula_categories_module.category_registry_repository"
                    - "@zikula_categories_module.api.category_permission"

        «ENDIF»
        «modPrefix».collection_filter_helper:
            class: «nsBase»CollectionFilterHelper
            arguments:
                - "@request_stack"
                - "@«modPrefix».permission_helper"
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
                - "@translator.default"
                - "@request_stack"
                «IF hasAutomaticArchiving»
                    - "@«modPrefix».archive_helper"
                «ENDIF»
                «IF hasUiHooksProviders»
                    - "@router"
                «ENDIF»
                «IF hasViewActions»
                    - "@form.factory"
                «ENDIF»
                «IF hasViewActions»
                    - "@zikula_extensions_module.api.variable"
                «ENDIF»
                «IF hasGeographical»
                    - "@logger"
                    - "@zikula_users_module.current_user"
                «ENDIF»
                - "@«modPrefix».entity_factory"
                - "@«modPrefix».collection_filter_helper"
                - "@«modPrefix».permission_helper"
                «IF hasViewActions && hasEditActions»
                    - "@«modPrefix».model_helper"
                «ENDIF»
                «IF !getUploadEntities.empty»
                    - "@«modPrefix».image_helper"
                «ENDIF»
                «IF needsFeatureActivationHelper»
                    - "@«modPrefix».feature_activation_helper"
                «ENDIF»

        «modPrefix».entity_display_helper:
            class: «nsBase»EntityDisplayHelper
            arguments:
                - "@translator.default"
                «IF hasAnyDateTimeFields || hasNumberFields»
                    - "@request_stack"
                «ENDIF»
                «IF hasListFields»
                    - "@«modPrefix».listentries_helper"
                «ENDIF»
        «IF amountOfExampleRows > 0»

            «modPrefix».example_data_helper:
                class: «nsBase»ExampleDataHelper
                arguments:
                    - "@translator.default"
                    - "@request_stack"
                    - "@logger"
                    - "@«modPrefix».entity_factory"
                    - "@«modPrefix».workflow_helper"
                    «IF hasUserFields»
                        - "@zikula_users_module.user_repository"
                    «ENDIF»
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
        «IF hasLoggable»

            «modPrefix».loggable_helper:
                class: «nsBase»LoggableHelper
                arguments:
                    - "@translator.default"
                    - "@«modPrefix».entity_factory"
                    - "@«modPrefix».entity_display_helper"
                    - "@«modPrefix».entity_lifecycle_listener"
                    «IF hasLoggableTranslatable»
                        - "@«modPrefix».translatable_helper"
                    «ENDIF»
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
                    - "@router"
                    - "@request_stack"
                    - "@zikula_extensions_module.api.variable"
                    - "@twig"
                    - "@zikula_mailer_module.api.mailer"
                    - "@zikula_groups_module.group_repository"
                    - "@«modPrefix».entity_display_helper"
                    - "@«modPrefix».workflow_helper"
        «ENDIF»

        «modPrefix».permission_helper:
            class: «nsBase»PermissionHelper
            arguments:
                - "@service_container"
                - "@request_stack"
                - "@zikula_permissions_module.api.permission"
                «IF hasLoggable»
                    - "@zikula_extensions_module.api.variable"
                «ENDIF»
                - "@zikula_users_module.current_user"
                - "@zikula_users_module.user_repository"
        «IF generateSearchApi»

            «modPrefix».search_helper:
                class: «nsBase»SearchHelper
                arguments:
                    - "@translator.default"
                    - "@session"
                    - "@request_stack"
                    - "@«modPrefix».entity_factory"
                    - "@«modPrefix».controller_helper"
                    - "@«modPrefix».entity_display_helper"
                    - "@«modPrefix».permission_helper"
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
                    - "@filesystem"
                    - "@session"
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
                - "@zikula_extensions_module.api.variable"
                - "@zikula_core.common.theme.pagevars"
                - "@«modPrefix».controller_helper"
                - "@«modPrefix».permission_helper"

        «modPrefix».workflow_helper:
            class: «nsBase»WorkflowHelper
            arguments:
                - "@translator.default"
                - "@workflow.registry"
                - "@logger"
                - "@zikula_users_module.current_user"
                - "@«modPrefix».entity_factory"
                - "@«modPrefix».listentries_helper"
                - "@«modPrefix».permission_helper"
    '''

    def private hooks(Application it) '''
        services:
            «IF hasHookSubscribers»
                «FOR entity : getAllEntities.filter[e|!e.skipHookSubscribers]»
                    «modPrefix».hook_subscriber.filter_hooks.«entity.nameMultiple.formatForDB»:
                        class: «appNamespace»\HookSubscriber\«entity.name.formatForCodeCapital»FilterHooksSubscriber
                        arguments:
                            - "@translator.default"
                        tags:
                            - { name: zikula.hook_subscriber, areaName: 'subscriber.«appName.formatForDB».filter_hooks.«entity.nameMultiple.formatForDB»' }

                    «IF entity.hasEditAction || entity.hasDeleteAction»
                        «modPrefix».hook_subscriber.form_aware_hook.«entity.nameMultiple.formatForDB»:
                            class: «appNamespace»\HookSubscriber\«entity.name.formatForCodeCapital»FormAwareHookSubscriber
                            arguments:
                                - "@translator.default"
                            tags:
                                - { name: zikula.hook_subscriber, areaName: 'subscriber.«appName.formatForDB».form_aware_hook.«entity.nameMultiple.formatForDB»' }

                    «ENDIF»
                    «IF entity.hasViewAction || entity.hasDisplayAction || entity.hasEditAction || entity.hasDeleteAction»
                        «modPrefix».hook_subscriber.ui_hooks.«entity.nameMultiple.formatForDB»:
                            class: «appNamespace»\HookSubscriber\«entity.name.formatForCodeCapital»UiHooksSubscriber
                            arguments:
                                - "@translator.default"
                            tags:
                                - { name: zikula.hook_subscriber, areaName: 'subscriber.«appName.formatForDB».ui_hooks.«entity.nameMultiple.formatForDB»' }

                    «ENDIF»
                «ENDFOR»
            «ENDIF»
            «IF hasHookProviders»
                «IF hasFilterHookProvider»
                    «modPrefix».hook_provider.filter_hooks.provider:
                        class: «appNamespace»\HookProvider\FilterHooksProvider
                        arguments:
                            - "@translator.default"
                        tags:
                            - { name: zikula.hook_provider, areaName: 'provider.«appName.formatForDB».filter_hooks.«name.formatForDB»' }

                «ENDIF»
                «IF hasFormAwareHookProviders || hasUiHooksProviders»
                    «FOR entity : getAllEntities»
                        «IF entity.formAwareHookProvider != HookProviderMode.DISABLED»
                            «modPrefix».hook_provider.form_aware_hook.«entity.nameMultiple.formatForDB»:
                                class: «appNamespace»\HookProvider\«entity.name.formatForCodeCapital»FormAwareHookProvider
                                arguments:
                                    - "@translator.default"
                                    - "@session"
                                    - "@form.factory"
                                tags:
                                    - { name: zikula.hook_provider, areaName: 'provider.«appName.formatForDB».form_aware_hook.«entity.nameMultiple.formatForDB»' }

                        «ENDIF»
                        «IF entity.uiHooksProvider != HookProviderMode.DISABLED»
                            «modPrefix».hook_provider.ui_hooks.«entity.nameMultiple.formatForDB»:
                                class: «appNamespace»\HookProvider\«entity.name.formatForCodeCapital»UiHooksProvider
                                arguments:
                                    - "@translator.default"
                                    - "@request_stack"
                                    - "@«modPrefix».entity_factory"
                                    - "@twig"
                                    - "@«modPrefix».permission_helper"
                                    «IF !getUploadEntities.empty»
                                        - "@«modPrefix».image_helper"
                                    «ENDIF»
                                tags:
                                    - { name: zikula.hook_provider, areaName: 'provider.«appName.formatForDB».ui_hooks.«entity.nameMultiple.formatForDB»' }

                        «ENDIF»
                    «ENDFOR»
                «ENDIF»
            «ENDIF»
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
                «IF hasTrees»
                    - "@«modPrefix».entity_factory"
                «ENDIF»
                - "@«modPrefix».entity_display_helper"
                - "@«modPrefix».workflow_helper"
                «IF hasListFields»
                    - "@«modPrefix».listentries_helper"
                «ENDIF»
                «IF hasLoggable»
                    - "@«modPrefix».loggable_helper"
                «ENDIF»
                «IF hasTrees»
                    - "@«modPrefix».menu_builder"
                «ENDIF»
            public: false
            «IF targets('2.0')»
                tags: ['twig.extension']
            «ELSE»
                tags:
                    - { name: twig.extension }
            «ENDIF»
    '''

    def private logger(Application it) '''
        services:
            «servicesLogger»
    '''

    def private servicesLogger(Application it) '''
        # Log processor
        «modPrefix».log.processor:
            class: Monolog\Processor\PsrLogMessageProcessor
            «IF targets('2.0')»
                tags: ['monolog.processor']
            «ELSE»
                tags:
                    - { name: monolog.processor }
            «ENDIF»
    '''

    def private contentTypes(Application it) '''
        services:
            «servicesContentTypes»
    '''

    def private servicesContentTypes(Application it) '''
        «val nsBase = appNamespace + '\\ContentType\\'»
        # Content types
        «IF generateListContentType»
            «nsBase»ItemListType:
                parent: zikula.content_type.base
                shared: false
                calls:
                    - [setControllerHelper, ['@«modPrefix».controller_helper']]
                    - [setModelHelper, ['@«modPrefix».model_helper']]
                    - [setEntityFactory, ['@«modPrefix».entity_factory']]
                    «IF hasCategorisableEntities»
                        - [setCategoryDependencies, ['@«modPrefix».feature_activation_helper', '@«modPrefix».category_helper']]
                    «ENDIF»
                tags: ['zikula.content_type']
            «nsBase»Form\Type\ItemListType:
                parent: zikula.content_type.form.base
                «IF hasCategorisableEntities»
                    arguments:
                        - "@zikula_categories_module.category_repository"
                «ENDIF»
                tags: ['form.type']
        «ENDIF»
        «IF needsDetailContentType»
            «nsBase»ItemType:
                parent: zikula.content_type.base
                shared: false
                calls:
                    - [setControllerHelper, ['@«modPrefix».controller_helper']]
                    - [setFragmentHandler, ['@fragment.handler']]
                tags: ['zikula.content_type']
            «nsBase»Form\Type\ItemType:
                parent: zikula.content_type.form.base
                arguments:
                    - "@«modPrefix».entity_factory"
                    - "@«modPrefix».entity_display_helper"
                tags: ['form.type']
        «ENDIF»
    '''
}
