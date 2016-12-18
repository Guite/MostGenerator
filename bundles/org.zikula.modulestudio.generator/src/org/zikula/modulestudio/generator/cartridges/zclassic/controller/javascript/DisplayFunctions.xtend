package org.zikula.modulestudio.generator.cartridges.zclassic.controller.javascript

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.DerivedField
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.JoinRelationship
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class DisplayFunctions {
    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension ModelJoinExtensions = new ModelJoinExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

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
        «IF targets('1.3.x')»

            «initItemActions»
        «ENDIF»
        «IF !controllers.map[hasActions('view')].empty»

            «initQuickNavigation»
        «ENDIF»
        «IF !getJoinRelations.empty»

            «initRelationWindow»
        «ENDIF»
        «IF hasBooleansWithAjaxToggle»

            «initToggle»

            «toggleFlag»
        «ENDIF»
        «IF !targets('1.3.x')»

            «simpleAlert»
        «ENDIF»
    '''

    def private initItemActions(Application it) '''
        var «vendorAndName»ContextMenu;

        «vendorAndName»ContextMenu = Class.create(Zikula.UI.ContextMenu, {
            selectMenuItem: function ($super, event, item, item_container) {
                // open in new tab / window when right-clicked
                if (event.isRightClick()) {
                    item.callback(this.clicked, true);
                    «IF targets('1.3.x')»
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
        function «vendorAndName»InitItemActions(objectType, func, containerId)
        {
            var triggerId, contextMenu, icon;

            triggerId = containerId + 'Trigger';

            // attach context menu
            contextMenu = new «vendorAndName»ContextMenu(triggerId, { leftClick: true, animation: false });

            // process normal links
            «IF targets('1.3.x')»$$«ELSE»jQuery«ENDIF»('#' + containerId + ' a').each(function («IF targets('1.3.x')»elem«ELSE»index«ENDIF») {
                «IF !targets('1.3.x')»
                    var elem = jQuery(this);
                    // save css class before hiding (#428)
                    var elemClass = elem.attr('class');
                «ENDIF»
                // hide it
                «IF targets('1.3.x')»
                    elem.addClassName('z-hide');
                «ELSE»
                    elem.addClass('hidden');
                «ENDIF»
                // determine the link text
                var linkText = '';
                if (func === 'display') {
                    linkText = elem.innerHTML;
                } else if (func === 'view') {
                    «IF targets('1.3.x')»
                        elem.select('img').each(function (imgElem) {
                            linkText = imgElem.readAttribute('alt');
                        });
                    «ELSE»
                        linkText = elem.attr('data-linktext');
                    «ENDIF»
                }

                // determine the icon
                icon = '';
                «IF targets('1.3.x')»
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
                        icon = jQuery('<i>', { class: elemClass });
                    }
                «ENDIF»

                contextMenu.addItem({
                    label: icon + linkText,
                    callback: function (selectedMenuItem, isRightClick) {
                        var url;

                        «IF targets('1.3.x')»
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
            «IF targets('1.3.x')»
                $(triggerId).removeClassName('z-hide');
            «ELSE»
                jQuery('#' + triggerId).removeClass('hidden');
            «ENDIF»
        }
    '''

    def private initQuickNavigation(Application it) '''
        function «vendorAndName»CapitaliseFirstLetter(string)
        {
            return string.charAt(0).toUpperCase() + string.substring(1);
        }

        /**
         * Submits a quick navigation form.
         */
        function «vendorAndName»SubmitQuickNavForm(objectType)
        {
            «IF targets('1.3.x')»$('«ELSE»jQuery('#«ENDIF»«appName.toLowerCase»' + «vendorAndName»CapitaliseFirstLetter(objectType) + 'QuickNavForm').submit();
        }

        /**
         * Initialise the quick navigation panel in list views.
         */
        function «vendorAndName»InitQuickNavigation(objectType)
        {
            «IF targets('1.3.x')»
                if ($('«appName.toLowerCase»' + «vendorAndName»CapitaliseFirstLetter(objectType) + 'QuickNavForm') == undefined) {
                    return;
                }
            «ELSE»
                if (jQuery('#«appName.toLowerCase»' + «vendorAndName»CapitaliseFirstLetter(objectType) + 'QuickNavForm').length < 1) {
                    return;
                }
            «ENDIF»

            «IF targets('1.3.x')»
                if ($('catid') != undefined) {
                    $('catid').observe('change', «initQuickNavigationSubmitCall»);
                }
                if ($('sortBy') != undefined) {
                    $('sortBy').observe('change', «initQuickNavigationSubmitCall»);
                }
                if ($('sortDir') != undefined) {
                    $('sortDir').observe('change', «initQuickNavigationSubmitCall»);
                }
                if ($('num') != undefined) {
                    $('num').observe('change', «initQuickNavigationSubmitCall»);
                }
            «ELSE»
                var fieldPrefix = '«appName.formatForDB»_' + objectType.toLowerCase() + 'quicknav_';
                if (jQuery('#' + fieldPrefix + 'catid').length > 0) {
                    jQuery('#' + fieldPrefix + 'catid').change(«initQuickNavigationSubmitCall»);
                }
                if (jQuery('#' + fieldPrefix + 'sortBy').length > 0) {
                    jQuery('#' + fieldPrefix + 'sortBy').change(«initQuickNavigationSubmitCall»);
                }
                if (jQuery('#' + fieldPrefix + 'sortDir').length > 0) {
                    jQuery('#' + fieldPrefix + 'sortDir').change(«initQuickNavigationSubmitCall»);
                }
                if (jQuery('#' + fieldPrefix + 'num').length > 0) {
                    jQuery('#' + fieldPrefix + 'num').change(«initQuickNavigationSubmitCall»);
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

    def private initQuickNavigationSubmitCall(Application it) '''function () { «vendorAndName»SubmitQuickNavForm(objectType); }'''

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
        «IF entity.application.targets('1.3.x')»
            if ($('«name.formatForCode»') != undefined) {
                $('«name.formatForCode»').observe('change', «initQuickNavigationSubmitCall(entity.application)»);
            }
        «ELSE»
            if (jQuery('#' + fieldPrefix + '«name.formatForCode»').length > 0) {
                jQuery('#' + fieldPrefix + '«name.formatForCode»').change(«initQuickNavigationSubmitCall(entity.application)»);
            }
        «ENDIF»
    '''

    def private dispatch jsInit(JoinRelationship it) '''
        «val sourceAliasName = getRelationAliasName(false)»
        «IF application.targets('1.3.x')»
            if ($('«sourceAliasName»') != undefined) {
                $('«sourceAliasName»').observe('change', «initQuickNavigationSubmitCall(application)»);
            }
        «ELSE»
            if (jQuery('#' + fieldPrefix + '«sourceAliasName.formatForDB»').length > 0) {
                jQuery('#' + fieldPrefix + '«sourceAliasName.formatForDB»').change(«initQuickNavigationSubmitCall(application)»);
            }
        «ENDIF»
    '''

    def private initRelationWindow(Application it) '''
        «IF targets('1.3.x')»
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
        function «vendorAndName»InitInlineWindow(containerElem, title)
        {
            var newWindow«IF !targets('1.3.x')»Id«ENDIF»;

            // show the container (hidden for users without JavaScript)
            «IF targets('1.3.x')»
                containerElem.removeClassName('z-hide');
            «ELSE»
                containerElem.removeClass('hidden');
            «ENDIF»

            «IF targets('1.3.x')»
                // define the new window instance
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
                // define name of window
                newWindowId = containerElem.attr('id') + 'Dialog';

                containerElem.unbind('click').click(function(e) {
                    e.preventDefault();

                    // check if window exists already
                    if (jQuery('#' + newWindowId).length < 1) {
                        // create new window instance
                        jQuery('<div id="' + newWindowId + '"></div>')
                            .append(
                                jQuery('<iframe width="100%" height="100%" marginWidth="0" marginHeight="0" frameBorder="0" scrolling="auto" />')
                                    .attr('src', containerElem.attr('href'))
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
                                title: title,
                                width: 600,
                                height: 400,
                                modal: false
                            });
                    }

                    // open the window
                    jQuery('#' + newWindowId).dialog('open');
                });
            «ENDIF»

            // return the «IF targets('1.3.x')»instance«ELSE»dialog selector id«ENDIF»;
            return newWindow«IF !targets('1.3.x')»Id«ENDIF»;
        }

    '''

    def private initToggle(Application it) '''
        /**
         * Initialise ajax-based toggle for boolean fields.
         */
        function «vendorAndName»InitToggle(objectType, fieldName, itemId)
        {
            var idSuffix = «vendorAndName»CapitaliseFirstLetter(fieldName) + itemId;
            «IF targets('1.3.x')»
                if ($('toggle' + idSuffix) == undefined) {
                    return;
                }
                $('toggle' + idSuffix).observe('click', function() {
                    «vendorAndName»ToggleFlag(objectType, fieldName, itemId);
                }).removeClassName('z-hide');
            «ELSE»
                if (jQuery('#toggle' + idSuffix).length < 1) {
                    return;
                }
                jQuery('#toggle' + idSuffix).click( function() {
                    «vendorAndName»ToggleFlag(objectType, fieldName, itemId);
                }).removeClass('hidden');
            «ENDIF»
        }

    '''

    def private toggleFlag(Application it) '''
        /**
         * Toggles a certain flag for a given item.
         */
        function «vendorAndName»ToggleFlag(objectType, fieldName, itemId)
        {
            var fieldNameCapitalised = «vendorAndName»CapitaliseFirstLetter(fieldName);
            var params = 'ot=' + objectType + '&field=' + fieldName + '&id=' + itemId;

            «IF targets('1.3.x')»
                new Zikula.Ajax.Request(
                    Zikula.Config.baseURL + 'ajax.php?module=«appName»&func=toggleFlag',
                    {
                        method: 'post',
                        parameters: params,
                        onComplete: function(req) {
                            var idSuffix = fieldNameCapitalised + '_' + itemId;
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
                            if (true === state) {
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
                jQuery.ajax({
                    type: 'POST',
                    url: Routing.generate('«appName.formatForDB»_ajax_toggleflag'),
                    data: params
                }).done(function(res) {
                    // get data returned by the ajax response
                    var idSuffix, data;

                    idSuffix = fieldName + '_' + itemId;
                    data = res.data;

                    /*if (data.message) {
                        «vendorAndName»SimpleAlert(jQuery('#toggle' + idSuffix), Zikula.__('Success', '«appName.formatForDB»_js'), data.message, 'toggle' + idSuffix + 'DoneAlert', 'success');
                    }*/

                    idSuffix = idSuffix.toLowerCase();
                    var state = data.state;
                    if (true === state) {
                        jQuery('#no' + idSuffix).addClass('hidden');
                        jQuery('#yes' + idSuffix).removeClass('hidden');
                    } else {
                        jQuery('#yes' + idSuffix).addClass('hidden');
                        jQuery('#no' + idSuffix).removeClass('hidden');
                    }
                })«/*.fail(function(jqXHR, textStatus) {
                    // nothing to do yet
                    var idSuffix = fieldName + '_' + itemId;
                    «vendorAndName»SimpleAlert(jQuery('#toggle' + idSuffix), Zikula.__('Error', '«appName.formatForDB»_js'), Zikula.__('Could not persist your change.', '«appName.formatForDB»_js'), 'toggle' + idSuffix + 'FailedAlert', 'danger');
                })*/»;
            «ENDIF»
        }

    '''

    def private simpleAlert(Application it) '''
        /**
         * Simulates a simple alert using bootstrap.
         */
        function «vendorAndName»SimpleAlert(beforeElem, title, content, alertId, cssClass)
        {
            var alertBox;

            alertBox = ' \
                <div id="' + alertId + '" class="alert alert-' + cssClass + ' fade"> \
                  <button type="button" class="close" data-dismiss="alert">&times;</button> \
                  <h4>' + title + '</h4> \
                  <p>' + content + '</p> \
                </div>';

            // insert alert before the given element
            beforeElem.before(alertBox);

            jQuery('#' + alertId).delay(200).addClass('in').fadeOut(4000, function () {
                jQuery(this).remove();
            });
        }
    '''
}
