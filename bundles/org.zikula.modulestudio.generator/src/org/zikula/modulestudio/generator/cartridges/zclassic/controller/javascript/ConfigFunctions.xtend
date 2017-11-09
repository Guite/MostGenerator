package org.zikula.modulestudio.generator.cartridges.zclassic.controller.javascript

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ConfigFunctions {

    extension FormattingExtensions = new FormattingExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    /**
     * Entry point for the JavaScript file with display functionality.
     */
    def generate(Application it, IFileSystemAccess fsa) {
        var fileName = appName + '.Config.js'
        if (!shouldBeSkipped(getAppJsPath + fileName)) {
            println('Generating JavaScript for config functions')
            if (shouldBeMarked(getAppJsPath + fileName)) {
                fileName = appName + '.generated.js'
            }
            fsa.generateFile(getAppJsPath + fileName, generate)
        }
    }

    def private generate(Application it) '''
        'use strict';

        function «prefix.formatForDB»ToggleShrinkSettings(fieldName) {
            var idSuffix = fieldName.replace('«appName.toLowerCase»_appsettings_', '');
            jQuery('#shrinkDetails' + idSuffix).toggleClass('hidden', !jQuery('#«appName.toLowerCase»_appsettings_enableShrinkingFor' + idSuffix).prop('checked'));
        }

        jQuery(document).ready(function () {
            jQuery('.shrink-enabler').each(function (index) {
                jQuery(this).bind('click keyup', function (event) {
                    «prefix.formatForDB»ToggleShrinkSettings(jQuery(this).attr('id').replace('enableShrinkingFor', ''));
                });
                «prefix.formatForDB»ToggleShrinkSettings(jQuery(this).attr('id').replace('enableShrinkingFor', ''));
            });
        });
    '''
}
