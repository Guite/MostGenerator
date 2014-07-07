package org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin

import de.guite.modulestudio.metamodel.modulestudio.Application
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
        val pluginFilePath = viewPluginFilePath('function', 'ObjectTypeSelector')
        if (!shouldBeSkipped(pluginFilePath)) {
            fsa.generateFile(pluginFilePath, new FileHelper().phpFileContent(it, selectorObjectTypesImpl))
        }
    }

    def private selectorObjectTypesImpl(Application it) '''
        /**
         * The «appName.formatForDB»ObjectTypeSelector plugin provides items for a dropdown selector.
         *
         * Available parameters:
         *   - assign: If set, the results are assigned to the corresponding variable instead of printed out.
         *
         * @param  array            $params All attributes passed to this function from the template.
         * @param  Zikula_Form_View $view   Reference to the view object.
         *
         * @return string The output of the plugin.
         */
        function smarty_function_«appName.formatForDB»ObjectTypeSelector($params, $view)
        {
            $dom = «IF !targets('1.3.5')»\«ENDIF»ZLanguage::getModuleDomain('«appName»');
            $result = array();

            «entityEntries»

            if (array_key_exists('assign', $params)) {
                $view->assign($params['assign'], $result);

                return;
            }

            return $result;
        }
    '''

    def private entityEntries(Application it) '''
        «FOR entity : getAllEntities»
            $result[] = array('text' => __('«entity.nameMultiple.formatForDisplayCapital»', $dom), 'value' => '«entity.name.formatForCode»');
        «ENDFOR»
    '''
}
