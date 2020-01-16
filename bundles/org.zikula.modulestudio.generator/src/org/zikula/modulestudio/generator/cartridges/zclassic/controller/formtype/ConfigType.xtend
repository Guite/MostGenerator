package org.zikula.modulestudio.generator.cartridges.zclassic.controller.formtype

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.DerivedField
import de.guite.modulestudio.metamodel.ListField
import de.guite.modulestudio.metamodel.StringField
import de.guite.modulestudio.metamodel.StringRole
import de.guite.modulestudio.metamodel.Variables
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ConfigType {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelExtensions = new ModelExtensions
    extension SharedFormTypeFields = new SharedFormTypeFields
    extension Utils = new Utils

    /**
     * Entry point for config form type.
     */
    def generate(Application it, IMostFileSystemAccess fsa) {
        if (!needsConfig) {
            return
        }
        fsa.generateClassPair('Form/Type/ConfigType.php', configTypeBaseImpl, configTypeImpl)
    }

    def private configTypeBaseImpl(Application it) '''
        namespace «appNamespace»\Form\Type\Base;

        «getAllVariables.formTypeImports(it, null)»
        use «appNamespace»\AppSettings;
        «IF !getAllVariables.filter(ListField).empty»
            use «appNamespace»\Helper\ListEntriesHelper;
        «ENDIF»
        «IF hasUploadVariables»
            use «appNamespace»\Helper\UploadHelper;
        «ENDIF»

        /**
         * Configuration form type base class.
         */
        abstract class AbstractConfigType extends AbstractType
        {
            «IF !targets('3.0')»
                use TranslatorTrait;

            «ENDIF»
            «IF targets('3.0') && !getAllVariables.filter(StringField).filter[#[StringRole.COUNTRY, StringRole.CURRENCY, StringRole.LANGUAGE, StringRole.LOCALE, StringRole.TIME_ZONE].contains(role)].empty»
                /**
                 * @var RequestStack
                 */
                protected $requestStack;

            «ENDIF»
            «IF !getAllVariables.filter(ListField).empty»

                /**
                 * @var ListEntriesHelper
                 */
                protected $listHelper;
            «ENDIF»
            «IF hasUploadVariables»

                /**
                 * @var UploadHelper
                 */
                protected $uploadHelper;
            «ENDIF»
            «IF !getAllVariables.filter(StringField).filter[role == StringRole.LOCALE].empty»

                /**
                 * @var LocaleApiInterface
                 */
                protected $localeApi;
            «ENDIF»

            public function __construct(
                «IF targets('3.0')»
                    «IF !getAllVariables.filter(StringField).filter[#[StringRole.COUNTRY, StringRole.CURRENCY, StringRole.LANGUAGE, StringRole.LOCALE, StringRole.TIME_ZONE].contains(role)].empty»
                        RequestStack $requestStack«IF !getAllVariables.filter(ListField).empty || hasUploadVariables || !getAllVariables.filter(StringField).filter[role == StringRole.LOCALE].empty»,«ENDIF»
                    «ENDIF»
                    «IF !getAllVariables.filter(ListField).empty»
                        ListEntriesHelper $listHelper«IF hasUploadVariables || !getAllVariables.filter(StringField).filter[role == StringRole.LOCALE].empty»,«ENDIF»
                    «ENDIF»
                    «IF hasUploadVariables»
                        UploadHelper $uploadHelper«IF !getAllVariables.filter(StringField).filter[role == StringRole.LOCALE].empty»,«ENDIF»
                    «ENDIF»
                    «IF !getAllVariables.filter(StringField).filter[role == StringRole.LOCALE].empty»
                        LocaleApiInterface $localeApi
                    «ENDIF»
                «ELSE»
                    TranslatorInterface $translator«IF !getAllVariables.filter(ListField).empty»,
                    ListEntriesHelper $listHelper«ENDIF»«IF hasUploadVariables»,
                    UploadHelper $uploadHelper«ENDIF»«IF !getAllVariables.filter(StringField).filter[role == StringRole.LOCALE].empty»,
                    LocaleApiInterface $localeApi«ENDIF»
                «ENDIF»
            ) {
                «IF !targets('3.0')»
                    $this->setTranslator($translator);
                «ELSEIF targets('3.0') && !getAllVariables.filter(StringField).filter[#[StringRole.COUNTRY, StringRole.CURRENCY, StringRole.LANGUAGE, StringRole.LOCALE, StringRole.TIME_ZONE].contains(role)].empty»
                    $this->requestStack = $requestStack;
                «ENDIF»
                «IF !getAllVariables.filter(ListField).empty»
                    $this->listHelper = $listHelper;
                «ENDIF»
                «IF hasUploadVariables»
                    $this->uploadHelper = $uploadHelper;
                «ENDIF»
                «IF !getAllVariables.filter(StringField).filter[role == StringRole.LOCALE].empty»
                    $this->localeApi = $localeApi;
                «ENDIF»
            }
            «IF !targets('3.0')»

                «setTranslatorMethod»
            «ENDIF»

            public function buildForm(FormBuilderInterface $builder, array $options)
            {
                «FOR varContainer : getSortedVariableContainers»
                    $this->add«varContainer.name.formatForCodeCapital»Fields($builder, $options);
                «ENDFOR»

                $this->addSubmitButtons($builder, $options);
            }

            «FOR varContainer : getSortedVariableContainers»
                «varContainer.addFieldsMethod»

            «ENDFOR»
            «addSubmitButtons»

            public function getBlockPrefix()
            {
                return '«appName.formatForDB»_config';
            }

            public function configureOptions(OptionsResolver $resolver)
            {
                $resolver->setDefaults([
                    // define class for underlying data
                    'data_class' => AppSettings::class,
                ]);
            }
        }
    '''

    def private addFieldsMethod(Variables it) '''
        /**
         * Adds fields for «name.formatForDisplay» fields.
         */
        public function add«name.formatForCodeCapital»Fields(FormBuilderInterface $builder, array $options = [])«IF application.targets('3.0')»: void«ENDIF»
        {
            «FOR field : fields.filter(DerivedField)»
                «field.definition»
            «ENDFOR»
        }
    '''

    def private addSubmitButtons(Application it) '''
        /**
         * Adds submit buttons.
         */
        public function addSubmitButtons(FormBuilderInterface $builder, array $options = [])«IF targets('3.0')»: void«ENDIF»
        {
            $builder->add('save', SubmitType::class, [
                'label' => «IF !targets('3.0')»$this->__(«ENDIF»'Update configuration'«IF !targets('3.0')»)«ENDIF»,
                'icon' => 'fa-check',
                'attr' => [
                    'class' => '«IF !targets('3.0')»btn «ENDIF»btn-success'
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
