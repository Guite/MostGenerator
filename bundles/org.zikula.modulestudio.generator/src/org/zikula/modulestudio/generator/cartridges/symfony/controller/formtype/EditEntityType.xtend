package org.zikula.modulestudio.generator.cartridges.symfony.controller.formtype

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.DataObject
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.EntityTreeType
import de.guite.modulestudio.metamodel.EntityWorkflowType
import de.guite.modulestudio.metamodel.ListField
import de.guite.modulestudio.metamodel.MappedSuperClass
import de.guite.modulestudio.metamodel.StringField
import de.guite.modulestudio.metamodel.StringRole
import de.guite.modulestudio.metamodel.UploadField
import de.guite.modulestudio.metamodel.UserField
import java.util.List
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.application.ImportList
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.DateTimeExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.ModelInheritanceExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class EditEntityType {

    extension ControllerExtensions = new ControllerExtensions
    extension DateTimeExtensions = new DateTimeExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelExtensions = new ModelExtensions
    extension ModelInheritanceExtensions = new ModelInheritanceExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    Application app
    List<String> extensions = newArrayList

    /**
     * Entry point for entity editing form type.
     */
    def generate(DataObject it, IMostFileSystemAccess fsa) {
        if (!(it instanceof MappedSuperClass) && !(it as Entity).hasEditAction) {
            return
        }
        if (it instanceof Entity) {
            if (hasTranslatableFields) extensions.add('translatable')
        }
        app = it.application
        fsa.generateClassPair('Form/Type/' + name.formatForCodeCapital + 'Type.php', editTypeBaseImpl, editTypeImpl)
    }

    def private collectBaseImports(DataObject it) {
        val imports = new ImportList
        imports.add(entityClassName('', false))
        imports.add('Symfony\\Component\\Form\\FormBuilderInterface')
        imports.add('Symfony\\Component\\Form\\FormInterface')
        imports.add('Symfony\\Component\\OptionsResolver\\OptionsResolver')
        if (isInheriting) {
            imports.add(app.appNamespace + '\\Form\\Type\\' + getParentDataObjects(newArrayList).head.name.formatForCodeCapital + 'Type')
        }
        if (it instanceof Entity && (it as Entity).tree != EntityTreeType.NONE) {
            imports.add(app.appNamespace + '\\Form\\Type\\Field\\EntityTreeType')
        }
        if (!incoming.empty || !outgoing.empty) {
            imports.add(app.appNamespace + '\\Helper\\CollectionFilterHelper')
            imports.add(app.appNamespace + '\\Helper\\EntityDisplayHelper')
        }
        if (app.needsFeatureActivationHelper) {
            imports.add(app.appNamespace + '\\Helper\\FeatureActivationHelper')
        }
        if (hasListFieldsEntity) {
            imports.add(app.appNamespace + '\\Helper\\ListEntriesHelper')
        }
        if (isTranslatable) {
            imports.add(app.appNamespace + '\\Helper\\TranslatableHelper')
        }
        if (hasUploadFieldsEntity) {
            imports.add(app.appNamespace + '\\Helper\\UploadHelper')
        }
        if (it instanceof Entity && (it as Entity).standardFields) {
            imports.add(app.appNamespace + '\\Traits\\ModerationFormFieldsTrait')
        }
        if (it instanceof Entity && (it as Entity).workflow != EntityWorkflowType.NONE) {
            imports.add(app.appNamespace + '\\Traits\\WorkflowFormFieldsTrait')
        }
        imports
    }

    def private editTypeBaseImpl(DataObject it) '''
        namespace «app.appNamespace»\Form\Type\Base;

        «collectBaseImports.print»

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
                    protected readonly RequestStack $requestStack,
                «ENDIF»
                protected readonly EntityFactory $entityFactory«IF !incoming.empty || !outgoing.empty»,
                protected readonly CollectionFilterHelper $collectionFilterHelper,
                protected readonly EntityDisplayHelper $entityDisplayHelper«ENDIF»«IF isTranslatable»,
                protected readonly LocaleApiInterface $localeApi,
                protected readonly TranslatableHelper $translatableHelper«ENDIF»«IF hasListFieldsEntity»,
                protected readonly ListEntriesHelper $listHelper«ENDIF»«IF hasUploadFieldsEntity»,
                protected readonly UploadHelper $uploadHelper«ENDIF»«IF hasLocaleFieldsEntity»,
                protected readonly LocaleApiInterface $localeApi«ENDIF»«IF app.needsFeatureActivationHelper»,
                protected readonly FeatureActivationHelper $featureActivationHelper«ENDIF»
            ) {
            }

            public function buildForm(FormBuilderInterface $builder, array $options): void
            {
                «IF it instanceof Entity && (it as Entity).tree != EntityTreeType.NONE»
                    if ('create' === $options['mode']) {
                        $builder->add('parent', EntityTreeType::class, [
                            'class' => «name.formatForCodeCapital»::class,
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
                        'data_class' => «name.formatForCodeCapital»::class
                    ]);
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

            «IF it instanceof Entity»
                «addSubmitButtons»

            «ENDIF»
            public function getBlockPrefix(): string
            {
                return '«app.appName.formatForDB»_«name.formatForDB»';
            }

            public function configureOptions(OptionsResolver $resolver): void
            {
                $resolver
                    ->setDefaults([
                        // define class for underlying data (required for embedding forms)
                        'data_class' => «name.formatForCodeCapital»::class,
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

        if ($this->localeApi->multilingual() && $this->featureActivationHelper->isEnabled(FeatureActivationHelper::TRANSLATIONS, '«name.formatForCode»')) {
            $supportedLanguages = $this->translatableHelper->getSupportedLanguages('«name.formatForCode»');
            if (is_array($supportedLanguages) && 1 < count($supportedLanguages)) {
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
            «/* TODO obsolete
            IF isTranslatable»
                «FOR field : getEditableNonTranslatableFields»«field.definition»«ENDFOR»
            «ELSE»
                «FOR field : getEditableFields»«field.definition»«ENDFOR»
            «ENDIF*/»
        «ENDIF»
        «IF it instanceof Entity»
            «IF hasSluggableFields && (!isTranslatable || !hasTranslatableSlug)»

                «slugField»
            «ENDIF»
        «ENDIF»
    '''

    def private translatableFieldSet(Entity it) '''
        «/* TODO obsolete
        FOR field : getEditableTranslatableFields»«field.definition»«ENDFOR*/»
        «IF hasTranslatableSlug»
            «slugField»
        «ENDIF»
    '''

    def private slugField(Entity it) '''
        «IF hasSluggableFields && slugUpdatable»
            $helpText = t('You can input a custom permalink for the «name.formatForDisplay» or let this field free to create one automatically.');
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
                    'title' => $helpText,
                ],
                'help' => $helpText,
            ]);
        «ENDIF»
    '''

    def private addSubmitButtons(Entity it) '''
        /**
         * Adds submit buttons.
         */
        public function addSubmitButtons(FormBuilderInterface $builder, array $options = []): void
        {
            foreach ($options['actions'] as $action) {
                $builder->add($action['id'], SubmitType::class, [
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

    def private addCommonSubmitButtons(Application it) '''
        $builder->add('reset', ResetType::class, [
            'label' => 'Reset',
            'icon' => 'fa-sync',
            'attr' => [
                'formnovalidate' => 'formnovalidate',
            ],
        ]);
        $builder->add('cancel', SubmitType::class, [
            'label' => 'Cancel',
            'validate' => false,
            'icon' => 'fa-times',
        ]);
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
