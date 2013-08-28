package org.zikula.modulestudio.generator.extensions;

import com.google.common.base.Objects;
import com.google.inject.Inject;
import de.guite.modulestudio.metamodel.modulestudio.Application;
import de.guite.modulestudio.metamodel.modulestudio.Controller;
import de.guite.modulestudio.metamodel.modulestudio.Controllers;
import de.guite.modulestudio.metamodel.modulestudio.Entity;
import de.guite.modulestudio.metamodel.modulestudio.JoinRelationship;
import de.guite.modulestudio.metamodel.modulestudio.Models;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.eclipse.xtext.xbase.lib.StringExtensions;
import org.zikula.modulestudio.generator.extensions.ControllerExtensions;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

/**
 * Extension methods for naming classes and building file pathes.
 */
@SuppressWarnings("all")
public class NamingExtensions {
  /**
   * Extensions related to the controller layer.
   */
  @Inject
  @Extension
  private ControllerExtensions _controllerExtensions = new Function0<ControllerExtensions>() {
    public ControllerExtensions apply() {
      ControllerExtensions _controllerExtensions = new ControllerExtensions();
      return _controllerExtensions;
    }
  }.apply();
  
  /**
   * Extensions used for formatting element names.
   */
  @Inject
  @Extension
  private FormattingExtensions _formattingExtensions = new Function0<FormattingExtensions>() {
    public FormattingExtensions apply() {
      FormattingExtensions _formattingExtensions = new FormattingExtensions();
      return _formattingExtensions;
    }
  }.apply();
  
  /**
   * Additional utility methods.
   */
  @Inject
  @Extension
  private Utils _utils = new Function0<Utils>() {
    public Utils apply() {
      Utils _utils = new Utils();
      return _utils;
    }
  }.apply();
  
  /**
   * Concatenates two strings being used for a template path.
   */
  public String prepTemplatePart(final String origin, final String addition) {
    String _lowerCase = addition.toLowerCase();
    String _plus = (origin + _lowerCase);
    return _plus;
  }
  
  /**
   * Returns the common suffix for template file names.
   */
  public String templateSuffix() {
    return ".tpl";
  }
  
  /**
   * Returns the base path for a certain template file.
   */
  public String templateFileBase(final Controller it, final String entityName, final String actionName) {
    String _xifexpression = null;
    Controllers _container = it.getContainer();
    Application _application = _container.getApplication();
    boolean _targets = this._utils.targets(_application, "1.3.5");
    if (_targets) {
      Controllers _container_1 = it.getContainer();
      Application _application_1 = _container_1.getApplication();
      String _viewPath = this.getViewPath(_application_1);
      String _formattedName = this._controllerExtensions.formattedName(it);
      String _plus = (_viewPath + _formattedName);
      String _plus_1 = (_plus + "/");
      String _formatForCode = this._formattingExtensions.formatForCode(entityName);
      String _plus_2 = (_plus_1 + _formatForCode);
      String _plus_3 = (_plus_2 + "/");
      String _plus_4 = (_plus_3 + actionName);
      _xifexpression = _plus_4;
    } else {
      Controllers _container_2 = it.getContainer();
      Application _application_2 = _container_2.getApplication();
      String _viewPath_1 = this.getViewPath(_application_2);
      String _formattedName_1 = this._controllerExtensions.formattedName(it);
      String _firstUpper = StringExtensions.toFirstUpper(_formattedName_1);
      String _plus_5 = (_viewPath_1 + _firstUpper);
      String _plus_6 = (_plus_5 + "/");
      String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(entityName);
      String _plus_7 = (_plus_6 + _formatForCodeCapital);
      String _plus_8 = (_plus_7 + "/");
      String _plus_9 = (_plus_8 + actionName);
      _xifexpression = _plus_9;
    }
    return _xifexpression;
  }
  
  /**
   * Returns the full template file path for given controller action and entity.
   */
  public String templateFile(final Controller it, final String entityName, final String actionName) {
    String _templateFileBase = this.templateFileBase(it, entityName, actionName);
    String _templateSuffix = this.templateSuffix();
    String _plus = (_templateFileBase + _templateSuffix);
    return _plus;
  }
  
  /**
   * Returns the full template file path for given controller action and entity,
   * using a custom template extension (like xml instead of tpl).
   */
  public String templateFileWithExtension(final Controller it, final String entityName, final String actionName, final String templateExtension) {
    String _templateFileBase = this.templateFileBase(it, entityName, actionName);
    String _plus = (_templateFileBase + ".");
    String _plus_1 = (_plus + templateExtension);
    return _plus_1;
  }
  
  /**
   * Returns the full template file path for given controller edit action and entity.
   */
  public String editTemplateFile(final Controller it, final String entityName, final String actionName) {
    String _templateFile = this.templateFile(it, entityName, actionName);
    return _templateFile;
  }
  
  /**
   * Returns the full file path for a view plugin file.
   */
  public String viewPluginFilePath(final Application it, final String pluginType, final String pluginName) {
    String _viewPath = this.getViewPath(it);
    String _plus = (_viewPath + "plugins/");
    String _plus_1 = (_plus + pluginType);
    String _plus_2 = (_plus_1 + ".");
    String _appName = this._utils.appName(it);
    String _formatForDB = this._formattingExtensions.formatForDB(_appName);
    String _plus_3 = (_plus_2 + _formatForDB);
    String _plus_4 = (_plus_3 + pluginName);
    String _plus_5 = (_plus_4 + ".php");
    return _plus_5;
  }
  
  /**
   * Returns the alias name for one side of a given relationship.
   */
  public String getRelationAliasName(final JoinRelationship it, final Boolean useTarget) {
    String _xblockexpression = null;
    {
      String result = null;
      boolean _and = false;
      boolean _and_1 = false;
      if (!(useTarget).booleanValue()) {
        _and_1 = false;
      } else {
        String _targetAlias = it.getTargetAlias();
        boolean _tripleNotEquals = (_targetAlias != null);
        _and_1 = ((useTarget).booleanValue() && _tripleNotEquals);
      }
      if (!_and_1) {
        _and = false;
      } else {
        String _targetAlias_1 = it.getTargetAlias();
        boolean _notEquals = (!Objects.equal(_targetAlias_1, ""));
        _and = (_and_1 && _notEquals);
      }
      if (_and) {
        String _targetAlias_2 = it.getTargetAlias();
        result = _targetAlias_2;
      } else {
        boolean _and_2 = false;
        boolean _and_3 = false;
        boolean _not = (!(useTarget).booleanValue());
        if (!_not) {
          _and_3 = false;
        } else {
          String _sourceAlias = it.getSourceAlias();
          boolean _tripleNotEquals_1 = (_sourceAlias != null);
          _and_3 = (_not && _tripleNotEquals_1);
        }
        if (!_and_3) {
          _and_2 = false;
        } else {
          String _sourceAlias_1 = it.getSourceAlias();
          boolean _notEquals_1 = (!Objects.equal(_sourceAlias_1, ""));
          _and_2 = (_and_3 && _notEquals_1);
        }
        if (_and_2) {
          String _sourceAlias_2 = it.getSourceAlias();
          result = _sourceAlias_2;
        } else {
          Entity _xifexpression = null;
          if ((useTarget).booleanValue()) {
            Entity _target = it.getTarget();
            _xifexpression = _target;
          } else {
            Entity _source = it.getSource();
            _xifexpression = _source;
          }
          String _entityClassName = this.entityClassName(_xifexpression, "", Boolean.valueOf(false));
          result = _entityClassName;
        }
      }
      String _formatForCode = this._formattingExtensions.formatForCode(result);
      _xblockexpression = (_formatForCode);
    }
    return _xblockexpression;
  }
  
  /**
   * Returns the class name for a certain entity class.
   */
  public String entityClassName(final Entity it, final String suffix, final Boolean isBase) {
    String _xblockexpression = null;
    {
      Models _container = it.getContainer();
      final Application app = _container.getApplication();
      String _xifexpression = null;
      boolean _targets = this._utils.targets(app, "1.3.5");
      if (_targets) {
        String _appName = this._utils.appName(app);
        String _plus = (_appName + "_Entity_");
        String _xifexpression_1 = null;
        if ((isBase).booleanValue()) {
          _xifexpression_1 = "Base_";
        } else {
          _xifexpression_1 = "";
        }
        String _plus_1 = (_plus + _xifexpression_1);
        String _name = it.getName();
        String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(_name);
        String _plus_2 = (_plus_1 + _formatForCodeCapital);
        String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(suffix);
        String _plus_3 = (_plus_2 + _formatForCodeCapital_1);
        _xifexpression = _plus_3;
      } else {
        String _vendor = app.getVendor();
        String _formatForCodeCapital_2 = this._formattingExtensions.formatForCodeCapital(_vendor);
        String _plus_4 = (_formatForCodeCapital_2 + "\\");
        String _name_1 = app.getName();
        String _formatForCodeCapital_3 = this._formattingExtensions.formatForCodeCapital(_name_1);
        String _plus_5 = (_plus_4 + _formatForCodeCapital_3);
        String _plus_6 = (_plus_5 + "Module\\Entity\\");
        String _xifexpression_2 = null;
        if ((isBase).booleanValue()) {
          _xifexpression_2 = "Base\\";
        } else {
          _xifexpression_2 = "";
        }
        String _plus_7 = (_plus_6 + _xifexpression_2);
        String _name_2 = it.getName();
        String _formatForCodeCapital_4 = this._formattingExtensions.formatForCodeCapital(_name_2);
        String _plus_8 = (_plus_7 + _formatForCodeCapital_4);
        String _formatForCodeCapital_5 = this._formattingExtensions.formatForCodeCapital(suffix);
        String _plus_9 = (_plus_8 + _formatForCodeCapital_5);
        String _plus_10 = (_plus_9 + "Entity");
        _xifexpression = _plus_10;
      }
      _xblockexpression = (_xifexpression);
    }
    return _xblockexpression;
  }
  
  /**
   * Returns the base path for the generated application.
   */
  public String getAppSourcePath(final Application it) {
    String _xifexpression = null;
    boolean _targets = this._utils.targets(it, "1.3.5");
    if (_targets) {
      String _appName = this._utils.appName(it);
      String _plus = ("src/modules/" + _appName);
      String _plus_1 = (_plus + "/");
      _xifexpression = _plus_1;
    } else {
      String _vendor = it.getVendor();
      String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(_vendor);
      String _plus_2 = (_formatForCodeCapital + "/");
      String _name = it.getName();
      String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(_name);
      String _plus_3 = (_plus_2 + _formatForCodeCapital_1);
      String _plus_4 = (_plus_3 + "Module/");
      _xifexpression = _plus_4;
    }
    return _xifexpression;
  }
  
  /**
   * Returns the base path for the source code of the generated application.
   */
  public String getAppSourceLibPath(final Application it) {
    String _xifexpression = null;
    boolean _targets = this._utils.targets(it, "1.3.5");
    if (_targets) {
      String _appSourcePath = this.getAppSourcePath(it);
      String _plus = (_appSourcePath + "lib/");
      String _appName = this._utils.appName(it);
      String _plus_1 = (_plus + _appName);
      String _plus_2 = (_plus_1 + "/");
      _xifexpression = _plus_2;
    } else {
      String _appSourcePath_1 = this.getAppSourcePath(it);
      _xifexpression = _appSourcePath_1;
    }
    return _xifexpression;
  }
  
  /**
   * Returns the base path for any documentation.
   */
  public String getAppDocPath(final Application it) {
    String _xifexpression = null;
    boolean _targets = this._utils.targets(it, "1.3.5");
    if (_targets) {
      String _appSourcePath = this.getAppSourcePath(it);
      String _plus = (_appSourcePath + "docs/");
      _xifexpression = _plus;
    } else {
      String _resourcesPath = this.getResourcesPath(it);
      String _plus_1 = (_resourcesPath + "docs/");
      _xifexpression = _plus_1;
    }
    return _xifexpression;
  }
  
  /**
   * Returns the base path for the locale artifacts.
   */
  public String getAppLocalePath(final Application it) {
    String _xifexpression = null;
    boolean _targets = this._utils.targets(it, "1.3.5");
    if (_targets) {
      String _appSourcePath = this.getAppSourcePath(it);
      String _plus = (_appSourcePath + "locale/");
      _xifexpression = _plus;
    } else {
      String _resourcesPath = this.getResourcesPath(it);
      String _plus_1 = (_resourcesPath + "locale/");
      _xifexpression = _plus_1;
    }
    return _xifexpression;
  }
  
  /**
   * Returns the base path for any resources.
   */
  public String getResourcesPath(final Application it) {
    String _appSourcePath = this.getAppSourcePath(it);
    String _plus = (_appSourcePath + "Resources/");
    return _plus;
  }
  
  /**
   * Returns the base path for any assets.
   */
  public String getAssetPath(final Application it) {
    String _resourcesPath = this.getResourcesPath(it);
    String _plus = (_resourcesPath + "public/");
    return _plus;
  }
  
  /**
   * Returns the base path for all view templates.
   */
  public String getViewPath(final Application it) {
    String _xifexpression = null;
    boolean _targets = this._utils.targets(it, "1.3.5");
    if (_targets) {
      String _appSourcePath = this.getAppSourcePath(it);
      String _plus = (_appSourcePath + "templates/");
      _xifexpression = _plus;
    } else {
      String _resourcesPath = this.getResourcesPath(it);
      String _plus_1 = (_resourcesPath + "views/");
      _xifexpression = _plus_1;
    }
    return _xifexpression;
  }
  
  /**
   * Returns the base path for image files.
   */
  public String getAppImagePath(final Application it) {
    String _xifexpression = null;
    boolean _targets = this._utils.targets(it, "1.3.5");
    if (_targets) {
      String _appSourcePath = this.getAppSourcePath(it);
      String _plus = (_appSourcePath + "images/");
      _xifexpression = _plus;
    } else {
      String _assetPath = this.getAssetPath(it);
      String _plus_1 = (_assetPath + "images/");
      _xifexpression = _plus_1;
    }
    return _xifexpression;
  }
  
  /**
   * Returns the base path for css files.
   */
  public String getAppCssPath(final Application it) {
    String _xifexpression = null;
    boolean _targets = this._utils.targets(it, "1.3.5");
    if (_targets) {
      String _appSourcePath = this.getAppSourcePath(it);
      String _plus = (_appSourcePath + "style/");
      _xifexpression = _plus;
    } else {
      String _assetPath = this.getAssetPath(it);
      String _plus_1 = (_assetPath + "css/");
      _xifexpression = _plus_1;
    }
    return _xifexpression;
  }
  
  /**
   * Returns the base path for js files.
   */
  public String getAppJsPath(final Application it) {
    String _xifexpression = null;
    boolean _targets = this._utils.targets(it, "1.3.5");
    if (_targets) {
      String _appSourcePath = this.getAppSourcePath(it);
      String _plus = (_appSourcePath + "javascript/");
      _xifexpression = _plus;
    } else {
      String _assetPath = this.getAssetPath(it);
      String _plus_1 = (_assetPath + "js/");
      _xifexpression = _plus_1;
    }
    return _xifexpression;
  }
  
  /**
   * Returns the base path for uploaded files of the generated application.
   */
  public String getAppUploadPath(final Application it) {
    String _xifexpression = null;
    boolean _targets = this._utils.targets(it, "1.3.5");
    if (_targets) {
      String _appName = this._utils.appName(it);
      String _plus = ("src/userdata/" + _appName);
      String _plus_1 = (_plus + "/");
      _xifexpression = _plus_1;
    } else {
      String _resourcesPath = this.getResourcesPath(it);
      String _plus_2 = (_resourcesPath + "userdata/");
      String _appName_1 = this._utils.appName(it);
      String _plus_3 = (_plus_2 + _appName_1);
      String _plus_4 = (_plus_3 + "/");
      _xifexpression = _plus_4;
    }
    return _xifexpression;
  }
  
  /**
   * Returns the base path for the test source code of the generated application.
   */
  public String getAppTestsPath(final Application it) {
    String _xifexpression = null;
    boolean _targets = this._utils.targets(it, "1.3.5");
    if (_targets) {
      _xifexpression = "tests/";
    } else {
      String _appSourcePath = this.getAppSourcePath(it);
      String _plus = (_appSourcePath + "Tests/");
      _xifexpression = _plus;
    }
    return _xifexpression;
  }
}
