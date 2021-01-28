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

    def private commonSystemImports(Application it) '''
        «IF targets('3.0')»
            «IF needsAutoCompletion»
                use Liip\ImagineBundle\Imagine\Cache\CacheManager;
            «ENDIF»
            «IF hasBooleansWithAjaxToggle || hasTrees»
                use Psr\Log\LoggerInterface;
                «IF hasTrees»
                    use Symfony\Component\Routing\RouterInterface;
                «ENDIF»
                use Zikula\UsersModule\Api\ApiInterface\CurrentUserApiInterface;
                «IF hasTrees»
                    use Zikula\UsersModule\Entity\RepositoryInterface\UserRepositoryInterface;
                «ENDIF»
            «ENDIF»
        «ENDIF»
    '''

    def private commonAppImports(Application it) '''
        «IF targets('3.0')»
            «IF generateExternalControllerAndFinder || needsAutoCompletion || needsDuplicateCheck || hasBooleansWithAjaxToggle || hasTrees || hasSortable || hasUiHooksProviders»
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
        «ENDIF»
    '''

    def private ajaxControllerBaseClass(Application it) '''
        namespace «appNamespace»\Controller\Base;

        «IF hasUiHooksProviders»
            use DateTime;
        «ENDIF»
        «IF hasTrees»
            use Exception;
        «ENDIF»
        use Symfony\Component\HttpFoundation\JsonResponse;
        use Symfony\Component\HttpFoundation\Request;
        use Symfony\Component\HttpFoundation\Response;
        «IF hasTrees && hasEditActions»
            use Symfony\Component\Routing\Generator\UrlGeneratorInterface;
        «ENDIF»
        «IF generateExternalControllerAndFinder || needsAutoCompletion || needsDuplicateCheck || hasBooleansWithAjaxToggle || hasTrees || hasSortable || hasUiHooksProviders»
            use Symfony\Component\Security\Core\Exception\AccessDeniedException;
        «ENDIF»
        «IF targets('3.0')»
            use Zikula\Bundle\CoreBundle\Controller\AbstractController;
        «ELSE»
            use Zikula\Core\Controller\AbstractController;
        «ENDIF»
        «commonSystemImports»
        «IF hasUiHooksProviders»
            use «appNamespace»\Entity\HookAssignmentEntity;
        «ENDIF»
        «commonAppImports»

        /**
         * Ajax controller base class.
         */
        abstract class AbstractAjaxController extends AbstractController
        {
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
        «IF hasUiHooksProviders»

            «attachHookObjectBase»

            «detachHookObjectBase»
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
        /**
         «IF isBase»
         * Retrieve item list for finder selections, for example used in Scribite editor plug-ins.
         «IF !targets('3.0')»
         *
         * @param Request $request
         *
         * @return JsonResponse
         «ENDIF»
         «ELSE»
         * @Route("/getItemListFinder", methods = {"GET"}, options={"expose"=true})
         «ENDIF»
         */
    '''

    def private getItemListFinderSignature(Application it) {
        if (targets('3.0')) '''
            public function getItemListFinder«IF !targets('3.x-dev')»Action«ENDIF»(
                Request $request,
                ControllerHelper $controllerHelper,
                PermissionHelper $permissionHelper,
                EntityFactory $entityFactory,
                EntityDisplayHelper $entityDisplayHelper
            ): JsonResponse'''
        else '''
            public function getItemListFinderAction(
                Request $request
            )'''
    }

    def private getItemListFinderBaseImpl(Application it) '''
        if (!$request->isXmlHttpRequest()) {
            return «IF targets('2.0')»$this->json«ELSE»new JsonResponse«ENDIF»($this->«IF targets('3.0')»trans«ELSE»__«ENDIF»('Only ajax access is allowed!'), Response::HTTP_BAD_REQUEST);
        }

        if (!$this->hasPermission('«appName»::Ajax', '::', ACCESS_EDIT)) {
            throw new AccessDeniedException();
        }

        $objectType = $request->query->getAlnum('ot', '«getLeadingEntity.name.formatForCode»');
        «IF !targets('3.0')»
            $controllerHelper = $this->get('«appService».controller_helper');
        «ENDIF»
        $contextArgs = ['controller' => 'ajax', 'action' => 'getItemListFinder'];
        if (!in_array($objectType, $controllerHelper->getObjectTypes('controllerAction'«IF !isSystemModule», $contextArgs«ENDIF»), true)) {
            $objectType = $controllerHelper->getDefaultObjectType('controllerAction'«IF !isSystemModule», $contextArgs«ENDIF»);
        }

        «IF targets('3.0')»
            $repository = $entityFactory->getRepository($objectType);
        «ELSE»
            $repository = $this->get('«appService».entity_factory')->getRepository($objectType);
            $entityDisplayHelper = $this->get('«appService».entity_display_helper');
        «ENDIF»

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
            «IF targets('3.0')»$entities«ELSE»list($entities, $totalAmount)«ENDIF» = $repository->selectSearch($searchTerm, [], $sortParam, 1, 50, false);
        } else {
            $entities = $repository->selectWhere($where, $sortParam);
        }

        $slimItems = [];
        «IF !targets('3.0')»
            $permissionHelper = $this->get('«appService».permission_helper');
        «ENDIF»
        foreach ($entities as $item) {
            if (!$permissionHelper->mayRead($item)) {
                continue;
            }
            $itemId = $item->getKey();
            $slimItems[] = $this->prepareSlimItem(
                «IF targets('3.0')»$controllerHelper,
                $repository,
                $entityDisplayHelper,
                «ELSE»$repository,«ENDIF»
                $item,
                $itemId
            );
        }

        // return response
        return «IF targets('2.0')»$this->json«ELSE»new JsonResponse«ENDIF»($slimItems);
    '''

    def private getItemListFinderPrepareSlimItem(Application it) '''
        /**
         * Builds and returns a slim data array from a given entity.
         «IF !targets('3.0')»
         *
         * @param EntityRepository $repository Repository for the treated object type
         * @param object $item The currently treated entity
         * @param string $itemId Data item identifier(s)
         *
         * @return array The slim data representation
         «ENDIF»
         */
        protected function prepareSlimItem(
            «IF targets('3.0')»
                ControllerHelper $controllerHelper,
                EntityRepository $repository,
                EntityDisplayHelper $entityDisplayHelper,
                $item,
                string $itemId
            «ELSE»
                $repository,
                $item,
                $itemId
            «ENDIF»
        )«IF targets('3.0')»: array«ENDIF» {
            $objectType = $item->get_objectType();
            $previewParameters = [
                $objectType => $item,
            ];
            $contextArgs = ['controller' => $objectType, 'action' => 'display'];
            $previewParameters = «IF targets('3.0')»$controllerHelper«ELSE»$this->get('«appService».controller_helper')«ENDIF»->addTemplateParameters(
                $objectType,
                $previewParameters,
                'controllerAction',
                $contextArgs
            );

            $previewInfo = $this->«IF targets('3.0')»renderView«ELSE»get('twig')->render«ENDIF»(
                '@«appName»/External/' . ucfirst($objectType) . '/info.html.twig',
                $previewParameters
            );
            $previewInfo = base64_encode($previewInfo);

            «IF !targets('3.0')»
                $entityDisplayHelper = $this->get('«appService».entity_display_helper');
            «ENDIF»
            $title = $entityDisplayHelper->getFormattedTitle($item);
            $description = $entityDisplayHelper->getDescription($item);

            return [
                'id' => $itemId,
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
        /**
         «IF isBase»
         * Searches for entities for auto completion usage.
         «IF !targets('3.0')»
         *
         * @param Request $request
         *
         * @return JsonResponse
         «ENDIF»
         «ELSE»
         * @Route("/getItemListAutoCompletion", methods = {"GET"}, options={"expose"=true})
         «ENDIF»
         */
    '''

    def private getItemListAutoCompletionSignature(Application it) {
        if (targets('3.0')) '''
            public function getItemListAutoCompletion«IF !targets('3.x-dev')»Action«ENDIF»(
                Request $request,
                CacheManager $imagineCacheManager,
                ControllerHelper $controllerHelper,
                EntityFactory $entityFactory,
                EntityDisplayHelper $entityDisplayHelper«IF hasImageFields»,
                ImageHelper $imageHelper«ENDIF»
            ): JsonResponse'''
        else '''
            public function getItemListAutoCompletionAction(
                Request $request
            )'''
    }

    def private getItemListAutoCompletionBaseImpl(Application it) '''
        if (!$request->isXmlHttpRequest()) {
            return «IF targets('2.0')»$this->json«ELSE»new JsonResponse«ENDIF»($this->«IF targets('3.0')»trans«ELSE»__«ENDIF»('Only ajax access is allowed!'), Response::HTTP_BAD_REQUEST);
        }

        if (!$this->hasPermission('«appName»::Ajax', '::', ACCESS_EDIT)) {
            throw new AccessDeniedException();
        }

        $objectType = $request->query->getAlnum('ot', '«getLeadingEntity.name.formatForCode»');
        «IF !targets('3.0')»
            $controllerHelper = $this->get('«appService».controller_helper');
        «ENDIF»
        $contextArgs = ['controller' => 'ajax', 'action' => 'getItemListAutoCompletion'];
        if (!in_array($objectType, $controllerHelper->getObjectTypes('controllerAction'«IF !isSystemModule», $contextArgs«ENDIF»), true)) {
            $objectType = $controllerHelper->getDefaultObjectType('controllerAction'«IF !isSystemModule», $contextArgs«ENDIF»);
        }

        $repository = «IF targets('3.0')»$entityFactory«ELSE»$this->get('«appService».entity_factory')«ENDIF»->getRepository($objectType);
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
        «IF targets('3.0')»$entities«ELSE»list($entities, $totalAmount)«ENDIF» = $repository->selectSearch($searchTerm, $exclude, $sortParam, $currentPage, $resultsPerPage, false);

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
                    if (!empty($previewFieldName) && !empty($item[$previewFieldName])) {
                        «IF targets('3.0')»
                            $imagePath = $item[$previewFieldName]->getPathname();
                            $imagePath = str_replace($item->get_uploadBasePathAbsolute(), $item->get_uploadBasePathRelative(), $imagePath);
                            $thumbImagePath = $imagineCacheManager->getBrowserPath($imagePath, 'zkroot', $thumbRuntimeOptions);
                        «ELSE»
                            $thumbImagePath = $imagineCacheManager->getBrowserPath($item[$previewFieldName]->getPathname(), 'zkroot', $thumbRuntimeOptions);
                        «ENDIF»
                        $resultItem['image'] = '<img src="' . $thumbImagePath . '" width="50" height="50" alt="' . $itemTitleStripped . '"«IF targets('3.0')» class="mr-1"«ENDIF» />';
                    }
                «ENDIF»

                $resultItems[] = $resultItem;
            }
        }

        return «IF targets('2.0')»$this->json«ELSE»new JsonResponse«ENDIF»($resultItems);
    '''

    def private prepareForAutoCompletionProcessing(Application it) '''
        «IF !targets('3.0')»
            $entityDisplayHelper = $this->get('«appService».entity_display_helper');
        «ENDIF»
        $descriptionFieldName = $entityDisplayHelper->getDescriptionFieldName($objectType);
        «IF hasImageFields»
            $previewFieldName = $entityDisplayHelper->getPreviewFieldName($objectType);
            «IF !targets('3.0')»
                $imagineCacheManager = $this->get('liip_imagine.cache.manager');
                $imageHelper = $this->get('«appService».image_helper');
            «ENDIF»
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
        /**
         «IF isBase»
         * Checks whether a field value is a duplicate or not.
         *
         «IF !targets('3.0')»
         * @param Request $request
         *
         * @return JsonResponse
         *
         «ENDIF»
         * @throws AccessDeniedException Thrown if the user doesn't have required permissions
         «ELSE»
         * @Route("/checkForDuplicate", methods = {"GET"}, options={"expose"=true})
         «ENDIF»
         */
    '''

    def private checkForDuplicateSignature(Application it) {
        if (targets('3.0')) '''
            public function checkForDuplicate«IF !targets('3.x-dev')»Action«ENDIF»(
                Request $request,
                ControllerHelper $controllerHelper,
                EntityFactory $entityFactory
            ): JsonResponse'''
        else '''
            public function checkForDuplicateAction(
                Request $request
            )'''
    }

    def private checkForDuplicateBaseImpl(Application it) '''
        if (!$request->isXmlHttpRequest()) {
            return «IF targets('2.0')»$this->json«ELSE»new JsonResponse«ENDIF»($this->«IF targets('3.0')»trans«ELSE»__«ENDIF»('Only ajax access is allowed!'), Response::HTTP_BAD_REQUEST);
        }

        if (!$this->hasPermission('«appName»::Ajax', '::', ACCESS_EDIT)) {
            throw new AccessDeniedException();
        }

        «prepareDuplicateCheckParameters»

        $result = false;
        switch ($objectType) {
            «FOR entity : getAllEntities»
                «val uniqueFields = entity.getUniqueDerivedFields.filter[!primaryKey]»
                «IF !uniqueFields.empty || (entity.hasSluggableFields && entity.slugUnique)»
                    case '«entity.name.formatForCode»':
                        $repository = «IF targets('3.0')»$entityFactory«ELSE»$this->get('«appService».entity_factory')«ENDIF»->getRepository($objectType);
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
        return «IF targets('2.0')»$this->json«ELSE»new JsonResponse«ENDIF»(['isDuplicate' => $result]);
    '''

    def private prepareDuplicateCheckParameters(Application it) '''
        $objectType = $request->query->getAlnum('ot', '«getLeadingEntity.name.formatForCode»');
        «IF !targets('3.0')»
            $controllerHelper = $this->get('«appService».controller_helper');
        «ENDIF»
        $contextArgs = ['controller' => 'ajax', 'action' => 'checkForDuplicate'];
        if (!in_array($objectType, $controllerHelper->getObjectTypes('controllerAction'«IF !isSystemModule», $contextArgs«ENDIF»), true)) {
            $objectType = $controllerHelper->getDefaultObjectType('controllerAction'«IF !isSystemModule», $contextArgs«ENDIF»);
        }

        $fieldName = $request->query->getAlnum('fn');
        $value = $request->query->get('v');

        if (empty($fieldName) || empty($value)) {
            return «IF targets('2.0')»$this->json«ELSE»new JsonResponse«ENDIF»($this->«IF targets('3.0')»trans«ELSE»__«ENDIF»('Error: invalid input.'), JsonResponse::HTTP_BAD_REQUEST);
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
            return «IF targets('2.0')»$this->json«ELSE»new JsonResponse«ENDIF»($this->«IF targets('3.0')»trans«ELSE»__«ENDIF»('Error: invalid input.'), JsonResponse::HTTP_BAD_REQUEST);
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
        /**
         «IF isBase»
         * Changes a given flag (boolean field) by switching between true and false.
         *
         «IF !targets('3.0')»
         * @param Request $request
         *
         * @return JsonResponse
         *
         «ENDIF»
         * @throws AccessDeniedException Thrown if the user doesn't have required permissions
         «ELSE»
         * @Route("/toggleFlag", methods = {"POST"}, options={"expose"=true})
         «ENDIF»
         */
    '''

    def private toggleFlagSignature(Application it) {
        if (targets('3.0')) '''
            public function toggleFlag«IF !targets('3.x-dev')»Action«ENDIF»(
                Request $request,
                LoggerInterface $logger,
                EntityFactory $entityFactory,
                CurrentUserApiInterface $currentUserApi
            ): JsonResponse'''
        else '''
            public function toggleFlagAction(
                Request $request
            )'''
    }

    def private toggleFlagBaseImpl(Application it) '''
        if (!$request->isXmlHttpRequest()) {
            return «IF targets('2.0')»$this->json«ELSE»new JsonResponse«ENDIF»($this->«IF targets('3.0')»trans«ELSE»__«ENDIF»('Only ajax access is allowed!'), Response::HTTP_BAD_REQUEST);
        }

        if (!$this->hasPermission('«appName»::Ajax', '::', ACCESS_EDIT)) {
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
            return «IF targets('2.0')»$this->json«ELSE»new JsonResponse«ENDIF»($this->«IF targets('3.0')»trans«ELSE»__«ENDIF»('Error: invalid input.'), JsonResponse::HTTP_BAD_REQUEST);
        }

        // select data from data source
        «IF !targets('3.0')»
            $entityFactory = $this->get('«appService».entity_factory');
        «ENDIF»
        $repository = $entityFactory->getRepository($objectType);
        $entity = $repository->selectById($id, false);
        if (null === $entity) {
            return «IF targets('2.0')»$this->json«ELSE»new JsonResponse«ENDIF»($this->«IF targets('3.0')»trans«ELSE»__«ENDIF»('No such item.'), JsonResponse::HTTP_NOT_FOUND);
        }

        // toggle the flag
        $entity[$field] = !$entity[$field];

        // save entity back to database
        $entityFactory->getEntityManager()->flush();

        «IF !targets('3.0')»
            $logger = $this->get('logger');
        «ENDIF»
        $logArgs = [
            'app' => '«appName»',
            'user' => «IF targets('3.0')»$currentUserApi«ELSE»$this->get('zikula_users_module.current_user')«ENDIF»->get('uname'),
            'field' => $field,
            'entity' => $objectType,
            'id' => $id,
        ];
        $logger->notice('{app}: User {user} toggled the {field} flag the {entity} with id {id}.', $logArgs);

        // return response
        return «IF targets('2.0')»$this->json«ELSE»new JsonResponse«ENDIF»([
            'id' => $id,
            'state' => $entity[$field],
            'message' => $this->«IF targets('3.0')»trans«ELSE»__«ENDIF»('The setting has been successfully changed.'),
        ]);
    '''

    def private handleTreeOperationBase(Application it) '''
        «handleTreeOperationDocBlock(true)»
        «handleTreeOperationSignature» {
            «handleTreeOperationBaseImpl»
        }
    '''

    def private handleTreeOperationDocBlock(Application it, Boolean isBase) '''
        /**
         «IF isBase»
         * Performs different operations on tree hierarchies.
         *
         «IF !targets('3.0')»
         * @param Request $request
         *
         * @return JsonResponse
         *
         «ENDIF»
         * @throws AccessDeniedException Thrown if the user doesn't have required permissions
         «ELSE»
         * @Route("/handleTreeOperation", methods = {"POST"}, options={"expose"=true})
         «ENDIF»
         */
    '''

    def private handleTreeOperationSignature(Application it) {
        if (targets('3.0')) '''
            public function handleTreeOperation«IF !targets('3.x-dev')»Action«ENDIF»(
                Request $request,
                RouterInterface $router,
                LoggerInterface $logger,
                EntityFactory $entityFactory,
                EntityDisplayHelper $entityDisplayHelper,
                CurrentUserApiInterface $currentUserApi,
                UserRepositoryInterface $userRepository,
                WorkflowHelper $workflowHelper
            ): JsonResponse'''
        else '''
            public function handleTreeOperationAction(
                Request $request
            )'''
    }

    def private handleTreeOperationBaseImpl(Application it) '''
        if (!$request->isXmlHttpRequest()) {
            return «IF targets('2.0')»$this->json«ELSE»new JsonResponse«ENDIF»($this->«IF targets('3.0')»trans«ELSE»__«ENDIF»('Only ajax access is allowed!'), Response::HTTP_BAD_REQUEST);
        }

        if (!$this->hasPermission('«appName»::Ajax', '::', ACCESS_EDIT)) {
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
        «IF !targets('3.0')»
            $entityFactory = $this->get('«appService».entity_factory');
        «ENDIF»
        $repository = $entityFactory->getRepository($objectType);

        $rootId = 1;
        if (!in_array($op, ['addRootNode'], true)) {
            $rootId = $request->request->getInt('root');
            if (!$rootId) {
                $returnValue['result'] = 'failure';
                $returnValue['message'] = $this->«IF targets('3.0')»trans«ELSE»__«ENDIF»('Error: invalid root node.');

                return «IF targets('2.0')»$this->json«ELSE»new JsonResponse«ENDIF»($returnValue);
            }
        }

        $entityManager = $entityFactory->getEntityManager();
        «IF !targets('3.0')»
            $entityDisplayHelper = $this->get('«appService».entity_display_helper');
        «ENDIF»
        $titleFieldName = $entityDisplayHelper->getTitleFieldName($objectType);
        $descriptionFieldName = $entityDisplayHelper->getDescriptionFieldName($objectType);

        «treeOperationSwitch»

        $returnValue['message'] = $this->«IF targets('3.0')»trans«ELSE»__«ENDIF»('The operation was successful.');

        // Renew tree
        /* postponed, for now we do a page reload.
         * $returnValue['data'] = $repository->selectTree($rootId);
         */

        return «IF targets('2.0')»$this->json«ELSE»new JsonResponse«ENDIF»($returnValue);
    '''

    def private prepareTreeOperationParameters(Application it) '''
        $op = $request->request->getAlpha('op');
        if (!in_array($op, ['addRootNode', 'addChildNode', 'deleteNode', 'moveNode', 'moveNodeTo'], true)) {
            $returnValue['result'] = 'failure';
            $returnValue['message'] = $this->«IF targets('3.0')»trans«ELSE»__«ENDIF»('Error: invalid operation.');

            return «IF targets('2.0')»$this->json«ELSE»new JsonResponse«ENDIF»($returnValue);
        }

        // Get id of treated node
        $id = 0;
        if (!in_array($op, ['addRootNode', 'addChildNode'], true)) {
            $id = $request->request->getInt('id');
            if (!$id) {
                $returnValue['result'] = 'failure';
                $returnValue['message'] = $this->«IF targets('3.0')»trans«ELSE»__«ENDIF»('Error: invalid node.');

                return «IF targets('2.0')»$this->json«ELSE»new JsonResponse«ENDIF»($returnValue);
            }
        }
    '''

    def private treeOperationSwitch(Application it) '''
        «IF !targets('3.0')»
            $currentUserApi = $this->get('zikula_users_module.current_user');
            $logger = $this->get('logger');
        «ENDIF»
        $logArgs = ['app' => '«appName»', 'user' => $currentUserApi->get('uname'), 'entity' => $objectType];
        «IF hasStandardFieldEntities»

            $currentUserId = $currentUserApi->isLoggedIn() ? $currentUserApi->get('uid') : 1;
            $currentUser = «IF targets('3.0')»$userRepository«ELSE»$this->get('zikula_users_module.user_repository')«ENDIF»->find($currentUserId);
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
            $entity[$titleFieldName] = $this->«IF targets('3.0')»trans«ELSE»__«ENDIF»('New root node');
        }
        if (!empty($descriptionFieldName)) {
            $entity[$descriptionFieldName] = $this->«IF targets('3.0')»trans«ELSE»__«ENDIF»('This is a new root node');
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
            «IF !targets('3.0')»
                $workflowHelper = $this->get('«appService».workflow_helper');
            «ENDIF»
            $success = $workflowHelper->executeAction($entity, $action);
            if (!$success) {
                $returnValue['result'] = 'failure';
            }
        } catch (Exception $exception) {
            $returnValue['result'] = 'failure';
            $returnValue['message'] = $this->«IF targets('3.0')»trans«ELSE»__f«ENDIF»(
                'Sorry, but an error occured during the %action% action. Please apply the changes again!',
                ['%action%' => $action]
            ) . '  ' . $exception->getMessage();

            return «IF targets('2.0')»$this->json«ELSE»new JsonResponse«ENDIF»($returnValue);
        }
    '''

    def private treeOperationAddChildNode(Application it) '''
        $parentId = $request->request->getInt('pid');
        if (!$parentId) {
            $returnValue['result'] = 'failure';
            $returnValue['message'] = $this->«IF targets('3.0')»trans«ELSE»__«ENDIF»('Error: invalid parent node.');

            return «IF targets('2.0')»$this->json«ELSE»new JsonResponse«ENDIF»($returnValue);
        }

        $childEntity = $entityFactory->$createMethod();
        $childEntity[$titleFieldName] = $this->«IF targets('3.0')»trans«ELSE»__«ENDIF»('New child node');
        if (!empty($descriptionFieldName)) {
            $childEntity[$descriptionFieldName] = $this->«IF targets('3.0')»trans«ELSE»__«ENDIF»('This is a new child node');
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
            $returnValue['message'] = $this->«IF targets('3.0')»trans«ELSE»__«ENDIF»('No such item.');

            return «IF targets('2.0')»$this->json«ELSE»new JsonResponse«ENDIF»($returnValue);
        }
        $childEntity->setParent($parentEntity);

        // save new object
        $action = 'submit';
        try {
            // execute the workflow action
            «IF !targets('3.0')»
                $workflowHelper = $this->get('«appService».workflow_helper');
            «ENDIF»
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
                    $returnValue['returnUrl'] = «IF targets('3.0')»$router«ELSE»$this->get('router')«ENDIF»->generate(
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
            $returnValue['message'] = $this->«IF targets('3.0')»trans«ELSE»__f«ENDIF»(
                'Sorry, but an error occured during the %action% action. Please apply the changes again!',
                ['%action%' => $action]
            ) . '  ' . $exception->getMessage();

            return «IF targets('2.0')»$this->json«ELSE»new JsonResponse«ENDIF»($returnValue);
        }
    '''

    def private treeOperationDeleteNode(Application it) '''
        // remove node from tree and reparent all children
        $entity = $repository->selectById($id, false);
        if (null === $entity) {
            $returnValue['result'] = 'failure';
            $returnValue['message'] = $this->«IF targets('3.0')»trans«ELSE»__«ENDIF»('No such item.');

            return «IF targets('2.0')»$this->json«ELSE»new JsonResponse«ENDIF»($returnValue);
        }

        // delete the object
        $action = 'delete';
        try {
            // execute the workflow action
            «IF !targets('3.0')»
                $workflowHelper = $this->get('«appService».workflow_helper');
            «ENDIF»
            $success = $workflowHelper->executeAction($entity, $action);
            if (!$success) {
                $returnValue['result'] = 'failure';
            }
        } catch (Exception $exception) {
            $returnValue['result'] = 'failure';
            $returnValue['message'] = $this->«IF targets('3.0')»trans«ELSE»__f«ENDIF»(
                'Sorry, but an error occured during the %action% action. Please apply the changes again!',
                ['%action%' => $action]
            ) . '  ' . $exception->getMessage();

            return «IF targets('2.0')»$this->json«ELSE»new JsonResponse«ENDIF»($returnValue);
        }

        $repository->removeFromTree($entity);
        $entityManager->clear(); // clear cached nodes
    '''

    def private treeOperationMoveNode(Application it) '''
        $moveDirection = $request->request->getAlpha('direction');
        if (!in_array($moveDirection, ['top', 'up', 'down', 'bottom'], true)) {
            $returnValue['result'] = 'failure';
            $returnValue['message'] = $this->«IF targets('3.0')»trans«ELSE»__«ENDIF»('Error: invalid direction.');

            return «IF targets('2.0')»$this->json«ELSE»new JsonResponse«ENDIF»($returnValue);
        }

        $entity = $repository->selectById($id, false);
        if (null === $entity) {
            $returnValue['result'] = 'failure';
            $returnValue['message'] = $this->«IF targets('3.0')»trans«ELSE»__«ENDIF»('No such item.');

            return «IF targets('2.0')»$this->json«ELSE»new JsonResponse«ENDIF»($returnValue);
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
            $returnValue['message'] = $this->«IF targets('3.0')»trans«ELSE»__«ENDIF»('Error: invalid direction.');

            return «IF targets('2.0')»$this->json«ELSE»new JsonResponse«ENDIF»($returnValue);
        }

        $destId = $request->request->getInt('destid');
        if (!$destId) {
            $returnValue['result'] = 'failure';
            $returnValue['message'] = $this->«IF targets('3.0')»trans«ELSE»__«ENDIF»('Error: invalid destination node.');

            return «IF targets('2.0')»$this->json«ELSE»new JsonResponse«ENDIF»($returnValue);
        }

        $entity = $repository->selectById($id, false);
        $destEntity = $repository->selectById($destId, false);
        if (null === $entity || null === $destEntity) {
            $returnValue['result'] = 'failure';
            $returnValue['message'] = $this->«IF targets('3.0')»trans«ELSE»__«ENDIF»('No such item.');

            return «IF targets('2.0')»$this->json«ELSE»new JsonResponse«ENDIF»($returnValue);
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
        /**
         «IF isBase»
         * Updates the sort positions for a given list of entities.
         *
         «IF !targets('3.0')»
         * @param Request $request
         *
         * @return JsonResponse
         *
         «ENDIF»
         * @throws AccessDeniedException Thrown if the user doesn't have required permissions
         «ELSE»
         * @Route("/updateSortPositions", methods = {"POST"}, options={"expose"=true})
         «ENDIF»
         */
    '''

    def private updateSortPositionsSignature(Application it) {
        if (targets('3.0')) '''
            public function updateSortPositions«IF !targets('3.x-dev')»Action«ENDIF»(
                Request $request,
                EntityFactory $entityFactory
            ): JsonResponse'''
        else '''
            public function updateSortPositionsAction(
                Request $request
            )'''
    }

    def private updateSortPositionsBaseImpl(Application it) '''
        if (!$request->isXmlHttpRequest()) {
            return «IF targets('2.0')»$this->json«ELSE»new JsonResponse«ENDIF»($this->«IF targets('3.0')»trans«ELSE»__«ENDIF»('Only ajax access is allowed!'), Response::HTTP_BAD_REQUEST);
        }

        if (!$this->hasPermission('«appName»::Ajax', '::', ACCESS_EDIT)) {
            throw new AccessDeniedException();
        }

        $objectType = $request->request->getAlnum('ot', '«getLeadingEntity.name.formatForCode»');
        $itemIds = $request->request->get('identifiers', []);
        $min = $request->request->getInt('min');
        $max = $request->request->getInt('max');

        if (!is_array($itemIds) || 2 > count($itemIds) || 1 > $max || $max <= $min) {
            return «IF targets('2.0')»$this->json«ELSE»new JsonResponse«ENDIF»($this->«IF targets('3.0')»trans«ELSE»__«ENDIF»('Error: invalid input.'), JsonResponse::HTTP_BAD_REQUEST);
        }

        «IF !targets('3.0')»
            $entityFactory = $this->get('«appService».entity_factory');
        «ENDIF»
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
        return «IF targets('2.0')»$this->json«ELSE»new JsonResponse«ENDIF»([
            'message' => $this->«IF targets('3.0')»trans«ELSE»__«ENDIF»('The setting has been successfully changed.'),
        ]);
    '''

    def private attachHookObjectBase(Application it) '''
        «attachHookObjectDocBlock(true)»
        «attachHookObjectSignature» {
            «attachHookObjectBaseImpl»
        }
    '''

    def private detachHookObjectBase(Application it) '''
        «detachHookObjectDocBlock(true)»
        «detachHookObjectSignature» {
            «detachHookObjectBaseImpl»
        }
    '''

    def private attachHookObjectDocBlock(Application it, Boolean isBase) '''
        /**
         «IF isBase»
         * Attachs a given hook assignment by creating the corresponding assignment data record.
         *
         «IF !targets('3.0')»
         * @param Request $request
         *
         * @return JsonResponse
         *
         «ENDIF»
         * @throws AccessDeniedException Thrown if the user doesn't have required permissions
         «ELSE»
         * @Route("/attachHookObject", methods = {"POST"}, options={"expose"=true})
         «ENDIF»
         */
    '''

    def private detachHookObjectDocBlock(Application it, Boolean isBase) '''
        /**
         «IF isBase»
         * Detachs a given hook assignment by removing the corresponding assignment data record.
         *
         «IF !targets('3.0')»
         * @param Request $request
         *
         * @return JsonResponse
         *
         «ENDIF»
         * @throws AccessDeniedException Thrown if the user doesn't have required permissions
         «ELSE»
         * @Route("/detachHookObject", methods = {"POST"}, options={"expose"=true})
         «ENDIF»
         */
    '''

    def private attachHookObjectSignature(Application it) {
        if (targets('3.0')) '''
            public function attachHookObject«IF !targets('3.x-dev')»Action«ENDIF»(
                Request $request,
                EntityFactory $entityFactory
            ): JsonResponse'''
        else '''
            public function attachHookObjectAction(
                Request $request
            )'''
    }

    def private detachHookObjectSignature(Application it) {
        if (targets('3.0')) '''
            public function detachHookObject«IF !targets('3.x-dev')»Action«ENDIF»(
                Request $request,
                EntityFactory $entityFactory
            ): JsonResponse'''
        else '''
            public function detachHookObjectAction(
                Request $request
            )'''
    }

    def private attachHookObjectBaseImpl(Application it) '''
        if (!$request->isXmlHttpRequest()) {
            return «IF targets('2.0')»$this->json«ELSE»new JsonResponse«ENDIF»($this->«IF targets('3.0')»trans«ELSE»__«ENDIF»('Only ajax access is allowed!'), Response::HTTP_BAD_REQUEST);
        }

        if (!$this->hasPermission('«appName»::Ajax', '::', ACCESS_EDIT)) {
            throw new AccessDeniedException();
        }

        $subscriberOwner = $request->request->get('owner');
        $subscriberAreaId = $request->request->get('areaId');
        $subscriberObjectId = $request->request->getInt('objectId');
        $subscriberUrl = $request->request->get('url');
        $assignedEntity = $request->request->get('assignedEntity');
        $assignedId = $request->request->getInt('assignedId');

        if (!$subscriberOwner || !$subscriberAreaId || !$subscriberObjectId || !$assignedEntity || !$assignedId) {
            return «IF targets('2.0')»$this->json«ELSE»new JsonResponse«ENDIF»($this->«IF targets('3.0')»trans«ELSE»__«ENDIF»('Error: invalid input.'), JsonResponse::HTTP_BAD_REQUEST);
        }

        $subscriberUrl = !empty($subscriberUrl) ? unserialize($subscriberUrl) : [];

        $assignment = new HookAssignmentEntity();
        $assignment->setSubscriberOwner($subscriberOwner);
        $assignment->setSubscriberAreaId($subscriberAreaId);
        $assignment->setSubscriberObjectId($subscriberObjectId);
        $assignment->setSubscriberUrl($subscriberUrl);
        $assignment->setAssignedEntity($assignedEntity);
        $assignment->setAssignedId($assignedId);
        $assignment->setUpdatedDate(new DateTime());

        $entityManager = «IF targets('3.0')»$entityFactory«ELSE»$this->get('«appService».entity_factory')«ENDIF»->getEntityManager();
        $entityManager->persist($assignment);
        $entityManager->flush();

        // return response
        return «IF targets('2.0')»$this->json«ELSE»new JsonResponse«ENDIF»([
            'id' => $assignment->getId(),
        ]);
    '''

    def private detachHookObjectBaseImpl(Application it) '''
        if (!$request->isXmlHttpRequest()) {
            return «IF targets('2.0')»$this->json«ELSE»new JsonResponse«ENDIF»($this->«IF targets('3.0')»trans«ELSE»__«ENDIF»('Only ajax access is allowed!'), Response::HTTP_BAD_REQUEST);
        }

        if (!$this->hasPermission('«appName»::Ajax', '::', ACCESS_EDIT)) {
            throw new AccessDeniedException();
        }

        $id = $request->request->getInt('id', 0);
        if (!$id) {
            return «IF targets('2.0')»$this->json«ELSE»new JsonResponse«ENDIF»($this->«IF targets('3.0')»trans«ELSE»__«ENDIF»('Error: invalid input.'), JsonResponse::HTTP_BAD_REQUEST);
        }

        «IF !targets('3.0')»
            $entityFactory = $this->get('«appService».entity_factory');
        «ENDIF»
        $qb = $entityFactory->getEntityManager()->createQueryBuilder();
        $qb->delete('«vendor.formatForCodeCapital + '\\' + name.formatForCodeCapital + 'Module\\Entity\\HookAssignmentEntity'»', 'tbl')
           ->where('tbl.id = :identifier')
           ->setParameter('identifier', $id);
        
        $query = $qb->getQuery();
        $query->execute();

        // return response
        return «IF targets('2.0')»$this->json«ELSE»new JsonResponse«ENDIF»([
            'id' => $id,
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
        «IF hasUiHooksProviders»

            «attachHookObjectImpl»

            «detachHookObjectImpl»
        «ENDIF»
    '''

    def private getItemListFinderImpl(Application it) '''
        «getItemListFinderDocBlock(false)»
        «getItemListFinderSignature» {
            «IF targets('3.0')»
                return parent::getItemListFinder«IF !targets('3.x-dev')»Action«ENDIF»(
                    $request,
                    $controllerHelper,
                    $permissionHelper,
                    $entityFactory,
                    $entityDisplayHelper
                );
            «ELSE»
                return parent::getItemListFinderAction($request);
            «ENDIF»
        }
    '''

    def private getItemListAutoCompletionImpl(Application it) '''
        «getItemListAutoCompletionDocBlock(false)»
        «getItemListAutoCompletionSignature» {
            «IF targets('3.0')»
                return parent::getItemListAutoCompletion«IF !targets('3.x-dev')»Action«ENDIF»(
                    $request,
                    $imagineCacheManager,
                    $controllerHelper,
                    $entityFactory,
                    $entityDisplayHelper«IF hasImageFields»,
                    $imageHelper«ENDIF»
                );
            «ELSE»
                return parent::getItemListAutoCompletionAction($request);
            «ENDIF»
        }
    '''

    def private checkForDuplicateImpl(Application it) '''
        «checkForDuplicateDocBlock(false)»
        «checkForDuplicateSignature» {
            «IF targets('3.0')»
                return parent::checkForDuplicate«IF !targets('3.x-dev')»Action«ENDIF»(
                    $request,
                    $controllerHelper,
                    $entityFactory
                );
            «ELSE»
                return parent::checkForDuplicateAction($request);
            «ENDIF»
        }
    '''

    def private toggleFlagImpl(Application it) '''
        «toggleFlagDocBlock(false)»
        «toggleFlagSignature» {
            «IF targets('3.0')»
                return parent::toggleFlag«IF !targets('3.x-dev')»Action«ENDIF»(
                    $request,
                    $logger,
                    $entityFactory,
                    $currentUserApi
                );
            «ELSE»
                return parent::toggleFlagAction($request);
            «ENDIF»
        }
    '''

    def private handleTreeOperationImpl(Application it) '''
        «handleTreeOperationDocBlock(false)»
        «handleTreeOperationSignature» {
            «IF targets('3.0')»
                return parent::handleTreeOperation«IF !targets('3.x-dev')»Action«ENDIF»(
                    $request,
                    $router,
                    $logger,
                    $entityFactory,
                    $entityDisplayHelper,
                    $currentUserApi,
                    $userRepository,
                    $workflowHelper
                );
            «ELSE»
                return parent::handleTreeOperationAction($request);
            «ENDIF»
        }
    '''

    def private updateSortPositionsImpl(Application it) '''
        «updateSortPositionsDocBlock(false)»
        «updateSortPositionsSignature» {
            «IF targets('3.0')»
                return parent::updateSortPositions«IF !targets('3.x-dev')»Action«ENDIF»(
                    $request,
                    $entityFactory
                );
            «ELSE»
                return parent::updateSortPositionsAction($request);
            «ENDIF»
        }
    '''

    def private attachHookObjectImpl(Application it) '''
        «attachHookObjectDocBlock(false)»
        «attachHookObjectSignature» {
            «IF targets('3.0')»
                return parent::attachHookObject«IF !targets('3.x-dev')»Action«ENDIF»(
                    $request,
                    $entityFactory
                );
            «ELSE»
                return parent::attachHookObjectAction($request);
            «ENDIF»
        }
    '''

    def private detachHookObjectImpl(Application it) '''
        «detachHookObjectDocBlock(false)»
        «detachHookObjectSignature» {
            «IF targets('3.0')»
                return parent::detachHookObject«IF !targets('3.x-dev')»Action«ENDIF»(
                    $request,
                    $entityFactory
                );
            «ELSE»
                return parent::detachHookObjectAction($request);
            «ENDIF»
        }
    '''

    def private ajaxControllerImpl(Application it) '''
        namespace «appNamespace»\Controller;

        use Symfony\Component\HttpFoundation\JsonResponse;
        use Symfony\Component\HttpFoundation\Request;
        use Symfony\Component\Routing\Annotation\Route;
        «commonSystemImports»
        use «appNamespace»\Controller\Base\AbstractAjaxController;
        «commonAppImports»

        /**
         * Ajax controller implementation class.
         *
         * @Route("/ajax")
         */
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
