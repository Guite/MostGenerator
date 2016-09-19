package org.zikula.modulestudio.generator.cartridges.zclassic.controller.apis

import de.guite.modulestudio.metamodel.Application
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
        «IF !targets('1.3.x')»
            namespace «appNamespace»\ContentType\Base;

            use ModUtil;
            use ServiceUtil;

        «ENDIF»
        /**
         * Generic single item display content plugin base class.
         */
        «IF targets('1.3.x')»
        abstract class «appName»_ContentType_Base_AbstractItem extends Content_AbstractContentType
        «ELSE»
        abstract class AbstractItem extends \Content_AbstractContentType
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
            return 'Item';
        }

        /**
         * Returns the title of this content type.
         *
         * @return string The content type title
         */
        public function getTitle()
        {
            «IF targets('1.3.x')»
                $dom = ZLanguage::getModuleDomain('«appName»');

                return __('«appName» detail view', $dom);
            «ELSE»
                $serviceManager = ServiceUtil::getManager();

                return $serviceManager->get('translator.default')->__('«appName» detail view');
            «ENDIF»
        }

        /**
         * Returns the description of this content type.
         *
         * @return string The content type description
         */
        public function getDescription()
        {
            «IF targets('1.3.x')»
                $dom = ZLanguage::getModuleDomain('«appName»');

                return __('Display or link a single «appName» object.', $dom);
            «ELSE»
                $serviceManager = ServiceUtil::getManager();

                return $serviceManager->get('translator.default')->__('Display or link a single «appName» object.');
            «ENDIF»
        }

        /**
         * Loads the data.
         *
         * @param array $data Data array with parameters
         */
        public function loadData(&$data)
        {
            $serviceManager = ServiceUtil::getManager();
            «IF targets('1.3.x')»
                $controllerHelper = new «appName»_Util_Controller($serviceManager);
            «ELSE»
                $controllerHelper = $serviceManager->get('«appService».controller_helper');
            «ENDIF»

            $utilArgs = «IF targets('1.3.x')»array(«ELSE»[«ENDIF»'name' => 'detail'«IF targets('1.3.x')»)«ELSE»]«ENDIF»;
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
         * @return string The returned output
         */
        public function display()
        {
            if (null !== $this->id && !empty($this->displayMode)) {
                return ModUtil::func('«appName»', 'external', 'display', $this->getDisplayArguments());
            }

            return '';
        }

        /**
         * Displays the data for editing.
         */
        public function displayEditing()
        {
            if (null !== $this->id && !empty($this->displayMode)) {
                return ModUtil::func('«appName»', 'external', 'display', $this->getDisplayArguments());
            }

            «IF targets('1.3.x')»
                $dom = ZLanguage::getModuleDomain('«appName»');

                return __('No item selected.', $dom);
            «ELSE»
                $serviceManager = ServiceUtil::getManager();
                
                return $serviceManager->get('translator.default')->__('No item selected.');
            «ENDIF»
        }

        /**
         * Returns common arguments for display data selection with the external api.
         *
         * @return array Display arguments
         */
        protected function getDisplayArguments()
        {
            return «IF targets('1.3.x')»array(«ELSE»[«ENDIF»
                'objectType' => $this->objectType,
                'source' => 'contentType',
                'displayMode' => $this->displayMode,
                'id' => $this->id
            «IF targets('1.3.x')»)«ELSE»]«ENDIF»;
        }

        /**
         * Returns the default data.
         *
         * @return array Default data and parameters
         */
        public function getDefaultData()
        {
            return «IF targets('1.3.x')»array(«ELSE»[«ENDIF»
                'objectType' => '«getLeadingEntity.name.formatForCode»',
                 'id' => null,
                 'displayMode' => 'embed'
             «IF targets('1.3.x')»)«ELSE»]«ENDIF»;
        }

        /**
         * Executes additional actions for the editing mode.
         */
        public function startEditing()
        {
            // ensure our custom plugins are loaded
            «IF targets('1.3.x')»
                array_push($this->view->plugins_dir, '«rootFolder»/«appName»/templates/plugins');
            «ELSE»
                array_push($this->view->plugins_dir, '«rootFolder»/«if (systemModule) name.formatForCode else appName»/«getViewPath»/plugins');
            «ENDIF»

            // required as parameter for the item selector plugin
            $this->view->assign('objectType', $this->objectType);
        }
    '''

    def private contentTypeImpl(Application it) '''
        «IF !targets('1.3.x')»
            namespace «appNamespace»\ContentType;

            use «appNamespace»\ContentType\Base\AbstractItem;

        «ENDIF»
        /**
         * Generic single item display content plugin implementation class.
         */
        «IF targets('1.3.x')»
        class «appName»_ContentType_Item extends «appName»_ContentType_Base_AbstractItem
        «ELSE»
        class Item extends AbstractItem
        «ENDIF»
        {
            // feel free to extend the content type here
        }
    '''
}
