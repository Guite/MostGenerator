package org.zikula.modulestudio.generator.cartridges.zclassic.controller.javascript

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class HistoryFunctions {

    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    /**
     * Entry point for the JavaScript file with version history functionality.
     */
    def generate(Application it, IFileSystemAccess fsa) {
        var fileName = appName + '.VersionHistory.js'
        if (!shouldBeSkipped(getAppJsPath + fileName)) {
            println('Generating JavaScript for version history view')
            if (shouldBeMarked(getAppJsPath + fileName)) {
                fileName = appName + '.VersionHistory.generated.js'
            }
            fsa.generateFile(getAppJsPath + fileName, generate)
        }
    }

    def private generate(Application it) '''
        'use strict';

        function updateVersionSelectionState() {
            var amountOfSelectedVersions;

            amountOfSelectedVersions = jQuery('.«vendorAndName.toLowerCase»-toggle-checkbox:checked').length;
            if (amountOfSelectedVersions > 2) {
                jQuery(this).prop('checked', false);
                amountOfSelectedVersions--;
            }
            jQuery('#compareButton').prop('disabled', amountOfSelectedVersions != 2);
        }

        jQuery(document).ready(function() {
            jQuery('.«vendorAndName.toLowerCase»-toggle-checkbox').click(updateVersionSelectionState);
            updateVersionSelectionState();
        });
    '''
}
