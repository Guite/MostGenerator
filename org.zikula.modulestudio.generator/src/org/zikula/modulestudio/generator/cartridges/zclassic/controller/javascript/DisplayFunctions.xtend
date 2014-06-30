package org.zikula.modulestudio.generator.cartridges.zclassic.controller.javascript

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Application
import de.guite.modulestudio.metamodel.modulestudio.DerivedField
import de.guite.modulestudio.metamodel.modulestudio.Entity
import de.guite.modulestudio.metamodel.modulestudio.JoinRelationship
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class DisplayFunctions {
    @Inject extension ControllerExtensions = new ControllerExtensions
    @Inject extension FormattingExtensions = new FormattingExtensions
    @Inject extension ModelExtensions = new ModelExtensions
    @Inject extension ModelJoinExtensions = new ModelJoinExtensions
    @Inject extension NamingExtensions = new NamingExtensions
    @Inject extension Utils = new Utils

    /**
     * Entry point for the JavaScript file with display functionality.
     */
    def generate(Application it, IFileSystemAccess fsa) {
        var fileName = appName + '.js'
        if (!shouldBeSkipped(getAppJsPath + fileName)) {
            println('Generating JavaScript for display functions')
            if (shouldBeMarked(getAppJsPath + fileName)) {
                fileName = appName + '.generated.js'
            }
            fsa.generateFile(getAppJsPath + fileName, generate)
        }
    }

    def private generate(Application it) '''
        'use strict';

        «initItemActions»
        «IF !getAllControllers.map[hasActions('view')].empty»

            «initQuickNavigation»
        «ENDIF»
        «IF !getJoinRelations.empty»

            «initRelationWindow»
        «ENDIF»
        «IF hasBooleansWithAjaxToggle»

            «initToggle»

            «toggleFlag»
        «ENDIF»
        «IF !targets('1.3.5')»

            «simpleAlert»
        «ENDIF»
    '''

    def private initItemActions(Application it) '''
        var «prefix()»ContextMenu;

        «prefix()»ContextMenu = Class.create(Zikula.UI.ContextMenu, {
            selectMenuItem: function ($super, event, item, item_container) {
                // open in new tab / window when right-clicked
                if (event.isRightClick()) {
                    item.callback(this.clicked, true);
                    «IF targets('1.3.5')»
                        event.stop(); // close the menu
                    «ELSE»
                        event.stopPropagation(); // close the menu
                    «ENDIF»
                    return;
                }
                // open in current window when left-clicked
                return $super(event, item, item_container);
            }
        });

        /**
         * Initialises the context menu for item actions.
         */
        function «prefix()»InitItemActions(objectType, func, containerId)
        {
            var triggerId, contextMenu, icon;

            triggerId = containerId + 'Trigger';

            // attach context menu
            contextMenu = new «prefix()»ContextMenu(triggerId, { leftClick: true, animation: false });

            // process normal links
            «IF targets('1.3.5')»$«ENDIF»$('#' + containerId + ' a').each(function (elem) {
                «IF !targets('1.3.5')»
                    // save css class before hiding (#428)
                    var elemClass = elem.attr('class');
                «ENDIF»
                // hide it
                «IF targets('1.3.5')»
                    elem.addClassName('z-hide');
                «ELSE»
                    elem.addClass('hidden');
                «ENDIF»
                // determine the link text
                var linkText = '';
                if (func === 'display') {
                    linkText = elem.innerHTML;
                } else if (func === 'view') {
                    «IF targets('1.3.5')»
                        elem.select('img').each(function (imgElem) {
                            linkText = imgElem.readAttribute('alt');
                        });
                    «ELSE»
                        linkText = elem.attr('data-linktext');
                    «ENDIF»
                }

                // determine the icon
                icon = '';
                «IF targets('1.3.5')»
                    if (func === 'display') {
                        if (elem.hasClassName('z-icon-es-preview')) {
                            icon = 'xeyes.png';
                        } else if (elem.hasClassName('z-icon-es-display')) {
                            icon = 'kview.png';
                        } else if (elem.hasClassName('z-icon-es-edit')) {
                            icon = 'edit';
                        } else if (elem.hasClassName('z-icon-es-saveas')) {
                            icon = 'filesaveas';
                        } else if (elem.hasClassName('z-icon-es-delete')) {
                            icon = '14_layer_deletelayer';
                        } else if (elem.hasClassName('z-icon-es-back')) {
                            icon = 'agt_back';
                        }
                        if (icon !== '') {
                            icon = Zikula.Config.baseURL + 'images/icons/extrasmall/' + icon + '.png';
                        }
                    } else if (func === 'view') {
                        elem.select('img').each(function (imgElem) {
                            icon = imgElem.readAttribute('src');
                        });
                    }
                    if (icon !== '') {
                        icon = '<img src="' + icon + '" width="16" height="16" alt="' + linkText + '" /> ';
                    }
                «ELSE»
                    if (elem.hasClass('fa')) {
                        icon = $('<span>', { class: elemClass });
                    }
                «ENDIF»

                contextMenu.addItem({
                    label: icon + linkText,
                    callback: function (selectedMenuItem, isRightClick) {
                        var url;

                        «IF targets('1.3.5')»
                            url = elem.readAttribute('href');
                        «ELSE»
                            url = elem.attr('href');
                        «ENDIF»
                        if (isRightClick) {
                            window.open(url);
                        } else {
                            window.location = url;
                        }
                    }
                });
            });
            «IF targets('1.3.5')»
                $(triggerId).removeClassName('z-hide');
            «ELSE»
                $('#' + triggerId).removeClass('hidden');
            «ENDIF»
        }
    '''

    def private initQuickNavigation(Application it) '''
        function «prefix()»CapitaliseFirstLetter(string)
        {
            return string.charAt(0).toUpperCase() + string.slice(1);
        }

        /**
         * Submits a quick navigation form.
         */
        function «prefix()»SubmitQuickNavForm(objectType)
        {
            $('«IF !targets('1.3.5')»#«ENDIF»«appName.toLowerCase»' + «prefix()»CapitaliseFirstLetter(objectType) + 'QuickNavForm').submit();
        }

        /**
         * Initialise the quick navigation panel in list views.
         */
        function «prefix()»InitQuickNavigation(objectType)
        {
            «IF targets('1.3.5')»
                if ($('«appName.toLowerCase»' + «prefix()»CapitaliseFirstLetter(objectType) + 'QuickNavForm') == undefined) {
                    return;
                }
            «ELSE»
                if ($('#«appName.toLowerCase»' + «prefix()»CapitaliseFirstLetter(objectType) + 'QuickNavForm').size() < 1) {
                    return;
                }
            «ENDIF»

            «IF targets('1.3.5')»
                if ($('catid') != undefined) {
                    $('catid').observe('change', «initQuickNavigationSubmitCall(prefix())»);
                }
                if ($('sortby') != undefined) {
                    $('sortby').observe('change', «initQuickNavigationSubmitCall(prefix())»);
                }
                if ($('sortdir') != undefined) {
                    $('sortdir').observe('change', «initQuickNavigationSubmitCall(prefix())»);
                }
                if ($('num') != undefined) {
                    $('num').observe('change', «initQuickNavigationSubmitCall(prefix())»);
                }
            «ELSE»
                if ($('#catid').size() > 0) {
                    $('#catid').change(«initQuickNavigationSubmitCall(prefix())»);
                }
                if ($('#sortby').size() > 0) {
                    $('#sortby').change(«initQuickNavigationSubmitCall(prefix())»);
                }
                if ($('#sortdir').size() > 0) {
                    $('#sortdir').change(«initQuickNavigationSubmitCall(prefix())»);
                }
                if ($('#num').size() > 0) {
                    $('#num').change(«initQuickNavigationSubmitCall(prefix())»);
                }
            «ENDIF»

            switch (objectType) {
            «FOR entity : getAllEntities»
                «entity.initQuickNavigationEntity»
            «ENDFOR»
            default:
                break;
            }
        }
    '''

    def private initQuickNavigationSubmitCall(String prefix) '''function () { «prefix»SubmitQuickNavForm(objectType); }'''

    def private initQuickNavigationEntity(Entity it) '''
        case '«name.formatForCode»':
            «IF !getBidirectionalIncomingJoinRelationsWithOneSource.empty»
                «FOR relation: getBidirectionalIncomingJoinRelationsWithOneSource»
                    «relation.jsInit»
                «ENDFOR»
            «ENDIF»
            «IF hasListFieldsEntity»
                «FOR field : getListFieldsEntity»
                    «field.jsInit»
                «ENDFOR»
            «ENDIF»
            «IF hasUserFieldsEntity»
                «FOR field : getUserFieldsEntity»
                    «field.jsInit»
                «ENDFOR»
            «ENDIF»
            «IF hasCountryFieldsEntity»
                «FOR field : getCountryFieldsEntity»
                    «field.jsInit»
                «ENDFOR»
            «ENDIF»
            «IF hasLanguageFieldsEntity»
                «FOR field : getLanguageFieldsEntity»
                    «field.jsInit»
                «ENDFOR»
            «ENDIF»
            «IF hasLocaleFieldsEntity»
                «FOR field : getLocaleFieldsEntity»
                    «field.jsInit»
                «ENDFOR»
            «ENDIF»
            «IF hasBooleanFieldsEntity»
                «FOR field : getBooleanFieldsEntity»
                    «field.jsInit»
                «ENDFOR»
            «ENDIF»
            break;
    '''

    def private dispatch jsInit(DerivedField it) '''
        «IF entity.container.application.targets('1.3.5')»
            if ($('«name.formatForCode»') != undefined) {
                $('«name.formatForCode»').observe('change', «initQuickNavigationSubmitCall(entity.container.application.prefix())»);
            }
        «ELSE»
            if ($('#«name.formatForCode»').size() > 0) {
                $('#«name.formatForCode»').change(«initQuickNavigationSubmitCall(entity.container.application.prefix())»);
            }
        «ENDIF»
    '''

    def private dispatch jsInit(JoinRelationship it) '''
        «val sourceAliasName = getRelationAliasName(false)»
        «IF container.application.targets('1.3.5')»
            if ($('«sourceAliasName»') != undefined) {
                $('«sourceAliasName»').observe('change', «initQuickNavigationSubmitCall(container.application.prefix())»);
            }
        «ELSE»
            if ($('#«sourceAliasName»').size() > 0) {
                $('#«sourceAliasName»').change(«initQuickNavigationSubmitCall(container.application.prefix())»);
            }
        «ENDIF»
    '''

    def private initRelationWindow(Application it) '''
        «IF targets('1.3.5')»
            /**
             * Helper function to create new Zikula.UI.Window instances.
             * For edit forms we use "iframe: true" to ensure file uploads work without problems.
             * For all other windows we use "iframe: false" because we want the escape key working.
             */
         «ELSE»
            /**
             * Helper function to create new Bootstrap modal window instances.
             */
         «ENDIF»
        function «prefix()»InitInlineWindow(containerElem, title)
        {
            var newWindow«IF !targets('1.3.5')»Id«ENDIF»;

            // show the container (hidden for users without JavaScript)
            «IF targets('1.3.5')»
                containerElem.removeClassName('z-hide');
            «ELSE»
                containerElem.removeClass('hidden');
            «ENDIF»

            // define the new window instance
            «IF targets('1.3.5')»
                newWindow = new Zikula.UI.Window(
                    containerElem,
                    {
                        minmax: true,
                        resizable: true,
                        title: title,
                        width: 600,
                        initMaxHeight: 400,
                        modal: false,
                        iframe: false
                    }
                );
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
                        title: title,
                        width: 600,
                        height: 400,
                        modal: false
                    })
                    .dialog('open');
            «ENDIF»

            // return the «IF targets('1.3.5')»instance«ELSE»dialog selector id«ENDIF»;
            return newWindow«IF !targets('1.3.5')»Id«ENDIF»;
        }

    '''

    def private initToggle(Application it) '''
        /**
         * Initialise ajax-based toggle for boolean fields.
         */
        function «prefix()»InitToggle(objectType, fieldName, itemId)
        {
            var idSuffix = «prefix()»CapitaliseFirstLetter(fieldName) + itemId;
            «IF targets('1.3.5')»
                if ($('toggle' + idSuffix) == undefined) {
                    return;
                }
                $('toggle' + idSuffix).observe('click', function() {
                    «prefix()»ToggleFlag(objectType, fieldName, itemId);
                }).removeClassName('z-hide');
            «ELSE»
                if ($('#toggle' + idSuffix).size() < 1) {
                    return;
                }
                $('#toggle' + idSuffix).click( function() {
                    «prefix()»ToggleFlag(objectType, fieldName, itemId);
                }).removeClass('hidden');
            «ENDIF»
        }

    '''

    def private toggleFlag(Application it) '''
        /**
         * Toggle a certain flag for a given item.
         */
        function «prefix()»ToggleFlag(objectType, fieldName, itemId)
        {
            fieldName = «prefix()»CapitaliseFirstLetter(fieldName);
            var params = 'ot=' + objectType + '&field=' + fieldName + '&id=' + itemId;

            «IF targets('1.3.5')»
                new Zikula.Ajax.Request(
                    Zikula.Config.baseURL + 'ajax.php?module=«appName»&func=toggleFlag',
                    {
                        method: 'post',
                        parameters: params,
                        onComplete: function(req) {
                            var idSuffix = fieldName + '_' + itemId;
                            if (!req.isSuccess()) {
                                Zikula.UI.Alert(req.getMessage(), Zikula.__('Error', 'module_«appName.formatForDB»_js'));
                                return;
                            }
                            var data = req.getData();
                            /*if (data.message) {
                                Zikula.UI.Alert(data.message, Zikula.__('Success', 'module_«appName.formatForDB»_js'));
                            }*/

                            idSuffix = idSuffix.toLowerCase();
                            var state = data.state;
                            if (state === true) {
                                $('no' + idSuffix).addClassName('z-hide');
                                $('yes' + idSuffix).removeClassName('z-hide');
                            } else {
                                $('yes' + idSuffix).addClassName('z-hide');
                                $('no' + idSuffix).removeClassName('z-hide');
                            }
                        }
                    }
                );
            «ELSE»
                $.ajax({
                    type: 'POST',
                    url: Zikula.Config.baseURL + 'index.php?module=«appName»&type=ajax&func=toggleFlag',
                    data: params
                }).done(function(res) {
                    // get data returned by the ajax response
                    var idSuffix, data;

                    idSuffix = fieldName + '_' + itemId;
                    data = res.data;

                    /*if (data.message) {
                        «prefix()»SimpleAlert($('#toggle' + idSuffix), Zikula.__('Success', 'module_«appName.formatForDB»_js'), data.message, 'toggle' + idSuffix + 'DoneAlert', 'success');
                    }*/

                    idSuffix = idSuffix.toLowerCase();
                    var state = data.state;
                    if (state === true) {
                        $('#no' + idSuffix).addClass('hidden');
                        $('#yes' + idSuffix).removeClass('hidden');
                    } else {
                        $('#yes' + idSuffix).addClass('hidden');
                        $('#no' + idSuffix).removeClass('hidden');
                    }
                })«/*.fail(function(jqXHR, textStatus) {
                    // nothing to do yet
                    var idSuffix = fieldName + '_' + itemId;
                    «prefix()»SimpleAlert($('#toggle' + idSuffix), Zikula.__('Error', 'module_«appName.formatForDB»_js'), Zikula.__('Could not persist your change.', 'module_«appName.formatForDB»_js'), 'toggle' + idSuffix + 'FailedAlert', 'danger');
                })*/»;
            «ENDIF»
        }

    '''

    def private simpleAlert(Application it) '''
        /**
         * Simulates a simple alert using bootstrap.
         */
        function «prefix()»SimpleAlert(beforeElem, title, content, alertId, cssClass)
        {
            var alertBox;

            alertBox = '
                <div id="' + alertId + '" class="alert alert-' + cssClass + ' fade">
                  <button type="button" class="close" data-dismiss="alert">&times;</button>
                  <h4>' + title + '</h4>
                  <p>' + content + '</p>
                </div>';

            // insert alert before the given element
            beforeElem.before(alertBox);

            $('#' + alertId).delay(200).addClass('in').fadeOut(4000, function () {
                $(this).remove();
            });
        }
    '''
}
