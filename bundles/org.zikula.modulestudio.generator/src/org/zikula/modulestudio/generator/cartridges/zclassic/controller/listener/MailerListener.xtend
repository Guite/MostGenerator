package org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener

import de.guite.modulestudio.metamodel.Application

class MailerListener {

    CommonExample commonExample = new CommonExample()

    def generate(Application it) '''
        /**
         * Makes our handlers known to the event system.
         */
        public static function getSubscribedEvents()
        {
            return [
                MailerEvents::SEND_MESSAGE_START   => ['sendMessageStart', 5],
                MailerEvents::SEND_MESSAGE_PERFORM => ['sendMessagePerform', 5],
                MailerEvents::SEND_MESSAGE_SUCCESS => ['sendMessageSuccess', 5],
                MailerEvents::SEND_MESSAGE_FAILURE => ['sendMessageFailure', 5]
            ];
        }

        /**
         * Listener for the `module.mailer.api.sendmessage` event.
         * Occurs when a new message should be sent.
         *
         * Invoked from `Zikula\MailerModule\Api\MailerApi#sendMessage`.
         * Subject is `Zikula\MailerModule\Api\MailerApi` with `SwiftMessage $message` object.
         * This is a notifyUntil event so the event must `$event->stopPropagation()` and set any
         * return data into `$event->data`, or `$event->setData()`.
         *
         «commonExample.generalEventProperties(it, false)»
         * @param GenericEvent $event The event instance
         */
        public function sendMessageStart(GenericEvent $event)
        {
        }

        /**
         * Listener for the `module.mailer.api.perform` event.
         * Occurs right before a message is sent.
         *
         * Invoked from `Zikula\MailerModule\Api\MailerApi#sendMessage`.
         * Subject is `Zikula\MailerModule\Api\MailerApi` with `SwiftMessage $message` object.
         * This is a notifyUntil event so the event must `$event->stopPropagation()` and set any
         * return data into `$event->data`, or `$event->setData()`.
         *
         «commonExample.generalEventProperties(it, false)»
         * @param GenericEvent $event The event instance
         */
        public function sendMessagePerform(GenericEvent $event)
        {
        }

        /**
         * Listener for the `module.mailer.api.success` event.
         * Occurs after a message has been sent successfully.
         *
         * Invoked from `Zikula\MailerModule\Api\MailerApi#performSending`.
         *
         «commonExample.generalEventProperties(it, false)»
         * @param GenericEvent $event The event instance
         */
        public function sendMessageSuccess(GenericEvent $event)
        {
        }

        /**
         * Listener for the `module.mailer.api.failure` event.
         * Occurs when a message could not be sent.
         *
         * Invoked from `Zikula\MailerModule\Api\MailerApi#performSending`.
         *
         «commonExample.generalEventProperties(it, false)»
         * @param GenericEvent $event The event instance
         */
        public function sendMessageFailure(GenericEvent $event)
        {
        }
    '''
}
