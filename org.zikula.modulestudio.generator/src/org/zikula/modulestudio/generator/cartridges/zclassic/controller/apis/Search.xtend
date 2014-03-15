package org.zikula.modulestudio.generator.cartridges.zclassic.controller.apis

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.cartridges.zclassic.view.additions.SearchView
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Search {
    @Inject extension ControllerExtensions = new ControllerExtensions
    @Inject extension FormattingExtensions = new FormattingExtensions
    @Inject extension ModelExtensions = new ModelExtensions
    @Inject extension NamingExtensions = new NamingExtensions
    @Inject extension Utils = new Utils

    FileHelper fh = new FileHelper

    def generate(Application it, IFileSystemAccess fsa) {
        if (targets('1.3.5')) {
            generateClassPair(fsa, getAppSourceLibPath + 'Api/Search.php', searchApiBaseFile, searchApiFile)
        } else {
            generateClassPair(fsa, getAppSourceLibPath + 'Helper/SearchHelper.php', searchHelperBaseFile, searchHelperFile)
        }
        new SearchView().generate(it, fsa)
    }

    def private searchApiBaseFile(Application it) '''
        «fh.phpFileHeader(it)»
        «searchApiBaseClass»
    '''

    def private searchApiFile(Application it) '''
        «fh.phpFileHeader(it)»
        «searchApiImpl»
    '''

    def private searchHelperBaseFile(Application it) '''
        «fh.phpFileHeader(it)»
        «searchHelperBaseClass»
    '''

    def private searchHelperFile(Application it) '''
        «fh.phpFileHeader(it)»
        «searchHelperImpl»
    '''

    def private searchApiBaseClass(Application it) '''
        /**
         * Search api base class.
         */
        class «appName»_Api_Base_Search extends Zikula_AbstractApi
        {
            «searchApiBaseImpl»
        }
    '''

    def private searchHelperBaseClass(Application it) '''
        namespace «appNamespace»\Api\Base;

        use «appNamespace»\Util\ControllerUtil;

        use ModUtil;
        use SecurityUtil;
        use ServiceUtil;
        use ZLanguage;

        use Zikula\Core\ModUrl;
        use Zikula\Module\SearchModule\AbstractSearchable;
        use Zikula\Module\SearchModule\Entity\SearchResultEntity;

        /**
         * Search helper base class.
         */
        class SearchHelper extends AbstractSearchable
        {
            «searchHelperBaseImpl»
        }
    '''

    def private searchApiBaseImpl(Application it) '''
        «infoLegacy»

        «optionsLegacy»

        «searchLegacy»

        «searchCheckLegacy»
    '''

    def private searchHelperBaseImpl(Application it) '''
        «getOptions»

        «getResults»
    '''

    def private infoLegacy(Application it) '''
        /**
         * Get search plugin information.
         *
         * @return array The search plugin information
         */
        public function info()
        {
            return array('title'     => $this->name,
                         'functions' => array($this->name => 'search'));
        }
    '''

    def private optionsLegacy(Application it) '''
        /**
         * Display the search form.
         *
         * @param array $args List of arguments.
         *
         * @return string Template output
         */
        public function options(array $args = array())
        {
            if (!SecurityUtil::checkPermission($this->name . '::', '::', ACCESS_READ)) {
                return '';
            }

            $view = Zikula_View::getInstance($this->name);

            «FOR entity : getAllEntities.filter[hasAbstractStringFieldsEntity]»
                «val fieldName = 'active_' + entity.name.formatForCode»
                $view->assign('«fieldName»', (!isset($args['«fieldName»']) || isset($args['active']['«fieldName»'])));
            «ENDFOR»

            return $view->fetch('search/options.tpl');
        }
    '''

    def private getOptions(Application it) '''
        /**
         * Display the search form.
         *
         * @param boolean    $active
         * @param array|null $modVars
         *
         * @return string Template output
         */
        public function getOptions($active, $modVars = null)
        {
            if (!SecurityUtil::checkPermission($this->name . '::', '::', ACCESS_READ)) {
                return '';
            }

            «FOR entity : getAllEntities.filter[hasAbstractStringFieldsEntity]»
                «val fieldName = 'active_' + entity.name.formatForCode»
                $this->view->assign('«fieldName»', (!isset($args['«fieldName»']) || isset($args['active']['«fieldName»'])));
            «ENDFOR»

            return $this->view->fetch('Search/options.tpl');
        }
    '''

    def private searchLegacy(Application it) '''
        /**
         * Executes the actual search process.
         *
         * @param array $args List of arguments.
         *
         * @return boolean
         *
         * @throws RuntimeException Thrown if search results can not be saved
         */
        public function search(array $args = array())
        {
            if (!SecurityUtil::checkPermission($this->name . '::', '::', ACCESS_READ)) {
                return '';
            }

            // ensure that database information of Search module is loaded
            ModUtil::dbInfoLoad('Search');

            // save session id as it is used when inserting search results below
            $sessionId  = session_id();

            // retrieve list of activated object types
            $searchTypes = isset($args['objectTypes']) ? (array)$args['objectTypes'] : (array) FormUtil::getPassedValue('«appName.toFirstLower»SearchTypes', array(), 'GETPOST');

            $controllerHelper = new «appName»_Util_Controller($this->serviceManager);
            $utilArgs = array('api' => 'search', 'action' => 'search');
            $allowedTypes = $controllerHelper->getObjectTypes('api', $utilArgs);
            $entityManager = ServiceUtil::getService('doctrine.entitymanager');
            $currentPage = 1;
            $resultsPerPage = 50;

            foreach ($searchTypes as $objectType) {
                if (!in_array($objectType, $allowedTypes)) {
                    continue;
                }

                $whereArray = array();
                $languageField = null;
                switch ($objectType) {
                    «FOR entity : getAllEntities.filter[hasAbstractStringFieldsEntity]»
                        case '«entity.name.formatForCode»':
                            «FOR field : entity.getAbstractStringFieldsEntity»
                                $whereArray[] = 'tbl.«field.name.formatForCode»';
                            «ENDFOR»
                            «IF entity.hasLanguageFieldsEntity»
                            $languageField = '«entity.getLanguageFieldsEntity.head»';
                            «ENDIF»
                            break;
                    «ENDFOR»
                }
                $where = Search_Api_User::construct_where($args, $whereArray, $languageField);

                $entityClass = $this->name . '_Entity_' . ucwords($objectType);
                $repository = $entityManager->getRepository($entityClass);

                // get objects from database
                list($entities, $objectCount) = $repository->selectWherePaginated($where, '', $currentPage, $resultsPerPage, false);

                if ($objectCount == 0) {
                    continue;
                }

                $idFields = ModUtil::apiFunc($this->name, 'selection', 'getIdFields', array('ot' => $objectType));
                $descriptionField = $repository->getDescriptionFieldName();
                «val hasUserDisplay = !getAllUserControllers.filter[hasActions('display')].empty»
                foreach ($entities as $entity) {
                    «IF hasUserDisplay»
                        $urlArgs = array('ot' => $objectType);
                    «ENDIF»
                    // create identifier for permission check
                    $instanceId = '';
                    foreach ($idFields as $idField) {
                        «IF hasUserDisplay»
                            $urlArgs[$idField] = $entity[$idField];
                        «ENDIF»
                        if (!empty($instanceId)) {
                            $instanceId .= '_';
                        }
                        $instanceId .= $entity[$idField];
                    }
                    «IF hasUserDisplay»
                        $urlArgs['id'] = $instanceId;
                        /* commented out as it could exceed the maximum length of the 'extra' field
                        if (isset($entity['slug'])) {
                            $urlArgs['slug'] = $entity['slug'];
                        }*/
                    «ENDIF»

                    // perform permission check
                    if (!SecurityUtil::checkPermission($this->name . ':' . ucfirst($objectType) . ':', $instanceId . '::', ACCESS_OVERVIEW)) {
                        continue;
                    }

                    $title = $entity->getTitleFromDisplayPattern();
                    $description = !empty($descriptionField) ? $entity[$descriptionField] : '';
                    $created = isset($entity['createdDate']) ? $entity['createdDate']->format('Y-m-d H:i:s') : '';

                    $searchItemData = array(
                        'title'   => $title,
                        'text'    => $description,
                        'extra'   => «IF hasUserDisplay»serialize($urlArgs)«ELSE»''«ENDIF»,
                        'created' => $created,
                        'module'  => $this->name,
                        'session' => $sessionId
                    );

                    if (!DBUtil::insertObject($searchItemData, 'search_result')) {
                        return LogUtil::registerError($this->__('Error! Could not save the search results.'));
                    }
                }
            }

            return true;
        }
    '''

    def private searchCheckLegacy(Application it) '''
        /**
         * Assign URL to items.
         *
         * @param array $args List of arguments.
         *
         * @return boolean
         */
        public function search_check(array $args = array())
        {
            «val hasUserDisplay = !getAllUserControllers.filter[hasActions('display')].empty»
            «IF hasUserDisplay»
                $datarow = &$args['datarow'];
                $urlArgs = unserialize($datarow['extra']);
                $datarow['url'] = ModUtil::url($this->name, 'user', 'display', $urlArgs);
            «ELSE»
                // nothing to do as we have no display pages which could be linked
            «ENDIF»

            return true;
        }
    '''

    def private getResults(Application it) '''
        /**
         * Returns the search results.
         *
         * @param array      $words      Array of words to search for
         * @param string     $searchType AND|OR|EXACT (defaults to AND)
         * @param array|null $modVars    Module form vars passed though
         *
         * @return array List of fetched results.
         */
        public function getResults(array $words, $searchType = 'AND', $modVars = null)
        {
            if (!SecurityUtil::checkPermission($this->name . '::', '::', ACCESS_READ)) {
                return array();
            }

            // save session id as it is used when inserting search results below
            $sessionId  = session_id();

            // save current language
            $languageCode = ZLanguage::getLanguageCode();

            // initialise array for results
            $records = array();

            // retrieve list of activated object types
            $searchTypes = isset($modVars['objectTypes']) ? (array)$modVars['objectTypes'] : array();

            $controllerHelper = new ControllerUtil(ServiceUtil::getManager(), ModUtil::getModule($this->name));
            $utilArgs = array('helper' => 'search', 'action' => 'getResults');
            $allowedTypes = $controllerHelper->getObjectTypes('helper', $utilArgs);

            foreach ($searchTypes as $objectType) {
                if (!in_array($objectType, $allowedTypes)) {
                    continue;
                }

                $whereArray = array();
                $languageField = null;
                switch ($objectType) {
                    «FOR entity : getAllEntities.filter[hasAbstractStringFieldsEntity]»
                        case '«entity.name.formatForCode»':
                            «FOR field : entity.getAbstractStringFieldsEntity»
                                $whereArray[] = 'tbl.«field.name.formatForCode»';
                            «ENDFOR»
                            «IF entity.hasLanguageFieldsEntity»
                            $languageField = '«entity.getLanguageFieldsEntity.head»';
                            «ENDIF»
                            break;
                    «ENDFOR»
                }

                $entityClass = '«vendor.formatForCodeCapital»«name.formatForCodeCapital»Module:' . ucwords($objectType) . 'Entity';
                $repository = $this->entityManager->getRepository($entityClass);

                // build the search query without any joins
                $qb = $repository->genericBaseQuery('', '', false);

                // build where expression for given search type
                $whereExpr = $this->formatWhere($qb, $words, $whereArray, $searchType);
                $qb->andWhere($whereExpr);

                $query = $qb->getQuery();

                // set a sensitive limit
                $query->setFirstResult(0)
                      ->setMaxResults(250);

                // fetch the results
                $entities = $query->getResult();

                if (count($entities) == 0) {
                    continue;
                }

                $idFields = ModUtil::apiFunc($this->name, 'selection', 'getIdFields', array('ot' => $objectType));
                $descriptionField = $repository->getDescriptionFieldName();
                «val hasUserDisplay = !getAllUserControllers.filter[hasActions('display')].empty»

                foreach ($entities as $entity) {
                    «IF hasUserDisplay»
                        $urlArgs = array('ot' => $objectType);
                    «ENDIF»
                    // create identifier for permission check
                    $instanceId = '';
                    foreach ($idFields as $idField) {
                        «IF hasUserDisplay»
                            $urlArgs[$idField] = $entity[$idField];
                        «ENDIF»
                        if (!empty($instanceId)) {
                            $instanceId .= '_';
                        }
                        $instanceId .= $entity[$idField];
                    }
                    «IF hasUserDisplay»
                        $urlArgs['id'] = $instanceId;
                        if (isset($entity['slug'])) {
                            $urlArgs['slug'] = $entity['slug'];
                        }
                    «ENDIF»

                    // perform permission check
                    if (!SecurityUtil::checkPermission($this->name . ':' . ucfirst($objectType) . ':', $instanceId . '::', ACCESS_OVERVIEW)) {
                        continue;
                    }

                    $description = !empty($descriptionField) ? $entity[$descriptionField] : '';
                    $created = isset($entity['createdDate']) ? $entity['createdDate'] : null;

                    // override language if required
                    if ($languageField != null) {
                        $languageCode = $entity[$languageField];
                    }

                    $records[] = array(
                        'title' => $entity->getTitleFromDisplayPattern(),
                        'text' => $description,
                        'module' => $this->name,
                        'sesid' => $sessionId,
                        'created' => $created«IF hasUserDisplay»,
                        'url' => new ModUrl($this->name, 'user', 'display', $languageCode, $urlArgs)«ENDIF»
                    );
                }
            }

            return $records;
        }
    '''

    def private searchApiImpl(Application it) '''
        /**
         * Search api implementation class.
         */
        class «appName»_Api_Search extends «appName»_Api_Base_Search
        {
            // feel free to extend the search api here
        }
    '''

    def private searchHelperImpl(Application it) '''
        namespace «appNamespace»\Api;

        use «appNamespace»\Helper\Base\SearchHelper as BaseSearchHelper;

        /**
         * Search helper implementation class.
         */
        class SearchHelper extends BaseSearchHelper
        {
            // feel free to extend the search helper here
        }
    '''
}
