package org.zikula.modulestudio.generator.cartridges.zclassic.controller.formtype

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.BooleanField
import de.guite.modulestudio.metamodel.DerivedField
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.EntityWorkflowType
import de.guite.modulestudio.metamodel.JoinRelationship
import de.guite.modulestudio.metamodel.ListField
import de.guite.modulestudio.metamodel.StringField
import de.guite.modulestudio.metamodel.StringRole
import de.guite.modulestudio.metamodel.UserField
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class QuickNavigationType {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelExtensions = new ModelExtensions
    extension ModelJoinExtensions = new ModelJoinExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    Application app
    String nsSymfonyFormType = 'Symfony\\Component\\Form\\Extension\\Core\\Type\\'
    Iterable<JoinRelationship> incomingRelations

    /**
     * Entry point for quick navigation form type.
     */
    def generate(Application it, IMostFileSystemAccess fsa) {
        if (!hasViewActions) {
            return
        }
        app = it
        for (entity : getAllEntities.filter[hasViewAction]) {
            incomingRelations = entity.getBidirectionalIncomingJoinRelationsWithOneSource.filter[source instanceof Entity]
            fsa.generateClassPair('Form/Type/QuickNavigation/' + entity.name.formatForCodeCapital + 'QuickNavType.php',
                entity.quickNavTypeBaseImpl, entity.quickNavTypeImpl
            )
        }
    }

    def private quickNavTypeBaseImpl(Entity it) '''
        namespace «app.appNamespace»\Form\Type\QuickNavigation\Base;

        «IF !incomingRelations.empty»
            use Doctrine\ORM\EntityRepository;
        «ENDIF»
        «IF !incomingRelations.empty || !fields.filter(UserField).empty»
            use Symfony\Bridge\Doctrine\Form\Type\EntityType;
        «ENDIF»
        use Symfony\Component\Form\AbstractType;
        use «nsSymfonyFormType»ChoiceType;
        «IF hasCountryFieldsEntity»
            use «nsSymfonyFormType»CountryType;
        «ENDIF»
        «IF hasCurrencyFieldsEntity»
            use «nsSymfonyFormType»CurrencyType;
        «ENDIF»
        use «nsSymfonyFormType»HiddenType;
        «IF hasLanguageFieldsEntity»
            use «nsSymfonyFormType»LanguageType;
        «ENDIF»
        «IF hasAbstractStringFieldsEntity»
            use «nsSymfonyFormType»SearchType;
        «ENDIF»
        use «nsSymfonyFormType»SubmitType;
        «IF hasTimezoneFieldsEntity»
            use «nsSymfonyFormType»TimezoneType;
        «ENDIF»
        use Symfony\Component\Form\FormBuilderInterface;
        «IF !incomingRelations.empty»
            use Symfony\Component\HttpFoundation\RequestStack;
        «ENDIF»
        use Symfony\Component\OptionsResolver\OptionsResolver;
        «IF hasLocaleFieldsEntity»
            use Zikula\Bundle\FormExtensionBundle\Form\Type\LocaleType;
        «ENDIF»
        «IF categorisable»
            use Zikula\CategoriesModule\Form\Type\CategoriesType;
        «ENDIF»
        use Zikula\Common\Translator\TranslatorInterface;
        use Zikula\Common\Translator\TranslatorTrait;
        «IF hasLocaleFieldsEntity»
            use Zikula\SettingsModule\Api\ApiInterface\LocaleApiInterface;
        «ENDIF»
        «IF !fields.filter(UserField).empty»
            use Zikula\UsersModule\Entity\UserEntity;
        «ENDIF»
        «IF !fields.filter(ListField).filter[multiple].empty»
            use «app.appNamespace»\Form\Type\Field\MultiListType;
        «ENDIF»
        «IF !incomingRelations.empty»
            use «app.appNamespace»\Helper\EntityDisplayHelper;
        «ENDIF»
        «IF app.needsFeatureActivationHelper»
            use «app.appNamespace»\Helper\FeatureActivationHelper;
        «ENDIF»
        «IF hasListFieldsEntity»
            use «app.appNamespace»\Helper\ListEntriesHelper;
        «ENDIF»

        /**
         * «name.formatForDisplayCapital» quick navigation form type base class.
         */
        abstract class Abstract«name.formatForCodeCapital»QuickNavType extends AbstractType
        {
            use TranslatorTrait;
            «IF !incomingRelations.empty»

                /**
                 * @var RequestStack
                 */
                protected $requestStack;

                /**
                 * @var EntityDisplayHelper
                 */
                protected $entityDisplayHelper;
            «ENDIF»
            «IF hasListFieldsEntity»

                /**
                 * @var ListEntriesHelper
                 */
                protected $listHelper;
            «ENDIF»
            «IF hasLocaleFieldsEntity»

                /**
                 * @var LocaleApiInterface
                 */
                protected $localeApi;
            «ENDIF»
            «IF app.needsFeatureActivationHelper»

                /**
                 * @var FeatureActivationHelper
                 */
                protected $featureActivationHelper;
            «ENDIF»

            public function __construct(
                TranslatorInterface $translator«IF !incomingRelations.empty»,
                RequestStack $requestStack,
                EntityDisplayHelper $entityDisplayHelper«ENDIF»«IF hasListFieldsEntity»,
                ListEntriesHelper $listHelper«ENDIF»«IF hasLocaleFieldsEntity»,
                LocaleApiInterface $localeApi«ENDIF»«IF app.needsFeatureActivationHelper»,
                FeatureActivationHelper $featureActivationHelper«ENDIF»
            ) {
                $this->setTranslator($translator);
                «IF !incomingRelations.empty»
                    $this->requestStack = $requestStack;
                    $this->entityDisplayHelper = $entityDisplayHelper;
                «ENDIF»
                «IF hasListFieldsEntity»
                    $this->listHelper = $listHelper;
                «ENDIF»
                «IF hasLocaleFieldsEntity»
                    $this->localeApi = $localeApi;
                «ENDIF»
                «IF app.needsFeatureActivationHelper»
                    $this->featureActivationHelper = $featureActivationHelper;
                «ENDIF»
            }

            «app.setTranslatorMethod»

            public function buildForm(FormBuilderInterface $builder, array $options)
            {
                $builder
                    ->setMethod('GET')
                    ->add('all', HiddenType::class)
                    ->add('own', HiddenType::class)
                    ->add('tpl', HiddenType::class)
                ;

                «IF categorisable»
                    if ($this->featureActivationHelper->isEnabled(FeatureActivationHelper::CATEGORIES, '«name.formatForCode»')) {
                        $this->addCategoriesField($builder, $options);
                    }
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
                $builder->add('updateview', SubmitType::class, [
                    'label' => $this->__('OK'),
                    'attr' => [
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
            public function getBlockPrefix()
            {
                return '«app.appName.formatForDB»_«name.formatForDB»quicknav';
            }

            public function configureOptions(OptionsResolver $resolver)
            {
                $resolver->setDefaults([
                    'csrf_protection' => false
                ]);
            }
        }
    '''

    def private addCategoriesField(Entity it) '''
        /**
         * Adds a categories field.
         */
        public function addCategoriesField(FormBuilderInterface $builder, array $options = [])«IF app.targets('3.0')»: void«ENDIF»
        {
            $objectType = '«name.formatForCode»';
            $entityCategoryClass = '«app.appNamespace»\Entity\\' . ucfirst($objectType) . 'CategoryEntity';
            $builder->add('categories', CategoriesType::class, [
                'label' => $this->__('«IF categorisableMultiSelection»Categories«ELSE»Category«ENDIF»'),
                'empty_data' => «IF categorisableMultiSelection»[]«ELSE»null«ENDIF»,
                'attr' => [
                    'class' => '«IF app.targets('3.0')»form-control«ELSE»input«ENDIF»-sm category-selector',
                    'title' => $this->__('This is an optional filter.')
                ],
                'required' => false,
                'multiple' => «categorisableMultiSelection.displayBool»,
                'module' => '«app.appName»',
                'entity' => ucfirst($objectType) . 'Entity',
                'entityCategoryClass' => $entityCategoryClass,
                'showRegistryLabels' => true
            ]);
        }
    '''

    def private addIncomingRelationshipFields(Entity it) '''
        /**
         * Adds fields for incoming relationships.
         */
        public function addIncomingRelationshipFields(FormBuilderInterface $builder, array $options = [])«IF app.targets('3.0')»: void«ENDIF»
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

            if ('' !== $mainSearchTerm) {
                // readd current search argument
                $request->query->set('q', $mainSearchTerm);
            }
        }
    '''

    def private addListFields(Entity it) '''
        /**
         * Adds list fields.
         */
        public function addListFields(FormBuilderInterface $builder, array $options = [])«IF app.targets('3.0')»: void«ENDIF»
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
         */
        public function addUserFields(FormBuilderInterface $builder, array $options = [])«IF app.targets('3.0')»: void«ENDIF»
        {
            «FOR field : getUserFieldsEntity»
                «field.fieldImpl»
            «ENDFOR»
        }
    '''

    def private addCountryFields(Entity it) '''
        /**
         * Adds country fields.
         */
        public function addCountryFields(FormBuilderInterface $builder, array $options = [])«IF app.targets('3.0')»: void«ENDIF»
        {
            «FOR field : getCountryFieldsEntity»
                «field.fieldImpl»
            «ENDFOR»
        }
    '''

    def private addLanguageFields(Entity it) '''
        /**
         * Adds language fields.
         */
        public function addLanguageFields(FormBuilderInterface $builder, array $options = [])«IF app.targets('3.0')»: void«ENDIF»
        {
            «FOR field : getLanguageFieldsEntity»
                «field.fieldImpl»
            «ENDFOR»
        }
    '''

    def private addLocaleFields(Entity it) '''
        /**
         * Adds locale fields.
         */
        public function addLocaleFields(FormBuilderInterface $builder, array $options = [])«IF app.targets('3.0')»: void«ENDIF»
        {
            «FOR field : getLocaleFieldsEntity»
                «field.fieldImpl»
            «ENDFOR»
        }
    '''

    def private addCurrencyFields(Entity it) '''
        /**
         * Adds currency fields.
         */
        public function addCurrencyFields(FormBuilderInterface $builder, array $options = [])«IF app.targets('3.0')»: void«ENDIF»
        {
            «FOR field : getCurrencyFieldsEntity»
                «field.fieldImpl»
            «ENDFOR»
        }
    '''

    def private addTimezoneFields(Entity it) '''
        /**
         * Adds time zone fields.
         */
        public function addTimezoneFields(FormBuilderInterface $builder, array $options = [])«IF app.targets('3.0')»: void«ENDIF»
        {
            «FOR field : getTimezoneFieldsEntity»
                «field.fieldImpl»
            «ENDFOR»
        }
    '''

    def private addSearchField(Entity it) '''
        /**
         * Adds a search field.
         */
        public function addSearchField(FormBuilderInterface $builder, array $options = [])«IF app.targets('3.0')»: void«ENDIF»
        {
            $builder->add('q', SearchType::class, [
                'label' => $this->__('Search'),
                'attr' => [
                    'maxlength' => 255,
                    'class' => '«IF app.targets('3.0')»form-control«ELSE»input«ENDIF»-sm'
                ],
                'required' => false
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
                    'label' => $this->__('Sort by'),
                    'attr' => [
                        'class' => '«IF app.targets('3.0')»form-control«ELSE»input«ENDIF»-sm'
                    ],
                    'choices' =>             [
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
                    «IF !app.targets('2.0')»
                        'choices_as_values' => true,
                    «ENDIF»
                    'required' => true,
                    'expanded' => false
                ])
                ->add('sortdir', ChoiceType::class, [
                    'label' => $this->__('Sort direction'),
                    'empty_data' => 'asc',
                    'attr' => [
                        'class' => '«IF app.targets('3.0')»form-control«ELSE»input«ENDIF»-sm'
                    ],
                    'choices' => [
                        $this->__('Ascending') => 'asc',
                        $this->__('Descending') => 'desc'
                    ],
                    «IF !app.targets('2.0')»
                        'choices_as_values' => true,
                    «ENDIF»
                    'required' => true,
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
                'label' => $this->__('Page size'),
                'empty_data' => 20,
                'attr' => [
                    'class' => '«IF app.targets('3.0')»form-control«ELSE»input«ENDIF»-sm text-right'
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
                'required' => false,
                'expanded' => false
            ]);
        }
    '''

    def private addBooleanFields(Entity it) '''
        /**
         * Adds boolean fields.
         */
        public function addBooleanFields(FormBuilderInterface $builder, array $options = [])«IF app.targets('3.0')»: void«ENDIF»
        {
            «FOR field : getBooleanFieldsEntity»
                «field.fieldImpl»
            «ENDFOR»
        }
    '''

    def private dispatch fieldImpl(DerivedField it) '''
        $builder->add('«name.formatForCode»', «IF it instanceof StringField && (it as StringField).role == StringRole.LOCALE»Locale«ELSEIF it instanceof ListField && (it as ListField).multiple»MultiList«ELSEIF it instanceof UserField»Entity«ELSE»«fieldType»«ENDIF»Type::class, [
            'label' => $this->__('«IF name == 'workflowState'»State«ELSE»«name.formatForDisplayCapital»«ENDIF»'),
            'attr' => [
                'class' => '«IF app.targets('3.0')»form-control«ELSE»input«ENDIF»-sm'
            ],
            'required' => false,
            «additionalOptions»
        ]);
    '''

    def private dispatch fieldType(DerivedField it) ''''''
    def private dispatch additionalOptions(DerivedField it) ''''''

    def private dispatch fieldType(StringField it) '''«IF role == StringRole.COUNTRY»Country«ELSEIF role == StringRole.CURRENCY»Currency«ELSEIF role == StringRole.LANGUAGE»Language«ELSEIF role == StringRole.LOCALE»Locale«ELSEIF role == StringRole.TIME_ZONE»Timezone«ENDIF»'''
    def private dispatch additionalOptions(StringField it) '''
        «IF !mandatory && #[StringRole.COUNTRY, StringRole.CURRENCY, StringRole.LANGUAGE, StringRole.LOCALE, StringRole.TIME_ZONE].contains(role)»
            'placeholder' => $this->__('All')«IF role == StringRole.LOCALE»,«ENDIF»
        «ENDIF»
        «IF role == StringRole.LOCALE»
            'choices' => $this->localeApi->getSupportedLocaleNames()«IF !app.targets('2.0')»,«ENDIF»
            «IF !app.targets('2.0')»
                'choices_as_values' => true
            «ENDIF»
        «ENDIF»
    '''

    def private dispatch additionalOptions(UserField it) '''
        'placeholder' => $this->__('All'),
        'class' => UserEntity::class,
        'choice_label' => 'uname'
    '''

    def private dispatch fieldType(ListField it) '''«/* called for multiple=false only */»Choice'''
    def private dispatch additionalOptions(ListField it) '''
        'placeholder' => $this->__('All'),
        'choices' => $choices,
        «IF !app.targets('2.0')»
            'choices_as_values' => true,
        «ENDIF»
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
        ]«IF !app.targets('2.0')»,«ENDIF»
        «IF !app.targets('2.0')»
            'choices_as_values' => true
        «ENDIF»
    '''

    def private dispatch fieldImpl(JoinRelationship it) '''
        «val sourceAliasName = getRelationAliasName(false)»
        $queryBuilder = function (EntityRepository $er) {
            // select without joins
            return $er->getListQueryBuilder('', '', false);
        };
        $entityDisplayHelper = $this->entityDisplayHelper;
        $choiceLabelClosure = function ($entity) use ($entityDisplayHelper) {
            return $entityDisplayHelper->getFormattedTitle($entity);
        };
        $builder->add('«sourceAliasName.formatForCode»', EntityType::class, [
            'class' => '«app.appName»:«source.name.formatForCodeCapital»Entity',
            'choice_label' => $choiceLabelClosure,
            'query_builder' => $queryBuilder,
            'placeholder' => $this->__('All'),
            'required' => false,
            'label' => $this->__('«/*(source as Entity).nameMultiple*/sourceAliasName.formatForDisplayCapital»'),
            'attr' => [
                'class' => '«IF app.targets('3.0')»form-control«ELSE»input«ENDIF»-sm'
            ]
        ]);
    '''

    def private quickNavTypeImpl(Entity it) '''
        namespace «app.appNamespace»\Form\Type\QuickNavigation;

        use «app.appNamespace»\Form\Type\QuickNavigation\Base\Abstract«name.formatForCodeCapital»QuickNavType;

        /**
         * «name.formatForDisplayCapital» quick navigation form type implementation class.
         */
        class «name.formatForCodeCapital»QuickNavType extends Abstract«name.formatForCodeCapital»QuickNavType
        {
            // feel free to extend the base form type class here
        }
    '''
}
