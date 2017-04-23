package org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff;

import de.guite.modulestudio.metamodel.Application;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper;
import org.zikula.modulestudio.generator.extensions.GeneratorSettingsExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class ModuleFile {
  @Extension
  private GeneratorSettingsExtensions _generatorSettingsExtensions = new GeneratorSettingsExtensions();
  
  @Extension
  private NamingExtensions _namingExtensions = new NamingExtensions();
  
  @Extension
  private Utils _utils = new Utils();
  
  private FileHelper fh = new FileHelper();
  
  public void generate(final Application it, final IFileSystemAccess fsa) {
    String _appSourceLibPath = this._namingExtensions.getAppSourceLibPath(it);
    String _appName = this._utils.appName(it);
    String _plus = (_appSourceLibPath + _appName);
    String _plus_1 = (_plus + ".php");
    this._namingExtensions.generateClassPair(it, fsa, _plus_1, 
      this.fh.phpFileContent(it, this.moduleBaseClass(it)), this.fh.phpFileContent(it, this.moduleInfoImpl(it)));
  }
  
  private CharSequence moduleBaseClass(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      if ((this._generatorSettingsExtensions.generateListContentType(it) || this._generatorSettingsExtensions.generateDetailContentType(it))) {
        _builder.append("namespace ");
        String _appNamespace = this._utils.appNamespace(it);
        _builder.append(_appNamespace);
        _builder.append("\\Base {");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
        _builder.append("    ");
        CharSequence _moduleBaseImpl = this.moduleBaseImpl(it);
        _builder.append(_moduleBaseImpl, "    ");
        _builder.newLineIfNotEmpty();
        _builder.append("}");
        _builder.newLine();
        _builder.newLine();
        _builder.append("namespace {");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("if (!class_exists(\'Content_AbstractContentType\')) {");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("if (file_exists(\'modules/Content/lib/Content/AbstractContentType.php\')) {");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("require_once \'modules/Content/lib/Content/AbstractType.php\';");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("require_once \'modules/Content/lib/Content/AbstractContentType.php\';");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("} else {");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("class Content_AbstractContentType {}");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
        _builder.newLine();
        {
          boolean _generateListContentType = this._generatorSettingsExtensions.generateListContentType(it);
          if (_generateListContentType) {
            _builder.append("    ");
            _builder.append("class ");
            String _appName = this._utils.appName(it);
            _builder.append(_appName, "    ");
            _builder.append("_ContentType_ItemList extends \\");
            String _appNamespace_1 = this._utils.appNamespace(it);
            _builder.append(_appNamespace_1, "    ");
            _builder.append("\\ContentType\\ItemList {");
            _builder.newLineIfNotEmpty();
            _builder.append("    ");
            _builder.append("}");
            _builder.newLine();
          }
        }
        {
          boolean _generateDetailContentType = this._generatorSettingsExtensions.generateDetailContentType(it);
          if (_generateDetailContentType) {
            _builder.append("    ");
            _builder.append("class ");
            String _appName_1 = this._utils.appName(it);
            _builder.append(_appName_1, "    ");
            _builder.append("_ContentType_Item extends \\");
            String _appNamespace_2 = this._utils.appNamespace(it);
            _builder.append(_appNamespace_2, "    ");
            _builder.append("\\ContentType\\Item {");
            _builder.newLineIfNotEmpty();
            _builder.append("    ");
            _builder.append("}");
            _builder.newLine();
          }
        }
        _builder.append("}");
        _builder.newLine();
      } else {
        _builder.append("namespace ");
        String _appNamespace_3 = this._utils.appNamespace(it);
        _builder.append(_appNamespace_3);
        _builder.append("\\Base;");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
        CharSequence _moduleBaseImpl_1 = this.moduleBaseImpl(it);
        _builder.append(_moduleBaseImpl_1);
        _builder.newLineIfNotEmpty();
      }
    }
    return _builder;
  }
  
  private CharSequence moduleBaseImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _isSystemModule = this._generatorSettingsExtensions.isSystemModule(it);
      if (_isSystemModule) {
        _builder.append("use Zikula\\Bundle\\CoreBundle\\Bundle\\AbstractCoreModule;");
        _builder.newLine();
      } else {
        _builder.append("use Zikula\\Core\\AbstractModule;");
        _builder.newLine();
      }
    }
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Module base class.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("abstract class Abstract");
    String _appName = this._utils.appName(it);
    _builder.append(_appName);
    _builder.append(" extends Abstract");
    {
      boolean _isSystemModule_1 = this._generatorSettingsExtensions.isSystemModule(it);
      if (_isSystemModule_1) {
        _builder.append("Core");
      }
    }
    _builder.append("Module");
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
    _builder.append(_appNamespace);
    _builder.append(";");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("use ");
    String _appNamespace_1 = this._utils.appNamespace(it);
    _builder.append(_appNamespace_1);
    _builder.append("\\Base\\Abstract");
    String _appName = this._utils.appName(it);
    _builder.append(_appName);
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
    String _appName_1 = this._utils.appName(it);
    _builder.append(_appName_1);
    _builder.append(" extends Abstract");
    String _appName_2 = this._utils.appName(it);
    _builder.append(_appName_2);
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
