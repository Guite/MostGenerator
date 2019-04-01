package org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class TemplateSelector {

    extension FormattingExtensions = new FormattingExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    Boolean generateSmartyPlugin

    def generate(Application it, IMostFileSystemAccess fsa, Boolean enforceLegacy) {
        if (targets('2.0')) {
            return '';
        }
        generateSmartyPlugin = enforceLegacy
        if (generateSmartyPlugin) {
            val pluginFilePath = legacyViewPluginFilePath('function', 'TemplateSelector')
            fsa.generateFile(pluginFilePath, selectorTemplatesImpl)
        } else {
            selectorTemplatesImpl
        }
    }

    def private selectorTemplatesImpl(Application it) '''
        /**
         * The «appName.formatForDB»«IF generateSmartyPlugin»TemplateSelector plugin«ELSE»_templateSelector function«ENDIF» provides items for a dropdown selector.
        «IF generateSmartyPlugin»
            «' '»*
            «' '»* Available parameters:
            «' '»*   - assign: If set, the results are assigned to the corresponding variable instead of printed out.
            «' '»*
            «' '»* @param array $params All attributes passed to this function from the template
            «' '»* @param Zikula_Form_View $view Reference to the view object
        «ENDIF»
         *
         * @return string The output of the plugin
         */
        «IF !generateSmartyPlugin»public «ENDIF»function «IF generateSmartyPlugin»smarty_function_«appName.formatForDB»«ELSE»get«ENDIF»TemplateSelector(«IF generateSmartyPlugin»$params, $view«ENDIF»)
        {
            «val templateExtension = '.html.twig'»
            «IF generateSmartyPlugin»
                $dom = ZLanguage::getModuleDomain('«appName»');
            «ENDIF»
            $result = [];

            «IF generateSmartyPlugin»
                $result[] = [
                    'text' => __('Only item titles', $dom),
                    'value' => 'itemlist_display«templateExtension»'
                ];
                $result[] = [
                    'text' => __('With description', $dom),
                    'value' => 'itemlist_display_description«templateExtension»'
                ];
                $result[] = [
                    'text' => __('Custom template', $dom),
                    'value' => 'custom'
                ];
            «ELSE»
                $result[] = [
                    'text' => $this->__('Only item titles'),
                    'value' => 'itemlist_display«templateExtension»'
                ];
                $result[] = [
                    'text' => $this->__('With description'),
                    'value' => 'itemlist_display_description«templateExtension»'
                ];
                $result[] = [
                    'text' => $this->__('Custom template'),
                    'value' => 'custom'
                ];
            «ENDIF»

            «IF generateSmartyPlugin»
                if (array_key_exists('assign', $params)) {
                    $view->assign($params['assign'], $result);

                    return;
                }

            «ENDIF»
            return $result;
        }
    '''
}
