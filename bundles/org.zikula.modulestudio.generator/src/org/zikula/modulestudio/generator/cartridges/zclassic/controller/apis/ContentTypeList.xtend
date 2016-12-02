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
        «IF !isLegacy»
            namespace «appNamespace»\ContentType\Base;

            «IF hasCategorisableEntities»
                use CategoryUtil;
            «ENDIF»
            use ModUtil;
            use ServiceUtil;
            use ZLanguage;
            «IF needsFeatureActivationHelper»
                use «appNamespace»\Helper\FeatureActivationHelper;
            «ENDIF»

        «ENDIF»
        /**
         * Generic item list content plugin base class.
         */
        «IF isLegacy»
        abstract class «appName»_ContentType_Base_AbstractItemList extends Content_AbstractContentType
        «ELSE»
        abstract class AbstractItemList extends \Content_AbstractContentType
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
         * @return string The module name
         */
        public function getModule()
        {
            return '«appName»';
        }

        /**
         * Returns the name of this content type.
         *
         * @return string The content type name
         */
        public function getName()
        {
            return 'ItemList';
        }

        /**
         * Returns the title of this content type.
         *
         * @return string The content type title
         */
        public function getTitle()
        {
            «IF isLegacy»
                $dom = ZLanguage::getModuleDomain('«appName»');

                return __('«appName» list view', $dom);
            «ELSE»
                $serviceManager = ServiceUtil::getManager();

                return $serviceManager->get('translator.default')->__('«appName» list view');
            «ENDIF»
        }

        /**
         * Returns the description of this content type.
         *
         * @return string The content type description
         */
        public function getDescription()
        {
            «IF isLegacy»
                $dom = ZLanguage::getModuleDomain('«appName»');

                return __('Display list of «appName» objects.', $dom);
            «ELSE»
                $serviceManager = ServiceUtil::getManager();

                return $serviceManager->get('translator.default')->__('Display list of «appName» objects.');
            «ENDIF»
        }

        /**
         * Loads the data.
         *
         * @param array $data Data array with parameters
         */
        public function loadData(&$data)
        {
            $serviceManager = ServiceUtil::getManager();
            «IF isLegacy»
                $controllerHelper = new «appName»_Util_Controller($serviceManager);
            «ELSE»
                $controllerHelper = $serviceManager->get('«appService».controller_helper');
            «ENDIF»

            $utilArgs = «IF isLegacy»array(«ELSE»[«ENDIF»'name' => 'list'«IF isLegacy»)«ELSE»]«ENDIF»;
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
                $data['template'] = 'itemlist_' . $this->objectType . '_display.«IF isLegacy»tpl«ELSE»html.twig«ENDIF»';
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
                «IF !isLegacy»
                    $featureActivationHelper = $serviceManager->get('«appService».feature_activation_helper');
                    if ($featureActivationHelper->isEnabled(FeatureActivationHelper::CATEGORIES, $this->objectType)) {
                «ENDIF»
                $this->categorisableObjectTypes = «IF isLegacy»array(«ELSE»[«ENDIF»«FOR entity : getCategorisableEntities SEPARATOR ', '»'«entity.name.formatForCode»'«ENDFOR»«IF isLegacy»)«ELSE»]«ENDIF»;
                «IF !isLegacy»
                    $categoryHelper = $serviceManager->get('«appService».category_helper');
                «ENDIF»

                // fetch category properties
                $this->catRegistries = «IF isLegacy»array()«ELSE»[]«ENDIF»;
                $this->catProperties = «IF isLegacy»array()«ELSE»[]«ENDIF»;
                if (in_array($this->objectType, $this->categorisableObjectTypes)) {
                    «IF isLegacy»
                        $idFields = ModUtil::apiFunc('«appName»', 'selection', 'getIdFields', array('ot' => $this->objectType));
                        $this->catRegistries = ModUtil::apiFunc('«appName»', 'category', 'getAllPropertiesWithMainCat', array('ot' => $this->objectType, 'arraykey' => $idFields[0]));
                        $this->catProperties = ModUtil::apiFunc('«appName»', 'category', 'getAllProperties', array('ot' => $this->objectType));
                    «ELSE»
                        $selectionHelper = $serviceManager->get('«appService».selection_helper');
                        $idFields = $selectionHelper->getIdFields($this->objectType);
                        $this->catRegistries = $categoryHelper->getAllPropertiesWithMainCat($this->objectType, $idFields[0]);
                        $this->catProperties = $categoryHelper->getAllProperties($this->objectType);
                    «ENDIF»
                }

                if (!isset($data['catIds'])) {
                    «IF isLegacy»
                        $primaryRegistry = ModUtil::apiFunc('«appName»', 'category', 'getPrimaryProperty', «IF isLegacy»array(«ELSE»[«ENDIF»'ot' => $this->objectType«IF isLegacy»)«ELSE»]«ENDIF»);
                    «ELSE»
                        $primaryRegistry = $categoryHelper->getPrimaryProperty($this->objectType);
                    «ENDIF»
                    $data['catIds'] = «IF isLegacy»array($primaryRegistry => array())«ELSE»[$primaryRegistry => []]«ENDIF»;
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
                            $data['catIds'][$propName] = «IF isLegacy»array(«ELSE»[«ENDIF»$data['catIds'][$propName]«IF isLegacy»)«ELSE»]«ENDIF»;
                        } else {
                            $data['catIds'][$propName] = «IF isLegacy»array()«ELSE»[]«ENDIF»;
                        }
                    }
                }

                $this->catIds = $data['catIds'];
                «IF !isLegacy»
                    }
                «ENDIF»
            «ENDIF»
        }

        /**
         * Displays the data.
         *
         * @return string The returned output
         */
        public function display()
        {
            $dom = ZLanguage::getModuleDomain('«appName»');

            «IF isLegacy»
                ModUtil::initOOModule('«appName»');
                $entityClass = '«appName»_Entity_' . ucfirst($this->objectType);
            «ENDIF»
            $serviceManager = ServiceUtil::getManager();
            «IF isLegacy»
                $entityManager = $serviceManager->getService('«entityManagerService»');
                $repository = $entityManager->getRepository($entityClass);
            «ELSE»
                $repository = $serviceManager->get('«appService».' . $this->objectType . '_factory')->getRepository();
            «ENDIF»

            «IF isLegacy»
                // ensure that the view does not look for templates in the Content module (#218)
                $this->view->toplevelmodule = '«appName»';

            «ENDIF»
            «IF !isLegacy»
                $permissionApi = $serviceManager->get('zikula_permissions_module.api.permission');

            «ENDIF»
            «IF isLegacy»
                $this->view->setCaching(Zikula_View::CACHE_ENABLED);
                // set cache id
                $component = '«appName»:' . ucfirst($this->objectType) . ':';
                $instance = '::';
                $accessLevel = ACCESS_READ;
                if («IF isLegacy»SecurityUtil::check«ELSE»$permissionApi->has«ENDIF»Permission($component, $instance, ACCESS_COMMENT)) {
                    $accessLevel = ACCESS_COMMENT;
                }
                if («IF isLegacy»SecurityUtil::check«ELSE»$permissionApi->has«ENDIF»Permission($component, $instance, ACCESS_EDIT)) {
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

                «IF !isLegacy»
                    $featureActivationHelper = $serviceManager->get('«appService».feature_activation_helper');
                    if ($featureActivationHelper->isEnabled(FeatureActivationHelper::CATEGORIES, $this->objectType)) {
                «ENDIF»
                // apply category filters
                if (in_array($this->objectType, $this->categorisableObjectTypes)) {
                    if (is_array($this->catIds) && count($this->catIds) > 0) {
                        «IF isLegacy»
                            $qb = ModUtil::apiFunc('«appName»', 'category', 'buildFilterClauses', array('qb' => $qb, 'ot' => $this->objectType, 'catids' => $this->catIds));
                        «ELSE»
                            $categoryHelper = $serviceManager->get('«appService».category_helper');
                            $qb = $categoryHelper->buildFilterClauses($qb, $this->objectType, $this->catIds);
                        «ENDIF»
                    }
                }
                «IF !isLegacy»
                    }
                «ENDIF»
            «ENDIF»

            // get objects from database
            $currentPage = 1;
            $resultsPerPage = isset($this->amount) ? $this->amount : 1;
            list($query, $count) = $repository->getSelectWherePaginatedQuery($qb, $currentPage, $resultsPerPage);
            $entities = $repository->retrieveCollectionResult($query, $orderBy, true);
            «IF hasCategorisableEntities»

                «IF !isLegacy»
                if ($featureActivationHelper->isEnabled(FeatureActivationHelper::CATEGORIES, $this->objectType)) {
                «ENDIF»
                $filteredEntities = «IF isLegacy»array()«ELSE»[]«ENDIF»;
                foreach ($entities as $entity) {
                    if (CategoryUtil::hasCategoryAccess($entity['categories'], '«appName»', ACCESS_OVERVIEW)) {
                        $filteredEntities[] = $entity;
                    }
                }
                $entities = $filteredEntities;
                «IF !isLegacy»
                }
                «ENDIF»
            «ENDIF»

            $data = «IF isLegacy»array(«ELSE»[«ENDIF»
                'objectType' => $this->objectType,
                'catids' => $this->catIds,
                'sorting' => $this->sorting,
                'amount' => $this->amount,
                'template' => $this->template,
                'customTemplate' => $this->customTemplate,
                'filter' => $this->filter
            «IF isLegacy»)«ELSE»]«ENDIF»;

            «IF isLegacy»
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
                    'items' => $entities
                ];
                «IF hasCategorisableEntities»,
                    if ($featureActivationHelper->isEnabled(FeatureActivationHelper::CATEGORIES, $this->objectType)) {
                        $templateParameters['registries'] = $this->catRegistries;
                        $templateParameters['properties'] = $this->catProperties;
                    }
                «ENDIF»
                «IF hasUploads»
                    $imageHelper = $serviceManager->get('«appService».image_helper');
                «ENDIF»
                $templateParameters = array_merge($templateData, $repository->getAdditionalTemplateParameters(«IF hasUploads»$imageHelper, «ENDIF»'contentType'));

                $template = $this->getDisplayTemplate();

                $output = $serviceManager->get('twig')->render('@«appName»/' . $template, $templateParameters);
            «ENDIF»

            return $output;
        }

        /**
         * Returns the template used for output.
         *
         * @return string the template path
         */
        protected function getDisplayTemplate()
        {
            $templateFile = $this->template;
            if ($templateFile == 'custom') {
                $templateFile = $this->customTemplate;
            }

            $templateForObjectType = str_replace('itemlist_', 'itemlist_' . $this->objectType . '_', $templateFile);

            $template = '';
            if ($this->view->template_exists('«IF isLegacy»contenttype«ELSE»ContentType«ENDIF»/' . $templateForObjectType)) {
                $template = '«IF isLegacy»contenttype«ELSE»ContentType«ENDIF»/' . $templateForObjectType;
            } elseif ($this->view->template_exists('«IF isLegacy»contenttype«ELSE»ContentType«ENDIF»/' . $templateFile)) {
                $template = '«IF isLegacy»contenttype«ELSE»ContentType«ENDIF»/' . $templateFile;
            } else {
                $template = '«IF isLegacy»contenttype«ELSE»ContentType«ENDIF»/itemlist_display.«IF isLegacy»tpl«ELSE»html.twig«ENDIF»';
            }

            return $template;
        }

        /**
         * Determines the order by parameter for item selection.
         *
         * @param Doctrine_Repository $repository The repository used for data fetching
         *
         * @return string the sorting clause
         */
        protected function getSortParam($repository)
        {
            if ($this->sorting == 'random') {
                return 'RAND()';
            }

            $sortParam = '';
            if ($this->sorting == 'newest') {
                «IF isLegacy»
                    $idFields = ModUtil::apiFunc('«appName»', 'selection', 'getIdFields', array('ot' => $this->objectType));
                «ELSE»
                    $selectionHelper = ServiceUtil::get('«appService».selection_helper');
                    $idFields = $selectionHelper->getIdFields($this->objectType);
                «ENDIF»
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
         * @return array Default data and parameters
         */
        public function getDefaultData()
        {
            return «IF isLegacy»array(«ELSE»[«ENDIF»
                'objectType' => '«getLeadingEntity.name.formatForCode»',
                'sorting' => 'default',
                'amount' => 1,
                'template' => 'itemlist_display.«IF isLegacy»tpl«ELSE»html.twig«ENDIF»',
                'customTemplate' => '',
                'filter' => ''
            «IF isLegacy»)«ELSE»]«ENDIF»;
        }

        /**
         * Executes additional actions for the editing mode.
         */
        public function startEditing()
        {
            // ensure that the view does not look for templates in the Content module (#218)
            $this->view->toplevelmodule = '«appName»';

            // ensure our custom plugins are loaded
            «IF isLegacy»
                array_push($this->view->plugins_dir, '«rootFolder»/«appName»/templates/plugins');
            «ELSE»
                array_push($this->view->plugins_dir, '«rootFolder»/«if (systemModule) name.formatForCode else appName»/«getViewPath»/plugins');
            «ENDIF»
            «IF hasCategorisableEntities»

                «IF !isLegacy»
                    $featureActivationHelper = $serviceManager->get('«appService».feature_activation_helper');
                    if ($featureActivationHelper->isEnabled(FeatureActivationHelper::CATEGORIES, $this->objectType)) {
                «ENDIF»
                // assign category data
                $this->view->assign('registries', $this->catRegistries)
                           ->assign('properties', $this->catProperties);

                // assign categories lists for simulating category selectors
                «IF isLegacy»
                    $dom = ZLanguage::getModuleDomain('«appName»');
                    $locale = ZLanguage::getLanguageCode();
                «ELSE»
                    $serviceManager = ServiceUtil::getManager();
                    $translator = $serviceManager->get('translator.default');
                    $locale = $serviceManager->get('request_stack')->getMasterRequest()->getLocale();
                «ENDIF»
                $categories = «IF isLegacy»array()«ELSE»[]«ENDIF»;
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
                    $catsForDropdown = «IF isLegacy»array(«ELSE»[«ENDIF»
                        «IF isLegacy»array(«ELSE»[«ENDIF»'value' => '', 'text' => «IF !isLegacy»$translator->«ENDIF»__('All'«IF isLegacy», $dom«ENDIF»)«IF isLegacy»)«ELSE»]«ENDIF»
                    «IF isLegacy»)«ELSE»]«ENDIF»;
                    foreach ($cats as $cat) {
                        $catName = isset($cat['display_name'][$locale]) ? $cat['display_name'][$locale] : $cat['name'];
                        $catsForDropdown[] = «IF isLegacy»array(«ELSE»[«ENDIF»'value' => $cat['id'], 'text' => $catName«IF isLegacy»)«ELSE»]«ENDIF»;
                    }
                    $categories[$propName] = $catsForDropdown;
                }

                $this->view->assign('categories', $categories)«IF !isLegacy»
                           ->assign('categoryHelper', $serviceManager->get('«appService».category_helper'))«ENDIF»;
                «IF !isLegacy»
                    }
                «ENDIF»
            «ENDIF»
        }
    '''

    def private contentTypeImpl(Application it) '''
        «IF !isLegacy»
            namespace «appNamespace»\ContentType;

            use «appNamespace»\ContentType\Base\AbstractItemList;

        «ENDIF»
        /**
         * Generic item list content plugin implementation class.
         */
        «IF isLegacy»
        class «appName»_ContentType_ItemList extends «appName»_ContentType_Base_AbstractItemList
        «ELSE»
        class ItemList extends AbstractItemList
        «ENDIF»
        {
            // feel free to extend the content type here
        }
    '''

    def private isLegacy(Application it) {
        targets('1.3.x')
    }
}
