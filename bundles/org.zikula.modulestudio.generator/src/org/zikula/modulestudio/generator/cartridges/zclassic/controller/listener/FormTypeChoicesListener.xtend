package org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener

import de.guite.modulestudio.metamodel.Application

class FormTypeChoicesListener {

    def generate(Application it) '''
        public static function getSubscribedEvents()
        {
            return [
                FormTypeChoiceEvent::NAME => ['formTypeChoices']
            ];
        }

        /**
         * Listener for the `FormTypeChoiceEvent` event.
         *
         * Implement using like this:
         *
         * $choices = $event->getChoices();
         *
         * $groupName = $this->translator->trans('Other Fields');
         * if (!isset($choices[$groupName])) {
         *     $choices[$groupName] = [];
         * }
         *
         * $groupChoices = $choices[$groupName];
         * $groupChoices[$this->translator->trans('Special field')] = SpecialFieldType::class;
         * $choices[$groupName] = $groupChoices;
         *
         * $event->setChoices($choices);
         */
        public function formTypeChoices(FormTypeChoiceEvent $event): void
        {
        }
    '''
}
