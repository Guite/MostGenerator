package org.zikula.modulestudio.generator.cartridges.zclassic.controller.formtype.field

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ArrayType {

    extension FormattingExtensions = new FormattingExtensions
    extension Utils = new Utils

    def generate(Application it, IMostFileSystemAccess fsa) {
        fsa.generateClassPair('Form/Type/Field/ArrayType.php', arrayTypeBaseImpl, arrayTypeImpl)
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
            public function buildForm(FormBuilderInterface $builder, array $options)
            {
                $transformer = new ArrayFieldTransformer();
                $builder->addModelTransformer($transformer);
            }

            public function getParent(): ?string
            {
                return TextareaType::class;
            }

            public function getBlockPrefix(): string
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
