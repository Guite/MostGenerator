package org.zikula.modulestudio.generator.cartridges.zclassic.controller.formtype

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.DataObject
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.EntityWorkflowType
import de.guite.modulestudio.metamodel.JoinRelationship
import de.guite.modulestudio.metamodel.ListField
import de.guite.modulestudio.metamodel.ManyToManyRelationship
import de.guite.modulestudio.metamodel.MappedSuperClass
import de.guite.modulestudio.metamodel.OneToManyRelationship
import de.guite.modulestudio.metamodel.RelationAutoCompletionUsage
import de.guite.modulestudio.metamodel.RelationEditMode
import de.guite.modulestudio.metamodel.UploadField
import de.guite.modulestudio.metamodel.UserField
import java.util.ArrayList
import java.util.List
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
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

    FileHelper fh = new FileHelper
    Application app

    List<String> extensions = newArrayList
    Iterable<JoinRelationship> incomingRelations
    Iterable<JoinRelationship> outgoingRelations

    /**
     * Entry point for entity editing form type.
     */
    def generate(DataObject it, IFileSystemAccess fsa) {
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
        app.generateClassPair(fsa, app.getAppSourceLibPath + 'Form/Type/' + name.formatForCodeCapital + 'Type.php',
            fh.phpFileContent(app, editTypeBaseImpl), fh.phpFileContent(app, editTypeImpl)
        )
    }

    def private editTypeBaseImpl(DataObject it) '''
        namespace «app.appNamespace»\Form\Type\Base;

        «IF !incomingRelations.empty || !outgoingRelations.empty»
            use Doctrine\ORM\EntityRepository;
        «ENDIF»
        «fields.formTypeImports(app, it)»
        «IF isInheriting»
            use «app.appNamespace»\Form\Type\«getParentDataObjects(newArrayList).head.name.formatForCodeCapital»Type;
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

        /**
         * «name.formatForDisplayCapital» editing form type base class.
         */
        abstract class Abstract«name.formatForCodeCapital»Type extends AbstractType
        {
            use TranslatorTrait;

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

            /**
             * «name.formatForCodeCapital»Type constructor.
             *
             * @param TranslatorInterface $translator «IF isTranslatable» «ENDIF»   Translator service instance
             * @param EntityFactory $entityFactory EntityFactory service instance
             «IF !incoming.empty || !outgoing.empty»
             * @param CollectionFilterHelper $collectionFilterHelper CollectionFilterHelper service instance
             * @param EntityDisplayHelper $entityDisplayHelper EntityDisplayHelper service instance
             «ENDIF»
             «IF isTranslatable»
             * @param VariableApiInterface $variableApi VariableApi service instance
             * @param TranslatableHelper $translatableHelper TranslatableHelper service instance
             «ENDIF»
             «IF hasListFieldsEntity»
             * @param ListEntriesHelper $listHelper ListEntriesHelper service instance
             «ENDIF»
             «IF hasLocaleFieldsEntity»
             * @param LocaleApiInterface $localeApi LocaleApi service instance
             «ENDIF»
             «IF app.needsFeatureActivationHelper»
             * @param FeatureActivationHelper $featureActivationHelper FeatureActivationHelper service instance
             «ENDIF»
             */
            public function __construct(
                TranslatorInterface $translator,
                EntityFactory $entityFactory«IF !incoming.empty || !outgoing.empty»,
                CollectionFilterHelper $collectionFilterHelper,
                EntityDisplayHelper $entityDisplayHelper«ENDIF»«IF isTranslatable»,
                VariableApiInterface $variableApi,
                TranslatableHelper $translatableHelper«ENDIF»«IF hasListFieldsEntity»,
                ListEntriesHelper $listHelper«ENDIF»«IF hasLocaleFieldsEntity»,
                LocaleApiInterface $localeApi«ENDIF»«IF app.needsFeatureActivationHelper»,
                FeatureActivationHelper $featureActivationHelper«ENDIF»
            ) {
                $this->setTranslator($translator);
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
                «IF hasLocaleFieldsEntity»
                    $this->localeApi = $localeApi;
                «ENDIF»
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
                $this->addEntityFields($builder, $options);
                «IF isInheriting»
                    «val parents = getParentDataObjects(newArrayList)»
                    $builder->add('parentFields', «parents.head.name.formatForCodeCapital»Type::class, [
                        'label' => $this->__('«parents.head.name.formatForDisplayCapital» data'),
                        'inherit_data' => true,
                        'data_class' => '«entityClassName('', false)»'
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
                «IF hasUploadFieldsEntity»

                    $builder->addEventListener(FormEvents::PRE_SET_DATA, function (FormEvent $event) {
                        $entity = $event->getData();
                        foreach (['«getUploadFieldsEntity.map[f|f.name.formatForCode].join("', '")»'] as $uploadFieldName) {
                            $entity[$uploadFieldName] = [
                                $uploadFieldName => $entity[$uploadFieldName] instanceof File ? $entity[$uploadFieldName]->getPathname() : null
                            ];
                        }
                    });
                    $builder->addEventListener(FormEvents::SUBMIT, function (FormEvent $event) {
                        $entity = $event->getData();
                        foreach (['«getUploadFieldsEntity.map[f|f.name.formatForCode].join("', '")»'] as $uploadFieldName) {
                            if (is_array($entity[$uploadFieldName])) {
                                $entity[$uploadFieldName] = $entity[$uploadFieldName][$uploadFieldName];
                            }
                        }
                    });
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
            «IF it instanceof Entity && (it as Entity).workflow != EntityWorkflowType.NONE»
                «addAdditionalNotificationRemarksField(it as Entity)»

            «ENDIF»
            «IF it instanceof Entity && (it as Entity).standardFields»
                «addModerationFields(it as Entity)»

            «ENDIF»
            «IF it instanceof Entity»
                «addSubmitButtons»

            «ENDIF»
            /**
             * @inheritDoc
             */
            public function getBlockPrefix()
            {
                return '«app.appName.formatForDB»_«name.formatForDB»';
            }

            /**
             * @inheritDoc
             */
            public function configureOptions(OptionsResolver $resolver)
            {
                $resolver
                    ->setDefaults([
                        // define class for underlying data (required for embedding forms)
                        'data_class' => '«entityClassName('', false)»',
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
                        «ENDIF»
                        «IF it instanceof Entity && (it as Entity).hasTranslatableFields»
                            'translations' => [],
                        «ENDIF»
                        «IF !incoming.empty || !outgoing.empty»
                            'filter_by_ownership' => true,
                            'inline_usage' => false
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
         *
         * @param FormBuilderInterface $builder The form builder
         * @param array                $options The options
         */
        public function addEntityFields(FormBuilderInterface $builder, array $options = [])
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
                    if ($language == $currentLanguage) {
                        continue;
                    }
                    $builder->add('translations' . $language, TranslationType::class, [
                        'fields' => $translatableFields,
                        'mandatory_fields' => $mandatoryFields[$language],
                        'values' => isset($options['translations'][$language]) ? $options['translations'][$language] : []
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
        «IF hasSluggableFields && slugUpdatable && application.supportsSlugInputFields»
            $builder->add('slug', TextType::class, [
                'label' => $this->__('Permalink') . ':',
                'required' => false«/* slugUnique.displayBool */»,
                'empty_data' => '',
                'attr' => [
                    'maxlength' => 255,
                    «IF slugUnique»
                        'class' => 'validate-unique',
                    «ENDIF»
                    'title' => $this->__('You can input a custom permalink for the «name.formatForDisplay»«IF !slugUnique» or let this field free to create one automatically«ENDIF»')
                ],
                'help' => $this->__('You can input a custom permalink for the «name.formatForDisplay»«IF !slugUnique» or let this field free to create one automatically«ENDIF»')
            ]);
        «ENDIF»
    '''

    def private addGeographicalFields(Entity it) '''
        /**
         * Adds fields for coordinates.
         *
         * @param FormBuilderInterface $builder The form builder
         * @param array                $options The options
         */
        public function addGeographicalFields(FormBuilderInterface $builder, array $options = [])
        {
            «FOR geoFieldName : newArrayList('latitude', 'longitude')»
                $builder->add('«geoFieldName»', GeoType::class, [
                    'label' => $this->__('«geoFieldName.toFirstUpper»') . ':',
                    'required' => false
                ]);
            «ENDFOR»
        }
    '''

    def private addAttributeFields(Entity it) '''
        /**
         * Adds fields for attributes.
         *
         * @param FormBuilderInterface $builder The form builder
         * @param array                $options The options
         */
        public function addAttributeFields(FormBuilderInterface $builder, array $options = [])
        {
            foreach ($options['attributes'] as $attributeName => $attributeValue) {
                $builder->add('attributes' . $attributeName, TextType::class, [
                    'mapped' => false,
                    'label' => $this->__($attributeName),
                    'attr' => [
                        'maxlength' => 255
                    ],
                    'data' => $attributeValue,
                    'required' => false
                ]);
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
        public function addCategoriesField(FormBuilderInterface $builder, array $options = [])
        {
            $builder->add('categories', CategoriesType::class, [
                'label' => $this->__('«IF categorisableMultiSelection»Categories«ELSE»Category«ENDIF»') . ':',
                'empty_data' => «IF categorisableMultiSelection»[]«ELSE»null«ENDIF»,
                'attr' => [
                    'class' => 'category-selector'
                ],
                'required' => false,
                'multiple' => «categorisableMultiSelection.displayBool»,
                'module' => '«app.appName»',
                'entity' => '«name.formatForCodeCapital»Entity',
                'entityCategoryClass' => '«app.appNamespace»\Entity\«name.formatForCodeCapital»CategoryEntity'«IF app.targets('2.0-dev') || (!app.targets('2.0') && app.targets('1.5-dev'))»,
                'showRegistryLabels' => true«ENDIF»
            ]);
        }
    '''

    def private addIncomingRelationshipFields(DataObject it) '''
        /**
         * Adds fields for incoming relationships.
         *
         * @param FormBuilderInterface $builder The form builder
         * @param array                $options The options
         */
        public function addIncomingRelationshipFields(FormBuilderInterface $builder, array $options = [])
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
         *
         * @param FormBuilderInterface $builder The form builder
         * @param array                $options The options
         */
        public function addOutgoingRelationshipFields(FormBuilderInterface $builder, array $options = [])
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
        «val editMode = if (outgoing) getTargetEditMode else getSourceEditMode»
        «IF editMode == RelationEditMode.EMBEDDED»
            $builder->add('«aliasName.formatForCode»', '«app.appNamespace»\Form\Type\«relatedEntity.name.formatForCodeCapital»Type', [
                «IF isManySide(outgoing)»
                    'by_reference' => false,
                «ENDIF»
                «IF /*outgoing && */nullable»
                    'required' => false,
                «ENDIF»
                'inline_usage' => true,
                'label' => $this->__('«aliasName.formatForDisplayCapital»'),
                «val helpMessage = relationHelpMessages(outgoing)»«IF !helpMessage.empty»'help' => «IF helpMessage.length > 1»[«ENDIF»«helpMessage.join(', ')»«IF helpMessage.length > 1»]«ENDIF»,«ENDIF»
                'attr' => [
                    'title' => $this->__('Choose the «aliasName.formatForDisplay»')
                ]
            ]);
        «ELSE»
            $queryBuilder = function(EntityRepository $er) {
                // select without joins
                return $er->getListQueryBuilder('', '', false);
            };
            «IF (relatedEntity as Entity).ownerPermission»
                if (true === $options['filter_by_ownership']) {
                    $collectionFilterHelper = $this->collectionFilterHelper;
                    $queryBuilder = function(EntityRepository $er) use ($collectionFilterHelper) {
                        // select without joins
                        $qb = $er->getListQueryBuilder('', '', false);
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
                    «val uniqueNameForJs = getUniqueRelationNameForJs((if (outgoing) source else target), isManySide(outgoing), (if (!isManyToMany) outgoing else !outgoing), aliasName.formatForCodeCapital)»
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
                        «IF !isManySide(outgoing)»
                            'placeholder' => $this->__('Please choose an option'),
                        «ENDIF»
                        'required' => false,
                    «ENDIF»
                «ENDIF»
                'label' => $this->__('«aliasName.formatForDisplayCapital»'),
                «IF !autoComplete && isExpanded»
                    'label_attr' => [
                        'class' => '«IF isManySide(outgoing)»checkbox«ELSE»radio«ENDIF»-inline'
                    ],
                «ENDIF»
                «val helpMessage = relationHelpMessages(outgoing)»«IF !helpMessage.empty»'help' => «IF helpMessage.length > 1»[«ENDIF»«helpMessage.join(', ')»«IF helpMessage.length > 1»]«ENDIF»,«ENDIF»
                'attr' => [
                    'title' => $this->__('Choose the «aliasName.formatForDisplay»')
                ]
            ]);
        «ENDIF»
    '''

    def private dispatch ArrayList<String> relationHelpMessages(JoinRelationship it, Boolean outgoing) {
        val messages = newArrayList

        messages
    }
    def private dispatch relationHelpMessages(OneToManyRelationship it, Boolean outgoing) {
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
    def private dispatch relationHelpMessages(ManyToManyRelationship it, Boolean outgoing) {
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

    def private isManyToMany(JoinRelationship it) {
        switch it {
            ManyToManyRelationship: true
            default: false
        }
    }

    def private addAdditionalNotificationRemarksField(Entity it) '''
        /**
         * Adds a field for additional notification remarks.
         *
         * @param FormBuilderInterface $builder The form builder
         * @param array                $options The options
         */
        public function addAdditionalNotificationRemarksField(FormBuilderInterface $builder, array $options = [])
        {
            $helpText = '';
            if ($options['is_moderator']«IF workflow == EntityWorkflowType.ENTERPRISE» || $options['is_super_moderator']«ENDIF») {
                $helpText = $this->__('These remarks (like a reason for deny) are not stored, but added to any notification emails send to the creator.');
            } elseif ($options['is_creator']) {
                $helpText = $this->__('These remarks (like questions about conformance) are not stored, but added to any notification emails send to our moderators.');
            }

            $builder->add('additionalNotificationRemarks', TextareaType::class, [
                'mapped' => false,
                'label' => $this->__('Additional remarks'),
                'label_attr' => [
                    'class' => 'tooltips',
                    'title' => $helpText
                ],
                'attr' => [
                    'title' => $options['mode'] == 'create' ? $this->__('Enter any additions about your content') : $this->__('Enter any additions about your changes')
                ],
                'required' => false,
                'help' => $helpText
            ]);
        }
    '''

    def private addModerationFields(Entity it) '''
        /**
         * Adds special fields for moderators.
         *
         * @param FormBuilderInterface $builder The form builder
         * @param array                $options The options
         */
        public function addModerationFields(FormBuilderInterface $builder, array $options = [])
        {
            if (!$options['has_moderate_permission']) {
                return;
            }
            «IF !incoming.empty || !outgoing.empty»
                if ($options['inline_usage']) {
                    return;
                }
            «ENDIF»

            $builder->add('moderationSpecificCreator', UserLiveSearchType::class, [
                'mapped' => false,
                'label' => $this->__('Creator') . ':',
                'attr' => [
                    'maxlength' => 11,
                    'title' => $this->__('Here you can choose a user which will be set as creator')
                ],
                'empty_data' => 0,
                'required' => false,
                'help' => $this->__('Here you can choose a user which will be set as creator')
            ]);
            $builder->add('moderationSpecificCreationDate', DateTimeType::class, [
                'mapped' => false,
                'label' => $this->__('Creation date') . ':',
                'attr' => [
                    'class' => '',
                    'title' => $this->__('Here you can choose a custom creation date')
                ],
                'empty_data' => '',
                'required' => false,
                'with_seconds' => true,
                'date_widget' => 'single_text',
                'time_widget' => 'single_text',
                'help' => $this->__('Here you can choose a custom creation date')
            ]);
        }
    '''

    def private addSubmitButtons(Entity it) '''
        /**
         * Adds submit buttons.
         *
         * @param FormBuilderInterface $builder The form builder
         * @param array                $options The options
         */
        public function addSubmitButtons(FormBuilderInterface $builder, array $options = [])
        {
            foreach ($options['actions'] as $action) {
                $builder->add($action['id'], SubmitType::class, [
                    'label' => $action['title'],
                    'icon' => ($action['id'] == 'delete' ? 'fa-trash-o' : ''),
                    'attr' => [
                        'class' => $action['buttonClass']
                    ]
                ]);
                if ($options['mode'] == 'create' && $action['id'] == 'submit'«IF !incoming.empty || !outgoing.empty» && !$options['inline_usage']«ENDIF») {
                    // add additional button to submit item and return to create form
                    $builder->add('submitrepeat', SubmitType::class, [
                        'label' => $this->__('Submit and repeat'),
                        'icon' => 'fa-repeat',
                        'attr' => [
                            'class' => $action['buttonClass']
                        ]
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
