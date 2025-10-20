package org.zikula.modulestudio.generator.cartridges.symfony.controller.helper

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.UploadField
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
            'Psr\\Log\\LoggerInterface',
            'Symfony\\Bundle\\SecurityBundle\\Security',
            'Symfony\\Component\\DependencyInjection\\Attribute\\Autowire',
            'Symfony\\Component\\Filesystem\\Exception\\IOExceptionInterface',
            'Symfony\\Component\\Filesystem\\Filesystem',
            'Symfony\\Component\\HttpFoundation\\File\\File',
            'Symfony\\Component\\HttpFoundation\\File\\UploadedFile',
            'Symfony\\Component\\HttpFoundation\\RequestStack',
            'function Symfony\\Component\\String\\s',
            'Symfony\\Contracts\\Translation\\TranslatorInterface',
            'Zikula\\CoreBundle\\Translation\\TranslatorTrait',
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
            protected readonly Security $security,
            protected readonly LoggerInterface $logger,
            protected readonly array $imageConfig,
            #[Autowire(param: 'kernel.project_dir')]
            protected readonly string $projectDir,
            #[Autowire(param: 'data_directory')]
            protected readonly string $dataDirectory
        ) {
            $this->setTranslator($translator);

            $this->imageFileTypes = ['gif', 'jpeg', 'jpg', 'png'«/*, 'svg' */»];
        }

        «polishUploadedFile»

        «determineFileExtension»

        «getAllowedFileExtensions»

        «getFileBaseFolder»

        «checkAndCreateAllUploadFolders»

        «checkAndCreateUploadFolder»
        «IF hasImageFields || !getUploadVariables.filter[isImageField].empty»

            «checkIfImagineCacheDirectoryExists»
        «ENDIF»
    '''

    def private polishUploadedFile(Application it) '''
        /**
         * Custom processing for a newly created file upload.
         */
        public function polishUploadedFile(UploadedFile $file, string $objectType, string $fieldName): array
        {
            $extension = $this->determineFileExtension($file);
            $filePath = $file->getPathname();

            «doImageFileValidation('$filePath')»

            if (!$isImage || 'gif' === $extension) {
                return $filePath;
            }

            // write result into a new, unique temp file and return its path
            $tempFilePath = tempnam(sys_get_temp_dir(), 'img_') . '.' . $extension;

            // fix wrong orientation and shrink too large image if needed
            @ini_set('memory_limit', '1G');
            «autorotate»

            // check if shrinking functionality is enabled
            $configSuffix = s($objectType . '_' . $fieldName)->snake();

            if ($this->imageConfig['enable_shrinking_for_' . $configSuffix]) {
                «shrinkToMaximumSize»
            }

            return $tempFilePath;
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
                    ['app' => '«appName»', 'user' => $this->security->getUser()?->getUserIdentifier()]
                );

                return «fileVar»;
            }
        }
    '''

    def private autorotate(Application it) '''
        $imagine = new Imagine();
        $image = $imagine->open($tempFilePath);
        $autorotateFilter = new Autorotate();
        $image = $autorotateFilter->apply($image);
        $image->save($tempFilePath);
    '''

    def private shrinkToMaximumSize(Application it) '''
        // check for maximum size
        $maxWidth = $this->imageConfig['shrink_width_' . $configSuffix];
        $maxHeight = $this->imageConfig['shrink_height_' . $configSuffix];
        $thumbMode = 'inset';

        $imgInfo = getimagesize($tempFilePath);
        if ($imgInfo[0] > $maxWidth || $imgInfo[1] > $maxHeight) {
            // resize to allowed maximum size
            $imagine = new Imagine();
            $image = $imagine->open($tempFilePath);
            $thumb = $image->thumbnail(new Box($maxWidth, $maxHeight), $thumbMode);
            $thumb->save($tempFilePath);
        }
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
            $session = $request?->hasSession() ? $request->getSession() : null;
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

    def private checkIfImagineCacheDirectoryExists(Application it) '''
        /**
         * Check if cache directory exists and create it if needed.
         */
        protected function checkIfImagineCacheDirectoryExists(): void
        {
            $cacheDirectory = $this->projectDir . '/public/media/cache';
            $fs = new Filesystem();
            if ($fs->exists($cacheDirectory)) {
                return;
            }
            try {
                $parentDirectory = mb_substr($cacheDirectory, 0, -6);
                if (!$fs->exists($parentDirectory)) {
                    $fs->mkdir($parentDirectory);
                }
                $fs->mkdir($cacheDirectory);
            } catch (IOExceptionInterface) {
                «warningAboutCacheDirectory»
            }
        }
    '''

    def private warningAboutCacheDirectory(Application it) '''
        $request = $this->requestStack->getCurrentRequest();
        if ($request->hasSession() && $session = $request->getSession()) {
            $session->getFlashBag()->add(
                'warning',
                $this->trans(
                    'The cache directory "%directory%" does not exist. Please create it and make it writable for the webserver.',
                    ['%directory%' => $cacheDirectory],
                    'config'
                )
            );
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
