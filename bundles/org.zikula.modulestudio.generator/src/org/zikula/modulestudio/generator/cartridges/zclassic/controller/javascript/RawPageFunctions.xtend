package org.zikula.modulestudio.generator.cartridges.zclassic.controller.javascript

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class RawPageFunctions {

    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    def generate(Application it, IMostFileSystemAccess fsa) {
        'Generating JavaScript for raw pages'.printIfNotTesting(fsa)
        val fileName = appName + '.RawPage.js'
        fsa.generateFile(getAppJsPath + fileName, generate)
    }

    def private generate(Application it) '''
        'use strict';

        (function($) {
            $(document).ready(function () {
                $('.dropdown-toggle').addClass('«IF targets('3.0')»d-none«ELSE»hidden«ENDIF»');
            });
        })(jQuery);
    '''
}
