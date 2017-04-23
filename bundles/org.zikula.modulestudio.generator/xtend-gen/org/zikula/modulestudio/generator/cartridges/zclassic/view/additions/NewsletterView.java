package org.zikula.modulestudio.generator.cartridges.zclassic.view.additions;

import de.guite.modulestudio.metamodel.Application;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.StringExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class NewsletterView {
  @Extension
  private NamingExtensions _namingExtensions = new NamingExtensions();
  
  @Extension
  private Utils _utils = new Utils();
  
  public void generate(final Application it, final IFileSystemAccess fsa) {
    final String pluginClassSuffix = "Plugin";
    String _viewPath = this._namingExtensions.getViewPath(it);
    final String templatePath = (_viewPath + "plugin_config/");
    String fileName = (("ItemList" + pluginClassSuffix) + ".tpl");
    boolean _shouldBeSkipped = this._namingExtensions.shouldBeSkipped(it, (templatePath + fileName));
    boolean _not = (!_shouldBeSkipped);
    if (_not) {
      boolean _shouldBeMarked = this._namingExtensions.shouldBeMarked(it, (templatePath + fileName));
      if (_shouldBeMarked) {
        fileName = (("ItemList" + pluginClassSuffix) + ".generated.tpl");
      }
      fsa.generateFile((templatePath + fileName), this.editTemplate(it));
    }
  }
  
  private CharSequence editTemplate(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{* Purpose of this template: Display an edit form for configuring the newsletter plugin *}");
    _builder.newLine();
    _builder.append("{assign var=\'objectTypes\' value=$plugin_parameters.");
    String _appName = this._utils.appName(it);
    _builder.append(_appName);
    _builder.append("_NewsletterPlugin_ItemList.param.ObjectTypes}");
    _builder.newLineIfNotEmpty();
    _builder.append("{assign var=\'pageArgs\' value=$plugin_parameters.");
    String _appName_1 = this._utils.appName(it);
    _builder.append(_appName_1);
    _builder.append("_NewsletterPlugin_ItemList.param.Args}");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("{assign var=\'j\' value=1}");
    _builder.newLine();
    _builder.append("{foreach key=\'objectType\' item=\'objectTypeData\' from=$objectTypes}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<hr />");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<div class=\"form-group\">");
    _builder.newLine();
    _builder.append("        ");
    CharSequence _editTemplateObjectTypes = this.editTemplateObjectTypes(it);
    _builder.append(_editTemplateObjectTypes, "        ");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("</div>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<div id=\"plugin_{$i}_suboption_{$j}\">");
    _builder.newLine();
    _builder.append("        ");
    CharSequence _editTemplateSorting = this.editTemplateSorting(it);
    _builder.append(_editTemplateSorting, "        ");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    CharSequence _editTemplateAmount = this.editTemplateAmount(it);
    _builder.append(_editTemplateAmount, "        ");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.newLine();
    _builder.append("        ");
    CharSequence _editTemplateFilter = this.editTemplateFilter(it);
    _builder.append(_editTemplateFilter, "        ");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("</div>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{assign var=\'j\' value=$j+1}");
    _builder.newLine();
    _builder.append("{foreachelse}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<p class=\"alert alert-warning\">{gt text=\'No object types found.\'}</p>");
    _builder.newLine();
    _builder.append("{/foreach}");
    _builder.newLine();
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence editTemplateObjectTypes(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("<div class=\"col-sm-offset-3 col-sm-9\">");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<div class=\"checkbox\">");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<label>");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("<input id=\"plugin_{$i}_enable_{$j}\" type=\"checkbox\" name=\"");
    String _appName = this._utils.appName(it);
    _builder.append(_appName, "            ");
    _builder.append("ObjectTypes[{$objectType}]\" value=\"1\"{if $objectTypeData.nwactive} checked=\"checked\"{/if} /> {$objectTypeData.name|safetext}");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("</label>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("</div>");
    _builder.newLine();
    _builder.append("</div>");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence editTemplateSorting(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("<div class=\"form-group\">");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<label for=\"");
    String _firstLower = StringExtensions.toFirstLower(this._utils.appName(it));
    _builder.append(_firstLower, "    ");
    _builder.append("Args_{$objectType}_sorting\" class=\"col-sm-3 control-label\">{gt text=\'Sorting\'}:</label>");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("<div class=\"col-sm-9\">");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<select id=\"");
    String _firstLower_1 = StringExtensions.toFirstLower(this._utils.appName(it));
    _builder.append(_firstLower_1, "        ");
    _builder.append("Args_{$objectType}_sorting\" name=\"");
    String _appName = this._utils.appName(it);
    _builder.append(_appName, "        ");
    _builder.append("Args[{$objectType}][sorting]\" class=\"form-control\">");
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    _builder.append("<option value=\"random\"{if $pageArgs.$objectType.sorting eq \'random\'} selected=\"selected\"{/if}>{gt text=\'Random\'}</option>");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("<option value=\"newest\"{if $pageArgs.$objectType.sorting eq \'newest\'} selected=\"selected\"{/if}>{gt text=\'Newest\'}</option>");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("<option value=\"alpha\"{if $pageArgs.$objectType.sorting eq \'default\' || ($pageArgs.$objectType.sorting != \'random\' && $pageArgs.$objectType.sorting != \'newest\')} selected=\"selected\"{/if}>{gt text=\'Default\'}</option>");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("</select>");
    _builder.newLine();
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
    _builder.append("<label for=\"");
    String _firstLower = StringExtensions.toFirstLower(this._utils.appName(it));
    _builder.append(_firstLower, "    ");
    _builder.append("Args_{$objectType}_amount\" class=\"col-sm-3 control-label\">{gt text=\'Amount\'}:</label>");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("<div class=\"col-sm-9\">");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<input type=\"text\" id=\"");
    String _firstLower_1 = StringExtensions.toFirstLower(this._utils.appName(it));
    _builder.append(_firstLower_1, "        ");
    _builder.append("Args_{$objectType}_amount\" name=\"");
    String _appName = this._utils.appName(it);
    _builder.append(_appName, "        ");
    _builder.append("Args[{$objectType}][amount]\" value=\"{$pageArgs.$objectType.amount|default:\'5\'}\" maxlength=\"2\" size=\"10\" class=\"form-control\" />");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("</div>");
    _builder.newLine();
    _builder.append("</div>");
    _builder.newLine();
    return _builder;
  }
  
  /**
   * def private editTemplateTemplate(Application it) '''
   * <div class="form-group">
   * <label for="«appName.toFirstLower»Args_{$objectType}_template" class="col-sm-3 control-label">{gt text='Template'}:</label>
   * <div class="col-sm-9">
   * <select id="«appName.toFirstLower»Args_{$objectType}_template" name="«appName»Args[{$objectType}][template]" class="form-control">
   * <option value="itemlist_display.tpl"{if $pageArgs.$objectType.template eq 'itemlist_display.tpl'} selected="selected"{/if}>{gt text='Only item titles'}</option>
   * <option value="itemlist_display_description.tpl"{if $pageArgs.$objectType.template eq 'itemlist_display_description.tpl'} selected="selected"{/if}>{gt text='With description'}</option>
   * <option value="custom"{if $pageArgs.$objectType.template eq 'custom'} selected="selected"{/if}>{gt text='Custom template'}</option>
   * </select>
   * <span class="help-block">{gt text='Only for HTML Newsletter'}</span>
   * </div>
   * </div>
   * <div id="customTemplateArea_{$objectType}" class="form-group" data-switch="«appName.toFirstLower»Args_{$objectType}_template" data-switch-value="custom">
   * <label for="«appName.toFirstLower»Args_{$objectType}_customtemplate" class="col-sm-3 control-label">{gt text='Custom template'}:</label>
   * <div class="col-sm-9">
   * <input type="text" id="«appName.toFirstLower»Args_{$objectType}_customtemplate" name="«appName»Args[{$objectType}][customtemplate]" value="{$pageArgs.$objectType.customtemplate|default:''}" maxlength="80" size="40" class="form-control" />
   * <span class="help-block">{gt text='Example'}: <em>itemlist_{objecttype}_display.tpl</em></span>
   * <span class="help-block">{gt text='Only for HTML Newsletter'}</span>
   * </div>
   * </div>
   * '''
   */
  private CharSequence editTemplateFilter(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("<div class=\"form-group\">");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<label for=\"");
    String _firstLower = StringExtensions.toFirstLower(this._utils.appName(it));
    _builder.append(_firstLower, "    ");
    _builder.append("Args_{$objectType}_filter\" class=\"col-sm-3 control-label\">{gt text=\'Filter (expert option)\'}:</label>");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("<div class=\"col-sm-9\">");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<input type=\"text\" id=\"");
    String _firstLower_1 = StringExtensions.toFirstLower(this._utils.appName(it));
    _builder.append(_firstLower_1, "        ");
    _builder.append("Args_{$objectType}_filter\" name=\"");
    String _appName = this._utils.appName(it);
    _builder.append(_appName, "        ");
    _builder.append("Args[{$objectType}][filter]\" value=\"{$pageArgs.$objectType.filter|default:\'\'}\" size=\"40\" class=\"form-control\" />");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("{*<span class=\"help-block\">");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("<a class=\"fa fa-filter\" data-toggle=\"modal\" data-target=\"#filterSyntaxModal\">{gt text=\'Show syntax examples\'}</a>");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("</span>*}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("</div>");
    _builder.newLine();
    _builder.append("</div>");
    _builder.newLine();
    return _builder;
  }
}
