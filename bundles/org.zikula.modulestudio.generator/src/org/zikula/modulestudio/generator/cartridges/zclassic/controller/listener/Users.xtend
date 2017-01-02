package org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener

import de.guite.modulestudio.metamodel.Application

class Users {

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
                    UserEvents::CONFIG_UPDATED => ['configUpdated', 5]
                ];
            «ELSE»
                return parent::getSubscribedEvents();
            «ENDIF»
        }

        «IF isBase»
            /**
             * Listener for the `module.users.config.updated` event.
             *
             * Occurs after the Users module configuration has been
             * updated via the administration interface.
             *
             * Event data is populated by the new values.
             *
             * @param GenericEvent $event The event instance
             */
        «ELSE»
            /**
             * {@inheritdoc}
             */
        «ENDIF»
        public function configUpdated(GenericEvent $event)
        {
            «IF !isBase»
                parent::configUpdated($event);

                «commonExample.generalEventProperties(it)»
            «ENDIF»
        }
    '''
}
