package org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener

import de.guite.modulestudio.metamodel.Application

class Core {

    CommonExample commonExample = new CommonExample()

    def generate(Application it, Boolean isBase) '''
        «IF isBase»
            /**
             * Makes our handlers known to the event system.
             */
        «ELSE»
            /**
             * {@inheritdoc}
             */
        «ENDIF»
        public static function getSubscribedEvents()
        {
            «IF isBase»
                return [
                    'api.method_not_found'        => ['apiMethodNotFound', 5],
                    'core.preinit'                => ['preInit', 5],
                    'core.init'                   => ['init', 5],
                    'core.postinit'               => ['postInit', 5],
                    'controller.method_not_found' => ['controllerMethodNotFound', 5]
                ];
            «ELSE»
                return parent::getSubscribedEvents();
            «ENDIF»
        }

        «IF isBase»
        /**
         * Listener for the `api.method_not_found` event.
         *
         * Called in instances of Zikula_Api from __call().
         * Receives arguments from __call($method, argument) as $args.
         *     $event['method'] is the method which didn't exist in the main class.
         *     $event['args'] is the arguments that were passed.
         * The event subject is the class where the method was not found.
         * Must exit if $event['method'] does not match whatever the handler expects.
         * Modify $event->data and $event->stopPropagation().
         *
         * @param GenericEvent $event The event instance
         */
        «ELSE»
            /**
             * {@inheritdoc}
             */
        «ENDIF»
        public function apiMethodNotFound(GenericEvent $event)
        {
            «IF !isBase»
                parent::apiMethodNotFound($event);

                «commonExample.generalEventProperties(it)»
            «ENDIF»
        }

        «IF isBase»
        /**
         * Listener for the `core.preinit` event.
         *
         * Occurs after the config.php is loaded.
         *
         * @param GenericEvent $event The event instance
         */
        «ELSE»
            /**
             * {@inheritdoc}
             */
        «ENDIF»
        public function preInit(GenericEvent $event)
        {
            «IF !isBase»
                parent::preInit($event);

                «commonExample.generalEventProperties(it)»
            «ENDIF»
        }

        «IF isBase»
        /**
         * Listener for the `core.init` event.
         *
         * Occurs after each `System::init()` stage, `$event['stage']` contains the stage.
         * To check if the handler should execute, do `if($event['stage'] & System::CORE_STAGES_*)`.
         *
         * @param GenericEvent $event The event instance
         */
        «ELSE»
            /**
             * {@inheritdoc}
             */
        «ENDIF»
        public function init(GenericEvent $event)
        {
            «IF !isBase»
                parent::init($event);

                «commonExample.generalEventProperties(it)»
            «ENDIF»
        }

        «IF isBase»
        /**
         * Listener for the `core.postinit` event.
         *
         * Occurs just before System::init() exits from normal execution.
         *
         * @param GenericEvent $event The event instance
         */
        «ELSE»
            /**
             * {@inheritdoc}
             */
        «ENDIF»
        public function postInit(GenericEvent $event)
        {
            «IF !isBase»
                parent::postInit($event);

                «commonExample.generalEventProperties(it)»
            «ENDIF»
        }

        «IF isBase»
        /**
         * Listener for the `controller.method_not_found` event.
         *
         * Called in instances of `Zikula_Controller` from `__call()`.
         * Receives arguments from `__call($method, argument)` as `$args`.
         *    `$event['method']` is the method which didn't exist in the main class.
         *    `$event['args']` is the arguments that were passed.
         * The event subject is the class where the method was not found.
         * Must exit if `$event['method']` does not match whatever the handler expects.
         * Modify `$event->data` and `$event->stopPropagation()`.
         *
         * @param GenericEvent $event The event instance
         */
        «ELSE»
            /**
             * {@inheritdoc}
             */
        «ENDIF»
        public function controllerMethodNotFound(GenericEvent $event)
        {
            «IF !isBase»
                parent::controllerMethodNotFound($event);

                «commonExample.generalEventProperties(it)»
            «ENDIF»
        }
    '''
}
