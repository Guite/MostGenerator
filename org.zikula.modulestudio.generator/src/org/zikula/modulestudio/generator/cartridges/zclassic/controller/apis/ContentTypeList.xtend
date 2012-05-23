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
        protected $filter;
        «IF hasCategorisableEntities»
            protected $categorisableObjectTypes;
            protected $mainCategory;
            protected $catId;
        «ENDIF»

        public function getModule()
        {
            return '«appName»';
        }

        public function getName()
        {
            return 'ItemList';
        }

        public function getTitle()
        {
            $dom = ZLanguage::getModuleDomain('«appName»');
            return __('«appName» list view', $dom);
        }

        public function getDescription()
        {
            $dom = ZLanguage::getModuleDomain('«appName»');
            return __('Display list of «appName» objects.', $dom);
        }

        public function loadData(&$data)
        {
            $utilArgs = array('name' => 'list');
            if (!isset($data['objectType']) || !in_array($data['objectType'], «appName»_Util_Controller::getObjectTypes('contentType', $utilArgs))) {
                $data['objectType'] = «appName»_Util_Controller::getDefaultObjectType('contentType', $utilArgs);
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
            if (!isset($data['filter'])) {
                $data['filter'] = '';
            }
            «IF hasCategorisableEntities»
                if (!isset($data['mainCategory'])) {
                    $data['mainCategory'] = null;
                }
                if (!isset($data['catId'])) {
                    $data['catId'] = 0;
                }

                $this->categorisableObjectTypes = array(«FOR entity : getCategorisableEntities SEPARATOR ', '»'«entity.name.formatForCode»'«ENDFOR»);
            «ENDIF»

            $this->sorting = $data['sorting'];
            $this->amount = $data['amount'];
            $this->template = $data['template'];
            $this->filter = $data['filter'];
            «IF hasCategorisableEntities»
                $this->mainCategory = $data['mainCategory'];
                $this->catId = $data['catId'];
            «ENDIF»
        }

        public function display()
        {
            $dom = ZLanguage::getModuleDomain('«appName»');
            ModUtil::initOOModule('«appName»');

            $serviceManager = ServiceUtil::getManager();
            $entityManager = $serviceManager->getService('doctrine.entitymanager');
            $repository = $entityManager->getRepository('«appName»_Entity_' . ucfirst($this->objectType));

            $where = $this->filter;
            «IF hasCategorisableEntities»
                if (in_array($this->objectType, $this->categorisableObjectTypes)) {
                    if ($this->catId > 0) {
                        if (!empty($where)) {
                            $where .= ' AND ';
                        }
                        $where .= 'tblCategories.category = ' . DataUtil::formatForStore($this->catId);
                    }
                }
            «ENDIF»

            $resultsPerPage = (($this->amount) ? $this->amount : 1);

            // get objects from database
            $selectionArgs = array(
                'ot' => $objectType,
                'where' => $where,
                'orderBy' => $this->getSortParam($repository),
                'currentPage' => 1,
                'resultsPerPage' => $resultsPerPage
            );
            list($entities, $objectCount) = ModUtil::apiFunc('«appName»', 'selection', 'getEntitiesPaginated', $selectionArgs);

            $this->view->setCaching(true);

            $data = array('objectType' => $this->objectType, 'sorting' => $this->sorting, 'amount' => $this->amount, 'filter' => $this->filter, 'template' => $this->template);

            // assign block vars and fetched data
            $this->view->assign('vars', $data)
                       ->assign('objectType', $this->objectType)
                       ->assign('items', $entities)
                       ->assign($repository->getAdditionalTemplateParameters('contentType'));

            $output = '';
            if (!empty($this->template) && $this->view->template_exists('contenttype/' . $this->template)) {
                $output = $this->view->fetch('contenttype/' . $this->template);
            }
            $templateForObjectType = str_replace('itemlist_', 'itemlist_' . $this->objectType . '_', $this->template);
            if ($this->view->template_exists('contenttype/' . $templateForObjectType)) {
                $output = $this->view->fetch('contenttype/' . $templateForObjectType);
            } elseif ($this->view->template_exists('contenttype/' . $this->template)) {
                $output = $this->view->fetch('contenttype/' . $this->template);
            } else {
                $output = $this->view->fetch('contenttype/itemlist_display.tpl');
            }

            return $output;
        }

        /**
         * Determines the order by parameter for item selection.
         *
         * @param array $blockinfo a blockinfo structure
         * @return string the sorting clause
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

        public function displayEditing()
        {
            return $this->display();
        }

        public function getDefaultData()
        {
            return array('objectType' => '«getLeadingEntity.name.formatForCode»',
                         'sorting' => 'default',
                         'amount' => 1,
                         'template' => 'itemlist_display.tpl',
                         'filter' => '');
        }

        public function startEditing()
        {
            $dom = ZLanguage::getModuleDomain('«appName»');
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
