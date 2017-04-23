package org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin;

import de.guite.modulestudio.metamodel.Application;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class FormatGeoData {
  @Extension
  private FormattingExtensions _formattingExtensions = new FormattingExtensions();
  
  @Extension
  private Utils _utils = new Utils();
  
  public CharSequence generate(final Application it, final IFileSystemAccess fsa) {
    return this.formatGeoDataImpl(it);
  }
  
  private CharSequence formatGeoDataImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* The ");
    String _formatForDB = this._formattingExtensions.formatForDB(this._utils.appName(it));
    _builder.append(_formatForDB, " ");
    _builder.append("_geoData filter formats geo data.");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("* Example:");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*     {{ latitude|");
    String _formatForDB_1 = this._formattingExtensions.formatForDB(this._utils.appName(it));
    _builder.append(_formatForDB_1, " ");
    _builder.append("_geoData }}");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $string The data to be formatted");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return string The formatted output");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function formatGeoData($string)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return number_format($string, 7, \'.\', \'\');");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
}
