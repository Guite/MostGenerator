package org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class TreeJS {
    @Inject extension ControllerExtensions = new ControllerExtensions
    @Inject extension FormattingExtensions = new FormattingExtensions
    @Inject extension NamingExtensions = new NamingExtensions
    @Inject extension Utils = new Utils

    def generate(Application it, IFileSystemAccess fsa) {
        val pluginFilePath = viewPluginFilePath('function', 'TreeJS')
        if (!shouldBeSkipped(pluginFilePath)) {
            fsa.generateFile(pluginFilePath, new FileHelper().phpFileContent(it, treeJsImpl))
        }
    }

    def private treeJsImpl(Application it) '''
        /**
         * The «appName.formatForDB»TreeJS plugin delivers the html output for a JS tree
         * based on given tree entities.
         *
         * Available parameters:
         *   - objectType: Name of treated object type.
         *   - tree:       Object collection with tree items.
         *   - controller: Optional name of controller, defaults to 'user'.
         *   - root:       Optional id of root node, defaults to 1.
         *   - assign:     If set, the results are assigned to the corresponding variable instead of printed out.
         *
         * @param  array       $params  All attributes passed to this function from the template.
         * @param  Zikula_View $view    Reference to the view object.
         *
         * @return string The output of the plugin.
         */
        function smarty_function_«appName.formatForDB»TreeJS($params, $view)
        {
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

            // check whether an edit action is available
            $controllerHasEditAction = false;
            switch ($params['controller']) {
                «controllerEditActionFlags»
            }

            «IF targets('1.3.5')»
                $entityClass = '«appName»_Entity_' . ucwords($params['objectType']);
            «ELSE»
                $entityClass = '«vendor.formatForCodeCapital»«name.formatForCodeCapital»Module:' . ucwords($params['objectType']) . 'Entity';
            «ENDIF»
            $serviceManager = ServiceUtil::getManager();
            $entityManager = $serviceManager->get«IF targets('1.3.5')»Service«ENDIF»('doctrine.entitymanager');
            $repository = $entityManager->getRepository($entityClass);
            $descriptionFieldName = $repository->getDescriptionFieldName();

«/* TODO improve identifier handling in treejs plugin */»
            $idField = 'id';
            $result = array();

            foreach ($params['tree'] as $item) {
                «IF targets('1.3.5')»
                    $url = $controllerHasEditAction ? ModUtil::url('«appName»', $params['controller'], 'edit', array('ot' => $params['objectType'], $idField => $item[$idField])) : '';
                «ELSE»
                    $urlArgs = $item->createUrlArgs();
                    $url = $controllerHasEditAction ? $serviceManager->get('router')->generate('«appName.formatForDB»_' . $params['objectType'] . '_edit', $urlArgs) : '';
                «ENDIF»

                $parentItem = $item->getParent();

                $result[] = array('id' => $item[$idField],
                                  'parent_id' => $parentItem[$idField],
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
            //$tree->setOption('objid', $idField);
            $tree->setOption('treeClass', 'z-nestedsetlist');
            $tree->setOption('nodePrefix', 'tree' . $params['root'] . 'node_');
            $tree->setOption('sortable', ((isset($params['sortable']) && $params['sortable']) ? true : false));
            $tree->setOption('withWraper', true);

            // disable drag and drop for root category
            $tree->setOption('disabled', array(1));

            // put data into output tree
            $tree->loadArrayData($result);

            // get output result
            $result = $tree->getHTML();

            if (array_key_exists('assign', $params)) {
                $view->assign($params['assign'], $result);

                return;
            }

            return $result;
        }
    '''

    def private controllerEditActionFlags(Application it) '''
        «FOR controller : getAllControllers.filter[hasActions('edit')]»
            case '«controller.formattedName»': $controllerHasEditAction = true; break;
        «ENDFOR»
    '''
}
