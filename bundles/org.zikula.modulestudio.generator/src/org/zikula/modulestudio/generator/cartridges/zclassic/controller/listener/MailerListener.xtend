package org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener

import de.guite.modulestudio.metamodel.Application

class MailerListener {

    def generate(Application it) '''
        public static function getSubscribedEvents()
        {
            return [
                MessageEvent::class => ['onMessageSend', 5],
            ];
        }

        /**
         * Listener for the `MessageEvent`.
         * Allows the transformation of a Message and the Envelope before the email is sent.
         */
        public function onMessageSend(MessageEvent $event): void
        {
        }
    '''
}
