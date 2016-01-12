package org.zikula.modulestudio.generator.cartridges.zclassic.controller

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.DateField
import de.guite.modulestudio.metamodel.TimeField
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.GeneratorSettingsExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

/**
 * Service definitions in YAML format.
 */
class ServiceDefinitions {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension GeneratorSettingsExtensions = new GeneratorSettingsExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelExtensions = new ModelExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

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
     * This generates yaml files describing DI configuration.
     */
    def generate(Application it, IFileSystemAccess fsa) {
        if (targets('1.3.x')) {
            return
        }
        modPrefix = vendor.formatForDB + '_' + name.formatForDB + '_module'

        generateServiceFile(fsa, 'services', mainServiceFile)
        if (hasUploads) {
            generateServiceFile(fsa, 'uploadHandler', uploadHandler)
        }
        generateServiceFile(fsa, 'linkContainer', linkContainer)
        generateServiceFile(fsa, 'entityFactories', entityFactories)
        generateServiceFile(fsa, 'eventSubscriber', eventSubscriber)
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
          - { resource: 'forms.yml' }
          - { resource: 'helpers.yml' }
          - { resource: 'twig.yml' }
          - { resource: 'logger.yml' }
    '''

    def private uploadHandler(Application it) '''
        services:
            «servicesUploadHandler»
    '''

    def private servicesUploadHandler(Application it) '''
        # Upload handler class
        «modPrefix».upload_handler:
            class: "«appNamespace.replace('\\', '\\\\')»\\UploadHandler"
    '''

    def private linkContainer(Application it) '''
        services:
            «modPrefix».link_container:
                class: "«vendor.formatForCodeCapital»\\«name.formatForCodeCapital»Module\\Container\\LinkContainer"
                arguments: [@translator, @router]
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
                class: "«vendor.formatForCodeCapital»\\«name.formatForCodeCapital»Module\\Entity\\Factory\\«entity.name.formatForCodeCapital»Factory"
                arguments: [@doctrine.orm.entity_manager, "«vendor.formatForCodeCapital»\\«name.formatForCodeCapital»Module\\Entity\\«entity.name.formatForCodeCapital»Entity"]

        «ENDFOR»
    '''

    def private eventSubscriber(Application it) '''
        services:
            «servicesEventSubscriber»
    '''

    def private servicesEventSubscriber(Application it) '''
        # Event subscriber and listener classes
        «val nsBase = appNamespace.replace('\\', '\\\\') + '\\\\Listener\\\\'»
        «FOR className : getSubscriberNames»
            «modPrefix».«className.toLowerCase»_listener:
                class: "«nsBase»«className»Listener"
                tags:
                    - { name: kernel.event_subscriber }

        «ENDFOR»
    '''

    def private getSubscriberNames(Application it) {
        var listeners = newArrayList(
            'Core', 'Kernel', 'Installer', 'ModuleDispatch', 'Mailer', 'Page', 'Theme', 'View',
            'UserLogin', 'UserLogout', 'User', 'UserRegistration', 'Users', 'Group')

        val needsDetailContentType = generateDetailContentType && hasUserController && getMainUserController.hasActions('display')
        if (generatePendingContentSupport || generateListContentType || needsDetailContentType) {
            listeners.add('ThirdParty')
        }

        listeners
    }

    def private forms(Application it) '''
        services:
            «formsHelper»
    '''

    def private formsHelper(Application it) '''
        # Form types
        «val nsBase = appNamespace.replace('\\', '\\\\') + '\\\\Form\\\\Type\\\\'»
        «IF hasViewActions»
            «FOR entity : getAllEntities.filter[e|e.hasActions('view')]»

                «modPrefix».form.type.«entity.name.formatForDB»quicknav:
                    class: "«nsBase»QuickNavigation\«entity.name.formatForCodeCapital»QuickNavType"
                    arguments: [@translator, @request_stack«IF entity.hasListFieldsEntity», @«modPrefix».listentries_helper«ENDIF»]
                    tags:
                        - { name: form.type }
            «ENDFOR»
        «ENDIF»
        «IF hasEditActions»
            «FOR entity : getAllEntities.filter[e|e.hasActions('edit')]»

                «modPrefix».form.type.«entity.name.formatForDB»:
                    class: "«nsBase»«entity.name.formatForCodeCapital»Type"
                    arguments: [@translator«IF entity.hasTranslatableFields», @zikula_extensions_module.api.variable, @«modPrefix».translatable_helper«ENDIF»«IF entity.hasListFieldsEntity», @«modPrefix».listentries_helper«ENDIF»]
                    tags:
                        - { name: form.type }
            «ENDFOR»
            «IF hasMetaDataEntities»

                «modPrefix».form.type.entitymetadata:
                    class: "«nsBase»EntityMetaDataType"
                    arguments: [@translator]
                    tags:
                        - { name: form.type }
            «ENDIF»
        «ENDIF»
        «IF hasDeleteActions»
            «modPrefix».form.type.deleteentity:
                class: "«nsBase.replace('Type\\\\', '')»DeleteEntityType"
                arguments: [@translator]
                tags:
                    - { name: form.type }
        «ENDIF»
        «IF generateListBlock»

            «modPrefix».form.type.block.itemlist:
                class: "«nsBase.replace('Form\\\\Type\\\\', '')»Block\Form\Type\ListBlockType"
                arguments: [@translator]
                tags:
                    - { name: form.type }
        «ENDIF»
        «IF generateExternalControllerAndFinder»
            «FOR entity : getAllEntities»

                «modPrefix».form.type.«entity.name.formatForDB»finder:
                    class: "«nsBase»Finder\«entity.name.formatForCodeCapital»FinderType"
                    arguments: [@translator]
                    tags:
                        - { name: form.type }
            «ENDFOR»
        «ENDIF»
        «IF needsConfig»

            «modPrefix».form.type.appsettings:
                class: "«nsBase.replace('Type\\\\', '')»AppSettingsType"
                arguments: [@translator, @zikula_extensions_module.api.variable]
                tags:
                    - { name: form.type }
        «ENDIF»
        «IF hasEditActions»
            «IF hasColourFields»

                «modPrefix».form.type.field.colour:
                    class: "«nsBase»Field\ColourType"
                    tags:
                        - { name: form.type }
            «ENDIF»
            «IF hasGeographical»

                «modPrefix».form.type.field.geo:
                    class: "«nsBase»Field\GeoType"
                    tags:
                        - { name: form.type }
            «ENDIF»
            «IF !getAllEntities.filter[e|!e.fields.filter(DateField).empty].empty»

                «modPrefix».form.date_type_extension:
                    class: "«nsBase.replace('Type\\\\', '')»Extension\DateTypeExtension"
                    tags:
                        - { name: form.type_extension, extended-type: "Symfony\Component\Form\Extension\Core\Type\DateType" }
            «ENDIF»
            «IF !getAllEntities.filter[e|!e.fields.filter(TimeField).empty].empty»

                «modPrefix».form.time_type_extension:
                    class: "«nsBase.replace('Type\\\\', '')»Extension\TimeTypeExtension"
                    tags:
                        - { name: form.type_extension, extended-type: "Symfony\Component\Form\Extension\Core\Type\TimeType" }
            «ENDIF»
            «IF hasMultiListFields»

                «modPrefix».form.type.field.multilist:
                    class: "«nsBase»Field\MultiListType"
                    arguments: [@translator, @«modPrefix».listentries_helper]
                    tags:
                        - { name: form.type }
            «ENDIF»
            «IF hasTrees»

                «modPrefix».form.type.field.entitytree:
                    class: "«nsBase»Field\EntityTreeType"
                    tags:
                        - { name: form.type }
            «ENDIF»
            «IF hasUploads»

                «modPrefix».form.upload_type_extension:
                    class: "«nsBase.replace('Type\\\\', '')»Extension\UploadTypeExtension"
                    arguments: [@translator]
                    tags:
                        - { name: form.type_extension, extended-type: "Symfony\Component\Form\Extension\Core\Type\FileType" }
            «ENDIF»
            «IF hasUserFields»

                «modPrefix».form.type.field.user:
                    class: "«nsBase»Field\UserType"
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
        # Helper classes
        «val nsBase = appNamespace.replace('\\', '\\\\') + '\\\\Helper\\\\'»
        «modPrefix».model_helper:
            class: "«nsBase»ModelHelper"
            arguments: [@service_container]

        «modPrefix».controller_helper:
            class: "«nsBase»ControllerHelper"
            arguments: [@service_container, @translator, @session, @logger]

        «modPrefix».view_helper:
            class: "«nsBase»ViewHelper"
            arguments: [@service_container, @translator]

        «modPrefix».workflow_helper:
            class: "«nsBase»WorkflowHelper"
            arguments: [@service_container, @translator]
        «IF hasHookSubscribers»

            «modPrefix».hook_helper:
                class: "«nsBase»HookHelper"
                arguments: [@hook_dispatcher]
        «ENDIF»
        «IF hasUploads»

            «modPrefix».image_helper:
                class: "«nsBase»ImageHelper"
        «ENDIF»
        «IF hasListFields»

            «modPrefix».listentries_helper:
                class: "«nsBase»ListEntriesHelper"
                arguments: [@translator]
        «ENDIF»
        «IF hasTranslatable»

            «modPrefix».translatable_helper:
                class: "«nsBase»TranslatableHelper"
                arguments: [@service_container]
        «ENDIF»
    '''

    def private twig(Application it) '''
        services:
            «servicesTwig»
    '''

    def private servicesTwig(Application it) '''
        # Twig extension
        «val nsBase = appNamespace.replace('\\', '\\\\') + '\\\\Twig\\\\'»
        «modPrefix».twig_extension:
            class: "«nsBase»TwigExtension"
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
            class: "Monolog\\Processor\\PsrLogMessageProcessor"
            tags:
                - { name: monolog.processor }
    '''
}
