package org.zikula.modulestudio.generator.cartridges.zclassic.controller.additions

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.formtype.Finder
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.cartridges.zclassic.view.additions.ExternalView
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ExternalController {
    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    FileHelper fh = new FileHelper()

    def generate(Application it, IFileSystemAccess fsa) {
        println('Generating external controller')
        generateClassPair(fsa, getAppSourceLibPath + 'Controller/ExternalController.php',
            fh.phpFileContent(it, externalBaseClass), fh.phpFileContent(it, externalImpl)
        )
        new Finder().generate(it, fsa)
        new ExternalView().generate(it, fsa)
    }

    def private externalBaseClass(Application it) '''
        namespace «appNamespace»\Controller\Base;

        use Sensio\Bundle\FrameworkExtraBundle\Configuration\Route;
        use Symfony\Component\HttpFoundation\Request;
        use Symfony\Component\Security\Core\Exception\AccessDeniedException;

        use PageUtil;
        use Zikula\Core\Controller\AbstractController;
        use Zikula\Core\Response\PlainResponse;
        «IF hasCategorisableEntities»
            use «appNamespace»\Helper\FeatureActivationHelper;
        «ENDIF»

        /**
         * Controller for external calls base class.
         */
        abstract class AbstractExternalController extends AbstractController
        {
            «externalBaseImpl»
        }
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
         «IF !isBase»
         *
         * @Route("/display/{ot}/{id}/{source}/{displayMode}",
         *        requirements = {"id" = "\d+", "source" = "contentType|scribite", "displayMode" = "link|embed"},
         *        defaults = {"source" = "contentType", "contentType" = "embed"},
         *        methods = {"GET"}
         * )
         «ENDIF»
         *
         * @param string $ot          The currently treated object type
         * @param int    $id          Identifier of the entity to be shown
         * @param string $source      Source of this call (contentType or scribite)
         * @param string $displayMode Display mode (link or embed)
         *
         * @return string Desired data output
         */
    '''

    def private displaySignature(Application it) '''
        public function displayAction($ot, $id, $source, $displayMode)
    '''

    def private displayBaseImpl(Application it) '''
        $controllerHelper = $this->get('«appService».controller_helper');

        $objectType = $ot;
        $utilArgs = ['controller' => 'external', 'action' => 'display'];
        if (!in_array($objectType, $controllerHelper->getObjectTypes('controller', $utilArgs))) {
            $objectType = $controllerHelper->getDefaultObjectType('controllerType', $utilArgs);
        }

        $component = $this->name . ':' . ucfirst($objectType) . ':';
        if (!$this->hasPermission($component, $id . '::', ACCESS_READ)) {
            return '';
        }

        $repository = $this->get('«appService».' . $objectType . '_factory')->getRepository();
        $repository->setRequest($this->get('request_stack')->getCurrentRequest());
        $selectionHelper = $this->get('«appService».selection_helper');
        $idFields = $selectionHelper->getIdFields($objectType);
        $idValues = ['id' => $id];«/** TODO consider composite keys properly */»

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

        $templateParameters = [
            'objectType' => $objectType,
            'source' => $source,
            $objectType => $entity,
            'displayMode' => $displayMode
        ];
        «IF needsFeatureActivationHelper»
            $templateParameters['featureActivationHelper'] = $this->get('«appService».feature_activation_helper');
        «ENDIF»

        return $this->render('@«appName»/External/' . ucfirst($objectType) . '/display.html.twig', $templateParameters);
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
         «IF !isBase»
         *
         * @Route("/finder/{objectType}/{editor}/{sort}/{sortdir}/{pos}/{num}",
         *        requirements = {"editor" = "ckeditor|tinymce", "sortdir" = "asc|desc", "pos" = "\d+", "num" = "\d+"},
         *        defaults = {"sort" = "", "sortdir" = "asc", "pos" = 1, "num" = 0},
         *        methods = {"GET"},
         *        options={"expose"=true}
         * )
         «ENDIF»
         *
         * @param Request $request    The current request
         * @param string  $objectType The object type
         * @param string  $editor     Name of used Scribite editor
         * @param string  $sort       Sorting field
         * @param string  $sortdir    Sorting direction
         * @param int     $pos        Current pager position
         * @param int     $num        Amount of entries to display
         *
         * @return output The external item finder page
         *
         * @throws AccessDeniedException Thrown if the user doesn't have required permissions
         */
    '''

    def private finderSignature(Application it) '''
        public function finderAction(Request $request, $objectType, $editor, $sort, $sortdir, $pos = 1, $num = 0)
    '''

    def private finderBaseImpl(Application it) '''
        $assetHelper = $this->get('zikula_core.common.theme.asset_helper');
        $cssAssetBag = $this->get('zikula_core.common.theme.assets_css');
        $cssAssetBag->add($assetHelper->resolve('@«appName»:css/style.css'));

        $controllerHelper = $this->get('«appService».controller_helper');
        $utilArgs = ['controller' => 'external', 'action' => 'finder'];
        if (!in_array($objectType, $controllerHelper->getObjectTypes('controller', $utilArgs))) {
            $objectType = $controllerHelper->getDefaultObjectType('controllerType', $utilArgs);
        }

        if (!$this->hasPermission('«appName»:' . ucfirst($objectType) . ':', '::', ACCESS_COMMENT)) {
            throw new AccessDeniedException();
        }

        if (empty($editor) || !in_array($editor, ['ckeditor', 'tinymce'])) {
            return $this->__('Error: Invalid editor context given for external controller action.');
        }

        $repository = $this->get('«appService».' . $objectType . '_factory')->getRepository();
        $repository->setRequest($request);
        if (empty($sort) || !in_array($sort, $repository->getAllowedSortingFields())) {
            $sort = $repository->getDefaultSortingField();
        }

        $sdir = strtolower($sortdir);
        if ($sdir != 'asc' && $sdir != 'desc') {
            $sdir = 'asc';
        }

        // the current offset which is used to calculate the pagination
        $currentPage = (int) $pos;

        // the number of items displayed on a page for pagination
        $resultsPerPage = (int) $num;
        if ($resultsPerPage == 0) {
            $resultsPerPage = $this->getVar('pageSize', 20);
        }

        $templateParameters = [
            'editorName' => $editor,
            'objectType' => $objectType,
            'sort' => $sort,
            'sortdir' => $sdir,
            'currentPage' => $currentPage
        ];
        $searchTerm = '';

        $formOptions = [
            'objectType' => $objectType,
            'editorName' => $editor
        ];
        $form = $this->createForm('«appNamespace»\Form\Type\Finder\\' . ucfirst($objectType) . 'FinderType', $templateParameters, $formOptions);

        if ($form->handleRequest($request)->isValid() && $form->get('update')->isClicked()) {
            $formData = $form->getData();
            $templateParameters = array_merge($templateParameters, $formData);
            $currentPage = $formData['currentPage'];
            $resultsPerPage = $formData['num'];
            $sort = $formData['sort'];
            $sdir = $formData['sortdir'];
            $searchTerm = $formData['q'];
        }

        $where = '';
        $sortParam = $sort . ' ' . $sdir;
        if ($searchTerm != '') {
            list($entities, $objectCount) = $repository->selectSearch($searchTerm, [], $sortParam, $currentPage, $resultsPerPage);
        } else {
            list($entities, $objectCount) = $repository->selectWherePaginated($where, $sortParam, $currentPage, $resultsPerPage);
        }

        «IF hasCategorisableEntities»
            if (in_array($objectType, ['«getCategorisableEntities.map[e|e.name.formatForCode].join('\', \'')»'])) {
                $featureActivationHelper = $this->get('«appService».feature_activation_helper');
                if ($featureActivationHelper->isEnabled(FeatureActivationHelper::CATEGORIES, $objectType)) {
                    $filteredEntities = [];
                    foreach ($entities as $entity) {
                        if ($this->get('«appService».category_helper')->hasPermission($entity)) {
                            $filteredEntities[] = $entity;
                        }
                    }
                    $entities = $filteredEntities;
                }
            }

        «ENDIF»
        foreach ($entities as $k => $entity) {
            $entity->initWorkflow();
        }

        $templateParameters['items'] = $entities;
        $templateParameters['finderForm'] = $form->createView();

        «IF needsFeatureActivationHelper»
            $templateParameters['featureActivationHelper'] = $this->get('«appService».feature_activation_helper');

        «ENDIF»
        $templateParameters['pager'] = [
            'numitems' => $objectCount,
            'itemsperpage' => $resultsPerPage
        ];

        $output = $this->renderView('@«appName»/External/' . ucfirst($objectType) . '/find.html.twig', $templateParameters);

        return new PlainResponse($output);
    '''

    def private externalImpl(Application it) '''
        namespace «appNamespace»\Controller;

        use «appNamespace»\Controller\Base\AbstractExternalController;

        use Sensio\Bundle\FrameworkExtraBundle\Configuration\Route;
        use Symfony\Component\HttpFoundation\Request;

        /**
         * Controller for external calls implementation class.
         *
         * @Route("/external")
         */
        class ExternalController extends AbstractExternalController
        {
            «displayImpl»

            «finderImpl»

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
            return parent::finderAction($request, $objectType, $editor, $sort, $sortdir, $pos, $num);
        }
    '''
}
