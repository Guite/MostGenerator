package org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ModuleDispatchListener {

    extension FormattingExtensions = new FormattingExtensions
    extension Utils = new Utils

    CommonExample commonExample = new CommonExample()

    def generate(Application it) '''
        public static function getSubscribedEvents()
        {
            return [
                'module_dispatch.service_links' => ['serviceLinks', 5]
            ];
        }

        /**
         * Listener for the `module_dispatch.service_links` event.
         *
         * Occurs when building admin menu items.
         * Adds sublinks to a Services menu that is appended to all modules if populated.
         * Triggered by module_dispatch.postexecute in bootstrap.
         *
         * Inject router and translator services and format data like this:
         *     `$event->data[] = [
         *         'url' => $router->generate('«appName.formatForDB»_user_index'),
         *         'text' => $translator->__('Link text')
         *     ];`
         *
         «commonExample.generalEventProperties(it, false)»
         */
        public function serviceLinks(GenericEvent $event)«IF targets('3.0')»: void«ENDIF»
        {
        }
    '''
}
