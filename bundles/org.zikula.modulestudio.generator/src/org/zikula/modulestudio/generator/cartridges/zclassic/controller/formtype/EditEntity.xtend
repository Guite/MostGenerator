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
        use Zikula\Common\Translator\TranslatorInterface;
        use Zikula\Common\Translator\TranslatorTrait;
        «IF extensions.contains('translatable')»
            use Zikula\ExtensionsModule\Api\VariableApi;
        «ENDIF»
        «IF hasLocaleFieldsEntity && app.targets('1.4-dev')»
            use Zikula\SettingsModule\Api\LocaleApi;
        «ENDIF»
        use «app.appNamespace»\Entity\Factory\«app.name.formatForCodeCapital»Factory;
        «IF app.needsFeatureActivationHelper»
            use «app.appNamespace»\Helper\FeatureActivationHelper;
        «ENDIF»
        «IF hasListFieldsEntity»
            use «app.appNamespace»\Helper\ListEntriesHelper;
        «ENDIF»
        «IF extensions.contains('translatable')»
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
            «IF hasLocaleFieldsEntity && app.targets('1.4-dev')»

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
             * @param TranslatorInterface $translator «IF extensions.contains('translatable')» «ENDIF»   Translator service instance
             * @param «app.name.formatForCodeCapital»Factory        $entityFactory Entity factory service instance
             «IF extensions.contains('translatable')»
             * @param VariableApi         $variableApi VariableApi service instance
             * @param TranslatableHelper  $translatableHelper TranslatableHelper service instance
             «ENDIF»
             «IF hasListFieldsEntity»
             * @param ListEntriesHelper   $listHelper    «IF extensions.contains('translatable')» «ENDIF»ListEntriesHelper service instance
             «ENDIF»
             «IF hasLocaleFieldsEntity && app.targets('1.4-dev')»
             * @param LocaleApi           $localeApi     «IF extensions.contains('translatable')» «ENDIF»LocaleApi service instance
             «ENDIF»
             «IF app.needsFeatureActivationHelper»
             * @param FeatureActivationHelper $featureActivationHelper FeatureActivationHelper service instance
             «ENDIF»
             */
            public function __construct(TranslatorInterface $translator, «app.name.formatForCodeCapital»Factory $entityFactory«IF extensions.contains('translatable')», VariableApi $variableApi, TranslatableHelper $translatableHelper«ENDIF»«IF hasListFieldsEntity», ListEntriesHelper $listHelper«ENDIF»«IF hasLocaleFieldsEntity && app.targets('1.4-dev')», LocaleApi $localeApi«ENDIF»«IF app.needsFeatureActivationHelper», FeatureActivationHelper $featureActivationHelper«ENDIF»)
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
                «IF hasLocaleFieldsEntity && app.targets('1.4-dev')»
                    $this->localeApi = $localeApi;
                «ENDIF»
                «IF app.needsFeatureActivationHelper»
                    $this->featureActivationHelper = $featureActivationHelper;
                «ENDIF»
            }

            «app.setTranslatorMethod»

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
                $this->addReturnControlField($builder, $options);
                $this->addSubmitButtons($builder, $options);
                «IF hasUploadFieldsEntity»

                    $builder->addEventListener(FormEvents::PRE_SET_DATA, function (FormEvent $event) {
                        $entity = $event->getData();
                        foreach (['«getUploadFieldsEntity.map[f|f.name.formatForCode].join("', '")»'] as $uploadFieldName) {
                            if ($entity[$uploadFieldName] instanceof File) {
                                $entity[$uploadFieldName] = [$uploadFieldName => $entity[$uploadFieldName]->getPathname()];
                            }
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
                            'isModerator' => false,
                            «IF it instanceof Entity && (it as Entity).workflow == EntityWorkflowType.ENTERPRISE»
                                'isSuperModerator' => false,
                            «ENDIF»
                            'isCreator' => false,
                        «ENDIF»
                        'actions' => [],
                        «IF !incoming.empty || !outgoing.empty»
                            'filterByOwnership' => true,
                            'currentUserId' => 0,
                            'inlineUsage' => false
                        «ENDIF»
                    ])
                    ->setRequired([«IF hasUploadFieldsEntity»'entity', «ENDIF»'mode', 'actions'])
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
                        «IF !incoming.empty || !outgoing.empty»
                            'filterByOwnership' => 'bool',
                            'currentUserId' => 'int',
                            'inlineUsage' => 'bool'
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
            «val isTranslatable = extensions.contains('translatable')»
            «IF it instanceof Entity && isTranslatable»
                «translatableFields(it as Entity)»
            «ENDIF»
            «fieldAdditions(isTranslatable)»
        }
    '''

    def private translatableFields(Entity it) '''
        $useOnlyCurrentLanguage = true;
        if ($this->variableApi->getSystemVar('multilingual') && $this->featureActivationHelper->isEnabled(FeatureActivationHelper::TRANSLATIONS, '«name.formatForCode»')) {
            $supportedLanguages = $this->translatableHelper->getSupportedLanguages('«name.formatForCode»');
            if (is_array($supportedLanguages) && count($supportedLanguages) > 1) {
                $useOnlyCurrentLanguage = false;
                $currentLanguage = $this->translatableHelper->getCurrentLanguage();
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
        if (true === $useOnlyCurrentLanguage) {
            $language = $this->translatableHelper->getCurrentLanguage();
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
        «IF hasSluggableFields && slugUpdatable && application.supportsSlugInputFields»
            $builder->add('slug'«IF idSuffix != ''» . «idSuffix»«ENDIF», '«nsSymfonyFormType»TextType', [
                'label' => $this->__('Permalink') . ':',
                'required' => false«/* slugUnique.displayBool */»,
                «IF idSuffix != ''»
                    'mapped' => false,
                «ENDIF»
                'attr' => [
                    'max_length' => 255,
                    «IF slugUnique»
                        'class' => 'validate-unique',
                    «ENDIF»
                    'title' => $this->__('You can input a custom permalink for the «name.formatForDisplay»«IF !slugUnique» or let this field free to create one automatically«ENDIF»')
                ],
                'help' => $this->__('You can input a custom permalink for the «name.formatForDisplay»«IF !slugUnique» or let this field free to create one automatically«ENDIF»')
            ]);
        «ENDIF»
    '''

    def private fieldImpl(DerivedField it, String groupSuffix, String idSuffix) '''
        «/* No input fields for foreign keys, relations are processed further down */»
        «IF entity.getIncomingJoinRelations.filter[e|e.getSourceFields.head == name.formatForDB].empty»
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
                «IF !(it instanceof BooleanField || it instanceof UploadField)»
                    'empty_data' => '«defaultValue»',
                «ENDIF»
                «IF idSuffix != ''»
                    'mapped' => false,
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
                ],«additionalOptions»
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
    def private dispatch additionalAttributes(DerivedField it) '''
        'max_length' => 255,
    '''
    def private dispatch additionalOptions(DerivedField it) '''
        'required' => «mandatory.displayBool»
    '''

    def private dispatch formType(BooleanField it) '''«nsSymfonyFormType»Checkbox'''
    def private dispatch titleAttribute(BooleanField it) '''«name.formatForDisplay» ?'''
    def private dispatch additionalAttributes(BooleanField it) ''''''
    def private dispatch additionalOptions(BooleanField it) '''
        'required' => «mandatory.displayBool»,
    '''

    def private dispatch formType(IntegerField it) '''«nsSymfonyFormType»«IF percentage»Percent«ELSEIF range»Range«ELSE»Integer«ENDIF»'''
    def private dispatch titleAttribute(IntegerField it) '''Enter the «name.formatForDisplay» of the «entity.name.formatForDisplay». Only digits are allowed.'''
    def private dispatch additionalAttributes(IntegerField it) '''
        'max_length' => «length»,
    '''
    def private dispatch additionalOptions(IntegerField it) '''
        'required' => «mandatory.displayBool»,
        «IF percentage»
            'type' => 'integer',
        «ENDIF»
        'scale' => 0
    '''

    def private dispatch formType(DecimalField it) '''«nsSymfonyFormType»«IF percentage»Percent«ELSEIF currency»Money«ELSE»Number«ENDIF»'''
    def private dispatch additionalAttributes(DecimalField it) '''
        'max_length' => «(length+3+scale)»,
    '''
    def private dispatch additionalOptions(DecimalField it) '''
        'required' => «mandatory.displayBool»,
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
    def private dispatch additionalAttributes(FloatField it) '''
        'max_length' => «(length+3+2)»,
    '''
    def private dispatch additionalOptions(FloatField it) '''
        'required' => «mandatory.displayBool»,
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
    def private dispatch additionalAttributes(StringField it) '''
        'max_length' => «length»,
        «IF null !== regexp && regexp != ''»
            «IF !regexpOpposite»
                'pattern' => '«regexp.replace('\'', '')»',
            «ENDIF»
        «ENDIF»
    '''
    def private dispatch additionalOptions(StringField it) '''
        'required' => «mandatory.displayBool»,
        «IF !mandatory && (country || language || locale || currency || timezone)»
            'placeholder' => $this->__('All'),
        «ENDIF»
        «IF locale && app.targets('1.4-dev')»
            'choices' => $this->localeApi->getSupportedLocaleNames(),
        «ENDIF»
    '''

    def private dispatch formType(TextField it) '''«nsSymfonyFormType»Textarea'''
    def private dispatch additionalAttributes(TextField it) '''
        'max_length' => «length»,
        «IF null !== regexp && regexp != ''»
            «IF !regexpOpposite»
                'pattern' => '«regexp.replace('\'', '')»',
            «ENDIF»
        «ENDIF»
    '''
    def private dispatch additionalOptions(TextField it) '''
        'required' => «mandatory.displayBool»
    '''

    def private dispatch formType(EmailField it) '''«nsSymfonyFormType»Email'''
    def private dispatch additionalAttributes(EmailField it) '''
        'max_length' => «length»,
    '''
    def private dispatch additionalOptions(EmailField it) '''
        'required' => «mandatory.displayBool»
    '''

    def private dispatch formType(UrlField it) '''«nsSymfonyFormType»Url'''
    def private dispatch additionalAttributes(UrlField it) '''
        'max_length' => «length»,
    '''
    def private dispatch additionalOptions(UrlField it) '''
        'required' => «mandatory.displayBool»«/*,
        'default_protocol' => 'http'*/»
    '''

    def private dispatch formType(UploadField it) '''«app.appNamespace»\Form\Type\Field\Upload'''
    def private dispatch additionalAttributes(UploadField it) ''''''
    def private dispatch additionalOptions(UploadField it) '''
        'required' => «mandatory.displayBool»«IF mandatory» && $options['mode'] == 'create'«ENDIF»,
        'entity' => $options['entity'],
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

    def private dispatch formType(UserField it) '''«app.appNamespace»\Form\Type\Field\User'''
    def private dispatch additionalAttributes(UserField it) '''
        'max_length' => «length»,
    '''
    def private dispatch additionalOptions(UserField it) '''
        'required' => «mandatory.displayBool»,
        'inlineUsage' => $options['inlineUsage']
    '''

    def private dispatch formType(DatetimeField it) '''«nsSymfonyFormType»DateTime'''
    def private dispatch formType(DateField it) '''«nsSymfonyFormType»Date'''
    def private dispatch formType(TimeField it) '''«nsSymfonyFormType»Time'''
    def private dispatch additionalAttributes(AbstractDateField it) ''''''
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
                    'attr' => [
                        'max_length' => 255
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
         *
         * @param FormBuilderInterface $builder The form builder
         * @param array                $options The options
         */
        public function addCategoriesField(FormBuilderInterface $builder, array $options)
        {
            $builder->add('categories', 'Zikula\CategoriesModule\Form\Type\CategoriesType', [
                'label' => $this->__('«IF categorisableMultiSelection»Categories«ELSE»Category«ENDIF»') . ':',
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
        «val relatedEntity = if (outgoing) target else source»
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
                'expanded' => «(if (outgoing) expandedTarget else expandedSource).displayBool»,
                'query_builder' => function(EntityRepository $er) {
                    // select without joins
                    «IF (relatedEntity as Entity).ownerPermission»
                        $qb = $er->getListQueryBuilder('', '', false);
                        if (true === $options['filterByOwnership']) {
                            $qb->andWhere('tbl.createdBy == :currentUserId)')
                               ->setParameter('currentUserId', $options['currentUserId']);
                        }

                        return $qb;
                    «ELSE»
                        return $er->getListQueryBuilder('', '', false);
                    «ENDIF»
                },
                «IF /*outgoing && */!nullable»
                    «IF !isManySide(outgoing)»
                        'placeholder' => $this->__('Please choose an option'),
                    «ENDIF»
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
                    'label' => $this->__(/** @Ignore */$action['title']),
                    'icon' => ($action['id'] == 'delete' ? 'fa-trash-o' : ''),
                    'attr' => [
                        'class' => $action['buttonClass'],
                        'title' => $this->__(/** @Ignore */$action['description'])
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
