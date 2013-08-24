package org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin;

import com.google.inject.Inject;
import de.guite.modulestudio.metamodel.modulestudio.Application;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class GetFileSize {
  @Inject
  @Extension
  private FormattingExtensions _formattingExtensions = new Function0<FormattingExtensions>() {
    public FormattingExtensions apply() {
      FormattingExtensions _formattingExtensions = new FormattingExtensions();
      return _formattingExtensions;
    }
  }.apply();
  
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
  
  public void generate(final Application it, final IFileSystemAccess fsa) {
    String _viewPluginFilePath = this._namingExtensions.viewPluginFilePath(it, "modifier", "GetFileSize");
    CharSequence _fileSizeFile = this.getFileSizeFile(it);
    fsa.generateFile(_viewPluginFilePath, _fileSizeFile);
  }
  
  private CharSequence getFileSizeFile(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    FileHelper _fileHelper = new FileHelper();
    CharSequence _phpFileHeader = _fileHelper.phpFileHeader(it);
    _builder.append(_phpFileHeader, "");
    _builder.newLineIfNotEmpty();
    CharSequence _fileSizeImpl = this.getFileSizeImpl(it);
    _builder.append(_fileSizeImpl, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence getFileSizeImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* The ");
    String _appName = this._utils.appName(it);
    String _formatForDB = this._formattingExtensions.formatForDB(_appName);
    _builder.append(_formatForDB, " ");
    _builder.append("GetFileSize modifier displays the size of a given file in a readable way.");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param integer $size     File size in bytes.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string  $filepath The input file path including file name (if file size is not known).");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param boolean $nodesc   If set to true the description will not be appended.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param boolean $onlydesc If set to true only the description will be returned.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return string File size in a readable form.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("function smarty_modifier_");
    String _appName_1 = this._utils.appName(it);
    String _formatForDB_1 = this._formattingExtensions.formatForDB(_appName_1);
    _builder.append(_formatForDB_1, "");
    _builder.append("GetFileSize($size = 0, $filepath = \'\', $nodesc = false, $onlydesc = false)");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!is_numeric($size)) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$size = (int) $size;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!$size) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if (empty($filepath) || !file_exists($filepath)) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("return \'\';");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$size = filesize($filepath);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!$size) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return \'\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$serviceManager = ServiceUtil::getManager();");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$viewHelper = new ");
    String _appName_2 = this._utils.appName(it);
    _builder.append(_appName_2, "    ");
    {
      boolean _targets = this._utils.targets(it, "1.3.5");
      if (_targets) {
        _builder.append("_Util_View");
      } else {
        _builder.append("\\Util\\ViewUtil");
      }
    }
    _builder.append("($serviceManager");
    {
      boolean _targets_1 = this._utils.targets(it, "1.3.5");
      boolean _not = (!_targets_1);
      if (_not) {
        _builder.append(", ModUtil::getModule(\'");
        String _appName_3 = this._utils.appName(it);
        _builder.append(_appName_3, "    ");
        _builder.append("\')");
      }
    }
    _builder.append(");");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("$result = $viewHelper->getReadableFileSize($size, $nodesc, $onlydesc);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $result;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
}
