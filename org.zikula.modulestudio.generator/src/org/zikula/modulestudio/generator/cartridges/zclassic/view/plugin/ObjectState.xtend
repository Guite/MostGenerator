package org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ObjectState {
    extension FormattingExtensions = new FormattingExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    def generate(Application it, IFileSystemAccess fsa) {
        if (targets('1.3.x')) {
            val pluginFilePath = viewPluginFilePath('modifier', 'ObjectState')
            if (!shouldBeSkipped(pluginFilePath)) {
                fsa.generateFile(pluginFilePath, new FileHelper().phpFileContent(it, objectStateImpl))
            }
        } else {
            objectStateImpl
        }
    }

    def private objectStateImpl(Application it) '''
        /**
         * The «appName.formatForDB»«IF targets('1.3.x')»ObjectState modifier«ELSE»_objectState filter«ENDIF» displays the name of a given object's workflow state.
         * Examples:
         *    «IF targets('1.3.x')»{$item.workflowState|«appName.formatForDB»ObjectState}       {* with visual feedback *}«ELSE»{{ item.workflowState|«appName.formatForDB»_objectState }}        {# with visual feedback #}«ENDIF»
         *    «IF targets('1.3.x')»{$item.workflowState|«appName.formatForDB»ObjectState:false} {* no ui feedback *}«ELSE»{{ item.workflowState|«appName.formatForDB»_objectState(false) }} {# no ui feedback #}«ENDIF»
         *
         * @param string  $state      Name of given workflow state.
         * @param boolean $uiFeedback Whether the output should include some visual feedback about the state.
         *
         * @return string Enriched and translated workflow state ready for display.
         */
        «IF !targets('1.3.x')»public «ENDIF»function «IF targets('1.3.x')»smarty_modifier_«appName.formatForDB»«ELSE»get«ENDIF»ObjectState($state = 'initial', $uiFeedback = true)
        {
            $serviceManager = «IF !targets('1.3.x')»\«ENDIF»ServiceUtil::getManager();
            «IF targets('1.3.x')»
                $workflowHelper = new «appName»_Util_Workflow($serviceManager);
            «ELSE»
                $workflowHelper = $serviceManager->get('«appName.formatForDB».workflow_helper');
            «ENDIF»

            $stateInfo = $workflowHelper->getStateInfo($state);

            $result = $stateInfo['text'];
            if ($uiFeedback === true) {
                «IF targets('1.3.x')»«/* LED images (legacy) */»
                    $result = '<img src="' . System::getBaseUrl() . 'images/icons/extrasmall/' . $stateInfo['ui'] . 'led.png" width="16" height="16" alt="' . $result . '" />&nbsp;&nbsp;' . $result;
                «ELSE»«/* use Bootstrap labels instead of images */»
                    $result = '<span class="label label-' . $stateInfo['ui'] . '">' . $result . '</span>';
                «ENDIF»
            }

            return $result;
        }
    '''
}
