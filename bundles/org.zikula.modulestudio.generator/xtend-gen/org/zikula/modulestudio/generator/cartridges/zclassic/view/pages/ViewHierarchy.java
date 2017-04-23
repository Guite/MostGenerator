package org.zikula.modulestudio.generator.cartridges.zclassic.view.pages;

import com.google.common.base.Objects;
import de.guite.modulestudio.metamodel.Entity;
import de.guite.modulestudio.metamodel.EntityWorkflowType;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.InputOutput;
import org.eclipse.xtext.xbase.lib.StringExtensions;
import org.zikula.modulestudio.generator.extensions.ControllerExtensions;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;

@SuppressWarnings("all")
public class ViewHierarchy {
  @Extension
  private ControllerExtensions _controllerExtensions = new ControllerExtensions();
  
  @Extension
  private FormattingExtensions _formattingExtensions = new FormattingExtensions();
  
  @Extension
  private NamingExtensions _namingExtensions = new NamingExtensions();
  
  public void generate(final Entity it, final String appName, final IFileSystemAccess fsa) {
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(it.getName());
    String _plus = ("Generating tree view templates for entity \"" + _formatForDisplay);
    String _plus_1 = (_plus + "\"");
    InputOutput.<String>println(_plus_1);
    String templateFilePath = this._namingExtensions.templateFile(it, "viewTree");
    boolean _shouldBeSkipped = this._namingExtensions.shouldBeSkipped(it.getApplication(), templateFilePath);
    boolean _not = (!_shouldBeSkipped);
    if (_not) {
      fsa.generateFile(templateFilePath, this.hierarchyView(it, appName));
    }
    templateFilePath = this._namingExtensions.templateFile(it, "viewTreeItems");
    boolean _shouldBeSkipped_1 = this._namingExtensions.shouldBeSkipped(it.getApplication(), templateFilePath);
    boolean _not_1 = (!_shouldBeSkipped_1);
    if (_not_1) {
      fsa.generateFile(templateFilePath, this.hierarchyItemsView(it, appName));
    }
  }
  
  private CharSequence hierarchyView(final Entity it, final String appName) {
    StringConcatenation _builder = new StringConcatenation();
    final String objName = this._formattingExtensions.formatForCode(it.getName());
    _builder.newLineIfNotEmpty();
    _builder.append("{# purpose of this template: ");
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(it.getNameMultiple());
    _builder.append(_formatForDisplay);
    _builder.append(" tree view #}");
    _builder.newLineIfNotEmpty();
    _builder.append("{% extends routeArea == \'admin\' ? \'");
    _builder.append(appName);
    _builder.append("::adminBase.html.twig\' : \'");
    _builder.append(appName);
    _builder.append("::base.html.twig\' %}");
    _builder.newLineIfNotEmpty();
    _builder.append("{% block title __(\'");
    String _formatForDisplayCapital = this._formattingExtensions.formatForDisplayCapital(it.getName());
    _builder.append(_formatForDisplayCapital);
    _builder.append(" hierarchy\') %}");
    _builder.newLineIfNotEmpty();
    _builder.append("{% block adminPageIcon \'list-alt\' %}");
    _builder.newLine();
    _builder.append("{% block content %}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<div class=\"");
    String _lowerCase = appName.toLowerCase();
    _builder.append(_lowerCase, "    ");
    _builder.append("-");
    String _formatForDB = this._formattingExtensions.formatForDB(it.getName());
    _builder.append(_formatForDB, "    ");
    _builder.append(" ");
    String _lowerCase_1 = appName.toLowerCase();
    _builder.append(_lowerCase_1, "    ");
    _builder.append("-viewhierarchy\">");
    _builder.newLineIfNotEmpty();
    {
      if (((null != it.getDocumentation()) && (!Objects.equal(it.getDocumentation(), "")))) {
        _builder.newLine();
        _builder.append("        ");
        _builder.append("<p class=\"alert alert-info\">{{ __(\'");
        String _replace = it.getDocumentation().replace("\'", "\\\'");
        _builder.append(_replace, "        ");
        _builder.append("\') }}</p>");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<p>");
    _builder.newLine();
    {
      boolean _hasEditAction = this._controllerExtensions.hasEditAction(it);
      if (_hasEditAction) {
        _builder.append("            ");
        _builder.append("{% if hasPermission(\'");
        _builder.append(appName, "            ");
        _builder.append(":");
        String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(it.getName());
        _builder.append(_formatForCodeCapital, "            ");
        _builder.append(":\', \'::\', \'ACCESS_");
        {
          EntityWorkflowType _workflow = it.getWorkflow();
          boolean _equals = Objects.equal(_workflow, EntityWorkflowType.NONE);
          if (_equals) {
            _builder.append("EDIT");
          } else {
            _builder.append("COMMENT");
          }
        }
        _builder.append("\') %}");
        _builder.newLineIfNotEmpty();
        _builder.append("            ");
        _builder.append("    ");
        _builder.append("{% set addRootTitle = __(\'Add root node\') %}");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("    ");
        _builder.append("<a id=\"treeAddRoot\" href=\"javascript:void(0)\" title=\"{{ addRootTitle|e(\'html_attr\') }}\" class=\"fa fa-plus hidden\" data-object-type=\"");
        _builder.append(objName, "                ");
        _builder.append("\">{{ addRootTitle }}</a>");
        _builder.newLineIfNotEmpty();
        _builder.append("            ");
        _builder.append("{% endif %}");
        _builder.newLine();
      }
    }
    _builder.append("            ");
    _builder.append("{% set switchTitle = __(\'Switch to table view\') %}");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("<a href=\"{{ path(\'");
    String _formatForDB_1 = this._formattingExtensions.formatForDB(appName);
    _builder.append(_formatForDB_1, "            ");
    _builder.append("_");
    String _lowerCase_2 = objName.toLowerCase();
    _builder.append(_lowerCase_2, "            ");
    _builder.append("_\' ~ routeArea ~ \'view\') }}\" title=\"{{ switchTitle|e(\'html_attr\') }}\" class=\"fa fa-table\">{{ switchTitle }}</a>");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("</p>");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("{% for rootId, treeNodes in trees %}");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("{{ include(\'@");
    _builder.append(appName, "            ");
    _builder.append("/");
    String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital_1, "            ");
    _builder.append("/viewTreeItems.html.twig\', { rootId: rootId, items: treeNodes }) }}");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("{% else %}");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("{{ include(\'@");
    _builder.append(appName, "            ");
    _builder.append("/");
    String _formatForCodeCapital_2 = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital_2, "            ");
    _builder.append("/viewTreeItems.html.twig\', { rootId: 1, items: null }) }}");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("{% endfor %}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<br style=\"clear: left\" />");
    _builder.newLine();
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
    _builder.append("{{ pageAddAsset(\'stylesheet\', asset(\'jstree/dist/themes/default/style.min.css\')) }}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{{ pageAddAsset(\'javascript\', asset(\'jstree/dist/jstree.min.js\')) }}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{{ pageAddAsset(\'javascript\', zasset(\'@");
    _builder.append(appName, "    ");
    _builder.append(":js/");
    _builder.append(appName, "    ");
    _builder.append(".Tree.js\')) }}");
    _builder.newLineIfNotEmpty();
    _builder.append("{% endblock %}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence hierarchyItemsView(final Entity it, final String appName) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{# purpose of this template: ");
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(it.getNameMultiple());
    _builder.append(_formatForDisplay);
    _builder.append(" tree items #}");
    _builder.newLineIfNotEmpty();
    _builder.append("{% set hasNodes = items|default and items is iterable and items|length > 0 %}");
    _builder.newLine();
    _builder.append("{% set idPrefix = \'");
    String _firstLower = StringExtensions.toFirstLower(this._formattingExtensions.formatForCode(it.getName()));
    _builder.append(_firstLower);
    _builder.append("Tree\' ~ rootId %}");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("<p>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<label for=\"{{ idPrefix }}SearchTerm\">{{ __(\'Quick search\') }}:</label>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<input type=\"search\" id=\"{{ idPrefix }}SearchTerm\" value=\"\" />");
    _builder.newLine();
    _builder.append("</p>");
    _builder.newLine();
    _builder.newLine();
    _builder.append("<div class=\"btn-toolbar\" role=\"toolbar\" aria-label=\"category button toolbar\">");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<div class=\"btn-group btn-group-sm\" role=\"group\" aria-label=\"");
    String _formatForDB = this._formattingExtensions.formatForDB(it.getName());
    _builder.append(_formatForDB, "    ");
    _builder.append(" buttons\">");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("<button type=\"button\" id=\"{{ idPrefix }}Expand\" class=\"btn btn-info\" title=\"{{ __(\'Expand all nodes\') }}\"><i class=\"fa fa-expand\"></i> {{ __(\'Expand all\') }}</button>");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<button type=\"button\" id=\"{{ idPrefix }}Collapse\"class=\"btn btn-info\" title=\"{{ __(\'Collapse all nodes\') }}\"><i class=\"fa fa-compress\"></i> {{ __(\'Collapse all\') }}</button>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("</div>");
    _builder.newLine();
    _builder.append("</div>");
    _builder.newLine();
    _builder.append("<div id=\"{{ idPrefix }}\" class=\"tree-container\" data-object-type=\"");
    String _formatForCode = this._formattingExtensions.formatForCode(it.getName());
    _builder.append(_formatForCode);
    _builder.append("\" data-root-id=\"{{ rootId|e(\'html_attr\') }}\" data-has-display=\"");
    String _displayBool = this._formattingExtensions.displayBool(Boolean.valueOf(this._controllerExtensions.hasDisplayAction(it)));
    _builder.append(_displayBool);
    _builder.append("\" data-has-edit=\"");
    String _displayBool_1 = this._formattingExtensions.displayBool(Boolean.valueOf((this._controllerExtensions.hasEditAction(it) && (!it.isReadOnly()))));
    _builder.append(_displayBool_1);
    _builder.append("\">");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("{% if hasNodes %}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<ul id=\"itemTree{{ rootId|e(\'html_attr\') }}\">");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("{{ ");
    String _formatForDB_1 = this._formattingExtensions.formatForDB(appName);
    _builder.append(_formatForDB_1, "            ");
    _builder.append("_treeData(objectType=\'");
    String _formatForCode_1 = this._formattingExtensions.formatForCode(it.getName());
    _builder.append(_formatForCode_1, "            ");
    _builder.append("\', tree=items, routeArea=routeArea, rootId=rootId) }}");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("</ul>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{% endif %}");
    _builder.newLine();
    _builder.append("</div>");
    _builder.newLine();
    return _builder;
  }
}
