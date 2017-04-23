package org.zikula.modulestudio.generator.cartridges.zclassic.view.formcomponents;

import com.google.common.base.Objects;
import de.guite.modulestudio.metamodel.Application;
import de.guite.modulestudio.metamodel.DataObject;
import de.guite.modulestudio.metamodel.DerivedField;
import de.guite.modulestudio.metamodel.Entity;
import de.guite.modulestudio.metamodel.JoinRelationship;
import de.guite.modulestudio.metamodel.ManyToManyRelationship;
import de.guite.modulestudio.metamodel.UploadField;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
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
  @Extension
  private ControllerExtensions _controllerExtensions = new ControllerExtensions();
  
  @Extension
  private FormattingExtensions _formattingExtensions = new FormattingExtensions();
  
  @Extension
  private ModelExtensions _modelExtensions = new ModelExtensions();
  
  @Extension
  private ModelJoinExtensions _modelJoinExtensions = new ModelJoinExtensions();
  
  @Extension
  private NamingExtensions _namingExtensions = new NamingExtensions();
  
  @Extension
  private UrlExtensions _urlExtensions = new UrlExtensions();
  
  @Extension
  private ViewExtensions _viewExtensions = new ViewExtensions();
  
  @Extension
  private Utils _utils = new Utils();
  
  /**
   * This method creates the templates to be included into the edit forms.
   */
  public CharSequence generateInclusionTemplate(final Entity it, final Application app, final IFileSystemAccess fsa) {
    StringConcatenation _builder = new StringConcatenation();
    {
      Iterable<JoinRelationship> _editableJoinRelations = this._modelJoinExtensions.getEditableJoinRelations(it, Boolean.valueOf(true));
      for(final JoinRelationship relation : _editableJoinRelations) {
        CharSequence _generate = this.generate(relation, app, Boolean.valueOf(false), Boolean.valueOf(false), Boolean.valueOf(true), fsa);
        _builder.append(_generate);
      }
    }
    _builder.newLineIfNotEmpty();
    {
      Iterable<JoinRelationship> _editableJoinRelations_1 = this._modelJoinExtensions.getEditableJoinRelations(it, Boolean.valueOf(false));
      for(final JoinRelationship relation_1 : _editableJoinRelations_1) {
        CharSequence _generate_1 = this.generate(relation_1, app, Boolean.valueOf(false), Boolean.valueOf(false), Boolean.valueOf(false), fsa);
        _builder.append(_generate_1);
      }
    }
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  /**
   * Entry point for form sections treating related objects.
   * This method creates the tab titles for included relationship sections on edit pages.
   */
  public CharSequence generateTabTitles(final Entity it, final Application app, final IFileSystemAccess fsa) {
    StringConcatenation _builder = new StringConcatenation();
    {
      Iterable<JoinRelationship> _editableJoinRelations = this._modelJoinExtensions.getEditableJoinRelations(it, Boolean.valueOf(true));
      for(final JoinRelationship relation : _editableJoinRelations) {
        CharSequence _generate = this.generate(relation, app, Boolean.valueOf(true), Boolean.valueOf(false), Boolean.valueOf(true), fsa);
        _builder.append(_generate);
      }
    }
    _builder.newLineIfNotEmpty();
    {
      Iterable<JoinRelationship> _editableJoinRelations_1 = this._modelJoinExtensions.getEditableJoinRelations(it, Boolean.valueOf(false));
      for(final JoinRelationship relation_1 : _editableJoinRelations_1) {
        CharSequence _generate_1 = this.generate(relation_1, app, Boolean.valueOf(true), Boolean.valueOf(false), Boolean.valueOf(false), fsa);
        _builder.append(_generate_1);
      }
    }
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  /**
   * Entry point for form sections treating related objects.
   * This method creates the include statement contained in the including template.
   */
  public CharSequence generateIncludeStatement(final Entity it, final Application app, final IFileSystemAccess fsa) {
    StringConcatenation _builder = new StringConcatenation();
    {
      Iterable<JoinRelationship> _editableJoinRelations = this._modelJoinExtensions.getEditableJoinRelations(it, Boolean.valueOf(true));
      for(final JoinRelationship relation : _editableJoinRelations) {
        CharSequence _generate = this.generate(relation, app, Boolean.valueOf(false), Boolean.valueOf(true), Boolean.valueOf(true), fsa);
        _builder.append(_generate);
      }
    }
    _builder.newLineIfNotEmpty();
    {
      Iterable<JoinRelationship> _editableJoinRelations_1 = this._modelJoinExtensions.getEditableJoinRelations(it, Boolean.valueOf(false));
      for(final JoinRelationship relation_1 : _editableJoinRelations_1) {
        CharSequence _generate_1 = this.generate(relation_1, app, Boolean.valueOf(false), Boolean.valueOf(true), Boolean.valueOf(false), fsa);
        _builder.append(_generate_1);
      }
    }
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence generate(final JoinRelationship it, final Application app, final Boolean onlyTabTitle, final Boolean onlyInclude, final Boolean incoming, final IFileSystemAccess fsa) {
    final int stageCode = this._controllerExtensions.getEditStageCode(it, incoming);
    if ((stageCode < 1)) {
      StringConcatenation _builder = new StringConcatenation();
      return _builder.toString();
    }
    final boolean useTarget = (!(incoming).booleanValue());
    final boolean hasEdit = (stageCode > 1);
    String _xifexpression = null;
    if (hasEdit) {
      _xifexpression = "Edit";
    } else {
      _xifexpression = "";
    }
    final String editSnippet = _xifexpression;
    final String templateName = this.getTemplateName(it, Boolean.valueOf(useTarget), editSnippet);
    DataObject _xifexpression_1 = null;
    if ((incoming).booleanValue()) {
      _xifexpression_1 = it.getSource();
    } else {
      _xifexpression_1 = it.getTarget();
    }
    final Entity ownEntity = ((Entity) _xifexpression_1);
    DataObject _xifexpression_2 = null;
    if ((!(incoming).booleanValue())) {
      _xifexpression_2 = it.getSource();
    } else {
      _xifexpression_2 = it.getTarget();
    }
    final Entity otherEntity = ((Entity) _xifexpression_2);
    final boolean many = this._modelJoinExtensions.isManySide(it, useTarget);
    if ((onlyTabTitle).booleanValue()) {
      return this.tabTitleForEditTemplate(it, ownEntity, Boolean.valueOf(many));
    }
    if ((onlyInclude).booleanValue()) {
      final String relationAliasName = this._formattingExtensions.formatForCodeCapital(this._namingExtensions.getRelationAliasName(it, Boolean.valueOf(useTarget)));
      final String relationAliasReverse = this._formattingExtensions.formatForCodeCapital(this._namingExtensions.getRelationAliasName(it, Boolean.valueOf((!useTarget))));
      Boolean _xifexpression_3 = null;
      boolean _isManyToMany = this.isManyToMany(it);
      boolean _not = (!_isManyToMany);
      if (_not) {
        _xifexpression_3 = Boolean.valueOf(useTarget);
      } else {
        _xifexpression_3 = incoming;
      }
      final Boolean incomingForUniqueRelationName = _xifexpression_3;
      final String uniqueNameForJs = this._modelJoinExtensions.getUniqueRelationNameForJs(it, app, otherEntity, Boolean.valueOf(many), incomingForUniqueRelationName, relationAliasName);
      return this.includeStatementForEditTemplate(it, templateName, ownEntity, otherEntity, incoming, relationAliasName, relationAliasReverse, uniqueNameForJs);
    }
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(ownEntity.getName());
    String _plus = ("Generating edit inclusion templates for entity \"" + _formatForDisplay);
    String _plus_1 = (_plus + "\"");
    InputOutput.<String>println(_plus_1);
    String _targetMultiplicity = this._modelJoinExtensions.getTargetMultiplicity(it, Boolean.valueOf(useTarget));
    String templateNameItemList = ((("includeSelect" + editSnippet) + "ItemList") + _targetMultiplicity);
    final String templateFileName = this._namingExtensions.templateFile(ownEntity, templateName);
    final String templateFileNameItemList = this._namingExtensions.templateFile(ownEntity, templateNameItemList);
    boolean _shouldBeSkipped = this._namingExtensions.shouldBeSkipped(app, templateFileName);
    boolean _not_1 = (!_shouldBeSkipped);
    if (_not_1) {
      fsa.generateFile(templateFileName, this.includedEditTemplate(it, app, ownEntity, otherEntity, incoming, Boolean.valueOf(hasEdit), Boolean.valueOf(many)));
    }
    boolean _shouldBeSkipped_1 = this._namingExtensions.shouldBeSkipped(app, templateFileNameItemList);
    boolean _not_2 = (!_shouldBeSkipped_1);
    if (_not_2) {
      fsa.generateFile(templateFileNameItemList, this.component_ItemList(it, app, ownEntity, Boolean.valueOf(many), incoming, Boolean.valueOf(hasEdit)));
    }
    return null;
  }
  
  private String getTemplateName(final JoinRelationship it, final Boolean useTarget, final String editSnippet) {
    String _xblockexpression = null;
    {
      String templateName = "";
      if (((useTarget).booleanValue() && (!this.isManyToMany(it)))) {
        templateName = ("includeSelect" + editSnippet);
      } else {
        templateName = ("includeSelect" + editSnippet);
      }
      String _targetMultiplicity = this._modelJoinExtensions.getTargetMultiplicity(it, useTarget);
      String _plus = (templateName + _targetMultiplicity);
      templateName = _plus;
      _xblockexpression = templateName;
    }
    return _xblockexpression;
  }
  
  private CharSequence tabTitleForEditTemplate(final JoinRelationship it, final Entity ownEntity, final Boolean many) {
    StringConcatenation _builder = new StringConcatenation();
    final String ownEntityName = this._modelExtensions.getEntityNameSingularPlural(ownEntity, many);
    _builder.newLineIfNotEmpty();
    _builder.append("<li role=\"presentation\">");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<a id=\"");
    String _formatForCode = this._formattingExtensions.formatForCode(ownEntityName);
    _builder.append(_formatForCode, "    ");
    _builder.append("Tab\" href=\"#tab");
    String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(ownEntityName);
    _builder.append(_formatForCodeCapital, "    ");
    _builder.append("\" title=\"{{ __(\'");
    String _formatForDisplayCapital = this._formattingExtensions.formatForDisplayCapital(ownEntityName);
    _builder.append(_formatForDisplayCapital, "    ");
    _builder.append("\') }}\" role=\"tab\" data-toggle=\"tab\">{{ __(\'");
    String _formatForDisplayCapital_1 = this._formattingExtensions.formatForDisplayCapital(ownEntityName);
    _builder.append(_formatForDisplayCapital_1, "    ");
    _builder.append("\') }}</a>");
    _builder.newLineIfNotEmpty();
    _builder.append("</li>");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence includeStatementForEditTemplate(final JoinRelationship it, final String templateName, final Entity ownEntity, final Entity linkingEntity, final Boolean incoming, final String relationAliasName, final String relationAliasReverse, final String uniqueNameForJs) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{{ include(");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("\'@");
    String _appName = this._utils.appName(it.getApplication());
    _builder.append(_appName, "    ");
    _builder.append("/");
    String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(ownEntity.getName());
    _builder.append(_formatForCodeCapital, "    ");
    _builder.append("/");
    _builder.append(templateName, "    ");
    _builder.append(".html.twig\',");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("{ group: \'");
    String _formatForDB = this._formattingExtensions.formatForDB(linkingEntity.getName());
    _builder.append(_formatForDB, "    ");
    _builder.append("\', alias: \'");
    String _firstLower = StringExtensions.toFirstLower(relationAliasName);
    _builder.append(_firstLower, "    ");
    _builder.append("\', aliasReverse: \'");
    String _firstLower_1 = StringExtensions.toFirstLower(relationAliasReverse);
    _builder.append(_firstLower_1, "    ");
    _builder.append("\', mandatory: ");
    boolean _isNullable = it.isNullable();
    String _displayBool = this._formattingExtensions.displayBool(Boolean.valueOf((!_isNullable)));
    _builder.append(_displayBool, "    ");
    _builder.append(", idPrefix: \'");
    _builder.append(uniqueNameForJs, "    ");
    _builder.append("\', linkingItem: ");
    String _formatForDB_1 = this._formattingExtensions.formatForDB(linkingEntity.getName());
    _builder.append(_formatForDB_1, "    ");
    {
      boolean _useGroupingTabs = this._viewExtensions.useGroupingTabs(linkingEntity, "edit");
      if (_useGroupingTabs) {
        _builder.append(", tabs: true");
      }
    }
    _builder.append(", displayMode: \'");
    {
      boolean _usesAutoCompletion = this._modelJoinExtensions.usesAutoCompletion(it, (incoming).booleanValue());
      if (_usesAutoCompletion) {
        _builder.append("autocomplete");
      } else {
        _builder.append("choices");
      }
    }
    _builder.append("\' }");
    _builder.newLineIfNotEmpty();
    _builder.append(") }}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence includedEditTemplate(final JoinRelationship it, final Application app, final Entity ownEntity, final Entity linkingEntity, final Boolean incoming, final Boolean hasEdit, final Boolean many) {
    StringConcatenation _builder = new StringConcatenation();
    final String ownEntityName = this._modelExtensions.getEntityNameSingularPlural(ownEntity, many);
    _builder.newLineIfNotEmpty();
    _builder.append("{# purpose of this template: inclusion template for managing related ");
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(ownEntityName);
    _builder.append(_formatForDisplay);
    _builder.append(" #}");
    _builder.newLineIfNotEmpty();
    _builder.append("{% if displayMode is not defined or displayMode is empty %}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{% set displayMode = \'choices\' %}");
    _builder.newLine();
    _builder.append("{% endif %}");
    _builder.newLine();
    _builder.append("{% if tabs|default(false) == true %}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<div role=\"tabpanel\" class=\"tab-pane fade\" id=\"tab");
    String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(ownEntityName);
    _builder.append(_formatForCodeCapital, "    ");
    _builder.append("\" aria-labelledby=\"");
    String _formatForCode = this._formattingExtensions.formatForCode(ownEntityName);
    _builder.append(_formatForCode, "    ");
    _builder.append("Tab\">");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("<h3>{{ __(\'");
    String _formatForDisplayCapital = this._formattingExtensions.formatForDisplayCapital(ownEntityName);
    _builder.append(_formatForDisplayCapital, "        ");
    _builder.append("\') }}</h3>");
    _builder.newLineIfNotEmpty();
    _builder.append("{% else %}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<fieldset class=\"");
    String _formatForDB = this._formattingExtensions.formatForDB(ownEntityName);
    _builder.append(_formatForDB, "    ");
    _builder.append("\">");
    _builder.newLineIfNotEmpty();
    _builder.append("{% endif %}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<legend>{{ __(\'");
    String _formatForDisplayCapital_1 = this._formattingExtensions.formatForDisplayCapital(ownEntityName);
    _builder.append(_formatForDisplayCapital_1, "    ");
    _builder.append("\') }}</legend>");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    CharSequence _includedEditTemplateBody = this.includedEditTemplateBody(it, app, ownEntity, linkingEntity, incoming, hasEdit, many);
    _builder.append(_includedEditTemplateBody, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("{% if tabs|default(false) == true %}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("</div>");
    _builder.newLine();
    _builder.append("{% else %}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("</fieldset>");
    _builder.newLine();
    _builder.append("{% endif %}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence includedEditTemplateBody(final JoinRelationship it, final Application app, final Entity ownEntity, final Entity linkingEntity, final Boolean incoming, final Boolean hasEdit, final Boolean many) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{% if displayMode == \'choices\' %}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{{ form_row(attribute(form, alias)) }}");
    _builder.newLine();
    _builder.append("{% elseif displayMode == \'autocomplete\' %}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{{ form_row(attribute(form, alias)) }}");
    _builder.newLine();
    _builder.append("    ");
    CharSequence _component_AutoComplete = this.component_AutoComplete(it, app, ownEntity, many, incoming, hasEdit);
    _builder.append(_component_AutoComplete, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("{% endif %}");
    _builder.newLine();
    return _builder;
  }
  
  /**
   * def private component_ParentEditing(JoinRelationship it, Entity targetEntity, Boolean many) '''
   * «/* just a reminder for the parent view which is not tested yet (see #10)
   * Example: create children (e.g. an address) while creating a parent (e.g. a new customer).
   * Problem: address must know the customerid.
   * To do only for $mode != create:
   * <p>ADD: button to create «targetEntity.getEntityNameSingularPlural(many).formatForDisplay» with inline editing (form dialog)</p>
   * <p>EDIT: display of related «targetEntity.getEntityNameSingularPlural(many).formatForDisplay» with inline editing (form dialog)</p>
   * /»
   * '''
   */
  private CharSequence component_AutoComplete(final JoinRelationship it, final Application app, final Entity targetEntity, final Boolean many, final Boolean incoming, final Boolean includeEditing) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("<div class=\"");
    String _lowerCase = this._utils.appName(app).toLowerCase();
    _builder.append(_lowerCase);
    _builder.append("-relation-leftside\">");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    final CharSequence includeStatement = this.component_IncludeStatementForAutoCompleterItemList(it, targetEntity, many, incoming, includeEditing);
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("{{ include(");
    _builder.newLine();
    _builder.append("        ");
    _builder.append(includeStatement, "        ");
    _builder.append(",");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("attribute(linkingItem, alias) is defined ? { item");
    {
      if ((many).booleanValue()) {
        _builder.append("s");
      }
    }
    _builder.append(": attribute(linkingItem, alias) } : {}");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append(") }}");
    _builder.newLine();
    _builder.append("</div>");
    _builder.newLine();
    _builder.append("<br style=\"clear: both\" />");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence component_IncludeStatementForAutoCompleterItemList(final JoinRelationship it, final Entity targetEntity, final Boolean many, final Boolean incoming, final Boolean includeEditing) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("\'@");
    String _appName = this._utils.appName(it.getApplication());
    _builder.append(_appName);
    _builder.append("/");
    String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(targetEntity.getName());
    _builder.append(_formatForCodeCapital);
    _builder.append("/includeSelect");
    {
      if ((includeEditing).booleanValue()) {
        _builder.append("Edit");
      }
    }
    _builder.append("ItemList");
    {
      if ((!(many).booleanValue())) {
        _builder.append("One");
      } else {
        _builder.append("Many");
      }
    }
    _builder.append(".html.twig\'");
    return _builder;
  }
  
  private CharSequence component_ItemList(final JoinRelationship it, final Application app, final Entity targetEntity, final Boolean many, final Boolean incoming, final Boolean includeEditing) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{# purpose of this template: inclusion template for display of related ");
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(this._modelExtensions.getEntityNameSingularPlural(targetEntity, many));
    _builder.append(_formatForDisplay);
    _builder.append(" #}");
    _builder.newLineIfNotEmpty();
    {
      if ((includeEditing).booleanValue()) {
        _builder.append("{% set editImage = \'<span class=\"fa fa-pencil-square-o\"></span>\' %}");
        _builder.newLine();
      }
    }
    _builder.append("{% set removeImage = \'<span class=\"fa fa-trash-o\"></span>\' %}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("<input type=\"hidden\" id=\"{{ idPrefix }}\" name=\"{{ idPrefix }}\" value=\"{% if item");
    {
      if ((many).booleanValue()) {
        _builder.append("s");
      }
    }
    _builder.append(" is defined");
    {
      if ((many).booleanValue()) {
        _builder.append(" and items is iterable");
      } else {
        {
          Iterable<DerivedField> _primaryKeyFields = this._modelExtensions.getPrimaryKeyFields(targetEntity);
          for(final DerivedField pkField : _primaryKeyFields) {
            _builder.append(" and item.");
            String _formatForCode = this._formattingExtensions.formatForCode(pkField.getName());
            _builder.append(_formatForCode);
            _builder.append(" is defined");
          }
        }
      }
    }
    _builder.append(" %}");
    {
      if ((many).booleanValue()) {
        _builder.append("{% for item in items %}");
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
        _builder.append("{{ item.");
        String _formatForCode_1 = this._formattingExtensions.formatForCode(pkField_1.getName());
        _builder.append(_formatForCode_1);
        _builder.append(" }}");
      }
    }
    {
      if ((many).booleanValue()) {
        _builder.append("{% if not loop.last %},{% endif %}{% endfor %}");
      }
    }
    _builder.append("{% endif %}\" />");
    _builder.newLineIfNotEmpty();
    _builder.append("<input type=\"hidden\" id=\"{{ idPrefix }}Mode\" name=\"{{ idPrefix }}Mode\" value=\"");
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
    _builder.append("<ul id=\"{{ idPrefix }}ReferenceList\">");
    _builder.newLine();
    _builder.append("{% if item");
    {
      if ((many).booleanValue()) {
        _builder.append("s");
      }
    }
    _builder.append(" is defined");
    {
      if ((many).booleanValue()) {
        _builder.append(" and items is iterable");
      } else {
        {
          Iterable<DerivedField> _primaryKeyFields_2 = this._modelExtensions.getPrimaryKeyFields(targetEntity);
          for(final DerivedField pkField_2 : _primaryKeyFields_2) {
            _builder.append(" and item.");
            String _formatForCode_2 = this._formattingExtensions.formatForCode(pkField_2.getName());
            _builder.append(_formatForCode_2);
            _builder.append(" is defined");
          }
        }
      }
    }
    _builder.append(" %}");
    _builder.newLineIfNotEmpty();
    {
      if ((many).booleanValue()) {
        _builder.append("{% for item in items %}");
        _builder.newLine();
      }
    }
    _builder.append("{% set idPrefixItem = idPrefix ~ \'Reference_\'");
    {
      Iterable<DerivedField> _primaryKeyFields_3 = this._modelExtensions.getPrimaryKeyFields(targetEntity);
      for(final DerivedField pkField_3 : _primaryKeyFields_3) {
        _builder.append(" ~ item.");
        String _formatForCode_3 = this._formattingExtensions.formatForCode(pkField_3.getName());
        _builder.append(_formatForCode_3);
      }
    }
    _builder.append(" %}");
    _builder.newLineIfNotEmpty();
    _builder.append("<li id=\"{{ idPrefixItem }}\">");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{{ item.getTitleFromDisplayPattern() }}");
    _builder.newLine();
    {
      if ((includeEditing).booleanValue()) {
        _builder.append("    ");
        _builder.append("<a id=\"{{ idPrefixItem }}Edit\" href=\"{{ path(\'");
        String _formatForDB = this._formattingExtensions.formatForDB(this._utils.appName(app));
        _builder.append(_formatForDB, "    ");
        _builder.append("_");
        String _formatForDB_1 = this._formattingExtensions.formatForDB(targetEntity.getName());
        _builder.append(_formatForDB_1, "    ");
        _builder.append("_\' ~ routeArea ~ \'edit\'");
        CharSequence _routeParams = this._urlExtensions.routeParams(targetEntity, "item", Boolean.valueOf(true));
        _builder.append(_routeParams, "    ");
        _builder.append(") }}\">{{ editImage|raw }}</a>");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("     ");
    _builder.append("<a id=\"{{ idPrefixItem }}Remove\" href=\"javascript:");
    String _vendorAndName = this._utils.vendorAndName(app);
    _builder.append(_vendorAndName, "     ");
    _builder.append("RemoveRelatedItem(\'{{ idPrefix }}\', \'");
    {
      Iterable<DerivedField> _primaryKeyFields_4 = this._modelExtensions.getPrimaryKeyFields(targetEntity);
      boolean _hasElements_1 = false;
      for(final DerivedField pkField_4 : _primaryKeyFields_4) {
        if (!_hasElements_1) {
          _hasElements_1 = true;
        } else {
          _builder.appendImmediate("_", "     ");
        }
        _builder.append("{{ item.");
        String _formatForCode_4 = this._formattingExtensions.formatForCode(pkField_4.getName());
        _builder.append(_formatForCode_4, "     ");
        _builder.append(" }}");
      }
    }
    _builder.append("\');\">{{ removeImage|raw }}</a>");
    _builder.newLineIfNotEmpty();
    {
      boolean _hasImageFieldsEntity = this._modelExtensions.hasImageFieldsEntity(targetEntity);
      if (_hasImageFieldsEntity) {
        _builder.append("    ");
        _builder.append("<br />");
        _builder.newLine();
        _builder.append("    ");
        final String imageFieldName = this._formattingExtensions.formatForCode(IterableExtensions.<UploadField>head(this._modelExtensions.getImageFieldsEntity(targetEntity)).getName());
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("{% if item.");
        _builder.append(imageFieldName, "    ");
        _builder.append(" is not empty and item.");
        _builder.append(imageFieldName, "    ");
        _builder.append("Meta.isImage %}");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("<img src=\"{{ item.");
        _builder.append(imageFieldName, "        ");
        _builder.append(".getPathname()|imagine_filter(\'zkroot\', relationThumbRuntimeOptions) }}\" alt=\"{{ item.getTitleFromDisplayPattern()|e(\'html_attr\') }}\" width=\"{{ relationThumbRuntimeOptions.thumbnail.size[0] }}\" height=\"{{ relationThumbRuntimeOptions.thumbnail.size[1] }}\" class=\"img-rounded\" />");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("{% endif %}");
        _builder.newLine();
      }
    }
    _builder.append("</li>");
    _builder.newLine();
    {
      if ((many).booleanValue()) {
        _builder.append("{% endfor %}");
        _builder.newLine();
      }
    }
    _builder.append("{% endif %}");
    _builder.newLine();
    _builder.append("</ul>");
    _builder.newLine();
    return _builder;
  }
  
  public CharSequence initJs(final Entity it, final Application app, final Boolean insideLoader) {
    StringConcatenation _builder = new StringConcatenation();
    final Function1<JoinRelationship, Boolean> _function = (JoinRelationship it_1) -> {
      return Boolean.valueOf(this._modelJoinExtensions.usesAutoCompletion(it_1, true));
    };
    final Iterable<JoinRelationship> incomingJoins = IterableExtensions.<JoinRelationship>filter(this._modelJoinExtensions.getEditableJoinRelations(it, Boolean.valueOf(true)), _function);
    _builder.newLineIfNotEmpty();
    final Function1<JoinRelationship, Boolean> _function_1 = (JoinRelationship it_1) -> {
      return Boolean.valueOf(this._modelJoinExtensions.usesAutoCompletion(it_1, false));
    };
    final Iterable<JoinRelationship> outgoingJoins = IterableExtensions.<JoinRelationship>filter(this._modelJoinExtensions.getEditableJoinRelations(it, Boolean.valueOf(false)), _function_1);
    _builder.newLineIfNotEmpty();
    {
      if (((!IterableExtensions.isEmpty(incomingJoins)) || (!IterableExtensions.isEmpty(outgoingJoins)))) {
        {
          if ((!(insideLoader).booleanValue())) {
            _builder.append("var editImage = \'{{ editImage|raw }}\';");
            _builder.newLine();
            _builder.append("var removeImage = \'{{ removeImage|raw }}\';");
            _builder.newLine();
            _builder.append("var relationHandler = new Array();");
            _builder.newLine();
          }
        }
        {
          for(final JoinRelationship relation : incomingJoins) {
            CharSequence _initJs = this.initJs(relation, app, it, Boolean.valueOf(true), insideLoader);
            _builder.append(_initJs);
          }
        }
        _builder.newLineIfNotEmpty();
        {
          for(final JoinRelationship relation_1 : outgoingJoins) {
            CharSequence _initJs_1 = this.initJs(relation_1, app, it, Boolean.valueOf(false), insideLoader);
            _builder.append(_initJs_1);
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
      if ((stageCode < 1)) {
        StringConcatenation _builder = new StringConcatenation();
        return _builder.toString();
      }
      final boolean useTarget = (!(incoming).booleanValue());
      boolean _usesAutoCompletion = this._modelJoinExtensions.usesAutoCompletion(it, (incoming).booleanValue());
      boolean _not = (!_usesAutoCompletion);
      if (_not) {
        StringConcatenation _builder_1 = new StringConcatenation();
        return _builder_1.toString();
      }
      final String relationAliasName = this._formattingExtensions.formatForCodeCapital(this._namingExtensions.getRelationAliasName(it, Boolean.valueOf((!(incoming).booleanValue()))));
      final boolean many = this._modelJoinExtensions.isManySide(it, useTarget);
      final String uniqueNameForJs = this._modelJoinExtensions.getUniqueRelationNameForJs(it, app, targetEntity, Boolean.valueOf(many), incoming, relationAliasName);
      DataObject _xifexpression = null;
      DataObject _target = it.getTarget();
      boolean _equals = Objects.equal(targetEntity, _target);
      if (_equals) {
        _xifexpression = it.getSource();
      } else {
        _xifexpression = it.getTarget();
      }
      final DataObject linkEntity = _xifexpression;
      CharSequence _xifexpression_1 = null;
      if ((!(insideLoader).booleanValue())) {
        StringConcatenation _builder_2 = new StringConcatenation();
        _builder_2.append("var newItem = {");
        _builder_2.newLine();
        _builder_2.append("    ");
        _builder_2.append("ot: \'");
        String _formatForCode = this._formattingExtensions.formatForCode(linkEntity.getName());
        _builder_2.append(_formatForCode, "    ");
        _builder_2.append("\',");
        _builder_2.newLineIfNotEmpty();
        _builder_2.append("    ");
        _builder_2.append("prefix: \'");
        _builder_2.append(uniqueNameForJs, "    ");
        _builder_2.append("SelectorDoNew\',");
        _builder_2.newLineIfNotEmpty();
        _builder_2.append("    ");
        _builder_2.append("moduleName: \'");
        String _appName = this._utils.appName(linkEntity.getApplication());
        _builder_2.append(_appName, "    ");
        _builder_2.append("\',");
        _builder_2.newLineIfNotEmpty();
        _builder_2.append("    ");
        _builder_2.append("acInstance: null,");
        _builder_2.newLine();
        _builder_2.append("    ");
        _builder_2.append("windowInstanceId: null");
        _builder_2.newLine();
        _builder_2.append("};");
        _builder_2.newLine();
        _builder_2.append("relationHandler.push(newItem);");
        _builder_2.newLine();
        _xifexpression_1 = _builder_2;
      } else {
        StringConcatenation _builder_3 = new StringConcatenation();
        String _vendorAndName = this._utils.vendorAndName(app);
        _builder_3.append(_vendorAndName);
        _builder_3.append("InitRelationItemsForm(\'");
        String _formatForCode_1 = this._formattingExtensions.formatForCode(linkEntity.getName());
        _builder_3.append(_formatForCode_1);
        _builder_3.append("\', \'");
        _builder_3.append(uniqueNameForJs);
        _builder_3.append("\', ");
        String _displayBool = this._formattingExtensions.displayBool(Boolean.valueOf((stageCode > 1)));
        _builder_3.append(_displayBool);
        _builder_3.append(");");
        _builder_3.newLineIfNotEmpty();
        _xifexpression_1 = _builder_3;
      }
      _xblockexpression = _xifexpression_1;
    }
    return _xblockexpression;
  }
  
  private boolean isManyToMany(final JoinRelationship it) {
    boolean _switchResult = false;
    boolean _matched = false;
    if (it instanceof ManyToManyRelationship) {
      _matched=true;
      _switchResult = true;
    }
    if (!_matched) {
      _switchResult = false;
    }
    return _switchResult;
  }
}
