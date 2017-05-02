package org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.EntityTreeType
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class TreeData {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension Utils = new Utils

    def generate(Application it, IFileSystemAccess fsa) {
        treeDataImpl
    }

    def private treeDataImpl(Application it) '''
        /**
         * The «appName.formatForDB»_treeData function delivers the html output for a JS tree
         * based on given tree entities.
         *
         * @param string  $objectType Name of treated object type
         * @param array   $tree       Object collection with tree items
         * @param string  $routeArea  Either 'admin' or an emptyy string
         * @param integer $rootId     Optional id of root node, defaults to 1
         *
         * @return string Output markup
         */
        public function getTreeData($objectType, $tree, $routeArea = '', $rootId = 1)
        {
            // check whether an edit action is available
            $hasEditAction = in_array($objectType, ['«getAllEntities.filter[tree != EntityTreeType.NONE && hasEditAction].map[name.formatForCode].join('\', \'')»']);

            $repository = $this->entityFactory->getRepository($objectType);
            $descriptionFieldName = $this->entityDisplayHelper->getDescriptionFieldName($objectType);

            $result = '';
            foreach ($tree as $node) {
                if ($node->getLvl() < 1 || $node->getKey() == $rootId) {
                    $result .= $this->processTreeItemWithChildren($objectType, $node, $routeArea, $rootId, $descriptionFieldName, $hasEditAction);
                }
            }

            return $result;
        }

        /**
         * Builds an unordered list for a tree node and it's children.
         *
         * @param string  $objectType           Name of treated object type
         * @param object  $node                 The processed tree node
         * @param string  $routeArea            Either 'admin' or an emptyy string
         * @param integer $rootId               Optional id of root node, defaults to 1
         * @param string  $descriptionFieldName Name of field to be used as a description
         * @param boolean $hasEditAction        Whether item editing is possible or not
         *
         * @return string Output markup
         */
        protected function processTreeItemWithChildren($objectType, $node, $routeArea, $rootId, $descriptionFieldName, $hasEditAction)
        {
            $idPrefix = 'tree' . $rootId . 'node_' . $node->getKey();
            $title = $descriptionFieldName != '' ? strip_tags($node[$descriptionFieldName]) : '';
            $liTag = '<li id="' . $idPrefix . '" title="' . str_replace('"', '', $title) . '" class="lvl' . $node->getLvl() . '">';

            $liContent = $this->entityDisplayHelper->getFormattedTitle($node);
            if ($hasEditAction) {
                $urlArgs = $node->createUrlArgs();
                $url = $this->router->generate('«appName.formatForDB»_' . strtolower($objectType) . '_' . $routeArea . 'edit', $urlArgs);

                $liContent = '<a href="' . $url . '" title="' . str_replace('"', '', $title) . '">' . $liContent . '</a>';
            }

            $treeItem = $liTag . $liContent;

            if (count($node->getChildren()) > 0) {
                $treeItem .= '<ul>';
                foreach ($node->getChildren() as $childNode) {
                    $treeItem .= $this->processTreeItemWithChildren($objectType, $childNode, $routeArea, $rootId, $descriptionFieldName, $hasEditAction);
                }
                $treeItem .= '</ul>';
            }

            $treeItem .= '</li>';

            return $treeItem;
        }
    '''
}
