package org.zikula.modulestudio.generator.cartridges.zclassic.controller.formtype

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.EntityWorkflowType
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.GeneratorSettingsExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Finder {
    extension FormattingExtensions = new FormattingExtensions
    extension GeneratorSettingsExtensions = new GeneratorSettingsExtensions
    extension ModelExtensions = new ModelExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    FileHelper fh = new FileHelper
    Application app
    String nsSymfonyFormType = 'Symfony\\Component\\Form\\Extension\\Core\\Type\\'

    /**
     * Entry point for entity finder form type.
     * 1.4.x only.
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

        use Symfony\Component\Form\AbstractType as SymfonyAbstractType;
        use Symfony\Component\Form\FormBuilderInterface;
        use Symfony\Component\Translation\TranslatorInterface;

        /**
         * «name.formatForDisplayCapital» finder form type base class.
         */
        class «name.formatForCodeCapital»FinderType extends SymfonyAbstractType
        {
            /**
             * @var TranslatorInterface
             */
            private $translator;

            /**
             * «name.formatForCodeCapital»FinderType constructor.
             *
             * @param TranslatorInterface $translator Translator service instance.
             */
            public function __construct(TranslatorInterface $translator)
            {
                $this->translator = $translator;
            }

            /**
             * {@inheritdoc}
             */
            public function buildForm(FormBuilderInterface $builder, array $options)
            {
                $builder
                    ->add('objectType', '«nsSymfonyFormType»HiddenType', [
                        'data' => $options['objectType']
                    ])
                    ->add('editor', '«nsSymfonyFormType»HiddenType', [
                        'data' => $options['editorName']
                    ])
                ;

                «IF categorisable»
                    $this->addCategoriesField($builder, $options);
            	«ENDIF»
                $this->addPasteAsField($builder, $options);
                $this->addSortingFields($builder, $options);
                $this->addAmountField($builder, $options);
                $this->addSearchField($builder, $options);

                $builder
                    ->add('update', '«nsSymfonyFormType»SubmitType', [
                        'label' => $this->translator->trans('Change selection', [], '«app.appName.formatForDB»'),
                        'attr' => [
                            'id' => '«app.appName.toFirstLower»Submit'
                        ]
                    ])
                    ->add('cancel', '«nsSymfonyFormType»SubmitType', [
                        'label' => $this->translator->trans('Cancel', [], '«app.appName.formatForDB»'),
                        'attr' => [
                            'id' => '«app.appName.toFirstLower»Cancel'
                        ]
                    ])
                ;
            }

            «IF categorisable»
                «addCategoriesField»

            «ENDIF»
            «addPasteAsField»

            «addSortingFields»

            «addAmountField»

            «addSearchField»

            /**
             * {@inheritdoc}
             */
            public function getBlockPrefix()
            {
                return '«app.appName.formatForDB»_«name.formatForDB»finder';
            }
        }
    '''

    def private addCategoriesField(Entity it) '''
        /**
         * Adds a categories field.
         *
         * @param FormBuilderInterface The form builder.
         * @param array                The options
         */
        public function addCategoriesField(FormBuilderInterface $builder, array $options)
        {
            $builder->add('categories', 'Zikula\CategoriesModule\Form\Type\CategoriesType', [
                'label' => $this->translator->trans('«IF categorisableMultiSelection»Categories«ELSE»Category«ENDIF»', [], '«app.appName.formatForDB»') . ':',
                'empty_data' => [],
                'attr' => [
                    'class' => 'category-selector',
                    'title' => $this->translator->trans('This is an optional filter.', [], '«app.appName.formatForDB»')
                ],
                'required' => false,
                'multiple' => «categorisableMultiSelection.displayBool»,
                'module' => '«app.appName»',
                'entity' => ucfirst($options['objectType']) . 'Entity',
                'entityCategoryClass' => '«app.appNamespace»\Entity\' . ucfirst($options['objectType']) . 'CategoryEntity',
                'help' => $this->translator->trans('This is an optional filter.', [], '«app.appName.formatForDB»')
            ]);
        }
    '''

    def private addPasteAsField(Entity it) '''
        /**
         * Adds a "paste as" field.
         *
         * @param FormBuilderInterface The form builder.
         * @param array                The options
         */
        public function addPasteAsField(FormBuilderInterface $builder, array $options)
        {
            $builder->add('pasteas', '«nsSymfonyFormType»ChoiceType', [
                'label' => $this->translator->trans('Paste as', [], '«app.appName.formatForDB»') . ':',
                'empty_data' => 1,
                'attr' => [
                    'id' => '«app.appName.toFirstLower»PasteAs'
                ],
                'choices' => [
                    $this->translator->trans('Link to the «name.formatForDisplay»', [], '«app.appName.formatForDB»') => 1,
                    $this->translator->trans('ID of «name.formatForDisplay»', [], '«app.appName.formatForDB»') => 2
                ],
                'choices_as_values' => true
            ]);
        }
    '''

    def private addSortingFields(Entity it) '''
        /**
         * Adds sorting fields.
         *
         * @param FormBuilderInterface The form builder.
         * @param array                The options
         */
        public function addSortingFields(FormBuilderInterface $builder, array $options)
        {
            $builder
                ->add('sort', '«nsSymfonyFormType»ChoiceType', [
                    'label' => $this->translator->trans('Sort by', [], '«app.appName.formatForDB»') . ':',
                    'empty_data' => '',
                    'attr' => [
                        'id' => '«app.appName.toFirstLower»Sort'
                    ],
                    'choices' => [
                        «FOR field : getDerivedFields»
                            «IF field.name.formatForCode != 'workflowState' || workflow != EntityWorkflowType.NONE»
                                $this->translator->trans('«field.name.formatForDisplayCapital»', [], '«app.appName.formatForDB»') => '«field.name.formatForCode»'«IF standardFields || field != getDerivedFields.last»,«ENDIF»
                            «ENDIF»
                        «ENDFOR»
                        «IF standardFields»
                            $this->translator->trans('Creation date', [], '«app.appName.formatForDB»') => 'createdDate',
                            $this->translator->trans('Creator', [], '«app.appName.formatForDB»') => 'createdUserId',
                            $this->translator->trans('Update date', [], '«app.appName.formatForDB»') => 'updatedDate'
                        «ENDIF»
                    ],
                    'choices_as_values' => true
                ])
                ->add('sortdir', '«nsSymfonyFormType»ChoiceType', [
                    'label' => $this->translator->trans('Sort direction', [], '«app.appName.formatForDB»') . ':',
                    'empty_data' => 'asc',
                    'attr' => [
                        'id' => '«app.appName.toFirstLower»SortDir'
                    ],
                    'choices' => [
                        $this->translator->trans('Ascending', [], '«app.appName.formatForDB»') => 'asc',
                        $this->translator->trans('Descending', [], '«app.appName.formatForDB»') => 'desc'
                    ],
                    'choices_as_values' => true
                ])
            ;
        }
    '''

    def private addAmountField(Entity it) '''
        /**
         * Adds a page size field.
         *
         * @param FormBuilderInterface The form builder.
         * @param array                The options
         */
        public function addAmountField(FormBuilderInterface $builder, array $options)
        {
            $builder->add('num', '«nsSymfonyFormType»ChoiceType', [
                'label' => $this->translator->trans('Page size', [], '«app.appName.formatForDB»') . ':',
                'empty_data' => 20,
                'attr' => [
                    'id' => '«app.appName.toFirstLower»PageSize',
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
                'choices_as_values' => true
            ]);
        }
    '''

    def private addSearchField(Entity it) '''
        /**
         * Adds a search field.
         *
         * @param FormBuilderInterface The form builder.
         * @param array                The options
         */
        public function addSearchField(FormBuilderInterface $builder, array $options)
        {
            $builder->add('q', '«nsSymfonyFormType»TextType', [
                'label' => $this->translator->trans('Search for', [], '«app.appName.formatForDB»') . ':',
                'attr' => [
                    'id' => '«app.appName.toFirstLower»SearchTerm'
                ],
                'required' => false,
                'max_length' => 255
            ]);
        }
    '''

    def private finderTypeImpl(Entity it) '''
        namespace «app.appNamespace»\Form\Type\Finder;

        use «app.appNamespace»\Form\Type\Finder\Base\«name.formatForCodeCapital»FinderType as Base«name.formatForCodeCapital»FinderType;

        /**
         * «name.formatForDisplayCapital» finder form type implementation class.
         */
        class «name.formatForCodeCapital»FinderType extends Base«name.formatForCodeCapital»FinderType
        {
            // feel free to extend the base form type class here
        }
    '''
}
