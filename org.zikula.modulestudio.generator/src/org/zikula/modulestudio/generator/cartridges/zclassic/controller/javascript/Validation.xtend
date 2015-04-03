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
        var fileName = ''
        if (targets('1.3.x')) {
            fileName = appName + '_validation.js'
        } else {
            fileName = appName + '.Validation.js'
        }
        if (!shouldBeSkipped(getAppJsPath + fileName)) {
            println('Generating JavaScript for validation')
            if (shouldBeMarked(getAppJsPath + fileName)) {
                if (targets('1.3.x')) {
                    fileName = appName + '_validation.generated.js'
                } else {
                    fileName = appName + '.Validation.generated.js'
                }
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
            if (val.substr(2, 1) === '.' && val.substr(4, 1) === '.') {
                var newVal = val.substr(6, 4) + '-' + val.substr(3, 2) + '-' + val.substr(0, 2);
                if (includeTime === true) {
                    newVal += ' ' + val.substr(11, 5);
                }
                return newVal;
            }
        }
        «IF entities.exists[getUniqueDerivedFields.filter[!primaryKey].size > 0]»

            /**
             * Performs a duplicate check for unique fields
             */
            function «vendorAndName»UniqueCheck(ucOt, val, elem, ucEx)
            {
                var params«IF targets('1.3.x')», request«ENDIF»;

                «IF targets('1.3.x')»
                    $('advice-validate-unique-' + elem.id).hide();
                    elem.removeClassName('validation-failed').removeClassName('validation-passed');
                «ELSE»
                    $('advice-validate-unique-' + elem.attr('id')).hide();
                    elem.parent().parent().removeClass('has-error').removeClassName('has-success');
                «ENDIF»

                // build parameters object
                params = {
                    ot: ucOt,
                    fn: encodeURIComponent(elem.«IF targets('1.3.x')»id«ELSE»attr('id')«ENDIF»),
                    v: encodeURIComponent(val),
                    ex: ucEx
                };

                /** TODO fix the following call to work within validation context */
                return true;

                «IF targets('1.3.x')»
                    request = new Zikula.Ajax.Request(
                        Zikula.Config.baseURL + 'ajax.php?module=«appName»&func=checkForDuplicate',
                        {
                            method: 'post',
                            parameters: params,
                            authid: 'FormAuthid',«/*from the Forms framework*/»
                            onComplete: function(req) {
                                // check if request was successful
                                if (!req.isSuccess()) {
                                    Zikula.showajaxerror(req.getMessage());
                                    return;
                                }

                                // get data returned by the ajax response
                                var data = req.getData();
                                if (data.isDuplicate !== '1') {
                                    $('advice-validate-unique-' + elem.id).hide();
                                    elem.removeClassName('validation-failed').addClassName('validation-passed');
                                    return true;
                                } else {
                                    $('advice-validate-unique-' + elem.id).show();
                                    elem.removeClassName('validation-passed').addClassName('validation-failed');
                                    return false;
                                }
                            }
                        }
                    );
                «ELSE»
                    $.ajax({
                        type: 'POST',
                        url: Routing.generate('«appName.formatForDB»_ajax_checkforduplicate'),
                        data: params
                    }).done(function(res) {
                        if (res.data.isDuplicate !== '1') {
                            $('#advice-validate-unique-' + elem.attr('id')).hide();
                            elem.parent().parent().removeClass('has-error').addClass('has-success');
                            return true;
                        } else {
                            $('#advice-validate-unique-' + elem.attr('id')).show();
                            elem.parent().parent().removeClass('has-success').addClass('has-error');
                            return false;
                        }
                    })«/*.fail(function(jqXHR, textStatus) {
                        // nothing to do yet
                    })*/»;
                «ENDIF»

                return true;
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
                allowedExtensions = $(«IF !targets('1.3.x')»'#' + elem.attr('id')«ELSE»elem.id«ENDIF» + 'FileExtensions').innerHTML;
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

                    return valStr === '' || (cmpVal >= «vendorAndName»Today('datetime'));
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

                    return valStr === '' || (cmpVal >= «vendorAndName»Today('date'));
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

                    return cmpVal === '' || (cmpVal >= «vendorAndName»Today('time'));
                }
            «ENDIF»
        «ENDIF»
        «FOR entity : entities»
            «val startDateField = entity.getStartDateField»
            «val endDateField = entity.getEndDateField»
            «IF startDateField !== null && endDateField !== null»

                function «vendorAndName»ValidateDateRange«entity.name.formatForCodeCapital»(val)
                {
                    «val validateClass = 'validate-daterange-' + entity.name.formatForDB»
                    «val startFieldName = startDateField.name.formatForCode»
                    «val endFieldName = endDateField.name.formatForCode»
                    «IF targets('1.3.x')»
                        cmpVal = «vendorAndName»ReadDate($F('«startFieldName»'), «(startDateField instanceof DatetimeField).displayBool»);
                        cmpVal2 = «vendorAndName»ReadDate($F('«endFieldName»'), «(endDateField instanceof DatetimeField).displayBool»);
                        result = (cmpVal <= cmpVal2);
                        if (result) {
                            $('advice-«validateClass»-«startFieldName»').hide();
                            $('advice-«validateClass»-«endFieldName»').hide();
                            $('«startFieldName»').removeClassName('validation-failed').addClassName('validation-passed');
                            $('«endFieldName»').removeClassName('validation-failed').addClassName('validation-passed');
                        } else {
                            $('advice-«validateClass»-«startFieldName»').innerHTML = Zikula.__('The start must be before the end.', 'module_«appName.formatForDB»_js');
                            $('advice-«validateClass»-«endFieldName»').innerHTML = Zikula.__('The start must be before the end.', 'module_«appName.formatForDB»_js');

                            $('advice-«validateClass»-«startFieldName»').show();
                            $('advice-«validateClass»-«endFieldName»').show();
                            $('«startFieldName»').removeClassName('validation-passed').addClassName('validation-failed');
                            $('«endFieldName»').removeClassName('validation-passed').addClassName('validation-failed');
                        }
                    «ELSE»
                        cmpVal = «vendorAndName»ReadDate($('#«startFieldName»').val(), «(startDateField instanceof DatetimeField).displayBool»);
                        cmpVal2 = «vendorAndName»ReadDate($('#«endFieldName»').val(), «(endDateField instanceof DatetimeField).displayBool»);
                        result = (cmpVal <= cmpVal2);
                        if (result) {
                            $('#advice-«validateClass»-«startFieldName»').hide();
                            $('#advice-«validateClass»-«endFieldName»').hide();
                            $('#«startFieldName»').parent().parent().removeClass('has-error').addClass('has-success');
                            $('#«endFieldName»').parent().parent().removeClass('has-error').addClass('has-success');
                        } else {
                            $('#advice-«validateClass»-«startFieldName»').html(Zikula.__('The start must be before the end.', 'module_«appName.formatForDB»_js'));
                            $('#advice-«validateClass»-«endFieldName»').html(Zikula.__('The start must be before the end.', 'module_«appName.formatForDB»_js'));

                            $('#advice-«validateClass»-«startFieldName»').show();
                            $('#advice-«validateClass»-«endFieldName»').show();
                            $('#«startFieldName»').parent().parent().removeClass('has-success').addClass('has-error');
                            $('#«endFieldName»').parent().parent().removeClass('has-success').addClass('has-error');
                        }
                    «ENDIF»

                    return result;
                }
            «ENDIF»
        «ENDFOR»

        /**
         * «IF targets('1.3.x')»Adds«ELSE»Runs«ENDIF» special validation rules.
         */
        function «vendorAndName»«IF targets('1.3.x')»AddCommonValidationRules«ELSE»PerformCustomValidationRules«ENDIF»(objectType, id)
        {
            «IF targets('1.3.x')»
                Validation.addAllThese([
                    ['validate-nospace', Zikula.__('No spaces', 'module_«appName.formatForDB»_js'), function(val, elem) {
                        return «vendorAndName»ValidateNoSpace(val);
                    }],
                    «IF hasColourFields»
                        ['validate-htmlcolour', Zikula.__('Please select a valid html colour code.', 'module_«appName.formatForDB»_js'), function(val, elem) {
                            return «vendorAndName»ValidateHtmlColour(val);
                        }],
                    «ENDIF»
                    «IF hasUploads»
                        ['validate-upload', Zikula.__('Please select a valid file extension.', 'module_«appName.formatForDB»_js'), function(val, elem) {
                            return «vendorAndName»ValidateUploadExtension(val, elem);
                        }],
                    «ENDIF»
                    «IF !datetimeFields.empty»
                        «IF datetimeFields.exists[past]»
                            ['validate-datetime-past', Zikula.__('Please select a value in the past.', 'module_«appName.formatForDB»_js'), function(val, elem) {
                                return «vendorAndName»ValidateDatetimePast(val);
                            }],
                        «ENDIF»
                        «IF datetimeFields.exists[future]»
                            ['validate-datetime-future', Zikula.__('Please select a value in the future.', 'module_«appName.formatForDB»_js'), function(val, elem) {
                                return «vendorAndName»ValidateDatetimeFuture(val);
                            }],
                        «ENDIF»
                    «ENDIF»
                    «IF !dateFields.empty»
                        «IF dateFields.exists[past]»
                            ['validate-date-past', Zikula.__('Please select a value in the past.', 'module_«appName.formatForDB»_js'), function(val, elem) {
                                return «vendorAndName»ValidateDatePast(val);
                            }],
                        «ENDIF»
                        «IF dateFields.exists[future]»
                            ['validate-date-future', Zikula.__('Please select a value in the future.', 'module_«appName.formatForDB»_js'), function(val, elem) {
                                return «vendorAndName»ValidateDateFuture(val);
                            }],
                        «ENDIF»
                    «ENDIF»
                    «IF !timeFields.empty»
                        «IF timeFields.exists[past]»
                            ['validate-time-past', Zikula.__('Please select a value in the past.', 'module_«appName.formatForDB»_js'), function(val, elem) {
                                return «vendorAndName»ValidateTimePast(val);
                            }],
                        «ENDIF»
                        «IF timeFields.exists[future]»
                            ['validate-time-future', Zikula.__('Please select a value in the future.', 'module_«appName.formatForDB»_js'), function(val, elem) {
                                return «vendorAndName»ValidateTimeFuture(val);
                            }],
                        «ENDIF»
                    «ENDIF»
                    «FOR entity : entities»
                        «val startDateField = entity.getStartDateField»
                        «val endDateField = entity.getEndDateField»
                        «IF startDateField !== null && endDateField !== null»
                            ['validate-daterange-«entity.name.formatForDB»', Zikula.__('The start must be before the end.', 'module_«appName.formatForDB»_js'), function(val, elem) {
                                return «vendorAndName»ValidateDateRange«entity.name.formatForCodeCapital»(val);
                            }],
                        «ENDIF»
                    «ENDFOR»
                    «IF entities.exists[getUniqueDerivedFields.filter[!primaryKey].size > 0]»
                        ['validate-unique', Zikula.__('This value is already assigned, but must be unique. Please change it.', 'module_«appName.formatForDB»_js'), function(val, elem) {
                            return «vendorAndName»UniqueCheck('«name.formatForCode»', val, elem, id);
                        }]
                    «ENDIF»
                ]);
            «ELSE»
                $('.validate-nospace').each( function() {
                    if («vendorAndName»ValidateNoSpace($(this).val())) {
                        $(this).setCustomValidity(Zikula.__('This value must not contain spaces.', 'module_«appName.formatForDB»_js'));
                    } else {
                        $(this).setCustomValidity('');
                    }
                });
                «IF hasColourFields»
                    $('.validate-htmlcolour').each( function() {
                        if («vendorAndName»ValidateHtmlColour($(this).val())) {
                            $(this).setCustomValidity(Zikula.__('Please select a valid html colour code.', 'module_«appName.formatForDB»_js'));
                        } else {
                            $(this).setCustomValidity('');
                        }
                    });
                «ENDIF»
                «IF hasUploads»
                    $('.validate-upload').each( function() {
                        if («vendorAndName»ValidateUploadExtension($(this).val(), $(this))) {
                            $(this).setCustomValidity(Zikula.__('Please select a valid file extension.', 'module_«appName.formatForDB»_js'));
                        } else {
                            $(this).setCustomValidity('');
                        }
                    });
                «ENDIF»
                «IF !datetimeFields.empty»
                    «IF datetimeFields.exists[past]»
                        $('.validate-datetime-past').each( function() {
                            if («vendorAndName»ValidateDatetimePast($(this).val())) {
                                $(this).setCustomValidity(Zikula.__('Please select a value in the past.', 'module_«appName.formatForDB»_js'));
                            } else {
                                $(this).setCustomValidity('');
                            }
                        });
                    «ENDIF»
                    «IF datetimeFields.exists[future]»
                        $('.validate-datetime-future').each( function() {
                            if («vendorAndName»ValidateDatetimeFuture($(this).val())) {
                                $(this).setCustomValidity(Zikula.__('Please select a value in the future.', 'module_«appName.formatForDB»_js'));
                            } else {
                                $(this).setCustomValidity('');
                            }
                        });
                    «ENDIF»
                «ENDIF»
                «IF !dateFields.empty»
                    «IF dateFields.exists[past]»
                        $('.validate-date-past').each( function() {
                            if («vendorAndName»ValidateDatePast($(this).val())) {
                                $(this).setCustomValidity(Zikula.__('Please select a value in the past.', 'module_«appName.formatForDB»_js'));
                            } else {
                                $(this).setCustomValidity('');
                            }
                        });
                    «ENDIF»
                    «IF dateFields.exists[future]»
                        $('.validate-date-future').each( function() {
                            if («vendorAndName»ValidateDateFuture($(this).val())) {
                                $(this).setCustomValidity(Zikula.__('Please select a value in the future.', 'module_«appName.formatForDB»_js'));
                            } else {
                                $(this).setCustomValidity('');
                            }
                        });
                    «ENDIF»
                «ENDIF»
                «IF !timeFields.empty»
                    «IF timeFields.exists[past]»
                        $('.validate-time-past').each( function() {
                            if («vendorAndName»ValidateTimePast($(this).val())) {
                                $(this).setCustomValidity(Zikula.__('Please select a value in the past.', 'module_«appName.formatForDB»_js'));
                            } else {
                                $(this).setCustomValidity('');
                            }
                        });
                    «ENDIF»
                    «IF timeFields.exists[future]»
                        $('.validate-time-future').each( function() {
                            if («vendorAndName»ValidateTimeFuture($(this).val())) {
                                $(this).setCustomValidity(Zikula.__('Please select a value in the future.', 'module_«appName.formatForDB»_js'));
                            } else {
                                $(this).setCustomValidity('');
                            }
                        });
                    «ENDIF»
                «ENDIF»
                «FOR entity : entities»
                    «val startDateField = entity.getStartDateField»
                    «val endDateField = entity.getEndDateField»
                    «IF startDateField !== null && endDateField !== null»
                        $('.validate-daterange-«entity.name.formatForDB»').each( function() {
                            if («vendorAndName»ValidateDateRange«entity.name.formatForCodeCapital»($(this).val())) {
                                $(this).setCustomValidity(Zikula.__('The start must be before the end.', 'module_«appName.formatForDB»_js'));
                            } else {
                                $(this).setCustomValidity('');
                            }
                        });
                    «ENDIF»
                «ENDFOR»
                «IF entities.exists[getUniqueDerivedFields.filter[!primaryKey].size > 0]»
                    $('.validate-unique').each( function() {
                        if («vendorAndName»UniqueCheck('«name.formatForCode»', $(this).val(), $(this), id)) {
                            $(this).setCustomValidity(Zikula.__('This value is already assigned, but must be unique. Please change it.', 'module_«appName.formatForDB»_js'));
                        } else {
                            $(this).setCustomValidity('');
                        }
                    });
                «ENDIF»
            «ENDIF»
        }
    '''
}
