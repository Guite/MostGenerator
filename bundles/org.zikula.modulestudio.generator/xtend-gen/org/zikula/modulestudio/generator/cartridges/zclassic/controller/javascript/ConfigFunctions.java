package org.zikula.modulestudio.generator.cartridges.zclassic.controller.javascript;

import de.guite.modulestudio.metamodel.Application;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.InputOutput;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class ConfigFunctions {
  @Extension
  private FormattingExtensions _formattingExtensions = new FormattingExtensions();
  
  @Extension
  private NamingExtensions _namingExtensions = new NamingExtensions();
  
  @Extension
  private Utils _utils = new Utils();
  
  /**
   * Entry point for the JavaScript file with display functionality.
   */
  public void generate(final Application it, final IFileSystemAccess fsa) {
    String _appName = this._utils.appName(it);
    String fileName = (_appName + ".Config.js");
    String _appJsPath = this._namingExtensions.getAppJsPath(it);
    String _plus = (_appJsPath + fileName);
    boolean _shouldBeSkipped = this._namingExtensions.shouldBeSkipped(it, _plus);
    boolean _not = (!_shouldBeSkipped);
    if (_not) {
      InputOutput.<String>println("Generating JavaScript for config functions");
      String _appJsPath_1 = this._namingExtensions.getAppJsPath(it);
      String _plus_1 = (_appJsPath_1 + fileName);
      boolean _shouldBeMarked = this._namingExtensions.shouldBeMarked(it, _plus_1);
      if (_shouldBeMarked) {
        String _appName_1 = this._utils.appName(it);
        String _plus_2 = (_appName_1 + ".generated.js");
        fileName = _plus_2;
      }
      String _appJsPath_2 = this._namingExtensions.getAppJsPath(it);
      String _plus_3 = (_appJsPath_2 + fileName);
      fsa.generateFile(_plus_3, this.generate(it));
    }
  }
  
  private CharSequence generate(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("\'use strict\';");
    _builder.newLine();
    _builder.newLine();
    _builder.append("function ");
    String _formatForDB = this._formattingExtensions.formatForDB(it.getPrefix());
    _builder.append(_formatForDB);
    _builder.append("ToggleShrinkSettings(fieldName) {");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("var idSuffix = fieldName.replace(\'");
    String _lowerCase = this._utils.appName(it).toLowerCase();
    _builder.append(_lowerCase, "    ");
    _builder.append("_appsettings_\', \'\');");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("jQuery(\'#shrinkDetails\' + idSuffix).toggleClass(\'hidden\', !jQuery(\'#");
    String _lowerCase_1 = this._utils.appName(it).toLowerCase();
    _builder.append(_lowerCase_1, "    ");
    _builder.append("_appsettings_enableShrinkingFor\' + idSuffix).prop(\'checked\'));");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("jQuery(document).ready(function() {");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("jQuery(\'.shrink-enabler\').each(function (index) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("jQuery(this).bind(\'click keyup\', function (event) {");
    _builder.newLine();
    _builder.append("            ");
    String _formatForDB_1 = this._formattingExtensions.formatForDB(it.getPrefix());
    _builder.append(_formatForDB_1, "            ");
    _builder.append("ToggleShrinkSettings(jQuery(this).attr(\'id\').replace(\'enableShrinkingFor\', \'\'));");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("});");
    _builder.newLine();
    _builder.append("        ");
    String _formatForDB_2 = this._formattingExtensions.formatForDB(it.getPrefix());
    _builder.append(_formatForDB_2, "        ");
    _builder.append("ToggleShrinkSettings(jQuery(this).attr(\'id\').replace(\'enableShrinkingFor\', \'\'));");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("});");
    _builder.newLine();
    _builder.append("});");
    _builder.newLine();
    return _builder;
  }
}
