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
   *            The given {@link org.eclipse.emf.mwe2.runtime.workflow.IWorkflowContext} instance.
   */
  @Override
  public void invoke(final IWorkflowContext ctx) {
  }
  
  /**
   * Performs actions before the invocation.
   */
  @Override
  public void preInvoke() {
    this.start = Long.valueOf(System.currentTimeMillis());
  }
  
  /**
   * Performs actions after the invocation.
   */
  @Override
  public void postInvoke() {
    if ((this.shouldStop).booleanValue()) {
      long _currentTimeMillis = System.currentTimeMillis();
      final long elapsed = (_currentTimeMillis - (this.start).longValue());
      InputOutput.<String>println((("Time elapsed: " + Long.valueOf(elapsed)) + " ms"));
    }
    this.shouldStop = Boolean.valueOf(true);
  }
}
