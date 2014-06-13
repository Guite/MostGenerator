package org.zikula.modulestudio.generator.cartridges.zclassic.controller.javascript

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class TreeFunctions {
    @Inject extension FormattingExtensions = new FormattingExtensions
    @Inject extension NamingExtensions = new NamingExtensions
    @Inject extension Utils = new Utils

    /**
     * Entry point for tree-related JavaScript functions.
     */
    def generate(Application it, IFileSystemAccess fsa) {
        var fileName = ''
        if (targets('1.3.5')) {
            fileName = appName + '_tree.js'
        } else {
            fileName = appName + '.Tree.js'
        }
        if (!shouldBeSkipped(getAppJsPath + fileName)) {
            println('Generating JavaScript for tree functions')
            if (shouldBeMarked(getAppJsPath + fileName)) {
                if (targets('1.3.5')) {
                    fileName = appName + '_tree.generated.js'
                } else {
                    fileName = appName + '.Tree.generated.js'
                }
            }
            fsa.generateFile(getAppJsPath + fileName, generate)
        }
    }

    def private generate(Application it) '''
        'use strict';

        var currentNodeId = 0;

        «performTreeOperation»

        «initTreeNodes»

        «treeSave»
    '''

    def private initTreeNodes(Application it) '''
        var «prefix()»TreeContextMenu;

        «prefix()»TreeContextMenu = Class.create(Zikula.UI.ContextMenu, {
            selectMenuItem: function ($super, event, item, item_container) {
                // open in new tab / window when right-clicked
                if (event.isRightClick()) {
                    item.callback(this.clicked, true);
                    «IF targets('1.3.5')»
                        event.stop(); // close the menu
                    «ELSE»
                        event.stopPropagation(); // close the menu
                    «ENDIF»
                    return;
                }
                // open in current window when left-clicked
                return $super(event, item, item_container);
            }
        });

        /**
         * Initialise event handlers for all nodes of a given tree root.
         */
        function «prefix()»InitTreeNodes(objectType, rootId, hasDisplay, hasEdit)
        {
            «IF targets('1.3.5')»$«ENDIF»$('#itemTree' + rootId + ' a').each(function (elem) {
                var liRef, isRoot, contextMenu;

                // get reference to list item
                «IF targets('1.3.5')»
                    liRef = elem.up();
                    isRoot = (liRef.id === 'tree' + rootId + 'node_' + rootId);
                «ELSE»
                    liRef = elem.parent();
                    isRoot = (liRef.attr('id') === 'tree' + rootId + 'node_' + rootId);
                «ENDIF»

                // define a link id
                «IF targets('1.3.5')»
                    elem.id = liRef.id + 'link';
                «ELSE»
                    elem.attr('id', liRef.attr('id') + 'link');
                «ENDIF»

                // and use it to attach a context menu
                contextMenu = new «prefix()»TreeContextMenu(elem.id, { leftClick: true, animation: false });
                if (hasDisplay === true) {
                    contextMenu.addItem({
                        label: '«IF targets('1.3.5')»<img src="' + Zikula.Config.baseURL + 'images/icons/extrasmall/kview.png" width="16" height="16" alt="' + Zikula.__('Display', 'module_«appName.formatForDB»_js') + '" />«ELSE»<span class="fa fa-eye"></span>«ENDIF» '
                             + Zikula.__('Display', 'module_«appName.formatForDB»_js'),
                        callback: function (selectedMenuItem, isRightClick) {
                            var url;

                            «IF targets('1.3.5')»
                                currentNodeId = liRef.id.replace('tree' + rootId + 'node_', '');
                            «ELSE»
                                currentNodeId = liRef.attr('id').replace('tree' + rootId + 'node_', '');
                            «ENDIF»
                            url = Zikula.Config.baseURL + 'index.php?module=«appName»&type=' + objectType + '&func=display&id=' + currentNodeId;

                            if (isRightClick) {
                                window.open(url);
                            } else {
                                window.location = url;
                            }
                        }
                    });
                }
                if (hasEdit === true) {
                    contextMenu.addItem({
                        label: '«IF targets('1.3.5')»<img src="' + Zikula.Config.baseURL + 'images/icons/extrasmall/edit.png" width="16" height="16" alt="' + Zikula.__('Edit', 'module_«appName.formatForDB»_js') + '" />«ELSE»<span class="fa fa-pencil-square-o"></span>«ENDIF» '
                             + Zikula.__('Edit', 'module_«appName.formatForDB»_js'),
                        callback: function (selectedMenuItem, isRightClick) {
                            var url;

                            «IF targets('1.3.5')»
                                currentNodeId = liRef.id.replace('tree' + rootId + 'node_', '');
                            «ELSE»
                                currentNodeId = liRef.attr('id').replace('tree' + rootId + 'node_', '');
                            «ENDIF»
                            url = Zikula.Config.baseURL + 'index.php?module=«appName»&type=' + objectType + '&func=edit&id=' + currentNodeId;

                            if (isRightClick) {
                                window.open(url);
                            } else {
                                window.location = url;
                            }
                        }
                    });
                }
                contextMenu.addItem({
                    label: '«IF targets('1.3.5')»<img src="' + Zikula.Config.baseURL + 'images/icons/extrasmall/insert_table_row.png" width="16" height="16" alt="' + Zikula.__('Add child node', 'module_«appName.formatForDB»_js') + '" />«ELSE»<span class="fa fa-plus"></span>«ENDIF» '
                         + Zikula.__('Add child node', 'module_«appName.formatForDB»_js'),
                    callback: function () {
                        «IF targets('1.3.5')»
                            currentNodeId = liRef.id.replace('tree' + rootId + 'node_', '');
                        «ELSE»
                            currentNodeId = liRef.attr('id').replace('tree' + rootId + 'node_', '');
                        «ENDIF»
                        «prefix()»PerformTreeOperation(objectType, rootId, 'addChildNode');
                    }
                });
                contextMenu.addItem({
                    label: '«IF targets('1.3.5')»<img src="' + Zikula.Config.baseURL + 'images/icons/extrasmall/14_layer_deletelayer.png" width="16" height="16" alt="' + Zikula.__('Delete node', 'module_«appName.formatForDB»_js') + '" />«ELSE»<span class="fa fa-trash-o"></span>«ENDIF» '
                         + Zikula.__('Delete node', 'module_«appName.formatForDB»_js'),
                    callback: function () {
                        var confirmQuestion;

                        confirmQuestion = Zikula.__('Do you really want to remove this node?', 'module_«appName.formatForDB»_js');
                        «IF targets('1.3.5')»
                            if (!liRef.hasClassName('z-tree-leaf')) {
                                confirmQuestion = Zikula.__('Do you really want to remove this node including all child nodes?', 'module_«appName.formatForDB»_js');
                            }
                        «ELSE»
                            if (!liRef.hasClass('z-tree-leaf')) {
                                confirmQuestion = Zikula.__('Do you really want to remove this node including all child nodes?', 'module_«appName.formatForDB»_js');
                            }
                        «ENDIF»
                        if (window.confirm(confirmQuestion) !== false) {
                            «IF targets('1.3.5')»
                                currentNodeId = liRef.id.replace('tree' + rootId + 'node_', '');
                            «ELSE»
                                currentNodeId = liRef.attr('id').replace('tree' + rootId + 'node_', '');
                            «ENDIF»
                            «prefix()»PerformTreeOperation(objectType, rootId, 'deleteNode');
                        }
                    }
                });
                contextMenu.addItem({
                    label: '«IF targets('1.3.5')»<img src="' + Zikula.Config.baseURL + 'images/icons/extrasmall/14_layer_raiselayer.png" width="16" height="16" alt="' + Zikula.__('Move up', 'module_«appName.formatForDB»_js') + '" />«ELSE»<span class="fa fa-angle-up"></span>«ENDIF» '
                         + Zikula.__('Move up', 'module_«appName.formatForDB»_js'),
                    condition: function () {
                        «IF targets('1.3.5')»
                            return !isRoot && !liRef.hasClassName('z-tree-first'); // has previous sibling
                        «ELSE»
                            return !isRoot && !liRef.hasClass('z-tree-first'); // has previous sibling
                        «ENDIF»
                    },
                    callback: function () {
                        «IF targets('1.3.5')»
                            currentNodeId = liRef.id.replace('tree' + rootId + 'node_', '');
                        «ELSE»
                            currentNodeId = liRef.attr('id').replace('tree' + rootId + 'node_', '');
                        «ENDIF»
                        «prefix()»PerformTreeOperation(objectType, rootId, 'moveNodeUp');
                    }
                });
                contextMenu.addItem({
                    label: '«IF targets('1.3.5')»<img src="' + Zikula.Config.baseURL + 'images/icons/extrasmall/14_layer_lowerlayer.png" width="16" height="16" alt="' + Zikula.__('Move down', 'module_«appName.formatForDB»_js') + '" />«ELSE»<span class="fa fa-angle-down"></span>«ENDIF» '
                         + Zikula.__('Move down', 'module_«appName.formatForDB»_js'),
                    condition: function () {
                        «IF targets('1.3.5')»
                            return !isRoot && !liRef.hasClassName('z-tree-last'); // has next sibling
                        «ELSE»
                            return !isRoot && !liRef.hasClass('z-tree-last'); // has next sibling
                        «ENDIF»
                    },
                    callback: function () {
                        «IF targets('1.3.5')»
                            currentNodeId = liRef.id.replace('tree' + rootId + 'node_', '');
                        «ELSE»
                            currentNodeId = liRef.attr('id').replace('tree' + rootId + 'node_', '');
                        «ENDIF»
                        «prefix()»PerformTreeOperation(objectType, rootId, 'moveNodeDown');
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
        function «prefix()»PerformTreeOperation(objectType, rootId, op)
        {
            var opParam, params«IF targets('1.3.5')», request«ENDIF»;

            opParam = ((op === 'moveNodeUp' || op === 'moveNodeDown') ? 'moveNode' : op);
            params = 'ot=' + objectType + '&op=' + opParam;

            if (op !== 'addRootNode') {
                params += '&root=' + rootId;

                if (!currentNodeId) {
                    «IF targets('1.3.5')»
                        Zikula.UI.Alert(Zikula.__('Invalid node id', 'module_«appName.formatForDB»_js'), Zikula.__('Error', 'module_«appName.formatForDB»_js'));
                    «ELSE»
                        «prefix()»SimpleAlert($('.tree-container'), Zikula.__('Error', 'module_«appName.formatForDB»_js'), Zikula.__('Invalid node id', 'module_«appName.formatForDB»_js'), 'treeInvalidNodeAlert', 'danger');
                    «ENDIF»
                }
                params += '&' + ((op === 'addChildNode') ? 'pid' : 'id') + '=' + currentNodeId;

                if (op === 'moveNodeUp') {
                    params += '&direction=up';
                } else if (op === 'moveNodeDown') {
                    params += '&direction=down';
                }
            }

            «IF targets('1.3.5')»
                request = new Zikula.Ajax.Request(
                    Zikula.Config.baseURL + 'ajax.php?module=«appName»&func=handleTreeOperation',
                    {
                        method: 'post',
                        parameters: params,
                        onComplete: function (req) {
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
            «ELSE»
                $.ajax({
                    type: 'POST',
                    url: Zikula.Config.baseURL + 'index.php?module=«appName»&type=ajax&func=handleTreeOperation',
                    data: params
                }).done(function(res) {
                    // get data returned by the ajax response
                    var data;

                    data = res.data;

                    /*if (data.message) {
                        «prefix()»SimpleAlert($('.tree-container'), Zikula.__('Success', 'module_«appName.formatForDB»_js'), data.message, 'treeAjaxDoneAlert', 'success');
                    }*/

                    window.location.reload();
                }).fail(function(jqXHR, textStatus) {
                    «prefix()»SimpleAlert($('.tree-container'), Zikula.__('Error', 'module_«appName.formatForDB»_js'), Zikula.__('Could not persist your change.', 'module_«appName.formatForDB»_js'), 'treeAjaxFailedAlert', 'danger');
                });
            «ENDIF»
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
        function «prefix()»TreeSave(node, params, data)
        {
            var nodeParts, rootId, nodeId, destId, params«IF targets('1.3.5')», request«ENDIF»;

            // do not allow inserts on root level
            «IF targets('1.3.5')»
                if (node.up('li') === undefined) {
                    return false;
                }
            «ELSE»
                if (node.parents.find('li').size() < 1) {
                    return false;
                }
            «ENDIF»

            «IF targets('1.3.5')»
                nodeParts = node.id.split('node_');
                rootId = nodeParts[0].replace('tree', '');
                nodeId = nodeParts[1];
                destId = params[1].id.replace('tree' + rootId + 'node_', '');
            «ELSE»
                nodeParts = node.attr('id').split('node_');
                rootId = nodeParts[0].replace('tree', '');
                nodeId = nodeParts[1];
                destId = params[1].attr('id').replace('tree' + rootId + 'node_', '');
            «ENDIF»

            params = {
                'op': 'moveNodeTo',
                'direction': params[0],
                'root': rootId,
                'id': nodeId,
                'destid': destId
            };

            «IF targets('1.3.5')»
                request = new Zikula.Ajax.Request(
                    Zikula.Config.baseURL + 'ajax.php?module=«appName»&func=handleTreeOperation',
                    {
                        method: 'post',
                        parameters: params,
                        onComplete: function (req) {
                            if (!req.isSuccess()) {
                                Zikula.UI.Alert(req.getMessage(), Zikula.__('Error', 'module_«appName.formatForDB»_js'));

                                return Zikula.TreeSortable.categoriesTree.revertInsertion();
                            }
                            return true;
                        }
                    }
                );

                return request.success();
            «ELSE»
                $.ajax({
                    type: 'POST',
                    url: Zikula.Config.baseURL + 'index.php?module=«appName»&type=ajax&func=handleTreeOperation',
                    data: params
                }).done(function(res) {
                    return true;
                }).fail(function(jqXHR, textStatus) {
                    «prefix()»SimpleAlert($('.tree-container'), Zikula.__('Error', 'module_«appName.formatForDB»_js'), Zikula.__('Could not persist your change.', 'module_«appName.formatForDB»_js'), 'treeAjaxFailedAlert', 'danger');

                    return Zikula.TreeSortable.categoriesTree.revertInsertion();
                });

                return true;
            «ENDIF»
        }
    '''
}
