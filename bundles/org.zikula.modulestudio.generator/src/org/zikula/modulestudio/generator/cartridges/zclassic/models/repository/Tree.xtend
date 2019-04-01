package org.zikula.modulestudio.generator.cartridges.zclassic.models.repository

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.EntityTreeType
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Tree {

    extension FormattingExtensions = new FormattingExtensions
    extension Utils = new Utils

    def generate(Entity it, Application app) '''
        «IF tree != EntityTreeType.NONE»

            «selectTree»

            «selectAllTrees»
        «ENDIF»
    '''

    def private selectTree(Entity it) '''
        /**
         * Selects tree of «nameMultiple.formatForCode».
         «IF !application.targets('3.0')»
         *
         * @param int $rootId Optional id of root node to use as a branch, defaults to 0 which corresponds to the whole tree
         * @param bool $useJoins Whether to include joining related objects (optional) (default=true)
         *
         * @return array Retrieved data array or tree node objects
         «ENDIF»
         */
        public function selectTree(«IF application.targets('3.0')»int «ENDIF»$rootId = 0, «IF application.targets('3.0')» bool«ENDIF»$useJoins = true)«IF application.targets('3.0')»: array«ENDIF»
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
        /**
         * Selects all trees at once.
         «IF !application.targets('3.0')»
         *
         * @param bool $useJoins Whether to include joining related objects (optional) (default=true)
         *
         * @return array|ArrayCollection Retrieved data array or tree node objects
         «ENDIF»
         */
        public function selectAllTrees«IF application.targets('3.0')»(bool $useJoins = true): array«ELSE»($useJoins = true)«ENDIF»
        {
            $trees = [];

            // get all root nodes
            $qb = $this->genericBaseQuery('tbl.lvl = 0', '', $useJoins);
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
