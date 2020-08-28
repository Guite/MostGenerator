package org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class FormatGeoData {

    extension FormattingExtensions = new FormattingExtensions
    extension Utils = new Utils

    def generate(Application it) {
        formatGeoDataImpl
    }

    def private formatGeoDataImpl(Application it) '''
        /**
         * The «appName.formatForDB»_geoData filter formats geo data.
         * Example:
         *     {{ latitude|«appName.formatForDB»_geoData }}.
         «IF !targets('3.0')»
         *
         * @param string $string The data to be formatted
         *
         * @return string The formatted output
         «ENDIF»
         */
        public function formatGeoData«IF targets('3.0')»(float $string): string«ELSE»($string)«ENDIF»
        {
            return number_format($string, 7, '.', '');
        }
    '''
}
