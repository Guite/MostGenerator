package org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener

import de.guite.modulestudio.metamodel.Application

class CommonExample {

    def generalEventProperties(Application it) '''
        * You can access general data available in the event.
        *
        * The event name:
        *     `echo 'Event: ' . $event->getName();`
        *
        * The current request's type: `MASTER_REQUEST` or `SUB_REQUEST`.
        * If a listener should only be active for the master request,
        * be sure to check that at the beginning of your method.
        *     `if ($event->getRequestType() !== HttpKernelInterface::MASTER_REQUEST) {
        *         return;
        *     }`
        *
        * The kernel instance handling the current request:
        *     `$kernel = $event->getKernel();`
        *
        * The currently handled request:
        *     `$request = $event->getRequest();`
    '''
}
