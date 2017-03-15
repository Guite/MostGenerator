package org.zikula.modulestudio.generator.cartridges.zclassic.controller.formtype

import de.guite.modulestudio.metamodel.AbstractDateField
import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.ArrayField
import de.guite.modulestudio.metamodel.BooleanField
import de.guite.modulestudio.metamodel.DataObject
import de.guite.modulestudio.metamodel.DateField
import de.guite.modulestudio.metamodel.DatetimeField
import de.guite.modulestudio.metamodel.DecimalField
import de.guite.modulestudio.metamodel.DerivedField
import de.guite.modulestudio.metamodel.EmailField
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.EntityWorkflowType
import de.guite.modulestudio.metamodel.FloatField
import de.guite.modulestudio.metamodel.InheritanceRelationship
import de.guite.modulestudio.metamodel.IntegerField
import de.guite.modulestudio.metamodel.JoinRelationship
import de.guite.modulestudio.metamodel.ListField
import de.guite.modulestudio.metamodel.ManyToManyRelationship
import de.guite.modulestudio.metamodel.MappedSuperClass
import de.guite.modulestudio.metamodel.RelationAutoCompletionUsage
import de.guite.modulestudio.metamodel.StringField
import de.guite.modulestudio.metamodel.TextField
import de.guite.modulestudio.metamodel.TimeField
import de.guite.modulestudio.metamodel.UploadField
import de.guite.modulestudio.metamodel.UrlField
import de.guite.modulestudio.metamodel.UserField
import java.math.BigInteger
import java.util.List
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.cartridges.zclassic.view.formcomponents.Validation
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class EditEntity {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelExtensions = new ModelExtensions
    extension ModelJoinExtensions = new ModelJoinExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    FileHelper fh = new FileHelper
    Validation validationHelper = new Validation
    Application app
    String nsSymfonyFormType = 'Symfony\\Component\\Form\\Extension\\Core\\Type\\'

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
        use Symfony\Component\Form\AbstractType;
        «IF app.targets('1.5')»
            use «nsSymfonyFormType»CheckboxType;
            «IF !fields.filter(ListField).filter[!multiple].empty»
                use «nsSymfonyFormType»ChoiceType;
            «ENDIF»
            «IF !fields.filter(StringField).filter[country].empty»
                use «nsSymfonyFormType»CountryType;
            «ENDIF»
            «IF !fields.filter(StringField).filter[currency].empty»
                use «nsSymfonyFormType»CurrencyType;
            «ENDIF»
            «IF !fields.filter(DateField).empty»
                use «nsSymfonyFormType»DateType;
            «ENDIF»
            «IF !fields.filter(EmailField).empty»
                use «nsSymfonyFormType»EmailType;
            «ENDIF»
            «IF !fields.filter(IntegerField).filter[!percentage && !range].empty»
                use «nsSymfonyFormType»IntegerType;
            «ENDIF»
            «IF !fields.filter(StringField).filter[language].empty»
                use «nsSymfonyFormType»LanguageType;
            «ENDIF»
            «IF !fields.filter(DecimalField).filter[currency].empty || !fields.filter(FloatField).filter[currency].empty»
                use «nsSymfonyFormType»MoneyType;
            «ENDIF»
            «IF !fields.filter(DecimalField).filter[!percentage && !currency].empty || !fields.filter(FloatField).filter[!percentage && !currency].empty»
                use «nsSymfonyFormType»NumberType;
            «ENDIF»
            «IF !fields.filter(StringField).filter[password].empty»
                use «nsSymfonyFormType»PasswordType;
            «ENDIF»
            «IF !fields.filter(IntegerField).filter[percentage].empty || !fields.filter(DecimalField).filter[percentage].empty || !fields.filter(FloatField).filter[percentage].empty»
                use «nsSymfonyFormType»PercentType;
            «ENDIF»
            «IF !fields.filter(IntegerField).filter[range].empty»
                use «nsSymfonyFormType»RangeType;
            «ENDIF»
            use «nsSymfonyFormType»ResetType;
            use «nsSymfonyFormType»SubmitType;
            «IF !fields.filter(TextField).empty || (it instanceof Entity && (it as Entity).workflow != EntityWorkflowType.NONE)»
                use «nsSymfonyFormType»TextareaType;
            «ENDIF»
            «IF extensions.contains('attributes')
                || !fields.filter(StringField).filter[!country && !language && !locale && !htmlcolour && !password && !currency && !timezone].empty
                || (it instanceof Entity && (it as Entity).hasSluggableFields && (it as Entity).slugUpdatable && application.supportsSlugInputFields)»
                use «nsSymfonyFormType»TextType;
            «ENDIF»
            «IF !fields.filter(TimeField).empty»
                use «nsSymfonyFormType»TimeType;
            «ENDIF»
            «IF !fields.filter(StringField).filter[timezone].empty»
                use «nsSymfonyFormType»TimezoneType;
            «ENDIF»
            «IF !fields.filter(UrlField).empty»
                use «nsSymfonyFormType»UrlType;
            «ENDIF»
        «ENDIF»
        «IF hasUploadFieldsEntity»
            use Symfony\Component\Form\FormEvent;
            use Symfony\Component\Form\FormEvents;
        «ENDIF»
        use Symfony\Component\Form\FormBuilderInterface;
        use Symfony\Component\Form\FormInterface;
        «IF hasUploadFieldsEntity»
            use Symfony\Component\HttpFoundation\File\File;
        «ENDIF»
        use Symfony\Component\OptionsResolver\OptionsResolver;
        «IF app.targets('1.5') && !fields.filter(StringField).filter[locale].empty»
            use Zikula\Bundle\FormExtensionBundle\Form\Type\LocaleType;
        «ENDIF»
        «IF app.targets('1.5') && extensions.contains('categories')»
            use Zikula\CategoriesModule\Form\Type\CategoriesType;
        «ENDIF»
        use Zikula\Common\Translator\TranslatorInterface;
        use Zikula\Common\Translator\TranslatorTrait;
        «IF isTranslatable»
            use Zikula\ExtensionsModule\Api\VariableApi;
        «ENDIF»
        «IF hasLocaleFieldsEntity»
            use Zikula\SettingsModule\Api\LocaleApi;
        «ENDIF»
        use «app.appNamespace»\Entity\Factory\«app.name.formatForCodeCapital»Factory;
        «IF app.targets('1.5')»
            «IF !fields.filter(ArrayField).empty»
                use «app.appNamespace»\Form\Type\Field\ArrayType;
            «ENDIF»
            «IF !fields.filter(StringField).filter[htmlcolour].empty»
                use «app.appNamespace»\Form\Type\Field\ColourType;
            «ENDIF»
            «IF !fields.filter(UserField).empty || (it instanceof Entity && (it as Entity).standardFields)»
                use «app.appNamespace»\Form\Type\Field\DateTimeType;
            «ENDIF»
            «IF it instanceof Entity && (it as Entity).geographical»
                use «app.appNamespace»\Form\Type\Field\GeoType;
            «ENDIF»
            «IF !fields.filter(ListField).filter[multiple].empty»
                use «app.appNamespace»\Form\Type\Field\MultiListType;
            «ENDIF»
            «IF it instanceof Entity && isTranslatable»
                use «app.appNamespace»\Form\Type\Field\TranslationType;
            «ENDIF»
            «IF !fields.filter(UploadField).empty»
                use «app.appNamespace»\Form\Type\Field\UploadType;
            «ENDIF»
            «IF !fields.filter(UserField).empty || (it instanceof Entity && (it as Entity).standardFields)»
                use «app.appNamespace»\Form\Type\Field\UserType;
            «ENDIF»
            «IF !getParentDataObjects(#[]).empty»
                use «app.appNamespace»\Form\Type\«getParentDataObjects(#[]).head.name.formatForCodeCapital»Type;
            «ENDIF»
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
             * @var «app.name.formatForCodeCapital»Factory
             */
            protected $entityFactory;
            «IF isTranslatable»

                /**
                 * @var VariableApi
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
                 * @var LocaleApi
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
             * @param «app.name.formatForCodeCapital»Factory        $entityFactory Entity factory service instance
             «IF isTranslatable»
             * @param VariableApi         $variableApi VariableApi service instance
             * @param TranslatableHelper  $translatableHelper TranslatableHelper service instance
             «ENDIF»
             «IF hasListFieldsEntity»
             * @param ListEntriesHelper   $listHelper    «IF isTranslatable» «ENDIF»ListEntriesHelper service instance
             «ENDIF»
             «IF hasLocaleFieldsEntity»
             * @param LocaleApi           $localeApi     «IF isTranslatable» «ENDIF»LocaleApi service instance
             «ENDIF»
             «IF app.needsFeatureActivationHelper»
             * @param FeatureActivationHelper $featureActivationHelper FeatureActivationHelper service instance
             «ENDIF»
             */
            public function __construct(TranslatorInterface $translator, «app.name.formatForCodeCapital»Factory $entityFactory«IF isTranslatable», VariableApi $variableApi, TranslatableHelper $translatableHelper«ENDIF»«IF hasListFieldsEntity», ListEntriesHelper $listHelper«ENDIF»«IF hasLocaleFieldsEntity», LocaleApi $localeApi«ENDIF»«IF app.needsFeatureActivationHelper», FeatureActivationHelper $featureActivationHelper«ENDIF»)
            {
                $this->setTranslator($translator);
                $this->entityFactory = $entityFactory;
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
                «val parents = getParentDataObjects(#[])»
                «IF !parents.empty»
                    $builder->add('parentFields', «IF app.targets('1.5')»«parents.head.name.formatForCodeCapital»Type::class«ELSE»'«app.appNamespace»\Form\Type\«parents.head.name.formatForCodeCapital»Type'«ENDIF», [
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
                «IF it instanceof Entity && (it as Entity).standardFields»
                    $this->addModerationFields($builder, $options);
                «ENDIF»
                $this->addReturnControlField($builder, $options);
                $this->addSubmitButtons($builder, $options);
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
                «addReturnControlField»

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
                            «FOR field : fields.filter(TimeField).filter[mandatory && (past || future)]»
                                «IF field.past»
                                    'is«field.name.formatForCodeCapital»TimeValidPast' => '«field.name.formatForCode»',
                                «ELSEIF field.future»
                                    'is«field.name.formatForCodeCapital»TimeValidFuture' => '«field.name.formatForCode»',
                                «ENDIF»
                            «ENDFOR»
                            «IF null !== startDateField && null !== endDateField»
                                'is«startDateField.name.formatForCodeCapital»Before«endDateField.name.formatForCodeCapital»' => '«startDateField.name.formatForCode»',
                            «ENDIF»
                        ],
                        «IF !incoming.filter(InheritanceRelationship).empty»
                            'inherit_data' => true,
                        «ENDIF»
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
                    ->setAllowedTypes([
                        'mode' => 'string',
                        «IF extensions.contains('attributes')»
                            'attributes' => 'array',
                        «ENDIF»
                        «IF it instanceof Entity && (it as Entity).workflow != EntityWorkflowType.NONE»
                            'is_moderator' => 'bool',
                            «IF it instanceof Entity && (it as Entity).workflow == EntityWorkflowType.ENTERPRISE»
                                'is_super_moderator' => 'bool',
                            «ENDIF»
                            'is_creator' => 'bool',
                        «ENDIF»
                        'actions' => 'array',
                        «IF it instanceof Entity && (it as Entity).standardFields»
                            'has_moderate_permission' => 'bool',
                        «ENDIF»
                        «IF it instanceof Entity && (it as Entity).hasTranslatableFields»
                            'translations' => 'array',
                        «ENDIF»
                        «IF !incoming.empty || !outgoing.empty»
                            'filter_by_ownership' => 'bool',
                            'inline_usage' => 'bool'
                        «ENDIF»
                    ])
                    ->setAllowedValues([
                        'mode' => ['create', 'edit']
                    ])
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
        public function addEntityFields(FormBuilderInterface $builder, array $options)
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
                    $builder->add('translations' . $language, «IF app.targets('1.5')»TranslationType::class«ELSE»'«app.appNamespace»\Form\Type\Field\TranslationType'«ENDIF», [
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
                «FOR field : getEditableNonTranslatableFields»«field.fieldImpl»«ENDFOR»
            «ELSE»
                «FOR field : getEditableFields»«field.fieldImpl»«ENDFOR»
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
        «FOR field : getEditableTranslatableFields»«field.fieldImpl»«ENDFOR»
        «IF hasTranslatableSlug»
            «slugField»
        «ENDIF»
    '''

    def private slugField(Entity it) '''
        «IF hasSluggableFields && slugUpdatable && application.supportsSlugInputFields»
            $builder->add('slug', «IF app.targets('1.5')»TextType::class«ELSE»'«nsSymfonyFormType»TextType'«ENDIF», [
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

    def private fieldImpl(DerivedField it) '''
        «/* No input fields for foreign keys, relations are processed further down */»
        «IF entity.getIncomingJoinRelations.filter[e|e.getSourceFields.head == name.formatForDB].empty»
            «IF it instanceof ListField»
                «fetchListEntries»
            «ENDIF»
            «val isExpandedListField = it instanceof ListField && (it as ListField).expanded»
            $builder->add('«name.formatForCode»', «IF app.targets('1.5')»«formType»::class«ELSE»'«formType»Type'«ENDIF», [
                'label' => $this->__('«name.formatForDisplayCapital»') . ':',
                «IF null !== documentation && documentation != ''»
                    'label_attr' => [
                        'class' => 'tooltips«IF isExpandedListField» «IF (it as ListField).multiple»checkbox«ELSE»radio«ENDIF»-inline«ENDIF»',
                        'title' => $this->__('«documentation.replace("'", '"')»')
                    ],
                «ELSEIF isExpandedListField»
                    'label_attr' => [
                        'class' => '«IF (it as ListField).multiple»checkbox«ELSE»radio«ENDIF»-inline'
                    ],
                «ENDIF»
                «helpAttribute»
                «IF readonly»
                    'disabled' => true,
                «ENDIF»
                «IF !(it instanceof BooleanField || it instanceof UploadField)»
                    'empty_data' => '«defaultValue»',
                «ENDIF»
                'attr' => [
                    «additionalAttributes»
                    'class' => '«validationHelper.fieldValidationCssClass(it)»',
                    «IF readonly»
                        'readonly' => 'readonly',
                    «ENDIF»
                    «IF it instanceof IntegerField && (it as IntegerField).range»
                        'min' => «(it as IntegerField).minValue»,
                        'max' => «(it as IntegerField).maxValue»,
                    «ENDIF»
                    'title' => $this->__('«titleAttribute»')
                ],
                «requiredOption»
                «additionalOptions»
            ]);
        «ENDIF»
    '''

    def private helpAttribute(DerivedField it) '''«IF !helpMessages.empty»'help' => «IF helpMessages.length > 1»[«ENDIF»«helpMessages.join(', ')»«IF helpMessages.length > 1»]«ENDIF»,«ENDIF»'''

    def private helpDocumentation(DerivedField it) {
        val messages = newArrayList
        if (null !== documentation && documentation != '') {
            messages += '$this->__(\'' + documentation.replace("'", '"') + '\')'
        }
        messages
    }

    def private dispatch helpMessages(DerivedField it) {
        val messages = helpDocumentation
        messages
    }

    def private dispatch helpMessages(IntegerField it) {
        val messages = helpDocumentation

        val hasMin = minValue.compareTo(BigInteger.valueOf(0)) > 0
        val hasMax = maxValue.compareTo(BigInteger.valueOf(0)) > 0
        if (!range && (hasMin || hasMax)) {
            if (hasMin && hasMax) {
                if (minValue == maxValue) {
                    messages += '''$this->__f('Note: this value must exactly be %value%.', ['%value%' => «minValue»])'''
                } else {
                    messages += '''$this->__f('Note: this value must be between %minValue% and %maxValue%.', ['%minValue%' => «minValue», '%maxValue%' => «maxValue»])'''
                }
            } else if (hasMin) {
                messages += '''$this->__f('Note: this value must be greater than %minValue%.', ['%minValue%' => «minValue»])'''
            } else if (hasMax) {
                messages += '''$this->__f('Note: this value must be less than %maxValue%.', ['%maxValue%' => «maxValue»])'''
            }
        }
        messages
    }

    def private dispatch helpMessages(DecimalField it) {
        val messages = helpDocumentation

        val hasMin = minValue > 0
        val hasMax = maxValue > 0
        if (hasMin || hasMax) {
            if (hasMin && hasMax) {
                if (minValue == maxValue) {
                    messages += '''$this->__f('Note: this value must exactly be %value%.', ['%value%' => «minValue»])'''
                } else {
                    messages += '''$this->__f('Note: this value must be between %minValue% and %maxValue%.', ['%minValue%' => «minValue», '%maxValue%' => «maxValue»])'''
                }
            } else if (hasMin) {
                messages += '''$this->__f('Note: this value must be greater than %minValue%.', ['%minValue%' => «minValue»])'''
            } else if (hasMax) {
                messages += '''$this->__f('Note: this value must be less than %maxValue%.', ['%maxValue%' => «maxValue»])'''
            }
        }
        messages
    }

    def private dispatch helpMessages(FloatField it) {
        val messages = helpDocumentation

        val hasMin = minValue > 0
        val hasMax = maxValue > 0
        if (hasMin || hasMax) {
            if (hasMin && hasMax) {
                if (minValue == maxValue) {
                    messages += '''$this->__f('Note: this value must exactly be %value%.', ['%value%' => «minValue»])'''
                } else {
                    messages += '''$this->__f('Note: this value must be between %minValue% and %maxValue%.', ['%minValue%' => «minValue», '%maxValue%' => «maxValue»])'''
                }
            } else if (hasMin) {
                messages += '''$this->__f('Note: this value must be greater than %minValue%.', ['%minValue%' => «minValue»])'''
            } else if (hasMax) {
                messages += '''$this->__f('Note: this value must be less than %maxValue%.', ['%maxValue%' => «maxValue»])'''
            }
        }
        messages
    }

    def private dispatch helpMessages(StringField it) {
        val messages = helpDocumentation

        if (null !== regexp && regexp != '') {
            messages += '''$this->__f('Note: this value must«IF regexpOpposite» not«ENDIF» conform to the regular expression "%pattern%".', ['%pattern%' => '«regexp.replace('\'', '')»'])'''
        }

        messages
    }

    def private dispatch helpMessages(TextField it) {
        val messages = helpDocumentation

        if (null !== regexp && regexp != '') {
            messages += '''$this->__f('Note: this value must«IF regexpOpposite» not«ENDIF» conform to the regular expression "%pattern%".', ['%pattern%' => '«regexp.replace('\'', '')»'])'''
        }

        messages
    }

    def private dispatch helpMessages(ListField it) {
        val messages = helpDocumentation

        if (multiple && min > 0 && max > 0) {
            if (min == max) {
                messages += '''$this->__f('Note: you must select exactly %min% choices.', ['%min%' => «min»])'''
            } else {
                messages += '''$this->__f('Note: you must select between %min% and %max% choices.', ['%min%' => «min», '%max%' => «max»])'''
            }
        }

        messages
    }

    def private dispatch helpMessages(ArrayField it) {
        val messages = helpDocumentation

        messages += '''$this->__('Enter one entry per line.')'''

        messages
    }

    def private dispatch helpMessages(AbstractDateField it) {
        val messages = helpDocumentation

        if (past) {
            messages += '''$this->__('Note: this value must be in the past.')'''
        } else if (future) {
            messages += '''$this->__('Note: this value must be in the future.')'''
        }

        messages
    }

    def private dispatch formType(DerivedField it) '''«nsSymfonyFormType»Text'''
    def private dispatch titleAttribute(DerivedField it) '''Enter the «name.formatForDisplay» of the «entity.name.formatForDisplay»'''
    def private dispatch additionalAttributes(DerivedField it) '''
        'maxlength' => 255,
    '''
    def private dispatch requiredOption(DerivedField it) '''
        'required' => «mandatory.displayBool»,
    '''
    def private dispatch additionalOptions(DerivedField it) ''''''

    def private dispatch formType(BooleanField it) '''«IF !app.targets('1.5')»«nsSymfonyFormType»«ENDIF»Checkbox'''
    def private dispatch titleAttribute(BooleanField it) '''«name.formatForDisplay» ?'''
    def private dispatch additionalAttributes(BooleanField it) ''''''

    def private dispatch formType(IntegerField it) '''«IF !app.targets('1.5')»«nsSymfonyFormType»«ENDIF»«IF percentage»Percent«ELSEIF range»Range«ELSE»Integer«ENDIF»'''
    def private dispatch titleAttribute(IntegerField it) '''Enter the «name.formatForDisplay» of the «entity.name.formatForDisplay».') . ' ' . $this->__('Only digits are allowed.'''
    def private dispatch additionalAttributes(IntegerField it) '''
        'maxlength' => «length»,
    '''
    def private dispatch additionalOptions(IntegerField it) '''
        «IF percentage»
            'type' => 'integer',
        «ENDIF»
        «IF !range»
            'scale' => 0
        «ENDIF»
    '''

    def private dispatch formType(DecimalField it) '''«IF !app.targets('1.5')»«nsSymfonyFormType»«ENDIF»«IF percentage»Percent«ELSEIF currency»Money«ELSE»Number«ENDIF»'''
    def private dispatch additionalAttributes(DecimalField it) '''
        'maxlength' => «(length+3+scale)»,
    '''
    def private dispatch additionalOptions(DecimalField it) '''
        «/* not required since these are the default values IF currency»
            'currency' => 'EUR',
            'divisor' => 1,
        «ENDIF*/»
        «/* not required since these are the default values IF percentage»
            'type' => 'fractional',
        «ENDIF*/»
        'scale' => «scale»
    '''

    def private dispatch formType(FloatField it) '''«IF !app.targets('1.5')»«nsSymfonyFormType»«ENDIF»«IF percentage»Percent«ELSEIF currency»Money«ELSE»Number«ENDIF»'''
    def private dispatch additionalAttributes(FloatField it) '''
        'maxlength' => «(length+3+2)»,
    '''
    def private dispatch additionalOptions(FloatField it) '''
        «/* not required since these are the default values IF currency»
            'currency' => 'EUR',
            'divisor' => 1,
        «ENDIF*/»
        «/* not required since these are the default values IF percentage»
            'type' => 'fractional',
        «ENDIF*/»
        'scale' => 2
    '''

    def private dispatch formType(StringField it) '''«IF country»«IF !app.targets('1.5')»«nsSymfonyFormType»«ENDIF»Country«ELSEIF language»«IF !app.targets('1.5')»«nsSymfonyFormType»«ENDIF»Language«ELSEIF locale»«IF !app.targets('1.5')»Zikula\Bundle\FormExtensionBundle\Form\Type\«ENDIF»Locale«ELSEIF htmlcolour»«IF !app.targets('1.5')»«app.appNamespace»\Form\Type\Field\«ENDIF»Colour«ELSEIF password»«IF !app.targets('1.5')»«nsSymfonyFormType»«ENDIF»Password«ELSEIF currency»«IF !app.targets('1.5')»«nsSymfonyFormType»«ENDIF»Currency«ELSEIF timezone»«IF !app.targets('1.5')»«nsSymfonyFormType»«ENDIF»Timezone«ELSE»«IF !app.targets('1.5')»«nsSymfonyFormType»«ENDIF»Text«ENDIF»'''
    def private dispatch titleAttribute(StringField it) '''«IF country || language || locale || htmlcolour || currency || timezone»Choose the «name.formatForDisplay» of the «entity.name.formatForDisplay»«ELSE»Enter the «name.formatForDisplay» of the «entity.name.formatForDisplay»«ENDIF»'''
    def private dispatch additionalAttributes(StringField it) '''
        'maxlength' => «length»,
        «IF null !== regexp && regexp != ''»
            «IF !regexpOpposite»
                'pattern' => '«regexp.replace('\'', '')»',
            «ENDIF»
        «ENDIF»
    '''
    def private dispatch additionalOptions(StringField it) '''
        «IF !mandatory && (country || language || locale || currency || timezone)»
            'placeholder' => $this->__('All')«IF locale»,«ENDIF»
        «ENDIF»
        «IF locale»
            'choices' => $this->localeApi->getSupportedLocaleNames(),
            'choices_as_values' => true
        «ENDIF»
    '''

    def private dispatch formType(TextField it) '''«IF !app.targets('1.5')»«nsSymfonyFormType»«ENDIF»Textarea'''
    def private dispatch additionalAttributes(TextField it) '''
        'maxlength' => «length»,
        «IF null !== regexp && regexp != ''»
            «IF !regexpOpposite»
                'pattern' => '«regexp.replace('\'', '')»',
            «ENDIF»
        «ENDIF»
    '''

    def private dispatch formType(EmailField it) '''«IF !app.targets('1.5')»«nsSymfonyFormType»«ENDIF»Email'''
    def private dispatch additionalAttributes(EmailField it) '''
        'maxlength' => «length»,
    '''

    def private dispatch formType(UrlField it) '''«IF !app.targets('1.5')»«nsSymfonyFormType»«ENDIF»Url'''
    def private dispatch additionalAttributes(UrlField it) '''
        'maxlength' => «length»,
    '''
    def private dispatch additionalOptions(UrlField it) '''«/*'default_protocol' => 'http'*/»'''

    def private dispatch formType(UploadField it) '''«IF !app.targets('1.5')»«app.appNamespace»\Form\Type\Field\«ENDIF»Upload'''
    def private dispatch additionalAttributes(UploadField it) ''''''
    def private dispatch requiredOption(UploadField it) '''
        'required' => «mandatory.displayBool» && $options['mode'] == 'create',
    '''
    def private dispatch additionalOptions(UploadField it) '''
        'entity' => $options['entity'],
        'allowed_extensions' => '«allowedExtensions»',
        'allowed_size' => '«maxSize»'
    '''

    def private fetchListEntries(ListField it) '''
        $listEntries = $this->listHelper->getEntries('«entity.name.formatForCode»', '«name.formatForCode»');
        $choices = [];
        $choiceAttributes = [];
        foreach ($listEntries as $entry) {
            $choices[$entry['text']] = $entry['value'];
            $choiceAttributes[$entry['text']] = ['title' => $entry['title']];
        }
    '''

    def private dispatch formType(ListField it) '''«IF multiple»«IF !app.targets('1.5')»«app.appNamespace»\Form\Type\Field\«ENDIF»MultiList«ELSE»«IF !app.targets('1.5')»«nsSymfonyFormType»«ENDIF»Choice«ENDIF»'''
    def private dispatch titleAttribute(ListField it) '''Choose the «name.formatForDisplay»'''
    def private dispatch additionalAttributes(ListField it) ''''''
    def private dispatch additionalOptions(ListField it) '''
        «IF !expanded && !mandatory»
            'placeholder' => $this->__('Choose an option'),
        «ENDIF»
        'choices' => $choices,
        'choices_as_values' => true,
        'choice_attr' => $choiceAttributes,
        'multiple' => «multiple.displayBool»,
        'expanded' => «expanded.displayBool»
    '''

    def private dispatch formType(UserField it) '''«IF !app.targets('1.5')»«app.appNamespace»\Form\Type\Field\«ENDIF»User'''
    def private dispatch additionalAttributes(UserField it) '''
        'maxlength' => «length»,
    '''
    def private dispatch additionalOptions(UserField it) '''
        «IF !entity.incoming.empty || !entity.outgoing.empty»
            'inline_usage' => $options['inline_usage']
        «ENDIF»
    '''

    def private dispatch formType(ArrayField it) '''«IF !app.targets('1.5')»«app.appNamespace»\Form\Type\Field\«ENDIF»Array'''
    def private dispatch additionalAttributes(ArrayField it) '''
    '''

    def private dispatch formType(DatetimeField it) '''«IF !app.targets('1.5')»«app.appNamespace»\Form\Type\Field\DateTime«ENDIF»'''
    def private dispatch formType(DateField it) '''«IF !app.targets('1.5')»«nsSymfonyFormType»«ENDIF»Date'''
    def private dispatch formType(TimeField it) '''«IF !app.targets('1.5')»«nsSymfonyFormType»«ENDIF»Time'''
    def private dispatch additionalAttributes(AbstractDateField it) ''''''
    def private dispatch additionalOptions(AbstractDateField it) '''
        'empty_data' => «defaultData»,
        'widget' => 'single_text'
    '''
    def private dispatch defaultData(DatetimeField it) '''«IF null !== defaultValue && defaultValue != '' && defaultValue != 'now'»'«defaultValue»'«ELSEIF mandatory || !nullable»date('Y-m-d H:i')«ELSE»''«ENDIF»'''
    def private dispatch defaultData(DateField it) '''«IF null !== defaultValue && defaultValue != '' && defaultValue != 'now'»'«defaultValue»'«ELSEIF mandatory || !nullable»date('Y-m-d')«ELSE»''«ENDIF»'''
    def private dispatch additionalAttributes(TimeField it) '''
        'maxlength' => 8,
    '''
    def private dispatch additionalOptions(TimeField it) '''
        'empty_data' => '«defaultValue»',
        'widget' => 'single_text'
    '''

    def private addGeographicalFields(Entity it) '''
        /**
         * Adds fields for coordinates.
         *
         * @param FormBuilderInterface $builder The form builder
         * @param array                $options The options
         */
        public function addGeographicalFields(FormBuilderInterface $builder, array $options)
        {
            «FOR geoFieldName : newArrayList('latitude', 'longitude')»
                $builder->add('«geoFieldName»', «IF app.targets('1.5')»GeoType::class«ELSE»'«app.appNamespace»\Form\Type\Field\GeoType'«ENDIF», [
                    'label' => $this->__('«geoFieldName.toFirstUpper»') . ':',
                    'attr' => [
                        'class' => 'validate-number'
                    ],
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
        public function addAttributeFields(FormBuilderInterface $builder, array $options)
        {
            foreach ($options['attributes'] as $attributeName => $attributeValue) {
                $builder->add('attributes' . $attributeName, «IF app.targets('1.5')»TextType::class«ELSE»'«nsSymfonyFormType»TextType'«ENDIF», [
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
        public function addCategoriesField(FormBuilderInterface $builder, array $options)
        {
            $builder->add('categories', «IF app.targets('1.5')»CategoriesType::class«ELSE»'Zikula\CategoriesModule\Form\Type\CategoriesType'«ENDIF», [
                'label' => $this->__('«IF categorisableMultiSelection»Categories«ELSE»Category«ENDIF»') . ':',
                'empty_data' => «IF categorisableMultiSelection»[]«ELSE»null«ENDIF»,
                'attr' => [
                    'class' => 'category-selector'
                ],
                'required' => false,
                'multiple' => «categorisableMultiSelection.displayBool»,
                'module' => '«app.appName»',
                'entity' => '«name.formatForCodeCapital»Entity',
                'entityCategoryClass' => '«app.appNamespace»\Entity\«name.formatForCodeCapital»CategoryEntity'
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
        public function addIncomingRelationshipFields(FormBuilderInterface $builder, array $options)
        {
            «FOR relation : incomingRelations»
                «val autoComplete = relation.useAutoCompletion != RelationAutoCompletionUsage.NONE && relation.useAutoCompletion != RelationAutoCompletionUsage.ONLY_TARGET_SIDE»
                «relation.fieldImpl(false, autoComplete)»
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
        public function addOutgoingRelationshipFields(FormBuilderInterface $builder, array $options)
        {
            «FOR relation : outgoingRelations»
                «val autoComplete = relation.useAutoCompletion != RelationAutoCompletionUsage.NONE && relation.useAutoCompletion != RelationAutoCompletionUsage.ONLY_SOURCE_SIDE»
                «relation.fieldImpl(true, autoComplete)»
            «ENDFOR»
        }
    '''

    def private fieldImpl(JoinRelationship it, Boolean outgoing, Boolean autoComplete) '''
        «val aliasName = getRelationAliasName(outgoing)»
        «val relatedEntity = if (outgoing) target else source»
        $queryBuilder = function(EntityRepository $er) {
            // select without joins
            return $er->getListQueryBuilder('', '', false);
        };
        «IF (relatedEntity as Entity).ownerPermission»
            if (true === $options['filter_by_ownership']) {
                $queryBuilder = function(EntityRepository $er) {
                    // select without joins
                    $qb = $er->getListQueryBuilder('', '', false);
                    $qb = $er->addCreatorFilter($qb);

                    return $qb;
                };
            }
        «ENDIF»
        «val isExpanded = if (outgoing) expandedTarget else expandedSource»
        $builder->add('«aliasName.formatForCode»', '«formType(autoComplete)»Type', [
            «IF autoComplete»
                «val uniqueNameForJs = getUniqueRelationNameForJs(app, (if (outgoing) source else target), isManySide(outgoing), (if (!isManyToMany) outgoing else !outgoing), aliasName)»
                'objectType' => '«relatedEntity.name.formatForCode»',
                'multiple' => «isManySide(outgoing).displayBool»,
                'uniqueNameForJs' => '«uniqueNameForJs»',
                «IF outgoing && nullable»
                    'required' => false,
                «ENDIF»
            «ELSE»
                'class' => '«app.appName»:«(if (outgoing) target else source).name.formatForCodeCapital»Entity',
                'choice_label' => 'getTitleFromDisplayPattern',
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
            'attr' => [
                'title' => $this->__('Choose the «aliasName.formatForDisplay»')
            ]
        ]);
    '''

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

    def private addReturnControlField(Entity it) '''
        /**
         * Adds the return control field.
         *
         * @param FormBuilderInterface $builder The form builder
         * @param array                $options The options
         */
        public function addReturnControlField(FormBuilderInterface $builder, array $options)
        {
            if ($options['mode'] != 'create') {
                return;
            }
            $builder->add('repeatCreation', «IF app.targets('1.5')»CheckboxType::class«ELSE»'«nsSymfonyFormType»CheckboxType'«ENDIF», [
                'mapped' => false,
                'label' => $this->__('Create another item after save'),
                'required' => false
            ]);
        }
    '''

    def private addAdditionalNotificationRemarksField(Entity it) '''
        /**
         * Adds a field for additional notification remarks.
         *
         * @param FormBuilderInterface $builder The form builder
         * @param array                $options The options
         */
        public function addAdditionalNotificationRemarksField(FormBuilderInterface $builder, array $options)
        {
            $helpText = '';
            if ($options['is_moderator']«IF workflow == EntityWorkflowType.ENTERPRISE» || $options['is_super_moderator']«ENDIF») {
                $helpText = $this->__('These remarks (like a reason for deny) are not stored, but added to any notification emails send to the creator.');
            } elseif ($options['is_creator']) {
                $helpText = $this->__('These remarks (like questions about conformance) are not stored, but added to any notification emails send to our moderators.');
            }

            $builder->add('additionalNotificationRemarks', «IF app.targets('1.5')»TextareaType::class«ELSE»'«nsSymfonyFormType»TextareaType'«ENDIF», [
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
        public function addModerationFields(FormBuilderInterface $builder, array $options)
        {
            if (!$options['has_moderate_permission']) {
                return;
            }

            $builder->add('moderationSpecificCreator', «IF app.targets('1.5')»UserType::class«ELSE»'«app.appNamespace»\Form\Type\Field\UserType'«ENDIF», [
                'mapped' => false,
                'label' => $this->__('Creator') . ':',
                'attr' => [
                    'maxlength' => 11,
                    'class' => ' validate-digits',
                    'title' => $this->__('Here you can choose a user which will be set as creator')
                ],
                'empty_data' => 0,
                'required' => false,
                'help' => $this->__('Here you can choose a user which will be set as creator')
            ]);
            $builder->add('moderationSpecificCreationDate', «IF app.targets('1.5')»DateTimeType::class«ELSE»'«app.appNamespace»\Form\Type\Field\DateTimeType'«ENDIF», [
                'mapped' => false,
                'label' => $this->__('Creation date') . ':',
                'attr' => [
                    'class' => '',
                    'title' => $this->__('Here you can choose a custom creation date')
                ],
                'empty_data' => '',
                'required' => false,
                'widget' => 'single_text',
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
        public function addSubmitButtons(FormBuilderInterface $builder, array $options)
        {
            foreach ($options['actions'] as $action) {
                $builder->add($action['id'], «IF app.targets('1.5')»SubmitType::class«ELSE»'«nsSymfonyFormType»SubmitType'«ENDIF», [
                    'label' => «IF app.targets('1.5')»$action['title']«ELSE»$this->__(/** @Ignore */$action['title'])«ENDIF»,
                    'icon' => ($action['id'] == 'delete' ? 'fa-trash-o' : ''),
                    'attr' => [
                        'class' => $action['buttonClass']«IF !app.targets('1.5')»,
                        'title' => $this->__(/** @Ignore */$action['description'])«ENDIF»
                    ]
                ]);
            }
            $builder->add('reset', «IF app.targets('1.5')»ResetType::class«ELSE»'«nsSymfonyFormType»ResetType'«ENDIF», [
                'label' => $this->__('Reset'),
                'icon' => 'fa-refresh',
                'attr' => [
                    'class' => 'btn btn-default',
                    'formnovalidate' => 'formnovalidate'
                ]
            ]);
            $builder->add('cancel', «IF app.targets('1.5')»SubmitType::class«ELSE»'«nsSymfonyFormType»SubmitType'«ENDIF», [
                'label' => $this->__('Cancel'),
                'icon' => 'fa-times',
                'attr' => [
                    'class' => 'btn btn-default',
                    'formnovalidate' => 'formnovalidate'
                ]
            ]);
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
