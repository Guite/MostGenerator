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
    _builder.append("<div class=\"");
    {
      boolean _targets = this._utils.targets(it, "1.3.5");
      if (_targets) {
        _builder.append("z-formrow");
      } else {
        _builder.append("form-group");
      }
    }
    _builder.append("\">");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("<label for=\"");
    String _appName = this._utils.appName(it);
    _builder.append(_appName, "    ");
    _builder.append("_objecttype\"");
    {
      boolean _targets_1 = this._utils.targets(it, "1.3.5");
      boolean _not = (!_targets_1);
      if (_not) {
        _builder.append(" class=\"col-lg-3 control-label\"");
      }
    }
    _builder.append(">{gt text=\'Object type\'}:</label>");
    _builder.newLineIfNotEmpty();
    {
      boolean _targets_2 = this._utils.targets(it, "1.3.5");
      boolean _not_1 = (!_targets_2);
      if (_not_1) {
        _builder.append("    ");
        _builder.append("<div class=\"col-lg-9\">");
        _builder.newLine();
      }
    }
    _builder.append("        ");
    _builder.append("<select id=\"");
    String _appName_1 = this._utils.appName(it);
    _builder.append(_appName_1, "        ");
    _builder.append("_objecttype\" name=\"objecttype\" size=\"1\"");
    {
      boolean _targets_3 = this._utils.targets(it, "1.3.5");
      boolean _not_2 = (!_targets_3);
      if (_not_2) {
        _builder.append(" class=\"form-control\"");
      }
    }
    _builder.append(">");
    _builder.newLineIfNotEmpty();
    {
      EList<Entity> _allEntities = this._modelExtensions.getAllEntities(it);
      for(final Entity entity : _allEntities) {
        _builder.append("            ");
        _builder.append("<option value=\"");
        String _name = entity.getName();
        String _formatForCode = this._formattingExtensions.formatForCode(_name);
        _builder.append(_formatForCode, "            ");
        _builder.append("\"{if $objectType eq \'");
        String _name_1 = entity.getName();
        String _formatForCode_1 = this._formattingExtensions.formatForCode(_name_1);
        _builder.append(_formatForCode_1, "            ");
        _builder.append("\'} selected=\"selected\"{/if}>{gt text=\'");
        String _nameMultiple = entity.getNameMultiple();
        String _formatForDisplayCapital = this._formattingExtensions.formatForDisplayCapital(_nameMultiple);
        _builder.append(_formatForDisplayCapital, "            ");
        _builder.append("\'}</option>");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("        ");
    _builder.append("</select>");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<span class=\"");
    {
      boolean _targets_4 = this._utils.targets(it, "1.3.5");
      if (_targets_4) {
        _builder.append("z-sub z-formnote");
      } else {
        _builder.append("help-block");
      }
    }
    _builder.append("\">{gt text=\'If you change this please save the block once to reload the parameters below.\'}</span>");
    _builder.newLineIfNotEmpty();
    {
      boolean _targets_5 = this._utils.targets(it, "1.3.5");
      boolean _not_3 = (!_targets_5);
      if (_not_3) {
        _builder.append("    ");
        _builder.append("</div>");
        _builder.newLine();
      }
    }
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
    _builder.append("<div class=\"");
    {
      boolean _targets_6 = this._utils.targets(it, "1.3.5");
      if (_targets_6) {
        _builder.append("z-formrow");
      } else {
        _builder.append("form-group");
      }
    }
    _builder.append("\">");
    _builder.newLineIfNotEmpty();
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
    _builder.append("<label for=\"{$categorySelectorId}{$propertyName}\"");
    {
      boolean _targets_7 = this._utils.targets(it, "1.3.5");
      boolean _not_4 = (!_targets_7);
      if (_not_4) {
        _builder.append(" class=\"col-lg-3 control-label\"");
      }
    }
    _builder.append(">{$categoryLabel}</label>");
    _builder.newLineIfNotEmpty();
    {
      boolean _targets_8 = this._utils.targets(it, "1.3.5");
      boolean _not_5 = (!_targets_8);
      if (_not_5) {
        _builder.append("            ");
        _builder.append("<div class=\"col-lg-9\">");
        _builder.newLine();
      } else {
        _builder.append("            ");
        _builder.append("&nbsp;");
        _builder.newLine();
      }
    }
    _builder.append("                ");
    _builder.append("{selector_category name=\"`$categorySelectorName``$propertyName`\" field=\'id\' selectedValue=$catIds.$propertyName categoryRegistryModule=\'");
    String _appName_3 = this._utils.appName(it);
    _builder.append(_appName_3, "                ");
    _builder.append("\' categoryRegistryTable=$objectType categoryRegistryProperty=$propertyName defaultText=$lblDefault editLink=false multipleSize=$categorySelectorSize}");
    _builder.newLineIfNotEmpty();
    _builder.append("                ");
    _builder.append("<span class=\"");
    {
      boolean _targets_9 = this._utils.targets(it, "1.3.5");
      if (_targets_9) {
        _builder.append("z-sub z-formnote");
      } else {
        _builder.append("help-block");
      }
    }
    _builder.append("\">{gt text=\'This is an optional filter.\'}</span>");
    _builder.newLineIfNotEmpty();
    {
      boolean _targets_10 = this._utils.targets(it, "1.3.5");
      boolean _not_6 = (!_targets_10);
      if (_not_6) {
        _builder.append("            ");
        _builder.append("</div>");
        _builder.newLine();
      }
    }
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
    _builder.append("<div class=\"");
    {
      boolean _targets_11 = this._utils.targets(it, "1.3.5");
      if (_targets_11) {
        _builder.append("z-formrow");
      } else {
        _builder.append("form-group");
      }
    }
    _builder.append("\">");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("<label for=\"");
    String _appName_4 = this._utils.appName(it);
    _builder.append(_appName_4, "    ");
    _builder.append("_sorting\"");
    {
      boolean _targets_12 = this._utils.targets(it, "1.3.5");
      boolean _not_7 = (!_targets_12);
      if (_not_7) {
        _builder.append(" class=\"col-lg-3 control-label\"");
      }
    }
    _builder.append(">{gt text=\'Sorting\'}:</label>");
    _builder.newLineIfNotEmpty();
    {
      boolean _targets_13 = this._utils.targets(it, "1.3.5");
      boolean _not_8 = (!_targets_13);
      if (_not_8) {
        _builder.append("    ");
        _builder.append("<div class=\"col-lg-9\">");
        _builder.newLine();
      }
    }
    _builder.append("        ");
    _builder.append("<select id=\"");
    String _appName_5 = this._utils.appName(it);
    _builder.append(_appName_5, "        ");
    _builder.append("_sorting\" name=\"sorting\"");
    {
      boolean _targets_14 = this._utils.targets(it, "1.3.5");
      boolean _not_9 = (!_targets_14);
      if (_not_9) {
        _builder.append(" class=\"form-control\"");
      }
    }
    _builder.append(">");
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    _builder.append("<option value=\"random\"{if $sorting eq \'random\'} selected=\"selected\"{/if}>{gt text=\'Random\'}</option>");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("<option value=\"newest\"{if $sorting eq \'newest\'} selected=\"selected\"{/if}>{gt text=\'Newest\'}</option>");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("<option value=\"alpha\"{if $sorting eq \'default\' || ($sorting != \'random\' && $sorting != \'newest\')} selected=\"selected\"{/if}>{gt text=\'Default\'}</option>");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("</select>");
    _builder.newLine();
    {
      boolean _targets_15 = this._utils.targets(it, "1.3.5");
      boolean _not_10 = (!_targets_15);
      if (_not_10) {
        _builder.append("    ");
        _builder.append("</div>");
        _builder.newLine();
      }
    }
    _builder.append("</div>");
    _builder.newLine();
    _builder.newLine();
    _builder.append("<div class=\"");
    {
      boolean _targets_16 = this._utils.targets(it, "1.3.5");
      if (_targets_16) {
        _builder.append("z-formrow");
      } else {
        _builder.append("form-group");
      }
    }
    _builder.append("\">");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("<label for=\"");
    String _appName_6 = this._utils.appName(it);
    _builder.append(_appName_6, "    ");
    _builder.append("_amount\"");
    {
      boolean _targets_17 = this._utils.targets(it, "1.3.5");
      boolean _not_11 = (!_targets_17);
      if (_not_11) {
        _builder.append(" class=\"col-lg-3 control-label\"");
      }
    }
    _builder.append(">{gt text=\'Amount\'}:</label>");
    _builder.newLineIfNotEmpty();
    {
      boolean _targets_18 = this._utils.targets(it, "1.3.5");
      boolean _not_12 = (!_targets_18);
      if (_not_12) {
        _builder.append("    ");
        _builder.append("<div class=\"col-lg-9\">");
        _builder.newLine();
      }
    }
    _builder.append("        ");
    _builder.append("<input type=\"text\" id=\"");
    String _appName_7 = this._utils.appName(it);
    _builder.append(_appName_7, "        ");
    _builder.append("_amount\" name=\"amount\" maxlength=\"2\" size=\"10\" value=\"{$amount|default:\"5\"}\"");
    {
      boolean _targets_19 = this._utils.targets(it, "1.3.5");
      boolean _not_13 = (!_targets_19);
      if (_not_13) {
        _builder.append(" class=\"form-control\"");
      }
    }
    _builder.append(" />");
    _builder.newLineIfNotEmpty();
    {
      boolean _targets_20 = this._utils.targets(it, "1.3.5");
      boolean _not_14 = (!_targets_20);
      if (_not_14) {
        _builder.append("    ");
        _builder.append("</div>");
        _builder.newLine();
      }
    }
    _builder.append("</div>");
    _builder.newLine();
    _builder.newLine();
    _builder.append("<div class=\"");
    {
      boolean _targets_21 = this._utils.targets(it, "1.3.5");
      if (_targets_21) {
        _builder.append("z-formrow");
      } else {
        _builder.append("form-group");
      }
    }
    _builder.append("\">");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("<label for=\"");
    String _appName_8 = this._utils.appName(it);
    _builder.append(_appName_8, "    ");
    _builder.append("_template\"");
    {
      boolean _targets_22 = this._utils.targets(it, "1.3.5");
      boolean _not_15 = (!_targets_22);
      if (_not_15) {
        _builder.append(" class=\"col-lg-3 control-label\"");
      }
    }
    _builder.append(">{gt text=\'Template\'}:</label>");
    _builder.newLineIfNotEmpty();
    {
      boolean _targets_23 = this._utils.targets(it, "1.3.5");
      boolean _not_16 = (!_targets_23);
      if (_not_16) {
        _builder.append("    ");
        _builder.append("<div class=\"col-lg-9\">");
        _builder.newLine();
      }
    }
    _builder.append("        ");
    _builder.append("<select id=\"");
    String _appName_9 = this._utils.appName(it);
    _builder.append(_appName_9, "        ");
    _builder.append("_template\" name=\"template\"");
    {
      boolean _targets_24 = this._utils.targets(it, "1.3.5");
      boolean _not_17 = (!_targets_24);
      if (_not_17) {
        _builder.append(" class=\"form-control\"");
      }
    }
    _builder.append(">");
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    _builder.append("<option value=\"itemlist_display.tpl\"{if $template eq \'itemlist_display.tpl\'} selected=\"selected\"{/if}>{gt text=\'Only item titles\'}</option>");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("<option value=\"itemlist_display_description.tpl\"{if $template eq \'itemlist_display_description.tpl\'} selected=\"selected\"{/if}>{gt text=\'With description\'}</option>");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("<option value=\"custom\"{if $template eq \'custom\'} selected=\"selected\"{/if}>{gt text=\'Custom template\'}</option>");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("</select>");
    _builder.newLine();
    {
      boolean _targets_25 = this._utils.targets(it, "1.3.5");
      boolean _not_18 = (!_targets_25);
      if (_not_18) {
        _builder.append("    ");
        _builder.append("</div>");
        _builder.newLine();
      }
    }
    _builder.append("</div>");
    _builder.newLine();
    _builder.newLine();
    _builder.append("<div id=\"customtemplatearea\" class=\"");
    {
      boolean _targets_26 = this._utils.targets(it, "1.3.5");
      if (_targets_26) {
        _builder.append("z-formrow z-hide");
      } else {
        _builder.append("form-group hide");
      }
    }
    _builder.append("\">");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("<label for=\"");
    String _appName_10 = this._utils.appName(it);
    _builder.append(_appName_10, "    ");
    _builder.append("_customtemplate\"");
    {
      boolean _targets_27 = this._utils.targets(it, "1.3.5");
      boolean _not_19 = (!_targets_27);
      if (_not_19) {
        _builder.append(" class=\"col-lg-3 control-label\"");
      }
    }
    _builder.append(">{gt text=\'Custom template\'}:</label>");
    _builder.newLineIfNotEmpty();
    {
      boolean _targets_28 = this._utils.targets(it, "1.3.5");
      boolean _not_20 = (!_targets_28);
      if (_not_20) {
        _builder.append("    ");
        _builder.append("<div class=\"col-lg-9\">");
        _builder.newLine();
      }
    }
    _builder.append("        ");
    _builder.append("<input type=\"text\" id=\"");
    String _appName_11 = this._utils.appName(it);
    _builder.append(_appName_11, "        ");
    _builder.append("__customtemplate\" name=\"customtemplate\" size=\"40\" maxlength=\"80\" value=\"{$customTemplate|default:\'\'}\"");
    {
      boolean _targets_29 = this._utils.targets(it, "1.3.5");
      boolean _not_21 = (!_targets_29);
      if (_not_21) {
        _builder.append(" class=\"form-control\"");
      }
    }
    _builder.append(" />");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("<span class=\"");
    {
      boolean _targets_30 = this._utils.targets(it, "1.3.5");
      if (_targets_30) {
        _builder.append("z-sub z-formnote");
      } else {
        _builder.append("help-block");
      }
    }
    _builder.append("\">{gt text=\'Example\'}: <em>itemlist_{$objecttype}_display.tpl</em></span>");
    _builder.newLineIfNotEmpty();
    {
      boolean _targets_31 = this._utils.targets(it, "1.3.5");
      boolean _not_22 = (!_targets_31);
      if (_not_22) {
        _builder.append("    ");
        _builder.append("</div>");
        _builder.newLine();
      }
    }
    _builder.append("</div>");
    _builder.newLine();
    _builder.newLine();
    _builder.append("<div class=\"");
    {
      boolean _targets_32 = this._utils.targets(it, "1.3.5");
      if (_targets_32) {
        _builder.append("z-formrow z-hide");
      } else {
        _builder.append("form-group hide");
      }
    }
    _builder.append("\"");
    _builder.append(">");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("<label for=\"");
    String _appName_12 = this._utils.appName(it);
    _builder.append(_appName_12, "    ");
    _builder.append("_filter\"");
    {
      boolean _targets_33 = this._utils.targets(it, "1.3.5");
      boolean _not_23 = (!_targets_33);
      if (_not_23) {
        _builder.append(" class=\"col-lg-3 control-label\"");
      }
    }
    _builder.append(">{gt text=\'Filter (expert option)\'}:</label>");
    _builder.newLineIfNotEmpty();
    {
      boolean _targets_34 = this._utils.targets(it, "1.3.5");
      boolean _not_24 = (!_targets_34);
      if (_not_24) {
        _builder.append("    ");
        _builder.append("<div class=\"col-lg-9\">");
        _builder.newLine();
      }
    }
    _builder.append("        ");
    _builder.append("<input type=\"text\" id=\"");
    String _appName_13 = this._utils.appName(it);
    _builder.append(_appName_13, "        ");
    _builder.append("_filter\" name=\"filter\" size=\"40\" value=\"{$filterValue|default:\'\'}\"");
    {
      boolean _targets_35 = this._utils.targets(it, "1.3.5");
      boolean _not_25 = (!_targets_35);
      if (_not_25) {
        _builder.append(" class=\"form-control\"");
      }
    }
    _builder.append(" />");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("<span class=\"");
    {
      boolean _targets_36 = this._utils.targets(it, "1.3.5");
      if (_targets_36) {
        _builder.append("z-sub z-formnote");
      } else {
        _builder.append("help-block");
      }
    }
    _builder.append("\">({gt text=\'Syntax examples\'}: <kbd>name:like:foobar</kbd> {gt text=\'or\'} <kbd>status:ne:3</kbd>)</span>");
    _builder.newLineIfNotEmpty();
    {
      boolean _targets_37 = this._utils.targets(it, "1.3.5");
      boolean _not_26 = (!_targets_37);
      if (_not_26) {
        _builder.append("    ");
        _builder.append("</div>");
        _builder.newLine();
      }
    }
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
    _builder.append("$(\'customtemplatearea\').removeClassName(\'");
    {
      boolean _targets_38 = this._utils.targets(it, "1.3.5");
      if (_targets_38) {
        _builder.append("z-");
      }
    }
    _builder.append("hide\');");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("} else {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$(\'customtemplatearea\').addClassName(\'");
    {
      boolean _targets_39 = this._utils.targets(it, "1.3.5");
      if (_targets_39) {
        _builder.append("z-");
      }
    }
    _builder.append("hide\');");
    _builder.newLineIfNotEmpty();
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
