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
        println('Generating javascript for finder component')
        fsa.generateFile(getAppSourcePath(appName) + 'javascript/' + appName + '_finder.js', generate)
    }

    def private generate(Application it) '''
        'use strict';

        var current«appName»Editor = null;
        var current«appName»Input = null;

        /**
         * Returns the attributes used for the popup window. 
         * @return {String}
         */
        function getPopupAttributes() {
            var pWidth, pHeight;

            pWidth = screen.width * 0.75;
            pHeight = screen.height * 0.66;
            return 'width=' + pWidth + ',height=' + pHeight + ',scrollbars,resizable';
        }

        /**
         * Open a popup window with the finder triggered by a Xinha button.
         */
        function «appName»FinderXinha(editor, «prefix()»URL) {
        	var popupAttributes;

            // Save editor for access in selector window
            current«appName»Editor = editor;

            popupAttributes = getPopupAttributes();
            window.open(«prefix()»URL, '', popupAttributes);
        }



        var «name.formatForDB» = {};

        «name.formatForDB».finder = {};

        «name.formatForDB».finder.onLoad = function (baseId, selectedId) {
            $('«appName»_sort').observe('change', «name.formatForDB».finder.onParamChanged);
            $('«appName»_sortdir').observe('change', «name.formatForDB».finder.onParamChanged);
            $('«appName»_pagesize').observe('change', «name.formatForDB».finder.onParamChanged);
            $('«appName»_gosearch').observe('click', «name.formatForDB».finder.onParamChanged)
                                   .observe('keypress', «name.formatForDB».finder.onParamChanged);
            $('«appName»_submit').hide();
            $('«appName»_cancel').observe('click', «name.formatForDB».finder.handleCancel);
        };

        «name.formatForDB».finder.onParamChanged = function () {
            $('selectorForm').submit();
        };

        «name.formatForDB».finder.handleCancel = function () {
            var editor, w;

            editor = $F('editorName');
            if (editor === 'xinha') {
                w = parent.window;
                window.close();
                w.focus();
            } else if (editor === 'tinymce') {
                tinyMCEPopup.close();
                //«prefix()»ClosePopup();
            } else if (editor === 'ckeditor') {
                /** to be done*/
            } else {
                alert('Close Editor: ' + editor);
            }
        };


        function getPasteSnippet(mode, itemId) {
            var itemUrl, itemTitle, itemDescription, pasteMode;

            itemUrl = $F('url' + itemId);
            itemTitle = $F('title' + itemId);
            itemDescription = $F('desc' + itemId);

            pasteMode = $F('«appName»_pasteas');

            if (pasteMode === '2' || pasteMode !== '1') {
                return itemId;
            }

            // return link to item
            if (mode === 'url') {
                // plugin mode
                return itemUrl;
            } else {
                // editor mode
                return '<a href="' + itemUrl + '" title="' + itemDescription + '">' + itemTitle + '</a>';
            }
        }


        // User clicks on "select item" button
        «name.formatForDB».finder.selectItem = function (itemId) {
            var editor, html;

            editor = $F('editorName');
            if (editor === 'xinha') {
                if (window.opener.current«appName»Editor !== null) {
                    html = getPasteSnippet('html', itemId);

                    window.opener.current«appName»Editor.focusEditor();
                    window.opener.current«appName»Editor.insertHTML(html);
                } else {
                    html = getPasteSnippet('url', itemId);
                    var currentInput = window.opener.current«appName»Input;

                    if (currentInput.tagName === 'INPUT') {
                        // Simply overwrite value of input elements
                        currentInput.value = html;
                    } else if (currentInput.tagName === 'TEXTAREA') {
                        // Try to paste into textarea - technique depends on environment
                        if (typeof document.selection !== 'undefined') {
                            // IE: Move focus to textarea (which fortunately keeps its current selection) and overwrite selection
                            currentInput.focus();
                            window.opener.document.selection.createRange().text = html;
                        } else if (typeof currentInput.selectionStart !== 'undefined') {
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
            } else if (editor === 'tinymce') {
                html = getPasteSnippet('html', itemId);
                tinyMCEPopup.editor.execCommand('mceInsertContent', false, html);
                tinyMCEPopup.close();
                return;
            } else if (editor === 'ckeditor') {
                /** to be done*/
            } else {
                alert('Insert into Editor: ' + editor);
            }
            «prefix()»ClosePopup();
        };


        function «prefix()»ClosePopup() {
            window.opener.focus();
            window.close();
        }




        //=============================================================================
        // «appName» item selector for Forms
        //=============================================================================

        «name.formatForDB».itemSelector = {};
        «name.formatForDB».itemSelector.items = {};
        «name.formatForDB».itemSelector.baseId = 0;
        «name.formatForDB».itemSelector.selectedId = 0;

        «name.formatForDB».itemSelector.onLoad = function (baseId, selectedId) {
            «name.formatForDB».itemSelector.baseId = baseId;
            «name.formatForDB».itemSelector.selectedId = selectedId;

            // required as a changed object type requires a new instance of the item selector plugin
            $(baseId + '_objecttype').observe('change', «name.formatForDB».itemSelector.onParamChanged);

            if ($(baseId + '_catid') !== undefined) {
                $(baseId + '_catid').observe('change', «name.formatForDB».itemSelector.onParamChanged);
            }
            $(baseId + '_id').observe('change', «name.formatForDB».itemSelector.onItemChanged);
            $(baseId + '_sort').observe('change', «name.formatForDB».itemSelector.onParamChanged);
            $(baseId + '_sortdir').observe('change', «name.formatForDB».itemSelector.onParamChanged);
            $('«appName»_gosearch').observe('click', «name.formatForDB».itemSelector.onParamChanged)
                                   .observe('keypress', «name.formatForDB».itemSelector.onParamChanged);

            «name.formatForDB».itemSelector.getItemList();
        };

        «name.formatForDB».itemSelector.onParamChanged = function () {
            $('ajax_indicator').show();

            «name.formatForDB».itemSelector.getItemList();
        };

        «name.formatForDB».itemSelector.getItemList = function () {
            var baseId, pars, request;

            baseId = «name.formatForDB».itemSelector.baseId;
            pars = 'objectType=' + baseId + '&';
            if ($(baseId + '_catid') !== undefined) {
                pars += 'catid=' + $F(baseId + '_catid') + '&';
            }
            pars += 'sort=' + $F(baseId + '_sort') + '&' +
                    'sortdir=' + $F(baseId + '_sortdir') + '&' +
                    'searchterm=' + $F(baseId + '_searchterm');

            request = new Zikula.Ajax.Request('ajax.php?module=«appName»&func=getItemListFinder', {
                method: 'post',
                parameters: pars,
                onFailure: function(req) {
                    Zikula.showajaxerror(req.getMessage());
                },
                onSuccess: function(req) {
                    var baseId;
                    baseId = «name.formatForDB».itemSelector.baseId;
                    «name.formatForDB».itemSelector.items[baseId] = req.getData();
                    $('ajax_indicator').hide();
                    «name.formatForDB».itemSelector.updateItemDropdownEntries();
                    «name.formatForDB».itemSelector.updatePreview();
                }
            });
        };

        «name.formatForDB».itemSelector.updateItemDropdownEntries = function () {
            var baseId, itemSelector, items, i, item;

            baseId = «name.formatForDB».itemSelector.baseId;
            itemSelector = $(baseId + '_id');
            itemSelector.length = 0;

            items = «name.formatForDB».itemSelector.items[baseId];
            for (i = 0; i < items.length; ++i) {
                item = items[i];
                itemSelector.options[i] = new Option(item.title, item.id, false);
            }

            if («name.formatForDB».itemSelector.selectedId > 0) {
                $(baseId + '_id').value = «name.formatForDB».itemSelector.selectedId;
            }
        };

        «name.formatForDB».itemSelector.updatePreview = function () {
            var baseId, items, selectedElement, i;

            baseId = «name.formatForDB».itemSelector.baseId;
            items = «name.formatForDB».itemSelector.items[baseId];

            $(baseId + '_previewcontainer').hide();

            if (items.length === 0) {
                return;
            }

            selectedElement = items[0];
            if («name.formatForDB».itemSelector.selectedId > 0) {
                for (var i = 0; i < items.length; ++i) {
                    if (items[i].id === «name.formatForDB».itemSelector.selectedId) {
                        selectedElement = items[i];
                        break;
                    }
                }
            }

            if (selectedElement !== null) {
                $(baseId + '_previewcontainer').update(window.atob(selectedElement.previewInfo))
                                               .show();
            }
        };

        «name.formatForDB».itemSelector.onItemChanged = function () {
            var baseId, itemSelector, preview;

            baseId = «name.formatForDB».itemSelector.baseId;
            itemSelector = $(baseId + '_id');
            preview = window.atob(«name.formatForDB».itemSelector.items[baseId][itemSelector.selectedIndex].previewInfo);

            $(baseId + '_previewcontainer').update(preview);
            «name.formatForDB».itemSelector.selectedId = $F(baseId + '_id');
        };
    '''
}
