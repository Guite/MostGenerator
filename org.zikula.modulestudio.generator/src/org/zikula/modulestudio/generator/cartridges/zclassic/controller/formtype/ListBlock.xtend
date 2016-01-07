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

        use Symfony\Component\Form\AbstractType as SymfonyAbstractType;
        use Symfony\Component\Form\FormBuilderInterface;
        use Symfony\Component\Translation\TranslatorInterface;

        /**
         * List block form type base class.
         */
        class ItemListBlockType extends SymfonyAbstractType
        {
            /**
             * @var TranslatorInterface
             */
            private $translator;

            public function __construct(TranslatorInterface $translator)
            {
                $this->translator = $translator;
            }

            /**
             * {@inheritdoc}
             */
            public function buildForm(FormBuilderInterface $builder, array $options)
            {
                $builder
                    ->add('objectType', '«nsSymfonyFormType»ChoiceType', [
                        'label' => $this->translator->trans('Object type', [], '«app.appName.formatForDB»'),
                        'empty_data' => '«app.leadingEntity.name.formatForCode»',
                        'attr' => [
                            'title' => $this->translator->trans('If you change this please save the block once to reload the parameters below.', [], '«app.appName.formatForDB»'),
                            'help' => $this->translator->trans('If you change this please save the block once to reload the parameters below.', [], '«app.appName.formatForDB»')
                        ],
                        'choices' => [
                            «FOR entity : getAllEntities»
                                '«entity.name.formatForDisplayCapital»' => $this->translator->trans('«entity.nameMultiple.formatForDisplayCapital»', [], '«app.appName.formatForDB»')«IF entity != getAllEntities.last»,«ENDIF»
                            «ENDFOR»
                        ],
                        'choices_as_values' => true
                    ]);
                «IF hasCategorisableEntities»

                    if ($options['isCategorisable']) {
                        $hasMultiSelection = \ModUtil::apiFunc('«appName», 'category', 'hasMultipleSelection', ['ot' => $options['objectType']]);
                        $builder->add('categoryAssignments', 'Zikula\CategoriesModule\Form\Type\CategoriesType', [
                            'label' => $hasMultiSelection ? $this->translator->trans('Categories', [], '«app.appName.formatForDB»') : $this->translator->trans('Category', [], '«app.appName.formatForDB»'),
                            'empty_data' => [],
                            'attr' => [
                                'title' => $this->translator->trans('This is an optional filter.', [], '«app.appName.formatForDB»'),
                                'help' => $this->translator->trans('This is an optional filter.', [], '«app.appName.formatForDB»')
                            ],
                            'required' => false,
                            'multiple' => $hasMultiSelection,
                            'module' => '«appName»',
                            'entity' => ucfirst($options['objectType']) . 'Entity',
                            'entityCategoryClass' => '«app.appNamespace»\Entity\' . ucfirst($options['objectType']) . 'CategoryEntity'
                        ]);
                    }
            	«ENDIF»

                $builder
                    ->add('sorting', '«nsSymfonyFormType»ChoiceType', [
                        'label' => $this->translator->trans('Sorting', [], '«app.appName.formatForDB»'),
                        'empty_data' => 'default',
                        'choices' => [
                            'random' => $this->translator->trans('Random', [], '«app.appName.formatForDB»'),
                            'newest' => $this->translator->trans('Newest', [], '«app.appName.formatForDB»'),
                            'default' => $this->translator->trans('Default', [], '«app.appName.formatForDB»')
                        ],
                        'choices_as_values' => true
                    ])
                    ->add('amount', '«nsSymfonyFormType»IntegerType', [
                        'label' => $this->translator->trans('Amount', [], '«app.appName.formatForDB»'),
                        'attr' => [
                            'title' => $this->translator->trans('The maximum amount of items to be shown. Only digits are allowed.', [], '«app.appName.formatForDB»'),
                            'help' => $this->translator->trans('The maximum amount of items to be shown. Only digits are allowed.', [], '«app.appName.formatForDB»')
                        ]
                        'empty_data' => 5,
                        'max_length' => 2,
                        'scale' => 0
                    ])
                    ->add('template', '«nsSymfonyFormType»ChoiceType', [
                        'label' => $this->translator->trans('Template', [], '«app.appName.formatForDB»'),
                        'empty_data' => 'itemlist_display.html.twig',
                        'choices' => [
                            'itemlist_display.html.twig' => $this->translator->trans('Only item titles', [], '«app.appName.formatForDB»'),
                            'itemlist_display_description.html.twig' => $this->translator->trans('With description', [], '«app.appName.formatForDB»'),
                            'custom' => $this->translator->trans('Custom template', [], '«app.appName.formatForDB»')
                        ],
                        'choices_as_values' => true
                    ])
                    ->add('customTemplate', '«nsSymfonyFormType»TextType', [
                        'label' => $this->translator->trans('Custom template', [], '«app.appName.formatForDB»'),
                        'required' => false,
                        'attr' => [
                            'title' => $this->translator->trans('Example', [], '«app.appName.formatForDB»') . ': <em>itemlist_[objectType]_display.html.twig</em>',
                            'help' => $this->translator->trans('Example', [], '«app.appName.formatForDB»') . ': <em>itemlist_[objectType]_display.html.twig</em>'
                        ]
                        'max_length' => 80
                    ])
                    ->add('filter', '«nsSymfonyFormType»TextType', [
                        'label' => $this->translator->trans('Filter (expert option)', [], '«app.appName.formatForDB»'),
                        'required' => false,
                        'max_length' => 255
                    ])
                ;
            }

            /**
             * {@inheritdoc}
             */
            public function getBlockPrefix()
            {
                return '«appName.formatForDB»_listblock';
            }
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
