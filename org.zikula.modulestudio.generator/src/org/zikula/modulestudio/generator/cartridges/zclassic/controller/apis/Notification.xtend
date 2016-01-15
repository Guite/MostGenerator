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
        generateClassPair(fsa, getAppSourceLibPath + 'Api/Notification' + (if (targets('1.3.x')) '' else 'Api') + '.php',
            fh.phpFileContent(it, notificationApiBaseClass), fh.phpFileContent(it, notificationApiImpl)
        )
    }

    def private notificationApiBaseClass(Application it) '''
        «IF !targets('1.3.x')»
            namespace «appNamespace»\Api\Base;

            use LogUtil;
            use ModUtil;
            use ServiceUtil;
            use System;
            use UserUtil;

            use Zikula_AbstractBase;
            use Zikula\Core\Doctrine\EntityAccess;

        «ENDIF»
        /**
         * Notification api base class.
         */
        class «IF targets('1.3.x')»«appName»_Api_Base_Notification extends Zikula_AbstractApi«ELSE»NotificationApi extends Zikula_AbstractBase«ENDIF»
        {
            «notificationApiBaseImpl»
        }
    '''

    def private notificationApiBaseImpl(Application it) '''

        /**
         * List of notification recipients.
         *
         * @var array $recipients.
         */
        private $recipients = «IF targets('1.3.x')»array()«ELSE»[]«ENDIF»;

        /**
         * Which type of recipient is used ("creator", "moderator" or "superModerator").
         *
         * @var string recipientType.
         */
        private $recipientType = '';

        /**
         * The entity which has been changed before.
         *
         * @var «IF targets('1.3.x')»Zikula_«ENDIF»EntityAccess entity.
         */
        private $entity = '';

        /**
         * Name of workflow action which is being performed.
         *
         * @var string action.
         */
        private $action = '';

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

            $uid = UserUtil::getVar('uid');

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
                $this->get('session')->del($this->name . 'AdditionalNotificationRemarks');
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
                    $varHelper = $this->get('zikula_extensions_module.api.variable');
                    $moderatorGroupId = $varHelper->get('«appName»', 'moderationGroupFor' . $objectType, 2);
                    if ($this->recipientType == 'superModerator') {
                        $moderatorGroupId = $varHelper->get('«appName»', 'superModerationGroupFor' . $objectType, 2);
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
         * @param $userId Id of treated user.
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
            $siteName = System::getVar('sitename');

            «IF targets('1.3.x')»
                $view = Zikula_View::getInstance('«appName»');
            «ENDIF»
            $templateType = $this->recipientType == 'creator' ? 'Creator' : 'Moderator';
            $template = '«IF targets('1.3.x')»email«ELSE»Email«ENDIF»/notify' . ucfirst($objectType) . $templateType .  '.«IF targets('1.3.x')»tpl«ELSE»html.twig«ENDIF»';
            «IF !targets('1.3.x')»
                $templating = $this->get('twig');
            «ENDIF»

            $mailData = $this->prepareEmailData();

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

                $mailArgs = «IF targets('1.3.x')»array(«ELSE»[«ENDIF»
                    'fromname' => $siteName,
                    'toname' => $recipient['name'],
                    'toaddress' => $recipient['email'],
                    'subject' => $this->getMailSubject(),
                    'body' => «IF targets('1.3.x')»$view->fetch($template)«ELSE»$templating->render('@«appName»/' . $template, $templateParameters)«ENDIF»,
                    'html' => true
                «IF targets('1.3.x')»)«ELSE»]«ENDIF»;

                $totalResult &= ModUtil::apiFunc('«IF targets('1.3.x')»Mailer«ELSE»ZikulaMailerModule«ENDIF»', 'user', 'sendmessage', $mailArgs);
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
            «ELSE»
                $workflowHelper = $this->get('«appName.formatForDB».workflow_helper');
            «ENDIF»

            $objectType = $this->entity['_objectType'];
            $state = $this->entity['workflowState'];
            $stateInfo = $workflowHelper->getStateInfo($state);

            «IF targets('1.3.x')»
                $remarks = SessionUtil::getVar($this->name . 'AdditionalNotificationRemarks', '');
            «ELSE»
                $remarks = $this->get('session')->get($this->name . 'AdditionalNotificationRemarks', '');

                $router = $this->get('router');
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
                        $displayUrl = $router->generate('«appName.formatForDB»_' . strtolower($objectType) . '_' . $routeArea . 'display', $urlArgs, true);
                    «ENDIF»
                «ENDIF»
                «IF hasAdminController && getAllAdminControllers.head.hasActions('edit')
                    || hasUserController && getMainUserController.hasActions('edit')»
                    «IF targets('1.3.x')»
                        $editUrl = ModUtil::url($this->name, '«IF hasAdminController && getAllAdminControllers.head.hasActions('display')»admin«ELSE»user«ENDIF»', 'edit', $urlArgs, null, null, true); // absolute
                    «ELSE»
                        $editUrl = $router->generate('«appName.formatForDB»_' . strtolower($objectType) . '_' . $routeArea . 'edit', $urlArgs, true);
                    «ENDIF»
                «ENDIF»
            } elseif ($this->recipientType == 'creator') {
                «IF hasUserController»
                    «IF getMainUserController.hasActions('display')»
                        «IF targets('1.3.x')»
                            $displayUrl = ModUtil::url($this->name, 'user', 'display', $urlArgs, null, null, true); // absolute
                        «ELSE»
                            $displayUrl = $router->generate('«appName.formatForDB»_' . strtolower($objectType) . '_display', $urlArgs, true);
                        «ENDIF»
                    «ENDIF»
                    «IF getMainUserController.hasActions('edit')»
                        «IF targets('1.3.x')»
                            $editUrl = ModUtil::url($this->name, 'user', 'edit', $urlArgs, null, null, true); // absolute
                        «ELSE»
                            $editUrl = $router->generate('«appName.formatForDB»_' . strtolower($objectType) . '_edit', $urlArgs, true);
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
        «IF !targets('1.3.x')»
            namespace «appNamespace»\Api;

            use «appNamespace»\Api\Base\NotificationApi as BaseNotificationApi;

        «ENDIF»
        /**
         * Notification api implementation class.
         */
        «IF targets('1.3.x')»
        class «appName»_Api_Notification extends «appName»_Api_Base_Notification
        «ELSE»
        class NotificationApi extends BaseNotificationApi
        «ENDIF»
        {
            // feel free to extend the notification api here
        }
    '''
}
