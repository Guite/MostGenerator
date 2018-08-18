package org.zikula.modulestudio.generator.cartridges.zclassic.controller.formtype

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ContentTypeDetailType {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension Utils = new Utils

    String nsSymfonyFormType = 'Symfony\\Component\\Form\\Extension\\Core\\Type\\'

    /**
     * Entry point for detail content type form type.
     */
    def generate(Application it, IMostFileSystemAccess fsa) {
        if (!generateDetailContentType || !hasDisplayActions) {
            return
        }
        fsa.generateClassPair('ContentType/Form/Type/ItemType.php', detailContentTypeBaseImpl, detailContentTypeImpl)
    }

    def private detailContentTypeBaseImpl(Application it) '''
        namespace «appNamespace»\ContentType\Form\Type\Base;

        use «nsSymfonyFormType»ChoiceType;
        «IF getAllEntities.filter[hasDisplayAction].size == 1»
            use «nsSymfonyFormType»HiddenType;
        «ENDIF»
        use «nsSymfonyFormType»TextType;
        use Symfony\Component\Form\FormBuilderInterface;
        use Symfony\Component\OptionsResolver\OptionsResolver;
        use Zikula\Common\Content\AbstractContentFormType;
        use Zikula\Common\Content\ContentTypeInterface;
        use Zikula\Common\Translator\TranslatorInterface;
        use «appNamespace»\Entity\Factory\EntityFactory;
        use «appNamespace»\Helper\EntityDisplayHelper;

        /**
         * Detail content type form type base class.
         */
        abstract class AbstractItemType extends AbstractContentFormType
        {
            /**
             * @var EntityFactory
             */
            protected $entityFactory;

            /**
             * @var EntityDisplayHelper
             */
            protected $entityDisplayHelper;

            /**
             * ItemType constructor.
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
                $this->entityFactory = $entityFactory;
                $this->entityDisplayHelper = $entityDisplayHelper;
            }

            /**
             * @inheritDoc
             */
            public function buildForm(FormBuilderInterface $builder, array $options)
            {
                $this->addObjectTypeField($builder, $options);
                $this->addIdField($builder, $options);
                $this->addDisplayModeField($builder, $options);
                $this->addTemplateField($builder, $options);
            }

            «addObjectTypeField»

            «addIdField»

            «addDisplayModeField»

            «addTemplateField»

            /**
             * @inheritDoc
             */
            public function getBlockPrefix()
            {
                return '«appName.formatForDB»_contenttype_detail';
            }

            /**
             * @inheritDoc
             */
            public function configureOptions(OptionsResolver $resolver)
            {
                $resolver
                    ->setDefaults([
                        'context' => ContentTypeInterface::CONTEXT_EDIT,
                        'object_type' => '«leadingEntity.name.formatForCode»'
                    ])
                    ->setRequired(['object_type'])
                    ->setAllowedTypes('context', 'string')
                    ->setAllowedTypes('object_type', 'string')
                    ->setAllowedValues('context', [ContentTypeInterface::CONTEXT_EDIT, ContentTypeInterface::CONTEXT_TRANSLATION])
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
        public function addObjectTypeField(FormBuilderInterface $builder, array $options = [])
        {
            $builder->add('objectType', «IF getAllEntities.filter[hasDisplayAction].size == 1»Hidden«ELSE»Choice«ENDIF»Type::class, [
                'label' => $this->__('Object type'«IF !isSystemModule», '«appName.formatForDB»'«ENDIF») . ':',
                'empty_data' => '«leadingEntity.name.formatForCode»'«IF getAllEntities.filter[hasDisplayAction].size > 1»,«ENDIF»
                «IF getAllEntities.filter[hasDisplayAction].size > 1»
                    'attr' => [
                        'title' => $this->__('If you change this please save the element once to reload the parameters below.'«IF !isSystemModule», '«appName.formatForDB»'«ENDIF»)
                    ],
                    'help' => $this->__('If you change this please save the element once to reload the parameters below.'«IF !isSystemModule», '«appName.formatForDB»'«ENDIF»),
                    'choices' => [
                        «FOR entity : getAllEntities.filter[hasDisplayAction]»
                            $this->__('«entity.nameMultiple.formatForDisplayCapital»'«IF !isSystemModule», '«appName.formatForDB»'«ENDIF») => '«entity.name.formatForCode»'«IF entity != getAllEntities.filter[hasDisplayAction].last»,«ENDIF»
                        «ENDFOR»
                    ],
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
        public function addIdField(FormBuilderInterface $builder, array $options = [])
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
                'required' => true,
                'label' => $this->__('Entry to display'«IF !isSystemModule», '«appName.formatForDB»'«ENDIF») . ':'
            ]);
        }
    '''

    def private addDisplayModeField(Application it) '''
        /**
         * Adds a display mode field.
         *
         * @param FormBuilderInterface $builder The form builder
         * @param array                $options The options
         */
        public function addDisplayModeField(FormBuilderInterface $builder, array $options = [])
        {
            $builder->add('displayMode', ChoiceType::class, [
                'label' => $this->__('Display mode'«IF !isSystemModule», '«appName.formatForDB»'«ENDIF») . ':',
                'label_attr' => [
                    'class' => 'radio-inline'
                ],
                'empty_data' => 'embed',
                'choices' => [
                    $this->__('Link to object'«IF !isSystemModule», '«appName.formatForDB»'«ENDIF») => 'link',
                    $this->__('Embed object display'«IF !isSystemModule», '«appName.formatForDB»'«ENDIF») => 'embed'
                ],
                'multiple' => false,
                'expanded' => true
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
        public function addTemplateField(FormBuilderInterface $builder, array $options = [])
        {
            $builder
                ->add('customTemplate', TextType::class, [
                    'label' => $this->__('Custom template'«IF !isSystemModule», '«appName.formatForDB»'«ENDIF») . ':',
                    'required' => false,
                    'attr' => [
                        'maxlength' => 80,
                        'title' => $this->__('Example'«IF !isSystemModule», '«appName.formatForDB»'«ENDIF») . ': displaySpecial.html.twig'
                    ],
                    'help' => [
                        $this->__('Example'«IF !isSystemModule», '«appName.formatForDB»'«ENDIF») . ': <em>displaySpecial.html.twig</em>',
                        $this->__('Needs to be located in the "External/YourEntity/" directory.'«IF !isSystemModule», '«appName.formatForDB»'«ENDIF»)
                    ]
                ])
            ;
        }
    '''

    def private detailContentTypeImpl(Application it) '''
        namespace «appNamespace»\ContentType\Form\Type;

        use «appNamespace»\ContentType\Form\Type\Base\AbstractItemType;

        /**
         * Detail content type form type implementation class.
         */
        class ItemType extends AbstractItemType
        {
            // feel free to extend the detail content type form type class here
        }
    '''
}
