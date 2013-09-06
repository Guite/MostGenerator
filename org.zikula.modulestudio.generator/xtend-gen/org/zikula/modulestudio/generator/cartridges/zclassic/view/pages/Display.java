package org.zikula.modulestudio.generator.cartridges.zclassic.view.pages;

import com.google.common.base.Objects;
import com.google.common.collect.Iterables;
import com.google.inject.Inject;
import de.guite.modulestudio.metamodel.modulestudio.AdminController;
import de.guite.modulestudio.metamodel.modulestudio.Application;
import de.guite.modulestudio.metamodel.modulestudio.BooleanField;
import de.guite.modulestudio.metamodel.modulestudio.Controller;
import de.guite.modulestudio.metamodel.modulestudio.Controllers;
import de.guite.modulestudio.metamodel.modulestudio.DerivedField;
import de.guite.modulestudio.metamodel.modulestudio.Entity;
import de.guite.modulestudio.metamodel.modulestudio.EntityTreeType;
import de.guite.modulestudio.metamodel.modulestudio.JoinRelationship;
import de.guite.modulestudio.metamodel.modulestudio.ManyToManyRelationship;
import de.guite.modulestudio.metamodel.modulestudio.Models;
import de.guite.modulestudio.metamodel.modulestudio.OneToManyRelationship;
import de.guite.modulestudio.metamodel.modulestudio.Relationship;
import java.util.ArrayList;
import org.eclipse.emf.common.util.EList;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.CollectionLiterals;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.InputOutput;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.eclipse.xtext.xbase.lib.StringExtensions;
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
  private ModelExtensions _modelExtensions = new Function0<ModelExtensions>() {
    public ModelExtensions apply() {
      ModelExtensions _modelExtensions = new ModelExtensions();
      return _modelExtensions;
    }
  }.apply();
  
  @Inject
  @Extension
  private ModelJoinExtensions _modelJoinExtensions = new Function0<ModelJoinExtensions>() {
    public ModelJoinExtensions apply() {
      ModelJoinExtensions _modelJoinExtensions = new ModelJoinExtensions();
      return _modelJoinExtensions;
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
  private UrlExtensions _urlExtensions = new Function0<UrlExtensions>() {
    public UrlExtensions apply() {
      UrlExtensions _urlExtensions = new UrlExtensions();
      return _urlExtensions;
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
  
  @Inject
  @Extension
  private ViewExtensions _viewExtensions = new Function0<ViewExtensions>() {
    public ViewExtensions apply() {
      ViewExtensions _viewExtensions = new ViewExtensions();
      return _viewExtensions;
    }
  }.apply();
  
  @Inject
  @Extension
  private WorkflowExtensions _workflowExtensions = new Function0<WorkflowExtensions>() {
    public WorkflowExtensions apply() {
      WorkflowExtensions _workflowExtensions = new WorkflowExtensions();
      return _workflowExtensions;
    }
  }.apply();
  
  public void generate(final Entity it, final String appName, final Controller controller, final IFileSystemAccess fsa) {
    String _formattedName = this._controllerExtensions.formattedName(controller);
    String _plus = ("Generating " + _formattedName);
    String _plus_1 = (_plus + " display templates for entity \"");
    String _name = it.getName();
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(_name);
    String _plus_2 = (_plus_1 + _formatForDisplay);
    String _plus_3 = (_plus_2 + "\"");
    InputOutput.<String>println(_plus_3);
    String _name_1 = it.getName();
    String _templateFile = this._namingExtensions.templateFile(controller, _name_1, "display");
    CharSequence _displayView = this.displayView(it, appName, controller);
    fsa.generateFile(_templateFile, _displayView);
    EntityTreeType _tree = it.getTree();
    boolean _notEquals = (!Objects.equal(_tree, EntityTreeType.NONE));
    if (_notEquals) {
      String _name_2 = it.getName();
      String _templateFile_1 = this._namingExtensions.templateFile(controller, _name_2, "display_treeRelatives");
      CharSequence _treeRelatives = this.treeRelatives(it, appName, controller);
      fsa.generateFile(_templateFile_1, _treeRelatives);
    }
  }
  
  private CharSequence displayView(final Entity it, final String appName, final Controller controller) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{* purpose of this template: ");
    String _nameMultiple = it.getNameMultiple();
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(_nameMultiple);
    _builder.append(_formatForDisplay, "");
    _builder.append(" display view in ");
    String _formattedName = this._controllerExtensions.formattedName(controller);
    _builder.append(_formattedName, "");
    _builder.append(" area *}");
    _builder.newLineIfNotEmpty();
    _builder.append("{include file=\'");
    {
      Models _container = it.getContainer();
      Application _application = _container.getApplication();
      boolean _targets = this._utils.targets(_application, "1.3.5");
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
    Iterable<JoinRelationship> _outgoingJoinRelations = this._modelJoinExtensions.getOutgoingJoinRelations(it);
    final Function1<JoinRelationship,Boolean> _function = new Function1<JoinRelationship,Boolean>() {
      public Boolean apply(final JoinRelationship e) {
        Entity _target = e.getTarget();
        Models _container = _target.getContainer();
        Application _application = _container.getApplication();
        Models _container_1 = it.getContainer();
        Application _application_1 = _container_1.getApplication();
        boolean _equals = Objects.equal(_application, _application_1);
        return Boolean.valueOf(_equals);
      }
    };
    Iterable<JoinRelationship> _filter = IterableExtensions.<JoinRelationship>filter(_outgoingJoinRelations, _function);
    EList<Relationship> _incoming = it.getIncoming();
    Iterable<ManyToManyRelationship> _filter_1 = Iterables.<ManyToManyRelationship>filter(_incoming, ManyToManyRelationship.class);
    final Function1<ManyToManyRelationship,Boolean> _function_1 = new Function1<ManyToManyRelationship,Boolean>() {
      public Boolean apply(final ManyToManyRelationship e) {
        Entity _source = e.getSource();
        Models _container = _source.getContainer();
        Application _application = _container.getApplication();
        Models _container_1 = it.getContainer();
        Application _application_1 = _container_1.getApplication();
        boolean _equals = Objects.equal(_application, _application_1);
        return Boolean.valueOf(_equals);
      }
    };
    Iterable<ManyToManyRelationship> _filter_2 = IterableExtensions.<ManyToManyRelationship>filter(_filter_1, _function_1);
    final Iterable<JoinRelationship> refedElems = Iterables.<JoinRelationship>concat(_filter, _filter_2);
    _builder.newLineIfNotEmpty();
    _builder.append("<div class=\"");
    String _lowerCase = appName.toLowerCase();
    _builder.append(_lowerCase, "");
    _builder.append("-");
    String _name = it.getName();
    String _formatForDB = this._formattingExtensions.formatForDB(_name);
    _builder.append(_formatForDB, "");
    _builder.append(" ");
    String _lowerCase_1 = appName.toLowerCase();
    _builder.append(_lowerCase_1, "");
    _builder.append("-display");
    {
      boolean _isEmpty = IterableExtensions.isEmpty(refedElems);
      boolean _not = (!_isEmpty);
      if (_not) {
        _builder.append(" withrightbox");
      }
    }
    _builder.append("\">");
    _builder.newLineIfNotEmpty();
    String _name_1 = it.getName();
    final String objName = this._formattingExtensions.formatForCode(_name_1);
    _builder.newLineIfNotEmpty();
    final DerivedField leadingField = this._modelExtensions.getLeadingField(it);
    _builder.newLineIfNotEmpty();
    _builder.append("{gt text=\'");
    String _name_2 = it.getName();
    String _formatForDisplayCapital = this._formattingExtensions.formatForDisplayCapital(_name_2);
    _builder.append(_formatForDisplayCapital, "");
    _builder.append("\' assign=\'templateTitle\'}");
    _builder.newLineIfNotEmpty();
    {
      boolean _and = false;
      boolean _tripleNotEquals = (leadingField != null);
      if (!_tripleNotEquals) {
        _and = false;
      } else {
        boolean _showLeadingFieldInTitle = this._modelExtensions.showLeadingFieldInTitle(leadingField);
        _and = (_tripleNotEquals && _showLeadingFieldInTitle);
      }
      if (_and) {
        _builder.append("{assign var=\'templateTitle\' value=$");
        _builder.append(objName, "");
        _builder.append(".");
        String _name_3 = leadingField.getName();
        String _formatForCode = this._formattingExtensions.formatForCode(_name_3);
        _builder.append(_formatForCode, "");
        _builder.append("|default:$templateTitle}");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("{pagesetvar name=\'title\' value=$templateTitle|@html_entity_decode}");
    _builder.newLine();
    CharSequence _templateHeader = this.templateHeader(controller, it, appName);
    _builder.append(_templateHeader, "");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    {
      boolean _isEmpty_1 = IterableExtensions.isEmpty(refedElems);
      boolean _not_1 = (!_isEmpty_1);
      if (_not_1) {
        _builder.append("{if !isset($smarty.get.theme) || $smarty.get.theme ne \'Printer\'}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("<div class=\"");
        String _lowerCase_2 = appName.toLowerCase();
        _builder.append(_lowerCase_2, "    ");
        _builder.append("rightbox\">");
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        Relations _relations = new Relations();
        final Relations relationHelper = _relations;
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        {
          for(final JoinRelationship elem : refedElems) {
            CharSequence _displayRelatedItems = relationHelper.displayRelatedItems(elem, appName, controller, it);
            _builder.append(_displayRelatedItems, "        ");
          }
        }
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("</div>");
        _builder.newLine();
        _builder.append("{/if}");
        _builder.newLine();
      }
    }
    _builder.newLine();
    {
      boolean _useGroupingPanels = this._viewExtensions.useGroupingPanels(it, "display");
      if (_useGroupingPanels) {
        _builder.append("{if !isset($smarty.get.theme) || $smarty.get.theme ne \'Printer\'}");
        _builder.newLine();
        _builder.append("<div class=\"z-panels\" id=\"");
        _builder.append(appName, "");
        _builder.append("_panel\">");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("<h3 id=\"z-panel-header-fields\" class=\"z-panel-header z-panel-indicator z-pointer z-panel-active\">{gt text=\'Fields\'}</h3>");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("<div class=\"z-panel-content z-panel-active\" style=\"overflow: visible\">");
        _builder.newLine();
        _builder.append("{/if}");
        _builder.newLine();
      }
    }
    CharSequence _fieldDetails = this.fieldDetails(it, appName, controller);
    _builder.append(_fieldDetails, "");
    _builder.newLineIfNotEmpty();
    {
      boolean _useGroupingPanels_1 = this._viewExtensions.useGroupingPanels(it, "display");
      if (_useGroupingPanels_1) {
        _builder.append("{if !isset($smarty.get.theme) || $smarty.get.theme ne \'Printer\'}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("</div>");
        _builder.newLine();
        _builder.append("{/if}");
        _builder.newLine();
      }
    }
    CharSequence _displayExtensions = this.displayExtensions(it, controller, objName);
    _builder.append(_displayExtensions, "");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("{if !isset($smarty.get.theme) || $smarty.get.theme ne \'Printer\'}");
    _builder.newLine();
    _builder.append("    ");
    CharSequence _callDisplayHooks = this.callDisplayHooks(it, appName, controller);
    _builder.append(_callDisplayHooks, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    CharSequence _itemActions = this.itemActions(it, appName, controller);
    _builder.append(_itemActions, "    ");
    _builder.newLineIfNotEmpty();
    {
      boolean _useGroupingPanels_2 = this._viewExtensions.useGroupingPanels(it, "display");
      if (_useGroupingPanels_2) {
        _builder.append("    ");
        _builder.append("</div>");
        _builder.newLine();
      }
    }
    {
      boolean _isEmpty_2 = IterableExtensions.isEmpty(refedElems);
      boolean _not_2 = (!_isEmpty_2);
      if (_not_2) {
        _builder.append("    ");
        _builder.append("<br style=\"clear: right\" />");
        _builder.newLine();
      }
    }
    _builder.append("{/if}");
    _builder.newLine();
    _builder.newLine();
    CharSequence _templateFooter = this.templateFooter(controller);
    _builder.append(_templateFooter, "");
    _builder.newLineIfNotEmpty();
    _builder.append("</div>");
    _builder.newLine();
    _builder.append("{include file=\'");
    {
      Models _container_1 = it.getContainer();
      Application _application_1 = _container_1.getApplication();
      boolean _targets_1 = this._utils.targets(_application_1, "1.3.5");
      if (_targets_1) {
        String _formattedName_3 = this._controllerExtensions.formattedName(controller);
        _builder.append(_formattedName_3, "");
      } else {
        String _formattedName_4 = this._controllerExtensions.formattedName(controller);
        String _firstUpper_1 = StringExtensions.toFirstUpper(_formattedName_4);
        _builder.append(_firstUpper_1, "");
      }
    }
    _builder.append("/footer.tpl\'}");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    {
      boolean _or = false;
      boolean _hasBooleansWithAjaxToggleEntity = this._modelExtensions.hasBooleansWithAjaxToggleEntity(it);
      if (_hasBooleansWithAjaxToggleEntity) {
        _or = true;
      } else {
        boolean _useGroupingPanels_3 = this._viewExtensions.useGroupingPanels(it, "display");
        _or = (_hasBooleansWithAjaxToggleEntity || _useGroupingPanels_3);
      }
      if (_or) {
        _builder.append("{if !isset($smarty.get.theme) || $smarty.get.theme ne \'Printer\'}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("<script type=\"text/javascript\">");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("/* <![CDATA[ */");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("document.observe(\'dom:loaded\', function() {");
        _builder.newLine();
        {
          boolean _hasBooleansWithAjaxToggleEntity_1 = this._modelExtensions.hasBooleansWithAjaxToggleEntity(it);
          if (_hasBooleansWithAjaxToggleEntity_1) {
            _builder.append("            ");
            _builder.append("{{assign var=\'itemid\' value=$");
            String _name_4 = it.getName();
            String _formatForCode_1 = this._formattingExtensions.formatForCode(_name_4);
            _builder.append(_formatForCode_1, "            ");
            _builder.append(".");
            DerivedField _firstPrimaryKey = this._modelExtensions.getFirstPrimaryKey(it);
            String _name_5 = _firstPrimaryKey.getName();
            String _formatForCode_2 = this._formattingExtensions.formatForCode(_name_5);
            _builder.append(_formatForCode_2, "            ");
            _builder.append("}}");
            _builder.newLineIfNotEmpty();
            {
              Iterable<BooleanField> _booleansWithAjaxToggleEntity = this._modelExtensions.getBooleansWithAjaxToggleEntity(it);
              for(final BooleanField field : _booleansWithAjaxToggleEntity) {
                _builder.append("                ");
                Models _container_2 = it.getContainer();
                Application _application_2 = _container_2.getApplication();
                String _prefix = _application_2.getPrefix();
                _builder.append(_prefix, "                ");
                _builder.append("InitToggle(\'");
                String _name_6 = it.getName();
                String _formatForCode_3 = this._formattingExtensions.formatForCode(_name_6);
                _builder.append(_formatForCode_3, "                ");
                _builder.append("\', \'");
                String _name_7 = field.getName();
                String _formatForCode_4 = this._formattingExtensions.formatForCode(_name_7);
                _builder.append(_formatForCode_4, "                ");
                _builder.append("\', \'{{$itemid}}\');");
                _builder.newLineIfNotEmpty();
              }
            }
          }
        }
        {
          boolean _useGroupingPanels_4 = this._viewExtensions.useGroupingPanels(it, "display");
          if (_useGroupingPanels_4) {
            _builder.append("            ");
            _builder.append("var panel = new Zikula.UI.Panels(\'");
            _builder.append(appName, "            ");
            _builder.append("_panel\', {");
            _builder.newLineIfNotEmpty();
            _builder.append("            ");
            _builder.append("    ");
            _builder.append("headerSelector: \'h3\',");
            _builder.newLine();
            _builder.append("            ");
            _builder.append("    ");
            _builder.append("headerClassName: \'z-panel-header z-panel-indicator\',");
            _builder.newLine();
            _builder.append("            ");
            _builder.append("    ");
            _builder.append("contentClassName: \'z-panel-content\',");
            _builder.newLine();
            _builder.append("            ");
            _builder.append("    ");
            _builder.append("active: $(\'z-panel-header-fields\')");
            _builder.newLine();
            _builder.append("            ");
            _builder.append("});");
            _builder.newLine();
          }
        }
        _builder.append("        ");
        _builder.append("});");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("/* ]]> */");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("</script>");
        _builder.newLine();
        _builder.append("{/if}");
        _builder.newLine();
      }
    }
    return _builder;
  }
  
  private CharSequence fieldDetails(final Entity it, final String appName, final Controller controller) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("<dl>");
    _builder.newLine();
    _builder.append("    ");
    {
      Iterable<DerivedField> _leadingDisplayFields = this._modelExtensions.getLeadingDisplayFields(it);
      for(final DerivedField field : _leadingDisplayFields) {
        CharSequence _displayEntry = this.displayEntry(field, controller);
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
            _builder.append("<dt>{gt text=\'");
            String _firstUpper = StringExtensions.toFirstUpper(geoFieldName);
            _builder.append(_firstUpper, "    ");
            _builder.append("\'}</dt>");
            _builder.newLineIfNotEmpty();
            _builder.append("    ");
            _builder.append("<dd>{$");
            String _name = it.getName();
            String _formatForCode = this._formattingExtensions.formatForCode(_name);
            _builder.append(_formatForCode, "    ");
            _builder.append(".");
            _builder.append(geoFieldName, "    ");
            _builder.append("|");
            String _formatForDB = this._formattingExtensions.formatForDB(appName);
            _builder.append(_formatForDB, "    ");
            _builder.append("FormatGeoData}</dd>");
            _builder.newLineIfNotEmpty();
          }
        }
      }
    }
    {
      boolean _isSoftDeleteable = it.isSoftDeleteable();
      if (_isSoftDeleteable) {
        _builder.append("    ");
        _builder.append("<dt>{gt text=\'Deleted at\'}</dt>");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("<dd>{$");
        String _name_1 = it.getName();
        String _formatForCode_1 = this._formattingExtensions.formatForCode(_name_1);
        _builder.append(_formatForCode_1, "    ");
        _builder.append(".deletedAt|dateformat:\'datebrief\'}</dd>");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("    ");
    {
      EList<Relationship> _incoming = it.getIncoming();
      Iterable<OneToManyRelationship> _filter = Iterables.<OneToManyRelationship>filter(_incoming, OneToManyRelationship.class);
      final Function1<OneToManyRelationship,Boolean> _function = new Function1<OneToManyRelationship,Boolean>() {
        public Boolean apply(final OneToManyRelationship e) {
          boolean _isBidirectional = e.isBidirectional();
          return Boolean.valueOf(_isBidirectional);
        }
      };
      Iterable<OneToManyRelationship> _filter_1 = IterableExtensions.<OneToManyRelationship>filter(_filter, _function);
      for(final OneToManyRelationship relation : _filter_1) {
        CharSequence _displayEntry_1 = this.displayEntry(relation, controller, Boolean.valueOf(false));
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
  
  private CharSequence templateHeader(final Controller it, final Entity entity, final String appName) {
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
        _builder.append("{icon type=\'display\' size=\'small\' __alt=\'Details\'}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("<h3>");
        CharSequence _templateHeading = this.templateHeading(entity, appName);
        _builder.append(_templateHeading, "    ");
        _builder.append("</h3>");
        _builder.newLineIfNotEmpty();
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
      _builder.append("<h2>");
      CharSequence _templateHeading = this.templateHeading(entity, appName);
      _builder.append(_templateHeading, "    ");
      _builder.append("</h2>");
      _builder.newLineIfNotEmpty();
      _switchResult = _builder;
    }
    return _switchResult;
  }
  
  private CharSequence templateHeading(final Entity it, final String appName) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{$templateTitle|notifyfilters:\'");
    String _formatForDB = this._formattingExtensions.formatForDB(appName);
    _builder.append(_formatForDB, "");
    _builder.append(".filter_hooks.");
    String _nameMultiple = it.getNameMultiple();
    String _formatForDB_1 = this._formattingExtensions.formatForDB(_nameMultiple);
    _builder.append(_formatForDB_1, "");
    _builder.append(".filter\'}");
    {
      boolean _hasVisibleWorkflow = this._workflowExtensions.hasVisibleWorkflow(it);
      if (_hasVisibleWorkflow) {
        _builder.append(" ({$");
        String _name = it.getName();
        String _formatForCode = this._formattingExtensions.formatForCode(_name);
        _builder.append(_formatForCode, "");
        _builder.append(".workflowState|");
        String _formatForDB_2 = this._formattingExtensions.formatForDB(appName);
        _builder.append(_formatForDB_2, "");
        _builder.append("ObjectState:false|lower})");
      }
    }
    _builder.append("{icon id=\'itemactionstrigger\' type=\'options\' size=\'extrasmall\' __alt=\'Actions\' class=\'z-pointer z-hide\'}");
    return _builder;
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
  
  private CharSequence displayEntry(final DerivedField it, final Controller controller) {
    StringConcatenation _builder = new StringConcatenation();
    String _xifexpression = null;
    String _name = it.getName();
    boolean _equals = Objects.equal(_name, "workflowState");
    if (_equals) {
      _xifexpression = "state";
    } else {
      String _name_1 = it.getName();
      _xifexpression = _name_1;
    }
    final String fieldLabel = _xifexpression;
    _builder.newLineIfNotEmpty();
    _builder.append("<dt>{gt text=\'");
    String _formatForDisplayCapital = this._formattingExtensions.formatForDisplayCapital(fieldLabel);
    _builder.append(_formatForDisplayCapital, "");
    _builder.append("\'}</dt>");
    _builder.newLineIfNotEmpty();
    _builder.append("<dd>");
    CharSequence _displayEntryImpl = this.displayEntryImpl(it);
    _builder.append(_displayEntryImpl, "");
    _builder.append("</dd>");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence displayEntryImpl(final DerivedField it) {
    SimpleFields _simpleFields = new SimpleFields();
    Entity _entity = it.getEntity();
    String _name = _entity.getName();
    String _formatForCode = this._formattingExtensions.formatForCode(_name);
    CharSequence _displayField = _simpleFields.displayField(it, _formatForCode, "display");
    return _displayField;
  }
  
  private CharSequence displayEntry(final JoinRelationship it, final Controller controller, final Boolean useTarget) {
    StringConcatenation _builder = new StringConcatenation();
    String _relationAliasName = this._namingExtensions.getRelationAliasName(it, useTarget);
    final String relationAliasName = this._formattingExtensions.formatForCodeCapital(_relationAliasName);
    _builder.newLineIfNotEmpty();
    Entity _xifexpression = null;
    if ((useTarget).booleanValue()) {
      Entity _source = it.getSource();
      _xifexpression = _source;
    } else {
      Entity _target = it.getTarget();
      _xifexpression = _target;
    }
    final Entity mainEntity = _xifexpression;
    _builder.newLineIfNotEmpty();
    Entity _xifexpression_1 = null;
    if ((useTarget).booleanValue()) {
      Entity _target_1 = it.getTarget();
      _xifexpression_1 = _target_1;
    } else {
      Entity _source_1 = it.getSource();
      _xifexpression_1 = _source_1;
    }
    final Entity linkEntity = _xifexpression_1;
    _builder.newLineIfNotEmpty();
    String _name = mainEntity.getName();
    String _formatForCode = this._formattingExtensions.formatForCode(_name);
    String _plus = (_formatForCode + ".");
    final String relObjName = (_plus + relationAliasName);
    _builder.newLineIfNotEmpty();
    _builder.append("<dt>{gt text=\'");
    String _formatForDisplayCapital = this._formattingExtensions.formatForDisplayCapital(relationAliasName);
    _builder.append(_formatForDisplayCapital, "");
    _builder.append("\'}</dt>");
    _builder.newLineIfNotEmpty();
    _builder.append("<dd>");
    _builder.newLine();
    _builder.append("{if isset($");
    _builder.append(relObjName, "");
    _builder.append(") && $");
    _builder.append(relObjName, "");
    _builder.append(" ne null}");
    _builder.newLineIfNotEmpty();
    _builder.append("  ");
    _builder.append("{if !isset($smarty.get.theme) || $smarty.get.theme ne \'Printer\'}");
    _builder.newLine();
    _builder.append("  ");
    Models _container = it.getContainer();
    Application _application = _container.getApplication();
    Controller linkController = this._controllerExtensions.getLinkController(_application, controller, linkEntity);
    _builder.newLineIfNotEmpty();
    {
      boolean _tripleNotEquals = (linkController != null);
      if (_tripleNotEquals) {
        _builder.append("  ");
        _builder.append("<a href=\"{modurl modname=\'");
        Models _container_1 = linkEntity.getContainer();
        Application _application_1 = _container_1.getApplication();
        String _appName = this._utils.appName(_application_1);
        _builder.append(_appName, "  ");
        _builder.append("\' type=\'");
        String _formattedName = this._controllerExtensions.formattedName(linkController);
        _builder.append(_formattedName, "  ");
        _builder.append("\' ");
        String _modUrlDisplay = this._urlExtensions.modUrlDisplay(linkEntity, relObjName, Boolean.valueOf(true));
        _builder.append(_modUrlDisplay, "  ");
        _builder.append("}\">{strip}");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("    ");
    final DerivedField leadingField = this._modelExtensions.getLeadingField(linkEntity);
    _builder.newLineIfNotEmpty();
    {
      boolean _tripleNotEquals_1 = (leadingField != null);
      if (_tripleNotEquals_1) {
        _builder.append("    ");
        _builder.append("{$");
        _builder.append(relObjName, "    ");
        _builder.append(".");
        String _name_1 = leadingField.getName();
        String _formatForCode_1 = this._formattingExtensions.formatForCode(_name_1);
        _builder.append(_formatForCode_1, "    ");
        _builder.append("|default:\"\"}");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("    ");
        _builder.append("{gt text=\'");
        String _name_2 = linkEntity.getName();
        String _formatForDisplayCapital_1 = this._formattingExtensions.formatForDisplayCapital(_name_2);
        _builder.append(_formatForDisplayCapital_1, "    ");
        _builder.append("\'}");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      boolean _tripleNotEquals_2 = (linkController != null);
      if (_tripleNotEquals_2) {
        _builder.append("  ");
        _builder.append("{/strip}</a>");
        _builder.newLine();
        _builder.append("  ");
        _builder.append("<a id=\"");
        String _name_3 = linkEntity.getName();
        String _formatForCode_2 = this._formattingExtensions.formatForCode(_name_3);
        _builder.append(_formatForCode_2, "  ");
        _builder.append("Item");
        {
          Iterable<DerivedField> _primaryKeyFields = this._modelExtensions.getPrimaryKeyFields(linkEntity);
          for(final DerivedField pkField : _primaryKeyFields) {
            _builder.append("{$");
            _builder.append(relObjName, "  ");
            _builder.append(".");
            String _name_4 = pkField.getName();
            String _formatForCode_3 = this._formattingExtensions.formatForCode(_name_4);
            _builder.append(_formatForCode_3, "  ");
            _builder.append("}");
          }
        }
        _builder.append("Display\" href=\"{modurl modname=\'");
        Models _container_2 = linkEntity.getContainer();
        Application _application_2 = _container_2.getApplication();
        String _appName_1 = this._utils.appName(_application_2);
        _builder.append(_appName_1, "  ");
        _builder.append("\' type=\'");
        String _formattedName_1 = this._controllerExtensions.formattedName(linkController);
        _builder.append(_formattedName_1, "  ");
        _builder.append("\' ");
        String _modUrlDisplay_1 = this._urlExtensions.modUrlDisplay(linkEntity, relObjName, Boolean.valueOf(true));
        _builder.append(_modUrlDisplay_1, "  ");
        _builder.append(" theme=\'Printer\'");
        String _additionalUrlParametersForQuickViewLink = this._viewExtensions.additionalUrlParametersForQuickViewLink(controller);
        _builder.append(_additionalUrlParametersForQuickViewLink, "  ");
        _builder.append("}\" title=\"{gt text=\'Open quick view window\'}\" class=\"z-hide\">{icon type=\'view\' size=\'extrasmall\' __alt=\'Quick view\'}</a>");
        _builder.newLineIfNotEmpty();
        _builder.append("  ");
        _builder.append("<script type=\"text/javascript\">");
        _builder.newLine();
        _builder.append("  ");
        _builder.append("/* <![CDATA[ */");
        _builder.newLine();
        _builder.append("  ");
        _builder.append("    ");
        _builder.append("document.observe(\'dom:loaded\', function() {");
        _builder.newLine();
        _builder.append("  ");
        _builder.append("        ");
        final DerivedField leadingLinkField = this._modelExtensions.getLeadingField(linkEntity);
        _builder.newLineIfNotEmpty();
        {
          boolean _tripleNotEquals_3 = (leadingLinkField != null);
          if (_tripleNotEquals_3) {
            _builder.append("  ");
            _builder.append("        ");
            Models _container_3 = it.getContainer();
            Application _application_3 = _container_3.getApplication();
            String _prefix = _application_3.getPrefix();
            _builder.append(_prefix, "          ");
            _builder.append("InitInlineWindow($(\'");
            String _name_5 = linkEntity.getName();
            String _formatForCode_4 = this._formattingExtensions.formatForCode(_name_5);
            _builder.append(_formatForCode_4, "          ");
            _builder.append("Item");
            {
              Iterable<DerivedField> _primaryKeyFields_1 = this._modelExtensions.getPrimaryKeyFields(linkEntity);
              boolean _hasElements = false;
              for(final DerivedField pkField_1 : _primaryKeyFields_1) {
                if (!_hasElements) {
                  _hasElements = true;
                } else {
                  _builder.appendImmediate("_", "          ");
                }
                _builder.append("{{$");
                _builder.append(relObjName, "          ");
                _builder.append(".");
                String _name_6 = pkField_1.getName();
                String _formatForCode_5 = this._formattingExtensions.formatForCode(_name_6);
                _builder.append(_formatForCode_5, "          ");
                _builder.append("}}");
              }
            }
            _builder.append("Display\'), \'{{$");
            _builder.append(relObjName, "          ");
            _builder.append(".");
            String _name_7 = leadingLinkField.getName();
            String _formatForCode_6 = this._formattingExtensions.formatForCode(_name_7);
            _builder.append(_formatForCode_6, "          ");
            _builder.append("|replace:\"\'\":\"\"}}\');");
            _builder.newLineIfNotEmpty();
          } else {
            _builder.append("  ");
            _builder.append("        ");
            Models _container_4 = it.getContainer();
            Application _application_4 = _container_4.getApplication();
            String _prefix_1 = _application_4.getPrefix();
            _builder.append(_prefix_1, "          ");
            _builder.append("InitInlineWindow($(\'");
            String _name_8 = linkEntity.getName();
            String _formatForCode_7 = this._formattingExtensions.formatForCode(_name_8);
            _builder.append(_formatForCode_7, "          ");
            _builder.append("Item");
            {
              Iterable<DerivedField> _primaryKeyFields_2 = this._modelExtensions.getPrimaryKeyFields(linkEntity);
              boolean _hasElements_1 = false;
              for(final DerivedField pkField_2 : _primaryKeyFields_2) {
                if (!_hasElements_1) {
                  _hasElements_1 = true;
                } else {
                  _builder.appendImmediate("_", "          ");
                }
                _builder.append("{{$");
                _builder.append(relObjName, "          ");
                _builder.append(".");
                String _name_9 = pkField_2.getName();
                String _formatForCode_8 = this._formattingExtensions.formatForCode(_name_9);
                _builder.append(_formatForCode_8, "          ");
                _builder.append("}}");
              }
            }
            _builder.append("Display\'), \'{{gt text=\'");
            String _name_10 = linkEntity.getName();
            String _formatForDisplayCapital_2 = this._formattingExtensions.formatForDisplayCapital(_name_10);
            _builder.append(_formatForDisplayCapital_2, "          ");
            _builder.append("\'|replace:\"\'\":\"\"}}\');");
            _builder.newLineIfNotEmpty();
          }
        }
        _builder.append("  ");
        _builder.append("    ");
        _builder.append("});");
        _builder.newLine();
        _builder.append("  ");
        _builder.append("/* ]]> */");
        _builder.newLine();
        _builder.append("  ");
        _builder.append("</script>");
        _builder.newLine();
      }
    }
    _builder.append("  ");
    _builder.append("{else}");
    _builder.newLine();
    {
      boolean _tripleNotEquals_4 = (leadingField != null);
      if (_tripleNotEquals_4) {
        _builder.append("{$");
        _builder.append(relObjName, "");
        _builder.append(".");
        String _name_11 = leadingField.getName();
        String _formatForCode_9 = this._formattingExtensions.formatForCode(_name_11);
        _builder.append(_formatForCode_9, "");
        _builder.append("|default:\"\"}");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("{gt text=\'");
        String _name_12 = linkEntity.getName();
        String _formatForDisplayCapital_3 = this._formattingExtensions.formatForDisplayCapital(_name_12);
        _builder.append(_formatForDisplayCapital_3, "");
        _builder.append("\'}");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("  ");
    _builder.append("{/if}");
    _builder.newLine();
    _builder.append("{else}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{gt text=\'Not set.\'}");
    _builder.newLine();
    _builder.append("{/if}");
    _builder.newLine();
    _builder.append("</dd>");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence itemActions(final Entity it, final String appName, final Controller controller) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{if count($");
    String _name = it.getName();
    String _formatForCode = this._formattingExtensions.formatForCode(_name);
    _builder.append(_formatForCode, "");
    _builder.append("._actions) gt 0}");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    CharSequence _itemActionsImpl = this.itemActionsImpl(it, appName, controller);
    _builder.append(_itemActionsImpl, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("{/if}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence itemActionsImpl(final Entity it, final String appName, final Controller controller) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("<p id=\"itemactions\">");
    _builder.newLine();
    _builder.append("{foreach item=\'option\' from=$");
    String _name = it.getName();
    String _formatForCode = this._formattingExtensions.formatForCode(_name);
    _builder.append(_formatForCode, "");
    _builder.append("._actions}");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("<a href=\"{$option.url.type|");
    String _formatForDB = this._formattingExtensions.formatForDB(appName);
    _builder.append(_formatForDB, "    ");
    _builder.append("ActionUrl:$option.url.func:$option.url.arguments}\" title=\"{$option.linkTitle|safetext}\" class=\"z-icon-es-{$option.icon}\">{$option.linkText|safetext}</a>");
    _builder.newLineIfNotEmpty();
    _builder.append("{/foreach}");
    _builder.newLine();
    _builder.append("</p>");
    _builder.newLine();
    _builder.append("<script type=\"text/javascript\">");
    _builder.newLine();
    _builder.append("/* <![CDATA[ */");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("document.observe(\'dom:loaded\', function() {");
    _builder.newLine();
    _builder.append("        ");
    Models _container = it.getContainer();
    Application _application = _container.getApplication();
    String _prefix = _application.getPrefix();
    _builder.append(_prefix, "        ");
    _builder.append("InitItemActions(\'");
    String _name_1 = it.getName();
    String _formatForCode_1 = this._formattingExtensions.formatForCode(_name_1);
    _builder.append(_formatForCode_1, "        ");
    _builder.append("\', \'display\', \'itemactions\');");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("});");
    _builder.newLine();
    _builder.append("/* ]]> */");
    _builder.newLine();
    _builder.append("</script>");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence displayExtensions(final Entity it, final Controller controller, final String objName) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _isGeographical = it.isGeographical();
      if (_isGeographical) {
        {
          boolean _useGroupingPanels = this._viewExtensions.useGroupingPanels(it, "display");
          if (_useGroupingPanels) {
            _builder.append("<h3 class=\"");
            Models _container = it.getContainer();
            Application _application = _container.getApplication();
            String _appName = this._utils.appName(_application);
            String _formatForDB = this._formattingExtensions.formatForDB(_appName);
            _builder.append(_formatForDB, "");
            _builder.append("map z-panel-header z-panel-indicator z-pointer\">{gt text=\'Map\'}</h3>");
            _builder.newLineIfNotEmpty();
            _builder.append("<div class=\"");
            Models _container_1 = it.getContainer();
            Application _application_1 = _container_1.getApplication();
            String _appName_1 = this._utils.appName(_application_1);
            String _formatForDB_1 = this._formattingExtensions.formatForDB(_appName_1);
            _builder.append(_formatForDB_1, "");
            _builder.append("map z-panel-content\" style=\"display: none\">");
            _builder.newLineIfNotEmpty();
          } else {
            _builder.append("<h3 class=\"");
            Models _container_2 = it.getContainer();
            Application _application_2 = _container_2.getApplication();
            String _appName_2 = this._utils.appName(_application_2);
            String _formatForDB_2 = this._formattingExtensions.formatForDB(_appName_2);
            _builder.append(_formatForDB_2, "");
            _builder.append("map\">{gt text=\'Map\'}</h3>");
            _builder.newLineIfNotEmpty();
          }
        }
        _builder.append("{pageaddvarblock name=\'header\'}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("<script type=\"text/javascript\" src=\"http://maps.google.com/maps/api/js?sensor=false\"></script>");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("<script type=\"text/javascript\" src=\"{$baseurl}plugins/Mapstraction/lib/vendor/mxn/mxn.js?(googlev3)\"></script>");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("<script type=\"text/javascript\">");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("/* <![CDATA[ */");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("var mapstraction;");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("Event.observe(window, \'load\', function() {");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("mapstraction = new mxn.Mapstraction(\'mapcontainer\', \'googlev3\');");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("mapstraction.addControls({");
        _builder.newLine();
        _builder.append("                ");
        _builder.append("pan: true,");
        _builder.newLine();
        _builder.append("                ");
        _builder.append("zoom: \'small\',");
        _builder.newLine();
        _builder.append("                ");
        _builder.append("map_type: true");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("});");
        _builder.newLine();
        _builder.newLine();
        _builder.append("            ");
        _builder.append("var latlon = new mxn.LatLonPoint({{$");
        _builder.append(objName, "            ");
        _builder.append(".latitude|");
        Models _container_3 = it.getContainer();
        Application _application_3 = _container_3.getApplication();
        String _name = _application_3.getName();
        String _formatForDB_3 = this._formattingExtensions.formatForDB(_name);
        _builder.append(_formatForDB_3, "            ");
        _builder.append("FormatGeoData}}, {{$");
        _builder.append(objName, "            ");
        _builder.append(".longitude|");
        Models _container_4 = it.getContainer();
        Application _application_4 = _container_4.getApplication();
        String _name_1 = _application_4.getName();
        String _formatForDB_4 = this._formattingExtensions.formatForDB(_name_1);
        _builder.append(_formatForDB_4, "            ");
        _builder.append("FormatGeoData}});");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
        _builder.append("            ");
        _builder.append("mapstraction.setMapType(mxn.Mapstraction.SATELLITE);");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("mapstraction.setCenterAndZoom(latlon, 18);");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("mapstraction.mousePosition(\'position\');");
        _builder.newLine();
        _builder.newLine();
        _builder.append("            ");
        _builder.append("// add a marker");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("var marker = new mxn.Marker(latlon);");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("mapstraction.addMarker(marker, true);");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("});");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("/* ]]> */");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("</script>");
        _builder.newLine();
        _builder.append("{/pageaddvarblock}");
        _builder.newLine();
        _builder.append("<div id=\"mapcontainer\" class=\"");
        Controllers _container_5 = controller.getContainer();
        Application _application_5 = _container_5.getApplication();
        String _appName_3 = this._utils.appName(_application_5);
        String _lowerCase = _appName_3.toLowerCase();
        _builder.append(_lowerCase, "");
        _builder.append("mapcontainer\">");
        _builder.newLineIfNotEmpty();
        _builder.append("</div>");
        _builder.newLine();
      }
    }
    {
      boolean _isAttributable = it.isAttributable();
      if (_isAttributable) {
        _builder.append("{include file=\'");
        {
          Models _container_6 = it.getContainer();
          Application _application_6 = _container_6.getApplication();
          boolean _targets = this._utils.targets(_application_6, "1.3.5");
          if (_targets) {
            String _formattedName = this._controllerExtensions.formattedName(controller);
            _builder.append(_formattedName, "");
          } else {
            String _formattedName_1 = this._controllerExtensions.formattedName(controller);
            String _firstUpper = StringExtensions.toFirstUpper(_formattedName_1);
            _builder.append(_firstUpper, "");
          }
        }
        _builder.append("/include_attributes_display.tpl\' obj=$");
        _builder.append(objName, "");
        {
          boolean _useGroupingPanels_1 = this._viewExtensions.useGroupingPanels(it, "display");
          if (_useGroupingPanels_1) {
            _builder.append(" panel=true");
          }
        }
        _builder.append("}");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      boolean _isCategorisable = it.isCategorisable();
      if (_isCategorisable) {
        _builder.append("{include file=\'");
        {
          Models _container_7 = it.getContainer();
          Application _application_7 = _container_7.getApplication();
          boolean _targets_1 = this._utils.targets(_application_7, "1.3.5");
          if (_targets_1) {
            String _formattedName_2 = this._controllerExtensions.formattedName(controller);
            _builder.append(_formattedName_2, "");
          } else {
            String _formattedName_3 = this._controllerExtensions.formattedName(controller);
            String _firstUpper_1 = StringExtensions.toFirstUpper(_formattedName_3);
            _builder.append(_firstUpper_1, "");
          }
        }
        _builder.append("/include_categories_display.tpl\' obj=$");
        _builder.append(objName, "");
        {
          boolean _useGroupingPanels_2 = this._viewExtensions.useGroupingPanels(it, "display");
          if (_useGroupingPanels_2) {
            _builder.append(" panel=true");
          }
        }
        _builder.append("}");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      EntityTreeType _tree = it.getTree();
      boolean _notEquals = (!Objects.equal(_tree, EntityTreeType.NONE));
      if (_notEquals) {
        {
          boolean _useGroupingPanels_3 = this._viewExtensions.useGroupingPanels(it, "display");
          if (_useGroupingPanels_3) {
            _builder.append("<h3 class=\"relatives z-panel-header z-panel-indicator z-pointer\">{gt text=\'Relatives\'}</h3>");
            _builder.newLine();
            _builder.append("<div class=\"relatives z-panel-content\" style=\"display: none\">");
            _builder.newLine();
          } else {
            _builder.append("<h3 class=\"relatives\">{gt text=\'Relatives\'}</h3>");
            _builder.newLine();
          }
        }
        _builder.append("        ");
        _builder.append("{include file=\'");
        {
          Models _container_8 = it.getContainer();
          Application _application_8 = _container_8.getApplication();
          boolean _targets_2 = this._utils.targets(_application_8, "1.3.5");
          if (_targets_2) {
            String _formattedName_4 = this._controllerExtensions.formattedName(controller);
            _builder.append(_formattedName_4, "        ");
            _builder.append("/");
            String _name_2 = it.getName();
            String _formatForCode = this._formattingExtensions.formatForCode(_name_2);
            _builder.append(_formatForCode, "        ");
          } else {
            String _formattedName_5 = this._controllerExtensions.formattedName(controller);
            String _firstUpper_2 = StringExtensions.toFirstUpper(_formattedName_5);
            _builder.append(_firstUpper_2, "        ");
            _builder.append("/");
            String _name_3 = it.getName();
            String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(_name_3);
            _builder.append(_formatForCodeCapital, "        ");
          }
        }
        _builder.append("/display_treeRelatives.tpl\' allParents=true directParent=true allChildren=true directChildren=true predecessors=true successors=true preandsuccessors=true}");
        _builder.newLineIfNotEmpty();
        {
          boolean _useGroupingPanels_4 = this._viewExtensions.useGroupingPanels(it, "display");
          if (_useGroupingPanels_4) {
            _builder.append("</div>");
            _builder.newLine();
          }
        }
      }
    }
    {
      boolean _isMetaData = it.isMetaData();
      if (_isMetaData) {
        _builder.append("{include file=\'");
        {
          Models _container_9 = it.getContainer();
          Application _application_9 = _container_9.getApplication();
          boolean _targets_3 = this._utils.targets(_application_9, "1.3.5");
          if (_targets_3) {
            String _formattedName_6 = this._controllerExtensions.formattedName(controller);
            _builder.append(_formattedName_6, "");
          } else {
            String _formattedName_7 = this._controllerExtensions.formattedName(controller);
            String _firstUpper_3 = StringExtensions.toFirstUpper(_formattedName_7);
            _builder.append(_firstUpper_3, "");
          }
        }
        _builder.append("/include_metadata_display.tpl\' obj=$");
        _builder.append(objName, "");
        {
          boolean _useGroupingPanels_5 = this._viewExtensions.useGroupingPanels(it, "display");
          if (_useGroupingPanels_5) {
            _builder.append(" panel=true");
          }
        }
        _builder.append("}");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      boolean _isStandardFields = it.isStandardFields();
      if (_isStandardFields) {
        _builder.append("{include file=\'");
        {
          Models _container_10 = it.getContainer();
          Application _application_10 = _container_10.getApplication();
          boolean _targets_4 = this._utils.targets(_application_10, "1.3.5");
          if (_targets_4) {
            String _formattedName_8 = this._controllerExtensions.formattedName(controller);
            _builder.append(_formattedName_8, "");
          } else {
            String _formattedName_9 = this._controllerExtensions.formattedName(controller);
            String _firstUpper_4 = StringExtensions.toFirstUpper(_formattedName_9);
            _builder.append(_firstUpper_4, "");
          }
        }
        _builder.append("/include_standardfields_display.tpl\' obj=$");
        _builder.append(objName, "");
        {
          boolean _useGroupingPanels_6 = this._viewExtensions.useGroupingPanels(it, "display");
          if (_useGroupingPanels_6) {
            _builder.append(" panel=true");
          }
        }
        _builder.append("}");
        _builder.newLineIfNotEmpty();
      }
    }
    return _builder;
  }
  
  private CharSequence callDisplayHooks(final Entity it, final String appName, final Controller controller) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{* include display hooks *}");
    _builder.newLine();
    _builder.append("{notifydisplayhooks eventname=\'");
    String _formatForDB = this._formattingExtensions.formatForDB(appName);
    _builder.append(_formatForDB, "");
    _builder.append(".ui_hooks.");
    String _nameMultiple = it.getNameMultiple();
    String _formatForDB_1 = this._formattingExtensions.formatForDB(_nameMultiple);
    _builder.append(_formatForDB_1, "");
    _builder.append(".display_view\' id=");
    CharSequence _displayHookId = this.displayHookId(it);
    _builder.append(_displayHookId, "");
    _builder.append(" urlobject=$currentUrlObject assign=\'hooks\'}");
    _builder.newLineIfNotEmpty();
    _builder.append("{foreach key=\'providerArea\' item=\'hook\' from=$hooks}");
    _builder.newLine();
    {
      boolean _useGroupingPanels = this._viewExtensions.useGroupingPanels(it, "display");
      if (_useGroupingPanels) {
        _builder.append("    ");
        _builder.append("<h3 class=\"z-panel-header z-panel-indicator z-pointer\">{$providerArea}</h3>");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("<div class=\"z-panel-content\" style=\"display: none\">{$hook}</div>");
        _builder.newLine();
      } else {
        _builder.append("    ");
        _builder.append("{$hook}");
        _builder.newLine();
      }
    }
    _builder.append("{/foreach}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence displayHookId(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _hasCompositeKeys = this._modelExtensions.hasCompositeKeys(it);
      boolean _not = (!_hasCompositeKeys);
      if (_not) {
        _builder.append("$");
        String _name = it.getName();
        String _formatForCode = this._formattingExtensions.formatForCode(_name);
        _builder.append(_formatForCode, "");
        _builder.append(".");
        DerivedField _firstPrimaryKey = this._modelExtensions.getFirstPrimaryKey(it);
        String _name_1 = _firstPrimaryKey.getName();
        String _formatForCode_1 = this._formattingExtensions.formatForCode(_name_1);
        _builder.append(_formatForCode_1, "");
      } else {
        _builder.append("\"");
        {
          Iterable<DerivedField> _primaryKeyFields = this._modelExtensions.getPrimaryKeyFields(it);
          boolean _hasElements = false;
          for(final DerivedField pkField : _primaryKeyFields) {
            if (!_hasElements) {
              _hasElements = true;
            } else {
              _builder.appendImmediate("_", "");
            }
            _builder.append("`$");
            String _name_2 = it.getName();
            String _formatForCode_2 = this._formattingExtensions.formatForCode(_name_2);
            _builder.append(_formatForCode_2, "");
            _builder.append(".");
            String _name_3 = pkField.getName();
            String _formatForCode_3 = this._formattingExtensions.formatForCode(_name_3);
            _builder.append(_formatForCode_3, "");
            _builder.append("`");
          }
        }
        _builder.append("\"");
      }
    }
    return _builder;
  }
  
  private CharSequence treeRelatives(final Entity it, final String appName, final Controller controller) {
    StringConcatenation _builder = new StringConcatenation();
    String _name = it.getName();
    final String objName = this._formattingExtensions.formatForCode(_name);
    _builder.newLineIfNotEmpty();
    Models _container = it.getContainer();
    Application _application = _container.getApplication();
    String _appName = this._utils.appName(_application);
    final String pluginPrefix = this._formattingExtensions.formatForDB(_appName);
    _builder.newLineIfNotEmpty();
    final DerivedField leadingField = this._modelExtensions.getLeadingField(it);
    _builder.newLineIfNotEmpty();
    _builder.append("{* purpose of this template: show different forms of relatives for a given tree node *}");
    _builder.newLine();
    _builder.append("<h3>{gt text=\'Related ");
    String _nameMultiple = it.getNameMultiple();
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(_nameMultiple);
    _builder.append(_formatForDisplay, "");
    _builder.append("\'}</h3>");
    _builder.newLineIfNotEmpty();
    _builder.append("{if $");
    _builder.append(objName, "");
    _builder.append(".lvl gt 0}");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("{if !isset($allParents) || $allParents eq true}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("{");
    _builder.append(pluginPrefix, "        ");
    _builder.append("TreeSelection objectType=\'");
    _builder.append(objName, "        ");
    _builder.append("\' node=$");
    _builder.append(objName, "        ");
    _builder.append(" target=\'allParents\' assign=\'allParents\'}");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("{if $allParents ne null && count($allParents) gt 0}");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("<h4>{gt text=\'All parents\'}</h4>");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("<ul>");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("{foreach item=\'node\' from=$allParents}");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("<li><a href=\"{modurl modname=\'");
    _builder.append(appName, "                ");
    _builder.append("\' type=\'");
    String _formattedName = this._controllerExtensions.formattedName(controller);
    _builder.append(_formattedName, "                ");
    _builder.append("\' ");
    String _modUrlDisplay = this._urlExtensions.modUrlDisplay(it, "node", Boolean.valueOf(true));
    _builder.append(_modUrlDisplay, "                ");
    _builder.append("}\"");
    {
      boolean _tripleNotEquals = (leadingField != null);
      if (_tripleNotEquals) {
        _builder.append(" title=\"{$node.");
        String _name_1 = leadingField.getName();
        String _formatForCode = this._formattingExtensions.formatForCode(_name_1);
        _builder.append(_formatForCode, "                ");
        _builder.append("|replace:\'\"\':\'\'}\">{$node.");
        String _name_2 = leadingField.getName();
        String _formatForCode_1 = this._formattingExtensions.formatForCode(_name_2);
        _builder.append(_formatForCode_1, "                ");
        _builder.append("}");
      } else {
        _builder.append(">{gt text=\'");
        String _name_3 = it.getName();
        String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(_name_3);
        _builder.append(_formatForCodeCapital, "                ");
        _builder.append("\'}");
      }
    }
    _builder.append("</a></li>");
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    _builder.append("{/foreach}");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("</ul>");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("{/if}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{/if}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{if !isset($directParent) || $directParent eq true}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("{");
    _builder.append(pluginPrefix, "        ");
    _builder.append("TreeSelection objectType=\'");
    _builder.append(objName, "        ");
    _builder.append("\' node=$");
    _builder.append(objName, "        ");
    _builder.append(" target=\'directParent\' assign=\'directParent\'}");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("{if $directParent ne null}");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("<h4>{gt text=\'Direct parent\'}</h4>");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("<ul>");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("<li><a href=\"{modurl modname=\'");
    _builder.append(appName, "                ");
    _builder.append("\' type=\'");
    String _formattedName_1 = this._controllerExtensions.formattedName(controller);
    _builder.append(_formattedName_1, "                ");
    _builder.append("\' ");
    String _modUrlDisplay_1 = this._urlExtensions.modUrlDisplay(it, "directParent", Boolean.valueOf(true));
    _builder.append(_modUrlDisplay_1, "                ");
    _builder.append("}\"");
    {
      boolean _tripleNotEquals_1 = (leadingField != null);
      if (_tripleNotEquals_1) {
        _builder.append(" title=\"{$directParent.");
        String _name_4 = leadingField.getName();
        String _formatForCode_2 = this._formattingExtensions.formatForCode(_name_4);
        _builder.append(_formatForCode_2, "                ");
        _builder.append("|replace:\'\"\':\'\'}\">{$directParent.");
        String _name_5 = leadingField.getName();
        String _formatForCode_3 = this._formattingExtensions.formatForCode(_name_5);
        _builder.append(_formatForCode_3, "                ");
        _builder.append("}");
      } else {
        _builder.append(">{gt text=\'");
        String _name_6 = it.getName();
        String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(_name_6);
        _builder.append(_formatForCodeCapital_1, "                ");
        _builder.append("\'}");
      }
    }
    _builder.append("</a></li>");
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    _builder.append("</ul>");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("{/if}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{/if}");
    _builder.newLine();
    _builder.append("{/if}");
    _builder.newLine();
    _builder.append("{if !isset($allChildren) || $allChildren eq true}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{");
    _builder.append(pluginPrefix, "    ");
    _builder.append("TreeSelection objectType=\'");
    _builder.append(objName, "    ");
    _builder.append("\' node=$");
    _builder.append(objName, "    ");
    _builder.append(" target=\'allChildren\' assign=\'allChildren\'}");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("{if $allChildren ne null && count($allChildren) gt 0}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<h4>{gt text=\'All children\'}</h4>");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<ul>");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("{foreach item=\'node\' from=$allChildren}");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("<li><a href=\"{modurl modname=\'");
    _builder.append(appName, "            ");
    _builder.append("\' type=\'");
    String _formattedName_2 = this._controllerExtensions.formattedName(controller);
    _builder.append(_formattedName_2, "            ");
    _builder.append("\' ");
    String _modUrlDisplay_2 = this._urlExtensions.modUrlDisplay(it, "node", Boolean.valueOf(true));
    _builder.append(_modUrlDisplay_2, "            ");
    _builder.append("}\"");
    {
      boolean _tripleNotEquals_2 = (leadingField != null);
      if (_tripleNotEquals_2) {
        _builder.append(" title=\"{$node.");
        String _name_7 = leadingField.getName();
        String _formatForCode_4 = this._formattingExtensions.formatForCode(_name_7);
        _builder.append(_formatForCode_4, "            ");
        _builder.append("|replace:\'\"\':\'\'}\">{$node.");
        String _name_8 = leadingField.getName();
        String _formatForCode_5 = this._formattingExtensions.formatForCode(_name_8);
        _builder.append(_formatForCode_5, "            ");
        _builder.append("}");
      } else {
        _builder.append(">{gt text=\'");
        String _name_9 = it.getName();
        String _formatForCodeCapital_2 = this._formattingExtensions.formatForCodeCapital(_name_9);
        _builder.append(_formatForCodeCapital_2, "            ");
        _builder.append("\'}");
      }
    }
    _builder.append("</a></li>");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("{/foreach}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("</ul>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{/if}");
    _builder.newLine();
    _builder.append("{/if}");
    _builder.newLine();
    _builder.append("{if !isset($directChildren) || $directChildren eq true}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{");
    _builder.append(pluginPrefix, "    ");
    _builder.append("TreeSelection objectType=\'");
    _builder.append(objName, "    ");
    _builder.append("\' node=$");
    _builder.append(objName, "    ");
    _builder.append(" target=\'directChildren\' assign=\'directChildren\'}");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("{if $directChildren ne null && count($directChildren) gt 0}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<h4>{gt text=\'Direct children\'}</h4>");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<ul>");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("{foreach item=\'node\' from=$directChildren}");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("<li><a href=\"{modurl modname=\'");
    _builder.append(appName, "            ");
    _builder.append("\' type=\'");
    String _formattedName_3 = this._controllerExtensions.formattedName(controller);
    _builder.append(_formattedName_3, "            ");
    _builder.append("\' ");
    String _modUrlDisplay_3 = this._urlExtensions.modUrlDisplay(it, "node", Boolean.valueOf(true));
    _builder.append(_modUrlDisplay_3, "            ");
    _builder.append("}\"");
    {
      boolean _tripleNotEquals_3 = (leadingField != null);
      if (_tripleNotEquals_3) {
        _builder.append(" title=\"{$node.");
        String _name_10 = leadingField.getName();
        String _formatForCode_6 = this._formattingExtensions.formatForCode(_name_10);
        _builder.append(_formatForCode_6, "            ");
        _builder.append("|replace:\'\"\':\'\'}\">{$node.");
        String _name_11 = leadingField.getName();
        String _formatForCode_7 = this._formattingExtensions.formatForCode(_name_11);
        _builder.append(_formatForCode_7, "            ");
        _builder.append("}");
      } else {
        _builder.append(">{gt text=\'");
        String _name_12 = it.getName();
        String _formatForCodeCapital_3 = this._formattingExtensions.formatForCodeCapital(_name_12);
        _builder.append(_formatForCodeCapital_3, "            ");
        _builder.append("\'}");
      }
    }
    _builder.append("</a></li>");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("{/foreach}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("</ul>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{/if}");
    _builder.newLine();
    _builder.append("{/if}");
    _builder.newLine();
    _builder.append("{if $");
    _builder.append(objName, "");
    _builder.append(".lvl gt 0}");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("{if !isset($predecessors) || $predecessors eq true}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("{");
    _builder.append(pluginPrefix, "        ");
    _builder.append("TreeSelection objectType=\'");
    _builder.append(objName, "        ");
    _builder.append("\' node=$");
    _builder.append(objName, "        ");
    _builder.append(" target=\'predecessors\' assign=\'predecessors\'}");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("{if $predecessors ne null && count($predecessors) gt 0}");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("<h4>{gt text=\'Predecessors\'}</h4>");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("<ul>");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("{foreach item=\'node\' from=$predecessors}");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("<li><a href=\"{modurl modname=\'");
    _builder.append(appName, "                ");
    _builder.append("\' type=\'");
    String _formattedName_4 = this._controllerExtensions.formattedName(controller);
    _builder.append(_formattedName_4, "                ");
    _builder.append("\' ");
    String _modUrlDisplay_4 = this._urlExtensions.modUrlDisplay(it, "node", Boolean.valueOf(true));
    _builder.append(_modUrlDisplay_4, "                ");
    _builder.append("}\"");
    {
      boolean _tripleNotEquals_4 = (leadingField != null);
      if (_tripleNotEquals_4) {
        _builder.append(" title=\"{$node.");
        String _name_13 = leadingField.getName();
        String _formatForCode_8 = this._formattingExtensions.formatForCode(_name_13);
        _builder.append(_formatForCode_8, "                ");
        _builder.append("|replace:\'\"\':\'\'}\">{$node.");
        String _name_14 = leadingField.getName();
        String _formatForCode_9 = this._formattingExtensions.formatForCode(_name_14);
        _builder.append(_formatForCode_9, "                ");
        _builder.append("}");
      } else {
        _builder.append(">{gt text=\'");
        String _name_15 = it.getName();
        String _formatForCodeCapital_4 = this._formattingExtensions.formatForCodeCapital(_name_15);
        _builder.append(_formatForCodeCapital_4, "                ");
        _builder.append("\'}");
      }
    }
    _builder.append("</a></li>");
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    _builder.append("{/foreach}");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("</ul>");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("{/if}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{/if}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{if !isset($successors) || $successors eq true}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("{");
    _builder.append(pluginPrefix, "        ");
    _builder.append("TreeSelection objectType=\'");
    _builder.append(objName, "        ");
    _builder.append("\' node=$");
    _builder.append(objName, "        ");
    _builder.append(" target=\'successors\' assign=\'successors\'}");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("{if $successors ne null && count($successors) gt 0}");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("<h4>{gt text=\'Successors\'}</h4>");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("<ul>");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("{foreach item=\'node\' from=$successors}");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("<li><a href=\"{modurl modname=\'");
    _builder.append(appName, "                ");
    _builder.append("\' type=\'");
    String _formattedName_5 = this._controllerExtensions.formattedName(controller);
    _builder.append(_formattedName_5, "                ");
    _builder.append("\' ");
    String _modUrlDisplay_5 = this._urlExtensions.modUrlDisplay(it, "node", Boolean.valueOf(true));
    _builder.append(_modUrlDisplay_5, "                ");
    _builder.append("}\"");
    {
      boolean _tripleNotEquals_5 = (leadingField != null);
      if (_tripleNotEquals_5) {
        _builder.append(" title=\"{$node.");
        String _name_16 = leadingField.getName();
        String _formatForCode_10 = this._formattingExtensions.formatForCode(_name_16);
        _builder.append(_formatForCode_10, "                ");
        _builder.append("|replace:\'\"\':\'\'}\">{$node.");
        String _name_17 = leadingField.getName();
        String _formatForCode_11 = this._formattingExtensions.formatForCode(_name_17);
        _builder.append(_formatForCode_11, "                ");
        _builder.append("}");
      } else {
        _builder.append(">{gt text=\'");
        String _name_18 = it.getName();
        String _formatForCodeCapital_5 = this._formattingExtensions.formatForCodeCapital(_name_18);
        _builder.append(_formatForCodeCapital_5, "                ");
        _builder.append("\'}");
      }
    }
    _builder.append("</a></li>");
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    _builder.append("{/foreach}");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("</ul>");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("{/if}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{/if}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{if !isset($preandsuccessors) || $preandsuccessors eq true}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("{");
    _builder.append(pluginPrefix, "        ");
    _builder.append("TreeSelection objectType=\'");
    _builder.append(objName, "        ");
    _builder.append("\' node=$");
    _builder.append(objName, "        ");
    _builder.append(" target=\'preandsuccessors\' assign=\'preandsuccessors\'}");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("{if $preandsuccessors ne null && count($preandsuccessors) gt 0}");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("<h4>{gt text=\'Siblings\'}</h4>");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("<ul>");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("{foreach item=\'node\' from=$preandsuccessors}");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("<li><a href=\"{modurl modname=\'");
    _builder.append(appName, "                ");
    _builder.append("\' type=\'");
    String _formattedName_6 = this._controllerExtensions.formattedName(controller);
    _builder.append(_formattedName_6, "                ");
    _builder.append("\' ");
    String _modUrlDisplay_6 = this._urlExtensions.modUrlDisplay(it, "node", Boolean.valueOf(true));
    _builder.append(_modUrlDisplay_6, "                ");
    _builder.append("}\"");
    {
      boolean _tripleNotEquals_6 = (leadingField != null);
      if (_tripleNotEquals_6) {
        _builder.append(" title=\"{$node.");
        String _name_19 = leadingField.getName();
        String _formatForCode_12 = this._formattingExtensions.formatForCode(_name_19);
        _builder.append(_formatForCode_12, "                ");
        _builder.append("|replace:\'\"\':\'\'}\">{$node.");
        String _name_20 = leadingField.getName();
        String _formatForCode_13 = this._formattingExtensions.formatForCode(_name_20);
        _builder.append(_formatForCode_13, "                ");
        _builder.append("}");
      } else {
        _builder.append(">{gt text=\'");
        String _name_21 = it.getName();
        String _formatForCodeCapital_6 = this._formattingExtensions.formatForCodeCapital(_name_21);
        _builder.append(_formatForCodeCapital_6, "                ");
        _builder.append("\'}");
      }
    }
    _builder.append("</a></li>");
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    _builder.append("{/foreach}");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("</ul>");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("{/if}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{/if}");
    _builder.newLine();
    _builder.append("{/if}");
    _builder.newLine();
    return _builder;
  }
}
