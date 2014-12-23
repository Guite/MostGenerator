package org.zikula.modulestudio.generator.cartridges.zclassic.controller.additions

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.ControllerHelper
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.cartridges.zclassic.view.additions.ExternalView
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ExternalController {
    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelExtensions = new ModelExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    FileHelper fh = new FileHelper()

    def generate(Application it, IFileSystemAccess fsa) {
        println('Generating external controller')
        generateClassPair(fsa, getAppSourceLibPath + 'Controller/External' + (if (targets('1.3.5')) '' else 'Controller') + '.php',
            fh.phpFileContent(it, externalBaseClass), fh.phpFileContent(it, externalImpl)
        )
        new ExternalView().generate(it, fsa)
    }

    def private externalBaseClass(Application it) '''
    «IF !targets('1.3.5')»
        namespace «appNamespace»\Controller\Base;

        use Symfony\Component\Security\Core\Exception\AccessDeniedException;
        use Sensio\Bundle\FrameworkExtraBundle\Configuration\Route;

        use ModUtil;
        use PageUtil;
        use SecurityUtil;
        use ThemeUtil;
        use UserUtil;
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
        «displayBase»

        «finderBase»
    '''

    def private displayBase(Application it) '''
        «displayDocBlock(true)»
        «displaySignature»
        {
            «displayBaseImpl»
        }
    '''

    def private displayDocBlock(Application it, Boolean isBase) '''
        /**
         * Displays one item of a certain object type using a separate template for external usages.
         «IF !targets('1.3.5') && !isBase»
         *
         * @Route("/display/{ot}/{id}/{source}/{displayMode}",
         *        requirements = {"id" = "\d+", "source" = "contentType|scribite", "displayMode" = "link|embed"},
         *        defaults = {"source" = "contentType", "contentType" = "embed"},
         *        methods = {"GET"}
         * )
         «ENDIF»
         *
         * @param string $ot          The currently treated object type.
         * @param int    $id          Identifier of the entity to be shown.
         * @param string $source      Source of this call (contentType or scribite).
         * @param string $displayMode Display mode (link or embed).
         *
         * @return string Desired data output.
         */
    '''

    def private displaySignature(Application it) '''
        public function display«IF targets('1.3.5')»(array $args = array())«ELSE»Action($ot, $id, $source, $displayMode)«ENDIF»
    '''

    def private displayBaseImpl(Application it) '''
        «IF targets('1.3.5')»
            $getData = $this->request->query;
            $controllerHelper = new «appName»_Util_Controller($this->serviceManager);
        «ELSE»
            $controllerHelper = $this->serviceManager->get('«appName.formatForDB».controller_helper');
        «ENDIF»

        $objectType = «IF targets('1.3.5')»isset($args['objectType']) ? $args['objectType'] : $getData->filter('ot', '', FILTER_SANITIZE_STRING)«ELSE»$ot«ENDIF»;
        $utilArgs = array('controller' => 'external', 'action' => 'display');
        if (!in_array($objectType, $controllerHelper->getObjectTypes('controller', $utilArgs))) {
            $objectType = $controllerHelper->getDefaultObjectType('controllerType', $utilArgs);
        }
        «IF targets('1.3.5')»

            $id = isset($args['id']) ? $args['id'] : $getData->filter('id', null, FILTER_SANITIZE_STRING);
        «ENDIF»

        $component = $this->name . ':' . ucfirst($objectType) . ':';
        if (!SecurityUtil::checkPermission($component, $id . '::', ACCESS_READ)) {
            return '';
        }

        «IF targets('1.3.5')»
            $source = isset($args['source']) ? $args['source'] : $getData->filter('source', '', FILTER_SANITIZE_STRING);
            if (!in_array($source, array('contentType', 'scribite'))) {
                $source = 'contentType';
            }

            $displayMode = isset($args['displayMode']) ? $args['displayMode'] : $getData->filter('displayMode', 'embed', FILTER_SANITIZE_STRING);
            if (!in_array($displayMode, array('link', 'embed'))) {
                $displayMode = 'embed';
            }

            $entityClass = '«appName»_Entity_' . ucfirst($objectType);
            $repository = $this->entityManager->getRepository($entityClass);
            $repository->setControllerArguments(array());
        «ELSE»
            $repository = $this->serviceManager->get('«appName.formatForDB».' . $objectType . '_factory')->getRepository();
            $repository->setRequest($this->request);
        «ENDIF»
        $idFields = ModUtil::apiFunc('«appName»', 'selection', 'getIdFields', array('ot' => $objectType));
        $idValues = array('id' => $id);«/** TODO consider composite keys properly */»

        $hasIdentifier = $controllerHelper->isValidIdentifier($idValues);
        if (!$hasIdentifier) {
            return $this->__('Error! Invalid identifier received.');
        }

        // assign object data fetched from the database
        $entity = $repository->selectById($idValues);
        if ((!is_array($entity) && !is_object($entity)) || !isset($entity[$idFields[0]])) {
            return $this->__('No such item.');
        }

        $entity->initWorkflow();

        $instance = $entity->createCompositeIdentifier() . '::';

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
            return $this->response($this->view->fetch('External/' . ucfirst($objectType) . '/display.tpl'));
        «ENDIF»
    '''

    def private finderBase(Application it) '''
        «finderDocBlock(true)»
        «finderSignature»
        {
            «finderBaseImpl»
        }
    '''

    def private finderDocBlock(Application it, Boolean isBase) '''
        /**
         * Popup selector for Scribite plugins.
         * Finds items of a certain object type.
         «IF !targets('1.3.5') && !isBase»
         *
         * @Route("/finder/{objectType}/{editor}/{sort}/{sortdir}/{pos}/{num}",
         *        requirements = {"editor" = "xinha|tinymce|ckeditor", "sortdir" = "asc|desc", "pos" = "\d+", "num" = "\d+"},
         *        defaults = {"sort" = "", "sortdir" = "asc", "pos" = 1, "num" = 0},
         *        methods = {"GET"},
         *        options={"expose"=true}
         * )
         «ENDIF»
         *
         * @param string $objectType The object type.
         * @param string $editor     Name of used Scribite editor.
         * @param string $sort       Sorting field.
         * @param string $sortdir    Sorting direction.
         * @param int    $pos        Current pager position.
         * @param int    $num        Amount of entries to display.
         *
         * @return output The external item finder page
         «IF !targets('1.3.5')»
         *
         * @throws AccessDeniedException Thrown if the user doesn't have required permissions
         «ENDIF»
         */
    '''

    def private finderSignature(Application it) '''
        public function finder«IF targets('1.3.5')»()«ELSE»Action($objectType, $editor, $sort, $sortdir, $pos = 1, $num = 0)«ENDIF»
    '''

    def private finderBaseImpl(Application it) '''
        «IF targets('1.3.5')»
            PageUtil::addVar('stylesheet', ThemeUtil::getModuleStylesheet('«appName»'));
        «ELSE»
            PageUtil::addVar('stylesheet', '@«appName»/Resources/public/css/style.css');
        «ENDIF»

        $getData = $this->request->query;
        «IF targets('1.3.5')»
            $controllerHelper = new «appName»_Util_Controller($this->serviceManager);
        «ELSE»
            $controllerHelper = $this->serviceManager->get('«appName.formatForDB».controller_helper');
        «ENDIF»

        «IF targets('1.3.5')»
            $objectType = $getData->filter('objectType', '«getLeadingEntity.name.formatForCode»', FILTER_SANITIZE_STRING);
        «ENDIF»
        $utilArgs = array('controller' => 'external', 'action' => 'finder');
        if (!in_array($objectType, $controllerHelper->getObjectTypes('controller', $utilArgs))) {
            $objectType = $controllerHelper->getDefaultObjectType('controllerType', $utilArgs);
        }

        «IF targets('1.3.5')»
            $this->throwForbiddenUnless(SecurityUtil::checkPermission('«appName»:' . ucfirst($objectType) . ':', '::', ACCESS_COMMENT), LogUtil::getErrorMsgPermission());
        «ELSE»
            if (!SecurityUtil::checkPermission('«appName»:' . ucfirst($objectType) . ':', '::', ACCESS_COMMENT)) {
                throw new AccessDeniedException();
            }
        «ENDIF»

        «IF targets('1.3.5')»
            $entityClass = '«appName»_Entity_' . ucfirst($objectType);
            $repository = $this->entityManager->getRepository($entityClass);
            $repository->setControllerArguments(array());
        «ELSE»
            $repository = $this->serviceManager->get('«appName.formatForDB».' . $objectType . '_factory')->getRepository();
            $repository->setRequest($this->request);
        «ENDIF»

        «IF targets('1.3.5')»
            $editor = $getData->filter('editor', '', FILTER_SANITIZE_STRING);
        «ENDIF»
        if (empty($editor) || !in_array($editor, array('xinha', 'tinymce', 'ckeditor'))) {
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
            return new PlainResponse($view->display('External/' . ucfirst($objectType) . '/find.tpl'));
        «ENDIF»
    '''

    def private externalImpl(Application it) '''
        «IF !targets('1.3.5')»
            namespace «appNamespace»\Controller;

            use «appNamespace»\Controller\Base\ExternalController as BaseExternalController;

            use Sensio\Bundle\FrameworkExtraBundle\Configuration\Route;

        «ENDIF»
        /**
         * Controller for external calls implementation class.
         «IF !targets('1.3.5')»
         *
         * @Route("/%«appName.formatForDB».routing.external%")
         «ENDIF»
         */
        «IF targets('1.3.5')»
        class «appName»_Controller_External extends «appName»_Controller_Base_External
        «ELSE»
        class ExternalController extends BaseExternalController
        «ENDIF»
        {
            «IF !targets('1.3.5')»
                «displayImpl»

                «finderImpl»

            «ENDIF»
            // feel free to extend the external controller here
        }
    '''

    def private displayImpl(Application it) '''
        «displayDocBlock(false)»
        «displaySignature»
        {
            return parent::displayAction($ot, $id, $source, $displayMode);
        }
    '''

    def private finderImpl(Application it) '''
        «finderDocBlock(false)»
        «finderSignature»
        {
            return parent::finderAction($objectType, $editor, $sort, $sortdir, $pos, $num);
        }
    '''
}
