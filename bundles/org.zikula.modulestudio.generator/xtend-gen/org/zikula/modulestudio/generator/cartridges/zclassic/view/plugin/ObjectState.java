package org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin;

import de.guite.modulestudio.metamodel.Application;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class ObjectState {
  @Extension
  private FormattingExtensions _formattingExtensions = new FormattingExtensions();
  
  @Extension
  private Utils _utils = new Utils();
  
  public CharSequence generate(final Application it, final IFileSystemAccess fsa) {
    return this.objectStateImpl(it);
  }
  
  private CharSequence objectStateImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* The ");
    String _formatForDB = this._formattingExtensions.formatForDB(this._utils.appName(it));
    _builder.append(_formatForDB, " ");
    _builder.append("_objectState filter displays the name of a given object\'s workflow state.");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("* Examples:");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*    {{ item.workflowState|");
    String _formatForDB_1 = this._formattingExtensions.formatForDB(this._utils.appName(it));
    _builder.append(_formatForDB_1, " ");
    _builder.append("_objectState }}        {# with visual feedback #}");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*    {{ item.workflowState|");
    String _formatForDB_2 = this._formattingExtensions.formatForDB(this._utils.appName(it));
    _builder.append(_formatForDB_2, " ");
    _builder.append("_objectState(false) }} {# no ui feedback #}");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string  $state      Name of given workflow state");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param boolean $uiFeedback Whether the output should include some visual feedback about the state");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return string Enriched and translated workflow state ready for display");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function getObjectState($state = \'initial\', $uiFeedback = true)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$stateInfo = $this->workflowHelper->getStateInfo($state);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$result = $stateInfo[\'text\'];");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (true === $uiFeedback) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$result = \'<span class=\"label label-\' . $stateInfo[\'ui\'] . \'\">\' . $result . \'</span>\';");
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
