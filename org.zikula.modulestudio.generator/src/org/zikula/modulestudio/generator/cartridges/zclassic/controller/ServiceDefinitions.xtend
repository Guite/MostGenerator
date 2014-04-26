package org.zikula.modulestudio.generator.cartridges.zclassic.controller

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.GeneratorSettingsExtensions
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
    @Inject extension NamingExtensions = new NamingExtensions
    @Inject extension Utils = new Utils
    @Inject extension ViewExtensions = new ViewExtensions

    /**
     * Entry point for workflow definitions.
     * This generates xml files describing the workflows used in the application.
     */
    def generate(Application it, IFileSystemAccess fsa) {
        if (targets('1.3.5')) {
            return
        }
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
            «parameters»

        services:
            «services»
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

    def private parameters(Application it) '''
        «val modPrefix = appName.formatForDB»
        # Route parts
        «modPrefix».routing.external: external
        «FOR entity : getAllEntities»
            «modPrefix».routing.«entity.name.formatForCode».singular: «entity.name.formatForCode»
            «modPrefix».routing.«entity.name.formatForCode».plural: «entity.nameMultiple.formatForCode»
        «ENDFOR»
        «modPrefix».routing.formats.view: html«IF getListOfViewFormats.size > 0»|«FOR format : getListOfViewFormats SEPARATOR '|'»«format»«ENDFOR»«ENDIF»
        «modPrefix».routing.formats.display: html«IF getListOfDisplayFormats.size > 0»|«FOR format : getListOfDisplayFormats SEPARATOR '|'»«format»«ENDFOR»«ENDIF»

        «val listenerBase = vendor.formatForCodeCapital + '\\' + name.formatForCodeCapital + 'Module\\Listener\\'»
        # Listener classes
        «FOR listenerName : getListenerNames»
            «modPrefix».«listenerName.toLowerCase»_listener.class: «listenerBase»«listenerName»Listener
        «ENDFOR»
    '''

    def private services(Application it) '''
        «val modPrefix = appName.formatForDB»

        «FOR listenerName : getListenerNames»
            «modPrefix».«listenerName.toLowerCase»_listener:
                class: "%«modPrefix».«listenerName.toLowerCase»_listener.class%"
                tags:
                    - { name: kernel.event_subscriber }

        «ENDFOR»
    '''
}
