package org.zikula.modulestudio.generator.cartridges.zclassic.view.pages;

import com.google.common.base.Objects;
import com.google.inject.Inject;
import de.guite.modulestudio.metamodel.modulestudio.Application;
import de.guite.modulestudio.metamodel.modulestudio.BoolVar;
import de.guite.modulestudio.metamodel.modulestudio.IntVar;
import de.guite.modulestudio.metamodel.modulestudio.ListVar;
import de.guite.modulestudio.metamodel.modulestudio.Models;
import de.guite.modulestudio.metamodel.modulestudio.Variable;
import de.guite.modulestudio.metamodel.modulestudio.Variables;
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
import org.zikula.modulestudio.generator.extensions.ControllerExtensions;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class Config {
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
  
  public void generate(final Application it, final IFileSystemAccess fsa) {
    InputOutput.<String>println("Generating config template");
    String _viewPath = this._namingExtensions.getViewPath(it);
    String _xifexpression = null;
    boolean _targets = this._utils.targets(it, "1.3.5");
    if (_targets) {
      String _configController = this._controllerExtensions.configController(it);
      String _formatForDB = this._formattingExtensions.formatForDB(_configController);
      _xifexpression = _formatForDB;
    } else {
      String _configController_1 = this._controllerExtensions.configController(it);
      String _formatForDB_1 = this._formattingExtensions.formatForDB(_configController_1);
      String _firstUpper = StringExtensions.toFirstUpper(_formatForDB_1);
      _xifexpression = _firstUpper;
    }
    String _plus = (_viewPath + _xifexpression);
    final String templatePath = (_plus + "/");
    String _plus_1 = (templatePath + "config.tpl");
    CharSequence _configView = this.configView(it);
    fsa.generateFile(_plus_1, _configView);
  }
  
  private CharSequence configView(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{* purpose of this template: module configuration *}");
    _builder.newLine();
    _builder.append("{include file=\'");
    {
      boolean _targets = this._utils.targets(it, "1.3.5");
      if (_targets) {
        String _configController = this._controllerExtensions.configController(it);
        String _formatForDB = this._formattingExtensions.formatForDB(_configController);
        _builder.append(_formatForDB, "");
      } else {
        String _configController_1 = this._controllerExtensions.configController(it);
        String _formatForDB_1 = this._formattingExtensions.formatForDB(_configController_1);
        String _firstUpper = StringExtensions.toFirstUpper(_formatForDB_1);
        _builder.append(_firstUpper, "");
      }
    }
    _builder.append("/header.tpl\'}");
    _builder.newLineIfNotEmpty();
    _builder.append("<div class=\"");
    String _appName = this._utils.appName(it);
    String _lowerCase = _appName.toLowerCase();
    _builder.append(_lowerCase, "");
    _builder.append("-config\">");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("{gt text=\'Settings\' assign=\'templateTitle\'}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{pagesetvar name=\'title\' value=$templateTitle}");
    _builder.newLine();
    {
      String _configController_2 = this._controllerExtensions.configController(it);
      String _formatForDB_2 = this._formattingExtensions.formatForDB(_configController_2);
      boolean _equals = Objects.equal(_formatForDB_2, "admin");
      if (_equals) {
        {
          boolean _targets_1 = this._utils.targets(it, "1.3.5");
          if (_targets_1) {
            _builder.append("    ");
            _builder.append("<div class=\"z-admin-content-pagetitle\">");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("{icon type=\'config\' size=\'small\' __alt=\'Settings\'}");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("<h3>{$templateTitle}</h3>");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("</div>");
            _builder.newLine();
          } else {
            _builder.append("    ");
            _builder.append("<h3>");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("<span class=\"icon icon-wrench\"></span>");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("{$templateTitle}");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("</h3>");
            _builder.newLine();
          }
        }
      } else {
        _builder.append("    ");
        _builder.append("<div class=\"z-frontendcontainer\">");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("<h2>{$templateTitle}</h2>");
        _builder.newLine();
      }
    }
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{form cssClass=\'");
    {
      boolean _targets_2 = this._utils.targets(it, "1.3.5");
      if (_targets_2) {
        _builder.append("z-form");
      } else {
        _builder.append("form-horizontal");
      }
    }
    _builder.append("\'");
    {
      boolean _targets_3 = this._utils.targets(it, "1.3.5");
      boolean _not = (!_targets_3);
      if (_not) {
        _builder.append(" role=\'form\'");
      }
    }
    _builder.append("}");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("{* add validation summary and a <div> element for styling the form *}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("{");
    String _appName_1 = this._utils.appName(it);
    String _formatForDB_3 = this._formattingExtensions.formatForDB(_appName_1);
    _builder.append(_formatForDB_3, "        ");
    _builder.append("FormFrame}");
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    _builder.append("{formsetinitialfocus inputId=\'");
    List<Variables> _sortedVariableContainers = this._utils.getSortedVariableContainers(it);
    Variables _head = IterableExtensions.<Variables>head(_sortedVariableContainers);
    EList<Variable> _vars = _head.getVars();
    Variable _head_1 = IterableExtensions.<Variable>head(_vars);
    String _name = _head_1.getName();
    String _formatForCode = this._formattingExtensions.formatForCode(_name);
    _builder.append(_formatForCode, "            ");
    _builder.append("\'}");
    _builder.newLineIfNotEmpty();
    {
      boolean _hasMultipleConfigSections = this._utils.hasMultipleConfigSections(it);
      if (_hasMultipleConfigSections) {
        _builder.append("            ");
        _builder.append("{formtabbedpanelset}");
        _builder.newLine();
      }
    }
    _builder.append("            ");
    {
      List<Variables> _sortedVariableContainers_1 = this._utils.getSortedVariableContainers(it);
      for(final Variables varContainer : _sortedVariableContainers_1) {
        boolean _hasMultipleConfigSections_1 = this._utils.hasMultipleConfigSections(it);
        List<Variables> _sortedVariableContainers_2 = this._utils.getSortedVariableContainers(it);
        Variables _head_2 = IterableExtensions.<Variables>head(_sortedVariableContainers_2);
        boolean _equals_1 = Objects.equal(varContainer, _head_2);
        CharSequence _configSection = this.configSection(varContainer, it, Boolean.valueOf(_hasMultipleConfigSections_1), Boolean.valueOf(_equals_1));
        _builder.append(_configSection, "            ");
      }
    }
    _builder.newLineIfNotEmpty();
    {
      boolean _hasMultipleConfigSections_2 = this._utils.hasMultipleConfigSections(it);
      if (_hasMultipleConfigSections_2) {
        _builder.append("            ");
        _builder.append("{/formtabbedpanelset}");
        _builder.newLine();
      }
    }
    _builder.newLine();
    _builder.append("            ");
    _builder.append("<div class=\"");
    {
      boolean _targets_4 = this._utils.targets(it, "1.3.5");
      if (_targets_4) {
        _builder.append("z-buttons z-formbuttons");
      } else {
        _builder.append("form-group form-buttons");
      }
    }
    _builder.append("\">");
    _builder.newLineIfNotEmpty();
    {
      boolean _targets_5 = this._utils.targets(it, "1.3.5");
      boolean _not_1 = (!_targets_5);
      if (_not_1) {
        _builder.append("            ");
        _builder.append("<div class=\"col-lg-offset-3 col-lg-9\">");
        _builder.newLine();
      }
    }
    _builder.append("                ");
    _builder.append("{formbutton commandName=\'save\' __text=\'Update configuration\' class=\'");
    {
      boolean _targets_6 = this._utils.targets(it, "1.3.5");
      if (_targets_6) {
        _builder.append("z-bt-save");
      } else {
        _builder.append("btn btn-success");
      }
    }
    _builder.append("\'}");
    _builder.newLineIfNotEmpty();
    _builder.append("                ");
    _builder.append("{formbutton commandName=\'cancel\' __text=\'Cancel\' class=\'");
    {
      boolean _targets_7 = this._utils.targets(it, "1.3.5");
      if (_targets_7) {
        _builder.append("z-bt-cancel");
      } else {
        _builder.append("btn btn-default");
      }
    }
    _builder.append("\'}");
    _builder.newLineIfNotEmpty();
    {
      boolean _targets_8 = this._utils.targets(it, "1.3.5");
      boolean _not_2 = (!_targets_8);
      if (_not_2) {
        _builder.append("            ");
        _builder.append("</div>");
        _builder.newLine();
      }
    }
    _builder.append("            ");
    _builder.append("</div>");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("{/");
    String _appName_2 = this._utils.appName(it);
    String _formatForDB_4 = this._formattingExtensions.formatForDB(_appName_2);
    _builder.append(_formatForDB_4, "        ");
    _builder.append("FormFrame}");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("{/form}");
    _builder.newLine();
    {
      String _configController_3 = this._controllerExtensions.configController(it);
      String _formatForDB_5 = this._formattingExtensions.formatForDB(_configController_3);
      boolean _equals_2 = Objects.equal(_formatForDB_5, "admin");
      if (_equals_2) {
      } else {
        _builder.append("    ");
        _builder.append("</div>");
        _builder.newLine();
      }
    }
    _builder.append("</div>");
    _builder.newLine();
    _builder.append("{include file=\'");
    {
      boolean _targets_9 = this._utils.targets(it, "1.3.5");
      if (_targets_9) {
        String _configController_4 = this._controllerExtensions.configController(it);
        String _formatForDB_6 = this._formattingExtensions.formatForDB(_configController_4);
        _builder.append(_formatForDB_6, "");
      } else {
        String _configController_5 = this._controllerExtensions.configController(it);
        String _formatForDB_7 = this._formattingExtensions.formatForDB(_configController_5);
        String _firstUpper_1 = StringExtensions.toFirstUpper(_formatForDB_7);
        _builder.append(_firstUpper_1, "");
      }
    }
    _builder.append("/footer.tpl\'}");
    _builder.newLineIfNotEmpty();
    {
      List<Variable> _allVariables = this._utils.getAllVariables(it);
      final Function1<Variable,Boolean> _function = new Function1<Variable,Boolean>() {
        public Boolean apply(final Variable it) {
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
          return Boolean.valueOf(_and);
        }
      };
      Iterable<Variable> _filter = IterableExtensions.<Variable>filter(_allVariables, _function);
      boolean _isEmpty = IterableExtensions.isEmpty(_filter);
      boolean _not_3 = (!_isEmpty);
      if (_not_3) {
        _builder.append("<script type=\"text/javascript\">");
        _builder.newLine();
        _builder.append("/* <![CDATA[ */");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("document.observe(\'dom:loaded\', function() {");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("Zikula.UI.Tooltips($$(\'.");
        String _appName_3 = this._utils.appName(it);
        String _formatForDB_8 = this._formattingExtensions.formatForDB(_appName_3);
        _builder.append(_formatForDB_8, "        ");
        _builder.append("FormTooltips\'));");
        _builder.newLineIfNotEmpty();
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
  
  private CharSequence configSection(final Variables it, final Application app, final Boolean hasMultipleConfigSections, final Boolean isPrimaryVarContainer) {
    StringConcatenation _builder = new StringConcatenation();
    {
      if ((hasMultipleConfigSections).booleanValue()) {
        _builder.append("{gt text=\'");
        String _name = it.getName();
        String _formatForDisplayCapital = this._formattingExtensions.formatForDisplayCapital(_name);
        _builder.append(_formatForDisplayCapital, "");
        _builder.append("\' assign=\'tabTitle\'}");
        _builder.newLineIfNotEmpty();
        _builder.append("{formtabbedpanel title=$tabTitle}");
        _builder.newLine();
      }
    }
    _builder.append("<fieldset>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<legend>");
    String _name_1 = it.getName();
    String _formatForDisplayCapital_1 = this._formattingExtensions.formatForDisplayCapital(_name_1);
    _builder.append(_formatForDisplayCapital_1, "    ");
    _builder.append("</legend>");
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
        _builder.append("    ");
        _builder.append("<p class=\"");
        {
          boolean _targets = this._utils.targets(app, "1.3.5");
          if (_targets) {
            _builder.append("z-confirmationmsg");
          } else {
            _builder.append("alert alert-info");
          }
        }
        _builder.append("\">{gt text=\'");
        String _documentation_2 = it.getDocumentation();
        String _replaceAll = _documentation_2.replaceAll("\'", "");
        _builder.append(_replaceAll, "    ");
        _builder.append("\'|nl2br}</p>");
        _builder.newLineIfNotEmpty();
      } else {
        boolean _or = false;
        boolean _not = (!(hasMultipleConfigSections).booleanValue());
        if (_not) {
          _or = true;
        } else {
          _or = (_not || (isPrimaryVarContainer).booleanValue());
        }
        if (_or) {
          _builder.append("    ");
          _builder.append("<p class=\"");
          {
            boolean _targets_1 = this._utils.targets(app, "1.3.5");
            if (_targets_1) {
              _builder.append("z-confirmationmsg");
            } else {
              _builder.append("alert alert-info");
            }
          }
          _builder.append("\">{gt text=\'Here you can manage all basic settings for this application.\'}</p>");
          _builder.newLineIfNotEmpty();
        }
      }
    }
    _builder.newLine();
    _builder.append("    ");
    {
      EList<Variable> _vars = it.getVars();
      for(final Variable modvar : _vars) {
        CharSequence _formRow = this.formRow(modvar);
        _builder.append(_formRow, "    ");
      }
    }
    _builder.newLineIfNotEmpty();
    _builder.append("</fieldset>");
    _builder.newLine();
    {
      if ((hasMultipleConfigSections).booleanValue()) {
        _builder.append("{/formtabbedpanel}");
        _builder.newLine();
      }
    }
    return _builder;
  }
  
  private CharSequence formRow(final Variable it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("<div class=\"");
    {
      Variables _container = it.getContainer();
      Models _container_1 = _container.getContainer();
      Application _application = _container_1.getApplication();
      boolean _targets = this._utils.targets(_application, "1.3.5");
      if (_targets) {
        _builder.append("z-formrow");
      } else {
        _builder.append("form-group");
      }
    }
    _builder.append("\">");
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
        _builder.append("    ");
        _builder.append("{gt text=\'");
        String _documentation_2 = it.getDocumentation();
        String _replaceAll = _documentation_2.replaceAll("\'", "\"");
        _builder.append(_replaceAll, "    ");
        _builder.append("\' assign=\'toolTip\'}");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("    ");
    _builder.append("{formlabel for=\'");
    String _name = it.getName();
    String _formatForCode = this._formattingExtensions.formatForCode(_name);
    _builder.append(_formatForCode, "    ");
    _builder.append("\' __text=\'");
    String _name_1 = it.getName();
    String _formatForDisplayCapital = this._formattingExtensions.formatForDisplayCapital(_name_1);
    _builder.append(_formatForDisplayCapital, "    ");
    _builder.append("\' cssClass=\'");
    {
      boolean _and_1 = false;
      String _documentation_3 = it.getDocumentation();
      boolean _tripleNotEquals_1 = (_documentation_3 != null);
      if (!_tripleNotEquals_1) {
        _and_1 = false;
      } else {
        String _documentation_4 = it.getDocumentation();
        boolean _notEquals_1 = (!Objects.equal(_documentation_4, ""));
        _and_1 = (_tripleNotEquals_1 && _notEquals_1);
      }
      if (_and_1) {
        Variables _container_2 = it.getContainer();
        Models _container_3 = _container_2.getContainer();
        Application _application_1 = _container_3.getApplication();
        String _appName = this._utils.appName(_application_1);
        String _formatForDB = this._formattingExtensions.formatForDB(_appName);
        _builder.append(_formatForDB, "    ");
        _builder.append("FormTooltips ");
      }
    }
    {
      Variables _container_4 = it.getContainer();
      Models _container_5 = _container_4.getContainer();
      Application _application_2 = _container_5.getApplication();
      boolean _targets_1 = this._utils.targets(_application_2, "1.3.5");
      boolean _not = (!_targets_1);
      if (_not) {
        _builder.append(" col-lg-3 control-label");
      }
    }
    _builder.append("\'");
    {
      boolean _and_2 = false;
      String _documentation_5 = it.getDocumentation();
      boolean _tripleNotEquals_2 = (_documentation_5 != null);
      if (!_tripleNotEquals_2) {
        _and_2 = false;
      } else {
        String _documentation_6 = it.getDocumentation();
        boolean _notEquals_2 = (!Objects.equal(_documentation_6, ""));
        _and_2 = (_tripleNotEquals_2 && _notEquals_2);
      }
      if (_and_2) {
        _builder.append(" title=$toolTip");
      }
    }
    _builder.append("}");
    _builder.newLineIfNotEmpty();
    {
      Variables _container_6 = it.getContainer();
      Models _container_7 = _container_6.getContainer();
      Application _application_3 = _container_7.getApplication();
      boolean _targets_2 = this._utils.targets(_application_3, "1.3.5");
      boolean _not_1 = (!_targets_2);
      if (_not_1) {
        _builder.append("    ");
        _builder.append("<div class=\"col-lg-9\">");
        _builder.newLine();
      }
    }
    _builder.append("        ");
    CharSequence _inputField = this.inputField(it);
    _builder.append(_inputField, "        ");
    _builder.newLineIfNotEmpty();
    {
      Variables _container_8 = it.getContainer();
      Models _container_9 = _container_8.getContainer();
      Application _application_4 = _container_9.getApplication();
      boolean _targets_3 = this._utils.targets(_application_4, "1.3.5");
      boolean _not_2 = (!_targets_3);
      if (_not_2) {
        _builder.append("    ");
        _builder.append("</div>");
        _builder.newLine();
      }
    }
    _builder.append("</div>");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence _inputField(final Variable it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{formtextinput id=\'");
    String _name = it.getName();
    String _formatForCode = this._formattingExtensions.formatForCode(_name);
    _builder.append(_formatForCode, "");
    _builder.append("\' group=\'config\' maxLength=255 __title=\'Enter the ");
    String _name_1 = it.getName();
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(_name_1);
    _builder.append(_formatForDisplay, "");
    _builder.append(".\'");
    {
      Variables _container = it.getContainer();
      Models _container_1 = _container.getContainer();
      Application _application = _container_1.getApplication();
      boolean _targets = this._utils.targets(_application, "1.3.5");
      boolean _not = (!_targets);
      if (_not) {
        _builder.append(" cssClass=\'form-control\'");
      }
    }
    _builder.append("}");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence _inputField(final IntVar it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{formintinput id=\'");
    String _name = it.getName();
    String _formatForCode = this._formattingExtensions.formatForCode(_name);
    _builder.append(_formatForCode, "");
    _builder.append("\' group=\'config\' maxLength=255 __title=\'Enter the ");
    String _name_1 = it.getName();
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(_name_1);
    _builder.append(_formatForDisplay, "");
    _builder.append(". Only digits are allowed.\'");
    {
      Variables _container = it.getContainer();
      Models _container_1 = _container.getContainer();
      Application _application = _container_1.getApplication();
      boolean _targets = this._utils.targets(_application, "1.3.5");
      boolean _not = (!_targets);
      if (_not) {
        _builder.append(" cssClass=\'form-control\'");
      }
    }
    _builder.append("}");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence _inputField(final BoolVar it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{formcheckbox id=\'");
    String _name = it.getName();
    String _formatForCode = this._formattingExtensions.formatForCode(_name);
    _builder.append(_formatForCode, "");
    _builder.append("\' group=\'config\'}");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence _inputField(final ListVar it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _isMultiple = it.isMultiple();
      if (_isMultiple) {
        _builder.append("{formcheckboxlist id=\'");
        String _name = it.getName();
        String _formatForCode = this._formattingExtensions.formatForCode(_name);
        _builder.append(_formatForCode, "");
        _builder.append("\' group=\'config\' repeatColumns=2 __title=\'Choose the ");
        String _name_1 = it.getName();
        String _formatForDisplay = this._formattingExtensions.formatForDisplay(_name_1);
        _builder.append(_formatForDisplay, "");
        _builder.append("\'");
        {
          Variables _container = it.getContainer();
          Models _container_1 = _container.getContainer();
          Application _application = _container_1.getApplication();
          boolean _targets = this._utils.targets(_application, "1.3.5");
          boolean _not = (!_targets);
          if (_not) {
            _builder.append(" cssClass=\'form-control\'");
          }
        }
        _builder.append("}");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("{formdropdownlist id=\'");
        String _name_2 = it.getName();
        String _formatForCode_1 = this._formattingExtensions.formatForCode(_name_2);
        _builder.append(_formatForCode_1, "");
        _builder.append("\' group=\'config\'");
        {
          boolean _isMultiple_1 = it.isMultiple();
          if (_isMultiple_1) {
            _builder.append(" selectionMode=\'multiple\'");
          }
        }
        _builder.append(" __title=\'Choose the ");
        String _name_3 = it.getName();
        String _formatForDisplay_1 = this._formattingExtensions.formatForDisplay(_name_3);
        _builder.append(_formatForDisplay_1, "");
        _builder.append("\'");
        {
          Variables _container_2 = it.getContainer();
          Models _container_3 = _container_2.getContainer();
          Application _application_1 = _container_3.getApplication();
          boolean _targets_1 = this._utils.targets(_application_1, "1.3.5");
          boolean _not_1 = (!_targets_1);
          if (_not_1) {
            _builder.append(" cssClass=\'form-control\'");
          }
        }
        _builder.append("}");
        _builder.newLineIfNotEmpty();
      }
    }
    return _builder;
  }
  
  private CharSequence inputField(final Variable it) {
    if (it instanceof BoolVar) {
      return _inputField((BoolVar)it);
    } else if (it instanceof IntVar) {
      return _inputField((IntVar)it);
    } else if (it instanceof ListVar) {
      return _inputField((ListVar)it);
    } else if (it != null) {
      return _inputField(it);
    } else {
      throw new IllegalArgumentException("Unhandled parameter types: " +
        Arrays.<Object>asList(it).toString());
    }
  }
}
