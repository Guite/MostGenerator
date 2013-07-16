package org.zikula.modulestudio.generator.cartridges.zclassic.view.pages;

import com.google.common.base.Objects;
import com.google.common.collect.Iterables;
import com.google.inject.Inject;
import de.guite.modulestudio.metamodel.modulestudio.AdminController;
import de.guite.modulestudio.metamodel.modulestudio.Application;
import de.guite.modulestudio.metamodel.modulestudio.BooleanField;
import de.guite.modulestudio.metamodel.modulestudio.Controller;
import de.guite.modulestudio.metamodel.modulestudio.Controllers;
import de.guite.modulestudio.metamodel.modulestudio.DecimalField;
import de.guite.modulestudio.metamodel.modulestudio.DerivedField;
import de.guite.modulestudio.metamodel.modulestudio.Entity;
import de.guite.modulestudio.metamodel.modulestudio.EntityTreeType;
import de.guite.modulestudio.metamodel.modulestudio.EntityWorkflowType;
import de.guite.modulestudio.metamodel.modulestudio.FloatField;
import de.guite.modulestudio.metamodel.modulestudio.IntegerField;
import de.guite.modulestudio.metamodel.modulestudio.JoinRelationship;
import de.guite.modulestudio.metamodel.modulestudio.ListField;
import de.guite.modulestudio.metamodel.modulestudio.Models;
import de.guite.modulestudio.metamodel.modulestudio.NamedObject;
import de.guite.modulestudio.metamodel.modulestudio.OneToManyRelationship;
import de.guite.modulestudio.metamodel.modulestudio.OneToOneRelationship;
import de.guite.modulestudio.metamodel.modulestudio.Relationship;
import de.guite.modulestudio.metamodel.modulestudio.StringField;
import de.guite.modulestudio.metamodel.modulestudio.UserController;
import de.guite.modulestudio.metamodel.modulestudio.UserField;
import java.util.Arrays;
import java.util.List;
import org.eclipse.emf.common.util.EList;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.InputOutput;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.eclipse.xtext.xbase.lib.StringExtensions;
import org.zikula.modulestudio.generator.cartridges.zclassic.view.pagecomponents.SimpleFields;
import org.zikula.modulestudio.generator.cartridges.zclassic.view.pagecomponents.ViewQuickNavForm;
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
public class View {
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
  
  private SimpleFields fieldHelper = new Function0<SimpleFields>() {
    public SimpleFields apply() {
      SimpleFields _simpleFields = new SimpleFields();
      return _simpleFields;
    }
  }.apply();
  
  private Integer listType;
  
  /**
   * listType:
   * 0 = div and ul
   * 1 = div and ol
   * 2 = div and dl
   * 3 = div and table
   */
  public void generate(final Entity it, final String appName, final Controller controller, final Integer listType, final IFileSystemAccess fsa) {
    String _formattedName = this._controllerExtensions.formattedName(controller);
    String _plus = ("Generating " + _formattedName);
    String _plus_1 = (_plus + " view templates for entity \"");
    String _name = it.getName();
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(_name);
    String _plus_2 = (_plus_1 + _formatForDisplay);
    String _plus_3 = (_plus_2 + "\"");
    InputOutput.<String>println(_plus_3);
    this.listType = listType;
    String _name_1 = it.getName();
    String _templateFile = this._namingExtensions.templateFile(controller, _name_1, "view");
    CharSequence _viewView = this.viewView(it, appName, controller);
    fsa.generateFile(_templateFile, _viewView);
    ViewQuickNavForm _viewQuickNavForm = new ViewQuickNavForm();
    _viewQuickNavForm.generate(it, appName, controller, fsa);
  }
  
  private CharSequence viewView(final Entity it, final String appName, final Controller controller) {
    StringConcatenation _builder = new StringConcatenation();
    String _name = it.getName();
    final String objName = this._formattingExtensions.formatForCode(_name);
    _builder.newLineIfNotEmpty();
    _builder.append("{* purpose of this template: ");
    String _nameMultiple = it.getNameMultiple();
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(_nameMultiple);
    _builder.append(_formatForDisplay, "");
    _builder.append(" view view in ");
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
    _builder.append("-view\">");
    _builder.newLineIfNotEmpty();
    _builder.append("{gt text=\'");
    String _name_2 = it.getName();
    String _formatForDisplayCapital = this._formattingExtensions.formatForDisplayCapital(_name_2);
    _builder.append(_formatForDisplayCapital, "");
    _builder.append(" list\' assign=\'templateTitle\'}");
    _builder.newLineIfNotEmpty();
    _builder.append("{pagesetvar name=\'title\' value=$templateTitle}");
    _builder.newLine();
    CharSequence _templateHeader = this.templateHeader(controller);
    _builder.append(_templateHeader, "");
    _builder.newLineIfNotEmpty();
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
        _builder.newLine();
        _builder.append("<p class=\"sectiondesc\">");
        String _documentation_2 = it.getDocumentation();
        _builder.append(_documentation_2, "");
        _builder.append("</p>");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.newLine();
    {
      boolean _hasActions = this._controllerExtensions.hasActions(controller, "edit");
      if (_hasActions) {
        _builder.append("{checkpermissionblock component=\'");
        _builder.append(appName, "");
        _builder.append(":");
        String _name_3 = it.getName();
        String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(_name_3);
        _builder.append(_formatForCodeCapital, "");
        _builder.append(":\' instance=\'::\' level=\'ACCESS_EDIT\'}");
        _builder.newLineIfNotEmpty();
        {
          EntityTreeType _tree = it.getTree();
          boolean _notEquals_1 = (!Objects.equal(_tree, EntityTreeType.NONE));
          if (_notEquals_1) {
            _builder.append("{*");
            _builder.newLine();
          }
        }
        _builder.append("    ");
        _builder.append("{gt text=\'Create ");
        String _name_4 = it.getName();
        String _formatForDisplay_1 = this._formattingExtensions.formatForDisplay(_name_4);
        _builder.append(_formatForDisplay_1, "    ");
        _builder.append("\' assign=\'createTitle\'}");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("<a href=\"{modurl modname=\'");
        _builder.append(appName, "    ");
        _builder.append("\' type=\'");
        String _formattedName_3 = this._controllerExtensions.formattedName(controller);
        _builder.append(_formattedName_3, "    ");
        _builder.append("\' func=\'edit\' ot=\'");
        _builder.append(objName, "    ");
        _builder.append("\'}\" title=\"{$createTitle}\" class=\"z-icon-es-add\">{$createTitle}</a>");
        _builder.newLineIfNotEmpty();
        {
          EntityTreeType _tree_1 = it.getTree();
          boolean _notEquals_2 = (!Objects.equal(_tree_1, EntityTreeType.NONE));
          if (_notEquals_2) {
            _builder.append("*}");
            _builder.newLine();
          }
        }
        _builder.append("{/checkpermissionblock}");
        _builder.newLine();
      }
    }
    _builder.append("{assign var=\'own\' value=0}");
    _builder.newLine();
    _builder.append("{if isset($showOwnEntries) && $showOwnEntries eq 1}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{assign var=\'own\' value=1}");
    _builder.newLine();
    _builder.append("{/if}");
    _builder.newLine();
    _builder.append("{assign var=\'all\' value=0}");
    _builder.newLine();
    _builder.append("{if isset($showAllEntries) && $showAllEntries eq 1}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{gt text=\'Back to paginated view\' assign=\'linkTitle\'}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<a href=\"{modurl modname=\'");
    _builder.append(appName, "    ");
    _builder.append("\' type=\'");
    String _formattedName_4 = this._controllerExtensions.formattedName(controller);
    _builder.append(_formattedName_4, "    ");
    _builder.append("\' func=\'view\' ot=\'");
    _builder.append(objName, "    ");
    _builder.append("\'}\" title=\"{$linkTitle}\" class=\"z-icon-es-view\">");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("{$linkTitle}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("</a>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{assign var=\'all\' value=1}");
    _builder.newLine();
    _builder.append("{else}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{gt text=\'Show all entries\' assign=\'linkTitle\'}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<a href=\"{modurl modname=\'");
    _builder.append(appName, "    ");
    _builder.append("\' type=\'");
    String _formattedName_5 = this._controllerExtensions.formattedName(controller);
    _builder.append(_formattedName_5, "    ");
    _builder.append("\' func=\'view\' ot=\'");
    _builder.append(objName, "    ");
    _builder.append("\' all=1}\" title=\"{$linkTitle}\" class=\"z-icon-es-view\">{$linkTitle}</a>");
    _builder.newLineIfNotEmpty();
    _builder.append("{/if}");
    _builder.newLine();
    {
      EntityTreeType _tree_2 = it.getTree();
      boolean _notEquals_3 = (!Objects.equal(_tree_2, EntityTreeType.NONE));
      if (_notEquals_3) {
        _builder.append("{gt text=\'Switch to hierarchy view\' assign=\'linkTitle\'}");
        _builder.newLine();
        _builder.append("<a href=\"{modurl modname=\'");
        _builder.append(appName, "");
        _builder.append("\' type=\'");
        String _formattedName_6 = this._controllerExtensions.formattedName(controller);
        _builder.append(_formattedName_6, "");
        _builder.append("\' func=\'view\' ot=\'");
        _builder.append(objName, "");
        _builder.append("\' tpl=\'tree\'}\" title=\"{$linkTitle}\" class=\"z-icon-es-view\">{$linkTitle}</a>");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.newLine();
    _builder.append("{include file=\'");
    {
      Models _container_1 = it.getContainer();
      Application _application_1 = _container_1.getApplication();
      boolean _targets_1 = this._utils.targets(_application_1, "1.3.5");
      if (_targets_1) {
        String _formattedName_7 = this._controllerExtensions.formattedName(controller);
        _builder.append(_formattedName_7, "");
        _builder.append("/");
        String _name_5 = it.getName();
        String _formatForCode = this._formattingExtensions.formatForCode(_name_5);
        _builder.append(_formatForCode, "");
      } else {
        String _formattedName_8 = this._controllerExtensions.formattedName(controller);
        String _firstUpper_1 = StringExtensions.toFirstUpper(_formattedName_8);
        _builder.append(_firstUpper_1, "");
        _builder.append("/");
        String _name_6 = it.getName();
        String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(_name_6);
        _builder.append(_formatForCodeCapital_1, "");
      }
    }
    _builder.append("/view_quickNav.tpl\'");
    {
      boolean _hasVisibleWorkflow = this._workflowExtensions.hasVisibleWorkflow(it);
      boolean _not = (!_hasVisibleWorkflow);
      if (_not) {
        _builder.append(" workflowStateFilter=false");
      }
    }
    _builder.append("}{* see template file for available options *}");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    CharSequence _viewForm = this.viewForm(it, appName, controller);
    _builder.append(_viewForm, "");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    CharSequence _callDisplayHooks = this.callDisplayHooks(it, appName, controller);
    _builder.append(_callDisplayHooks, "");
    _builder.newLineIfNotEmpty();
    CharSequence _templateFooter = this.templateFooter(controller);
    _builder.append(_templateFooter, "");
    _builder.newLineIfNotEmpty();
    _builder.append("</div>");
    _builder.newLine();
    _builder.append("{include file=\'");
    {
      Models _container_2 = it.getContainer();
      Application _application_2 = _container_2.getApplication();
      boolean _targets_2 = this._utils.targets(_application_2, "1.3.5");
      if (_targets_2) {
        String _formattedName_9 = this._controllerExtensions.formattedName(controller);
        _builder.append(_formattedName_9, "");
      } else {
        String _formattedName_10 = this._controllerExtensions.formattedName(controller);
        String _firstUpper_2 = StringExtensions.toFirstUpper(_formattedName_10);
        _builder.append(_firstUpper_2, "");
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
        boolean _and_1 = false;
        boolean _equals = ((this.listType).intValue() == 3);
        if (!_equals) {
          _and_1 = false;
        } else {
          String _tableClass = this.tableClass(controller);
          boolean _equals_1 = Objects.equal(_tableClass, "admin");
          _and_1 = (_equals && _equals_1);
        }
        _or = (_hasBooleansWithAjaxToggleEntity || _and_1);
      }
      if (_or) {
        _builder.append("<script type=\"text/javascript\">");
        _builder.newLine();
        _builder.append("/* <![CDATA[ */");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("document.observe(\'dom:loaded\', function() {");
        _builder.newLine();
        {
          boolean _hasBooleansWithAjaxToggleEntity_1 = this._modelExtensions.hasBooleansWithAjaxToggleEntity(it);
          if (_hasBooleansWithAjaxToggleEntity_1) {
            _builder.append("    ");
            _builder.append("{{foreach item=\'");
            _builder.append(objName, "    ");
            _builder.append("\' from=$items}}");
            _builder.newLineIfNotEmpty();
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("{{assign var=\'itemid\' value=$");
            _builder.append(objName, "        ");
            _builder.append(".");
            DerivedField _firstPrimaryKey = this._modelExtensions.getFirstPrimaryKey(it);
            String _name_7 = _firstPrimaryKey.getName();
            String _formatForCode_1 = this._formattingExtensions.formatForCode(_name_7);
            _builder.append(_formatForCode_1, "        ");
            _builder.append("}}");
            _builder.newLineIfNotEmpty();
            {
              Iterable<BooleanField> _booleansWithAjaxToggleEntity = this._modelExtensions.getBooleansWithAjaxToggleEntity(it);
              for(final BooleanField field : _booleansWithAjaxToggleEntity) {
                _builder.append("    ");
                _builder.append("    ");
                Models _container_3 = it.getContainer();
                Application _application_3 = _container_3.getApplication();
                String _prefix = _application_3.getPrefix();
                _builder.append(_prefix, "        ");
                _builder.append("InitToggle(\'");
                _builder.append(objName, "        ");
                _builder.append("\', \'");
                String _name_8 = field.getName();
                String _formatForCode_2 = this._formattingExtensions.formatForCode(_name_8);
                _builder.append(_formatForCode_2, "        ");
                _builder.append("\', \'{{$itemid}}\');");
                _builder.newLineIfNotEmpty();
              }
            }
            _builder.append("    ");
            _builder.append("{{/foreach}}");
            _builder.newLine();
          }
        }
        {
          boolean _and_2 = false;
          boolean _equals_2 = ((this.listType).intValue() == 3);
          if (!_equals_2) {
            _and_2 = false;
          } else {
            String _tableClass_1 = this.tableClass(controller);
            boolean _equals_3 = Objects.equal(_tableClass_1, "admin");
            _and_2 = (_equals_2 && _equals_3);
          }
          if (_and_2) {
            _builder.append("    ");
            _builder.append("{{* init the \"toggle all\" functionality *}}");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("if ($(\'toggle_");
            String _nameMultiple_1 = it.getNameMultiple();
            String _formatForCode_3 = this._formattingExtensions.formatForCode(_nameMultiple_1);
            _builder.append(_formatForCode_3, "    ");
            _builder.append("\') != undefined) {");
            _builder.newLineIfNotEmpty();
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("$(\'toggle_");
            String _nameMultiple_2 = it.getNameMultiple();
            String _formatForCode_4 = this._formattingExtensions.formatForCode(_nameMultiple_2);
            _builder.append(_formatForCode_4, "        ");
            _builder.append("\').observe(\'click\', function (e) {");
            _builder.newLineIfNotEmpty();
            _builder.append("    ");
            _builder.append("        ");
            _builder.append("Zikula.toggleInput(\'");
            String _nameMultiple_3 = it.getNameMultiple();
            String _formatForCode_5 = this._formattingExtensions.formatForCode(_nameMultiple_3);
            _builder.append(_formatForCode_5, "            ");
            _builder.append("_view\');");
            _builder.newLineIfNotEmpty();
            _builder.append("    ");
            _builder.append("        ");
            _builder.append("e.stop()");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("});");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("}");
            _builder.newLine();
          }
        }
        _builder.append("    ");
        _builder.append("});");
        _builder.newLine();
        _builder.append("/* ]]> */");
        _builder.newLine();
        _builder.append("</script>");
        _builder.newLine();
      }
    }
    return _builder;
  }
  
  private CharSequence viewForm(final Entity it, final String appName, final Controller controller) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _and = false;
      boolean _equals = ((this.listType).intValue() == 3);
      if (!_equals) {
        _and = false;
      } else {
        String _tableClass = this.tableClass(controller);
        boolean _equals_1 = Objects.equal(_tableClass, "admin");
        _and = (_equals && _equals_1);
      }
      if (_and) {
        _builder.append("<form class=\"z-form\" id=\"");
        String _nameMultiple = it.getNameMultiple();
        String _formatForCode = this._formattingExtensions.formatForCode(_nameMultiple);
        _builder.append(_formatForCode, "");
        _builder.append("_view\" action=\"{modurl modname=\'");
        _builder.append(appName, "");
        _builder.append("\' type=\'");
        String _formattedName = this._controllerExtensions.formattedName(controller);
        _builder.append(_formattedName, "");
        _builder.append("\' func=\'handleselectedentries\'}\" method=\"post\">");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("<div>");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("<input type=\"hidden\" name=\"csrftoken\" value=\"{insert name=\'csrftoken\'}\" />");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("<input type=\"hidden\" name=\"ot\" value=\"");
        String _name = it.getName();
        String _formatForCode_1 = this._formattingExtensions.formatForCode(_name);
        _builder.append(_formatForCode_1, "        ");
        _builder.append("\" />");
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        CharSequence _viewItemList = this.viewItemList(it, appName, controller);
        _builder.append(_viewItemList, "        ");
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        CharSequence _pagerCall = this.pagerCall(it);
        _builder.append(_pagerCall, "        ");
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        CharSequence _massActionFields = this.massActionFields(it, appName);
        _builder.append(_massActionFields, "        ");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("</div>");
        _builder.newLine();
        _builder.append("</form>");
        _builder.newLine();
      } else {
        CharSequence _viewItemList_1 = this.viewItemList(it, appName, controller);
        _builder.append(_viewItemList_1, "");
        _builder.newLineIfNotEmpty();
        CharSequence _pagerCall_1 = this.pagerCall(it);
        _builder.append(_pagerCall_1, "");
        _builder.newLineIfNotEmpty();
      }
    }
    return _builder;
  }
  
  private CharSequence viewItemList(final Entity it, final String appName, final Controller controller) {
    StringConcatenation _builder = new StringConcatenation();
    final List<DerivedField> listItemsFields = this._modelExtensions.getDisplayFieldsForView(it);
    _builder.newLineIfNotEmpty();
    EList<Relationship> _incoming = it.getIncoming();
    Iterable<OneToManyRelationship> _filter = Iterables.<OneToManyRelationship>filter(_incoming, OneToManyRelationship.class);
    final Function1<OneToManyRelationship,Boolean> _function = new Function1<OneToManyRelationship,Boolean>() {
        public Boolean apply(final OneToManyRelationship e) {
          boolean _isBidirectional = e.isBidirectional();
          return Boolean.valueOf(_isBidirectional);
        }
      };
    final Iterable<OneToManyRelationship> listItemsIn = IterableExtensions.<OneToManyRelationship>filter(_filter, _function);
    _builder.newLineIfNotEmpty();
    EList<Relationship> _outgoing = it.getOutgoing();
    final Iterable<OneToOneRelationship> listItemsOut = Iterables.<OneToOneRelationship>filter(_outgoing, OneToOneRelationship.class);
    _builder.newLineIfNotEmpty();
    {
      boolean _notEquals = ((this.listType).intValue() != 3);
      if (_notEquals) {
        _builder.append("<");
        String _asListTag = this.asListTag(this.listType);
        _builder.append(_asListTag, "");
        _builder.append(">");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("<table class=\"z-datatable\">");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("<colgroup>");
        _builder.newLine();
        {
          String _tableClass = this.tableClass(controller);
          boolean _equals = Objects.equal(_tableClass, "admin");
          if (_equals) {
            _builder.append("        ");
            _builder.append("<col id=\"cselect\" />");
            _builder.newLine();
          }
        }
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
        _builder.append("        ");
        _builder.append("<col id=\"citemactions\" />");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("</colgroup>");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("<thead>");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("<tr>");
        _builder.newLine();
        {
          boolean _isCategorisable = it.isCategorisable();
          if (_isCategorisable) {
            _builder.append("        ");
            _builder.append("{assign var=\'catIdListMainString\' value=\',\'|implode:$catIdList.Main}");
            _builder.newLine();
          }
        }
        {
          String _tableClass_1 = this.tableClass(controller);
          boolean _equals_1 = Objects.equal(_tableClass_1, "admin");
          if (_equals_1) {
            _builder.append("        ");
            _builder.append("<th id=\"hselect\" scope=\"col\" align=\"center\" valign=\"middle\">");
            _builder.newLine();
            _builder.append("        ");
            _builder.append("    ");
            _builder.append("<input type=\"checkbox\" id=\"toggle_");
            String _nameMultiple = it.getNameMultiple();
            String _formatForCode = this._formattingExtensions.formatForCode(_nameMultiple);
            _builder.append(_formatForCode, "            ");
            _builder.append("\" />");
            _builder.newLineIfNotEmpty();
            _builder.append("        ");
            _builder.append("</th>");
            _builder.newLine();
          }
        }
        _builder.append("        ");
        {
          for(final DerivedField field_1 : listItemsFields) {
            CharSequence _headerLine = this.headerLine(field_1, controller);
            _builder.append(_headerLine, "        ");
          }
        }
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        {
          for(final OneToManyRelationship relation_2 : listItemsIn) {
            CharSequence _headerLine_1 = this.headerLine(relation_2, controller, Boolean.valueOf(false));
            _builder.append(_headerLine_1, "        ");
          }
        }
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        {
          for(final OneToOneRelationship relation_3 : listItemsOut) {
            CharSequence _headerLine_2 = this.headerLine(relation_3, controller, Boolean.valueOf(true));
            _builder.append(_headerLine_2, "        ");
          }
        }
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        _builder.append("<th id=\"hitemactions\" scope=\"col\" class=\"z-right z-order-unsorted\">{gt text=\'Actions\'}</th>");
        _builder.newLine();
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
    _builder.newLine();
    _builder.append("{foreach item=\'");
    String _name = it.getName();
    String _formatForCode_1 = this._formattingExtensions.formatForCode(_name);
    _builder.append(_formatForCode_1, "");
    _builder.append("\' from=$items}");
    _builder.newLineIfNotEmpty();
    {
      boolean _lessThan = ((this.listType).intValue() < 2);
      if (_lessThan) {
        _builder.append("    ");
        _builder.append("<li><ul>");
        _builder.newLine();
      } else {
        boolean _equals_2 = ((this.listType).intValue() == 2);
        if (_equals_2) {
          _builder.append("    ");
          _builder.append("<dt>");
          _builder.newLine();
        } else {
          boolean _equals_3 = ((this.listType).intValue() == 3);
          if (_equals_3) {
            _builder.append("    ");
            _builder.append("<tr class=\"{cycle values=\'z-odd, z-even\'}\">");
            _builder.newLine();
            {
              String _tableClass_2 = this.tableClass(controller);
              boolean _equals_4 = Objects.equal(_tableClass_2, "admin");
              if (_equals_4) {
                _builder.append("    ");
                _builder.append("    ");
                _builder.append("<td headers=\"hselect\" align=\"center\" valign=\"top\">");
                _builder.newLine();
                _builder.append("    ");
                _builder.append("    ");
                _builder.append("    ");
                _builder.append("<input type=\"checkbox\" name=\"items[]\" value=\"{$");
                String _name_1 = it.getName();
                String _formatForCode_2 = this._formattingExtensions.formatForCode(_name_1);
                _builder.append(_formatForCode_2, "            ");
                _builder.append(".");
                Iterable<DerivedField> _primaryKeyFields = this._modelExtensions.getPrimaryKeyFields(it);
                DerivedField _head = IterableExtensions.<DerivedField>head(_primaryKeyFields);
                String _name_2 = _head.getName();
                String _formatForCode_3 = this._formattingExtensions.formatForCode(_name_2);
                _builder.append(_formatForCode_3, "            ");
                _builder.append("}\" class=\"");
                String _nameMultiple_1 = it.getNameMultiple();
                String _formatForCode_4 = this._formattingExtensions.formatForCode(_nameMultiple_1);
                _builder.append(_formatForCode_4, "            ");
                _builder.append("_checkbox\" />");
                _builder.newLineIfNotEmpty();
                _builder.append("    ");
                _builder.append("    ");
                _builder.append("</td>");
                _builder.newLine();
              }
            }
          }
        }
      }
    }
    _builder.append("        ");
    {
      for(final DerivedField field_2 : listItemsFields) {
        CharSequence _displayEntry = this.displayEntry(field_2, controller, Boolean.valueOf(false));
        _builder.append(_displayEntry, "        ");
      }
    }
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    {
      for(final OneToManyRelationship relation_4 : listItemsIn) {
        CharSequence _displayEntry_1 = this.displayEntry(relation_4, controller, Boolean.valueOf(false));
        _builder.append(_displayEntry_1, "        ");
      }
    }
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    {
      for(final OneToOneRelationship relation_5 : listItemsOut) {
        CharSequence _displayEntry_2 = this.displayEntry(relation_5, controller, Boolean.valueOf(true));
        _builder.append(_displayEntry_2, "        ");
      }
    }
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    CharSequence _itemActions = this.itemActions(it, appName, controller);
    _builder.append(_itemActions, "        ");
    _builder.newLineIfNotEmpty();
    {
      boolean _lessThan_1 = ((this.listType).intValue() < 2);
      if (_lessThan_1) {
        _builder.append("    ");
        _builder.append("</ul></li>");
        _builder.newLine();
      } else {
        boolean _equals_5 = ((this.listType).intValue() == 2);
        if (_equals_5) {
          _builder.append("    ");
          _builder.append("</dt>");
          _builder.newLine();
        } else {
          boolean _equals_6 = ((this.listType).intValue() == 3);
          if (_equals_6) {
            _builder.append("    ");
            _builder.append("</tr>");
            _builder.newLine();
          }
        }
      }
    }
    _builder.append("{foreachelse}");
    _builder.newLine();
    {
      boolean _lessThan_2 = ((this.listType).intValue() < 2);
      if (_lessThan_2) {
        _builder.append("    ");
        _builder.append("<li>");
        _builder.newLine();
      } else {
        boolean _equals_7 = ((this.listType).intValue() == 2);
        if (_equals_7) {
          _builder.append("    ");
          _builder.append("<dt>");
          _builder.newLine();
        } else {
          boolean _equals_8 = ((this.listType).intValue() == 3);
          if (_equals_8) {
            _builder.append("    ");
            _builder.append("<tr class=\"z-");
            String _tableClass_3 = this.tableClass(controller);
            _builder.append(_tableClass_3, "    ");
            _builder.append("tableempty\">");
            _builder.newLineIfNotEmpty();
            _builder.append("    ");
            _builder.append("  ");
            _builder.append("<td class=\"z-left\" colspan=\"");
            int _size = listItemsFields.size();
            int _size_1 = IterableExtensions.size(listItemsIn);
            int _plus = (_size + _size_1);
            int _size_2 = IterableExtensions.size(listItemsOut);
            int _plus_1 = (_plus + _size_2);
            int _plus_2 = (_plus_1 + 1);
            int _xifexpression = (int) 0;
            String _tableClass_4 = this.tableClass(controller);
            boolean _equals_9 = Objects.equal(_tableClass_4, "admin");
            if (_equals_9) {
              _xifexpression = 1;
            } else {
              _xifexpression = 0;
            }
            int _plus_3 = (_plus_2 + _xifexpression);
            _builder.append(_plus_3, "      ");
            _builder.append("\">");
            _builder.newLineIfNotEmpty();
          }
        }
      }
    }
    _builder.append("    ");
    _builder.append("{gt text=\'No ");
    String _nameMultiple_2 = it.getNameMultiple();
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(_nameMultiple_2);
    _builder.append(_formatForDisplay, "    ");
    _builder.append(" found.\'}");
    _builder.newLineIfNotEmpty();
    {
      boolean _lessThan_3 = ((this.listType).intValue() < 2);
      if (_lessThan_3) {
        _builder.append("    ");
        _builder.append("</li>");
        _builder.newLine();
      } else {
        boolean _equals_10 = ((this.listType).intValue() == 2);
        if (_equals_10) {
          _builder.append("    ");
          _builder.append("</dt>");
          _builder.newLine();
        } else {
          boolean _equals_11 = ((this.listType).intValue() == 3);
          if (_equals_11) {
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
    _builder.append("{/foreach}");
    _builder.newLine();
    _builder.newLine();
    {
      boolean _notEquals_1 = ((this.listType).intValue() != 3);
      if (_notEquals_1) {
        _builder.append("<");
        String _asListTag_1 = this.asListTag(this.listType);
        _builder.append(_asListTag_1, "");
        _builder.append(">");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("    ");
        _builder.append("</tbody>");
        _builder.newLine();
        _builder.append("</table>");
        _builder.newLine();
      }
    }
    return _builder;
  }
  
  private CharSequence pagerCall(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.newLine();
    _builder.append("{if !isset($showAllEntries) || $showAllEntries ne 1}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{pager rowcount=$pager.numitems limit=$pager.itemsperpage display=\'page\'}");
    _builder.newLine();
    _builder.append("{/if}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence massActionFields(final Entity it, final String appName) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("<fieldset>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<label for=\"");
    String _formatForDB = this._formattingExtensions.formatForDB(appName);
    _builder.append(_formatForDB, "    ");
    _builder.append("_action\">{gt text=\'With selected ");
    String _nameMultiple = it.getNameMultiple();
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(_nameMultiple);
    _builder.append(_formatForDisplay, "    ");
    _builder.append("\'}</label>");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("<select id=\"");
    String _formatForDB_1 = this._formattingExtensions.formatForDB(appName);
    _builder.append(_formatForDB_1, "    ");
    _builder.append("_action\" name=\"action\">");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("<option value=\"\">{gt text=\'Choose action\'}</option>");
    _builder.newLine();
    {
      EntityWorkflowType _workflow = it.getWorkflow();
      boolean _notEquals = (!Objects.equal(_workflow, EntityWorkflowType.NONE));
      if (_notEquals) {
        {
          EntityWorkflowType _workflow_1 = it.getWorkflow();
          boolean _equals = Objects.equal(_workflow_1, EntityWorkflowType.ENTERPRISE);
          if (_equals) {
            _builder.append("    ");
            _builder.append("<option value=\"accept\" title=\"");
            EntityWorkflowType _workflow_2 = it.getWorkflow();
            String _workflowActionDescription = this._workflowExtensions.getWorkflowActionDescription(_workflow_2, "Accept");
            _builder.append(_workflowActionDescription, "    ");
            _builder.append("\">{gt text=\'Accept\'}</option>");
            _builder.newLineIfNotEmpty();
            {
              boolean _isOwnerPermission = it.isOwnerPermission();
              if (_isOwnerPermission) {
                _builder.append("    ");
                _builder.append("<option value=\"reject\" title=\"");
                EntityWorkflowType _workflow_3 = it.getWorkflow();
                String _workflowActionDescription_1 = this._workflowExtensions.getWorkflowActionDescription(_workflow_3, "Reject");
                _builder.append(_workflowActionDescription_1, "    ");
                _builder.append("\">{gt text=\'Reject\'}</option>");
                _builder.newLineIfNotEmpty();
              }
            }
            _builder.append("    ");
            _builder.append("<option value=\"demote\" title=\"");
            EntityWorkflowType _workflow_4 = it.getWorkflow();
            String _workflowActionDescription_2 = this._workflowExtensions.getWorkflowActionDescription(_workflow_4, "Demote");
            _builder.append(_workflowActionDescription_2, "    ");
            _builder.append("\">{gt text=\'Demote\'}</option>");
            _builder.newLineIfNotEmpty();
          }
        }
        _builder.append("    ");
        _builder.append("<option value=\"approve\" title=\"");
        EntityWorkflowType _workflow_5 = it.getWorkflow();
        String _workflowActionDescription_3 = this._workflowExtensions.getWorkflowActionDescription(_workflow_5, "Approve");
        _builder.append(_workflowActionDescription_3, "    ");
        _builder.append("\">{gt text=\'Approve\'}</option>");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      boolean _isHasTray = it.isHasTray();
      if (_isHasTray) {
        _builder.append("    ");
        _builder.append("<option value=\"unpublish\" title=\"");
        EntityWorkflowType _workflow_6 = it.getWorkflow();
        String _workflowActionDescription_4 = this._workflowExtensions.getWorkflowActionDescription(_workflow_6, "Unpublish");
        _builder.append(_workflowActionDescription_4, "    ");
        _builder.append("\">{gt text=\'Unpublish\'}</option>");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("<option value=\"publish\" title=\"");
        EntityWorkflowType _workflow_7 = it.getWorkflow();
        String _workflowActionDescription_5 = this._workflowExtensions.getWorkflowActionDescription(_workflow_7, "Publish");
        _builder.append(_workflowActionDescription_5, "    ");
        _builder.append("\">{gt text=\'Publish\'}</option>");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      boolean _isHasArchive = it.isHasArchive();
      if (_isHasArchive) {
        _builder.append("    ");
        _builder.append("<option value=\"archive\" title=\"");
        EntityWorkflowType _workflow_8 = it.getWorkflow();
        String _workflowActionDescription_6 = this._workflowExtensions.getWorkflowActionDescription(_workflow_8, "Archive");
        _builder.append(_workflowActionDescription_6, "    ");
        _builder.append("\">{gt text=\'Archive\'}</option>");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      boolean _isSoftDeleteable = it.isSoftDeleteable();
      if (_isSoftDeleteable) {
        _builder.append("    ");
        _builder.append("<option value=\"trash\" title=\"");
        EntityWorkflowType _workflow_9 = it.getWorkflow();
        String _workflowActionDescription_7 = this._workflowExtensions.getWorkflowActionDescription(_workflow_9, "Trash");
        _builder.append(_workflowActionDescription_7, "    ");
        _builder.append("\">{gt text=\'Trash\'}</option>");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("<option value=\"recover\" title=\"");
        EntityWorkflowType _workflow_10 = it.getWorkflow();
        String _workflowActionDescription_8 = this._workflowExtensions.getWorkflowActionDescription(_workflow_10, "Recover");
        _builder.append(_workflowActionDescription_8, "    ");
        _builder.append("\">{gt text=\'Recover\'}</option>");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("        ");
    _builder.append("<option value=\"delete\">{gt text=\'Delete\'}</option>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("</select>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<input type=\"submit\" value=\"{gt text=\'Submit\'}\" />");
    _builder.newLine();
    _builder.append("</fieldset>");
    _builder.newLine();
    return _builder;
  }
  
  private String tableClass(final Controller it) {
    String _switchResult = null;
    boolean _matched = false;
    if (!_matched) {
      if (it instanceof AdminController) {
        final AdminController _adminController = (AdminController)it;
        _matched=true;
        _switchResult = "admin";
      }
    }
    if (!_matched) {
      _switchResult = "data";
    }
    return _switchResult;
  }
  
  private CharSequence callDisplayHooks(final Entity it, final String appName, final Controller controller) {
    CharSequence _switchResult = null;
    boolean _matched = false;
    if (!_matched) {
      if (controller instanceof UserController) {
        final UserController _userController = (UserController)controller;
        _matched=true;
        StringConcatenation _builder = new StringConcatenation();
        _builder.newLine();
        _builder.append("{notifydisplayhooks eventname=\'");
        String _formatForDB = this._formattingExtensions.formatForDB(appName);
        _builder.append(_formatForDB, "");
        _builder.append(".ui_hooks.");
        String _nameMultiple = it.getNameMultiple();
        String _formatForDB_1 = this._formattingExtensions.formatForDB(_nameMultiple);
        _builder.append(_formatForDB_1, "");
        _builder.append(".display_view\' urlobject=$currentUrlObject assign=\'hooks\'}");
        _builder.newLineIfNotEmpty();
        _builder.append("{foreach key=\'providerArea\' item=\'hook\' from=$hooks}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("{$hook}");
        _builder.newLine();
        _builder.append("{/foreach}");
        _builder.newLine();
        _switchResult = _builder;
      }
    }
    if (!_matched) {
      _switchResult = "";
    }
    return _switchResult;
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
  
  private CharSequence columnDef(final DerivedField it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("<col id=\"c");
    String _markupIdCode = this.markupIdCode(it, Boolean.valueOf(false));
    _builder.append(_markupIdCode, "");
    _builder.append("\" />");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence columnDef(final JoinRelationship it, final Boolean useTarget) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("<col id=\"c");
    String _markupIdCode = this.markupIdCode(it, useTarget);
    _builder.append(_markupIdCode, "");
    _builder.append("\" />");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence headerLine(final DerivedField it, final Controller controller) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("<th id=\"h");
    String _markupIdCode = this.markupIdCode(it, Boolean.valueOf(false));
    _builder.append(_markupIdCode, "");
    _builder.append("\" scope=\"col\" class=\"z-");
    String _alignment = this.alignment(it);
    _builder.append(_alignment, "");
    _builder.append("\">");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
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
    _builder.append("    ");
    Entity _entity = it.getEntity();
    String _name_2 = it.getName();
    String _formatForCode = this._formattingExtensions.formatForCode(_name_2);
    CharSequence _headerSortingLink = this.headerSortingLink(it, controller, _entity, _formatForCode, fieldLabel);
    _builder.append(_headerSortingLink, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("</th>");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence headerLine(final JoinRelationship it, final Controller controller, final Boolean useTarget) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("<th id=\"h");
    String _markupIdCode = this.markupIdCode(it, useTarget);
    _builder.append(_markupIdCode, "");
    _builder.append("\" scope=\"col\" class=\"z-left\">");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
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
    _builder.append("    ");
    String _relationAliasName = this._namingExtensions.getRelationAliasName(it, useTarget);
    String _formatForCode = this._formattingExtensions.formatForCode(_relationAliasName);
    String _relationAliasName_1 = this._namingExtensions.getRelationAliasName(it, useTarget);
    String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(_relationAliasName_1);
    CharSequence _headerSortingLink = this.headerSortingLink(it, controller, mainEntity, _formatForCode, _formatForCodeCapital);
    _builder.append(_headerSortingLink, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("</th>");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence headerSortingLink(final Object it, final Controller controller, final Entity entity, final String fieldName, final String label) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{sortlink __linktext=\'");
    String _formatForDisplayCapital = this._formattingExtensions.formatForDisplayCapital(label);
    _builder.append(_formatForDisplayCapital, "");
    _builder.append("\' currentsort=$sort modname=\'");
    Controllers _container = controller.getContainer();
    Application _application = _container.getApplication();
    String _appName = this._utils.appName(_application);
    _builder.append(_appName, "");
    _builder.append("\' type=\'");
    String _formattedName = this._controllerExtensions.formattedName(controller);
    _builder.append(_formattedName, "");
    _builder.append("\' func=\'view\' ot=\'");
    String _name = entity.getName();
    String _formatForCode = this._formattingExtensions.formatForCode(_name);
    _builder.append(_formatForCode, "");
    _builder.append("\' sort=\'");
    _builder.append(fieldName, "");
    _builder.append("\'");
    CharSequence _headerSortingLinkParameters = this.headerSortingLinkParameters(entity);
    _builder.append(_headerSortingLinkParameters, "");
    _builder.append("}");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence headerSortingLinkParameters(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append(" ");
    _builder.append("sortdir=$sdir all=$all own=$own");
    {
      boolean _isCategorisable = it.isCategorisable();
      if (_isCategorisable) {
        _builder.append(" catidMain=$catIdListMainString");
      }
    }
    CharSequence _sortParamsForIncomingRelations = this.sortParamsForIncomingRelations(it);
    _builder.append(_sortParamsForIncomingRelations, " ");
    CharSequence _sortParamsForListFields = this.sortParamsForListFields(it);
    _builder.append(_sortParamsForListFields, " ");
    CharSequence _sortParamsForUserFields = this.sortParamsForUserFields(it);
    _builder.append(_sortParamsForUserFields, " ");
    CharSequence _sortParamsForCountryFields = this.sortParamsForCountryFields(it);
    _builder.append(_sortParamsForCountryFields, " ");
    CharSequence _sortParamsForLanguageFields = this.sortParamsForLanguageFields(it);
    _builder.append(_sortParamsForLanguageFields, " ");
    {
      boolean _hasAbstractStringFieldsEntity = this._modelExtensions.hasAbstractStringFieldsEntity(it);
      if (_hasAbstractStringFieldsEntity) {
        _builder.append(" searchterm=$searchterm");
      }
    }
    _builder.append(" pageSize=$pageSize");
    CharSequence _sortParamsForBooleanFields = this.sortParamsForBooleanFields(it);
    _builder.append(_sortParamsForBooleanFields, " ");
    return _builder;
  }
  
  private CharSequence sortParamsForIncomingRelations(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      Iterable<JoinRelationship> _incomingJoinRelationsWithOneSource = this._modelJoinExtensions.getIncomingJoinRelationsWithOneSource(it);
      boolean _isEmpty = IterableExtensions.isEmpty(_incomingJoinRelationsWithOneSource);
      boolean _not = (!_isEmpty);
      if (_not) {
        {
          Iterable<JoinRelationship> _incomingJoinRelationsWithOneSource_1 = this._modelJoinExtensions.getIncomingJoinRelationsWithOneSource(it);
          for(final JoinRelationship relation : _incomingJoinRelationsWithOneSource_1) {
            String _relationAliasName = this._namingExtensions.getRelationAliasName(relation, Boolean.valueOf(false));
            final String sourceAliasName = this._formattingExtensions.formatForCode(_relationAliasName);
            _builder.append(" ");
            _builder.append(sourceAliasName, "");
            _builder.append("=$");
            _builder.append(sourceAliasName, "");
          }
        }
      }
    }
    return _builder;
  }
  
  private CharSequence sortParamsForListFields(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _hasListFieldsEntity = this._modelExtensions.hasListFieldsEntity(it);
      if (_hasListFieldsEntity) {
        {
          Iterable<ListField> _listFieldsEntity = this._modelExtensions.getListFieldsEntity(it);
          for(final ListField field : _listFieldsEntity) {
            String _name = field.getName();
            final String fieldName = this._formattingExtensions.formatForCode(_name);
            _builder.append(" ");
            _builder.append(fieldName, "");
            _builder.append("=$");
            _builder.append(fieldName, "");
          }
        }
      }
    }
    return _builder;
  }
  
  private CharSequence sortParamsForUserFields(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _hasUserFieldsEntity = this._modelExtensions.hasUserFieldsEntity(it);
      if (_hasUserFieldsEntity) {
        {
          Iterable<UserField> _userFieldsEntity = this._modelExtensions.getUserFieldsEntity(it);
          for(final UserField field : _userFieldsEntity) {
            String _name = field.getName();
            final String fieldName = this._formattingExtensions.formatForCode(_name);
            _builder.append(" ");
            _builder.append(fieldName, "");
            _builder.append("=$");
            _builder.append(fieldName, "");
          }
        }
      }
    }
    return _builder;
  }
  
  private CharSequence sortParamsForCountryFields(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _hasCountryFieldsEntity = this._modelExtensions.hasCountryFieldsEntity(it);
      if (_hasCountryFieldsEntity) {
        {
          Iterable<StringField> _countryFieldsEntity = this._modelExtensions.getCountryFieldsEntity(it);
          for(final StringField field : _countryFieldsEntity) {
            String _name = field.getName();
            final String fieldName = this._formattingExtensions.formatForCode(_name);
            _builder.append(" ");
            _builder.append(fieldName, "");
            _builder.append("=$");
            _builder.append(fieldName, "");
          }
        }
      }
    }
    return _builder;
  }
  
  private CharSequence sortParamsForLanguageFields(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _hasLanguageFieldsEntity = this._modelExtensions.hasLanguageFieldsEntity(it);
      if (_hasLanguageFieldsEntity) {
        {
          Iterable<StringField> _languageFieldsEntity = this._modelExtensions.getLanguageFieldsEntity(it);
          for(final StringField field : _languageFieldsEntity) {
            String _name = field.getName();
            final String fieldName = this._formattingExtensions.formatForCode(_name);
            _builder.append(" ");
            _builder.append(fieldName, "");
            _builder.append("=$");
            _builder.append(fieldName, "");
          }
        }
      }
    }
    return _builder;
  }
  
  private CharSequence sortParamsForBooleanFields(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _hasBooleanFieldsEntity = this._modelExtensions.hasBooleanFieldsEntity(it);
      if (_hasBooleanFieldsEntity) {
        {
          Iterable<BooleanField> _booleanFieldsEntity = this._modelExtensions.getBooleanFieldsEntity(it);
          for(final BooleanField field : _booleanFieldsEntity) {
            String _name = field.getName();
            final String fieldName = this._formattingExtensions.formatForCode(_name);
            _builder.append(" ");
            _builder.append(fieldName, "");
            _builder.append("=$");
            _builder.append(fieldName, "");
          }
        }
      }
    }
    return _builder;
  }
  
  private CharSequence displayEntry(final Object it, final Controller controller, final Boolean useTarget) {
    StringConcatenation _builder = new StringConcatenation();
    final String cssClass = this.entryContainerCssClass(it);
    _builder.newLineIfNotEmpty();
    {
      boolean _notEquals = ((this.listType).intValue() != 3);
      if (_notEquals) {
        _builder.append("<");
        String _asItemTag = this.asItemTag(this.listType);
        _builder.append(_asItemTag, "");
        {
          boolean _notEquals_1 = (!Objects.equal(cssClass, ""));
          if (_notEquals_1) {
            _builder.append(" class=\"");
            _builder.append(cssClass, "");
            _builder.append("\"");
          }
        }
        _builder.append(">");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("<td headers=\"h");
        String _markupIdCode = this.markupIdCode(it, useTarget);
        _builder.append(_markupIdCode, "");
        _builder.append("\" class=\"z-");
        String _alignment = this.alignment(it);
        _builder.append(_alignment, "");
        {
          boolean _notEquals_2 = (!Objects.equal(cssClass, ""));
          if (_notEquals_2) {
            _builder.append(" ");
            _builder.append(cssClass, "");
          }
        }
        _builder.append("\">");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("    ");
    CharSequence _displayEntryInner = this.displayEntryInner(it, controller, useTarget);
    _builder.append(_displayEntryInner, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("</");
    String _asItemTag_1 = this.asItemTag(this.listType);
    _builder.append(_asItemTag_1, "");
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
      _xifexpression = "z-nowrap";
    } else {
      _xifexpression = "";
    }
    return _xifexpression;
  }
  
  private CharSequence _displayEntryInner(final Object it, final Controller controller, final Boolean useTarget) {
    return null;
  }
  
  private CharSequence _displayEntryInner(final DerivedField it, final Controller controller, final Boolean useTarget) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _isLeading = it.isLeading();
      boolean _equals = (_isLeading == true);
      if (_equals) {
        {
          boolean _hasActions = this._controllerExtensions.hasActions(controller, "display");
          if (_hasActions) {
            _builder.append("<a href=\"{modurl modname=\'");
            Controllers _container = controller.getContainer();
            Application _application = _container.getApplication();
            String _appName = this._utils.appName(_application);
            _builder.append(_appName, "");
            _builder.append("\' type=\'");
            String _formattedName = this._controllerExtensions.formattedName(controller);
            _builder.append(_formattedName, "");
            _builder.append("\' ");
            Entity _entity = it.getEntity();
            Entity _entity_1 = it.getEntity();
            String _name = _entity_1.getName();
            String _formatForCode = this._formattingExtensions.formatForCode(_name);
            String _modUrlDisplay = this._urlExtensions.modUrlDisplay(_entity, _formatForCode, Boolean.valueOf(true));
            _builder.append(_modUrlDisplay, "");
            _builder.append("}\" title=\"{gt text=\'View detail page\'}\">");
            CharSequence _displayLeadingEntry = this.displayLeadingEntry(it, controller);
            _builder.append(_displayLeadingEntry, "");
            _builder.append("</a>");
            _builder.newLineIfNotEmpty();
          } else {
            CharSequence _displayLeadingEntry_1 = this.displayLeadingEntry(it, controller);
            _builder.append(_displayLeadingEntry_1, "");
            _builder.newLineIfNotEmpty();
          }
        }
      } else {
        String _name_1 = it.getName();
        boolean _equals_1 = Objects.equal(_name_1, "workflowState");
        if (_equals_1) {
          _builder.append("{$");
          Entity _entity_2 = it.getEntity();
          String _name_2 = _entity_2.getName();
          String _formatForCode_1 = this._formattingExtensions.formatForCode(_name_2);
          _builder.append(_formatForCode_1, "");
          _builder.append(".workflowState|");
          Controllers _container_1 = controller.getContainer();
          Application _application_1 = _container_1.getApplication();
          String _appName_1 = this._utils.appName(_application_1);
          String _formatForDB = this._formattingExtensions.formatForDB(_appName_1);
          _builder.append(_formatForDB, "");
          _builder.append("ObjectState}");
          _builder.newLineIfNotEmpty();
        } else {
          Entity _entity_3 = it.getEntity();
          String _name_3 = _entity_3.getName();
          String _formatForCode_2 = this._formattingExtensions.formatForCode(_name_3);
          CharSequence _displayField = this.fieldHelper.displayField(it, _formatForCode_2, "view");
          _builder.append(_displayField, "");
          _builder.newLineIfNotEmpty();
        }
      }
    }
    return _builder;
  }
  
  private CharSequence displayLeadingEntry(final DerivedField it, final Controller controller) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{$");
    Entity _entity = it.getEntity();
    String _name = _entity.getName();
    String _formatForCode = this._formattingExtensions.formatForCode(_name);
    _builder.append(_formatForCode, "");
    _builder.append(".");
    String _name_1 = it.getName();
    String _formatForCode_1 = this._formattingExtensions.formatForCode(_name_1);
    _builder.append(_formatForCode_1, "");
    _builder.append("|notifyfilters:\'");
    Entity _entity_1 = it.getEntity();
    Models _container = _entity_1.getContainer();
    Application _application = _container.getApplication();
    String _appName = this._utils.appName(_application);
    String _formatForDB = this._formattingExtensions.formatForDB(_appName);
    _builder.append(_formatForDB, "");
    _builder.append(".filterhook.");
    Entity _entity_2 = it.getEntity();
    String _nameMultiple = _entity_2.getNameMultiple();
    String _formatForDB_1 = this._formattingExtensions.formatForDB(_nameMultiple);
    _builder.append(_formatForDB_1, "");
    _builder.append("\'}");
    return _builder;
  }
  
  private CharSequence _displayEntryInner(final JoinRelationship it, final Controller controller, final Boolean useTarget) {
    StringConcatenation _builder = new StringConcatenation();
    String _relationAliasName = this._namingExtensions.getRelationAliasName(it, useTarget);
    final String relationAliasName = this._formattingExtensions.formatForCodeCapital(_relationAliasName);
    _builder.newLineIfNotEmpty();
    Entity _xifexpression = null;
    boolean _not = (!(useTarget).booleanValue());
    if (_not) {
      Entity _target = it.getTarget();
      _xifexpression = _target;
    } else {
      Entity _source = it.getSource();
      _xifexpression = _source;
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
    String relObjName = (_plus + relationAliasName);
    _builder.newLineIfNotEmpty();
    _builder.append("{if isset($");
    _builder.append(relObjName, "");
    _builder.append(") && $");
    _builder.append(relObjName, "");
    _builder.append(" ne null}");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    Models _container = it.getContainer();
    Application _application = _container.getApplication();
    Controller linkController = this._controllerExtensions.getLinkController(_application, controller, linkEntity);
    _builder.newLineIfNotEmpty();
    {
      boolean _tripleNotEquals = (linkController != null);
      if (_tripleNotEquals) {
        _builder.append("    ");
        _builder.append("<a href=\"{modurl modname=\'");
        Models _container_1 = linkEntity.getContainer();
        Application _application_1 = _container_1.getApplication();
        String _appName = this._utils.appName(_application_1);
        _builder.append(_appName, "    ");
        _builder.append("\' type=\'");
        String _formattedName = this._controllerExtensions.formattedName(linkController);
        _builder.append(_formattedName, "    ");
        _builder.append("\' ");
        String _modUrlDisplay = this._urlExtensions.modUrlDisplay(linkEntity, relObjName, Boolean.valueOf(true));
        _builder.append(_modUrlDisplay, "    ");
        _builder.append("}\">{strip}");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("      ");
    final DerivedField leadingField = this._modelExtensions.getLeadingField(linkEntity);
    _builder.newLineIfNotEmpty();
    {
      boolean _tripleNotEquals_1 = (leadingField != null);
      if (_tripleNotEquals_1) {
        _builder.append("      ");
        _builder.append("{$");
        _builder.append(relObjName, "      ");
        _builder.append(".");
        String _name_1 = leadingField.getName();
        String _formatForCode_1 = this._formattingExtensions.formatForCode(_name_1);
        _builder.append(_formatForCode_1, "      ");
        _builder.append("|default:\"\"}");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("      ");
        _builder.append("{gt text=\'");
        String _name_2 = linkEntity.getName();
        String _formatForDisplayCapital = this._formattingExtensions.formatForDisplayCapital(_name_2);
        _builder.append(_formatForDisplayCapital, "      ");
        _builder.append("\'}");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      boolean _tripleNotEquals_2 = (linkController != null);
      if (_tripleNotEquals_2) {
        _builder.append("    ");
        _builder.append("{/strip}</a>");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("<a id=\"");
        String _name_3 = linkEntity.getName();
        String _formatForCode_2 = this._formattingExtensions.formatForCode(_name_3);
        _builder.append(_formatForCode_2, "    ");
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
            _builder.append("{$");
            String _name_4 = mainEntity.getName();
            String _formatForCode_3 = this._formattingExtensions.formatForCode(_name_4);
            _builder.append(_formatForCode_3, "    ");
            _builder.append(".");
            String _name_5 = pkField.getName();
            String _formatForCode_4 = this._formattingExtensions.formatForCode(_name_5);
            _builder.append(_formatForCode_4, "    ");
            _builder.append("}");
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
            _builder.append("{$");
            _builder.append(relObjName, "    ");
            _builder.append(".");
            String _name_6 = pkField_1.getName();
            String _formatForCode_5 = this._formattingExtensions.formatForCode(_name_6);
            _builder.append(_formatForCode_5, "    ");
            _builder.append("}");
          }
        }
        _builder.append("Display\" href=\"{modurl modname=\'");
        Models _container_2 = it.getContainer();
        Application _application_2 = _container_2.getApplication();
        String _appName_1 = this._utils.appName(_application_2);
        _builder.append(_appName_1, "    ");
        _builder.append("\' type=\'");
        String _formattedName_1 = this._controllerExtensions.formattedName(controller);
        _builder.append(_formattedName_1, "    ");
        _builder.append("\' ");
        String _modUrlDisplay_1 = this._urlExtensions.modUrlDisplay(linkEntity, relObjName, Boolean.valueOf(true));
        _builder.append(_modUrlDisplay_1, "    ");
        _builder.append(" theme=\'Printer\'");
        String _additionalUrlParametersForQuickViewLink = this._viewExtensions.additionalUrlParametersForQuickViewLink(controller);
        _builder.append(_additionalUrlParametersForQuickViewLink, "    ");
        _builder.append("}\" title=\"{gt text=\'Open quick view window\'}\" class=\"z-hide\">{icon type=\'view\' size=\'extrasmall\' __alt=\'Quick view\'}</a>");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("<script type=\"text/javascript\">");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("/* <![CDATA[ */");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("document.observe(\'dom:loaded\', function() {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("        ");
        Models _container_3 = it.getContainer();
        Application _application_3 = _container_3.getApplication();
        String _prefix = _application_3.getPrefix();
        _builder.append(_prefix, "            ");
        _builder.append("InitInlineWindow($(\'");
        String _name_7 = linkEntity.getName();
        String _formatForCode_6 = this._formattingExtensions.formatForCode(_name_7);
        _builder.append(_formatForCode_6, "            ");
        _builder.append("Item");
        {
          Iterable<DerivedField> _primaryKeyFields_2 = this._modelExtensions.getPrimaryKeyFields(mainEntity);
          boolean _hasElements_2 = false;
          for(final DerivedField pkField_2 : _primaryKeyFields_2) {
            if (!_hasElements_2) {
              _hasElements_2 = true;
            } else {
              _builder.appendImmediate("_", "            ");
            }
            _builder.append("{{$");
            String _name_8 = mainEntity.getName();
            String _formatForCode_7 = this._formattingExtensions.formatForCode(_name_8);
            _builder.append(_formatForCode_7, "            ");
            _builder.append(".");
            String _name_9 = pkField_2.getName();
            String _formatForCode_8 = this._formattingExtensions.formatForCode(_name_9);
            _builder.append(_formatForCode_8, "            ");
            _builder.append("}}");
          }
        }
        _builder.append("_rel_");
        {
          Iterable<DerivedField> _primaryKeyFields_3 = this._modelExtensions.getPrimaryKeyFields(linkEntity);
          boolean _hasElements_3 = false;
          for(final DerivedField pkField_3 : _primaryKeyFields_3) {
            if (!_hasElements_3) {
              _hasElements_3 = true;
            } else {
              _builder.appendImmediate("_", "            ");
            }
            _builder.append("{{$");
            _builder.append(relObjName, "            ");
            _builder.append(".");
            String _name_10 = pkField_3.getName();
            String _formatForCode_9 = this._formattingExtensions.formatForCode(_name_10);
            _builder.append(_formatForCode_9, "            ");
            _builder.append("}}");
          }
        }
        _builder.append("Display\'), \'{{");
        {
          boolean _tripleNotEquals_3 = (leadingField != null);
          if (_tripleNotEquals_3) {
            _builder.append("$");
            _builder.append(relObjName, "            ");
            _builder.append(".");
            String _name_11 = leadingField.getName();
            String _formatForCode_10 = this._formattingExtensions.formatForCode(_name_11);
            _builder.append(_formatForCode_10, "            ");
          } else {
            _builder.append("gt text=\'");
            String _name_12 = linkEntity.getName();
            String _formatForDisplayCapital_1 = this._formattingExtensions.formatForDisplayCapital(_name_12);
            _builder.append(_formatForDisplayCapital_1, "            ");
            _builder.append("\'");
          }
        }
        _builder.append("|replace:\"\'\":\"\"}}\');");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("});");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("/* ]]> */");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("</script>");
        _builder.newLine();
      }
    }
    _builder.append("{else}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{gt text=\'Not set.\'}");
    _builder.newLine();
    _builder.append("{/if}");
    _builder.newLine();
    return _builder;
  }
  
  private String _markupIdCode(final Object it, final Boolean useTarget) {
    return null;
  }
  
  private String _markupIdCode(final NamedObject it, final Boolean useTarget) {
    String _name = it.getName();
    String _formatForDB = this._formattingExtensions.formatForDB(_name);
    return _formatForDB;
  }
  
  private String _markupIdCode(final DerivedField it, final Boolean useTarget) {
    String _name = it.getName();
    String _formatForDB = this._formattingExtensions.formatForDB(_name);
    return _formatForDB;
  }
  
  private String _markupIdCode(final JoinRelationship it, final Boolean useTarget) {
    String _relationAliasName = this._namingExtensions.getRelationAliasName(it, useTarget);
    String _formatForDB = this._formattingExtensions.formatForDB(_relationAliasName);
    return _formatForDB;
  }
  
  private String alignment(final Object it) {
    String _switchResult = null;
    boolean _matched = false;
    if (!_matched) {
      if (it instanceof BooleanField) {
        final BooleanField _booleanField = (BooleanField)it;
        _matched=true;
        _switchResult = "center";
      }
    }
    if (!_matched) {
      if (it instanceof IntegerField) {
        final IntegerField _integerField = (IntegerField)it;
        _matched=true;
        _switchResult = "right";
      }
    }
    if (!_matched) {
      if (it instanceof DecimalField) {
        final DecimalField _decimalField = (DecimalField)it;
        _matched=true;
        _switchResult = "right";
      }
    }
    if (!_matched) {
      if (it instanceof FloatField) {
        final FloatField _floatField = (FloatField)it;
        _matched=true;
        _switchResult = "right";
      }
    }
    if (!_matched) {
      _switchResult = "left";
    }
    return _switchResult;
  }
  
  private CharSequence itemActions(final Entity it, final String appName, final Controller controller) {
    StringConcatenation _builder = new StringConcatenation();
    String _name = it.getName();
    final String objName = this._formattingExtensions.formatForCode(_name);
    _builder.newLineIfNotEmpty();
    {
      boolean _notEquals = ((this.listType).intValue() != 3);
      if (_notEquals) {
        _builder.append("<");
        String _asItemTag = this.asItemTag(this.listType);
        _builder.append(_asItemTag, "");
        _builder.append(">");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("<td id=\"");
        CharSequence _itemActionContainerId = this.itemActionContainerId(it);
        _builder.append(_itemActionContainerId, "");
        _builder.append("\" headers=\"hitemactions\" class=\"z-right z-nowrap z-w02\">");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("    ");
    _builder.append("{if count($");
    _builder.append(objName, "    ");
    _builder.append("._actions) gt 0}");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("{foreach item=\'option\' from=$");
    _builder.append(objName, "        ");
    _builder.append("._actions}");
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    _builder.append("<a href=\"{$option.url.type|");
    String _formatForDB = this._formattingExtensions.formatForDB(appName);
    _builder.append(_formatForDB, "            ");
    _builder.append("ActionUrl:$option.url.func:$option.url.arguments}\" title=\"{$option.linkTitle|safetext}\"{if $option.icon eq \'preview\'} target=\"_blank\"{/if}>{icon type=$option.icon size=\'extrasmall\' alt=$option.linkText|safetext}</a>");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("{/foreach}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("{icon id=\"");
    CharSequence _itemActionContainerIdForSmarty = this.itemActionContainerIdForSmarty(it);
    _builder.append(_itemActionContainerIdForSmarty, "        ");
    _builder.append("trigger\" type=\'options\' size=\'extrasmall\' __alt=\'Actions\' class=\'z-pointer z-hide\'}");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("<script type=\"text/javascript\">");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("/* <![CDATA[ */");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("document.observe(\'dom:loaded\', function() {");
    _builder.newLine();
    _builder.append("                ");
    Models _container = it.getContainer();
    Application _application = _container.getApplication();
    String _prefix = _application.getPrefix();
    _builder.append(_prefix, "                ");
    _builder.append("InitItemActions(\'");
    String _name_1 = it.getName();
    String _formatForCode = this._formattingExtensions.formatForCode(_name_1);
    _builder.append(_formatForCode, "                ");
    _builder.append("\', \'view\', \'");
    CharSequence _itemActionContainerIdForJs = this.itemActionContainerIdForJs(it);
    _builder.append(_itemActionContainerIdForJs, "                ");
    _builder.append("\');");
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    _builder.append("});");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("/* ]]> */");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("</script>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{/if}");
    _builder.newLine();
    _builder.append("</");
    String _asItemTag_1 = this.asItemTag(this.listType);
    _builder.append(_asItemTag_1, "");
    _builder.append(">");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence itemActionContainerId(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    String _name = it.getName();
    final String objName = this._formattingExtensions.formatForCode(_name);
    _builder.newLineIfNotEmpty();
    _builder.append("itemactions");
    {
      Iterable<DerivedField> _primaryKeyFields = this._modelExtensions.getPrimaryKeyFields(it);
      boolean _hasElements = false;
      for(final DerivedField pkField : _primaryKeyFields) {
        if (!_hasElements) {
          _hasElements = true;
        } else {
          _builder.appendImmediate("_", "");
        }
        _builder.append("{$");
        _builder.append(objName, "");
        _builder.append(".");
        String _name_1 = pkField.getName();
        String _formatForCode = this._formattingExtensions.formatForCode(_name_1);
        _builder.append(_formatForCode, "");
        _builder.append("}");
      }
    }
    return _builder;
  }
  
  private CharSequence itemActionContainerIdForJs(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    String _name = it.getName();
    final String objName = this._formattingExtensions.formatForCode(_name);
    _builder.newLineIfNotEmpty();
    _builder.append("itemactions");
    {
      Iterable<DerivedField> _primaryKeyFields = this._modelExtensions.getPrimaryKeyFields(it);
      boolean _hasElements = false;
      for(final DerivedField pkField : _primaryKeyFields) {
        if (!_hasElements) {
          _hasElements = true;
        } else {
          _builder.appendImmediate("_", "");
        }
        _builder.append("{{$");
        _builder.append(objName, "");
        _builder.append(".");
        String _name_1 = pkField.getName();
        String _formatForCode = this._formattingExtensions.formatForCode(_name_1);
        _builder.append(_formatForCode, "");
        _builder.append("}}");
      }
    }
    return _builder;
  }
  
  private CharSequence itemActionContainerIdForSmarty(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    String _name = it.getName();
    final String objName = this._formattingExtensions.formatForCode(_name);
    _builder.newLineIfNotEmpty();
    _builder.append("itemactions");
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
        _builder.append(objName, "");
        _builder.append(".");
        String _name_1 = pkField.getName();
        String _formatForCode = this._formattingExtensions.formatForCode(_name_1);
        _builder.append(_formatForCode, "");
        _builder.append("`");
      }
    }
    return _builder;
  }
  
  private String asListTag(final Integer listType) {
    String _switchResult = null;
    boolean _matched = false;
    if (!_matched) {
      if (Objects.equal(listType,0)) {
        _matched=true;
        _switchResult = "ul";
      }
    }
    if (!_matched) {
      if (Objects.equal(listType,1)) {
        _matched=true;
        _switchResult = "ol";
      }
    }
    if (!_matched) {
      if (Objects.equal(listType,2)) {
        _matched=true;
        _switchResult = "dl";
      }
    }
    if (!_matched) {
      if (Objects.equal(listType,3)) {
        _matched=true;
        _switchResult = "table";
      }
    }
    return _switchResult;
  }
  
  private String asItemTag(final Integer listType) {
    String _switchResult = null;
    boolean _matched = false;
    if (!_matched) {
      if (Objects.equal(listType,0)) {
        _matched=true;
        _switchResult = "li";
      }
    }
    if (!_matched) {
      if (Objects.equal(listType,1)) {
        _matched=true;
        _switchResult = "li";
      }
    }
    if (!_matched) {
      if (Objects.equal(listType,2)) {
        _matched=true;
        _switchResult = "dd";
      }
    }
    if (!_matched) {
      if (Objects.equal(listType,3)) {
        _matched=true;
        _switchResult = "td";
      }
    }
    return _switchResult;
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
  
  private CharSequence displayEntryInner(final Object it, final Controller controller, final Boolean useTarget) {
    if (it instanceof DerivedField) {
      return _displayEntryInner((DerivedField)it, controller, useTarget);
    } else if (it instanceof JoinRelationship) {
      return _displayEntryInner((JoinRelationship)it, controller, useTarget);
    } else if (it != null) {
      return _displayEntryInner(it, controller, useTarget);
    } else {
      throw new IllegalArgumentException("Unhandled parameter types: " +
        Arrays.<Object>asList(it, controller, useTarget).toString());
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
