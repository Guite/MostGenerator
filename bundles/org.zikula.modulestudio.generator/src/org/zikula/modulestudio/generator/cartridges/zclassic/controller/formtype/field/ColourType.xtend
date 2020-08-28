package org.zikula.modulestudio.generator.cartridges.zclassic.controller.formtype.field

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ColourType {

    extension FormattingExtensions = new FormattingExtensions
    extension Utils = new Utils

    def generate(Application it, IMostFileSystemAccess fsa) {
        if (targets('2.0')) {
            return
        }
        fsa.generateClassPair('Form/Type/Field/ColourType.php', colourTypeBaseImpl, colourTypeImpl)
    }

    def private colourTypeBaseImpl(Application it) '''
        namespace «appNamespace»\Form\Type\Field\Base;

        use Symfony\Component\Form\AbstractType;
        use Symfony\Component\Form\Extension\Core\Type\TextType;
        use Symfony\Component\OptionsResolver\OptionsResolver;

        /**
         * Colour field type base class.
         *
         * The allowed formats are '#RRGGBB' and '#RGB'.
         */
        abstract class AbstractColourType extends AbstractType
        {
            public function configureOptions(OptionsResolver $resolver)
            {
                parent::configureOptions($resolver);

                $resolver->setDefaults([
                    'attr' => [
                        'maxlength' => 7,
                        'class' => 'colour-selector',
                    ],
                ]);
            }

            public function getParent()
            {
                return TextType::class;
            }

            public function getBlockPrefix()
            {
                return '«appName.formatForDB»_field_colour';
            }
        }
    '''

    def private colourTypeImpl(Application it) '''
        namespace «appNamespace»\Form\Type\Field;

        use «appNamespace»\Form\Type\Field\Base\AbstractColourType;

        /**
         * Colour field type implementation class.
         *
         * The allowed formats are '#RRGGBB' and '#RGB'.
         */
        class ColourType extends AbstractColourType
        {
            // feel free to add your customisation here
        }
    '''
}
