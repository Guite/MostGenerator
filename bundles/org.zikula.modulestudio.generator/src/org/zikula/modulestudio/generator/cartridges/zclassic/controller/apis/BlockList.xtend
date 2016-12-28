package org.zikula.modulestudio.generator.cartridges.zclassic.controller.apis

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.formtype.ListBlock
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.cartridges.zclassic.view.additions.BlocksView
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class BlockList {
    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelExtensions = new ModelExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    FileHelper fh = new FileHelper

    def generate(Application it, IFileSystemAccess fsa) {
        println('Generating block for multiple objects')
        generateClassPair(fsa, getAppSourceLibPath + 'Block/ItemList' + (if (targets('1.3.x')) '' else 'Block') + '.php',
            fh.phpFileContent(it, listBlockBaseClass), fh.phpFileContent(it, listBlockImpl)
        )
        new BlocksView().generate(it, fsa)
        if (!targets('1.3.x')) {
            // form type class
            new ListBlock().generate(it, fsa)
        }
    }

    def private listBlockBaseClass(Application it) '''
        «IF !targets('1.3.x')»
            namespace «appNamespace»\Block\Base;

            «IF hasCategorisableEntities && !targets('1.4-dev')»
                use CategoryUtil;
            «ENDIF»
            use Zikula\BlocksModule\AbstractBlockHandler;
            use Zikula\Core\AbstractBundle;
            «IF hasCategorisableEntities»
                use «appNamespace»\Helper\FeatureActivationHelper;
            «ENDIF»

        «ENDIF»
        /**
         * Generic item list block base class.
         */
        abstract class «IF targets('1.3.x')»«appName»_Block_Base_AbstractItemList extends Zikula_Controller_AbstractBlock«ELSE»AbstractItemListBlock extends AbstractBlockHandler«ENDIF»
        {
            «listBlockBaseImpl»
        }
    '''

    def private listBlockBaseImpl(Application it) '''
        «IF hasCategorisableEntities»
            /**
             * List of object types allowing categorisation.
             *
             * @var array
             */
            protected $categorisableObjectTypes;

        «ENDIF»
        «IF targets('1.3.x')»
            «init»

            «info»

        «ELSEIF hasCategorisableEntities»
            /**
             * Constructor.
             *
             * @param AbstractBundle $bundle An AbstractBundle instance
             *
             * @throws \InvalidArgumentException
             */
            public function __construct(AbstractBundle $bundle)
            {
                parent::__construct($bundle);

                $this->categorisableObjectTypes = [«FOR entity : getCategorisableEntities SEPARATOR ', '»'«entity.name.formatForCode»'«ENDFOR»];
            }

        «ENDIF»
        «display»

        «getDisplayTemplate»

        «getSortParam»

        «modify»

        «IF targets('1.3.x')»
            «update»

        «ENDIF»
        /**
         * Returns default settings for this block.
         *
         * @return array The default settings
         */
        protected function getDefaults()
        {
            $defaults = «IF targets('1.3.x')»array(«ELSE»[«ENDIF»
                'objectType' => '«getLeadingEntity.name.formatForCode»',
                'sorting' => 'default',
                'amount' => 5,
                'template' => 'itemlist_display.«IF targets('1.3.x')»tpl«ELSE»html.twig«ENDIF»',
                'customTemplate' => '',
                'filter' => ''
            «IF targets('1.3.x')»)«ELSE»]«ENDIF»;

            return $defaults;
        }

        «IF hasCategorisableEntities»

            /**
             * Resolves category filter ids.
             *
             * @param array $properties The block properties array
             *
             * @return array The updated block properties
             */
            protected function resolveCategoryIds(array $properties)
            {
                if (!isset($properties['catIds'])) {
                    «IF targets('1.3.x')»
                        $primaryRegistry = ModUtil::apiFunc('«appName»', 'category', 'getPrimaryProperty', array('ot' => $properties['objectType']));
                    «ELSE»
                        $categoryHelper = $this->get('«appService».category_helper');
                        $primaryRegistry = $categoryHelper->getPrimaryProperty($properties['objectType']);
                    «ENDIF»
                    $properties['catIds'] = «IF targets('1.3.x')»array(«ELSE»[«ENDIF»$primaryRegistry => «IF targets('1.3.x')»array())«ELSE»[]]«ENDIF»;
                    «IF targets('1.3.x')»
                        // backwards compatibility
                        if (isset($properties['catId'])) {
                            $properties['catIds'][$primaryRegistry][] = $properties['catId'];
                            unset($properties['catId']);
                        }
                    «ENDIF»
                } elseif (!is_array($properties['catIds'])) {
                    $properties['catIds'] = explode(',', $properties['catIds']);
                }

                return $properties;
            }
        «ENDIF»
    '''

    // 1.3.x only
    def private init(Application it) '''
        /**
         * Initialise the block.
         */
        public function init()
        {
            //SecurityUtil::registerPermissionSchema('«appName»:ItemListBlock:', 'Block title::');
            «IF hasCategorisableEntities»

                $this->categorisableObjectTypes = array(«FOR entity : getCategorisableEntities SEPARATOR ', '»'«entity.name.formatForCode»'«ENDFOR»);
            «ENDIF»
        }
    '''

    // 1.3.x only
    def private info(Application it) '''
        /**
         * Get information on the block.
         *
         * @return array The block information
         */
        public function info()
        {
            $requirementMessage = '';
            // check if the module is available at all
            if (!ModUtil::available('«appName»')) {
                $requirementMessage .= $this->__('Notice: This block will not be displayed until you activate the «appName» module.');
            }

            return array(
                'module'          => '«appName»',
                'text_type'       => $this->__('«appName» list view'),
                'text_type_long'  => $this->__('Display list of «appName» objects.'),
                'allow_multiple'  => true,
                'form_content'    => false,
                'form_refresh'    => false,
                'show_preview'    => true,
                'admin_tableless' => true,
                'requirement'     => $requirementMessage
            );
        }
    '''

    def private display(Application it) '''
        /**
         * Display the block content.
         *
        «IF targets('1.3.x')»
            «' '»* @param array $blockinfo the blockinfo structure
            «' '»*
            «' '»* @return string output of the rendered block
        «ELSE»
            «' '»* @param array $properties The block properties array
            «' '»*
            «' '»* @return array|string
        «ENDIF»
         */
        public function display(«IF targets('1.3.x')»$blockinfo«ELSE»array $properties«ENDIF»)
        {
            // only show block content if the user has the required permissions
            «IF targets('1.3.x')»
                if (!SecurityUtil::checkPermission('«appName»:ItemListBlock:', "$blockinfo[title]::", ACCESS_OVERVIEW)) {
                    return false;
                }
            «ELSE»
                if (!$this->hasPermission('«appName»:ItemListBlock:', "$properties[title]::", ACCESS_OVERVIEW)) {
                    return false;
                }
            «ENDIF»
            «IF targets('1.3.x')»

                // check if the module is available at all
                if (!ModUtil::available('«appName»')) {
                    return false;
                }

                // get current block content
                $properties = BlockUtil::varsFromContent($blockinfo['content']);
                $properties['bid'] = $blockinfo['bid'];
            «ENDIF»

            // set default values for all params which are not properly set
            $defaults = $this->getDefaults();
            $properties = array_merge($defaults, $properties);
            «IF hasCategorisableEntities»

                «IF targets('1.3.x')»
                    $properties = $this->resolveCategoryIds($properties);
                «ELSE»
                    $featureActivationHelper = $this->get('«appService».feature_activation_helper');
                    if ($featureActivationHelper->isEnabled(FeatureActivationHelper::CATEGORIES, $properties['objectType'])) {
                        $properties = $this->resolveCategoryIds($properties);
                    }
                «ENDIF»
            «ENDIF»

            «IF targets('1.3.x')»
                ModUtil::initOOModule('«appName»');

                $controllerHelper = new «appName»_Util_Controller($this->serviceManager);
            «ELSE»
                $controllerHelper = $this->get('«appService».controller_helper');
            «ENDIF»
            $utilArgs = «IF targets('1.3.x')»array(«ELSE»[«ENDIF»'name' => 'list'«IF targets('1.3.x')»)«ELSE»]«ENDIF»;
            if (!isset($properties['objectType']) || !in_array($properties['objectType'], $controllerHelper->getObjectTypes('block', $utilArgs))) {
                $properties['objectType'] = $controllerHelper->getDefaultObjectType('block', $utilArgs);
            }

            $objectType = $properties['objectType'];

            «IF targets('1.3.x')»
                $entityClass = '«appName»_Entity_' . ucfirst($objectType);
                $entityManager = $this->serviceManager->get«IF targets('1.3.x')»Service«ENDIF»('«entityManagerService»');
                $repository = $entityManager->getRepository($entityClass);
            «ELSE»
                $repository = $this->get('«appService».' . $objectType . '_factory')->getRepository();
            «ENDIF»

            «IF targets('1.3.x')»
                $this->view->setCaching(Zikula_View::CACHE_ENABLED);
                // set cache id
                $component = '«appName»:' . ucfirst($objectType) . ':';
                $instance = '::';
                $accessLevel = ACCESS_READ;
                if (SecurityUtil::checkPermission($component, $instance, ACCESS_COMMENT)) {
                    $accessLevel = ACCESS_COMMENT;
                }
                if (SecurityUtil::checkPermission($component, $instance, ACCESS_EDIT)) {
                    $accessLevel = ACCESS_EDIT;
                }
                $this->view->setCacheId('view|ot_' . $objectType . '_sort_' . $properties['sorting'] . '_amount_' . $properties['amount'] . '_' . $accessLevel);

                $template = $this->getDisplayTemplate($properties);

                // if page is cached return cached content
                if ($this->view->is_cached($template)) {
                    $blockinfo['content'] = $this->view->fetch($template);

                    return BlockUtil::themeBlock($blockinfo);
                }
            «ENDIF»

            // create query
            $where = $properties['filter'];
            $orderBy = $this->getSortParam($properties, $repository);
            $qb = $repository->genericBaseQuery($where, $orderBy);
            «IF hasCategorisableEntities»

                // fetch category registries
                $catProperties = null;
                if (in_array($objectType, $this->categorisableObjectTypes)) {
                    «IF targets('1.3.x')»
                        $catProperties = ModUtil::apiFunc('«appName»', 'category', 'getAllProperties', array('ot' => $objectType));
                        // apply category filters
                        if (is_array($properties['catIds']) && count($properties['catIds']) > 0) {
                            $qb = ModUtil::apiFunc('«appName»', 'category', 'buildFilterClauses', array('qb' => $qb, 'ot' => $objectType, 'catids' => $properties['catIds']));
                        }
                    «ELSE»
                        if ($featureActivationHelper->isEnabled(FeatureActivationHelper::CATEGORIES, $properties['objectType'])) {
                            $categoryHelper = $this->get('«appService».category_helper');
                            $catProperties = $categoryHelper->getAllProperties($objectType);
                            // apply category filters
                            if (is_array($properties['catIds']) && count($properties['catIds']) > 0) {
                                $qb = $categoryHelper->buildFilterClauses($qb, $objectType, $properties['catIds']);
                            }
                        }
                    «ENDIF»
                }
            «ENDIF»

            // get objects from database
            $currentPage = 1;
            $resultsPerPage = $properties['amount'];
            list($query, $count) = $repository->getSelectWherePaginatedQuery($qb, $currentPage, $resultsPerPage);
            «IF targets('1.3.x')»$entities«ELSE»list($entities, $objectCount)«ENDIF» = $repository->retrieveCollectionResult($query, $orderBy, true);
            «IF hasCategorisableEntities»

                «IF !targets('1.3.x')»
                if ($featureActivationHelper->isEnabled(FeatureActivationHelper::CATEGORIES, $objectType)) {
                «ENDIF»
                $filteredEntities = «IF targets('1.3.x')»array()«ELSE»[]«ENDIF»;
                foreach ($entities as $entity) {
                    «IF !targets('1.3.x')»
                        if ($this->get('«appService».category_helper')->hasPermission($entity)) {
                            $filteredEntities[] = $entity;
                        }
                    «ELSE»
                        if (ModUtil::apiFunc($this->name, 'category', 'hasPermission', array('entity' => $entity))) {
                            $filteredEntities[] = $entity;
                        }
                    «ENDIF»
                }
                $entities = $filteredEntities;
                «IF !targets('1.3.x')»
                }
                «ENDIF»
            «ENDIF»

            «IF targets('1.3.x')»
                // assign block vars and fetched data
                $this->view->assign('vars', $properties)
                           ->assign('objectType', $objectType)
                           ->assign('items', $entities)
                           ->assign($repository->getAdditionalTemplateParameters('block'));
                «IF hasCategorisableEntities»

                    // assign category registries
                    $this->view->assign('properties', $catProperties);
                «ENDIF»

                // set a block title
                if (empty($blockinfo['title'])) {
                    $blockinfo['title'] = $this->__('«appName» items');
                }

                $blockinfo['content'] = $this->view->fetch($template);

                // return the block to the theme
                return BlockUtil::themeBlock($blockinfo);
            «ELSE»
                // set a block title
                if (empty($properties['title'])) {
                    $properties['title'] = $this->__('«appName» items');
                }

                $template = $this->getDisplayTemplate($properties);

                $templateParameters = [
                    'vars' => $properties,
                    'objectType' => $objectType,
                    'items' => $entities
                ];
                «IF hasCategorisableEntities»
                    if ($featureActivationHelper->isEnabled(FeatureActivationHelper::CATEGORIES, $properties['objectType'])) {
                        $templateParameters['properties'] = $properties;
                    }
                «ENDIF»
                «IF hasUploads»
                    $imageHelper = $this->get('«appService».image_helper');
                «ENDIF»
                $templateParameters = array_merge($templateParameters, $repository->getAdditionalTemplateParameters(«IF hasUploads»$imageHelper, «ENDIF»'block'));

                return $this->renderView($template, $templateParameters);
            «ENDIF»
        }
    '''

    def private getDisplayTemplate(Application it) '''
        /**
         * Returns the template used for output.
         *
         * @param array $properties The block properties array
         *
         * @return string the template path
         */
        protected function getDisplayTemplate(array $properties)
        {
            $templateFile = $properties['template'];
            if ($templateFile == 'custom') {
                $templateFile = $properties['customTemplate'];
            }

            $templateForObjectType = str_replace('itemlist_', 'itemlist_' . $properties['objectType'] . '_', $templateFile);
            «IF !targets('1.3.x')»
                «/* TODO find a better way considering overriding */»
                $templateDirectory = str_replace('Block/Base/AbstractItemListBlock.php', 'Resources/views/', __FILE__);
            «ENDIF»

            $template = '';
            if («IF targets('1.3.x')»$this->view->template_exists(«ELSE»file_exists($templateDirectory . «ENDIF»'«IF targets('1.3.x')»contenttype«ELSE»ContentType«ENDIF»/' . $templateForObjectType)) {
                $template = '«IF targets('1.3.x')»contenttype«ELSE»ContentType«ENDIF»/' . $templateForObjectType;
            } elseif («IF targets('1.3.x')»$this->view->template_exists(«ELSE»file_exists($templateDirectory . «ENDIF»'«IF targets('1.3.x')»block«ELSE»Block«ENDIF»/' . $templateForObjectType)) {
                $template = '«IF targets('1.3.x')»block«ELSE»Block«ENDIF»/' . $templateForObjectType;
            } elseif («IF targets('1.3.x')»$this->view->template_exists(«ELSE»file_exists($templateDirectory . «ENDIF»'«IF targets('1.3.x')»contenttype«ELSE»ContentType«ENDIF»/' . $templateFile)) {
                $template = '«IF targets('1.3.x')»contenttype«ELSE»ContentType«ENDIF»/' . $templateFile;
            } elseif («IF targets('1.3.x')»$this->view->template_exists(«ELSE»file_exists($templateDirectory . «ENDIF»'«IF targets('1.3.x')»block«ELSE»Block«ENDIF»/' . $templateFile)) {
                $template = '«IF targets('1.3.x')»block«ELSE»Block«ENDIF»/' . $templateFile;
            } else {
                $template = '«IF targets('1.3.x')»block«ELSE»Block«ENDIF»/itemlist.«IF targets('1.3.x')»tpl«ELSE»html.twig«ENDIF»';
            }
            «IF !targets('1.3.x')»
                $template = '@«appName»/' . $template;
            «ENDIF»

            return $template;
        }
    '''

    def private getSortParam(Application it) '''
        /**
         * Determines the order by parameter for item selection.
         *
         * @param array               $properties The block properties array
         * @param Doctrine_Repository $repository The repository used for data fetching
         *
         * @return string the sorting clause
         */
        protected function getSortParam(array $properties, $repository)
        {
            if ($properties['sorting'] == 'random') {
                return 'RAND()';
            }

            $sortParam = '';
            if ($properties['sorting'] == 'newest') {
                «IF targets('1.3.x')»
                    $idFields = ModUtil::apiFunc('«appName»', 'selection', 'getIdFields', array('ot' => $properties['objectType']));
                «ELSE»
                    $selectionHelper = $this->get('«appService».selection_helper');
                    $idFields = $selectionHelper->getIdFields($properties['objectType']);
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
            } elseif ($properties['sorting'] == 'default') {
                $sortParam = $repository->getDefaultSortingField() . ' ASC';
            }

            return $sortParam;
        }
    '''

    def private modify(Application it) '''
        «val templateExtension = if (targets('1.3.x')) '.tpl' else '.html.twig'»
        «IF targets('1.3.x')»
            /**
             * Modify block settings.
             *
             * @param array $blockinfo the blockinfo structure
             *
             * @return string output of the block editing form
             */
            public function modify($blockinfo)
            {
                // Get current content
                $properties = BlockUtil::varsFromContent($blockinfo['content']);

                // set default values for all params which are not properly set
                $defaults = $this->getDefaults();
                $properties = array_merge($defaults, $properties);
                «IF hasCategorisableEntities»

                    $properties = $this->resolveCategoryIds($properties);
                «ENDIF»

                $this->view->setCaching(Zikula_View::CACHE_DISABLED);

                // assign the appropriate values
                $this->view->assign($properties);

                // Return the output that has been generated by this function
                return $this->view->fetch('block/itemlist_modify«templateExtension»');
            }
        «ELSE»
            /**
             * Returns the fully qualified class name of the block's form class.
             *
             * @return string Template path
             */
            public function getFormClassName()
            {
                return '«appNamespace»\Block\Form\Type\ItemListBlockType';
            }

            /**
             * Returns any array of form options.
             *
             * @return array Options array
             */
            public function getFormOptions()
            {
                $objectType = '«leadingEntity.name.formatForCode»';

                $request = $this->get('request_stack')->getCurrentRequest();
                if ($request->attributes->has('blockEntity')) {
                    $blockEntity = $request->attributes->get('blockEntity');
                    if (is_object($blockEntity) && method_exists($blockEntity, 'getContent')) {
                        $blockProperties = $blockEntity->getContent();
                        if (isset($blockProperties['objectType'])) {
                            $objectType = $blockProperties['objectType'];
                        }
                    }
                }

                return [
                    'objectType' => $objectType«IF hasCategorisableEntities»,
                    'isCategorisable' => in_array($objectType, $this->categorisableObjectTypes),
                    'categoryHelper' => $this->get('«appService».category_helper'),
                    'featureActivationHelper' => $this->get('«appService».feature_activation_helper')«ENDIF»
                ];
            }

            /**
             * Returns the template used for rendering the editing form.
             *
             * @return string Template path
             */
            public function getFormTemplate()
            {
                return '@«appName»/Block/itemlist_modify«templateExtension»';
            }
        «ENDIF»
    '''

    // 1.3.x only
    def private update(Application it) '''
        /**
         * Update block settings.
         *
         * @param array $blockinfo the blockinfo structure
         *
         * @return array the modified blockinfo structure
         */
        public function update($blockinfo)
        {
            // Get current content
            $properties = BlockUtil::varsFromContent($blockinfo['content']);

            $properties['objectType'] = $this->request->request->filter('objecttype', '«getLeadingEntity.name.formatForCode»', FILTER_SANITIZE_STRING);
            $properties['sorting'] = $this->request->request->filter('sorting', 'default', FILTER_SANITIZE_STRING);
            $properties['amount'] = (int) $this->request->request->filter('amount', 5, FILTER_VALIDATE_INT);
            $properties['template'] = $this->request->request->get('template', '');
            $properties['customTemplate'] = $this->request->request->get('customtemplate', '');
            $properties['filter'] = $this->request->request->get('filter', '');

            $controllerHelper = new «appName»_Util_Controller($this->serviceManager);
            if (!in_array($properties['objectType'], $controllerHelper->getObjectTypes('block'))) {
                $properties['objectType'] = $controllerHelper->getDefaultObjectType('block');
            }

            $primaryRegistry = ModUtil::apiFunc('«appName»', 'category', 'getPrimaryProperty', array('ot' => $properties['objectType']));
            $properties['catIds'] = array($primaryRegistry => array());
            if (in_array($properties['objectType'], $this->categorisableObjectTypes)) {
                $properties['catIds'] = ModUtil::apiFunc('«appName»', 'category', 'retrieveCategoriesFromRequest', array('ot' => $properties['objectType']));
            }

            // write back the new contents
            $blockinfo['content'] = BlockUtil::varsToContent($properties);

            // clear the block cache
            $this->view->clear_cache('block/itemlist_display.tpl');
            $this->view->clear_cache('block/itemlist_' . $properties['objectType'] . '_display.tpl');
            $this->view->clear_cache('block/itemlist_display_description.tpl');
            $this->view->clear_cache('block/itemlist_' . $properties['objectType'] . '_display_description.tpl');

            return $blockinfo;
        }
    '''

    def private listBlockImpl(Application it) '''
        «IF !targets('1.3.x')»
            namespace «appNamespace»\Block;

            use «appNamespace»\Block\Base\AbstractItemListBlock;

        «ENDIF»
        /**
         * Generic item list block implementation class.
         */
        «IF targets('1.3.x')»
        class «appName»_Block_ItemList extends «appName»_Block_Base_AbstractItemList
        «ELSE»
        class ItemListBlock extends AbstractItemListBlock
        «ENDIF»
        {
            // feel free to extend the item list block here
        }
    '''
}
