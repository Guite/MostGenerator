package org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class FormatGeoData {
    extension FormattingExtensions = new FormattingExtensions
    extension Utils = new Utils

    def generate(Application it, IFileSystemAccess fsa) {
        formatGeoDataImpl
    }

    def private formatGeoDataImpl(Application it) '''
        /**
         * The «appName.formatForDB»_geoData filter formats geo data.
         * Example:
         *     {{ latitude|«appName.formatForDB»_geoData }}
         *
         * @param string $string The data to be formatted
         *
         * @return string The formatted output
         */
        public function formatGeoData($string)
        {
            return number_format($string, 7, '.', '');
        }
    '''
}
