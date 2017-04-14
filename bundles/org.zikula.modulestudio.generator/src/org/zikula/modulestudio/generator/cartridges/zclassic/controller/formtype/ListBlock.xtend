package org.zikula.modulestudio.generator.cartridges.zclassic.controller.formtype

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.GeneratorSettingsExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ListBlock {
    extension FormattingExtensions = new FormattingExtensions
    extension GeneratorSettingsExtensions = new GeneratorSettingsExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelExtensions = new ModelExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    FileHelper fh = new FileHelper
    Application app
    String nsSymfonyFormType = 'Symfony\\Component\\Form\\Extension\\Core\\Type\\'

    /**
     * Entry point for list block form type.
     */
    def generate(Application it, IFileSystemAccess fsa) {
        if (!generateListBlock) {
            return
        }
        app = it
        generateClassPair(fsa, getAppSourceLibPath + 'Block/Form/Type/ItemListBlockType.php',
            fh.phpFileContent(it, listBlockTypeBaseImpl), fh.phpFileContent(it, listBlockTypeImpl)
        )
    }

    def private listBlockTypeBaseImpl(Application it) '''
        namespace «appNamespace»\Block\Form\Type\Base;

        use Symfony\Component\Form\AbstractType;
        «IF targets('1.5')»
            use «nsSymfonyFormType»ChoiceType;
            «IF getAllEntities.size == 1»
                use «nsSymfonyFormType»HiddenType;
            «ENDIF»
            use «nsSymfonyFormType»IntegerType;
            use «nsSymfonyFormType»TextType;
        «ENDIF»
        use Symfony\Component\Form\FormBuilderInterface;
        «IF hasCategorisableEntities»
            use Symfony\Component\Form\FormInterface;
            use Symfony\Component\Form\FormView;
        «ENDIF»
        use Symfony\Component\OptionsResolver\OptionsResolver;
        «IF targets('1.5') && hasCategorisableEntities»
            use Zikula\CategoriesModule\Form\Type\CategoriesType;
        «ENDIF»
        use Zikula\Common\Translator\TranslatorInterface;
        use Zikula\Common\Translator\TranslatorTrait;
        «IF hasCategorisableEntities»
            use «appNamespace»\Helper\FeatureActivationHelper;
        «ENDIF»

        /**
         * List block form type base class.
         */
        abstract class AbstractItemListBlockType extends AbstractType
        {
            use TranslatorTrait;

            /**
             * ItemListBlockType constructor.
             *
             * @param TranslatorInterface $translator Translator service instance
             */
            public function __construct(TranslatorInterface $translator)
            {
                $this->setTranslator($translator);
            }

            «setTranslatorMethod»

            /**
             * @inheritDoc
             */
            public function buildForm(FormBuilderInterface $builder, array $options)
            {
                $this->addObjectTypeField($builder, $options);
                «IF hasCategorisableEntities»
                    if ($options['feature_activation_helper']->isEnabled(FeatureActivationHelper::CATEGORIES, $options['object_type'])) {
                        $this->addCategoriesField($builder, $options);
                    }
                «ENDIF»
                $this->addSortingField($builder, $options);
                $this->addAmountField($builder, $options);
                $this->addTemplateFields($builder, $options);
                $this->addFilterField($builder, $options);
            }
            «IF hasCategorisableEntities»

                /**
                 * @inheritDoc
                 */
                public function buildView(FormView $view, FormInterface $form, array $options)
                {
                    $view->vars['isCategorisable'] = $options['is_categorisable'];
                }
            «ENDIF»

            «addObjectTypeField»

            «IF hasCategorisableEntities»
                «addCategoriesField»

            «ENDIF»
            «addSortingField»

            «addAmountField»

            «addTemplateFields»

            «addFilterField»

            /**
             * @inheritDoc
             */
            public function getBlockPrefix()
            {
                return '«appName.formatForDB»_listblock';
            }

            /**
             * @inheritDoc
             */
            public function configureOptions(OptionsResolver $resolver)
            {
                $resolver
                    ->setDefaults([
                        'object_type' => '«leadingEntity.name.formatForCode»'«IF hasCategorisableEntities»,
                        'is_categorisable' => false,
                        'category_helper' => null,
                        'feature_activation_helper' => null«ENDIF»
                    ])
                    ->setRequired(['object_type'])
                    «IF hasCategorisableEntities»
                        ->setOptional(['is_categorisable', 'category_helper', 'feature_activation_helper'])
                    «ENDIF»
                    ->setAllowedTypes([
                        'objectType' => 'string'«IF hasCategorisableEntities»,
                        'is_categorisable' => 'bool',
                        'category_helper' => 'object',
                        'feature_activation_helper' => 'object'«ENDIF»
                    ])
                ;
            }
        }
    '''

    def private addObjectTypeField(Application it) '''
        /**
         * Adds an object type field.
         *
         * @param FormBuilderInterface $builder The form builder
         * @param array                $options The options
         */
        public function addObjectTypeField(FormBuilderInterface $builder, array $options)
        {
            $builder->add('objectType', «IF targets('1.5')»«IF getAllEntities.size == 1»Hidden«ELSE»Choice«ENDIF»Type::class«ELSE»'«nsSymfonyFormType»«IF getAllEntities.size == 1»Hidden«ELSE»Choice«ENDIF»Type'«ENDIF», [
                'label' => $this->__('Object type') . ':',
                'empty_data' => '«app.leadingEntity.name.formatForCode»',
                'attr' => [
                    'title' => $this->__('If you change this please save the block once to reload the parameters below.')
                ],
                'help' => $this->__('If you change this please save the block once to reload the parameters below.'),
                'choices' => [
                    «FOR entity : getAllEntities»
                        $this->__('«entity.nameMultiple.formatForDisplayCapital»') => '«entity.name.formatForCode»'«IF entity != getAllEntities.last»,«ENDIF»
                    «ENDFOR»
                ],
                'choices_as_values' => true,
                'multiple' => false,
                'expanded' => false
            ]);
        }
    '''

    def private addCategoriesField(Application it) '''
        /**
         * Adds a categories field.
         *
         * @param FormBuilderInterface $builder The form builder
         * @param array                $options The options
         */
        public function addCategoriesField(FormBuilderInterface $builder, array $options)
        {
            if (!$options['is_categorisable'] || null === $options['category_helper']) {
                return;
            }

            $hasMultiSelection = $options['category_helper']->hasMultipleSelection($options['object_type']);
            $builder->add('categories', «IF targets('1.5')»CategoriesType::class«ELSE»'Zikula\CategoriesModule\Form\Type\CategoriesType'«ENDIF», [
                'label' => ($hasMultiSelection ? $this->__('Categories') : $this->__('Category')) . ':',
                'empty_data' => $hasMultiSelection ? [] : null,
                'attr' => [
                    'class' => 'category-selector',
                    'title' => $this->__('This is an optional filter.')
                ],
                'help' => $this->__('This is an optional filter.'),
                'required' => false,
                'multiple' => $hasMultiSelection,
                'module' => '«appName»',
                'entity' => ucfirst($options['object_type']) . 'Entity',
                'entityCategoryClass' => '«app.appNamespace»\Entity\\' . ucfirst($options['object_type']) . 'CategoryEntity'
            ]);
        }
    '''

    def private addSortingField(Application it) '''
        /**
         * Adds a sorting field.
         *
         * @param FormBuilderInterface $builder The form builder
         * @param array                $options The options
         */
        public function addSortingField(FormBuilderInterface $builder, array $options)
        {
            $builder->add('sorting', «IF targets('1.5')»ChoiceType::class«ELSE»'«nsSymfonyFormType»ChoiceType'«ENDIF», [
                'label' => $this->__('Sorting') . ':',
                'empty_data' => 'default',
                'choices' => [
                    $this->__('Random') => 'random',
                    $this->__('Newest') => 'newest',
                    $this->__('Default') => 'default'
                ],
                'choices_as_values' => true,
                'multiple' => false,
                'expanded' => false
            ]);
        }
    '''

    def private addAmountField(Application it) '''
        /**
         * Adds a page size field.
         *
         * @param FormBuilderInterface $builder The form builder
         * @param array                $options The options
         */
        public function addAmountField(FormBuilderInterface $builder, array $options)
        {
            $builder->add('amount', «IF targets('1.5')»IntegerType::class«ELSE»'«nsSymfonyFormType»IntegerType'«ENDIF», [
                'label' => $this->__('Amount') . ':',
                'attr' => [
                    'maxlength' => 2,
                    'title' => $this->__('The maximum amount of items to be shown.') . ' ' . $this->__('Only digits are allowed.')
                ],
                'help' => $this->__('The maximum amount of items to be shown.') . ' ' . $this->__('Only digits are allowed.'),
                'empty_data' => 5,
                'scale' => 0
            ]);
        }
    '''

    def private addTemplateFields(Application it) '''
        /**
         * Adds template fields.
         *
         * @param FormBuilderInterface $builder The form builder
         * @param array                $options The options
         */
        public function addTemplateFields(FormBuilderInterface $builder, array $options)
        {
            $builder
                ->add('template', «IF targets('1.5')»ChoiceType::class«ELSE»'«nsSymfonyFormType»ChoiceType'«ENDIF», [
                    'label' => $this->__('Template') . ':',
                    'empty_data' => 'itemlist_display.html.twig',
                    'choices' => [
                        $this->__('Only item titles') => 'itemlist_display.html.twig',
                        $this->__('With description') => 'itemlist_display_description.html.twig',
                        $this->__('Custom template') => 'custom'
                    ],
                    'choices_as_values' => true,
                    'multiple' => false,
                    'expanded' => false
                ])
                ->add('customTemplate', «IF targets('1.5')»TextType::class«ELSE»'«nsSymfonyFormType»TextType'«ENDIF», [
                    'label' => $this->__('Custom template') . ':',
                    'required' => false,
                    'attr' => [
                        'maxlength' => 80,
                        'title' => $this->__('Example') . ': itemlist_[objectType]_display.html.twig'
                    ],
                    'help' => $this->__('Example') . ': <em>itemlist_[objectType]_display.html.twig</em>'
                ])
            ;
        }
    '''

    def private addFilterField(Application it) '''
        /**
         * Adds a filter field.
         *
         * @param FormBuilderInterface $builder The form builder
         * @param array                $options The options
         */
        public function addFilterField(FormBuilderInterface $builder, array $options)
        {
            $builder->add('filter', «IF targets('1.5')»TextType::class«ELSE»'«nsSymfonyFormType»TextType'«ENDIF», [
                'label' => $this->__('Filter (expert option)') . ':',
                'required' => false,
                'attr' => [
                    'maxlength' => 255
                ]
            ]);
        }
    '''

    def private listBlockTypeImpl(Application it) '''
        namespace «appNamespace»\Block\Form\Type;

        use «appNamespace»\Block\Form\Type\Base\AbstractItemListBlockType;

        /**
         * List block form type implementation class.
         */
        class ItemListBlockType extends AbstractItemListBlockType
        {
            // feel free to extend the list block form type class here
        }
    '''
}
