package org.zikula.modulestudio.generator.cartridges.zclassic.controller.helper

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.EntityWorkflowType
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class NotificationHelper {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelExtensions = new ModelExtensions
    extension Utils = new Utils

    def generate(Application it, IMostFileSystemAccess fsa) {
        'Generating helper class for workflow notifications'.printIfNotTesting(fsa)
        fsa.generateClassPair('Helper/NotificationHelper.php', notificationHelperBaseClass, notificationHelperImpl)
    }

    def private notificationHelperBaseClass(Application it) '''
        namespace «appNamespace»\Helper\Base;

        «IF targets('3.0')»
            use Psr\Log\LoggerInterface;
        «ELSE»
            use Swift_Message;
        «ENDIF»
        use Symfony\Component\HttpFoundation\RequestStack;
        «IF targets('3.0')»
            use Symfony\Component\Mailer\Exception\TransportExceptionInterface;
            use Symfony\Component\Mailer\MailerInterface;
            use Symfony\Component\Mime\Address;
            use Symfony\Component\Mime\Email;
        «ENDIF»
        use Symfony\Component\Routing\Generator\UrlGeneratorInterface;
        use Symfony\Component\Routing\RouterInterface;
        «IF targets('3.0')»
            use Symfony\Contracts\Translation\TranslatorInterface;
        «ENDIF»
        use Twig«IF targets('3.0')»\«ELSE»_«ENDIF»Environment;
        use Zikula\Bundle\CoreBundle\HttpKernel\ZikulaHttpKernelInterface;
        «IF targets('3.0')»
            use Zikula\Bundle\CoreBundle\Doctrine\EntityAccess;
            use Zikula\Bundle\CoreBundle\Translation\TranslatorTrait;
        «ELSE»
            use Zikula\Common\Translator\TranslatorInterface;
            use Zikula\Common\Translator\TranslatorTrait;
            use Zikula\Core\Doctrine\EntityAccess;
        «ENDIF»
        use Zikula\ExtensionsModule\Api\ApiInterface\VariableApiInterface;
        use Zikula\GroupsModule\Constant as GroupsConstant;
        use Zikula\GroupsModule\Entity\RepositoryInterface\GroupRepositoryInterface;
        «IF !targets('3.0')»
            use Zikula\MailerModule\Api\ApiInterface\MailerApiInterface;
        «ENDIF»
        use Zikula\UsersModule\Constant as UsersConstant;
        use Zikula\UsersModule\Entity\RepositoryInterface\UserRepositoryInterface;
        use Zikula\UsersModule\Entity\UserEntity;
        use «appNamespace»\Helper\EntityDisplayHelper;
        use «appNamespace»\Helper\WorkflowHelper;

        /**
         * Notification helper base class.
         */
        abstract class AbstractNotificationHelper
        {
            «helperBaseImpl»
        }
    '''

    def private helperBaseImpl(Application it) '''
        use TranslatorTrait;

        /**
         * @var RouterInterface
         */
        protected $router;

        /**
         * @var ZikulaHttpKernelInterface
         */
        protected $kernel;

        /**
         * @var RequestStack
         */
        protected $requestStack;

        /**
         * @var VariableApiInterface
         */
        protected $variableApi;

        /**
         * @var «IF !targets('3.0')»Twig_«ENDIF»Environment
         */
        protected $twig;

        /**
         * @var «IF targets('3.0')»MailerInterface«ELSE»MailerApiInterface«ENDIF»
         */
        protected $mailer;
        «IF targets('3.0')»

            /**
             * @var LoggerInterface
             */
            protected $mailLogger;

            /**
             * @var bool
             */
            protected $mailLoggingEnabled;
        «ENDIF»

        /**
         * @var GroupRepositoryInterface
         */
        protected $groupRepository;

        /**
         * @var UserRepositoryInterface
         */
        protected $userRepository;

        /**
         * @var EntityDisplayHelper
         */
        protected $entityDisplayHelper;

        /**
         * @var WorkflowHelper
         */
        protected $workflowHelper;

        /**
         * List of notification recipients.
         *
         * @var array $recipients
         */
        protected $recipients = [];

        /**
         * Which type of recipient is used ("creator", "moderator" or "superModerator").
         *
         * @var string recipientType
         */
        protected $recipientType = '';

        /**
         * The entity which has been changed before.
         *
         * @var EntityAccess entity
         */
        protected $entity = '';

        /**
         * Name of workflow action which is being performed.
         *
         * @var string action
         */
        protected $action = '';

        /**
         * Name of the application.
         *
         * @var string
         */
        protected $name;

        public function __construct(
            ZikulaHttpKernelInterface $kernel,
            TranslatorInterface $translator,
            RouterInterface $router,
            RequestStack $requestStack,
            VariableApiInterface $variableApi,
            «IF !targets('3.0')»Twig_«ENDIF»Environment $twig,
            «IF targets('3.0')»MailerInterface $mailer«ELSE»MailerApiInterface $mailerApi«ENDIF»,
            «IF targets('3.0')»
                LoggerInterface $mailLogger, // $mailLogger var name auto-injects the mail channel handler
            «ENDIF»
            GroupRepositoryInterface $groupRepository,
            UserRepositoryInterface $userRepository,
            EntityDisplayHelper $entityDisplayHelper,
            WorkflowHelper $workflowHelper
        ) {
            $this->kernel = $kernel;
            $this->setTranslator($translator);
            $this->router = $router;
            $this->requestStack = $requestStack;
            $this->variableApi = $variableApi;
            $this->twig = $twig;
            $this->mailer = «IF targets('3.0')»$mailer«ELSE»$mailerApi«ENDIF»;
            «IF targets('3.0')»
                $this->mailLogger = $mailLogger;
                $this->mailLoggingEnabled = $variableApi->get('ZikulaMailerModule', 'enableLogging', false);
            «ENDIF»
            $this->groupRepository = $groupRepository;
            $this->userRepository = $userRepository;
            $this->entityDisplayHelper = $entityDisplayHelper;
            $this->workflowHelper = $workflowHelper;
            $this->name = '«appName»';
        }
        «IF !targets('3.0')»

            «setTranslatorMethod»
        «ENDIF»

        «process»

        «collectRecipients»

        «addRecipient»

        «sendMails»

        «getMailSubject»

        «prepareEmailData»

        «usesDesignatedEntityFields»

        «getEditorName»
    '''

    def private process(Application it) '''
        /**
         * Sends a mail to either an item's creator or a group of moderators.
         «IF !targets('3.0')»
         *
         * @param array $args
         *
         * @return bool
         «ENDIF»
         */
        public function process(array $args)«IF targets('3.0')»: bool«ENDIF»
        {
            if (!isset($args['recipientType']) || !$args['recipientType']) {
                return false;
            }

            if (!isset($args['action']) || !$args['action']) {
                return false;
            }

            if (!isset($args['entity']) || !$args['entity']) {
                return false;
            }

            $this->recipientType = $args['recipientType'];
            $this->action = $args['action'];
            $this->entity = $args['entity'];

            $debug = isset($args['debug']) && $args['debug'];
            $this->collectRecipients($debug);

            if (!count($this->recipients)) {
                return true;
            }

            $result = $this->sendMails();

            $request = $this->requestStack->getCurrentRequest();
            $session = null !== $request && $request->hasSession() ? $request->getSession() : null;
            if (null !== $session) {
                $session->remove($this->name . 'AdditionalNotificationRemarks');
            }

            return $result;
        }
    '''

    def private collectRecipients(Application it) '''
        /**
         * Collects the recipients.
         *
         * @param bool $debug Whether to add the admin or not
         */
        protected function collectRecipients(«IF targets('3.0')»bool «ENDIF»$debug = false)
        {
            $this->recipients = [];

            if (in_array($this->recipientType, ['moderator', 'superModerator'], true)) {
                «val entitiesWithWorkflow = getAllEntities.filter[workflow != EntityWorkflowType.NONE]»
                $modVarSuffixes = [
                    «FOR entity : entitiesWithWorkflow»
                        '«entity.name.formatForCode»' => '«entity.nameMultiple.formatForCodeCapital»'«IF entity != entitiesWithWorkflow.last»,«ENDIF»
                    «ENDFOR»
                ];
                $modVarSuffix = $modVarSuffixes[$this->entity->get_objectType()];

                $moderatorGroupId = $this->variableApi->get(
                    '«appName»',
                    'moderationGroupFor' . $modVarSuffix,
                    GroupsConstant::GROUP_ID_ADMIN
                );
                if ('superModerator' === $this->recipientType) {
                    $moderatorGroupId = $this->variableApi->get(
                        '«appName»',
                        'superModerationGroupFor' . $modVarSuffix,
                        GroupsConstant::GROUP_ID_ADMIN
                    );
                }

                $moderatorGroup = $this->groupRepository->find($moderatorGroupId);
                if (null !== $moderatorGroup) {
                    foreach ($moderatorGroup['users'] as $user) {
                        $this->addRecipient($user);
                    }
                }
            } elseif ('creator' === $this->recipientType && method_exists($this->entity, 'getCreatedBy')) {
                $this->addRecipient($this->entity->getCreatedBy());
            } elseif ($this->usesDesignatedEntityFields()) {
                $this->addRecipient();
            }

            if ($debug) {
                // add the admin, too
                $this->addRecipient($this->userRepository->find(UsersConstant::USER_ID_ADMIN));
            }
        }
    '''

    def private addRecipient(Application it) '''
        /**
         * Collects data for building the recipients array.
         «IF !targets('3.0')»
         *
         * @param UserEntity $user Recipient user record
         «ENDIF»
         */
        protected function addRecipient(UserEntity $user = null)«IF targets('3.0')»: void«ENDIF»
        {
            if ($this->usesDesignatedEntityFields()) {
                $recipientTypeParts = explode('-', $this->recipientType);
                if (count($recipientTypeParts) != 2) {
                    return;
                }
                $fieldNames = explode('^', $recipientTypeParts[1]);
                if (count($fieldNames) != 2) {
                    return;
                }

                $this->recipients[] = [
                    'name' => $this->entity[$fieldNames[1]],
                    'email' => $this->entity[$fieldNames[0]]
                ];

                return;
            }

            if (null === $user) {
                return;
            }

            $userAttributes = $user->getAttributes();
            $recipientName = isset($userAttributes['name']) && !empty($userAttributes['name'])
                ? $userAttributes['name']
                : $user->getUname()
            ;
            $this->recipients[] = [
                'name' => $recipientName,
                'email' => $user->getEmail()
            ];
        }
    '''

    def private sendMails(Application it) '''
        /**
         * Performs the actual mailing.
         «IF !targets('3.0')»
         *
         * @return bool
         «ENDIF»
         */
        protected function sendMails()«IF targets('3.0')»: bool«ENDIF»
        {
            $objectType = $this->entity->get_objectType();
            $siteName = $this->variableApi->getSystemVar('sitename');
            $adminMail = $this->variableApi->getSystemVar('adminmail');

            $templateType = '';
            if ($this->usesDesignatedEntityFields()) {
                $templateType = $this->recipientType;
            } else {
                $templateType = $this->recipientType == 'creator' ? 'Creator' : 'Moderator';
            }
            $template = 'Email/notify' . ucfirst($objectType) . $templateType .  '.html.twig';

            $mailData = $this->prepareEmailData();
            $subject = $this->getMailSubject();

            // send one mail per recipient
            «IF targets('3.0')»
                «sendMailsProcessing»
            «ELSE»
                «sendMailsProcessingLegacy»
            «ENDIF»
        }
    '''

    def private sendMailsProcessing(Application it) '''
        try {
            foreach ($this->recipients as $recipient) {
                if (!isset($recipient['name']) || !$recipient['name']) {
                    continue;
                }
                if (!isset($recipient['email']) || !$recipient['email']) {
                    continue;
                }

                $body = $this->twig->render('@«appName»/' . $template, [
                    'recipient' => $recipient,
                    'mailData' => $mailData
                ]);

                $email = (new Email())
                    ->from(new Address($adminMail, $siteName))
                    ->to(new Address($recipient['email'], $recipient['name']))
                    ->subject($subject)
                    ->html($body)
                ;    

                $this->mailer->send($email);

                if ($this->mailLoggingEnabled) {
                    $this->mailLogger->info(sprintf('Email sent to %s', $recipient['email']), [
                        'in' => __METHOD__
                    ]);
                }
            }
        } catch (TransportExceptionInterface $exception) {
            $this->mailLogger->error($exception->getMessage(), [
                'in' => __METHOD__
            ]);

            return false;
        }

        return true;
    '''

    def private sendMailsProcessingLegacy(Application it) '''
        $totalResult = true;
        foreach ($this->recipients as $recipient) {
            if (!isset($recipient['name']) || !$recipient['name']) {
                continue;
            }
            if (!isset($recipient['email']) || !$recipient['email']) {
                continue;
            }

            $body = $this->twig->render('@«appName»/' . $template, [
                'recipient' => $recipient,
                'mailData' => $mailData
            ]);
            $altBody = '';
            $html = true;

            // create new message instance
            /** @var Swift_Message */
            $message = Swift_Message::newInstance();
            $message->setFrom([$adminMail => $siteName]);
            $message->setTo([$recipient['email'] => $recipient['name']]);

            $totalResult = $totalResult && $this->mailer->sendMessage($message, $subject, $body, $altBody, $html);
        }

        return $totalResult;
    '''

    def private getMailSubject(Application it) '''
        /**
         * Returns the subject used for the emails to be sent.
         «IF !targets('3.0')»
         *
         * @return string
         «ENDIF»
         */
        protected function getMailSubject()«IF targets('3.0')»: string«ENDIF»
        {
            $mailSubject = '';
            if (
                in_array($this->recipientType, ['moderator', 'superModerator'], true)
                || $this->usesDesignatedEntityFields()
            ) {
                if ('submit' === $this->action) {
                    $mailSubject = $this->«IF targets('3.0')»trans«ELSE»__«ENDIF»('New content has been submitted'«IF targets('3.0')», [], 'mail'«ENDIF»);
                } elseif ('demote' === $this->action) {
                    $mailSubject = $this->«IF targets('3.0')»trans«ELSE»__«ENDIF»('Content has been demoted'«IF targets('3.0')», [], 'mail'«ENDIF»);
                } elseif ('accept' === $this->action) {
                    $mailSubject = $this->«IF targets('3.0')»trans«ELSE»__«ENDIF»('Content has been accepted'«IF targets('3.0')», [], 'mail'«ENDIF»);
                } elseif ('approve' === $this->action) {
                    $mailSubject = $this->«IF targets('3.0')»trans«ELSE»__«ENDIF»('Content has been approved'«IF targets('3.0')», [], 'mail'«ENDIF»);
                } elseif ('delete' === $this->action) {
                    $mailSubject = $this->«IF targets('3.0')»trans«ELSE»__«ENDIF»('Content has been deleted'«IF targets('3.0')», [], 'mail'«ENDIF»);
                } else {
                    $mailSubject = $this->«IF targets('3.0')»trans«ELSE»__«ENDIF»('Content has been updated'«IF targets('3.0')», [], 'mail'«ENDIF»);
                }
            } elseif ('creator' === $this->recipientType) {
                if ('accept' === $this->action) {
                    $mailSubject = $this->«IF targets('3.0')»trans«ELSE»__«ENDIF»('Your submission has been accepted'«IF targets('3.0')», [], 'mail'«ENDIF»);
                } elseif ('approve' === $this->action) {
                    $mailSubject = $this->«IF targets('3.0')»trans«ELSE»__«ENDIF»('Your submission has been approved'«IF targets('3.0')», [], 'mail'«ENDIF»);
                } elseif ('reject' === $this->action) {
                    $mailSubject = $this->«IF targets('3.0')»trans«ELSE»__«ENDIF»('Your submission has been rejected'«IF targets('3.0')», [], 'mail'«ENDIF»);
                } elseif ('delete' === $this->action) {
                    $mailSubject = $this->«IF targets('3.0')»trans«ELSE»__«ENDIF»('Your submission has been deleted'«IF targets('3.0')», [], 'mail'«ENDIF»);
                } else {
                    $mailSubject = $this->«IF targets('3.0')»trans«ELSE»__«ENDIF»('Your submission has been updated'«IF targets('3.0')», [], 'mail'«ENDIF»);
                }
            }

            return $mailSubject;
        }
    '''

    def private prepareEmailData(Application it) '''
        /**
         * Collects data used by the email templates.
         «IF !targets('3.0')»
         *
         * @return array Email template data
         «ENDIF»
         */
        protected function prepareEmailData()«IF targets('3.0')»: array«ENDIF»
        {
            $objectType = $this->entity->get_objectType();
            $state = $this->entity->getWorkflowState();
            $stateInfo = $this->workflowHelper->getStateInfo($state);

            $request = $this->requestStack->getCurrentRequest();
            $session = null !== $request && $request->hasSession() ? $request->getSession() : null;
            $remarks = null !== $session ? $session->get($this->name . 'AdditionalNotificationRemarks', '') : '';

            $hasDisplayAction = in_array($objectType, ['«getAllEntities.filter[hasDisplayAction].map[name.formatForCode].join('\', \'')»'], true);
            $hasEditAction = in_array($objectType, ['«getAllEntities.filter[hasEditAction].map[name.formatForCode].join('\', \'')»'], true);
            $routeArea = in_array($this->recipientType, ['moderator', 'superModerator'], true) ? 'admin' : '';
            $routePrefix = '«appName.formatForDB»_' . strtolower($objectType) . '_' . $routeArea;

            $urlArgs = $this->entity->createUrlArgs();
            $displayUrl = $hasDisplayAction
                ? $this->router->generate($routePrefix . 'display', $urlArgs, UrlGeneratorInterface::ABSOLUTE_URL)
                : ''
            ;

            «IF !getAllEntities.filter[hasEditAction && hasSluggableFields && slugUnique].empty»
                $needsArg = in_array($objectType, ['«getAllEntities.filter[hasEditAction && hasSluggableFields && slugUnique].map[name.formatForCode].join('\', \'')»'], true);
                $urlArgs = $needsArg ? $this->entity->createUrlArgs(true) : $this->entity->createUrlArgs();
            «ENDIF»
            $editUrl = $hasEditAction
                ? $this->router->generate($routePrefix . 'edit', $urlArgs, UrlGeneratorInterface::ABSOLUTE_URL)
                : ''
            ;

            return [
                'name' => $this->entityDisplayHelper->getFormattedTitle($this->entity),
                'newState' => $stateInfo['text'],
                'remarks' => $remarks,
                'editor' => $this->getEditorName(),
                'displayUrl' => $displayUrl,
                'editUrl' => $editUrl
            ];
        }
    '''

    def private usesDesignatedEntityFields(Application it) '''
        /**
         * Checks whether a special notification type is used or not.
         «IF !targets('3.0')»
         *
         * @return bool
         «ENDIF»
         */
        protected function usesDesignatedEntityFields()«IF targets('3.0')»: bool«ENDIF»
        {
            return 0 === strpos($this->recipientType, 'field-');
        }
    '''

    def private getEditorName(Application it) '''
        /**
         * Determines name of editor for the given entity.
         «IF !targets('3.0')»
         *
         * @return string
         «ENDIF»
         */
        protected function getEditorName()«IF targets('3.0')»: string«ENDIF»
        {
            «IF !hasStandardFieldEntities»
                return '';
            «ELSE»
                if (!in_array($this->entity->get_objectType(), ['«standardFieldEntities.map[name.formatForCode].join('\', \'')»'], true)) {
                    return '';
                }

                return $this->entity->getUpdatedBy()->getUname();
            «ENDIF»
        }
    '''

    def private notificationHelperImpl(Application it) '''
        namespace «appNamespace»\Helper;

        use «appNamespace»\Helper\Base\AbstractNotificationHelper;

        /**
         * Notification helper implementation class.
         */
        class NotificationHelper extends AbstractNotificationHelper
        {
            // feel free to extend the notification helper here
        }
    '''
}
