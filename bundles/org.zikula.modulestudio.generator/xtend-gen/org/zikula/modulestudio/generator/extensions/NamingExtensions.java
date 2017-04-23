package org.zikula.modulestudio.generator.extensions;

import com.google.common.base.Objects;
import de.guite.modulestudio.metamodel.Application;
import de.guite.modulestudio.metamodel.DataObject;
import de.guite.modulestudio.metamodel.Entity;
import de.guite.modulestudio.metamodel.JoinRelationship;
import java.util.ArrayList;
import java.util.Arrays;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.CollectionLiterals;
import org.eclipse.xtext.xbase.lib.Conversions;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.GeneratorSettingsExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

/**
 * Extension methods for naming classes and building file pathes.
 */
@SuppressWarnings("all")
public class NamingExtensions {
  /**
   * Extensions used for formatting element names.
   */
  @Extension
  private FormattingExtensions _formattingExtensions = new FormattingExtensions();
  
  /**
   * Helper methods for generator settings.
   */
  @Extension
  private GeneratorSettingsExtensions _generatorSettingsExtensions = new GeneratorSettingsExtensions();
  
  /**
   * Additional utility methods.
   */
  @Extension
  private Utils _utils = new Utils();
  
  /**
   * Concatenates two strings being used for a template path.
   */
  public String prepTemplatePart(final String origin, final String addition) {
    String _lowerCase = addition.toLowerCase();
    return (origin + _lowerCase);
  }
  
  /**
   * Returns the common suffix for template file names.
   */
  public String templateSuffix(final Application it, final String format) {
    return (("." + format) + ".twig");
  }
  
  /**
   * Returns the base path for a certain template file.
   */
  public String templateFileBase(final Entity it, final String actionName) {
    String _viewPath = this.getViewPath(it.getApplication());
    String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(it.getName());
    String _plus = (_viewPath + _formatForCodeCapital);
    String _plus_1 = (_plus + "/");
    return (_plus_1 + actionName);
  }
  
  /**
   * Returns the full template file path for given controller action and entity.
   */
  public String templateFile(final Entity it, final String actionName) {
    String _xblockexpression = null;
    {
      String _templateFileBase = this.templateFileBase(it, actionName);
      String _templateSuffix = this.templateSuffix(it.getApplication(), "html");
      String filePath = (_templateFileBase + _templateSuffix);
      boolean _shouldBeMarked = this.shouldBeMarked(it.getApplication(), filePath);
      if (_shouldBeMarked) {
        String _templateFileBase_1 = this.templateFileBase(it, actionName);
        String _plus = (_templateFileBase_1 + ".generated");
        String _templateSuffix_1 = this.templateSuffix(it.getApplication(), "html");
        String _plus_1 = (_plus + _templateSuffix_1);
        filePath = _plus_1;
      }
      _xblockexpression = filePath;
    }
    return _xblockexpression;
  }
  
  /**
   * Returns the full template file path for given controller action and entity,
   * using a custom template extension (like xml instead of tpl).
   */
  public String templateFileWithExtension(final Entity it, final String actionName, final String templateExtension) {
    String _xblockexpression = null;
    {
      String _templateFileBase = this.templateFileBase(it, actionName);
      String _templateSuffix = this.templateSuffix(it.getApplication(), templateExtension);
      String filePath = (_templateFileBase + _templateSuffix);
      boolean _shouldBeMarked = this.shouldBeMarked(it.getApplication(), filePath);
      if (_shouldBeMarked) {
        String _templateFileBase_1 = this.templateFileBase(it, actionName);
        String _plus = (_templateFileBase_1 + ".generated");
        String _templateSuffix_1 = this.templateSuffix(it.getApplication(), templateExtension);
        String _plus_1 = (_plus + _templateSuffix_1);
        filePath = _plus_1;
      }
      _xblockexpression = filePath;
    }
    return _xblockexpression;
  }
  
  /**
   * Returns the full template file path for given controller edit action and entity.
   */
  public String editTemplateFile(final Entity it, final String actionName) {
    return this.templateFile(it, actionName);
  }
  
  /**
   * Returns the full file path for a view plugin file.
   */
  public String viewPluginFilePath(final Application it, final String pluginType, final String pluginName) {
    String _xblockexpression = null;
    {
      String _viewPath = this.getViewPath(it);
      String _plus = (_viewPath + "plugins/");
      String _plus_1 = (_plus + pluginType);
      String _plus_2 = (_plus_1 + ".");
      String _formatForDB = this._formattingExtensions.formatForDB(this._utils.appName(it));
      String _plus_3 = (_plus_2 + _formatForDB);
      String _plus_4 = (_plus_3 + pluginName);
      String filePath = (_plus_4 + ".php");
      boolean _shouldBeMarked = this.shouldBeMarked(it, filePath);
      if (_shouldBeMarked) {
        String _viewPath_1 = this.getViewPath(it);
        String _plus_5 = (_viewPath_1 + "plugins/");
        String _plus_6 = (_plus_5 + pluginType);
        String _plus_7 = (_plus_6 + ".");
        String _formatForDB_1 = this._formattingExtensions.formatForDB(this._utils.appName(it));
        String _plus_8 = (_plus_7 + _formatForDB_1);
        String _plus_9 = (_plus_8 + pluginName);
        String _plus_10 = (_plus_9 + ".generated.php");
        filePath = _plus_10;
      }
      _xblockexpression = filePath;
    }
    return _xblockexpression;
  }
  
  /**
   * Returns the alias name for one side of a given relationship.
   */
  public String getRelationAliasName(final JoinRelationship it, final Boolean useTarget) {
    String _xblockexpression = null;
    {
      String result = null;
      if ((((useTarget).booleanValue() && (null != it.getTargetAlias())) && (!Objects.equal(it.getTargetAlias(), "")))) {
        result = it.getTargetAlias();
      } else {
        if ((((!(useTarget).booleanValue()) && (null != it.getSourceAlias())) && (!Objects.equal(it.getSourceAlias(), "")))) {
          result = it.getSourceAlias();
        } else {
          DataObject _xifexpression = null;
          if ((useTarget).booleanValue()) {
            _xifexpression = it.getTarget();
          } else {
            _xifexpression = it.getSource();
          }
          result = this.entityClassName(_xifexpression, "", Boolean.valueOf(false));
        }
      }
      _xblockexpression = this._formattingExtensions.formatForCode(result);
    }
    return _xblockexpression;
  }
  
  /**
   * Returns the class name for a certain entity class.
   */
  public String entityClassName(final DataObject it, final String suffix, final Boolean isBase) {
    String _xblockexpression = null;
    {
      final Application app = it.getApplication();
      String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(app.getVendor());
      String _plus = (_formatForCodeCapital + "\\");
      String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(app.getName());
      String _plus_1 = (_plus + _formatForCodeCapital_1);
      String _plus_2 = (_plus_1 + "Module\\Entity\\");
      String _xifexpression = null;
      if ((isBase).booleanValue()) {
        _xifexpression = "Base\\Abstract";
      } else {
        _xifexpression = "";
      }
      String _plus_3 = (_plus_2 + _xifexpression);
      String _formatForCodeCapital_2 = this._formattingExtensions.formatForCodeCapital(it.getName());
      String _plus_4 = (_plus_3 + _formatForCodeCapital_2);
      String _formatForCodeCapital_3 = this._formattingExtensions.formatForCodeCapital(suffix);
      String _plus_5 = (_plus_4 + _formatForCodeCapital_3);
      _xblockexpression = (_plus_5 + "Entity");
    }
    return _xblockexpression;
  }
  
  /**
   * Returns the doctrine entity manager service name.
   */
  public String entityManagerService(final Application it) {
    return "doctrine.orm.default_entity_manager";
  }
  
  /**
   * Checks whether a certain file path is contained in the blacklist for files to be skipped during generation.
   */
  public boolean shouldBeSkipped(final Application it, final String filePath) {
    return this._generatorSettingsExtensions.getListOfFilesToBeSkipped(it).contains(filePath.replace(this.getAppSourcePath(it), ""));
  }
  
  /**
   * Checks whether a certain file path is contained in the list for files to be marked during generation.
   */
  public boolean shouldBeMarked(final Application it, final String filePath) {
    return this._generatorSettingsExtensions.getListOfFilesToBeMarked(it).contains(filePath.replace(this.getAppSourcePath(it), ""));
  }
  
  /**
   * Generates a base class and an inheriting concrete class with
   * the corresponding content.
   * 
   * @param it              The {@link Application} instance.
   * @param fsa             Given file system access.
   * @param concretePath    Path to concrete class file.
   * @param baseContent     Content for base class file.
   * @param concreteContent Content for concrete class file.
   */
  public void generateClassPair(final Application it, final IFileSystemAccess fsa, final String concretePath, final CharSequence baseContent, final CharSequence concreteContent) {
    String[] basePathParts = concretePath.split("/");
    final String[] _converted_basePathParts = (String[])basePathParts;
    String baseFileName = IterableExtensions.<String>last(((Iterable<String>)Conversions.doWrapArray(_converted_basePathParts)));
    int _length = basePathParts.length;
    int _minus = (_length - 1);
    basePathParts = Arrays.<String>copyOf(basePathParts, _minus);
    ArrayList<String> basePathPartsChangeable = CollectionLiterals.<String>newArrayList(basePathParts);
    basePathPartsChangeable.add("Base");
    basePathPartsChangeable.add(("Abstract" + baseFileName));
    final String basePath = IterableExtensions.join(basePathPartsChangeable, "/");
    boolean _shouldBeSkipped = this.shouldBeSkipped(it, basePath);
    boolean _not = (!_shouldBeSkipped);
    if (_not) {
      boolean _shouldBeMarked = this.shouldBeMarked(it, basePath);
      if (_shouldBeMarked) {
        fsa.generateFile(basePath.replace(".php", ".generated.php"), baseContent);
      } else {
        fsa.generateFile(basePath, baseContent);
      }
    }
    if (((!this._generatorSettingsExtensions.generateOnlyBaseClasses(it)) && (!this.shouldBeSkipped(it, concretePath)))) {
      boolean _shouldBeMarked_1 = this.shouldBeMarked(it, concretePath);
      if (_shouldBeMarked_1) {
        fsa.generateFile(concretePath.replace(".php", ".generated.php"), concreteContent);
      } else {
        fsa.generateFile(concretePath, concreteContent);
      }
    }
  }
  
  /**
   * Returns the base path for the generated application.
   */
  public String getAppSourcePath(final Application it) {
    return "";
  }
  
  /**
   * Returns the relative path to the application's root directory.
   */
  public String relativeAppRootPath(final Application it) {
    String _xifexpression = null;
    boolean _isSystemModule = this._generatorSettingsExtensions.isSystemModule(it);
    if (_isSystemModule) {
      String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(it.getName());
      String _plus = ("system/" + _formatForCodeCapital);
      _xifexpression = (_plus + "Module");
    } else {
      String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(it.getVendor());
      String _plus_1 = ("modules/" + _formatForCodeCapital_1);
      String _plus_2 = (_plus_1 + "/");
      String _formatForCodeCapital_2 = this._formattingExtensions.formatForCodeCapital(it.getName());
      String _plus_3 = (_plus_2 + _formatForCodeCapital_2);
      _xifexpression = (_plus_3 + "Module");
    }
    return _xifexpression;
  }
  
  /**
   * Returns the base path for the source code of the generated application.
   */
  public String getAppSourceLibPath(final Application it) {
    return this.getAppSourcePath(it);
  }
  
  /**
   * Returns the base path for any documentation.
   */
  public String getAppDocPath(final Application it) {
    String _resourcesPath = this.getResourcesPath(it);
    return (_resourcesPath + "docs/");
  }
  
  /**
   * Returns the base path for the licence file.
   */
  public String getAppLicencePath(final Application it) {
    String _resourcesPath = this.getResourcesPath(it);
    return (_resourcesPath + "meta/");
  }
  
  /**
   * Returns the base path for the locale artifacts.
   */
  public String getAppLocalePath(final Application it) {
    String _resourcesPath = this.getResourcesPath(it);
    return (_resourcesPath + "translations/");
  }
  
  /**
   * Returns the base path for any resources.
   */
  public String getResourcesPath(final Application it) {
    String _appSourcePath = this.getAppSourcePath(it);
    return (_appSourcePath + "Resources/");
  }
  
  /**
   * Returns the base path for any assets.
   */
  public String getAssetPath(final Application it) {
    String _resourcesPath = this.getResourcesPath(it);
    return (_resourcesPath + "public/");
  }
  
  /**
   * Returns the base path for all view templates.
   */
  public String getViewPath(final Application it) {
    String _resourcesPath = this.getResourcesPath(it);
    return (_resourcesPath + "views/");
  }
  
  /**
   * Returns the base path for image files.
   */
  public String getAppImagePath(final Application it) {
    String _assetPath = this.getAssetPath(it);
    return (_assetPath + "images/");
  }
  
  /**
   * Returns the base path for css files.
   */
  public String getAppCssPath(final Application it) {
    String _assetPath = this.getAssetPath(it);
    return (_assetPath + "css/");
  }
  
  /**
   * Returns the base path for js files.
   */
  public String getAppJsPath(final Application it) {
    String _assetPath = this.getAssetPath(it);
    return (_assetPath + "js/");
  }
  
  /**
   * Returns the base path for uploaded files of the generated application.
   */
  public String getAppUploadPath(final Application it) {
    String _resourcesPath = this.getResourcesPath(it);
    String _plus = (_resourcesPath + "userdata/");
    String _appName = this._utils.appName(it);
    String _plus_1 = (_plus + _appName);
    return (_plus_1 + "/");
  }
  
  /**
   * Returns the base path for the test source code of the generated application.
   */
  public String getAppTestsPath(final Application it) {
    String _appSourcePath = this.getAppSourcePath(it);
    return (_appSourcePath + "Tests/");
  }
}
