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

        «simpleAlert»
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
            jQuery('#«appName.toLowerCase»' + «vendorAndName»CapitaliseFirstLetter(objectType) + 'QuickNavForm').submit();
        }

        /**
         * Initialise the quick navigation panel in list views.
         */
        function «vendorAndName»InitQuickNavigation(objectType)
        {
            if (jQuery('#«appName.toLowerCase»' + «vendorAndName»CapitaliseFirstLetter(objectType) + 'QuickNavForm').length < 1) {
                return;
            }

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
        if (jQuery('#' + fieldPrefix + '«name.formatForCode»').length > 0) {
            jQuery('#' + fieldPrefix + '«name.formatForCode»').change(«initQuickNavigationSubmitCall(entity.application)»);
        }
    '''

    def private dispatch jsInit(JoinRelationship it) '''
        «val sourceAliasName = getRelationAliasName(false)»
        if (jQuery('#' + fieldPrefix + '«sourceAliasName.formatForDB»').length > 0) {
            jQuery('#' + fieldPrefix + '«sourceAliasName.formatForDB»').change(«initQuickNavigationSubmitCall(application)»);
        }
    '''

    def private initRelationWindow(Application it) '''
        /**
         * Helper function to create new Bootstrap modal window instances.
         */
        function «vendorAndName»InitInlineWindow(containerElem, title)
        {
            var newWindowId;

            // show the container (hidden for users without JavaScript)
            containerElem.removeClass('hidden');

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

            // return the dialog selector id;
            return newWindowId;
        }

    '''

    def private initToggle(Application it) '''
        /**
         * Initialise ajax-based toggle for boolean fields.
         */
        function «vendorAndName»InitToggle(objectType, fieldName, itemId)
        {
            var idSuffix = «vendorAndName»CapitaliseFirstLetter(fieldName) + itemId;
            if (jQuery('#toggle' + idSuffix).length < 1) {
                return;
            }
            jQuery('#toggle' + idSuffix).click( function() {
                «vendorAndName»ToggleFlag(objectType, fieldName, itemId);
            }).removeClass('hidden');
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
                    «vendorAndName»SimpleAlert(jQuery('#toggle' + idSuffix), Translator.__('Success'), data.message, 'toggle' + idSuffix + 'DoneAlert', 'success');
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
                «vendorAndName»SimpleAlert(jQuery('#toggle' + idSuffix), Translator.__('Error'), Translator.__('Could not persist your change.'), 'toggle' + idSuffix + 'FailedAlert', 'danger');
            })*/»;
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
