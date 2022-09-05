package org.zikula.modulestudio.generator.cartridges.zclassic.controller

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener.FormTypeChoicesListener
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener.GroupListener
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener.IpTraceListener
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener.KernelListener
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener.LoggableListener
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener.ThemeListener
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

    String listenerPath
    String listenerSuffix

    /**
     * Entry point for event subscribers.
     */
    def generate(Application it, IMostFileSystemAccess fsa) {
        this.fsa = fsa
        listenerSuffix = 'Listener.php'

        'Generating event listener base classes'.printIfNotTesting(fsa)
        listenerPath = 'EventListener/Base/'
        isBase = true
        generateListenerClasses

        if (generateOnlyBaseClasses) {
            return
        }

        'Generating event listener implementation classes'.printIfNotTesting(fsa)
        listenerPath = 'EventListener/'
        isBase = false
        generateListenerClasses
    }

    def private generateListenerClasses(Application it) {
        listenerFile('FormTypeChoices', formTypeChoicesFile)
        listenerFile('Kernel', listenersKernelFile)
        listenerFile('Theme', listenersThemeFile)
        listenerFile('UserLogin', listenersUserLoginFile)
        listenerFile('UserLogout', listenersUserLogoutFile)
        listenerFile('User', listenersUserFile)
        listenerFile('UserRegistration', listenersUserRegistrationFile)
        listenerFile('Group', listenersGroupFile)

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

    def private formTypeChoicesFile(Application it) '''
        namespace «appNamespace»\EventListener«IF isBase»\Base«ENDIF»;

        «IF !isBase»
            use «appNamespace»\EventListener\Base\AbstractFormTypeChoicesListener;
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

    def private listenersKernelFile(Application it) '''
        namespace «appNamespace»\EventListener«IF isBase»\Base«ENDIF»;

        «IF !isBase»
            use «appNamespace»\EventListener\Base\AbstractKernelListener;
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

    def private listenersThemeFile(Application it) '''
        namespace «appNamespace»\EventListener«IF isBase»\Base«ENDIF»;

        «IF !isBase»
            use «appNamespace»\EventListener\Base\AbstractThemeListener;
        «ELSE»
            use Symfony\Component\EventDispatcher\EventSubscriberInterface;
            use Symfony\Component\HttpKernel\Event\ResponseEvent;
            use Symfony\Component\HttpKernel\KernelEvents;
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
        namespace «appNamespace»\EventListener«IF isBase»\Base«ENDIF»;

        «IF !isBase»
            use «appNamespace»\EventListener\Base\AbstractUserLoginListener;
        «ELSE»
            use Symfony\Component\EventDispatcher\EventSubscriberInterface;
            use Zikula\UsersBundle\Event\UserPostLoginFailureEvent;
            use Zikula\UsersBundle\Event\UserPostLoginSuccessEvent;
            use Zikula\UsersBundle\Event\UserPreLoginSuccessEvent;
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
        namespace «appNamespace»\EventListener«IF isBase»\Base«ENDIF»;

        «IF !isBase»
            use «appNamespace»\EventListener\Base\AbstractUserLogoutListener;
        «ELSE»
            use Symfony\Component\EventDispatcher\EventSubscriberInterface;
            use Zikula\UsersBundle\Event\UserPostLogoutSuccessEvent;
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
        namespace «appNamespace»\EventListener«IF isBase»\Base«ENDIF»;

        «IF !isBase»
            use «appNamespace»\EventListener\Base\AbstractUserListener;
        «ELSE»
            «IF hasStandardFieldEntities || hasUserFields»
                use Psr\Log\LoggerInterface;
            «ENDIF»
            use Symfony\Component\EventDispatcher\EventSubscriberInterface;
            «IF hasStandardFieldEntities || hasUserFields»
                use Zikula\UsersBundle\Api\ApiInterface\CurrentUserApiInterface;
            «ENDIF»
            use Zikula\UsersBundle\Event\ActiveUserPostCreatedEvent;
            use Zikula\UsersBundle\Event\ActiveUserPostDeletedEvent;
            use Zikula\UsersBundle\Event\ActiveUserPostUpdatedEvent;
            «IF hasStandardFieldEntities || hasUserFields || hasUserVariables»
                use Zikula\UsersBundle\UsersConstant;
            «ENDIF»
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
        namespace «appNamespace»\EventListener«IF isBase»\Base«ENDIF»;

        «IF !isBase»
            use «appNamespace»\EventListener\Base\AbstractUserRegistrationListener;
        «ELSE»
            use Symfony\Component\EventDispatcher\EventSubscriberInterface;
            use Zikula\UsersBundle\Event\ActiveUserPreCreatedEvent;
            use Zikula\UsersBundle\Event\RegistrationPostApprovedEvent;
            use Zikula\UsersBundle\Event\RegistrationPostCreatedEvent;
            use Zikula\UsersBundle\Event\RegistrationPostDeletedEvent;
            use Zikula\UsersBundle\Event\RegistrationPostSuccessEvent;
            use Zikula\UsersBundle\Event\RegistrationPostUpdatedEvent;
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
        namespace «appNamespace»\EventListener«IF isBase»\Base«ENDIF»;

        «IF !isBase»
            use «appNamespace»\EventListener\Base\AbstractGroupListener;
        «ELSE»
            use Symfony\Component\EventDispatcher\EventSubscriberInterface;
            use Zikula\GroupsBundle\Event\GroupApplicationPostCreatedEvent;
            use Zikula\GroupsBundle\Event\GroupApplicationPostProcessedEvent;
            use Zikula\GroupsBundle\Event\GroupPostCreatedEvent;
            use Zikula\GroupsBundle\Event\GroupPostDeletedEvent;
            use Zikula\GroupsBundle\Event\GroupPostUpdatedEvent;
            use Zikula\GroupsBundle\Event\GroupPostUserAddedEvent;
            use Zikula\GroupsBundle\Event\GroupPostUserRemovedEvent;
            use Zikula\GroupsBundle\Event\GroupPreDeletedEvent;
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

    def private listenersIpTraceFile(Application it) '''
        namespace «appNamespace»\EventListener«IF isBase»\Base«ENDIF»;

        «IF !isBase»
            use «appNamespace»\EventListener\Base\AbstractIpTraceListener;
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
        namespace «appNamespace»\EventListener«IF isBase»\Base«ENDIF»;

        «IF !isBase»
            use «appNamespace»\EventListener\Base\AbstractLoggableListener;
        «ELSE»
            use Gedmo\Loggable\LoggableListener as BaseListener;
            use Gedmo\Loggable\Mapping\Event\LoggableAdapter;
            use «appNamespace»\Entity\EntityInterface;
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
        namespace «appNamespace»\EventListener«IF isBase»\Base«ENDIF»;

        «IF !isBase»
            use «appNamespace»\EventListener\Base\AbstractWorkflowEventsListener;
        «ELSE»
            use Symfony\Component\EventDispatcher\EventSubscriberInterface;
            use Symfony\Component\Workflow\Event\Event;
            use Symfony\Component\Workflow\Event\GuardEvent;
            «IF !getJoinRelations.empty && !getAllEntities.filter[!getOutgoingJoinRelationsWithoutDeleteCascade.empty].empty»
                use Symfony\Component\Workflow\TransitionBlocker;
            «ENDIF»
            use Symfony\Contracts\Translation\TranslatorInterface;
            use «appNamespace»\Entity\EntityInterface;
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
