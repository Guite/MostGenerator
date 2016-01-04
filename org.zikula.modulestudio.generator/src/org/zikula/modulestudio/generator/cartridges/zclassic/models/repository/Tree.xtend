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
         *
         * @param integer $rootId   Optional id of root node to use as a branch, defaults to 0 which corresponds to the whole tree.
         * @param boolean $useJoins Whether to include joining related objects (optional) (default=true).
         *
         * @return array|ArrayCollection retrieved data array or tree node objects.
         */
        public function selectTree($rootId = 0, $useJoins = true)
        {
            if ($rootId == 0) {
                // return all trees if no specific one has been asked for
                return $this->selectAllTrees($useJoins);
            }

            $result = null;

            // fetch root node
            $rootNode = $this->selectById($rootId, $useJoins);

            // fetch children
            $children = $this->children($rootNode);

            // alternatively we could probably select all nodes with root = $rootId

            return array_merge(«IF application.targets('1.3.x')»array($rootNode)«ELSE»[$rootNode]«ENDIF», $children);
        }
    '''

    def private selectAllTrees(Entity it) '''
        /**
         * Selects all trees at once.
         *
         * @param boolean $useJoins Whether to include joining related objects (optional) (default=true).
         *
         * @return array|ArrayCollection retrieved data array or tree node objects.
         */
        public function selectAllTrees($useJoins = true)
        {
            $trees = «IF application.targets('1.3.x')»array()«ELSE»[]«ENDIF»;

            $slimMode = false;

            // get all root nodes
            $qb = $this->genericBaseQuery('tbl.lvl = 0', '', $useJoins, $slimMode);
            $query = $this->getQueryFromBuilder($qb);
            $rootNodes = $query->getResult();

            foreach ($rootNodes as $rootNode) {
                // fetch children
                $children = $this->children($rootNode);
                $trees[$rootNode->getId()] = array_merge(«IF application.targets('1.3.x')»array($rootNode)«ELSE»[$rootNode]«ENDIF», $children);
            }

            return $trees;
        }
    '''
}
