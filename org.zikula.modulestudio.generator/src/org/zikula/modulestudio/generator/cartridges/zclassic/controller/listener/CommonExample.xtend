package org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener

import de.guite.modulestudio.metamodel.Application

class CommonExample {

    def generalEventProperties(Application it) '''
        // you can access general data available in the event

        // the event name
        // echo 'Event: ' . $event->getName();

        // type of current request: MASTER_REQUEST or SUB_REQUEST
        // if a listener should only be active for the master request,
        // be sure to check that at the beginning of your method
        // if ($event->getRequestType() !== HttpKernelInterface::MASTER_REQUEST) {
        //     // don't do anything if it's not the master request
        //     return;
        // }

        // kernel instance handling the current request
        // $kernel = $event->getKernel();

        // the currently handled request
        // $request = $event->getRequest();
    '''
}