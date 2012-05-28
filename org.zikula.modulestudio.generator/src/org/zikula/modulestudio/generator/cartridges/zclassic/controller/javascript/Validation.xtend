package org.zikula.modulestudio.generator.cartridges.zclassic.controller.javascript

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Validation {
    @Inject extension FormattingExtensions = new FormattingExtensions()
    @Inject extension ModelExtensions = new ModelExtensions()
    @Inject extension NamingExtensions = new NamingExtensions()
    @Inject extension Utils = new Utils()

    /**
     * Entry point for the javascript file with validation functionality.
     */
    def generate(Application it, IFileSystemAccess fsa) {
        println('Generating javascript for validation')
        fsa.generateFile(getAppSourcePath(appName) + 'javascript/' + appName + '_validation.js', generate)
    }

    def private generate(Application it) '''
        'use strict';

        function «prefix»Today(format) {
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
        function «prefix»ReadDate(val, includeTime) {
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
        «IF getAllEntities.exists(e|e.getUniqueDerivedFields.filter(f|!f.primaryKey).size > 0)»

            /**
             * Performs a duplicate check for unique fields
             */
            function «prefix»UniqueCheck(ucOt, val, elem, ucEx) {
                var params, request;

                $('advice-validate-unique-' + elem.id).hide();
                elem.removeClassName('validation-failed').removeClassName('validation-passed');

                // build parameters object
                params = {ot: ucOt, fn: encodeURIComponent(elem.id), v: encodeURIComponent(val), ex: ucEx};

                /** TODO fix the following call to work within validation context */
                return true;

                request = new Zikula.Ajax.Request(Zikula.Config.baseURL + 'ajax.php?module=«appName»&func=checkForDuplicate', {
                    method: 'post',
                    parameters: params,
                    authid: 'FormAuthid',«/*from the Forms framework*/»
                    onComplete: function(req) {
                        // check if request was successful
                        if (!req.isSuccess()) {
                            Zikula.showajaxerror(req.getMessage());
                            return;
                        }

                        // get data returned by module
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
                });

                return true;
            }
        «ENDIF»

        /**
         * Add special validation rules.
         */
        function «prefix»AddCommonValidationRules(objectType, id) {
            Validation.addAllThese([
                ['validate-nospace', Zikula.__('No spaces', 'module_«appName»'), function(val, elem) {
                    var valStr;
                    valStr = new String(val);
                    return (valStr.indexOf(' ') === -1);
                }],
                «IF hasColourFields»
                ['validate-htmlcolour', Zikula.__('Please select a valid html colour code.', 'module_«appName»'), function(val, elem) {
                    var valStr;
                    valStr = new String(val);
                    return Validation.get('IsEmpty').test(val) || (/^#[0-9a-f]{3}([0-9a-f]{3})?$/i.test(valStr));
                }],
                «ENDIF»
                «IF hasUploads»
                ['validate-upload', Zikula.__('Please select a valid file extension.', 'module_«appName»'), function(val, elem) {
                    var allowedExtensions;
                    if (val === '') {
                        return true;
                    }
                    allowedExtensions = $('fileextensions' + elem.id).innerHTML;
                    allowedExtensions = '(.' + allowedExtensions.replace(/, /g, '|.') + ')$';
                    allowedExtensions = new RegExp(allowedExtensions, 'i');
                    return allowedExtensions.test(val);
                }],
                «ENDIF»
                ['validate-datetime-past', Zikula.__('Please select a value in the past.', 'module_«appName»'), function(val, elem) {
                    var valStr, cmpVal;
                    valStr = new String(val);
                    cmpVal = «prefix»ReadDate(valStr, true);
                    return Validation.get('IsEmpty').test(val) || (cmpVal < «prefix»Today('datetime'));
                }],
                ['validate-datetime-future', Zikula.__('Please select a value in the future.', 'module_«appName»'), function(val, elem) {
                    var valStr, cmpVal;
                    valStr = new String(val);
                    cmpVal = «prefix»ReadDate(valStr, true);
                    return Validation.get('IsEmpty').test(val) || (cmpVal >= «prefix»Today('datetime'));
                }],
                ['validate-date-past', Zikula.__('Please select a value in the past.', 'module_«appName»'), function(val, elem) {
                    var valStr, cmpVal;
                    valStr = new String(val);
                    cmpVal = «prefix»ReadDate(valStr, false);
                    return Validation.get('IsEmpty').test(val) || (cmpVal < «prefix»Today('date'));
                }],
                ['validate-date-future', Zikula.__('Please select a value in the future.', 'module_«appName»'), function(val, elem) {
                    var valStr, cmpVal;
                    valStr = new String(val);
                    cmpVal = «prefix»ReadDate(valStr, false);
                    return Validation.get('IsEmpty').test(val) || (cmpVal >= «prefix»Today('date'));
                }],
                ['validate-time-past', Zikula.__('Please select a value in the past.', 'module_«appName»'), function(val, elem) {
                    var cmpVal;
                    cmpVal = new String(val);
                    return Validation.get('IsEmpty').test(val) || (cmpVal < «prefix»Today('time'));
                }],
                ['validate-time-future', Zikula.__('Please select a value in the future.', 'module_«appName»'), function(val, elem) {
                    var cmpVal;
                    cmpVal = new String(val);
                    return Validation.get('IsEmpty').test(val) || (cmpVal >= «prefix()»Today('time'));
                }]«IF getAllEntities.exists(e|e.getUniqueDerivedFields.filter(f|!f.primaryKey).size > 0)»,
                ['validate-unique', Zikula.__('This value is already assigned, but must be unique. Please change it.', 'module_«appName»'), function(val, elem) {
                    return «prefix»UniqueCheck('«name.formatForCode»', val, elem, id);
                }]«ENDIF»
            ]);
        }
    '''
}
