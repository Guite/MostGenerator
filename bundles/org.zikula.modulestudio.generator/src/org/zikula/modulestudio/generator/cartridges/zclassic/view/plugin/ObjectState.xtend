package org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ObjectState {
    extension FormattingExtensions = new FormattingExtensions
    extension Utils = new Utils

    def generate(Application it, IFileSystemAccess fsa) {
        objectStateImpl
    }

    def private objectStateImpl(Application it) '''
        /**
         * The «appName.formatForDB»_objectState filter displays the name of a given object's workflow state.
         * Examples:
         *    {{ item.workflowState|«appName.formatForDB»_objectState }}        {# with visual feedback #}
         *    {{ item.workflowState|«appName.formatForDB»_objectState(false) }} {# no ui feedback #}
         *
         * @param string  $state      Name of given workflow state
         * @param boolean $uiFeedback Whether the output should include some visual feedback about the state
         *
         * @return string Enriched and translated workflow state ready for display
         */
        public function getObjectState($state = 'initial', $uiFeedback = true)
        {
            $stateInfo = $this->workflowHelper->getStateInfo($state);

            $result = $stateInfo['text'];
            if (true === $uiFeedback) {
                $result = '<span class="label label-' . $stateInfo['ui'] . '">' . $result . '</span>';
            }

            return $result;
        }
    '''
}
