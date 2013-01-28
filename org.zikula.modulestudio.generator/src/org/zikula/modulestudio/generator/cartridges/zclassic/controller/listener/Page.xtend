package org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Application
import org.zikula.modulestudio.generator.extensions.Utils
import org.zikula.modulestudio.generator.extensions.NamingExtensions

class Page {
    @Inject extension NamingExtensions = new NamingExtensions()
    @Inject extension Utils = new Utils()

    def generate(Application it, Boolean isBase) '''
        /**
         * Listener for the `pageutil.addvar_filter` event.
         *
         * Used to override things like system or module stylesheets or javascript.
         * Subject is the `$varname`, and `$event->data` an array of values to be modified by the filter.
         *
         * This single filter can be used to override all css or js scripts or any other var types
         * sent to `\PageUtil::addVar()`.
         *
         * @param «IF targets('1.3.5')»Zikula_Event«ELSE»\Zikula\Core\Event\GenericEvent«ENDIF» $event The event instance.
         */
        public static function pageutilAddvarFilter(«IF targets('1.3.5')»Zikula_Event«ELSE»\Zikula\Core\Event\GenericEvent«ENDIF» $event)
        {
            «IF !isBase»
                parent::pageutilAddvarFilter($event);

            «ENDIF»
            // Simply test with something like
            /*
                if (($key = array_search('system/Users/«IF targets('1.3.5')»javascript«ELSE»«getAppJsPath»«ENDIF»/somescript.js', $event->data)) !== false) {
                    $event->data[$key] = 'config/javascript/myoverride.js';
                }
            */
        }

        /**
         * Listener for the `system.outputfilter` event.
         *
         * Filter type event for output filter HTML sanitisation.
         *
         * @param «IF targets('1.3.5')»Zikula_Event«ELSE»\Zikula\Core\Event\GenericEvent«ENDIF» $event The event instance.
         */
        public static function systemOutputFilter(«IF targets('1.3.5')»Zikula_Event«ELSE»\Zikula\Core\Event\GenericEvent«ENDIF» $event)
        {
            «IF !isBase»
                parent::systemOutputFilter($event);
            «ENDIF»
        }
    '''
}
