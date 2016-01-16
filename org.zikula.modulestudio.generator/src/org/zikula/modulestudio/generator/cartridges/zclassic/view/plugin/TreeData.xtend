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
         *   - root:       Optional id of root node, defaults to 1.
        «IF targets('1.3.x')»
            «' '»*   - sortable:   Whether tree nodes should be sortable or not, defaults to true.
            «' '»*   - assign:     If set, the results are assigned to the corresponding variable instead of printed out.
            «' '»*
            «' '»* @param  array       $params All attributes passed to this function from the template.
            «' '»* @param  Zikula_View $view   Reference to the view object.
        «ENDIF»
         *
         * @return string The output of the plugin.
         */
        «IF !targets('1.3.x')»public «ENDIF»function «IF targets('1.3.x')»smarty_function_«appName.formatForDB»«ELSE»get«ENDIF»TreeData(«IF targets('1.3.x')»$params, $view«ELSE»$objectType, $tree, $controller = 'user', $root = 1«ENDIF»)
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
                $entityManager = $serviceManager->get«IF targets('1.3.x')»Service«ENDIF»('doctrine.entitymanager');
                $repository = $entityManager->getRepository($entityClass);
            «ELSE»
                $repository = $serviceManager->get('«appName.formatForDB».«name.formatForCode»_factory')->getRepository();
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
                foreach ($params['tree'] as $item) {
                    $result .= processTreeItemWithChildren($objectType, $controller, $item, $rootId, $descriptionFieldName, $controllerHasEditAction);
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

            function processTreeItemWithChildren($objectType, $controller, $node, $rootId, $descriptionFieldName, $controllerHasEditAction)
            {
                $output = '';
                $idPrefix = 'tree' . $rootId . 'node_' . $item->createCompositeIdentifier();
                $title = ($descriptionFieldName != '' ? strip_tags($item[$descriptionFieldName]) : '');
                $liTag = '<li id="' . $idPrefix . '" title="' . str_replace('"', '', $title) . '" class="lvl' . $item->getLvl() . '">';

                $liContent = $item->getTitleFromDisplayPattern();
                if ($controllerHasEditAction) {
                    $urlArgs = $item->createUrlArgs();
                    $routeArea = $controller == 'admin' ? 'admin' : '';
                    $url = $serviceManager->get('router')->generate('«appName.formatForDB»_' . strtolower($objectType) . '_' . $routeArea . 'edit', $urlArgs);

                    $liContent = '<a href="' . $url . '" title="' . str_replace('"', '', $title) . '">' . $liContent . '</a>';

                    // add dropdown for available node-related actions
                    $liContent .= '
                        <div class="dropdown">
                            <a id="' . $idPrefix . 'DropDownToggle" role="button" data-toggle="dropdown" data-target="#" href="javascript:void(0);" class="dropdown-toggle"><span class="caret"></span></a>
                            <ul id="' . $idPrefix . 'DropDownMenu" class="dropdown-menu" role="menu" aria-labelledby="' . $idPrefix . 'DropDownToggle">
                            </ul>
                        </div>
                    ';
                }

                $treeItem = $liTag . $liContent;

                if (count($item->getChildren()) > 0) {
                    $treeItem .= '<ul>';
                    foreach ($item->getChildren() as $childNode) {
                        $treeItem .= processTreeItemWithChildren($objectType, $controller, $childNode, $rootId, $descriptionFieldName, $controllerHasEditAction);
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
