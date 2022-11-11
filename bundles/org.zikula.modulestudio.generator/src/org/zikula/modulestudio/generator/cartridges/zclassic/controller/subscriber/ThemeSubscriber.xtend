package org.zikula.modulestudio.generator.cartridges.zclassic.controller.subscriber

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ThemeSubscriber {

    extension FormattingExtensions = new FormattingExtensions
    extension Utils = new Utils

    def generate(Application it) '''
        public static function getSubscribedEvents(): array
        {
            return [
                KernelEvents::RESPONSE => ['injectDefaultAssetsIntoRawPage', 1020], // after DefaultPageAssetSetterListener
            ];
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
            // $output = $this->assetFilter->filter($output); TODO
            $response->setContent($output);
            $event->setResponse($response);
        }
    '''
}
