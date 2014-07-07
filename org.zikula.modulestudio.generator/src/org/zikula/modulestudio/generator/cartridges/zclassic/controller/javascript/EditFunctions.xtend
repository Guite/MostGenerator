package org.zikula.modulestudio.generator.cartridges.zclassic.controller.javascript

import de.guite.modulestudio.metamodel.modulestudio.AbstractDateField
import de.guite.modulestudio.metamodel.modulestudio.Application
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
        if (targets('1.3.5')) {
            fileName = appName + '_editFunctions.js'
        } else {
            fileName = appName + '.EditFunctions.js'
        }
        if (!shouldBeSkipped(getAppJsPath + fileName)) {
            println('Generating JavaScript for edit functions')
            if (shouldBeMarked(getAppJsPath + fileName)) {
                if (targets('1.3.5')) {
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
        «IF !getAllEntities.filter[!getDerivedFields.filter(AbstractDateField).empty].empty»
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
            function «prefix()»InitUserField(fieldName, getterName)
            {
                if ($(fieldName + 'LiveSearch') === null) {
                    return;
                }
                $(fieldName + 'LiveSearch').removeClassName('«IF targets('1.3.5')»z-hide«ELSE»hidden«ENDIF»');
                new Ajax.Autocompleter(
                    fieldName + 'Selector',
                    fieldName + 'SelectorChoices',
                    «IF targets('1.3.5')»
                        Zikula.Config.baseURL + 'ajax.php?module=«appName»&func=' + getterName,
                    «ELSE»
                        Routing.generate('«appName.formatForDB»_ajax_' + getterName),
                    «ENDIF»
                    {
                        paramName: 'fragment',
                        minChars: 3,
                        indicator: fieldName + 'Indicator',
                        afterUpdateElement: function(data) {
                            $(fieldName).value = $($(data).value).value;
                        }
                    }
                );
            }

        «ENDIF»
    '''

    def private resetUploadField(Application it) '''
        /**
         * Resets the value of an upload / file input field.
         */
        function «prefix()»ResetUploadField(fieldName)
        {
            «IF targets('1.3.5')»
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
        function «prefix()»InitUploadField(fieldName)
        {
            «IF targets('1.3.5')»
                if ($('reset' + fieldName.capitalize() + 'Val') != null) {
                    $('reset' + fieldName.capitalize() + 'Val').observe('click', function (evt) {
                        evt.preventDefault();
                        «prefix()»ResetUploadField(fieldName);
                    }).removeClassName('z-hide');
                }
            «ELSE»
                var fieldNameCapitalised;

                fieldNameCapitalised = fieldName.charAt(0).toUpperCase() + fieldName.slice(1);
                if ($('#reset' + fieldNameCapitalised + 'Val').size() > 0) {
                    $('#reset' + fieldNameCapitalised + 'Val').click( function (evt) {
                        event.stopPropagation();
                        «prefix()»ResetUploadField(fieldName);
                    }).removeClass('hidden');
                }
            «ENDIF»
        }
    '''

    def private resetDateField(Application it) '''
        /**
         * Resets the value of a date or datetime input field.
         */
        function «prefix()»ResetDateField(fieldName)
        {
            «IF targets('1.3.5')»
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
                    $('#' + fieldName + 'cal').html(Zikula.__('No date set.', 'module_«appName.formatForDB»_js'));
                }
            «ENDIF»
        }
    '''

    def private initDateField(Application it) '''
        /**
         * Initialises the reset button for a certain date input.
         */
        function «prefix()»InitDateField(fieldName)
        {
            «IF targets('1.3.5')»
                if ($('reset' + fieldName.capitalize() + 'Val') != null) {
                    $('reset' + fieldName.capitalize() + 'Val').observe('click', function (evt) {
                        evt.preventDefault();
                        «prefix()»ResetDateField(fieldName);
                    }).removeClassName('z-hide');
                }
            «ELSE»
                var fieldNameCapitalised;

                fieldNameCapitalised = fieldName.charAt(0).toUpperCase() + fieldName.slice(1);
                if ($('#reset' + fieldNameCapitalised + 'Val').size() > 0) {
                    $('#reset' + fieldNameCapitalised + 'Val').click( function (evt) {
                        event.stopPropagation();
                        «prefix()»ResetDateField(fieldName);
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
         * There is also a method on PHP level available in the \«IF targets('1.3.5')»«appName»_Util_Controller«ELSE»«vendor.formatForCodeCapital»\«name.formatForCodeCapital»Module\Util\ControllerUtil«ENDIF» class.
         */
        function «prefix()»InitGeoCoding(addressCallback)
        {
            «IF targets('1.3.5')»
                $('linkGetCoordinates').observe('click', function (evt) {
                    «prefix()»DoGeoCoding(addressCallback);
                });
            «ELSE»
                $('#linkGetCoordinates').click( function (evt) {
                    «prefix()»DoGeoCoding(addressCallback);
                });
            «ENDIF»
        }

        /**
         * Performs the actual geo coding using Mapstraction.
         */
        function «prefix()»DoGeoCoding(addressCallback)
        {
            «IF targets('1.3.5')»
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

            var geocoder = new mxn.Geocoder('googlev3', «prefix()»GeoCodeReturn, «prefix()»GeoCodeErrorCallback);
            geocoder.geocode(address);

            function «prefix()»GeoCodeErrorCallback (status) {
                «IF targets('1.3.5')»
                    Zikula.UI.Alert(Zikula.__('Error during geocoding:', 'module_«appName.formatForDB»_js') + ' ' + status);
                «ELSE»
                    «prefix()»SimpleAlert($('#mapContainer'), Zikula.__('Error during geocoding', 'module_«appName.formatForDB»_js'), status, 'geoCodingAlert', 'danger');
                «ENDIF»
            }

            function «prefix()»GeoCodeReturn (location) {
                «IF targets('1.3.5')»
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
        «IF !getJoinRelations.empty»

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
                            $(idPrefix + 'NoResultsHint').removeClassName('«IF targets('1.3.5')»z-hide«ELSE»hidden«ENDIF»');
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

            «initRelatedItemsForm(prefix())»

            «closeWindowFromInside»
        «ENDIF»
    '''

    def private toggleRelatedItemForm(Application it) '''
        /**
         * Toggles the fields of an auto completion field.
         */
        function «prefix()»ToggleRelatedItemForm(idPrefix)
        {
            «IF targets('1.3.5')»
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
        function «prefix()»ResetRelatedItemForm(idPrefix)
        {
            // hide the sub form
            «prefix()»ToggleRelatedItemForm(idPrefix);

            // reset value of the auto completion field
            «IF targets('1.3.5')»
                $(idPrefix + 'Selector').value = '';
            «ELSE»
                $('#' + idPrefix + 'Selector').val('');
            «ENDIF»
        }
    '''

    def private createRelationWindowInstance(Application it) '''
        /**
         * Helper function to create new «IF targets('1.3.5')»Zikula.UI.Window«ELSE»modal form dialog«ENDIF» instances.
         * For edit forms we use "iframe: true" to ensure file uploads work without problems.
         * For all other windows we use "iframe: false" because we want the escape key working.
         */
        function «prefix()»CreateRelationWindowInstance(containerElem, useIframe)
        {
            var newWindow«IF !targets('1.3.5')»Id«ENDIF»;

            // define the new window instance
            «IF targets('1.3.5')»
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
            return newWindow«IF !targets('1.3.5')»Id«ENDIF»;
        }
    '''

    def private initInlineRelationWindow(Application it) '''
        /**
         * Observe a link for opening an inline window
         */
        function «prefix()»initInlineRelationWindow(objectType, containerID)
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
                        «IF targets('1.3.5')»
                            relationHandler.windowInstance.destroy();
                        «ELSE»
                            $(containerID + 'Dialog').dialog('destroy');
                        «ENDIF»
                    }
                    // create and assign the new window instance
                    relationHandler.windowInstance«IF !targets('1.3.5')»Id«ENDIF» = «prefix()»CreateRelationWindowInstance($(«IF !targets('1.3.5')»'#' + «ENDIF»containerID), true);
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
                newItem.windowInstance«IF !targets('1.3.5')»Id«ENDIF» = «prefix()»CreateRelationWindowInstance($(«IF !targets('1.3.5')»'#' + «ENDIF»containerID), true);

                // add it to the list of handlers
                relationHandler.push(newItem);
            }
        }
    '''

    def private removeRelatedItem(Application it) '''
        /**
         * Removes a related item from the list of selected ones.
         */
        function «prefix()»RemoveRelatedItem(idPrefix, removeId)
        {
            var itemIds, itemIdsArr;

            «IF targets('1.3.5')»
                itemIds = $F(idPrefix + 'ItemList');
            «ELSE»
                itemIds = $('#' + idPrefix + 'ItemList').val();
            «ENDIF»
            itemIdsArr = itemIds.split(',');

            «IF targets('1.3.5')»
                itemIdsArr = itemIdsArr.without(removeId);
            «ELSE»
                itemIdsArr = $.grep(itemIdsArr, function(value) {
                    return value != removeId;
                });
            «ENDIF»

            itemIds = itemIdsArr.join(',');

            «IF targets('1.3.5')»
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
        function «prefix()»SelectRelatedItem(objectType, idPrefix, inputField, selectedListItem)
        {
            var newItemId, newTitle, includeEditing, editLink, removeLink, elemPrefix, itemPreview, li, editHref, fldPreview, itemIds, itemIdsArr;

            «IF targets('1.3.5')»
                newItemId = selectedListItem.id;
                newTitle = $F(idPrefix + 'Selector');
                includeEditing = !!(($F(idPrefix + 'Mode') == '1'));
            «ELSE»
                newItemId = selectedListItem.attr('id');
                newTitle = $('#' + idPrefix + 'Selector').val();
                includeEditing = !!(($('#' + idPrefix + 'Mode').val() == '1'));
            «ENDIF»
            elemPrefix = idPrefix + 'Reference_' + newItemId;
            itemPreview = '';

            «IF targets('1.3.5')»
                if ($('itemPreview' + selectedListItem.id) !== null) {
                    itemPreview = $('itemPreview' + selectedListItem.id).innerHTML;
                }
            «ELSE»
                if ($('#itemPreview' + selectedListItem.attr('id')).size() > 0) {
                    itemPreview = $('#itemPreview' + selectedListItem.attr('id')).innerHTML;
                }
            «ENDIF»

            «IF targets('1.3.5')»
                var li = Builder.node('li', {id: elemPrefix}, newTitle);
                if (includeEditing === true) {
                    var editHref = $(idPrefix + 'SelectorDoNew').href + '&id=' + newItemId;
                    editLink = Builder.node('a', {id: elemPrefix + 'Edit', href: editHref}, 'edit');
                    li.appendChild(editLink);
                }
                removeLink = Builder.node('a', {id: elemPrefix + 'Remove', href: 'javascript:«prefix()»RemoveRelatedItem(\'' + idPrefix + '\', ' + newItemId + ');'}, 'remove');
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
                removeLink = $('<a>', {id: elemPrefix + 'Remove', href: 'javascript:«prefix()»RemoveRelatedItem(\'' + idPrefix + '\', ' + newItemId + ');', text: 'remove'});
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
                «IF targets('1.3.5')»
                    editLink.update(' ' + editImage);
                «ELSE»
                    editLink.html(' ' + editImage);
                «ENDIF»

                «IF targets('1.3.5')»
                    $(elemPrefix + 'Edit').observe('click', function (e) {
                        «prefix()»initInlineRelationWindow(objectType, idPrefix + 'Reference_' + newItemId + 'Edit');
                        e.stop();
                    });
                «ELSE»
                    $('#' + elemPrefix + 'Edit').click( function (e) {
                        «prefix()»initInlineRelationWindow(objectType, idPrefix + 'Reference_' + newItemId + 'Edit');
                        e.stopPropagation();
                    });
                «ENDIF»
            }
            «IF targets('1.3.5')»
                removeLink.update(' ' + removeImage);
            «ELSE»
                removeLink.html(' ' + removeImage);
            «ENDIF»

            «IF targets('1.3.5')»
                itemIds = $F(idPrefix + 'ItemList');
                if (itemIds !== '') {
                    if ($F(idPrefix + 'Scope') === '0') {
                        itemIdsArr = itemIds.split(',');
                        itemIdsArr.each(function (existingId) {
                            if (existingId) {
                                «prefix()»RemoveRelatedItem(idPrefix, existingId);
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
                                «prefix()»RemoveRelatedItem(idPrefix, existingId);
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

            «prefix()»ResetRelatedItemForm(idPrefix);
        }
    '''

    def private initRelatedItemsForm(Application it, String prefixSmall) '''
        /**
         * Initialise a relation field section with autocompletion and optional edit capabilities
         */
        function «prefixSmall»InitRelationItemsForm(objectType, idPrefix, includeEditing)
        {
            var acOptions, itemIds, itemIdsArr;

            «IF targets('1.3.5')»
                // add handling for the toggle link if existing
                if ($(idPrefix + 'AddLink') !== null) {
                    $(idPrefix + 'AddLink').observe('click', function (e) {
                        «prefixSmall»ToggleRelatedItemForm(idPrefix);
                    });
                }
                // add handling for the cancel button
                if ($(idPrefix + 'SelectorDoCancel') !== null) {
                    $(idPrefix + 'SelectorDoCancel').observe('click', function (e) {
                        «prefixSmall»ResetRelatedItemForm(idPrefix);
                    });
                }
            «ELSE»
                // add handling for the toggle link if existing
                if ($('#' + idPrefix + 'AddLink').size() > 0) {
                    $('#' + idPrefix + 'AddLink').click( function (e) {
                        «prefixSmall»ToggleRelatedItemForm(idPrefix);
                    });
                }
                // add handling for the cancel button
                if ($('#' + idPrefix + 'SelectorDoCancel').size() > 0) {
                    $('#' + idPrefix + 'SelectorDoCancel').click( function (e) {
                        «prefixSmall»ResetRelatedItemForm(idPrefix);
                    });
                }
            «ENDIF»
            // clear values and ensure starting state
            «prefixSmall»ResetRelatedItemForm(idPrefix);

            acOptions = {
                paramName: 'fragment',
                minChars: 2,
                indicator: idPrefix + 'Indicator',
                callback: function (inputField, defaultQueryString) {
                    var queryString;

                    // modify the query string before the request
                    queryString = defaultQueryString + '&ot=' + objectType;
                    «IF targets('1.3.5')»
                        if ($(idPrefix + 'ItemList') !== null) {
                            queryString += '&exclude=' + $F(idPrefix + 'ItemList');
                        }

                        if ($(idPrefix + 'NoResultsHint') != null) {
                            $(idPrefix + 'NoResultsHint').addClassName('z-hide');
                        }
                    «ELSE»
                        if ($('#' + idPrefix + 'ItemList').size() > 0) {
                            queryString += '&exclude=' + $('#' + idPrefix + 'ItemList').val();
                        }

                        if ($('#' + idPrefix + 'NoResultsHint').size() > 0) {
                            $('#' + idPrefix + 'NoResultsHint').addClass('hidden');
                        }
                    «ENDIF»

                    return queryString;
                },
                afterUpdateElement: function (inputField, selectedListItem) {
                    // Called after the input element has been updated (i.e. when the user has selected an entry).
                    // This function is called after the built-in function that adds the list item text to the input field.
                    «prefixSmall»SelectRelatedItem(objectType, idPrefix, inputField, selectedListItem);
                }
            };
            relationHandler.each(function (relationHandler) {
                if (relationHandler.prefix === (idPrefix + 'SelectorDoNew') && relationHandler.acInstance === null) {
                    relationHandler.acInstance = new Ajax.Autocompleter(
                        idPrefix + 'Selector',
                        idPrefix + 'SelectorChoices',
                        «IF targets('1.3.5')»
                            Zikula.Config.baseURL + 'ajax.php?module=' + relationHandler.moduleName + '&func=getItemListAutoCompletion',
                        «ELSE»
                            //Routing.generate('«appName.formatForDB»_ajax_getItemListAutoCompletion'),
                            Routing.generate(relationHandler.moduleName.toLowerCase() + '_ajax_getItemListAutoCompletion'),
                        «ENDIF»
                        acOptions
                    );
                }
            });

            «IF targets('1.3.5')»
                if (!includeEditing || $(idPrefix + 'SelectorDoNew') === null) {
                    return;
                }
            «ELSE»
                if (!includeEditing || $('#' + idPrefix + 'SelectorDoNew').size() < 1) {
                    return;
                }
            «ENDIF»

            // from here inline editing will be handled
            «IF targets('1.3.5')»
                $(idPrefix + 'SelectorDoNew').href += '&theme=Printer&idp=' + idPrefix + 'SelectorDoNew';
                $(idPrefix + 'SelectorDoNew').observe('click', function(e) {
                    «prefixSmall»initInlineRelationWindow(objectType, idPrefix + 'SelectorDoNew');
                    e.stop();
                });
            «ELSE»
                $('#' + idPrefix + 'SelectorDoNew').href += '&theme=Printer&idp=' + idPrefix + 'SelectorDoNew';
                $('#' + idPrefix + 'SelectorDoNew').click( function(e) {
                    «prefixSmall»initInlineRelationWindow(objectType, idPrefix + 'SelectorDoNew');
                    e.stopPropagation();
                });
            «ENDIF»

            «IF targets('1.3.5')»
                itemIds = $F(idPrefix + 'ItemList');
            «ELSE»
                itemIds = $('#' + idPrefix + 'ItemList').val();
            «ENDIF»
            itemIdsArr = itemIds.split(',');
            itemIdsArr.each(function (existingId) {
                var elemPrefix;

                if (existingId) {
                    elemPrefix = idPrefix + 'Reference_' + existingId + 'Edit';
                    «IF targets('1.3.5')»
                        $(elemPrefix).href += '&theme=Printer&idp=' + elemPrefix;
                        $(elemPrefix).observe('click', function (e) {
                            «prefixSmall»initInlineRelationWindow(objectType, elemPrefix);
                            e.stop();
                        });
                    «ELSE»
                        $('#' + elemPrefix).href += '&theme=Printer&idp=' + elemPrefix;
                        $('#' + elemPrefix).click( function (e) {
                            «prefixSmall»initInlineRelationWindow(objectType, elemPrefix);
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
        function «prefix()»CloseWindowFromInside(idPrefix, itemId)
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
                            relationHandler.acInstance.activate();
                            // show a message
                            «IF targets('1.3.5')» 
                                Zikula.UI.Alert(Zikula.__('Action has been completed.', 'module_«appName.formatForDB»_js'), Zikula.__('Information', 'module_«appName.formatForDB»_js'), {
                                    autoClose: 3 // time in seconds
                                });
                            «ELSE»
                                «prefix()»SimpleAlert($('.«appName.toLowerCase»-form'), Zikula.__('Information', 'module_«appName.formatForDB»_js'), Zikula.__('Action has been completed.', 'module_«appName.formatForDB»_js'), 'actionDoneAlert', 'success');
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
