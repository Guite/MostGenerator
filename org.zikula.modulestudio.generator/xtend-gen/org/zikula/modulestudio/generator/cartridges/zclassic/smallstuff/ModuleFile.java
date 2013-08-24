package org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff;

import com.google.inject.Inject;
import de.guite.modulestudio.metamodel.modulestudio.Application;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class ModuleFile {
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
  
  public void generate(final Application it, final IFileSystemAccess fsa) {
    boolean _targets = this._utils.targets(it, "1.3.5");
    if (_targets) {
      return;
    }
    String _appName = this._utils.appName(it);
    final String moduleFileName = (_appName + ".php");
    String _appSourceLibPath = this._namingExtensions.getAppSourceLibPath(it);
    String _plus = (_appSourceLibPath + "Base/");
    String _plus_1 = (_plus + moduleFileName);
    CharSequence _moduleBaseFile = this.moduleBaseFile(it);
    fsa.generateFile(_plus_1, _moduleBaseFile);
    String _appSourceLibPath_1 = this._namingExtensions.getAppSourceLibPath(it);
    String _plus_2 = (_appSourceLibPath_1 + moduleFileName);
    CharSequence _moduleFile = this.moduleFile(it);
    fsa.generateFile(_plus_2, _moduleFile);
  }
  
  private CharSequence moduleBaseFile(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _phpFileHeader = this.fh.phpFileHeader(it);
    _builder.append(_phpFileHeader, "");
    _builder.newLineIfNotEmpty();
    CharSequence _moduleBaseImpl = this.moduleBaseImpl(it);
    _builder.append(_moduleBaseImpl, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence moduleFile(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _phpFileHeader = this.fh.phpFileHeader(it);
    _builder.append(_phpFileHeader, "");
    _builder.newLineIfNotEmpty();
    CharSequence _moduleInfoImpl = this.moduleInfoImpl(it);
    _builder.append(_moduleInfoImpl, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence moduleBaseImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("namespace ");
    String _appNamespace = this._utils.appNamespace(it);
    _builder.append(_appNamespace, "");
    _builder.append("\\Base;");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("use Zikula\\Core\\AbstractModule;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Module base class.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("class ");
    String _appName = this._utils.appName(it);
    _builder.append(_appName, "");
    _builder.append(" extends AbstractModule");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence moduleInfoImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("namespace ");
    String _appNamespace = this._utils.appNamespace(it);
    _builder.append(_appNamespace, "");
    _builder.append(";");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Module implementation class.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("class ");
    String _appName = this._utils.appName(it);
    _builder.append(_appName, "");
    _builder.append(" extends Base\\");
    String _appName_1 = this._utils.appName(it);
    _builder.append(_appName_1, "");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// custom enhancements can go here");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
}
