package org.zikula.modulestudio.generator.cartridges.zclassic.view.additions;

import com.google.inject.Inject;
import de.guite.modulestudio.metamodel.modulestudio.Application;
import de.guite.modulestudio.metamodel.modulestudio.Entity;
import org.eclipse.emf.common.util.EList;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class BlocksView {
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
      _xifexpression = "block";
    } else {
      _xifexpression = "Block";
    }
    String _plus = (_viewPath + _xifexpression);
    final String templatePath = (_plus + "/");
    String _plus_1 = (templatePath + "itemlist.tpl");
    CharSequence _displayTemplate = this.displayTemplate(it);
    fsa.generateFile(_plus_1, _displayTemplate);
    String _plus_2 = (templatePath + "itemlist_modify.tpl");
    CharSequence _editTemplate = this.editTemplate(it);
    fsa.generateFile(_plus_2, _editTemplate);
  }
  
  private CharSequence displayTemplate(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{* Purpose of this template: Display items within a block (fallback template) *}");
    _builder.newLine();
    _builder.append("Default block for generic item list.");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence editTemplate(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{* Purpose of this template: Edit block for generic item list *}");
    _builder.newLine();
    _builder.append("<div class=\"z-formrow\">");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<label for=\"");
    String _appName = this._utils.appName(it);
    _builder.append(_appName, "    ");
    _builder.append("_objecttype\">{gt text=\'Object type\'}:</label>");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("<select id=\"");
    String _appName_1 = this._utils.appName(it);
    _builder.append(_appName_1, "    ");
    _builder.append("_objecttype\" name=\"objecttype\" size=\"1\">");
    _builder.newLineIfNotEmpty();
    {
      EList<Entity> _allEntities = this._modelExtensions.getAllEntities(it);
      for(final Entity entity : _allEntities) {
        _builder.append("        ");
        _builder.append("<option value=\"");
        String _name = entity.getName();
        String _formatForCode = this._formattingExtensions.formatForCode(_name);
        _builder.append(_formatForCode, "        ");
        _builder.append("\"{if $objectType eq \'");
        String _name_1 = entity.getName();
        String _formatForCode_1 = this._formattingExtensions.formatForCode(_name_1);
        _builder.append(_formatForCode_1, "        ");
        _builder.append("\'} selected=\"selected\"{/if}>{gt text=\'");
        String _nameMultiple = entity.getNameMultiple();
        String _formatForDisplayCapital = this._formattingExtensions.formatForDisplayCapital(_nameMultiple);
        _builder.append(_formatForDisplayCapital, "        ");
        _builder.append("\'}</option>");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("    ");
    _builder.append("</select>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<span class=\"z-sub z-formnote\">{gt text=\'If you change this please save the block once to reload the parameters below.\'}</span>");
    _builder.newLine();
    _builder.append("</div>");
    _builder.newLine();
    _builder.newLine();
    _builder.append("{if $properties ne null && is_array($properties)}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{gt text=\'All\' assign=\'lblDefault\'}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{nocache}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{foreach key=\'propertyName\' item=\'propertyId\' from=$properties}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<div class=\"z-formrow\">");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("{modapifunc modname=\'");
    String _appName_2 = this._utils.appName(it);
    _builder.append(_appName_2, "            ");
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
    _builder.append("{assign var=\'categorySelectorSize\' value=\'8\'}");
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
    _builder.append("{selector_category name=\"`$categorySelectorName``$propertyName`\" field=\'id\' selectedValue=$catIds.$propertyName categoryRegistryModule=\'");
    String _appName_3 = this._utils.appName(it);
    _builder.append(_appName_3, "            ");
    _builder.append("\' categoryRegistryTable=$objectType categoryRegistryProperty=$propertyName defaultText=$lblDefault editLink=false multipleSize=$categorySelectorSize}");
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    _builder.append("<span class=\"z-sub z-formnote\">{gt text=\'This is an optional filter.\'}</span>");
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
    _builder.newLine();
    _builder.append("<div class=\"z-formrow\">");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<label for=\"");
    String _appName_4 = this._utils.appName(it);
    _builder.append(_appName_4, "    ");
    _builder.append("_sorting\">{gt text=\'Sorting\'}:</label>");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("<select id=\"");
    String _appName_5 = this._utils.appName(it);
    _builder.append(_appName_5, "    ");
    _builder.append("_sorting\" name=\"sorting\">");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("<option value=\"random\"{if $sorting eq \'random\'} selected=\"selected\"{/if}>{gt text=\'Random\'}</option>");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<option value=\"newest\"{if $sorting eq \'newest\'} selected=\"selected\"{/if}>{gt text=\'Newest\'}</option>");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<option value=\"alpha\"{if $sorting eq \'default\' || ($sorting != \'random\' && $sorting != \'newest\')} selected=\"selected\"{/if}>{gt text=\'Default\'}</option>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("</select>");
    _builder.newLine();
    _builder.append("</div>");
    _builder.newLine();
    _builder.newLine();
    _builder.append("<div class=\"z-formrow\">");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<label for=\"");
    String _appName_6 = this._utils.appName(it);
    _builder.append(_appName_6, "    ");
    _builder.append("_amount\">{gt text=\'Amount\'}:</label>");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("<input type=\"text\" id=\"");
    String _appName_7 = this._utils.appName(it);
    _builder.append(_appName_7, "    ");
    _builder.append("_amount\" name=\"amount\" maxlength=\"2\" size=\"10\" value=\"{$amount|default:\"5\"}\" />");
    _builder.newLineIfNotEmpty();
    _builder.append("</div>");
    _builder.newLine();
    _builder.newLine();
    _builder.append("<div class=\"z-formrow\">");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<label for=\"");
    String _appName_8 = this._utils.appName(it);
    _builder.append(_appName_8, "    ");
    _builder.append("_template\">{gt text=\'Template\'}:</label>");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("<select id=\"");
    String _appName_9 = this._utils.appName(it);
    _builder.append(_appName_9, "    ");
    _builder.append("_template\" name=\"template\">");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("<option value=\"itemlist_display.tpl\"{if $template eq \'itemlist_display.tpl\'} selected=\"selected\"{/if}>{gt text=\'Only item titles\'}</option>");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<option value=\"itemlist_display_description.tpl\"{if $template eq \'itemlist_display_description.tpl\'} selected=\"selected\"{/if}>{gt text=\'With description\'}</option>");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<option value=\"custom\"{if $template eq \'custom\'} selected=\"selected\"{/if}>{gt text=\'Custom template\'}</option>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("</select>");
    _builder.newLine();
    _builder.append("</div>");
    _builder.newLine();
    _builder.newLine();
    _builder.append("<div id=\"customtemplatearea\" class=\"z-formrow z-hide\">");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<label for=\"");
    String _appName_10 = this._utils.appName(it);
    _builder.append(_appName_10, "    ");
    _builder.append("_customtemplate\">{gt text=\'Custom template\'}:</label>");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("<input type=\"text\" id=\"");
    String _appName_11 = this._utils.appName(it);
    _builder.append(_appName_11, "    ");
    _builder.append("__customtemplate\" name=\"customtemplate\" size=\"40\" maxlength=\"80\" value=\"{$customTemplate|default:\'\'}\" />");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("<span class=\"z-sub z-formnote\">{gt text=\'Example\'}: <em>itemlist_{$objecttype}_display.tpl</em></span>");
    _builder.newLine();
    _builder.append("</div>");
    _builder.newLine();
    _builder.newLine();
    _builder.append("<div class=\"z-formrow z-hide\"");
    _builder.append(">");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<label for=\"");
    String _appName_12 = this._utils.appName(it);
    _builder.append(_appName_12, "    ");
    _builder.append("_filter\">{gt text=\'Filter (expert option)\'}:</label>");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("<input type=\"text\" id=\"");
    String _appName_13 = this._utils.appName(it);
    _builder.append(_appName_13, "    ");
    _builder.append("_filter\" name=\"filter\" size=\"40\" value=\"{$filterValue|default:\'\'}\" />");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("<span class=\"z-sub z-formnote\">({gt text=\'Syntax examples\'}: <kbd>name:like:foobar</kbd> {gt text=\'or\'} <kbd>status:ne:3</kbd>)</span>");
    _builder.newLine();
    _builder.append("</div>");
    _builder.newLine();
    _builder.newLine();
    _builder.append("{pageaddvar name=\'javascript\' value=\'prototype\'}");
    _builder.newLine();
    _builder.append("<script type=\"text/javascript\">");
    _builder.newLine();
    _builder.append("/* <![CDATA[ */");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("function ");
    String _prefix = this._utils.prefix(it);
    _builder.append(_prefix, "    ");
    _builder.append("ToggleCustomTemplate() {");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("if ($F(\'");
    String _appName_14 = this._utils.appName(it);
    _builder.append(_appName_14, "        ");
    _builder.append("_template\') == \'custom\') {");
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    _builder.append("$(\'customtemplatearea\').removeClassName(\'z-hide\');");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("} else {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$(\'customtemplatearea\').addClassName(\'z-hide\');");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("document.observe(\'dom:loaded\', function() {");
    _builder.newLine();
    _builder.append("        ");
    String _prefix_1 = this._utils.prefix(it);
    _builder.append(_prefix_1, "        ");
    _builder.append("ToggleCustomTemplate();");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("$(\'");
    String _appName_15 = this._utils.appName(it);
    _builder.append(_appName_15, "        ");
    _builder.append("_template\').observe(\'change\', function(e) {");
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    String _prefix_2 = this._utils.prefix(it);
    _builder.append(_prefix_2, "            ");
    _builder.append("ToggleCustomTemplate();");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("});");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("});");
    _builder.newLine();
    _builder.append("/* ]]> */");
    _builder.newLine();
    _builder.append("</script>");
    _builder.newLine();
    return _builder;
  }
}
