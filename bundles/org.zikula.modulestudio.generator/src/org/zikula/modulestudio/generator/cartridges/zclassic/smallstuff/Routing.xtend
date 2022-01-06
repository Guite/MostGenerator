package org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

/**
 * This class generates routing configuration file for the Symfony Routing component.
 * The generated file uses the YAML syntax for configuration.
 */
class Routing {

    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    /**
     * Entry point for Routing YAML file.
     */
    def generate(Application it, IMostFileSystemAccess fsa) {
        fsa.generateFile(getResourcesPath + 'config/routing.yaml', routingConfig)
    }

    def private routingConfig(Application it) '''
        «appName.toLowerCase»:
            # define routing support for these controllers
            resource: "@«appName»/Controller"
            # enable support for defining routes by annotations
            type: annotation
    '''
}
