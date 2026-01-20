package org.zikula.modulestudio.generator.cartridges.symfony.controller.action

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Entity
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess

interface ActionInterface {
    /**
     * Returns name of this action.
     */
    def String name(Application it)

    /**
     * Returns whether this action is required for a given entity or not.
     */
    def Boolean requiredFor(Entity it)

    /**
     * Main entry point.
     */
    def void generate(Application it, IMostFileSystemAccess fsa)

    /**
     * Returns import statement for controllers.
     */
    def String controllerImport(Application it)

    /**
     * Returns constructor argument for controllers.
     */
    def String controllerInjection(Application it)

    /**
     * Generates usage inside controllers.
     */
    def CharSequence controllerUsage(Application it, Entity entity)
}
