package org.zikula.modulestudio.generator.cartridges.zclassic.controller

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener.GroupListener
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener.IpTraceListener
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener.KernelListener
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener.LoggableListener
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener.MailerListener
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener.ModuleDispatchListener
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener.ModuleInstallerListener
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener.ThemeListener
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener.ThirdPartyListener
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener.UserListener
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener.UserLoginListener
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener.UserLogoutListener
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener.UserRegistrationListener
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener.UsersListener
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener.WorkflowEventsListener
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.Utils
import org.zikula.modulestudio.generator.extensions.WorkflowExtensions

class Listeners {

    extension ControllerExtensions = new ControllerExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelExtensions = new ModelExtensions
    extension Utils = new Utils
    extension WorkflowExtensions = new WorkflowExtensions

    IMostFileSystemAccess fsa
    Boolean isBase
    Boolean needsThirdPartyListener

    String listenerPath
    String listenerSuffix

    /**
     * Entry point for event subscribers.
     */
    def generate(Application it, IMostFileSystemAccess fsa) {
        this.fsa = fsa
        listenerSuffix = 'Listener.php'

        val needsDetailContentType = generateDetailContentType && hasDisplayActions
        needsThirdPartyListener = ((needsApproval && generatePendingContentSupport) || ((generateListContentType || needsDetailContentType) && !targets('2.0')) || generateScribitePlugins)

        'Generating event listener base classes'.printIfNotTesting(fsa)
        listenerPath = 'Listener/Base/'
        isBase = true
        generateListenerClasses

        if (generateOnlyBaseClasses) {
            return
        }

        'Generating event listener implementation classes'.printIfNotTesting(fsa)
        listenerPath = 'Listener/'
        isBase = false
        generateListenerClasses
    }

    def private generateListenerClasses(Application it) {
        listenerFile('Installer', listenersInstallerFile)
        listenerFile('Kernel', listenersKernelFile)
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
        if (hasLoggable) {
            listenerFile('Loggable', listenersLoggableFile)
        }
        listenerFile('WorkflowEvents', listenersWorkflowEventsFile)
    }

    def private listenerFile(String name, CharSequence content) {
        var filePath = listenerPath + (if (isBase) 'Abstract' else '') + name + listenerSuffix
        fsa.generateFile(filePath, content)
    }

    def private listenersInstallerFile(Application it) '''
        namespace «appNamespace»\Listener«IF isBase»\Base«ENDIF»;

        «IF !isBase»
            use «appNamespace»\Listener\Base\AbstractInstallerListener;
        «ELSE»
            use Symfony\Component\EventDispatcher\EventSubscriberInterface;
            use Zikula\Core\CoreEvents;
            use Zikula\Core\Event\ModuleStateEvent;
            «IF hasUiHooksProviders»
                use «appNamespace»\Entity\Factory\EntityFactory;
            «ENDIF»
            «IF amountOfExampleRows > 0»
                use «appNamespace»\Helper\ExampleDataHelper;
            «ENDIF»
        «ENDIF»

        /**
         * Event handler «IF isBase»base«ELSE»implementation«ENDIF» class for module installer events.
         */
        «IF isBase»abstract «ENDIF»class «IF isBase»Abstract«ENDIF»InstallerListener«IF !isBase» extends AbstractInstallerListener«ELSE» implements EventSubscriberInterface«ENDIF»
        {
            «IF isBase»
                «new ModuleInstallerListener().generate(it)»
            «ELSE»
                // feel free to enhance the parent methods
            «ENDIF»
        }
    '''

    def private listenersKernelFile(Application it) '''
        namespace «appNamespace»\Listener«IF isBase»\Base«ENDIF»;

        «IF !isBase»
            use «appNamespace»\Listener\Base\AbstractKernelListener;
        «ELSE»
            use Symfony\Component\EventDispatcher\EventSubscriberInterface;
            use Symfony\Component\HttpKernel\Event\FilterControllerEvent;
            use Symfony\Component\HttpKernel\Event\FilterResponseEvent;
            use Symfony\Component\HttpKernel\Event\FinishRequestEvent;
            use Symfony\Component\HttpKernel\Event\GetResponseEvent;
            use Symfony\Component\HttpKernel\Event\GetResponseForControllerResultEvent;
            use Symfony\Component\HttpKernel\Event\GetResponseForExceptionEvent;
            use Symfony\Component\HttpKernel\Event\PostResponseEvent;
            use Symfony\Component\HttpKernel\KernelEvents;
        «ENDIF»

        /**
         * Event handler «IF isBase»base«ELSE»implementation«ENDIF» class for Symfony kernel events.
         */
        «IF isBase»abstract «ENDIF»class «IF isBase»Abstract«ENDIF»KernelListener«IF !isBase» extends AbstractKernelListener«ELSE» implements EventSubscriberInterface«ENDIF»
        {
            «IF isBase»
                «new KernelListener().generate(it)»
            «ELSE»
                // feel free to enhance the parent methods
            «ENDIF»
        }
    '''

    def private listenersModuleDispatchFile(Application it) '''
        namespace «appNamespace»\Listener«IF isBase»\Base«ENDIF»;

        «IF !isBase»
            use «appNamespace»\Listener\Base\AbstractModuleDispatchListener;
        «ELSE»
            use Symfony\Component\EventDispatcher\EventSubscriberInterface;
            use Zikula\Core\Event\GenericEvent;
        «ENDIF»

        /**
         * Event handler «IF isBase»base«ELSE»implementation«ENDIF» class for dispatching modules.
         */
        «IF isBase»abstract «ENDIF»class «IF isBase»Abstract«ENDIF»ModuleDispatchListener«IF !isBase» extends AbstractModuleDispatchListener«ELSE» implements EventSubscriberInterface«ENDIF»
        {
            «IF isBase»
                «new ModuleDispatchListener().generate(it)»
            «ELSE»
                // feel free to enhance the parent methods
            «ENDIF»
        }
    '''

    def private listenersMailerFile(Application it) '''
        namespace «appNamespace»\Listener«IF isBase»\Base«ENDIF»;

        «IF !isBase»
            use «appNamespace»\Listener\Base\AbstractMailerListener;
        «ELSE»
            use Symfony\Component\EventDispatcher\EventSubscriberInterface;
            use Zikula\Core\Event\GenericEvent;
            use Zikula\MailerModule\MailerEvents;
        «ENDIF»

        /**
         * Event handler «IF isBase»base«ELSE»implementation«ENDIF» class for mailing events.
         */
        «IF isBase»abstract «ENDIF»class «IF isBase»Abstract«ENDIF»MailerListener«IF !isBase» extends AbstractMailerListener«ELSE» implements EventSubscriberInterface«ENDIF»
        {
            «IF isBase»
                «new MailerListener().generate(it)»
            «ELSE»
                // feel free to enhance the parent methods
            «ENDIF»
        }
    '''

    def private listenersThemeFile(Application it) '''
        namespace «appNamespace»\Listener«IF isBase»\Base«ENDIF»;

        «IF !isBase»
            use «appNamespace»\Listener\Base\AbstractThemeListener;
        «ELSE»
            use Symfony\Component\EventDispatcher\EventSubscriberInterface;
            use Zikula\ThemeModule\Bridge\Event\TwigPostRenderEvent;
            use Zikula\ThemeModule\Bridge\Event\TwigPreRenderEvent;
            use Zikula\ThemeModule\ThemeEvents;
        «ENDIF»

        /**
         * Event handler «IF isBase»base«ELSE»implementation«ENDIF» class for theme-related events.
         */
        «IF isBase»abstract «ENDIF»class «IF isBase»Abstract«ENDIF»ThemeListener«IF !isBase» extends AbstractThemeListener«ELSE» implements EventSubscriberInterface«ENDIF»
        {
            «IF isBase»
                «new ThemeListener().generate(it)»
            «ELSE»
                // feel free to enhance the parent methods
            «ENDIF»
        }
    '''

    def private listenersUserLoginFile(Application it) '''
        namespace «appNamespace»\Listener«IF isBase»\Base«ENDIF»;

        «IF !isBase»
            use «appNamespace»\Listener\Base\AbstractUserLoginListener;
        «ELSE»
            use Symfony\Component\EventDispatcher\EventSubscriberInterface;
            use Zikula\Core\Event\GenericEvent;
            use Zikula\UsersModule\AccessEvents;
        «ENDIF»

        /**
         * Event handler «IF isBase»base«ELSE»implementation«ENDIF» class for user login events.
         */
        «IF isBase»abstract «ENDIF»class «IF isBase»Abstract«ENDIF»UserLoginListener«IF !isBase» extends AbstractUserLoginListener«ELSE» implements EventSubscriberInterface«ENDIF»
        {
            «IF isBase»
                «new UserLoginListener().generate(it)»
            «ELSE»
                // feel free to enhance the parent methods
            «ENDIF»
        }
    '''

    def private listenersUserLogoutFile(Application it) '''
        namespace «appNamespace»\Listener«IF isBase»\Base«ENDIF»;

        «IF !isBase»
            use «appNamespace»\Listener\Base\AbstractUserLogoutListener;
        «ELSE»
            use Symfony\Component\EventDispatcher\EventSubscriberInterface;
            use Zikula\Core\Event\GenericEvent;
            use Zikula\UsersModule\AccessEvents;
        «ENDIF»

        /**
         * Event handler «IF isBase»base«ELSE»implementation«ENDIF» class for user logout events.
         */
        «IF isBase»abstract «ENDIF»class «IF isBase»Abstract«ENDIF»UserLogoutListener«IF !isBase» extends AbstractUserLogoutListener«ELSE» implements EventSubscriberInterface«ENDIF»
        {
            «IF isBase»
                «new UserLogoutListener().generate(it)»
            «ELSE»
                // feel free to enhance the parent methods
            «ENDIF»
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
            use Zikula\Core\Event\GenericEvent;
            «IF hasUserVariables»
                use Zikula\ExtensionsModule\Api\ApiInterface\VariableApiInterface;
            «ENDIF»
            «IF hasStandardFieldEntities || hasUserFields»
                use Zikula\UsersModule\Api\ApiInterface\CurrentUserApiInterface;
            «ENDIF»
            «IF hasStandardFieldEntities || hasUserFields || hasUserVariables»
                use Zikula\UsersModule\Constant as UsersConstant;
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
            «IF isBase»
                «new UserListener().generate(it)»
            «ELSE»
                // feel free to enhance the parent methods
            «ENDIF»
        }
    '''

    def private listenersUserRegistrationFile(Application it) '''
        namespace «appNamespace»\Listener«IF isBase»\Base«ENDIF»;

        «IF !isBase»
            use «appNamespace»\Listener\Base\AbstractUserRegistrationListener;
        «ELSE»
            use Symfony\Component\EventDispatcher\EventSubscriberInterface;
            use Zikula\Core\Event\GenericEvent;
            use Zikula\UsersModule\RegistrationEvents;
        «ENDIF»

        /**
         * Event handler «IF isBase»base«ELSE»implementation«ENDIF» class for user registration events.
         */
        «IF isBase»abstract «ENDIF»class «IF isBase»Abstract«ENDIF»UserRegistrationListener«IF !isBase» extends AbstractUserRegistrationListener«ELSE» implements EventSubscriberInterface«ENDIF»
        {
            «IF isBase»
                «new UserRegistrationListener().generate(it)»
            «ELSE»
                // feel free to enhance the parent methods
            «ENDIF»
        }
    '''

    def private listenersUsersFile(Application it) '''
        namespace «appNamespace»\Listener«IF isBase»\Base«ENDIF»;

        «IF !isBase»
            use «appNamespace»\Listener\Base\AbstractUsersListener;
        «ELSE»
            use Symfony\Component\EventDispatcher\EventSubscriberInterface;
            use Zikula\Core\Event\GenericEvent;
            use Zikula\UsersModule\UserEvents;
        «ENDIF»

        /**
         * Event handler «IF isBase»base«ELSE»implementation«ENDIF» class for events of the Users module.
         */
        «IF isBase»abstract «ENDIF»class «IF isBase»Abstract«ENDIF»UsersListener«IF !isBase» extends AbstractUsersListener«ELSE» implements EventSubscriberInterface«ENDIF»
        {
            «IF isBase»
                «new UsersListener().generate(it)»
            «ELSE»
                // feel free to enhance the parent methods
            «ENDIF»
        }
    '''

    def private listenersGroupFile(Application it) '''
        namespace «appNamespace»\Listener«IF isBase»\Base«ENDIF»;

        «IF !isBase»
            use «appNamespace»\Listener\Base\AbstractGroupListener;
        «ELSE»
            use Symfony\Component\EventDispatcher\EventSubscriberInterface;
            use Zikula\Core\Event\GenericEvent;
            use Zikula\GroupsModule\GroupEvents;
        «ENDIF»

        /**
         * Event handler implementation class for group-related events.
         */
        «IF isBase»abstract «ENDIF»class «IF isBase»Abstract«ENDIF»GroupListener«IF !isBase» extends AbstractGroupListener«ELSE» implements EventSubscriberInterface«ENDIF»
        {
            «IF isBase»
                «new GroupListener().generate(it)»
            «ELSE»
                // feel free to enhance the parent methods
            «ENDIF»
        }
    '''

    def private listenersThirdPartyFile(Application it) '''
        namespace «appNamespace»\Listener«IF isBase»\Base«ENDIF»;

        «IF !isBase»
            use «appNamespace»\Listener\Base\AbstractThirdPartyListener;
        «ELSE»
            use Symfony\Component\EventDispatcher\EventSubscriberInterface;
            «IF generateScribitePlugins»
                use Symfony\Component\Filesystem\Filesystem;
                use Symfony\Component\Finder\Finder;
                use Symfony\Component\HttpFoundation\RequestStack;
            «ENDIF»
            use Symfony\Component\HttpKernel\HttpKernelInterface;
            «IF needsApproval && generatePendingContentSupport»
                use Zikula\Common\Collection\Collectible\PendingContentCollectible;
                use Zikula\Common\Collection\Container;
            «ENDIF»
            use Zikula\Core\Event\GenericEvent;
            «IF needsApproval && generatePendingContentSupport»
                use «appNamespace»\Helper\WorkflowHelper;
            «ENDIF»
            «IF generateScribitePlugins»
                use Zikula\ScribiteModule\Event\EditorHelperEvent;
            «ENDIF»
        «ENDIF»

        /**
         * Event handler implementation class for special purposes and 3rd party api support.
         */
        «IF isBase»abstract «ENDIF»class «IF isBase»Abstract«ENDIF»ThirdPartyListener«IF !isBase» extends AbstractThirdPartyListener«ELSE» implements EventSubscriberInterface«ENDIF»
        {
            «IF isBase»
                «new ThirdPartyListener().generate(it)»
            «ELSE»
                // feel free to enhance the parent methods
            «ENDIF»
        }
    '''

    def private listenersIpTraceFile(Application it) '''
        namespace «appNamespace»\Listener«IF isBase»\Base«ENDIF»;

        «IF !isBase»
            use «appNamespace»\Listener\Base\AbstractIpTraceListener;
        «ELSE»
            use Gedmo\IpTraceable\IpTraceableListener;
            use Symfony\Component\EventDispatcher\EventSubscriberInterface;
            use Symfony\Component\HttpFoundation\RequestStack;
            use Symfony\Component\HttpKernel\Event\GetResponseEvent;
            use Symfony\Component\HttpKernel\KernelEvents;
            use Zikula\Core\Event\GenericEvent;
        «ENDIF»

        /**
         * Event handler implementation class for ip traceable support.
         *
         * Can be removed after https://github.com/stof/StofDoctrineExtensionsBundle/pull/233 has been merged.
         */
        «IF isBase»abstract «ENDIF»class «IF isBase»Abstract«ENDIF»IpTraceListener«IF !isBase» extends AbstractIpTraceListener«ELSE» implements EventSubscriberInterface«ENDIF»
        {
            «IF isBase»
                «new IpTraceListener().generate(it)»
            «ELSE»
                // feel free to enhance the parent methods
            «ENDIF»
        }
    '''

    def private listenersLoggableFile(Application it) '''
        namespace «appNamespace»\Listener«IF isBase»\Base«ENDIF»;

        «IF !isBase»
            use «appNamespace»\Listener\Base\AbstractLoggableListener;
        «ELSE»
            use Gedmo\Loggable\LoggableListener as BaseListener;
            use «appNamespace»\Helper\EntityDisplayHelper;
            use «appNamespace»\Helper\LoggableHelper;
        «ENDIF»

        /**
         * Event handler implementation class for injecting log entry additions.
         */
        «IF isBase»abstract «ENDIF»class «IF isBase»Abstract«ENDIF»LoggableListener«IF !isBase» extends AbstractLoggableListener«ELSE» extends BaseListener«ENDIF»
        {
            «IF isBase»
                «new LoggableListener().generate(it)»
            «ELSE»
                // feel free to enhance the parent methods
            «ENDIF»
        }
    '''

    def private listenersWorkflowEventsFile(Application it) '''
        namespace «appNamespace»\Listener«IF isBase»\Base«ENDIF»;

        «IF !isBase»
            use «appNamespace»\Listener\Base\AbstractWorkflowEventsListener;
        «ELSE»
            use Symfony\Component\EventDispatcher\EventSubscriberInterface;
            use Symfony\Component\Workflow\Event\Event;
            use Symfony\Component\Workflow\Event\GuardEvent;
            use Zikula\Core\Doctrine\EntityAccess;
            use «appNamespace»\Entity\Factory\EntityFactory;
            use «appNamespace»\Helper\PermissionHelper;
            «IF needsApproval»
                use «appNamespace»\Helper\NotificationHelper;
            «ENDIF»
        «ENDIF»

        /**
         * Event handler implementation class for workflow events.
         *
         * @see /src/docs/Workflows/WorkflowEvents.md
         */
        «IF isBase»abstract «ENDIF»class «IF isBase»Abstract«ENDIF»WorkflowEventsListener«IF !isBase» extends AbstractWorkflowEventsListener«ELSE» implements EventSubscriberInterface«ENDIF»
        {
            «IF isBase»
                «new WorkflowEventsListener().generate(it)»
            «ELSE»
                // feel free to enhance the parent methods
            «ENDIF»
        }
    '''
}
