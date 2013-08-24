package org.zikula.modulestudio.generator.cartridges.zclassic.view.pages;

import com.google.inject.Inject;
import de.guite.modulestudio.metamodel.modulestudio.Action;
import de.guite.modulestudio.metamodel.modulestudio.AdminController;
import de.guite.modulestudio.metamodel.modulestudio.Application;
import de.guite.modulestudio.metamodel.modulestudio.Controller;
import de.guite.modulestudio.metamodel.modulestudio.CustomAction;
import java.util.Arrays;
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
public class Custom {
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
  
  protected CharSequence _generate(final Action it, final Application app, final Controller controller, final IFileSystemAccess fsa) {
    return null;
  }
  
  protected CharSequence _generate(final CustomAction it, final Application app, final Controller controller, final IFileSystemAccess fsa) {
    CharSequence _xblockexpression = null;
    {
      String _formattedName = this._controllerExtensions.formattedName(controller);
      String _plus = ("Generating " + _formattedName);
      String _plus_1 = (_plus + " templates for custom action \"");
      String _name = it.getName();
      String _formatForDisplay = this._formattingExtensions.formatForDisplay(_name);
      String _plus_2 = (_plus_1 + _formatForDisplay);
      String _plus_3 = (_plus_2 + "\"");
      InputOutput.<String>println(_plus_3);
      String _viewPath = this._namingExtensions.getViewPath(app);
      String _xifexpression = null;
      boolean _targets = this._utils.targets(app, "1.3.5");
      if (_targets) {
        String _formattedName_1 = this._controllerExtensions.formattedName(controller);
        _xifexpression = _formattedName_1;
      } else {
        String _formattedName_2 = this._controllerExtensions.formattedName(controller);
        String _firstUpper = StringExtensions.toFirstUpper(_formattedName_2);
        _xifexpression = _firstUpper;
      }
      String _plus_4 = (_viewPath + _xifexpression);
      final String templatePath = (_plus_4 + "/");
      String _name_1 = it.getName();
      String _formatForCode = this._formattingExtensions.formatForCode(_name_1);
      String _firstLower = StringExtensions.toFirstLower(_formatForCode);
      String _plus_5 = (templatePath + _firstLower);
      String _plus_6 = (_plus_5 + ".tpl");
      CharSequence _customView = this.customView(it, app, controller);
      fsa.generateFile(_plus_6, _customView);
      StringConcatenation _builder = new StringConcatenation();
      _builder.append(" ");
      _xblockexpression = (_builder);
    }
    return _xblockexpression;
  }
  
  private CharSequence customView(final CustomAction it, final Application app, final Controller controller) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{* purpose of this template: show output of ");
    String _name = it.getName();
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(_name);
    _builder.append(_formatForDisplay, "");
    _builder.append(" action in ");
    String _formattedName = this._controllerExtensions.formattedName(controller);
    _builder.append(_formattedName, "");
    _builder.append(" area *}");
    _builder.newLineIfNotEmpty();
    _builder.append("{include file=\'");
    {
      boolean _targets = this._utils.targets(app, "1.3.5");
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
    String _appName = this._utils.appName(app);
    String _lowerCase = _appName.toLowerCase();
    _builder.append(_lowerCase, "");
    _builder.append("-");
    String _name_1 = it.getName();
    String _formatForDB = this._formattingExtensions.formatForDB(_name_1);
    _builder.append(_formatForDB, "");
    _builder.append(" ");
    String _appName_1 = this._utils.appName(app);
    String _lowerCase_1 = _appName_1.toLowerCase();
    _builder.append(_lowerCase_1, "");
    _builder.append("-");
    String _name_2 = it.getName();
    String _formatForDB_1 = this._formattingExtensions.formatForDB(_name_2);
    _builder.append(_formatForDB_1, "");
    _builder.append("\">");
    _builder.newLineIfNotEmpty();
    _builder.append("{gt text=\'");
    String _name_3 = it.getName();
    String _formatForDisplayCapital = this._formattingExtensions.formatForDisplayCapital(_name_3);
    _builder.append(_formatForDisplayCapital, "");
    _builder.append("\' assign=\'templateTitle\'}");
    _builder.newLineIfNotEmpty();
    _builder.append("{pagesetvar name=\'title\' value=$templateTitle}");
    _builder.newLine();
    String _name_4 = it.getName();
    CharSequence _templateHeader = this.templateHeader(controller, _name_4);
    _builder.append(_templateHeader, "");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("<p>Please override this template by moving it from <em>/modules/");
    {
      boolean _targets_1 = this._utils.targets(app, "1.3.5");
      if (_targets_1) {
        String _appName_2 = this._utils.appName(app);
        _builder.append(_appName_2, "");
        _builder.append("/templates/");
        String _formattedName_3 = this._controllerExtensions.formattedName(controller);
        _builder.append(_formattedName_3, "");
      } else {
        String _viewPath = this._namingExtensions.getViewPath(app);
        _builder.append(_viewPath, "");
        String _formattedName_4 = this._controllerExtensions.formattedName(controller);
        String _firstUpper_1 = StringExtensions.toFirstUpper(_formattedName_4);
        _builder.append(_firstUpper_1, "");
      }
    }
    _builder.append("/");
    String _name_5 = it.getName();
    String _formatForCode = this._formattingExtensions.formatForCode(_name_5);
    String _firstLower = StringExtensions.toFirstLower(_formatForCode);
    _builder.append(_firstLower, "");
    _builder.append(".tpl</em> to either your <em>/themes/YourTheme/templates/modules/");
    String _appName_3 = this._utils.appName(app);
    _builder.append(_appName_3, "");
    _builder.append("/");
    {
      boolean _targets_2 = this._utils.targets(app, "1.3.5");
      if (_targets_2) {
        String _formattedName_5 = this._controllerExtensions.formattedName(controller);
        _builder.append(_formattedName_5, "");
      } else {
        String _formattedName_6 = this._controllerExtensions.formattedName(controller);
        String _firstUpper_2 = StringExtensions.toFirstUpper(_formattedName_6);
        _builder.append(_firstUpper_2, "");
      }
    }
    _builder.append("/");
    String _name_6 = it.getName();
    String _formatForCode_1 = this._formattingExtensions.formatForCode(_name_6);
    String _firstLower_1 = StringExtensions.toFirstLower(_formatForCode_1);
    _builder.append(_firstLower_1, "");
    _builder.append(".tpl</em> or <em>/config/templates/");
    String _appName_4 = this._utils.appName(app);
    _builder.append(_appName_4, "");
    _builder.append("/");
    {
      boolean _targets_3 = this._utils.targets(app, "1.3.5");
      if (_targets_3) {
        String _formattedName_7 = this._controllerExtensions.formattedName(controller);
        _builder.append(_formattedName_7, "");
      } else {
        String _formattedName_8 = this._controllerExtensions.formattedName(controller);
        String _firstUpper_3 = StringExtensions.toFirstUpper(_formattedName_8);
        _builder.append(_firstUpper_3, "");
      }
    }
    _builder.append("/");
    String _name_7 = it.getName();
    String _formatForCode_2 = this._formattingExtensions.formatForCode(_name_7);
    String _firstLower_2 = StringExtensions.toFirstLower(_formatForCode_2);
    _builder.append(_firstLower_2, "");
    _builder.append(".tpl</em>.</p>");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    CharSequence _templateFooter = this.templateFooter(controller);
    _builder.append(_templateFooter, "");
    _builder.newLineIfNotEmpty();
    _builder.append("</div>");
    _builder.newLine();
    _builder.append("{include file=\'");
    {
      boolean _targets_4 = this._utils.targets(app, "1.3.5");
      if (_targets_4) {
        String _formattedName_9 = this._controllerExtensions.formattedName(controller);
        _builder.append(_formattedName_9, "");
      } else {
        String _formattedName_10 = this._controllerExtensions.formattedName(controller);
        String _firstUpper_4 = StringExtensions.toFirstUpper(_formattedName_10);
        _builder.append(_firstUpper_4, "");
      }
    }
    _builder.append("/footer.tpl\'}");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence templateHeader(final Controller it, final String actionName) {
    CharSequence _switchResult = null;
    boolean _matched = false;
    if (!_matched) {
      if (it instanceof AdminController) {
        final AdminController _adminController = (AdminController)it;
        _matched=true;
        StringConcatenation _builder = new StringConcatenation();
        _builder.append("<div class=\"z-admin-content-pagetitle\">");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("{icon type=\'options\' size=\'small\' __alt=\'");
        String _formatForDisplayCapital = this._formattingExtensions.formatForDisplayCapital(actionName);
        _builder.append(_formatForDisplayCapital, "    ");
        _builder.append("\'}");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("<h3>{$templateTitle}</h3>");
        _builder.newLine();
        _builder.append("</div>");
        _builder.newLine();
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
  
  public CharSequence generate(final Action it, final Application app, final Controller controller, final IFileSystemAccess fsa) {
    if (it instanceof CustomAction) {
      return _generate((CustomAction)it, app, controller, fsa);
    } else if (it != null) {
      return _generate(it, app, controller, fsa);
    } else {
      throw new IllegalArgumentException("Unhandled parameter types: " +
        Arrays.<Object>asList(it, app, controller, fsa).toString());
    }
  }
}
