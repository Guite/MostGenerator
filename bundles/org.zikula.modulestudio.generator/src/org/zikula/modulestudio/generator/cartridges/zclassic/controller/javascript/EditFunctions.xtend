package org.zikula.modulestudio.generator.cartridges.zclassic.controller.javascript

import de.guite.modulestudio.metamodel.AbstractDateField
import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class EditFunctions {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelExtensions = new ModelExtensions
    extension ModelJoinExtensions = new ModelJoinExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    /**
     * Entry point for the JavaScript file with edit functionality.
     */
    def generate(Application it, IFileSystemAccess fsa) {
        var fileName = appName + '.EditFunctions.js'
        if (!shouldBeSkipped(getAppJsPath + fileName)) {
            println('Generating JavaScript for edit functions')
            if (shouldBeMarked(getAppJsPath + fileName)) {
                fileName = appName + '.EditFunctions.generated.js'
            }
            fsa.generateFile(getAppJsPath + fileName, generate)
        }
    }

    def private generate(Application it) '''
        'use strict';

        «IF hasUserFields || hasStandardFieldEntities»
            «initUserField»

        «ENDIF»
        «IF hasUploads»
            «resetUploadField»

            «initUploadField»

        «ENDIF»
        «IF !entities.filter[!getDerivedFields.filter(AbstractDateField).empty].empty»
            «initDateField»

        «ENDIF»
        «initEditForm»

        «relationshipFunctions»
    '''

    def private initUserField(Application it) '''
        «IF needsUserAutoCompletion»
            /**
             * Initialises a user field with auto completion.
             */
            function «vendorAndName»InitUserField(fieldName, getterName)
            {
                jQuery('#' + fieldName + 'ResetVal').click( function (event) {
                    event.preventDefault();
                    jQuery('#' + fieldName).val('');
                    jQuery('#' + fieldName + 'Selector').val('');
                }).removeClass('hidden');

                if (jQuery('#' + fieldName + 'LiveSearch').length < 1) {
                    return;
                }
                jQuery('#' + fieldName + 'LiveSearch').removeClass('hidden');

                jQuery('#' + fieldName + 'Selector').autocomplete({
                    minLength: 1,
                    source: function (request, response) {
                        jQuery.getJSON(Routing.generate('«appName.formatForDB»_ajax_' + getterName.toLowerCase(), { fragment: request.term }), function(data) {
                            response(data);
                        });
                    },
                    response: function(event, ui) {
                        if (ui.content.length === 0) {
                            jQuery('#' + fieldName + 'LiveSearch').append('<div class="empty-message">' + Translator.__('No results found!') + '</div>');
                        } else {
                            jQuery('#' + fieldName + 'LiveSearch .empty-message').remove();
                        }
                    },
                    focus: function(event, ui) {
                        jQuery('#' + fieldName + 'Selector').val(ui.item.uname);

                        return false;
                    },
                    select: function(event, ui) {
                        jQuery('#' + fieldName).val(ui.item.uid);
                        jQuery('#' + fieldName + 'Avatar').html(ui.item.avatar);

                        return false;
                    }
                })
                .autocomplete('instance')._renderItem = function(ul, item) {
                    return jQuery('<div class="suggestion">')
                        .append('<div class="media"><div class="media-left"><a href="javascript:void(0)">' + item.avatar + '</a></div><div class="media-body"><p class="media-heading">' + item.uname + '</p></div></div>')
                        .appendTo(ul);
                };
            }

        «ENDIF»
    '''

    def private resetUploadField(Application it) '''
        /**
         * Resets the value of an upload / file input field.
         */
        function «vendorAndName»ResetUploadField(fieldName)
        {
            jQuery('#' + fieldName).attr('type', 'input');
            jQuery('#' + fieldName).attr('type', 'file');
        }
    '''

    def private initUploadField(Application it) '''
        /**
         * Initialises the reset button for a certain upload input.
         */
        function «vendorAndName»InitUploadField(fieldName)
        {
            jQuery('#' + fieldName + 'ResetVal').click( function (event) {
                event.preventDefault();
                «vendorAndName»ResetUploadField(fieldName);
            }).removeClass('hidden');
        }
    '''

    def private initDateField(Application it) '''
        /**
         * Initialises the reset button for a certain date input.
         */
        function «vendorAndName»InitDateField(fieldName)
        {
            jQuery('#' + fieldName + 'ResetVal').click( function (event) {
                event.preventDefault();
                jQuery('#' + fieldName).val('');
            }).removeClass('hidden');
        }
    '''

    def private initEditForm(Application it) '''
        var editedObjectType;
        var editedEntityId;
        var editForm;
        var formButtons;
        var triggerValidation = true;

        function «vendorAndName»TriggerFormValidation()
        {
            «vendorAndName»ExecuteCustomValidationConstraints(editedObjectType, editedEntityId);

            if (!editForm.get(0).checkValidity()) {
                // This does not really submit the form,
                // but causes the browser to display the error message
                editForm.find(':submit').first().click();
            }
        }

        function «vendorAndName»HandleFormSubmit (event) {
            if (triggerValidation) {
                «vendorAndName»TriggerFormValidation();
                if (!editForm.get(0).checkValidity()) {
                    event.preventDefault();
                    return false;
                }
            }

            // hide form buttons to prevent double submits by accident
            formButtons.each(function (index) {
                jQuery(this).addClass('hidden');
            });

            return true;
        }

        /**
         * Initialises an entity edit form.
         */
        function «vendorAndName»InitEditForm(mode, entityId)
        {
            if (jQuery('.«vendorAndName.toLowerCase»-edit-form').length < 1) {
                return;
            }

            editForm = jQuery('.«vendorAndName.toLowerCase»-edit-form').first();
            editedObjectType = editForm.attr('id').replace('EditForm', '');
            editedEntityId = entityId;

            if (jQuery('#moderationFieldsSection').length > 0) {
                jQuery('#moderationFieldsContent').addClass('hidden');
                jQuery('#moderationFieldsSection legend').addClass('pointer').click(function (event) {
                    if (jQuery('#moderationFieldsContent').hasClass('hidden')) {
                        jQuery('#moderationFieldsContent').removeClass('hidden');
                        jQuery(this).find('i').removeClass('fa-expand').addClass('fa-compress');
                    } else {
                        jQuery('#moderationFieldsContent').addClass('hidden');
                        jQuery(this).find('i').removeClass('fa-compress').addClass('fa-expand');
                    }
                });
            }

            var allFormFields = editForm.find('input, select, textarea');
            allFormFields.change(function (event) {
                «vendorAndName»ExecuteCustomValidationConstraints(editedObjectType, editedEntityId);
            });

            formButtons = editForm.find('.form-buttons input');
            editForm.find('.btn-danger').first().bind('click keypress', function (event) {
                if (!window.confirm(Translator.__('Do you really want to delete this entry?'))) {
                    event.preventDefault();
                }
            });
            editForm.find('button[type=submit]').bind('click keypress', function (event) {
                triggerValidation = !jQuery(this).attr('formnovalidate');
            });
            editForm.submit(«vendorAndName»HandleFormSubmit);

            if (mode != 'create') {
                «vendorAndName»TriggerFormValidation();
            }
        }
    '''

    def private relationshipFunctions(Application it) '''
        «IF needsAutoCompletion»
            «toggleRelatedItemForm»

            «resetRelatedItemForm»

            «createRelationWindowInstance»

            «initInlineRelationWindow»

            «removeRelatedItem»

            «selectRelatedItem»

            «initRelatedItemsForm»

            «closeWindowFromInside»
        «ENDIF»
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
                        if (ui.content.length === 0) {
                            jQuery('#' + idPrefix + 'LiveSearch').append('<div class="empty-message">' + Translator.__('No results found!') + '</div>');
                        } else {
                            jQuery('#' + idPrefix + 'LiveSearch .empty-message').remove();
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
        function «vendorAndName»CloseWindowFromInside(idPrefix, itemId)
        {
            // if there is no parent window do nothing
            if (window.parent === '') {
                return;
            }

            // search for the handler of the current window
            jQuery.each(window.parent.relationHandler, function (key, singleRelationHandler) {
                var selector, searchTerm;

                // look if this handler is the right one
                if (singleRelationHandler.prefix === idPrefix) {
                    // show a message
                    window.parent.«vendorAndName»SimpleAlert(window.parent.jQuery('.«vendorAndName.toLowerCase»-edit-form').first(), window.parent.Translator.__('Information'), window.parent.Translator.__('Action has been completed.'), 'actionDoneAlert', 'success');

                    // check if a new item has been created
                    if (itemId > 0) {
                        // look whether there is an auto completion instance
                        if (null !== singleRelationHandler.acInstance) {
                            // activate it
                            selector = window.parent.jQuery('#' + idPrefix.replace('DoNew', '')).first();
                            searchTerm = selector.val();
                            selector.autocomplete('search', searchTerm);
                        }
                    }
                    // look whether there is a windows instance
                    if (null !== singleRelationHandler.windowInstanceId) {
                        // close it
                        window.parent.jQuery('#' + singleRelationHandler.windowInstanceId).dialog('close');
                    }
                }
            });
        }
    '''
}
