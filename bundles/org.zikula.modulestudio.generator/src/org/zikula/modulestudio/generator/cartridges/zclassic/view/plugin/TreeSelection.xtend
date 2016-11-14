package org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class TreeSelection {
    extension FormattingExtensions = new FormattingExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    def generate(Application it, IFileSystemAccess fsa) {
        if (targets('1.3.x')) {
            val pluginFilePath = viewPluginFilePath('function', 'TreeSelection')
            if (!shouldBeSkipped(pluginFilePath)) {
                fsa.generateFile(pluginFilePath, new FileHelper().phpFileContent(it, treeSelectionImpl))
            }
        } else {
            treeSelectionImpl
        }
    }

    def private treeSelectionImpl(Application it) '''
        /**
         * The «appName.formatForDB»«IF targets('1.3.x')»TreeSelection plugin«ELSE»_treeSelection function«ENDIF» retrieves tree entities based on a given one.
         *
         * Available parameters:
         *   - objectType:   Name of treated object type.
         *   - node:         Given entity as tree entry point.
         *   - target:       One of 'allParents', 'directParent', 'allChildren', 'directChildren', 'predecessors', 'successors', 'preandsuccessors'
         *   - skipRootNode: Whether root nodes are skipped or not (defaults to true). Useful for when working with many trees at once.
        «IF targets('1.3.x')»
            «' '»*   - assign:       Variable where the results are assigned to.
            «' '»*
            «' '»* @param  array       $params All attributes passed to this function from the template
            «' '»* @param  Zikula_View $view   Reference to the view object
        «ENDIF»
         *
         * @return string The output of the plugin
         */
        «IF !targets('1.3.x')»public «ENDIF»function «IF targets('1.3.x')»smarty_function_«appName.formatForDB»«ELSE»get«ENDIF»TreeSelection(«IF targets('1.3.x')»$params, $view«ELSE»$objectType, $node, $target, $skipRootNode = true«ENDIF»)
        {
            «IF targets('1.3.x')»
                if (!isset($params['objectType']) || empty($params['objectType'])) {
                    $view->trigger_error(__f('Error! in %1$s: the %2$s parameter must be specified.', array('«appName.formatForDB»TreeSelection', 'objectType')));

                    return false;
                }

                if (!isset($params['node']) || !is_object($params['node'])) {
                    $view->trigger_error(__f('Error! in %1$s: the %2$s parameter must be specified.', array('«appName.formatForDB»TreeSelection', 'node')));

                    return false;
                }

                $allowedTargets = array('allParents', 'directParent', 'allChildren', 'directChildren', 'predecessors', 'successors', 'preandsuccessors');
                if (!isset($params['target']) || empty($params['target']) || !in_array($params['target'], $allowedTargets)) {
                    $view->trigger_error(__f('Error! in %1$s: the %2$s parameter must be specified.', array('«appName.formatForDB»TreeSelection', 'target')));

                    return false;
                }

                $skipRootNode = (isset($params['skipRootNode']) ? (bool) $params['skipRootNode'] : true);

                if (!isset($params['assign']) || empty($params['assign'])) {
                    $view->trigger_error(__f('Error! in %1$s: the %2$s parameter must be specified.', array('«appName.formatForDB»TreeSelection', 'assign')));

                    return false;
                }

                $entityClass = '«appName»_Entity_' . ucfirst($params['objectType']);
            «ENDIF»
            $serviceManager = «IF !targets('1.3.x')»\«ENDIF»ServiceUtil::getManager();
            «IF targets('1.3.x')»
                $entityManager = $serviceManager->get«IF targets('1.3.x')»Service«ENDIF»('«entityManagerService»');
                $repository = $entityManager->getRepository($entityClass);
            «ELSE»
                $repository = $serviceManager->get('«appService».' . $params['objectType'] . '_factory')->getRepository();
            «ENDIF»
            $titleFieldName = $repository->getTitleFieldName();

            «IF targets('1.3.x')»
                $node = $params['node'];
            «ENDIF»
            $result = null;

            switch ($«IF targets('1.3.x')»params['«ENDIF»target«IF targets('1.3.x')»']«ENDIF») {
                case 'allParents':
                case 'directParent':
                    $path = $repository->getPath($node);
                    if (count($path) > 0) {
                        // remove $node
                        unset($path[count($path)-1]);
                    }
                    if ($skipRootNode && count($path) > 0) {
                        // remove root level
                        array_shift($path);
                    }
                    if ($«IF targets('1.3.x')»params['«ENDIF»target«IF targets('1.3.x')»']«ENDIF» == 'allParents') {
                        $result = $path;
                    } elseif ($«IF targets('1.3.x')»params['«ENDIF»target«IF targets('1.3.x')»']«ENDIF» == 'directParent' && count($path) > 0) {
                        $result = $path[count($path)-1];
                    }
                    break;
                case 'allChildren':
                case 'directChildren':
                    $direct = ($«IF targets('1.3.x')»params['«ENDIF»target«IF targets('1.3.x')»']«ENDIF» == 'directChildren');
                    $sortByField = ($titleFieldName != '') ? $titleFieldName : null;
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
                    $result = array_merge($repository->getPrevSiblings($node, $includeSelf), $repository->getNextSiblings($node, $includeSelf));
                    break;
            }

            «IF targets('1.3.x')»
                $view->assign($params['assign'], $result);
            «ELSE»
                return $result;
            «ENDIF»
        }
    '''
}
