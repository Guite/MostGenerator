package org.zikula.modulestudio.generator.cartridges.zclassic.models.repository

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.EntityTreeType
import org.zikula.modulestudio.generator.extensions.FormattingExtensions

class Tree {

    extension FormattingExtensions = new FormattingExtensions

    def generateInterface(Entity it, Application app) '''
        «IF tree != EntityTreeType.NONE»

            /**
             * Selects tree of «nameMultiple.formatForCode».
             */
            public function selectTree(int $rootId = 0, bool $useJoins = true): array;

            /**
             * Selects all trees at once.
             */
            public function selectAllTrees(bool $useJoins = true): array;
        «ENDIF»
    '''

    def generate(Entity it, Application app) '''
        «IF tree != EntityTreeType.NONE»

            «selectTree»

            «selectAllTrees»
        «ENDIF»
    '''

    def private selectTree(Entity it) '''
        public function selectTree(int $rootId = 0, bool $useJoins = true): array
        {
            if (0 === $rootId) {
                // return all trees if no specific one has been asked for
                return $this->selectAllTrees($useJoins);
            }

            // fetch root node
            $rootNode = $this->selectById($rootId, $useJoins);

            // fetch children
            $children = $this->children($rootNode);

            return array_merge([$rootNode], $children);
        }
    '''

    def private selectAllTrees(Entity it) '''
        public function selectAllTrees(bool $useJoins = true): array
        {
            $trees = [];

            // get all root nodes
            $qb = $this->genericBaseQuery('tbl.lvl = 0', '', $useJoins);

            if (null !== $this->collectionFilterHelper) {
                $qb = $this->collectionFilterHelper->applyDefaultFilters('«name.formatForCode»', $qb);
            }

            $query = $this->getQueryFromBuilder($qb);
            $rootNodes = $query->getResult();

            foreach ($rootNodes as $rootNode) {
                // fetch children
                $children = $this->children($rootNode);
                $trees[$rootNode->getId()] = array_merge([$rootNode], $children);
            }

            return $trees;
        }
    '''
}
