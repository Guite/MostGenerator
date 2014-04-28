package org.zikula.modulestudio.generator.cartridges.zclassic.controller

import com.google.inject.Inject
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
 * Service definitions in xml format.
 */
class ServiceDefinitions {

    @Inject extension ControllerExtensions = new ControllerExtensions
    @Inject extension FormattingExtensions = new FormattingExtensions
    @Inject extension GeneratorSettingsExtensions = new GeneratorSettingsExtensions
    @Inject extension ModelExtensions = new ModelExtensions
    @Inject extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    @Inject extension NamingExtensions = new NamingExtensions
    @Inject extension Utils = new Utils
    @Inject extension ViewExtensions = new ViewExtensions

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
            «parametersListener»
            «parametersHelper»

        services:
            «IF hasUploads»
                «servicesUploadHandler»

            «ENDIF»
            «servicesListener»
            «servicesHelper»
    '''

    def private parametersRouting(Application it) '''
        # Route parts
        «modPrefix».routing.external: external
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

    def private parametersListener(Application it) '''
        «val listenerBase = appNamespace + '\\Listener\\'»
        # Listener classes
        «FOR listenerName : getListenerNames»
            «modPrefix».«listenerName.toLowerCase»_listener.class: «listenerBase»«listenerName»Listener
        «ENDFOR»
    '''

    def private parametersHelper(Application it) '''
        «val helperBase = appNamespace + '\\Util\\'»
        # Util classes
        «FOR helperName : getHelperNames»
            «modPrefix».«helperName.toLowerCase»_helper.class: «helperBase»«helperName»Util
        «ENDFOR»
    '''

    def private servicesUploadHandler(Application it) '''
        «modPrefix».upload_handler:
            class: "%«modPrefix».upload_handler.class%"
    '''

    def private servicesListener(Application it) '''
        «FOR listenerName : getListenerNames»
            «modPrefix».«listenerName.toLowerCase»_listener:
                class: "%«modPrefix».«listenerName.toLowerCase»_listener.class%"
                tags:
                    - { name: kernel.event_subscriber }

        «ENDFOR»
    '''

    def private servicesHelper(Application it) '''
        «FOR helperName : getHelperNames»
            «modPrefix».«helperName.toLowerCase»_helper:
                class: "%«modPrefix».«helperName.toLowerCase»_helper.class%"
                arguments: ["@service_container", "@«appName»"]

        «ENDFOR»
    '''

    def private getListenerNames(Application it) {
        var listeners = newArrayList(
            'Core', 'FrontController', 'Installer', 'ModuleDispatch', 'Mailer', 'Page', 'Theme', 'View',
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
