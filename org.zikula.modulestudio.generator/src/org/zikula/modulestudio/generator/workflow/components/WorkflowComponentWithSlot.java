package org.zikula.modulestudio.generator.workflow.components;

import org.eclipse.emf.mwe2.runtime.workflow.IWorkflowComponent;

/**
 * Common super class for components working with a model.
 */
public abstract class WorkflowComponentWithSlot implements IWorkflowComponent {
    /**
     * Name of used slot.
     */
    private String slot = "model"; //$NON-NLS-1$

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
     * Returns the slot.
     * 
     * @return The slot string.
     */
    public String getSlot() {
        return this.slot;
    }

    /**
     * Sets the slot.
     * 
     * @param slot
     *            The slot string.
     */
    public void setSlot(String slot) {
        this.slot = slot;
    }
}
