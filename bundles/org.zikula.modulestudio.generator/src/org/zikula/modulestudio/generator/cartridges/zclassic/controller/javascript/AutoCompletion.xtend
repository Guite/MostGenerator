package org.zikula.modulestudio.generator.cartridges.zclassic.controller.javascript

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class AutoCompletion {

    extension ModelExtensions = new ModelExtensions
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

        «toggleAutoCompletionFields»

        «resetAutoCompletion»

        «removeRelatedItem»

        «selectResultItem»
        «IF hasUiHooksProviders»

            «selectHookItem»
        «ENDIF»

        «initRelatedItemsForm»

    '''

    def private toggleAutoCompletionFields(Application it) '''
        /**
         * Toggles the fields of an auto completion field.
         */
        function «vendorAndName»ToggleAutoCompletionFields(idPrefix)
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

    def private resetAutoCompletion(Application it) '''
        /**
         * Resets an auto completion field.
         */
        function «vendorAndName»ResetAutoCompletion(idPrefix)
        {
            // hide the sub form
            «vendorAndName»ToggleAutoCompletionFields(idPrefix);

            // reset value of the auto completion field
            jQuery('#' + idPrefix + 'Selector').val('');
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

    def private selectResultItem(Application it) '''
        /**
         * Adds an item to the current selection which has been chosen by auto completion.
         */
        function «vendorAndName»SelectResultItem(objectType, idPrefix, selectedListItem)
        {
            var newItemId, newTitle, includeEditing, removeLink, elemPrefix, li, itemIds;

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

            li = jQuery('<li />', { id: elemPrefix, text: newTitle });
            if (true === includeEditing) {
                li.append(«vendorAndName»CreateInlineEditLink(objectType, idPrefix, elemPrefix, newItemId));
            }

            removeLink = jQuery('<a />', { id: elemPrefix + 'Remove', href: 'javascript:«vendorAndName»RemoveRelatedItem(\'' + idPrefix + '\', ' + newItemId + ');', text: 'remove' });
            li.append(removeLink);
            removeLink.html(' ' + removeImage);

            if (selectedListItem.image !== '') {
                li.append(jQuery('<div>', { id: elemPrefix + 'Preview', name: idPrefix + 'Preview' }).html(selectedListItem.image));
            }

            jQuery('#' + idPrefix + 'ReferenceList').append(li);

            if (true === includeEditing) {
                «vendorAndName»InitInlineEditLink(objectType, idPrefix, elemPrefix, newItemId);
            }

            itemIds += newItemId;
            jQuery('#' + idPrefix).val(itemIds);

            «vendorAndName»ResetAutoCompletion(idPrefix);
        }
    '''

    def private selectHookItem(Application it) '''
        /**
         * Adds a hook assignment item to selection which has been chosen by auto completion.
         */
        function «vendorAndName»SelectHookItem(objectType, idPrefix, selectedListItem)
        {
            «vendorAndName»ResetAutoCompletion(idPrefix);
            «vendorAndName»AttachHookObject(jQuery('#' + idPrefix + 'AddLink'), selectedListItem.id);
        }
    '''

    def private initRelatedItemsForm(Application it) '''
        /**
         * Initialises a relation field section with autocompletion and optional edit capabilities.
         */
        function «vendorAndName»InitRelationItemsForm(objectType, idPrefix, includeEditing)
        {
            var acOptions, acDataSet, acUrl«IF hasUiHooksProviders», isHookAttacher«ENDIF»;

            // update identifier of hidden field for easier usage in JS
            jQuery('#' + idPrefix + 'Multiple').prev().attr('id', idPrefix);

            // add handling for the toggle link if existing
            jQuery('#' + idPrefix + 'AddLink').click(function (event) {
                «vendorAndName»ToggleAutoCompletionFields(idPrefix);
            });

            // add handling for the cancel button
            jQuery('#' + idPrefix + 'SelectorDoCancel').click(function (event) {
                «vendorAndName»ResetAutoCompletion(idPrefix);
            });

            // clear values and ensure starting state
            «vendorAndName»ResetAutoCompletion(idPrefix);

            «IF hasUiHooksProviders»

                isHookAttacher = idPrefix.startsWith('hookAssignment');
            «ENDIF»
            jQuery.each(inlineEditHandlers, function (key, editHandler) {
                if (editHandler.prefix !== (idPrefix + 'SelectorDoNew') || null !== editHandler.acInstance) {
                    return;
                }

                editHandler.acInstance = 'yes';

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
                            «IF hasUiHooksProviders»
                                if (true === isHookAttacher) {
                                    acUrlArgs.exclude = jQuery('#' + idPrefix + 'ExcludedIds').val();
                                } else {
                                    acUrlArgs.exclude = jQuery('#' + idPrefix).val();
                                }
                            «ELSE»
                                acUrlArgs.exclude = jQuery('#' + idPrefix).val();
                            «ENDIF»
                        }

                        jQuery.getJSON(Routing.generate(editHandler.moduleName.toLowerCase() + '_ajax_getitemlistautocompletion', acUrlArgs), function(data) {
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
                        «IF hasUiHooksProviders»
                            if (true === isHookAttacher) {
                                «vendorAndName»SelectHookItem(objectType, idPrefix, ui.item);
                            } else {
                                «vendorAndName»SelectResultItem(objectType, idPrefix, ui.item);
                            }
                        «ELSE»
                            «vendorAndName»SelectResultItem(objectType, idPrefix, ui.item);
                        «ENDIF»

                        return false;
                    }
                })
                .autocomplete('instance')._renderItem = function(ul, item) {
                    return jQuery('<div class="suggestion">')
                        .append('<div class="media"><div class="media-left"><a href="javascript:void(0)">' + item.image + '</a></div><div class="media-body"><p class="media-heading">' + item.title + '</p>' + item.description + '</div></div>')
                        .appendTo(ul);
                };
            });

            «vendorAndName»InitInlineEditingButtons(objectType, idPrefix, includeEditing);
        }
    '''
}
