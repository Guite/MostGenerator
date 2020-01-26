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
        use Symfony\Component\HttpFoundation\RequestStack;
        «IF targets('3.0')»
            use Symfony\Contracts\Translation\TranslatorInterface;
        «ELSE»
            use Zikula\Common\Translator\TranslatorInterface;
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
         * @var TranslatorInterface
         */
        protected $translator;

        /**
         * @var RequestStack
         */
        protected $requestStack;

        /**
         * @var VariableApiInterface
         */
        protected $variableApi;

        /**
         * Name of the application.
         *
         * @var string
         */
        protected $name;

        public function __construct(
            TranslatorInterface $translator,
            RequestStack $requestStack,
            VariableApiInterface $variableApi
        ) {
            $this->translator = $translator;
            $this->requestStack = $requestStack;
            $this->variableApi = $variableApi;
            $this->name = '«appName»';
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
         «IF !targets('3.0')»
         *
         * @param string $objectType Currently treated entity type
         * @param string $fieldName Name of upload field
         * @param string $context Usage context (allowed values: controllerAction, api, actionHandler, block, contentType)
         * @param array $args Additional arguments
         *
         * @return array The selected runtime options
         «ENDIF»
         */
        public function getRuntimeOptions(«IF targets('3.0')»string «ENDIF»$objectType = '', «IF targets('3.0')»string «ENDIF»$fieldName = '', «IF targets('3.0')»string «ENDIF»$context = '', array $args = [])«IF targets('3.0')»: array«ENDIF»
        {
            «IF hasImageFields || !getUploadVariables.filter[isImageField].empty»
                $this->checkIfImagineCacheDirectoryExists();

            «ENDIF»
            if (!in_array($context, ['controllerAction', 'api', 'actionHandler', 'block', 'contentType'])) {
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
                        $contextName = $this->name . '_ajax_autocomplete';
                    } else {
                        $contextName = $this->name . '_' . $args['controller'] . '_' . $args['action'];
                    }
                «ELSE»
                    $contextName = $this->name . '_' . $args['controller'] . '_' . $args['action'];
                «ENDIF»
            }
            if (empty($contextName)) {
                $contextName = $this->name . '_default';
            }

            return $this->getCustomRuntimeOptions($objectType, $fieldName, $contextName, $context, $args);
        }
    '''

    def private getCustomRuntimeOptions(Application it) '''
        /**
         * This method returns an Imagine runtime options array for the given arguments.
         «IF !targets('3.0')»
         *
         * @param string $objectType Currently treated entity type
         * @param string $fieldName Name of upload field
         * @param string $contextName Name of desired context
         * @param string $context Usage context (allowed values: controllerAction, api, actionHandler, block, contentType)
         * @param array $args Additional arguments
         *
         * @return array The selected runtime options
         «ENDIF»
         */
        public function getCustomRuntimeOptions(
            «IF targets('3.0')»string «ENDIF»$objectType = '',
            «IF targets('3.0')»string «ENDIF»$fieldName = '',
            «IF targets('3.0')»string «ENDIF»$contextName = '',
            «IF targets('3.0')»string «ENDIF»$context = '',
            array $args = []
        )«IF targets('3.0')»: array«ENDIF» {
            $options = [
                'thumbnail' => [
                    'size' => [100, 100], // thumbnail width and height in pixels
                    'mode' => $this->variableApi->get(
                        '«appName»',
                        'thumbnailMode' . ucfirst($objectType) . ucfirst($fieldName),
                        ImageInterface::THUMBNAIL_INSET
                    ),
                    'extension' => null // file extension for thumbnails (jpg, png, gif; null for original file type)
                ]
            ];

            «IF needsAutoCompletion»
                if ($this->name . '_ajax_autocomplete' === $contextName) {
                    $options['thumbnail']['size'] = [100, 75];

                    return $options;
                }
            «ENDIF»
            if ($this->name . '_relateditem' === $contextName) {
                $options['thumbnail']['size'] = [100, 75];
            } elseif ('controllerAction' === $context) {
                if (in_array($args['action'], ['view', 'display', 'edit'])) {
                    $fieldSuffix = ucfirst($objectType) . ucfirst($fieldName) . ucfirst($args['action']);
                    $defaultWidth = 'view' === $args['action'] ? 32 : 240;
                    $defaultHeight = 'view' === $args['action'] ? 24 : 180;
                    $options['thumbnail']['size'] = [
                        $this->variableApi->get('«appName»', 'thumbnailWidth' . $fieldSuffix, $defaultWidth),
                        $this->variableApi->get('«appName»', 'thumbnailHeight' . $fieldSuffix, $defaultHeight)
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
        protected function checkIfImagineCacheDirectoryExists()«IF targets('3.0')»: void«ENDIF»
        {
            $cachePath = '«IF targets('3.0')»public«ELSE»web«ENDIF»/imagine/cache';
            if (file_exists($cachePath)) {
                return;
            }
            if (!$this->requestStack->getCurrentRequest()->hasSession()) {
                return;
            }
            $session = $this->requestStack->getCurrentRequest()->getSession();
            $session->getFlashBag()->add(
                'warning',
                $this->translator->«IF targets('3.0')»trans«ELSE»__f«ENDIF»(
                    'The cache directory "%directory%" does not exist. Please create it and make it writable for the webserver.',
                    ['%directory%' => $cachePath]«IF targets('3.0') && !isSystemModule»,
                    'config'«ENDIF»
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

            «IF !targets('3.0')»
            /**
             * @param string $secret
             */
            «ENDIF»
            public function __construct(«IF targets('3.0')»string «ENDIF»$secret)
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

                return substr(
                    preg_replace('/[^a-zA-Z0-9-_]/', '', $encodedPath),
                    0,
                    8
                );
            }

            public function check($hash, $path, array $runtimeConfig = null)
            {
                return true;//$hash === $this->sign($path, $runtimeConfig);
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
