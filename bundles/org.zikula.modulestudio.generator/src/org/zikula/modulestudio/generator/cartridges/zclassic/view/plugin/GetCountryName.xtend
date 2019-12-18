package org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class GetCountryName {

    extension FormattingExtensions = new FormattingExtensions
    extension Utils = new Utils

    def generate(Application it) {
        getCountryNameImpl
    }

    def private getCountryNameImpl(Application it) '''
        /**
         * The «appName.formatForDB»_countryName filter displays the country name for a given country code.
         * Example:
         *     {{ 'de'|«appName.formatForDB»_countryName }}
         «IF !targets('3.0')»
         *
         * @param string $countryCode The country code to process
         *
         * @return string Country name
         «ENDIF»
         */
        public function getCountryName«IF targets('3.0')»(string $countryCode): string«ELSE»($countryCode)«ENDIF»
        {
            «IF targets('3.0')»
                $result = Countries::getName($countryCode);
            «ELSE»
                $result = Intl::getRegionBundle()->getCountryName($countryCode);
            «ENDIF»
            if (false === $result) {
                $result = $countryCode;
            }

            return $result;
        }
    '''
}
