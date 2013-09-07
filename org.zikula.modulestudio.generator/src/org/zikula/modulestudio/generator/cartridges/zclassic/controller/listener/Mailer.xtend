package org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Application
import org.zikula.modulestudio.generator.extensions.Utils

class Mailer {
    @Inject extension Utils = new Utils

    def generate(Application it, Boolean isBase) '''
        /**
         * Listener for the `module.mailer.api.sendmessage` event.
         *
         * Invoked from `Mailer_Api_User#sendmessage`.
         * Subject is `Mailer_Api_User` with `$args`.
         * This is a notifyUntil event so the event must `$event->stop«IF !targets('1.3.5')»Propagation«ENDIF»()` and set any
         * return data into `$event->data`, or `$event->setData()`.
         *
         * @param «IF targets('1.3.5')»Zikula_Event«ELSE»GenericEvent«ENDIF» $event The event instance.
         */
        public static function sendMessage(«IF targets('1.3.5')»Zikula_Event«ELSE»GenericEvent«ENDIF» $event)
        {
            «IF !isBase»
                parent::sendMessage($event);
            «ENDIF»
        }
    '''
}
