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
     * 1.4.x only.
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
        use Symfony\Component\Form\FormBuilderInterface;
        use Symfony\Component\OptionsResolver\OptionsResolver;
        use Symfony\Component\Translation\TranslatorInterface;
        use Zikula\Common\Translator\TranslatorTrait;

        /**
         * List block form type base class.
         */
        class ItemListBlockType extends AbstractType
        {
            use TranslatorTrait;

            /**
             * ItemListBlockType constructor.
             *
             * @param TranslatorInterface $translator Translator service instance.
             */
            public function __construct(TranslatorInterface $translator)
            {
                $this->setTranslator($translator);
            }

            /**
             * Sets the translator.
             *
             * @param TranslatorInterface $translator Translator service instance.
             */
            public function setTranslator(TranslatorInterface $translator)
            {
                $this->translator = $translator;
            }

            /**
             * {@inheritdoc}
             */
            public function buildForm(FormBuilderInterface $builder, array $options)
            {
                $this->addObjectTypeField($builder, $options);
                «IF hasCategorisableEntities»
                    $this->addCategoriesField($builder, $options);
                «ENDIF»
                $this->addSortingField($builder, $options);
                $this->addAmountField($builder, $options);
                $this->addTemplateFields($builder, $options);
                $this->addFilterField($builder, $options);
            }

            «addObjectTypeField»

            «IF hasCategorisableEntities»
                «addCategoriesField»

            «ENDIF»
            «addSortingField»

            «addAmountField»

            «addTemplateFields»

            «addFilterField»

            /**
             * {@inheritdoc}
             */
            public function getBlockPrefix()
            {
                return '«appName.formatForDB»_listblock';
            }

            /**
             * {@inheritdoc}
             */
            public function configureOptions(OptionsResolver $resolver)
            {
                parent::configureOptions($resolver);

                $resolver
                    ->setDefaults([
                        'objectType' => '«leadingEntity.name.formatForCode»',
                        'isCategorisable' => false
                    ])
                    ->setRequired(['objectType'])
                    ->setOptional(['isCategorisable'])
                    ->setAllowedTypes([
                        'objectType' => 'string',
                        'isCategorisable' => 'bool'
                    ])
                ;
            }
        }
    '''

    def private addObjectTypeField(Application it) '''
        /**
         * Adds an object type field.
         *
         * @param FormBuilderInterface The form builder.
         * @param array                The options.
         */
        public function addObjectTypeField(FormBuilderInterface $builder, array $options)
        {
            $builder->add('objectType', '«nsSymfonyFormType»ChoiceType', [
                'label' => $this->__('Object type') . ':',
                'empty_data' => '«app.leadingEntity.name.formatForCode»',
                'attr' => [
                    'title' => $this->__('If you change this please save the block once to reload the parameters below.')
                ],
                'choices' => [
                    «FOR entity : getAllEntities»
                        $this->__('«entity.nameMultiple.formatForDisplayCapital»') => '«entity.name.formatForCode»'«IF entity != getAllEntities.last»,«ENDIF»
                    «ENDFOR»
                ],
                'choices_as_values' => true,
                'help' => $this->__('If you change this please save the block once to reload the parameters below.')
            ]);
        }
    '''

    def private addCategoriesField(Application it) '''
        /**
         * Adds a categories field.
         *
         * @param FormBuilderInterface The form builder.
         * @param array                The options.
         */
        public function addCategoriesField(FormBuilderInterface $builder, array $options)
        {
            if (!$options['isCategorisable']) {
                return;
            }

            $hasMultiSelection = \ModUtil::apiFunc('«appName», 'category', 'hasMultipleSelection', ['ot' => $options['objectType']]);
            $builder->add('categories', 'Zikula\CategoriesModule\Form\Type\CategoriesType', [
                'label' => ($hasMultiSelection ? $this->__('Categories') : $this->__('Category')) . ':',
                'empty_data' => [],
                'attr' => [
                    'class' => 'category-selector',
                    'title' => $this->__('This is an optional filter.')
                ],
                'required' => false,
                'multiple' => $hasMultiSelection,
                'module' => '«appName»',
                'entity' => ucfirst($options['objectType']) . 'Entity',
                'entityCategoryClass' => '«app.appNamespace»\Entity\' . ucfirst($options['objectType']) . 'CategoryEntity',
                'help' => $this->__('This is an optional filter.')
            ]);
        }
    '''

    def private addSortingField(Application it) '''
        /**
         * Adds a sorting field.
         *
         * @param FormBuilderInterface The form builder.
         * @param array                The options.
         */
        public function addSortingField(FormBuilderInterface $builder, array $options)
        {
            $builder->add('sorting', '«nsSymfonyFormType»ChoiceType', [
                'label' => $this->__('Sorting') . ':',
                'empty_data' => 'default',
                'choices' => [
                    $this->__('Random') => 'random',
                    $this->__('Newest') => 'newest',
                    $this->__('Default') => 'default'
                ],
                'choices_as_values' => true
            ]);
        }
    '''

    def private addAmountField(Application it) '''
        /**
         * Adds a page size field.
         *
         * @param FormBuilderInterface The form builder.
         * @param array                The options.
         */
        public function addAmountField(FormBuilderInterface $builder, array $options)
        {
            $builder->add('amount', '«nsSymfonyFormType»IntegerType', [
                'label' => $this->__('Amount') . ':',
                'attr' => [
                    'title' => $this->__('The maximum amount of items to be shown. Only digits are allowed.')
                ],
                'empty_data' => 5,
                'max_length' => 2,
                'scale' => 0,
                'help' => $this->__('The maximum amount of items to be shown. Only digits are allowed.')
            ]);
        }
    '''

    def private addTemplateFields(Application it) '''
        /**
         * Adds template fields.
         *
         * @param FormBuilderInterface The form builder.
         * @param array                The options.
         */
        public function addTemplateFields(FormBuilderInterface $builder, array $options)
        {
            $builder
                ->add('template', '«nsSymfonyFormType»ChoiceType', [
                    'label' => $this->__('Template') . ':',
                    'empty_data' => 'itemlist_display.html.twig',
                    'choices' => [
                        $this->__('Only item titles') => 'itemlist_display.html.twig',
                        $this->__('With description') => 'itemlist_display_description.html.twig',
                        $this->__('Custom template') => 'custom'
                    ],
                    'choices_as_values' => true
                ])
                ->add('customTemplate', '«nsSymfonyFormType»TextType', [
                    'label' => $this->__('Custom template') . ':',
                    'required' => false,
                    'attr' => [
                        'title' => $this->__('Example') . ': <em>itemlist_[objectType]_display.html.twig</em>'
                    ],
                    'max_length' => 80,
                    'help' => $this->__('Example') . ': <em>itemlist_[objectType]_display.html.twig</em>'
                ])
            ;
        }
    '''

    def private addFilterField(Application it) '''
        /**
         * Adds a filter field.
         *
         * @param FormBuilderInterface The form builder.
         * @param array                The options.
         */
        public function addFilterField(FormBuilderInterface $builder, array $options)
        {
            $builder->add('filter', '«nsSymfonyFormType»TextType', [
                'label' => $this->__('Filter (expert option)') . ':',
                'required' => false,
                'max_length' => 255,
                'help' => '<a class="fa fa-filter" data-toggle="modal" data-target="#filterSyntaxModal">' . $this->__('Show syntax examples') . '</a>'
            ]);
        }
    '''

    def private listBlockTypeImpl(Application it) '''
        namespace «appNamespace»\Block\Form\Type;

        use «appNamespace»\Block\Form\Type\Base\ItemListBlockType as BaseItemListBlockType;

        /**
         * List block form type implementation class.
         */
        class ItemListBlockType extends BaseItemListBlockType
        {
            // feel free to extend the list block form type class here
        }
    '''
}
