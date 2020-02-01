package org.zikula.modulestudio.generator.cartridges.zclassic.controller.javascript

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
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
    def generate(Application it, IMostFileSystemAccess fsa) {
        if (!generateExternalControllerAndFinder) {
            return
        }
        'Generating JavaScript for finder component'.printIfNotTesting(fsa)
        val fileName = appName + '.Finder.js'
        fsa.generateFile(getAppJsPath + fileName, generate)
    }

    def private generate(Application it) '''
        'use strict';

        var current«appName»Editor = null;
        var current«appName»Input = null;

        /**
         * Returns the attributes used for the popup window. 
         * @return {String}
         */
        function get«appName»PopupAttributes() {
            var pWidth, pHeight;

            pWidth = screen.width * 0.75;
            pHeight = screen.height * 0.66;

            return 'width=' + pWidth + ',height=' + pHeight + ',location=no,menubar=no,toolbar=no,dependent=yes,minimizable=no,modal=yes,alwaysRaised=yes,resizable=yes,scrollbars=yes';
        }

        /**
         * Open a popup window with the finder triggered by an editor button.
         */
        function «appName»FinderOpenPopup(editor, editorName) {
            var popupUrl;

            // Save editor for access in selector window
            current«appName»Editor = editor;

            popupUrl = Routing.generate('«appName.formatForDB»_external_finder', { objectType: '«getLeadingEntity.name.formatForCode»', editor: editorName });

            if (editorName == 'ckeditor') {
                editor.popup(popupUrl, /*width*/ '80%', /*height*/ '70%', get«appName»PopupAttributes());
            } else {
                window.open(popupUrl, '_blank', get«appName»PopupAttributes());
            }
        }


        «val elemPrefix = appName.toFirstLower»
        «val objName = appName.toFirstLower»
        var «objName» = {};

        «objName».finder = {};

        «objName».finder.onLoad = function (baseId, selectedId) {
            «IF hasImageFields»
                var imageModeEnabled;

                if (jQuery('#«elemPrefix»SelectorForm').length < 1) {
                    return;
                }

                imageModeEnabled = jQuery("[id$='onlyImages']").prop('checked');
                if (!imageModeEnabled) {
                    jQuery('#imageFieldRow').addClass('«IF targets('3.0')»d-none«ELSE»hidden«ENDIF»');
                    jQuery("[id$='pasteAs'] option[value=6]").addClass('«IF targets('3.0')»d-none«ELSE»hidden«ENDIF»');
                    jQuery("[id$='pasteAs'] option[value=7]").addClass('«IF targets('3.0')»d-none«ELSE»hidden«ENDIF»');
                    jQuery("[id$='pasteAs'] option[value=8]").addClass('«IF targets('3.0')»d-none«ELSE»hidden«ENDIF»');
                    jQuery("[id$='pasteAs'] option[value=9]").addClass('«IF targets('3.0')»d-none«ELSE»hidden«ENDIF»');
                } else {
                    jQuery('#searchTermRow').addClass('«IF targets('3.0')»d-none«ELSE»hidden«ENDIF»');
                }

                jQuery('input[type="checkbox"]').click(«objName».finder.onParamChanged);
            «ELSE»
                if (jQuery('#«elemPrefix»SelectorForm').length < 1) {
                    return;
                }
            «ENDIF»
            jQuery('select').not("[id$='pasteAs']").change(«objName».finder.onParamChanged);
            «/*jQuery('.btn-success').addClass('«IF targets('3.0')»d-none«ELSE»hidden«ENDIF»');*/»
            jQuery('.btn-«IF targets('3.0')»secondary«ELSE»default«ENDIF»').click(«objName».finder.handleCancel);

            var selectedItems = jQuery('#«appName.toLowerCase»ItemContainer a');
            selectedItems.bind('click keypress', function (event) {
                event.preventDefault();
                «objName».finder.selectItem(jQuery(this).data('itemid'));
            });
        };

        «objName».finder.onParamChanged = function () {
            jQuery('#«elemPrefix»SelectorForm').submit();
        };

        «objName».finder.handleCancel = function (event) {
            var editor;

            event.preventDefault();
            editor = jQuery("[id$='editor']").first().val();
            if ('ckeditor' === editor) {
                «vendorAndName»ClosePopup();
            } else if ('quill' === editor) {
                «vendorAndName»ClosePopup();
            } else if ('summernote' === editor) {
                «vendorAndName»ClosePopup();
            } else if ('tinymce' === editor) {
                «vendorAndName»ClosePopup();
            } else {
                alert('Close Editor: ' + editor);
            }
        };


        function «vendorAndName»GetPasteSnippet(mode, itemId) {
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
            if (!itemDescription) {
                itemDescription = itemTitle;
            }
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
        «objName».finder.selectItem = function (itemId) {
            var editor, html;

            html = «vendorAndName»GetPasteSnippet('html', itemId);
            editor = jQuery("[id$='editor']").first().val();
            if ('ckeditor' === editor) {
                if (null !== window.opener.current«appName»Editor) {
                    window.opener.current«appName»Editor.insertHtml(html);
                }
            } else if ('quill' === editor) {
                if (null !== window.opener.current«appName»Editor) {
                    window.opener.current«appName»Editor.clipboard.dangerouslyPasteHTML(window.opener.current«appName»Editor.getLength(), html);
                }
            } else if ('summernote' === editor) {
                if (null !== window.opener.current«appName»Editor) {
                    html = jQuery(html).get(0);
                    window.opener.current«appName»Editor.invoke('insertNode', html);
                }
            } else if ('tinymce' === editor) {
                window.opener.current«appName»Editor.insertContent(html);
            } else {
                alert('Insert into Editor: ' + editor);
            }
            «vendorAndName»ClosePopup();
        };

        function «vendorAndName»ClosePopup() {
            window.opener.focus();
            window.close();
        }

        jQuery(document).ready(function () {
            «objName».finder.onLoad();
        });
    '''
}
