package org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class TemplateHeaders {
    extension FormattingExtensions = new FormattingExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    def generate(Application it, IFileSystemAccess fsa) {
        if (targets('1.3.x')) {
            val pluginFilePath = viewPluginFilePath('function', 'TemplateHeaders')
            if (!shouldBeSkipped(pluginFilePath)) {
                fsa.generateFile(pluginFilePath, new FileHelper().phpFileContent(it, templateHeadersImpl))
            }
        } else {
            templateHeadersImpl
        }
    }

    def private templateHeadersImpl(Application it) '''
        /**
         * The «appName.formatForDB»«IF targets('1.3.x')»TemplateHeaders plugin«ELSE»_templateHeaders function«ENDIF» performs header() operations
         * to change the content type provided to the user agent.
         *
         * Available parameters:
         *   - contentType:  Content type for corresponding http header.
         *   - asAttachment: If set to true the file will be offered for downloading.
         *   - fileName:     Name of download file.
        «IF targets('1.3.x')»
            «' '»*
            «' '»* @param  array       $params All attributes passed to this function from the template.
            «' '»* @param  Zikula_View $view   Reference to the view object.
        «ENDIF»
         *
         * @return boolean false.
         */
        «IF !targets('1.3.x')»public «ENDIF»function «IF targets('1.3.x')»smarty_function_«appName.formatForDB»T«ELSE»t«ENDIF»emplateHeaders(«IF targets('1.3.x')»$params, $view«ELSE»$contentType, $asAttachment = false, $fileName = ''«ENDIF»)
        {
            «IF targets('1.3.x')»
                if (!isset($params['contentType'])) {
                    $view->trigger_error($view->__f('%1$s: missing parameter \'%2$s\'', array('«appName.formatForDB»TemplateHeaders', 'contentType')));
                }

            «ENDIF»
            // apply header
            header('Content-Type: ' . $«IF targets('1.3.x')»params['«ENDIF»contentType«IF targets('1.3.x')»']«ENDIF»);

            // if desired let the browser offer the given file as a download
            «IF targets('1.3.x')»
                if (isset($params['asAttachment']) && $params['asAttachment']
                 && isset($params['fileName']) && !empty($params['fileName'])) {
                    header('Content-Disposition: attachment; filename=' . $params['fileName']);
                }
            «ELSE»
                if ($asAttachment && !empty($fileName)) {
                    header('Content-Disposition: attachment; filename=' . $fileName);
                }
            «ENDIF»

            return;
        }
    '''
}
