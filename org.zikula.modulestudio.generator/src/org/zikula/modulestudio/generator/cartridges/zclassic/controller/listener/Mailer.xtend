package org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.extensions.Utils

class Mailer {
    extension Utils = new Utils

    CommonExample commonExample = new CommonExample()

    def generate(Application it, Boolean isBase) '''
        «IF !targets('1.3.x')»
            «IF isBase»
                /**
                 * Makes our handlers known to the event system.
                 */
            «ELSE»
                /**
                 * {@inheritdoc}
                 */
            «ENDIF»
            public static function getSubscribedEvents()
            {
                «IF isBase»
                    return [
                        MailerEvents::SEND_MESSAGE_START => ['sendMessageStart', 5],
                        MailerEvents::SEND_MESSAGE_PERFORM => ['sendMessagePerform', 5],
                        MailerEvents::SEND_MESSAGE_SUCCESS => ['sendMessageSuccess', 5],
                        MailerEvents::SEND_MESSAGE_FAILURE => ['sendMessageFailure', 5]
                    ];
                «ELSE»
                    return parent::getSubscribedEvents();
                «ENDIF»
            }

        «ENDIF»
        «IF isBase»
        /**
         * Listener for the `module.mailer.api.sendmessage` event.
         * Occurs when a new message should be sent.
         *
        «IF targets('1.3.x')»
            «' '»* Invoked from `Mailer_Api_User#sendmessage`.
            «' '»* Subject is `Mailer_Api_User` with `$args`.
        «ELSE»
            «' '»* Invoked from `Zikula\MailerModule\Api\MailerApi#sendMessage`.
            «' '»* Subject is `Zikula\MailerModule\Api\MailerApi` with `SwiftMessage $message` object.
        «ENDIF»
         * This is a notifyUntil event so the event must `$event->stop«IF !targets('1.3.x')»Propagation«ENDIF»()` and set any
         * return data into `$event->data`, or `$event->setData()`.
         *
         * @param «IF targets('1.3.x')»Zikula_Event«ELSE»GenericEvent«ENDIF» $event The event instance
         */
        «ELSE»
            /**
             * {@inheritdoc}
             */
        «ENDIF»
        public «IF targets('1.3.x')»static «ENDIF»function sendMessage«IF !targets('1.3.x')»Start«ENDIF»(«IF targets('1.3.x')»Zikula_Event«ELSE»GenericEvent«ENDIF» $event)
        {
            «IF !isBase»
                parent::sendMessage«IF !targets('1.3.x')»Start«ENDIF»($event);

                «commonExample.generalEventProperties(it)»
            «ENDIF»
        }
        «IF !targets('1.3.x')»

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
                 * {@inheritdoc}
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
                 * {@inheritdoc}
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
                 * {@inheritdoc}
                 */
            «ENDIF»
            public function sendMessageFailure(GenericEvent $event)
            {
                «IF !isBase»
                    parent::sendMessageFailure($event);

                    «commonExample.generalEventProperties(it)»
                «ENDIF»
            }
        «ENDIF»
    '''
}
