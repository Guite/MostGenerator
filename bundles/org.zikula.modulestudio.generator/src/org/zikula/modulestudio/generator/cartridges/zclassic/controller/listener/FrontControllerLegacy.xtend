package org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener

import de.guite.modulestudio.metamodel.Application

class FrontControllerLegacy {

    CommonExample commonExample = new CommonExample()

    // obsolete, used for 1.3.x only
    def generate(Application it, Boolean isBase) '''
        «IF isBase»
        /**
         * Listener for the `frontcontroller.predispatch` event.
         *
         * Runs before the front controller does any work.
         *
         * @param Zikula_Event $event The event instance
         */
        «ELSE»
            /**
             * {@inheritdoc}
             */
        «ENDIF»
        public static function preDispatch(Zikula_Event $event)
        {
            «IF !isBase»
                parent::preDispatch($event);

                «commonExample.generalEventProperties(it)»
            «ENDIF»
        }
    '''
}