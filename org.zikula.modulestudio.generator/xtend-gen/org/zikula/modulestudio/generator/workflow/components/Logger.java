package org.zikula.modulestudio.generator.workflow.components;

import org.eclipse.emf.mwe2.runtime.workflow.IWorkflowComponent;
import org.eclipse.emf.mwe2.runtime.workflow.IWorkflowContext;
import org.eclipse.xtext.xbase.lib.InputOutput;

/**
 * Workflow component class for logging some messages.
 */
@SuppressWarnings("all")
public class Logger implements IWorkflowComponent {
  /**
   * Currently stored message.
   */
  private String _message = "Hello World!";
  
  /**
   * Currently stored message.
   */
  public String getMessage() {
    return this._message;
  }
  
  /**
   * Currently stored message.
   */
  public void setMessage(final String message) {
    this._message = message;
  }
  
  /**
   * Invokes the workflow component.
   * 
   * @param ctx
   *            The given {@link IWorkflowContext} instance.
   */
  public void invoke(final IWorkflowContext ctx) {
    String _message = this.getMessage();
    InputOutput.<String>println(_message);
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
