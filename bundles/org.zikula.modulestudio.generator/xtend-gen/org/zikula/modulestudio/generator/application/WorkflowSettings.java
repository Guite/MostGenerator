package org.zikula.modulestudio.generator.application;

import java.io.File;
import java.net.URL;
import java.util.List;
import org.eclipse.core.runtime.FileLocator;
import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.core.runtime.Path;
import org.eclipse.core.runtime.Platform;
import org.eclipse.xtend.lib.annotations.AccessorType;
import org.eclipse.xtend.lib.annotations.Accessors;
import org.eclipse.xtext.xbase.lib.Conversions;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.eclipse.xtext.xbase.lib.Pure;
import org.eclipse.xtext.xbase.lib.StringExtensions;
import org.osgi.framework.Bundle;
import org.zikula.modulestudio.generator.application.ModuleStudioGeneratorActivator;

/**
 * This class collects required workflow properties.
 */
@SuppressWarnings("all")
public class WorkflowSettings {
  /**
   * The output path.
   */
  @Accessors(AccessorType.PUBLIC_GETTER)
  private String outputPath = null;
  
  /**
   * File handle for output directory.
   */
  @Accessors(AccessorType.PUBLIC_GETTER)
  private File outputDir = null;
  
  /**
   * The model path.
   */
  @Accessors
  private String modelPath = null;
  
  /**
   * The destination path for copying the model.
   */
  @Accessors
  private String modelDestinationPath = null;
  
  /**
   * Name of the vendor of the application instance described by the model.
   */
  @Accessors
  private String appVendor = "";
  
  /**
   * Name of the application instance described by the model.
   */
  @Accessors
  private String appName = "";
  
  /**
   * Version of the application instance described by the model.
   */
  @Accessors
  private String appVersion = "";
  
  /**
   * The progress monitor.
   */
  @Accessors
  private IProgressMonitor progressMonitor = null;
  
  /**
   * Whether stand-alone execution (using jar file) is done or not.
   */
  @Accessors
  private Boolean isStandalone = Boolean.valueOf(false);
  
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
      _xblockexpression = this.outputDir = _file;
    }
    return _xblockexpression;
  }
  
  /**
   * Returns url of default admin image.
   * 
   * @return image url
   */
  public URL getAdminImageUrl() {
    URL _xblockexpression = null;
    {
      final Bundle bundle = Platform.getBundle(ModuleStudioGeneratorActivator.PLUGIN_ID);
      String _adminImageInputPath = this.getAdminImageInputPath();
      String _plus = ("/src" + _adminImageInputPath);
      Path _path = new Path(_plus);
      URL[] resources = FileLocator.findEntries(bundle, _path);
      String _adminImageInputPath_1 = this.getAdminImageInputPath();
      Path _path_1 = new Path(_adminImageInputPath_1);
      final URL[] resourcesExported = FileLocator.findEntries(bundle, _path_1);
      final URL[] _converted_resources = (URL[])resources;
      boolean _isEmpty = ((List<URL>)Conversions.doWrapArray(_converted_resources)).isEmpty();
      if (_isEmpty) {
        resources = resourcesExported;
      }
      final URL[] _converted_resources_1 = (URL[])resources;
      boolean _isEmpty_1 = ((List<URL>)Conversions.doWrapArray(_converted_resources_1)).isEmpty();
      if (_isEmpty_1) {
        return null;
      }
      final URL[] _converted_resources_2 = (URL[])resources;
      _xblockexpression = IterableExtensions.<URL>head(((Iterable<URL>)Conversions.doWrapArray(_converted_resources_2)));
    }
    return _xblockexpression;
  }
  
  /**
   * Returns path to input admin image.
   * 
   * @return string
   */
  public String getAdminImageInputPath() {
    return "/resources/images/MOST_48.png";
  }
  
  /**
   * Returns base path to the module's root folder.
   * 
   * @return string Module base path
   */
  public String getPathToModuleRoot() {
    String _firstUpper = StringExtensions.toFirstUpper(this.appVendor);
    String _plus = ((this.outputPath + File.separator) + _firstUpper);
    String _plus_1 = (_plus + File.separator);
    String _firstUpper_1 = StringExtensions.toFirstUpper(this.appName);
    String _plus_2 = (_plus_1 + _firstUpper_1);
    String _plus_3 = (_plus_2 + "Module");
    return (_plus_3 + File.separator);
  }
  
  /**
   * Returns path to the module's image assets folder.
   * 
   * @return path to images folder
   */
  public File getPathToModuleImageAssets() {
    File _xblockexpression = null;
    {
      final String targetBasePath = this.getPathToModuleRoot();
      String imagePath = (((("Resources" + File.separator) + "public") + File.separator) + "images");
      File targetFolder = new File((targetBasePath + imagePath));
      _xblockexpression = targetFolder;
    }
    return _xblockexpression;
  }
  
  @Pure
  public String getOutputPath() {
    return this.outputPath;
  }
  
  @Pure
  public File getOutputDir() {
    return this.outputDir;
  }
  
  @Pure
  public String getModelPath() {
    return this.modelPath;
  }
  
  public void setModelPath(final String modelPath) {
    this.modelPath = modelPath;
  }
  
  @Pure
  public String getModelDestinationPath() {
    return this.modelDestinationPath;
  }
  
  public void setModelDestinationPath(final String modelDestinationPath) {
    this.modelDestinationPath = modelDestinationPath;
  }
  
  @Pure
  public String getAppVendor() {
    return this.appVendor;
  }
  
  public void setAppVendor(final String appVendor) {
    this.appVendor = appVendor;
  }
  
  @Pure
  public String getAppName() {
    return this.appName;
  }
  
  public void setAppName(final String appName) {
    this.appName = appName;
  }
  
  @Pure
  public String getAppVersion() {
    return this.appVersion;
  }
  
  public void setAppVersion(final String appVersion) {
    this.appVersion = appVersion;
  }
  
  @Pure
  public IProgressMonitor getProgressMonitor() {
    return this.progressMonitor;
  }
  
  public void setProgressMonitor(final IProgressMonitor progressMonitor) {
    this.progressMonitor = progressMonitor;
  }
  
  @Pure
  public Boolean getIsStandalone() {
    return this.isStandalone;
  }
  
  public void setIsStandalone(final Boolean isStandalone) {
    this.isStandalone = isStandalone;
  }
}
