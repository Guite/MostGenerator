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
        use Symfony\Component\OptionsResolver\OptionsResolver;
        use Zikula\Common\Translator\TranslatorInterface;
        use Zikula\Common\Translator\TranslatorTrait;
        «IF hasListFieldsEntity»
            use «app.appNamespace»\Helper\ListEntriesHelper;
        «ENDIF»

        /**
         * «name.formatForDisplayCapital» quick navigation form type base class.
         */
        class «name.formatForCodeCapital»QuickNavType extends AbstractType
        {
            use TranslatorTrait;

            /**
             * @var RequestStack
             */
            protected $requestStack;
            «IF hasListFieldsEntity»

                /**
                 * @var ListEntriesHelper
                 */
                protected $listHelper;
            «ENDIF»

            /**
             * «name.formatForCodeCapital»QuickNavType constructor.
             *
             * @param TranslatorInterface $translator   Translator service instance
             * @param RequestStack        $requestStack RequestStack service instance
            «IF hasListFieldsEntity»
                «' '»* @param ListEntriesHelper   $listHelper   ListEntriesHelper service instance
            «ENDIF»
             */
            public function __construct(TranslatorInterface $translator, RequestStack $requestStack«IF hasListFieldsEntity», ListEntriesHelper $listHelper«ENDIF»)
            {
                $this->setTranslator($translator);
                $this->requestStack = $requestStack;
                «IF hasListFieldsEntity»
                    $this->listHelper = $listHelper;
                «ENDIF»
            }

            /**
             * Sets the translator.
             *
             * @param TranslatorInterface $translator Translator service instance
             */
            public function setTranslator(/*TranslatorInterface */$translator)
            {
                $this->translator = $translator;
            }

            /**
             * {@inheritdoc}
             */
            public function buildForm(FormBuilderInterface $builder, array $options)
            {
                $builder
                    ->setMethod('GET')
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
                «IF hasCurrencyFieldsEntity»
                    $this->addCurrencyFields($builder, $options);
                «ENDIF»
                «IF hasAbstractStringFieldsEntity»
                    «IF hasTimezoneFieldsEntity»
                        $this->addTimeZoneFields($builder, $options);
                    «ENDIF»
                    $this->addSearchField($builder, $options);
                «ENDIF»
                $this->addSortingFields($builder, $options);
                $this->addAmountField($builder, $options);
                «IF hasBooleanFieldsEntity»
                    $this->addBooleanFields($builder, $options);
                «ENDIF»
                $builder->add('updateview', '«nsSymfonyFormType»SubmitType', [
                    'label' => $this->__('OK'),
                    'attr' => [
                        'id' => 'quicknavSubmit',
                        'class' => 'btn btn-default btn-sm'
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
            «IF hasCurrencyFieldsEntity»
                «addCurrencyFields»

            «ENDIF»
            «IF hasAbstractStringFieldsEntity»
                «IF hasTimezoneFieldsEntity»
                    «addTimezoneFields»

                «ENDIF»
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

            /**
             * {@inheritdoc}
             */
            public function getName()
            {
                return $this->getBlockPrefix();
            }

            /**
             * {@inheritdoc}
             */
            public function configureOptions(OptionsResolver $resolver)
            {
                $resolver
                    ->setDefaults([
                        'all' => 0,
                        'own' => 0
                    ])
                    ->setRequired(['all', 'own'])
                    ->setAllowedValues([
                        'all' => [0, 1],
                        'own' => [0, 1]
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
            $objectType = '«name.formatForCode»';

            $builder->add('categories', 'Zikula\CategoriesModule\Form\Type\CategoriesType', [
                'label' => $this->__('«IF categorisableMultiSelection»Categories«ELSE»Category«ENDIF»'),
                'empty_data' => [],
                'attr' => [
                    'class' => 'input-sm category-selector',
                    'title' => $this->__('This is an optional filter.')
                ],
                'help' => $this->__('This is an optional filter.'),
                'required' => false,
                'multiple' => «categorisableMultiSelection.displayBool»,
                'module' => '«app.appName»',
                'entity' => ucfirst($objectType) . 'Entity',
                'entityCategoryClass' => '«app.appNamespace»\Entity\\' . ucfirst($objectType) . 'CategoryEntity'
            ]);
        }
    '''

    def private addIncomingRelationshipFields(Entity it) '''
        /**
         * Adds fields for incoming relationships.
         *
         * @param FormBuilderInterface $builder The form builder
         * @param array                $options The options
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
         * @param FormBuilderInterface $builder The form builder
         * @param array                $options The options
         */
        public function addListFields(FormBuilderInterface $builder, array $options)
        {
            «FOR field : getListFieldsEntity»
                $listEntries = $this->listHelper->getEntries('«name.formatForCode»', '«field.name.formatForCode»');
                $choices = [];
                $choiceAttributes = [];
                foreach ($listEntries as $entry) {
                    $choices[$entry['text']] = $entry['value'];
                    $choiceAttributes[$entry['text']] = ['title' => $entry['title']];
                }
                «field.fieldImpl»
            «ENDFOR»
        }
    '''

    def private addUserFields(Entity it) '''
        /**
         * Adds user fields.
         *
         * @param FormBuilderInterface $builder The form builder
         * @param array                $options The options
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
         * @param FormBuilderInterface $builder The form builder
         * @param array                $options The options
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
         * @param FormBuilderInterface $builder The form builder
         * @param array                $options The options
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
         * @param FormBuilderInterface $builder The form builder
         * @param array                $options The options
         */
        public function addLocaleFields(FormBuilderInterface $builder, array $options)
        {
            «FOR field : getLocaleFieldsEntity»
                «field.fieldImpl»
            «ENDFOR»
        }
    '''

    def private addCurrencyFields(Entity it) '''
        /**
         * Adds currency fields.
         *
         * @param FormBuilderInterface $builder The form builder
         * @param array                $options The options
         */
        public function addCurrencyFields(FormBuilderInterface $builder, array $options)
        {
            «FOR field : getCurrencyFieldsEntity»
                «field.fieldImpl»
            «ENDFOR»
        }
    '''

    def private addTimezoneFields(Entity it) '''
        /**
         * Adds time zone fields.
         *
         * @param FormBuilderInterface $builder The form builder
         * @param array                $options The options
         */
        public function addTimezoneFields(FormBuilderInterface $builder, array $options)
        {
            «FOR field : getTimezoneFieldsEntity»
                «field.fieldImpl»
            «ENDFOR»
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
                'label' => $this->__('Search'),
                'attr' => [
                    'id' => 'searchTerm',
                    'class' => 'input-sm'
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
         * @param FormBuilderInterface $builder The form builder
         * @param array                $options The options
         */
        public function addSortingFields(FormBuilderInterface $builder, array $options)
        {
            $builder
                ->add('sort', '«nsSymfonyFormType»ChoiceType', [
                    'label' => $this->__('Sort by'),
                    'attr' => [
                        'id' => '«app.appName.toFirstLower»Sort',
                        'class' => 'input-sm'
                    ],
                    'choices' => [
                        «FOR field : getDerivedFields»
                            «IF field.name.formatForCode != 'workflowState' || workflow != EntityWorkflowType.NONE»
                                $this->__('«field.name.formatForDisplayCapital»') => '«field.name.formatForCode»'«IF standardFields || field != getDerivedFields.last»,«ENDIF»
                            «ENDIF»
                        «ENDFOR»
                        «IF standardFields»
                            $this->__('Creation date') => 'createdDate',
                            $this->__('Creator') => 'createdUserId',
                            $this->__('Update date') => 'updatedDate'
                        «ENDIF»
                    ],
                    'choices_as_values' => true,
                    'required' => false,
                    'expanded' => false
                ])
                ->add('sortdir', '«nsSymfonyFormType»ChoiceType', [
                    'label' => $this->__('Sort direction'),
                    'empty_data' => 'asc',
                    'attr' => [
                        'id' => '«app.appName.toFirstLower»SortDir',
                        'class' => 'input-sm'
                    ],
                    'choices' => [
                        $this->__('Ascending') => 'asc',
                        $this->__('Descending') => 'desc'
                    ],
                    'choices_as_values' => true,
                    'required' => false,
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
                'label' => $this->__('Page size'),
                'empty_data' => 20,
                'attr' => [
                    'id' => '«app.appName.toFirstLower»PageSize',
                    'class' => 'input-sm text-right'
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
                'choices_as_values' => true,
                'required' => false,
                'expanded' => false
            ]);
        }
    '''

    def private addBooleanFields(Entity it) '''
        /**
         * Adds boolean fields.
         *
         * @param FormBuilderInterface $builder The form builder
         * @param array                $options The options
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
            'label' => $this->__('«name.formatForDisplayCapital»'),
            'attr' => [
                'class' => 'input-sm'
            ],
            'required' => false,
            «additionalOptions»
        ]);
    '''

    def private dispatch fieldType(DerivedField it) ''''''
    def private dispatch additionalOptions(DerivedField it) ''''''

    def private dispatch fieldType(StringField it) '''«IF country»Country«ELSEIF language»Language«ELSEIF locale»Locale«ELSEIF currency»Currency«ELSEIF timezone»Timezone«ENDIF»'''
    def private dispatch additionalOptions(StringField it) '''
        'placeholder' => $this->__('All')
    '''

    def private dispatch fieldType(UserField it) '''Entity'''
    def private dispatch additionalOptions(UserField it) '''
        'placeholder' => $this->__('All'),
        // Zikula core should provide a form type for this to hide entity details
        'class' => 'Zikula\UsersModule\Entity\UserEntity',
        'choice_label' => 'uname'
    '''

    def private dispatch fieldType(ListField it) '''«/* called for multiple=false only */»Choice'''
    def private dispatch additionalOptions(ListField it) '''
        'placeholder' => $this->__('All'),
        'choices' => $choices,
        'choices_as_values' => true,
        'choice_attr' => $choiceAttributes,
        'multiple' => «multiple.displayBool»,
        'expanded' => false
    '''

    def private dispatch fieldType(BooleanField it) '''Choice'''
    def private dispatch additionalOptions(BooleanField it) '''
        'placeholder' => $this->__('All'),
        'choices' => [
            $this->__('No') => 'no',
            $this->__('Yes') => 'yes'
        ],
        'choices_as_values' => true
    '''

    def private dispatch fieldImpl(JoinRelationship it) '''
        «val sourceAliasName = getRelationAliasName(false)»
        $builder->add('«sourceAliasName.formatForCode»', 'Symfony\Bridge\Doctrine\Form\Type\EntityType', [
            'class' => '«app.appName»:«source.name.formatForCodeCapital»Entity',
            'choice_label' => 'getTitleFromDisplayPattern',
            'placeholder' => $this->__('All'),
            'required' => false,
            'label' => $this->__('«/*(source as Entity).nameMultiple*/sourceAliasName.formatForDisplayCapital»'),
            'attr' => [
                'id' => '«sourceAliasName.formatForCode»',
                'class' => 'input-sm'
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
