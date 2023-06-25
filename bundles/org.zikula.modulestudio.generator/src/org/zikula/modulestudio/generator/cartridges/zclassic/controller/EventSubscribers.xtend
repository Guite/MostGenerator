package org.zikula.modulestudio.generator.cartridges.zclassic.controller

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.application.ImportList
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.subscriber.FormTypeChoicesSubscriber
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.subscriber.IpTraceSubscriber
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.subscriber.KernelSubscriber
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.subscriber.LoggableSubscriber
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.subscriber.MailerSubscriber
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.subscriber.ThemeSubscriber
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.subscriber.UserAuthenticationSubscriber
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.subscriber.UserCredentialSubscriber
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.subscriber.UserProfileSubscriber
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.subscriber.UserRegistrationSubscriber
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.subscriber.UserSubscriber
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.subscriber.WorkflowSubscriber
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions
import org.zikula.modulestudio.generator.extensions.Utils
import org.zikula.modulestudio.generator.extensions.WorkflowExtensions

class EventSubscribers {

    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelExtensions = new ModelExtensions
    extension ModelJoinExtensions = new ModelJoinExtensions
    extension Utils = new Utils
    extension WorkflowExtensions = new WorkflowExtensions

    IMostFileSystemAccess fsa
    Boolean isBase

    String subscriberPath
    String subscriberSuffix

    /**
     * Entry point for event subscribers.
     */
    def generate(Application it, IMostFileSystemAccess fsa) {
        this.fsa = fsa
        subscriberSuffix = 'Subscriber.php'

        'Generating event subscriber base classes'.printIfNotTesting(fsa)
        subscriberPath = 'EventSubscriber/Base/'
        isBase = true
        generateSubscriberClasses

        if (generateOnlyBaseClasses) {
            return
        }

        'Generating event subscriber implementation classes'.printIfNotTesting(fsa)
        subscriberPath = 'EventSubscriber/'
        isBase = false
        generateSubscriberClasses
    }

    def private generateSubscriberClasses(Application it) {
        subscriberFile('FormTypeChoices', formTypeChoicesFile)
        subscriberFile('Kernel', subscribersKernelFile)
        subscriberFile('Mailer', subscribersMailerFile)
        subscriberFile('Theme', subscribersThemeFile)
        subscriberFile('UserAuthentication', subscribersUserAuthenticationFile)
        subscriberFile('UserCredential', subscribersUserCredentialFile)
        subscriberFile('User', subscribersUserFile)
        subscriberFile('UserProfile', subscribersUserProfileFile)
        subscriberFile('UserRegistration', subscribersUserRegistrationFile)

        if (!getAllEntities.filter[hasIpTraceableFields].empty) {
            subscriberFile('IpTrace', subscribersIpTraceFile)
        }
        if (hasLoggable) {
            subscriberFile('Loggable', subscribersLoggableFile)
        }
        subscriberFile('WorkflowEvents', subscribersWorkflowEventsFile)
    }

    def private subscriberFile(String name, CharSequence content) {
        var filePath = subscriberPath + (if (isBase) 'Abstract' else '') + name + subscriberSuffix
        fsa.generateFile(filePath, content)
    }

    def private formTypeChoicesFile(Application it) '''
        namespace «appNamespace»\EventSubscriber«IF isBase»\Base«ENDIF»;

        «IF !isBase»
            use «appNamespace»\EventSubscriber\Base\AbstractFormTypeChoicesSubscriber;
        «ELSE»
            use Symfony\Component\EventDispatcher\EventSubscriberInterface;
            use Zikula\FormExtensionBundle\Event\FormTypeChoiceEvent;
        «ENDIF»

        /**
         * Event handler «IF isBase»base«ELSE»implementation«ENDIF» class for injecting custom dynamic form types.
         */
        «IF isBase»abstract «ENDIF»class «IF isBase»Abstract«ENDIF»FormTypeChoicesSubscriber«IF !isBase» extends AbstractFormTypeChoicesSubscriber«ELSE» implements EventSubscriberInterface«ENDIF»
        {
            «IF isBase»
                «new FormTypeChoicesSubscriber().generate(it)»
            «ELSE»
                // feel free to enhance the parent methods
            «ENDIF»
        }
    '''

    def private subscribersKernelFile(Application it) '''
        namespace «appNamespace»\EventSubscriber«IF isBase»\Base«ENDIF»;

        «IF !isBase»
            use «appNamespace»\EventSubscriber\Base\AbstractKernelSubscriber;
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
        «IF isBase»abstract «ENDIF»class «IF isBase»Abstract«ENDIF»KernelSubscriber«IF !isBase» extends AbstractKernelSubscriber«ELSE» implements EventSubscriberInterface«ENDIF»
        {
            «IF isBase»
                «new KernelSubscriber().generate(it)»
            «ELSE»
                // feel free to enhance the parent methods
            «ENDIF»
        }
    '''

    def private subscribersMailerFile(Application it) '''
        namespace «appNamespace»\EventSubscriber«IF isBase»\Base«ENDIF»;

        «IF !isBase»
            use «appNamespace»\EventSubscriber\Base\AbstractMailerSubscriber;
        «ELSE»
            use Symfony\Component\EventDispatcher\EventSubscriberInterface;
            use Symfony\Component\Mailer\Event\FailedMessageEvent;
            use Symfony\Component\Mailer\Event\MessageEvent;
            use Symfony\Component\Mailer\Event\SentMessageEvent;
            use Symfony\Component\Mailer\SentMessage;
            use Symfony\Component\Mime\Email;
        «ENDIF»

        /**
         * Event handler «IF isBase»base«ELSE»implementation«ENDIF» class for mailer events.
         */
        «IF isBase»abstract «ENDIF»class «IF isBase»Abstract«ENDIF»MailerSubscriber«IF !isBase» extends AbstractMailerSubscriber«ELSE» implements EventSubscriberInterface«ENDIF»
        {
            «IF isBase»
                «new MailerSubscriber().generate(it)»
            «ELSE»
                // feel free to enhance the parent methods
            «ENDIF»
        }
    '''

    def private subscribersThemeFile(Application it) '''
        namespace «appNamespace»\EventSubscriber«IF isBase»\Base«ENDIF»;

        «IF !isBase»
            use «appNamespace»\EventSubscriber\Base\AbstractThemeSubscriber;
        «ELSE»
            use Symfony\Component\EventDispatcher\EventSubscriberInterface;
            use Symfony\Component\HttpKernel\Event\ResponseEvent;
            use Symfony\Component\HttpKernel\KernelEvents;
        «ENDIF»

        /**
         * Event handler «IF isBase»base«ELSE»implementation«ENDIF» class for theme-related events.
         */
        «IF isBase»abstract «ENDIF»class «IF isBase»Abstract«ENDIF»ThemeSubscriber«IF !isBase» extends AbstractThemeSubscriber«ELSE» implements EventSubscriberInterface«ENDIF»
        {
            «IF isBase»
                «new ThemeSubscriber().generate(it)»
            «ELSE»
                // feel free to enhance the parent methods
            «ENDIF»
        }
    '''

    def private subscribersUserAuthenticationFile(Application it) '''
        namespace «appNamespace»\EventSubscriber«IF isBase»\Base«ENDIF»;

        «IF !isBase»
            use «appNamespace»\EventSubscriber\Base\AbstractUserAuthenticationSubscriber;
        «ELSE»
            use Nucleos\UserBundle\Event\GetResponseLoginEvent;
            use Nucleos\UserBundle\Event\GetResponseUserEvent;
            use Nucleos\UserBundle\Event\UserEvent;
            use Nucleos\UserBundle\NucleosUserEvents;
            use Symfony\Component\EventDispatcher\EventSubscriberInterface;
            use Symfony\Component\Security\Http\Event\LogoutEvent;
        «ENDIF»

        /**
         * Event handler «IF isBase»base«ELSE»implementation«ENDIF» class for user login and logout events.
         */
        «IF isBase»abstract «ENDIF»class «IF isBase»Abstract«ENDIF»UserAuthenticationSubscriber«IF !isBase» extends AbstractUserAuthenticationSubscriber«ELSE» implements EventSubscriberInterface«ENDIF»
        {
            «IF isBase»
                «new UserAuthenticationSubscriber().generate(it)»
            «ELSE»
                // feel free to enhance the parent methods
            «ENDIF»
        }
    '''

    def private subscribersUserCredentialFile(Application it) '''
        namespace «appNamespace»\EventSubscriber«IF isBase»\Base«ENDIF»;

        «IF !isBase»
            use «appNamespace»\EventSubscriber\Base\AbstractUserCredentialSubscriber;
        «ELSE»
            use Nucleos\UserBundle\Event\FilterUserResponseEvent;
            use Nucleos\UserBundle\Event\FormEvent;
            use Nucleos\UserBundle\Event\GetResponseNullableUserEvent;
            use Nucleos\UserBundle\Event\GetResponseUserEvent;
            use Nucleos\UserBundle\Event\UserEvent;
            use Symfony\Component\EventDispatcher\EventSubscriberInterface;
        «ENDIF»

        /**
         * Event handler «IF isBase»base«ELSE»implementation«ENDIF» class for user crendential related events.
         */
        «IF isBase»abstract «ENDIF»class «IF isBase»Abstract«ENDIF»UserCredentialSubscriber«IF !isBase» extends AbstractUserCredentialSubscriber«ELSE» implements EventSubscriberInterface«ENDIF»
        {
            «IF isBase»
                «new UserCredentialSubscriber().generate(it)»
            «ELSE»
                // feel free to enhance the parent methods
            «ENDIF»
        }
    '''

    def private collectUserBaseImports(Application it) {
        val imports = new ImportList
        imports.addAll(#[
            'Nucleos\\UserBundle\\Event\\AccountDeletionEvent',
            'Nucleos\\UserBundle\\Event\\AccountDeletionResponseEvent',
            'Nucleos\\UserBundle\\Event\\GetResponseAccountDeletionEvent',
            'Nucleos\\UserBundle\\Event\\UserEvent',
            'Nucleos\\UserBundle\\NucleosUserEvents',
            'Symfony\\Component\\EventDispatcher\\EventSubscriberInterface'
        ])
        if (hasStandardFieldEntities || hasUserFields) {
            imports.addAll(#[
                'Psr\\Log\\LoggerInterface',
                'Symfony\\Bundle\\SecurityBundle\\Security',
                appNamespace + '\\Entity\\Factory\\EntityFactory'
            ])
        }
        imports
    }

    def private subscribersUserFile(Application it) '''
        namespace «appNamespace»\EventSubscriber«IF isBase»\Base«ENDIF»;

        «IF !isBase»
            use «appNamespace»\EventSubscriber\Base\AbstractUserSubscriber;
        «ELSE»
            «collectUserBaseImports.print»
        «ENDIF»

        /**
         * Event handler «IF isBase»base«ELSE»implementation«ENDIF» class for user-related events.
         */
        «IF isBase»abstract «ENDIF»class «IF isBase»Abstract«ENDIF»UserSubscriber«IF !isBase» extends AbstractUserSubscriber«ELSE» implements EventSubscriberInterface«ENDIF»
        {
            «IF isBase»
                «new UserSubscriber().generate(it)»
            «ELSE»
                // feel free to enhance the parent methods
            «ENDIF»
        }
    '''

    def private subscribersUserProfileFile(Application it) '''
        namespace «appNamespace»\EventSubscriber«IF isBase»\Base«ENDIF»;

        «IF !isBase»
            use «appNamespace»\EventSubscriber\Base\AbstractUserProfileSubscriber;
        «ELSE»
            use Nucleos\ProfileBundle\Event\UserFormEvent;
            use Nucleos\ProfileBundle\NucleosProfileEvents;
            use Nucleos\UserBundle\Event\FilterUserResponseEvent;
            use Nucleos\UserBundle\Event\GetResponseUserEvent;
            use Symfony\Component\EventDispatcher\EventSubscriberInterface;
        «ENDIF»

        /**
         * Event handler «IF isBase»base«ELSE»implementation«ENDIF» class for user profile events.
         */
        «IF isBase»abstract «ENDIF»class «IF isBase»Abstract«ENDIF»UserProfileSubscriber«IF !isBase» extends AbstractUserProfileSubscriber«ELSE» implements EventSubscriberInterface«ENDIF»
        {
            «IF isBase»
                «new UserProfileSubscriber().generate(it)»
            «ELSE»
                // feel free to enhance the parent methods
            «ENDIF»
        }
    '''

    def private subscribersUserRegistrationFile(Application it) '''
        namespace «appNamespace»\EventSubscriber«IF isBase»\Base«ENDIF»;

        «IF !isBase»
            use «appNamespace»\EventSubscriber\Base\AbstractUserRegistrationSubscriber;
        «ELSE»
            use Nucleos\ProfileBundle\Event\GetResponseRegistrationEvent;
            use Nucleos\ProfileBundle\Event\UserFormEvent;
            use Nucleos\ProfileBundle\NucleosProfileEvents;
            use Nucleos\UserBundle\Event\FilterUserResponseEvent;
            use Nucleos\UserBundle\Event\FormEvent;
            use Nucleos\UserBundle\Event\GetResponseUserEvent;
            use Symfony\Component\EventDispatcher\EventSubscriberInterface;
        «ENDIF»

        /**
         * Event handler «IF isBase»base«ELSE»implementation«ENDIF» class for user registration events.
         */
        «IF isBase»abstract «ENDIF»class «IF isBase»Abstract«ENDIF»UserRegistrationSubscriber«IF !isBase» extends AbstractUserRegistrationSubscriber«ELSE» implements EventSubscriberInterface«ENDIF»
        {
            «IF isBase»
                «new UserRegistrationSubscriber().generate(it)»
            «ELSE»
                // feel free to enhance the parent methods
            «ENDIF»
        }
    '''

    def private subscribersIpTraceFile(Application it) '''
        namespace «appNamespace»\EventSubscriber«IF isBase»\Base«ENDIF»;

        «IF !isBase»
            use «appNamespace»\EventSubscriber\Base\AbstractIpTraceSubscriber;
        «ELSE»
            use Gedmo\IpTraceable\IpTraceableSubscriber;
            use Symfony\Component\EventDispatcher\EventSubscriberInterface;
            use Symfony\Component\HttpFoundation\RequestStack;
            use Symfony\Component\HttpKernel\Event\RequestEvent;
            use Symfony\Component\HttpKernel\KernelEvents;
        «ENDIF»

        /**
         * Event handler implementation class for ip traceable support.
         *
         * Can be removed after https://github.com/stof/StofDoctrineExtensionsBundle/pull/233 has been merged.
         */
        «IF isBase»abstract «ENDIF»class «IF isBase»Abstract«ENDIF»IpTraceSubscriber«IF !isBase» extends AbstractIpTraceSubscriber«ELSE» implements EventSubscriberInterface«ENDIF»
        {
            «IF isBase»
                «new IpTraceSubscriber().generate(it)»
            «ELSE»
                // feel free to enhance the parent methods
            «ENDIF»
        }
    '''

    def private subscribersLoggableFile(Application it) '''
        namespace «appNamespace»\EventSubscriber«IF isBase»\Base«ENDIF»;

        «IF !isBase»
            use «appNamespace»\EventSubscriber\Base\AbstractLoggableSubscriber;
        «ELSE»
            use Gedmo\Loggable\LoggableSubscriber as BaseSubscriber;
            use Gedmo\Loggable\Mapping\Event\LoggableAdapter;
            use «appNamespace»\Entity\EntityInterface;
            use «appNamespace»\Helper\EntityDisplayHelper;
            use «appNamespace»\Helper\LoggableHelper;
        «ENDIF»

        /**
         * Event handler implementation class for injecting log entry additions.
         */
        «IF isBase»abstract «ENDIF»class «IF isBase»Abstract«ENDIF»LoggableSubscriber«IF !isBase» extends AbstractLoggableSubscriber«ELSE» extends BaseSubscriber«ENDIF»
        {
            «IF isBase»
                «new LoggableSubscriber().generate(it)»
            «ELSE»
                // feel free to enhance the parent methods
            «ENDIF»
        }
    '''

    def private subscribersWorkflowEventsFile(Application it) '''
        namespace «appNamespace»\EventSubscriber«IF isBase»\Base«ENDIF»;

        «IF !isBase»
            use «appNamespace»\EventSubscriber\Base\AbstractWorkflowEventsSubscriber;
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
        «IF isBase»abstract «ENDIF»class «IF isBase»Abstract«ENDIF»WorkflowEventsSubscriber«IF !isBase» extends AbstractWorkflowEventsSubscriber«ELSE» implements EventSubscriberInterface«ENDIF»
        {
            «IF isBase»
                «new WorkflowSubscriber().generate(it)»
            «ELSE»
                // feel free to enhance the parent methods
            «ENDIF»
        }
    '''
}
