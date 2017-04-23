package org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin;

import de.guite.modulestudio.metamodel.Application;
import de.guite.modulestudio.metamodel.EntityWorkflowType;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;
import org.zikula.modulestudio.generator.extensions.WorkflowExtensions;

@SuppressWarnings("all")
public class ModerationObjects {
  @Extension
  private FormattingExtensions _formattingExtensions = new FormattingExtensions();
  
  @Extension
  private Utils _utils = new Utils();
  
  @Extension
  private WorkflowExtensions _workflowExtensions = new WorkflowExtensions();
  
  public CharSequence generate(final Application it, final IFileSystemAccess fsa) {
    return this.moderationObjectsImpl(it);
  }
  
  private CharSequence moderationObjectsImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* The ");
    String _formatForDB = this._formattingExtensions.formatForDB(this._utils.appName(it));
    _builder.append(_formatForDB, " ");
    _builder.append("_moderationObjects function determines the amount of ");
    {
      boolean _hasWorkflow = this._workflowExtensions.hasWorkflow(it, EntityWorkflowType.ENTERPRISE);
      if (_hasWorkflow) {
        _builder.append("unaccepted and ");
      }
    }
    _builder.append("unapproved objects.");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("* It uses the same logic as the moderation block and the pending content listener.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return string The output of the plugin");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function getModerationObjects()");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $this->workflowHelper->collectAmountOfModerationItems();");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
}
