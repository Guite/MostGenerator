package org.zikula.modulestudio.generator.cartridges.zclassic.controller.javascript

import com.google.inject.Inject
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
    @Inject extension FormattingExtensions = new FormattingExtensions()
    @Inject extension ModelExtensions = new ModelExtensions()
    @Inject extension ModelBehaviourExtensions = new ModelBehaviourExtensions()
    @Inject extension ModelJoinExtensions = new ModelJoinExtensions()
    @Inject extension NamingExtensions = new NamingExtensions()
    @Inject extension Utils = new Utils()

    /**
     * Entry point for the javascript file with edit functionality.
     */
    def generate(Application it, IFileSystemAccess fsa) {
        println('Generating javascript for edit functions')
        fsa.generateFile(getAppJsPath + appName + '_editFunctions.js', generate)
    }

    def private generate(Application it) '''
        'use strict';

        «initUserField»

        «IF hasUploads»
            «resetUploadField»

            «initUploadField»

        «ENDIF»
        «IF !getAllEntities.filter(e|!e.getDerivedFields.filter(typeof(AbstractDateField)).isEmpty).isEmpty»
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
             * Initialise a user field with autocompletion.
             */
            function «prefix»InitUserField(fieldName, getterName) {
                if ($(fieldName + 'LiveSearch') === undefined) {
                    return;
                }
                $(fieldName + 'LiveSearch').removeClassName('z-hide');
                new Ajax.Autocompleter(
                    fieldName + 'Selector',
                    fieldName + 'SelectorChoices',
                    Zikula.Config.baseURL + 'ajax.php?module=«appName»&func=' + getterName,
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
        function «prefix»ResetUploadField(fieldName) {
            if ($(fieldName) != undefined) {
                $(fieldName).setAttribute('type', 'input');
                $(fieldName).setAttribute('type', 'file');
            }
        }
    '''

    def private initUploadField(Application it) '''
        /**
         * Initialises the reset button for a certain upload input.
         */
        function «prefix»InitUploadField(fieldName) {
            if ($('reset' + fieldName.capitalize() + 'Val') != undefined) {
                $('reset' + fieldName.capitalize() + 'Val').observe('click', function (evt) {
                    evt.preventDefault();
                    «prefix»ResetUploadField(fieldName);
                }).removeClassName('z-hide');
            }
        }
    '''

    def private resetDateField(Application it) '''
        /**
         * Resets the value of a date or datetime input field.
         */
        function «prefix»ResetDateField(fieldName) {
            if ($(fieldName) != undefined) {
                $(fieldName).value = '';
            }
            if ($(fieldName + 'cal') != undefined) {
                $(fieldName + 'cal').update(Zikula.__('No date set.', 'module_«appName»'));
            }
        }
    '''

    def private initDateField(Application it) '''
        /**
         * Initialises the reset button for a certain date input.
         */
        function «prefix»InitDateField(fieldName) {
            if ($('reset' + fieldName.capitalize() + 'Val') != undefined) {
                $('reset' + fieldName.capitalize() + 'Val').observe('click', function (evt) {
                    evt.preventDefault();
                    «prefix»ResetDateField(fieldName);
                }).removeClassName('z-hide');
            }
        }
    '''

    def private initGeoCoding(Application it) '''
        /**
         * Example method for initialising geo coding functionality in JavaScript.
         * To use this please customise the form field names to your needs.
         * There is also a method on PHP level available in the «appName»«IF targets('1.3.5')»_Util_«ELSE»\Util\«ENDIF»Controller class.
         */
        function «prefix»InitGeoCoding() {
            $('linkGetCoordinates').observe('click', function (evt) {
                var geocoder = new mxn.Geocoder('googlev3', «prefix»GeoCodeReturn, «prefix»GeoCodeErrorCallback);

                var address = {
                    address : $F('street') + ' ' + $F('houseNumber') + ' ' + $F('zipcode') + ' ' + $F('city') + ' ' + $F('country')
                };
                geocoder.geocode(address);

                function «prefix»GeoCodeErrorCallback (status) {
                    Zikula.UI.Alert(Zikula.__('Error during geocoding:', 'module_«appName»') + ' ' + status);
                }

                function «prefix»GeoCodeReturn (location) {
                    Form.Element.setValue('latitude', location.point.lat.toFixed(4));
                    Form.Element.setValue('longitude', location.point.lng.toFixed(4));
                    newCoordinatesEventHandler();
                }
            });
        }
    '''

    def private relationFunctions(Application it) '''
        «IF !getJoinRelations.isEmpty»
            «toggleRelatedItemForm»

            «resetRelatedItemForm»

            «createWindowInstance»

            «initInlineWindow»

            «removeRelatedItem»

            «selectRelatedItem»

            «initRelatedItemsForm(prefix)»

            «closeWindowFromInside»
        «ENDIF»
    '''

    def private toggleRelatedItemForm(Application it) '''
        /**
         * Toggles the fields of an auto completion field.
         */
        function «prefix»ToggleRelatedItemForm(idPrefix) {
            // if we don't have a toggle link do nothing
            if ($(idPrefix + 'AddLink') === undefined) {
                return;
            }

            // show/hide the toggle link
            $(idPrefix + 'AddLink').toggleClassName('z-hide');

            // hide/show the fields
            $(idPrefix + 'AddFields').toggleClassName('z-hide');
        }
    '''

    def private resetRelatedItemForm(Application it) '''
        /**
         * Resets an auto completion field.
         */
        function «prefix»ResetRelatedItemForm(idPrefix) {
            // hide the sub form
            «prefix»ToggleRelatedItemForm(idPrefix);

            // reset value of the auto completion field
            $(idPrefix + 'Selector').value = '';
        }
    '''

    def private createWindowInstance(Application it) '''
        /**
         * Helper function to create new Zikula.UI.Window instances.
         * For edit forms we use "iframe: true" to ensure file uploads work without problems.
         * For all other windows we use "iframe: false" because we want the escape key working.
         */
        function «prefix»CreateWindowInstance(containerElem, useIframe) {
            var newWindow;

            // define the new window instance
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

            // return the instance
            return newWindow;
        }
    '''

    def private initInlineWindow(Application it) '''
        /**
         * Observe a link for opening an inline window
         */
        function «prefix»InitInlineWindow(objectType, containerID) {
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
                        relationHandler.windowInstance.destroy();
                    }
                    // create and assign the new window instance
                    relationHandler.windowInstance = «prefix»CreateWindowInstance($(containerID), true);
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
                newItem.windowInstance = «prefix»CreateWindowInstance($(containerID), true);

                // add it to the list of handlers
                relationHandler.push(newItem);
            }
        }
    '''

    def private removeRelatedItem(Application it) '''
        /**
         * Removes a related item from the list of selected ones.
         */
        function «prefix»RemoveRelatedItem(idPrefix, removeId) {
            var itemIds, itemIdsArr;

            itemIds = $F(idPrefix + 'ItemList');
            itemIdsArr = itemIds.split(',');

            itemIdsArr = itemIdsArr.without(removeId);

            itemIds = itemIdsArr.join(',');

            $(idPrefix + 'ItemList').value = itemIds;
            $(idPrefix + 'Reference_' + removeId).remove();
        }
    '''

    def private selectRelatedItem(Application it) '''
        /**
         * Add a related item to selection which has been chosen by auto completion
         */
        function «prefix»SelectRelatedItem(objectType, idPrefix, inputField, selectedListItem) {
            var newItemId, newTitle, includeEditing, editLink, removeLink, elemPrefix, itemPreview, li, editHref, fldPreview, itemIds, itemIdsArr;

            newItemId = selectedListItem.id;
            newTitle = $F(idPrefix + 'Selector');
            includeEditing = !!(($F(idPrefix + 'Mode') == '1'));
            elemPrefix = idPrefix + 'Reference_' + newItemId;
            itemPreview = '';

            if ($('itempreview' + selectedListItem.id) !== null) {
                itemPreview = $('itempreview' + selectedListItem.id).innerHTML;
            }

            var li = Builder.node('li', {id: elemPrefix}, newTitle);
            if (includeEditing === true) {
                var editHref = $(idPrefix + 'SelectorDoNew').href + '&id=' + newItemId;
                editLink = Builder.node('a', {id: elemPrefix + 'Edit', href: editHref}, 'edit');
                li.appendChild(editLink);
            }
            removeLink = Builder.node('a', {id: elemPrefix + 'Remove', href: 'javascript:«prefix»RemoveRelatedItem(\'' + idPrefix + '\', ' + newItemId + ');'}, 'remove');
            li.appendChild(removeLink);
            if (itemPreview !== '') {
                fldPreview = Builder.node('div', {id: elemPrefix + 'preview', name: idPrefix + 'preview'}, '');
                fldPreview.update(itemPreview);
                li.appendChild(fldPreview);
                itemPreview = '';
            }
            $(idPrefix + 'ReferenceList').appendChild(li);

            if (includeEditing === true) {
                editLink.update(' ' + editImage);

                $(elemPrefix + 'Edit').observe('click', function (e) {
                    «prefix»InitInlineWindow(objectType, idPrefix + 'Reference_' + newItemId + 'Edit');
                    e.stop();
                });
            }
            removeLink.update(' ' + removeImage);

            itemIds = $F(idPrefix + 'ItemList');
            if (itemIds !== '') {
                if ($F(idPrefix + 'Scope') === '0') {
                    itemIdsArr = itemIds.split(',');
                    itemIdsArr.each(function (existingId) {
                        if (existingId) {
                            «prefix»RemoveRelatedItem(idPrefix, existingId);
                        }
                    });
                    itemIds = '';
                } else {
                    itemIds += ',';
                }
            }
            itemIds += newItemId;
            $(idPrefix + 'ItemList').value = itemIds;

            «prefix»ResetRelatedItemForm(idPrefix);
        }
    '''

    def private initRelatedItemsForm(Application it, String prefixSmall) '''
        /**
         * Initialise a relation field section with autocompletion and optional edit capabilities
         */
        function «prefixSmall»InitRelationItemsForm(objectType, idPrefix, includeEditing) {
            var acOptions, itemIds, itemIdsArr;

            // add handling for the toggle link if existing
            if ($(idPrefix + 'AddLink') !== undefined) {
                $(idPrefix + 'AddLink').observe('click', function (e) {
                    «prefixSmall»ToggleRelatedItemForm(idPrefix);
                });
            }
            // add handling for the cancel button
            if ($(idPrefix + 'SelectorDoCancel') !== undefined) {
                $(idPrefix + 'SelectorDoCancel').observe('click', function (e) {
                    «prefixSmall»ResetRelatedItemForm(idPrefix);
                });
            }
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
                    if ($(idPrefix + 'ItemList') !== undefined) {
                        queryString += '&exclude=' + $F(idPrefix + 'ItemList');
                    }
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
                        Zikula.Config.baseURL + 'ajax.php?module=' + relationHandler.moduleName + '&func=getItemListAutoCompletion',
                        acOptions
                    );
                }
            });

            if (!includeEditing || $(idPrefix + 'SelectorDoNew') === undefined) {
                return;
            }

            // from here inline editing will be handled
            $(idPrefix + 'SelectorDoNew').href += '&theme=Printer&idp=' + idPrefix + 'SelectorDoNew';
            $(idPrefix + 'SelectorDoNew').observe('click', function(e) {
                «prefixSmall»InitInlineWindow(objectType, idPrefix + 'SelectorDoNew');
                e.stop();
            });

            itemIds = $F(idPrefix + 'ItemList');
            itemIdsArr = itemIds.split(',');
            itemIdsArr.each(function (existingId) {
                var elemPrefix;

                if (existingId) {
                    elemPrefix = idPrefix + 'Reference_' + existingId + 'Edit';
                    $(elemPrefix).href += '&theme=Printer&idp=' + elemPrefix;
                    $(elemPrefix).observe('click', function (e) {
                        «prefixSmall»InitInlineWindow(objectType, elemPrefix);
                        e.stop();
                    });
                }
            });
        }
    '''

    def private closeWindowFromInside(Application it) '''
        /**
         * Closes an iframe from the document displayed in it
         */
        function «prefix»CloseWindowFromInside(idPrefix, itemId) {
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
                            Zikula.UI.Alert(Zikula.__('Action has been completed.', 'module_«appName.formatForDB»_js'), Zikula.__('Information','module_«appName.formatForDB»_js'), {
                                autoClose: 3 // time in seconds
                            });
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
