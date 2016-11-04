package org.zikula.modulestudio.generator.cartridges.zclassic.controller.formtype

import de.guite.modulestudio.metamodel.AbstractDateField
import de.guite.modulestudio.metamodel.Application
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
     * 1.4.x only.
     */
    def generate(DataObject it, IFileSystemAccess fsa) {
        if (!(it instanceof MappedSuperClass) && !hasActions('edit')) {
            return
        }
        if (it instanceof Entity) {
            if (metaData) extensions.add('metadata')
            if (hasTranslatableFields) extensions.add('translatable')
            if (attributable) extensions.add('attributes')
            if (categorisable) extensions.add('categories')
        }
        app = it.application
        incomingRelations = getBidirectionalIncomingJoinRelations.filter[source.application == app && source instanceof Entity]
        outgoingRelations = getOutgoingJoinRelations.filter[target.application == app && target instanceof Entity]
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
        use Symfony\Component\Form\FormBuilderInterface;
        use Symfony\Component\Form\FormInterface;
        use Symfony\Component\OptionsResolver\OptionsResolver;
        use Zikula\Common\Translator\TranslatorInterface;
        «IF extensions.contains('metadata')»
            use Symfony\Component\Validator\Constraints\Valid;
        «ENDIF»
        use Zikula\Common\Translator\TranslatorTrait;
        use «app.appNamespace»\Entity\Factory\«name.formatForCodeCapital»Factory;
        «IF extensions.contains('translatable')»
            use Zikula\ExtensionsModule\Api\VariableApi;
            use ZLanguage;
            use «app.appNamespace»\Helper\TranslatableHelper;
        «ENDIF»
        «IF hasListFieldsEntity»
            use «app.appNamespace»\Helper\ListEntriesHelper;
        «ENDIF»

        /**
         * «name.formatForDisplayCapital» editing form type base class.
         */
        abstract class Abstract«name.formatForCodeCapital»Type extends AbstractType
        {
            use TranslatorTrait;

            /**
             * @var «name.formatForCodeCapital»Factory
             */
            protected $entityFactory;
            «IF extensions.contains('translatable')»

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

            /**
             * «name.formatForCodeCapital»Type constructor.
             *
             * @param TranslatorInterface $translator «IF extensions.contains('translatable')» «ENDIF»   Translator service instance
             * @param «name.formatForCodeCapital»Factory        $entityFactory Entity factory service instance
            «IF extensions.contains('translatable')»
                «' '»* @param VariableApi         $variableApi VariableApi service instance
                «' '»* @param TranslatableHelper  $listHelper  TranslatableHelper service instance
            «ENDIF»
            «IF hasListFieldsEntity»
                «' '»* @param ListEntriesHelper   $listHelper    «IF extensions.contains('translatable')» «ENDIF»ListEntriesHelper service instance
            «ENDIF»
             */
            public function __construct(TranslatorInterface $translator, «name.formatForCodeCapital»Factory $entityFactory«IF extensions.contains('translatable')», VariableApi $variableApi, TranslatableHelper $translatableHelper«ENDIF»«IF hasListFieldsEntity», ListEntriesHelper $listHelper«ENDIF»)
            {
                $this->setTranslator($translator);
                $this->entityFactory = $entityFactory;
                «IF extensions.contains('translatable')»
                    $this->variableApi = $variableApi;
                    $this->translatableHelper = $translatableHelper;
                «ENDIF»
                «IF hasListFieldsEntity»
                    $this->listHelper = $listHelper;
                «ENDIF»
            }

            /**
             * Sets the translator.
             *
             * @param TranslatorInterface $translator Translator service instance
             */
            public function setTranslator(/*TranslatorInterface */$translator)
            {
                $this->translator = $translator;
            }

            /**
             * {@inheritdoc}
             */
            public function buildForm(FormBuilderInterface $builder, array $options)
            {
                $this->addEntityFields($builder, $options);
                «val parents = getParentDataObjects(#[])»
                «IF !parents.empty»
                    $builder->add('parentFields', '«app.appNamespace»\Form\Type\«parents.head.name.formatForCodeCapital»Type', [
                        'data_class' => '«entityClassName('', false)»'
                    ]);
                «ENDIF»
                «IF extensions.contains('attributes')»
                    $this->addAttributeFields($builder, $options);
                «ENDIF»
                «IF extensions.contains('categories')»
                    $this->addCategoriesField($builder, $options);
                «ENDIF»
                «IF !incomingRelations.empty»
                    $this->addIncomingRelationshipFields($builder, $options);
                «ENDIF»
                «IF !outgoingRelations.empty»
                    $this->addOutgoingRelationshipFields($builder, $options);
                «ENDIF»
                «IF extensions.contains('metadata')»
                    $this->addMetaDataFields($builder, $options);
                «ENDIF»
                «IF it instanceof Entity && (it as Entity).workflow != EntityWorkflowType.NONE»
                    $this->addAdditionalNotificationRemarksField($builder, $options);
                «ENDIF»
                $this->addReturnControlField($builder, $options);
                $this->addSubmitButtons($builder, $options);
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
            «IF extensions.contains('metadata')»
                «addMetaDataFields(it as Entity)»

            «ENDIF»
            «IF it instanceof Entity && (it as Entity).workflow != EntityWorkflowType.NONE»
                «addAdditionalNotificationRemarksField(it as Entity)»

            «ENDIF»
            «IF it instanceof Entity»
                «addReturnControlField»

                «addSubmitButtons»

            «ENDIF»
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
            public function getName()
            {
                return $this->getBlockPrefix();
            }

            /**
             * {@inheritdoc}
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
                            'isModerator' => false,
                            «IF it instanceof Entity && (it as Entity).workflow == EntityWorkflowType.ENTERPRISE»
                                'isSuperModerator' => false,
                            «ENDIF»
                            'isCreator' => false,
                        «ENDIF»
                        'actions' => [],
                        'inlineUsage' => false
                    ])
                    ->setRequired(['mode', 'actions'])
                    ->setAllowedTypes([
                        'mode' => 'string',
                        «IF extensions.contains('attributes')»
                            'attributes' => 'array',
                        «ENDIF»
                        «IF it instanceof Entity && (it as Entity).workflow != EntityWorkflowType.NONE»
                            'isModerator' => 'bool',
                            «IF it instanceof Entity && (it as Entity).workflow == EntityWorkflowType.ENTERPRISE»
                                'isSuperModerator' => 'bool',
                            «ENDIF»
                            'isCreator' => 'bool',
                        «ENDIF»
                        'actions' => 'array',
                        'inlineUsage' => 'bool'
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
            «val isTranslatable = extensions.contains('translatable')»
            «IF it instanceof Entity && isTranslatable»
                «translatableFields(it as Entity)»
            «ENDIF»
            «fieldAdditions(isTranslatable)»
        }
    '''

    def private translatableFields(Entity it) '''
        $useOnlyCurrentLanguage = true;
        if ($this->variableApi->getSystemVar('multilingual')) {
            $supportedLanguages = $this->translatableHelper->getSupportedLanguages('«name.formatForCode»');
            if (is_array($supportedLanguages) && count($supportedLanguages) > 1) {
                $useOnlyCurrentLanguage = false;
                $currentLanguage = ZLanguage::getLanguageCode();
                foreach ($supportedLanguages as $language) {
                    if ($language != $currentLanguage) {
                        continue;
                    }
                    «translatableFieldSet('', '')»
                }
                foreach ($supportedLanguages as $language) {
                    if ($language == $currentLanguage) {
                        continue;
                    }
                    «translatableFieldSet('$language', '$language')»
                }
            }
        }
        if ($useOnlyCurrentLanguage === true) {
            $language = ZLanguage::getLanguageCode();
            «translatableFieldSet('', '')»
        }
    '''

    def private fieldAdditions(DataObject it, Boolean isTranslatable) '''
        «IF !isTranslatable || !getEditableNonTranslatableFields.empty»
            «IF isTranslatable»
                «FOR field : getEditableNonTranslatableFields»«field.fieldImpl('', '')»«ENDFOR»
            «ELSE»
                «FOR field : getEditableFields»«field.fieldImpl('', '')»«ENDFOR»
            «ENDIF»
        «ENDIF»
        «IF it instanceof Entity»
            «IF hasSluggableFields && (!isTranslatable || !hasTranslatableSlug)»

                «slugField('', '')»
            «ENDIF»
            «IF geographical»
                $this->addGeographicalFields($builder, $options);
            «ENDIF»
        «ENDIF»
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
                'label' => $this->__('Permalink') . ':',
                'required' => false«/* slugUnique.displayBool */»,
                'attr' => [
                    «IF slugUnique»
                        'class' => 'validate-unique',
                    «ENDIF»
                    'title' => $this->__('You can input a custom permalink for the «name.formatForDisplay»«IF !slugUnique» or let this field free to create one automatically«ENDIF»')
                ],
                'help' => $this->__('You can input a custom permalink for the «name.formatForDisplay»«IF !slugUnique» or let this field free to create one automatically«ENDIF»'),
                'max_length' => 255
            ]);
        «ENDIF»
    '''

    def private fieldImpl(DerivedField it, String groupSuffix, String idSuffix) '''
        «IF it instanceof ListField»
            «fetchListEntries»
        «ENDIF»
        «val isExpandedListField = it instanceof ListField && (it as ListField).expanded»
        $builder->add('«name.formatForCode»'«IF idSuffix != ''» . «idSuffix»«ENDIF», '«formType»Type', [
            'label' => $this->__('«name.formatForDisplayCapital»') . ':',
            «IF null !== documentation && documentation != ''»
                'label_attr' => [
                    'class' => 'tooltips«IF isExpandedListField» «IF (it as ListField).multiple»checkbox«ELSE»radio«ENDIF»-inline«ENDIF»',
                    'title' => $this->__('«documentation.replace("'", '"')»')
                ],
                «helpAttribute»
            «ELSEIF isExpandedListField»
                'label_attr' => [
                    'class' => '«IF (it as ListField).multiple»checkbox«ELSE»radio«ENDIF»-inline'
                ],
            «ENDIF»
            «IF readonly»
                'disabled' => true,
            «ENDIF»
            'empty_data' => «IF it instanceof UploadField»null«ELSE»'«defaultValue»'«ENDIF»,
            'attr' => [
                'class' => '«validationHelper.fieldValidationCssClass(it)»',
                «IF readonly»
                    'readonly' => 'readonly',
                «ENDIF»
                «IF it instanceof IntegerField && (it as IntegerField).range»
                    'min' => «(it as IntegerField).minValue»,
                    'max' => «(it as IntegerField).maxValue»,
                «ENDIF»
                'title' => $this->__('«titleAttribute»')
            ],«additionalOptions»
        ]);
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
                messages += '''$this->__f('Note: this value must be less than %maxValue%.', ['%maxValue%' => «maxValue»]')'''
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
                messages += '''$this->__f('Note: this value must be less than %maxValue%.', ['%maxValue%' => «maxValue»]')'''
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
                messages += '''$this->__f('Note: this value must be less than %maxValue%.', ['%maxValue%' => «maxValue»]')'''
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
    def private dispatch additionalOptions(DerivedField it) '''
        'required' => «mandatory.displayBool»,
        'max_length' => 255
    '''

    def private dispatch formType(BooleanField it) '''«nsSymfonyFormType»Checkbox'''
    def private dispatch titleAttribute(BooleanField it) '''«name.formatForDisplay» ?'''
    def private dispatch additionalOptions(BooleanField it) '''
        'required' => «mandatory.displayBool»,
    '''

    def private dispatch formType(IntegerField it) '''«nsSymfonyFormType»«IF percentage»Percent«ELSEIF range»Range«ELSE»Integer«ENDIF»'''
    def private dispatch titleAttribute(IntegerField it) '''Enter the «name.formatForDisplay» of the «entity.name.formatForDisplay». Only digits are allowed.'''
    def private dispatch additionalOptions(IntegerField it) '''
        'required' => «mandatory.displayBool»,
        'max_length' => «length»,
        «IF percentage»
            'type' => 'integer',
        «ENDIF»
        'scale' => 0
    '''

    def private dispatch formType(DecimalField it) '''«nsSymfonyFormType»«IF percentage»Percent«ELSEIF currency»Money«ELSE»Number«ENDIF»'''
    def private dispatch additionalOptions(DecimalField it) '''
        'required' => «mandatory.displayBool»,
        'max_length' => «(length+3+scale)»,
        «/* not required since these are the default values IF currency»
            'currency' => 'EUR',
            'divisor' => 1,
        «ENDIF*/»
        «/* not required since these are the default values IF percentage»
            'type' => 'fractional',
        «ENDIF*/»
        'scale' => «scale»
    '''

    def private dispatch formType(FloatField it) '''«nsSymfonyFormType»«IF percentage»Percent«ELSEIF currency»Money«ELSE»Number«ENDIF»'''
    def private dispatch additionalOptions(FloatField it) '''
        'required' => «mandatory.displayBool»,
        'max_length' => «(length+3+2)»,
        «/* not required since these are the default values IF currency»
            'currency' => 'EUR',
            'divisor' => 1,
        «ENDIF*/»
        «/* not required since these are the default values IF percentage»
            'type' => 'fractional',
        «ENDIF*/»
        'scale' => 2
    '''

    def private dispatch formType(StringField it) '''«IF country»«nsSymfonyFormType»Country«ELSEIF language»«nsSymfonyFormType»Language«ELSEIF locale»Zikula\Bundle\FormExtensionBundle\Form\Type\Locale«ELSEIF htmlcolour»«app.appNamespace»\Form\Type\Field\Colour«ELSEIF password»«nsSymfonyFormType»Password«ELSEIF currency»«nsSymfonyFormType»Currency«ELSEIF timezone»«nsSymfonyFormType»Timezone«ELSE»«nsSymfonyFormType»Text«ENDIF»'''
    def private dispatch titleAttribute(StringField it) '''«IF country || language || locale || htmlcolour || currency || timezone»Choose the «name.formatForDisplay» of the «entity.name.formatForDisplay»«ELSE»Enter the «name.formatForDisplay» of the «entity.name.formatForDisplay»«ENDIF»'''
    def private dispatch additionalOptions(StringField it) '''
        'required' => «mandatory.displayBool»,
        «IF !mandatory && (country || language || locale || currency || timezone)»
            'placeholder' => $this->__('All'),
        «ENDIF»
        'max_length' => «length»,
        «IF null !== regexp && regexp != ''»
            «IF !regexpOpposite»
                'pattern' => '«regexp.replace('\'', '')»',
            «ENDIF»
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

    def private dispatch formType(UploadField it) '''«app.appNamespace»\Form\Type\Field\Upload'''
    def private dispatch additionalOptions(UploadField it) '''
        'required' => «mandatory.displayBool»«IF mandatory» && $options['mode'] == 'create'«ENDIF»,
        'allowed_extensions' => '«allowedExtensions»',
        'allowed_size' => «allowedFileSize»
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

    def private dispatch formType(ListField it) '''«IF multiple»«app.appNamespace»\Form\Type\Field\MultiList«ELSE»«nsSymfonyFormType»Choice«ENDIF»'''
    def private dispatch titleAttribute(ListField it) '''Choose the «name.formatForDisplay»'''
    def private dispatch additionalOptions(ListField it) '''
        «IF !expanded»
            «IF mandatory»
                'placeholder' => '',
            «ELSE»
                'placeholder' => $this->__('Choose an option'),
            «ENDIF»
        «ENDIF»
        'choices' => $choices,
        'choices_as_values' => true,
        'choice_attr' => $choiceAttributes,
        'multiple' => «multiple.displayBool»,
        'expanded' => «expanded.displayBool»
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
        'widget' => 'single_text'
    '''
    def private dispatch defaultData(DatetimeField it) '''«IF null !== defaultValue && defaultValue != '' && defaultValue != 'now'»'«defaultValue»'«ELSEIF mandatory || !nullable»date('Y-m-d H:i')«ELSE»''«ENDIF»'''
    def private dispatch defaultData(DateField it) '''«IF null !== defaultValue && defaultValue != '' && defaultValue != 'now'»'«defaultValue»'«ELSEIF mandatory || !nullable»date('Y-m-d')«ELSE»''«ENDIF»'''
    def private dispatch additionalOptions(TimeField it) '''
        'empty_data' => '«defaultValue»',
        'required' => «mandatory.displayBool»,
        'widget' => 'single_text',
        'max_length' => 8
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
                $builder->add('«geoFieldName»', '«app.appNamespace»\Form\Type\Field\GeoType', [
                    'label' => $this->__('«geoFieldName.toFirstUpper»') . ':',
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
         * @param FormBuilderInterface $builder The form builder
         * @param array                $options The options
         */
        public function addAttributeFields(FormBuilderInterface $builder, array $options)
        {
            foreach ($options['attributes'] as $attributeName => $attributeValue) {
                $builder->add('attributes' . $attributeName, '«nsSymfonyFormType»TextType', [
                    'mapped' => false,
                    'label' => $this->__($attributeName),
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
         * @param FormBuilderInterface $builder The form builder
         * @param array                $options The options
         */
        public function addCategoriesField(FormBuilderInterface $builder, array $options)
        {
            $builder->add('categories', 'Zikula\CategoriesModule\Form\Type\CategoriesType', [
                'label' => $this->__('«IF categorisableMultiSelection»Categories«ELSE»Category«ENDIF»', [], '«app.appName.formatForDB»') . ':',
                'empty_data' => [],
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
        $builder->add('«aliasName.formatForCode»', '«formType(autoComplete)»Type', [
            «IF autoComplete»
                «val uniqueNameForJs = getUniqueRelationNameForJs(app, (if (outgoing) source else target), isManySide(outgoing), (if (!isManyToMany) outgoing else !outgoing), aliasName)»
                'objectType' => '«(if (outgoing) target else source).name.formatForCode»',
                'multiple' => «isManySide(outgoing).displayBool»,
                'uniqueNameForJs' => '«uniqueNameForJs»',
                «IF outgoing && !nullable»
                    'required' => false,
                «ENDIF»
            «ELSE»
                'class' => '«app.appName»:«(if (outgoing) target else source).name.formatForCodeCapital»Entity',
                'choice_label' => 'getTitleFromDisplayPattern',
                'multiple' => «isManySide(outgoing).displayBool»,
                'expanded' => «(if (outgoing) expandedTarget else expandedSource).displayBool»,
                'query_builder' => function(EntityRepository $er) {
                    return $er->getListQueryBuilder('', '', false, true);
                },
                «IF outgoing && !nullable»
                    'placeholder' => $this->__('Please choose an option'),
                    'required' => false,
                «ENDIF»
            «ENDIF»
            'label' => $this->__('«aliasName.formatForDisplayCapital»'),
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

    def private addMetaDataFields(Entity it) '''
        /**
         * Adds a meta data fields.
         *
         * @param FormBuilderInterface $builder The form builder
         * @param array                $options The options
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
         * @param FormBuilderInterface $builder The form builder
         * @param array                $options The options
         */
        public function addReturnControlField(FormBuilderInterface $builder, array $options)
        {
            $builder->add('repeatCreation', '«nsSymfonyFormType»CheckboxType', [
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
            if ($options['isModerator']«IF workflow == EntityWorkflowType.ENTERPRISE» || $options['isSuperModerator']«ENDIF») {
                $helpText = $this->__('These remarks (like a reason for deny) are not stored, but added to any notification emails send to the creator.');
            } elseif ($options['isCreator']) {
                $helpText = $this->__('These remarks (like questions about conformance) are not stored, but added to any notification emails send to our moderators.');
            }

            $builder->add('additionalNotificationRemarks', '«nsSymfonyFormType»TextareaType', [
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
                $builder->add($action['id'], '«nsSymfonyFormType»SubmitType', [
                    'label' => $this->__(/** @ignore */$action['title']),
                    'icon' => ($action['id'] == 'delete' ? 'fa-trash-o' : ''),
                    'attr' => [
                        'class' => $action['buttonClass'],
                        'title' => $this->__($action['description'])
                    ]
                ]);
            }
            $builder->add('reset', '«nsSymfonyFormType»ResetType', [
                'label' => $this->__('Reset'),
                'icon' => 'fa-refresh',
                'attr' => [
                    'class' => 'btn btn-default',
                    'formnovalidate' => 'formnovalidate'
                ]
            ]);
            $builder->add('cancel', '«nsSymfonyFormType»SubmitType', [
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
