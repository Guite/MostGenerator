package org.zikula.modulestudio.generator.cartridges.zclassic.view.pages;

import de.guite.modulestudio.metamodel.Application;
import de.guite.modulestudio.metamodel.DerivedField;
import de.guite.modulestudio.metamodel.Entity;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.InputOutput;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class Delete {
  @Extension
  private FormattingExtensions _formattingExtensions = new FormattingExtensions();
  
  @Extension
  private ModelExtensions _modelExtensions = new ModelExtensions();
  
  @Extension
  private NamingExtensions _namingExtensions = new NamingExtensions();
  
  @Extension
  private Utils _utils = new Utils();
  
  public void generate(final Entity it, final String appName, final IFileSystemAccess fsa) {
    final String templateFilePath = this._namingExtensions.templateFile(it, "delete");
    boolean _shouldBeSkipped = this._namingExtensions.shouldBeSkipped(it.getApplication(), templateFilePath);
    boolean _not = (!_shouldBeSkipped);
    if (_not) {
      String _formatForDisplay = this._formattingExtensions.formatForDisplay(it.getName());
      String _plus = ("Generating delete templates for entity \"" + _formatForDisplay);
      String _plus_1 = (_plus + "\"");
      InputOutput.<String>println(_plus_1);
      fsa.generateFile(templateFilePath, this.deleteView(it, appName));
    }
  }
  
  private CharSequence deleteView(final Entity it, final String appName) {
    StringConcatenation _builder = new StringConcatenation();
    final Application app = it.getApplication();
    _builder.newLineIfNotEmpty();
    _builder.append("{# purpose of this template: ");
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(it.getNameMultiple());
    _builder.append(_formatForDisplay);
    _builder.append(" delete confirmation view #}");
    _builder.newLineIfNotEmpty();
    _builder.append("{% extends routeArea == \'admin\' ? \'");
    String _appName = this._utils.appName(app);
    _builder.append(_appName);
    _builder.append("::adminBase.html.twig\' : \'");
    String _appName_1 = this._utils.appName(app);
    _builder.append(_appName_1);
    _builder.append("::base.html.twig\' %}");
    _builder.newLineIfNotEmpty();
    _builder.append("{% block title __(\'Delete ");
    String _formatForDisplay_1 = this._formattingExtensions.formatForDisplay(it.getName());
    _builder.append(_formatForDisplay_1);
    _builder.append("\') %}");
    _builder.newLineIfNotEmpty();
    _builder.append("{% block admin_page_icon \'trash-o\' %}");
    _builder.newLine();
    _builder.append("{% block content %}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<div class=\"");
    String _lowerCase = appName.toLowerCase();
    _builder.append(_lowerCase, "    ");
    _builder.append("-");
    String _formatForDB = this._formattingExtensions.formatForDB(it.getName());
    _builder.append(_formatForDB, "    ");
    _builder.append(" ");
    String _lowerCase_1 = appName.toLowerCase();
    _builder.append(_lowerCase_1, "    ");
    _builder.append("-delete\">");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("<p class=\"alert alert-warning\">{{ __f(\'Do you really want to delete this ");
    String _formatForDisplay_2 = this._formattingExtensions.formatForDisplay(it.getName());
    _builder.append(_formatForDisplay_2, "        ");
    _builder.append(": \"%name%\" ?\', {\'%name%\': ");
    String _formatForCode = this._formattingExtensions.formatForCode(it.getName());
    _builder.append(_formatForCode, "        ");
    _builder.append(".getTitleFromDisplayPattern()}) }}</p>");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("{% form_theme deleteForm with [");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("\'@");
    _builder.append(appName, "            ");
    _builder.append("/Form/bootstrap_3.html.twig\',");
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    _builder.append("\'ZikulaFormExtensionBundle:Form:form_div_layout.html.twig\'");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("] %}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("{{ form_start(deleteForm) }}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("{{ form_errors(deleteForm) }}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<fieldset>");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("<legend>{{ __(\'Confirmation prompt\') }}</legend>");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("<div class=\"form-group\">");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("<div class=\"col-sm-offset-3 col-sm-9\">");
    _builder.newLine();
    _builder.append("                    ");
    _builder.append("{{ form_widget(deleteForm.delete) }}");
    _builder.newLine();
    _builder.append("                    ");
    _builder.append("{{ form_widget(deleteForm.cancel) }}");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("</div>");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("</div>");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("</fieldset>");
    _builder.newLine();
    {
      boolean _isSkipHookSubscribers = it.isSkipHookSubscribers();
      boolean _not = (!_isSkipHookSubscribers);
      if (_not) {
        _builder.newLine();
        _builder.append("        ");
        _builder.append("{{ block(\'display_hooks\') }}");
        _builder.newLine();
      }
    }
    _builder.append("        ");
    _builder.append("{{ form_end(deleteForm) }}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("</div>");
    _builder.newLine();
    _builder.append("{% endblock %}");
    _builder.newLine();
    {
      boolean _isSkipHookSubscribers_1 = it.isSkipHookSubscribers();
      boolean _not_1 = (!_isSkipHookSubscribers_1);
      if (_not_1) {
        _builder.append("{% block display_hooks %}");
        _builder.newLine();
        _builder.append("    ");
        CharSequence _callDisplayHooks = this.callDisplayHooks(it, appName);
        _builder.append(_callDisplayHooks, "    ");
        _builder.newLineIfNotEmpty();
        _builder.append("{% endblock %}");
        _builder.newLine();
      }
    }
    return _builder;
  }
  
  private CharSequence callDisplayHooks(final Entity it, final String appName) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{% set hooks = notifyDisplayHooks(eventName=\'");
    String _formatForDB = this._formattingExtensions.formatForDB(appName);
    _builder.append(_formatForDB);
    _builder.append(".ui_hooks.");
    String _formatForDB_1 = this._formattingExtensions.formatForDB(it.getNameMultiple());
    _builder.append(_formatForDB_1);
    _builder.append(".form_delete\', id=");
    {
      Iterable<DerivedField> _primaryKeyFields = this._modelExtensions.getPrimaryKeyFields(it);
      boolean _hasElements = false;
      for(final DerivedField pkField : _primaryKeyFields) {
        if (!_hasElements) {
          _hasElements = true;
        } else {
          _builder.appendImmediate(" ~ ", "");
        }
        String _formatForCode = this._formattingExtensions.formatForCode(it.getName());
        _builder.append(_formatForCode);
        _builder.append(".");
        String _formatForCode_1 = this._formattingExtensions.formatForCode(pkField.getName());
        _builder.append(_formatForCode_1);
      }
    }
    _builder.append(") %}");
    _builder.newLineIfNotEmpty();
    _builder.append("{% if hooks is iterable and hooks|length > 0 %}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{% for providerArea, hook in hooks %}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<fieldset>");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("{# <legend>{{ hookName }}</legend> #}");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("{{ hook }}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("</fieldset>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{% endfor %}");
    _builder.newLine();
    _builder.append("{% endif %}");
    _builder.newLine();
    return _builder;
  }
}
