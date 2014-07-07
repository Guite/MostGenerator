package org.zikula.modulestudio.generator.cartridges.zclassic.controller.additions

import de.guite.modulestudio.metamodel.modulestudio.Application
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
     * Entry point for workflow definitions.
     * This generates xml files describing the workflows used in the application.
     */
    def generate(Application it, IFileSystemAccess fsa) {
        if (targets('1.3.5')) {
            return
        }
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
            type:     annotation
    '''
}
