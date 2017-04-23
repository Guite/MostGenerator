package org.zikula.modulestudio.generator.cartridges.zclassic.view.pages;

import de.guite.modulestudio.metamodel.Application;
import de.guite.modulestudio.metamodel.CustomAction;
import de.guite.modulestudio.metamodel.Entity;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.InputOutput;
import org.eclipse.xtext.xbase.lib.StringExtensions;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class Custom {
  @Extension
  private FormattingExtensions _formattingExtensions = new FormattingExtensions();
  
  @Extension
  private NamingExtensions _namingExtensions = new NamingExtensions();
  
  @Extension
  private Utils _utils = new Utils();
  
  public CharSequence generate(final CustomAction it, final Application app, final Entity entity, final IFileSystemAccess fsa) {
    CharSequence _xblockexpression = null;
    {
      String templateFilePath = this._namingExtensions.templateFile(entity, this._formattingExtensions.formatForCode(it.getName()));
      boolean _shouldBeSkipped = this._namingExtensions.shouldBeSkipped(app, templateFilePath);
      boolean _not = (!_shouldBeSkipped);
      if (_not) {
        String _formatForDisplay = this._formattingExtensions.formatForDisplay(entity.getName());
        String _plus = ("Generating " + _formatForDisplay);
        String _plus_1 = (_plus + " templates for custom action \"");
        String _formatForDisplay_1 = this._formattingExtensions.formatForDisplay(it.getName());
        String _plus_2 = (_plus_1 + _formatForDisplay_1);
        String _plus_3 = (_plus_2 + "\"");
        InputOutput.<String>println(_plus_3);
        fsa.generateFile(templateFilePath, this.customView(it, app, entity));
      }
      StringConcatenation _builder = new StringConcatenation();
      _builder.append(" ");
      _xblockexpression = _builder;
    }
    return _xblockexpression;
  }
  
  private CharSequence customView(final CustomAction it, final Application app, final Entity controller) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{# purpose of this template: show output of ");
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(it.getName());
    _builder.append(_formatForDisplay);
    _builder.append(" action in ");
    String _formatForDisplay_1 = this._formattingExtensions.formatForDisplay(it.getEntity().getName());
    _builder.append(_formatForDisplay_1);
    _builder.append(" area #}");
    _builder.newLineIfNotEmpty();
    _builder.append("{% extends routeArea == \'admin\' ? \'");
    String _appName = this._utils.appName(app);
    _builder.append(_appName);
    _builder.append("::adminBase.html.twig\' : \'");
    String _appName_1 = this._utils.appName(app);
    _builder.append(_appName_1);
    _builder.append("::base.html.twig\' %}");
    _builder.newLineIfNotEmpty();
    _builder.append("{% block title __(\'");
    String _formatForDisplayCapital = this._formattingExtensions.formatForDisplayCapital(it.getName());
    _builder.append(_formatForDisplayCapital);
    _builder.append("\') %}");
    _builder.newLineIfNotEmpty();
    _builder.append("{% block admin_page_icon \'square\' %}");
    _builder.newLine();
    _builder.append("{% block content %}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<div class=\"");
    String _lowerCase = this._utils.appName(app).toLowerCase();
    _builder.append(_lowerCase, "    ");
    _builder.append("-");
    String _formatForDB = this._formattingExtensions.formatForDB(controller.getName());
    _builder.append(_formatForDB, "    ");
    _builder.append(" ");
    String _lowerCase_1 = this._utils.appName(app).toLowerCase();
    _builder.append(_lowerCase_1, "    ");
    _builder.append("-");
    String _formatForDB_1 = this._formattingExtensions.formatForDB(it.getName());
    _builder.append(_formatForDB_1, "    ");
    _builder.append("\">");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("<p>Please override this template by moving it from <em>/");
    String _relativeAppRootPath = this._namingExtensions.relativeAppRootPath(app);
    _builder.append(_relativeAppRootPath, "        ");
    _builder.append("/");
    String _viewPath = this._namingExtensions.getViewPath(app);
    _builder.append(_viewPath, "        ");
    String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(it.getEntity().getName());
    _builder.append(_formatForCodeCapital, "        ");
    _builder.append("/");
    String _firstLower = StringExtensions.toFirstLower(this._formattingExtensions.formatForCode(it.getName()));
    _builder.append(_firstLower, "        ");
    _builder.append(".html.twig</em> to either <em>/themes/YourTheme/Resources/");
    String _appName_2 = this._utils.appName(app);
    _builder.append(_appName_2, "        ");
    _builder.append("/views/");
    String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(it.getEntity().getName());
    _builder.append(_formatForCodeCapital_1, "        ");
    _builder.append("/");
    String _firstLower_1 = StringExtensions.toFirstLower(this._formattingExtensions.formatForCode(it.getName()));
    _builder.append(_firstLower_1, "        ");
    _builder.append(".html.twig</em> or <em>/app/Resources/");
    String _appName_3 = this._utils.appName(app);
    _builder.append(_appName_3, "        ");
    _builder.append("/views/");
    String _formatForCodeCapital_2 = this._formattingExtensions.formatForCodeCapital(it.getEntity().getName());
    _builder.append(_formatForCodeCapital_2, "        ");
    _builder.append("/");
    String _firstLower_2 = StringExtensions.toFirstLower(this._formattingExtensions.formatForCode(it.getName()));
    _builder.append(_firstLower_2, "        ");
    _builder.append(".html.twig</em>.</p>");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("</div>");
    _builder.newLine();
    _builder.append("{% endblock %}");
    _builder.newLine();
    return _builder;
  }
}
