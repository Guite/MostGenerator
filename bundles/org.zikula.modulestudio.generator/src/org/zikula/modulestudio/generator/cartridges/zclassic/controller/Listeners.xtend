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
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions
import org.zikula.modulestudio.generator.extensions.Utils
import org.zikula.modulestudio.generator.extensions.WorkflowExtensions

class Listeners {

    extension ControllerExtensions = new ControllerExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelExtensions = new ModelExtensions
    extension ModelJoinExtensions = new ModelJoinExtensions
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
        if (!targets('3.0')) {
            listenerFile('Users', listenersUsersFile)
        }
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
            «IF targets('3.0')»
                use Zikula\ExtensionsModule\Event\ExtensionPostCacheRebuildEvent;
                use Zikula\ExtensionsModule\Event\ExtensionPostDisabledEvent;
                use Zikula\ExtensionsModule\Event\ExtensionPostEnabledEvent;
                use Zikula\ExtensionsModule\Event\ExtensionPostInstallEvent;
                use Zikula\ExtensionsModule\Event\ExtensionPostRemoveEvent;
                use Zikula\ExtensionsModule\Event\ExtensionPostUpgradeEvent;
            «ELSE»
                use Zikula\Core\CoreEvents;
                use Zikula\Core\Event\ModuleStateEvent;
            «ENDIF»
            «IF hasUiHooksProviders»
                use «appNamespace»\Entity\Factory\EntityFactory;
            «ENDIF»
            «IF amountOfExampleRows > 0»
                use «appNamespace»\Helper\ExampleDataHelper;
            «ENDIF»
        «ENDIF»

        /**
         * Event handler «IF isBase»base«ELSE»implementation«ENDIF» class for «IF targets('3.0')»extension«ELSE»module«ENDIF» installer events.
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
            use Symfony\Component\HttpKernel\Event\«IF !targets('3.0')»Filter«ENDIF»ControllerEvent;
            «IF !targets('3.0')»
                use Symfony\Component\HttpKernel\Event\FilterResponseEvent;
            «ENDIF»
            «IF targets('3.0')»
                use Symfony\Component\HttpKernel\Event\ExceptionEvent;
            «ENDIF»
            use Symfony\Component\HttpKernel\Event\FinishRequestEvent;
            «IF !targets('3.0')»
                use Symfony\Component\HttpKernel\Event\GetResponseEvent;
                use Symfony\Component\HttpKernel\Event\GetResponseForControllerResultEvent;
                use Symfony\Component\HttpKernel\Event\GetResponseForExceptionEvent;
                use Symfony\Component\HttpKernel\Event\PostResponseEvent;
            «ENDIF»
            «IF targets('3.0')»
                use Symfony\Component\HttpKernel\Event\RequestEvent;
                use Symfony\Component\HttpKernel\Event\ResponseEvent;
                use Symfony\Component\HttpKernel\Event\TerminateEvent;
                use Symfony\Component\HttpKernel\Event\ViewEvent;
            «ENDIF»
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
            «IF targets('3.0')»
                use Zikula\Bundle\CoreBundle\Event\GenericEvent;
            «ELSE»
                use Zikula\Core\Event\GenericEvent;
            «ENDIF»
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
            «IF targets('3.0')»
                use Symfony\Component\Mailer\Event\MessageEvent;
            «ELSE»
                use Zikula\Core\Event\GenericEvent;
                use Zikula\MailerModule\MailerEvents;
            «ENDIF»
        «ENDIF»

        /**
         * Event handler «IF isBase»base«ELSE»implementation«ENDIF» class for mailing events.
         */
        «IF isBase»abstract «ENDIF»class «IF isBase»Abstract«ENDIF»MailerListener«IF !isBase» extends AbstractMailerListener«ELSE» implements EventSubscriberInterface«ENDIF»
        {
            «IF isBase»
                «IF targets('3.0')»
                    «new MailerListener().generate(it)»
                «ELSE»
                    «new MailerListener().generateLegacy(it)»
                «ENDIF»
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
            «IF !targets('3.0')»
                use Zikula\ThemeModule\ThemeEvents;
            «ENDIF»
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
            «IF targets('3.0')»
                use Zikula\UsersModule\Event\UserPostLoginFailureEvent;
                use Zikula\UsersModule\Event\UserPostLoginSuccessEvent;
                use Zikula\UsersModule\Event\UserPreLoginSuccessEvent;
            «ELSE»
                use Zikula\Core\Event\GenericEvent;
                use Zikula\UsersModule\AccessEvents;
            «ENDIF»
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
            «IF targets('3.0')»
                use Zikula\UsersModule\Event\UserPostLogoutSuccessEvent;
            «ELSE»
                use Zikula\Core\Event\GenericEvent;
                use Zikula\UsersModule\AccessEvents;
            «ENDIF»
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
                «IF targets('3.0')»
                    use Symfony\Contracts\Translation\TranslatorInterface;
                «ELSE»
                    use Zikula\Common\Translator\TranslatorInterface;
                «ENDIF»
            «ENDIF»
            «IF !targets('3.0')»
                use Zikula\Core\Event\GenericEvent;
            «ENDIF»
            «IF hasUserVariables»
                use Zikula\ExtensionsModule\Api\ApiInterface\VariableApiInterface;
            «ENDIF»
            «IF hasStandardFieldEntities || hasUserFields»
                use Zikula\UsersModule\Api\ApiInterface\CurrentUserApiInterface;
            «ENDIF»
            «IF hasStandardFieldEntities || hasUserFields || hasUserVariables»
                use Zikula\UsersModule\Constant as UsersConstant;
            «ENDIF»
            «IF targets('3.0')»
                use Zikula\UsersModule\Event\ActiveUserPostCreatedEvent;
                use Zikula\UsersModule\Event\ActiveUserPostDeletedEvent;
                use Zikula\UsersModule\Event\ActiveUserPostUpdatedEvent;
            «ELSE»
                use Zikula\UsersModule\UserEvents;
            «ENDIF»
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
            «IF targets('3.0')»
                use Zikula\UsersModule\Event\ActiveUserPreCreatedEvent;
                use Zikula\UsersModule\Event\RegistrationPostApprovedEvent;
                use Zikula\UsersModule\Event\RegistrationPostCreatedEvent;
                use Zikula\UsersModule\Event\RegistrationPostDeletedEvent;
                use Zikula\UsersModule\Event\RegistrationPostSuccessEvent;
                use Zikula\UsersModule\Event\RegistrationPostUpdatedEvent;
            «ELSE»
                use Zikula\Core\Event\GenericEvent;
                use Zikula\UsersModule\RegistrationEvents;
            «ENDIF»
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
            «IF targets('3.0')»
                use Zikula\Bundle\CoreBundle\Event\GenericEvent;
            «ELSE»
                use Zikula\Core\Event\GenericEvent;
            «ENDIF»
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
            «IF targets('3.0')»
                use Zikula\GroupsModule\Event\GroupApplicationPostCreatedEvent;
                use Zikula\GroupsModule\Event\GroupApplicationPostProcessedEvent;
                use Zikula\GroupsModule\Event\GroupPostCreatedEvent;
                use Zikula\GroupsModule\Event\GroupPostDeletedEvent;
                use Zikula\GroupsModule\Event\GroupPostUpdatedEvent;
                use Zikula\GroupsModule\Event\GroupPostUserAddedEvent;
                use Zikula\GroupsModule\Event\GroupPostUserRemovedEvent;
                use Zikula\GroupsModule\Event\GroupPreDeletedEvent;
            «ELSE»
                use Zikula\Core\Event\GenericEvent;
                use Zikula\GroupsModule\GroupEvents;
            «ENDIF»
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
                use Symfony\Component\HttpFoundation\RequestStack;
            «ENDIF»
            «IF needsApproval && generatePendingContentSupport»
                «IF targets('3.0')»
                    use Zikula\Bundle\CoreBundle\Collection\Collectible\PendingContentCollectible;
                    use Zikula\Bundle\CoreBundle\Collection\Container;
                «ELSE»
                    use Zikula\Common\Collection\Collectible\PendingContentCollectible;
                    use Zikula\Common\Collection\Container;
                «ENDIF»
            «ENDIF»
            «IF targets('3.0')»
                use Zikula\Bundle\CoreBundle\Event\GenericEvent;
            «ELSE»
                use Zikula\Core\Event\GenericEvent;
            «ENDIF»
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
            «IF targets('3.0')»
                use Zikula\Bundle\CoreBundle\Event\GenericEvent;
            «ELSE»
                use Zikula\Core\Event\GenericEvent;
            «ENDIF»
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
            use Gedmo\Loggable\Mapping\Event\LoggableAdapter;
            «IF targets('3.0')»
                use Zikula\Bundle\CoreBundle\Doctrine\EntityAccess;
            «ELSE»
                use Zikula\Core\Doctrine\EntityAccess;
            «ENDIF»
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
            «IF targets('3.0')»
                «IF !getJoinRelations.empty && !getAllEntities.filter[!getOutgoingJoinRelationsWithoutDeleteCascade.empty].empty»
                    use Symfony\Component\Workflow\TransitionBlocker;
                    use Symfony\Contracts\Translation\TranslatorInterface;
                «ENDIF»
                use Zikula\Bundle\CoreBundle\Doctrine\EntityAccess;
            «ELSE»
                use Zikula\Core\Doctrine\EntityAccess;
            «ENDIF»
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
