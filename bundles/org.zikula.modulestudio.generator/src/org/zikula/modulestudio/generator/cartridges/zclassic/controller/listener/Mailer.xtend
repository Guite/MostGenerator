package org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener

import de.guite.modulestudio.metamodel.Application

class Mailer {

    CommonExample commonExample = new CommonExample()

    def generate(Application it, Boolean isBase) '''
        «IF isBase»
            /**
             * Makes our handlers known to the event system.
             */
        «ELSE»
            /**
             * @inheritDoc
             */
        «ENDIF»
        public static function getSubscribedEvents()
        {
            «IF isBase»
                return [
                    MailerEvents::SEND_MESSAGE_START   => ['sendMessageStart', 5],
                    MailerEvents::SEND_MESSAGE_PERFORM => ['sendMessagePerform', 5],
                    MailerEvents::SEND_MESSAGE_SUCCESS => ['sendMessageSuccess', 5],
                    MailerEvents::SEND_MESSAGE_FAILURE => ['sendMessageFailure', 5]
                ];
            «ELSE»
                return parent::getSubscribedEvents();
            «ENDIF»
        }

        «IF isBase»
        /**
         * Listener for the `module.mailer.api.sendmessage` event.
         * Occurs when a new message should be sent.
         *
         * Invoked from `Zikula\MailerModule\Api\MailerApi#sendMessage`.
         * Subject is `Zikula\MailerModule\Api\MailerApi` with `SwiftMessage $message` object.
         * This is a notifyUntil event so the event must `$event->stopPropagation()` and set any
         * return data into `$event->data`, or `$event->setData()`.
         *
         * @param GenericEvent $event The event instance
         */
        «ELSE»
            /**
             * @inheritDoc
             */
        «ENDIF»
        public function sendMessageStart(GenericEvent $event)
        {
            «IF !isBase»
                parent::sendMessageStart($event);

                «commonExample.generalEventProperties(it)»
            «ENDIF»
        }

        «IF isBase»
        /**
         * Listener for the `module.mailer.api.perform` event.
         * Occurs right before a message is sent.
         *
         * Invoked from `Zikula\MailerModule\Api\MailerApi#sendMessage`.
         * Subject is `Zikula\MailerModule\Api\MailerApi` with `SwiftMessage $message` object.
         * This is a notifyUntil event so the event must `$event->stopPropagation()` and set any
         * return data into `$event->data`, or `$event->setData()`.
         *
         * @param GenericEvent $event The event instance
         */
        «ELSE»
            /**
             * @inheritDoc
             */
        «ENDIF»
        public function sendMessagePerform(GenericEvent $event)
        {
            «IF !isBase»
                parent::sendMessagePerform($event);

                «commonExample.generalEventProperties(it)»
            «ENDIF»
        }

        «IF isBase»
        /**
         * Listener for the `module.mailer.api.success` event.
         * Occurs after a message has been sent successfully.
         *
         * Invoked from `Zikula\MailerModule\Api\MailerApi#performSending`.
         *
         * @param GenericEvent $event The event instance
         */
        «ELSE»
            /**
             * @inheritDoc
             */
        «ENDIF»
        public function sendMessageSuccess(GenericEvent $event)
        {
            «IF !isBase»
                parent::sendMessageSuccess($event);

                «commonExample.generalEventProperties(it)»
            «ENDIF»
        }

        «IF isBase»
        /**
         * Listener for the `module.mailer.api.failure` event.
         * Occurs when a message could not be sent.
         *
         * Invoked from `Zikula\MailerModule\Api\MailerApi#performSending`.
         *
         * @param GenericEvent $event The event instance
         */
        «ELSE»
            /**
             * @inheritDoc
             */
        «ENDIF»
        public function sendMessageFailure(GenericEvent $event)
        {
            «IF !isBase»
                parent::sendMessageFailure($event);

                «commonExample.generalEventProperties(it)»
            «ENDIF»
        }
    '''
}
