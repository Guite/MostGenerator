package org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Application
import org.zikula.modulestudio.generator.extensions.Utils

class ModuleDispatch {
    @Inject extension Utils = new Utils

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
                        'module_dispatch.postloadgeneric'  => array('postLoadGeneric', 5),
                        'module_dispatch.preexecute'       => array('preExecute', 5),
                        'module_dispatch.postexecute'      => array('postExecute', 5),
                        'module_dispatch.custom_classname' => array('customClassname', 5),
                        'module_dispatch.service_links'    => array('serviceLinks', 5)
                    );
                «ELSE»
                    return parent::getSubscribedEvents();
                «ENDIF»
            }

        «ENDIF»
        /**
         * Listener for the `module_dispatch.postloadgeneric` event.
         *
         * Called after a module api or controller has been loaded.
         * Receives the args `array('modinfo' => $modinfo, 'type' => $type, 'force' => $force, 'api' => $api)`.
         *
         * @param «IF targets('1.3.5')»Zikula_Event«ELSE»GenericEvent«ENDIF» $event The event instance.
         */
        public «IF targets('1.3.5')»static «ENDIF»function postLoadGeneric(«IF targets('1.3.5')»Zikula_Event«ELSE»GenericEvent«ENDIF» $event)
        {
            «IF !isBase»
                parent::postLoadGeneric($event);

                «commonExample.generalEventProperties(it)»
            «ENDIF»
        }

        /**
         * Listener for the `module_dispatch.preexecute` event.
         *
         * Occurs in `ModUtil::exec()` after function call with the following args:
         *     `array('modname' => $modname,
         *            'modfunc' => $modfunc,
         *            'args' => $args,
         *            'modinfo' => $modinfo,
         *            'type' => $type,
         *            'api' => $api)`
         * .
         *
         * @param «IF targets('1.3.5')»Zikula_Event«ELSE»GenericEvent«ENDIF» $event The event instance.
         */
        public «IF targets('1.3.5')»static «ENDIF»function preExecute(«IF targets('1.3.5')»Zikula_Event«ELSE»GenericEvent«ENDIF» $event)
        {
            «IF !isBase»
                parent::preExecute($event);

                «commonExample.generalEventProperties(it)»
            «ENDIF»
        }

        /**
         * Listener for the `module_dispatch.postexecute` event.
         *
         * Occurs in `ModUtil::exec()` after function call with the following args:
         *     `array('modname' => $modname,
         *            'modfunc' => $modfunc,
         *            'args' => $args,
         *            'modinfo' => $modinfo,
         *            'type' => $type,
         *            'api' => $api)`
         * .
         * Receives the modules output with `$event->getData();`.
         * Can modify this output with `$event->setData($data);`.
         *
         * @param «IF targets('1.3.5')»Zikula_Event«ELSE»GenericEvent«ENDIF» $event The event instance.
         */
        public «IF targets('1.3.5')»static «ENDIF»function postExecute(«IF targets('1.3.5')»Zikula_Event«ELSE»GenericEvent«ENDIF» $event)
        {
            «IF !isBase»
                parent::postExecute($event);

                «commonExample.generalEventProperties(it)»
            «ENDIF»
        }

        /**
         * Listener for the `module_dispatch.custom_classname` event.
         *
         * In order to override the classname calculated in `ModUtil::exec()`.
         * In order to override a pre-existing controller/api method, use this event type to override the class name that is loaded.
         * This allows to override the methods using inheritance.
         * Receives no subject, args of `array('modname' => $modname, 'modinfo' => $modinfo, 'type' => $type, 'api' => $api)`
         * and 'event data' of `$className`. This can be altered by setting `$event->setData()` followed by `$event->stop«IF !targets('1.3.5')»Propagation«ENDIF»()`.
         *
         * @param «IF targets('1.3.5')»Zikula_Event«ELSE»GenericEvent«ENDIF» $event The event instance.
         */
        public «IF targets('1.3.5')»static «ENDIF»function customClassname(«IF targets('1.3.5')»Zikula_Event«ELSE»GenericEvent«ENDIF» $event)
        {
            «IF !isBase»
                parent::customClassName($event);

                «commonExample.generalEventProperties(it)»
            «ENDIF»
        }

        /**
         * Listener for the `module_dispatch.service_links` event.
         *
         * Occurs when building admin menu items.
         * Adds sublinks to a Services menu that is appended to all modules if populated.
         * Triggered by module_dispatch.postexecute in bootstrap.
         *
         * @param «IF targets('1.3.5')»Zikula_Event«ELSE»GenericEvent«ENDIF» $event The event instance.
         */
        public «IF targets('1.3.5')»static «ENDIF»function serviceLinks(«IF targets('1.3.5')»Zikula_Event«ELSE»GenericEvent«ENDIF» $event)
        {
            «IF !isBase»
                parent::customClassName($event);

                // Format data like so:
                // $event->data[] = array('url' => ModUtil::url('«appName»', 'user', '«IF targets('1.3.5')»main«ELSE»index«ENDIF»'), 'text' => __('Link Text'));

                «commonExample.generalEventProperties(it)»
            «ENDIF»
        }
    '''
}
