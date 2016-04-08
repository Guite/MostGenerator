package org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ObjectTypeSelector {
    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    Boolean generateSmartyPlugin

    def generate(Application it, IFileSystemAccess fsa, Boolean enforceLegacy) {
        generateSmartyPlugin = targets('1.3.x') || enforceLegacy
        if (generateSmartyPlugin) {
            val pluginFilePath = viewPluginFilePath('function', 'ObjectTypeSelector')
            if (!shouldBeSkipped(pluginFilePath)) {
                fsa.generateFile(pluginFilePath, new FileHelper().phpFileContent(it, selectorObjectTypesImpl))
            }
        } else {
            selectorObjectTypesImpl
        }
    }

    def private selectorObjectTypesImpl(Application it) '''
        /**
         * The «appName.formatForDB»«IF generateSmartyPlugin»ObjectTypeSelector plugin«ELSE»_objectTypeSelector function«ENDIF» provides items for a dropdown selector.
        «IF generateSmartyPlugin»
            «' '»*
            «' '»* Available parameters:
            «' '»*   - assign: If set, the results are assigned to the corresponding variable instead of printed out.
            «' '»*
            «' '»* @param  array            $params All attributes passed to this function from the template.
            «' '»* @param  Zikula_Form_View $view   Reference to the view object.
        «ENDIF»
         *
         * @return string The output of the plugin.
         */
        «IF !generateSmartyPlugin»public «ENDIF»function «IF generateSmartyPlugin»smarty_function_«appName.formatForDB»«ELSE»get«ENDIF»ObjectTypeSelector(«IF generateSmartyPlugin»$params, $view«ENDIF»)
        {
            «IF targets('1.3.x')»
                $dom = ZLanguage::getModuleDomain('«appName»');
                $result = array();
            «ELSE»
                $result = [];
            «ENDIF»

            «entityEntries»

            «IF generateSmartyPlugin»
                if (array_key_exists('assign', $params)) {
                    $view->assign($params['assign'], $result);

                    return;
                }

            «ENDIF»
            return $result;
        }
    '''

    def private entityEntries(Application it) '''
        «FOR entity : getAllEntities»
            «IF targets('1.3.x')»
                $result[] = array('text' => __('«entity.nameMultiple.formatForDisplayCapital»', $dom), 'value' => '«entity.name.formatForCode»');
            «ELSE»
                $result[] = ['text' => $this->__('«entity.nameMultiple.formatForDisplayCapital»'), 'value' => '«entity.name.formatForCode»'];
            «ENDIF»
        «ENDFOR»
    '''
}
