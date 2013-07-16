package org.zikula.modulestudio.generator.application;

import java.io.File;
import java.io.IOException;
import java.net.URI;
import java.net.URL;
import java.util.ArrayList;
import java.util.List;
import org.eclipse.core.runtime.FileLocator;
import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.core.runtime.Path;
import org.eclipse.core.runtime.Platform;
import org.eclipse.emf.mwe.utils.FileCopy;
import org.eclipse.xtext.xbase.lib.Conversions;
import org.eclipse.xtext.xbase.lib.Exceptions;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.osgi.framework.Bundle;
import org.zikula.modulestudio.generator.application.Activator;
import org.zikula.modulestudio.generator.application.WorkflowSettings;
import org.zikula.modulestudio.generator.cartridges.reporting.ReportingFacade;
import org.zikula.modulestudio.generator.workflow.components.ModelFileCopier;

/**
 * Workflow post processing for copying the admin image (zclassic) and
 * exporting the report files (reporting).
 */
@SuppressWarnings("all")
public class WorkflowPostProcess {
  private WorkflowSettings settings;
  
  public WorkflowPostProcess(final WorkflowSettings settings) {
    this.settings = settings;
  }
  
  /**
   * Executes the workflow.
   */
  public void run() {
    this.copyModelFiles();
    ArrayList<Object> _selectedCartridges = this.settings.getSelectedCartridges();
    boolean _contains = _selectedCartridges.contains("zclassic");
    if (_contains) {
      this.copyAdminImage();
    }
    ArrayList<Object> _selectedCartridges_1 = this.settings.getSelectedCartridges();
    boolean _contains_1 = _selectedCartridges_1.contains("reporting");
    if (_contains_1) {
      this.exportBirtReports();
    }
  }
  
  /**
   * Copies the model files into the output folder.
   */
  private void copyModelFiles() {
    String _modelPath = this.settings.getModelPath();
    final String srcPath = _modelPath.replaceFirst("file:", "");
    File _file = new File(srcPath);
    final String modelFileName = _file.getName();
    ModelFileCopier _modelFileCopier = new ModelFileCopier();
    final ModelFileCopier copier = _modelFileCopier;
    copier.setSourceModelFile(srcPath);
    String _outputPath = this.settings.getOutputPath();
    String _plus = (_outputPath + "/model/");
    String _plus_1 = (_plus + modelFileName);
    copier.setTargetModelFile(_plus_1);
    String _replace = srcPath.replace(".mostapp", "_enriched.mostapp");
    copier.setSourceModelFileEnriched(_replace);
    String _outputPath_1 = this.settings.getOutputPath();
    String _plus_2 = (_outputPath_1 + "/model/");
    String _replace_1 = modelFileName.replace(".mostapp", "_enriched.mostapp");
    String _plus_3 = (_plus_2 + _replace_1);
    copier.setTargetModelFileEnriched(_plus_3);
    String _replace_2 = srcPath.replace(".mostapp", ".mostdiagram");
    copier.setSourceDiagramFile(_replace_2);
    String _outputPath_2 = this.settings.getOutputPath();
    String _plus_4 = (_outputPath_2 + "/model/");
    String _replace_3 = modelFileName.replace(".mostapp", ".mostdiagram");
    String _plus_5 = (_plus_4 + _replace_3);
    copier.setTargetDiagramFile(_plus_5);
    copier.invoke();
  }
  
  /**
   * Copies the admin image for zclassic cartridge.
   */
  private void copyAdminImage() {
    FileCopy _fileCopy = new FileCopy();
    final FileCopy fileCopy = _fileCopy;
    final Bundle bundle = Platform.getBundle(Activator.PLUGIN_ID);
    Path _path = new Path("/src/resources/images/MOST_48.png");
    URL[] resources = FileLocator.findEntries(bundle, _path);
    Path _path_1 = new Path("/resources/images/MOST_48.png");
    final URL[] resourcesExported = FileLocator.findEntries(bundle, _path_1);
    final URL[] _converted_resources = (URL[])resources;
    int _size = ((List<URL>)Conversions.doWrapArray(_converted_resources)).size();
    boolean _equals = (_size == 0);
    if (_equals) {
      resources = resourcesExported;
    }
    final URL[] _converted_resources_1 = (URL[])resources;
    int _size_1 = ((List<URL>)Conversions.doWrapArray(_converted_resources_1)).size();
    boolean _greaterThan = (_size_1 > 0);
    if (_greaterThan) {
      try {
        final URL[] _converted_resources_2 = (URL[])resources;
        final URL url = IterableExtensions.<URL>head(((Iterable<URL>)Conversions.doWrapArray(_converted_resources_2)));
        final URL fileUrl = FileLocator.toFileURL(url);
        String _path_2 = fileUrl.getPath();
        File _file = new File(_path_2);
        final File file = _file;
        String _absolutePath = file.getAbsolutePath();
        fileCopy.setSourceFile(_absolutePath);
        String _outputPath = this.settings.getOutputPath();
        String _plus = (_outputPath + "/zclassic/");
        String _appName = this.settings.getAppName();
        String _plus_1 = (_plus + _appName);
        final String targetBasePath = (_plus_1 + "/");
        String imageFolder = "Resources/public/images";
        String _plus_2 = (targetBasePath + imageFolder);
        File _file_1 = new File(_plus_2);
        File targetFolder = _file_1;
        boolean _exists = targetFolder.exists();
        boolean _not = (!_exists);
        if (_not) {
          String _appName_1 = this.settings.getAppName();
          String _plus_3 = ("src/modules/" + _appName_1);
          String _plus_4 = (_plus_3 + "/images");
          imageFolder = _plus_4;
          String _plus_5 = (targetBasePath + imageFolder);
          File _file_2 = new File(_plus_5);
          targetFolder = _file_2;
        }
        boolean _exists_1 = targetFolder.exists();
        if (_exists_1) {
          String _plus_6 = (targetBasePath + imageFolder);
          String _plus_7 = (_plus_6 + "/admin.png");
          fileCopy.setTargetFile(_plus_7);
          fileCopy.invoke(null);
        }
      } catch (final Throwable _t) {
        if (_t instanceof IOException) {
          final IOException e = (IOException)_t;
          e.printStackTrace();
        } else {
          throw Exceptions.sneakyThrow(_t);
        }
      }
    }
  }
  
  /**
   * Exports the BIRT reports for reporting cartridge.
   */
  private void exportBirtReports() {
    try {
      final Bundle bundle = Platform.getBundle(Activator.PLUGIN_ID);
      String _reportPath = this.settings.getReportPath();
      Path _path = new Path(_reportPath);
      URL[] resources = FileLocator.findEntries(bundle, _path);
      String _reportPath_1 = this.settings.getReportPath();
      String _plus = ("src/" + _reportPath_1);
      Path _path_1 = new Path(_plus);
      final URL[] resourcesExported = FileLocator.findEntries(bundle, _path_1);
      final URL[] _converted_resources = (URL[])resources;
      int _size = ((List<URL>)Conversions.doWrapArray(_converted_resources)).size();
      boolean _lessThan = (_size < 1);
      if (_lessThan) {
        resources = resourcesExported;
      }
      final URL[] _converted_resources_1 = (URL[])resources;
      URL _head = IterableExtensions.<URL>head(((Iterable<URL>)Conversions.doWrapArray(_converted_resources_1)));
      URL _fileURL = FileLocator.toFileURL(_head);
      URI _uRI = _fileURL.toURI();
      File _file = new File(_uRI);
      File dir = _file;
      ReportingFacade _reportingFacade = new ReportingFacade();
      final ReportingFacade reportingFacade = _reportingFacade;
      String _outputPath = this.settings.getOutputPath();
      reportingFacade.setOutputPath(_outputPath);
      String _modelPath = this.settings.getModelPath();
      String _replaceFirst = _modelPath.replaceFirst("file:", "");
      reportingFacade.setModelPath(_replaceFirst);
      reportingFacade.setUp();
      Object[] _selectedReports = this.settings.getSelectedReports();
      for (final Object report : _selectedReports) {
        {
          IProgressMonitor _progressMonitor = this.settings.getProgressMonitor();
          String _string = report.toString();
          String _plus_1 = ("Reporting: " + _string);
          _progressMonitor.subTask(_plus_1);
          String _string_1 = dir.toString();
          String _plus_2 = (_string_1 + "/");
          String _string_2 = report.toString();
          String _plus_3 = (_plus_2 + _string_2);
          String _plus_4 = (_plus_3 + ".rptdesign");
          String _string_3 = report.toString();
          reportingFacade.startExport(_plus_4, _string_3);
          IProgressMonitor _progressMonitor_1 = this.settings.getProgressMonitor();
          _progressMonitor_1.subTask("");
        }
      }
      reportingFacade.shutDown();
    } catch (final Throwable _t) {
      if (_t instanceof Exception) {
        final Exception e = (Exception)_t;
        e.printStackTrace();
      } else {
        throw Exceptions.sneakyThrow(_t);
      }
    }
  }
}
