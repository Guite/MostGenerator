package org.zikula.modulestudio.generator.cartridges.zclassic.controller.formtype.field

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class UploadType {
    extension FormattingExtensions = new FormattingExtensions()
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
        use Symfony\Component\Form\FormBuilderInterface;
        use Symfony\Component\Form\FormInterface;
        use Symfony\Component\Form\FormView;
        use Symfony\Component\OptionsResolver\OptionsResolver;
        use Symfony\Component\PropertyAccess\PropertyAccess;
        use Zikula\Common\Translator\TranslatorInterface;

        /**
         * Upload field type extension base class.
         */
        abstract class AbstractUploadType extends AbstractType
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

                $fileOptions = [];
                foreach ($options as $k => $v) {
                    if (in_array($k, ['allowed_extensions', 'allowed_size'])) {
                        continue;
                    }
                    $fileOptions[$k] = $v;
                }
                $fileOptions['attr']['class'] = 'validate-upload';

                $builder->add($fieldName, 'Symfony\Component\Form\Extension\Core\Type\FileType', $fileOptions);

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
                $fieldName = $form->getConfig()->getName();
                $parentData = $form->getParent()->getData();

                $view->vars['object_type'] = $parentData->get_objectType();
                $view->vars['object_id'] = $parentData->createCompositeIdentifier();
                $view->vars['formattedEntityTitle'] = $parentData->getTitleFromDisplayPattern();
                $view->vars['fieldName'] = $fieldName;

                $parentData = $form->getParent()->getData();
                $accessor = PropertyAccess::createPropertyAccessor();
                $fieldNameGetter = 'get' . ucfirst($fieldName);

                // assign basic file properties
                $fileMeta = null !== $parentData ? $accessor->getValue($parentData, $fieldNameGetter . 'Meta') : [];
                if (!isset($fileMeta['isImage'])) {
                    $fileMeta['isImage'] = false;
                }
                if (!isset($fileMeta['size'])) {
                    $fileMeta['size'] = 0;
                }
                $view->vars['file_meta'] = $fileMeta;
                $view->vars['file_path'] = null !== $parentData ? $accessor->getValue($parentData, $fieldNameGetter . 'FullPath') : null;
                $view->vars['file_url'] = null !== $parentData ? $accessor->getValue($parentData, $fieldNameGetter . 'FullPathUrl') : null;

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
                    ->setOptional(['allowed_extensions', 'allowed_size'])
                    ->setDefaults([
                        'attr' => [
                            'class' => 'file-selector'
                        ],
                        'allowed_extensions' => '',
                        'allowed_size' => 0
                    ])
                    ->setAllowedTypes([
                        'allowed_extensions' => 'string',
                        'allowed_size' => 'int'
                    ])
                ;
            }

            /**
             * {@inheritdoc}
             */
            public function getBlockPrefix()
            {
                return '«appName.formatForDB»_field_upload';
            }
        }
    '''

    def private uploadTypeImpl(Application it) '''
        namespace «appNamespace»\Form\Type\Field;

        use «appNamespace»\Form\Type\Field\Base\AbstractUploadType;

        /**
         * Upload field type implementation class.
         */
        class UploadType extends AbstractUploadType
        {
            // feel free to add your customisation here
        }
    '''
}
