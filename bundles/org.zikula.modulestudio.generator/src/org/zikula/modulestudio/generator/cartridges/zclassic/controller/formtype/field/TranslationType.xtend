package org.zikula.modulestudio.generator.cartridges.zclassic.controller.formtype.field

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class TranslationType {

    extension FormattingExtensions = new FormattingExtensions()
    extension NamingExtensions = new NamingExtensions()
    extension Utils = new Utils()

    FileHelper fh = new FileHelper()

    def generate(Application it, IFileSystemAccess fsa) {
        generateClassPair(fsa, getAppSourceLibPath + 'Form/Type/Field/TranslationType.php',
            fh.phpFileContent(it, translationTypeBaseImpl), fh.phpFileContent(it, translationTypeImpl)
        )
    }

    def private translationTypeBaseImpl(Application it) '''
        namespace «appNamespace»\Form\Type\Field\Base;

        use Symfony\Component\Form\AbstractType;
        use Symfony\Component\Form\FormBuilderInterface;
        use Symfony\Component\Form\FormInterface;
        use Symfony\Component\OptionsResolver\OptionsResolver;
        use «appNamespace»\Form\EventListener\TranslationListener;

        /**
         * Translations field type base class.
         */
        abstract class AbstractTranslationType extends AbstractType
        {
            /**
             * @var TranslationListener
             */
            private $translationListener;

            /**
             * TranslationsType constructor.
             */
            public function __construct()
            {
                $this->translationListener = new TranslationListener();
            }

            /**
             * @inheritDoc
             */
            public function buildForm(FormBuilderInterface $builder, array $options)
            {
                $builder->addEventSubscriber($this->translationListener);
            }

            /**
             * @inheritDoc
             */
            public function configureOptions(OptionsResolver $resolver)
            {
                $resolver
                    ->setDefaults([
                        'by_reference' => false,
                        'mapped' => false,
                        'empty_data' => function (FormInterface $form) {
                            return new \Doctrine\Common\Collections\ArrayCollection();
                        },
                        'fields' => [],
                        'mandatory_fields' => [],
                        'values' => []
                    ])
                    ->setRequired(['fields'])
                    ->setOptional(['mandatory_fields', 'values'])
                    ->setAllowedTypes('fields', 'array')
                    ->setAllowedTypes('mandatory_fields', 'array')
                    ->setAllowedTypes('values', 'array')
                ;
            }

            /**
             * @inheritDoc
             */
            public function getBlockPrefix()
            {
                return '«appName.formatForDB»_field_translation';
            }
        }
    '''

    def private translationTypeImpl(Application it) '''
        namespace «appNamespace»\Form\Type\Field;

        use «appNamespace»\Form\Type\Field\Base\AbstractTranslationType;

        /**
         * Translation field type implementation class.
         */
        class TranslationType extends AbstractTranslationType
        {
            // feel free to add your customisation here
        }
    '''
}
