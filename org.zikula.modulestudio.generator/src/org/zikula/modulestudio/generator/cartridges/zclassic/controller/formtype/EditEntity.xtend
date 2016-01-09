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

        use Symfony\Component\Form\AbstractType as SymfonyAbstractType;
        use Symfony\Component\Form\FormBuilderInterface;
        use Symfony\Component\OptionsResolver\OptionsResolver;
        use Symfony\Component\Translation\TranslatorInterface;
        «IF metaData»
            use Symfony\Component\Validator\Constraints\Valid;
        «ENDIF»
        «IF hasListFieldsEntity»
            use «app.appNamespace»\Helper\ListEntriesHelper;
        «ENDIF»

        /**
         * «name.formatForDisplayCapital» editing form type base class.
         */
        class «name.formatForCodeCapital»Type extends SymfonyAbstractType
        {
            /**
             * @var TranslatorInterface
             */
            private $translator;
            «IF hasListFieldsEntity»

                /**
                 * @var ListEntriesHelper
                 */
                private $listHelper;
            «ENDIF»

            /**
             * «name.formatForCodeCapital»Type constructor.
             *
             * @param TranslatorInterface $translator Translator service instance.
            «IF hasListFieldsEntity»
                «' '»* @param ListEntriesHelper   $listHelper   ListEntriesHelper service instance.
            «ENDIF»
             */
            public function __construct(TranslatorInterface $translator«IF hasListFieldsEntity»ListEntriesHelper $listHelper«ENDIF»)
            {
                $this->translator = $translator;
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
            «/* TODO */»
            «IF hasTranslatableFields»
                {% set useOnlyCurrentLanguage = true %}
                {% if getModVar('ZConfig', 'multilingual') %}
                    {% if supportedLanguages is iterable and supportedLanguages|length > 1 %}
                        {% set useOnlyCurrentLanguage = false %}
                        {% set currentLanguage = lang() %}
                        {% for language in supportedLanguages %}
                            {% if language == currentLanguage %}
                                «translatableFieldSet('', '')»
                            {% endif %}
                        {% endfor %}
                        {% for language in supportedLanguages %}
                            {% if language != currentLanguage %}
                                «translatableFieldSet('language', 'language')»
                            {% endif %}
                        {% endfor %}
                    {% endif %}
                {% endif %}
                {% if useOnlyCurrentLanguage == true %}
                    {% set language = lang() %}
                    «translatableFieldSet('', '')»
                {% endif %}
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
        «/* TODO */»
        «FOR field : getEditableTranslatableFields»«field.fieldImpl(groupSuffix, idSuffix)»«ENDFOR»
        «IF hasTranslatableSlug»
            «slugField(groupSuffix, idSuffix)»
        «ENDIF»
    '''

    def private slugField(Entity it, String groupSuffix, String idSuffix) '''
        «IF hasSluggableFields && slugUpdatable»
            $builder->add('slug«idSuffix»', '«nsSymfonyFormType»TextType', [
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
        $builder->add('«name.formatForCode»«idSuffix»', '«IF it instanceof StringField && (it as StringField).locale»Zikula\Bundle\FormExtensionBundle\Form\Type\Locale«ELSE»«nsSymfonyFormType»«formType»«ENDIF»Type', [
            'label' => $this->translator->trans('«name.formatForDisplayCapital»', [], '«app.appName.formatForDB»') . ':',
            «IF documentation !== null && documentation != ''»
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
            «IF documentation !== null && documentation != ''»
                'help' => $this->translator->trans('«documentation.replace("'", '"')»', [], '«app.appName.formatForDB»'),
            «ENDIF»«additionalOptions»
        ])
    '''

    def private dispatch formType(DerivedField it) '''Text'''
    def private dispatch titleAttribute(DerivedField it) '''Enter the «name.formatForDisplay» of the «entity.name.formatForDisplay»'''
    def private dispatch additionalOptions(DerivedField it) '''
        'required' => «mandatory.displayBool»,
        'max_length' => 255
    '''

    def private dispatch formType(BooleanField it) '''Checkbox'''
    def private dispatch titleAttribute(BooleanField it) '''«name.formatForDisplay» ?'''
    def private dispatch additionalOptions(BooleanField it) '''
        'required' => «mandatory.displayBool»,
    '''

    def private dispatch formType(IntegerField it) '''Integer'''
    def private dispatch titleAttribute(IntegerField it) '''Enter the «name.formatForDisplay» of the «entity.name.formatForDisplay». Only digits are allowed.'''
    def private dispatch additionalOptions(IntegerField it) '''
        «val hasMin = minValue.compareTo(BigInteger.valueOf(0)) > 0»
        «val hasMax = maxValue.compareTo(BigInteger.valueOf(0)) > 0»
        'required' => «mandatory.displayBool»,
        'max_length' => «length»,
        «IF hasMin || hasMax»
            «IF hasMin && hasMax»
                «IF minValue == maxValue»
                    'help' => $this->translator->trans('Note: this value must exactly be %value%.', ['%value% => «minValue»], '«app.appName.formatForDB»'),
                «ELSE»
                    'help' => $this->translator->trans('Note: this value must be between %minValue% and %maxValue%.', ['%minValue% => «minValue», '%maxValue%' => «maxValue»], '«app.appName.formatForDB»'),
                «ENDIF»
            «ELSEIF hasMin»
                'help' => $this->translator->trans('Note: this value must be greater than %minValue%.', ['%minValue% => «minValue»], '«app.appName.formatForDB»'),
            «ELSEIF hasMax»
                'help' => $this->translator->trans('Note: this value must be less than %maxValue%.', ['%maxValue% => «maxValue»], '«app.appName.formatForDB»'),
            «ENDIF»
        «ENDIF»
        'scale' => 0
    '''

    def private dispatch formType(DecimalField it) '''«IF currency»Money«ELSE»Number«ENDIF»'''
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
                    'help' => $this->translator->trans('Note: this value must exactly be %value%.', ['%value% => «minValue»], '«app.appName.formatForDB»'),
                «ELSE»
                    'help' => $this->translator->trans('Note: this value must be between %minValue% and %maxValue%.', ['%minValue% => «minValue», '%maxValue%' => «maxValue»], '«app.appName.formatForDB»'),
                «ENDIF»
            «ELSEIF hasMin»
                'help' => $this->translator->trans('Note: this value must be greater than %minValue%.', ['%minValue% => «minValue»], '«app.appName.formatForDB»'),
            «ELSEIF hasMax»
                'help' => $this->translator->trans('Note: this value must be less than %maxValue%.', ['%maxValue% => «maxValue»], '«app.appName.formatForDB»'),
            «ENDIF»
        «ENDIF»
        'scale' => «scale»
    '''

    def private dispatch formType(FloatField it) '''«IF currency»Money«ELSE»Number«ENDIF»'''
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
                    'help' => $this->translator->trans('Note: this value must exactly be %value%.', ['%value% => «minValue»], '«app.appName.formatForDB»'),
                «ELSE»
                    'help' => $this->translator->trans('Note: this value must be between %minValue% and %maxValue%.', ['%minValue% => «minValue», '%maxValue%' => «maxValue»], '«app.appName.formatForDB»'),
                «ENDIF»
            «ELSEIF hasMin»
                'help' => $this->translator->trans('Note: this value must be greater than %minValue%.', ['%minValue% => «minValue»], '«app.appName.formatForDB»'),
            «ELSEIF hasMax»
                'help' => $this->translator->trans('Note: this value must be less than %maxValue%.', ['%maxValue% => «maxValue»], '«app.appName.formatForDB»'),
            «ENDIF»
        «ENDIF»
        'scale' => 2
    '''

    def private dispatch formType(StringField it) '''«IF country»Country«ELSEIF language»Language«ELSEIF locale»Locale«ELSEIF htmlcolour»«/* TODO colour type */»«ELSEIF password»Password«ELSE»Text«ENDIF»'''
    def private dispatch titleAttribute(StringField it) '''«IF country || language || locale || htmlcolour»Choose the «name.formatForDisplay» of the «entity.name.formatForDisplay»«ELSE»Enter the «name.formatForDisplay» of the «entity.name.formatForDisplay»«ENDIF»'''
    def private dispatch additionalOptions(StringField it) '''
        'required' => «mandatory.displayBool»,
        «IF !mandatory && (country || language || locale)»
            'placeholder' => $this->translator->trans('All', [], '«app.appName.formatForDB»'),
        «ENDIF»
        'max_length' => «length»
    '''

    def private dispatch TODO(StringField it, String groupSuffix, String idSuffix) '''
        «IF minLength > 0» minLength=«minLength»«ENDIF»
        «IF regexp !== null && regexp != ''»
            'pattern' => string with html5 pattern attribute
            <span class="help-block">{gt text='Note: this value must«IF regexpOpposite» not«ENDIF» conform to the regular expression "%s".' tag1='«regexp.replace('\'', '')»'}</span>
        «ENDIF»
    '''

    def private dispatch formType(TextField it) '''Textarea'''
    def private dispatch additionalOptions(TextField it) '''
        'required' => «mandatory.displayBool»,
        'max_length' => «length»
    '''

    def private dispatch TODO(TextField it, String groupSuffix, String idSuffix) '''
        «IF minLength > 0» minLength=«minLength»«ENDIF»
        «IF regexp !== null && regexp != ''»
            'pattern' => string with html5 pattern attribute
            <span class="help-block">{gt text='Note: this value must«IF regexpOpposite» not«ENDIF» conform to the regular expression "%s".' tag1='«regexp.replace('\'', '')»'}</span>
        «ENDIF»
    '''

    def private dispatch formType(EmailField it) '''Email'''
    def private dispatch additionalOptions(EmailField it) '''
        'required' => «mandatory.displayBool»,
        'max_length' => «length»
    '''

    def private dispatch TODO(EmailField it, String groupSuffix, String idSuffix) '''
        «IF minLength > 0» minLength=«minLength»«ENDIF»
    '''

    def private dispatch formType(UrlField it) '''Url'''
    def private dispatch additionalOptions(UrlField it) '''
        'required' => «mandatory.displayBool»,
        'max_length' => «length»«/*,
        'default_protocol' => 'http'*/»
    '''


    def private dispatch TODO(UrlField it, String groupSuffix, String idSuffix) '''
        «IF minLength > 0» minLength=«minLength»«ENDIF»
    '''

/* TODO */

/* TODO help can be an array now */

    def private dispatch formField(UploadField it, String groupSuffix, String idSuffix) '''
        «IF mandatory»
            {if $mode eq 'create'}
                {formuploadinput «groupAndId(groupSuffix, idSuffix)» mandatory=«mandatory.displayBool» readOnly=«readonly.displayBool»«validationHelper.fieldValidationCssClass(it, true)»}
            {else}
                {formuploadinput «groupAndId(groupSuffix, idSuffix)» mandatory=false readOnly=«readonly.displayBool»«validationHelper.fieldValidationCssClassOptional(it, true)»}
                <span class="help-block"><a id="reset«name.formatForCodeCapital»Val" href="javascript:void(0);" class="hidden">{gt text='Reset to empty value'}</a></span>
            {/if}
        «ELSE»
            {formuploadinput «groupAndId(groupSuffix, idSuffix)» mandatory=false readOnly=«readonly.displayBool»«validationHelper.fieldValidationCssClassOptional(it, true)»}
            <span class="help-block"><a id="reset«name.formatForCodeCapital»Val" href="javascript:void(0);" class="hidden">{gt text='Reset to empty value'}</a></span>
        «ENDIF»

            <span class="help-block">{{ __('Allowed file extensions:') }} <span id="«name.formatForCode»FileExtensions">«allowedExtensions»</span></span>
        «IF allowedFileSize > 0»
            <span class="help-block">{{ __('Allowed file size:') }} {{ '«allowedFileSize»'|«entity.application.appName.formatForDB»_fileSize('', false, false) }}</span>
        «ENDIF»
        «decideWhetherToShowCurrentFile»
    '''

    def private decideWhetherToShowCurrentFile(UploadField it) '''
        «val fieldName = entity.name.formatForDB + '.' + name.formatForCode»
        {% if mode != 'create' and «fieldName» is not empty %}
            «showCurrentFile»
        {% endif %}
    '''

    def private showCurrentFile(UploadField it) '''
        «val appNameSmall = entity.application.appName.formatForDB»
        «val objName = entity.name.formatForDB»
        «val realName = objName + '.' + name.formatForCode»
        <span class="help-block">
            {{ __('Current file') }}:
            <a href="{{ «realName»FullPathUrl }}" title="{{ formattedEntityTitle|e('html_attr') }}"{% if «realName»Meta.isImage %} class="lightbox"{% endif %}>
            {% if «realName»Meta.isImage %}
                {{ «entity.application.appName.formatForDB»_thumb({ image: «realName»FullPath, objectid: '«entity.name.formatForCode»«FOR pkField : entity.getPrimaryKeyFields»-' ~ «objName».«pkField.name.formatForCode» ~ '«ENDFOR»', preset: «entity.name.formatForCode»ThumbPreset«name.formatForCodeCapital», tag: true, img_alt: formattedEntityTitle, img_class: 'img-thumbnail' }) }}
            {% else %}
                {{ __('Download') }} ({{ «realName»Meta.size|«appNameSmall»_fileSize(«realName»FullPath, false, false) }})
            {% endif %}
            </a>
        </span>
        «IF !mandatory»
            <span class="help-block">
                {formcheckbox group='«entity.name.formatForDB»' id='«name.formatForCode»DeleteFile' readOnly=false __title='Delete «name.formatForDisplay» ?'}
                {formlabel for='«name.formatForCode»DeleteFile' __text='Delete existing file'}
            </span>
        «ENDIF»
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

    def private dispatch formType(ListField it) '''Choice'''
    def private dispatch titleAttribute(ListField it) '''Choose the «name.formatForDisplay»'''
    def private dispatch additionalOptions(ListField it) '''
        'placeholder' => $this->translator->trans('All', [], '«app.appName.formatForDB»'),
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

    def private dispatch formField(UserField it, String groupSuffix, String idSuffix) '''
        {«entity.application.appName.formatForDB»UserInput «groupAndId(groupSuffix, idSuffix)» mandatory=«mandatory.displayBool» readOnly=«readonly.displayBool» __title='Enter a part of the user name to search' cssClass='«IF mandatory»required «ENDIF»form-control'}
        {% if mode != 'create' and «entity.name.formatForDB».«name.formatForDB» and inlineUsage != true %}
            <span class="help-block avatar">
                {{ «entity.application.appName.formatForDB»_userAvatar(uid=«entity.name.formatForDB».«name.formatForDB», rating='g') }}
            </span>
            {% if hasPermission('Users::', '::', 'ACCESS_ADMIN') %}
            <span class="help-block"><a href="{{ path('zikulausersmodule_admin_modify', { 'userid': «entity.name.formatForDB».«name.formatForDB» }) }}" title="{{ __('Switch to users administration') }}">{{ __('Manage user') }}</a></span>
            {% endif %}
        {% endif %}
    '''

    def private dispatch formField(AbstractDateField it, String groupSuffix, String idSuffix) '''
        «formFieldDetails(groupSuffix, idSuffix)»
        «IF past»
            <span class="help-block">{{ __('Note: this value must be in the past.') }}</span>
        «ELSEIF future»
            <span class="help-block">{{ __('Note: this value must be in the future.') }}</span>
        «ENDIF»
    '''

    def private dispatch formFieldDetails(AbstractDateField it, String groupSuffix, String idSuffix) {
    }
    def private dispatch formFieldDetails(DatetimeField it, String groupSuffix, String idSuffix) '''
        {if $mode ne 'create'}
            {formdateinput «groupAndId(groupSuffix, idSuffix)» mandatory=«mandatory.displayBool» __title='Enter the «name.formatForDisplay» of the «entity.name.formatForDisplay»' includeTime=true«validationHelper.fieldValidationCssClass(it, true)»}
        {else}
            {formdateinput «groupAndId(groupSuffix, idSuffix)» mandatory=«mandatory.displayBool» __title='Enter the «name.formatForDisplay» of the «entity.name.formatForDisplay»' includeTime=true«IF defaultValue !== null && defaultValue != '' && defaultValue != 'now'» defaultValue='«defaultValue»'«ELSEIF mandatory || !nullable» defaultValue='now'«ENDIF»«validationHelper.fieldValidationCssClass(it, true)»}
        {/if}
        «IF !mandatory && nullable»
            <span class="help-block"><a id="reset«name.formatForCodeCapital»Val" href="javascript:void(0);" class="hidden">{{ __('Reset to empty value') }}</a></span>
        «ENDIF»
    '''

    def private dispatch formFieldDetails(DateField it, String groupSuffix, String idSuffix) '''
        {if $mode ne 'create'}
            {«entity.application.appName.formatForDB»DateInput «groupAndId(groupSuffix, idSuffix)» mandatory=«mandatory.displayBool» __title='Enter the «name.formatForDisplay» of the «entity.name.formatForDisplay»'«validationHelper.fieldValidationCssClass(it, true)»}
        {else}
            {«entity.application.appName.formatForDB»DateInput «groupAndId(groupSuffix, idSuffix)» mandatory=«mandatory.displayBool» __title='Enter the «name.formatForDisplay» of the «entity.name.formatForDisplay»'«IF defaultValue !== null && defaultValue != '' && defaultValue != 'now'» defaultValue='«defaultValue»'«ELSEIF mandatory || !nullable» defaultValue='today'«ENDIF»«validationHelper.fieldValidationCssClass(it, true)»}
        {/if}
        «IF !mandatory && nullable»
            <span class="help-block"><a id="reset«name.formatForCodeCapital»Val" href="javascript:void(0);" class="hidden">{{ __('Reset to empty value') }}</a></span>
        «ENDIF»
    '''

    def private dispatch formFieldDetails(TimeField it, String groupSuffix, String idSuffix) '''
        {«entity.application.appName.formatForDB»TimeInput «groupAndId(groupSuffix, idSuffix)» mandatory=«mandatory.displayBool» readOnly=«readonly.displayBool» __title='Enter the «name.formatForDisplay» of the «entity.name.formatForDisplay»' textMode='singleline' maxLength=8«validationHelper.fieldValidationCssClass(it, true)»}
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
            «/* TODO */»
            «FOR geoFieldName : newArrayList('latitude', 'longitude')»
                {formlabel for='«geoFieldName»' __text='«geoFieldName.toFirstUpper»'}
                {«app.appName.formatForDB»GeoInput group='«name.formatForDB»' id='«geoFieldName»' mandatory=false __title='Enter the «geoFieldName» of the «name.formatForDisplay»' cssClass='validate-number'}
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
            $builder->add('metadata', '«app.appNamespace»\Form\EntityMetaDataType', [
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
