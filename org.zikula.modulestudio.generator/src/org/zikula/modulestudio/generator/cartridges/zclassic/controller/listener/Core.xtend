package org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener

import de.guite.modulestudio.metamodel.modulestudio.Application
import org.zikula.modulestudio.generator.extensions.Utils

class Core {
    extension Utils = new Utils

    CommonExample commonExample = new CommonExample()

    def generate(Application it, Boolean isBase) '''
        «IF !targets('1.3.5')»

            /**
             * Makes our handlers known to the event system.
             */
            public static function getSubscribedEvents()
            {
                «IF isBase»
                    return array(
                        'api.method_not_found'        => array('apiMethodNotFound', 5),
                        'core.preinit'                => array('preInit', 5),
                        'core.init'                   => array('init', 5),
                        'core.postinit'               => array('postInit', 5),
                        'controller.method_not_found' => array('controllerMethodNotFound', 5)
                    );
                «ELSE»
                    return parent::getSubscribedEvents();
                «ENDIF»
            }

        «ENDIF»
        /**
         * Listener for the `api.method_not_found` event.
         *
         * Called in instances of Zikula_Api from __call().
         * Receives arguments from __call($method, argument) as $args.
         *     $event['method'] is the method which didn't exist in the main class.
         *     $event['args'] is the arguments that were passed.
         * The event subject is the class where the method was not found.
         * Must exit if $event['method'] does not match whatever the handler expects.
         * Modify $event->data and $event->stop«IF !targets('1.3.5')»Propagation«ENDIF»().
         *
         * @param «IF targets('1.3.5')»Zikula_Event«ELSE»GenericEvent«ENDIF» $event The event instance.
         */
        public «IF targets('1.3.5')»static «ENDIF»function apiMethodNotFound(«IF targets('1.3.5')»Zikula_Event«ELSE»GenericEvent«ENDIF» $event)
        {
            «IF !isBase»
                parent::apiMethodNotFound($event);

                «commonExample.generalEventProperties(it)»
            «ENDIF»
        }

        /**
         * Listener for the `core.preinit` event.
         *
         * Occurs after the config.php is loaded.
         *
         * @param «IF targets('1.3.5')»Zikula_Event«ELSE»GenericEvent«ENDIF» $event The event instance.
         */
        public «IF targets('1.3.5')»static «ENDIF»function preInit(«IF targets('1.3.5')»Zikula_Event«ELSE»GenericEvent«ENDIF» $event)
        {
            «IF !isBase»
                parent::preInit($event);

                «commonExample.generalEventProperties(it)»
            «ENDIF»
        }

        /**
         * Listener for the `core.init` event.
         *
         * Occurs after each `System::init()` stage, `$event['stage']` contains the stage.
         * To check if the handler should execute, do `if($event['stage'] & System::CORE_STAGES_*)`.
         *
         * @param «IF targets('1.3.5')»Zikula_Event«ELSE»GenericEvent«ENDIF» $event The event instance.
         */
        public «IF targets('1.3.5')»static «ENDIF»function init(«IF targets('1.3.5')»Zikula_Event«ELSE»GenericEvent«ENDIF» $event)
        {
            «IF !isBase»
                parent::init($event);

                «commonExample.generalEventProperties(it)»
            «ENDIF»
        }

        /**
         * Listener for the `core.postinit` event.
         *
         * Occurs just before System::init() exits from normal execution.
         *
         * @param «IF targets('1.3.5')»Zikula_Event«ELSE»GenericEvent«ENDIF» $event The event instance.
         */
        public «IF targets('1.3.5')»static «ENDIF»function postInit(«IF targets('1.3.5')»Zikula_Event«ELSE»GenericEvent«ENDIF» $event)
        {
            «IF !isBase»
                parent::postInit($event);

                «commonExample.generalEventProperties(it)»
            «ENDIF»
        }

        /**
         * Listener for the `controller.method_not_found` event.
         *
         * Called in instances of `Zikula_Controller` from `__call()`.
         * Receives arguments from `__call($method, argument)` as `$args`.
         *    `$event['method']` is the method which didn't exist in the main class.
         *    `$event['args']` is the arguments that were passed.
         * The event subject is the class where the method was not found.
         * Must exit if `$event['method']` does not match whatever the handler expects.
         * Modify `$event->data` and `$event->stop«IF !targets('1.3.5')»Propagation«ENDIF»()`.
         *
         * @param «IF targets('1.3.5')»Zikula_Event«ELSE»GenericEvent«ENDIF» $event The event instance.
         */
        public «IF targets('1.3.5')»static «ENDIF»function controllerMethodNotFound(«IF targets('1.3.5')»Zikula_Event«ELSE»GenericEvent«ENDIF» $event)
        {
            «IF !isBase»
                parent::controllerMethodNotFound($event);

                «commonExample.generalEventProperties(it)»
            «ENDIF»
        }
    '''
}
