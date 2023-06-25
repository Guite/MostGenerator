package org.zikula.modulestudio.generator.cartridges.symfony.view.plugin

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class TreeSelection {

    extension FormattingExtensions = new FormattingExtensions
    extension Utils = new Utils

    def generate(Application it) {
        treeSelectionImpl
    }

    def private treeSelectionImpl(Application it) '''
        /**
         * The «appName.formatForDB»_treeSelection function retrieves tree entities based on a given one.
         */
        public function getTreeSelection(
            string $objectType,
            EntityInterface $node,
            string $target,
            bool $skipRootNode = true
        ): array {
            $repository = $this->entityFactory->getRepository($objectType);
            $titleFieldName = $this->entityDisplayHelper->getTitleFieldName($objectType);

            $result = [];

            switch ($target) {
                case 'allParents':
                case 'directParent':
                    $path = $repository->getPath($node);
                    if (0 < count($path)) {
                        // remove $node
                        unset($path[count($path) - 1]);
                    }
                    if ($skipRootNode && 0 < count($path)) {
                        // remove root level
                        array_shift($path);
                    }
                    if ('allParents' === $target) {
                        $result = $path;
                    } elseif ('directParent' === $target && 0 < count($path)) {
                        $result = [$path[count($path) - 1]];
                    }
                    break;
                case 'allChildren':
                case 'directChildren':
                    $direct = 'directChildren' === $target;
                    $sortByField = '' !== $titleFieldName ? $titleFieldName : null;
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
                    $result = array_merge(
                        $repository->getPrevSiblings($node, $includeSelf),
                        $repository->getNextSiblings($node, $includeSelf)
                    );
                    break;
            }

            return $result;
        }
    '''
}
