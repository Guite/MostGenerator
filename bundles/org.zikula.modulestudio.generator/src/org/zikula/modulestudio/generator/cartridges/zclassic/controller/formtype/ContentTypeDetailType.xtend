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
        use Translation\Extractor\Annotation\Ignore;
        use Translation\Extractor\Annotation\Translate;
        use Zikula\ExtensionsModule\ModuleInterface\Content\ContentTypeInterface;
        use Zikula\ExtensionsModule\ModuleInterface\Content\Form\Type\AbstractContentFormType;
        use «appNamespace»\Entity\Factory\EntityFactory;
        use «appNamespace»\Helper\EntityDisplayHelper;

        /**
         * Detail content type form type base class.
         */
        abstract class AbstractItemType extends AbstractContentFormType
        {
            public function __construct(
                protected EntityFactory $entityFactory,
                protected EntityDisplayHelper $entityDisplayHelper
            ) {
            }

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

            public function getBlockPrefix()
            {
                return '«appName.formatForDB»_contenttype_detail';
            }

            public function configureOptions(OptionsResolver $resolver)
            {
                $resolver
                    ->setDefaults([
                        'context' => ContentTypeInterface::CONTEXT_EDIT,
                        'object_type' => '«leadingEntity.name.formatForCode»',
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
        public function addObjectTypeField(FormBuilderInterface $builder, array $options = []): void
        {
            $builder->add('objectType', «IF getAllEntities.filter[hasDisplayAction].size == 1»Hidden«ELSE»Choice«ENDIF»Type::class, [
                'label' => 'Object type',
                'empty_data' => '«leadingEntity.name.formatForCode»',
                «IF getAllEntities.filter[hasDisplayAction].size > 1»
                    'attr' => [
                        'title' => 'If you change this please save the element once to reload the parameters below.',
                    ],
                    'help' => 'If you change this please save the element once to reload the parameters below.',
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

    def private addDisplayModeField(Application it) '''
        /**
         * Adds a display mode field.
         */
        public function addDisplayModeField(FormBuilderInterface $builder, array $options = []): void
        {
            $builder->add('displayMode', ChoiceType::class, [
                'label' => 'Display mode',
                'label_attr' => [
                    'class' => 'radio-custom',
                ],
                'empty_data' => 'embed',
                'choices' => [
                    'Link to object' => 'link',
                    'Embed object display' => 'embed',
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
