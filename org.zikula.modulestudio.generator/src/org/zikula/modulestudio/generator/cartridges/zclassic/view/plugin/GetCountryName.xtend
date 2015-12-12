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
        val pluginFilePath = viewPluginFilePath('modifier', 'GetCountryName')
        if (!shouldBeSkipped(pluginFilePath)) {
            fsa.generateFile(pluginFilePath, new FileHelper().phpFileContent(it, getCountryNameImpl))
        }
    }

    def private getCountryNameImpl(Application it) '''
        /**
         * The «appName.formatForDB»GetCountryName modifier displays the country name for a given country code.
         *
         * @param string $countryCode The country code to process.
         *
         * @return string Country name.
         */
        function smarty_modifier_«appName.formatForDB»GetCountryName($countryCode)
        {
            $result = «IF targets('1.3.x')»ZLanguage::getCountryName«ELSE»\Symfony\Component\Intl\Intl::getRegionBundle()->getCountryName«ENDIF»($countryCode);
            if ($result === false) {
                $result = $countryCode;
            }

            return $result;
        }
    '''
}
