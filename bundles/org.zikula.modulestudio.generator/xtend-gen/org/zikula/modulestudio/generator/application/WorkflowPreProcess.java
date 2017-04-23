package org.zikula.modulestudio.generator.application;

import java.io.File;
import java.util.List;
import org.eclipse.xtext.xbase.lib.Conversions;
import org.zikula.modulestudio.generator.application.WorkflowSettings;
import org.zikula.modulestudio.generator.exceptions.DirectoryNotEmptyException;
import org.zikula.modulestudio.generator.exceptions.ExceptionBase;

/**
 * Pre processing providing convenience methods for single cartridges.
 */
@SuppressWarnings("all")
public class WorkflowPreProcess {
  private WorkflowSettings settings;
  
  public void run(final WorkflowSettings settings) throws ExceptionBase {
    this.settings = settings;
    this.directoryTasks();
  }
  
  private void directoryTasks() throws DirectoryNotEmptyException {
    final File[] existingFiles = this.settings.getOutputDir().listFiles();
    boolean _isEmpty = ((List<File>)Conversions.doWrapArray(existingFiles)).isEmpty();
    boolean _not = (!_isEmpty);
    if (_not) {
      throw new DirectoryNotEmptyException();
    }
  }
  
  public Boolean emptyDestinationDirectory() {
    return this.emptyDir(this.settings.getOutputDir());
  }
  
  private Boolean emptyDir(final File dir) {
    boolean _xblockexpression = false;
    {
      boolean hasErrors = false;
      final File[] files = dir.listFiles();
      if ((null == files)) {
        return Boolean.valueOf(hasErrors);
      }
      for (final File file : files) {
        {
          boolean _isDirectory = file.isDirectory();
          if (_isDirectory) {
            this.emptyDir(file);
          }
          boolean _delete = file.delete();
          boolean _not = (!_delete);
          if (_not) {
            hasErrors = true;
          }
        }
      }
      _xblockexpression = hasErrors;
    }
    return Boolean.valueOf(_xblockexpression);
  }
}
