package org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin;

import de.guite.modulestudio.metamodel.Application;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class GetCountryName {
  @Extension
  private FormattingExtensions _formattingExtensions = new FormattingExtensions();
  
  @Extension
  private Utils _utils = new Utils();
  
  public CharSequence generate(final Application it, final IFileSystemAccess fsa) {
    return this.getCountryNameImpl(it);
  }
  
  private CharSequence getCountryNameImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* The ");
    String _formatForDB = this._formattingExtensions.formatForDB(this._utils.appName(it));
    _builder.append(_formatForDB, " ");
    _builder.append("_countryName filter displays the country name for a given country code.");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("* Example:");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*     {{ \'de\'|");
    String _formatForDB_1 = this._formattingExtensions.formatForDB(this._utils.appName(it));
    _builder.append(_formatForDB_1, " ");
    _builder.append("_countryName }}");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $countryCode The country code to process");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return string Country name");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function getCountryName($countryCode)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$result = \\Symfony\\Component\\Intl\\Intl::getRegionBundle()->getCountryName($countryCode);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (false === $result) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$result = $countryCode;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
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
