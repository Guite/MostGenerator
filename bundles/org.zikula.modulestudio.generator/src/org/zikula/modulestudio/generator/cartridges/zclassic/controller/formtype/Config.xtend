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
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Config {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    FileHelper fh = new FileHelper
    String nsSymfonyFormType = 'Symfony\\Component\\Form\\Extension\\Core\\Type\\'

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

        use Symfony\Component\Form\AbstractType;
        «IF targets('1.5')»
            «IF hasUserGroupSelectors»
                use Symfony\Bridge\Doctrine\Form\Type\EntityType;
            «ENDIF»
            «IF !getAllVariables.filter(BoolVar).empty»
                use «nsSymfonyFormType»CheckboxType;
            «ENDIF»
            «IF !getAllVariables.filter(ListVar).empty»
                use «nsSymfonyFormType»ChoiceType;
            «ENDIF»
            «IF !getAllVariables.filter(IntVar).filter[!isUserGroupSelector].empty»
                use «nsSymfonyFormType»IntegerType;
            «ENDIF»
            «IF !getAllVariables.filter(TextVar).filter[multiline].empty»
                use «nsSymfonyFormType»TextareaType;
            «ENDIF»
            «IF !getAllVariables.filter(TextVar).filter[!multiline].empty»
                use «nsSymfonyFormType»TextType;
            «ENDIF»
            use «nsSymfonyFormType»SubmitType;
        «ENDIF»
        use Symfony\Component\Form\FormBuilderInterface;
        use Zikula\Common\Translator\TranslatorInterface;
        use Zikula\Common\Translator\TranslatorTrait;
        «IF hasUserGroupSelectors»
            «IF targets('1.5')»
                use Zikula\GroupsModule\Constant as GroupsConstant;
            «ENDIF»
            use Zikula\GroupsModule\Entity\RepositoryInterface\GroupRepositoryInterface;
        «ENDIF»

        /**
         * Configuration form type base class.
         */
        abstract class AbstractConfigType extends AbstractType
        {
            use TranslatorTrait;

            /**
             * @var array
             */
            protected $moduleVars;

            /**
             * ConfigType constructor.
             *
             «IF hasUserGroupSelectors»
             * @param TranslatorInterface      $translator      Translator service instance
             * @param object                   $moduleVars      Existing module vars
             * @param GroupRepositoryInterface $groupRepository GroupRepository service instance
             «ELSE»
             * @param TranslatorInterface $translator  Translator service instance
             * @param object              $moduleVars  Existing module vars
             «ENDIF»
             */
            public function __construct(
                TranslatorInterface $translator,
                $moduleVars«IF hasUserGroupSelectors»,
                GroupRepositoryInterface $groupRepository«ENDIF»
            ) {
                $this->setTranslator($translator);
                $this->moduleVars = $moduleVars;
                «IF hasUserGroupSelectors»

                    // prepare group selector values
                    foreach (['«getUserGroupSelectors.map[name.formatForCode].join('\', \'')»'] as $groupFieldName) {
                        $groupId = intval($this->moduleVars[$groupFieldName]);
                        if ($groupId < 1) {
                            // fallback to admin group
                            $groupId = «IF targets('1.5')»GroupsConstant::GROUP_ID_ADMIN«ELSE»2«ENDIF»;
                        }
                        $this->moduleVars[$groupFieldName] = $groupRepository->find($groupId);
                    }
                «ENDIF»
                «IF !variables.filter[composite].empty»

                    // prepare composite variables
                    «FOR varContainer : variables.filter[composite]»
                        $«varContainer.name.formatForCode» = $this->moduleVars['«varContainer.name.formatForCode»'];
                        «FOR modvar : varContainer.vars»
                            $this->moduleVars['«modvar.name.formatForCode»' = $«varContainer.name.formatForCode»['«modvar.name.formatForCode»'];
                        «ENDFOR»
                        unset($this->moduleVars['«varContainer.name.formatForCode»']);
                    «ENDFOR»
                «ENDIF»
            }

            «setTranslatorMethod»

            /**
             * @inheritDoc
             */
            public function buildForm(FormBuilderInterface $builder, array $options)
            {
                «FOR varContainer : variables»
                    $this->add«varContainer.name.formatForCodeCapital»Fields($builder, $options);
                «ENDFOR»

                $builder
                    ->add('save', «IF targets('1.5')»SubmitType::class«ELSE»'«nsSymfonyFormType»SubmitType'«ENDIF», [
                        'label' => $this->__('Update configuration'),
                        'icon' => 'fa-check',
                        'attr' => [
                            'class' => 'btn btn-success'
                        ]
                    ])
                    ->add('cancel', «IF targets('1.5')»SubmitType::class«ELSE»'«nsSymfonyFormType»SubmitType'«ENDIF», [
                        'label' => $this->__('Cancel'),
                        'icon' => 'fa-times',
                        'attr' => [
                            'class' => 'btn btn-default',
                            'formnovalidate' => 'formnovalidate'
                        ]
                    ])
                ;
            }

            «FOR varContainer : variables»
                «varContainer.addFieldsMethod»

            «ENDFOR»
            /**
             * @inheritDoc
             */
            public function getBlockPrefix()
            {
                return '«appName.formatForDB»_config';
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
        public function add«name.formatForCodeCapital»Fields(FormBuilderInterface $builder, array $options)
        {
            $builder
                «FOR modvar : vars»«modvar.definition»«ENDFOR»
            ;
        }
    '''

    def private definition(Variable it) '''
        ->add('«name.formatForCode»', «IF container.application.targets('1.5')»«fieldType»Type::class«ELSE»'«fieldType»Type'«ENDIF», [
            'label' => $this->__('«labelText»') . ':',
            «IF null !== documentation && documentation != ''»
                'label_attr' => [
                    'class' => 'tooltips',
                    'title' => $this->__('«documentation.replace("'", '"')»')
                ],
                'help' => $this->__('«documentation.replace("'", '"')»'),
            «ENDIF»
            «IF !(it instanceof IntVar && (it as IntVar).isUserGroupSelector)»
                'required' => false,
            «ENDIF»
            «IF it instanceof IntVar && !(it as IntVar).isUserGroupSelector»
                'data' => isset($this->moduleVars['«name.formatForCode»']) ? intval($this->moduleVars['«name.formatForCode»']) : intval(«value»),
            «ELSE»
                'data' => «IF it instanceof BoolVar»(bool)(«ENDIF»isset($this->moduleVars['«name.formatForCode»']) ? $this->moduleVars['«name.formatForCode»'] : «IF it instanceof BoolVar»«(value == 'true').displayBool»)«ELSE»''«ENDIF»,
            «ENDIF»
            «IF !(it instanceof BoolVar)»
                «IF !(it instanceof IntVar && (it as IntVar).isUserGroupSelector)»
                    'empty_data' => «IF it instanceof IntVar»intval('«value»')«ELSE»'«value»'«ENDIF»,
                «ENDIF»
            «ENDIF»
            'attr' => [
                «additionalAttributes»
                'title' => $this->__('«titleAttribute»')«IF isShrinkDimensionField»,
                'class' => 'shrinkdimension-«name.formatForCode.toLowerCase»'«ELSEIF isShrinkEnableField»,
                'class' => 'shrink-enabler'«ENDIF»
            ],«additionalOptions»
        ])
    '''

    def private labelText(Variable it) {
        if (isShrinkEnableField) {
            return 'Enable shrinking'
        }
        if (isShrinkDimensionField) {
            if (name.startsWith('shrinkWidth')) {
                return 'Shrink width'
            }
            if (name.startsWith('shrinkHeight')) {
                return 'Shrink height'
            }
        }
        if (isThumbModeField) {
            return 'Thumbnail mode'
        }
        if (isThumbDimensionField) {
            var suffix = ''
            if (name.endsWith('View')) {
                suffix = ' view'
            } else if (name.endsWith('Display')) {
                suffix = ' display'
            } else if (name.endsWith('Edit')) {
                suffix = ' edit'
            }
            if (name.startsWith('thumbnailWidth')) {
                return 'Thumbnail width' + suffix
            }
            if (name.startsWith('thumbnailHeight')) {
                return 'Thumbnail height' + suffix
            }
        }
        name.formatForDisplayCapital
    }

    def private dispatch fieldType(Variable it) '''«IF !container.application.targets('1.5')»«nsSymfonyFormType»«ENDIF»Text'''
    def private dispatch titleAttribute(Variable it) '''Enter the «name.formatForDisplay».'''
    def private dispatch additionalAttributes(Variable it) '''
        'maxlength' => 255,
    '''
    def private dispatch additionalOptions(Variable it) ''''''

    def private dispatch fieldType(IntVar it) '''«IF isUserGroupSelector»«IF !container.application.targets('1.5')»Symfony\Bridge\Doctrine\Form\Type\«ENDIF»Entity«ELSE»«IF !container.application.targets('1.5')»«nsSymfonyFormType»«ENDIF»Integer«ENDIF»'''
    def private dispatch titleAttribute(IntVar it) '''«IF isUserGroupSelector»Choose the «name.formatForDisplay».«ELSE»«IF isShrinkDimensionField || isThumbDimensionField»Enter the «labelText.toLowerCase».«ELSE»Enter the «name.formatForDisplay».«ENDIF»') . ' ' . $this->__('Only digits are allowed.«ENDIF»'''
    def private dispatch additionalAttributes(IntVar it) '''
        «IF isUserGroupSelector»
            'maxlength' => 255,
        «ELSE»
            'maxlength' => «IF isShrinkDimensionField || isThumbDimensionField»4«ELSE»255«ENDIF»,
        «ENDIF»
    '''
    def private dispatch additionalOptions(IntVar it) '''
        «IF isUserGroupSelector»
            // Zikula core should provide a form type for this to hide entity details
            'class' => 'ZikulaGroupsModule:GroupEntity',
            'choice_label' => 'name',
            'choice_value' => 'gid'
        «ELSE»
            'scale' => 0«IF isShrinkDimensionField || isThumbDimensionField»,
            'input_group' => ['right' => $this->__('pixels')]«ENDIF»
        «ENDIF»
    '''

    def private isShrinkEnableField(Variable it) {
        it instanceof BoolVar && name.startsWith('enableShrinkingFor')
    }

    def private isShrinkDimensionField(Variable it) {
        name.startsWith('shrinkWidth') || name.startsWith('shrinkHeight')
    }

    def private isThumbModeField(Variable it) {
        name.startsWith('thumbnailMode')
    }

    def private isThumbDimensionField(Variable it) {
        name.startsWith('thumbnailWidth') || name.startsWith('thumbnailHeight')
    }

    def private dispatch fieldType(TextVar it) '''«IF !container.application.targets('1.5')»«nsSymfonyFormType»«ENDIF»Text«IF multiline»area«ENDIF»'''
    def private dispatch additionalAttributes(TextVar it) '''
        «IF maxLength > 0 || !multiline»
            'maxlength' => «IF maxLength > 0»«maxLength»«ELSEIF !multiline»255«ENDIF»,
        «ENDIF»
    '''

    def private dispatch fieldType(BoolVar it) '''«IF !container.application.targets('1.5')»«nsSymfonyFormType»«ENDIF»Checkbox'''
    def private dispatch titleAttribute(BoolVar it) '''The «IF isShrinkEnableField»enable shrinking«ELSE»«name.formatForDisplay»«ENDIF» option.'''
    def private dispatch additionalAttributes(BoolVar it) ''''''

    def private dispatch fieldType(ListVar it) '''«IF !container.application.targets('1.5')»«nsSymfonyFormType»«ENDIF»Choice'''
    def private dispatch titleAttribute(ListVar it) '''Choose the «IF isThumbModeField»thumbnail mode«ELSE»«name.formatForDisplay»«ENDIF».'''
    def private dispatch additionalAttributes(ListVar it) ''''''
    def private dispatch additionalOptions(ListVar it) '''
        'choices' => [
            «FOR item : items»«item.itemDefinition»«IF item != items.last»,«ENDIF»«ENDFOR»
        ],
        'choices_as_values' => true,
        'multiple' => «multiple.displayBool»
    '''

    def private itemDefinition(ListVarItem it) '''
        $this->__('«name.formatForDisplayCapital»') => '«name.formatForCode»'
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
