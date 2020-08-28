package org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ThemeListener {

    extension FormattingExtensions = new FormattingExtensions
    extension Utils = new Utils

    def generate(Application it) '''
        «IF targets('3.0')»
            /**
             * @var AssetFilter
             */
            protected $assetFilter;

            public function __construct(
                AssetFilter $assetFilter
            ) {
                $this->assetFilter = $assetFilter;
            }

        «ENDIF»
        public static function getSubscribedEvents()
        {
            return [
                «IF targets('3.0')»
                    TwigPreRenderEvent::class  => ['preRender', 5],
                    TwigPostRenderEvent::class => ['postRender', 5],
                    KernelEvents::RESPONSE => ['injectDefaultAssetsIntoRawPage', 1020], // after DefaultPageAssetSetterListener
                «ELSE»
                    ThemeEvents::PRE_RENDER  => ['preRender', 5],
                    ThemeEvents::POST_RENDER => ['postRender', 5],
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
        «IF targets('3.0')»

            /**
             * Adds assets to a raw page which is not processed by the Theme engine.
             */
            public function injectDefaultAssetsIntoRawPage(ResponseEvent $event): void
            {
                $request = $event->getRequest();

                $raw = null !== $request ? $request->query->getBoolean('raw') : false;
                if (true !== $raw) {
                    return;
                }

                $routeName = $request->get('_route', '');
                if (false === mb_strpos($routeName, '«appName.formatForDB»')) {
                    return;
                }

                $response = $event->getResponse();
                $output = $response->getContent();
                $output = $this->assetFilter->filter($output);
                $response->setContent($output);
                $event->setResponse($response);
            }
        «ENDIF»
    '''
}
