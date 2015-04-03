package org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.extensions.Utils

class Users {
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
                    return array(
                        'module.users.config.updated' => array('configUpdated', 5)
                    );
                «ELSE»
                    return parent::getSubscribedEvents();
                «ENDIF»
            }

        «ENDIF»
        /**
         * Listener for the `module.users.config.updated` event.
         *
         * Occurs after the Users module configuration has been
         * updated via the administration interface.
         *
         * @param «IF targets('1.3.x')»Zikula_Event«ELSE»GenericEvent«ENDIF» $event The event instance.
         */
        public «IF targets('1.3.x')»static «ENDIF»function configUpdated(«IF targets('1.3.x')»Zikula_Event«ELSE»GenericEvent«ENDIF» $event)
        {
            «IF !isBase»
                parent::configUpdated($event);

                «commonExample.generalEventProperties(it)»
            «ENDIF»
        }
    '''
}
