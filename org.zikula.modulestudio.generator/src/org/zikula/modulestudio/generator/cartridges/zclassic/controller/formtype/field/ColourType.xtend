package org.zikula.modulestudio.generator.cartridges.zclassic.controller.formtype.field

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ColourType {
    extension FormattingExtensions = new FormattingExtensions()
    extension NamingExtensions = new NamingExtensions()
    extension Utils = new Utils()

    FileHelper fh = new FileHelper()

    def generate(Application it, IFileSystemAccess fsa) {
        generateClassPair(fsa, getAppSourceLibPath + 'Form/Type/Field/ColourType.php',
            fh.phpFileContent(it, colourTypeBaseImpl), fh.phpFileContent(it, colourTypeImpl)
        )
    }

    def private colourTypeBaseImpl(Application it) '''
        namespace «appNamespace»\Form\Type\Field\Base;

        use PageUtil;
        use Symfony\Component\Form\AbstractType;
        use Symfony\Component\Form\FormInterface;
        use Symfony\Component\Form\FormView;
        use Symfony\Component\OptionsResolver\OptionsResolver;

        /**
         * Colour field type base class.
         *
         * The allowed formats are '#RRGGBB' and '#RGB'.
         */
        class ColourType extends AbstractType
        {
            /**
             * {@inheritdoc}
             */
            public function buildView(FormView $view, FormInterface $form, array $options)
            {
                static $firstTime = true;

                if (
                    (isset($options['disabled']) && $options['disabled'])
                    || (isset($options['attr']) && isset(isset($options['attr']['readonly'])))
                ) {
                    return;
                }

                if ($firstTime) {
                    PageUtil::addVar('stylesheet', 'web/jquery-minicolors/jquery.minicolors.css');
                    PageUtil::addVar('javascript', 'jquery');
                    PageUtil::addVar('javascript', 'web/jquery-minicolors/jquery.minicolors.min.js');
                }
                $firstTime = false;

                $customScript = "<script type=\"text/javascript\">
                    /* <![CDATA[ */
                        ( function($) {
                            $(document).ready(function() {
                                $('#" . $options['attr']['id'] . "').minicolors({theme: 'bootstrap'});
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

                $resolver->setDefaults([
                    'max_length' => 7,
                    'attr' => [
                        'class' => 'colour-selector'
                    ]
                ]);
            }

            /**
             * {@inheritdoc}
             */
            public function getParent()
            {
                return 'Symfony\Component\Form\Extension\Core\Type\TextType';
            }

            /**
             * {@inheritdoc}
             */
            public function getBlockPrefix()
            {
                return '«appName.formatForDB»_field_colour';
            }

            /**
             * {@inheritdoc}
             */
            public function getName()
            {
                return $this->getBlockPrefix();
            }
        }
    '''

    def private colourTypeImpl(Application it) '''
        namespace «appNamespace»\Form\Type\Field;

        use «appNamespace»\Form\Type\Field\Base\ColourType as BaseColourType;

        /**
         * Colour field type implementation class.
         *
         * The allowed formats are '#RRGGBB' and '#RGB'.
         */
        class ColourType extends BaseColourType
        {
            // feel free to add your customisation here
        }
    '''
}
