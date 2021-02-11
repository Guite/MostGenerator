package org.zikula.modulestudio.generator.cartridges.zclassic.controller.formtype

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.DataObject
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.EntityTreeType
import de.guite.modulestudio.metamodel.EntityWorkflowType
import de.guite.modulestudio.metamodel.JoinRelationship
import de.guite.modulestudio.metamodel.ListField
import de.guite.modulestudio.metamodel.ManyToManyRelationship
import de.guite.modulestudio.metamodel.MappedSuperClass
import de.guite.modulestudio.metamodel.OneToManyRelationship
import de.guite.modulestudio.metamodel.RelationAutoCompletionUsage
import de.guite.modulestudio.metamodel.RelationEditMode
import de.guite.modulestudio.metamodel.StringField
import de.guite.modulestudio.metamodel.StringRole
import de.guite.modulestudio.metamodel.UploadField
import de.guite.modulestudio.metamodel.UserField
import java.util.ArrayList
import java.util.List
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.DateTimeExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.ModelInheritanceExtensions
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class EditEntityType {

    extension ControllerExtensions = new ControllerExtensions
    extension DateTimeExtensions = new DateTimeExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelExtensions = new ModelExtensions
    extension ModelInheritanceExtensions = new ModelInheritanceExtensions
    extension ModelJoinExtensions = new ModelJoinExtensions
    extension NamingExtensions = new NamingExtensions
    extension SharedFormTypeFields = new SharedFormTypeFields
    extension Utils = new Utils

    Application app

    List<String> extensions = newArrayList
    Iterable<JoinRelationship> incomingRelations
    Iterable<JoinRelationship> outgoingRelations

    /**
     * Entry point for entity editing form type.
     */
    def generate(DataObject it, IMostFileSystemAccess fsa) {
        if (!(it instanceof MappedSuperClass) && !(it as Entity).hasEditAction) {
            return
        }
        if (it instanceof Entity) {
            if (hasTranslatableFields) extensions.add('translatable')
            if (attributable) extensions.add('attributes')
            if (categorisable) extensions.add('categories')
        }
        app = it.application
        incomingRelations = getEditableJoinRelations(true).filter[getEditStageCode(true) > 0]
        outgoingRelations = getEditableJoinRelations(false).filter[getEditStageCode(false) > 0]
        fsa.generateClassPair('Form/Type/' + name.formatForCodeCapital + 'Type.php', editTypeBaseImpl, editTypeImpl)
    }

    def private editTypeBaseImpl(DataObject it) '''
        namespace «app.appNamespace»\Form\Type\Base;

        «IF !incomingRelations.empty || !outgoingRelations.empty»
            use Doctrine\ORM\EntityRepository;
        «ENDIF»
        «fields.formTypeImports(app, it)»
        use «entityClassName('', false)»;
        «IF it instanceof Entity && (it as Entity).categorisable»
            use «entityClassName('Category', false)»;
        «ENDIF»
        «IF isInheriting»
            use «app.appNamespace»\Form\Type\«getParentDataObjects(newArrayList).head.name.formatForCodeCapital»Type;
        «ENDIF»
        «IF it instanceof Entity && (it as Entity).tree != EntityTreeType.NONE»
            use «app.appNamespace»\Form\Type\Field\EntityTreeType;
        «ENDIF»
        «IF !incoming.empty || !outgoing.empty»
            use «app.appNamespace»\Helper\CollectionFilterHelper;
            use «app.appNamespace»\Helper\EntityDisplayHelper;
        «ENDIF»
        «IF app.needsFeatureActivationHelper»
            use «app.appNamespace»\Helper\FeatureActivationHelper;
        «ENDIF»
        «IF hasListFieldsEntity»
            use «app.appNamespace»\Helper\ListEntriesHelper;
        «ENDIF»
        «IF isTranslatable»
            use «app.appNamespace»\Helper\TranslatableHelper;
        «ENDIF»
        «IF hasUploadFieldsEntity»
            use «app.appNamespace»\Helper\UploadHelper;
        «ENDIF»
        «IF it instanceof Entity && (it as Entity).standardFields»
            use «application.appNamespace»\Traits\ModerationFormFieldsTrait;
        «ENDIF»
        «IF it instanceof Entity && (it as Entity).workflow != EntityWorkflowType.NONE»
            use «application.appNamespace»\Traits\WorkflowFormFieldsTrait;
        «ENDIF»

        /**
         * «name.formatForDisplayCapital» editing form type base class.
         */
        abstract class Abstract«name.formatForCodeCapital»Type extends AbstractType
        {
            «IF !app.targets('3.0')»
                use TranslatorTrait;

            «ENDIF»
            «IF application.targets('3.0') && !fields.filter(StringField).filter[#[StringRole.COUNTRY, StringRole.CURRENCY, StringRole.LANGUAGE, StringRole.LOCALE, StringRole.TIME_ZONE].contains(role)].empty»
                /**
                 * @var RequestStack
                 */
                protected $requestStack;

            «ENDIF»
            «IF it instanceof Entity && (it as Entity).standardFields»
                use ModerationFormFieldsTrait;
            «ENDIF»
            «IF it instanceof Entity && (it as Entity).workflow != EntityWorkflowType.NONE»
                use WorkflowFormFieldsTrait;
            «ENDIF»

            /**
             * @var EntityFactory
             */
            protected $entityFactory;
            «IF !incoming.empty || !outgoing.empty»

                /**
                 * @var CollectionFilterHelper
                 */
                protected $collectionFilterHelper;

                /**
                 * @var EntityDisplayHelper
                 */
                protected $entityDisplayHelper;
            «ENDIF»
            «IF isTranslatable»

                /**
                 * @var VariableApiInterface
                 */
                protected $variableApi;

                /**
                 * @var TranslatableHelper
                 */
                protected $translatableHelper;
            «ENDIF»
            «IF hasListFieldsEntity»

                /**
                 * @var ListEntriesHelper
                 */
                protected $listHelper;
            «ENDIF»
            «IF hasUploadFieldsEntity»

                /**
                 * @var UploadHelper
                 */
                protected $uploadHelper;
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
                «IF !application.targets('3.0')»
                    TranslatorInterface $translator,
                «ELSEIF application.targets('3.0') && !fields.filter(StringField).filter[#[StringRole.COUNTRY, StringRole.CURRENCY, StringRole.LANGUAGE, StringRole.LOCALE, StringRole.TIME_ZONE].contains(role)].empty»
                    RequestStack $requestStack,
                «ENDIF»
                EntityFactory $entityFactory«IF !incoming.empty || !outgoing.empty»,
                CollectionFilterHelper $collectionFilterHelper,
                EntityDisplayHelper $entityDisplayHelper«ENDIF»«IF isTranslatable»,
                VariableApiInterface $variableApi,
                TranslatableHelper $translatableHelper«ENDIF»«IF hasListFieldsEntity»,
                ListEntriesHelper $listHelper«ENDIF»«IF hasUploadFieldsEntity»,
                UploadHelper $uploadHelper«ENDIF»«IF hasLocaleFieldsEntity»,
                LocaleApiInterface $localeApi«ENDIF»«IF app.needsFeatureActivationHelper»,
                FeatureActivationHelper $featureActivationHelper«ENDIF»
            ) {
                «IF !application.targets('3.0')»
                    $this->setTranslator($translator);
                «ELSEIF application.targets('3.0') && !fields.filter(StringField).filter[#[StringRole.COUNTRY, StringRole.CURRENCY, StringRole.LANGUAGE, StringRole.LOCALE, StringRole.TIME_ZONE].contains(role)].empty»
                    $this->requestStack = $requestStack;
                «ENDIF»
                $this->entityFactory = $entityFactory;
                «IF !incoming.empty || !outgoing.empty»
                    $this->collectionFilterHelper = $collectionFilterHelper;
                    $this->entityDisplayHelper = $entityDisplayHelper;
                «ENDIF»
                «IF isTranslatable»
                    $this->variableApi = $variableApi;
                    $this->translatableHelper = $translatableHelper;
                «ENDIF»
                «IF hasListFieldsEntity»
                    $this->listHelper = $listHelper;
                «ENDIF»
                «IF hasUploadFieldsEntity»
                    $this->uploadHelper = $uploadHelper;
                «ENDIF»
                «IF hasLocaleFieldsEntity»
                    $this->localeApi = $localeApi;
                «ENDIF»
                «IF app.needsFeatureActivationHelper»
                    $this->featureActivationHelper = $featureActivationHelper;
                «ENDIF»
            }
            «IF !app.targets('3.0')»

                «app.setTranslatorMethod»
            «ENDIF»

            public function buildForm(FormBuilderInterface $builder, array $options)
            {
                «IF it instanceof Entity && (it as Entity).tree != EntityTreeType.NONE»
                    if ('create' === $options['mode']) {
                        $builder->add('parent', EntityTreeType::class, [
                            'class' => «name.formatForCodeCapital»Entity::class,
                            'multiple' => false,
                            'expanded' => false,
                            'use_joins' => false,
                            'label' => «IF !app.targets('3.0')»$this->__(«ENDIF»'Parent «name.formatForDisplay»'«IF !app.targets('3.0')»)«ENDIF»,
                            'attr' => [
                                'title' => «IF !app.targets('3.0')»$this->__(«ENDIF»'Choose the parent «name.formatForDisplay».'«IF !app.targets('3.0')»)«ENDIF»,
                            ],
                        ]);
                    }
                «ENDIF»
                $this->addEntityFields($builder, $options);
                «IF isInheriting»
                    «val parents = getParentDataObjects(newArrayList)»
                    $builder->add('parentFields', «parents.head.name.formatForCodeCapital»Type::class, [
                        'label' => «IF !app.targets('3.0')»$this->__(«ENDIF»'«parents.head.name.formatForDisplayCapital» data'«IF !app.targets('3.0')»)«ENDIF»,
                        'inherit_data' => true,
                        'data_class' => «name.formatForCodeCapital»Entity::class
                    ]);
                «ENDIF»
                «IF extensions.contains('attributes')»
                    if ($this->featureActivationHelper->isEnabled(FeatureActivationHelper::ATTRIBUTES, '«name.formatForCode»')) {
                        $this->addAttributeFields($builder, $options);
                    }
                «ENDIF»
                «IF extensions.contains('categories')»
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
                «IF it instanceof Entity && (it as Entity).workflow != EntityWorkflowType.NONE»
                    $this->addAdditionalNotificationRemarksField($builder, $options);
                «ENDIF»
                «IF isInheriter»
                    if (!$options['inherit_data']) {
                        «IF it instanceof Entity && (it as Entity).standardFields»
                            $this->addModerationFields($builder, $options);
                        «ENDIF»
                        $this->addSubmitButtons($builder, $options);
                    }
                «ELSE»
                    «IF it instanceof Entity && (it as Entity).standardFields»
                        $this->addModerationFields($builder, $options);
                    «ENDIF»
                    $this->addSubmitButtons($builder, $options);
                «ENDIF»
            }

            «addFields»

            «IF it instanceof Entity && (it as Entity).geographical»
                «addGeographicalFields(it as Entity)»

            «ENDIF»
            «IF extensions.contains('attributes')»
                «addAttributeFields(it as Entity)»

            «ENDIF»
            «IF extensions.contains('categories')»
                «addCategoriesField(it as Entity)»

            «ENDIF»
            «IF !incomingRelations.empty»
                «addIncomingRelationshipFields»

            «ENDIF»
            «IF !outgoingRelations.empty»
                «addOutgoingRelationshipFields»

            «ENDIF»
            «IF it instanceof Entity»
                «addSubmitButtons»

            «ENDIF»
            public function getBlockPrefix()
            {
                return '«app.appName.formatForDB»_«name.formatForDB»';
            }

            public function configureOptions(OptionsResolver $resolver)
            {
                $resolver
                    ->setDefaults([
                        // define class for underlying data (required for embedding forms)
                        'data_class' => «name.formatForCodeCapital»Entity::class,
                        «IF app.targets('3.0') && !app.isSystemModule»
                            'translation_domain' => '«name.formatForCode»',
                        «ENDIF»
                        'empty_data' => function (FormInterface $form) {
                            return $this->entityFactory->create«name.formatForCodeCapital»();
                        },
                        'error_mapping' => [
                            «FOR field : fields.filter(ListField).filter[multiple]»
                                'is«field.name.formatForCodeCapital»ValueAllowed' => '«field.name.formatForCode»',
                            «ENDFOR»
                            «FOR field : fields.filter(UserField)»
                                'is«field.name.formatForCodeCapital»UserValid' => '«field.name.formatForCode»',
                            «ENDFOR»
                            «FOR field : fields.filter(UploadField)»
                                '«field.name.formatForCode»' => '«field.name.formatForCode».«field.name.formatForCode»',
                            «ENDFOR»
                            «FOR field : getDirectTimeFields.filter[mandatory && (past || future)]»
                                «IF field.past»
                                    'is«field.name.formatForCodeCapital»TimeValidPast' => '«field.name.formatForCode»',
                                «ELSEIF field.future»
                                    'is«field.name.formatForCodeCapital»TimeValidFuture' => '«field.name.formatForCode»',
                                «ENDIF»
                            «ENDFOR»
                            «IF hasStartAndEndDateField»
                                'is«startDateField.name.formatForCodeCapital»Before«endDateField.name.formatForCodeCapital»' => '«startDateField.name.formatForCode»',
                            «ENDIF»
                        ],
                        'mode' => 'create',
                        «IF extensions.contains('attributes')»
                            'attributes' => [],
                        «ENDIF»
                        «IF it instanceof Entity && (it as Entity).workflow != EntityWorkflowType.NONE»
                            'is_moderator' => false,
                            «IF it instanceof Entity && (it as Entity).workflow == EntityWorkflowType.ENTERPRISE»
                                'is_super_moderator' => false,
                            «ENDIF»
                            'is_creator' => false,
                        «ENDIF»
                        'actions' => [],
                        «IF it instanceof Entity && (it as Entity).standardFields»
                            'has_moderate_permission' => false,
                            'allow_moderation_specific_creator' => false,
                            'allow_moderation_specific_creation_date' => false,
                        «ENDIF»
                        «IF it instanceof Entity && (it as Entity).hasTranslatableFields»
                            'translations' => [],
                        «ENDIF»
                        «IF !incoming.empty || !outgoing.empty»
                            'filter_by_ownership' => true,
                            'inline_usage' => false,
                        «ENDIF»
                    ])
                    ->setRequired([«IF hasUploadFieldsEntity»'entity', «ENDIF»'mode', 'actions'])
                    ->setAllowedTypes('mode', 'string')
                    «IF extensions.contains('attributes')»
                        ->setAllowedTypes('attributes', 'array')
                    «ENDIF»
                    «IF it instanceof Entity && (it as Entity).workflow != EntityWorkflowType.NONE»
                        ->setAllowedTypes('is_moderator', 'bool')
                        «IF it instanceof Entity && (it as Entity).workflow == EntityWorkflowType.ENTERPRISE»
                            ->setAllowedTypes('is_super_moderator', 'bool')
                        «ENDIF»
                        ->setAllowedTypes('is_creator', 'bool')
                    «ENDIF»
                    ->setAllowedTypes('actions', 'array')
                    «IF it instanceof Entity && (it as Entity).standardFields»
                        ->setAllowedTypes('has_moderate_permission', 'bool')
                        ->setAllowedTypes('allow_moderation_specific_creator', 'bool')
                        ->setAllowedTypes('allow_moderation_specific_creation_date', 'bool')
                    «ENDIF»
                    «IF it instanceof Entity && (it as Entity).hasTranslatableFields»
                        ->setAllowedTypes('translations', 'array')
                    «ENDIF»
                    «IF !incoming.empty || !outgoing.empty»
                        ->setAllowedTypes('filter_by_ownership', 'bool')
                        ->setAllowedTypes('inline_usage', 'bool')
                    «ENDIF»
                    ->setAllowedValues('mode', ['create', 'edit'])
                ;
            }
        }
    '''

    def private addFields(DataObject it) '''
        /**
         * Adds basic entity fields.
         */
        public function addEntityFields(FormBuilderInterface $builder, array $options = [])«IF app.targets('3.0')»: void«ENDIF»
        {
            «IF it instanceof Entity && isTranslatable»
                «translatableFields(it as Entity)»
            «ENDIF»
            «fieldAdditions(isTranslatable)»
        }
    '''

    def private isTranslatable(DataObject it) {
        extensions.contains('translatable')
    }

    def private translatableFields(Entity it) '''
        «translatableFieldSet»

        if ($this->variableApi->getSystemVar('multilingual') && $this->featureActivationHelper->isEnabled(FeatureActivationHelper::TRANSLATIONS, '«name.formatForCode»')) {
            $supportedLanguages = $this->translatableHelper->getSupportedLanguages('«name.formatForCode»');
            if (is_array($supportedLanguages) && count($supportedLanguages) > 1) {
                $currentLanguage = $this->translatableHelper->getCurrentLanguage();
                $translatableFields = $this->translatableHelper->getTranslatableFields('«name.formatForCode»');
                $mandatoryFields = $this->translatableHelper->getMandatoryFields('«name.formatForCode»');
                foreach ($supportedLanguages as $language) {
                    if ($language === $currentLanguage) {
                        continue;
                    }
                    $builder->add('translations' . $language, TranslationType::class, [
                        'fields' => $translatableFields,
                        'mandatory_fields' => $mandatoryFields[$language],
                        «IF app.targets('3.0')»
                            'values' => $options['translations'][$language] ?? [],
                        «ELSE»
                            'values' => isset($options['translations'][$language]) ? $options['translations'][$language] : [],
                        «ENDIF»
                    ]);
                }
            }
        }
    '''

    def private fieldAdditions(DataObject it, Boolean isTranslatable) '''
        «IF !isTranslatable || !getEditableNonTranslatableFields.empty»
            «IF isTranslatable»
                «FOR field : getEditableNonTranslatableFields»«field.definition»«ENDFOR»
            «ELSE»
                «FOR field : getEditableFields»«field.definition»«ENDFOR»
            «ENDIF»
        «ENDIF»
        «IF it instanceof Entity»
            «IF hasSluggableFields && (!isTranslatable || !hasTranslatableSlug)»

                «slugField»
            «ENDIF»
            «IF geographical»
                $this->addGeographicalFields($builder, $options);
            «ENDIF»
        «ENDIF»
    '''

    def private translatableFieldSet(Entity it) '''
        «FOR field : getEditableTranslatableFields»«field.definition»«ENDFOR»
        «IF hasTranslatableSlug»
            «slugField»
        «ENDIF»
    '''

    def private slugField(Entity it) '''
        «IF hasSluggableFields && slugUpdatable»
            $helpText = «IF !app.targets('3.0')»$this->__(«ELSE»/** @Translate */«ENDIF»'You can input a custom permalink for the «name.formatForDisplay» or let this field free to create one automatically.'«IF !app.targets('3.0')»)«ENDIF»;
            «IF hasTranslatableSlug»
                if ('create' !== $options['mode']) {
                    $helpText = '';
                }
            «ENDIF»
            $builder->add('slug', TextType::class, [
                'label' => «IF !app.targets('3.0')»$this->__(«ENDIF»'Permalink:'«IF !app.targets('3.0')»)«ENDIF»,
                'required' => «IF hasTranslatableSlug»'create' !== $options['mode']«ELSE»false«ENDIF»,
                «/*IF hasTranslatableSlug»
                    'empty_data' => '',
                «ENDIF*/»'attr' => [
                    'maxlength' => «slugLength»,
                    «IF slugUnique»
                        'class' => 'validate-unique',
                    «ENDIF»
                    «IF app.targets('3.0')»
                        /** @Ignore */
                    «ENDIF»
                    'title' => $helpText,
                ],
                «IF app.targets('3.0')»
                    /** @Ignore */
                «ENDIF»
                'help' => $helpText,
            ]);
        «ENDIF»
    '''

    def private addGeographicalFields(Entity it) '''
        /**
         * Adds fields for coordinates.
         */
        public function addGeographicalFields(FormBuilderInterface $builder, array $options = [])«IF app.targets('3.0')»: void«ENDIF»
        {
            «FOR geoFieldName : newArrayList('latitude', 'longitude')»
                $builder->add('«geoFieldName»', GeoType::class, [
                    'label' => «IF !app.targets('3.0')»$this->__(«ENDIF»'«geoFieldName.toFirstUpper»:'«IF !app.targets('3.0')»)«ENDIF»,
                    'required' => false
                ]);
            «ENDFOR»
        }
    '''

    def private addAttributeFields(Entity it) '''
        /**
         * Adds fields for attributes.
         */
        public function addAttributeFields(FormBuilderInterface $builder, array $options = [])«IF app.targets('3.0')»: void«ENDIF»
        {
            foreach ($options['attributes'] as $attributeName => $attributeValue) {
                $builder->add('attributes' . $attributeName, TextType::class, [
                    'mapped' => false,
                    «IF app.targets('3.0')»
                        /** @Ignore */
                        'label' => $attributeName,
                    «ELSE»
                        'label' => $this->__(/** @Ignore */$attributeName),
                    «ENDIF»
                    'attr' => [
                        'maxlength' => 255,
                    ],
                    'data' => $attributeValue,
                    'required' => false,
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
            $builder->add('categories', CategoriesType::class, [
                'label' => «IF !app.targets('3.0')»$this->__(«ENDIF»'«IF categorisableMultiSelection»Categories«ELSE»Category«ENDIF»:'«IF !app.targets('3.0')»)«ENDIF»,
                'empty_data' => «IF categorisableMultiSelection»[]«ELSE»null«ENDIF»,
                'attr' => [
                    'class' => 'category-selector',
                ],
                'required' => false,
                'multiple' => «categorisableMultiSelection.displayBool»,
                'module' => '«app.appName»',
                'entity' => '«name.formatForCodeCapital»Entity',
                'entityCategoryClass' => «name.formatForCodeCapital»CategoryEntity::class,
                'showRegistryLabels' => true,
            ]);
        }
    '''

    def private addIncomingRelationshipFields(DataObject it) '''
        /**
         * Adds fields for incoming relationships.
         */
        public function addIncomingRelationshipFields(FormBuilderInterface $builder, array $options = [])«IF app.targets('3.0')»: void«ENDIF»
        {
            «FOR relation : incomingRelations»
                «val autoComplete = relation.useAutoCompletion != RelationAutoCompletionUsage.NONE && relation.useAutoCompletion != RelationAutoCompletionUsage.ONLY_TARGET_SIDE»
                «relation.relationDefinition(false, autoComplete)»
            «ENDFOR»
        }
    '''

    def private addOutgoingRelationshipFields(DataObject it) '''
        /**
         * Adds fields for outgoing relationships.
         */
        public function addOutgoingRelationshipFields(FormBuilderInterface $builder, array $options = [])«IF app.targets('3.0')»: void«ENDIF»
        {
            «FOR relation : outgoingRelations»
                «val autoComplete = relation.useAutoCompletion != RelationAutoCompletionUsage.NONE && relation.useAutoCompletion != RelationAutoCompletionUsage.ONLY_SOURCE_SIDE»
                «relation.relationDefinition(true, autoComplete)»
            «ENDFOR»
        }
    '''

    def private relationDefinition(JoinRelationship it, Boolean outgoing, Boolean autoComplete) '''
        «val aliasName = getRelationAliasName(outgoing)»
        «val relatedEntity = if (outgoing) target else source»
        «val editMode = if (outgoing) getSourceEditMode else getTargetEditMode»
        «IF editMode == RelationEditMode.EMBEDDED»
            $builder->add('«aliasName.formatForCode»', '«app.appNamespace»\Form\Type\«relatedEntity.name.formatForCodeCapital»Type', [
                «IF isManySide(outgoing)»
                    'by_reference' => false,
                «ENDIF»
                «IF /*outgoing && */nullable»
                    'required' => false,
                «ENDIF»
                'inline_usage' => true,
                'label' => «IF !app.targets('3.0')»$this->__(«ENDIF»'«aliasName.formatForDisplayCapital»'«IF !app.targets('3.0')»)«ENDIF»,
                «relationHelp(outgoing)»
                'attr' => [
                    'title' => «IF !app.targets('3.0')»$this->__(«ENDIF»'Choose the «aliasName.formatForDisplay».'«IF !app.targets('3.0')»)«ENDIF»,
                ],
            ]);
        «ELSE»
            $queryBuilder = function (EntityRepository $er) {«/* get repo from entity factory to ensure CollectionFilterHelper is set return $er->getListQueryBuilder('', '', false);*/»
                return $this->entityFactory->getRepository('«relatedEntity.name.formatForCode»')->getListQueryBuilder('', '', false);
            };
            «IF (relatedEntity as Entity).ownerPermission»
                if (true === $options['filter_by_ownership']) {
                    $collectionFilterHelper = $this->collectionFilterHelper;
                    $queryBuilder = function (EntityRepository $er) use ($collectionFilterHelper) {
                        $qb = $this->entityFactory->getRepository('«relatedEntity.name.formatForCode»')->getListQueryBuilder('', '', false);
                        $qb = $collectionFilterHelper->addCreatorFilter($qb);

                        return $qb;
                    };
                }
            «ENDIF»
            «IF !autoComplete»
                $entityDisplayHelper = $this->entityDisplayHelper;
                $choiceLabelClosure = function ($entity) use ($entityDisplayHelper) {
                    return $entityDisplayHelper->getFormattedTitle($entity);
                };
            «ENDIF»
            «val isExpanded = if (outgoing) expandedTarget else expandedSource»
            $builder->add('«aliasName.formatForCode»', '«formType(autoComplete)»Type', [
                «IF autoComplete»
                    «val uniqueNameForJs = getUniqueRelationNameForJs((if (outgoing) source else target), aliasName.formatForCodeCapital)»
                    'object_type' => '«relatedEntity.name.formatForCode»',
                    «IF isManySide(outgoing)»
                        'by_reference' => false,
                    «ENDIF»
                    'multiple' => «isManySide(outgoing).displayBool»,
                    'unique_name_for_js' => '«uniqueNameForJs»',
                    'allow_editing' => «(getEditStageCode(!outgoing) > 1).displayBool»,
                    «IF outgoing && nullable»
                        'required' => false,
                    «ENDIF»
                «ELSE»
                    'class' => '«app.appName»:«relatedEntity.name.formatForCodeCapital»Entity',
                    'choice_label' => $choiceLabelClosure,
                    «IF isManySide(outgoing)»
                        'by_reference' => false,
                    «ENDIF»
                    'multiple' => «isManySide(outgoing).displayBool»,
                    'expanded' => «isExpanded.displayBool»,
                    'query_builder' => $queryBuilder,
                    «IF /*outgoing && */nullable»
                        «IF !isManySide(outgoing) && !isExpanded/* expanded uses default: "None" */»
                            'placeholder' => «IF !app.targets('3.0')»$this->__(«ENDIF»'Please choose an option.'«IF !app.targets('3.0')»)«ENDIF»,
                        «ENDIF»
                        'required' => false,
                    «ENDIF»
                «ENDIF»
                'label' => «IF !app.targets('3.0')»$this->__(«ENDIF»'«aliasName.formatForDisplayCapital»'«IF !app.targets('3.0')»)«ENDIF»,
                «IF !autoComplete && isExpanded»
                    'label_attr' => [
                        'class' => '«IF isManySide(outgoing)»checkbox«ELSE»radio«ENDIF»-inline'
                    ],
                «ENDIF»
                «relationHelp(outgoing)»
                'attr' => [
                    'title' => «IF !app.targets('3.0')»$this->__(«ENDIF»'Choose the «aliasName.formatForDisplay».'«IF !app.targets('3.0')»)«ENDIF»,
                ],
            ]);
        «ENDIF»
    '''

    def private relationHelp(JoinRelationship it, Boolean outgoing) {
        val messages = if (application.targets('3.0')) relationHelpMessages(outgoing) else relationHelpMessagesLegacy(outgoing)
        val parameters = if (application.targets('3.0')) relationHelpMessageParameters(outgoing) else newArrayList
        new SharedFormTypeHelper().displayHelpMessages(application, messages, parameters)
    }

    def private dispatch ArrayList<String> relationHelpMessages(JoinRelationship it, Boolean outgoing) {
        newArrayList
    }
    def private dispatch relationHelpMessages(OneToManyRelationship it, Boolean outgoing) {
        val messages = newArrayList

        if (!outgoing) {
            return messages
        }

        if (minTarget > 0 && maxTarget > 0) {
            if (minTarget == maxTarget) {
                messages += '''«''»'Note: you must select exactly %amount% choices.'«''»'''
            } else {
                messages += '''«''»'Note: you must select between %min% and %max% choices.'«''»'''
            }
        } else if (minTarget > 0) {
            messages += '''«''»'Note: you must select at least %min% choices.'«''»'''
        } else if (maxTarget > 0) {
            messages += '''«''»'Note: you must not select more than %max% choices.'«''»'''
        }

        messages
    }
    def private dispatch relationHelpMessages(ManyToManyRelationship it, Boolean outgoing) {
        val messages = newArrayList

        if (!outgoing) {
            if (minSource > 0 && maxSource > 0) {
                if (minSource == maxSource) {
                    messages += '''«''»'Note: you must select exactly %amount% choices.'«''»'''
                } else {
                    messages += '''«''»'Note: you must select between %min% and %max% choices.'«''»'''
                }
            } else if (minSource > 0) {
                messages += '''«''»'Note: you must select at least %min% choices.'«''»'''
            } else if (maxSource > 0) {
                messages += '''«''»'Note: you must not select more than %max% choices.'«''»'''
            }
    	} else {
            if (minTarget > 0 && maxTarget > 0) {
                if (minTarget == maxTarget) {
                    messages += '''«''»'Note: you must select exactly %amount% choices.'«''»'''
                } else {
                    messages += '''«''»'Note: you must select between %min% and %max% choices.'«''»'''
                }
            } else if (minTarget > 0) {
                messages += '''«''»'Note: you must select at least %min% choices.'«''»'''
            } else if (maxTarget > 0) {
                messages += '''«''»'Note: you must not select more than %max% choices.'«''»'''
            }
        }

        messages
    }
    def private dispatch ArrayList<String> relationHelpMessageParameters(JoinRelationship it, Boolean outgoing) {
        newArrayList
    }
    def private dispatch relationHelpMessageParameters(OneToManyRelationship it, Boolean outgoing) {
        val parameters = newArrayList

        if (!outgoing) {
            return parameters
        }

        if (minTarget > 0 && maxTarget > 0) {
            if (minTarget == maxTarget) {
                parameters += '''«''»'%amount%' => «minTarget»'''
            } else {
                parameters += '''«''»'%min%' => «minTarget»'''
                parameters += '''«''»'%max%' => «maxTarget»'''
            }
        } else if (minTarget > 0) {
            parameters += '''«''»'%min%' => «minTarget»'''
        } else if (maxTarget > 0) {
            parameters += '''«''»'%max%' => «maxTarget»'''
        }

        parameters
    }
    def private dispatch relationHelpMessageParameters(ManyToManyRelationship it, Boolean outgoing) {
        val parameters = newArrayList

        if (!outgoing) {
            if (minSource > 0 && maxSource > 0) {
                if (minSource == maxSource) {
                    parameters += '''«''»'%amount%' => «minSource»'''
                } else {
                    parameters += '''«''»'%min%' => «minSource»'''
                    parameters += '''«''»'%max%' => «maxSource»'''
                }
            } else if (minSource > 0) {
                parameters += '''«''»'%min%' => «minSource»'''
            } else if (maxSource > 0) {
                parameters += '''«''»'%max%' => «maxSource»'''
            }
    	} else {
            if (minTarget > 0 && maxTarget > 0) {
                if (minTarget == maxTarget) {
                    parameters += '''«''»'%amount%' => «minTarget»])'''
                } else {
                    parameters += '''«''»'%min%' => «minTarget», '%max%' => «maxTarget»]'''
                }
            } else if (minTarget > 0) {
                parameters += '''«''»'%min%' => «minTarget»'''
            } else if (maxTarget > 0) {
                parameters += '''«''»'%max%' => «maxTarget»'''
            }
        }

        parameters
    }
    def private dispatch ArrayList<String> relationHelpMessagesLegacy(JoinRelationship it, Boolean outgoing) {
        newArrayList
    }
    def private dispatch relationHelpMessagesLegacy(OneToManyRelationship it, Boolean outgoing) {
        val messages = newArrayList

        if (!outgoing) {
            return messages
        }

        if (minTarget > 0 && maxTarget > 0) {
            if (minTarget == maxTarget) {
                messages += '''$this->__f('Note: you must select exactly %amount% choices.', ['%amount%' => «minTarget»])'''
            } else {
                messages += '''$this->__f('Note: you must select between %min% and %max% choices.', ['%min%' => «minTarget», '%max%' => «maxTarget»])'''
            }
        } else if (minTarget > 0) {
            messages += '''$this->__f('Note: you must select at least %min% choices.', ['%min%' => «minTarget»])'''
        } else if (maxTarget > 0) {
            messages += '''$this->__f('Note: you must not select more than %max% choices.', ['%max%' => «maxTarget»])'''
        }

        messages
    }
    def private dispatch relationHelpMessagesLegacy(ManyToManyRelationship it, Boolean outgoing) {
        val messages = newArrayList

        if (!outgoing) {
            if (minSource > 0 && maxSource > 0) {
                if (minSource == maxSource) {
                    messages += '''$this->__f('Note: you must select exactly %amount% choices.', ['%amount%' => «minSource»])'''
                } else {
                    messages += '''$this->__f('Note: you must select between %min% and %max% choices.', ['%min%' => «minSource», '%max%' => «maxSource»])'''
                }
            } else if (minSource > 0) {
                messages += '''$this->__f('Note: you must select at least %min% choices.', ['%min%' => «minSource»])'''
            } else if (maxSource > 0) {
                messages += '''$this->__f('Note: you must not select more than %max% choices.', ['%max%' => «maxSource»])'''
            }
    	} else {
            if (minTarget > 0 && maxTarget > 0) {
                if (minTarget == maxTarget) {
                    messages += '''$this->__f('Note: you must select exactly %amount% choices.', ['%amount%' => «minTarget»])'''
                } else {
                    messages += '''$this->__f('Note: you must select between %min% and %max% choices.', ['%min%' => «minTarget», '%max%' => «maxTarget»])'''
                }
            } else if (minTarget > 0) {
                messages += '''$this->__f('Note: you must select at least %min% choices.', ['%min%' => «minTarget»])'''
            } else if (maxTarget > 0) {
                messages += '''$this->__f('Note: you must not select more than %max% choices.', ['%max%' => «maxTarget»])'''
            }
        }

        messages
    }

    def private formType(JoinRelationship it, Boolean autoComplete) {
        if (autoComplete) '''«app.appNamespace»\Form\Type\Field\AutoCompletionRelation'''
        else '''Symfony\Bridge\Doctrine\Form\Type\Entity'''
    }

    def private addSubmitButtons(Entity it) '''
        /**
         * Adds submit buttons.
         */
        public function addSubmitButtons(FormBuilderInterface $builder, array $options = [])«IF app.targets('3.0')»: void«ENDIF»
        {
            foreach ($options['actions'] as $action) {
                $builder->add($action['id'], SubmitType::class, [
                    «IF app.targets('3.0')»
                        /** @Ignore */
                    «ENDIF»
                    'label' => $action['title'],
                    'icon' => 'delete' === $action['id'] ? 'fa-trash-«IF app.targets('3.0')»alt«ELSE»o«ENDIF»' : '',
                    'attr' => [
                        'class' => $action['buttonClass'],
                    ],
                ]);
                if ('create' === $options['mode'] && 'submit' === $action['id']«IF !incoming.empty || !outgoing.empty» && !$options['inline_usage']«ENDIF») {
                    // add additional button to submit item and return to create form
                    $builder->add('submitrepeat', SubmitType::class, [
                        'label' => «IF !app.targets('3.0')»$this->__(«ENDIF»'Submit and repeat'«IF !app.targets('3.0')»)«ENDIF»,
                        'icon' => 'fa-repeat',
                        'attr' => [
                            'class' => $action['buttonClass'],
                        ],
                    ]);
                }
            }
            «app.addCommonSubmitButtons»
        }
    '''

    def private editTypeImpl(DataObject it) '''
        namespace «app.appNamespace»\Form\Type;

        use «app.appNamespace»\Form\Type\Base\Abstract«name.formatForCodeCapital»Type;

        /**
         * «name.formatForDisplayCapital» editing form type implementation class.
         */
        class «name.formatForCodeCapital»Type extends Abstract«name.formatForCodeCapital»Type
        {
            // feel free to extend the «name.formatForDisplay» editing form type class here
        }
    '''
}
