package org.zikula.modulestudio.generator.cartridges.zclassic.view.pages;

import com.google.common.base.Objects;
import com.google.inject.Inject;
import de.guite.modulestudio.metamodel.modulestudio.AdminController;
import de.guite.modulestudio.metamodel.modulestudio.Application;
import de.guite.modulestudio.metamodel.modulestudio.Controller;
import de.guite.modulestudio.metamodel.modulestudio.Entity;
import de.guite.modulestudio.metamodel.modulestudio.Models;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.eclipse.xtext.xbase.lib.InputOutput;
import org.eclipse.xtext.xbase.lib.StringExtensions;
import org.zikula.modulestudio.generator.extensions.ControllerExtensions;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class ViewHierarchy {
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
    String _plus_1 = (_plus + " tree view templates for entity \"");
    String _name = it.getName();
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(_name);
    String _plus_2 = (_plus_1 + _formatForDisplay);
    String _plus_3 = (_plus_2 + "\"");
    InputOutput.<String>println(_plus_3);
    String _name_1 = it.getName();
    String _templateFile = this._namingExtensions.templateFile(controller, _name_1, "view_tree");
    CharSequence _hierarchyView = this.hierarchyView(it, appName, controller);
    fsa.generateFile(_templateFile, _hierarchyView);
    String _name_2 = it.getName();
    String _templateFile_1 = this._namingExtensions.templateFile(controller, _name_2, "view_tree_items");
    CharSequence _hierarchyItemsView = this.hierarchyItemsView(it, appName, controller);
    fsa.generateFile(_templateFile_1, _hierarchyItemsView);
  }
  
  private CharSequence hierarchyView(final Entity it, final String appName, final Controller controller) {
    StringConcatenation _builder = new StringConcatenation();
    String _name = it.getName();
    final String objName = this._formattingExtensions.formatForCode(_name);
    _builder.newLineIfNotEmpty();
    Models _container = it.getContainer();
    Application _application = _container.getApplication();
    final String appPrefix = _application.getPrefix();
    _builder.newLineIfNotEmpty();
    _builder.append("{* purpose of this template: ");
    String _nameMultiple = it.getNameMultiple();
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(_nameMultiple);
    _builder.append(_formatForDisplay, "");
    _builder.append(" tree view in ");
    String _formattedName = this._controllerExtensions.formattedName(controller);
    _builder.append(_formattedName, "");
    _builder.append(" area *}");
    _builder.newLineIfNotEmpty();
    _builder.append("{include file=\'");
    {
      Models _container_1 = it.getContainer();
      Application _application_1 = _container_1.getApplication();
      boolean _targets = this._utils.targets(_application_1, "1.3.5");
      if (_targets) {
        String _formattedName_1 = this._controllerExtensions.formattedName(controller);
        _builder.append(_formattedName_1, "");
      } else {
        String _formattedName_2 = this._controllerExtensions.formattedName(controller);
        String _firstUpper = StringExtensions.toFirstUpper(_formattedName_2);
        _builder.append(_firstUpper, "");
      }
    }
    _builder.append("/header.tpl\'}");
    _builder.newLineIfNotEmpty();
    _builder.append("<div class=\"");
    String _lowerCase = appName.toLowerCase();
    _builder.append(_lowerCase, "");
    _builder.append("-");
    String _name_1 = it.getName();
    String _formatForDB = this._formattingExtensions.formatForDB(_name_1);
    _builder.append(_formatForDB, "");
    _builder.append(" ");
    String _lowerCase_1 = appName.toLowerCase();
    _builder.append(_lowerCase_1, "");
    _builder.append("-viewhierarchy\">");
    _builder.newLineIfNotEmpty();
    _builder.append("{gt text=\'");
    String _name_2 = it.getName();
    String _formatForDisplayCapital = this._formattingExtensions.formatForDisplayCapital(_name_2);
    _builder.append(_formatForDisplayCapital, "");
    _builder.append(" hierarchy\' assign=\'templateTitle\'}");
    _builder.newLineIfNotEmpty();
    _builder.append("{pagesetvar name=\'title\' value=$templateTitle}");
    _builder.newLine();
    CharSequence _templateHeader = this.templateHeader(controller);
    _builder.append(_templateHeader, "");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    {
      boolean _and = false;
      String _documentation = it.getDocumentation();
      boolean _tripleNotEquals = (_documentation != null);
      if (!_tripleNotEquals) {
        _and = false;
      } else {
        String _documentation_1 = it.getDocumentation();
        boolean _notEquals = (!Objects.equal(_documentation_1, ""));
        _and = (_tripleNotEquals && _notEquals);
      }
      if (_and) {
        _builder.append("<p class=\"sectiondesc\">");
        String _documentation_2 = it.getDocumentation();
        _builder.append(_documentation_2, "");
        _builder.append("</p>");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.newLine();
    _builder.append("<p>");
    _builder.newLine();
    {
      boolean _hasActions = this._controllerExtensions.hasActions(controller, "edit");
      if (_hasActions) {
        _builder.append("    ");
        _builder.append("{checkpermissionblock component=\'");
        _builder.append(appName, "    ");
        _builder.append(":");
        String _name_3 = it.getName();
        String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(_name_3);
        _builder.append(_formatForCodeCapital, "    ");
        _builder.append(":\' instance=\'::\' level=\'ACCESS_ADD\'}");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("{gt text=\'Add root node\' assign=\'addRootTitle\'}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("<a id=\"z-tree-addroot\" href=\"javascript:void(0)\" title=\"{$addRootTitle}\" class=\"z-icon-es-add z-hide\">{$addRootTitle}</a>");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("<script type=\"text/javascript\">");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("/* <![CDATA[ */");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("document.observe(\'dom:loaded\', function() {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("       ");
        _builder.append("$(\'z-tree-addroot\').observe(\'click\', function(event) {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("           ");
        _builder.append(appPrefix, "               ");
        _builder.append("PerformTreeOperation(\'");
        String _name_4 = it.getName();
        String _formatForCode = this._formattingExtensions.formatForCode(_name_4);
        _builder.append(_formatForCode, "               ");
        _builder.append("\', 1, \'addRootNode\');");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("           ");
        _builder.append("Event.stop(event);");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("       ");
        _builder.append("}).removeClassName(\'z-hide\');");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("});");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("/* ]]> */");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("</script>");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("<noscript><p>{gt text=\'This function requires JavaScript activated!\'}</p></noscript>");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("{*");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("{gt text=\'Create ");
        String _name_5 = it.getName();
        String _formatForDisplay_1 = this._formattingExtensions.formatForDisplay(_name_5);
        _builder.append(_formatForDisplay_1, "        ");
        _builder.append("\' assign=\'createTitle\'}");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("<a href=\"{modurl modname=\'");
        _builder.append(appName, "        ");
        _builder.append("\' type=\'");
        String _formattedName_3 = this._controllerExtensions.formattedName(controller);
        _builder.append(_formattedName_3, "        ");
        _builder.append("\' func=\'edit\' ot=\'");
        _builder.append(objName, "        ");
        _builder.append("\'}\" title=\"{$createTitle}\" class=\"z-icon-es-add\">");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("        ");
        _builder.append("{$createTitle}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("</a>");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("*}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("{/checkpermissionblock}");
        _builder.newLine();
      }
    }
    _builder.append("    ");
    _builder.append("{gt text=\'Switch to table view\' assign=\'switchTitle\'}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<a href=\"{modurl modname=\'");
    _builder.append(appName, "    ");
    _builder.append("\' type=\'");
    String _formattedName_4 = this._controllerExtensions.formattedName(controller);
    _builder.append(_formattedName_4, "    ");
    _builder.append("\' func=\'view\' ot=\'");
    _builder.append(objName, "    ");
    _builder.append("\'}\" title=\"{$switchTitle}\" class=\"z-icon-es-view\">{$switchTitle}</a>");
    _builder.newLineIfNotEmpty();
    _builder.append("</p>");
    _builder.newLine();
    _builder.newLine();
    _builder.append("{foreach key=\'rootId\' item=\'treeNodes\' from=$trees}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{include file=\'");
    {
      Models _container_2 = it.getContainer();
      Application _application_2 = _container_2.getApplication();
      boolean _targets_1 = this._utils.targets(_application_2, "1.3.5");
      if (_targets_1) {
        String _formattedName_5 = this._controllerExtensions.formattedName(controller);
        _builder.append(_formattedName_5, "    ");
        _builder.append("/");
        String _name_6 = it.getName();
        String _formatForCode_1 = this._formattingExtensions.formatForCode(_name_6);
        _builder.append(_formatForCode_1, "    ");
      } else {
        String _formattedName_6 = this._controllerExtensions.formattedName(controller);
        String _firstUpper_1 = StringExtensions.toFirstUpper(_formattedName_6);
        _builder.append(_firstUpper_1, "    ");
        _builder.append("/");
        String _name_7 = it.getName();
        String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(_name_7);
        _builder.append(_formatForCodeCapital_1, "    ");
      }
    }
    _builder.append("/view_tree_items.tpl\' rootId=$rootId items=$treeNodes}");
    _builder.newLineIfNotEmpty();
    _builder.append("{foreachelse}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{include file=\'");
    {
      Models _container_3 = it.getContainer();
      Application _application_3 = _container_3.getApplication();
      boolean _targets_2 = this._utils.targets(_application_3, "1.3.5");
      if (_targets_2) {
        String _formattedName_7 = this._controllerExtensions.formattedName(controller);
        _builder.append(_formattedName_7, "    ");
        _builder.append("/");
        String _name_8 = it.getName();
        String _formatForCode_2 = this._formattingExtensions.formatForCode(_name_8);
        _builder.append(_formatForCode_2, "    ");
      } else {
        String _formattedName_8 = this._controllerExtensions.formattedName(controller);
        String _firstUpper_2 = StringExtensions.toFirstUpper(_formattedName_8);
        _builder.append(_firstUpper_2, "    ");
        _builder.append("/");
        String _name_9 = it.getName();
        String _formatForCodeCapital_2 = this._formattingExtensions.formatForCodeCapital(_name_9);
        _builder.append(_formatForCodeCapital_2, "    ");
      }
    }
    _builder.append("/view_tree_items.tpl\' rootId=1 items=null}");
    _builder.newLineIfNotEmpty();
    _builder.append("{/foreach}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("<br style=\"clear: left\" />");
    _builder.newLine();
    _builder.newLine();
    CharSequence _templateFooter = this.templateFooter(controller);
    _builder.append(_templateFooter, "");
    _builder.newLineIfNotEmpty();
    _builder.append("</div>");
    _builder.newLine();
    _builder.append("{include file=\'");
    {
      Models _container_4 = it.getContainer();
      Application _application_4 = _container_4.getApplication();
      boolean _targets_3 = this._utils.targets(_application_4, "1.3.5");
      if (_targets_3) {
        String _formattedName_9 = this._controllerExtensions.formattedName(controller);
        _builder.append(_formattedName_9, "");
      } else {
        String _formattedName_10 = this._controllerExtensions.formattedName(controller);
        String _firstUpper_3 = StringExtensions.toFirstUpper(_formattedName_10);
        _builder.append(_firstUpper_3, "");
      }
    }
    _builder.append("/footer.tpl\'}");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence templateHeader(final Controller it) {
    CharSequence _switchResult = null;
    boolean _matched = false;
    if (!_matched) {
      if (it instanceof AdminController) {
        final AdminController _adminController = (AdminController)it;
        _matched=true;
        StringConcatenation _builder = new StringConcatenation();
        _builder.append("<div class=\"z-admin-content-pagetitle\">");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("{icon type=\'view\' size=\'small\' alt=$templateTitle}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("<h3>{$templateTitle}</h3>");
        _builder.newLine();
        _builder.append("</div>");
        _builder.newLine();
        _switchResult = _builder;
      }
    }
    if (!_matched) {
      StringConcatenation _builder = new StringConcatenation();
      _builder.append("<div class=\"z-frontendcontainer\">");
      _builder.newLine();
      _builder.append("    ");
      _builder.append("<h2>{$templateTitle}</h2>");
      _builder.newLine();
      _switchResult = _builder;
    }
    return _switchResult;
  }
  
  private CharSequence templateFooter(final Controller it) {
    CharSequence _switchResult = null;
    boolean _matched = false;
    if (!_matched) {
      if (it instanceof AdminController) {
        final AdminController _adminController = (AdminController)it;
        _matched=true;
        _switchResult = "";
      }
    }
    if (!_matched) {
      StringConcatenation _builder = new StringConcatenation();
      _builder.append("</div>");
      _builder.newLine();
      _switchResult = _builder;
    }
    return _switchResult;
  }
  
  private CharSequence hierarchyItemsView(final Entity it, final String appName, final Controller controller) {
    StringConcatenation _builder = new StringConcatenation();
    Models _container = it.getContainer();
    Application _application = _container.getApplication();
    final String appPrefix = _application.getPrefix();
    _builder.newLineIfNotEmpty();
    _builder.append("{* purpose of this template: ");
    String _nameMultiple = it.getNameMultiple();
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(_nameMultiple);
    _builder.append(_formatForDisplay, "");
    _builder.append(" tree items in ");
    String _formattedName = this._controllerExtensions.formattedName(controller);
    _builder.append(_formattedName, "");
    _builder.append(" area *}");
    _builder.newLineIfNotEmpty();
    _builder.append("{assign var=\'hasNodes\' value=false}");
    _builder.newLine();
    _builder.append("{if isset($items) && (is_object($items) && $items->count() gt 0) || (is_array($items) && count($items) gt 0)}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{assign var=\'hasNodes\' value=true}");
    _builder.newLine();
    _builder.append("{/if}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("{* initialise additional gettext domain for translations within javascript *}");
    _builder.newLine();
    _builder.append("{pageaddvar name=\'jsgettext\' value=\'module_");
    String _formatForDB = this._formattingExtensions.formatForDB(appName);
    _builder.append(_formatForDB, "");
    _builder.append("_js:");
    _builder.append(appName, "");
    _builder.append("\'}");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("<div id=\"");
    String _name = it.getName();
    String _formatForDB_1 = this._formattingExtensions.formatForDB(_name);
    _builder.append(_formatForDB_1, "");
    _builder.append("_tree{$rootId}\" class=\"z-treecontainer\">");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("<div id=\"treeitems{$rootId}\" class=\"z-treeitems\">");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{if $hasNodes}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("{");
    String _formatForDB_2 = this._formattingExtensions.formatForDB(appName);
    _builder.append(_formatForDB_2, "        ");
    _builder.append("TreeJS objectType=\'");
    String _name_1 = it.getName();
    String _formatForCode = this._formattingExtensions.formatForCode(_name_1);
    _builder.append(_formatForCode, "        ");
    _builder.append("\' tree=$items controller=\'");
    String _formattedName_1 = this._controllerExtensions.formattedName(controller);
    _builder.append(_formattedName_1, "        ");
    _builder.append("\' root=$rootId sortable=true}");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("{/if}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("</div>");
    _builder.newLine();
    _builder.append("</div>");
    _builder.newLine();
    _builder.newLine();
    _builder.append("{pageaddvar name=\'javascript\' value=\'modules/");
    _builder.append(appName, "");
    _builder.append("/");
    {
      Models _container_1 = it.getContainer();
      Application _application_1 = _container_1.getApplication();
      boolean _targets = this._utils.targets(_application_1, "1.3.5");
      if (_targets) {
        _builder.append("javascript/");
      } else {
        Models _container_2 = it.getContainer();
        Application _application_2 = _container_2.getApplication();
        String _appJsPath = this._namingExtensions.getAppJsPath(_application_2);
        _builder.append(_appJsPath, "");
      }
    }
    _builder.append(appName, "");
    _builder.append("_tree.js\'}");
    _builder.newLineIfNotEmpty();
    _builder.append("<script type=\"text/javascript\">");
    _builder.newLine();
    _builder.append("/* <![CDATA[ */");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("document.observe(\'dom:loaded\', function() {");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{{if $hasNodes}}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append(appPrefix, "        ");
    _builder.append("InitTreeNodes(\'");
    String _name_2 = it.getName();
    String _formatForCode_1 = this._formattingExtensions.formatForCode(_name_2);
    _builder.append(_formatForCode_1, "        ");
    _builder.append("\', \'");
    String _formattedName_2 = this._controllerExtensions.formattedName(controller);
    _builder.append(_formattedName_2, "        ");
    _builder.append("\', \'{{$rootId}}\', ");
    boolean _hasActions = this._controllerExtensions.hasActions(controller, "display");
    String _displayBool = this._formattingExtensions.displayBool(Boolean.valueOf(_hasActions));
    _builder.append(_displayBool, "        ");
    _builder.append(", ");
    boolean _and = false;
    boolean _hasActions_1 = this._controllerExtensions.hasActions(controller, "edit");
    if (!_hasActions_1) {
      _and = false;
    } else {
      boolean _isReadOnly = it.isReadOnly();
      boolean _not = (!_isReadOnly);
      _and = (_hasActions_1 && _not);
    }
    String _displayBool_1 = this._formattingExtensions.displayBool(Boolean.valueOf(_and));
    _builder.append(_displayBool_1, "        ");
    _builder.append(");");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("Zikula.TreeSortable.trees.itemtree{{$rootId}}.config.onSave = ");
    _builder.append(appPrefix, "        ");
    _builder.append("TreeSave;");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("{{/if}}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("});");
    _builder.newLine();
    _builder.append("/* ]]> */");
    _builder.newLine();
    _builder.append("</script>");
    _builder.newLine();
    _builder.append("<noscript><p>{gt text=\'This function requires JavaScript activated!\'}</p></noscript>");
    _builder.newLine();
    return _builder;
  }
}
