package org.zikula.modulestudio.generator.cartridges.zclassic.controller.formtype

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.BooleanField
import de.guite.modulestudio.metamodel.DerivedField
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.EntityWorkflowType
import de.guite.modulestudio.metamodel.JoinRelationship
import de.guite.modulestudio.metamodel.ListField
import de.guite.modulestudio.metamodel.ModuleStudioFactory
import de.guite.modulestudio.metamodel.OneToManyRelationship
import de.guite.modulestudio.metamodel.OneToOneRelationship
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
    Iterable<JoinRelationship> outgoingRelations

    /**
     * Entry point for quick navigation form type.
     */
    def generate(Application it, IMostFileSystemAccess fsa) {
        if (!hasViewActions) {
            return
        }
        app = it
        for (entity : getAllEntities.filter[hasViewAction]) {
            incomingRelations = entity.getBidirectionalIncomingJoinRelations.filter[source instanceof Entity]
            outgoingRelations = entity.getOutgoingJoinRelations.filter[target instanceof Entity]
            fsa.generateClassPair('Form/Type/QuickNavigation/' + entity.name.formatForCodeCapital + 'QuickNavType.php',
                entity.quickNavTypeBaseImpl, entity.quickNavTypeImpl
            )
        }
    }

    def private quickNavTypeBaseImpl(Entity it) '''
        namespace «app.appNamespace»\Form\Type\QuickNavigation\Base;

        «IF !fields.filter(UserField).empty»
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
        «IF !incomingRelations.empty || !outgoingRelations.empty»
            use Symfony\Component\HttpFoundation\RequestStack;
        «ENDIF»
        use Symfony\Component\OptionsResolver\OptionsResolver;
        use Translation\Extractor\Annotation\Ignore;
        «IF hasLocaleFieldsEntity»
            use Zikula\Bundle\FormExtensionBundle\Form\Type\LocaleType;
        «ENDIF»
        «IF categorisable»
            use Zikula\CategoriesBundle\Form\Type\CategoriesType;
        «ENDIF»
        «IF hasLocaleFieldsEntity»
            use Zikula\SettingsBundle\Api\ApiInterface\LocaleApiInterface;
        «ENDIF»
        «IF !fields.filter(UserField).empty»
            use Zikula\UsersBundle\Entity\UserEntity;
        «ENDIF»
        «IF !incomingRelations.empty || !outgoingRelations.empty»
            use «app.appNamespace»\Entity\Factory\EntityFactory;
        «ENDIF»
        «IF !fields.filter(ListField).filter[multiple].empty»
            use «app.appNamespace»\Form\Type\Field\MultiListType;
        «ENDIF»
        «IF !incomingRelations.empty || !outgoingRelations.empty»
            use «app.appNamespace»\Helper\EntityDisplayHelper;
        «ENDIF»
        «IF needsFeatureActivationHelperEntity»
            use «app.appNamespace»\Helper\FeatureActivationHelper;
        «ENDIF»
        «IF hasListFieldsEntity»
            use «app.appNamespace»\Helper\ListEntriesHelper;
        «ENDIF»
        «IF !incomingRelations.empty || !outgoingRelations.empty»
            use «app.appNamespace»\Helper\PermissionHelper;
        «ENDIF»

        /**
         * «name.formatForDisplayCapital» quick navigation form type base class.
         */
        abstract class Abstract«name.formatForCodeCapital»QuickNavType extends AbstractType
        {
            public function __construct(
                «IF !incomingRelations.empty || !outgoingRelations.empty»
                    protected RequestStack $requestStack,
                    protected EntityFactory $entityFactory,
                    protected PermissionHelper $permissionHelper,
                    protected EntityDisplayHelper $entityDisplayHelper«IF hasListFieldsEntity || hasLocaleFieldsEntity || needsFeatureActivationHelperEntity»,«ENDIF»
                «ENDIF»
                «IF hasListFieldsEntity»
                    protected ListEntriesHelper $listHelper«IF hasLocaleFieldsEntity || needsFeatureActivationHelperEntity»,«ENDIF»
                «ENDIF»
                «IF hasLocaleFieldsEntity»
                    protected LocaleApiInterface $localeApi«IF needsFeatureActivationHelperEntity»,«ENDIF»
                «ENDIF»
                «IF needsFeatureActivationHelperEntity»
                    protected FeatureActivationHelper $featureActivationHelper
                «ENDIF»
            ) {
            }

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
                «IF !outgoingRelations.empty»
                    $this->addOutgoingRelationshipFields($builder, $options);
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
                    'label' => 'OK',
                    'attr' => [
                        'class' => 'btn-secondary btn-sm',
                    ],
                ]);
            }

            «IF categorisable»
                «addCategoriesField»

            «ENDIF»
            «IF !incomingRelations.empty»
                «addRelationshipFields('incoming')»

            «ENDIF»
            «IF !outgoingRelations.empty»
                «addRelationshipFields('outgoing')»

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
                    'csrf_protection' => false,
                    'translation_domain' => '«name.formatForCode»',
                ]);
            }
        }
    '''

    def private addCategoriesField(Entity it) '''
        /**
         * Adds a categories field.
         */
        public function addCategoriesField(FormBuilderInterface $builder, array $options = []): void
        {
            $objectType = '«name.formatForCode»';
            $entityCategoryClass = '«app.appNamespace»\Entity\\' . ucfirst($objectType) . 'CategoryEntity';
            $builder->add('categories', CategoriesType::class, [
                'label' => '«IF categorisableMultiSelection»Categories«ELSE»Category«ENDIF»',
                'empty_data' => «IF categorisableMultiSelection»[]«ELSE»null«ENDIF»,
                'attr' => [
                    'class' => 'form-control-sm category-selector',
                    'title' => 'This is an optional filter.',
                ],
                'required' => false,
                'multiple' => «categorisableMultiSelection.displayBool»,
                'bundle' => '«app.appName»',
                'entity' => ucfirst($objectType) . 'Entity',
                'entityCategoryClass' => $entityCategoryClass,
                'showRegistryLabels' => true,
            ]);
        }
    '''

    def private addRelationshipFields(Entity it, String mode) '''
        /**
         * Adds fields for «mode» relationships.
         */
        public function add«mode.toFirstUpper»RelationshipFields(FormBuilderInterface $builder, array $options = []): void
        {
            $mainSearchTerm = '';
            $request = $this->requestStack->getCurrentRequest();
            if ($request->query->has('q')) {
                // remove current search argument from request to avoid filtering related items
                $mainSearchTerm = $request->query->get('q');
                $request->query->remove('q');
            }
            $entityDisplayHelper = $this->entityDisplayHelper;
            «FOR relation : (if (mode == 'incoming') incomingRelations else outgoingRelations)»
                «relation.relationImpl(mode == 'outgoing')»

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
        public function addListFields(FormBuilderInterface $builder, array $options = []): void
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
        public function addUserFields(FormBuilderInterface $builder, array $options = []): void
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
        public function addCountryFields(FormBuilderInterface $builder, array $options = []): void
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
        public function addLanguageFields(FormBuilderInterface $builder, array $options = []): void
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
        public function addLocaleFields(FormBuilderInterface $builder, array $options = []): void
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
        public function addCurrencyFields(FormBuilderInterface $builder, array $options = []): void
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
        public function addTimezoneFields(FormBuilderInterface $builder, array $options = []): void
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
        public function addSearchField(FormBuilderInterface $builder, array $options = []): void
        {
            $builder->add('q', SearchType::class, [
                'label' => 'Search',
                'attr' => [
                    'maxlength' => 255,
                    'class' => 'form-control-sm',
                ],
                'required' => false,
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
                    'attr' => [
                        'class' => 'form-control-sm',
                    ],
                    'choices' => [
                        «val listItemsIn = incoming.filter(OneToManyRelationship).filter[bidirectional && source instanceof Entity]»
                        «val listItemsOut = outgoing.filter(OneToOneRelationship).filter[target instanceof Entity]»
                        «FOR field : getSortingFields»
                            «IF field.name.formatForCode != 'workflowState' || workflow != EntityWorkflowType.NONE»
                                '«field.name.formatForDisplayCapital»' => '«field.name.formatForCode»'«IF !listItemsIn.empty || !listItemsOut.empty || standardFields || field != getDerivedFields.last»,«ENDIF»
                            «ENDIF»
                        «ENDFOR»
                        «FOR relation : listItemsIn»
                            '«relation.getRelationAliasName(false).formatForDisplayCapital»' => '«relation.getRelationAliasName(false)»'«IF !listItemsOut.empty || standardFields || relation != listItemsIn.last»,«ENDIF»
                        «ENDFOR»
                        «FOR relation : listItemsOut»
                            '«relation.getRelationAliasName(true).formatForDisplayCapital»' => '«relation.getRelationAliasName(true)»'«IF standardFields || relation != listItemsOut.last»,«ENDIF»
                        «ENDFOR»
                        «IF standardFields»
                            'Creation date' => 'createdDate',
                            'Creator' => 'createdBy',
                            'Update date' => 'updatedDate',
                            'Updater' => 'updatedBy',
                        «ENDIF»
                    ],
                    'required' => true,
                    'expanded' => false,
                ])
                ->add('sortdir', ChoiceType::class, [
                    'label' => 'Sort direction',
                    'empty_data' => 'asc',
                    'attr' => [
                        'class' => 'form-control-sm',
                    ],
                    'choices' => [
                        'Ascending' => 'asc',
                        'Descending' => 'desc',
                    ],
                    'required' => true,
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
                    'class' => 'form-control-sm text-right',
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
                'required' => false,
                'expanded' => false,
            ]);
        }
    '''

    def private addBooleanFields(Entity it) '''
        /**
         * Adds boolean fields.
         */
        public function addBooleanFields(FormBuilderInterface $builder, array $options = []): void
        {
            «FOR field : getBooleanFieldsEntity»
                «field.fieldImpl»
            «ENDFOR»
        }
    '''

    def private fieldImpl(DerivedField it) '''
        $builder->add('«name.formatForCode»', «IF it instanceof StringField && (it as StringField).role == StringRole.LOCALE»Locale«ELSEIF it instanceof ListField && (it as ListField).multiple»MultiList«ELSEIF it instanceof UserField»Entity«ELSE»«fieldType»«ENDIF»Type::class, [
            'label' => '«IF name == 'workflowState'»State«ELSE»«name.formatForDisplayCapital»«ENDIF»',
            'attr' => [
                'class' => 'form-control-sm',
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
            'placeholder' => 'All'«IF role == StringRole.LOCALE»,«ENDIF»
        «ENDIF»
        «IF role == StringRole.LOCALE»
            /** @Ignore */
            'choices' => $this->localeApi->getSupportedLocaleNames(),
        «ENDIF»
    '''

    def private dispatch additionalOptions(UserField it) '''
        'placeholder' => 'All',
        'class' => UserEntity::class,
        'choice_label' => 'uname',
    '''

    def private dispatch fieldType(ListField it) '''«/* called for multiple=false only */»Choice'''
    def private dispatch additionalOptions(ListField it) '''
        'placeholder' => 'All',
        'choices' => $choices,
        'choice_attr' => $choiceAttributes,
        'multiple' => «multiple.displayBool»,
        'expanded' => false,
    '''

    def private dispatch fieldType(BooleanField it) '''Choice'''
    def private dispatch additionalOptions(BooleanField it) '''
        'placeholder' => 'All',
        'choices' => [
            'No' => 'no',
            'Yes' => 'yes',
        ],
    '''

    def private relationImpl(JoinRelationship it, Boolean useTarget) '''
        «val sourceAliasName = getRelationAliasName(useTarget)»
        $objectType = '«(if (useTarget) target else source).name.formatForCode»';
        // select without joins
        $entities = $this->entityFactory->getRepository($objectType)->selectWhere('', '', false);
        $permLevel = «(if (useTarget) target else source).getPermissionAccessLevel(ModuleStudioFactory.eINSTANCE.createViewAction)»;

        $entities = $this->permissionHelper->filterCollection($objectType, $entities, $permLevel);
        $choices = [];
        foreach ($entities as $entity) {
            $choices[$entity->getId()] = $entity;
        }

        $builder->add('«sourceAliasName.formatForCode»', ChoiceType::class, [
            'choices' => /** @Ignore */$choices,
            'choice_label' => function ($entity) use ($entityDisplayHelper) {
                return $entityDisplayHelper->getFormattedTitle($entity);
            },
            'placeholder' => 'All',
            'required' => false,
            'label' => '«sourceAliasName.formatForDisplayCapital»',
            'attr' => [
                'class' => 'form-control-sm',
            ],
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
