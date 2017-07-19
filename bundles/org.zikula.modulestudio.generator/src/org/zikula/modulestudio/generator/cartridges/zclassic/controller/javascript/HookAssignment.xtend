package org.zikula.modulestudio.generator.cartridges.zclassic.controller.javascript

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class HookAssignment {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    /**
     * Entry point for the JavaScript file with hook assignment functionality.
     */
    def generate(Application it, IFileSystemAccess fsa) {
        if (!hasUiHooksProviders) {
            return
        }
        var fileName = appName + '.HookAssignment.js'
        if (!shouldBeSkipped(getAppJsPath + fileName)) {
            println('Generating JavaScript for UI hook functions')
            if (shouldBeMarked(getAppJsPath + fileName)) {
                fileName = appName + '.generated.js'
            }
            fsa.generateFile(getAppJsPath + fileName, generate)
        }
    }

    def private generate(Application it) '''
        'use strict';

        «attachObject»

        «detachObject»

        «onLoad»
    '''

    def private attachObject(Application it) '''
        /**
         * Adds a hook assignment for a certain object.
         */
        function «vendorAndName»AttachHookObject(elem)
        {
            // TODO
        }
    '''

    def private detachObject(Application it) '''
        /**
         * Removes a hook assignment for a certain object.
         */
        function «vendorAndName»DetachHookObject(elem)
        {
            jQuery.ajax({
                method: 'POST',
                url: Routing.generate('«appName.formatForDB»_ajax_detachhookobject'),
                data: {
                    id: jQuery(elem).data('assignment-id')
                },
                success: function(data) {
                    window.location.reload();
                }
            });
        }
    '''

    def private onLoad(Application it) '''
        jQuery(document).ready(function() {
            jQuery('.attach-«appName.formatForDB»-object').each(function (index) {
                jQuery(this).click(«vendorAndName»AttachHookObject);
                jQuery(this).removeClass('hidden');
            });
            jQuery('.detach-«appName.formatForDB»-object').each(function (index) {
                jQuery(this).click(«vendorAndName»DetachHookObject);
                jQuery(this).removeClass('hidden');
            });
        });
    '''
}
