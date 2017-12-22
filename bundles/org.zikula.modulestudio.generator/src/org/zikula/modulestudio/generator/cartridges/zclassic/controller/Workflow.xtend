package org.zikula.modulestudio.generator.cartridges.zclassic.controller

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.workflows.Definition

/**
 * Entry point for all workflows.
 */
class Workflow {

    def generate(Application it, IMostFileSystemAccess fsa) {
        // YAML definitions
        new Definition().generate(it, fsa)
    }
}
