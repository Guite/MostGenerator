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
        val listenerBasePath = getAppSourceLibPath + 'Listener/Base/'
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
        val listenerPath = getAppSourceLibPath + 'Listener/'
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
        «IF !targets('1.3.5')»
            namespace «appName»\Listener«IF isBase»\Base«ENDIF»;

        «ENDIF»
        /**
         * Event handler «IF isBase»base«ELSE»implementation«ENDIF» class for core events.
         */
        «IF targets('1.3.5')»
        class «IF !isBase»«appName»_Listener_Core extends «ENDIF»«appName»_Listener_Base_Core
        «ELSE»
        class CoreListener«IF !isBase» extends Base\CoreListener«ENDIF»
        «ENDIF»
        {
            «new Core().generate(it, isBase)»
        }
    '''

    def private listenersInstallerFile(Application it, Boolean isBase) '''
        «fh.phpFileHeader(it)»
        «IF !targets('1.3.5')»
            namespace «appName»\Listener«IF isBase»\Base«ENDIF»;

        «ENDIF»
        /**
         * Event handler «IF isBase»base«ELSE»implementation«ENDIF» class for module installer events.
         */
        «IF targets('1.3.5')»
        class «IF !isBase»«appName»_Listener_Installer extends «ENDIF»«appName»_Listener_Base_Installer
        «ELSE»
        class InstallerListener«IF !isBase» extends Base\InstallerListener«ENDIF»
        «ENDIF»
        {
            «new ModuleInstaller().generate(it, isBase)»
        }
    '''

    def private listenersModuleDispatchFile(Application it, Boolean isBase) '''
        «fh.phpFileHeader(it)»
        «IF !targets('1.3.5')»
            namespace «appName»\Listener«IF isBase»\Base«ENDIF»;

        «ENDIF»
        /**
         * Event handler «IF isBase»base«ELSE»implementation«ENDIF» class for dispatching modules.
         */
        «IF targets('1.3.5')»
        class «IF !isBase»«appName»_Listener_ModuleDispatch extends «ENDIF»«appName»_Listener_Base_ModuleDispatch
        «ELSE»
        class ModuleDispatchListener«IF !isBase» extends Base\ModuleDispatchListener«ENDIF»
        «ENDIF»
        {
            «new ModuleDispatch().generate(it, isBase)»
        }
    '''

    def private listenersMailerFile(Application it, Boolean isBase) '''
        «fh.phpFileHeader(it)»
        «IF !targets('1.3.5')»
            namespace «appName»\Listener«IF isBase»\Base«ENDIF»;

        «ENDIF»
        /**
         * Event handler «IF isBase»base«ELSE»implementation«ENDIF» class for mailing events.
         */
        «IF targets('1.3.5')»
        class «IF !isBase»«appName»_Listener_Mailer extends «ENDIF»«appName»_Listener_Base_Mailer
        «ELSE»
        class MailerListener«IF !isBase» extends Base\MailerListener«ENDIF»
        «ENDIF»
        {
            «new Mailer().generate(it, isBase)»
        }
    '''

    def private listenersPageFile(Application it, Boolean isBase) '''
        «fh.phpFileHeader(it)»
        «IF !targets('1.3.5')»
            namespace «appName»\Listener«IF isBase»\Base«ENDIF»;

        «ENDIF»
        /**
         * Event handler «IF isBase»base«ELSE»implementation«ENDIF» class for page-related events.
         */
        «IF targets('1.3.5')»
        class «IF !isBase»«appName»_Listener_Page extends «ENDIF»«appName»_Listener_Base_Page
        «ELSE»
        class PageListener«IF !isBase» extends Base\PageListener«ENDIF»
        «ENDIF»
        {
            «new Page().generate(it, isBase)»
        }
    '''

    def private listenersErrorsFile(Application it, Boolean isBase) '''
        «fh.phpFileHeader(it)»
        «IF !targets('1.3.5')»
            namespace «appName»\Listener«IF isBase»\Base«ENDIF»;

        «ENDIF»
        /**
         * Event handler «IF isBase»base«ELSE»implementation«ENDIF» class for error-related events.
         */
        «IF targets('1.3.5')»
        class «IF !isBase»«appName»_Listener_Errors extends «ENDIF»«appName»_Listener_Base_Errors
        «ELSE»
        class ErrorsListener«IF !isBase» extends Base\ErrorsListener«ENDIF»
        «ENDIF»
        {
            «new Errors().generate(it, isBase)»
        }
    '''

    def private listenersThemeFile(Application it, Boolean isBase) '''
        «fh.phpFileHeader(it)»
        «IF !targets('1.3.5')»
            namespace «appName»\Listener«IF isBase»\Base«ENDIF»;

        «ENDIF»
        /**
         * Event handler «IF isBase»base«ELSE»implementation«ENDIF» class for theme-related events.
         */
        «IF targets('1.3.5')»
        class «IF !isBase»«appName»_Listener_Theme extends «ENDIF»«appName»_Listener_Base_Theme
        «ELSE»
        class ThemeListener«IF !isBase» extends Base\ThemeListener«ENDIF»
        «ENDIF»
        {
            «new Theme().generate(it, isBase)»
        }
    '''

    def private listenersViewFile(Application it, Boolean isBase) '''
        «fh.phpFileHeader(it)»
        «IF !targets('1.3.5')»
            namespace «appName»\Listener«IF isBase»\Base«ENDIF»;

        «ENDIF»
        /**
         * Event handler «IF isBase»base«ELSE»implementation«ENDIF» class for view-related events.
         */
        «IF targets('1.3.5')»
        class «IF !isBase»«appName»_Listener_View extends «ENDIF»«appName»_Listener_Base_View
        «ELSE»
        class ViewListener«IF !isBase» extends Base\ViewListener«ENDIF»
        «ENDIF»
        {
            «new View().generate(it, isBase)»
        }
    '''

    def private listenersUserLoginFile(Application it, Boolean isBase) '''
        «fh.phpFileHeader(it)»
        «IF !targets('1.3.5')»
            namespace «appName»\Listener«IF isBase»\Base«ENDIF»;

        «ENDIF»
        /**
         * Event handler «IF isBase»base«ELSE»implementation«ENDIF» class for user login events.
         */
        «IF targets('1.3.5')»
        class «IF !isBase»«appName»_Listener_UserLogin extends «ENDIF»«appName»_Listener_Base_UserLogin
        «ELSE»
        class UserLoginListener«IF !isBase» extends Base\UserLoginListener«ENDIF»
        «ENDIF»
        {
            «new UserLogin().generate(it, isBase)»
        }
    '''

    def private listenersUserLogoutFile(Application it, Boolean isBase) '''
        «fh.phpFileHeader(it)»
        «IF !targets('1.3.5')»
            namespace «appName»\Listener«IF isBase»\Base«ENDIF»;

        «ENDIF»
        /**
         * Event handler «IF isBase»base«ELSE»implementation«ENDIF» class for user logout events.
         */
        «IF targets('1.3.5')»
        class «IF !isBase»«appName»_Listener_UserLogout extends «ENDIF»«appName»_Listener_Base_UserLogout
        «ELSE»
        class UserLogoutListener«IF !isBase» extends Base\UserLogoutListener«ENDIF»
        «ENDIF»
        {
            «new UserLogout().generate(it, isBase)»
        }
    '''

    def private listenersUserFile(Application it, Boolean isBase) '''
        «fh.phpFileHeader(it)»
        «IF !targets('1.3.5')»
            namespace «appName»\Listener«IF isBase»\Base«ENDIF»;

        «ENDIF»
        /**
         * Event handler «IF isBase»base«ELSE»implementation«ENDIF» class for user-related events.
         */
        «IF targets('1.3.5')»
        class «IF !isBase»«appName»_Listener_User extends «ENDIF»«appName»_Listener_Base_User
        «ELSE»
        class UserListener«IF !isBase» extends Base\UserListener«ENDIF»
        «ENDIF»
        {
            «new User().generate(it, isBase)»
        }
    '''

    def private listenersUserRegistrationFile(Application it, Boolean isBase) '''
        «fh.phpFileHeader(it)»
        «IF !targets('1.3.5')»
            namespace «appName»\Listener«IF isBase»\Base«ENDIF»;

        «ENDIF»
        /**
         * Event handler «IF isBase»base«ELSE»implementation«ENDIF» class for user registration events.
         */
        «IF targets('1.3.5')»
        class «IF !isBase»«appName»_Listener_UserRegistration extends «ENDIF»«appName»_Listener_Base_UserRegistration
        «ELSE»
        class UserRegistrationListener«IF !isBase» extends Base\UserRegistrationListener«ENDIF»
        «ENDIF»
        {
            «new UserRegistration().generate(it, isBase)»
        }
    '''

    def private listenersUsersFile(Application it, Boolean isBase) '''
        «fh.phpFileHeader(it)»
        «IF !targets('1.3.5')»
            namespace «appName»\Listener«IF isBase»\Base«ENDIF»;

        «ENDIF»
        /**
         * Event handler «IF isBase»base«ELSE»implementation«ENDIF» class for events of the Users module.
         */
        «IF targets('1.3.5')»
        class «IF !isBase»«appName»_Listener_Users extends «ENDIF»«appName»_Listener_Base_Users
        «ELSE»
        class UsersListener«IF !isBase» extends Base\UsersListener«ENDIF»
        «ENDIF»
        {
            «new Users().generate(it, isBase)»
        }
    '''

    def private listenersGroupFile(Application it, Boolean isBase) '''
        «fh.phpFileHeader(it)»
        «IF !targets('1.3.5')»
            namespace «appName»\Listener«IF isBase»\Base«ENDIF»;

        «ENDIF»
        /**
         * Event handler implementation class for group-related events.
         */
        «IF targets('1.3.5')»
        class «IF !isBase»«appName»_Listener_Group extends «ENDIF»«appName»_Listener_Base_Group
        «ELSE»
        class GroupListener«IF !isBase» extends Base\GroupListener«ENDIF»
        «ENDIF»
        {
            «new Group().generate(it, isBase)»
        }
    '''

    def private listenersThirdPartyFile(Application it, Boolean isBase) '''
        «fh.phpFileHeader(it)»
        «IF !targets('1.3.5')»
            namespace «appName»\Listener«IF isBase»\Base«ENDIF»;

        «ENDIF»
        /**
         * Event handler implementation class for special purposes and 3rd party api support.
         */
        «IF targets('1.3.5')»
        class «IF !isBase»«appName»_Listener_ThirdParty extends «ENDIF»«appName»_Listener_Base_ThirdParty
        «ELSE»
        class ThirdPartyListener«IF !isBase» extends Base\ThirdPartyListener«ENDIF»
        «ENDIF»
        {
            «new ThirdParty().generate(it, isBase)»
        }
    '''
}
