package org.zikula.modulestudio.generator.cartridges.symfony.view.plugin

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.EntityTreeType
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class TreeData {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension Utils = new Utils

    def generate(Application it) {
        treeDataImpl
    }

    def private treeDataImpl(Application it) '''
        /**
         * The «appName.formatForDB»_treeData function delivers the html output for a JS tree
         * based on given tree entities.
         */
        public function getTreeData(string $objectType, array $tree = [], string $routeArea = '', int $rootId = 1): array
        {
            // check whether an edit action is available
            $hasEditAction = in_array($objectType, ['«entities.filter[tree != EntityTreeType.NONE && hasEditAction].map[name.formatForCode].join('\', \'')»'], true);

            $repository = $this->entityFactory->getRepository($objectType);
            $descriptionFieldName = $this->entityDisplayHelper->getDescriptionFieldName($objectType);

            $result = [
                'nodes' => '',
                'actions' => '',
            ];
            foreach ($tree as $node) {
                if (1 > $node->getLvl() || $rootId === $node->getKey()) {
                    [$nodes, $actions] = $this->processTreeItemWithChildren(
                        $objectType,
                        $node,
                        $routeArea,
                        $rootId,
                        $descriptionFieldName,
                        $hasEditAction
                    );
                    $result['nodes'] .= $nodes;
                    $result['actions'] .= $actions;
                }
            }

            return $result;
        }

        /**
         * Builds an unordered list for a tree node and it's children.
         */
        protected function processTreeItemWithChildren(
            string $objectType,
            EntityInterface $node,
            string $routeArea,
            int $rootId,
            string $descriptionFieldName,
            bool $hasEditAction
        ): array {
            $idPrefix = 'tree' . $rootId . 'node_' . $node->getKey();
            $title = '';
            if ('' !== $descriptionFieldName) {
                $getter = 'get' . ucfirst($descriptionFieldName);
                $title = strip_tags($node->$getter() ?? '');
            }

            $needsArg = in_array($objectType, ['«entities.filter[tree != EntityTreeType.NONE && hasEditAction && hasSluggableFields && slugUnique].map[name.formatForCode].join('\', \'')»'], true);
            $urlArgs = $needsArg ? $node->createUrlArgs(true) : $node->createUrlArgs();
            $urlDataAttributes = '';
            foreach ($urlArgs as $field => $value) {
                $urlDataAttributes .= ' data-' . $field . '="' . $value . '"';
            }

            $titleAttribute = ' title="' . str_replace('"', '', $title) . '"';
            $classAttribute = ' class="lvl' . $node->getLvl() . '"';
            $liTag = '<li id="' . $idPrefix . '"' . $titleAttribute . $classAttribute . $urlDataAttributes . '>';
            $liContent = $this->entityDisplayHelper->getFormattedTitle($node);
            if ($hasEditAction) {
                $routeName = '«appName.formatForDB»_' . mb_strtolower($objectType) . '_' . $routeArea . 'edit';
                $url = $this->router->generate($routeName, $urlArgs);
                $liContent = '<a href="' . $url . '" title="' . str_replace('"', '', $title) . '">' . $liContent . '</a>';
            }

            $nodeItem = $liTag . $liContent;

            $itemActionsMenu = $this->menuBuilder->createItemActionsMenu([
                'entity' => $node,
                'area' => $routeArea,
                'context' => 'index',
            ]);
            $renderer = new ListRenderer(new Matcher());

            $actions = '<li id="itemActions' . $node->getKey() . '">';
            $actions .= $renderer->render($itemActionsMenu);
            $actions = str_replace([' class="first"', ' class="last"'], '', $actions);
            $actions .= '</li>';

            if (0 < count($node->getChildren())) {
                $nodeItem .= '<ul>';
                foreach ($node->getChildren() as $childNode) {
                    [$subNodes, $subActions] = $this->processTreeItemWithChildren(
                        $objectType,
                        $childNode,
                        $routeArea,
                        $rootId,
                        $descriptionFieldName,
                        $hasEditAction
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
