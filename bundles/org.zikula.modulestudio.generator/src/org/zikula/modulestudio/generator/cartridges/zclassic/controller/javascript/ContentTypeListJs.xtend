package org.zikula.modulestudio.generator.cartridges.zclassic.controller.javascript

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ContentTypeListJs {

    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    def generate(Application it, IMostFileSystemAccess fsa) {
        if (!generateListContentType) {
            return
        }
        'Generating JavaScript for content type editing'.printIfNotTesting(fsa)
        val fileName = appName + '.ContentType.List.Edit.js'
        fsa.generateFile(getAppJsPath + fileName, generate)
    }

    def private generate(Application it) '''
        'use strict';

        (function($) {
            $(document).ready(function () {
                $('#zikulacontentmodule_contentitem_contentData_template').change(function () {
                    $('#customTemplateArea').toggleClass('«IF targets('3.0')»d-none«ELSE»hidden«ENDIF»', 'custom' !== $(this).val());
                }).trigger('change');
            });
        })(jQuery)
    '''
}
