package org.zikula.modulestudio.generator.cartridges.symfony.controller.javascript

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.DatetimeField
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.extensions.DateTimeExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Validation {

    extension DateTimeExtensions = new DateTimeExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    /**
     * Entry point for the JavaScript file with validation functionality.
     */
    def generate(Application it, IMostFileSystemAccess fsa) {
        'Generating JavaScript for validation'.printIfNotTesting(fsa)
        val fileName = appName + '.Validation.js'
        fsa.generateFile(getAppJsPath + fileName, generate)
    }

    def private generate(Application it) '''
        'use strict';
        «IF hasAnyDateTimeFields || !getAllVariables.filter(DatetimeField).empty»

            «dateFunctions»
        «ENDIF»
        «IF entities.exists[getUniqueDerivedFields.filter[!primaryKey].size > 0]»

            «uniqueCheck»
        «ENDIF»

        function «vendorAndName»ValidateNoSpace(val) {
            var valStr;

            valStr = '' + val;

            return -1 === valStr.indexOf(' ');
        }
        «IF hasUploads»

            function «vendorAndName»ValidateUploadExtension(val, elem) {
                var fileExtension, allowedExtensions;
                if ('' == val) {
                    return true;
                }

                fileExtension = '.' + val.substr(val.lastIndexOf('.') + 1);
                allowedExtensions = jQuery('#' + elem.attr('id').replace(':', '\\:') + 'FileExtensions').text();
                allowedExtensions = '(.' + allowedExtensions.replace(/, /g, '|.').replace(/,/g, '|.') + ')$';
                allowedExtensions = new RegExp(allowedExtensions, 'i');

                return allowedExtensions.test(val);
            }
        «ENDIF»
        «val datetimeFields = getAllEntityFields.filter(DatetimeField).filter[isDateTimeField] + getAllVariables.filter(DatetimeField).filter[isDateTimeField]»
        «IF !datetimeFields.empty»
            «IF datetimeFields.exists[past]»

                function «vendorAndName»ValidateDatetimePast(val) {
                    var valStr, cmpVal;

                    valStr = '' + val;
                    cmpVal = «vendorAndName»ReadDate(valStr, true);

                    return '' === valStr || cmpVal < «vendorAndName»Today('datetime');
                }
            «ENDIF»
            «IF datetimeFields.exists[future]»

                function «vendorAndName»ValidateDatetimeFuture(val) {
                    var valStr, cmpVal;

                    valStr = '' + val;
                    cmpVal = «vendorAndName»ReadDate(valStr, true);

                    return '' === valStr || cmpVal > «vendorAndName»Today('datetime');
                }
            «ENDIF»
        «ENDIF»
        «val dateFields = getAllEntityFields.filter(DatetimeField).filter[isDateField] + getAllVariables.filter(DatetimeField).filter[isDateField]»
        «IF !dateFields.empty»
            «IF dateFields.exists[past]»

                function «vendorAndName»ValidateDatePast(val) {
                    var valStr, cmpVal;

                    valStr = '' + val;
                    cmpVal = «vendorAndName»ReadDate(valStr, false);

                    return '' === valStr || cmpVal < «vendorAndName»Today('date');
                }
            «ENDIF»
            «IF dateFields.exists[future]»

                function «vendorAndName»ValidateDateFuture(val) {
                    var valStr, cmpVal;

                    valStr = '' + val;
                    cmpVal = «vendorAndName»ReadDate(valStr, false);

                    return '' === valStr || cmpVal > «vendorAndName»Today('date');
                }
            «ENDIF»
        «ENDIF»
        «val timeFields = getAllEntityFields.filter(DatetimeField).filter[isTimeField] + getAllVariables.filter(DatetimeField).filter[isTimeField]»
        «IF !timeFields.empty»
            «IF timeFields.exists[past]»

                function «vendorAndName»ValidateTimePast(val) {
                    var cmpVal;

                    valStr = '' + val;

                    return '' === cmpVal || cmpVal < «vendorAndName»Today('time');
                }
            «ENDIF»
            «IF timeFields.exists[future]»

                function «vendorAndName»ValidateTimeFuture(val) {
                    var cmpVal;

                    valStr = '' + val;

                    return '' === cmpVal || cmpVal > «vendorAndName»Today('time');
                }
            «ENDIF»
        «ENDIF»
        «FOR entity : entities.filter[hasStartAndEndDateField]»
            «val startDateField = entity.getStartDateField»
            «val endDateField = entity.getEndDateField»

            function «vendorAndName»ValidateDateRange«entity.name.formatForCodeCapital»(val) {
                var cmpVal, cmpVal2, result;

                «val startFieldName = startDateField.name.formatForCode»
                «val endFieldName = endDateField.name.formatForCode»
                «IF startDateField.isDateTimeField»
                    cmpVal = jQuery("[id$='«startFieldName»_date']").val() + ' ' + jQuery("[id$='«startFieldName»_time']").val();
                «ELSE»
                    cmpVal = jQuery("[id$='«startFieldName»']").val();
                «ENDIF»
                «IF endDateField.isDateTimeField»
                    cmpVal2 = jQuery("[id$='«endFieldName»_date']").val() + ' ' + jQuery("[id$='«endFieldName»_time']").val();
                «ELSE»
                    cmpVal2 = jQuery("[id$='«endFieldName»']").val();
                «ENDIF»

                if (typeof cmpVal == 'undefined' && typeof cmpVal2 == 'undefined') {
                    result = true;
                } else if ('' == jQuery.trim(cmpVal) || '' == jQuery.trim(cmpVal2)) {
                    result = true;
                } else {
                    result = (cmpVal <= cmpVal2);
                }

                return result;
            }
        «ENDFOR»
        «FOR varContainer : variables.filter[hasStartAndEndDateField]»
            «val startDateField = varContainer.getStartDateField»
            «val endDateField = varContainer.getEndDateField»

            function «vendorAndName»ValidateDateRange«varContainer.name.formatForCodeCapital»(val) {
                var cmpVal, cmpVal2, result;

                «val startFieldName = startDateField.name.formatForCode»
                «val endFieldName = endDateField.name.formatForCode»
                «IF startDateField.isDateTimeField»
                    cmpVal = jQuery("[id$='«startFieldName»_date']").val() + ' ' + jQuery("[id$='«startFieldName»_time']").val();
                «ELSE»
                    cmpVal = jQuery("[id$='«startFieldName»']").val();
                «ENDIF»
                «IF endDateField.isDateTimeField»
                    cmpVal2 = jQuery("[id$='«endFieldName»_date']").val() + ' ' + jQuery("[id$='«endFieldName»_time']").val();
                «ELSE»
                    cmpVal2 = jQuery("[id$='«endFieldName»']").val();
                «ENDIF»

                if (typeof cmpVal == 'undefined' && typeof cmpVal2 == 'undefined') {
                    result = true;
                } else if ('' == jQuery.trim(cmpVal) || '' == jQuery.trim(cmpVal2)) {
                    result = true;
                } else {
                    result = (cmpVal <= cmpVal2);
                }

                return result;
            }
        «ENDFOR»

        /**
         * Runs special validation rules.
         */
        function «vendorAndName»ExecuteCustomValidationConstraints(objectType, currentEntityId) {
            «IF hasUploads»
                jQuery('.validate-upload').each(function () {
                    if (!«vendorAndName»ValidateUploadExtension(jQuery(this).val(), jQuery(this))) {
                        jQuery(this).get(0).setCustomValidity(Translator.trans('Please select a valid file extension.', {}, 'validators'));
                    } else {
                        jQuery(this).get(0).setCustomValidity('');
                    }
                });
            «ENDIF»
            «IF !datetimeFields.empty»
                «IF datetimeFields.exists[past]»
                    jQuery('.validate-datetime-past').each(function () {
                        if (!«vendorAndName»ValidateDatetimePast(jQuery(jQuery(this).attr('id') + '_date').val() + ' ' + jQuery(jQuery(this).attr('id') + '_time').val())) {
                            document.getElementById(jQuery(this).attr('id') + '_date').setCustomValidity(Translator.trans('Please select a value in the past.', {}, 'validators'));
                            document.getElementById(jQuery(this).attr('id') + '_time').setCustomValidity(Translator.trans('Please select a value in the past.', {}, 'validators'));
                        } else {
                            document.getElementById(jQuery(this).attr('id') + '_date').setCustomValidity('');
                            document.getElementById(jQuery(this).attr('id') + '_time').setCustomValidity('');
                        }
                    });
                «ENDIF»
                «IF datetimeFields.exists[future]»
                    jQuery('.validate-datetime-future').each(function () {
                        if (!«vendorAndName»ValidateDatetimeFuture(jQuery(jQuery(this).attr('id') + '_date').val() + ' ' + jQuery(jQuery(this).attr('id') + '_time').val())) {
                            document.getElementById(jQuery(this).attr('id') + '_date').setCustomValidity(Translator.trans('Please select a value in the future.', {}, 'validators'));
                            document.getElementById(jQuery(this).attr('id') + '_time').setCustomValidity(Translator.trans('Please select a value in the future.', {}, 'validators'));
                        } else {
                            document.getElementById(jQuery(this).attr('id') + '_date').setCustomValidity('');
                            document.getElementById(jQuery(this).attr('id') + '_time').setCustomValidity('');
                        }
                    });
                «ENDIF»
            «ENDIF»
            «IF !dateFields.empty»
                «IF dateFields.exists[past]»
                    jQuery('.validate-date-past').each(function () {
                        if (!«vendorAndName»ValidateDatePast(jQuery(this).val())) {
                            jQuery(this).get(0).setCustomValidity(Translator.trans('Please select a value in the past.', {}, 'validators'));
                        } else {
                            jQuery(this).get(0).setCustomValidity('');
                        }
                    });
                «ENDIF»
                «IF dateFields.exists[future]»
                    jQuery('.validate-date-future').each(function () {
                        if (!«vendorAndName»ValidateDateFuture(jQuery(this).val())) {
                            jQuery(this).get(0).setCustomValidity(Translator.trans('Please select a value in the future.', {}, 'validators'));
                        } else {
                            jQuery(this).get(0).setCustomValidity('');
                        }
                    });
                «ENDIF»
            «ENDIF»
            «IF !timeFields.empty»
                «IF timeFields.exists[past]»
                    jQuery('.validate-time-past').each(function () {
                        if (!«vendorAndName»ValidateTimePast(jQuery(this).val())) {
                            jQuery(this).get(0).setCustomValidity(Translator.trans('Please select a value in the past.', {}, 'validators'));
                        } else {
                            jQuery(this).get(0).setCustomValidity('');
                        }
                    });
                «ENDIF»
                «IF timeFields.exists[future]»
                    jQuery('.validate-time-future').each(function () {
                        if (!«vendorAndName»ValidateTimeFuture(jQuery(this).val())) {
                            jQuery(this).get(0).setCustomValidity(Translator.trans('Please select a value in the future.', {}, 'validators'));
                        } else {
                            jQuery(this).get(0).setCustomValidity('');
                        }
                    });
                «ENDIF»
            «ENDIF»
            «FOR entity : entities.filter[hasStartAndEndDateField]»
                jQuery('.validate-daterange-entity-«entity.name.formatForDB»').each(function () {
                    if ('undefined' != typeof jQuery(this).attr('id')) {
                        if ('DIV' == jQuery(this).prop('tagName')) {
                            if (!«vendorAndName»ValidateDateRange«entity.name.formatForCodeCapital»()) {
                                jQuery('#' + jQuery(this).attr('id') + '_date').get(0).setCustomValidity(Translator.trans('The start must be before the end.', {}, 'validators'));
                                jQuery('#' + jQuery(this).attr('id') + '_time').get(0).setCustomValidity(Translator.trans('The start must be before the end.', {}, 'validators'));
                            } else {
                                jQuery('#' + jQuery(this).attr('id') + '_date').get(0).setCustomValidity('');
                                jQuery('#' + jQuery(this).attr('id') + '_time').get(0).setCustomValidity('');
                            }
                        } else {
                            if (!«vendorAndName»ValidateDateRange«entity.name.formatForCodeCapital»()) {
                                jQuery(this).get(0).setCustomValidity(Translator.trans('The start must be before the end.', {}, 'validators'));
                            } else {
                                jQuery(this).get(0).setCustomValidity('');
                            }
                        }
                    }
                });
            «ENDFOR»
            «FOR varContainer : variables.filter[hasStartAndEndDateField]»
                jQuery('.validate-daterange-vars-«varContainer.name.formatForDB»').each(function () {
                    if ('undefined' != typeof jQuery(this).attr('id')) {
                        if ('DIV' == jQuery(this).prop('tagName')) {
                            if (!«vendorAndName»ValidateDateRange«varContainer.name.formatForCodeCapital»()) {
                                jQuery('#' + jQuery(this).attr('id') + '_date').get(0).setCustomValidity(Translator.trans('The start must be before the end.', {}, 'validators'));
                                jQuery('#' + jQuery(this).attr('id') + '_time').get(0).setCustomValidity(Translator.trans('The start must be before the end.', {}, 'validators'));
                            } else {
                                jQuery('#' + jQuery(this).attr('id') + '_date').get(0).setCustomValidity('');
                                jQuery('#' + jQuery(this).attr('id') + '_time').get(0).setCustomValidity('');
                            }
                        } else {
                            if (!«vendorAndName»ValidateDateRange«varContainer.name.formatForCodeCapital»()) {
                                jQuery(this).get(0).setCustomValidity(Translator.trans('The start must be before the end.', {}, 'validators'));
                            } else {
                                jQuery(this).get(0).setCustomValidity('');
                            }
                        }
                    }
                });
            «ENDFOR»
            «IF entities.exists[getUniqueDerivedFields.filter[!primaryKey].size > 0]»
                jQuery('.validate-unique').each(function () {
                    if (!«vendorAndName»UniqueCheck(jQuery(this), currentEntityId)) {
                        jQuery(this).get(0).setCustomValidity(Translator.trans('This value is already assigned, but must be unique. Please change it.', {}, 'validators'));
                    } else {
                        jQuery(this).get(0).setCustomValidity('');
                    }
                });
            «ENDIF»
        }
    '''

    def private dateFunctions(Application it) '''
        function «vendorAndName»Today(format) {
            var timestamp, todayDate, month, day, hours, minutes, seconds;

            timestamp = new Date();
            todayDate = '';
            if ('time' !== format) {
                month = new String((parseInt(timestamp.getMonth()) + 1));
                if (1 === month.length) {
                    month = '0' + month;
                }
                day = new String(timestamp.getDate());
                if (1 === day.length) {
                    day = '0' + day;
                }
                todayDate += timestamp.getFullYear() + '-' + month + '-' + day;
            }
            if ('datetime' === format) {
                todayDate += ' ';
            }
            if ('date' !== format) {
                hours = new String(timestamp.getHours());
                if (1 === hours.length) {
                    hours = '0' + hours;
                }
                minutes = new String(timestamp.getMinutes());
                if (1 === minutes.length) {
                    minutes = '0' + minutes;
                }
                seconds = new String(timestamp.getSeconds());
                if (1 === seconds.length) {
                    seconds = '0' + seconds;
                }
                todayDate += hours + ':' + minutes;// + ':' + seconds;
            }

            return todayDate;
        }

        // returns YYYY-MM-DD even if date is in DD.MM.YYYY
        function «vendorAndName»ReadDate(val, includeTime) {
            // look if we have YYYY-MM-DD
            if ('-' === val.substr(4, 1) && '-' === val.substr(7, 1)) {
                return val;
            }

            // look if we have DD.MM.YYYY
            if ('.' === val.substr(2, 1) && '.' === val.substr(5, 1)) {
                var newVal = val.substr(6, 4) + '-' + val.substr(3, 2) + '-' + val.substr(0, 2);
                if (true === includeTime) {
                    newVal += ' ' + val.substr(11, 7);
                }

                return newVal;
            }
        }
    '''

    def private uniqueCheck(Application it) '''
        «FOR entity : entities»
            «FOR field : entity.getUniqueDerivedFields.filter[!primaryKey]»
                var last«entity.name.formatForCodeCapital»«field.name.formatForCodeCapital» = '';
            «ENDFOR»
        «ENDFOR»

        /**
         * Performs a duplicate check for unique fields
         */
        function «vendorAndName»UniqueCheck(elem, excludeId) {
            var objectType, fieldName, fieldValue, result, params;

            objectType = elem.attr('id').split('_')[1];
            fieldName = elem.attr('id').split('_')[2];
            fieldValue = elem.val();
            if (fieldValue == window['last' + «vendorAndName»CapitaliseFirstLetter(objectType) + «vendorAndName»CapitaliseFirstLetter(fieldName)]) {
                return true;
            }

            window['last' + «vendorAndName»CapitaliseFirstLetter(objectType) + «vendorAndName»CapitaliseFirstLetter(fieldName)] = fieldValue;

            result = true;
            params = {
                ot: encodeURIComponent(objectType),
                fn: encodeURIComponent(fieldName),
                v: encodeURIComponent(fieldValue),
                ex: excludeId
            };

            jQuery.ajax({
                url: Routing.generate('«appName.formatForDB»_ajax_checkforduplicate'),
                method: 'GET',
                dataType: 'json',
                async: false,
                data: params
            }).done(function (data) {
                if (null == data || true === data.isDuplicate) {
                    result = false;
                }
            });

            return result;
        }
    '''
}
