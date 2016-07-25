package org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.form

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class TimeInput {
    extension FormattingExtensions = new FormattingExtensions()
    extension NamingExtensions = new NamingExtensions()
    extension Utils = new Utils()

    FileHelper fh = new FileHelper()

    // 1.3.x only
    def generate(Application it, IFileSystemAccess fsa) {
        if (!targets('1.3.x')) {
            return
        }
        generateClassPair(fsa, getAppSourceLibPath + 'Form/Plugin/TimeInput.php',
            fh.phpFileContent(it, formTimeInputBaseImpl), fh.phpFileContent(it, formTimeInputImpl)
        )
        if (!shouldBeSkipped(viewPluginFilePath('function', 'TimeInput'))) {
            fsa.generateFile(viewPluginFilePath('function', 'TimeInput'), fh.phpFileContent(it, formTimeInputPluginImpl))
        }
    }

    def private formTimeInputBaseImpl(Application it) '''
        /**
         * Time value input.
         *
         * You can also use all of the features from the Zikula_Form_Plugin_TextInput plugin since
         * the time input inherits from it.
         */
        class «appName»_Form_Plugin_Base_TimeInput extends Zikula_Form_Plugin_TextInput
        {
            /**
             * Flag for switching between 24 and 12 hour mode.
             *
             * @var boolean
             */
            public $use24Hour = true;

            /**
             * Whether to include seconds or not.
             *
             * @var boolean
             */
            public $addSeconds = false;

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
             * @param Zikula_Form_View $view    Reference to Zikula_Form_View object
             * @param array            &$params Parameters passed from the Smarty plugin function
             *
             * @see    Zikula_Form_AbstractPlugin
             *
             * @return void
             */
            public function create(Zikula_Form_View $view, &$params)
            {
                if (isset($params['use24Hour'])) {
                    $this->use24Hour = (bool) $params['use24Hour'];
                } else {
                    $i18n = ZI18n::getInstance();
                    $this->use24Hour = $i18n->locale->getTimeformat() == 24;
                }

                if (isset($params['addSeconds'])) {
                    $this->addSeconds = (bool) $params['addSeconds'];
                }

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

                return str_replace('z-form-text', 'z-form-time', $class);
            }

            /**
             * Render event handler.
             *
             * @param Zikula_Form_View $view Reference to Zikula_Form_View object
             *
             * @return string The rendered output
             */
            public function render(Zikula_Form_View $view)
            {
                include_once 'lib/viewplugins/function.jquery_timepicker.php';

                $params = array(
                    'defaultdate' => $this->text,
                    'displayelement' => $this->getId(),
                    'readonly' => $this->readOnly,
                    'use24hour' => $this->use24Hour
                );

                $result = smarty_function_jquery_timepicker($params, $view);

                // override time format
                $result .= "<script type=\"text/javascript\">
                    /* <![CDATA[ */
                        ( function($) {
                            $(document).ready(function() {
                                $('#" . $this->getId() . "').timepicker({
                                    timeFormat: '" . $this->getTimeFormat() . "',
                                    ampm: false
                                });
                            });
                        })(jQuery);
                    /* ]]> */
                    </script>";

                $attributes = $this->renderAttributes($view) . ' class="' . $this->getStyleClass() . '" ';
                $idNamePattern = 'id=\'' . $this->getId() . '\' name=\'' . $this->getId() . '\' ';
                $result = str_replace($idNamePattern, $idNamePattern . $attributes, $result);

                return $result;
            }

            /**
             * Returns required time format.
             *
             * @return string Time format
             */
            protected function getTimeFormat()
            {
                $format = 'hh:mm';

                if ($this->addSeconds) {
                    $format .= ':ss';
                }

                return $format;
            }

            /**
             * Validates the input.
             *
             * @param Zikula_Form_View $view Reference to Zikula_Form_View object
             *
             * @return void
             */
            public function validate(Zikula_Form_View $view)
            {
                parent::validate($view);

                if (!$this->isValid) {
                    return;
                }

                if ($this->text !== '') {
                    $hourCheck = $this->use24Hour ? '([0-1]?[0-9]|[2][0-3])' : '(1[0-2]|0?[1-9])';
                    $pattern = '/^' . $hourCheck . ':' . '([0-5]?[0-9])' . ($this->addSeconds ? ':([0-5]?[0-9])' : '') . '$/';
                    if (!preg_match($pattern, $this->text)) {
                        $this->setError(__('Error! Invalid time.'));
                    }
                }
            }

            /**
             * Parses a value.
             *
             * @param Zikula_Form_View $view Reference to Zikula_Form_View object
             * @param string           $text Text
             *
             * @return string Parsed text
             */
            public function parseValue(Zikula_Form_View $view, $text)
            {
                if ($text === '') {
                    return null;
                }

                $expectedPartAmount = $this->addslashes ? 3 : 2;

                $textParts = explode(':', $text);
                if (count($textParts) != $expectedPartAmount) {
                    return null;
                }

                if (strlen($textParts[0]) == 1) {
                    $textParts[0] = '0' . $textParts[0];
                }
                if (strlen($textParts[1]) == 1) {
                    $textParts[1] = '0' . $textParts[1];
                }
                if ($this->addSeconds && strlen($textParts[2]) == 1) {
                    $textParts[2] = '0' . $textParts[2];
                }

                $text = implode(':', $textParts);

                return $text;
            }
        }
    '''

    def private formTimeInputImpl(Application it) '''
        /**
         * Time value input.
         *
         * You can also use all of the features from the Zikula_Form_Plugin_TextInput plugin since
         * the time input inherits from it.
         */
        class «appName»_Form_Plugin_TimeInput extends «appName»_Form_Plugin_Base_TimeInput
        {
            // feel free to add your customisation here
        }
    '''

    def private formTimeInputPluginImpl(Application it) '''
        /**
         * The «appName.formatForDB»TimeInput plugin handles fields carrying time data.
         *
         * @param  array            $params All attributes passed to this function from the template
         * @param  Zikula_Form_View $view   Reference to the view object
         *
         * @return string The output of the plugin
         */
        function smarty_function_«appName.formatForDB»TimeInput($params, $view)
        {
            return $view->registerPlugin('«appName»_Form_Plugin_TimeInput', $params);
        }
    '''
}
