package org.zikula.modulestudio.generator.cartridges.zclassic.view.formcomponents;

import com.google.common.base.Objects;
import com.google.inject.Inject;
import de.guite.modulestudio.metamodel.modulestudio.Application;
import de.guite.modulestudio.metamodel.modulestudio.Controller;
import de.guite.modulestudio.metamodel.modulestudio.DerivedField;
import de.guite.modulestudio.metamodel.modulestudio.Entity;
import de.guite.modulestudio.metamodel.modulestudio.JoinRelationship;
import de.guite.modulestudio.metamodel.modulestudio.ManyToManyRelationship;
import de.guite.modulestudio.metamodel.modulestudio.Models;
import de.guite.modulestudio.metamodel.modulestudio.UploadField;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.InputOutput;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.eclipse.xtext.xbase.lib.StringExtensions;
import org.zikula.modulestudio.generator.extensions.ControllerExtensions;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.UrlExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;
import org.zikula.modulestudio.generator.extensions.ViewExtensions;

@SuppressWarnings("all")
public class Relations {
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
  private UrlExtensions _urlExtensions = new Function0<UrlExtensions>() {
    public UrlExtensions apply() {
      UrlExtensions _urlExtensions = new UrlExtensions();
      return _urlExtensions;
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
  
  @Inject
  @Extension
  private Utils _utils = new Function0<Utils>() {
    public Utils apply() {
      Utils _utils = new Utils();
      return _utils;
    }
  }.apply();
  
  /**
   * This method creates the templates to be included into the edit forms.
   */
  public CharSequence generateInclusionTemplate(final Entity it, final Application app, final Controller controller, final IFileSystemAccess fsa) {
    StringConcatenation _builder = new StringConcatenation();
    {
      Iterable<JoinRelationship> _bidirectionalIncomingJoinRelations = this._modelJoinExtensions.getBidirectionalIncomingJoinRelations(it);
      final Function1<JoinRelationship,Boolean> _function = new Function1<JoinRelationship,Boolean>() {
          public Boolean apply(final JoinRelationship e) {
            Entity _source = e.getSource();
            Models _container = _source.getContainer();
            Application _application = _container.getApplication();
            boolean _equals = Objects.equal(_application, app);
            return Boolean.valueOf(_equals);
          }
        };
      Iterable<JoinRelationship> _filter = IterableExtensions.<JoinRelationship>filter(_bidirectionalIncomingJoinRelations, _function);
      for(final JoinRelationship relation : _filter) {
        CharSequence _generate = this.generate(relation, app, controller, Boolean.valueOf(false), Boolean.valueOf(true), fsa);
        _builder.append(_generate, "");
      }
    }
    _builder.newLineIfNotEmpty();
    {
      Iterable<JoinRelationship> _outgoingJoinRelations = this._modelJoinExtensions.getOutgoingJoinRelations(it);
      final Function1<JoinRelationship,Boolean> _function_1 = new Function1<JoinRelationship,Boolean>() {
          public Boolean apply(final JoinRelationship e) {
            Entity _target = e.getTarget();
            Models _container = _target.getContainer();
            Application _application = _container.getApplication();
            boolean _equals = Objects.equal(_application, app);
            return Boolean.valueOf(_equals);
          }
        };
      Iterable<JoinRelationship> _filter_1 = IterableExtensions.<JoinRelationship>filter(_outgoingJoinRelations, _function_1);
      for(final JoinRelationship relation_1 : _filter_1) {
        CharSequence _generate_1 = this.generate(relation_1, app, controller, Boolean.valueOf(false), Boolean.valueOf(false), fsa);
        _builder.append(_generate_1, "");
      }
    }
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  /**
   * Entry point for form sections treating related objects.
   * This method creates the Smarty include statement.
   */
  public CharSequence generateIncludeStatement(final Entity it, final Application app, final Controller controller, final IFileSystemAccess fsa) {
    StringConcatenation _builder = new StringConcatenation();
    {
      Iterable<JoinRelationship> _bidirectionalIncomingJoinRelations = this._modelJoinExtensions.getBidirectionalIncomingJoinRelations(it);
      final Function1<JoinRelationship,Boolean> _function = new Function1<JoinRelationship,Boolean>() {
          public Boolean apply(final JoinRelationship e) {
            Entity _source = e.getSource();
            Models _container = _source.getContainer();
            Application _application = _container.getApplication();
            boolean _equals = Objects.equal(_application, app);
            return Boolean.valueOf(_equals);
          }
        };
      Iterable<JoinRelationship> _filter = IterableExtensions.<JoinRelationship>filter(_bidirectionalIncomingJoinRelations, _function);
      for(final JoinRelationship relation : _filter) {
        CharSequence _generate = this.generate(relation, app, controller, Boolean.valueOf(true), Boolean.valueOf(true), fsa);
        _builder.append(_generate, "");
      }
    }
    _builder.newLineIfNotEmpty();
    {
      Iterable<JoinRelationship> _outgoingJoinRelations = this._modelJoinExtensions.getOutgoingJoinRelations(it);
      final Function1<JoinRelationship,Boolean> _function_1 = new Function1<JoinRelationship,Boolean>() {
          public Boolean apply(final JoinRelationship e) {
            Entity _target = e.getTarget();
            Models _container = _target.getContainer();
            Application _application = _container.getApplication();
            boolean _equals = Objects.equal(_application, app);
            return Boolean.valueOf(_equals);
          }
        };
      Iterable<JoinRelationship> _filter_1 = IterableExtensions.<JoinRelationship>filter(_outgoingJoinRelations, _function_1);
      for(final JoinRelationship relation_1 : _filter_1) {
        CharSequence _generate_1 = this.generate(relation_1, app, controller, Boolean.valueOf(true), Boolean.valueOf(false), fsa);
        _builder.append(_generate_1, "");
      }
    }
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence generate(final JoinRelationship it, final Application app, final Controller controller, final Boolean onlyInclude, final Boolean incoming, final IFileSystemAccess fsa) {
    final int stageCode = this._controllerExtensions.getEditStageCode(it, incoming);
    boolean _lessThan = (stageCode < 1);
    if (_lessThan) {
      StringConcatenation _builder = new StringConcatenation();
      return _builder.toString();
    }
    final boolean useTarget = (!(incoming).booleanValue());
    boolean _and = false;
    if (!useTarget) {
      _and = false;
    } else {
      boolean _isManyToMany = this.isManyToMany(it);
      boolean _not = (!_isManyToMany);
      _and = (useTarget && _not);
    }
    if (_and) {
      StringConcatenation _builder_1 = new StringConcatenation();
      return _builder_1.toString();
    }
    final boolean hasEdit = (stageCode > 1);
    String _xifexpression = null;
    if (hasEdit) {
      _xifexpression = "Edit";
    } else {
      _xifexpression = "";
    }
    final String editSnippet = _xifexpression;
    final String templateName = this.getTemplateName(it, Boolean.valueOf(useTarget), editSnippet);
    Entity _xifexpression_1 = null;
    if ((incoming).booleanValue()) {
      Entity _source = it.getSource();
      _xifexpression_1 = _source;
    } else {
      Entity _target = it.getTarget();
      _xifexpression_1 = _target;
    }
    final Entity ownEntity = _xifexpression_1;
    Entity _xifexpression_2 = null;
    boolean _not_1 = (!(incoming).booleanValue());
    if (_not_1) {
      Entity _source_1 = it.getSource();
      _xifexpression_2 = _source_1;
    } else {
      Entity _target_1 = it.getTarget();
      _xifexpression_2 = _target_1;
    }
    final Entity otherEntity = _xifexpression_2;
    final boolean many = this._modelJoinExtensions.isManySide(it, useTarget);
    if ((onlyInclude).booleanValue()) {
      String _relationAliasName = this._namingExtensions.getRelationAliasName(it, Boolean.valueOf(useTarget));
      final String relationAliasName = this._formattingExtensions.formatForCodeCapital(_relationAliasName);
      boolean _not_2 = (!useTarget);
      String _relationAliasName_1 = this._namingExtensions.getRelationAliasName(it, Boolean.valueOf(_not_2));
      final String relationAliasReverse = this._formattingExtensions.formatForCodeCapital(_relationAliasName_1);
      boolean _xifexpression_3 = false;
      boolean _isManyToMany_1 = this.isManyToMany(it);
      boolean _not_3 = (!_isManyToMany_1);
      if (_not_3) {
        _xifexpression_3 = useTarget;
      } else {
        _xifexpression_3 = (incoming).booleanValue();
      }
      final boolean incomingForUniqueRelationName = _xifexpression_3;
      final String uniqueNameForJs = this._modelJoinExtensions.getUniqueRelationNameForJs(it, app, otherEntity, Boolean.valueOf(many), Boolean.valueOf(incomingForUniqueRelationName), relationAliasName);
      return this.includeStatementForEditTemplate(it, templateName, controller, ownEntity, otherEntity, incoming, relationAliasName, relationAliasReverse, uniqueNameForJs, Boolean.valueOf(hasEdit));
    }
    String _formattedName = this._controllerExtensions.formattedName(controller);
    String _plus = ("Generating " + _formattedName);
    String _plus_1 = (_plus + " edit inclusion templates for entity \"");
    String _name = ownEntity.getName();
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(_name);
    String _plus_2 = (_plus_1 + _formatForDisplay);
    String _plus_3 = (_plus_2 + "\"");
    InputOutput.<String>println(_plus_3);
    String _plus_4 = ("include_select" + editSnippet);
    String _plus_5 = (_plus_4 + "ItemList");
    String _targetMultiplicity = this._modelJoinExtensions.getTargetMultiplicity(it, Boolean.valueOf(useTarget));
    String templateNameItemList = (_plus_5 + _targetMultiplicity);
    String _name_1 = ownEntity.getName();
    final String templateFileName = this._namingExtensions.templateFile(controller, _name_1, templateName);
    String _name_2 = ownEntity.getName();
    final String templateFileNameItemList = this._namingExtensions.templateFile(controller, _name_2, templateNameItemList);
    CharSequence _includedEditTemplate = this.includedEditTemplate(it, app, controller, ownEntity, otherEntity, incoming, Boolean.valueOf(hasEdit), Boolean.valueOf(many));
    fsa.generateFile(templateFileName, _includedEditTemplate);
    CharSequence _component_ItemList = this.component_ItemList(it, app, controller, ownEntity, Boolean.valueOf(many), incoming, Boolean.valueOf(hasEdit));
    fsa.generateFile(templateFileNameItemList, _component_ItemList);
    return null;
  }
  
  private String getTemplateName(final JoinRelationship it, final Boolean useTarget, final String editSnippet) {
    String _xblockexpression = null;
    {
      String templateName = "";
      boolean _and = false;
      if (!(useTarget).booleanValue()) {
        _and = false;
      } else {
        boolean _isManyToMany = this.isManyToMany(it);
        boolean _not = (!_isManyToMany);
        _and = ((useTarget).booleanValue() && _not);
      }
      if (_and) {
      } else {
        String _plus = ("include_select" + editSnippet);
        templateName = _plus;
      }
      String _targetMultiplicity = this._modelJoinExtensions.getTargetMultiplicity(it, useTarget);
      String _plus_1 = (templateName + _targetMultiplicity);
      templateName = _plus_1;
      _xblockexpression = (templateName);
    }
    return _xblockexpression;
  }
  
  private CharSequence includeStatementForEditTemplate(final JoinRelationship it, final String templateName, final Controller controller, final Entity ownEntity, final Entity linkingEntity, final Boolean incoming, final String relationAliasName, final String relationAliasReverse, final String uniqueNameForJs, final Boolean hasEdit) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{include file=\'");
    {
      Models _container = it.getContainer();
      Application _application = _container.getApplication();
      boolean _targets = this._utils.targets(_application, "1.3.5");
      if (_targets) {
        String _formattedName = this._controllerExtensions.formattedName(controller);
        _builder.append(_formattedName, "");
        _builder.append("/");
        String _name = ownEntity.getName();
        String _formatForCode = this._formattingExtensions.formatForCode(_name);
        _builder.append(_formatForCode, "");
      } else {
        String _formattedName_1 = this._controllerExtensions.formattedName(controller);
        String _firstUpper = StringExtensions.toFirstUpper(_formattedName_1);
        _builder.append(_firstUpper, "");
        _builder.append("/");
        String _name_1 = ownEntity.getName();
        String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(_name_1);
        _builder.append(_formatForCodeCapital, "");
      }
    }
    _builder.append("/");
    _builder.append(templateName, "");
    _builder.append(".tpl\' group=\'");
    String _name_2 = linkingEntity.getName();
    String _formatForDB = this._formattingExtensions.formatForDB(_name_2);
    _builder.append(_formatForDB, "");
    _builder.append("\' alias=\'");
    String _firstLower = StringExtensions.toFirstLower(relationAliasName);
    _builder.append(_firstLower, "");
    _builder.append("\' aliasReverse=\'");
    String _firstLower_1 = StringExtensions.toFirstLower(relationAliasReverse);
    _builder.append(_firstLower_1, "");
    _builder.append("\' mandatory=");
    boolean _isNullable = it.isNullable();
    boolean _not = (!_isNullable);
    String _displayBool = this._formattingExtensions.displayBool(Boolean.valueOf(_not));
    _builder.append(_displayBool, "");
    _builder.append(" idPrefix=\'");
    _builder.append(uniqueNameForJs, "");
    _builder.append("\' linkingItem=$");
    String _name_3 = linkingEntity.getName();
    String _formatForDB_1 = this._formattingExtensions.formatForDB(_name_3);
    _builder.append(_formatForDB_1, "");
    {
      boolean _useGroupingPanels = this._viewExtensions.useGroupingPanels(linkingEntity, "edit");
      if (_useGroupingPanels) {
        _builder.append(" panel=true");
      }
    }
    _builder.append(" displayMode=\'");
    {
      boolean _not_1 = (!(incoming).booleanValue());
      boolean _usesAutoCompletion = this._modelJoinExtensions.usesAutoCompletion(it, _not_1);
      boolean _not_2 = (!_usesAutoCompletion);
      if (_not_2) {
        _builder.append("dropdown");
      } else {
        _builder.append("autocomplete");
      }
    }
    _builder.append("\' allowEditing=");
    String _displayBool_1 = this._formattingExtensions.displayBool(hasEdit);
    _builder.append(_displayBool_1, "");
    _builder.append("}");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence includedEditTemplate(final JoinRelationship it, final Application app, final Controller controller, final Entity ownEntity, final Entity linkingEntity, final Boolean incoming, final Boolean hasEdit, final Boolean many) {
    StringConcatenation _builder = new StringConcatenation();
    final String ownEntityName = this._modelExtensions.getEntityNameSingularPlural(ownEntity, many);
    _builder.newLineIfNotEmpty();
    _builder.append("{* purpose of this template: inclusion template for managing related ");
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(ownEntityName);
    _builder.append(_formatForDisplay, "");
    _builder.append(" in ");
    String _formattedName = this._controllerExtensions.formattedName(controller);
    _builder.append(_formattedName, "");
    _builder.append(" area *}");
    _builder.newLineIfNotEmpty();
    _builder.append("{if !isset($displayMode)}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{assign var=\'displayMode\' value=\'dropdown\'}");
    _builder.newLine();
    _builder.append("{/if}");
    _builder.newLine();
    _builder.append("{if !isset($allowEditing)}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{assign var=\'allowEditing\' value=false}");
    _builder.newLine();
    _builder.append("{/if}");
    _builder.newLine();
    _builder.append("{if isset($panel) && $panel eq true}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<h3 class=\"");
    String _formatForDB = this._formattingExtensions.formatForDB(ownEntityName);
    _builder.append(_formatForDB, "    ");
    _builder.append(" z-panel-header z-panel-indicator z-pointer\">{gt text=\'");
    String _formatForDisplayCapital = this._formattingExtensions.formatForDisplayCapital(ownEntityName);
    _builder.append(_formatForDisplayCapital, "    ");
    _builder.append("\'}</h3>");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("<fieldset class=\"");
    String _formatForDB_1 = this._formattingExtensions.formatForDB(ownEntityName);
    _builder.append(_formatForDB_1, "    ");
    _builder.append(" z-panel-content\" style=\"display: none\">");
    _builder.newLineIfNotEmpty();
    _builder.append("{else}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<fieldset class=\"");
    String _formatForDB_2 = this._formattingExtensions.formatForDB(ownEntityName);
    _builder.append(_formatForDB_2, "    ");
    _builder.append("\">");
    _builder.newLineIfNotEmpty();
    _builder.append("{/if}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<legend>{gt text=\'");
    String _formatForDisplayCapital_1 = this._formattingExtensions.formatForDisplayCapital(ownEntityName);
    _builder.append(_formatForDisplayCapital_1, "    ");
    _builder.append("\'}</legend>");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("<div class=\"z-formrow\">");
    _builder.newLine();
    String _name = ownEntity.getName();
    String _formatForCode = this._formattingExtensions.formatForCode(_name);
    final CharSequence pluginAttributes = this.formPluginAttributes(it, ownEntity, ownEntityName, _formatForCode, many);
    _builder.newLineIfNotEmpty();
    Models _container = it.getContainer();
    Application _application = _container.getApplication();
    String _appName = this._utils.appName(_application);
    final String appnameLower = this._formattingExtensions.formatForDB(_appName);
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("{if $displayMode eq \'dropdown\'}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("{formlabel for=$alias __text=\'Choose ");
    String _formatForDisplay_1 = this._formattingExtensions.formatForDisplay(ownEntityName);
    _builder.append(_formatForDisplay_1, "        ");
    _builder.append("\'");
    {
      boolean _isNullable = it.isNullable();
      boolean _not = (!_isNullable);
      if (_not) {
        _builder.append(" mandatorysym=\'1\'");
      }
    }
    _builder.append("}");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("{");
    _builder.append(appnameLower, "        ");
    _builder.append("RelationSelectorList ");
    _builder.append(pluginAttributes, "        ");
    _builder.append("}");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("{elseif $displayMode eq \'autocomplete\'}");
    _builder.newLine();
    {
      boolean _and = false;
      boolean _isManyToMany = this.isManyToMany(it);
      boolean _not_1 = (!_isManyToMany);
      if (!_not_1) {
        _and = false;
      } else {
        boolean _not_2 = (!(incoming).booleanValue());
        _and = (_not_1 && _not_2);
      }
      if (_and) {
        _builder.append("        ");
        CharSequence _component_ParentEditing = this.component_ParentEditing(it, ownEntity, many);
        _builder.append(_component_ParentEditing, "        ");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("        ");
        _builder.append("{assign var=\'createLink\' value=\'\'}");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("{if $allowEditing eq true}");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("{modurl modname=\'");
        String _appName_1 = this._utils.appName(app);
        _builder.append(_appName_1, "            ");
        _builder.append("\' type=\'");
        String _formattedName_1 = this._controllerExtensions.formattedName(controller);
        _builder.append(_formattedName_1, "            ");
        _builder.append("\' func=\'edit\' ot=\'");
        String _name_1 = ownEntity.getName();
        String _formatForCode_1 = this._formattingExtensions.formatForCode(_name_1);
        _builder.append(_formatForCode_1, "            ");
        _builder.append("\'");
        String _additionalUrlParametersForQuickViewLink = this._viewExtensions.additionalUrlParametersForQuickViewLink(controller);
        _builder.append(_additionalUrlParametersForQuickViewLink, "            ");
        _builder.append(" assign=\'createLink\'}");
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        _builder.append("{/if}");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("{");
        _builder.append(appnameLower, "        ");
        _builder.append("RelationSelectorAutoComplete ");
        _builder.append(pluginAttributes, "        ");
        _builder.append(" idPrefix=$idPrefix createLink=$createLink selectedEntityName=\'");
        String _formatForDisplay_2 = this._formattingExtensions.formatForDisplay(ownEntityName);
        _builder.append(_formatForDisplay_2, "        ");
        _builder.append("\' withImage=");
        boolean _hasImageFieldsEntity = this._modelExtensions.hasImageFieldsEntity(ownEntity);
        String _displayBool = this._formattingExtensions.displayBool(Boolean.valueOf(_hasImageFieldsEntity));
        _builder.append(_displayBool, "        ");
        _builder.append("}");
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        CharSequence _component_AutoComplete = this.component_AutoComplete(it, app, controller, ownEntity, many, incoming, hasEdit);
        _builder.append(_component_AutoComplete, "        ");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("    ");
    _builder.append("{/if}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("</div>");
    _builder.newLine();
    _builder.append("</fieldset>");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence formPluginAttributes(final JoinRelationship it, final Entity ownEntity, final String ownEntityName, final String objectType, final Boolean many) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("group=$group id=$alias aliasReverse=$aliasReverse mandatory=$mandatory __title=\'Choose the ");
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(ownEntityName);
    _builder.append(_formatForDisplay, "");
    _builder.append("\' selectionMode=\'");
    {
      if ((many).booleanValue()) {
        _builder.append("multiple");
      } else {
        _builder.append("single");
      }
    }
    _builder.append("\' objectType=\'");
    _builder.append(objectType, "");
    _builder.append("\' linkingItem=$linkingItem");
    return _builder;
  }
  
  private CharSequence component_ParentEditing(final JoinRelationship it, final Entity targetEntity, final Boolean many) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("        ");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence component_AutoComplete(final JoinRelationship it, final Application app, final Controller controller, final Entity targetEntity, final Boolean many, final Boolean incoming, final Boolean includeEditing) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("<div class=\"");
    String _prefix = this._utils.prefix(app);
    _builder.append(_prefix, "");
    _builder.append("RelationLeftSide\">");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    final CharSequence includeStatement = this.component_IncludeStatementForAutoCompleterItemList(it, controller, targetEntity, many, incoming, includeEditing);
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("{if isset($linkingItem.$alias)}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("{");
    _builder.append(includeStatement, "        ");
    _builder.append(" item");
    {
      if ((many).booleanValue()) {
        _builder.append("s");
      }
    }
    _builder.append("=$linkingItem.$alias}");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("{else}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("{");
    _builder.append(includeStatement, "        ");
    _builder.append("}");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("{/if}");
    _builder.newLine();
    _builder.append("</div>");
    _builder.newLine();
    _builder.append("<br class=\"z-clearer\" />");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence component_IncludeStatementForAutoCompleterItemList(final JoinRelationship it, final Controller controller, final Entity targetEntity, final Boolean many, final Boolean incoming, final Boolean includeEditing) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("include file=\'");
    {
      Models _container = it.getContainer();
      Application _application = _container.getApplication();
      boolean _targets = this._utils.targets(_application, "1.3.5");
      if (_targets) {
        String _formattedName = this._controllerExtensions.formattedName(controller);
        _builder.append(_formattedName, "");
        _builder.append("/");
        String _name = targetEntity.getName();
        String _formatForCode = this._formattingExtensions.formatForCode(_name);
        _builder.append(_formatForCode, "");
      } else {
        String _formattedName_1 = this._controllerExtensions.formattedName(controller);
        String _firstUpper = StringExtensions.toFirstUpper(_formattedName_1);
        _builder.append(_firstUpper, "");
        _builder.append("/");
        String _name_1 = targetEntity.getName();
        String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(_name_1);
        _builder.append(_formatForCodeCapital, "");
      }
    }
    _builder.append("/include_select");
    {
      if ((includeEditing).booleanValue()) {
        _builder.append("Edit");
      }
    }
    _builder.append("ItemList");
    {
      boolean _not = (!(many).booleanValue());
      if (_not) {
        _builder.append("One");
      } else {
        _builder.append("Many");
      }
    }
    _builder.append(".tpl\' ");
    return _builder;
  }
  
  private CharSequence component_ItemList(final JoinRelationship it, final Application app, final Controller controller, final Entity targetEntity, final Boolean many, final Boolean incoming, final Boolean includeEditing) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{* purpose of this template: inclusion template for display of related ");
    String _entityNameSingularPlural = this._modelExtensions.getEntityNameSingularPlural(targetEntity, many);
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(_entityNameSingularPlural);
    _builder.append(_formatForDisplay, "");
    _builder.append(" in ");
    String _formattedName = this._controllerExtensions.formattedName(controller);
    _builder.append(_formattedName, "");
    _builder.append(" area *}");
    _builder.newLineIfNotEmpty();
    {
      if ((includeEditing).booleanValue()) {
        _builder.append("{icon type=\'edit\' size=\'extrasmall\' assign=\'editImageArray\'}");
        _builder.newLine();
        _builder.append("{assign var=\'editImage\' value=\"<img src=\\\"`$editImageArray.src`\\\" width=\\\"16\\\" height=\\\"16\\\" alt=\\\"\\\" />\"}");
        _builder.newLine();
      }
    }
    _builder.append("{icon type=\'delete\' size=\'extrasmall\' assign=\'removeImageArray\'}");
    _builder.newLine();
    _builder.append("{assign var=\'removeImage\' value=\"<img src=\\\"`$removeImageArray.src`\\\" width=\\\"16\\\" height=\\\"16\\\" alt=\\\"\\\" />\"}");
    _builder.newLine();
    {
      boolean _not = (!(many).booleanValue());
      if (_not) {
        _builder.newLine();
        _builder.append("{if isset($item) && is_array($item) && !is_object($item[0])}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("{modapifunc modname=\'");
        String _appName = this._utils.appName(app);
        _builder.append(_appName, "    ");
        _builder.append("\' type=\'selection\' func=\'getEntity\' objectType=\'");
        String _name = targetEntity.getName();
        String _formatForCode = this._formattingExtensions.formatForCode(_name);
        _builder.append(_formatForCode, "    ");
        _builder.append("\' id=$item[0] assign=\'item\'}");
        _builder.newLineIfNotEmpty();
        _builder.append("{/if}");
        _builder.newLine();
      }
    }
    _builder.newLine();
    _builder.append("<input type=\"hidden\" id=\"{$idPrefix}ItemList\" name=\"{$idPrefix}ItemList\" value=\"{if isset($item");
    {
      if ((many).booleanValue()) {
        _builder.append("s");
      }
    }
    _builder.append(") && (is_array($item");
    {
      if ((many).booleanValue()) {
        _builder.append("s");
      }
    }
    _builder.append(") || is_object($item");
    {
      if ((many).booleanValue()) {
        _builder.append("s");
      }
    }
    _builder.append("))");
    {
      boolean _not_1 = (!(many).booleanValue());
      if (_not_1) {
        {
          Iterable<DerivedField> _primaryKeyFields = this._modelExtensions.getPrimaryKeyFields(targetEntity);
          for(final DerivedField pkField : _primaryKeyFields) {
            _builder.append(" && isset($item.");
            String _name_1 = pkField.getName();
            String _formatForCode_1 = this._formattingExtensions.formatForCode(_name_1);
            _builder.append(_formatForCode_1, "");
            _builder.append(")");
          }
        }
      }
    }
    _builder.append("}");
    {
      if ((many).booleanValue()) {
        _builder.append("{foreach name=\'relLoop\' item=\'item\' from=$items}");
      }
    }
    {
      Iterable<DerivedField> _primaryKeyFields_1 = this._modelExtensions.getPrimaryKeyFields(targetEntity);
      boolean _hasElements = false;
      for(final DerivedField pkField_1 : _primaryKeyFields_1) {
        if (!_hasElements) {
          _hasElements = true;
        } else {
          _builder.appendImmediate("_", "");
        }
        _builder.append("{$item.");
        String _name_2 = pkField_1.getName();
        String _formatForCode_2 = this._formattingExtensions.formatForCode(_name_2);
        _builder.append(_formatForCode_2, "");
        _builder.append("}");
      }
    }
    {
      if ((many).booleanValue()) {
        _builder.append("{if $smarty.foreach.relLoop.last ne true},{/if}{/foreach}");
      }
    }
    _builder.append("{/if}\" />");
    _builder.newLineIfNotEmpty();
    _builder.append("<input type=\"hidden\" id=\"{$idPrefix}Mode\" name=\"{$idPrefix}Mode\" value=\"");
    {
      if ((includeEditing).booleanValue()) {
        _builder.append("1");
      } else {
        _builder.append("0");
      }
    }
    _builder.append("\" />");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("<ul id=\"{$idPrefix}ReferenceList\">");
    _builder.newLine();
    _builder.append("{if isset($item");
    {
      if ((many).booleanValue()) {
        _builder.append("s");
      }
    }
    _builder.append(") && (is_array($item");
    {
      if ((many).booleanValue()) {
        _builder.append("s");
      }
    }
    _builder.append(") || is_object($item");
    {
      if ((many).booleanValue()) {
        _builder.append("s");
      }
    }
    _builder.append("))");
    {
      boolean _not_2 = (!(many).booleanValue());
      if (_not_2) {
        {
          Iterable<DerivedField> _primaryKeyFields_2 = this._modelExtensions.getPrimaryKeyFields(targetEntity);
          for(final DerivedField pkField_2 : _primaryKeyFields_2) {
            _builder.append(" && isset($item.");
            String _name_3 = pkField_2.getName();
            String _formatForCode_3 = this._formattingExtensions.formatForCode(_name_3);
            _builder.append(_formatForCode_3, "");
            _builder.append(")");
          }
        }
      }
    }
    _builder.append("}");
    _builder.newLineIfNotEmpty();
    {
      if ((many).booleanValue()) {
        _builder.append("{foreach name=\'relLoop\' item=\'item\' from=$items}");
        _builder.newLine();
      }
    }
    _builder.append("{assign var=\'idPrefixItem\' value=\"`$idPrefix`Reference_");
    {
      Iterable<DerivedField> _primaryKeyFields_3 = this._modelExtensions.getPrimaryKeyFields(targetEntity);
      boolean _hasElements_1 = false;
      for(final DerivedField pkField_3 : _primaryKeyFields_3) {
        if (!_hasElements_1) {
          _hasElements_1 = true;
        } else {
          _builder.appendImmediate("_", "");
        }
        _builder.append("`$item.");
        String _name_4 = pkField_3.getName();
        String _formatForCode_4 = this._formattingExtensions.formatForCode(_name_4);
        _builder.append(_formatForCode_4, "");
        _builder.append("`");
      }
    }
    _builder.append("\"}");
    _builder.newLineIfNotEmpty();
    _builder.append("<li id=\"{$idPrefixItem}\">");
    _builder.newLine();
    _builder.append("    ");
    final DerivedField leadingField = this._modelExtensions.getLeadingField(targetEntity);
    _builder.newLineIfNotEmpty();
    {
      boolean _tripleNotEquals = (leadingField != null);
      if (_tripleNotEquals) {
        _builder.append("    ");
        _builder.append("{$item.");
        String _name_5 = leadingField.getName();
        String _formatForCode_5 = this._formattingExtensions.formatForCode(_name_5);
        _builder.append(_formatForCode_5, "    ");
        _builder.append("}");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("    ");
        _builder.append("{gt text=\'");
        String _name_6 = targetEntity.getName();
        String _formatForDisplayCapital = this._formattingExtensions.formatForDisplayCapital(_name_6);
        _builder.append(_formatForDisplayCapital, "    ");
        _builder.append("\'}");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      if ((includeEditing).booleanValue()) {
        _builder.append("    ");
        _builder.append("<a id=\"{$idPrefixItem}Edit\" href=\"{modurl modname=\'");
        String _appName_1 = this._utils.appName(app);
        _builder.append(_appName_1, "    ");
        _builder.append("\' type=\'");
        String _formattedName_1 = this._controllerExtensions.formattedName(controller);
        _builder.append(_formattedName_1, "    ");
        _builder.append("\' ");
        String _modUrlEdit = this._urlExtensions.modUrlEdit(targetEntity, "item", Boolean.valueOf(true));
        _builder.append(_modUrlEdit, "    ");
        {
          String _formattedName_2 = this._controllerExtensions.formattedName(controller);
          boolean _equals = Objects.equal(_formattedName_2, "user");
          if (_equals) {
            _builder.append(" forcelongurl=true");
          }
        }
        _builder.append("}\">{$editImage}</a>");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("     ");
    _builder.append("<a id=\"{$idPrefixItem}Remove\" href=\"javascript:");
    String _prefix = app.getPrefix();
    _builder.append(_prefix, "     ");
    _builder.append("RemoveRelatedItem(\'{$idPrefix}\', \'");
    {
      Iterable<DerivedField> _primaryKeyFields_4 = this._modelExtensions.getPrimaryKeyFields(targetEntity);
      boolean _hasElements_2 = false;
      for(final DerivedField pkField_4 : _primaryKeyFields_4) {
        if (!_hasElements_2) {
          _hasElements_2 = true;
        } else {
          _builder.appendImmediate("_", "     ");
        }
        _builder.append("{$item.");
        String _name_7 = pkField_4.getName();
        String _formatForCode_6 = this._formattingExtensions.formatForCode(_name_7);
        _builder.append(_formatForCode_6, "     ");
        _builder.append("}");
      }
    }
    _builder.append("\');\">{$removeImage}</a>");
    _builder.newLineIfNotEmpty();
    {
      boolean _hasImageFieldsEntity = this._modelExtensions.hasImageFieldsEntity(targetEntity);
      if (_hasImageFieldsEntity) {
        _builder.append("    ");
        _builder.append("<br />");
        _builder.newLine();
        _builder.append("    ");
        Iterable<UploadField> _imageFieldsEntity = this._modelExtensions.getImageFieldsEntity(targetEntity);
        UploadField _head = IterableExtensions.<UploadField>head(_imageFieldsEntity);
        String _name_8 = _head.getName();
        final String imageFieldName = this._formattingExtensions.formatForCode(_name_8);
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("{if $item.");
        _builder.append(imageFieldName, "    ");
        _builder.append(" ne \'\' && isset($item.");
        _builder.append(imageFieldName, "    ");
        _builder.append("FullPath) && $item.");
        _builder.append(imageFieldName, "    ");
        _builder.append("Meta.isImage}");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("{thumb image=$item.");
        _builder.append(imageFieldName, "        ");
        _builder.append("FullPath objectid=\"");
        String _name_9 = targetEntity.getName();
        String _formatForCode_7 = this._formattingExtensions.formatForCode(_name_9);
        _builder.append(_formatForCode_7, "        ");
        {
          boolean _hasCompositeKeys = this._modelExtensions.hasCompositeKeys(targetEntity);
          if (_hasCompositeKeys) {
            {
              Iterable<DerivedField> _primaryKeyFields_5 = this._modelExtensions.getPrimaryKeyFields(targetEntity);
              for(final DerivedField pkField_5 : _primaryKeyFields_5) {
                _builder.append("-`$item.");
                String _name_10 = pkField_5.getName();
                String _formatForCode_8 = this._formattingExtensions.formatForCode(_name_10);
                _builder.append(_formatForCode_8, "        ");
                _builder.append("`");
              }
            }
          } else {
            _builder.append("-`$item.");
            Iterable<DerivedField> _primaryKeyFields_6 = this._modelExtensions.getPrimaryKeyFields(targetEntity);
            DerivedField _head_1 = IterableExtensions.<DerivedField>head(_primaryKeyFields_6);
            String _name_11 = _head_1.getName();
            String _formatForCode_9 = this._formattingExtensions.formatForCode(_name_11);
            _builder.append(_formatForCode_9, "        ");
            _builder.append("`");
          }
        }
        _builder.append("\" preset=$relationThumbPreset tag=true ");
        {
          boolean _tripleNotEquals_1 = (leadingField != null);
          if (_tripleNotEquals_1) {
            _builder.append("img_alt=$item.");
            String _name_12 = leadingField.getName();
            String _formatForCode_10 = this._formattingExtensions.formatForCode(_name_12);
            _builder.append(_formatForCode_10, "        ");
          } else {
            _builder.append("__img_alt=\'");
            String _name_13 = targetEntity.getName();
            String _formatForDisplayCapital_1 = this._formattingExtensions.formatForDisplayCapital(_name_13);
            _builder.append(_formatForDisplayCapital_1, "        ");
            _builder.append("\'");
          }
        }
        _builder.append("}");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("{/if}");
        _builder.newLine();
      }
    }
    _builder.append("</li>");
    _builder.newLine();
    {
      if ((many).booleanValue()) {
        _builder.append("{/foreach}");
        _builder.newLine();
      }
    }
    _builder.append("{/if}");
    _builder.newLine();
    _builder.append("</ul>");
    _builder.newLine();
    return _builder;
  }
  
  public CharSequence initJs(final Entity it, final Application app, final Boolean insideLoader) {
    StringConcatenation _builder = new StringConcatenation();
    Iterable<JoinRelationship> _bidirectionalIncomingJoinRelations = this._modelJoinExtensions.getBidirectionalIncomingJoinRelations(it);
    final Function1<JoinRelationship,Boolean> _function = new Function1<JoinRelationship,Boolean>() {
        public Boolean apply(final JoinRelationship e) {
          boolean _and = false;
          Entity _source = e.getSource();
          Models _container = _source.getContainer();
          Application _application = _container.getApplication();
          boolean _equals = Objects.equal(_application, app);
          if (!_equals) {
            _and = false;
          } else {
            boolean _usesAutoCompletion = Relations.this._modelJoinExtensions.usesAutoCompletion(e, false);
            _and = (_equals && _usesAutoCompletion);
          }
          return Boolean.valueOf(_and);
        }
      };
    final Iterable<JoinRelationship> incomingJoins = IterableExtensions.<JoinRelationship>filter(_bidirectionalIncomingJoinRelations, _function);
    _builder.newLineIfNotEmpty();
    Iterable<JoinRelationship> _outgoingJoinRelations = this._modelJoinExtensions.getOutgoingJoinRelations(it);
    final Function1<JoinRelationship,Boolean> _function_1 = new Function1<JoinRelationship,Boolean>() {
        public Boolean apply(final JoinRelationship e) {
          boolean _and = false;
          Entity _target = e.getTarget();
          Models _container = _target.getContainer();
          Application _application = _container.getApplication();
          boolean _equals = Objects.equal(_application, app);
          if (!_equals) {
            _and = false;
          } else {
            boolean _usesAutoCompletion = Relations.this._modelJoinExtensions.usesAutoCompletion(e, true);
            _and = (_equals && _usesAutoCompletion);
          }
          return Boolean.valueOf(_and);
        }
      };
    final Iterable<JoinRelationship> outgoingJoins = IterableExtensions.<JoinRelationship>filter(_outgoingJoinRelations, _function_1);
    _builder.newLineIfNotEmpty();
    {
      boolean _or = false;
      boolean _isEmpty = IterableExtensions.isEmpty(incomingJoins);
      boolean _not = (!_isEmpty);
      if (_not) {
        _or = true;
      } else {
        boolean _isEmpty_1 = IterableExtensions.isEmpty(outgoingJoins);
        boolean _not_1 = (!_isEmpty_1);
        _or = (_not || _not_1);
      }
      if (_or) {
        {
          boolean _not_2 = (!(insideLoader).booleanValue());
          if (_not_2) {
            _builder.append("var editImage = \'<img src=\"{{$editImageArray.src}}\" width=\"16\" height=\"16\" alt=\"\" />\';");
            _builder.newLine();
            _builder.append("var removeImage = \'<img src=\"{{$deleteImageArray.src}}\" width=\"16\" height=\"16\" alt=\"\" />\';");
            _builder.newLine();
            _builder.append("var relationHandler = new Array();");
            _builder.newLine();
          }
        }
        {
          for(final JoinRelationship relation : incomingJoins) {
            CharSequence _initJs = this.initJs(relation, app, it, Boolean.valueOf(true), insideLoader);
            _builder.append(_initJs, "");
          }
        }
        _builder.newLineIfNotEmpty();
        {
          for(final JoinRelationship relation_1 : outgoingJoins) {
            CharSequence _initJs_1 = this.initJs(relation_1, app, it, Boolean.valueOf(false), insideLoader);
            _builder.append(_initJs_1, "");
          }
        }
        _builder.newLineIfNotEmpty();
      }
    }
    return _builder;
  }
  
  private CharSequence initJs(final JoinRelationship it, final Application app, final Entity targetEntity, final Boolean incoming, final Boolean insideLoader) {
    CharSequence _xblockexpression = null;
    {
      final int stageCode = this._controllerExtensions.getEditStageCode(it, incoming);
      boolean _lessThan = (stageCode < 1);
      if (_lessThan) {
        StringConcatenation _builder = new StringConcatenation();
        return _builder.toString();
      }
      final boolean useTarget = (!(incoming).booleanValue());
      boolean _and = false;
      if (!useTarget) {
        _and = false;
      } else {
        boolean _isManyToMany = this.isManyToMany(it);
        boolean _not = (!_isManyToMany);
        _and = (useTarget && _not);
      }
      if (_and) {
        StringConcatenation _builder_1 = new StringConcatenation();
        return _builder_1.toString();
      }
      boolean _usesAutoCompletion = this._modelJoinExtensions.usesAutoCompletion(it, useTarget);
      boolean _not_1 = (!_usesAutoCompletion);
      if (_not_1) {
        StringConcatenation _builder_2 = new StringConcatenation();
        return _builder_2.toString();
      }
      boolean _not_2 = (!(incoming).booleanValue());
      String _relationAliasName = this._namingExtensions.getRelationAliasName(it, Boolean.valueOf(_not_2));
      final String relationAliasName = this._formattingExtensions.formatForCodeCapital(_relationAliasName);
      final boolean many = this._modelJoinExtensions.isManySide(it, useTarget);
      final String uniqueNameForJs = this._modelJoinExtensions.getUniqueRelationNameForJs(it, app, targetEntity, Boolean.valueOf(many), incoming, relationAliasName);
      Entity _xifexpression = null;
      Entity _target = it.getTarget();
      boolean _equals = Objects.equal(targetEntity, _target);
      if (_equals) {
        Entity _source = it.getSource();
        _xifexpression = _source;
      } else {
        Entity _target_1 = it.getTarget();
        _xifexpression = _target_1;
      }
      final Entity linkEntity = _xifexpression;
      CharSequence _xifexpression_1 = null;
      boolean _not_3 = (!(insideLoader).booleanValue());
      if (_not_3) {
        StringConcatenation _builder_3 = new StringConcatenation();
        _builder_3.append("var newItem = new Object();");
        _builder_3.newLine();
        _builder_3.append("newItem.ot = \'");
        String _name = linkEntity.getName();
        String _formatForCode = this._formattingExtensions.formatForCode(_name);
        _builder_3.append(_formatForCode, "");
        _builder_3.append("\';");
        _builder_3.newLineIfNotEmpty();
        _builder_3.append("newItem.alias = \'");
        _builder_3.append(relationAliasName, "");
        _builder_3.append("\';");
        _builder_3.newLineIfNotEmpty();
        _builder_3.append("newItem.prefix = \'");
        _builder_3.append(uniqueNameForJs, "");
        _builder_3.append("SelectorDoNew\';");
        _builder_3.newLineIfNotEmpty();
        _builder_3.append("newItem.moduleName = \'");
        Models _container = linkEntity.getContainer();
        Application _application = _container.getApplication();
        String _appName = this._utils.appName(_application);
        _builder_3.append(_appName, "");
        _builder_3.append("\';");
        _builder_3.newLineIfNotEmpty();
        _builder_3.append("newItem.acInstance = null;");
        _builder_3.newLine();
        _builder_3.append("newItem.windowInstance = null;");
        _builder_3.newLine();
        _builder_3.append("relationHandler.push(newItem);");
        _builder_3.newLine();
        _xifexpression_1 = _builder_3;
      } else {
        StringConcatenation _builder_4 = new StringConcatenation();
        String _prefix = app.getPrefix();
        _builder_4.append(_prefix, "");
        _builder_4.append("InitRelationItemsForm(\'");
        String _name_1 = linkEntity.getName();
        String _formatForCode_1 = this._formattingExtensions.formatForCode(_name_1);
        _builder_4.append(_formatForCode_1, "");
        _builder_4.append("\', \'");
        _builder_4.append(uniqueNameForJs, "");
        _builder_4.append("\', ");
        boolean _greaterThan = (stageCode > 1);
        String _displayBool = this._formattingExtensions.displayBool(Boolean.valueOf(_greaterThan));
        _builder_4.append(_displayBool, "");
        _builder_4.append(");");
        _builder_4.newLineIfNotEmpty();
        _xifexpression_1 = _builder_4;
      }
      _xblockexpression = (_xifexpression_1);
    }
    return _xblockexpression;
  }
  
  private boolean isManyToMany(final JoinRelationship it) {
    boolean _switchResult = false;
    boolean _matched = false;
    if (!_matched) {
      if (it instanceof ManyToManyRelationship) {
        final ManyToManyRelationship _manyToManyRelationship = (ManyToManyRelationship)it;
        _matched=true;
        _switchResult = true;
      }
    }
    if (!_matched) {
      _switchResult = false;
    }
    return _switchResult;
  }
}
