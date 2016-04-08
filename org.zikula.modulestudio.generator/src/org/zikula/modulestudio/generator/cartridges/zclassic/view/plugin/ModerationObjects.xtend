package org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.EntityWorkflowType
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils
import org.zikula.modulestudio.generator.extensions.WorkflowExtensions

class ModerationObjects {
    extension FormattingExtensions = new FormattingExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils
    extension WorkflowExtensions = new WorkflowExtensions

    def generate(Application it, IFileSystemAccess fsa) {
        if (targets('1.3.x')) {
            val pluginFilePath = viewPluginFilePath('function', 'ModerationObjects')
            if (!shouldBeSkipped(pluginFilePath)) {
                fsa.generateFile(pluginFilePath, new FileHelper().phpFileContent(it, moderationObjectsImpl))
            }
        } else {
            moderationObjectsImpl
        }
    }

    def private moderationObjectsImpl(Application it) '''
        /**
         * The «appName.formatForDB»«IF targets('1.3.x')»ModerationObjects plugin«ELSE»_moderationObjects function«ENDIF» determines the amount of «IF hasWorkflow(EntityWorkflowType::ENTERPRISE)»unaccepted and «ENDIF»unapproved objects.
         * It uses the same logic as the moderation block and the pending content listener.
        «IF targets('1.3.x')»
            «' '»*
            «' '»* Available parameters:
            «' '»*   - assign: If set, the results are assigned to the corresponding variable instead of printed out.
            «' '»*
            «' '»* @param  array       $params All attributes passed to this function from the template.
            «' '»* @param  Zikula_View $view   Reference to the view object.
        «ENDIF»
         */
        «IF !targets('1.3.x')»public «ENDIF»function «IF targets('1.3.x')»smarty_function_«appName.formatForDB»«ELSE»get«ENDIF»ModerationObjects(«IF targets('1.3.x')»$params, $view«ENDIF»)
        {
            «IF targets('1.3.x')»
                if (!isset($params['assign']) || empty($params['assign'])) {
                    $view->trigger_error(__f('Error! in %1$s: the %2$s parameter must be specified.', array('«appName.formatForDB»ModerationObjects', 'assign')));

                    return false;
                }

                $serviceManager = $view->getServiceManager();
                $workflowHelper = new «appName»_Util_Workflow($serviceManager);

            «ENDIF»
            $result = $«IF !targets('1.3.x')»this->«ENDIF»workflowHelper->collectAmountOfModerationItems();

            «IF targets('1.3.x')»
                $view->assign($params['assign'], $result);
            «ELSE»
                return $result;
            «ENDIF»
        }
    '''
}
