package org.zikula.modulestudio.generator.application;

import java.io.File;
import java.util.ArrayList;
import java.util.List;
import org.eclipse.xtext.xbase.lib.Conversions;
import org.zikula.modulestudio.generator.application.WorkflowSettings;
import org.zikula.modulestudio.generator.exceptions.DirectoryNotEmptyException;
import org.zikula.modulestudio.generator.exceptions.ExceptionBase;
import org.zikula.modulestudio.generator.exceptions.NoCartridgesSelected;

/**
 * Pre processing providing convenience methods for single cartridges.
 */
@SuppressWarnings("all")
public class WorkflowPreProcess {
  private WorkflowSettings settings;
  
  public void run(final WorkflowSettings settings) throws ExceptionBase {
    this.settings = settings;
    this.cartridgeTasks();
    this.directoryTasks();
  }
  
  private void cartridgeTasks() throws NoCartridgesSelected {
    ArrayList<Object> _selectedCartridges = this.settings.getSelectedCartridges();
    int _size = _selectedCartridges.size();
    boolean _equals = (_size == 0);
    if (_equals) {
      NoCartridgesSelected _noCartridgesSelected = new NoCartridgesSelected();
      throw _noCartridgesSelected;
    }
  }
  
  private void directoryTasks() throws DirectoryNotEmptyException {
    File _outputDir = this.settings.getOutputDir();
    final File[] existingFiles = _outputDir.listFiles();
    int _size = ((List<File>)Conversions.doWrapArray(existingFiles)).size();
    boolean _greaterThan = (_size > 0);
    if (_greaterThan) {
      DirectoryNotEmptyException _directoryNotEmptyException = new DirectoryNotEmptyException();
      throw _directoryNotEmptyException;
    }
  }
  
  public void emptyDestinationDirectory() {
    File _outputDir = this.settings.getOutputDir();
    this.emptyDir(_outputDir);
  }
  
  private void emptyDir(final File dir) {
    final File[] files = dir.listFiles();
    boolean _tripleNotEquals = (files != null);
    if (_tripleNotEquals) {
      for (final File file : files) {
        {
          boolean _isDirectory = file.isDirectory();
          if (_isDirectory) {
            this.emptyDir(file);
          }
          file.delete();
        }
      }
    }
  }
}
