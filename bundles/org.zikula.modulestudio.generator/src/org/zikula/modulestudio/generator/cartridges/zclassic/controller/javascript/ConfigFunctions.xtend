package org.zikula.modulestudio.generator.cartridges.zclassic.controller.javascript

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ConfigFunctions {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelExtensions = new ModelExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    /**
     * Entry point for the JavaScript file with display functionality.
     */
    def generate(Application it, IMostFileSystemAccess fsa) {
        'Generating JavaScript for config functions'.printIfNotTesting(fsa)
        val fileName = appName + '.Config.js'
        fsa.generateFile(getAppJsPath + fileName, generate)
    }

    def private generate(Application it) '''
        'use strict';

        «IF hasImageFields»
            function «prefix.formatForDB»ToggleShrinkSettings(fieldName) {
                var idSuffix;

                idSuffix = fieldName.replace('«appName.toLowerCase»_config_', '');
                jQuery('#shrinkDetails' + idSuffix).toggleClass('hidden', !jQuery('#«appName.toLowerCase»_config_enableShrinkingFor' + idSuffix).prop('checked'));
            }

        «ENDIF»
        «IF hasLoggable»
            function «prefix.formatForDB»ToggleRevisionSettings(objectTypeCapitalised) {
                var idPrefix;
                var revisionHandling;

                idPrefix = '«appName.toLowerCase»_config_';
                revisionHandling = jQuery('#' + idPrefix + 'revisionHandlingFor' + objectTypeCapitalised).val();
                jQuery('#' + idPrefix + 'maximumAmountOf' + objectTypeCapitalised + 'Revisions').parents('.form-group').toggleClass('hidden', 'limitedByAmount' != revisionHandling);
                «IF targets('2.0')»
                    jQuery('#' + idPrefix + 'periodFor' + objectTypeCapitalised + 'Revisions_years').parents('.form-group').toggleClass('hidden', 'limitedByDate' != revisionHandling);
                «ENDIF»
            }

        «ENDIF»
        jQuery(document).ready(function () {
            «IF hasImageFields»
                jQuery('.shrink-enabler').each(function (index) {
                    jQuery(this).bind('click keyup', function (event) {
                        «prefix.formatForDB»ToggleShrinkSettings(jQuery(this).attr('id').replace('enableShrinkingFor', ''));
                    });
                    «prefix.formatForDB»ToggleShrinkSettings(jQuery(this).attr('id').replace('enableShrinkingFor', ''));
                });
            «ENDIF»
            «IF hasLoggable»
            «ENDIF»
        });
    '''
}
