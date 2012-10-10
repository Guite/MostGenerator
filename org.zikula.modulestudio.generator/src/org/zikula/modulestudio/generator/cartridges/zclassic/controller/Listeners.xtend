package org.zikula.modulestudio.generator.cartridges.zclassic.controller

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener.Core
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener.Errors
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener.Group
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener.Mailer
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener.ModuleDispatch
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener.ModuleInstaller
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener.Page
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener.Theme
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener.ThirdParty
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener.User
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener.UserLogin
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener.UserLogout
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener.UserRegistration
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener.Users
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener.View
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Listeners {
    @Inject extension NamingExtensions = new NamingExtensions()
    @Inject extension Utils = new Utils()

    FileHelper fh = new FileHelper()

    /**
     * Entry point for persistent event listeners.
     */
    def generate(Application it, IFileSystemAccess fsa) {
        println('Generating event listener base classes')
        val listenerBasePath = getAppSourceLibPath(appName) + 'Listener/Base/'
        fsa.generateFile(listenerBasePath + 'Core.php', listenersCoreFile(true))
        fsa.generateFile(listenerBasePath + 'Installer.php', listenersInstallerFile(true))
        fsa.generateFile(listenerBasePath + 'ModuleDispatch.php', listenersModuleDispatchFile(true))
        fsa.generateFile(listenerBasePath + 'Mailer.php', listenersMailerFile(true))
        fsa.generateFile(listenerBasePath + 'Page.php', listenersPageFile(true))
        fsa.generateFile(listenerBasePath + 'Errors.php', listenersErrorsFile(true))
        fsa.generateFile(listenerBasePath + 'Theme.php', listenersThemeFile(true))
        fsa.generateFile(listenerBasePath + 'View.php', listenersViewFile(true))
        fsa.generateFile(listenerBasePath + 'UserLogin.php', listenersUserLoginFile(true))
        fsa.generateFile(listenerBasePath + 'UserLogout.php', listenersUserLogoutFile(true))
        fsa.generateFile(listenerBasePath + 'User.php', listenersUserFile(true))
        fsa.generateFile(listenerBasePath + 'UserRegistration.php', listenersUserRegistrationFile(true))
        fsa.generateFile(listenerBasePath + 'Users.php', listenersUsersFile(true))
        fsa.generateFile(listenerBasePath + 'Group.php', listenersGroupFile(true))
        fsa.generateFile(listenerBasePath + 'ThirdParty.php', listenersThirdPartyFile(true))

        println('Generating event listener implementation classes')
        val listenerPath = getAppSourceLibPath(appName) + 'Listener/'
        fsa.generateFile(listenerPath + 'Core.php', listenersCoreFile(false))
        fsa.generateFile(listenerPath + 'Installer.php', listenersInstallerFile(false))
        fsa.generateFile(listenerPath + 'ModuleDispatch.php', listenersModuleDispatchFile(false))
        fsa.generateFile(listenerPath + 'Mailer.php', listenersMailerFile(false))
        fsa.generateFile(listenerPath + 'Page.php', listenersPageFile(false))
        fsa.generateFile(listenerPath + 'Errors.php', listenersErrorsFile(false))
        fsa.generateFile(listenerPath + 'Theme.php', listenersThemeFile(false))
        fsa.generateFile(listenerPath + 'View.php', listenersViewFile(false))
        fsa.generateFile(listenerPath + 'UserLogin.php', listenersUserLoginFile(false))
        fsa.generateFile(listenerPath + 'UserLogout.php', listenersUserLogoutFile(false))
        fsa.generateFile(listenerPath + 'User.php', listenersUserFile(false))
        fsa.generateFile(listenerPath + 'UserRegistration.php', listenersUserRegistrationFile(false))
        fsa.generateFile(listenerPath + 'Users.php', listenersUsersFile(false))
        fsa.generateFile(listenerPath + 'Group.php', listenersGroupFile(false))
        fsa.generateFile(listenerPath + 'ThirdParty.php', listenersThirdPartyFile(false))
    }

    def private listenersCoreFile(Application it, Boolean isBase) '''
        «fh.phpFileHeader(it)»
        /**
         * Event handler «IF isBase»base«ELSE»implementation«ENDIF» class for core events.
         */
        class «IF !isBase»«appName»_Listener_Core extends «ENDIF»«appName»_Listener_Base_Core
        {
            «new Core().generate(it, isBase)»
        }
    '''

    def private listenersInstallerFile(Application it, Boolean isBase) '''
        «fh.phpFileHeader(it)»
        /**
         * Event handler «IF isBase»base«ELSE»implementation«ENDIF» class for module installer events.
         */
        class «IF !isBase»«appName»_Listener_Installer extends «ENDIF»«appName»_Listener_Base_Installer
        {
            «new ModuleInstaller().generate(it, isBase)»
        }
    '''

    def private listenersModuleDispatchFile(Application it, Boolean isBase) '''
        «fh.phpFileHeader(it)»
        /**
         * Event handler «IF isBase»base«ELSE»implementation«ENDIF» class for dispatching modules.
         */
        class «IF !isBase»«appName»_Listener_ModuleDispatch extends «ENDIF»«appName»_Listener_Base_ModuleDispatch
        {
            «new ModuleDispatch().generate(it, isBase)»
        }
    '''

    def private listenersMailerFile(Application it, Boolean isBase) '''
        «fh.phpFileHeader(it)»
        /**
         * Event handler «IF isBase»base«ELSE»implementation«ENDIF» class for mailing events.
         */
        class «IF !isBase»«appName»_Listener_Mailer extends «ENDIF»«appName»_Listener_Base_Mailer
        {
            «new Mailer().generate(it, isBase)»
        }
    '''

    def private listenersPageFile(Application it, Boolean isBase) '''
        «fh.phpFileHeader(it)»
        /**
         * Event handler «IF isBase»base«ELSE»implementation«ENDIF» class for page-related events.
         */
        class «IF !isBase»«appName»_Listener_Page extends «ENDIF»«appName»_Listener_Base_Page
        {
            «new Page().generate(it, isBase)»
        }
    '''

    def private listenersErrorsFile(Application it, Boolean isBase) '''
        «fh.phpFileHeader(it)»
        /**
         * Event handler «IF isBase»base«ELSE»implementation«ENDIF» class for error-related events.
         */
        class «IF !isBase»«appName»_Listener_Errors extends «ENDIF»«appName»_Listener_Base_Errors
        {
            «new Errors().generate(it, isBase)»
        }
    '''

    def private listenersThemeFile(Application it, Boolean isBase) '''
        «fh.phpFileHeader(it)»
        /**
         * Event handler «IF isBase»base«ELSE»implementation«ENDIF» class for theme-related events.
         */
        class «IF !isBase»«appName»_Listener_Theme extends «ENDIF»«appName»_Listener_Base_Theme
        {
            «new Theme().generate(it, isBase)»
        }
    '''

    def private listenersViewFile(Application it, Boolean isBase) '''
        «fh.phpFileHeader(it)»
        /**
         * Event handler «IF isBase»base«ELSE»implementation«ENDIF» class for view-related events.
         */
        class «IF !isBase»«appName»_Listener_View extends «ENDIF»«appName»_Listener_Base_View
        {
            «new View().generate(it, isBase)»
        }
    '''

    def private listenersUserLoginFile(Application it, Boolean isBase) '''
        «fh.phpFileHeader(it)»
        /**
         * Event handler «IF isBase»base«ELSE»implementation«ENDIF» class for user login events.
         */
        class «IF !isBase»«appName»_Listener_UserLogin extends «ENDIF»«appName»_Listener_Base_UserLogin
        {
            «new UserLogin().generate(it, isBase)»
        }
    '''

    def private listenersUserLogoutFile(Application it, Boolean isBase) '''
        «fh.phpFileHeader(it)»
        /**
         * Event handler «IF isBase»base«ELSE»implementation«ENDIF» class for user logout events.
         */
        class «IF !isBase»«appName»_Listener_UserLogout extends «ENDIF»«appName»_Listener_Base_UserLogout
        {
            «new UserLogout().generate(it, isBase)»
        }
    '''

    def private listenersUserFile(Application it, Boolean isBase) '''
        «fh.phpFileHeader(it)»
        /**
         * Event handler «IF isBase»base«ELSE»implementation«ENDIF» class for user-related events.
         */
        class «IF !isBase»«appName»_Listener_User extends «ENDIF»«appName»_Listener_Base_User
        {
            «new User().generate(it, isBase)»
        }
    '''

    def private listenersUserRegistrationFile(Application it, Boolean isBase) '''
        «fh.phpFileHeader(it)»
        /**
         * Event handler «IF isBase»base«ELSE»implementation«ENDIF» class for user registration events.
         */
        class «IF !isBase»«appName»_Listener_UserRegistration extends «ENDIF»«appName»_Listener_Base_UserRegistration
        {
            «new UserRegistration().generate(it, isBase)»
        }
    '''

    def private listenersUsersFile(Application it, Boolean isBase) '''
        «fh.phpFileHeader(it)»
        /**
         * Event handler «IF isBase»base«ELSE»implementation«ENDIF» class for events of the Users module.
         */
        class «IF !isBase»«appName»_Listener_Users extends «ENDIF»«appName»_Listener_Base_Users
        {
            «new Users().generate(it, isBase)»
        }
    '''

    def private listenersGroupFile(Application it, Boolean isBase) '''
        «fh.phpFileHeader(it)»
        /**
         * Event handler implementation class for group-related events.
         */
        class «IF !isBase»«appName»_Listener_Group extends «ENDIF»«appName»_Listener_Base_Group
        {
            «new Group().generate(it, isBase)»
        }
    '''

    def private listenersThirdPartyFile(Application it, Boolean isBase) '''
        «fh.phpFileHeader(it)»
        /**
         * Event handler implementation class for special purposes and 3rd party api support.
         */
        class «IF !isBase»«appName»_Listener_ThirdParty extends «ENDIF»«appName»_Listener_Base_ThirdParty
        {
            «new ThirdParty().generate(it, isBase)»
        }
    '''
}
