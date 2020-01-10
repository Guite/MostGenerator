package org.zikula.modulestudio.generator.cartridges.zclassic.controller.formtype

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class BlockListType {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelExtensions = new ModelExtensions
    extension Utils = new Utils

    String nsSymfonyFormType = 'Symfony\\Component\\Form\\Extension\\Core\\Type\\'

    /**
     * Entry point for list block form type.
     */
    def generate(Application it, IMostFileSystemAccess fsa) {
        if (!generateListBlock) {
            return
        }
        fsa.generateClassPair('Block/Form/Type/ItemListBlockType.php', listBlockTypeBaseImpl, listBlockTypeImpl)
    }

    def private listBlockTypeBaseImpl(Application it) '''
        namespace «appNamespace»\Block\Form\Type\Base;

        use Symfony\Component\Form\AbstractType;
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
        «IF targets('3.0')»
            use Symfony\Contracts\Translation\TranslatorInterface;
        «ENDIF»
        «IF hasCategorisableEntities»
            use Zikula\CategoriesModule\Entity\RepositoryInterface\CategoryRepositoryInterface;
            use Zikula\CategoriesModule\Form\Type\CategoriesType;
        «ENDIF»
        «IF !targets('3.0')»
            use Zikula\Common\Translator\TranslatorInterface;
        «ENDIF»
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
            «IF hasCategorisableEntities»

                /**
                 * @var CategoryRepositoryInterface
                 */
                protected $categoryRepository;
            «ENDIF»

            public function __construct(
                TranslatorInterface $translator«IF hasCategorisableEntities»,
                CategoryRepositoryInterface $categoryRepository«ENDIF»
            ) {
                $this->setTranslator($translator);
                «IF hasCategorisableEntities»
                    $this->categoryRepository = $categoryRepository;
                «ENDIF»
            }
            «IF !targets('3.0')»

                «setTranslatorMethod»
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
                return '«appName.formatForDB»_listblock';
            }

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
                        ->setDefined(['is_categorisable', 'category_helper', 'feature_activation_helper'])
                    «ENDIF»
                    ->setAllowedTypes('object_type', 'string')
                    «IF hasCategorisableEntities»
                        ->setAllowedTypes('is_categorisable', 'bool')
                        ->setAllowedTypes('category_helper', 'object')
                        ->setAllowedTypes('feature_activation_helper', 'object')
                    «ENDIF»
                ;
            }
        }
    '''

    def private addObjectTypeField(Application it) '''
        /**
         * Adds an object type field.
         */
        public function addObjectTypeField(FormBuilderInterface $builder, array $options = [])«IF targets('3.0')»: void«ENDIF»
        {
            $helpText = $this->«IF targets('3.0')»trans«ELSE»__«ENDIF»(
                'If you change this please save the block once to reload the parameters below.'«IF !isSystemModule»,
                «IF targets('3.0')»
                    [],
                «ENDIF»
                '«appName.formatForDB»'«ENDIF»
            );
            $builder->add('objectType', «IF getAllEntities.size == 1»Hidden«ELSE»Choice«ENDIF»Type::class, [
                'label' => $this->«IF targets('3.0')»trans«ELSE»__«ENDIF»('Object type'«IF !isSystemModule»«IF targets('3.0')», []«ENDIF», '«appName.formatForDB»'«ENDIF») . ':',
                'empty_data' => '«leadingEntity.name.formatForCode»'«IF getAllEntities.size > 1»,«ENDIF»
                «IF getAllEntities.size > 1»
                    'attr' => [
                        'title' => $helpText
                    ],
                    'help' => $helpText,
                    'choices' => [
                        «FOR entity : getAllEntities»
                            $this->«IF targets('3.0')»trans«ELSE»__«ENDIF»('«entity.nameMultiple.formatForDisplayCapital»'«IF !isSystemModule»«IF targets('3.0')», []«ENDIF», '«appName.formatForDB»'«ENDIF») => '«entity.name.formatForCode»'«IF entity != getAllEntities.last»,«ENDIF»
                        «ENDFOR»
                    ],
                    «IF !targets('2.0')»
                        'choices_as_values' => true,
                    «ENDIF»
                    'multiple' => false,
                    'expanded' => false
                «ENDIF»
            ]);
        }
    '''

    def private addCategoriesField(Application it) '''
        /**
         * Adds a categories field.
         */
        public function addCategoriesField(FormBuilderInterface $builder, array $options = [])«IF targets('3.0')»: void«ENDIF»
        {
            if (!$options['is_categorisable'] || null === $options['category_helper']) {
                return;
            }

            $objectType = $options['object_type'];
            $label = $hasMultiSelection
                ? $this->«IF targets('3.0')»trans«ELSE»__«ENDIF»('Categories'«IF !isSystemModule»«IF targets('3.0')», []«ENDIF», '«appName.formatForDB»'«ENDIF»)
                : $this->«IF targets('3.0')»trans«ELSE»__«ENDIF»('Category'«IF !isSystemModule»«IF targets('3.0')», []«ENDIF», '«appName.formatForDB»'«ENDIF»)
            ;
            $hasMultiSelection = $options['category_helper']->hasMultipleSelection($objectType);
            $entityCategoryClass = '«appNamespace»\Entity\\' . ucfirst($objectType) . 'CategoryEntity';
            $builder->add('categories', CategoriesType::class, [
                'label' => $label . ':',
                'empty_data' => $hasMultiSelection ? [] : null,
                'attr' => [
                    'class' => 'category-selector',
                    'title' => $this->«IF targets('3.0')»trans«ELSE»__«ENDIF»('This is an optional filter.'«IF !isSystemModule»«IF targets('3.0')», []«ENDIF», '«appName.formatForDB»'«ENDIF»)
                ],
                'help' => $this->«IF targets('3.0')»trans«ELSE»__«ENDIF»('This is an optional filter.'«IF !isSystemModule»«IF targets('3.0')», []«ENDIF», '«appName.formatForDB»'«ENDIF»),
                'required' => false,
                'multiple' => $hasMultiSelection,
                'module' => '«appName»',
                'entity' => ucfirst($objectType) . 'Entity',
                'entityCategoryClass' => $entityCategoryClass,
                'showRegistryLabels' => true
            ]);

            $categoryRepository = $this->categoryRepository;
            $builder->get('categories')->addModelTransformer(new CallbackTransformer(
                static function ($catIds) use ($categoryRepository, $objectType, $hasMultiSelection) {
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
                static function ($result) use ($hasMultiSelection) {
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
        public function addSortingField(FormBuilderInterface $builder, array $options = [])«IF targets('3.0')»: void«ENDIF»
        {
            $builder->add('sorting', ChoiceType::class, [
                'label' => $this->«IF targets('3.0')»trans«ELSE»__«ENDIF»('Sorting'«IF !isSystemModule»«IF targets('3.0')», []«ENDIF», '«appName.formatForDB»'«ENDIF») . ':',
                'label_attr' => [
                    'class' => 'radio-«IF targets('3.0')»custom«ELSE»inline«ENDIF»'
                ],
                'empty_data' => 'default',
                'choices' => [
                    $this->«IF targets('3.0')»trans«ELSE»__«ENDIF»('Random'«IF !isSystemModule»«IF targets('3.0')», []«ENDIF», '«appName.formatForDB»'«ENDIF») => 'random',
                    $this->«IF targets('3.0')»trans«ELSE»__«ENDIF»('Newest'«IF !isSystemModule»«IF targets('3.0')», []«ENDIF», '«appName.formatForDB»'«ENDIF») => 'newest',
                    $this->«IF targets('3.0')»trans«ELSE»__«ENDIF»('Updated'«IF !isSystemModule»«IF targets('3.0')», []«ENDIF», '«appName.formatForDB»'«ENDIF») => 'updated',
                    $this->«IF targets('3.0')»trans«ELSE»__«ENDIF»('Default'«IF !isSystemModule»«IF targets('3.0')», []«ENDIF», '«appName.formatForDB»'«ENDIF») => 'default'
                ],
                «IF !targets('2.0')»
                    'choices_as_values' => true,
                «ENDIF»
                'multiple' => false,
                'expanded' => true
            ]);
        }
    '''

    def private addAmountField(Application it) '''
        /**
         * Adds a page size field.
         */
        public function addAmountField(FormBuilderInterface $builder, array $options = [])«IF targets('3.0')»: void«ENDIF»
        {
            $helpText = $this->«IF targets('3.0')»trans«ELSE»__«ENDIF»('The maximum amount of items to be shown.'«IF !isSystemModule»«IF targets('3.0')», []«ENDIF», '«appName.formatForDB»'«ENDIF»)
                . ' ' . $this->«IF targets('3.0')»trans«ELSE»__«ENDIF»('Only digits are allowed.'«IF !isSystemModule»«IF targets('3.0')», []«ENDIF», '«appName.formatForDB»'«ENDIF»)
            ;
            $builder->add('amount', IntegerType::class, [
                'label' => $this->«IF targets('3.0')»trans«ELSE»__«ENDIF»('Amount'«IF !isSystemModule»«IF targets('3.0')», []«ENDIF», '«appName.formatForDB»'«ENDIF») . ':',
                'attr' => [
                    'maxlength' => 2,
                    'title' => $helpText
                ],
                'help' => $helpText,
                'empty_data' => 5
            ]);
        }
    '''

    def private addTemplateFields(Application it) '''
        /**
         * Adds template fields.
         */
        public function addTemplateFields(FormBuilderInterface $builder, array $options = [])«IF targets('3.0')»: void«ENDIF»
        {
            $builder->add('template', ChoiceType::class, [
                'label' => $this->«IF targets('3.0')»trans«ELSE»__«ENDIF»('Template'«IF !isSystemModule»«IF targets('3.0')», []«ENDIF», '«appName.formatForDB»'«ENDIF») . ':',
                'empty_data' => 'itemlist_display.html.twig',
                'choices' => [
                    $this->«IF targets('3.0')»trans«ELSE»__«ENDIF»('Only item titles'«IF !isSystemModule»«IF targets('3.0')», []«ENDIF», '«appName.formatForDB»'«ENDIF») => 'itemlist_display.html.twig',
                    $this->«IF targets('3.0')»trans«ELSE»__«ENDIF»('With description'«IF !isSystemModule»«IF targets('3.0')», []«ENDIF», '«appName.formatForDB»'«ENDIF») => 'itemlist_display_description.html.twig',
                    $this->«IF targets('3.0')»trans«ELSE»__«ENDIF»('Custom template'«IF !isSystemModule»«IF targets('3.0')», []«ENDIF», '«appName.formatForDB»'«ENDIF») => 'custom'
                ],
                «IF !targets('2.0')»
                    'choices_as_values' => true,
                «ENDIF»
                'multiple' => false,
                'expanded' => false
            ]);
            $exampleTemplate = 'itemlist_[objectType]_display.html.twig';
            $builder->add('customTemplate', TextType::class, [
                'label' => $this->«IF targets('3.0')»trans«ELSE»__«ENDIF»('Custom template'«IF !isSystemModule»«IF targets('3.0')», []«ENDIF», '«appName.formatForDB»'«ENDIF») . ':',
                'required' => false,
                'attr' => [
                    'maxlength' => 80,
                    'title' => $this->«IF targets('3.0')»trans«ELSE»__«ENDIF»('Example'«IF !isSystemModule»«IF targets('3.0')», []«ENDIF», '«appName.formatForDB»'«ENDIF») . ': ' . $exampleTemplate
                ],
                'help' => $this->«IF targets('3.0')»trans«ELSE»__«ENDIF»('Example'«IF !isSystemModule»«IF targets('3.0')», []«ENDIF», '«appName.formatForDB»'«ENDIF») . ': <code>' . $exampleTemplate . '</code>'«IF targets('3.0')»,
                'help_html' => true«ENDIF»
            ]);
        }
    '''

    def private addFilterField(Application it) '''
        /**
         * Adds a filter field.
         */
        public function addFilterField(FormBuilderInterface $builder, array $options = [])«IF targets('3.0')»: void«ENDIF»
        {
            $builder->add('filter', TextType::class, [
                'label' => $this->«IF targets('3.0')»trans«ELSE»__«ENDIF»('Filter (expert option)'«IF !isSystemModule»«IF targets('3.0')», []«ENDIF», '«appName.formatForDB»'«ENDIF») . ':',
                'required' => false,
                'attr' => [
                    'maxlength' => 255,
                    'title' => $this->«IF targets('3.0')»trans«ELSE»__«ENDIF»('Example'«IF !isSystemModule»«IF targets('3.0')», []«ENDIF», '«appName.formatForDB»'«ENDIF») . ': tbl.age >= 18'
                ],
                'help' => $this->«IF targets('3.0')»trans«ELSE»__«ENDIF»('Example'«IF !isSystemModule»«IF targets('3.0')», []«ENDIF», '«appName.formatForDB»'«ENDIF») . ': tbl.age >= 18'
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
