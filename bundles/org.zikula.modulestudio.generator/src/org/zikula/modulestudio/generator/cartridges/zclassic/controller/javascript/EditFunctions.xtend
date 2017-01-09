package org.zikula.modulestudio.generator.cartridges.zclassic.controller.javascript

import de.guite.modulestudio.metamodel.AbstractDateField
import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class EditFunctions {

    extension FormattingExtensions = new FormattingExtensions
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

        «initUserField»

        «IF hasUploads»
            «resetUploadField»

            «initUploadField»

        «ENDIF»
        «IF !entities.filter[!getDerivedFields.filter(AbstractDateField).empty].empty»
            «resetDateField»

            «initDateField»

        «ENDIF»
        «initEditForm»

        «relationshipFunctions»
    '''

    def private initUserField(Application it) '''
        «IF hasUserFields»
            /**
             * Initialises a user field with auto completion.
             */
            function «vendorAndName»InitUserField(fieldName, getterName)
            {
                if (jQuery('#' + fieldName + 'LiveSearch').length < 1) {
                    return;
                }
                jQuery('#' + fieldName + 'LiveSearch').removeClass('hidden');

                jQuery('#' + fieldName + 'Selector').typeahead({
                    highlight: true,
                    hint: true,
                    minLength: 2
                }, {
                    limit: 15,
                    // The data source to query against. Receives the query value in the input field and the process callbacks.
                    source: function (query, syncResults, asyncResults) {
                        // Retrieve data from server using "query" parameter as it contains the search string entered by the user
                        jQuery('#' + fieldName + 'Indicator').removeClass('hidden');
                        jQuery.getJSON(Routing.generate('«appName.formatForDB»_ajax_' + getterName.toLowerCase(), { fragment: query }), function( data ) {
                            jQuery('#' + fieldName + 'Indicator').addClass('hidden');
                            asyncResults(data);
                        });
                    },
                    templates: {
                        empty: '<div class="empty-message">' + jQuery('#' + fieldName + 'NoResultsHint').text() + '</div>',
                        suggestion: function(user) {
                            var html;

                            html = '<div class="typeahead">';
                            html += '<div class="media"><a class="pull-left" href="javascript:void(0)">' + user.avatar + '</a>';
                            html += '<div class="media-body">';
                            html += '<p class="media-heading">' + user.uname + '</p>';
                            html += '</div>';
                            html += '</div>';

                            return html;
                        }
                    }
                }).bind('typeahead:select', function(ev, user) {
                    // Called after the user selects an item. Here we can do something with the selection.
                    jQuery('#' + fieldName).val(user.uid);
                    jQuery(this).typeahead('val', user.uname);
                });
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
                event.stopPropagation();
                «vendorAndName»ResetUploadField(fieldName);
            }).removeClass('hidden');
        }
    '''

    def private resetDateField(Application it) '''
        /**
         * Resets the value of a date or datetime input field.
         */
        function «vendorAndName»ResetDateField(fieldName)
        {
            jQuery('#' + fieldName).val('');
            jQuery('#' + fieldName + 'cal').html(Translator.__('No date set.'));
        }
    '''

    def private initDateField(Application it) '''
        /**
         * Initialises the reset button for a certain date input.
         */
        function «vendorAndName»InitDateField(fieldName)
        {
            jQuery('#' + fieldName + 'ResetVal').click( function (event) {
                event.stopPropagation();
                «vendorAndName»ResetDateField(fieldName);
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
         * For edit forms we use "iframe: true" to ensure file uploads work without problems.
         * For all other windows we use "iframe: false" because we want the escape key working.
         */
        function «vendorAndName»CreateRelationWindowInstance(containerElem, useIframe)
        {
            var newWindowId;

            // define the new window instance
            newWindowId = containerElem.attr('id') + 'Dialog';
            jQuery('<div id="' + newWindowId + '"></div>')
                .append(jQuery('<iframe«/* width="100%" height="100%" marginWidth="0" marginHeight="0" frameBorder="0" scrolling="auto"*/» />').attr('src', containerElem.attr('href')))
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
            relationHandler.each(function (relationHandler) {
                // is this the right one
                if (relationHandler.prefix === containerID) {
                    // yes, it is
                    found = true;
                    // look whether there is already a window instance
                    if (null !== relationHandler.windowInstance) {
                        // unset it
                        jQuery(containerID + 'Dialog').dialog('destroy');
                    }
                    // create and assign the new window instance
                    relationHandler.windowInstanceId = «vendorAndName»CreateRelationWindowInstance(jQuery('#' + containerID), true);
                }
            });

            // if no handler was found
            if (false === found) {
                // create a new one
                newItem = new Object();
                newItem.ot = objectType;
                newItem.alias = '«/* TODO provide alias for relation window instance handler */»';
                newItem.prefix = containerID;
                newItem.acInstance = null;
                newItem.windowInstanceId = «vendorAndName»CreateRelationWindowInstance(jQuery('#' + containerID), true);

                // add it to the list of handlers
                relationHandler.push(newItem);
            }
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
        function «vendorAndName»SelectRelatedItem(objectType, idPrefix, inputField, selectedListItem)
        {
            var newItemId, newTitle, includeEditing, editLink, removeLink, elemPrefix, itemPreview, li, editHref, fldPreview, itemIds, itemIdsArr;

            newItemId = selectedListItem.id;
            newTitle = jQuery('#' + idPrefix + 'Selector').val();
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

                jQuery('#' + elemPrefix + 'Edit').click( function (e) {
                    «vendorAndName»InitInlineRelationWindow(objectType, idPrefix + 'Reference_' + newItemId + 'Edit');
                    e.stopPropagation();
                });
            }
            removeLink.html(' ' + removeImage);

            itemIds = jQuery('#' + idPrefix).val();
            if (itemIds !== '') {
                if (jQuery('#' + idPrefix + 'Scope').val() === '0') {
                    itemIdsArr = itemIds.split(',');
                    itemIdsArr.each(function (existingId) {
                        if (existingId) {
                            «vendorAndName»RemoveRelatedItem(idPrefix, existingId);
                        }
                    });
                    itemIds = '';
                } else {
                    itemIds += ',';
                }
            }
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

            // add handling for the toggle link if existing
            jQuery('#' + idPrefix + 'AddLink').click( function (e) {
                «vendorAndName»ToggleRelatedItemForm(idPrefix);
            });

            // add handling for the cancel button
            jQuery('#' + idPrefix + 'SelectorDoCancel').click( function (e) {
                «vendorAndName»ResetRelatedItemForm(idPrefix);
            });

            // clear values and ensure starting state
            «vendorAndName»ResetRelatedItemForm(idPrefix);

            acOptions = {
                highlight: true,
                hint: true,
                minLength: 2,
            };
            acDataSet = {
                limit: 15,
                // The data source to query against. Receives the query value in the input field and the process callbacks.
                source: function (query, syncResults, asyncResults) {
                    // Retrieve data from server using "query" parameter as it contains the search string entered by the user
                    jQuery('#' + idPrefix + 'Indicator').removeClass('hidden');
                    jQuery.getJSON(acUrl, { fragment: query }, function( data ) {
                        jQuery('#' + idPrefix + 'Indicator').addClass('hidden');
                        asyncResults(data);
                    });
                },
                templates: {
                    empty: '<div class="empty-message">' + jQuery('#' + idPrefix + 'NoResultsHint').text() + '</div>',
                    suggestion: function(item) {
                        var html;

                        html = '<div class="typeahead">';
                        html += '<div class="media"><a class="pull-left" href="javascript:void(0)">' + item.image + '</a>';
                        html += '<div class="media-body">';
                        html += '<p class="media-heading">' + item.title + '</p>';
                        html += item.description;
                        html += '</div>';
                        html += '</div>';

                        return html;
                    }
                }
            };

            relationHandler.each(function (key, relationHandler) {
                if (relationHandler.prefix === (idPrefix + 'SelectorDoNew') && null === relationHandler.acInstance) {
                    relationHandler.acInstance = 'yes';

                    acUrl = Routing.generate(relationHandler.moduleName.toLowerCase() + '_ajax_getitemlistautocompletion');
                    acUrl += '&ot=' + objectType;
                    if (jQuery('#' + idPrefix).length > 0) {
                        acUrl += '&exclude=' + jQuery('#' + idPrefix).val();
                    }

                    jQuery('#' + idPrefix + 'Selector')
                        .typeahead(acOptions, acDataSet)
                        .bind('typeahead:select', function(ev, item) {
                            // Called after the user selects an item. Here we can do something with the selection.
                            «vendorAndName»SelectRelatedItem(objectType, idPrefix, jQuery('#' + idPrefix), item);
                            jQuery(this).typeahead('val', item.title);
                        });

                    // Ensure that clearing out the selector is properly reflected into the hidden field
                    jQuery('#' + idPrefix + 'Selector').blur(function() {
                        if (jQuery(this).val().length == 0 || jQuery('#' + idPrefix).val() != listItemMap[idPrefix][jQuery(this).val()]) {
                            jQuery('#' + idPrefix).val('');
                        }
                    });
                }
            });

            if (!includeEditing || jQuery('#' + idPrefix + 'SelectorDoNew').length < 1) {
                return;
            }

            // from here inline editing will be handled
            jQuery('#' + idPrefix + 'SelectorDoNew').href += '&theme=Printer&idp=' + idPrefix + 'SelectorDoNew';
            jQuery('#' + idPrefix + 'SelectorDoNew').click( function(e) {
                «vendorAndName»InitInlineRelationWindow(objectType, idPrefix + 'SelectorDoNew');
                e.stopPropagation();
            });

            itemIds = jQuery('#' + idPrefix).val();
            itemIdsArr = itemIds.split(',');
            itemIdsArr.each(function (existingId) {
                var elemPrefix;

                if (existingId) {
                    elemPrefix = idPrefix + 'Reference_' + existingId + 'Edit';
                    jQuery('#' + elemPrefix).href += '&theme=Printer&idp=' + elemPrefix;
                    jQuery('#' + elemPrefix).click( function (event) {
                        «vendorAndName»InitInlineRelationWindow(objectType, elemPrefix);
                        event.stopPropagation();
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
            window.parent.relationHandler.each(function (relationHandler) {
                // look if this handler is the right one
                if (relationHandler['prefix'] === idPrefix) {
                    // do we have an item created
                    if (itemId > 0) {
                        // look whether there is an auto completion instance
                        if (null !== relationHandler.acInstance) {
                            // activate it
                            jQuery('#' + idPrefix + 'Selector').lookup();
                            // show a message
                            «vendorAndName»SimpleAlert(jQuery('.«appName.toLowerCase»-form'), Translator.__('Information'), Translator.__('Action has been completed.'), 'actionDoneAlert', 'success');
                        }
                    }
                    // look whether there is a windows instance
                    if (null !== relationHandler.windowInstance) {
                        // close it
                        relationHandler.windowInstance.closeHandler();
                    }
                }
            });
        }
    '''
}
