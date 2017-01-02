package org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener

import de.guite.modulestudio.metamodel.Application

class View {

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
                    'view.init'      => ['init', 5],
                    'view.postfetch' => ['postFetch', 5]
                ];
            «ELSE»
                return parent::getSubscribedEvents();
            «ENDIF»
        }

        «IF isBase»
        /**
         * Listener for the `view.init` event.
         *
         * Occurs just before `Zikula_View#__construct()` finishes.
         * The subject is the Zikula_View instance.
         *
         * Note that Zikula_View is deprecated and being replaced by Twig.
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
         * Listener for the `view.postfetch` event.
         *
         * Filter of result of a fetch.
         * Receives `Zikula_View` instance as subject,
         * args are `['template' => $template]`,
         * $data was the result of the fetch to be filtered.
         *
         * Note that Zikula_View is deprecated and being replaced by Twig.
         *
         * @param GenericEvent $event The event instance
         */
        «ELSE»
            /**
             * {@inheritdoc}
             */
        «ENDIF»
        public function postFetch(GenericEvent $event)
        {
            «IF !isBase»
                parent::postFetch($event);

                «commonExample.generalEventProperties(it)»
            «ENDIF»
        }
    '''
}
