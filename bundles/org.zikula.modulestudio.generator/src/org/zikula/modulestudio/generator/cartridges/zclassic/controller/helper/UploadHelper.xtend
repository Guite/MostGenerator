package org.zikula.modulestudio.generator.cartridges.zclassic.controller.helper

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.UploadField
import de.guite.modulestudio.metamodel.UploadNamingScheme
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
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
    def generate(Application it, IMostFileSystemAccess fsa) {
        'Generating helper class for upload handling'.printIfNotTesting(fsa)
        fsa.generateClassPair('Helper/UploadHelper.php', uploadFunctionsBaseImpl, uploadFunctionsImpl)
    }

    def private uploadFunctionsBaseImpl(Application it) '''
        namespace «appNamespace»\Helper\Base;

        use Imagine\Filter\Basic\Autorotate;
        use Imagine\Gd\Imagine;
        use Imagine\Image\Box;
        use Imagine\Image\ImageInterface;
        use Imagine\Image\Metadata\ExifMetadataReader;
        use Psr\Log\LoggerInterface;
        use Symfony\Component\Filesystem\Exception\IOExceptionInterface;
        use Symfony\Component\Filesystem\Filesystem;
        use Symfony\Component\HttpFoundation\File\File;
        use Symfony\Component\HttpFoundation\File\UploadedFile;
        use Symfony\Component\HttpFoundation\Session\SessionInterface;
        use Zikula\Common\Translator\TranslatorInterface;
        use Zikula\Common\Translator\TranslatorTrait;
        use Zikula\UsersModule\Api\ApiInterface\CurrentUserApiInterface;

        /**
         * Helper base class for upload handling.
         */
        abstract class AbstractUploadHelper
        {
            «helperBaseImpl»
        }
    '''

    def private helperBaseImpl(Application it) '''
        use TranslatorTrait;

        /**
         * @var Filesystem
         */
        protected $filesystem;

        /**
         * @var SessionInterface
         */
        protected $session;

        /**
         * @var LoggerInterface
         */
        protected $logger;

        /**
         * @var CurrentUserApiInterface
         */
        protected $currentUserApi;

        /**
         * @var array
         */
        protected $moduleVars;

        /**
         * @var String
         */
        protected $dataDirectory;

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
         * @param TranslatorInterface     $translator     Translator service instance
         * @param Filesystem              $filesystem     Filesystem service instance
         * @param SessionInterface        $session        Session service instance
         * @param LoggerInterface         $logger         Logger service instance
         * @param CurrentUserApiInterface $currentUserApi CurrentUserApi service instance
         * @param object                  $moduleVars     Existing module vars
         * @param String                  $dataDirectory  The data directory name
         */
        public function __construct(
            TranslatorInterface $translator,
            Filesystem $filesystem,
            SessionInterface $session,
            LoggerInterface $logger,
            CurrentUserApiInterface $currentUserApi,
            $moduleVars,
            $dataDirectory
        ) {
            $this->setTranslator($translator);
            $this->filesystem = $filesystem;
            $this->session = $session;
            $this->logger = $logger;
            $this->currentUserApi = $currentUserApi;
            $this->moduleVars = $moduleVars;
            $this->dataDirectory = $dataDirectory;

            $this->allowedObjectTypes = [«FOR entity : getUploadEntities SEPARATOR ', '»'«entity.name.formatForCode»'«ENDFOR»];
            $this->imageFileTypes = ['gif', 'jpeg', 'jpg', 'png'];
            $this->forbiddenFileTypes = ['cgi', 'pl', 'asp', 'phtml', 'php', 'php3', 'php4', 'php5', 'exe', 'com', 'bat', 'jsp', 'cfm', 'shtml'];
        }

        «setTranslatorMethod»

        «performFileUpload»

        «validateFileUpload»

        «readMetaDataForFile»

        «getAllowedFileExtensions»

        «isAllowedFileExtension»

        «determineFileName»

        «deleteUploadFile»

        «getFileBaseFolder»

        «checkAndCreateAllUploadFolders»

        «checkAndCreateUploadFolder»
    '''

    def private performFileUpload(Application it) '''
        /**
         * Process a file upload.
         *
         * @param string       $objectType Currently treated entity type
         * @param UploadedFile $file       The uploaded file
         * @param string       $fieldName  Name of upload field
         «IF hasUploadNamingScheme(UploadNamingScheme.USERDEFINEDWITHCOUNTER)»
         * @param string       $customName Optional custom file name
         «ENDIF»
         *
         * @return array Resulting file name and collected meta data
         */
        public function performFileUpload($objectType, $file, $fieldName«IF hasUploadNamingScheme(UploadNamingScheme.USERDEFINEDWITHCOUNTER)», $customName«ENDIF»)
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
            if (!$this->validateFileUpload($objectType, $file, $fieldName)) {
                return $result;
            }

            // build the file name
            $fileName = $file->getClientOriginalName();
            $fileNameParts = explode('.', $fileName);
            $extension = null !== $file->guessExtension() ? $file->guessExtension() : $file->guessClientExtension();
            if (in_array($extension, ['bin', 'mpga'])) {
                // fallback to given extension for mp3
                $fileNameParts = explode('.', $fileName);
                $extension = strtolower($fileNameParts[count($fileNameParts) - 1]);
            }
            if (null === $extension) {
                $extension = strtolower($fileNameParts[count($fileNameParts) - 1]);
            }
            $extension = str_replace('jpeg', 'jpg', $extension);
            $fileNameParts[count($fileNameParts) - 1] = $extension;
            «IF hasUploadNamingScheme(UploadNamingScheme.USERDEFINEDWITHCOUNTER)»
                $fileName = !empty($customName) ? $customName . '.' . $extension : implode('.', $fileNameParts);
            «ELSE»
                $fileName = implode('.', $fileNameParts);
            «ENDIF»

            $flashBag = $this->session->getFlashBag();

            // retrieve the final file name
            try {
                $basePath = $this->getFileBaseFolder($objectType, $fieldName);
            } catch (\Exception $exception) {
                $flashBag->add('error', $exception->getMessage());
                $this->logger->error('{app}: User {user} could not detect upload destination path for entity {entity} and field {field}. ' . $exception->getMessage(), ['app' => '«appName»', 'user' => $this->currentUserApi->get('uname'), 'entity' => $objectType, 'field' => $fieldName]);

                return $result;
            }
            $fileName = $this->determineFileName($objectType, $fieldName, $basePath, $fileName, $extension);

            $destinationFilePath = $basePath . $fileName;
            $targetFile = $file->move($basePath, $fileName);

            «doFileValidation('$destinationFilePath')»

            // collect data to return
            $result['fileName'] = $fileName;
            $result['metaData'] = $this->readMetaDataForFile($fileName, $destinationFilePath);

            $isImage = in_array($extension, $this->imageFileTypes);
            if ($isImage) {
                // fix wrong orientation and shrink too large image if needed
                @ini_set('memory_limit', '1G');
                $imagine = new Imagine();
                $image = $imagine->open($destinationFilePath);
                $autorotateFilter = new Autorotate();
                $image = $autorotateFilter->apply($image);
                $image->save($destinationFilePath);

                // check if shrinking functionality is enabled
                $fieldSuffix = ucfirst($objectType) . ucfirst($fieldName);
                if (isset($this->moduleVars['enableShrinkingFor' . $fieldSuffix]) && true === (bool)$this->moduleVars['enableShrinkingFor' . $fieldSuffix]) {
                    // check for maximum size
                    $maxWidth = isset($this->moduleVars['shrinkWidth' . $fieldSuffix]) ? $this->moduleVars['shrinkWidth' . $fieldSuffix] : 800;
                    $maxHeight = isset($this->moduleVars['shrinkHeight' . $fieldSuffix]) ? $this->moduleVars['shrinkHeight' . $fieldSuffix] : 600;
                    $thumbMode = isset($this->moduleVars['thumbnailMode' . $fieldSuffix]) ? $this->moduleVars['thumbnailMode' . $fieldSuffix] : ImageInterface::THUMBNAIL_INSET;

                    $imgInfo = getimagesize($destinationFilePath);
                    if ($imgInfo[0] > $maxWidth || $imgInfo[1] > $maxHeight) {
                        // resize to allowed maximum size
                        $imagine = new Imagine();
                        $image = $imagine->open($destinationFilePath);
                        $thumb = $image->thumbnail(new Box($maxWidth, $maxHeight), $thumbMode);
                        $thumb->save($destinationFilePath);
                    }
                }

                // update meta data excluding EXIF
                $newMetaData = $this->readMetaDataForFile($fileName, $destinationFilePath, false);
                $result['metaData'] = array_merge($result['metaData'], $newMetaData);
            }

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
         * @param string  $fileName    Name of file to be processed
         * @param string  $filePath    Path to file to be processed
         * @param boolean $includeExif Whether to read out EXIF data or not
         *
         * @return array Collected meta data
         */
        public function readMetaDataForFile($fileName, $filePath, $includeExif = true)
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

            if ('swf' == $meta['extension']) {
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

            if (!$includeExif || 'jpg' != $meta['extension']) {
                return $meta;
            }

            // add EXIF data
            $exifData = $this->readExifData($filePath);
            $meta = array_merge($meta, $exifData);

            return $meta;
        }

        /**
         * Read EXIF data from a certain file.
         *
         * @param string  $filePath Path to file to be processed
         *
         * @return array Collected meta data
         */
        protected function readExifData($filePath)
        {
            $imagine = new Imagine();
            $image = $imagine
                ->setMetadataReader(new ExifMetadataReader())
                ->open($filePath);

            $exifData = $image->metadata()->toArray();

            // strip non-utf8 chars to bypass firmware bugs (e.g. Samsung)
            foreach ($exifData as $k => $v) {
                if (is_array($v)) {
                    foreach ($v as $kk => $vv) {
                        $exifData[$k][$kk] = mb_convert_encoding($vv, 'UTF-8', 'UTF-8');
                        if (false !== strpos($exifData[$k][$kk], '????')) {
                            unset($exifData[$k][$kk]);
                        }
                    }
                } else {
                    $exifData[$k] = mb_convert_encoding($v, 'UTF-8', 'UTF-8');
                    if (false !== strpos($exifData[$k], '????')) {
                        unset($exifData[$k]);
                    }
                }
            }

            return $exifData;
        }
    '''

    def private getAllowedFileExtensions(Application it) '''
        /**
         * Determines the allowed file extensions for a given object type and field.
         *
         * @param string $objectType Currently treated entity type
         * @param string $fieldName  Name of upload field
         *
         * @return string[] List of allowed file extensions
         */
        public function getAllowedFileExtensions($objectType, $fieldName)
        {
            // determine the allowed extensions
            $allowedExtensions = [];
            switch ($objectType) {
                «FOR entity : getUploadEntities.filter(Entity)»«entity.getAllowedFileExtensionsEntityCase»«ENDFOR»
                «IF hasUploadVariables»
                    «getAllowedFileExtensionsEntityCase»
                «ENDIF»
            }

            return $allowedExtensions;
        }
    '''

    def private isAllowedFileExtension(Application it) '''
        /**
         * Determines whether a certain file extension is allowed for a given object type and field.
         *
         * @param string $objectType Currently treated entity type
         * @param string $fieldName  Name of upload field
         * @param string $extension  Input file extension
         *
         * @return boolean True if given extension is allowed, false otherwise
         */
        protected function isAllowedFileExtension($objectType, $fieldName, $extension)
        {
            // determine the allowed extensions
            $allowedExtensions = $this->getAllowedFileExtensions($objectType, $fieldName);

            if (count($allowedExtensions) > 0 && $allowedExtensions[0] != '*') {
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

    def private dispatch getAllowedFileExtensionsEntityCase(Entity it) '''
        «val uploadFields = getUploadFieldsEntity»
        case '«name.formatForCode»':
            «IF uploadFields.size > 1»
                switch ($fieldName) {
                    «FOR uploadField : uploadFields»«uploadField.getAllowedFileExtensionsFieldCase»«ENDFOR»
                }
            «ELSE»
                $allowedExtensions = ['«uploadFields.head.allowedExtensions.replace(', ', "', '")»'];
            «ENDIF»
                break;
    '''


    def private dispatch getAllowedFileExtensionsEntityCase(Application it) '''
        «val uploadFields = getUploadVariables»
        case 'appSettings':
            «IF uploadFields.size > 1»
                switch ($fieldName) {
                    «FOR uploadField : uploadFields»«uploadField.getAllowedFileExtensionsFieldCase»«ENDFOR»
                }
            «ELSE»
                $allowedExtensions = ['«uploadFields.head.allowedExtensions.replace(', ', "', '")»'];
            «ENDIF»
                break;
    '''

    def private getAllowedFileExtensionsFieldCase(UploadField it) '''
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
            $namingScheme = 0;
            switch ($objectType) {
                «FOR entity : getUploadEntities.filter(Entity)»«entity.determineFileNameEntityCase»«ENDFOR»
                «IF hasUploadVariables»
                    «determineFileNameEntityCase»
                «ENDIF»
            }

            if ($namingScheme == 0 || $namingScheme == 3) {
                // clean the given file name
                $fileNameCharCount = strlen($fileName);
                for ($y = 0; $y < $fileNameCharCount; $y++) {
                    if (preg_match('/[^0-9A-Za-z_\.]/', $fileName[$y])) {
                        $fileName[$y] = '_';
                    }
                }
            }
            $backupFileName = $fileName;

            $iterIndex = -1;
            do {
                if ($namingScheme == 0 || $namingScheme == 3) {
                    // original (0) or user defined (3) file name with counter
                    if ($iterIndex > 0) {
                        // strip off extension
                        $fileName = str_replace('.' . $extension, '', $backupFileName);
                        // append incremented number
                        $fileName .= (string) ++$iterIndex;
                        // readd extension
                        $fileName .= '.' . $extension;
                    } else {
                        $iterIndex++;
                    }
                } elseif ($namingScheme == 1) {
                    // md5 name
                    $fileName = md5(uniqid(mt_rand(), true)) . '.' . $extension;
                } elseif ($namingScheme == 2) {
                    // prefix with random number
                    $fileName = $fieldName . mt_rand(1, 999999) . '.' . $extension;
                }
            }
            while (file_exists($basePath . $fileName)); // repeat until we have a new name

            // return the final file name
            return $fileName;
        }
    '''

    def private dispatch determineFileNameEntityCase(Entity it) '''
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

    def private dispatch determineFileNameEntityCase(Application it) '''
        «val uploadFields = getUploadVariables»
        case 'appSettings':
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

            «val loggableEntitiesWithUploads = getUploadEntities.filter(Entity).filter[loggable]»
            // remove the file«IF !loggableEntitiesWithUploads.empty» (but not for loggable entities)«ENDIF»
            «IF !loggableEntitiesWithUploads.empty»
                if (!in_array($objectType, ['«loggableEntitiesWithUploads.map[name.formatForCode].join('\', \'')»'])) {
            «ENDIF»
            if (is_array($entity[$fieldName]) && isset($entity[$fieldName][$fieldName])) {
                $entity[$fieldName] = $entity[$fieldName][$fieldName];
            }
            $filePath = $entity[$fieldName] instanceof File ? $entity[$fieldName]->getPathname() : $entity[$fieldName];
            if (file_exists($filePath) && !unlink($filePath)) {
                return false;
            }
            «IF !loggableEntitiesWithUploads.empty»
            }
            «ENDIF»

            $entity[$fieldName] = null;

            return $entity;
        }
    '''

    def private getFileBaseFolder(Application it) '''
        /**
         * Retrieve the base path for given object type and upload field combination.
         *
         * @param string  $objectType   Name of treated entity type
         * @param string  $fieldName    Name of upload field
         * @param boolean $ignoreCreate Whether to ignore the creation of upload folders on demand or not
         *
         * @return mixed Output
         *
         * @throws Exception If an invalid object type is used
         */
        public function getFileBaseFolder($objectType, $fieldName = '', $ignoreCreate = false)
        {
            $basePath = $this->dataDirectory . '/«appName»/';

            switch ($objectType) {
                «FOR entity : getUploadEntities.filter(Entity)»
                    «val uploadFields = entity.getUploadFieldsEntity»
                    case '«entity.name.formatForCode»':
                        «IF uploadFields.size > 1»
                            $basePath .= '«entity.nameMultiple.formatForDB»/';
                            if ('' != $fieldName) {
                                switch ($fieldName) {
                                    «FOR uploadField : uploadFields»
                                        case '«uploadField.name.formatForCode»':
                                            $basePath .= '«uploadField.subFolderPathSegment»/';
                                            break;
                                    «ENDFOR»
                                }
                            }
                        «ELSE»
                            $basePath .= '«entity.nameMultiple.formatForDB»/';
                            if ('' != $fieldName) {
                                $basePath .= '«uploadFields.head.subFolderPathSegment»/';
                            }
                        «ENDIF»
                        break;
                «ENDFOR»
                «IF hasUploadVariables»
                    «val uploadFields = getUploadVariables»
                    case 'appSettings':
                        «IF uploadFields.size > 1»
                            $basePath .= 'appSettings/';
                            if ('' != $fieldName) {
                                switch ($fieldName) {
                                    «FOR uploadField : uploadFields»
                                        case '«uploadField.name.formatForCode»':
                                            $basePath .= '«uploadField.subFolderPathSegment»/';
                                            break;
                                    «ENDFOR»
                                }
                            }
                        «ELSE»
                            $basePath .= 'appSettings/';
                            if ('' != $fieldName) {
                                $basePath .= '«uploadFields.head.subFolderPathSegment»/';
                            }
                        «ENDIF»
                        break;
                «ENDIF»
                default:
                    throw new Exception($this->__('Error! Invalid object type received.'));
            }

            $result = $basePath;
            if (substr($result, -1, 1) != '/') {
                // reappend the removed slash
                $result .= '/';
            }

            if (!is_dir($result) && !$ignoreCreate) {
                $this->checkAndCreateAllUploadFolders();
            }

            return $result;
        }
    '''

    def private checkAndCreateAllUploadFolders(Application it) '''
        /**
         * Creates all required upload folders for this application.
         *
         * @return Boolean Whether everything went okay or not
         */
        public function checkAndCreateAllUploadFolders()
        {
            $result = true;
            «FOR uploadEntity : getUploadEntities»

                «FOR uploadField : uploadEntity.getUploadFieldsEntity»
                    $result &= $this->checkAndCreateUploadFolder('«uploadField.entity.name.formatForCode»', '«uploadField.name.formatForCode»', '«uploadField.allowedExtensions»');
                «ENDFOR»
            «ENDFOR»
            «FOR uploadField : getUploadVariables»
                $result &= $this->checkAndCreateUploadFolder('appSettings', '«uploadField.name.formatForCode»', '«uploadField.allowedExtensions»');
            «ENDFOR»

            return $result;
        }
    '''

    def private checkAndCreateUploadFolder(Application it) '''
        /**
         * Creates an upload folder and a .htaccess file within it.
         *
         * @param string $objectType        Name of treated entity type
         * @param string $fieldName         Name of upload field
         * @param string $allowedExtensions String with list of allowed file extensions (separated by ", ")
         *
         * @return Boolean Whether everything went okay or not
         */
        protected function checkAndCreateUploadFolder($objectType, $fieldName, $allowedExtensions = '')
        {
            $uploadPath = $this->getFileBaseFolder($objectType, $fieldName, true);

            $flashBag = $this->session->getFlashBag();

            // Check if directory exist and try to create it if needed
            if (!$this->filesystem->exists($uploadPath)) {
                try {
                    $this->filesystem->mkdir($uploadPath, 0777);
                } catch (IOExceptionInterface $exception) {
                    $flashBag->add('error', $this->__f('The upload directory "%path%" does not exist and could not be created. Try to create it yourself and make sure that this folder is accessible via the web and writable by the webserver.', ['%path%' => $exception->getPath()]));
                    $this->logger->error('{app}: The upload directory {directory} does not exist and could not be created.', ['app' => '«appName»', 'directory' => $uploadPath]);

                    return false;
                }
            }

            // Check if directory is writable and change permissions if needed
            if (!is_writable($uploadPath)) {
                try {
                    $this->filesystem->chmod($uploadPath, 0777);
                } catch (IOExceptionInterface $exception) {
                    $flashBag->add('warning', $this->__f('Warning! The upload directory at "%path%" exists but is not writable by the webserver.', ['%path%' => $exception->getPath()]));
                    $this->logger->error('{app}: The upload directory {directory} exists but is not writable by the webserver.', ['app' => '«appName»', 'directory' => $uploadPath]);

                    return false;
                }
            }

            // Write a htaccess file into the upload directory
            $htaccessFilePath = $uploadPath . '/.htaccess';
            $htaccessFileTemplate = '«relativeAppRootPath»/«getAppDocPath»htaccessTemplate';
            if (!$this->filesystem->exists($htaccessFilePath) && $this->filesystem->exists($htaccessFileTemplate)) {
                try {
                    $extensions = str_replace(',', '|', str_replace(' ', '', $allowedExtensions));
                    $htaccessContent = str_replace('__EXTENSIONS__', $extensions, file_get_contents($htaccessFileTemplate, false));
                    $this->filesystem->dumpFile($htaccessFilePath, $htaccessContent);
                } catch (IOExceptionInterface $exception) {
                    $flashBag->add('error', $this->__f('An error occured during creation of the .htaccess file in directory "%path%".', ['%path%' => $exception->getPath()]));

                    $this->logger->error('{app}: An error occured during creation of the .htaccess file in directory {directory}.', ['app' => '«appName»', 'directory' => $uploadPath]);

                    return false;
                }
            }

            return true;
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
