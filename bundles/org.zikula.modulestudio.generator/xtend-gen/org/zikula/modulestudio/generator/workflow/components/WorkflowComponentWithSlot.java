package org.zikula.modulestudio.generator.workflow.components;

import org.eclipse.emf.mwe2.runtime.workflow.IWorkflowComponent;
import org.eclipse.xtend.lib.annotations.Accessors;
import org.eclipse.xtext.xbase.lib.Pure;

/**
 * Common super class for components working with a model.
 */
@SuppressWarnings("all")
public abstract class WorkflowComponentWithSlot implements IWorkflowComponent {
  /**
   * Name of used slot.
   */
  @Accessors
  private String slot = "model";
  
  /**
   * Performs actions before the invocation.
   */
  @Override
  public void preInvoke() {
  }
  
  /**
   * Performs actions after the invocation.
   */
  @Override
  public void postInvoke() {
  }
  
  @Pure
  public String getSlot() {
    return this.slot;
  }
  
  public void setSlot(final String slot) {
    this.slot = slot;
  }
}
