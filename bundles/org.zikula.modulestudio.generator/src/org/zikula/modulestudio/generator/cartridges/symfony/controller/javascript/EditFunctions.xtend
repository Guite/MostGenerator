package org.zikula.modulestudio.generator.cartridges.symfony.controller.javascript

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class EditFunctions {

    extension ControllerExtensions = new ControllerExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    /**
     * Entry point for the JavaScript file with edit functionality.
     */
    def generate(Application it, IMostFileSystemAccess fsa) {
        'Generating JavaScript for edit functions'.printIfNotTesting(fsa)
        val fileName = appName + '.EditFunctions.js'
        fsa.generateFile(getAppJsPath + fileName, generate)
    }

    def private generate(Application it) '''
        'use strict';

        «initEditForm»
        «IF needsInlineEditing»

            «initRelationHandling»
        «ENDIF»

        «onLoad»
    '''

    def private initEditForm(Application it) '''
        var editedObjectType;
        var editedEntityId;
        var editForm;
        var formButtons;
        var triggerValidation = true;

        function «vendorAndName»TriggerFormValidation() {
            «vendorAndName»ExecuteCustomValidationConstraints(editedObjectType, editedEntityId);

            if (!editForm.get(0).checkValidity()) {
                // This does not really submit the form,
                // but causes the browser to display the error message
                editForm.find(':submit').first().click();
            }
        }

        function «vendorAndName»HandleFormSubmit(event) {
            if (triggerValidation) {
                «vendorAndName»TriggerFormValidation();
                if (!editForm.get(0).checkValidity()) {
                    event.preventDefault();
                    return false;
                }
            }

            // hide form buttons to prevent double submits by accident
            formButtons.each(function (index) {
                jQuery(this).addClass('d-none');
            });

            return true;
        }

        /**
         * Initialises an entity edit form.
         */
        function «vendorAndName»InitEditForm(mode, entityId) {
            if (jQuery('.«vendorAndName.toLowerCase»-edit-form').length < 1) {
                return;
            }

            editForm = jQuery('.«vendorAndName.toLowerCase»-edit-form').first();
            editedObjectType = editForm.attr('id').replace('EditForm', '');
            editedEntityId = entityId;
            «IF hasStandardFieldEntities»

                if (jQuery('#moderationFieldsSection').length > 0) {
                    jQuery('#moderationFieldsContent').addClass('d-none');
                    jQuery('#moderationFieldsSection legend').css({cursor: 'pointer'}).click(function (event) {
                        if (jQuery('#moderationFieldsContent').hasClass('d-none')) {
                            jQuery('#moderationFieldsContent').removeClass('d-none');
                            jQuery(this).find('i').removeClass('fa-expand').addClass('fa-compress');
                        } else {
                            jQuery('#moderationFieldsContent').addClass('d-none');
                            jQuery(this).find('i').removeClass('fa-compress').addClass('fa-expand');
                        }
                    });
                }
            «ENDIF»

            var allFormFields = editForm.find('input, select, textarea');
            allFormFields.change(function (event) {
                «vendorAndName»ExecuteCustomValidationConstraints(editedObjectType, editedEntityId);
            });

            formButtons = editForm.find('.form-buttons input, .form-buttons button');
            if (editForm.find('.btn-danger').length > 0) {
                editForm.find('.btn-danger').first().bind('click keypress', function (event) {
                    if (!window.confirm(Translator.trans('Do you really want to delete this entry?'))) {
                        event.preventDefault();
                    }
                });
            }
            editForm.find('button[type=submit]').bind('click keypress', function (event) {
                triggerValidation = !jQuery(this).attr«/* use attr instead of prop to fix #1180 */»('formnovalidate');
            });
            editForm.submit(«vendorAndName»HandleFormSubmit);

            if ('create' !== mode) {
                «vendorAndName»TriggerFormValidation();
            }
        }
    '''

    def private initRelationHandling(Application it) '''
        /**
         * Initialises a relation field section with «IF needsInlineEditing»optional edit capabilities«ENDIF».
         */
        function «vendorAndName»InitRelationHandling(objectType, alias, idPrefix, includeEditing, inputType, createUrl) {
            «IF needsInlineEditing»
                if (includeEditing) {
                    «vendorAndName»InitInlineEditingButtons(objectType, alias, idPrefix, inputType, createUrl);
                }
            «ENDIF»
        }
    '''

    def private onLoad(Application it) '''
        jQuery(document).ready(function () {
            «IF needsInlineEditing»
                if (jQuery('.relation-editing-definition').length > 0) {
                    jQuery('.relation-editing-definition').each(function (index) {
                        «IF needsInlineEditing»
                            var editHandler = {
                                alias: jQuery(this).data('alias'),
                                prefix: jQuery(this).data('inline-prefix'),
                                moduleName: jQuery(this).data('module-name'),
                                objectType: jQuery(this).data('object-type'),
                                inputType: jQuery(this).data('input-type'),
                                windowInstanceId: null
                            };
                            «vendorAndName»InlineEditHandlers.push(editHandler);
                        «ENDIF»
                        «vendorAndName»InitRelationHandling(
                            jQuery(this).data('object-type'),
                            jQuery(this).data('alias'),
                            jQuery(this).data('prefix'),
                            '1' == jQuery(this).data('include-editing'),
                            jQuery(this).data('input-type'),
                            jQuery(this).data('create-url')
                        );
                    });
                }
            «ENDIF»
            if (jQuery('#formEditingDefinition').length > 0) {
                «vendorAndName»InitEditForm(jQuery('#formEditingDefinition').data('mode'), jQuery('#formEditingDefinition').data('entityid'));
            }
        });
    '''
}
