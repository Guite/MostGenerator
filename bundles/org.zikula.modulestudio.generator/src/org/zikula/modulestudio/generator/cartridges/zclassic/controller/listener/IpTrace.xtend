package org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener

import de.guite.modulestudio.metamodel.Application

class IpTrace {

    def generate(Application it, Boolean isBase) '''
        «IF isBase»
            /**
             * @var Request
             */
            private $request;

            /**
             * @var IpTraceableListener
             */
            private $ipTraceableListener;

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
        «ELSE»
            /**
             * @inheritDoc
             */
        «ENDIF»
        public static function getSubscribedEvents()
        {
            «IF isBase»
                return [
                    KernelEvents::REQUEST => 'onKernelRequest'
                ];
            «ELSE»
                return parent::getSubscribedEvents();
            «ENDIF»
        }

        «IF isBase»
            /**
             * Set the username from the security context by listening on core.request
             *
             * @param GetResponseEvent $event
             */
        «ELSE»
            /**
             * @inheritDoc
             */
        «ENDIF»
        public function onKernelRequest(GetResponseEvent $event)
        {
            «IF isBase»
                if (null === $this->request) {
                    return;
                }

                // If you use a cache like Varnish, you may want to set a proxy to Request::getClientIp() method 
                // $this->request->setTrustedProxies(array('127.0.0.1'));

                // $ip = $_SERVER['REMOTE_ADDR'];
                $ip = $this->request->getClientIp();

                if (null !== $ip) {
                    $this->ipTraceableListener->setIpValue($ip);
                }
            «ELSE»
                parent::onKernelRequest($event);
            «ENDIF»
        }
    '''
}
