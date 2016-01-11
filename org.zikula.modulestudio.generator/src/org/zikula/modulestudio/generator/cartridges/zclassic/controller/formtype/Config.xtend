package org.zikula.modulestudio.generator.cartridges.zclassic.controller.formtype

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.BoolVar
import de.guite.modulestudio.metamodel.IntVar
import de.guite.modulestudio.metamodel.ListVar
import de.guite.modulestudio.metamodel.ListVarItem
import de.guite.modulestudio.metamodel.TextVar
import de.guite.modulestudio.metamodel.Variable
import de.guite.modulestudio.metamodel.Variables
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Config {
    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    FileHelper fh = new FileHelper
    Application app
    Boolean hasUserGroupSelectors = false
    String nsSymfonyFormType = 'Symfony\\Component\\Form\\Extension\\Core\\Type\\'

    /**
     * Entry point for config form type.
     * 1.4.x only.
     */
    def generate(Application it, IFileSystemAccess fsa) {
        if (!needsConfig) {
            return
        }
        app = it
        hasUserGroupSelectors = !getAllVariables.filter(IntVar).filter[isUserGroupSelector].empty
        generateClassPair(fsa, getAppSourceLibPath + 'Form/AppSettingsType.php',
            fh.phpFileContent(it, configTypeBaseImpl), fh.phpFileContent(it, configTypeImpl)
        )
    }

    def private configTypeBaseImpl(Application it) '''
        namespace «appNamespace»\Form\Base;

        «IF hasUserGroupSelectors»
            use ModUtil;
        «ENDIF»
        use Symfony\Component\Form\AbstractType;
        use Symfony\Component\Form\FormBuilderInterface;
        use Symfony\Component\Translation\TranslatorInterface;
        use Zikula\ExtensionsModule\Api\VariableApi;

        /**
         * Configuration form type base class.
         */
        class AppSettingsType extends AbstractType
        {
            /**
             * @var TranslatorInterface
             */
            private $translator;

            /**
             * @var VariableApi
             */
            private $variableApi;

            /**
             * @var array
             */
            private $modVars;

            /**
             * AppSettingsType constructor.
             *
             * @param TranslatorInterface $translator  Translator service instance.
             * @param VariableApi         $variableApi VariableApi service instance.
             */
            public function __construct(TranslatorInterface $translator, VariableApi $variableApi)
            {
                $this->translator = $translator;
                $this->variableApi = $variableApi;
                $this->modVars = $this->variableApi->getAll('«appName»');
            }

            /**
             * {@inheritdoc}
             */
            public function buildForm(FormBuilderInterface $builder, array $options)
            {
                «FOR varContainer : variables»
                    $this->add«varContainer.name.formatForCodeCapital»Fields($builder, $options);
                «ENDFOR»

                $builder
                    ->add('save', '«nsSymfonyFormType»SubmitType', [
                        'label' => $this->translator->trans('Update configuration', [], '«appName.formatForDB»')
                    ])
                    ->add('cancel', '«nsSymfonyFormType»SubmitType', [
                        'label' => $this->translator->trans('Cancel', [], '«appName.formatForDB»')
                    ])
                ;
            }

            «FOR varContainer : variables»
                «varContainer.addFieldsMethod»

            «ENDFOR»
            /**
             * {@inheritdoc}
             */
            public function getBlockPrefix()
            {
                return '«appName.formatForDB»_appsettings';
            }
        }
    '''

    def private addFieldsMethod(Variables it) '''
        /**
         * Adds fields for «name.formatForDisplay» fields.
         *
         * @param FormBuilderInterface The form builder.
         * @param array                The options
         */
        public function add«name.formatForCodeCapital»Fields(FormBuilderInterface $builder, array $options)
        {
            $builder
                «FOR modvar : vars»«modvar.definition»«ENDFOR»
            ;
        }
    '''

    def private definition(Variable it) '''
        ->add('«name.formatForCode»', '«fieldType»Type', [
            'label' => $this->translator->trans('«name.formatForDisplayCapital»', [], '«app.appName.formatForDB»') . ':',
            «IF documentation !== null && documentation != ''»
                'label_attr' => [
                    'class' => '«app.appName.toLowerCase»-form-tooltips',
                    'title' => $this->translator->trans('«documentation.replace("'", '"')»', [], '«app.appName.formatForDB»')
                ],
            «ENDIF»
            'required' => false,
            'data' => $this->modVars['«name.formatForCode»'],
            'empty_data' => '«value»',
            'attr' => [
                'title' => $this->translator->trans('«titleAttribute»', [], '«app.appName.formatForDB»')
            ],
            «IF documentation !== null && documentation != ''»
                'help' => $this->translator->trans('«documentation.replace("'", '"')»', [], '«app.appName.formatForDB»'),
            «ENDIF»«additionalOptions»
        ])
    '''

    def private dispatch fieldType(Variable it) '''«nsSymfonyFormType»Text'''
    def private dispatch titleAttribute(Variable it) '''Enter the «name.formatForDisplay».'''
    def private dispatch additionalOptions(Variable it) '''
        'max_length' => 255
    '''

    def private dispatch fieldType(IntVar it) '''«IF hasUserGroupSelectors && isUserGroupSelector»Symfony\Bridge\Doctrine\Form\Type\Entity«ELSE»«nsSymfonyFormType»Integer«ENDIF»'''
    def private dispatch titleAttribute(IntVar it) '''«IF hasUserGroupSelectors && isUserGroupSelector»Choose the «name.formatForDisplay».«ELSE»Enter the «name.formatForDisplay». Only digits are allowed.«ENDIF»'''
    def private dispatch additionalOptions(IntVar it) '''
        'max_length' => 255,
        «IF hasUserGroupSelectors && isUserGroupSelector»
            // Zikula core should provide a form type for this to hide entity details
            'class' => 'Zikula\GroupsModule\Entity\GroupsEntity',
            'choice_label' => 'name'
        «ELSE»
            'scale' => 0
        «ENDIF»
    '''

    def private dispatch fieldType(TextVar it) '''«nsSymfonyFormType»Text«IF multiline»area«ENDIF»'''
    def private dispatch additionalOptions(TextVar it) '''
        «IF maxLength > 0 || !multiline»
            'max_length' => «IF maxLength > 0»«maxLength»«ELSEIF !multiline»255«ENDIF»
        «ENDIF»
    '''

    def private dispatch fieldType(BoolVar it) '''«nsSymfonyFormType»Checkbox'''
    def private dispatch titleAttribute(BoolVar it) '''The «name.formatForDisplay» option.'''
    def private dispatch additionalOptions(BoolVar it) ''''''

    def private dispatch fieldType(ListVar it) '''«nsSymfonyFormType»Choice'''
    def private dispatch titleAttribute(ListVar it) '''Choose the «name.formatForDisplay».'''
    def private dispatch additionalOptions(ListVar it) '''
        'choices' => [
            «FOR item : items»«item.itemDefinition»«IF item != items.last»,«ENDIF»«ENDFOR»
        ],
        'choices_as_values' => true,
        'multiple' => «multiple.displayBool»
    '''

    def private itemDefinition(ListVarItem it) '''
        $this->translator->trans('«name.formatForCode»', [], '«app.appName.formatForDB»') => '«name.formatForDisplayCapital»'
    '''

    def private configTypeImpl(Application it) '''
        namespace «appNamespace»\Form;

        use «appNamespace»\Form\Base\AppSettingsType as BaseAppSettingsType;

        /**
         * Configuration form type implementation class.
         */
        class AppSettingsType extends BaseAppSettingsType
        {
            // feel free to extend the base form type class here
        }
    '''
}
