package org.zikula.modulestudio.generator.cartridges.zclassic.controller.javascript

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class HistoryFunctions {

    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    /**
     * Entry point for the JavaScript file with version history functionality.
     */
    def generate(Application it, IMostFileSystemAccess fsa) {
        if (!hasLoggable) {
            return
        }
        'Generating JavaScript for version history view'.printIfNotTesting(fsa)
        val fileName = appName + '.VersionHistory.js'
        fsa.generateFile(getAppJsPath + fileName, generate)
    }

    def private generate(Application it) '''
        'use strict';

        function updateVersionSelectionState() {
            var amountOfSelectedVersions;

            amountOfSelectedVersions = jQuery('.«vendorAndName.toLowerCase»-toggle-checkbox:checked').length;
            if (2 < amountOfSelectedVersions) {
                jQuery(this).prop('checked', false);
                amountOfSelectedVersions--;
            }
            jQuery('#compareButton').prop('disabled', 2 != amountOfSelectedVersions);
        }

        jQuery(document).ready(function () {
            jQuery('.«vendorAndName.toLowerCase»-toggle-checkbox').click(updateVersionSelectionState);
            updateVersionSelectionState();
        });
    '''
}
