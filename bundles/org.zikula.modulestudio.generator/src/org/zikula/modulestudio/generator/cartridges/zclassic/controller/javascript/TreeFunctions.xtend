package org.zikula.modulestudio.generator.cartridges.zclassic.controller.javascript

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class TreeFunctions {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    /**
     * Entry point for tree-related JavaScript functions.
     */
    def generate(Application it, IMostFileSystemAccess fsa) {
        if (!hasTrees) {
            return
        }
        'Generating JavaScript for tree functions'.printIfNotTesting(fsa)
        val fileName = appName + '.Tree.js'
        fsa.generateFile(getAppJsPath + fileName, generate)
    }

    def private generate(Application it) '''
        'use strict';

        var nodeEntityId = 0;

        «performTreeOperation»

        «initTree»
        
        «treeContextMenuActions»

        «treeDropNode»

        «treeMoveNode»

        «onLoad»
    '''

    def private initTree(Application it) '''
        var trees;
        var tree;
        var idPrefix;
        var rootId;
        var objectType;
        var routeArgNames;
        var hasDetailAction;
        var hasEditAction;

        /**
         * Initialise a tree.
         */
        function «vendorAndName»InitTree(treeContainer) {
            idPrefix = treeContainer.attr('id');
            rootId = treeContainer.data('root-id');
            objectType = treeContainer.data('object-type');
            routeArgNames = treeContainer.data('urlargnames').split(',');
            hasDetailAction = treeContainer.data('has-detail');
            hasEditAction = treeContainer.data('has-edit');

            trees[idPrefix] = jQuery('#' + idPrefix).jstree({
                'core': {
                    'multiple': false,
                    'check_callback': true
                },
                'contextmenu': {
                    'items': «vendorAndName»TreeContextMenuActions
                },
                'dnd': {
                    'copy': false,
                    'is_draggable': function (node) {
                        // disable drag and drop for root category
                        return node[0].parent != '#';
                    },
                    // drop as last child
                    'inside_pos': 'last'
                },
                'state': {
                    'key': idPrefix
                },
                'plugins': [ 'contextmenu', 'dnd', 'search', 'state', 'wholerow'«/*, 'types' */» ]
            });
            tree = trees[idPrefix];
            «/*
            tree.on('open_node.jstree', function (event, data) {
                if (data.instance.is_leaf(data.node)) {
                    return;
                }
                jQuery('#' + data.node.id)
                    // hide the folder icons
                    .find('a.jstree-anchor.leaf > i.fa-folder').addClass('d-none).end()
                    // replace folder with folder-open
                    .find('i.jstree-icon.jstree-themeicon').first()
                        .removeClass('fa-folder').addClass('fa-folder-open');
            });
            tree.on('close_node.jstree', function (event, data) {
                if (data.instance.is_leaf(data.node)) {
                    return;
                }
                jQuery('#' + data.node.id).find('i.jstree-icon.jstree-themeicon').first()
                    .removeClass('fa-folder-open').addClass('fa-folder');
            });*/»

            // Drag n drop
            tree.on('move_node.jstree', «vendorAndName»TreeDropNode);
            // Copy is fired when moving between multiple trees
            tree.on('copy_node.jstree', «vendorAndName»TreeDropNode);

            // Expand and collapse
            jQuery('#' + idPrefix + 'Expand').click(function (event) {
                var theIdPrefix;

                event.preventDefault();
                theIdPrefix = jQuery(this).attr('id').replace('Expand', '');
                trees[theIdPrefix].jstree(true).open_all(null, 500);
            });
            jQuery('#' + idPrefix + 'Collapse').click(function (event) {
                var theIdPrefix;

                event.preventDefault();
                theIdPrefix = jQuery(this).attr('id').replace('Collapse', '');
                trees[theIdPrefix].jstree(true).close_all(null, 500);
            });

            // Search
            var searchStartDelay = false;
            jQuery('#' + idPrefix + 'SearchTerm').keyup(function () {
                var theIdPrefix;

                theIdPrefix = jQuery(this).attr('id').replace('SearchTerm', '');
                if (searchStartDelay) {
                    clearTimeout(searchStartDelay);
                }
                searchStartDelay = setTimeout(function () {
                    var searchTerm;

                    searchTerm = jQuery('#' + theIdPrefix + 'SearchTerm').val();
                    trees[theIdPrefix].jstree(true).search(searchTerm);
                }, 250);
            });

            // allow redirecting if a link has been clicked
            tree.find('ul').on('click', 'li.jstree-node a', function (event) {
                var theIdPrefix;

                theIdPrefix = jQuery(this).parents('div.tree-container').attr('id');
                trees[theIdPrefix].jstree('save_state');
                document.location.href = jQuery(this).attr('href');
            });
        }
    '''

    def private treeContextMenuActions(Application it) '''
        /**
         * Initialise context menu actions for a given tree node.
         */
        function «vendorAndName»TreeContextMenuActions(theNode) {
            «initTreeNodesImpl»
        }
    '''

    def private initTreeNodesImpl(Application it) '''
        var rootId;
        var currentNode;
        var currentNodeDom;
        var isRoot;

        rootId = theNode.id.split('_')[0].replace('tree', '').replace('node', '');
        currentNode = trees[objectType + 'Tree' + rootId].jstree('get_node', theNode, false);
        currentNodeDom = trees[objectType + 'Tree' + rootId].jstree('get_node', theNode, true);
        isRoot = (currentNode.id === 'tree' + rootId + 'node_' + rootId);
        nodeEntityId = currentNode.id.replace('tree' + rootId + 'node_', '');

        var actions = {};

        var hasItemActions = jQuery('#itemActions' + nodeEntityId + ' ul li a').length > 0;
        jQuery('#itemActions' + nodeEntityId + ' ul li a').each(function (index) {
            var link;

            link = jQuery(this);
            actions['itemAction' + (index + 1)] = {
                label: link.text().trim(),
                title: link.attr('title'),
                action: function (node) {
                    document.location.href = link.attr('href');
                },
                icon: link.parent().attr('icon') + ' fa-fw'
            };
        });
        if (!hasItemActions) {
            var nodeEntityRouteArgs = {};
            jQuery.each(routeArgNames, function (index, value) {
                nodeEntityRouteArgs[value] = currentNodeDom.data(value);
            });
            if (true === hasDetailAction) {
                actions.detail = {
                    label: Translator.trans('Detail'),
                    title: Translator.trans('Show detail page'),
                    action: function (node) {
                        document.location.href = Routing.generate('«appName.formatForDB»_' + objectType.toLowerCase() + '_detail', nodeEntityRouteArgs, true);
                    },
                    icon: 'fas fa-fw fa-eye'
                };
            }
            if (true === hasEditAction) {
                actions.edit = {
                    label: Translator.trans('Edit'),
                    title: Translator.trans('Show edit form'),
                    action: function (node) {
                        document.location.href = Routing.generate('«appName.formatForDB»_' + objectType.toLowerCase() + '_edit', nodeEntityRouteArgs, true);
                    },
                    icon: 'fas fa-fw fa-edit'
                };
            }
            actions.addChildNode = {
                label: Translator.trans('Add child node'),
                title: Translator.trans('Add child node'),
                action: function (node) {
                    «vendorAndName»PerformTreeOperation(objectType, rootId, 'addChildNode');
                },
                icon: 'fas fa-fw fa-plus'
            };
            actions.deleteNode = {
                label: Translator.trans('Delete'),
                title: Translator.trans('Delete this node'),
                action: function (node) {
                    var confirmQuestion;
                    var amountOfChildren;

                    confirmQuestion = Translator.trans('Do you really want to remove this node?');
                    amountOfChildren = currentNode.children.length;
                    if (amountOfChildren > 0) {
                        confirmQuestion = Translator.trans('Do you really want to remove this node including all child nodes?');
                    }
                    if (false !== window.confirm(confirmQuestion)) {
                        «vendorAndName»PerformTreeOperation(objectType, rootId, 'deleteNode');
                    }
                },
                icon: 'fas fa-fw fa-trash-alt'
            };
        }

        if (isRoot) {
            return actions;
        }

        if (currentNodeDom.is(':first-child') && currentNodeDom.is(':last-child')) {
            return actions;
        }

        if (!currentNodeDom.is(':first-child')) {
            // has previous sibling
            actions.moveTop = {
                label: Translator.trans('Move to top'),
                title: Translator.trans('Move to top position'),
                action: function (node) {
                    «vendorAndName»PerformTreeOperation(objectType, rootId, 'moveNodeTop');
                },
                icon: 'fas fa-fw fa-angle-double-up',
                separator_before: true
            };
            actions.moveUp = {
                label: Translator.trans('Move up'),
                title: Translator.trans('Move one position up'),
                action: function (node) {
                    «vendorAndName»PerformTreeOperation(objectType, rootId, 'moveNodeUp');
                },
                icon: 'fas fa-fw fa-angle-up'
            };
        }
        if (!currentNodeDom.is(':last-child')) {
            // has next sibling
            actions.moveDown = {
                label: Translator.trans('Move down'),
                title: Translator.trans('Move one position down'),
                action: function (node) {
                    «vendorAndName»PerformTreeOperation(objectType, rootId, 'moveNodeDown');
                },
                icon: 'fas fa-fw fa-angle-down',
                separator_before: currentNodeDom.is(':first-child')
            };
            actions.moveBottom = {
                label: Translator.trans('Move to bottom'),
                title: Translator.trans('Move to bottom position'),
                action: function (node) {
                    «vendorAndName»PerformTreeOperation(objectType, rootId, 'moveNodeBottom');
                },
                icon: 'fas fa-fw fa-angle-double-down'
            };
        }

        return actions;
    '''

    def private performTreeOperation(Application it) '''
        /**
         * Helper function to start several different ajax actions
         * performing tree related amendments and operations.
         */
        function «vendorAndName»PerformTreeOperation(objectType, rootId, op) {
            var opParam, params;

            opParam = ((op === 'moveNodeTop' || op === 'moveNodeUp' || op === 'moveNodeDown' || op === 'moveNodeBottom') ? 'moveNode' : op);
            params = {
                ot: objectType,
                op: opParam
            };

            if (op !== 'addRootNode') {
                if (!nodeEntityId) {
                    «vendorAndName»SimpleAlert(jQuery('.tree-container'), Translator.trans('Error'), Translator.trans('Invalid node id'), 'treeInvalidNodeAlert', 'danger');
                    return;
                }
                params['root'] = rootId;
                params[op === 'addChildNode' ? 'pid' : 'id'] = nodeEntityId;

                if (op === 'moveNodeTop') {
                    params['direction'] = 'top';
                } else if (op === 'moveNodeUp') {
                    params['direction'] = 'up';
                } else if (op === 'moveNodeDown') {
                    params['direction'] = 'down';
                } else if (op === 'moveNodeBottom') {
                    params['direction'] = 'bottom';
                }
            }

            jQuery.ajax({
                method: 'POST',
                url: Routing.generate('«appName.formatForDB»_ajax_handletreeoperation'),
                data: params
            }).done(function (data) {
                if (data.result == 'success') {
                    /*«vendorAndName»SimpleAlert(jQuery('.tree-container'), Translator.trans('Success'), data.message, 'treeAjaxDoneAlert', 'success');*/

                    if (typeof data.returnUrl !== 'undefined') {
                        window.location = data.returnUrl;
                    } else {
                        window.location.reload();
                    }
                } else {
                    «vendorAndName»SimpleAlert(jQuery('.tree-container'), Translator.trans('Error'), data.message !== '' ? data.message : Translator.trans('Could not persist your change.'), 'treeAjaxFailedAlert', 'danger');
                }
            }).fail(function (jqXHR, textStatus) {
                «vendorAndName»SimpleAlert(jQuery('.tree-container'), Translator.trans('Error'), Translator.trans('Could not persist your change.'), 'treeAjaxFailedAlert', 'danger');
            });
        }
    '''

    def private treeDropNode(Application it) '''
        /**
         * Handles drag n drop events.
         *
         * @see https://www.jstree.com/api/#/?f=move_node(obj,%20par%20[,%20pos,%20callback,%20is_loaded])
         * @see https://www.jstree.com/api/#/?f=copy_node(obj,%20par%20[,%20pos,%20callback,%20is_loaded])
         */
        function «vendorAndName»TreeDropNode(event, data) {
            var isMultiTreeCopy;
            var node;
            var parentNode;
            var previousNode;
            var nextNode;

            isMultiTreeCopy = 'undefined' !== typeof data.original;
            // when copying between multiple trees refer to original node to get real identifier
            node = isMultiTreeCopy ? data.original : data.node;
            // do not allow inserts on root level
            if (node.parents.length < 1) {
                return false;
            }

            rootId = node.id.split('_')[0].replace('tree', '').replace('node', '');
            parentNode = data.new_instance.get_node(data.parent, false);

            previousNode = null;
            nextNode = null;
            if (data.position > 0) {
                previousNode = data.new_instance.get_node(parentNode.children[data.position - 1], false);
            } else if (data.position < parentNode.children.length - 1)  {
                nextNode = data.new_instance.get_node(parentNode.children[data.position + 1], false);
            }

            if (null !== previousNode) {
                «vendorAndName»TreeMoveNode(node, previousNode, 'after', isMultiTreeCopy);
            } else if (null !== nextNode) {
                «vendorAndName»TreeMoveNode(node, nextNode, 'before', isMultiTreeCopy);
            } else {
                «vendorAndName»TreeMoveNode(node, parentNode, 'bottom', isMultiTreeCopy);
            }
        }
    '''

    def private treeMoveNode(Application it) '''
        /**
         * Callback function for drag n drop. This function is called after each tree change
         * caused by moving a node.
         *
         * @param node - the node which has been moved
         * @param refNode - the new reference node
         * @param position - can be "after", "before" or "bottom" and defines
         *       whether the affected node is inserted after, before or as last child of "refNode"
         * @param doReload - whether to reload the page after the change has been performed
         *       (required for multi-tree copying to update identifiers)
         *
         * @return true on success, otherwise the change will be reverted
         */
        function «vendorAndName»TreeMoveNode(node, refNode, position, doReload) {
            var nodeParts;
            var rootId;
            var nodeId;
            var destId;

            nodeParts = node.id.split('node_');
            rootId = nodeParts[0].replace('tree', '');
            nodeId = nodeParts[1];

            nodeParts = refNode.id.split('node_');
            rootId = nodeParts[0].replace('tree', '');
            destId = nodeParts[1];

            jQuery.ajax({
                method: 'POST',
                url: Routing.generate('«appName.formatForDB»_ajax_handletreeoperation'),
                data: {
                    op: 'moveNodeTo',
                    direction: position,
                    root: rootId,
                    id: nodeId,
                    destid: destId
                }
            }).done(function (data) {
                if (true === doReload) {
                    window.location.reload();
                }

                return true;
            }).fail(function (jqXHR, textStatus) {
                «vendorAndName»SimpleAlert(jQuery('.tree-container'), Translator.trans('Error'), Translator.trans('Could not persist your change.'), 'treeAjaxFailedAlert', 'danger');

                window.location.reload();

                return false;
            });

            return true;
        }
    '''

    def private onLoad(Application it) '''
        jQuery(document).ready(function () {
            if (jQuery('#treeAddRoot').length > 0) {
                jQuery('#treeAddRoot').click(function (event) {
                    event.preventDefault();
                    «vendorAndName»PerformTreeOperation(jQuery(this).data('object-type'), 1, 'addRootNode');
                }).removeClass('d-none');
            }

            trees = [];
            if (jQuery('.tree-container').length > 0) {
                jQuery('.tree-container').each(function (index) {
                    «vendorAndName»InitTree(jQuery(this).first());
                });
            }
        });
    '''
}
