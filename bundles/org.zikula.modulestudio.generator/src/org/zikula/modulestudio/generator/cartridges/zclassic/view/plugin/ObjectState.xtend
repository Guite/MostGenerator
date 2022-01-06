package org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ObjectState {

    extension FormattingExtensions = new FormattingExtensions
    extension Utils = new Utils

    def generate(Application it) {
        objectStateImpl
    }

    def private objectStateImpl(Application it) '''
        /**
         * The «appName.formatForDB»_objectState filter displays the name of a given object's workflow state.
         * Examples:
         *    {{ item.workflowState|«appName.formatForDB»_objectState }}        {# with visual feedback #}
         *    {{ item.workflowState|«appName.formatForDB»_objectState(false) }} {# no ui feedback #}.
         */
        public function getObjectState(string $state = 'initial', bool $uiFeedback = true): string
        {
            $stateInfo = $this->workflowHelper->getStateInfo($state);

            $result = $stateInfo['text'];
            if (true === $uiFeedback) {
                $result = '<span class="badge badge-' . $stateInfo['ui'] . '">' . $result . '</span>';
            }

            return $result;
        }
    '''
}
