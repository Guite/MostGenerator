package org.zikula.modulestudio.generator.cartridges.zclassic.controller.javascript

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Application
import de.guite.modulestudio.metamodel.modulestudio.DateField
import de.guite.modulestudio.metamodel.modulestudio.DatetimeField
import de.guite.modulestudio.metamodel.modulestudio.TimeField
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Validation {
    @Inject extension FormattingExtensions = new FormattingExtensions
    @Inject extension ModelExtensions = new ModelExtensions
    @Inject extension NamingExtensions = new NamingExtensions
    @Inject extension Utils = new Utils

    /**
     * Entry point for the JavaScript file with validation functionality.
     */
    def generate(Application it, IFileSystemAccess fsa) {
        var fileName = ''
        if (targets('1.3.5')) {
            fileName = appName + '_validation.js'
        } else {
            fileName = appName + '.Validation.js'
        }
        if (!shouldBeSkipped(getAppJsPath + fileName)) {
            println('Generating JavaScript for validation')
            if (shouldBeMarked(getAppJsPath + fileName)) {
                if (targets('1.3.5')) {
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

        function «prefix()»Today(format)
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
        function «prefix()»ReadDate(val, includeTime)
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
        «IF getAllEntities.exists[getUniqueDerivedFields.filter[!primaryKey].size > 0]»

            /**
             * Performs a duplicate check for unique fields
             */
            function «prefix()»UniqueCheck(ucOt, val, elem, ucEx)
            {
                var params«IF targets('1.3.5')», request«ENDIF»;

                «IF targets('1.3.5')»
                    $('advice-validate-unique-' + elem.id).hide();
                    elem.removeClassName('validation-failed').removeClassName('validation-passed');
                «ELSE»
                    $('advice-validate-unique-' + elem.attr('id')).hide();
                    elem.parent().parent().removeClass('has-error').removeClassName('has-success');
                «ENDIF»

                // build parameters object
                params = {
                    ot: ucOt,
                    fn: encodeURIComponent(elem.«IF targets('1.3.5')»id«ELSE»attr('id')«ENDIF»),
                    v: encodeURIComponent(val),
                    ex: ucEx
                };

                /** TODO fix the following call to work within validation context */
                return true;

                «IF targets('1.3.5')»
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
                        url: Zikula.Config.baseURL + 'index.php?module=«appName»&type=ajax&func=checkForDuplicate',
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

        function «prefix()»ValidateNoSpace(val)
        {
            var valStr;
            valStr = new String(val);

            return (valStr.indexOf(' ') === -1);
        }
        «IF hasColourFields»

            function «prefix()»ValidateHtmlColour(val)
            {
                var valStr;
                valStr = new String(val);

                return valStr === '' || (/^#[0-9a-f]{3}([0-9a-f]{3})?$/i.test(valStr));
            }
        «ENDIF»
        «IF hasUploads»

            function «prefix()»ValidateUploadExtension(val, elem)
            {
                var fileExtension, allowedExtensions;
                if (val === '') {
                    return true;
                }
                fileExtension = '.' + val.substr(val.lastIndexOf('.') + 1);
                allowedExtensions = $(«IF !targets('1.3.5')»'#' + elem.attr('id')«ELSE»elem.id«ENDIF» + 'FileExtensions').innerHTML;
                allowedExtensions = '(.' + allowedExtensions.replace(/, /g, '|.').replace(/,/g, '|.') + ')$';
                allowedExtensions = new RegExp(allowedExtensions, 'i');

                return allowedExtensions.test(val);
            }
        «ENDIF»
        «val datetimeFields = getAllEntityFields.filter(DatetimeField)»
        «IF !datetimeFields.empty»
            «IF datetimeFields.exists[past]»

                function «prefix()»ValidateDatetimePast(val)
                {
                    var valStr, cmpVal;
                    valStr = new String(val);
                    cmpVal = «prefix()»ReadDate(valStr, true);

                    return valStr === '' || (cmpVal < «prefix()»Today('datetime'));
                }
            «ENDIF»
            «IF datetimeFields.exists[future]»

                function «prefix()»ValidateDatetimeFuture(val)
                {
                    var valStr, cmpVal;
                    valStr = new String(val);
                    cmpVal = «prefix()»ReadDate(valStr, true);

                    return valStr === '' || (cmpVal >= «prefix()»Today('datetime'));
                }
            «ENDIF»
        «ENDIF»
        «val dateFields = getAllEntityFields.filter(DateField)»
        «IF !dateFields.empty»
            «IF dateFields.exists[past]»

                function «prefix()»ValidateDatePast(val)
                {
                    var valStr, cmpVal;
                    valStr = new String(val);
                    cmpVal = «prefix()»ReadDate(valStr, false);

                    return valStr === '' || (cmpVal < «prefix()»Today('date'));
                }
            «ENDIF»
            «IF dateFields.exists[future]»

                function «prefix()»ValidateDateFuture(val)
                {
                    var valStr, cmpVal;
                    valStr = new String(val);
                    cmpVal = «prefix()»ReadDate(valStr, false);

                    return valStr === '' || (cmpVal >= «prefix()»Today('date'));
                }
            «ENDIF»
        «ENDIF»
        «val timeFields = getAllEntityFields.filter(TimeField)»
        «IF !timeFields.empty»
            «IF timeFields.exists[past]»

                function «prefix()»ValidateTimePast(val)
                {
                    var cmpVal;
                    cmpVal = new String(val);

                    return cmpVal === '' || (cmpVal < «prefix()»Today('time'));
                }
            «ENDIF»
            «IF timeFields.exists[future]»

                function «prefix()»ValidateTimeFuture(val)
                {
                    var cmpVal;
                    cmpVal = new String(val);

                    return cmpVal === '' || (cmpVal >= «prefix()»Today('time'));
                }
            «ENDIF»
        «ENDIF»
        «FOR entity : getAllEntities»
            «val startDateField = entity.getStartDateField»
            «val endDateField = entity.getEndDateField»
            «IF startDateField !== null && endDateField !== null»

                function «prefix()»ValidateDateRange«entity.name.formatForCodeCapital»(val)
                {
                    «val validateClass = 'validate-daterange-' + entity.name.formatForDB»
                    «val startFieldName = startDateField.name.formatForCode»
                    «val endFieldName = endDateField.name.formatForCode»
                    «IF targets('1.3.5')»
                        cmpVal = «prefix()»ReadDate($F('«startFieldName»'), «(startDateField instanceof DatetimeField).displayBool»);
                        cmpVal2 = «prefix()»ReadDate($F('«endFieldName»'), «(endDateField instanceof DatetimeField).displayBool»);
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
                        cmpVal = «prefix()»ReadDate($('#«startFieldName»').val(), «(startDateField instanceof DatetimeField).displayBool»);
                        cmpVal2 = «prefix()»ReadDate($('#«endFieldName»').val(), «(endDateField instanceof DatetimeField).displayBool»);
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
         * «IF targets('1.3.5')»Adds«ELSE»Runs«ENDIF» special validation rules.
         */
        function «prefix()»«IF targets('1.3.5')»AddCommonValidationRules«ELSE»PerformCustomValidationRules«ENDIF»(objectType, id)
        {
            «IF targets('1.3.5')»
                Validation.addAllThese([
                    ['validate-nospace', Zikula.__('No spaces', 'module_«appName.formatForDB»_js'), function(val, elem) {
                        return «prefix()»ValidateNoSpace(val);
                    }],
                    «IF hasColourFields»
                        ['validate-htmlcolour', Zikula.__('Please select a valid html colour code.', 'module_«appName.formatForDB»_js'), function(val, elem) {
                            return «prefix()»ValidateHtmlColour(val);
                        }],
                    «ENDIF»
                    «IF hasUploads»
                        ['validate-upload', Zikula.__('Please select a valid file extension.', 'module_«appName.formatForDB»_js'), function(val, elem) {
                            return «prefix()»ValidateUploadExtension(val, elem);
                        }],
                    «ENDIF»
                    «IF !datetimeFields.empty»
                        «IF datetimeFields.exists[past]»
                            ['validate-datetime-past', Zikula.__('Please select a value in the past.', 'module_«appName.formatForDB»_js'), function(val, elem) {
                                return «prefix()»ValidateDatetimePast(val);
                            }],
                        «ENDIF»
                        «IF datetimeFields.exists[future]»
                            ['validate-datetime-future', Zikula.__('Please select a value in the future.', 'module_«appName.formatForDB»_js'), function(val, elem) {
                                return «prefix()»ValidateDatetimeFuture(val);
                            }],
                        «ENDIF»
                    «ENDIF»
                    «IF !dateFields.empty»
                        «IF dateFields.exists[past]»
                            ['validate-date-past', Zikula.__('Please select a value in the past.', 'module_«appName.formatForDB»_js'), function(val, elem) {
                                return «prefix()»ValidateDatePast(val);
                            }],
                        «ENDIF»
                        «IF dateFields.exists[future]»
                            ['validate-date-future', Zikula.__('Please select a value in the future.', 'module_«appName.formatForDB»_js'), function(val, elem) {
                                return «prefix()»ValidateDateFuture(val);
                            }],
                        «ENDIF»
                    «ENDIF»
                    «IF !timeFields.empty»
                        «IF timeFields.exists[past]»
                            ['validate-time-past', Zikula.__('Please select a value in the past.', 'module_«appName.formatForDB»_js'), function(val, elem) {
                                return «prefix()»ValidateTimePast(val);
                            }],
                        «ENDIF»
                        «IF timeFields.exists[future]»
                            ['validate-time-future', Zikula.__('Please select a value in the future.', 'module_«appName.formatForDB»_js'), function(val, elem) {
                                return «prefix()»ValidateTimeFuture(val);
                            }],
                        «ENDIF»
                    «ENDIF»
                    «FOR entity : getAllEntities»
                        «val startDateField = entity.getStartDateField»
                        «val endDateField = entity.getEndDateField»
                        «IF startDateField !== null && endDateField !== null»
                            ['validate-daterange-«entity.name.formatForDB»', Zikula.__('The start must be before the end.', 'module_«appName.formatForDB»_js'), function(val, elem) {
                                return «prefix()»ValidateDateRange«entity.name.formatForCodeCapital»(val);
                            }],
                        «ENDIF»
                    «ENDFOR»
                    «IF getAllEntities.exists[getUniqueDerivedFields.filter[!primaryKey].size > 0]»
                        ['validate-unique', Zikula.__('This value is already assigned, but must be unique. Please change it.', 'module_«appName.formatForDB»_js'), function(val, elem) {
                            return «prefix()»UniqueCheck('«name.formatForCode»', val, elem, id);
                        }]
                    «ENDIF»
                ]);
            «ELSE»
                $('.validate-nospace').each( function() {
                    if («prefix()»ValidateNoSpace($(this).val())) {
                        $(this).setCustomValidity(Zikula.__('This value must not contain spaces.', 'module_«appName.formatForDB»_js'));
                    } else {
                        $(this).setCustomValidity('');
                    }
                });
                «IF hasColourFields»
                    $('.validate-htmlcolour').each( function() {
                        if («prefix()»ValidateHtmlColour($(this).val())) {
                            $(this).setCustomValidity(Zikula.__('Please select a valid html colour code.', 'module_«appName.formatForDB»_js'));
                        } else {
                            $(this).setCustomValidity('');
                        }
                    });
                «ENDIF»
                «IF hasUploads»
                    $('.validate-upload').each( function() {
                        if («prefix()»ValidateUploadExtension($(this).val(), $(this))) {
                            $(this).setCustomValidity(Zikula.__('Please select a valid file extension.', 'module_«appName.formatForDB»_js'));
                        } else {
                            $(this).setCustomValidity('');
                        }
                    });
                «ENDIF»
                «IF !datetimeFields.empty»
                    «IF datetimeFields.exists[past]»
                        $('.validate-datetime-past').each( function() {
                            if («prefix()»ValidateDatetimePast($(this).val())) {
                                $(this).setCustomValidity(Zikula.__('Please select a value in the past.', 'module_«appName.formatForDB»_js'));
                            } else {
                                $(this).setCustomValidity('');
                            }
                        });
                    «ENDIF»
                    «IF datetimeFields.exists[future]»
                        $('.validate-datetime-future').each( function() {
                            if («prefix()»ValidateDatetimeFuture($(this).val())) {
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
                            if («prefix()»ValidateDatePast($(this).val())) {
                                $(this).setCustomValidity(Zikula.__('Please select a value in the past.', 'module_«appName.formatForDB»_js'));
                            } else {
                                $(this).setCustomValidity('');
                            }
                        });
                    «ENDIF»
                    «IF dateFields.exists[future]»
                        $('.validate-date-future').each( function() {
                            if («prefix()»ValidateDateFuture($(this).val())) {
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
                            if («prefix()»ValidateTimePast($(this).val())) {
                                $(this).setCustomValidity(Zikula.__('Please select a value in the past.', 'module_«appName.formatForDB»_js'));
                            } else {
                                $(this).setCustomValidity('');
                            }
                        });
                    «ENDIF»
                    «IF timeFields.exists[future]»
                        $('.validate-time-future').each( function() {
                            if («prefix()»ValidateTimeFuture($(this).val())) {
                                $(this).setCustomValidity(Zikula.__('Please select a value in the future.', 'module_«appName.formatForDB»_js'));
                            } else {
                                $(this).setCustomValidity('');
                            }
                        });
                    «ENDIF»
                «ENDIF»
                «FOR entity : getAllEntities»
                    «val startDateField = entity.getStartDateField»
                    «val endDateField = entity.getEndDateField»
                    «IF startDateField !== null && endDateField !== null»
                        $('.validate-daterange-«entity.name.formatForDB»').each( function() {
                            if («prefix()»ValidateDateRange«entity.name.formatForCodeCapital»($(this).val())) {
                                $(this).setCustomValidity(Zikula.__('The start must be before the end.', 'module_«appName.formatForDB»_js'));
                            } else {
                                $(this).setCustomValidity('');
                            }
                        });
                    «ENDIF»
                «ENDFOR»
                «IF getAllEntities.exists[getUniqueDerivedFields.filter[!primaryKey].size > 0]»
                    $('.validate-unique').each( function() {
                        if («prefix()»UniqueCheck('«name.formatForCode»', $(this).val(), $(this), id)) {
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
