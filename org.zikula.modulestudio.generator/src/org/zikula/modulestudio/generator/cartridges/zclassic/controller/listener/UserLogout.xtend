package org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.extensions.Utils

class UserLogout {
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
                        AccessEvents::LOGOUT_SUCCESS => ['succeeded', 5]
                    ];
                «ELSE»
                    return parent::getSubscribedEvents();
                «ENDIF»
            }

        «ENDIF»
        «IF isBase»
        /**
         * Listener for the `module.users.ui.logout.succeeded` event.
         *
         * Occurs right after a successful logout. All handlers are notified.
         * The event's subject contains the user's UserEntity.
        «IF targets('1.3.x')»
            «' '»* Args contain array of `array('authentication_method' => $authenticationMethod,
            «' '»*                              'uid'                   => $uid);`
        «ELSE»
            «' '»* Args contain array of `['authentication_method' => $authenticationMethod,
            «' '»*                         'uid'                   => $uid];`
        «ENDIF»
         *
         * @param «IF targets('1.3.x')»Zikula_Event«ELSE»GenericEvent«ENDIF» $event The event instance
         */
        «ELSE»
            /**
             * {@inheritdoc}
             */
        «ENDIF»
        public «IF targets('1.3.x')»static «ENDIF»function succeeded(«IF targets('1.3.x')»Zikula_Event«ELSE»GenericEvent«ENDIF» $event)
        {
            «IF !isBase»
                parent::succeeded($event);

                «commonExample.generalEventProperties(it)»
            «ENDIF»
        }
    '''
}
