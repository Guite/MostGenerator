package org.zikula.modulestudio.generator.cartridges.zclassic.controller

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener.ConnectionsMenuListener
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener.FormTypeChoicesListener
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener.GroupListener
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener.IpTraceListener
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener.KernelListener
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener.LoggableListener
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener.MailerListener
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener.ModuleInstallerListener
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener.ThemeListener
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener.ThirdPartyListener
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener.UserListener
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener.UserLoginListener
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener.UserLogoutListener
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener.UserRegistrationListener
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener.WorkflowEventsListener
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions
import org.zikula.modulestudio.generator.extensions.Utils
import org.zikula.modulestudio.generator.extensions.WorkflowExtensions

class Listeners {

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

        needsThirdPartyListener = (needsApproval && generatePendingContentSupport) || generateScribitePlugins

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
        listenerFile('FormTypeChoices', formTypeChoicesFile)
        listenerFile('Installer', listenersInstallerFile)
        listenerFile('Kernel', listenersKernelFile)
        listenerFile('ConnectionsMenu', listenersConnectionsMenuFile)
        listenerFile('Mailer', listenersMailerFile)
        listenerFile('Theme', listenersThemeFile)
        listenerFile('UserLogin', listenersUserLoginFile)
        listenerFile('UserLogout', listenersUserLogoutFile)
        listenerFile('User', listenersUserFile)
        listenerFile('UserRegistration', listenersUserRegistrationFile)
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

    // 3.0 only
    def private formTypeChoicesFile(Application it) '''
        namespace «appNamespace»\Listener«IF isBase»\Base«ENDIF»;

        «IF !isBase»
            use «appNamespace»\Listener\Base\AbstractFormTypeChoicesListener;
        «ELSE»
            use Symfony\Component\EventDispatcher\EventSubscriberInterface;
            use Zikula\Bundle\FormExtensionBundle\Event\FormTypeChoiceEvent;
        «ENDIF»

        /**
         * Event handler «IF isBase»base«ELSE»implementation«ENDIF» class for injecting custom dynamic form types.
         */
        «IF isBase»abstract «ENDIF»class «IF isBase»Abstract«ENDIF»FormTypeChoicesListener«IF !isBase» extends AbstractFormTypeChoicesListener«ELSE» implements EventSubscriberInterface«ENDIF»
        {
            «IF isBase»
                «new FormTypeChoicesListener().generate(it)»
            «ELSE»
                // feel free to enhance the parent methods
            «ENDIF»
        }
    '''

    def private listenersInstallerFile(Application it) '''
        namespace «appNamespace»\Listener«IF isBase»\Base«ENDIF»;

        «IF !isBase»
            use «appNamespace»\Listener\Base\AbstractInstallerListener;
        «ELSE»
            use Symfony\Component\EventDispatcher\EventSubscriberInterface;
            use Zikula\ExtensionsModule\Event\ExtensionPostCacheRebuildEvent;
            use Zikula\ExtensionsModule\Event\ExtensionPostDisabledEvent;
            use Zikula\ExtensionsModule\Event\ExtensionPostEnabledEvent;
            use Zikula\ExtensionsModule\Event\ExtensionPostInstallEvent;
            use Zikula\ExtensionsModule\Event\ExtensionPostRemoveEvent;
            use Zikula\ExtensionsModule\Event\ExtensionPostUpgradeEvent;
            «IF hasUiHooksProviders»
                use «appNamespace»\Entity\Factory\EntityFactory;
                use «appNamespace»\Entity\HookAssignmentEntity;
            «ENDIF»
            «IF amountOfExampleRows > 0»
                use «appNamespace»\Helper\ExampleDataHelper;
            «ENDIF»
        «ENDIF»

        /**
         * Event handler «IF isBase»base«ELSE»implementation«ENDIF» class for extension installer events.
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
            use Symfony\Component\HttpKernel\Event\ControllerEvent;
            use Symfony\Component\HttpKernel\Event\ExceptionEvent;
            use Symfony\Component\HttpKernel\Event\FinishRequestEvent;
            use Symfony\Component\HttpKernel\Event\RequestEvent;
            use Symfony\Component\HttpKernel\Event\ResponseEvent;
            use Symfony\Component\HttpKernel\Event\TerminateEvent;
            use Symfony\Component\HttpKernel\Event\ViewEvent;
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

    def private listenersConnectionsMenuFile(Application it) '''
        namespace «appNamespace»\Listener«IF isBase»\Base«ENDIF»;

        «IF !isBase»
            use «appNamespace»\Listener\Base\AbstractConnectionsMenuListener;
        «ELSE»
            use Symfony\Component\EventDispatcher\EventSubscriberInterface;
            use Symfony\Contracts\Translation\TranslatorInterface;
            use Zikula\ExtensionsModule\Event\ConnectionsMenuEvent;
            use Zikula\PermissionsModule\Api\ApiInterface\PermissionApiInterface;
        «ENDIF»

        /**
         * Event handler «IF isBase»base«ELSE»implementation«ENDIF» class for adding connections to extension menus.
         */
        «IF isBase»abstract «ENDIF»class «IF isBase»Abstract«ENDIF»ConnectionsMenuListener«IF !isBase» extends AbstractConnectionsMenuListener«ELSE» implements EventSubscriberInterface«ENDIF»
        {
            «IF isBase»
                «new ConnectionsMenuListener().generate(it)»
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
            use Symfony\Component\Mailer\Event\MessageEvent;
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
            use Symfony\Component\HttpKernel\Event\ResponseEvent;
            use Symfony\Component\HttpKernel\KernelEvents;
            use Zikula\ThemeModule\Bridge\Event\TwigPostRenderEvent;
            use Zikula\ThemeModule\Bridge\Event\TwigPreRenderEvent;
            use Zikula\ThemeModule\Engine\AssetFilter;
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
            use Zikula\UsersModule\Event\UserPostLoginFailureEvent;
            use Zikula\UsersModule\Event\UserPostLoginSuccessEvent;
            use Zikula\UsersModule\Event\UserPreLoginSuccessEvent;
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
            use Zikula\UsersModule\Event\UserPostLogoutSuccessEvent;
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
            «IF hasUserVariables»
                use Zikula\ExtensionsModule\Api\ApiInterface\VariableApiInterface;
            «ENDIF»
            «IF hasStandardFieldEntities || hasUserFields»
                use Zikula\UsersModule\Api\ApiInterface\CurrentUserApiInterface;
            «ENDIF»
            «IF hasStandardFieldEntities || hasUserFields || hasUserVariables»
                use Zikula\UsersModule\Constant as UsersConstant;
            «ENDIF»
            use Zikula\UsersModule\Event\ActiveUserPostCreatedEvent;
            use Zikula\UsersModule\Event\ActiveUserPostDeletedEvent;
            use Zikula\UsersModule\Event\ActiveUserPostUpdatedEvent;
            «IF hasStandardFieldEntities || hasUserFields»
                use «appNamespace»\Entity\Factory\EntityFactory;
            «ENDIF»
            «IF hasLoggable»
                use «appNamespace»\Helper\LoggableHelper;
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
            use Zikula\UsersModule\Event\ActiveUserPreCreatedEvent;
            use Zikula\UsersModule\Event\RegistrationPostApprovedEvent;
            use Zikula\UsersModule\Event\RegistrationPostCreatedEvent;
            use Zikula\UsersModule\Event\RegistrationPostDeletedEvent;
            use Zikula\UsersModule\Event\RegistrationPostSuccessEvent;
            use Zikula\UsersModule\Event\RegistrationPostUpdatedEvent;
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

    def private listenersGroupFile(Application it) '''
        namespace «appNamespace»\Listener«IF isBase»\Base«ENDIF»;

        «IF !isBase»
            use «appNamespace»\Listener\Base\AbstractGroupListener;
        «ELSE»
            use Symfony\Component\EventDispatcher\EventSubscriberInterface;
            use Zikula\GroupsModule\Event\GroupApplicationPostCreatedEvent;
            use Zikula\GroupsModule\Event\GroupApplicationPostProcessedEvent;
            use Zikula\GroupsModule\Event\GroupPostCreatedEvent;
            use Zikula\GroupsModule\Event\GroupPostDeletedEvent;
            use Zikula\GroupsModule\Event\GroupPostUpdatedEvent;
            use Zikula\GroupsModule\Event\GroupPostUserAddedEvent;
            use Zikula\GroupsModule\Event\GroupPostUserRemovedEvent;
            use Zikula\GroupsModule\Event\GroupPreDeletedEvent;
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
                use Zikula\BlocksModule\Collectible\PendingContentCollectible;
                use Zikula\BlocksModule\Event\PendingContentEvent;
                use Zikula\Bundle\CoreBundle\Collection\Container;
            «ENDIF»
            «IF generateScribitePlugins»
                use Zikula\Bundle\CoreBundle\HttpKernel\ZikulaHttpKernelInterface;
            «ENDIF»
            «IF needsApproval && generatePendingContentSupport»
                use «appNamespace»\Helper\WorkflowHelper;
            «ENDIF»
            «IF generateScribitePlugins»
                use Zikula\ScribiteModule\Event\EditorHelperEvent;
                use Zikula\ScribiteModule\Event\LoadExternalPluginsEvent;
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
            use Symfony\Component\HttpKernel\Event\RequestEvent;
            use Symfony\Component\HttpKernel\KernelEvents;
            use Zikula\Bundle\CoreBundle\Event\GenericEvent;
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
            use Zikula\Bundle\CoreBundle\Doctrine\EntityAccess;
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
            «IF !getJoinRelations.empty && !getAllEntities.filter[!getOutgoingJoinRelationsWithoutDeleteCascade.empty].empty»
                use Symfony\Component\Workflow\TransitionBlocker;
            «ENDIF»
            use Symfony\Contracts\Translation\TranslatorInterface;
            use Zikula\Bundle\CoreBundle\Doctrine\EntityAccess;
            use Zikula\Bundle\CoreBundle\Translation\TranslatorTrait;
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
