package org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Application
import org.zikula.modulestudio.generator.extensions.Utils

class ModuleDispatch {
    @Inject extension Utils = new Utils()

    def generate(Application it, Boolean isBase) '''
        /**
         * Listener for the `module_dispatch.postloadgeneric` event.
         *
         * Called after a module api or controller has been loaded.
         * Receives the args `array('modinfo' => $modinfo, 'type' => $type, 'force' => $force, 'api' => $api)`.
         *
         * @param «IF targets('1.3.5')»Zikula_Event«ELSE»Zikula\Core\Event\GenericEvent«ENDIF» $event The event instance.
         */
        public static function postLoadGeneric(«IF targets('1.3.5')»Zikula_Event«ELSE»Zikula\Core\Event\GenericEvent«ENDIF» $event)
        {
            «IF !isBase»
                parent::postLoadGeneric($event);
            «ENDIF»
        }

        /**
         * Listener for the `module_dispatch.preexecute` event.
         *
         * Occurs in `\ModUtil::exec()` after function call with the following args:
         * `array('modname' => $modname, 'modfunc' => $modfunc, 'args' => $args, 'modinfo' => $modinfo, 'type' => $type, 'api' => $api)`.
         *
         * @param «IF targets('1.3.5')»Zikula_Event«ELSE»Zikula\Core\Event\GenericEvent«ENDIF» $event The event instance.
         */
        public static function preExecute(«IF targets('1.3.5')»Zikula_Event«ELSE»Zikula\Core\Event\GenericEvent«ENDIF» $event)
        {
            «IF !isBase»
                parent::preExecute($event);
            «ENDIF»
        }

        /**
         * Listener for the `module_dispatch.postexecute` event.
         *
         * Occurs in `\ModUtil::exec()` after function call with the following args:
         * `array('modname' => $modname, 'modfunc' => $modfunc, 'args' => $args, 'modinfo' => $modinfo, 'type' => $type, 'api' => $api)`.
         * Receives the modules output with `$event->getData();`.
         * Can modify this output with `$event->setData($data);`.
         *
         * @param «IF targets('1.3.5')»Zikula_Event«ELSE»Zikula\Core\Event\GenericEvent«ENDIF» $event The event instance.
         */
        public static function postExecute(«IF targets('1.3.5')»Zikula_Event«ELSE»Zikula\Core\Event\GenericEvent«ENDIF» $event)
        {
            «IF !isBase»
                parent::postExecute($event);
            «ENDIF»
        }

        /**
         * Listener for the `module_dispatch.custom_classname` event.
         *
         * In order to override the classname calculated in `\ModUtil::exec()`.
         * In order to override a pre-existing controller/api method, use this event type to override the class name that is loaded.
         * This allows to override the methods using inheritance.
         * Receives no subject, args of `array('modname' => $modname, 'modinfo' => $modinfo, 'type' => $type, 'api' => $api)`
         * and 'event data' of `$className`. This can be altered by setting `$event->setData()` followed by `$event->stop«IF !targets('1.3.5')»Propagation«ENDIF»()`.
         *
         * @param «IF targets('1.3.5')»Zikula_Event«ELSE»Zikula\Core\Event\GenericEvent«ENDIF» $event The event instance.
         */
        public static function customClassname(«IF targets('1.3.5')»Zikula_Event«ELSE»Zikula\Core\Event\GenericEvent«ENDIF» $event)
        {
            «IF !isBase»
                parent::customClassName($event);
            «ENDIF»
        }
    '''
}
