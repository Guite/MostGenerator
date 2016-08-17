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

        use Symfony\Component\Form\AbstractType;
        use Symfony\Component\Form\FormInterface;
        use Symfony\Component\Form\FormView;
        use Symfony\Component\OptionsResolver\OptionsResolver;
        use Zikula\ThemeModule\Engine\AssetBag;

        /**
         * Colour field type base class.
         *
         * The allowed formats are '#RRGGBB' and '#RGB'.
         */
        class ColourType extends AbstractType
        {
            /**
             * @var AssetBag
             */
            protected $jsAssetHelper;

            /**
             * @var AssetBag
             */
            protected $cssAssetHelper;

            /**
             * @var AssetBag
             */
            protected $footerAssetHelper;

            /**
             * ColourType constructor.
             *
             * @param AssetBag $jsAssetBag     AssetBag service instance for JS files
             * @param AssetBag $cssAssetBag    AssetBag service instance for CSS files
             * @param AssetBag $footerAssetBag AssetBag service instance for footer code
             */
            public function __construct(AssetBag $jsAssetBag, AssetBag $cssAssetBag, AssetBag $footerAssetBag)
            {
                $this->jsAssetBag = $jsAssetBag;
                $this->cssAssetBag = $cssAssetBag;
                $this->footerAssetBag = $footerAssetBag;
            }

            /**
             * {@inheritdoc}
             */
            public function buildView(FormView $view, FormInterface $form, array $options)
            {
                static $firstTime = true;

                if (
                    (isset($options['disabled']) && $options['disabled'])
                    || (isset($options['attr']) && isset($options['attr']['readonly']))
                ) {
                    return;
                }

                if ($firstTime) {
                    $this->jsAssetBag->add('web/jquery-minicolors/jquery.minicolors.min.js');
                    $this->cssAssetBag->add('web/jquery-minicolors/jquery.minicolors.css');
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

                $this->footerAssetBag->add($customScript);
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
