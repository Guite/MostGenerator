package org.zikula.modulestudio.generator.cartridges.zclassic.controller.formtype

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.EntityWorkflowType
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.GeneratorSettingsExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Finder {

    extension FormattingExtensions = new FormattingExtensions
    extension GeneratorSettingsExtensions = new GeneratorSettingsExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelExtensions = new ModelExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    FileHelper fh = new FileHelper
    Application app
    String nsSymfonyFormType = 'Symfony\\Component\\Form\\Extension\\Core\\Type\\'

    /**
     * Entry point for entity finder form type.
     */
    def generate(Application it, IFileSystemAccess fsa) {
        if (!generateExternalControllerAndFinder) {
            return
        }
        app = it
        for (entity : getAllEntities) {
            generateClassPair(fsa, getAppSourceLibPath + 'Form/Type/Finder/' + entity.name.formatForCodeCapital + 'FinderType.php',
                fh.phpFileContent(it, entity.finderTypeBaseImpl), fh.phpFileContent(it, entity.finderTypeImpl)
            )
        }
    }

    def private finderTypeBaseImpl(Entity it) '''
        namespace «app.appNamespace»\Form\Type\Finder\Base;

        use Symfony\Component\Form\AbstractType;
        use Symfony\Component\Form\FormBuilderInterface;
        use Symfony\Component\OptionsResolver\OptionsResolver;
        use Zikula\Common\Translator\TranslatorInterface;
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

            /**
             * «name.formatForCodeCapital»FinderType constructor.
             *
             * @param TranslatorInterface $translator Translator service instance
            «IF app.needsFeatureActivationHelper»
                «' '»* @param FeatureActivationHelper $featureActivationHelper FeatureActivationHelper service instance
            «ENDIF»
             */
            public function __construct(TranslatorInterface $translator«IF app.needsFeatureActivationHelper», FeatureActivationHelper $featureActivationHelper«ENDIF»)
            {
                $this->setTranslator($translator);
                «IF app.needsFeatureActivationHelper»
                    $this->featureActivationHelper = $featureActivationHelper;
                «ENDIF»
            }

            «app.setTranslatorMethod»

            /**
             * @inheritDoc
             */
            public function buildForm(FormBuilderInterface $builder, array $options)
            {
                $builder
                    ->setMethod('GET')
                    ->add('objectType', '«nsSymfonyFormType»HiddenType', [
                        'data' => $options['objectType']
                    ])
                    ->add('editor', '«nsSymfonyFormType»HiddenType', [
                        'data' => $options['editorName']
                    ])
                ;

                «IF categorisable»
                    if ($this->featureActivationHelper->isEnabled(FeatureActivationHelper::CATEGORIES, $options['objectType'])) {
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
                    ->add('update', '«nsSymfonyFormType»SubmitType', [
                        'label' => $this->__('Change selection'),
                        'icon' => 'fa-check',
                        'attr' => [
                            'class' => 'btn btn-success'
                        ]
                    ])
                    ->add('cancel', '«nsSymfonyFormType»SubmitType', [
                        'label' => $this->__('Cancel'),
                        'icon' => 'fa-times',
                        'attr' => [
                            'class' => 'btn btn-default',
                            'formnovalidate' => 'formnovalidate'
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

            /**
             * @inheritDoc
             */
            public function getBlockPrefix()
            {
                return '«app.appName.formatForDB»_«name.formatForDB»finder';
            }

            /**
             * @inheritDoc
             */
            public function configureOptions(OptionsResolver $resolver)
            {
                $resolver
                    ->setDefaults([
                        'objectType' => '«app.leadingEntity.name.formatForCode»',
                        'editorName' => 'ckeditor'
                    ])
                    ->setRequired(['objectType', 'editorName'])
                    ->setAllowedTypes([
                        'objectType' => 'string',
                        'editorName' => 'string'
                    ])
                    ->setAllowedValues([
                        'editorName' => ['tinymce', 'ckeditor']
                    ])
                ;
            }
        }
    '''

    def private addCategoriesField(Entity it) '''
        /**
         * Adds a categories field.
         *
         * @param FormBuilderInterface $builder The form builder
         * @param array                $options The options
         */
        public function addCategoriesField(FormBuilderInterface $builder, array $options)
        {
            $builder->add('categories', 'Zikula\CategoriesModule\Form\Type\CategoriesType', [
                'label' => $this->__('«IF categorisableMultiSelection»Categories«ELSE»Category«ENDIF»') . ':',
                'empty_data' => «IF categorisableMultiSelection»[]«ELSE»null«ENDIF»,
                'attr' => [
                    'class' => 'category-selector',
                    'title' => $this->__('This is an optional filter.')
                ],
                'help' => $this->__('This is an optional filter.'),
                'required' => false,
                'multiple' => «categorisableMultiSelection.displayBool»,
                'module' => '«app.appName»',
                'entity' => ucfirst($options['objectType']) . 'Entity',
                'entityCategoryClass' => '«app.appNamespace»\Entity\\' . ucfirst($options['objectType']) . 'CategoryEntity'
            ]);
        }
    '''

    def private addImageFields(Entity it) '''
        /**
         * Adds fields for image insertion options.
         *
         * @param FormBuilderInterface $builder The form builder
         * @param array                $options The options
         */
        public function addImageFields(FormBuilderInterface $builder, array $options)
        {
            $builder->add('onlyImages', '«nsSymfonyFormType»CheckboxType', [
                'label' => $this->__('Only images'),
                'empty_data' => false,
                'help' => $this->__('Enable this option to insert images'),
                'required' => false
            ]);
            «IF imageFieldsEntity.size > 1»
                $builder->add('imageField', '«nsSymfonyFormType»ChoiceType', [
                    'label' => $this->__('Image field'),
                    'empty_data' => '«imageFieldsEntity.head.name.formatForCode»',
                    'help' => $this->__('You can switch between different image fields'),
                    'choices' => [
                        «FOR imageField : imageFieldsEntity»
                            $this->__('«imageField.name.formatForDisplayCapital»') => '«imageField.name.formatForCode»'«IF imageField != imageFieldsEntity.last»,«ENDIF»
                        «ENDFOR»
                    ],
                    'choices_as_values' => true,
                    'multiple' => false,
                    'expanded' => false
                ]);
            «ELSE»
                $builder->add('imageField', '«nsSymfonyFormType»HiddenType', [
                    'data' => '«imageFieldsEntity.head.name.formatForCode»'
                ]);
            «ENDIF»
        }
    '''

    def private addPasteAsField(Entity it) '''
        /**
         * Adds a "paste as" field.
         *
         * @param FormBuilderInterface $builder The form builder
         * @param array                $options The options
         */
        public function addPasteAsField(FormBuilderInterface $builder, array $options)
        {
            $builder->add('pasteAs', '«nsSymfonyFormType»ChoiceType', [
                'label' => $this->__('Paste as') . ':',
                'empty_data' => 1,
                'choices' => [
                    $this->__('Relative link to the «name.formatForDisplay»') => 1,
                    $this->__('Absolute url to the «name.formatForDisplay»') => 2,
                    $this->__('ID of «name.formatForDisplay»') => 3«IF hasImageFieldsEntity»,«ENDIF»
                    «IF hasImageFieldsEntity»
                        $this->__('Relative link to the image') => 6,
                        $this->__('Image') => 7,
                        $this->__('Image with relative link to the «name.formatForDisplay»') => 8,
                        $this->__('Image with absolute url to the «name.formatForDisplay»') => 9
                    «ENDIF»
                ],
                'choices_as_values' => true,
                'multiple' => false,
                'expanded' => false
            ]);
        }
    '''

    def private addSortingFields(Entity it) '''
        /**
         * Adds sorting fields.
         *
         * @param FormBuilderInterface $builder The form builder
         * @param array                $options The options
         */
        public function addSortingFields(FormBuilderInterface $builder, array $options)
        {
            $builder
                ->add('sort', '«nsSymfonyFormType»ChoiceType', [
                    'label' => $this->__('Sort by') . ':',
                    'empty_data' => '',
                    'choices' => [
                        «FOR field : getSortingFields»
                            «IF field.name.formatForCode != 'workflowState' || workflow != EntityWorkflowType.NONE»
                                $this->__('«field.name.formatForDisplayCapital»') => '«field.name.formatForCode»'«IF standardFields || field != getDerivedFields.last»,«ENDIF»
                            «ENDIF»
                        «ENDFOR»
                        «IF standardFields»
                            $this->__('Creation date') => 'createdDate',
                            $this->__('Creator') => 'createdBy',
                            $this->__('Update date') => 'updatedDate',
                            $this->__('Updater') => 'updatedBy'
                        «ENDIF»
                    ],
                    'choices_as_values' => true,
                    'multiple' => false,
                    'expanded' => false
                ])
                ->add('sortdir', '«nsSymfonyFormType»ChoiceType', [
                    'label' => $this->__('Sort direction') . ':',
                    'empty_data' => 'asc',
                    'choices' => [
                        $this->__('Ascending') => 'asc',
                        $this->__('Descending') => 'desc'
                    ],
                    'choices_as_values' => true,
                    'multiple' => false,
                    'expanded' => false
                ])
            ;
        }
    '''

    def private addAmountField(Entity it) '''
        /**
         * Adds a page size field.
         *
         * @param FormBuilderInterface $builder The form builder
         * @param array                $options The options
         */
        public function addAmountField(FormBuilderInterface $builder, array $options)
        {
            $builder->add('num', '«nsSymfonyFormType»ChoiceType', [
                'label' => $this->__('Page size') . ':',
                'empty_data' => 20,
                'attr' => [
                    'class' => 'text-right'
                ],
                'choices' => [
                    $this->__('5') => 5,
                    $this->__('10') => 10,
                    $this->__('15') => 15,
                    $this->__('20') => 20,
                    $this->__('30') => 30,
                    $this->__('50') => 50,
                    $this->__('100') => 100
                ],
                'choices_as_values' => true,
                'multiple' => false,
                'expanded' => false
            ]);
        }
    '''

    def private addSearchField(Entity it) '''
        /**
         * Adds a search field.
         *
         * @param FormBuilderInterface $builder The form builder
         * @param array                $options The options
         */
        public function addSearchField(FormBuilderInterface $builder, array $options)
        {
            $builder->add('q', '«nsSymfonyFormType»SearchType', [
                'label' => $this->__('Search for') . ':',
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
