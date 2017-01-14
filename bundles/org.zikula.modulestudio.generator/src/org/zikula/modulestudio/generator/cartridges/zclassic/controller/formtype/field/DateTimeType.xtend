package org.zikula.modulestudio.generator.cartridges.zclassic.controller.formtype.field

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class DateTimeType {

    extension FormattingExtensions = new FormattingExtensions()
    extension NamingExtensions = new NamingExtensions()
    extension Utils = new Utils()

    FileHelper fh = new FileHelper()

    def generate(Application it, IFileSystemAccess fsa) {
        generateClassPair(fsa, getAppSourceLibPath + 'Form/Type/Field/DateTimeType.php',
            fh.phpFileContent(it, datetimeTypeBaseImpl), fh.phpFileContent(it, datetimeTypeImpl)
        )
    }

    def private datetimeTypeBaseImpl(Application it) '''
        namespace «appNamespace»\Form\Type\Field\Base;

        use Symfony\Component\Form\AbstractType;
        use Symfony\Component\Form\Extension\Core\Type\DateTimeType as SymfonyDateTimeType;
        use Symfony\Component\Form\FormInterface;
        use Symfony\Component\Form\FormView;

        /**
         * Datetime field type base class.
         */
        abstract class AbstractDateTimeType extends AbstractType
        {
            /**
             * {@inheritdoc}
             */
            public function buildView(FormView $view, FormInterface $form, array $options)
            {
                $view->vars['widget'] = $options['widget'];

                // Change the input to a HTML5 datetime input if
                //  * the widget is set to "single_text"
                //  * the format matches the one expected by HTML5
                //  * the html5 is set to true
                if ($options['html5'] && 'single_text' === $options['widget'] && SymfonyDateTimeType::HTML5_FORMAT === $options['format']) {
                    $view->vars['type'] = 'datetime-local';
                }
            }

            /**
             * {@inheritdoc}
             */
            public function getParent()
            {
                return 'Symfony\Component\Form\Extension\Core\Type\DateTimeType';
            }

            /**
             * {@inheritdoc}
             */
            public function getBlockPrefix()
            {
                return '«appName.formatForDB»_field_datetime';
            }
        }
    '''

    def private datetimeTypeImpl(Application it) '''
        namespace «appNamespace»\Form\Type\Field;

        use «appNamespace»\Form\Type\Field\Base\AbstractDateTimeType;

        /**
         * Datetime field type implementation class.
         */
        class DateTimeType extends AbstractDateTimeType
        {
            // feel free to add your customisation here
        }
    '''
}
