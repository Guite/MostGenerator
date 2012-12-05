package org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ObjectState {
    @Inject extension FormattingExtensions = new FormattingExtensions()
    @Inject extension NamingExtensions = new NamingExtensions()
    @Inject extension Utils = new Utils()

    def generate(Application it, IFileSystemAccess fsa) {
        fsa.generateFile(viewPluginFilePath('modifier', 'ObjectState'), objectStateFile)
    }

    def private objectStateFile(Application it) '''
        «new FileHelper().phpFileHeader(it)»
        «objectStateImpl»
    '''

    def private objectStateImpl(Application it) '''
        /**
         * The «appName.formatForDB»ObjectState modifier displays the name of a given object's workflow state.
         * Examples:
         *    {$item.workflowState|«appName.formatForDB»ObjectState}       {* with led icon *}
         *    {$item.workflowState|«appName.formatForDB»ObjectState:false} {* no icon *}
         *
         * @param string  $state    Name of given workflow state.
         * @param boolean $withIcon Whether a led icon should be displayed before the name.
         *
         * @return string Enriched and translated workflow state ready for display.
         */
        function smarty_modifier_«appName.formatForDB»ObjectState($state = 'initial', $withIcon = true)
        {
            $serviceManager = ServiceUtil::getManager();
            $workflowHelper = new «appName»_Util_Workflow($serviceManager);
            $stateInfo = $workflowHelper->getStateInfo($state);

            $result = $stateInfo['text'];
            if ($withIcon === true) {
                $result = '<img src="/images/icons/extrasmall/' . $stateInfo['icon'] . '" width="16" height="16" alt="' . $result . '" />&nbsp;&nbsp;' . $result;
            }

            return $result;
        }
    '''
}
