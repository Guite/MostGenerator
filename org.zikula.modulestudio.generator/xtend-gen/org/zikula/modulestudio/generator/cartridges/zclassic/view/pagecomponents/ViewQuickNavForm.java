package org.zikula.modulestudio.generator.cartridges.zclassic.view.pagecomponents;

import com.google.common.base.Objects;
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
import org.eclipse.emf.ecore.EObject;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.eclipse.xtext.xbase.lib.InputOutput;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.zikula.modulestudio.generator.extensions.ControllerExtensions;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class ViewQuickNavForm {
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
  
  public void generate(final Entity it, final String appName, final Controller controller, final IFileSystemAccess fsa) {
    String _formattedName = this._controllerExtensions.formattedName(controller);
    String _plus = ("Generating " + _formattedName);
    String _plus_1 = (_plus + " view filter form templates for entity \"");
    String _name = it.getName();
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(_name);
    String _plus_2 = (_plus_1 + _formatForDisplay);
    String _plus_3 = (_plus_2 + "\"");
    InputOutput.<String>println(_plus_3);
    String _name_1 = it.getName();
    String _templateFile = this._namingExtensions.templateFile(controller, _name_1, "view_quickNav");
    CharSequence _quickNavForm = this.quickNavForm(it, controller);
    fsa.generateFile(_templateFile, _quickNavForm);
  }
  
  private CharSequence quickNavForm(final Entity it, final Controller controller) {
    StringConcatenation _builder = new StringConcatenation();
    Models _container = it.getContainer();
    final Application app = _container.getApplication();
    _builder.newLineIfNotEmpty();
    String _name = it.getName();
    final String objName = this._formattingExtensions.formatForCode(_name);
    _builder.newLineIfNotEmpty();
    _builder.append("{* purpose of this template: ");
    String _nameMultiple = it.getNameMultiple();
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(_nameMultiple);
    _builder.append(_formatForDisplay, "");
    _builder.append(" view filter form in ");
    String _formattedName = this._controllerExtensions.formattedName(controller);
    _builder.append(_formattedName, "");
    _builder.append(" area *}");
    _builder.newLineIfNotEmpty();
    _builder.append("{checkpermissionblock component=\'");
    String _appName = this._utils.appName(app);
    _builder.append(_appName, "");
    _builder.append(":");
    String _name_1 = it.getName();
    String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(_name_1);
    _builder.append(_formatForCodeCapital, "");
    _builder.append(":\' instance=\'::\' level=\'ACCESS_EDIT\'}");
    _builder.newLineIfNotEmpty();
    _builder.append("{assign var=\'objectType\' value=\'");
    String _name_2 = it.getName();
    String _formatForCode = this._formattingExtensions.formatForCode(_name_2);
    _builder.append(_formatForCode, "");
    _builder.append("\'}");
    _builder.newLineIfNotEmpty();
    _builder.append("<form action=\"{$modvars.ZConfig.entrypoint|default:\'index.php\'}\" method=\"get\" id=\"");
    String _prefix = app.getPrefix();
    _builder.append(_prefix, "");
    String _name_3 = it.getName();
    String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(_name_3);
    _builder.append(_formatForCodeCapital_1, "");
    _builder.append("QuickNavForm\" class=\"");
    String _prefix_1 = app.getPrefix();
    _builder.append(_prefix_1, "");
    _builder.append("QuickNavForm\">");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("<fieldset>");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<h3>{gt text=\'Quick navigation\'}</h3>");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<input type=\"hidden\" name=\"module\" value=\"{modgetinfo modname=\'");
    String _appName_1 = this._utils.appName(app);
    _builder.append(_appName_1, "        ");
    _builder.append("\' info=\'url\'}\" />");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("<input type=\"hidden\" name=\"type\" value=\"");
    String _formattedName_1 = this._controllerExtensions.formattedName(controller);
    _builder.append(_formattedName_1, "        ");
    _builder.append("\" />");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("<input type=\"hidden\" name=\"func\" value=\"view\" />");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<input type=\"hidden\" name=\"ot\" value=\"");
    _builder.append(objName, "        ");
    _builder.append("\" />");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("{gt text=\'All\' assign=\'lblDefault\'}");
    _builder.newLine();
    _builder.append("        ");
    CharSequence _formFields = this.formFields(it);
    _builder.append(_formFields, "        ");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("<input type=\"submit\" name=\"updateview\" id=\"quicknav_submit\" value=\"{gt text=\'OK\'}\" />");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("</fieldset>");
    _builder.newLine();
    _builder.append("</form>");
    _builder.newLine();
    _builder.newLine();
    _builder.append("<script type=\"text/javascript\">");
    _builder.newLine();
    _builder.append("/* <![CDATA[ */");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("document.observe(\'dom:loaded\', function() {");
    _builder.newLine();
    _builder.append("        ");
    String _prefix_2 = app.getPrefix();
    _builder.append(_prefix_2, "        ");
    _builder.append("InitQuickNavigation(\'");
    String _name_4 = it.getName();
    String _formatForCode_1 = this._formattingExtensions.formatForCode(_name_4);
    _builder.append(_formatForCode_1, "        ");
    _builder.append("\', \'");
    String _formattedName_2 = this._controllerExtensions.formattedName(controller);
    _builder.append(_formattedName_2, "        ");
    _builder.append("\');");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("{{if isset($searchFilter) && $searchFilter eq false}}");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("{{* we can hide the submit button if we have no quick search field *}}");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$(\'quicknav_submit\').addClassName(\'z-hide\');");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("{{/if}}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("});");
    _builder.newLine();
    _builder.append("/* ]]> */");
    _builder.newLine();
    _builder.append("</script>");
    _builder.newLine();
    _builder.append("{/checkpermissionblock}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence formFields(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _categoriesFields = this.categoriesFields(it);
    _builder.append(_categoriesFields, "");
    _builder.newLineIfNotEmpty();
    final Iterable<JoinRelationship> incomingRelations = this._modelJoinExtensions.getBidirectionalIncomingJoinRelationsWithOneSource(it);
    _builder.newLineIfNotEmpty();
    {
      boolean _isEmpty = IterableExtensions.isEmpty(incomingRelations);
      boolean _not = (!_isEmpty);
      if (_not) {
        {
          for(final JoinRelationship relation : incomingRelations) {
            CharSequence _formField = this.formField(relation);
            _builder.append(_formField, "");
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
            _builder.append(_formField_1, "");
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
            _builder.append(_formField_2, "");
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
            _builder.append(_formField_3, "");
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
            _builder.append(_formField_4, "");
            _builder.newLineIfNotEmpty();
          }
        }
      }
    }
    {
      boolean _hasAbstractStringFieldsEntity = this._modelExtensions.hasAbstractStringFieldsEntity(it);
      if (_hasAbstractStringFieldsEntity) {
        _builder.append("{if !isset($searchFilter) || $searchFilter eq true}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("<label for=\"searchterm\">{gt text=\'Search\'}:</label>");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("<input type=\"text\" id=\"searchterm\" name=\"searchterm\" value=\"{$searchterm}\" />");
        _builder.newLine();
        _builder.append("{/if}");
        _builder.newLine();
      }
    }
    CharSequence _sortingAndPageSize = this.sortingAndPageSize(it);
    _builder.append(_sortingAndPageSize, "");
    _builder.newLineIfNotEmpty();
    {
      boolean _hasBooleanFieldsEntity = this._modelExtensions.hasBooleanFieldsEntity(it);
      if (_hasBooleanFieldsEntity) {
        {
          Iterable<BooleanField> _booleanFieldsEntity = this._modelExtensions.getBooleanFieldsEntity(it);
          for(final BooleanField field_4 : _booleanFieldsEntity) {
            CharSequence _formField_5 = this.formField(field_4);
            _builder.append(_formField_5, "");
            _builder.newLineIfNotEmpty();
          }
        }
      }
    }
    return _builder;
  }
  
  private CharSequence categoriesFields(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _isCategorisable = it.isCategorisable();
      if (_isCategorisable) {
        _builder.append("{if !isset($categoryFilter) || $categoryFilter eq true}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("{modapifunc modname=\'");
        Models _container = it.getContainer();
        Application _application = _container.getApplication();
        String _appName = this._utils.appName(_application);
        _builder.append(_appName, "    ");
        _builder.append("\' type=\'category\' func=\'getAllProperties\' ot=$objectType assign=\'properties\'}");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("{if $properties ne null && is_array($properties)}");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("{gt text=\'All\' assign=\'lblDefault\'}");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("{nocache}");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("{foreach key=\'propertyName\' item=\'propertyId\' from=$properties}");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("{modapifunc modname=\'");
        Models _container_1 = it.getContainer();
        Application _application_1 = _container_1.getApplication();
        String _appName_1 = this._utils.appName(_application_1);
        _builder.append(_appName_1, "            ");
        _builder.append("\' type=\'category\' func=\'hasMultipleSelection\' ot=$objectType registry=$propertyName assign=\'hasMultiSelection\'}");
        _builder.newLineIfNotEmpty();
        _builder.append("            ");
        _builder.append("{gt text=\'Category\' assign=\'categoryLabel\'}");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("{assign var=\'categorySelectorId\' value=\'catid\'}");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("{assign var=\'categorySelectorName\' value=\'catid\'}");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("{assign var=\'categorySelectorSize\' value=\'1\'}");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("{if $hasMultiSelection eq true}");
        _builder.newLine();
        _builder.append("                ");
        _builder.append("{gt text=\'Categories\' assign=\'categoryLabel\'}");
        _builder.newLine();
        _builder.append("                ");
        _builder.append("{assign var=\'categorySelectorName\' value=\'catids\'}");
        _builder.newLine();
        _builder.append("                ");
        _builder.append("{assign var=\'categorySelectorId\' value=\'catids__\'}");
        _builder.newLine();
        _builder.append("                ");
        _builder.append("{assign var=\'categorySelectorSize\' value=\'5\'}");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("{/if}");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("<label for=\"{$categorySelectorId}{$propertyName}\">{$categoryLabel}</label>");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("&nbsp;");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("{selector_category name=\"`$categorySelectorName``$propertyName`\" field=\'id\' selectedValue=$catIdList.$propertyName categoryRegistryModule=\'");
        Models _container_2 = it.getContainer();
        Application _application_2 = _container_2.getApplication();
        String _appName_2 = this._utils.appName(_application_2);
        _builder.append(_appName_2, "            ");
        _builder.append("\' categoryRegistryTable=$objectType categoryRegistryProperty=$propertyName defaultText=$lblDefault editLink=false multipleSize=$categorySelectorSize}");
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        _builder.append("{/foreach}");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("{/nocache}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("{/if}");
        _builder.newLine();
        _builder.append("{/if}");
        _builder.newLine();
      }
    }
    return _builder;
  }
  
  private CharSequence _formField(final DerivedField it) {
    StringConcatenation _builder = new StringConcatenation();
    String _name = it.getName();
    final String fieldName = this._formattingExtensions.formatForCode(_name);
    _builder.newLineIfNotEmpty();
    _builder.append("{if !isset($");
    _builder.append(fieldName, "");
    _builder.append("Filter) || $");
    _builder.append(fieldName, "");
    _builder.append("Filter eq true}");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    CharSequence _formFieldImpl = this.formFieldImpl(it);
    _builder.append(_formFieldImpl, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("{/if}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence _formFieldImpl(final BooleanField it) {
    StringConcatenation _builder = new StringConcatenation();
    String _name = it.getName();
    final String fieldName = this._formattingExtensions.formatForCode(_name);
    _builder.newLineIfNotEmpty();
    String _xifexpression = null;
    String _name_1 = it.getName();
    boolean _equals = Objects.equal(_name_1, "workflowState");
    if (_equals) {
      _xifexpression = "state";
    } else {
      String _name_2 = it.getName();
      _xifexpression = _name_2;
    }
    final String fieldLabel = _xifexpression;
    _builder.newLineIfNotEmpty();
    _builder.append("<label for=\"");
    _builder.append(fieldName, "");
    _builder.append("\">{gt text=\'");
    String _formatForDisplayCapital = this._formattingExtensions.formatForDisplayCapital(fieldLabel);
    _builder.append(_formatForDisplayCapital, "");
    _builder.append("\'}</label>");
    _builder.newLineIfNotEmpty();
    _builder.append("<select id=\"");
    _builder.append(fieldName, "");
    _builder.append("\" name=\"");
    _builder.append(fieldName, "");
    _builder.append("\">");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("<option value=\"\">{$lblDefault}</option>");
    _builder.newLine();
    _builder.append("{foreach item=\'option\' from=$");
    _builder.append(fieldName, "");
    _builder.append("Items}");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("<option value=\"{$option.value}\"{if $option.value eq $");
    _builder.append(fieldName, "    ");
    _builder.append("} selected=\"selected\"{/if}>{$option.text|safetext}</option>");
    _builder.newLineIfNotEmpty();
    _builder.append("{/foreach}");
    _builder.newLine();
    _builder.append("</select>");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence _formFieldImpl(final StringField it) {
    StringConcatenation _builder = new StringConcatenation();
    String _name = it.getName();
    final String fieldName = this._formattingExtensions.formatForCode(_name);
    _builder.newLineIfNotEmpty();
    _builder.append("<label for=\"");
    _builder.append(fieldName, "");
    _builder.append("\">{gt text=\'");
    String _name_1 = it.getName();
    String _formatForDisplayCapital = this._formattingExtensions.formatForDisplayCapital(_name_1);
    _builder.append(_formatForDisplayCapital, "");
    _builder.append("\'}</label>");
    _builder.newLineIfNotEmpty();
    {
      boolean _isCountry = it.isCountry();
      if (_isCountry) {
        _builder.append("{selector_countries name=\'");
        _builder.append(fieldName, "");
        _builder.append("\' selectedValue=$");
        _builder.append(fieldName, "");
        _builder.append(" defaultText=$lblDefault}");
        _builder.newLineIfNotEmpty();
      } else {
        boolean _isLanguage = it.isLanguage();
        if (_isLanguage) {
          _builder.append("{html_select_locales name=\'");
          _builder.append(fieldName, "");
          _builder.append("\' selected=$");
          _builder.append(fieldName, "");
          _builder.append("}");
          _builder.newLineIfNotEmpty();
        }
      }
    }
    return _builder;
  }
  
  private CharSequence _formFieldImpl(final UserField it) {
    StringConcatenation _builder = new StringConcatenation();
    String _name = it.getName();
    final String fieldName = this._formattingExtensions.formatForCode(_name);
    _builder.newLineIfNotEmpty();
    _builder.append("<label for=\"");
    _builder.append(fieldName, "");
    _builder.append("\">{gt text=\'");
    String _name_1 = it.getName();
    String _formatForDisplayCapital = this._formattingExtensions.formatForDisplayCapital(_name_1);
    _builder.append(_formatForDisplayCapital, "");
    _builder.append("\'}</label>");
    _builder.newLineIfNotEmpty();
    _builder.append("{selector_user name=\'");
    _builder.append(fieldName, "");
    _builder.append("\' selectedValue=$");
    _builder.append(fieldName, "");
    _builder.append(" defaultText=$lblDefault}");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence _formFieldImpl(final ListField it) {
    StringConcatenation _builder = new StringConcatenation();
    String _name = it.getName();
    final String fieldName = this._formattingExtensions.formatForCode(_name);
    _builder.newLineIfNotEmpty();
    _builder.append("<label for=\"");
    _builder.append(fieldName, "");
    _builder.append("\">{gt text=\'");
    String _name_1 = it.getName();
    String _formatForDisplayCapital = this._formattingExtensions.formatForDisplayCapital(_name_1);
    _builder.append(_formatForDisplayCapital, "");
    _builder.append("\'}</label>");
    _builder.newLineIfNotEmpty();
    _builder.append("<select id=\"");
    _builder.append(fieldName, "");
    _builder.append("\" name=\"");
    _builder.append(fieldName, "");
    _builder.append("\">");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("<option value=\"\">{$lblDefault}</option>");
    _builder.newLine();
    _builder.append("{foreach item=\'option\' from=$");
    _builder.append(fieldName, "");
    _builder.append("Items}");
    _builder.newLineIfNotEmpty();
    {
      boolean _isMultiple = it.isMultiple();
      if (_isMultiple) {
        _builder.append("<option value=\"%{$option.value}\"{if $option.title ne \'\'} title=\"{$option.title|safetext}\"{/if}{if \"%`$option.value`\" eq $formats} selected=\"selected\"{/if}>{$option.text|safetext}</option>");
        _builder.newLine();
      } else {
        _builder.append("<option value=\"{$option.value}\"{if $option.title ne \'\'} title=\"{$option.title|safetext}\"{/if}{if $option.value eq $");
        _builder.append(fieldName, "");
        _builder.append("} selected=\"selected\"{/if}>{$option.text|safetext}</option>");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("{/foreach}");
    _builder.newLine();
    _builder.append("</select>");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence _formField(final JoinRelationship it) {
    StringConcatenation _builder = new StringConcatenation();
    Entity _source = it.getSource();
    String _name = _source.getName();
    final String sourceName = this._formattingExtensions.formatForCode(_name);
    _builder.newLineIfNotEmpty();
    final String sourceAliasName = this._namingExtensions.getRelationAliasName(it, Boolean.valueOf(false));
    _builder.newLineIfNotEmpty();
    _builder.append("{if !isset($");
    _builder.append(sourceName, "");
    _builder.append("Filter) || $");
    _builder.append(sourceName, "");
    _builder.append("Filter eq true}");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("<label for=\"");
    _builder.append(sourceAliasName, "    ");
    _builder.append("\">{gt text=\'");
    Entity _source_1 = it.getSource();
    String _nameMultiple = _source_1.getNameMultiple();
    String _formatForDisplayCapital = this._formattingExtensions.formatForDisplayCapital(_nameMultiple);
    _builder.append(_formatForDisplayCapital, "    ");
    _builder.append("\'}</label>");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("{modapifunc modname=\'");
    Entity _source_2 = it.getSource();
    Models _container = _source_2.getContainer();
    Application _application = _container.getApplication();
    String _appName = this._utils.appName(_application);
    _builder.append(_appName, "    ");
    _builder.append("\' type=\'selection\' func=\'getEntities\' ot=\'");
    Entity _source_3 = it.getSource();
    String _name_1 = _source_3.getName();
    String _formatForCode = this._formattingExtensions.formatForCode(_name_1);
    _builder.append(_formatForCode, "    ");
    _builder.append("\'");
    {
      Entity _source_4 = it.getSource();
      DerivedField _leadingField = this._modelExtensions.getLeadingField(_source_4);
      boolean _tripleNotEquals = (_leadingField != null);
      if (_tripleNotEquals) {
        _builder.append(" orderBy=\'tbl.");
        Entity _source_5 = it.getSource();
        DerivedField _leadingField_1 = this._modelExtensions.getLeadingField(_source_5);
        String _name_2 = _leadingField_1.getName();
        String _formatForCode_1 = this._formattingExtensions.formatForCode(_name_2);
        _builder.append(_formatForCode_1, "    ");
        _builder.append("\'");
      }
    }
    _builder.append(" slimMode=true assign=\'listEntries\'}");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("<select id=\"");
    _builder.append(sourceAliasName, "    ");
    _builder.append("\" name=\"");
    _builder.append(sourceAliasName, "    ");
    _builder.append("\">");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("<option value=\"\">{$lblDefault}</option>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{foreach item=\'option\' from=$listEntries}");
    _builder.newLine();
    {
      Entity _source_6 = it.getSource();
      boolean _hasCompositeKeys = this._modelExtensions.hasCompositeKeys(_source_6);
      if (_hasCompositeKeys) {
        _builder.append("        ");
        _builder.append("{assign var=\'entryId\' value=\"");
        {
          Entity _source_7 = it.getSource();
          Iterable<DerivedField> _primaryKeyFields = this._modelExtensions.getPrimaryKeyFields(_source_7);
          boolean _hasElements = false;
          for(final DerivedField pkField : _primaryKeyFields) {
            if (!_hasElements) {
              _hasElements = true;
            } else {
              _builder.appendImmediate("_", "        ");
            }
            _builder.append("`$option.");
            String _name_3 = pkField.getName();
            String _formatForCode_2 = this._formattingExtensions.formatForCode(_name_3);
            _builder.append(_formatForCode_2, "        ");
            _builder.append("`");
          }
        }
        _builder.append("\"}");
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        _builder.append("<option value=\"{$entryId}\"{if $entryId eq $");
        _builder.append(sourceAliasName, "        ");
        _builder.append("} selected=\"selected\"{/if}>{$option.");
        Entity _source_8 = it.getSource();
        DerivedField _leadingField_2 = this._modelExtensions.getLeadingField(_source_8);
        String _name_4 = _leadingField_2.getName();
        String _formatForCode_3 = this._formattingExtensions.formatForCode(_name_4);
        _builder.append(_formatForCode_3, "        ");
        _builder.append("}</option>");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("        ");
        _builder.append("{assign var=\'entryId\' value=$option.");
        Entity _source_9 = it.getSource();
        DerivedField _firstPrimaryKey = this._modelExtensions.getFirstPrimaryKey(_source_9);
        String _name_5 = _firstPrimaryKey.getName();
        String _formatForCode_4 = this._formattingExtensions.formatForCode(_name_5);
        _builder.append(_formatForCode_4, "        ");
        _builder.append("}");
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        _builder.append("<option value=\"{$entryId}\"{if $entryId eq $");
        _builder.append(sourceAliasName, "        ");
        _builder.append("} selected=\"selected\"{/if}>{$option.");
        Entity _source_10 = it.getSource();
        DerivedField _leadingField_3 = this._modelExtensions.getLeadingField(_source_10);
        String _name_6 = _leadingField_3.getName();
        String _formatForCode_5 = this._formattingExtensions.formatForCode(_name_6);
        _builder.append(_formatForCode_5, "        ");
        _builder.append("}</option>");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("    ");
    _builder.append("{/foreach}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("</select>");
    _builder.newLine();
    _builder.append("{/if}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence sortingAndPageSize(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{if !isset($sorting) || $sorting eq true}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<label for=\"sortby\">{gt text=\'Sort by\'}</label>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("&nbsp;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<select id=\"sortby\" name=\"sort\">");
    _builder.newLine();
    {
      Iterable<DerivedField> _derivedFields = this._modelExtensions.getDerivedFields(it);
      for(final DerivedField field : _derivedFields) {
        _builder.append("    ");
        _builder.append("<option value=\"");
        String _name = field.getName();
        String _formatForCode = this._formattingExtensions.formatForCode(_name);
        _builder.append(_formatForCode, "    ");
        _builder.append("\"{if $sort eq \'");
        String _name_1 = field.getName();
        String _formatForCode_1 = this._formattingExtensions.formatForCode(_name_1);
        _builder.append(_formatForCode_1, "    ");
        _builder.append("\'} selected=\"selected\"{/if}>{gt text=\'");
        String _name_2 = field.getName();
        String _formatForDisplayCapital = this._formattingExtensions.formatForDisplayCapital(_name_2);
        _builder.append(_formatForDisplayCapital, "    ");
        _builder.append("\'}</option>");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      boolean _isStandardFields = it.isStandardFields();
      if (_isStandardFields) {
        _builder.append("    ");
        _builder.append("<option value=\"createdDate\"{if $sort eq \'createdDate\'} selected=\"selected\"{/if}>{gt text=\'Creation date\'}</option>");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("<option value=\"createdUserId\"{if $sort eq \'createdUserId\'} selected=\"selected\"{/if}>{gt text=\'Creator\'}</option>");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("<option value=\"updatedDate\"{if $sort eq \'updatedDate\'} selected=\"selected\"{/if}>{gt text=\'Update date\'}</option>");
        _builder.newLine();
      }
    }
    _builder.append("    ");
    _builder.append("</select>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<select id=\"sortdir\" name=\"sortdir\">");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<option value=\"asc\"{if $sdir eq \'asc\'} selected=\"selected\"{/if}>{gt text=\'ascending\'}</option>");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<option value=\"desc\"{if $sdir eq \'desc\'} selected=\"selected\"{/if}>{gt text=\'descending\'}</option>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("</select>");
    _builder.newLine();
    _builder.append("{else}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<input type=\"hidden\" name=\"sort\" value=\"{$sort}\" />");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<input type=\"hidden\" name=\"sdir\" value=\"{if $sdir eq \'desc\'}asc{else}desc{/if}\" />");
    _builder.newLine();
    _builder.append("{/if}");
    _builder.newLine();
    _builder.append("{if !isset($pageSizeSelector) || $pageSizeSelector eq true}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<label for=\"num\">{gt text=\'Page size\'}</label>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("&nbsp;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<select id=\"num\" name=\"num\">");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<option value=\"5\"{if $pageSize eq 5} selected=\"selected\"{/if}>5</option>");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<option value=\"10\"{if $pageSize eq 10} selected=\"selected\"{/if}>10</option>");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<option value=\"15\"{if $pageSize eq 15} selected=\"selected\"{/if}>15</option>");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<option value=\"20\"{if $pageSize eq 20} selected=\"selected\"{/if}>20</option>");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<option value=\"30\"{if $pageSize eq 30} selected=\"selected\"{/if}>30</option>");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<option value=\"50\"{if $pageSize eq 50} selected=\"selected\"{/if}>50</option>");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<option value=\"100\"{if $pageSize eq 100} selected=\"selected\"{/if}>100</option>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("</select>");
    _builder.newLine();
    _builder.append("{/if}");
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
  
  private CharSequence formFieldImpl(final DerivedField it) {
    if (it instanceof ListField) {
      return _formFieldImpl((ListField)it);
    } else if (it instanceof StringField) {
      return _formFieldImpl((StringField)it);
    } else if (it instanceof UserField) {
      return _formFieldImpl((UserField)it);
    } else if (it instanceof BooleanField) {
      return _formFieldImpl((BooleanField)it);
    } else {
      throw new IllegalArgumentException("Unhandled parameter types: " +
        Arrays.<Object>asList(it).toString());
    }
  }
}
