package org.zikula.modulestudio.generator.cartridges.zclassic.controller.apis

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Notification {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    FileHelper fh = new FileHelper

    def generate(Application it, IFileSystemAccess fsa) {
        if (targets('1.3.x')) {
            generateClassPair(fsa, getAppSourceLibPath + 'Api/Notification.php',
                fh.phpFileContent(it, notificationApiBaseClass), fh.phpFileContent(it, notificationApiImpl)
            )
        } else {
            generateClassPair(fsa, getAppSourceLibPath + 'Helper/NotificationHelper.php',
                fh.phpFileContent(it, notificationHelperBaseClass), fh.phpFileContent(it, notificationHelperImpl)
            )
        }
    }

    def private notificationApiBaseClass(Application it) '''
        /**
         * Notification api base class.
         */
        class «appName»_Api_Base_Notification extends Zikula_AbstractApi
        {
            «notificationApiBaseImpl»
        }
    '''

    def private notificationHelperBaseClass(Application it) '''
        namespace «appNamespace»\Helper\Base;

        use LogUtil;
        use ModUtil;
        use ServiceUtil;
        use System;
        use UserUtil;
        use ZLanguage;

        use Swift_Message;
        use Symfony\Component\HttpFoundation\Session\Session;
        use Symfony\Component\Routing\RouterInterface;
        use Twig_Environment;
        use Zikula\Common\Translator\TranslatorInterface;
        use Zikula\Common\Translator\TranslatorTrait;
        use Zikula\Core\Doctrine\EntityAccess;
        use Zikula\ExtensionsModule\Api\VariableApi;
        use Zikula\MailerModule\Api\MailerApi;
        use Zikula\UsersModule\Api\CurrentUserApi;

        /**
         * Notification helper base class.
         */
        class NotificationHelper
        {
            «notificationApiBaseImpl»
        }
    '''

    def private notificationApiBaseImpl(Application it) '''
        «IF !targets('1.3.x')»
            use TranslatorTrait;

            /**
             * @var Session
             */
            protected $session;

            /**
             * @var RouterInterface
             */
            protected $router;

            /**
             * @var VariableApi
             */
            protected $variableApi;

            /**
             * @var CurrentUserApi
             */
            private $currentUserApi;

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

        «ENDIF»
        /**
         * List of notification recipients.
         *
         * @var array $recipients
         */
        private $recipients = «IF targets('1.3.x')»array()«ELSE»[]«ENDIF»;

        /**
         * Which type of recipient is used ("creator", "moderator" or "superModerator").
         *
         * @var string recipientType
         */
        private $recipientType = '';

        /**
         * The entity which has been changed before.
         *
         * @var «IF targets('1.3.x')»Zikula_«ENDIF»EntityAccess entity
         */
        private $entity = '';

        /**
         * Name of workflow action which is being performed.
         *
         * @var string action
         */
        private $action = '';

        «IF !targets('1.3.x')»
            /**
             * Constructor.
             * Initialises member vars.
             *
             * @param TranslatorInterface $translator     Translator service instance
             * @param Session             $session        Session service instance
             * @param Routerinterface     $router         Router service instance
             * @param VariableApi         $variableApi    VariableApi service instance
             * @param CurrentUserApi      $currentUserApi CurrentUserApi service instance
             * @param Twig_Environment    $twig           Twig service instance
             * @param MailerApi           $mailerApi      MailerApi service instance
             * @param WorkflowHelper      $workflowHelper WorkflowHelper service instance
             */
            public function __construct(
                TranslatorInterface $translator,
                Session $session,
                RouterInterface $router,
                VariableApi $variableApi,
                CurrentUserApi $currentUserApi,
                Twig_Environment $twig,
                MailerApi $mailerApi,
                WorkflowHelper $workflowHelper)
            {
                $this->setTranslator($translator);
                $this->session = $session;
                $this->router = $router;
                $this->variableApi = $variableApi;
                $this->currentUserApi = $currentUserApi;
                $this->templating = $twig;
                $this->mailerApi = $mailerApi;
                $this->workflowHelper = $workflowHelper;
            }

            /**
             * Sets the translator.
             *
             * @param TranslatorInterface $translator Translator service instance
             */
            public function setTranslator(/*TranslatorInterface */$translator)
            {
                $this->translator = $translator;
            }
        «ENDIF»

        /**
         * Sends a mail to either an item's creator or a group of moderators.
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

            «IF targets('1.3.x')»
                $uid = UserUtil::getVar('uid');
            «ELSE»
                $uid = $this->currentUserApi->get('uid');
            «ENDIF»

            $this->collectRecipients();

            if (!count($this->recipients)) {
                return true;
            }

            if (!ModUtil::available('«IF targets('1.3.x')»Mailer«ELSE»ZikulaMailerModule«ENDIF»') || !ModUtil::loadApi('«IF targets('1.3.x')»Mailer«ELSE»ZikulaMailerModule«ENDIF»', 'user')) {
                return LogUtil::registerError($this->__('Could not inform other persons about your amendments, because the Mailer module is not available - please contact an administrator about that!'));
            }

            $result = $this->sendMails();

            «IF targets('1.3.x')»
                SessionUtil::delVar($this->name . 'AdditionalNotificationRemarks');
            «ELSE»
                $this->session->del($this->name . 'AdditionalNotificationRemarks');
            «ENDIF»

            return $result;
        }

        /**
         * Collects the recipients.
         */
        protected function collectRecipients()
        {
            $this->recipients = «IF targets('1.3.x')»array()«ELSE»[]«ENDIF»;

            if ($this->recipientType == 'moderator' || $this->recipientType == 'superModerator') {
                $objectType = $this->entity['_objectType'];
                «IF targets('1.3.x')»
                    $moderatorGroupId = $this->getVar('moderationGroupFor' . $objectType, 2);
                    if ($this->recipientType == 'superModerator') {
                        $moderatorGroupId = $this->getVar('superModerationGroupFor' . $objectType, 2);
                    }
                «ELSE»
                    $moderatorGroupId = $this->variableApi->get('«appName»', 'moderationGroupFor' . $objectType, 2);
                    if ($this->recipientType == 'superModerator') {
                        $moderatorGroupId = $this->variableApi->get('«appName»', 'superModerationGroupFor' . $objectType, 2);
                    }
                «ENDIF»

                $moderatorGroup = ModUtil::apiFunc('«IF targets('1.3.x')»Groups«ELSE»ZikulaGroupsModule«ENDIF»', 'user', 'get', «IF targets('1.3.x')»array(«ELSE»[«ENDIF»'gid' => $moderatorGroupId«IF targets('1.3.x')»)«ELSE»]«ENDIF»);
                foreach (array_keys($moderatorGroup['members']) as $uid) {
                    $this->addRecipient($uid);
                }
            } elseif ($this->recipientType == 'creator' && isset($this->entity['createdUserId'])) {
                $creatorUid = $this->entity['createdUserId'];

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

            $recipient = «IF targets('1.3.x')»array(«ELSE»[«ENDIF»
                'name' => (isset($userVars['name']) && !empty($userVars['name']) ? $userVars['name'] : $userVars['uname']),
                'email' => $userVars['email']
            «IF targets('1.3.x')»)«ELSE»]«ENDIF»;
            $this->recipients[] = $recipient;

            return $recipient;
        }

        /**
         * Performs the actual mailing.
         */
        protected function sendMails()
        {
            $objectType = $this->entity['_objectType'];
            «IF targets('1.3.x')»
                $siteName = System::getVar('sitename');
            «ELSE»
                $siteName = $this->variableApi->get(VariableApi::CONFIG, 'sitename_' . ZLanguage::getLanguageCode(), $this->variableApi->get(VariableApi::CONFIG, 'sitename_en'));
                $adminMail = $this->variableApi->get(VariableApi::CONFIG, 'adminmail');
            «ENDIF»

            «IF targets('1.3.x')»
                $view = Zikula_View::getInstance('«appName»');
            «ENDIF»
            $templateType = $this->recipientType == 'creator' ? 'Creator' : 'Moderator';
            $template = '«IF targets('1.3.x')»email«ELSE»Email«ENDIF»/notify' . ucfirst($objectType) . $templateType .  '.«IF targets('1.3.x')»tpl«ELSE»html.twig«ENDIF»';

            $mailData = $this->prepareEmailData();
            $subject = $this->getMailSubject();

            // send one mail per recipient
            $totalResult = true;
            foreach ($this->recipients as $recipient) {
                if (!isset($recipient['username']) || !$recipient['username']) {
                    continue;
                }
                if (!isset($recipient['email']) || !$recipient['email']) {
                    continue;
                }

                «IF targets('1.3.x')»
                    $view->assign('recipient', $recipient)
                         ->assign('mailData', $mailData);
                «ELSE»
                    $templateParameters = [
                        'recipient' => $recipient,
                        'mailData' => $mailData
                    ];
                «ENDIF»

                «IF targets('1.3.x')»
                    $mailArgs = array(
                        'fromname' => $siteName,
                        'toname' => $recipient['name'],
                        'toaddress' => $recipient['email'],
                        'subject' => $this->getMailSubject(),
                        'body' => $view->fetch($template),
                        'html' => true
                    );

                    $totalResult &= ModUtil::apiFunc('Mailer', 'user', 'sendmessage', $mailArgs);
                «ELSE»
                    $body = $this->templating->render('@«appName»/' . $template, $templateParameters);
                    $altBody = '';
                    $html = true;

                    // create new message instance
                    /** @var Swift_Message */
                    $message = Swift_Message::newInstance();

                    $message->setFrom([$adminMail => $siteName]);
                    $message->setTo([$recipient['email'] => $recipient['name']]);

                    $totalResult &= $this->mailerApi->sendMessage($message, $subject, $msgBody, $altBody, $html);
                «ENDIF»
            }

            return $totalResult;
        }

        protected function getMailSubject()
        {
            $mailSubject = '';
            if ($this->recipientType == 'moderator' || $this->recipientType == 'superModerator') {
                if ($this->action == 'submit') {
                    $mailSubject = $this->__('New content has been submitted');
                } else {
                    $mailSubject = $this->__('Content has been updated');
                }
            } elseif ($this->recipientType == 'creator') {
                $mailSubject = $this->__('Your submission has been updated');
            }

            return $mailSubject;
        }

        protected function prepareEmailData()
        {
            «IF targets('1.3.x')»
                $serviceManager = ServiceUtil::getManager();
                $workflowHelper = new «appName»_Util_Workflow($serviceManager);

            «ENDIF»
            $objectType = $this->entity['_objectType'];
            $state = $this->entity['workflowState'];
            $stateInfo = $«IF !targets('1.3.x')»this->«ENDIF»workflowHelper->getStateInfo($state);

            «IF targets('1.3.x')»
                $remarks = SessionUtil::getVar($this->name . 'AdditionalNotificationRemarks', '');
            «ELSE»
                $remarks = $this->session->get($this->name . 'AdditionalNotificationRemarks', '');
            «ENDIF»

            $urlArgs = $this->entity->createUrlArgs();
            $displayUrl = '';
            $editUrl = '';

            if ($this->recipientType == 'moderator' || $this->recipientType == 'superModerator') {
                «IF !targets('1.3.x') && (hasAdminController && getAllAdminControllers.head.hasActions('display')
                    || hasUserController && getMainUserController.hasActions('display')
                    || hasAdminController && getAllAdminControllers.head.hasActions('edit')
                    || hasUserController && getMainUserController.hasActions('edit'))»
                    $routeArea = '«IF hasAdminController && getAllAdminControllers.head.hasActions('display')»admin«ENDIF»';
                «ENDIF»
                «IF hasAdminController && getAllAdminControllers.head.hasActions('display')
                    || hasUserController && getMainUserController.hasActions('display')»
                    «IF targets('1.3.x')»
                        $displayUrl = ModUtil::url($this->name, '«IF hasAdminController && getAllAdminControllers.head.hasActions('display')»admin«ELSE»user«ENDIF»', 'display', $urlArgs, null, null, true); // absolute
                    «ELSE»
                        $displayUrl = $this->router->generate('«appName.formatForDB»_' . strtolower($objectType) . '_' . $routeArea . 'display', $urlArgs, true);
                    «ENDIF»
                «ENDIF»
                «IF hasAdminController && getAllAdminControllers.head.hasActions('edit')
                    || hasUserController && getMainUserController.hasActions('edit')»
                    «IF targets('1.3.x')»
                        $editUrl = ModUtil::url($this->name, '«IF hasAdminController && getAllAdminControllers.head.hasActions('display')»admin«ELSE»user«ENDIF»', 'edit', $urlArgs, null, null, true); // absolute
                    «ELSE»
                        $editUrl = $this->router->generate('«appName.formatForDB»_' . strtolower($objectType) . '_' . $routeArea . 'edit', $urlArgs, true);
                    «ENDIF»
                «ENDIF»
            } elseif ($this->recipientType == 'creator') {
                «IF hasUserController»
                    «IF getMainUserController.hasActions('display')»
                        «IF targets('1.3.x')»
                            $displayUrl = ModUtil::url($this->name, 'user', 'display', $urlArgs, null, null, true); // absolute
                        «ELSE»
                            $displayUrl = $this->router->generate('«appName.formatForDB»_' . strtolower($objectType) . '_display', $urlArgs, true);
                        «ENDIF»
                    «ENDIF»
                    «IF getMainUserController.hasActions('edit')»
                        «IF targets('1.3.x')»
                            $editUrl = ModUtil::url($this->name, 'user', 'edit', $urlArgs, null, null, true); // absolute
                        «ELSE»
                            $editUrl = $this->router->generate('«appName.formatForDB»_' . strtolower($objectType) . '_edit', $urlArgs, true);
                        «ENDIF»
                    «ENDIF»
                «ELSE»
                    // nothing to do as no user controller is available
                «ENDIF»
            }

            $emailData = «IF targets('1.3.x')»array(«ELSE»[«ENDIF»
                'name' => $this->entity->getTitleFromDisplayPattern(),
                'newState' => $stateInfo['text'],
                'remarks' => $remarks,
                'displayUrl' => $displayUrl,
                'editUrl' => $editUrl
            «IF targets('1.3.x')»)«ELSE»]«ENDIF»;

            return $emailData;
        }
    '''

    def private notificationApiImpl(Application it) '''
        /**
         * Notification api implementation class.
         */
        class «appName»_Api_Notification extends «appName»_Api_Base_Notification
        {
            // feel free to extend the notification api here
        }
    '''

    def private notificationHelperImpl(Application it) '''
        namespace «appNamespace»\Helper;

        use «appNamespace»\Helper\Base\NotificationHelper as BaseNotificationHelper;

        /**
         * Notification helper implementation class.
         */
        class NotificationHelper extends BaseNotificationHelper
        {
            // feel free to extend the notification helper here
        }
    '''
}
