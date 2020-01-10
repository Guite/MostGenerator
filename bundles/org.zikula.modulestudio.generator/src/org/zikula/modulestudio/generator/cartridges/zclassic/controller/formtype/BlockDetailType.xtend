package org.zikula.modulestudio.generator.cartridges.zclassic.controller.formtype

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class BlockDetailType {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
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
        «IF targets('3.0')»
            use Symfony\Contracts\Translation\TranslatorInterface;
        «ELSE»
            use Zikula\Common\Translator\TranslatorInterface;
        «ENDIF»
        use Zikula\Common\Translator\TranslatorTrait;
        use «appNamespace»\Entity\Factory\EntityFactory;
        use «appNamespace»\Helper\EntityDisplayHelper;

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

            public function __construct(
                TranslatorInterface $translator,
                EntityFactory $entityFactory,
                EntityDisplayHelper $entityDisplayHelper
            ) {
                $this->setTranslator($translator);
                $this->entityFactory = $entityFactory;
                $this->entityDisplayHelper = $entityDisplayHelper;
            }
            «IF !targets('3.0')»

                «setTranslatorMethod»
            «ENDIF»

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
         */
        public function addObjectTypeField(FormBuilderInterface $builder, array $options = [])«IF targets('3.0')»: void«ENDIF»
        {
            $builder->add('objectType', «IF getAllEntities.filter[hasDisplayAction].size == 1»Hidden«ELSE»Choice«ENDIF»Type::class, [
                'label' => $this->«IF targets('3.0')»trans«ELSE»__«ENDIF»('Object type'«IF !isSystemModule»«IF targets('3.0')», []«ENDIF», '«appName.formatForDB»'«ENDIF») . ':',
                'empty_data' => '«leadingEntity.name.formatForCode»'«IF getAllEntities.filter[hasDisplayAction].size > 1»,«ENDIF»
                «IF getAllEntities.filter[hasDisplayAction].size > 1»
                    'attr' => [
                        'title' => $this->«IF targets('3.0')»trans«ELSE»__«ENDIF»('If you change this please save the block once to reload the parameters below.'«IF !isSystemModule»«IF targets('3.0')», []«ENDIF», '«appName.formatForDB»'«ENDIF»)
                    ],
                    'help' => $this->«IF targets('3.0')»trans«ELSE»__«ENDIF»('If you change this please save the block once to reload the parameters below.'«IF !isSystemModule»«IF targets('3.0')», []«ENDIF», '«appName.formatForDB»'«ENDIF»),
                    'choices' => [
                        «FOR entity : getAllEntities.filter[hasDisplayAction]»
                            $this->«IF targets('3.0')»trans«ELSE»__«ENDIF»('«entity.nameMultiple.formatForDisplayCapital»'«IF !isSystemModule»«IF targets('3.0')», []«ENDIF», '«appName.formatForDB»'«ENDIF») => '«entity.name.formatForCode»'«IF entity != getAllEntities.filter[hasDisplayAction].last»,«ENDIF»
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
         */
        public function addIdField(FormBuilderInterface $builder, array $options = [])«IF targets('3.0')»: void«ENDIF»
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
                'choices' => $choices,
                «IF !targets('2.0')»
                    'choices_as_values' => true,
                «ENDIF»
                'required' => true,
                'label' => $this->«IF targets('3.0')»trans«ELSE»__«ENDIF»('Entry to display'«IF !isSystemModule»«IF targets('3.0')», []«ENDIF», '«appName.formatForDB»'«ENDIF») . ':'
            ]);
        }
    '''

    def private addTemplateField(Application it) '''
        /**
         * Adds template fields.
         */
        public function addTemplateField(FormBuilderInterface $builder, array $options = [])«IF targets('3.0')»: void«ENDIF»
        {
            $builder
                ->add('customTemplate', TextType::class, [
                    'label' => $this->«IF targets('3.0')»trans«ELSE»__«ENDIF»('Custom template'«IF !isSystemModule»«IF targets('3.0')», []«ENDIF», '«appName.formatForDB»'«ENDIF») . ':',
                    'required' => false,
                    'attr' => [
                        'maxlength' => 80,
                        'title' => $this->«IF targets('3.0')»trans«ELSE»__«ENDIF»('Example'«IF !isSystemModule»«IF targets('3.0')», []«ENDIF», '«appName.formatForDB»'«ENDIF») . ': displaySpecial.html.twig'
                    ],
                    'help' => [
                        $this->«IF targets('3.0')»trans«ELSE»__«ENDIF»('Example'«IF !isSystemModule»«IF targets('3.0')», []«ENDIF», '«appName.formatForDB»'«ENDIF») . ': <code>displaySpecial.html.twig</code>',
                        $this->«IF targets('3.0')»trans«ELSE»__«ENDIF»('Needs to be located in the "External/YourEntity/" directory.'«IF !isSystemModule»«IF targets('3.0')», []«ENDIF», '«appName.formatForDB»'«ENDIF»)
                    ]«IF targets('3.0')»,
                    'help_html' => true«ENDIF»
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
