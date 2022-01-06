package org.zikula.modulestudio.generator.cartridges.zclassic.controller.javascript

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class InlineEditing {

    extension ControllerExtensions = new ControllerExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    /**
     * Entry point for the JavaScript file with inline editing functionality.
     */
    def generate(Application it, IMostFileSystemAccess fsa) {
        if (!needsInlineEditing) {
            return
        }
        'Generating JavaScript for inline editing'.printIfNotTesting(fsa)
        val fileName = appName + '.InlineEditing.js'
        fsa.generateFile(getAppJsPath + fileName, generate)
    }

    def private generate(Application it) '''
        'use strict';

        var «vendorAndName»InlineEditHandlers = [];

        «createInlineEditingWindowInstance»

        «initInlineEditingWindow»

        «createInlineEditLink»

        «initInlineEditLink»

        «determineInputReference»

        «initInlineEditingButtons»

        «closeWindowFromInside»

        «onLoad»
    '''

    def private createInlineEditingWindowInstance(Application it) '''
        /**
         * Helper function to create new modal form dialog instances.
         */
        function «vendorAndName»CreateInlineEditingWindowInstance(containerElem) {
            var newWindowId;

            // define the new window instance
            newWindowId = containerElem.attr('id') + 'Dialog';
            jQuery('<div>', { id: newWindowId })
                .append(
                    jQuery('<iframe>', { src: containerElem.attr('href') })
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
        function «vendorAndName»InitInlineEditingWindow(objectType, idPrefix, containerId, inputType) {
            var found, newEditHandler;

            // whether the handler has been found
            found = false;

            // search for the handler
            jQuery.each(«vendorAndName»InlineEditHandlers, function (key, editHandler) {
                // is this the right one
                if (editHandler.prefix !== containerId) {
                    return;
                }

                // yes, it is
                found = true;
                // look whether there is already a window instance
                if (null !== editHandler.windowInstanceId) {
                    // unset it
                    jQuery('#' + editHandler.windowInstanceId).dialog('destroy');
                }
                // create and assign the new window instance
                editHandler.windowInstanceId = «vendorAndName»CreateInlineEditingWindowInstance(jQuery('#' + containerId));
            });

            if (false !== found) {
                return;
            }

            // if no inline editing handler was found create a new one
            newEditHandler = {
                alias: idPrefix,
                prefix: containerId,
                moduleName: '«appName»',
                objectType: objectType,
                inputType: inputType,
                windowInstanceId: «vendorAndName»CreateInlineEditingWindowInstance(jQuery('#' + containerId))
            };

            // add it to the list of edit handlers
            «vendorAndName»InlineEditHandlers.push(newEditHandler);
        }
    '''

    def private createInlineEditLink(Application it) '''
        /**
         * Creates a link for editing an existing item using inline editing.
         */
        function «vendorAndName»CreateInlineEditLink(objectType, idPrefix, elemPrefix, itemId) {
            var editHref, editLink;

            editHref = jQuery('#' + idPrefix + 'SelectorDoNew').attr('href') + '&id=' + itemId;
            editLink = jQuery('<a>', {
                id: elemPrefix + 'Edit',
                href: editHref,
                text: 'edit'
            }).append(
                jQuery('<span>', { class: 'fas fa-edit' })
            );

            return editLink;
        }
    '''

    def private initInlineEditLink(Application it) '''
        /**
         * Initialises behaviour for an inline editing link.
         */
        function «vendorAndName»InitInlineEditLink(objectType, idPrefix, elemPrefix, itemId, inputType) {
            jQuery('#' + elemPrefix + 'Edit').click(function (event) {
                event.preventDefault();
                «vendorAndName»InitInlineEditingWindow(objectType, idPrefix, idPrefix + 'Reference_' + itemId + 'Edit');
            });
        }
    '''

    def private determineInputReference(Application it) '''
        /**
         * Returns the input field reference for a given context
         */
        function «vendorAndName»DetermineInputReference(objectType, alias, idPrefix, inputType, targetWindow) {
            var inputPrefix, inputIdentifier, inputField;

            // determine reference to input element
            inputPrefix = targetWindow.jQuery('.«vendorAndName.toLowerCase»-edit-form').first().attr('name');
            inputField = null;
            if (inputType === 'autocomplete') {
                inputIdentifier = idPrefix.replace('DoNew', '');
                inputField = targetWindow.jQuery('#' + inputIdentifier).first();
            } else if (inputType === 'select-single' || inputType === 'select-multi') {
                inputIdentifier = inputPrefix + '_' + alias;
                inputField = targetWindow.jQuery('#' + inputIdentifier).first();
            } else if (inputType === 'checkbox' || inputType === 'radio') {
                // points to the containing div element in this case
                inputIdentifier = inputPrefix + '_' + alias;
                inputField = targetWindow.jQuery('#' + alias + 'InlineEditingContainer').find('.form-group').first().find('div').first();
            }

            return {
                prefix: inputPrefix,
                identifier: inputIdentifier,
                field: inputField
            };
        }
    '''

    def private initInlineEditingButtons(Application it) '''
        /**
         * Initialises inline editing capability for a certain form section.
         */
        function «vendorAndName»InitInlineEditingButtons(objectType, alias, idPrefix, inputType, createUrl) {
            var inputReference, createButtonId, createButton, itemIds, itemIdsArr;

            inputReference = «vendorAndName»DetermineInputReference(objectType, alias, idPrefix, inputType, window);
            if (null === inputReference || null === inputReference.field) {
                return;
            }

            createButtonId = idPrefix + 'SelectorDoNew';

            if (jQuery('#' + createButtonId).length < 1) {
                if (inputType === 'autocomplete') {
                    return;
                }
                // dynamically add create button
                createButton = jQuery('<a>', {
                    id: createButtonId,
                    href: createUrl,
                    title: Translator.trans('Create new entry'),
                    class: 'btn btn-secondary «appName.toLowerCase»-inline-button'
                }).append(
                    jQuery('<i>', { class: 'fas fa-plus' })
                ).append(' ' + Translator.trans('Create'));

                if (inputType === 'select-single' || inputType === 'select-multi') {
                    inputReference.field.parent().append(createButton);
                } else if (inputType === 'checkbox' || inputType === 'radio') {
                    inputReference.field.append(createButton);
                }
            }

            createButton = jQuery('#' + createButtonId);
            createButton.attr('href', createButton.attr('href') + '?raw=1&idp=' + createButtonId);
            createButton.click(function (event) {
                event.preventDefault();
                «vendorAndName»InitInlineEditingWindow(objectType, idPrefix, createButtonId, inputType);
            });

            if (inputType === 'select-single' || inputType === 'select-multi') {
                // no edit buttons for select options
                return;
            }

            if (inputType === 'autocomplete') {
                itemIds = jQuery('#' + idPrefix).val();
                itemIdsArr = itemIds.split(',');
            } else if (inputType === 'checkbox' || inputType === 'radio') {
                itemIdsArr = [];
                inputReference.field.find('input').each(function (index) {
                    var existingId, elemPrefix;

                    existingId = jQuery(this).attr('value');
                    itemIdsArr.push(existingId);

                    elemPrefix = idPrefix + 'Reference_' + existingId + 'Edit';
                    if (jQuery('#' + elemPrefix).length < 1) {
                        jQuery(this).parent().append(' ').append(
                            jQuery('<a>', {
                                id: elemPrefix,
                                href: createUrl,
                                title: Translator.trans('Edit this entry')
                            }).append(
                                jQuery('<span>', { class: 'fas fa-edit' })
                            )
                        );
                    }
                });
            }
            jQuery.each(itemIdsArr, function (key, existingId) {
                var elemPrefix;

                if (existingId) {
                    elemPrefix = idPrefix + 'Reference_' + existingId + 'Edit';
                    if (jQuery('#' + elemPrefix) < 1) {
                        return;
                    }
                    jQuery('#' + elemPrefix).attr('href', jQuery('#' + elemPrefix).attr('href') + '?raw=1&idp=' + elemPrefix);
                    jQuery('#' + elemPrefix).click(function (event) {
                        event.preventDefault();
                        «vendorAndName»InitInlineEditingWindow(objectType, idPrefix, elemPrefix, inputType);
                    });
                }
            });
        }
    '''

    def private closeWindowFromInside(Application it) '''
        /**
         * Closes an iframe from the document displayed in it.
         */
        function «vendorAndName»CloseWindowFromInside(idPrefix, itemId, formattedTitle, searchTerm) {
            // if there is no parent window do nothing
            if (window.parent === '') {
                return;
            }

            // search for the handler of the current window
            jQuery.each(window.parent.«vendorAndName»InlineEditHandlers, function (key, editHandler) {
                var inputType, inputReference, newElement, anchorElement;

                // look if this handler is the right one
                if (editHandler.prefix !== idPrefix) {
                    return;
                }

                // determine reference to input element
                inputType = editHandler.inputType;
                inputReference = «vendorAndName»DetermineInputReference(editHandler.objectType, editHandler.alias, idPrefix, inputType, window.parent);
                if (null === inputReference || null === inputReference.field) {
                    return;
                }

                // show a message
                anchorElement = (inputType === 'autocomplete') ? inputReference.field : inputReference.field.parents('.form-group').first();
                window.parent.«vendorAndName»SimpleAlert(anchorElement, window.parent.Translator.trans('Information'), window.parent.Translator.trans('Action has been completed.'), 'actionDoneAlert', 'success');

                // check if a new item has been created
                if (itemId > 0) {
                    newElement = '';
                    if (inputType === 'autocomplete') {
                        // activate auto completion
                        if (searchTerm == '') {
                            searchTerm = inputReference.field.val();
                        }
                        if (searchTerm != '') {
                            inputReference.field.autocomplete('option', 'autoFocus', true);
                            inputReference.field.autocomplete('search', searchTerm);
                            window.setTimeout(function () {
                                var suggestions = inputReference.field.autocomplete('widget')[0].children;
                                if (suggestions.length === 1) {
                                    window.parent.jQuery(suggestions[0]).click();
                                }
                                inputReference.field.autocomplete('option', 'autoFocus', false);
                            }, 1000);
                        }
                    } else if (inputType === 'select-single' || inputType === 'select-multi') {
                        newElement = jQuery('<option>', {
                            value: itemId,
                            selected: 'selected'
                        }).text(formattedTitle);
                    } else if (inputType === 'checkbox' || inputType === 'radio') {
                        if (inputType === 'checkbox') {
                            newElement = jQuery('<label>', {
                                class: 'checkbox-inline'
                            }).append(
                                jQuery('<input>', {
                                    type: 'checkbox',
                                    id: inputReference.identifier + '_' + itemId,
                                    name: inputReference.prefix + '[' + editHandler.alias + '][]',
                                    value: itemId,
                                    checked: 'checked'
                                })
                            ).append(' ' + formattedTitle);
                        } else if (inputType === 'radio') {
                            newElement = jQuery('<label>', {
                                class: 'radio-inline'
                            }).append(
                                jQuery('<input>', {
                                    type: 'radio',
                                    id: inputReference.identifier + '_' + itemId,
                                    name: inputReference.prefix + '[' + editHandler.alias + ']',
                                    value: itemId,
                                    checked: 'checked'
                                })
                            ).append(' ' + formattedTitle);
                        }
                    }
                    inputReference.field.append(newElement);
                }

                // look whether there is a window instance
                if (null !== editHandler.windowInstanceId) {
                    // close it
                    window.parent.jQuery('#' + editHandler.windowInstanceId).dialog('close');
                }
            });
        }
    '''

    def private onLoad(Application it) '''
        jQuery(document).ready(function () {
            if (jQuery('#inlineRedirectParameters').length > 0) {
                var redirectParams = jQuery('#inlineRedirectParameters');
                «vendorAndName»CloseWindowFromInside(
                    redirectParams.data('idprefix'),
                    redirectParams.data('itemid'),
                    redirectParams.data('title'),
                    redirectParams.data('searchterm')
                );
            }
        });
    '''
}
