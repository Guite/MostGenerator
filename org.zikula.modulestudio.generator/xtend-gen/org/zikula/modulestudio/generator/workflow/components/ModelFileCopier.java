package org.zikula.modulestudio.generator.workflow.components;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.channels.FileChannel;
import org.eclipse.emf.mwe2.runtime.workflow.IWorkflowComponent;
import org.eclipse.emf.mwe2.runtime.workflow.IWorkflowContext;
import org.eclipse.xtext.xbase.lib.Exceptions;
import org.eclipse.xtext.xbase.lib.InputOutput;

/**
 * Workflow component class for copying model files into the output folder.
 */
@SuppressWarnings("all")
public class ModelFileCopier implements IWorkflowComponent {
  /**
   * Whether copying should be executed or not.
   */
  private Boolean enabled = Boolean.valueOf(true);
  
  /**
   * Path to the source application model file.
   */
  private String _sourceModelFile = "";
  
  /**
   * Path to the source application model file.
   */
  public String getSourceModelFile() {
    return this._sourceModelFile;
  }
  
  /**
   * Path to the source application model file.
   */
  public void setSourceModelFile(final String sourceModelFile) {
    this._sourceModelFile = sourceModelFile;
  }
  
  /**
   * Path to the enriched source application model file.
   */
  private String _sourceModelFileEnriched = "";
  
  /**
   * Path to the enriched source application model file.
   */
  public String getSourceModelFileEnriched() {
    return this._sourceModelFileEnriched;
  }
  
  /**
   * Path to the enriched source application model file.
   */
  public void setSourceModelFileEnriched(final String sourceModelFileEnriched) {
    this._sourceModelFileEnriched = sourceModelFileEnriched;
  }
  
  /**
   * Path to the source diagram model file.
   */
  private String _sourceDiagramFile = "";
  
  /**
   * Path to the source diagram model file.
   */
  public String getSourceDiagramFile() {
    return this._sourceDiagramFile;
  }
  
  /**
   * Path to the source diagram model file.
   */
  public void setSourceDiagramFile(final String sourceDiagramFile) {
    this._sourceDiagramFile = sourceDiagramFile;
  }
  
  /**
   * Path to the target application model file.
   */
  private String _targetModelFile = "";
  
  /**
   * Path to the target application model file.
   */
  public String getTargetModelFile() {
    return this._targetModelFile;
  }
  
  /**
   * Path to the target application model file.
   */
  public void setTargetModelFile(final String targetModelFile) {
    this._targetModelFile = targetModelFile;
  }
  
  /**
   * Path to the enriched target application model file.
   */
  private String _targetModelFileEnriched = "";
  
  /**
   * Path to the enriched target application model file.
   */
  public String getTargetModelFileEnriched() {
    return this._targetModelFileEnriched;
  }
  
  /**
   * Path to the enriched target application model file.
   */
  public void setTargetModelFileEnriched(final String targetModelFileEnriched) {
    this._targetModelFileEnriched = targetModelFileEnriched;
  }
  
  /**
   * Path to the target diagram model file.
   */
  private String _targetDiagramFile = "";
  
  /**
   * Path to the target diagram model file.
   */
  public String getTargetDiagramFile() {
    return this._targetDiagramFile;
  }
  
  /**
   * Path to the target diagram model file.
   */
  public void setTargetDiagramFile(final String targetDiagramFile) {
    this._targetDiagramFile = targetDiagramFile;
  }
  
  /**
   * Invokes the workflow component from the outside.
   */
  public void invoke() {
    this.invokeInternal();
  }
  
  /**
   * Invokes the workflow component from a workflow.
   * 
   * @param ctx
   *            The given {@link IWorkflowContext} instance.
   */
  public void invoke(final IWorkflowContext ctx) {
    this.invokeInternal();
  }
  
  /**
   * Performs the actual process.
   */
  protected void invokeInternal() {
    Boolean _isEnabled = this.isEnabled();
    boolean _not = (!(_isEnabled).booleanValue());
    if (_not) {
      InputOutput.<String>println("Skipping model file copier.");
      return;
    }
    InputOutput.<String>println("Running model file copier.");
    String _sourceModelFile = this.getSourceModelFile();
    String _targetModelFile = this.getTargetModelFile();
    this.copy(_sourceModelFile, _targetModelFile);
    String _sourceModelFileEnriched = this.getSourceModelFileEnriched();
    String _targetModelFileEnriched = this.getTargetModelFileEnriched();
    this.copy(_sourceModelFileEnriched, _targetModelFileEnriched);
    String _sourceDiagramFile = this.getSourceDiagramFile();
    String _targetDiagramFile = this.getTargetDiagramFile();
    this.copy(_sourceDiagramFile, _targetDiagramFile);
  }
  
  /**
   * Copies one certain file to a given target file.
   * 
   * @param sourceFile
   *            The source file path.
   * @param targetFile
   *            The target file path.
   */
  protected void copy(final String sourceFile, final String targetFile) {
    boolean _or = false;
    boolean _isEmpty = sourceFile.isEmpty();
    if (_isEmpty) {
      _or = true;
    } else {
      boolean _isEmpty_1 = targetFile.isEmpty();
      _or = (_isEmpty || _isEmpty_1);
    }
    if (_or) {
      return;
    }
    try {
      File _file = new File(sourceFile);
      final File source = _file;
      File _file_1 = new File(targetFile);
      final File target = _file_1;
      boolean _exists = source.exists();
      boolean _not = (!_exists);
      if (_not) {
        return;
      }
      boolean _exists_1 = target.exists();
      boolean _not_1 = (!_exists_1);
      if (_not_1) {
        boolean _and = false;
        File _parentFile = target.getParentFile();
        boolean _exists_2 = _parentFile.exists();
        boolean _not_2 = (!_exists_2);
        if (!_not_2) {
          _and = false;
        } else {
          File _parentFile_1 = target.getParentFile();
          boolean _mkdirs = _parentFile_1.mkdirs();
          boolean _not_3 = (!_mkdirs);
          _and = (_not_2 && _not_3);
        }
        if (_and) {
          return;
        }
        target.createNewFile();
      }
      FileChannel sourceChannel = null;
      FileChannel destinationChannel = null;
      try {
        FileInputStream _fileInputStream = new FileInputStream(source);
        FileChannel _channel = _fileInputStream.getChannel();
        sourceChannel = _channel;
        FileOutputStream _fileOutputStream = new FileOutputStream(target);
        FileChannel _channel_1 = _fileOutputStream.getChannel();
        destinationChannel = _channel_1;
        long _size = sourceChannel.size();
        destinationChannel.transferFrom(sourceChannel, 0, _size);
        sourceChannel.close();
        destinationChannel.close();
      } finally {
        if (sourceChannel!=null) {
          sourceChannel.close();
        }
        if (destinationChannel!=null) {
          destinationChannel.close();
        }
      }
    } catch (final Throwable _t) {
      if (_t instanceof IOException) {
        final IOException x = (IOException)_t;
      } else {
        throw Exceptions.sneakyThrow(_t);
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
  
  /**
   * Returns the enabled flag.
   * 
   * @return The enabled flag.
   */
  public Boolean isEnabled() {
    return this.enabled;
  }
  
  /**
   * Sets the enabled flag.
   * 
   * @param enabled
   *            The enabled flag.
   */
  public Boolean setEnabled(final String enabled) {
    Boolean _valueOf = Boolean.valueOf(enabled);
    Boolean _enabled = this.enabled = _valueOf;
    return _enabled;
  }
}
