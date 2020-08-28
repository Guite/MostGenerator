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
        «IF targets('3.0')»
            use Zikula\Bundle\CoreBundle\Doctrine\EntityAccess;
            use Zikula\Bundle\CoreBundle\HttpKernel\ZikulaHttpKernelInterface;
        «ELSE»
            use Zikula\Core\Doctrine\EntityAccess;
        «ENDIF»
        use «appNamespace»\Helper\UploadHelper;

        /**
         * Upload file transformer base class.
         *
         * This data transformer treats uploaded files.
         */
        abstract class AbstractUploadFileTransformer implements DataTransformerInterface
        {
            «IF targets('3.0')»
                /**
                 * @var ZikulaHttpKernelInterface
                 */
                protected $kernel;

            «ENDIF»
            /**
             * @var EntityAccess
             */
            protected $entity = null;

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

            public function __construct(
                «IF targets('3.0')»
                    ZikulaHttpKernelInterface $kernel,
                «ENDIF»
                EntityAccess $entity,
                UploadHelper $uploadHelper,
                $fieldName = ''«IF hasUploadNamingScheme(UploadNamingScheme.USERDEFINEDWITHCOUNTER)»,
                $customName = false«ENDIF»
            ) {
                «IF targets('3.0')»
                    $this->kernel = $kernel;
                «ENDIF»
                $this->entity = $entity;
                $this->uploadHelper = $uploadHelper;
                $this->fieldName = $fieldName;
                «IF hasUploadNamingScheme(UploadNamingScheme.USERDEFINEDWITHCOUNTER)»
                    $this->supportCustomFileName = $customName;
                «ENDIF»
            }

            /**
             * Transforms a filename to the corresponding upload input array.
             */
            public function transform($file)
            {
                return [
                    $this->fieldName => $file,
                    $this->fieldName . 'DeleteFile' => false,
                ];
            }

            /**
             * Transforms a result array back to the File object.
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
                    $uploadedFile = isset($data[$this->fieldName]) ? $data[$this->fieldName] : null;
                    $deleteFile = isset($data[$this->fieldName . 'DeleteFile'])
                        ? $data[$this->fieldName . 'DeleteFile']
                        : false
                    ;
                    «IF hasUploadNamingScheme(UploadNamingScheme.USERDEFINEDWITHCOUNTER)»
                        $customFileName = isset($data[$this->fieldName . 'CustomFileName'])
                            ? $data[$this->fieldName . 'CustomFileName']
                            : ''
                        ;
                    «ENDIF»
                }

                $entity = $this->entity;
                $objectType = $entity->get_objectType();
                $fieldName = $this->fieldName;

                $oldFile = $entity[$fieldName];

                // check if an existing file must be deleted
                $hasOldFile = !empty($oldFile);
                if ($hasOldFile && true === $deleteFile) {
                    // remove old upload file
                    $entity = $this->uploadHelper->deleteUploadFile($entity, $fieldName);
                    // set old file to empty value as the file does not exist anymore
                    $oldFile = null;
                }

                if (null === $uploadedFile || !($uploadedFile instanceof UploadedFile)) {
                    // no new file has been uploaded
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
                if ('' !== $uploadResult['fileName']) {
                    $result = $this->uploadHelper->getFileBaseFolder($objectType, $fieldName) . $uploadResult['fileName'];
                    $result = null !== $result ? new File(«IF targets('3.0')»$this->kernel->getProjectDir() . '/' . «ENDIF»$result) : $result;
                    $metaData = $uploadResult['metaData'];
                }

                // assign the meta data
                $setter = 'set' . ucfirst($fieldName) . 'Meta';
                $entity->$setter($metaData);

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
