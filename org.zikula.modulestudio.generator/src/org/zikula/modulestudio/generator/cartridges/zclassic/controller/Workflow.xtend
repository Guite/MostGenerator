package org.zikula.modulestudio.generator.cartridges.zclassic.controller

import de.guite.modulestudio.metamodel.modulestudio.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.workflows.SimpleApproval

/**
 * Entry point for all workflows.
 */
class Workflow {
    def generate(Application it, IFileSystemAccess fsa) {
        new SimpleApproval().generate(it, fsa)
    }
}
