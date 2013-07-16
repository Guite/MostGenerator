package org.zikula.modulestudio.generator.application;

import java.io.File;
import java.io.IOException;
import java.net.URI;
import java.net.URISyntaxException;
import java.net.URL;
import java.util.ArrayList;
import java.util.List;
import org.eclipse.core.runtime.FileLocator;
import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.core.runtime.Path;
import org.eclipse.core.runtime.Platform;
import org.eclipse.gmf.runtime.diagram.core.preferences.PreferencesHint;
import org.eclipse.gmf.runtime.notation.Diagram;
import org.eclipse.xtext.xbase.lib.Conversions;
import org.eclipse.xtext.xbase.lib.Exceptions;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.osgi.framework.Bundle;
import org.zikula.modulestudio.generator.application.Activator;
import org.zikula.modulestudio.generator.cartridges.reporting.ReportFilenameFilter;

/**
 * This class collects required workflow properties.
 */
@SuppressWarnings("all")
public class WorkflowSettings {
  /**
   * List of available cartridges.
   */
  private ArrayList<String> availableCartridges = new Function0<ArrayList<String>>() {
    public ArrayList<String> apply() {
      ArrayList<String> _arrayList = new ArrayList<String>();
      return _arrayList;
    }
  }.apply();
  
  /**
   * List of selected cartridges.
   */
  private ArrayList<Object> selectedCartridges = new Function0<ArrayList<Object>>() {
    public ArrayList<Object> apply() {
      ArrayList<Object> _arrayList = new ArrayList<Object>();
      return _arrayList;
    }
  }.apply();
  
  /**
   * The output path.
   */
  private String outputPath = null;
  
  /**
   * File handle for output directory.
   */
  private File outputDir = null;
  
  /**
   * The model path.
   */
  private String _modelPath = null;
  
  /**
   * The model path.
   */
  public String getModelPath() {
    return this._modelPath;
  }
  
  /**
   * The model path.
   */
  public void setModelPath(final String modelPath) {
    this._modelPath = modelPath;
  }
  
  /**
   * Reference to current diagram.
   */
  private Diagram _diagram = null;
  
  /**
   * Reference to current diagram.
   */
  public Diagram getDiagram() {
    return this._diagram;
  }
  
  /**
   * Reference to current diagram.
   */
  public void setDiagram(final Diagram diagram) {
    this._diagram = diagram;
  }
  
  /**
   * Name of the application instance described by the model.
   */
  private String _appName = "";
  
  /**
   * Name of the application instance described by the model.
   */
  public String getAppName() {
    return this._appName;
  }
  
  /**
   * Name of the application instance described by the model.
   */
  public void setAppName(final String appName) {
    this._appName = appName;
  }
  
  /**
   * Version of the application instance described by the model.
   */
  private String _appVersion = "";
  
  /**
   * Version of the application instance described by the model.
   */
  public String getAppVersion() {
    return this._appVersion;
  }
  
  /**
   * Version of the application instance described by the model.
   */
  public void setAppVersion(final String appVersion) {
    this._appVersion = appVersion;
  }
  
  /**
   * Preference hint for reporting.
   */
  private PreferencesHint _diagramPreferencesHint = null;
  
  /**
   * Preference hint for reporting.
   */
  public PreferencesHint getDiagramPreferencesHint() {
    return this._diagramPreferencesHint;
  }
  
  /**
   * Preference hint for reporting.
   */
  public void setDiagramPreferencesHint(final PreferencesHint diagramPreferencesHint) {
    this._diagramPreferencesHint = diagramPreferencesHint;
  }
  
  /**
   * The progress monitor.
   */
  private IProgressMonitor _progressMonitor = null;
  
  /**
   * The progress monitor.
   */
  public IProgressMonitor getProgressMonitor() {
    return this._progressMonitor;
  }
  
  /**
   * The progress monitor.
   */
  public void setProgressMonitor(final IProgressMonitor progressMonitor) {
    this._progressMonitor = progressMonitor;
  }
  
  /**
   * List of available reports.
   */
  private ArrayList<String> availableReports = new Function0<ArrayList<String>>() {
    public ArrayList<String> apply() {
      ArrayList<String> _arrayList = new ArrayList<String>();
      return _arrayList;
    }
  }.apply();
  
  /**
   * List of selected reports.
   */
  private Object[] _selectedReports = null;
  
  /**
   * List of selected reports.
   */
  public Object[] getSelectedReports() {
    return this._selectedReports;
  }
  
  /**
   * List of selected reports.
   */
  public void setSelectedReports(final Object[] selectedReports) {
    this._selectedReports = selectedReports;
  }
  
  /**
   * Path containing the report files.
   */
  private String _reportPath = "/org/zikula/modulestudio/generator/cartridges/reporting/reports";
  
  /**
   * Path containing the report files.
   */
  public String getReportPath() {
    return this._reportPath;
  }
  
  /**
   * Path containing the report files.
   */
  public void setReportPath(final String reportPath) {
    this._reportPath = reportPath;
  }
  
  /**
   * The constructor.
   */
  public WorkflowSettings() {
    this.availableCartridges.add("zclassic");
    this.availableCartridges.add("reporting");
    this.selectedCartridges.add("zclassic");
    this.selectedCartridges.add("reporting");
    try {
      this.collectAvailableReports();
    } catch (final Throwable _t) {
      if (_t instanceof Exception) {
        final Exception exc = (Exception)_t;
        exc.printStackTrace();
      } else {
        throw Exceptions.sneakyThrow(_t);
      }
    }
  }
  
  /**
   * Collect available reports.
   * 
   * @throws Exception
   *             In case something goes wrong.
   */
  private void collectAvailableReports() throws Exception {
    Bundle _bundle = Platform.getBundle(Activator.PLUGIN_ID);
    String _reportPath = this.getReportPath();
    String _plus = ("/src" + _reportPath);
    Path _path = new Path(_plus);
    URL[] resources = FileLocator.findEntries(_bundle, _path);
    Bundle _bundle_1 = Platform.getBundle(Activator.PLUGIN_ID);
    String _reportPath_1 = this.getReportPath();
    Path _path_1 = new Path(_reportPath_1);
    final URL[] resourcesExported = FileLocator.findEntries(_bundle_1, _path_1);
    final URL[] _converted_resources = (URL[])resources;
    int _size = ((List<URL>)Conversions.doWrapArray(_converted_resources)).size();
    boolean _equals = (_size == 0);
    if (_equals) {
      resources = resourcesExported;
    }
    final URL[] _converted_resources_1 = (URL[])resources;
    int _size_1 = ((List<URL>)Conversions.doWrapArray(_converted_resources_1)).size();
    boolean _equals_1 = (_size_1 == 0);
    if (_equals_1) {
      Exception _exception = new Exception("Could not find report directory.");
      throw _exception;
    }
    try {
      final URL[] _converted_resources_2 = (URL[])resources;
      URL _head = IterableExtensions.<URL>head(((Iterable<URL>)Conversions.doWrapArray(_converted_resources_2)));
      URL _fileURL = FileLocator.toFileURL(_head);
      URI _uRI = _fileURL.toURI();
      File _file = new File(_uRI);
      final File reportDir = _file;
      ReportFilenameFilter _reportFilenameFilter = new ReportFilenameFilter();
      String[] _list = reportDir.list(_reportFilenameFilter);
      for (final String file : _list) {
        String _replace = file.replace(".rptdesign", "");
        this.availableReports.add(_replace);
      }
    } catch (final Throwable _t) {
      if (_t instanceof URISyntaxException) {
        final URISyntaxException e = (URISyntaxException)_t;
        e.printStackTrace();
      } else if (_t instanceof IOException) {
        final IOException e_1 = (IOException)_t;
        e_1.printStackTrace();
      } else {
        throw Exceptions.sneakyThrow(_t);
      }
    }
  }
  
  /**
   * Returns the list of available cartridges.
   * 
   * @return Cartridge list.
   */
  public ArrayList<String> getAvailableCartridges() {
    return this.availableCartridges;
  }
  
  /**
   * Returns the list of selected cartridges.
   * 
   * @return Cartridge list.
   */
  public ArrayList<Object> getSelectedCartridges() {
    return this.selectedCartridges;
  }
  
  /**
   * Returns the list of available reports.
   * 
   * @return Report list.
   */
  public ArrayList<String> getAvailableReports() {
    return this.availableReports;
  }
  
  /**
   * Sets the output path.
   * 
   * @param path
   *            The given path string.
   */
  public File setOutputPath(final String path) {
    File _xblockexpression = null;
    {
      this.outputPath = path;
      File _file = new File(path);
      File _outputDir = this.outputDir = _file;
      _xblockexpression = (_outputDir);
    }
    return _xblockexpression;
  }
  
  /**
   * Sets the list of selected cartridges.
   * 
   * @param objects
   *            The given cartridge list.
   */
  public void setSelectedCartridges(final Object[] objects) {
    this.selectedCartridges.clear();
    for (final Object cartridge : objects) {
      this.selectedCartridges.add(cartridge);
    }
  }
  
  /**
   * Returns the output directory.
   * 
   * @return the outputDir
   */
  public File getOutputDir() {
    return this.outputDir;
  }
  
  /**
   * Returns the output path.
   * 
   * @return the outputPath
   */
  public String getOutputPath() {
    return this.outputPath;
  }
}
