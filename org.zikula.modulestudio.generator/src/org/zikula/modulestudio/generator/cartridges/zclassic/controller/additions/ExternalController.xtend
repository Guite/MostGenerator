package org.zikula.modulestudio.generator.cartridges.zclassic.controller.additions

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.ControllerHelper
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.cartridges.zclassic.view.additions.ExternalView
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils
import org.zikula.modulestudio.generator.extensions.FormattingExtensions

class ExternalController {
    @Inject extension FormattingExtensions = new FormattingExtensions()
    @Inject extension ModelBehaviourExtensions = new ModelBehaviourExtensions()
    @Inject extension ModelExtensions = new ModelExtensions()
    @Inject extension NamingExtensions = new NamingExtensions()
    @Inject extension Utils = new Utils()

    FileHelper fh = new FileHelper()

    def generate(Application it, IFileSystemAccess fsa) {
        println('Generating external controller')
        val controllerPath = getAppSourceLibPath + 'Controller/'
        val controllerClassSuffix = if (!targets('1.3.5')) 'Controller' else ''
        val controllerFileName = 'External' + controllerClassSuffix + '.php'
        fsa.generateFile(controllerPath + 'Base/' + controllerFileName, externalBaseFile)
        fsa.generateFile(controllerPath + controllerFileName, externalFile)
        new ExternalView().generate(it, fsa)
    }

    def private externalBaseFile(Application it) '''
        «fh.phpFileHeader(it)»
        «externalBaseClass»
    '''

    def private externalFile(Application it) '''
        «fh.phpFileHeader(it)»
        «externalImpl»
    '''

    def private externalBaseClass(Application it) '''
        «IF !targets('1.3.5')»
            namespace «appName»\Controller\Base;

        «ENDIF»
        /**
         * Controller for external calls base class.
         */
        «IF targets('1.3.5')»
        class «appName»_Controller_Base_External extends Zikula_AbstractController
        «ELSE»
        class ExternalController extends \Zikula_AbstractController
        «ENDIF»
        {
        «IF hasCategorisableEntities»
            /**
             * List of object types allowing categorisation.
             *
             * @var array
             */
            protected $categorisableObjectTypes;

        «ENDIF»
        «val additionalCommands = if (hasCategorisableEntities) categoryInitialisation else ''»
    «new ControllerHelper().controllerPostInitialize(it, false, additionalCommands.toString)»

            «externalBaseImpl»
        }
    '''

    def private categoryInitialisation(Application it) '''
        $this->categorisableObjectTypes = array(«FOR entity : getCategorisableEntities SEPARATOR ', '»'«entity.name.formatForCode»'«ENDFOR»);
    '''

    def private externalBaseImpl(Application it) '''
        /**
         * Displays one item of a certain object type using a separate template for external usages.
         *
         * @param array  $args              List of arguments.
         * @param string $args[ot]          The object type
         * @param int    $args[id]          Identifier of the item to be shown
         * @param string $args[source]      Source of this call (contentType or scribite)
         * @param string $args[displayMode] Display mode (link or embed)
         *
         * @return string Desired data output.
         */
        public function display«IF !targets('1.3.5')»Action«ENDIF»(array $args = array())
        {
            $getData = $this->request->query;
            $controllerHelper = new \«appName»«IF targets('1.3.5')»_Util_Controller«ELSE»\Util\ControllerUtil«ENDIF»($this->serviceManager);

            $objectType = isset($args['objectType']) ? $args['objectType'] : '';
            $utilArgs = array('controller' => 'external', 'action' => 'display');
            if (!in_array($objectType, $controllerHelper->getObjectTypes('controller', $utilArgs))) {
                $objectType = $controllerHelper->getDefaultObjectType('controllerType', $utilArgs);
            }

            $id = (isset($args['id'])) ? $args['id'] : $getData->filter('id', null, FILTER_SANITIZE_STRING);

            $component = $this->name . ':' . ucwords($objectType) . ':';
            if (!\SecurityUtil::checkPermission($component, $id . '::', ACCESS_READ)) {
                return '';
            }

            $source = (isset($args['source'])) ? $args['source'] : $getData->filter('source', '', FILTER_SANITIZE_STRING);
            if (!in_array($source, array('contentType', 'scribite'))) {
                $source = 'contentType';
            }

            $displayMode = (isset($args['displayMode'])) ? $args['displayMode'] : $getData->filter('displayMode', 'embed', FILTER_SANITIZE_STRING);
            if (!in_array($displayMode, array('link', 'embed'))) {
                $displayMode = 'embed';
            }

            unset($args);

            $repository = $this->entityManager->getRepository('«appName»_Entity_' . ucwords($objectType));
            $idFields = \ModUtil::apiFunc('«appName»', 'selection', 'getIdFields', array('ot' => $objectType));
            $idValues = array('id' => $id);«/** TODO consider composite keys properly */»

            $hasIdentifier = $controllerHelper->isValidIdentifier($idValues);
            //$this->throwNotFoundUnless($hasIdentifier, $this->__('Error! Invalid identifier received.'));
            if (!$hasIdentifier) {
                return $this->__('Error! Invalid identifier received.');
            }

            // assign object data fetched from the database
            $objectData = null;
            $objectData = $repository->selectById($idValues);
            if ((!is_array($objectData) && !is_object($objectData)) || !isset($objectData[$idFields[0]])) {
                //$this->throwNotFound($this->__('No such item.'));
                return $this->__('No such item.');
            }

            $instance = $id . '::';«/** TODO consider composite keys properly
            $instanceId = '';
            foreach ($idFields as $idField) {
                if (!empty($instanceId)) {
                    $instanceId .= '_';
                }
                $instanceId .= $idValues[$idField];
            }
            $instance = $instanceId . '::';
             */»

            $this->view->setCaching(Zikula_View::CACHE_ENABLED);
            // set cache id
            $accessLevel = ACCESS_READ;
            if (\SecurityUtil::checkPermission($component, $instance, ACCESS_COMMENT)) $accessLevel = ACCESS_COMMENT;
            if (\SecurityUtil::checkPermission($component, $instance, ACCESS_EDIT)) $accessLevel = ACCESS_EDIT;
            $this->view->setCacheId($objectType . '|' . $id . '|a' . $accessLevel);

            $this->view->assign('objectType', $objectType)
                      ->assign('source', $source)
                      ->assign('item', $objectData)
                      ->assign('displayMode', $displayMode);

            «IF targets('1.3.5')»
            return $this->view->fetch('external/' . $objectType . '/display.tpl');
            «ELSE»
            return $this->response($this->view->fetch('External/' . ucwords($objectType) . '/display.tpl'));
            «ENDIF»
        }

        /**
         * Popup selector for scribite plugins.
         * Finds items of a certain object type.
         *
         * @param array $args List of arguments.
         *
         * @return output The external item finder page
         */
        public function finder«IF !targets('1.3.5')»Action«ENDIF»(array $args = array())
        {
            \PageUtil::addVar('stylesheet', \ThemeUtil::getModuleStylesheet('«appName»'));

            $getData = $this->request->query;
            $controllerHelper = new \«appName»«IF targets('1.3.5')»_Util_Controller«ELSE»\Util\ControllerUtil«ENDIF»($this->serviceManager);

            $objectType = isset($args['objectType']) ? $args['objectType'] : $getData->filter('objectType', '«getLeadingEntity.name.formatForCode»', FILTER_SANITIZE_STRING);
            $utilArgs = array('controller' => 'external', 'action' => 'finder');
            if (!in_array($objectType, $controllerHelper->getObjectTypes('controller', $utilArgs))) {
                $objectType = $controllerHelper->getDefaultObjectType('controllerType', $utilArgs);
            }

            $this->throwForbiddenUnless(\SecurityUtil::checkPermission('«appName»:' . ucwords($objectType) . ':', '::', ACCESS_COMMENT), \LogUtil::getErrorMsgPermission());

            $repository = $this->entityManager->getRepository('«appName»_Entity_' . ucfirst($objectType));

            $editor = (isset($args['editor']) && !empty($args['editor'])) ? $args['editor'] : $getData->filter('editor', '', FILTER_SANITIZE_STRING);
            if (empty($editor) || !in_array($editor, array('xinha', 'tinymce'/*, 'ckeditor'*/))) {
                return 'Error: Invalid editor context given for external controller action.';
            }
            «IF hasCategorisableEntities»

                // fetch selected categories to reselect them in the output
                // the actual filtering is done inside the repository class
                $categoryIds = \ModUtil::apiFunc('«appName»', 'category', 'retrieveCategoriesFromRequest', array('ot' => $objectType, 'source' => 'GET'));
            «ENDIF»
            $sort = (isset($args['sort']) && !empty($args['sort'])) ? $args['sort'] : $getData->filter('sort', '', FILTER_SANITIZE_STRING);
            if (empty($sort) || !in_array($sort, $repository->getAllowedSortingFields())) {
                $sort = $repository->getDefaultSortingField();
            }

            $sdir = (isset($args['sortdir']) && !empty($args['sortdir'])) ? $args['sortdir'] : $getData->filter('sortdir', '', FILTER_SANITIZE_STRING);
            $sdir = strtolower($sdir);
            if ($sdir != 'asc' && $sdir != 'desc') {
                $sdir = 'asc';
            }

            $sortParam = $sort . ' ' . $sdir;

            // the current offset which is used to calculate the pagination
            $currentPage = (int) (isset($args['pos']) && !empty($args['pos'])) ? $args['pos'] : $getData->filter('pos', 1, FILTER_VALIDATE_INT);

            // the number of items displayed on a page for pagination
            $resultsPerPage = (int) (isset($args['num']) && !empty($args['num'])) ? $args['num'] : $getData->filter('num', 0, FILTER_VALIDATE_INT);
            if ($resultsPerPage == 0) {
                $resultsPerPage = $this->getVar('pageSize', 20);
            }
            $where = '';
            list($objectData, $objectCount) = $repository->selectWherePaginated($where, $sortParam, $currentPage, $resultsPerPage);

            $view = Zikula_View::getInstance('«appName»', false);

            $view->assign('editorName', $editor)
                 ->assign('objectType', $objectType)
                 ->assign('objectData', $objectData)
                 ->assign('sort', $sort)
                 ->assign('sortdir', $sdir)
                 ->assign('currentPage', $currentPage)
                 ->assign('pager', array('numitems'     => $objectCount,
                                         'itemsperpage' => $resultsPerPage));
            «IF hasCategorisableEntities»

                // assign category properties
                $properties = null;
                if (in_array($objectType, $this->categorisableObjectTypes)) {
                    $properties = \ModUtil::apiFunc('«appName»', 'category', 'getAllProperties', array('ot' => $objectType));
                }
                $view->assign('properties', $properties)
                     ->assign('catIds', $categoryIds);
            «ENDIF»

            «IF targets('1.3.5')»
            return $view->display('external/' . $objectType . '/find.tpl');
            «ELSE»
            return new \Zikula\Core\Response\PlainResponse($view->display('External/' . ucwords($objectType) . '/find.tpl'));
            «ENDIF»
        }
    '''

    def private externalImpl(Application it) '''
        «IF !targets('1.3.5')»
            namespace «appName»\Controller;

        «ENDIF»
        /**
         * Controller for external calls implementation class.
         */
        «IF targets('1.3.5')»
        class «appName»_Controller_External extends «appName»_Controller_Base_External
        «ELSE»
        class ExternalController extends Base\ExternalController
        «ENDIF»
        {
            // feel free to extend the external controller here
        }
    '''
}
