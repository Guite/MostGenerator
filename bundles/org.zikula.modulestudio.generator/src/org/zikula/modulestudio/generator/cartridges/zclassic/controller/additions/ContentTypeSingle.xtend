package org.zikula.modulestudio.generator.cartridges.zclassic.controller.additions

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.cartridges.zclassic.view.additions.ContentTypeSingleView
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ContentTypeSingle {

    extension FormattingExtensions = new FormattingExtensions
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
        namespace «appNamespace»\ContentType\Base;

        use ServiceUtil;

        /**
         * Generic single item display content plugin base class.
         */
        abstract class AbstractItem extends \Content_AbstractContentType
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
            return ServiceUtil::get('translator.default')->__('«appName» detail view');
        }

        /**
         * Returns the description of this content type.
         *
         * @return string The content type description
         */
        public function getDescription()
        {
            return ServiceUtil::get('translator.default')->__('Display or link a single «appName» object.');
        }

        /**
         * Loads the data.
         *
         * @param array $data Data array with parameters
         */
        public function loadData(&$data)
        {
            $serviceManager = ServiceUtil::getManager();
            $controllerHelper = $serviceManager->get('«appService».controller_helper');

            $contextArgs = ['name' => 'detail'];
            if (!isset($data['objectType']) || !in_array($data['objectType'], $controllerHelper->getObjectTypes('contentType', $contextArgs))) {
                $data['objectType'] = $controllerHelper->getDefaultObjectType('contentType', $contextArgs);
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
                return ServiceUtil::get('router')->generate('«appName.formatForDB»_external_display', $this->getDisplayArguments());
            }

            return '';
        }

        /**
         * Displays the data for editing.
         */
        public function displayEditing()
        {
            if (null !== $this->id && !empty($this->displayMode)) {
                return ServiceUtil::get('router')->generate('«appName.formatForDB»_external_display', $this->getDisplayArguments());
            }

            return ServiceUtil::get('translator.default')->__('No item selected.');
        }

        /**
         * Returns common arguments for display data selection with the external api.
         *
         * @return array Display arguments
         */
        protected function getDisplayArguments()
        {
            return [
                'objectType' => $this->objectType,
                'source' => 'contentType',
                'displayMode' => $this->displayMode,
                'id' => $this->id
            ];
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
                 'id' => null,
                 'displayMode' => 'embed'
             ];
        }

        /**
         * Executes additional actions for the editing mode.
         */
        public function startEditing()
        {
            // ensure our custom plugins are loaded
            array_push($this->view->plugins_dir, '«relativeAppRootPath»/«getViewPath»/plugins');

            // required as parameter for the item selector plugin
            $this->view->assign('objectType', $this->objectType);
        }

        /**
         * Returns the edit template path.
         *
         * @return string
         */
        public function getEditTemplate()
        {
            $absoluteTemplatePath = str_replace('ContentType/Base/AbstractItem.php', 'Resources/views/ContentType/item_edit.tpl', __FILE__);

            return 'file:' . $absoluteTemplatePath;
        }
    '''

    def private contentTypeImpl(Application it) '''
        namespace «appNamespace»\ContentType;

        use «appNamespace»\ContentType\Base\AbstractItem;

        /**
         * Generic single item display content plugin implementation class.
         */
        class Item extends AbstractItem
        {
            // feel free to extend the content type here
        }
    '''
}
