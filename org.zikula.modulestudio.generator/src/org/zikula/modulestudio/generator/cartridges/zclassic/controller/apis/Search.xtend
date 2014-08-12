package org.zikula.modulestudio.generator.cartridges.zclassic.controller.apis

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
    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    FileHelper fh = new FileHelper

    def generate(Application it, IFileSystemAccess fsa) {
        if (targets('1.3.5')) {
            generateClassPair(fsa, getAppSourceLibPath + 'Api/Search.php',
                fh.phpFileContent(it, searchApiBaseClass), fh.phpFileContent(it, searchApiImpl)
            )
        } else {
            generateClassPair(fsa, getAppSourceLibPath + 'Helper/SearchHelper.php',
                fh.phpFileContent(it, searchHelperBaseClass), fh.phpFileContent(it, searchHelperImpl)
            )
        }
        new SearchView().generate(it, fsa)
    }

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
        namespace «appNamespace»\Helper\Base;

        use ModUtil;
        use SecurityUtil;
        use ServiceUtil;
        use ZLanguage;

        use Zikula\Core\ModUrl;
        use Zikula\Module\SearchModule\AbstractSearchable;

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

            «FOR entity : entities.filter[hasAbstractStringFieldsEntity]»
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

            «FOR entity : entities.filter[hasAbstractStringFieldsEntity]»
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
            «IF targets('1.3.5')»
                $entityManager = ServiceUtil::get«IF targets('1.3.5')»Service«ENDIF»('doctrine.entitymanager');
            «ENDIF»
            $currentPage = 1;
            $resultsPerPage = 50;

            foreach ($searchTypes as $objectType) {
                if (!in_array($objectType, $allowedTypes)) {
                    continue;
                }

                $whereArray = array();
                $languageField = null;
                switch ($objectType) {
                    «FOR entity : entities.filter[hasAbstractStringFieldsEntity]»
                        case '«entity.name.formatForCode»':
                            «FOR field : entity.getAbstractStringFieldsEntity»
                                $whereArray[] = 'tbl.«field.name.formatForCode»';
                            «ENDFOR»
                            «IF entity.hasLanguageFieldsEntity»
                                $languageField = '«entity.getLanguageFieldsEntity.head.name.formatForCode»';
                            «ENDIF»
                            break;
                    «ENDFOR»
                }
                $where = Search_Api_User::construct_where($args, $whereArray, $languageField);

                $entityClass = $this->name . '_Entity_' . ucfirst($objectType);
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
                        $urlArgs = $entity->createUrlArgs();
                    «ENDIF»
                    $instanceId = $entity->createCompositeIdentifier();
                    «IF hasUserDisplay»
                        // could exceed the maximum length of the 'extra' field, improved in 1.4.0
                        if (isset($urlArgs['slug'])) {
                            unset($urlArgs['slug']);
                        }
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

            $serviceManager = ServiceUtil::getManager();

            // save session id as it is used when inserting search results below
            $session = $serviceManager->get('session');
            $sessionId = $session->getId();

            // save current language
            $languageCode = ZLanguage::getLanguageCode();

            // initialise array for results
            $records = array();

            // retrieve list of activated object types
            $searchTypes = isset($modVars['objectTypes']) ? (array)$modVars['objectTypes'] : array();

            $controllerHelper = $serviceManager->get('«appName.formatForDB».controller_helper');
            $utilArgs = array('helper' => 'search', 'action' => 'getResults');
            $allowedTypes = $controllerHelper->getObjectTypes('helper', $utilArgs);

            foreach ($searchTypes as $objectType) {
                if (!in_array($objectType, $allowedTypes)) {
                    continue;
                }

                $whereArray = array();
                $languageField = null;
                switch ($objectType) {
                    «FOR entity : entities.filter[hasAbstractStringFieldsEntity]»
                        case '«entity.name.formatForCode»':
                            «FOR field : entity.getAbstractStringFieldsEntity»
                                $whereArray[] = 'tbl.«field.name.formatForCode»';
                            «ENDFOR»
                            «IF entity.hasLanguageFieldsEntity»
                                $languageField = '«entity.getLanguageFieldsEntity.head.name.formatForCode»';
                            «ENDIF»
                            break;
                    «ENDFOR»
                }

                $repository = $serviceManager->get('«appName.formatForDB».' . $objectType . '_factory')->getRepository();

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
                        $urlArgs = $entity->createUrlArgs();
                    «ENDIF»
                    $instanceId = $entity->createCompositeIdentifier();

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
                        'url' => new ModUrl($this->name, $objectType, 'display', $languageCode, $urlArgs)«ENDIF»
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
        namespace «appNamespace»\Helper;

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
