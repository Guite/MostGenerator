package org.zikula.modulestudio.generator.cartridges.zclassic.controller.formtype

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class EntityMetaData {
    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    FileHelper fh = new FileHelper
    String nsSymfonyFormType = 'Symfony\\Component\\Form\\Extension\\Core\\Type\\'

    /**
     * Entry point for entity meta data form type.
     * 1.4.x only.
     */
    def generate(Application it, IFileSystemAccess fsa) {
        if (!hasMetaDataEntities) {
            return
        }
        generateClassPair(fsa, getAppSourceLibPath + 'Form/Type/EntityMetaDataType.php',
            fh.phpFileContent(it, metaDataTypeBaseImpl), fh.phpFileContent(it, metaDataTypeImpl)
        )
    }

    def private metaDataTypeBaseImpl(Application it) '''
        namespace «appNamespace»\Form\Type\Base;

        use Symfony\Component\Form\AbstractType;
        use Symfony\Component\Form\FormBuilderInterface;
        use Symfony\Component\OptionsResolver\OptionsResolver;
        use Zikula\Common\Translator\TranslatorInterface;

        /**
         * Entity meta data form type base class.
         */
        class EntityMetaDataType extends AbstractType
        {
            /**
             * @var TranslatorInterface
             */
            protected $translator;

            /**
             * EntityMetaDataType constructor.
             *
             * @param TranslatorInterface $translator Translator service instance.
             */
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
                    «fieldImpl('title', 80)»
                    «fieldImpl('author', 80)»
                    «fieldImpl('subject', 255)»
                    «fieldImpl('keywords', 128)»
                    «fieldImpl('description', 255)»
                    «fieldImpl('publisher', 128)»
                    «fieldImpl('contributor', 80)»
                    «fieldImpl('startdate', 0)»
                    «fieldImpl('enddate', 0)»
                    «fieldImpl('type', 128)»
                    «fieldImpl('format', 128)»
                    «fieldImpl('uri', 255)»
                    «fieldImpl('source', 128)»
                    «fieldImpl('language', 0)»
                    «fieldImpl('relation', 255)»
                    «fieldImpl('coverage', 64)»
                    «fieldImpl('comment', 255)»
                    «fieldImpl('extra', 255)»
                ;
            }

            /**
             * {@inheritdoc}
             */
            public function getBlockPrefix()
            {
                return '«appName.formatForDB»_entitymetadata';
            }

            /**
             * {@inheritdoc}
             */
            public function getName()
            {
                return $this->getBlockPrefix();
            }

            /**
             * {@inheritdoc}
             */
            public function configureOptions(OptionsResolver $resolver)
            {
                $resolver->setDefaults([
                    // define class for underlying data (required for embedding forms)
                    'data_class' => 'Zikula\Core\Doctrine\Entity\AbstractEntityMetadata'
                ]);
            }
        }
    '''

    def private fieldImpl(String name, Integer length) '''
        ->add('«name»', '«nsSymfonyFormType»«IF 'startdate'.equals(name) || 'enddate'.equals(name)»DateTime«ELSEIF 'language'.equals(name)»Language«ELSE»Text«ENDIF»Type', [
            'label' => $this->translator->__('«name.formatForDisplayCapital»') . ':',
            'required' => false,
            «IF 'startdate'.equals(name) || 'enddate'.equals(name)»
                'widget' => 'single_text',
            «ELSEIF 'language'.equals(name)»
                'attr' => [
                    'title' => $this->translator->__('Choose a language')
                ],
            «ELSE»
                'max_length' => «length»
            «ENDIF»
        ])
    '''

    def private metaDataTypeImpl(Application it) '''
        namespace «appNamespace»\Form\Type;

        use «appNamespace»\Form\Type\Base\EntityMetaDataType as BaseEntityMetaDataType;

        /**
         * Entity meta data form type implementation class.
         */
        class EntityMetaDataType extends BaseEntityMetaDataType
        {
            // feel free to extend the meta data form type class here
        }
    '''
}
