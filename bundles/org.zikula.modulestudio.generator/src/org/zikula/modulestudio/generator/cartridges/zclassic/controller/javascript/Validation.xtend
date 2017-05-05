package org.zikula.modulestudio.generator.cartridges.zclassic.controller.javascript

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.DateField
import de.guite.modulestudio.metamodel.DatetimeField
import de.guite.modulestudio.metamodel.TimeField
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Validation {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    /**
     * Entry point for the JavaScript file with validation functionality.
     */
    def generate(Application it, IFileSystemAccess fsa) {
        var fileName = appName + '.Validation.js'
        if (!shouldBeSkipped(getAppJsPath + fileName)) {
            println('Generating JavaScript for validation')
            if (shouldBeMarked(getAppJsPath + fileName)) {
                fileName = appName + '.Validation.generated.js'
            }
            fsa.generateFile(getAppJsPath + fileName, generate)
        }
    }

    def private generate(Application it) '''
        'use strict';

        function «vendorAndName»Today(format)
        {
            var timestamp, todayDate, month, day, hours, minutes, seconds;

            timestamp = new Date();
            todayDate = '';
            if (format !== 'time') {
                month = new String((parseInt(timestamp.getMonth()) + 1));
                if (month.length === 1) {
                    month = '0' + month;
                }
                day = new String(timestamp.getDate());
                if (day.length === 1) {
                    day = '0' + day;
                }
                todayDate += timestamp.getFullYear() + '-' + month + '-' + day;
            }
            if (format === 'datetime') {
                todayDate += ' ';
            }
            if (format != 'date') {
                hours = new String(timestamp.getHours());
                if (hours.length === 1) {
                    hours = '0' + hours;
                }
                minutes = new String(timestamp.getMinutes());
                if (minutes.length === 1) {
                    minutes = '0' + minutes;
                }
                seconds = new String(timestamp.getSeconds());
                if (seconds.length === 1) {
                    seconds = '0' + seconds;
                }
                todayDate += hours + ':' + minutes;// + ':' + seconds;
            }

            return todayDate;
        }

        // returns YYYY-MM-DD even if date is in DD.MM.YYYY
        function «vendorAndName»ReadDate(val, includeTime)
        {
            // look if we have YYYY-MM-DD
            if (val.substr(4, 1) === '-' && val.substr(7, 1) === '-') {
                return val;
            }

            // look if we have DD.MM.YYYY
            if (val.substr(2, 1) === '.' && val.substr(5, 1) === '.') {
                var newVal = val.substr(6, 4) + '-' + val.substr(3, 2) + '-' + val.substr(0, 2);
                if (true === includeTime) {
                    newVal += ' ' + val.substr(11, 7);
                }

                return newVal;
            }
        }
        «IF entities.exists[getUniqueDerivedFields.filter[!primaryKey].size > 0]»

            «FOR entity : entities»
                «FOR field : entity.getUniqueDerivedFields.filter[!primaryKey]»
                    var last«entity.name.formatForCodeCapital»«field.name.formatForCodeCapital» = '';
                «ENDFOR»
            «ENDFOR»

            /**
             * Performs a duplicate check for unique fields
             */
            function «vendorAndName»UniqueCheck(ucOt, val, elem, ucEx)
            {
                var result, params;

                if (elem.val() == window['last' + «vendorAndName»CapitaliseFirstLetter(ucOt) + «vendorAndName»CapitaliseFirstLetter(elem.attr('id')) ]) {
                    return true;
                }

                window['last' + «vendorAndName»CapitaliseFirstLetter(ucOt) + «vendorAndName»CapitaliseFirstLetter(elem.attr('id')) ] = elem.val();

                result = true;
                params = {
                    ot: ucOt,
                    fn: encodeURIComponent(elem.attr('id')),
                    v: encodeURIComponent(val),
                    ex: ucEx
                };

                jQuery.ajax({
                    url: Routing.generate('«appName.formatForDB»_ajax_checkforduplicate'),
                    datatype: 'json',
                    async: false,
                    data: params,
                    success: function(data) {
                        if (null == data || true === data.isDuplicate) {
                            result = false;
                        }
                    }
                });

                return result;
            }
        «ENDIF»

        function «vendorAndName»ValidateNoSpace(val)
        {
            var valStr;
            valStr = new String(val);

            return (valStr.indexOf(' ') === -1);
        }
        «IF hasColourFields»

            function «vendorAndName»ValidateHtmlColour(val)
            {
                var valStr;
                valStr = new String(val);

                return valStr === '' || (/^#[0-9a-f]{3}([0-9a-f]{3})?$/i.test(valStr));
            }
        «ENDIF»
        «IF hasUploads»

            function «vendorAndName»ValidateUploadExtension(val, elem)
            {
                var fileExtension, allowedExtensions;
                if (val === '') {
                    return true;
                }

                fileExtension = '.' + val.substr(val.lastIndexOf('.') + 1);
                allowedExtensions = jQuery('#' + elem.attr('id') + 'FileExtensions').text();
                allowedExtensions = '(.' + allowedExtensions.replace(/, /g, '|.').replace(/,/g, '|.') + ')$';
                allowedExtensions = new RegExp(allowedExtensions, 'i');

                return allowedExtensions.test(val);
            }
        «ENDIF»
        «val datetimeFields = getAllEntityFields.filter(DatetimeField)»
        «IF !datetimeFields.empty»
            «IF datetimeFields.exists[past]»

                function «vendorAndName»ValidateDatetimePast(val)
                {
                    var valStr, cmpVal;
                    valStr = new String(val);
                    cmpVal = «vendorAndName»ReadDate(valStr, true);

                    return valStr === '' || (cmpVal < «vendorAndName»Today('datetime'));
                }
            «ENDIF»
            «IF datetimeFields.exists[future]»

                function «vendorAndName»ValidateDatetimeFuture(val)
                {
                    var valStr, cmpVal;
                    valStr = new String(val);
                    cmpVal = «vendorAndName»ReadDate(valStr, true);

                    return valStr === '' || (cmpVal > «vendorAndName»Today('datetime'));
                }
            «ENDIF»
        «ENDIF»
        «val dateFields = getAllEntityFields.filter(DateField)»
        «IF !dateFields.empty»
            «IF dateFields.exists[past]»

                function «vendorAndName»ValidateDatePast(val)
                {
                    var valStr, cmpVal;
                    valStr = new String(val);
                    cmpVal = «vendorAndName»ReadDate(valStr, false);

                    return valStr === '' || (cmpVal < «vendorAndName»Today('date'));
                }
            «ENDIF»
            «IF dateFields.exists[future]»

                function «vendorAndName»ValidateDateFuture(val)
                {
                    var valStr, cmpVal;
                    valStr = new String(val);
                    cmpVal = «vendorAndName»ReadDate(valStr, false);

                    return valStr === '' || (cmpVal > «vendorAndName»Today('date'));
                }
            «ENDIF»
        «ENDIF»
        «val timeFields = getAllEntityFields.filter(TimeField)»
        «IF !timeFields.empty»
            «IF timeFields.exists[past]»

                function «vendorAndName»ValidateTimePast(val)
                {
                    var cmpVal;
                    cmpVal = new String(val);

                    return cmpVal === '' || (cmpVal < «vendorAndName»Today('time'));
                }
            «ENDIF»
            «IF timeFields.exists[future]»

                function «vendorAndName»ValidateTimeFuture(val)
                {
                    var cmpVal;
                    cmpVal = new String(val);

                    return cmpVal === '' || (cmpVal > «vendorAndName»Today('time'));
                }
            «ENDIF»
        «ENDIF»
        «FOR entity : entities»
            «val startDateField = entity.getStartDateField»
            «val endDateField = entity.getEndDateField»
            «IF null !== startDateField && null !== endDateField»

                function «vendorAndName»ValidateDateRange«entity.name.formatForCodeCapital»(val)
                {
                    var cmpVal, cmpVal2, result;
                    «val startFieldName = startDateField.name.formatForCode»
                    «val endFieldName = endDateField.name.formatForCode»
                    cmpVal = «vendorAndName»ReadDate(jQuery("[id$='«startFieldName»']").val(), «(startDateField instanceof DatetimeField).displayBool»);
                    cmpVal2 = «vendorAndName»ReadDate(jQuery("[id$='«endFieldName»']").val(), «(endDateField instanceof DatetimeField).displayBool»);

                    if (typeof cmpVal == 'undefined' && typeof cmpVal2 == 'undefined') {
                        result = true;
                    } else {
                        result = (cmpVal <= cmpVal2);
                    }

                    return result;
                }
            «ENDIF»
        «ENDFOR»

        /**
         * Runs special validation rules.
         */
        function «vendorAndName»ExecuteCustomValidationConstraints(objectType, currentEntityId)
        {
            jQuery('.validate-nospace').each( function() {
                if (!«vendorAndName»ValidateNoSpace(jQuery(this).val())) {
                    document.getElementById(jQuery(this).attr('id')).setCustomValidity(Translator.__('This value must not contain spaces.'));
                } else {
                    document.getElementById(jQuery(this).attr('id')).setCustomValidity('');
                }
            });
            «IF hasColourFields»
                jQuery('.validate-htmlcolour').each( function() {
                    if (!«vendorAndName»ValidateHtmlColour(jQuery(this).val())) {
                        document.getElementById(jQuery(this).attr('id')).setCustomValidity(Translator.__('Please select a valid html colour code.'));
                    } else {
                        document.getElementById(jQuery(this).attr('id')).setCustomValidity('');
                    }
                });
            «ENDIF»
            «IF hasUploads»
                jQuery('.validate-upload').each( function() {
                    if (!«vendorAndName»ValidateUploadExtension(jQuery(this).val(), jQuery(this))) {
                        document.getElementById(jQuery(this).attr('id')).setCustomValidity(Translator.__('Please select a valid file extension.'));
                    } else {
                        document.getElementById(jQuery(this).attr('id')).setCustomValidity('');
                    }
                });
            «ENDIF»
            «IF !datetimeFields.empty»
                «IF datetimeFields.exists[past]»
                    jQuery('.validate-datetime-past').each( function() {
                        if (!«vendorAndName»ValidateDatetimePast(jQuery(jQuery(this).attr('id') + '_date').val() + ' ' + jQuery(jQuery(this).attr('id') + '_time').val())) {
                            document.getElementById(jQuery(this).attr('id') + '_date').setCustomValidity(Translator.__('Please select a value in the past.'));
                            document.getElementById(jQuery(this).attr('id') + '_time').setCustomValidity(Translator.__('Please select a value in the past.'));
                        } else {
                            document.getElementById(jQuery(this).attr('id') + '_date').setCustomValidity('');
                            document.getElementById(jQuery(this).attr('id') + '_time').setCustomValidity('');
                        }
                    });
                «ENDIF»
                «IF datetimeFields.exists[future]»
                    jQuery('.validate-datetime-future').each( function() {
                        if (!«vendorAndName»ValidateDatetimeFuture(jQuery(jQuery(this).attr('id') + '_date').val() + ' ' + jQuery(jQuery(this).attr('id') + '_time').val())) {
                            document.getElementById(jQuery(this).attr('id') + '_date').setCustomValidity(Translator.__('Please select a value in the future.'));
                            document.getElementById(jQuery(this).attr('id') + '_time').setCustomValidity(Translator.__('Please select a value in the future.'));
                        } else {
                            document.getElementById(jQuery(this).attr('id') + '_date').setCustomValidity('');
                            document.getElementById(jQuery(this).attr('id') + '_time').setCustomValidity('');
                        }
                    });
                «ENDIF»
            «ENDIF»
            «IF !dateFields.empty»
                «IF dateFields.exists[past]»
                    jQuery('.validate-date-past').each( function() {
                        if (!«vendorAndName»ValidateDatePast(jQuery(this).val())) {
                            document.getElementById(jQuery(this).attr('id')).setCustomValidity(Translator.__('Please select a value in the past.'));
                        } else {
                            document.getElementById(jQuery(this).attr('id')).setCustomValidity('');
                        }
                    });
                «ENDIF»
                «IF dateFields.exists[future]»
                    jQuery('.validate-date-future').each( function() {
                        if (!«vendorAndName»ValidateDateFuture(jQuery(this).val())) {
                            document.getElementById(jQuery(this).attr('id')).setCustomValidity(Translator.__('Please select a value in the future.'));
                        } else {
                            document.getElementById(jQuery(this).attr('id')).setCustomValidity('');
                        }
                    });
                «ENDIF»
            «ENDIF»
            «IF !timeFields.empty»
                «IF timeFields.exists[past]»
                    jQuery('.validate-time-past').each( function() {
                        if (!«vendorAndName»ValidateTimePast(jQuery(this).val())) {
                            document.getElementById(jQuery(this).attr('id')).setCustomValidity(Translator.__('Please select a value in the past.'));
                        } else {
                            document.getElementById(jQuery(this).attr('id')).setCustomValidity('');
                        }
                    });
                «ENDIF»
                «IF timeFields.exists[future]»
                    jQuery('.validate-time-future').each( function() {
                        if (!«vendorAndName»ValidateTimeFuture(jQuery(this).val())) {
                            document.getElementById(jQuery(this).attr('id')).setCustomValidity(Translator.__('Please select a value in the future.'));
                        } else {
                            document.getElementById(jQuery(this).attr('id')).setCustomValidity('');
                        }
                    });
                «ENDIF»
            «ENDIF»
            «FOR entity : entities»
                «IF null !== entity.startDateField && null !== entity.endDateField»
                    jQuery('.validate-daterange-«entity.name.formatForDB»').each( function() {
                        if (typeof jQuery(this).attr('id') != 'undefined') {
                            if (jQuery(this).prop('tagName') == 'DIV') {
                                if (!«vendorAndName»ValidateDateRange«entity.name.formatForCodeCapital»()) {
                                    document.getElementById(jQuery(this).attr('id') + '_date').setCustomValidity(Translator.__('The start must be before the end.'));
                                    document.getElementById(jQuery(this).attr('id') + '_time').setCustomValidity(Translator.__('The start must be before the end.'));
                                } else {
                                    document.getElementById(jQuery(this).attr('id') + '_date').setCustomValidity('');
                                    document.getElementById(jQuery(this).attr('id') + '_time').setCustomValidity('');
                                }
                        	} else {
                                if (!«vendorAndName»ValidateDateRange«entity.name.formatForCodeCapital»()) {
                                    document.getElementById(jQuery(this).attr('id')).setCustomValidity(Translator.__('The start must be before the end.'));
                                } else {
                                    document.getElementById(jQuery(this).attr('id')).setCustomValidity('');
                                }
                    		}
                        }
                    });
                «ENDIF»
            «ENDFOR»
            «IF entities.exists[getUniqueDerivedFields.filter[!primaryKey].size > 0]»
                jQuery('.validate-unique').each( function() {
                    if (!«vendorAndName»UniqueCheck(jQuery(this).attr('id'), jQuery(this).val(), jQuery(this), currentEntityId)) {
                        document.getElementById(jQuery(this).attr('id')).setCustomValidity(Translator.__('This value is already assigned, but must be unique. Please change it.'));
                    } else {
                        document.getElementById(jQuery(this).attr('id')).setCustomValidity('');
                    }
                });
            «ENDIF»
        }
    '''
}
