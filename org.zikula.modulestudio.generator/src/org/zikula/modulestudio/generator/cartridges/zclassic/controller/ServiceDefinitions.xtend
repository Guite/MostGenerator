package org.zikula.modulestudio.generator.cartridges.zclassic.controller

import de.guite.modulestudio.metamodel.modulestudio.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.GeneratorSettingsExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils
import org.zikula.modulestudio.generator.extensions.ViewExtensions

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
    extension ViewExtensions = new ViewExtensions

    String modPrefix = ''

    /**
     * Entry point for service definitions.
     * This generates yaml files describing DI configuration.
     */
    def generate(Application it, IFileSystemAccess fsa) {
        if (targets('1.3.5')) {
            return
        }
        modPrefix = appName.formatForDB
        var definitionFileName = getResourcesPath + 'config/services.yml'
        if (!shouldBeSkipped(definitionFileName)) {
            if (shouldBeMarked(definitionFileName)) {
                definitionFileName = getResourcesPath + 'config/services.generated.yml'
            }
            fsa.generateFile(definitionFileName, ymlContent)
        }
    }

    def private ymlContent(Application it) '''
        parameters:
            «parametersRouting»

            «IF hasUploads»
                «parametersUploadHandler»

            «ENDIF»
            «parametersEntityFactories»

            «parametersEventSubscriber»

            «parametersHelper»

            «parametersLogger»

        services:
            «IF hasUploads»
                «servicesUploadHandler»

            «ENDIF»
            «servicesEntityFactories»

            «servicesEventSubscriber»

            «servicesHelper»

            «servicesLogger»
    '''

    def private parametersRouting(Application it) '''
        # Route parts
        «modPrefix».routing.ajax: ajax
        «modPrefix».routing.external: external
        «modPrefix».routing.view.suffix: view
        «FOR entity : getAllEntities»
            «modPrefix».routing.«entity.name.formatForCode».singular: «entity.name.formatForCode»
            «modPrefix».routing.«entity.name.formatForCode».plural: «entity.nameMultiple.formatForCode»
        «ENDFOR»
        «modPrefix».routing.formats.view: html«IF getListOfViewFormats.size > 0»|«FOR format : getListOfViewFormats SEPARATOR '|'»«format»«ENDFOR»«ENDIF»
        «modPrefix».routing.formats.display: html«IF getListOfDisplayFormats.size > 0»|«FOR format : getListOfDisplayFormats SEPARATOR '|'»«format»«ENDFOR»«ENDIF»
    '''

    def private parametersUploadHandler(Application it) '''
        # Upload handler class
        «modPrefix».upload_handler.class: «appNamespace»\UploadHandler
    '''

    def private parametersEntityFactories(Application it) '''
        # Entity factory classes
        «FOR entity : getAllEntities»
            «modPrefix».entity.factory.«entity.name.formatForCode».class: «vendor.formatForCodeCapital»\«name.formatForCodeCapital»Module\Entity\Factory\«entity.name.formatForCodeCapital»Factory
        «ENDFOR»
    '''

    def private parametersEventSubscriber(Application it) '''
        «val nsBase = appNamespace + '\\Listener\\'»
        # Listener classes
        «FOR className : getSubscriberNames»
            «modPrefix».«className.toLowerCase»_listener.class: «nsBase»«className»Listener
        «ENDFOR»
    '''

    def private parametersHelper(Application it) '''
        «val nsBase = appNamespace + '\\Util\\'»
        # Util classes
        «FOR className : getHelperNames»
            «modPrefix».«className.toLowerCase»_helper.class: «nsBase»«className»Util
        «ENDFOR»
    '''

    def private parametersLogger(Application it) '''

        # Log processor
        «modPrefix».log.processor.class: Monolog\Processor\PsrLogMessageProcessor
    '''

    def private servicesUploadHandler(Application it) '''
        «modPrefix».upload_handler:
            class: "%«modPrefix».upload_handler.class%"
    '''

    def private servicesEntityFactories(Application it) '''
        «FOR entity : getAllEntities»
            «modPrefix».«entity.name.formatForCode»_factory:
                class: "%«modPrefix».entity.factory.«entity.name.formatForCode».class%"
                arguments:
                    objectManager: "@doctrine.orm.entity_manager"
                    className: «vendor.formatForCodeCapital»\«name.formatForCodeCapital»Module\Entity\«entity.name.formatForCodeCapital»Entity

        «ENDFOR»
    '''

    def private servicesEventSubscriber(Application it) '''
        «FOR className : getSubscriberNames»
            «modPrefix».«className.toLowerCase»_listener:
                class: "%«modPrefix».«className.toLowerCase»_listener.class%"
                tags:
                    - { name: kernel.event_subscriber }

        «ENDFOR»
    '''

    def private servicesHelper(Application it) '''
        «FOR className : getHelperNames»
            «modPrefix».«className.toLowerCase»_helper:
                class: "%«modPrefix».«className.toLowerCase»_helper.class%"
                arguments: ["@service_container", "@=service('kernel').getBundle('«appName»')"]

        «ENDFOR»
    '''

    def private servicesLogger(Application it) '''
        «modPrefix».log.processor:
            class: "%«modPrefix».log.processor.class%"
            tags:
                - { name: monolog.processor }
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

    def private getHelperNames(Application it) {
        var helpers = newArrayList('Model', 'Controller', 'View', 'Workflow')
        if (hasUploads) {
            helpers.add('Image')
        }
        if (hasListFields) {
            helpers.add('ListEntries')
        }
        if (hasTranslatable) {
            helpers.add('Translatable')
        }

        helpers
    }
}
