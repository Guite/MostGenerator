package org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener

import de.guite.modulestudio.metamodel.Application

class ThemeListener {

    CommonExample commonExample = new CommonExample()

    def generate(Application it) '''
        /**
         * Makes our handlers known to the event system.
         */
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
         * @param TwigPreRenderEvent $event The event instance
         */
        public function preRender(TwigPreRenderEvent $event)
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
         * @param TwigPostRenderEvent $event The event instance
         */
        public function postRender(TwigPostRenderEvent $event)
        {
        }
    '''
}
