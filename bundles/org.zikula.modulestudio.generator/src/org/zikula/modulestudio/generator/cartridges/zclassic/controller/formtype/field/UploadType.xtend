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

        use ServiceUtil;
        use Symfony\Component\Form\AbstractType;
        use Symfony\Component\Form\FormBuilderInterface;
        use Symfony\Component\Form\FormInterface;
        use Symfony\Component\Form\FormView;
        use Symfony\Component\HttpFoundation\File\File;
        use Symfony\Component\OptionsResolver\OptionsResolver;
        use Symfony\Component\PropertyAccess\PropertyAccess;
        use Zikula\Common\Translator\TranslatorInterface;
        use «appNamespace»\Form\DataTransformer\UploadFileTransformer;

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

                $builder->add($fieldName, 'Symfony\Component\Form\Extension\Core\Type\FileType', $fileOptions);
                $uploadFileTransformer = new UploadFileTransformer($this, $fieldName);
                $builder->get($fieldName)->addModelTransformer($uploadFileTransformer);

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

                $view->vars['object_type'] = $this->entity->get_objectType();
                $view->vars['fieldName'] = $fieldName;
                $view->vars['formattedEntityTitle'] = $this->entity->getTitleFromDisplayPattern();

                $parentData = $form->getParent()->getData();
                $accessor = PropertyAccess::createPropertyAccessor();
                $fieldNameGetter = 'get' . ucfirst($fieldName);

                // assign basic file properties
                $file = null !== $parentData ? $accessor->getValue($parentData, $fieldNameGetter) : null;
                if (null !== $file && is_string($file)) {
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
                $view->vars['file_path'] = $hasFile ? $hasFile->getPathname() : null;
                $view->vars['file_url'] = $hasFile ? $accessor->getValue($parentData, $fieldNameGetter . 'Url') : null;

                // assign other custom options
                $view->vars['allowed_extensions'] = array_key_exists('allowed_extensions', $options) ? $options['allowed_extensions'] : '';
                $view->vars['allowed_size'] = array_key_exists('allowed_size', $options) ? $options['allowed_size'] : 0;
                $view->vars['thumbRuntimeOptions'] = null;

                if (true === $fileMeta['isImage']) {
                    $imageHelper = ServiceUtil::get('«appService».image_helper');
                    $view->vars['thumbRuntimeOptions'] = $imageHelper->getRuntimeOptions($this->entity->get_objectType(), $fieldName, 'controllerAction', ['action' => 'edit']);
                }
            }

            /**
             * {@inheritdoc}
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
                        'allowed_size' => 0,
                        'error_bubbling' => false
                    ])
                    ->setAllowedTypes([
                        'allowed_extensions' => 'string',
                        'allowed_size' => 'int'
                    ])
                ;
            }

            «new FileHelper().getterMethod(null, 'formBuilder', 'FormBuilderInterface', false)»
            «new FileHelper().getterMethod(null, 'entity', 'object', false)»
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
