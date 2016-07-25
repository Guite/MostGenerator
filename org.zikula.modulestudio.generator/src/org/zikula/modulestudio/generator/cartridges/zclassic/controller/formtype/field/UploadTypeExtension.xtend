package org.zikula.modulestudio.generator.cartridges.zclassic.controller.formtype.field

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class UploadTypeExtension {
    extension NamingExtensions = new NamingExtensions()
    extension Utils = new Utils()

    FileHelper fh = new FileHelper()

    def generate(Application it, IFileSystemAccess fsa) {
        generateClassPair(fsa, getAppSourceLibPath + 'Form/Extension/UploadTypeExtension.php',
            fh.phpFileContent(it, uploadTypeExtensionBaseImpl), fh.phpFileContent(it, uploadTypeExtensionImpl)
        )
    }

    def private uploadTypeExtensionBaseImpl(Application it) '''
        namespace «appNamespace»\Form\Extension\Base;

        use Symfony\Component\Form\AbstractTypeExtension;
        use Symfony\Component\Form\FormBuilderInterface;
        use Symfony\Component\Form\FormInterface;
        use Symfony\Component\Form\FormView;
        use Symfony\Component\PropertyAccess\PropertyAccess;
        use Symfony\Component\OptionsResolver\OptionsResolver;
        use Zikula\Common\Translator\TranslatorInterface;

        /**
         * File field type extension base class.
         */
        class UploadTypeExtension extends AbstractTypeExtension
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
                if ($options['mandatory']) {
                    return;
                }

                $builder->add($options['attr']['id'] . 'DeleteFile', 'Symfony\Component\Form\Extension\Core\Type\CheckboxType', [
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
                    $view->vars['file_meta'] = null !== $parentData ? $accessor->getValue($parentData, $options['file_meta']) : null;
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

    def private uploadTypeExtensionImpl(Application it) '''
        namespace «appNamespace»\Form\Extension;

        use «appNamespace»\Form\Extension\Base\UploadTypeExtension as BaseUploadTypeExtension;

        /**
         * File field type extension implementation class.
         */
        class UploadTypeExtension extends BaseUploadTypeExtension
        {
            // feel free to add your customisation here
        }
    '''
}
