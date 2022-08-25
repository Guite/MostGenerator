package org.zikula.modulestudio.generator.cartridges.zclassic.controller.formtype.field

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class AutoCompletionRelationType {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension Utils = new Utils

    def generate(Application it, IMostFileSystemAccess fsa) {
        fsa.generateClassPair('Form/Type/Field/AutoCompletionRelationType.php', relationTypeBaseImpl, relationTypeImpl)
    }

    def private relationTypeBaseImpl(Application it) '''
        namespace «appNamespace»\Form\Type\Field\Base;

        use Symfony\Component\Form\AbstractType;
        use Symfony\Component\Form\Extension\Core\Type\HiddenType;
        use Symfony\Component\Form\FormBuilderInterface;
        use Symfony\Component\Form\FormInterface;
        use Symfony\Component\Form\FormView;
        use Symfony\Component\OptionsResolver\OptionsResolver;
        use Symfony\Component\Routing\RouterInterface;
        use «appNamespace»\Entity\Factory\EntityFactory;
        use «appNamespace»\Form\DataTransformer\AutoCompletionRelationTransformer;

        /**
         * Auto completion relation field type base class.
         */
        abstract class AbstractAutoCompletionRelationType extends AbstractType
        {
            public function __construct(protected RouterInterface $router, protected EntityFactory $entityFactory)
            {
            }

            public function buildForm(FormBuilderInterface $builder, array $options)
            {
                $transformer = new AutoCompletionRelationTransformer($this->entityFactory, $options['object_type'], $options['multiple']);
                $builder->addModelTransformer($transformer);
            }

            public function buildView(FormView $view, FormInterface $form, array $options)
            {
                $view->vars['object_type'] = $options['object_type'];
                $view->vars['multiple'] = $options['multiple'];
                $view->vars['unique_name_for_js'] = $options['unique_name_for_js'];

                $view->vars['create_url'] = '';
                «IF hasEditActions»
                    if (true === $options['allow_editing'] && in_array($options['object_type'], ['«getAllEntities.filter[hasEditAction].map[name.formatForCode].join('\', \'')»'])) {
                        $view->vars['create_url'] = $this->router->generate('«appName.formatForDB»_' . strtolower($options['object_type']) . '_edit');
                    }
                «ENDIF»
            }

            public function configureOptions(OptionsResolver $resolver)
            {
                parent::configureOptions($resolver);

                $resolver
                    ->setDefaults([
                        'object_type' => '«leadingEntity.name.formatForCode»',
                        'multiple' => false,
                        'unique_name_for_js' => '',
                        'allow_editing' => false,
                        'attr' => [
                            'class' => 'relation-selector',
                        ],
                    ])
                    ->setRequired(['object_type', 'unique_name_for_js'])
                    ->setAllowedTypes('object_type', 'string')
                    ->setAllowedTypes('multiple', 'bool')
                    ->setAllowedTypes('unique_name_for_js', 'string')
                    ->setAllowedTypes('allow_editing', 'bool')
                ;
            }

            public function getParent(): ?string
            {
                return HiddenType::class;
            }

            public function getBlockPrefix(): string
            {
                return '«appName.formatForDB»_field_autocompletionrelation';
            }
        }
    '''

    def private relationTypeImpl(Application it) '''
        namespace «appNamespace»\Form\Type\Field;

        use «appNamespace»\Form\Type\Field\Base\AbstractAutoCompletionRelationType;

        /**
         * Auto completion relation field type implementation class.
         */
        class AutoCompletionRelationType extends AbstractAutoCompletionRelationType
        {
            // feel free to add your customisation here
        }
    '''
}
