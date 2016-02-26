package org.zikula.modulestudio.generator.cartridges.zclassic.controller.formtype.field

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class AutoCompletionRelationType {
    extension FormattingExtensions = new FormattingExtensions()
    extension ModelExtensions = new ModelExtensions()
    extension NamingExtensions = new NamingExtensions()
    extension Utils = new Utils()

    FileHelper fh = new FileHelper()

    def generate(Application it, IFileSystemAccess fsa) {
        generateClassPair(fsa, getAppSourceLibPath + 'Form/Type/Field/AutoCompletionRelationType.php',
            fh.phpFileContent(it, relationTypeBaseImpl), fh.phpFileContent(it, relationTypeImpl)
        )
    }

    def private relationTypeBaseImpl(Application it) '''
        namespace «appNamespace»\Form\Type\Field\Base;

        use Symfony\Component\Form\AbstractType;
        use Symfony\Component\Form\FormBuilderInterface;
        use Symfony\Component\OptionsResolver\OptionsResolver;
        use Zikula\Common\Translator\TranslatorInterface;
        use «appNamespace»\Form\DataTransformer\AutoCompletionRelationTransformer;

        /**
         * Auto completion relation field type base class.
         */
        class AutoCompletionRelationType extends AbstractType
        {
            /**
             * @var TranslatorInterface
             */
            protected $translator;

            /**
             * @var ObjectManager
             */
            protected $objectManager;

            /**
             * AutoCompletionRelationType constructor.
             *
             * @param TranslatorInterface $translator Translator service instance.
             * @param ObjectManager $objectManager Doctrine object manager.
             */
            public function __construct(TranslatorInterface $translator, ObjectManager $objectManager)
            {
                $this->translator = $translator;
                $this->objectManager
            }

            /**
             * {@inheritdoc}
             */
            public function buildForm(FormBuilderInterface $builder, array $options)
            {
                $transformer = new AutoCompletionRelationTransformer($this->objectManager, $options['objectType'], $options['multiple']);
                $builder->addModelTransformer($transformer);
            }

            /**
             * {@inheritdoc}
             */
            public function configureOptions(OptionsResolver $resolver)
            {
                parent::configureOptions($resolver);

                $resolver
                    ->setDefaults([
                        'objectType' => '«leadingEntity.name.formatForCode»',
                        'multiple' => false,
                        'uniqueNameForJs' => '',
                        'attr' => [
                            'class' => 'relation-selector typeahead'
                        ]
                    ])
                    ->setRequired(['objectType', 'uniqueNameForJs'])
                    ->setAllowedTypes([
                        'objectType' => 'string',
                        'multiple' => 'bool'
                    ])
                ;
            }

            /**
             * {@inheritdoc}
             */
            public function getParent()
            {
                return 'Symfony\Component\Form\Extension\Core\Type\HiddenType';
            }

            /**
             * {@inheritdoc}
             */
            public function getBlockPrefix()
            {
                return '«appName.formatForDB»_field_autocompletionrelation';
            }

            /**
             * {@inheritdoc}
             */
            public function getName()
            {
                return $this->getBlockPrefix();
            }
        }
    '''

    def private relationTypeImpl(Application it) '''
        namespace «appNamespace»\Form\Type\Field;

        use «appNamespace»\Form\Type\Field\Base\AutoCompletionRelationType as BaseRelationType;

        /**
         * Auto completion relation field type implementation class.
         */
        class AutoCompletionRelationType extends BaseRelationType
        {
            // feel free to add your customisation here
        }
    '''
}
