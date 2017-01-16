package org.zikula.modulestudio.generator.cartridges.zclassic.controller.javascript

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Finder {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    /**
     * Entry point for the JavaScript file with finder functionality.
     */
    def generate(Application it, IFileSystemAccess fsa) {
        var fileName = appName + '.Finder.js'
        if (!shouldBeSkipped(getAppJsPath + fileName)) {
            println('Generating JavaScript for finder component')
            if (shouldBeMarked(getAppJsPath + fileName)) {
                fileName = appName + '.Finder.generated.js'
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
         * Open a popup window with the finder triggered by a CKEditor button.
         */
        function «appName»FinderCKEditor(editor, «prefix()»Url)
        {
            // Save editor for access in selector window
            current«appName»Editor = editor;

            editor.popup(
                Routing.generate('«appName.formatForDB»_external_finder', { objectType: '«getLeadingEntity.name.formatForCode»', editor: 'ckeditor' }),
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
            «IF hasImageFields»
                var imageModeEnabled;

                imageModeEnabled = jQuery("[id$='onlyImages']").prop('checked');
                if (!imageModeEnabled) {
                    jQuery('#imageFieldRow').addClass('hidden');
                    jQuery("[id$='pasteAs'] option[value=6]").addClass('hidden');
                    jQuery("[id$='pasteAs'] option[value=7]").addClass('hidden');
                    jQuery("[id$='pasteAs'] option[value=8]").addClass('hidden');
                } else {
                    jQuery('#searchTermRow').addClass('hidden');
                }

                jQuery('input[type="checkbox"]').click(«objName».finder.onParamChanged);
            «ENDIF»
            jQuery('select').not("[id$='pasteAs']").change(«objName».finder.onParamChanged);
            «/*jQuery('.btn-success').addClass('hidden');*/»
            jQuery('.btn-default').click(«objName».finder.handleCancel);

            var selectedItems = jQuery('#«appName.toLowerCase»ItemContainer a');
            selectedItems.bind('click keypress', function (event) {
                event.preventDefault();
                «objName».finder.selectItem(jQuery(this).data('itemid'));
            });
        };

        «objName».finder.onParamChanged = function ()
        {
            jQuery('#«elemPrefix»SelectorForm').submit();
        };

        «objName».finder.handleCancel = function ()
        {
            var editor;

            event.preventDefault();
            editor = jQuery("[id$='editor']").first().val();
            if ('tinymce' === editor) {
                «vendorAndName»ClosePopup();
            } else if ('ckeditor' === editor) {
                «vendorAndName»ClosePopup();
            } else {
                alert('Close Editor: ' + editor);
            }
        };


        function «vendorAndName»GetPasteSnippet(mode, itemId)
        {
            var quoteFinder;
            var itemUrl;
            var itemTitle;
            var itemDescription;
            «IF hasImageFields»
                var imageUrl;
            «ENDIF»
            var pasteMode;

            quoteFinder = new RegExp('"', 'g');
            itemUrl = jQuery('#url' + itemId).val().replace(quoteFinder, '');
            itemTitle = jQuery('#title' + itemId).val().replace(quoteFinder, '').trim();
            itemDescription = jQuery('#desc' + itemId).val().replace(quoteFinder, '').trim();
            «IF hasImageFields»
                imageUrl = jQuery('#imageUrl' + itemId).length > 0 ? jQuery('#imageUrl' + itemId).val().replace(quoteFinder, '') : '';
            «ENDIF»
            pasteMode = jQuery("[id$='pasteAs']").first().val();

            // item ID
            if (pasteMode === '2') {
                return '' + itemId;
            }

            // link to detail page
            if (pasteMode === '1') {
                return mode === 'url' ? itemUrl : '<a href="' + itemUrl + '" title="' + itemDescription + '">' + itemTitle + '</a>';
            }
            «IF hasImageFields»

                if (pasteMode === '6') {
                    // link to image file
                    return mode === 'url' ? imageUrl : '<a href="' + imageUrl + '" title="' + itemDescription + '">' + itemTitle + '</a>';
                }
                if (pasteMode === '7') {
                    // image tag
                    return '<img src="' + imageUrl + '" alt="' + itemTitle + '" width="300" />';
                }
                if (pasteMode === '8') {
                    // image tag with link to detail page
                    return mode === 'url' ? itemUrl : '<a href="' + itemUrl + '" title="' + itemTitle + '"><img src="' + imageUrl + '" alt="' + itemTitle + '" width="300" /></a>';
                }

            «ENDIF»

            return '';
        }


        // User clicks on "select item" button
        «objName».finder.selectItem = function (itemId)
        {
            var editor, html;

            editor = jQuery("[id$='editor']").first().val();
            if ('tinymce' === editor) {
                html = «vendorAndName»GetPasteSnippet('html', itemId);
                tinyMCE.activeEditor.execCommand('mceInsertContent', false, html);
                // other tinymce commands: mceImage, mceInsertLink, mceReplaceContent, see http://www.tinymce.com/wiki.php/Command_identifiers
            } else if ('ckeditor' === editor) {
                if (null !== window.opener.current«appName»Editor) {
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
            jQuery('#«elemPrefix»ObjectType').change(«objName».itemSelector.onParamChanged);

            jQuery('#' + baseId + '_catidMain').change(«objName».itemSelector.onParamChanged);
            jQuery('#' + baseId + '_catidsMain').change(«objName».itemSelector.onParamChanged);
            jQuery('#' + baseId + 'Id').change(«objName».itemSelector.onItemChanged);
            jQuery('#' + baseId + 'Sort').change(«objName».itemSelector.onParamChanged);
            jQuery('#' + baseId + 'SortDir').change(«objName».itemSelector.onParamChanged);
            jQuery('#«elemPrefix»SearchGo').click(«objName».itemSelector.onParamChanged);
            jQuery('#«elemPrefix»SearchGo').keypress(«objName».itemSelector.onParamChanged);

            «objName».itemSelector.getItemList();
        };

        «objName».itemSelector.onParamChanged = function ()
        {
            jQuery('#ajax_indicator').removeClass('hidden');

            «objName».itemSelector.getItemList();
        };

        «objName».itemSelector.getItemList = function ()
        {
            var baseId;
            var params;

            baseId = «name.formatForDB».itemSelector.baseId;
            params = {
                ot: baseId,
                sort: jQuery('#' + baseId + 'Sort').val(),
                sortdir: jQuery('#' + baseId + 'SortDir').val(),
                q: jQuery('#' + baseId + 'SearchTerm').val()
            }
            if (jQuery('#' + baseId + '_catidMain').length > 0) {
                params[catidMain] = jQuery('#' + baseId + '_catidMain').val();
            } else if (jQuery('#' + baseId + '_catidsMain').length > 0) {
                params[catidsMain] = jQuery('#' + baseId + '_catidsMain').val();
            }

            jQuery.ajax({
                type: 'POST',
                url: Routing.generate('«appName.formatForDB»_ajax_getitemlistfinder'),
                data: params
            }).done(function(res) {
                // get data returned by the ajax response
                var baseId;
                baseId = «objName».itemSelector.baseId;
                «objName».itemSelector.items[baseId] = res.data;
                jQuery('#ajax_indicator').addClass('hidden');
                «objName».itemSelector.updateItemDropdownEntries();
                «objName».itemSelector.updatePreview();
            })«/*.fail(function(jqXHR, textStatus) {
                // nothing to do yet
            })*/»;
        };

        «objName».itemSelector.updateItemDropdownEntries = function ()
        {
            var baseId, itemSelector, items, i, item;

            baseId = «objName».itemSelector.baseId;
            itemSelector = jQuery('#' + baseId + 'Id');
            itemSelector.length = 0;

            items = «objName».itemSelector.items[baseId];
            for (i = 0; i < items.length; ++i) {
                item = items[i];
                itemSelector.options[i] = new Option(item.title, item.id, false);
            }

            if («objName».itemSelector.selectedId > 0) {
                jQuery('#' + baseId + 'Id').val(«objName».itemSelector.selectedId);
            }
        };

        «objName».itemSelector.updatePreview = function ()
        {
            var baseId, items, selectedElement, i;

            baseId = «objName».itemSelector.baseId;
            items = «objName».itemSelector.items[baseId];

            jQuery('#' + baseId + 'PreviewContainer').addClass('hidden');

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

            if (null !== selectedElement) {
                jQuery('#' + baseId + 'PreviewContainer')
                    .html(window.atob(selectedElement.previewInfo))
                    .removeClass('hidden');
            }
        };

        «objName».itemSelector.onItemChanged = function ()
        {
            var baseId, itemSelector, preview;

            baseId = «objName».itemSelector.baseId;
            itemSelector = jQuery('#' + baseId + 'Id');
            preview = window.atob(«objName».itemSelector.items[baseId][itemSelector.selectedIndex].previewInfo);

            jQuery('#' + baseId + 'PreviewContainer').html(preview);
            «objName».itemSelector.selectedId = jQuery('#' + baseId + 'Id').val();
        };
    '''
}
