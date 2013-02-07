package org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Application
import org.zikula.modulestudio.generator.extensions.Utils

class Errors {
    @Inject extension Utils = new Utils()

    def generate(Application it, Boolean isBase) '''
        /**
         * Listener for the `setup.errorreporting` event.
         *
         * Invoked during `System::init()`.
         * Used to activate `set_error_handler()`.
         * Event must `stop«IF !targets('1.3.5')»Propagation«ENDIF»()`.
         *
         * @param «IF targets('1.3.5')»Zikula_Event«ELSE»GenericEvent«ENDIF» $event The event instance.
         */
        public static function setupErrorReporting(«IF targets('1.3.5')»Zikula_Event«ELSE»GenericEvent«ENDIF» $event)
        {
            «IF !isBase»
                parent::setupErrorReporting($event);
            «ENDIF»
        }

        /**
         * Listener for the `systemerror` event.
         *
         * Invoked on any system error.
         * args gets `array('errorno' => $errno, 'errstr' => $errstr, 'errfile' => $errfile, 'errline' => $errline, 'errcontext' => $errcontext)`.
         *
         * @param «IF targets('1.3.5')»Zikula_Event«ELSE»GenericEvent«ENDIF» $event The event instance.
         */
        public static function systemError(«IF targets('1.3.5')»Zikula_Event«ELSE»GenericEvent«ENDIF» $event)
        {
            «IF !isBase»
                parent::systemError($event);
            «ENDIF»
        }
    '''
}
