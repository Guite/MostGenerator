package org.zikula.modulestudio.generator.cartridges.zclassic.controller

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.workflows.Definition

/**
 * Entry point for all workflows.
 */
class Workflow {

    def generate(Application it, IFileSystemAccess fsa) {
        // YAML definitions
        new Definition().generate(it, fsa)
    }
}
