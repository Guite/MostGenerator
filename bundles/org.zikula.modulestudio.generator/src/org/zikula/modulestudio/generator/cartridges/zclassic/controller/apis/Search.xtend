package org.zikula.modulestudio.generator.cartridges.zclassic.controller.apis

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.cartridges.zclassic.view.additions.SearchView
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Search {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelExtensions = new ModelExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    FileHelper fh = new FileHelper

    def generate(Application it, IFileSystemAccess fsa) {
        if (targets('1.3.x')) {
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
        abstract class «appName»_Api_Base_AbstractSearch extends Zikula_AbstractApi
        {
            «searchApiBaseImpl»
        }
    '''

    def private searchHelperBaseClass(Application it) '''
        namespace «appNamespace»\Helper\Base;

        «IF hasCategorisableEntities && !targets('1.4-dev')»
            use CategoryUtil;
        «ENDIF»
        use ServiceUtil;
        use Zikula\Core\RouteUrl;
        use Zikula\SearchModule\AbstractSearchable;
        «IF hasCategorisableEntities»
            use «appNamespace»\Helper\FeatureActivationHelper;
        «ENDIF»

        /**
         * Search helper base class.
         */
        abstract class AbstractSearchHelper extends AbstractSearchable
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

    // 1.3.x only
    def private infoLegacy(Application it) '''
        /**
         * Get search plugin information.
         *
         * @return array The search plugin information
         */
        public function info()
        {
            return array(
                'title'     => $this->name,
                'functions' => array($this->name => 'search')
            );
        }
    '''

    // 1.3.x only
    def private optionsLegacy(Application it) '''
        «val entitiesWithStrings = entities.filter[hasAbstractStringFieldsEntity]»
        /**
         * Display the search form.
         *
         * @param array $args List of arguments
         *
         * @return string Template output
         */
        public function options(array $args = array())
        {
            if (!SecurityUtil::checkPermission($this->name . '::', '::', ACCESS_READ)) {
                return '';
            }

            $view = Zikula_View::getInstance($this->name);

            $searchTypes = array(«FOR entity : entitiesWithStrings»'«entity.name.formatForCode»'«IF entity != entitiesWithStrings.last», «ENDIF»«ENDFOR»);
            foreach ($searchTypes as $searchType) {
                $view->assign('active_' . $searchType, (!isset($args['«appName.toFirstLower»SearchTypes']) || in_array($searchType, $args['«appName.toFirstLower»SearchTypes'])));
            }

            return $view->fetch('search/options.tpl');
        }
    '''

    def private getOptions(Application it) '''
        «val entitiesWithStrings = entities.filter[hasAbstractStringFieldsEntity]»
        /**
         * Display the search form.
         *
         * @param boolean    $active  if the module should be checked as active
         * @param array|null $modVars module form vars as previously set
         *
         * @return string Template output
         */
        public function getOptions($active, $modVars = null)
        {
            $serviceManager = ServiceUtil::getManager();
            $permissionApi = $serviceManager->get('zikula_permissions_module.api.permission');

            if (!$permissionApi->hasPermission($this->name . '::', '::', ACCESS_READ)) {
                return '';
            }

            $templateParameters = [];

            $searchTypes = array(«FOR entity : entitiesWithStrings»'«entity.name.formatForCode»'«IF entity != entitiesWithStrings.last», «ENDIF»«ENDFOR»);
            foreach ($searchTypes as $searchType) {
                $templateParameters['active_' . $searchType] = (!isset($args['«appName.toFirstLower»SearchTypes']) || in_array($searchType, $args['«appName.toFirstLower»SearchTypes']));
            }

            return $this->getContainer()->get('twig')->render('@«appName»/Search/options.html.twig', $templateParameters);
        }
    '''

    // 1.3.x only
    def private searchLegacy(Application it) '''
        /**
         * Executes the actual search process.
         *
         * @param array $args List of arguments
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
            $entityManager = ServiceUtil::get«IF targets('1.3.x')»Service«ENDIF»('«entityManagerService»');
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

                $descriptionField = $repository->getDescriptionFieldName();

                $entitiesWithDisplayAction = array(«FOR entity : getAllEntities.filter[hasActions('display')] SEPARATOR ', '»'«entity.name.formatForCode»'«ENDFOR»);

                foreach ($entities as $entity) {
                    $urlArgs = $entity->createUrlArgs();
                    $hasDisplayAction = in_array($objectType, $entitiesWithDisplayAction);

                    if ($hasDisplayAction) {
                        $urlArgs['type'] = $objectType;
                        // slug could exceed the maximum length of the 'extra' field, improved in 1.4.0
                        if (isset($urlArgs['slug'])) {
                            unset($urlArgs['slug']);
                        }
                    }

                    $instanceId = $entity->createCompositeIdentifier();

                    // perform permission check
                    if (!SecurityUtil::checkPermission($this->name . ':' . ucfirst($objectType) . ':', $instanceId . '::', ACCESS_OVERVIEW)) {
                        continue;
                    }
                    «IF hasCategorisableEntities»
                        if (in_array($objectType, array('«getCategorisableEntities.map[e|e.name.formatForCode].join('\', \'')»'))) {
                            if (!CategoryUtil::hasCategoryAccess($entity['categories'], '«appName»', ACCESS_OVERVIEW)) {
                                continue;
                            }
                        }
                    «ENDIF»

                    $title = $entity->getTitleFromDisplayPattern();
                    $description = !empty($descriptionField) ? $entity[$descriptionField] : '';
                    $created = isset($entity['createdDate']) ? $entity['createdDate']->format('Y-m-d H:i:s') : '';

                    $searchItemData = array(
                        'title'   => $title,
                        'text'    => $description,
                        'extra'   => $hasDisplayAction ? serialize($urlArgs) : '',
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

    // 1.3.x only
    def private searchCheckLegacy(Application it) '''
        /**
         * Assign URL to items.
         *
         * @param array $args List of arguments
         *
         * @return boolean
         */
        public function search_check(array $args = array())
        {
            $datarow = &$args['datarow'];
            if ($datarow['extra'] != '') {
                $urlArgs = unserialize($datarow['extra']);
                $objectType = $urlArgs['type'];
                unset($urlArgs['type']);
                if (in_array($objectType, array(«FOR entity : getAllEntities.filter[hasActions('display')] SEPARATOR ', '»'«entity.name.formatForCode»'«ENDFOR»))) {
                    $datarow['url'] = ModUtil::url($this->name, $objectType, 'display', $urlArgs);
                }
            }

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
         * @return array List of fetched results
         */
        public function getResults(array $words, $searchType = 'AND', $modVars = null)
        {
            $serviceManager = ServiceUtil::getManager();
            $permissionApi = $serviceManager->get('zikula_permissions_module.api.permission');
            «IF hasCategorisableEntities»
                $featureActivationHelper = $serviceManager('«appService».feature_activation_helper');
            «ENDIF»
            $request = $serviceManager->get('request_stack')->getMasterRequest();

            if (!$permissionApi->hasPermission($this->name . '::', '::', ACCESS_READ)) {
                return [];
            }

            // save session id as it is used when inserting search results below
            $session = $serviceManager->get('session');
            $sessionId = $session->getId();

            // initialise array for results
            $records = [];

            // retrieve list of activated object types
            $searchTypes = isset($modVars['objectTypes']) ? (array)$modVars['objectTypes'] : [];
            if (!is_array($searchTypes) || !count($searchTypes)) {
                if ($request->isMethod('GET')) {
                    $searchTypes = $request->query->get('«appName.toFirstLower»SearchTypes', []);
                } elseif ($request->isMethod('POST')) {
                    $searchTypes = $request->request->get('«appName.toFirstLower»SearchTypes', []);
                }
            }

            $controllerHelper = $serviceManager->get('«appService».controller_helper');
            $utilArgs = ['helper' => 'search', 'action' => 'getResults'];
            $allowedTypes = $controllerHelper->getObjectTypes('helper', $utilArgs);

            foreach ($searchTypes as $objectType) {
                if (!in_array($objectType, $allowedTypes)) {
                    continue;
                }

                $whereArray = [];
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

                $repository = $serviceManager->get('«appService».' . $objectType . '_factory')->getRepository();

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

                $descriptionField = $repository->getDescriptionFieldName();

                $entitiesWithDisplayAction = [«FOR entity : getAllEntities.filter[hasActions('display')] SEPARATOR ', '»'«entity.name.formatForCode»'«ENDFOR»];
                «IF targets('1.4-dev')»
                    $categoryPermissionApi = $serviceManager->get('zikula_categories_module.api.category_permission');
                «ENDIF»

                foreach ($entities as $entity) {
                    $urlArgs = $entity->createUrlArgs();
                    $hasDisplayAction = in_array($objectType, $entitiesWithDisplayAction);

                    $instanceId = $entity->createCompositeIdentifier();
                    // perform permission check
                    if (!$permissionApi->hasPermission($this->name . ':' . ucfirst($objectType) . ':', $instanceId . '::', ACCESS_OVERVIEW)) {
                        continue;
                    }
                    «IF hasCategorisableEntities»
                        if (in_array($objectType, ['«getCategorisableEntities.map[e|e.name.formatForCode].join('\', \'')»'])) {
                            if ($featureActivationHelper->isEnabled(FeatureActivationHelper::CATEGORIES, $objectType)) {
                                «IF targets('1.4-dev')»
                                    if (!$categoryPermissionApi->hasCategoryAccess($entity['categories'], '«appName»', ACCESS_OVERVIEW)) {
                                        continue;
                                    }
                                «ELSE»
                                    if (!CategoryUtil::hasCategoryAccess($entity['categories'], '«appName»', ACCESS_OVERVIEW)) {
                                        continue;
                                    }
                                «ENDIF»
                            }
                        }
                    «ENDIF»

                    $description = !empty($descriptionField) ? $entity[$descriptionField] : '';
                    $created = isset($entity['createdDate']) ? $entity['createdDate'] : null;

                    $urlArgs['_locale'] = (null !== $languageField && !empty($entity[$languageField])) ? $entity[$languageField] : $request->getLocale();

                    $displayUrl = $hasDisplayAction ? new RouteUrl('«appName.formatForDB»_' . $objectType . '_display', $urlArgs) : '';

                    $records[] = [
                        'title' => $entity->getTitleFromDisplayPattern(),
                        'text' => $description,
                        'module' => $this->name,
                        'sesid' => $sessionId,
                        'created' => $created,
                        'url' => $displayUrl
                    ];
                }
            }

            return $records;
        }
    '''

    def private searchApiImpl(Application it) '''
        /**
         * Search api implementation class.
         */
        class «appName»_Api_Search extends «appName»_Api_Base_AbstractSearch
        {
            // feel free to extend the search api here
        }
    '''

    def private searchHelperImpl(Application it) '''
        namespace «appNamespace»\Helper;

        use «appNamespace»\Helper\Base\AbstractSearchHelper;

        /**
         * Search helper implementation class.
         */
        class SearchHelper extends AbstractSearchHelper
        {
            // feel free to extend the search helper here
        }
    '''
}
