package org.zikula.modulestudio.generator.cartridges.zclassic.controller

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.GeneratorSettingsExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

/**
 * Service definitions in xml format.
 */
class ServiceDefinitions {
    @Inject extension ControllerExtensions = new ControllerExtensions
    @Inject extension FormattingExtensions = new FormattingExtensions
    @Inject extension GeneratorSettingsExtensions = new GeneratorSettingsExtensions
    @Inject extension NamingExtensions = new NamingExtensions
    @Inject extension Utils = new Utils

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

    def private parameters(Application it) '''
        «val modPrefix = appName.formatForDB»
        «val listenerBase = vendor.formatForCodeCapital + '\\' + name.formatForCodeCapital + 'Module\\Listener\\'»

        «modPrefix».core_listener.class: «listenerBase»CoreListener
        «modPrefix».frontcontroller_listener.class: «listenerBase»FrontControllerListener
        «modPrefix».installer_listener.class: «listenerBase»InstallerListener
        «modPrefix».moduledispatch_listener.class: «listenerBase»ModuleDispatchListener
        «modPrefix».mailer_listener.class: «listenerBase»MailerListener
        «modPrefix».page_listener.class: «listenerBase»PageListener
        «modPrefix».theme_listener.class: «listenerBase»ThemeListener
        «modPrefix».view_listener.class: «listenerBase»ViewListener
        «modPrefix».userlogin_listener.class: «listenerBase»UserLoginListener
        «modPrefix».userlogout_listener.class: «listenerBase»UserLogoutListener
        «modPrefix».user_listener.class: «listenerBase»UserListener
        «modPrefix».userregistration_listener.class: «listenerBase»UserRegistrationListener
        «modPrefix».users_listener.class: «listenerBase»UsersListener
        «modPrefix».group_listener.class: «listenerBase»GroupListener
        «val needsDetailContentType = generateDetailContentType && hasUserController && getMainUserController.hasActions('display')»
        «IF generatePendingContentSupport || generateListContentType || needsDetailContentType»
            «modPrefix».thirdparty_listener.class: «listenerBase»ThirdPartyListener
        «ENDIF»
    '''

    def private services(Application it) '''
        «val modPrefix = appName.formatForDB»

        # core related events
        «modPrefix».core_listener:
            class: "%«modPrefix».core_listener.class%"
            tags:
                - { name: kernel.event_subscriber }

        # front controller
        «modPrefix».frontcontroller_listener:
            class: "%«modPrefix».frontcontroller_listener.class%"
            tags:
                - { name: kernel.event_subscriber }

        # installer
        «modPrefix».installer_listener:
            class: "%«modPrefix».installer_listener.class%"
            tags:
                - { name: kernel.event_subscriber }

        # module dispatching
        «modPrefix».moduledispatch_listener:
            class: "%«modPrefix».moduledispatch_listener.class%"
            tags:
                - { name: kernel.event_subscriber }

        # mailer
        «modPrefix».mailer_listener:
            class: "%«modPrefix».mailer_listener.class%"
            tags:
                - { name: kernel.event_subscriber }

        # page
        «modPrefix».page_listener:
            class: "%«modPrefix».page_listener.class%"
            tags:
                - { name: kernel.event_subscriber }

        # theme
        «modPrefix».theme_listener:
            class: "%«modPrefix».theme_listener.class%"
            tags:
                - { name: kernel.event_subscriber }

        # view
        «modPrefix».view_listener:
            class: "%«modPrefix».view_listener.class%"
            tags:
                - { name: kernel.event_subscriber }

        # user login
        «modPrefix».userlogin_listener:
            class: "%«modPrefix».userlogin_listener.class%"
            tags:
                - { name: kernel.event_subscriber }

        # user logout
        «modPrefix».userlogout_listener:
            class: "%«modPrefix».userlogout_listener.class%"
            tags:
                - { name: kernel.event_subscriber }

        # user
        «modPrefix».user_listener:
            class: "%«modPrefix».user_listener.class%"
            tags:
                - { name: kernel.event_subscriber }

        # registration
        «modPrefix».userregistration_listener:
            class: "%«modPrefix».userregistration_listener.class%"
            tags:
                - { name: kernel.event_subscriber }

        # users module
        «modPrefix».users_listener:
            class: "%«modPrefix».users_listener.class%"
            tags:
                - { name: kernel.event_subscriber }

        # group
        «modPrefix».group_listener:
            class: "%«modPrefix».group_listener.class%"
            tags:
                - { name: kernel.event_subscriber }
        «val needsDetailContentType = generateDetailContentType && hasUserController && getMainUserController.hasActions('display')»
        «IF generatePendingContentSupport || generateListContentType || needsDetailContentType»

            # special purposes and 3rd party api support
            «modPrefix».thirdparty_listener:
                class: "%«modPrefix».thirdparty_listener.class%"
                tags:
                - { name: kernel.event_subscriber }
        «ENDIF»
    '''
}
