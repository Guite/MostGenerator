package org.zikula.modulestudio.generator.cartridges.zclassic.controller.additions

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.formtype.FinderType
import org.zikula.modulestudio.generator.cartridges.zclassic.view.additions.ExternalView
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ExternalController {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelExtensions = new ModelExtensions
    extension Utils = new Utils

    def generate(Application it, IMostFileSystemAccess fsa) {
        if (!generateExternalControllerAndFinder || !hasDisplayActions) {
            return
        }
        'Generating external controller'.printIfNotTesting(fsa)
        fsa.generateClassPair('Controller/ExternalController.php', externalBaseClass, externalImpl)
        new FinderType().generate(it, fsa)
        new ExternalView().generate(it, fsa)
    }

    def private externalBaseClass(Application it) '''
        namespace «appNamespace»\Controller\Base;

        use Symfony\Component\HttpFoundation\RedirectResponse;
        use Symfony\Component\HttpFoundation\Request;
        use Symfony\Component\HttpFoundation\Response;
        use Symfony\Component\Security\Core\Exception\AccessDeniedException;
        use Zikula\Core\Controller\AbstractController;
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
         «IF isBase»
         * Displays one item of a certain object type using a separate template for external usages.
         *
         * @param Request $request     The current request
         * @param string  $objectType  The currently treated object type
         * @param int     $id          Identifier of the entity to be shown
         * @param string  $source      Source of this call (block, contentType, scribite)
         * @param string  $displayMode Display mode (link or embed)
         *
         * @return string Desired data output
         «ELSE»
         * @inheritDoc
         * @Route("/display/{objectType}/{id}/{source}/{displayMode}",
         *        requirements = {"id" = "\d+", "source" = "block|contentType|scribite", "displayMode" = "link|embed"},
         *        defaults = {"source" = "contentType", "displayMode" = "embed"},
         *        methods = {"GET"}
         * )
         «ENDIF»
         */
    '''

    def private displaySignature(Application it) '''
        public function displayAction(Request $request, $objectType, $id, $source, $displayMode)
    '''

    def private displayBaseImpl(Application it) '''
        $controllerHelper = $this->get('«appService».controller_helper');
        $contextArgs = ['controller' => 'external', 'action' => 'display'];
        if (!in_array($objectType, $controllerHelper->getObjectTypes('controllerAction', $contextArgs))) {
            $objectType = $controllerHelper->getDefaultObjectType('controllerAction', $contextArgs);
        }

        $entityFactory = $this->get('«appService».entity_factory');
        $repository = $entityFactory->getRepository($objectType);

        // assign object data fetched from the database
        $entity = $repository->selectById($id);
        if (null === $entity) {
            return new Response($this->__('No such item.'));
        }

        if (!$this->get('«appService».permission_helper')->mayRead($entity)) {
            return new Response('');
        }

        $template = $request->query->has('template') ? $request->query->get('template', null) : null;
        if (null === $template || $template == '') {
            $template = 'display.html.twig';
        }

        $templateParameters = [
            'objectType' => $objectType,
            'source' => $source,
            $objectType => $entity,
            'displayMode' => $displayMode
        ];

        $contextArgs = ['controller' => 'external', 'action' => 'display'];
        $templateParameters = $this->get('«appService».controller_helper')->addTemplateParameters($objectType, $templateParameters, 'controllerAction', $contextArgs);

        $viewHelper = $this->get('«appService».view_helper');
        $request->query->set('raw', true);
        
        return $viewHelper->processTemplate('external', ucfirst($objectType) . '/' . str_replace('.html.twig', '', $template), $templateParameters);
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
         «IF isBase»
         * Popup selector for Scribite plugins.
         * Finds items of a certain object type.
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
         «ELSE»
         * @inheritDoc
         * @Route("/finder/{objectType}/{editor}/{sort}/{sortdir}/{pos}/{num}",
         *        requirements = {"editor" = "ckeditor|quill|summernote|tinymce", "sortdir" = "asc|desc", "pos" = "\d+", "num" = "\d+"},
         *        defaults = {"sort" = "", "sortdir" = "asc", "pos" = 1, "num" = 0},
         *        methods = {"GET"},
         *        options={"expose"=true}
         * )
         «ENDIF»
         */
    '''

    def private finderSignature(Application it) '''
        public function finderAction(Request $request, $objectType, $editor, $sort, $sortdir, $pos = 1, $num = 0)
    '''

    def private finderBaseImpl(Application it) '''
        $assetHelper = $this->get('zikula_core.common.theme.asset_helper');
        $cssAssetBag = $this->get('zikula_core.common.theme.assets_css');
        $cssAssetBag->add($assetHelper->resolve('@«appName»:css/style.css'));
        $cssAssetBag->add([$assetHelper->resolve('@«appName»:css/custom.css') => 120]);

        $listEntriesHelper = $this->get('«appService».listentries_helper');
        $activatedObjectTypes = $listEntriesHelper->extractMultiList($this->getVar('enabledFinderTypes', ''));
        if (!in_array($objectType, $activatedObjectTypes)) {
            if (!count($activatedObjectTypes)) {
                throw new AccessDeniedException();
            }

            // redirect to first valid object type
            $redirectUrl = $this->get('router')->generate('«appName.formatForDB»_external_finder', ['objectType' => array_shift($activatedObjectTypes), 'editor' => $editor]);

            return new RedirectResponse($redirectUrl);
        }

        if (!$this->get('«appService».permission_helper')->hasComponentPermission($objectType, ACCESS_COMMENT)) {
            throw new AccessDeniedException();
        }

        if (empty($editor) || !in_array($editor, ['ckeditor', 'quill', 'summernote', 'tinymce'])) {
            return new Response($this->__('Error: Invalid editor context given for external controller action.'));
        }

        $repository = $this->get('«appService».entity_factory')->getRepository($objectType);
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
            $resultsPerPage = $this->getVar($objectType . 'EntriesPerPage', 20);
        }

        $templateParameters = [
            'editorName' => $editor,
            'objectType' => $objectType,
            'sort' => $sort,
            'sortdir' => $sdir,
            'currentPage' => $currentPage«IF hasImageFields»,«ENDIF»
            «IF hasImageFields»
                'onlyImages' => false,
                'imageField' => ''
            «ENDIF»
        ];
        $searchTerm = '';

        $formOptions = [
            'object_type' => $objectType,
            'editor_name' => $editor
        ];
        $form = $this->createForm('«appNamespace»\Form\Type\Finder\\' . ucfirst($objectType) . 'FinderType', $templateParameters, $formOptions);

        if ($form->handleRequest($request)->isValid()) {
            $formData = $form->getData();
            $templateParameters = array_merge($templateParameters, $formData);
            $currentPage = $formData['currentPage'];
            $resultsPerPage = $formData['num'];
            $sort = $formData['sort'];
            $sdir = $formData['sortdir'];
            $searchTerm = $formData['q'];
            «IF hasImageFields»
                $templateParameters['onlyImages'] = isset($formData['onlyImages']) ? (bool)$formData['onlyImages'] : false;
                $templateParameters['imageField'] = isset($formData['imageField']) ? $formData['imageField'] : '';
            «ENDIF»
        }

        $where = '';
        $orderBy = $sort . ' ' . $sdir;

        $qb = $repository->getListQueryBuilder($where, $orderBy);
        «IF hasImageFields»

            if (true === $templateParameters['onlyImages'] && '' != $templateParameters['imageField']) {
                $imageField = $templateParameters['imageField'];
                $orX = $qb->expr()->orX();
                foreach (['gif', 'jpg', 'jpeg', 'jpe', 'png', 'bmp'] as $imageExtension) {
                    $orX->add($qb->expr()->like('tbl.' . $imageField . 'FileName', $qb->expr()->literal('%.' . $imageExtension)));
                }

                $qb->andWhere($orX);
            }
        «ENDIF»

        if ('' != $searchTerm) {
            $qb = $this->get('«appService».collection_filter_helper')->addSearchFilter($objectType, $qb, $searchTerm);
        }
        $query = $repository->getQueryFromBuilder($qb);

        list($entities, $objectCount) = $repository->retrieveCollectionResult($query, true);

        «IF hasCategorisableEntities»
            if (in_array($objectType, ['«getCategorisableEntities.map[name.formatForCode].join('\', \'')»'])) {
                $featureActivationHelper = $this->get('«appService».feature_activation_helper');
                if ($featureActivationHelper->isEnabled(FeatureActivationHelper::CATEGORIES, $objectType)) {
                    $entities = $this->get('«appService».category_helper')->filterEntitiesByPermission($entities);
                }
            }

        «ENDIF»
        $templateParameters['items'] = $entities;
        $templateParameters['finderForm'] = $form->createView();

        $contextArgs = ['controller' => 'external', 'action' => 'display'];
        $templateParameters = $this->get('«appService».controller_helper')->addTemplateParameters($objectType, $templateParameters, 'controllerAction', $contextArgs);

        $templateParameters['activatedObjectTypes'] = $activatedObjectTypes;

        $templateParameters['pager'] = [
            'numitems' => $objectCount,
            'itemsperpage' => $resultsPerPage
        ];

        $viewHelper = $this->get('«appService».view_helper');
        $request->query->set('raw', true);
        
        return $viewHelper->processTemplate('external', ucfirst($objectType) . '/find', $templateParameters);
    '''

    def private externalImpl(Application it) '''
        namespace «appNamespace»\Controller;

        use «appNamespace»\Controller\Base\AbstractExternalController;
        use Symfony\Component\HttpFoundation\Request;
        use Symfony\Component\Routing\Annotation\Route;

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
            return parent::displayAction($request, $objectType, $id, $source, $displayMode);
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
