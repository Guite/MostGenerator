package org.zikula.modulestudio.generator.cartridges.zclassic.controller.additions

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.EntityTreeType
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.ControllerHelperFunctions
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class AjaxController {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelExtensions = new ModelExtensions
    extension ModelJoinExtensions = new ModelJoinExtensions
    extension Utils = new Utils

    def generate(Application it, IMostFileSystemAccess fsa) {
        'Generating ajax controller class'.printIfNotTesting(fsa)
        fsa.generateClassPair('Controller/AjaxController.php', ajaxControllerBaseClass, ajaxControllerImpl)
    }

    def private commonSystemImports(Application it, Boolean isBase) '''
        «IF needsAutoCompletion»
            use Liip\ImagineBundle\Imagine\Cache\CacheManager;
        «ENDIF»
        «IF hasBooleansWithAjaxToggle || hasTrees»
            use Psr\Log\LoggerInterface;
            «IF hasTrees»
                use Symfony\Component\Routing\RouterInterface;
            «ENDIF»
        «ENDIF»
        «IF isBase»
            use Symfony\Contracts\Translation\TranslatorInterface;
            use Zikula\Bundle\CoreBundle\Translation\TranslatorTrait;
            use Zikula\PermissionsBundle\Api\ApiInterface\PermissionApiInterface;
        «ENDIF»
        «IF hasBooleansWithAjaxToggle || hasTrees»
            use Zikula\UsersBundle\Api\ApiInterface\CurrentUserApiInterface;
            «IF hasTrees»
                use Zikula\UsersBundle\Repository\UserRepositoryInterface;
            «ENDIF»
        «ENDIF»
    '''

    def private commonAppImports(Application it) '''
        «IF generateExternalControllerAndFinder || needsAutoCompletion || needsDuplicateCheck || hasBooleansWithAjaxToggle || hasTrees || hasSortable»
            use «appNamespace»\Entity\Factory\EntityFactory;
        «ENDIF»
        «IF generateExternalControllerAndFinder || needsAutoCompletion || needsDuplicateCheck»
            use «appNamespace»\Helper\ControllerHelper;
        «ENDIF»
        «IF generateExternalControllerAndFinder || needsAutoCompletion || hasTrees»
            use «appNamespace»\Helper\EntityDisplayHelper;
        «ENDIF»
        «IF needsAutoCompletion && hasImageFields»
            use «appNamespace»\Helper\ImageHelper;
        «ENDIF»
        «IF generateExternalControllerAndFinder»
            use «appNamespace»\Helper\PermissionHelper;
        «ENDIF»
        «IF hasTrees»
            use «appNamespace»\Helper\WorkflowHelper;
        «ENDIF»
    '''

    def private ajaxControllerBaseClass(Application it) '''
        namespace «appNamespace»\Controller\Base;

        «IF hasTrees»
            use Exception;
        «ENDIF»
        use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
        use Symfony\Component\HttpFoundation\JsonResponse;
        use Symfony\Component\HttpFoundation\Request;
        use Symfony\Component\HttpFoundation\Response;
        «IF hasTrees && hasEditActions»
            use Symfony\Component\Routing\Generator\UrlGeneratorInterface;
        «ENDIF»
        «IF generateExternalControllerAndFinder || needsAutoCompletion || needsDuplicateCheck || hasBooleansWithAjaxToggle || hasTrees || hasSortable»
            use Symfony\Component\Security\Core\Exception\AccessDeniedException;
        «ENDIF»
        «commonSystemImports(true)»
        «IF generateExternalControllerAndFinder»
            use «appNamespace»\Entity\EntityInterface;
        «ENDIF»
        «commonAppImports»

        /**
         * Ajax controller base class.
         */
        abstract class AbstractAjaxController extends AbstractController
        {
            public function __construct(private readonly PermissionApiInterface $permissionApi, TranslatorInterface $translator)
            {
                $this->setTranslator($translator);
            }

            «additionalAjaxFunctionsBase»
        }
    '''

    def additionalAjaxFunctionsBase(Application it) '''
        «IF generateExternalControllerAndFinder»

            «getItemListFinderBase»
        «ENDIF»
        «IF needsAutoCompletion»

            «getItemListAutoCompletionBase»
        «ENDIF»
        «IF needsDuplicateCheck»

            «checkForDuplicateBase»
        «ENDIF»
        «IF hasBooleansWithAjaxToggle»

            «toggleFlagBase»
        «ENDIF»
        «IF hasTrees»

            «handleTreeOperationBase»
        «ENDIF»
        «IF hasSortable»

            «updateSortPositionsBase»
        «ENDIF»
    '''

    def private getItemListFinderBase(Application it) '''
        «getItemListFinderDocBlock(true)»
        «getItemListFinderSignature» {
            «getItemListFinderBaseImpl»
        }

        «getItemListFinderPrepareSlimItem»
    '''

    def private getItemListFinderDocBlock(Application it, Boolean isBase) '''
        «IF isBase»
            /**
             * Retrieve item list for finder selections.
             */
        «ELSE»
            #[Route('/getItemListFinder',
                name: '«appName.formatForDB»_ajax_getitemlistfinder',
                methods: ['GET'],
                options: ['expose' => true])
            ]
        «ENDIF»
    '''

    def private getItemListFinderSignature(Application it) '''
        public function getItemListFinder(
            Request $request,
            ControllerHelper $controllerHelper,
            PermissionHelper $permissionHelper,
            EntityFactory $entityFactory,
            EntityDisplayHelper $entityDisplayHelper
        ): JsonResponse'''

    def private getItemListFinderBaseImpl(Application it) '''
        if (!$request->isXmlHttpRequest()) {
            return $this->json($this->trans('Only ajax access is allowed!'), Response::HTTP_BAD_REQUEST);
        }

        if (!$this->permissionApi->hasPermission('«appName»::Ajax', '::', ACCESS_EDIT)) {
            throw new AccessDeniedException();
        }

        $objectType = $request->query->getAlnum('ot', '«getLeadingEntity.name.formatForCode»');
        $contextArgs = ['controller' => 'ajax', 'action' => 'getItemListFinder'];
        if (!in_array($objectType, $controllerHelper->getObjectTypes('controllerAction', $contextArgs), true)) {
            $objectType = $controllerHelper->getDefaultObjectType('controllerAction', $contextArgs);
        }

        $repository = $entityFactory->getRepository($objectType);

        $sort = $request->query->getAlnum('sort');
        if (empty($sort) || !in_array($sort, $repository->getAllowedSortingFields(), true)) {
            $sort = $repository->getDefaultSortingField();
        }

        $sdir = mb_strtolower($request->query->getAlpha('sortdir'));
        if ('asc' !== $sdir && 'desc' !== $sdir) {
            $sdir = 'asc';
        }

        $where = ''; // filters are processed inside the repository class
        $searchTerm = $request->query->get('q');
        $sortParam = $sort . ' ' . $sdir;

        $entities = [];
        if ('' !== $searchTerm) {
            $entities = $repository->selectSearch($searchTerm, [], $sortParam, 1, 50, false);
        } else {
            $entities = $repository->selectWhere($where, $sortParam);
        }

        $slimItems = [];
        foreach ($entities as $entity) {
            if (!$permissionHelper->mayRead($item)) {
                continue;
            }
            $slimItems[] = $this->prepareSlimItem(
                $controllerHelper,
                $repository,
                $entityDisplayHelper,
                $entity
            );
        }

        // return response
        return $this->json($slimItems);
    '''

    def private getItemListFinderPrepareSlimItem(Application it) '''
        /**
         * Builds and returns a slim data array from a given entity.
         */
        protected function prepareSlimItem(
            ControllerHelper $controllerHelper,
            EntityRepository $repository,
            EntityDisplayHelper $entityDisplayHelper,
            EntityInterface $entity
        ): array {
            $objectType = $entity->get_objectType();
            $previewParameters = [
                $objectType => $entity,
            ];
            $contextArgs = ['controller' => $objectType, 'action' => 'detail'];
            $previewParameters = $controllerHelper->addTemplateParameters(
                $objectType,
                $previewParameters,
                'controllerAction',
                $contextArgs
            );

            $previewInfo = $this->renderView(
                '@«vendorAndName»/External/' . ucfirst($objectType) . '/info.html.twig',
                $previewParameters
            );
            $previewInfo = base64_encode($previewInfo);

            $title = $entityDisplayHelper->getFormattedTitle($entity);
            $description = $entityDisplayHelper->getDescription($entity);

            return [
                'id' => $entity->getKey(),
                'title' => str_replace('&amp;', '&', $title),
                'description' => $description,
                'previewInfo' => $previewInfo,
            ];
        }
    '''

    def private getItemListAutoCompletionBase(Application it) '''
        «getItemListAutoCompletionDocBlock(true)»
        «getItemListAutoCompletionSignature» {
            «getItemListAutoCompletionBaseImpl»
        }
    '''

    def private getItemListAutoCompletionDocBlock(Application it, Boolean isBase) '''
        «IF isBase»
            /**
             * Searches for entities for auto completion usage.
             */
        «ELSE»
            #[Route('/getItemListAutoCompletion',
                name: '«appName.formatForDB»_ajax_getitemlistautocompletion',
                methods: ['GET'],
                options: ['expose' => true]
            )]
        «ENDIF»
    '''

    def private getItemListAutoCompletionSignature(Application it) '''
        public function getItemListAutoCompletion(
            Request $request,
            CacheManager $imagineCacheManager,
            ControllerHelper $controllerHelper,
            EntityFactory $entityFactory,
            EntityDisplayHelper $entityDisplayHelper«IF hasImageFields»,
            ImageHelper $imageHelper«ENDIF»
        ): JsonResponse'''

    def private getItemListAutoCompletionBaseImpl(Application it) '''
        if (!$request->isXmlHttpRequest()) {
            return $this->json($this->trans('Only ajax access is allowed!'), Response::HTTP_BAD_REQUEST);
        }

        if (!$this->permissionApi->hasPermission('«appName»::Ajax', '::', ACCESS_EDIT)) {
            throw new AccessDeniedException();
        }

        $objectType = $request->query->getAlnum('ot', '«getLeadingEntity.name.formatForCode»');
        $contextArgs = ['controller' => 'ajax', 'action' => 'getItemListAutoCompletion'];
        if (!in_array($objectType, $controllerHelper->getObjectTypes('controllerAction', $contextArgs), true)) {
            $objectType = $controllerHelper->getDefaultObjectType('controllerAction', $contextArgs);
        }

        $repository = $entityFactory->getRepository($objectType);
        $searchTerm = $request->query->get('q');
        $exclude = $request->query->get('exclude');
        $exclude = !empty($exclude) ? explode(',', str_replace(', ', ',', $exclude)) : [];

        // parameter for used sorting field
        «new ControllerHelperFunctions().defaultSorting(it)»
        $sortParam = $sort;
        if (false === mb_strpos(strtolower($sort), ' asc') && false === mb_strpos(strtolower($sort), ' desc')) {
            $sortParam .= ' asc';
        }

        $currentPage = 1;
        $resultsPerPage = 20;

        // get objects from database
        $entities = $repository->selectSearch($searchTerm, $exclude, $sortParam, $currentPage, $resultsPerPage, false);

        $resultItems = [];

        if ((is_array($entities) || is_object($entities)) && 0 < count($entities)) {
            «prepareForAutoCompletionProcessing»
            foreach ($entities as $item) {
                $itemTitle = $entityDisplayHelper->getFormattedTitle($item);
                «IF hasImageFields»
                    $itemTitleStripped = str_replace('"', '', $itemTitle);
                «ENDIF»
                $itemDescription = $entityDisplayHelper->getDescription($item);
                if ($itemDescription === $itemTitle) {
                    $itemDescription = '';
                }
                if (!empty($itemDescription)) {
                    $itemDescription = strip_tags($itemDescription);
                    $descriptionLength = 50;
                    if (mb_strlen($itemDescription) > $descriptionLength) {
                        if (false !== ($breakpoint = mb_strpos($itemDescription, ' ', $descriptionLength))) {
                            $descriptionLength = $breakpoint;
                            $itemDescription = rtrim(mb_substr($itemDescription, 0, $descriptionLength)) . '&hellip;';
                        }
                    }
                }

                $resultItem = [
                    'id' => $item->getKey(),
                    'title' => $itemTitle,
                    'description' => $itemDescription,
                    'image' => '',
                ];
                «IF hasImageFields»

                    // check for preview image
                    if (!empty($previewFieldName)) {
                        $getter = 'get' . ucfirst($previewFieldName);
                        if (!empty($item->$getter())) {
                            $imagePath = $item->$getter()->getPathname();
                            $imagePath = str_replace($item->get_uploadBasePathAbsolute(), $item->get_uploadBasePathRelative(), $imagePath);
                            $thumbImagePath = $imagineCacheManager->getBrowserPath($imagePath, 'zkroot', $thumbRuntimeOptions);
                            $resultItem['image'] = '<img src="' . $thumbImagePath . '" width="50" height="50" alt="' . $itemTitleStripped . '" class="mr-1" />';
                        }
                    }
                «ENDIF»

                $resultItems[] = $resultItem;
            }
        }

        return $this->json($resultItems);
    '''

    def private prepareForAutoCompletionProcessing(Application it) '''
        $descriptionFieldName = $entityDisplayHelper->getDescriptionFieldName($objectType);
        «IF hasImageFields»
            $previewFieldName = $entityDisplayHelper->getPreviewFieldName($objectType);
            $thumbRuntimeOptions = $imageHelper->getRuntimeOptions($objectType, $previewFieldName, 'controllerAction', $contextArgs);
        «ENDIF»
    '''

    def private checkForDuplicateBase(Application it) '''
        «checkForDuplicateDocBlock(true)»
        «checkForDuplicateSignature» {
            «checkForDuplicateBaseImpl»
        }
    '''

    def private checkForDuplicateDocBlock(Application it, Boolean isBase) '''
        «IF isBase»
            /**
             * Checks whether a field value is a duplicate or not.
             *
             * @throws AccessDeniedException Thrown if the user doesn't have required permissions
             */
        «ELSE»
            #[Route('/checkForDuplicate',
                name: '«appName.formatForDB»_ajax_checkforduplicate',
                methods: ['GET'],
                options: ['expose' => true]
            )]
        «ENDIF»
    '''

    def private checkForDuplicateSignature(Application it) '''
        public function checkForDuplicate(
            Request $request,
            ControllerHelper $controllerHelper,
            EntityFactory $entityFactory
        ): JsonResponse'''

    def private checkForDuplicateBaseImpl(Application it) '''
        if (!$request->isXmlHttpRequest()) {
            return $this->json($this->trans('Only ajax access is allowed!'), Response::HTTP_BAD_REQUEST);
        }

        if (!$this->permissionApi->hasPermission('«appName»::Ajax', '::', ACCESS_EDIT)) {
            throw new AccessDeniedException();
        }

        «prepareDuplicateCheckParameters»

        $result = false;
        switch ($objectType) {
            «FOR entity : getAllEntities»
                «val uniqueFields = entity.getUniqueDerivedFields.filter[!primaryKey]»
                «IF !uniqueFields.empty || (entity.hasSluggableFields && entity.slugUnique)»
                    case '«entity.name.formatForCode»':
                        $repository = $entityFactory->getRepository($objectType);
                        switch ($fieldName) {
                            «FOR uniqueField : uniqueFields»
                                case '«uniqueField.name.formatForCode»':
                                    $result = !$repository->detectUniqueState('«uniqueField.name.formatForCode»', $value, $exclude);
                                    break;
                            «ENDFOR»
                            «IF entity.hasSluggableFields && entity.slugUnique»
                                case 'slug':
                                    $entity = $repository->selectBySlug($value, false, false, $exclude);
                                    $result = null !== $entity && isset($entity['slug']);
                                    break;
                            «ENDIF»
                        }
                        break;
                «ENDIF»
            «ENDFOR»
        }

        // return response
        return $this->json(['isDuplicate' => $result]);
    '''

    def private prepareDuplicateCheckParameters(Application it) '''
        $objectType = $request->query->getAlnum('ot', '«getLeadingEntity.name.formatForCode»');
        $contextArgs = ['controller' => 'ajax', 'action' => 'checkForDuplicate'];
        if (!in_array($objectType, $controllerHelper->getObjectTypes('controllerAction', $contextArgs), true)) {
            $objectType = $controllerHelper->getDefaultObjectType('controllerAction', $contextArgs);
        }

        $fieldName = $request->query->getAlnum('fn');
        $value = $request->query->get('v');

        if (empty($fieldName) || empty($value)) {
            return $this->json($this->trans('Error: invalid input.'), JsonResponse::HTTP_BAD_REQUEST);
        }

        // check if the given field is existing and unique
        $uniqueFields = [];
        switch ($objectType) {
            «FOR entity : getAllEntities»
                «val uniqueFields = entity.getUniqueDerivedFields.filter[!primaryKey]»
                «IF !uniqueFields.empty || (entity.hasSluggableFields && entity.slugUnique)»
                    case '«entity.name.formatForCode»':
                        $uniqueFields = [«FOR uniqueField : uniqueFields SEPARATOR ', '»'«uniqueField.name.formatForCode»'«ENDFOR»«IF entity.hasSluggableFields && entity.slugUnique»«IF !uniqueFields.empty», «ENDIF»'slug'«ENDIF»];
                        break;
                «ENDIF»
            «ENDFOR»
        }
        if (!count($uniqueFields) || !in_array($fieldName, $uniqueFields, true)) {
            return $this->json($this->trans('Error: invalid input.'), JsonResponse::HTTP_BAD_REQUEST);
        }

        $exclude = $request->query->getInt('ex');
    '''

    def private toggleFlagBase(Application it) '''
        «toggleFlagDocBlock(true)»
        «toggleFlagSignature» {
            «toggleFlagBaseImpl»
        }
    '''

    def private toggleFlagDocBlock(Application it, Boolean isBase) '''
        «IF isBase»
            /**
             * Changes a given flag (boolean field) by switching between true and false.
             *
             * @throws AccessDeniedException Thrown if the user doesn't have required permissions
             */
        «ELSE»
            #[Route('/toggleFlag',
                name: '«appName.formatForDB»_ajax_toggleflag',
                methods: ['POST'],
                options: ['expose' => true]
            )]
        «ENDIF»
    '''

    def private toggleFlagSignature(Application it) '''
        public function toggleFlag(
            Request $request,
            LoggerInterface $logger,
            EntityFactory $entityFactory,
            CurrentUserApiInterface $currentUserApi
        ): JsonResponse'''

    def private toggleFlagBaseImpl(Application it) '''
        if (!$request->isXmlHttpRequest()) {
            return $this->json($this->trans('Only ajax access is allowed!'), Response::HTTP_BAD_REQUEST);
        }

        if (!$this->permissionApi->hasPermission('«appName»::Ajax', '::', ACCESS_EDIT)) {
            throw new AccessDeniedException();
        }

        $objectType = $request->request->getAlnum('ot', '«getLeadingEntity.name.formatForCode»');
        $field = $request->request->getAlnum('field');
        $id = $request->request->getInt('id');

        «val entities = getEntitiesWithAjaxToggle»
        if (
            0 === $id
            || («FOR entity : entities SEPARATOR ' && '»'«entity.name.formatForCode»' !== $objectType«ENDFOR»)
            «FOR entity : entities»
                || ('«entity.name.formatForCode»' === $objectType && !in_array($field, [«FOR field : entity.getBooleansWithAjaxToggleEntity('') SEPARATOR ', '»'«field.name.formatForCode»'«ENDFOR»], true))
            «ENDFOR»
        ) {
            return $this->json($this->trans('Error: invalid input.'), JsonResponse::HTTP_BAD_REQUEST);
        }

        // select data from data source
        $repository = $entityFactory->getRepository($objectType);
        $entity = $repository->selectById($id, false);
        if (null === $entity) {
            return $this->json($this->trans('No such item.'), JsonResponse::HTTP_NOT_FOUND);
        }

        // toggle the flag
        $entity[$field] = !$entity[$field];

        // save entity back to database
        $entityFactory->getEntityManager()->flush();

        $logArgs = [
            'app' => '«appName»',
            'user' => $currentUserApi->get('uname'),
            'field' => $field,
            'entity' => $objectType,
            'id' => $id,
        ];
        $logger->notice('{app}: User {user} toggled the {field} flag the {entity} with id {id}.', $logArgs);

        // return response
        return $this->json([
            'id' => $id,
            'state' => $entity[$field],
            'message' => $this->trans('The setting has been successfully changed.'),
        ]);
    '''

    def private handleTreeOperationBase(Application it) '''
        «handleTreeOperationDocBlock(true)»
        «handleTreeOperationSignature» {
            «handleTreeOperationBaseImpl»
        }
    '''

    def private handleTreeOperationDocBlock(Application it, Boolean isBase) '''
        «IF isBase»
            /**
             * Performs different operations on tree hierarchies.
             *
             * @throws AccessDeniedException Thrown if the user doesn't have required permissions
             */
        «ELSE»
            #[Route('/handleTreeOperation',
                name: '«appName.formatForDB»_ajax_handletreeoperation',
                methods: ['POST'],
                options: ['expose' => true]
            )]
        «ENDIF»
    '''

    def private handleTreeOperationSignature(Application it) '''
        public function handleTreeOperation(
            Request $request,
            RouterInterface $router,
            LoggerInterface $logger,
            EntityFactory $entityFactory,
            EntityDisplayHelper $entityDisplayHelper,
            CurrentUserApiInterface $currentUserApi,
            UserRepositoryInterface $userRepository,
            WorkflowHelper $workflowHelper
        ): JsonResponse'''

    def private handleTreeOperationBaseImpl(Application it) '''
        if (!$request->isXmlHttpRequest()) {
            return $this->json($this->trans('Only ajax access is allowed!'), Response::HTTP_BAD_REQUEST);
        }

        if (!$this->permissionApi->hasPermission('«appName»::Ajax', '::', ACCESS_EDIT)) {
            throw new AccessDeniedException();
        }

        «val treeEntities = getTreeEntities»
        // parameter specifying which type of objects we are treating
        $objectType = $request->request->getAlnum('ot', '«treeEntities.head.name.formatForCode»');
        // ensure that we use only object types with tree extension enabled
        if (!in_array($objectType, [«FOR treeEntity : treeEntities SEPARATOR ", "»'«treeEntity.name.formatForCode»'«ENDFOR»], true)) {
            $objectType = '«treeEntities.head.name.formatForCode»';
        }

        $returnValue = [
            'data' => [],
            'result' => 'success',
            'message' => '',
        ];

        «prepareTreeOperationParameters»

        $createMethod = 'create' . ucfirst($objectType);
        $repository = $entityFactory->getRepository($objectType);

        $rootId = 1;
        if (!in_array($op, ['addRootNode'], true)) {
            $rootId = $request->request->getInt('root');
            if (!$rootId) {
                $returnValue['result'] = 'failure';
                $returnValue['message'] = $this->trans('Error: invalid root node.');

                return $this->json($returnValue);
            }
        }

        $entityManager = $entityFactory->getEntityManager();
        $titleFieldName = $entityDisplayHelper->getTitleFieldName($objectType);
        $descriptionFieldName = $entityDisplayHelper->getDescriptionFieldName($objectType);

        «treeOperationSwitch»

        $returnValue['message'] = $this->trans('The operation was successful.');

        // Renew tree
        /* postponed, for now we do a page reload.
         * $returnValue['data'] = $repository->selectTree($rootId);
         */

        return $this->json($returnValue);
    '''

    def private prepareTreeOperationParameters(Application it) '''
        $op = $request->request->getAlpha('op');
        if (!in_array($op, ['addRootNode', 'addChildNode', 'deleteNode', 'moveNode', 'moveNodeTo'], true)) {
            $returnValue['result'] = 'failure';
            $returnValue['message'] = $this->trans('Error: invalid operation.');

            return $this->json($returnValue);
        }

        // Get id of treated node
        $id = 0;
        if (!in_array($op, ['addRootNode', 'addChildNode'], true)) {
            $id = $request->request->getInt('id');
            if (!$id) {
                $returnValue['result'] = 'failure';
                $returnValue['message'] = $this->trans('Error: invalid node.');

                return $this->json($returnValue);
            }
        }
    '''

    def private treeOperationSwitch(Application it) '''
        $logArgs = ['app' => '«appName»', 'user' => $currentUserApi->get('uname'), 'entity' => $objectType];
        «IF hasStandardFieldEntities»

            $currentUserId = $currentUserApi->isLoggedIn() ? $currentUserApi->get('uid') : 1;
            $currentUser = $userRepository->find($currentUserId);
        «ENDIF»

        switch ($op) {
            case 'addRootNode':
                «treeOperationAddRootNode»

                $logger->notice('{app}: User {user} added a new root node in the {entity} tree.', $logArgs);
                break;
            case 'addChildNode':
                «treeOperationAddChildNode»

                $logger->notice('{app}: User {user} added a new child node in the {entity} tree.', $logArgs);
                break;
            case 'deleteNode':
                «treeOperationDeleteNode»

                $logger->notice('{app}: User {user} deleted a node from the {entity} tree.', $logArgs);
                break;
            case 'moveNode':
                «treeOperationMoveNode»

                $logger->notice('{app}: User {user} moved a node in the {entity} tree.', $logArgs);
                break;
            case 'moveNodeTo':
                «treeOperationMoveNodeTo»

                $logger->notice('{app}: User {user} moved a node in the {entity} tree.', $logArgs);
                break;
        }
    '''

    def private treeOperationAddRootNode(Application it) '''
        $entity = $entityFactory->$createMethod();
        if (!empty($titleFieldName)) {
            $setter = 'set' . ucfirst($titleFieldName);
            $entity->$setter($this->trans('New root node'));
        }
        if (!empty($descriptionFieldName)) {
            $setter = 'set' . ucfirst($descriptionFieldName);
            $entity->$setter($this->trans('This is a new root node'));
        }
        «IF hasStandardFieldEntities»
            if (method_exists($entity, 'setCreatedBy')) {
                $entity->setCreatedBy($currentUser);
                $entity->setUpdatedBy($currentUser);
            }
        «ENDIF»«/*IF hasTranslatableFields»
            $entity->setLocale($request->getLocale());
        «ENDIF*/»

        // save new object to set the root id
        $action = 'submit';
        try {
            // execute the workflow action
            $success = $workflowHelper->executeAction($entity, $action);
            if (!$success) {
                $returnValue['result'] = 'failure';
            }
        } catch (Exception $exception) {
            $returnValue['result'] = 'failure';
            $returnValue['message'] = $this->trans(
                'Sorry, but an error occured during the %action% action. Please apply the changes again!',
                ['%action%' => $action]
            ) . '  ' . $exception->getMessage();

            return $this->json($returnValue);
        }
    '''

    def private treeOperationAddChildNode(Application it) '''
        $parentId = $request->request->getInt('pid');
        if (!$parentId) {
            $returnValue['result'] = 'failure';
            $returnValue['message'] = $this->trans('Error: invalid parent node.');

            return $this->json($returnValue);
        }

        $childEntity = $entityFactory->$createMethod();
        $setter = 'set' . ucfirst($titleFieldName);
        $childEntity->$setter($this->trans('New child node'));
        if (!empty($descriptionFieldName)) {
            $setter = 'set' . ucfirst($descriptionFieldName);
            $childEntity->$setter($this->trans('This is a new child node'));
        }
        «IF hasStandardFieldEntities»
            if (method_exists($childEntity, 'setCreatedBy')) {
                $childEntity->setCreatedBy($currentUser);
                $childEntity->setUpdatedBy($currentUser);
            }
        «ENDIF»
        $parentEntity = $repository->selectById($parentId, false);
        if (null === $parentEntity) {
            $returnValue['result'] = 'failure';
            $returnValue['message'] = $this->trans('No such item.');

            return $this->json($returnValue);
        }
        $childEntity->setParent($parentEntity);

        // save new object
        $action = 'submit';
        try {
            // execute the workflow action
            $success = $workflowHelper->executeAction($childEntity, $action);
            «IF hasEditActions && !getAllEntities.filter[tree != EntityTreeType.NONE && hasEditAction].empty»
                if (!$success) {
                    $returnValue['result'] = 'failure';
                } elseif (in_array($objectType, ['«getAllEntities.filter[tree != EntityTreeType.NONE && hasEditAction].map[name.formatForCode].join('\', \'')»'], true)) {
                    $routeName = '«appName.formatForDB»_' . mb_strtolower($objectType) . '_edit';
                    «IF !getAllEntities.filter[tree != EntityTreeType.NONE && hasEditAction && hasSluggableFields && slugUnique].empty»
                        $needsArg = in_array($objectType, ['«getAllEntities.filter[tree != EntityTreeType.NONE && hasEditAction && hasSluggableFields && slugUnique].map[name.formatForCode].join('\', \'')»'], true);
                        $urlArgs = $needsArg ? $childEntity->createUrlArgs(true) : $childEntity->createUrlArgs();
                    «ELSE»
                        $urlArgs = $childEntity->createUrlArgs();
                    «ENDIF»
                    $returnValue['returnUrl'] = $router->generate(
                        $routeName,
                        $urlArgs,
                        UrlGeneratorInterface::ABSOLUTE_URL
                    );
                }
            «ELSE»
                if (!$success) {
                    $returnValue['result'] = 'failure';
                }
            «ENDIF»
        } catch (Exception $exception) {
            $returnValue['result'] = 'failure';
            $returnValue['message'] = $this->trans(
                'Sorry, but an error occured during the %action% action. Please apply the changes again!',
                ['%action%' => $action]
            ) . '  ' . $exception->getMessage();

            return $this->json($returnValue);
        }
    '''

    def private treeOperationDeleteNode(Application it) '''
        // remove node from tree and reparent all children
        $entity = $repository->selectById($id, false);
        if (null === $entity) {
            $returnValue['result'] = 'failure';
            $returnValue['message'] = $this->trans('No such item.');

            return $this->json($returnValue);
        }

        // delete the object
        $action = 'delete';
        try {
            // execute the workflow action
            $success = $workflowHelper->executeAction($entity, $action);
            if (!$success) {
                $returnValue['result'] = 'failure';
            }
        } catch (Exception $exception) {
            $returnValue['result'] = 'failure';
            $returnValue['message'] = $this->trans(
                'Sorry, but an error occured during the %action% action. Please apply the changes again!',
                ['%action%' => $action]
            ) . '  ' . $exception->getMessage();

            return $this->json($returnValue);
        }

        $repository->removeFromTree($entity);
        $entityManager->clear(); // clear cached nodes
    '''

    def private treeOperationMoveNode(Application it) '''
        $moveDirection = $request->request->getAlpha('direction');
        if (!in_array($moveDirection, ['top', 'up', 'down', 'bottom'], true)) {
            $returnValue['result'] = 'failure';
            $returnValue['message'] = $this->trans('Error: invalid direction.');

            return $this->json($returnValue);
        }

        $entity = $repository->selectById($id, false);
        if (null === $entity) {
            $returnValue['result'] = 'failure';
            $returnValue['message'] = $this->trans('No such item.');

            return $this->json($returnValue);
        }

        if ('top' === $moveDirection) {
            $repository->moveUp($entity, true);
        } elseif ('up' === $moveDirection) {
            $repository->moveUp($entity, 1);
        } elseif ('down' === $moveDirection) {
            $repository->moveDown($entity, 1);
        } elseif ('bottom' === $moveDirection) {
            $repository->moveDown($entity, true);
        }
        $entityManager->flush();
    '''

    def private treeOperationMoveNodeTo(Application it) '''
        $moveDirection = $request->request->getAlpha('direction');
        if (!in_array($moveDirection, ['after', 'before', 'bottom'], true)) {
            $returnValue['result'] = 'failure';
            $returnValue['message'] = $this->trans('Error: invalid direction.');

            return $this->json($returnValue);
        }

        $destId = $request->request->getInt('destid');
        if (!$destId) {
            $returnValue['result'] = 'failure';
            $returnValue['message'] = $this->trans('Error: invalid destination node.');

            return $this->json($returnValue);
        }

        $entity = $repository->selectById($id, false);
        $destEntity = $repository->selectById($destId, false);
        if (null === $entity || null === $destEntity) {
            $returnValue['result'] = 'failure';
            $returnValue['message'] = $this->trans('No such item.');

            return $this->json($returnValue);
        }

        if ('after' === $moveDirection) {
            $repository->persistAsNextSiblingOf($entity, $destEntity);
        } elseif ('before' === $moveDirection) {
            $repository->persistAsPrevSiblingOf($entity, $destEntity);
        } elseif ('bottom' === $moveDirection) {
            $repository->persistAsLastChildOf($entity, $destEntity);
        }

        $entityManager->flush();
    '''

    def private updateSortPositionsBase(Application it) '''
        «updateSortPositionsDocBlock(true)»
        «updateSortPositionsSignature» {
            «updateSortPositionsBaseImpl»
        }
    '''

    def private updateSortPositionsDocBlock(Application it, Boolean isBase) '''
        «IF isBase»
            /**
             * Updates the sort positions for a given list of entities.
             *
             * @throws AccessDeniedException Thrown if the user doesn't have required permissions
             */
        «ELSE»
            #[Route('/updateSortPositions',
                name: '«appName.formatForDB»_ajax_updatesortpositions',
                methods: ['POST'],
                options: ['expose' => true]
            )]
        «ENDIF»
    '''

    def private updateSortPositionsSignature(Application it) '''
        public function updateSortPositions(
            Request $request,
            EntityFactory $entityFactory
        ): JsonResponse'''

    def private updateSortPositionsBaseImpl(Application it) '''
        if (!$request->isXmlHttpRequest()) {
            return $this->json($this->trans('Only ajax access is allowed!'), Response::HTTP_BAD_REQUEST);
        }

        if (!$this->permissionApi->hasPermission('«appName»::Ajax', '::', ACCESS_EDIT)) {
            throw new AccessDeniedException();
        }

        $objectType = $request->request->getAlnum('ot', '«getLeadingEntity.name.formatForCode»');
        $itemIds = $request->request->get('identifiers', []);
        $min = $request->request->getInt('min');
        $max = $request->request->getInt('max');

        if (!is_array($itemIds) || 2 > count($itemIds) || 1 > $max || $max <= $min) {
            return $this->json($this->trans('Error: invalid input.'), JsonResponse::HTTP_BAD_REQUEST);
        }

        $repository = $entityFactory->getRepository($objectType);
        $sortableFieldMap = [
            «FOR entity : getAllEntities.filter[hasSortableFields]»
                '«entity.name.formatForCode»' => '«entity.getSortableFields.head.name.formatForCode»',
            «ENDFOR»
        ];

        $sortFieldSetter = 'set' . ucfirst($sortableFieldMap[$objectType]);
        $sortCounter = $min;

        // update sort values
        foreach ($itemIds as $itemId) {
            if (empty($itemId) || !is_numeric($itemId)) {
                continue;
            }
            $entity = $repository->selectById($itemId);
            $entity->$sortFieldSetter($sortCounter);
            ++$sortCounter;
        }

        // save entities back to database
        $entityFactory->getEntityManager()->flush();

        // return response
        return $this->json([
            'message' => $this->trans('The setting has been successfully changed.'),
        ]);
    '''

    def additionalAjaxFunctions(Application it) '''
        «IF generateExternalControllerAndFinder»

            «getItemListFinderImpl»
        «ENDIF»
        «IF needsAutoCompletion»

            «getItemListAutoCompletionImpl»
        «ENDIF»
        «IF needsDuplicateCheck»

            «checkForDuplicateImpl»
        «ENDIF»
        «IF hasBooleansWithAjaxToggle»

            «toggleFlagImpl»
        «ENDIF»
        «IF hasTrees»

            «handleTreeOperationImpl»
        «ENDIF»
        «IF hasSortable»

            «updateSortPositionsImpl»
        «ENDIF»
    '''

    def private getItemListFinderImpl(Application it) '''
        «getItemListFinderDocBlock(false)»
        «getItemListFinderSignature» {
            return parent::getItemListFinder(
                $request,
                $controllerHelper,
                $permissionHelper,
                $entityFactory,
                $entityDisplayHelper
            );
        }
    '''

    def private getItemListAutoCompletionImpl(Application it) '''
        «getItemListAutoCompletionDocBlock(false)»
        «getItemListAutoCompletionSignature» {
            return parent::getItemListAutoCompletion(
                $request,
                $imagineCacheManager,
                $controllerHelper,
                $entityFactory,
                $entityDisplayHelper«IF hasImageFields»,
                $imageHelper«ENDIF»
            );
        }
    '''

    def private checkForDuplicateImpl(Application it) '''
        «checkForDuplicateDocBlock(false)»
        «checkForDuplicateSignature» {
            return parent::checkForDuplicate(
                $request,
                $controllerHelper,
                $entityFactory
            );
        }
    '''

    def private toggleFlagImpl(Application it) '''
        «toggleFlagDocBlock(false)»
        «toggleFlagSignature» {
            return parent::toggleFlag(
                $request,
                $logger,
                $entityFactory,
                $currentUserApi
            );
        }
    '''

    def private handleTreeOperationImpl(Application it) '''
        «handleTreeOperationDocBlock(false)»
        «handleTreeOperationSignature» {
            return parent::handleTreeOperation(
                $request,
                $router,
                $logger,
                $entityFactory,
                $entityDisplayHelper,
                $currentUserApi,
                $userRepository,
                $workflowHelper
            );
        }
    '''

    def private updateSortPositionsImpl(Application it) '''
        «updateSortPositionsDocBlock(false)»
        «updateSortPositionsSignature» {
            return parent::updateSortPositions(
                $request,
                $entityFactory
            );
        }
    '''

    def private ajaxControllerImpl(Application it) '''
        namespace «appNamespace»\Controller;

        use Symfony\Component\HttpFoundation\JsonResponse;
        use Symfony\Component\HttpFoundation\Request;
        use Symfony\Component\Routing\Annotation\Route;
        «commonSystemImports(false)»
        use «appNamespace»\Controller\Base\AbstractAjaxController;
        «commonAppImports»

        /**
         * Ajax controller implementation class.
         */
        #[Route('/«name.formatForDB»/ajax')]
        class AjaxController extends AbstractAjaxController
        {
            «additionalAjaxFunctions»

            // feel free to add your own ajax controller methods here
        }
    '''

    def private needsDuplicateCheck(Application it) {
        entities.exists[getUniqueDerivedFields.filter[!primaryKey].size > 0]
        || (hasSluggable && !getAllEntities.filter[hasSluggableFields && slugUnique].empty)
    }
}
