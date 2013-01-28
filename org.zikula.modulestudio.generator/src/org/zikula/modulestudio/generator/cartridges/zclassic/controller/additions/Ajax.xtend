package org.zikula.modulestudio.generator.cartridges.zclassic.controller.additions

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.AjaxController
import de.guite.modulestudio.metamodel.modulestudio.Application
import de.guite.modulestudio.metamodel.modulestudio.Controller
import de.guite.modulestudio.metamodel.modulestudio.StringField
import de.guite.modulestudio.metamodel.modulestudio.TextField
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.ControllerHelper
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Ajax {
    @Inject extension ControllerExtensions = new ControllerExtensions()
    @Inject extension FormattingExtensions = new FormattingExtensions()
    @Inject extension ModelExtensions = new ModelExtensions()
    @Inject extension ModelBehaviourExtensions = new ModelBehaviourExtensions()
    @Inject extension ModelJoinExtensions = new ModelJoinExtensions()
    @Inject extension Utils = new Utils()

    def dispatch additionalAjaxFunctions(Controller it, Application app) {
    }

    def dispatch additionalAjaxFunctions(AjaxController it, Application app) '''
        «userSelectors(app)»

        «getItemListFinder(app)»
        «val joinRelations = app.getJoinRelations»
        «IF !joinRelations.isEmpty»

            «getItemListAutoCompletion(app)»
        «ENDIF»
        «IF app.getAllEntities.exists(e|e.getUniqueDerivedFields.filter(f|!f.primaryKey).size > 0)
        || (app.hasSluggable && !app.getAllEntities.filter(e|e.hasSluggableFields && e.slugUnique).isEmpty)»

            «checkForDuplicate(app)»
        «ENDIF»
        «IF app.hasBooleansWithAjaxToggle»

            «toggleFlag(app)»
        «ENDIF»
        «IF app.hasTrees»
        
            «handleTreeOperations(app)»
        «ENDIF»
    '''

    def private userSelectors(AjaxController it, Application app) '''
        «val userFields = app.getAllUserFields»
        «IF !userFields.isEmpty»
            «FOR userField : userFields»

                public function get«userField.entity.name.formatForCodeCapital»«userField.name.formatForCodeCapital»Users«IF !app.targets('1.3.5')»Action«ENDIF»()
                {
                    return $this->getCommonUsersList();
                }
            «ENDFOR»

            /**
             * Retrieve a general purpose list of users.
             */ 
            public function getCommonUsersList«IF !app.targets('1.3.5')»Action«ENDIF»()
            {
                if (!\SecurityUtil::checkPermission($this->name . '::Ajax', '::', ACCESS_EDIT)) {
                    return true;
                }

                $fragment = '';
                if ($this->request->«IF app.targets('1.3.5')»isPost()«ELSE»isMethod('POST')«ENDIF» && $this->request->request->has('fragment')) {
                    $fragment = $this->request->request->get('fragment', '');
                } elseif ($this->request->«IF app.targets('1.3.5')»isGet()«ELSE»isMethod('GET')«ENDIF» && $this->request->query->has('fragment')) {
                    $fragment = $this->request->query->get('fragment', '');
                }

                \ModUtil::dbInfoLoad('Users');
                $tables = \DBUtil::getTables();

                $usersColumn = $tables['users_column'];

                $where = 'WHERE ' . $usersColumn['uname'] . ' REGEXP \'(' . DataUtil::formatForStore($fragment) . ')\'';
                $results = \DBUtil::selectObjectArray('users', $where);

                $out = '<ul>';
                if (is_array($results) && count($results) > 0) {
                    foreach($results as $result) {
                        $out .= '<li>' . DataUtil::formatForDisplay($result['uname']) . '<input type="hidden" id="' . DataUtil::formatForDisplay($result['uname']) . '" value="' . $result['uid'] . '" /></li>';
                    }
                }
                $out .= '</ul>';

                «IF targets('1.3.5')»
                return new Zikula_Response_Ajax_Plain($out);
                «ELSE»
                return new \Zikula\Core\Response\Ajax\Plain($view->display('External/' . ucwords($objectType) . '/find.tpl'));
                «ENDIF»
            }
        «ENDIF»
    '''

    def private getItemListFinder(AjaxController it, Application app) '''
        /**
         * Retrieve item list for finder selections in Forms, Content type plugin and Scribite.
         *
         * @param array $args List of arguments.
         *
         * @return Zikula_Response_Ajax
         */
        public function getItemListFinder«IF !app.targets('1.3.5')»Action«ENDIF»(array $args = array())
        {
            if (!\SecurityUtil::checkPermission($this->name . '::Ajax', '::', ACCESS_EDIT)) {
                return true;
            }

            $objectType = '«app.getLeadingEntity.name.formatForCode»';
            if ($this->request->«IF app.targets('1.3.5')»isPost()«ELSE»isMethod('POST')«ENDIF» && $this->request->request->has('ot')) {
                $objectType = $this->request->request->filter('ot', '«app.getLeadingEntity.name.formatForCode»', FILTER_SANITIZE_STRING);
            } elseif ($this->request->«IF app.targets('1.3.5')»isGet()«ELSE»isMethod('GET')«ENDIF» && $this->request->query->has('ot')) {
                $objectType = $this->request->query->filter('ot', '«app.getLeadingEntity.name.formatForCode»', FILTER_SANITIZE_STRING);
            }
            $controllerHelper = new \«app.appName»«IF app.targets('1.3.5')»_Util_Controller«ELSE»\Util\ControllerUtil«ENDIF»($this->serviceManager);
            if (!in_array($objectType, $controllerHelper->getObjectTypes('controllerAction', array('controller' => '«formattedName»', 'action' => 'getItemListFinder')))) {
                $objectType = $controllerHelper->getDefaultObjectType('controllerAction', array('controller' => '«formattedName»', 'action' => 'getItemListFinder'));
            }

            $repository = $this->entityManager->getRepository('«app.appName»_Entity_' . ucfirst($objectType));
            $idFields = \ModUtil::apiFunc($this->name, 'selection', 'getIdFields', array('ot' => $objectType));
            $titleField = $repository->getTitleFieldName();
            $descriptionField = $repository->getDescriptionFieldName();

            $sort = (isset($args['sort']) && !empty($args['sort'])) ? $args['sort'] : $this->request->request->filter('sort', '', FILTER_SANITIZE_STRING);
            if (empty($sort) || !in_array($sort, $repository->getAllowedSortingFields())) {
                $sort = $repository->getDefaultSortingField();
            }

            $sdir = (isset($args['sortdir']) && !empty($args['sortdir'])) ? $args['sortdir'] : $this->request->request->filter('sortdir', '', FILTER_SANITIZE_STRING);
            $sdir = strtolower($sdir);
            if ($sdir != 'asc' && $sdir != 'desc') {
                $sdir = 'asc';
            }

            $where = ''; // filters are processed inside the repository class
            $sortParam = $sort . ' ' . $sdir;

            $objectData = $repository->selectWhere($where, $sortParam);

            $slimItems = array();
            $component = $this->name . ':' . ucwords($objectType) . ':';
            foreach ($objectData as $item) {
                $itemId = '';
                foreach ($idFields as $idField) {
                    $itemId .= ((!empty($itemId)) ? '_' : '') . $item[$idField];
                }
                if (!\SecurityUtil::checkPermission($component, $itemId . '::', ACCESS_READ)) {
                    continue;
                }
                $slimItems[] = $this->prepareSlimItem($objectType, $item, $itemId, $titleField, $descriptionField);
            }

            return new Zikula_Response_Ajax($slimItems);
        }

        /**
         * Builds and returns a slim data array from a given entity.
         *
         * @param string $objectType       The currently treated object type.
         * @param object $item             The currently treated entity.
         * @param string $itemid           Data item identifier(s).
         * @param string $titleField       Name of item title field.
         * @param string $descriptionField Name of item description field.
         *
         * @return array The slim data representation.
         */
        protected function prepareSlimItem($objectType, $item, $itemId, $titleField, $descriptionField)
        {
            $view = Zikula_View::getInstance('«app.appName»', false);
            $view->assign($objectType, $item);
            $previewInfo = base64_encode($view->fetch(«IF app.targets('1.3.5')»'external/' . $objectType«ELSE»'External/' . ucwords($objectType)«ENDIF» . '/info.tpl'));

            $title = ($titleField != '') ? $item[$titleField] : '';
            $description = ($descriptionField != '') ? $item[$descriptionField] : '';

            return array('id'           => $itemId,
                         'title'        => str_replace('&amp;', '&', $title),
                         'description'  => $description,
                         'previewInfo'  => $previewInfo);
        }
    '''

    def private getItemListAutoCompletion(AjaxController it, Application app) '''
        /**
         * Searches for entities for auto completion usage.
         *
         * @param string $ot       Treated object type.
         * @param string $fragment The fragment of the entered item name.
         * @param string $exclude  Comma separated list with ids of other items (to be excluded from search).
         *
         * @return Zikula_Response_Ajax_Plain
         */
        public function getItemListAutoCompletion«IF !app.targets('1.3.5')»Action«ENDIF»()
        {
            if (!\SecurityUtil::checkPermission($this->name . '::Ajax', '::', ACCESS_EDIT)) {
                return true;
            }

            $objectType = '«app.getLeadingEntity.name.formatForCode»';
            if ($this->request->«IF app.targets('1.3.5')»isPost()«ELSE»isMethod('POST')«ENDIF» && $this->request->request->has('ot')) {
                $objectType = $this->request->request->filter('ot', '«app.getLeadingEntity.name.formatForCode»', FILTER_SANITIZE_STRING);
            } elseif ($this->request->«IF app.targets('1.3.5')»isGet()«ELSE»isMethod('GET')«ENDIF» && $this->request->query->has('ot')) {
                $objectType = $this->request->query->filter('ot', '«app.getLeadingEntity.name.formatForCode»', FILTER_SANITIZE_STRING);
            }
            $controllerHelper = new \«app.appName»«IF app.targets('1.3.5')»_Util_Controller«ELSE»\Util\ControllerUtil«ENDIF»($this->serviceManager);
            $utilArgs = array('controller' => '«formattedName»', 'action' => 'getItemListAutoCompletion');
            if (!in_array($objectType, $controllerHelper->getObjectTypes('controllerAction', $utilArgs))) {
                $objectType = $controllerHelper->getDefaultObjectType('controllerAction', $utilArgs);
            }

            $repository = $this->entityManager->getRepository('«app.appName»_Entity_' . ucfirst($objectType));
            $idFields = \ModUtil::apiFunc($this->name, 'selection', 'getIdFields', array('ot' => $objectType));

            $fragment = '';
            $exclude = '';
            if ($this->request->«IF app.targets('1.3.5')»isPost()«ELSE»isMethod('POST')«ENDIF» && $this->request->request->has('fragment')) {
                $fragment = $this->request->request->get('fragment', '');
                $exclude = $this->request->request->get('exclude', '');
            } elseif ($this->request->«IF app.targets('1.3.5')»isGet()«ELSE»isMethod('GET')«ENDIF» && $this->request->query->has('fragment')) {
                $fragment = $this->request->query->get('fragment', '');
                $exclude = $this->request->query->get('exclude', '');
            }
            $exclude = ((!empty($exclude)) ? array($exclude) : array());

            // parameter for used sorting field
            $sort = $this->request->query->get('sort', '');
            «new ControllerHelper().defaultSorting(it)»
            $sortParam = $sort . ' asc';

            $currentPage = 1;
            $resultsPerPage = 20;

            // get objects from database
            list($entities, $objectCount) = $repository->selectSearch($fragment, $exclude, $sortParam, $currentPage, $resultsPerPage);

            $out = '<ul>';
            if ((is_array($entities) || is_object($entities)) && count($entities) > 0) {
                $titleFieldName = $repository->getTitleFieldName();
                $descriptionFieldName = $repository->getDescriptionFieldName();
                $previewFieldName = $repository->getPreviewFieldName();
                «IF app.hasImageFields»
                    if (!empty($previewFieldName)) {
                        $imageHelper = new \«app.appName»«IF app.targets('1.3.5')»_Util_Image«ELSE»\Util\ImageUtil«ENDIF»($this->serviceManager);
                        $imagineManager = $imageHelper->getManager($objectType, $previewFieldName, 'controllerAction', $utilArgs);
                    }
                «ENDIF»
                foreach ($entities as $item) {
                    // class="informal" --> show in dropdown, but do nots copy in the input field after selection
                    $itemTitle = (!empty($titleFieldName)) ? $item[$titleFieldName] : $this->__('Item');
                    $itemTitleStripped = str_replace('"', '', $itemTitle);
                    $itemDescription = (isset($item[$descriptionFieldName]) && !empty($item[$descriptionFieldName])) ? $item[$descriptionFieldName] : '';//$this->__('No description yet.');
                    $itemId = '';
                    foreach ($idFields as $idField) {
                        $itemId .= ((!empty($itemId)) ? '_' : '') . $item[$idField];
                    }
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
                            $preview = '<img src="' . $thumbImagePath . '" width="' . $thumbWidth . '" height="' . $thumbHeight . '" alt="' . $itemTitleStripped . '" />';
                            $out .= '<div class="itempreview informal" id="itempreview' . $itemId . '">' . $preview . '</div>';
                        }
                    «ENDIF»
                    $out .= '</li>';
                }
            }
            $out .= '</ul>';

            // return response
            return new Zikula_Response_Ajax_Plain($out);
        }
    '''

    def private checkForDuplicate(AjaxController it, Application app) '''
        /**
         * Checks whether a field value is a duplicate or not.
         *
         * @param string $ot       Treated object type.
         * @param string $fragment The fragment of the entered item name.
         * @param string $exclude  Optinal identifier to be excluded from search.
         *
         * @throws Zikula_Exception If something fatal occurs.
         *
         * @return Zikula_Response_Ajax
         */
        public function checkForDuplicate«IF !app.targets('1.3.5')»Action«ENDIF»()
        {
            $this->checkAjaxToken();
            $this->throwForbiddenUnless(\SecurityUtil::checkPermission($this->name . '::Ajax', '::', ACCESS_EDIT));

            $objectType = $this->request->request->filter('ot', '«app.getLeadingEntity.name.formatForCode»', FILTER_SANITIZE_STRING);
            $controllerHelper = new \«app.appName»«IF app.targets('1.3.5')»_Util_Controller«ELSE»\Util\ControllerUtil«ENDIF»($this->serviceManager);
            if (!in_array($objectType, $controllerHelper->getObjectTypes('controllerAction', array('controller' => '«formattedName»', 'action' => 'checkForDuplicate')))) {
                $objectType = $controllerHelper->getDefaultObjectType('controllerAction', array('controller' => '«formattedName»', 'action' => 'checkForDuplicate'));
            }

            $fieldName = $this->request->request->filter('fn', '', FILTER_SANITIZE_STRING);
            $value = $this->request->request->get('v', '');

            if (empty($fieldName) || empty($value)) {
                return new Zikula_Response_Ajax_BadData($this->__('Error: invalid input.'));
            }

            // check if the given field is existing and unique
            $uniqueFields = array();
            switch ($objectType) {
                «FOR entity : app.getAllEntities»
                    «val uniqueFields = entity.getUniqueDerivedFields.filter(e|!e.primaryKey)»
                    «IF !uniqueFields.isEmpty || (entity.hasSluggableFields && entity.slugUnique)»
                        case '«entity.name.formatForCode»':
                                $uniqueFields = array(«FOR uniqueField : uniqueFields SEPARATOR ', '»'«uniqueField.name.formatForCode»'«ENDFOR»«IF entity.hasSluggableFields && entity.slugUnique»«IF !uniqueFields.isEmpty», «ENDIF»'slug'«ENDIF»);
                                break;
                    «ENDIF»
                «ENDFOR»
            }
            if (!count($uniqueFields) || !in_array($fieldName, $uniqueFields)) {
                return new Zikula_Response_Ajax_BadData($this->__('Error: invalid input.'));
            }

            $exclude = $this->request->request->get('ex', '');
            «IF !container.application.getAllEntities.filter(e|e.hasCompositeKeys).isEmpty»
            if (strpos($exclude, '_') !== false) {
                $exclude = explode('_', $exclude);
            }
            «ENDIF» 

            $entityClass = '«app.appName»_Entity_' . ucfirst($objectType);
            $object = new $entityClass(); 

            $result = false;
            switch ($objectType) {
            «FOR entity : app.getAllEntities»
                «val uniqueFields = entity.getUniqueDerivedFields.filter(e|!e.primaryKey)»
                «IF !uniqueFields.isEmpty || (entity.hasSluggableFields && entity.slugUnique)»
                    case '«entity.name.formatForCode»':
                        $repository = $this->entityManager->getRepository($entityClass);
                        switch ($fieldName) {
                        «FOR uniqueField : uniqueFields»
                            case '«uniqueField.name.formatForCode»':
                                    $result = $repository->detectUniqueState('«uniqueField.name.formatForCode»', $value, $exclude«IF !container.application.getAllEntities.filter(e|e.hasCompositeKeys).isEmpty»[0]«ENDIF»);
                                    break;
                        «ENDFOR»
                        «IF entity.hasSluggableFields && entity.slugUnique»
                            case 'slug':
                                    $entity = $repository->selectBySlug($value, false, $exclude);
                                    $result = ($entity != null && isset($entity['slug']));
                                    break;
                        «ENDIF»
                        }
                        break;
                «ENDIF»
            «ENDFOR»
            }

            // return response
            return new Zikula_Response_Ajax(array('isDuplicate' => $result));
        }
    '''

    def private toggleFlag(AjaxController it, Application app) '''
        /**
         * Changes a given flag (boolean field) by switching between true and false.
         *
         * @param string $ot    Treated object type.
         * @param string $field The field to be toggled.
         * @param int    $id    Identifier of treated entity.
         *
         * @return Zikula_Response_Ajax
         */
        public function toggleFlag«IF !app.targets('1.3.5')»Action«ENDIF»()
        {
            $this->throwForbiddenUnless(\SecurityUtil::checkPermission($this->name. '::Ajax', '::', ACCESS_EDIT));

            $objectType = $this->request->request->filter('ot', '', FILTER_SANITIZE_STRING);
            $field = $this->request->request->filter('field', '', FILTER_SANITIZE_STRING);
            $id = (int) $this->request->request->filter('id', 0, FILTER_VALIDATE_INT);

            «val entities = app.getEntitiesWithAjaxToggle»
            if ($id == 0
                || («FOR entity : entities SEPARATOR ' && '»$objectType != '«entity.name.formatForCode»'«ENDFOR»)
            «FOR entity : entities»
                || ($objectType == '«entity.name.formatForCode»' && !in_array($field, array(«FOR field : entity.getBooleansWithAjaxToggleEntity SEPARATOR ', '»'«field.name.formatForCode»'«ENDFOR»)))
            «ENDFOR»
            ) {
                return new Zikula_Response_Ajax_BadData($this->__('Error: invalid input.'));
            }

            // select data from data source
            $entity = \ModUtil::apiFunc($this->name, 'selection', 'getEntity', array('ot' => $objectType, 'id' => $id));
            if ($entity == null) {
                return new Zikula_Response_Ajax_NotFound($this->__('No such item.'));
            }

            // toggle the flag
            $entity[$field] = !$entity[$field];

            // save entity back to database
            $this->entityManager->flush();

            // return response
            return new Zikula_Response_Ajax(array('id' => $id,
                                                  'state' => $entity[$field]));
        }
    '''

    def private handleTreeOperations(AjaxController it, Application app) '''
        /**
         * Performs different operations on tree hierarchies.
         *
         * @param string $ot Treated object type.
         * @param string $op The operation which should be performed.
         *
         * @return Zikula_Response_Ajax
         * @throws Zikula_Exception_Ajax_Fatal
         */
        public function handleTreeOperation«IF !app.targets('1.3.5')»Action«ENDIF»()
        {
            $this->throwForbiddenUnless(\SecurityUtil::checkPermission($this->name . '::Ajax', '::', ACCESS_EDIT));

            «val treeEntities = app.getTreeEntities»
            // parameter specifying which type of objects we are treating
            $objectType = DataUtil::convertFromUTF8($this->request->request->filter('ot', '«treeEntities.head.name.formatForCode»', FILTER_SANITIZE_STRING));
            // ensure that we use only object types with tree extension enabled
            if (!in_array($objectType, array(«FOR treeEntity : treeEntities SEPARATOR ", "»'«treeEntity.name.formatForCode»'«ENDFOR»))) {
                $objectType = '«treeEntities.head.name.formatForCode»';
            }

            $returnValue = array(
                'data'    => array(),
                'message' => ''
            );

            $op = DataUtil::convertFromUTF8($this->request->request->filter('op', '', FILTER_SANITIZE_STRING));
            if (!in_array($op, array('addRootNode', 'addChildNode', 'deleteNode', 'moveNode', 'moveNodeTo'))) {
                \LogUtil::registerError($this->__('Error: invalid operation.'));
                throw new Zikula_Exception_Ajax_Fatal();
            }

            // Get id of treated node
            $id = 0;
            if (!in_array($op, array('addRootNode', 'addChildNode'))) {
                $id = (int) $this->request->request->filter('id', 0, FILTER_VALIDATE_INT);
                if (!$id) {
                    \LogUtil::registerError($this->__('Error: invalid node.'));
                    throw new Zikula_Exception_Ajax_Fatal();
                }
            }

            $entityClass = '«app.appName»_Entity_' . ucfirst($objectType);
            $repository = $this->entityManager->getRepository($entityClass);

            $rootId = 1;
            if (!in_array($op, array('addRootNode'))) {
                $rootId = (int) $this->request->request->filter('root', 0, FILTER_VALIDATE_INT);
                if (!$rootId) {
                    \LogUtil::registerError($this->__('Error: invalid root node.'));
                    throw new Zikula_Exception_Ajax_Fatal();
                }
            }

            // Select tree
            $tree = null;
            if (!in_array($op, array('addRootNode'))) {
                $tree = \ModUtil::apiFunc($this->name, 'selection', 'getTree', array('ot' => $objectType, 'rootId' => $rootId));
            }

            // verification and recovery of tree
            $verificationResult = $repository->verify();
            if (is_array($verificationResult)) {
                foreach ($verificationResult as $errorMsg) {
                    \LogUtil::registerError($errorMsg);
                }
            }
            $repository->recover();
            $this->entityManager->clear(); // clear cached nodes

            $titleFieldName = $descriptionFieldName = '';

            switch ($objectType) {
                «FOR entity : app.getTreeEntities»
                    case '«entity.name.formatForCode»':
                        «val stringFields = entity.fields.filter(typeof(StringField)).filter(e|e.length >= 20 && !e.nospace && !e.country && !e.htmlcolour && !e.language)»
                            $titleFieldName = '«IF !stringFields.isEmpty»«stringFields.head.name.formatForCode»«ENDIF»';
                            «val textFields = entity.fields.filter(typeof(TextField)).filter(e|!e.leading && e.length >= 50)»
                            «IF !textFields.isEmpty»
                            $descriptionFieldName = '«textFields.head.name.formatForCode»';
                            «ELSE»
                                «val textStringFields = entity.fields.filter(typeof(StringField)).filter(e|!e.leading && e.length >= 50 && !e.nospace && !e.country && !e.htmlcolour && !e.language)»
                                «IF !textStringFields.isEmpty»
                                $descriptionFieldName = '«textStringFields.head.name.formatForCode»';
                                «ENDIF»
                            «ENDIF»
                            break;
                «ENDFOR»
            }

            switch ($op) {
                case 'addRootNode':
                                //$this->entityManager->transactional(function($entityManager) {
                                    $object = new $entityClass();
                                    $objectData = array();
                                    if (!empty($titleFieldName)) {
                                        $objectData[$titleFieldName] = $this->__('New root node');
                                    }
                                    if (!empty($descriptionFieldName)) {
                                        $objectData[$descriptionFieldName] = $this->__('This is a new root node');
                                    }
                                    $object->merge($objectData);
                                    «/*IF hasTranslatableFields»
                                        $object->setLocale(ZLanguage::getLanguageCode());
                                    «ENDIF*/»
                                    // save new object to set the root id
                                    $this->entityManager->persist($object);
                                    $this->entityManager->flush();
                                //});
                                break;
                case 'addChildNode':
                                $parentId = (int) $this->request->request->filter('pid', 0, FILTER_VALIDATE_INT);
                                if (!$parentId) {
                                    \LogUtil::registerError($this->__('Error: invalid parent node.'));
                                    throw new Zikula_Exception_Ajax_Fatal();
                                }

                                //$this->entityManager->transactional(function($entityManager) {
                                    $childEntity = new $entityClass();
                                    $objectData = array();
                                    $objectData[$titleFieldName] = $this->__('New child node');
                                    if (!empty($descriptionFieldName)) {
                                        $objectData[$descriptionFieldName] = $this->__('This is a new child node');
                                    }
                                    $childEntity->merge($objectData);

                                    //$childEntity->setParent($parentEntity);
                                    $parentEntity = \ModUtil::apiFunc($this->name, 'selection', 'getEntity', array('ot' => $objectType, 'id' => $parentId, 'useJoins' => false));
                                    if ($parentEntity == null) {
                                        return new Zikula_Response_Ajax_NotFound($this->__('No such item.'));
                                    }
                                    $repository->persistAsLastChildOf($childEntity, $parentEntity);
                                //});
                                $this->entityManager->flush();
                                break;
                case 'deleteNode':
                                // remove node from tree and reparent all children
                                $entity = \ModUtil::apiFunc($this->name, 'selection', 'getEntity', array('ot' => $objectType, 'id' => $id, 'useJoins' => false));
                                if ($entity == null) {
                                    return new Zikula_Response_Ajax_NotFound($this->__('No such item.'));
                                }
                                $repository->removeFromTree($entity);
                                $this->entityManager->clear(); // clear cached nodes
                                break;
                case 'moveNode':
                                $moveDirection = $this->request->request->filter('direction', '', FILTER_SANITIZE_STRING);
                                if (!in_array($moveDirection, array('up', 'down'))) {
                                    \LogUtil::registerError($this->__('Error: invalid direction.'));
                                    throw new Zikula_Exception_Ajax_Fatal();
                                }

                                $entity = \ModUtil::apiFunc($this->name, 'selection', 'getEntity', array('ot' => $objectType, 'id' => $id, 'useJoins' => false));
                                if ($entity == null) {
                                    return new Zikula_Response_Ajax_NotFound($this->__('No such item.'));
                                }

                                if ($moveDirection == 'up') {
                                    $repository->moveUp($entity, 1);
                                } else if ($moveDirection == 'down') {
                                    $repository->moveDown($entity, 1);
                                }
                                $this->entityManager->flush();

                                break;
                case 'moveNodeTo':
                                $moveDirection = $this->request->request->filter('direction', '', FILTER_SANITIZE_STRING);
                                if (!in_array($moveDirection, array('after', 'before', 'bottom'))) {
                                    \LogUtil::registerError($this->__('Error: invalid direction.'));
                                    throw new Zikula_Exception_Ajax_Fatal();
                                }

                                $destId = (int) $this->request->request->filter('destid', 0, FILTER_VALIDATE_INT);
                                if (!$destId) {
                                    \LogUtil::registerError($this->__('Error: invalid destination node.'));
                                    throw new Zikula_Exception_Ajax_Fatal();
                                }

                                //$this->entityManager->transactional(function($entityManager) {
                                    $entity = \ModUtil::apiFunc($this->name, 'selection', 'getEntity', array('ot' => $objectType, 'id' => $id, 'useJoins' => false));
                                    $destEntity = \ModUtil::apiFunc($this->name, 'selection', 'getEntity', array('ot' => $objectType, 'id' => $destId, 'useJoins' => false));
                                    if ($entity == null || $destEntity == null) {
                                        return new Zikula_Response_Ajax_NotFound($this->__('No such item.'));
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
                                break;
            }

            $returnValue['message'] = $this->__('The operation was successful.');

            // Renew tree
            /** postponed, for now we do a page reload
            $returnValue['data'] = \ModUtil::apiFunc($this->name, 'selection', 'getTree', array('ot' => $objectType, 'rootId' => $rootId));
            */

            return new Zikula_Response_Ajax($returnValue);
        }
    '''
}
