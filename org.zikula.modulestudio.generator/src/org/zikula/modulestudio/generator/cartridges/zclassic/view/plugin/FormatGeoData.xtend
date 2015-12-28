package org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class FormatGeoData {
    extension FormattingExtensions = new FormattingExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    def generate(Application it, IFileSystemAccess fsa) {
        if (targets('1.3.x')) {
            val pluginFilePath = viewPluginFilePath('modifier', 'FormatGeoData')
            if (!shouldBeSkipped(pluginFilePath)) {
                fsa.generateFile(pluginFilePath, new FileHelper().phpFileContent(it, formatGeoDataImpl))
            }
        } else {
            formatGeoDataImpl
        }
    }

    def private formatGeoDataImpl(Application it) '''
        /**
         * The «appName.formatForDB»«IF targets('1.3.x')»FormatGeoData modifier«ELSE»_geoData filter«ENDIF» formats geo data.
         * Example:
         *     «IF targets('1.3.x')»{$latitude|«appName.formatForDB»FormatGeoData}«ELSE»{{ latitude|«appName.formatForDB»_geoData }}«ENDIF»
         *
         * @param string $string The data to be formatted.
         *
         * @return string The formatted output.
         */
        «IF !targets('1.3.x')»public «ENDIF»function «IF targets('1.3.x')»smarty_modifier_«appName.formatForDB»F«ELSE»f«ENDIF»ormatGeoData($string)
        {
            return number_format($string, 7, '.', '');
        }
    '''
}
