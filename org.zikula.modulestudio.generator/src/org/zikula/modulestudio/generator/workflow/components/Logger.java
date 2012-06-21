package org.zikula.modulestudio.generator.workflow.components;

import org.eclipse.emf.mwe2.runtime.workflow.IWorkflowComponent;
import org.eclipse.emf.mwe2.runtime.workflow.IWorkflowContext;

/**
 * Workflow component class for logging some messages.
 */
public class Logger implements IWorkflowComponent {

    /**
     * Currently stored message.
     */
    private String message = "Hello World!"; //$NON-NLS-1$

    /**
     * Invokes the workflow component.
     * 
     * @param ctx
     *            The given {@link IWorkflowContext} instance.
     */
    @Override
    public void invoke(IWorkflowContext ctx) {
        System.out.println(getMessage());
    }

    /**
     * Performs actions before the invocation.
     */
    @Override
    public void preInvoke() {
        // Nothing to do here yet
    }

    /**
     * Performs actions after the invocation.
     */
    @Override
    public void postInvoke() {
        // Nothing to do here yet
    }

    /**
     * Sets the current message.
     * 
     * @param msg
     *            The given message string.
     */
    public void setMessage(String msg) {
        this.message = msg;
    }

    /**
     * Returns the current message.
     * 
     * @return Current message string.
     */
    public String getMessage() {
        return this.message;
    }
}
