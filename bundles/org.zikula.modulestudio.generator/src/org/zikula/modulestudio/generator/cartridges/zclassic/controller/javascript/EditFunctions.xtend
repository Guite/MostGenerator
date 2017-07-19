package org.zikula.modulestudio.generator.cartridges.zclassic.controller.javascript

import de.guite.modulestudio.metamodel.AbstractDateField
import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class EditFunctions {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelExtensions = new ModelExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    /**
     * Entry point for the JavaScript file with edit functionality.
     */
    def generate(Application it, IFileSystemAccess fsa) {
        var fileName = appName + '.EditFunctions.js'
        if (!shouldBeSkipped(getAppJsPath + fileName)) {
            println('Generating JavaScript for edit functions')
            if (shouldBeMarked(getAppJsPath + fileName)) {
                fileName = appName + '.EditFunctions.generated.js'
            }
            fsa.generateFile(getAppJsPath + fileName, generate)
        }
    }

    def private generate(Application it) '''
        'use strict';

        «IF hasUserFields || hasStandardFieldEntities»
            «initUserField»

        «ENDIF»
        «IF hasUploads»
            «resetUploadField»

            «initUploadField»

        «ENDIF»
        «IF !entities.filter[!getDerivedFields.filter(AbstractDateField).empty].empty»
            «initDateField»

        «ENDIF»
        «initEditForm»
    '''

    def private initUserField(Application it) '''
        «IF needsUserAutoCompletion && !targets('1.5')»
            /**
             * Initialises a user field with auto completion.
             */
            function «vendorAndName»InitUserField(fieldName)
            {
                jQuery('#' + fieldName + 'ResetVal').click( function (event) {
                    event.preventDefault();
                    jQuery('#' + fieldName).val('');
                    jQuery('#' + fieldName + 'Selector').val('');
                }).removeClass('hidden');

                if (jQuery('#' + fieldName + 'LiveSearch').length < 1) {
                    return;
                }
                jQuery('#' + fieldName + 'LiveSearch').removeClass('hidden');

                jQuery('#' + fieldName + 'Selector').autocomplete({
                    minLength: 1,
                    open: function(event, ui) {
                        jQuery(this).autocomplete('widget').css({
                            width: (jQuery(this).outerWidth() + 'px')
                        });
                    },
                    source: function (request, response) {
                        jQuery.getJSON(Routing.generate('«appName.formatForDB»_ajax_searchusers', { fragment: request.term }), function(data) {
                            response(data);
                        });
                    },
                    response: function(event, ui) {
                        jQuery('#' + fieldName + 'LiveSearch .empty-message').remove();
                        if (ui.content.length === 0) {
                            jQuery('#' + fieldName + 'LiveSearch').append('<div class="empty-message">' + Translator.__('No results found!') + '</div>');
                        }
                    },
                    focus: function(event, ui) {
                        jQuery('#' + fieldName + 'Selector').val(ui.item.uname);

                        return false;
                    },
                    select: function(event, ui) {
                        jQuery('#' + fieldName).val(ui.item.uid);
                        jQuery('#' + fieldName + 'Avatar').html(ui.item.avatar);

                        return false;
                    }
                })
                .autocomplete('instance')._renderItem = function(ul, item) {
                    return jQuery('<div class="suggestion">')
                        .append('<div class="media"><div class="media-left"><a href="javascript:void(0)">' + item.avatar + '</a></div><div class="media-body"><p class="media-heading">' + item.uname + '</p></div></div>')
                        .appendTo(ul);
                };
            }

        «ENDIF»
    '''

    def private resetUploadField(Application it) '''
        /**
         * Resets the value of an upload / file input field.
         */
        function «vendorAndName»ResetUploadField(fieldName)
        {
            jQuery('#' + fieldName).attr('type', 'input');
            jQuery('#' + fieldName).attr('type', 'file');
        }
    '''

    def private initUploadField(Application it) '''
        /**
         * Initialises the reset button for a certain upload input.
         */
        function «vendorAndName»InitUploadField(fieldName)
        {
            jQuery('#' + fieldName + 'ResetVal').click( function (event) {
                event.preventDefault();
                «vendorAndName»ResetUploadField(fieldName);
            }).removeClass('hidden');
        }
    '''

    def private initDateField(Application it) '''
        /**
         * Initialises the reset button for a certain date input.
         */
        function «vendorAndName»InitDateField(fieldName)
        {
            jQuery('#' + fieldName + 'ResetVal').click( function (event) {
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

        function «vendorAndName»TriggerFormValidation()
        {
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
        function «vendorAndName»InitEditForm(mode, entityId)
        {
            if (jQuery('.«vendorAndName.toLowerCase»-edit-form').length < 1) {
                return;
            }

            editForm = jQuery('.«vendorAndName.toLowerCase»-edit-form').first();
            editedObjectType = editForm.attr('id').replace('EditForm', '');
            editedEntityId = entityId;

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

            var allFormFields = editForm.find('input, select, textarea');
            allFormFields.change(function (event) {
                «vendorAndName»ExecuteCustomValidationConstraints(editedObjectType, editedEntityId);
            });

            formButtons = editForm.find('.form-buttons input');
            editForm.find('.btn-danger').first().bind('click keypress', function (event) {
                if (!window.confirm(Translator.__('Do you really want to delete this entry?'))) {
                    event.preventDefault();
                }
            });
            editForm.find('button[type=submit]').bind('click keypress', function (event) {
                triggerValidation = !jQuery(this).attr('formnovalidate');
            });
            editForm.submit(«vendorAndName»HandleFormSubmit);

            if (mode != 'create') {
                «vendorAndName»TriggerFormValidation();
            }
        }
    '''
}
