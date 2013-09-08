package org.zikula.modulestudio.generator.workflow.components

import org.eclipse.emf.mwe2.runtime.workflow.IWorkflowComponent

/**
 * Common super class for components working with a model.
 */
public abstract class WorkflowComponentWithSlot implements IWorkflowComponent {

    /**
     * Name of used slot.
     */
    @Property
    String slot = 'model' //$NON-NLS-1$

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
