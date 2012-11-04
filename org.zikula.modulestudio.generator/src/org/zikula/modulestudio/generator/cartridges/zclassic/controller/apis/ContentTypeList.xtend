package org.zikula.modulestudio.generator.cartridges.zclassic.controller.apis

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.cartridges.zclassic.view.additions.ContentTypeListView
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ContentTypeList {
    @Inject extension FormattingExtensions = new FormattingExtensions()
    @Inject extension ModelBehaviourExtensions = new ModelBehaviourExtensions()
    @Inject extension ModelExtensions = new ModelExtensions()
    @Inject extension NamingExtensions = new NamingExtensions()
    @Inject extension Utils = new Utils()

    FileHelper fh = new FileHelper()

    def generate(Application it, IFileSystemAccess fsa) {
        println('Generating content type for multiple objects')
        val contentTypePath = appName.getAppSourceLibPath + 'ContentType/'
        fsa.generateFile(contentTypePath + 'Base/ItemList.php', contentTypeBaseFile)
        fsa.generateFile(contentTypePath + 'ItemList.php', contentTypeFile)
        new ContentTypeListView().generate(it, fsa)
    }

    def private contentTypeBaseFile(Application it) '''
    	«fh.phpFileHeader(it)»
    	«contentTypeBaseClass»
    '''

    def private contentTypeFile(Application it) '''
    	«fh.phpFileHeader(it)»
    	«contentTypeImpl»
    '''

    def private contentTypeBaseClass(Application it) '''
		/**
		 * Generic item list content plugin base class.
		 */
		class «appName»_ContentType_Base_ItemList extends Content_AbstractContentType
		{
		    «contentTypeBaseImpl»
		}
    '''

    def private contentTypeBaseImpl(Application it) '''
        protected $objectType;
        protected $sorting;
        protected $amount;
        protected $template;
        protected $customTemplate;
        protected $filter;
        «IF hasCategorisableEntities»
            protected $categorisableObjectTypes;
            protected $catProperties;
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
            $dom = ZLanguage::getModuleDomain('«appName»');
            return __('«appName» list view', $dom);
        }

        /**
         * Returns the description of this content type.
         *
         * @return string The content type description.
         */
        public function getDescription()
        {
            $dom = ZLanguage::getModuleDomain('«appName»');
            return __('Display list of «appName» objects.', $dom);
        }

        /**
         * Loads the data.
         *
         * @param array $data Data array with parameters.
         */
        public function loadData(&$data)
        {
            $serviceManager = ServiceUtil::getManager();
            $controllerHelper = new «appName»_Util_Controller($serviceManager);

            $utilArgs = array('name' => 'list');
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
                $data['template'] = 'itemlist_' . $this->objectType . '_display.tpl';
            }
            if (!isset($data['customTemplate'])) {
                $data['customTemplate'] = '';
            }
            if (!isset($data['filter'])) {
                $data['filter'] = '';
            }
            «IF hasCategorisableEntities»

                if (!isset($data['catIds'])) {
                    $primaryRegistry = ModUtil::apiFunc('«appName»', 'category', 'getPrimaryProperty', array('ot' => $vars['objectType']));
                    $data['catIds'] = array($primaryRegistry => array());
                    // backwards compatibility
                    if (isset($data['catId'])) {
                        $data['catIds'][$primaryRegistry][] = $data['catId'];
                        unset($data['catId']);
                    }
                } elseif (!is_array($data['catIds'])) {
                    $data['catIds'] = explode(',', $data['catIds']);
                }

                $this->categorisableObjectTypes = array(«FOR entity : getCategorisableEntities SEPARATOR ', '»'«entity.name.formatForCode»'«ENDFOR»);
            «ENDIF»

            $this->sorting = $data['sorting'];
            $this->amount = $data['amount'];
            $this->template = $data['template'];
            $this->customTemplate = $data['customTemplate'];
            $this->filter = $data['filter'];
            «IF hasCategorisableEntities»

                // fetch category properties
                $this->catProperties = null;
                if (in_array($this->objectType, $this->categorisableObjectTypes)) {
                    $this->catProperties = ModUtil::apiFunc('«appName»', 'category', 'getAllProperties', array('ot' => $this->objectType));
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
            ModUtil::initOOModule('«appName»');

            $serviceManager = ServiceUtil::getManager();
            $entityManager = $serviceManager->getService('doctrine.entitymanager');
            $repository = $entityManager->getRepository('«appName»_Entity_' . ucfirst($this->objectType));

            $where = $this->filter;
            «IF hasCategorisableEntities»

                // apply category filters
                if (in_array($this->objectType, $this->categorisableObjectTypes)) {
                    if (is_array($this->catIds) && count($this->catIds) > 0) {
                        $categoryFiltersPerRegistry = ModUtil::apiFunc('«appName»', 'category', 'buildFilterClauses', array('ot' => $this->objectType, 'catids' => $this->catIds));
                        if (count($categoryFiltersPerRegistry) > 0) {
                            if (!empty($where)) {
                                $where .= ' AND ';
                            }
                            $where .= '(' . implode(' OR ', $categoryFiltersPerRegistry) . ')';
                        }
                    }
                }
            «ENDIF»

            // ensure that the view does not look for templates in the Content module (#218)
            $this->view->toplevelmodule = '«appName»';

            $this->view->setCaching(Zikula_View::CACHE_ENABLED);
            // set cache id
            $component = '«appName»:' . ucwords($this->objectType) . ':';
            $instance = '::';
            $accessLevel = ACCESS_READ;
            if (SecurityUtil::checkPermission($component, $instance, ACCESS_COMMENT)) $accessLevel = ACCESS_COMMENT;
            if (SecurityUtil::checkPermission($component, $instance, ACCESS_EDIT)) $accessLevel = ACCESS_EDIT;
            $this->view->setCacheId('view|ot_' . $this->objectType . '_sort_' . $this->sorting . '_amount_' . $this->amount . '_' . $accessLevel);

            $template = $this->getDisplayTemplate();

            // if page is cached return cached content
            if ($this->view->is_cached($template)) {
                return $this->view->fetch($template);
            }

            $resultsPerPage = (($this->amount) ? $this->amount : 1);

            // get objects from database
            $selectionArgs = array(
                'ot' => $this->objectType,
                'where' => $where,
                'orderBy' => $this->getSortParam($repository),
                'currentPage' => 1,
                'resultsPerPage' => $resultsPerPage
            );
            list($entities, $objectCount) = ModUtil::apiFunc('«appName»', 'selection', 'getEntitiesPaginated', $selectionArgs);

            $data = array('objectType' => $this->objectType,
                          'catids' => $this->catIds,
                          'sorting' => $this->sorting,
                          'amount' => $this->amount,
                          'template' => $this->template,
                          'customTemplate' => $this->customTemplate,
                          'filter' => $this->filter);

            // assign block vars and fetched data
            $this->view->assign('vars', $data)
                       ->assign('objectType', $this->objectType)
                       ->assign('items', $entities)
                       ->assign($repository->getAdditionalTemplateParameters('contentType'));
            «IF hasCategorisableEntities»

                // assign category properties
                $this->view->assign('properties', $this->catProperties);
            «ENDIF»

            $output = $this->view->fetch($template);

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
            if ($this->view->template_exists('contenttype/' . $templateForObjectType)) {
                $template = 'contenttype/' . $templateForObjectType;
            } elseif ($this->view->template_exists('contenttype/' . $templateFile)) {
                $template = 'contenttype/' . $templateFile;
            } else {
                $template = 'contenttype/itemlist_display.tpl';
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
                $idFields = ModUtil::apiFunc('«appName»', 'selection', 'getIdFields', array('ot' => $this->objectType));
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
            return array('objectType' => '«getLeadingEntity.name.formatForCode»',
                         'sorting' => 'default',
                         'amount' => 1,
                         'template' => 'itemlist_display.tpl',
                         'customTemplate' => '',
                         'filter' => '');
        }

        /**
         * Executes additional actions for the editing mode.
         */
        public function startEditing()
        {
            // ensure that the view does not look for templates in the Content module (#218)
            $this->view->toplevelmodule = '«appName»';

            // ensure our custom plugins are loaded
            array_push($this->view->plugins_dir, 'modules/«appName»/templates/plugins');
        }
    '''

    def private contentTypeImpl(Application it) '''
        /**
         * Generic item list content plugin implementation class.
         */
        class «appName»_ContentType_ItemList extends «appName»_ContentType_Base_ItemList
        {
            // feel free to extend the content type here
        }

        function «appName»_Api_ContentTypes_itemlist($args)
        {
            return new «appName»_Api_ContentTypes_itemListPlugin();
        }
    '''
}
