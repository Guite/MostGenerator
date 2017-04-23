package org.zikula.modulestudio.generator.cartridges.zclassic.view.additions;

import com.google.common.collect.Iterables;
import de.guite.modulestudio.metamodel.Application;
import de.guite.modulestudio.metamodel.Entity;
import de.guite.modulestudio.metamodel.StringField;
import de.guite.modulestudio.metamodel.TextField;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.eclipse.xtext.xbase.lib.StringExtensions;
import org.zikula.modulestudio.generator.extensions.ControllerExtensions;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.UrlExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class ContentTypeListView {
  @Extension
  private ControllerExtensions _controllerExtensions = new ControllerExtensions();
  
  @Extension
  private FormattingExtensions _formattingExtensions = new FormattingExtensions();
  
  @Extension
  private ModelBehaviourExtensions _modelBehaviourExtensions = new ModelBehaviourExtensions();
  
  @Extension
  private ModelExtensions _modelExtensions = new ModelExtensions();
  
  @Extension
  private NamingExtensions _namingExtensions = new NamingExtensions();
  
  @Extension
  private UrlExtensions _urlExtensions = new UrlExtensions();
  
  @Extension
  private Utils _utils = new Utils();
  
  public void generate(final Application it, final IFileSystemAccess fsa) {
    String _viewPath = this._namingExtensions.getViewPath(it);
    final String templatePath = (_viewPath + "ContentType/");
    final String templateExtension = ".html.twig";
    String fileName = "";
    Iterable<Entity> _allEntities = this._modelExtensions.getAllEntities(it);
    for (final Entity entity : _allEntities) {
      {
        String _formatForCode = this._formattingExtensions.formatForCode(entity.getName());
        String _plus = ("itemlist_" + _formatForCode);
        String _plus_1 = (_plus + "_display_description");
        String _plus_2 = (_plus_1 + templateExtension);
        fileName = _plus_2;
        boolean _shouldBeSkipped = this._namingExtensions.shouldBeSkipped(it, (templatePath + fileName));
        boolean _not = (!_shouldBeSkipped);
        if (_not) {
          boolean _shouldBeMarked = this._namingExtensions.shouldBeMarked(it, (templatePath + fileName));
          if (_shouldBeMarked) {
            String _formatForCode_1 = this._formattingExtensions.formatForCode(entity.getName());
            String _plus_3 = ("itemlist_" + _formatForCode_1);
            String _plus_4 = (_plus_3 + "_display_description.generated");
            String _plus_5 = (_plus_4 + templateExtension);
            fileName = _plus_5;
          }
          fsa.generateFile((templatePath + fileName), this.displayDescTemplate(entity, it));
        }
        String _formatForCode_2 = this._formattingExtensions.formatForCode(entity.getName());
        String _plus_6 = ("itemlist_" + _formatForCode_2);
        String _plus_7 = (_plus_6 + "_display");
        String _plus_8 = (_plus_7 + templateExtension);
        fileName = _plus_8;
        boolean _shouldBeSkipped_1 = this._namingExtensions.shouldBeSkipped(it, (templatePath + fileName));
        boolean _not_1 = (!_shouldBeSkipped_1);
        if (_not_1) {
          boolean _shouldBeMarked_1 = this._namingExtensions.shouldBeMarked(it, (templatePath + fileName));
          if (_shouldBeMarked_1) {
            String _formatForCode_3 = this._formattingExtensions.formatForCode(entity.getName());
            String _plus_9 = ("itemlist_" + _formatForCode_3);
            String _plus_10 = (_plus_9 + "_display.generated");
            String _plus_11 = (_plus_10 + templateExtension);
            fileName = _plus_11;
          }
          fsa.generateFile((templatePath + fileName), this.displayTemplate(entity, it));
        }
      }
    }
    fileName = ("itemlist_display" + templateExtension);
    boolean _shouldBeSkipped = this._namingExtensions.shouldBeSkipped(it, (templatePath + fileName));
    boolean _not = (!_shouldBeSkipped);
    if (_not) {
      boolean _shouldBeMarked = this._namingExtensions.shouldBeMarked(it, (templatePath + fileName));
      if (_shouldBeMarked) {
        fileName = ("itemlist_display.generated" + templateExtension);
      }
      fsa.generateFile((templatePath + fileName), this.fallbackDisplayTemplate(it));
    }
    fileName = "itemlist_edit.tpl";
    boolean _shouldBeSkipped_1 = this._namingExtensions.shouldBeSkipped(it, (templatePath + fileName));
    boolean _not_1 = (!_shouldBeSkipped_1);
    if (_not_1) {
      boolean _shouldBeMarked_1 = this._namingExtensions.shouldBeMarked(it, (templatePath + fileName));
      if (_shouldBeMarked_1) {
        fileName = "itemlist_edit.generated.tpl";
      }
      fsa.generateFile((templatePath + fileName), this.editTemplate(it));
    }
  }
  
  private CharSequence displayDescTemplate(final Entity it, final Application app) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{# Purpose of this template: Display ");
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(it.getNameMultiple());
    _builder.append(_formatForDisplay);
    _builder.append(" within an external context #}");
    _builder.newLineIfNotEmpty();
    _builder.append("<dl>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{% for ");
    String _formatForCode = this._formattingExtensions.formatForCode(it.getName());
    _builder.append(_formatForCode, "    ");
    _builder.append(" in items %}");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("<dt>{{ ");
    String _formatForCode_1 = this._formattingExtensions.formatForCode(it.getName());
    _builder.append(_formatForCode_1, "        ");
    _builder.append(".getTitleFromDisplayPattern() }}</dt>");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    final Iterable<TextField> textFields = Iterables.<TextField>filter(it.getFields(), TextField.class);
    _builder.newLineIfNotEmpty();
    {
      boolean _isEmpty = IterableExtensions.isEmpty(textFields);
      boolean _not = (!_isEmpty);
      if (_not) {
        _builder.append("        ");
        _builder.append("{% if ");
        String _formatForCode_2 = this._formattingExtensions.formatForCode(it.getName());
        _builder.append(_formatForCode_2, "        ");
        _builder.append(".");
        String _formatForCode_3 = this._formattingExtensions.formatForCode(IterableExtensions.<TextField>head(textFields).getName());
        _builder.append(_formatForCode_3, "        ");
        _builder.append(" %}");
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("<dd>{{ ");
        String _formatForCode_4 = this._formattingExtensions.formatForCode(it.getName());
        _builder.append(_formatForCode_4, "            ");
        _builder.append(".");
        String _formatForCode_5 = this._formattingExtensions.formatForCode(IterableExtensions.<TextField>head(textFields).getName());
        _builder.append(_formatForCode_5, "            ");
        _builder.append("|striptags|truncate(200, true, \'&hellip;\') }}</dd>");
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        _builder.append("{% endif %}");
        _builder.newLine();
      } else {
        _builder.append("        ");
        final Function1<StringField, Boolean> _function = (StringField it_1) -> {
          boolean _isPassword = it_1.isPassword();
          return Boolean.valueOf((!_isPassword));
        };
        final Iterable<StringField> stringFields = IterableExtensions.<StringField>filter(Iterables.<StringField>filter(it.getFields(), StringField.class), _function);
        _builder.newLineIfNotEmpty();
        {
          boolean _isEmpty_1 = IterableExtensions.isEmpty(stringFields);
          boolean _not_1 = (!_isEmpty_1);
          if (_not_1) {
            _builder.append("        ");
            _builder.append("{% if ");
            String _formatForCode_6 = this._formattingExtensions.formatForCode(it.getName());
            _builder.append(_formatForCode_6, "        ");
            _builder.append(".");
            String _formatForCode_7 = this._formattingExtensions.formatForCode(IterableExtensions.<StringField>head(stringFields).getName());
            _builder.append(_formatForCode_7, "        ");
            _builder.append(" %}");
            _builder.newLineIfNotEmpty();
            _builder.append("        ");
            _builder.append("    ");
            _builder.append("<dd>{{ ");
            String _formatForCode_8 = this._formattingExtensions.formatForCode(it.getName());
            _builder.append(_formatForCode_8, "            ");
            _builder.append(".");
            String _formatForCode_9 = this._formattingExtensions.formatForCode(IterableExtensions.<StringField>head(stringFields).getName());
            _builder.append(_formatForCode_9, "            ");
            _builder.append("|striptags|truncate(200, true, \'&hellip;\') }}</dd>");
            _builder.newLineIfNotEmpty();
            _builder.append("        ");
            _builder.append("{% endif %}");
            _builder.newLine();
          }
        }
      }
    }
    {
      boolean _hasDisplayAction = this._controllerExtensions.hasDisplayAction(it);
      if (_hasDisplayAction) {
        _builder.append("        ");
        _builder.append("<dd>");
        CharSequence _detailLink = this.detailLink(it, this._utils.appName(app));
        _builder.append(_detailLink, "        ");
        _builder.append("</dd>");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("    ");
    _builder.append("{% else %}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<dt>{{ __(\'No entries found.\') }}</dt>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{% endfor %}");
    _builder.newLine();
    _builder.append("</dl>");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence displayTemplate(final Entity it, final Application app) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{# Purpose of this template: Display ");
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(it.getNameMultiple());
    _builder.append(_formatForDisplay);
    _builder.append(" within an external context #}");
    _builder.newLineIfNotEmpty();
    _builder.append("{% for ");
    String _formatForCode = this._formattingExtensions.formatForCode(it.getName());
    _builder.append(_formatForCode);
    _builder.append(" in items %}");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("<h3>{{ ");
    String _formatForCode_1 = this._formattingExtensions.formatForCode(it.getName());
    _builder.append(_formatForCode_1, "    ");
    _builder.append(".getTitleFromDisplayPattern() }}</h3>");
    _builder.newLineIfNotEmpty();
    {
      boolean _hasDisplayAction = this._controllerExtensions.hasDisplayAction(it);
      if (_hasDisplayAction) {
        _builder.append("    ");
        _builder.append("<p>");
        CharSequence _detailLink = this.detailLink(it, this._utils.appName(app));
        _builder.append(_detailLink, "    ");
        _builder.append("</p>");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("{% endfor %}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence fallbackDisplayTemplate(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{# Purpose of this template: Display objects within an external context #}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence editTemplate(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{* Purpose of this template: edit view of generic item list content type *}");
    _builder.newLine();
    CharSequence _editTemplateObjectType = this.editTemplateObjectType(it);
    _builder.append(_editTemplateObjectType);
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    {
      boolean _hasCategorisableEntities = this._modelBehaviourExtensions.hasCategorisableEntities(it);
      if (_hasCategorisableEntities) {
        CharSequence _editTemplateCategories = this.editTemplateCategories(it);
        _builder.append(_editTemplateCategories);
        _builder.newLineIfNotEmpty();
        _builder.newLine();
      }
    }
    CharSequence _editTemplateSorting = this.editTemplateSorting(it);
    _builder.append(_editTemplateSorting);
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    CharSequence _editTemplateAmount = this.editTemplateAmount(it);
    _builder.append(_editTemplateAmount);
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    CharSequence _editTemplateTemplate = this.editTemplateTemplate(it);
    _builder.append(_editTemplateTemplate);
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    CharSequence _editTemplateFilter = this.editTemplateFilter(it);
    _builder.append(_editTemplateFilter);
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("<script type=\"text/javascript\">");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("(function($) {");
    _builder.newLine();
    _builder.append("    \t");
    _builder.append("$(\'#");
    String _firstLower = StringExtensions.toFirstLower(this._utils.appName(it));
    _builder.append(_firstLower, "    \t");
    _builder.append("Template\').change(function() {");
    _builder.newLineIfNotEmpty();
    _builder.append("    \t    ");
    _builder.append("$(\'#customTemplateArea\').toggleClass(\'hidden\', $(this).val() != \'custom\');");
    _builder.newLine();
    _builder.append("\t    ");
    _builder.append("}).trigger(\'change\');");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("})(jQuery)");
    _builder.newLine();
    _builder.append("</script>");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence editTemplateObjectType(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("<div class=\"form-group\">");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{gt text=\'Object type\' domain=\'");
    String _formatForDB = this._formattingExtensions.formatForDB(this._utils.appName(it));
    _builder.append(_formatForDB, "    ");
    _builder.append("\' assign=\'objectTypeSelectorLabel\'}");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("{formlabel for=\'");
    String _firstLower = StringExtensions.toFirstLower(this._utils.appName(it));
    _builder.append(_firstLower, "    ");
    _builder.append("ObjectType\' text=$objectTypeSelectorLabel");
    CharSequence _editLabelClass = this.editLabelClass();
    _builder.append(_editLabelClass, "    ");
    _builder.append("}");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("<div class=\"col-sm-9\">");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("{");
    String _formatForDB_1 = this._formattingExtensions.formatForDB(this._utils.appName(it));
    _builder.append(_formatForDB_1, "        ");
    _builder.append("ObjectTypeSelector assign=\'allObjectTypes\'}");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("{formdropdownlist id=\'");
    String _firstLower_1 = StringExtensions.toFirstLower(this._utils.appName(it));
    _builder.append(_firstLower_1, "        ");
    _builder.append("ObjectType\' dataField=\'objectType\' group=\'data\' mandatory=true items=$allObjectTypes");
    CharSequence _editInputClass = this.editInputClass();
    _builder.append(_editInputClass, "        ");
    _builder.append("}");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("<span class=\"help-block\">{gt text=\'If you change this please save the element once to reload the parameters below.\' domain=\'");
    String _formatForDB_2 = this._formattingExtensions.formatForDB(this._utils.appName(it));
    _builder.append(_formatForDB_2, "        ");
    _builder.append("\'}</span>");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("</div>");
    _builder.newLine();
    _builder.append("</div>");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence editTemplateCategories(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{if $featureActivationHelper->isEnabled(constant(\'");
    String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(it.getVendor());
    _builder.append(_formatForCodeCapital);
    _builder.append("\\\\");
    String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital_1);
    _builder.append("Module\\\\Helper\\\\FeatureActivationHelper::CATEGORIES\'), $objectType)}");
    _builder.newLineIfNotEmpty();
    _builder.append("{formvolatile}");
    _builder.newLine();
    _builder.append("{if $properties ne null && is_array($properties)}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{nocache}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{foreach key=\'registryId\' item=\'registryCid\' from=$registries}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("{assign var=\'propName\' value=\'\'}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("{foreach key=\'propertyName\' item=\'propertyId\' from=$properties}");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("{if $propertyId eq $registryId}");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("{assign var=\'propName\' value=$propertyName}");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("{/if}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("{/foreach}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<div class=\"form-group\">");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("{assign var=\'hasMultiSelection\' value=$categoryHelper->hasMultipleSelection($objectType, $propertyName)}");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("{gt text=\'Category\' domain=\'");
    String _formatForDB = this._formattingExtensions.formatForDB(this._utils.appName(it));
    _builder.append(_formatForDB, "            ");
    _builder.append("\' assign=\'categorySelectorLabel\'}");
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    _builder.append("{assign var=\'selectionMode\' value=\'single\'}");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("{if $hasMultiSelection eq true}");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("{gt text=\'Categories\' domain=\'");
    String _formatForDB_1 = this._formattingExtensions.formatForDB(this._utils.appName(it));
    _builder.append(_formatForDB_1, "                ");
    _builder.append("\' assign=\'categorySelectorLabel\'}");
    _builder.newLineIfNotEmpty();
    _builder.append("                ");
    _builder.append("{assign var=\'selectionMode\' value=\'multiple\'}");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("{/if}");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("{formlabel for=\"");
    String _firstLower = StringExtensions.toFirstLower(this._utils.appName(it));
    _builder.append(_firstLower, "            ");
    _builder.append("CatIds`$propertyName`\" text=$categorySelectorLabel");
    CharSequence _editLabelClass = this.editLabelClass();
    _builder.append(_editLabelClass, "            ");
    _builder.append("}");
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    _builder.append("<div class=\"col-sm-9\">");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("{formdropdownlist id=\"");
    String _firstLower_1 = StringExtensions.toFirstLower(this._utils.appName(it));
    _builder.append(_firstLower_1, "                ");
    _builder.append("CatIds`$propName`\" items=$categories.$propName dataField=\"catids`$propName`\" group=\'data\' selectionMode=$selectionMode");
    CharSequence _editInputClass = this.editInputClass();
    _builder.append(_editInputClass, "                ");
    _builder.append("}");
    _builder.newLineIfNotEmpty();
    _builder.append("                ");
    _builder.append("<span class=\"help-block\">{gt text=\'This is an optional filter.\' domain=\'");
    String _formatForDB_2 = this._formattingExtensions.formatForDB(this._utils.appName(it));
    _builder.append(_formatForDB_2, "                ");
    _builder.append("\'}</span>");
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    _builder.append("</div>");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("</div>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{/foreach}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{/nocache}");
    _builder.newLine();
    _builder.append("{/if}");
    _builder.newLine();
    _builder.append("{/formvolatile}");
    _builder.newLine();
    _builder.append("{/if}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence editTemplateSorting(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("<div class=\"form-group\">");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{gt text=\'Sorting\' domain=\'");
    String _formatForDB = this._formattingExtensions.formatForDB(this._utils.appName(it));
    _builder.append(_formatForDB, "    ");
    _builder.append("\' assign=\'sortingLabel\'}");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("{formlabel text=$sortingLabel");
    CharSequence _editLabelClass = this.editLabelClass();
    _builder.append(_editLabelClass, "    ");
    _builder.append("}");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("<div class=\"col-sm-9\">");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("{formradiobutton id=\'");
    String _firstLower = StringExtensions.toFirstLower(this._utils.appName(it));
    _builder.append(_firstLower, "        ");
    _builder.append("SortRandom\' value=\'random\' dataField=\'sorting\' group=\'data\' mandatory=true}");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("{gt text=\'Random\' domain=\'");
    String _formatForDB_1 = this._formattingExtensions.formatForDB(this._utils.appName(it));
    _builder.append(_formatForDB_1, "        ");
    _builder.append("\' assign=\'sortingRandomLabel\'}");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("{formlabel for=\'");
    String _firstLower_1 = StringExtensions.toFirstLower(this._utils.appName(it));
    _builder.append(_firstLower_1, "        ");
    _builder.append("SortRandom\' text=$sortingRandomLabel}");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("{formradiobutton id=\'");
    String _firstLower_2 = StringExtensions.toFirstLower(this._utils.appName(it));
    _builder.append(_firstLower_2, "        ");
    _builder.append("SortNewest\' value=\'newest\' dataField=\'sorting\' group=\'data\' mandatory=true}");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("{gt text=\'Newest\' domain=\'");
    String _formatForDB_2 = this._formattingExtensions.formatForDB(this._utils.appName(it));
    _builder.append(_formatForDB_2, "        ");
    _builder.append("\' assign=\'sortingNewestLabel\'}");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("{formlabel for=\'");
    String _firstLower_3 = StringExtensions.toFirstLower(this._utils.appName(it));
    _builder.append(_firstLower_3, "        ");
    _builder.append("SortNewest\' text=$sortingNewestLabel}");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("{formradiobutton id=\'");
    String _firstLower_4 = StringExtensions.toFirstLower(this._utils.appName(it));
    _builder.append(_firstLower_4, "        ");
    _builder.append("SortDefault\' value=\'default\' dataField=\'sorting\' group=\'data\' mandatory=true}");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("{gt text=\'Default\' domain=\'");
    String _formatForDB_3 = this._formattingExtensions.formatForDB(this._utils.appName(it));
    _builder.append(_formatForDB_3, "        ");
    _builder.append("\' assign=\'sortingDefaultLabel\'}");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("{formlabel for=\'");
    String _firstLower_5 = StringExtensions.toFirstLower(this._utils.appName(it));
    _builder.append(_firstLower_5, "        ");
    _builder.append("SortDefault\' text=$sortingDefaultLabel}");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("</div>");
    _builder.newLine();
    _builder.append("</div>");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence editTemplateAmount(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("<div class=\"form-group\">");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{gt text=\'Amount\' domain=\'");
    String _formatForDB = this._formattingExtensions.formatForDB(this._utils.appName(it));
    _builder.append(_formatForDB, "    ");
    _builder.append("\' assign=\'amountLabel\'}");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("{formlabel for=\'");
    String _firstLower = StringExtensions.toFirstLower(this._utils.appName(it));
    _builder.append(_firstLower, "    ");
    _builder.append("Amount\' text=$amountLabel");
    CharSequence _editLabelClass = this.editLabelClass();
    _builder.append(_editLabelClass, "    ");
    _builder.append("}");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("<div class=\"col-sm-9\">");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("{formintinput id=\'");
    String _firstLower_1 = StringExtensions.toFirstLower(this._utils.appName(it));
    _builder.append(_firstLower_1, "        ");
    _builder.append("Amount\' dataField=\'amount\' group=\'data\' mandatory=true maxLength=2 cssClass=\'form-control\'}");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("</div>");
    _builder.newLine();
    _builder.append("</div>");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence editTemplateTemplate(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("<div class=\"form-group\">");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{gt text=\'Template\' domain=\'");
    String _formatForDB = this._formattingExtensions.formatForDB(this._utils.appName(it));
    _builder.append(_formatForDB, "    ");
    _builder.append("\' assign=\'templateLabel\'}");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("{formlabel for=\'");
    String _firstLower = StringExtensions.toFirstLower(this._utils.appName(it));
    _builder.append(_firstLower, "    ");
    _builder.append("Template\' text=$templateLabel");
    CharSequence _editLabelClass = this.editLabelClass();
    _builder.append(_editLabelClass, "    ");
    _builder.append("}");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("<div class=\"col-sm-9\">");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("{");
    String _formatForDB_1 = this._formattingExtensions.formatForDB(this._utils.appName(it));
    _builder.append(_formatForDB_1, "        ");
    _builder.append("TemplateSelector assign=\'allTemplates\'}");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("{formdropdownlist id=\'");
    String _firstLower_1 = StringExtensions.toFirstLower(this._utils.appName(it));
    _builder.append(_firstLower_1, "        ");
    _builder.append("Template\' dataField=\'template\' group=\'data\' mandatory=true items=$allTemplates");
    CharSequence _editInputClass = this.editInputClass();
    _builder.append(_editInputClass, "        ");
    _builder.append("}");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("</div>");
    _builder.newLine();
    _builder.append("</div>");
    _builder.newLine();
    _builder.newLine();
    _builder.append("<div id=\"customTemplateArea\" class=\"form-group\"{* data-switch=\"");
    String _firstLower_2 = StringExtensions.toFirstLower(this._utils.appName(it));
    _builder.append(_firstLower_2);
    _builder.append("Template\" data-switch-value=\"custom\"*}>");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("{gt text=\'Custom template\' domain=\'");
    String _formatForDB_2 = this._formattingExtensions.formatForDB(this._utils.appName(it));
    _builder.append(_formatForDB_2, "    ");
    _builder.append("\' assign=\'customTemplateLabel\'}");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("{formlabel for=\'");
    String _firstLower_3 = StringExtensions.toFirstLower(this._utils.appName(it));
    _builder.append(_firstLower_3, "    ");
    _builder.append("CustomTemplate\' text=$customTemplateLabel");
    CharSequence _editLabelClass_1 = this.editLabelClass();
    _builder.append(_editLabelClass_1, "    ");
    _builder.append("}");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("<div class=\"col-sm-9\">");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("{formtextinput id=\'");
    String _firstLower_4 = StringExtensions.toFirstLower(this._utils.appName(it));
    _builder.append(_firstLower_4, "        ");
    _builder.append("CustomTemplate\' dataField=\'customTemplate\' group=\'data\' mandatory=false maxLength=80");
    CharSequence _editInputClass_1 = this.editInputClass();
    _builder.append(_editInputClass_1, "        ");
    _builder.append("}");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("<span class=\"help-block\">{gt text=\'Example\' domain=\'");
    String _formatForDB_3 = this._formattingExtensions.formatForDB(this._utils.appName(it));
    _builder.append(_formatForDB_3, "        ");
    _builder.append("\'}: <em>itemlist_[objectType]_display.html.twig</em></span>");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("</div>");
    _builder.newLine();
    _builder.append("</div>");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence editTemplateFilter(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("<div class=\"form-group\">");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{gt text=\'Filter (expert option)\' domain=\'");
    String _formatForDB = this._formattingExtensions.formatForDB(this._utils.appName(it));
    _builder.append(_formatForDB, "    ");
    _builder.append("\' assign=\'filterLabel\'}");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("{formlabel for=\'");
    String _firstLower = StringExtensions.toFirstLower(this._utils.appName(it));
    _builder.append(_firstLower, "    ");
    _builder.append("Filter\' text=$filterLabel");
    CharSequence _editLabelClass = this.editLabelClass();
    _builder.append(_editLabelClass, "    ");
    _builder.append("}");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("<div class=\"col-sm-9\">");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("{formtextinput id=\'");
    String _firstLower_1 = StringExtensions.toFirstLower(this._utils.appName(it));
    _builder.append(_firstLower_1, "        ");
    _builder.append("Filter\' dataField=\'filter\' group=\'data\' mandatory=false maxLength=255");
    CharSequence _editInputClass = this.editInputClass();
    _builder.append(_editInputClass, "        ");
    _builder.append("}");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("{*<span class=\"help-block\">");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("<a class=\"fa fa-filter\" data-toggle=\"modal\" data-target=\"#filterSyntaxModal\">{gt text=\'Show syntax examples\' domain=\'");
    String _formatForDB_1 = this._formattingExtensions.formatForDB(this._utils.appName(it));
    _builder.append(_formatForDB_1, "            ");
    _builder.append("\'}</a>");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("</span>*}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("</div>");
    _builder.newLine();
    _builder.append("</div>");
    _builder.newLine();
    _builder.newLine();
    _builder.append("{*include file=\'include_filterSyntaxDialog.tpl\'*}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence detailLink(final Entity it, final String appName) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("<a href=\"{{ path(\'");
    String _formatForDB = this._formattingExtensions.formatForDB(appName);
    _builder.append(_formatForDB);
    _builder.append("_");
    String _formatForDB_1 = this._formattingExtensions.formatForDB(it.getName());
    _builder.append(_formatForDB_1);
    _builder.append("_display\'");
    CharSequence _routeParams = this._urlExtensions.routeParams(it, this._formattingExtensions.formatForCode(it.getName()), Boolean.valueOf(true));
    _builder.append(_routeParams);
    _builder.append(") }}\">{{ __(\'Read more\') }}</a>");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence editLabelClass() {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append(" ");
    _builder.append("cssClass=\'col-sm-3 control-label\'");
    return _builder;
  }
  
  private CharSequence editInputClass() {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append(" ");
    _builder.append("cssClass=\'form-control\'");
    return _builder;
  }
}
