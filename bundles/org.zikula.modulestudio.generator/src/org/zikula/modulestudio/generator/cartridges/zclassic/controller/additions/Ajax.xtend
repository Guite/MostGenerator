package org.zikula.modulestudio.generator.cartridges.zclassic.controller.additions

import de.guite.modulestudio.metamodel.AjaxController
import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Controller
import de.guite.modulestudio.metamodel.StringField
import de.guite.modulestudio.metamodel.TextField
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.ControllerHelperFunctions
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.GeneratorSettingsExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Ajax {
    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension GeneratorSettingsExtensions = new GeneratorSettingsExtensions
    extension ModelExtensions = new ModelExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelJoinExtensions = new ModelJoinExtensions
    extension Utils = new Utils

    def dispatch additionalAjaxFunctionsBase(Controller it, Application app) {
    }

    def dispatch additionalAjaxFunctionsBase(AjaxController it, Application app) '''
        «userSelectorsBase(app)»
        «IF app.generateExternalControllerAndFinder»

            «getItemListFinderBase(app)»
        «ENDIF»
        «val joinRelations = app.getJoinRelations»
        «IF !joinRelations.empty»

            «getItemListAutoCompletionBase(app)»
        «ENDIF»
        «IF app.entities.exists[getUniqueDerivedFields.filter[!primaryKey].size > 0]
        || (app.hasSluggable && !app.getAllEntities.filter[hasSluggableFields && slugUnique].empty)»

            «checkForDuplicateBase(app)»
        «ENDIF»
        «IF app.hasBooleansWithAjaxToggle»

            «toggleFlagBase(app)»
        «ENDIF»
        «IF app.hasTrees»
        
            «handleTreeOperationBase(app)»
        «ENDIF»
    '''

    def private userSelectorsBase(AjaxController it, Application app) '''
        «val userFields = app.getAllUserFields»
        «IF !userFields.empty»
            «FOR userField : userFields»

                public function get«userField.entity.name.formatForCodeCapital»«userField.name.formatForCodeCapital»Users«IF app.isLegacy»()«ELSE»Action(Request $request)«ENDIF»
                {
                    return $this->getCommonUsersList«IF app.isLegacy»()«ELSE»Action($request)«ENDIF»;
                }
            «ENDFOR»

            «getCommonUsersListBase(app)»
        «ENDIF»
    '''

    def private getCommonUsersListBase(AjaxController it, Application app) '''
        «getCommonUsersListDocBlock(true)»
        «getCommonUsersListSignature»
        {
            «getCommonUsersListBaseImpl(app)»
        }
    '''

    def private getCommonUsersListDocBlock(AjaxController it, Boolean isBase) '''
        /**
         * Retrieve a general purpose list of users.
        «IF !application.isLegacy && !isBase»
        «' '»*
        «' '»* @Route("/getCommonUsersList", options={"expose"=true})
        «/*' '»* @Method("POST")*/»
        «ENDIF»
         *
         * @param string $fragment The search fragment
         *
         * @return «IF application.isLegacy»Zikula_Response_Ajax_Plain«ELSE»PlainResponse«ENDIF»
         */ 
    '''

    def private getCommonUsersListSignature(AjaxController it) '''
        public function getCommonUsersList«IF application.isLegacy»()«ELSE»Action(Request $request)«ENDIF»
    '''

    def private getCommonUsersListBaseImpl(AjaxController it, Application app) '''
        if (!«IF app.isLegacy»SecurityUtil::check«ELSE»$this->has«ENDIF»Permission($this->name . '::Ajax', '::', ACCESS_EDIT)) {
            return true;
        }

        $fragment = '';
        if ($«IF app.isLegacy»this->«ENDIF»request->«IF app.isLegacy»isPost()«ELSE»isMethod('POST')«ENDIF» && $«IF app.isLegacy»this->«ENDIF»request->request->has('fragment')) {
            $fragment = $«IF app.isLegacy»this->«ENDIF»request->request->get('fragment', '');
        } elseif ($this->request->«IF app.isLegacy»isGet()«ELSE»isMethod('GET')«ENDIF» && $this->request->query->has('fragment')) {
            $fragment = $«IF app.isLegacy»this->«ENDIF»request->query->get('fragment', '');
        }

        «IF app.isLegacy»
            ModUtil::dbInfoLoad('Users');
            $tables = DBUtil::getTables();

            $usersColumn = $tables['users_column'];

            $where = 'WHERE ' . $usersColumn['uname'] . ' REGEXP \'(' . DataUtil::formatForStore($fragment) . ')\'';
            $results = DBUtil::selectObjectArray('users', $where);
        «ELSE»
            «/* ModUtil::initOOModule('ZikulaUsersModule');
            */»
            $dql = 'SELECT u FROM Zikula\Module\UsersModule\Entity\UserEntity u WHERE u.uname LIKE :fragment';
            $query = $this->entityManager->createQuery($dql);
            $query->setParameter('fragment', '%' . $fragment . '%');
            $results = $query->getArrayResult();
        «ENDIF»

        // load avatar plugin
        «IF app.isLegacy»
            include_once 'lib/viewplugins/function.useravatar.php';
        «ELSE»
            include_once 'lib/legacy/viewplugins/function.useravatar.php';
        «ENDIF»
        $view = Zikula_View::getInstance('«app.appName»', false);

        «IF app.isLegacy»
            $out = '<ul>';
            if (is_array($results) && count($results) > 0) {
                foreach ($results as $result) {
                    $itemId = 'user' . $result['uid'];
                    $itemTitle = DataUtil::formatForDisplay($result['uname']);
                    $itemTitleStripped = str_replace('"', '', $itemTitle);
                    $out .= '<li id="' . $itemId . '" title="' . $itemTitleStripped . '">';
                    $out .= '<div class="itemtitle">' . $itemTitle . '</div>';
                    $out .= '<input type="hidden" id="' . $itemTitleStripped . '" value="' . $result['uid'] . '" />';
                    $out .= '<div id="itemPreview' . $itemId . '" class="itempreview informal">' . smarty_function_useravatar(array('uid' => $result['uid'], 'rating' => 'g'), $view) . '</div>';
                    $out .= '</li>';
                }
            }
            $out .= '</ul>';

            «IF app.isLegacy»
                return new Zikula_Response_Ajax_Plain($out);
            «ELSE»
                return new PlainResponse($out);
            «ENDIF»
        «ELSE»
            $resultItems = [];
            if (is_array($results) && count($results) > 0) {
                foreach ($results as $result) {
                    $resultItems[] = [
                        'uid' => $result['uid'],
                        'uname' => DataUtil::formatForDisplay($result['uname']),
                        'avatar' => smarty_function_useravatar(['uid' => $result['uid'], 'rating' => 'g'], $view)
                    ];
                }
            }

            return new JsonResponse($resultItems);
        «ENDIF»
    '''

    def private getItemListFinderBase(AjaxController it, Application app) '''
        «getItemListFinderDocBlock(true)»
        «getItemListFinderSignature»
        {
            «getItemListFinderBaseImpl(app)»
        }

        «getItemListFinderPrepareSlimItem(app)»
    '''

    def private getItemListFinderDocBlock(AjaxController it, Boolean isBase) '''
        /**
         * Retrieve item list for finder selections in Forms, Content type plugin and Scribite.
        «IF !application.isLegacy && !isBase»
        «' '»*
        «' '»* @Route("/getItemListFinder", options={"expose"=true})
        «/*' '»* @Method("POST")*/»
        «ENDIF»
         *
         * @param string $ot      Name of currently used object type
         * @param string $sort    Sorting field
         * @param string $sortdir Sorting direction
         *
         * @return «IF application.isLegacy»Zikula_Response_Ajax«ELSE»AjaxResponse«ENDIF»
         */
    '''

    def private getItemListFinderSignature(AjaxController it) '''
        public function getItemListFinder«IF application.isLegacy»()«ELSE»Action(Request $request)«ENDIF»
    '''

    def private getItemListFinderBaseImpl(AjaxController it, Application app) '''
        if (!«IF app.isLegacy»SecurityUtil::check«ELSE»$this->has«ENDIF»Permission($this->name . '::Ajax', '::', ACCESS_EDIT)) {
            return true;
        }

        $objectType = '«app.getLeadingEntity.name.formatForCode»';
        «IF app.isLegacy»
            if ($this->request->isPost() && $this->request->request->has('ot')) {
                $objectType = $this->request->request->filter('ot', '«app.getLeadingEntity.name.formatForCode»', FILTER_SANITIZE_STRING);
            } elseif ($this->request->isGet() && $this->request->query->has('ot')) {
                $objectType = $this->request->query->filter('ot', '«app.getLeadingEntity.name.formatForCode»', FILTER_SANITIZE_STRING);
            }
        «ELSE»
            if ($request->isMethod('POST') && $request->request->has('ot')) {
                $objectType = $request->request->getAlnum('ot', '«app.getLeadingEntity.name.formatForCode»');
            } elseif ($request->isMethod('GET') && $request->query->has('ot')) {
                $objectType = $request->query->getAlnum('ot', '«app.getLeadingEntity.name.formatForCode»');
            }
        «ENDIF»
        «IF app.isLegacy»
            $controllerHelper = new «app.appName»_Util_Controller($this->serviceManager);
        «ELSE»
            $controllerHelper = $this->get('«app.appService».controller_helper');
        «ENDIF»
        $utilArgs = «IF app.isLegacy»array(«ELSE»[«ENDIF»'controller' => '«formattedName»', 'action' => 'getItemListFinder'«IF app.isLegacy»)«ELSE»]«ENDIF»;
        if (!in_array($objectType, $controllerHelper->getObjectTypes('controllerAction', $utilArgs))) {
            $objectType = $controllerHelper->getDefaultObjectType('controllerAction', $utilArgs);
        }

        «IF app.isLegacy»
            $entityClass = '«app.appName»_Entity_' . ucfirst($objectType);
            $repository = $this->entityManager->getRepository($entityClass);
            $repository->setControllerArguments(array());
            $idFields = ModUtil::apiFunc($this->name, 'selection', 'getIdFields', array('ot' => $objectType));
        «ELSE»
            $repository = $this->get('«app.appService».' . $objectType . '_factory')->getRepository();
            $repository->setRequest($request);
            $selectionHelper = $this->get('«app.appService».selection_helper');
            $idFields = $selectionHelper->getIdFields($objectType);
        «ENDIF»

        $descriptionField = $repository->getDescriptionFieldName();

        «IF app.isLegacy»
            $sort = $this->request->request->filter('sort', '', FILTER_SANITIZE_STRING);
        «ELSE»
            $sort = $request->request->getAlnum('sort', '');
        «ENDIF»
        if (empty($sort) || !in_array($sort, $repository->getAllowedSortingFields())) {
            $sort = $repository->getDefaultSortingField();
        }

        «IF app.isLegacy»
            $sdir = $this->request->request->filter('sortdir', '', FILTER_SANITIZE_STRING);
        «ELSE»
            $sdir = $request->request->getAlpha('sortdir', '');
        «ENDIF»
        $sdir = strtolower($sdir);
        if ($sdir != 'asc' && $sdir != 'desc') {
            $sdir = 'asc';
        }

        $where = ''; // filters are processed inside the repository class
        $sortParam = $sort . ' ' . $sdir;

        $entities = $repository->selectWhere($where, $sortParam);

        $slimItems = «IF app.isLegacy»array()«ELSE»[]«ENDIF»;
        $component = $this->name . ':' . ucfirst($objectType) . ':';
        foreach ($entities as $item) {
            $itemId = '';
            foreach ($idFields as $idField) {
                $itemId .= ((!empty($itemId)) ? '_' : '') . $item[$idField];
            }
            if (!«IF app.isLegacy»SecurityUtil::check«ELSE»$this->has«ENDIF»Permission($component, $itemId . '::', ACCESS_READ)) {
                continue;
            }
            $slimItems[] = $this->prepareSlimItem($objectType, $item, $itemId, $descriptionField);
        }

        return new «IF app.isLegacy»Zikula_Response_Ajax«ELSE»AjaxResponse«ENDIF»($slimItems);
    '''

    def private getItemListFinderPrepareSlimItem(AjaxController it, Application app) '''
        /**
         * Builds and returns a slim data array from a given entity.
         *
         * @param string $objectType       The currently treated object type
         * @param object $item             The currently treated entity
         * @param string $itemid           Data item identifier(s)
         * @param string $descriptionField Name of item description field
         *
         * @return array The slim data representation
         */
        protected function prepareSlimItem($objectType, $item, $itemId, $descriptionField)
        {
            $view = Zikula_View::getInstance('«app.appName»', false);
            $view->assign($objectType, $item);
            $previewInfo = base64_encode($view->fetch(«IF app.isLegacy»'external/' . $objectType«ELSE»'External/' . ucfirst($objectType)«ENDIF» . '/info.tpl'));

            $title = $item->getTitleFromDisplayPattern();
            $description = ($descriptionField != '') ? $item[$descriptionField] : '';

            return «IF app.isLegacy»array(«ELSE»[«ENDIF»
                'id'          => $itemId,
                'title'       => str_replace('&amp;', '&', $title),
                'description' => $description,
                'previewInfo' => $previewInfo
            «IF app.isLegacy»)«ELSE»]«ENDIF»;
        }
    '''

    def private getItemListAutoCompletionBase(AjaxController it, Application app) '''
        «getItemListAutoCompletionDocBlock(true)»
        «getItemListAutoCompletionSignature»
        {
            «getItemListAutoCompletionBaseImpl(app)»
        }
    '''

    def private getItemListAutoCompletionDocBlock(AjaxController it, Boolean isBase) '''
        /**
         * Searches for entities for auto completion usage.
        «IF !application.isLegacy && !isBase»
        «' '»*
        «' '»* @Route("/getItemListAutoCompletion", options={"expose"=true})
        «/*' '»* @Method("POST")*/»
        «ENDIF»
         *
        «IF application.isLegacy»
            «' '»* @param string $ot       Treated object type
            «' '»* @param string $fragment The fragment of the entered item name
            «' '»* @param string $exclude  Comma separated list with ids of other items (to be excluded from search)
        «ELSE»
            «' '»* @param Request $request Current request instance
        «ENDIF»
         *
         * @return «IF application.isLegacy»Zikula_Response_Ajax_Plain«ELSE»JsonResponse«ENDIF»
         */
    '''

    def private getItemListAutoCompletionSignature(AjaxController it) '''
        public function getItemListAutoCompletion«IF application.isLegacy»()«ELSE»Action(Request $request)«ENDIF»
    '''

    def private getItemListAutoCompletionBaseImpl(AjaxController it, Application app) '''
        if (!«IF app.isLegacy»SecurityUtil::check«ELSE»$this->has«ENDIF»Permission($this->name . '::Ajax', '::', ACCESS_EDIT)) {
            return true;
        }

        $objectType = '«app.getLeadingEntity.name.formatForCode»';
        «IF app.isLegacy»
            if ($this->request->isPost() && $this->request->request->has('ot')) {
                $objectType = $this->request->request->filter('ot', '«app.getLeadingEntity.name.formatForCode»', FILTER_SANITIZE_STRING);
            } elseif ($this->request->isGet() && $this->request->query->has('ot')) {
                $objectType = $this->request->query->filter('ot', '«app.getLeadingEntity.name.formatForCode»', FILTER_SANITIZE_STRING);
            }
        «ELSE»
            if ($request->isMethod('POST') && $request->request->has('ot')) {
                $objectType = $request->request->getAlnum('ot', '«app.getLeadingEntity.name.formatForCode»');
            } elseif ($request->isMethod('GET') && $request->query->has('ot')) {
                $objectType = $request->query->getAlnum('ot', '«app.getLeadingEntity.name.formatForCode»');
            }
        «ENDIF»
        «IF app.isLegacy»
            $controllerHelper = new «app.appName»_Util_Controller($this->serviceManager);
        «ELSE»
            $controllerHelper = $this->get('«app.appService».controller_helper');
        «ENDIF»
        $utilArgs = «IF app.isLegacy»array(«ELSE»[«ENDIF»'controller' => '«formattedName»', 'action' => 'getItemListAutoCompletion'«IF app.isLegacy»)«ELSE»]«ENDIF»;
        if (!in_array($objectType, $controllerHelper->getObjectTypes('controllerAction', $utilArgs))) {
            $objectType = $controllerHelper->getDefaultObjectType('controllerAction', $utilArgs);
        }

        «IF app.isLegacy»
            $entityClass = '«app.appName»_Entity_' . ucfirst($objectType);
            $repository = $this->entityManager->getRepository($entityClass);
            $idFields = ModUtil::apiFunc($this->name, 'selection', 'getIdFields', array('ot' => $objectType));
        «ELSE»
            $repository = $this->get('«app.appService».' . $objectType . '_factory')->getRepository();
            $selectionHelper = $this->get('«app.appService».selection_helper');
            $idFields = $selectionHelper->getIdFields($objectType);
        «ENDIF»

        $fragment = '';
        $exclude = '';
        if ($«IF app.isLegacy»this->«ENDIF»request->«IF app.isLegacy»isPost()«ELSE»isMethod('POST')«ENDIF» && $«IF app.isLegacy»this->«ENDIF»request->request->has('fragment')) {
            $fragment = $«IF app.isLegacy»this->«ENDIF»request->request->get('fragment', '');
            $exclude = $«IF app.isLegacy»this->«ENDIF»request->request->get('exclude', '');
        } elseif ($«IF app.isLegacy»this->«ENDIF»request->«IF app.isLegacy»isGet()«ELSE»isMethod('GET')«ENDIF» && $«IF app.isLegacy»this->«ENDIF»request->query->has('fragment')) {
            $fragment = $«IF app.isLegacy»this->«ENDIF»request->query->get('fragment', '');
            $exclude = $«IF app.isLegacy»this->«ENDIF»request->query->get('exclude', '');
        }
        $exclude = !empty($exclude) ? explode(',', $exclude) : «IF app.isLegacy»array()«ELSE»[]«ENDIF»;

        // parameter for used sorting field
        $sort = $«IF app.isLegacy»this->«ENDIF»request->query->get('sort', '');
        «new ControllerHelperFunctions().defaultSorting(it, app)»
        $sortParam = $sort . ' asc';

        $currentPage = 1;
        $resultsPerPage = 20;

        // get objects from database
        list($entities, $objectCount) = $repository->selectSearch($fragment, $exclude, $sortParam, $currentPage, $resultsPerPage);

        «IF app.isLegacy»
            $out = '<ul>';
            if ((is_array($entities) || is_object($entities)) && count($entities) > 0) {
                «prepareForAutoCompletionProcessing(app)»
                foreach ($entities as $item) {
                    // class="informal" --> show in dropdown, but do nots copy in the input field after selection
                    $itemTitle = $item->getTitleFromDisplayPattern();
                    $itemTitleStripped = str_replace('"', '', $itemTitle);
                    $itemDescription = isset($item[$descriptionFieldName]) && !empty($item[$descriptionFieldName]) ? $item[$descriptionFieldName] : '';//$this->__('No description yet.');
                    $itemId = $item->createCompositeIdentifier();

                    $out .= '<li id="' . $itemId . '" title="' . $itemTitleStripped . '">';
                    $out .= '<div class="itemtitle">' . $itemTitle . '</div>';
                    if (!empty($itemDescription)) {
                        $out .= '<div class="itemdesc informal">' . substr($itemDescription, 0, 50) . '&hellip;</div>';
                    }
                    «IF app.hasImageFields»

                        // check for preview image
                        if (!empty($previewFieldName) && !empty($item[$previewFieldName]) && isset($item[$previewFieldName . 'FullPath'])) {
                            $fullObjectId = $objectType . '-' . $itemId;
                            $thumbImagePath = $imagineManager->getThumb($item[$previewFieldName], $fullObjectId);
                            $preview = '<img src="' . $thumbImagePath . '" width="50" height="50" alt="' . $itemTitleStripped . '" />';
                            $out .= '<div id="itemPreview' . $itemId . '" class="itempreview informal">' . $preview . '</div>';
                        }
                    «ENDIF»

                    $out .= '</li>';
                }
            }
            $out .= '</ul>';

            // return response
            return new «IF app.isLegacy»Zikula_Response_Ajax_Plain«ELSE»PlainResponse«ENDIF»($out);
        «ELSE»
            $resultItems = [];

            if ((is_array($entities) || is_object($entities)) && count($entities) > 0) {
                «prepareForAutoCompletionProcessing(app)»
                foreach ($entities as $item) {
                    $itemTitle = $item->getTitleFromDisplayPattern();
                    $itemTitleStripped = str_replace('"', '', $itemTitle);
                    $itemDescription = isset($item[$descriptionFieldName]) && !empty($item[$descriptionFieldName]) ? $item[$descriptionFieldName] : '';//$this->__('No description yet.')
                    if (!empty($itemDescription)) {
                        $itemDescription = substr($itemDescription, 0, 50) . '&hellip;';
                    }

                    $resultItem = [
                        'id' => $item->createCompositeIdentifier(),
                        'title' => $item->getTitleFromDisplayPattern(),
                        'description' => $itemDescription,
                        'image' => ''
                    ];
                    «IF app.hasImageFields»

                        // check for preview image
                        if (!empty($previewFieldName) && !empty($item[$previewFieldName]) && isset($item[$previewFieldName . 'FullPath'])) {
                            $fullObjectId = $objectType . '-' . $resultItem['id'];
                            $thumbImagePath = $imagineManager->getThumb($item[$previewFieldName], $fullObjectId);
                            $preview = '<img src="' . $thumbImagePath . '" width="50" height="50" alt="' . $itemTitleStripped . '" />';
                            $resultItem['image'] = $preview;
                        }
                    «ENDIF»

                    $resultItems[] = $resultItem;
                }
            }

            return new JsonResponse($resultItems);
        «ENDIF»
    '''

    def private prepareForAutoCompletionProcessing(AjaxController it, Application app) '''
        $descriptionFieldName = $repository->getDescriptionFieldName();
        $previewFieldName = $repository->getPreviewFieldName();
        «IF app.hasImageFields»
            «/* TODO use custom image helper instead of pure imagine plugin */»
            «IF app.isLegacy»
                //$imageHelper = new «app.appName»_Util_Image($this->serviceManager);
                //$imagineManager = $imageHelper->getManager($objectType, $previewFieldName, 'controllerAction', $utilArgs);
                $imagineManager = ServiceUtil::getManager()->getService('systemplugin.imagine.manager');
            «ELSE»
                //$imageHelper = $this->get('«app.appService».image_helper');
                //$imagineManager = $imageHelper->getManager($objectType, $previewFieldName, 'controllerAction', $utilArgs);
                $imagineManager = $this->get('systemplugin.imagine.manager');
            «ENDIF»
        «ENDIF»
    '''

    def private checkForDuplicateBase(AjaxController it, Application app) '''
        «checkForDuplicateDocBlock(true)»
        «checkForDuplicateSignature»
        {
            «checkForDuplicateBaseImpl(app)»
        }
    '''

    def private checkForDuplicateDocBlock(AjaxController it, Boolean isBase) '''
        /**
         * Checks whether a field value is a duplicate or not.
        «IF !application.isLegacy && !isBase»
        «' '»*
        «' '»* @Route("/checkForDuplicate", options={"expose"=true})
        «' '»* @Method("POST")
        «ENDIF»
         *
        «IF application.isLegacy»
            «' '»* @param string $ot Treated object type
            «' '»* @param string $fn Name of field to be checked
            «' '»* @param string $v  The value to be checked for uniqueness
            «' '»* @param string $ex Optional identifier to be excluded from search
        «ELSE»
            «' '»* @param Request $request Current request instance
        «ENDIF»
         *
         * @return «IF application.isLegacy»Zikula_Response_Ajax«ELSE»AjaxResponse«ENDIF»
         «IF !application.isLegacy»
         *
         * @throws AccessDeniedException Thrown if the user doesn't have required permissions
         «ENDIF»
         */
    '''

    def private checkForDuplicateSignature(AjaxController it) '''
        public function checkForDuplicate«IF application.isLegacy»()«ELSE»Action(Request $request)«ENDIF»
    '''

    def private checkForDuplicateBaseImpl(AjaxController it, Application app) '''
        $this->checkAjaxToken();
        «IF app.isLegacy»
            $this->throwForbiddenUnless(SecurityUtil::checkPermission($this->name . '::Ajax', '::', ACCESS_EDIT));
        «ELSE»
            if (!$this->hasPermission($this->name . '::Ajax', '::', ACCESS_EDIT)) {
                throw new AccessDeniedException();
            }
        «ENDIF»

        «prepareDuplicateCheckParameters(app)»
        «IF app.isLegacy»
            $entityClass = '«app.appName»_Entity_' . ucfirst($objectType);
            /* can probably be removed
             * $object = new $entityClass();
             */ 
        «ELSE»
            /* can probably be removed
             * $createMethod = 'create' . ucfirst($objectType);
             * $object = $this->get('«app.name.formatForDB».' . $objectType . '_factory')->$createMethod();
             */
        «ENDIF»

        $result = false;
        switch ($objectType) {
        «FOR entity : app.getAllEntities»
            «val uniqueFields = entity.getUniqueDerivedFields.filter[!primaryKey]»
            «IF !uniqueFields.empty || (entity.hasSluggableFields && entity.slugUnique)»
                case '«entity.name.formatForCode»':
                    «IF app.isLegacy»
                        $repository = $this->entityManager->getRepository($entityClass);
                    «ELSE»
                        $repository = $this->get('«app.appService».' . $objectType . '_factory')->getRepository();
                    «ENDIF»
                    switch ($fieldName) {
                    «FOR uniqueField : uniqueFields»
                        case '«uniqueField.name.formatForCode»':
                                $result = $repository->detectUniqueState('«uniqueField.name.formatForCode»', $value, $exclude«IF !application.entities.filter[hasCompositeKeys].empty»[0]«ENDIF»);
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
        $result = «IF app.isLegacy»array(«ELSE»[«ENDIF»'isDuplicate' => $result«IF app.isLegacy»)«ELSE»]«ENDIF»;

        return new «IF app.isLegacy»Zikula_Response_Ajax«ELSE»AjaxResponse«ENDIF»($result);
    '''

    def private prepareDuplicateCheckParameters(AjaxController it, Application app) '''
        $postData = $«IF app.isLegacy»this->«ENDIF»request->request;

        «IF app.isLegacy»
            $objectType = $postData->filter('ot', '«app.getLeadingEntity.name.formatForCode»', FILTER_SANITIZE_STRING);
            $controllerHelper = new «app.appName»_Util_Controller($this->serviceManager);
        «ELSE»
            $objectType = $postData->getAlnum('ot', '«app.getLeadingEntity.name.formatForCode»');
            $controllerHelper = $this->get('«app.appService».controller_helper');
        «ENDIF»
        $utilArgs = «IF app.isLegacy»array(«ELSE»[«ENDIF»'controller' => '«formattedName»', 'action' => 'checkForDuplicate'«IF app.isLegacy»)«ELSE»]«ENDIF»;
        if (!in_array($objectType, $controllerHelper->getObjectTypes('controllerAction', $utilArgs))) {
            $objectType = $controllerHelper->getDefaultObjectType('controllerAction', $utilArgs);
        }

        «IF app.isLegacy»
            $fieldName = $postData->filter('fn', '', FILTER_SANITIZE_STRING);
        «ELSE»
            $fieldName = $postData->getAlnum('fn', '');
        «ENDIF»
        $value = $postData->get('v', '');

        if (empty($fieldName) || empty($value)) {
            return new «IF app.isLegacy»Zikula_Response_Ajax_BadData«ELSE»BadDataResponse«ENDIF»($this->__('Error: invalid input.'));
        }

        // check if the given field is existing and unique
        $uniqueFields = «IF app.isLegacy»array()«ELSE»[]«ENDIF»;
        switch ($objectType) {
            «FOR entity : app.getAllEntities»
                «val uniqueFields = entity.getUniqueDerivedFields.filter[!primaryKey]»
                «IF !uniqueFields.empty || (entity.hasSluggableFields && entity.slugUnique)»
                    case '«entity.name.formatForCode»':
                            $uniqueFields = «IF app.isLegacy»array(«ELSE»[«ENDIF»«FOR uniqueField : uniqueFields SEPARATOR ', '»'«uniqueField.name.formatForCode»'«ENDFOR»«IF entity.hasSluggableFields && entity.slugUnique»«IF !uniqueFields.empty», «ENDIF»'slug'«ENDIF»«IF app.isLegacy»)«ELSE»]«ENDIF»;
                            break;
                «ENDIF»
            «ENDFOR»
        }
        if (!count($uniqueFields) || !in_array($fieldName, $uniqueFields)) {
            return new «IF app.isLegacy»Zikula_Response_Ajax_BadData«ELSE»BadDataResponse«ENDIF»($this->__('Error: invalid input.'));
        }

        $exclude = $postData->get('ex', '');
        «IF !application.entities.filter[hasCompositeKeys].empty»
            if (strpos($exclude, '_') !== false) {
                $exclude = explode('_', $exclude);
            }
        «ENDIF» 
    '''

    def private toggleFlagBase(AjaxController it, Application app) '''
        «toggleFlagDocBlock(true)»
        «toggleFlagSignature»
        {
            «toggleFlagBaseImpl(app)»
        }
    '''

    def private toggleFlagDocBlock(AjaxController it, Boolean isBase) '''
        /**
         * Changes a given flag (boolean field) by switching between true and false.
        «IF !application.isLegacy && !isBase»
        «' '»*
        «' '»* @Route("/toggleFlag", options={"expose"=true})
        «' '»* @Method("POST")
        «ENDIF»
         *
        «IF application.isLegacy»
            «' '»* @param string $ot    Treated object type
            «' '»* @param string $field The field to be toggled
            «' '»* @param int    $id    Identifier of treated entity
        «ELSE»
            «' '»* @param Request $request Current request instance
        «ENDIF»
         *
         * @return «IF application.isLegacy»Zikula_Response_Ajax«ELSE»AjaxResponse«ENDIF»
         «IF !application.isLegacy»
         *
         * @throws AccessDeniedException Thrown if the user doesn't have required permissions
         «ENDIF»
         */
    '''

    def private toggleFlagSignature(AjaxController it) '''
        public function toggleFlag«IF application.isLegacy»()«ELSE»Action(Request $request)«ENDIF»
    '''

    def private toggleFlagBaseImpl(AjaxController it, Application app) '''
        «IF app.isLegacy»
            $this->throwForbiddenUnless(SecurityUtil::checkPermission($this->name . '::Ajax', '::', ACCESS_EDIT));
        «ELSE»
            if (!$this->hasPermission($this->name . '::Ajax', '::', ACCESS_EDIT)) {
                throw new AccessDeniedException();
            }
        «ENDIF»

        $postData = $«IF app.isLegacy»this->«ENDIF»request->request;

        «IF app.isLegacy»
            $objectType = $postData->filter('ot', '«app.getLeadingEntity.name.formatForCode»', FILTER_SANITIZE_STRING);
            $field = $postData->filter('field', '', FILTER_SANITIZE_STRING);
            $id = (int) $postData->filter('id', 0, FILTER_VALIDATE_INT);
        «ELSE»
            $objectType = $postData->getAlnum('ot', '«app.getLeadingEntity.name.formatForCode»');
            $field = $postData->getAlnum('field', '');
            $id = $postData->getInt('id', 0);
        «ENDIF»

        «val entities = app.getEntitiesWithAjaxToggle»
        if ($id == 0
            || («FOR entity : entities SEPARATOR ' && '»$objectType != '«entity.name.formatForCode»'«ENDFOR»)
        «FOR entity : entities»
            || ($objectType == '«entity.name.formatForCode»' && !in_array($field, «IF app.isLegacy»array(«ELSE»[«ENDIF»«FOR field : entity.getBooleansWithAjaxToggleEntity SEPARATOR ', '»'«field.name.formatForCode»'«ENDFOR»«IF app.isLegacy»)«ELSE»]«ENDIF»))
        «ENDFOR»
        ) {
            return new «IF app.isLegacy»Zikula_Response_Ajax_BadData«ELSE»BadDataResponse«ENDIF»($this->__('Error: invalid input.'));
        }

        // select data from data source
        «IF app.isLegacy»
            $entity = ModUtil::apiFunc($this->name, 'selection', 'getEntity', array('ot' => $objectType, 'id' => $id));
        «ELSE»
            $selectionHelper = $this->get('«app.appService».selection_helper');
            $entity = $selectionHelper->getEntity($objectType, $id);
        «ENDIF»
        if (null === $entity) {
            return new «IF app.isLegacy»Zikula_Response_Ajax_NotFound«ELSE»NotFoundResponse«ENDIF»($this->__('No such item.'));
        }

        // toggle the flag
        $entity[$field] = !$entity[$field];

        // save entity back to database
        «IF app.isLegacy»
            $this->entityManager->flush();
        «ELSE»
            $entityManager = $this->get('doctrine.entitymanager');
            $entityManager->flush();
        «ENDIF»

        // return response
        $result = «IF app.isLegacy»array(«ELSE»[«ENDIF»
            'id' => $id,
            'state' => $entity[$field]
        «IF app.isLegacy»)«ELSE»]«ENDIF»;
        «IF !app.isLegacy»

            $logger = $this->get('logger');
            $logArgs = ['app' => '«app.appName»', 'user' => $this->get('zikula_users_module.current_user')->get('uname'), 'field' => $field, 'entity' => $objectType, 'id' => $id];
            $logger->notice('{app}: User {user} toggled the {field} flag the {entity} with id {id}.', $logArgs);
        «ENDIF»

        return new «IF app.isLegacy»Zikula_Response_Ajax«ELSE»AjaxResponse«ENDIF»($result);
    '''

    def private handleTreeOperationBase(AjaxController it, Application app) '''
        «handleTreeOperationDocBlock(true)»
        «handleTreeOperationSignature»
        {
            «handleTreeOperationBaseImpl(app)»
        }
    '''

    def private handleTreeOperationDocBlock(AjaxController it, Boolean isBase) '''
        /**
         * Performs different operations on tree hierarchies.
        «IF !application.isLegacy && !isBase»
        «' '»*
        «' '»* @Route("/handleTreeOperation", options={"expose"=true})
        «' '»* @Method("POST")
        «ENDIF»
         *
         * @param string $ot        Treated object type
         * @param string $op        The operation which should be performed (addRootNode, addChildNode, deleteNode, moveNode, moveNodeTo)
         * @param int    $id        Identifier of treated node (not for addRootNode and addChildNode)
         * @param int    $pid       Identifier of parent node (only for addChildNode)
         * @param string $direction The target direction for a move action (only for moveNode [up, down] and moveNodeTo [after, before, bottom])
         * @param int    $destid    Identifier of destination node for (only for moveNodeTo)
         *
         * @return «IF application.isLegacy»Zikula_Response_Ajax«ELSE»AjaxResponse«ENDIF»
         *
         «IF !application.isLegacy»
         * @throws AccessDeniedException Thrown if the user doesn't have required permissions
         «ENDIF»
         * @throws «IF application.isLegacy»Zikula_Exception_Ajax_Fatal«ELSE»FatalResponse«ENDIF»
         «IF !application.isLegacy»
         * @throws RuntimeException Thrown if tree verification or executing the workflow action fails
         «ENDIF»
         */
    '''

    def private handleTreeOperationSignature(AjaxController it) '''
        public function handleTreeOperation«IF application.isLegacy»()«ELSE»Action(Request $request)«ENDIF»
    '''

    def private handleTreeOperationBaseImpl(AjaxController it, Application app) '''
        «IF app.isLegacy»
            $this->throwForbiddenUnless(SecurityUtil::checkPermission($this->name . '::Ajax', '::', ACCESS_EDIT));
        «ELSE»
            if (!$this->hasPermission($this->name . '::Ajax', '::', ACCESS_EDIT)) {
                throw new AccessDeniedException();
            }
        «ENDIF»

        $postData = $«IF app.isLegacy»this->«ENDIF»request->request;

        «val treeEntities = app.getTreeEntities»
        // parameter specifying which type of objects we are treating
        «IF app.isLegacy»
            $objectType = $postData->filter('ot', '«treeEntities.head.name.formatForCode»', FILTER_SANITIZE_STRING);
        «ELSE»
            $objectType = $postData->getAlnum('ot', '«treeEntities.head.name.formatForCode»');
        «ENDIF»
        // ensure that we use only object types with tree extension enabled
        if (!in_array($objectType, «IF app.isLegacy»array(«ELSE»[«ENDIF»«FOR treeEntity : treeEntities SEPARATOR ", "»'«treeEntity.name.formatForCode»'«ENDFOR»«IF app.isLegacy»)«ELSE»]«ENDIF»)) {
            $objectType = '«treeEntities.head.name.formatForCode»';
        }

        «prepareTreeOperationParameters(app)»

        $returnValue = «IF app.isLegacy»array(«ELSE»[«ENDIF»
            'data'    => «IF app.isLegacy»array()«ELSE»[]«ENDIF»,
            'message' => ''
        «IF app.isLegacy»)«ELSE»]«ENDIF»;

        «IF app.isLegacy»
            $entityClass = '«app.appName»_Entity_' . ucfirst($objectType);
            $repository = $this->entityManager->getRepository($entityClass);
        «ELSE»
            $createMethod = 'create' . ucfirst($objectType);
            $repository = $this->get('«app.appService».' . $objectType . '_factory')->getRepository();
        «ENDIF»

        $rootId = 1;
        if (!in_array($op, «IF app.isLegacy»array(«ELSE»[«ENDIF»'addRootNode'«IF app.isLegacy»)«ELSE»]«ENDIF»)) {
            «IF app.isLegacy»
                $rootId = (int) $postData->filter('root', 0, FILTER_VALIDATE_INT);
            «ELSE»
                $rootId = $postData->getInt('root', 0);
            «ENDIF»
            if (!$rootId) {
                throw new «IF app.isLegacy»Zikula_Exception_Ajax_Fatal«ELSE»FatalResponse«ENDIF»($this->__('Error: invalid root node.'));
            }
        }

        «IF !app.isLegacy»
            $selectionHelper = $this->get('«app.appService».selection_helper');

        «ENDIF»
        // Select tree
        $tree = null;
        if (!in_array($op, «IF app.isLegacy»array(«ELSE»[«ENDIF»'addRootNode'«IF app.isLegacy»)«ELSE»]«ENDIF»)) {
            «IF app.isLegacy»
                $tree = ModUtil::apiFunc($this->name, 'selection', 'getTree', array('ot' => $objectType, 'rootId' => $rootId));
            «ELSE»
                $tree = $selectionHelper->getTree($objectType, $rootId);
            «ENDIF»
        }

        // verification and recovery of tree
        $verificationResult = $repository->verify();
        if (is_array($verificationResult)) {
            foreach ($verificationResult as $errorMsg) {
                «IF app.isLegacy»LogUtil::registerError«ELSE»throw new \RuntimeException«ENDIF»($errorMsg);
            }
        }
        $repository->recover();
        $this->entityManager->clear(); // clear cached nodes

        «treeOperationDetermineEntityFields(app)»

        «treeOperationSwitch(app)»

        $returnValue['message'] = $this->__('The operation was successful.');

        // Renew tree
        /** postponed, for now we do a page reload
        «IF app.isLegacy»
            $returnValue['data'] = ModUtil::apiFunc($this->name, 'selection', 'getTree', array('ot' => $objectType, 'rootId' => $rootId));
        «ELSE»
            $returnValue['data'] = $selectionHelper->getTree($objectType, $rootId);
        «ENDIF»
        */

        return new «IF app.isLegacy»Zikula_Response_Ajax«ELSE»AjaxResponse«ENDIF»($returnValue);
    '''

    def private prepareTreeOperationParameters(AjaxController it, Application app) '''
        «IF app.isLegacy»
            $op = $postData->filter('op', '', FILTER_SANITIZE_STRING);
        «ELSE»
            $op = $postData->getAlpha('op', '');
        «ENDIF»
        if (!in_array($op, «IF app.isLegacy»array(«ELSE»[«ENDIF»'addRootNode', 'addChildNode', 'deleteNode', 'moveNode', 'moveNodeTo'«IF app.isLegacy»)«ELSE»]«ENDIF»)) {
            throw new «IF app.isLegacy»Zikula_Exception_Ajax_Fatal«ELSE»FatalResponse«ENDIF»($this->__('Error: invalid operation.'));
        }

        // Get id of treated node
        $id = 0;
        if (!in_array($op, «IF app.isLegacy»array(«ELSE»[«ENDIF»'addRootNode', 'addChildNode'«IF app.isLegacy»)«ELSE»]«ENDIF»)) {
            «IF app.isLegacy»
                $id = (int) $postData->filter('id', 0, FILTER_VALIDATE_INT);
            «ELSE»
                $id = $postData->getInt('id', 0);
            «ENDIF»
            if (!$id) {
                throw new «IF app.isLegacy»Zikula_Exception_Ajax_Fatal«ELSE»FatalResponse«ENDIF»($this->__('Error: invalid node.'));
            }
        }
    '''

    def private treeOperationDetermineEntityFields(AjaxController it, Application app) '''
        $titleFieldName = $descriptionFieldName = '';

        switch ($objectType) {
            «FOR entity : app.getTreeEntities»
                case '«entity.name.formatForCode»':
                    «val stringFields = entity.fields.filter(StringField).filter[length >= 20 && !nospace && !country && !htmlcolour && !language && !locale]»
                        $titleFieldName = '«IF !stringFields.empty»«stringFields.head.name.formatForCode»«ENDIF»';
                        «val textFields = entity.fields.filter(TextField).filter[mandatory && length >= 50]»
                        «IF !textFields.empty»
                            $descriptionFieldName = '«textFields.head.name.formatForCode»';
                        «ELSE»
                            «val textStringFields = entity.fields.filter(StringField).filter[mandatory && length >= 50 && !nospace && !country && !htmlcolour && !language && !locale]»
                            «IF !textStringFields.empty»
                                $descriptionFieldName = '«textStringFields.head.name.formatForCode»';
                            «ENDIF»
                        «ENDIF»
                        break;
            «ENDFOR»
        }
    '''

    def private treeOperationSwitch(AjaxController it, Application app) '''
        «IF !app.isLegacy»
            $logger = $this->get('logger');
            $logArgs = ['app' => '«app.appName»', 'user' => $this->get('zikula_users_module.current_user')->get('uname'), 'entity' => $objectType];
            $selectionHelper = $this->get('«app.appService».selection_helper');

        «ENDIF»
        switch ($op) {
            case 'addRootNode':
                            «treeOperationAddRootNode(app)»
                            «IF !app.isLegacy»

                                $logger->notice('{app}: User {user} added a new root node in the {entity} tree.', $logArgs);
                            «ENDIF»

                            break;
            case 'addChildNode':
                            «treeOperationAddChildNode(app)»
                            «IF !app.isLegacy»

                                $logger->notice('{app}: User {user} added a new child node in the {entity} tree.', $logArgs);
                            «ENDIF»
                            break;
            case 'deleteNode':
                            «treeOperationDeleteNode(app)»
                            «IF !app.isLegacy»

                                $logger->notice('{app}: User {user} deleted a node from the {entity} tree.', $logArgs);
                            «ENDIF»

                            break;
            case 'moveNode':
                            «treeOperationMoveNode(app)»
                            «IF !app.isLegacy»

                                $logger->notice('{app}: User {user} moved a node in the {entity} tree.', $logArgs);
                            «ENDIF»

                            break;
            case 'moveNodeTo':
                            «treeOperationMoveNodeTo(app)»
                            «IF !app.isLegacy»

                                $logger->notice('{app}: User {user} moved a node in the {entity} tree.', $logArgs);
                            «ENDIF»

                            break;
        }
    '''

    def private treeOperationAddRootNode(AjaxController it, Application app) '''
        //$this->entityManager->transactional(function($entityManager) {
            «IF app.isLegacy»
                $entity = new $entityClass();
            «ELSE»
                $entity = $this->get('«app.name.formatForDB».' . $objectType . '_factory')->$createMethod();
            «ENDIF»
            $entityData = «IF app.isLegacy»array()«ELSE»[]«ENDIF»;
            if (!empty($titleFieldName)) {
                $entityData[$titleFieldName] = $this->__('New root node');
            }
            if (!empty($descriptionFieldName)) {
                $entityData[$descriptionFieldName] = $this->__('This is a new root node');
            }
            $entity->merge($entityData);
            «/*IF hasTranslatableFields»
                $entity->setLocale(«IF app.isLegacy»ZLanguage::getLanguageCode()«ELSE»$request->getLocale()«ENDIF»);
            «ENDIF*/»

            // save new object to set the root id
            $action = 'submit';
            try {
                if ($entity->validate()) {
                    // execute the workflow action
                    «IF app.isLegacy»
                        $workflowHelper = new «app.appName»_Util_Workflow($this->serviceManager);
                    «ELSE»
                        $workflowHelper = $this->get('«app.appService».workflow_helper');
                    «ENDIF»
                    $success = $workflowHelper->executeAction($entity, $action);
                }
            } catch(\Exception $e) {
                «IF app.isLegacy»LogUtil::registerError«ELSE»throw new \RuntimeException«ENDIF»($this->__f('Sorry, but an unknown error occured during the %s action. Please apply the changes again!', «IF app.isLegacy»array($action)«ELSE»['%s' => $action]«ENDIF»));
            }
        //});
    '''

    def private treeOperationAddChildNode(AjaxController it, Application app) '''
        «IF app.isLegacy»
            $parentId = (int) $postData->filter('pid', 0, FILTER_VALIDATE_INT);
        «ELSE»
            $parentId = $postData->getInt('pid', 0);
        «ENDIF»
        if (!$parentId) {
            throw new «IF app.isLegacy»Zikula_Exception_Ajax_Fatal«ELSE»FatalResponse«ENDIF»($this->__('Error: invalid parent node.'));
        }

        //$this->entityManager->transactional(function($entityManager) {
            «IF app.isLegacy»
                $childEntity = new $entityClass();
            «ELSE»
                $childEntity = $this->get('«app.name.formatForDB».' . $objectType . '_factory')->$createMethod();
            «ENDIF»
            $entityData = «IF app.isLegacy»array()«ELSE»[]«ENDIF»;
            $entityData[$titleFieldName] = $this->__('New child node');
            if (!empty($descriptionFieldName)) {
                $entityData[$descriptionFieldName] = $this->__('This is a new child node');
            }
            $childEntity->merge($entityData);

            // save new object
            $action = 'submit';
            try {
                if ($childEntity->validate()) {
                    // execute the workflow action
                    «IF app.isLegacy»
                        $workflowHelper = new «app.appName»_Util_Workflow($this->serviceManager);
                    «ELSE»
                        $workflowHelper = $this->get('«app.appService».workflow_helper');
                    «ENDIF»
                    $success = $workflowHelper->executeAction($childEntity, $action);
                }
            } catch(\Exception $e) {
                «IF app.isLegacy»LogUtil::registerError«ELSE»throw new \RuntimeException«ENDIF»($this->__f('Sorry, but an unknown error occured during the %s action. Please apply the changes again!', «IF app.isLegacy»array($action)«ELSE»['%s' => $action]«ENDIF»));
            }

            //$childEntity->setParent($parentEntity);
            «IF app.isLegacy»
                $parentEntity = ModUtil::apiFunc($this->name, 'selection', 'getEntity', array('ot' => $objectType, 'id' => $parentId, 'useJoins' => false));
            «ELSE»
                $parentEntity = $selectionHelper->getEntity($objectType, $parentId«IF app.hasSluggable», ''«ENDIF», false);
            «ENDIF»
            if (null === $parentEntity) {
                return new «IF app.isLegacy»Zikula_Response_Ajax_NotFound«ELSE»NotFoundResponse«ENDIF»($this->__('No such item.'));
            }
            $repository->persistAsLastChildOf($childEntity, $parentEntity);
        //});
        $this->entityManager->flush();
    '''

    def private treeOperationDeleteNode(AjaxController it, Application app) '''
        // remove node from tree and reparent all children
        «IF app.isLegacy»
            $entity = ModUtil::apiFunc($this->name, 'selection', 'getEntity', array('ot' => $objectType, 'id' => $id, 'useJoins' => false));
        «ELSE»
            $entity = $selectionHelper->getEntity($objectType, $id«IF app.hasSluggable», ''«ENDIF», false);
        «ENDIF»
        if (null === $entity) {
            return new «IF app.isLegacy»Zikula_Response_Ajax_NotFound«ELSE»NotFoundResponse«ENDIF»($this->__('No such item.'));
        }

        $entity->initWorkflow();

        // delete the object
        $action = 'delete';
        try {
            if ($entity->validate()) {
                // execute the workflow action
                «IF app.isLegacy»
                    $workflowHelper = new «app.appName»_Util_Workflow($this->serviceManager);
                «ELSE»
                    $workflowHelper = $this->get('«app.appService».workflow_helper');
                «ENDIF»
                $success = $workflowHelper->executeAction($entity, $action);
            }
        } catch(\Exception $e) {
            «IF app.isLegacy»LogUtil::registerError«ELSE»throw new \RuntimeException«ENDIF»($this->__f('Sorry, but an unknown error occured during the %s action. Please apply the changes again!', «IF app.isLegacy»array($action)«ELSE»['%s' => $action]«ENDIF»));
        }

        $repository->removeFromTree($entity);
        $this->entityManager->clear(); // clear cached nodes
    '''

    def private treeOperationMoveNode(AjaxController it, Application app) '''
        «IF app.isLegacy»
            $moveDirection = $postData->filter('direction', '', FILTER_SANITIZE_STRING);
        «ELSE»
            $moveDirection = $postData->getAlpha('direction', '');
        «ENDIF»
        if (!in_array($moveDirection, «IF app.isLegacy»array(«ELSE»[«ENDIF»'up', 'down'«IF app.isLegacy»)«ELSE»]«ENDIF»)) {
            throw new «IF app.isLegacy»Zikula_Exception_Ajax_Fatal«ELSE»FatalResponse«ENDIF»($this->__('Error: invalid direction.'));
        }

        «IF app.isLegacy»
            $entity = ModUtil::apiFunc($this->name, 'selection', 'getEntity', array('ot' => $objectType, 'id' => $id, 'useJoins' => false));
        «ELSE»
            $entity = $selectionHelper->getEntity($objectType, $id«IF app.hasSluggable», ''«ENDIF», false);
        «ENDIF»
        if (null === $entity) {
            return new «IF app.isLegacy»Zikula_Response_Ajax_NotFound«ELSE»NotFoundResponse«ENDIF»($this->__('No such item.'));
        }

        if ($moveDirection == 'up') {
            $repository->moveUp($entity, 1);
        } else if ($moveDirection == 'down') {
            $repository->moveDown($entity, 1);
        }
        $this->entityManager->flush();
    '''

    def private treeOperationMoveNodeTo(AjaxController it, Application app) '''
        «IF app.isLegacy»
            $moveDirection = $postData->filter('direction', '', FILTER_SANITIZE_STRING);
        «ELSE»
            $moveDirection = $postData->getAlpha('direction', '');
        «ENDIF»
        if (!in_array($moveDirection, «IF app.isLegacy»array(«ELSE»[«ENDIF»'after', 'before', 'bottom'«IF app.isLegacy»)«ELSE»]«ENDIF»)) {
            throw new «IF app.isLegacy»Zikula_Exception_Ajax_Fatal«ELSE»FatalResponse«ENDIF»($this->__('Error: invalid direction.'));
        }

        «IF app.isLegacy»
            $destId = (int) $postData->filter('destid', 0, FILTER_VALIDATE_INT);
        «ELSE»
            $destId = $postData->getInt('destid', 0);
        «ENDIF»
        if (!$destId) {
            throw new «IF app.isLegacy»Zikula_Exception_Ajax_Fatal«ELSE»FatalResponse«ENDIF»($this->__('Error: invalid destination node.'));
        }

        //$this->entityManager->transactional(function($entityManager) {
            «IF app.isLegacy»
                $entity = ModUtil::apiFunc($this->name, 'selection', 'getEntity', array('ot' => $objectType, 'id' => $id, 'useJoins' => false));
                $destEntity = ModUtil::apiFunc($this->name, 'selection', 'getEntity', array('ot' => $objectType, 'id' => $destId, 'useJoins' => false));
            «ELSE»
                $entity = $selectionHelper->getEntity($objectType, $id«IF app.hasSluggable», ''«ENDIF», false);
                $destEntity = $selectionHelper->getEntity($objectType, $destId«IF app.hasSluggable», ''«ENDIF», false);
            «ENDIF»
            if (null === $entity || null === $destEntity) {
                return new «IF app.isLegacy»Zikula_Response_Ajax_NotFound«ELSE»NotFoundResponse«ENDIF»($this->__('No such item.'));
            }

            if ($moveDirection == 'after') {
                $repository->persistAsNextSiblingOf($entity, $destEntity);
            } elseif ($moveDirection == 'before') {
                $repository->persistAsPrevSiblingOf($entity, $destEntity);
            } elseif ($moveDirection == 'bottom') {
                $repository->persistAsLastChildOf($entity, $destEntity);
            }
            $this->entityManager->flush();
        //});
    '''




    def dispatch additionalAjaxFunctions(Controller it, Application app) {
    }

    def dispatch additionalAjaxFunctions(AjaxController it, Application app) '''
        «userSelectorsImpl(app)»
        «IF app.generateExternalControllerAndFinder»

            «getItemListFinderImpl(app)»
        «ENDIF»
        «val joinRelations = app.getJoinRelations»
        «IF !joinRelations.empty»

            «getItemListAutoCompletionImpl(app)»
        «ENDIF»
        «IF app.entities.exists[getUniqueDerivedFields.filter[!primaryKey].size > 0]
        || (app.hasSluggable && !app.getAllEntities.filter[hasSluggableFields && slugUnique].empty)»

            «checkForDuplicateImpl(app)»
        «ENDIF»
        «IF app.hasBooleansWithAjaxToggle»

            «toggleFlagImpl(app)»
        «ENDIF»
        «IF app.hasTrees»
        
            «handleTreeOperationImpl(app)»
        «ENDIF»
    '''

    def private userSelectorsImpl(AjaxController it, Application app) '''
        «val userFields = app.getAllUserFields»
        «IF !userFields.empty»
            «FOR userField : userFields»

                /**
                 *
                 * @Route("/get«userField.entity.name.formatForCodeCapital»«userField.name.formatForCodeCapital»Users", options={"expose"=true})
                 * @Method("GET")
                 */
                public function get«userField.entity.name.formatForCodeCapital»«userField.name.formatForCodeCapital»UsersAction(Request $request)
                {
                    return parent::get«userField.entity.name.formatForCodeCapital»«userField.name.formatForCodeCapital»UsersAction($request);
                }
            «ENDFOR»

            «getCommonUsersListImpl(app)»
        «ENDIF»
    '''

    def private getCommonUsersListImpl(AjaxController it, Application app) '''
        «getCommonUsersListDocBlock(false)»
        «getCommonUsersListSignature»
        {
            return parent::getCommonUsersListAction($request);
        }
    '''

    def private getItemListFinderImpl(AjaxController it, Application app) '''
        «getItemListFinderDocBlock(false)»
        «getItemListFinderSignature»
        {
            return parent::getItemListFinderAction($request);
        }
    '''

    def private getItemListAutoCompletionImpl(AjaxController it, Application app) '''
        «getItemListAutoCompletionDocBlock(false)»
        «getItemListAutoCompletionSignature»
        {
            return parent::getItemListAutoCompletionAction($request);
        }
    '''

    def private checkForDuplicateImpl(AjaxController it, Application app) '''
        «checkForDuplicateDocBlock(false)»
        «checkForDuplicateSignature»
        {
            return parent::checkForDuplicateAction($request);
        }
    '''

    def private toggleFlagImpl(AjaxController it, Application app) '''
        «toggleFlagDocBlock(false)»
        «toggleFlagSignature»
        {
            return parent::toggleFlagAction($request);
        }
    '''

    def private handleTreeOperationImpl(AjaxController it, Application app) '''
        «handleTreeOperationDocBlock(false)»
        «handleTreeOperationSignature»
        {
            return parent::handleTreeOperationAction($request);
        }
    '''

    def private isLegacy(Application it) {
        targets('1.3.x')
    }
}
