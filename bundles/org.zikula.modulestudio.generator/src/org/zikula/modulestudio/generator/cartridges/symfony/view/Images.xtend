package org.zikula.modulestudio.generator.cartridges.symfony.view

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Images {
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    /**
     * Entry point for all application images.
     */
    def generate(Application it, IMostFileSystemAccess fsa) {
        // create a placeholder file
        // the actual images are generated and copied in org.zikula.modulestudio.generator.application.ImageCreator and WorkflowPostProcess classes
        fsa.createPlaceholder(getAppImagePath)
    }
}
