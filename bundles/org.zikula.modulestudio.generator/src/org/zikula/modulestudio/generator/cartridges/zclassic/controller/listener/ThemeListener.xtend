package org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.extensions.Utils

class ThemeListener {

    extension Utils = new Utils

    CommonExample commonExample = new CommonExample()

    def generate(Application it) '''
        public static function getSubscribedEvents()
        {
            return [
                ThemeEvents::PRE_RENDER  => ['preRender', 5],
                ThemeEvents::POST_RENDER => ['postRender', 5]
            ];
        }

        /**
         * Listener for the `theme.pre_render` event.
         *
         * Occurs immediately before twig theme engine renders a template.
         *
         «commonExample.generalEventProperties(it, false)»
         */
        public function preRender(TwigPreRenderEvent $event)«IF targets('3.0')»: void«ENDIF»
        {
        }

        /**
         * Listener for the `theme.post_render` event.
         *
         * Occurs immediately after twig theme engine renders a template.
         *
         * An example for implementing this event is \Zikula\ThemeModule\EventListener\TemplateNameExposeListener.
         *
         «commonExample.generalEventProperties(it, false)»
         */
        public function postRender(TwigPostRenderEvent $event)«IF targets('3.0')»: void«ENDIF»
        {
        }
    '''
}
