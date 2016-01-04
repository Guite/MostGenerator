package org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class TemplateSelector {
    extension FormattingExtensions = new FormattingExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    def generate(Application it, IFileSystemAccess fsa) {
        if (targets('1.3.x')) {
            val pluginFilePath = viewPluginFilePath('function', 'TemplateSelector')
            if (!shouldBeSkipped(pluginFilePath)) {
                fsa.generateFile(pluginFilePath, new FileHelper().phpFileContent(it, selectorTemplatesImpl))
            }
        } else {
            selectorTemplatesImpl
        }
    }

    def private selectorTemplatesImpl(Application it) '''
        /**
         * The «appName.formatForDB»«IF targets('1.3.x')»TemplateSelector plugin«ELSE»_templateSelector function«ENDIF» provides items for a dropdown selector.
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
        «IF !targets('1.3.x')»public «ENDIF»function «IF targets('1.3.x')»smarty_function_«appName.formatForDB»«ELSE»get«ENDIF»TemplateSelector($params, $view)
        {
            «val templateExtension = if (targets('1.3.x')) '.tpl' else '.html.twig'»
            $dom = «IF !targets('1.3.x')»\«ENDIF»ZLanguage::getModuleDomain('«appName»');
            $result = «IF targets('1.3.x')»array()«ELSE»[]«ENDIF»;

            $result[] = «IF targets('1.3.x')»array(«ELSE»[«ENDIF»'text' => __('Only item titles', $dom), 'value' => 'itemlist_display«templateExtension»'«IF targets('1.3.x')»)«ELSE»]«ENDIF»;
            $result[] = «IF targets('1.3.x')»array(«ELSE»[«ENDIF»'text' => __('With description', $dom), 'value' => 'itemlist_display_description«templateExtension»'«IF targets('1.3.x')»)«ELSE»]«ENDIF»;
            $result[] = «IF targets('1.3.x')»array(«ELSE»[«ENDIF»'text' => __('Custom template', $dom), 'value' => 'custom'«IF targets('1.3.x')»)«ELSE»]«ENDIF»;

            «IF targets('1.3.x')»
                if (array_key_exists('assign', $params)) {
                    $view->assign($params['assign'], $result);

                    return;
                }

            «ENDIF»
            return $result;
        }
    '''
}
