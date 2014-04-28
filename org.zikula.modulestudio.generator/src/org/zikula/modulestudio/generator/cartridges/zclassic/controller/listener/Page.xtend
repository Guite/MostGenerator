package org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Application
import org.zikula.modulestudio.generator.extensions.Utils
import org.zikula.modulestudio.generator.extensions.NamingExtensions

class Page {
    @Inject extension NamingExtensions = new NamingExtensions
    @Inject extension Utils = new Utils

    CommonExample commonExample

    def generate(Application it, Boolean isBase) '''
        «IF !targets('1.3.5')»
            /**
             * Makes our handlers known to the event system.
             */
            public static function getSubscribedEvents()
            {
                «IF isBase»
                    return array(
                        'pageutil.addvar_filter' => array('pageutilAddvarFilter', 5),
                        'system.outputfilter'    => array('systemOutputfilter', 5)
                    );
                «ELSE»
                    return parent::getSubscribedEvents();
                «ENDIF»
            }

        «ENDIF»
        /**
         * Listener for the `pageutil.addvar_filter` event.
         *
         * Used to override things like system or module stylesheets or javascript.
         * Subject is the `$varname`, and `$event->data` an array of values to be modified by the filter.
         *
         * This single filter can be used to override all css or js scripts or any other var types
         * sent to `PageUtil::addVar()`.
         *
         * @param «IF targets('1.3.5')»Zikula_Event«ELSE»GenericEvent«ENDIF» $event The event instance.
         */
        public «IF targets('1.3.5')»static «ENDIF»function pageutilAddvarFilter(«IF targets('1.3.5')»Zikula_Event«ELSE»GenericEvent«ENDIF» $event)
        {
            «IF !isBase»
                parent::pageutilAddvarFilter($event);

                // Simply test with something like
                /*
                    if (($key = array_search('system/Users/«IF targets('1.3.5')»javascript/«ELSE»«getAppJsPath»«ENDIF»somescript.js', $event->data)) !== false) {
                        $event->data[$key] = 'config/javascript/myoverride.js';
                    }
                */

                «commonExample.generalEventProperties(it)»
            «ENDIF»
        }

        /**
         * Listener for the `system.outputfilter` event.
         *
         * Filter type event for output filter HTML sanitisation.
         *
         * @param «IF targets('1.3.5')»Zikula_Event«ELSE»GenericEvent«ENDIF» $event The event instance.
         */
        public «IF targets('1.3.5')»static «ENDIF»function systemOutputFilter(«IF targets('1.3.5')»Zikula_Event«ELSE»GenericEvent«ENDIF» $event)
        {
            «IF !isBase»
                parent::systemOutputFilter($event);

                «commonExample.generalEventProperties(it)»
            «ENDIF»
        }
    '''
}
