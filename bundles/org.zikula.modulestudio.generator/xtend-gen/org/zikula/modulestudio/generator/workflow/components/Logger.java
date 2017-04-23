package org.zikula.modulestudio.generator.workflow.components;

import org.eclipse.emf.mwe2.runtime.workflow.IWorkflowComponent;
import org.eclipse.emf.mwe2.runtime.workflow.IWorkflowContext;
import org.eclipse.xtend.lib.annotations.Accessors;
import org.eclipse.xtext.xbase.lib.InputOutput;
import org.eclipse.xtext.xbase.lib.Pure;

/**
 * Workflow component class for logging some messages.
 */
@SuppressWarnings("all")
public class Logger implements IWorkflowComponent {
  /**
   * Currently stored message.
   */
  @Accessors
  private String message = "Hello World!";
  
  /**
   * Invokes the workflow component.
   * 
   * @param ctx
   *            The given {@link IWorkflowContext} instance.
   */
  @Override
  public void invoke(final IWorkflowContext ctx) {
    InputOutput.<String>println(this.getMessage());
  }
  
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
  public String getMessage() {
    return this.message;
  }
  
  public void setMessage(final String message) {
    this.message = message;
  }
}
