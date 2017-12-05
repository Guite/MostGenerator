package org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Translations {

    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils
    
    /**
     * Entry point for module translations.
     */
    def generate(Application it, IFileSystemAccess fsa) {
        createPlaceholder(fsa, getAppLocalePath)
    }
}
