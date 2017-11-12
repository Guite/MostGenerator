package org.zikula.modulestudio.generator.cartridges.zclassic.controller.formtype

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.DerivedField
import de.guite.modulestudio.metamodel.ListField
import de.guite.modulestudio.metamodel.StringField
import de.guite.modulestudio.metamodel.StringRole
import de.guite.modulestudio.metamodel.UploadField
import de.guite.modulestudio.metamodel.Variables
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ConfigType {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension NamingExtensions = new NamingExtensions
    extension SharedFormTypeFields = new SharedFormTypeFields
    extension Utils = new Utils

    FileHelper fh = new FileHelper

    /**
     * Entry point for config form type.
     */
    def generate(Application it, IFileSystemAccess fsa) {
        if (!needsConfig) {
            return
        }
        generateClassPair(fsa, getAppSourceLibPath + 'Form/Type/ConfigType.php',
            fh.phpFileContent(it, configTypeBaseImpl), fh.phpFileContent(it, configTypeImpl)
        )
    }

    def private configTypeBaseImpl(Application it) '''
        namespace «appNamespace»\Form\Type\Base;

        «getAllVariables.formTypeImports(it, null)»
        use «appNamespace»\AppSettings;
        «IF !getAllVariables.filter(ListField).empty»
            use «appNamespace»\Helper\ListEntriesHelper;
        «ENDIF»

        /**
         * Configuration form type base class.
         */
        abstract class AbstractConfigType extends AbstractType
        {
            use TranslatorTrait;
            «IF !getAllVariables.filter(ListField).empty»

                /**
                 * @var ListEntriesHelper
                 */
                protected $listHelper;
            «ENDIF»
            «IF !getAllVariables.filter(StringField).filter[role == StringRole.LOCALE].empty»

                /**
                 * @var LocaleApiInterface
                 */
                protected $localeApi;
            «ENDIF»

            /**
             * ConfigType constructor.
             *
             * @param TranslatorInterface $translator Translator service instance
             «IF !getAllVariables.filter(ListField).empty»
             * @param ListEntriesHelper $listHelper ListEntriesHelper service instance
             «ENDIF»
             «IF !getAllVariables.filter(StringField).filter[role == StringRole.LOCALE].empty»
             * @param LocaleApiInterface $localeApi LocaleApi service instance
             «ENDIF»
             */
            public function __construct(
                TranslatorInterface $translator«IF !getAllVariables.filter(ListField).empty»,
                ListEntriesHelper $listHelper«ENDIF»«IF !getAllVariables.filter(StringField).filter[role == StringRole.LOCALE].empty»,
                LocaleApiInterface $localeApi«ENDIF»
            ) {
                $this->setTranslator($translator);
                «IF !getAllVariables.filter(ListField).empty»
                    $this->listHelper = $listHelper;
                «ENDIF»
                «IF !getAllVariables.filter(StringField).filter[role == StringRole.LOCALE].empty»
                    $this->localeApi = $localeApi;
                «ENDIF»
            }

            «setTranslatorMethod»

            /**
             * @inheritDoc
             */
            public function buildForm(FormBuilderInterface $builder, array $options)
            {
                «FOR varContainer : getSortedVariableContainers»
                    $this->add«varContainer.name.formatForCodeCapital»Fields($builder, $options);
                «ENDFOR»

                $this->addSubmitButtons($builder, $options);
                «IF !getAllVariables.filter(UploadField).empty»

                    $builder->addEventListener(FormEvents::PRE_SET_DATA, function (FormEvent $event) {
                        $data = $event->getData();
                        foreach (['«getAllVariables.filter(UploadField).map[f|f.name.formatForCode].join("', '")»'] as $uploadFieldName) {
                            $data[$uploadFieldName] = [
                                $uploadFieldName => $data[$uploadFieldName] instanceof File ? $data[$uploadFieldName]->getPathname() : null
                            ];
                        }
                    });
                    $builder->addEventListener(FormEvents::SUBMIT, function (FormEvent $event) {
                        $data = $event->getData();
                        foreach (['«getAllVariables.filter(UploadField).map[f|f.name.formatForCode].join("', '")»'] as $uploadFieldName) {
                            if (is_array($data[$uploadFieldName])) {
                                $data[$uploadFieldName] = $data[$uploadFieldName][$uploadFieldName];
                            }
                        }
                    });
                «ENDIF»
            }

            «FOR varContainer : getSortedVariableContainers»
                «varContainer.addFieldsMethod»

            «ENDFOR»
            «addSubmitButtons»

            /**
             * @inheritDoc
             */
            public function getBlockPrefix()
            {
                return '«appName.formatForDB»_config';
            }

            /**
             * @inheritDoc
             */
            public function configureOptions(OptionsResolver $resolver)
            {
                $resolver
                    ->setDefaults([
                        // define class for underlying data
                        'data_class' => AppSettings::class,
                    ]);
            }
        }
    '''

    def private addFieldsMethod(Variables it) '''
        /**
         * Adds fields for «name.formatForDisplay» fields.
         *
         * @param FormBuilderInterface $builder The form builder
         * @param array                $options The options
         */
        public function add«name.formatForCodeCapital»Fields(FormBuilderInterface $builder, array $options = [])
        {
            «FOR field : fields.filter(DerivedField)»
                «field.definition»
            «ENDFOR»
        }
    '''

    def private addSubmitButtons(Application it) '''
        /**
         * Adds submit buttons.
         *
         * @param FormBuilderInterface $builder The form builder
         * @param array                $options The options
         */
        public function addSubmitButtons(FormBuilderInterface $builder, array $options = [])
        {
            $builder->add('save', SubmitType::class, [
                'label' => $this->__('Update configuration'),
                'icon' => 'fa-check',
                'attr' => [
                    'class' => 'btn btn-success'
                ]
            ]);
            «addCommonSubmitButtons»
        }
    '''

    def private configTypeImpl(Application it) '''
        namespace «appNamespace»\Form\Type;

        use «appNamespace»\Form\Type\Base\AbstractConfigType;

        /**
         * Configuration form type implementation class.
         */
        class ConfigType extends AbstractConfigType
        {
            // feel free to extend the base form type class here
        }
    '''
}
