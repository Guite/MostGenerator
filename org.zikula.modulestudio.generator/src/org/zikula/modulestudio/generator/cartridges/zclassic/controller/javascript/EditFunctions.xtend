package org.zikula.modulestudio.generator.cartridges.zclassic.controller.javascript

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class EditFunctions {
    @Inject extension ModelExtensions = new ModelExtensions()
    @Inject extension ModelJoinExtensions = new ModelJoinExtensions()
    @Inject extension NamingExtensions = new NamingExtensions()
    @Inject extension Utils = new Utils()

    /**
     * Entry point for the javascript file with edit functionality.
     */
    def generate(Application it, IFileSystemAccess fsa) {
        fsa.generateFile(getAppSourcePath(appName) + 'javascript/' + appName + '_editFunctions.js', generate)
    }

    def private generate(Application it) '''

        «initUserField»
        «relationFunctions»
    '''

    def private initUserField(Application it) '''
        «IF hasUserFields»
            /**
             * Initialise a user field with autocompletion.
             */
            function «prefix»InitUserField(fieldName, getterName)
            {
                if ($(fieldName + 'LiveSearch') == undefined) {
                    return;
                }
                $(fieldName + 'LiveSearch').removeClassName('z-hide');
                new Ajax.Autocompleter(
                    fieldName + 'Selector',
                    fieldName + 'SelectorChoices',
                    Zikula.Config['baseURL'] + 'ajax.php?module=«appName»&func=' + getterName,
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

    def private relationFunctions(Application it) '''
        «IF !getJoinRelations.isEmpty»
            «initRelatedItemsForm(prefix)»

            «selectRelatedItem»

            «initInlineWindow»

            «createWindowInstance»

            «removeRelatedItem»

            «resetRelatedItemForm»

            «toggleRelatedItemForm»

            «closeWindowFromInside»

            // TODO: support auto-hiding notification windows (see https://github.com/zikula/core/issues/121 for more information)
        «ENDIF»
    '''

    def private initRelatedItemsForm(Application it, String prefixSmall) '''
        /**
         * Initialise a relation field section with autocompletion and optional edit capabilities
         */
        function «prefixSmall»InitRelationItemsForm(objectType, idPrefix, includeEditing)
        {
            // add handling for the toggle link if existing
            if ($(idPrefix + 'AddLink') != undefined) {
                $(idPrefix + 'AddLink').observe('click', function(e) { «prefixSmall»ToggleRelatedItemForm(idPrefix); });
            }
            // add handling for the cancel button
            if ($(idPrefix + 'SelectorDoCancel') != undefined) {
                $(idPrefix + 'SelectorDoCancel').observe('click', function(e) { «prefixSmall»ResetRelatedItemForm(idPrefix); });
            }
            // clear values and ensure starting state
            «prefixSmall»ResetRelatedItemForm(idPrefix);

            var acOptions = {
                    paramName: 'fragment',
                    minChars: 2,
                    indicator: idPrefix + 'Indicator',
                    callback: function(inputField, defaultQueryString) {
                            // modify the query string before the request
                            defaultQueryString += '&ot=' + objectType;
                            if ($(idPrefix + 'ItemList') != undefined) {
                                defaultQueryString += '&exclude=' + $F(idPrefix + 'ItemList');
                            }
                            return defaultQueryString;
                    },
                    afterUpdateElement: function(inputField, selectedListItem) {
                            // Called after the input element has been updated (i.e. when the user has selected an entry).
                            // This function is called after the built-in function that adds the list item text to the input field.
                            «prefixSmall»SelectRelatedItem(objectType, idPrefix, inputField, selectedListItem);
                    }
            };
            relationHandler.each(function(relationHandler) {
                if (relationHandler['prefix'] == (idPrefix + 'SelectorDoNew') && relationHandler['acInstance'] == null) {
                    relationHandler['acInstance'] = new Ajax.Autocompleter(
                        idPrefix + 'Selector',
                        idPrefix + 'SelectorChoices',
                        Zikula.Config['baseURL'] + 'ajax.php?module=«appName»&func=getItemListAutoCompletion',
                        acOptions
                    );
                }
            });

            if (!includeEditing || $(idPrefix + 'SelectorDoNew') == undefined) {
                return;
            }

            // from here inline editing will be handled
            $(idPrefix + 'SelectorDoNew').href += '&theme=Printer&idp=' + idPrefix + 'SelectorDoNew';
            $(idPrefix + 'SelectorDoNew').observe('click', function(e) {
                «prefixSmall»InitInlineWindow(objectType, idPrefix + 'SelectorDoNew')
                e.stop();
            });

            var itemIds = $F(idPrefix + 'ItemList');
            var itemIdsArr = itemIds.split(',');
            itemIdsArr.each(function(existingId) {
                if (existingId) {
                    var elemPrefix = idPrefix + 'Reference_' + existingId + 'Edit';
                    $(elemPrefix).href += '&theme=Printer&idp=' + elemPrefix;
                    $(elemPrefix).observe('click', function(e) {
                        «prefixSmall»InitInlineWindow(objectType, elemPrefix);
                        e.stop();
                    });
                }
            });
        }
    '''

    def private selectRelatedItem(Application it) '''
        /**
         * Add a related item to selection which has been chosen by auto completion
         */
        function «prefix»SelectRelatedItem(objectType, idPrefix, inputField, selectedListItem)
        {
            var newItemId = selectedListItem.id;
            var newTitle = $F(idPrefix + 'Selector');
            var includeEditing = ($F(idPrefix + 'Mode') == '1') ? true : false;
            var editLink;
            var removeLink;
            var elemPrefix = idPrefix + 'Reference_' + newItemId;
            var itemPreview = '';
            if ($('itempreview' + selectedListItem.id) != undefined) {
                itemPreview = $('itempreview' + selectedListItem.id).innerHTML;
            }

            var li = Builder.node('li', {id: elemPrefix}, newTitle);
            if (includeEditing == true) {
                var editHref = $(idPrefix + 'SelectorDoNew').href + '&id=' + newItemId;
                editLink = Builder.node('a', {id: elemPrefix + 'Edit', href: editHref}, 'edit');
                li.appendChild(editLink);
            }
            removeLink = Builder.node('a', {id: elemPrefix + 'Remove', href: 'javascript:«prefix»RemoveRelatedItem(\'' + idPrefix + '\', ' + newItemId + ');'}, 'remove');
            li.appendChild(removeLink);
            if (itemPreview != '') {
                var fldPreview = Builder.node('div', {id: elemPrefix + 'preview', name: idPrefix + 'preview'}, '');
                fldPreview.update(itemPreview);
                li.appendChild(fldPreview);
                itemPreview = '';
            }
            $(idPrefix + 'ReferenceList').appendChild(li);

            if (includeEditing == true) {
                editLink.update(' ' + editImage);

                $(elemPrefix + 'Edit').observe('click', function(e) {
                    «prefix»InitInlineWindow(objectType, idPrefix + 'Reference_' + newItemId + 'Edit');
                    e.stop();
                });
            }
            removeLink.update(' ' + removeImage);

            var itemIds = $F(idPrefix + 'ItemList');
            if (itemIds != '') {
                if ($F(idPrefix + 'Scope') == '0') {
                    var itemIdsArr = itemIds.split(',');
                    itemIdsArr.each(function(existingId) {
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

    def private initInlineWindow(Application it) '''
        /**
         * Observe a link for opening an inline window
         */
        function «prefix»InitInlineWindow(objectType, containerID)
        {
            // whether the handler has been found
            var found = false;

            // search for the handler
            relationHandler.each(function(relationHandler) {
                // is this the right one
                if (relationHandler['prefix'] == containerID) {
                    // yes, it is
                    found = true;
                    // look whether there is already a window instance
                    if (relationHandler['windowInstance'] != null) {
                        // unset it
                        relationHandler['windowInstance'].destroy();
                    }
                    // create and assign the new window instance
                    relationHandler['windowInstance'] = «prefix»CreateWindowInstance($(containerID), true);
                }
            });

            // if no handler was found
            if (found === false) {
                // create a new one
                var newItem = new Object();
                newItem['ot'] = objectType;
                newItem['alias'] = '«/*TODO*/»';
                newItem['prefix'] = containerID;
                newItem['acInstance'] = null;
                newItem['windowInstance'] = «prefix»CreateWindowInstance($(containerID), true);
                // add it to the list of handlers
                relationHandler.push(newItem);
            }
        }
    '''

    def private createWindowInstance(Application it) '''
        /**
         * Helper function to create new Zikula.UI.Window instances.
         * For edit forms we use "iframe: true" to ensure file uploads work without problems.
         * For all other windows we use "iframe: false" because we want the escape key working.
         */
        function «prefix»CreateWindowInstance(containerElem, useIframe)
        {
            // define the new window instance
            var newWindow = new Zikula.UI.Window(
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

    def private removeRelatedItem(Application it) '''
        /**
         * Removes a related item from the list of selected ones.
         */
        function «prefix»RemoveRelatedItem(idPrefix, removeId)
        {
            var itemIds = $F(idPrefix + 'ItemList');
            var itemIdsArr = itemIds.split(',');
            itemIdsArr = itemIdsArr.without(removeId);
            itemIds = itemIdsArr.join(',');
            $(idPrefix + 'ItemList').value = itemIds;
            $(idPrefix + 'Reference_' + removeId).remove();
        }
    '''

    def private resetRelatedItemForm(Application it) '''
        /**
         * Resets an auto completion field.
         */
        function «prefix»ResetRelatedItemForm(idPrefix)
        {
            // hide the sub form
            «prefix»ToggleRelatedItemForm(idPrefix);

            // reset value of the auto completion field
            $(idPrefix + 'Selector').value = '';
        }
    '''

    def private toggleRelatedItemForm(Application it) '''
        /**
         * Toggles the fields of an auto completion field.
         */
        function «prefix»ToggleRelatedItemForm(idPrefix)
        {
            // if we don't have a toggle link do nothing
            if ($(idPrefix + 'AddLink') == undefined) {
                return;
            }

            // show/hide the toggle link
            $(idPrefix + 'AddLink').toggle();

            // hide/show the fields
            $(idPrefix + 'AddFields').toggle();
        }
    '''

    def private closeWindowFromInside(Application it) '''
        /**
         * Closes an iframe from the document displayed in it
         */
        function «prefix»CloseWindowFromInside(idPrefix, itemID)
        {
            // if there is no parent window do nothing
            if (window.parent == '') {
                return;
            }

            // search for the handler of the current window
            window.parent.relationHandler.each(function(relationHandler) {
                // look if this handler is the right one
                if (relationHandler['prefix'] == idPrefix) {
                    // do we have an item created
                    if (itemID > 0) {
                        // look whether there is an auto completion instance
                        if (relationHandler['acInstance'] != null) {
                            // activate it
                            relationHandler['acInstance'].activate();
                            // show a message 
                            Zikula.UI.Alert('Action has been completed.', 'Information');
                        }
                    }
                    // look whether there is a windows instance
                    if (relationHandler['windowInstance'] != null) {
                        // close it
                        relationHandler['windowInstance'].closeHandler();
                    }
                }
            });
        }
    '''
}
