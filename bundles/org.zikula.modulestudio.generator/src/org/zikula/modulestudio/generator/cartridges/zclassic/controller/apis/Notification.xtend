package org.zikula.modulestudio.generator.cartridges.zclassic.controller.apis

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Notification {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    FileHelper fh = new FileHelper

    def generate(Application it, IFileSystemAccess fsa) {
        generateClassPair(fsa, getAppSourceLibPath + 'Helper/NotificationHelper.php',
            fh.phpFileContent(it, notificationHelperBaseClass), fh.phpFileContent(it, notificationHelperImpl)
        )
    }

    def private notificationHelperBaseClass(Application it) '''
        namespace «appNamespace»\Helper\Base;

        use ModUtil;
        use UserUtil;

        use Swift_Message;
        use Symfony\Component\HttpFoundation\Request;
        use Symfony\Component\HttpFoundation\RequestStack;
        use Symfony\Component\HttpFoundation\Session\SessionInterface;
        use Symfony\Component\HttpKernel\KernelInterface;
        use Symfony\Component\Routing\RouterInterface;
        use Twig_Environment;
        use Zikula\Common\Translator\TranslatorInterface;
        use Zikula\Common\Translator\TranslatorTrait;
        use Zikula\Core\Doctrine\EntityAccess;
        use Zikula\ExtensionsModule\Api\VariableApi;
        use Zikula\MailerModule\Api\MailerApi;
        use «appNamespace»\Helper\WorkflowHelper;

        /**
         * Notification helper base class.
         */
        abstract class AbstractNotificationHelper
        {
            «notificationApiBaseImpl»
        }
    '''

    def private notificationApiBaseImpl(Application it) '''
        use TranslatorTrait;

        /**
         * @var SessionInterface
         */
        protected $session;

        /**
         * @var RouterInterface
         */
        protected $router;

        /**
         * @var KernelInterface
         */
        protected $kernel;

        /**
         * @var Request
         */
        protected $request;

        /**
         * @var VariableApi
         */
        protected $variableApi;

        /**
         * @var Twig_Environment
         */
        protected $templating;

        /**
         * @var MailerApi
         */
        protected $mailer;

        /**
         * @var WorkflowHelper
         */
        protected $workflowHelper;

        /**
         * List of notification recipients.
         *
         * @var array $recipients
         */
        private $recipients = [];

        /**
         * Which type of recipient is used ("creator", "moderator" or "superModerator").
         *
         * @var string recipientType
         */
        private $recipientType = '';

        /**
         * The entity which has been changed before.
         *
         * @var EntityAccess entity
         */
        private $entity = '';

        /**
         * Name of workflow action which is being performed.
         *
         * @var string action
         */
        private $action = '';

        /**
         * Name of the application.
         *
         * @var string
         */
        protected $name;

        /**
         * Constructor.
         * Initialises member vars.
         *
         * @param TranslatorInterface $translator     Translator service instance
         * @param SessionInterface    $session        Session service instance
         * @param Routerinterface     $router         Router service instance
         * @param KernelInterface     $kernel         Kernel service instance
         * @param RequestStack        $requestStack   RequestStack service instance
         * @param VariableApi         $variableApi    VariableApi service instance
         * @param Twig_Environment    $twig           Twig service instance
         * @param MailerApi           $mailerApi      MailerApi service instance
         * @param WorkflowHelper      $workflowHelper WorkflowHelper service instance
         */
        public function __construct(
            TranslatorInterface $translator,
            SessionInterface $session,
            RouterInterface $router,
            KernelInterface $kernel,
            RequestStack $requestStack,
            VariableApi $variableApi,
            Twig_Environment $twig,
            MailerApi $mailerApi,
            WorkflowHelper $workflowHelper)
        {
            $this->setTranslator($translator);
            $this->session = $session;
            $this->router = $router;
            $this->kernel = $kernel;
            $this->request = $requestStack->getMasterRequest();
            $this->variableApi = $variableApi;
            $this->templating = $twig;
            $this->mailerApi = $mailerApi;
            $this->workflowHelper = $workflowHelper;
            $this->name = '«appName»';
        }

        «setTranslatorMethod»

        /**
         * Sends a mail to either an item's creator or a group of moderators.
         *
         * @return boolean
         */
        public function process($args)
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

            $this->collectRecipients();

            if (!count($this->recipients)) {
                return true;
            }

            if (null === $this->kernel->getModule('ZikulaMailerModule')) {
                $this->session->getFlashBag()->add('error', $this->__('Could not inform other persons about your amendments, because the Mailer module is not available - please contact an administrator about that!'));

                return false;
            }

            $result = $this->sendMails();

            $this->session->del($this->name . 'AdditionalNotificationRemarks');

            return $result;
        }

        /**
         * Collects the recipients.
         */
        protected function collectRecipients()
        {
            $this->recipients = [];

            if ($this->recipientType == 'moderator' || $this->recipientType == 'superModerator') {
                $objectType = $this->entity['_objectType'];
                $moderatorGroupId = $this->variableApi->get('«appName»', 'moderationGroupFor' . $objectType, 2);
                if ($this->recipientType == 'superModerator') {
                    $moderatorGroupId = $this->variableApi->get('«appName»', 'superModerationGroupFor' . $objectType, 2);
                }

                $moderatorGroup = ModUtil::apiFunc('ZikulaGroupsModule', 'user', 'get', ['gid' => $moderatorGroupId]);
                foreach (array_keys($moderatorGroup['members']) as $uid) {
                    $this->addRecipient($uid);
                }
            } elseif ($this->recipientType == 'creator' && method_exists($entity, 'getCreatedBy')) {
                $creatorUid = $this->entity->getCreatedBy()->getUid();

                $this->addRecipient($creatorUid);
            }

            if (isset($args['debug']) && $args['debug']) {
                // add the admin, too
                $this->addRecipient(2);
            }
        }

        /**
         * Collects data for building the recipients array.
         *
         * @param $userId Id of treated user
         */
        protected function addRecipient($userId)
        {
            $userVars = UserUtil::getVars($userId);

            $recipient = [
                'name' => (isset($userVars['name']) && !empty($userVars['name']) ? $userVars['name'] : $userVars['uname']),
                'email' => $userVars['email']
            ];
            $this->recipients[] = $recipient;

            return $recipient;
        }

        /**
         * Performs the actual mailing.
         */
        protected function sendMails()
        {
            $objectType = $this->entity['_objectType'];
            $siteName = $this->variableApi->getSystemVar('sitename_' . $this->request->getLocale(), $this->variableApi->getSystemVar('sitename_en'));
            $adminMail = $this->variableApi->getSystemVar('adminmail');

            $templateType = $this->recipientType == 'creator' ? 'Creator' : 'Moderator';
            $template = 'Email/notify' . ucfirst($objectType) . $templateType .  '.html.twig';

            $mailData = $this->prepareEmailData();
            $subject = $this->getMailSubject();

            // send one mail per recipient
            $totalResult = true;
            foreach ($this->recipients as $recipient) {
                if (!isset($recipient['name']) || !$recipient['name']) {
                    continue;
                }
                if (!isset($recipient['email']) || !$recipient['email']) {
                    continue;
                }

                $templateParameters = [
                    'recipient' => $recipient,
                    'mailData' => $mailData
                ];

                $body = $this->templating->render('@«appName»/' . $template, $templateParameters);
                $altBody = '';
                $html = true;

                // create new message instance
                /** @var Swift_Message */
                $message = Swift_Message::newInstance();

                $message->setFrom([$adminMail => $siteName]);
                $message->setTo([$recipient['email'] => $recipient['name']]);

                $totalResult &= $this->mailerApi->sendMessage($message, $subject, $body, $altBody, $html);
            }

            return $totalResult;
        }

        /**
         * Returns the subject used for the emails to be sent.
         *
         * @return string
         */
        protected function getMailSubject()
        {
            $mailSubject = '';
            if ($this->recipientType == 'moderator' || $this->recipientType == 'superModerator') {
                if ($this->action == 'submit') {
                    $mailSubject = $this->__('New content has been submitted');
                } elseif ($this->action == 'delete') {
                    $mailSubject = $this->__('Content has been deleted');
                } else {
                    $mailSubject = $this->__('Content has been updated');
                }
            } elseif ($this->recipientType == 'creator') {
                if ($this->action == 'delete') {
                    $mailSubject = $this->__('Your submission has been deleted');
                } else {
                    $mailSubject = $this->__('Your submission has been updated');
                }
            }

            return $mailSubject;
        }

        /**
         * Collects data used by the email templates.
         *
         * @return array
         */
        protected function prepareEmailData()
        {
            $objectType = $this->entity['_objectType'];
            $state = $this->entity['workflowState'];
            $stateInfo = $this->workflowHelper->getStateInfo($state);

            $remarks = $this->session->get($this->name . 'AdditionalNotificationRemarks', '');

            $urlArgs = $this->entity->createUrlArgs();
            $displayUrl = '';
            $editUrl = '';

            if ($this->recipientType == 'moderator' || $this->recipientType == 'superModerator') {
                «IF hasAdminController && getAllAdminControllers.head.hasActions('display')
                    || hasUserController && getMainUserController.hasActions('display')
                    || hasAdminController && getAllAdminControllers.head.hasActions('edit')
                    || hasUserController && getMainUserController.hasActions('edit')»
                    $routeArea = '«IF hasAdminController && getAllAdminControllers.head.hasActions('display')»admin«ENDIF»';
                «ENDIF»
                «IF hasAdminController && getAllAdminControllers.head.hasActions('display')
                    || hasUserController && getMainUserController.hasActions('display')»
                    $displayUrl = $this->router->generate('«appName.formatForDB»_' . strtolower($objectType) . '_' . $routeArea . 'display', $urlArgs, true);
                «ENDIF»
                «IF hasAdminController && getAllAdminControllers.head.hasActions('edit')
                    || hasUserController && getMainUserController.hasActions('edit')»
                    $editUrl = $this->router->generate('«appName.formatForDB»_' . strtolower($objectType) . '_' . $routeArea . 'edit', $urlArgs, true);
                «ENDIF»
            } elseif ($this->recipientType == 'creator') {
                «IF hasUserController»
                    «IF getMainUserController.hasActions('display')»
                        $displayUrl = $this->router->generate('«appName.formatForDB»_' . strtolower($objectType) . '_display', $urlArgs, true);
                    «ENDIF»
                    «IF getMainUserController.hasActions('edit')»
                        $editUrl = $this->router->generate('«appName.formatForDB»_' . strtolower($objectType) . '_edit', $urlArgs, true);
                    «ENDIF»
                «ELSE»
                    // nothing to do as no user controller is available
                «ENDIF»
            }

            $emailData = [
                'name' => $this->entity->getTitleFromDisplayPattern(),
                'newState' => $stateInfo['text'],
                'remarks' => $remarks,
                'displayUrl' => $displayUrl,
                'editUrl' => $editUrl
            ];

            return $emailData;
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
