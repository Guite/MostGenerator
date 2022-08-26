package org.zikula.modulestudio.generator.cartridges.zclassic.controller.formtype.field

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class TranslationType {

    extension FormattingExtensions = new FormattingExtensions
    extension Utils = new Utils

    def generate(Application it, IMostFileSystemAccess fsa) {
        fsa.generateClassPair('Form/Type/Field/TranslationType.php', translationTypeBaseImpl, translationTypeImpl)
    }

    def private translationTypeBaseImpl(Application it) '''
        namespace «appNamespace»\Form\Type\Field\Base;

        use Doctrine\Common\Collections\ArrayCollection;
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
            public function __construct(protected readonly TranslationListener $translationListener)
            {
            }

            public function buildForm(FormBuilderInterface $builder, array $options)
            {
                $builder->addEventSubscriber($this->translationListener);
            }

            public function configureOptions(OptionsResolver $resolver)
            {
                $resolver
                    ->setDefaults([
                        'by_reference' => false,
                        'mapped' => false,
                        'empty_data' => static function (FormInterface $form) {
                            return new ArrayCollection();
                        },
                        'fields' => [],
                        'mandatory_fields' => [],
                        'values' => [],
                    ])
                    ->setRequired(['fields'])
                    ->setDefined(['mandatory_fields', 'values'])
                    ->setAllowedTypes('fields', 'array')
                    ->setAllowedTypes('mandatory_fields', 'array')
                    ->setAllowedTypes('values', 'array')
                ;
            }

            public function getBlockPrefix(): string
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
