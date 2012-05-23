package org.zikula.modulestudio.generator.cartridges.zclassic.controller.apis

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.cartridges.zclassic.view.additions.ContentTypeSingleView
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ContentTypeSingle {
    @Inject extension FormattingExtensions = new FormattingExtensions()
    @Inject extension ModelExtensions = new ModelExtensions()
    @Inject extension NamingExtensions = new NamingExtensions()
    @Inject extension Utils = new Utils()

    FileHelper fh = new FileHelper()

    def generate(Application it, IFileSystemAccess fsa) {
        val contentTypePath = appName.getAppSourceLibPath + 'ContentType/'
        fsa.generateFile(contentTypePath + 'Base/Item.php', contentTypeBaseFile)
        fsa.generateFile(contentTypePath + 'Item.php', contentTypeFile)
        new ContentTypeSingleView().generate(it, fsa)
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
		 * Generic single item display content plugin base class.
		 */
		class «appName»_ContentType_Base_Item extends Content_AbstractContentType
		{
		    «contentTypeBaseImpl»
		}
    '''

    def private contentTypeBaseImpl(Application it) '''
        protected $objectType;
        protected $id;
        protected $displayMode;

        public function getModule()
        {
            return '«appName»';
        }

        public function getName()
        {
            return 'Item';
        }

        public function getTitle()
        {
            $dom = ZLanguage::getModuleDomain('«appName»');
            return __('«appName» detail view', $dom);
        }

        public function getDescription()
        {
            $dom = ZLanguage::getModuleDomain('«appName»');
            return __('Display or link a single «appName» object.', $dom);
        }

        public function loadData(&$data)
        {
            $utilArgs = array('name' => 'detail');
            if (!isset($data['objectType']) || !in_array($data['objectType'], «appName»_Util_Controller::getObjectTypes('contentType', $utilArgs))) {
                $data['objectType'] = «appName»_Util_Controller::getDefaultObjectType('contentType', $utilArgs);
            }

            $this->objectType = $data['objectType'];

            if (!isset($data['id'])) {
                $data['id'] = null;
            }
            if (!isset($data['displayMode'])) {
                $data['displayMode'] = 'embed';
            }

            $this->id = $data['id'];
            $this->displayMode = $data['displayMode'];
        }

        public function display()
        {
            if ($this->id != null && !empty($this->displayMode)) {
                return ModUtil::func('«appName»', 'external', 'display', $this->getDisplayArguments());
            }
            return '';
        }

        public function displayEditing()
        {
            if ($this->id != null && !empty($this->displayMode)) {
                return ModUtil::func('«appName»', 'external', 'display', $this->getDisplayArguments());
            }
            $dom = ZLanguage::getModuleDomain('«appName»');
            return __('No medium selected.', $dom);
        }

        protected function getDisplayArguments()
        {
            return array('objectType' => $this->objectType,
                         'source' => 'contentType',
                         'displayMode' => $this->displayMode,
                         'id' => $this->id
            );
        }

        public function getDefaultData()
        {
            return array('objectType' => '«getLeadingEntity.name.formatForCode»',
                         'id' => null,
                         'displayMode' => 'embed');
        }

        public function startEditing()
        {
            $dom = ZLanguage::getModuleDomain('«appName»');
            array_push($this->view->plugins_dir, 'modules/«appName»/templates/plugins');

            // required as parameter for the item selector plugin
            $this->view->assign('objectType', $this->objectType);
        }
    '''

    def private contentTypeImpl(Application it) '''
        /**
         * Generic single item display content plugin implementation class.
         */
        class «appName»_ContentType_Item extends «appName»_ContentType_Base_Item
        {
            // feel free to extend the content type here
        }

        function «appName»_Api_ContentTypes_item($args)
        {
            return new «appName»_Api_ContentTypes_itemPlugin();
        }
    '''
}
