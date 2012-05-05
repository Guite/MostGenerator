package org.zikula.modulestudio.generator.workflow.components

import org.eclipse.emf.mwe.core.monitor.NullProgressMonitor
import org.eclipse.emf.mwe2.runtime.workflow.IWorkflowComponent
import org.eclipse.emf.mwe2.runtime.workflow.IWorkflowContext

class ManualProgressMonitor implements IWorkflowComponent {

    String outputSlot = null

    def setOutputSlot(String outputSlot) {
        this.outputSlot = outputSlot
    }

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
	
	override postInvoke() {
		throw new UnsupportedOperationException('Auto-generated function stub')
	}
	
	override preInvoke() {
		throw new UnsupportedOperationException('Auto-generated function stub')
	}
}
