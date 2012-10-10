package org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener

import de.guite.modulestudio.metamodel.modulestudio.Application

class Page {

    def generate(Application it, Boolean isBase) '''
        /**
         * Listener for the `pageutil.addvar_filter` event.
         *
         * Used to override things like system or module stylesheets or javascript.
         * Subject is the `$varname`, and `$event->data` an array of values to be modified by the filter.
         *
         * This single filter can be used to override all css or js scripts or any other var types
         * sent to `PageUtil::addVar()`.
         *
         * @param Zikula_Event $event The event instance.
         */
        public static function pageutilAddvarFilter(Zikula_Event $event)
        {
            «IF !isBase»
                parent::pageutilAddvarFilter($event);

            «ENDIF»
            // Simply test with something like
            /*
                if (($key = array_search('system/Users/javascript/somescript.js', $event->data)) !== false) {
                    $event->data[$key] = 'config/javascript/myoverride.js';
                }
            */
        }

        /**
         * Listener for the `system.outputfilter` event.
         *
         * Filter type event for output filter HTML sanitisation.
         *
         * @param Zikula_Event $event The event instance.
         */
        public static function systemOutputFilter(Zikula_Event $event)
        {
            «IF !isBase»
                parent::systemOutputFilter($event);
            «ENDIF»
        }
    '''
}
