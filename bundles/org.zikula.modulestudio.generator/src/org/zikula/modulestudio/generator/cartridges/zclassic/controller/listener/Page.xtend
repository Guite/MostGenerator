package org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.extensions.NamingExtensions

class Page {
    extension NamingExtensions = new NamingExtensions

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
                    'pageutil.addvar_filter' => ['pageutilAddvarFilter', 5],
                    'system.outputfilter'    => ['systemOutputfilter', 5]
                ];
            «ELSE»
                return parent::getSubscribedEvents();
            «ENDIF»
        }

        «IF isBase»
        /**
         * Listener for the `pageutil.addvar_filter` event.
         *
         * Used to override things like system or module stylesheets or javascript.
         * Subject is the `$varname`, and `$event->data` an array of values to be modified by the filter.
         *
         * This single filter can be used to override all css or js scripts or any other var types
         * sent to `PageUtil::addVar()`.
         *
         * @param GenericEvent $event The event instance
         */
        «ELSE»
            /**
             * {@inheritdoc}
             */
        «ENDIF»
        public function pageutilAddvarFilter(GenericEvent $event)
        {
            «IF !isBase»
                parent::pageutilAddvarFilter($event);

                // Simply test with something like
                /*
                    if (($key = array_search('system/UsersModule/«getAppJsPath»somescript.js', $event->data)) !== false) {
                        $event->data[$key] = 'config/javascript/myoverride.js';
                    }
                */

                «commonExample.generalEventProperties(it)»
            «ENDIF»
        }

        «IF isBase»
        /**
         * Listener for the `system.outputfilter` event.
         *
         * Filter type event for output filter HTML sanitisation.
         *
         * @param GenericEvent $event The event instance
         */
        «ELSE»
            /**
             * {@inheritdoc}
             */
        «ENDIF»
        public function systemOutputFilter(GenericEvent $event)
        {
            «IF !isBase»
                parent::systemOutputFilter($event);

                «commonExample.generalEventProperties(it)»
            «ENDIF»
        }
    '''
}
