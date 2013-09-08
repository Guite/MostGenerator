package org.zikula.modulestudio.generator.workflow.components

import org.eclipse.emf.mwe2.runtime.workflow.IWorkflowComponent
import org.eclipse.emf.mwe2.runtime.workflow.IWorkflowContext

/**
 * Workflow component class for a stop watch observing how long certain actions
 * last.
 */
class StopWatch implements IWorkflowComponent {

    /**
     * The start time stamp.
     */
    Long start

    /**
     * Whether we should stop on next execution or not.
     */
    Boolean shouldStop = false

    /**
     * Invokes the workflow component.
     * 
     * @param ctx
     *            The given {@link IWorkflowContext} instance.
     */
    override invoke(IWorkflowContext ctx) {
        // Nothing to do here yet
    }

    /**
     * Performs actions before the invocation.
     */
    override preInvoke() {
        start = System.currentTimeMillis
    }

    /**
     * Performs actions after the invocation.
     */
    override postInvoke() {
        if (shouldStop) {
            val elapsed = System.currentTimeMillis - this.start
            println('Time elapsed: ' + elapsed + ' ms') //$NON-NLS-1$ //$NON-NLS-2$
        }
        shouldStop = true
    }
}
