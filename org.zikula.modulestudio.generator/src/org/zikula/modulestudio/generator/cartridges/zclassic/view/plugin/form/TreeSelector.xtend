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
            val formPluginPath = getAppSourceLibPath + 'Form/Plugin/'
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
        «IF !targets('1.3.5')»
            namespace «appNamespace»\Form\Plugin\Base;

            use ModUtil;
            use ServiceUtil;
            use Zikula_Form_View;

        «ENDIF»
        /**
         * Tree selector.
         *
         * This plugin creates a nested tree selector using a dropdown list.
         * The selected value of the base dropdown list will be set to ID of the selected tree node.
         */
        «IF targets('1.3.5')»
        class «appName»_Form_Plugin_Base_TreeSelector extends «appName»_Form_Plugin_AbstractObjectSelector
        «ELSE»
        class TreeSelector extends \«vendor.formatForCodeCapital»\«name.formatForCodeCapital»\Form\Plugin\AbstractObjectSelector
        «ENDIF»
        {
            /**
             * Root node id (when using multiple roots).
             *
             * @var integer
             */
            public $root;

            /**
             * Whether leaf nodes should be included or not.
             *
             * @var boolean
             */
            public $includeLeafNodes = true;

            /**
             * Whether the root node should be included or not.
             *
             * @var boolean
             */
            public $includeRootNode = false;

            /**
             * Reference to the tree repository.
             *
             * @var Doctrine\ORM\EntityRepository
             */
            public $repository = null;

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
                $this->root = (isset($params['root']) && is_numeric($params['root']) && $params['root'] > 0) ? $params['root'] : 1;
                $this->includeLeafNodes = isset($params['includeLeaf']) ? $params['includeLeaf'] : true;
                $this->includeRootNode = isset($params['includeRoot']) ? $params['includeRoot'] : false;

                parent::create($view, $params);

                «IF targets('1.3.5')»
                    $entityClass = $this->name . '_Entity_' . ucwords($this->objectType);
                «ELSE»
                    $entityClass = '\\' . $this->Name . '\\Entity\\' . ucwords($this->objectType) . 'Entity';
                «ENDIF»
                $entityManager = ServiceUtil::getManager()->getService('doctrine.entitymanager');
                $this->repository = $entityManager->getRepository($entityClass);
            }

            /**
             * Entry point for customised css class.
             */
            protected function getStyleClass()
            {
                return 'z-form-nestedsetlist';
            }

            /**
             * Performs the actual data selection.
             *
             * @param array &$params Parameters passed from the Smarty plugin function.
             *
             * @return array List of selected objects.
             */
            protected function loadItems(&$params)
            {
                $apiArgs = array('ot' => $this->objectType
                                 'rootId' => $this->root);
                $treeNodes = ModUtil::apiFunc($this->name, 'selection', 'getTree', $apiArgs);
                if (!$treeNodes) {
                    return array();
                }

                return $treeNodes;
            }

            /**
             * Determines whether a certain list item should be included or not.
             * Allows to exclude undesired items after the selection has happened.
             *
             * @param Doctrine\ORM\Entity $item The treated entity.
             *
             * @return boolean Whether this entity should be included into the list.
             */
            protected function isIncluded($item)
            {
                $nodeLevel = $item->getLvl();

                if (!$this->includeRootNode && $nodeLevel == 0) {
                    // if we do not include the root node skip it
                    return false;
                }

                if (!$this->includeLeafNodes && $this->repository->childCount($item) == 0) {
                    // if we do not include leaf nodes skip them
                    return false;
                }

                return true;
            }

            /**
             * Calculates the label for a certain list item.
             *
             * @param Doctrine\ORM\Entity $item The treated entity.
             *
             * @return string The created label string.
             */
            protected function createItemLabel($item)
            {
                // determine current list hierarchy level depending on root node inclusion
                $shownLevel = $item->getLvl();
                if (!$this->includeRootNode) {
                    $shownLevel--;
                }
                $praefix = str_repeat('- - ', $shownLevel);

                $itemLabel = $praefix . parent::createItemLabel($item);

                return $itemLabel;
            }
        }
    '''

    def private treeSelectorImpl(Application it) '''
        «IF !targets('1.3.5')»
            namespace «appNamespace»\Form\Plugin;

        «ENDIF»
        /**
         * Tree selector.
         *
         * This plugin creates a nested tree selector using a dropdown list.
         * The selected value of the base dropdown list will be set to ID of the selected tree node.
         */
        «IF targets('1.3.5')»
        class «appName»_Form_Plugin_TreeSelector extends «appName»_Form_Plugin_Base_TreeSelector
        «ELSE»
        class TreeSelector extends Base\TreeSelector
        «ENDIF»
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
            return $view->registerPlugin('«IF targets('1.3.5')»«appName»_Form_Plugin_TreeSelector«ELSE»\\«appNamespace»\\Form\\Plugin\\TreeSelector«ENDIF»', $params);
        }
    '''
}
