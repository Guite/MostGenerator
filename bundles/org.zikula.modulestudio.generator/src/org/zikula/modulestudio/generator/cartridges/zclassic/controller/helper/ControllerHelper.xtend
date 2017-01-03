package org.zikula.modulestudio.generator.cartridges.zclassic.controller.helper

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Entity
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.GeneratorSettingsExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ControllerHelper {
    extension FormattingExtensions = new FormattingExtensions
    extension GeneratorSettingsExtensions = new GeneratorSettingsExtensions
    extension ModelExtensions = new ModelExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    FileHelper fh = new FileHelper

    /**
     * Entry point for the helper class creation.
     */
    def generate(Application it, IFileSystemAccess fsa) {
        println('Generating helper class for controller layer')
        generateClassPair(fsa, getAppSourceLibPath + 'Helper/ControllerHelper.php',
            fh.phpFileContent(it, controllerFunctionsBaseImpl), fh.phpFileContent(it, controllerFunctionsImpl)
        )
    }

    def private controllerFunctionsBaseImpl(Application it) '''
        namespace «appNamespace»\Helper\Base;

        use DataUtil;
        «IF hasUploads»
            use FileUtil;
        «ENDIF»
        «IF hasGeographical»
            use UserUtil;
        «ENDIF»
        «IF hasUploads || hasGeographical»
            use Psr\Log\LoggerInterface;
        «ENDIF»
        use Symfony\Component\DependencyInjection\ContainerBuilder;
        «IF hasUploads»
            use Symfony\Component\Filesystem\Filesystem;
            use Symfony\Component\Filesystem\Exception\IOExceptionInterface;
        «ENDIF»
        use Symfony\Component\HttpFoundation\Request;
        «IF hasUploads»
            use Symfony\Component\HttpFoundation\Session\SessionInterface;
        «ENDIF»
        use Zikula\Common\Translator\TranslatorInterface;

        /**
         * Helper base class for controller layer methods.
         */
        abstract class AbstractControllerHelper
        {
            /**
             * @var ContainerBuilder
             */
            protected $container;

            /**
             * @var TranslatorInterface
             */
            protected $translator;
            «IF hasUploads»

                /**
                 * @var SessionInterface
                 */
                protected $session;
            «ENDIF»
            «IF hasUploads || hasGeographical»

                /**
                 * @var LoggerInterface
                 */
                protected $logger;
            «ENDIF»

            /**
             * ControllerHelper constructor.
             *
             * @param ContainerBuilder    $container  ContainerBuilder service instance
             * @param TranslatorInterface $translator Translator service instance
             «IF hasUploads»
                 * @param SessionInterface    $session    Session service instance
             «ENDIF»
             «IF hasUploads || hasGeographical»
                 * @param LoggerInterface     $logger     Logger service instance
             «ENDIF»
             */
            public function __construct(ContainerBuilder $container, TranslatorInterface $translator«IF hasUploads», SessionInterface $session«ENDIF»«IF hasUploads || hasGeographical», LoggerInterface $logger«ENDIF»)
            {
                $this->container = $container;
                $this->translator = $translator;
                «IF hasUploads»
                    $this->session = $session;
                «ENDIF»
                «IF hasUploads || hasGeographical»
                    $this->logger = $logger;
                «ENDIF»
            }

            «getObjectTypes»

            «getDefaultObjectType»

            «hasCompositeKeys»

            «retrieveIdentifier»

            «isValidIdentifier»

            «formatPermalink»
            «IF hasUploads»

                «getFileBaseFolder»

                «checkAndCreateAllUploadFolders»

                «checkAndCreateUploadFolder»
            «ENDIF»
            «IF hasGeographical»

                «performGeoCoding»
            «ENDIF»
        }
    '''

    def private getObjectTypes(Application it) '''
        /**
         * Returns an array of all allowed object types in «appName».
         *
         * @param string $context Usage context (allowed values: controllerAction, api, helper, actionHandler, block, contentType, util)
         * @param array  $args    Additional arguments
         *
         * @return array List of allowed object types
         */
        public function getObjectTypes($context = '', $args = [])
        {
            if (!in_array($context, ['controllerAction', 'api', 'helper', 'actionHandler', 'block', 'contentType', 'util'])) {
                $context = 'controllerAction';
            }

            $allowedObjectTypes = [];
            «FOR entity : entities»
                $allowedObjectTypes[] = '«entity.name.formatForCode»';
            «ENDFOR»

            return $allowedObjectTypes;
        }
    '''

    def private getDefaultObjectType(Application it) '''
        /**
         * Returns the default object type in «appName».
         *
         * @param string $context Usage context (allowed values: controllerAction, api, helper, actionHandler, block, contentType, util)
         * @param array  $args    Additional arguments
         *
         * @return string The name of the default object type
         */
        public function getDefaultObjectType($context = '', $args = [])
        {
            if (!in_array($context, ['controllerAction', 'api', 'helper', 'actionHandler', 'block', 'contentType', 'util'])) {
                $context = 'controllerAction';
            }

            $defaultObjectType = '«getLeadingEntity.name.formatForCode»';

            return $defaultObjectType;
        }
    '''

    def private hasCompositeKeys(Application it) '''
        /**
         * Checks whether a certain entity type uses composite keys or not.
         *
         * @param string $objectType The object type to retrieve
         *
         * @return Boolean Whether composite keys are used or not
         */
        public function hasCompositeKeys($objectType)
        {
            switch ($objectType) {
                «FOR entity : entities»
                    case '«entity.name.formatForCode»':
                        return «entity.hasCompositeKeys.displayBool»;
                «ENDFOR»
                    default:
                        return false;
            }
        }
    '''

    def private retrieveIdentifier(Application it) '''
        /**
         * Retrieve identifier parameters for a given object type.
         *
         * @param Request $request    The current request
         * @param array   $args       List of arguments used as fallback if request does not contain a field
         * @param string  $objectType Name of treated entity type
         * @param array   $idFields   List of identifier field names
         *
         * @return array List of fetched identifiers
         */
        public function retrieveIdentifier(Request $request, array $args, $objectType = '', array $idFields)
        {
            $idValues = [];
            $routeParams = $request->get('_route_params', []);
            foreach ($idFields as $idField) {
                $defaultValue = isset($args[$idField]) && is_numeric($args[$idField]) ? $args[$idField] : 0;
                if ($this->hasCompositeKeys($objectType)) {
                    // composite key may be alphanumeric
                    if (array_key_exists($idField, $routeParams)) {
                        $id = !empty($routeParams[$idField]) ? $routeParams[$idField] : $defaultValue;
                    } elseif ($request->query->has($idField)) {
                        $id = $request->query->getAlnum($idField, $defaultValue);
                    } else {
                        $id = $defaultValue;
                    }
                } else {
                    // single identifier
                    if (array_key_exists($idField, $routeParams)) {
                        $id = (int) !empty($routeParams[$idField]) ? $routeParams[$idField] : $defaultValue;
                    } elseif ($request->query->has($idField)) {
                        $id = $request->query->getInt($idField, $defaultValue);
                    } else {
                        $id = $defaultValue;
                    }
                }

                // fallback if id has not been found yet
                if (!$id && $idField != 'id' && count($idFields) == 1) {
                    $defaultValue = isset($args['id']) && is_numeric($args['id']) ? $args['id'] : 0;
                    if (array_key_exists('id', $routeParams)) {
                        $id = (int) !empty($routeParams['id']) ? $routeParams['id'] : $defaultValue;
                    } elseif ($request->query->has('id')) {
                        $id = (int) $request->query->getInt('id', $defaultValue);
                    } else {
                        $id = $defaultValue;
                    }
                }
                $idValues[$idField] = $id;
            }

            return $idValues;
        }
    '''

    def private isValidIdentifier(Application it) '''
        /**
         * Checks if all identifiers are set properly.
         *
         * @param array  $idValues List of identifier field values
         *
         * @return boolean Whether all identifiers are set or not
         */
        public function isValidIdentifier(array $idValues)
        {
            if (!count($idValues)) {
                return false;
            }

            foreach ($idValues as $idField => $idValue) {
                if (!$idValue) {
                    return false;
                }
            }

            return true;
        }
    '''

    def private formatPermalink(Application it) '''
        /**
         * Create nice permalinks.
         *
         * @param string $name The given object title
         *
         * @return string processed permalink
         * @deprecated made obsolete by Doctrine extensions
         */
        public function formatPermalink($name)
        {
            $name = str_replace(
                ['ä', 'ö', 'ü', 'Ä', 'Ö', 'Ü', 'ß', '.', '?', '"', '/', ':', 'é', 'è', 'â'],
                ['ae', 'oe', 'ue', 'Ae', 'Oe', 'Ue', 'ss', '', '', '', '-', '-', 'e', 'e', 'a'],
                $name
            );
            $name = DataUtil::formatPermalink($name);

            return strtolower($name);
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
        public function getFileBaseFolder($objectType, $fieldName, $ignoreCreate = false)
        {
            if (!in_array($objectType, $this->getObjectTypes())) {
                throw new Exception('Error! Invalid object type received.');
            }

            $basePath = $this->container->getParameter('datadir') . '/«appName»/';

            switch ($objectType) {
                «FOR entity : getUploadEntities.filter(Entity)»
                    «val uploadFields = entity.getUploadFieldsEntity»
                    case '«entity.name.formatForCode»':
                        «IF uploadFields.size > 1»
                            $basePath .= '«entity.nameMultiple.formatForDB»/';
                            switch ($fieldName) {
                                «FOR uploadField : uploadFields»
                                    case '«uploadField.name.formatForCode»':
                                        $basePath .= '«uploadField.subFolderPathSegment»/';
                                        break;
                                «ENDFOR»
                            }
                        «ELSE»
                            $basePath .= '«entity.nameMultiple.formatForDB»/«uploadFields.head.subFolderPathSegment»/';
                        «ENDIF»
                    break;
                «ENDFOR»
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

            return $result;
        }
    '''

    def private checkAndCreateUploadFolder(Application it) '''
        /**
         * Creates upload folder including a subfolder for thumbnail and an .htaccess file within it.
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

            $fs = new Filesystem();
            $flashBag = $this->session->getFlashBag();

            // Check if directory exist and try to create it if needed
            if (!$fs->exists($uploadPath)) {
                try {
                    $fs->mkdir($uploadPath, 0777);
                } catch (IOExceptionInterface $e) {
                    $flashBag->add('error', $this->translator->__f('The upload directory "%s" does not exist and could not be created. Try to create it yourself and make sure that this folder is accessible via the web and writable by the webserver.', ['%s' => $e->getPath()]));
                    $this->logger->error('{app}: The upload directory {directory} does not exist and could not be created.', ['app' => '«appName»', 'directory' => $uploadPath]);

                    return false;
                }
            }

            // Check if directory is writable and change permissions if needed
            if (!is_writable($uploadPath)) {
                try {
                    $fs->chmod($uploadPath, 0777);
                } catch (IOExceptionInterface $e) {
                    $flashBag->add('warning', $this->translator->__f('Warning! The upload directory at "%s" exists but is not writable by the webserver.', ['%s' => $e->getPath()]));
                    $this->logger->error('{app}: The upload directory {directory} exists but is not writable by the webserver.', ['app' => '«appName»', 'directory' => $uploadPath]);

                    return false;
                }
            }

            // Write a htaccess file into the upload directory
            $htaccessFilePath = $uploadPath . '/.htaccess';
            $htaccessFileTemplate = '«rootFolder»/«if (systemModule) name.formatForCode else appName»/«getAppDocPath»htaccessTemplate';
            if (!$fs->exists($htaccessFilePath) && $fs->exists($htaccessFileTemplate)) {
                try {
                    $extensions = str_replace(',', '|', str_replace(' ', '', $allowedExtensions));
                    $htaccessContent = str_replace('__EXTENSIONS__', $extensions, file_get_contents($htaccessFileTemplate, false));
                    $fs->dumpFile($htaccessFilePath, $htaccessContent);
                } catch (IOExceptionInterface $e) {
                    $flashBag->add('error', $this->translator->__f('An error occured during creation of the .htaccess file in directory "%s".', ['%s' => $e->getPath()]));
                    $this->logger->error('{app}: An error occured during creation of the .htaccess file in directory {directory}.', ['app' => '«appName»', 'directory' => $uploadPath]);
                }
            }

            return true;
        }
    '''

    def private performGeoCoding(Application it) '''
        /**
         * Example method for performing geo coding in PHP.
         * To use this please customise it to your needs in the concrete subclass.
         * Also you have to call this method in a PrePersist-Handler of the
         * corresponding entity class.
         * There is also a method on JS level available in «getAppJsPath»«appName».EditFunctions.js.
         *
         * @param string $address The address input string
         *
         * @return Array The determined coordinates
         */
        public function performGeoCoding($address)
        {
            $lang = $this->container->get('request_stack')->getMasterRequest()->getLocale();
            $url = 'https://maps.googleapis.com/maps/api/geocode/json?address=' . urlencode($address);
            $url .= '&region=' . $lang . '&language=' . $lang . '&sensor=false';

            $json = '';

            // we can either use Snoopy if available
            //require_once('«rootFolder»/«if (systemModule) name.formatForCode else vendor.formatForCode + '/' + name.formatForCode»/vendor/Snoopy/Snoopy.class.php');
            //$snoopy = new Snoopy();
            //$snoopy->fetch($url);
            //$json = $snoopy->results;

            // we can also use curl
            if (function_exists('curl_version')) {
                $ch = curl_init();
                curl_setopt($ch, CURLOPT_RETURNTRANSFER, TRUE);
                curl_setopt($ch, CURLOPT_HEADER, 0);
                //curl_setopt($ch, CURLOPT_FOLLOWLOCATION, 1); // can cause problems with open_basedir
                curl_setopt($ch, CURLOPT_URL, $url);
                $json = curl_exec($ch);
                curl_close($ch);
            } else {
                // or we can use the plain file_get_contents method
                // requires allow_url_fopen = true in php.ini which is NOT good for security
                $json = file_get_contents($url);
            }

            // create the result array
            $result = [
                'latitude' => 0,
                'longitude' => 0
            ];

            if ($json != '') {
                $data = json_decode($json);

                if (json_last_error() == JSON_ERROR_NONE && $data->status == 'OK') {
                    $jsonResult = reset($data->results);
                    $location = $jsonResult->geometry->location;

                    $result['latitude'] = str_replace(',', '.', $location->lat);
                    $result['longitude'] = str_replace(',', '.', $location->lng);
                } else {
                    $logArgs = ['app' => '«appName»', 'user' => $this->container->get('zikula_users_module.current_user')->get('uname'), 'field' => $field, 'address' => $address];
                    $this->logger->warning('{app}: User {user} tried geocoding for address "{address}", but failed.', $logArgs);
                }
            }

            return $result;
        }
    '''

    def private controllerFunctionsImpl(Application it) '''
        namespace «appNamespace»\Helper;

        use «appNamespace»\Helper\Base\AbstractControllerHelper;

        /**
         * Helper implementation class for controller layer methods.
         */
        class ControllerHelper extends AbstractControllerHelper
        {
            // feel free to add your own convenience methods here
        }
    '''
}
