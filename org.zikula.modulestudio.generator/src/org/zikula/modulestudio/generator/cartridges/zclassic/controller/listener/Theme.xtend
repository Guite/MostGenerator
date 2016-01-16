package org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.extensions.Utils

class Theme {
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
                        'theme.preinit'     => ['preInit', 5],
                        'theme.init'        => ['init', 5],
                        'theme.load_config' => ['loadConfig', 5],
                        'theme.prefetch'    => ['preFetch', 5],
                        'theme.postfetch'   => ['postFetch', 5]
                    ];
                «ELSE»
                    return parent::getSubscribedEvents();
                «ENDIF»
            }

        «ENDIF»
        /**
         * Listener for the `theme.preinit` event.
         *
         * Occurs on the startup of the `Zikula_View_Theme#__construct()`.
         * The subject is the Zikula_View_Theme instance.
         * Is useful to setup a customized theme configuration or cache_id.
        «IF !targets('1.3.x')»
            «' '»*
            «' '»* Note that Zikula_View_Theme is deprecated and being replaced by Twig.
        «ENDIF»
         *
         * @param «IF targets('1.3.x')»Zikula_Event«ELSE»GenericEvent«ENDIF» $event The event instance.
         */
        public «IF targets('1.3.x')»static «ENDIF»function preInit(«IF targets('1.3.x')»Zikula_Event«ELSE»GenericEvent«ENDIF» $event)
        {
            «IF !isBase»
                parent::preInit($event);

                «commonExample.generalEventProperties(it)»
            «ENDIF»
        }

        /**
         * Listener for the `theme.init` event.
         *
         * Occurs just before `Zikula_View_Theme#__construct()` finishes.
         * The subject is the Zikula_View_Theme instance.
        «IF !targets('1.3.x')»
            «' '»*
            «' '»* Note that Zikula_View_Theme is deprecated and being replaced by Twig.
        «ENDIF»
         *
         * @param «IF targets('1.3.x')»Zikula_Event«ELSE»GenericEvent«ENDIF» $event The event instance.
         */
        public «IF targets('1.3.x')»static «ENDIF»function init(«IF targets('1.3.x')»Zikula_Event«ELSE»GenericEvent«ENDIF» $event)
        {
            «IF !isBase»
                parent::init($event);

                «commonExample.generalEventProperties(it)»
            «ENDIF»
        }

        /**
         * Listener for the `theme.load_config` event.
         *
         * Runs just before `Theme#load_config()` completed.
         * Subject is the Theme instance.
         *
         * @param «IF targets('1.3.x')»Zikula_Event«ELSE»GenericEvent«ENDIF» $event The event instance.
         */
        public «IF targets('1.3.x')»static «ENDIF»function loadConfig(«IF targets('1.3.x')»Zikula_Event«ELSE»GenericEvent«ENDIF» $event)
        {
            «IF !isBase»
                parent::loadConfig($event);

                «commonExample.generalEventProperties(it)»
            «ENDIF»
        }

        /**
         * Listener for the `theme.prefetch` event.
         *
         * Occurs in `Theme::themefooter()` just after getting the `$maincontent`.
         * The event subject is `$this` (Theme instance) and has $maincontent as the event data
         * which you can modify with `$event->setData()` in the event handler.
         *
         * @param «IF targets('1.3.x')»Zikula_Event«ELSE»GenericEvent«ENDIF» $event The event instance.
         */
        public «IF targets('1.3.x')»static «ENDIF»function preFetch(«IF targets('1.3.x')»Zikula_Event«ELSE»GenericEvent«ENDIF» $event)
        {
            «IF !isBase»
                parent::preFetch($event);

                «commonExample.generalEventProperties(it)»
            «ENDIF»
        }

        /**
         * Listener for the `theme.postfetch` event.
         *
         * Occurs in `Theme::themefooter()` just after rendering the theme.
         * The event subject is `$this` (Theme instance) and the event data is the rendered
         * output which you can modify with `$event->setData()` in the event handler.
         *
         * @param «IF targets('1.3.x')»Zikula_Event«ELSE»GenericEvent«ENDIF» $event The event instance.
         */
        public «IF targets('1.3.x')»static «ENDIF»function postFetch(«IF targets('1.3.x')»Zikula_Event«ELSE»GenericEvent«ENDIF» $event)
        {
            «IF !isBase»
                parent::postFetch($event);

                «commonExample.generalEventProperties(it)»
            «ENDIF»
        }
    '''
}
