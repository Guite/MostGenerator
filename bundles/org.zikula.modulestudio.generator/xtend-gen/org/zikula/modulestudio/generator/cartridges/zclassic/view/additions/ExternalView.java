package org.zikula.modulestudio.generator.cartridges.zclassic.view.additions;

import de.guite.modulestudio.metamodel.Application;
import de.guite.modulestudio.metamodel.Entity;
import de.guite.modulestudio.metamodel.EntityField;
import de.guite.modulestudio.metamodel.StringField;
import de.guite.modulestudio.metamodel.TextField;
import de.guite.modulestudio.metamodel.UploadField;
import java.util.List;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.eclipse.xtext.xbase.lib.StringExtensions;
import org.zikula.modulestudio.generator.cartridges.zclassic.view.pagecomponents.SimpleFields;
import org.zikula.modulestudio.generator.extensions.ControllerExtensions;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.UrlExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class ExternalView {
  @Extension
  private ControllerExtensions _controllerExtensions = new ControllerExtensions();
  
  @Extension
  private FormattingExtensions _formattingExtensions = new FormattingExtensions();
  
  @Extension
  private ModelExtensions _modelExtensions = new ModelExtensions();
  
  @Extension
  private NamingExtensions _namingExtensions = new NamingExtensions();
  
  @Extension
  private UrlExtensions _urlExtensions = new UrlExtensions();
  
  @Extension
  private Utils _utils = new Utils();
  
  private SimpleFields fieldHelper = new SimpleFields();
  
  public void generate(final Application it, final IFileSystemAccess fsa) {
    String fileName = "";
    final String templateExtension = ".html.twig";
    final Function1<Entity, Boolean> _function = (Entity it_1) -> {
      return Boolean.valueOf(this._controllerExtensions.hasDisplayAction(it_1));
    };
    Iterable<Entity> _filter = IterableExtensions.<Entity>filter(this._modelExtensions.getAllEntities(it), _function);
    for (final Entity entity : _filter) {
      {
        String _viewPath = this._namingExtensions.getViewPath(it);
        String _plus = (_viewPath + "External/");
        String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(entity.getName());
        String _plus_1 = (_plus + _formatForCodeCapital);
        final String templatePath = (_plus_1 + "/");
        fileName = ("display" + templateExtension);
        boolean _shouldBeSkipped = this._namingExtensions.shouldBeSkipped(it, (templatePath + fileName));
        boolean _not = (!_shouldBeSkipped);
        if (_not) {
          boolean _shouldBeMarked = this._namingExtensions.shouldBeMarked(it, (templatePath + fileName));
          if (_shouldBeMarked) {
            fileName = ("display.generated" + templateExtension);
          }
          fsa.generateFile((templatePath + fileName), this.displayTemplate(entity, it));
        }
        fileName = ("info" + templateExtension);
        boolean _shouldBeSkipped_1 = this._namingExtensions.shouldBeSkipped(it, (templatePath + fileName));
        boolean _not_1 = (!_shouldBeSkipped_1);
        if (_not_1) {
          boolean _shouldBeMarked_1 = this._namingExtensions.shouldBeMarked(it, (templatePath + fileName));
          if (_shouldBeMarked_1) {
            fileName = ("info.generated" + templateExtension);
          }
          fsa.generateFile((templatePath + fileName), this.itemInfoTemplate(entity, it));
        }
        fileName = ("find" + templateExtension);
        boolean _shouldBeSkipped_2 = this._namingExtensions.shouldBeSkipped(it, (templatePath + fileName));
        boolean _not_2 = (!_shouldBeSkipped_2);
        if (_not_2) {
          boolean _shouldBeMarked_2 = this._namingExtensions.shouldBeMarked(it, (templatePath + fileName));
          if (_shouldBeMarked_2) {
            fileName = ("find.generated" + templateExtension);
          }
          fsa.generateFile((templatePath + fileName), this.findTemplate(entity, it));
        }
        fileName = "select.tpl";
        boolean _shouldBeSkipped_3 = this._namingExtensions.shouldBeSkipped(it, (templatePath + fileName));
        boolean _not_3 = (!_shouldBeSkipped_3);
        if (_not_3) {
          boolean _shouldBeMarked_3 = this._namingExtensions.shouldBeMarked(it, (templatePath + fileName));
          if (_shouldBeMarked_3) {
            fileName = "select.generated.tpl";
          }
          fsa.generateFile((templatePath + fileName), this.selectTemplate(entity, it));
        }
      }
    }
  }
  
  private CharSequence displayTemplate(final Entity it, final Application app) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{# Purpose of this template: Display one certain ");
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(it.getName());
    _builder.append(_formatForDisplay);
    _builder.append(" within an external context #}");
    _builder.newLineIfNotEmpty();
    {
      boolean _hasImageFieldsEntity = this._modelExtensions.hasImageFieldsEntity(it);
      if (_hasImageFieldsEntity) {
        _builder.append("{{ pageAddAsset(\'javascript\', asset(\'magnific-popup/jquery.magnific-popup.min.js\')) }}");
        _builder.newLine();
        _builder.append("{{ pageAddAsset(\'stylesheet\', asset(\'magnific-popup/magnific-popup.css\')) }}");
        _builder.newLine();
        _builder.append("{{ pageAddAsset(\'javascript\', zasset(\'@");
        String _appName = this._utils.appName(app);
        _builder.append(_appName);
        _builder.append(":js/");
        String _appName_1 = this._utils.appName(app);
        _builder.append(_appName_1);
        _builder.append(".js\')) }}");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("<div id=\"");
    String _formatForCode = this._formattingExtensions.formatForCode(it.getName());
    _builder.append(_formatForCode);
    _builder.append("{$");
    String _formatForCode_1 = this._formattingExtensions.formatForCode(it.getName());
    _builder.append(_formatForCode_1);
    _builder.append(".");
    String _formatForCode_2 = this._formattingExtensions.formatForCode(this._modelExtensions.getFirstPrimaryKey(it).getName());
    _builder.append(_formatForCode_2);
    _builder.append("}\" class=\"");
    String _lowerCase = this._utils.appName(app).toLowerCase();
    _builder.append(_lowerCase);
    _builder.append("-external-");
    String _formatForDB = this._formattingExtensions.formatForDB(it.getName());
    _builder.append(_formatForDB);
    _builder.append("\">");
    _builder.newLineIfNotEmpty();
    _builder.append("{% if displayMode == \'link\' %}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<p");
    {
      boolean _hasDisplayAction = this._controllerExtensions.hasDisplayAction(it);
      if (_hasDisplayAction) {
        _builder.append(" class=\"");
        String _lowerCase_1 = this._utils.appName(app).toLowerCase();
        _builder.append(_lowerCase_1, "    ");
        _builder.append("-external-link\"");
      }
    }
    _builder.append(">");
    _builder.newLineIfNotEmpty();
    {
      boolean _hasDisplayAction_1 = this._controllerExtensions.hasDisplayAction(it);
      if (_hasDisplayAction_1) {
        _builder.append("    ");
        _builder.append("<a href=\"{{ path(\'");
        String _formatForDB_1 = this._formattingExtensions.formatForDB(this._utils.appName(app));
        _builder.append(_formatForDB_1, "    ");
        _builder.append("_");
        String _formatForDB_2 = this._formattingExtensions.formatForDB(it.getName());
        _builder.append(_formatForDB_2, "    ");
        _builder.append("_display\'");
        CharSequence _routeParams = this._urlExtensions.routeParams(it, this._formattingExtensions.formatForCode(it.getName()), Boolean.valueOf(true));
        _builder.append(_routeParams, "    ");
        _builder.append(") }}\" title=\"{{ ");
        String _formatForCode_3 = this._formattingExtensions.formatForCode(it.getName());
        _builder.append(_formatForCode_3, "    ");
        _builder.append(".getTitleFromDisplayPattern()|e(\'html_attr\') }}\">");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("    ");
    _builder.append("{{ ");
    String _formatForCode_4 = this._formattingExtensions.formatForCode(it.getName());
    _builder.append(_formatForCode_4, "    ");
    _builder.append(".getTitleFromDisplayPattern()");
    {
      boolean _isSkipHookSubscribers = it.isSkipHookSubscribers();
      boolean _not = (!_isSkipHookSubscribers);
      if (_not) {
        _builder.append("|notifyFilters(\'");
        String _formatForDB_3 = this._formattingExtensions.formatForDB(app.getName());
        _builder.append(_formatForDB_3, "    ");
        _builder.append(".filter_hooks.");
        String _formatForDB_4 = this._formattingExtensions.formatForDB(it.getNameMultiple());
        _builder.append(_formatForDB_4, "    ");
        _builder.append(".filter\')");
      }
    }
    _builder.append(" }}");
    _builder.newLineIfNotEmpty();
    {
      boolean _hasDisplayAction_2 = this._controllerExtensions.hasDisplayAction(it);
      if (_hasDisplayAction_2) {
        _builder.append("    ");
        _builder.append("</a>");
        _builder.newLine();
      }
    }
    _builder.append("    ");
    _builder.append("</p>");
    _builder.newLine();
    _builder.append("{% endif %}");
    _builder.newLine();
    _builder.append("{% if hasPermission(\'");
    String _appName_2 = this._utils.appName(app);
    _builder.append(_appName_2);
    _builder.append("::\', \'::\', \'ACCESS_EDIT\') %}");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("{# for normal users without edit permission show only the actual file per default #}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{% if displayMode == \'embed\' %}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<p class=\"");
    String _lowerCase_2 = this._utils.appName(app).toLowerCase();
    _builder.append(_lowerCase_2, "        ");
    _builder.append("-external-title\">");
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    _builder.append("<strong>{{ ");
    String _formatForCode_5 = this._formattingExtensions.formatForCode(it.getName());
    _builder.append(_formatForCode_5, "            ");
    _builder.append(".getTitleFromDisplayPattern()");
    {
      boolean _isSkipHookSubscribers_1 = it.isSkipHookSubscribers();
      boolean _not_1 = (!_isSkipHookSubscribers_1);
      if (_not_1) {
        _builder.append("|notifyFilters(\'");
        String _formatForDB_5 = this._formattingExtensions.formatForDB(app.getName());
        _builder.append(_formatForDB_5, "            ");
        _builder.append(".filter_hooks.");
        String _formatForDB_6 = this._formattingExtensions.formatForDB(it.getNameMultiple());
        _builder.append(_formatForDB_6, "            ");
        _builder.append(".filter\')");
      }
    }
    _builder.append(" }}</strong>");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("</p>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{% endif %}");
    _builder.newLine();
    _builder.append("{% endif %}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("{% if displayMode == \'link\' %}");
    _builder.newLine();
    _builder.append("{% elseif displayMode == \'embed\' %}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<div class=\"");
    String _lowerCase_3 = this._utils.appName(app).toLowerCase();
    _builder.append(_lowerCase_3, "    ");
    _builder.append("-external-snippet\">");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    CharSequence _displaySnippet = this.displaySnippet(it);
    _builder.append(_displaySnippet, "        ");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("</div>");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{# you can distinguish the context like this: #}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{# % if source == \'contentType\' %}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("...");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{% elseif source == \'scribite\' %}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("...");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{% endif % #}");
    _builder.newLine();
    {
      if ((this._modelExtensions.hasAbstractStringFieldsEntity(it) || it.isCategorisable())) {
        _builder.newLine();
        _builder.append("    ");
        _builder.append("{# you can enable more details about the item: #}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("{#");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("<p class=\"");
        String _lowerCase_4 = this._utils.appName(app).toLowerCase();
        _builder.append(_lowerCase_4, "        ");
        _builder.append("-external-description\">");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("        ");
        CharSequence _displayDescription = this.displayDescription(it, "", "<br />");
        _builder.append(_displayDescription, "            ");
        _builder.newLineIfNotEmpty();
        {
          boolean _isCategorisable = it.isCategorisable();
          if (_isCategorisable) {
            _builder.append("    ");
            _builder.append("        ");
            _builder.append("{% if featureActivationHelper.isEnabled(constant(\'");
            String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(app.getVendor());
            _builder.append(_formatForCodeCapital, "            ");
            _builder.append("\\\\");
            String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(app.getName());
            _builder.append(_formatForCodeCapital_1, "            ");
            _builder.append("Module\\\\Helper\\\\FeatureActivationHelper::CATEGORIES\'), \'");
            String _formatForCode_6 = this._formattingExtensions.formatForCode(it.getName());
            _builder.append(_formatForCode_6, "            ");
            _builder.append("\') %}");
            _builder.newLineIfNotEmpty();
            _builder.append("    ");
            _builder.append("        ");
            _builder.append("    ");
            CharSequence _displayCategories = this.displayCategories(it);
            _builder.append(_displayCategories, "                ");
            _builder.newLineIfNotEmpty();
            _builder.append("    ");
            _builder.append("        ");
            _builder.append("{% endif %}");
            _builder.newLine();
          }
        }
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("</p>");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("#}");
        _builder.newLine();
      }
    }
    _builder.append("{% endif %}");
    _builder.newLine();
    _builder.append("</div>");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence displaySnippet(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _hasImageFieldsEntity = this._modelExtensions.hasImageFieldsEntity(it);
      if (_hasImageFieldsEntity) {
        final UploadField imageField = IterableExtensions.<UploadField>head(this._modelExtensions.getImageFieldsEntity(it));
        _builder.newLineIfNotEmpty();
        CharSequence _displayField = this.fieldHelper.displayField(imageField, this._formattingExtensions.formatForCode(it.getName()), "display");
        _builder.append(_displayField);
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("&nbsp;");
        _builder.newLine();
      }
    }
    return _builder;
  }
  
  private CharSequence displayDescription(final Entity it, final String praefix, final String suffix) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _hasAbstractStringFieldsEntity = this._modelExtensions.hasAbstractStringFieldsEntity(it);
      if (_hasAbstractStringFieldsEntity) {
        {
          boolean _hasTextFieldsEntity = this._modelExtensions.hasTextFieldsEntity(it);
          if (_hasTextFieldsEntity) {
            _builder.append("{% if ");
            String _formatForCode = this._formattingExtensions.formatForCode(it.getName());
            _builder.append(_formatForCode);
            _builder.append(".");
            String _formatForCode_1 = this._formattingExtensions.formatForCode(IterableExtensions.<TextField>head(this._modelExtensions.getTextFieldsEntity(it)).getName());
            _builder.append(_formatForCode_1);
            _builder.append(" is not empty %}");
            _builder.append(praefix);
            _builder.append("{{ ");
            String _formatForCode_2 = this._formattingExtensions.formatForCode(it.getName());
            _builder.append(_formatForCode_2);
            _builder.append(".");
            String _formatForCode_3 = this._formattingExtensions.formatForCode(IterableExtensions.<TextField>head(this._modelExtensions.getTextFieldsEntity(it)).getName());
            _builder.append(_formatForCode_3);
            _builder.append(" }}");
            _builder.append(suffix);
            _builder.append("{% endif %}");
            _builder.newLineIfNotEmpty();
          } else {
            boolean _hasStringFieldsEntity = this._modelExtensions.hasStringFieldsEntity(it);
            if (_hasStringFieldsEntity) {
              _builder.append("{% if ");
              String _formatForCode_4 = this._formattingExtensions.formatForCode(it.getName());
              _builder.append(_formatForCode_4);
              _builder.append(".");
              String _formatForCode_5 = this._formattingExtensions.formatForCode(IterableExtensions.<StringField>head(this._modelExtensions.getStringFieldsEntity(it)).getName());
              _builder.append(_formatForCode_5);
              _builder.append(" is not empty %}");
              _builder.append(praefix);
              _builder.append("{{ ");
              String _formatForCode_6 = this._formattingExtensions.formatForCode(it.getName());
              _builder.append(_formatForCode_6);
              _builder.append(".");
              String _formatForCode_7 = this._formattingExtensions.formatForCode(IterableExtensions.<StringField>head(this._modelExtensions.getStringFieldsEntity(it)).getName());
              _builder.append(_formatForCode_7);
              _builder.append(" }}");
              _builder.append(suffix);
              _builder.append("{% endif %}");
              _builder.newLineIfNotEmpty();
            }
          }
        }
      }
    }
    return _builder;
  }
  
  private CharSequence displayCategories(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("<dl class=\"category-list\">");
    _builder.newLine();
    _builder.append("{% for propName, catMapping in ");
    String _formatForCode = this._formattingExtensions.formatForCode(it.getName());
    _builder.append(_formatForCode);
    _builder.append(".categories %}");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("<dt>{{ propName }}</dt>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<dd>{{ catMapping.category.display_name[app.request.locale]|default(catMapping.category.name) }}</dd>");
    _builder.newLine();
    _builder.append("{% endfor %}");
    _builder.newLine();
    _builder.append("</dl>");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence itemInfoTemplate(final Entity it, final Application app) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{# Purpose of this template: Display item information for previewing from other modules #}");
    _builder.newLine();
    _builder.append("<dl id=\"");
    String _formatForCode = this._formattingExtensions.formatForCode(it.getName());
    _builder.append(_formatForCode);
    _builder.append("{{ ");
    String _formatForCode_1 = this._formattingExtensions.formatForCode(it.getName());
    _builder.append(_formatForCode_1);
    _builder.append(".");
    String _formatForCode_2 = this._formattingExtensions.formatForCode(this._modelExtensions.getFirstPrimaryKey(it).getName());
    _builder.append(_formatForCode_2);
    _builder.append(" }}\">");
    _builder.newLineIfNotEmpty();
    _builder.append("<dt>{{ ");
    String _formatForCode_3 = this._formattingExtensions.formatForCode(it.getName());
    _builder.append(_formatForCode_3);
    _builder.append(".getTitleFromDisplayPattern()");
    {
      boolean _isSkipHookSubscribers = it.isSkipHookSubscribers();
      boolean _not = (!_isSkipHookSubscribers);
      if (_not) {
        _builder.append("|notifyFilters(\'");
        String _formatForDB = this._formattingExtensions.formatForDB(app.getName());
        _builder.append(_formatForDB);
        _builder.append(".filter_hooks.");
        String _formatForDB_1 = this._formattingExtensions.formatForDB(it.getNameMultiple());
        _builder.append(_formatForDB_1);
        _builder.append(".filter\')");
      }
    }
    _builder.append(" }}</dt>");
    _builder.newLineIfNotEmpty();
    {
      boolean _hasImageFieldsEntity = this._modelExtensions.hasImageFieldsEntity(it);
      if (_hasImageFieldsEntity) {
        _builder.append("<dd>");
        CharSequence _displaySnippet = this.displaySnippet(it);
        _builder.append(_displaySnippet);
        _builder.append("</dd>");
        _builder.newLineIfNotEmpty();
      }
    }
    CharSequence _displayDescription = this.displayDescription(it, "<dd>", "</dd>");
    _builder.append(_displayDescription);
    _builder.newLineIfNotEmpty();
    {
      boolean _isCategorisable = it.isCategorisable();
      if (_isCategorisable) {
        _builder.append("{% if featureActivationHelper.isEnabled(constant(\'");
        String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(app.getVendor());
        _builder.append(_formatForCodeCapital);
        _builder.append("\\\\");
        String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(app.getName());
        _builder.append(_formatForCodeCapital_1);
        _builder.append("Module\\\\Helper\\\\FeatureActivationHelper::CATEGORIES\'), \'");
        String _formatForCode_4 = this._formattingExtensions.formatForCode(it.getName());
        _builder.append(_formatForCode_4);
        _builder.append("\') %}");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("<dd>");
        _builder.newLine();
        _builder.append("        ");
        CharSequence _displayCategories = this.displayCategories(it);
        _builder.append(_displayCategories, "        ");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("</dd>");
        _builder.newLine();
        _builder.append("{% endif %}");
        _builder.newLine();
      }
    }
    _builder.append("</dl>");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence findTemplate(final Entity it, final Application app) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{# Purpose of this template: Display a popup selector of ");
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(it.getNameMultiple());
    _builder.append(_formatForDisplay);
    _builder.append(" for scribite integration #}");
    _builder.newLineIfNotEmpty();
    _builder.append("{% set useFinder = true %}");
    _builder.newLine();
    _builder.append("{% extends \'");
    String _appName = this._utils.appName(app);
    _builder.append(_appName);
    _builder.append("::raw.html.twig\' %}");
    _builder.newLineIfNotEmpty();
    _builder.append("{% block title __(\'Search and select ");
    String _formatForDisplay_1 = this._formattingExtensions.formatForDisplay(it.getName());
    _builder.append(_formatForDisplay_1);
    _builder.append("\') %}");
    _builder.newLineIfNotEmpty();
    _builder.append("{% block content %}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<div class=\"container\">");
    _builder.newLine();
    _builder.append("        ");
    CharSequence _findTemplateObjectTypeSwitcher = this.findTemplateObjectTypeSwitcher(it, app);
    _builder.append(_findTemplateObjectTypeSwitcher, "        ");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("{% form_theme finderForm with [");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("\'@");
    String _appName_1 = this._utils.appName(app);
    _builder.append(_appName_1, "            ");
    _builder.append("/Form/bootstrap_3.html.twig\',");
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    _builder.append("\'ZikulaFormExtensionBundle:Form:form_div_layout.html.twig\'");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("] %}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("{{ form_start(finderForm, {attr: { id: \'");
    String _firstLower = StringExtensions.toFirstLower(this._utils.appName(app));
    _builder.append(_firstLower, "        ");
    _builder.append("SelectorForm\' }}) }}");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("{{ form_errors(finderForm) }}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<fieldset>");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("<legend>{{ __(\'Search and select ");
    String _formatForDisplay_2 = this._formattingExtensions.formatForDisplay(it.getName());
    _builder.append(_formatForDisplay_2, "            ");
    _builder.append("\') }}</legend>");
    _builder.newLineIfNotEmpty();
    {
      boolean _isCategorisable = it.isCategorisable();
      if (_isCategorisable) {
        _builder.append("            ");
        _builder.append("{% if featureActivationHelper.isEnabled(constant(\'");
        String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(app.getVendor());
        _builder.append(_formatForCodeCapital, "            ");
        _builder.append("\\\\");
        String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(app.getName());
        _builder.append(_formatForCodeCapital_1, "            ");
        _builder.append("Module\\\\Helper\\\\FeatureActivationHelper::CATEGORIES\'), \'");
        String _formatForCode = this._formattingExtensions.formatForCode(it.getName());
        _builder.append(_formatForCode, "            ");
        _builder.append("\') %}");
        _builder.newLineIfNotEmpty();
        _builder.append("            ");
        _builder.append("    ");
        _builder.append("{{ form_row(finderForm.categories) }}");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("{% endif %}");
        _builder.newLine();
      }
    }
    {
      boolean _hasImageFieldsEntity = this._modelExtensions.hasImageFieldsEntity(it);
      if (_hasImageFieldsEntity) {
        _builder.append("            ");
        _builder.append("{{ form_row(finderForm.onlyImages) }}");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("<div id=\"imageFieldRow\">");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("    ");
        _builder.append("{{ form_row(finderForm.imageField) }}");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("</div>");
        _builder.newLine();
      }
    }
    _builder.append("            ");
    _builder.append("{{ form_row(finderForm.pasteAs) }}");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("<br />");
    _builder.newLine();
    _builder.append("            ");
    CharSequence _findTemplateObjectId = this.findTemplateObjectId(it, app);
    _builder.append(_findTemplateObjectId, "            ");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("            ");
    _builder.append("{{ form_row(finderForm.sort) }}");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("{{ form_row(finderForm.sortdir) }}");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("{{ form_row(finderForm.num) }}");
    _builder.newLine();
    {
      boolean _hasAbstractStringFieldsEntity = this._modelExtensions.hasAbstractStringFieldsEntity(it);
      if (_hasAbstractStringFieldsEntity) {
        {
          boolean _hasImageFieldsEntity_1 = this._modelExtensions.hasImageFieldsEntity(it);
          if (_hasImageFieldsEntity_1) {
            _builder.append("            ");
            _builder.append("<div id=\"searchTermRow\">");
            _builder.newLine();
            _builder.append("            ");
            _builder.append("    ");
            _builder.append("{{ form_row(finderForm.q) }}");
            _builder.newLine();
            _builder.append("            ");
            _builder.append("</div>");
            _builder.newLine();
          } else {
            _builder.append("            ");
            _builder.append("{{ form_row(finderForm.q) }}");
            _builder.newLine();
          }
        }
      }
    }
    _builder.append("            ");
    _builder.append("<div>");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("{{ pager({ display: \'page\', rowcount: pager.numitems, limit: pager.itemsperpage, posvar: \'pos\', maxpages: 10, route: \'");
    String _formatForDB = this._formattingExtensions.formatForDB(this._utils.appName(app));
    _builder.append(_formatForDB, "                ");
    _builder.append("_external_finder\'}) }}");
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    _builder.append("</div>");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("<div class=\"form-group\">");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("<div class=\"col-sm-offset-3 col-sm-9\">");
    _builder.newLine();
    _builder.append("                    ");
    _builder.append("{{ form_widget(finderForm.update) }}");
    _builder.newLine();
    _builder.append("                    ");
    _builder.append("{{ form_widget(finderForm.cancel) }}");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("</div>");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("</div>");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("</fieldset>");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("{{ form_end(finderForm) }}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("</div>");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    CharSequence _findTemplateEditForm = this.findTemplateEditForm(it, app);
    _builder.append(_findTemplateEditForm, "    ");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    CharSequence _findTemplateJs = this.findTemplateJs(it, app);
    _builder.append(_findTemplateJs, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("{% endblock %}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence findTemplateObjectTypeSwitcher(final Entity it, final Application app) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _hasDisplayActions = this._controllerExtensions.hasDisplayActions(app);
      if (_hasDisplayActions) {
        _builder.append("<div class=\"zikula-bootstrap-tab-container\">");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("<ul class=\"nav nav-tabs\">");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("{% set activatedObjectTypes = getModVar(\'");
        String _appName = this._utils.appName(app);
        _builder.append(_appName, "    ");
        _builder.append("\', \'enabledFinderTypes\', []) %}");
        _builder.newLineIfNotEmpty();
        {
          final Function1<Entity, Boolean> _function = (Entity it_1) -> {
            return Boolean.valueOf(this._controllerExtensions.hasDisplayAction(it_1));
          };
          Iterable<Entity> _filter = IterableExtensions.<Entity>filter(this._modelExtensions.getAllEntities(app), _function);
          for(final Entity entity : _filter) {
            _builder.append("    ");
            _builder.append("{% if \'");
            String _formatForCode = this._formattingExtensions.formatForCode(entity.getName());
            _builder.append(_formatForCode, "    ");
            _builder.append("\' in activatedObjectTypes %}");
            _builder.newLineIfNotEmpty();
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("<li{{ objectType == \'");
            String _formatForCode_1 = this._formattingExtensions.formatForCode(entity.getName());
            _builder.append(_formatForCode_1, "        ");
            _builder.append("\' ? \' class=\"active\"\' : \'\' }}><a href=\"{{ path(\'");
            String _formatForDB = this._formattingExtensions.formatForDB(this._utils.appName(app));
            _builder.append(_formatForDB, "        ");
            _builder.append("_external_finder\', {\'objectType\': \'");
            String _formatForCode_2 = this._formattingExtensions.formatForCode(entity.getName());
            _builder.append(_formatForCode_2, "        ");
            _builder.append("\', \'editor\': editorName}) }}\" title=\"{{ __(\'Search and select ");
            String _formatForDisplay = this._formattingExtensions.formatForDisplay(entity.getName());
            _builder.append(_formatForDisplay, "        ");
            _builder.append("\') }}\">{{ __(\'");
            String _formatForDisplayCapital = this._formattingExtensions.formatForDisplayCapital(entity.getNameMultiple());
            _builder.append(_formatForDisplayCapital, "        ");
            _builder.append("\') }}</a></li>");
            _builder.newLineIfNotEmpty();
            _builder.append("    ");
            _builder.append("{% endif %}");
            _builder.newLine();
          }
        }
        _builder.append("    ");
        _builder.append("</ul>");
        _builder.newLine();
        _builder.append("</div>");
        _builder.newLine();
      }
    }
    return _builder;
  }
  
  private CharSequence findTemplateObjectId(final Entity it, final Application app) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("<div class=\"form-group\">");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<label class=\"col-sm-3 control-label\">{{ __(\'");
    String _formatForDisplayCapital = this._formattingExtensions.formatForDisplayCapital(it.getName());
    _builder.append(_formatForDisplayCapital, "    ");
    _builder.append("\') }}:</label>");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("<div class=\"col-sm-9\">");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<div id=\"");
    String _lowerCase = this._utils.appName(app).toLowerCase();
    _builder.append(_lowerCase, "        ");
    _builder.append("ItemContainer\">");
    _builder.newLineIfNotEmpty();
    {
      boolean _hasImageFieldsEntity = this._modelExtensions.hasImageFieldsEntity(it);
      if (_hasImageFieldsEntity) {
        _builder.append("            ");
        _builder.append("{% if not onlyImages %}");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("    ");
        _builder.append("<ul>");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("{% endif %}");
        _builder.newLine();
      } else {
        _builder.append("            ");
        _builder.append("<ul>");
        _builder.newLine();
      }
    }
    _builder.append("                ");
    _builder.append("{% for ");
    String _formatForCode = this._formattingExtensions.formatForCode(it.getName());
    _builder.append(_formatForCode, "                ");
    _builder.append(" in items %}");
    _builder.newLineIfNotEmpty();
    {
      boolean _hasImageFieldsEntity_1 = this._modelExtensions.hasImageFieldsEntity(it);
      if (_hasImageFieldsEntity_1) {
        _builder.append("                    ");
        _builder.append("{% if not onlyImages or (attribute(");
        String _formatForCode_1 = this._formattingExtensions.formatForCode(it.getName());
        _builder.append(_formatForCode_1, "                    ");
        _builder.append(", imageField) is not empty and attribute(");
        String _formatForCode_2 = this._formattingExtensions.formatForCode(it.getName());
        _builder.append(_formatForCode_2, "                    ");
        _builder.append(", imageField ~ \'Meta\').isImage) %}");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      boolean _hasImageFieldsEntity_2 = this._modelExtensions.hasImageFieldsEntity(it);
      if (_hasImageFieldsEntity_2) {
        _builder.append("                    ");
        _builder.append("{% if not onlyImages %}");
        _builder.newLine();
        _builder.append("                    ");
        _builder.append("    ");
        _builder.append("<li>");
        _builder.newLine();
        _builder.append("                    ");
        _builder.append("{% endif %}");
        _builder.newLine();
      } else {
        _builder.append("                    ");
        _builder.append("<li>");
        _builder.newLine();
      }
    }
    _builder.append("                        ");
    _builder.append("{% set itemId = ");
    String _formatForCode_3 = this._formattingExtensions.formatForCode(it.getName());
    _builder.append(_formatForCode_3, "                        ");
    _builder.append(".createCompositeIdentifier() %}");
    _builder.newLineIfNotEmpty();
    _builder.append("                        ");
    _builder.append("<a href=\"#\" data-itemid=\"{{ itemId }}\">");
    _builder.newLine();
    {
      boolean _hasImageFieldsEntity_3 = this._modelExtensions.hasImageFieldsEntity(it);
      if (_hasImageFieldsEntity_3) {
        _builder.append("                            ");
        _builder.append("{% if onlyImages %}");
        _builder.newLine();
        _builder.append("                            ");
        _builder.append("    ");
        _builder.append("{% set thumbOptions = attribute(thumbRuntimeOptions, \'");
        String _formatForCode_4 = this._formattingExtensions.formatForCode(it.getName());
        _builder.append(_formatForCode_4, "                                ");
        _builder.append("\' ~ imageField[:1]|upper ~ imageField[1:]) %}");
        _builder.newLineIfNotEmpty();
        _builder.append("                            ");
        _builder.append("    ");
        _builder.append("<img src=\"{{ attribute(");
        String _formatForCode_5 = this._formattingExtensions.formatForCode(it.getName());
        _builder.append(_formatForCode_5, "                                ");
        _builder.append(", imageField).getPathname()|imagine_filter(\'zkroot\', thumbOptions) }}\" alt=\"{{ ");
        String _formatForCode_6 = this._formattingExtensions.formatForCode(it.getName());
        _builder.append(_formatForCode_6, "                                ");
        _builder.append(".getTitleFromDisplayPattern()|e(\'html_attr\') }}\" width=\"{{ thumbOptions.thumbnail.size[0] }}\" height=\"{{ thumbOptions.thumbnail.size[1] }}\" class=\"img-rounded\" />");
        _builder.newLineIfNotEmpty();
        _builder.append("                            ");
        _builder.append("{% else %}");
        _builder.newLine();
        _builder.append("                            ");
        _builder.append("    ");
        _builder.append("{{ ");
        String _formatForCode_7 = this._formattingExtensions.formatForCode(it.getName());
        _builder.append(_formatForCode_7, "                                ");
        _builder.append(".getTitleFromDisplayPattern() }}");
        _builder.newLineIfNotEmpty();
        _builder.append("                            ");
        _builder.append("{% endif %}");
        _builder.newLine();
      } else {
        _builder.append("                            ");
        _builder.append("{{ ");
        String _formatForCode_8 = this._formattingExtensions.formatForCode(it.getName());
        _builder.append(_formatForCode_8, "                            ");
        _builder.append(".getTitleFromDisplayPattern() }}");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("                        ");
    _builder.append("</a>");
    _builder.newLine();
    _builder.append("                        ");
    _builder.append("<input type=\"hidden\" id=\"path{{ itemId }}\" value=\"{{ path(\'");
    String _formatForDB = this._formattingExtensions.formatForDB(this._utils.appName(app));
    _builder.append(_formatForDB, "                        ");
    _builder.append("_");
    String _formatForDB_1 = this._formattingExtensions.formatForDB(it.getName());
    _builder.append(_formatForDB_1, "                        ");
    _builder.append("_display\'");
    CharSequence _routeParams = this._urlExtensions.routeParams(it, this._formattingExtensions.formatForCode(it.getName()), Boolean.valueOf(true));
    _builder.append(_routeParams, "                        ");
    _builder.append(") }}\" />");
    _builder.newLineIfNotEmpty();
    _builder.append("                        ");
    _builder.append("<input type=\"hidden\" id=\"url{{ itemId }}\" value=\"{{ url(\'");
    String _formatForDB_2 = this._formattingExtensions.formatForDB(this._utils.appName(app));
    _builder.append(_formatForDB_2, "                        ");
    _builder.append("_");
    String _formatForDB_3 = this._formattingExtensions.formatForDB(it.getName());
    _builder.append(_formatForDB_3, "                        ");
    _builder.append("_display\'");
    CharSequence _routeParams_1 = this._urlExtensions.routeParams(it, this._formattingExtensions.formatForCode(it.getName()), Boolean.valueOf(true));
    _builder.append(_routeParams_1, "                        ");
    _builder.append(") }}\" />");
    _builder.newLineIfNotEmpty();
    _builder.append("                        ");
    _builder.append("<input type=\"hidden\" id=\"title{{ itemId }}\" value=\"{{ ");
    String _formatForCode_9 = this._formattingExtensions.formatForCode(it.getName());
    _builder.append(_formatForCode_9, "                        ");
    _builder.append(".getTitleFromDisplayPattern()|e(\'html_attr\') }}\" />");
    _builder.newLineIfNotEmpty();
    _builder.append("                        ");
    _builder.append("<input type=\"hidden\" id=\"desc{{ itemId }}\" value=\"{% set description %}");
    CharSequence _displayDescription = this.displayDescription(it, "", "");
    _builder.append(_displayDescription, "                        ");
    _builder.append("{% endset %}{{ description|striptags|e(\'html_attr\') }}\" />");
    _builder.newLineIfNotEmpty();
    {
      boolean _hasImageFieldsEntity_4 = this._modelExtensions.hasImageFieldsEntity(it);
      if (_hasImageFieldsEntity_4) {
        _builder.append("                        ");
        _builder.append("{% if onlyImages %}");
        _builder.newLine();
        _builder.append("                        ");
        _builder.append("    ");
        _builder.append("<input type=\"hidden\" id=\"imagePath{{ itemId }}\" value=\"/{{ attribute(");
        String _formatForCode_10 = this._formattingExtensions.formatForCode(it.getName());
        _builder.append(_formatForCode_10, "                            ");
        _builder.append(", imageField).getPathname() }}\" />");
        _builder.newLineIfNotEmpty();
        _builder.append("                        ");
        _builder.append("{% endif %}");
        _builder.newLine();
      }
    }
    {
      boolean _hasImageFieldsEntity_5 = this._modelExtensions.hasImageFieldsEntity(it);
      if (_hasImageFieldsEntity_5) {
        _builder.append("                    ");
        _builder.append("{% if not onlyImages %}");
        _builder.newLine();
        _builder.append("                    ");
        _builder.append("    ");
        _builder.append("</li>");
        _builder.newLine();
        _builder.append("                    ");
        _builder.append("{% endif %}");
        _builder.newLine();
      } else {
        _builder.append("                    ");
        _builder.append("</li>");
        _builder.newLine();
      }
    }
    {
      boolean _hasImageFieldsEntity_6 = this._modelExtensions.hasImageFieldsEntity(it);
      if (_hasImageFieldsEntity_6) {
        _builder.append("                    ");
        _builder.append("{% endif %}");
        _builder.newLine();
      }
    }
    _builder.append("                ");
    _builder.append("{% else %}");
    _builder.newLine();
    {
      boolean _hasImageFieldsEntity_7 = this._modelExtensions.hasImageFieldsEntity(it);
      if (_hasImageFieldsEntity_7) {
        _builder.append("                    ");
        _builder.append("{% if not onlyImages %}<li>{% endif %}{{ __(\'No ");
        String _formatForDisplay = this._formattingExtensions.formatForDisplay(it.getNameMultiple());
        _builder.append(_formatForDisplay, "                    ");
        _builder.append(" found.\') }}{% if not onlyImages %}</li>{% endif %}");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("                    ");
        _builder.append("<li>{{ __(\'No ");
        String _formatForDisplay_1 = this._formattingExtensions.formatForDisplay(it.getNameMultiple());
        _builder.append(_formatForDisplay_1, "                    ");
        _builder.append(" found.\') }}</li>");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("                ");
    _builder.append("{% endfor %}");
    _builder.newLine();
    {
      boolean _hasImageFieldsEntity_8 = this._modelExtensions.hasImageFieldsEntity(it);
      if (_hasImageFieldsEntity_8) {
        _builder.append("            ");
        _builder.append("{% if not onlyImages %}");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("    ");
        _builder.append("</ul>");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("{% endif %}");
        _builder.newLine();
      } else {
        _builder.append("            ");
        _builder.append("</ul>");
        _builder.newLine();
      }
    }
    _builder.append("        ");
    _builder.append("</div>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("</div>");
    _builder.newLine();
    _builder.append("</div>");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence findTemplateEditForm(final Entity it, final Application app) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _hasEditAction = this._controllerExtensions.hasEditAction(it);
      if (_hasEditAction) {
        _builder.append("{#");
        _builder.newLine();
        _builder.append("<div class=\"");
        String _lowerCase = this._utils.appName(app).toLowerCase();
        _builder.append(_lowerCase);
        _builder.append("-finderform\">");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("<fieldset>");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("{{ render(controller(\'");
        String _appName = this._utils.appName(app);
        _builder.append(_appName, "        ");
        _builder.append(":");
        String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(it.getName());
        _builder.append(_formatForCodeCapital, "        ");
        _builder.append(":edit\')) }}");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("</fieldset>");
        _builder.newLine();
        _builder.append("</div>");
        _builder.newLine();
        _builder.append("#}");
        _builder.newLine();
      }
    }
    return _builder;
  }
  
  private CharSequence findTemplateJs(final Entity it, final Application app) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("<script type=\"text/javascript\">");
    _builder.newLine();
    _builder.append("/* <![CDATA[ */");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("( function($) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$(document).ready(function() {");
    _builder.newLine();
    _builder.append("            ");
    String _firstLower = StringExtensions.toFirstLower(this._utils.appName(app));
    _builder.append(_firstLower, "            ");
    _builder.append(".finder.onLoad();");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("});");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("})(jQuery);");
    _builder.newLine();
    _builder.append("/* ]]> */");
    _builder.newLine();
    _builder.append("</script>");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence selectTemplate(final Entity it, final Application app) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{* Purpose of this template: Display a popup selector for Forms and Content integration *}");
    _builder.newLine();
    _builder.append("{assign var=\'baseID\' value=\'");
    String _formatForCode = this._formattingExtensions.formatForCode(it.getName());
    _builder.append(_formatForCode);
    _builder.append("\'}");
    _builder.newLineIfNotEmpty();
    _builder.append("<div class=\"row\">");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<div class=\"col-sm-8\">");
    _builder.newLine();
    {
      boolean _isCategorisable = it.isCategorisable();
      if (_isCategorisable) {
        _builder.newLine();
        _builder.append("        ");
        _builder.append("{if $properties ne null && is_array($properties)}");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("{gt text=\'All\' assign=\'lblDefault\'}");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("{nocache}");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("{foreach key=\'propertyName\' item=\'propertyId\' from=$properties}");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("        ");
        _builder.append("<div class=\"form-group\">");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("            ");
        _builder.append("{assign var=\'hasMultiSelection\' value=$categoryHelper->hasMultipleSelection(\'");
        String _formatForCode_1 = this._formattingExtensions.formatForCode(it.getName());
        _builder.append(_formatForCode_1, "                    ");
        _builder.append("\', $propertyName)}");
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        _builder.append("            ");
        _builder.append("{gt text=\'Category\' assign=\'categoryLabel\'}");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("            ");
        _builder.append("{assign var=\'categorySelectorId\' value=\'catid\'}");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("            ");
        _builder.append("{assign var=\'categorySelectorName\' value=\'catid\'}");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("            ");
        _builder.append("{assign var=\'categorySelectorSize\' value=\'1\'}");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("            ");
        _builder.append("{if $hasMultiSelection eq true}");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("                ");
        _builder.append("{gt text=\'Categories\' assign=\'categoryLabel\'}");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("                ");
        _builder.append("{assign var=\'categorySelectorName\' value=\'catids\'}");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("                ");
        _builder.append("{assign var=\'categorySelectorId\' value=\'catids__\'}");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("                ");
        _builder.append("{assign var=\'categorySelectorSize\' value=\'8\'}");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("            ");
        _builder.append("{/if}");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("            ");
        _builder.append("<label for=\"{$baseID}_{$categorySelectorId}{$propertyName}\" class=\"col-sm-3 control-label\">{$categoryLabel}:</label>");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("            ");
        _builder.append("<div class=\"col-sm-9\">");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("                ");
        _builder.append("{selector_category name=\"`$baseID`_`$categorySelectorName``$propertyName`\" field=\'id\' selectedValue=$catIds.$propertyName|default:null categoryRegistryModule=\'");
        String _appName = this._utils.appName(app);
        _builder.append(_appName, "                        ");
        _builder.append("\' categoryRegistryTable=\"`$objectType`Entity\" categoryRegistryProperty=$propertyName defaultText=$lblDefault editLink=false multipleSize=$categorySelectorSize cssClass=\'form-control\'}");
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        _builder.append("            ");
        _builder.append("</div>");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("        ");
        _builder.append("</div>");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("{/foreach}");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("{/nocache}");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("{/if}");
        _builder.newLine();
      }
    }
    _builder.append("        ");
    _builder.append("<div class=\"form-group\">");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("<label for=\"{$baseID}Id\" class=\"col-sm-3 control-label\">{gt text=\'");
    String _formatForDisplayCapital = this._formattingExtensions.formatForDisplayCapital(it.getName());
    _builder.append(_formatForDisplayCapital, "            ");
    _builder.append("\'}:</label>");
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    _builder.append("<div class=\"col-sm-9\">");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("<select id=\"{$baseID}Id\" name=\"id\" class=\"form-control\">");
    _builder.newLine();
    _builder.append("                    ");
    _builder.append("{foreach item=\'");
    String _formatForCode_2 = this._formattingExtensions.formatForCode(it.getName());
    _builder.append(_formatForCode_2, "                    ");
    _builder.append("\' from=$items}");
    _builder.newLineIfNotEmpty();
    _builder.append("                        ");
    _builder.append("<option value=\"{$");
    String _formatForCode_3 = this._formattingExtensions.formatForCode(it.getName());
    _builder.append(_formatForCode_3, "                        ");
    _builder.append(".");
    String _formatForCode_4 = this._formattingExtensions.formatForCode(this._modelExtensions.getFirstPrimaryKey(it).getName());
    _builder.append(_formatForCode_4, "                        ");
    _builder.append("}\"{if $selectedId eq $");
    String _formatForCode_5 = this._formattingExtensions.formatForCode(it.getName());
    _builder.append(_formatForCode_5, "                        ");
    _builder.append(".");
    String _formatForCode_6 = this._formattingExtensions.formatForCode(this._modelExtensions.getFirstPrimaryKey(it).getName());
    _builder.append(_formatForCode_6, "                        ");
    _builder.append("} selected=\"selected\"{/if}>{$");
    String _formatForCode_7 = this._formattingExtensions.formatForCode(it.getName());
    _builder.append(_formatForCode_7, "                        ");
    _builder.append("->getTitleFromDisplayPattern()}</option>");
    _builder.newLineIfNotEmpty();
    _builder.append("                    ");
    _builder.append("{foreachelse}");
    _builder.newLine();
    _builder.append("                        ");
    _builder.append("<option value=\"0\">{gt text=\'No entries found.\'}</option>");
    _builder.newLine();
    _builder.append("                    ");
    _builder.append("{/foreach}");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("</select>");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("</div>");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("</div>");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<div class=\"form-group\">");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("<label for=\"{$baseID}Sort\" class=\"col-sm-3 control-label\">{gt text=\'Sort by\'}:</label>");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("<div class=\"col-sm-9\">");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("<select id=\"{$baseID}Sort\" name=\"sort\" class=\"form-control\">");
    _builder.newLine();
    {
      List<EntityField> _sortingFields = this._modelExtensions.getSortingFields(it);
      for(final EntityField field : _sortingFields) {
        _builder.append("                    ");
        _builder.append("<option value=\"");
        String _formatForCode_8 = this._formattingExtensions.formatForCode(field.getName());
        _builder.append(_formatForCode_8, "                    ");
        _builder.append("\"{if $sort eq \'");
        String _formatForCode_9 = this._formattingExtensions.formatForCode(field.getName());
        _builder.append(_formatForCode_9, "                    ");
        _builder.append("\'} selected=\"selected\"{/if}>{gt text=\'");
        String _formatForDisplayCapital_1 = this._formattingExtensions.formatForDisplayCapital(field.getName());
        _builder.append(_formatForDisplayCapital_1, "                    ");
        _builder.append("\'}</option>");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      boolean _isStandardFields = it.isStandardFields();
      if (_isStandardFields) {
        _builder.append("                    ");
        _builder.append("<option value=\"createdDate\"{if $sort eq \'createdDate\'} selected=\"selected\"{/if}>{gt text=\'Creation date\'}</option>");
        _builder.newLine();
        _builder.append("                    ");
        _builder.append("<option value=\"createdBy\"{if $sort eq \'createdBy\'} selected=\"selected\"{/if}>{gt text=\'Creator\'}</option>");
        _builder.newLine();
        _builder.append("                    ");
        _builder.append("<option value=\"updatedDate\"{if $sort eq \'updatedDate\'} selected=\"selected\"{/if}>{gt text=\'Update date\'}</option>");
        _builder.newLine();
        _builder.append("                    ");
        _builder.append("<option value=\"updatedBy\"{if $sort eq \'updatedBy\'} selected=\"selected\"{/if}>{gt text=\'Updater\'}</option>");
        _builder.newLine();
      }
    }
    _builder.append("                ");
    _builder.append("</select>");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("<select id=\"{$baseID}SortDir\" name=\"sortdir\" class=\"form-control\">");
    _builder.newLine();
    _builder.append("                    ");
    _builder.append("<option value=\"asc\"{if $sortdir eq \'asc\'} selected=\"selected\"{/if}>{gt text=\'ascending\'}</option>");
    _builder.newLine();
    _builder.append("                    ");
    _builder.append("<option value=\"desc\"{if $sortdir eq \'desc\'} selected=\"selected\"{/if}>{gt text=\'descending\'}</option>");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("</select>");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("</div>");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("</div>");
    _builder.newLine();
    {
      boolean _hasAbstractStringFieldsEntity = this._modelExtensions.hasAbstractStringFieldsEntity(it);
      if (_hasAbstractStringFieldsEntity) {
        _builder.append("        ");
        _builder.append("<div class=\"form-group\">");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("<label for=\"{$baseID}SearchTerm\" class=\"col-sm-3 control-label\">{gt text=\'Search for\'}:</label>");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("<div class=\"col-sm-9\">");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("        ");
        _builder.append("<div class=\"input-group\">");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("            ");
        _builder.append("<input type=\"text\" id=\"{$baseID}SearchTerm\" name=\"q\" class=\"form-control\" />");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("            ");
        _builder.append("<span class=\"input-group-btn\">");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("                ");
        _builder.append("<input type=\"button\" id=\"");
        String _firstLower = StringExtensions.toFirstLower(this._utils.appName(app));
        _builder.append(_firstLower, "                        ");
        _builder.append("SearchGo\" name=\"gosearch\" value=\"{gt text=\'Filter\'}\" class=\"btn btn-default\" />");
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        _builder.append("            ");
        _builder.append("</span>");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("        ");
        _builder.append("</div>");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("</div>");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("</div>");
        _builder.newLine();
      }
    }
    _builder.append("    ");
    _builder.append("</div>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<div class=\"col-sm-4\">");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<div id=\"{$baseID}Preview\" style=\"border: 1px dotted #a3a3a3; padding: .2em .5em\">");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("<p><strong>{gt text=\'");
    String _formatForDisplayCapital_2 = this._formattingExtensions.formatForDisplayCapital(it.getName());
    _builder.append(_formatForDisplayCapital_2, "            ");
    _builder.append(" information\'}</strong></p>");
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    _builder.append("{img id=\'ajax_indicator\' modname=\'core\' set=\'ajax\' src=\'indicator_circle.gif\' alt=\'\' class=\'hidden\'}");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("<div id=\"{$baseID}PreviewContainer\">&nbsp;</div>");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("</div>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("</div>");
    _builder.newLine();
    _builder.append("</div>");
    _builder.newLine();
    _builder.newLine();
    _builder.append("<script type=\"text/javascript\">");
    _builder.newLine();
    _builder.append("/* <![CDATA[ */");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("( function($) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$(document).ready(function() {");
    _builder.newLine();
    _builder.append("            ");
    String _firstLower_1 = StringExtensions.toFirstLower(this._utils.appName(app));
    _builder.append(_firstLower_1, "            ");
    _builder.append(".itemSelector.onLoad(\'{{$baseID}}\', {{$selectedId|default:0}});");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("});");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("})(jQuery);");
    _builder.newLine();
    _builder.append("/* ]]> */");
    _builder.newLine();
    _builder.append("</script>");
    _builder.newLine();
    return _builder;
  }
}
