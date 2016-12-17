package org.zikula.modulestudio.generator.cartridges.zclassic.controller

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener.Core
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener.ErrorsLegacy
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener.FrontControllerLegacy
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener.Group
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener.Kernel
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
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.GeneratorSettingsExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils
import org.zikula.modulestudio.generator.extensions.WorkflowExtensions

class Listeners {
    extension ControllerExtensions = new ControllerExtensions
    extension GeneratorSettingsExtensions = new GeneratorSettingsExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelExtensions = new ModelExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils
    extension WorkflowExtensions = new WorkflowExtensions

    FileHelper fh = new FileHelper
    IFileSystemAccess fsa
    Application app
    Boolean isBase
    Boolean needsThirdPartyListener

    String listenerPath
    String listenerSuffix

    /**
     * Entry point for event subscribers.
     */
    def generate(Application it, IFileSystemAccess fsa) {
        this.fsa = fsa
        this.app = it
        listenerSuffix = (if (targets('1.3.x')) '' else 'Listener') + '.php'

        val needsDetailContentType = generateDetailContentType && hasUserController && getMainUserController.hasActions('display')
        needsThirdPartyListener = (generatePendingContentSupport || generateListContentType || needsDetailContentType || (!targets('1.3.x') && generateScribitePlugins))

        println('Generating event listener base classes')
        listenerPath = getAppSourceLibPath + 'Listener/Base/'
        isBase = true
        generateListenerClasses

        if (generateOnlyBaseClasses) {
            return
        }

        println('Generating event listener implementation classes')
        listenerPath = getAppSourceLibPath + 'Listener/'
        isBase = false
        generateListenerClasses
    }

    def private generateListenerClasses(Application it) {
        listenerFile('Core', listenersCoreFile)
        if (targets('1.3.x')) {
            listenerFile('FrontController', listenersFrontControllerFile)
        } else {
            listenerFile('Kernel', listenersKernelFile)
        }
        listenerFile('Installer', listenersInstallerFile)
        listenerFile('ModuleDispatch', listenersModuleDispatchFile)
        listenerFile('Mailer', listenersMailerFile)
        listenerFile('Page', listenersPageFile)
        if (targets('1.3.x')) {
            listenerFile('Errors', listenersErrorsFile)
        }
        listenerFile('Theme', listenersThemeFile)
        listenerFile('View', listenersViewFile)
        listenerFile('UserLogin', listenersUserLoginFile)
        listenerFile('UserLogout', listenersUserLogoutFile)
        listenerFile('User', listenersUserFile)
        listenerFile('UserRegistration', listenersUserRegistrationFile)
        listenerFile('Users', listenersUsersFile)
        listenerFile('Group', listenersGroupFile)

        if (needsThirdPartyListener) {
            listenerFile('ThirdParty', listenersThirdPartyFile)
        }
    }

    def private listenerFile(String name, CharSequence content) {
        var filePath = listenerPath + (if (isBase) 'Abstract' else '') + name + listenerSuffix
        if (!app.shouldBeSkipped(filePath)) {
            if (app.shouldBeMarked(filePath)) {
                filePath = listenerPath + name + listenerSuffix.replace('.php', '.generated.php')
            }
            fsa.generateFile(filePath, fh.phpFileContent(app, content))
        }
    }

    def private listenersCoreFile(Application it) '''
        «IF !targets('1.3.x')»
            namespace «appNamespace»\Listener«IF isBase»\Base«ENDIF»;

            «IF !isBase»
                use «appNamespace»\Listener\Base\AbstractCoreListener;
            «ELSE»
                use Symfony\Component\EventDispatcher\EventSubscriberInterface;
                use Symfony\Component\HttpKernel\HttpKernelInterface;
            «ENDIF»
            use Zikula\Core\Event\GenericEvent;

        «ENDIF»
        /**
         * Event handler «IF isBase»base«ELSE»implementation«ENDIF» class for core events.
         */
        «IF targets('1.3.x')»
        «IF isBase»abstract «ENDIF»class «IF !isBase»«appName»_Listener_Core extends «ENDIF»«appName»_Listener_Base_AbstractCore
        «ELSE»
        «IF isBase»abstract «ENDIF»class «IF isBase»Abstract«ENDIF»CoreListener«IF !isBase» extends AbstractCoreListener«ELSE» implements EventSubscriberInterface«ENDIF»
        «ENDIF»
        {
            «new Core().generate(it, isBase)»
        }
    '''

    // obsolete, used for 1.3.x only
    def private listenersFrontControllerFile(Application it) '''
        /**
         * Event handler «IF isBase»base«ELSE»implementation«ENDIF» class for frontend controller interaction events.
         */
        «IF isBase»abstract «ENDIF»class «IF !isBase»«appName»_Listener_FrontController extends «ENDIF»«appName»_Listener_Base_AbstractFrontController
        {
            «new FrontControllerLegacy().generate(it, isBase)»
        }
    '''

    def private listenersInstallerFile(Application it) '''
        «IF !targets('1.3.x')»
            namespace «appNamespace»\Listener«IF isBase»\Base«ENDIF»;

            «IF !isBase»
                use «appNamespace»\Listener\Base\AbstractInstallerListener;
            «ELSE»
                use Symfony\Component\EventDispatcher\EventSubscriberInterface;
                use Symfony\Component\HttpKernel\HttpKernelInterface;
                use Zikula\Core\CoreEvents;
            «ENDIF»
            use Zikula\Core\Event\GenericEvent;
            use Zikula\Core\Event\ModuleStateEvent;

        «ENDIF»
        /**
         * Event handler «IF isBase»base«ELSE»implementation«ENDIF» class for module installer events.
         */
        «IF targets('1.3.x')»
        «IF isBase»abstract «ENDIF»class «IF !isBase»«appName»_Listener_Installer extends «ENDIF»«appName»_Listener_Base_AbstractInstaller
        «ELSE»
        «IF isBase»abstract «ENDIF»class «IF isBase»Abstract«ENDIF»InstallerListener«IF !isBase» extends AbstractInstallerListener«ELSE» implements EventSubscriberInterface«ENDIF»
        «ENDIF»
        {
            «new ModuleInstaller().generate(it, isBase)»
        }
    '''

    // used for 1.4.x only
    def private listenersKernelFile(Application it) '''
        namespace «appNamespace»\Listener«IF isBase»\Base«ENDIF»;

        «IF !isBase»
            use «appNamespace»\Listener\Base\AbstractKernelListener;
        «ELSE»
            use Symfony\Component\EventDispatcher\EventSubscriberInterface;
            use Symfony\Component\HttpKernel\KernelEvents;
        «ENDIF»
        use Symfony\Component\HttpKernel\Event\FilterControllerEvent;
        use Symfony\Component\HttpKernel\Event\FilterResponseEvent;
        use Symfony\Component\HttpKernel\Event\FinishRequestEvent;
        use Symfony\Component\HttpKernel\Event\GetResponseEvent;
        use Symfony\Component\HttpKernel\Event\GetResponseForControllerResultEvent;
        use Symfony\Component\HttpKernel\Event\GetResponseForExceptionEvent;
        use Symfony\Component\HttpKernel\Event\PostResponseEvent;
        use Symfony\Component\HttpKernel\Exception\HttpExceptionInterface;
        use Symfony\Component\HttpFoundation\Response;

        /**
         * Event handler «IF isBase»base«ELSE»implementation«ENDIF» class for Symfony kernel events.
         */
        «IF isBase»abstract «ENDIF»class «IF isBase»Abstract«ENDIF»KernelListener«IF !isBase» extends AbstractKernelListener«ELSE» implements EventSubscriberInterface«ENDIF»
        {
            «new Kernel().generate(it, isBase)»
        }
    '''

    def private listenersModuleDispatchFile(Application it) '''
        «IF !targets('1.3.x')»
            namespace «appNamespace»\Listener«IF isBase»\Base«ENDIF»;

            «IF !isBase»
                use «appNamespace»\Listener\Base\AbstractModuleDispatchListener;
            «ELSE»
                use Symfony\Component\EventDispatcher\EventSubscriberInterface;
            «ENDIF»
            use Zikula\Core\Event\GenericEvent;

        «ENDIF»
        /**
         * Event handler «IF isBase»base«ELSE»implementation«ENDIF» class for dispatching modules.
         */
        «IF targets('1.3.x')»
        «IF isBase»abstract «ENDIF»class «IF !isBase»«appName»_Listener_ModuleDispatch extends «ENDIF»«appName»_Listener_Base_AbstractModuleDispatch
        «ELSE»
        «IF isBase»abstract «ENDIF»class «IF isBase»Abstract«ENDIF»ModuleDispatchListener«IF !isBase» extends AbstractModuleDispatchListener«ELSE» implements EventSubscriberInterface«ENDIF»
        «ENDIF»
        {
            «new ModuleDispatch().generate(it, isBase)»
        }
    '''

    def private listenersMailerFile(Application it) '''
        «IF !targets('1.3.x')»
            namespace «appNamespace»\Listener«IF isBase»\Base«ENDIF»;

            «IF !isBase»
                use «appNamespace»\Listener\Base\AbstractMailerListener;
            «ELSE»
                use Symfony\Component\EventDispatcher\EventSubscriberInterface;
                use Symfony\Component\HttpKernel\HttpKernelInterface;
                use Zikula\MailerModule\MailerEvents;
            «ENDIF»
            use Zikula\Core\Event\GenericEvent;

        «ENDIF»
        /**
         * Event handler «IF isBase»base«ELSE»implementation«ENDIF» class for mailing events.
         */
        «IF targets('1.3.x')»
        «IF isBase»abstract «ENDIF»class «IF !isBase»«appName»_Listener_Mailer extends «ENDIF»«appName»_Listener_Base_AbstractMailer
        «ELSE»
        «IF isBase»abstract «ENDIF»class «IF isBase»Abstract«ENDIF»MailerListener«IF !isBase» extends AbstractMailerListener«ELSE» implements EventSubscriberInterface«ENDIF»
        «ENDIF»
        {
            «new Mailer().generate(it, isBase)»
        }
    '''

    def private listenersPageFile(Application it) '''
        «IF !targets('1.3.x')»
            namespace «appNamespace»\Listener«IF isBase»\Base«ENDIF»;

            «IF !isBase»
                use «appNamespace»\Listener\Base\AbstractPageListener;
            «ELSE»
                use Symfony\Component\EventDispatcher\EventSubscriberInterface;
            «ENDIF»
            use Zikula\Core\Event\GenericEvent;

        «ENDIF»
        /**
         * Event handler «IF isBase»base«ELSE»implementation«ENDIF» class for page-related events.
         */
        «IF targets('1.3.x')»
        «IF isBase»abstract «ENDIF»class «IF !isBase»«appName»_Listener_Page extends «ENDIF»«appName»_Listener_Base_AbstractPage
        «ELSE»
        «IF isBase»abstract «ENDIF»class «IF isBase»Abstract«ENDIF»PageListener«IF !isBase» extends AbstractPageListener«ELSE» implements EventSubscriberInterface«ENDIF»
        «ENDIF»
        {
            «new Page().generate(it, isBase)»
        }
    '''

    // obsolete, used for 1.3.x only
    def private listenersErrorsFile(Application it) '''
        /**
         * Event handler «IF isBase»base«ELSE»implementation«ENDIF» class for error-related events.
         */
        «IF isBase»abstract «ENDIF»class «IF !isBase»«appName»_Listener_Errors extends «ENDIF»«appName»_Listener_Base_AbstractErrors
        {
            «new ErrorsLegacy().generate(it, isBase)»
        }
    '''

    def private listenersThemeFile(Application it) '''
        «IF !targets('1.3.x')»
            namespace «appNamespace»\Listener«IF isBase»\Base«ENDIF»;

            «IF !isBase»
                use «appNamespace»\Listener\Base\AbstractThemeListener;
            «ELSE»
                use Symfony\Component\EventDispatcher\EventSubscriberInterface;
                use Zikula\ThemeModule\ThemeEvents;
            «ENDIF»
            use Zikula\ThemeModule\Bridge\Event\TwigPostRenderEvent;
            use Zikula\ThemeModule\Bridge\Event\TwigPreRenderEvent;
            use Zikula\Core\Event\GenericEvent;

        «ENDIF»
        /**
         * Event handler «IF isBase»base«ELSE»implementation«ENDIF» class for theme-related events.
         */
        «IF targets('1.3.x')»
        «IF isBase»abstract «ENDIF»class «IF !isBase»«appName»_Listener_Theme extends «ENDIF»«appName»_Listener_Base_AbstractTheme
        «ELSE»
        «IF isBase»abstract «ENDIF»class «IF isBase»Abstract«ENDIF»ThemeListener«IF !isBase» extends AbstractThemeListener«ELSE» implements EventSubscriberInterface«ENDIF»
        «ENDIF»
        {
            «new Theme().generate(it, isBase)»
        }
    '''

    def private listenersViewFile(Application it) '''
        «IF !targets('1.3.x')»
            namespace «appNamespace»\Listener«IF isBase»\Base«ENDIF»;

            «IF !isBase»
                use «appNamespace»\Listener\Base\AbstractViewListener;
            «ELSE»
                use Symfony\Component\EventDispatcher\EventSubscriberInterface;
            «ENDIF»
            use Zikula\Core\Event\GenericEvent;

        «ENDIF»
        /**
         * Event handler «IF isBase»base«ELSE»implementation«ENDIF» class for view-related events.
         */
        «IF targets('1.3.x')»
        «IF isBase»abstract «ENDIF»class «IF !isBase»«appName»_Listener_View extends «ENDIF»«appName»_Listener_Base_AbstractView
        «ELSE»
        «IF isBase»abstract «ENDIF»class «IF isBase»Abstract«ENDIF»ViewListener«IF !isBase» extends AbstractViewListener«ELSE» implements EventSubscriberInterface«ENDIF»
        «ENDIF»
        {
            «new View().generate(it, isBase)»
        }
    '''

    def private listenersUserLoginFile(Application it) '''
        «IF !targets('1.3.x')»
            namespace «appNamespace»\Listener«IF isBase»\Base«ENDIF»;

            «IF !isBase»
                use «appNamespace»\Listener\Base\AbstractUserLoginListener;
            «ELSE»
                use Symfony\Component\EventDispatcher\EventSubscriberInterface;
            «ENDIF»
            use Zikula\Core\Event\GenericEvent;
            «IF isBase»
                use Zikula\UsersModule\AccessEvents;
            «ENDIF»

        «ENDIF»
        /**
         * Event handler «IF isBase»base«ELSE»implementation«ENDIF» class for user login events.
         */
        «IF targets('1.3.x')»
        «IF isBase»abstract «ENDIF»class «IF !isBase»«appName»_Listener_UserLogin extends «ENDIF»«appName»_Listener_Base_AbstractUserLogin
        «ELSE»
        «IF isBase»abstract «ENDIF»class «IF isBase»Abstract«ENDIF»UserLoginListener«IF !isBase» extends AbstractUserLoginListener«ELSE» implements EventSubscriberInterface«ENDIF»
        «ENDIF»
        {
            «new UserLogin().generate(it, isBase)»
        }
    '''

    def private listenersUserLogoutFile(Application it) '''
        «IF !targets('1.3.x')»
            namespace «appNamespace»\Listener«IF isBase»\Base«ENDIF»;

            «IF !isBase»
                use «appNamespace»\Listener\Base\AbstractUserLogoutListener;
            «ELSE»
                use Symfony\Component\EventDispatcher\EventSubscriberInterface;
            «ENDIF»
            use Zikula\Core\Event\GenericEvent;
            «IF isBase»
                use Zikula\UsersModule\AccessEvents;
            «ENDIF»

        «ENDIF»
        /**
         * Event handler «IF isBase»base«ELSE»implementation«ENDIF» class for user logout events.
         */
        «IF targets('1.3.x')»
        «IF isBase»abstract «ENDIF»class «IF !isBase»«appName»_Listener_UserLogout extends «ENDIF»«appName»_Listener_Base_AbstractUserLogout
        «ELSE»
        «IF isBase»abstract «ENDIF»class «IF isBase»Abstract«ENDIF»UserLogoutListener«IF !isBase» extends AbstractUserLogoutListener«ELSE» implements EventSubscriberInterface«ENDIF»
        «ENDIF»
        {
            «new UserLogout().generate(it, isBase)»
        }
    '''

    def private listenersUserFile(Application it) '''
        «IF !targets('1.3.x')»
            namespace «appNamespace»\Listener«IF isBase»\Base«ENDIF»;

            «IF !isBase»
                use «appNamespace»\Listener\Base\AbstractUserListener;
            «ELSE»
                «IF hasStandardFieldEntities || hasUserFields»
                    use ServiceUtil;
                «ENDIF»
                use Symfony\Component\EventDispatcher\EventSubscriberInterface;
                use Symfony\Component\HttpKernel\HttpKernelInterface;
                use UserUtil;
            «ENDIF»
            use Zikula\Core\Event\GenericEvent;
            «IF isBase»
                use Zikula\UsersModule\UserEvents;
            «ENDIF»

        «ENDIF»
        /**
         * Event handler «IF isBase»base«ELSE»implementation«ENDIF» class for user-related events.
         */
        «IF targets('1.3.x')»
        «IF isBase»abstract «ENDIF»class «IF !isBase»«appName»_Listener_User extends «ENDIF»«appName»_Listener_Base_AbstractUser
        «ELSE»
        «IF isBase»abstract «ENDIF»class «IF isBase»Abstract«ENDIF»UserListener«IF !isBase» extends AbstractUserListener«ELSE» implements EventSubscriberInterface«ENDIF»
        «ENDIF»
        {
            «new User().generate(it, isBase)»
        }
    '''

    def private listenersUserRegistrationFile(Application it) '''
        «IF !targets('1.3.x')»
            namespace «appNamespace»\Listener«IF isBase»\Base«ENDIF»;

            «IF !isBase»
                use «appNamespace»\Listener\Base\AbstractUserRegistrationListener;
            «ELSE»
                use Symfony\Component\EventDispatcher\EventSubscriberInterface;
            «ENDIF»
            use Zikula\Core\Event\GenericEvent;
            «IF isBase»
                use Zikula\UsersModule\RegistrationEvents;
            «ENDIF»

        «ENDIF»
        /**
         * Event handler «IF isBase»base«ELSE»implementation«ENDIF» class for user registration events.
         */
        «IF targets('1.3.x')»
        «IF isBase»abstract «ENDIF»class «IF !isBase»«appName»_Listener_UserRegistration extends «ENDIF»«appName»_Listener_Base_AbstractUserRegistration
        «ELSE»
        «IF isBase»abstract «ENDIF»class «IF isBase»Abstract«ENDIF»UserRegistrationListener«IF !isBase» extends AbstractUserRegistrationListener«ELSE» implements EventSubscriberInterface«ENDIF»
        «ENDIF»
        {
            «new UserRegistration().generate(it, isBase)»
        }
    '''

    def private listenersUsersFile(Application it) '''
        «IF !targets('1.3.x')»
            namespace «appNamespace»\Listener«IF isBase»\Base«ENDIF»;

            «IF !isBase»
                use «appNamespace»\Listener\Base\AbstractUsersListener;
            «ELSE»
                use Symfony\Component\EventDispatcher\EventSubscriberInterface;
            «ENDIF»
            use Zikula\Core\Event\GenericEvent;
            «IF isBase»
                use Zikula\UsersModule\UserEvents;
            «ENDIF»

        «ENDIF»
        /**
         * Event handler «IF isBase»base«ELSE»implementation«ENDIF» class for events of the Users module.
         */
        «IF targets('1.3.x')»
        «IF isBase»abstract «ENDIF»class «IF !isBase»«appName»_Listener_Users extends «ENDIF»«appName»_Listener_Base_AbstractUsers
        «ELSE»
        «IF isBase»abstract «ENDIF»class «IF isBase»Abstract«ENDIF»UsersListener«IF !isBase» extends AbstractUsersListener«ELSE» implements EventSubscriberInterface«ENDIF»
        «ENDIF»
        {
            «new Users().generate(it, isBase)»
        }
    '''

    def private listenersGroupFile(Application it) '''
        «IF !targets('1.3.x')»
            namespace «appNamespace»\Listener«IF isBase»\Base«ENDIF»;

            «IF !isBase»
                use «appNamespace»\Listener\Base\AbstractGroupListener;
            «ELSE»
                use Symfony\Component\EventDispatcher\EventSubscriberInterface;
            «ENDIF»
            use Zikula\Core\Event\GenericEvent;

        «ENDIF»
        /**
         * Event handler implementation class for group-related events.
         */
        «IF targets('1.3.x')»
        «IF isBase»abstract «ENDIF»class «IF !isBase»«appName»_Listener_Group extends «ENDIF»«appName»_Listener_Base_AbstractGroup
        «ELSE»
        «IF isBase»abstract «ENDIF»class «IF isBase»Abstract«ENDIF»GroupListener«IF !isBase» extends AbstractGroupListener«ELSE» implements EventSubscriberInterface«ENDIF»
        «ENDIF»
        {
            «new Group().generate(it, isBase)»
        }
    '''

    def private listenersThirdPartyFile(Application it) '''
        «IF !targets('1.3.x')»
            namespace «appNamespace»\Listener«IF isBase»\Base«ENDIF»;

            «IF !isBase»
                use «appNamespace»\Listener\Base\AbstractThirdPartyListener;
            «ELSE»
                use Symfony\Component\EventDispatcher\EventSubscriberInterface;
                use Symfony\Component\HttpKernel\HttpKernelInterface;
                «IF needsApproval && generatePendingContentSupport»
                    use ServiceUtil;
                    use Zikula\Collection\Container;
                «ENDIF»
            «ENDIF»
            use Zikula\Core\Event\GenericEvent;
            «IF isBase»
                «IF needsApproval && generatePendingContentSupport»
                    use Zikula\Provider\AggregateItem;
                «ENDIF»
            «ENDIF»

        «ENDIF»
        /**
         * Event handler implementation class for special purposes and 3rd party api support.
         */
        «IF targets('1.3.x')»
        «IF isBase»abstract «ENDIF»class «IF !isBase»«appName»_Listener_ThirdParty extends «ENDIF»«appName»_Listener_Base_AbstractThirdParty
        «ELSE»
        «IF isBase»abstract «ENDIF»class «IF isBase»Abstract«ENDIF»ThirdPartyListener«IF !isBase» extends AbstractThirdPartyListener«ELSE» implements EventSubscriberInterface«ENDIF»
        «ENDIF»
        {
            «new ThirdParty().generate(it, isBase)»
        }
    '''
}
