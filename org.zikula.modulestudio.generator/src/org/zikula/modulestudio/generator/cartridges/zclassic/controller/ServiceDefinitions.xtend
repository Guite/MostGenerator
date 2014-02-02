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
        val definitionFileName = getResourcesPath + 'config/services.xml'
        if (!shouldBeSkipped(definitionFileName)) {
            fsa.generateFile(definitionFileName, xmlContent)
        }
    }

    def private xmlContent(Application it) '''
        <?xml version="1.0" encoding="UTF-8"?>
        <container xmlns="http://symfony.com/schema/dic/services"
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
            xsi:schemaLocation="http://symfony.com/schema/dic/services http://symfony.com/schema/dic/services/services-1.0.xsd">
            «parameters»
            «services»
        </container>
    '''

    def private parameters(Application it) '''
        <parameters>
            «val modPrefix = appName.formatForDB»
            «val listenerBase = vendor.formatForCodeCapital + '\\' + name.formatForCodeCapital + 'Module\\Listener\\'»

            <parameter key="«modPrefix».core_listener.class">«listenerBase»CoreListener</parameter>
            <parameter key="«modPrefix».frontcontroller_listener.class">«listenerBase»FrontControllerListener</parameter>
            <parameter key="«modPrefix».installer_listener.class">«listenerBase»InstallerListener</parameter>
            <parameter key="«modPrefix».moduledispatch_listener.class">«listenerBase»ModuleDispatchListener</parameter>
            <parameter key="«modPrefix».mailer_listener.class">«listenerBase»MailerListener</parameter>
            <parameter key="«modPrefix».page_listener.class">«listenerBase»PageListener</parameter>
            <parameter key="«modPrefix».theme_listener.class">«listenerBase»ThemeListener</parameter>
            <parameter key="«modPrefix».view_listener.class">«listenerBase»ViewListener</parameter>
            <parameter key="«modPrefix».userlogin_listener.class">«listenerBase»UserLoginListener</parameter>
            <parameter key="«modPrefix».userlogout_listener.class">«listenerBase»UserLogoutListener</parameter>
            <parameter key="«modPrefix».user_listener.class">«listenerBase»UserListener</parameter>
            <parameter key="«modPrefix».userregistration_listener.class">«listenerBase»UserRegistrationListener</parameter>
            <parameter key="«modPrefix».users_listener.class">«listenerBase»UsersListener</parameter>
            <parameter key="«modPrefix».group_listener.class">«listenerBase»GroupListener</parameter>
            «val needsDetailContentType = generateDetailContentType && hasUserController && getMainUserController.hasActions('display')»
            «IF generatePendingContentSupport || generateListContentType || needsDetailContentType»
                <parameter key="«modPrefix».thirdparty_listener.class">«listenerBase»ThirdPartyListener</parameter>
            «ENDIF»
        </parameters>
    '''

    def private services(Application it) '''
        <services>
            «val modPrefix = appName.formatForDB»

            <!-- core related events -->
            <service id="«modPrefix».core_listener" class="%«modPrefix».core_listener.class%">
                <tag name="kernel.event_subscriber" />
            </service>

            <!-- front controller -->
            <service id="«modPrefix».frontcontroller_listener" class="%«modPrefix».frontcontroller_listener.class%">
                <tag name="kernel.event_subscriber" />
            </service>

            <!-- installer -->
            <service id="«modPrefix».installer_listener" class="%«modPrefix».installer_listener.class%">
                <tag name="kernel.event_subscriber" />
            </service>

            <!-- module dispatching -->
            <service id="«modPrefix».moduledispatch_listener" class="%«modPrefix».moduledispatch_listener.class%">
                <tag name="kernel.event_subscriber" />
            </service>

            <!-- mailer -->
            <service id="«modPrefix».mailer_listener" class="%«modPrefix».mailer_listener.class%">
                <tag name="kernel.event_subscriber" />
            </service>

            <!-- page -->
            <service id="«modPrefix».page_listener" class="%«modPrefix».page_listener.class%">
                <tag name="kernel.event_subscriber" />
            </service>

            <!-- theme -->
            <service id="«modPrefix».theme_listener" class="%«modPrefix».theme_listener.class%">
                <tag name="kernel.event_subscriber" />
            </service>

            <!-- view -->
            <service id="«modPrefix».view_listener" class="%«modPrefix».view_listener.class%">
                <tag name="kernel.event_subscriber" />
            </service>

            <!-- user login -->
            <service id="«modPrefix».userlogin_listener" class="%«modPrefix».userlogin_listener.class%">
                <tag name="kernel.event_subscriber" />
            </service>

            <!-- user logout -->
            <service id="«modPrefix».userlogout_listener" class="%«modPrefix».userlogout_listener.class%">
                <tag name="kernel.event_subscriber" />
            </service>

            <!-- user -->
            <service id="«modPrefix».user_listener" class="%«modPrefix».user_listener.class%">
                <tag name="kernel.event_subscriber" />
            </service>

            <!-- registration -->
            <service id="«modPrefix».userregistration_listener" class="%«modPrefix».userregistration_listener.class%">
                <tag name="kernel.event_subscriber" />
            </service>

            <!-- users module -->
            <service id="«modPrefix».users_listener" class="%«modPrefix».users_listener.class%">
                <tag name="kernel.event_subscriber" />
            </service>

            <!-- group -->
            <service id="«modPrefix».group_listener" class="%«modPrefix».group_listener.class%">
                <tag name="kernel.event_subscriber" />
            </service>
            «val needsDetailContentType = generateDetailContentType && hasUserController && getMainUserController.hasActions('display')»
            «IF generatePendingContentSupport || generateListContentType || needsDetailContentType»

                <!-- special purposes and 3rd party api support -->
                <service id="«modPrefix».thirdparty_listener" class="%«modPrefix».thirdparty_listener.class%">
                    <tag name="kernel.event_subscriber" />
                </service>
            «ENDIF»

        </services>
    '''
}
