package org.zikula.modulestudio.generator.cartridges.zclassic.view;

import com.google.common.base.Objects;
import com.google.common.collect.Iterables;
import com.google.inject.Inject;
import de.guite.modulestudio.metamodel.modulestudio.AbstractDateField;
import de.guite.modulestudio.metamodel.modulestudio.Action;
import de.guite.modulestudio.metamodel.modulestudio.AdminController;
import de.guite.modulestudio.metamodel.modulestudio.Application;
import de.guite.modulestudio.metamodel.modulestudio.Controller;
import de.guite.modulestudio.metamodel.modulestudio.DateField;
import de.guite.modulestudio.metamodel.modulestudio.DatetimeField;
import de.guite.modulestudio.metamodel.modulestudio.DerivedField;
import de.guite.modulestudio.metamodel.modulestudio.EditAction;
import de.guite.modulestudio.metamodel.modulestudio.Entity;
import de.guite.modulestudio.metamodel.modulestudio.JoinRelationship;
import de.guite.modulestudio.metamodel.modulestudio.Models;
import de.guite.modulestudio.metamodel.modulestudio.UploadField;
import de.guite.modulestudio.metamodel.modulestudio.UserField;
import java.util.ArrayList;
import java.util.List;
import org.eclipse.emf.common.util.EList;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.CollectionLiterals;
import org.eclipse.xtext.xbase.lib.Conversions;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.InputOutput;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.eclipse.xtext.xbase.lib.StringExtensions;
import org.zikula.modulestudio.generator.cartridges.zclassic.view.formcomponents.Relations;
import org.zikula.modulestudio.generator.cartridges.zclassic.view.formcomponents.Section;
import org.zikula.modulestudio.generator.cartridges.zclassic.view.formcomponents.SimpleFields;
import org.zikula.modulestudio.generator.extensions.ControllerExtensions;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;
import org.zikula.modulestudio.generator.extensions.ViewExtensions;

@SuppressWarnings("all")
public class Forms {
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
  private ModelBehaviourExtensions _modelBehaviourExtensions = new Function0<ModelBehaviourExtensions>() {
    public ModelBehaviourExtensions apply() {
      ModelBehaviourExtensions _modelBehaviourExtensions = new ModelBehaviourExtensions();
      return _modelBehaviourExtensions;
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
  
  @Inject
  @Extension
  private ViewExtensions _viewExtensions = new Function0<ViewExtensions>() {
    public ViewExtensions apply() {
      ViewExtensions _viewExtensions = new ViewExtensions();
      return _viewExtensions;
    }
  }.apply();
  
  private SimpleFields fieldHelper = new Function0<SimpleFields>() {
    public SimpleFields apply() {
      SimpleFields _simpleFields = new SimpleFields();
      return _simpleFields;
    }
  }.apply();
  
  private Relations relationHelper = new Function0<Relations>() {
    public Relations apply() {
      Relations _relations = new Relations();
      return _relations;
    }
  }.apply();
  
  public void generate(final Application it, final IFileSystemAccess fsa) {
    EList<Controller> _allControllers = this._controllerExtensions.getAllControllers(it);
    for (final Controller controller : _allControllers) {
      EList<Action> _actions = controller.getActions();
      Iterable<EditAction> _filter = Iterables.<EditAction>filter(_actions, EditAction.class);
      for (final EditAction action : _filter) {
        this.generate(action, it, fsa);
      }
    }
  }
  
  /**
   * Entry point for form templates for each action.
   */
  private void generate(final Action it, final Application app, final IFileSystemAccess fsa) {
    EList<Entity> _allEntities = this._modelExtensions.getAllEntities(app);
    for (final Entity entity : _allEntities) {
      Controller _controller = it.getController();
      this.generate(entity, app, _controller, "edit", fsa);
    }
    Controller _controller_1 = it.getController();
    this.inlineRedirectHandlerFile(_controller_1, app, fsa);
  }
  
  /**
   * Entry point for form templates for each entity.
   */
  private CharSequence generate(final Entity it, final Application app, final Controller controller, final String actionName, final IFileSystemAccess fsa) {
    CharSequence _xblockexpression = null;
    {
      String _formattedName = this._controllerExtensions.formattedName(controller);
      String _plus = ("Generating " + _formattedName);
      String _plus_1 = (_plus + " edit form templates for entity \"");
      String _name = it.getName();
      String _formatForDisplay = this._formattingExtensions.formatForDisplay(_name);
      String _plus_2 = (_plus_1 + _formatForDisplay);
      String _plus_3 = (_plus_2 + "\"");
      InputOutput.<String>println(_plus_3);
      String _name_1 = it.getName();
      String _editTemplateFile = this._namingExtensions.editTemplateFile(controller, _name_1, actionName);
      StringConcatenation _builder = new StringConcatenation();
      CharSequence _formTemplateHeader = this.formTemplateHeader(it, app, controller, actionName);
      _builder.append(_formTemplateHeader, "");
      _builder.newLineIfNotEmpty();
      CharSequence _formTemplateBody = this.formTemplateBody(it, app, controller, actionName, fsa);
      _builder.append(_formTemplateBody, "");
      _builder.newLineIfNotEmpty();
      fsa.generateFile(_editTemplateFile, _builder);
      CharSequence _generateInclusionTemplate = this.relationHelper.generateInclusionTemplate(it, app, controller, fsa);
      _xblockexpression = (_generateInclusionTemplate);
    }
    return _xblockexpression;
  }
  
  private CharSequence formTemplateHeader(final Entity it, final Application app, final Controller controller, final String actionName) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{* purpose of this template: build the Form to ");
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(actionName);
    _builder.append(_formatForDisplay, "");
    _builder.append(" an instance of ");
    String _name = it.getName();
    String _formatForDisplay_1 = this._formattingExtensions.formatForDisplay(_name);
    _builder.append(_formatForDisplay_1, "");
    _builder.append(" *}");
    _builder.newLineIfNotEmpty();
    _builder.append("{include file=\'");
    {
      boolean _targets = this._utils.targets(app, "1.3.5");
      if (_targets) {
        String _formattedName = this._controllerExtensions.formattedName(controller);
        _builder.append(_formattedName, "");
      } else {
        String _formattedName_1 = this._controllerExtensions.formattedName(controller);
        String _firstUpper = StringExtensions.toFirstUpper(_formattedName_1);
        _builder.append(_firstUpper, "");
      }
    }
    _builder.append("/header.tpl\'}");
    _builder.newLineIfNotEmpty();
    _builder.append("{pageaddvar name=\'javascript\' value=\'modules/");
    String _appName = this._utils.appName(app);
    _builder.append(_appName, "");
    _builder.append("/");
    {
      boolean _targets_1 = this._utils.targets(app, "1.3.5");
      if (_targets_1) {
        _builder.append("javascript/");
      } else {
        String _appJsPath = this._namingExtensions.getAppJsPath(app);
        _builder.append(_appJsPath, "");
      }
    }
    String _appName_1 = this._utils.appName(app);
    _builder.append(_appName_1, "");
    _builder.append("_editFunctions.js\'}");
    _builder.newLineIfNotEmpty();
    _builder.append("{pageaddvar name=\'javascript\' value=\'modules/");
    String _appName_2 = this._utils.appName(app);
    _builder.append(_appName_2, "");
    _builder.append("/");
    {
      boolean _targets_2 = this._utils.targets(app, "1.3.5");
      if (_targets_2) {
        _builder.append("javascript/");
      } else {
        String _appJsPath_1 = this._namingExtensions.getAppJsPath(app);
        _builder.append(_appJsPath_1, "");
      }
    }
    String _appName_3 = this._utils.appName(app);
    _builder.append(_appName_3, "");
    _builder.append("_validation.js\'}");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("{if $mode eq \'edit\'}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{gt text=\'Edit ");
    String _name_1 = it.getName();
    String _formatForDisplay_2 = this._formattingExtensions.formatForDisplay(_name_1);
    _builder.append(_formatForDisplay_2, "    ");
    _builder.append("\' assign=\'templateTitle\'}");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    CharSequence _pageIcon = this.pageIcon(controller, "edit");
    _builder.append(_pageIcon, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("{elseif $mode eq \'create\'}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{gt text=\'Create ");
    String _name_2 = it.getName();
    String _formatForDisplay_3 = this._formattingExtensions.formatForDisplay(_name_2);
    _builder.append(_formatForDisplay_3, "    ");
    _builder.append("\' assign=\'templateTitle\'}");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    CharSequence _pageIcon_1 = this.pageIcon(controller, "new");
    _builder.append(_pageIcon_1, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("{else}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{gt text=\'Edit ");
    String _name_3 = it.getName();
    String _formatForDisplay_4 = this._formattingExtensions.formatForDisplay(_name_3);
    _builder.append(_formatForDisplay_4, "    ");
    _builder.append("\' assign=\'templateTitle\'}");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    CharSequence _pageIcon_2 = this.pageIcon(controller, "edit");
    _builder.append(_pageIcon_2, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("{/if}");
    _builder.newLine();
    _builder.append("<div class=\"");
    String _appName_4 = this._utils.appName(app);
    String _lowerCase = _appName_4.toLowerCase();
    _builder.append(_lowerCase, "");
    _builder.append("-");
    String _name_4 = it.getName();
    String _formatForDB = this._formattingExtensions.formatForDB(_name_4);
    _builder.append(_formatForDB, "");
    _builder.append(" ");
    String _appName_5 = this._utils.appName(app);
    String _lowerCase_1 = _appName_5.toLowerCase();
    _builder.append(_lowerCase_1, "");
    _builder.append("-edit\">");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("{pagesetvar name=\'title\' value=$templateTitle}");
    _builder.newLine();
    _builder.append("    ");
    CharSequence _templateHeader = this.templateHeader(controller);
    _builder.append(_templateHeader, "    ");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence pageIcon(final Controller it, final String iconName) {
    CharSequence _switchResult = null;
    boolean _matched = false;
    if (!_matched) {
      if (it instanceof AdminController) {
        final AdminController _adminController = (AdminController)it;
        _matched=true;
        StringConcatenation _builder = new StringConcatenation();
        _builder.append("{assign var=\'adminPageIcon\' value=\'");
        _builder.append(iconName, "");
        _builder.append("\'}");
        _builder.newLineIfNotEmpty();
        _switchResult = _builder;
      }
    }
    if (!_matched) {
      _switchResult = "";
    }
    return _switchResult;
  }
  
  private CharSequence templateHeader(final Controller it) {
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
        _builder.append("{icon type=$adminPageIcon size=\'small\' alt=$templateTitle}");
        _builder.newLine();
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
  
  private CharSequence formTemplateBody(final Entity it, final Application app, final Controller controller, final String actionName, final IFileSystemAccess fsa) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{form ");
    {
      boolean _hasUploadFieldsEntity = this._modelExtensions.hasUploadFieldsEntity(it);
      if (_hasUploadFieldsEntity) {
        _builder.append("enctype=\'multipart/form-data\' ");
      }
    }
    _builder.append("cssClass=\'z-form\'}");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("{* add validation summary and a <div> element for styling the form *}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{");
    String _appName = this._utils.appName(app);
    String _formatForDB = this._formattingExtensions.formatForDB(_appName);
    _builder.append(_formatForDB, "    ");
    _builder.append("FormFrame}");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    {
      List<DerivedField> _editableFields = this._modelExtensions.getEditableFields(it);
      boolean _isEmpty = _editableFields.isEmpty();
      boolean _not = (!_isEmpty);
      if (_not) {
        _builder.append("    ");
        _builder.append("{formsetinitialfocus inputId=\'");
        List<DerivedField> _editableFields_1 = this._modelExtensions.getEditableFields(it);
        DerivedField _head = IterableExtensions.<DerivedField>head(_editableFields_1);
        String _name = _head.getName();
        String _formatForCode = this._formattingExtensions.formatForCode(_name);
        _builder.append(_formatForCode, "    ");
        _builder.append("\'}");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
      }
    }
    _builder.newLine();
    {
      boolean _useGroupingPanels = this._viewExtensions.useGroupingPanels(it, "edit");
      if (_useGroupingPanels) {
        _builder.append("    ");
        _builder.append("<div class=\"z-panels\" id=\"");
        String _appName_1 = this._utils.appName(app);
        _builder.append(_appName_1, "    ");
        _builder.append("_panel\">");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("<h3 id=\"z-panel-header-fields\" class=\"z-panel-header z-panel-indicator z-pointer\">{gt text=\'Fields\'}</h3>");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("<div class=\"z-panel-content z-panel-active\" style=\"overflow: visible\">");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("        ");
        CharSequence _fieldDetails = this.fieldDetails(it, app, controller);
        _builder.append(_fieldDetails, "            ");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("</div>");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        Section _section = new Section();
        CharSequence _generate = _section.generate(it, app, controller, fsa);
        _builder.append(_generate, "        ");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("</div>");
        _builder.newLine();
      } else {
        _builder.append("    ");
        CharSequence _fieldDetails_1 = this.fieldDetails(it, app, controller);
        _builder.append(_fieldDetails_1, "    ");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        Section _section_1 = new Section();
        CharSequence _generate_1 = _section_1.generate(it, app, controller, fsa);
        _builder.append(_generate_1, "    ");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("    ");
    _builder.append("{/");
    String _appName_2 = this._utils.appName(app);
    String _formatForDB_1 = this._formattingExtensions.formatForDB(_appName_2);
    _builder.append(_formatForDB_1, "    ");
    _builder.append("FormFrame}");
    _builder.newLineIfNotEmpty();
    _builder.append("{/form}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    CharSequence _templateFooter = this.templateFooter(controller);
    _builder.append(_templateFooter, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("</div>");
    _builder.newLine();
    _builder.append("{include file=\'");
    {
      boolean _targets = this._utils.targets(app, "1.3.5");
      if (_targets) {
        String _formattedName = this._controllerExtensions.formattedName(controller);
        _builder.append(_formattedName, "");
      } else {
        String _formattedName_1 = this._controllerExtensions.formattedName(controller);
        String _firstUpper = StringExtensions.toFirstUpper(_formattedName_1);
        _builder.append(_firstUpper, "");
      }
    }
    _builder.append("/footer.tpl\'}");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    CharSequence _formTemplateJS = this.formTemplateJS(it, app, controller, actionName);
    _builder.append(_formTemplateJS, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence fieldDetails(final Entity it, final Application app, final Controller controller) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _hasTranslatableFields = this._modelBehaviourExtensions.hasTranslatableFields(it);
      if (_hasTranslatableFields) {
        _builder.append("{formvolatile}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("{assign var=\'useOnlyCurrentLocale\' value=true}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("{if $modvars.ZConfig.multilingual}");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("{if $supportedLocales ne \'\' && is_array($supportedLocales) && count($supportedLocales) > 1}");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("{assign var=\'useOnlyCurrentLocale\' value=false}");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("{nocache}");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("{lang assign=\'currentLanguage\'}");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("{foreach item=\'locale\' from=$supportedLocales}");
        _builder.newLine();
        _builder.append("                ");
        _builder.append("{if $locale eq $currentLanguage}");
        _builder.newLine();
        _builder.append("                    ");
        CharSequence _translatableFieldSet = this.translatableFieldSet(it, "", "");
        _builder.append(_translatableFieldSet, "                    ");
        _builder.newLineIfNotEmpty();
        _builder.append("                ");
        _builder.append("{/if}");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("{/foreach}");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("{foreach item=\'locale\' from=$supportedLocales}");
        _builder.newLine();
        _builder.append("                ");
        _builder.append("{if $locale ne $currentLanguage}");
        _builder.newLine();
        _builder.append("                    ");
        CharSequence _translatableFieldSet_1 = this.translatableFieldSet(it, "$locale", "$locale");
        _builder.append(_translatableFieldSet_1, "                    ");
        _builder.newLineIfNotEmpty();
        _builder.append("                ");
        _builder.append("{/if}");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("{/foreach}");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("{/nocache}");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("{/if}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("{/if}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("{if $useOnlyCurrentLocale eq true}");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("{lang assign=\'locale\'}");
        _builder.newLine();
        _builder.append("        ");
        CharSequence _translatableFieldSet_2 = this.translatableFieldSet(it, "", "");
        _builder.append(_translatableFieldSet_2, "        ");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("{/if}");
        _builder.newLine();
        _builder.append("{/formvolatile}");
        _builder.newLine();
      }
    }
    {
      boolean _or = false;
      boolean _or_1 = false;
      boolean _hasTranslatableFields_1 = this._modelBehaviourExtensions.hasTranslatableFields(it);
      boolean _not = (!_hasTranslatableFields_1);
      if (_not) {
        _or_1 = true;
      } else {
        boolean _and = false;
        boolean _hasTranslatableFields_2 = this._modelBehaviourExtensions.hasTranslatableFields(it);
        if (!_hasTranslatableFields_2) {
          _and = false;
        } else {
          boolean _or_2 = false;
          Iterable<DerivedField> _editableNonTranslatableFields = this._modelBehaviourExtensions.getEditableNonTranslatableFields(it);
          boolean _isEmpty = IterableExtensions.isEmpty(_editableNonTranslatableFields);
          boolean _not_1 = (!_isEmpty);
          if (_not_1) {
            _or_2 = true;
          } else {
            boolean _and_1 = false;
            boolean _hasSluggableFields = this._modelBehaviourExtensions.hasSluggableFields(it);
            if (!_hasSluggableFields) {
              _and_1 = false;
            } else {
              boolean _hasTranslatableSlug = this._modelBehaviourExtensions.hasTranslatableSlug(it);
              boolean _not_2 = (!_hasTranslatableSlug);
              _and_1 = (_hasSluggableFields && _not_2);
            }
            _or_2 = (_not_1 || _and_1);
          }
          _and = (_hasTranslatableFields_2 && _or_2);
        }
        _or_1 = (_not || _and);
      }
      if (_or_1) {
        _or = true;
      } else {
        boolean _isGeographical = it.isGeographical();
        _or = (_or_1 || _isGeographical);
      }
      if (_or) {
        _builder.append("<fieldset>");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("<legend>{gt text=\'");
        {
          boolean _hasTranslatableFields_3 = this._modelBehaviourExtensions.hasTranslatableFields(it);
          if (_hasTranslatableFields_3) {
            _builder.append("Further properties");
          } else {
            _builder.append("Content");
          }
        }
        _builder.append("\'}</legend>");
        _builder.newLineIfNotEmpty();
        {
          boolean _hasTranslatableFields_4 = this._modelBehaviourExtensions.hasTranslatableFields(it);
          if (_hasTranslatableFields_4) {
            _builder.append("    ");
            {
              Iterable<DerivedField> _editableNonTranslatableFields_1 = this._modelBehaviourExtensions.getEditableNonTranslatableFields(it);
              for(final DerivedField field : _editableNonTranslatableFields_1) {
                CharSequence _fieldWrapper = this.fieldWrapper(field, "", "");
                _builder.append(_fieldWrapper, "    ");
              }
            }
            _builder.newLineIfNotEmpty();
          } else {
            _builder.append("    ");
            {
              List<DerivedField> _editableFields = this._modelExtensions.getEditableFields(it);
              for(final DerivedField field_1 : _editableFields) {
                CharSequence _fieldWrapper_1 = this.fieldWrapper(field_1, "", "");
                _builder.append(_fieldWrapper_1, "    ");
              }
            }
            _builder.newLineIfNotEmpty();
          }
        }
        {
          boolean _or_3 = false;
          boolean _hasTranslatableFields_5 = this._modelBehaviourExtensions.hasTranslatableFields(it);
          boolean _not_3 = (!_hasTranslatableFields_5);
          if (_not_3) {
            _or_3 = true;
          } else {
            boolean _and_2 = false;
            boolean _hasSluggableFields_1 = this._modelBehaviourExtensions.hasSluggableFields(it);
            if (!_hasSluggableFields_1) {
              _and_2 = false;
            } else {
              boolean _hasTranslatableSlug_1 = this._modelBehaviourExtensions.hasTranslatableSlug(it);
              boolean _not_4 = (!_hasTranslatableSlug_1);
              _and_2 = (_hasSluggableFields_1 && _not_4);
            }
            _or_3 = (_not_3 || _and_2);
          }
          if (_or_3) {
            _builder.append("    ");
            CharSequence _slugField = this.slugField(it, "", "");
            _builder.append(_slugField, "    ");
            _builder.newLineIfNotEmpty();
          }
        }
        {
          boolean _isGeographical_1 = it.isGeographical();
          if (_isGeographical_1) {
            {
              ArrayList<String> _newArrayList = CollectionLiterals.<String>newArrayList("latitude", "longitude");
              for(final String geoFieldName : _newArrayList) {
                _builder.append("    ");
                _builder.append("<div class=\"z-formrow\">");
                _builder.newLine();
                _builder.append("    ");
                _builder.append("    ");
                _builder.append("{formlabel for=\'");
                _builder.append(geoFieldName, "        ");
                _builder.append("\' __text=\'");
                String _firstUpper = StringExtensions.toFirstUpper(geoFieldName);
                _builder.append(_firstUpper, "        ");
                _builder.append("\'}");
                _builder.newLineIfNotEmpty();
                _builder.append("    ");
                _builder.append("    ");
                _builder.append("{");
                String _appName = this._utils.appName(app);
                String _formatForDB = this._formattingExtensions.formatForDB(_appName);
                _builder.append(_formatForDB, "        ");
                _builder.append("GeoInput group=\'");
                String _name = it.getName();
                String _formatForDB_1 = this._formattingExtensions.formatForDB(_name);
                _builder.append(_formatForDB_1, "        ");
                _builder.append("\' id=\'");
                _builder.append(geoFieldName, "        ");
                _builder.append("\' mandatory=false __title=\'Enter the ");
                _builder.append(geoFieldName, "        ");
                _builder.append(" of the ");
                String _name_1 = it.getName();
                String _formatForDisplay = this._formattingExtensions.formatForDisplay(_name_1);
                _builder.append(_formatForDisplay, "        ");
                _builder.append("\' cssClass=\'validate-number\'}");
                _builder.newLineIfNotEmpty();
                _builder.append("    ");
                _builder.append("    ");
                _builder.append("{");
                String _appName_1 = this._utils.appName(app);
                String _formatForDB_2 = this._formattingExtensions.formatForDB(_appName_1);
                _builder.append(_formatForDB_2, "        ");
                _builder.append("ValidationError id=\'");
                _builder.append(geoFieldName, "        ");
                _builder.append("\' class=\'validate-number\'}");
                _builder.newLineIfNotEmpty();
                _builder.append("    ");
                _builder.append("</div>");
                _builder.newLine();
              }
            }
          }
        }
        _builder.append("</fieldset>");
        _builder.newLine();
      }
    }
    return _builder;
  }
  
  private CharSequence translatableFieldSet(final Entity it, final String groupSuffix, final String idSuffix) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("<fieldset>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<legend>{$locale|getlanguagename|safehtml}</legend>");
    _builder.newLine();
    _builder.append("    ");
    {
      Iterable<DerivedField> _editableTranslatableFields = this._modelBehaviourExtensions.getEditableTranslatableFields(it);
      for(final DerivedField field : _editableTranslatableFields) {
        CharSequence _fieldWrapper = this.fieldWrapper(field, groupSuffix, idSuffix);
        _builder.append(_fieldWrapper, "    ");
      }
    }
    _builder.newLineIfNotEmpty();
    {
      boolean _hasTranslatableSlug = this._modelBehaviourExtensions.hasTranslatableSlug(it);
      if (_hasTranslatableSlug) {
        _builder.append("    ");
        CharSequence _slugField = this.slugField(it, groupSuffix, idSuffix);
        _builder.append(_slugField, "    ");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("</fieldset>");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence slugField(final Entity it, final String groupSuffix, final String idSuffix) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _and = false;
      boolean _and_1 = false;
      boolean _hasSluggableFields = this._modelBehaviourExtensions.hasSluggableFields(it);
      if (!_hasSluggableFields) {
        _and_1 = false;
      } else {
        boolean _isSlugUpdatable = it.isSlugUpdatable();
        _and_1 = (_hasSluggableFields && _isSlugUpdatable);
      }
      if (!_and_1) {
        _and = false;
      } else {
        Models _container = it.getContainer();
        Application _application = _container.getApplication();
        boolean _targets = this._utils.targets(_application, "1.3.5");
        boolean _not = (!_targets);
        _and = (_and_1 && _not);
      }
      if (_and) {
        _builder.append("    ");
        _builder.append("<div class=\"z-formrow\">");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("{formlabel for=");
        String _templateIdWithSuffix = this._utils.templateIdWithSuffix("slug", idSuffix);
        _builder.append(_templateIdWithSuffix, "        ");
        _builder.append(" __text=\'Permalink\'");
        _builder.append("}");
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        _builder.append("{formtextinput group=");
        String _name = it.getName();
        String _formatForDB = this._formattingExtensions.formatForDB(_name);
        String _templateIdWithSuffix_1 = this._utils.templateIdWithSuffix(_formatForDB, groupSuffix);
        _builder.append(_templateIdWithSuffix_1, "        ");
        _builder.append(" id=");
        String _templateIdWithSuffix_2 = this._utils.templateIdWithSuffix("slug", idSuffix);
        _builder.append(_templateIdWithSuffix_2, "        ");
        _builder.append(" mandatory=false");
        _builder.append(" readOnly=false __title=\'You can input a custom permalink for the ");
        String _name_1 = it.getName();
        String _formatForDisplay = this._formattingExtensions.formatForDisplay(_name_1);
        _builder.append(_formatForDisplay, "        ");
        {
          boolean _isSlugUnique = it.isSlugUnique();
          boolean _not_1 = (!_isSlugUnique);
          if (_not_1) {
            _builder.append(" or let this field free to create one automatically");
          }
        }
        _builder.append("\' textMode=\'singleline\' maxLength=255");
        {
          boolean _isSlugUnique_1 = it.isSlugUnique();
          if (_isSlugUnique_1) {
            _builder.append(" cssClass=\'");
            _builder.append("validate-unique\'");
          }
        }
        _builder.append("}");
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        _builder.append("<div class=\"z-formnote z-sub\">{gt text=\'You can input a custom permalink for the ");
        String _name_2 = it.getName();
        String _formatForDisplay_1 = this._formattingExtensions.formatForDisplay(_name_2);
        _builder.append(_formatForDisplay_1, "        ");
        {
          boolean _isSlugUnique_2 = it.isSlugUnique();
          boolean _not_2 = (!_isSlugUnique_2);
          if (_not_2) {
            _builder.append(" or let this field free to create one automatically");
          }
        }
        _builder.append("\'}</div>");
        _builder.newLineIfNotEmpty();
        {
          boolean _isSlugUnique_3 = it.isSlugUnique();
          if (_isSlugUnique_3) {
            _builder.append("    ");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("{");
            Models _container_1 = it.getContainer();
            Application _application_1 = _container_1.getApplication();
            String _appName = this._utils.appName(_application_1);
            String _formatForDB_1 = this._formattingExtensions.formatForDB(_appName);
            _builder.append(_formatForDB_1, "    ");
            _builder.append("ValidationError id=");
            String _templateIdWithSuffix_3 = this._utils.templateIdWithSuffix("slug", idSuffix);
            _builder.append(_templateIdWithSuffix_3, "    ");
            _builder.append(" class=\'validate-unique\'}");
            _builder.newLineIfNotEmpty();
          }
        }
        _builder.append("</div>");
        _builder.newLine();
      }
    }
    return _builder;
  }
  
  private CharSequence formTemplateJS(final Entity it, final Application app, final Controller controller, final String actionName) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{icon type=\'edit\' size=\'extrasmall\' assign=\'editImageArray\'}");
    _builder.newLine();
    _builder.append("{icon type=\'delete\' size=\'extrasmall\' assign=\'deleteImageArray\'}");
    _builder.newLine();
    _builder.newLine();
    {
      boolean _isGeographical = it.isGeographical();
      if (_isGeographical) {
        _builder.append("{pageaddvarblock name=\'header\'}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("<script type=\"text/javascript\" src=\"http://maps.google.com/maps/api/js?sensor=false\"></script>");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("<script type=\"text/javascript\" src=\"{$baseurl}plugins/Mapstraction/lib/vendor/mxn/mxn.js?(googlev3)\"></script>");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("<script type=\"text/javascript\">");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("/* <![CDATA[ */");
        _builder.newLine();
        _builder.newLine();
        _builder.append("        ");
        _builder.append("var mapstraction;");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("var marker;");
        _builder.newLine();
        _builder.newLine();
        _builder.append("        ");
        _builder.append("function newCoordinatesEventHandler() {");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("var location = new mxn.LatLonPoint($F(\'latitude\'), $F(\'longitude\'));");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("marker.hide();");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("mapstraction.removeMarker(marker);");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("marker = new mxn.Marker(location);");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("mapstraction.addMarker(marker,true);");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("mapstraction.setCenterAndZoom(location, 18);");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("}");
        _builder.newLine();
        _builder.newLine();
        _builder.append("        ");
        _builder.append("Event.observe(window, \'load\', function() {");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("mapstraction = new mxn.Mapstraction(\'mapcontainer\', \'googlev3\');");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("mapstraction.addControls({");
        _builder.newLine();
        _builder.append("                ");
        _builder.append("pan: true,");
        _builder.newLine();
        _builder.append("                ");
        _builder.append("zoom: \'small\',");
        _builder.newLine();
        _builder.append("                ");
        _builder.append("map_type: true");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("});");
        _builder.newLine();
        _builder.newLine();
        _builder.append("            ");
        _builder.append("var latlon = new mxn.LatLonPoint({{$");
        String _name = it.getName();
        String _formatForDB = this._formattingExtensions.formatForDB(_name);
        _builder.append(_formatForDB, "            ");
        _builder.append(".latitude|");
        String _appName = this._utils.appName(app);
        String _formatForDB_1 = this._formattingExtensions.formatForDB(_appName);
        _builder.append(_formatForDB_1, "            ");
        _builder.append("FormatGeoData}}, {{$");
        String _name_1 = it.getName();
        String _formatForDB_2 = this._formattingExtensions.formatForDB(_name_1);
        _builder.append(_formatForDB_2, "            ");
        _builder.append(".longitude|");
        String _appName_1 = this._utils.appName(app);
        String _formatForDB_3 = this._formattingExtensions.formatForDB(_appName_1);
        _builder.append(_formatForDB_3, "            ");
        _builder.append("FormatGeoData}});");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
        _builder.append("            ");
        _builder.append("mapstraction.setMapType(mxn.Mapstraction.SATELLITE);");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("mapstraction.setCenterAndZoom(latlon, 16);");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("mapstraction.mousePosition(\'position\');");
        _builder.newLine();
        _builder.newLine();
        _builder.append("            ");
        _builder.append("// add a marker");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("marker = new mxn.Marker(latlon);");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("mapstraction.addMarker(marker, true);");
        _builder.newLine();
        _builder.newLine();
        _builder.append("            ");
        _builder.append("$(\'latitude\').observe(\'change\', function() {");
        _builder.newLine();
        _builder.append("                ");
        _builder.append("newCoordinatesEventHandler();");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("});");
        _builder.newLine();
        _builder.newLine();
        _builder.append("            ");
        _builder.append("$(\'longitude\').observe(\'change\', function() {");
        _builder.newLine();
        _builder.append("                ");
        _builder.append("newCoordinatesEventHandler();");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("});");
        _builder.newLine();
        _builder.newLine();
        _builder.append("            ");
        _builder.append("mapstraction.click.addHandler(function(event_name, event_source, event_args){");
        _builder.newLine();
        _builder.append("                ");
        _builder.append("var coords = event_args.location;");
        _builder.newLine();
        _builder.append("                ");
        _builder.append("Form.Element.setValue(\'latitude\', coords.lat.toFixed(7));");
        _builder.newLine();
        _builder.append("                ");
        _builder.append("Form.Element.setValue(\'longitude\', coords.lng.toFixed(7));");
        _builder.newLine();
        _builder.append("                ");
        _builder.append("newCoordinatesEventHandler();");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("});");
        _builder.newLine();
        _builder.newLine();
        _builder.append("            ");
        _builder.append("{{if $mode eq \'create\'}}");
        _builder.newLine();
        _builder.append("                ");
        _builder.append("// derive default coordinates from users position with html5 geolocation feature");
        _builder.newLine();
        _builder.append("                ");
        _builder.append("if (navigator.geolocation) {");
        _builder.newLine();
        _builder.append("                    ");
        _builder.append("navigator.geolocation.getCurrentPosition(setDefaultCoordinates, handlePositionError);");
        _builder.newLine();
        _builder.append("                ");
        _builder.append("}");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("{{/if}}");
        _builder.newLine();
        _builder.newLine();
        _builder.append("            ");
        _builder.append("function setDefaultCoordinates(position) {");
        _builder.newLine();
        _builder.append("                ");
        _builder.append("$(\'latitude\').value = position.coords.latitude.toFixed(7);");
        _builder.newLine();
        _builder.append("                ");
        _builder.append("$(\'longitude\').value = position.coords.longitude.toFixed(7);");
        _builder.newLine();
        _builder.append("                ");
        _builder.append("newCoordinatesEventHandler();");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("}");
        _builder.newLine();
        _builder.newLine();
        _builder.append("            ");
        _builder.append("function handlePositionError(evt) {");
        _builder.newLine();
        _builder.append("                ");
        _builder.append("Zikula.UI.Alert(evt.message, Zikula.__(\'Error during geolocation\', \'module_");
        String _appName_2 = this._utils.appName(app);
        String _formatForDB_4 = this._formattingExtensions.formatForDB(_appName_2);
        _builder.append(_formatForDB_4, "                ");
        _builder.append("\'));");
        _builder.newLineIfNotEmpty();
        _builder.append("            ");
        _builder.append("}");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("{{*");
        _builder.newLine();
        _builder.append("                ");
        _builder.append("Initialise geocoding functionality.");
        _builder.newLine();
        _builder.append("                ");
        _builder.append("In contrast to the map picker this one determines coordinates for a given address.");
        _builder.newLine();
        _builder.append("                ");
        _builder.append("To use this please customise the form field names inside the function to your needs.");
        _builder.newLine();
        _builder.append("                ");
        _builder.append("You can find it in ");
        String _appJsPath = this._namingExtensions.getAppJsPath(app);
        _builder.append(_appJsPath, "                ");
        String _appName_3 = this._utils.appName(app);
        _builder.append(_appName_3, "                ");
        _builder.append("_editFunctions.js");
        _builder.newLineIfNotEmpty();
        _builder.append("                ");
        _builder.append("Furthermore you will need a link or a button with id=\"linkGetCoordinates\" which will");
        _builder.newLine();
        _builder.append("                ");
        _builder.append("be used by the script for adding a corresponding click event handler.");
        _builder.newLine();
        _builder.append("                ");
        String _prefix = app.getPrefix();
        _builder.append(_prefix, "                ");
        _builder.append("InitGeoCoding();");
        _builder.newLineIfNotEmpty();
        _builder.append("            ");
        _builder.append("*}}");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("});");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("/* ]]> */");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("</script>");
        _builder.newLine();
        _builder.append("{/pageaddvarblock}");
        _builder.newLine();
      }
    }
    _builder.newLine();
    _builder.append("<script type=\"text/javascript\">");
    _builder.newLine();
    _builder.append("/* <![CDATA[ */");
    _builder.newLine();
    _builder.append("    ");
    CharSequence _initJs = this.relationHelper.initJs(it, app, Boolean.valueOf(false));
    _builder.append(_initJs, "    ");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("var formButtons, formValidator;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("function handleFormButton (event) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("var result = formValidator.validate();");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if (!result) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("// validation error, abort form submit");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("Event.stop(event);");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("} else {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("// hide form buttons to prevent double submits by accident");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("formButtons.each(function (btn) {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("btn.addClassName(\'z-hide\');");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("});");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return result;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("document.observe(\'dom:loaded\', function() {");
    _builder.newLine();
    _builder.append("        ");
    final Iterable<UserField> userFields = this._modelExtensions.getUserFieldsEntity(it);
    _builder.newLineIfNotEmpty();
    {
      boolean _isEmpty = IterableExtensions.isEmpty(userFields);
      boolean _not = (!_isEmpty);
      if (_not) {
        _builder.append("        ");
        _builder.append("// initialise auto completion for user fields");
        _builder.newLine();
        {
          for(final UserField userField : userFields) {
            _builder.append("        ");
            String _name_2 = userField.getName();
            final String realName = this._formattingExtensions.formatForCode(_name_2);
            _builder.newLineIfNotEmpty();
            _builder.append("        ");
            String _prefix_1 = app.getPrefix();
            _builder.append(_prefix_1, "        ");
            _builder.append("InitUserField(\'");
            _builder.append(realName, "        ");
            _builder.append("\', \'get");
            String _name_3 = it.getName();
            String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(_name_3);
            _builder.append(_formatForCodeCapital, "        ");
            String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(realName);
            _builder.append(_formatForCodeCapital_1, "        ");
            _builder.append("Users\');");
            _builder.newLineIfNotEmpty();
          }
        }
      }
    }
    _builder.append("        ");
    CharSequence _initJs_1 = this.relationHelper.initJs(it, app, Boolean.valueOf(true));
    _builder.append(_initJs_1, "        ");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("        ");
    Models _container = it.getContainer();
    Application _application = _container.getApplication();
    String _prefix_2 = _application.getPrefix();
    _builder.append(_prefix_2, "        ");
    _builder.append("AddCommonValidationRules(\'");
    String _name_4 = it.getName();
    String _formatForCode = this._formattingExtensions.formatForCode(_name_4);
    _builder.append(_formatForCode, "        ");
    _builder.append("\', \'{{if $mode ne \'create\'}}");
    {
      Iterable<DerivedField> _primaryKeyFields = this._modelExtensions.getPrimaryKeyFields(it);
      boolean _hasElements = false;
      for(final DerivedField pkField : _primaryKeyFields) {
        if (!_hasElements) {
          _hasElements = true;
        } else {
          _builder.appendImmediate("_", "        ");
        }
        _builder.append("{{$");
        String _name_5 = it.getName();
        String _formatForDB_5 = this._formattingExtensions.formatForDB(_name_5);
        _builder.append(_formatForDB_5, "        ");
        _builder.append(".");
        String _name_6 = pkField.getName();
        String _formatForCode_1 = this._formattingExtensions.formatForCode(_name_6);
        _builder.append(_formatForCode_1, "        ");
        _builder.append("}}");
      }
    }
    _builder.append("{{/if}}\');");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("{{* observe validation on button events instead of form submit to exclude the cancel command *}}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("formValidator = new Validation(\'{{$__formid}}\', {onSubmit: false, immediate: true, focusOnError: false});");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("{{if $mode ne \'create\'}}");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("var result = formValidator.validate();");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("{{/if}}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("formButtons = $(\'{{$__formid}}\').select(\'div.z-formbuttons input\');");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("formButtons.each(function (elem) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("if (elem.id != \'btnCancel\') {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("elem.observe(\'click\', handleFormButton);");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("});");
    _builder.newLine();
    {
      boolean _useGroupingPanels = this._viewExtensions.useGroupingPanels(it, "edit");
      if (_useGroupingPanels) {
        _builder.newLine();
        _builder.append("        ");
        _builder.append("var panel = new Zikula.UI.Panels(\'");
        String _appName_4 = this._utils.appName(app);
        _builder.append(_appName_4, "        ");
        _builder.append("_panel\', {");
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("headerSelector: \'h3\',");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("headerClassName: \'z-panel-header z-panel-indicator\',");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("contentClassName: \'z-panel-content\',");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("active: $(\'z-panel-header-fields\')");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("});");
        _builder.newLine();
      }
    }
    _builder.newLine();
    _builder.append("        ");
    _builder.append("Zikula.UI.Tooltips($$(\'.");
    String _appName_5 = this._utils.appName(app);
    String _formatForDB_6 = this._formattingExtensions.formatForDB(_appName_5);
    _builder.append(_formatForDB_6, "        ");
    _builder.append("FormTooltips\'));");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    {
      Iterable<DerivedField> _derivedFields = this._modelExtensions.getDerivedFields(it);
      for(final DerivedField field : _derivedFields) {
        CharSequence _additionalInitScript = this.additionalInitScript(field);
        _builder.append(_additionalInitScript, "        ");
      }
    }
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("});");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/* ]]> */");
    _builder.newLine();
    _builder.append("</script>");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence fieldWrapper(final DerivedField it, final String groupSuffix, final String idSuffix) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.newLine();
    {
      Entity _entity = it.getEntity();
      Iterable<JoinRelationship> _incomingJoinRelations = this._modelJoinExtensions.getIncomingJoinRelations(_entity);
      final Function1<JoinRelationship,Boolean> _function = new Function1<JoinRelationship,Boolean>() {
          public Boolean apply(final JoinRelationship e) {
            String[] _sourceFields = Forms.this._modelJoinExtensions.getSourceFields(e);
            String _head = IterableExtensions.<String>head(((Iterable<String>)Conversions.doWrapArray(_sourceFields)));
            String _name = it.getName();
            String _formatForDB = Forms.this._formattingExtensions.formatForDB(_name);
            boolean _equals = Objects.equal(_head, _formatForDB);
            return Boolean.valueOf(_equals);
          }
        };
      Iterable<JoinRelationship> _filter = IterableExtensions.<JoinRelationship>filter(_incomingJoinRelations, _function);
      boolean _isEmpty = IterableExtensions.isEmpty(_filter);
      if (_isEmpty) {
        _builder.append("<div class=\"z-formrow\">");
        _builder.newLine();
        _builder.append("    ");
        CharSequence _formRow = this.fieldHelper.formRow(it, groupSuffix, idSuffix);
        _builder.append(_formRow, "    ");
        _builder.newLineIfNotEmpty();
        _builder.append("</div>");
        _builder.newLine();
      }
    }
    return _builder;
  }
  
  private CharSequence additionalInitScript(final DerivedField it) {
    CharSequence _switchResult = null;
    boolean _matched = false;
    if (!_matched) {
      if (it instanceof UploadField) {
        final UploadField _uploadField = (UploadField)it;
        _matched=true;
        CharSequence _additionalInitScriptUpload = this.additionalInitScriptUpload(_uploadField);
        _switchResult = _additionalInitScriptUpload;
      }
    }
    if (!_matched) {
      if (it instanceof DatetimeField) {
        final DatetimeField _datetimeField = (DatetimeField)it;
        _matched=true;
        CharSequence _additionalInitScriptCalendar = this.additionalInitScriptCalendar(_datetimeField);
        _switchResult = _additionalInitScriptCalendar;
      }
    }
    if (!_matched) {
      if (it instanceof DateField) {
        final DateField _dateField = (DateField)it;
        _matched=true;
        CharSequence _additionalInitScriptCalendar = this.additionalInitScriptCalendar(_dateField);
        _switchResult = _additionalInitScriptCalendar;
      }
    }
    return _switchResult;
  }
  
  private CharSequence additionalInitScriptUpload(final UploadField it) {
    StringConcatenation _builder = new StringConcatenation();
    Entity _entity = it.getEntity();
    Models _container = _entity.getContainer();
    Application _application = _container.getApplication();
    String _prefix = _application.getPrefix();
    _builder.append(_prefix, "");
    _builder.append("InitUploadField(\'");
    String _name = it.getName();
    String _formatForCode = this._formattingExtensions.formatForCode(_name);
    _builder.append(_formatForCode, "");
    _builder.append("\');");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence additionalInitScriptCalendar(final AbstractDateField it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _and = false;
      boolean _isMandatory = it.isMandatory();
      boolean _not = (!_isMandatory);
      if (!_not) {
        _and = false;
      } else {
        boolean _isNullable = it.isNullable();
        _and = (_not && _isNullable);
      }
      if (_and) {
        Entity _entity = it.getEntity();
        Models _container = _entity.getContainer();
        Application _application = _container.getApplication();
        String _prefix = _application.getPrefix();
        _builder.append(_prefix, "");
        _builder.append("InitDateField(\'");
        String _name = it.getName();
        String _formatForCode = this._formattingExtensions.formatForCode(_name);
        _builder.append(_formatForCode, "");
        _builder.append("\');");
        _builder.newLineIfNotEmpty();
      }
    }
    return _builder;
  }
  
  private void inlineRedirectHandlerFile(final Controller it, final Application app, final IFileSystemAccess fsa) {
    String _viewPath = this._namingExtensions.getViewPath(app);
    String _xifexpression = null;
    boolean _targets = this._utils.targets(app, "1.3.5");
    if (_targets) {
      String _formattedName = this._controllerExtensions.formattedName(it);
      _xifexpression = _formattedName;
    } else {
      String _formattedName_1 = this._controllerExtensions.formattedName(it);
      String _firstUpper = StringExtensions.toFirstUpper(_formattedName_1);
      _xifexpression = _firstUpper;
    }
    String _plus = (_viewPath + _xifexpression);
    final String templatePath = (_plus + "/");
    String _plus_1 = (templatePath + "inlineRedirectHandler.tpl");
    CharSequence _inlineRedirectHandlerImpl = this.inlineRedirectHandlerImpl(it, app);
    fsa.generateFile(_plus_1, _inlineRedirectHandlerImpl);
  }
  
  private CharSequence inlineRedirectHandlerImpl(final Controller it, final Application app) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{* purpose of this template: close an iframe from within this iframe *}");
    _builder.newLine();
    _builder.append("<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\">");
    _builder.newLine();
    _builder.append("<html xmlns=\"http://www.w3.org/1999/xhtml\">");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<head>");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("{$jcssConfig}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<script type=\"text/javascript\" src=\"{$baseurl}javascript/ajax/proto_scriptaculous.combined.min.js\"></script>");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<script type=\"text/javascript\" src=\"{$baseurl}javascript/helpers/Zikula.js\"></script>");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<script type=\"text/javascript\" src=\"{$baseurl}javascript/livepipe/livepipe.combined.min.js\"></script>");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<script type=\"text/javascript\" src=\"{$baseurl}javascript/helpers/Zikula.UI.js\"></script>");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<script type=\"text/javascript\" src=\"{$baseurl}modules/");
    String _appName = this._utils.appName(app);
    _builder.append(_appName, "        ");
    _builder.append("/");
    {
      boolean _targets = this._utils.targets(app, "1.3.5");
      if (_targets) {
        _builder.append("javascript");
      } else {
        String _appJsPath = this._namingExtensions.getAppJsPath(app);
        _builder.append(_appJsPath, "        ");
      }
    }
    _builder.append("/");
    String _appName_1 = this._utils.appName(app);
    _builder.append(_appName_1, "        ");
    _builder.append("_editFunctions.js\"></script>");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("</head>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<body>");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<script type=\"text/javascript\">");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("/* <![CDATA[ */");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("// close window from parent document");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("document.observe(\'dom:loaded\', function() {");
    _builder.newLine();
    _builder.append("                ");
    String _prefix = app.getPrefix();
    _builder.append(_prefix, "                ");
    _builder.append("CloseWindowFromInside(\'{{$idPrefix}}\', {{if $commandName eq \'create\'}}{{$itemId}}{{else}}0{{/if}});");
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    _builder.append("});");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("/* ]]> */");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("</script>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("</body>");
    _builder.newLine();
    _builder.append("</html>");
    _builder.newLine();
    return _builder;
  }
}
