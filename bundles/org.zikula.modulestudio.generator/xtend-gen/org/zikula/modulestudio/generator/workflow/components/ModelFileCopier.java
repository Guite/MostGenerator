package org.zikula.modulestudio.generator.workflow.components;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.channels.FileChannel;
import org.eclipse.core.runtime.IStatus;
import org.eclipse.emf.mwe2.runtime.workflow.IWorkflowComponent;
import org.eclipse.emf.mwe2.runtime.workflow.IWorkflowContext;
import org.eclipse.xtend.lib.annotations.Accessors;
import org.eclipse.xtext.xbase.lib.Exceptions;
import org.eclipse.xtext.xbase.lib.InputOutput;
import org.eclipse.xtext.xbase.lib.Pure;
import org.zikula.modulestudio.generator.application.ModuleStudioGeneratorActivator;

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
  @Accessors
  private String sourceModelFile = "";
  
  /**
   * Path to the enriched source application model file.
   */
  @Accessors
  private String sourceModelFileEnriched = "";
  
  /**
   * Path to the target application model file.
   */
  @Accessors
  private String targetModelFile = "";
  
  /**
   * Path to the enriched target application model file.
   */
  @Accessors
  private String targetModelFileEnriched = "";
  
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
  @Override
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
    this.copy(this.sourceModelFile, this.targetModelFile);
    this.copy(this.sourceModelFileEnriched, this.targetModelFileEnriched);
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
    if ((sourceFile.isEmpty() || targetFile.isEmpty())) {
      return;
    }
    try {
      final File source = new File(sourceFile);
      final File target = new File(targetFile);
      boolean _exists = source.exists();
      boolean _not = (!_exists);
      if (_not) {
        return;
      }
      boolean _exists_1 = target.exists();
      boolean _not_1 = (!_exists_1);
      if (_not_1) {
        if (((!target.getParentFile().exists()) && (!target.getParentFile().mkdirs()))) {
          return;
        }
        boolean _createNewFile = target.createNewFile();
        boolean _not_2 = (!_createNewFile);
        if (_not_2) {
          return;
        }
      }
      FileChannel sourceChannel = null;
      FileChannel destinationChannel = null;
      try {
        final FileInputStream inputStream = new FileInputStream(source);
        final FileOutputStream outputStream = new FileOutputStream(target);
        sourceChannel = inputStream.getChannel();
        destinationChannel = outputStream.getChannel();
        destinationChannel.transferFrom(sourceChannel, 0, sourceChannel.size());
        sourceChannel.close();
        destinationChannel.close();
        inputStream.close();
        outputStream.close();
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
        final IOException e = (IOException)_t;
        ModuleStudioGeneratorActivator.log(IStatus.ERROR, e.getMessage(), e);
      } else {
        throw Exceptions.sneakyThrow(_t);
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
    return this.enabled = Boolean.valueOf(enabled);
  }
  
  @Pure
  public String getSourceModelFile() {
    return this.sourceModelFile;
  }
  
  public void setSourceModelFile(final String sourceModelFile) {
    this.sourceModelFile = sourceModelFile;
  }
  
  @Pure
  public String getSourceModelFileEnriched() {
    return this.sourceModelFileEnriched;
  }
  
  public void setSourceModelFileEnriched(final String sourceModelFileEnriched) {
    this.sourceModelFileEnriched = sourceModelFileEnriched;
  }
  
  @Pure
  public String getTargetModelFile() {
    return this.targetModelFile;
  }
  
  public void setTargetModelFile(final String targetModelFile) {
    this.targetModelFile = targetModelFile;
  }
  
  @Pure
  public String getTargetModelFileEnriched() {
    return this.targetModelFileEnriched;
  }
  
  public void setTargetModelFileEnriched(final String targetModelFileEnriched) {
    this.targetModelFileEnriched = targetModelFileEnriched;
  }
}
