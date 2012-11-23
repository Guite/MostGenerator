package org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class GetCountryName {
    @Inject extension FormattingExtensions = new FormattingExtensions()
    @Inject extension NamingExtensions = new NamingExtensions()
    @Inject extension Utils = new Utils()

    def generate(Application it, IFileSystemAccess fsa) {
        fsa.generateFile(viewPluginFilePath('modifier', 'GetCountryName'), getCountryNameFile)
    }

    def private getCountryNameFile(Application it) '''
    	«new FileHelper().phpFileHeader(it)»
    	«getCountryNameImpl»
    '''

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
            $result = ZLanguage::getCountryName($countryCode);
            if ($result === false) {
                $result = $countryCode;
            }

            return $result;
        }
    '''
}
