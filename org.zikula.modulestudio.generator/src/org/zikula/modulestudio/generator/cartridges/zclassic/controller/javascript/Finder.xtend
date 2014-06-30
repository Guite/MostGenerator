package org.zikula.modulestudio.generator.cartridges.zclassic.controller.javascript

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Finder {
    @Inject extension FormattingExtensions = new FormattingExtensions
    @Inject extension NamingExtensions = new NamingExtensions
    @Inject extension Utils = new Utils

    /**
     * Entry point for the JavaScript file with finder functionality.
     */
    def generate(Application it, IFileSystemAccess fsa) {
        var fileName = ''
        if (targets('1.3.5')) {
            fileName = appName + '_finder.js'
        } else {
            fileName = appName + '.Finder.js'
        }
        if (!shouldBeSkipped(getAppJsPath + fileName)) {
            println('Generating JavaScript for finder component')
            if (shouldBeMarked(getAppJsPath + fileName)) {
                if (targets('1.3.5')) {
                    fileName = appName + '_finder.generated.js'
                } else {
                    fileName = appName + '.Finder.generated.js'
                }
            }
            fsa.generateFile(getAppJsPath + fileName, generate)
        }
    }

    def private generate(Application it) '''
        'use strict';

        var current«appName»Editor = null;
        var current«appName»Input = null;

        /**
         * Returns the attributes used for the popup window. 
         * @return {String}
         */
        function getPopupAttributes()
        {
            var pWidth, pHeight;

            pWidth = screen.width * 0.75;
            pHeight = screen.height * 0.66;

            return 'width=' + pWidth + ',height=' + pHeight + ',scrollbars,resizable';
        }

        /**
         * Open a popup window with the finder triggered by a Xinha button.
         */
        function «appName»FinderXinha(editor, «prefix()»URL)
        {
            var popupAttributes;

            // Save editor for access in selector window
            current«appName»Editor = editor;

            popupAttributes = getPopupAttributes();
            window.open(«prefix()»URL, '', popupAttributes);
        }

        /**
         * Open a popup window with the finder triggered by a CKEditor button.
         */
        function «appName»FinderCKEditor(editor, «prefix()»URL)
        {
            // Save editor for access in selector window
            current«appName»Editor = editor;

            editor.popup(
                «IF targets('1.3.5')»
                    Zikula.Config.baseURL + Zikula.Config.entrypoint + '?module=«appName»&type=external&func=finder&editor=ckeditor',
                «ELSE»
                    Routing.generate('«appName.formatForDB»_external_finder', { editor: 'ckeditor' }),
                «ENDIF»
                /*width*/ '80%', /*height*/ '70%',
                'location=no,menubar=no,toolbar=no,dependent=yes,minimizable=no,modal=yes,alwaysRaised=yes,resizable=yes,scrollbars=yes'
            );
        }



        var «name.formatForDB» = {};

        «name.formatForDB».finder = {};

        «name.formatForDB».finder.onLoad = function (baseId, selectedId)
        {
            «IF targets('1.3.5')»
                $$('div.categoryselector select').invoke('observe', 'change', «name.formatForDB».finder.onParamChanged);
                $('«appName.toFirstLower»Sort').observe('change', «name.formatForDB».finder.onParamChanged);
                $('«appName.toFirstLower»SortDir').observe('change', «name.formatForDB».finder.onParamChanged);
                $('«appName.toFirstLower»PageSize').observe('change', «name.formatForDB».finder.onParamChanged);
                $('«appName.toFirstLower»SearchGo').observe('click', «name.formatForDB».finder.onParamChanged);
                $('«appName.toFirstLower»SearchGo').observe('keypress', «name.formatForDB».finder.onParamChanged);
                $('«appName.toFirstLower»Submit').addClassName('z-hide');
                $('«appName.toFirstLower»Cancel').observe('click', «name.formatForDB».finder.handleCancel);
            «ELSE»
                $('div.categoryselector select').change(«name.formatForDB».finder.onParamChanged);
                $('#«appName.toFirstLower»Sort').change(«name.formatForDB».finder.onParamChanged);
                $('#«appName.toFirstLower»SortDir').change(«name.formatForDB».finder.onParamChanged);
                $('#«appName.toFirstLower»PageSize').change(«name.formatForDB».finder.onParamChanged);
                $('#«appName.toFirstLower»SearchGo').click(«name.formatForDB».finder.onParamChanged);
                $('#«appName.toFirstLower»SearchGo').keypress(«name.formatForDB».finder.onParamChanged);
                $('#«appName.toFirstLower»Submit').addClass('hidden');
                $('#«appName.toFirstLower»Cancel').click(«name.formatForDB».finder.handleCancel);
            «ENDIF»
        };

        «name.formatForDB».finder.onParamChanged = function ()
        {
            $('«IF !targets('1.3.5')»#«ENDIF»«appName.toFirstLower»SelectorForm').submit();
        };

        «name.formatForDB».finder.handleCancel = function ()
        {
            var editor, w;

            «IF targets('1.3.5')»
                editor = $F('editorName');
            «ELSE»
                editor = $('#editorName').val();
            «ENDIF»
            if (editor === 'xinha') {
                w = parent.window;
                window.close();
                w.focus();
            } else if (editor === 'tinymce') {
                «prefix()»ClosePopup();
            } else if (editor === 'ckeditor') {
                «prefix()»ClosePopup();
            } else {
                alert('Close Editor: ' + editor);
            }
        };


        function getPasteSnippet(mode, itemId)
        {
            var itemUrl, itemTitle, itemDescription, pasteMode;

            «IF targets('1.3.5')»
                itemUrl = $F('url' + itemId);
                itemTitle = $F('title' + itemId);
                itemDescription = $F('desc' + itemId);
                pasteMode = $F('«appName.toFirstLower»PasteAs');
            «ELSE»
                itemUrl = $('#url' + itemId).val();
                itemTitle = $('#title' + itemId).val();
                itemDescription = $('#desc' + itemId).val();
                pasteMode = $('#«appName.toFirstLower»PasteAs').val();
            «ENDIF»

            if (pasteMode === '2' || pasteMode !== '1') {
                return itemId;
            }

            // return link to item
            if (mode === 'url') {
                // plugin mode
                return itemUrl;
            }

            // editor mode
            return '<a href="' + itemUrl + '" title="' + itemDescription + '">' + itemTitle + '</a>';
        }


        // User clicks on "select item" button
        «name.formatForDB».finder.selectItem = function (itemId)
        {
            var editor, html;

            «IF targets('1.3.5')»
                editor = $F('editorName');
            «ELSE»
                editor = $('#editorName').val();
            «ENDIF»
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
                window.opener.tinyMCE.activeEditor.execCommand('mceInsertContent', false, html);
                // other tinymce commands: mceImage, mceInsertLink, mceReplaceContent, see http://www.tinymce.com/wiki.php/Command_identifiers
            } else if (editor === 'ckeditor') {
                if (window.opener.current«appName»Editor !== null) {
                    html = getPasteSnippet('html', itemId);

                    window.opener.current«appName»Editor.insertHtml(html);
                }
            } else {
                alert('Insert into Editor: ' + editor);
            }
            «prefix()»ClosePopup();
        };


        function «prefix()»ClosePopup()
        {
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

        «name.formatForDB».itemSelector.onLoad = function (baseId, selectedId)
        {
            «name.formatForDB».itemSelector.baseId = baseId;
            «name.formatForDB».itemSelector.selectedId = selectedId;

            // required as a changed object type requires a new instance of the item selector plugin
            «IF targets('1.3.5')»
                $('«appName.toFirstLower»ObjectType').observe('change', «name.formatForDB».itemSelector.onParamChanged);

                if ($(baseId + '_catidMain') != undefined) {
                    $(baseId + '_catidMain').observe('change', «name.formatForDB».itemSelector.onParamChanged);
                } else if ($(baseId + '_catidsMain') != undefined) {
                    $(baseId + '_catidsMain').observe('change', «name.formatForDB».itemSelector.onParamChanged);
                }
                $(baseId + 'Id').observe('change', «name.formatForDB».itemSelector.onItemChanged);
                $(baseId + 'Sort').observe('change', «name.formatForDB».itemSelector.onParamChanged);
                $(baseId + 'SortDir').observe('change', «name.formatForDB».itemSelector.onParamChanged);
                $('«appName.toFirstLower»SearchGo').observe('click', «name.formatForDB».itemSelector.onParamChanged);
                $('«appName.toFirstLower»SearchGo').observe('keypress', «name.formatForDB».itemSelector.onParamChanged);
            «ELSE»
                $('#«appName.toFirstLower»ObjectType').change(«name.formatForDB».itemSelector.onParamChanged);

                if ($('#' + baseId + '_catidMain').size() > 0) {
                    $('#' + baseId + '_catidMain').change(«name.formatForDB».itemSelector.onParamChanged);
                } else if ($('#' + baseId + '_catidsMain').size() > 0) {
                    $('#' + baseId + '_catidsMain').change(«name.formatForDB».itemSelector.onParamChanged);
                }
                $('#' + baseId + 'Id').change(«name.formatForDB».itemSelector.onItemChanged);
                $('#' + baseId + 'Sort').change(«name.formatForDB».itemSelector.onParamChanged);
                $('#' + baseId + 'SortDir').change(«name.formatForDB».itemSelector.onParamChanged);
                $('#«appName.toFirstLower»SearchGo').click(«name.formatForDB».itemSelector.onParamChanged);
                $('#«appName.toFirstLower»SearchGo').keypress(«name.formatForDB».itemSelector.onParamChanged);
            «ENDIF»

            «name.formatForDB».itemSelector.getItemList();
        };

        «name.formatForDB».itemSelector.onParamChanged = function ()
        {
            $('ajax_indicator').removeClass«IF targets('1.3.5')»Name«ENDIF»('«IF targets('1.3.5')»z-hide«ELSE»hidden«ENDIF»');

            «name.formatForDB».itemSelector.getItemList();
        };

        «name.formatForDB».itemSelector.getItemList = function ()
        {
            var baseId, params«IF targets('1.3.5')», request«ENDIF»;

            baseId = «name.formatForDB».itemSelector.baseId;
            params = 'ot=' + baseId + '&';
            «IF targets('1.3.5')»
                if ($(baseId + '_catidMain') != undefined) {
                    params += 'catidMain=' + $F(baseId + '_catidMain') + '&';
                } else if ($(baseId + '_catidsMain') != undefined) {
                    params += 'catidsMain=' + $F(baseId + '_catidsMain') + '&';
                }
                params += 'sort=' + $F(baseId + 'Sort') + '&' +
                          'sortdir=' + $F(baseId + 'SortDir') + '&' +
                          'searchterm=' + $F(baseId + 'SearchTerm');
            «ELSE»
                if ($('#' + baseId + '_catidMain').size() > 0) {
                    params += 'catidMain=' + $('#' + baseId + '_catidMain').val() + '&';
                } else if ($('#' + baseId + '_catidsMain').size() > 0) {
                    params += 'catidsMain=' + $('#' + baseId + '_catidsMain').val() + '&';
                }
                params += 'sort=' + $('#' + baseId + 'Sort').val() + '&' +
                          'sortdir=' + $('#' + baseId + 'SortDir').val() + '&' +
                          'searchterm=' + $('#' + baseId + 'SearchTerm').val();
            «ENDIF»

            «IF targets('1.3.5')»
                request = new Zikula.Ajax.Request(
                    Zikula.Config.baseURL + 'ajax.php?module=«appName»&func=getItemListFinder',
                    {
                        method: 'post',
                        parameters: params,
                        onFailure: function(req) {
                            Zikula.showajaxerror(req.getMessage());
                        },
                        onSuccess: function(req) {
                            var baseId;
                            baseId = «name.formatForDB».itemSelector.baseId;
                            «name.formatForDB».itemSelector.items[baseId] = req.getData();
                            $('ajax_indicator').addClassName('z-hide');
                            «name.formatForDB».itemSelector.updateItemDropdownEntries();
                            «name.formatForDB».itemSelector.updatePreview();
                        }
                    }
                );
            «ELSE»
                $.ajax({
                    type: 'POST',
                    url: Routing.generate('«appName.formatForDB»_ajax_getItemListFinder'),
                    data: params
                }).done(function(res) {
                    // get data returned by the ajax response
                    var baseId;
                    baseId = «name.formatForDB».itemSelector.baseId;
                    «name.formatForDB».itemSelector.items[baseId] = res.data;
                    $('#ajax_indicator').addClass('hidden');
                    «name.formatForDB».itemSelector.updateItemDropdownEntries();
                    «name.formatForDB».itemSelector.updatePreview();
                })«/*.fail(function(jqXHR, textStatus) {
                    // nothing to do yet
                })*/»;
            «ENDIF»
        };

        «name.formatForDB».itemSelector.updateItemDropdownEntries = function ()
        {
            var baseId, itemSelector, items, i, item;

            baseId = «name.formatForDB».itemSelector.baseId;
            itemSelector = $(«IF !targets('1.3.5')»'#' + «ENDIF»baseId + 'Id');
            itemSelector.length = 0;

            items = «name.formatForDB».itemSelector.items[baseId];
            for (i = 0; i < items.length; ++i) {
                item = items[i];
                itemSelector.options[i] = new Option(item.title, item.id, false);
            }

            if («name.formatForDB».itemSelector.selectedId > 0) {
                «IF targets('1.3.5')»
                    $(baseId + 'Id').value = «name.formatForDB».itemSelector.selectedId;
                «ELSE»
                    $('#' + baseId + 'Id').val(«name.formatForDB».itemSelector.selectedId);
                «ENDIF»
            }
        };

        «name.formatForDB».itemSelector.updatePreview = function ()
        {
            var baseId, items, selectedElement, i;

            baseId = «name.formatForDB».itemSelector.baseId;
            items = «name.formatForDB».itemSelector.items[baseId];

            «IF targets('1.3.5')»
                $(baseId + 'PreviewContainer').addClassName('z-hide');
            «ELSE»
                $('#' + baseId + 'PreviewContainer').addClass('hidden');
            «ENDIF»

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
                «IF targets('1.3.5')»
                    $(baseId + 'PreviewContainer')
                        .update(window.atob(selectedElement.previewInfo))
                        .removeClassName('z-hide');
                «ELSE»
                    $('#' + baseId + 'PreviewContainer')
                        .html(window.atob(selectedElement.previewInfo))
                        .removeClass('hidden');
                «ENDIF»
            }
        };

        «name.formatForDB».itemSelector.onItemChanged = function ()
        {
            var baseId, itemSelector, preview;

            baseId = «name.formatForDB».itemSelector.baseId;
            itemSelector = $(«IF !targets('1.3.5')»'#' + «ENDIF»baseId + 'Id');
            preview = window.atob(«name.formatForDB».itemSelector.items[baseId][itemSelector.selectedIndex].previewInfo);

            $(baseId + 'PreviewContainer').«IF targets('1.3.5')»update«ELSE»html«ENDIF»(preview);
            «name.formatForDB».itemSelector.selectedId = «IF targets('1.3.5')»$F(baseId + 'Id')«ELSE»$('#' + baseId + 'Id').val()«ENDIF»;
        };
    '''
}
