package org.zikula.modulestudio.generator.workflow.components;

import java.io.File;
import org.eclipse.emf.mwe2.runtime.workflow.IWorkflowComponent;
import org.eclipse.emf.mwe2.runtime.workflow.IWorkflowContext;

/**
 * Workflow component class for cleaning a certain directory.
 */
@SuppressWarnings("all")
public class DirectoryCreator implements IWorkflowComponent {
  /**
   * The treated directory.
   */
  private String _directory = "";
  
  /**
   * The treated directory.
   */
  public String getDirectory() {
    return this._directory;
  }
  
  /**
   * The treated directory.
   */
  public void setDirectory(final String directory) {
    this._directory = directory;
  }
  
  /**
   * Invokes the workflow component.
   * 
   * @param ctx
   *            The given {@link IWorkflowContext} instance.
   */
  public void invoke(final IWorkflowContext ctx) {
    String _directory = this.getDirectory();
    boolean _isEmpty = _directory.isEmpty();
    boolean _not = (!_isEmpty);
    if (_not) {
      String _directory_1 = this.getDirectory();
      File _file = new File(_directory_1);
      final File dirHandle = _file;
      boolean _mkdirs = dirHandle.mkdirs();
      boolean _not_1 = (!_mkdirs);
      if (_not_1) {
        System.err.println("Error during directory creation.");
        IllegalStateException _illegalStateException = new IllegalStateException("Abort the workflow");
        throw _illegalStateException;
      }
    }
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
