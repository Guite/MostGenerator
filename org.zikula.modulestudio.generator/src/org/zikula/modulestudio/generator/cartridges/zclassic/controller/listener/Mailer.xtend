package org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener

import de.guite.modulestudio.metamodel.modulestudio.Application

class Mailer {

    def generate(Application it, Boolean isBase) '''
        /**
         * Listener for the `module.mailer.api.sendmessage` event.
         *
         * Invoked from `Mailer_Api_User#sendmessage`.
         * Subject is `Mailer_Api_User` with `$args`.
         * This is a notifyUntil event so the event must `$event->stop()` and set any
         * return data into `$event->data`, or `$event->setData()`.
         *
         * @param Zikula_Event $event The event instance.
         */
        public static function sendMessage(Zikula_Event $event)
        {
            «IF !isBase»
                parent::sendMessage($event);
            «ENDIF»
        }
    '''
}
