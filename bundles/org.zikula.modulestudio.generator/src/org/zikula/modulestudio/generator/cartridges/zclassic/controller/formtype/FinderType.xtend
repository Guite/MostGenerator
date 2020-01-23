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
            use Translation\Extractor\Annotation\Ignore;
        «ENDIF»
        «IF categorisable»
            use Zikula\CategoriesModule\Form\Type\CategoriesType;
        «ENDIF»
        «IF !app.targets('3.0')»
            use Zikula\Common\Translator\TranslatorInterface;
            use Zikula\Common\Translator\TranslatorTrait;
        «ENDIF»
        «IF app.needsFeatureActivationHelper»
            use «app.appNamespace»\Helper\FeatureActivationHelper;
        «ENDIF»

        /**
         * «name.formatForDisplayCapital» finder form type base class.
         */
        abstract class Abstract«name.formatForCodeCapital»FinderType extends AbstractType
        {
            «IF !app.targets('3.0')»
                use TranslatorTrait;

            «ENDIF»
            «IF app.needsFeatureActivationHelper»
                /**
                 * @var FeatureActivationHelper
                 */
                protected $featureActivationHelper;

            «ENDIF»
            «IF !app.targets('3.0') || app.needsFeatureActivationHelper»
                public function __construct(
                    «IF !app.targets('3.0')»
                        TranslatorInterface $translator«IF app.needsFeatureActivationHelper»,«ENDIF»
                    «ENDIF»
                    «IF app.needsFeatureActivationHelper»
                        FeatureActivationHelper $featureActivationHelper
                    «ENDIF»
                ) {
                    «IF !app.targets('3.0')»
                        $this->setTranslator($translator);
                    «ENDIF»
                    «IF app.needsFeatureActivationHelper»
                        $this->featureActivationHelper = $featureActivationHelper;
                    «ENDIF»
                }

            «ENDIF»
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
                        'label' => «IF !app.targets('3.0')»$this->__(«ENDIF»'Change selection'«IF !app.targets('3.0')»)«ENDIF»,
                        'icon' => 'fa-check',
                        'attr' => [
                            'class' => '«IF !app.targets('3.0')»btn «ENDIF»btn-success'
                        ]
                    ])
                    ->add('cancel', SubmitType::class, [
                        'label' => «IF !app.targets('3.0')»$this->__(«ENDIF»'Cancel'«IF !app.targets('3.0')»)«ENDIF»,
                        «IF app.targets('3.0')»
                            'validate' => false,
                        «ENDIF»
                        'icon' => 'fa-times'«IF !app.targets('3.0')»,
                        'attr' => [
                            'class' => 'btn btn-default',
                            'formnovalidate' => 'formnovalidate'
                        ]«ENDIF»
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
                        'editor_name' => 'ckeditor'«IF app.targets('3.0') && !app.isSystemModule»,
                        'translation_domain' => '«name.formatForCode»'«ENDIF»
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
                'label' => «IF !app.targets('3.0')»$this->__(«ENDIF»'«IF categorisableMultiSelection»Categories«ELSE»Category«ENDIF»:'«IF !app.targets('3.0')»)«ENDIF»,
                'empty_data' => «IF categorisableMultiSelection»[]«ELSE»null«ENDIF»,
                'attr' => [
                    'class' => 'category-selector',
                    'title' => «IF !app.targets('3.0')»$this->__(«ENDIF»'This is an optional filter.'«IF !app.targets('3.0')»)«ENDIF»
                ],
                'help' => «IF !app.targets('3.0')»$this->__(«ENDIF»'This is an optional filter.'«IF !app.targets('3.0')»)«ENDIF»,
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
                'label' => «IF !app.targets('3.0')»$this->__(«ENDIF»'Only images'«IF !app.targets('3.0')»)«ENDIF»,
                «IF app.targets('3.0')»
                    'label_attr' => [
                        'class' => 'switch-custom'
                    ],
                «ENDIF»
                'empty_data' => false,
                'help' => «IF !app.targets('3.0')»$this->__(«ENDIF»'Enable this option to insert images'«IF !app.targets('3.0')»)«ENDIF»,
                'required' => false
            ]);
            «IF imageFieldsEntity.size > 1»
                $builder->add('imageField', ChoiceType::class, [
                    'label' => «IF !app.targets('3.0')»$this->__(«ENDIF»'Image field'«IF !app.targets('3.0')»)«ENDIF»,
                    'empty_data' => '«imageFieldsEntity.head.name.formatForCode»',
                    'help' => «IF !app.targets('3.0')»$this->__(«ENDIF»'You can switch between different image fields'«IF !app.targets('3.0')»)«ENDIF»,
                    'choices' => [
                        «FOR imageField : imageFieldsEntity»
                            «IF !app.targets('3.0')»$this->__(«ENDIF»'«imageField.name.formatForDisplayCapital»'«IF !app.targets('3.0')»)«ENDIF» => '«imageField.name.formatForCode»'«IF imageField != imageFieldsEntity.last»,«ENDIF»
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
                'label' => «IF !app.targets('3.0')»$this->__(«ENDIF»'Paste as:'«IF !app.targets('3.0')»)«ENDIF»,
                'empty_data' => 1,
                'choices' => [
                    «IF hasDisplayAction»
                        «IF !app.targets('3.0')»$this->__(«ENDIF»'Relative link to the «name.formatForDisplay»'«IF !app.targets('3.0')»)«ENDIF» => 1,
                        «IF !app.targets('3.0')»$this->__(«ENDIF»'Absolute url to the «name.formatForDisplay»'«IF !app.targets('3.0')»)«ENDIF» => 2,
                    «ENDIF»
                    «IF !app.targets('3.0')»$this->__(«ENDIF»'ID of «name.formatForDisplay»'«IF !app.targets('3.0')»)«ENDIF» => 3«IF hasImageFieldsEntity»,«ENDIF»
                    «IF hasImageFieldsEntity»
                        «IF !app.targets('3.0')»$this->__(«ENDIF»'Relative link to the image'«IF !app.targets('3.0')»)«ENDIF» => 6,
                        «IF !app.targets('3.0')»$this->__(«ENDIF»'Image'«IF !app.targets('3.0')»)«ENDIF» => 7,
                        «IF !app.targets('3.0')»$this->__(«ENDIF»'Image with relative link to the «name.formatForDisplay»'«IF !app.targets('3.0')»)«ENDIF» => 8,
                        «IF !app.targets('3.0')»$this->__(«ENDIF»'Image with absolute url to the «name.formatForDisplay»'«IF !app.targets('3.0')»)«ENDIF» => 9
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
                    'label' => «IF !app.targets('3.0')»$this->__(«ENDIF»'Sort by:'«IF !app.targets('3.0')»)«ENDIF»,
                    'empty_data' => '',
                    'choices' => [
                        «FOR field : getSortingFields»
                            «IF field.name.formatForCode != 'workflowState' || workflow != EntityWorkflowType.NONE»
                                «IF !app.targets('3.0')»$this->__(«ENDIF»'«field.name.formatForDisplayCapital»'«IF !app.targets('3.0')»)«ENDIF» => '«field.name.formatForCode»'«IF standardFields || field != getDerivedFields.last»,«ENDIF»
                            «ENDIF»
                        «ENDFOR»
                        «IF standardFields»
                            «IF !app.targets('3.0')»$this->__(«ENDIF»'Creation date'«IF !app.targets('3.0')»)«ENDIF» => 'createdDate',
                            «IF !app.targets('3.0')»$this->__(«ENDIF»'Creator'«IF !app.targets('3.0')»)«ENDIF» => 'createdBy',
                            «IF !app.targets('3.0')»$this->__(«ENDIF»'Update date'«IF !app.targets('3.0')»)«ENDIF» => 'updatedDate',
                            «IF !app.targets('3.0')»$this->__(«ENDIF»'Updater'«IF !app.targets('3.0')»)«ENDIF» => 'updatedBy'
                        «ENDIF»
                    ],
                    «IF !app.targets('2.0')»
                        'choices_as_values' => true,
                    «ENDIF»
                    'multiple' => false,
                    'expanded' => false
                ])
                ->add('sortdir', ChoiceType::class, [
                    'label' => «IF !app.targets('3.0')»$this->__(«ENDIF»'Sort direction:'«IF !app.targets('3.0')»)«ENDIF»,
                    'empty_data' => 'asc',
                    'choices' => [
                        «IF !app.targets('3.0')»$this->__(«ENDIF»'Ascending'«IF !app.targets('3.0')»)«ENDIF» => 'asc',
                        «IF !app.targets('3.0')»$this->__(«ENDIF»'Descending'«IF !app.targets('3.0')»)«ENDIF» => 'desc'
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
                'label' => «IF !app.targets('3.0')»$this->__(«ENDIF»'Page size:'«IF !app.targets('3.0')»)«ENDIF»,
                'empty_data' => 20,
                'attr' => [
                    'class' => 'text-right'
                ],
                «IF app.targets('3.0')»
                    /** @Ignore */
                «ENDIF»
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
                'label' => «IF !app.targets('3.0')»$this->__(«ENDIF»'Search for:'«IF !app.targets('3.0')»)«ENDIF»,
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
