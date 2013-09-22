package org.zikula.modulestudio.generator.cartridges.zclassic.view.additions;

import com.google.inject.Inject;
import de.guite.modulestudio.metamodel.modulestudio.Application;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class NewsletterView {
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
    String _xifexpression = null;
    boolean _targets = this._utils.targets(it, "1.3.5");
    boolean _not = (!_targets);
    if (_not) {
      _xifexpression = "Plugin";
    } else {
      _xifexpression = "";
    }
    final String pluginClassSuffix = _xifexpression;
    String _plus = ("ItemList" + pluginClassSuffix);
    final String templateFileName = (_plus + ".tpl");
    String _viewPath = this._namingExtensions.getViewPath(it);
    final String templatePath = (_viewPath + "plugin_config/");
    String _plus_1 = (templatePath + templateFileName);
    CharSequence _editTemplate = this.editTemplate(it);
    fsa.generateFile(_plus_1, _editTemplate);
  }
  
  private CharSequence editTemplate(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{* Purpose of this template: Display an edit form for configuring the newsletter plugin *}");
    _builder.newLine();
    _builder.append("{assign var=\'objectTypes\' value=$plugin_parameters.");
    String _appName = this._utils.appName(it);
    _builder.append(_appName, "");
    _builder.append("_NewsletterPlugin_ItemList.param.ObjectTypes}");
    _builder.newLineIfNotEmpty();
    _builder.append("{assign var=\'pageArgs\' value=$plugin_parameters.");
    String _appName_1 = this._utils.appName(it);
    _builder.append(_appName_1, "");
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
    {
      boolean _targets_1 = this._utils.targets(it, "1.3.5");
      if (_targets_1) {
        _builder.append("        ");
        _builder.append("<label for=\"plugin_{$i}_enable_{$j}\">{$objectTypeData.name|safetext}</label>");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("<input id=\"plugin_{$i}_enable_{$j}\" type=\"checkbox\" name=\"");
        String _appName_2 = this._utils.appName(it);
        _builder.append(_appName_2, "        ");
        _builder.append("ObjectTypes[{$objectType}]\" value=\"1\"{if $objectTypeData.nwactive} checked=\"checked\"{/if} />");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("        ");
        _builder.append("<div class=\"col-lg-offset-3 col-lg-9\">");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("<div class=\"checkbox\">");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("        ");
        _builder.append("<label>");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("            ");
        _builder.append("<input id=\"plugin_{$i}_enable_{$j}\" type=\"checkbox\" name=\"");
        String _appName_3 = this._utils.appName(it);
        _builder.append(_appName_3, "                    ");
        _builder.append("ObjectTypes[{$objectType}]\" value=\"1\"{if $objectTypeData.nwactive} checked=\"checked\"{/if} /> {$objectTypeData.name|safetext}");
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        _builder.append("        ");
        _builder.append("</label>");
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
    _builder.append("<div id=\"plugin_{$i}_suboption_{$j}\">");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<div class=\"");
    {
      boolean _targets_2 = this._utils.targets(it, "1.3.5");
      if (_targets_2) {
        _builder.append("z-formrow");
      } else {
        _builder.append("form-group");
      }
    }
    _builder.append("\">");
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    _builder.append("<label for=\"");
    String _appName_4 = this._utils.appName(it);
    _builder.append(_appName_4, "            ");
    _builder.append("Args_{$objectType}_sorting\"");
    {
      boolean _targets_3 = this._utils.targets(it, "1.3.5");
      boolean _not = (!_targets_3);
      if (_not) {
        _builder.append(" class=\"col-lg-3 control-label\"");
      }
    }
    _builder.append(">{gt text=\'Sorting\'}:</label>");
    _builder.newLineIfNotEmpty();
    {
      boolean _targets_4 = this._utils.targets(it, "1.3.5");
      boolean _not_1 = (!_targets_4);
      if (_not_1) {
        _builder.append("            ");
        _builder.append("<div class=\"col-lg-9\">");
        _builder.newLine();
      }
    }
    _builder.append("                ");
    _builder.append("<select name=\"");
    String _appName_5 = this._utils.appName(it);
    _builder.append(_appName_5, "                ");
    _builder.append("Args[{$objectType}][sorting]\" id=\"");
    String _appName_6 = this._utils.appName(it);
    _builder.append(_appName_6, "                ");
    _builder.append("Args_{$objectType}_sorting\"");
    {
      boolean _targets_5 = this._utils.targets(it, "1.3.5");
      boolean _not_2 = (!_targets_5);
      if (_not_2) {
        _builder.append(" class=\"form-control\"");
      }
    }
    _builder.append(">");
    _builder.newLineIfNotEmpty();
    _builder.append("                    ");
    _builder.append("<option value=\"random\"{if $pageArgs.$objectType.sorting eq \'random\'} selected=\"selected\"{/if}>{gt text=\'Random\'}</option>");
    _builder.newLine();
    _builder.append("                    ");
    _builder.append("<option value=\"newest\"{if $pageArgs.$objectType.sorting eq \'newest\'} selected=\"selected\"{/if}>{gt text=\'Newest\'}</option>");
    _builder.newLine();
    _builder.append("                    ");
    _builder.append("<option value=\"alpha\"{if $pageArgs.$objectType.sorting eq \'default\' || ($pageArgs.$objectType.sorting != \'random\' && $pageArgs.$objectType.sorting != \'newest\')} selected=\"selected\"{/if}>{gt text=\'Default\'}</option>");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("</select>");
    _builder.newLine();
    {
      boolean _targets_6 = this._utils.targets(it, "1.3.5");
      boolean _not_3 = (!_targets_6);
      if (_not_3) {
        _builder.append("            ");
        _builder.append("</div>");
        _builder.newLine();
      }
    }
    _builder.append("        ");
    _builder.append("</div>");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<div class=\"");
    {
      boolean _targets_7 = this._utils.targets(it, "1.3.5");
      if (_targets_7) {
        _builder.append("z-formrow");
      } else {
        _builder.append("form-group");
      }
    }
    _builder.append("\">");
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    _builder.append("<label for=\"");
    String _appName_7 = this._utils.appName(it);
    _builder.append(_appName_7, "            ");
    _builder.append("Args_{$objectType}_amount\"");
    {
      boolean _targets_8 = this._utils.targets(it, "1.3.5");
      boolean _not_4 = (!_targets_8);
      if (_not_4) {
        _builder.append(" class=\"col-lg-3 control-label\"");
      }
    }
    _builder.append(">{gt text=\'Amount\'}:</label>");
    _builder.newLineIfNotEmpty();
    {
      boolean _targets_9 = this._utils.targets(it, "1.3.5");
      boolean _not_5 = (!_targets_9);
      if (_not_5) {
        _builder.append("            ");
        _builder.append("<div class=\"col-lg-9\">");
        _builder.newLine();
      }
    }
    _builder.append("                ");
    _builder.append("<input type=\"text\" value=\"{$pageArgs.$objectType.amount|default:\'5\'}\" name=\"");
    String _appName_8 = this._utils.appName(it);
    _builder.append(_appName_8, "                ");
    _builder.append("Args[{$objectType}][amount]\" id=\"");
    String _appName_9 = this._utils.appName(it);
    _builder.append(_appName_9, "                ");
    _builder.append("Args_{$objectType}_amount\" maxlength=\"2\" size=\"10\"");
    {
      boolean _targets_10 = this._utils.targets(it, "1.3.5");
      boolean _not_6 = (!_targets_10);
      if (_not_6) {
        _builder.append(" class=\"form-control\"");
      }
    }
    _builder.append(" />");
    _builder.newLineIfNotEmpty();
    {
      boolean _targets_11 = this._utils.targets(it, "1.3.5");
      boolean _not_7 = (!_targets_11);
      if (_not_7) {
        _builder.append("            ");
        _builder.append("</div>");
        _builder.newLine();
      }
    }
    _builder.append("        ");
    _builder.append("</div>");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<div class=\"");
    {
      boolean _targets_12 = this._utils.targets(it, "1.3.5");
      if (_targets_12) {
        _builder.append("z-formrow z-hide");
      } else {
        _builder.append("form-group hide");
      }
    }
    _builder.append("\"");
    _builder.append(">");
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    _builder.append("<label for=\"");
    String _appName_10 = this._utils.appName(it);
    _builder.append(_appName_10, "            ");
    _builder.append("Args_{$objectType}_filter\"");
    {
      boolean _targets_13 = this._utils.targets(it, "1.3.5");
      boolean _not_8 = (!_targets_13);
      if (_not_8) {
        _builder.append(" class=\"col-lg-3 control-label\"");
      }
    }
    _builder.append(">{gt text=\'Filter (expert option)\'}:</label>");
    _builder.newLineIfNotEmpty();
    {
      boolean _targets_14 = this._utils.targets(it, "1.3.5");
      boolean _not_9 = (!_targets_14);
      if (_not_9) {
        _builder.append("            ");
        _builder.append("<div class=\"col-lg-9\">");
        _builder.newLine();
      }
    }
    _builder.append("                ");
    _builder.append("<input type=\"text\" value=\"{$pageArgs.$objectType.filter|default:\'\'}\" name=\"");
    String _appName_11 = this._utils.appName(it);
    _builder.append(_appName_11, "                ");
    _builder.append("Args[{$objectType}][filter]\" id=\"");
    String _appName_12 = this._utils.appName(it);
    _builder.append(_appName_12, "                ");
    _builder.append("Args_{$objectType}_filter\" size=\"40\"");
    {
      boolean _targets_15 = this._utils.targets(it, "1.3.5");
      boolean _not_10 = (!_targets_15);
      if (_not_10) {
        _builder.append(" class=\"form-control\"");
      }
    }
    _builder.append(" />");
    _builder.newLineIfNotEmpty();
    _builder.append("                ");
    _builder.append("<span class=\"");
    {
      boolean _targets_16 = this._utils.targets(it, "1.3.5");
      if (_targets_16) {
        _builder.append("z-sub z-formnote");
      } else {
        _builder.append("help-block");
      }
    }
    _builder.append("\">({gt text=\'Syntax examples\'}: <kbd>name:like:foobar</kbd> {gt text=\'or\'} <kbd>status:ne:3</kbd>)</span>");
    _builder.newLineIfNotEmpty();
    {
      boolean _targets_17 = this._utils.targets(it, "1.3.5");
      boolean _not_11 = (!_targets_17);
      if (_not_11) {
        _builder.append("            ");
        _builder.append("</div>");
        _builder.newLine();
      }
    }
    _builder.append("        ");
    _builder.append("</div>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("</div>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{assign var=\'j\' value=$j+1}");
    _builder.newLine();
    _builder.append("{foreachelse}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<div class=\"");
    {
      boolean _targets_18 = this._utils.targets(it, "1.3.5");
      if (_targets_18) {
        _builder.append("z-warningmsg");
      } else {
        _builder.append("alert alert-warningmsg");
      }
    }
    _builder.append("\">{gt text=\'No object types found.\'}</div>");
    _builder.newLineIfNotEmpty();
    _builder.append("{/foreach}");
    _builder.newLine();
    _builder.newLine();
    return _builder;
  }
}
