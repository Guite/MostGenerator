package org.zikula.modulestudio.generator.cartridges.zclassic.controller.util

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ControllerUtil {
    @Inject extension FormattingExtensions = new FormattingExtensions()
    @Inject extension ModelExtensions = new ModelExtensions()
    @Inject extension NamingExtensions = new NamingExtensions()
    @Inject extension Utils = new Utils()

    FileHelper fh = new FileHelper()

    /**
     * Entry point for the Util class creation.
     */
    def generate(Application it, IFileSystemAccess fsa) {
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
            /**
             * Returns an array of all allowed object types in «appName».
             *
             * @param string $context Usage context (allowed values: controllerAction, api, actionHandler, block, contentType).
             * @param array  $args    Additional arguments.
             *
             * @return array List of allowed object types.
             */
            public static function getObjectTypes($context = '', $args = array())
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

            /**
             * Returns the default object type in «appName».
             *
             * @param string $context Usage context (allowed values: controllerAction, api, actionHandler, block, contentType).
             * @param array  $args    Additional arguments.
             *
             * @return string The name of the default object type.
             */
            public static function getDefaultObjectType($context = '', $args = array())
            {
                if (!in_array($context, array('controllerAction', 'api', 'actionHandler', 'block', 'contentType'))) {
                    $context = 'controllerAction';
                }

                $defaultObjectType = '«getLeadingEntity.name.formatForCode»';
                return $defaultObjectType;
            }

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
            public static function retrieveIdentifier(Zikula_Request_Http $request, array $args, $objectType = '', array $idFields)
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

            /**
             * Checks if all identifiers are set properly.
             *
             * @param array  $idValues List of identifier field values.
             *
             * @return boolean Whether all identifiers are set or not.
             */
            public static function isValidIdentifier(array $idValues)
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

            /**
             * Create nice permalinks.
             */
            public static function formatPermalink($name)
            {
                $name = str_replace(array('ä', 'ö', 'ü', 'Ä', 'Ö', 'Ü', 'ß', '.', '?', '"', '/', ':', 'é', 'è', 'â'),
                                    array('ae', 'oe', 'ue', 'Ae', 'Oe', 'Ue', 'ss', '', '', '', '-', '-', 'e', 'e', 'a'),
                                    $name);
                $name = DataUtil::formatPermalink($name);
                return strtolower($name);
            }
            «IF hasUploads»

                /**
                 * Retrieve the base path for given object type and upload field combination.
                 *
                 * @param string $objectType Name of treated entity type.
                 * @param string $fieldName  Name of upload field.
                 * @param array  $args       Additional arguments.
                 *
                 * @return mixed Output.
                 */
                public static function getFileBaseFolder($objectType, $fieldName)
                {
                    if (!in_array($objectType, self::getObjectTypes())) {
                        $objectType = self::getDefaultObjectType();
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

                    return $basePath;
                }
            «ENDIF»
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
