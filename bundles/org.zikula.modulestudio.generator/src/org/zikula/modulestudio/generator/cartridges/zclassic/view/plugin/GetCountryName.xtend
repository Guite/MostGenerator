package org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class GetCountryName {
    extension FormattingExtensions = new FormattingExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    def generate(Application it, IFileSystemAccess fsa) {
        if (targets('1.3.x')) {
            val pluginFilePath = viewPluginFilePath('modifier', 'GetCountryName')
            if (!shouldBeSkipped(pluginFilePath)) {
                fsa.generateFile(pluginFilePath, new FileHelper().phpFileContent(it, getCountryNameImpl))
            }
        } else {
            getCountryNameImpl
        }
    }

    def private getCountryNameImpl(Application it) '''
        /**
         * The «appName.formatForDB»«IF targets('1.3.x')»GetCountryName modifier«ELSE»_countryName filter«ENDIF» displays the country name for a given country code.
         * Example:
         *     «IF targets('1.3.x')»{'de'|«appName.formatForDB»GetCountryName}«ELSE»{{ 'de'|«appName.formatForDB»_countryName }}«ENDIF»
         *
         * @param string $countryCode The country code to process
         *
         * @return string Country name
         */
        «IF !targets('1.3.x')»public «ENDIF»function «IF targets('1.3.x')»smarty_modifier_«appName.formatForDB»G«ELSE»g«ENDIF»etCountryName($countryCode)
        {
            $result = «IF targets('1.3.x')»ZLanguage::getCountryName«ELSE»\Symfony\Component\Intl\Intl::getRegionBundle()->getCountryName«ENDIF»($countryCode);
            if (false === $result) {
                $result = $countryCode;
            }

            return $result;
        }
    '''
}
