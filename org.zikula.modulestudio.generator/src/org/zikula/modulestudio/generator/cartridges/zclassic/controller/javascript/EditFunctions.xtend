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
    extension ModelExtensions = new ModelExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelJoinExtensions = new ModelJoinExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    /**
     * Entry point for the JavaScript file with edit functionality.
     */
    def generate(Application it, IFileSystemAccess fsa) {
        var fileName = ''
        if (targets('1.3.x')) {
            fileName = appName + '_editFunctions.js'
        } else {
            fileName = appName + '.EditFunctions.js'
        }
        if (!shouldBeSkipped(getAppJsPath + fileName)) {
            println('Generating JavaScript for edit functions')
            if (shouldBeMarked(getAppJsPath + fileName)) {
                if (targets('1.3.x')) {
                    fileName = appName + '_editFunctions.generated.js'
                } else {
                    fileName = appName + '.EditFunctions.generated.js'
                }
            }
            fsa.generateFile(getAppJsPath + fileName, generate)
        }
    }

    def private generate(Application it) '''
        'use strict';

        «relationFunctionsPreparation»
        «initUserField»

        «IF hasUploads»
            «resetUploadField»

            «initUploadField»

        «ENDIF»
        «IF !entities.filter[!getDerivedFields.filter(AbstractDateField).empty].empty»
            «resetDateField»

            «initDateField»

        «ENDIF»
        «IF hasGeographical»
            «initGeoCoding»

        «ENDIF»
        «relationFunctions»
    '''

    def private initUserField(Application it) '''
        «IF hasUserFields»
            /**
             * Initialises a user field with auto completion.
             */
            function «vendorAndName»InitUserField(fieldName, getterName)
            {
                «IF !targets('1.3.x')»
                    var users, userMap;

                «ENDIF»
                «IF targets('1.3.x')»
                    if ($(fieldName + 'LiveSearch') === null) {
                        return;
                    }
                    $(fieldName + 'LiveSearch').removeClassName('z-hide');
                «ELSE»
                    if ($('#' + fieldName + 'LiveSearch').length < 1) {
                        return;
                    }
                    $('#' + fieldName + 'LiveSearch').removeClass('hidden');
                «ENDIF»

                «IF targets('1.3.x')»
                    new Ajax.Autocompleter(
                        fieldName + 'Selector',
                        fieldName + 'SelectorChoices',
                        Zikula.Config.baseURL + 'ajax.php?module=«appName»&func=' + getterName,
                        {
                            paramName: 'fragment',
                            minChars: 3,
                            indicator: fieldName + 'Indicator',
                            afterUpdateElement: function (inputField, selectedListItem) {
                                var itemId = selectedListItem.id;
                                var userId = itemId.replace('user', '');
                                $(fieldName).value = userId;
                            }
                        }
                    );
                «ELSE»
                    users = [];
                    userMap = [];

                    $('#' + fieldName + 'Selector').typeahead({
                        items: 25,
                        minLength: 2,
                        showHintOnFocus: true,
                        scrollHeight: 400,

                        // The data source to query against. Receives the query value in the input field and the process callback.
                        source: function (query, process) {
                            users[fieldName] = [];
                            userMap[fieldName] = {};

                            // Retrieve data from server using "query" parameter as it contains the search string entered by the user
                            $('#' + fieldName + 'Indicator').removeClass('hidden')
                            $.getJSON( Routing.generate('«appName.formatForDB»_ajax_' + getterName.toLowerCase(), { fragment: query }), function( data ) {

                                if (data.length > 0) {
                                    $('#' + idPrefix + 'NoResultsHint').addClass('hidden');

                                    // map dropdown options to corresponding objects
                                    $.each(data, function (key, user) {
                                        userMap[fieldName][user.uname] = user;
                                        users[fieldName].push(user.uname);
                                    });
                                } else {
                                    $('#' + idPrefix + 'NoResultsHint').removeClass('hidden');
                                }

                                $('#' + fieldName + 'Indicator').addClass('hidden')
                            });

                            // call process() function with dropdown array
                            return process(users[fieldName]);
                        },

                        // custom formatting of result items
                        highlighter: function(item) {
                            var html, user;

                            user = userMap[fieldName][item];

                            html = '<div class="typeahead">';
                            html += '<div class="media"><a class="pull-left" href="#"><img src="' + user.avatar + '" /></a>'
                            html += '<div class="media-body">';
                            html += '<p class="media-heading">' + user.uname + '</p>';
                            html += '</div>';
                            html += '</div>';

                            return html;
                        },

                        // Called after the user selects an item. Here we can do something with the selection.
                        updater: function (item) {
                            var userId;

                            userId = userMap[fieldName][item].uid;

                            $('#' + fieldName).val(userId);

                            return item;
                        }
                    });

                    // Ensure that clearing out the selector is reflected into the hidden field properly
                    $('#' + fieldName + 'Selector').blur(function() {
                        if ($(this).val().length == 0 || $('#' + fieldName).val() != userMap[fieldName][$(this).val()]) {
                            $('#' + fieldName).val('');
                        }
                    });
                «ENDIF»
            }

        «ENDIF»
    '''

    def private resetUploadField(Application it) '''
        /**
         * Resets the value of an upload / file input field.
         */
        function «vendorAndName»ResetUploadField(fieldName)
        {
            «IF targets('1.3.x')»
                if ($(fieldName) != null) {
                    $(fieldName).setAttribute('type', 'input');
                    $(fieldName).setAttribute('type', 'file');
                }
            «ELSE»
                if ($('#' + fieldName).size() > 0) {
                    $('#' + fieldName).attr('type', 'input');
                    $('#' + fieldName).attr('type', 'file');
                }
            «ENDIF»
        }
    '''

    def private initUploadField(Application it) '''
        /**
         * Initialises the reset button for a certain upload input.
         */
        function «vendorAndName»InitUploadField(fieldName)
        {
            var fieldNameCapitalised;

            fieldNameCapitalised = fieldName.charAt(0).toUpperCase() + fieldName.substring(1);
            «IF targets('1.3.x')»
                if ($('reset' + fieldNameCapitalised + 'Val') != null) {
                    $('reset' + fieldNameCapitalised + 'Val').observe('click', function (evt) {
                        evt.preventDefault();
                        «vendorAndName»ResetUploadField(fieldName);
                    }).removeClassName('z-hide').setStyle({ display: 'block' });
                }
            «ELSE»
                if ($('#reset' + fieldNameCapitalised + 'Val').size() > 0) {
                    $('#reset' + fieldNameCapitalised + 'Val').click( function (evt) {
                        event.stopPropagation();
                        «vendorAndName»ResetUploadField(fieldName);
                    }).removeClass('hidden');
                }
            «ENDIF»
        }
    '''

    def private resetDateField(Application it) '''
        /**
         * Resets the value of a date or datetime input field.
         */
        function «vendorAndName»ResetDateField(fieldName)
        {
            «IF targets('1.3.x')»
                if ($(fieldName) != null) {
                    $(fieldName).value = '';
                }
                if ($(fieldName + 'cal') != null) {
                    $(fieldName + 'cal').update(Zikula.__('No date set.', 'module_«appName.formatForDB»_js'));
                }
            «ELSE»
                if ($('#' + fieldName).size() > 0) {
                    $('#' + fieldName).val('');
                }
                if ($('#' + fieldName + 'cal').size() > 0) {
                    $('#' + fieldName + 'cal').html(Zikula.__('No date set.', '«appName.formatForDB»_js'));
                }
            «ENDIF»
        }
    '''

    def private initDateField(Application it) '''
        /**
         * Initialises the reset button for a certain date input.
         */
        function «vendorAndName»InitDateField(fieldName)
        {
            var fieldNameCapitalised;

            fieldNameCapitalised = fieldName.charAt(0).toUpperCase() + fieldName.substring(1);
            «IF targets('1.3.x')»
                if ($('reset' + fieldNameCapitalised + 'Val') != null) {
                    $('reset' + fieldNameCapitalised + 'Val').observe('click', function (evt) {
                        evt.preventDefault();
                        «vendorAndName»ResetDateField(fieldName);
                    }).removeClassName('z-hide').setStyle({ display: 'block' });
                }
            «ELSE»
                if ($('#reset' + fieldNameCapitalised + 'Val').size() > 0) {
                    $('#reset' + fieldNameCapitalised + 'Val').click( function (evt) {
                        event.stopPropagation();
                        «vendorAndName»ResetDateField(fieldName);
                    }).removeClass('hidden');
                }
            «ENDIF»
        }
    '''

    def private initGeoCoding(Application it) '''
        /**
         * Example method for initialising geo coding functionality in JavaScript.
         * In contrast to the map picker this one determines coordinates for a given address.
         * Uses a callback function for retrieving the address to be converted, so that it can be easily customised in each edit template.
         * There is also a method on PHP level available in the \«IF targets('1.3.x')»«appName»_Util_Controller«ELSE»«vendor.formatForCodeCapital»\«name.formatForCodeCapital»Module\Util\ControllerUtil«ENDIF» class.
         */
        function «vendorAndName»InitGeoCoding(addressCallback)
        {
            «IF targets('1.3.x')»
                $('linkGetCoordinates').observe('click', function (evt) {
                    «vendorAndName»DoGeoCoding(addressCallback);
                });
            «ELSE»
                $('#linkGetCoordinates').click( function (evt) {
                    «vendorAndName»DoGeoCoding(addressCallback);
                });
            «ENDIF»
        }

        /**
         * Performs the actual geo coding using Mapstraction.
         */
        function «vendorAndName»DoGeoCoding(addressCallback)
        {
            «IF targets('1.3.x')»
                var address = {
                    address : $F('street') + ' ' + $F('houseNumber') + ' ' + $F('zipcode') + ' ' + $F('city') + ' ' + $F('country')
                };
            «ELSE»
                var address = {
                    address : $('#street').val() + ' ' + $('#houseNumber').val() + ' ' + $('#zipcode').val() + ' ' + $('#city').val() + ' ' + $('#country').val()
                };
            «ENDIF»

            // Check whether the given callback is executable
            if (typeof addressCallback !== 'function') {
                address = addressCallback();
            }

            var geocoder = new mxn.Geocoder('googlev3', «vendorAndName»GeoCodeReturn, «vendorAndName»GeoCodeErrorCallback);
            geocoder.geocode(address);

            function «vendorAndName»GeoCodeErrorCallback (status) {
                «IF targets('1.3.x')»
                    Zikula.UI.Alert(Zikula.__('Error during geocoding:', 'module_«appName.formatForDB»_js') + ' ' + status);
                «ELSE»
                    «vendorAndName»SimpleAlert($('#mapContainer'), Zikula.__('Error during geocoding', '«appName.formatForDB»_js'), status, 'geoCodingAlert', 'danger');
                «ENDIF»
            }

            function «vendorAndName»GeoCodeReturn (location) {
                «IF targets('1.3.x')»
                    Form.Element.setValue('latitude', location.point.lat.toFixed(4));
                    Form.Element.setValue('longitude', location.point.lng.toFixed(4));
                «ELSE»
                    $('#latitude').val(location.point.lat.toFixed(7));
                    $('#longitude').val(location.point.lng.toFixed(7));
                «ENDIF»
                newCoordinatesEventHandler();
            }
        }
    '''

    def private relationFunctionsPreparation(Application it) '''
        «IF !getJoinRelations.empty && targets('1.3.x')»

            /**
             * Override method of Scriptaculous auto completer method.
             * Purpose: better feedback if no results are found (#247).
             * See http://stackoverflow.com/questions/657839/scriptaculous-ajax-autocomplete-empty-response for more information.
             */
            Ajax.Autocompleter.prototype.updateChoices = function (choices)
            {
                if (!this.changed && this.hasFocus) {
                    if (!choices || choices == '<ul></ul>') {
                        this.stopIndicator();
                        var idPrefix = this.options.indicator.replace('Indicator', '');
                        if ($(idPrefix + 'NoResultsHint') != null) {
                            $(idPrefix + 'NoResultsHint').removeClassName('«IF targets('1.3.x')»z-hide«ELSE»hidden«ENDIF»');
                        }
                    } else {
                        this.update.innerHTML = choices;
                        Element.cleanWhitespace(this.update);
                        Element.cleanWhitespace(this.update.down());

                        if (this.update.firstChild && this.update.down().childNodes) {
                            this.entryCount = this.update.down().childNodes.length;
                            for (var i = 0; i < this.entryCount; i++) {
                                var entry = this.getEntry(i);
                                entry.autocompleteIndex = i;
                                this.addObservers(entry);
                            }
                        } else {
                            this.entryCount = 0;
                        }

                        this.stopIndicator();
                        this.index = 0;

                        if (this.entryCount == 1 && this.options.autoSelect) {
                            this.selectEntry();
                            this.hide();
                        } else {
                            this.render();
                        }
                    }
                }
            }
        «ENDIF»
    '''

    def private relationFunctions(Application it) '''
        «IF !getJoinRelations.empty»
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
            «IF targets('1.3.x')»
                // if we don't have a toggle link do nothing
                if ($(idPrefix + 'AddLink') === null) {
                    return;
                }

                // show/hide the toggle link
                $(idPrefix + 'AddLink').toggleClassName('z-hide');

                // hide/show the fields
                $(idPrefix + 'AddFields').toggleClassName('z-hide');
            «ELSE»
                // if we don't have a toggle link do nothing
                if ($('#' + idPrefix + 'AddLink').size() < 1) {
                    return;
                }

                // show/hide the toggle link
                $('#' + idPrefix + 'AddLink').toggleClass('hidden');

                // hide/show the fields
                $('#' + idPrefix + 'AddFields').toggleClass('hidden');
            «ENDIF»
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
            «IF targets('1.3.x')»
                $(idPrefix + 'Selector').value = '';
            «ELSE»
                $('#' + idPrefix + 'Selector').val('');
            «ENDIF»
        }
    '''

    def private createRelationWindowInstance(Application it) '''
        /**
         * Helper function to create new «IF targets('1.3.x')»Zikula.UI.Window«ELSE»modal form dialog«ENDIF» instances.
         * For edit forms we use "iframe: true" to ensure file uploads work without problems.
         * For all other windows we use "iframe: false" because we want the escape key working.
         */
        function «vendorAndName»CreateRelationWindowInstance(containerElem, useIframe)
        {
            var newWindow«IF !targets('1.3.x')»Id«ENDIF»;

            // define the new window instance
            «IF targets('1.3.x')»
                newWindow = new Zikula.UI.Window(
                    containerElem,
                    {
                        minmax: true,
                        resizable: true,
                        //title: containerElem.title,
                        width: 600,
                        initMaxHeight: 500,
                        modal: false,
                        iframe: useIframe
                    }
                );

                // open it
                newWindow.openHandler();
            «ELSE»
                newWindowId = containerElem.attr('id') + 'Dialog';
                $('<div id="' + newWindowId + "></div>')
                    .append($('<iframe«/* width="100%" height="100%" marginWidth="0" marginHeight="0" frameBorder="0" scrolling="auto"*/» />').attr('src', containerElem.attr('href')))
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
            «ENDIF»

            // return the instance
            return newWindow«IF !targets('1.3.x')»Id«ENDIF»;
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
                    if (relationHandler.windowInstance !== null) {
                        // unset it
                        «IF targets('1.3.x')»
                            relationHandler.windowInstance.destroy();
                        «ELSE»
                            $(containerID + 'Dialog').dialog('destroy');
                        «ENDIF»
                    }
                    // create and assign the new window instance
                    relationHandler.windowInstance«IF !targets('1.3.x')»Id«ENDIF» = «vendorAndName»CreateRelationWindowInstance($(«IF !targets('1.3.x')»'#' + «ENDIF»containerID), true);
                }
            });

            // if no handler was found
            if (found === false) {
                // create a new one
                newItem = new Object();
                newItem.ot = objectType;
                newItem.alias = '«/*TODO*/»';
                newItem.prefix = containerID;
                newItem.acInstance = null;
                newItem.windowInstance«IF !targets('1.3.x')»Id«ENDIF» = «vendorAndName»CreateRelationWindowInstance($(«IF !targets('1.3.x')»'#' + «ENDIF»containerID), true);

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

            «IF targets('1.3.x')»
                itemIds = $F(idPrefix + 'ItemList');
            «ELSE»
                itemIds = $('#' + idPrefix + 'ItemList').val();
            «ENDIF»
            itemIdsArr = itemIds.split(',');

            «IF targets('1.3.x')»
                itemIdsArr = itemIdsArr.without(removeId);
            «ELSE»
                itemIdsArr = $.grep(itemIdsArr, function(value) {
                    return value != removeId;
                });
            «ENDIF»

            itemIds = itemIdsArr.join(',');

            «IF targets('1.3.x')»
                $(idPrefix + 'ItemList').value = itemIds;
                $(idPrefix + 'Reference_' + removeId).remove();
            «ELSE»
                $('#' + idPrefix + 'ItemList').val(itemIds);
                $('#' + idPrefix + 'Reference_' + removeId).remove();
            «ENDIF»
        }
    '''

    def private selectRelatedItem(Application it) '''
        /**
         * Adds a related item to selection which has been chosen by auto completion.
         */
        function «vendorAndName»SelectRelatedItem(objectType, idPrefix, inputField, selectedListItem)
        {
            var newItemId, newTitle, includeEditing, editLink, removeLink, elemPrefix, itemPreview, li, editHref, fldPreview, itemIds, itemIdsArr;

            «IF targets('1.3.x')»
                newItemId = selectedListItem.id;
                newTitle = $F(idPrefix + 'Selector');
                includeEditing = !!(($F(idPrefix + 'Mode') == '1'));
            «ELSE»
                newItemId = selectedListItem.id;
                newTitle = $('#' + idPrefix + 'Selector').val();
                includeEditing = !!(($('#' + idPrefix + 'Mode').val() == '1'));
            «ENDIF»
            elemPrefix = idPrefix + 'Reference_' + newItemId;
            itemPreview = '';

            «IF targets('1.3.x')»
                if ($('itemPreview' + selectedListItem.id) !== null) {
                    itemPreview = $('itemPreview' + selectedListItem.id).innerHTML;
                }
            «ELSE»
                if (selectedListItem.image != '') {
                    itemPreview = selectedListItem.image;
                }
            «ENDIF»

            «IF targets('1.3.x')»
                var li = Builder.node('li', {id: elemPrefix}, newTitle);
                if (includeEditing === true) {
                    var editHref = $(idPrefix + 'SelectorDoNew').href + '&id=' + newItemId;
                    editLink = Builder.node('a', {id: elemPrefix + 'Edit', href: editHref}, 'edit');
                    li.appendChild(editLink);
                }
                removeLink = Builder.node('a', {id: elemPrefix + 'Remove', href: 'javascript:«vendorAndName»RemoveRelatedItem(\'' + idPrefix + '\', ' + newItemId + ');'}, 'remove');
                li.appendChild(removeLink);
                if (itemPreview !== '') {
                    fldPreview = Builder.node('div', {id: elemPrefix + 'preview', name: idPrefix + 'preview'}, '');
                    fldPreview.update(itemPreview);
                    li.appendChild(fldPreview);
                    itemPreview = '';
                }
                $(idPrefix + 'ReferenceList').appendChild(li);
            «ELSE»
                var li = $('<li>', {id: elemPrefix, text: newTitle});
                if (includeEditing === true) {
                    var editHref = $('#' + idPrefix + 'SelectorDoNew').attr('href') + '&id=' + newItemId;
                    editLink = $('<a>', {id: elemPrefix + 'Edit', href: editHref, text: 'edit'});
                    li.append(editLink);
                }
                removeLink = $('<a>', {id: elemPrefix + 'Remove', href: 'javascript:«vendorAndName»RemoveRelatedItem(\'' + idPrefix + '\', ' + newItemId + ');', text: 'remove'});
                li.append(removeLink);
                if (itemPreview !== '') {
                    fldPreview = $('<div>', {id: elemPrefix + 'preview', name: idPrefix + 'preview'});
                    fldPreview.html(itemPreview);
                    li.append(fldPreview);
                    itemPreview = '';
                }
                $('#' + idPrefix + 'ReferenceList').append(li);
            «ENDIF»

            if (includeEditing === true) {
                «IF targets('1.3.x')»
                    editLink.update(' ' + editImage);
                «ELSE»
                    editLink.html(' ' + editImage);
                «ENDIF»

                «IF targets('1.3.x')»
                    $(elemPrefix + 'Edit').observe('click', function (e) {
                        «vendorAndName»InitInlineRelationWindow(objectType, idPrefix + 'Reference_' + newItemId + 'Edit');
                        e.stop();
                    });
                «ELSE»
                    $('#' + elemPrefix + 'Edit').click( function (e) {
                        «vendorAndName»InitInlineRelationWindow(objectType, idPrefix + 'Reference_' + newItemId + 'Edit');
                        e.stopPropagation();
                    });
                «ENDIF»
            }
            «IF targets('1.3.x')»
                removeLink.update(' ' + removeImage);
            «ELSE»
                removeLink.html(' ' + removeImage);
            «ENDIF»

            «IF targets('1.3.x')»
                itemIds = $F(idPrefix + 'ItemList');
                if (itemIds !== '') {
                    if ($F(idPrefix + 'Scope') === '0') {
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
                $(idPrefix + 'ItemList').value = itemIds;
            «ELSE»
                itemIds = $('#' + idPrefix + 'ItemList').val();
                if (itemIds !== '') {
                    if ($('#' + idPrefix + 'Scope').val() === '0') {
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
                $('#' + idPrefix + 'ItemList').val(itemIds);
            «ENDIF»

            «vendorAndName»ResetRelatedItemForm(idPrefix);
        }
    '''

    def private initRelatedItemsForm(Application it) '''
        /**
         * Initialise a relation field section with autocompletion and optional edit capabilities
         */
        function «vendorAndName»InitRelationItemsForm(objectType, idPrefix, includeEditing)
        {
            var acOptions, itemIds, itemIdsArr«IF !targets('1.3.x')», listItems, listItemMap, acUrl«ENDIF»;

            «IF targets('1.3.x')»
                // add handling for the toggle link if existing
                if ($(idPrefix + 'AddLink') !== null) {
                    $(idPrefix + 'AddLink').observe('click', function (e) {
                        «vendorAndName»ToggleRelatedItemForm(idPrefix);
                    });
                }
                // add handling for the cancel button
                if ($(idPrefix + 'SelectorDoCancel') !== null) {
                    $(idPrefix + 'SelectorDoCancel').observe('click', function (e) {
                        «vendorAndName»ResetRelatedItemForm(idPrefix);
                    });
                }
            «ELSE»
                // add handling for the toggle link if existing
                if ($('#' + idPrefix + 'AddLink').size() > 0) {
                    $('#' + idPrefix + 'AddLink').click( function (e) {
                        «vendorAndName»ToggleRelatedItemForm(idPrefix);
                    });
                }
                // add handling for the cancel button
                if ($('#' + idPrefix + 'SelectorDoCancel').size() > 0) {
                    $('#' + idPrefix + 'SelectorDoCancel').click( function (e) {
                        «vendorAndName»ResetRelatedItemForm(idPrefix);
                    });
                }
            «ENDIF»
            // clear values and ensure starting state
            «vendorAndName»ResetRelatedItemForm(idPrefix);

            «IF targets('1.3.x')»
                acOptions = {
                    paramName: 'fragment',
                    minChars: 2,
                    indicator: idPrefix + 'Indicator',
                    callback: function (inputField, defaultQueryString) {
                        var queryString;

                        // modify the query string before the request
                        queryString = defaultQueryString + '&ot=' + objectType;
                        if ($(idPrefix + 'ItemList') !== null) {
                            queryString += '&exclude=' + $F(idPrefix + 'ItemList');
                        }

                        if ($(idPrefix + 'NoResultsHint') != null) {
                            $(idPrefix + 'NoResultsHint').addClassName('z-hide');
                        }

                        return queryString;
                    },
                    afterUpdateElement: function (inputField, selectedListItem) {
                        // Called after the input element has been updated (i.e. when the user has selected an entry).
                        // This function is called after the built-in function that adds the list item text to the input field.
                        «vendorAndName»SelectRelatedItem(objectType, idPrefix, inputField, selectedListItem);
                    }
                };
                relationHandler.each(function (relationHandler) {
                    if (relationHandler.prefix === (idPrefix + 'SelectorDoNew') && relationHandler.acInstance === null) {
                        relationHandler.acInstance = new Ajax.Autocompleter(
                            idPrefix + 'Selector',
                            idPrefix + 'SelectorChoices',
                            Zikula.Config.baseURL + 'ajax.php?module=' + relationHandler.moduleName + '&func=getItemListAutoCompletion',
                            acOptions
                        );
                    }
                });
            «ELSE»
                listItems = [];
                listItemMap = [];

                acOptions = {
                    items: 25,
                    minLength: 2,
                    showHintOnFocus: true,
                    scrollHeight: 400,

                    // The data source to query against. Receives the query value in the input field and the process callback.
                    source: function (query, process) {
                        listItems[idPrefix] = [];
                        listItemMap[idPrefix] = {};

                        // Retrieve data from server using "query" parameter as it contains the search string entered by the user
                        $('#' + idPrefix + 'Indicator').removeClass('hidden')
                        $.getJSON( acUrl, { fragment: query }), function( data ) {

                            if (data.length > 0) {
                                $('#' + idPrefix + 'NoResultsHint').addClass('hidden');

                                // map dropdown options to corresponding objects
                                $.each(data, function (key, listItem) {
                                    listItemMap[idPrefix][listItem.title] = listItem;
                                    listItems[idPrefix].push(listItem.title);
                                });
                            } else {
                                $('#' + idPrefix + 'NoResultsHint').removeClass('hidden');
                            }

                            $('#' + idPrefix + 'Indicator').addClass('hidden')
                        });

                        // call process() function with dropdown array
                        return process(listItems[idPrefix]);
                    },

                    // custom formatting of result items
                    highlighter: function(item) {
                        var html, listItem;

                        listItem = listItemMap[idPrefix][item];

                        html = '<div class="typeahead">';
                        html += '<div class="media"><a class="pull-left" href="#"><img src="' + listItem.image + '" /></a>'
                        html += '<div class="media-body">';
                        html += '<p class="media-heading">' + listItem.title + '</p>';
                        html += listItem.description;
                        html += '</div>';
                        html += '</div>';

                        return html;
                    },

                    // Called after the user selects an item. Here we can do something with the selection.
                    updater: function (item) {
                        var inputField, listItem;

                        inputField = $('#' + idPrefix);
                        listItem = listItemMap[idPrefix][item];

                        «vendorAndName»SelectRelatedItem(objectType, idPrefix, inputField, listItem);
                        inputField.val(listItemId);

                        return item;
                    }
                };

                relationHandler.each(function (key, relationHandler) {
                    if (relationHandler.prefix === (idPrefix + 'SelectorDoNew') && relationHandler.acInstance === null) {
                        relationHandler.acInstance = 'yes';

                        acUrl = Routing.generate(relationHandler.moduleName.toLowerCase() + '_ajax_getitemlistautocompletion');
                        acUrl += '&ot=' + objectType;
                        if ($('#' + idPrefix + 'ItemList').size() > 0) {
                            acUrl += '&exclude=' + $('#' + idPrefix + 'ItemList').val();
                        }

                        $('#' + idPrefix + 'Selector').typeahead(acOptions);

                        // Ensure that clearing out the selector is reflected into the hidden field properly
                        $('#' + idPrefix + 'Selector').blur(function() {
                            if ($(this).val().length == 0 || $('#' + idPrefix).val() != listItemMap[idPrefix][$(this).val()]) {
                                $('#' + idPrefix).val('');
                            }
                        });
                    }
                });
            «ENDIF»

            «IF targets('1.3.x')»
                if (!includeEditing || $(idPrefix + 'SelectorDoNew') === null) {
                    return;
                }
            «ELSE»
                if (!includeEditing || $('#' + idPrefix + 'SelectorDoNew').size() < 1) {
                    return;
                }
            «ENDIF»

            // from here inline editing will be handled
            «IF targets('1.3.x')»
                $(idPrefix + 'SelectorDoNew').href += '&theme=Printer&idp=' + idPrefix + 'SelectorDoNew';
                $(idPrefix + 'SelectorDoNew').observe('click', function(e) {
                    «vendorAndName»InitInlineRelationWindow(objectType, idPrefix + 'SelectorDoNew');
                    e.stop();
                });
            «ELSE»
                $('#' + idPrefix + 'SelectorDoNew').href += '&theme=Printer&idp=' + idPrefix + 'SelectorDoNew';
                $('#' + idPrefix + 'SelectorDoNew').click( function(e) {
                    «vendorAndName»InitInlineRelationWindow(objectType, idPrefix + 'SelectorDoNew');
                    e.stopPropagation();
                });
            «ENDIF»

            «IF targets('1.3.x')»
                itemIds = $F(idPrefix + 'ItemList');
            «ELSE»
                itemIds = $('#' + idPrefix + 'ItemList').val();
            «ENDIF»
            itemIdsArr = itemIds.split(',');
            itemIdsArr.each(function (existingId) {
                var elemPrefix;

                if (existingId) {
                    elemPrefix = idPrefix + 'Reference_' + existingId + 'Edit';
                    «IF targets('1.3.x')»
                        $(elemPrefix).href += '&theme=Printer&idp=' + elemPrefix;
                        $(elemPrefix).observe('click', function (e) {
                            «vendorAndName»InitInlineRelationWindow(objectType, elemPrefix);
                            e.stop();
                        });
                    «ELSE»
                        $('#' + elemPrefix).href += '&theme=Printer&idp=' + elemPrefix;
                        $('#' + elemPrefix).click( function (e) {
                            «vendorAndName»InitInlineRelationWindow(objectType, elemPrefix);
                            e.stopPropagation();
                        });
                    «ENDIF»
                }
            });
        }
    '''

    def private closeWindowFromInside(Application it) '''
        /**
         * Closes an iframe from the document displayed in it
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
                        if (relationHandler.acInstance !== null) {
                            // activate it
                            «IF targets('1.3.x')»
                                relationHandler.acInstance.activate();
                            «ELSE»
                                $('#' + idPrefix + 'Selector').lookup();
                            «ENDIF»
                            // show a message
                            «IF targets('1.3.x')»
                                Zikula.UI.Alert(Zikula.__('Action has been completed.', 'module_«appName.formatForDB»_js'), Zikula.__('Information', 'module_«appName.formatForDB»_js'), {
                                    autoClose: 3 // time in seconds
                                });
                            «ELSE»
                                «vendorAndName»SimpleAlert($('.«appName.toLowerCase»-form'), Zikula.__('Information', '«appName.formatForDB»_js'), Zikula.__('Action has been completed.', '«appName.formatForDB»_js'), 'actionDoneAlert', 'success');
                            «ENDIF»
                        }
                    }
                    // look whether there is a windows instance
                    if (relationHandler.windowInstance !== null) {
                        // close it
                        relationHandler.windowInstance.closeHandler();
                    }
                }
            });
        }
    '''
}
