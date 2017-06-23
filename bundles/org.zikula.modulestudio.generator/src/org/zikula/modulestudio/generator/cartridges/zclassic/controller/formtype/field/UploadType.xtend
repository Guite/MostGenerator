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
        «IF targets('1.5')»
            use Symfony\Component\Form\Extension\Core\Type\CheckboxType;
            use Symfony\Component\Form\Extension\Core\Type\FileType;
        «ENDIF»
        use Symfony\Component\Form\FormBuilderInterface;
        use Symfony\Component\Form\FormInterface;
        use Symfony\Component\Form\FormView;
        use Symfony\Component\HttpFoundation\File\File;
        use Symfony\Component\HttpFoundation\RequestStack;
        use Symfony\Component\OptionsResolver\OptionsResolver;
        use Symfony\Component\PropertyAccess\PropertyAccess;
        use Zikula\Common\Translator\TranslatorInterface;
        use «appNamespace»\Form\DataTransformer\UploadFileTransformer;
        use «appNamespace»\Helper\ImageHelper;
        use «appNamespace»\Helper\UploadHelper;

        /**
         * Upload field type base class.
         */
        abstract class AbstractUploadType extends AbstractType
        {
            /**
             * @var TranslatorInterface
             */
            protected $translator;

            /**
             * @var RequestStack
             */
            protected $requestStack = '';

            /**
             * @var ImageHelper
             */
            protected $imageHelper;

            /**
             * @var UploadHelper
             */
            protected $uploadHelper = '';

            /**
             * @var FormBuilderInterface
             */
            protected $formBuilder = null;

            /**
             * @var object
             */
            protected $entity = null;

            /**
             * UploadTypeExtension constructor.
             *
             * @param TranslatorInterface $translator   Translator service instance
             * @param RequestStack        $requestStack RequestStack service instance
             * @param ImageHelper         $imageHelper  ImageHelper service instance
             * @param UploadHelper        $uploadHelper UploadHelper service instance
             */
            public function __construct(TranslatorInterface $translator, RequestStack $requestStack, ImageHelper $imageHelper, UploadHelper $uploadHelper)
            {
                $this->translator = $translator;
                $this->requestStack = $requestStack;
                $this->imageHelper = $imageHelper;
                $this->uploadHelper = $uploadHelper;
            }

            /**
             * @inheritDoc
             */
            public function buildForm(FormBuilderInterface $builder, array $options)
            {
                $options['compound'] = false;
                $fieldName = $builder->getName();

                $this->entity = $options['entity'];
                $this->formBuilder = $builder;

                $fileOptions = [];
                foreach ($options as $optionName => $optionValue) {
                    if (in_array($optionName, ['entity', 'allowed_extensions', 'allowed_size'])) {
                        continue;
                    }
                    $fileOptions[$optionName] = $optionValue;
                }
                $fileOptions['attr']['class'] = 'validate-upload';

                $builder->add($fieldName, «IF targets('1.5')»FileType::class«ELSE»'Symfony\Component\Form\Extension\Core\Type\FileType'«ENDIF», $fileOptions);
                $uploadFileTransformer = new UploadFileTransformer($this, $this->requestStack, $this->uploadHelper, $fieldName);
                $builder->get($fieldName)->addModelTransformer($uploadFileTransformer);

                if ($options['required']) {
                    return;
                }

                $builder->add($fieldName . 'DeleteFile', «IF targets('1.5')»CheckboxType::class«ELSE»'Symfony\Component\Form\Extension\Core\Type\CheckboxType'«ENDIF», [
                    'mapped' => false,
                    'label' => $this->translator->__('Delete existing file'),
                    'required' => false,
                    'attr' => [
                        'title' => $this->translator->__('Delete this file ?')
                    ]
                ]);
            }

            /**
             * @inheritDoc
             */
            public function buildView(FormView $view, FormInterface $form, array $options)
            {
                $fieldName = $form->getConfig()->getName();

                $view->vars['object_type'] = $this->entity->get_objectType();
                $view->vars['field_name'] = $fieldName;
                $view->vars['edited_entity'] = $this->entity;

                $parentData = $form->getParent()->getData();
                $accessor = PropertyAccess::createPropertyAccessor();
                $fieldNameGetter = 'get' . ucfirst($fieldName);

                // assign basic file properties
                $file = null !== $parentData ? $accessor->getValue($parentData, $fieldNameGetter) : null;
                if (null !== $file && is_array($file)) {
                    $file = $file[$fieldName];
                }
                if (null !== $file && is_string($file)) {
                    if (false === strpos($file, '/')) {
                        $file = $this->uploadHelper->getFileBaseFolder($this->entity->get_objectType(), $fieldName) . $file;
                    }
                    $file = new File($file);
                }
                $hasFile = null !== $file;
                $fileMeta = $hasFile ? $accessor->getValue($parentData, $fieldNameGetter . 'Meta') : [];
                if (!isset($fileMeta['isImage'])) {
                    $fileMeta['isImage'] = false;
                }
                if (!isset($fileMeta['size'])) {
                    $fileMeta['size'] = 0;
                }
                $view->vars['file_meta'] = $fileMeta;
                $view->vars['file_path'] = $hasFile ? $file->getPathname() : null;
                $view->vars['file_url'] = $hasFile ? $accessor->getValue($parentData, $fieldNameGetter . 'Url') : null;

                // assign other custom options
                $view->vars['allowed_extensions'] = array_key_exists('allowed_extensions', $options) ? $options['allowed_extensions'] : '';
                $view->vars['allowed_size'] = array_key_exists('allowed_size', $options) ? $options['allowed_size'] : 0;
                $view->vars['thumb_runtime_options'] = null;

                if (true === $fileMeta['isImage']) {
                    $view->vars['thumb_runtime_options'] = $this->imageHelper->getRuntimeOptions($this->entity->get_objectType(), $fieldName, 'controllerAction', ['action' => 'edit']);
                }
            }

            /**
             * @inheritDoc
             */
            public function configureOptions(OptionsResolver $resolver)
            {
                $resolver
                    ->setRequired(['entity'])
                    ->setOptional(['allowed_extensions', 'allowed_size'])
                    ->setDefaults([
                        'attr' => [
                            'class' => 'file-selector'
                        ],
                        'allowed_extensions' => '',
                        'allowed_size' => '',
                        'error_bubbling' => false
                    ])
                    ->setAllowedTypes('allowed_extensions', 'string')
                    ->setAllowedTypes('allowed_size', 'string')
                ;
            }

            «new FileHelper().getterMethod(null, 'formBuilder', 'FormBuilderInterface', false)»
            «new FileHelper().getterMethod(null, 'entity', 'object', false)»
            /**
             * @inheritDoc
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
