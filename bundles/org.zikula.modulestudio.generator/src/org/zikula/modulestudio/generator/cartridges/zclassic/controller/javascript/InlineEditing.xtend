package org.zikula.modulestudio.generator.cartridges.zclassic.controller.javascript

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class InlineEditing {

    extension ModelJoinExtensions = new ModelJoinExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    /**
     * Entry point for the JavaScript file with inline editing functionality.
     */
    def generate(Application it, IFileSystemAccess fsa) {
        if (!needsAutoCompletion) {
            return
        }
        var fileName = appName + '.InlineEditing.js'
        if (!shouldBeSkipped(getAppJsPath + fileName)) {
            println('Generating JavaScript for inline editing')
            if (shouldBeMarked(getAppJsPath + fileName)) {
                fileName = appName + '.InlineEditing.generated.js'
            }
            fsa.generateFile(getAppJsPath + fileName, generate)
        }
    }

    def private generate(Application it) '''
        'use strict';

        «createInlineEditingWindowInstance»

        «initInlineEditingWindow»

        «createInlineEditLink»

        «initInlineEditLink»

        «initInlineEditingButtons»

        «closeWindowFromInside»

    '''

    def private createInlineEditingWindowInstance(Application it) '''
        /**
         * Helper function to create new modal form dialog instances.
         */
        function «vendorAndName»CreateInlineEditingWindowInstance(containerElem, useIframe)
        {
            var newWindowId;

            // define the new window instance
            newWindowId = containerElem.attr('id') + 'Dialog';
            jQuery('<div id="' + newWindowId + '"></div>')
                .append(
                    jQuery('<iframe />')
                        .attr('src', containerElem.attr('href'))
                        .css({ width: '100%', height: '440px' })
                )
                .dialog({
                    autoOpen: false,
                    show: {
                        effect: 'blind',
                        duration: 1000
                    },
                    hide: {
                        effect: 'explode',
                        duration: 1000
                    },
                    //title: containerElem.title,
                    width: 600,
                    height: 500,
                    modal: false
                })
                .dialog('open');

            // return the identifier of dialog dom element
            return newWindowId;
        }
    '''

    def private initInlineEditingWindow(Application it) '''
        /**
         * Observe a link for opening an inline window.
         */
        function «vendorAndName»InitInlineEditingWindow(objectType, containerId)
        {
            var found, newEditHandler;

            // whether the handler has been found
            found = false;

            // search for the handler
            jQuery.each(inlineEditHandlers, function (key, editHandler) {
                // is this the right one
                if (editHandler.prefix === containerId) {
                    // yes, it is
                    found = true;
                    // look whether there is already a window instance
                    if (null !== editHandler.windowInstanceId) {
                        // unset it
                        jQuery(containerId + 'Dialog').dialog('destroy');
                    }
                    // create and assign the new window instance
                    editHandler.windowInstanceId = «vendorAndName»CreateInlineEditingWindowInstance(jQuery('#' + containerId), true);
                }
            });

            if (false !== found) {
                return;
            }

            // if no inline editing handler was found create a new one
            newEditHandler = {
                ot: objectType,«/*alias: '',*/»
                prefix: containerId,
                moduleName: '«appName»',
                acInstance: null,
                windowInstanceId: «vendorAndName»CreateInlineEditingWindowInstance(jQuery('#' + containerId), true)
            };

            // add it to the list of edit handlers
            inlineEditHandlers.push(newEditHandler);
        }
    '''

    def private createInlineEditLink(Application it) '''
        /**
         * Creates a link for editing an existing item using inline editing.
         */
        function «vendorAndName»CreateInlineEditLink(objectType, idPrefix, elemPrefix, itemId)
        {
            var editHref, editLink;

            editHref = jQuery('#' + idPrefix + 'SelectorDoNew').attr('href') + '&id=' + itemId;
            editLink = jQuery('<a />', { id: elemPrefix + 'Edit', href: editHref, text: 'edit' });
            editLink.html(' ' + editImage);

            return editLink;
        }
    '''

    def private initInlineEditLink(Application it) '''
        /**
         * Initialises behaviour for an inline editing link.
         */
        function «vendorAndName»InitInlineEditLink(objectType, idPrefix, elemPrefix, itemId)
        {
            jQuery('#' + elemPrefix + 'Edit').click(function (event) {
                event.preventDefault();
                «vendorAndName»InitInlineEditingWindow(objectType, idPrefix + 'Reference_' + itemId + 'Edit');
            });
        }
    '''

    def private initInlineEditingButtons(Application it) '''
        /**
         * Initialises inline editing capability for a certain form section.
         */
        function «vendorAndName»InitInlineEditingButtons(objectType, idPrefix, includeEditing)
        {
            var itemIds, itemIdsArr;

            if (!includeEditing || jQuery('#' + idPrefix + 'SelectorDoNew').length < 1) {
                return;
            }

            jQuery('#' + idPrefix + 'SelectorDoNew').attr('href', jQuery('#' + idPrefix + 'SelectorDoNew').attr('href') + '?raw=1&idp=' + idPrefix + 'SelectorDoNew');
            jQuery('#' + idPrefix + 'SelectorDoNew').click(function (event) {
                event.preventDefault();
                «vendorAndName»InitInlineEditingWindow(objectType, idPrefix + 'SelectorDoNew');
            });

            itemIds = jQuery('#' + idPrefix).val();
            itemIdsArr = itemIds.split(',');
            jQuery.each(itemIdsArr, function (key, existingId) {
                var elemPrefix;

                if (existingId) {
                    elemPrefix = idPrefix + 'Reference_' + existingId + 'Edit';
                    jQuery('#' + elemPrefix).attr('href', jQuery('#' + elemPrefix).attr('href') + '?raw=1&idp=' + elemPrefix);
                    jQuery('#' + elemPrefix).click(function (event) {
                        event.preventDefault();
                        «vendorAndName»InitInlineEditingWindow(objectType, elemPrefix);
                    });
                }
            });
        }
    '''

    def private closeWindowFromInside(Application it) '''
        /**
         * Closes an iframe from the document displayed in it.
         */
        function «vendorAndName»CloseWindowFromInside(idPrefix, itemId, searchTerm)
        {
            // if there is no parent window do nothing
            if (window.parent === '') {
                return;
            }

            // search for the handler of the current window
            jQuery.each(window.parent.inlineEditHandlers, function (key, editHandler) {
                var selector;

                // look if this handler is the right one
                if (editHandler.prefix === idPrefix) {
                    // look whether there is an auto completion instance
                    if (null !== editHandler.acInstance) {
                        selector = window.parent.jQuery('#' + idPrefix.replace('DoNew', '')).first();

                        // show a message
                        window.parent.«vendorAndName»SimpleAlert(selector, window.parent.Translator.__('Information'), window.parent.Translator.__('Action has been completed.'), 'actionDoneAlert', 'success');

                        // check if a new item has been created
                        if (itemId > 0) {
                            // activate auto completion
                            if (searchTerm == '') {
                                searchTerm = selector.val();
                            }
                            if (searchTerm != '') {
                                selector.autocomplete('option', 'autoFocus', true);
                                selector.autocomplete('search', searchTerm);
                                window.setTimeout(function() {
                                    var suggestions = selector.autocomplete('widget')[0].children;
                                    if (suggestions.length === 1) {
                                        window.parent.jQuery(suggestions[0]).click();
                                    }
                                    selector.autocomplete('option', 'autoFocus', false);
                                }, 1000);
                            }
                        }
                    }

                    // look whether there is a window instance
                    if (null !== editHandler.windowInstanceId) {
                        // close it
                        window.parent.jQuery('#' + editHandler.windowInstanceId).dialog('close');
                    }
                }
            });
        }
    '''
}
