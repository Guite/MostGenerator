package org.zikula.modulestudio.generator.cartridges.zclassic.controller.formtype.field

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.UploadNamingScheme
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class UploadType {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension Utils = new Utils

    def generate(Application it, IMostFileSystemAccess fsa) {
        fsa.generateClassPair('Form/Type/Field/UploadType.php', uploadTypeBaseImpl, uploadTypeImpl)
    }

    def private uploadTypeBaseImpl(Application it) '''
        namespace «appNamespace»\Form\Type\Field\Base;

        use Symfony\Component\Form\AbstractType;
        use Symfony\Component\Form\Extension\Core\Type\CheckboxType;
        use Symfony\Component\Form\Extension\Core\Type\FileType;
        «IF hasUploadNamingScheme(UploadNamingScheme.USERDEFINEDWITHCOUNTER)»
            use Symfony\Component\Form\Extension\Core\Type\TextType;
        «ENDIF»
        use Symfony\Component\Form\FormBuilderInterface;
        use Symfony\Component\Form\FormInterface;
        use Symfony\Component\Form\FormView;
        use Symfony\Component\HttpFoundation\File\File;
        use Symfony\Component\OptionsResolver\OptionsResolver;
        use Symfony\Component\PropertyAccess\PropertyAccess;
        «IF !targets('3.0')»
            use Zikula\Common\Translator\TranslatorInterface;
        «ENDIF»
        use «appNamespace»\Form\DataTransformer\UploadFileTransformer;
        use «appNamespace»\Helper\ImageHelper;
        use «appNamespace»\Helper\UploadHelper;

        /**
         * Upload field type base class.
         */
        abstract class AbstractUploadType extends AbstractType
        {
            «IF !targets('3.0')»
                /**
                 * @var TranslatorInterface
                 */
                protected $translator;

            «ENDIF»
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

            public function __construct(
                «IF !targets('3.0')»
                    TranslatorInterface $translator,
                «ENDIF»
                ImageHelper $imageHelper,
                UploadHelper $uploadHelper
            ) {
                «IF !targets('3.0')»
                    $this->translator = $translator;
                «ENDIF»
                $this->imageHelper = $imageHelper;
                $this->uploadHelper = $uploadHelper;
            }

            public function buildForm(FormBuilderInterface $builder, array $options)
            {
                $options['compound'] = false;
                $fieldName = $builder->getName();

                $this->entity = $options['entity'];
                $this->formBuilder = $builder;

                $fileOptions = [];
                foreach ($options as $optionName => $optionValue) {
                    if (in_array($optionName, ['entity', 'allow_deletion', 'allowed_extensions', 'allowed_size'])) {
                        continue;
                    }
                    $fileOptions[$optionName] = $optionValue;
                }
                $fileOptions['attr']['class'] = 'validate-upload';

                $builder->add($fieldName, FileType::class, $fileOptions);
                $uploadFileTransformer = new UploadFileTransformer($this->entity, $this->uploadHelper, $fieldName«IF hasUploadNamingScheme(UploadNamingScheme.USERDEFINEDWITHCOUNTER)», $options['custom_filename']«ENDIF»);
                $builder->addModelTransformer($uploadFileTransformer);

                if ($options['allow_deletion'] && !$options['required']) {
                    $builder->add($fieldName . 'DeleteFile', CheckboxType::class, [
                        'label' => «IF !targets('3.0')»$this->translator->__(«ENDIF»'Delete existing file'«IF !targets('3.0')»)«ENDIF»,
                        «IF targets('3.0')»
                            'label_attr' => [
                                'class' => 'switch-custom'
                            ],
                        «ENDIF»
                        'required' => false,
                        'attr' => [
                            'title' => «IF !targets('3.0')»$this->translator->__(«ENDIF»'Delete this file ?'«IF !targets('3.0')»)«ENDIF»
                        ]
                    ]);
                }
                «IF hasUploadNamingScheme(UploadNamingScheme.USERDEFINEDWITHCOUNTER)»

                    if (true === $options['custom_filename']) {
                        $builder->add($fieldName . 'CustomFileName', TextType::class, [
                            'label' => «IF !targets('3.0')»$this->translator->__(«ENDIF»'Custom file name'«IF !targets('3.0')»)«ENDIF»,
                            'required' => false,
                            'attr' => [
                                'title' => «IF !targets('3.0')»$this->translator->__(«ENDIF»'Optionally enter a custom file name (without extension)'«IF !targets('3.0')»)«ENDIF»
                            ],
                            'help' => «IF !targets('3.0')»$this->translator->__(«ENDIF»'Optionally enter a custom file name (without extension)'«IF !targets('3.0')»)«ENDIF»
                        ]);
                    }
                «ENDIF»
            }

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
                $hasFile = null !== $file && $file instanceof File;
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
                $view->vars['allow_deletion'] = array_key_exists('allow_deletion', $options)
                    ? $options['allow_deletion']
                    : false
                ;
                $view->vars['allowed_extensions'] = array_key_exists('allowed_extensions', $options)
                    ? $options['allowed_extensions']
                    : ''
                ;
                $view->vars['allowed_size'] = array_key_exists('allowed_size', $options)
                    ? $options['allowed_size']
                    : 0
                ;
                $view->vars['thumb_runtime_options'] = null;

                if (true === $fileMeta['isImage']) {
                    $view->vars['thumb_runtime_options'] = $this->imageHelper->getRuntimeOptions(
                        $this->entity->get_objectType(),
                        $fieldName,
                        'controllerAction',
                        ['action' => 'edit']
                    );
                }
                «IF hasUploadNamingScheme(UploadNamingScheme.USERDEFINEDWITHCOUNTER)»

                    $view->vars['has_custom_filename'] = $options['custom_filename'];
                «ENDIF»
            }

            public function configureOptions(OptionsResolver $resolver)
            {
                $resolver
                    ->setRequired(['entity'])
                    ->setDefined(['allow_deletion', 'allowed_extensions', 'allowed_size'«IF hasUploadNamingScheme(UploadNamingScheme.USERDEFINEDWITHCOUNTER)», 'custom_filename'«ENDIF»])
                    ->setDefaults([
                        'attr' => [
                            'class' => 'file-selector'
                        ],
                        'allow_deletion' => false,
                        'allowed_extensions' => '',
                        'allowed_size' => '',
                        «IF hasUploadNamingScheme(UploadNamingScheme.USERDEFINEDWITHCOUNTER)»
                            'custom_filename' => false,
                        «ENDIF»
                        'error_bubbling' => false«IF targets('2.0')»,
                        'allow_file_upload' => true«ENDIF»
                    ])
                    ->setAllowedTypes('allow_deletion', 'bool')
                    ->setAllowedTypes('allowed_extensions', 'string')
                    ->setAllowedTypes('allowed_size', 'string')
                    «IF hasUploadNamingScheme(UploadNamingScheme.USERDEFINEDWITHCOUNTER)»
                        ->setAllowedTypes('custom_filename', 'bool')
                    «ENDIF»
                ;
            }

            «new FileHelper(it).getterMethod(null, 'formBuilder', 'FormBuilderInterface', false, false, targets('3.0'))»
            «new FileHelper(it).getterMethod(null, 'entity', 'object', false, false, targets('3.0'))»
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
