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

                if (jQuery('#«elemPrefix»SelectorForm').length < 1) {
                    return;
                }

                imageModeEnabled = jQuery("[id$='onlyImages']").prop('checked');
                if (!imageModeEnabled) {
                    jQuery('#imageFieldRow').addClass('hidden');
                    jQuery("[id$='pasteAs'] option[value=6]").addClass('hidden');
                    jQuery("[id$='pasteAs'] option[value=7]").addClass('hidden');
                    jQuery("[id$='pasteAs'] option[value=8]").addClass('hidden');
                    jQuery("[id$='pasteAs'] option[value=9]").addClass('hidden');
                } else {
                    jQuery('#searchTermRow').addClass('hidden');
                }

                jQuery('input[type="checkbox"]').click(«objName».finder.onParamChanged);
            «ELSE»
                if (jQuery('#«elemPrefix»SelectorForm').length < 1) {
                    return;
                }
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

        «objName».finder.handleCancel = function (event)
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
            var itemPath;
            var itemUrl;
            var itemTitle;
            var itemDescription;
            «IF hasImageFields»
                var imagePath;
            «ENDIF»
            var pasteMode;

            quoteFinder = new RegExp('"', 'g');
            itemPath = jQuery('#path' + itemId).val().replace(quoteFinder, '');
            itemUrl = jQuery('#url' + itemId).val().replace(quoteFinder, '');
            itemTitle = jQuery('#title' + itemId).val().replace(quoteFinder, '').trim();
            itemDescription = jQuery('#desc' + itemId).val().replace(quoteFinder, '').trim();
            «IF hasImageFields»
                imagePath = jQuery('#imagePath' + itemId).length > 0 ? jQuery('#imagePath' + itemId).val().replace(quoteFinder, '') : '';
            «ENDIF»
            pasteMode = jQuery("[id$='pasteAs']").first().val();

            // item ID
            if (pasteMode === '3') {
                return '' + itemId;
            }

            // relative link to detail page
            if (pasteMode === '1') {
                return mode === 'url' ? itemPath : '<a href="' + itemPath + '" title="' + itemDescription + '">' + itemTitle + '</a>';
            }
            // absolute url to detail page
            if (pasteMode === '2') {
                return mode === 'url' ? itemUrl : '<a href="' + itemUrl + '" title="' + itemDescription + '">' + itemTitle + '</a>';
            }
            «IF hasImageFields»

                if (pasteMode === '6') {
                    // relative link to image file
                    return mode === 'url' ? imagePath : '<a href="' + imagePath + '" title="' + itemDescription + '">' + itemTitle + '</a>';
                }
                if (pasteMode === '7') {
                    // image tag
                    return '<img src="' + imagePath + '" alt="' + itemTitle + '" width="300" />';
                }
                if (pasteMode === '8') {
                    // image tag with relative link to detail page
                    return mode === 'url' ? itemPath : '<a href="' + itemPath + '" title="' + itemTitle + '"><img src="' + imagePath + '" alt="' + itemTitle + '" width="300" /></a>';
                }
                if (pasteMode === '9') {
                    // image tag with absolute url to detail page
                    return mode === 'url' ? itemUrl : '<a href="' + itemUrl + '" title="' + itemTitle + '"><img src="' + imagePath + '" alt="' + itemTitle + '" width="300" /></a>';
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

        jQuery(document).ready(function() {
            «objName».finder.onLoad();
        });
    '''
}
