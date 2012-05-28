package org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class FormCountrySelector {
    @Inject extension FormattingExtensions = new FormattingExtensions()
    @Inject extension NamingExtensions = new NamingExtensions()
    @Inject extension Utils = new Utils()

    FileHelper fh = new FileHelper()

    def generate(Application it, IFileSystemAccess fsa) {
    	val formPluginPath = appName.getAppSourceLibPath + 'Form/Plugin/'
        fsa.generateFile(formPluginPath + 'Base/CountrySelector.php', formCountrySelectorBaseFile)
        fsa.generateFile(formPluginPath + 'CountrySelector.php', formCountrySelectorFile)
        fsa.generateFile(viewPluginFilePath('function', 'CountrySelector'), formCountrySelectorPluginFile)
    }

    def private formCountrySelectorBaseFile(Application it) '''
    	«fh.phpFileHeader(it)»
    	«formCountrySelectorBaseImpl»
    '''

    def private formCountrySelectorFile(Application it) '''
    	«fh.phpFileHeader(it)»
    	«formCountrySelectorImpl»
    '''

    def private formCountrySelectorPluginFile(Application it) '''
    	«fh.phpFileHeader(it)»
    	«formCountrySelectorPluginImpl»
    '''

    def private formCountrySelectorBaseImpl(Application it) '''
        /**
         * This plugin creates a country dropdown list.
         * It understands an optional argument to limit the select options to a given set of allowed countries.
         */
        class «appName»_Form_Plugin_Base_CountrySelector extends Zikula_Form_Plugin_DropdownList
        {
            /**
             * Optional filter for displaying only selected countries in the list.
             */
            protected $validCountryList;

            /**
             * Get filename of this file.
             * The information is used to re-establish the plugins on postback.
             *
             * @return string
             */
            public function getFilename()
            {
                return __FILE__;
            }

            /**
             * Load event handler.
             *
             * @param Zikula_Form_View $view    Reference to Zikula_Form_View object.
             * @param array            &$params Parameters passed from the Smarty plugin function.
             *
             * @return void
             */
            public function load(Zikula_Form_View $view, &$params)
            {
                $this->validCountryList = array();
                $isFiltered = false;
                if (array_key_exists('validCountryList', $params)) {
                    if (is_array($params['validCountryList']) && count($params['validCountryList']) > 0) {
                        $this->validCountryList = $params['validCountryList'];
                        $isFiltered = true;
                    }
                    unset($params['validCountryList']);
                }

                if ($this->mandatory) {
                    $this->addItem('---', null);
                }

                $allCountries = ZLanguage::countryMap();
                foreach ($allCountries as $countryCode => $countryName) {
                    if (!$isFiltered || in_array($countryCode, $this->validCountryList)) {
                        $this->addItem($countryName, $countryCode);
                    }
                }

                parent::load($view, $params);
            }
        }
    '''

    def private formCountrySelectorImpl(Application it) '''
        /**
         * This plugin creates a country dropdown list.
         * It understands an optional argument to limit the select options to a given set of allowed countries.
         */
        class «appName»_Form_Plugin_CountrySelector extends «appName»_Form_Plugin_Base_CountrySelector
        {
            // feel free to add your customisation here
        }
    '''

    def private formCountrySelectorPluginImpl(Application it) '''
        /**
         * The «appName.formatForDB»CountrySelector plugin creates a country dropdown list.
         * It understands an optional argument to limit the select options to a given set of allowed countries.
         *
         * @param  array            $params All attributes passed to this function from the template.
         * @param  Zikula_Form_View $view   Reference to the view object.
         *
         * @return string The output of the plugin.
         */
        function smarty_function_«appName.formatForDB»CountrySelector($params, $view)
        {
            return $view->registerPlugin('«appName»_Form_Plugin_CountrySelector', $params);
        }
    '''
}
