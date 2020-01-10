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
        use Symfony\Component\OptionsResolver\OptionsResolver;
        «IF app.targets('3.0')»
            use Symfony\Contracts\Translation\TranslatorInterface;
        «ENDIF»
        «IF categorisable»
            use Zikula\CategoriesModule\Form\Type\CategoriesType;
        «ENDIF»
        «IF !app.targets('3.0')»
            use Zikula\Common\Translator\TranslatorInterface;
        «ENDIF»
        use Zikula\Common\Translator\TranslatorTrait;
        «IF app.needsFeatureActivationHelper»
            use «app.appNamespace»\Helper\FeatureActivationHelper;
        «ENDIF»

        /**
         * «name.formatForDisplayCapital» finder form type base class.
         */
        abstract class Abstract«name.formatForCodeCapital»FinderType extends AbstractType
        {
            use TranslatorTrait;
            «IF app.needsFeatureActivationHelper»

                /**
                 * @var FeatureActivationHelper
                 */
                protected $featureActivationHelper;
            «ENDIF»

            public function __construct(
                TranslatorInterface $translator«IF app.needsFeatureActivationHelper»,
                FeatureActivationHelper $featureActivationHelper«ENDIF»
            ) {
                $this->setTranslator($translator);
                «IF app.needsFeatureActivationHelper»
                    $this->featureActivationHelper = $featureActivationHelper;
                «ENDIF»
            }
            «IF !app.targets('3.0')»

                «app.setTranslatorMethod»
            «ENDIF»

            public function buildForm(FormBuilderInterface $builder, array $options)
            {
                $builder
                    ->setMethod('GET')
                    ->add('objectType', HiddenType::class, [
                        'data' => $options['object_type']
                    ])
                    ->add('editor', HiddenType::class, [
                        'data' => $options['editor_name']
                    ])
                ;

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
                        'label' => $this->«IF app.targets('3.0')»trans«ELSE»__«ENDIF»('Change selection'),
                        'icon' => 'fa-check',
                        'attr' => [
                            'class' => 'btn btn-success'
                        ]
                    ])
                    ->add('cancel', SubmitType::class, [
                        'label' => $this->«IF app.targets('3.0')»trans«ELSE»__«ENDIF»('Cancel'),
                        «IF app.targets('3.0')»
                            'validate' => false,
                        «ENDIF»
                        'icon' => 'fa-times',
                        'attr' => [
                            'class' => 'btn btn-default'«IF !app.targets('3.0')»,
                            'formnovalidate' => 'formnovalidate'«ENDIF»
                        ]
                    ])
                ;
            }

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
                        'editor_name' => 'ckeditor'
                    ])
                    ->setRequired(['object_type', 'editor_name'])
                    ->setAllowedTypes('object_type', 'string')
                    ->setAllowedTypes('editor_name', 'string')
                    ->setAllowedValues('editor_name', ['ckeditor', 'quill', 'summernote', 'tinymce'])
                ;
            }
        }
    '''

    def private addCategoriesField(Entity it) '''
        /**
         * Adds a categories field.
         */
        public function addCategoriesField(FormBuilderInterface $builder, array $options = [])«IF app.targets('3.0')»: void«ENDIF»
        {
            $entityCategoryClass = '«app.appNamespace»\Entity\\' . ucfirst($options['object_type']) . 'CategoryEntity';
            $builder->add('categories', CategoriesType::class, [
                'label' => $this->«IF app.targets('3.0')»trans«ELSE»__«ENDIF»('«IF categorisableMultiSelection»Categories«ELSE»Category«ENDIF»') . ':',
                'empty_data' => «IF categorisableMultiSelection»[]«ELSE»null«ENDIF»,
                'attr' => [
                    'class' => 'category-selector',
                    'title' => $this->«IF app.targets('3.0')»trans«ELSE»__«ENDIF»('This is an optional filter.')
                ],
                'help' => $this->«IF app.targets('3.0')»trans«ELSE»__«ENDIF»('This is an optional filter.'),
                'required' => false,
                'multiple' => «categorisableMultiSelection.displayBool»,
                'module' => '«app.appName»',
                'entity' => ucfirst($options['object_type']) . 'Entity',
                'entityCategoryClass' => $entityCategoryClass,
                'showRegistryLabels' => true
            ]);
        }
    '''

    def private addImageFields(Entity it) '''
        /**
         * Adds fields for image insertion options.
         */
        public function addImageFields(FormBuilderInterface $builder, array $options = [])«IF app.targets('3.0')»: void«ENDIF»
        {
            $builder->add('onlyImages', CheckboxType::class, [
                'label' => $this->«IF app.targets('3.0')»trans«ELSE»__«ENDIF»('Only images'),
                «IF app.targets('3.0')»
                    'label_attr' => [
                        'class' => 'switch-custom'
                    ],
                «ENDIF»
                'empty_data' => false,
                'help' => $this->«IF app.targets('3.0')»trans«ELSE»__«ENDIF»('Enable this option to insert images'),
                'required' => false
            ]);
            «IF imageFieldsEntity.size > 1»
                $builder->add('imageField', ChoiceType::class, [
                    'label' => $this->«IF app.targets('3.0')»trans«ELSE»__«ENDIF»('Image field'),
                    'empty_data' => '«imageFieldsEntity.head.name.formatForCode»',
                    'help' => $this->«IF app.targets('3.0')»trans«ELSE»__«ENDIF»('You can switch between different image fields'),
                    'choices' => [
                        «FOR imageField : imageFieldsEntity»
                            $this->«IF app.targets('3.0')»trans«ELSE»__«ENDIF»('«imageField.name.formatForDisplayCapital»') => '«imageField.name.formatForCode»'«IF imageField != imageFieldsEntity.last»,«ENDIF»
                        «ENDFOR»
                    ],
                    «IF !app.targets('2.0')»
                        'choices_as_values' => true,
                    «ENDIF»
                    'multiple' => false,
                    'expanded' => false
                ]);
            «ELSE»
                $builder->add('imageField', HiddenType::class, [
                    'data' => '«imageFieldsEntity.head.name.formatForCode»'
                ]);
            «ENDIF»
        }
    '''

    def private addPasteAsField(Entity it) '''
        /**
         * Adds a "paste as" field.
         */
        public function addPasteAsField(FormBuilderInterface $builder, array $options = [])«IF app.targets('3.0')»: void«ENDIF»
        {
            $builder->add('pasteAs', ChoiceType::class, [
                'label' => $this->«IF app.targets('3.0')»trans«ELSE»__«ENDIF»('Paste as') . ':',
                'empty_data' => 1,
                'choices' => [
                    «IF hasDisplayAction»
                        $this->«IF app.targets('3.0')»trans«ELSE»__«ENDIF»('Relative link to the «name.formatForDisplay»') => 1,
                        $this->«IF app.targets('3.0')»trans«ELSE»__«ENDIF»('Absolute url to the «name.formatForDisplay»') => 2,
                    «ENDIF»
                    $this->«IF app.targets('3.0')»trans«ELSE»__«ENDIF»('ID of «name.formatForDisplay»') => 3«IF hasImageFieldsEntity»,«ENDIF»
                    «IF hasImageFieldsEntity»
                        $this->«IF app.targets('3.0')»trans«ELSE»__«ENDIF»('Relative link to the image') => 6,
                        $this->«IF app.targets('3.0')»trans«ELSE»__«ENDIF»('Image') => 7,
                        $this->«IF app.targets('3.0')»trans«ELSE»__«ENDIF»('Image with relative link to the «name.formatForDisplay»') => 8,
                        $this->«IF app.targets('3.0')»trans«ELSE»__«ENDIF»('Image with absolute url to the «name.formatForDisplay»') => 9
                    «ENDIF»
                ],
                «IF !app.targets('2.0')»
                    'choices_as_values' => true,
                «ENDIF»
                'multiple' => false,
                'expanded' => false
            ]);
        }
    '''

    def private addSortingFields(Entity it) '''
        /**
         * Adds sorting fields.
         */
        public function addSortingFields(FormBuilderInterface $builder, array $options = [])«IF app.targets('3.0')»: void«ENDIF»
        {
            $builder
                ->add('sort', ChoiceType::class, [
                    'label' => $this->«IF app.targets('3.0')»trans«ELSE»__«ENDIF»('Sort by') . ':',
                    'empty_data' => '',
                    'choices' => [
                        «FOR field : getSortingFields»
                            «IF field.name.formatForCode != 'workflowState' || workflow != EntityWorkflowType.NONE»
                                $this->«IF app.targets('3.0')»trans«ELSE»__«ENDIF»('«field.name.formatForDisplayCapital»') => '«field.name.formatForCode»'«IF standardFields || field != getDerivedFields.last»,«ENDIF»
                            «ENDIF»
                        «ENDFOR»
                        «IF standardFields»
                            $this->«IF app.targets('3.0')»trans«ELSE»__«ENDIF»('Creation date') => 'createdDate',
                            $this->«IF app.targets('3.0')»trans«ELSE»__«ENDIF»('Creator') => 'createdBy',
                            $this->«IF app.targets('3.0')»trans«ELSE»__«ENDIF»('Update date') => 'updatedDate',
                            $this->«IF app.targets('3.0')»trans«ELSE»__«ENDIF»('Updater') => 'updatedBy'
                        «ENDIF»
                    ],
                    «IF !app.targets('2.0')»
                        'choices_as_values' => true,
                    «ENDIF»
                    'multiple' => false,
                    'expanded' => false
                ])
                ->add('sortdir', ChoiceType::class, [
                    'label' => $this->«IF app.targets('3.0')»trans«ELSE»__«ENDIF»('Sort direction') . ':',
                    'empty_data' => 'asc',
                    'choices' => [
                        $this->«IF app.targets('3.0')»trans«ELSE»__«ENDIF»('Ascending') => 'asc',
                        $this->«IF app.targets('3.0')»trans«ELSE»__«ENDIF»('Descending') => 'desc'
                    ],
                    «IF !app.targets('2.0')»
                        'choices_as_values' => true,
                    «ENDIF»
                    'multiple' => false,
                    'expanded' => false
                ])
            ;
        }
    '''

    def private addAmountField(Entity it) '''
        /**
         * Adds a page size field.
         */
        public function addAmountField(FormBuilderInterface $builder, array $options = [])«IF app.targets('3.0')»: void«ENDIF»
        {
            $builder->add('num', ChoiceType::class, [
                'label' => $this->«IF app.targets('3.0')»trans«ELSE»__«ENDIF»('Page size') . ':',
                'empty_data' => 20,
                'attr' => [
                    'class' => 'text-right'
                ],
                'choices' => [
                    5 => 5,
                    10 => 10,
                    15 => 15,
                    20 => 20,
                    30 => 30,
                    50 => 50,
                    100 => 100
                ],
                «IF !app.targets('2.0')»
                    'choices_as_values' => true,
                «ENDIF»
                'multiple' => false,
                'expanded' => false
            ]);
        }
    '''

    def private addSearchField(Entity it) '''
        /**
         * Adds a search field.
         */
        public function addSearchField(FormBuilderInterface $builder, array $options = [])«IF app.targets('3.0')»: void«ENDIF»
        {
            $builder->add('q', SearchType::class, [
                'label' => $this->«IF app.targets('3.0')»trans«ELSE»__«ENDIF»('Search for') . ':',
                'required' => false,
                'attr' => [
                    'maxlength' => 255
                ]
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
