package org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.extensions.Utils

class IpTraceListener {

    extension Utils = new Utils

    CommonExample commonExample = new CommonExample()

    def generate(Application it) '''
        /**
         * @var RequestStack
         */
        protected $requestStack;

        /**
         * @var IpTraceableListener
         */
        protected $ipTraceableListener;

        public function __construct(
            IpTraceableListener $ipTraceableListener,
            RequestStack $requestStack = null
        ) {
            $this->ipTraceableListener = $ipTraceableListener;
            $this->requestStack = $requestStack;
        }

        public static function getSubscribedEvents()
        {
            return [
                KernelEvents::REQUEST => 'onKernelRequest',
            ];
        }

        /**
         * Set the username from the security context by listening on core.request
         *
         * If you use a cache like Varnish, you may want to set a proxy to Request::getClientIp() method.
         *     $this->request->setTrustedProxies(array('127.0.0.1'));
         *
         «commonExample.generalEventProperties(it, true)»
         */
        public function onKernelRequest(GetResponseEvent $event)«IF targets('3.0')»: void«ENDIF»
        {
            $request = null !== $this->requestStack ? $this->requestStack->getCurrentRequest() : null;
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
