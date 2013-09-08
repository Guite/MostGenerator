package org.zikula.modulestudio.generator.workflow.components;

import org.eclipse.emf.mwe2.runtime.workflow.IWorkflowComponent;

/**
 * Common super class for components working with a model.
 */
@SuppressWarnings("all")
public abstract class WorkflowComponentWithSlot implements IWorkflowComponent {
  /**
   * Name of used slot.
   */
  private String _slot = "model";
  
  /**
   * Name of used slot.
   */
  public String getSlot() {
    return this._slot;
  }
  
  /**
   * Name of used slot.
   */
  public void setSlot(final String slot) {
    this._slot = slot;
  }
  
  /**
   * Performs actions before the invocation.
   */
  public void preInvoke() {
  }
  
  /**
   * Performs actions after the invocation.
   */
  public void postInvoke() {
  }
}
