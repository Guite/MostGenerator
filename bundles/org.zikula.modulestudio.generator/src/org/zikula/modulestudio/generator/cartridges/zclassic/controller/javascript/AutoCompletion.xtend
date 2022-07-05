package org.zikula.modulestudio.generator.cartridges.zclassic.controller.javascript

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class AutoCompletion {

    extension ControllerExtensions = new ControllerExtensions
    extension ModelJoinExtensions = new ModelJoinExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    /**
     * Entry point for the JavaScript file with auto completion functionality.
     */
    def generate(Application it, IMostFileSystemAccess fsa) {
        if (!needsAutoCompletion) {
            return
        }
        'Generating JavaScript for auto completion'.printIfNotTesting(fsa)
        val fileName = appName + '.AutoCompletion.js'
        fsa.generateFile(getAppJsPath + fileName, generate)
    }

    def private generate(Application it) '''
        'use strict';

        «toggleAutoCompletionFields»

        «resetAutoCompletion»

        «removeRelatedItem»

        «selectResultItem»

        «initAutoCompletion»

    '''

    def private toggleAutoCompletionFields(Application it) '''
        /**
         * Toggles the fields of an auto completion field.
         */
        function «vendorAndName»ToggleAutoCompletionFields(idPrefix) {
            // if we don't have a toggle link do nothing
            if (jQuery('#' + idPrefix + 'AddLink').length < 1) {
                return;
            }

            // show/hide the toggle link
            jQuery('#' + idPrefix + 'AddLink').toggleClass('d-none');

            // hide/show the fields
            jQuery('#' + idPrefix + 'AddFields').toggleClass('d-none');
        }
    '''

    def private resetAutoCompletion(Application it) '''
        /**
         * Resets an auto completion field.
         */
        function «vendorAndName»ResetAutoCompletion(idPrefix) {
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
        function «vendorAndName»RemoveRelatedItem(idPrefix, removeId) {
            var itemIds, itemIdsArr;

            itemIds = jQuery('#' + idPrefix).val();
            itemIdsArr = itemIds.split(',');

            itemIdsArr = jQuery.grep(itemIdsArr, function (value) {
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
        function «vendorAndName»SelectResultItem(objectType, idPrefix, selectedListItem, includeEditing) {
            var newItemId, newTitle, elemPrefix, li, itemIds;

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
            elemPrefix = idPrefix + 'Reference_' + newItemId;

            li = jQuery('<li>', {
                id: elemPrefix,
                text: newTitle + ' '
            });
            «IF needsInlineEditing»
                if (true === includeEditing) {
                    li.append(«vendorAndName»CreateInlineEditLink(objectType, idPrefix, elemPrefix, newItemId));
                }
            «ENDIF»

            li.append(
                jQuery('<a>', {
                    id: elemPrefix + 'Remove',
                    href: 'javascript:«vendorAndName»RemoveRelatedItem(\'' + idPrefix + '\', ' + newItemId + ');'
                }).append(
                    jQuery('<span>', { class: 'fas fa-trash-alt' })
                        .append(' ' + Translator.trans('remove'))
                )
            );

            if (selectedListItem.image !== '') {
                li.append(
                    jQuery('<div>', {
                        id: elemPrefix + 'Preview',
                        name: idPrefix + 'Preview'
                    }).html(selectedListItem.image)
                );
            }

            jQuery('#' + idPrefix + 'ReferenceList').append(li);
            «IF needsInlineEditing»

                if (true === includeEditing) {
                    «vendorAndName»InitInlineEditLink(objectType, idPrefix, elemPrefix, newItemId, 'autocomplete');
                }
            «ENDIF»

            itemIds += newItemId;
            jQuery('#' + idPrefix).val(itemIds);

            «vendorAndName»ResetAutoCompletion(idPrefix);
        }
    '''

    def private initAutoCompletion(Application it) '''
        /**
         * Initialises auto completion for a relation field.
         */
        function «vendorAndName»InitAutoCompletion(objectType, alias, idPrefix, includeEditing) {
            var acOptions, acDataSet, acUrl;

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

            jQuery('.relation-editing-definition').each(function (index) {
                if (
                    jQuery(this).data('input-type') !== 'autocomplete'
                    || (
                        jQuery(this).data('prefix') !== idPrefix
                        && jQuery(this).data('prefix') !== (idPrefix + 'SelectorDoNew')
                    )
                ) {
                    return;
                }

                var definition = jQuery(this);
                jQuery('#' + idPrefix + 'Selector').autocomplete({
                    minLength: 1,
                    open: function (event, ui) {
                        jQuery(this).autocomplete('widget').css({
                            width: (jQuery(this).outerWidth() + 'px')
                        });
                    },
                    source: function (request, response) {
                        var acUrlArgs;

                        acUrlArgs = {
                            ot: objectType,
                            q: request.term
                        };
                        if (jQuery('#' + idPrefix).length > 0) {
                            acUrlArgs.exclude = jQuery('#' + idPrefix).val();
                        }

                        jQuery.getJSON(Routing.generate(definition.data('module-name').toLowerCase() + '_ajax_getitemlistautocompletion', acUrlArgs), function (data) {
                            response(data);
                        });
                    },
                    response: function (event, ui) {
                        jQuery('#' + idPrefix + 'LiveSearch .empty-message').remove();
                        if (ui.content.length === 0) {
                            jQuery('#' + idPrefix + 'LiveSearch').append(
                                jQuery('<div>', { class: 'empty-message' }).text(Translator.trans('No results found!'))
                            );
                        }
                    },
                    focus: function (event, ui) {
                        jQuery('#' + idPrefix + 'Selector').val(ui.item.title);

                        return false;
                    },
                    select: function (event, ui) {
                        «vendorAndName»SelectResultItem(objectType, idPrefix, ui.item, includeEditing);

                        return false;
                    }
                })
                .autocomplete('instance')._renderItem = function (ul, item) {
                    return jQuery('<div>', { class: 'suggestion' })
                        .append('<div class="media"><div class="media-left"><a href="javascript:void(0)">' + item.image + '</a></div><div class="media-body"><p class="media-heading">' + item.title + '</p>' + item.description + '</div></div>')
                        .appendTo(ul);
                };
            });
        }
    '''
}
