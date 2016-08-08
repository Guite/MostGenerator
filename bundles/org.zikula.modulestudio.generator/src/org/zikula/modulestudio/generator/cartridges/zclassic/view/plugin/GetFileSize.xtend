package org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class GetFileSize {
    extension FormattingExtensions = new FormattingExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    def generate(Application it, IFileSystemAccess fsa) {
        if (targets('1.3.x')) {
            val pluginFilePath = viewPluginFilePath('modifier', 'GetFileSize')
            if (!shouldBeSkipped(pluginFilePath)) {
                fsa.generateFile(pluginFilePath, new FileHelper().phpFileContent(it, getFileSizeImpl))
            }
        } else {
            getFileSizeImpl
        }
    }

    def private getFileSizeImpl(Application it) '''
        /**
         * The «appName.formatForDB»«IF targets('1.3.x')»GetFileSize modifier«ELSE»_fileSize filter«ENDIF» displays the size of a given file in a readable way.
         * Example:
         *     «IF targets('1.3.x')»{12345|«appName.formatForDB»GetFileSize}«ELSE»{{ 12345|«appName.formatForDB»_fileSize }}«ENDIF»
         *
         * @param integer $size     File size in bytes
         * @param string  $filepath The input file path including file name (if file size is not known)
         * @param boolean $nodesc   If set to true the description will not be appended
         * @param boolean $onlydesc If set to true only the description will be returned
         *
         * @return string File size in a readable form
         */
        «IF !targets('1.3.x')»public «ENDIF»function «IF targets('1.3.x')»smarty_modifier_«appName.formatForDB»G«ELSE»g«ENDIF»etFileSize($size = 0, $filepath = '', $nodesc = false, $onlydesc = false)
        {
            if (!is_numeric($size)) {
                $size = (int) $size;
            }
            if (!$size) {
                if (empty($filepath) || !file_exists($filepath)) {
                    return '';
                }
                $size = filesize($filepath);
            }
            if (!$size) {
                return '';
            }

            «IF targets('1.3.x')»
                $serviceManager = ServiceUtil::getManager();
                $viewHelper = new «appName»_Util_View($serviceManager);

            «ENDIF»
            return $«IF !targets('1.3.x')»this->«ENDIF»viewHelper->getReadableFileSize($size, $nodesc, $onlydesc);
        }
    '''
}
