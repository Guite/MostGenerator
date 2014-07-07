package org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff

import de.guite.modulestudio.metamodel.modulestudio.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Translations {
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils
    
    /**
     * Entry point for module language defines.
     */
    def generate(Application it, IFileSystemAccess fsa) {
        // These index.html files will be removed later. At the moment we need them
        // for creating according directories.
        // See https://github.com/Guite/MostGenerator/issues/8 for more information.
        if (!shouldBeSkipped(getAppLocalePath + 'index.html')) {
            fsa.generateFile(getAppLocalePath + 'index.html', msUrl)
        }
        if (!shouldBeSkipped(getAppLocalePath + 'de/index.html')) {
            fsa.generateFile(getAppLocalePath + 'de/index.html', msUrl)
        }
        if (!shouldBeSkipped(getAppLocalePath + 'de/LC_MESSAGES/index.html')) {
            fsa.generateFile(getAppLocalePath + 'de/LC_MESSAGES/index.html', msUrl)
        }
    }
}
