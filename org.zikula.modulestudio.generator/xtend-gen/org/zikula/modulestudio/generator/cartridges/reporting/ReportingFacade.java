package org.zikula.modulestudio.generator.cartridges.reporting;

import java.io.File;
import java.util.HashMap;
import java.util.logging.Level;
import org.eclipse.birt.core.framework.Platform;
import org.eclipse.birt.report.engine.api.EngineConfig;
import org.eclipse.birt.report.engine.api.EngineConstants;
import org.eclipse.birt.report.engine.api.EngineException;
import org.eclipse.birt.report.engine.api.IReportEngine;
import org.eclipse.birt.report.engine.api.IReportEngineFactory;
import org.eclipse.birt.report.engine.api.IReportRunnable;
import org.eclipse.birt.report.engine.api.IRunAndRenderTask;
import org.eclipse.birt.report.engine.api.RenderOption;
import org.eclipse.birt.report.engine.api.ReportEngine;
import org.eclipse.xtext.xbase.lib.Exceptions;

/**
 * Facade class for the reporting cartridge.
 */
@SuppressWarnings("all")
public class ReportingFacade {
  /**
   * The output path.
   */
  private String outputPath;
  
  /**
   * The model path.
   */
  private String modelPath;
  
  /**
   * The {@link IReportEngine} reference.
   */
  private IReportEngine engine = null;
  
  /**
   * Report engine configuration object.
   */
  private EngineConfig config = null;
  
  /**
   * The {@link IRunAndRenderTask} reference.
   */
  private IRunAndRenderTask task = null;
  
  /**
   * Sets up prerequisites.
   */
  public IReportEngine setUp() {
    IReportEngine _xtrycatchfinallyexpression = null;
    try {
      IReportEngine _xblockexpression = null;
      {
        EngineConfig _engineConfig = new EngineConfig();
        this.config = _engineConfig;
        final HashMap hm = this.config.getAppContext();
        ClassLoader _classLoader = ReportEngine.class.getClassLoader();
        hm.put(EngineConstants.APPCONTEXT_CLASSLOADER_KEY, _classLoader);
        this.config.setAppContext(hm);
        final String reportPath = (this.outputPath + "/reporting/");
        File _file = new File(reportPath);
        final File reportPathDir = _file;
        boolean _exists = reportPathDir.exists();
        boolean _not = (!_exists);
        if (_not) {
          reportPathDir.mkdir();
        }
        this.config.setLogConfig(reportPath, 
          Level.WARNING);
        Platform.startup(this.config);
        Object _createFactoryObject = Platform.createFactoryObject(IReportEngineFactory.EXTENSION_REPORT_ENGINE_FACTORY);
        final IReportEngineFactory factory = ((IReportEngineFactory) _createFactoryObject);
        IReportEngine _createReportEngine = factory.createReportEngine(this.config);
        IReportEngine _engine = this.engine = _createReportEngine;
        _xblockexpression = (_engine);
      }
      _xtrycatchfinallyexpression = _xblockexpression;
    } catch (final Throwable _t) {
      if (_t instanceof Exception) {
        final Exception ex = (Exception)_t;
        ex.printStackTrace();
      } else {
        throw Exceptions.sneakyThrow(_t);
      }
    }
    return _xtrycatchfinallyexpression;
  }
  
  /**
   * Starts the export of a certain report to a given output name.
   * 
   * @param reportPath
   *            The path to the report.
   * @param outputName
   *            Desired name of output file.
   */
  public void startExport(final String reportPath, final String outputName) {
    try {
      this.singleExport(reportPath, outputName, "html");
      this.singleExport(reportPath, outputName, "pdf");
    } catch (final Throwable _t) {
      if (_t instanceof Exception) {
        final Exception ex = (Exception)_t;
        ex.printStackTrace();
      } else {
        throw Exceptions.sneakyThrow(_t);
      }
    }
  }
  
  /**
   * Does a single export for a certain file format.
   * 
   * @param reportPath
   *            The path to the report.
   * @param outputName
   *            Desired name of output file.
   * @param fileExtension
   *            Desired file format.
   */
  private void singleExport(final String reportPath, final String outputName, final String fileExtension) throws EngineException {
    IReportRunnable _openReportDesign = this.engine.openReportDesign(reportPath);
    IRunAndRenderTask _createRunAndRenderTask = this.engine.createRunAndRenderTask(_openReportDesign);
    this.task = _createRunAndRenderTask;
    String _plus = ("file:" + this.modelPath);
    this.task.setParameterValue("modelPath", _plus);
    String _plus_1 = (this.outputPath + "/diagrams/");
    String _plus_2 = ("file:" + _plus_1);
    this.task.setParameterValue("diagramPath", _plus_2);
    RenderOption _renderOption = new RenderOption();
    RenderOption renderOptions = _renderOption;
    String _plus_3 = (this.outputPath + "/reporting/");
    String _plus_4 = (_plus_3 + outputName);
    String _plus_5 = (_plus_4 + ".");
    String _plus_6 = (_plus_5 + fileExtension);
    renderOptions.setOutputFileName(_plus_6);
    renderOptions.setOutputFormat(fileExtension);
    this.task.setRenderOption(renderOptions);
    this.task.run();
    this.task.close();
  }
  
  /**
   * Cleanup method.
   */
  public void shutDown() {
    try {
      this.engine.destroy();
      Platform.shutdown();
    } catch (final Throwable _t) {
      if (_t instanceof Exception) {
        final Exception ex = (Exception)_t;
        ex.printStackTrace();
      } else {
        throw Exceptions.sneakyThrow(_t);
      }
    }
  }
  
  /**
   * Sets the output path.
   * 
   * @param path The given path.
   */
  public String setOutputPath(final String path) {
    String _outputPath = this.outputPath = path;
    return _outputPath;
  }
  
  /**
   * Sets the model path.
   * 
   * @param path The given path.
   */
  public String setModelPath(final String path) {
    String _modelPath = this.modelPath = path;
    return _modelPath;
  }
}
