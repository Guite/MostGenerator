package org.zikula.modulestudio.generator.cartridges.zclassic.view.pages;

import de.guite.modulestudio.metamodel.Application;
import de.guite.modulestudio.metamodel.Entity;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.InputOutput;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class Index {
  @Extension
  private FormattingExtensions _formattingExtensions = new FormattingExtensions();
  
  @Extension
  private NamingExtensions _namingExtensions = new NamingExtensions();
  
  @Extension
  private Utils _utils = new Utils();
  
  private Application app;
  
  public void generate(final Entity it, final IFileSystemAccess fsa) {
    this.app = it.getApplication();
    final String pageName = "index";
    final String templateExtension = ".html.twig";
    final Application app = it.getApplication();
    String _viewPath = this._namingExtensions.getViewPath(app);
    String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(it.getName());
    String _plus = (_viewPath + _formatForCodeCapital);
    final String templatePath = (_plus + "/");
    String fileName = (pageName + templateExtension);
    boolean _shouldBeSkipped = this._namingExtensions.shouldBeSkipped(app, (templatePath + fileName));
    boolean _not = (!_shouldBeSkipped);
    if (_not) {
      String _formatForDisplay = this._formattingExtensions.formatForDisplay(it.getName());
      String _plus_1 = ((("Generating " + pageName) + " templates for entity \"") + _formatForDisplay);
      String _plus_2 = (_plus_1 + "\"");
      InputOutput.<String>println(_plus_2);
      boolean _shouldBeMarked = this._namingExtensions.shouldBeMarked(app, (templatePath + fileName));
      if (_shouldBeMarked) {
        fileName = ((pageName + ".generated") + templateExtension);
      }
      fsa.generateFile((templatePath + fileName), this.indexView(it, pageName));
    }
  }
  
  private CharSequence indexView(final Entity it, final String pageName) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{# purpose of this template: ");
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(it.getNameMultiple());
    _builder.append(_formatForDisplay);
    _builder.append(" ");
    _builder.append(pageName);
    _builder.append(" view #}");
    _builder.newLineIfNotEmpty();
    _builder.append("{% extends routeArea == \'admin\' ? \'");
    String _appName = this._utils.appName(this.app);
    _builder.append(_appName);
    _builder.append("::adminBase.html.twig\' : \'");
    String _appName_1 = this._utils.appName(this.app);
    _builder.append(_appName_1);
    _builder.append("::base.html.twig\' %}");
    _builder.newLineIfNotEmpty();
    _builder.append("{% block title __(\'");
    String _formatForDisplay_1 = this._formattingExtensions.formatForDisplay(it.getNameMultiple());
    _builder.append(_formatForDisplay_1);
    _builder.append("\') %}");
    _builder.newLineIfNotEmpty();
    _builder.append("{% block admin_page_icon \'home\' %}");
    _builder.newLine();
    _builder.append("{% block content %}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<p>{{ __(\'Welcome to the ");
    String _formatForDisplay_2 = this._formattingExtensions.formatForDisplay(it.getName());
    _builder.append(_formatForDisplay_2, "    ");
    _builder.append(" section of the ");
    String _formatForDisplayCapital = this._formattingExtensions.formatForDisplayCapital(this.app.getName());
    _builder.append(_formatForDisplayCapital, "    ");
    _builder.append(" application.\') }}</p>");
    _builder.newLineIfNotEmpty();
    _builder.append("{% endblock %}");
    _builder.newLine();
    return _builder;
  }
}
