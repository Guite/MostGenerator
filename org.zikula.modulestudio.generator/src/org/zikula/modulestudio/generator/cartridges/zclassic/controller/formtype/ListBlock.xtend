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

        /**
         * List block form type base class.
         */
        class ItemListBlockType extends AbstractType
        {
            /**
             * @var TranslatorInterface
             */
            protected $translator;

            /**
             * ItemListBlockType constructor.
             *
             * @param TranslatorInterface $translator Translator service instance.
             */
            public function __construct(TranslatorInterface $translator)
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
                'label' => $this->translator->trans('Object type', [], '«app.appName.formatForDB»') . ':',
                'empty_data' => '«app.leadingEntity.name.formatForCode»',
                'attr' => [
                    'title' => $this->translator->trans('If you change this please save the block once to reload the parameters below.', [], '«app.appName.formatForDB»')
                ],
                'choices' => [
                    «FOR entity : getAllEntities»
                        $this->translator->trans('«entity.nameMultiple.formatForDisplayCapital»', [], '«app.appName.formatForDB»') => '«entity.name.formatForCode»'«IF entity != getAllEntities.last»,«ENDIF»
                    «ENDFOR»
                ],
                'choices_as_values' => true,
                'help' => $this->translator->trans('If you change this please save the block once to reload the parameters below.', [], '«app.appName.formatForDB»')
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
                'label' => ($hasMultiSelection ? $this->translator->trans('Categories', [], '«app.appName.formatForDB»') : $this->translator->trans('Category', [], '«app.appName.formatForDB»')) . ':',
                'empty_data' => [],
                'attr' => [
                    'class' => 'category-selector',
                    'title' => $this->translator->trans('This is an optional filter.', [], '«app.appName.formatForDB»')
                ],
                'required' => false,
                'multiple' => $hasMultiSelection,
                'module' => '«appName»',
                'entity' => ucfirst($options['objectType']) . 'Entity',
                'entityCategoryClass' => '«app.appNamespace»\Entity\' . ucfirst($options['objectType']) . 'CategoryEntity',
                'help' => $this->translator->trans('This is an optional filter.', [], '«app.appName.formatForDB»')
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
                'label' => $this->translator->trans('Sorting', [], '«app.appName.formatForDB»') . ':',
                'empty_data' => 'default',
                'choices' => [
                    $this->translator->trans('Random', [], '«app.appName.formatForDB»') => 'random',
                    $this->translator->trans('Newest', [], '«app.appName.formatForDB»') => 'newest',
                    $this->translator->trans('Default', [], '«app.appName.formatForDB»') => 'default'
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
                'label' => $this->translator->trans('Amount', [], '«app.appName.formatForDB»') . ':',
                'attr' => [
                    'title' => $this->translator->trans('The maximum amount of items to be shown. Only digits are allowed.', [], '«app.appName.formatForDB»')
                ],
                'empty_data' => 5,
                'max_length' => 2,
                'scale' => 0,
                'help' => $this->translator->trans('The maximum amount of items to be shown. Only digits are allowed.', [], '«app.appName.formatForDB»')
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
                    'label' => $this->translator->trans('Template', [], '«app.appName.formatForDB»') . ':',
                    'empty_data' => 'itemlist_display.html.twig',
                    'choices' => [
                        $this->translator->trans('Only item titles', [], '«app.appName.formatForDB»') => 'itemlist_display.html.twig',
                        $this->translator->trans('With description', [], '«app.appName.formatForDB»') => 'itemlist_display_description.html.twig',
                        $this->translator->trans('Custom template', [], '«app.appName.formatForDB»') => 'custom'
                    ],
                    'choices_as_values' => true
                ])
                ->add('customTemplate', '«nsSymfonyFormType»TextType', [
                    'label' => $this->translator->trans('Custom template', [], '«app.appName.formatForDB»') . ':',
                    'required' => false,
                    'attr' => [
                        'title' => $this->translator->trans('Example', [], '«app.appName.formatForDB»') . ': <em>itemlist_[objectType]_display.html.twig</em>'
                    ],
                    'max_length' => 80,
                    'help' => $this->translator->trans('Example', [], '«app.appName.formatForDB»') . ': <em>itemlist_[objectType]_display.html.twig</em>'
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
                'label' => $this->translator->trans('Filter (expert option)', [], '«app.appName.formatForDB»') . ':',
                'required' => false,
                'max_length' => 255,
                'help' => '<a class="fa fa-filter" data-toggle="modal" data-target="#filterSyntaxModal">' . $this->translator->trans('Show syntax examples', [], '«app.appName.formatForDB»') . '</a>'
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
