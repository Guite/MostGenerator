package org.zikula.modulestudio.generator.cartridges.symfony.controller.subscriber

import de.guite.modulestudio.metamodel.Application

class IpTraceSubscriber {

    CommonExample commonExample = new CommonExample()

    def generate(Application it) '''
        public function __construct(
            protected IpTraceableListener $ipTraceableListener,
            protected ?RequestStack $requestStack = null
        ) {
        }

        public static function getSubscribedEvents(): array
        {
            return [
                KernelEvents::REQUEST => 'onKernelRequest',
            ];
        }

        /**
         * Set the username from the security context by listening on kernel request event.
         *
         * If you use a cache like Varnish, you may want to set a proxy to Request::getClientIp() method.
         *     $this->request->setTrustedProxies(array('127.0.0.1'));
         *
         «commonExample.generalEventProperties(it, true)»
         */
        public function onKernelRequest(RequestEvent $event): void
        {
            $request = $this->requestStack?->getCurrentRequest();
            if (null === $request) {
                return;
            }

            $ip = $request->getClientIp();
            if (null !== $ip) {
                $this->ipTraceableListener->setIpValue($ip);
            }
        }
    '''
}
