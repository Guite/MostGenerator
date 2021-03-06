package org.zikula.modulestudio.generator.cartridges.zclassic.controller.additions

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.formtype.ContentTypeListType
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

    def generate(Application it, IMostFileSystemAccess fsa) {
        if (!generateListContentType) {
            return
        }
        'Generating content type for multiple objects'.printIfNotTesting(fsa)
        if (targets('2.0')) {
            fsa.generateClassPair('ContentType/ItemListType.php', contentTypeBaseClass, contentTypeImpl)
            new ContentTypeListType().generate(it, fsa)
        } else {
            fsa.generateClassPair('ContentType/ItemList.php', contentTypeLegacyBaseClass, contentTypeLegacyImpl)
        }
        new ContentTypeListView().generate(it, fsa)
    }

    def private contentTypeBaseClass(Application it) '''
        namespace «appNamespace»\ContentType\Base;

        «IF targets('3.0')»
            use Zikula\ExtensionsModule\ModuleInterface\Content\AbstractContentType;
        «ELSE»
            use Zikula\Common\Content\AbstractContentType;
        «ENDIF»
        use «appNamespace»\ContentType\Form\Type\ItemListType as FormType;
        use «appNamespace»\Entity\Factory\EntityFactory;
        «IF hasCategorisableEntities»
            use «appNamespace»\Helper\CategoryHelper;
        «ENDIF»
        use «appNamespace»\Helper\ControllerHelper;
        «IF hasCategorisableEntities»
            use «appNamespace»\Helper\FeatureActivationHelper;
        «ENDIF»
        use «appNamespace»\Helper\ModelHelper;
        use «appNamespace»\Helper\PermissionHelper;

        /**
         * Generic item list content type base class.
         */
        abstract class AbstractItemListType extends AbstractContentType
        {
            «contentTypeBaseImpl»
        }
    '''

    def private contentTypeLegacyBaseClass(Application it) '''
        namespace «appNamespace»\ContentType\Base;

        use Symfony\Component\DependencyInjection\ContainerAwareInterface;
        use Symfony\Component\DependencyInjection\ContainerAwareTrait;
        «IF hasCategorisableEntities»
            use «appNamespace»\Helper\FeatureActivationHelper;
        «ENDIF»

        /**
         * Generic item list content type base class.
         */
        abstract class AbstractItemList extends \Content_AbstractContentType implements ContainerAwareInterface
        {
            use ContainerAwareTrait;

            «contentTypeBaseLegacyImpl»
        }
    '''

    def private contentTypeBaseImpl(Application it) '''
        /**
         * @var ControllerHelper
         */
        protected $controllerHelper;

        /**
         * @var ModelHelper
         */
        protected $modelHelper;

        /**
         * @var PermissionHelper
         */
        protected $modulePermissionHelper;

        /**
         * @var EntityFactory
         */
        protected $entityFactory;

        «IF hasCategorisableEntities»
            /**
             * @var FeatureActivationHelper
             */
            protected $featureActivationHelper;

            /**
             * @var CategoryHelper
             */
            protected $categoryHelper;

            /**
             * List of object types allowing categorisation.
             *
             * @var array
             */
            protected $categorisableObjectTypes;

        «ENDIF»
        public function getIcon()«IF targets('3.0')»: string«ENDIF»
        {
            return 'th-list';
        }

        public function getTitle()«IF targets('3.0')»: string«ENDIF»
        {
            return $this->translator->«IF targets('3.0')»trans«ELSE»__«ENDIF»('«name.formatForDisplayCapital» list'«IF !targets('3.0')», '«appName.formatForDB»'«ENDIF»);
        }

        public function getDescription()«IF targets('3.0')»: string«ENDIF»
        {
            return $this->translator->«IF targets('3.0')»trans«ELSE»__«ENDIF»('Display a list of «name.formatForDisplay» objects.'«IF !targets('3.0')», '«appName.formatForDB»'«ENDIF»);
        }

        public function getDefaultData()«IF targets('3.0')»: array«ENDIF»
        {
            return [
                'objectType' => '«getLeadingEntity.name.formatForCode»',
                'sorting' => 'default',
                'amount' => 1,
                'template' => 'itemlist_display.html.twig',
                'customTemplate' => null,
                'filter' => '',
            ];
        }

        public function getData()«IF targets('3.0')»: array«ENDIF»
        {
            $data = parent::getData();

            «IF !isSystemModule»
                $contextArgs = ['name' => 'list'];
            «ENDIF»
            $allowedObjectTypes = $this->controllerHelper->getObjectTypes('contentType'«IF !isSystemModule», $contextArgs«ENDIF»);
            if (
                !isset($data['objectType'])
                || !in_array($data['objectType'], $allowedObjectTypes, true)
            ) {
                $data['objectType'] = $this->controllerHelper->getDefaultObjectType('contentType'«IF !isSystemModule», $contextArgs«ENDIF»);
            }

            if (!isset($data['template'])) {
                $data['template'] = 'itemlist_' . $data['objectType'] . '_display.html.twig';
            }
            «IF hasCategorisableEntities»

                $objectType = $data['objectType'];
                $this->categorisableObjectTypes = [«FOR entity : getCategorisableEntities SEPARATOR ', '»'«entity.name.formatForCode»'«ENDFOR»];
                if ($this->featureActivationHelper->isEnabled(FeatureActivationHelper::CATEGORIES, $objectType)) {
                    $primaryRegistry = $this->categoryHelper->getPrimaryProperty($objectType);
                    if (!isset($data['categories'])) {
                        $data['categories'] = [$primaryRegistry => []];
                    } else {
                        if (!is_array($data['categories'])) {
                            $data['categories'] = explode(',', $data['categories']);
                        }
                        if (count($data['categories']) > 0) {
                            $firstCategories = reset($data['categories']);
                            if (!is_array($firstCategories)) {
                                $firstCategories = [$firstCategories];
                            }
                            $data['categories'] = [$primaryRegistry => $firstCategories];
                        }
                    }
                }
            «ENDIF»
            $this->data = $data;

            return $data;
        }

        public function displayView()«IF targets('3.0')»: string«ENDIF»
        {
            $objectType = $this->data['objectType'];
            $repository = $this->entityFactory->getRepository($objectType);

            // create query
            $orderBy = $this->modelHelper->resolveSortParameter($this->data['objectType'], $this->data['sorting']);
            $qb = $repository->getListQueryBuilder($this->data['filter'] ?? '', $orderBy);
            «IF hasCategorisableEntities»

                $this->getData();
                if (in_array($objectType, $this->categorisableObjectTypes, true)) {
                    if ($this->featureActivationHelper->isEnabled(FeatureActivationHelper::CATEGORIES, $objectType)) {
                        // apply category filters
                        if (is_array($this->data['categories']) && count($this->data['categories']) > 0) {
                            $qb = $this->categoryHelper->buildFilterClauses($qb, $objectType, $this->data['categories']);
                        }
                    }
                }
            «ENDIF»

            // get objects from database
            $currentPage = 1;
            $resultsPerPage = isset($this->data['amount']) ? $this->data['amount'] : 1;
            «IF targets('3.0')»
                $paginator = $repository->retrieveCollectionResult($qb, true, $currentPage, $resultsPerPage);
                $entities = $paginator->getResults();
            «ELSE»
                $query = $repository->getSelectWherePaginatedQuery($qb, $currentPage, $resultsPerPage);
                try {
                    list($entities, $objectCount) = $repository->retrieveCollectionResult($query, true);
                } catch (\Exception $exception) {
                    $entities = [];
                    $objectCount = 0;
                }
            «ENDIF»

            // filter by permissions
            $entities = $this->modulePermissionHelper->filterCollection(«IF !isSystemModule»$objectType, «ENDIF»$entities, ACCESS_READ);

            $data = $this->data;
            $data['items'] = $entities;

            $data = $this->controllerHelper->addTemplateParameters($objectType, $data, 'contentType', []);
            $this->data = $data;

            return parent::displayView();
        }

        public function getViewTemplatePath(«IF targets('3.0')»string «ENDIF»$suffix = '')«IF targets('3.0')»: string«ENDIF»
        {
            $templateFile = $this->data['template'];
            if (
                'custom' === $templateFile
                && null !== $this->data['customTemplate']
                && '' !== $this->data['customTemplate']
            ) {
                $templateFile = $this->data['customTemplate'];
            }

            $templateForObjectType = str_replace('itemlist_', 'itemlist_' . $this->data['objectType'] . '_', $templateFile);

            $templateOptions = [
                'ContentType/' . $templateForObjectType,
                'ContentType/' . $templateFile,
                'ContentType/itemlist_display.html.twig',
            ];

            $template = '';
            foreach ($templateOptions as $templatePath) {
                if ($this->twigLoader->exists('@«appName»/' . $templatePath)) {
                    $template = '@«appName»/' . $templatePath;
                    break;
                }
            }

            return $template;
        }

        public function getEditFormClass()«IF targets('3.0')»: string«ENDIF»
        {
            return FormType::class;
        }

        public function getEditFormOptions($context)«IF targets('3.0')»: array«ENDIF»
        {
            $options = parent::getEditFormOptions($context);
            $data = $this->getData();
            $options['object_type'] = $data['objectType'];
            «IF hasCategorisableEntities»
                $this->categorisableObjectTypes = [«FOR entity : getCategorisableEntities SEPARATOR ', '»'«entity.name.formatForCode»'«ENDFOR»];
                $options['is_categorisable'] = in_array($this->data['objectType'], $this->categorisableObjectTypes);
                $options['category_helper'] = $this->categoryHelper;
                $options['feature_activation_helper'] = $this->featureActivationHelper;
            «ENDIF»

            return $options;
        }

        «IF targets('3.0')»
            /**
             * @required
             */
        «ENDIF»
        public function setControllerHelper(ControllerHelper $controllerHelper)«IF targets('3.0')»: void«ENDIF»
        {
            $this->controllerHelper = $controllerHelper;
        }

        «IF targets('3.0')»
            /**
             * @required
             */
        «ENDIF»
        public function setModelHelper(ModelHelper $modelHelper)«IF targets('3.0')»: void«ENDIF»
        {
            $this->modelHelper = $modelHelper;
        }

        «IF targets('3.0')»
            /**
             * @required
             */
        «ENDIF»
        public function setModulePermissionHelper(PermissionHelper $modulePermissionHelper)«IF targets('3.0')»: void«ENDIF»
        {
            $this->modulePermissionHelper = $modulePermissionHelper;
        }

        «IF targets('3.0')»
            /**
             * @required
             */
        «ENDIF»
        public function setEntityFactory(EntityFactory $entityFactory)«IF targets('3.0')»: void«ENDIF»
        {
            $this->entityFactory = $entityFactory;
        }
        «IF hasCategorisableEntities»

            «IF targets('3.0')»
                /**
                 * @required
                 */
            «ENDIF»
            public function setCategoryDependencies(
                CategoryHelper $categoryHelper,
                FeatureActivationHelper $featureActivationHelper
            )«IF targets('3.0')»: void«ENDIF» {
                $this->categoryHelper = $categoryHelper;
                $this->featureActivationHelper = $featureActivationHelper;
            }
        «ENDIF»
    '''

    def private contentTypeBaseLegacyImpl(Application it) '''
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

        public function __construct()
        {
            $this->setContainer(\ServiceUtil::getManager());
        }

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
            return $this->container->get('translator.default')->__('«appName» list view', '«appName.formatForDB»');
        }

        /**
         * Returns the description of this content type.
         *
         * @return string The content type description
         */
        public function getDescription()
        {
            return $this->container->get('translator.default')->__('Display a list of «appName» objects.', '«appName.formatForDB»');
        }

        /**
         * Loads the data.
         *
         * @param array $data Data array with parameters
         */
        public function loadData(&$data)
        {
            $controllerHelper = $this->container->get('«appService».controller_helper');

            «IF !isSystemModule»
                $contextArgs = ['name' => 'list'];
            «ENDIF»
            if (!isset($data['objectType']) || !in_array($data['objectType'], $controllerHelper->getObjectTypes('contentType'«IF !isSystemModule», $contextArgs«ENDIF»))) {
                $data['objectType'] = $controllerHelper->getDefaultObjectType('contentType'«IF !isSystemModule», $contextArgs«ENDIF»);
            }

            $this->objectType = $data['objectType'];

            $this->sorting = isset($data['sorting']) ? $data['sorting'] : 'default';
            $this->amount = isset($data['amount']) ? $data['amount'] : 1;
            $this->template = isset($data['template']) ? $data['template'] : 'itemlist_' . $this->objectType . '_display.html.twig';
            $this->customTemplate = isset($data['customTemplate']) ? $data['customTemplate'] : null;
            $this->filter = isset($data['filter']) ? $data['filter'] : '';
            «IF hasCategorisableEntities»
                $featureActivationHelper = $this->container->get('«appService».feature_activation_helper');
                if ($featureActivationHelper->isEnabled(FeatureActivationHelper::CATEGORIES, $this->objectType)) {
                    $this->categorisableObjectTypes = [«FOR entity : getCategorisableEntities SEPARATOR ', '»'«entity.name.formatForCode»'«ENDFOR»];
                    $categoryHelper = $this->container->get('«appService».category_helper');

                    // fetch category properties
                    $this->catRegistries = [];
                    $this->catProperties = [];
                    if (in_array($this->objectType, $this->categorisableObjectTypes)) {
                        $entityFactory = $this->container->get('«appService».entity_factory');
                        $idField = $entityFactory->getIdField($this->objectType);
                        $this->catRegistries = $categoryHelper->getAllPropertiesWithMainCat($this->objectType, $idField);
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
                        $data['catIds'][$propName] = [];
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
            $repository = $this->container->get('«appService».entity_factory')->getRepository($this->objectType);

            // create query
            $orderBy = $this->container->get('«appService».model_helper')->resolveSortParameter($this->objectType, $this->sorting);
            $qb = $repository->getListQueryBuilder($this->filter, $orderBy);
            «IF hasCategorisableEntities»

                $featureActivationHelper = $this->container->get('«appService».feature_activation_helper');
                if ($featureActivationHelper->isEnabled(FeatureActivationHelper::CATEGORIES, $this->objectType)) {
                    // apply category filters
                    if (in_array($this->objectType, $this->categorisableObjectTypes)) {
                        if (is_array($this->catIds) && count($this->catIds) > 0) {
                            $categoryHelper = $this->container->get('«appService».category_helper');
                            $qb = $categoryHelper->buildFilterClauses($qb, $this->objectType, $this->catIds);
                        }
                    }
                }
            «ENDIF»

            // get objects from database
            $currentPage = 1;
            $resultsPerPage = isset($this->amount) ? $this->amount : 1;
            $query = $repository->getSelectWherePaginatedQuery($qb, $currentPage, $resultsPerPage);
            try {
                list($entities, $objectCount) = $repository->retrieveCollectionResult($query, true);
            } catch (\Exception $exception) {
                $entities = [];
                $objectCount = 0;
            }

            // filter by permissions
            $entities = $this->container->get('«appService».permission_helper')->filterCollection(«IF !isSystemModule»$objectType, «ENDIF»$entities, ACCESS_READ);

            $data = [
                'objectType' => $this->objectType,
                «IF hasCategorisableEntities»
                    'catids' => $this->catIds,
                «ENDIF»
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

            $templateParameters = $this->container->get('«appService».controller_helper')->addTemplateParameters($this->objectType, $templateParameters, 'contentType', []);

            $template = $this->getDisplayTemplate();

            return $this->container->get('twig')->render($template, $templateParameters);
        }

        /**
         * Returns the template used for output.
         *
         * @return string the template path
         */
        protected function getDisplayTemplate()
        {
            $templateFile = $this->template;
            if ($templateFile == 'custom' && null !== $this->customTemplate && $this->customTemplate != '') {
                $templateFile = $this->customTemplate;
            }

            $templateForObjectType = str_replace('itemlist_', 'itemlist_' . $this->objectType . '_', $templateFile);
            $templating = $this->container->get('templating');

            $templateOptions = [
                'ContentType/' . $templateForObjectType,
                'ContentType/' . $templateFile,
                'ContentType/itemlist_display.html.twig'
            ];

            $template = '';
            foreach ($templateOptions as $templatePath) {
                if ($templating->exists('@«appName»/' . $templatePath)) {
                    $template = '@«appName»/' . $templatePath;
                    break;
                }
            }

            return $template;
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
                'customTemplate' => null,
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
            array_push($this->view->plugins_dir, '«relativeAppRootPath»/«getViewPath»plugins');
            «IF hasCategorisableEntities»

                $featureActivationHelper = $this->container->get('«appService».feature_activation_helper');
                if ($featureActivationHelper->isEnabled(FeatureActivationHelper::CATEGORIES, $this->objectType)) {
                    // assign category data
                    $this->view->assign('registries', $this->catRegistries)
                               ->assign('properties', $this->catProperties);

                    // assign categories lists for simulating category selectors
                    $translator = $this->container->get('translator.default');
                    $locale = $this->container->get('request_stack')->getCurrentRequest()->getLocale();
                    $categories = [];
                    $categoryRepository = $this->container->get('zikula_categories_module.category_repository');
                    foreach ($this->catRegistries as $registryId => $registryCid) {
                        $propName = '';
                        foreach ($this->catProperties as $propertyName => $propertyId) {
                            if ($propertyId == $registryId) {
                                $propName = $propertyName;
                                break;
                            }
                        }

                        $mainCategory = $categoryRepository->find($registryCid);
                        $queryBuilder = $categoryRepository->getChildrenQueryBuilder($mainCategory);
                        $cats = $queryBuilder->getQuery()->execute();
                        $catsForDropdown = [
                            [
                                'value' => '',
                                'text' => $translator->__('All', '«appName.formatForDB»')
                            ]
                        ];
                        foreach ($cats as $category) {
                            $indent = str_repeat('--', $category->getLvl() - $mainCategory->getLvl() - 1);
                            $categoryName = (!empty($indent) ? '|' : '') . $indent . $category->getName();
                            $catsForDropdown[] = [
                                'value' => $category->getId(),
                                'text' => $categoryName
                            ];
                        }
                        $categories[$propName] = $catsForDropdown;
                    }

                    $this->view->assign('categories', $categories)
                               ->assign('categoryHelper', $this->container->get('«appService».category_helper'));
                }
                $this->view->assign('featureActivationHelper', $featureActivationHelper)
                           ->assign('objectType', $this->objectType);
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

        use «appNamespace»\ContentType\Base\AbstractItemListType;

        /**
         * Generic item list content type implementation class.
         */
        class ItemListType extends AbstractItemListType
        {
            // feel free to extend the content type here
        }
    '''

    def private contentTypeLegacyImpl(Application it) '''
        namespace «appNamespace»\ContentType;

        use «appNamespace»\ContentType\Base\AbstractItemList;

        /**
         * Generic item list content type implementation class.
         */
        class ItemList extends AbstractItemList
        {
            // feel free to extend the content type here
        }
    '''
}
