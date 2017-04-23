package org.zikula.modulestudio.generator.cartridges.zclassic.view.extensions;

import de.guite.modulestudio.metamodel.Application;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.GeneratorSettingsExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;
import org.zikula.modulestudio.generator.extensions.WorkflowExtensions;

@SuppressWarnings("all")
public class ModerationPanel {
  @Extension
  private FormattingExtensions _formattingExtensions = new FormattingExtensions();
  
  @Extension
  private GeneratorSettingsExtensions _generatorSettingsExtensions = new GeneratorSettingsExtensions();
  
  @Extension
  private NamingExtensions _namingExtensions = new NamingExtensions();
  
  @Extension
  private Utils _utils = new Utils();
  
  @Extension
  private WorkflowExtensions _workflowExtensions = new WorkflowExtensions();
  
  public void generate(final Application it, final IFileSystemAccess fsa) {
    boolean _not = (!(this._generatorSettingsExtensions.generateModerationPanel(it) && this._workflowExtensions.needsApproval(it)));
    if (_not) {
      return;
    }
    String _viewPath = this._namingExtensions.getViewPath(it);
    final String templatePath = (_viewPath + "Helper/");
    final String templateExtension = ".html.twig";
    String fileName = ("includeModerationPanel" + templateExtension);
    boolean _shouldBeSkipped = this._namingExtensions.shouldBeSkipped(it, (templatePath + fileName));
    boolean _not_1 = (!_shouldBeSkipped);
    if (_not_1) {
      boolean _shouldBeMarked = this._namingExtensions.shouldBeMarked(it, (templatePath + fileName));
      if (_shouldBeMarked) {
        fileName = ("includeModerationPanel.generated" + templateExtension);
      }
      fsa.generateFile((templatePath + fileName), this.moderationPanelImpl(it));
    }
  }
  
  private CharSequence moderationPanelImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{# purpose of this template: show amount of pending items to moderators #}");
    _builder.newLine();
    _builder.append("{% if not app.request.query.getBoolean(\'raw\', false) %}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{% set moderationObjects = ");
    String _formatForDB = this._formattingExtensions.formatForDB(this._utils.appName(it));
    _builder.append(_formatForDB, "    ");
    _builder.append("_moderationObjects() %}");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("{% if moderationObjects|length > 0 %}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("{% for modItem in moderationObjects %}");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("<p class=\"alert alert-info alert-dismissable text-center\">");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("<button type=\"button\" class=\"close\" data-dismiss=\"alert\" aria-hidden=\"true\">&times;</button>");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("{% set itemObjectType = modItem.objectType|lower %}");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("<a href=\"{{ path(\'");
    String _formatForDB_1 = this._formattingExtensions.formatForDB(this._utils.appName(it));
    _builder.append(_formatForDB_1, "                ");
    _builder.append("_\' ~ itemObjectType ~ \'_adminview\', { workflowState: modItem.state }) }}\" class=\"bold alert-link\">{{ modItem.message }}</a>");
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    _builder.append("</p>");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("{% endfor %}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{% endif %}");
    _builder.newLine();
    _builder.append("{% endif %}");
    _builder.newLine();
    return _builder;
  }
}
