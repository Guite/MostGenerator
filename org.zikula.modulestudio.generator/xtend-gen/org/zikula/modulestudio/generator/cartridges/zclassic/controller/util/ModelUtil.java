package org.zikula.modulestudio.generator.cartridges.zclassic.controller.util;

import com.google.inject.Inject;
import de.guite.modulestudio.metamodel.modulestudio.Application;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.eclipse.xtext.xbase.lib.InputOutput;
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class ModelUtil {
  @Inject
  @Extension
  private NamingExtensions _namingExtensions = new Function0<NamingExtensions>() {
    public NamingExtensions apply() {
      NamingExtensions _namingExtensions = new NamingExtensions();
      return _namingExtensions;
    }
  }.apply();
  
  @Inject
  @Extension
  private Utils _utils = new Function0<Utils>() {
    public Utils apply() {
      Utils _utils = new Utils();
      return _utils;
    }
  }.apply();
  
  private FileHelper fh = new Function0<FileHelper>() {
    public FileHelper apply() {
      FileHelper _fileHelper = new FileHelper();
      return _fileHelper;
    }
  }.apply();
  
  /**
   * Entry point for the utility class creation.
   */
  public void generate(final Application it, final IFileSystemAccess fsa) {
    InputOutput.<String>println("Generating utility class for model layer");
    String _appSourceLibPath = this._namingExtensions.getAppSourceLibPath(it);
    final String utilPath = (_appSourceLibPath + "Util/");
    String _xifexpression = null;
    boolean _targets = this._utils.targets(it, "1.3.5");
    if (_targets) {
      _xifexpression = "";
    } else {
      _xifexpression = "Util";
    }
    final String utilSuffix = _xifexpression;
    String _plus = (utilPath + "Base/Model");
    String _plus_1 = (_plus + utilSuffix);
    String _plus_2 = (_plus_1 + ".php");
    CharSequence _modelFunctionsBaseFile = this.modelFunctionsBaseFile(it);
    fsa.generateFile(_plus_2, _modelFunctionsBaseFile);
    String _plus_3 = (utilPath + "Model");
    String _plus_4 = (_plus_3 + utilSuffix);
    String _plus_5 = (_plus_4 + ".php");
    CharSequence _modelFunctionsFile = this.modelFunctionsFile(it);
    fsa.generateFile(_plus_5, _modelFunctionsFile);
  }
  
  private CharSequence modelFunctionsBaseFile(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _phpFileHeader = this.fh.phpFileHeader(it);
    _builder.append(_phpFileHeader, "");
    _builder.newLineIfNotEmpty();
    CharSequence _modelFunctionsBaseImpl = this.modelFunctionsBaseImpl(it);
    _builder.append(_modelFunctionsBaseImpl, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence modelFunctionsFile(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _phpFileHeader = this.fh.phpFileHeader(it);
    _builder.append(_phpFileHeader, "");
    _builder.newLineIfNotEmpty();
    CharSequence _modelFunctionsImpl = this.modelFunctionsImpl(it);
    _builder.append(_modelFunctionsImpl, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence modelFunctionsBaseImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _targets = this._utils.targets(it, "1.3.5");
      boolean _not = (!_targets);
      if (_not) {
        _builder.append("namespace ");
        String _appNamespace = this._utils.appNamespace(it);
        _builder.append(_appNamespace, "");
        _builder.append("\\Util\\Base;");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
        _builder.append("use Zikula_AbstractBase;");
        _builder.newLine();
        _builder.newLine();
      }
    }
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Utility base class for model helper methods.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("class ");
    {
      boolean _targets_1 = this._utils.targets(it, "1.3.5");
      if (_targets_1) {
        String _appName = this._utils.appName(it);
        _builder.append(_appName, "");
        _builder.append("_Util_Base_Model");
      } else {
        _builder.append("ModelUtil");
      }
    }
    _builder.append(" extends Zikula_AbstractBase");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence modelFunctionsImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _targets = this._utils.targets(it, "1.3.5");
      boolean _not = (!_targets);
      if (_not) {
        _builder.append("namespace ");
        String _appNamespace = this._utils.appNamespace(it);
        _builder.append(_appNamespace, "");
        _builder.append("\\Util;");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
        _builder.append("use ");
        String _appNamespace_1 = this._utils.appNamespace(it);
        _builder.append(_appNamespace_1, "");
        _builder.append("\\Util\\Base\\ModelUtil as BaseModelUtil;");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
      }
    }
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Utility implementation class for model helper methods.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    {
      boolean _targets_1 = this._utils.targets(it, "1.3.5");
      if (_targets_1) {
        _builder.append("class ");
        String _appName = this._utils.appName(it);
        _builder.append(_appName, "");
        _builder.append("_Util_Model extends ");
        String _appName_1 = this._utils.appName(it);
        _builder.append(_appName_1, "");
        _builder.append("_Util_Base_Model");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("class ModelUtil extends BaseModelUtil");
        _builder.newLine();
      }
    }
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// feel free to add your own convenience methods here");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
}
