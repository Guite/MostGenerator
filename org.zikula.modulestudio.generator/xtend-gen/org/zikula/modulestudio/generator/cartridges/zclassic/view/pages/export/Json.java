package org.zikula.modulestudio.generator.cartridges.zclassic.view.pages.export;

import com.google.inject.Inject;
import de.guite.modulestudio.metamodel.modulestudio.Controller;
import de.guite.modulestudio.metamodel.modulestudio.Entity;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.eclipse.xtext.xbase.lib.InputOutput;
import org.zikula.modulestudio.generator.extensions.ControllerExtensions;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;

@SuppressWarnings("all")
public class Json {
  @Inject
  @Extension
  private ControllerExtensions _controllerExtensions = new Function0<ControllerExtensions>() {
    public ControllerExtensions apply() {
      ControllerExtensions _controllerExtensions = new ControllerExtensions();
      return _controllerExtensions;
    }
  }.apply();
  
  @Inject
  @Extension
  private FormattingExtensions _formattingExtensions = new Function0<FormattingExtensions>() {
    public FormattingExtensions apply() {
      FormattingExtensions _formattingExtensions = new FormattingExtensions();
      return _formattingExtensions;
    }
  }.apply();
  
  @Inject
  @Extension
  private NamingExtensions _namingExtensions = new Function0<NamingExtensions>() {
    public NamingExtensions apply() {
      NamingExtensions _namingExtensions = new NamingExtensions();
      return _namingExtensions;
    }
  }.apply();
  
  public void generate(final Entity it, final String appName, final Controller controller, final IFileSystemAccess fsa) {
    String _formattedName = this._controllerExtensions.formattedName(controller);
    String _plus = ("Generating " + _formattedName);
    String _plus_1 = (_plus + " json view templates for entity \"");
    String _name = it.getName();
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(_name);
    String _plus_2 = (_plus_1 + _formatForDisplay);
    String _plus_3 = (_plus_2 + "\"");
    InputOutput.<String>println(_plus_3);
    boolean _hasActions = this._controllerExtensions.hasActions(controller, "view");
    if (_hasActions) {
      String _name_1 = it.getName();
      String _templateFileWithExtension = this._namingExtensions.templateFileWithExtension(controller, _name_1, "view", "json");
      CharSequence _jsonView = this.jsonView(it, appName, controller);
      fsa.generateFile(_templateFileWithExtension, _jsonView);
    }
    boolean _hasActions_1 = this._controllerExtensions.hasActions(controller, "display");
    if (_hasActions_1) {
      String _name_2 = it.getName();
      String _templateFileWithExtension_1 = this._namingExtensions.templateFileWithExtension(controller, _name_2, "display", "json");
      CharSequence _jsonDisplay = this.jsonDisplay(it, appName, controller);
      fsa.generateFile(_templateFileWithExtension_1, _jsonDisplay);
    }
  }
  
  private CharSequence jsonView(final Entity it, final String appName, final Controller controller) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{* purpose of this template: ");
    String _nameMultiple = it.getNameMultiple();
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(_nameMultiple);
    _builder.append(_formatForDisplay, "");
    _builder.append(" view json view in ");
    String _formattedName = this._controllerExtensions.formattedName(controller);
    _builder.append(_formattedName, "");
    _builder.append(" area *}");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    String _formatForDB = this._formattingExtensions.formatForDB(appName);
    _builder.append(_formatForDB, "");
    _builder.append("TemplateHeaders contentType=\'application/json\'}");
    _builder.newLineIfNotEmpty();
    _builder.append("[");
    _builder.newLine();
    _builder.append("{foreach item=\'item\' from=$items name=\'");
    String _nameMultiple_1 = it.getNameMultiple();
    String _formatForCode = this._formattingExtensions.formatForCode(_nameMultiple_1);
    _builder.append(_formatForCode, "");
    _builder.append("\'}");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("{if not $smarty.foreach.");
    String _nameMultiple_2 = it.getNameMultiple();
    String _formatForCode_1 = this._formattingExtensions.formatForCode(_nameMultiple_2);
    _builder.append(_formatForCode_1, "    ");
    _builder.append(".first},{/if}");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("{$item->toJson()}");
    _builder.newLine();
    _builder.append("{/foreach}");
    _builder.newLine();
    _builder.append("]");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence jsonDisplay(final Entity it, final String appName, final Controller controller) {
    StringConcatenation _builder = new StringConcatenation();
    String _name = it.getName();
    final String objName = this._formattingExtensions.formatForCode(_name);
    _builder.newLineIfNotEmpty();
    _builder.append("{* purpose of this template: ");
    String _nameMultiple = it.getNameMultiple();
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(_nameMultiple);
    _builder.append(_formatForDisplay, "");
    _builder.append(" display json view in ");
    String _formattedName = this._controllerExtensions.formattedName(controller);
    _builder.append(_formattedName, "");
    _builder.append(" area *}");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    String _formatForDB = this._formattingExtensions.formatForDB(appName);
    _builder.append(_formatForDB, "");
    _builder.append("TemplateHeaders contentType=\'application/json\'}");
    _builder.newLineIfNotEmpty();
    _builder.append("{$");
    _builder.append(objName, "");
    _builder.append("->toJson()}");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
}
