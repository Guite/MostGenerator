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
             * {@inheritdoc}
             */
        «ENDIF»
        public static function getSubscribedEvents()
        {
            «IF isBase»
                return [
                    'theme.preinit'          => ['smartyPreInit', 5],
                    'theme.init'             => ['smartyInit', 5],
                    'theme.load_config'      => ['smartyLoadConfig', 5],
                    'theme.prefetch'         => ['smartyPreFetch', 5],
                    'theme.postfetch'        => ['smartyPostFetch', 5],
                    ThemeEvents::PRE_RENDER  => ['twigPreRender', 5],
                    ThemeEvents::POST_RENDER => ['twigPostRender', 5]
                ];
            «ELSE»
                return parent::getSubscribedEvents();
            «ENDIF»
        }

        «IF isBase»
        /**
         * Listener for the `theme.preinit` event.
         *
         * Occurs on the startup of the `Zikula_View_Theme#__construct()`.
         * The subject is the Zikula_View_Theme instance.
         * Is useful to setup a customized theme configuration or cache_id.
         *
         * Note that Zikula_View_Theme is deprecated and being replaced by Twig.
         *
         * @param GenericEvent $event The event instance
         */
        «ELSE»
            /**
             * {@inheritdoc}
             */
        «ENDIF»
        public function smartyPreInit(GenericEvent $event)
        {
            «IF !isBase»
                parent::smartyPreInit($event);

                «commonExample.generalEventProperties(it)»
            «ENDIF»
        }

        «IF isBase»
        /**
         * Listener for the `theme.init` event.
         *
         * Occurs just before `Zikula_View_Theme#__construct()` finishes.
         * The subject is the Zikula_View_Theme instance.
         *
         * Note that Zikula_View_Theme is deprecated and being replaced by Twig.
         *
         * @param GenericEvent $event The event instance
         */
        «ELSE»
            /**
             * {@inheritdoc}
             */
        «ENDIF»
        public function smartyInit(GenericEvent $event)
        {
            «IF !isBase»
                parent::smartyInit($event);

                «commonExample.generalEventProperties(it)»
            «ENDIF»
        }

        «IF isBase»
        /**
         * Listener for the `theme.load_config` event.
         *
         * Runs just before `Theme#load_config()` completed.
         * Subject is the Theme instance.
         *
         * @param GenericEvent $event The event instance
         */
        «ELSE»
            /**
             * {@inheritdoc}
             */
        «ENDIF»
        public function smartyLoadConfig(GenericEvent $event)
        {
            «IF !isBase»
                parent::smartyLoadConfig($event);

                «commonExample.generalEventProperties(it)»
            «ENDIF»
        }

        «IF isBase»
        /**
         * Listener for the `theme.prefetch` event.
         *
         * Occurs in `Theme::themefooter()` just after getting the `$maincontent`.
         * The event subject is `$this` (Theme instance) and has $maincontent as the event data
         * which you can modify with `$event->setData()` in the event handler.
         *
         * @param GenericEvent $event The event instance
         */
        «ELSE»
            /**
             * {@inheritdoc}
             */
        «ENDIF»
        public function smartyPreFetch(GenericEvent $event)
        {
            «IF !isBase»
                parent::smartyPreFetch($event);

                «commonExample.generalEventProperties(it)»
            «ENDIF»
        }

        «IF isBase»
        /**
         * Listener for the `theme.postfetch` event.
         *
         * Occurs in `Theme::themefooter()` just after rendering the theme.
         * The event subject is `$this` (Theme instance) and the event data is the rendered
         * output which you can modify with `$event->setData()` in the event handler.
         *
         * @param GenericEvent $event The event instance
         */
        «ELSE»
            /**
             * {@inheritdoc}
             */
        «ENDIF»
        public function smartyPostFetch(GenericEvent $event)
        {
            «IF !isBase»
                parent::smartyPostFetch($event);

                «commonExample.generalEventProperties(it)»
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
             * {@inheritdoc}
             */
        «ENDIF»
        public function twigPreRender(TwigPreRenderEvent $event)
        {
            «IF !isBase»
                parent::twigPreRender($event);
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
             * {@inheritdoc}
             */
        «ENDIF»
        public function twigPostRender(TwigPostRenderEvent $event)
        {
            «IF !isBase»
                parent::twigPostRender($event);
            «ENDIF»
        }
    '''
}
