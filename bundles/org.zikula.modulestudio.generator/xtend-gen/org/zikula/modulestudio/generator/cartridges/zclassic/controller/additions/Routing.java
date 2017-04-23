package org.zikula.modulestudio.generator.cartridges.zclassic.controller.additions;

import de.guite.modulestudio.metamodel.Application;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

/**
 * This class generates routing configuration file for the Symfony Routing component.
 * The generated file uses the YAML syntax for configuration.
 */
@SuppressWarnings("all")
public class Routing {
  @Extension
  private NamingExtensions _namingExtensions = new NamingExtensions();
  
  @Extension
  private Utils _utils = new Utils();
  
  /**
   * Entry point for Routing YAML file.
   */
  public void generate(final Application it, final IFileSystemAccess fsa) {
    String _resourcesPath = this._namingExtensions.getResourcesPath(it);
    String configFileName = (_resourcesPath + "config/routing.yml");
    boolean _shouldBeSkipped = this._namingExtensions.shouldBeSkipped(it, configFileName);
    boolean _not = (!_shouldBeSkipped);
    if (_not) {
      boolean _shouldBeMarked = this._namingExtensions.shouldBeMarked(it, configFileName);
      if (_shouldBeMarked) {
        String _resourcesPath_1 = this._namingExtensions.getResourcesPath(it);
        String _plus = (_resourcesPath_1 + "config/routing.generated.yml");
        configFileName = _plus;
      }
      fsa.generateFile(configFileName, this.routingConfig(it));
    }
  }
  
  private CharSequence routingConfig(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    String _lowerCase = this._utils.appName(it).toLowerCase();
    _builder.append(_lowerCase);
    _builder.append(":");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("# define routing support for these controllers");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("resource: \"@");
    String _appName = this._utils.appName(it);
    _builder.append(_appName, "    ");
    _builder.append("/Controller\"");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("# enable support for defining routes by annotations");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("type: annotation");
    _builder.newLine();
    return _builder;
  }
}
