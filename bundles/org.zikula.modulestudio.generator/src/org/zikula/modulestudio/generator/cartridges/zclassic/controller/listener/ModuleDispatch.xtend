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
                    'module_dispatch.service_links'    => ['serviceLinks', 5]
                ];
            «ELSE»
                return parent::getSubscribedEvents();
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

                // Inject router and translator services and format data like this:
                // $event->data[] = [
                //     'url' => $router->generate('«appName.formatForDB»_user_index'),
                //     'text' => $translator->__('Link text')
                // ];

                «commonExample.generalEventProperties(it)»
            «ENDIF»
        }
    '''
}
