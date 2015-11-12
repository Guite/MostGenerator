package org.zikula.modulestudio.generator.cartridges.zclassic.controller

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.GeneratorSettingsExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

/**
 * Service definitions in yaml format.
 */
class ServiceDefinitions {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension GeneratorSettingsExtensions = new GeneratorSettingsExtensions
    extension ModelExtensions = new ModelExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    String modPrefix = ''

    def private generateServiceFile(Application it, IFileSystemAccess fsa, String fileName, CharSequence content) {
        var definitionFileName = getResourcesPath + 'config/' + fileName + '.yml'
        if (!shouldBeSkipped(definitionFileName)) {
            if (shouldBeMarked(definitionFileName)) {
                definitionFileName = getResourcesPath + 'config/' + fileName + '.generated.yml'
            }
            definitionFileName
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
        generateServiceFile(fsa, 'helpers', helpers)
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
          - { resource: 'helpers.yml' }
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
                arguments:
                    translator: "@translator"
                    router: "@router"
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
                arguments:
                    objectManager: "@doctrine.orm.entity_manager"
                    className: "«vendor.formatForCodeCapital»\\«name.formatForCodeCapital»Module\\Entity\\«entity.name.formatForCodeCapital»Entity"

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

    def private helpers(Application it) '''
        services:
            «servicesHelper»
    '''

    def private servicesHelper(Application it) '''
        # Utility classes
        «val nsBase = appNamespace.replace('\\', '\\\\') + '\\\\Helper\\\\'»
        «modPrefix».model_helper:
            class: "«nsBase»ModelHelper"
            arguments:
                serviceManager: "@service_container"

        «modPrefix».controller_helper:
            class: "«nsBase»ControllerHelper"
            arguments:
                translator: "@translator"
                session: "@session"
                logger: "@logger"

        «modPrefix».view_helper:
            class: "«nsBase»ViewHelper"
            arguments:
                serviceManager: "@service_container"
                translator: "@translator"

        «modPrefix».workflow_helper:
            class: "«nsBase»WorkflowHelper"
            arguments:
                serviceManager: "@service_container"
                translator: "@translator"
        «IF hasUploads»

            «modPrefix».image_helper:
                class: "«nsBase»ImageHelper"
        «ENDIF»
        «IF hasListFields»

            «modPrefix».listentries_helper:
                class: "«nsBase»ListEntriesHelper"
                arguments:
                    translator: "@translator"
        «ENDIF»
        «IF hasTranslatable»

            «modPrefix».translatable_helper:
                class: "«nsBase»TranslatableHelper"
                arguments:
                    serviceManager: "@service_container"
        «ENDIF»
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
