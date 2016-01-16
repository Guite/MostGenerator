package org.zikula.modulestudio.generator.cartridges.zclassic.controller.apis

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.cartridges.zclassic.view.additions.ContentTypeListView
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.GeneratorSettingsExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ContentTypeList {

    extension FormattingExtensions = new FormattingExtensions
    extension GeneratorSettingsExtensions = new GeneratorSettingsExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelExtensions = new ModelExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    FileHelper fh = new FileHelper

    def generate(Application it, IFileSystemAccess fsa) {
        println('Generating content type for multiple objects')
        generateClassPair(fsa, getAppSourceLibPath + 'ContentType/ItemList.php',
            fh.phpFileContent(it, contentTypeBaseClass), fh.phpFileContent(it, contentTypeImpl)
        )
        new ContentTypeListView().generate(it, fsa)
    }

    def private contentTypeBaseClass(Application it) '''
        «IF !targets('1.3.x')»
            namespace «appNamespace»\ContentType\Base;

            «IF hasCategorisableEntities»
                use CategoryUtil;
            «ENDIF»
            use ModUtil;
            use ServiceUtil;
            use ZLanguage;

        «ENDIF»
        /**
         * Generic item list content plugin base class.
         */
        «IF targets('1.3.x')»
        class «appName»_ContentType_Base_ItemList extends Content_AbstractContentType
        «ELSE»
        class ItemList extends \Content_AbstractContentType
        «ENDIF»
        {
            «contentTypeBaseImpl»
        }
    '''

    def private contentTypeBaseImpl(Application it) '''
        /**
         * The treated object type.
         *
         * @var string
         */
        protected $objectType;

        /**
         * The sorting criteria.
         *
         * @var string
         */
        protected $sorting;

        /**
         * The amount of desired items.
         *
         * @var integer
         */
        protected $amount;

        /**
         * Name of template file.
         *
         * @var string
         */
        protected $template;

        /**
         * Name of custom template file.
         *
         * @var string
         */
        protected $customTemplate;

        /**
         * Optional filters.
         *
         * @var string
         */
        protected $filter;
        «IF hasCategorisableEntities»

            /**
             * List of object types allowing categorisation.
             *
             * @var array
             */
            protected $categorisableObjectTypes;

            /**
             * List of category registries for different trees.
             *
             * @var array
             */
            protected $catRegistries;
            
            /**
             * List of category properties for different trees.
             *
             * @var array
             */
            protected $catProperties;

            /**
             * List of category ids with sub arrays for each registry.
             *
             * @var array
             */
            protected $catIds;
        «ENDIF»

        /**
         * Returns the module providing this content type.
         *
         * @return string The module name.
         */
        public function getModule()
        {
            return '«appName»';
        }

        /**
         * Returns the name of this content type.
         *
         * @return string The content type name.
         */
        public function getName()
        {
            return 'ItemList';
        }

        /**
         * Returns the title of this content type.
         *
         * @return string The content type title.
         */
        public function getTitle()
        {
            «IF targets('1.3.x')»
                $dom = ZLanguage::getModuleDomain('«appName»');

                return __('«appName» list view', $dom);
            «ELSE»
                $serviceManager = ServiceUtil::getManager();

                return $serviceManager->get('translator')->__('«appName» list view');
            «ENDIF»
        }

        /**
         * Returns the description of this content type.
         *
         * @return string The content type description.
         */
        public function getDescription()
        {
            «IF targets('1.3.x')»
                $dom = ZLanguage::getModuleDomain('«appName»');

                return __('Display list of «appName» objects.', $dom);
            «ELSE»
                $serviceManager = ServiceUtil::getManager();

                return $serviceManager->get('translator')->__('Display list of «appName» objects.');
            «ENDIF»
        }

        /**
         * Loads the data.
         *
         * @param array $data Data array with parameters.
         */
        public function loadData(&$data)
        {
            $serviceManager = ServiceUtil::getManager();
            «IF targets('1.3.x')»
                $controllerHelper = new «appName»_Util_Controller($serviceManager);
            «ELSE»
                $controllerHelper = $serviceManager->get('«appName.formatForDB».controller_helper');
            «ENDIF»

            $utilArgs = «IF targets('1.3.x')»array(«ELSE»[«ENDIF»'name' => 'list'«IF targets('1.3.x')»)«ELSE»]«ENDIF»;
            if (!isset($data['objectType']) || !in_array($data['objectType'], $controllerHelper->getObjectTypes('contentType', $utilArgs))) {
                $data['objectType'] = $controllerHelper->getDefaultObjectType('contentType', $utilArgs);
            }

            $this->objectType = $data['objectType'];

            if (!isset($data['sorting'])) {
                $data['sorting'] = 'default';
            }
            if (!isset($data['amount'])) {
                $data['amount'] = 1;
            }
            if (!isset($data['template'])) {
                $data['template'] = 'itemlist_' . $this->objectType . '_display.«IF targets('1.3.x')»tpl«ELSE»html.twig«ENDIF»';
            }
            if (!isset($data['customTemplate'])) {
                $data['customTemplate'] = '';
            }
            if (!isset($data['filter'])) {
                $data['filter'] = '';
            }

            $this->sorting = $data['sorting'];
            $this->amount = $data['amount'];
            $this->template = $data['template'];
            $this->customTemplate = $data['customTemplate'];
            $this->filter = $data['filter'];
            «IF hasCategorisableEntities»
                $this->categorisableObjectTypes = «IF targets('1.3.x')»array(«ELSE»[«ENDIF»«FOR entity : getCategorisableEntities SEPARATOR ', '»'«entity.name.formatForCode»'«ENDFOR»«IF targets('1.3.x')»)«ELSE»]«ENDIF»;

                // fetch category properties
                $this->catRegistries = «IF targets('1.3.x')»array()«ELSE»[]«ENDIF»;
                $this->catProperties = «IF targets('1.3.x')»array()«ELSE»[]«ENDIF»;
                if (in_array($this->objectType, $this->categorisableObjectTypes)) {
                    $idFields = ModUtil::apiFunc('«appName»', 'selection', 'getIdFields', «IF targets('1.3.x')»array(«ELSE»[«ENDIF»'ot' => $this->objectType«IF targets('1.3.x')»)«ELSE»]«ENDIF»);
                    $this->catRegistries = ModUtil::apiFunc('«appName»', 'category', 'getAllPropertiesWithMainCat', «IF targets('1.3.x')»array(«ELSE»[«ENDIF»'ot' => $this->objectType, 'arraykey' => $idFields[0]«IF targets('1.3.x')»)«ELSE»]«ENDIF»);
                    $this->catProperties = ModUtil::apiFunc('«appName»', 'category', 'getAllProperties', «IF targets('1.3.x')»array(«ELSE»[«ENDIF»'ot' => $this->objectType«IF targets('1.3.x')»)«ELSE»]«ENDIF»);
                }

                if (!isset($data['catIds'])) {
                    $primaryRegistry = ModUtil::apiFunc('«appName»', 'category', 'getPrimaryProperty', «IF targets('1.3.x')»array(«ELSE»[«ENDIF»'ot' => $this->objectType«IF targets('1.3.x')»)«ELSE»]«ENDIF»);
                    $data['catIds'] = «IF targets('1.3.x')»array($primaryRegistry => array())«ELSE»[$primaryRegistry => []]«ENDIF»;
                    // backwards compatibility
                    if (isset($data['catId'])) {
                        $data['catIds'][$primaryRegistry][] = $data['catId'];
                        unset($data['catId']);
                    }
                } elseif (!is_array($data['catIds'])) {
                    $data['catIds'] = explode(',', $data['catIds']);
                }

                foreach ($this->catRegistries as $registryId => $registryCid) {
                    $propName = '';
                    foreach ($this->catProperties as $propertyName => $propertyId) {
                        if ($propertyId == $registryId) {
                            $propName = $propertyName;
                            break;
                        }
                    }
                    if (isset($data['catids' . $propName])) {
                        $data['catIds'][$propName] = $data['catids' . $propName];
                    }
                    if (!is_array($data['catIds'][$propName])) {
                        if ($data['catIds'][$propName]) {
                            $data['catIds'][$propName] = «IF targets('1.3.x')»array(«ELSE»[«ENDIF»$data['catIds'][$propName]«IF targets('1.3.x')»)«ELSE»]«ENDIF»;
                        } else {
                            $data['catIds'][$propName] = «IF targets('1.3.x')»array()«ELSE»[]«ENDIF»;
                        }
                    }
                }

                $this->catIds = $data['catIds'];
            «ENDIF»
        }

        /**
         * Displays the data.
         *
         * @return string The returned output.
         */
        public function display()
        {
            $dom = ZLanguage::getModuleDomain('«appName»');

            «IF targets('1.3.x')»
                ModUtil::initOOModule('«appName»');
                $entityClass = '«appName»_Entity_' . ucfirst($this->objectType);
            «ENDIF»
            $serviceManager = ServiceUtil::getManager();
            «IF targets('1.3.x')»
                $entityManager = $serviceManager->get«IF targets('1.3.x')»Service«ENDIF»('doctrine.entitymanager');
                $repository = $entityManager->getRepository($entityClass);
            «ELSE»
                $repository = $serviceManager->get('«appName.formatForDB».' . $this->objectType . '_factory')->getRepository();
            «ENDIF»

            «IF targets('1.3.x')»
                // ensure that the view does not look for templates in the Content module (#218)
                $this->view->toplevelmodule = '«appName»';

            «ENDIF»
            «IF !targets('1.3.x')»
                $permissionHelper = $serviceManager->get('zikula_permissions_module.api.permission');

            «ENDIF»
            «IF targets('1.3.x')»
                $this->view->setCaching(Zikula_View::CACHE_ENABLED);
                // set cache id
                $component = '«appName»:' . ucfirst($this->objectType) . ':';
                $instance = '::';
                $accessLevel = ACCESS_READ;
                if («IF targets('1.3.x')»SecurityUtil::check«ELSE»$permissionHelper->has«ENDIF»Permission($component, $instance, ACCESS_COMMENT)) {
                    $accessLevel = ACCESS_COMMENT;
                }
                if («IF targets('1.3.x')»SecurityUtil::check«ELSE»$permissionHelper->has«ENDIF»Permission($component, $instance, ACCESS_EDIT)) {
                    $accessLevel = ACCESS_EDIT;
                }
                $this->view->setCacheId('view|ot_' . $this->objectType . '_sort_' . $this->sorting . '_amount_' . $this->amount . '_' . $accessLevel);

                $template = $this->getDisplayTemplate();

                // if page is cached return cached content
                if ($this->view->is_cached($template)) {
                    return $this->view->fetch($template);
                }

            «ENDIF»
            // create query
            $where = $this->filter;
            $orderBy = $this->getSortParam($repository);
            $qb = $repository->genericBaseQuery($where, $orderBy);
            «IF hasCategorisableEntities»

                // apply category filters
                if (in_array($this->objectType, $this->categorisableObjectTypes)) {
                    if (is_array($this->catIds) && count($this->catIds) > 0) {
                        $qb = ModUtil::apiFunc('«appName»', 'category', 'buildFilterClauses', «IF targets('1.3.x')»array(«ELSE»[«ENDIF»'qb' => $qb, 'ot' => $this->objectType, 'catids' => $this->catIds«IF targets('1.3.x')»)«ELSE»]«ENDIF»);
                    }
                }
            «ENDIF»

            // get objects from database
            $currentPage = 1;
            $resultsPerPage = (isset($this->amount) ? $this->amount : 1);
            list($query, $count) = $repository->getSelectWherePaginatedQuery($qb, $currentPage, $resultsPerPage);
            $entities = $repository->retrieveCollectionResult($query, $orderBy, true);

            $data = «IF targets('1.3.x')»array(«ELSE»[«ENDIF»
                'objectType' => $this->objectType,
                'catids' => $this->catIds,
                'sorting' => $this->sorting,
                'amount' => $this->amount,
                'template' => $this->template,
                'customTemplate' => $this->customTemplate,
                'filter' => $this->filter
            «IF targets('1.3.x')»)«ELSE»]«ENDIF»;

            «IF targets('1.3.x')»
                // assign vars and fetched data
                $this->view->assign('vars', $data)
                           ->assign('objectType', $this->objectType)
                           ->assign('items', $entities)
                           ->assign($repository->getAdditionalTemplateParameters('contentType'));
                «IF hasCategorisableEntities»

                    // assign category data
                    $this->view->assign('registries', $this->catRegistries);
                    $this->view->assign('properties', $this->catProperties);
                «ENDIF»

                $output = $this->view->fetch($template);
            «ELSE»
                $templateParameters = [
                    'vars' => $data,
                    'objectType' => $this->objectType,
                    'items' => $entities«IF hasCategorisableEntities»,
                    'registries' => $this->catRegistries,
                    'properties' => $this->catProperties«ENDIF»
                ];
                $templateParameters = array_merge($templateData, $repository->getAdditionalTemplateParameters('contentType'));

                $template = $this->getDisplayTemplate();

                $output = $serviceManager->get('twig')->render('@«appName»/' . $template, $templateParameters);
            «ENDIF»

            return $output;
        }

        /**
         * Returns the template used for output.
         *
         * @return string the template path.
         */
        protected function getDisplayTemplate()
        {
            $templateFile = $this->template;
            if ($templateFile == 'custom') {
                $templateFile = $this->customTemplate;
            }

            $templateForObjectType = str_replace('itemlist_', 'itemlist_' . $this->objectType . '_', $templateFile);

            $template = '';
            if ($this->view->template_exists('«IF targets('1.3.x')»contenttype«ELSE»ContentType«ENDIF»/' . $templateForObjectType)) {
                $template = '«IF targets('1.3.x')»contenttype«ELSE»ContentType«ENDIF»/' . $templateForObjectType;
            } elseif ($this->view->template_exists('«IF targets('1.3.x')»contenttype«ELSE»ContentType«ENDIF»/' . $templateFile)) {
                $template = '«IF targets('1.3.x')»contenttype«ELSE»ContentType«ENDIF»/' . $templateFile;
            } else {
                $template = '«IF targets('1.3.x')»contenttype«ELSE»ContentType«ENDIF»/itemlist_display.«IF targets('1.3.x')»tpl«ELSE»html.twig«ENDIF»';
            }

            return $template;
        }

        /**
         * Determines the order by parameter for item selection.
         *
         * @param Doctrine_Repository $repository The repository used for data fetching.
         *
         * @return string the sorting clause.
         */
        protected function getSortParam($repository)
        {
            if ($this->sorting == 'random') {
                return 'RAND()';
            }

            $sortParam = '';
            if ($this->sorting == 'newest') {
                $idFields = ModUtil::apiFunc('«appName»', 'selection', 'getIdFields', «IF targets('1.3.x')»array(«ELSE»[«ENDIF»'ot' => $this->objectType«IF targets('1.3.x')»)«ELSE»]«ENDIF»);
                if (count($idFields) == 1) {
                    $sortParam = $idFields[0] . ' DESC';
                } else {
                    foreach ($idFields as $idField) {
                        if (!empty($sortParam)) {
                            $sortParam .= ', ';
                        }
                        $sortParam .= $idField . ' DESC';
                    }
                }
            } elseif ($this->sorting == 'default') {
                $sortParam = $repository->getDefaultSortingField() . ' ASC';
            }

            return $sortParam;
        }

        /**
         * Displays the data for editing.
         */
        public function displayEditing()
        {
            return $this->display();
        }

        /**
         * Returns the default data.
         *
         * @return array Default data and parameters.
         */
        public function getDefaultData()
        {
            return «IF targets('1.3.x')»array(«ELSE»[«ENDIF»
                'objectType' => '«getLeadingEntity.name.formatForCode»',
                'sorting' => 'default',
                'amount' => 1,
                'template' => 'itemlist_display.«IF targets('1.3.x')»tpl«ELSE»html.twig«ENDIF»',
                'customTemplate' => '',
                'filter' => ''
            «IF targets('1.3.x')»)«ELSE»]«ENDIF»;
        }

        /**
         * Executes additional actions for the editing mode.
         */
        public function startEditing()
        {
            // ensure that the view does not look for templates in the Content module (#218)
            $this->view->toplevelmodule = '«appName»';

            // ensure our custom plugins are loaded
            «IF targets('1.3.x')»
                array_push($this->view->plugins_dir, '«rootFolder»/«appName»/templates/plugins');
            «ELSE»
                array_push($this->view->plugins_dir, '«rootFolder»/«if (systemModule) name.formatForCode else appName»/«getViewPath»»/plugins');
            «ENDIF»
            «IF hasCategorisableEntities»

                // assign category data
                $this->view->assign('registries', $this->catRegistries)
                           ->assign('properties', $this->catProperties);

                // assign categories lists for simulating category selectors
                «IF targets('1.3.x')»
                    $dom = ZLanguage::getModuleDomain('«appName»');
                «ELSE»
                    $serviceManager = ServiceUtil::getManager();
                    $translator = $serviceManager->get('translator');
                «ENDIF»
                $locale = ZLanguage::getLanguageCode();
                $categories = «IF targets('1.3.x')»array()«ELSE»[]«ENDIF»;
                foreach ($this->catRegistries as $registryId => $registryCid) {
                    $propName = '';
                    foreach ($this->catProperties as $propertyName => $propertyId) {
                        if ($propertyId == $registryId) {
                            $propName = $propertyName;
                            break;
                        }
                    }

                    //$mainCategory = CategoryUtil::getCategoryByID($registryCid);
                    $cats = CategoryUtil::getSubCategories($registryCid, true, true, false, true, false, null, '', null, 'sort_value');
                    $catsForDropdown = «IF targets('1.3.x')»array(«ELSE»[«ENDIF»
                        «IF targets('1.3.x')»array(«ELSE»[«ENDIF»'value' => '', 'text' => «IF !targets('1.3.x')»$translator->«ENDIF»__('All'«IF targets('1.3.x')», $dom«ENDIF»)«IF targets('1.3.x')»)«ELSE»]«ENDIF»
                    «IF targets('1.3.x')»)«ELSE»]«ENDIF»;
                    foreach ($cats as $cat) {
                        $catName = isset($cat['display_name'][$locale]) ? $cat['display_name'][$locale] : $cat['name'];
                        $catsForDropdown[] = «IF targets('1.3.x')»array(«ELSE»[«ENDIF»'value' => $cat['id'], 'text' => $catName«IF targets('1.3.x')»)«ELSE»]«ENDIF»;
                    }
                    $categories[$propName] = $catsForDropdown;
                }

                $this->view->assign('categories', $categories);
            «ENDIF»
        }
    '''

    def private contentTypeImpl(Application it) '''
        «IF !targets('1.3.x')»
            namespace «appNamespace»\ContentType;

            use «appNamespace»\ContentType\Base\ItemList as BaseItemList;

        «ENDIF»
        /**
         * Generic item list content plugin implementation class.
         */
        «IF targets('1.3.x')»
        class «appName»_ContentType_ItemList extends «appName»_ContentType_Base_ItemList
        «ELSE»
        class ItemList extends BaseItemList
        «ENDIF»
        {
            // feel free to extend the content type here
        }
    '''
}
