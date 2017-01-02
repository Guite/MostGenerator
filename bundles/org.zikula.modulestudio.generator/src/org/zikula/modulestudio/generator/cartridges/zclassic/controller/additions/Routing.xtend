package org.zikula.modulestudio.generator.cartridges.zclassic.controller.additions

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
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
    def generate(Application it, IFileSystemAccess fsa) {
        var configFileName = getResourcesPath + 'config/routing.yml'
        if (!shouldBeSkipped(configFileName)) {
            if (shouldBeMarked(configFileName)) {
                configFileName = getResourcesPath + 'config/routing.generated.yml'
            }
            fsa.generateFile(configFileName, routingConfig)
        }
    }

    def private routingConfig(Application it) '''
        «appName.toLowerCase»:
            # define routing support for these controllers
            resource: "@«appName»/Controller"
            # enable support for defining routes by annotations
            type: annotation
    '''
}
