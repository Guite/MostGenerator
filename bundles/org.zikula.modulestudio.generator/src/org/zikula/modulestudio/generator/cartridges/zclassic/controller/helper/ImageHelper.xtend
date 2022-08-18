package org.zikula.modulestudio.generator.cartridges.zclassic.controller.helper

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.UploadField
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ImageHelper {

    extension ModelExtensions = new ModelExtensions
    extension ModelJoinExtensions = new ModelJoinExtensions
    extension Utils = new Utils

    /**
     * Entry point for the helper class creation.
     */
    def generate(Application it, IMostFileSystemAccess fsa) {
        'Generating helper class for image handling'.printIfNotTesting(fsa)
        fsa.generateClassPair('Helper/ImageHelper.php', imageFunctionsBaseImpl, imageFunctionsImpl)
        if (hasImageFields || !getAllVariables.filter(UploadField).filter[isImageField].empty) {
            fsa.generateClassPair('Imagine/Cache/DummySigner.php', dummySignerBaseImpl, dummySignerImpl)
        }
    }

    def private imageFunctionsBaseImpl(Application it) '''
        namespace «appNamespace»\Helper\Base;

        use Imagine\Image\ImageInterface;
        «IF hasImageFields || !getUploadVariables.filter[isImageField].empty»
            use Symfony\Component\Filesystem\Exception\IOExceptionInterface;
            use Symfony\Component\Filesystem\Filesystem;
        «ENDIF»
        use Symfony\Component\HttpFoundation\RequestStack;
        use Symfony\Contracts\Translation\TranslatorInterface;
        «IF hasImageFields || !getUploadVariables.filter[isImageField].empty»
            use Zikula\Bundle\CoreBundle\HttpKernel\ZikulaHttpKernelInterface;
        «ENDIF»
        use Zikula\ExtensionsModule\Api\ApiInterface\VariableApiInterface;

        /**
         * Helper base class for image methods.
         */
        abstract class AbstractImageHelper
        {
            «helperBaseImpl»
        }
    '''

    def private helperBaseImpl(Application it) '''
        /**
         * Name of the application.
         */
        protected string $applicationName;

        public function __construct(
            «IF hasImageFields || !getUploadVariables.filter[isImageField].empty»
                protected ZikulaHttpKernelInterface $kernel,
            «ENDIF»
            protected TranslatorInterface $translator,
            protected RequestStack $requestStack,
            protected VariableApiInterface $variableApi
        ) {
            $this->applicationName = '«appName»';
        }

        «getRuntimeOptions»

        «getCustomRuntimeOptions»
        «IF hasImageFields || !getUploadVariables.filter[isImageField].empty»

            «checkIfImagineCacheDirectoryExists»
        «ENDIF»
    '''

    def private getRuntimeOptions(Application it) '''
        /**
         * This method returns an Imagine runtime options array for the given arguments.
         */
        public function getRuntimeOptions(string $objectType = '', string $fieldName = '', string $context = '', array $args = []): array
        {
            «IF hasImageFields || !getUploadVariables.filter[isImageField].empty»
                $this->checkIfImagineCacheDirectoryExists();

            «ENDIF»
            if (!in_array($context, ['controllerAction', 'api', 'actionHandler'], true)) {
                $context = 'controllerAction';
            }

            $contextName = '';
            if ('controllerAction' === $context) {
                if (!isset($args['controller'])) {
                    $args['controller'] = 'user';
                }
                if (!isset($args['action'])) {
                    $args['action'] = 'index';
                }

                «IF needsAutoCompletion»
                    if ('ajax' === $args['controller'] && 'getItemListAutoCompletion' === $args['action']) {
                        $contextName = $this->applicationName . '_ajax_autocomplete';
                    } else {
                        $contextName = $this->applicationName . '_' . $args['controller'] . '_' . $args['action'];
                    }
                «ELSE»
                    $contextName = $this->applicationName . '_' . $args['controller'] . '_' . $args['action'];
                «ENDIF»
            }
            if (empty($contextName)) {
                $contextName = $this->applicationName . '_default';
            }

            return $this->getCustomRuntimeOptions($objectType, $fieldName, $contextName, $context, $args);
        }
    '''

    def private getCustomRuntimeOptions(Application it) '''
        /**
         * This method returns an Imagine runtime options array for the given arguments.
         */
        public function getCustomRuntimeOptions(
            string $objectType = '',
            string $fieldName = '',
            string $contextName = '',
            string $context = '',
            array $args = []
        ): array {
            $options = [
                'thumbnail' => [
                    'size' => [100, 100], // thumbnail width and height in pixels
                    'mode' => $this->variableApi->get(
                        '«appName»',
                        'thumbnailMode' . ucfirst($objectType) . ucfirst($fieldName),
                        ImageInterface::THUMBNAIL_INSET
                    ),
                    'extension' => null, // file extension for thumbnails (jpg, png, gif; null for original file type)
                ],
            ];

            «IF needsAutoCompletion»
                if ($this->applicationName . '_ajax_autocomplete' === $contextName) {
                    $options['thumbnail']['size'] = [100, 75];

                    return $options;
                }
            «ENDIF»
            if ($this->applicationName . '_relateditem' === $contextName) {
                $options['thumbnail']['size'] = [100, 75];
            } elseif ('controllerAction' === $context) {
                if (in_array($args['action'], ['view', 'display', 'edit'])) {
                    $fieldSuffix = ucfirst($objectType) . ucfirst($fieldName) . ucfirst($args['action']);
                    $defaultWidth = 'view' === $args['action'] ? 32 : 240;
                    $defaultHeight = 'view' === $args['action'] ? 24 : 180;
                    $options['thumbnail']['size'] = [
                        $this->variableApi->get('«appName»', 'thumbnailWidth' . $fieldSuffix, $defaultWidth),
                        $this->variableApi->get('«appName»', 'thumbnailHeight' . $fieldSuffix, $defaultHeight),
                    ];
                }
            }

            return $options;
        }
    '''

    def private imageFunctionsImpl(Application it) '''
        namespace «appNamespace»\Helper;

        use «appNamespace»\Helper\Base\AbstractImageHelper;

        /**
         * Helper implementation class for image methods.
         */
        class ImageHelper extends AbstractImageHelper
        {
            // feel free to add your own convenience methods here
        }
    '''

    def private checkIfImagineCacheDirectoryExists(Application it) '''
        /**
         * Check if cache directory exists and create it if needed.
         */
        protected function checkIfImagineCacheDirectoryExists(): void
        {
            $cacheDirectory = $this->kernel->getProjectDir() . '/public/media/cache';
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
                $this->translator->trans(
                    'The cache directory "%directory%" does not exist. Please create it and make it writable for the webserver.',
                    ['%directory%' => $cacheDirectory],
                    'config'
                )
            );
        }
    '''

    def private dummySignerBaseImpl(Application it) '''
        namespace «appNamespace»\Imagine\Cache\Base;

        use Liip\ImagineBundle\Imagine\Cache\SignerInterface;

        /**
         * Temporary dummy signer until https://github.com/liip/LiipImagineBundle/issues/837 has been resolved.
         */
        abstract class AbstractDummySigner implements SignerInterface
        {
            /**
             * @var string
             */
            protected $secret;

            public function __construct(string $secret)
            {
                $this->secret = $secret;
            }

            public function sign($path, array $runtimeConfig = null)
            {
                if ($runtimeConfig) {
                    array_walk_recursive($runtimeConfig, function (&$value) {
                        $value = (string) $value;
                    });
                }

                $encodedPath = base64_encode(
                    hash_hmac(
                        'sha256',
                        ltrim($path, '/')
                            . (null === $runtimeConfig ?: serialize($runtimeConfig)),
                        $this->secret,
                        true
                    )
                );

                return mb_substr(
                    preg_replace('/[^a-zA-Z0-9-_]/', '', $encodedPath),
                    0,
                    8
                );
            }

            public function check($hash, $path, array $runtimeConfig = null)
            {
                return true; //$hash === $this->sign($path, $runtimeConfig);
            }
        }
    '''

    def private dummySignerImpl(Application it) '''
        namespace «appNamespace»\Imagine\Cache;

        use «appNamespace»\Imagine\Cache\Base\AbstractDummySigner;

        /**
         * Temporary dummy signer until https://github.com/liip/LiipImagineBundle/issues/837 has been resolved.
         */
        class DummySigner extends AbstractDummySigner
        {
            // feel free to add your own convenience methods here
        }
    '''
}
