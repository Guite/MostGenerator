package org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Translations {
    @Inject extension NamingExtensions = new NamingExtensions()
    @Inject extension Utils = new Utils()

    /**
     * Entry point for module language defines.
     */
    def generate(Application it, IFileSystemAccess fsa) {
    	// These index.html files will be removed later. At the moment we need them
    	// for creating according directories.
    	// See https://github.com/Guite/MostGenerator/issues/8 for more information.
        fsa.generateFile(getAppSourcePath + 'locale/index.html', msUrl)
        fsa.generateFile(getAppSourcePath + 'locale/de/index.html', msUrl)
        fsa.generateFile(getAppSourcePath + 'locale/de/LC_MESSAGES/index.html', msUrl)
    }
}
