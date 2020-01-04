package org.zikula.modulestudio.generator.cartridges.zclassic.controller.javascript

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ItemSelector {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    /**
     * Entry point for the JavaScript file with item selector functionality.
     */
    def generate(Application it, IMostFileSystemAccess fsa) {
        if (targets('2.0')) {
            return;
        }
        val needsDetailContentType = generateDetailContentType && hasDisplayActions
        if (!needsDetailContentType) {
            return
        }
        'Generating JavaScript for item selector component'.printIfNotTesting(fsa)
        val fileName = appName + '.ItemSelector.js'
        fsa.generateFile(getAppJsPath + fileName, generate)
    }

    def private generate(Application it) '''
        'use strict';

        «val elemPrefix = appName.toFirstLower»
        «val objName = appName.toFirstLower»
        var «objName» = {};

        «objName».itemSelector = {};
        «objName».itemSelector.items = {};
        «objName».itemSelector.baseId = 0;
        «objName».itemSelector.selectedId = 0;

        «objName».itemSelector.onLoad = function (baseId, selectedId) {
            «objName».itemSelector.baseId = baseId;
            «objName».itemSelector.selectedId = selectedId;

            // required as a changed object type requires a new instance of the item selector plugin
            jQuery('#«elemPrefix»ObjectType').change(«objName».itemSelector.onParamChanged);

            jQuery('#' + baseId + '_catidMain').change(«objName».itemSelector.onParamChanged);
            jQuery('#' + baseId + '_catidsMain').change(«objName».itemSelector.onParamChanged);
            jQuery('#' + baseId + 'Id').change(«objName».itemSelector.onItemChanged);
            jQuery('#' + baseId + 'Sort').change(«objName».itemSelector.onParamChanged);
            jQuery('#' + baseId + 'SortDir').change(«objName».itemSelector.onParamChanged);
            jQuery('#«elemPrefix»SearchGo').click(«objName».itemSelector.onParamChanged);
            jQuery('#«elemPrefix»SearchGo').keypress(«objName».itemSelector.onParamChanged);

            «objName».itemSelector.getItemList();
        };

        «objName».itemSelector.onParamChanged = function () {
            jQuery('#ajaxIndicator').removeClass('«IF targets('3.0')»d-none«ELSE»hidden«ENDIF»');

            «objName».itemSelector.getItemList();
        };

        «objName».itemSelector.getItemList = function () {
            var baseId;
            var params;

            baseId = «objName».itemSelector.baseId;
            params = {
                ot: baseId,
                sort: jQuery('#' + baseId + 'Sort').val(),
                sortdir: jQuery('#' + baseId + 'SortDir').val(),
                q: jQuery('#' + baseId + 'SearchTerm').val()
            }
            if (jQuery('#' + baseId + '_catidMain').length > 0) {
                params[catidMain] = jQuery('#' + baseId + '_catidMain').val();
            } else if (jQuery('#' + baseId + '_catidsMain').length > 0) {
                params[catidsMain] = jQuery('#' + baseId + '_catidsMain').val();
            }

            jQuery.getJSON(Routing.generate('«appName.formatForDB»_ajax_getitemlistfinder'), params, function (data) {
                var baseId;

                baseId = «objName».itemSelector.baseId;
                «objName».itemSelector.items[baseId] = data;
                jQuery('#ajaxIndicator').addClass('«IF targets('3.0')»d-none«ELSE»hidden«ENDIF»');
                «objName».itemSelector.updateItemDropdownEntries();
                «objName».itemSelector.updatePreview();
            });
        };

        «objName».itemSelector.updateItemDropdownEntries = function () {
            var baseId, itemSelector, items, i, item;

            baseId = «objName».itemSelector.baseId;
            itemSelector = jQuery('#' + baseId + 'Id');
            itemSelector.length = 0;

            items = «objName».itemSelector.items[baseId];
            for (i = 0; i < items.length; ++i) {
                item = items[i];
                itemSelector.get(0).options[i] = new Option(item.title, item.id, false);
            }

            if («objName».itemSelector.selectedId > 0) {
                jQuery('#' + baseId + 'Id').val(«objName».itemSelector.selectedId);
            }
        };

        «objName».itemSelector.updatePreview = function () {
            var baseId, items, selectedElement, i;

            baseId = «objName».itemSelector.baseId;
            items = «objName».itemSelector.items[baseId];

            jQuery('#' + baseId + 'PreviewContainer').addClass('«IF targets('3.0')»d-none«ELSE»hidden«ENDIF»');

            if (items.length === 0) {
                return;
            }

            selectedElement = items[0];
            if («objName».itemSelector.selectedId > 0) {
                for (var i = 0; i < items.length; ++i) {
                    if (items[i].id == «objName».itemSelector.selectedId) {
                        selectedElement = items[i];
                        break;
                    }
                }
            }

            if (null !== selectedElement) {
                jQuery('#' + baseId + 'PreviewContainer')
                    .html(window.atob(selectedElement.previewInfo))
                    .removeClass('«IF targets('3.0')»d-none«ELSE»hidden«ENDIF»');
                «IF hasImageFields»
                    «vendorAndName»InitImageViewer();
                «ENDIF»
            }
        };

        «objName».itemSelector.onItemChanged = function () {
            var baseId, itemSelector, preview;

            baseId = «objName».itemSelector.baseId;
            itemSelector = jQuery('#' + baseId + 'Id').get(0);
            preview = window.atob(«objName».itemSelector.items[baseId][itemSelector.selectedIndex].previewInfo);

            jQuery('#' + baseId + 'PreviewContainer').html(preview);
            «objName».itemSelector.selectedId = jQuery('#' + baseId + 'Id').val();
            «IF hasImageFields»
                «vendorAndName»InitImageViewer();
            «ENDIF»
        };

        jQuery(document).ready(function () {
            var infoElem;

            infoElem = jQuery('#itemSelectorInfo');
            if (infoElem.length == 0) {
                return;
            }

            «objName».itemSelector.onLoad(infoElem.data('base-id'), infoElem.data('selected-id'));
        });
    '''
}
