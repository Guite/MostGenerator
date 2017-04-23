package org.zikula.modulestudio.generator.cartridges.zclassic.view.pages;

import com.google.common.base.Objects;
import com.google.common.collect.Iterables;
import de.guite.modulestudio.metamodel.BooleanField;
import de.guite.modulestudio.metamodel.DataObject;
import de.guite.modulestudio.metamodel.DecimalField;
import de.guite.modulestudio.metamodel.DerivedField;
import de.guite.modulestudio.metamodel.EmailField;
import de.guite.modulestudio.metamodel.Entity;
import de.guite.modulestudio.metamodel.EntityTreeType;
import de.guite.modulestudio.metamodel.EntityWorkflowType;
import de.guite.modulestudio.metamodel.FloatField;
import de.guite.modulestudio.metamodel.IntegerField;
import de.guite.modulestudio.metamodel.JoinRelationship;
import de.guite.modulestudio.metamodel.ListField;
import de.guite.modulestudio.metamodel.NamedObject;
import de.guite.modulestudio.metamodel.OneToManyRelationship;
import de.guite.modulestudio.metamodel.OneToOneRelationship;
import de.guite.modulestudio.metamodel.UrlField;
import java.util.Arrays;
import java.util.List;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.CollectionLiterals;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.InputOutput;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.eclipse.xtext.xbase.lib.ListExtensions;
import org.eclipse.xtext.xbase.lib.StringExtensions;
import org.zikula.modulestudio.generator.cartridges.zclassic.view.pagecomponents.ItemActionsView;
import org.zikula.modulestudio.generator.cartridges.zclassic.view.pagecomponents.SimpleFields;
import org.zikula.modulestudio.generator.cartridges.zclassic.view.pagecomponents.ViewQuickNavForm;
import org.zikula.modulestudio.generator.extensions.ControllerExtensions;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.UrlExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;
import org.zikula.modulestudio.generator.extensions.WorkflowExtensions;

@SuppressWarnings("all")
public class View {
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
  
  @Extension
  private WorkflowExtensions _workflowExtensions = new WorkflowExtensions();
  
  private SimpleFields fieldHelper = new SimpleFields();
  
  private Integer listType;
  
  private final static int LIST_TYPE_UL = 0;
  
  private final static int LIST_TYPE_OL = 1;
  
  private final static int LIST_TYPE_DL = 2;
  
  private final static int LIST_TYPE_TABLE = 3;
  
  public void generate(final Entity it, final String appName, final Integer listType, final IFileSystemAccess fsa) {
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(it.getName());
    String _plus = ("Generating view templates for entity \"" + _formatForDisplay);
    String _plus_1 = (_plus + "\"");
    InputOutput.<String>println(_plus_1);
    this.listType = listType;
    String templateFilePath = this._namingExtensions.templateFile(it, "view");
    boolean _shouldBeSkipped = this._namingExtensions.shouldBeSkipped(it.getApplication(), templateFilePath);
    boolean _not = (!_shouldBeSkipped);
    if (_not) {
      fsa.generateFile(templateFilePath, this.viewView(it, appName));
    }
    new ViewQuickNavForm().generate(it, appName, fsa);
    boolean _isLoggable = it.isLoggable();
    if (_isLoggable) {
      templateFilePath = this._namingExtensions.templateFile(it, "viewDeleted");
      boolean _shouldBeSkipped_1 = this._namingExtensions.shouldBeSkipped(it.getApplication(), templateFilePath);
      boolean _not_1 = (!_shouldBeSkipped_1);
      if (_not_1) {
        fsa.generateFile(templateFilePath, this.viewViewDeleted(it, appName));
      }
    }
  }
  
  private CharSequence viewView(final Entity it, final String appName) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{# purpose of this template: ");
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(it.getNameMultiple());
    _builder.append(_formatForDisplay);
    _builder.append(" list view #}");
    _builder.newLineIfNotEmpty();
    _builder.append("{% extends routeArea == \'admin\' ? \'");
    String _appName = this._utils.appName(it.getApplication());
    _builder.append(_appName);
    _builder.append("::adminBase.html.twig\' : \'");
    String _appName_1 = this._utils.appName(it.getApplication());
    _builder.append(_appName_1);
    _builder.append("::base.html.twig\' %}");
    _builder.newLineIfNotEmpty();
    _builder.append("{% block title own ? __(\'My ");
    String _formatForDisplay_1 = this._formattingExtensions.formatForDisplay(it.getNameMultiple());
    _builder.append(_formatForDisplay_1);
    _builder.append("\') : __(\'");
    String _formatForDisplayCapital = this._formattingExtensions.formatForDisplayCapital(it.getName());
    _builder.append(_formatForDisplayCapital);
    _builder.append(" list\') %}");
    _builder.newLineIfNotEmpty();
    _builder.append("{% block admin_page_icon \'list-alt\' %}");
    _builder.newLine();
    _builder.append("{% block content %}");
    _builder.newLine();
    _builder.append("<div class=\"");
    String _lowerCase = appName.toLowerCase();
    _builder.append(_lowerCase);
    _builder.append("-");
    String _formatForDB = this._formattingExtensions.formatForDB(it.getName());
    _builder.append(_formatForDB);
    _builder.append(" ");
    String _lowerCase_1 = appName.toLowerCase();
    _builder.append(_lowerCase_1);
    _builder.append("-view\">");
    _builder.newLineIfNotEmpty();
    {
      if (((null != it.getDocumentation()) && (!Objects.equal(it.getDocumentation(), "")))) {
        _builder.newLine();
        {
          boolean _isEmpty = this._formattingExtensions.containedTwigVariables(it.getDocumentation()).isEmpty();
          boolean _not = (!_isEmpty);
          if (_not) {
            _builder.append("    ");
            _builder.append("{{ __f(\'");
            String _replaceTwigVariablesForTranslation = this._formattingExtensions.replaceTwigVariablesForTranslation(it.getDocumentation().replace("\'", "\\\'"));
            _builder.append(_replaceTwigVariablesForTranslation, "    ");
            _builder.append("\', { ");
            final Function1<String, String> _function = (String v) -> {
              return (((("\'%" + v) + "%\': ") + v) + "|default");
            };
            String _join = IterableExtensions.join(ListExtensions.<String, String>map(this._formattingExtensions.containedTwigVariables(it.getDocumentation()), _function), ", ");
            _builder.append(_join, "    ");
            _builder.append(" }) }}");
            _builder.newLineIfNotEmpty();
          } else {
            _builder.append("    ");
            _builder.append("<p class=\"alert alert-info\">{{ __(\'");
            String _replace = it.getDocumentation().replace("\'", "\\\'");
            _builder.append(_replace, "    ");
            _builder.append("\') }}</p>");
            _builder.newLineIfNotEmpty();
          }
        }
      }
    }
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{{ block(\'page_nav_links\') }}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{{ include(\'@");
    String _appName_2 = this._utils.appName(it.getApplication());
    _builder.append(_appName_2, "    ");
    _builder.append("/");
    String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital, "    ");
    _builder.append("/viewQuickNav.html.twig\'");
    {
      boolean _hasVisibleWorkflow = this._workflowExtensions.hasVisibleWorkflow(it);
      boolean _not_1 = (!_hasVisibleWorkflow);
      if (_not_1) {
        _builder.append(", { workflowStateFilter: false }");
      }
    }
    _builder.append(") }}{# see template file for available options #}");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    CharSequence _viewForm = this.viewForm(it, appName);
    _builder.append(_viewForm, "    ");
    _builder.newLineIfNotEmpty();
    {
      boolean _isSkipHookSubscribers = it.isSkipHookSubscribers();
      boolean _not_2 = (!_isSkipHookSubscribers);
      if (_not_2) {
        _builder.newLine();
        _builder.append("    ");
        _builder.append("{{ block(\'display_hooks\') }}");
        _builder.newLine();
      }
    }
    _builder.append("</div>");
    _builder.newLine();
    _builder.append("{% endblock %}");
    _builder.newLine();
    _builder.append("{% block page_nav_links %}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<p>");
    _builder.newLine();
    _builder.append("        ");
    CharSequence _pageNavLinks = this.pageNavLinks(it, appName);
    _builder.append(_pageNavLinks, "        ");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("</p>");
    _builder.newLine();
    _builder.append("{% endblock %}");
    _builder.newLine();
    {
      boolean _isSkipHookSubscribers_1 = it.isSkipHookSubscribers();
      boolean _not_3 = (!_isSkipHookSubscribers_1);
      if (_not_3) {
        _builder.append("{% block display_hooks %}");
        _builder.newLine();
        _builder.append("    ");
        CharSequence _callDisplayHooks = this.callDisplayHooks(it, appName);
        _builder.append(_callDisplayHooks, "    ");
        _builder.newLineIfNotEmpty();
        _builder.append("{% endblock %}");
        _builder.newLine();
      }
    }
    return _builder;
  }
  
  private CharSequence pageNavLinks(final Entity it, final String appName) {
    StringConcatenation _builder = new StringConcatenation();
    final String objName = this._formattingExtensions.formatForCode(it.getName());
    _builder.newLineIfNotEmpty();
    {
      boolean _hasEditAction = this._controllerExtensions.hasEditAction(it);
      if (_hasEditAction) {
        _builder.append("{% if canBeCreated %}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("{% if hasPermission(\'");
        _builder.append(appName, "    ");
        _builder.append(":");
        String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(it.getName());
        _builder.append(_formatForCodeCapital, "    ");
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
        _builder.append("        ");
        _builder.append("{% set createTitle = __(\'Create ");
        String _formatForDisplay = this._formattingExtensions.formatForDisplay(it.getName());
        _builder.append(_formatForDisplay, "        ");
        _builder.append("\') %}");
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        _builder.append("<a href=\"{{ path(\'");
        String _formatForDB = this._formattingExtensions.formatForDB(appName);
        _builder.append(_formatForDB, "        ");
        _builder.append("_");
        String _lowerCase = objName.toLowerCase();
        _builder.append(_lowerCase, "        ");
        _builder.append("_\' ~ routeArea ~ \'edit\') }}\" title=\"{{ createTitle|e(\'html_attr\') }}\" class=\"fa fa-plus\">{{ createTitle }}</a>");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("{% endif %}");
        _builder.newLine();
        _builder.append("{% endif %}");
        _builder.newLine();
      }
    }
    _builder.append("{% if showAllEntries == 1 %}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{% set linkTitle = __(\'Back to paginated view\') %}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<a href=\"{{ path(\'");
    String _formatForDB_1 = this._formattingExtensions.formatForDB(appName);
    _builder.append(_formatForDB_1, "    ");
    _builder.append("_");
    String _lowerCase_1 = objName.toLowerCase();
    _builder.append(_lowerCase_1, "    ");
    _builder.append("_\' ~ routeArea ~ \'view\') }}\" title=\"{{ linkTitle|e(\'html_attr\') }}\" class=\"fa fa-table\">{{ linkTitle }}</a>");
    _builder.newLineIfNotEmpty();
    _builder.append("{% else %}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{% set linkTitle = __(\'Show all entries\') %}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<a href=\"{{ path(\'");
    String _formatForDB_2 = this._formattingExtensions.formatForDB(appName);
    _builder.append(_formatForDB_2, "    ");
    _builder.append("_");
    String _lowerCase_2 = objName.toLowerCase();
    _builder.append(_lowerCase_2, "    ");
    _builder.append("_\' ~ routeArea ~ \'view\', { all: 1 }) }}\" title=\"{{ linkTitle|e(\'html_attr\') }}\" class=\"fa fa-table\">{{ linkTitle }}</a>");
    _builder.newLineIfNotEmpty();
    _builder.append("{% endif %}");
    _builder.newLine();
    {
      EntityTreeType _tree = it.getTree();
      boolean _notEquals = (!Objects.equal(_tree, EntityTreeType.NONE));
      if (_notEquals) {
        _builder.append("{% set linkTitle = __(\'Switch to hierarchy view\') %}");
        _builder.newLine();
        _builder.append("<a href=\"{{ path(\'");
        String _formatForDB_3 = this._formattingExtensions.formatForDB(appName);
        _builder.append(_formatForDB_3);
        _builder.append("_");
        String _lowerCase_3 = objName.toLowerCase();
        _builder.append(_lowerCase_3);
        _builder.append("_\' ~ routeArea ~ \'view\', { tpl: \'tree\' }) }}\" title=\"{{ linkTitle|e(\'html_attr\') }}\" class=\"fa fa-code-fork\">{{ linkTitle }}</a>");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      boolean _isLoggable = it.isLoggable();
      if (_isLoggable) {
        _builder.append("{% if hasDeletedEntities and hasPermission(\'");
        _builder.append(appName);
        _builder.append(":");
        String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(it.getName());
        _builder.append(_formatForCodeCapital_1);
        _builder.append(":\', \'::\', \'ACCESS_EDIT\') %}");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("{% set linkTitle = __(\'View deleted ");
        String _formatForDisplay_1 = this._formattingExtensions.formatForDisplay(it.getNameMultiple());
        _builder.append(_formatForDisplay_1, "    ");
        _builder.append("\') %}");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("<a href=\"{{ path(\'");
        String _formatForDB_4 = this._formattingExtensions.formatForDB(appName);
        _builder.append(_formatForDB_4, "    ");
        _builder.append("_");
        String _lowerCase_4 = objName.toLowerCase();
        _builder.append(_lowerCase_4, "    ");
        _builder.append("_\' ~ routeArea ~ \'view\', { deleted: 1 }) }}\" title=\"{{ linkTitle|e(\'html_attr\') }}\" class=\"fa fa-trash-o\">{{ linkTitle }}</a>");
        _builder.newLineIfNotEmpty();
        _builder.append("{% endif %}");
        _builder.newLine();
      }
    }
    return _builder;
  }
  
  private CharSequence viewForm(final Entity it, final String appName) {
    StringConcatenation _builder = new StringConcatenation();
    {
      if (((this.listType).intValue() == View.LIST_TYPE_TABLE)) {
        _builder.append("{% if routeArea == \'admin\' %}");
        _builder.newLine();
        _builder.append("<form action=\"{{ path(\'");
        String _formatForDB = this._formattingExtensions.formatForDB(appName);
        _builder.append(_formatForDB);
        _builder.append("_");
        String _formatForDB_1 = this._formattingExtensions.formatForDB(it.getName());
        _builder.append(_formatForDB_1);
        _builder.append("_\' ~ routeArea ~ \'handleselectedentries\') }}\" method=\"post\" id=\"");
        String _formatForCode = this._formattingExtensions.formatForCode(it.getNameMultiple());
        _builder.append(_formatForCode);
        _builder.append("ViewForm\" class=\"form-horizontal\" role=\"form\">");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("<div>");
        _builder.newLine();
        _builder.append("{% endif %}");
        _builder.newLine();
      }
    }
    _builder.append("    ");
    CharSequence _viewItemList = this.viewItemList(it, appName);
    _builder.append(_viewItemList, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    CharSequence _pagerCall = this.pagerCall(it, appName);
    _builder.append(_pagerCall, "    ");
    _builder.newLineIfNotEmpty();
    {
      if (((this.listType).intValue() == View.LIST_TYPE_TABLE)) {
        _builder.append("{% if routeArea == \'admin\' %}");
        _builder.newLine();
        _builder.append("        ");
        CharSequence _massActionFields = this.massActionFields(it, appName);
        _builder.append(_massActionFields, "        ");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("</div>");
        _builder.newLine();
        _builder.append("</form>");
        _builder.newLine();
        _builder.append("{% endif %}");
        _builder.newLine();
      }
    }
    return _builder;
  }
  
  private CharSequence viewItemList(final Entity it, final String appName) {
    StringConcatenation _builder = new StringConcatenation();
    final List<DerivedField> listItemsFields = this._modelExtensions.getFieldsForViewPage(it);
    _builder.newLineIfNotEmpty();
    final Function1<OneToManyRelationship, Boolean> _function = (OneToManyRelationship it_1) -> {
      return Boolean.valueOf((it_1.isBidirectional() && (it_1.getSource() instanceof Entity)));
    };
    final Iterable<OneToManyRelationship> listItemsIn = IterableExtensions.<OneToManyRelationship>filter(Iterables.<OneToManyRelationship>filter(it.getIncoming(), OneToManyRelationship.class), _function);
    _builder.newLineIfNotEmpty();
    final Function1<OneToOneRelationship, Boolean> _function_1 = (OneToOneRelationship it_1) -> {
      DataObject _target = it_1.getTarget();
      return Boolean.valueOf((_target instanceof Entity));
    };
    final Iterable<OneToOneRelationship> listItemsOut = IterableExtensions.<OneToOneRelationship>filter(Iterables.<OneToOneRelationship>filter(it.getOutgoing(), OneToOneRelationship.class), _function_1);
    _builder.newLineIfNotEmpty();
    CharSequence _viewItemListHeader = this.viewItemListHeader(it, appName, listItemsFields, listItemsIn, listItemsOut);
    _builder.append(_viewItemListHeader);
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    CharSequence _viewItemListBody = this.viewItemListBody(it, appName, listItemsFields, listItemsIn, listItemsOut);
    _builder.append(_viewItemListBody);
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    CharSequence _viewItemListFooter = this.viewItemListFooter(it);
    _builder.append(_viewItemListFooter);
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence viewItemListHeader(final Entity it, final String appName, final List<DerivedField> listItemsFields, final Iterable<OneToManyRelationship> listItemsIn, final Iterable<OneToOneRelationship> listItemsOut) {
    StringConcatenation _builder = new StringConcatenation();
    {
      if (((this.listType).intValue() != View.LIST_TYPE_TABLE)) {
        _builder.append("<");
        String _asListTag = this.asListTag(this.listType);
        _builder.append(_asListTag);
        _builder.append(">");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("<div class=\"table-responsive\">");
        _builder.newLine();
        _builder.append("<table class=\"table table-striped table-bordered table-hover");
        {
          int _size = listItemsFields.size();
          int _size_1 = IterableExtensions.size(listItemsIn);
          int _plus = (_size + _size_1);
          int _size_2 = IterableExtensions.size(listItemsOut);
          int _plus_1 = (_plus + _size_2);
          int _plus_2 = (_plus_1 + 1);
          boolean _greaterThan = (_plus_2 > 7);
          if (_greaterThan) {
            _builder.append(" table-condensed");
          } else {
            _builder.append("{% if routeArea == \'admin\' %} table-condensed{% endif %}");
          }
        }
        _builder.append("\">");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("<colgroup>");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("{% if routeArea == \'admin\' %}");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("<col id=\"cSelect\" />");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("{% endif %}");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("<col id=\"cItemActions\" />");
        _builder.newLine();
        _builder.append("        ");
        {
          for(final DerivedField field : listItemsFields) {
            CharSequence _columnDef = this.columnDef(field);
            _builder.append(_columnDef, "        ");
          }
        }
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        {
          for(final OneToManyRelationship relation : listItemsIn) {
            CharSequence _columnDef_1 = this.columnDef(relation, Boolean.valueOf(false));
            _builder.append(_columnDef_1, "        ");
          }
        }
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        {
          for(final OneToOneRelationship relation_1 : listItemsOut) {
            CharSequence _columnDef_2 = this.columnDef(relation_1, Boolean.valueOf(true));
            _builder.append(_columnDef_2, "        ");
          }
        }
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("</colgroup>");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("<thead>");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("<tr>");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("{% if routeArea == \'admin\' %}");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("<th id=\"hSelect\" scope=\"col\" class=\"{% if items|length > 0 %}fixed-column {% endif %}text-center z-w02\">");
        _builder.newLine();
        _builder.append("                ");
        _builder.append("<input type=\"checkbox\" class=\"");
        String _lowerCase = this._utils.vendorAndName(it.getApplication()).toLowerCase();
        _builder.append(_lowerCase, "                ");
        _builder.append("-mass-toggle\" />");
        _builder.newLineIfNotEmpty();
        _builder.append("            ");
        _builder.append("</th>");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("{% endif %}");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("<th id=\"hItemActions\" scope=\"col\" class=\"{% if items|length > 0 %}fixed-column {% endif %}z-order-unsorted z-w02\">{{ __(\'Actions\') }}</th>");
        _builder.newLine();
        _builder.append("        ");
        {
          for(final DerivedField field_1 : listItemsFields) {
            CharSequence _headerLine = this.headerLine(field_1);
            _builder.append(_headerLine, "        ");
          }
        }
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        {
          for(final OneToManyRelationship relation_2 : listItemsIn) {
            CharSequence _headerLine_1 = this.headerLine(relation_2, Boolean.valueOf(false));
            _builder.append(_headerLine_1, "        ");
          }
        }
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        {
          for(final OneToOneRelationship relation_3 : listItemsOut) {
            CharSequence _headerLine_2 = this.headerLine(relation_3, Boolean.valueOf(true));
            _builder.append(_headerLine_2, "        ");
          }
        }
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("</tr>");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("</thead>");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("<tbody>");
        _builder.newLine();
      }
    }
    return _builder;
  }
  
  private CharSequence viewItemListBody(final Entity it, final String appName, final List<DerivedField> listItemsFields, final Iterable<OneToManyRelationship> listItemsIn, final Iterable<OneToOneRelationship> listItemsOut) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{% for ");
    String _formatForCode = this._formattingExtensions.formatForCode(it.getName());
    _builder.append(_formatForCode);
    _builder.append(" in items %}");
    _builder.newLineIfNotEmpty();
    {
      if ((((this.listType).intValue() == View.LIST_TYPE_UL) || ((this.listType).intValue() == View.LIST_TYPE_OL))) {
        _builder.append("    ");
        _builder.append("<li><ul>");
        _builder.newLine();
      } else {
        if (((this.listType).intValue() == View.LIST_TYPE_DL)) {
          _builder.append("    ");
          _builder.append("<dt>");
          _builder.newLine();
        } else {
          if (((this.listType).intValue() == View.LIST_TYPE_TABLE)) {
            _builder.append("    ");
            _builder.append("<tr>");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("{% if routeArea == \'admin\' %}");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("        ");
            _builder.append("<td headers=\"hSelect\" class=\"fixed-column text-center z-w02\">");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("            ");
            _builder.append("<input type=\"checkbox\" name=\"items[]\" value=\"{{ ");
            String _formatForCode_1 = this._formattingExtensions.formatForCode(it.getName());
            _builder.append(_formatForCode_1, "                ");
            _builder.append(".");
            String _formatForCode_2 = this._formattingExtensions.formatForCode(IterableExtensions.<DerivedField>head(this._modelExtensions.getPrimaryKeyFields(it)).getName());
            _builder.append(_formatForCode_2, "                ");
            _builder.append(" }}\" class=\"");
            String _lowerCase = this._utils.vendorAndName(it.getApplication()).toLowerCase();
            _builder.append(_lowerCase, "                ");
            _builder.append("-toggle-checkbox\" />");
            _builder.newLineIfNotEmpty();
            _builder.append("    ");
            _builder.append("        ");
            _builder.append("</td>");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("{% endif %}");
            _builder.newLine();
          }
        }
      }
    }
    _builder.append("        ");
    CharSequence _itemActions = this.itemActions(it, appName);
    _builder.append(_itemActions, "        ");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    {
      for(final DerivedField field : listItemsFields) {
        {
          String _name = field.getName();
          boolean _equals = Objects.equal(_name, "workflowState");
          if (_equals) {
            _builder.append("{% if routeArea == \'admin\' %}");
          }
        }
        CharSequence _displayEntry = this.displayEntry(field, Boolean.valueOf(false));
        _builder.append(_displayEntry, "        ");
        {
          String _name_1 = field.getName();
          boolean _equals_1 = Objects.equal(_name_1, "workflowState");
          if (_equals_1) {
            _builder.append("{% endif %}");
          }
        }
      }
    }
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    {
      for(final OneToManyRelationship relation : listItemsIn) {
        CharSequence _displayEntry_1 = this.displayEntry(relation, Boolean.valueOf(false));
        _builder.append(_displayEntry_1, "        ");
      }
    }
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    {
      for(final OneToOneRelationship relation_1 : listItemsOut) {
        CharSequence _displayEntry_2 = this.displayEntry(relation_1, Boolean.valueOf(true));
        _builder.append(_displayEntry_2, "        ");
      }
    }
    _builder.newLineIfNotEmpty();
    {
      if ((((this.listType).intValue() == View.LIST_TYPE_UL) || ((this.listType).intValue() == View.LIST_TYPE_OL))) {
        _builder.append("    ");
        _builder.append("</ul></li>");
        _builder.newLine();
      } else {
        if (((this.listType).intValue() == View.LIST_TYPE_DL)) {
          _builder.append("    ");
          _builder.append("</dt>");
          _builder.newLine();
        } else {
          if (((this.listType).intValue() == View.LIST_TYPE_TABLE)) {
            _builder.append("    ");
            _builder.append("</tr>");
            _builder.newLine();
          }
        }
      }
    }
    _builder.append("{% else %}");
    _builder.newLine();
    {
      if ((((this.listType).intValue() == View.LIST_TYPE_UL) || ((this.listType).intValue() == View.LIST_TYPE_OL))) {
        _builder.append("    ");
        _builder.append("<li>");
        _builder.newLine();
      } else {
        if (((this.listType).intValue() == View.LIST_TYPE_DL)) {
          _builder.append("    ");
          _builder.append("<dt>");
          _builder.newLine();
        } else {
          if (((this.listType).intValue() == View.LIST_TYPE_TABLE)) {
            _builder.append("    ");
            _builder.append("<tr class=\"z-{{ routeArea == \'admin\' ? \'admin\' : \'data\' }}tableempty\">");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("    ", "    ");
            _builder.append("<td class=\"text-left\" colspan=\"{% if routeArea == \'admin\' %}");
            int _size = listItemsFields.size();
            int _size_1 = IterableExtensions.size(listItemsIn);
            int _plus = (_size + _size_1);
            int _size_2 = IterableExtensions.size(listItemsOut);
            int _plus_1 = (_plus + _size_2);
            int _plus_2 = (_plus_1 + 1);
            int _plus_3 = (_plus_2 + 1);
            _builder.append(_plus_3, "    ");
            _builder.append("{% else %}");
            int _size_3 = listItemsFields.size();
            int _size_4 = IterableExtensions.size(listItemsIn);
            int _plus_4 = (_size_3 + _size_4);
            int _size_5 = IterableExtensions.size(listItemsOut);
            int _plus_5 = (_plus_4 + _size_5);
            int _plus_6 = (_plus_5 + 1);
            int _plus_7 = (_plus_6 + 0);
            _builder.append(_plus_7, "    ");
            _builder.append("{% endif %}\">");
            _builder.newLineIfNotEmpty();
          }
        }
      }
    }
    _builder.append("    ");
    _builder.append("{{ __(\'No ");
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(it.getNameMultiple());
    _builder.append(_formatForDisplay, "    ");
    _builder.append(" found.\') }}");
    _builder.newLineIfNotEmpty();
    {
      if ((((this.listType).intValue() == View.LIST_TYPE_UL) || ((this.listType).intValue() == View.LIST_TYPE_OL))) {
        _builder.append("    ");
        _builder.append("</li>");
        _builder.newLine();
      } else {
        if (((this.listType).intValue() == View.LIST_TYPE_DL)) {
          _builder.append("    ");
          _builder.append("</dt>");
          _builder.newLine();
        } else {
          if (((this.listType).intValue() == View.LIST_TYPE_TABLE)) {
            _builder.append("    ");
            _builder.append("  ");
            _builder.append("</td>");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("</tr>");
            _builder.newLine();
          }
        }
      }
    }
    _builder.append("{% endfor %}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence viewItemListFooter(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      if (((this.listType).intValue() != View.LIST_TYPE_TABLE)) {
        _builder.append("<");
        String _asListTag = this.asListTag(this.listType);
        _builder.append(_asListTag);
        _builder.append(">");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("    ");
        _builder.append("</tbody>");
        _builder.newLine();
        _builder.append("</table>");
        _builder.newLine();
        _builder.append("</div>");
        _builder.newLine();
      }
    }
    return _builder;
  }
  
  private CharSequence pagerCall(final Entity it, final String appName) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.newLine();
    _builder.append("{% if showAllEntries != 1 and pager|default %}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{{ pager({ rowcount: pager.amountOfItems, limit: pager.itemsPerPage, display: \'page\', route: \'");
    String _formatForDB = this._formattingExtensions.formatForDB(appName);
    _builder.append(_formatForDB, "    ");
    _builder.append("_");
    String _formatForDB_1 = this._formattingExtensions.formatForDB(it.getName());
    _builder.append(_formatForDB_1, "    ");
    _builder.append("_\' ~ routeArea ~ \'view\'}) }}");
    _builder.newLineIfNotEmpty();
    _builder.append("{% endif %}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence massActionFields(final Entity it, final String appName) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("<fieldset>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<label for=\"");
    String _firstLower = StringExtensions.toFirstLower(appName);
    _builder.append(_firstLower, "    ");
    _builder.append("Action\" class=\"col-sm-3 control-label\">{{ __(\'With selected ");
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(it.getNameMultiple());
    _builder.append(_formatForDisplay, "    ");
    _builder.append("\') }}</label>");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("<div class=\"col-sm-6\">");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<select id=\"");
    String _firstLower_1 = StringExtensions.toFirstLower(appName);
    _builder.append(_firstLower_1, "        ");
    _builder.append("Action\" name=\"action\" class=\"form-control input-sm\">");
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    _builder.append("<option value=\"\">{{ __(\'Choose action\') }}</option>");
    _builder.newLine();
    {
      EntityWorkflowType _workflow = it.getWorkflow();
      boolean _notEquals = (!Objects.equal(_workflow, EntityWorkflowType.NONE));
      if (_notEquals) {
        {
          EntityWorkflowType _workflow_1 = it.getWorkflow();
          boolean _equals = Objects.equal(_workflow_1, EntityWorkflowType.ENTERPRISE);
          if (_equals) {
            _builder.append("            ");
            _builder.append("<option value=\"accept\" title=\"{{ __(\'");
            String _workflowActionDescription = this._workflowExtensions.getWorkflowActionDescription(it.getWorkflow(), "Accept");
            _builder.append(_workflowActionDescription, "            ");
            _builder.append("\') }}\">{{ __(\'Accept\') }}</option>");
            _builder.newLineIfNotEmpty();
            {
              boolean _isOwnerPermission = it.isOwnerPermission();
              if (_isOwnerPermission) {
                _builder.append("            ");
                _builder.append("<option value=\"reject\" title=\"{{ __(\'");
                String _workflowActionDescription_1 = this._workflowExtensions.getWorkflowActionDescription(it.getWorkflow(), "Reject");
                _builder.append(_workflowActionDescription_1, "            ");
                _builder.append("\') }}\">{{ __(\'Reject\') }}</option>");
                _builder.newLineIfNotEmpty();
              }
            }
            _builder.append("            ");
            _builder.append("<option value=\"demote\" title=\"{{ __(\'");
            String _workflowActionDescription_2 = this._workflowExtensions.getWorkflowActionDescription(it.getWorkflow(), "Demote");
            _builder.append(_workflowActionDescription_2, "            ");
            _builder.append("\') }}\">{{ __(\'Demote\') }}</option>");
            _builder.newLineIfNotEmpty();
          }
        }
        _builder.append("            ");
        _builder.append("<option value=\"approve\" title=\"{{ __(\'");
        String _workflowActionDescription_3 = this._workflowExtensions.getWorkflowActionDescription(it.getWorkflow(), "Approve");
        _builder.append(_workflowActionDescription_3, "            ");
        _builder.append("\') }}\">{{ __(\'Approve\') }}</option>");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      boolean _isHasTray = it.isHasTray();
      if (_isHasTray) {
        _builder.append("            ");
        _builder.append("<option value=\"unpublish\" title=\"{{ __(\'");
        String _workflowActionDescription_4 = this._workflowExtensions.getWorkflowActionDescription(it.getWorkflow(), "Unpublish");
        _builder.append(_workflowActionDescription_4, "            ");
        _builder.append("\') }}\">{{ __(\'Unpublish\') }}</option>");
        _builder.newLineIfNotEmpty();
        _builder.append("            ");
        _builder.append("<option value=\"publish\" title=\"{{ __(\'");
        String _workflowActionDescription_5 = this._workflowExtensions.getWorkflowActionDescription(it.getWorkflow(), "Publish");
        _builder.append(_workflowActionDescription_5, "            ");
        _builder.append("\') }}\">{{ __(\'Publish\') }}</option>");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      boolean _isHasArchive = it.isHasArchive();
      if (_isHasArchive) {
        _builder.append("            ");
        _builder.append("<option value=\"archive\" title=\"{{ __(\'");
        String _workflowActionDescription_6 = this._workflowExtensions.getWorkflowActionDescription(it.getWorkflow(), "Archive");
        _builder.append(_workflowActionDescription_6, "            ");
        _builder.append("\') }}\">{{ __(\'Archive\') }}</option>");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("            ");
    _builder.append("<option value=\"delete\" title=\"{{ __(\'");
    String _workflowActionDescription_7 = this._workflowExtensions.getWorkflowActionDescription(it.getWorkflow(), "Delete");
    _builder.append(_workflowActionDescription_7, "            ");
    _builder.append("\') }}\">{{ __(\'Delete\') }}</option>");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("</select>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("</div>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<div class=\"col-sm-3\">");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<input type=\"submit\" value=\"{{ __(\'Submit\') }}\" class=\"btn btn-default btn-sm\" />");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("</div>");
    _builder.newLine();
    _builder.append("</fieldset>");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence callDisplayHooks(final Entity it, final String appName) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.newLine();
    _builder.append("{# here you can activate calling display hooks for the view page if you need it #}");
    _builder.newLine();
    _builder.append("{# % if routeArea != \'admin\' %}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{% set hooks = notifyDisplayHooks(eventName=\'");
    String _formatForDB = this._formattingExtensions.formatForDB(appName);
    _builder.append(_formatForDB, "    ");
    _builder.append(".ui_hooks.");
    String _formatForDB_1 = this._formattingExtensions.formatForDB(it.getNameMultiple());
    _builder.append(_formatForDB_1, "    ");
    _builder.append(".display_view\', urlObject=currentUrlObject) %}");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("{% for providerArea, hook in hooks %}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("{{ hook }}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{% endfor %}");
    _builder.newLine();
    _builder.append("{% endif % #}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence columnDef(final DerivedField it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      String _name = it.getName();
      boolean _equals = Objects.equal(_name, "workflowState");
      if (_equals) {
        _builder.append("{% if routeArea == \'admin\' %}");
      }
    }
    _builder.newLineIfNotEmpty();
    _builder.append("<col id=\"c");
    String _markupIdCode = this.markupIdCode(it, Boolean.valueOf(false));
    _builder.append(_markupIdCode);
    _builder.append("\" />");
    _builder.newLineIfNotEmpty();
    {
      String _name_1 = it.getName();
      boolean _equals_1 = Objects.equal(_name_1, "workflowState");
      if (_equals_1) {
        _builder.append("{% endif %}");
      }
    }
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence columnDef(final JoinRelationship it, final Boolean useTarget) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("<col id=\"c");
    String _markupIdCode = this.markupIdCode(it, useTarget);
    _builder.append(_markupIdCode);
    _builder.append("\" />");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence headerLine(final DerivedField it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      String _name = it.getName();
      boolean _equals = Objects.equal(_name, "workflowState");
      if (_equals) {
        _builder.append("{% if routeArea == \'admin\' %}");
      }
    }
    _builder.newLineIfNotEmpty();
    _builder.append("<th id=\"h");
    String _markupIdCode = this.markupIdCode(it, Boolean.valueOf(false));
    _builder.append(_markupIdCode);
    _builder.append("\" scope=\"col\" class=\"text-");
    String _alignment = this.alignment(it);
    _builder.append(_alignment);
    {
      boolean _contains = this._modelExtensions.getSortingFields(it.getEntity()).contains(it);
      boolean _not = (!_contains);
      if (_not) {
        _builder.append(" z-order-unsorted");
      }
    }
    _builder.append("\">");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    String _xifexpression = null;
    String _name_1 = it.getName();
    boolean _equals_1 = Objects.equal(_name_1, "workflowState");
    if (_equals_1) {
      _xifexpression = "state";
    } else {
      _xifexpression = it.getName();
    }
    final String fieldLabel = _xifexpression;
    _builder.newLineIfNotEmpty();
    {
      boolean _contains_1 = this._modelExtensions.getSortingFields(it.getEntity()).contains(it);
      if (_contains_1) {
        _builder.append("    ");
        CharSequence _headerSortingLink = this.headerSortingLink(it, it.getEntity(), this._formattingExtensions.formatForCode(it.getName()), fieldLabel);
        _builder.append(_headerSortingLink, "    ");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("    ");
        CharSequence _headerTitle = this.headerTitle(it, it.getEntity(), this._formattingExtensions.formatForCode(it.getName()), fieldLabel);
        _builder.append(_headerTitle, "    ");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("</th>");
    _builder.newLine();
    {
      String _name_2 = it.getName();
      boolean _equals_2 = Objects.equal(_name_2, "workflowState");
      if (_equals_2) {
        _builder.append("{% endif %}");
      }
    }
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence headerLine(final JoinRelationship it, final Boolean useTarget) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("<th id=\"h");
    String _markupIdCode = this.markupIdCode(it, useTarget);
    _builder.append(_markupIdCode);
    _builder.append("\" scope=\"col\" class=\"text-left\">");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    DataObject _xifexpression = null;
    if ((useTarget).booleanValue()) {
      _xifexpression = it.getSource();
    } else {
      _xifexpression = it.getTarget();
    }
    final DataObject mainEntity = _xifexpression;
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    CharSequence _headerSortingLink = this.headerSortingLink(it, mainEntity, this._formattingExtensions.formatForCode(this._namingExtensions.getRelationAliasName(it, useTarget)), this._formattingExtensions.formatForCodeCapital(this._namingExtensions.getRelationAliasName(it, useTarget)));
    _builder.append(_headerSortingLink, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("</th>");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence headerSortingLink(final Object it, final DataObject entity, final String fieldName, final String label) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("<a href=\"{{ sort.");
    _builder.append(fieldName);
    _builder.append(".url }}\" title=\"{{ __f(\'Sort by %s\', {\'%s\': \'");
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(label);
    _builder.append(_formatForDisplay);
    _builder.append("\'}) }}\" class=\"{{ sort.");
    _builder.append(fieldName);
    _builder.append(".class }}\">{{ __(\'");
    String _formatForDisplayCapital = this._formattingExtensions.formatForDisplayCapital(label);
    _builder.append(_formatForDisplayCapital);
    _builder.append("\') }}</a>");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence headerTitle(final Object it, final DataObject entity, final String fieldName, final String label) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{{ __(\'");
    String _formatForDisplayCapital = this._formattingExtensions.formatForDisplayCapital(label);
    _builder.append(_formatForDisplayCapital);
    _builder.append("\') }}");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence displayEntry(final Object it, final Boolean useTarget) {
    StringConcatenation _builder = new StringConcatenation();
    final String cssClass = this.entryContainerCssClass(it);
    _builder.newLineIfNotEmpty();
    {
      if (((this.listType).intValue() != View.LIST_TYPE_TABLE)) {
        _builder.append("<");
        String _asItemTag = this.asItemTag(this.listType);
        _builder.append(_asItemTag);
        {
          boolean _notEquals = (!Objects.equal(cssClass, ""));
          if (_notEquals) {
            _builder.append(" class=\"");
            _builder.append(cssClass);
            _builder.append("\"");
          }
        }
        _builder.append(">");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("<td headers=\"h");
        String _markupIdCode = this.markupIdCode(it, useTarget);
        _builder.append(_markupIdCode);
        _builder.append("\" class=\"text-");
        String _alignment = this.alignment(it);
        _builder.append(_alignment);
        {
          boolean _notEquals_1 = (!Objects.equal(cssClass, ""));
          if (_notEquals_1) {
            _builder.append(" ");
            _builder.append(cssClass);
          }
        }
        _builder.append("\">");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("    ");
    CharSequence _displayEntryInner = this.displayEntryInner(it, useTarget);
    _builder.append(_displayEntryInner, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("</");
    String _asItemTag_1 = this.asItemTag(this.listType);
    _builder.append(_asItemTag_1);
    _builder.append(">");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private String _entryContainerCssClass(final Object it) {
    return "";
  }
  
  private String _entryContainerCssClass(final ListField it) {
    String _xifexpression = null;
    String _name = it.getName();
    boolean _equals = Objects.equal(_name, "workflowState");
    if (_equals) {
      _xifexpression = "nowrap";
    } else {
      _xifexpression = "";
    }
    return _xifexpression;
  }
  
  private CharSequence _displayEntryInner(final Object it, final Boolean useTarget) {
    return null;
  }
  
  private CharSequence _displayEntryInner(final DerivedField it, final Boolean useTarget) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _contains = CollectionLiterals.<String>newArrayList("name", "title").contains(it.getName());
      if (_contains) {
        {
          if (((it.getEntity() instanceof Entity) && this._controllerExtensions.hasDisplayAction(((Entity) it.getEntity())))) {
            _builder.append("<a href=\"{{ path(\'");
            String _formatForDB = this._formattingExtensions.formatForDB(this._utils.appName(it.getEntity().getApplication()));
            _builder.append(_formatForDB);
            _builder.append("_");
            String _formatForDB_1 = this._formattingExtensions.formatForDB(it.getEntity().getName());
            _builder.append(_formatForDB_1);
            _builder.append("_\' ~ routeArea ~ \'display\'");
            DataObject _entity = it.getEntity();
            CharSequence _routeParams = this._urlExtensions.routeParams(((Entity) _entity), this._formattingExtensions.formatForCode(it.getEntity().getName()), Boolean.valueOf(true));
            _builder.append(_routeParams);
            _builder.append(") }}\" title=\"{{ __(\'View detail page\')|e(\'html_attr\') }}\">");
            CharSequence _displayLeadingEntry = this.displayLeadingEntry(it);
            _builder.append(_displayLeadingEntry);
            _builder.append("</a>");
            _builder.newLineIfNotEmpty();
          } else {
            CharSequence _displayLeadingEntry_1 = this.displayLeadingEntry(it);
            _builder.append(_displayLeadingEntry_1);
            _builder.newLineIfNotEmpty();
          }
        }
      } else {
        String _name = it.getName();
        boolean _equals = Objects.equal(_name, "workflowState");
        if (_equals) {
          _builder.append("{{ ");
          String _formatForCode = this._formattingExtensions.formatForCode(it.getEntity().getName());
          _builder.append(_formatForCode);
          _builder.append(".workflowState|");
          String _formatForDB_2 = this._formattingExtensions.formatForDB(this._utils.appName(it.getEntity().getApplication()));
          _builder.append(_formatForDB_2);
          _builder.append("_objectState }}");
          _builder.newLineIfNotEmpty();
        } else {
          CharSequence _displayField = this.fieldHelper.displayField(it, this._formattingExtensions.formatForCode(it.getEntity().getName()), "view");
          _builder.append(_displayField);
          _builder.newLineIfNotEmpty();
        }
      }
    }
    return _builder;
  }
  
  private CharSequence displayLeadingEntry(final DerivedField it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{{ ");
    String _formatForCode = this._formattingExtensions.formatForCode(it.getEntity().getName());
    _builder.append(_formatForCode);
    _builder.append(".");
    String _formatForCode_1 = this._formattingExtensions.formatForCode(it.getName());
    _builder.append(_formatForCode_1);
    {
      if (((it.getEntity() instanceof Entity) && (!((Entity) it.getEntity()).isSkipHookSubscribers()))) {
        _builder.append("|notifyFilters(\'");
        String _formatForDB = this._formattingExtensions.formatForDB(this._utils.appName(it.getEntity().getApplication()));
        _builder.append(_formatForDB);
        _builder.append(".filterhook.");
        DataObject _entity = it.getEntity();
        String _formatForDB_1 = this._formattingExtensions.formatForDB(((Entity) _entity).getNameMultiple());
        _builder.append(_formatForDB_1);
        _builder.append("\')");
      }
    }
    _builder.append(" }}");
    return _builder;
  }
  
  private CharSequence _displayEntryInner(final JoinRelationship it, final Boolean useTarget) {
    StringConcatenation _builder = new StringConcatenation();
    final String relationAliasName = this._formattingExtensions.formatForCode(this._namingExtensions.getRelationAliasName(it, useTarget));
    _builder.newLineIfNotEmpty();
    DataObject _xifexpression = null;
    if ((!(useTarget).booleanValue())) {
      _xifexpression = it.getTarget();
    } else {
      _xifexpression = it.getSource();
    }
    final Entity mainEntity = ((Entity) _xifexpression);
    _builder.newLineIfNotEmpty();
    DataObject _xifexpression_1 = null;
    if ((useTarget).booleanValue()) {
      _xifexpression_1 = it.getTarget();
    } else {
      _xifexpression_1 = it.getSource();
    }
    final Entity linkEntity = ((Entity) _xifexpression_1);
    _builder.newLineIfNotEmpty();
    String _formatForCode = this._formattingExtensions.formatForCode(mainEntity.getName());
    String _plus = (_formatForCode + ".");
    String relObjName = (_plus + relationAliasName);
    _builder.newLineIfNotEmpty();
    _builder.append("{% if ");
    _builder.append(relObjName);
    _builder.append("|default %}");
    _builder.newLineIfNotEmpty();
    {
      boolean _hasDisplayAction = this._controllerExtensions.hasDisplayAction(linkEntity);
      if (_hasDisplayAction) {
        _builder.append("    ");
        _builder.append("<a href=\"{{ path(\'");
        String _formatForDB = this._formattingExtensions.formatForDB(this._utils.appName(linkEntity.getApplication()));
        _builder.append(_formatForDB, "    ");
        _builder.append("_");
        String _formatForDB_1 = this._formattingExtensions.formatForDB(linkEntity.getName());
        _builder.append(_formatForDB_1, "    ");
        _builder.append("_\' ~ routeArea ~ \'display\'");
        CharSequence _routeParams = this._urlExtensions.routeParams(linkEntity, relObjName, Boolean.valueOf(true));
        _builder.append(_routeParams, "    ");
        _builder.append(") }}\">{% spaceless %}");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("      ");
    _builder.append("{{ ");
    _builder.append(relObjName, "      ");
    _builder.append(".getTitleFromDisplayPattern() }}");
    _builder.newLineIfNotEmpty();
    {
      boolean _hasDisplayAction_1 = this._controllerExtensions.hasDisplayAction(linkEntity);
      if (_hasDisplayAction_1) {
        _builder.append("    ");
        _builder.append("{% endspaceless %}</a>");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("<a id=\"");
        String _formatForCode_1 = this._formattingExtensions.formatForCode(linkEntity.getName());
        _builder.append(_formatForCode_1, "    ");
        _builder.append("Item");
        {
          Iterable<DerivedField> _primaryKeyFields = this._modelExtensions.getPrimaryKeyFields(mainEntity);
          boolean _hasElements = false;
          for(final DerivedField pkField : _primaryKeyFields) {
            if (!_hasElements) {
              _hasElements = true;
            } else {
              _builder.appendImmediate("_", "    ");
            }
            _builder.append("{{ ");
            String _formatForCode_2 = this._formattingExtensions.formatForCode(mainEntity.getName());
            _builder.append(_formatForCode_2, "    ");
            _builder.append(".");
            String _formatForCode_3 = this._formattingExtensions.formatForCode(pkField.getName());
            _builder.append(_formatForCode_3, "    ");
            _builder.append(" }}");
          }
        }
        _builder.append("_rel_");
        {
          Iterable<DerivedField> _primaryKeyFields_1 = this._modelExtensions.getPrimaryKeyFields(linkEntity);
          boolean _hasElements_1 = false;
          for(final DerivedField pkField_1 : _primaryKeyFields_1) {
            if (!_hasElements_1) {
              _hasElements_1 = true;
            } else {
              _builder.appendImmediate("_", "    ");
            }
            _builder.append("{{ ");
            _builder.append(relObjName, "    ");
            _builder.append(".");
            String _formatForCode_4 = this._formattingExtensions.formatForCode(pkField_1.getName());
            _builder.append(_formatForCode_4, "    ");
            _builder.append(" }}");
          }
        }
        _builder.append("Display\" href=\"{{ path(\'");
        String _formatForDB_2 = this._formattingExtensions.formatForDB(this._utils.appName(it.getApplication()));
        _builder.append(_formatForDB_2, "    ");
        _builder.append("_");
        String _formatForDB_3 = this._formattingExtensions.formatForDB(linkEntity.getName());
        _builder.append(_formatForDB_3, "    ");
        _builder.append("_\' ~ routeArea ~ \'display\', {");
        CharSequence _routePkParams = this._urlExtensions.routePkParams(linkEntity, relObjName, Boolean.valueOf(true));
        _builder.append(_routePkParams, "    ");
        CharSequence _appendSlug = this._urlExtensions.appendSlug(linkEntity, relObjName, Boolean.valueOf(true));
        _builder.append(_appendSlug, "    ");
        _builder.append(", \'raw\': 1 }) }}\" title=\"{{ __(\'Open quick view window\')|e(\'html_attr\') }}\" class=\"");
        String _lowerCase = this._utils.vendorAndName(it.getApplication()).toLowerCase();
        _builder.append(_lowerCase, "    ");
        _builder.append("-inline-window hidden\" data-modal-title=\"{{ ");
        _builder.append(relObjName, "    ");
        _builder.append(".getTitleFromDisplayPattern()|e(\'html_attr\') }}\"><span class=\"fa fa-id-card-o\"></span></a>");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("{% else %}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{{ __(\'Not set.\') }}");
    _builder.newLine();
    _builder.append("{% endif %}");
    _builder.newLine();
    return _builder;
  }
  
  private String _markupIdCode(final Object it, final Boolean useTarget) {
    return null;
  }
  
  private String _markupIdCode(final NamedObject it, final Boolean useTarget) {
    return this._formattingExtensions.formatForCodeCapital(it.getName());
  }
  
  private String _markupIdCode(final DerivedField it, final Boolean useTarget) {
    return this._formattingExtensions.formatForCodeCapital(it.getName());
  }
  
  private String _markupIdCode(final JoinRelationship it, final Boolean useTarget) {
    return StringExtensions.toFirstUpper(this._namingExtensions.getRelationAliasName(it, useTarget));
  }
  
  private String alignment(final Object it) {
    String _switchResult = null;
    boolean _matched = false;
    if (it instanceof BooleanField) {
      _matched=true;
      _switchResult = "center";
    }
    if (!_matched) {
      if (it instanceof IntegerField) {
        _matched=true;
        _switchResult = "right";
      }
    }
    if (!_matched) {
      if (it instanceof DecimalField) {
        _matched=true;
        _switchResult = "right";
      }
    }
    if (!_matched) {
      if (it instanceof FloatField) {
        _matched=true;
        _switchResult = "right";
      }
    }
    if (!_matched) {
      if (it instanceof EmailField) {
        _matched=true;
        _switchResult = "center";
      }
    }
    if (!_matched) {
      if (it instanceof UrlField) {
        _matched=true;
        _switchResult = "center";
      }
    }
    if (!_matched) {
      _switchResult = "left";
    }
    return _switchResult;
  }
  
  private CharSequence itemActions(final Entity it, final String appName) {
    StringConcatenation _builder = new StringConcatenation();
    {
      if (((this.listType).intValue() != View.LIST_TYPE_TABLE)) {
        _builder.append("<");
        String _asItemTag = this.asItemTag(this.listType);
        _builder.append(_asItemTag);
        _builder.append(">");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("<td id=\"");
        CharSequence _itemActionContainerViewId = new ItemActionsView().itemActionContainerViewId(it);
        _builder.append(_itemActionContainerViewId);
        _builder.append("\" headers=\"hItemActions\" class=\"fixed-column actions nowrap z-w02\">");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("    ");
    CharSequence _generate = new ItemActionsView().generate(it, "view");
    _builder.append(_generate, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("</");
    String _asItemTag_1 = this.asItemTag(this.listType);
    _builder.append(_asItemTag_1);
    _builder.append(">");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private String asListTag(final Integer listType) {
    String _switchResult = null;
    if (listType != null) {
      switch (listType) {
        case View.LIST_TYPE_UL:
          _switchResult = "ul";
          break;
        case View.LIST_TYPE_OL:
          _switchResult = "ol";
          break;
        case View.LIST_TYPE_DL:
          _switchResult = "dl";
          break;
        case View.LIST_TYPE_TABLE:
          _switchResult = "table";
          break;
        default:
          _switchResult = "table";
          break;
      }
    } else {
      _switchResult = "table";
    }
    return _switchResult;
  }
  
  private String asItemTag(final Integer listType) {
    String _switchResult = null;
    if (listType != null) {
      switch (listType) {
        case View.LIST_TYPE_UL:
          _switchResult = "li";
          break;
        case View.LIST_TYPE_OL:
          _switchResult = "li";
          break;
        case View.LIST_TYPE_DL:
          _switchResult = "dd";
          break;
        case View.LIST_TYPE_TABLE:
          _switchResult = "td";
          break;
        default:
          _switchResult = "td";
          break;
      }
    } else {
      _switchResult = "td";
    }
    return _switchResult;
  }
  
  private CharSequence viewViewDeleted(final Entity it, final String appName) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{# purpose of this template: list view of deleted ");
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(it.getNameMultiple());
    _builder.append(_formatForDisplay);
    _builder.append(" #}");
    _builder.newLineIfNotEmpty();
    _builder.append("{% extends routeArea == \'admin\' ? \'");
    String _appName = this._utils.appName(it.getApplication());
    _builder.append(_appName);
    _builder.append("::adminBase.html.twig\' : \'");
    String _appName_1 = this._utils.appName(it.getApplication());
    _builder.append(_appName_1);
    _builder.append("::base.html.twig\' %}");
    _builder.newLineIfNotEmpty();
    _builder.append("{% block title __(\'Deleted ");
    String _formatForDisplay_1 = this._formattingExtensions.formatForDisplay(it.getNameMultiple());
    _builder.append(_formatForDisplay_1);
    _builder.append("\') %}");
    _builder.newLineIfNotEmpty();
    _builder.append("{% block admin_page_icon \'trash-o\' %}");
    _builder.newLine();
    _builder.append("{% block content %}");
    _builder.newLine();
    _builder.append("<div class=\"");
    String _lowerCase = appName.toLowerCase();
    _builder.append(_lowerCase);
    _builder.append("-");
    String _formatForDB = this._formattingExtensions.formatForDB(it.getName());
    _builder.append(_formatForDB);
    _builder.append(" ");
    String _lowerCase_1 = appName.toLowerCase();
    _builder.append(_lowerCase_1);
    _builder.append("-viewdeleted\">");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("{{ block(\'page_nav_links\') }}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<div class=\"table-responsive\">");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<table class=\"table table-striped table-bordered table-hover{% if routeArea == \'admin\' %} table-condensed{% endif %}\">");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("<colgroup>");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("<col id=\"cId\" />");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("<col id=\"cDate\" />");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("<col id=\"cUser\" />");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("<col id=\"cActions\" />");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("</colgroup>");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("<thead>");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("<tr>");
    _builder.newLine();
    _builder.append("                    ");
    _builder.append("<th id=\"hId\" scope=\"col\" class=\"z-order-unsorted z-w02\">{{ __(\'ID\') }}</th>");
    _builder.newLine();
    _builder.append("                    ");
    _builder.append("<th id=\"hDate\" scope=\"col\" class=\"z-order-unsorted\">{{ __(\'Date\') }}</th>");
    _builder.newLine();
    _builder.append("                    ");
    _builder.append("<th id=\"hUser\" scope=\"col\" class=\"z-order-unsorted\">{{ __(\'User\') }}</th>");
    _builder.newLine();
    _builder.append("                    ");
    _builder.append("<th id=\"hActions\" scope=\"col\" class=\"z-order-unsorted\">{{ __(\'Actions\') }}</th>");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("</tr>");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("</thead>");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("<tbody>");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("{% for logEntry in deletedItems %}");
    _builder.newLine();
    _builder.append("                    ");
    _builder.append("<tr>");
    _builder.newLine();
    _builder.append("                        ");
    _builder.append("<td headers=\"hVersion\" class=\"text-center\">{{ logEntry.objectId }}</td>");
    _builder.newLine();
    _builder.append("                        ");
    _builder.append("<td headers=\"hDate\">{{ logEntry.loggedAt|localizeddate(\'long\', \'medium\') }}</td>");
    _builder.newLine();
    _builder.append("                        ");
    _builder.append("<td headers=\"hUser\">{{ ");
    String _lowerCase_2 = appName.toLowerCase();
    _builder.append(_lowerCase_2, "                        ");
    _builder.append("_userAvatar(uid=logEntry.username, size=20, rating=\'g\') }} {{ logEntry.username|profileLinkByUserName() }}</td>");
    _builder.newLineIfNotEmpty();
    _builder.append("                        ");
    _builder.append("<td headers=\"hActions\" class=\"actions nowrap\">");
    _builder.newLine();
    {
      boolean _hasDisplayAction = this._controllerExtensions.hasDisplayAction(it);
      if (_hasDisplayAction) {
        _builder.append("                            ");
        _builder.append("{% set linkTitle = __f(\'Preview ");
        String _formatForDisplay_2 = this._formattingExtensions.formatForDisplay(it.getName());
        _builder.append(_formatForDisplay_2, "                            ");
        _builder.append(" %id%\', { \'%id%\': logEntry.objectId }) %}");
        _builder.newLineIfNotEmpty();
        _builder.append("                            ");
        _builder.append("<a id=\"");
        String _formatForCode = this._formattingExtensions.formatForCode(it.getName());
        _builder.append(_formatForCode, "                            ");
        _builder.append("ItemDisplay{{ logEntry.objectId }}\" href=\"{{ path(\'");
        String _formatForDB_1 = this._formattingExtensions.formatForDB(appName);
        _builder.append(_formatForDB_1, "                            ");
        _builder.append("_");
        String _formatForDB_2 = this._formattingExtensions.formatForDB(it.getName());
        _builder.append(_formatForDB_2, "                            ");
        _builder.append("_\' ~ routeArea ~ \'displaydeleted\', { \'");
        String _formatForCode_1 = this._formattingExtensions.formatForCode(this._modelExtensions.getFirstPrimaryKey(it).getName());
        _builder.append(_formatForCode_1, "                            ");
        _builder.append("\': logEntry.objectId, \'raw\': 1 }) }}\" title=\"{{ linkTitle|e(\'html_attr\') }}\" class=\"");
        String _lowerCase_3 = this._utils.vendorAndName(it.getApplication()).toLowerCase();
        _builder.append(_lowerCase_3, "                            ");
        _builder.append("-inline-window hidden\" data-modal-title=\"{{ __f(\'");
        String _formatForDisplayCapital = this._formattingExtensions.formatForDisplayCapital(it.getName());
        _builder.append(_formatForDisplayCapital, "                            ");
        _builder.append(" %id%\', { \'%id%\': logEntry.objectId }) }}\"><span class=\"fa fa-id-card-o\"></span></a>");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("                            ");
    _builder.append("{% set linkTitle = __f(\'Undelete ");
    String _formatForDisplay_3 = this._formattingExtensions.formatForDisplay(it.getName());
    _builder.append(_formatForDisplay_3, "                            ");
    _builder.append(" %id%\', { \'%id%\': logEntry.objectId }) %}");
    _builder.newLineIfNotEmpty();
    _builder.append("                            ");
    _builder.append("<a href=\"{{ path(\'");
    String _formatForDB_3 = this._formattingExtensions.formatForDB(appName);
    _builder.append(_formatForDB_3, "                            ");
    _builder.append("_");
    String _formatForDB_4 = this._formattingExtensions.formatForDB(it.getName());
    _builder.append(_formatForDB_4, "                            ");
    _builder.append("_\' ~ routeArea ~ \'displaydeleted\', { \'");
    String _formatForCode_2 = this._formattingExtensions.formatForCode(this._modelExtensions.getFirstPrimaryKey(it).getName());
    _builder.append(_formatForCode_2, "                            ");
    _builder.append("\': logEntry.objectId, \'undelete\': 1 }) }}\" title=\"{{ linkTitle|e(\'html_attr\') }}\"><span class=\"fa fa-history\"></span></a>");
    _builder.newLineIfNotEmpty();
    _builder.append("                        ");
    _builder.append("</td>");
    _builder.newLine();
    _builder.append("                    ");
    _builder.append("</tr>");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("{% endfor %}");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("</tbody>");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("</table>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("</div>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{{ block(\'page_nav_links\') }}");
    _builder.newLine();
    _builder.append("</div>");
    _builder.newLine();
    _builder.append("{% endblock %}");
    _builder.newLine();
    _builder.append("{% block page_nav_links %}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<p>");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("{% set linkTitle = __(\'Back to overview\') %}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<a href=\"{{ path(\'");
    String _formatForDB_5 = this._formattingExtensions.formatForDB(appName);
    _builder.append(_formatForDB_5, "        ");
    _builder.append("_");
    String _formatForDB_6 = this._formattingExtensions.formatForDB(it.getName());
    _builder.append(_formatForDB_6, "        ");
    _builder.append("_\' ~ routeArea ~ \'view\') }}\" title=\"{{ linkTitle|e(\'html_attr\') }}\" class=\"fa fa-reply\">{{ linkTitle }}</a>");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("</p>");
    _builder.newLine();
    _builder.append("{% endblock %}");
    _builder.newLine();
    return _builder;
  }
  
  private String entryContainerCssClass(final Object it) {
    if (it instanceof ListField) {
      return _entryContainerCssClass((ListField)it);
    } else if (it != null) {
      return _entryContainerCssClass(it);
    } else {
      throw new IllegalArgumentException("Unhandled parameter types: " +
        Arrays.<Object>asList(it).toString());
    }
  }
  
  private CharSequence displayEntryInner(final Object it, final Boolean useTarget) {
    if (it instanceof DerivedField) {
      return _displayEntryInner((DerivedField)it, useTarget);
    } else if (it instanceof JoinRelationship) {
      return _displayEntryInner((JoinRelationship)it, useTarget);
    } else if (it != null) {
      return _displayEntryInner(it, useTarget);
    } else {
      throw new IllegalArgumentException("Unhandled parameter types: " +
        Arrays.<Object>asList(it, useTarget).toString());
    }
  }
  
  private String markupIdCode(final Object it, final Boolean useTarget) {
    if (it instanceof DerivedField) {
      return _markupIdCode((DerivedField)it, useTarget);
    } else if (it instanceof JoinRelationship) {
      return _markupIdCode((JoinRelationship)it, useTarget);
    } else if (it instanceof NamedObject) {
      return _markupIdCode((NamedObject)it, useTarget);
    } else if (it != null) {
      return _markupIdCode(it, useTarget);
    } else {
      throw new IllegalArgumentException("Unhandled parameter types: " +
        Arrays.<Object>asList(it, useTarget).toString());
    }
  }
}
