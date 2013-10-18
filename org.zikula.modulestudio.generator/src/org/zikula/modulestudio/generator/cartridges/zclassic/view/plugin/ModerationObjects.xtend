package org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Application
import de.guite.modulestudio.metamodel.modulestudio.EntityWorkflowType
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.GeneratorSettingsExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils
import org.zikula.modulestudio.generator.extensions.WorkflowExtensions

class ModerationObjects {
    @Inject extension FormattingExtensions = new FormattingExtensions
    @Inject extension GeneratorSettingsExtensions = new GeneratorSettingsExtensions
    @Inject extension NamingExtensions = new NamingExtensions
    @Inject extension Utils = new Utils
    @Inject extension WorkflowExtensions = new WorkflowExtensions

    def generate(Application it, IFileSystemAccess fsa) {
        val pluginFilePath = viewPluginFilePath('function', 'ModerationObjects')
        if (!shouldBeSkipped(pluginFilePath)) {
            fsa.generateFile(pluginFilePath, moderationObjectsFile)
        }
    }

    def private moderationObjectsFile(Application it) '''
        «new FileHelper().phpFileHeader(it)»
        «moderationObjectsImpl»
    '''

    def private moderationObjectsImpl(Application it) '''
        /**
         * The «appName.formatForDB»ModerationObjects plugin determines the amount of «IF hasWorkflow(EntityWorkflowType::ENTERPRISE)»unaccepted and «ENDIF»unapproved objects.
         * It uses the same logic as the moderation block and the pending content listener.
         *
         * @param  array       $params All attributes passed to this function from the template.
         * @param  Zikula_View $view   Reference to the view object.
         */
        function smarty_function_«appName.formatForDB»ModerationObjects($params, $view)
        {
            if (!isset($params['assign']) || empty($params['assign'])) {
                $view->trigger_error(__f('Error! in %1$s: the %2$s parameter must be specified.', array('«appName.formatForDB»ModerationObjects', 'assign')));

                return false;
            }

            $serviceManager = $view->getServiceManager();
            $workflowHelper = new «IF targets('1.3.5')»«appName»_Util_Workflow«ELSE»«appNamespace»\Util\WorkflowUtil«ENDIF»($serviceManager«IF !targets('1.3.5')», ModUtil::getModule('«appName»')«ENDIF»);
            $result = $workflowHelper->collectAmountOfModerationItems();

            $view->assign($params['assign'], $result);
        }
    '''
}
