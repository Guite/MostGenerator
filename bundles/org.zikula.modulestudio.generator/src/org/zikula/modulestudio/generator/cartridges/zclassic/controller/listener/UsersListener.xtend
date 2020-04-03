package org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.extensions.Utils

class UsersListener {

    extension Utils = new Utils

    CommonExample commonExample = new CommonExample()

    // NOT NEEDED FOR 3.0
    def generate(Application it) '''
        public static function getSubscribedEvents()
        {
            return [
                UserEvents::CONFIG_UPDATED => ['configUpdated', 5]
            ];
        }

        /**
         * Listener for the `module.users.config.updated` event.
         *
         * Occurs after the Users module configuration has been
         * updated via the administration interface.
         *
         * Event data is populated by the new values.
         *
         «commonExample.generalEventProperties(it, false)»
         */
        public function configUpdated(GenericEvent $event)«IF targets('3.0')»: void«ENDIF»
        {
        }
    '''
}
