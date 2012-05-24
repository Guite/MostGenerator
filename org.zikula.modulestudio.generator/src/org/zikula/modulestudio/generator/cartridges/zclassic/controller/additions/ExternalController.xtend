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
        val controllerPath = appName.getAppSourceLibPath + 'Controller/'
        fsa.generateFile(controllerPath + 'Base/External.php', externalBaseFile)
        fsa.generateFile(controllerPath + 'External.php', externalFile)
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
		/**
		 * Controller for external calls base class.
		 */
		class «appName»_Controller_Base_External extends Zikula_AbstractController
		{
            «new ControllerHelper().controllerPostInitialize(it, false)»

		    «externalBaseImpl»
		}
    '''

    def private externalBaseImpl(Application it) '''
        /**
         * Displays one item of a certain object type using a separate template for external usages.
         *
         * @param string $ot          The object type
         * @param int    $id          Identifier of the item to be shown
         * @param string $source      Source of this call (contentType or scribite)
         * @param string $displayMode Display mode (link or embed)
         *
         * @return string Desired data output
         */
        public function display($args)
        {
            $getData = $this->request->query;

            $objectType = isset($args['objectType']) ? $args['objectType'] : '';
            $utilArgs = array('controller' => 'external', 'action' => 'display');
            if (!in_array($objectType, «appName»_Util_Controller::getObjectTypes('controller', $utilArgs))) {
                $objectType = «appName»_Util_Controller::getDefaultObjectType('controllerType', $utilArgs);
            }

            $id = (isset($args['id'])) ? $args['id'] : $getData->filter('id', null, FILTER_SANITIZE_STRING);

            $component = $this->name . ':' . ucwords($objectType) . ':';
            if (!SecurityUtil::checkPermission($component, $id . '::', ACCESS_READ)) {
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
            $idFields = ModUtil::apiFunc('«appName»', 'selection', 'getIdFields', array('ot' => $objectType));
            $idValues = array('id' => $id);«/** TODO consider composite keys properly */»

            $hasIdentifier = «appName»_Util_Controller::isValidIdentifier($idValues);
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
            if (SecurityUtil::checkPermission($component, $instance, ACCESS_COMMENT)) $accessLevel = ACCESS_COMMENT;
            if (SecurityUtil::checkPermission($component, $instance, ACCESS_EDIT)) $accessLevel = ACCESS_EDIT;
            $this->view->setCacheId($objectType . '|' . $id . '|a' . $accessLevel);

            $view->assign('objectType', $objectType)
                 ->assign('source', $source)
                 ->assign('item', $objectData)
                 ->assign('displayMode', $displayMode);

            return $view->fetch('external/' . $objectType . '/display.tpl');
        }

        /**
         * Popup selector for scribite plugins.
         * Finds items of a certain object type.
         *
         * @return output The external item finder page
         */
        public function finder($args)
        {
            PageUtil::addVar('stylesheet', ThemeUtil::getModuleStylesheet('«appName»'));

            $getData = $this->request->query;
            $objectType = isset($args['objectType']) ? $args['objectType'] : $getData->filter('objectType', '«getLeadingEntity.name.formatForCode»', FILTER_SANITIZE_STRING);
            $utilArgs = array('controller' => 'external', 'action' => 'finder');
            if (!in_array($objectType, «appName»_Util_Controller::getObjectTypes('controller', $utilArgs))) {
                $objectType = «appName»_Util_Controller::getDefaultObjectType('controllerType', $utilArgs);
            }

            $this->throwForbiddenUnless(SecurityUtil::checkPermission('«appName»:' . ucwords($objectType) . ':', '::', ACCESS_COMMENT), LogUtil::getErrorMsgPermission());

            $repository = $this->entityManager->getRepository('«appName»_Entity_' . ucfirst($objectType));

            $editor = (isset($args['editor']) && !empty($args['editor'])) ? $args['editor'] : $getData->filter('editor', '', FILTER_SANITIZE_STRING);
            if (empty($editor) || !in_array($editor, array('xinha', 'tinymce'/*, 'ckeditor'*/))) {
                return 'Error: Invalid editor context given for external controller action.';
            }
            «IF hasCategorisableEntities»
                $categoryId = (isset($args['catid'])) ? $args['catid'] : $getData->filter('catid', 0, FILTER_VALIDATE_INT);
                if (!is_numeric($categoryId)) {
                    $categoryId = 0;
                }

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
                 «IF hasCategorisableEntities»
                     ->assign('catId', $categoryId)
                     ->assign('mainCategory', ModUtil::apiFunc('«appName»', 'category', 'getMainCat', array('ot' => $objectType))
                 «ENDIF»
                 ->assign('sort', $sort)
                 ->assign('sortdir', $sdir)
                 ->assign('currentPage', $currentPage)
                 ->assign('pager', array('numitems'     => $objectCount,
                                         'itemsperpage' => $resultsPerPage));
            return $view->display('external/' . $objectType . '/find.tpl');
        }
    '''

    def private externalImpl(Application it) '''
        /**
         * Controller for external calls implementation class.
         */
        class «appName»_Controller_External extends «appName»_Controller_Base_External
        {
            // feel free to extend the external controller here
        }
    '''
}
