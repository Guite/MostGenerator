package org.zikula.modulestudio.generator.cartridges.zclassic.controller.formtype.field

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ArrayType {

    extension FormattingExtensions = new FormattingExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    FileHelper fh = new FileHelper

    def generate(Application it, IFileSystemAccess fsa) {
        generateClassPair(fsa, getAppSourceLibPath + 'Form/Type/Field/ArrayType.php',
            fh.phpFileContent(it, arrayTypeBaseImpl), fh.phpFileContent(it, arrayTypeImpl)
        )
    }

    def private arrayTypeBaseImpl(Application it) '''
        namespace «appNamespace»\Form\Type\Field\Base;

        use Symfony\Component\Form\AbstractType;
        use Symfony\Component\Form\Extension\Core\Type\TextareaType;
        use Symfony\Component\Form\FormBuilderInterface;
        use «appNamespace»\Form\DataTransformer\ArrayFieldTransformer;

        /**
         * Array field type base class.
         */
        abstract class AbstractArrayType extends AbstractType
        {
            /**
             * @inheritDoc
             */
            public function buildForm(FormBuilderInterface $builder, array $options)
            {
                $transformer = new ArrayFieldTransformer();
                $builder->addModelTransformer($transformer);
            }

            /**
             * @inheritDoc
             */
            public function getParent()
            {
                return TextareaType::class;
            }

            /**
             * @inheritDoc
             */
            public function getBlockPrefix()
            {
                return '«appName.formatForDB»_field_array';
            }
        }
    '''

    def private arrayTypeImpl(Application it) '''
        namespace «appNamespace»\Form\Type\Field;

        use «appNamespace»\Form\Type\Field\Base\AbstractArrayType;

        /**
         * Array field type implementation class.
         */
        class ArrayType extends AbstractArrayType
        {
            // feel free to add your customisation here
        }
    '''
}
