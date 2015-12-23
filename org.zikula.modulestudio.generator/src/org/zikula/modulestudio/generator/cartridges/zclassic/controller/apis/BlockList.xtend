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
            use Zikula\Core\Controller\AbstractBlockController;
            use Zikula_View;

        «ENDIF»
        /**
         * Generic item list block base class.
         */
        class «IF targets('1.3.x')»«appName»_Block_Base_ItemList extends Zikula_Controller_AbstractBlock«ELSE»ItemListBlock extends AbstractBlockController«ENDIF»
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
            $defaults = array(
                'objectType' => '«getLeadingEntity.name.formatForCode»',
                'sorting' => 'default',
                'amount' => 5,
                'customTemplate' => '',
                'filter' => ''
            );

            return $defaults;
        }

        «IF hasCategorisableEntities»

            /**
             * Resolves category filter ids.
             *
             * @param array $content Block variables.
             *
             * @return array The updated block variables.
             */
            protected function resolveCategoryIds($content)
            {
                if (!isset($content['catIds'])) {
                    $primaryRegistry = ModUtil::apiFunc('«appName»', 'category', 'getPrimaryProperty', array('ot' => $content['objectType']));
                    $content['catIds'] = array($primaryRegistry => array());
                    // backwards compatibility
                    if (isset($content['catId'])) {
                        $content['catIds'][$primaryRegistry][] = $content['catId'];
                        unset($content['catId']);
                    }
                } elseif (!is_array($content['catIds'])) {
                    $content['catIds'] = explode(',', $content['catIds']);
                }

                return $content;
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

            return array('module'          => '«appName»',
                         'text_type'       => $this->__('«appName» list view'),
                         'text_type_long'  => $this->__('Display list of «appName» objects.'),
                         'allow_multiple'  => true,
                         'form_content'    => false,
                         'form_refresh'    => false,
                         'show_preview'    => true,
                         'admin_tableless' => true,
                         'requirement'     => $requirementMessage);
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
            «' '»* @param array $content The block content array.

            «' '»* @return array|string
        «ENDIF»
         */
        public function display(«IF targets('1.3.x')»$blockinfo«ELSE»$content«ENDIF»)
        {
            // only show block content if the user has the required permissions
            «IF targets('1.3.x')»
                if (!SecurityUtil::checkPermission('«appName»:ItemListBlock:', "$blockinfo[title]::", ACCESS_OVERVIEW)) {
                    return false;
                }
            «ELSE»
                if (!$this->hasPermission('«appName»:ItemListBlock:', "$content[title]::", ACCESS_OVERVIEW)) {
                    return false;
                }
            «ENDIF»

            // check if the module is available at all
            if (!ModUtil::available('«appName»')) {
                return false;
            }

            «IF targets('1.3.x')»
                // get current block content
                $content = BlockUtil::varsFromContent($blockinfo['content']);
                $content['bid'] = $blockinfo['bid'];

            «ENDIF»
            // set default values for all params which are not properly set
            $defaults = $this->getDefaults();
            $content = array_merge($defaults, $content);
            if (!isset($content['template'])) {
                $content['template'] = 'itemlist_' . DataUtil::formatForOS($content['objectType']) . '_display.tpl';
            }
            «IF hasCategorisableEntities»

                $content = $this->resolveCategoryIds($content);
            «ENDIF»

            «IF targets('1.3.x')»
                ModUtil::initOOModule('«appName»');

                $controllerHelper = new «appName»_Util_Controller($this->serviceManager);
            «ELSE»
                $controllerHelper = $this->get('«appName.formatForDB».controller_helper');
            «ENDIF»
            $utilArgs = array('name' => 'list');
            if (!isset($content['objectType']) || !in_array($content['objectType'], $controllerHelper->getObjectTypes('block', $utilArgs))) {
                $content['objectType'] = $controllerHelper->getDefaultObjectType('block', $utilArgs);
            }

            $objectType = $content['objectType'];

            «IF targets('1.3.x')»
                $entityClass = '«appName»_Entity_' . ucfirst($objectType);
                $entityManager = $this->serviceManager->get«IF targets('1.3.x')»Service«ENDIF»('doctrine.entitymanager');
                $repository = $entityManager->getRepository($entityClass);
            «ELSE»
                $repository = $this->get('«appName.formatForDB».' . $objectType . '_factory')->getRepository();
            «ENDIF»

            $this->view->setCaching(Zikula_View::CACHE_ENABLED);
            // set cache id
            $component = '«appName»:' . ucfirst($objectType) . ':';
            $instance = '::';
            $accessLevel = ACCESS_READ;
            if («IF targets('1.3.x')»SecurityUtil::check«ELSE»$this->has«ENDIF»Permission($component, $instance, ACCESS_COMMENT)) {
                $accessLevel = ACCESS_COMMENT;
            }
            if («IF targets('1.3.x')»SecurityUtil::check«ELSE»$this->has«ENDIF»Permission($component, $instance, ACCESS_EDIT)) {
                $accessLevel = ACCESS_EDIT;
            }
            $this->view->setCacheId('view|ot_' . $objectType . '_sort_' . $content['sorting'] . '_amount_' . $content['amount'] . '_' . $accessLevel);

            $template = $this->getDisplayTemplate($content);

            // if page is cached return cached content
            if ($this->view->is_cached($template)) {
                $blockinfo['content'] = $this->view->fetch($template);
                return BlockUtil::themeBlock($blockinfo);
            }

            // create query
            $where = $content['filter'];
            $orderBy = $this->getSortParam($content, $repository);
            $qb = $repository->genericBaseQuery($where, $orderBy);
            «IF hasCategorisableEntities»

                $properties = null;
                if (in_array($content['objectType'], $this->categorisableObjectTypes)) {
                    $properties = ModUtil::apiFunc('«appName»', 'category', 'getAllProperties', array('ot' => $objectType));
                }

                // apply category filters
                if (in_array($objectType, $this->categorisableObjectTypes)) {
                    if (is_array($content['catIds']) && count($content['catIds']) > 0) {
                        $qb = ModUtil::apiFunc('«appName»', 'category', 'buildFilterClauses', array('qb' => $qb, 'ot' => $objectType, 'catids' => $content['catIds']));
                    }
                }
            «ENDIF»

            // get objects from database
            $currentPage = 1;
            $resultsPerPage = $content['amount'];
            list($query, $count) = $repository->getSelectWherePaginatedQuery($qb, $currentPage, $resultsPerPage);
            $entities = $repository->retrieveCollectionResult($query, $orderBy, true);

            // assign block vars and fetched data
            $this->view->assign('vars', $content)
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

            $blockinfo['content'] = $this->view->fetch($template);;

            // return the block to the theme
            return BlockUtil::themeBlock($blockinfo);
        }
    '''

    def private getDisplayTemplate(Application it) '''
        /**
         * Returns the template used for output.
         *
         * @param array $content Block variables.
         *
         * @return string the template path.
         */
        protected function getDisplayTemplate($content)
        {
            $templateFile = $content['template'];
            if ($templateFile == 'custom') {
                $templateFile = $content['customTemplate'];
            }

            $templateForObjectType = str_replace('itemlist_', 'itemlist_' . DataUtil::formatForOS($content['objectType']) . '_', $templateFile);

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
                $template = '«IF targets('1.3.x')»block«ELSE»Block«ENDIF»/itemlist.tpl';
            }

            return $template;
        }
    '''

    def private getSortParam(Application it) '''
        /**
         * Determines the order by parameter for item selection.
         *
         * @param array               $content    Block variables.
         * @param Doctrine_Repository $repository The repository used for data fetching.
         *
         * @return string the sorting clause.
         */
        protected function getSortParam($content, $repository)
        {
            if ($content['sorting'] == 'random') {
                return 'RAND()';
            }

            $sortParam = '';
            if ($content['sorting'] == 'newest') {
                $idFields = ModUtil::apiFunc('«appName»', 'selection', 'getIdFields', array('ot' => $content['objectType']));
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
            } elseif ($content['sorting'] == 'default') {
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
            «' '»* @param Request $request
            «' '»* @param array|string $content
            «' '»*
            «' '»* @return string
        «ENDIF»
         */
        public function modify(«IF targets('1.3.x')»$blockinfo«ELSE»Request $request, $content«ENDIF»)
        {
            «IF targets('1.3.x')»
                // Get current content
                $content = BlockUtil::varsFromContent($blockinfo['content']);

            «ENDIF»
            // set default values for all params which are not properly set
            $defaults = $this->getDefaults();
            $content = array_merge($defaults, $content);
            if (!isset($content['template'])) {
                $content['template'] = 'itemlist_' . DataUtil::formatForOS($content['objectType']) . '_display.tpl';
            }
            «IF hasCategorisableEntities»

                $content = $this->resolveCategoryIds($content);
            «ENDIF»

            $this->view->setCaching(Zikula_View::CACHE_DISABLED);

            // assign the appropriate values
            $this->view->assign($content);

            // clear the block cache
            $this->view->clear_cache('«IF targets('1.3.x')»block«ELSE»Block«ENDIF»/itemlist_display.tpl');
            $this->view->clear_cache('«IF targets('1.3.x')»block«ELSE»Block«ENDIF»/itemlist_' . DataUtil::formatForOS($content['objectType']) . '_display.tpl');
            $this->view->clear_cache('«IF targets('1.3.x')»block«ELSE»Block«ENDIF»/itemlist_display_description.tpl');
            $this->view->clear_cache('«IF targets('1.3.x')»block«ELSE»Block«ENDIF»/itemlist_' . DataUtil::formatForOS($content['objectType']) . '_display_description.tpl');

            // Return the output that has been generated by this function
            return $this->view->fetch('«IF targets('1.3.x')»block«ELSE»Block«ENDIF»/itemlist_modify.tpl');
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
            $content = BlockUtil::varsFromContent($blockinfo['content']);
            «IF !targets('1.3.x')»
                $request = $this->get('request');
            «ENDIF»

            «IF targets('1.3.x')»
                $content['objectType'] = $this->request->request->filter('objecttype', '«getLeadingEntity.name.formatForCode»', FILTER_SANITIZE_STRING);
                $content['sorting'] = $this->request->request->filter('sorting', 'default', FILTER_SANITIZE_STRING);
                $content['amount'] = (int) $this->request->request->filter('amount', 5, FILTER_VALIDATE_INT);
                $content['template'] = $this->request->request->get('template', '');
                $content['customTemplate'] = $this->request->request->get('customtemplate', '');
                $content['filter'] = $this->request->request->get('filter', '');
            «ELSE»
                $content['objectType'] = $request->request->getAlnum('objecttype', '«getLeadingEntity.name.formatForCode»');
                $content['sorting'] = $request->request->getAlpha('sorting', 'default');
                $content['amount'] = $request->request->getInt('amount', 5);
                $content['template'] = $request->request->getAlnum('template', '');
                $content['customTemplate'] = $request->request->getAlnum('customtemplate', '');
                $content['filter'] = $request->request->get('filter', '');
            «ENDIF»

            «IF targets('1.3.x')»
                $controllerHelper = new «appName»_Util_Controller($this->serviceManager);
            «ELSE»
                $controllerHelper = $this->get('«appName.formatForDB».controller_helper');
            «ENDIF»
            if (!in_array($content['objectType'], $controllerHelper->getObjectTypes('block'))) {
                $content['objectType'] = $controllerHelper->getDefaultObjectType('block');
            }
            «IF hasCategorisableEntities»

                $primaryRegistry = ModUtil::apiFunc('«appName»', 'category', 'getPrimaryProperty', array('ot' => $content['objectType']));
                $content['catIds'] = array($primaryRegistry => array());
                if (in_array($content['objectType'], $this->categorisableObjectTypes)) {
                    $content['catIds'] = ModUtil::apiFunc('«appName»', 'category', 'retrieveCategoriesFromRequest', array('ot' => $content['objectType']));
                }
            «ENDIF»

            // write back the new contents
            $blockinfo['content'] = BlockUtil::varsToContent($content);

            // clear the block cache
            $this->view->clear_cache('«IF targets('1.3.x')»block«ELSE»Block«ENDIF»/itemlist_display.tpl');
            $this->view->clear_cache('«IF targets('1.3.x')»block«ELSE»Block«ENDIF»/itemlist_' . ucfirst($content['objectType']) . '_display.tpl');
            $this->view->clear_cache('«IF targets('1.3.x')»block«ELSE»Block«ENDIF»/itemlist_display_description.tpl');
            $this->view->clear_cache('«IF targets('1.3.x')»block«ELSE»Block«ENDIF»/itemlist_' . ucfirst($content['objectType']) . '_display_description.tpl');

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
