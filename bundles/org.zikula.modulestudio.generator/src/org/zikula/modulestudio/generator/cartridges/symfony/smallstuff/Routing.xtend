package org.zikula.modulestudio.generator.cartridges.symfony.smallstuff

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.extensions.Utils

/**
 * This class generates routing configuration file for the Symfony Routing component.
 * The generated file uses the YAML syntax for configuration.
 */
class Routing {

    extension Utils = new Utils

    /**
     * Entry point for Routing YAML file.
     */
    def generate(Application it, IMostFileSystemAccess fsa) {
        fsa.generateFile('config/routing.yaml', routingConfig)
    }

    def private routingConfig(Application it) '''
        «appName.toLowerCase»:
            resource: '@«appName»/src/Controller' # TODO src is a workaround for https://github.com/symfony/symfony/issues/46482
            type: attribute
    '''
}
