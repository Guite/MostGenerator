package org.zikula.modulestudio.generator.cartridges.zclassic.controller.additions

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.formtype.Finder
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
        use Symfony\Component\HttpFoundation\Response;
        use Symfony\Component\Security\Core\Exception\AccessDeniedException;
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
         * @Route("/display/{objectType}/{id}/{source}/{displayMode}",
         *        requirements = {«IF getAllEntities.filter[hasCompositeKeys].empty»"id" = "\d+", «ENDIF»"source" = "contentType|scribite", "displayMode" = "link|embed"},
         *        defaults = {"source" = "contentType", "contentType" = "embed"},
         *        methods = {"GET"}
         * )
         «ENDIF»
         *
         * @param string $objectType  The currently treated object type
         * @param int    $id          Identifier of the entity to be shown
         * @param string $source      Source of this call (contentType or scribite)
         * @param string $displayMode Display mode (link or embed)
         *
         * @return string Desired data output
         */
    '''

    def private displaySignature(Application it) '''
        public function displayAction($objectType, $id, $source, $displayMode)
    '''

    def private displayBaseImpl(Application it) '''
        $controllerHelper = $this->get('«appService».controller_helper');
        $contextArgs = ['controller' => 'external', 'action' => 'display'];
        if (!in_array($objectType, $controllerHelper->getObjectTypes('controllerAction', $contextArgs))) {
            $objectType = $controllerHelper->getDefaultObjectType('controllerAction', $contextArgs);
        }

        $component = '«appName»:' . ucfirst($objectType) . ':';
        if (!$this->hasPermission($component, $id . '::', ACCESS_READ)) {
            return '';
        }

        $entityFactory = $this->get('«appService».entity_factory');
        $repository = $entityFactory->getRepository($objectType);
        $repository->setRequest($this->get('request_stack')->getCurrentRequest());
        $idValues = $controllerHelper->retrieveIdentifier($request, [], $objectType);

        $hasIdentifier = $controllerHelper->isValidIdentifier($idValues);
        if (!$hasIdentifier) {
            return new Response($this->__('Error! Invalid identifier received.'));
        }

        // assign object data fetched from the database
        $entity = $repository->selectById($idValues);
        if (null === $entity) {
            return new Response($this->__('No such item.'));
        }

        «IF !targets('1.5')»
            $entity->initWorkflow();

        «ENDIF»
        $instance = $entity->createCompositeIdentifier() . '::';

        $templateParameters = [
            'objectType' => $objectType,
            'source' => $source,
            $objectType => $entity,
            'displayMode' => $displayMode
        ];

        $contextArgs = ['controller' => 'external', 'action' => 'display'];
        $templateParameters = $this->get('«appService».controller_helper')->addTemplateParameters($objectType, $templateParameters, 'controllerAction', $contextArgs);

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

        $activatedObjectTypes = $this->getVar('enabledFinderTypes', []);
        if (!in_array($objectType, $activatedObjectTypes)) {
            throw new AccessDeniedException();
        }

        if (!$this->hasPermission('«appName»:' . ucfirst($objectType) . ':', '::', ACCESS_COMMENT)) {
            throw new AccessDeniedException();
        }

        if (empty($editor) || !in_array($editor, ['ckeditor', 'tinymce'])) {
            return new Response($this->__('Error: Invalid editor context given for external controller action.'));
        }

        $repository = $this->get('«appService».entity_factory')->getRepository($objectType);
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
            'currentPage' => $currentPage«IF hasImageFields»,«ENDIF»
            «IF hasImageFields»
                'onlyImages' => false,
                'imageField' => ''
            «ENDIF»
        ];
        $searchTerm = '';

        $formOptions = [
            'objectType' => $objectType,
            'editorName' => $editor
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
        $sortParam = $sort . ' ' . $sdir;
        «IF hasImageFields»

            if (true === $templateParameters['onlyImages'] && $templateParameters['imageField'] != '') {
                $searchTerm = '';
                $imageField = $templateParameters['imageField'];

                $whereParts = [];
                foreach (['gif', 'jpg', 'jpeg', 'jpe', 'png', 'bmp'] as $imageExtension) {
                    $whereParts[] = 'tbl.' . $imageField . ':like:%.' . $imageExtension;
                }

                $where = '(' . implode('*', $whereParts) . ')';
            }
        «ENDIF»

        if ($searchTerm != '') {
            list($entities, $objectCount) = $repository->selectSearch($searchTerm, [], $sortParam, $currentPage, $resultsPerPage);
        } else {
            list($entities, $objectCount) = $repository->selectWherePaginated($where, $sortParam, $currentPage, $resultsPerPage);
        }

        «IF hasCategorisableEntities»
            if (in_array($objectType, ['«getCategorisableEntities.map[e|e.name.formatForCode].join('\', \'')»'])) {
                $featureActivationHelper = $this->get('«appService».feature_activation_helper');
                if ($featureActivationHelper->isEnabled(FeatureActivationHelper::CATEGORIES, $objectType)) {
                    $entities = $this->get('«appService».category_helper')->filterEntitiesByPermission($entities);
                }
            }

        «ENDIF»
        «IF !targets('1.5')»
            foreach ($entities as $k => $entity) {
                $entity->initWorkflow();
            }

        «ENDIF»
        $templateParameters['items'] = $entities;
        $templateParameters['finderForm'] = $form->createView();

        $contextArgs = ['controller' => 'external', 'action' => 'display'];
        $templateParameters = $this->get('«appService».controller_helper')->addTemplateParameters($objectType, $templateParameters, 'controllerAction', $contextArgs);

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
            return parent::displayAction($objectType, $id, $source, $displayMode);
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
