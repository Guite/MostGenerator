package org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.extensions.Utils

class ThemeListener {

    extension Utils = new Utils

    def generate(Application it) '''
        public static function getSubscribedEvents()
        {
            return [
                «IF targets('3.0')»
                    TwigPreRenderEvent::class  => ['preRender', 5],
                    TwigPostRenderEvent::class => ['postRender', 5]
                «ELSE»
                    ThemeEvents::PRE_RENDER  => ['preRender', 5],
                    ThemeEvents::POST_RENDER => ['postRender', 5]
                «ENDIF»
            ];
        }

        /**
         * Listener for the «IF targets('3.0')»`TwigPreRenderEvent`«ELSE»`theme.pre_render` event«ENDIF».
         *
         * Occurs immediately before twig theme engine renders a template.
         */
        public function preRender(TwigPreRenderEvent $event)«IF targets('3.0')»: void«ENDIF»
        {
        }

        /**
         * Listener for the «IF targets('3.0')»`TwigPostRenderEvent`«ELSE»`theme.post_render` event«ENDIF».
         *
         * Occurs immediately after twig theme engine renders a template.
         */
        public function postRender(TwigPostRenderEvent $event)«IF targets('3.0')»: void«ENDIF»
        {
        }
    '''
}
