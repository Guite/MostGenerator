package org.zikula.modulestudio.generator.workflow.components

import org.eclipse.emf.common.util.Diagnostic
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.emf.ecore.util.Diagnostician
import org.eclipse.emf.mwe2.runtime.workflow.IWorkflowContext

/**
 * Workflow component for running validation on input model.
 */
class Validator extends WorkflowComponentWithSlot {

    /**
     * Whether validation should be executed or not.
     */
    private Boolean enabled = true

    /**
     * Invokes the workflow component.
     * 
     * @param ctx
     *            The given {@link org.eclipse.emf.mwe2.runtime.workflow.IWorkflowContext} instance.
     */
    override invoke(IWorkflowContext ctx) {
        if (!enabled) {
            println('Skipping validation.')
            return
        }
        println('Running validation.')

        val resource = ctx.get(getSlot()) as Resource
        val theModel = resource.getContents().head
        val diagnostic = Diagnostician.INSTANCE.validate(theModel)
        if (diagnostic.severity == Diagnostic.ERROR) {
            println('Model has errors: ' + diagnostic)
            throw new IllegalStateException('Aborting generation as the model has errors: ' + diagnostic)
        } else if (diagnostic.severity == Diagnostic.WARNING) {
            println('Model has warnings: ' + diagnostic)
        }
    }

    /**
     * Returns the enabled flag.
     * 
     * @return The enabled flag.
     */
    def isEnabled() {
        enabled
    }

    /**
     * Sets the enabled flag.
     * 
     * @param enabled
     *            The enabled flag.
     */
    def setEnabled(String enabled) {
        enabled = Boolean.valueOf(enabled)
    }
}
