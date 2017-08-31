package org.zikula.modulestudio.generator.cartridges.zclassic.controller.formtype

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.GeneratorSettingsExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class BlockDetailType {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension GeneratorSettingsExtensions = new GeneratorSettingsExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelExtensions = new ModelExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    FileHelper fh = new FileHelper
    String nsSymfonyFormType = 'Symfony\\Component\\Form\\Extension\\Core\\Type\\'

    /**
     * Entry point for list block form type.
     */
    def generate(Application it, IFileSystemAccess fsa) {
        if (!generateDetailBlock) {
            return
        }
        generateClassPair(fsa, getAppSourceLibPath + 'Block/Form/Type/ItemBlockType.php',
            fh.phpFileContent(it, detailBlockTypeBaseImpl), fh.phpFileContent(it, detailBlockTypeImpl)
        )
    }

    def private detailBlockTypeBaseImpl(Application it) '''
        namespace «appNamespace»\Block\Form\Type\Base;

        use Symfony\Component\Form\AbstractType;
        use «nsSymfonyFormType»ChoiceType;
        «IF getAllEntities.filter[hasDisplayAction].size == 1»
            use «nsSymfonyFormType»HiddenType;
        «ENDIF»
        use «nsSymfonyFormType»TextType;
        use Symfony\Component\Form\FormBuilderInterface;
        use Symfony\Component\OptionsResolver\OptionsResolver;
        use Zikula\Common\Translator\TranslatorInterface;
        use Zikula\Common\Translator\TranslatorTrait;
        use «appNamespace»\Entity\Factory\EntityFactory;
        use «appNamespace»\Entity\Helper\EntityDisplayHelper;

        /**
         * Detail block form type base class.
         */
        abstract class AbstractItemBlockType extends AbstractType
        {
            use TranslatorTrait;

            /**
             * @var EntityFactory
             */
            protected $entityFactory;

            /**
             * @var EntityDisplayHelper
             */
            protected $entityDisplayHelper;

            /**
             * ItemBlockType constructor.
             *
             * @param TranslatorInterface $translator          Translator service instance
             * @param EntityFactory       $entityFactory       EntityFactory service instance
             * @param EntityDisplayHelper $entityDisplayHelper EntityDisplayHelper service instance
             */
            public function __construct(
                TranslatorInterface $translator,
                EntityFactory $entityFactory,
                EntityDisplayHelper $entityDisplayHelper
            ) {
                $this->setTranslator($translator);
            }

            «setTranslatorMethod»

            /**
             * @inheritDoc
             */
            public function buildForm(FormBuilderInterface $builder, array $options)
            {
                $this->addObjectTypeField($builder, $options);
                $this->addIdField($builder, $options);
                $this->addTemplateField($builder, $options);
            }

            «addObjectTypeField»

            «addIdField»

            «addTemplateField»

            /**
             * @inheritDoc
             */
            public function getBlockPrefix()
            {
                return '«appName.formatForDB»_detailblock';
            }

            /**
             * @inheritDoc
             */
            public function configureOptions(OptionsResolver $resolver)
            {
                $resolver
                    ->setDefaults([
                        'object_type' => '«leadingEntity.name.formatForCode»'
                    ])
                    ->setRequired(['object_type'])
                    ->setAllowedTypes('object_type', 'string')
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
            $builder->add('objectType', «IF getAllEntities.filter[hasDisplayAction].size == 1»Hidden«ELSE»Choice«ENDIF»Type::class, [
                'label' => $this->__('Object type') . ':',
                'empty_data' => '«leadingEntity.name.formatForCode»',
                'attr' => [
                    'title' => $this->__('If you change this please save the block once to reload the parameters below.')
                ],
                'help' => $this->__('If you change this please save the block once to reload the parameters below.')«IF getAllEntities.filter[hasDisplayAction].size > 1»,
                'choices' => [
                    «FOR entity : getAllEntities.filter[hasDisplayAction]»
                        $this->__('«entity.nameMultiple.formatForDisplayCapital»') => '«entity.name.formatForCode»'«IF entity != getAllEntities.filter[hasDisplayAction].last»,«ENDIF»
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

    def private addIdField(Application it) '''
        /**
         * Adds a item identifier field.
         *
         * @param FormBuilderInterface $builder The form builder
         * @param array                $options The options
         */
        public function addIdField(FormBuilderInterface $builder, array $options)
        {
            $repository = $this->entityFactory->getRepository($options['object_type']);
            // select without joins
            $entities = $repository->selectWhere('', '', false);

            $choices = [];
            foreach ($entities as $entity) {
                $choices[$this->entityDisplayHelper->getFormattedTitle($entity)] = $entity->getKey();
            }
            ksort($choices);

            $builder->add('id', ChoiceType::class, [
                'choice_label' => $choiceLabelClosure,
                'multiple' => false,
                'expanded' => false,
                'choices' => $choices,
                «IF !targets('2.0')»
                    'choices_as_values' => true,
                «ENDIF»
                'required' => true,
                'label' => $this->__('Entry to display') . ':'
            ]);
        }
    '''

    def private addTemplateField(Application it) '''
        /**
         * Adds template fields.
         *
         * @param FormBuilderInterface $builder The form builder
         * @param array                $options The options
         */
        public function addTemplateField(FormBuilderInterface $builder, array $options)
        {
            $builder
                ->add('customTemplate', TextType::class, [
                    'label' => $this->__('Custom template') . ':',
                    'required' => false,
                    'attr' => [
                        'maxlength' => 80,
                        'title' => $this->__('Example') . ': displaySpecial.html.twig'
                    ],
                    'help' => [
                        $this->__('Example') . ': <em>displaySpecial.html.twig</em>',
                        $this->__('Needs to be located in the "External/YourEntity/" directory.')
                    ]
                ])
            ;
        }
    '''

    def private detailBlockTypeImpl(Application it) '''
        namespace «appNamespace»\Block\Form\Type;

        use «appNamespace»\Block\Form\Type\Base\AbstractItemBlockType;

        /**
         * Detail block form type implementation class.
         */
        class ItemBlockType extends AbstractItemBlockType
        {
            // feel free to extend the detail block form type class here
        }
    '''
}
