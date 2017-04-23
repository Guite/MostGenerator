package org.zikula.modulestudio.generator.cartridges.zclassic.view.pages;

import com.google.common.base.Objects;
import com.google.common.collect.Iterables;
import de.guite.modulestudio.metamodel.DataObject;
import de.guite.modulestudio.metamodel.DerivedField;
import de.guite.modulestudio.metamodel.Entity;
import de.guite.modulestudio.metamodel.EntityTreeType;
import de.guite.modulestudio.metamodel.JoinRelationship;
import de.guite.modulestudio.metamodel.ManyToManyRelationship;
import de.guite.modulestudio.metamodel.OneToManyRelationship;
import java.util.ArrayList;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.CollectionLiterals;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.InputOutput;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.eclipse.xtext.xbase.lib.StringExtensions;
import org.zikula.modulestudio.generator.cartridges.zclassic.view.pagecomponents.ItemActionsView;
import org.zikula.modulestudio.generator.cartridges.zclassic.view.pagecomponents.Relations;
import org.zikula.modulestudio.generator.cartridges.zclassic.view.pagecomponents.SimpleFields;
import org.zikula.modulestudio.generator.extensions.ControllerExtensions;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.UrlExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;
import org.zikula.modulestudio.generator.extensions.ViewExtensions;
import org.zikula.modulestudio.generator.extensions.WorkflowExtensions;

@SuppressWarnings("all")
public class Display {
  @Extension
  private ControllerExtensions _controllerExtensions = new ControllerExtensions();
  
  @Extension
  private FormattingExtensions _formattingExtensions = new FormattingExtensions();
  
  @Extension
  private ModelExtensions _modelExtensions = new ModelExtensions();
  
  @Extension
  private ModelJoinExtensions _modelJoinExtensions = new ModelJoinExtensions();
  
  @Extension
  private NamingExtensions _namingExtensions = new NamingExtensions();
  
  @Extension
  private UrlExtensions _urlExtensions = new UrlExtensions();
  
  @Extension
  private Utils _utils = new Utils();
  
  @Extension
  private ViewExtensions _viewExtensions = new ViewExtensions();
  
  @Extension
  private WorkflowExtensions _workflowExtensions = new WorkflowExtensions();
  
  public void generate(final Entity it, final String appName, final IFileSystemAccess fsa) {
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(it.getName());
    String _plus = ("Generating display templates for entity \"" + _formatForDisplay);
    String _plus_1 = (_plus + "\"");
    InputOutput.<String>println(_plus_1);
    String templateFilePath = this._namingExtensions.templateFile(it, "display");
    boolean _shouldBeSkipped = this._namingExtensions.shouldBeSkipped(it.getApplication(), templateFilePath);
    boolean _not = (!_shouldBeSkipped);
    if (_not) {
      fsa.generateFile(templateFilePath, this.displayView(it, appName));
    }
    EntityTreeType _tree = it.getTree();
    boolean _notEquals = (!Objects.equal(_tree, EntityTreeType.NONE));
    if (_notEquals) {
      templateFilePath = this._namingExtensions.templateFile(it, "displayTreeRelatives");
      boolean _shouldBeSkipped_1 = this._namingExtensions.shouldBeSkipped(it.getApplication(), templateFilePath);
      boolean _not_1 = (!_shouldBeSkipped_1);
      if (_not_1) {
        fsa.generateFile(templateFilePath, this.treeRelatives(it, appName));
      }
    }
  }
  
  private CharSequence displayView(final Entity it, final String appName) {
    StringConcatenation _builder = new StringConcatenation();
    final Function1<JoinRelationship, Boolean> _function = (JoinRelationship e) -> {
      return Boolean.valueOf(((e.getTarget() instanceof Entity) && Objects.equal(e.getTarget().getApplication(), it.getApplication())));
    };
    Iterable<JoinRelationship> _filter = IterableExtensions.<JoinRelationship>filter(this._modelJoinExtensions.getOutgoingJoinRelations(it), _function);
    final Function1<ManyToManyRelationship, Boolean> _function_1 = (ManyToManyRelationship e) -> {
      return Boolean.valueOf(((e.getSource() instanceof Entity) && Objects.equal(e.getSource().getApplication(), it.getApplication())));
    };
    Iterable<ManyToManyRelationship> _filter_1 = IterableExtensions.<ManyToManyRelationship>filter(Iterables.<ManyToManyRelationship>filter(it.getIncoming(), ManyToManyRelationship.class), _function_1);
    final Iterable<JoinRelationship> refedElems = Iterables.<JoinRelationship>concat(_filter, _filter_1);
    _builder.newLineIfNotEmpty();
    final String objName = this._formattingExtensions.formatForCode(it.getName());
    _builder.newLineIfNotEmpty();
    _builder.append("{# purpose of this template: ");
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(it.getNameMultiple());
    _builder.append(_formatForDisplay);
    _builder.append(" display view #}");
    _builder.newLineIfNotEmpty();
    _builder.append("{% set baseTemplate = app.request.query.getBoolean(\'raw\', false) ? \'raw\' : (routeArea == \'admin\' ? \'adminBase\' : \'base\') %}");
    _builder.newLine();
    _builder.append("{% extends \'");
    String _appName = this._utils.appName(it.getApplication());
    _builder.append(_appName);
    _builder.append("::\' ~ baseTemplate ~ \'.html.twig\' %}");
    _builder.newLineIfNotEmpty();
    _builder.append("{% block pageTitle %}{{ ");
    _builder.append(objName);
    _builder.append(".getTitleFromDisplayPattern()|default(__(\'");
    String _formatForDisplayCapital = this._formattingExtensions.formatForDisplayCapital(it.getName());
    _builder.append(_formatForDisplayCapital);
    _builder.append("\')) }}{% endblock %}");
    _builder.newLineIfNotEmpty();
    _builder.append("{% block title %}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{% set templateTitle = ");
    _builder.append(objName, "    ");
    _builder.append(".getTitleFromDisplayPattern()|default(__(\'");
    String _formatForDisplayCapital_1 = this._formattingExtensions.formatForDisplayCapital(it.getName());
    _builder.append(_formatForDisplayCapital_1, "    ");
    _builder.append("\')) %}");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    CharSequence _templateHeading = this.templateHeading(it, appName);
    _builder.append(_templateHeading, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    CharSequence _generate = new ItemActionsView().generate(it, "display");
    _builder.append(_generate, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("{% endblock %}");
    _builder.newLine();
    _builder.append("{% block admin_page_icon \'eye\' %}");
    _builder.newLine();
    _builder.append("{% block content %}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{% set isQuickView = app.request.query.getBoolean(\'raw\', false) %}");
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
    _builder.append("-display\">");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    {
      boolean _useGroupingTabs = this._viewExtensions.useGroupingTabs(it, "display");
      if (_useGroupingTabs) {
        _builder.append("    ");
        _builder.append("<div class=\"zikula-bootstrap-tab-container\">");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("<ul class=\"nav nav-tabs\">");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("        ");
        _builder.append("<li role=\"presentation\" class=\"active\">");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("            ");
        _builder.append("<a id=\"fieldsTab\" href=\"#tabFields\" title=\"{{ __(\'Fields\') }}\" role=\"tab\" data-toggle=\"tab\">{{ __(\'Fields\') }}</a>");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("        ");
        _builder.append("</li>");
        _builder.newLine();
        {
          boolean _isGeographical = it.isGeographical();
          if (_isGeographical) {
            _builder.append("    ");
            _builder.append("        ");
            _builder.append("<li role=\"presentation\">");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("        ");
            _builder.append("    ");
            _builder.append("<a id=\"mapTab\" href=\"#tabMap\" title=\"{{ __(\'Map\') }}\" role=\"tab\" data-toggle=\"tab\">{{ __(\'Map\') }}</a>");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("        ");
            _builder.append("</li>");
            _builder.newLine();
          }
        }
        {
          boolean _isEmpty = IterableExtensions.isEmpty(refedElems);
          boolean _not = (!_isEmpty);
          if (_not) {
            _builder.append("    ");
            _builder.append("        ");
            _builder.append("<li role=\"presentation\">");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("        ");
            _builder.append("    ");
            _builder.append("<a id=\"relationsTab\" href=\"#tabRelations\" title=\"{{ __(\'Related data\') }}\" role=\"tab\" data-toggle=\"tab\">{{ __(\'Related data\') }}</a>");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("        ");
            _builder.append("</li>");
            _builder.newLine();
          }
        }
        {
          boolean _isAttributable = it.isAttributable();
          if (_isAttributable) {
            _builder.append("    ");
            _builder.append("        ");
            _builder.append("{% if featureActivationHelper.isEnabled(constant(\'");
            String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(it.getApplication().getVendor());
            _builder.append(_formatForCodeCapital, "            ");
            _builder.append("\\\\");
            String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(it.getApplication().getName());
            _builder.append(_formatForCodeCapital_1, "            ");
            _builder.append("Module\\\\Helper\\\\FeatureActivationHelper::ATTRIBUTES\'), \'");
            String _formatForCode = this._formattingExtensions.formatForCode(it.getName());
            _builder.append(_formatForCode, "            ");
            _builder.append("\') %}");
            _builder.newLineIfNotEmpty();
            _builder.append("    ");
            _builder.append("        ");
            _builder.append("    ");
            _builder.append("<li role=\"presentation\">");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("        ");
            _builder.append("        ");
            _builder.append("<a id=\"attributesTab\" href=\"#tabAttributes\" title=\"{{ __(\'Attributes\') }}\" role=\"tab\" data-toggle=\"tab\">{{ __(\'Attributes\') }}</a>");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("        ");
            _builder.append("    ");
            _builder.append("</li>");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("        ");
            _builder.append("{% endif %}");
            _builder.newLine();
          }
        }
        {
          EntityTreeType _tree = it.getTree();
          boolean _notEquals = (!Objects.equal(_tree, EntityTreeType.NONE));
          if (_notEquals) {
            _builder.append("    ");
            _builder.append("        ");
            _builder.append("{% if featureActivationHelper.isEnabled(constant(\'");
            String _formatForCodeCapital_2 = this._formattingExtensions.formatForCodeCapital(it.getApplication().getVendor());
            _builder.append(_formatForCodeCapital_2, "            ");
            _builder.append("\\\\");
            String _formatForCodeCapital_3 = this._formattingExtensions.formatForCodeCapital(it.getApplication().getName());
            _builder.append(_formatForCodeCapital_3, "            ");
            _builder.append("Module\\\\Helper\\\\FeatureActivationHelper::TREE_RELATIVES\'), \'");
            String _formatForCode_1 = this._formattingExtensions.formatForCode(it.getName());
            _builder.append(_formatForCode_1, "            ");
            _builder.append("\') %}");
            _builder.newLineIfNotEmpty();
            _builder.append("    ");
            _builder.append("        ");
            _builder.append("    ");
            _builder.append("<li role=\"presentation\">");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("        ");
            _builder.append("        ");
            _builder.append("<a id=\"relativesTab\" href=\"#tabRelatives\" title=\"{{ __(\'Relatives\') }}\" role=\"tab\" data-toggle=\"tab\">{{ __(\'Relatives\') }}</a>");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("        ");
            _builder.append("    ");
            _builder.append("</li>");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("        ");
            _builder.append("{% endif %}");
            _builder.newLine();
          }
        }
        {
          boolean _isCategorisable = it.isCategorisable();
          if (_isCategorisable) {
            _builder.append("    ");
            _builder.append("        ");
            _builder.append("{% if featureActivationHelper.isEnabled(constant(\'");
            String _formatForCodeCapital_4 = this._formattingExtensions.formatForCodeCapital(it.getApplication().getVendor());
            _builder.append(_formatForCodeCapital_4, "            ");
            _builder.append("\\\\");
            String _formatForCodeCapital_5 = this._formattingExtensions.formatForCodeCapital(it.getApplication().getName());
            _builder.append(_formatForCodeCapital_5, "            ");
            _builder.append("Module\\\\Helper\\\\FeatureActivationHelper::CATEGORIES\'), \'");
            String _formatForCode_2 = this._formattingExtensions.formatForCode(it.getName());
            _builder.append(_formatForCode_2, "            ");
            _builder.append("\') %}");
            _builder.newLineIfNotEmpty();
            _builder.append("    ");
            _builder.append("        ");
            _builder.append("    ");
            _builder.append("<li role=\"presentation\">");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("        ");
            _builder.append("        ");
            _builder.append("<a id=\"categoriesTab\" href=\"#tabCategories\" title=\"{{ __(\'Categories\') }}\" role=\"tab\" data-toggle=\"tab\">{{ __(\'Categories\') }}</a>");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("        ");
            _builder.append("    ");
            _builder.append("</li>");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("        ");
            _builder.append("{% endif %}");
            _builder.newLine();
          }
        }
        {
          boolean _isStandardFields = it.isStandardFields();
          if (_isStandardFields) {
            _builder.append("    ");
            _builder.append("        ");
            _builder.append("<li role=\"presentation\">");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("        ");
            _builder.append("    ");
            _builder.append("<a id=\"standardFieldsTab\" href=\"#tabStandardFields\" title=\"{{ __(\'Creation and update\') }}\" role=\"tab\" data-toggle=\"tab\">{{ __(\'Creation and update\') }}</a>");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("        ");
            _builder.append("</li>");
            _builder.newLine();
          }
        }
        {
          boolean _isSkipHookSubscribers = it.isSkipHookSubscribers();
          boolean _not_1 = (!_isSkipHookSubscribers);
          if (_not_1) {
            _builder.append("    ");
            _builder.append("        ");
            _builder.append("<li role=\"presentation\">");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("        ");
            _builder.append("    ");
            _builder.append("<a id=\"hooksTab\" href=\"#tabHooks\" title=\"{{ __(\'Hooks\') }}\" role=\"tab\" data-toggle=\"tab\">{{ __(\'Hooks\') }}</a>");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("        ");
            _builder.append("</li>");
            _builder.newLine();
          }
        }
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("</ul>");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("</div>");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("<div class=\"tab-content\">");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("<div role=\"tabpanel\" class=\"tab-pane fade in active\" id=\"tabFields\" aria-labelledby=\"fieldsTab\">");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("        ");
        _builder.append("<h3>{{ __(\'Fields\') }}</h3>");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("        ");
        CharSequence _fieldDetails = this.fieldDetails(it, appName);
        _builder.append(_fieldDetails, "            ");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("</div>");
        _builder.newLine();
      } else {
        {
          boolean _isEmpty_1 = IterableExtensions.isEmpty(refedElems);
          boolean _not_2 = (!_isEmpty_1);
          if (_not_2) {
            _builder.append("    ");
            _builder.append("<div class=\"row\">");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("<div class=\"col-sm-9\">");
            _builder.newLine();
          }
        }
        _builder.append("    ");
        CharSequence _fieldDetails_1 = this.fieldDetails(it, appName);
        _builder.append(_fieldDetails_1, "    ");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.newLine();
    _builder.append("    ");
    CharSequence _displayExtensions = this.displayExtensions(it, objName);
    _builder.append(_displayExtensions, "    ");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    {
      boolean _isSkipHookSubscribers_1 = it.isSkipHookSubscribers();
      boolean _not_3 = (!_isSkipHookSubscribers_1);
      if (_not_3) {
        _builder.append("    ");
        _builder.append("{{ block(\'display_hooks\') }}");
        _builder.newLine();
      }
    }
    {
      boolean _useGroupingTabs_1 = this._viewExtensions.useGroupingTabs(it, "display");
      if (_useGroupingTabs_1) {
        _builder.append("    ");
        _builder.append("</div>");
        _builder.newLine();
      } else {
        {
          boolean _isEmpty_2 = IterableExtensions.isEmpty(refedElems);
          boolean _not_4 = (!_isEmpty_2);
          if (_not_4) {
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("</div>");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("<div class=\"col-sm-3\">");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("        ");
            _builder.append("{{ block(\'related_items\') }}");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("</div>");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("</div>");
            _builder.newLine();
          }
        }
      }
    }
    _builder.append("</div>");
    _builder.newLine();
    _builder.append("{% endblock %}");
    _builder.newLine();
    {
      boolean _isEmpty_3 = IterableExtensions.isEmpty(refedElems);
      boolean _not_5 = (!_isEmpty_3);
      if (_not_5) {
        _builder.append(" ");
        final Relations relationHelper = new Relations();
        _builder.newLineIfNotEmpty();
        _builder.append("{% block related_items %}");
        _builder.newLine();
        {
          boolean _useGroupingTabs_2 = this._viewExtensions.useGroupingTabs(it, "display");
          if (_useGroupingTabs_2) {
            _builder.append("    ");
            _builder.append("<div role=\"tabpanel\" class=\"tab-pane fade\" id=\"tabRelations\" aria-labelledby=\"relationsTab\">");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("<h3>{{ __(\'Related data\') }}</h3>");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("    ");
            {
              for(final JoinRelationship elem : refedElems) {
                CharSequence _displayRelatedItems = relationHelper.displayRelatedItems(elem, appName, it);
                _builder.append(_displayRelatedItems, "        ");
              }
            }
            _builder.newLineIfNotEmpty();
            _builder.append("    ");
            _builder.append("</div>");
            _builder.newLine();
          } else {
            _builder.append("    ");
            {
              for(final JoinRelationship elem_1 : refedElems) {
                CharSequence _displayRelatedItems_1 = relationHelper.displayRelatedItems(elem_1, appName, it);
                _builder.append(_displayRelatedItems_1, "    ");
              }
            }
            _builder.newLineIfNotEmpty();
          }
        }
        _builder.append("{% endblock %}");
        _builder.newLine();
      }
    }
    {
      boolean _isSkipHookSubscribers_2 = it.isSkipHookSubscribers();
      boolean _not_6 = (!_isSkipHookSubscribers_2);
      if (_not_6) {
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
    {
      boolean _isGeographical_1 = it.isGeographical();
      if (_isGeographical_1) {
        _builder.append("{% block footer %}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("{{ parent() }}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("{{ pageAddAsset(\'javascript\', \'https://maps.google.com/maps/api/js?key=\' ~ getModVar(\'");
        _builder.append(appName, "    ");
        _builder.append("\', \'googleMapsApiKey\', \'\') ~ \'&amp;language=\' ~ app.request.locale ~ \'&amp;sensor=false\') }}");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("{{ pageAddAsset(\'javascript\', app.request.basePath ~ \'/plugins/Mapstraction/lib/vendor/mxn/mxn.js?(googlev3)\') }}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("{% set geoScripts %}");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("<script type=\"text/javascript\">");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("/* <![CDATA[ */");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("( function($) {");
        _builder.newLine();
        _builder.append("                ");
        _builder.append("$(document).ready(function() {");
        _builder.newLine();
        _builder.append("                    ");
        String _vendorAndName = this._utils.vendorAndName(it.getApplication());
        _builder.append(_vendorAndName, "                    ");
        _builder.append("InitGeographicalDisplay({{ ");
        _builder.append(objName, "                    ");
        _builder.append(".latitude|");
        String _formatForDB_1 = this._formattingExtensions.formatForDB(appName);
        _builder.append(_formatForDB_1, "                    ");
        _builder.append("_geoData }}, {{ ");
        _builder.append(objName, "                    ");
        _builder.append(".longitude|");
        String _formatForDB_2 = this._formattingExtensions.formatForDB(appName);
        _builder.append(_formatForDB_2, "                    ");
        _builder.append("_geoData }})");
        _builder.newLineIfNotEmpty();
        _builder.append("                ");
        _builder.append("});");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("})(jQuery);");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("/* ]]> */");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("</script>");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("{% endset %}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("{{ pageAddAsset(\'footer\', geoScripts) }}");
        _builder.newLine();
        _builder.append("{% endblock %}");
        _builder.newLine();
      }
    }
    return _builder;
  }
  
  private CharSequence fieldDetails(final Entity it, final String appName) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("<dl>");
    _builder.newLine();
    _builder.append("    ");
    {
      Iterable<DerivedField> _fieldsForDisplayPage = this._modelExtensions.getFieldsForDisplayPage(it);
      for(final DerivedField field : _fieldsForDisplayPage) {
        CharSequence _displayEntry = this.displayEntry(field);
        _builder.append(_displayEntry, "    ");
      }
    }
    _builder.newLineIfNotEmpty();
    {
      boolean _isGeographical = it.isGeographical();
      if (_isGeographical) {
        {
          ArrayList<String> _newArrayList = CollectionLiterals.<String>newArrayList("latitude", "longitude");
          for(final String geoFieldName : _newArrayList) {
            _builder.append("    ");
            _builder.append("{% if ");
            String _formatForCode = this._formattingExtensions.formatForCode(it.getName());
            _builder.append(_formatForCode, "    ");
            _builder.append(".");
            _builder.append(geoFieldName, "    ");
            _builder.append(" is not empty %}");
            _builder.newLineIfNotEmpty();
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("<dt>{{ __(\'");
            String _firstUpper = StringExtensions.toFirstUpper(geoFieldName);
            _builder.append(_firstUpper, "        ");
            _builder.append("\') }}</dt>");
            _builder.newLineIfNotEmpty();
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("<dd>{{ ");
            String _formatForCode_1 = this._formattingExtensions.formatForCode(it.getName());
            _builder.append(_formatForCode_1, "        ");
            _builder.append(".");
            _builder.append(geoFieldName, "        ");
            _builder.append("|");
            String _formatForDB = this._formattingExtensions.formatForDB(appName);
            _builder.append(_formatForDB, "        ");
            _builder.append("_geoData }}</dd>");
            _builder.newLineIfNotEmpty();
            _builder.append("    ");
            _builder.append("{% endif %}");
            _builder.newLine();
          }
        }
      }
    }
    _builder.append("    ");
    {
      final Function1<OneToManyRelationship, Boolean> _function = (OneToManyRelationship it_1) -> {
        return Boolean.valueOf((it_1.isBidirectional() && (it_1.getSource() instanceof Entity)));
      };
      Iterable<OneToManyRelationship> _filter = IterableExtensions.<OneToManyRelationship>filter(Iterables.<OneToManyRelationship>filter(it.getIncoming(), OneToManyRelationship.class), _function);
      for(final OneToManyRelationship relation : _filter) {
        CharSequence _displayEntry_1 = this.displayEntry(relation, Boolean.valueOf(false));
        _builder.append(_displayEntry_1, "    ");
      }
    }
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.newLine();
    _builder.append("</dl>");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence templateHeading(final Entity it, final String appName) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{{ templateTitle");
    {
      boolean _isSkipHookSubscribers = it.isSkipHookSubscribers();
      boolean _not = (!_isSkipHookSubscribers);
      if (_not) {
        _builder.append("|notifyFilters(\'");
        String _formatForDB = this._formattingExtensions.formatForDB(appName);
        _builder.append(_formatForDB);
        _builder.append(".filter_hooks.");
        String _formatForDB_1 = this._formattingExtensions.formatForDB(it.getNameMultiple());
        _builder.append(_formatForDB_1);
        _builder.append(".filter\')");
      }
    }
    _builder.append(" }}");
    {
      boolean _hasVisibleWorkflow = this._workflowExtensions.hasVisibleWorkflow(it);
      if (_hasVisibleWorkflow) {
        _builder.append("{% if routeArea == \'admin\' %} <small>({{ ");
        String _formatForCode = this._formattingExtensions.formatForCode(it.getName());
        _builder.append(_formatForCode);
        _builder.append(".workflowState|");
        String _formatForDB_2 = this._formattingExtensions.formatForDB(appName);
        _builder.append(_formatForDB_2);
        _builder.append("_objectState(false)|lower }})</small>{% endif %}");
      }
    }
    return _builder;
  }
  
  private CharSequence displayEntry(final DerivedField it) {
    StringConcatenation _builder = new StringConcatenation();
    String _xifexpression = null;
    String _name = it.getName();
    boolean _equals = Objects.equal(_name, "workflowState");
    if (_equals) {
      _xifexpression = "state";
    } else {
      _xifexpression = it.getName();
    }
    final String fieldLabel = _xifexpression;
    _builder.newLineIfNotEmpty();
    _builder.append("{% if ");
    String _formatForCode = this._formattingExtensions.formatForCode(it.getEntity().getName());
    _builder.append(_formatForCode);
    _builder.append(".");
    String _formatForCode_1 = this._formattingExtensions.formatForCode(it.getName());
    _builder.append(_formatForCode_1);
    _builder.append(" is not empty");
    {
      String _name_1 = it.getName();
      boolean _equals_1 = Objects.equal(_name_1, "workflowState");
      if (_equals_1) {
        _builder.append(" and routeArea == \'admin\'");
      }
    }
    _builder.append(" %}");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("<dt>{{ __(\'");
    String _formatForDisplayCapital = this._formattingExtensions.formatForDisplayCapital(fieldLabel);
    _builder.append(_formatForDisplayCapital, "    ");
    _builder.append("\') }}</dt>");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("<dd>");
    CharSequence _displayEntryImpl = this.displayEntryImpl(it);
    _builder.append(_displayEntryImpl, "    ");
    _builder.append("</dd>");
    _builder.newLineIfNotEmpty();
    _builder.append("{% endif %}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence displayEntryImpl(final DerivedField it) {
    return new SimpleFields().displayField(it, this._formattingExtensions.formatForCode(it.getEntity().getName()), "display");
  }
  
  private CharSequence displayEntry(final JoinRelationship it, final Boolean useTarget) {
    StringConcatenation _builder = new StringConcatenation();
    final String relationAliasName = this._formattingExtensions.formatForCode(this._namingExtensions.getRelationAliasName(it, useTarget));
    _builder.newLineIfNotEmpty();
    DataObject _xifexpression = null;
    if ((useTarget).booleanValue()) {
      _xifexpression = it.getSource();
    } else {
      _xifexpression = it.getTarget();
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
    final String relObjName = (_plus + relationAliasName);
    _builder.newLineIfNotEmpty();
    _builder.append("{% if ");
    _builder.append(relObjName);
    _builder.append("|default %}");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("<dt>{{ __(\'");
    String _formatForDisplayCapital = this._formattingExtensions.formatForDisplayCapital(relationAliasName);
    _builder.append(_formatForDisplayCapital, "    ");
    _builder.append("\') }}</dt>");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("<dd>");
    _builder.newLine();
    _builder.append("      ");
    _builder.append("{% if not isQuickView %}");
    _builder.newLine();
    {
      boolean _hasDisplayAction = this._controllerExtensions.hasDisplayAction(linkEntity);
      if (_hasDisplayAction) {
        _builder.append("          ");
        _builder.append("<a href=\"{{ path(\'");
        String _formatForDB = this._formattingExtensions.formatForDB(this._utils.appName(linkEntity.getApplication()));
        _builder.append(_formatForDB, "          ");
        _builder.append("_");
        String _lowerCase = linkEntity.getName().toLowerCase();
        _builder.append(_lowerCase, "          ");
        _builder.append("_\' ~ routeArea ~ \'display\'");
        CharSequence _routeParams = this._urlExtensions.routeParams(linkEntity, relObjName, Boolean.valueOf(true));
        _builder.append(_routeParams, "          ");
        _builder.append(") }}\">{% spaceless %}");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("            ");
    _builder.append("{{ ");
    _builder.append(relObjName, "            ");
    _builder.append(".getTitleFromDisplayPattern() }}");
    _builder.newLineIfNotEmpty();
    {
      boolean _hasDisplayAction_1 = this._controllerExtensions.hasDisplayAction(linkEntity);
      if (_hasDisplayAction_1) {
        _builder.append("          ");
        _builder.append("{% endspaceless %}</a>");
        _builder.newLine();
        _builder.append("          ");
        _builder.append("<a id=\"");
        String _formatForCode_1 = this._formattingExtensions.formatForCode(linkEntity.getName());
        _builder.append(_formatForCode_1, "          ");
        _builder.append("Item{{ ");
        {
          Iterable<DerivedField> _primaryKeyFields = this._modelExtensions.getPrimaryKeyFields(linkEntity);
          boolean _hasElements = false;
          for(final DerivedField pkField : _primaryKeyFields) {
            if (!_hasElements) {
              _hasElements = true;
            } else {
              _builder.appendImmediate(" ~ ", "          ");
            }
            _builder.append(relObjName, "          ");
            _builder.append(".");
            String _formatForCode_2 = this._formattingExtensions.formatForCode(pkField.getName());
            _builder.append(_formatForCode_2, "          ");
          }
        }
        _builder.append(" }}Display\" href=\"{{ path(\'");
        String _formatForDB_1 = this._formattingExtensions.formatForDB(this._utils.appName(linkEntity.getApplication()));
        _builder.append(_formatForDB_1, "          ");
        _builder.append("_");
        String _formatForDB_2 = this._formattingExtensions.formatForDB(linkEntity.getName());
        _builder.append(_formatForDB_2, "          ");
        _builder.append("_\' ~ routeArea ~ \'display\', { ");
        CharSequence _routePkParams = this._urlExtensions.routePkParams(linkEntity, relObjName, Boolean.valueOf(true));
        _builder.append(_routePkParams, "          ");
        CharSequence _appendSlug = this._urlExtensions.appendSlug(linkEntity, relObjName, Boolean.valueOf(true));
        _builder.append(_appendSlug, "          ");
        _builder.append(", \'raw\': 1 }) }}\" title=\"{{ __(\'Open quick view window\')|e(\'html_attr\') }}\" class=\"");
        String _lowerCase_1 = this._utils.vendorAndName(it.getApplication()).toLowerCase();
        _builder.append(_lowerCase_1, "          ");
        _builder.append("-inline-window hidden\" data-modal-title=\"{{ ");
        _builder.append(relObjName, "          ");
        _builder.append(".getTitleFromDisplayPattern()|e(\'html_attr\') }}\"><span class=\"fa fa-id-card-o\"></span></a>");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("      ");
    _builder.append("{% else %}");
    _builder.newLine();
    _builder.append("          ");
    _builder.append("{{ ");
    _builder.append(relObjName, "          ");
    _builder.append(".getTitleFromDisplayPattern() }}");
    _builder.newLineIfNotEmpty();
    _builder.append("      ");
    _builder.append("{% endif %}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("</dd>");
    _builder.newLine();
    _builder.append("{% endif %}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence displayExtensions(final Entity it, final String objName) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _isGeographical = it.isGeographical();
      if (_isGeographical) {
        {
          boolean _useGroupingTabs = this._viewExtensions.useGroupingTabs(it, "display");
          if (_useGroupingTabs) {
            _builder.append("<div role=\"tabpanel\" class=\"tab-pane fade\" id=\"tabMap\" aria-labelledby=\"mapTab\">");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("<h3>{{ __(\'Map\') }}</h3>");
            _builder.newLine();
          } else {
            _builder.append("<h3 class=\"");
            String _lowerCase = this._utils.appName(it.getApplication()).toLowerCase();
            _builder.append(_lowerCase);
            _builder.append("-map\">{{ __(\'Map\') }}</h3>");
            _builder.newLineIfNotEmpty();
          }
        }
        _builder.append("<div id=\"mapContainer\" class=\"");
        String _lowerCase_1 = this._utils.appName(it.getApplication()).toLowerCase();
        _builder.append(_lowerCase_1);
        _builder.append("-mapcontainer\">");
        _builder.newLineIfNotEmpty();
        _builder.append("</div>");
        _builder.newLine();
        {
          boolean _useGroupingTabs_1 = this._viewExtensions.useGroupingTabs(it, "display");
          if (_useGroupingTabs_1) {
            _builder.append("</div>");
            _builder.newLine();
          }
        }
      }
    }
    {
      boolean _useGroupingTabs_2 = this._viewExtensions.useGroupingTabs(it, "display");
      if (_useGroupingTabs_2) {
        _builder.append("{{ block(\'related_items\') }}");
        _builder.newLine();
      }
    }
    {
      boolean _isAttributable = it.isAttributable();
      if (_isAttributable) {
        _builder.append("{% if featureActivationHelper.isEnabled(constant(\'");
        String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(it.getApplication().getVendor());
        _builder.append(_formatForCodeCapital);
        _builder.append("\\\\");
        String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(it.getApplication().getName());
        _builder.append(_formatForCodeCapital_1);
        _builder.append("Module\\\\Helper\\\\FeatureActivationHelper::ATTRIBUTES\'), \'");
        String _formatForCode = this._formattingExtensions.formatForCode(it.getName());
        _builder.append(_formatForCode);
        _builder.append("\') %}");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("{{ include(\'@");
        String _appName = this._utils.appName(it.getApplication());
        _builder.append(_appName, "    ");
        _builder.append("/Helper/includeAttributesDisplay.html.twig\', { obj: ");
        _builder.append(objName, "    ");
        {
          boolean _useGroupingTabs_3 = this._viewExtensions.useGroupingTabs(it, "display");
          if (_useGroupingTabs_3) {
            _builder.append(", tabs: true");
          }
        }
        _builder.append(" }) }}");
        _builder.newLineIfNotEmpty();
        _builder.append("{% endif %}");
        _builder.newLine();
      }
    }
    {
      boolean _isCategorisable = it.isCategorisable();
      if (_isCategorisable) {
        _builder.append("{% if featureActivationHelper.isEnabled(constant(\'");
        String _formatForCodeCapital_2 = this._formattingExtensions.formatForCodeCapital(it.getApplication().getVendor());
        _builder.append(_formatForCodeCapital_2);
        _builder.append("\\\\");
        String _formatForCodeCapital_3 = this._formattingExtensions.formatForCodeCapital(it.getApplication().getName());
        _builder.append(_formatForCodeCapital_3);
        _builder.append("Module\\\\Helper\\\\FeatureActivationHelper::CATEGORIES\'), \'");
        String _formatForCode_1 = this._formattingExtensions.formatForCode(it.getName());
        _builder.append(_formatForCode_1);
        _builder.append("\') %}");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("{{ include(\'@");
        String _appName_1 = this._utils.appName(it.getApplication());
        _builder.append(_appName_1, "    ");
        _builder.append("/Helper/includeCategoriesDisplay.html.twig\', { obj: ");
        _builder.append(objName, "    ");
        {
          boolean _useGroupingTabs_4 = this._viewExtensions.useGroupingTabs(it, "display");
          if (_useGroupingTabs_4) {
            _builder.append(", tabs: true");
          }
        }
        _builder.append(" }) }}");
        _builder.newLineIfNotEmpty();
        _builder.append("{% endif %}");
        _builder.newLine();
      }
    }
    {
      EntityTreeType _tree = it.getTree();
      boolean _notEquals = (!Objects.equal(_tree, EntityTreeType.NONE));
      if (_notEquals) {
        _builder.append("{% if featureActivationHelper.isEnabled(constant(\'");
        String _formatForCodeCapital_4 = this._formattingExtensions.formatForCodeCapital(it.getApplication().getVendor());
        _builder.append(_formatForCodeCapital_4);
        _builder.append("\\\\");
        String _formatForCodeCapital_5 = this._formattingExtensions.formatForCodeCapital(it.getApplication().getName());
        _builder.append(_formatForCodeCapital_5);
        _builder.append("Module\\\\Helper\\\\FeatureActivationHelper::TREE_RELATIVES\'), \'");
        String _formatForCode_2 = this._formattingExtensions.formatForCode(it.getName());
        _builder.append(_formatForCode_2);
        _builder.append("\') %}");
        _builder.newLineIfNotEmpty();
        {
          boolean _useGroupingTabs_5 = this._viewExtensions.useGroupingTabs(it, "display");
          if (_useGroupingTabs_5) {
            _builder.append("    ");
            _builder.append("<div role=\"tabpanel\" class=\"tab-pane fade\" id=\"tabRelatives\" aria-labelledby=\"relativesTab\">");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("<h3>{{ __(\'Relatives\') }}</h3>");
            _builder.newLine();
          } else {
            _builder.append("    ");
            _builder.append("<h3 class=\"relatives\">{{ __(\'Relatives\') }}</h3>");
            _builder.newLine();
          }
        }
        _builder.append("        ");
        _builder.append("{{ include(");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("\'@");
        String _appName_2 = this._utils.appName(it.getApplication());
        _builder.append(_appName_2, "            ");
        _builder.append("/");
        String _formatForCodeCapital_6 = this._formattingExtensions.formatForCodeCapital(it.getName());
        _builder.append(_formatForCodeCapital_6, "            ");
        _builder.append("/displayTreeRelatives.html.twig\',");
        _builder.newLineIfNotEmpty();
        _builder.append("            ");
        _builder.append("{ allParents: true, directParent: true, allChildren: true, directChildren: true, predecessors: true, successors: true, preandsuccessors: true }");
        _builder.newLine();
        _builder.append("        ");
        _builder.append(") }}");
        _builder.newLine();
        {
          boolean _useGroupingTabs_6 = this._viewExtensions.useGroupingTabs(it, "display");
          if (_useGroupingTabs_6) {
            _builder.append("    ");
            _builder.append("</div>");
            _builder.newLine();
          }
        }
        _builder.append("{% endif %}");
        _builder.newLine();
      }
    }
    {
      boolean _isStandardFields = it.isStandardFields();
      if (_isStandardFields) {
        _builder.append("{{ include(\'@");
        String _appName_3 = this._utils.appName(it.getApplication());
        _builder.append(_appName_3);
        _builder.append("/Helper/includeStandardFieldsDisplay.html.twig\', { obj: ");
        _builder.append(objName);
        {
          boolean _useGroupingTabs_7 = this._viewExtensions.useGroupingTabs(it, "display");
          if (_useGroupingTabs_7) {
            _builder.append(", tabs: true");
          }
        }
        _builder.append(" }) }}");
        _builder.newLineIfNotEmpty();
      }
    }
    return _builder;
  }
  
  private CharSequence callDisplayHooks(final Entity it, final String appName) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _useGroupingTabs = this._viewExtensions.useGroupingTabs(it, "display");
      if (_useGroupingTabs) {
        _builder.append("<div role=\"tabpanel\" class=\"tab-pane fade\" id=\"tabHooks\" aria-labelledby=\"hooksTab\">");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("<h3>{{ __(\'Hooks\') }}</h3>");
        _builder.newLine();
      }
    }
    _builder.append("{% set hooks = notifyDisplayHooks(eventName=\'");
    String _formatForDB = this._formattingExtensions.formatForDB(appName);
    _builder.append(_formatForDB);
    _builder.append(".ui_hooks.");
    String _formatForDB_1 = this._formattingExtensions.formatForDB(it.getNameMultiple());
    _builder.append(_formatForDB_1);
    _builder.append(".display_view\', id=");
    CharSequence _displayHookId = this.displayHookId(it);
    _builder.append(_displayHookId);
    _builder.append(", urlObject=currentUrlObject) %}");
    _builder.newLineIfNotEmpty();
    _builder.append("{% for providerArea, hook in hooks if providerArea != \'provider.scribite.ui_hooks.editor\' %}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<h4>{{ providerArea }}</h4>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{{ hook }}");
    _builder.newLine();
    _builder.append("{% endfor %}");
    _builder.newLine();
    {
      boolean _useGroupingTabs_1 = this._viewExtensions.useGroupingTabs(it, "display");
      if (_useGroupingTabs_1) {
        _builder.append("</div>");
        _builder.newLine();
      }
    }
    return _builder;
  }
  
  private CharSequence displayHookId(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      Iterable<DerivedField> _primaryKeyFields = this._modelExtensions.getPrimaryKeyFields(it);
      boolean _hasElements = false;
      for(final DerivedField pkField : _primaryKeyFields) {
        if (!_hasElements) {
          _hasElements = true;
        } else {
          _builder.appendImmediate(" ~ ", "");
        }
        String _formatForCode = this._formattingExtensions.formatForCode(it.getName());
        _builder.append(_formatForCode);
        _builder.append(".");
        String _formatForCode_1 = this._formattingExtensions.formatForCode(pkField.getName());
        _builder.append(_formatForCode_1);
      }
    }
    return _builder;
  }
  
  private CharSequence treeRelatives(final Entity it, final String appName) {
    StringConcatenation _builder = new StringConcatenation();
    final String objName = this._formattingExtensions.formatForCode(it.getName());
    _builder.newLineIfNotEmpty();
    final String pluginPrefix = this._formattingExtensions.formatForDB(this._utils.appName(it.getApplication()));
    _builder.newLineIfNotEmpty();
    _builder.append("{# purpose of this template: show different forms of relatives for a given tree node #}");
    _builder.newLine();
    _builder.append("{% import _self as relatives %}");
    _builder.newLine();
    _builder.append("<h3>{{ __(\'Related ");
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(it.getNameMultiple());
    _builder.append(_formatForDisplay);
    _builder.append("\') }}</h3>");
    _builder.newLineIfNotEmpty();
    _builder.append("{% if ");
    _builder.append(objName);
    _builder.append(".lvl > 0 %}");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("{% if allParents is not defined or allParents == true %}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("{% set allParents = ");
    _builder.append(pluginPrefix, "        ");
    _builder.append("_treeSelection(objectType=\'");
    _builder.append(objName, "        ");
    _builder.append("\', node=");
    _builder.append(objName, "        ");
    _builder.append(", target=\'allParents\') %}");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("{% if allParents is not null and allParents is iterable and allParents|length > 0 %}");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("<h4>{{ __(\'All parents\') }}</h4>");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("{{ relatives.list_relatives(allParents) }}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("{% endif %}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{% endif %}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{% if directParent is not defined or directParent == true %}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("{% set directParent = ");
    _builder.append(pluginPrefix, "        ");
    _builder.append("_treeSelection(objectType=\'");
    _builder.append(objName, "        ");
    _builder.append("\', node=");
    _builder.append(objName, "        ");
    _builder.append(", target=\'directParent\') %}");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("{% if directParent is not null %}");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("<h4>{{ __(\'Direct parent\') }}</h4>");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("<ul>");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("<li><a href=\"{{ path(\'");
    String _formatForDB = this._formattingExtensions.formatForDB(appName);
    _builder.append(_formatForDB, "                ");
    _builder.append("_");
    String _lowerCase = objName.toLowerCase();
    _builder.append(_lowerCase, "                ");
    _builder.append("_\' ~ routeArea ~ \'display\'");
    CharSequence _routeParams = this._urlExtensions.routeParams(it, "directParent", Boolean.valueOf(true));
    _builder.append(_routeParams, "                ");
    _builder.append(") }}\" title=\"{{ directParent.getTitleFromDisplayPattern()|e(\'html_attr\') }}\">{{ directParent.getTitleFromDisplayPattern() }}</a></li>");
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    _builder.append("</ul>");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("{% endif %}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{% endif %}");
    _builder.newLine();
    _builder.append("{% endif %}");
    _builder.newLine();
    _builder.append("{% if allChildren is not defined or allChildren == true %}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{% set allChildren = ");
    _builder.append(pluginPrefix, "    ");
    _builder.append("_treeSelection(objectType=\'");
    _builder.append(objName, "    ");
    _builder.append("\', node=");
    _builder.append(objName, "    ");
    _builder.append(", target=\'allChildren\') %}");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("{% if allChildren is not null and allChildren is iterable and allChildren|length > 0 %}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<h4>{{ __(\'All children\') }}</h4>");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("{{ relatives.list_relatives(allChildren) }}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{% endif %}");
    _builder.newLine();
    _builder.append("{% endif %}");
    _builder.newLine();
    _builder.append("{% if directChildren is not defined or directChildren == true %}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{% set directChildren = ");
    _builder.append(pluginPrefix, "    ");
    _builder.append("_treeSelection(objectType=\'");
    _builder.append(objName, "    ");
    _builder.append("\', node=");
    _builder.append(objName, "    ");
    _builder.append(", target=\'directChildren\') %}");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("{% if directChildren is not null and directChildren is iterable and directChildren|length > 0 %}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<h4>{{ __(\'Direct children\') }}</h4>");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("{{ relatives.list_relatives(directChildren) }}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{% endif %}");
    _builder.newLine();
    _builder.append("{% endif %}");
    _builder.newLine();
    _builder.append("{% if ");
    _builder.append(objName);
    _builder.append(".lvl > 0 %}");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("{% if predecessors is not defined or predecessors == true %}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("{% set predecessors = ");
    _builder.append(pluginPrefix, "        ");
    _builder.append("_treeSelection(\'");
    _builder.append(objName, "        ");
    _builder.append("\', node=");
    _builder.append(objName, "        ");
    _builder.append(", target=\'predecessors\') %}");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("{% if predecessors is not null and predecessors is iterable and predecessors|length > 0 %}");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("<h4>{{ __(\'Predecessors\') }}</h4>");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("{{ relatives.list_relatives(predecessors) }}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("{% endif %}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{% endif %}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{% if successors is not defined or successors == true %}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("{% set successors = ");
    _builder.append(pluginPrefix, "        ");
    _builder.append("_treeSelection(objectType=\'");
    _builder.append(objName, "        ");
    _builder.append("\', node=");
    _builder.append(objName, "        ");
    _builder.append(", target=\'successors\') %}");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("{% if successors is not null and successors is iterable and successors|length > 0 %}");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("<h4>{{ __(\'Successors\') }}</h4>");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("{{ relatives.list_relatives(successors) }}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("{% endif %}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{% endif %}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{% if preandsuccessors is not defined or preandsuccessors == true %}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("{% set preandsuccessors = ");
    _builder.append(pluginPrefix, "        ");
    _builder.append("_treeSelection(objectType=\'");
    _builder.append(objName, "        ");
    _builder.append("\', node=");
    _builder.append(objName, "        ");
    _builder.append(", target=\'preandsuccessors\') %}");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("{% if preandsuccessors is not null and preandsuccessors is iterable and preandsuccessors|length > 0 %}");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("<h4>{{ __(\'Siblings\') }}</h4>");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("{{ relatives.list_relatives(preandsuccessors) }}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("{% endif %}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{% endif %}");
    _builder.newLine();
    _builder.append("{% endif %}");
    _builder.newLine();
    _builder.append("{% macro list_relatives(items) %}");
    _builder.newLine();
    _builder.append("    ");
    CharSequence _nodeLoop = this.nodeLoop(it, appName, "items");
    _builder.append(_nodeLoop, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("{% endmacro %}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence nodeLoop(final Entity it, final String appName, final String collectionName) {
    StringConcatenation _builder = new StringConcatenation();
    final String objName = this._formattingExtensions.formatForCode(it.getName());
    _builder.newLineIfNotEmpty();
    _builder.append("<ul>");
    _builder.newLine();
    _builder.append("{% for node in ");
    _builder.append(collectionName);
    _builder.append(" %}");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("<li><a href=\"{{ path(\'");
    String _formatForDB = this._formattingExtensions.formatForDB(appName);
    _builder.append(_formatForDB, "    ");
    _builder.append("_");
    String _lowerCase = objName.toLowerCase();
    _builder.append(_lowerCase, "    ");
    _builder.append("_\' ~ routeArea ~ \'display\'");
    CharSequence _routeParams = this._urlExtensions.routeParams(it, "node", Boolean.valueOf(true));
    _builder.append(_routeParams, "    ");
    _builder.append(") }}\" title=\"{{ node.getTitleFromDisplayPattern()|e(\'html_attr\') }}\">{{ node.getTitleFromDisplayPattern() }}</a></li>");
    _builder.newLineIfNotEmpty();
    _builder.append("{% endfor %}");
    _builder.newLine();
    _builder.append("</ul>");
    _builder.newLine();
    return _builder;
  }
}
