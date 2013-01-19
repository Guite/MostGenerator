package org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.form

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ColourInput {
    @Inject extension FormattingExtensions = new FormattingExtensions()
    @Inject extension NamingExtensions = new NamingExtensions()
    @Inject extension Utils = new Utils()

    FileHelper fh = new FileHelper()

    def generate(Application it, IFileSystemAccess fsa) {
    	val formPluginPath = getAppSourceLibPath + 'Form/Plugin/'
        fsa.generateFile(formPluginPath + 'Base/ColourInput.php', formColourInputBaseFile)
        fsa.generateFile(formPluginPath + 'ColourInput.php', formColourInputFile)
        fsa.generateFile(viewPluginFilePath('function', 'ColourInput'), formColourInputPluginFile)
    }

    def private formColourInputBaseFile(Application it) '''
        «fh.phpFileHeader(it)»
        «formColourInputBaseImpl»
    '''

    def private formColourInputFile(Application it) '''
        «fh.phpFileHeader(it)»
        «formColourInputImpl»
    '''

    def private formColourInputPluginFile(Application it) '''
        «fh.phpFileHeader(it)»
        «formColourInputPluginImpl»
    '''

    def private formColourInputBaseImpl(Application it) '''
        «IF !targets('1.3.5')»
            namespace «appName»\Form\Plugin\Base;

        «ENDIF»
        /**
         * Colour field plugin including colour picker.
         *
         * The allowed formats are '#RRGGBB' and '#RGB'.
         *
         * You can also use all of the features from the Zikula_Form_Plugin_TextInput plugin since
         * the colour input inherits from it.
         */
        «IF targets('1.3.5')»
        class «appName»_Form_Plugin_Base_ColourInput extends Zikula_Form_Plugin_TextInput
        «ELSE»
        class ColourInput extends \Zikula_Form_Plugin_TextInput
        «ENDIF»
        {
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
             * Create event handler.
             *
             * @param Zikula_Form_View $view    Reference to Zikula_Form_View object.
             * @param array            &$params Parameters passed from the Smarty plugin function.
             *
             * @see    Zikula_Form_AbstractPlugin
             * @return void
             */
            public function create(Zikula_Form_View $view, &$params)
            {
                $params['maxLength'] = 7;
                $params['width'] = '8em';

                // let parent plugin do the work in detail
                parent::create($view, $params);
            }

            /**
             * Helper method to determine css class.
             *
             * @see Zikula_Form_Plugin_TextInput
             *
             * @return string the list of css classes to apply
             */
            protected function getStyleClass()
            {
                $class = parent::getStyleClass();
                return str_replace('z-form-text', 'z-form-colour', $class);
            }

            /**
             * Render event handler.
             *
             * @param Zikula_Form_View $view Reference to Zikula_Form_View object.
             *
             * @return string The rendered output
             */
            public function render(Zikula_Form_View $view)
            {
                static $firstTime = true;
                if ($firstTime) {
                    PageUtil::addVar('stylesheet', 'javascript/picky_color/picky_color.css');
                    PageUtil::addVar('javascript', 'javascript/picky_color/picky_color.js');
                }
                $firstTime = false;

                $dom = ZLanguage::getModuleDomain('«appName»');

                $result = parent::render($view);

                if ($this->readOnly) {
                    return $result;
                }

                $result .= "<script type=\"text/javascript\">
                    /* <![CDATA[ */
                        var namePicky = new PickyColor({
                            field: '" . $this->getId() . "',
                            color: '" . DataUtil::formatForDisplay($this->text) . "',
                            colorWell: '" . $this->getId() . "',
                            closeText: '" . __('Close', $dom) . "'
                        })
                    /* ]]> */
                    </script>";

                return $result;
            }

            /**
             * Parses a value.
             *
             * @param Zikula_Form_View $view Reference to Zikula_Form_View object.
             * @param string           $text Text.
             *
             * @return string Parsed Text.
             */
            public function parseValue(Zikula_Form_View $view, $text)
            {
                if (empty($text)) {
                    return null;
                }

                return $text;
            }

            /**
             * Validates the input string.
             *
             * @param Zikula_Form_View $view Reference to Zikula_Form_View object.
             *
             * @return boolean
             */
            public function validate(Zikula_Form_View $view)
            {
                parent::validate($view);

                if (!$this->isValid) {
                    return;
                }

                if (strlen($this->text) > 0) {
                    $regex = '/^#?(([a-fA-F0-9]{3}){1,2})$/';
                    $result = preg_match($regex, $this->text);
                    if (!$result) {
                        $this->setError(__('Error! Invalid colour.'));
                        return false;
                    }
                }
            }
        }
    '''

    def private formColourInputImpl(Application it) '''
        «IF !targets('1.3.5')»
            namespace «appName»\Form\Plugin;

        «ENDIF»
        /**
         * Colour field plugin including colour picker.
         *
         * The allowed formats are '#RRGGBB' and '#RGB'.
         *
         * You can also use all of the features from the Zikula_Form_Plugin_TextInput plugin since
         * the colour input inherits from it.
         */
        «IF targets('1.3.5')»
        class «appName»_Form_Plugin_ColourInput extends «appName»_Form_Plugin_Base_ColourInput
        «ELSE»
        class ColourInput extends Base\ColourInput
        «ENDIF»
        {
            // feel free to add your customisation here
        }
    '''

    def private formColourInputPluginImpl(Application it) '''
        /**
         * The «appName.formatForDB»ColourInput plugin handles fields carrying a html colour code.
         * It provides a colour picker for convenient editing.
         *
         * @param array            $params  All attributes passed to this function from the template.
         * @param Zikula_Form_View $view    Reference to the view object.
         *
         * @return string The output of the plugin.
         */
        function smarty_function_«appName.formatForDB»ColourInput($params, $view)
        {
            return $view->registerPlugin('«appName»_Form_Plugin_ColourInput', $params);
        }
    '''
}
