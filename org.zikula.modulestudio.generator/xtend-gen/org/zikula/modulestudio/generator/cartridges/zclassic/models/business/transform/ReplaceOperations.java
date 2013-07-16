package org.zikula.modulestudio.generator.cartridges.zclassic.models.business.transform;

import de.guite.modulestudio.metamodel.modulestudio.ReplaceGermanSpecialChars;
import org.eclipse.xtend2.lib.StringConcatenation;

@SuppressWarnings("all")
public class ReplaceOperations {
  public CharSequence Function(final ReplaceGermanSpecialChars it, final String src, final String dest) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("// This method is used to transform data acquired from input");
    _builder.newLine();
    _builder.append("// in such a way that only 7-bit ASCII characters remain. ");
    _builder.newLine();
    _builder.newLine();
    _builder.append("// initialize transformation parameters");
    _builder.newLine();
    _builder.append("$special1 = \'\u00C4\u00D6\u00DC\u00E4\u00F6\u00FC\u00DF\';");
    _builder.newLine();
    _builder.append("$special2 = \'AOUaous\';");
    _builder.newLine();
    _builder.newLine();
    _builder.append("// now perform our transformation ");
    _builder.newLine();
    _builder.append("$obj[\'");
    _builder.append(dest, "");
    _builder.append("\'] = strtr($obj[\'");
    _builder.append(src, "");
    _builder.append("\'], $special1, $special2);");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
}
