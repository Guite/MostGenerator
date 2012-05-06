package org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener

import de.guite.modulestudio.metamodel.modulestudio.Application

class View {

    def generate(Application it) '''
        /**
         * Listener for the `view.init` event.
         *
         * Occurs just before `Zikula_View#__construct()` finishes.
         * The subject is the Zikula_View instance.
         */
        public static function init(Zikula_Event $event)
        {
        }

        /**
         * Listener for the `view.postfetch` event.
         *
         * Filter of result of a fetch. Receives `Zikula_View` instance as subject, args are
         * `array('template' => $template)`, $data was the result of the fetch to be filtered.
         */
        public static function postFetch(Zikula_Event $event)
        {
        }
    '''
}
