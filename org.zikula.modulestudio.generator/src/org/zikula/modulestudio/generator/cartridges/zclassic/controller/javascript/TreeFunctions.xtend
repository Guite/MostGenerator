package org.zikula.modulestudio.generator.cartridges.zclassic.controller.javascript

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class TreeFunctions {
    @Inject extension FormattingExtensions = new FormattingExtensions()
    @Inject extension NamingExtensions = new NamingExtensions()
    @Inject extension Utils = new Utils()

    /**
     * Entry point for tree-related javascript functions.
     */
    def generate(Application it, IFileSystemAccess fsa) {
        fsa.generateFile(getAppSourcePath(appName) + 'javascript/' + appName + '_tree.js', generate)
    }

    def private generate(Application it) '''

        var currentNodeId = 0;

        «initTreeNodes»

        «performTreeOperation»

        «treeSave»
    '''

    def private initTreeNodes(Application it) '''
        /**
         * Initialise event handlers for all nodes of a given tree root.
         */
        function «prefix»InitTreeNodes(objectType, controller, rootId, hasDisplay, hasEdit)
        {
            $$('#itemtree' + rootId + ' a').each(function(elem) {
                // get reference to list item
                var liRef = elem.up();
                var isRoot = (liRef.id == 'tree' + rootId + 'node_' + rootId);

                // define a link id
                elem.id = liRef.id + 'link';

                // and use it to attach a context menu
                var contextMenu = new Control.ContextMenu(elem.id, { leftClick: true, animation: false });
                if (hasDisplay === true) {
                    contextMenu.addItem({
                        label: '<img src="/images/icons/extrasmall/kview.png" width="16" height="16" alt="' + Zikula.__('Display', 'module_«appName.formatForDB»_js') + '" /> '
                             + Zikula.__('Display', 'module_«appName.formatForDB»_js'),
                        callback: function() {
                            currentNodeId = liRef.id.replace('tree' + rootId + 'node_', '');
                            window.location = Zikula.Config.baseURL + 'index.php?module=«appName»&type=' + controller + '&func=display&ot=' + objectType + '&id=' + currentNodeId;
                        }
                    });
                }
                if (hasEdit === true) {
                    contextMenu.addItem({
                        label: '<img src="/images/icons/extrasmall/edit.png" width="16" height="16" alt="' + Zikula.__('Edit', 'module_«appName.formatForDB»_js') + '" /> '
                             + Zikula.__('Edit', 'module_«appName.formatForDB»_js'),
                        callback: function() {
                            currentNodeId = liRef.id.replace('tree' + rootId + 'node_', '');
                            window.location = Zikula.Config.baseURL + 'index.php?module=«appName»&type=' + controller + '&func=edit&ot=' + objectType + '&id=' + currentNodeId;
                        }
                    });
                }
                contextMenu.addItem({
                    label: '<img src="/images/icons/extrasmall/insert_table_row.png" width="16" height="16" alt="' + Zikula.__('Add child node', 'module_«appName.formatForDB»_js') + '" /> '
                         + Zikula.__('Add child node', 'module_«appName.formatForDB»_js'),
                    callback: function() {
                        currentNodeId = liRef.id.replace('tree' + rootId + 'node_', '');
                        «prefix»PerformTreeOperation(objectType, rootId, 'addChildNode');
                    }
                });
                contextMenu.addItem({
                    label: '<img src="/images/icons/extrasmall/14_layer_deletelayer.png" width="16" height="16" alt="' + Zikula.__('Delete node', 'module_«appName.formatForDB»_js') + '" /> '
                         + Zikula.__('Delete node', 'module_«appName.formatForDB»_js'),
                    callback: function() {
                        var confirmQuestion = Zikula.__('Do you really want to remove this node?', 'module_«appName.formatForDB»_js');
                        if (!liRef.hasClassName('z-tree-leaf')) {
                            confirmQuestion = Zikula.__('Do you really want to remove this node including all child nodes?', 'module_«appName.formatForDB»_js');
                        }
                        if (window.confirm(confirmQuestion) != false) {
                            currentNodeId = liRef.id.replace('tree' + rootId + 'node_', '');
                            «prefix»PerformTreeOperation(objectType, rootId, 'deleteNode');
                        }
                    }
                });
                contextMenu.addItem({
                    label: '<img src="/images/icons/extrasmall/14_layer_raiselayer.png" width="16" height="16" alt="' + Zikula.__('Move up', 'module_«appName.formatForDB»_js') + '" /> '
                         + Zikula.__('Move up', 'module_«appName.formatForDB»_js'),
                    condition: function() {
                        return !isRoot && !liRef.hasClassName('z-tree-first'); // has previous sibling
                    },
                    callback: function() {
                        currentNodeId = liRef.id.replace('tree' + rootId + 'node_', '');
                        «prefix»PerformTreeOperation(objectType, rootId, 'moveNodeUp');
                    }
                });
                contextMenu.addItem({
                    label: '<img src="/images/icons/extrasmall/14_layer_lowerlayer.png" width="16" height="16" alt="' + Zikula.__('Move down', 'module_«appName.formatForDB»_js') + '" /> '
                         + Zikula.__('Move down', 'module_«appName.formatForDB»_js'),
                    condition: function() {
                        return !isRoot && !liRef.hasClassName('z-tree-last'); // has next sibling
                    },
                    callback: function() {
                        currentNodeId = liRef.id.replace('tree' + rootId + 'node_', '');
                        «prefix»PerformTreeOperation(objectType, rootId, 'moveNodeDown');
                    }
                });
            });
        }
    '''

    def private performTreeOperation(Application it) '''
        /**
         * Helper function to start several different ajax actions
         * performing tree related amendments and operations.
         */
        function «prefix»PerformTreeOperation(objectType, rootId, op)
        {
            var opParam = ((op == 'moveNodeUp' || op == 'moveNodeDown') ? 'moveNode' : op);
            var pars = 'ot=' + objectType + '&op=' + opParam;

            if (op != 'addRootNode') {
                pars += '&root=' + rootId;

                if (!currentNodeId) {
                    Zikula.UI.Alert('Invalid node id', Zikula.__('Error', 'module_«appName.formatForDB»_js'));
                }
                pars += '&' + ((op == 'addChildNode') ? 'pid' : 'id') + '=' + currentNodeId;

                if (op == 'moveNodeUp') {
                    pars += '&direction=up';
                } else if (op == 'moveNodeDown') {
                    pars += '&direction=down';
                }
            }

            new Zikula.Ajax.Request(
                Zikula.Config.baseURL + 'ajax.php?module=«appName»&func=handleTreeOperation',
                {
                    method: 'post',
                    parameters: pars,
                    onComplete: function(req) {
                        if (!req.isSuccess()) {
                            Zikula.UI.Alert(req.getMessage(), Zikula.__('Error', 'module_«appName.formatForDB»_js'));
                            return;
                        }
                        var data = req.getData();
                        /*if (data.message) {
                            Zikula.UI.Alert(data.message, Zikula.__('Success', 'module_«appName.formatForDB»_js'));
                        }*/
                        window.location.reload();
                    }
                }
            );
        }
    '''

    def private treeSave(Application it) '''
        /**
         * Callback function for config.onSave. This function is called after each tree change.
         *
         * @param node - the node which is currently being moved
         * @param params - array with insertion params, which are [relativenode, dir];
         *     - "dir" is a string with value "after', "before" or "bottom" and defines
         *       whether the affected node is inserted after, before or as last child of "relativenode"
         * @param tree data - serialized to JSON tree data
         *
         * @return true on success, otherwise the change will be reverted
         */
        function «prefix»TreeSave(node, params, data) {
            // do not allow inserts on root level
            if (node.up('li') == undefined) {
                return false;
            }

            var nodeParts = node.id.split('node_');
            var rootId = nodeParts[0].replace('tree', '');
            var nodeId = nodeParts[1];
            var destId = params[1].id.replace('tree' + rootId + 'node_', '');

            var pars = {
                'op': 'moveNodeTo',
                'direction': params[0],
                'root': rootId,
                'id': nodeId,
                'destid': destId
            }

            var request = new Zikula.Ajax.Request(
                Zikula.Config.baseURL + 'ajax.php?module=«appName»&func=handleTreeOperation',
                {
                    method: 'post',
                    parameters: pars,
                    onComplete: function(req) {
                        if (!req.isSuccess()) {
                            Zikula.UI.Alert(req.getMessage(), Zikula.__('Error', 'module_«appName.formatForDB»_js'));
                            return Zikula.TreeSortable.categoriesTree.revertInsertion();
                        }
                return true;
                    }
                });
            return request.success();
        }
    '''
}
