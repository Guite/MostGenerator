package org.zikula.modulestudio.generator.cartridges.zclassic.controller.additions

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.ControllerHelper
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.cartridges.zclassic.view.additions.ExternalView
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.GeneratorSettingsExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ExternalController {
    @Inject extension FormattingExtensions = new FormattingExtensions
    @Inject extension GeneratorSettingsExtensions = new GeneratorSettingsExtensions
    @Inject extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    @Inject extension ModelExtensions = new ModelExtensions
    @Inject extension NamingExtensions = new NamingExtensions
    @Inject extension Utils = new Utils

    FileHelper fh = new FileHelper()

    def generate(Application it, IFileSystemAccess fsa) {
        println('Generating external controller')
        val controllerPath = getAppSourceLibPath + 'Controller/'
        val controllerClassSuffix = if (!targets('1.3.5')) 'Controller' else ''
        val controllerFileName = 'External' + controllerClassSuffix + '.php'
        if (!shouldBeSkipped(controllerPath + 'Base/' + controllerFileName)) {
            fsa.generateFile(controllerPath + 'Base/' + controllerFileName, externalBaseFile)
        }
        if (!generateOnlyBaseClasses && !shouldBeSkipped(controllerPath + controllerFileName)) {
            fsa.generateFile(controllerPath + controllerFileName, externalFile)
        }
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
        namespace «appNamespace»\Controller\Base;

        use «appNamespace»\Util\ControllerUtil;

        use LogUtil;
        use ModUtil;
        use PageUtil;
        use SecurityUtil;
        use ThemeUtil;
        use Zikula_AbstractController;
        use Zikula_View;
        use Zikula\Core\Response\PlainResponse;

    «ENDIF»
    /**
     * Controller for external calls base class.
     */
    class «IF targets('1.3.5')»«appName»_Controller_Base_External«ELSE»ExternalController«ENDIF» extends Zikula_AbstractController
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
         * @param string $ot          The object type.
         * @param int    $id          Identifier of the item to be shown.
         * @param string $source      Source of this call (contentType or scribite).
         * @param string $displayMode Display mode (link or embed).
         *
         * @return string Desired data output.
         */
        public function display«IF targets('1.3.5')»(array $args = array())«ELSE»Action($ot, $id, $source, $displayMode)«ENDIF»
        {
            «IF targets('1.3.5')»
                $getData = $this->request->query;
            «ENDIF»
            $controllerHelper = new «IF targets('1.3.5')»«appName»_Util_Controller«ELSE»ControllerUtil«ENDIF»($this->serviceManager«IF !targets('1.3.5')», ModUtil::getModule($this->name)«ENDIF»);

            $objectType = «IF targets('1.3.5')»isset($args['objectType']) ? $args['objectType'] : $getData->filter('ot', '', FILTER_SANITIZE_STRING)«ELSE»$ot«ENDIF»;
            $utilArgs = array('controller' => 'external', 'action' => 'display');
            if (!in_array($objectType, $controllerHelper->getObjectTypes('controller', $utilArgs))) {
                $objectType = $controllerHelper->getDefaultObjectType('controllerType', $utilArgs);
            }
            «IF targets('1.3.5')»

                $id = isset($args['id']) ? $args['id'] : $getData->filter('id', null, FILTER_SANITIZE_STRING);
            «ENDIF»

            $component = $this->name . ':' . ucwords($objectType) . ':';
            if (!SecurityUtil::checkPermission($component, $id . '::', ACCESS_READ)) {
                return '';
            }

            «IF targets('1.3.5')»
                $source = isset($args['source']) ? $args['source'] : $getData->filter('source', '', FILTER_SANITIZE_STRING);
            «ENDIF»
            if (!in_array($source, array('contentType', 'scribite'))) {
                $source = 'contentType';
            }

            «IF targets('1.3.5')»
                $displayMode = isset($args['displayMode']) ? $args['displayMode'] : $getData->filter('displayMode', 'embed', FILTER_SANITIZE_STRING);
            «ENDIF»
            if (!in_array($displayMode, array('link', 'embed'))) {
                $displayMode = 'embed';
            }

            «IF targets('1.3.5')»
                $entityClass = '«appName»_Entity_' . ucwords($objectType);
            «ELSE»
                $entityClass = '\\«vendor.formatForCodeCapital»\\«name.formatForCodeCapital»Module\\Entity\\' . ucwords($objectType) . 'Entity';
            «ENDIF»
            $repository = $this->entityManager->getRepository($entityClass);
            «IF targets('1.3.5')»
                $repository->setControllerArguments(array());
            «ELSE»
                $repository->setRequest($this->request);
            «ENDIF»
            $idFields = ModUtil::apiFunc('«appName»', 'selection', 'getIdFields', array('ot' => $objectType));
            $idValues = array('id' => $id);«/** TODO consider composite keys properly */»

            $hasIdentifier = $controllerHelper->isValidIdentifier($idValues);
            //$this->throwNotFoundUnless($hasIdentifier, $this->__('Error! Invalid identifier received.'));
            if (!$hasIdentifier) {
                return $this->__('Error! Invalid identifier received.');
            }

            // assign object data fetched from the database
            $entity = $repository->selectById($idValues);
            if ((!is_array($entity) && !is_object($entity)) || !isset($entity[$idFields[0]])) {
                //$this->throwNotFound($this->__('No such item.'));
                return $this->__('No such item.');
            }

            $entity->initWorkflow();

            /*if ($controllerHelper->hasCompositeKeys($objectType)) {
                «/** TODO consider composite keys properly */»
                $instanceId = '';
                foreach ($idFields as $idField) {
                    if (!empty($instanceId)) {
                        $instanceId .= '_';
                    }
                    $instanceId .= $idValues[$idField];
                }
                $instance = $instanceId . '::';
            } else {*/
                $instance = $id . '::';
            /*}*/

            $this->view->setCaching(Zikula_View::CACHE_ENABLED);
            // set cache id
            $accessLevel = ACCESS_READ;
            if (SecurityUtil::checkPermission($component, $instance, ACCESS_COMMENT)) {
                $accessLevel = ACCESS_COMMENT;
            }
            if (SecurityUtil::checkPermission($component, $instance, ACCESS_EDIT)) {
                $accessLevel = ACCESS_EDIT;
            }
            $this->view->setCacheId($objectType . '|' . $id . '|a' . $accessLevel);

            $this->view->assign('objectType', $objectType)
                      ->assign('source', $source)
                      ->assign($objectType, $entity)
                      ->assign('displayMode', $displayMode);

            «IF targets('1.3.5')»
            return $this->view->fetch('external/' . $objectType . '/display.tpl');
            «ELSE»
            return $this->response($this->view->fetch('External/' . ucwords($objectType) . '/display.tpl'));
            «ENDIF»
        }

        /**
         * Popup selector for Scribite plugins.
         * Finds items of a certain object type.
         *
         * @param string $objectType The object type.
         * @param string $editor     Name of used Scribite editor.
         * @param string $sort       Sorting field.
         * @param string $sortdir    Sorting direction.
         * @param int    $pos        Current pager position.
         * @param int    $num        Amount of entries to display.
         *
         * @return output The external item finder page
         */
        public function finder«IF targets('1.3.5')»()«ELSE»Action($objectType, $editor, $sort, $sortdir, $pos = 1, $num = 0)«ENDIF»
        {
            PageUtil::addVar('stylesheet', ThemeUtil::getModuleStylesheet('«appName»'));

            $getData = $this->request->query;
            $controllerHelper = new «IF targets('1.3.5')»«appName»_Util_Controller«ELSE»ControllerUtil«ENDIF»($this->serviceManager«IF !targets('1.3.5')», ModUtil::getModule($this->name)«ENDIF»);

            «IF targets('1.3.5')»
                $objectType = $getData->filter('objectType', '«getLeadingEntity.name.formatForCode»', FILTER_SANITIZE_STRING);
            «ENDIF»
            $utilArgs = array('controller' => 'external', 'action' => 'finder');
            if (!in_array($objectType, $controllerHelper->getObjectTypes('controller', $utilArgs))) {
                $objectType = $controllerHelper->getDefaultObjectType('controllerType', $utilArgs);
            }

            $this->throwForbiddenUnless(SecurityUtil::checkPermission('«appName»:' . ucwords($objectType) . ':', '::', ACCESS_COMMENT), LogUtil::getErrorMsgPermission());

            «IF targets('1.3.5')»
                $entityClass = '«appName»_Entity_' . ucwords($objectType);
            «ELSE»
                $entityClass = '\\«vendor.formatForCodeCapital»\\«name.formatForCodeCapital»Module\\Entity\\' . ucwords($objectType) . 'Entity';
            «ENDIF»
            $repository = $this->entityManager->getRepository($entityClass);
            «IF targets('1.3.5')»
                $repository->setControllerArguments(array());
            «ELSE»
                $repository->setRequest($this->request);
            «ENDIF»

            «IF targets('1.3.5')»
                $editor = $getData->filter('editor', '', FILTER_SANITIZE_STRING);
            «ENDIF»
            if (empty($editor) || !in_array($editor, array('xinha', 'tinymce'/*, 'ckeditor'*/))) {
                return $this->__('Error: Invalid editor context given for external controller action.');
            }
            «IF hasCategorisableEntities»

                // fetch selected categories to reselect them in the output
                // the actual filtering is done inside the repository class
                $categoryIds = ModUtil::apiFunc('«appName»', 'category', 'retrieveCategoriesFromRequest', array('ot' => $objectType, 'source' => 'GET'));
            «ENDIF»
            «IF targets('1.3.5')»
                $sort = $getData->filter('sort', '', FILTER_SANITIZE_STRING);
            «ENDIF»
            if (empty($sort) || !in_array($sort, $repository->getAllowedSortingFields())) {
                $sort = $repository->getDefaultSortingField();
            }

            «IF targets('1.3.5')»
                $sortdir = $getData->filter('sortdir', '', FILTER_SANITIZE_STRING);
            «ENDIF»
            $sdir = strtolower($sortdir);
            if ($sdir != 'asc' && $sdir != 'desc') {
                $sdir = 'asc';
            }

            $sortParam = $sort . ' ' . $sdir;

            // the current offset which is used to calculate the pagination
            $currentPage = (int) «IF targets('1.3.5')»$getData->filter('pos', 1, FILTER_VALIDATE_INT)«ELSE»$pos«ENDIF»;

            // the number of items displayed on a page for pagination
            $resultsPerPage = (int) «IF targets('1.3.5')»$getData->filter('num', 0, FILTER_VALIDATE_INT)«ELSE»$num«ENDIF»;
            if ($resultsPerPage == 0) {
                $resultsPerPage = $this->getVar('pageSize', 20);
            }
            $where = '';
            list($entities, $objectCount) = $repository->selectWherePaginated($where, $sortParam, $currentPage, $resultsPerPage);

            foreach ($entities as $k => $entity) {
                $entity->initWorkflow();
            }

            $view = Zikula_View::getInstance('«appName»', false);

            $view->assign('editorName', $editor)
                 ->assign('objectType', $objectType)
                 ->assign('items', $entities)
                 ->assign('sort', $sort)
                 ->assign('sortdir', $sdir)
                 ->assign('currentPage', $currentPage)
                 ->assign('pager', array('numitems'     => $objectCount,
                                         'itemsperpage' => $resultsPerPage));
            «IF hasCategorisableEntities»

                // assign category properties
                $properties = null;
                if (in_array($objectType, $this->categorisableObjectTypes)) {
                    $properties = ModUtil::apiFunc('«appName»', 'category', 'getAllProperties', array('ot' => $objectType));
                }
                $view->assign('properties', $properties)
                     ->assign('catIds', $categoryIds);
            «ENDIF»

            «IF targets('1.3.5')»
            return $view->display('external/' . $objectType . '/find.tpl');
            «ELSE»
            return new PlainResponse($view->display('External/' . ucwords($objectType) . '/find.tpl'));
            «ENDIF»
        }
    '''

    def private externalImpl(Application it) '''
        «IF !targets('1.3.5')»
            namespace «appNamespace»\Controller;

            use «appNamespace»\Controller\Base\ExternalController as BaseExternalController;

        «ENDIF»
        /**
         * Controller for external calls implementation class.
         */
        «IF targets('1.3.5')»
        class «appName»_Controller_External extends «appName»_Controller_Base_External
        «ELSE»
        class ExternalController extends BaseExternalController
        «ENDIF»
        {
            // feel free to extend the external controller here
        }
    '''
}
