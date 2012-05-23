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
        println('Generating event listeners')
        val listenerPath = getAppSourceLibPath(appName) + 'Listener/'
        fsa.generateFile(listenerPath + 'Core.php', listenersCoreFile)
        fsa.generateFile(listenerPath + 'Installer.php', listenersInstallerFile)
        fsa.generateFile(listenerPath + 'ModuleDispatch.php', listenersModuleDispatchFile)
        fsa.generateFile(listenerPath + 'Mailer.php', listenersMailerFile)
        fsa.generateFile(listenerPath + 'Page.php', listenersPageFile)
        fsa.generateFile(listenerPath + 'Errors.php', listenersErrorsFile)
        fsa.generateFile(listenerPath + 'Theme.php', listenersThemeFile)
        fsa.generateFile(listenerPath + 'View.php', listenersViewFile)
        fsa.generateFile(listenerPath + 'UserLogin.php', listenersUserLoginFile)
        fsa.generateFile(listenerPath + 'UserLogout.php', listenersUserLogoutFile)
        fsa.generateFile(listenerPath + 'User.php', listenersUserFile)
        fsa.generateFile(listenerPath + 'UserRegistration.php', listenersUserRegistrationFile)
        fsa.generateFile(listenerPath + 'Users.php', listenersUsersFile)
        fsa.generateFile(listenerPath + 'Group.php', listenersGroupFile)
        fsa.generateFile(listenerPath + 'ThirdParty.php', listenersThirdPartyFile)
    }

    def private listenersCoreFile(Application it) '''
    	«fh.phpFileHeader(it)»
    	/**
    	 * Event handler implementation class for core events.
    	 */
    	class «appName»_Listener_Core
    	{
    	    «new Core().generate(it)»
    	}
    '''

    def private listenersInstallerFile(Application it) '''
    	«fh.phpFileHeader(it)»
    	/**
    	 * Event handler implementation class for module installer events.
    	 */
    	class «appName»_Listener_Installer
    	{
    	    «new ModuleInstaller().generate(it)»
    	}
    '''

    def private listenersModuleDispatchFile(Application it) '''
    	«fh.phpFileHeader(it)»
    	/**
    	 * Event handler implementation class for dispatching modules.
    	 */
    	class «appName»_Listener_ModuleDispatch
    	{
    	    «new ModuleDispatch().generate(it)»
    	}
    '''

    def private listenersMailerFile(Application it) '''
    	«fh.phpFileHeader(it)»
    	/**
    	 * Event handler implementation class for mailing events.
    	 */
    	class «appName»_Listener_Mailer
    	{
    	    «new Mailer().generate(it)»
    	}
    '''

    def private listenersPageFile(Application it) '''
    	«fh.phpFileHeader(it)»
    	/**
    	 * Event handler implementation class for page-related events.
    	 */
    	class «appName»_Listener_Page
    	{
    	    «new Page().generate(it)»
    	}
    '''

    def private listenersErrorsFile(Application it) '''
    	«fh.phpFileHeader(it)»
    	/**
    	 * Event handler implementation class for error-related events.
    	 */
    	class «appName»_Listener_Errors
    	{
    	    «new Errors().generate(it)»
    	}
    '''

    def private listenersThemeFile(Application it) '''
    	«fh.phpFileHeader(it)»
    	/**
    	 * Event handler implementation class for theme-related events.
    	 */
    	class «appName»_Listener_Theme
    	{
    	    «new Theme().generate(it)»
    	}
    '''

    def private listenersViewFile(Application it) '''
    	«fh.phpFileHeader(it)»
    	/**
    	 * Event handler implementation class for view-related events.
    	 */
    	class «appName»_Listener_View
    	{
    	    «new View().generate(it)»
    	}
    '''

    def private listenersUserLoginFile(Application it) '''
    	«fh.phpFileHeader(it)»
    	/**
    	 * Event handler implementation class for user login events.
    	 */
    	class «appName»_Listener_UserLogin
    	{
    	    «new UserLogin().generate(it)»
    	}
    '''

    def private listenersUserLogoutFile(Application it) '''
    	«fh.phpFileHeader(it)»
    	/**
    	 * Event handler implementation class for user logout events.
    	 */
    	class «appName»_Listener_UserLogout
    	{
    	    «new UserLogout().generate(it)»
    	}
    '''

    def private listenersUserFile(Application it) '''
    	«fh.phpFileHeader(it)»
    	/**
    	 * Event handler implementation class for user-related events.
    	 */
    	class «appName»_Listener_User
    	{
    	    «new User().generate(it)»
    	}
    '''

    def private listenersUserRegistrationFile(Application it) '''
    	«fh.phpFileHeader(it)»
    	/**
    	 * Event handler implementation class for user registration events.
    	 */
    	class «appName»_Listener_UserRegistration
    	{
    	    «new UserRegistration().generate(it)»
    	}
    '''

    def private listenersUsersFile(Application it) '''
    	«fh.phpFileHeader(it)»
    	/**
    	 * Event handler implementation class for events of the Users module.
    	 */
    	class «appName»_Listener_Users
    	{
     	    «new Users().generate(it)»
    	}
    '''

    def private listenersGroupFile(Application it) '''
    	«fh.phpFileHeader(it)»
    	/**
    	 * Event handler implementation class for group-related events.
    	 */
    	class «appName»_Listener_Group
    	{
    	    «new Group().generate(it)»
    	}
    '''

    def private listenersThirdPartyFile(Application it) '''
    	«fh.phpFileHeader(it)»
    	/**
    	 * Event handler implementation class for special purposes and 3rd party api support.
    	 */
    	class «appName»_Listener_ThirdParty
    	{
    	    «new ThirdParty().generate(it)»
    	}
    '''
}
