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
        use Symfony\Component\Routing\RouterInterface;
        use Zikula\ThemeModule\Engine\Asset;
        use Zikula\ThemeModule\Engine\AssetBag;
    '''

    def private commonAppImports(Application it) '''
        use «appNamespace»\Entity\Factory\EntityFactory;
        use «appNamespace»\Helper\CollectionFilterHelper;
        use «appNamespace»\Helper\ControllerHelper;
        use «appNamespace»\Helper\ListEntriesHelper;
        use «appNamespace»\Helper\PermissionHelper;
        use «appNamespace»\Helper\ViewHelper;
    '''

    def private externalBaseClass(Application it) '''
        namespace «appNamespace»\Controller\Base;

        use Symfony\Component\HttpFoundation\RedirectResponse;
        use Symfony\Component\HttpFoundation\Request;
        use Symfony\Component\HttpFoundation\Response;
        use Symfony\Component\Security\Core\Exception\AccessDeniedException;
        use Zikula\Bundle\CoreBundle\Controller\AbstractController;
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
        «IF isBase»
            /**
             * Displays one item of a certain object type using a separate template for external usages.
             */
         «ELSE»
             #[Route('/display/{objectType}/{id}/{displayMode}',
                 requirements: ['id' => '\d+', 'displayMode' => 'link|embed'],
                 defaults: ['displayMode' => 'embed'],
                 methods: ['GET']
             )]
         «ENDIF»
    '''

    def private displaySignature(Application it) '''
        public function display«IF !targets('3.1')»Action«ENDIF»(
            Request $request,
            ControllerHelper $controllerHelper,
            PermissionHelper $permissionHelper,
            EntityFactory $entityFactory,
            ViewHelper $viewHelper,
            string $objectType,
            int $id,
            string $displayMode
        ): Response'''

    def private displayBaseImpl(Application it) '''
        «IF !isSystemModule»
            $contextArgs = ['controller' => 'external', 'action' => 'display'];
        «ENDIF»
        if (!in_array($objectType, $controllerHelper->getObjectTypes('controllerAction'«IF !isSystemModule», $contextArgs«ENDIF»), true)) {
            $objectType = $controllerHelper->getDefaultObjectType('controllerAction'«IF !isSystemModule», $contextArgs«ENDIF»);
        }

        $repository = $entityFactory->getRepository($objectType);

        // assign object data fetched from the database
        $entity = $repository->selectById($id);
        if (null === $entity) {
            return new Response($this->trans('No such item.'));
        }

        if (!$permissionHelper->mayRead($entity)) {
            return new Response('');
        }

        $template = $request->query->get('template');
        if (null === $template || '' === $template) {
            $template = 'display.html.twig';
        }

        $templateParameters = [
            'objectType' => $objectType,
            $objectType => $entity,
            'displayMode' => $displayMode,
        ];

        $contextArgs = ['controller' => 'external', 'action' => 'display'];
        $templateParameters = $controllerHelper->addTemplateParameters(
            $objectType,
            $templateParameters,
            'controllerAction',
            $contextArgs
        );

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
        «IF isBase»
            /**
             * Popup selector for specific items.
             * Finds items of a certain object type.
             *
             * @throws AccessDeniedException Thrown if the user doesn't have required permissions
             */
        «ELSE»
            #[Route('/finder/{objectType}/{editor}/{sort}/{sortdir}/{page}/{num}',
                requirements: ['editor' => 'ckeditor|quill|summernote|tinymce', 'sortdir' => 'asc|desc', 'page' => '\d+', 'num' => '\d+'],
                defaults: ['sort' => 'dummy«/* will be replaced by default field */»', 'sortdir' => 'asc', 'page' => 1, 'num' => 0],
                methods: ['GET'],
                options: ['expose' => true]
            )]
        «ENDIF»
    '''

    def private finderSignature(Application it) '''
        public function finder«IF !targets('3.1')»Action«ENDIF»(
            Request $request,
            RouterInterface $router,
            ControllerHelper $controllerHelper,
            PermissionHelper $permissionHelper,
            EntityFactory $entityFactory,
            CollectionFilterHelper $collectionFilterHelper,
            ListEntriesHelper $listEntriesHelper,
            ViewHelper $viewHelper,
            AssetBag $cssAssetBag,
            Asset $assetHelper,
            string $objectType,
            string $editor,
            string $sort,
            string $sortdir,
            int $page = 1,
            int $num = 0
        ): Response'''

    def private finderBaseImpl(Application it) '''
        $activatedObjectTypes = $listEntriesHelper->extractMultiList($this->getVar('enabledFinderTypes', ''));
        if (!in_array($objectType, $activatedObjectTypes, true)) {
            if (!count($activatedObjectTypes)) {
                throw new AccessDeniedException();
            }

            // redirect to first valid object type
            $redirectUrl = $router->generate(
                '«appName.formatForDB»_external_finder',
                ['objectType' => array_shift($activatedObjectTypes), 'editor' => $editor]
            );

            return new RedirectResponse($redirectUrl);
        }

        $formData = $request->query->get('«appName.formatForDB»_' . mb_strtolower($objectType) . 'finder', []);
        «IF hasTranslatable»
            if (isset($formData['language'])) {
                $this->get('stof_doctrine_extensions.listener.translatable')->setTranslatableLocale($formData['language']);
            }
        «ENDIF»

        if (!$permissionHelper->hasComponentPermission($objectType, ACCESS_COMMENT)) {
            throw new AccessDeniedException();
        }

        if (empty($editor) || !in_array($editor, ['ckeditor', 'quill', 'summernote', 'tinymce'], true)) {
            return new Response($this->trans('Error: Invalid editor context given for external controller action.'));
        }

        $cssAssetBag->add($assetHelper->resolve('@«appName»:css/style.css'));
        $cssAssetBag->add([$assetHelper->resolve('@«appName»:css/custom.css') => 120]);

        $repository = $entityFactory->getRepository($objectType);
        if (empty($sort) || !in_array($sort, $repository->getAllowedSortingFields(), true)) {
            $sort = $repository->getDefaultSortingField();
        }

        $sdir = mb_strtolower($sortdir);
        if ('asc' !== $sdir && 'desc' !== $sdir) {
            $sdir = 'asc';
        }

        // the number of items displayed on a page for pagination
        $resultsPerPage = $num;
        if (0 === $resultsPerPage) {
            $resultsPerPage = $this->getVar($objectType . 'EntriesPerPage', 20);
        }

        $templateParameters = [
            'editorName' => $editor,
            'objectType' => $objectType,
            'sort' => $sort,
            'sortdir' => $sdir,
            'currentPage' => $page,
            'language' => isset($formData['language']) ? $formData['language'] : $request->getLocale(),
            «IF hasImageFields»
                'onlyImages' => false,
                'imageField' => '',
            «ENDIF»
        ];
        $searchTerm = '';

        $formOptions = [
            'object_type' => $objectType,
            'editor_name' => $editor,
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
            $page = $formData['currentPage'];
            $resultsPerPage = $formData['num'];
            $sort = $formData['sort'];
            $sdir = $formData['sortdir'];
            $searchTerm = $formData['q'];
            «IF hasImageFields»
                $templateParameters['onlyImages'] = isset($formData['onlyImages']) ? (bool) $formData['onlyImages'] : false;
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
            $collectionFilterHelper->addSearchFilter($objectType, $qb, $searchTerm);
        }

        $paginator = $repository->retrieveCollectionResult($qb, true, $page, $resultsPerPage);
        $paginator->setRoute('«appName.formatForDB»_external_finder');
        $paginator->setRouteParameters($formData);

        $templateParameters['paginator'] = $paginator;
        $entities = $paginator->getResults();

        // filter by permissions
        $entities = $permissionHelper->filterCollection(«IF !isSystemModule»$objectType, «ENDIF»$entities, ACCESS_READ);

        $templateParameters['items'] = $entities;
        $templateParameters['finderForm'] = $form->createView();

        $contextArgs = ['controller' => 'external', 'action' => 'display'];
        $templateParameters = $controllerHelper->addTemplateParameters(
            $objectType,
            $templateParameters,
            'controllerAction',
            $contextArgs
        );

        $templateParameters['activatedObjectTypes'] = $activatedObjectTypes;
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
         */
        #[Route('/external')]
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
            return parent::display«IF !targets('3.1')»Action«ENDIF»(
                $request,
                $controllerHelper,
                $permissionHelper,
                $entityFactory,
                $viewHelper,
                $objectType,
                $id,
                $displayMode
            );
        }
    '''

    def private finderImpl(Application it) '''
        «finderDocBlock(false)»
        «finderSignature» {
            return parent::finder«IF !targets('3.1')»Action«ENDIF»(
                $request,
                $router,
                $controllerHelper,
                $permissionHelper,
                $entityFactory,
                $collectionFilterHelper,
                $listEntriesHelper,
                $viewHelper,
                $cssAssetBag,
                $assetHelper,
                $objectType,
                $editor,
                $sort,
                $sortdir,
                $page,
                $num
            );
        }
    '''
}
