package org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.EntityTreeType
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class TreeData {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelExtensions = new ModelExtensions
    extension Utils = new Utils

    def generate(Application it) {
        treeDataImpl
    }

    def private treeDataImpl(Application it) '''
        /**
         * The «appName.formatForDB»_treeData function delivers the html output for a JS tree
         * based on given tree entities.
         «IF !targets('3.0')»
         *
         * @param string $objectType Name of treated object type
         * @param array $tree Object collection with tree items
         * @param string $routeArea Either 'admin' or an empty string
         * @param int $rootId Optional id of root node, defaults to 1
         *
         * @return array
         «ENDIF»
         */
        public function getTreeData«IF targets('3.0')»(string $objectType, array $tree = [], string $routeArea = '', int $rootId = 1): array«ELSE»($objectType, $tree = [], $routeArea = '', $rootId = 1)«ENDIF»
        {
            // check whether an edit action is available
            $hasEditAction = in_array($objectType, ['«getAllEntities.filter[tree != EntityTreeType.NONE && hasEditAction].map[name.formatForCode].join('\', \'')»'], true);

            $repository = $this->entityFactory->getRepository($objectType);
            $descriptionFieldName = $this->entityDisplayHelper->getDescriptionFieldName($objectType);

            $result = [
                'nodes' => '',
                'actions' => ''
            ];
            foreach ($tree as $node) {
                if (1 > $node->getLvl() || $rootId === $node->getKey()) {
                    list ($nodes, $actions) = $this->processTreeItemWithChildren(
                        $objectType, $node, $routeArea, $rootId, $descriptionFieldName, $hasEditAction
                    );
                    $result['nodes'] .= $nodes;
                    $result['actions'] .= $actions;
                }
            }

            return $result;
        }

        /**
         * Builds an unordered list for a tree node and it's children.
         «IF !targets('3.0')»
         *
         * @param string $objectType Name of treated object type
         * @param EntityAccess $node The processed tree node
         * @param string $routeArea Either 'admin' or an emptyy string
         * @param int $rootId Optional id of root node, defaults to 1
         * @param string $descriptionFieldName Name of field to be used as a description
         * @param bool $hasEditAction Whether item editing is possible or not
         *
         * @return array
         «ENDIF»
         */
        protected function processTreeItemWithChildren«IF targets('3.0')»(
            string $objectType,
            EntityAccess $node,
            string $routeArea,
            int $rootId,
            string $descriptionFieldName,
            bool $hasEditAction
        ): array {«ELSE»($objectType, $node, $routeArea, $rootId, $descriptionFieldName, $hasEditAction)
        {«ENDIF»
            $idPrefix = 'tree' . $rootId . 'node_' . $node->getKey();
            $title = '' !== $descriptionFieldName ? strip_tags($node[$descriptionFieldName]) : '';

            $needsArg = in_array($objectType, ['«getAllEntities.filter[tree != EntityTreeType.NONE && hasEditAction && hasSluggableFields && slugUnique].map[name.formatForCode].join('\', \'')»'], true);
            $urlArgs = $needsArg ? $node->createUrlArgs(true) : $node->createUrlArgs();
            $urlDataAttributes = '';
            foreach ($urlArgs as $field => $value) {
                $urlDataAttributes .= ' data-' . $field . '="' . $value . '"';
            }

            $titleAttribute = ' title="' . str_replace('"', '', $title) . '"';
            $liTag = '<li id="' . $idPrefix . '"' . $titleAttribute . ' class="lvl' . $node->getLvl() . '"' . $urlDataAttributes . '>';
            $liContent = $this->entityDisplayHelper->getFormattedTitle($node);
            if ($hasEditAction) {
                $routeName = '«appName.formatForDB»_' . strtolower($objectType) . '_' . $routeArea . 'edit';
                $url = $this->router->generate($routeName, $urlArgs);
                $liContent = '<a href="' . $url . '" title="' . str_replace('"', '', $title) . '">' . $liContent . '</a>';
            }

            $nodeItem = $liTag . $liContent;

            $itemActionsMenu = $this->menuBuilder->createItemActionsMenu([
                'entity' => $node,
                'area' => $routeArea,
                'context' => 'view'
            ]);
            $renderer = new ListRenderer(new Matcher());

            $actions = '<li id="itemActions' . $node->getKey() . '">';
            $actions .= $renderer->render($itemActionsMenu);
            $actions = str_replace([' class="first"', ' class="last"'], '', $actions);
            $actions .= '</li>';

            if (count($node->getChildren()) > 0) {
                $nodeItem .= '<ul>';
                foreach ($node->getChildren() as $childNode) {
                    list ($subNodes, $subActions) = $this->processTreeItemWithChildren(
                        $objectType, $childNode, $routeArea, $rootId, $descriptionFieldName, $hasEditAction
                    );
                    $nodeItem .= $subNodes;
                    $actions .= $subActions;
                }
                $nodeItem .= '</ul>';
            }

            $nodeItem .= '</li>';

            return [$nodeItem, $actions];
        }
    '''
}
