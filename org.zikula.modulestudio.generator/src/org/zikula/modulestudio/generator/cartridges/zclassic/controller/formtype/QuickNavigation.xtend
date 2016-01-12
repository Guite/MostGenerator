package org.zikula.modulestudio.generator.cartridges.zclassic.controller.formtype

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.BooleanField
import de.guite.modulestudio.metamodel.DerivedField
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.EntityWorkflowType
import de.guite.modulestudio.metamodel.JoinRelationship
import de.guite.modulestudio.metamodel.ListField
import de.guite.modulestudio.metamodel.StringField
import de.guite.modulestudio.metamodel.UserField
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class QuickNavigation {
    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension ModelJoinExtensions = new ModelJoinExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    FileHelper fh = new FileHelper
    Application app
    String nsSymfonyFormType = 'Symfony\\Component\\Form\\Extension\\Core\\Type\\'
    Iterable<JoinRelationship> incomingRelations

    /**
     * Entry point for quick navigation form type.
     * 1.4.x only.
     */
    def generate(Application it, IFileSystemAccess fsa) {
        if (!hasViewActions) {
            return
        }
        app = it
        for (entity : getAllEntities.filter[e|e.hasActions('view')]) {
        	incomingRelations = entity.getBidirectionalIncomingJoinRelationsWithOneSource.filter[source instanceof Entity]
            generateClassPair(fsa, getAppSourceLibPath + 'Form/Type/QuickNavigation/' + entity.name.formatForCodeCapital + 'QuickNavType.php',
                fh.phpFileContent(it, entity.quickNavTypeBaseImpl), fh.phpFileContent(it, entity.quickNavTypeImpl)
            )
        }
    }

    def private quickNavTypeBaseImpl(Entity it) '''
        namespace «app.appNamespace»\Form\Type\QuickNavigation\Base;

        use Symfony\Component\Form\AbstractType;
        use Symfony\Component\Form\FormBuilderInterface;
        use Symfony\Component\HttpFoundation\RequestStack;
        use Symfony\Component\Translation\TranslatorInterface;
        «IF hasListFieldsEntity»
            use «app.appNamespace»\Helper\ListEntriesHelper;
        «ENDIF»

        /**
         * «name.formatForDisplayCapital» quick navigation form type base class.
         */
        class «name.formatForCodeCapital»QuickNavType extends AbstractType
        {
            /**
             * @var TranslatorInterface
             */
            private $translator;

            /**
             * @var RequestStack
             */
            private $requestStack;
            «IF hasListFieldsEntity»

                /**
                 * @var ListEntriesHelper
                 */
                private $listHelper;
            «ENDIF»

            /**
             * «name.formatForCodeCapital»QuickNavType constructor.
             *
             * @param TranslatorInterface $translator   Translator service instance.
             * @param RequestStack        $requestStack RequestStack service instance.
            «IF hasListFieldsEntity»
                «' '»* @param ListEntriesHelper   $listHelper   ListEntriesHelper service instance.
            «ENDIF»
             */
            public function __construct(TranslatorInterface $translator, RequestStack $requestStack«IF hasListFieldsEntity», ListEntriesHelper $listHelper«ENDIF»)
            {
                $this->translator = $translator;
                $this->requestStack = $requestStack;
                «IF hasListFieldsEntity»
                    $this->listHelper = $listHelper;
                «ENDIF»
            }

            /**
             * {@inheritdoc}
             */
            public function buildForm(FormBuilderInterface $builder, array $options)
            {
                $objectType = '«name.formatForCode»';

                $builder
                    ->add('all', '«nsSymfonyFormType»HiddenType', [
                        'data' => $options['all'],
                        'empty_data' => 0
                    ])
                    ->add('own', '«nsSymfonyFormType»HiddenType', [
                        'data' => $options['own'],
                        'empty_data' => 0
                    ])
                ;

                «IF categorisable»
                    $this->addCategoriesField($builder, $options);
            	«ENDIF»
                «IF !incomingRelations.empty»
                    $this->addIncomingRelationshipFields($builder, $options);
                «ENDIF»
                «IF hasListFieldsEntity»
                    $this->addListFields($builder, $options);
                «ENDIF»
                «IF hasUserFieldsEntity»
                    $this->addUserFields($builder, $options);
                «ENDIF»
                «IF hasCountryFieldsEntity»
                    $this->addCountryFields($builder, $options);
                «ENDIF»
                «IF hasLanguageFieldsEntity»
                    $this->addLanguageFields($builder, $options);
                «ENDIF»
                «IF hasLocaleFieldsEntity»
                    $this->addLocaleFields($builder, $options);
                «ENDIF»
                «IF hasAbstractStringFieldsEntity»
                    $this->addSearchField($builder, $options);
                «ENDIF»
                $this->addSortingFields($builder, $options);
                $this->addAmountField($builder, $options);
                «IF hasBooleanFieldsEntity»
                    $this->addBooleanFields($builder, $options);
                «ENDIF»
                $builder->add('updateview', '«nsSymfonyFormType»SubmitType', [
                    'label' => $this->translator->trans('OK', [], '«app.appName.formatForDB»'),
                    'attr' => [
                        'id' => 'quicknavSubmit'
                    ]
                ]);
            }

            «IF categorisable»
                «addCategoriesField»

            «ENDIF»
            «IF !incomingRelations.empty»
                «addIncomingRelationshipFields»

            «ENDIF»
            «IF hasListFieldsEntity»
                «addListFields»

            «ENDIF»
            «IF hasUserFieldsEntity»
                «addUserFields»

            «ENDIF»
            «IF hasCountryFieldsEntity»
                «addCountryFields»

            «ENDIF»
            «IF hasLanguageFieldsEntity»
                «addLanguageFields»

            «ENDIF»
            «IF hasLocaleFieldsEntity»
                «addLocaleFields»

            «ENDIF»
            «IF hasAbstractStringFieldsEntity»
                «addSearchField»

            «ENDIF»

            «addSortingFields»

            «addAmountField»

            «IF hasBooleanFieldsEntity»
                «addBooleanFields»

            «ENDIF»
            /**
             * {@inheritdoc}
             */
            public function getBlockPrefix()
            {
                return '«app.appName.formatForDB»_«name.formatForDB»quicknav';
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
                'entity' => ucfirst($objectType) . 'Entity',
                'entityCategoryClass' => '«app.appNamespace»\Entity\' . ucfirst($objectType) . 'CategoryEntity',
                'help' => $this->translator->trans('This is an optional filter.', [], '«app.appName.formatForDB»')
            ]);
        }
    '''

    def private addIncomingRelationshipFields(Entity it) '''
        /**
         * Adds fields for incoming relationships.
         *
         * @param FormBuilderInterface The form builder.
         * @param array                The options
         */
        public function addIncomingRelationshipFields(FormBuilderInterface $builder, array $options)
        {
            $mainSearchTerm = '';
            $request = $this->requestStack->getCurrentRequest();
            if ($request->query->has('q')) {
                // remove current search argument from request to avoid filtering related items
                $mainSearchTerm = $request->query->get('q');
                $request->query->remove('q');
            }

            «FOR relation : incomingRelations»
                «relation.fieldImpl»
            «ENDFOR»

            if ($mainSearchTerm != '') {
                // readd current search argument
                $request->query->set('q', $mainSearchTerm);
            }
        }
    '''

    def private addListFields(Entity it) '''
        /**
         * Adds list fields.
         *
         * @param FormBuilderInterface The form builder.
         * @param array                The options
         */
        public function addListFields(FormBuilderInterface $builder, array $options)
        {
            «FOR field : getListFieldsEntity»
                $listEntries = $this->listHelper->getEntries('«name.formatForCode»', '«field.name.formatForCode»');
                $choices = [];
                $choiceAttributes = [];
                foreach ($listEntries as $entry) {
                    $choices[$entry['text']] = $entry['value'];
                    $choiceAttributes[$entry['text']] = $entry['title'];
                }
                «field.fieldImpl»
            «ENDFOR»
        }
    '''

    def private addUserFields(Entity it) '''
        /**
         * Adds user fields.
         *
         * @param FormBuilderInterface The form builder.
         * @param array                The options
         */
        public function addUserFields(FormBuilderInterface $builder, array $options)
        {
            «FOR field : getUserFieldsEntity»
                «field.fieldImpl»
            «ENDFOR»
        }
    '''

    def private addCountryFields(Entity it) '''
        /**
         * Adds country fields.
         *
         * @param FormBuilderInterface The form builder.
         * @param array                The options
         */
        public function addCountryFields(FormBuilderInterface $builder, array $options)
        {
            «FOR field : getCountryFieldsEntity»
                «field.fieldImpl»
            «ENDFOR»
        }
    '''

    def private addLanguageFields(Entity it) '''
        /**
         * Adds language fields.
         *
         * @param FormBuilderInterface The form builder.
         * @param array                The options
         */
        public function addLanguageFields(FormBuilderInterface $builder, array $options)
        {
            «FOR field : getLanguageFieldsEntity»
                «field.fieldImpl»
            «ENDFOR»
        }
    '''

    def private addLocaleFields(Entity it) '''
        /**
         * Adds locale fields.
         *
         * @param FormBuilderInterface The form builder.
         * @param array                The options
         */
        public function addLocaleFields(FormBuilderInterface $builder, array $options)
        {
            «FOR field : getLocaleFieldsEntity»
                «field.fieldImpl»
            «ENDFOR»
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
            $builder->add('q', '«nsSymfonyFormType»SearchType', [
                'label' => $this->translator->trans('Search', [], '«app.appName.formatForDB»'),
                'attr' => [
                    'id' => 'searchTerm'
                ],
                'required' => false,
                'max_length' => 255
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

    def private addBooleanFields(Entity it) '''
        /**
         * Adds boolean fields.
         *
         * @param FormBuilderInterface The form builder.
         * @param array                The options
         */
        public function addBooleanFields(FormBuilderInterface $builder, array $options)
        {
            «FOR field : getBooleanFieldsEntity»
                «field.fieldImpl»
            «ENDFOR»
        }
    '''

    def private dispatch fieldImpl(DerivedField it) '''
        $builder->add('«name.formatForCode»', '«IF it instanceof StringField && (it as StringField).locale»Zikula\Bundle\FormExtensionBundle\Form\Type\Locale«ELSEIF it instanceof ListField && (it as ListField).multiple»«app.appNamespace»\Form\Type\Field\MultiList«ELSE»«nsSymfonyFormType»«fieldType»«ENDIF»Type', [
            'label' => $this->translator->trans('«name.formatForDisplayCapital»', [], '«app.appName.formatForDB»'),
            'required' => false,
            «additionalOptions»
        ]);
    '''

    def private dispatch fieldType(DerivedField it) ''''''
    def private dispatch additionalOptions(DerivedField it) ''''''

    def private dispatch fieldType(StringField it) '''«IF country»Country«ELSEIF language»Language«ELSEIF locale»Locale«ENDIF»'''
    def private dispatch additionalOptions(StringField it) '''
        'placeholder' => $this->translator->trans('All', [], '«app.appName.formatForDB»')
    '''

    def private dispatch fieldType(UserField it) '''Entity'''
    def private dispatch additionalOptions(UserField it) '''
        'placeholder' => $this->translator->trans('All', [], '«app.appName.formatForDB»'),
        // Zikula core should provide a form type for this to hide entity details
        'class' => 'Zikula\UsersModule\Entity\UserEntity',
        'choice_label' => 'uname'
    '''

    def private dispatch fieldType(ListField it) '''«/* called for multiple=false only */»Choice'''
    def private dispatch additionalOptions(ListField it) '''
        'placeholder' => $this->translator->trans('All', [], '«app.appName.formatForDB»'),
        'choices' => $choices,
        'choices_as_values' => true,
        'choice_attr' => $choiceAttributes«IF !multiple»,«ENDIF»
        «IF !multiple»
        	'multiple' => «multiple.displayBool»
    	«ENDIF»
    '''

    def private dispatch fieldType(BooleanField it) '''Choice'''
    def private dispatch additionalOptions(BooleanField it) '''
        'placeholder' => $this->translator->trans('All', [], '«app.appName.formatForDB»'),
        'choices' => [
            $this->translator->trans('No', [], '«app.appName.formatForDB»') => 'no',
            $this->translator->trans('Yes', [], '«app.appName.formatForDB»') => 'yes'
        ],
        'choices_as_values' => true
    '''

    def private dispatch fieldImpl(JoinRelationship it) '''
        «val sourceAliasName = getRelationAliasName(false)»
        $builder->add('«sourceAliasName»', 'Symfony\Bridge\Doctrine\Form\Type\EntityType', [
            'placeholder' => $this->translator->trans('All', [], '«app.appName.formatForDB»'),
            'class' => '«source.entityClassName('', false)»',
            'choice_label' => 'getTitleFromDisplayPattern',
            'label' => $this->translator->trans('«(source as Entity).nameMultiple.formatForDisplayCapital»', [], '«app.appName.formatForDB»'),
            'attr' => [
                'id' => '«sourceAliasName»'
            ]
        ]);
    '''

    def private quickNavTypeImpl(Entity it) '''
        namespace «app.appNamespace»\Form\Type\QuickNavigation;

        use «app.appNamespace»\Form\Type\QuickNavigation\Base\«name.formatForCodeCapital»QuickNavType as Base«name.formatForCodeCapital»QuickNavType;

        /**
         * «name.formatForDisplayCapital» quick navigation form type implementation class.
         */
        class «name.formatForCodeCapital»QuickNavType extends Base«name.formatForCodeCapital»QuickNavType
        {
            // feel free to extend the base form type class here
        }
    '''
}
