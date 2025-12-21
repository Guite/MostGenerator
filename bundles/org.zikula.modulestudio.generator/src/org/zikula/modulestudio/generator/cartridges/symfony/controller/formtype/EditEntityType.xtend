package org.zikula.modulestudio.generator.cartridges.symfony.controller.formtype

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.ListField
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
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class EditEntityType {

    extension ControllerExtensions = new ControllerExtensions
    extension DateTimeExtensions = new DateTimeExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelExtensions = new ModelExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    Application app
    List<String> extensions = newArrayList

    /**
     * Entry point for entity editing form type.
     */
    def generate(Entity it, IMostFileSystemAccess fsa) {
        if (!hasEditAction) {
            return
        }
        if (hasTranslatableFields) extensions.add('translatable')
        app = it.application
        fsa.generateClassPair('Form/Type/' + name.formatForCodeCapital + 'Type.php', editTypeBaseImpl, editTypeImpl)
    }

    def private collectBaseImports(Entity it) {
        val imports = new ImportList
        imports.add(entityClassName('', false))
        imports.add('Symfony\\Component\\Form\\AbstractType')
        imports.add('Symfony\\Component\\Form\\FormBuilderInterface')
        imports.add('Symfony\\Component\\Form\\FormInterface')
        imports.add('Symfony\\Component\\OptionsResolver\\OptionsResolver')
        if (tree) {
            imports.add(app.appNamespace + '\\Form\\Type\\Field\\EntityTreeType')
        }
        if (standardFields) {
            imports.add(app.appNamespace + '\\Form\\Type\\Field\\ModerationFormFieldsTrait')
        }
        if (approval) {
            imports.add(app.appNamespace + '\\Form\\Type\\Field\\WorkflowFormFieldsTrait')
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
        if (isTranslatable || hasLocaleFieldsEntity) {
            imports.add('Zikula\\CoreBundle\\Api\\ApiInterface\\LocaleApiInterface')
            if (isTranslatable) {
                imports.add(app.appNamespace + '\\Helper\\TranslatableHelper')
            }
        }
        if (hasUploadFieldsEntity) {
            imports.add(app.appNamespace + '\\Helper\\UploadHelper')
        }
        if (!fields.filter(StringField).filter[#[StringRole.COUNTRY, StringRole.CURRENCY, StringRole.LANGUAGE, StringRole.LOCALE, StringRole.TIME_ZONE].contains(role)].empty) {
            imports.add('Symfony\\Component\\HttpFoundation\\RequestStack')
        }
        imports
    }

    def private editTypeBaseImpl(Entity it) '''
        namespace «app.appNamespace»\Form\Type\Base;

        «collectBaseImports.print»

        /**
         * «name.formatForDisplayCapital» editing form type base class.
         */
        abstract class Abstract«name.formatForCodeCapital»Type extends AbstractType
        {
            «IF it.standardFields || it.approval»
                «IF it.standardFields»
                    use ModerationFormFieldsTrait;
                «ENDIF»
                «IF it.approval»
                    use WorkflowFormFieldsTrait;
                «ENDIF»

            «ENDIF»
            public function __construct(
                «IF !fields.filter(StringField).filter[#[StringRole.COUNTRY, StringRole.CURRENCY, StringRole.LANGUAGE, StringRole.LOCALE, StringRole.TIME_ZONE].contains(role)].empty»
                    protected readonly RequestStack $requestStack,
                «ENDIF»
                «IF !incoming.empty || !outgoing.empty»
                    protected readonly CollectionFilterHelper $collectionFilterHelper,
                    protected readonly EntityDisplayHelper $entityDisplayHelper,
                «ENDIF»
                «IF isTranslatable || hasLocaleFieldsEntity»
                    protected readonly LocaleApiInterface $localeApi,
                «ENDIF»
                «IF isTranslatable»
                    protected readonly TranslatableHelper $translatableHelper,
                «ENDIF»
                «IF hasListFieldsEntity»
                    protected readonly ListEntriesHelper $listHelper,
                «ENDIF»
                «IF hasUploadFieldsEntity»
                    protected readonly UploadHelper $uploadHelper,
                «ENDIF»
                «IF app.needsFeatureActivationHelper»
                    protected readonly FeatureActivationHelper $featureActivationHelper,
                «ENDIF»
            ) {
            }

            public function buildForm(FormBuilderInterface $builder, array $options): void
            {
                «IF tree»
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
                «IF approval»
                    $this->addAdditionalNotificationRemarksField($builder, $options);
                «ENDIF»
                «IF standardFields»
                    $this->addModerationFields($builder, $options);
                «ENDIF»
                $this->addSubmitButtons($builder, $options);
            }

            «addFields»

            «addSubmitButtons»

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
                        «IF approval»
                            'is_moderator' => false,
                            'is_creator' => false,
                        «ENDIF»
                        'actions' => [],
                        «IF standardFields»
                            'has_moderate_permission' => false,
                            'allow_moderation_specific_creator' => false,
                            'allow_moderation_specific_creation_date' => false,
                        «ENDIF»
                        «IF hasTranslatableFields»
                            'translations' => [],
                        «ENDIF»
                        «IF !incoming.empty || !outgoing.empty»
                            'filter_by_ownership' => true,
                            'inline_usage' => false,
                        «ENDIF»
                    ])
                    ->setRequired([«IF hasUploadFieldsEntity»'entity', «ENDIF»'mode', 'actions'])
                    ->setAllowedTypes('mode', 'string')
                    «IF approval»
                        ->setAllowedTypes('is_moderator', 'bool')
                        ->setAllowedTypes('is_creator', 'bool')
                    «ENDIF»
                    ->setAllowedTypes('actions', 'array')
                    «IF standardFields»
                        ->setAllowedTypes('has_moderate_permission', 'bool')
                        ->setAllowedTypes('allow_moderation_specific_creator', 'bool')
                        ->setAllowedTypes('allow_moderation_specific_creation_date', 'bool')
                    «ENDIF»
                    «IF hasTranslatableFields»
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

    def private addFields(Entity it) '''
        /**
         * Adds basic entity fields.
         */
        public function addEntityFields(FormBuilderInterface $builder, array $options = []): void
        {
            «IF isTranslatable»
                «processTranslatableFields»
            «ENDIF»
            «fieldAdditions(isTranslatable)»
        }
    '''

    def private isTranslatable(Entity it) {
        extensions.contains('translatable')
    }

    def private processTranslatableFields(Entity it) '''
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

    def private fieldAdditions(Entity it, Boolean isTranslatable) '''
        «IF !isTranslatable || !getEditableNonTranslatableFields.empty»
            «/* TODO obsolete
            IF isTranslatable»
                «FOR field : getEditableNonTranslatableFields»«field.definition»«ENDFOR»
            «ELSE»
                «FOR field : getEditableFields»«field.definition»«ENDFOR»
            «ENDIF*/»
        «ENDIF»
        «IF hasSluggableFields && (!isTranslatable || !hasTranslatableSlug)»

            «slugField»
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
        «IF hasSluggableFields»
            $helpText = t('You can input a custom permalink for the «name.formatForDisplay» or let this field free to create one automatically.');
            «IF hasTranslatableSlug»
                if ('create' !== $options['mode']) {
                    $helpText = '';
                }
            «ENDIF»
            $builder->add('slug', TextType::class, [
                'label' => 'Permalink',
                'required' => «IF hasTranslatableSlug»'create' !== $options['mode']«ELSE»false«ENDIF»,
                'attr' => [
                    'maxlength' => «(fields.filter[name == 'slug'].head as StringField).length»,
                    'class' => 'validate-unique',
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

    def private editTypeImpl(Entity it) '''
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
