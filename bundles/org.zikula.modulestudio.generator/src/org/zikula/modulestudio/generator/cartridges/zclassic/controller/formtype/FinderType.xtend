package org.zikula.modulestudio.generator.cartridges.zclassic.controller.formtype

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.EntityWorkflowType
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class FinderType {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelExtensions = new ModelExtensions
    extension Utils = new Utils

    Application app
    String nsSymfonyFormType = 'Symfony\\Component\\Form\\Extension\\Core\\Type\\'

    /**
     * Entry point for entity finder form type.
     */
    def generate(Application it, IMostFileSystemAccess fsa) {
        if (!generateExternalControllerAndFinder || !hasDisplayActions) {
            return
        }
        app = it
        for (entity : getFinderEntities) {
            fsa.generateClassPair('Form/Type/Finder/' + entity.name.formatForCodeCapital + 'FinderType.php',
                entity.finderTypeBaseImpl, entity.finderTypeImpl
            )
        }
    }

    def private finderTypeBaseImpl(Entity it) '''
        namespace «app.appNamespace»\Form\Type\Finder\Base;

        use Symfony\Component\Form\AbstractType;
        «IF hasImageFieldsEntity»
            use «nsSymfonyFormType»CheckboxType;
        «ENDIF»
        use «nsSymfonyFormType»ChoiceType;
        use «nsSymfonyFormType»HiddenType;
        use «nsSymfonyFormType»SearchType;
        use «nsSymfonyFormType»SubmitType;
        use Symfony\Component\Form\FormBuilderInterface;
        use Symfony\Component\HttpFoundation\RequestStack;
        use Symfony\Component\OptionsResolver\OptionsResolver;
        use Translation\Extractor\Annotation\Ignore;
        use Zikula\Bundle\FormExtensionBundle\Form\Type\LocaleType;
        «IF categorisable»
            use Zikula\CategoriesModule\Form\Type\CategoriesType;
        «ENDIF»
        use Zikula\ExtensionsModule\Api\ApiInterface\VariableApiInterface;
        «IF app.needsFeatureActivationHelper»
            use «app.appNamespace»\Helper\FeatureActivationHelper;
        «ENDIF»

        /**
         * «name.formatForDisplayCapital» finder form type base class.
         */
        abstract class Abstract«name.formatForCodeCapital»FinderType extends AbstractType
        {
            public function __construct(
                protected RequestStack $requestStack,
                protected VariableApiInterface $variableApi«IF app.needsFeatureActivationHelper»,
                protected FeatureActivationHelper $featureActivationHelper
                «ENDIF»
            ) {
            }

            public function buildForm(FormBuilderInterface $builder, array $options)
            {
                $builder
                    ->setMethod('GET')
                    ->add('objectType', HiddenType::class, [
                        'data' => $options['object_type'],
                    ])
                    ->add('editor', HiddenType::class, [
                        'data' => $options['editor_name'],
                    ])
                ;

                if ($this->variableApi->getSystemVar('multilingual')) {
                    $this->addLanguageField($builder, $options);
                }
                «IF categorisable»
                    if ($this->featureActivationHelper->isEnabled(FeatureActivationHelper::CATEGORIES, $options['object_type'])) {
                        $this->addCategoriesField($builder, $options);
                    }
                «ENDIF»
                «IF hasImageFieldsEntity»
                    $this->addImageFields($builder, $options);
                «ENDIF»
                $this->addPasteAsField($builder, $options);
                $this->addSortingFields($builder, $options);
                $this->addAmountField($builder, $options);
                $this->addSearchField($builder, $options);

                $builder
                    ->add('update', SubmitType::class, [
                        'label' => 'Change selection',
                        'icon' => 'fa-check',
                        'attr' => [
                            'class' => 'btn-success',
                        ],
                    ])
                    ->add('cancel', SubmitType::class, [
                        'label' => 'Cancel',
                        'validate' => false,
                        'icon' => 'fa-times',
                    ])
                ;
            }

            «addLanguageField»

            «IF categorisable»
                «addCategoriesField»

            «ENDIF»
            «IF hasImageFieldsEntity»
                «addImageFields»

            «ENDIF»
            «addPasteAsField»

            «addSortingFields»

            «addAmountField»

            «addSearchField»

            public function getBlockPrefix()
            {
                return '«app.appName.formatForDB»_«name.formatForDB»finder';
            }

            public function configureOptions(OptionsResolver $resolver)
            {
                $resolver
                    ->setDefaults([
                        'object_type' => '«app.leadingEntity.name.formatForCode»',
                        'editor_name' => 'ckeditor',
                        «IF !app.isSystemModule»
                            'translation_domain' => '«name.formatForCode»',
                        «ENDIF»
                    ])
                    ->setRequired(['object_type', 'editor_name'])
                    ->setAllowedTypes('object_type', 'string')
                    ->setAllowedTypes('editor_name', 'string')
                    ->setAllowedValues('editor_name', ['ckeditor', 'quill', 'summernote', 'tinymce'])
                ;
            }
        }
    '''

    def private addLanguageField(Entity it) '''
        /**
         * Adds a language field.
         */
        public function addLanguageField(FormBuilderInterface $builder, array $options = [])
        {
            $builder->add('language', LocaleType::class, [
                'label' => 'Language',
                'data' => $this->requestStack->getCurrentRequest()->getLocale(),
                'empty_data' => null,
                'multiple' => false,
                'expanded' => false,
            ]);
        }
    '''

    def private addCategoriesField(Entity it) '''
        /**
         * Adds a categories field.
         */
        public function addCategoriesField(FormBuilderInterface $builder, array $options = []): void
        {
            $entityCategoryClass = '«app.appNamespace»\Entity\\' . ucfirst($options['object_type']) . 'CategoryEntity';
            $builder->add('categories', CategoriesType::class, [
                'label' => '«IF categorisableMultiSelection»Categories«ELSE»Category«ENDIF»',
                'empty_data' => «IF categorisableMultiSelection»[]«ELSE»null«ENDIF»,
                'attr' => [
                    'class' => 'category-selector',
                    'title' => 'This is an optional filter.',
                ],
                'help' => 'This is an optional filter.',
                'required' => false,
                'multiple' => «categorisableMultiSelection.displayBool»,
                'module' => '«app.appName»',
                'entity' => ucfirst($options['object_type']) . 'Entity',
                'entityCategoryClass' => $entityCategoryClass,
                'showRegistryLabels' => true,
            ]);
        }
    '''

    def private addImageFields(Entity it) '''
        /**
         * Adds fields for image insertion options.
         */
        public function addImageFields(FormBuilderInterface $builder, array $options = []): void
        {
            $builder->add('onlyImages', CheckboxType::class, [
                'label' => 'Only images',
                'label_attr' => [
                    'class' => 'switch-custom',
                ],
                'empty_data' => false,
                'help' => 'Enable this option to insert images',
                'required' => false,
            ]);
            «IF imageFieldsEntity.size > 1»
                $builder->add('imageField', ChoiceType::class, [
                    'label' => 'Image field',
                    'empty_data' => '«imageFieldsEntity.head.name.formatForCode»',
                    'help' => 'You can switch between different image fields',
                    'choices' => [
                        «FOR imageField : imageFieldsEntity»
                            '«imageField.name.formatForDisplayCapital»' => '«imageField.name.formatForCode»',
                        «ENDFOR»
                    ],
                    'multiple' => false,
                    'expanded' => false,
                ]);
            «ELSE»
                $builder->add('imageField', HiddenType::class, [
                    'data' => '«imageFieldsEntity.head.name.formatForCode»',
                ]);
            «ENDIF»
        }
    '''

    def private addPasteAsField(Entity it) '''
        /**
         * Adds a "paste as" field.
         */
        public function addPasteAsField(FormBuilderInterface $builder, array $options = []): void
        {
            $builder->add('pasteAs', ChoiceType::class, [
                'label' => 'Paste as',
                'empty_data' => 1,
                'choices' => [
                    «IF hasDisplayAction»
                        'Relative link to the «name.formatForDisplay»' => 1,
                        'Absolute url to the «name.formatForDisplay»' => 2,
                    «ENDIF»
                    'ID of «name.formatForDisplay»' => 3,
                    «IF hasImageFieldsEntity»
                        'Relative link to the image' => 6,
                        'Image' => 7,
                        'Image with relative link to the «name.formatForDisplay»' => 8,
                        'Image with absolute url to the «name.formatForDisplay»' => 9,
                    «ENDIF»
                ],
                'multiple' => false,
                'expanded' => false,
            ]);
        }
    '''

    def private addSortingFields(Entity it) '''
        /**
         * Adds sorting fields.
         */
        public function addSortingFields(FormBuilderInterface $builder, array $options = []): void
        {
            $builder
                ->add('sort', ChoiceType::class, [
                    'label' => 'Sort by',
                    'empty_data' => '',
                    'choices' => [
                        «FOR field : getSortingFields»
                            «IF field.name.formatForCode != 'workflowState' || workflow != EntityWorkflowType.NONE»
                                '«field.name.formatForDisplayCapital»' => '«field.name.formatForCode»',
                            «ENDIF»
                        «ENDFOR»
                        «IF standardFields»
                            'Creation date' => 'createdDate',
                            'Creator' => 'createdBy',
                            'Update date' => 'updatedDate',
                            'Updater' => 'updatedBy',
                        «ENDIF»
                    ],
                    'multiple' => false,
                    'expanded' => false,
                ])
                ->add('sortdir', ChoiceType::class, [
                    'label' => 'Sort direction',
                    'empty_data' => 'asc',
                    'choices' => [
                        'Ascending' => 'asc',
                        'Descending' => 'desc',
                    ],
                    'multiple' => false,
                    'expanded' => false,
                ])
            ;
        }
    '''

    def private addAmountField(Entity it) '''
        /**
         * Adds a page size field.
         */
        public function addAmountField(FormBuilderInterface $builder, array $options = []): void
        {
            $builder->add('num', ChoiceType::class, [
                'label' => 'Page size',
                'empty_data' => 20,
                'attr' => [
                    'class' => 'text-right',
                ],
                /** @Ignore */
                'choices' => [
                    5 => 5,
                    10 => 10,
                    15 => 15,
                    20 => 20,
                    30 => 30,
                    50 => 50,
                    100 => 100,
                ],
                'multiple' => false,
                'expanded' => false,
            ]);
        }
    '''

    def private addSearchField(Entity it) '''
        /**
         * Adds a search field.
         */
        public function addSearchField(FormBuilderInterface $builder, array $options = []): void
        {
            $builder->add('q', SearchType::class, [
                'label' => 'Search for',
                'required' => false,
                'attr' => [
                    'maxlength' => 255,
                ],
            ]);
        }
    '''

    def private finderTypeImpl(Entity it) '''
        namespace «app.appNamespace»\Form\Type\Finder;

        use «app.appNamespace»\Form\Type\Finder\Base\Abstract«name.formatForCodeCapital»FinderType;

        /**
         * «name.formatForDisplayCapital» finder form type implementation class.
         */
        class «name.formatForCodeCapital»FinderType extends Abstract«name.formatForCodeCapital»FinderType
        {
            // feel free to extend the base form type class here
        }
    '''
}
