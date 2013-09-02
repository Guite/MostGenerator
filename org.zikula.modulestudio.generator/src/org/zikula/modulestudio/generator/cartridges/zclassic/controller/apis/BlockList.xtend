package org.zikula.modulestudio.generator.cartridges.zclassic.controller.apis

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.cartridges.zclassic.view.additions.BlocksView
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class BlockList {
    @Inject extension FormattingExtensions = new FormattingExtensions()
    @Inject extension ModelBehaviourExtensions = new ModelBehaviourExtensions()
    @Inject extension ModelExtensions = new ModelExtensions()
    @Inject extension NamingExtensions = new NamingExtensions()
    @Inject extension Utils = new Utils()

    FileHelper fh = new FileHelper()

    def generate(Application it, IFileSystemAccess fsa) {
        println('Generating block for multiple objects')
        val blockPath = getAppSourceLibPath + 'Block/'
        val blockClassSuffix = if (!targets('1.3.5')) 'Block' else ''
        val blockFileName = 'ItemList' + blockClassSuffix + '.php'
        fsa.generateFile(blockPath + 'Base/' + blockFileName, listBlockBaseFile)
        fsa.generateFile(blockPath + blockFileName, listBlockFile)
        new BlocksView().generate(it, fsa)
    }

    def private listBlockBaseFile(Application it) '''
        «fh.phpFileHeader(it)»
        «listBlockBaseClass»
    '''

    def private listBlockFile(Application it) '''
        «fh.phpFileHeader(it)»
        «listBlockImpl»
    '''

    def private listBlockBaseClass(Application it) '''
        «IF !targets('1.3.5')»
            namespace «appNamespace»\Block\Base;

            use «appNamespace»\Util\ControllerUtil;

            use BlockUtil;
            use DataUtil;
            use ModUtil;
            use SecurityUtil;
            use Zikula_Controller_AbstractBlock;
            use Zikula_View;

        «ENDIF»
        /**
         * Generic item list block base class.
         */
        class «IF targets('1.3.5')»«appName»_Block_Base_ItemList«ELSE»ItemListBlock«ENDIF» extends Zikula_Controller_AbstractBlock
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
        /**
         * Initialise the block.
         */
        public function init()
        {
            SecurityUtil::registerPermissionSchema('«appName»:ItemListBlock:', 'Block title::');
            «IF hasCategorisableEntities»

                $this->categorisableObjectTypes = array(«FOR entity : getCategorisableEntities SEPARATOR ', '»'«entity.name.formatForCode»'«ENDFOR»);
            «ENDIF»
        }

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

        /**
         * Display the block.
         *
         * @param array $blockinfo the blockinfo structure
         *
         * @return string output of the rendered block
         */
        public function display($blockinfo)
        {
            // only show block content if the user has the required permissions
            if (!SecurityUtil::checkPermission('«appName»:ItemListBlock:', "$blockinfo[title]::", ACCESS_OVERVIEW)) {
                return false;
            }

            // check if the module is available at all
            if (!ModUtil::available('«appName»')) {
                return false;
            }

            // get current block content
            «IF targets('1.3.5')»
                $vars = BlockUtil::varsFromContent($blockinfo['content']);
            «ELSE»
                //$vars = BlockUtil::varsFromContent($blockinfo['content']);
                $vars = unserialize($blockinfo['content']);
            «ENDIF»
            $vars['bid'] = $blockinfo['bid'];

            // set default values for all params which are not properly set
            if (!isset($vars['objectType']) || empty($vars['objectType'])) {
                $vars['objectType'] = '«getLeadingEntity.name.formatForCode»';
            }
            if (!isset($vars['sorting']) || empty($vars['sorting'])) {
                $vars['sorting'] = 'default';
            }
            if (!isset($vars['amount']) || !is_numeric($vars['amount'])) {
                $vars['amount'] = 5;
            }
            if (!isset($vars['template'])) {
                $vars['template'] = 'itemlist_' . DataUtil::formatForOS($vars['objectType']) . '_display.tpl';
            }
            if (!isset($vars['customTemplate'])) {
                $vars['customTemplate'] = '';
            }
            if (!isset($vars['filter'])) {
                $vars['filter'] = '';
            }
            «IF hasCategorisableEntities»

                if (!isset($vars['catIds'])) {
                    $primaryRegistry = ModUtil::apiFunc('«appName»', 'category', 'getPrimaryProperty', array('ot' => $vars['objectType']));
                    $vars['catIds'] = array($primaryRegistry => array());
                    // backwards compatibility
                    if (isset($vars['catId'])) {
                        $vars['catIds'][$primaryRegistry][] = $vars['catId'];
                        unset($vars['catId']);
                    }
                } elseif (!is_array($vars['catIds'])) {
                    $vars['catIds'] = explode(',', $vars['catIds']);
                }
            «ENDIF»

            ModUtil::initOOModule('«appName»');

            $controllerHelper = new «IF targets('1.3.5')»«appName»_Util_Controller«ELSE»ControllerUtil«ENDIF»($this->serviceManager«IF !targets('1.3.5')», ModUtil::getModule($this->name)«ENDIF»);

            $utilArgs = array('name' => 'list');
            if (!isset($vars['objectType']) || !in_array($vars['objectType'], $controllerHelper->getObjectTypes('block', $utilArgs))) {
                $vars['objectType'] = $controllerHelper->getDefaultObjectType('block', $utilArgs);
            }

            $objectType = $vars['objectType'];

            «IF targets('1.3.5')»
                $entityClass = '«appName»_Entity_' . ucwords($objectType);
            «ELSE»
                $entityClass = '\\«vendor.formatForCodeCapital»\\«name.formatForCodeCapital»Module\\Entity\\' . ucwords($objectType) . 'Entity';
            «ENDIF»
            $entityManager = $this->serviceManager->getService('doctrine.entitymanager');
            $repository = $entityManager->getRepository($entityClass);

            $where = $vars['filter'];
            «IF hasCategorisableEntities»
                $properties = null;
                if (in_array($vars['objectType'], $this->categorisableObjectTypes)) {
                    $properties = ModUtil::apiFunc('«appName»', 'category', 'getAllProperties', array('ot' => $objectType));
                }

                // apply category filters
                if (in_array($objectType, $this->categorisableObjectTypes)) {
                    if (is_array($vars['catIds']) && count($vars['catIds']) > 0) {
                        $categoryFiltersPerRegistry = ModUtil::apiFunc('«appName»', 'category', 'buildFilterClauses', array('ot' => $objectType, 'catids' => $vars['catIds']));
                        if (count($categoryFiltersPerRegistry) > 0) {
                            if (!empty($where)) {
                                $where .= ' AND ';
                            }
                            $where .= '(' . implode(' OR ', $categoryFiltersPerRegistry) . ')';
                        }
                    }
                }
            «ENDIF»

            $this->view->setCaching(Zikula_View::CACHE_ENABLED);
            // set cache id
            $component = '«appName»:' . ucwords($objectType) . ':';
            $instance = '::';
            $accessLevel = ACCESS_READ;
            if (SecurityUtil::checkPermission($component, $instance, ACCESS_COMMENT)) {
                $accessLevel = ACCESS_COMMENT;
            }
            if (SecurityUtil::checkPermission($component, $instance, ACCESS_EDIT)) {
                $accessLevel = ACCESS_EDIT;
            }
            $this->view->setCacheId('view|ot_' . $objectType . '_sort_' . $vars['sorting'] . '_amount_' . $vars['amount'] . '_' . $accessLevel);

            $template = $this->getDisplayTemplate($vars);

            // if page is cached return cached content
            if ($this->view->is_cached($template)) {
                $blockinfo['content'] = $this->view->fetch($template);
                return BlockUtil::themeBlock($blockinfo);
            }

            // get objects from database
            $selectionArgs = array(
                'ot' => $objectType,
                'where' => $where,
                'orderBy' => $this->getSortParam($vars, $repository),
                'currentPage' => 1,
                'resultsPerPage' => $vars['amount']
            );
            list($entities, $objectCount) = ModUtil::apiFunc('«appName»', 'selection', 'getEntitiesPaginated', $selectionArgs);

            // assign block vars and fetched data
            $this->view->assign('vars', $vars)
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

        /**
         * Returns the template used for output.
         *
         * @param array $vars List of block variables.
         *
         * @return string the template path.
         */
        protected function getDisplayTemplate($vars)
        {
            $templateFile = $vars['template'];
            if ($templateFile == 'custom') {
                $templateFile = $vars['customTemplate'];
            }

            $templateForObjectType = str_replace('itemlist_', 'itemlist_' . DataUtil::formatForOS($vars['objectType']) . '_', $templateFile);

            $template = '';
            if ($this->view->template_exists('«IF targets('1.3.5')»contenttype«ELSE»ContentType«ENDIF»/' . $templateForObjectType)) {
                $template = '«IF targets('1.3.5')»contenttype«ELSE»ContentType«ENDIF»/' . $templateForObjectType;
            } elseif ($this->view->template_exists('«IF targets('1.3.5')»block«ELSE»Block«ENDIF»/' . $templateForObjectType)) {
                $template = '«IF targets('1.3.5')»block«ELSE»Block«ENDIF»/' . $templateForObjectType;
            } elseif ($this->view->template_exists('«IF targets('1.3.5')»contenttype«ELSE»ContentType«ENDIF»/' . $templateFile)) {
                $template = '«IF targets('1.3.5')»contenttype«ELSE»ContentType«ENDIF»/' . $templateFile;
            } elseif ($this->view->template_exists('«IF targets('1.3.5')»block«ELSE»Block«ENDIF»/' . $templateFile)) {
                $template = '«IF targets('1.3.5')»block«ELSE»Block«ENDIF»/' . $templateFile;
            } else {
                $template = '«IF targets('1.3.5')»block«ELSE»Block«ENDIF»/itemlist.tpl';
            }

            return $template;
        }

        /**
         * Determines the order by parameter for item selection.
         *
         * @param array               $vars       List of block variables.
         * @param Doctrine_Repository $repository The repository used for data fetching.
         *
         * @return string the sorting clause.
         */
        protected function getSortParam($vars, $repository)
        {
            if ($vars['sorting'] == 'random') {
                return 'RAND()';
            }

            $sortParam = '';
            if ($vars['sorting'] == 'newest') {
                $idFields = ModUtil::apiFunc('«appName»', 'selection', 'getIdFields', array('ot' => $vars['objectType']));
                if (count($idFields) == 1) {
                    $sortParam = $idFields[0] . ' DESC';
                } else {
                    foreach ($idFields as $idField) {
                        if (!empty($sortParam)) {
                            $sortParam .= ', ';
                        }
                        $sortParam .= $idField . ' ASC';
                    }
                }
            } elseif ($vars['sorting'] == 'default') {
                $sortParam = $repository->getDefaultSortingField() . ' ASC';
            }

            return $sortParam;
        }

        /**
         * Modify block settings.
         *
         * @param array $blockinfo the blockinfo structure
         *
         * @return string output of the block editing form.
         */
        public function modify($blockinfo)
        {
            // Get current content
            «IF targets('1.3.5')»
                $vars = BlockUtil::varsFromContent($blockinfo['content']);
            «ELSE»
                //$vars = BlockUtil::varsFromContent($blockinfo['content']);
                $vars = unserialize($blockinfo['content']);
            «ENDIF»

            // set default values for all params which are not properly set
            if (!isset($vars['objectType']) || empty($vars['objectType'])) {
                $vars['objectType'] = '«getLeadingEntity.name.formatForCode»';
            }
            if (!isset($vars['sorting']) || empty($vars['sorting'])) {
                $vars['sorting'] = 'default';
            }
            if (!isset($vars['amount']) || !is_numeric($vars['amount'])) {
                $vars['amount'] = 5;
            }
            if (!isset($vars['template'])) {
                $vars['template'] = 'itemlist_' . DataUtil::formatForOS($vars['objectType']) . '_display.tpl';
            }
            if (!isset($vars['customTemplate'])) {
                $vars['customTemplate'] = '';
            }
            if (!isset($vars['filter'])) {
                $vars['filter'] = '';
            }
            «IF hasCategorisableEntities»

                if (!isset($vars['catIds'])) {
                    $primaryRegistry = ModUtil::apiFunc('«appName»', 'category', 'getPrimaryProperty', array('ot' => $vars['objectType']));
                    $vars['catIds'] = array($primaryRegistry => array());
                    // backwards compatibility
                    if (isset($vars['catId'])) {
                        $vars['catIds'][$primaryRegistry][] = $vars['catId'];
                        unset($vars['catId']);
                    }
                } elseif (!is_array($vars['catIds'])) {
                    $vars['catIds'] = explode(',', $vars['catIds']);
                }
            «ENDIF»

            $this->view->setCaching(Zikula_View::CACHE_DISABLED);

            // assign the approriate values
            $this->view->assign($vars);

            // clear the block cache
            $this->view->clear_cache('«IF targets('1.3.5')»block«ELSE»Block«ENDIF»/itemlist_display.tpl');
            $this->view->clear_cache('«IF targets('1.3.5')»block«ELSE»Block«ENDIF»/itemlist_' . DataUtil::formatForOS($vars['objectType']) . '_display.tpl');
            $this->view->clear_cache('«IF targets('1.3.5')»block«ELSE»Block«ENDIF»/itemlist_display_description.tpl');
            $this->view->clear_cache('«IF targets('1.3.5')»block«ELSE»Block«ENDIF»/itemlist_' . DataUtil::formatForOS($vars['objectType']) . '_display_description.tpl');

            // Return the output that has been generated by this function
            return $this->view->fetch('«IF targets('1.3.5')»block«ELSE»Block«ENDIF»/itemlist_modify.tpl');
        }

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
            $vars = BlockUtil::varsFromContent($blockinfo['content']);

            $vars['objectType'] = $this->request->request->filter('objecttype', '«getLeadingEntity.name.formatForCode»', FILTER_SANITIZE_STRING);
            $vars['sorting'] = $this->request->request->filter('sorting', 'default', FILTER_SANITIZE_STRING);
            $vars['amount'] = (int) $this->request->request->filter('amount', 5, FILTER_VALIDATE_INT);
            $vars['template'] = $this->request->request->get('template', '');
            $vars['customTemplate'] = $this->request->request->get('customtemplate', '');
            $vars['filter'] = $this->request->request->get('filter', '');

            $controllerHelper = new «IF targets('1.3.5')»«appName»_Util_Controller«ELSE»ControllerUtil«ENDIF»($this->serviceManager«IF !targets('1.3.5')», ModUtil::getModule($this->name)«ENDIF»);

            if (!in_array($vars['objectType'], $controllerHelper->getObjectTypes('block'))) {
                $vars['objectType'] = $controllerHelper->getDefaultObjectType('block');
            }
            «IF hasCategorisableEntities»

                $primaryRegistry = ModUtil::apiFunc('«appName»', 'category', 'getPrimaryProperty', array('ot' => $vars['objectType']));
                $vars['catIds'] = array($primaryRegistry => array());
                if (in_array($vars['objectType'], $this->categorisableObjectTypes)) {
                    $vars['catIds'] = ModUtil::apiFunc('«appName»', 'category', 'retrieveCategoriesFromRequest', array('ot' => $vars['objectType']));
                }
            «ENDIF»

            // write back the new contents
            $blockinfo['content'] = BlockUtil::varsToContent($vars);

            // clear the block cache
            $this->view->clear_cache('«IF targets('1.3.5')»block«ELSE»Block«ENDIF»/itemlist_display.tpl');
            $this->view->clear_cache('«IF targets('1.3.5')»block«ELSE»Block«ENDIF»/itemlist_' . ucwords($vars['objectType']) . '_display.tpl');
            $this->view->clear_cache('«IF targets('1.3.5')»block«ELSE»Block«ENDIF»/itemlist_display_description.tpl');
            $this->view->clear_cache('«IF targets('1.3.5')»block«ELSE»Block«ENDIF»/itemlist_' . ucwords($vars['objectType']) . '_display_description.tpl');

            return $blockinfo;
        }
    '''

    def private listBlockImpl(Application it) '''
        «IF !targets('1.3.5')»
            namespace «appNamespace»\Block;

        «ENDIF»
        /**
         * Generic item list block implementation class.
         */
        «IF targets('1.3.5')»
        class «appName»_Block_ItemList extends «appName»_Block_Base_ItemList
        «ELSE»
        class ItemListBlock extends Base\ItemListBlock
        «ENDIF»
        {
            // feel free to extend the item list block here
        }
    '''
}
