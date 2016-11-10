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
        // These files will be removed later. At the moment we need them
        // for creating according directories.
        // See https://github.com/Guite/MostGenerator/issues/8 for more information.
        val localePath = getAppLocalePath
        createPlaceholder(fsa, localePath)
        if (!targets('1.3.x')) {
            return
        }
        createPlaceholder(fsa, localePath + 'de/')
        createPlaceholder(fsa, localePath + 'de/LC_MESSAGES/')
    }
}
