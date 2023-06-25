package org.zikula.modulestudio.generator.cartridges.symfony.controller.helper

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.UploadField
import de.guite.modulestudio.metamodel.UploadNamingScheme
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils
import org.zikula.modulestudio.generator.application.ImportList

class UploadHelper {

    extension FormattingExtensions = new FormattingExtensions
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

    def private collectBaseImports(Application it) {
        val imports = new ImportList
        imports.addAll(#[
            'Exception',
            'Imagine\\Filter\\Basic\\Autorotate',
            'Imagine\\Gd\\Imagine',
            'Imagine\\Image\\Box',
            'Imagine\\Image\\ImageInterface',
            'Imagine\\Image\\Metadata\\ExifMetadataReader',
            'Psr\\Log\\LoggerInterface',
            'Symfony\\Component\\DependencyInjection\\Attribute\\Autowire',
            'Symfony\\Component\\Filesystem\\Exception\\IOExceptionInterface',
            'Symfony\\Component\\Filesystem\\Filesystem',
            'Symfony\\Component\\HttpFoundation\\File\\File',
            'Symfony\\Component\\HttpFoundation\\File\\UploadedFile',
            'Symfony\\Component\\HttpFoundation\\RequestStack',
            'function Symfony\\Component\\String\\s',
            'Symfony\\Contracts\\Translation\\TranslatorInterface',
            'Zikula\\CoreBundle\\Translation\\TranslatorTrait',
            'Zikula\\UsersBundle\\Api\\ApiInterface\\CurrentUserApiInterface',
            appNamespace + '\\Entity\\EntityInterface'
        ])
        imports
    }

    def private uploadFunctionsBaseImpl(Application it) '''
        namespace «appNamespace»\Helper\Base;

        «collectBaseImports.print»

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
         * List of object types with upload fields
         */
        protected array $allowedObjectTypes;

        /**
         * List of file types to be considered as images
         */
        protected array $imageFileTypes;

        /**
         * List of dangerous file types to be rejected
         */
        protected array $forbiddenFileTypes;

        public function __construct(
            TranslatorInterface $translator,
            protected readonly Filesystem $filesystem,
            protected readonly RequestStack $requestStack,
            protected readonly LoggerInterface $logger,
            protected readonly CurrentUserApiInterface $currentUserApi,
            protected readonly array $imageConfig,
            #[Autowire(param: 'kernel.project_dir')]
            protected readonly string $projectDir,
            #[Autowire(param: 'data_directory')]
            protected readonly string $dataDirectory
        ) {
            $this->setTranslator($translator);

            $this->allowedObjectTypes = [«FOR entity : getUploadEntities SEPARATOR ', '»'«entity.name.formatForCode»'«ENDFOR»];
            $this->imageFileTypes = ['gif', 'jpeg', 'jpg', 'png'];
            $this->forbiddenFileTypes = [
                'cgi', 'pl', 'asp', 'phtml', 'php', 'php3', 'php4', 'php5',
                'exe', 'com', 'bat', 'jsp', 'cfm', 'shtml',
            ];
        }

        «performFileUpload»

        «validateFileUpload»

        «readMetaDataForFile»

        «getAllowedFileExtensions»

        «isAllowedFileExtension»

        «determineFileExtension»

        «determineFileName»

        «deleteUploadFile»

        «getFileBaseFolder»

        «checkAndCreateAllUploadFolders»

        «checkAndCreateUploadFolder»
    '''

    def private performFileUpload(Application it) '''
        /**
         * Process a file upload.
         */
        public function performFileUpload(string $objectType, UploadedFile $file, string $fieldName«IF hasUploadNamingScheme(UploadNamingScheme.USERDEFINEDWITHCOUNTER)», string $customName«ENDIF»): array
        {
            $result = [
                'fileName' => '',
                'metaData' => [],
            ];

            // check whether uploads are allowed for the given object type
            if (!in_array($objectType, $this->allowedObjectTypes, true)) {
                return $result;
            }

            // perform validation
            if (!$this->validateFileUpload($objectType, $file, $fieldName)) {
                return $result;
            }

            // build the file name
            $fileName = $file->getClientOriginalName();
            $fileNameParts = explode('.', $fileName);
            $extension = $this->determineFileExtension($file);
            $fileNameParts[count($fileNameParts) - 1] = $extension;
            «IF hasUploadNamingScheme(UploadNamingScheme.USERDEFINEDWITHCOUNTER)»
                $fileName = !empty($customName) ? $customName . '.' . $extension : implode('.', $fileNameParts);
            «ELSE»
                $fileName = implode('.', $fileNameParts);
            «ENDIF»

            $request = $this->requestStack->getCurrentRequest();
            $session = $request->hasSession() ? $request->getSession() : null;
            $flashBag = null !== $session ? $session->getFlashBag() : null;

            // retrieve the final file name
            try {
                $basePath = $this->projectDir . '/' . $this->getFileBaseFolder($objectType, $fieldName);
            } catch (Exception $exception) {
                if (null !== $flashBag) {
                    $flashBag->add('error', $exception->getMessage());
                }
                $logArgs = [
                    'app' => '«appName»',
                    'user' => $this->currentUserApi->get('uname'),
                    'entity' => $objectType,
                    'field' => $fieldName,
                ];
                $this->logger->error(
                    '{app}: User {user} could not detect upload destination path for entity {entity} and field {field}.'
                        . ' ' . $exception->getMessage(),
                    $logArgs
                );

                return $result;
            }
            $fileName = $this->determineFileName($objectType, $fieldName, $basePath, $fileName, $extension);

            $destinationFilePath = $basePath . $fileName;
            $targetFile = $file->move($basePath, $fileName);

            «doImageFileValidation('$destinationFilePath')»

            // collect data to return
            $result['fileName'] = $fileName;
            $result['metaData'] = $this->readMetaDataForFile($fileName, $destinationFilePath);

            if ($isImage && 'gif' !== $extension) {
                // fix wrong orientation and shrink too large image if needed
                @ini_set('memory_limit', '1G');
                $imagine = new Imagine();
                $image = $imagine->open($destinationFilePath);
                $autorotateFilter = new Autorotate();
                $image = $autorotateFilter->apply($image);
                $image->save($destinationFilePath);

                // check if shrinking functionality is enabled
                $configSuffix = s($objectType . '_' . $fieldName)->snake();

                if ($this->imageConfig['enable_shrinking_for_' . $configSuffix]) {
                    // check for maximum size
                    $maxWidth = $this->imageConfig['shrink_width_' . $configSuffix];
                    $maxHeight = $this->imageConfig['shrink_height_' . $configSuffix];
                    $thumbMode = $this->imageConfig['thumbnail_mode_' . $configSuffix];

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
         */
        protected function validateFileUpload(string $objectType, UploadedFile $file, string $fieldName): bool
        {
            $request = $this->requestStack->getCurrentRequest();
            $session = $request->hasSession() ? $request->getSession() : null;
            $flashBag = null !== $session ? $session->getFlashBag() : null;

            // check if a file has been uploaded properly without errors
            if (UPLOAD_ERR_OK !== $file->getError()) {
                if (null !== $flashBag) {
                    $flashBag->add('error', $file->getErrorMessage());
                }
                $this->logger->error(
                    '{app}: User {user} tried to upload a file with errors: ' . $file->getErrorMessage(),
                    ['app' => '«appName»', 'user' => $this->currentUserApi->get('uname')]
                );

                return false;
            }

            // extract file extension
            $fileName = $file->getClientOriginalName();
            $extension = $this->determineFileExtension($file);

            // validate extension
            $isValidExtension = $this->isAllowedFileExtension($objectType, $fieldName, $extension);
            if (false === $isValidExtension) {
                if (null !== $flashBag) {
                    $flashBag->add(
                        'error',
                        $this->trans('Error! This file type is not allowed. Please choose another file format.')
                    );
                }
                $logArgs = [
                    'app' => '«appName»',
                    'user' => $this->currentUserApi->get('uname'),
                    'extension' => $extension,
                ];
                $this->logger->error(
                    '{app}: User {user} tried to upload a file with a forbidden extension ("{extension}").',
                    $logArgs
                );

                return false;
            }

            return true;
        }
    '''

    def private doImageFileValidation(Application it, String fileVar) '''
        // validate image file
        $isImage = in_array($extension, $this->imageFileTypes, true);
        if ($isImage) {
            $imgInfo = getimagesize(«fileVar»);
            if (!is_array($imgInfo) || !$imgInfo[0] || !$imgInfo[1]) {
                if (null !== $flashBag) {
                    $flashBag->add('error', $this->trans('Error! This file type seems not to be a valid image.'));
                }
                $this->logger->error(
                    '{app}: User {user} tried to upload a file which is seems not to be a valid image.',
                    ['app' => '«appName»', 'user' => $this->currentUserApi->get('uname')]
                );

                return $result;
            }
        }
    '''

    def private readMetaDataForFile(Application it) '''
        /**
         * Read meta data from a certain file.
         */
        public function readMetaDataForFile(string $fileName, string $filePath, bool $includeExif = true): array
        {
            $meta = [];
            if (empty($fileName)) {
                return $meta;
            }

            $extensionarr = explode('.', $fileName);
            $meta['extension'] = mb_strtolower($extensionarr[count($extensionarr) - 1]);
            $meta['size'] = filesize($filePath);
            $meta['isImage'] = in_array($meta['extension'], $this->imageFileTypes, true);

            if (!$meta['isImage']) {
                return $meta;
            }

            if ('swf' === $meta['extension']) {
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

            if (!$includeExif || 'jpg' !== $meta['extension']) {
                return $meta;
            }

            // add EXIF data
            $exifData = $this->readExifData($filePath);
            $meta = array_merge($meta, $exifData);

            return $meta;
        }

        /**
         * Read EXIF data from a certain file.
         */
        protected function readExifData(string $filePath): array
        {
            $imagine = new Imagine();
            $image = $imagine
                ->setMetadataReader(new ExifMetadataReader())
                ->open($filePath)
            ;

            $exifData = $image->metadata()->toArray();

            // strip non-utf8 chars to bypass firmware bugs (e.g. Samsung)
            foreach ($exifData as $k => $v) {
                if (is_array($v)) {
                    foreach ($v as $kk => $vv) {
                        $exifData[$k][$kk] = mb_convert_encoding($vv, 'UTF-8', 'UTF-8');
                        if (false !== mb_strpos($exifData[$k][$kk], '????')) {
                            unset($exifData[$k][$kk]);
                        }
                    }
                } else {
                    $exifData[$k] = mb_convert_encoding((string) $v, 'UTF-8', 'UTF-8');
                    if (false !== mb_strpos($exifData[$k], '????')) {
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
         * @return string[] List of allowed file extensions
         */
        public function getAllowedFileExtensions(string $objectType, string $fieldName): array
        {
            // determine the allowed extensions
            $allowedExtensions = [];
            switch ($objectType) {
                «FOR entity : getUploadEntities.filter(Entity)»«entity.getAllowedFileExtensionsEntityCase»«ENDFOR»
            }

            return $allowedExtensions;
        }
    '''

    def private isAllowedFileExtension(Application it) '''
        /**
         * Determines whether a certain file extension is allowed for a given object type and field.
         */
        protected function isAllowedFileExtension(string $objectType, string $fieldName, string $extension): bool
        {
            // determine the allowed extensions
            $allowedExtensions = $this->getAllowedFileExtensions($objectType, $fieldName);

            if (count($allowedExtensions) > 0 && '*' !== $allowedExtensions[0]) {
                if (!in_array($extension, $allowedExtensions, true)) {
                    return false;
                }
            }

            return !in_array($extension, $this->forbiddenFileTypes, true);
        }
    '''

    def private getAllowedFileExtensionsEntityCase(Entity it) '''
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

    def private getAllowedFileExtensionsFieldCase(UploadField it) '''
        case '«name.formatForCode»':
            $allowedExtensions = ['«allowedExtensions.replace(', ', "', '")»'];
            break;
    '''

    def private determineFileExtension(Application it) '''
        /**
         * Determines the extension for a given file.
         */
        protected function determineFileExtension(UploadedFile $file): string
        {
            $fileName = $file->getClientOriginalName();
            $fileNameParts = explode('.', $fileName);
            $extension = null !== $file->guessExtension() ? $file->guessExtension() : $file->guessClientExtension();
            if (in_array($extension, ['bin', 'mpga'], true)) {
                // fallback to given extension for mp3
                $extension = mb_strtolower($fileNameParts[count($fileNameParts) - 1]);
            }
            if (null === $extension) {
                $extension = mb_strtolower($fileNameParts[count($fileNameParts) - 1]);
            }

            return str_replace('jpeg', 'jpg', $extension);
        }
    '''

    def private determineFileName(Application it) '''
        /**
         * Determines the final filename for a given input filename.
         * It considers different strategies for computing the result.
         */
        protected function determineFileName(string $objectType, string $fieldName, string $basePath, string $fileName, string $extension): string
        {
            $namingScheme = 0;
            switch ($objectType) {
                «FOR entity : getUploadEntities.filter(Entity)»«entity.determineFileNameEntityCase»«ENDFOR»
            }

            if (0 === $namingScheme || 3 === $namingScheme) {
                // clean the given file name
                $fileNameCharCount = mb_strlen($fileName);
                for ($y = 0; $y < $fileNameCharCount; ++$y) {
                    if (preg_match('/[^0-9A-Za-z_\.]/', $fileName[$y])) {
                        $fileName[$y] = '_';
                    }
                }
            }
            $backupFileName = $fileName;

            $iterIndex = -1;
            do {
                if (0 === $namingScheme || 3 === $namingScheme) {
                    // original (0) or user defined (3) file name with counter
                    if (0 < $iterIndex) {
                        // strip off extension
                        $fileName = str_replace('.' . $extension, '', $backupFileName);
                        // append incremented number
                        $fileName .= (string) ++$iterIndex;
                        // readd extension
                        $fileName .= '.' . $extension;
                    } else {
                        ++$iterIndex;
                    }
                } elseif (1 === $namingScheme) {
                    // md5 name
                    $fileName = md5(uniqid((string) mt_rand(), true)) . '.' . $extension;
                } elseif (2 === $namingScheme) {
                    // prefix with random number
                    $fileName = $fieldName . random_int(1, 999999) . '.' . $extension;
                }
            } while (file_exists($basePath . $fileName)); // repeat until we have a new name

            // return the final file name
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
         */
        public function deleteUploadFile(EntityInterface $entity, string $fieldName): EntityInterface
        {
            $objectType = $entity->get_objectType();
            if (!in_array($objectType, $this->allowedObjectTypes, true)) {
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
         * @throws Exception If an invalid object type is used
         */
        public function getFileBaseFolder(string $objectType, string $fieldName = '', bool $ignoreCreate = false): string
        {
            $basePath = $this->dataDirectory . '/«appName»/';

            switch ($objectType) {
                «FOR entity : getUploadEntities.filter(Entity)»
                    «val uploadFields = entity.getUploadFieldsEntity»
                    case '«entity.name.formatForCode»':
                        «IF uploadFields.size > 1»
                            $basePath .= '«entity.nameMultiple.formatForDB»/';
                            if ('' !== $fieldName) {
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
                            if ('' !== $fieldName) {
                                $basePath .= '«uploadFields.head.subFolderPathSegment»/';
                            }
                        «ENDIF»
                        break;
                «ENDFOR»
                default:
                    throw new Exception($this->trans('Error! Invalid object type received.'));
            }

            $result = $basePath;
            if ('/' !== mb_substr($result, -1, 1)) {
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
         */
        public function checkAndCreateAllUploadFolders(): bool
        {
            $result = true;
            «FOR uploadEntity : getUploadEntities»

                «FOR uploadField : uploadEntity.getUploadFieldsEntity»
                    $result = $result && $this->checkAndCreateUploadFolder('«uploadField.entity.name.formatForCode»', '«uploadField.name.formatForCode»', '«uploadField.allowedExtensions»');
                «ENDFOR»
            «ENDFOR»

            return $result;
        }
    '''

    def private checkAndCreateUploadFolder(Application it) '''
        /**
         * Creates an upload folder and a .htaccess file within it.
         */
        protected function checkAndCreateUploadFolder(string $objectType, string $fieldName, string $allowedExtensions = ''): bool
        {
            $uploadPath = $this->projectDir . '/' . $this->getFileBaseFolder($objectType, $fieldName, true);

            $request = $this->requestStack->getCurrentRequest();
            $session = $request->hasSession() ? $request->getSession() : null;
            $flashBag = null !== $session ? $session->getFlashBag() : null;

            // Check if directory exist and try to create it if needed
            if (!$this->filesystem->exists($uploadPath)) {
                try {
                    $this->filesystem->mkdir($uploadPath, 0777);
                } catch (IOExceptionInterface $exception) {
                    if (null !== $flashBag) {
                        $flashBag->add(
                            'error',
                            $this->trans(
                                'The upload directory "%path%" does not exist and could not be created. Try to create it yourself and make sure that this folder is accessible via the web and writable by the webserver.',
                                ['%path%' => $exception->getPath()],
                                'config'
                            )
                        );
                    }
                    if (null !== $this->logger) {
                        $this->logger->error(
                            '{app}: The upload directory {directory} does not exist and could not be created.',
                            ['app' => '«appName»', 'directory' => $uploadPath]
                        );
                    }

                    return false;
                }
            }

            // Check if directory is writable and change permissions if needed
            if (!is_writable($uploadPath)) {
                try {
                    $this->filesystem->chmod($uploadPath, 0777);
                } catch (IOExceptionInterface $exception) {
                    if (null !== $flashBag) {
                        $flashBag->add(
                            'warning',
                            $this->trans(
                                'Warning! The upload directory at "%path%" exists but is not writable by the webserver.',
                                ['%path%' => $exception->getPath()],
                                'config'
                            )
                        );
                    }
                    $this->logger->error(
                        '{app}: The upload directory {directory} exists but is not writable by the webserver.',
                        ['app' => '«appName»', 'directory' => $uploadPath]
                    );

                    return false;
                }
            }

            // Write a htaccess file into the upload directory
            $htaccessFilePath = $uploadPath . '/.htaccess';
            $htaccessFileTemplate = '«relativeAppRootPath»/«getAppDocPath»htaccessTemplate';
            if (!$this->filesystem->exists($htaccessFilePath) && $this->filesystem->exists($htaccessFileTemplate)) {
                try {
                    $extensions = str_replace(',', '|', str_replace(' ', '', $allowedExtensions));
                    $htaccessContent = str_replace(
                        '__EXTENSIONS__',
                        $extensions,
                        file_get_contents($htaccessFileTemplate, false)
                    );
                    $this->filesystem->dumpFile($htaccessFilePath, $htaccessContent);
                } catch (IOExceptionInterface $exception) {
                    if (null !== $flashBag) {
                        $flashBag->add(
                            'error',
                            $this->trans(
                                'An error occured during creation of the .htaccess file in directory "%path%".',
                                ['%path%' => $exception->getPath()],
                                'config'
                            )
                        );
                    }
                    $this->logger->error(
                        '{app}: An error occured during creation of the .htaccess file in directory {directory}.',
                        ['app' => '«appName»', 'directory' => $uploadPath]
                    );

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
