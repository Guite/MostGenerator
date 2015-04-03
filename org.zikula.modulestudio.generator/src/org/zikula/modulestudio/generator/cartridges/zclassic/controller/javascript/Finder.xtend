package org.zikula.modulestudio.generator.cartridges.zclassic.controller.javascript

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Finder {
    extension FormattingExtensions = new FormattingExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    /**
     * Entry point for the JavaScript file with finder functionality.
     */
    def generate(Application it, IFileSystemAccess fsa) {
        var fileName = ''
        if (targets('1.3.x')) {
            fileName = appName + '_finder.js'
        } else {
            fileName = appName + '.Finder.js'
        }
        if (!shouldBeSkipped(getAppJsPath + fileName)) {
            println('Generating JavaScript for finder component')
            if (shouldBeMarked(getAppJsPath + fileName)) {
                if (targets('1.3.x')) {
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
        function get«appName»PopupAttributes()
        {
            var pWidth, pHeight;

            pWidth = screen.width * 0.75;
            pHeight = screen.height * 0.66;

            return 'width=' + pWidth + ',height=' + pHeight + ',scrollbars,resizable';
        }

        /**
         * Open a popup window with the finder triggered by a Xinha button.
         */
        function «appName»FinderXinha(editor, «prefix()»Url)
        {
            var popupAttributes;

            // Save editor for access in selector window
            current«appName»Editor = editor;

            popupAttributes = get«appName»PopupAttributes();
            window.open(«prefix()»Url, '', popupAttributes);
        }

        /**
         * Open a popup window with the finder triggered by a CKEditor button.
         */
        function «appName»FinderCKEditor(editor, «prefix()»Url)
        {
            // Save editor for access in selector window
            current«appName»Editor = editor;

            editor.popup(
                «IF targets('1.3.x')»
                    Zikula.Config.baseURL + Zikula.Config.entrypoint + '?module=«appName»&type=external&func=finder&editor=ckeditor',
                «ELSE»
                    Routing.generate('«appName.formatForDB»_external_finder', { editor: 'ckeditor' }),
                «ENDIF»
                /*width*/ '80%', /*height*/ '70%',
                'location=no,menubar=no,toolbar=no,dependent=yes,minimizable=no,modal=yes,alwaysRaised=yes,resizable=yes,scrollbars=yes'
            );
        }


        «val elemPrefix = appName.toFirstLower»
        «val objName = appName.toFirstLower»
        var «objName» = {};

        «objName».finder = {};

        «objName».finder.onLoad = function (baseId, selectedId)
        {
            «IF targets('1.3.x')»
                $$('div.categoryselector select').invoke('observe', 'change', «objName».finder.onParamChanged);
                $('«elemPrefix»Sort').observe('change', «objName».finder.onParamChanged);
                $('«elemPrefix»SortDir').observe('change', «objName».finder.onParamChanged);
                $('«elemPrefix»PageSize').observe('change', «objName».finder.onParamChanged);
                $('«elemPrefix»SearchGo').observe('click', «objName».finder.onParamChanged);
                $('«elemPrefix»SearchGo').observe('keypress', «objName».finder.onParamChanged);
                $('«elemPrefix»Submit').addClassName('z-hide');
                $('«elemPrefix»Cancel').observe('click', «objName».finder.handleCancel);
            «ELSE»
                $('div.categoryselector select').change(«objName».finder.onParamChanged);
                $('#«elemPrefix»Sort').change(«objName».finder.onParamChanged);
                $('#«elemPrefix»SortDir').change(«objName».finder.onParamChanged);
                $('#«elemPrefix»PageSize').change(«objName».finder.onParamChanged);
                $('#«elemPrefix»SearchGo').click(«objName».finder.onParamChanged);
                $('#«elemPrefix»SearchGo').keypress(«objName».finder.onParamChanged);
                $('#«elemPrefix»Submit').addClass('hidden');
                $('#«elemPrefix»Cancel').click(«objName».finder.handleCancel);
            «ENDIF»
        };

        «objName».finder.onParamChanged = function ()
        {
            $('«IF !targets('1.3.x')»#«ENDIF»«elemPrefix»SelectorForm').submit();
        };

        «objName».finder.handleCancel = function ()
        {
            var editor, w;

            «IF targets('1.3.x')»
                editor = $F('editorName');
            «ELSE»
                editor = $('#editorName').val();
            «ENDIF»
            if (editor === 'xinha') {
                w = parent.window;
                window.close();
                w.focus();
            } else if (editor === 'tinymce') {
                «vendorAndName»ClosePopup();
            } else if (editor === 'ckeditor') {
                «vendorAndName»ClosePopup();
            } else {
                alert('Close Editor: ' + editor);
            }
        };


        function «vendorAndName»GetPasteSnippet(mode, itemId)
        {
            var quoteFinder, itemUrl, itemTitle, itemDescription, pasteMode;

            quoteFinder = new RegExp('"', 'g');
            «IF targets('1.3.x')»
                itemUrl = $F('url' + itemId).replace(quoteFinder, '');
                itemTitle = $F('title' + itemId).replace(quoteFinder, '');
                itemDescription = $F('desc' + itemId).replace(quoteFinder, '');
                pasteMode = $F('«elemPrefix»PasteAs');
            «ELSE»
                itemUrl = $('#url' + itemId).val().replace(quoteFinder, '');
                itemTitle = $('#title' + itemId).val().replace(quoteFinder, '');
                itemDescription = $('#desc' + itemId).val().replace(quoteFinder, '');
                pasteMode = $('#«elemPrefix»PasteAs').val();
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
        «objName».finder.selectItem = function (itemId)
        {
            var editor, html;

            «IF targets('1.3.x')»
                editor = $F('editorName');
            «ELSE»
                editor = $('#editorName').val();
            «ENDIF»
            if (editor === 'xinha') {
                if (window.opener.current«appName»Editor !== null) {
                    html = «vendorAndName»GetPasteSnippet('html', itemId);

                    window.opener.current«appName»Editor.focusEditor();
                    window.opener.current«appName»Editor.insertHTML(html);
                } else {
                    html = «vendorAndName»GetPasteSnippet('url', itemId);
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
                html = «vendorAndName»GetPasteSnippet('html', itemId);
                tinyMCE.activeEditor.execCommand('mceInsertContent', false, html);
                // other tinymce commands: mceImage, mceInsertLink, mceReplaceContent, see http://www.tinymce.com/wiki.php/Command_identifiers
            } else if (editor === 'ckeditor') {
                if (window.opener.current«appName»Editor !== null) {
                    html = «vendorAndName»GetPasteSnippet('html', itemId);

                    window.opener.current«appName»Editor.insertHtml(html);
                }
            } else {
                alert('Insert into Editor: ' + editor);
            }
            «vendorAndName»ClosePopup();
        };


        function «vendorAndName»ClosePopup()
        {
            window.opener.focus();
            window.close();
        }




        //=============================================================================
        // «appName» item selector for Forms
        //=============================================================================

        «objName».itemSelector = {};
        «objName».itemSelector.items = {};
        «objName».itemSelector.baseId = 0;
        «objName».itemSelector.selectedId = 0;

        «objName».itemSelector.onLoad = function (baseId, selectedId)
        {
            «objName».itemSelector.baseId = baseId;
            «objName».itemSelector.selectedId = selectedId;

            // required as a changed object type requires a new instance of the item selector plugin
            «IF targets('1.3.x')»
                $('«elemPrefix»ObjectType').observe('change', «objName».itemSelector.onParamChanged);

                if ($(baseId + '_catidMain') != undefined) {
                    $(baseId + '_catidMain').observe('change', «objName».itemSelector.onParamChanged);
                } else if ($(baseId + '_catidsMain') != undefined) {
                    $(baseId + '_catidsMain').observe('change', «objName».itemSelector.onParamChanged);
                }
                $(baseId + 'Id').observe('change', «objName».itemSelector.onItemChanged);
                $(baseId + 'Sort').observe('change', «objName».itemSelector.onParamChanged);
                $(baseId + 'SortDir').observe('change', «objName».itemSelector.onParamChanged);
                $('«elemPrefix»SearchGo').observe('click', «objName».itemSelector.onParamChanged);
                $('«elemPrefix»SearchGo').observe('keypress', «objName».itemSelector.onParamChanged);
            «ELSE»
                $('#«elemPrefix»ObjectType').change(«objName».itemSelector.onParamChanged);

                if ($('#' + baseId + '_catidMain').size() > 0) {
                    $('#' + baseId + '_catidMain').change(«objName».itemSelector.onParamChanged);
                } else if ($('#' + baseId + '_catidsMain').size() > 0) {
                    $('#' + baseId + '_catidsMain').change(«objName».itemSelector.onParamChanged);
                }
                $('#' + baseId + 'Id').change(«objName».itemSelector.onItemChanged);
                $('#' + baseId + 'Sort').change(«objName».itemSelector.onParamChanged);
                $('#' + baseId + 'SortDir').change(«objName».itemSelector.onParamChanged);
                $('#«elemPrefix»SearchGo').click(«objName».itemSelector.onParamChanged);
                $('#«elemPrefix»SearchGo').keypress(«objName».itemSelector.onParamChanged);
            «ENDIF»

            «objName».itemSelector.getItemList();
        };

        «objName».itemSelector.onParamChanged = function ()
        {
            $('ajax_indicator').removeClass«IF targets('1.3.x')»Name«ENDIF»('«IF targets('1.3.x')»z-hide«ELSE»hidden«ENDIF»');

            «objName».itemSelector.getItemList();
        };

        «objName».itemSelector.getItemList = function ()
        {
            var baseId, params«IF targets('1.3.x')», request«ENDIF»;

            baseId = «name.formatForDB».itemSelector.baseId;
            params = 'ot=' + baseId + '&';
            «IF targets('1.3.x')»
                if ($(baseId + '_catidMain') != undefined) {
                    params += 'catidMain=' + $F(baseId + '_catidMain') + '&';
                } else if ($(baseId + '_catidsMain') != undefined) {
                    params += 'catidsMain=' + $F(baseId + '_catidsMain') + '&';
                }
                params += 'sort=' + $F(baseId + 'Sort') + '&' +
                          'sortdir=' + $F(baseId + 'SortDir') + '&' +
                          'q=' + $F(baseId + 'SearchTerm');
            «ELSE»
                if ($('#' + baseId + '_catidMain').size() > 0) {
                    params += 'catidMain=' + $('#' + baseId + '_catidMain').val() + '&';
                } else if ($('#' + baseId + '_catidsMain').size() > 0) {
                    params += 'catidsMain=' + $('#' + baseId + '_catidsMain').val() + '&';
                }
                params += 'sort=' + $('#' + baseId + 'Sort').val() + '&' +
                          'sortdir=' + $('#' + baseId + 'SortDir').val() + '&' +
                          'q=' + $('#' + baseId + 'SearchTerm').val();
            «ENDIF»

            «IF targets('1.3.x')»
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
                            baseId = «objName».itemSelector.baseId;
                            «objName».itemSelector.items[baseId] = req.getData();
                            $('ajax_indicator').addClassName('z-hide');
                            «objName».itemSelector.updateItemDropdownEntries();
                            «objName».itemSelector.updatePreview();
                        }
                    }
                );
            «ELSE»
                $.ajax({
                    type: 'POST',
                    url: Routing.generate('«appName.formatForDB»_ajax_getitemlistfinder'),
                    data: params
                }).done(function(res) {
                    // get data returned by the ajax response
                    var baseId;
                    baseId = «objName».itemSelector.baseId;
                    «objName».itemSelector.items[baseId] = res.data;
                    $('#ajax_indicator').addClass('hidden');
                    «objName».itemSelector.updateItemDropdownEntries();
                    «objName».itemSelector.updatePreview();
                })«/*.fail(function(jqXHR, textStatus) {
                    // nothing to do yet
                })*/»;
            «ENDIF»
        };

        «objName».itemSelector.updateItemDropdownEntries = function ()
        {
            var baseId, itemSelector, items, i, item;

            baseId = «objName».itemSelector.baseId;
            itemSelector = $(«IF !targets('1.3.x')»'#' + «ENDIF»baseId + 'Id');
            itemSelector.length = 0;

            items = «objName».itemSelector.items[baseId];
            for (i = 0; i < items.length; ++i) {
                item = items[i];
                itemSelector.options[i] = new Option(item.title, item.id, false);
            }

            if («objName».itemSelector.selectedId > 0) {
                «IF targets('1.3.x')»
                    $(baseId + 'Id').value = «objName».itemSelector.selectedId;
                «ELSE»
                    $('#' + baseId + 'Id').val(«objName».itemSelector.selectedId);
                «ENDIF»
            }
        };

        «objName».itemSelector.updatePreview = function ()
        {
            var baseId, items, selectedElement, i;

            baseId = «objName».itemSelector.baseId;
            items = «objName».itemSelector.items[baseId];

            «IF targets('1.3.x')»
                $(baseId + 'PreviewContainer').addClassName('z-hide');
            «ELSE»
                $('#' + baseId + 'PreviewContainer').addClass('hidden');
            «ENDIF»

            if (items.length === 0) {
                return;
            }

            selectedElement = items[0];
            if («objName».itemSelector.selectedId > 0) {
                for (var i = 0; i < items.length; ++i) {
                    if (items[i].id === «objName».itemSelector.selectedId) {
                        selectedElement = items[i];
                        break;
                    }
                }
            }

            if (selectedElement !== null) {
                «IF targets('1.3.x')»
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

        «objName».itemSelector.onItemChanged = function ()
        {
            var baseId, itemSelector, preview;

            baseId = «objName».itemSelector.baseId;
            itemSelector = $(«IF !targets('1.3.x')»'#' + «ENDIF»baseId + 'Id');
            preview = window.atob(«objName».itemSelector.items[baseId][itemSelector.selectedIndex].previewInfo);

            $(baseId + 'PreviewContainer').«IF targets('1.3.x')»update«ELSE»html«ENDIF»(preview);
            «objName».itemSelector.selectedId = «IF targets('1.3.x')»$F(baseId + 'Id')«ELSE»$('#' + baseId + 'Id').val()«ENDIF»;
        };
    '''
}
