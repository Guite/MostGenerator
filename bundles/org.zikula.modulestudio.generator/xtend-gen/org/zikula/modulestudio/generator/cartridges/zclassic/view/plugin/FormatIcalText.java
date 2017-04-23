package org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin;

import de.guite.modulestudio.metamodel.Application;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class FormatIcalText {
  @Extension
  private FormattingExtensions _formattingExtensions = new FormattingExtensions();
  
  @Extension
  private Utils _utils = new Utils();
  
  public CharSequence generate(final Application it, final IFileSystemAccess fsa) {
    return this.formatIcalTextImpl(it);
  }
  
  private CharSequence formatIcalTextImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* The ");
    String _formatForDB = this._formattingExtensions.formatForDB(this._utils.appName(it));
    _builder.append(_formatForDB, " ");
    _builder.append("_icalText filter outputs a given text for the ics output format.");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("* Example:");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*     {{ \'someString\'|");
    String _formatForDB_1 = this._formattingExtensions.formatForDB(this._utils.appName(it));
    _builder.append(_formatForDB_1, " ");
    _builder.append("_icalText }}");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $string The given output string");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return string Processed string for ics output");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function formatIcalText($string)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$result = preg_replace(\'/<a href=\"(.*)\">.*<\\/a>/i\', \"$1\", $string);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$result = str_replace(\'€\', \'Euro\', $result);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$result = ereg_replace(\"(\\r\\n|\\n|\\r)\", \'=0D=0A\', $result);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return \';LANGUAGE=\' . $this->request->getLocale() . \';ENCODING=QUOTED-PRINTABLE:\' . $result . \"\\r\\n\";");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
}
