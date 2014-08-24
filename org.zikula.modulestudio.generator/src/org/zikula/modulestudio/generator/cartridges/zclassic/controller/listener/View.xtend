package org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.extensions.Utils

class View {
    extension Utils = new Utils

    CommonExample commonExample = new CommonExample()

    def generate(Application it, Boolean isBase) '''
        «IF !targets('1.3.5')»
            /**
             * Makes our handlers known to the event system.
             */
            public static function getSubscribedEvents()
            {
                «IF isBase»
                    return array(
                        'view.init'      => array('init', 5),
                        'view.postfetch' => array('postFetch', 5)
                    );
                «ELSE»
                    return parent::getSubscribedEvents();
                «ENDIF»
            }

        «ENDIF»
        /**
         * Listener for the `view.init` event.
         *
         * Occurs just before `Zikula_View#__construct()` finishes.
         * The subject is the Zikula_View instance.
         *
         * @param «IF targets('1.3.5')»Zikula_Event«ELSE»GenericEvent«ENDIF» $event The event instance.
         */
        public «IF targets('1.3.5')»static «ENDIF»function init(«IF targets('1.3.5')»Zikula_Event«ELSE»GenericEvent«ENDIF» $event)
        {
            «IF !isBase»
                parent::init($event);

                «commonExample.generalEventProperties(it)»
            «ENDIF»
        }

        /**
         * Listener for the `view.postfetch` event.
         *
         * Filter of result of a fetch.
         * Receives `Zikula_View` instance as subject,
         * args are `array('template' => $template)`,
         * $data was the result of the fetch to be filtered.
         *
         * @param «IF targets('1.3.5')»Zikula_Event«ELSE»GenericEvent«ENDIF» $event The event instance.
         */
        public «IF targets('1.3.5')»static «ENDIF»function postFetch(«IF targets('1.3.5')»Zikula_Event«ELSE»GenericEvent«ENDIF» $event)
        {
            «IF !isBase»
                parent::postFetch($event);

                «commonExample.generalEventProperties(it)»
            «ENDIF»
        }
    '''
}
