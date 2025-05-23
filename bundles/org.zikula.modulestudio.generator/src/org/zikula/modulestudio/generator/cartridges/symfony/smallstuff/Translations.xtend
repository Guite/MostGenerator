package org.zikula.modulestudio.generator.cartridges.symfony.smallstuff

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.extensions.Utils

class Translations {

    extension Utils = new Utils

    /**
     * Entry point for bundle translations.
     */
    def generate(Application it, IMostFileSystemAccess fsa) {
        fsa.createPlaceholder('translations/')
    }
}
