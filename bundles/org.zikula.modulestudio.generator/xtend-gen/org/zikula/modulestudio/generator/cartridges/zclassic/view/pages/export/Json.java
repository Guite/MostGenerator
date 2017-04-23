package org.zikula.modulestudio.generator.cartridges.zclassic.view.pages.export;

import de.guite.modulestudio.metamodel.Entity;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.InputOutput;
import org.zikula.modulestudio.generator.extensions.ControllerExtensions;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;

@SuppressWarnings("all")
public class Json {
  @Extension
  private ControllerExtensions _controllerExtensions = new ControllerExtensions();
  
  @Extension
  private FormattingExtensions _formattingExtensions = new FormattingExtensions();
  
  @Extension
  private NamingExtensions _namingExtensions = new NamingExtensions();
  
  public void generate(final Entity it, final String appName, final IFileSystemAccess fsa) {
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(it.getName());
    String _plus = ("Generating json view templates for entity \"" + _formatForDisplay);
    String _plus_1 = (_plus + "\"");
    InputOutput.<String>println(_plus_1);
    String templateFilePath = "";
    boolean _hasViewAction = this._controllerExtensions.hasViewAction(it);
    if (_hasViewAction) {
      templateFilePath = this._namingExtensions.templateFileWithExtension(it, "view", "json");
      boolean _shouldBeSkipped = this._namingExtensions.shouldBeSkipped(it.getApplication(), templateFilePath);
      boolean _not = (!_shouldBeSkipped);
      if (_not) {
        fsa.generateFile(templateFilePath, this.jsonView(it, appName));
      }
    }
    boolean _hasDisplayAction = this._controllerExtensions.hasDisplayAction(it);
    if (_hasDisplayAction) {
      templateFilePath = this._namingExtensions.templateFileWithExtension(it, "display", "json");
      boolean _shouldBeSkipped_1 = this._namingExtensions.shouldBeSkipped(it.getApplication(), templateFilePath);
      boolean _not_1 = (!_shouldBeSkipped_1);
      if (_not_1) {
        fsa.generateFile(templateFilePath, this.jsonDisplay(it, appName));
      }
    }
  }
  
  private CharSequence jsonView(final Entity it, final String appName) {
    StringConcatenation _builder = new StringConcatenation();
    final String objName = this._formattingExtensions.formatForCode(it.getName());
    _builder.newLineIfNotEmpty();
    _builder.append("{# purpose of this template: ");
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(it.getNameMultiple());
    _builder.append(_formatForDisplay);
    _builder.append(" view json view #}");
    _builder.newLineIfNotEmpty();
    _builder.append("[");
    _builder.newLine();
    _builder.append("{% for ");
    _builder.append(objName);
    _builder.append(" in items %}");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("{% if not loop.first %},{% endif %}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{{ ");
    _builder.append(objName, "    ");
    _builder.append(".toJson() }}");
    _builder.newLineIfNotEmpty();
    _builder.append("{% endfor %}");
    _builder.newLine();
    _builder.append("]");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence jsonDisplay(final Entity it, final String appName) {
    StringConcatenation _builder = new StringConcatenation();
    final String objName = this._formattingExtensions.formatForCode(it.getName());
    _builder.newLineIfNotEmpty();
    _builder.append("{# purpose of this template: ");
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(it.getNameMultiple());
    _builder.append(_formatForDisplay);
    _builder.append(" display json view #}");
    _builder.newLineIfNotEmpty();
    _builder.append("{{ ");
    _builder.append(objName);
    _builder.append(".toJson() }}");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
}
