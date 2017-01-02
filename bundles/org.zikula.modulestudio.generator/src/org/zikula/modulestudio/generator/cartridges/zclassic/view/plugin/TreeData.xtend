package org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class TreeData {
    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension Utils = new Utils

    def generate(Application it, IFileSystemAccess fsa) {
        treeDataImpl
    }

    def private treeDataImpl(Application it) '''
        /**
         * The «appName.formatForDB»_treeData function delivers the html output for a JS tree
         * based on given tree entities.
         *
         * Available parameters:
         *   - objectType: Name of treated object type.
         *   - tree:       Object collection with tree items.
         *   - controller: Optional name of controller, defaults to 'user'.
         *   - rootId:     Optional id of root node, defaults to 1.
         *
         * @return string The output of the plugin
         */
        public function getTreeData($objectType, $tree, $controller = 'user', $rootId = 1)
        {
            // check whether an edit action is available
            $controllerHasEditAction = false;
            switch ($controller) {
                «controllerEditActionFlags»
            }

            $serviceManager = \ServiceUtil::getManager();
            $repository = $serviceManager->get('«appService».' . $objectType . '_factory')->getRepository();
            $descriptionFieldName = $repository->getDescriptionFieldName();

            $result = '';
            foreach ($tree as $node) {
                if ($node->getLvl() < 1) {
                    $result .= $this->processTreeItemWithChildren($objectType, $controller, $node, $rootId, $descriptionFieldName, $controllerHasEditAction);
                }
            }

            return $result;
        }

        protected function processTreeItemWithChildren($objectType, $controller, $node, $rootId, $descriptionFieldName, $controllerHasEditAction)
        {
            $output = '';
            $idPrefix = 'tree' . $rootId . 'node_' . $node->createCompositeIdentifier();
            $title = ($descriptionFieldName != '' ? strip_tags($node[$descriptionFieldName]) : '');
            $liTag = '<li id="' . $idPrefix . '" title="' . str_replace('"', '', $title) . '" class="lvl' . $node->getLvl() . '">';

            $liContent = $node->getTitleFromDisplayPattern();
            if ($controllerHasEditAction) {
                $urlArgs = $node->createUrlArgs();
                $routeArea = $controller == 'admin' ? 'admin' : '';«/* TODO fix this (#715) */»
                $url = $this->router->generate('«appName.formatForDB»_' . strtolower($objectType) . '_' . $routeArea . 'edit', $urlArgs);

                $liContent = '<a href="' . $url . '" title="' . str_replace('"', '', $title) . '">' . $liContent . '</a>';
            }

            $treeItem = $liTag . $liContent;

            if (count($node->getChildren()) > 0) {
                $treeItem .= '<ul>';
                foreach ($node->getChildren() as $childNode) {
                    $treeItem .= $this->processTreeItemWithChildren($objectType, $controller, $childNode, $rootId, $descriptionFieldName, $controllerHasEditAction);
                }
                $treeItem .= '</ul>';
            }

            $treeItem .= '</li>';

            $output .= $treeItem;

            return $output;
        }
    '''

    def private controllerEditActionFlags(Application it) '''
        «FOR controller : controllers.filter[hasActions('edit')]»
            case '«controller.formattedName»': $controllerHasEditAction = true; break;
        «ENDFOR»
        «FOR entity : entities.filter[hasActions('edit')]»
            case '«entity.name.formatForCode»': $controllerHasEditAction = true; break;
        «ENDFOR»
    '''
}
