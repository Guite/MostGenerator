package org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class FormatGeoData {
    @Inject extension FormattingExtensions = new FormattingExtensions()
    @Inject extension NamingExtensions = new NamingExtensions()
    @Inject extension Utils = new Utils()

    def generate(Application it, IFileSystemAccess fsa) {
        fsa.generateFile(viewPluginFilePath('modifier', 'FormatGeoData'), formatGeoDataFile)
    }

    def private formatGeoDataFile(Application it) '''
        «new FileHelper().phpFileHeader(it)»
        «formatGeoDataImpl»
    '''

    def private formatGeoDataImpl(Application it) '''
        /**
         * The «appName.formatForDB»FormatGeoData modifier formats geo data.
         *
         * @param string $string The data to be formatted.
         *
         * @return string The formatted output.
         */
        function smarty_modifier_«appName.formatForDB»FormatGeoData($string)
        {
            return number_format($string, 7, '.', '');
        }
    '''
}
