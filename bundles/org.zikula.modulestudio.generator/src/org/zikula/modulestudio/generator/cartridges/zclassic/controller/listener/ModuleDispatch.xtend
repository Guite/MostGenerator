package org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ModuleDispatch {
    extension FormattingExtensions = new FormattingExtensions
    extension Utils = new Utils

    CommonExample commonExample = new CommonExample()

    def generate(Application it, Boolean isBase) '''
        «IF !targets('1.3.x')»
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

        «ENDIF»
        «IF isBase»
        /**
         * Listener for the `module_dispatch.postloadgeneric` event.
         *
         * Called after a module api or controller has been loaded.
         * Receives the args `«IF targets('1.3.x')»array(«ELSE»[«ENDIF»'modinfo' => $modinfo, 'type' => $type, 'force' => $force, 'api' => $api«IF targets('1.3.x')»)«ELSE»]«ENDIF»`.
         *
         * @param «IF targets('1.3.x')»Zikula_Event«ELSE»GenericEvent«ENDIF» $event The event instance
         */
        «ELSE»
            /**
             * {@inheritdoc}
             */
        «ENDIF»
        public «IF targets('1.3.x')»static «ENDIF»function postLoadGeneric(«IF targets('1.3.x')»Zikula_Event«ELSE»GenericEvent«ENDIF» $event)
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
         *     `«IF targets('1.3.x')»array(«ELSE»[«ENDIF»
         *          'modname' => $modname,
         *          'modfunc' => $modfunc,
         *          'args' => $args,
         *          'modinfo' => $modinfo,
         *          'type' => $type,
         *          'api' => $api
         *      «IF targets('1.3.x')»)«ELSE»]«ENDIF»`
         * .
         *
         * @param «IF targets('1.3.x')»Zikula_Event«ELSE»GenericEvent«ENDIF» $event The event instance
         */
        «ELSE»
            /**
             * {@inheritdoc}
             */
        «ENDIF»
        public «IF targets('1.3.x')»static «ENDIF»function preExecute(«IF targets('1.3.x')»Zikula_Event«ELSE»GenericEvent«ENDIF» $event)
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
         *     `«IF targets('1.3.x')»array(«ELSE»[«ENDIF»
         *          'modname' => $modname,
         *          'modfunc' => $modfunc,
         *          'args' => $args,
         *          'modinfo' => $modinfo,
         *          'type' => $type,
         *          'api' => $api
         *      «IF targets('1.3.x')»)«ELSE»]«ENDIF»`
         * .
         * Receives the modules output with `$event->getData();`.
         * Can modify this output with `$event->setData($data);`.
         *
         * @param «IF targets('1.3.x')»Zikula_Event«ELSE»GenericEvent«ENDIF» $event The event instance
         */
        «ELSE»
            /**
             * {@inheritdoc}
             */
        «ENDIF»
        public «IF targets('1.3.x')»static «ENDIF»function postExecute(«IF targets('1.3.x')»Zikula_Event«ELSE»GenericEvent«ENDIF» $event)
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
         * Receives no subject, args of `«IF targets('1.3.x')»array(«ELSE»[«ENDIF»'modname' => $modname, 'modinfo' => $modinfo, 'type' => $type, 'api' => $api«IF targets('1.3.x')»)«ELSE»]«ENDIF»`
         * and 'event data' of `$className`. This can be altered by setting `$event->setData()` followed by `$event->stop«IF !targets('1.3.x')»Propagation«ENDIF»()`.
         *
         * @param «IF targets('1.3.x')»Zikula_Event«ELSE»GenericEvent«ENDIF» $event The event instance
         */
        «ELSE»
            /**
             * {@inheritdoc}
             */
        «ENDIF»
        public «IF targets('1.3.x')»static «ENDIF»function customClassname(«IF targets('1.3.x')»Zikula_Event«ELSE»GenericEvent«ENDIF» $event)
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
         * @param «IF targets('1.3.x')»Zikula_Event«ELSE»GenericEvent«ENDIF» $event The event instance
         */
        «ELSE»
            /**
             * {@inheritdoc}
             */
        «ENDIF»
        public «IF targets('1.3.x')»static «ENDIF»function serviceLinks(«IF targets('1.3.x')»Zikula_Event«ELSE»GenericEvent«ENDIF» $event)
        {
            «IF !isBase»
                parent::customClassName($event);

                // Format data like so:
                «IF targets('1.3.x')»
                    // $dom = ZLanguage::getModuleDomain('«appName»');
                    // $event->data[] = array('url' => ModUtil::url('«appName»', 'user', 'main'), 'text' => __('Link text', $dom));
                «ELSE»
                    // $serviceManager = \ServiceUtil::getManager();
                    // $event->data[] = ['url' => $serviceManager->get('router')->generate('«appName.formatForDB»_user_index'), 'text' => $serviceManager->get('translator.default')->__('Link text')];
                «ENDIF»

                «commonExample.generalEventProperties(it)»
            «ENDIF»
        }
    '''
}