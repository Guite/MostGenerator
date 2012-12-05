package org.zikula.modulestudio.generator.cartridges.zclassic.controller

import de.guite.modulestudio.metamodel.modulestudio.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.workflows.Definition
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.workflows.Operations
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.workflows.PermissionCheck

/**
 * Entry point for all workflows.
 */
class Workflow {
    def generate(Application it, IFileSystemAccess fsa) {
        // xml definitions
        new Definition().generate(it, fsa)
        // permission checks
        new PermissionCheck().generate(it, fsa)
        // operations
        new Operations().generate(it, fsa)
    }
}
