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

        use Psr\Log\LoggerInterface;
        use Symfony\Component\HttpFoundation\RequestStack;
        use Symfony\Component\Mailer\Exception\TransportExceptionInterface;
        use Symfony\Component\Mailer\MailerInterface;
        use Symfony\Component\Mime\Address;
        use Symfony\Component\Mime\Email;
        use Symfony\Component\Routing\Generator\UrlGeneratorInterface;
        use Symfony\Component\Routing\RouterInterface;
        use Symfony\Contracts\Translation\TranslatorInterface;
        use Twig\Environment;
        use Zikula\Bundle\CoreBundle\Site\SiteDefinitionInterface;
        use Zikula\Bundle\CoreBundle\Translation\TranslatorTrait;
        use Zikula\GroupsBundle\GroupsConstant;
        use Zikula\GroupsBundle\Repository\GroupRepositoryInterface;
        use Zikula\UsersBundle\Entity\User;
        use Zikula\UsersBundle\Repository\UserRepositoryInterface;
        use Zikula\UsersBundle\UsersConstant;
        use «appNamespace»\Entity\EntityInterface;
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
         * List of notification recipients.
         */
        protected array $recipients = [];

        /**
         * Which type of recipient is used ("creator", "moderator" or "superModerator").
         */
        protected string $recipientType = '';

        /**
         * The entity which has been changed before.
         */
        protected EntityInterface $entity;

        /**
         * Name of workflow action which is being performed.
         */
        protected string $action = '';

        /**
         * Name of the application.
         */
        protected string $applicationName;

        public function __construct(
            TranslatorInterface $translator,
            protected readonly RouterInterface $router,
            protected readonly RequestStack $requestStack,
            protected readonly Environment $twig,
            protected readonly SiteDefinitionInterface $site,
            protected readonly MailerInterface $mailer,
            protected readonly LoggerInterface $mailLogger, // $mailLogger var name auto-injects the mail channel handler
            protected readonly GroupRepositoryInterface $groupRepository,
            protected readonly UserRepositoryInterface $userRepository,
            protected readonly EntityDisplayHelper $entityDisplayHelper,
            protected readonly WorkflowHelper $workflowHelper,
            protected readonly bool $mailLoggingEnabled,
            protected readonly array $moderationConfig
        ) {
            $this->setTranslator($translator);
            $this->applicationName = '«appName»';
        }

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
         */
        public function process(array $args): bool
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
                $session->remove($this->applicationName . 'AdditionalNotificationRemarks');
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
        protected function collectRecipients(bool $debug = false)
        {
            $this->recipients = [];

            if (in_array($this->recipientType, ['moderator', 'superModerator'], true)) {
                «val entitiesWithWorkflow = getAllEntities.filter[workflow != EntityWorkflowType.NONE]»
                $configSuffixes = [
                    «FOR entity : entitiesWithWorkflow»
                        '«entity.name.formatForCode»' => '«entity.nameMultiple.formatForSnakeCase»',
                    «ENDFOR»
                ];
                $configSuffix = $configSuffixes[$this->entity->get_objectType()];

                $moderatorGroupId = $this->moderationConfig['moderation_group_for_' . $configSuffix];
                if ('superModerator' === $this->recipientType) {
                    $moderatorGroupId = $this->moderationConfig['super_moderation_group_for_' . $configSuffix];
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
         */
        protected function addRecipient(?User $user = null): void
        {
            if ($this->usesDesignatedEntityFields()) {
                $recipientTypeParts = explode('-', $this->recipientType);
                if (2 !== count($recipientTypeParts)) {
                    return;
                }
                $fieldNames = explode('^', $recipientTypeParts[1]);
                if (2 !== count($fieldNames)) {
                    return;
                }

                $this->recipients[] = [
                    'name' => $this->entity[$fieldNames[1]],
                    'email' => $this->entity[$fieldNames[0]],
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
                'email' => $user->getEmail(),
            ];
        }
    '''

    def private sendMails(Application it) '''
        /**
         * Performs the actual mailing.
         */
        protected function sendMails(): bool
        {
            $objectType = $this->entity->get_objectType();
            $siteName = $this->site->getName();
            $adminMail = $this->site->getAdminMail();

            $templateType = '';
            if ($this->usesDesignatedEntityFields()) {
                $templateType = $this->recipientType;
            } else {
                $templateType = 'creator' === $this->recipientType ? 'Creator' : 'Moderator';
            }
            $template = 'Email/notify' . ucfirst($objectType) . $templateType . '.html.twig';

            $mailData = $this->prepareEmailData();
            $subject = $this->getMailSubject();

            // send one mail per recipient
            «sendMailsProcessing»
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

                $body = $this->twig->render('@«vendorAndName»/' . $template, [
                    'recipient' => $recipient,
                    'mailData' => $mailData,
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
                        'in' => __METHOD__,
                    ]);
                }
            }
        } catch (TransportExceptionInterface $exception) {
            $this->mailLogger->error($exception->getMessage(), [
                'in' => __METHOD__,
            ]);

            return false;
        }

        return true;
    '''

    def private getMailSubject(Application it) '''
        /**
         * Returns the subject used for the emails to be sent.
         */
        protected function getMailSubject(): string
        {
            $mailSubject = '';
            if (
                in_array($this->recipientType, ['moderator', 'superModerator'], true)
                || $this->usesDesignatedEntityFields()
            ) {
                if ('submit' === $this->action) {
                    $mailSubject = $this->trans('New content has been submitted', [], 'mail');
                } elseif ('demote' === $this->action) {
                    $mailSubject = $this->trans('Content has been demoted', [], 'mail');
                } elseif ('accept' === $this->action) {
                    $mailSubject = $this->trans('Content has been accepted', [], 'mail');
                } elseif ('approve' === $this->action) {
                    $mailSubject = $this->trans('Content has been approved', [], 'mail');
                } elseif ('delete' === $this->action) {
                    $mailSubject = $this->trans('Content has been deleted', [], 'mail');
                } else {
                    $mailSubject = $this->trans('Content has been updated', [], 'mail');
                }
            } elseif ('creator' === $this->recipientType) {
                if ('accept' === $this->action) {
                    $mailSubject = $this->trans('Your submission has been accepted', [], 'mail');
                } elseif ('approve' === $this->action) {
                    $mailSubject = $this->trans('Your submission has been approved', [], 'mail');
                } elseif ('reject' === $this->action) {
                    $mailSubject = $this->trans('Your submission has been rejected', [], 'mail');
                } elseif ('delete' === $this->action) {
                    $mailSubject = $this->trans('Your submission has been deleted', [], 'mail');
                } else {
                    $mailSubject = $this->trans('Your submission has been updated', [], 'mail');
                }
            }

            return $mailSubject;
        }
    '''

    def private prepareEmailData(Application it) '''
        /**
         * Collects data used by the email templates.
         */
        protected function prepareEmailData(): array
        {
            $objectType = $this->entity->get_objectType();
            $state = $this->entity->getWorkflowState();
            $stateInfo = $this->workflowHelper->getStateInfo($state);

            $request = $this->requestStack->getCurrentRequest();
            $session = null !== $request && $request->hasSession() ? $request->getSession() : null;
            $remarks = null !== $session ? $session->get($this->applicationName . 'AdditionalNotificationRemarks', '') : '';

            $hasDetailAction = in_array($objectType, ['«getAllEntities.filter[hasDetailAction].map[name.formatForCode].join('\', \'')»'], true);
            $hasEditAction = in_array($objectType, ['«getAllEntities.filter[hasEditAction].map[name.formatForCode].join('\', \'')»'], true);
            $routeArea = in_array($this->recipientType, ['moderator', 'superModerator'], true) ? 'admin' : '';
            $routePrefix = '«appName.formatForDB»_' . mb_strtolower($objectType) . '_' . $routeArea;

            $urlArgs = $this->entity->createUrlArgs();
            $detailUrl = $hasDetailAction
                ? $this->router->generate($routePrefix . 'detail', $urlArgs, UrlGeneratorInterface::ABSOLUTE_URL)
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
                'detailUrl' => $detailUrl,
                'editUrl' => $editUrl,
            ];
        }
    '''

    def private usesDesignatedEntityFields(Application it) '''
        /**
         * Checks whether a special notification type is used or not.
         */
        protected function usesDesignatedEntityFields(): bool
        {
            return 0 === mb_strpos($this->recipientType, 'field-');
        }
    '''

    def private getEditorName(Application it) '''
        /**
         * Determines name of editor for the given entity.
         */
        protected function getEditorName(): string
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
