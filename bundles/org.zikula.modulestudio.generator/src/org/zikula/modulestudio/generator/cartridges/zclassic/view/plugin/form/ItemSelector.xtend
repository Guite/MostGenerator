package org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.form

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ItemSelector {

    extension FormattingExtensions = new FormattingExtensions()
    extension ModelExtensions = new ModelExtensions()
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions()
    extension NamingExtensions = new NamingExtensions()
    extension Utils = new Utils()

    FileHelper fh = new FileHelper()

    def generate(Application it, IFileSystemAccess fsa) {
        generateClassPair(fsa, getAppSourceLibPath + 'Form/Plugin/ItemSelector.php',
            fh.phpFileContent(it, itemSelectorBaseImpl), fh.phpFileContent(it, itemSelectorImpl)
        )
        if (!shouldBeSkipped(viewPluginFilePath('function', 'ItemSelector'))) {
            fsa.generateFile(viewPluginFilePath('function', 'ItemSelector'), fh.phpFileContent(it, itemSelectorPluginImpl))
        }
    }

    def private itemSelectorBaseImpl(Application it) '''
        namespace «appNamespace»\Form\Plugin\Base;

        use FormUtil;
        use PageUtil;
        use ServiceUtil;
        use Zikula_Form_Plugin_TextInput;
        use Zikula_Form_View;
        use Zikula_View;

        /**
         * Item selector plugin base class.
         */
        class AbstractItemSelector extends Zikula_Form_Plugin_TextInput
        {
            /**
             * The treated object type.
             *
             * @var string
             */
            public $objectType = '';

            /**
             * Identifier of selected object.
             *
             * @var integer
             */
            public $selectedItemId = 0;

            /**
             * Get filename of this file.
             * The information is used to re-establish the plugins on postback.
             *
             * @return string
             */
            public function getFilename()
            {
                return __FILE__;
            }

            /**
             * Create event handler.
             *
             * @param Zikula_Form_View $view    Reference to Zikula_Form_View object
             * @param array            &$params Parameters passed from the Smarty plugin function
             *
             * @see    Zikula_Form_AbstractPlugin
             *
             * @return void
             */
            public function create(Zikula_Form_View $view, &$params)
            {
                $params['maxLength'] = 11;
                /*$params['width'] = '8em';*/

                // let parent plugin do the work in detail
                parent::create($view, $params);
            }

            /**
             * Helper method to determine css class.
             *
             * @see    Zikula_Form_Plugin_TextInput
             *
             * @return string the list of css classes to apply
             */
            protected function getStyleClass()
            {
                $class = parent::getStyleClass();

                return str_replace('z-form-text', 'z-form-itemlist ' . strtolower($this->objectType), $class);
            }

            /**
             * Render event handler.
             *
             * @param Zikula_Form_View $view Reference to Zikula_Form_View object
             *
             * @return string The rendered output
             */
            public function render(Zikula_Form_View $view)
            {
                static $firstTime = true;
                if ($firstTime) {
                    PageUtil::addVar('javascript', 'jquery');
                    PageUtil::addVar('javascript', 'web/bootstrap-media-lightbox/bootstrap-media-lightbox.min.js');
                    PageUtil::addVar('stylesheet', 'web/bootstrap-media-lightbox/bootstrap-media-lightbox.css');
                    PageUtil::addVar('javascript', '@«appName»/Resources/public/js/«appName».Finder.js');
                    PageUtil::addVar('stylesheet', '@«appName»/Resources/public/css/style.css');
                }
                $firstTime = false;

                $serviceManager = ServiceUtil::getManager();
                $permissionApi = $serviceManager->get('zikula_permissions_module.api.permission');

                if (!$permissionApi->hasPermission('«appName»:' . ucfirst($this->objectType) . ':', '::', ACCESS_COMMENT)) {
                    return false;
                }
                «IF hasCategorisableEntities»

                    $categorisableObjectTypes = [«FOR entity : getCategorisableEntities SEPARATOR ', '»'«entity.name.formatForCode»'«ENDFOR»];
                    $catIds = [];
                    if (in_array($this->objectType, $categorisableObjectTypes)) {
                        // fetch selected categories to reselect them in the output
                        // the actual filtering is done inside the repository class
                        $categoryHelper = $serviceManager->get('«appService».category_helper');
                        $catIds = $categoryHelper->retrieveCategoriesFromRequest($this->objectType);
                    }
                «ENDIF»

                $this->selectedItemId = $this->text;

                $serviceManager = ServiceUtil::getManager();
                $repository = $serviceManager->get('«appService».' . $this->objectType . '_factory')->getRepository();

                $sort = $repository->getDefaultSortingField();
                $sdir = 'asc';

                // convenience vars to make code clearer
                $where = '';
                $sortParam = $sort . ' ' . $sdir;

                $entities = $repository->selectWhere($where, $sortParam);

                $view = Zikula_View::getInstance('«appName»', false);
                $view->assign('objectType', $this->objectType)
                     ->assign('items', $entities)
                     ->assign('selectedId', $this->selectedItemId);
                «IF hasCategorisableEntities»

                    // assign category properties
                    $properties = null;
                    if (in_array($this->objectType, $categorisableObjectTypes)) {
                        $properties = $categoryHelper->getAllProperties($this->objectType);
                    }
                    $view->assign('properties', $properties)
                         ->assign('catIds', $catIds)
                         ->assign('categoryHelper', $categoryHelper);
                «ENDIF»

                return $view->fetch('External/' . ucfirst($this->objectType) . '/select.tpl');
            }

            /**
             * Decode event handler.
             *
             * @param Zikula_Form_View $view Zikula_Form_View object
             *
             * @return void
             */
            public function decode(Zikula_Form_View $view)
            {
                parent::decode($view);
                $this->objectType = FormUtil::getPassedValue('«appName»_objecttype', '«getLeadingEntity.name.formatForCode»', 'POST');
                $this->selectedItemId = $this->text;
            }
        }
    '''

    def private itemSelectorImpl(Application it) '''
        namespace «appNamespace»\Form\Plugin;

        use «appNamespace»\Form\Plugin\Base\AbstractItemSelector;

        /**
         * Item selector plugin implementation class.
         */
        class ItemSelector extends AbstractItemSelector
        {
            // feel free to add your customisation here
        }
    '''

    def private itemSelectorPluginImpl(Application it) '''
        /**
         * The «appName.formatForDB»ItemSelector plugin provides items for a dropdown selector.
         *
         * @param  array            $params All attributes passed to this function from the template
         * @param  Zikula_Form_View $view   Reference to the view object
         *
         * @return string The output of the plugin
         */
        function smarty_function_«appName.formatForDB»ItemSelector($params, $view)
        {
            return $view->registerPlugin('\\«vendor.formatForCodeCapital»\\«name.formatForCodeCapital»Module\\Form\\Plugin\\ItemSelector', $params);
        }
    '''
}
