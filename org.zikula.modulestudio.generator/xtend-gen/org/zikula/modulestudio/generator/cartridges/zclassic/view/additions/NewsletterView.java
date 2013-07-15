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
    _builder.append("<div class=\"z-formrow\">");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<label for=\"plugin_{$i}_enable_{$j}\">{$objectTypeData.name|safetext}</label>");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<input id=\"plugin_{$i}_enable_{$j}\" type=\"checkbox\" name=\"");
    String _appName_2 = this._utils.appName(it);
    _builder.append(_appName_2, "        ");
    _builder.append("ObjectTypes[{$objectType}]\" value=\"1\"{if $objectTypeData.nwactive} checked=\"checked\"{/if} />");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("</div>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<div id=\"plugin_{$i}_suboption_{$j}\">");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<div class=\"z-formrow\">");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("<label for=\"");
    String _appName_3 = this._utils.appName(it);
    _builder.append(_appName_3, "            ");
    _builder.append("Args_{$objectType}_sorting\">{gt text=\'Sorting\'}:</label>");
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    _builder.append("<select name=\"");
    String _appName_4 = this._utils.appName(it);
    _builder.append(_appName_4, "            ");
    _builder.append("Args[{$objectType}][sorting]\" id=\"");
    String _appName_5 = this._utils.appName(it);
    _builder.append(_appName_5, "            ");
    _builder.append("Args_{$objectType}_sorting\">");
    _builder.newLineIfNotEmpty();
    _builder.append("                ");
    _builder.append("<option value=\"random\"{if $pageArgs.$objectType.sorting eq \'random\'} selected=\"selected\"{/if}>{gt text=\'Random\'}</option>");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("<option value=\"newest\"{if $pageArgs.$objectType.sorting eq \'newest\'} selected=\"selected\"{/if}>{gt text=\'Newest\'}</option>");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("<option value=\"alpha\"{if $pageArgs.$objectType.sorting eq \'default\' || ($pageArgs.$objectType.sorting != \'random\' && $pageArgs.$objectType.sorting != \'newest\')} selected=\"selected\"{/if}>{gt text=\'Default\'}</option>");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("</select>");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("</div>");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<div class=\"z-formrow\">");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("<label for=\"");
    String _appName_6 = this._utils.appName(it);
    _builder.append(_appName_6, "            ");
    _builder.append("Args_{$objectType}_amount\">{gt text=\'Amount\'}:</label>");
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    _builder.append("<input type=\"text\" value=\"{$pageArgs.$objectType.amount|default:\'5\'}\" name=\"");
    String _appName_7 = this._utils.appName(it);
    _builder.append(_appName_7, "            ");
    _builder.append("Args[{$objectType}][amount]\" id=\"");
    String _appName_8 = this._utils.appName(it);
    _builder.append(_appName_8, "            ");
    _builder.append("Args_{$objectType}_amount\" maxlength=\"2\" size=\"10\" />");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("</div>");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<div class=\"z-formrow z-hide\"");
    _builder.append(">");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("<label for=\"");
    String _appName_9 = this._utils.appName(it);
    _builder.append(_appName_9, "            ");
    _builder.append("Args_{$objectType}_filter\">{gt text=\'Filter (expert option)\'}:</label>");
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    _builder.append("<input type=\"text\" value=\"{$pageArgs.$objectType.filter|default:\'\'}\" name=\"");
    String _appName_10 = this._utils.appName(it);
    _builder.append(_appName_10, "            ");
    _builder.append("Args[{$objectType}][filter]\" id=\"");
    String _appName_11 = this._utils.appName(it);
    _builder.append(_appName_11, "            ");
    _builder.append("Args_{$objectType}_filter\" size=\"40\" />");
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    _builder.append("<span class=\"z-sub z-formnote\">({gt text=\'Syntax examples\'}: <kbd>name:like:foobar</kbd> {gt text=\'or\'} <kbd>status:ne:3</kbd>)</span>");
    _builder.newLine();
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
    _builder.append("<div class=\"z-warningmsg\">{gt text=\'No object types found.\'}</div>");
    _builder.newLine();
    _builder.append("{/foreach}");
    _builder.newLine();
    _builder.newLine();
    return _builder;
  }
}
