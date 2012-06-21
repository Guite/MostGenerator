package org.zikula.modulestudio.generator.workflow.components;

import org.eclipse.emf.mwe2.runtime.workflow.IWorkflowComponent;
import org.eclipse.emf.mwe2.runtime.workflow.IWorkflowContext;

/**
 * Workflow component class for a stop watch observing how long certain actions
 * last.
 */
public class StopWatch implements IWorkflowComponent {

    /**
     * The start time stamp.
     */
    private long start;

    /**
     * Whether we should stop on next execution or not.
     */
    private boolean shouldStop = false;

    /**
     * Invokes the workflow component.
     * 
     * @param ctx
     *            The given {@link IWorkflowContext} instance.
     */
    @Override
    public void invoke(IWorkflowContext ctx) {
        // Nothing to do here yet
    }

    /**
     * Performs actions before the invocation.
     */
    @Override
    public void preInvoke() {
        this.start = System.currentTimeMillis();
    }

    /**
     * Performs actions after the invocation.
     */
    @Override
    public void postInvoke() {
        if (this.shouldStop) {
            final long elapsed = System.currentTimeMillis() - this.start;
            System.out.println("Time elapsed: " + elapsed + " ms"); //$NON-NLS-1$ //$NON-NLS-2$
        }
        this.shouldStop = true;
    }
}
