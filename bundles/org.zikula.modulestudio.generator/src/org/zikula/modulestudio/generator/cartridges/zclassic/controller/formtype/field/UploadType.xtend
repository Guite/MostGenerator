package org.zikula.modulestudio.generator.cartridges.zclassic.controller.formtype.field

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class UploadType {
    extension NamingExtensions = new NamingExtensions()
    extension Utils = new Utils()

    FileHelper fh = new FileHelper()

    def generate(Application it, IFileSystemAccess fsa) {
        generateClassPair(fsa, getAppSourceLibPath + 'Form/Type/Field/UploadType.php',
            fh.phpFileContent(it, uploadTypeBaseImpl), fh.phpFileContent(it, uploadTypeImpl)
        )
    }

    def private uploadTypeBaseImpl(Application it) '''
        namespace «appNamespace»\Form\Type\Field\Base;

        use Symfony\Component\Form\AbstractType;
        use Symfony\Component\Form\FormInterface;
        use Symfony\Component\Form\FormView;
        use Symfony\Component\PropertyAccess\PropertyAccess;
        use Symfony\Component\OptionsResolver\OptionsResolver;
        use Zikula\Common\Translator\TranslatorInterface;
        use «appNamespace»\Form\DataTransformer\UploadFieldTransformer;

        /**
         * Upload field type extension base class.
         */
        class UploadType extends AbstractType
        {
            /**
             * @var TranslatorInterface
             */
            protected $translator;

            /**
             * UploadTypeExtension constructor.
             *
             * @param TranslatorInterface $translator Translator service instance
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
                $fieldName = $builder->getForm()->getConfig()->getName();

                $builder->add($fieldName, 'Symfony\Component\Form\Extension\Core\Type\FileType', $options);

                if ($options['required']) {
                    return;
                }

                $builder->add($fieldName . 'DeleteFile', 'Symfony\Component\Form\Extension\Core\Type\CheckboxType', [
                    'mapped' => false,
                    'label' => $this->translator->__('Delete existing file'),
                    'required' => false,
                    'attr' => [
                        'title' => $this->translator->__('Delete this file ?')
                    ]
                ]);
            }

            /**
             * {@inheritdoc}
             */
            public function buildView(FormView $view, FormInterface $form, array $options)
            {
                $parentData = $form->getParent()->getData();

                $view->vars['object_type'] = $parentData->get_objectType();
                $view->vars['object_id'] = $parentData->createCompositeIdentifier();

                $parentData = $form->getParent()->getData();
                $accessor = PropertyAccess::createPropertyAccessor();

                // assign basic file properties
                if (array_key_exists('file_meta', $options)) {
                    $view->vars['file_meta'] = null !== $parentData ? $accessor->getValue($parentData, $options['file_meta']) : ['isImage' => false, 'size' => 0];
                }

                if (array_key_exists('file_path', $options)) {
                    $view->vars['file_path'] = null !== $parentData ? $accessor->getValue($parentData, $options['file_path']) : null;
                }

                if (array_key_exists('file_url', $options)) {
                    $view->vars['file_url'] = null !== $parentData ? $accessor->getValue($parentData, $options['file_url']) : null;
                }

                // assign other custom options
                $view->vars['allowed_extensions'] = array_key_exists('allowed_extensions', $options) ? $options['allowed_extensions'] : '';
                $view->vars['allowed_size'] = array_key_exists('allowed_size', $options) ? $options['allowed_size'] : 0;
            }

            /**
             * {@inheritdoc}
             */
            public function configureOptions(OptionsResolver $resolver)
            {
                $resolver
                    ->setOptional(['file_meta', 'file_path', 'file_url', 'allowed_extensions', 'allowed_size'])
                    ->setDefaults([
                        'compound' => true,
                        'data_class' => null,«/* expect not a File instance */»
                        'attr' => [
                            'class' => 'file-selector'
                        ],
                        'allowed_extensions' => '',
                        'allowed_size' => 0
                    ])
                    ->setAllowedTypes([
                        «/* disabled because of #753 'file_meta' => 'array', */»'file_path' => 'string',
                        'file_url' => 'string',
                        'allowed_extensions' => 'string',
                        'allowed_size' => 'int'
                    ])
                ;
            }

            /**
             * {@inheritdoc}
             */
            public function getExtendedType()
            {
                return 'Symfony\Component\Form\Extension\Core\Type\FileType';
            }
        }
    '''

    def private uploadTypeImpl(Application it) '''
        namespace «appNamespace»\Form\Type\Field;

        use «appNamespace»\Form\Type\Field\Base\UploadType as BaseUploadType;

        /**
         * Upload field type implementation class.
         */
        class UploadType extends BaseUploadType
        {
            // feel free to add your customisation here
        }
    '''
}
