package org.zikula.modulestudio.generator.cartridges.zclassic.controller.additions

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.cartridges.zclassic.view.additions.ContentTypeListView
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ContentTypeList {

    extension FormattingExtensions = new FormattingExtensions
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
        namespace «appNamespace»\ContentType\Base;

        use ServiceUtil;
        «IF needsFeatureActivationHelper»
            use «appNamespace»\Helper\FeatureActivationHelper;
        «ENDIF»

        /**
         * Generic item list content plugin base class.
         */
        abstract class AbstractItemList extends \Content_AbstractContentType
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
            return ServiceUtil::get('translator.default')->__('«appName» list view');
        }

        /**
         * Returns the description of this content type.
         *
         * @return string The content type description
         */
        public function getDescription()
        {
            return ServiceUtil::get('translator.default')->__('Display list of «appName» objects.');
        }

        /**
         * Loads the data.
         *
         * @param array $data Data array with parameters
         */
        public function loadData(&$data)
        {
            $serviceManager = ServiceUtil::getManager();
            $controllerHelper = $serviceManager->get('«appService».controller_helper');

            $utilArgs = ['name' => 'list'];
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
                $data['template'] = 'itemlist_' . $this->objectType . '_display.html.twig';
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
                $featureActivationHelper = $serviceManager->get('«appService».feature_activation_helper');
                if ($featureActivationHelper->isEnabled(FeatureActivationHelper::CATEGORIES, $this->objectType)) {
                    $this->categorisableObjectTypes = [«FOR entity : getCategorisableEntities SEPARATOR ', '»'«entity.name.formatForCode»'«ENDFOR»];
                    $categoryHelper = $serviceManager->get('«appService».category_helper');

                    // fetch category properties
                    $this->catRegistries = [];
                    $this->catProperties = [];
                    if (in_array($this->objectType, $this->categorisableObjectTypes)) {
                        $selectionHelper = $serviceManager->get('«appService».selection_helper');
                        $idFields = $selectionHelper->getIdFields($this->objectType);
                        $this->catRegistries = $categoryHelper->getAllPropertiesWithMainCat($this->objectType, $idFields[0]);
                        $this->catProperties = $categoryHelper->getAllProperties($this->objectType);
                    }

                    if (!isset($data['catIds'])) {
                        $primaryRegistry = $categoryHelper->getPrimaryProperty($this->objectType);
                        $data['catIds'] = [$primaryRegistry => []];
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
                                $data['catIds'][$propName] = [$data['catIds'][$propName]];
                            } else {
                                $data['catIds'][$propName] = [];
                            }
                        }
                    }

                    $this->catIds = $data['catIds'];
                }
            «ENDIF»
        }

        /**
         * Displays the data.
         *
         * @return string The returned output
         */
        public function display()
        {
            $serviceManager = ServiceUtil::getManager();
            $repository = $serviceManager->get('«appService».' . $this->objectType . '_factory')->getRepository();
            $permissionApi = $serviceManager->get('zikula_permissions_module.api.permission');

            // create query
            $where = $this->filter;
            $orderBy = $this->getSortParam($repository);
            $qb = $repository->genericBaseQuery($where, $orderBy);
            «IF hasCategorisableEntities»

                $featureActivationHelper = $serviceManager->get('«appService».feature_activation_helper');
                if ($featureActivationHelper->isEnabled(FeatureActivationHelper::CATEGORIES, $this->objectType)) {
                    // apply category filters
                    if (in_array($this->objectType, $this->categorisableObjectTypes)) {
                        if (is_array($this->catIds) && count($this->catIds) > 0) {
                            $categoryHelper = $serviceManager->get('«appService».category_helper');
                            $qb = $categoryHelper->buildFilterClauses($qb, $this->objectType, $this->catIds);
                        }
                    }
                }
            «ENDIF»

            // get objects from database
            $currentPage = 1;
            $resultsPerPage = isset($this->amount) ? $this->amount : 1;
            $query = $repository->getSelectWherePaginatedQuery($qb, $currentPage, $resultsPerPage);
            list($entities, $objectCount) = $repository->retrieveCollectionResult($query, $orderBy, true);
            «IF hasCategorisableEntities»

                if ($featureActivationHelper->isEnabled(FeatureActivationHelper::CATEGORIES, $this->objectType)) {
                    $entities = $categoryHelper->filterEntitiesByPermission($entities);
                }
            «ENDIF»

            $data = [
                'objectType' => $this->objectType,
                'catids' => $this->catIds,
                'sorting' => $this->sorting,
                'amount' => $this->amount,
                'template' => $this->template,
                'customTemplate' => $this->customTemplate,
                'filter' => $this->filter
            ];

            $templateParameters = [
                'vars' => $data,
                'objectType' => $this->objectType,
                'items' => $entities
            ];
            «IF hasCategorisableEntities»

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

            return $serviceManager->get('twig')->render('@«appName»/' . $template, $templateParameters);
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
            if ($this->view->template_exists('ContentType/' . $templateForObjectType)) {
                $template = 'ContentType/' . $templateForObjectType;
            } elseif ($this->view->template_exists('ContentType/' . $templateFile)) {
                $template = 'ContentType/' . $templateFile;
            } else {
                $template = 'ContentType/itemlist_display.html.twig';
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
                $selectionHelper = ServiceUtil::get('«appService».selection_helper');
                $idFields = $selectionHelper->getIdFields($this->objectType);
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
            return [
                'objectType' => '«getLeadingEntity.name.formatForCode»',
                'sorting' => 'default',
                'amount' => 1,
                'template' => 'itemlist_display.html.twig',
                'customTemplate' => '',
                'filter' => ''
            ];
        }

        /**
         * Executes additional actions for the editing mode.
         */
        public function startEditing()
        {
            // ensure that the view does not look for templates in the Content module (#218)
            $this->view->toplevelmodule = '«appName»';

            // ensure our custom plugins are loaded
            array_push($this->view->plugins_dir, '«relativeAppRootPath»/«getViewPath»/plugins');
            «IF hasCategorisableEntities»

                $featureActivationHelper = $serviceManager->get('«appService».feature_activation_helper');
                if ($featureActivationHelper->isEnabled(FeatureActivationHelper::CATEGORIES, $this->objectType)) {
                    // assign category data
                    $this->view->assign('registries', $this->catRegistries)
                               ->assign('properties', $this->catProperties);

                    // assign categories lists for simulating category selectors
                    $serviceManager = ServiceUtil::getManager();
                    $translator = $serviceManager->get('translator.default');
                    $locale = $serviceManager->get('request_stack')->getMasterRequest()->getLocale();
                    $categories = [];
                    $categoryApi = $serviceManager->get('zikula_categories_module.api.category');
                    foreach ($this->catRegistries as $registryId => $registryCid) {
                        $propName = '';
                        foreach ($this->catProperties as $propertyName => $propertyId) {
                            if ($propertyId == $registryId) {
                                $propName = $propertyName;
                                break;
                            }
                        }

                        //$mainCategory = $categoryApi->getCategoryById($registryCid);
                        $cats = $categoryApi->getSubCategories($registryCid, true, true, false, true, false, null, '', null, 'sort_value');
                        $catsForDropdown = [
                            ['value' => '', 'text' => $translator->__('All')]
                        ];
                        foreach ($cats as $cat) {
                            $catName = isset($cat['display_name'][$locale]) ? $cat['display_name'][$locale] : $cat['name'];
                            $catsForDropdown[] = ['value' => $cat['id'], 'text' => $catName];
                        }
                        $categories[$propName] = $catsForDropdown;
                    }

                    $this->view->assign('categories', $categories)
                               ->assign('categoryHelper', $serviceManager->get('«appService».category_helper'));
                }
            «ENDIF»
        }

        /**
         * Returns the edit template path.
         *
         * @return string
         */
        public function getEditTemplate()
        {
            $absoluteTemplatePath = str_replace('ContentType/Base/AbstractItemList.php', 'Resources/views/ContentType/itemlist_edit.tpl', __FILE__);

            return 'file:' . $absoluteTemplatePath;
        }
    '''

    def private contentTypeImpl(Application it) '''
        namespace «appNamespace»\ContentType;

        use «appNamespace»\ContentType\Base\AbstractItemList;

        /**
         * Generic item list content plugin implementation class.
         */
        class ItemList extends AbstractItemList
        {
            // feel free to extend the content type here
        }
    '''
}
