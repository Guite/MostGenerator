package org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ModuleDispatch {
    extension FormattingExtensions = new FormattingExtensions
    extension Utils = new Utils

    CommonExample commonExample = new CommonExample()

    def generate(Application it, Boolean isBase) '''
        /**
         * Makes our handlers known to the event system.
         */
        public static function getSubscribedEvents()
        {
            «IF isBase»
                return [
                    'module_dispatch.postloadgeneric'  => ['postLoadGeneric', 5],
                    'module_dispatch.preexecute'       => ['preExecute', 5],
                    'module_dispatch.postexecute'      => ['postExecute', 5],
                    'module_dispatch.custom_classname' => ['customClassname', 5],
                    'module_dispatch.service_links'    => ['serviceLinks', 5]
                ];
            «ELSE»
                return parent::getSubscribedEvents();
            «ENDIF»
        }

        «IF isBase»
        /**
         * Listener for the `module_dispatch.postloadgeneric` event.
         *
         * Called after a module api or controller has been loaded.
         * Receives the args `['modinfo' => $modinfo, 'type' => $type, 'force' => $force, 'api' => $api]`.
         *
         * @param GenericEvent $event The event instance
         */
        «ELSE»
            /**
             * {@inheritdoc}
             */
        «ENDIF»
        public function postLoadGeneric(GenericEvent $event)
        {
            «IF !isBase»
                parent::postLoadGeneric($event);

                «commonExample.generalEventProperties(it)»
            «ENDIF»
        }

        «IF isBase»
        /**
         * Listener for the `module_dispatch.preexecute` event.
         *
         * Occurs in `ModUtil::exec()` before function call with the following args:
         *     `[
         *          'modname' => $modname,
         *          'modfunc' => $modfunc,
         *          'args' => $args,
         *          'modinfo' => $modinfo,
         *          'type' => $type,
         *          'api' => $api
         *      ]`
         * .
         *
         * @param GenericEvent $event The event instance
         */
        «ELSE»
            /**
             * {@inheritdoc}
             */
        «ENDIF»
        public function preExecute(GenericEvent $event)
        {
            «IF !isBase»
                parent::preExecute($event);

                «commonExample.generalEventProperties(it)»
            «ENDIF»
        }

        «IF isBase»
        /**
         * Listener for the `module_dispatch.postexecute` event.
         *
         * Occurs in `ModUtil::exec()` after function call with the following args:
         *     `[
         *          'modname' => $modname,
         *          'modfunc' => $modfunc,
         *          'args' => $args,
         *          'modinfo' => $modinfo,
         *          'type' => $type,
         *          'api' => $api
         *      ]`
         * .
         * Receives the modules output with `$event->getData();`.
         * Can modify this output with `$event->setData($data);`.
         *
         * @param GenericEvent $event The event instance
         */
        «ELSE»
            /**
             * {@inheritdoc}
             */
        «ENDIF»
        public function postExecute(GenericEvent $event)
        {
            «IF !isBase»
                parent::postExecute($event);

                «commonExample.generalEventProperties(it)»
            «ENDIF»
        }

        «IF isBase»
        /**
         * Listener for the `module_dispatch.custom_classname` event.
         *
         * In order to override the classname calculated in `ModUtil::exec()`.
         * In order to override a pre-existing controller/api method, use this event type to override the class name that is loaded.
         * This allows to override the methods using inheritance.
         * Receives no subject, args of `['modname' => $modname, 'modinfo' => $modinfo, 'type' => $type, 'api' => $api]`
         * and 'event data' of `$className`. This can be altered by setting `$event->setData()` followed by `$event->stopPropagation()`.
         *
         * @param GenericEvent $event The event instance
         */
        «ELSE»
            /**
             * {@inheritdoc}
             */
        «ENDIF»
        public function customClassname(GenericEvent $event)
        {
            «IF !isBase»
                parent::customClassName($event);

                «commonExample.generalEventProperties(it)»
            «ENDIF»
        }

        «IF isBase»
        /**
         * Listener for the `module_dispatch.service_links` event.
         *
         * Occurs when building admin menu items.
         * Adds sublinks to a Services menu that is appended to all modules if populated.
         * Triggered by module_dispatch.postexecute in bootstrap.
         *
         * @param GenericEvent $event The event instance
         */
        «ELSE»
            /**
             * {@inheritdoc}
             */
        «ENDIF»
        public function serviceLinks(GenericEvent $event)
        {
            «IF !isBase»
                parent::customClassName($event);

                // Format data like so:
                // $router = \ServiceUtil::get('router');
                // $translator = \ServiceUtil::get('translator.default');
                // $event->data[] = [
                //     'url' => $router->generate('«appName.formatForDB»_user_index'),
                //     'text' => $translator->__('Link text')
                // ];

                «commonExample.generalEventProperties(it)»
            «ENDIF»
        }
    '''
}
