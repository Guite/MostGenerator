package org.zikula.modulestudio.generator.cartridges.zclassic.view

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Images {
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    /**
     * Entry point for all application images.
     */
    def generate(Application it, IFileSystemAccess fsa) {
        val imagePath = getAppImagePath
        if (!shouldBeSkipped(imagePath + 'index.html')) {
            fsa.generateFile(imagePath + 'index.html', msUrl)
        }

        if (!shouldBeSkipped(imagePath + 'admin.png')) {
            //fsa.generateFile(imagePath + 'admin.png', adminImage)
        }
    }

    /**
     * admin icon 48x48
     * /
    def private adminImage(Application it) {
    }*/
}
