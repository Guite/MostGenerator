package org.zikula.modulestudio.generator.cartridges.zclassic.controller.javascript

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.DatetimeField
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class EditFunctions {

    extension ControllerExtensions = new ControllerExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelExtensions = new ModelExtensions
    extension ModelJoinExtensions = new ModelJoinExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    /**
     * Entry point for the JavaScript file with edit functionality.
     */
    def generate(Application it, IFileSystemAccess fsa) {
        var fileName = appName + '.EditFunctions.js'
        if (!shouldBeSkipped(getAppJsPath + fileName)) {
            'Generating JavaScript for edit functions'.printIfNotTesting(fsa)
            if (shouldBeMarked(getAppJsPath + fileName)) {
                fileName = appName + '.EditFunctions.generated.js'
            }
            fsa.generateFile(getAppJsPath + fileName, generate)
        }
    }

    def private generate(Application it) '''
        'use strict';

        «IF hasUploads»
            «resetUploadField»

            «initUploadField»

        «ENDIF»
        «IF !entities.filter[!getDerivedFields.filter(DatetimeField).empty].empty || !variables.map[fields].filter(DatetimeField).empty»
            «initDateField»

        «ENDIF»
        «initEditForm»
        «IF needsInlineEditing || needsAutoCompletion»

            «initRelationHandling»
        «ENDIF»

    '''

    def private resetUploadField(Application it) '''
        /**
         * Resets the value of an upload / file input field.
         */
        function «vendorAndName»ResetUploadField(fieldName) {
            jQuery('#' + fieldName).attr('type', 'input');
            jQuery('#' + fieldName).attr('type', 'file');
        }
    '''

    def private initUploadField(Application it) '''
        /**
         * Initialises the reset button for a certain upload input.
         */
        function «vendorAndName»InitUploadField(fieldName) {
            jQuery('#' + fieldName + 'ResetVal').click(function (event) {
                event.preventDefault();
                «vendorAndName»ResetUploadField(fieldName);
            }).removeClass('hidden');
        }
    '''

    def private initDateField(Application it) '''
        /**
         * Initialises the reset button for a certain date input.
         */
        function «vendorAndName»InitDateField(fieldName) {
            jQuery('#' + fieldName + 'ResetVal').click(function (event) {
                event.preventDefault();
                jQuery('#' + fieldName).val('');
            }).removeClass('hidden');
        }
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

        function «vendorAndName»HandleFormSubmit (event) {
            if (triggerValidation) {
                «vendorAndName»TriggerFormValidation();
                if (!editForm.get(0).checkValidity()) {
                    event.preventDefault();
                    return false;
                }
            }

            // hide form buttons to prevent double submits by accident
            formButtons.each(function (index) {
                jQuery(this).addClass('hidden');
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
                    jQuery('#moderationFieldsContent').addClass('hidden');
                    jQuery('#moderationFieldsSection legend').addClass('pointer').click(function (event) {
                        if (jQuery('#moderationFieldsContent').hasClass('hidden')) {
                            jQuery('#moderationFieldsContent').removeClass('hidden');
                            jQuery(this).find('i').removeClass('fa-expand').addClass('fa-compress');
                        } else {
                            jQuery('#moderationFieldsContent').addClass('hidden');
                            jQuery(this).find('i').removeClass('fa-compress').addClass('fa-expand');
                        }
                    });
                }
            «ENDIF»

            var allFormFields = editForm.find('input, select, textarea');
            allFormFields.change(function (event) {
                «vendorAndName»ExecuteCustomValidationConstraints(editedObjectType, editedEntityId);
            });

            formButtons = editForm.find('.form-buttons input');
            if (editForm.find('.btn-danger').length > 0) {
                editForm.find('.btn-danger').first().bind('click keypress', function (event) {
                    if (!window.confirm(Translator.__('Do you really want to delete this entry?'))) {
                        event.preventDefault();
                    }
                });
            }
            editForm.find('button[type=submit]').bind('click keypress', function (event) {
                triggerValidation = !jQuery(this).prop('formnovalidate');
            });
            editForm.submit(«vendorAndName»HandleFormSubmit);

            if (mode != 'create') {
                «vendorAndName»TriggerFormValidation();
            }
        }
    '''

    def private initRelationHandling(Application it) '''
        /**
         * Initialises a relation field section with «IF needsAutoCompletion»autocompletion «ENDIF»«IF needsInlineEditing»«IF needsAutoCompletion»and «ENDIF»optional edit capabilities«ENDIF».
         */
        function «vendorAndName»InitRelationHandling(objectType, alias, idPrefix, includeEditing, inputType, createUrl) {
            «IF needsAutoCompletion»
                if (inputType == 'autocomplete') {
                    «vendorAndName»InitAutoCompletion(objectType, alias, includeEditing);
                }
            «ENDIF»
            «IF needsInlineEditing»
                if (includeEditing) {
                    «vendorAndName»InitInlineEditingButtons(objectType, alias, idPrefix, inputType, createUrl);
                }
            «ENDIF»
        }
	'''
}
