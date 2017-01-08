package org.zikula.modulestudio.generator.cartridges.zclassic.controller.helper

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.UploadField
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class UploadHelper {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelExtensions = new ModelExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    /**
     * Entry point for the helper class creation.
     */
    def generate(Application it, IFileSystemAccess fsa) {
        println('Generating helper class for upload handling')
        val fh = new FileHelper
        generateClassPair(fsa, getAppSourceLibPath + 'Helper/UploadHelper.php',
            fh.phpFileContent(it, uploadFunctionsBaseImpl), fh.phpFileContent(it, uploadFunctionsImpl)
        )
    }

    def private uploadFunctionsBaseImpl(Application it) '''
        namespace «appNamespace»\Helper\Base;

        use Psr\Log\LoggerInterface;
        use Symfony\Component\Filesystem\Exception\IOExceptionInterface;
        use Symfony\Component\Filesystem\Filesystem;
        use Symfony\Component\HttpFoundation\File\UploadedFile;
        use Symfony\Component\HttpFoundation\Session\SessionInterface;
        use Zikula\Common\Translator\TranslatorInterface;
        use Zikula\Common\Translator\TranslatorTrait;
        use Zikula\ExtensionsModule\Api\VariableApi;
        use Zikula\UsersModule\Api\CurrentUserApi;

        /**
         * Helper base class for upload handling.
         */
        abstract class AbstractUploadHelper
        {
            use TranslatorTrait;

            /**
             * @var SessionInterface
             */
            protected $session;

            /**
             * @var LoggerInterface
             */
            protected $logger;

            /**
             * @var CurrentUserApi
             */
            protected $currentUserApi;

            /**
             * @var VariableApi
             */
            protected $variableApi;

            /**
             * @var ControllerHelper
             */
            protected $controllerHelper;

            /**
             * @var array List of object types with upload fields
             */
            protected $allowedObjectTypes;

            /**
             * @var array List of file types to be considered as images
             */
            protected $imageFileTypes;

            /**
             * @var array List of dangerous file types to be rejected
             */
            protected $forbiddenFileTypes;

            /**
             * UploadHelper constructor.
             *
             * @param TranslatorInterface $translator       Translator service instance
             * @param SessionInterface    $session          Session service instance
             * @param LoggerInterface     $logger           Logger service instance
             * @param CurrentUserApi      $currentUserApi   CurrentUserApi service instance
             * @param VariableApi         $variableApi      VariableApi service instance
             * @param ControllerHelper    $controllerHelper ControllerHelper service instance
             */
            public function __construct(
                TranslatorInterface $translator,
                SessionInterface $session,
                LoggerInterface $logger,
                CurrentUserApi $currentUserApi,
                VariableApi $variableApi,
                ControllerHelper $controllerHelper)
            {
                $this->setTranslator($translator);
                $this->session = $session;
                $this->logger = $logger;
                $this->currentUserApi = $currentUserApi;
                $this->variableApi = $variableApi;
                $this->controllerHelper = $controllerHelper;

                $this->allowedObjectTypes = [«FOR entity : getUploadEntities SEPARATOR ', '»'«entity.name.formatForCode»'«ENDFOR»];
                $this->imageFileTypes = ['gif', 'jpeg', 'jpg', 'png', 'swf'];
                $this->forbiddenFileTypes = ['cgi', 'pl', 'asp', 'phtml', 'php', 'php3', 'php4', 'php5', 'exe', 'com', 'bat', 'jsp', 'cfm', 'shtml'];
            }

            «setTranslatorMethod»

            «performFileUpload»

            «validateFileUpload»

            «readMetaDataForFile»

            «isAllowedFileExtension»

            «determineFileName»

            «deleteUploadFile»
        }
    '''

    def private performFileUpload(Application it) '''
        /**
         * Process a file upload.
         *
         * @param string       $objectType Currently treated entity type
         * @param UploadedFile $file       The uploaded file
         * @param string       $fieldName  Name of upload field
         *
         * @return array Resulting file name and collected meta data
         */
        public function performFileUpload($objectType, $file, $fieldName)
        {
            $result = [
                'fileName' => '',
                'metaData' => []
            ];

            // check whether uploads are allowed for the given object type
            if (!in_array($objectType, $this->allowedObjectTypes)) {
                return $result;
            }

            // perform validation
            try {
                $this->validateFileUpload($objectType, $file, $fieldName);
            } catch (\Exception $e) {
                // skip this upload field
                return $result;
            }

            // build the file name
            $fileName = $file->getClientOriginalName();
            $fileNameParts = explode('.', $fileName);
            $extension = null !== $file->guessExtension() ? $file->guessExtension() : $file->guessClientExtension();
            if (null === $extension) {
                $extension = strtolower($fileNameParts[count($fileNameParts) - 1]);
            }
            $extension = str_replace('jpeg', 'jpg', $extension);
            $fileNameParts[count($fileNameParts) - 1] = $extension;
            $fileName = implode('.', $fileNameParts);

            $flashBag = $this->session->getFlashBag();

            // retrieve the final file name
            try {
                $basePath = $this->controllerHelper->getFileBaseFolder($objectType, $fieldName);
            } catch (\Exception $e) {
                $flashBag->add('error', $e->getMessage());
                $this->logger->error('{app}: User {user} could not detect upload destination path for entity {entity} and field {field}.', ['app' => '«appName»', 'user' => $this->currentUserApi->get('uname'), 'entity' => $objectType, 'field' => $fieldName]);

                return false;
            }
            $fileName = $this->determineFileName($objectType, $fieldName, $basePath, $fileName, $extension);

            $destinationFilePath = $basePath . $fileName;
            $targetFile = $file->move($basePath, $fileName);

            «doFileValidation('$destinationFilePath')»

            $isImage = in_array($extension, $this->imageFileTypes);
            if ($isImage) {
                // check if shrinking functionality is enabled
                $fieldSuffix = ucfirst($objectType) . ucfirst($fieldName);
                if (true === $this->variableApi->get('«appName»', 'enableShrinkingFor' . $fieldSuffix, false)) {
                    // check for maximum size
                    $maxWidth = $this->variableApi->get('«appName»', 'shrinkWidth' . $fieldSuffix, 800);
                    $maxHeight = $this->variableApi->get('«appName»', 'shrinkHeight' . $fieldSuffix, 600);

                    $imgInfo = getimagesize($destinationFilePath);
                    if ($imgInfo[0] > $maxWidth || $imgInfo[1] > $maxHeight) {
                        // resize to allowed maximum size
                        $thumbManager = $serviceManager->get('systemplugin.imagine.manager');
                        $preset = new \SystemPlugin_Imagine_Preset('«appName»_Shrinker', [
                            'width' => $maxWidth,
                            'height' => $maxHeight,
                            'mode' => 'inset'
                        ]);
                        $thumbManager->setPreset($preset);

                        // create thumbnail image
                        $thumbFilePath = $thumbManager->getThumb($destinationFilePath, $maxWidth, $maxHeight);

                        // remove original image
                        unlink($destinationFilePath);

                        // rename thumbnail image to original image
                        rename($thumbFilePath, $destinationFilePath);
                    }
                }
            }

            // collect data to return
            $result['fileName'] = $fileName;
            $result['metaData'] = $this->readMetaDataForFile($fileName, $destinationFilePath);

            return $result;
        }
    '''

    def private validateFileUpload(Application it) '''
        /**
         * Check if an upload file meets all validation criteria.
         *
         * @param string       $objectType Currently treated entity type
         * @param UploadedFile $file       Reference to data of uploaded file
         * @param string       $fieldName  Name of upload field
         *
         * @return boolean true if file is valid else false
         */
        protected function validateFileUpload($objectType, $file, $fieldName)
        {
            $flashBag = $this->session->getFlashBag();

            // check if a file has been uploaded properly without errors
            if ($file->getError() != UPLOAD_ERR_OK) {
                $flashBag->add('error', $file->getErrorMessage());
                $this->logger->error('{app}: User {user} tried to upload a file with errors: ' . $file->getErrorMessage(), ['app' => '«appName»', 'user' => $this->currentUserApi->get('uname')]);

                return false;
            }

            // extract file extension
            $fileName = $file->getClientOriginalName();
            $extension = null !== $file->guessExtension() ? $file->guessExtension() : $file->guessClientExtension();
            if (null === $extension) {
                $fileNameParts = explode('.', $fileName);
                $extension = strtolower($fileNameParts[count($fileNameParts) - 1]);
            }
            $extension = str_replace('jpeg', 'jpg', $extension);

            // validate extension
            $isValidExtension = $this->isAllowedFileExtension($objectType, $fieldName, $extension);
            if (false === $isValidExtension) {
                $flashBag->add('error', $this->__('Error! This file type is not allowed. Please choose another file format.'));
                $this->logger->error('{app}: User {user} tried to upload a file with a forbidden extension ("{extension}").', ['app' => '«appName»', 'user' => $this->currentUserApi->get('uname'), 'extension' => $extension]);

                return false;
            }

            return true;
        }
    '''

    def private doFileValidation(Application it, String fileVar) '''
        // validate image file
        $isImage = in_array($extension, $this->imageFileTypes);
        if ($isImage) {
            $imgInfo = getimagesize(«fileVar»);
            if (!is_array($imgInfo) || !$imgInfo[0] || !$imgInfo[1]) {
                $flashBag->add('error', $this->__('Error! This file type seems not to be a valid image.'));
                $this->logger->error('{app}: User {user} tried to upload a file which is seems not to be a valid image.', ['app' => '«appName»', 'user' => $this->currentUserApi->get('uname')]);

                return false;
            }
        }
    '''

    def private readMetaDataForFile(Application it) '''
        /**
         * Read meta data from a certain file.
         *
         * @param string $fileName  Name of file to be processed
         * @param string $filePath  Path to file to be processed
         *
         * @return array collected meta data
         */
        public function readMetaDataForFile($fileName, $filePath)
        {
            $meta = [];
            if (empty($fileName)) {
                return $meta;
            }

            $extensionarr = explode('.', $fileName);
            $meta['extension'] = strtolower($extensionarr[count($extensionarr) - 1]);
            $meta['size'] = filesize($filePath);
            $meta['isImage'] = in_array($meta['extension'], $this->imageFileTypes) ? true : false;

            if (!$meta['isImage']) {
                return $meta;
            }

            if ($meta['extension'] == 'swf') {
                $meta['isImage'] = false;
            }

            $imgInfo = getimagesize($filePath);
            if (!is_array($imgInfo)) {
                return $meta;
            }

            $meta['width'] = $imgInfo[0];
            $meta['height'] = $imgInfo[1];

            if ($imgInfo[1] < $imgInfo[0]) {
                $meta['format'] = 'landscape';
            } elseif ($imgInfo[1] > $imgInfo[0]) {
                $meta['format'] = 'portrait';
            } else {
                $meta['format'] = 'square';
            }

            return $meta;
        }
    '''

    def private isAllowedFileExtension(Application it) '''
        /**
         * Determines the allowed file extensions for a given object type.
         *
         * @param string $objectType Currently treated entity type
         * @param string $fieldName  Name of upload field
         * @param string $extension  Input file extension
         *
         * @return array the list of allowed file extensions
         */
        protected function isAllowedFileExtension($objectType, $fieldName, $extension)
        {
            // determine the allowed extensions
            $allowedExtensions = [];
            switch ($objectType) {
                «FOR entity : getUploadEntities.filter(Entity)»«entity.isAllowedFileExtensionEntityCase»«ENDFOR»
            }

            if (count($allowedExtensions) > 0) {
                if (!in_array($extension, $allowedExtensions)) {
                    return false;
                }
            }

            if (in_array($extension, $this->forbiddenFileTypes)) {
                return false;
            }

            return true;
        }
    '''

    def private isAllowedFileExtensionEntityCase(Entity it) '''
        «val uploadFields = getUploadFieldsEntity»
        case '«name.formatForCode»':
            «IF uploadFields.size > 1»
                switch ($fieldName) {
                    «FOR uploadField : uploadFields»«uploadField.isAllowedFileExtensionFieldCase»«ENDFOR»
                }
            «ELSE»
                $allowedExtensions = ['«uploadFields.head.allowedExtensions.replace(', ', "', '")»'];
            «ENDIF»
                break;
    '''

    def private isAllowedFileExtensionFieldCase(UploadField it) '''
        case '«name.formatForCode»':
            $allowedExtensions = ['«allowedExtensions.replace(', ', "', '")»'];
            break;
    '''

    def private determineFileName(Application it) '''
        /**
         * Determines the final filename for a given input filename.
         *
         * It considers different strategies for computing the result.
         *
         * @param string $objectType Currently treated entity type
         * @param string $fieldName  Name of upload field
         * @param string $basePath   Base path for file storage
         * @param string $fileName   Input file name
         * @param string $extension  Input file extension
         *
         * @return string the resulting file name
         */
        protected function determineFileName($objectType, $fieldName, $basePath, $fileName, $extension)
        {
            $backupFileName = $fileName;

            $namingScheme = 0;

            switch ($objectType) {
                «FOR entity : getUploadEntities.filter(Entity)»«entity.determineFileNameEntityCase»«ENDFOR»
            }


            $iterIndex = -1;
            do {
                if ($namingScheme == 0) {
                    // original file name
                    $fileNameCharCount = strlen($fileName);
                    for ($y = 0; $y < $fileNameCharCount; $y++) {
                        if (preg_match('/[^0-9A-Za-z_\.]/', $fileName[$y])) {
                            $fileName[$y] = '_';
                        }
                    }
                    // append incremented number
                    if ($iterIndex > 0) {
                        // strip off extension
                        $fileName = str_replace('.' . $extension, '', $backupFileName);
                        // add iterated number
                        $fileName .= (string) ++$iterIndex;
                        // readd extension
                        $fileName .= '.' . $extension;
                    } else {
                        $iterIndex++;
                    }
                } elseif ($namingScheme == 1) {
                    // md5 name
                    $fileName = md5(uniqid(mt_rand(), TRUE)) . '.' . $extension;
                } elseif ($namingScheme == 2) {
                    // prefix with random number
                    $fileName = $fieldName . mt_rand(1, 999999) . '.' . $extension;
                }
            }
            while (file_exists($basePath . $fileName)); // repeat until we have a new name

            // return the new file name
            return $fileName;
        }
    '''

    def private determineFileNameEntityCase(Entity it) '''
        «val uploadFields = getUploadFieldsEntity»
        case '«name.formatForCode»':
            «IF uploadFields.size > 1»
                switch ($fieldName) {
                    «FOR uploadField : uploadFields»«uploadField.determineFileNameFieldCase»«ENDFOR»
                }
            «ELSE»
                $namingScheme = «uploadFields.head.namingScheme.value»;
            «ENDIF»
                break;
    '''

    def private determineFileNameFieldCase(UploadField it) '''
        case '«name.formatForCode»':
            $namingScheme = «it.namingScheme.value»;
            break;
    '''

    def private deleteUploadFile(Application it) '''
        /**
         * Deletes an existing upload file.
         * For images the thumbnails are removed, too.
         *
         * @param object  $entity    Currently treated entity
         * @param string  $fieldName Name of upload field
         *
         * @return mixed Updated entity on success, else false
         */
        public function deleteUploadFile($entity, $fieldName)
        {
            $objectType = $entity->get_objectType();
            if (!in_array($objectType, $this->allowedObjectTypes)) {
                return false;
            }

            if (empty($entity[$fieldName])) {
                return $entity;
            }

            // remove the file
            if (is_array($entity[$fieldName]) && isset($entity[$fieldName][$fieldName])) {
                $entity[$fieldName] = $entity[$fieldName][$fieldName];
            }
            if (is_object($entity[$fieldName])) {
                $filePath = $entity[$fieldName]->getPathname();
                if (file_exists($filePath) && !unlink($filePath)) {
                    return false;
                }
            }

            $entity[$fieldName] = null;
            $entity[$fieldName . 'Meta'] = [];
            $entity[$fieldName . 'Url'] = '';

            return $entity;
        }
    '''

    def private uploadFunctionsImpl(Application it) '''
        namespace «appNamespace»\Helper;

        use «appNamespace»\Helper\Base\AbstractUploadHelper;

        /**
         * Helper implementation class for upload handling.
         */
        class UploadHelper extends AbstractUploadHelper
        {
            // feel free to add your own convenience methods here
        }
    '''
}
