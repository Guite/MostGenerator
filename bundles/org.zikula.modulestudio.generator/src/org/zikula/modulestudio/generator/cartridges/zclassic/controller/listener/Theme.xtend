package org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener

import de.guite.modulestudio.metamodel.Application

class Theme {

    CommonExample commonExample = new CommonExample()

    def generate(Application it, Boolean isBase) '''
        «IF isBase»
            /**
             * Makes our handlers known to the event system.
             */
        «ELSE»
            /**
             * @inheritDoc
             */
        «ENDIF»
        public static function getSubscribedEvents()
        {
            «IF isBase»
                return [
                    ThemeEvents::PRE_RENDER  => ['preRender', 5],
                    ThemeEvents::POST_RENDER => ['postRender', 5]
                ];
            «ELSE»
                return parent::getSubscribedEvents();
            «ENDIF»
        }

        «IF isBase»
        /**
         * Listener for the `theme.pre_render` event.
         *
         * Occurs immediately before twig theme engine renders a template.
         * The event subject is \Zikula\ThemeModule\Bridge\Event\TwigPreRenderEvent.
         *
         * @param TwigPreRenderEvent $event The event instance
         */
        «ELSE»
            /**
             * @inheritDoc
             */
        «ENDIF»
        public function preRender(TwigPreRenderEvent $event)
        {
            «IF !isBase»
                parent::preRender($event);

                «commonExample.generalEventProperties(it)»
            «ENDIF»
        }

        «IF isBase»
        /**
         * Listener for the `theme.post_render` event.
         *
         * Occurs immediately after twig theme engine renders a template.
         * The event subject is \Zikula\ThemeModule\Bridge\Event\TwigPostRenderEvent.
         *
         * An example for implementing this event is \Zikula\ThemeModule\EventListener\TemplateNameExposeListener.
         *
         * @param TwigPostRenderEvent $event The event instance
         */
        «ELSE»
            /**
             * @inheritDoc
             */
        «ENDIF»
        public function postRender(TwigPostRenderEvent $event)
        {
            «IF !isBase»
                parent::postRender($event);

                «commonExample.generalEventProperties(it)»
            «ENDIF»
        }
    '''
}
