package org.zikula.modulestudio.generator.workflow.components;

import java.io.File;
import org.eclipse.emf.mwe2.runtime.workflow.IWorkflowComponent;
import org.eclipse.emf.mwe2.runtime.workflow.IWorkflowContext;
import org.eclipse.xtend.lib.annotations.Accessors;
import org.eclipse.xtext.xbase.lib.Pure;

/**
 * Workflow component class for cleaning a certain directory.
 */
@SuppressWarnings("all")
public class DirectoryCreator implements IWorkflowComponent {
  /**
   * The treated directory.
   */
  @Accessors
  private String directory = "";
  
  /**
   * Invokes the workflow component.
   * 
   * @param ctx
   *            The given {@link IWorkflowContext} instance.
   */
  @Override
  public void invoke(final IWorkflowContext ctx) {
    boolean _isEmpty = this.directory.isEmpty();
    boolean _not = (!_isEmpty);
    if (_not) {
      final File dirHandle = new File(this.directory);
      if (((!dirHandle.exists()) && (!dirHandle.mkdirs()))) {
        throw new IllegalStateException((("Error during creation of directory \"" + this.directory) + "\"."));
      }
    }
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
  public String getDirectory() {
    return this.directory;
  }
  
  public void setDirectory(final String directory) {
    this.directory = directory;
  }
}
