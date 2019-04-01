package org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.EntityWorkflowType
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.Utils
import org.zikula.modulestudio.generator.extensions.WorkflowExtensions

class ModerationObjects {

    extension FormattingExtensions = new FormattingExtensions
    extension Utils = new Utils
    extension WorkflowExtensions = new WorkflowExtensions

    def generate(Application it) {
        moderationObjectsImpl
    }

    def private moderationObjectsImpl(Application it) '''
        /**
         * The «appName.formatForDB»_moderationObjects function determines the amount of «IF hasWorkflow(EntityWorkflowType::ENTERPRISE)»unaccepted and «ENDIF»unapproved objects.
         * It uses the same logic as the moderation block and the pending content listener.
         «IF !targets('3.0')»
         *
         * @return array Information about items to be reviewed
         «ENDIF»
         */
        public function getModerationObjects()«IF targets('3.0')»: array«ENDIF»
        {
            return $this->workflowHelper->collectAmountOfModerationItems();
        }
    '''
}
