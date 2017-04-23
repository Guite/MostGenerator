package org.zikula.modulestudio.generator.cartridges.zclassic.view.additions;

import de.guite.modulestudio.metamodel.Application;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class BlockModerationView {
  @Extension
  private FormattingExtensions _formattingExtensions = new FormattingExtensions();
  
  @Extension
  private NamingExtensions _namingExtensions = new NamingExtensions();
  
  @Extension
  private Utils _utils = new Utils();
  
  public void generate(final Application it, final IFileSystemAccess fsa) {
    String _viewPath = this._namingExtensions.getViewPath(it);
    final String templatePath = (_viewPath + "Block/");
    String fileName = "moderation.html.twig";
    boolean _shouldBeSkipped = this._namingExtensions.shouldBeSkipped(it, (templatePath + fileName));
    boolean _not = (!_shouldBeSkipped);
    if (_not) {
      boolean _shouldBeMarked = this._namingExtensions.shouldBeMarked(it, (templatePath + fileName));
      if (_shouldBeMarked) {
        fileName = "moderation.generated.html.twig";
      }
      fsa.generateFile((templatePath + fileName), this.displayTemplate(it));
    }
  }
  
  private CharSequence displayTemplate(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{# Purpose of this template: show moderation block #}");
    _builder.newLine();
    _builder.append("{% if moderationObjects|length > 0 %}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<ul>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{% for modItem in moderationObjects %}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("{% set itemObjectType = modItem.objectType|lower %}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<li><a href=\"{{ path(\'");
    String _formatForDB = this._formattingExtensions.formatForDB(this._utils.appName(it));
    _builder.append(_formatForDB, "        ");
    _builder.append("_\' ~ itemObjectType ~ \'_adminview\', { workflowState: modItem.state }) }}\" class=\"bold\">{{ modItem.message }}</a></li>");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("{% endfor %}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("</ul>");
    _builder.newLine();
    _builder.append("{% endif %}");
    _builder.newLine();
    return _builder;
  }
}
