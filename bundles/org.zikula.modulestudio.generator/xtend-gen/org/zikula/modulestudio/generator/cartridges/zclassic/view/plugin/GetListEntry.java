package org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin;

import de.guite.modulestudio.metamodel.Application;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class GetListEntry {
  @Extension
  private FormattingExtensions _formattingExtensions = new FormattingExtensions();
  
  @Extension
  private Utils _utils = new Utils();
  
  public CharSequence generate(final Application it, final IFileSystemAccess fsa) {
    return this.getListEntryImpl(it);
  }
  
  private CharSequence getListEntryImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* The ");
    String _formatForDB = this._formattingExtensions.formatForDB(this._utils.appName(it));
    _builder.append(_formatForDB, " ");
    _builder.append("_listEntry filter displays the name");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("* or names for a given list item.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Example:");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*     {{ entity.listField|");
    String _formatForDB_1 = this._formattingExtensions.formatForDB(this._utils.appName(it));
    _builder.append(_formatForDB_1, " ");
    _builder.append("_listEntry(\'entityName\', \'fieldName\') }}");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $value      The dropdown value to process");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $objectType The treated object type");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $fieldName  The list field\'s name");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $delimiter  String used as separator for multiple selections");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return string List item name");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function getListEntry($value, $objectType = \'\', $fieldName = \'\', $delimiter = \', \')");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ((empty($value) && $value != \'0\') || empty($objectType) || empty($fieldName)) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return $value;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $this->listHelper->resolve($value, $objectType, $fieldName, $delimiter);");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
}
