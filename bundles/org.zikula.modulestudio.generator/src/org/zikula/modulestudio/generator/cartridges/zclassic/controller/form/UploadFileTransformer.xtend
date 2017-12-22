package org.zikula.modulestudio.generator.cartridges.zclassic.controller.form

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.UploadNamingScheme
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class UploadFileTransformer {

    extension ModelExtensions = new ModelExtensions
    extension Utils = new Utils

    def generate(Application it, IMostFileSystemAccess fsa) {
        fsa.generateClassPair('Form/DataTransformer/UploadFileTransformer.php', transformerBaseImpl, transformerImpl)
    }

    def private transformerBaseImpl(Application it) '''
        namespace «appNamespace»\Form\DataTransformer\Base;

        use Symfony\Component\Form\DataTransformerInterface;
        use Symfony\Component\HttpFoundation\File\File;
        use Symfony\Component\HttpFoundation\File\UploadedFile;
        use Symfony\Component\HttpFoundation\Request;
        use Symfony\Component\HttpFoundation\RequestStack;
        use «appNamespace»\Form\Type\Field\UploadType;
        use «appNamespace»\Helper\UploadHelper;

        /**
         * Upload file transformer base class.
         *
         * This data transformer treats uploaded files.
         */
        abstract class AbstractUploadFileTransformer implements DataTransformerInterface
        {
            /**
             * @var UploadType
             */
            protected $formType = '';

            /**
             * @var Request
             */
            protected $request = '';

            /**
             * @var UploadHelper
             */
            protected $uploadHelper = '';

            /**
             * @var string
             */
            protected $fieldName = '';
            «IF hasUploadNamingScheme(UploadNamingScheme.USERDEFINEDWITHCOUNTER)»

                /**
                 * @var boolean
                 */
                protected $supportCustomFileName = false;
            «ENDIF»

            /**
             * UploadFileTransformer constructor.
             *
             * @param UploadType   $formType     The form type containing this transformer
             * @param RequestStack $requestStack RequestStack service instance
             * @param UploadHelper $uploadHelper UploadHelper service instance
             * @param string       $fieldName    The form field name
             «IF hasUploadNamingScheme(UploadNamingScheme.USERDEFINEDWITHCOUNTER)»
             * @param boolean      $customName   Whether a custom file name is supported or not
             «ENDIF»
             */
            public function __construct(UploadType $formType, RequestStack $requestStack, UploadHelper $uploadHelper, $fieldName = ''«IF hasUploadNamingScheme(UploadNamingScheme.USERDEFINEDWITHCOUNTER)», $customName = false«ENDIF»)
            {
                $this->formType = $formType;
                $this->request = $requestStack->getCurrentRequest();
                $this->uploadHelper = $uploadHelper;
                $this->fieldName = $fieldName;
                «IF hasUploadNamingScheme(UploadNamingScheme.USERDEFINEDWITHCOUNTER)»
                    $this->supportCustomFileName = $customName;
                «ENDIF»
            }

            /**
             * Transforms a filename to the corresponding file object.
             *
             * @param string|File|null $filePath
             *
             * @return File|null
             */
            public function transform($filePath)
            {
                if (empty($filePath)) {
                    return null;
                }
                if ($filePath instanceof File) {
                    return $filePath;
                }

                return [$this->fieldName => new File($filePath)];
            }

            /**
             * Transforms an uploaded file back to the filename string.
             *
             * @param mixed $data Uploaded file or parent object (if file deletion checkbox has been provided)
             *
             * @return string
             */
            public function reverseTransform($data)
            {
                $deleteFile = false;
                $uploadedFile = null;
                «IF hasUploadNamingScheme(UploadNamingScheme.USERDEFINEDWITHCOUNTER)»
                    $customFileName = '';
                «ENDIF»

                if ($data instanceof UploadedFile) {
                    // no file deletion checkbox has been provided
                    $uploadedFile = $data;
                } else {
                    $children = $this->formType->getFormBuilder()->all();
                    foreach ($children as $child) {
                        $childForm = $child->getForm();
                        «IF hasUploadNamingScheme(UploadNamingScheme.USERDEFINEDWITHCOUNTER)»
                            if (true === $this->supportCustomFileName && false !== strpos($childForm->getName(), 'CustomFileName')) {
                                $customFileName = $childForm->getData();
                                continue;
                            }
                        «ENDIF»
                        if (false !== strpos($childForm->getName(), 'DeleteFile')) {
                            //$deleteFile = $childForm->getData();
                            foreach ($_POST as $k => $v) {
                                if (!is_array($v)) {
                                    continue;
                                }
                                foreach ($v as $field => $value) {
                                    if ($field != str_replace('DeleteFile', '', $childForm->getName())) {
                                        continue;
                                    }
                                    $deleteFile = isset($value[$childForm->getName()]) && $value[$childForm->getName()] == '1';
                                    break 2;
                                }
                            }
                        } elseif ($childForm->getData() instanceof UploadedFile) {
                            $uploadedFile = $childForm->getData();
                        }
                    }
                }

                $entity = $this->formType->getEntity();
                $objectType = $entity->get_objectType();
                $fieldName = $this->fieldName;

                if (null === $uploadedFile) {
                    // check files array
                    $filesKey = '«appName.toLowerCase»_' . $objectType;
                    if ($this->request->files->has($filesKey)) {
                        $files = $this->request->files->get($filesKey);
                        if (isset($files[$fieldName]) && isset($files[$fieldName][$fieldName])) {
                            $uploadedFile = $files[$fieldName][$fieldName];
                        }
                    }
                }

                $oldFile = $entity[$fieldName];
                if (is_array($oldFile)) {
                    $oldFile = $oldFile[$fieldName];
                }

                // check if an existing file must be deleted
                $hasOldFile = !empty($oldFile);
                if ($hasOldFile && true === $deleteFile) {
                    // remove old upload file
                    $entity = $this->uploadHelper->deleteUploadFile($entity, $fieldName);
                }

                if (null === $uploadedFile) {
                    // no file has been uploaded
                    return $oldFile;
                }

                // new file has been uploaded; check if there is an old one to be deleted
                if ($hasOldFile && true !== $deleteFile) {
                    // remove old upload file (and image thumbnails)
                    $entity = $this->uploadHelper->deleteUploadFile($entity, $fieldName);
                }

                // do the actual upload (includes validation, physical file processing and reading meta data)
                $uploadResult = $this->uploadHelper->performFileUpload($objectType, $uploadedFile, $fieldName«IF hasUploadNamingScheme(UploadNamingScheme.USERDEFINEDWITHCOUNTER)», $customFileName«ENDIF»);

                $result = null;
                $metaData = [];
                if ($uploadResult['fileName'] != '') {
                    $result = $this->uploadHelper->getFileBaseFolder($this->formType->getEntity()->get_objectType(), $fieldName) . $uploadResult['fileName'];
                    $metaData = $uploadResult['metaData'];
                }

                // assign the upload file
                $setter = 'set' . ucfirst($fieldName);
                $entity->$setter(null !== $result ? new File($result) : $result);

                // assign the meta data
                $entity[$fieldName . 'Meta'] = $metaData;

                return $result;
            }
        }
    '''

    def private transformerImpl(Application it) '''
        namespace «appNamespace»\Form\DataTransformer;

        use «appNamespace»\Form\DataTransformer\Base\AbstractUploadFileTransformer;

        /**
         * Upload file transformer implementation class.
         *
         * This data transformer treats uploaded files.
         */
        class UploadFileTransformer extends AbstractUploadFileTransformer
        {
            // feel free to add your customisation here
        }
    '''
}
