package org.zikula.modulestudio.generator.cartridges.zclassic.view;

import com.google.common.base.Objects;
import de.guite.modulestudio.metamodel.AbstractDateField;
import de.guite.modulestudio.metamodel.Application;
import de.guite.modulestudio.metamodel.DateField;
import de.guite.modulestudio.metamodel.DatetimeField;
import de.guite.modulestudio.metamodel.DerivedField;
import de.guite.modulestudio.metamodel.Entity;
import de.guite.modulestudio.metamodel.JoinRelationship;
import de.guite.modulestudio.metamodel.UploadField;
import de.guite.modulestudio.metamodel.UserField;
import java.util.ArrayList;
import java.util.List;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.CollectionLiterals;
import org.eclipse.xtext.xbase.lib.Conversions;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.InputOutput;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.zikula.modulestudio.generator.cartridges.zclassic.view.formcomponents.Relations;
import org.zikula.modulestudio.generator.cartridges.zclassic.view.formcomponents.Section;
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
  @Extension
  private ControllerExtensions _controllerExtensions = new ControllerExtensions();
  
  @Extension
  private FormattingExtensions _formattingExtensions = new FormattingExtensions();
  
  @Extension
  private ModelExtensions _modelExtensions = new ModelExtensions();
  
  @Extension
  private ModelBehaviourExtensions _modelBehaviourExtensions = new ModelBehaviourExtensions();
  
  @Extension
  private ModelJoinExtensions _modelJoinExtensions = new ModelJoinExtensions();
  
  @Extension
  private NamingExtensions _namingExtensions = new NamingExtensions();
  
  @Extension
  private Utils _utils = new Utils();
  
  @Extension
  private ViewExtensions _viewExtensions = new ViewExtensions();
  
  private Relations relationHelper = new Relations();
  
  public void generate(final Application it, final IFileSystemAccess fsa) {
    final Function1<Entity, Boolean> _function = (Entity it_1) -> {
      return Boolean.valueOf(this._controllerExtensions.hasEditAction(it_1));
    };
    Iterable<Entity> _filter = IterableExtensions.<Entity>filter(this._modelExtensions.getAllEntities(it), _function);
    for (final Entity entity : _filter) {
      {
        this.generate(entity, it, "edit", fsa);
        boolean _needsAutoCompletion = this._modelJoinExtensions.needsAutoCompletion(it);
        if (_needsAutoCompletion) {
          this.entityInlineRedirectHandlerFile(entity, it, fsa);
        }
      }
    }
  }
  
  /**
   * Entry point for form templates for each entity.
   */
  private CharSequence generate(final Entity it, final Application app, final String actionName, final IFileSystemAccess fsa) {
    CharSequence _xblockexpression = null;
    {
      final String templatePath = this._namingExtensions.editTemplateFile(it, actionName);
      boolean _shouldBeSkipped = this._namingExtensions.shouldBeSkipped(app, templatePath);
      boolean _not = (!_shouldBeSkipped);
      if (_not) {
        String _formatForDisplay = this._formattingExtensions.formatForDisplay(it.getName());
        String _plus = ("Generating edit form templates for entity \"" + _formatForDisplay);
        String _plus_1 = (_plus + "\"");
        InputOutput.<String>println(_plus_1);
        StringConcatenation _builder = new StringConcatenation();
        CharSequence _formTemplate = this.formTemplate(it, app, actionName, fsa);
        _builder.append(_formTemplate);
        _builder.newLineIfNotEmpty();
        fsa.generateFile(templatePath, _builder);
      }
      _xblockexpression = this.relationHelper.generateInclusionTemplate(it, app, fsa);
    }
    return _xblockexpression;
  }
  
  private CharSequence formTemplate(final Entity it, final Application app, final String actionName, final IFileSystemAccess fsa) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{# purpose of this template: build the form to ");
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(actionName);
    _builder.append(_formatForDisplay);
    _builder.append(" an instance of ");
    String _formatForDisplay_1 = this._formattingExtensions.formatForDisplay(it.getName());
    _builder.append(_formatForDisplay_1);
    _builder.append(" #}");
    _builder.newLineIfNotEmpty();
    _builder.append("{% set baseTemplate = app.request.query.getBoolean(\'raw\', false) ? \'raw\' : (routeArea == \'admin\' ? \'adminBase\' : \'base\') %}");
    _builder.newLine();
    _builder.append("{% extends \'");
    String _appName = this._utils.appName(it.getApplication());
    _builder.append(_appName);
    _builder.append("::\' ~ baseTemplate ~ \'.html.twig\' %}");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("{% block header %}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{{ parent() }}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{{ pageAddAsset(\'javascript\', zasset(\'@");
    String _appName_1 = this._utils.appName(app);
    _builder.append(_appName_1, "    ");
    _builder.append(":js/");
    String _appName_2 = this._utils.appName(app);
    _builder.append(_appName_2, "    ");
    _builder.append(".Validation.js\'), 98) }}");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("{{ pageAddAsset(\'javascript\', zasset(\'@");
    String _appName_3 = this._utils.appName(app);
    _builder.append(_appName_3, "    ");
    _builder.append(":js/");
    String _appName_4 = this._utils.appName(app);
    _builder.append(_appName_4, "    ");
    _builder.append(".EditFunctions.js\'), 99) }}");
    _builder.newLineIfNotEmpty();
    {
      if ((((this._modelExtensions.hasUserFieldsEntity(it) || it.isStandardFields()) || (!IterableExtensions.isEmpty(this._modelJoinExtensions.getOutgoingJoinRelations(it)))) || (!IterableExtensions.isEmpty(this._modelJoinExtensions.getIncomingJoinRelations(it))))) {
        _builder.append("    ");
        _builder.append("{{ pageAddAsset(\'javascript\', asset(\'typeahead/typeahead.bundle.min.js\')) }}");
        _builder.newLine();
      }
    }
    _builder.append("{% endblock %}");
    _builder.newLine();
    _builder.append("{% block title mode == \'create\' ? __(\'Create ");
    String _formatForDisplay_2 = this._formattingExtensions.formatForDisplay(it.getName());
    _builder.append(_formatForDisplay_2);
    _builder.append("\') : __(\'Edit ");
    String _formatForDisplay_3 = this._formattingExtensions.formatForDisplay(it.getName());
    _builder.append(_formatForDisplay_3);
    _builder.append("\') %}");
    _builder.newLineIfNotEmpty();
    _builder.append("{% block admin_page_icon mode == \'create\' ? \'plus\' : \'pencil-square-o\' %}");
    _builder.newLine();
    _builder.append("{% block content %}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<div class=\"");
    String _lowerCase = this._utils.appName(app).toLowerCase();
    _builder.append(_lowerCase, "    ");
    _builder.append("-");
    String _formatForDB = this._formattingExtensions.formatForDB(it.getName());
    _builder.append(_formatForDB, "    ");
    _builder.append(" ");
    String _lowerCase_1 = this._utils.appName(app).toLowerCase();
    _builder.append(_lowerCase_1, "    ");
    _builder.append("-edit\">");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    CharSequence _formTemplateBody = this.formTemplateBody(it, app, actionName, fsa);
    _builder.append(_formTemplateBody, "        ");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("</div>");
    _builder.newLine();
    _builder.append("{% endblock %}");
    _builder.newLine();
    _builder.append("{% block footer %}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{{ parent() }}");
    _builder.newLine();
    _builder.append("    ");
    CharSequence _formTemplateJS = this.formTemplateJS(it, app, actionName);
    _builder.append(_formTemplateJS, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("{% endblock %}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence formTemplateBody(final Entity it, final Application app, final String actionName, final IFileSystemAccess fsa) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{% form_theme form with [");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("\'@");
    String _appName = this._utils.appName(it.getApplication());
    _builder.append(_appName, "    ");
    _builder.append("/Form/bootstrap_3.html.twig\',");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("\'ZikulaFormExtensionBundle:Form:form_div_layout.html.twig\'");
    _builder.newLine();
    _builder.append("] %}");
    _builder.newLine();
    _builder.append("{{ form_start(form, {attr: {id: \'");
    String _formatForCode = this._formattingExtensions.formatForCode(it.getName());
    _builder.append(_formatForCode);
    _builder.append("EditForm\', class: \'");
    String _lowerCase = this._utils.vendorAndName(app).toLowerCase();
    _builder.append(_lowerCase);
    _builder.append("-edit-form\'}}) }}");
    _builder.newLineIfNotEmpty();
    {
      boolean _useGroupingTabs = this._viewExtensions.useGroupingTabs(it, "edit");
      if (_useGroupingTabs) {
        _builder.append("<div class=\"zikula-bootstrap-tab-container\">");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("<ul class=\"nav nav-tabs\">");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("<li role=\"presentation\" class=\"active\">");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("<a id=\"fieldsTab\" href=\"#tabFields\" title=\"{{ __(\'Fields\') }}\" role=\"tab\" data-toggle=\"tab\">{{ __(\'Fields\') }}</a>");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("</li>");
        _builder.newLine();
        {
          boolean _isGeographical = it.isGeographical();
          if (_isGeographical) {
            _builder.append("        ");
            _builder.append("<li role=\"presentation\">");
            _builder.newLine();
            _builder.append("        ");
            _builder.append("    ");
            _builder.append("<a id=\"mapTab\" href=\"#tabMap\" title=\"{{ __(\'Map\') }}\" role=\"tab\" data-toggle=\"tab\">{{ __(\'Map\') }}</a>");
            _builder.newLine();
            _builder.append("        ");
            _builder.append("</li>");
            _builder.newLine();
          }
        }
        _builder.append("        ");
        CharSequence _generateTabTitles = this.relationHelper.generateTabTitles(it, app, fsa);
        _builder.append(_generateTabTitles, "        ");
        _builder.newLineIfNotEmpty();
        {
          boolean _isAttributable = it.isAttributable();
          if (_isAttributable) {
            _builder.append("        ");
            _builder.append("{% if featureActivationHelper.isEnabled(constant(\'");
            String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(app.getVendor());
            _builder.append(_formatForCodeCapital, "        ");
            _builder.append("\\\\");
            String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(app.getName());
            _builder.append(_formatForCodeCapital_1, "        ");
            _builder.append("Module\\\\Helper\\\\FeatureActivationHelper::ATTRIBUTES\'), \'");
            String _formatForCode_1 = this._formattingExtensions.formatForCode(it.getName());
            _builder.append(_formatForCode_1, "        ");
            _builder.append("\') %}");
            _builder.newLineIfNotEmpty();
            _builder.append("        ");
            _builder.append("    ");
            _builder.append("<li role=\"presentation\">");
            _builder.newLine();
            _builder.append("        ");
            _builder.append("        ");
            _builder.append("<a id=\"attributesTab\" href=\"#tabAttributes\" title=\"{{ __(\'Attributes\') }}\" role=\"tab\" data-toggle=\"tab\">{{ __(\'Attributes\') }}</a>");
            _builder.newLine();
            _builder.append("        ");
            _builder.append("    ");
            _builder.append("</li>");
            _builder.newLine();
            _builder.append("        ");
            _builder.append("{% endif %}");
            _builder.newLine();
          }
        }
        {
          boolean _isCategorisable = it.isCategorisable();
          if (_isCategorisable) {
            _builder.append("        ");
            _builder.append("{% if featureActivationHelper.isEnabled(constant(\'");
            String _formatForCodeCapital_2 = this._formattingExtensions.formatForCodeCapital(app.getVendor());
            _builder.append(_formatForCodeCapital_2, "        ");
            _builder.append("\\\\");
            String _formatForCodeCapital_3 = this._formattingExtensions.formatForCodeCapital(app.getName());
            _builder.append(_formatForCodeCapital_3, "        ");
            _builder.append("Module\\\\Helper\\\\FeatureActivationHelper::CATEGORIES\'), \'");
            String _formatForCode_2 = this._formattingExtensions.formatForCode(it.getName());
            _builder.append(_formatForCode_2, "        ");
            _builder.append("\') %}");
            _builder.newLineIfNotEmpty();
            _builder.append("        ");
            _builder.append("    ");
            _builder.append("<li role=\"presentation\">");
            _builder.newLine();
            _builder.append("        ");
            _builder.append("        ");
            _builder.append("<a id=\"categoriesTab\" href=\"#tabCategories\" title=\"{{ __(\'Categories\') }}\" role=\"tab\" data-toggle=\"tab\">{{ __(\'Categories\') }}</a>");
            _builder.newLine();
            _builder.append("        ");
            _builder.append("    ");
            _builder.append("</li>");
            _builder.newLine();
            _builder.append("        ");
            _builder.append("{% endif %}");
            _builder.newLine();
          }
        }
        {
          boolean _isStandardFields = it.isStandardFields();
          if (_isStandardFields) {
            _builder.append("        ");
            _builder.append("{% if mode != \'create\' %}");
            _builder.newLine();
            _builder.append("        ");
            _builder.append("    ");
            _builder.append("<li role=\"presentation\">");
            _builder.newLine();
            _builder.append("        ");
            _builder.append("        ");
            _builder.append("<a id=\"standardFieldsTab\" href=\"#tabStandardFields\" title=\"{{ __(\'Creation and update\') }}\" role=\"tab\" data-toggle=\"tab\">{{ __(\'Creation and update\') }}</a>");
            _builder.newLine();
            _builder.append("        ");
            _builder.append("    ");
            _builder.append("</li>");
            _builder.newLine();
            _builder.append("        ");
            _builder.append("{% endif %}");
            _builder.newLine();
          }
        }
        {
          boolean _isSkipHookSubscribers = it.isSkipHookSubscribers();
          boolean _not = (!_isSkipHookSubscribers);
          if (_not) {
            _builder.append("        ");
            _builder.append("<li role=\"presentation\">");
            _builder.newLine();
            _builder.append("        ");
            _builder.append("    ");
            _builder.append("<a id=\"hooksTab\" href=\"#tabHooks\" title=\"{{ __(\'Hooks\') }}\" role=\"tab\" data-toggle=\"tab\">{{ __(\'Hooks\') }}</a>");
            _builder.newLine();
            _builder.append("        ");
            _builder.append("</li>");
            _builder.newLine();
          }
        }
        _builder.append("        ");
        _builder.append("{% if form.moderationSpecificCreator is defined %}");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("<li role=\"presentation\">");
        _builder.newLine();
        _builder.append("                ");
        _builder.append("<a id=\"moderationTab\" href=\"#tabModeration\" title=\"{{ __(\'Moderation options\') }}\" role=\"tab\" data-toggle=\"tab\">{{ __(\'Moderation\') }}</a>");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("</li>");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("{% endif %}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("</ul>");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("{{ form_errors(form) }}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("<div class=\"tab-content\">");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("<div role=\"tabpanel\" class=\"tab-pane fade in active\" id=\"tabFields\" aria-labelledby=\"fieldsTab\">");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("<h3>{{ __(\'Fields\') }}</h3>");
        _builder.newLine();
        _builder.append("            ");
        CharSequence _fieldDetails = this.fieldDetails(it, app);
        _builder.append(_fieldDetails, "            ");
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        _builder.append("</div>");
        _builder.newLine();
        _builder.append("        ");
        CharSequence _generate = new Section().generate(it, app, fsa);
        _builder.append(_generate, "        ");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("</div>");
        _builder.newLine();
        _builder.append("</div>");
        _builder.newLine();
      } else {
        _builder.append("{{ form_errors(form) }}");
        _builder.newLine();
        CharSequence _fieldDetails_1 = this.fieldDetails(it, app);
        _builder.append(_fieldDetails_1);
        _builder.newLineIfNotEmpty();
        CharSequence _generate_1 = new Section().generate(it, app, fsa);
        _builder.append(_generate_1);
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.newLine();
    CharSequence _submitActions = this.submitActions(it);
    _builder.append(_submitActions);
    _builder.newLineIfNotEmpty();
    _builder.append("{{ form_end(form) }}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence fieldDetails(final Entity it, final Application app) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _translatableFieldDetails = this.translatableFieldDetails(it);
    _builder.append(_translatableFieldDetails);
    _builder.newLineIfNotEmpty();
    {
      if ((((!this._modelBehaviourExtensions.hasTranslatableFields(it)) || (this._modelBehaviourExtensions.hasTranslatableFields(it) && ((!IterableExtensions.isEmpty(this._modelBehaviourExtensions.getEditableNonTranslatableFields(it))) || (this._modelBehaviourExtensions.hasSluggableFields(it) && (!this._modelBehaviourExtensions.hasTranslatableSlug(it)))))) || it.isGeographical())) {
        CharSequence _fieldDetailsFurtherOptions = this.fieldDetailsFurtherOptions(it, app);
        _builder.append(_fieldDetailsFurtherOptions);
        _builder.newLineIfNotEmpty();
      }
    }
    return _builder;
  }
  
  private CharSequence translatableFieldDetails(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _hasTranslatableFields = this._modelBehaviourExtensions.hasTranslatableFields(it);
      if (_hasTranslatableFields) {
        _builder.append("{% if translationsEnabled == true %}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("<div class=\"zikula-bootstrap-tab-container\">");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("<ul class=\"{{ form.vars.id|lower }}-translation-locales nav nav-tabs\">");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("{% for language in supportedLanguages %}");
        _builder.newLine();
        _builder.append("                ");
        _builder.append("<li{% if language == app.request.locale %} class=\"active\"{% endif %}>");
        _builder.newLine();
        _builder.append("                    ");
        _builder.append("<a href=\"#\" data-toggle=\"tab\" data-target=\".{{ form.vars.id|lower }}-translations-fields-{{ language }}\">");
        _builder.newLine();
        _builder.append("                        ");
        _builder.append("{% if not form.vars.valid %}");
        _builder.newLine();
        _builder.append("                            ");
        _builder.append("<span class=\"label label-danger\"><i class=\"fa fa-warning\"></i><span class=\"sr-only\">{{ __(\'Errors\') }}</span></span>");
        _builder.newLine();
        _builder.append("                        ");
        _builder.append("{% endif %}");
        _builder.newLine();
        _builder.append("                        ");
        _builder.append("{% set hasRequiredFields = language in localesWithMandatoryFields %}");
        _builder.newLine();
        _builder.append("                        ");
        _builder.append("{% if hasRequiredFields %}<span class=\"required\">{% endif %}{{ language|languageName|safeHtml }}{% if hasRequiredFields %}</span>{% endif %}");
        _builder.newLine();
        _builder.append("                    ");
        _builder.append("</a>");
        _builder.newLine();
        _builder.append("                ");
        _builder.append("</li>");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("{% endfor %}");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("</ul>");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("<div class=\"{{ form.vars.id|lower }}-translation-fields tab-content\">");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("{% for language in supportedLanguages %}");
        _builder.newLine();
        _builder.append("                ");
        _builder.append("<div class=\"{{ form.vars.id|lower }}-translations-fields-{{ language }} tab-pane fade{% if language == app.request.locale %} active in{% endif %}\">");
        _builder.newLine();
        _builder.append("                    ");
        _builder.append("<fieldset>");
        _builder.newLine();
        _builder.append("                        ");
        _builder.append("<legend>{{ language|languageName|safeHtml }}</legend>");
        _builder.newLine();
        _builder.append("                        ");
        _builder.append("{% if language == app.request.locale %}");
        _builder.newLine();
        _builder.append("                            ");
        CharSequence _fieldSet = this.fieldSet(it);
        _builder.append(_fieldSet, "                            ");
        _builder.newLineIfNotEmpty();
        _builder.append("                        ");
        _builder.append("{% else %}");
        _builder.newLine();
        _builder.append("                            ");
        _builder.append("{{ form_row(attribute(form, \'translations\' ~ language)) }}");
        _builder.newLine();
        _builder.append("                        ");
        _builder.append("{% endif %}");
        _builder.newLine();
        _builder.append("                    ");
        _builder.append("</fieldset>");
        _builder.newLine();
        _builder.append("                ");
        _builder.append("</div>");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("{% endfor %}");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("</div>");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("</div>");
        _builder.newLine();
        _builder.append("{% else %}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("{% set language = app.request.locale %}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("<fieldset>");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("<legend>{{ language|languageName|safeHtml }}</legend>");
        _builder.newLine();
        _builder.append("        ");
        CharSequence _fieldSet_1 = this.fieldSet(it);
        _builder.append(_fieldSet_1, "        ");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("</fieldset>");
        _builder.newLine();
        _builder.append("{% endif %}");
        _builder.newLine();
      }
    }
    return _builder;
  }
  
  private CharSequence fieldSet(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      Iterable<DerivedField> _editableTranslatableFields = this._modelBehaviourExtensions.getEditableTranslatableFields(it);
      for(final DerivedField field : _editableTranslatableFields) {
        CharSequence _fieldWrapper = this.fieldWrapper(field);
        _builder.append(_fieldWrapper);
      }
    }
    _builder.newLineIfNotEmpty();
    {
      boolean _hasTranslatableSlug = this._modelBehaviourExtensions.hasTranslatableSlug(it);
      if (_hasTranslatableSlug) {
        CharSequence _slugField = this.slugField(it);
        _builder.append(_slugField);
        _builder.newLineIfNotEmpty();
      }
    }
    return _builder;
  }
  
  private CharSequence fieldDetailsFurtherOptions(final Entity it, final Application app) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("<fieldset>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<legend>{{ __(\'");
    {
      boolean _hasTranslatableFields = this._modelBehaviourExtensions.hasTranslatableFields(it);
      if (_hasTranslatableFields) {
        _builder.append("Further properties");
      } else {
        _builder.append("Content");
      }
    }
    _builder.append("\') }}</legend>");
    _builder.newLineIfNotEmpty();
    {
      boolean _hasTranslatableFields_1 = this._modelBehaviourExtensions.hasTranslatableFields(it);
      if (_hasTranslatableFields_1) {
        _builder.append("    ");
        {
          Iterable<DerivedField> _editableNonTranslatableFields = this._modelBehaviourExtensions.getEditableNonTranslatableFields(it);
          for(final DerivedField field : _editableNonTranslatableFields) {
            CharSequence _fieldWrapper = this.fieldWrapper(field);
            _builder.append(_fieldWrapper, "    ");
          }
        }
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("    ");
        {
          List<DerivedField> _editableFields = this._modelExtensions.getEditableFields(it);
          for(final DerivedField field_1 : _editableFields) {
            CharSequence _fieldWrapper_1 = this.fieldWrapper(field_1);
            _builder.append(_fieldWrapper_1, "    ");
          }
        }
        _builder.newLineIfNotEmpty();
      }
    }
    {
      if (((!this._modelBehaviourExtensions.hasTranslatableFields(it)) || (this._modelBehaviourExtensions.hasSluggableFields(it) && (!this._modelBehaviourExtensions.hasTranslatableSlug(it))))) {
        _builder.append("    ");
        CharSequence _slugField = this.slugField(it);
        _builder.append(_slugField, "    ");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      boolean _isGeographical = it.isGeographical();
      if (_isGeographical) {
        {
          ArrayList<String> _newArrayList = CollectionLiterals.<String>newArrayList("latitude", "longitude");
          for(final String geoFieldName : _newArrayList) {
            _builder.append("    ");
            _builder.append("{{ form_row(form.");
            _builder.append(geoFieldName, "    ");
            _builder.append(") }}");
            _builder.newLineIfNotEmpty();
          }
        }
      }
    }
    _builder.append("</fieldset>");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence slugField(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      if (((this._modelBehaviourExtensions.hasSluggableFields(it) && it.isSlugUpdatable()) && this._modelBehaviourExtensions.supportsSlugInputFields(it.getApplication()))) {
        _builder.append("{{ form_row(form.slug) }}");
        _builder.newLine();
      }
    }
    return _builder;
  }
  
  private CharSequence formTemplateJS(final Entity it, final Application app, final String actionName) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{% set editImage = \'<span class=\"fa fa-pencil-square-o\"></span>\' %}");
    _builder.newLine();
    _builder.append("{% set removeImage = \'<span class=\"fa fa-trash-o\"></span>\' %}");
    _builder.newLine();
    {
      boolean _isGeographical = it.isGeographical();
      if (_isGeographical) {
        _builder.newLine();
        _builder.append("{% set geoScripts %}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("{% set useGeoLocation = getModVar(\'");
        String _appName = this._utils.appName(app);
        _builder.append(_appName, "    ");
        _builder.append("\', \'enable");
        String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(it.getName());
        _builder.append(_formatForCodeCapital, "    ");
        _builder.append("GeoLocation\', false) %}");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("{{ pageAddAsset(\'javascript\', \'https://maps.google.com/maps/api/js?key=\' ~ getModVar(\'");
        String _appName_1 = this._utils.appName(app);
        _builder.append(_appName_1, "    ");
        _builder.append("\', \'googleMapsApiKey\', \'\') ~ \'&amp;language=\' ~ app.request.locale ~ \'&amp;sensor=false\') }}");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("{{ pageAddAsset(\'javascript\', app.request.basePath ~ \'/plugins/Mapstraction/lib/vendor/mxn/mxn.js?(googlev3)\') }}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("{% if useGeoLocation == true %}");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("{{ pageAddAsset(\'javascript\', app.request.basePath ~ \'/plugins/Mapstraction/lib/vendor/mxn/mxn.geocoder.js\') }}");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("{{ pageAddAsset(\'javascript\', app.request.basePath ~ \'/plugins/Mapstraction/lib/vendor/mxn/mxn.googlev3.geocoder.js\') }}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("{% endif %}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("<script type=\"text/javascript\">");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("/* <![CDATA[ */");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("( function($) {");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("$(document).ready(function() {");
        _builder.newLine();
        _builder.append("                ");
        String _vendorAndName = this._utils.vendorAndName(app);
        _builder.append(_vendorAndName, "                ");
        _builder.append("InitGeographicalEditing({{ ");
        String _formatForDB = this._formattingExtensions.formatForDB(it.getName());
        _builder.append(_formatForDB, "                ");
        _builder.append(".latitude|");
        String _formatForDB_1 = this._formattingExtensions.formatForDB(this._utils.appName(app));
        _builder.append(_formatForDB_1, "                ");
        _builder.append("_geoData }}, {{ ");
        String _formatForDB_2 = this._formattingExtensions.formatForDB(it.getName());
        _builder.append(_formatForDB_2, "                ");
        _builder.append(".longitude|");
        String _formatForDB_3 = this._formattingExtensions.formatForDB(this._utils.appName(app));
        _builder.append(_formatForDB_3, "                ");
        _builder.append("_geoData }}, \'{{ mode }}\', {% if useGeoLocation == true %}true{% else %}false{% endif %});");
        _builder.newLineIfNotEmpty();
        _builder.append("            ");
        _builder.append("});");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("})(jQuery);");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("/* ]]> */");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("</script>");
        _builder.newLine();
        _builder.append("{% endset %}");
        _builder.newLine();
        _builder.append("{{ pageAddAsset(\'footer\', geoScripts) }}");
        _builder.newLine();
      }
    }
    _builder.newLine();
    _builder.append("<script type=\"text/javascript\">");
    _builder.newLine();
    _builder.append("/* <![CDATA[ */");
    _builder.newLine();
    _builder.append("    ");
    CharSequence _jsInitImpl = this.jsInitImpl(it, app);
    _builder.append(_jsInitImpl, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("/* ]]> */");
    _builder.newLine();
    _builder.append("</script>");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence jsInitImpl(final Entity it, final Application app) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _initJs = this.relationHelper.initJs(it, app, Boolean.valueOf(false));
    _builder.append(_initJs);
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("( function($) {");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$(document).ready(function() {");
    _builder.newLine();
    _builder.append("        ");
    final Iterable<UserField> userFields = this._modelExtensions.getUserFieldsEntity(it);
    _builder.newLineIfNotEmpty();
    {
      if (((!IterableExtensions.isEmpty(userFields)) || it.isStandardFields())) {
        _builder.append("        ");
        _builder.append("// initialise auto completion for user fields");
        _builder.newLine();
        {
          for(final UserField userField : userFields) {
            _builder.append("        ");
            final String realName = this._formattingExtensions.formatForCode(userField.getName());
            _builder.newLineIfNotEmpty();
            _builder.append("        ");
            String _vendorAndName = this._utils.vendorAndName(app);
            _builder.append(_vendorAndName, "        ");
            _builder.append("InitUserField(\'");
            String _lowerCase = this._utils.appName(app).toLowerCase();
            _builder.append(_lowerCase, "        ");
            _builder.append("_");
            String _lowerCase_1 = this._formattingExtensions.formatForCode(it.getName()).toLowerCase();
            _builder.append(_lowerCase_1, "        ");
            _builder.append("_");
            _builder.append(realName, "        ");
            _builder.append("\', \'get");
            String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(it.getName());
            _builder.append(_formatForCodeCapital, "        ");
            String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(realName);
            _builder.append(_formatForCodeCapital_1, "        ");
            _builder.append("Users\');");
            _builder.newLineIfNotEmpty();
          }
        }
        {
          boolean _isStandardFields = it.isStandardFields();
          if (_isStandardFields) {
            _builder.append("        ");
            _builder.append("{% if form.moderationSpecificCreator is defined %}");
            _builder.newLine();
            _builder.append("        ");
            _builder.append("    ");
            String _vendorAndName_1 = this._utils.vendorAndName(app);
            _builder.append(_vendorAndName_1, "            ");
            _builder.append("InitUserField(\'");
            String _lowerCase_2 = this._utils.appName(app).toLowerCase();
            _builder.append(_lowerCase_2, "            ");
            _builder.append("_");
            String _lowerCase_3 = this._formattingExtensions.formatForCode(it.getName()).toLowerCase();
            _builder.append(_lowerCase_3, "            ");
            _builder.append("_moderationSpecificCreator\', \'getCommonUsersList\');");
            _builder.newLineIfNotEmpty();
            _builder.append("        ");
            _builder.append("{% endif %}");
            _builder.newLine();
          }
        }
      }
    }
    _builder.append("        ");
    CharSequence _initJs_1 = this.relationHelper.initJs(it, app, Boolean.valueOf(true));
    _builder.append(_initJs_1, "        ");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    String _vendorAndName_2 = this._utils.vendorAndName(app);
    _builder.append(_vendorAndName_2, "        ");
    _builder.append("InitEditForm(\'{{ mode }}\', \'{% if mode != \'create\' %}{{ ");
    {
      Iterable<DerivedField> _primaryKeyFields = this._modelExtensions.getPrimaryKeyFields(it);
      boolean _hasElements = false;
      for(final DerivedField pkField : _primaryKeyFields) {
        if (!_hasElements) {
          _hasElements = true;
        } else {
          _builder.appendImmediate(" ~ ", "        ");
        }
        String _formatForDB = this._formattingExtensions.formatForDB(it.getName());
        _builder.append(_formatForDB, "        ");
        _builder.append(".");
        String _formatForCode = this._formattingExtensions.formatForCode(pkField.getName());
        _builder.append(_formatForCode, "        ");
      }
    }
    _builder.append(" }}{% endif %}\');");
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
    _builder.append("})(jQuery);");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence fieldWrapper(final DerivedField it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      final Function1<JoinRelationship, Boolean> _function = (JoinRelationship e) -> {
        String _head = IterableExtensions.<String>head(((Iterable<String>)Conversions.doWrapArray(this._modelJoinExtensions.getSourceFields(e))));
        String _formatForDB = this._formattingExtensions.formatForDB(it.getName());
        return Boolean.valueOf(Objects.equal(_head, _formatForDB));
      };
      boolean _isEmpty = IterableExtensions.isEmpty(IterableExtensions.<JoinRelationship>filter(this._modelJoinExtensions.getIncomingJoinRelations(it.getEntity()), _function));
      if (_isEmpty) {
        {
          boolean _isVisible = it.isVisible();
          boolean _not = (!_isVisible);
          if (_not) {
            _builder.append("<div class=\"hidden\">");
            _builder.newLine();
            _builder.append("    ");
            CharSequence _formRow = this.formRow(it);
            _builder.append(_formRow, "    ");
            _builder.newLineIfNotEmpty();
            _builder.append("</div>");
            _builder.newLine();
          } else {
            CharSequence _formRow_1 = this.formRow(it);
            _builder.append(_formRow_1);
            _builder.newLineIfNotEmpty();
          }
        }
      }
    }
    return _builder;
  }
  
  private CharSequence formRow(final DerivedField it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{{ form_row(form.");
    String _formatForCode = this._formattingExtensions.formatForCode(it.getName());
    _builder.append(_formatForCode);
    _builder.append(") }}");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence submitActions(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{# include possible submit actions #}");
    _builder.newLine();
    _builder.append("<div class=\"form-group form-buttons\">");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<div class=\"col-sm-offset-3 col-sm-9\">");
    _builder.newLine();
    _builder.append("        ");
    CharSequence _submitActionsImpl = this.submitActionsImpl(it);
    _builder.append(_submitActionsImpl, "        ");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("</div>");
    _builder.newLine();
    _builder.append("</div>");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence submitActionsImpl(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{% for action in actions %}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{{ form_widget(attribute(form, action.id)) }}");
    _builder.newLine();
    _builder.append("{% endfor %}");
    _builder.newLine();
    _builder.append("{{ form_widget(form.reset) }}");
    _builder.newLine();
    _builder.append("{{ form_widget(form.cancel) }}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence additionalInitScript(final DerivedField it) {
    CharSequence _switchResult = null;
    boolean _matched = false;
    if (it instanceof UploadField) {
      _matched=true;
      _switchResult = this.additionalInitScriptUpload(((UploadField)it));
    }
    if (!_matched) {
      if (it instanceof DatetimeField) {
        _matched=true;
        _switchResult = this.additionalInitScriptCalendar(((AbstractDateField)it));
      }
    }
    if (!_matched) {
      if (it instanceof DateField) {
        _matched=true;
        _switchResult = this.additionalInitScriptCalendar(((AbstractDateField)it));
      }
    }
    return _switchResult;
  }
  
  private CharSequence additionalInitScriptUpload(final UploadField it) {
    StringConcatenation _builder = new StringConcatenation();
    String _vendorAndName = this._utils.vendorAndName(it.getEntity().getApplication());
    _builder.append(_vendorAndName);
    _builder.append("InitUploadField(\'");
    String _lowerCase = this._utils.appName(it.getEntity().getApplication()).toLowerCase();
    _builder.append(_lowerCase);
    _builder.append("_");
    String _lowerCase_1 = this._formattingExtensions.formatForCode(it.getEntity().getName()).toLowerCase();
    _builder.append(_lowerCase_1);
    _builder.append("_");
    String _formatForCode = this._formattingExtensions.formatForCode(it.getName());
    _builder.append(_formatForCode);
    _builder.append("_");
    String _formatForCode_1 = this._formattingExtensions.formatForCode(it.getName());
    _builder.append(_formatForCode_1);
    _builder.append("\');");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence additionalInitScriptCalendar(final AbstractDateField it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _isMandatory = it.isMandatory();
      boolean _not = (!_isMandatory);
      if (_not) {
        String _vendorAndName = this._utils.vendorAndName(it.getEntity().getApplication());
        _builder.append(_vendorAndName);
        _builder.append("InitDateField(\'");
        String _lowerCase = this._utils.appName(it.getEntity().getApplication()).toLowerCase();
        _builder.append(_lowerCase);
        _builder.append("_");
        String _lowerCase_1 = this._formattingExtensions.formatForCode(it.getEntity().getName()).toLowerCase();
        _builder.append(_lowerCase_1);
        _builder.append("_");
        String _formatForCode = this._formattingExtensions.formatForCode(it.getName());
        _builder.append(_formatForCode);
        _builder.append("\');");
        _builder.newLineIfNotEmpty();
      }
    }
    return _builder;
  }
  
  private void entityInlineRedirectHandlerFile(final Entity it, final Application app, final IFileSystemAccess fsa) {
    String _viewPath = this._namingExtensions.getViewPath(app);
    String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(it.getName());
    String _plus = (_viewPath + _formatForCodeCapital);
    final String templatePath = (_plus + "/");
    final String templateExtension = ".html.twig";
    String fileName = ("inlineRedirectHandler" + templateExtension);
    boolean _shouldBeSkipped = this._namingExtensions.shouldBeSkipped(app, (templatePath + fileName));
    boolean _not = (!_shouldBeSkipped);
    if (_not) {
      boolean _shouldBeMarked = this._namingExtensions.shouldBeMarked(app, (templatePath + fileName));
      if (_shouldBeMarked) {
        fileName = ("inlineRedirectHandler.generated" + templateExtension);
      }
      fsa.generateFile((templatePath + fileName), this.inlineRedirectHandlerImpl(app));
    }
  }
  
  private CharSequence inlineRedirectHandlerImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{# purpose of this template: close an iframe from within this iframe #}");
    _builder.newLine();
    _builder.append("<!DOCTYPE html>");
    _builder.newLine();
    _builder.append("<html xml:lang=\"{{ app.request.locale }}\" lang=\"{{ app.request.locale }}\" dir=\"auto\">");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<head>");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<script type=\"text/javascript\" src=\"{{ asset(\'jquery/jquery.min.js\') }}\"></script>");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<script type=\"text/javascript\" src=\"{{ zasset(\'@");
    String _appName = this._utils.appName(it);
    _builder.append(_appName, "        ");
    _builder.append(":js/");
    String _appName_1 = this._utils.appName(it);
    _builder.append(_appName_1, "        ");
    _builder.append(".EditFunctions.js\') }}\"></script>");
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
    _builder.append("( function($) {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("$(document).ready(function() {");
    _builder.newLine();
    _builder.append("                    ");
    String _vendorAndName = this._utils.vendorAndName(it);
    _builder.append(_vendorAndName, "                    ");
    _builder.append("CloseWindowFromInside(\'{{ idPrefix|e(\'js\') }}\', {% if commandName == \'create\' %}{{ itemId }}{% else %}0{% endif %});");
    _builder.newLineIfNotEmpty();
    _builder.append("                ");
    _builder.append("});");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("})(jQuery);");
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
