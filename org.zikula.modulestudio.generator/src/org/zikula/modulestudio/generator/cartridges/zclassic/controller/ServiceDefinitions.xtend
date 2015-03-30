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

    def private servicesUploadHandler(Application it) '''
        # Upload handler class
        «modPrefix».upload_handler:
            class: "«appNamespace»\UploadHandler"
    '''

    def private servicesEntityFactories(Application it) '''
        # Entity factory classes
        «FOR entity : entities»
            «modPrefix».«entity.name.formatForCode»_factory:
                class: "«vendor.formatForCodeCapital»\«name.formatForCodeCapital»Module\Entity\Factory\«entity.name.formatForCodeCapital»Factory"
                arguments:
                    objectManager: "@doctrine.orm.entity_manager"
                    className: «vendor.formatForCodeCapital»\«name.formatForCodeCapital»Module\Entity\«entity.name.formatForCodeCapital»Entity

        «ENDFOR»
    '''

    def private servicesEventSubscriber(Application it) '''
        # Event subscriber and listener classes
        «val nsBase = appNamespace + '\\Listener\\'»
        «FOR className : getSubscriberNames»
            «modPrefix».«className.toLowerCase»_listener:
                class: "«nsBase»«className»Listener"
                tags:
                    - { name: kernel.event_subscriber }

        «ENDFOR»
    '''

    def private servicesHelper(Application it) '''
        # Util classes
        «val nsBase = appNamespace + '\\Util\\'»
        «FOR className : getHelperNames»
            «modPrefix».«className.toLowerCase»_helper:
                class: "«nsBase»«className»Util"
                arguments: ["@service_container", "@=service('kernel').getBundle('«appName»')"]

        «ENDFOR»
    '''

    def private servicesLogger(Application it) '''
        # Log processor
        «modPrefix».log.processor:
            class: "Monolog\Processor\PsrLogMessageProcessor"
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
