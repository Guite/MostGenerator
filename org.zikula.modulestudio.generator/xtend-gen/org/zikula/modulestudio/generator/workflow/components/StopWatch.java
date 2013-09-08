package org.zikula.modulestudio.generator.workflow.components;

import org.eclipse.emf.mwe2.runtime.workflow.IWorkflowComponent;
import org.eclipse.emf.mwe2.runtime.workflow.IWorkflowContext;
import org.eclipse.xtext.xbase.lib.InputOutput;

/**
 * Workflow component class for a stop watch observing how long certain actions
 * last.
 */
@SuppressWarnings("all")
public class StopWatch implements IWorkflowComponent {
  /**
   * The start time stamp.
   */
  private Long start;
  
  /**
   * Whether we should stop on next execution or not.
   */
  private Boolean shouldStop = Boolean.valueOf(false);
  
  /**
   * Invokes the workflow component.
   * 
   * @param ctx
   *            The given {@link IWorkflowContext} instance.
   */
  public void invoke(final IWorkflowContext ctx) {
  }
  
  /**
   * Performs actions before the invocation.
   */
  public void preInvoke() {
    long _currentTimeMillis = System.currentTimeMillis();
    this.start = Long.valueOf(_currentTimeMillis);
  }
  
  /**
   * Performs actions after the invocation.
   */
  public void postInvoke() {
    if ((this.shouldStop).booleanValue()) {
      long _currentTimeMillis = System.currentTimeMillis();
      final long elapsed = (_currentTimeMillis - (this.start).longValue());
      String _plus = ("Time elapsed: " + Long.valueOf(elapsed));
      String _plus_1 = (_plus + " ms");
      InputOutput.<String>println(_plus_1);
    }
    this.shouldStop = Boolean.valueOf(true);
  }
}
