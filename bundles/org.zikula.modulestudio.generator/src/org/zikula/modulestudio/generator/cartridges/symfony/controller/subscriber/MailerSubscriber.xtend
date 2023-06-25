package org.zikula.modulestudio.generator.cartridges.symfony.controller.subscriber

import de.guite.modulestudio.metamodel.Application

class MailerSubscriber {

    def generate(Application it) '''
        public static function getSubscribedEvents(): array
        {
            return [
                MessageEvent::class => ['onMessage'],
                SentMessageEvent::class => ['onSentMessage'],
                FailedMessageEvent::class => ['onFailedMessage'],
            ];
        }

        «onMessage»

        «onSentMessage»

        «onFailedMessage»
    '''

    def private onMessage(Application it) '''
        /**
         * Allows to change a Mailer message and its envelope before the email is sent.
         */
        public function onMessage(MessageEvent $event): void
        {
            $message = $event->getMessage();
            if (!$message instanceof Email) {
                return;
            }

            // do something with the message (logging, ...)
        
            // and/or add some Messenger stamps
            // $event->addStamp(new SomeMessengerStamp());

            // stop the message from being sent (as well as the event propagation)
            // $event->reject();
        }
    '''

    def private onSentMessage(Application it) '''
        /**
         * Allows to act on sent messages.
         */
        public function onSentMessage(SentMessageEvent $event): void
        {
            $message = $event->getMessage();

            if (!$message instanceof SentMessage) {
                return;
            }

            // do something with the message

            // access the original message
            // $originalMessage = $event->getOriginalMessage();

            // access debugging information (e.g. HTTP calls)
            // $debugInfo = $event->getDebug();
        }
    '''

    def private onFailedMessage(Application it) '''
        /**
         * Allows acting on the the initial message in case of a failure.
         */
        public function onSentMessage(FailedMessageEvent $event): void
        {
            // e.g you can get more information on this error when sending an email
            // $event->getError();

            // do something with the message
        }
    '''
}
