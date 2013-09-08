package org.zikula.modulestudio.generator.workflow.components

import org.eclipse.emf.mwe2.runtime.workflow.IWorkflowComponent
import org.eclipse.emf.mwe2.runtime.workflow.IWorkflowContext

/**
 * Workflow component class for logging some messages.
 */
class Logger implements IWorkflowComponent {

    /**
     * Currently stored message.
     */
    @Property
    String message = 'Hello World!' //$NON-NLS-1$

    /**
     * Invokes the workflow component.
     * 
     * @param ctx
     *            The given {@link IWorkflowContext} instance.
     */
    override invoke(IWorkflowContext ctx) {
        println(getMessage)
    }

    /**
     * Performs actions before the invocation.
     */
    override preInvoke() {
        // Nothing to do here yet
    }

    /**
     * Performs actions after the invocation.
     */
    override postInvoke() {
        // Nothing to do here yet
    }
}
