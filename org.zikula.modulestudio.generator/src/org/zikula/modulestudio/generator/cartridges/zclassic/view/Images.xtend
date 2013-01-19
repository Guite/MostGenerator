package org.zikula.modulestudio.generator.cartridges.zclassic.view

import com.google.inject.Inject
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils
import de.guite.modulestudio.metamodel.modulestudio.Application
import org.eclipse.xtext.generator.IFileSystemAccess

class Images {
    @Inject extension NamingExtensions = new NamingExtensions()
    @Inject extension Utils = new Utils()

    /**
     * Entry point for all application images.
     */
    def generate(Application it, IFileSystemAccess fsa) {
        val imagePath = getAppImagePath
        // This index.html file will be removed later. At the moment we need it to create according directories.
        fsa.generateFile(imagePath + 'index.html', msUrl)

        //fsa.generateFile(imagePath + 'admin.png', adminImage)
    }

    /**
     * admin icon 48x48
     * /
    def private adminImage(Application it) {
    }*/
}
