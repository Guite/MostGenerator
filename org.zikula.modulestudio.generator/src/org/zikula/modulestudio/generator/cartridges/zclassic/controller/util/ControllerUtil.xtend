package org.zikula.modulestudio.generator.cartridges.zclassic.controller.util

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ControllerUtil {
    @Inject extension FormattingExtensions = new FormattingExtensions()
    @Inject extension ModelExtensions = new ModelExtensions()
    @Inject extension ModelBehaviourExtensions = new ModelBehaviourExtensions()
    @Inject extension NamingExtensions = new NamingExtensions()
    @Inject extension Utils = new Utils()

    FileHelper fh = new FileHelper()

    /**
     * Entry point for the utility class creation.
     */
    def generate(Application it, IFileSystemAccess fsa) {
        println('Generating utility class for controller layer')
        val utilPath = appName.getAppSourceLibPath + 'Util/'
        fsa.generateFile(utilPath + 'Base/Controller.php', controllerFunctionsBaseFile)
        fsa.generateFile(utilPath + 'Controller.php', controllerFunctionsFile)
    }

    def private controllerFunctionsBaseFile(Application it) '''
        «fh.phpFileHeader(it)»
        «controllerFunctionsBaseImpl»
    '''

    def private controllerFunctionsFile(Application it) '''
        «fh.phpFileHeader(it)»
        «controllerFunctionsImpl»
    '''

    def private controllerFunctionsBaseImpl(Application it) '''
        /**
         * Utility base class for controller helper methods.
         */
        class «appName»_«fillingUtil»Base_Controller extends Zikula_AbstractBase
        {
            «getObjectTypes»

            «getDefaultObjectType»

            «retrieveIdentifier»

            «isValidIdentifier»

            «formatPermalink»
            «IF hasUploads»

                «getFileBaseFolder»

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
         * @param string $context Usage context (allowed values: controllerAction, api, actionHandler, block, contentType).
         * @param array  $args    Additional arguments.
         *
         * @return array List of allowed object types.
         */
        public function getObjectTypes($context = '', $args = array())
        {
            if (!in_array($context, array('controllerAction', 'api', 'actionHandler', 'block', 'contentType'))) {
                $context = 'controllerAction';
            }

            $allowedObjectTypes = array();
            «FOR entity : getAllEntities»
                $allowedObjectTypes[] = '«entity.name.formatForCode»';
            «ENDFOR»

            return $allowedObjectTypes;
        }
    '''

    def private getDefaultObjectType(Application it) '''
        /**
         * Returns the default object type in «appName».
         *
         * @param string $context Usage context (allowed values: controllerAction, api, actionHandler, block, contentType).
         * @param array  $args    Additional arguments.
         *
         * @return string The name of the default object type.
         */
        public function getDefaultObjectType($context = '', $args = array())
        {
            if (!in_array($context, array('controllerAction', 'api', 'actionHandler', 'block', 'contentType'))) {
                $context = 'controllerAction';
            }

            $defaultObjectType = '«getLeadingEntity.name.formatForCode»';

            return $defaultObjectType;
        }
    '''

    def private retrieveIdentifier(Application it) '''
        /**
         * Retrieve identifier parameters for a given object type.
         *
         * @param Zikula_Request_Http $request    Instance of Zikula_Request_Http.
         * @param array               $args       List of arguments used as fallback if request does not contain a field.
         * @param string              $objectType Name of treated entity type.
         * @param array               $idFields   List of identifier field names.
         *
         * @return array List of fetched identifiers.
         */
        public function retrieveIdentifier(Zikula_Request_Http $request, array $args, $objectType = '', array $idFields)
        {
            $idValues = array();
            foreach ($idFields as $idField) {
                $defaultValue = isset($args[$idField]) && is_numeric($args[$idField]) ? $args[$idField] : 0;
                «/*TODO: distinguish between composite keys and other ones (which are always integers)
                         this is why the $objectType parameter is available*/»
                «/*$id = (int) $request->query->filter($idField, $defaultValue, FILTER_VALIDATE_INT);*/»
                $id = $request->query->filter($idField, $defaultValue);
                if (!$id && $idField != 'id' && count($idFields) == 1) {
                    $defaultValue = isset($args['id']) && is_numeric($args['id']) ? $args['id'] : 0;
                    $id = (int) $request->query->filter('id', $defaultValue, FILTER_VALIDATE_INT);
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
         * @param array  $idValues List of identifier field values.
         *
         * @return boolean Whether all identifiers are set or not.
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
         * @param string $name The given object title.
         *
         * @return string processed permalink.
         * @deprecated made obsolete by Doctrine extensions.
         */
        public function formatPermalink($name)
        {
            $name = str_replace(array('ä', 'ö', 'ü', 'Ä', 'Ö', 'Ü', 'ß', '.', '?', '"', '/', ':', 'é', 'è', 'â'),
                                array('ae', 'oe', 'ue', 'Ae', 'Oe', 'Ue', 'ss', '', '', '', '-', '-', 'e', 'e', 'a'),
                                $name);
            $name = DataUtil::formatPermalink($name);

            return strtolower($name);
        }
    '''

    def private getFileBaseFolder(Application it) '''
        /**
         * Retrieve the base path for given object type and upload field combination.
         *
         * @param string $objectType Name of treated entity type.
         * @param string $fieldName  Name of upload field.
         *
         * @return mixed Output.
         * @throws Exception if invalid object type is given.
         */
        public function getFileBaseFolder($objectType, $fieldName)
        {
            if (!in_array($objectType, $this->getObjectTypes())) {
                throw new Exception('Error! Invalid object type received.');
            }

            $basePath = FileUtil::getDataDirectory() . '/«appName»/';

            switch ($objectType) {
                «FOR entity : getUploadEntities»
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

            return DataUtil::formatForOS($basePath);
        }
    '''

    def private checkAndCreateUploadFolder(Application it) '''
        /**
         * Creates upload folder including a subfolder for thumbnail and an .htaccess file within it.
         *
         * @param string $objectType        Name of treated entity type.
         * @param string $fieldName         Name of upload field.
         * @param string $allowedExtensions String with list of allowed file extensions (separated by ", ").
         *
         * @return Boolean whether everything went okay or not.
         */
        public function checkAndCreateUploadFolder($objectType, $fieldName, $allowedExtensions = '')
        {
            $dom = ZLanguage::getModuleDomain('«appName»');
            $uploadPath = $this->getFileBaseFolder($objectType, $fieldName);

            // Check if directory exist and try to create it if needed
            if (!is_dir($uploadPath) && !FileUtil::mkdirs($uploadPath, 0777)) {
                LogUtil::registerStatus(__f('The upload directory "%s" does not exist and could not be created. Try to create it yourself and make sure that this folder is accessible via the web and writable by the webserver.', array($uploadPath), $dom));
                return false;
            }

            // Check if directory is writable and change permissions if needed
            if (!is_writable($uploadPath) && !chmod($uploadPath, 0777)) {
                LogUtil::registerStatus(__f('Warning! The upload directory at "%s" exists but is not writable by the webserver.', array($uploadPath), $dom));
                return false;
            }

            // Write a htaccess file into the upload directory
            $htaccessFilePath = $uploadPath . '.htaccess';
            $htaccessFileTemplate = 'modules/«appName»/docs/htaccessTemplate';
            if (!file_exists($htaccessFilePath) && file_exists($htaccessFileTemplate)) {
                $extensions = str_replace(',', '|', str_replace(' ', '', $allowedExtensions));
                $htaccessContent = str_replace('__EXTENSIONS__', $extensions, FileUtil::readFile($htaccessFileTemplate));
                if (!FileUtil::writeFile($htaccessFilePath, $htaccessContent)) {
                    LogUtil::registerStatus(__f('Warning! Could not but could not write the .htaccess file at "%s".', array($htaccessFilePath), $dom));
                    return false;
                }
            }

            return true;
        }
    '''

    def private performGeoCoding(Application it) '''
        /**
         * Example method for performing geo coding in PHP.
         * To use this please customise it to your needs in the concrete subclass.
         * There is also a method on JS level available in «getAppSourcePath(appName)»javascript/«appName»_editFunctions.js.
         *
         * @param string $address The address input string.
         *
         * @return Array The determined coordinates.
         */
        public function performGeoCoding($address)
        {
            $lang = ZLanguage::getLanguageCode();
            $url = 'http://maps.google.com/maps/api/geocode/xml?address=' . urlencode($address);
            $url .= '&region=' . $lang . '&language=' . $lang . '&sensor=false';

            // we can either use Snoopy if available
            //require_once('modules/«appName»/lib/vendor/Snoopy/Snoopy.class.php');
            //$snoopy = new Snoopy();
            //$snoopy->fetch($url);
            //$xmlContent = $snoopy->results;

            // we can also use curl
            // example do be done

            // or we can use the plain file_get_contents method
            // requires allow_url_fopen = true in php.ini which is NOT good for security
            $xmlContent = file_get_contents($url);

            // parse the markup
            $xml = new SimpleXMLElement($xmlContent);
            //$xml = simplexml_load_string($xmlContent, 'SimpleXMLElement', LIBXML_NOCDATA);

            // create the result array
            $result = array('latitude' => 0, 'longitude' => 0);

            $lat = $xml->xpath('result/geometry/location/lat');
            $result['latitude'] = (float)$lat[0];

            $lng = $xml->xpath('result/geometry/location/lng');
            $result['longitude'] = (float)$lng[0];

            return $result;
        }
    '''

    def private controllerFunctionsImpl(Application it) '''
        /**
         * Utility implementation class for controller helper methods.
         */
        class «appName»_«fillingUtil»Controller extends «appName»_«fillingUtil»Base_Controller
        {
            // feel free to add your own convenience methods here
        }
    '''
}
