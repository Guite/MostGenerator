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

    def generate(Application it, IFileSystemAccess fsa) {
        if (targets('1.3.x')) {
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
         * The «appName.formatForDB»«IF targets('1.3.x')»ObjectTypeSelector plugin«ELSE»_objectTypeSelector function«ENDIF» provides items for a dropdown selector.
        «IF targets('1.3.x')»
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
        «IF !targets('1.3.x')»public «ENDIF»function «IF targets('1.3.x')»smarty_function_«appName.formatForDB»«ELSE»get«ENDIF»ObjectTypeSelector(«IF targets('1.3.x')»$params, $view«ENDIF»)
        {
            $dom = «IF !targets('1.3.x')»\«ENDIF»ZLanguage::getModuleDomain('«appName»');
            $result = array();

            «entityEntries»

            «IF targets('1.3.x')»
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
            $result[] = array('text' => __('«entity.nameMultiple.formatForDisplayCapital»', $dom), 'value' => '«entity.name.formatForCode»');
        «ENDFOR»
    '''
}
