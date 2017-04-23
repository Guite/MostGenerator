package org.zikula.modulestudio.generator.application;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.URL;
import org.eclipse.core.runtime.FileLocator;
import org.eclipse.core.runtime.IStatus;
import org.eclipse.emf.mwe.utils.FileCopy;
import org.eclipse.xtext.xbase.lib.Exceptions;
import org.eclipse.xtext.xbase.lib.ObjectExtensions;
import org.eclipse.xtext.xbase.lib.Procedures.Procedure1;
import org.zikula.modulestudio.generator.application.ImageCreator;
import org.zikula.modulestudio.generator.application.ModuleStudioGeneratorActivator;
import org.zikula.modulestudio.generator.application.WorkflowSettings;
import org.zikula.modulestudio.generator.workflow.components.ModelFileCopier;

/**
 * Workflow post processing for copying model files and creating custom images.
 */
@SuppressWarnings("all")
public class WorkflowPostProcess {
  /**
   * The workflow settings.
   */
  private WorkflowSettings settings;
  
  /**
   * Constructor.
   * 
   * @param settings The workflow settings
   */
  public WorkflowPostProcess(final WorkflowSettings settings) {
    this.settings = settings;
  }
  
  /**
   * Executes the workflow.
   */
  public void run() {
    this.copyModelFiles();
    final ImageCreator imageCreator = new ImageCreator();
    try {
      imageCreator.generate(this.settings);
    } catch (final Throwable _t) {
      if (_t instanceof Exception) {
        final Exception e = (Exception)_t;
        ModuleStudioGeneratorActivator.log(IStatus.ERROR, e.getMessage(), e);
        this.copyAdminImage();
      } else {
        throw Exceptions.sneakyThrow(_t);
      }
    }
  }
  
  /**
   * Copies the model files into the output folder.
   */
  private void copyModelFiles() {
    String _modelDestinationPath = this.settings.getModelDestinationPath();
    boolean _tripleEquals = (null == _modelDestinationPath);
    if (_tripleEquals) {
      return;
    }
    final String srcPath = this.settings.getModelPath().replaceFirst("file:", "");
    final String modelFileName = new File(srcPath).getName();
    ModelFileCopier _modelFileCopier = new ModelFileCopier();
    final Procedure1<ModelFileCopier> _function = (ModelFileCopier it) -> {
      it.setSourceModelFile(srcPath);
      String _modelDestinationPath_1 = this.settings.getModelDestinationPath();
      String _plus = (_modelDestinationPath_1 + modelFileName);
      it.setTargetModelFile(_plus);
      it.setSourceModelFileEnriched(srcPath.replace(".mostapp", "_enriched.mostapp"));
      String _modelDestinationPath_2 = this.settings.getModelDestinationPath();
      String _replace = modelFileName.replace(".mostapp", "_enriched.mostapp");
      String _plus_1 = (_modelDestinationPath_2 + _replace);
      it.setTargetModelFileEnriched(_plus_1);
    };
    final ModelFileCopier copier = ObjectExtensions.<ModelFileCopier>operator_doubleArrow(_modelFileCopier, _function);
    copier.invoke();
  }
  
  /**
   * Copies the admin image for the generated application.
   */
  private void copyAdminImage() {
    final File targetFolder = this.settings.getPathToModuleImageAssets();
    boolean _exists = targetFolder.exists();
    boolean _not = (!_exists);
    if (_not) {
      return;
    }
    String _plus = (targetFolder + File.separator);
    final String targetFilePath = (_plus + "admin.png");
    Boolean _isStandalone = this.settings.getIsStandalone();
    boolean _not_1 = (!(_isStandalone).booleanValue());
    if (_not_1) {
      final URL url = this.settings.getAdminImageUrl();
      if ((null == url)) {
        return;
      }
      try {
        final URL sourceImageUrl = FileLocator.toFileURL(url);
        String _path = sourceImageUrl.getPath();
        final File sourceImageFile = new File(_path);
        final FileCopy fileCopy = new FileCopy();
        fileCopy.setSourceFile(sourceImageFile.getAbsolutePath());
        fileCopy.setTargetFile(targetFilePath);
        fileCopy.invoke(null);
      } catch (final Throwable _t) {
        if (_t instanceof IOException) {
          final IOException e = (IOException)_t;
          ModuleStudioGeneratorActivator.log(IStatus.ERROR, e.getMessage(), e);
        } else {
          throw Exceptions.sneakyThrow(_t);
        }
      }
    } else {
      final InputStream inputStream = this.getClass().getResourceAsStream(this.settings.getAdminImageInputPath());
      if ((null == inputStream)) {
        return;
      }
      OutputStream outputStream = null;
      int readBytes = 0;
      final byte[] buffer = new byte[4096];
      try {
        File _file = new File(targetFilePath);
        FileOutputStream _fileOutputStream = new FileOutputStream(_file);
        outputStream = _fileOutputStream;
        while (((readBytes = inputStream.read(buffer)) != (-1))) {
          outputStream.write(buffer, 0, readBytes);
        }
        outputStream.close();
      } catch (final Throwable _t_1) {
        if (_t_1 instanceof IOException) {
          final IOException e1 = (IOException)_t_1;
          e1.printStackTrace();
        } else {
          throw Exceptions.sneakyThrow(_t_1);
        }
      }
    }
  }
}
