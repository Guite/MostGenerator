package org.zikula.modulestudio.generator.cartridges.zclassic.controller.javascript

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
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
    def generate(Application it, IMostFileSystemAccess fsa) {
        if (!hasUiHooksProviders) {
            return
        }
        'Generating JavaScript for UI hook functions'.printIfNotTesting(fsa)
        val fileName = appName + '.HookAssignment.js'
        fsa.generateFile(getAppJsPath + fileName, generate)
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
        function «vendorAndName»AttachHookObject(attachLink, entityId) {
            jQuery.ajax({
                method: 'POST',
                url: Routing.generate('«appName.formatForDB»_ajax_attachhookobject'),
                data: {
                    owner: attachLink.data('owner'),
                    areaId: attachLink.data('area-id'),
                    objectId: attachLink.data('object-id'),
                    url: attachLink.data('url'),
                    assignedEntity: attachLink.data('assigned-entity'),
                    assignedId: entityId
                }
            }).done(function (data) {
                window.location.reload();
            });
        }
    '''

    def private detachObject(Application it) '''
        /**
         * Removes a hook assignment for a certain object.
         */
        function «vendorAndName»DetachHookObject() {
            jQuery.ajax({
                method: 'POST',
                url: Routing.generate('«appName.formatForDB»_ajax_detachhookobject'),
                data: {
                    id: jQuery(this).data('assignment-id')
                }
            }).done(function (data) {
                window.location.reload();
            });
        }
    '''

    def private onLoad(Application it) '''
        jQuery(document).ready(function () {
            jQuery('.detach-«appName.formatForDB»-object')
                .click(«vendorAndName»DetachHookObject)
                .removeClass('«IF targets('3.0')»d-none«ELSE»hidden«ENDIF»');
        });
    '''
}
