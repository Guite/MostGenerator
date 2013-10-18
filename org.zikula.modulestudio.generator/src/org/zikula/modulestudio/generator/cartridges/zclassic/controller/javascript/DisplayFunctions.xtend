package org.zikula.modulestudio.generator.cartridges.zclassic.controller.javascript

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Application
import de.guite.modulestudio.metamodel.modulestudio.DerivedField
import de.guite.modulestudio.metamodel.modulestudio.Entity
import de.guite.modulestudio.metamodel.modulestudio.JoinRelationship
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.GeneratorSettingsExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class DisplayFunctions {
    @Inject extension ControllerExtensions = new ControllerExtensions
    @Inject extension FormattingExtensions = new FormattingExtensions
    @Inject extension GeneratorSettingsExtensions = new GeneratorSettingsExtensions
    @Inject extension ModelExtensions = new ModelExtensions
    @Inject extension ModelJoinExtensions = new ModelJoinExtensions
    @Inject extension NamingExtensions = new NamingExtensions
    @Inject extension Utils = new Utils

    /**
     * Entry point for the javascript file with display functionality.
     */
    def generate(Application it, IFileSystemAccess fsa) {
        if (!shouldBeSkipped(getAppJsPath + appName + '.js')) {
            println('Generating javascript for display functions')
            fsa.generateFile(getAppJsPath + appName + '.js', generate)
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
    '''

    def private initItemActions(Application it) '''
        var «prefix()»ContextMenu;

        «prefix()»ContextMenu = Class.create(Zikula.UI.ContextMenu, {
            selectMenuItem: function ($super, event, item, item_container) {
                // open in new tab / window when right-clicked
                if (event.isRightClick()) {
                    item.callback(this.clicked, true);
                    event.stop(); // close the menu
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
            $$('#' + containerId + ' a').each(function (elem) {
                // hide it
                elem.addClassName('«IF targets('1.3.5')»z-«ENDIF»hide');
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
                        linkText = elem.readAttribute('data-linktext');
                    «ENDIF»
                }

                // determine the icon
                «IF targets('1.3.5')»
                    icon = '';
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
                    if (elem.hasClassName('icon')) {
                        icon = '<span class="' + elem.readAttribute('class') + '"></span>';
                    }
                «ENDIF»

                contextMenu.addItem({
                    label: icon + linkText,
                    callback: function (selectedMenuItem, isRightClick) {
                        var url;

                        url = elem.readAttribute('href');
                        if (isRightClick) {
                            window.open(url);
                        } else {
                            window.location = url;
                        }
                    }
                });
            });
            $(triggerId).removeClassName('«IF targets('1.3.5')»z-«ENDIF»hide');
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
            $('«appName.toLowerCase»' + «prefix()»CapitaliseFirstLetter(objectType) + 'QuickNavForm').submit();
        }

        /**
         * Initialise the quick navigation panel in list views.
         */
        function «prefix()»InitQuickNavigation(objectType, controller)
        {
            if ($('«appName.toLowerCase»' + «prefix()»CapitaliseFirstLetter(objectType) + 'QuickNavForm') == undefined) {
                return;
            }

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
            «IF hasBooleanFieldsEntity»
                «FOR field : getBooleanFieldsEntity»
                    «field.jsInit»
                «ENDFOR»
            «ENDIF»
            break;
    '''

    def private dispatch jsInit(DerivedField it) '''
        if ($('«name.formatForCode»') != undefined) {
            $('«name.formatForCode»').observe('change', «initQuickNavigationSubmitCall(entity.container.application.prefix)»);
        }
    '''

    def private dispatch jsInit(JoinRelationship it) '''
        «val sourceAliasName = getRelationAliasName(false)»
        if ($('«sourceAliasName»') != undefined) {
            $('«sourceAliasName»').observe('change', «initQuickNavigationSubmitCall(container.application.prefix)»);
        }
    '''

    def private initRelationWindow(Application it) '''
        /**
         * Helper function to create new Zikula.UI.Window instances.
         * For edit forms we use "iframe: true" to ensure file uploads work without problems.
         * For all other windows we use "iframe: false" because we want the escape key working.
         */
        function «prefix()»InitInlineWindow(containerElem, title)
        {
            var newWindow;

            // show the container (hidden for users without JavaScript)
            containerElem.removeClassName('«IF targets('1.3.5')»z-«ENDIF»hide');

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

            // return the instance
            return newWindow;
        }

    '''

    def private initToggle(Application it) '''
        /**
         * Initialise ajax-based toggle for boolean fields.
         */
        function «prefix()»InitToggle(objectType, fieldName, itemId)
        {
            var idSuffix = fieldName + itemId;
            if ($('toggle' + idSuffix) == undefined) {
                return;
            }
            $('toggle' + idSuffix).observe('click', function() {
                «prefix()»ToggleFlag(objectType, fieldName, itemId);
            }).removeClassName('«IF targets('1.3.5')»z-«ENDIF»hide');
        }

    '''

    def private toggleFlag(Application it) '''
        /**
         * Toggle a certain flag for a given item.
         */
        function «prefix()»ToggleFlag(objectType, fieldName, itemId)
        {
            var pars = 'ot=' + objectType + '&field=' + fieldName + '&id=' + itemId;

            new Zikula.Ajax.Request(
                Zikula.Config.baseURL + '«IF targets('1.3.5')»ajax«ELSE»index«ENDIF».php?module=«appName»«IF !targets('1.3.5')»&type=ajax«ENDIF»&func=toggleFlag',
                {
                    method: 'post',
                    parameters: pars,
                    onComplete: function(req) {
                        if (!req.isSuccess()) {
                            Zikula.UI.Alert(req.getMessage(), Zikula.__('Error', 'module_«appName»'));
                            return;
                        }
                        var data = req.getData();
                        /*if (data.message) {
                            Zikula.UI.Alert(data.message, Zikula.__('Success', 'module_«appName»'));
                        }*/

                        var idSuffix = fieldName + '_' + itemId;
                        var state = data.state;
                        if (state === true) {
                            $('no' + idSuffix).addClassName('«IF targets('1.3.5')»z-«ENDIF»hide');
                            $('yes' + idSuffix).removeClassName('«IF targets('1.3.5')»z-«ENDIF»hide');
                        } else {
                            $('yes' + idSuffix).addClassName('«IF targets('1.3.5')»z-«ENDIF»hide');
                            $('no' + idSuffix).removeClassName('«IF targets('1.3.5')»z-«ENDIF»hide');
                        }
                    }
                }
            );
        }
    '''
}
