package org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener

import de.guite.modulestudio.metamodel.Application

class IpTrace {

    CommonExample commonExample = new CommonExample()

    def generate(Application it) '''
        /**
         * @var Request
         */
        protected $request;

        /**
         * @var IpTraceableListener
         */
        protected $ipTraceableListener;

        /**
         * IpTraceListener constructor.
         *
         * @param IpTraceableListener $ipTraceableListener
         * @param RequestStack        $requestStack
         */
        public function __construct(IpTraceableListener $ipTraceableListener, RequestStack $requestStack = null)
        {
            $this->ipTraceableListener = $ipTraceableListener;
            $this->request = null !== $requestStack ? $requestStack->getCurrentRequest() : null;
        }

        /**
         * Makes our handlers known to the event system.
         */
        public static function getSubscribedEvents()
        {
            return [
                KernelEvents::REQUEST => 'onKernelRequest'
            ];
        }

        /**
         * Set the username from the security context by listening on core.request
         *
         * If you use a cache like Varnish, you may want to set a proxy to Request::getClientIp() method.
         *     $this->request->setTrustedProxies(array('127.0.0.1'));
         *
         «commonExample.generalEventProperties(it, true)»
         * @param GetResponseEvent $event The event instance
         */
        public function onKernelRequest(GetResponseEvent $event)
        {
            if (null === $this->request) {
                return;
            }

            $ip = $this->request->getClientIp();
            if (null !== $ip) {
                $this->ipTraceableListener->setIpValue($ip);
            }
        }
    '''
}
