package org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class TemplateHeaders {
    @Inject extension FormattingExtensions = new FormattingExtensions
    @Inject extension NamingExtensions = new NamingExtensions
    @Inject extension Utils = new Utils

    def generate(Application it, IFileSystemAccess fsa) {
        if (!targets('1.3.5')) {
            return
        }
        val pluginFilePath = viewPluginFilePath('function', 'TemplateHeaders')
        if (!shouldBeSkipped(pluginFilePath)) {
            fsa.generateFile(pluginFilePath, new FileHelper().phpFileContent(it, templateHeadersImpl))
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
         *   - filename:     Name of download file.
         *
         * @param  array       $params All attributes passed to this function from the template.
         * @param  Zikula_View $view   Reference to the view object.
         *
         * @return boolean false.
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
             && isset($params['filename']) && !empty($params['filename'])) {
                header('Content-Disposition: attachment; filename=' . $params['filename']);
            }

            return;
        }
    '''
}
