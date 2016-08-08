package org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.form

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class CountrySelector {
    extension FormattingExtensions = new FormattingExtensions()
    extension NamingExtensions = new NamingExtensions()
    extension Utils = new Utils()

    FileHelper fh = new FileHelper()

    // 1.3.x only
    def generate(Application it, IFileSystemAccess fsa) {
        if (!targets('1.3.x')) {
            return
        }
        generateClassPair(fsa, getAppSourceLibPath + 'Form/Plugin/CountrySelector.php',
            fh.phpFileContent(it, formCountrySelectorBaseImpl), fh.phpFileContent(it, formCountrySelectorImpl)
        )
        if (!shouldBeSkipped(viewPluginFilePath('function', 'CountrySelector'))) {
            fsa.generateFile(viewPluginFilePath('function', 'CountrySelector'), fh.phpFileContent(it, formCountrySelectorPluginImpl))
        }
    }

    def private formCountrySelectorBaseImpl(Application it) '''
        «IF !targets('1.3.x')»
            namespace «appNamespace»\Form\Plugin\Base;

            use Zikula_Form_Plugin_DropdownList;
            use Zikula_Form_View;
            use ZLanguage;

        «ENDIF»
        /**
         * This plugin creates a country dropdown list.
         * It understands an optional argument to limit the select options to a given set of allowed countries.
         */
        class «IF targets('1.3.x')»«appName»_Form_Plugin_Base_«ENDIF»CountrySelector extends Zikula_Form_Plugin_DropdownList
        {
            /**
             * Optional filter for displaying only certain countries in the list.
             *
             * @var array
             */
            public $validCountryList;

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
             * @param Zikula_Form_View $view    Reference to Zikula_Form_View object
             * @param array            &$params Parameters passed from the Smarty plugin function
             *
             * @return void
             */
            public function load(Zikula_Form_View $view, &$params)
            {
                $this->validCountryList = «IF targets('1.3.x')»array()«ELSE»[]«ENDIF»;
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

                «IF targets('1.3.x')»
                    $allCountries = ZLanguage::countrymap();
                «ELSE»
                    $allCountries = \Symfony\Component\Intl\Intl::getRegionBundle()->getCountryNames();
                «ENDIF»
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
        «IF !targets('1.3.x')»
            namespace «appNamespace»\Form\Plugin;

            use «appNamespace»\Form\Plugin\Base\CountrySelector as BaseCountrySelector;

        «ENDIF»
        /**
         * This plugin creates a country dropdown list.
         * It understands an optional argument to limit the select options to a given set of allowed countries.
         */
        «IF targets('1.3.x')»
        class «appName»_Form_Plugin_CountrySelector extends «appName»_Form_Plugin_Base_CountrySelector
        «ELSE»
        class CountrySelector extends BaseCountrySelector
        «ENDIF»
        {
            // feel free to add your customisation here
        }
    '''

    def private formCountrySelectorPluginImpl(Application it) '''
        /**
         * The «appName.formatForDB»CountrySelector plugin creates a country dropdown list.
         * It understands an optional argument to limit the select options to a given set of allowed countries.
         *
         * @param array            $params All attributes passed to this function from the template
         * @param Zikula_Form_View $view   Reference to the view object
         *
         * @return string The output of the plugin
         */
        function smarty_function_«appName.formatForDB»CountrySelector($params, $view)
        {
            return $view->registerPlugin('«IF targets('1.3.x')»«appName»_Form_Plugin_CountrySelector«ELSE»\\«vendor.formatForCodeCapital»\\«name.formatForCodeCapital»Module\\Form\\Plugin\\CountrySelector«ENDIF»', $params);
        }
    '''
}
