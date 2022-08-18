package org.zikula.modulestudio.generator.cartridges.zclassic.controller.formtype

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.DerivedField
import de.guite.modulestudio.metamodel.ListField
import de.guite.modulestudio.metamodel.StringField
import de.guite.modulestudio.metamodel.StringRole
import de.guite.modulestudio.metamodel.Variables
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ConfigType {

    extension FormattingExtensions = new FormattingExtensions
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
            public function __construct(
                «IF !getAllVariables.filter(StringField).filter[#[StringRole.COUNTRY, StringRole.CURRENCY, StringRole.LANGUAGE, StringRole.LOCALE, StringRole.TIME_ZONE].contains(role)].empty»
                    protected RequestStack $requestStack«IF !getAllVariables.filter(ListField).empty || hasUploadVariables || !getAllVariables.filter(StringField).filter[role == StringRole.LOCALE].empty»,«ENDIF»
                «ENDIF»
                «IF !getAllVariables.filter(ListField).empty»
                    protected ListEntriesHelper $listHelper«IF hasUploadVariables || !getAllVariables.filter(StringField).filter[role == StringRole.LOCALE].empty»,«ENDIF»
                «ENDIF»
                «IF hasUploadVariables»
                    protected UploadHelper $uploadHelper«IF !getAllVariables.filter(StringField).filter[role == StringRole.LOCALE].empty»,«ENDIF»
                «ENDIF»
                «IF !getAllVariables.filter(StringField).filter[role == StringRole.LOCALE].empty»
                    protected LocaleApiInterface $localeApi
                «ENDIF»
            ) {
            }

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
                    'translation_domain' => 'config',
                ]);
            }
        }
    '''

    def private addFieldsMethod(Variables it) '''
        /**
         * Adds fields for «name.formatForDisplay» fields.
         */
        public function add«name.formatForCodeCapital»Fields(FormBuilderInterface $builder, array $options = []): void
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
        public function addSubmitButtons(FormBuilderInterface $builder, array $options = []): void
        {
            $builder->add('save', SubmitType::class, [
                'label' => 'Update configuration',
                'icon' => 'fa-check',
                'attr' => [
                    'class' => 'btn-success',
                ],
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
