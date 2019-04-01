package org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.form

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ItemSelector {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    def generate(Application it, IMostFileSystemAccess fsa) {
        if (targets('2.0')) {
            return;
        }
        fsa.generateClassPair('Form/Plugin/ItemSelector.php', itemSelectorBaseImpl, itemSelectorImpl)

        val pluginFilePath = legacyViewPluginFilePath('function', 'ItemSelector')
        fsa.generateFile(pluginFilePath, itemSelectorPluginImpl)
    }

    def private itemSelectorBaseImpl(Application it) '''
        namespace «appNamespace»\Form\Plugin\Base;

        use Symfony\Component\DependencyInjection\ContainerAwareInterface;
        use Symfony\Component\DependencyInjection\ContainerAwareTrait;
        use Zikula_Form_Plugin_TextInput;
        use Zikula_Form_View;
        use Zikula_View;

        /**
         * Item selector plugin base class.
         */
        class AbstractItemSelector extends Zikula_Form_Plugin_TextInput implements ContainerAwareInterface
        {
            use ContainerAwareTrait;

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
             * ItemSelector constructor.
             */
            public function __construct()
            {
                $this->setContainer(\ServiceUtil::getManager());
            }

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
             * @param array            &$params List of parameters passed from the Smarty plugin function
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
                    $assetHelper = $this->container->get('zikula_core.common.theme.asset_helper');
                    $cssAssetBag = $this->container->get('zikula_core.common.theme.assets_css');
                    $jsAssetBag = $this->container->get('zikula_core.common.theme.assets_js');
                    $homePath = $this->container->get('request_stack')->getCurrentRequest()->getBasePath();

                    «IF hasImageFields»
                        $jsAssetBag->add([$homePath . '/web/magnific-popup/jquery.magnific-popup.min.js' => 90]);
                        $cssAssetBag->add([$homePath . '/web/magnific-popup/magnific-popup.css' => 90]);
                    «ENDIF»
                    $jsAssetBag->add($assetHelper->resolve('@«appName»:js/«appName».js'));
                    $jsAssetBag->add($assetHelper->resolve('@«appName»:js/«appName».ItemSelector.js'));
                    $cssAssetBag->add($assetHelper->resolve('@«appName»:css/style.css'));
                    $cssAssetBag->add([$assetHelper->resolve('@«appName»:css/custom.css') => 120]);
                }
                $firstTime = false;

                $permissionApi = $this->container->get('zikula_permissions_module.api.permission');

                if (!$permissionApi->hasPermission('«appName»:' . ucfirst($this->objectType) . ':', '::', ACCESS_COMMENT)) {
                    return false;
                }
                «IF hasCategorisableEntities»

                    $categorisableObjectTypes = [«FOR entity : getCategorisableEntities SEPARATOR ', '»'«entity.name.formatForCode»'«ENDFOR»];
                    $catIds = [];
                    if (in_array($this->objectType, $categorisableObjectTypes)) {
                        // fetch selected categories to reselect them in the output
                        // the actual filtering is done inside the collection filter helper class
                        $categoryHelper = $this->container->get('«appService».category_helper');
                        $catIds = $categoryHelper->retrieveCategoriesFromRequest($this->objectType);
                    }
                «ENDIF»

                $this->selectedItemId = $this->text;

                $repository = $this->container->get('«appService».entity_factory')->getRepository($this->objectType);

                $sort = $repository->getDefaultSortingField();
                $sdir = 'asc';

                // convenience vars to make code clearer
                $where = '';
                $sortParam = $sort . ' ' . $sdir;

                $entities = $repository->selectWhere($where, $sortParam);

                $view = Zikula_View::getInstance('«appName»', false);
                $view->assign('objectType', $this->objectType)
                     ->assign('items', $entities)
                     ->assign('sort', $sort)
                     ->assign('sortdir', $sdir)
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
                $request = $this->container->get('request_stack')->getCurrentRequest();
                $this->objectType = $request->request->get('«appName»_objecttype', '«getLeadingEntity.name.formatForCode»');
                $this->selectedItemId = $this->text = $request->request->get($this->inputName, 0);
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
