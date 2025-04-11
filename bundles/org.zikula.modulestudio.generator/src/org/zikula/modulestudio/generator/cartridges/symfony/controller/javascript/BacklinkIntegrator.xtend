package org.zikula.modulestudio.generator.cartridges.symfony.controller.javascript

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class BacklinkIntegrator {

    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    def generate(Application it, IMostFileSystemAccess fsa) {
        'Generating JavaScript for backlink integration'.printIfNotTesting(fsa)
        val fileName = appName + '.Backlink.Integration.js'
        fsa.generateFile(getAppJsPath + fileName, generate)
    }

    def private generate(Application it) '''
        'use strict';

        (function($) {
            $(document).ready(function () {
                if (1 > $('#poweredBy').length || 1 > $('#poweredByMost').length) {
                    return;
                }

                $('#poweredBy')
                    .html($('#poweredBy').html() + ' ' + Translator.trans('and') + ' ')
                    .append($('#poweredByMost a'))
                ;
                $('#poweredByMost').remove();
            });
        })(jQuery);
    '''
}
