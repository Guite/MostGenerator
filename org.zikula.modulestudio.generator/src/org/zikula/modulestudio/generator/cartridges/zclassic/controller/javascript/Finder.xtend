package org.zikula.modulestudio.generator.cartridges.zclassic.controller.javascript

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Finder {
    @Inject extension FormattingExtensions = new FormattingExtensions()
    @Inject extension NamingExtensions = new NamingExtensions()
    @Inject extension Utils = new Utils()

    /**
     * Entry point for the javascript file with validation functionality.
     */
    def generate(Application it, IFileSystemAccess fsa) {
        fsa.generateFile(getAppSourcePath(appName) + 'javascript/' + appName + '_finder.js', generate)
    }

    def private generate(Application it) '''

        /**
         * Open a popup window with the finder triggered by a Xinha button.
         */
        function «appName»FinderXinha(editor, «prefix()»URL)
        {
            // Save editor for access in selector window
            current«appName»Editor = editor;

            window.open(«prefix()»URL, '', getPopupAttributes());
        }

        function getPopupAttributes()
        {
            var pWidth = screen.width * 0.75;
            var pHeight = screen.height * 0.66;
            return 'width=' + pWidth + ',height=' + pHeight + ',scrollbars,resizable';
        }


        //=============================================================================
        // Internal stuff
        //=============================================================================

        // htmlArea 3.0 editor for access in selector window
        var current«appName»Editor = null;
        var current«appName»Input = null;

        var «name.formatForDB» = {}

        «name.formatForDB».finder = {}

        «name.formatForDB».finder.onLoad = function(baseID, selectedId) {
            $('«appName»_sort').observe('change', «name.formatForDB».finder.onParamChanged);
            $('«appName»_sortdir').observe('change', «name.formatForDB».finder.onParamChanged);
            $('«appName»_pagesize').observe('change', «name.formatForDB».finder.onParamChanged);
            $('«appName»_gosearch').observe('click', «name.formatForDB».finder.onParamChanged)
                                   .observe('keypress', «name.formatForDB».finder.onParamChanged);
            $('«appName»_submit').hide();
            $('«appName»_cancel').observe('click', «name.formatForDB».finder.handleCancel);
        }

        «name.formatForDB».finder.onParamChanged = function() {
            $('selectorForm').submit();
        }

        «name.formatForDB».finder.handleCancel = function() {
            var editor = $F('editorName');
            if (editor == 'xinha') {
                var w = parent.window;
                window.close();
                w.focus();
            } else if (editor == 'tinymce') {
                tinyMCEPopup.close();
                //«prefix()»ClosePopup();
            } else if (editor == 'ckeditor') {
                /** to be done*/
            } else {
                alert('Close Editor: ' + editor);
            }
        }


        function getPasteSnippet(mode, itemId) {
            var itemUrl = $F('url' + itemId);
            var itemTitle = $F('title' + itemId);
            var itemDescription = $F('desc' + itemId);

            var pasteMode = $F('«appName»_pasteas');

            if (pasteMode == 2 || pasteMode != 1) {
                return itemId;
            }

            // return link to item
            if (mode == 'url') {
                // plugin mode
                return itemUrl;
            } else {
                // editor mode
                return '<a href="' + itemUrl + '" title="' + itemDescription + '">' + itemTitle + '</a>';
            }
        }


        // User clicks on "select item" button
        «name.formatForDB».finder.selectItem = function(itemId) {
            var editor = $F('editorName');
            if (editor == 'xinha') {
                if (window.opener.currentSimpleMediaEditor != null) {
                    var html = getPasteSnippet('html', itemId);

                    window.opener.current«appName»Editor.focusEditor();
                    window.opener.current«appName»Editor.insertHTML(html);
                } else {
                    var html = getPasteSnippet('url', itemId);
                    var currentInput = window.opener.current«appName»Input;

                    if (currentInput.tagName == 'INPUT') {
                        // Simply overwrite value of input elements
                        currentInput.value = html;
                    } else if (currentInput.tagName == 'TEXTAREA') {
                        // Try to paste into textarea - technique depends on environment
                        if (typeof document.selection != 'undefined') {
                            // IE: Move focus to textarea (which fortunately keeps its current selection) and overwrite selection
                            currentInput.focus();
                            window.opener.document.selection.createRange().text = html;
                        } else if (typeof currentInput.selectionStart != 'undefined') {
                            // Firefox: Get start and end points of selection and create new value based on old value
                            var startPos = currentInput.selectionStart;
                            var endPos = currentInput.selectionEnd;
                            currentInput.value = currentInput.value.substring(0, startPos)
                                                + html
                                                + currentInput.value.substring(endPos, currentInput.value.length);
                        } else {
                            // Others: just append to the current value
                            currentInput.value += html;
                        }
                    }
                }
            } else if (editor == 'tinymce') {
                var html = getPasteSnippet('html', itemId);
                tinyMCEPopup.editor.execCommand('mceInsertContent', false, html);
                tinyMCEPopup.close();
                return;
            } else if (editor == 'ckeditor') {
                /** to be done*/
            } else {
                alert('Insert into Editor: ' + editor);
            }
            «prefix()»ClosePopup();
        }


        function «prefix()»ClosePopup() {
            window.opener.focus();
            window.close();
        }




        //=============================================================================
        // «appName» item selector for Forms
        //=============================================================================

        «name.formatForDB».itemSelector = {};
        «name.formatForDB».itemSelector.items = {};
        «name.formatForDB».itemSelector.baseID = 0;
        «name.formatForDB».itemSelector.selectedId = 0;

        «name.formatForDB».itemSelector.onLoad = function(baseID, selectedId) {
            «name.formatForDB».itemSelector.baseID = baseID;
            «name.formatForDB».itemSelector.selectedId = selectedId;

            // required as a changed object type requires a new instance of the item selector plugin
            $(baseID + '_objecttype').observe('change', «name.formatForDB».itemSelector.onParamChanged);

            if ($(baseID + '_catid') != undefined) {
                $(baseID + '_catid').observe('change', «name.formatForDB».itemSelector.onParamChanged);
            }
            $(baseID + '_id').observe('change', «name.formatForDB».itemSelector.onItemChanged);
            $(baseID + '_sort').observe('change', «name.formatForDB».itemSelector.onParamChanged);
            $(baseID + '_sortdir').observe('change', «name.formatForDB».itemSelector.onParamChanged);
            $('«appName»_gosearch').observe('click', «name.formatForDB».itemSelector.onParamChanged)
                                   .observe('keypress', «name.formatForDB».itemSelector.onParamChanged)

            «name.formatForDB».itemSelector.getItemList();
        }

        «name.formatForDB».itemSelector.onParamChanged = function() {
            var baseID = «name.formatForDB».itemSelector.baseID;
            $('ajax_indicator').show();

            «name.formatForDB».itemSelector.getItemList();
        }

        «name.formatForDB».itemSelector.getItemList = function() {
            var baseID = «name.formatForDB».itemSelector.baseID;
            var pars = 'objectType=' + baseID + '&';
            if ($(baseID + '_catid') != undefined) {
                pars += 'catid=' + $F(baseID + '_catid') + '&';
            }
            pars += 'sort=' + $F(baseID + '_sort') + '&' +
                    'sortdir=' + $F(baseID + '_sortdir') + '&' +
                    'searchterm=' + $F(baseID + '_searchterm');

            new Zikula.Ajax.Request('ajax.php?module=«appName»&func=getItemListFinder', {
                method: 'post',
                parameters: pars,
                onFailure: function(req) {
                    Zikula.showajaxerror(req.getMessage());
                    return;
                },
                onSuccess: function(req) {
                    var baseID = «name.formatForDB».itemSelector.baseID;
                    «name.formatForDB».itemSelector.items[baseID] = req.getData();
                    $('ajax_indicator').hide();
                    «name.formatForDB».itemSelector.updateItemDropdownEntries();
                    «name.formatForDB».itemSelector.updatePreview();
                }
            });
        }

        «name.formatForDB».itemSelector.updateItemDropdownEntries = function() {
            var baseID = «name.formatForDB».itemSelector.baseID;
            var itemSelector = $(baseID + '_id');

            itemSelector.length = 0;

            var items = «name.formatForDB».itemSelector.items[baseID];
            for (i = 0; i < items.length; ++i) {
                var item = items[i];
                itemSelector.options[i] = new Option(item.title, item.id, false);
            }

            if («name.formatForDB».itemSelector.selectedId > 0) {
                $(baseID + '_id').value = «name.formatForDB».itemSelector.selectedId;
            }
        }

        «name.formatForDB».itemSelector.updatePreview = function() {
            var baseID = «name.formatForDB».itemSelector.baseID;
            var items = «name.formatForDB».itemSelector.items[baseID];

            $(baseID + '_previewcontainer').hide();

            if (items.length == 0) {
                return;
            }

            var selectedElement = items[0];
            if («name.formatForDB».itemSelector.selectedId > 0) {
                for (i = 0; i < items.length; ++i) {
                    if (items[i].id == «name.formatForDB».itemSelector.selectedId) {
                        selectedElement = items[i];
                        break;
                    }
                }
            }

            if (selectedElement !== null) {
                $(baseID + '_previewcontainer').update(window.atob(selectedElement.previewInfo))
                                               .show();
            }
        }

        «name.formatForDB».itemSelector.onItemChanged = function() {
            var baseID = «name.formatForDB».itemSelector.baseID;
            var itemSelector = $(baseID + '_id');
            var preview = window.atob(«name.formatForDB».itemSelector.items[baseID][itemSelector.selectedIndex].previewInfo);
            $(baseID + '_previewcontainer').update(preview);
            «name.formatForDB».itemSelector.selectedId = $F(baseID + '_id');
        }
    '''
}
