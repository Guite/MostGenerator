package org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

// 1.3.x only
class TemplateHeaders {
    extension FormattingExtensions = new FormattingExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    def CharSequence generate(Application it, IFileSystemAccess fsa) {
        if (!targets('1.3.x')) {
            return ''
        }

        val pluginFilePath = viewPluginFilePath('function', 'TemplateHeaders')
        if (!shouldBeSkipped(pluginFilePath)) {
            fsa.generateFile(pluginFilePath, new FileHelper().phpFileContent(it, templateHeadersImpl))
            return ''
        }
    }

    def private templateHeadersImpl(Application it) '''
        /**
         * The «appName.formatForDB»TemplateHeaders plugin performs header() operations
         * to change the content type provided to the user agent.
         *
         * Available parameters:
         *   - contentType:  Content type for corresponding http header.
         *   - asAttachment: If set to true the file will be offered for downloading.
         *   - fileName:     Name of download file.
         *
         * @param  array       $params All attributes passed to this function from the template
         * @param  Zikula_View $view   Reference to the view object
         *
         * @return boolean false
         */
        function smarty_function_«appName.formatForDB»TemplateHeaders($params, $view)
        {
            if (!isset($params['contentType'])) {
                $view->trigger_error($view->__f('%1$s: missing parameter \'%2$s\'', array('«appName.formatForDB»TemplateHeaders', 'contentType')));
            }

            // apply header
            header('Content-Type: ' . $params['contentType']);

            // if desired let the browser offer the given file as a download
            if (isset($params['asAttachment']) && $params['asAttachment']
             && isset($params['fileName']) && !empty($params['fileName'])) {
                header('Content-Disposition: attachment; filename=' . $params['fileName']);
            }

            return;
        }
    '''
}
