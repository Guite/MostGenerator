package org.zikula.modulestudio.generator.cartridges.zclassic.controller.apis

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
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
    }

    def private listBlockBaseClass(Application it) '''
        «IF !targets('1.3.x')»
            namespace «appNamespace»\Block\Base;

            use BlockUtil;
            use DataUtil;
            use ModUtil;
            use Zikula\Core\AbstractBlockHandler;

        «ENDIF»
        /**
         * Generic item list block base class.
         */
        class «IF targets('1.3.x')»«appName»_Block_Base_ItemList extends Zikula_Controller_AbstractBlock«ELSE»ItemListBlock extends AbstractBlockHandler«ENDIF»
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

        «update»

        /**
         * Returns default settings for this block.
         *
         * @return array The default settings.
         */
        protected function getDefaults()
        {
            $defaults = «IF targets('1.3.x')»array(«ELSE»[«ENDIF»
                'objectType' => '«getLeadingEntity.name.formatForCode»',
                'sorting' => 'default',
                'amount' => 5,
                'customTemplate' => '',
                'filter' => ''
            «IF targets('1.3.x')»)«ELSE»]«ENDIF»;

            return $defaults;
        }

        «IF hasCategorisableEntities»

            /**
             * Resolves category filter ids.
             *
             * @param array $properties The block properties array.
             *
             * @return array The updated block properties.
             */
            protected function resolveCategoryIds(array $properties)
            {
                if (!isset($properties['catIds'])) {
                    $primaryRegistry = ModUtil::apiFunc('«appName»', 'category', 'getPrimaryProperty', «IF targets('1.3.x')»array(«ELSE»[«ENDIF»'ot' => $properties['objectType']«IF targets('1.3.x')»)«ELSE»]«ENDIF»);
                    $properties['catIds'] = «IF targets('1.3.x')»array(«ELSE»[«ENDIF»$primaryRegistry => «IF targets('1.3.x')»array())«ELSE»[]]«ENDIF»;
                    // backwards compatibility
                    if (isset($properties['catId'])) {
                        $properties['catIds'][$primaryRegistry][] = $properties['catId'];
                        unset($properties['catId']);
                    }
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
            «' '»* @param array $blockinfo the blockinfo structure.
            «' '»*
            «' '»* @return string output of the rendered block
        «ELSE»
            «' '»* @param array $properties The block properties array.

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
            «val templateExtension = if (targets('1.3.x')) '.tpl' else '.html.twig'»
            if (!isset($properties['template'])) {
                $properties['template'] = 'itemlist_' . DataUtil::formatForOS($properties['objectType']) . '_display«templateExtension»';
            }
            «IF hasCategorisableEntities»

                $properties = $this->resolveCategoryIds($properties);
            «ENDIF»

            «IF targets('1.3.x')»
                ModUtil::initOOModule('«appName»');

                $controllerHelper = new «appName»_Util_Controller($this->serviceManager);
            «ELSE»
                $controllerHelper = $this->get('«appName.formatForDB».controller_helper');
            «ENDIF»
            $utilArgs = «IF targets('1.3.x')»array(«ELSE»[«ENDIF»'name' => 'list'«IF targets('1.3.x')»)«ELSE»]«ENDIF»;
            if (!isset($properties['objectType']) || !in_array($properties['objectType'], $controllerHelper->getObjectTypes('block', $utilArgs))) {
                $properties['objectType'] = $controllerHelper->getDefaultObjectType('block', $utilArgs);
            }

            $objectType = $properties['objectType'];

            «IF targets('1.3.x')»
                $entityClass = '«appName»_Entity_' . ucfirst($objectType);
                $entityManager = $this->serviceManager->get«IF targets('1.3.x')»Service«ENDIF»('doctrine.entitymanager');
                $repository = $entityManager->getRepository($entityClass);
            «ELSE»
                $repository = $this->get('«appName.formatForDB».' . $objectType . '_factory')->getRepository();
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

                $properties = null;
                if (in_array($properties['objectType'], $this->categorisableObjectTypes)) {
                    $properties = ModUtil::apiFunc('«appName»', 'category', 'getAllProperties', «IF targets('1.3.x')»array(«ELSE»[«ENDIF»'ot' => $objectType«IF targets('1.3.x')»)«ELSE»]«ENDIF»);
                }

                // apply category filters
                if (in_array($objectType, $this->categorisableObjectTypes)) {
                    if (is_array($properties['catIds']) && count($properties['catIds']) > 0) {
                        $qb = ModUtil::apiFunc('«appName»', 'category', 'buildFilterClauses', «IF targets('1.3.x')»array(«ELSE»[«ENDIF»'qb' => $qb, 'ot' => $objectType, 'catids' => $properties['catIds']«IF targets('1.3.x')»)«ELSE»]«ENDIF»);
                    }
                }
            «ENDIF»

            // get objects from database
            $currentPage = 1;
            $resultsPerPage = $properties['amount'];
            list($query, $count) = $repository->getSelectWherePaginatedQuery($qb, $currentPage, $resultsPerPage);
            $entities = $repository->retrieveCollectionResult($query, $orderBy, true);

            «IF targets('1.3.x')»
                // assign block vars and fetched data
                $this->view->assign('vars', $properties)
                           ->assign('objectType', $objectType)
                           ->assign('items', $entities)
                           ->assign($repository->getAdditionalTemplateParameters('block'));
                «IF hasCategorisableEntities»

                    // assign category properties
                    $this->view->assign('properties', $properties);
                «ENDIF»

                // set a block title
                if (empty($blockinfo['title'])) {
                    $blockinfo['title'] = $this->__('«appName» items');
                }

                $blockinfo['content'] = $this->view->fetch($template);

                // return the block to the theme
                return BlockUtil::themeBlock($blockinfo);
            «ELSE»
                $template = $this->getDisplayTemplate($properties);

                $templateParameters = [
                    'vars' => $properties,
                    'objectType' => $objectType,
                    'items' => $entities«IF hasCategorisableEntities»,
                    'properties' => $properties«ENDIF»
                ];
                $templateParameters = array_merge($templateParameters, $repository->getAdditionalTemplateParameters('block'));

                return $this->renderView($template, $templateParameters);
            «ENDIF»
        }
    '''

    def private getDisplayTemplate(Application it) '''
        /**
         * Returns the template used for output.
         *
         * @param array $properties The block properties array.
         *
         * @return string the template path.
         */
        protected function getDisplayTemplate(array $properties)
        {
            $templateFile = $properties['template'];
            if ($templateFile == 'custom') {
                $templateFile = $properties['customTemplate'];
            }

            $templateForObjectType = str_replace('itemlist_', 'itemlist_' . DataUtil::formatForOS($properties['objectType']) . '_', $templateFile);

            $template = '';
            if ($this->view->template_exists('«IF targets('1.3.x')»contenttype«ELSE»ContentType«ENDIF»/' . $templateForObjectType)) {
                $template = '«IF targets('1.3.x')»contenttype«ELSE»ContentType«ENDIF»/' . $templateForObjectType;
            } elseif ($this->view->template_exists('«IF targets('1.3.x')»block«ELSE»Block«ENDIF»/' . $templateForObjectType)) {
                $template = '«IF targets('1.3.x')»block«ELSE»Block«ENDIF»/' . $templateForObjectType;
            } elseif ($this->view->template_exists('«IF targets('1.3.x')»contenttype«ELSE»ContentType«ENDIF»/' . $templateFile)) {
                $template = '«IF targets('1.3.x')»contenttype«ELSE»ContentType«ENDIF»/' . $templateFile;
            } elseif ($this->view->template_exists('«IF targets('1.3.x')»block«ELSE»Block«ENDIF»/' . $templateFile)) {
                $template = '«IF targets('1.3.x')»block«ELSE»Block«ENDIF»/' . $templateFile;
            } else {
                $template = '«IF targets('1.3.x')»block«ELSE»Block«ENDIF»/itemlist.«IF targets('1.3.x')»tpl«ELSE»html.twig«ENDIF»';
            }

            return $template;
        }
    '''

    def private getSortParam(Application it) '''
        /**
         * Determines the order by parameter for item selection.
         *
         * @param array               $properties The block properties array.
         * @param Doctrine_Repository $repository The repository used for data fetching.
         *
         * @return string the sorting clause.
         */
        protected function getSortParam(array $properties, $repository)
        {
            if ($properties['sorting'] == 'random') {
                return 'RAND()';
            }

            $sortParam = '';
            if ($properties['sorting'] == 'newest') {
                $idFields = ModUtil::apiFunc('«appName»', 'selection', 'getIdFields', «IF targets('1.3.x')»array(«ELSE»[«ENDIF»'ot' => $properties['objectType']«IF targets('1.3.x')»)«ELSE»]«ENDIF»);
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
        /**
        «IF targets('1.3.x')»
            «' '»* Modify block settings.
            «' '»*
            «' '»* @param array $blockinfo the blockinfo structure
            «' '»*
            «' '»* @return string output of the block editing form.
        «ELSE»
            «' '»* Modify the block content.
            «' '»*
            «' '»* @param Request $request The current request.
            «' '»* @param array $properties The block properties array.
            «' '»*
            «' '»* @return string
        «ENDIF»
        «val templateExtension = if (targets('1.3.x')) '.tpl' else '.html.twig'»
         */
        public function modify(«IF targets('1.3.x')»$blockinfo«ELSE»Request $request, array $properties«ENDIF»)
        {
            «IF targets('1.3.x')»
                // Get current content
                $properties = BlockUtil::varsFromContent($blockinfo['content']);

            «ENDIF»
            // set default values for all params which are not properly set
            $defaults = $this->getDefaults();
            $properties = array_merge($defaults, $properties);
            if (!isset($properties['template'])) {
                $properties['template'] = 'itemlist_' . DataUtil::formatForOS($properties['objectType']) . '_display«templateExtension»';
            }
            «IF hasCategorisableEntities»

                $properties = $this->resolveCategoryIds($properties);
            «ENDIF»

            «IF targets('1.3.x')»
                $this->view->setCaching(Zikula_View::CACHE_DISABLED);

                // assign the appropriate values
                $this->view->assign($properties);

                // clear the block cache
                $this->view->clear_cache('«IF targets('1.3.x')»block«ELSE»Block«ENDIF»/itemlist_display«templateExtension»');
                $this->view->clear_cache('«IF targets('1.3.x')»block«ELSE»Block«ENDIF»/itemlist_' . DataUtil::formatForOS($properties['objectType']) . '_display«templateExtension»');
                $this->view->clear_cache('«IF targets('1.3.x')»block«ELSE»Block«ENDIF»/itemlist_display_description«templateExtension»');
                $this->view->clear_cache('«IF targets('1.3.x')»block«ELSE»Block«ENDIF»/itemlist_' . DataUtil::formatForOS($properties['objectType']) . '_display_description«templateExtension»');

                // Return the output that has been generated by this function
                return $this->view->fetch('block/itemlist_modify«templateExtension»');
            «ELSE»
                return $this->renderView('Block/itemlist_modify«templateExtension», $properties);
            «ENDIF»
        }
    '''

    def private update(Application it) '''
        /**
         * Update block settings.
         *
         * @param array $blockinfo the blockinfo structure
         *
         * @return array the modified blockinfo structure.
         */
        public function update($blockinfo)
        {
            // Get current content
            $properties = BlockUtil::varsFromContent($blockinfo['content']);
            «IF !targets('1.3.x')»
                $request = $this->get('request_stack')->getCurrentRequest();
            «ENDIF»

            «IF targets('1.3.x')»
                $properties['objectType'] = $this->request->request->filter('objecttype', '«getLeadingEntity.name.formatForCode»', FILTER_SANITIZE_STRING);
                $properties['sorting'] = $this->request->request->filter('sorting', 'default', FILTER_SANITIZE_STRING);
                $properties['amount'] = (int) $this->request->request->filter('amount', 5, FILTER_VALIDATE_INT);
                $properties['template'] = $this->request->request->get('template', '');
                $properties['customTemplate'] = $this->request->request->get('customtemplate', '');
                $properties['filter'] = $this->request->request->get('filter', '');
            «ELSE»
                $properties['objectType'] = $request->request->getAlnum('objecttype', '«getLeadingEntity.name.formatForCode»');
                $properties['sorting'] = $request->request->getAlpha('sorting', 'default');
                $properties['amount'] = $request->request->getInt('amount', 5);
                $properties['template'] = $request->request->getAlnum('template', '');
                $properties['customTemplate'] = $request->request->getAlnum('customtemplate', '');
                $properties['filter'] = $request->request->get('filter', '');
            «ENDIF»

            «IF targets('1.3.x')»
                $controllerHelper = new «appName»_Util_Controller($this->serviceManager);
            «ELSE»
                $controllerHelper = $this->get('«appName.formatForDB».controller_helper');
            «ENDIF»
            if (!in_array($properties['objectType'], $controllerHelper->getObjectTypes('block'))) {
                $properties['objectType'] = $controllerHelper->getDefaultObjectType('block');
            }
            «IF hasCategorisableEntities»

                $primaryRegistry = ModUtil::apiFunc('«appName»', 'category', 'getPrimaryProperty', «IF targets('1.3.x')»array(«ELSE»[«ENDIF»'ot' => $properties['objectType']«IF targets('1.3.x')»)«ELSE»]«ENDIF»);
                $properties['catIds'] = «IF targets('1.3.x')»array(«ELSE»[«ENDIF»$primaryRegistry => «IF targets('1.3.x')»array())«ELSE»[]]«ENDIF»;
                if (in_array($properties['objectType'], $this->categorisableObjectTypes)) {
                    $properties['catIds'] = ModUtil::apiFunc('«appName»', 'category', 'retrieveCategoriesFromRequest', «IF targets('1.3.x')»array(«ELSE»[«ENDIF»'ot' => $properties['objectType']«IF targets('1.3.x')»)«ELSE»]«ENDIF»);
                }
            «ENDIF»

            // write back the new contents
            $blockinfo['content'] = BlockUtil::varsToContent($properties);
            «IF targets('1.3.x')»

                // clear the block cache
                $this->view->clear_cache('«IF targets('1.3.x')»block«ELSE»Block«ENDIF»/itemlist_display.tpl');
                $this->view->clear_cache('«IF targets('1.3.x')»block«ELSE»Block«ENDIF»/itemlist_' . ucfirst($properties['objectType']) . '_display.tpl');
                $this->view->clear_cache('«IF targets('1.3.x')»block«ELSE»Block«ENDIF»/itemlist_display_description.tpl');
                $this->view->clear_cache('«IF targets('1.3.x')»block«ELSE»Block«ENDIF»/itemlist_' . ucfirst($properties['objectType']) . '_display_description.tpl');
            «ENDIF»

            return $blockinfo;
        }
    '''

    def private listBlockImpl(Application it) '''
        «IF !targets('1.3.x')»
            namespace «appNamespace»\Block;

            use «appNamespace»\Block\Base\ItemListBlock as BaseItemListBlock;

        «ENDIF»
        /**
         * Generic item list block implementation class.
         */
        «IF targets('1.3.x')»
        class «appName»_Block_ItemList extends «appName»_Block_Base_ItemList
        «ELSE»
        class ItemListBlock extends BaseItemListBlock
        «ENDIF»
        {
            // feel free to extend the item list block here
        }
    '''
}
