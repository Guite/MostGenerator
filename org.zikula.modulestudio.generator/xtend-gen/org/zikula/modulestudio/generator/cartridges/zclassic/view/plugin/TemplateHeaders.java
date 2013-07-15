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
public class TemplateHeaders {
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
    String _viewPluginFilePath = this._namingExtensions.viewPluginFilePath(it, "function", "TemplateHeaders");
    CharSequence _templateHeadersFile = this.templateHeadersFile(it);
    fsa.generateFile(_viewPluginFilePath, _templateHeadersFile);
  }
  
  private CharSequence templateHeadersFile(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    FileHelper _fileHelper = new FileHelper();
    CharSequence _phpFileHeader = _fileHelper.phpFileHeader(it);
    _builder.append(_phpFileHeader, "");
    _builder.newLineIfNotEmpty();
    CharSequence _templateHeadersImpl = this.templateHeadersImpl(it);
    _builder.append(_templateHeadersImpl, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence templateHeadersImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* The ");
    String _appName = this._utils.appName(it);
    String _formatForDB = this._formattingExtensions.formatForDB(_appName);
    _builder.append(_formatForDB, " ");
    _builder.append("TemplateHeaders plugin performs header() operations");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("* to change the content type provided to the user agent.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Available parameters:");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*   - contentType:  Content type for corresponding http header.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*   - asAttachment: If set to true the file will be offered for downloading.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*   - filename:     Name of download file.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param  array       $params All attributes passed to this function from the template.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param  Zikula_View $view   Reference to the view object.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return boolean false.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("function smarty_function_");
    String _appName_1 = this._utils.appName(it);
    String _formatForDB_1 = this._formattingExtensions.formatForDB(_appName_1);
    _builder.append(_formatForDB_1, "");
    _builder.append("TemplateHeaders($params, $view)");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!isset($params[\'contentType\'])) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$view->trigger_error($view->__f(\'%1$s: missing parameter \\\'%2$s\\\'\', array(\'");
    String _appName_2 = this._utils.appName(it);
    String _formatForDB_2 = this._formattingExtensions.formatForDB(_appName_2);
    _builder.append(_formatForDB_2, "        ");
    _builder.append("TemplateHeaders\', \'contentType\')));");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// apply header");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("header(\'Content-Type: \' . $params[\'contentType\']);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// if desired let the browser offer the given file as a download");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (isset($params[\'asAttachment\']) && $params[\'asAttachment\']");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("&& isset($params[\'filename\']) && !empty($params[\'filename\'])) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("header(\'Content-Disposition: attachment; filename=\' . $params[\'filename\']);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
}
