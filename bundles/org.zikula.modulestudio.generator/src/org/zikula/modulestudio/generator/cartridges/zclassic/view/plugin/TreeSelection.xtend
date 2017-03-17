package org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class TreeSelection {
    extension FormattingExtensions = new FormattingExtensions
    extension Utils = new Utils

    def generate(Application it, IFileSystemAccess fsa) {
        treeSelectionImpl
    }

    def private treeSelectionImpl(Application it) '''
        /**
         * The «appName.formatForDB»_treeSelection function retrieves tree entities based on a given one.
         *
         * Available parameters:
         *   - objectType:   Name of treated object type.
         *   - node:         Given entity as tree entry point.
         *   - target:       One of 'allParents', 'directParent', 'allChildren', 'directChildren', 'predecessors', 'successors', 'preandsuccessors'
         *   - skipRootNode: Whether root nodes are skipped or not (defaults to true). Useful for when working with many trees at once.
         *
         * @return string The output of the plugin
         */
        public function getTreeSelection($objectType, $node, $target, $skipRootNode = true)
        {
            $container = \ServiceUtil::get('service_container');
            $repository = $container->get('«appService».entity_factory')->getRepository($objectType);
            $titleFieldName = $repository->getTitleFieldName();

            $result = null;

            switch ($target) {
                case 'allParents':
                case 'directParent':
                    $path = $repository->getPath($node);
                    if (count($path) > 0) {
                        // remove $node
                        unset($path[count($path)-1]);
                    }
                    if ($skipRootNode && count($path) > 0) {
                        // remove root level
                        array_shift($path);
                    }
                    if ($target == 'allParents') {
                        $result = $path;
                    } elseif ($target == 'directParent' && count($path) > 0) {
                        $result = $path[count($path)-1];
                    }
                    break;
                case 'allChildren':
                case 'directChildren':
                    $direct = $target == 'directChildren';
                    $sortByField = $titleFieldName != '' ? $titleFieldName : null;
                    $sortDirection = 'ASC';
                    $result = $repository->children($node, $direct, $sortByField, $sortDirection);
                    break;
                case 'predecessors':
                    $includeSelf = false;
                    $result = $repository->getPrevSiblings($node, $includeSelf);
                    break;
                case 'successors':
                    $includeSelf = false;
                    $result = $repository->getNextSiblings($node, $includeSelf);
                    break;
                case 'preandsuccessors':
                    $includeSelf = false;
                    $result = array_merge($repository->getPrevSiblings($node, $includeSelf), $repository->getNextSiblings($node, $includeSelf));
                    break;
            }

            return $result;
        }
    '''
}
