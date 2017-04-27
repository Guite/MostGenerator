package org.zikula.modulestudio.generator.cartridges.zclassic.controller

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener.Group
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener.IpTrace
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener.Kernel
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener.Mailer
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener.ModuleDispatch
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener.ModuleInstaller
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener.Theme
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener.ThirdParty
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener.User
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener.UserLogin
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener.UserLogout
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener.UserRegistration
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener.Users
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener.WorkflowEvents
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
        listenerSuffix = 'Listener.php'

        val needsDetailContentType = generateDetailContentType && hasDisplayActions
        needsThirdPartyListener = (generatePendingContentSupport || generateListContentType || needsDetailContentType || generateScribitePlugins)

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
        listenerFile('Kernel', listenersKernelFile)
        listenerFile('Installer', listenersInstallerFile)
        listenerFile('ModuleDispatch', listenersModuleDispatchFile)
        listenerFile('Mailer', listenersMailerFile)
        listenerFile('Theme', listenersThemeFile)
        listenerFile('UserLogin', listenersUserLoginFile)
        listenerFile('UserLogout', listenersUserLogoutFile)
        listenerFile('User', listenersUserFile)
        listenerFile('UserRegistration', listenersUserRegistrationFile)
        listenerFile('Users', listenersUsersFile)
        listenerFile('Group', listenersGroupFile)

        if (needsThirdPartyListener) {
            listenerFile('ThirdParty', listenersThirdPartyFile)
        }
        if (!getAllEntities.filter[hasIpTraceableFields].empty) {
            listenerFile('IpTrace', listenersIpTraceFile)
        }
        if (targets('1.5')) {
            listenerFile('WorkflowEvents', listenersWorkflowEventsFile)
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

    def private listenersInstallerFile(Application it) '''
        namespace «appNamespace»\Listener«IF isBase»\Base«ENDIF»;

        «IF !isBase»
            use «appNamespace»\Listener\Base\AbstractInstallerListener;
        «ELSE»
            use Symfony\Component\EventDispatcher\EventSubscriberInterface;
            use Zikula\Core\CoreEvents;
        «ENDIF»
        use Zikula\Core\Event\GenericEvent;
        use Zikula\Core\Event\ModuleStateEvent;

        /**
         * Event handler «IF isBase»base«ELSE»implementation«ENDIF» class for module installer events.
         */
        «IF isBase»abstract «ENDIF»class «IF isBase»Abstract«ENDIF»InstallerListener«IF !isBase» extends AbstractInstallerListener«ELSE» implements EventSubscriberInterface«ENDIF»
        {
            «new ModuleInstaller().generate(it, isBase)»
        }
    '''

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

        /**
         * Event handler «IF isBase»base«ELSE»implementation«ENDIF» class for Symfony kernel events.
         */
        «IF isBase»abstract «ENDIF»class «IF isBase»Abstract«ENDIF»KernelListener«IF !isBase» extends AbstractKernelListener«ELSE» implements EventSubscriberInterface«ENDIF»
        {
            «new Kernel().generate(it, isBase)»
        }
    '''

    def private listenersModuleDispatchFile(Application it) '''
        namespace «appNamespace»\Listener«IF isBase»\Base«ENDIF»;

        «IF !isBase»
            use «appNamespace»\Listener\Base\AbstractModuleDispatchListener;
        «ELSE»
            use Symfony\Component\EventDispatcher\EventSubscriberInterface;
        «ENDIF»
        use Zikula\Core\Event\GenericEvent;

        /**
         * Event handler «IF isBase»base«ELSE»implementation«ENDIF» class for dispatching modules.
         */
        «IF isBase»abstract «ENDIF»class «IF isBase»Abstract«ENDIF»ModuleDispatchListener«IF !isBase» extends AbstractModuleDispatchListener«ELSE» implements EventSubscriberInterface«ENDIF»
        {
            «new ModuleDispatch().generate(it, isBase)»
        }
    '''

    def private listenersMailerFile(Application it) '''
        namespace «appNamespace»\Listener«IF isBase»\Base«ENDIF»;

        «IF !isBase»
            use «appNamespace»\Listener\Base\AbstractMailerListener;
        «ELSE»
            use Symfony\Component\EventDispatcher\EventSubscriberInterface;
            use Zikula\MailerModule\MailerEvents;
        «ENDIF»
        use Zikula\Core\Event\GenericEvent;

        /**
         * Event handler «IF isBase»base«ELSE»implementation«ENDIF» class for mailing events.
         */
        «IF isBase»abstract «ENDIF»class «IF isBase»Abstract«ENDIF»MailerListener«IF !isBase» extends AbstractMailerListener«ELSE» implements EventSubscriberInterface«ENDIF»
        {
            «new Mailer().generate(it, isBase)»
        }
    '''

    def private listenersThemeFile(Application it) '''
        namespace «appNamespace»\Listener«IF isBase»\Base«ENDIF»;

        «IF !isBase»
            use «appNamespace»\Listener\Base\AbstractThemeListener;
        «ELSE»
            use Symfony\Component\EventDispatcher\EventSubscriberInterface;
            use Zikula\ThemeModule\ThemeEvents;
        «ENDIF»
        use Zikula\ThemeModule\Bridge\Event\TwigPostRenderEvent;
        use Zikula\ThemeModule\Bridge\Event\TwigPreRenderEvent;

        /**
         * Event handler «IF isBase»base«ELSE»implementation«ENDIF» class for theme-related events.
         */
        «IF isBase»abstract «ENDIF»class «IF isBase»Abstract«ENDIF»ThemeListener«IF !isBase» extends AbstractThemeListener«ELSE» implements EventSubscriberInterface«ENDIF»
        {
            «new Theme().generate(it, isBase)»
        }
    '''

    def private listenersUserLoginFile(Application it) '''
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

        /**
         * Event handler «IF isBase»base«ELSE»implementation«ENDIF» class for user login events.
         */
        «IF isBase»abstract «ENDIF»class «IF isBase»Abstract«ENDIF»UserLoginListener«IF !isBase» extends AbstractUserLoginListener«ELSE» implements EventSubscriberInterface«ENDIF»
        {
            «new UserLogin().generate(it, isBase)»
        }
    '''

    def private listenersUserLogoutFile(Application it) '''
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

        /**
         * Event handler «IF isBase»base«ELSE»implementation«ENDIF» class for user logout events.
         */
        «IF isBase»abstract «ENDIF»class «IF isBase»Abstract«ENDIF»UserLogoutListener«IF !isBase» extends AbstractUserLogoutListener«ELSE» implements EventSubscriberInterface«ENDIF»
        {
            «new UserLogout().generate(it, isBase)»
        }
    '''

    def private listenersUserFile(Application it) '''
        namespace «appNamespace»\Listener«IF isBase»\Base«ENDIF»;

        «IF !isBase»
            use «appNamespace»\Listener\Base\AbstractUserListener;
        «ELSE»
            «IF hasStandardFieldEntities || hasUserFields»
                use Psr\Log\LoggerInterface;
            «ENDIF»
            use Symfony\Component\EventDispatcher\EventSubscriberInterface;
            «IF hasStandardFieldEntities || hasUserFields»
                use Zikula\Common\Translator\TranslatorInterface;
            «ENDIF»
        «ENDIF»
        use Zikula\Core\Event\GenericEvent;
        «IF isBase»
            «IF hasStandardFieldEntities || hasUserFields»
                use Zikula\UsersModule\Api\«IF targets('1.5')»ApiInterface\CurrentUserApiInterface«ELSE»CurrentUserApi«ENDIF»;
                «IF targets('1.5')»
                    use Zikula\UsersModule\Constant as UsersConstant;
                «ENDIF»
            «ENDIF»
            use Zikula\UsersModule\UserEvents;
            «IF hasStandardFieldEntities || hasUserFields»
                use «appNamespace»\Entity\Factory\EntityFactory;
            «ENDIF»
        «ENDIF»

        /**
         * Event handler «IF isBase»base«ELSE»implementation«ENDIF» class for user-related events.
         */
        «IF isBase»abstract «ENDIF»class «IF isBase»Abstract«ENDIF»UserListener«IF !isBase» extends AbstractUserListener«ELSE» implements EventSubscriberInterface«ENDIF»
        {
            «new User().generate(it, isBase)»
        }
    '''

    def private listenersUserRegistrationFile(Application it) '''
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

        /**
         * Event handler «IF isBase»base«ELSE»implementation«ENDIF» class for user registration events.
         */
        «IF isBase»abstract «ENDIF»class «IF isBase»Abstract«ENDIF»UserRegistrationListener«IF !isBase» extends AbstractUserRegistrationListener«ELSE» implements EventSubscriberInterface«ENDIF»
        {
            «new UserRegistration().generate(it, isBase)»
        }
    '''

    def private listenersUsersFile(Application it) '''
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

        /**
         * Event handler «IF isBase»base«ELSE»implementation«ENDIF» class for events of the Users module.
         */
        «IF isBase»abstract «ENDIF»class «IF isBase»Abstract«ENDIF»UsersListener«IF !isBase» extends AbstractUsersListener«ELSE» implements EventSubscriberInterface«ENDIF»
        {
            «new Users().generate(it, isBase)»
        }
    '''

    def private listenersGroupFile(Application it) '''
        namespace «appNamespace»\Listener«IF isBase»\Base«ENDIF»;

        «IF !isBase»
            use «appNamespace»\Listener\Base\AbstractGroupListener;
        «ELSE»
            use Symfony\Component\EventDispatcher\EventSubscriberInterface;
        «ENDIF»
        use Zikula\Core\Event\GenericEvent;
        «IF isBase»
            use Zikula\GroupsModule\GroupEvents;
        «ENDIF»

        /**
         * Event handler implementation class for group-related events.
         */
        «IF isBase»abstract «ENDIF»class «IF isBase»Abstract«ENDIF»GroupListener«IF !isBase» extends AbstractGroupListener«ELSE» implements EventSubscriberInterface«ENDIF»
        {
            «new Group().generate(it, isBase)»
        }
    '''

    def private listenersThirdPartyFile(Application it) '''
        namespace «appNamespace»\Listener«IF isBase»\Base«ENDIF»;

        «IF !isBase»
            use «appNamespace»\Listener\Base\AbstractThirdPartyListener;
        «ELSE»
            use Symfony\Component\EventDispatcher\EventSubscriberInterface;
            use Symfony\Component\HttpKernel\HttpKernelInterface;
            «IF needsApproval && generatePendingContentSupport»
                use Zikula\Collection\Container;
                use «appNamespace»\Helper\WorkflowHelper;
            «ENDIF»
        «ENDIF»
        use Zikula\Core\Event\GenericEvent;
        «IF isBase»
            «IF needsApproval && generatePendingContentSupport»
                use Zikula\Provider\AggregateItem;
            «ENDIF»
        «ENDIF»

        /**
         * Event handler implementation class for special purposes and 3rd party api support.
         */
        «IF isBase»abstract «ENDIF»class «IF isBase»Abstract«ENDIF»ThirdPartyListener«IF !isBase» extends AbstractThirdPartyListener«ELSE» implements EventSubscriberInterface«ENDIF»
        {
            «new ThirdParty().generate(it, isBase)»
        }
    '''

    def private listenersIpTraceFile(Application it) '''
        namespace «appNamespace»\Listener«IF isBase»\Base«ENDIF»;

        «IF !isBase»
            use «appNamespace»\Listener\Base\AbstractIpTraceListener;
        «ELSE»
            use Gedmo\IpTraceable\IpTraceableListener;
            use Symfony\Component\EventDispatcher\EventSubscriberInterface;
            use Symfony\Component\HttpFoundation\Request;
            use Symfony\Component\HttpFoundation\RequestStack;
            use Symfony\Component\HttpKernel\Event\GetResponseEvent;
            use Symfony\Component\HttpKernel\KernelEvents;
        «ENDIF»
        use Zikula\Core\Event\GenericEvent;

        /**
         * Event handler implementation class for ip traceable support.
         */
        «IF isBase»abstract «ENDIF»class «IF isBase»Abstract«ENDIF»IpTraceListener«IF !isBase» extends AbstractIpTraceListener«ELSE» implements EventSubscriberInterface«ENDIF»
        {
            «new IpTrace().generate(it, isBase)»
        }
    '''

    def private listenersWorkflowEventsFile(Application it) '''
        namespace «appNamespace»\Listener«IF isBase»\Base«ENDIF»;

        «IF !isBase»
            use «appNamespace»\Listener\Base\AbstractWorkflowEventsListener;
            use Symfony\Component\Workflow\Event\Event;
            use Symfony\Component\Workflow\Event\GuardEvent;
        «ELSE»
            use Symfony\Component\EventDispatcher\EventSubscriberInterface;
            use Symfony\Component\Workflow\Event\Event;
            use Symfony\Component\Workflow\Event\GuardEvent;
            use Zikula\Core\Doctrine\EntityAccess;
            use Zikula\PermissionsModule\Api\ApiInterface\PermissionApiInterface;
            «IF needsApproval»
                use «appNamespace»\Helper\NotificationHelper;
            «ENDIF»
        «ENDIF»

        /**
         * Event handler implementation class for workflow events.
         *
         * @see /src/docs/Core-2.0/Workflows/WorkflowEvents.md
         */
        «IF isBase»abstract «ENDIF»class «IF isBase»Abstract«ENDIF»WorkflowEventsListener«IF !isBase» extends AbstractWorkflowEventsListener«ELSE» implements EventSubscriberInterface«ENDIF»
        {
            «new WorkflowEvents().generate(it, isBase)»
        }
    '''
}
