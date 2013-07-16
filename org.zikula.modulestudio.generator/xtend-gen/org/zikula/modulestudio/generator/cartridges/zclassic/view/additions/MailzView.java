package org.zikula.modulestudio.generator.cartridges.zclassic.view.additions;

import com.google.inject.Inject;
import de.guite.modulestudio.metamodel.modulestudio.Application;
import de.guite.modulestudio.metamodel.modulestudio.DerivedField;
import de.guite.modulestudio.metamodel.modulestudio.Entity;
import de.guite.modulestudio.metamodel.modulestudio.UserController;
import org.eclipse.emf.common.util.EList;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.zikula.modulestudio.generator.extensions.ControllerExtensions;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.UrlExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class MailzView {
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
  
  public void generate(final Application it, final IFileSystemAccess fsa) {
    String _viewPath = this._namingExtensions.getViewPath(it);
    String _xifexpression = null;
    boolean _targets = this._utils.targets(it, "1.3.5");
    if (_targets) {
      _xifexpression = "mailz";
    } else {
      _xifexpression = "Mailz";
    }
    String _plus = (_viewPath + _xifexpression);
    final String templatePath = (_plus + "/");
    EList<Entity> _allEntities = this._modelExtensions.getAllEntities(it);
    for (final Entity entity : _allEntities) {
      {
        String _plus_1 = (templatePath + "itemlist_");
        String _name = entity.getName();
        String _formatForCode = this._formattingExtensions.formatForCode(_name);
        String _plus_2 = (_plus_1 + _formatForCode);
        String _plus_3 = (_plus_2 + "_text.tpl");
        CharSequence _textTemplate = this.textTemplate(entity, it);
        fsa.generateFile(_plus_3, _textTemplate);
        String _plus_4 = (templatePath + "itemlist_");
        String _name_1 = entity.getName();
        String _formatForCode_1 = this._formattingExtensions.formatForCode(_name_1);
        String _plus_5 = (_plus_4 + _formatForCode_1);
        String _plus_6 = (_plus_5 + "_html.tpl");
        CharSequence _htmlTemplate = this.htmlTemplate(entity, it);
        fsa.generateFile(_plus_6, _htmlTemplate);
      }
    }
  }
  
  private CharSequence textTemplate(final Entity it, final Application app) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{* Purpose of this template: Display ");
    String _nameMultiple = it.getNameMultiple();
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(_nameMultiple);
    _builder.append(_formatForDisplay, "");
    _builder.append(" in text mailings *}");
    _builder.newLineIfNotEmpty();
    _builder.append("{foreach item=\'");
    String _name = it.getName();
    String _formatForCode = this._formattingExtensions.formatForCode(_name);
    _builder.append(_formatForCode, "");
    _builder.append("\' from=$items}");
    _builder.newLineIfNotEmpty();
    String _appName = this._utils.appName(app);
    CharSequence _mailzEntryText = this.mailzEntryText(it, _appName);
    _builder.append(_mailzEntryText, "");
    _builder.newLineIfNotEmpty();
    _builder.append("-----");
    _builder.newLine();
    _builder.append("{foreachelse}");
    _builder.newLine();
    _builder.append("{gt text=\'No ");
    String _nameMultiple_1 = it.getNameMultiple();
    String _formatForDisplay_1 = this._formattingExtensions.formatForDisplay(_nameMultiple_1);
    _builder.append(_formatForDisplay_1, "");
    _builder.append(" found.\'}");
    _builder.newLineIfNotEmpty();
    _builder.append("{/foreach}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence htmlTemplate(final Entity it, final Application app) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{* Purpose of this template: Display ");
    String _nameMultiple = it.getNameMultiple();
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(_nameMultiple);
    _builder.append(_formatForDisplay, "");
    _builder.append(" in html mailings *}");
    _builder.newLineIfNotEmpty();
    _builder.append("{*");
    _builder.newLine();
    _builder.append("<ul>");
    _builder.newLine();
    _builder.append("{foreach item=\'");
    String _name = it.getName();
    String _formatForCode = this._formattingExtensions.formatForCode(_name);
    _builder.append(_formatForCode, "");
    _builder.append("\' from=$items}");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("<li>");
    _builder.newLine();
    _builder.append("        ");
    CharSequence _mailzEntryHtml = this.mailzEntryHtml(it, app);
    _builder.append(_mailzEntryHtml, "        ");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("</li>");
    _builder.newLine();
    _builder.append("{foreachelse}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<li>{gt text=\'No ");
    String _nameMultiple_1 = it.getNameMultiple();
    String _formatForDisplay_1 = this._formattingExtensions.formatForDisplay(_nameMultiple_1);
    _builder.append(_formatForDisplay_1, "    ");
    _builder.append(" found.\'}</li>");
    _builder.newLineIfNotEmpty();
    _builder.append("{/foreach}");
    _builder.newLine();
    _builder.append("</ul>");
    _builder.newLine();
    _builder.append("*}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("{include file=\'");
    {
      boolean _targets = this._utils.targets(app, "1.3.5");
      if (_targets) {
        _builder.append("contenttype");
      } else {
        _builder.append("ContentType");
      }
    }
    _builder.append("/itemlist_");
    String _name_1 = it.getName();
    String _formatForCode_1 = this._formattingExtensions.formatForCode(_name_1);
    _builder.append(_formatForCode_1, "");
    _builder.append("_display_description.tpl\'}");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence mailzEntryText(final Entity it, final String appName) {
    StringConcatenation _builder = new StringConcatenation();
    final DerivedField leadingField = this._modelExtensions.getLeadingField(it);
    _builder.newLineIfNotEmpty();
    {
      boolean _tripleNotEquals = (leadingField != null);
      if (_tripleNotEquals) {
        _builder.append("{$");
        String _name = it.getName();
        String _formatForCode = this._formattingExtensions.formatForCode(_name);
        _builder.append(_formatForCode, "");
        _builder.append(".");
        String _name_1 = leadingField.getName();
        String _formatForCode_1 = this._formattingExtensions.formatForCode(_name_1);
        _builder.append(_formatForCode_1, "");
        _builder.append("}");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("{modurl modname=\'");
    _builder.append(appName, "");
    _builder.append("\' type=\'user\' ");
    String _name_2 = it.getName();
    String _formatForCode_2 = this._formattingExtensions.formatForCode(_name_2);
    String _modUrlDisplayWithFreeOt = this._urlExtensions.modUrlDisplayWithFreeOt(it, _formatForCode_2, Boolean.valueOf(true), "$objectType");
    _builder.append(_modUrlDisplayWithFreeOt, "");
    _builder.append(" fqurl=true}");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence mailzEntryHtml(final Entity it, final Application app) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _and = false;
      boolean _hasUserController = this._controllerExtensions.hasUserController(app);
      if (!_hasUserController) {
        _and = false;
      } else {
        UserController _mainUserController = this._controllerExtensions.getMainUserController(app);
        boolean _hasActions = this._controllerExtensions.hasActions(_mainUserController, "display");
        _and = (_hasUserController && _hasActions);
      }
      if (_and) {
        _builder.append("<a href=\"");
        CharSequence _mailzEntryHtmlLinkUrlDisplay = this.mailzEntryHtmlLinkUrlDisplay(it, app);
        _builder.append(_mailzEntryHtmlLinkUrlDisplay, "");
        _builder.append("\">");
        CharSequence _mailzEntryHtmlLinkText = this.mailzEntryHtmlLinkText(it, app);
        _builder.append(_mailzEntryHtmlLinkText, "");
        _builder.append("</a>");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("<a href=\"");
        CharSequence _mailzEntryHtmlLinkUrlMain = this.mailzEntryHtmlLinkUrlMain(it, app);
        _builder.append(_mailzEntryHtmlLinkUrlMain, "");
        _builder.append("\">");
        CharSequence _mailzEntryHtmlLinkText_1 = this.mailzEntryHtmlLinkText(it, app);
        _builder.append(_mailzEntryHtmlLinkText_1, "");
        _builder.append("</a>");
        _builder.newLineIfNotEmpty();
      }
    }
    return _builder;
  }
  
  private CharSequence mailzEntryHtmlLinkUrlDisplay(final Entity it, final Application app) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{modurl modname=\'");
    String _appName = this._utils.appName(app);
    _builder.append(_appName, "");
    _builder.append("\' type=\'user\' ");
    String _name = it.getName();
    String _formatForCode = this._formattingExtensions.formatForCode(_name);
    String _modUrlDisplayWithFreeOt = this._urlExtensions.modUrlDisplayWithFreeOt(it, _formatForCode, Boolean.valueOf(true), "$objectType");
    _builder.append(_modUrlDisplayWithFreeOt, "");
    _builder.append(" fqurl=true}");
    return _builder;
  }
  
  private CharSequence mailzEntryHtmlLinkUrlMain(final Entity it, final Application app) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _hasUserController = this._controllerExtensions.hasUserController(app);
      if (_hasUserController) {
        {
          UserController _mainUserController = this._controllerExtensions.getMainUserController(app);
          boolean _hasActions = this._controllerExtensions.hasActions(_mainUserController, "view");
          if (_hasActions) {
            _builder.append("{modurl modname=\'");
            String _appName = this._utils.appName(app);
            _builder.append(_appName, "");
            _builder.append("\' type=\'user\' func=\'view\' fqurl=true}");
            _builder.newLineIfNotEmpty();
          } else {
            UserController _mainUserController_1 = this._controllerExtensions.getMainUserController(app);
            boolean _hasActions_1 = this._controllerExtensions.hasActions(_mainUserController_1, "index");
            if (_hasActions_1) {
              _builder.append("{modurl modname=\'");
              String _appName_1 = this._utils.appName(app);
              _builder.append(_appName_1, "");
              _builder.append("\' type=\'user\' func=\'");
              {
                boolean _targets = this._utils.targets(app, "1.3.5");
                if (_targets) {
                  _builder.append("main");
                } else {
                  _builder.append("index");
                }
              }
              _builder.append("\' fqurl=true}");
              _builder.newLineIfNotEmpty();
            } else {
              _builder.append("{modurl modname=\'");
              String _appName_2 = this._utils.appName(app);
              _builder.append(_appName_2, "");
              _builder.append("\' type=\'user\' func=\'");
              {
                boolean _targets_1 = this._utils.targets(app, "1.3.5");
                if (_targets_1) {
                  _builder.append("main");
                } else {
                  _builder.append("index");
                }
              }
              _builder.append("\' fqurl=true}");
              _builder.newLineIfNotEmpty();
            }
          }
        }
      } else {
        _builder.append("{homepage}");
        _builder.newLine();
        _builder.append("        ");
      }
    }
    return _builder;
  }
  
  private CharSequence mailzEntryHtmlLinkText(final Entity it, final Application app) {
    StringConcatenation _builder = new StringConcatenation();
    final DerivedField leadingField = this._modelExtensions.getLeadingField(it);
    _builder.newLineIfNotEmpty();
    {
      boolean _tripleNotEquals = (leadingField != null);
      if (_tripleNotEquals) {
        _builder.append("{$");
        String _name = it.getName();
        String _formatForCode = this._formattingExtensions.formatForCode(_name);
        _builder.append(_formatForCode, "");
        _builder.append(".");
        String _name_1 = leadingField.getName();
        String _formatForCode_1 = this._formattingExtensions.formatForCode(_name_1);
        _builder.append(_formatForCode_1, "");
        _builder.append("}");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("{gt text=\'");
        String _name_2 = it.getName();
        String _formatForDisplayCapital = this._formattingExtensions.formatForDisplayCapital(_name_2);
        _builder.append(_formatForDisplayCapital, "");
        _builder.append("\'}");
        _builder.newLineIfNotEmpty();
      }
    }
    return _builder;
  }
}
