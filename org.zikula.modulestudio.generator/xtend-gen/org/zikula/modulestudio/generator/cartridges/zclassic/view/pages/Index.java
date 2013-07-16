package org.zikula.modulestudio.generator.cartridges.zclassic.view.pages;

import com.google.inject.Inject;
import de.guite.modulestudio.metamodel.modulestudio.Application;
import de.guite.modulestudio.metamodel.modulestudio.Controller;
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
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class Index {
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
  
  @Inject
  @Extension
  private Utils _utils = new Function0<Utils>() {
    public Utils apply() {
      Utils _utils = new Utils();
      return _utils;
    }
  }.apply();
  
  private Application app;
  
  public void generate(final Entity it, final Controller controller, final IFileSystemAccess fsa) {
    Models _container = it.getContainer();
    Application _application = _container.getApplication();
    this.app = _application;
    String _xifexpression = null;
    boolean _targets = this._utils.targets(this.app, "1.3.5");
    if (_targets) {
      _xifexpression = "main";
    } else {
      _xifexpression = "index";
    }
    final String pageName = _xifexpression;
    String _formattedName = this._controllerExtensions.formattedName(controller);
    String _plus = ("Generating " + _formattedName);
    String _plus_1 = (_plus + " ");
    String _plus_2 = (_plus_1 + pageName);
    String _plus_3 = (_plus_2 + " templates for entity \"");
    String _name = it.getName();
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(_name);
    String _plus_4 = (_plus_3 + _formatForDisplay);
    String _plus_5 = (_plus_4 + "\"");
    InputOutput.<String>println(_plus_5);
    Models _container_1 = it.getContainer();
    final Application app = _container_1.getApplication();
    String _viewPath = this._namingExtensions.getViewPath(app);
    String _xifexpression_1 = null;
    boolean _targets_1 = this._utils.targets(app, "1.3.5");
    if (_targets_1) {
      String _formattedName_1 = this._controllerExtensions.formattedName(controller);
      _xifexpression_1 = _formattedName_1;
    } else {
      String _formattedName_2 = this._controllerExtensions.formattedName(controller);
      String _firstUpper = StringExtensions.toFirstUpper(_formattedName_2);
      _xifexpression_1 = _firstUpper;
    }
    String _plus_6 = (_viewPath + _xifexpression_1);
    final String templatePath = (_plus_6 + "/");
    String _plus_7 = (templatePath + pageName);
    String _plus_8 = (_plus_7 + ".tpl");
    CharSequence _indexView = this.indexView(it, pageName, controller);
    fsa.generateFile(_plus_8, _indexView);
  }
  
  private CharSequence indexView(final Entity it, final String pageName, final Controller controller) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{* purpose of this template: ");
    String _nameMultiple = it.getNameMultiple();
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(_nameMultiple);
    _builder.append(_formatForDisplay, "");
    _builder.append(" ");
    _builder.append(pageName, "");
    _builder.append(" view in ");
    String _formattedName = this._controllerExtensions.formattedName(controller);
    _builder.append(_formattedName, "");
    _builder.append(" area *}");
    _builder.newLineIfNotEmpty();
    {
      boolean _hasActions = this._controllerExtensions.hasActions(controller, "view");
      if (_hasActions) {
        {
          boolean _targets = this._utils.targets(this.app, "1.3.5");
          if (_targets) {
            _builder.append("{modfunc modname=\'");
            String _appName = this._utils.appName(this.app);
            _builder.append(_appName, "");
            _builder.append("\' type=\'");
            String _formattedName_1 = this._controllerExtensions.formattedName(controller);
            _builder.append(_formattedName_1, "");
            _builder.append("\' func=\'view\'}");
            _builder.newLineIfNotEmpty();
          } else {
            _builder.append("{modfunc modname=\'");
            String _appName_1 = this._utils.appName(this.app);
            _builder.append(_appName_1, "");
            _builder.append("\' type=\'");
            String _formattedName_2 = this._controllerExtensions.formattedName(controller);
            _builder.append(_formattedName_2, "");
            _builder.append("\' func=\'view\' assign=\'response\'}");
            _builder.newLineIfNotEmpty();
            _builder.append("{$response->getContent()}");
            _builder.newLine();
          }
        }
      } else {
        _builder.append("{include file=\'");
        {
          boolean _targets_1 = this._utils.targets(this.app, "1.3.5");
          if (_targets_1) {
            String _formattedName_3 = this._controllerExtensions.formattedName(controller);
            _builder.append(_formattedName_3, "");
          } else {
            String _formattedName_4 = this._controllerExtensions.formattedName(controller);
            String _firstUpper = StringExtensions.toFirstUpper(_formattedName_4);
            _builder.append(_firstUpper, "");
          }
        }
        _builder.append("/header.tpl\'}");
        _builder.newLineIfNotEmpty();
        _builder.append("<p>{gt text=\'Welcome to the ");
        String _formattedName_5 = this._controllerExtensions.formattedName(controller);
        _builder.append(_formattedName_5, "");
        _builder.append(" section of the ");
        String _appName_2 = this._utils.appName(this.app);
        String _formatForDisplayCapital = this._formattingExtensions.formatForDisplayCapital(_appName_2);
        _builder.append(_formatForDisplayCapital, "");
        _builder.append(" application.\'}</p>");
        _builder.newLineIfNotEmpty();
        _builder.append("{include file=\'");
        {
          boolean _targets_2 = this._utils.targets(this.app, "1.3.5");
          if (_targets_2) {
            String _formattedName_6 = this._controllerExtensions.formattedName(controller);
            _builder.append(_formattedName_6, "");
          } else {
            String _formattedName_7 = this._controllerExtensions.formattedName(controller);
            String _firstUpper_1 = StringExtensions.toFirstUpper(_formattedName_7);
            _builder.append(_firstUpper_1, "");
          }
        }
        _builder.append("/footer.tpl\'}");
        _builder.newLineIfNotEmpty();
      }
    }
    return _builder;
  }
}
