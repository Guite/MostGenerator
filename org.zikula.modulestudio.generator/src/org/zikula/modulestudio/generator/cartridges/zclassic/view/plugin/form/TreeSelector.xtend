package org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.form

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class TreeSelector {
    @Inject extension FormattingExtensions = new FormattingExtensions()
    @Inject extension ModelBehaviourExtensions = new ModelBehaviourExtensions()
    @Inject extension NamingExtensions = new NamingExtensions()
    @Inject extension Utils = new Utils()

    FileHelper fh = new FileHelper()

    def generate(Application it, IFileSystemAccess fsa) {
    	if (hasTrees) {
    	    val formPluginPath = appName.getAppSourceLibPath + 'Form/Plugin/'
            fsa.generateFile(formPluginPath + 'Base/TreeSelector.php', treeSelectorBaseFile)
            fsa.generateFile(formPluginPath + 'TreeSelector.php', treeSelectorFile)
            fsa.generateFile(viewPluginFilePath('function', 'TreeSelector'), treeSelectorPluginFile)
        }
    }

    def private treeSelectorBaseFile(Application it) '''
    	«fh.phpFileHeader(it)»
    	«treeSelectorBaseImpl»
    '''

    def private treeSelectorFile(Application it) '''
    	«fh.phpFileHeader(it)»
    	«treeSelectorImpl»
    '''

    def private treeSelectorPluginFile(Application it) '''
    	«fh.phpFileHeader(it)»
    	«treeSelectorPluginImpl»
    '''

    def private treeSelectorBaseImpl(Application it) '''
        /**
         * Tree selector.
         *
         * This plugin creates a nested tree selector using a dropdown list.
         * The selected value of the base dropdown list will be set to ID of the selected tree node.
         */
        class «appName»_Form_Plugin_Base_TreeSelector extends Zikula_Form_Plugin_DropdownList
        {
            /**
             * The treated object type.
             *
             * @var string
             */
            protected $objectType = '';

            /**
             * Root node id (when using multiple roots).
             *
             * @var integer
             */
            protected $root;

            /**
             * Name of the field to display.
             *
             * @var string
             */
            protected $displayField = '';

            /**
             * Name of optional second field to display.
             *
             * @var string
             */
            protected $displayFieldTwo = '';

            /**
             * Whether to display an empty value to select nothing.
             *
             * @var boolean
             */
            protected $showEmptyValue = false;

            /**
             * Get filename of this file.
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
             * @see    Zikula_Form_Plugin
             * @return void
             */
            public function create($view, &$params)
            {
                if (!isset($params['objectType']) || empty($params['objectType'])) {
                    $view->trigger_error(__f('Error! in %1$s: the %2$s parameter must be specified.', array('«appName.formatForDB»TreeSelector', 'objectType')));
                }
                $this->objectType = $params['objectType'];
                unset($params['objectType']);

                $this->root = (isset($params['root']) && is_numeric($params['root']) && $params['root'] > 0) ? $params['root'] : 1;

                if (!isset($params['displayField']) || empty($params['displayField'])) {
                    $view->trigger_error(__f('Error! in %1$s: the %2$s parameter must be specified.', array('«appName.formatForDB»TreeSelector', 'displayField')));
                }
                $this->displayField = $params['displayField'];
                unset($params['displayField']);

                $this->displayFieldTwo = '';
                if (isset($params['displayField2'])) {
                    $this->displayFieldTwo = $params['displayField2'];
                    unset($params['displayField2']);
                } elseif (isset($params['displayFieldTwo'])) {
                    $this->displayFieldTwo = $params['displayFieldTwo'];
                    unset($params['displayFieldTwo']);
                }

                if (isset($params['showEmptyValue'])) {
                    $this->showEmptyValue = $params['showEmptyValue'];
                    unset($params['showEmptyValue']);
                }

                parent::create($view, $params);

                $this->cssClass .= ' z-form-nestedsetlist';
            }

            /**
             * Load event handler.
             *
             * @param Zikula_Form_View $view    Reference to Form render object.
             * @param array            &$params Parameters passed from the Smarty plugin function.
             *
             * @return void
             */
            public function load($view, &$params)
            {
                if ($this->showEmptyValue != false) {
                    $this->addItem('- - -', 0);
                }

                $includeLeaf = isset($params['includeLeaf']) ? $params['includeLeaf'] : true;
                $includeRoot = isset($params['includeRoot']) ? $params['includeRoot'] : false;

                $treeNodes = array();

                $serviceManager = ServiceUtil::getManager();
                $entityManager = $serviceManager->getService('doctrine.entitymanager');
                $repository = $entityManager->getRepository('«appName»_Entity_' . ucfirst($this->objectType));

                $apiArgs = array('ot' => $this->objectType);
                $idFields = ModUtil::apiFunc('«appName»', 'selection', 'getIdFields', $apiArgs);

                $apiArgs['rootId'] = $this->root;
                $treeNodes = ModUtil::apiFunc('«appName»', 'selection', 'getTree', $apiArgs);
                if (!$treeNodes) {
                    $treeNodes = array();
                }

                foreach ($treeNodes as $node) {
                    $nodeLevel = $node->getLvl();
                    if (!$includeRoot && $nodeLevel == 0) {
                        // if we do not include the root node skip it
                        continue;
                    }
                    if (!$includeLeaf && $repository->childCount($node) == 0) {
                        // if we do not include leaf nodes skip them
                        continue;
                    }

                    // determine current list hierarchy level depending on root node inclusion
                    $shownLevel = (($includeRoot) ? $nodeLevel : $nodeLevel - 1);

                    // create the visible text for this entry
                    $itemLabel = str_repeat('- - ', $shownLevel) . $node[$this->displayField];
                    if (!empty($this->displayFieldTwo)) {
                        $itemLabel .= ' (' . $node[$this->displayFieldTwo] . ')';
                    }

                    // create concatenated list of identifiers (for composite keys)
                    $itemId = '';
                    foreach ($idFields as $idField) {
                        $itemId .= ((!empty($itemId)) ? '_' : '') . $node[$idField];
                    }

                    // add entity to selector list entries
                    $this->addItem($itemLabel, $itemId);
                }

                parent::load($view, $params);
            }
        }
    '''

    def private treeSelectorImpl(Application it) '''
        /**
         * Tree selector.
         *
         * This plugin creates a nested tree selector using a dropdown list.
         * The selected value of the base dropdown list will be set to ID of the selected tree node.
         */
        class «appName»_Form_Plugin_TreeSelector extends «appName»_Form_Plugin_Base_TreeSelector
        {
            // feel free to add your customisation here
        }
    '''

    def private treeSelectorPluginImpl(Application it) '''
        /**
         * The «appName.formatForDB»TreeSelector plugin cares for handling a dropdown list
         * for an entity with tree structure.
         *
         * @param array            $params Parameters passed to this function from the template.
         * @param Zikula_Form_View $view   Reference to Form render object.
         *
         * @return string The rendered output.
         */
        function smarty_function_«appName.formatForDB»TreeSelector($params, $view)
        {
            return $view->registerPlugin('«appName»_Form_Plugin_TreeSelector', $params);
        }
    '''
}
