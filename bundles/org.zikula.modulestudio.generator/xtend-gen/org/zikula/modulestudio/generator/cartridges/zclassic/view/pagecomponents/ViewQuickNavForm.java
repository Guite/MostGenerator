package org.zikula.modulestudio.generator.cartridges.zclassic.view.pagecomponents;

import de.guite.modulestudio.metamodel.BooleanField;
import de.guite.modulestudio.metamodel.DataObject;
import de.guite.modulestudio.metamodel.DerivedField;
import de.guite.modulestudio.metamodel.Entity;
import de.guite.modulestudio.metamodel.JoinRelationship;
import de.guite.modulestudio.metamodel.ListField;
import de.guite.modulestudio.metamodel.StringField;
import de.guite.modulestudio.metamodel.UserField;
import java.util.Arrays;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.InputOutput;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.eclipse.xtext.xbase.lib.StringExtensions;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class ViewQuickNavForm {
  @Extension
  private FormattingExtensions _formattingExtensions = new FormattingExtensions();
  
  @Extension
  private ModelExtensions _modelExtensions = new ModelExtensions();
  
  @Extension
  private ModelJoinExtensions _modelJoinExtensions = new ModelJoinExtensions();
  
  @Extension
  private NamingExtensions _namingExtensions = new NamingExtensions();
  
  @Extension
  private Utils _utils = new Utils();
  
  public void generate(final Entity it, final String appName, final IFileSystemAccess fsa) {
    final String templatePath = this._namingExtensions.templateFile(it, "viewQuickNav");
    boolean _shouldBeSkipped = this._namingExtensions.shouldBeSkipped(it.getApplication(), templatePath);
    boolean _not = (!_shouldBeSkipped);
    if (_not) {
      String _formatForDisplay = this._formattingExtensions.formatForDisplay(it.getName());
      String _plus = ("Generating view filter form templates for entity \"" + _formatForDisplay);
      String _plus_1 = (_plus + "\"");
      InputOutput.<String>println(_plus_1);
      fsa.generateFile(templatePath, this.quickNavForm(it));
    }
  }
  
  private CharSequence quickNavForm(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{# purpose of this template: ");
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(it.getNameMultiple());
    _builder.append(_formatForDisplay);
    _builder.append(" view filter form #}");
    _builder.newLineIfNotEmpty();
    _builder.append("{% if hasPermission(\'");
    String _appName = this._utils.appName(it.getApplication());
    _builder.append(_appName);
    _builder.append(":");
    String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital);
    _builder.append(":\', \'::\', \'ACCESS_EDIT\') %}");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("{% form_theme quickNavForm with [");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'bootstrap_3_layout.html.twig\'");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("] %}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{{ form_start(quickNavForm, {attr: {id: \'");
    String _firstLower = StringExtensions.toFirstLower(this._utils.appName(it.getApplication()));
    _builder.append(_firstLower, "    ");
    String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital_1, "    ");
    _builder.append("QuickNavForm\', class: \'");
    String _lowerCase = this._utils.appName(it.getApplication()).toLowerCase();
    _builder.append(_lowerCase, "    ");
    _builder.append("-quicknav navbar-form\', role: \'navigation\'}}) }}");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("{{ form_errors(quickNavForm) }}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<a href=\"#collapse");
    String _formatForCodeCapital_2 = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital_2, "    ");
    _builder.append("QuickNav\" role=\"button\" data-toggle=\"collapse\" class=\"btn btn-default\" aria-expanded=\"false\" aria-controls=\"collapse");
    String _formatForCodeCapital_3 = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital_3, "    ");
    _builder.append("QuickNav\">");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("<i class=\"fa fa-filter\" aria-hidden=\"true\"></i> {{ __(\'Filter\') }}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("</a>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<div id=\"collapse");
    String _formatForCodeCapital_4 = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital_4, "    ");
    _builder.append("QuickNav\" class=\"collapse\">");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("<fieldset>");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("<h3>{{ __(\'Quick navigation\') }}</h3>");
    _builder.newLine();
    _builder.append("            ");
    CharSequence _formFields = this.formFields(it);
    _builder.append(_formFields, "            ");
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    _builder.append("{{ form_widget(quickNavForm.updateview) }}");
    _builder.newLine();
    {
      boolean _isCategorisable = it.isCategorisable();
      if (_isCategorisable) {
        _builder.append("            ");
        _builder.append("{% if (categoryFilter is defined and categoryFilter != true) or not categoriesEnabled %}");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("{% else %}");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("        ");
        _builder.append("</div>");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("    ");
        _builder.append("</div>");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("{% endif %}");
        _builder.newLine();
      }
    }
    _builder.append("        ");
    _builder.append("</fieldset>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("</div>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{{ form_end(quickNavForm) }}");
    _builder.newLine();
    _builder.append("{% endif %}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence formFields(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _isCategorisable = it.isCategorisable();
      if (_isCategorisable) {
        CharSequence _categoriesFields = this.categoriesFields(it);
        _builder.append(_categoriesFields);
        _builder.newLineIfNotEmpty();
      }
    }
    final Function1<JoinRelationship, Boolean> _function = (JoinRelationship it_1) -> {
      DataObject _source = it_1.getSource();
      return Boolean.valueOf((_source instanceof Entity));
    };
    final Iterable<JoinRelationship> incomingRelations = IterableExtensions.<JoinRelationship>filter(this._modelJoinExtensions.getBidirectionalIncomingJoinRelationsWithOneSource(it), _function);
    _builder.newLineIfNotEmpty();
    {
      boolean _isEmpty = IterableExtensions.isEmpty(incomingRelations);
      boolean _not = (!_isEmpty);
      if (_not) {
        {
          for(final JoinRelationship relation : incomingRelations) {
            CharSequence _formField = this.formField(relation);
            _builder.append(_formField);
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
            CharSequence _formField_1 = this.formField(field);
            _builder.append(_formField_1);
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
            CharSequence _formField_2 = this.formField(field_1);
            _builder.append(_formField_2);
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
            CharSequence _formField_3 = this.formField(field_2);
            _builder.append(_formField_3);
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
            CharSequence _formField_4 = this.formField(field_3);
            _builder.append(_formField_4);
            _builder.newLineIfNotEmpty();
          }
        }
      }
    }
    {
      boolean _hasLocaleFieldsEntity = this._modelExtensions.hasLocaleFieldsEntity(it);
      if (_hasLocaleFieldsEntity) {
        {
          Iterable<StringField> _localeFieldsEntity = this._modelExtensions.getLocaleFieldsEntity(it);
          for(final StringField field_4 : _localeFieldsEntity) {
            CharSequence _formField_5 = this.formField(field_4);
            _builder.append(_formField_5);
            _builder.newLineIfNotEmpty();
          }
        }
      }
    }
    {
      boolean _hasAbstractStringFieldsEntity = this._modelExtensions.hasAbstractStringFieldsEntity(it);
      if (_hasAbstractStringFieldsEntity) {
        _builder.append("{% if searchFilter is defined and searchFilter != true %}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("<div class=\"hidden\">");
        _builder.newLine();
        _builder.append("{% endif %}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("{{ form_row(quickNavForm.q) }}");
        _builder.newLine();
        _builder.append("{% if searchFilter is defined and searchFilter != true %}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("</div>");
        _builder.newLine();
        _builder.append("{% endif %}");
        _builder.newLine();
      }
    }
    CharSequence _sortingAndPageSize = this.sortingAndPageSize(it);
    _builder.append(_sortingAndPageSize);
    _builder.newLineIfNotEmpty();
    {
      boolean _hasBooleanFieldsEntity = this._modelExtensions.hasBooleanFieldsEntity(it);
      if (_hasBooleanFieldsEntity) {
        {
          Iterable<BooleanField> _booleanFieldsEntity = this._modelExtensions.getBooleanFieldsEntity(it);
          for(final BooleanField field_5 : _booleanFieldsEntity) {
            CharSequence _formField_6 = this.formField(field_5);
            _builder.append(_formField_6);
            _builder.newLineIfNotEmpty();
          }
        }
      }
    }
    return _builder;
  }
  
  private CharSequence categoriesFields(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{% set categoriesEnabled = featureActivationHelper.isEnabled(constant(\'");
    String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(it.getApplication().getVendor());
    _builder.append(_formatForCodeCapital);
    _builder.append("\\\\");
    String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(it.getApplication().getName());
    _builder.append(_formatForCodeCapital_1);
    _builder.append("Module\\\\Helper\\\\FeatureActivationHelper::CATEGORIES\'), \'");
    String _formatForCode = this._formattingExtensions.formatForCode(it.getName());
    _builder.append(_formatForCode);
    _builder.append("\') %}");
    _builder.newLineIfNotEmpty();
    _builder.append("{% if (categoryFilter is defined and categoryFilter != true) or not categoriesEnabled %}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<div class=\"hidden\">");
    _builder.newLine();
    _builder.append("{% else %}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<div class=\"row\">");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<div class=\"col-sm-3\">");
    _builder.newLine();
    _builder.append("{% endif %}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{{ form_row(quickNavForm.categories) }}");
    _builder.newLine();
    _builder.append("{% if (categoryFilter is defined and categoryFilter != true) or not categoriesEnabled %}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("</div>");
    _builder.newLine();
    _builder.append("{% else %}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("</div>");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<div class=\"col-sm-9\">");
    _builder.newLine();
    _builder.append("{% endif %}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence _formField(final DerivedField it) {
    StringConcatenation _builder = new StringConcatenation();
    final String fieldName = this._formattingExtensions.formatForCode(it.getName());
    _builder.newLineIfNotEmpty();
    _builder.append("{% if ");
    _builder.append(fieldName);
    _builder.append("Filter is defined and ");
    _builder.append(fieldName);
    _builder.append("Filter != true %}");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("<div class=\"hidden\">");
    _builder.newLine();
    _builder.append("{% endif %}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{{ form_row(quickNavForm.");
    _builder.append(fieldName, "    ");
    _builder.append(") }}");
    _builder.newLineIfNotEmpty();
    _builder.append("{% if ");
    _builder.append(fieldName);
    _builder.append("Filter is defined and ");
    _builder.append(fieldName);
    _builder.append("Filter != true %}");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("</div>");
    _builder.newLine();
    _builder.append("{% endif %}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence _formField(final JoinRelationship it) {
    StringConcatenation _builder = new StringConcatenation();
    final String sourceName = this._formattingExtensions.formatForCode(it.getSource().getName());
    _builder.newLineIfNotEmpty();
    final String sourceAliasName = this._namingExtensions.getRelationAliasName(it, Boolean.valueOf(false));
    _builder.newLineIfNotEmpty();
    _builder.append("{% if ");
    _builder.append(sourceName);
    _builder.append("Filter is defined and ");
    _builder.append(sourceName);
    _builder.append("Filter != true %}");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("<div class=\"hidden\">");
    _builder.newLine();
    _builder.append("{% endif %}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{{ form_row(quickNavForm.");
    _builder.append(sourceAliasName, "    ");
    _builder.append(") }}");
    _builder.newLineIfNotEmpty();
    _builder.append("{% if ");
    _builder.append(sourceName);
    _builder.append("Filter is defined and ");
    _builder.append(sourceName);
    _builder.append("Filter != true %}");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("</div>");
    _builder.newLine();
    _builder.append("{% endif %}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence sortingAndPageSize(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{% if sorting is defined and sorting != true %}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<div class=\"hidden\">");
    _builder.newLine();
    _builder.append("{% endif %}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{{ form_row(quickNavForm.sort) }}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{{ form_row(quickNavForm.sortdir) }}");
    _builder.newLine();
    _builder.append("{% if sorting is defined and sorting != true %}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("</div>");
    _builder.newLine();
    _builder.append("{% endif %}");
    _builder.newLine();
    _builder.append("{% if pageSizeSelector is defined and pageSizeSelector != true %}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<div class=\"hidden\">");
    _builder.newLine();
    _builder.append("{% endif %}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{{ form_row(quickNavForm.num) }}");
    _builder.newLine();
    _builder.append("{% if pageSizeSelector is defined and pageSizeSelector != true %}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("</div>");
    _builder.newLine();
    _builder.append("{% endif %}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence formField(final EObject it) {
    if (it instanceof DerivedField) {
      return _formField((DerivedField)it);
    } else if (it instanceof JoinRelationship) {
      return _formField((JoinRelationship)it);
    } else {
      throw new IllegalArgumentException("Unhandled parameter types: " +
        Arrays.<Object>asList(it).toString());
    }
  }
}
