package org.zikula.modulestudio.generator.cartridges.zclassic.controller.formtype.field

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class DateTypeExtension {
    extension NamingExtensions = new NamingExtensions()
    extension Utils = new Utils()

    FileHelper fh = new FileHelper()

    def generate(Application it, IFileSystemAccess fsa) {
        generateClassPair(fsa, getAppSourceLibPath + 'Form/Extension/DateTypeExtension.php',
            fh.phpFileContent(it, dateTypeExtensionBaseImpl), fh.phpFileContent(it, dateTypeExtensionImpl)
        )
    }

    def private dateTypeExtensionBaseImpl(Application it) '''
        namespace «appNamespace»\Form\Extension\Base;

        use Symfony\Component\Form\AbstractTypeExtension;
        use Symfony\Component\Form\FormInterface;
        use Symfony\Component\Form\FormView;
        use Symfony\Component\OptionsResolver\OptionsResolver;
        use Zikula_View;

        /**
         * Date field type extension base class.
         */
        class DateTypeExtension extends AbstractTypeExtension
        {
            /**
             * {@inheritdoc}
             */
            public function buildView(FormView $view, FormInterface $form, array $options)
            {
                if ($options['widget'] != 'single_text') {
                    return;
                }

                include_once 'lib/legacy/viewplugins/function.jquery_datepicker.php';

                $readOnly = (
                    (isset($options['disabled']) && $options['disabled'])
                    || (isset($options['attr']) && isset($options['attr']['readonly']))
                );

                list ($dateFormat, $dateFormatJs) = $this->getDateFormat($options);

                $domId = $form->getParent()->getConfig()->getName() . '_' . $form->getConfig()->getName();

                $params = [
                    'defaultdate' => $options['empty_data'],
                    'displayelement' => $domId,
                    'readonly' => $readOnly,
                    'displayformat_datetime' => $dateFormat,
                    'displayformat_javascript' => $dateFormatJs
                ];

                // adds required JavaScript to the footer
                // ignoring the function call result, as Symfony Forms is rendering the actual input field
                smarty_function_jquery_datepicker($params, Zikula_View::getInstance('«appName»'));
            }

            /**
             * {@inheritdoc}
             */
            public function configureOptions(OptionsResolver $resolver)
            {
                $resolver->setDefaults([
                    'max_length' => 10,
                    'attr' => [
                        'class' => 'date-picker'
                    ],
                    'formName' => ''
                ]);
            }

            /**
             * {@inheritdoc}
             */
            public function getExtendedType()
            {
                return 'Symfony\Component\Form\Extension\Core\Type\DateType';
            }

            /**
             * Returns required date formats for PHP date and JavaScript.
             *
             * @param array The options
             *
             * @return array List of date formats
             */
            protected function getDateFormat(array $options)
            {
                $dateFormat = $options['format'] ? $options['format'] : str_replace('%', '', DATEONLYFORMAT_FIXED);
                $dateFormatJs = str_replace(array('Y', 'm', 'd'), array('yy', 'mm', 'dd'), $dateFormat);

                return [$dateFormat, $dateFormatJs];
            }
        }
    '''

    def private dateTypeExtensionImpl(Application it) '''
        namespace «appNamespace»\Form\Extension;

        use «appNamespace»\Form\Extension\Base\DateTypeExtension as BaseDateTypeExtension;

        /**
         * Date field type extension implementation class.
         */
        class DateTypeExtension extends BaseDateTypeExtension
        {
            // feel free to add your customisation here
        }
    '''
}
