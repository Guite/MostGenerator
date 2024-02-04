package org.zikula.modulestudio.generator.cartridges.symfony.controller.formtype.field

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.Utils
import org.zikula.modulestudio.generator.application.ImportList

class TranslationType {

    extension FormattingExtensions = new FormattingExtensions
    extension Utils = new Utils

    def generate(Application it, IMostFileSystemAccess fsa) {
        fsa.generateClassPair('Form/Type/Field/TranslationType.php', translationTypeBaseImpl, translationTypeImpl)
    }

    def private collectBaseImports(Application it) {
        val imports = new ImportList
        imports.addAll(#[
            'Doctrine\\Common\\Collections\\ArrayCollection',
            'Symfony\\Component\\Form\\AbstractType',
            'Symfony\\Component\\Form\\FormBuilderInterface',
            'Symfony\\Component\\Form\\FormInterface',
            'Symfony\\Component\\OptionsResolver\\OptionsResolver',
            appNamespace + '\\Form\\EventListener\\TranslationListener'
        ])
        imports
    }

    def private translationTypeBaseImpl(Application it) '''
        namespace «appNamespace»\Form\Type\Field\Base;

        «collectBaseImports.print»

        /**
         * Translations field type base class.
         */
        abstract class AbstractTranslationType extends AbstractType
        {
            public function __construct(protected readonly TranslationListener $translationListener)
            {
            }

            public function buildForm(FormBuilderInterface $builder, array $options): void
            {
                $builder->addEventSubscriber($this->translationListener);
            }

            public function configureOptions(OptionsResolver $resolver): void
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
