package org.zikula.modulestudio.generator.cartridges.zclassic.controller.additions

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.EntityTreeType
import de.guite.modulestudio.metamodel.StringField
import de.guite.modulestudio.metamodel.TextField
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.ControllerHelperFunctions
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.GeneratorSettingsExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class AjaxController {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension GeneratorSettingsExtensions = new GeneratorSettingsExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelExtensions = new ModelExtensions
    extension ModelJoinExtensions = new ModelJoinExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    def generate(Application it, IFileSystemAccess fsa) {
        println('Ajax controller class')
        val fh = new FileHelper
        generateClassPair(fsa, getAppSourceLibPath + 'Controller/AjaxController.php',
            fh.phpFileContent(it, ajaxControllerBaseClass), fh.phpFileContent(it, ajaxControllerImpl)
        )
    }

    def private ajaxControllerBaseClass(Application it) '''
        namespace «appNamespace»\Controller\Base;

        «IF !getAllUserFields.empty»
            use Doctrine\ORM\AbstractQuery;
        «ENDIF»
        use Symfony\Component\HttpFoundation\JsonResponse;
        use Symfony\Component\HttpFoundation\Request;
        «IF hasTrees && hasEditActions»
            use Symfony\Component\Routing\Generator\UrlGeneratorInterface;
        «ENDIF»
        «IF needsDuplicateCheck || hasBooleansWithAjaxToggle || hasTrees»
            use Symfony\Component\Security\Core\Exception\AccessDeniedException;
        «ENDIF»
        «IF hasTrees»
            use RuntimeException;
        «ENDIF»
        use Zikula\Core\Controller\AbstractController;
        «IF generateExternalControllerAndFinder || needsDuplicateCheck || hasBooleansWithAjaxToggle || hasTrees»
            use Zikula\Core\Response\Ajax\AjaxResponse;
        «ENDIF»
        «IF needsDuplicateCheck || hasBooleansWithAjaxToggle»
            use Zikula\Core\Response\Ajax\BadDataResponse;
        «ENDIF»
        «IF hasTrees»
            use Zikula\Core\Response\Ajax\FatalResponse;
        «ENDIF»
        «IF hasBooleansWithAjaxToggle»
            use Zikula\Core\Response\Ajax\NotFoundResponse;
        «ENDIF»

        /**
         * Ajax controller base class.
         */
        abstract class AbstractAjaxController extends AbstractController
        {
            «additionalAjaxFunctionsBase»
        }
    '''

    def additionalAjaxFunctionsBase(Application it) '''
        «userSelectorsBase»
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
    '''

    def private userSelectorsBase(Application it) '''
        «val userFields = getAllUserFields»
        «IF !userFields.empty»
            «FOR userField : userFields»

                /**
                 * Retrieves a list of users.
                 *
                 * @param Request $request Current request instance
                 *
                 * @return JsonResponse
                 */
                public function get«userField.entity.name.formatForCodeCapital»«userField.name.formatForCodeCapital»UsersAction(Request $request)
                {
                    return $this->getCommonUsersListAction($request);
                }
            «ENDFOR»
        «ENDIF»
        «IF needsUserAutoCompletion»

            «getCommonUsersListBase»
        «ENDIF»
    '''

    def private getCommonUsersListBase(Application it) '''
        «getCommonUsersListDocBlock(true)»
        «getCommonUsersListSignature»
        {
            «getCommonUsersListBaseImpl»
        }
    '''

    def private getCommonUsersListDocBlock(Application it, Boolean isBase) '''
        /**
         * Retrieves a general purpose list of users.
         «IF !isBase»
         *
         * @Route("/getCommonUsersList", options={"expose"=true})
         * @Method("GET")
         «ENDIF»
         *
         * @param Request $request Current request instance
         *
         * @return JsonResponse
         */ 
    '''

    def private getCommonUsersListSignature(Application it) '''
        public function getCommonUsersListAction(Request $request)
    '''

    def private getCommonUsersListBaseImpl(Application it) '''
        if (!$this->hasPermission('«appName»::Ajax', '::', ACCESS_EDIT)) {
            return true;
        }

        $fragment = $request->query->get('fragment', '');
        $userRepository = $this->get('zikula_users_module.user_repository');
        $limit = 50;
        $filter = [
            'uname' => ['operator' => 'like', 'operand' => '%' . $fragment . '%']
        ];
        $results = $userRepository->query($filter, ['uname' => 'asc'], $limit);

        // load avatar plugin
        include_once 'lib/legacy/viewplugins/function.useravatar.php';
        $view = \Zikula_View::getInstance('«appName»', false);

        $resultItems = [];
        if (count($results) > 0) {
            foreach ($results as $result) {
                $resultItems[] = [
                    'uid' => $result->getUid(),
                    'uname' => $result->getUname(),
                    'avatar' => smarty_function_useravatar(['uid' => $result->getUid(), 'rating' => 'g'], $view)
                ];
            }
        }

        return new JsonResponse($resultItems);
    '''

    def private getItemListFinderBase(Application it) '''
        «getItemListFinderDocBlock(true)»
        «getItemListFinderSignature»
        {
            «getItemListFinderBaseImpl»
        }

        «getItemListFinderPrepareSlimItem»
    '''

    def private getItemListFinderDocBlock(Application it, Boolean isBase) '''
        /**
         * Retrieve item list for finder selections in Forms, Content type plugin and Scribite.
         «IF !isBase»
         *
         * @Route("/getItemListFinder", options={"expose"=true})
         * @Method("POST")
         «ENDIF»
         *
         * @param string $ot      Name of currently used object type
         * @param string $sort    Sorting field
         * @param string $sortdir Sorting direction
         *
         * @return AjaxResponse
         */
    '''

    def private getItemListFinderSignature(Application it) '''
        public function getItemListFinderAction(Request $request)
    '''

    def private getItemListFinderBaseImpl(Application it) '''
        if (!$this->hasPermission('«appName»::Ajax', '::', ACCESS_EDIT)) {
            return true;
        }

        $objectType = $request->request->getAlnum('ot', '«getLeadingEntity.name.formatForCode»');
        $controllerHelper = $this->get('«appService».controller_helper');
        $contextArgs = ['controller' => 'ajax', 'action' => 'getItemListFinder'];
        if (!in_array($objectType, $controllerHelper->getObjectTypes('controllerAction', $contextArgs))) {
            $objectType = $controllerHelper->getDefaultObjectType('controllerAction', $contextArgs);
        }

        $repository = $this->get('«appService».entity_factory')->getRepository($objectType);
        $entityDisplayHelper = $this->get('«appService».entity_display_helper');
        $descriptionFieldName = $entityDisplayHelper->getDescriptionFieldName($objectType);

        $sort = $request->request->getAlnum('sort', '');
        if (empty($sort) || !in_array($sort, $repository->getAllowedSortingFields())) {
            $sort = $repository->getDefaultSortingField();
        }

        $sdir = strtolower($request->request->getAlpha('sortdir', ''));
        if ($sdir != 'asc' && $sdir != 'desc') {
            $sdir = 'asc';
        }

        $where = ''; // filters are processed inside the repository class
        $searchTerm = $request->request->get('q', '');
        $sortParam = $sort . ' ' . $sdir;

        $entities = [];
        if ($searchTerm != '') {
            list ($entities, $totalAmount) = $repository->selectSearch($searchTerm, [], $sortParam, 1, 50);
        } else {
            $entities = $repository->selectWhere($where, $sortParam);
        }

        $slimItems = [];
        $component = '«appName»:' . ucfirst($objectType) . ':';
        foreach ($entities as $item) {
            $itemId = $item->getKey();
            if (!$this->hasPermission($component, $itemId . '::', ACCESS_READ)) {
                continue;
            }
            $slimItems[] = $this->prepareSlimItem($repository, $objectType, $item, $itemId, $descriptionFieldName);
        }

        return new AjaxResponse($slimItems);
    '''

    def private getItemListFinderPrepareSlimItem(Application it) '''
        /**
         * Builds and returns a slim data array from a given entity.
         *
         * @param EntityRepository $repository       Repository for the treated object type
         * @param string           $objectType       The currently treated object type
         * @param object           $item             The currently treated entity
         * @param string           $itemId           Data item identifier(s)
         * @param string           $descriptionField Name of item description field
         *
         * @return array The slim data representation
         */
        protected function prepareSlimItem($repository, $objectType, $item, $itemId, $descriptionField)
        {
            $previewParameters = [
                $objectType => $item
            ];
            $contextArgs = ['controller' => $objectType, 'action' => 'display'];
            $previewParameters = $this->get('«appService».controller_helper')->addTemplateParameters($objectType, $previewParameters, 'controllerAction', $contextArgs);

            $previewInfo = base64_encode($this->get('twig')->render('@«appName»/External/' . ucfirst($objectType) . '/info.html.twig', $previewParameters));

            $title = $this->get('«appService».entity_display_helper')->getFormattedTitle($item);
            $description = $descriptionField != '' ? $item[$descriptionField] : '';

            return [
                'id'          => $itemId,
                'title'       => str_replace('&amp;', '&', $title),
                'description' => $description,
                'previewInfo' => $previewInfo
            ];
        }
    '''

    def private getItemListAutoCompletionBase(Application it) '''
        «getItemListAutoCompletionDocBlock(true)»
        «getItemListAutoCompletionSignature»
        {
            «getItemListAutoCompletionBaseImpl»
        }
    '''

    def private getItemListAutoCompletionDocBlock(Application it, Boolean isBase) '''
        /**
         * Searches for entities for auto completion usage.
         «IF !isBase»
         *
         * @Route("/getItemListAutoCompletion", options={"expose"=true})
         * @Method("GET")
         «ENDIF»
         *
         * @param Request $request Current request instance
         *
         * @return JsonResponse
         */
    '''

    def private getItemListAutoCompletionSignature(Application it) '''
        public function getItemListAutoCompletionAction(Request $request)
    '''

    def private getItemListAutoCompletionBaseImpl(Application it) '''
        if (!$this->hasPermission('«appName»::Ajax', '::', ACCESS_EDIT)) {
            return true;
        }

        $objectType = $request->query->getAlnum('ot', '«getLeadingEntity.name.formatForCode»');
        $controllerHelper = $this->get('«appService».controller_helper');
        $contextArgs = ['controller' => 'ajax', 'action' => 'getItemListAutoCompletion'];
        if (!in_array($objectType, $controllerHelper->getObjectTypes('controllerAction', $contextArgs))) {
            $objectType = $controllerHelper->getDefaultObjectType('controllerAction', $contextArgs);
        }

        $repository = $this->get('«appService».entity_factory')->getRepository($objectType);
        $fragment = $request->query->get('fragment', '');
        $exclude = $request->query->get('exclude', '');
        $exclude = !empty($exclude) ? explode(',', str_replace(', ', ',', $exclude)) : [];

        // parameter for used sorting field
        «new ControllerHelperFunctions().defaultSorting(it)»
        $sortParam = $sort . ' asc';

        $currentPage = 1;
        $resultsPerPage = 20;

        // get objects from database
        list($entities, $objectCount) = $repository->selectSearch($fragment, $exclude, $sortParam, $currentPage, $resultsPerPage);

        $resultItems = [];

        if ((is_array($entities) || is_object($entities)) && count($entities) > 0) {
            «prepareForAutoCompletionProcessing»
            foreach ($entities as $item) {
                $itemTitle = $entityDisplayHelper->getFormattedTitle($item);
                «IF hasImageFields»
                    $itemTitleStripped = str_replace('"', '', $itemTitle);
                «ENDIF»
                $itemDescription = isset($item[$descriptionFieldName]) && !empty($item[$descriptionFieldName]) ? $item[$descriptionFieldName] : '';//$this->__('No description yet.')
                if (!empty($itemDescription)) {
                    $itemDescription = substr($itemDescription, 0, 50) . '&hellip;';
                }

                $resultItem = [
                    'id' => $item->getKey(),
                    'title' => $itemTitle,
                    'description' => $itemDescription,
                    'image' => ''
                ];
                «IF hasImageFields»

                    // check for preview image
                    if (!empty($previewFieldName) && !empty($item[$previewFieldName])) {
                        $thumbImagePath = $imagineCacheManager->getThumb($item[$previewFieldName]->getPathname(), 'zkroot', $thumbRuntimeOptions);
                        $resultItem['image'] = '<img src="' . $thumbImagePath . '" width="50" height="50" alt="' . $itemTitleStripped . '" />';
                    }
                «ENDIF»

                $resultItems[] = $resultItem;
            }
        }

        return new JsonResponse($resultItems);
    '''

    def private prepareForAutoCompletionProcessing(Application it) '''
        $entityDisplayHelper = $this->get('«appService».entity_display_helper');
        $descriptionFieldName = $entityDisplayHelper->getDescriptionFieldName($objectType);
        «IF hasImageFields»
            $previewFieldName = $entityDisplayHelper->getPreviewFieldName($objectType);
            $imagineCacheManager = $this->get('liip_imagine.cache.manager');
            $imageHelper = $this->get('«appService».image_helper');
            $thumbRuntimeOptions = $imageHelper->getRuntimeOptions($objectType, $previewFieldName, 'controllerAction', $contextArgs);
        «ENDIF»
    '''

    def private checkForDuplicateBase(Application it) '''
        «checkForDuplicateDocBlock(true)»
        «checkForDuplicateSignature»
        {
            «checkForDuplicateBaseImpl»
        }
    '''

    def private checkForDuplicateDocBlock(Application it, Boolean isBase) '''
        /**
         * Checks whether a field value is a duplicate or not.
         «IF !isBase»
         *
         * @Route("/checkForDuplicate", options={"expose"=true})
         * @Method("POST")
         «ENDIF»
         *
         * @param Request $request Current request instance
         *
         * @return AjaxResponse
         *
         * @throws AccessDeniedException Thrown if the user doesn't have required permissions
         */
    '''

    def private checkForDuplicateSignature(Application it) '''
        public function checkForDuplicateAction(Request $request)
    '''

    def private checkForDuplicateBaseImpl(Application it) '''
        if (!$this->hasPermission('«appName»::Ajax', '::', ACCESS_EDIT)) {
            throw new AccessDeniedException();
        }

        «prepareDuplicateCheckParameters»
        /* can probably be removed
         * $createMethod = 'create' . ucfirst($objectType);
         * $object = $repository = $this->get('«appService».entity_factory')->$createMethod();
         */

        $result = false;
        switch ($objectType) {
        «FOR entity : getAllEntities»
            «val uniqueFields = entity.getUniqueDerivedFields.filter[!primaryKey]»
            «IF !uniqueFields.empty || (entity.hasSluggableFields && entity.slugUnique)»
                case '«entity.name.formatForCode»':
                    $repository = $this->get('«appService».entity_factory')->getRepository($objectType);
                    switch ($fieldName) {
                    «FOR uniqueField : uniqueFields»
                        case '«uniqueField.name.formatForCode»':
                                $result = $repository->detectUniqueState('«uniqueField.name.formatForCode»', $value, $exclude);
                                break;
                    «ENDFOR»
                    «IF entity.hasSluggableFields && entity.slugUnique»
                        case 'slug':
                                $entity = $repository->selectBySlug($value, false, $exclude);
                                $result = null !== $entity && isset($entity['slug']);
                                break;
                    «ENDIF»
                    }
                    break;
            «ENDIF»
        «ENDFOR»
        }

        // return response
        $result = ['isDuplicate' => $result];

        return new AjaxResponse($result);
    '''

    def private prepareDuplicateCheckParameters(Application it) '''
        $postData = $request->request;

        $objectType = $postData->getAlnum('ot', '«getLeadingEntity.name.formatForCode»');
        $controllerHelper = $this->get('«appService».controller_helper');
        $contextArgs = ['controller' => 'ajax', 'action' => 'checkForDuplicate'];
        if (!in_array($objectType, $controllerHelper->getObjectTypes('controllerAction', $contextArgs))) {
            $objectType = $controllerHelper->getDefaultObjectType('controllerAction', $contextArgs);
        }

        $fieldName = $postData->getAlnum('fn', '');
        $value = $postData->get('v', '');

        if (empty($fieldName) || empty($value)) {
            return new BadDataResponse($this->__('Error: invalid input.'));
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
        if (!count($uniqueFields) || !in_array($fieldName, $uniqueFields)) {
            return new BadDataResponse($this->__('Error: invalid input.'));
        }

        $exclude = $postData->get('ex', '');
    '''

    def private toggleFlagBase(Application it) '''
        «toggleFlagDocBlock(true)»
        «toggleFlagSignature»
        {
            «toggleFlagBaseImpl»
        }
    '''

    def private toggleFlagDocBlock(Application it, Boolean isBase) '''
        /**
         * Changes a given flag (boolean field) by switching between true and false.
         «IF !isBase»
         *
         * @Route("/toggleFlag", options={"expose"=true})
         * @Method("POST")
         «ENDIF»
         *
         * @param Request $request Current request instance
         *
         * @return AjaxResponse
         *
         * @throws AccessDeniedException Thrown if the user doesn't have required permissions
         */
    '''

    def private toggleFlagSignature(Application it) '''
        public function toggleFlagAction(Request $request)
    '''

    def private toggleFlagBaseImpl(Application it) '''
        if (!$this->hasPermission('«appName»::Ajax', '::', ACCESS_EDIT)) {
            throw new AccessDeniedException();
        }

        $postData = $request->request;

        $objectType = $postData->getAlnum('ot', '«getLeadingEntity.name.formatForCode»');
        $field = $postData->getAlnum('field', '');
        $id = $postData->getInt('id', 0);

        «val entities = getEntitiesWithAjaxToggle»
        if ($id == 0
            || («FOR entity : entities SEPARATOR ' && '»$objectType != '«entity.name.formatForCode»'«ENDFOR»)
        «FOR entity : entities»
            || ($objectType == '«entity.name.formatForCode»' && !in_array($field, [«FOR field : entity.getBooleansWithAjaxToggleEntity('') SEPARATOR ', '»'«field.name.formatForCode»'«ENDFOR»]))
        «ENDFOR»
        ) {
            return new BadDataResponse($this->__('Error: invalid input.'));
        }

        // select data from data source
        $entityFactory = $this->get('«appService».entity_factory');
        $repository = $entityFactory->getRepository($objectType);
        $entity = $repository->selectById($id, false);
        if (null === $entity) {
            return new NotFoundResponse($this->__('No such item.'));
        }

        // toggle the flag
        $entity[$field] = !$entity[$field];

        // save entity back to database
        $entityFactory->getObjectManager()->flush();

        $logger = $this->get('logger');
        $logArgs = ['app' => '«appName»', 'user' => $this->get('zikula_users_module.current_user')->get('uname'), 'field' => $field, 'entity' => $objectType, 'id' => $id];
        $logger->notice('{app}: User {user} toggled the {field} flag the {entity} with id {id}.', $logArgs);

        // return response
        return new AjaxResponse([
            'id' => $id,
            'state' => $entity[$field],
            'message' => $this->__('The setting has been successfully changed.')
        ]);
    '''

    def private handleTreeOperationBase(Application it) '''
        «handleTreeOperationDocBlock(true)»
        «handleTreeOperationSignature»
        {
            «handleTreeOperationBaseImpl»
        }
    '''

    def private handleTreeOperationDocBlock(Application it, Boolean isBase) '''
        /**
         * Performs different operations on tree hierarchies.
         «IF !isBase»
         *
         * @Route("/handleTreeOperation", options={"expose"=true})
         * @Method("POST")
         «ENDIF»
         *
         * @param Request $request Current request instance
         *
         * @return AjaxResponse
         *
         * @throws AccessDeniedException Thrown if the user doesn't have required permissions
         * @throws FatalResponse
         * @throws RuntimeException Thrown if tree verification or executing the workflow action fails
         */
    '''

    def private handleTreeOperationSignature(Application it) '''
        public function handleTreeOperationAction(Request $request)
    '''

    def private handleTreeOperationBaseImpl(Application it) '''
        if (!$this->hasPermission('«appName»::Ajax', '::', ACCESS_EDIT)) {
            throw new AccessDeniedException();
        }

        $postData = $request->request;

        «val treeEntities = getTreeEntities»
        // parameter specifying which type of objects we are treating
        $objectType = $postData->getAlnum('ot', '«treeEntities.head.name.formatForCode»');
        // ensure that we use only object types with tree extension enabled
        if (!in_array($objectType, [«FOR treeEntity : treeEntities SEPARATOR ", "»'«treeEntity.name.formatForCode»'«ENDFOR»])) {
            $objectType = '«treeEntities.head.name.formatForCode»';
        }

        «prepareTreeOperationParameters»

        $returnValue = [
            'data'    => [],
            'result'  => 'success',
            'message' => ''
        ];

        $createMethod = 'create' . ucfirst($objectType);
        $repository = $this->get('«appService».entity_factory')->getRepository($objectType);

        $rootId = 1;
        if (!in_array($op, ['addRootNode'])) {
            $rootId = $postData->getInt('root', 0);
            if (!$rootId) {
                $returnValue['result'] = 'failure';
                $returnValue['message'] = $this->__('Error: invalid root node.');

                return new AjaxResponse($returnValue);
            }
        }

        $entityFactory = $this->get('«appService».entity_factory');
        $repository = $entityFactory->getRepository($objectType);

        «/*
        // Select tree
        $tree = null;
        if (!in_array($op, ['addRootNode'])) {
            $tree = $repository->selectTree($rootId);
        }

        */»// recover any broken tree nodes
        $entityManager = $entityFactory->getObjectManager();
        $repository->recover();
        // flush recovered nodes
        $entityManager->flush();

        // verify tree state
        $verificationResult = $repository->verify();
        if (is_array($verificationResult)) {
            $errorMessages = [];
            foreach ($verificationResult as $errorMsg) {
                $errorMessages[] = $errorMsg;
            }
            $returnValue['result'] = 'failure';
            $returnValue['message'] = implode('<br />', $errorMessages);

            return new AjaxResponse($returnValue);
        }
        $entityManager->clear(); // clear cached nodes

        «treeOperationDetermineEntityFields»

        «treeOperationSwitch»

        $returnValue['message'] = $this->__('The operation was successful.');

        // Renew tree
        /** postponed, for now we do a page reload
        $returnValue['data'] = $repository->selectTree($rootId);
        */

        return new AjaxResponse($returnValue);
    '''

    def private prepareTreeOperationParameters(Application it) '''
        $op = $postData->getAlpha('op', '');
        if (!in_array($op, ['addRootNode', 'addChildNode', 'deleteNode', 'moveNode', 'moveNodeTo'])) {
            $returnValue['result'] = 'failure';
            $returnValue['message'] = $this->__('Error: invalid operation.');

            return new AjaxResponse($returnValue);
        }

        // Get id of treated node
        $id = 0;
        if (!in_array($op, ['addRootNode', 'addChildNode'])) {
            $id = $postData->getInt('id', 0);
            if (!$id) {
                $returnValue['result'] = 'failure';
                $returnValue['message'] = $this->__('Error: invalid node.');

                return new AjaxResponse($returnValue);
            }
        }
    '''

    def private treeOperationDetermineEntityFields(Application it) '''
        $titleFieldName = $descriptionFieldName = '';

        switch ($objectType) {
            «FOR entity : getTreeEntities»
                case '«entity.name.formatForCode»':
                    «val stringFields = entity.fields.filter(StringField).filter[length >= 20 && !nospace && !country && !htmlcolour && !language && !locale]»
                        $titleFieldName = '«IF !stringFields.empty»«stringFields.head.name.formatForCode»«ENDIF»';
                        «val textFields = entity.fields.filter(TextField).filter[mandatory && length >= 50]»
                        «IF !textFields.empty»
                            $descriptionFieldName = '«textFields.head.name.formatForCode»';
                        «ELSE»
                            «val textStringFields = entity.fields.filter(StringField).filter[mandatory && length >= 50 && !nospace && !country && !htmlcolour && !language && !locale]»
                            «IF textStringFields.length > 1»
                                $descriptionFieldName = '«textStringFields.get(1).name.formatForCode»';
                            «ENDIF»
                        «ENDIF»
                        break;
            «ENDFOR»
        }
    '''

    def private treeOperationSwitch(Application it) '''
        $currentUserApi = $this->get('zikula_users_module.current_user');
        $logger = $this->get('logger');
        $logArgs = ['app' => '«appName»', 'user' => $currentUserApi->get('uname'), 'entity' => $objectType];
        «IF hasStandardFieldEntities»

            $currentUserId = $currentUserApi->isLoggedIn() ? $currentUserApi->get('uid') : 1;
            $currentUser = $this->get('zikula_users_module.user_repository')->find($currentUserId);
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
        //$entityManager->transactional(function($entityManager) {
            $entity = $this->get('«appService».entity_factory')->$createMethod();
            if (!empty($titleFieldName)) {
                $entity[$titleFieldName] = $this->__('New root node');
            }
            if (!empty($descriptionFieldName)) {
                $entity[$descriptionFieldName] = $this->__('This is a new root node');
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
                $workflowHelper = $this->get('«appService».workflow_helper');
                $success = $workflowHelper->executeAction($entity, $action);
                if (!$success) {
                    $returnValue['result'] = 'failure';
                }
            } catch(\Exception $e) {
                $returnValue['result'] = 'failure';
                $returnValue['message'] = $this->__f('Sorry, but an error occured during the %action% action. Please apply the changes again!', ['%action%' => $action]) . '  ' . $e->getMessage();

                return new AjaxResponse($returnValue);
            }
        //});
    '''

    def private treeOperationAddChildNode(Application it) '''
        $parentId = $postData->getInt('pid', 0);
        if (!$parentId) {
            $returnValue['result'] = 'failure';
            $returnValue['message'] = $this->__('Error: invalid parent node.');

            return new AjaxResponse($returnValue);
        }

        //$entityManager->transactional(function($entityManager) {
            $childEntity = $this->get('«appService».entity_factory')->$createMethod();
            $childEntity[$titleFieldName] = $this->__('New child node');
            if (!empty($descriptionFieldName)) {
                $childEntity[$descriptionFieldName] = $this->__('This is a new child node');
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
                $returnValue['message'] = $this->__('No such item.');

                return new AjaxResponse($returnValue);
            }
            $childEntity->setParent($parentEntity);

            // save new object
            $action = 'submit';
            try {
                // execute the workflow action
                $workflowHelper = $this->get('«appService».workflow_helper');
                $success = $workflowHelper->executeAction($childEntity, $action);
                if (!$success) {
                    $returnValue['result'] = 'failure';
                } else {
                    «IF hasEditActions»
                        if (in_array($objectType, ['«getAllEntities.filter[tree != EntityTreeType.NONE && hasEditAction].map[name.formatForCode].join('\', \'')»'])) {
                            $returnValue['returnUrl'] = $this->get('router')->generate('«appName.formatForDB»_' . strtolower($objectType) . '_edit', $childEntity->createUrlArgs(), UrlGeneratorInterface::ABSOLUTE_URL);
                        }
                    «ENDIF»
                }
            } catch(\Exception $e) {
                $returnValue['result'] = 'failure';
                $returnValue['message'] = $this->__f('Sorry, but an error occured during the %action% action. Please apply the changes again!', ['%action%' => $action]) . '  ' . $e->getMessage();

                return new AjaxResponse($returnValue);
            }
        //});
    '''

    def private treeOperationDeleteNode(Application it) '''
        // remove node from tree and reparent all children
        $entity = $repository->selectById($id, false);
        if (null === $entity) {
            $returnValue['result'] = 'failure';
            $returnValue['message'] = $this->__('No such item.');

            return new AjaxResponse($returnValue);
        }

        «IF !targets('1.5')»
            $entity->initWorkflow();

        «ENDIF»
        // delete the object
        $action = 'delete';
        try {
            // execute the workflow action
            $workflowHelper = $this->get('«appService».workflow_helper');
            $success = $workflowHelper->executeAction($entity, $action);
            if (!$success) {
                $returnValue['result'] = 'failure';
            }
        } catch(\Exception $e) {
            $returnValue['result'] = 'failure';
            $returnValue['message'] = $this->__f('Sorry, but an error occured during the %action% action. Please apply the changes again!', ['%action%' => $action]) . '  ' . $e->getMessage();

            return new AjaxResponse($returnValue);
        }

        $repository->removeFromTree($entity);
        $entityManager->clear(); // clear cached nodes
    '''

    def private treeOperationMoveNode(Application it) '''
        $moveDirection = $postData->getAlpha('direction', '');
        if (!in_array($moveDirection, ['top', 'up', 'down', 'bottom'])) {
            $returnValue['result'] = 'failure';
            $returnValue['message'] = $this->__('Error: invalid direction.');

            return new AjaxResponse($returnValue);
        }

        $entity = $repository->selectById($id, false);
        if (null === $entity) {
            $returnValue['result'] = 'failure';
            $returnValue['message'] = $this->__('No such item.');

            return new AjaxResponse($returnValue);
        }

        if ($moveDirection == 'top') {
            $repository->moveUp($entity, true);
        } elseif ($moveDirection == 'up') {
            $repository->moveUp($entity, 1);
        } elseif ($moveDirection == 'down') {
            $repository->moveDown($entity, 1);
        } elseif ($moveDirection == 'bottom') {
            $repository->moveDown($entity, true);
        }
        $entityManager->flush();
    '''

    def private treeOperationMoveNodeTo(Application it) '''
        $moveDirection = $postData->getAlpha('direction', '');
        if (!in_array($moveDirection, ['after', 'before', 'bottom'])) {
            $returnValue['result'] = 'failure';
            $returnValue['message'] = $this->__('Error: invalid direction.');

            return new AjaxResponse($returnValue);
        }

        $destId = $postData->getInt('destid', 0);
        if (!$destId) {
            $returnValue['result'] = 'failure';
            $returnValue['message'] = $this->__('Error: invalid destination node.');

            return new AjaxResponse($returnValue);
        }

        $entityManager->clear();

        //$entityManager->transactional(function($entityManager) {
            $entity = $repository->selectById($id, false);
            $destEntity = $repository->selectById($destId, false);
            if (null === $entity || null === $destEntity) {
                $returnValue['result'] = 'failure';
                $returnValue['message'] = $this->__('No such item.');

                return new AjaxResponse($returnValue);
            }

            $entityManager->persist($destEntity);
            $entityManager->persist($currentUser);

            if ($moveDirection == 'after') {
                $repository->persistAsNextSiblingOf($entity, $destEntity);
            } elseif ($moveDirection == 'before') {
                $repository->persistAsPrevSiblingOf($entity, $destEntity);
            } elseif ($moveDirection == 'bottom') {
                $repository->persistAsLastChildOf($entity, $destEntity);
            }

            $entityManager->flush();
        //});
    '''



    def additionalAjaxFunctions(Application it) '''
        «userSelectorsImpl»
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
    '''

    def private userSelectorsImpl(Application it) '''
        «val userFields = getAllUserFields»
        «IF !userFields.empty»
            «FOR userField : userFields»

                /**
                 * Retrieves a list of users.
                 *
                 * @Route("/get«userField.entity.name.formatForCodeCapital»«userField.name.formatForCodeCapital»Users", options={"expose"=true})
                 * @Method("GET")
                 */
                public function get«userField.entity.name.formatForCodeCapital»«userField.name.formatForCodeCapital»UsersAction(Request $request)
                {
                    return parent::get«userField.entity.name.formatForCodeCapital»«userField.name.formatForCodeCapital»UsersAction($request);
                }
            «ENDFOR»
        «ENDIF»
        «IF needsUserAutoCompletion»

            «getCommonUsersListImpl»
        «ENDIF»
    '''

    def private getCommonUsersListImpl(Application it) '''
        «getCommonUsersListDocBlock(false)»
        «getCommonUsersListSignature»
        {
            return parent::getCommonUsersListAction($request);
        }
    '''

    def private getItemListFinderImpl(Application it) '''
        «getItemListFinderDocBlock(false)»
        «getItemListFinderSignature»
        {
            return parent::getItemListFinderAction($request);
        }
    '''

    def private getItemListAutoCompletionImpl(Application it) '''
        «getItemListAutoCompletionDocBlock(false)»
        «getItemListAutoCompletionSignature»
        {
            return parent::getItemListAutoCompletionAction($request);
        }
    '''

    def private checkForDuplicateImpl(Application it) '''
        «checkForDuplicateDocBlock(false)»
        «checkForDuplicateSignature»
        {
            return parent::checkForDuplicateAction($request);
        }
    '''

    def private toggleFlagImpl(Application it) '''
        «toggleFlagDocBlock(false)»
        «toggleFlagSignature»
        {
            return parent::toggleFlagAction($request);
        }
    '''

    def private handleTreeOperationImpl(Application it) '''
        «handleTreeOperationDocBlock(false)»
        «handleTreeOperationSignature»
        {
            return parent::handleTreeOperationAction($request);
        }
    '''

    def private ajaxControllerImpl(Application it) '''
        namespace «appNamespace»\Controller;

        use «appNamespace»\Controller\Base\AbstractAjaxController;
        use Sensio\Bundle\FrameworkExtraBundle\Configuration\Method;
        use Sensio\Bundle\FrameworkExtraBundle\Configuration\Route;
        use Symfony\Component\HttpFoundation\JsonResponse;
        use Symfony\Component\HttpFoundation\Request;
        «IF needsDuplicateCheck || hasBooleansWithAjaxToggle || hasTrees»
            use Symfony\Component\Security\Core\Exception\AccessDeniedException;
        «ENDIF»
        «IF hasTrees»
            use RuntimeException;
        «ENDIF»
        «IF generateExternalControllerAndFinder || needsDuplicateCheck || hasBooleansWithAjaxToggle || hasTrees»
            use Zikula\Core\Response\Ajax\AjaxResponse;
        «ENDIF»
        «IF needsDuplicateCheck || hasBooleansWithAjaxToggle»
            use Zikula\Core\Response\Ajax\BadDataResponse;
        «ENDIF»
        «IF hasTrees»
            use Zikula\Core\Response\Ajax\FatalResponse;
        «ENDIF»
        «IF hasBooleansWithAjaxToggle»
            use Zikula\Core\Response\Ajax\NotFoundResponse;
        «ENDIF»

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
