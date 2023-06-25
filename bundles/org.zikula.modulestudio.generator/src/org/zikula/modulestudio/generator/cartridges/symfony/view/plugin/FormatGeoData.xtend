package org.zikula.modulestudio.generator.cartridges.symfony.view.plugin

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
         */
        public function formatGeoData(float $value): string
        {
            return number_format($value, 7, '.', '');
        }
    '''
}
