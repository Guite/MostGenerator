package org.zikula.modulestudio.generator.cartridges.zclassic.view.pages;

import com.google.inject.Inject;
import de.guite.modulestudio.metamodel.modulestudio.AdminController;
import de.guite.modulestudio.metamodel.modulestudio.Application;
import de.guite.modulestudio.metamodel.modulestudio.Controller;
import de.guite.modulestudio.metamodel.modulestudio.Controllers;
import de.guite.modulestudio.metamodel.modulestudio.DerivedField;
import de.guite.modulestudio.metamodel.modulestudio.Entity;
import de.guite.modulestudio.metamodel.modulestudio.Models;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.eclipse.xtext.xbase.lib.InputOutput;
import org.eclipse.xtext.xbase.lib.StringExtensions;
import org.zikula.modulestudio.generator.extensions.ControllerExtensions;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.UrlExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class Delete {
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
  private ModelExtensions _modelExtensions = new Function0<ModelExtensions>() {
    public ModelExtensions apply() {
      ModelExtensions _modelExtensions = new ModelExtensions();
      return _modelExtensions;
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
  
  @Inject
  @Extension
  private UrlExtensions _urlExtensions = new Function0<UrlExtensions>() {
    public UrlExtensions apply() {
      UrlExtensions _urlExtensions = new UrlExtensions();
      return _urlExtensions;
    }
  }.apply();
  
  @Inject
  @Extension
  private Utils _utils = new Function0<Utils>() {
    public Utils apply() {
      Utils _utils = new Utils();
      return _utils;
    }
  }.apply();
  
  public void generate(final Entity it, final String appName, final Controller controller, final IFileSystemAccess fsa) {
    String _formattedName = this._controllerExtensions.formattedName(controller);
    String _plus = ("Generating " + _formattedName);
    String _plus_1 = (_plus + " delete templates for entity \"");
    String _name = it.getName();
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(_name);
    String _plus_2 = (_plus_1 + _formatForDisplay);
    String _plus_3 = (_plus_2 + "\"");
    InputOutput.<String>println(_plus_3);
    String _name_1 = it.getName();
    String _templateFile = this._namingExtensions.templateFile(controller, _name_1, "delete");
    CharSequence _deleteView = this.deleteView(it, appName, controller);
    fsa.generateFile(_templateFile, _deleteView);
  }
  
  private CharSequence deleteView(final Entity it, final String appName, final Controller controller) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{* purpose of this template: ");
    String _nameMultiple = it.getNameMultiple();
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(_nameMultiple);
    _builder.append(_formatForDisplay, "");
    _builder.append(" delete confirmation view in ");
    String _formattedName = this._controllerExtensions.formattedName(controller);
    _builder.append(_formattedName, "");
    _builder.append(" area *}");
    _builder.newLineIfNotEmpty();
    _builder.append("{include file=\'");
    {
      Models _container = it.getContainer();
      Application _application = _container.getApplication();
      boolean _targets = this._utils.targets(_application, "1.3.5");
      if (_targets) {
        String _formattedName_1 = this._controllerExtensions.formattedName(controller);
        _builder.append(_formattedName_1, "");
      } else {
        String _formattedName_2 = this._controllerExtensions.formattedName(controller);
        String _firstUpper = StringExtensions.toFirstUpper(_formattedName_2);
        _builder.append(_firstUpper, "");
      }
    }
    _builder.append("/header.tpl\'}");
    _builder.newLineIfNotEmpty();
    _builder.append("<div class=\"");
    String _lowerCase = appName.toLowerCase();
    _builder.append(_lowerCase, "");
    _builder.append("-");
    String _name = it.getName();
    String _formatForDB = this._formattingExtensions.formatForDB(_name);
    _builder.append(_formatForDB, "");
    _builder.append(" ");
    String _lowerCase_1 = appName.toLowerCase();
    _builder.append(_lowerCase_1, "");
    _builder.append("-delete\">");
    _builder.newLineIfNotEmpty();
    _builder.append("{gt text=\'Delete ");
    String _name_1 = it.getName();
    String _formatForDisplay_1 = this._formattingExtensions.formatForDisplay(_name_1);
    _builder.append(_formatForDisplay_1, "");
    _builder.append("\' assign=\'templateTitle\'}");
    _builder.newLineIfNotEmpty();
    _builder.append("{pagesetvar name=\'title\' value=$templateTitle}");
    _builder.newLine();
    CharSequence _templateHeader = this.templateHeader(controller);
    _builder.append(_templateHeader, "");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("<p class=\"");
    {
      Models _container_1 = it.getContainer();
      Application _application_1 = _container_1.getApplication();
      boolean _targets_1 = this._utils.targets(_application_1, "1.3.5");
      if (_targets_1) {
        _builder.append("z-warningmsg");
      } else {
        _builder.append("alert alert-warningmsg");
      }
    }
    _builder.append("\">{gt text=\'Do you really want to delete this ");
    String _name_2 = it.getName();
    String _formatForDisplay_2 = this._formattingExtensions.formatForDisplay(_name_2);
    _builder.append(_formatForDisplay_2, "");
    _builder.append(" ?\'}</p>");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("<form class=\"");
    {
      Models _container_2 = it.getContainer();
      Application _application_2 = _container_2.getApplication();
      boolean _targets_2 = this._utils.targets(_application_2, "1.3.5");
      if (_targets_2) {
        _builder.append("z-form");
      } else {
        _builder.append("form-horizontal");
      }
    }
    _builder.append("\" action=\"{modurl modname=\'");
    _builder.append(appName, "");
    _builder.append("\' type=\'");
    String _formattedName_3 = this._controllerExtensions.formattedName(controller);
    _builder.append(_formattedName_3, "");
    _builder.append("\' ");
    String _name_3 = it.getName();
    String _modUrlDelete = this._urlExtensions.modUrlDelete(it, _name_3, Boolean.valueOf(true));
    _builder.append(_modUrlDelete, "");
    _builder.append("}\" method=\"post\"");
    {
      Models _container_3 = it.getContainer();
      Application _application_3 = _container_3.getApplication();
      boolean _targets_3 = this._utils.targets(_application_3, "1.3.5");
      boolean _not = (!_targets_3);
      if (_not) {
        _builder.append(" role=\"form\"");
      }
    }
    _builder.append(">");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("<div>");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<input type=\"hidden\" name=\"csrftoken\" value=\"{insert name=\'csrftoken\'}\" />");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<input type=\"hidden\" id=\"confirmation\" name=\"confirmation\" value=\"1\" />");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<fieldset>");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("<legend>{gt text=\'Confirmation prompt\'}</legend>");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("<div class=\"");
    {
      Models _container_4 = it.getContainer();
      Application _application_4 = _container_4.getApplication();
      boolean _targets_4 = this._utils.targets(_application_4, "1.3.5");
      if (_targets_4) {
        _builder.append("z-buttons z-formbuttons");
      } else {
        _builder.append("form-group form-buttons");
      }
    }
    _builder.append("\">");
    _builder.newLineIfNotEmpty();
    {
      Models _container_5 = it.getContainer();
      Application _application_5 = _container_5.getApplication();
      boolean _targets_5 = this._utils.targets(_application_5, "1.3.5");
      boolean _not_1 = (!_targets_5);
      if (_not_1) {
        _builder.append("            ");
        _builder.append("<div class=\"col-lg-offset-3 col-lg-9\">");
        _builder.newLine();
      }
    }
    _builder.append("                ");
    _builder.append("{gt text=\'Delete\' assign=\'deleteTitle\'}");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("{button src=\'14_layer_deletelayer.png\' set=\'icons/small\' text=$deleteTitle title=$deleteTitle class=\'");
    {
      Models _container_6 = it.getContainer();
      Application _application_6 = _container_6.getApplication();
      boolean _targets_6 = this._utils.targets(_application_6, "1.3.5");
      if (_targets_6) {
        _builder.append("z-btred");
      } else {
        _builder.append("btn btn-danger");
      }
    }
    _builder.append("\'}");
    _builder.newLineIfNotEmpty();
    _builder.append("                ");
    _builder.append("<a href=\"{modurl modname=\'");
    _builder.append(appName, "                ");
    _builder.append("\' type=\'");
    String _formattedName_4 = this._controllerExtensions.formattedName(controller);
    _builder.append(_formattedName_4, "                ");
    _builder.append("\' func=\'view\' ot=\'");
    String _name_4 = it.getName();
    String _formatForCode = this._formattingExtensions.formatForCode(_name_4);
    _builder.append(_formatForCode, "                ");
    _builder.append("\'}\"");
    {
      Models _container_7 = it.getContainer();
      Application _application_7 = _container_7.getApplication();
      boolean _targets_7 = this._utils.targets(_application_7, "1.3.5");
      boolean _not_2 = (!_targets_7);
      if (_not_2) {
        _builder.append(" class=\"btn btn-default\" role=\"button\"");
      }
    }
    _builder.append(">{icon type=\'cancel\' size=\'small\' __alt=\'Cancel\' __title=\'Cancel\'} {gt text=\'Cancel\'}</a>");
    _builder.newLineIfNotEmpty();
    {
      Models _container_8 = it.getContainer();
      Application _application_8 = _container_8.getApplication();
      boolean _targets_8 = this._utils.targets(_application_8, "1.3.5");
      boolean _not_3 = (!_targets_8);
      if (_not_3) {
        _builder.append("            ");
        _builder.append("</div>");
        _builder.newLine();
      }
    }
    _builder.append("            ");
    _builder.append("</div>");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("</fieldset>");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    CharSequence _callDisplayHooks = this.callDisplayHooks(it, appName, controller);
    _builder.append(_callDisplayHooks, "        ");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("</div>");
    _builder.newLine();
    _builder.append("</form>");
    _builder.newLine();
    CharSequence _templateFooter = this.templateFooter(controller);
    _builder.append(_templateFooter, "");
    _builder.newLineIfNotEmpty();
    _builder.append("</div>");
    _builder.newLine();
    _builder.append("{include file=\'");
    {
      Models _container_9 = it.getContainer();
      Application _application_9 = _container_9.getApplication();
      boolean _targets_9 = this._utils.targets(_application_9, "1.3.5");
      if (_targets_9) {
        String _formattedName_5 = this._controllerExtensions.formattedName(controller);
        _builder.append(_formattedName_5, "");
      } else {
        String _formattedName_6 = this._controllerExtensions.formattedName(controller);
        String _firstUpper_1 = StringExtensions.toFirstUpper(_formattedName_6);
        _builder.append(_firstUpper_1, "");
      }
    }
    _builder.append("/footer.tpl\'}");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence templateHeader(final Controller it) {
    CharSequence _switchResult = null;
    boolean _matched = false;
    if (!_matched) {
      if (it instanceof AdminController) {
        final AdminController _adminController = (AdminController)it;
        _matched=true;
        StringConcatenation _builder = new StringConcatenation();
        {
          Controllers _container = _adminController.getContainer();
          Application _application = _container.getApplication();
          boolean _targets = this._utils.targets(_application, "1.3.5");
          if (_targets) {
            _builder.append("<div class=\"z-admin-content-pagetitle\">");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("{icon type=\'delete\' size=\'small\' __alt=\'Delete\'}");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("<h3>{$templateTitle}</h3>");
            _builder.newLine();
            _builder.append("</div>");
            _builder.newLine();
          } else {
            _builder.append("<h3>");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("{icon type=\'delete\' size=\'small\' __alt=\'Delete\'}");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("{$templateTitle}");
            _builder.newLine();
            _builder.append("</h3>");
            _builder.newLine();
          }
        }
        _switchResult = _builder;
      }
    }
    if (!_matched) {
      StringConcatenation _builder = new StringConcatenation();
      _builder.append("<div class=\"z-frontendcontainer\">");
      _builder.newLine();
      _builder.append("    ");
      _builder.append("<h2>{$templateTitle}</h2>");
      _builder.newLine();
      _switchResult = _builder;
    }
    return _switchResult;
  }
  
  private CharSequence templateFooter(final Controller it) {
    CharSequence _switchResult = null;
    boolean _matched = false;
    if (!_matched) {
      if (it instanceof AdminController) {
        final AdminController _adminController = (AdminController)it;
        _matched=true;
        _switchResult = "";
      }
    }
    if (!_matched) {
      StringConcatenation _builder = new StringConcatenation();
      _builder.append("</div>");
      _builder.newLine();
      _switchResult = _builder;
    }
    return _switchResult;
  }
  
  private CharSequence callDisplayHooks(final Entity it, final String appName, final Controller controller) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{notifydisplayhooks eventname=\'");
    String _formatForDB = this._formattingExtensions.formatForDB(appName);
    _builder.append(_formatForDB, "");
    _builder.append(".ui_hooks.");
    String _nameMultiple = it.getNameMultiple();
    String _formatForDB_1 = this._formattingExtensions.formatForDB(_nameMultiple);
    _builder.append(_formatForDB_1, "");
    _builder.append(".form_delete\' id=\"");
    {
      Iterable<DerivedField> _primaryKeyFields = this._modelExtensions.getPrimaryKeyFields(it);
      boolean _hasElements = false;
      for(final DerivedField pkField : _primaryKeyFields) {
        if (!_hasElements) {
          _hasElements = true;
        } else {
          _builder.appendImmediate("_", "");
        }
        _builder.append("`$");
        String _name = it.getName();
        String _formatForCode = this._formattingExtensions.formatForCode(_name);
        _builder.append(_formatForCode, "");
        _builder.append(".");
        String _name_1 = pkField.getName();
        String _formatForCode_1 = this._formattingExtensions.formatForCode(_name_1);
        _builder.append(_formatForCode_1, "");
        _builder.append("`");
      }
    }
    _builder.append("\" assign=\'hooks\'}");
    _builder.newLineIfNotEmpty();
    _builder.append("{foreach key=\'providerArea\' item=\'hook\' from=$hooks}");
    _builder.newLine();
    _builder.append("<fieldset>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<legend>{$hookName}</legend>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{$hook}");
    _builder.newLine();
    _builder.append("</fieldset>");
    _builder.newLine();
    _builder.append("{/foreach}");
    _builder.newLine();
    return _builder;
  }
}
