package org.zikula.modulestudio.generator.cartridges.zclassic.controller

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.workflows.Definition
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.workflows.LegacyDefinition
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.workflows.LegacyOperations
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.workflows.LegacyPermissionCheck
import org.zikula.modulestudio.generator.extensions.Utils

/**
 * Entry point for all workflows.
 */
class Workflow {

    extension Utils = new Utils

    def generate(Application it, IFileSystemAccess fsa) {
        if (targets('1.4-dev')) {
            // YAML definitions
            new Definition().generate(it, fsa)
        } else {
            // legacy XML definitions
            new LegacyDefinition().generate(it, fsa)
            // permission checks
            new LegacyPermissionCheck().generate(it, fsa)
            // operations
            new LegacyOperations().generate(it, fsa)
        }
    }
}
