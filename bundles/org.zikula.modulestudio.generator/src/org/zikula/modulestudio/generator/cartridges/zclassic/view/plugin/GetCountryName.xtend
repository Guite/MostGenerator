package org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class GetCountryName {
    extension FormattingExtensions = new FormattingExtensions
    extension Utils = new Utils

    def generate(Application it, IFileSystemAccess fsa) {
        getCountryNameImpl
    }

    def private getCountryNameImpl(Application it) '''
        /**
         * The «appName.formatForDB»_countryName filter displays the country name for a given country code.
         * Example:
         *     {{ 'de'|«appName.formatForDB»_countryName }}
         *
         * @param string $countryCode The country code to process
         *
         * @return string Country name
         */
        public function getCountryName($countryCode)
        {
            $result = \Symfony\Component\Intl\Intl::getRegionBundle()->getCountryName($countryCode);
            if (false === $result) {
                $result = $countryCode;
            }

            return $result;
        }
    '''
}
