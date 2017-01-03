package org.zikula.modulestudio.generator.cartridges.zclassic.controller.helper

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ImageHelper {

    extension ModelExtensions = new ModelExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    FileHelper fh = new FileHelper

    /**
     * Entry point for the helper class creation.
     */
    def generate(Application it, IFileSystemAccess fsa) {
        println('Generating helper class for image handling')
        generateClassPair(fsa, getAppSourceLibPath + 'Helper/ImageHelper.php',
            fh.phpFileContent(it, imageFunctionsBaseImpl), fh.phpFileContent(it, imageFunctionsImpl)
        )
        if (hasImageFields) {
            generateClassPair(fsa, getAppSourceLibPath + 'Imagine/Cache/DummySigner.php',
                fh.phpFileContent(it, dummySignerBaseImpl), fh.phpFileContent(it, dummySignerImpl)
            )
        }
    }

    def private imageFunctionsBaseImpl(Application it) '''
        namespace «appNamespace»\Helper\Base;

        use Symfony\Component\HttpFoundation\Session\SessionInterface;
        use Zikula\Common\Translator\TranslatorInterface;
        use Zikula\ExtensionsModule\Api\VariableApi;

        /**
         * Helper base class for image methods.
         */
        abstract class AbstractImageHelper
        {
            /**
             * @var TranslatorInterface
             */
            protected $translator;

            /**
             * @var SessionInterface
             */
            protected $session;

            /**
             * @var VariableApi
             */
            protected $variableApi;

            /**
             * Name of the application.
             *
             * @var string
             */
            protected $name;

            /**
             * ImageHelper constructor.
             *
             * @param TranslatorInterface $translator  Translator service instance
             * @param SessionInterface    $session     Session service instance
             * @param VariableApi         $variableApi VariableApi service instance
             */
            public function __construct(TranslatorInterface $translator, SessionInterface $session, VariableApi $variableApi)
            {
                $this->translator = $translator;
                $this->session = $session;
                $this->variableApi = $variableApi;
                $this->name = '«appName»';
            }

            «getRuntimeOptions»

            «getCustomRuntimeOptions»
            «IF hasImageFields»

                «checkIfImagineCacheDirectoryExists»
            «ENDIF»
        }
    '''

    def private getRuntimeOptions(Application it) '''
        /**
         * This method returns an Imagine runtime options array for the given arguments.
         *
         * @param string $objectType Currently treated entity type
         * @param string $fieldName  Name of upload field
         * @param string $context    Usage context (allowed values: controllerAction, api, actionHandler, block, contentType)
         * @param array  $args       Additional arguments
         *
         * @return array The selected runtime options
         */
        public function getRuntimeOptions($objectType = '', $fieldName = '', $context = '', $args = [])
        {
            «IF hasImageFields»
                $this->checkIfImagineCacheDirectoryExists();

            «ENDIF»
            if (!in_array($context, ['controllerAction', 'api', 'actionHandler', 'block', 'contentType'])) {
                $context = 'controllerAction';
            }

            $contextName = '';
            if ($context == 'controllerAction') {
                if (!isset($args['controller'])) {
                    $args['controller'] = 'user';
                }
                if (!isset($args['action'])) {
                    $args['action'] = 'index';
                }

                if ($args['controller'] == 'ajax' && $args['action'] == 'getItemListAutoCompletion') {
                    $contextName = $this->name . '_ajax_autocomplete';
                } else {
                    $contextName = $this->name . '_' . $args['controller'] . '_' . $args['action'];
                }
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
         *
         * @param string $objectType Currently treated entity type
         * @param string $fieldName  Name of upload field
         * @param string $contextName Name of desired context
         * @param string $context    Usage context (allowed values: controllerAction, api, actionHandler, block, contentType)
         * @param array  $args       Additional arguments
         *
         * @return array The selected runtime options
         */
        public function getCustomRuntimeOptions($objectType = '', $fieldName = '', $contextName = '', $context = '', $args = [])
        {
            $options = [
                'thumbnail' => [
                    'size'      => [100, 100], // thumbnail width and height in pixels
                    'mode'      => $this->variableApi->get('«appName»', 'thumbnailMode' . ucfirst($objectType), 'inset'),
                    'extension' => null        // file extension for thumbnails (jpg, png, gif; null for original file type)
                ]
            ];

            if ($contextName == $this->name . '_ajax_autocomplete') {
                $options['thumbnail']['size'] = [100, 75];
            } elseif ($contextName == $this->name . '_relateditem') {
                $options['thumbnail']['size'] = [100, 75];
            } elseif ($context == 'controllerAction') {
                if (in_array($args['action'], ['view', 'display', 'edit'])) {
                    $fieldSuffix = ucfirst($objectType) . ucfirst($fieldName) . ucfirst($args['action']);
                    $defaultWidth = $args['action'] == 'view' ? 32 : 240;
                    $defaultHeight = $args['action'] == 'view' ? 24 : 180;
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
        protected function checkIfImagineCacheDirectoryExists()
        {
            $cachePath = 'web/imagine/cache';
            if (file_exists($cachePath)) {
                return;
            }

            $this->session->getFlashBag()->add('warning', $this->translator->__f('The cache directory "%directory%" does not exist. Please create it and make it writable for the webserver.', ['%directory%' => $cachePath]));
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
            private $secret;

            /**
             * @param string $secret
             */
            public function __construct($secret)
            {
                $this->secret = $secret;
            }

            /**
             * {@inheritdoc}
             */
            public function sign($path, array $runtimeConfig = null)
            {
                if ($runtimeConfig) {
                    array_walk_recursive($runtimeConfig, function (&$value) {
                        $value = (string) $value;
                    });
                }

                return substr(preg_replace('/[^a-zA-Z0-9-_]/', '', base64_encode(hash_hmac('sha256', ltrim($path, '/').(null === $runtimeConfig ?: serialize($runtimeConfig)), $this->secret, true))), 0, 8);
            }

            /**
             * {@inheritdoc}
             */
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
