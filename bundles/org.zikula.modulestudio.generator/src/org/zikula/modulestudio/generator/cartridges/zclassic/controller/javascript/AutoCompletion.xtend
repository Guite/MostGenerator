package org.zikula.modulestudio.generator.cartridges.zclassic.controller.javascript

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class AutoCompletion {

    extension ModelJoinExtensions = new ModelJoinExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    /**
     * Entry point for the JavaScript file with auto completion functionality.
     */
    def generate(Application it, IFileSystemAccess fsa) {
        if (!needsAutoCompletion) {
            return
        }
        var fileName = appName + '.AutoCompletion.js'
        if (!shouldBeSkipped(getAppJsPath + fileName)) {
            println('Generating JavaScript for auto completion')
            if (shouldBeMarked(getAppJsPath + fileName)) {
                fileName = appName + '.AutoCompletion.generated.js'
            }
            fsa.generateFile(getAppJsPath + fileName, generate)
        }
    }

    def private generate(Application it) '''
        'use strict';

        «toggleRelatedItemForm»

        «resetRelatedItemForm»

        «createRelationWindowInstance»

        «initInlineRelationWindow»

        «removeRelatedItem»

        «selectRelatedItem»

        «initRelatedItemsForm»

        «closeWindowFromInside»

    '''

    def private toggleRelatedItemForm(Application it) '''
        /**
         * Toggles the fields of an auto completion field.
         */
        function «vendorAndName»ToggleRelatedItemForm(idPrefix)
        {
            // if we don't have a toggle link do nothing
            if (jQuery('#' + idPrefix + 'AddLink').length < 1) {
                return;
            }

            // show/hide the toggle link
            jQuery('#' + idPrefix + 'AddLink').toggleClass('hidden');

            // hide/show the fields
            jQuery('#' + idPrefix + 'AddFields').toggleClass('hidden');
        }
    '''

    def private resetRelatedItemForm(Application it) '''
        /**
         * Resets an auto completion field.
         */
        function «vendorAndName»ResetRelatedItemForm(idPrefix)
        {
            // hide the sub form
            «vendorAndName»ToggleRelatedItemForm(idPrefix);

            // reset value of the auto completion field
            jQuery('#' + idPrefix + 'Selector').val('');
        }
    '''

    def private createRelationWindowInstance(Application it) '''
        /**
         * Helper function to create new modal form dialog instances.
         */
        function «vendorAndName»CreateRelationWindowInstance(containerElem, useIframe)
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

            // return the instance
            return newWindowId;
        }
    '''

    def private initInlineRelationWindow(Application it) '''
        /**
         * Observe a link for opening an inline window
         */
        function «vendorAndName»InitInlineRelationWindow(objectType, containerID)
        {
            var found, newItem;

            // whether the handler has been found
            found = false;

            // search for the handler
            jQuery.each(relationHandler, function (key, singleRelationHandler) {
                // is this the right one
                if (singleRelationHandler.prefix === containerID) {
                    // yes, it is
                    found = true;
                    // look whether there is already a window instance
                    if (null !== singleRelationHandler.windowInstanceId) {
                        // unset it
                        jQuery(containerID + 'Dialog').dialog('destroy');
                    }
                    // create and assign the new window instance
                    singleRelationHandler.windowInstanceId = «vendorAndName»CreateRelationWindowInstance(jQuery('#' + containerID), true);
                }
            });

            if (false !== found) {
                return;
            }

            // if no handler was found create a new one
            newItem = {
                ot: objectType,«/*alias: '',*/»
                prefix: containerID,
                moduleName: '«appName»',
                acInstance: null,
                windowInstanceId: «vendorAndName»CreateRelationWindowInstance(jQuery('#' + containerID), true)
            };

            // add it to the list of handlers
            relationHandler.push(newItem);
        }
    '''

    def private removeRelatedItem(Application it) '''
        /**
         * Removes a related item from the list of selected ones.
         */
        function «vendorAndName»RemoveRelatedItem(idPrefix, removeId)
        {
            var itemIds, itemIdsArr;

            itemIds = jQuery('#' + idPrefix).val();
            itemIdsArr = itemIds.split(',');

            itemIdsArr = jQuery.grep(itemIdsArr, function(value) {
                return value != removeId;
            });

            itemIds = itemIdsArr.join(',');

            jQuery('#' + idPrefix).val(itemIds);
            jQuery('#' + idPrefix + 'Reference_' + removeId).remove();
        }
    '''

    def private selectRelatedItem(Application it) '''
        /**
         * Adds a related item to selection which has been chosen by auto completion.
         */
        function «vendorAndName»SelectRelatedItem(objectType, idPrefix, selectedListItem)
        {
            var newItemId, newTitle, includeEditing, editLink, removeLink, elemPrefix, itemPreview, li, editHref, fldPreview, itemIds, itemIdsArr;

            itemIds = jQuery('#' + idPrefix).val();
            if (itemIds !== '') {
                if (jQuery('#' + idPrefix + 'Multiple').val() === '0') {
                    jQuery('#' + idPrefix + 'ReferenceList').text('');
                    itemIds = '';
                } else {
                    itemIds += ',';
                }
            }

            newItemId = selectedListItem.id;
            newTitle = selectedListItem.title;
            includeEditing = !!((jQuery('#' + idPrefix + 'Mode').val() == '1'));
            elemPrefix = idPrefix + 'Reference_' + newItemId;
            itemPreview = '';

            if (selectedListItem.image != '') {
                itemPreview = selectedListItem.image;
            }

            var li = jQuery('<li />', { id: elemPrefix, text: newTitle });
            if (true === includeEditing) {
                var editHref = jQuery('#' + idPrefix + 'SelectorDoNew').attr('href') + '&id=' + newItemId;
                editLink = jQuery('<a />', { id: elemPrefix + 'Edit', href: editHref, text: 'edit' });
                li.append(editLink);
            }
            removeLink = jQuery('<a />', { id: elemPrefix + 'Remove', href: 'javascript:«vendorAndName»RemoveRelatedItem(\'' + idPrefix + '\', ' + newItemId + ');', text: 'remove' });
            li.append(removeLink);
            if (itemPreview !== '') {
                fldPreview = jQuery('<div>', { id: elemPrefix + 'preview', name: idPrefix + 'preview' });
                fldPreview.html(itemPreview);
                li.append(fldPreview);
                itemPreview = '';
            }
            jQuery('#' + idPrefix + 'ReferenceList').append(li);

            if (true === includeEditing) {
                editLink.html(' ' + editImage);

                jQuery('#' + elemPrefix + 'Edit').click( function (event) {
                    event.preventDefault();
                    «vendorAndName»InitInlineRelationWindow(objectType, idPrefix + 'Reference_' + newItemId + 'Edit');
                });
            }
            removeLink.html(' ' + removeImage);

            itemIds += newItemId;
            jQuery('#' + idPrefix).val(itemIds);

            «vendorAndName»ResetRelatedItemForm(idPrefix);
        }
    '''

    def private initRelatedItemsForm(Application it) '''
        /**
         * Initialises a relation field section with autocompletion and optional edit capabilities.
         */
        function «vendorAndName»InitRelationItemsForm(objectType, idPrefix, includeEditing)
        {
            var acOptions, acDataSet, itemIds, itemIdsArr, acUrl;

            // update identifier of hidden field for easier usage in JS
            jQuery('#' + idPrefix + 'Multiple').prev().attr('id', idPrefix);

            // add handling for the toggle link if existing
            jQuery('#' + idPrefix + 'AddLink').click( function (event) {
                «vendorAndName»ToggleRelatedItemForm(idPrefix);
            });

            // add handling for the cancel button
            jQuery('#' + idPrefix + 'SelectorDoCancel').click( function (event) {
                «vendorAndName»ResetRelatedItemForm(idPrefix);
            });

            // clear values and ensure starting state
            «vendorAndName»ResetRelatedItemForm(idPrefix);

            jQuery.each(relationHandler, function (key, singleRelationHandler) {
                if (singleRelationHandler.prefix !== (idPrefix + 'SelectorDoNew') || null !== singleRelationHandler.acInstance) {
                    return;
                }

                singleRelationHandler.acInstance = 'yes';

                jQuery('#' + idPrefix + 'Selector').autocomplete({
                    minLength: 1,
                    open: function(event, ui) {
                        jQuery(this).autocomplete('widget').css({
                            width: (jQuery(this).outerWidth() + 'px')
                        });
                    },
                    source: function (request, response) {
                        var acUrlArgs;

                        acUrlArgs = {
                            ot: objectType,
                            fragment: request.term
                        };
                        if (jQuery('#' + idPrefix).length > 0) {
                            acUrlArgs.exclude = jQuery('#' + idPrefix).val();
                        }

                        jQuery.getJSON(Routing.generate(singleRelationHandler.moduleName.toLowerCase() + '_ajax_getitemlistautocompletion', acUrlArgs), function(data) {
                            response(data);
                        });
                    },
                    response: function(event, ui) {
                        jQuery('#' + idPrefix + 'LiveSearch .empty-message').remove();
                        if (ui.content.length === 0) {
                            jQuery('#' + idPrefix + 'LiveSearch').append('<div class="empty-message">' + Translator.__('No results found!') + '</div>');
                        }
                    },
                    focus: function(event, ui) {
                        jQuery('#' + idPrefix + 'Selector').val(ui.item.title);

                        return false;
                    },
                    select: function(event, ui) {
                        «vendorAndName»SelectRelatedItem(objectType, idPrefix, ui.item);

                        return false;
                    }
                })
                .autocomplete('instance')._renderItem = function(ul, item) {
                    return jQuery('<div class="suggestion">')
                        .append('<div class="media"><div class="media-left"><a href="javascript:void(0)">' + item.image + '</a></div><div class="media-body"><p class="media-heading">' + item.title + '</p>' + item.description + '</div></div>')
                        .appendTo(ul);
                };
            });

            if (!includeEditing || jQuery('#' + idPrefix + 'SelectorDoNew').length < 1) {
                return;
            }

            // from here inline editing will be handled
            jQuery('#' + idPrefix + 'SelectorDoNew').attr('href', jQuery('#' + idPrefix + 'SelectorDoNew').attr('href') + '?raw=1&idp=' + idPrefix + 'SelectorDoNew');
            jQuery('#' + idPrefix + 'SelectorDoNew').click( function(event) {
                event.preventDefault();
                «vendorAndName»InitInlineRelationWindow(objectType, idPrefix + 'SelectorDoNew');
            });

            itemIds = jQuery('#' + idPrefix).val();
            itemIdsArr = itemIds.split(',');
            jQuery.each(itemIdsArr, function (key, existingId) {
                var elemPrefix;

                if (existingId) {
                    elemPrefix = idPrefix + 'Reference_' + existingId + 'Edit';
                    jQuery('#' + elemPrefix).attr('href', jQuery('#' + elemPrefix).attr('href') + '?raw=1&idp=' + elemPrefix);
                    jQuery('#' + elemPrefix).click( function (event) {
                        event.preventDefault();
                        «vendorAndName»InitInlineRelationWindow(objectType, elemPrefix);
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
            jQuery.each(window.parent.relationHandler, function (key, singleRelationHandler) {
                var selector;

                // look if this handler is the right one
                if (singleRelationHandler.prefix === idPrefix) {
                    // look whether there is an auto completion instance
                    if (null !== singleRelationHandler.acInstance) {
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
                    if (null !== singleRelationHandler.windowInstanceId) {
                        // close it
                        window.parent.jQuery('#' + singleRelationHandler.windowInstanceId).dialog('close');
                    }
                }
            });
        }
    '''
}
