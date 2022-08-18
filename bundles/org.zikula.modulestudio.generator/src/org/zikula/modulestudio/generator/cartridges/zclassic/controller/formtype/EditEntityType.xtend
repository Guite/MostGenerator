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
            «IF it instanceof Entity»
                «IF it.standardFields || it.workflow != EntityWorkflowType.NONE»
                    «IF it.standardFields»
                        use ModerationFormFieldsTrait;
                    «ENDIF»
                    «IF it.workflow != EntityWorkflowType.NONE»
                        use WorkflowFormFieldsTrait;
                    «ENDIF»

                «ENDIF»
            «ENDIF»
            public function __construct(
                «IF !fields.filter(StringField).filter[#[StringRole.COUNTRY, StringRole.CURRENCY, StringRole.LANGUAGE, StringRole.LOCALE, StringRole.TIME_ZONE].contains(role)].empty»
                    protected RequestStack $requestStack,
                «ENDIF»
                protected EntityFactory $entityFactory«IF !incoming.empty || !outgoing.empty»,
                protected CollectionFilterHelper $collectionFilterHelper,
                protected EntityDisplayHelper $entityDisplayHelper«ENDIF»«IF isTranslatable»,
                protected VariableApiInterface $variableApi,
                protected TranslatableHelper $translatableHelper«ENDIF»«IF hasListFieldsEntity»,
                protected ListEntriesHelper $listHelper«ENDIF»«IF hasUploadFieldsEntity»,
                protected UploadHelper $uploadHelper«ENDIF»«IF hasLocaleFieldsEntity»,
                protected LocaleApiInterface $localeApi«ENDIF»«IF app.needsFeatureActivationHelper»,
                protected FeatureActivationHelper $featureActivationHelper«ENDIF»
            ) {
            }

            public function buildForm(FormBuilderInterface $builder, array $options)
            {
                «IF it instanceof Entity && (it as Entity).tree != EntityTreeType.NONE»
                    if ('create' === $options['mode']) {
                        $builder->add('parent', EntityTreeType::class, [
                            'class' => «name.formatForCodeCapital»Entity::class,
                            'multiple' => false,
                            'expanded' => false,
                            'use_joins' => false,
                            'label' => 'Parent «name.formatForDisplay»',
                            'attr' => [
                                'title' => 'Choose the parent «name.formatForDisplay».',
                            ],
                        ]);
                    }
                «ENDIF»
                $this->addEntityFields($builder, $options);
                «IF isInheriting»
                    «val parents = getParentDataObjects(newArrayList)»
                    $builder->add('parentFields', «parents.head.name.formatForCodeCapital»Type::class, [
                        'label' => '«parents.head.name.formatForDisplayCapital» data',
                        'inherit_data' => true,
                        'data_class' => «name.formatForCodeCapital»Entity::class
                    ]);
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
                        'translation_domain' => '«name.formatForCode»',
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
        public function addEntityFields(FormBuilderInterface $builder, array $options = []): void
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
                        'values' => $options['translations'][$language] ?? [],
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
            $helpText = /** @Translate */'You can input a custom permalink for the «name.formatForDisplay» or let this field free to create one automatically.';
            «IF hasTranslatableSlug»
                if ('create' !== $options['mode']) {
                    $helpText = '';
                }
            «ENDIF»
            $builder->add('slug', TextType::class, [
                'label' => 'Permalink',
                'required' => «IF hasTranslatableSlug»'create' !== $options['mode']«ELSE»false«ENDIF»,
                «/*IF hasTranslatableSlug»
                    'empty_data' => '',
                «ENDIF*/»'attr' => [
                    'maxlength' => «slugLength»,
                    «IF slugUnique»
                        'class' => 'validate-unique',
                    «ENDIF»
                    /** @Ignore */
                    'title' => $helpText,
                ],
                /** @Ignore */
                'help' => $helpText,
            ]);
        «ENDIF»
    '''

    def private addGeographicalFields(Entity it) '''
        /**
         * Adds fields for coordinates.
         */
        public function addGeographicalFields(FormBuilderInterface $builder, array $options = []): void
        {
            «FOR geoFieldName : newArrayList('latitude', 'longitude')»
                $builder->add('«geoFieldName»', GeoType::class, [
                    'label' => '«geoFieldName.toFirstUpper»',
                    'required' => false
                ]);
            «ENDFOR»
        }
    '''

    def private addCategoriesField(Entity it) '''
        /**
         * Adds a categories field.
         */
        public function addCategoriesField(FormBuilderInterface $builder, array $options = []): void
        {
            $builder->add('categories', CategoriesType::class, [
                'label' => '«IF categorisableMultiSelection»Categories«ELSE»Category«ENDIF»',
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
        public function addIncomingRelationshipFields(FormBuilderInterface $builder, array $options = []): void
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
        public function addOutgoingRelationshipFields(FormBuilderInterface $builder, array $options = []): void
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
        «IF editMode == RelationEditMode.EMBEDDED»«/* TODO entity option is missing if related entity contains an upload field */»
            $builder->add('«aliasName.formatForCode»', '«app.appNamespace»\Form\Type\«relatedEntity.name.formatForCodeCapital»Type', [
                «IF isManySide(outgoing)»
                    'by_reference' => false,
                «ENDIF»
                «IF /*outgoing && */nullable»
                    'required' => false,
                «ENDIF»
                'inline_usage' => true,
                'label' => '«aliasName.formatForDisplayCapital»',
                «relationHelp(outgoing)»
                'attr' => [
                    'title' => 'Choose the «aliasName.formatForDisplay».',
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
                        $collectionFilterHelper->addCreatorFilter($qb);

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
                            'placeholder' => 'Please choose an option.',
                        «ENDIF»
                        'required' => false,
                    «ENDIF»
                «ENDIF»
                'label' => '«aliasName.formatForDisplayCapital»',
                «IF !autoComplete && isExpanded»
                    'label_attr' => [
                        'class' => '«IF isManySide(outgoing)»checkbox«ELSE»radio«ENDIF»-inline'
                    ],
                «ENDIF»
                «relationHelp(outgoing)»
                'attr' => [
                    'title' => 'Choose the «aliasName.formatForDisplay».',
                ],
            ]);
        «ENDIF»
    '''

    def private relationHelp(JoinRelationship it, Boolean outgoing) {
        val messages = relationHelpMessages(outgoing)
        val parameters = relationHelpMessageParameters(outgoing)
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

    def private formType(JoinRelationship it, Boolean autoComplete) {
        if (autoComplete) '''«app.appNamespace»\Form\Type\Field\AutoCompletionRelation'''
        else '''Symfony\Bridge\Doctrine\Form\Type\Entity'''
    }

    def private addSubmitButtons(Entity it) '''
        /**
         * Adds submit buttons.
         */
        public function addSubmitButtons(FormBuilderInterface $builder, array $options = []): void
        {
            foreach ($options['actions'] as $action) {
                $builder->add($action['id'], SubmitType::class, [
                    /** @Ignore */
                    'label' => $action['title'],
                    'icon' => 'delete' === $action['id'] ? 'fa-trash-alt' : '',
                    'attr' => [
                        'class' => $action['buttonClass'],
                    ],
                ]);
                if ('create' === $options['mode'] && 'submit' === $action['id']«IF !incoming.empty || !outgoing.empty» && !$options['inline_usage']«ENDIF») {
                    // add additional button to submit item and return to create form
                    $builder->add('submitrepeat', SubmitType::class, [
                        'label' => 'Submit and repeat',
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
