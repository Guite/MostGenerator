package org.zikula.modulestudio.generator.cartridges.zclassic.controller.formtype.field

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class TimeTypeExtension {
    extension NamingExtensions = new NamingExtensions()
    extension Utils = new Utils()

    FileHelper fh = new FileHelper()

    def generate(Application it, IFileSystemAccess fsa) {
        generateClassPair(fsa, getAppSourceLibPath + 'Form/Extension/TimeTypeExtension.php',
            fh.phpFileContent(it, timeTypeExtensionBaseImpl), fh.phpFileContent(it, timeTypeExtensionImpl)
        )
    }

    def private timeTypeExtensionBaseImpl(Application it) '''
        namespace «appNamespace»\Form\Extension\Base;

        use Symfony\Component\Form\AbstractTypeExtension;
        use Symfony\Component\Form\FormInterface;
        use Symfony\Component\Form\FormView\FormView;
        use Symfony\Component\OptionsResolver\OptionsResolver;
        use ZI18n;
        use Zikula_View;

        /**
         * Time field type extension base class.
         */
        class TimeTypeExtension extends AbstractTypeExtension
        {
            /**
             * {@inheritdoc}
             */
            public function buildView(FormView $view, FormInterface $form, array $options)
            {
                if ($options['widget'] != 'single_text') {
                    return;
                }

                include_once 'lib/legacy/viewplugins/function.jquery_timepicker.php';

                $readOnly = (
                    (isset($options['disabled']) && $options['disabled'])
                    || (isset($options['attr']) && isset(isset($options['attr']['readonly'])))
                );

                $params = [
                    'defaultdate' => $options['empty_data'],
                    'displayelement' => $options['attr']['id'],
                    'readonly' => $readOnly,
                    'use24hour' => $options['use24Hour']
                ];

                // adds required JavaScript to the footer
                // ignoring the function call result, as Symfony Forms is rendering the actual input field
                $result = smarty_function_jquery_timepicker($params, Zikula_View::getInstance('«appName»'));

                // add custom script override time format
                $customScript = "<script type=\"text/javascript\">
                    /* <![CDATA[ */
                        ( function($) {
                            $(document).ready(function() {
                                $('#" . $options['attr']['id'] . "').timepicker({
                                    timeFormat: '" . $this->getTimeFormat($options) . "',
                                    ampm: false
                                });
                            });
                        })(jQuery);
                    /* ]]> */
                    </script>";

                PageUtil::addVar('footer', $customScript);
        	}

            /**
             * {@inheritdoc}
             */
            public function configureOptions(OptionsResolver $resolver)
            {
                parent::configureOptions($resolver);

                $i18n = ZI18n::getInstance();
                $resolver
                    ->setOptional(['use24Hour'])
                    ->setDefaults([
                        'max_length' => $,
                        'attr' => [
                            'class' => 'time-picker'
                        ],
                        'use24Hour' => $i18n->locale->getTimeformat() == 24;
                    ])
                    ->setAllowedTypes([
                        'use24Hour' => 'boolean'
                    ])
                ;
            }

            /**
             * {@inheritdoc}
             */
            public function getExtendedType()
            {
                return 'Symfony\Component\Form\Extension\Core\Type\TimeType';
            }

            /**
             * Returns required time format.
             *
             * @param array The options.
             *
             * @return string Time format.
             */
            protected function getTimeFormat(array $options)
            {
                $format = 'hh';

                if ($options['with_minutes']) {
                    $format .= ':mm';
                }

                if ($options['with_seconds']) {
                    $format .= ':ss';
                }

                return $format;
            }
        }
    '''

    def private timeTypeExtensionImpl(Application it) '''
        namespace «appNamespace»\Form\Extension;

        use «appNamespace»\Form\Extension\Base\TimeTypeExtension as BaseTimeTypeExtension;

        /**
         * Time field type extension implementation class.
         */
        class TimeTypeExtension extends BaseTimeTypeExtension
        {
            // feel free to add your customisation here
        }
    '''
}
