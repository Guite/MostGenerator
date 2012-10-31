package org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.form

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ItemSelector {
    @Inject extension FormattingExtensions = new FormattingExtensions()
    @Inject extension ModelBehaviourExtensions = new ModelBehaviourExtensions()
    @Inject extension NamingExtensions = new NamingExtensions()
    @Inject extension Utils = new Utils()

    FileHelper fh = new FileHelper()

    def generate(Application it, IFileSystemAccess fsa) {
        val formPluginPath = appName.getAppSourceLibPath + 'Form/Plugin/'
        fsa.generateFile(formPluginPath + 'Base/ItemSelector.php', itemSelectorBaseFile)
        fsa.generateFile(formPluginPath + 'ItemSelector.php', itemSelectorFile)
        fsa.generateFile(viewPluginFilePath('function', 'SelectorItems'), itemSelectorPluginFile)
    }

    def private itemSelectorBaseFile(Application it) '''
    	«fh.phpFileHeader(it)»
    	«itemSelectorBaseImpl»
    '''

    def private itemSelectorFile(Application it) '''
    	«fh.phpFileHeader(it)»
    	«itemSelectorImpl»
    '''

    def private itemSelectorPluginFile(Application it) '''
    	«fh.phpFileHeader(it)»
    	«itemSelectorPluginImpl»
    '''

    def private itemSelectorBaseImpl(Application it) '''
        /**
         * Item selector plugin base class.
         */
        class «appName»_Form_Plugin_Base_ItemSelector extends Zikula_Form_Plugin_TextInput
        {
            protected $objectType = '';
            protected $selectedItemId = 0;

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
             * @param Zikula_Form_View $view    Reference to Zikula_Form_View object.
             * @param array            &$params Parameters passed from the Smarty plugin function.
             *
             * @see    Zikula_Form_AbstractPlugin
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
                return str_replace('z-form-text', 'z-form-itemselector ' . strtolower($this->objectType), $class);
            }

            /**
             * Render event handler.
             *
             * @param Zikula_Form_View $view Reference to Zikula_Form_View object.
             *
             * @return string The rendered output
             */
            public function render(Zikula_Form_View $view)
            {
                static $firstTime = true;
                if ($firstTime) {
                    PageUtil::addVar('javascript', 'prototype');
                    PageUtil::addVar('javascript', 'Zikula.UI'); // imageviewer
                    PageUtil::addVar('javascript', 'modules/«appName»/javascript/finder.js');
                    PageUtil::addVar('stylesheet', ThemeUtil::getModuleStylesheet('«appName»'));
                }
                $firstTime = false;

                if (!SecurityUtil::checkPermission('«appName»:' . ucwords($this->objectType) . ':', '::', ACCESS_COMMENT)) {
                    return false; //LogUtil::registerPermissionError();
                }
                «IF hasCategorisableEntities»

                    $categorisableObjectTypes = array(«FOR entity : getCategorisableEntities SEPARATOR ', '»'«entity.name.formatForCode»'«ENDFOR»);
                    $mainCategory = null;
                    $catIds = array();
                    if (in_array($this->objectType, $categorisableObjectTypes)) {
                        $mainCategory = ModUtil::apiFunc('«appName»', 'category', 'getMainCat', array('ot' => $this->objectType));

                        $registryId = 'Main';«/* TODO: support for multiple category trees - see #213 */»
                        $hasMultiSelection = ModUtil::apiFunc('«appName»', 'category', 'hasMultipleSelection', array('ot' => $this->objectType, 'registry' => $registryId));
                        if ($hasMultiSelection === true) {
                            $catIds = FormUtil::getPassedValue('catids', array(), 'POST');
                            if (!is_array($catIds)) {
                                $catIds = explode(', ', $catIds);
                            }
                        } else {
                            $catId = (int) FormUtil::getPassedValue('catid', 0, 'POST', FILTER_VALIDATE_INT);
                            if ($catId > 0) {
                                $catIds[] = $catId;
                            }
                        }
                    }
                «ENDIF»

                $serviceManager = ServiceUtil::getManager();
                $entityManager = $serviceManager->getService('doctrine.entitymanager');

                $repository = $entityManager->getRepository('«appName»_Entity_' . ucfirst($this->objectType));

                $sort = $repository->getDefaultSortingField();
                $sdir = 'asc';

                // convenience vars to make code clearer
                $where = '';
                $sortParam = $sort . ' ' . $sdir;

                $objectData = $repository->selectWhere($where, $sortParam);

                $view = Zikula_View::getInstance('«appName»', false);
                $view->assign('items', $objectData)
                «IF hasCategorisableEntities»
                     ->assign('mainCategory', $mainCategory)
                     ->assign('catIds', $catIds)
               «ENDIF»
                     ->assign('selectedId', $this->selectedItemId);

                return $view->fetch('external/' . $this->objectType . '/selectItem.tpl');
            }

            /**
             * Decode event handler.
             *
             * @param Zikula_Form_View $view Zikula_Form_View object.
             *
             * @return void
             */
            public function decode(Zikula_Form_View $view)
            {
                parent::decode($view);
                $value = explode(';', $this->text);
                $this->objectType = $value[0];
                $this->selectedItemId = $value[1];
            }

            /**
             * Parses a value.
             *
             * @param Zikula_Form_View $view Reference to Zikula_Form_View object.
             * @param string           $text Text.
             *
             * @return string Parsed Text.
             */
            public function parseValue(Zikula_Form_View $view, $text)
            {
                $valueParts = array($this->objectType, $this->selectedItemId);
                return implode(';', $valueParts);
            }

            /**
             * Load values.
             *
             * Called internally by the plugin itself to load values from the render.
             * Can also by called when some one is calling the render object's Zikula_Form_ViewetValues.
             *
             * @param Zikula_Form_View $view    Reference to Zikula_Form_View object.
             * @param array            &$values Values to load.
             *
             * @return void
             */
            public function loadValue(Zikula_Form_View $view, &$values)
            {
                if (!$this->dataBased) {
                    return;
                }

                $value = null;

                if ($this->group == null) {
                    if (array_key_exists($this->dataField, $values)) {
                        $value = $values[$this->dataField];
                    }
                } else {
                    if (array_key_exists($this->group, $values) && array_key_exists($this->dataField, $values[$this->group])) {
                        $value = $values[$this->group][$this->dataField];
                    }
                }

                if ($value !== null) {
                    //$this->text = $this->formatValue($view, $value);
                    $value = explode(';', $value);
                    $this->objectType = $value[0];
                    $this->selectedItemId = $value[1];
                }
            }
        }
    '''

    def private itemSelectorImpl(Application it) '''
        /**
         * Item selector plugin implementation class.
         */
        class «appName»_Form_Plugin_ItemSelector extends «appName»_Form_Plugin_Base_ItemSelector
        {
            // feel free to add your customisation here
        }
    '''

    def private itemSelectorPluginImpl(Application it) '''
        /**
         * The «appName.formatForDB»SelectorItem plugin provides items for a dropdown selector.
         *
         * @param  array            $params All attributes passed to this function from the template.
         * @param  Zikula_Form_View $view   Reference to the view object.
         *
         * @return string The output of the plugin.
         */
        function smarty_function_«appName.formatForDB»GeoInput($params, $view)
        {
            return $view->registerPlugin('«appName»_Form_Plugin_ItemSelector', $params);
        }
    '''
}
