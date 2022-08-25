package org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ThemeListener {

    extension FormattingExtensions = new FormattingExtensions
    extension Utils = new Utils

    def generate(Application it) '''
        public function __construct(
            protected readonly AssetFilter $assetFilter
        ) {
        }

        public static function getSubscribedEvents(): array
        {
            return [
                TwigPreRenderEvent::class => ['preRender', 5],
                TwigPostRenderEvent::class => ['postRender', 5],
                KernelEvents::RESPONSE => ['injectDefaultAssetsIntoRawPage', 1020], // after DefaultPageAssetSetterListener
            ];
        }

        /**
         * Listener for the `TwigPreRenderEvent`.
         *
         * Occurs immediately before twig theme engine renders a template.
         */
        public function preRender(TwigPreRenderEvent $event): void
        {
        }

        /**
         * Listener for the `TwigPostRenderEvent`.
         *
         * Occurs immediately after twig theme engine renders a template.
         */
        public function postRender(TwigPostRenderEvent $event): void
        {
        }

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
    '''
}
