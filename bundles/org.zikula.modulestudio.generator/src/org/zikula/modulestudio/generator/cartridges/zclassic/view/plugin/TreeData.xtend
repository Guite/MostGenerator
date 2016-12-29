package org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class TreeData {
    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    def generate(Application it, IFileSystemAccess fsa) {
        if (targets('1.3.x')) {
            val pluginFilePath = viewPluginFilePath('function', 'TreeData')
            if (!shouldBeSkipped(pluginFilePath)) {
                fsa.generateFile(pluginFilePath, new FileHelper().phpFileContent(it, treeDataImpl))
            }
        } else {
            treeDataImpl
        }
    }

    def private treeDataImpl(Application it) '''
        /**
         * The «appName.formatForDB»«IF targets('1.3.x')»TreeData plugin«ELSE»_treeData function«ENDIF» delivers the html output for a JS tree
         * based on given tree entities.
         *
         * Available parameters:
         *   - objectType: Name of treated object type.
         *   - tree:       Object collection with tree items.
         *   - controller: Optional name of controller, defaults to 'user'.
         «IF targets('1.3.x')»
         *   - root:       Optional id of root node, defaults to 1.
         «ELSE»
         *   - rootId:     Optional id of root node, defaults to 1.
         «ENDIF»
        «IF targets('1.3.x')»
            «' '»*   - sortable:   Whether tree nodes should be sortable or not, defaults to true.
            «' '»*   - assign:     If set, the results are assigned to the corresponding variable instead of printed out.
            «' '»*
            «' '»* @param  array       $params All attributes passed to this function from the template
            «' '»* @param  Zikula_View $view   Reference to the view object
        «ENDIF»
         *
         * @return string The output of the plugin
         */
        «IF !targets('1.3.x')»public «ENDIF»function «IF targets('1.3.x')»smarty_function_«appName.formatForDB»«ELSE»get«ENDIF»TreeData(«IF targets('1.3.x')»$params, $view«ELSE»$objectType, $tree, $controller = 'user', $rootId = 1«ENDIF»)
        {
            «IF targets('1.3.x')»
                if (!isset($params['objectType']) || empty($params['objectType'])) {
                    $view->trigger_error(__f('Error! in %1$s: the %2$s parameter must be specified.', array('«appName.formatForDB»TreeJS', 'objectType')));

                    return false;
                }

                if (!isset($params['tree']) || empty($params['tree'])) {
                    $view->trigger_error(__f('Error! in %1$s: the %2$s parameter must be specified.', array('«appName.formatForDB»TreeJS', 'tree')));

                    return false;
                }

                if (!isset($params['controller']) || empty($params['controller'])) {
                    $params['controller'] = 'user';
                }

                if (!isset($params['root']) || empty($params['root'])) {
                    $params['root'] = 1;
                }

            «ENDIF»
            // check whether an edit action is available
            $controllerHasEditAction = false;
            switch ($«IF targets('1.3.x')»params['«ENDIF»controller«IF targets('1.3.x')»']«ENDIF») {
                «controllerEditActionFlags»
            }

            «IF targets('1.3.x')»
                $entityClass = '«appName»_Entity_' . ucfirst($params['objectType']);
            «ENDIF»
            $serviceManager = «IF !targets('1.3.x')»\«ENDIF»ServiceUtil::getManager();
            «IF targets('1.3.x')»
                $entityManager = $serviceManager->get«IF targets('1.3.x')»Service«ENDIF»('«entityManagerService»');
                $repository = $entityManager->getRepository($entityClass);
            «ELSE»
                $repository = $serviceManager->get('«appService».' . $objectType . '_factory')->getRepository();
            «ENDIF»
            $descriptionFieldName = $repository->getDescriptionFieldName();

            $result = '';
            «IF targets('1.3.x')»
                $treeData = array();

                foreach ($params['tree'] as $item) {
                    $url = $controllerHasEditAction ? ModUtil::url('«appName»', $params['controller'], 'edit', $item->createUrlArgs()) : '';

                    $parent = $item->getParent();
                    $treeData[] = array('id' => $item->createCompositeIdentifier(),
                                        'parent_id' => $parent ? $parent->createCompositeIdentifier() : null,
                                        'name' => $item->getTitleFromDisplayPattern(),
                                        'title' => (($descriptionFieldName != '') ? strip_tags($item[$descriptionFieldName]) : ''),
                                      //'icon' => '',
                                      //'class' => '',
                                        'active' => true,
                                      //'expanded' => null,
                                        'href' => $url);
                }

                // instantiate and initialise the output tree object
                $tree = new Zikula_Tree();
                $tree->setOption('id', 'itemTree' . $params['root']);
                $tree->setOption('treeClass', 'z-nestedsetlist');
                $tree->setOption('nodePrefix', 'tree' . $params['root'] . 'node_');
                $tree->setOption('sortable', isset($params['sortable']) && $params['sortable'] ? true : false);
                $tree->setOption('withWraper', true);

                // disable drag and drop for root category
                $tree->setOption('disabled', array(1));

                // put data into output tree
                $tree->loadArrayData($treeData);

                // get output result
                $result = $tree->getHTML();
            «ELSE»
                foreach ($tree as $node) {
                    if ($node->getLvl() < 1) {
                        $result .= $this->processTreeItemWithChildren($objectType, $controller, $node, $rootId, $descriptionFieldName, $controllerHasEditAction);
                    }
                }
            «ENDIF»

            «IF targets('1.3.x')»
                if (array_key_exists('assign', $params)) {
                    $view->assign($params['assign'], $result);

                    return;
                }

            «ENDIF»
            return $result;
        }
        «IF !targets('1.3.x')»

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
        «ENDIF»
    '''

    def private controllerEditActionFlags(Application it) '''
        «FOR controller : controllers.filter[hasActions('edit')]»
            case '«controller.formattedName»': $controllerHasEditAction = true; break;
        «ENDFOR»
        «IF !targets('1.3.x')»
            «FOR entity : entities.filter[hasActions('edit')]»
                case '«entity.name.formatForCode»': $controllerHasEditAction = true; break;
            «ENDFOR»
        «ENDIF»
    '''
}
