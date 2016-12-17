package org.zikula.modulestudio.generator.cartridges.zclassic.controller.util

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
        val helperFolder = if (isLegacy) 'Util' else 'Helper'
        generateClassPair(fsa, getAppSourceLibPath + helperFolder + '/Image' + (if (isLegacy) '' else 'Helper') + '.php',
            fh.phpFileContent(it, imageFunctionsBaseImpl), fh.phpFileContent(it, imageFunctionsImpl)
        )
        if (!isLegacy && hasImageFields) {
            generateClassPair(fsa, getAppSourceLibPath + 'Imagine/Cache/DummySigner.php',
                fh.phpFileContent(it, dummySignerBaseImpl), fh.phpFileContent(it, dummySignerImpl)
            )
        }
    }

    def private imageFunctionsBaseImpl(Application it) '''
        «IF !isLegacy»
            namespace «appNamespace»\Helper\Base;

            use Symfony\Component\HttpFoundation\Session\SessionInterface;
            use Zikula\Common\Translator\TranslatorInterface;

        «ENDIF»
        /**
         * Helper base class for image methods.
         */
        abstract class «IF isLegacy»«appName»_Util_Base_AbstractImage extends Zikula_AbstractBase«ELSE»AbstractImageHelper«ENDIF»
        {
            «IF !isLegacy»
                /**
                 * @var TranslatorInterface
                 */
                protected $translator;

                /**
                 * @var SessionInterface
                 */
                protected $session;

                /**
                 * Name of the application.
                 *
                 * @var string
                 */
                protected $name;

                /**
                 * Constructor.
                 * Initialises member vars.
                 *
                 * @param TranslatorInterface $translator Translator service instance
                 * @param SessionInterface    $session    Session service instance
                 */
                public function __construct(TranslatorInterface $translator, SessionInterface $session)
                {
                    $this->translator = $translator;
                    $this->session = $session;
                    $this->name = '«appName»';
                }

            «ENDIF»
            «getRuntimeOptions»

            «getCustomRuntimeOptions»
            «IF !isLegacy»

                «checkAndCreateImagineCacheDirectory»
            «ENDIF»
        }
    '''

    def private getRuntimeOptions(Application it) '''
        /**
         * This method returns an Imagine «IF isLegacy»preset«ELSE»runtime options array«ENDIF» for the given arguments.
         *
         * @param string $objectType Currently treated entity type
         * @param string $fieldName  Name of upload field
         * @param string $context    Usage context (allowed values: controllerAction, api, actionHandler, block, contentType)
         * @param array  $args       Additional arguments
         *
         * @return «IF isLegacy»SystemPlugin_Imagine_Preset The selected preset«ELSE»array The selected runtime options«ENDIF»
         */
        public function get«IF isLegacy»Preset«ELSE»RuntimeOptions«ENDIF»($objectType = '', $fieldName = '', $context = '', $args = «IF isLegacy»array()«ELSE»[]«ENDIF»)
        {
            «IF !isLegacy»
                $this->checkAndCreateImagineCacheDirectory();

            «ENDIF»
            if (!in_array($context, «IF isLegacy»array(«ELSE»[«ENDIF»'controllerAction', 'api', 'actionHandler', 'block', 'contentType'«IF isLegacy»)«ELSE»]«ENDIF»)) {
                $context = 'controllerAction';
            }

            $«IF isLegacy»preset«ELSE»context«ENDIF»Name = '';
            if ($context == 'controllerAction') {
                if (!isset($args['controller'])) {
                    $args['controller'] = 'user';
                }
                if (!isset($args['action'])) {
                    $args['action'] = '«IF isLegacy»main«ELSE»index«ENDIF»';
                }

                if ($args['controller'] == 'ajax' && $args['action'] == 'getItemListAutoCompletion') {
                    $«IF isLegacy»preset«ELSE»context«ENDIF»Name = $this->name . '_ajax_autocomplete';
                } else {
                    $«IF isLegacy»preset«ELSE»context«ENDIF»Name = $this->name . '_' . $args['controller'] . '_' . $args['action'];
                }
            }
            if (empty($«IF isLegacy»preset«ELSE»context«ENDIF»Name)) {
                $«IF isLegacy»preset«ELSE»context«ENDIF»Name = $this->name . '_default';
            }

            return $this->getCustom«IF isLegacy»Preset«ELSE»RuntimeOptions«ENDIF»($objectType, $fieldName, $«IF isLegacy»preset«ELSE»context«ENDIF»Name, $context, $args);
        }
    '''

    def private getCustomRuntimeOptions(Application it) '''
        /**
         * This method returns an Imagine «IF isLegacy»preset«ELSE»runtime options array«ENDIF» for the given arguments.
         *
         * @param string $objectType Currently treated entity type
         * @param string $fieldName  Name of upload field
         * @param string $«IF isLegacy»preset«ELSE»context«ENDIF»Name Name of desired «IF isLegacy»preset«ELSE»context«ENDIF»
         * @param string $context    Usage context (allowed values: controllerAction, api, actionHandler, block, contentType)
         * @param array  $args       Additional arguments
         *
         * @return «IF isLegacy»SystemPlugin_Imagine_Preset The selected preset«ELSE»array The selected runtime options«ENDIF»
         */
        public function getCustom«IF isLegacy»Preset«ELSE»RuntimeOptions«ENDIF»($objectType = '', $fieldName = '', $«IF isLegacy»preset«ELSE»context«ENDIF»Name = '', $context = '', $args = «IF isLegacy»array()«ELSE»[]«ENDIF»)
        {
            «IF isLegacy»
                $presetData = array(
                    'width'     => 100,      // thumbnail width in pixels
                    'height'    => 100,      // thumbnail height in pixels
                    'mode'      => 'inset',  // inset or outbound
                    'extension' => null      // file extension for thumbnails (jpg, png, gif; null for original file type)
                );
            «ELSE»
                $options = [
                    'thumbnail' => [
                        'size'      => [100, 100], // thumbnail width and height in pixels
                        'mode'      => 'inset',    // inset or outbound
                        'extension' => null        // file extension for thumbnails (jpg, png, gif; null for original file type)
                    ]
                ];
            «ENDIF»

            if ($«IF isLegacy»preset«ELSE»context«ENDIF»Name == $this->name . '_ajax_autocomplete') {
                «IF isLegacy»
                    $presetData['width'] = 100;
                    $presetData['height'] = 80;
                «ELSE»
                    $options['thumbnail']['size'] = [100, 80];
                «ENDIF»
            } elseif ($«IF isLegacy»preset«ELSE»context«ENDIF»Name == $this->name . '_relateditem') {
                «IF isLegacy»
                    $presetData['width'] = 50;
                    $presetData['height'] = 40;
                «ELSE»
                    $options['thumbnail']['size'] = [50, 40];
                «ENDIF»
            } elseif ($context == 'controllerAction') {
                if ($args['action'] == 'view') {
                    «IF isLegacy»
                        $presetData['width'] = 32;
                        $presetData['height'] = 20;
                    «ELSE»
                        $options['thumbnail']['size'] = [32, 20];
                    «ENDIF»
                } elseif ($args['action'] == 'display') {
                    «IF isLegacy»
                        $presetData['width'] = 250;
                        $presetData['height'] = 150;
                    «ELSE»
                        $options['thumbnail']['size'] = [250, 150];
                    «ENDIF»
                }
            }

            return «IF isLegacy»new SystemPlugin_Imagine_Preset($presetName, $presetData)«ELSE»$options«ENDIF»;
        }
    '''

    def private imageFunctionsImpl(Application it) '''
        «IF !isLegacy»
            namespace «appNamespace»\Helper;

            use «appNamespace»\Helper\Base\AbstractImageHelper;

        «ENDIF»
        /**
         * Helper implementation class for image methods.
         */
        «IF isLegacy»
        class «appName»_Util_Image extends «appName»_Util_Base_AbstractImage
        «ELSE»
        class ImageHelper extends AbstractImageHelper
        «ENDIF»
        {
            // feel free to add your own convenience methods here
        }
    '''

    def private isLegacy(Application it) {
        targets('1.3.x')
    }

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

    def private checkAndCreateImagineCacheDirectory(Application it) '''
        /**
         * Check if cache directory exists and create it if needed.
         */
        protected function checkAndCreateImagineCacheDirectory()
        {
            $cachePath = 'web/imagine/cache';
            if (file_exists($cachePath)) {
                return;
            }

            $this->session->getFlashBag()->add('warning', $this->translator->__f('The cache directory "%directory%" does not exist. Please create it and make it writable for the webserver.', ['%directory%' => $cachePath]));
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
