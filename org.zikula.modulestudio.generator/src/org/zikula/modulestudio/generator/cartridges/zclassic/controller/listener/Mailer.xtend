package org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.extensions.Utils

class Mailer {
    extension Utils = new Utils

    CommonExample commonExample = new CommonExample()

    def generate(Application it, Boolean isBase) '''
        «IF !targets('1.3.x')»
            /**
             * Makes our handlers known to the event system.
             */
            public static function getSubscribedEvents()
            {
                «IF isBase»
                    return [
                        'module.mailer.api.sendmessage' => ['sendMessage', 5]
                    ];
                «ELSE»
                    return parent::getSubscribedEvents();
                «ENDIF»
            }

        «ENDIF»
        /**
         * Listener for the `module.mailer.api.sendmessage` event.
         *
         * Invoked from `Mailer_Api_User#sendmessage`.
         * Subject is `Mailer_Api_User` with `$args`.
         * This is a notifyUntil event so the event must `$event->stop«IF !targets('1.3.x')»Propagation«ENDIF»()` and set any
         * return data into `$event->data`, or `$event->setData()`.
         *
         * @param «IF targets('1.3.x')»Zikula_Event«ELSE»GenericEvent«ENDIF» $event The event instance.
         */
        public «IF targets('1.3.x')»static «ENDIF»function sendMessage(«IF targets('1.3.x')»Zikula_Event«ELSE»GenericEvent«ENDIF» $event)
        {
            «IF !isBase»
                parent::sendMessage($event);

                «commonExample.generalEventProperties(it)»
            «ENDIF»
        }
    '''
}
