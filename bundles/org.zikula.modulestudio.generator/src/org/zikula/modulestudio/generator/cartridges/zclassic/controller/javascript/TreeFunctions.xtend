package org.zikula.modulestudio.generator.cartridges.zclassic.controller.javascript

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class TreeFunctions {
    extension FormattingExtensions = new FormattingExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    /**
     * Entry point for tree-related JavaScript functions.
     */
    def generate(Application it, IFileSystemAccess fsa) {
        var fileName = ''
        if (targets('1.3.x')) {
            fileName = appName + '_tree.js'
        } else {
            fileName = appName + '.Tree.js'
        }
        if (!shouldBeSkipped(getAppJsPath + fileName)) {
            println('Generating JavaScript for tree functions')
            if (shouldBeMarked(getAppJsPath + fileName)) {
                if (targets('1.3.x')) {
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

        «IF targets('1.3.x')»
            var currentNodeId = 0;
        «ELSE»
            var nodeEntityId = 0;
        «ENDIF»

        «performTreeOperation»

        «IF !targets('1.3.x')»
            «initTree»
            
            «treeContextMenuActions»
        «ELSE»
            «initTreeNodes»
        «ENDIF»

        «treeSave»
    '''

    def private initTree(Application it) '''
        var tree;
        var objectType;
        var rootId;
        var hasDisplay;
        var hasEdit;

        /**
         * Initialise a tree.
         */
        function «vendorAndName»InitTree(idPrefix, theObjectType, theRootId, hasDisplayAction, hasEditAction)
        {
            objectType = theObjectType;
            rootId = theRootId;
            hasDisplay = hasDisplayAction;
            hasEdit = hasEditAction;

            tree = jQuery('#' + idPrefix).jstree({
                'core': {
                    'multiple': false,
                    'check_callback': true
                },
                'contextmenu': {
                    'items': «vendorAndName»TreeContextMenuActions
                },
                'dnd': {
                    'copy': false,
                    'is_draggable': function(node) {
                        // disable drag and drop for root category
                        return !jQuery(node).hasClass('lvl0');
                    }
                },
                'state': {
                    'key': idPrefix
                },
                'plugins': [ 'contextmenu', 'dnd', 'search', 'state', 'wholerow'«/*, 'types' */» ]
            });
            «/*
            tree.on('open_node.jstree', function(e, data) {
                if (data.instance.is_leaf(data.node)) {
                    return;
                }
                jQuery('#' + data.node.id)
                    // hide the folder icons
                    .find('a.jstree-anchor.leaf > i.fa-folder').hide().end()
                    // replace folder with folder-open
                    .find('i.jstree-icon.jstree-themeicon').first()
                        .removeClass('fa-folder').addClass('fa-folder-open');
            });
            tree.on('close_node.jstree', function(e, data) {
                if (data.instance.is_leaf(data.node)) {
                    return;
                }
                jQuery('#' + data.node.id).find('i.jstree-icon.jstree-themeicon').first()
                    .removeClass('fa-folder-open').addClass('fa-folder');
            });*/»

            // Drag n drop
            tree.on('move_node.jstree', function (e, data) {
                var node = data.node;
                var parentId = data.parent;
                var parentNode = $tree.jstree('get_node', parentId, false);

                «vendorAndName»TreeSave(node, parentNode, 'bottom');
            });

            // Expand and collapse
            jQuery('#' + idPrefix + 'Expand').click(function(event) {
                event.preventDefault();
                tree.jstree(true).open_all(null, 500);
            });
            jQuery('#' + idPrefix + 'Collapse').click(function(event) {
                event.preventDefault();
                tree.jstree(true).close_all(null, 500);
            });

            // Search
            var searchStartDelay = false;
            jQuery('#' + idPrefix + 'SearchTerm').keyup(function () {
                if (searchStartDelay) {
                    clearTimeout(searchStartDelay);
                }
                searchStartDelay = setTimeout(function () {
                    var v = jQuery('#' + idPrefix + 'SearchTerm').val();
                    tree.jstree(true).search(v);
                }, 250);
            });

            // allow redirecting if a link has been clicked
            tree.find('ul').on('click', 'li.jstree-node a', function(e) {
                tree.jstree('save_state');
                document.location.href = jQuery(this).attr('href');
            });
        }
    '''

    // 1.3.x only
    def private initTreeNodes(Application it) '''
        «IF targets('1.3.x')»
            var «vendorAndName»TreeContextMenu;

            «vendorAndName»TreeContextMenu = Class.create(Zikula.UI.ContextMenu, {
                selectMenuItem: function ($super, event, item, item_container) {
                    // open in new tab / window when right-clicked
                    if (event.isRightClick()) {
                        item.callback(this.clicked, true);
                        «IF targets('1.3.x')»
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

        «ENDIF»
        /**
         * Initialise event handlers for all nodes of a given tree root.
         */
        function «vendorAndName»InitTreeNodes(objectType, rootId, hasDisplay, hasEdit)
        {
            $$('#itemTree' + rootId + ' a').each(function (elem) {
                «initTreeNodesLegacy»
            });
        }
    '''

    def private treeContextMenuActions(Application it) '''
        /**
         * Initialise context menu actions for a given tree node.
         */
        function «vendorAndName»TreeContextMenuActions(theNode)
        {
            «initTreeNodesImpl»
        }
    '''

    def private initTreeNodesImpl(Application it) '''
        var currentNode;
        var isRoot;

        currentNode = tree.jstree('get_node', theNode, true);
        isRoot = (currentNode.attr('id') === 'tree' + rootId + 'node_' + rootId);
        nodeEntityId = currentNode.attr('id').replace('tree' + rootId + 'node_', '');

        var actions = {};

        if (true === hasDisplay) {
            actions.display = {
                label: Translator.__('Display'),
                title: Translator.__('Show detail page'),
                action: function (node) {
                    «/* TODO more detailed differentiation of parameters to be provided, e.g. slugs and composite keys */»
                    document.location.href = Routing.generate('«appName.formatForDB»_' + objectType.toLowerCase() + '_display', { id: nodeEntityId }, true);
                },
                icon: 'fa fa-fw fa-eye'
            };
        }
        if (true === hasEdit) {
            actions.edit = {
                label: Translator.__('Edit'),
                title: Translator.__('Show edit form'),
                action: function (node) {
                    «/* TODO more detailed differentiation of parameters to be provided, e.g. slugs and composite keys */»
                    document.location.href = Routing.generate('«appName.formatForDB»_' + objectType.toLowerCase() + '_edit', { id: nodeEntityId }, true);
                },
                icon: 'fa fa-fw fa-pencil-square-o'
            };
        }
        actions.addChildNode = {
            label: Translator.__('Add child node'),
            title: Translator.__('Add child node'),
            action: function (node) {
                «vendorAndName»PerformTreeOperation(objectType, rootId, 'addChildNode');
            },
            icon: 'fa fa-fw fa-plus'
        };
        actions.deleteNode = {
            label: Translator.__('Delete'),
            title: Translator.__('Delete this node'),
            action: function (node) {
                var confirmQuestion;
                var amountOfChildren;

                confirmQuestion = Translator.__('Do you really want to remove this node?');
                amountOfChildren = node.children.length;
                if (amountOfChildren > 0) {
                    confirmQuestion = Translator.__('Do you really want to remove this node including all child nodes?');
                }
                if (false !== window.confirm(confirmQuestion)) {
                    «vendorAndName»PerformTreeOperation(objectType, rootId, 'deleteNode');
                }
            },
            icon: 'fa fa-fw fa-trash-o'
        };

        if (isRoot) {
            return actions;
        }

        if (currentNode.is(':first-child') && currentNode.is(':last-child')) {
            return actions;
        }

        if (!currentNode.is(':first-child')) { // has previous sibling
            actions.moveUp = {
                label: Translator.__('Move up'),
                title: Translator.__('Move one position up'),
                action: function (node) {
                    «vendorAndName»PerformTreeOperation(objectType, rootId, 'moveNodeUp');
                },
                icon: 'fa fa-fw fa-angle-up',
                separator_before: true
            };
        }
        if (!currentNode.is(':last-child')) { // has next sibling
            actions.moveDown = {
                label: Translator.__('Move down'),
                title: Translator.__('Move one position down'),
                action: function (node) {
                    «vendorAndName»PerformTreeOperation(objectType, rootId, 'moveNodeDown');
                },
                icon: 'fa fa-fw fa-angle-down',
                separator_before: currentNode.is(':first-child')
            };
        }

        return actions;
    '''

    def private initTreeNodesLegacy(Application it) '''
        var liRef, isRoot, contextMenu;

        // get reference to list item
        liRef = elem.up();
        isRoot = (liRef.id === 'tree' + rootId + 'node_' + rootId);

        // define a link id
        elem.id = liRef.id + 'link';

        // and use it to attach a context menu
        contextMenu = new «vendorAndName»TreeContextMenu(elem.id, { leftClick: true, animation: false });
        if (true === hasDisplay) {
            contextMenu.addItem({
                label: '<img src="' + Zikula.Config.baseURL + 'images/icons/extrasmall/kview.png" width="16" height="16" alt="' + Zikula.__('Display', 'module_«appName.formatForDB»_js') + '" /> '
                     + Zikula.__('Display', 'module_«appName.formatForDB»_js'),
                callback: function (selectedMenuItem, isRightClick) {
                    var url;

                    currentNodeId = liRef.id.replace('tree' + rootId + 'node_', '');
                    url = Routing.generate('«appName.formatForDB»_' + objectType.toLowerCase() + '_display', { id: currentNodeId }, true);
                    «/* TODO more detailed differentiation of parameters to be provided, e.g. slugs and composite keys */»

                    if (isRightClick) {
                        window.open(url);
                    } else {
                        window.location = url;
                    }
                }
            });
        }
        if (true === hasEdit) {
            contextMenu.addItem({
                label: '<img src="' + Zikula.Config.baseURL + 'images/icons/extrasmall/edit.png" width="16" height="16" alt="' + Zikula.__('Edit', 'module_«appName.formatForDB»_js') + '" /> '
                     + Zikula.__('Edit', 'module_«appName.formatForDB»_js'),
                callback: function (selectedMenuItem, isRightClick) {
                    var url;

                    currentNodeId = liRef.id.replace('tree' + rootId + 'node_', '');
                    url = Routing.generate('«appName.formatForDB»_' + objectType.toLowerCase() + '_edit', { id: currentNodeId }, true);
                    «/* TODO more detailed differentiation of parameters to be provided, e.g. slugs and composite keys */»

                    if (isRightClick) {
                        window.open(url);
                    } else {
                        window.location = url;
                    }
                }
            });
        }
        contextMenu.addItem({
            label: '<img src="' + Zikula.Config.baseURL + 'images/icons/extrasmall/insert_table_row.png" width="16" height="16" alt="' + Zikula.__('Add child node', 'module_«appName.formatForDB»_js') + '" /> '
                 + Zikula.__('Add child node', 'module_«appName.formatForDB»_js'),
            callback: function () {
                currentNodeId = liRef.id.replace('tree' + rootId + 'node_', '');
                «vendorAndName»PerformTreeOperation(objectType, rootId, 'addChildNode');
            }
        });
        contextMenu.addItem({
            label: '<img src="' + Zikula.Config.baseURL + 'images/icons/extrasmall/14_layer_deletelayer.png" width="16" height="16" alt="' + Zikula.__('Delete node', 'module_«appName.formatForDB»_js') + '" /> '
                 + Zikula.__('Delete node', 'module_«appName.formatForDB»_js'),
            callback: function () {
                var confirmQuestion;

                confirmQuestion = Zikula.__('Do you really want to remove this node?', 'module_«appName.formatForDB»_js');
                if (!liRef.hasClassName('z-tree-leaf')) {
                    confirmQuestion = Zikula.__('Do you really want to remove this node including all child nodes?', 'module_«appName.formatForDB»_js');
                }
                if (false !== window.confirm(confirmQuestion)) {
                    currentNodeId = liRef.id.replace('tree' + rootId + 'node_', '');
                    «vendorAndName»PerformTreeOperation(objectType, rootId, 'deleteNode');
                }
            }
        });
        contextMenu.addItem({
            label: '<img src="' + Zikula.Config.baseURL + 'images/icons/extrasmall/14_layer_raiselayer.png" width="16" height="16" alt="' + Zikula.__('Move up', 'module_«appName.formatForDB»_js') + '" /> '
                 + Zikula.__('Move up', 'module_«appName.formatForDB»_js'),
            condition: function () {
                return !isRoot && !liRef.hasClassName('z-tree-first'); // has previous sibling
            },
            callback: function () {
                currentNodeId = liRef.id.replace('tree' + rootId + 'node_', '');
                «vendorAndName»PerformTreeOperation(objectType, rootId, 'moveNodeUp');
            }
        });
        contextMenu.addItem({
            label: '<img src="' + Zikula.Config.baseURL + 'images/icons/extrasmall/14_layer_lowerlayer.png" width="16" height="16" alt="' + Zikula.__('Move down', 'module_«appName.formatForDB»_js') + '" /> '
                 + Zikula.__('Move down', 'module_«appName.formatForDB»_js'),
            condition: function () {
                return !isRoot && !liRef.hasClassName('z-tree-last'); // has next sibling
            },
            callback: function () {
                currentNodeId = liRef.attr('id').replace('tree' + rootId + 'node_', '');
                «vendorAndName»PerformTreeOperation(objectType, rootId, 'moveNodeDown');
            }
        });
    '''

    def private performTreeOperation(Application it) '''
        /**
         * Helper function to start several different ajax actions
         * performing tree related amendments and operations.
         */
        function «vendorAndName»PerformTreeOperation(objectType, rootId, op)
        {
            var opParam, params«IF targets('1.3.x')», request«ENDIF»;

            opParam = ((op === 'moveNodeUp' || op === 'moveNodeDown') ? 'moveNode' : op);
            params = 'ot=' + objectType + '&op=' + opParam;

            if (op !== 'addRootNode') {
                params += '&root=' + rootId;

                if (!«IF targets('1.3.x')»currentNodeId«ELSE»nodeEntityId«ENDIF») {
                    «IF targets('1.3.x')»
                        Zikula.UI.Alert(Zikula.__('Invalid node id', 'module_«appName.formatForDB»_js'), Zikula.__('Error', 'module_«appName.formatForDB»_js'));
                    «ELSE»
                        «vendorAndName»SimpleAlert(jQuery('.tree-container'), Translator.__('Error'), Translator.__('Invalid node id'), 'treeInvalidNodeAlert', 'danger');
                    «ENDIF»
                }
                params += '&' + ((op === 'addChildNode') ? 'pid' : 'id') + '=' + «IF targets('1.3.x')»currentNodeId«ELSE»nodeEntityId«ENDIF»;

                if (op === 'moveNodeUp') {
                    params += '&direction=up';
                } else if (op === 'moveNodeDown') {
                    params += '&direction=down';
                }
            }

            «IF targets('1.3.x')»
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
                jQuery.ajax({
                    type: 'POST',
                    url: Routing.generate('«appName.formatForDB»_ajax_handletreeoperation'),
                    data: params
                }).done(function(res) {
                    // get data returned by the ajax response
                    var data;

                    data = res.data;

                    /*if (data.message) {
                        «vendorAndName»SimpleAlert(jQuery('.tree-container'), Translator.__('Success'), data.message, 'treeAjaxDoneAlert', 'success');
                    }*/

                    window.location.reload();
                }).fail(function(jqXHR, textStatus) {
                    «vendorAndName»SimpleAlert(jQuery('.tree-container'), Translator.__('Error'), Translator.__('Could not persist your change.'), 'treeAjaxFailedAlert', 'danger');
                });
            «ENDIF»
        }
    '''

    def private treeSave(Application it) '''
        /**
         * Callback function for config.onSave. This function is called after each tree change.
         *
         * @param node - the node which is currently being moved
        «IF targets('1.3.x')»
            «' '»* @param params - array with insertion params, which are [relativenode, dir];
            «' '»*     - "dir" is a string with value "after", "before" or "bottom" and defines
            «' '»*       whether the affected node is inserted after, before or as last child of "relativenode"
            «' '»* @param tree data - serialized to JSON tree data
        «ELSE»
            «' '»* @param parentNode - the new parent node
            «' '»* @param position - can be "after", "before" or "bottom" and defines
            «' '»*       whether the affected node is inserted after, before or as last child of "relativenode"
        «ENDIF»
         *
         * @return true on success, otherwise the change will be reverted
         */
        function «vendorAndName»TreeSave(node, «IF targets('1.3.x')»params, data«ELSE»parentNode, position«ENDIF»)
        {
            var nodeParts, rootId, nodeId, destId, requestParams«IF targets('1.3.x')», request«ENDIF»;

            // do not allow inserts on root level
            «IF targets('1.3.x')»
                if (node.up('li') === undefined) {
                    return false;
                }
            «ELSE»
                if (node.parents.find('li').length < 1) {
                    return false;
                }
            «ENDIF»

            «IF targets('1.3.x')»
                nodeParts = node.id.split('node_');
                rootId = nodeParts[0].replace('tree', '');
                nodeId = nodeParts[1];
                destId = params[1].id.replace('tree' + rootId + 'node_', '');
            «ELSE»
                nodeParts = node.attr('id').split('node_');
                rootId = nodeParts[0].replace('tree', '');
                nodeId = nodeParts[1];
                destId = parentNode.attr('id').replace('tree' + rootId + 'node_', '');
            «ENDIF»

            requestParams = {
                'op': 'moveNodeTo',
                'direction': «IF targets('1.3.x')»params[0]«ELSE»position«ENDIF»,
                'root': rootId,
                'id': nodeId,
                'destid': destId
            };

            «IF targets('1.3.x')»
                request = new Zikula.Ajax.Request(
                    Zikula.Config.baseURL + 'ajax.php?module=«appName»&func=handleTreeOperation',
                    {
                        method: 'post',
                        parameters: requestParams,
                        onComplete: function (req) {
                            if (!req.isSuccess()) {
                                var treeName = 'itemTree' + rootId;
                                Zikula.UI.Alert(req.getMessage(), Zikula.__('Error', 'module_«appName.formatForDB»_js'));

                                return Zikula.TreeSortable[treeName].revertInsertion();
                            }
                            return true;
                        }
                    }
                );

                return request.success();
            «ELSE»
                jQuery.ajax({
                    type: 'POST',
                    url: Routing.generate('«appName.formatForDB»_ajax_handletreeoperation'),
                    data: requestParams
                }).done(function(res) {
                    return true;
                }).fail(function(jqXHR, textStatus) {
                    var treeName = 'itemTree' + rootId;
                    «vendorAndName»SimpleAlert(jQuery('.tree-container'), Translator.__('Error'), Translator.__('Could not persist your change.'), 'treeAjaxFailedAlert', 'danger');

                    window.location.reload();
                    return false;
                });

                return true;
            «ENDIF»
        }
    '''
}
