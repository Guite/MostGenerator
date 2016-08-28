package org.zikula.modulestudio.generator.cartridges.zclassic.controller

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.UploadField
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.GeneratorSettingsExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Uploads {

    extension FormattingExtensions = new FormattingExtensions
    extension GeneratorSettingsExtensions = new GeneratorSettingsExtensions
    extension ModelExtensions = new ModelExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    FileHelper fh = new FileHelper
    IFileSystemAccess fsa

    /**
     * Entry point for the upload handler.
     */
    def generate(Application it, IFileSystemAccess fsa) {
        this.fsa = fsa
        createUploadFolders
        generateClassPair(fsa, getAppSourceLibPath + 'UploadHandler.php',
            fh.phpFileContent(it, uploadHandlerBaseImpl), fh.phpFileContent(it, uploadHandlerImpl)
        )
    }

    def private createUploadFolders(Application it) {
        /* This index.html files will be removed later. At the moment we need them to create according directories. */
        fsa.generateFile(getAppUploadPath + 'index.html', msUrl)
        for (entity : getUploadEntities.filter(Entity)) {
            val subFolderName = entity.nameMultiple.formatForDB + '/'
            fsa.generateFile(getAppUploadPath + subFolderName + '/index.html', msUrl)
            val uploadFields = entity.getUploadFieldsEntity
            if (uploadFields.size > 1) {
                for (uploadField : uploadFields) {
                    uploadField.uploadFolder(subFolderName + uploadField.subFolderPathSegment)
                }
            } else if (uploadFields.size > 0) {
                uploadFields.head.uploadFolder(subFolderName + uploadFields.head.subFolderPathSegment)
            }
        }
        val docPath = (if (targets('1.3.x')) getAppSourcePath + 'docs/' else getAppDocPath)
        fsa.generateFile(docPath + 'htaccessTemplate', htAccessTemplate)
    }

    def private uploadFolder(UploadField it, String folder) {
        fsa.generateFile(getAppUploadPath(entity.application) + folder + '/index.html', msUrl)
        fsa.generateFile(getAppUploadPath(entity.application) + folder + '/.htaccess', htAccess)
    }

    def private htAccess(UploadField it) '''
        # «fh.generatedBy(entity.application, entity.application.timestampAllGeneratedFiles, entity.application.versionAllGeneratedFiles)»
        # ------------------------------------------------------------
        # Purpose of file: block any web access to unallowed files
        # stored in this directory
        # ------------------------------------------------------------

        # Apache 2.2
        <IfModule !mod_authz_core.c>
            Deny from all
        </IfModule>

        # Apache 2.4
        <IfModule mod_authz_core.c>
            Require all denied
        </IfModule>

        <FilesMatch "\.(«allowedExtensions.replace(", ", "|")»)$">
            # Apache 2.2
            <IfModule !mod_authz_core.c>
                Order allow,deny
                Allow from all
            </IfModule>

            # Apache 2.4
            <IfModule mod_authz_core.c>
                Require all granted
            </IfModule>
        </filesmatch>
    '''

    def private htAccessTemplate(Application it) '''
        # «fh.generatedBy(it, timestampAllGeneratedFiles, versionAllGeneratedFiles)»
        # ------------------------------------------------------------
        # Purpose of file: block any web access to unallowed files
        # stored in this directory
        # ------------------------------------------------------------

        # Apache 2.2
        <IfModule !mod_authz_core.c>
            Deny from all
        </IfModule>

        # Apache 2.4
        <IfModule mod_authz_core.c>
            Require all denied
        </IfModule>

        <FilesMatch "\.(__EXTENSIONS__)$">
            # Apache 2.2
            <IfModule !mod_authz_core.c>
                Order allow,deny
                Allow from all
            </IfModule>

            # Apache 2.4
            <IfModule mod_authz_core.c>
                Require all granted
            </IfModule>
        </filesmatch>
    '''

    def private uploadHandlerBaseImpl(Application it) '''
        «IF !targets('1.3.x')»
            namespace «appNamespace»\Base;

            use Symfony\Component\Filesystem\Filesystem;
            use Symfony\Component\Filesystem\Exception\IOExceptionInterface;
            use Zikula\Common\Translator\TranslatorInterface;
            use Zikula\Common\Translator\TranslatorTrait;
            use Zikula\UsersModule\Api\CurrentUserApi;
            use DataUtil;
            use FileUtil;
            use RuntimeException;
            use ServiceUtil;

        «ENDIF»
        /**
         * Upload handler base class.
         */
        «IF targets('1.3.x')»
        class «appName»_Base_UploadHandler
        «ELSE»
        class UploadHandler
        «ENDIF»
        {
            «IF !targets('1.3.x')»
                use TranslatorTrait;

                /**
                 * @var CurrentUserApi
                 */
                protected $currentUserApi;

            «ENDIF»
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
             * @var array List of allowed file sizes per field
             */
            protected $allowedFileSizes;

            /**
             * Constructor initialising the supported object types.
            «IF !targets('1.3.x')»
                «' '»*
                «' '»* @param TranslatorInterface $translator Translator service instance
            «ENDIF»
             */
            public function __construct(«IF !targets('1.3.x')»TranslatorInterface $translator, CurrentUserApi $currentUserApi«ENDIF»)
            {
                «IF !targets('1.3.x')»
                    $this->setTranslator($translator);
                    $this->currentUserApi = $currentUserApi;
                «ENDIF»
                $this->allowedObjectTypes = «IF targets('1.3.x')»array(«ELSE»[«ENDIF»«FOR entity : getUploadEntities SEPARATOR ', '»'«entity.name.formatForCode»'«ENDFOR»«IF targets('1.3.x')»)«ELSE»]«ENDIF»;
                $this->imageFileTypes = «IF targets('1.3.x')»array(«ELSE»[«ENDIF»'gif', 'jpeg', 'jpg', 'png', 'swf'«IF targets('1.3.x')»)«ELSE»]«ENDIF»;
                $this->forbiddenFileTypes = «IF targets('1.3.x')»array(«ELSE»[«ENDIF»'cgi', 'pl', 'asp', 'phtml', 'php', 'php3', 'php4', 'php5', 'exe', 'com', 'bat', 'jsp', 'cfm', 'shtml'«IF targets('1.3.x')»)«ELSE»]«ENDIF»;
                $this->allowedFileSizes = «IF targets('1.3.x')»array(«ELSE»[«ENDIF»«FOR entity : getUploadEntities SEPARATOR ', '»'«entity.name.formatForCode»' => «IF targets('1.3.x')»array(«ELSE»[«ENDIF»«FOR field : entity.getUploadFieldsEntity SEPARATOR ', '»'«field.name.formatForCode»' => «field.allowedFileSize»«ENDFOR»«IF targets('1.3.x')»)«ELSE»]«ENDIF»«ENDFOR»«IF targets('1.3.x')»)«ELSE»]«ENDIF»;
            }

            /**
             * Sets the translator.
             *
             * @param TranslatorInterface $translator Translator service instance
             */
            public function setTranslator(/*TranslatorInterface */$translator)
            {
                $this->translator = $translator;
            }

            «performFileUpload»

            «validateFileUpload»

            «readMetaDataForFile»

            «isAllowedFileExtension»

            «determineFileName»

            «handleError»

            «deleteUploadFile»
        }
    '''

    def private performFileUpload(Application it) '''
        /**
         * Process a file upload.
         *
         * @param string $objectType Currently treated entity type
         * @param string $fileData   Form data array
         * @param string $fieldName  Name of upload field
         *
         * @return array Resulting file name and collected meta data
         «IF !targets('1.3.x')»
         *
         * @throws RuntimeException Thrown if upload file base path retrieval fails or the file can not be moved to it's destination folder
         «ENDIF»
         */
        public function performFileUpload($objectType, $fileData, $fieldName)
        {
            «IF targets('1.3.x')»
                $dom = ZLanguage::getModuleDomain('«appName»');

            «ENDIF»
            $result = «IF targets('1.3.x')»array(«ELSE»[«ENDIF»
                'fileName' => '',
                'metaData' => «IF targets('1.3.x')»array()«ELSE»[]«ENDIF»
            «IF targets('1.3.x')»)«ELSE»]«ENDIF»;

            // check whether uploads are allowed for the given object type
            if (!in_array($objectType, $this->allowedObjectTypes)) {
                return $result;
            }

            «IF !targets('1.3.x')»
                $file = $fileData[$fieldName];
            «ENDIF»

            // perform validation
            «IF targets('1.3.x')»
            if (!$this->validateFileUpload($objectType, $fileData[$fieldName], $fieldName)) {
            «ELSE»
            try {
                $this->validateFileUpload($objectType, $file, $fieldName);
            } catch (\Exception $e) {
            «ENDIF»
                // skip this upload field
                return $result;
            }

            // retrieve the final file name
            $fileName = «IF targets('1.3.x')»$fileData[$fieldName]['name']«ELSE»$file->getClientOriginalName()«ENDIF»;
            $fileNameParts = explode('.', $fileName);
            «IF targets('1.3.x')»
                $extension = strtolower($fileNameParts[count($fileNameParts) - 1]);
            «ELSE»
                $extension = null !== $file->guessExtension() ? $file->guessExtension() : $file->guessClientExtension();
                if (null === $extension) {
                    $extension = strtolower($fileNameParts[count($fileNameParts) - 1]);
                }
            «ENDIF»
            $extension = str_replace('jpeg', 'jpg', $extension);
            $fileNameParts[count($fileNameParts) - 1] = $extension;
            $fileName = implode('.', $fileNameParts);

            $serviceManager = ServiceUtil::getManager();
            «IF targets('1.3.x')»
                $controllerHelper = new «appName»_Util_Controller($serviceManager);
            «ELSE»
                $controllerHelper = $serviceManager->get('«appService».controller_helper');
                $flashBag = $serviceManager->get('session')->getFlashBag();
                $logger = $serviceManager->get('logger');
            «ENDIF»

            // retrieve the final file name
            try {
                $basePath = $controllerHelper->getFileBaseFolder($objectType, $fieldName);
            } catch (\Exception $e) {
                «IF targets('1.3.x')»
                    return LogUtil::registerError($e->getMessage());
                «ELSE»
                    $flashBag->add('error', $e->getMessage());
                    $logger->error('{app}: User {user} could not detect upload destination path for entity {entity} and field {field}.', ['app' => '«appName»', 'user' => $this->currentUserApi->get('uname'), 'entity' => $objectType, 'field' => $fieldName]);

                    return false;
                «ENDIF»
            }
            $fileName = $this->determineFileName($objectType, $fieldName, $basePath, $fileName, $extension);

            «IF targets('1.3.x')»
                if (!move_uploaded_file($fileData[$fieldName]['tmp_name'], $basePath . $fileName)) {
                    «IF targets('1.3.x')»
                        return LogUtil::registerError(__('Error! Could not move your file to the destination folder.', $dom));
                    «ELSE»
                        $flashBag->add('error', $this->__('Error! Could not move your file to the destination folder.'));
                        $logger->error('{app}: User {user} could not upload a file ("{sourcePath}") to destination folder ("{destinationPath}").', ['app' => '«appName»', 'user' => $this->currentUserApi->get('uname'), 'sourcePath' => $fileData[$fieldName]['tmp_name'], 'destinationPath' => $basePath . $fileName]);

                        return false;
                    «ENDIF»
                }
            «ELSE»
                $targetFile = $file->move($basePath, $fileName);

                «doFileValidation('$basePath . $fileName')»
            «ENDIF»

            // collect data to return
            $result['fileName'] = $fileName;
            $result['metaData'] = $this->readMetaDataForFile($fileName, $basePath . $fileName);

            return $result;
        }
    '''

    def private validateFileUpload(Application it) '''
        /**
         * Check if an upload file meets all validation criteria.
         *
         * @param string $objectType Currently treated entity type
         * @param array $file Reference to data of uploaded file
         * @param string $fieldName  Name of upload field
         *
         * @return boolean true if file is valid else false
         «IF !targets('1.3.x')»
         *
         * @throws RuntimeException Thrown if validating the upload file fails
         «ENDIF»
         */
        protected function validateFileUpload($objectType, $file, $fieldName)
        {
            «IF targets('1.3.x')»
                $dom = ZLanguage::getModuleDomain('«appName»');

            «ENDIF»
            $serviceManager = ServiceUtil::getManager();
            «IF !targets('1.3.x')»
                $flashBag = $serviceManager->get('session')->getFlashBag();
                $logger = $serviceManager->get('logger');
            «ENDIF»

            // check if a file has been uploaded properly without errors
            if (!is_array($file) || (is_array($file) && $file['error'] != '0')) {
                if (is_array($file)) {
                    return $this->handleError($file);
                }
                «IF targets('1.3.x')»
                    return LogUtil::registerError(__('Error! No file found.', $dom));
                «ELSE»
                    $flashBag->add('error', $this->__('Error! No file found.'));
                    $logger->error('{app}: User {user} tried to upload a file which could not be found.', ['app' => '«appName»', 'user' => $this->currentUserApi->get('uname')]);

                    return false;
                «ENDIF»
            }

            // extract file extension
            $fileName = $file«IF targets('1.3.x')»['name']«ELSE»->getClientOriginalName()«ENDIF»;
            «IF targets('1.3.x')»
                $fileNameParts = explode('.', $fileName);
                $extension = strtolower($fileNameParts[count($fileNameParts) - 1]);
            «ELSE»
                $extension = null !== $file->guessExtension() ? $file->guessExtension() : $file->guessClientExtension();
                if (null === $extension) {
                    $fileNameParts = explode('.', $fileName);
                    $extension = strtolower($fileNameParts[count($fileNameParts) - 1]);
                }
            «ENDIF»
            $extension = str_replace('jpeg', 'jpg', $extension);

            // validate extension
            $isValidExtension = $this->isAllowedFileExtension($objectType, $fieldName, $extension);
            if ($isValidExtension === false) {
                «IF targets('1.3.x')»
                    return LogUtil::registerError(__('Error! This file type is not allowed. Please choose another file format.', $dom));
                «ELSE»
                    $flashBag->add('error', $this->__('Error! This file type is not allowed. Please choose another file format.'));
                    $logger->error('{app}: User {user} tried to upload a file with a forbidden extension ("{extension}").', ['app' => '«appName»', 'user' => $this->currentUserApi->get('uname'), 'extension' => $extension]);

                    return false;
                «ENDIF»
            }
            «IF targets('1.3.x')»

                «doFileValidation('$file[\'tmp_name\']')»
            «ENDIF»

            return true;
        }
    '''

    def private doFileValidation(Application it, String fileVar) '''
        // validate file size
        $maxSize = $this->allowedFileSizes[$objectType][$fieldName];
        if ($maxSize > 0) {
            $fileSize = filesize(«fileVar»);
            if ($fileSize > $maxSize) {
                $maxSizeKB = $maxSize / 1024;
                if ($maxSizeKB < 1024) {
                    $maxSizeKB = DataUtil::formatNumber($maxSizeKB); 
                    «IF targets('1.3.x')»
                        return LogUtil::registerError(__f('Error! Your file is too big. Please keep it smaller than %s kilobytes.', array($maxSizeKB), $dom));
                    «ELSE»
                        $flashBag->add('error', $this->__f('Error! Your file is too big. Please keep it smaller than %s kilobytes.', [$maxSizeKB]));
                        $logger->error('{app}: User {user} tried to upload a file with a size greater than "{size} KB".', ['app' => '«appName»', 'user' => $this->currentUserApi->get('uname'), 'size' => $maxSizeKB]);

                        $fs = new Filesystem();
                        try {
                            $fs->remove(array(«fileVar»));
                        } catch (IOExceptionInterface $e) {
                            $logger->error('{app}: The file could not be properly removed from the file system.', []);
                        }

                        return false;
                    «ENDIF»
                }
                $maxSizeMB = $maxSizeKB / 1024;
                $maxSizeMB = DataUtil::formatNumber($maxSizeMB); 
                «IF targets('1.3.x')»
                    return LogUtil::registerError(__f('Error! Your file is too big. Please keep it smaller than %s megabytes.', array($maxSizeMB), $dom));
                «ELSE»
                    $flashBag->add('error', $this->__f('Error! Your file is too big. Please keep it smaller than %s megabytes.', [$maxSizeMB]));
                    $logger->error('{app}: User {user} tried to upload a file with a size greater than "{size} MB".', ['app' => '«appName»', 'user' => $this->currentUserApi->get('uname'), 'size' => $maxSizeMB]);

                    $fs = new Filesystem();
                    try {
                        $fs->remove(array(«fileVar»));
                    } catch (IOExceptionInterface $e) {
                        $logger->error('{app}: The file could not be properly removed from the file system.', []);
                    }

                    return false;
                «ENDIF»
            }
        }

        // validate image file
        $isImage = in_array($extension, $this->imageFileTypes);
        if ($isImage) {
            $imgInfo = getimagesize(«fileVar»);
            if (!is_array($imgInfo) || !$imgInfo[0] || !$imgInfo[1]) {
                «IF targets('1.3.x')»
                    return LogUtil::registerError(__('Error! This file type seems not to be a valid image.', $dom));
                «ELSE»
                    $flashBag->add('error', $this->__('Error! This file type seems not to be a valid image.'));
                    $logger->error('{app}: User {user} tried to upload a file which is seems not to be a valid image.', ['app' => '«appName»', 'user' => $this->currentUserApi->get('uname')]);

                    return false;
                «ENDIF»
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
            $meta = «IF targets('1.3.x')»array()«ELSE»[]«ENDIF»;
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
            $allowedExtensions = «IF targets('1.3.x')»array()«ELSE»[]«ENDIF»;
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
                $allowedExtensions = «IF application.targets('1.3.x')»array(«ELSE»[«ENDIF»'«uploadFields.head.allowedExtensions.replace(', ', "', '")»'«IF application.targets('1.3.x')»)«ELSE»]«ENDIF»;
            «ENDIF»
                break;
    '''

    def private isAllowedFileExtensionFieldCase(UploadField it) '''
        case '«name.formatForCode»':
            $allowedExtensions = «IF entity.application.targets('1.3.x')»array(«ELSE»[«ENDIF»'«allowedExtensions.replace(', ', "', '")»'«IF entity.application.targets('1.3.x')»)«ELSE»]«ENDIF»;
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

    def private handleError(Application it) '''
        /**
         * Error handling helper method.
         *
         * @param array $file File array from $_FILES
         *
         * @return boolean false
         «IF !targets('1.3.x')»
         *
         * @throws RuntimeException Thrown if an unknown error occurs
         «ENDIF»
         */
        private function handleError($file)
        {
            «IF targets('1.3.x')»
                $dom = ZLanguage::getModuleDomain('«appName»');

            «ENDIF»
            $errorMessage = '';
            switch ($file['error']) {
                case UPLOAD_ERR_OK: //no error; possible file attack!
                    $errorMessage = «IF !targets('1.3.x')»$this->«ENDIF»__('Unknown error'«IF targets('1.3.x')», $dom«ENDIF»);
                    break;
                case UPLOAD_ERR_INI_SIZE: //uploaded file exceeds the upload_max_filesize directive in php.ini
                    $errorMessage = «IF !targets('1.3.x')»$this->«ENDIF»__('File too big'«IF targets('1.3.x')», $dom«ENDIF»);
                    break;
                case UPLOAD_ERR_FORM_SIZE: //uploaded file exceeds the MAX_FILE_SIZE directive that was specified in the html form
                    $errorMessage = «IF !targets('1.3.x')»$this->«ENDIF»__('File too big'«IF targets('1.3.x')», $dom«ENDIF»);
                    break;
                case UPLOAD_ERR_PARTIAL: //uploaded file was only partially uploaded
                    $errorMessage = «IF !targets('1.3.x')»$this->«ENDIF»__('File uploaded partially'«IF targets('1.3.x')», $dom«ENDIF»);
                    break;
                case UPLOAD_ERR_NO_FILE: //no file was uploaded
                    $errorMessage = «IF !targets('1.3.x')»$this->«ENDIF»__('No file uploaded'«IF targets('1.3.x')», $dom«ENDIF»);
                    break;
                case UPLOAD_ERR_NO_TMP_DIR: //missing a temporary folder
                    $errorMessage = «IF !targets('1.3.x')»$this->«ENDIF»__('No tmp folder'«IF targets('1.3.x')», $dom«ENDIF»);
                    break;
                default: //a default (error, just in case!  :)
                    $errorMessage = «IF !targets('1.3.x')»$this->«ENDIF»__('Unknown error'«IF targets('1.3.x')», $dom«ENDIF»);
                    break;
            }

            «IF targets('1.3.x')»
                return LogUtil::registerError(__('Error with upload', $dom) . ': ' . $errorMessage);
            «ELSE»
                $serviceManager = ServiceUtil::getManager();
                $session = $serviceManager->get('session');
                $session->getFlashBag()->add('error', $this->__('Error with upload') . ': ' . $errorMessage);
                $logger = $serviceManager->get('logger');
                $logger->error('{app}: User {user} received an upload error: "{errorMessage}".', ['app' => '«appName»', 'user' => $this->currentUserApi->get('uname'), 'errorMessage' => $errorMessage]);

                return false;
            «ENDIF»
        }
    '''

    def private deleteUploadFile(Application it) '''
        /**
         * Deletes an existing upload file.
         * For images the thumbnails are removed, too.
         *
         * @param string  $objectType Currently treated entity type
         * @param string  $objectData Object data array
         * @param string  $fieldName  Name of upload field
         * @param integer $objectId   Primary identifier of the given object
         *
         * @return mixed Array with updated object data on success, else false
         */
        public function deleteUploadFile($objectType, $objectData, $fieldName, $objectId)
        {
            if (!in_array($objectType, $this->allowedObjectTypes)) {
                return false;
            }

            if (empty($objectData[$fieldName])) {
                return $objectData;
            }

            $serviceManager = ServiceUtil::getManager();
            «IF targets('1.3.x')»
                $controllerHelper = new «appName»_Util_Controller($serviceManager);
            «ELSE»
                $controllerHelper = $serviceManager->get('«appService».controller_helper');
            «ENDIF»

            // determine file system information
            try {
                $basePath = $controllerHelper->getFileBaseFolder($objectType, $fieldName);
            } catch (\Exception $e) {
                «IF targets('1.3.x')»
                    LogUtil::registerError($e->getMessage());
                «ELSE»
                    $logger = $serviceManager->get('logger');
                    $logger->error('{app}: User {user} could not detect upload destination path for entity {entity} and field {field}.', ['app' => '«appName»', 'user' => $this->currentUserApi->get('uname'), 'entity' => $objectType, 'field' => $fieldName]);

                    return false;
                «ENDIF»
            }
            $fileName = $objectData[$fieldName];

            // path to original file
            $filePath = $basePath . $fileName;

            // check whether we have to consider thumbnails, too
            $fileExtension = FileUtil::getExtension($fileName, false);
            if (in_array($fileExtension, $this->imageFileTypes) && $fileExtension != 'swf') {
                // remove thumbnail images as well
                $manager = ServiceUtil::getManager()->get«IF targets('1.3.x')»Service«ENDIF»('systemplugin.imagine.manager');
                $manager->setModule('«appName»');
                $fullObjectId = $objectType . '-' . $objectId;
                $manager->removeImageThumbs($filePath, $fullObjectId);
            }

            // remove original file
            if (!unlink($filePath)) {
                return false;
            }
            $objectData[$fieldName] = '';
            $objectData[$fieldName . 'Meta'] = «IF targets('1.3.x')»array()«ELSE»[]«ENDIF»;

            return $objectData;
        }
    '''

    def private uploadHandlerImpl(Application it) '''
        «IF !targets('1.3.x')»
            namespace «appNamespace»;

            use «appNamespace»\Base\UploadHandler as BaseUploadHandler;

        «ENDIF»
        /**
         * Upload handler implementation class.
         */
        «IF targets('1.3.x')»
        class «appName»_UploadHandler extends «appName»_Base_UploadHandler
        «ELSE»
        class UploadHandler extends BaseUploadHandler
        «ENDIF»
        {
            // feel free to add your upload handler enhancements here
        }
    '''
}
