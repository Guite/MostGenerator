package org.zikula.modulestudio.generator.cartridges.zclassic.controller.formtype.field

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ColourType {

    extension FormattingExtensions = new FormattingExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    FileHelper fh = new FileHelper

    def generate(Application it, IFileSystemAccess fsa) {
        generateClassPair(fsa, 'Form/Type/Field/ColourType.php',
            fh.phpFileContent(it, colourTypeBaseImpl), fh.phpFileContent(it, colourTypeImpl)
        )
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
            /**
             * @inheritDoc
             */
            public function configureOptions(OptionsResolver $resolver)
            {
                parent::configureOptions($resolver);

                $resolver->setDefaults([
                    'attr' => [
                        'maxlength' => 7,
                        'class' => 'colour-selector'
                    ]
                ]);
            }

            /**
             * @inheritDoc
             */
            public function getParent()
            {
                return TextType::class;
            }

            /**
             * @inheritDoc
             */
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
