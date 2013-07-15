package org.zikula.modulestudio.generator.cartridges.zclassic.controller.javascript;

import com.google.inject.Inject;
import de.guite.modulestudio.metamodel.modulestudio.Application;
import de.guite.modulestudio.metamodel.modulestudio.BooleanField;
import de.guite.modulestudio.metamodel.modulestudio.Controller;
import de.guite.modulestudio.metamodel.modulestudio.DerivedField;
import de.guite.modulestudio.metamodel.modulestudio.Entity;
import de.guite.modulestudio.metamodel.modulestudio.JoinRelationship;
import de.guite.modulestudio.metamodel.modulestudio.ListField;
import de.guite.modulestudio.metamodel.modulestudio.Models;
import de.guite.modulestudio.metamodel.modulestudio.StringField;
import de.guite.modulestudio.metamodel.modulestudio.UserField;
import java.util.Arrays;
import java.util.List;
import org.eclipse.emf.common.util.EList;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.InputOutput;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.eclipse.xtext.xbase.lib.ListExtensions;
import org.zikula.modulestudio.generator.extensions.ControllerExtensions;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class DisplayFunctions {
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
  private ModelJoinExtensions _modelJoinExtensions = new Function0<ModelJoinExtensions>() {
    public ModelJoinExtensions apply() {
      ModelJoinExtensions _modelJoinExtensions = new ModelJoinExtensions();
      return _modelJoinExtensions;
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
  
  /**
   * Entry point for the javascript file with display functionality.
   */
  public void generate(final Application it, final IFileSystemAccess fsa) {
    InputOutput.<String>println("Generating javascript for display functions");
    String _appJsPath = this._namingExtensions.getAppJsPath(it);
    String _appName = this._utils.appName(it);
    String _plus = (_appJsPath + _appName);
    String _plus_1 = (_plus + ".js");
    CharSequence _generate = this.generate(it);
    fsa.generateFile(_plus_1, _generate);
  }
  
  private CharSequence generate(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("\'use strict\';");
    _builder.newLine();
    _builder.newLine();
    CharSequence _initItemActions = this.initItemActions(it);
    _builder.append(_initItemActions, "");
    _builder.newLineIfNotEmpty();
    {
      EList<Controller> _allControllers = this._controllerExtensions.getAllControllers(it);
      final Function1<Controller,Boolean> _function = new Function1<Controller,Boolean>() {
          public Boolean apply(final Controller e) {
            boolean _hasActions = DisplayFunctions.this._controllerExtensions.hasActions(e, "view");
            return Boolean.valueOf(_hasActions);
          }
        };
      List<Boolean> _map = ListExtensions.<Controller, Boolean>map(_allControllers, _function);
      boolean _isEmpty = _map.isEmpty();
      boolean _not = (!_isEmpty);
      if (_not) {
        _builder.newLine();
        CharSequence _initQuickNavigation = this.initQuickNavigation(it);
        _builder.append(_initQuickNavigation, "");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      Iterable<JoinRelationship> _joinRelations = this._modelJoinExtensions.getJoinRelations(it);
      boolean _isEmpty_1 = IterableExtensions.isEmpty(_joinRelations);
      boolean _not_1 = (!_isEmpty_1);
      if (_not_1) {
        _builder.newLine();
        CharSequence _initRelationWindow = this.initRelationWindow(it);
        _builder.append(_initRelationWindow, "");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      boolean _hasBooleansWithAjaxToggle = this._modelExtensions.hasBooleansWithAjaxToggle(it);
      if (_hasBooleansWithAjaxToggle) {
        _builder.newLine();
        CharSequence _initToggle = this.initToggle(it);
        _builder.append(_initToggle, "");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
        CharSequence _ggleFlag = this.toggleFlag(it);
        _builder.append(_ggleFlag, "");
        _builder.newLineIfNotEmpty();
      }
    }
    return _builder;
  }
  
  private CharSequence initItemActions(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("var ");
    String _prefix = this._utils.prefix(it);
    _builder.append(_prefix, "");
    _builder.append("ContextMenu;");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    String _prefix_1 = this._utils.prefix(it);
    _builder.append(_prefix_1, "");
    _builder.append("ContextMenu = Class.create(Zikula.UI.ContextMenu, {");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("selectMenuItem: function ($super, event, item, item_container) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// open in new tab / window when right-clicked");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if (event.isRightClick()) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("item.callback(this.clicked, true);");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("event.stop(); // close the menu");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("return;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// open in current window when left-clicked");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return $super(event, item, item_container);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("});");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Initialises the context menu for item actions.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("function ");
    String _prefix_2 = this._utils.prefix(it);
    _builder.append(_prefix_2, "");
    _builder.append("InitItemActions(objectType, func, containerId) {");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("var triggerId, contextMenu, iconFile;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("triggerId = containerId + \'trigger\';");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// attach context menu");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("contextMenu = new ");
    String _prefix_3 = this._utils.prefix(it);
    _builder.append(_prefix_3, "    ");
    _builder.append("ContextMenu(triggerId, { leftClick: true, animation: false });");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// process normal links");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$$(\'#\' + containerId + \' a\').each(function (elem) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// hide it");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("elem.addClassName(\'z-hide\');");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// determine the link text");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("var linkText = \'\';");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if (func === \'display\') {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("linkText = elem.innerHTML;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("} else if (func === \'view\') {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("elem.select(\'img\').each(function (imgElem) {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("linkText = imgElem.readAttribute(\'alt\');");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("});");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// determine the icon");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("iconFile = \'\';");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if (func === \'display\') {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("if (elem.hasClassName(\'z-icon-es-preview\')) {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("iconFile = \'xeyes.png\';");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("} else if (elem.hasClassName(\'z-icon-es-display\')) {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("iconFile = \'kview.png\';");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("} else if (elem.hasClassName(\'z-icon-es-edit\')) {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("iconFile = \'edit\';");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("} else if (elem.hasClassName(\'z-icon-es-saveas\')) {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("iconFile = \'filesaveas\';");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("} else if (elem.hasClassName(\'z-icon-es-delete\')) {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("iconFile = \'14_layer_deletelayer\';");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("} else if (elem.hasClassName(\'z-icon-es-back\')) {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("iconFile = \'agt_back\';");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("if (iconFile !== \'\') {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("iconFile = Zikula.Config.baseURL + \'images/icons/extrasmall/\' + iconFile + \'.png\';");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("} else if (func === \'view\') {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("elem.select(\'img\').each(function (imgElem) {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("iconFile = imgElem.readAttribute(\'src\');");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("});");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if (iconFile !== \'\') {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("iconFile = \'<img src=\"\' + iconFile + \'\" width=\"16\" height=\"16\" alt=\"\' + linkText + \'\" /> \';");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("contextMenu.addItem({");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("label: iconFile + linkText,");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("callback: function (selectedMenuItem, isRightClick) {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("var url;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("                ");
    _builder.append("url = elem.readAttribute(\'href\');");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("if (isRightClick) {");
    _builder.newLine();
    _builder.append("                    ");
    _builder.append("window.open(url);");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("} else {");
    _builder.newLine();
    _builder.append("                    ");
    _builder.append("window.location = url;");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("});");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("});");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$(triggerId).removeClassName(\'z-hide\');");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence initQuickNavigation(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("function ");
    String _prefix = this._utils.prefix(it);
    _builder.append(_prefix, "");
    _builder.append("CapitaliseFirstLetter(string) {");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("return string.charAt(0).toUpperCase() + string.slice(1);");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Submits a quick navigation form.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("function ");
    String _prefix_1 = this._utils.prefix(it);
    _builder.append(_prefix_1, "");
    _builder.append("SubmitQuickNavForm(objectType) {");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("$(\'");
    String _prefix_2 = this._utils.prefix(it);
    _builder.append(_prefix_2, "    ");
    _builder.append("\' + ");
    String _prefix_3 = this._utils.prefix(it);
    _builder.append(_prefix_3, "    ");
    _builder.append("CapitaliseFirstLetter(objectType) + \'QuickNavForm\').submit();");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Initialise the quick navigation panel in list views.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("function ");
    String _prefix_4 = this._utils.prefix(it);
    _builder.append(_prefix_4, "");
    _builder.append("InitQuickNavigation(objectType, controller) {");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("if ($(\'");
    String _prefix_5 = this._utils.prefix(it);
    _builder.append(_prefix_5, "    ");
    _builder.append("\' + ");
    String _prefix_6 = this._utils.prefix(it);
    _builder.append(_prefix_6, "    ");
    _builder.append("CapitaliseFirstLetter(objectType) + \'QuickNavForm\') == undefined) {");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("return;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($(\'catid\') != undefined) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$(\'catid\').observe(\'change\', ");
    String _prefix_7 = this._utils.prefix(it);
    CharSequence _initQuickNavigationSubmitCall = this.initQuickNavigationSubmitCall(_prefix_7);
    _builder.append(_initQuickNavigationSubmitCall, "        ");
    _builder.append(");");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($(\'sortby\') != undefined) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$(\'sortby\').observe(\'change\', ");
    String _prefix_8 = this._utils.prefix(it);
    CharSequence _initQuickNavigationSubmitCall_1 = this.initQuickNavigationSubmitCall(_prefix_8);
    _builder.append(_initQuickNavigationSubmitCall_1, "        ");
    _builder.append(");");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($(\'sortdir\') != undefined) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$(\'sortdir\').observe(\'change\', ");
    String _prefix_9 = this._utils.prefix(it);
    CharSequence _initQuickNavigationSubmitCall_2 = this.initQuickNavigationSubmitCall(_prefix_9);
    _builder.append(_initQuickNavigationSubmitCall_2, "        ");
    _builder.append(");");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($(\'num\') != undefined) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$(\'num\').observe(\'change\', ");
    String _prefix_10 = this._utils.prefix(it);
    CharSequence _initQuickNavigationSubmitCall_3 = this.initQuickNavigationSubmitCall(_prefix_10);
    _builder.append(_initQuickNavigationSubmitCall_3, "        ");
    _builder.append(");");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("switch (objectType) {");
    _builder.newLine();
    {
      EList<Entity> _allEntities = this._modelExtensions.getAllEntities(it);
      for(final Entity entity : _allEntities) {
        _builder.append("    ");
        CharSequence _initQuickNavigationEntity = this.initQuickNavigationEntity(entity);
        _builder.append(_initQuickNavigationEntity, "    ");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("    ");
    _builder.append("default:");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("break;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence initQuickNavigationSubmitCall(final String prefix) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("function () { ");
    _builder.append(prefix, "");
    _builder.append("SubmitQuickNavForm(objectType); }");
    return _builder;
  }
  
  private CharSequence initQuickNavigationEntity(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("case \'");
    String _name = it.getName();
    String _formatForCode = this._formattingExtensions.formatForCode(_name);
    _builder.append(_formatForCode, "");
    _builder.append("\':");
    _builder.newLineIfNotEmpty();
    {
      Iterable<JoinRelationship> _bidirectionalIncomingJoinRelationsWithOneSource = this._modelJoinExtensions.getBidirectionalIncomingJoinRelationsWithOneSource(it);
      boolean _isEmpty = IterableExtensions.isEmpty(_bidirectionalIncomingJoinRelationsWithOneSource);
      boolean _not = (!_isEmpty);
      if (_not) {
        {
          Iterable<JoinRelationship> _bidirectionalIncomingJoinRelationsWithOneSource_1 = this._modelJoinExtensions.getBidirectionalIncomingJoinRelationsWithOneSource(it);
          for(final JoinRelationship relation : _bidirectionalIncomingJoinRelationsWithOneSource_1) {
            _builder.append("    ");
            CharSequence _jsInit = this.jsInit(relation);
            _builder.append(_jsInit, "    ");
            _builder.newLineIfNotEmpty();
          }
        }
      }
    }
    {
      boolean _hasListFieldsEntity = this._modelExtensions.hasListFieldsEntity(it);
      if (_hasListFieldsEntity) {
        {
          Iterable<ListField> _listFieldsEntity = this._modelExtensions.getListFieldsEntity(it);
          for(final ListField field : _listFieldsEntity) {
            _builder.append("    ");
            CharSequence _jsInit_1 = this.jsInit(field);
            _builder.append(_jsInit_1, "    ");
            _builder.newLineIfNotEmpty();
          }
        }
      }
    }
    {
      boolean _hasUserFieldsEntity = this._modelExtensions.hasUserFieldsEntity(it);
      if (_hasUserFieldsEntity) {
        {
          Iterable<UserField> _userFieldsEntity = this._modelExtensions.getUserFieldsEntity(it);
          for(final UserField field_1 : _userFieldsEntity) {
            _builder.append("    ");
            CharSequence _jsInit_2 = this.jsInit(field_1);
            _builder.append(_jsInit_2, "    ");
            _builder.newLineIfNotEmpty();
          }
        }
      }
    }
    {
      boolean _hasCountryFieldsEntity = this._modelExtensions.hasCountryFieldsEntity(it);
      if (_hasCountryFieldsEntity) {
        {
          Iterable<StringField> _countryFieldsEntity = this._modelExtensions.getCountryFieldsEntity(it);
          for(final StringField field_2 : _countryFieldsEntity) {
            _builder.append("    ");
            CharSequence _jsInit_3 = this.jsInit(field_2);
            _builder.append(_jsInit_3, "    ");
            _builder.newLineIfNotEmpty();
          }
        }
      }
    }
    {
      boolean _hasLanguageFieldsEntity = this._modelExtensions.hasLanguageFieldsEntity(it);
      if (_hasLanguageFieldsEntity) {
        {
          Iterable<StringField> _languageFieldsEntity = this._modelExtensions.getLanguageFieldsEntity(it);
          for(final StringField field_3 : _languageFieldsEntity) {
            _builder.append("    ");
            CharSequence _jsInit_4 = this.jsInit(field_3);
            _builder.append(_jsInit_4, "    ");
            _builder.newLineIfNotEmpty();
          }
        }
      }
    }
    {
      boolean _hasBooleanFieldsEntity = this._modelExtensions.hasBooleanFieldsEntity(it);
      if (_hasBooleanFieldsEntity) {
        {
          Iterable<BooleanField> _booleanFieldsEntity = this._modelExtensions.getBooleanFieldsEntity(it);
          for(final BooleanField field_4 : _booleanFieldsEntity) {
            _builder.append("    ");
            CharSequence _jsInit_5 = this.jsInit(field_4);
            _builder.append(_jsInit_5, "    ");
            _builder.newLineIfNotEmpty();
          }
        }
      }
    }
    _builder.append("    ");
    _builder.append("break;");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence _jsInit(final DerivedField it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("if ($(\'");
    String _name = it.getName();
    String _formatForCode = this._formattingExtensions.formatForCode(_name);
    _builder.append(_formatForCode, "");
    _builder.append("\') != undefined) {");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("$(\'");
    String _name_1 = it.getName();
    String _formatForCode_1 = this._formattingExtensions.formatForCode(_name_1);
    _builder.append(_formatForCode_1, "    ");
    _builder.append("\').observe(\'change\', ");
    Entity _entity = it.getEntity();
    Models _container = _entity.getContainer();
    Application _application = _container.getApplication();
    String _prefix = _application.getPrefix();
    CharSequence _initQuickNavigationSubmitCall = this.initQuickNavigationSubmitCall(_prefix);
    _builder.append(_initQuickNavigationSubmitCall, "    ");
    _builder.append(");");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence _jsInit(final JoinRelationship it) {
    StringConcatenation _builder = new StringConcatenation();
    final String sourceAliasName = this._namingExtensions.getRelationAliasName(it, Boolean.valueOf(false));
    _builder.newLineIfNotEmpty();
    _builder.append("if ($(\'");
    _builder.append(sourceAliasName, "");
    _builder.append("\') != undefined) {");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("$(\'");
    _builder.append(sourceAliasName, "    ");
    _builder.append("\').observe(\'change\', ");
    Models _container = it.getContainer();
    Application _application = _container.getApplication();
    String _prefix = _application.getPrefix();
    CharSequence _initQuickNavigationSubmitCall = this.initQuickNavigationSubmitCall(_prefix);
    _builder.append(_initQuickNavigationSubmitCall, "    ");
    _builder.append(");");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence initRelationWindow(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Helper function to create new Zikula.UI.Window instances.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* For edit forms we use \"iframe: true\" to ensure file uploads work without problems.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* For all other windows we use \"iframe: false\" because we want the escape key working.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("function ");
    String _prefix = this._utils.prefix(it);
    _builder.append(_prefix, "");
    _builder.append("InitInlineWindow(containerElem, title) {");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("var newWindow;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// show the container (hidden for users without JavaScript)");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("containerElem.removeClassName(\'z-hide\');");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// define the new window instance");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("newWindow = new Zikula.UI.Window(");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("containerElem,");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("{");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("minmax: true,");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("resizable: true,");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("title: title,");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("width: 600,");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("initMaxHeight: 400,");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("modal: false,");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("iframe: false");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append(");");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// return the instance");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return newWindow;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence initToggle(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Initialise ajax-based toggle for boolean fields.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("function ");
    String _prefix = this._utils.prefix(it);
    _builder.append(_prefix, "");
    _builder.append("InitToggle(objectType, fieldName, itemId)");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("var idSuffix = fieldName.toLowerCase() + itemId;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($(\'toggle\' + idSuffix) == undefined) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$(\'toggle\' + idSuffix).observe(\'click\', function() {");
    _builder.newLine();
    _builder.append("        ");
    String _prefix_1 = this._utils.prefix(it);
    _builder.append(_prefix_1, "        ");
    _builder.append("ToggleFlag(objectType, fieldName, itemId);");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("}).removeClassName(\'z-hide\');");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence toggleFlag(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Toggle a certain flag for a given item.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("function ");
    String _prefix = this._utils.prefix(it);
    _builder.append(_prefix, "");
    _builder.append("ToggleFlag(objectType, fieldName, itemId)");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("var pars = \'ot=\' + objectType + \'&field=\' + fieldName + \'&id=\' + itemId;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("new Zikula.Ajax.Request(");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("Zikula.Config.baseURL + \'ajax.php?module=");
    String _appName = this._utils.appName(it);
    _builder.append(_appName, "        ");
    {
      boolean _targets = this._utils.targets(it, "1.3.5");
      boolean _not = (!_targets);
      if (_not) {
        _builder.append("&type=ajax");
      }
    }
    _builder.append("&func=toggleFlag\',");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("{");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("method: \'post\',");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("parameters: pars,");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("onComplete: function(req) {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("if (!req.isSuccess()) {");
    _builder.newLine();
    _builder.append("                    ");
    _builder.append("Zikula.UI.Alert(req.getMessage(), Zikula.__(\'Error\', \'module_");
    String _appName_1 = this._utils.appName(it);
    _builder.append(_appName_1, "                    ");
    _builder.append("\'));");
    _builder.newLineIfNotEmpty();
    _builder.append("                    ");
    _builder.append("return;");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("var data = req.getData();");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("/*if (data.message) {");
    _builder.newLine();
    _builder.append("                    ");
    _builder.append("Zikula.UI.Alert(data.message, Zikula.__(\'Success\', \'module_");
    String _appName_2 = this._utils.appName(it);
    _builder.append(_appName_2, "                    ");
    _builder.append("\'));");
    _builder.newLineIfNotEmpty();
    _builder.append("                ");
    _builder.append("}*/");
    _builder.newLine();
    _builder.newLine();
    _builder.append("                ");
    _builder.append("var idSuffix = fieldName.toLowerCase() + \'_\' + itemId;");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("var state = data.state;");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("if (state === true) {");
    _builder.newLine();
    _builder.append("                    ");
    _builder.append("$(\'no\' + idSuffix).addClassName(\'z-hide\');");
    _builder.newLine();
    _builder.append("                    ");
    _builder.append("$(\'yes\' + idSuffix).removeClassName(\'z-hide\');");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("} else {");
    _builder.newLine();
    _builder.append("                    ");
    _builder.append("$(\'yes\' + idSuffix).addClassName(\'z-hide\');");
    _builder.newLine();
    _builder.append("                    ");
    _builder.append("$(\'no\' + idSuffix).removeClassName(\'z-hide\');");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append(");");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence jsInit(final EObject it) {
    if (it instanceof DerivedField) {
      return _jsInit((DerivedField)it);
    } else if (it instanceof JoinRelationship) {
      return _jsInit((JoinRelationship)it);
    } else {
      throw new IllegalArgumentException("Unhandled parameter types: " +
        Arrays.<Object>asList(it).toString());
    }
  }
}
