package org.zikula.modulestudio.generator.workflow.components

import org.eclipse.emf.mwe2.runtime.workflow.IWorkflowComponent
import org.eclipse.xtend.lib.annotations.Accessors

/**
 * Common super class for components working with a model.
 */
abstract class WorkflowComponentWithSlot implements IWorkflowComponent {

    /**
     * Name of used slot.
     */
    @Accessors
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
