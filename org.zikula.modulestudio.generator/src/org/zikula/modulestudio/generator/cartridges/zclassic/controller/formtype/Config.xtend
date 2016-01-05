package org.zikula.modulestudio.generator.cartridges.zclassic.controller.formtype

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.BoolVar
import de.guite.modulestudio.metamodel.IntVar
import de.guite.modulestudio.metamodel.ListVar
import de.guite.modulestudio.metamodel.ListVarItem
import de.guite.modulestudio.metamodel.TextVar
import de.guite.modulestudio.metamodel.Variable
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
        use Symfony\Component\Form\AbstractType as SymfonyAbstractType;
        use Symfony\Component\Form\FormBuilderInterface;
        use Symfony\Component\Translation\TranslatorInterface;
        use Zikula\ExtensionsModule\Api\VariableApi;

        /**
         * Configuration form type base class.
         */
        class AppSettingsType extends SymfonyAbstractType
        {
            /**
             * @var TranslatorInterface
             */
            private $translator;

            /**
             * @var VariableApi
             */
            private $variableApi;

            public function __construct(TranslatorInterface $translator, VariableApi $variableApi)
            {
                $this->translator = $translator;
                $this->variableApi = $variableApi;
            }

            /**
             * {@inheritdoc}
             */
            public function buildForm(FormBuilderInterface $builder, array $options)
            {
                $modVars = $this->variableApi->getAll('«appName»');

                $builder
                    «FOR modvar : getAllVariables»«modvar.definition»«ENDFOR»
                    ->add('save', 'submit', [
                        'label' => $this->translator->trans('Update configuration', [], '«appName.formatForDB»')
                    ])
                    ->add('cancel', 'submit', [
                        'label' => $this->translator->trans('Cancel', [], '«appName.formatForDB»')
                    ])
                ;
            }

            /**
             * {@inheritdoc}
             */
            public function getBlockPrefix()
            {
                return '«appName.formatForDB»_appsettingstype';
            }
        }
    '''

    def private definition(Variable it) '''
        ->add('«name.formatForCode»', '«nsSymfonyFormType»«fieldType»Type', [
            'label' => $this->translator->trans('«name.formatForDisplayCapital»', [], '«app.appName.formatForDB»'),
            «IF documentation !== null && documentation != ''»
                'label_attr' => [
                    'class' => '«app.appName.toLowerCase»-form-tooltips',
                    'title' => $this->translator->trans('«documentation.replace("'", '"')»', [], '«app.appName.formatForDB»')
                ],
            «ENDIF»
            'required' => false,
            'data' => $modVars['«name.formatForCode»'],
            'empty_data' => null,
            'attr' => [
                'title' => $this->translator->trans('«titleAttribute»', [], '«app.appName.formatForDB»')«IF documentation !== null && documentation != ''»,
                'help' => $this->translator->trans('«documentation.replace("'", '"')»', [], '«app.appName.formatForDB»')
            «ENDIF»
            ]«additionalOptions»
        ]
    '''

    def private dispatch fieldType(Variable it) '''Text'''
    def private dispatch titleAttribute(Variable it) '''Enter the «name.formatForDisplay».'''
    def private dispatch additionalOptions(Variable it) ''',
        'max_length' => 255
    '''

    def private dispatch fieldType(IntVar it) '''«IF hasUserGroupSelectors && isUserGroupSelector»Entity«ELSE»Integer«ENDIF»'''
    def private dispatch titleAttribute(IntVar it) '''«IF hasUserGroupSelectors && isUserGroupSelector»Choose the «name.formatForDisplay».«ELSE»Enter the «name.formatForDisplay». Only digits are allowed.«ENDIF»'''
    def private dispatch additionalOptions(IntVar it) ''',
        'max_length' => 255,
        «IF hasUserGroupSelectors && isUserGroupSelector»
            'class' => 'Zikula\GroupsModule\Entity\GroupsEntity',
            'choice_label' => 'name'
        «ELSE»
            'scale' => 0
        «ENDIF»
    '''

    def private dispatch additionalOptions(TextVar it) ''',
        'max_length' => «IF maxLength > 0»«maxLength»«ELSE»255«ENDIF»
    '''

    def private dispatch fieldType(BoolVar it) '''Checkbox'''
    def private dispatch titleAttribute(BoolVar it) '''The «name.formatForDisplay» option.'''
    def private dispatch additionalOptions(BoolVar it) ''''''

    def private dispatch fieldType(ListVar it) '''Choice'''
    def private dispatch titleAttribute(ListVar it) '''Choose the «name.formatForDisplay».'''
    def private dispatch additionalOptions(ListVar it) ''',
        'choices' => [
            «FOR item : items»«item.itemDefinition»«IF item != items.last»,«ENDIF»«ENDFOR»
        ],
        'choices_as_values' => true,
        'multiple' => «multiple.displayBool»
    '''

    def private itemDefinition(ListVarItem it) '''
        '«name.formatForDisplayCapital»' => $this->translator->trans('«name.formatForCode»', [], '«app.appName.formatForDB»')
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
