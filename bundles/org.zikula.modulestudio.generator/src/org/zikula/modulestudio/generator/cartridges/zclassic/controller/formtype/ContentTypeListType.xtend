package org.zikula.modulestudio.generator.cartridges.zclassic.controller.formtype

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ContentTypeListType {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelExtensions = new ModelExtensions
    extension Utils = new Utils

    String nsSymfonyFormType = 'Symfony\\Component\\Form\\Extension\\Core\\Type\\'

    /**
     * Entry point for list content type form type.
     */
    def generate(Application it, IMostFileSystemAccess fsa) {
        if (!generateListContentType) {
            return
        }
        fsa.generateClassPair('ContentType/Form/Type/ItemListType.php', listContentTypeBaseImpl, listContentTypeImpl)
    }

    def private listContentTypeBaseImpl(Application it) '''
        namespace «appNamespace»\ContentType\Form\Type\Base;

        «IF hasCategorisableEntities»
            use Symfony\Component\Form\CallbackTransformer;
        «ENDIF»
        use «nsSymfonyFormType»ChoiceType;
        «IF getAllEntities.size == 1»
            use «nsSymfonyFormType»HiddenType;
        «ENDIF»
        use «nsSymfonyFormType»IntegerType;
        use «nsSymfonyFormType»TextType;
        use Symfony\Component\Form\FormBuilderInterface;
        use Symfony\Component\OptionsResolver\OptionsResolver;
        use Translation\Extractor\Annotation\Ignore;
        use Translation\Extractor\Annotation\Translate;
        «IF hasCategorisableEntities»
            use Zikula\CategoriesModule\Entity\RepositoryInterface\CategoryRepositoryInterface;
            use Zikula\CategoriesModule\Form\Type\CategoriesType;
        «ENDIF»
        use Zikula\ExtensionsModule\ModuleInterface\Content\ContentTypeInterface;
        use Zikula\ExtensionsModule\ModuleInterface\Content\Form\Type\AbstractContentFormType;
        «IF hasCategorisableEntities»
            use «appNamespace»\Helper\FeatureActivationHelper;
        «ENDIF»

        /**
         * List content type form type base class.
         */
        abstract class AbstractItemListType extends AbstractContentFormType
        {
            «IF hasCategorisableEntities»
                /**
                 * @var CategoryRepositoryInterface
                 */
                protected $categoryRepository;

                public function __construct(
                    CategoryRepositoryInterface $categoryRepository
                ) {
                    $this->categoryRepository = $categoryRepository;
                }

            «ENDIF»
            public function buildForm(FormBuilderInterface $builder, array $options)
            {
                $this->addObjectTypeField($builder, $options);
                «IF hasCategorisableEntities»
                    if (
                        $options['feature_activation_helper']->isEnabled(
                            FeatureActivationHelper::CATEGORIES,
                            $options['object_type']
                        )
                    ) {
                        $this->addCategoriesField($builder, $options);
                    }
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

            public function getBlockPrefix()
            {
                return '«appName.formatForDB»_contenttype_list';
            }

            public function configureOptions(OptionsResolver $resolver)
            {
                $resolver
                    ->setDefaults([
                        'context' => ContentTypeInterface::CONTEXT_EDIT,
                        'object_type' => '«leadingEntity.name.formatForCode»',
                        «IF hasCategorisableEntities»
                            'is_categorisable' => false,
                            'category_helper' => null,
                            'feature_activation_helper' => null,
                        «ENDIF»
                    ])
                    ->setRequired(['object_type'])
                    «IF hasCategorisableEntities»
                        ->setDefined(['is_categorisable', 'category_helper', 'feature_activation_helper'])
                    «ENDIF»
                    ->setAllowedTypes('context', 'string')
                    ->setAllowedTypes('object_type', 'string')
                    «IF hasCategorisableEntities»
                        ->setAllowedTypes('is_categorisable', 'bool')
                        ->setAllowedTypes('category_helper', 'object')
                        ->setAllowedTypes('feature_activation_helper', 'object')
                    «ENDIF»
                    ->setAllowedValues('context', [ContentTypeInterface::CONTEXT_EDIT, ContentTypeInterface::CONTEXT_TRANSLATION])
                ;
            }
        }
    '''

    def private addObjectTypeField(Application it) '''
        /**
         * Adds an object type field.
         */
        public function addObjectTypeField(FormBuilderInterface $builder, array $options = []): void
        {
            $helpText = /** @Translate */'If you change this please save the element once to reload the parameters below.';
            $builder->add('objectType', «IF getAllEntities.size == 1»Hidden«ELSE»Choice«ENDIF»Type::class, [
                'label' => 'Object type',
                'empty_data' => '«leadingEntity.name.formatForCode»'«IF getAllEntities.size > 1»,«ENDIF»
                «IF getAllEntities.size > 1»
                    'attr' => [
                        /** @Ignore */
                        'title' => $helpText,
                    ],
                    /** @Ignore */
                    'help' => $helpText,
                    'choices' => [
                        «FOR entity : getAllEntities»
                            '«entity.nameMultiple.formatForDisplayCapital»' => '«entity.name.formatForCode»',
                        «ENDFOR»
                    ],
                    'multiple' => false,
                    'expanded' => false,
                «ENDIF»
            ]);
        }
    '''

    def private addCategoriesField(Application it) '''
        /**
         * Adds a categories field.
         */
        public function addCategoriesField(FormBuilderInterface $builder, array $options = []): void
        {
            if (!$options['is_categorisable'] || null === $options['category_helper']) {
                return;
            }

            $objectType = $options['object_type'];
            $label = $hasMultiSelection
                ? /** @Translate */'Categories'
                : /** @Translate */'Category'
            ;
            $hasMultiSelection = $options['category_helper']->hasMultipleSelection($objectType);
            $entityCategoryClass = '«appNamespace»\Entity\\' . ucfirst($objectType) . 'CategoryEntity';
            $builder->add('categories', CategoriesType::class, [
                /** @Ignore */
                'label' => $label,
                'empty_data' => $hasMultiSelection ? [] : null,
                'attr' => [
                    'class' => 'category-selector',
                    'title' => 'This is an optional filter.',
                ],
                'help' => 'This is an optional filter.',
                'required' => false,
                'multiple' => $hasMultiSelection,
                'module' => '«appName»',
                'entity' => ucfirst($objectType) . 'Entity',
                'entityCategoryClass' => $entityCategoryClass,
                'showRegistryLabels' => true,
            ]);

            $categoryRepository = $this->categoryRepository;
            $builder->get('categories')->addModelTransformer(new CallbackTransformer(
                function ($catIds) use ($categoryRepository, $objectType, $hasMultiSelection) {
                    $categoryMappings = [];
                    $entityCategoryClass = '«appNamespace»\Entity\\' . ucfirst($objectType) . 'CategoryEntity';

                    $catIds = is_array($catIds) ? $catIds : explode(',', $catIds);
                    foreach ($catIds as $catId) {
                        $category = $categoryRepository->find($catId);
                        if (null === $category) {
                            continue;
                        }
                        $mapping = new $entityCategoryClass(null, $category, null);
                        $categoryMappings[] = $mapping;
                    }

                    if (!$hasMultiSelection) {
                        $categoryMappings = 0 < count($categoryMappings) ? reset($categoryMappings) : null;
                    }

                    return $categoryMappings;
                },
                function ($result) use ($hasMultiSelection) {
                    $catIds = [];

                    foreach ($result as $categoryMapping) {
                        $catIds[] = $categoryMapping->getCategory()->getId();
                    }

                    return $catIds;
                }
            ));
        }
    '''

    def private addSortingField(Application it) '''
        /**
         * Adds a sorting field.
         */
        public function addSortingField(FormBuilderInterface $builder, array $options = []): void
        {
            $builder->add('sorting', ChoiceType::class, [
                'label' => 'Sorting',
                'label_attr' => [
                    'class' => 'radio-custom',
                ],
                'empty_data' => 'default',
                'choices' => [
                    'Random' => 'random',
                    'Newest' => 'newest',
                    'Updated' => 'updated',
                    'Default' => 'default',
                ],
                'multiple' => false,
                'expanded' => true,
            ]);
        }
    '''

    def private addAmountField(Application it) '''
        /**
         * Adds a page size field.
         */
        public function addAmountField(FormBuilderInterface $builder, array $options = []): void
        {
            $helpText = /** @Translate */'The maximum amount of items to be shown.'
                . ' ' . /** @Translate */'Only digits are allowed.'
            ;
            $builder->add('amount', IntegerType::class, [
                'label' => 'Amount',
                'attr' => [
                    'maxlength' => 2,
                    /** @Ignore */
                    'title' => $helpText,
                ],
                /** @Ignore */
                'help' => $helpText,
                'empty_data' => 5,
            ]);
        }
    '''

    def private addTemplateFields(Application it) '''
        /**
         * Adds template fields.
         */
        public function addTemplateFields(FormBuilderInterface $builder, array $options = []): void
        {
            $builder->add('template', ChoiceType::class, [
                'label' => 'Template',
                'empty_data' => 'itemlist_display.html.twig',
                'choices' => [
                    'Only item titles' => 'itemlist_display.html.twig',
                    'With description' => 'itemlist_display_description.html.twig',
                    'Custom template' => 'custom',
                ],
                'multiple' => false,
                'expanded' => false,
            ]);
            $exampleTemplate = 'itemlist_[objectType]_display.html.twig';
            $builder->add('customTemplate', TextType::class, [
                'label' => 'Custom template',
                'required' => false,
                'attr' => [
                    'maxlength' => 80,
                    /** @Ignore */
                    'title' => /** @Translate */'Example' . ': ' . $exampleTemplate,
                ],
                /** @Ignore */
                'help' => /** @Translate */'Example' . ': <code>' . $exampleTemplate . '</code>',
                'help_html' => true,
            ]);
        }
    '''

    def private addFilterField(Application it) '''
        /**
         * Adds a filter field.
         */
        public function addFilterField(FormBuilderInterface $builder, array $options = []): void
        {
            $builder->add('filter', TextType::class, [
                'label' => 'Filter (expert option)',
                'required' => false,
                'attr' => [
                    'maxlength' => 255,
                    /** @Ignore */
                    'title' => /** @Translate */'Example' . ': tbl.age >= 18',
                ],
                /** @Ignore */
                'help' => /** @Translate */'Example' . ': tbl.age >= 18',
            ]);
        }
    '''

    def private listContentTypeImpl(Application it) '''
        namespace «appNamespace»\ContentType\Form\Type;

        use «appNamespace»\ContentType\Form\Type\Base\AbstractItemListType;

        /**
         * List content type form type implementation class.
         */
        class ItemListType extends AbstractItemListType
        {
            // feel free to extend the list content type form type class here
        }
    '''
}
