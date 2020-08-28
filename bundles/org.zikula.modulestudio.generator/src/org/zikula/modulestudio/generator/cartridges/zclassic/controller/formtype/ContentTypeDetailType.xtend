package org.zikula.modulestudio.generator.cartridges.zclassic.controller.formtype

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ContentTypeDetailType {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
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
        «IF targets('3.0')»
            use Translation\Extractor\Annotation\Ignore;
            use Translation\Extractor\Annotation\Translate;
            use Zikula\ExtensionsModule\ModuleInterface\Content\ContentTypeInterface;
            use Zikula\ExtensionsModule\ModuleInterface\Content\Form\Type\AbstractContentFormType;
        «ELSE»
            use Zikula\Common\Content\AbstractContentFormType;
            use Zikula\Common\Content\ContentTypeInterface;
            use Zikula\Common\Translator\TranslatorInterface;
        «ENDIF»
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

            public function __construct(
                «IF !targets('3.0')»
                    TranslatorInterface $translator,
                «ENDIF»
                EntityFactory $entityFactory,
                EntityDisplayHelper $entityDisplayHelper
            ) {
                «IF !targets('3.0')»
                    $this->setTranslator($translator);
                «ENDIF»
                $this->entityFactory = $entityFactory;
                $this->entityDisplayHelper = $entityDisplayHelper;
            }

            public function buildForm(FormBuilderInterface $builder, array $options)
            {
                $this->addObjectTypeField($builder, $options);
                $this->addIdField($builder, $options);
                $this->addDisplayModeField($builder, $options);
                $this->addTemplateField($builder, $options);
            }
            «IF !targets('3.0')»

                «setTranslatorMethod»
            «ENDIF»

            «addObjectTypeField»

            «addIdField»

            «addDisplayModeField»

            «addTemplateField»

            public function getBlockPrefix()
            {
                return '«appName.formatForDB»_contenttype_detail';
            }

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
         */
        public function addObjectTypeField(FormBuilderInterface $builder, array $options = [])«IF targets('3.0')»: void«ENDIF»
        {
            $builder->add('objectType', «IF getAllEntities.filter[hasDisplayAction].size == 1»Hidden«ELSE»Choice«ENDIF»Type::class, [
                'label' => «IF !targets('3.0')»$this->__(«ENDIF»'Object type:'«IF !targets('3.0')»«IF !isSystemModule», '«appName.formatForDB»'«ENDIF»)«ENDIF»,
                'empty_data' => '«leadingEntity.name.formatForCode»'«IF getAllEntities.filter[hasDisplayAction].size > 1»,«ENDIF»
                «IF getAllEntities.filter[hasDisplayAction].size > 1»
                    'attr' => [
                        'title' => «IF !targets('3.0')»$this->__(«ENDIF»'If you change this please save the element once to reload the parameters below.'«IF !targets('3.0')»«IF !isSystemModule», '«appName.formatForDB»'«ENDIF»)«ENDIF»,
                    ],
                    'help' => «IF !targets('3.0')»$this->__(«ENDIF»'If you change this please save the element once to reload the parameters below.'«IF !targets('3.0')»«IF !isSystemModule», '«appName.formatForDB»'«ENDIF»)«ENDIF»,
                    'choices' => [
                        «FOR entity : getAllEntities.filter[hasDisplayAction]»
                            «IF !targets('3.0')»$this->__(«ENDIF»'«entity.nameMultiple.formatForDisplayCapital»'«IF !targets('3.0')»«IF !isSystemModule», '«appName.formatForDB»'«ENDIF»)«ENDIF» => '«entity.name.formatForCode»',
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
                'choices' => «IF targets('3.0')»/** @Ignore */«ENDIF»$choices,
                'required' => true,
                'label' => «IF !targets('3.0')»$this->__(«ENDIF»'Entry to display:'«IF !targets('3.0')»«IF !isSystemModule», '«appName.formatForDB»'«ENDIF»)«ENDIF»,
            ]);
        }
    '''

    def private addDisplayModeField(Application it) '''
        /**
         * Adds a display mode field.
         */
        public function addDisplayModeField(FormBuilderInterface $builder, array $options = [])«IF targets('3.0')»: void«ENDIF»
        {
            $builder->add('displayMode', ChoiceType::class, [
                'label' => «IF !targets('3.0')»$this->__(«ENDIF»'Display mode:'«IF !targets('3.0')»«IF !isSystemModule», '«appName.formatForDB»'«ENDIF»)«ENDIF»,
                'label_attr' => [
                    'class' => 'radio-«IF targets('3.0')»custom«ELSE»inline«ENDIF»',
                ],
                'empty_data' => 'embed',
                'choices' => [
                    «IF !targets('3.0')»$this->__(«ENDIF»'Link to object'«IF !targets('3.0')»«IF !isSystemModule», '«appName.formatForDB»'«ENDIF»)«ENDIF» => 'link',
                    «IF !targets('3.0')»$this->__(«ENDIF»'Embed object display'«IF !targets('3.0')»«IF !isSystemModule», '«appName.formatForDB»'«ENDIF»)«ENDIF» => 'embed',
                ],
                'multiple' => false,
                'expanded' => true,
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
                    'label' => «IF !targets('3.0')»$this->__(«ENDIF»'Custom template:'«IF !targets('3.0')»«IF !isSystemModule», '«appName.formatForDB»'«ENDIF»)«ENDIF»,
                    'required' => false,
                    'attr' => [
                        'maxlength' => 80,
                        «IF targets('3.0')»
                            /** @Ignore */
                        «ENDIF»
                        'title' => «IF targets('3.0')»/** @Translate */«ELSE»$this->__(«ENDIF»'Example'«IF !targets('3.0')»«IF !isSystemModule», '«appName.formatForDB»'«ENDIF»)«ENDIF» . ': displaySpecial.html.twig',
                    ],
                    «IF targets('3.0')»
                        /** @Ignore */
                    «ENDIF»
                    'help' => [
                        «IF targets('3.0')»/** @Translate */«ELSE»$this->__(«ENDIF»'Example'«IF !targets('3.0')»«IF !isSystemModule», '«appName.formatForDB»'«ENDIF»)«ENDIF» . ': <code>displaySpecial.html.twig</code>',
                        «IF targets('3.0')»/** @Translate */«ELSE»$this->__(«ENDIF»'Needs to be located in the "External/YourEntity/" directory.'«IF !targets('3.0')»«IF !isSystemModule», '«appName.formatForDB»'«ENDIF»)«ENDIF»,
                    ],
                    «IF targets('3.0')»
                        'help_html' => true,
                    «ENDIF»
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
