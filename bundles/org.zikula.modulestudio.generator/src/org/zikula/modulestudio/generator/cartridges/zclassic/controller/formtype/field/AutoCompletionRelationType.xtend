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
        «IF targets('1.5')»
            use Symfony\Component\Form\Extension\Core\Type\HiddenType;
        «ENDIF»
        use Symfony\Component\Form\FormBuilderInterface;
        use Symfony\Component\OptionsResolver\OptionsResolver;
        use Zikula\Common\Translator\TranslatorInterface;
        use «appNamespace»\Form\DataTransformer\AutoCompletionRelationTransformer;

        /**
         * Auto completion relation field type base class.
         */
        abstract class AbstractAutoCompletionRelationType extends AbstractType
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
             * @param TranslatorInterface $translator Translator service instance
             * @param ObjectManager $objectManager Doctrine object manager
             */
            public function __construct(TranslatorInterface $translator, ObjectManager $objectManager)
            {
                $this->translator = $translator;
                $this->objectManager
            }

            /**
             * @inheritDoc
             */
            public function buildForm(FormBuilderInterface $builder, array $options)
            {
                $transformer = new AutoCompletionRelationTransformer($this->objectManager, $options['object_type'], $options['multiple']);
                $builder->addModelTransformer($transformer);
            }

            /**
             * @inheritDoc
             */
            public function configureOptions(OptionsResolver $resolver)
            {
                parent::configureOptions($resolver);

                $resolver
                    ->setDefaults([
                        'object_type' => '«leadingEntity.name.formatForCode»',
                        'multiple' => false,
                        'unique_name_for_js' => '',
                        'attr' => [
                            'class' => 'relation-selector typeahead'
                        ]
                    ])
                    ->setRequired(['object_type', 'unique_name_for_js'])
                    ->setAllowedTypes([
                        'object_type' => 'string',
                        'multiple' => 'bool'
                    ])
                ;
            }

            /**
             * @inheritDoc
             */
            public function getParent()
            {
                return «IF targets('1.5')»HiddenType::class«ELSE»'Symfony\Component\Form\Extension\Core\Type\HiddenType'«ENDIF»;
            }

            /**
             * @inheritDoc
             */
            public function getBlockPrefix()
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
        class AutoCompletionRelationType extends AbstractRelationType
        {
            // feel free to add your customisation here
        }
    '''
}
