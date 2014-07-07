package org.zikula.modulestudio.generator.cartridges.zclassic.controller.apis

import de.guite.modulestudio.metamodel.modulestudio.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.cartridges.zclassic.view.additions.ContentTypeSingleView
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.GeneratorSettingsExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ContentTypeSingle {

    extension FormattingExtensions = new FormattingExtensions
    extension GeneratorSettingsExtensions = new GeneratorSettingsExtensions
    extension ModelExtensions = new ModelExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    FileHelper fh = new FileHelper

    def generate(Application it, IFileSystemAccess fsa) {
        println('Generating content type for single objects')
        generateClassPair(fsa, getAppSourceLibPath + 'ContentType/Item.php',
            fh.phpFileContent(it, contentTypeBaseClass), fh.phpFileContent(it, contentTypeImpl)
        )
        new ContentTypeSingleView().generate(it, fsa)
    }

    def private contentTypeBaseClass(Application it) '''
        «IF !targets('1.3.5')»
            namespace «appNamespace»\ContentType\Base;

            use ModUtil;
            use ServiceUtil;
            use ZLanguage;

        «ENDIF»
        /**
         * Generic single item display content plugin base class.
         */
        «IF targets('1.3.5')»
        class «appName»_ContentType_Base_Item extends Content_AbstractContentType
        «ELSE»
        class Item extends \Content_AbstractContentType
        «ENDIF»
        {
            «contentTypeBaseImpl»
        }
    '''

    def private contentTypeBaseImpl(Application it) '''
        protected $objectType;
        protected $id;
        protected $displayMode;

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
            return 'Item';
        }

        /**
         * Returns the title of this content type.
         *
         * @return string The content type title.
         */
        public function getTitle()
        {
            $dom = ZLanguage::getModuleDomain('«appName»');

            return __('«appName» detail view', $dom);
        }

        /**
         * Returns the description of this content type.
         *
         * @return string The content type description.
         */
        public function getDescription()
        {
            $dom = ZLanguage::getModuleDomain('«appName»');

            return __('Display or link a single «appName» object.', $dom);
        }

        /**
         * Loads the data.
         *
         * @param array $data Data array with parameters.
         */
        public function loadData(&$data)
        {
            $serviceManager = ServiceUtil::getManager();
            «IF targets('1.3.5')»
                $controllerHelper = new «appName»_Util_Controller($serviceManager);
            «ELSE»
                $controllerHelper = $serviceManager->get('«appName.formatForDB».controller_helper');
            «ENDIF»

            $utilArgs = array('name' => 'detail');
            if (!isset($data['objectType']) || !in_array($data['objectType'], $controllerHelper->getObjectTypes('contentType', $utilArgs))) {
                $data['objectType'] = $controllerHelper->getDefaultObjectType('contentType', $utilArgs);
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

        /**
         * Displays the data.
         *
         * @return string The returned output.
         */
        public function display()
        {
            if ($this->id != null && !empty($this->displayMode)) {
                return ModUtil::func('«appName»', 'external', 'display', $this->getDisplayArguments());
            }

            return '';
        }

        /**
         * Displays the data for editing.
         */
        public function displayEditing()
        {
            if ($this->id != null && !empty($this->displayMode)) {
                return ModUtil::func('«appName»', 'external', 'display', $this->getDisplayArguments());
            }
            $dom = ZLanguage::getModuleDomain('«appName»');

            return __('No item selected.', $dom);
        }

        /**
         * Returns common arguments for display data selection with the external api.
         *
         * @return array Display arguments.
         */
        protected function getDisplayArguments()
        {
            return array('objectType' => $this->objectType,
                         'source' => 'contentType',
                         'displayMode' => $this->displayMode,
                         'id' => $this->id
            );
        }

        /**
         * Returns the default data.
         *
         * @return array Default data and parameters.
         */
        public function getDefaultData()
        {
            return array('objectType' => '«getLeadingEntity.name.formatForCode»',
                         'id' => null,
                         'displayMode' => 'embed');
        }

        /**
         * Executes additional actions for the editing mode.
         */
        public function startEditing()
        {
            // ensure our custom plugins are loaded
            «IF targets('1.3.5')»
                array_push($this->view->plugins_dir, '«rootFolder»/«appName»/templates/plugins');
            «ELSE»
                array_push($this->view->plugins_dir, '«rootFolder»/«getViewPath»/plugins');
            «ENDIF»

            // required as parameter for the item selector plugin
            $this->view->assign('objectType', $this->objectType);
        }
    '''

    def private contentTypeImpl(Application it) '''
        «IF !targets('1.3.5')»
            namespace «appNamespace»\ContentType;

            use «appNamespace»\ContentType\Base\Item as BaseItem;

        «ENDIF»
        /**
         * Generic single item display content plugin implementation class.
         */
        «IF targets('1.3.5')»
        class «appName»_ContentType_Item extends «appName»_ContentType_Base_Item
        «ELSE»
        class Item extends BaseItem
        «ENDIF»
        {
            // feel free to extend the content type here
        }
    '''
}
