package org.zikula.modulestudio.generator.workflow.components

import org.eclipse.emf.mwe.core.monitor.NullProgressMonitor
import org.eclipse.emf.mwe2.runtime.workflow.IWorkflowComponent
import org.eclipse.emf.mwe2.runtime.workflow.IWorkflowContext

/**
 * Workflow component for manual progress monitor.
 */
class ManualProgressMonitor implements IWorkflowComponent {

    /**
     * The output slot.
     */
    String outputSlot = null

    /**
     * Sets the output slot.
     *
     * @param outputSlot The given output slot.
     * @return The new output slot.
     */
    def setOutputSlot(String outputSlot) {
        this.outputSlot = outputSlot
    }

    /**
     * Invokes the workflow component.
     * 
     * @param ctx
     *            The given {@link IWorkflowContext} instance.
     */
	override invoke(IWorkflowContext ctx) {
        // look if monitor is already there
        var monitorFound = false
        for (currentSlotName : ctx.getSlotNames) {
            if (currentSlotName.equals(outputSlot)) {
                monitorFound = true
                //break (no break yet in Xtend, wait until 2.3)
            }
        }
        if (monitorFound == false) {
            // use the monitor of MWE2 for our manual generator runs
            // ctx.set(outputSlot, monitor)

            // create dummy monitor and assign it to workflow context
            ctx.put(outputSlot, new NullProgressMonitor())
        }
	}
	
    /**
     * Performs actions before the invocation.
     */
	override preInvoke() {
		// nothing to do yet
	}

    /**
     * Performs actions after the invocation.
     */
	override postInvoke() {
		// nothing to do yet
	}
}
