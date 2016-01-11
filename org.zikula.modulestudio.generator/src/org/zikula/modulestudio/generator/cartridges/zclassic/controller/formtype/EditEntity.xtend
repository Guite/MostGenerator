package org.zikula.modulestudio.generator.cartridges.zclassic.controller.formtype

import de.guite.modulestudio.metamodel.AbstractDateField
import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.BooleanField
import de.guite.modulestudio.metamodel.DateField
import de.guite.modulestudio.metamodel.DatetimeField
import de.guite.modulestudio.metamodel.DecimalField
import de.guite.modulestudio.metamodel.DerivedField
import de.guite.modulestudio.metamodel.EmailField
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.EntityWorkflowType
import de.guite.modulestudio.metamodel.FloatField
import de.guite.modulestudio.metamodel.IntegerField
import de.guite.modulestudio.metamodel.ListField
import de.guite.modulestudio.metamodel.StringField
import de.guite.modulestudio.metamodel.TextField
import de.guite.modulestudio.metamodel.TimeField
import de.guite.modulestudio.metamodel.UploadField
import de.guite.modulestudio.metamodel.UrlField
import de.guite.modulestudio.metamodel.UserField
import java.math.BigInteger
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.cartridges.zclassic.view.formcomponents.Validation
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class EditEntity {
    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelExtensions = new ModelExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    FileHelper fh = new FileHelper
    Validation validationHelper = new Validation
    Application app
    String nsSymfonyFormType = 'Symfony\\Component\\Form\\Extension\\Core\\Type\\'

    /**
     * Entry point for entity editing form type.
     * 1.4.x only.
     */
    def generate(Entity it, IFileSystemAccess fsa) {
        if (!hasActions('edit')) {
            return
        }
        app = it.application
        app.generateClassPair(fsa, app.getAppSourceLibPath + 'Form/Type/' + name.formatForCodeCapital + 'Type.php',
            fh.phpFileContent(app, editTypeBaseImpl), fh.phpFileContent(app, editTypeImpl)
        )
    }

    def private editTypeBaseImpl(Entity it) '''
        namespace «app.appNamespace»\Form\Type\Base;

        use Symfony\Component\Form\AbstractType;
        use Symfony\Component\Form\FormBuilderInterface;
        use Symfony\Component\OptionsResolver\OptionsResolver;
        use Symfony\Component\Translation\TranslatorInterface;
        «IF metaData»
            use Symfony\Component\Validator\Constraints\Valid;
        «ENDIF»
        «IF hasTranslatableFields»
            use Zikula\ExtensionsModule\Api\VariableApi;
            use «app.appNamespace»\Helper\TranslatableHelper;
        «ENDIF»
        «IF hasListFieldsEntity»
            use «app.appNamespace»\Helper\ListEntriesHelper;
        «ENDIF»

        /**
         * «name.formatForDisplayCapital» editing form type base class.
         */
        class «name.formatForCodeCapital»Type extends AbstractType
        {
            /**
             * @var TranslatorInterface
             */
            private $translator;
            «IF hasTranslatableFields»

                /**
                 * @var VariableApi
                 */
                private $variableApi;

                /**
                 * @var TranslatableHelper
                 */
                private $translatableHelper;
            «ENDIF»
            «IF hasListFieldsEntity»

                /**
                 * @var ListEntriesHelper
                 */
                private $listHelper;
            «ENDIF»

            /**
             * «name.formatForCodeCapital»Type constructor.
             *
             * @param TranslatorInterface $translator «IF hasTranslatableFields» «ENDIF»Translator service instance.
            «IF hasTranslatableFields»
                «' '»* @param VariableApi         $variableApi VariableApi service instance.
                «' '»* @param TranslatableHelper  $listHelper  TranslatableHelper service instance.
            «ENDIF»
            «IF hasListFieldsEntity»
                «' '»* @param ListEntriesHelper   $listHelper   «IF hasTranslatableFields» «ENDIF»ListEntriesHelper service instance.
            «ENDIF»
             */
            public function __construct(TranslatorInterface $translator«IF hasTranslatableFields», VariableApi $variableApi, TranslatableHelper $translatableHelper«ENDIF»«IF hasListFieldsEntity», ListEntriesHelper $listHelper«ENDIF»)
            {
                $this->translator = $translator;
                «IF hasTranslatableFields»
                    $this->variableApi = $variableApi;
                    $this->translatableHelper = $translatableHelper;
                «ENDIF»
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

«/* TODO
required form options
'mode' -> create or edit
if attributable
    attributes
if (workflow != none)
    isModerator
    isSuperModerator
    isCreator
'actions' -> list of workflow actions
inlineUsage => false/true

required template vars
'«entity.name.formatForDB»' -> entity instance
'mode' -> create or edit
'form' -> edit form
'actions' -> list of workflow actions
if attributable:
    attributes -> list of fieldNames
 */»
                $this->addEntityFields($builder, $options);
                «IF attributable»
                    $this->addAttributeFields($builder, $options);
                «ENDIF»
                «IF categorisable»
                    $this->addCategoriesField($builder, $options);
                «ENDIF»
                «/* TODO relations */»
                «IF metaData»
                    $this->addMetaDataFields($builder, $options);
                «ENDIF»
                «IF workflow != EntityWorkflowType.NONE»
                    $this->addAdditionalNotificationRemarksField($builder, $options);
                «ENDIF»
                $this->addReturnControlField($builder, $options);
                $this->addSubmitButtons($builder, $options);
            }

            «addEntityFields»

            «IF geographical»
                «addGeographicalFields»

            «ENDIF»
            «IF attributable»
                «addAttributeFields»

            «ENDIF»
            «IF categorisable»
                «addCategoriesField»

            «ENDIF»
            «IF metaData»
                «addMetaDataFields»

            «ENDIF»
            «IF workflow != EntityWorkflowType.NONE»
                «addAdditionalNotificationRemarksField»

            «ENDIF»
            «addReturnControlField»

            «addSubmitButtons»

            /**
             * {@inheritdoc}
             */
            public function getBlockPrefix()
            {
                return '«app.appName.formatForDB»_«name.formatForDB»';
            }

            /**
             * {@inheritdoc}
             */
            public function configureOptions(OptionsResolver $resolver)
            {
                parent::configureOptions($resolver);

                $resolver->setDefaults([
                    // define class for underlying data (required for embedding forms)
                    'data_class' => '«entityClassName('', false)»'
                ]);
            }
        }
    '''

    def private addEntityFields(Entity it) '''
        /**
         * Adds basic entity fields.
         *
         * @param FormBuilderInterface The form builder.
         * @param array                The options
         */
        public function addEntityFields(FormBuilderInterface $builder, array $options)
        {
            «IF hasTranslatableFields»
                $useOnlyCurrentLanguage = true;
                if ($this->variableApi->get('ZConfig', 'multilingual')) {
                    $supportedLanguages = $this->translatableHelper->getSupportedLanguages('«name.formatForCode»');
                    if (is_array($supportedLanguages) && count($supportedLanguages) > 1) {
                        $useOnlyCurrentLanguage = false;
                        $currentLanguage = \ZLanguage::getLanguageCode();
                        foreach ($supportedLanguages as $language) {
                            if ($language == $currentLanguage) {
                                «translatableFieldSet('', '')»
                            }
                        }
                        foreach ($supportedLanguages as $language) {
                            if ($language != $currentLanguage) {
                                «translatableFieldSet('$language', '$language')»
                            }
                        }
                    }
                }
                if ($useOnlyCurrentLanguage === true) {
                    $language = \ZLanguage::getLanguageCode();
                    «translatableFieldSet('', '')»
                }
            «ENDIF»
            «IF !hasTranslatableFields
                || (hasTranslatableFields && (!getEditableNonTranslatableFields.empty || (hasSluggableFields && !hasTranslatableSlug)))
                || geographical»
                «IF hasTranslatableFields»
                    «FOR field : getEditableNonTranslatableFields»«field.fieldImpl('', '')»«ENDFOR»
                «ELSE»
                    «FOR field : getEditableFields»«field.fieldImpl('', '')»«ENDFOR»
                «ENDIF»
                «IF !hasTranslatableFields || (hasSluggableFields && !hasTranslatableSlug)»

                    «slugField('', '')»
                «ENDIF»
                «IF geographical»
                    $this->addGeographicalFields($builder, $options);
                «ENDIF»
            «ENDIF»
        }
    '''

    def private translatableFieldSet(Entity it, String groupSuffix, String idSuffix) '''
        «FOR field : getEditableTranslatableFields»«field.fieldImpl(groupSuffix, idSuffix)»«ENDFOR»
        «IF hasTranslatableSlug»
            «slugField(groupSuffix, idSuffix)»
        «ENDIF»
    '''

    def private slugField(Entity it, String groupSuffix, String idSuffix) '''
        «IF hasSluggableFields && slugUpdatable»
            $builder->add('slug'«IF idSuffix != ''» . «idSuffix»«ENDIF», '«nsSymfonyFormType»TextType', [
                'label' => $this->translator->trans('Permalink', [], '«app.appName.formatForDB»'),
                'required' => false«/* slugUnique.displayBool */»,
                'attr' => [
                    «IF slugUnique»
                        'class' => 'validate-unique',
                    «ENDIF»
                    'title' => $this->translator->trans('You can input a custom permalink for the «name.formatForDisplay»«IF !slugUnique» or let this field free to create one automatically«ENDIF»', [], '«app.appName.formatForDB»')
                ],
                'help' => $this->translator->trans('You can input a custom permalink for the «name.formatForDisplay»«IF !slugUnique» or let this field free to create one automatically«ENDIF»', [], '«app.appName.formatForDB»'),
                'max_length' => 255
            ]);
        «ENDIF»
    '''

    def private fieldImpl(DerivedField it, String groupSuffix, String idSuffix) '''
        «IF it instanceof ListField»
            «fetchListEntries»
        «ENDIF»
        $builder->add('«name.formatForCode»«IF idSuffix != ''» . «idSuffix»«ENDIF»', '«formType»Type', [
            'label' => $this->translator->trans('«name.formatForDisplayCapital»', [], '«app.appName.formatForDB»') . ':',
            «IF null !== documentation && documentation != ''»
                'label_attr' => [
                    'class' => '«app.appName.toLowerCase»-form-tooltips',
                    'title' => $this->translator->trans('«documentation.replace("'", '"')»', [], '«app.appName.formatForDB»')
                ],
            «ENDIF»
            «IF readonly»
                'disabled' => true,
            «ENDIF»
            'empty_data' => '«defaultValue»',
            'attr' => [
                'class' => '«validationHelper.fieldValidationCssClass(it)»',
                «IF readonly»
                    'readonly' => 'readonly',
                «ENDIF»
                'title' => $this->translator->trans('«titleAttribute»', [], '«app.appName.formatForDB»')
            ],
            «IF null !== documentation && documentation != ''»
                'help' => $this->translator->trans('«documentation.replace("'", '"')»', [], '«app.appName.formatForDB»'),
            «ENDIF»«additionalOptions»
        ]);
    '''

    def private dispatch formType(DerivedField it) '''«nsSymfonyFormType»Text'''
    def private dispatch titleAttribute(DerivedField it) '''Enter the «name.formatForDisplay» of the «entity.name.formatForDisplay»'''
    def private dispatch additionalOptions(DerivedField it) '''
        'required' => «mandatory.displayBool»,
        'max_length' => 255
    '''

    def private dispatch formType(BooleanField it) '''«nsSymfonyFormType»Checkbox'''
    def private dispatch titleAttribute(BooleanField it) '''«name.formatForDisplay» ?'''
    def private dispatch additionalOptions(BooleanField it) '''
        'required' => «mandatory.displayBool»,
    '''

    def private dispatch formType(IntegerField it) '''«nsSymfonyFormType»Integer'''
    def private dispatch titleAttribute(IntegerField it) '''Enter the «name.formatForDisplay» of the «entity.name.formatForDisplay». Only digits are allowed.'''
    def private dispatch additionalOptions(IntegerField it) '''
        «val hasMin = minValue.compareTo(BigInteger.valueOf(0)) > 0»
        «val hasMax = maxValue.compareTo(BigInteger.valueOf(0)) > 0»
        'required' => «mandatory.displayBool»,
        'max_length' => «length»,
        «IF hasMin || hasMax»
            «IF hasMin && hasMax»
                «IF minValue == maxValue»
                    'help' => $this->translator->trans('Note: this value must exactly be %value%.', ['%value%' => «minValue»], '«app.appName.formatForDB»'),
                «ELSE»
                    'help' => $this->translator->trans('Note: this value must be between %minValue% and %maxValue%.', ['%minValue%' => «minValue», '%maxValue%' => «maxValue»], '«app.appName.formatForDB»'),
                «ENDIF»
            «ELSEIF hasMin»
                'help' => $this->translator->trans('Note: this value must be greater than %minValue%.', ['%minValue%' => «minValue»], '«app.appName.formatForDB»'),
            «ELSEIF hasMax»
                'help' => $this->translator->trans('Note: this value must be less than %maxValue%.', ['%maxValue%' => «maxValue»], '«app.appName.formatForDB»'),
            «ENDIF»
        «ENDIF»
        'scale' => 0
    '''

    def private dispatch formType(DecimalField it) '''«nsSymfonyFormType»«IF currency»Money«ELSE»Number«ENDIF»'''
    def private dispatch additionalOptions(DecimalField it) '''
        «val hasMin = minValue > 0»
        «val hasMax = maxValue > 0»
        'required' => «mandatory.displayBool»,
        'max_length' => «(length+3+scale)»,
        «/* not required since these are the default values IF currency»
            'currency' => 'EUR',
            'divisor' => 1,
        «ENDIF*/»
        «IF hasMin || hasMax»
            «IF hasMin && hasMax»
                «IF minValue == maxValue»
                    'help' => $this->translator->trans('Note: this value must exactly be %value%.', ['%value%' => «minValue»], '«app.appName.formatForDB»'),
                «ELSE»
                    'help' => $this->translator->trans('Note: this value must be between %minValue% and %maxValue%.', ['%minValue%' => «minValue», '%maxValue%' => «maxValue»], '«app.appName.formatForDB»'),
                «ENDIF»
            «ELSEIF hasMin»
                'help' => $this->translator->trans('Note: this value must be greater than %minValue%.', ['%minValue%' => «minValue»], '«app.appName.formatForDB»'),
            «ELSEIF hasMax»
                'help' => $this->translator->trans('Note: this value must be less than %maxValue%.', ['%maxValue%' => «maxValue»], '«app.appName.formatForDB»'),
            «ENDIF»
        «ENDIF»
        'scale' => «scale»
    '''

    def private dispatch formType(FloatField it) '''«nsSymfonyFormType»«IF currency»Money«ELSE»Number«ENDIF»'''
    def private dispatch additionalOptions(FloatField it) '''
        «val hasMin = minValue > 0»
        «val hasMax = maxValue > 0»
        'required' => «mandatory.displayBool»,
        'max_length' => «(length+3+2)»,
        «/* not required since these are the default values IF currency»
            'currency' => 'EUR',
            'divisor' => 1,
        «ENDIF*/»
        «IF hasMin || hasMax»
            «IF hasMin && hasMax»
                «IF minValue == maxValue»
                    'help' => $this->translator->trans('Note: this value must exactly be %value%.', ['%value%' => «minValue»], '«app.appName.formatForDB»'),
                «ELSE»
                    'help' => $this->translator->trans('Note: this value must be between %minValue% and %maxValue%.', ['%minValue%' => «minValue», '%maxValue%' => «maxValue»], '«app.appName.formatForDB»'),
                «ENDIF»
            «ELSEIF hasMin»
                'help' => $this->translator->trans('Note: this value must be greater than %minValue%.', ['%minValue%' => «minValue»], '«app.appName.formatForDB»'),
            «ELSEIF hasMax»
                'help' => $this->translator->trans('Note: this value must be less than %maxValue%.', ['%maxValue%' => «maxValue»], '«app.appName.formatForDB»'),
            «ENDIF»
        «ENDIF»
        'scale' => 2
    '''

    def private dispatch formType(StringField it) '''«IF country»«nsSymfonyFormType»Country«ELSEIF language»«nsSymfonyFormType»Language«ELSEIF locale»Zikula\Bundle\FormExtensionBundle\Form\Type\Locale«ELSEIF htmlcolour»«app.appNamespace»\Form\Type\Field\Colour«ELSEIF password»«nsSymfonyFormType»Password«ELSE»«nsSymfonyFormType»Text«ENDIF»'''
    def private dispatch titleAttribute(StringField it) '''«IF country || language || locale || htmlcolour»Choose the «name.formatForDisplay» of the «entity.name.formatForDisplay»«ELSE»Enter the «name.formatForDisplay» of the «entity.name.formatForDisplay»«ENDIF»'''
    def private dispatch additionalOptions(StringField it) '''
        'required' => «mandatory.displayBool»,
        «IF !mandatory && (country || language || locale)»
            'placeholder' => $this->translator->trans('All', [], '«app.appName.formatForDB»'),
        «ENDIF»
        'max_length' => «length»,
        «IF null !== regexp && regexp != ''»
            «IF !regexpOpposite»
                'pattern' => '«regexp.replace('\'', '')»',
            «ENDIF»
            'help' => $this->translator->trans('Note: this value must«IF regexpOpposite» not«ENDIF» conform to the regular expression "%pattern%".', ['%pattern%' => '«regexp.replace('\'', '')»'], '«app.appName.formatForDB»')
        «ENDIF»
    '''

    def private dispatch formType(TextField it) '''«nsSymfonyFormType»Textarea'''
    def private dispatch additionalOptions(TextField it) '''
        'required' => «mandatory.displayBool»,
        'max_length' => «length»,
        «IF null !== regexp && regexp != ''»
            «IF !regexpOpposite»
                'pattern' => '«regexp.replace('\'', '')»',
            «ENDIF»
            'help' => $this->translator->trans('Note: this value must«IF regexpOpposite» not«ENDIF» conform to the regular expression "%pattern%".', ['%pattern%' => '«regexp.replace('\'', '')»'], '«app.appName.formatForDB»')
        «ENDIF»
    '''

    def private dispatch formType(EmailField it) '''«nsSymfonyFormType»Email'''
    def private dispatch additionalOptions(EmailField it) '''
        'required' => «mandatory.displayBool»,
        'max_length' => «length»
    '''

    def private dispatch formType(UrlField it) '''«nsSymfonyFormType»Url'''
    def private dispatch additionalOptions(UrlField it) '''
        'required' => «mandatory.displayBool»,
        'max_length' => «length»«/*,
        'default_protocol' => 'http'*/»
    '''

    def private dispatch formType(UploadField it) '''«nsSymfonyFormType»File'''
    def private dispatch additionalOptions(UploadField it) '''
        'required' => «mandatory.displayBool»«IF mandatory» && $options['mode'] == 'create'«ENDIF»,
        'file_meta' => 'get«name.formatForCodeCapital»Meta',
        'file_path' => 'get«name.formatForCodeCapital»FullPath',
        'file_url' => 'get«name.formatForCodeCapital»FullPathUrl',
        'allowed_extensions' => '«allowedExtensions»',
        'allowed_size' => «allowedFileSize»
    '''

    def private fetchListEntries(ListField it) '''
        $listEntries = $this->listHelper->getEntries('«entity.name.formatForCode»', '«name.formatForCode»');
        $choices = [];
        $choiceAttributes = [];
        foreach ($listEntries as $entry) {
            $choices[$entry['text']] = $entry['value'];
            $choiceAttributes[$entry['text']] = $entry['title'];
        }
    '''

    def private dispatch formType(ListField it) '''«nsSymfonyFormType»Choice'''
    def private dispatch titleAttribute(ListField it) '''Choose the «name.formatForDisplay»'''
    def private dispatch additionalOptions(ListField it) '''
        «IF !useChecks»
            «IF mandatory»
                'placeholder' => '',
            «ELSE»
                'placeholder' => $this->translator->trans('Choose an option', [], '«app.appName.formatForDB»'),
            «ENDIF»
        «ENDIF»
        'choices' => $choices,
        'choices_as_values' => true,
        'choice_attr' => $choiceAttributes,
        «IF multiple && min > 0 && max > 0»
            «IF min == max»
                'help' => $this->translator->trans('Note: you must select exactly %min% choices.', ['%min%' => «min»], '«app.appName.formatForDB»'),
            «ELSE»
                'help' => $this->translator->trans('Note: you must select between %min% and %max% choices.', ['%min%' => «min», '%max%' => «max»], '«app.appName.formatForDB»'),
            «ENDIF»
        «ENDIF»
        'multiple' => «multiple.displayBool»,
        'expanded' => «useChecks.displayBool»
    '''

    def private dispatch formType(UserField it) '''«app.appNamespace»\Form\Type\Field\User'''
    def private dispatch titleAttribute(UserField it) '''Enter a part of the user name to search'''
    def private dispatch additionalOptions(UserField it) '''
        'required' => «mandatory.displayBool»,
        'max_length' => «length»,
        'inlineUsage' => $options['inlineUsage']
    '''

    def private dispatch formType(DatetimeField it) '''«nsSymfonyFormType»DateTime'''
    def private dispatch formType(DateField it) '''«nsSymfonyFormType»Date'''
    def private dispatch formType(TimeField it) '''«nsSymfonyFormType»Time'''
    def private dispatch additionalOptions(AbstractDateField it) '''
        'empty_data' => «defaultData»,
        'required' => «mandatory.displayBool»,
        «IF past»
            'help' => $this->translator->trans('Note: this value must be in the past.', [], '«app.appName.formatForDB»'),
        «ELSEIF future»
            'help' => $this->translator->trans('Note: this value must be in the future.', [], '«app.appName.formatForDB»'),
        «ENDIF»
        'widget' => 'single_text'
    '''
    def private dispatch defaultData(DatetimeField it) '''«IF null !== defaultValue && defaultValue != '' && defaultValue != 'now'»'«defaultValue»'«ELSEIF mandatory || !nullable»date('Y-m-d H:i')«ELSE»''«ENDIF»'''
    def private dispatch defaultData(DateField it) '''«IF null !== defaultValue && defaultValue != '' && defaultValue != 'now'»'«defaultValue»'«ELSEIF mandatory || !nullable»date('Y-m-d')«ELSE»''«ENDIF»'''
    def private dispatch additionalOptions(TimeField it) '''
        'empty_data' => '«defaultValue»',
        'required' => «mandatory.displayBool»,
        «IF past»
            'help' => $this->translator->trans('Note: this value must be in the past.', [], '«app.appName.formatForDB»'),
        «ELSEIF future»
            'help' => $this->translator->trans('Note: this value must be in the future.', [], '«app.appName.formatForDB»'),
        «ENDIF»
        'widget' => 'single_text',
        'max_length' => 8
    '''

    def private addGeographicalFields(Entity it) '''
        /**
         * Adds fields for coordinates.
         *
         * @param FormBuilderInterface The form builder.
         * @param array                The options
         */
        public function addGeographicalFields(FormBuilderInterface $builder, array $options)
        {
            «FOR geoFieldName : newArrayList('latitude', 'longitude')»
                $builder->add('«geoFieldName»', '«app.appNamespace»\Form\Type\Field\GeoType', [
                    'label' => $this->translator->trans('«geoFieldName.toFirstUpper»', [], '«app.appName.formatForDB»') . ':',
                    'attr' => [
                        'class' => 'validate-number',
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
         * @param FormBuilderInterface The form builder.
         * @param array                The options
         */
        public function addAttributeFields(FormBuilderInterface $builder, array $options)
        {
            foreach ($options['attributes'] as $attributeName => $attributeValue) {
                $builder->add('attributes' . $attributeName, '«nsSymfonyFormType»TextType', [
                    'mapped' => false,
                    'label' => $this->translator->trans($attributeName, [], '«app.appName.formatForDB»'),
                    'data' => $attributeValue,
                    'required' => false,
                    'max_length' => 255
                ]);
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
                    'class' => 'category-selector'
                ],
                'required' => false,
                'multiple' => «categorisableMultiSelection.displayBool»,
                'module' => '«app.appName»',
                'entity' => ucfirst($objectType) . 'Entity',
                'entityCategoryClass' => '«app.appNamespace»\Entity\' . ucfirst($objectType) . 'CategoryEntity'
            ]);
        }
    '''

    def private addMetaDataFields(Entity it) '''
        /**
         * Adds a meta data fields.
         *
         * @param FormBuilderInterface The form builder.
         * @param array                The options
         */
        public function addMetaDataFields(FormBuilderInterface $builder, array $options)
        {
            // embedded meta data form
            $builder->add('metadata', '«app.appNamespace»\Form\Type\EntityMetaDataType', [
                'constraints' => new Valid()
            ]);
        }
    '''

    def private addReturnControlField(Entity it) '''
        /**
         * Adds the return control field.
         *
         * @param FormBuilderInterface The form builder.
         * @param array                The options
         */
        public function addReturnControlField(FormBuilderInterface $builder, array $options)
        {
            $builder->add('repeatCreation', '«nsSymfonyFormType»CheckboxType', [
                'mapped' => false,
                'label' => $this->translator->trans('Create another item after save', [], '«app.appName.formatForDB»'),
                'required' => false
            ]);
        }
    '''

    def private addAdditionalNotificationRemarksField(Entity it) '''
        /**
         * Adds a field for additional notification remarks.
         *
         * @param FormBuilderInterface The form builder.
         * @param array                The options
         */
        public function addAdditionalNotificationRemarksField(FormBuilderInterface $builder, array $options)
        {
            $helpText = '';
            if ($options['isModerator'] || $options['isSuperModerator']) {
                $helpText = $this->translator->trans('These remarks (like a reason for deny) are not stored, but added to any notification emails send to the creator.', [], '«app.appName.formatForDB»');
        	} elseif ($options['isCreator']) {
        	    $helpText = $this->translator->trans('These remarks (like questions about conformance) are not stored, but added to any notification emails send to our moderators.', [], '«app.appName.formatForDB»');
        	}

            $builder->add('additionalNotificationRemarks', '«nsSymfonyFormType»TextareaType', [
                'mapped' => false,
                'label' => $this->translator->trans('Additional remarks', [], '«app.appName.formatForDB»'),
                'label_attr' => [
                    'class' => '«app.appName.toLowerCase»-form-tooltips',
                    'title' => $helpText
                ],
                'attr' => [
                    'id' => 'additionalNotificationRemarks',
                    'title' => $options['mode'] == 'create' ? $this->translator->trans('Enter any additions about your content', [], '«app.appName.formatForDB»') : $this->translator->trans('Enter any additions about your changes', [], '«app.appName.formatForDB»')
                ],
                'required' => false,
                'help' => $helpText
            ]);
        }
    '''

    def private addSubmitButtons(Entity it) '''
        /**
         * Adds submit buttons.
         *
         * @param FormBuilderInterface The form builder.
         * @param array                The options
         */
        public function addSubmitButtons(FormBuilderInterface $builder, array $options)
        {
            foreach ($options['actions'] as $action) {
                $builder->add($action['id'], '«nsSymfonyFormType»SubmitType', [
                    'label' => $this->translator->trans($action['title'], [], '«app.appName.formatForDB»'),
                    'attr' => [
                        'id' => 'btn' . ucfirst($action['id']),
                        'class' => $action['buttonClass'],
                        'title' => $this->translator->trans($action['description'], [], '«app.appName.formatForDB»')
                    ]
                ]);
            }
            $builder->add('reset', '«nsSymfonyFormType»ResetType', [
                'label' => $this->translator->trans('Reset', [], '«app.appName.formatForDB»'),
                'attr' => [
                    'id' => 'btnReset'
                ]
            ]);
            $builder->add('cancel', '«nsSymfonyFormType»SubmitType', [
                'label' => $this->translator->trans('Cancel', [], '«app.appName.formatForDB»'),
                'attr' => [
                    'id' => 'btnCancel'
                ]
            ]);
        }
    '''

    def private editTypeImpl(Entity it) '''
        namespace «app.appNamespace»\Form\Type;

        use «app.appNamespace»\Form\Type\Base\«name.formatForCodeCapital»Type as Base«name.formatForCodeCapital»Type;

        /**
         * «name.formatForDisplayCapital» editing form type implementation class.
         */
        class «name.formatForCodeCapital»Type extends Base«name.formatForCodeCapital»Type
        {
            // feel free to extend the «name.formatForDisplay» editing form type class here
        }
    '''
}
