package org.zikula.modulestudio.generator.cartridges.zclassic.controller.formtype

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class BlockDetailType {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension Utils = new Utils

    String nsSymfonyFormType = 'Symfony\\Component\\Form\\Extension\\Core\\Type\\'

    /**
     * Entry point for detail block form type.
     */
    def generate(Application it, IMostFileSystemAccess fsa) {
        if (!generateDetailBlock || !hasDisplayActions) {
            return
        }
        fsa.generateClassPair('Block/Form/Type/ItemBlockType.php', detailBlockTypeBaseImpl, detailBlockTypeImpl)
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
        use Translation\Extractor\Annotation\Ignore;
        use Translation\Extractor\Annotation\Translate;
        use «appNamespace»\Entity\Factory\EntityFactory;
        use «appNamespace»\Helper\EntityDisplayHelper;

        /**
         * Detail block form type base class.
         */
        abstract class AbstractItemBlockType extends AbstractType
        {
            /**
             * @var EntityFactory
             */
            protected $entityFactory;

            /**
             * @var EntityDisplayHelper
             */
            protected $entityDisplayHelper;

            public function __construct(
                EntityFactory $entityFactory,
                EntityDisplayHelper $entityDisplayHelper
            ) {
                $this->entityFactory = $entityFactory;
                $this->entityDisplayHelper = $entityDisplayHelper;
            }

            public function buildForm(FormBuilderInterface $builder, array $options)
            {
                $this->addObjectTypeField($builder, $options);
                $this->addIdField($builder, $options);
                $this->addTemplateField($builder, $options);
            }

            «addObjectTypeField»

            «addIdField»

            «addTemplateField»

            public function getBlockPrefix()
            {
                return '«appName.formatForDB»_detailblock';
            }

            public function configureOptions(OptionsResolver $resolver)
            {
                $resolver
                    ->setDefaults([
                        'object_type' => '«leadingEntity.name.formatForCode»',
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
         */
        public function addObjectTypeField(FormBuilderInterface $builder, array $options = []): void
        {
            $builder->add('objectType', «IF getAllEntities.filter[hasDisplayAction].size == 1»Hidden«ELSE»Choice«ENDIF»Type::class, [
                'label' => 'Object type',
                'empty_data' => '«leadingEntity.name.formatForCode»',
                «IF getAllEntities.filter[hasDisplayAction].size > 1»
                    'attr' => [
                        'title' => 'If you change this please save the block once to reload the parameters below.',
                    ],
                    'help' => 'If you change this please save the block once to reload the parameters below.',
                    'choices' => [
                        «FOR entity : getAllEntities.filter[hasDisplayAction]»
                            '«entity.nameMultiple.formatForDisplayCapital»' => '«entity.name.formatForCode»',
                        «ENDFOR»
                    ],
                    'multiple' => false,
                    'expanded' => false,
                «ENDIF»
            ]);
        }
    '''

    def private addIdField(Application it) '''
        /**
         * Adds a item identifier field.
         */
        public function addIdField(FormBuilderInterface $builder, array $options = []): void
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
                'multiple' => false,
                'expanded' => false,
                'choices' => /** @Ignore */$choices,
                'required' => true,
                'label' => 'Entry to display',
            ]);
        }
    '''

    def private addTemplateField(Application it) '''
        /**
         * Adds template fields.
         */
        public function addTemplateField(FormBuilderInterface $builder, array $options = []): void
        {
            $builder
                ->add('customTemplate', TextType::class, [
                    'label' => 'Custom template',
                    'required' => false,
                    'attr' => [
                        'maxlength' => 80,
                        /** @Ignore */
                        'title' => /** @Translate */'Example' . ': displaySpecial.html.twig',
                    ],
                    /** @Ignore */
                    'help' => [
                        /** @Translate */'Example' . ': <code>displaySpecial.html.twig</code>',
                        /** @Translate */'Needs to be located in the "External/YourEntity/" directory.',
                    ],
                    'help_html' => true,
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
