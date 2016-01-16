package org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener

import de.guite.modulestudio.metamodel.Application

// 1.3.x only
class ErrorsLegacy {

    CommonExample commonExample = new CommonExample()

    def generate(Application it, Boolean isBase) '''
        /**
         * Listener for the `setup.errorreporting` event.
         *
         * Invoked during `System::init()`.
         * Used to activate `set_error_handler()`.
         * Event must `stop()`.
         *
         * @param Zikula_Event $event The event instance.
         */
        public static function setupErrorReporting(Zikula_Event $event)
        {
            «IF !isBase»
                parent::setupErrorReporting($event);

                «commonExample.generalEventProperties(it)»
            «ENDIF»
        }

        /**
         * Listener for the `systemerror` event.
         *
         * Invoked on any system error.
         * args gets `array('errorno' => $errno, 'errstr' => $errstr, 'errfile' => $errfile, 'errline' => $errline, 'errcontext' => $errcontext)`.
         *
         * @param Zikula_Event $event The event instance.
         */
        public static function systemError(Zikula_Event $event)
        {
            «IF !isBase»
                parent::systemError($event);

                «commonExample.generalEventProperties(it)»
            «ENDIF»
        }
    '''
}
