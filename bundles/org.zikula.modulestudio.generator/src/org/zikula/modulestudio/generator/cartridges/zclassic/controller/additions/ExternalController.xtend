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

    def private commonSystemImports(Application it) '''
        «IF targets('3.0')»
            use Symfony\Component\Routing\RouterInterface;
            use Zikula\ThemeModule\Engine\Asset;
        «ENDIF»
    '''

    def private commonAppImports(Application it) '''
        «IF targets('3.0')»
            use «appNamespace»\Entity\Factory\EntityFactory;
            use «appNamespace»\Helper\CollectionFilterHelper;
            use «appNamespace»\Helper\ControllerHelper;
            use «appNamespace»\Helper\ListEntriesHelper;
            use «appNamespace»\Helper\PermissionHelper;
            use «appNamespace»\Helper\ViewHelper;
        «ENDIF»
    '''

    def private externalBaseClass(Application it) '''
        namespace «appNamespace»\Controller\Base;

        use Symfony\Component\HttpFoundation\RedirectResponse;
        use Symfony\Component\HttpFoundation\Request;
        use Symfony\Component\HttpFoundation\Response;
        use Symfony\Component\Security\Core\Exception\AccessDeniedException;
        «IF targets('3.0')»
            use Zikula\Bundle\CoreBundle\Controller\AbstractController;
        «ELSE»
            use Zikula\Core\Controller\AbstractController;
        «ENDIF»
        «commonSystemImports»
        «commonAppImports»

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
        «displaySignature» {
            «displayBaseImpl»
        }
    '''

    def private displayDocBlock(Application it, Boolean isBase) '''
        /**
         «IF isBase»
         * Displays one item of a certain object type using a separate template for external usages.
         *
         «IF !targets('3.0')»
         * @param Request $request
         * @param string $objectType The currently treated object type
         * @param int $id Identifier of the entity to be shown
         * @param string $source Source of this call (block, contentType, scribite)
         * @param string $displayMode Display mode (link or embed)
         *
         * @return Response
         «ENDIF»
         «ELSE»
         * @Route("/display/{objectType}/{id}/{source}/{displayMode}",
         *        requirements = {"id" = "\d+", "source" = "block|contentType|scribite", "displayMode" = "link|embed"},
         *        defaults = {"source" = "contentType", "displayMode" = "embed"},
         *        methods = {"GET"}
         * )
         «ENDIF»
         */
    '''

    def private displaySignature(Application it) {
        if (targets('3.0')) '''
            public function displayAction(
                Request $request,
                ControllerHelper $controllerHelper,
                PermissionHelper $permissionHelper,
                EntityFactory $entityFactory,
                ViewHelper $viewHelper,
                string $objectType,
                int $id,
                string $source,
                string $displayMode
            ): Response'''
        else '''
            public function displayAction(
                Request $request,
                $objectType,
                $id,
                $source,
                $displayMode
            )'''
    }

    def private displayBaseImpl(Application it) '''
        «IF !targets('3.0')»
            $controllerHelper = $this->get('«appService».controller_helper');
        «ENDIF»
        $contextArgs = ['controller' => 'external', 'action' => 'display'];
        if (!in_array($objectType, $controllerHelper->getObjectTypes('controllerAction', $contextArgs), true)) {
            $objectType = $controllerHelper->getDefaultObjectType('controllerAction', $contextArgs);
        }

        «IF !targets('3.0')»
            $entityFactory = $this->get('«appService».entity_factory');
        «ENDIF»
        $repository = $entityFactory->getRepository($objectType);

        // assign object data fetched from the database
        $entity = $repository->selectById($id);
        if (null === $entity) {
            return new Response($this->«IF targets('3.0')»trans«ELSE»__«ENDIF»('No such item.'));
        }

        if (!«IF targets('3.0')»$permissionHelper«ELSE»$this->get('«appService».permission_helper')«ENDIF»->mayRead($entity)) {
            return new Response('');
        }

        $template = $request->query->get('template');
        if (null === $template || '' === $template) {
            $template = 'display.html.twig';
        }

        $templateParameters = [
            'objectType' => $objectType,
            'source' => $source,
            $objectType => $entity,
            'displayMode' => $displayMode
        ];

        $contextArgs = ['controller' => 'external', 'action' => 'display'];
        $templateParameters = «IF targets('3.0')»$controllerHelper«ELSE»$this->get('«appService».controller_helper')«ENDIF»->addTemplateParameters(
            $objectType,
            $templateParameters,
            'controllerAction',
            $contextArgs
        );

        «IF !targets('3.0')»
            $viewHelper = $this->get('«appService».view_helper');
        «ENDIF»
        $request->query->set('raw', true);
        
        return $viewHelper->processTemplate(
            'external',
            ucfirst($objectType) . '/' . str_replace('.html.twig', '', $template),
            $templateParameters
        );
    '''

    def private finderBase(Application it) '''
        «finderDocBlock(true)»
        «finderSignature» {
            «finderBaseImpl»
        }
    '''

    def private finderDocBlock(Application it, Boolean isBase) '''
        /**
         «IF isBase»
         * Popup selector for Scribite plugins.
         * Finds items of a certain object type.
         *
         «IF !targets('3.0')»
         * @param Request $request
         * @param string $objectType The object type
         * @param string $editor Name of used Scribite editor
         * @param string $sort Sorting field
         * @param string $sortdir Sorting direction
         * @param int $pos Current pager position
         * @param int $num Amount of entries to display
         *
         * @return Response
         *
         «ENDIF»
         * @throws AccessDeniedException Thrown if the user doesn't have required permissions
         «ELSE»
         * @Route("/finder/{objectType}/{editor}/{sort}/{sortdir}/{pos}/{num}",
         *        requirements = {"editor" = "ckeditor|quill|summernote|tinymce", "sortdir" = "asc|desc", "pos" = "\d+", "num" = "\d+"},
         *        defaults = {"sort" = "dummy«/* will be replaced by default field */»", "sortdir" = "asc", "pos" = 1, "num" = 0},
         *        methods = {"GET"},
         *        options={"expose"=true}
         * )
         «ENDIF»
         */
    '''

    def private finderSignature(Application it) {
        if (targets('3.0')) '''
            public function finderAction(
                Request $request,
                RouterInterface $router,
                ControllerHelper $controllerHelper,
                PermissionHelper $permissionHelper,
                EntityFactory $entityFactory,
                CollectionFilterHelper $collectionFilterHelper,
                ListEntriesHelper $listEntriesHelper,
                ViewHelper $viewHelper,
                Asset $assetHelper,
                string $objectType,
                string $editor,
                string $sort,
                string $sortdir,
                int $pos = 1,
                int $num = 0
            ): Response'''
        else '''
            public function finderAction(
                Request $request,
                $objectType,
                $editor,
                $sort,
                $sortdir,
                $pos = 1,
                $num = 0
            )'''
    }

    def private finderBaseImpl(Application it) '''
        «IF !targets('3.0')»
            $listEntriesHelper = $this->get('«appService».listentries_helper');
        «ENDIF»
        $activatedObjectTypes = $listEntriesHelper->extractMultiList($this->getVar('enabledFinderTypes', ''));
        if (!in_array($objectType, $activatedObjectTypes, true)) {
            if (!count($activatedObjectTypes)) {
                throw new AccessDeniedException();
            }

            // redirect to first valid object type
            $redirectUrl = «IF targets('3.0')»$router«ELSE»$this->get('router')«ENDIF»->generate(
                '«appName.formatForDB»_external_finder',
                ['objectType' => array_shift($activatedObjectTypes), 'editor' => $editor]
            );

            return new RedirectResponse($redirectUrl);
        }

        $formData = $request->query->get('«appName.formatForDB»_' . strtolower($objectType) . 'finder', []);
        «IF hasTranslatable»
            if (isset($formData['language'])) {
                $this->get('stof_doctrine_extensions.listener.translatable')->setTranslatableLocale($formData['language']);
            }
        «ENDIF»

        if (!«IF targets('3.0')»$permissionHelper«ELSE»$this->get('«appService».permission_helper')«ENDIF»->hasComponentPermission($objectType, ACCESS_COMMENT)) {
            throw new AccessDeniedException();
        }

        if (empty($editor) || !in_array($editor, ['ckeditor', 'quill', 'summernote', 'tinymce'], true)) {
            return new Response($this->«IF targets('3.0')»trans«ELSE»__«ENDIF»('Error: Invalid editor context given for external controller action.'));
        }

        «IF !targets('3.0')»
            $assetHelper = $this->get('zikula_core.common.theme.asset_helper');
        «ENDIF»
        $cssAssetBag = $this->get('zikula_core.common.theme.assets_css');
        $cssAssetBag->add($assetHelper->resolve('@«appName»:css/style.css'));
        $cssAssetBag->add([$assetHelper->resolve('@«appName»:css/custom.css') => 120]);

        $repository = «IF targets('3.0')»$entityFactory«ELSE»$this->get('«appService».entity_factory')«ENDIF»->getRepository($objectType);
        if (empty($sort) || !in_array($sort, $repository->getAllowedSortingFields(), true)) {
            $sort = $repository->getDefaultSortingField();
        }

        $sdir = strtolower($sortdir);
        if ('asc' !== $sdir && 'desc' !== $sdir) {
            $sdir = 'asc';
        }

        // the current offset which is used to calculate the pagination
        $currentPage = «IF !targets('3.0')»(int)«ENDIF»$pos;

        // the number of items displayed on a page for pagination
        $resultsPerPage = «IF !targets('3.0')»(int)«ENDIF»$num;
        if (0 === $resultsPerPage) {
            $resultsPerPage = $this->getVar($objectType . 'EntriesPerPage', 20);
        }

        $templateParameters = [
            'editorName' => $editor,
            'objectType' => $objectType,
            'sort' => $sort,
            'sortdir' => $sdir,
            'currentPage' => $currentPage,
            'language' => isset($formData['language']) ? $formData['language'] : $request->getLocale()«IF hasImageFields»,«ENDIF»
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
        $form = $this->createForm(
            '«appNamespace»\Form\Type\Finder\\' . ucfirst($objectType) . 'FinderType',
            $templateParameters,
            $formOptions
        );

        $form->handleRequest($request);
        if ($form->isSubmitted() && $form->isValid()) {
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

            if (true === $templateParameters['onlyImages'] && '' !== $templateParameters['imageField']) {
                $imageField = $templateParameters['imageField'];
                $orX = $qb->expr()->orX();
                foreach (['gif', 'jpg', 'jpeg', 'jpe', 'png', 'bmp'] as $imageExtension) {
                    $orX->add($qb->expr()->like('tbl.' . $imageField . 'FileName', $qb->expr()->literal('%.' . $imageExtension)));
                }

                $qb->andWhere($orX);
            }
        «ENDIF»

        if ('' !== $searchTerm) {
            $qb = $this->«IF targets('3.0')»$collectionFilterHelper«ELSE»get('«appService».collection_filter_helper')«ENDIF»->addSearchFilter($objectType, $qb, $searchTerm);
        }
        $query = $repository->getQueryFromBuilder($qb);

        list($entities, $objectCount) = $repository->retrieveCollectionResult($query, true);

        // filter by permissions
        $entities = «IF targets('3.0')»$permissionHelper«ELSE»$this->get('«appService».permission_helper')«ENDIF»->filterCollection($objectType, $entities, ACCESS_READ);

        $templateParameters['items'] = $entities;
        $templateParameters['finderForm'] = $form->createView();

        $contextArgs = ['controller' => 'external', 'action' => 'display'];
        $templateParameters = «IF targets('3.0')»$controllerHelper«ELSE»$this->get('«appService».controller_helper')«ENDIF»->addTemplateParameters(
            $objectType,
            $templateParameters,
            'controllerAction',
            $contextArgs
        );

        $templateParameters['activatedObjectTypes'] = $activatedObjectTypes;

        $templateParameters['pager'] = [
            'numitems' => $objectCount,
            'itemsperpage' => $resultsPerPage
        ];

        «IF !targets('3.0')»
            $viewHelper = $this->get('«appService».view_helper');
        «ENDIF»
        $request->query->set('raw', true);
        
        return $viewHelper->processTemplate('external', ucfirst($objectType) . '/find', $templateParameters);
    '''

    def private externalImpl(Application it) '''
        namespace «appNamespace»\Controller;

        use Symfony\Component\HttpFoundation\Request;
        use Symfony\Component\HttpFoundation\Response;
        use Symfony\Component\Routing\Annotation\Route;
        «commonSystemImports»
        use «appNamespace»\Controller\Base\AbstractExternalController;
        «commonAppImports»

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
        «displaySignature» {
            «IF targets('3.0')»
                return parent::displayAction(
                    $request,
                    $controllerHelper,
                    $permissionHelper,
                    $entityFactory,
                    $viewHelper,
                    $objectType,
                    $id,
                    $source,
                    $displayMode
                );
            «ELSE»
                return parent::displayAction(
                    $request,
                    $objectType,
                    $id,
                    $source,
                    $displayMode
                );
            «ENDIF»
        }
    '''

    def private finderImpl(Application it) '''
        «finderDocBlock(false)»
        «finderSignature» {
            «IF targets('3.0')»
                return parent::finderAction(
                    $request,
                    $router,
                    $controllerHelper,
                    $permissionHelper,
                    $entityFactory,
                    $collectionFilterHelper,
                    $listEntriesHelper,
                    $viewHelper,
                    $assetHelper,
                    $objectType,
                    $editor,
                    $sort,
                    $sortdir,
                    $pos,
                    $num
                );
            «ELSE»
                return parent::finderAction(
                    $request,
                    $objectType,
                    $editor,
                    $sort,
                    $sortdir,
                    $pos,
                    $num
                );
            «ENDIF»
        }
    '''
}
