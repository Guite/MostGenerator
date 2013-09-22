package org.zikula.modulestudio.generator.cartridges.zclassic.view.formcomponents;

import com.google.inject.Inject;
import de.guite.modulestudio.metamodel.modulestudio.Application;
import de.guite.modulestudio.metamodel.modulestudio.Controller;
import de.guite.modulestudio.metamodel.modulestudio.DerivedField;
import de.guite.modulestudio.metamodel.modulestudio.Entity;
import de.guite.modulestudio.metamodel.modulestudio.Models;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.eclipse.xtext.xbase.lib.StringExtensions;
import org.zikula.modulestudio.generator.cartridges.zclassic.view.formcomponents.Relations;
import org.zikula.modulestudio.generator.extensions.ControllerExtensions;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;
import org.zikula.modulestudio.generator.extensions.ViewExtensions;

@SuppressWarnings("all")
public class Section {
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
  private ViewExtensions _viewExtensions = new Function0<ViewExtensions>() {
    public ViewExtensions apply() {
      ViewExtensions _viewExtensions = new ViewExtensions();
      return _viewExtensions;
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
  
  private Relations relationHelper = new Function0<Relations>() {
    public Relations apply() {
      Relations _relations = new Relations();
      return _relations;
    }
  }.apply();
  
  /**
   * Entry point for edit sections beside the actual fields.
   */
  public CharSequence generate(final Entity it, final Application app, final Controller controller, final IFileSystemAccess fsa) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.newLine();
    CharSequence _extensionsAndRelations = this.extensionsAndRelations(it, app, controller, fsa);
    _builder.append(_extensionsAndRelations, "");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    CharSequence _displayHooks = this.displayHooks(it, app);
    _builder.append(_displayHooks, "");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    CharSequence _returnControl = this.returnControl(it);
    _builder.append(_returnControl, "");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    CharSequence _submitActions = this.submitActions(it);
    _builder.append(_submitActions, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence extensionsAndRelations(final Entity it, final Application app, final Controller controller, final IFileSystemAccess fsa) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _isGeographical = it.isGeographical();
      if (_isGeographical) {
        {
          boolean _useGroupingPanels = this._viewExtensions.useGroupingPanels(it, "edit");
          if (_useGroupingPanels) {
            _builder.append("<h3 class=\"");
            String _appName = this._utils.appName(app);
            String _formatForDB = this._formattingExtensions.formatForDB(_appName);
            _builder.append(_formatForDB, "");
            _builder.append("map z-panel-header z-panel-indicator ");
            {
              boolean _targets = this._utils.targets(app, "1.3.5");
              if (_targets) {
                _builder.append("z");
              } else {
                _builder.append("cursor");
              }
            }
            _builder.append("-pointer\">{gt text=\'Map\'}</h3>");
            _builder.newLineIfNotEmpty();
            _builder.append("<fieldset class=\"");
            String _appName_1 = this._utils.appName(app);
            String _formatForDB_1 = this._formattingExtensions.formatForDB(_appName_1);
            _builder.append(_formatForDB_1, "");
            _builder.append("map z-panel-content\" style=\"display: none\">");
            _builder.newLineIfNotEmpty();
          } else {
            _builder.append("<fieldset class=\"");
            String _appName_2 = this._utils.appName(app);
            String _formatForDB_2 = this._formattingExtensions.formatForDB(_appName_2);
            _builder.append(_formatForDB_2, "");
            _builder.append("map\">");
            _builder.newLineIfNotEmpty();
          }
        }
        _builder.append("    ");
        _builder.append("<legend>{gt text=\'Map\'}</legend>");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("<div id=\"mapcontainer\" class=\"");
        String _appName_3 = this._utils.appName(app);
        String _lowerCase = _appName_3.toLowerCase();
        _builder.append(_lowerCase, "    ");
        _builder.append("mapcontainer\">");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("</div>");
        _builder.newLine();
        _builder.append("</fieldset>");
        _builder.newLine();
        _builder.newLine();
      }
    }
    {
      boolean _isAttributable = it.isAttributable();
      if (_isAttributable) {
        _builder.append("{include file=\'");
        {
          boolean _targets_1 = this._utils.targets(app, "1.3.5");
          if (_targets_1) {
            String _formattedName = this._controllerExtensions.formattedName(controller);
            _builder.append(_formattedName, "");
          } else {
            String _formattedName_1 = this._controllerExtensions.formattedName(controller);
            String _firstUpper = StringExtensions.toFirstUpper(_formattedName_1);
            _builder.append(_firstUpper, "");
          }
        }
        _builder.append("/include_attributes_edit.tpl\' obj=$");
        String _name = it.getName();
        String _formatForDB_3 = this._formattingExtensions.formatForDB(_name);
        _builder.append(_formatForDB_3, "");
        {
          boolean _useGroupingPanels_1 = this._viewExtensions.useGroupingPanels(it, "edit");
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
          boolean _targets_2 = this._utils.targets(app, "1.3.5");
          if (_targets_2) {
            String _formattedName_2 = this._controllerExtensions.formattedName(controller);
            _builder.append(_formattedName_2, "");
          } else {
            String _formattedName_3 = this._controllerExtensions.formattedName(controller);
            String _firstUpper_1 = StringExtensions.toFirstUpper(_formattedName_3);
            _builder.append(_firstUpper_1, "");
          }
        }
        _builder.append("/include_categories_edit.tpl\' obj=$");
        String _name_1 = it.getName();
        String _formatForDB_4 = this._formattingExtensions.formatForDB(_name_1);
        _builder.append(_formatForDB_4, "");
        _builder.append(" groupName=\'");
        String _name_2 = it.getName();
        String _formatForDB_5 = this._formattingExtensions.formatForDB(_name_2);
        _builder.append(_formatForDB_5, "");
        _builder.append("Obj\'");
        {
          boolean _useGroupingPanels_2 = this._viewExtensions.useGroupingPanels(it, "edit");
          if (_useGroupingPanels_2) {
            _builder.append(" panel=true");
          }
        }
        _builder.append("}");
        _builder.newLineIfNotEmpty();
      }
    }
    CharSequence _generateIncludeStatement = this.relationHelper.generateIncludeStatement(it, app, controller, fsa);
    _builder.append(_generateIncludeStatement, "");
    _builder.newLineIfNotEmpty();
    {
      boolean _isMetaData = it.isMetaData();
      if (_isMetaData) {
        _builder.append("{include file=\'");
        {
          boolean _targets_3 = this._utils.targets(app, "1.3.5");
          if (_targets_3) {
            String _formattedName_4 = this._controllerExtensions.formattedName(controller);
            _builder.append(_formattedName_4, "");
          } else {
            String _formattedName_5 = this._controllerExtensions.formattedName(controller);
            String _firstUpper_2 = StringExtensions.toFirstUpper(_formattedName_5);
            _builder.append(_firstUpper_2, "");
          }
        }
        _builder.append("/include_metadata_edit.tpl\' obj=$");
        String _name_3 = it.getName();
        String _formatForDB_6 = this._formattingExtensions.formatForDB(_name_3);
        _builder.append(_formatForDB_6, "");
        {
          boolean _useGroupingPanels_3 = this._viewExtensions.useGroupingPanels(it, "edit");
          if (_useGroupingPanels_3) {
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
        _builder.append("{if $mode ne \'create\'}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("{include file=\'");
        {
          boolean _targets_4 = this._utils.targets(app, "1.3.5");
          if (_targets_4) {
            String _formattedName_6 = this._controllerExtensions.formattedName(controller);
            _builder.append(_formattedName_6, "    ");
          } else {
            String _formattedName_7 = this._controllerExtensions.formattedName(controller);
            String _firstUpper_3 = StringExtensions.toFirstUpper(_formattedName_7);
            _builder.append(_firstUpper_3, "    ");
          }
        }
        _builder.append("/include_standardfields_edit.tpl\' obj=$");
        String _name_4 = it.getName();
        String _formatForDB_7 = this._formattingExtensions.formatForDB(_name_4);
        _builder.append(_formatForDB_7, "    ");
        {
          boolean _useGroupingPanels_4 = this._viewExtensions.useGroupingPanels(it, "edit");
          if (_useGroupingPanels_4) {
            _builder.append(" panel=true");
          }
        }
        _builder.append("}");
        _builder.newLineIfNotEmpty();
        _builder.append("{/if}");
        _builder.newLine();
      }
    }
    return _builder;
  }
  
  private CharSequence displayHooks(final Entity it, final Application app) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{* include display hooks *}");
    _builder.newLine();
    _builder.append("{if $mode ne \'create\'}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{assign var=\'hookid\' value=");
    {
      boolean _hasCompositeKeys = this._modelExtensions.hasCompositeKeys(it);
      boolean _not = (!_hasCompositeKeys);
      if (_not) {
        _builder.append("$");
        String _name = it.getName();
        String _formatForDB = this._formattingExtensions.formatForDB(_name);
        _builder.append(_formatForDB, "    ");
        _builder.append(".");
        DerivedField _firstPrimaryKey = this._modelExtensions.getFirstPrimaryKey(it);
        String _name_1 = _firstPrimaryKey.getName();
        String _formatForCode = this._formattingExtensions.formatForCode(_name_1);
        _builder.append(_formatForCode, "    ");
      } else {
        _builder.append("\"");
        {
          Iterable<DerivedField> _primaryKeyFields = this._modelExtensions.getPrimaryKeyFields(it);
          boolean _hasElements = false;
          for(final DerivedField pkField : _primaryKeyFields) {
            if (!_hasElements) {
              _hasElements = true;
            } else {
              _builder.appendImmediate("_", "    ");
            }
            _builder.append("`$");
            String _name_2 = it.getName();
            String _formatForDB_1 = this._formattingExtensions.formatForDB(_name_2);
            _builder.append(_formatForDB_1, "    ");
            _builder.append(".");
            String _name_3 = pkField.getName();
            String _formatForCode_1 = this._formattingExtensions.formatForCode(_name_3);
            _builder.append(_formatForCode_1, "    ");
            _builder.append("`");
          }
        }
        _builder.append("\"");
      }
    }
    _builder.append("}");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("{notifydisplayhooks eventname=\'");
    String _name_4 = app.getName();
    String _formatForDB_2 = this._formattingExtensions.formatForDB(_name_4);
    _builder.append(_formatForDB_2, "    ");
    _builder.append(".ui_hooks.");
    String _nameMultiple = it.getNameMultiple();
    String _formatForDB_3 = this._formattingExtensions.formatForDB(_nameMultiple);
    _builder.append(_formatForDB_3, "    ");
    _builder.append(".form_edit\' id=$hookId assign=\'hooks\'}");
    _builder.newLineIfNotEmpty();
    _builder.append("{else}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{notifydisplayhooks eventname=\'");
    String _name_5 = app.getName();
    String _formatForDB_4 = this._formattingExtensions.formatForDB(_name_5);
    _builder.append(_formatForDB_4, "    ");
    _builder.append(".ui_hooks.");
    String _nameMultiple_1 = it.getNameMultiple();
    String _formatForDB_5 = this._formattingExtensions.formatForDB(_nameMultiple_1);
    _builder.append(_formatForDB_5, "    ");
    _builder.append(".form_edit\' id=null assign=\'hooks\'}");
    _builder.newLineIfNotEmpty();
    _builder.append("{/if}");
    _builder.newLine();
    _builder.append("{if is_array($hooks) && count($hooks)}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{foreach key=\'providerArea\' item=\'hook\' from=$hooks}");
    _builder.newLine();
    {
      boolean _useGroupingPanels = this._viewExtensions.useGroupingPanels(it, "edit");
      if (_useGroupingPanels) {
        _builder.append("        ");
        _builder.append("<h3 class=\"hook z-panel-header z-panel-indicator ");
        {
          boolean _targets = this._utils.targets(app, "1.3.5");
          if (_targets) {
            _builder.append("z");
          } else {
            _builder.append("cursor");
          }
        }
        _builder.append("-pointer\">{$providerArea}</h3>");
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        _builder.append("<fieldset class=\"hook z-panel-content\" style=\"display: none\">{$hook}</div>");
        _builder.newLine();
      } else {
        _builder.append("        ");
        _builder.append("<fieldset>");
        _builder.newLine();
      }
    }
    _builder.append("            ");
    _builder.append("{$hook}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("</fieldset>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{/foreach}");
    _builder.newLine();
    _builder.append("{/if}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence returnControl(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{* include return control *}");
    _builder.newLine();
    _builder.append("{if $mode eq \'create\'}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<fieldset>");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<legend>{gt text=\'Return control\'}</legend>");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<div class=\"");
    {
      Models _container = it.getContainer();
      Application _application = _container.getApplication();
      boolean _targets = this._utils.targets(_application, "1.3.5");
      if (_targets) {
        _builder.append("z-formrow");
      } else {
        _builder.append("form-group");
      }
    }
    _builder.append("\">");
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    _builder.append("{formlabel for=\'repeatcreation\' __text=\'Create another item after save\'");
    {
      Models _container_1 = it.getContainer();
      Application _application_1 = _container_1.getApplication();
      boolean _targets_1 = this._utils.targets(_application_1, "1.3.5");
      boolean _not = (!_targets_1);
      if (_not) {
        _builder.append(" cssClass=\'col-lg-3 control-label\'");
      }
    }
    _builder.append("}");
    _builder.newLineIfNotEmpty();
    {
      Models _container_2 = it.getContainer();
      Application _application_2 = _container_2.getApplication();
      boolean _targets_2 = this._utils.targets(_application_2, "1.3.5");
      boolean _not_1 = (!_targets_2);
      if (_not_1) {
        _builder.append("        ");
        _builder.append("<div class=\"col-lg-9\">");
        _builder.newLine();
      }
    }
    _builder.append("                ");
    _builder.append("{formcheckbox group=\'");
    String _name = it.getName();
    String _formatForDB = this._formattingExtensions.formatForDB(_name);
    _builder.append(_formatForDB, "                ");
    _builder.append("\' id=\'repeatcreation\' readOnly=false}");
    _builder.newLineIfNotEmpty();
    {
      Models _container_3 = it.getContainer();
      Application _application_3 = _container_3.getApplication();
      boolean _targets_3 = this._utils.targets(_application_3, "1.3.5");
      boolean _not_2 = (!_targets_3);
      if (_not_2) {
        _builder.append("        ");
        _builder.append("</div>");
        _builder.newLine();
      }
    }
    _builder.append("        ");
    _builder.append("</div>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("</fieldset>");
    _builder.newLine();
    _builder.append("{/if}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence submitActions(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{* include possible submit actions *}");
    _builder.newLine();
    _builder.append("<div class=\"");
    {
      Models _container = it.getContainer();
      Application _application = _container.getApplication();
      boolean _targets = this._utils.targets(_application, "1.3.5");
      if (_targets) {
        _builder.append("z-buttons z-formbuttons");
      } else {
        _builder.append("form-group form-buttons");
      }
    }
    _builder.append("\">");
    _builder.newLineIfNotEmpty();
    {
      Models _container_1 = it.getContainer();
      Application _application_1 = _container_1.getApplication();
      boolean _targets_1 = this._utils.targets(_application_1, "1.3.5");
      boolean _not = (!_targets_1);
      if (_not) {
        _builder.append("<div class=\"col-lg-offset-3 col-lg-9\">");
        _builder.newLine();
      }
    }
    _builder.append("{foreach item=\'action\' from=$actions}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{assign var=\'actionIdCapital\' value=$action.id|@ucwords}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{gt text=$action.title assign=\'actionTitle\'}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{*gt text=$action.description assign=\'actionDescription\'*}{* TODO: formbutton could support title attributes *}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{if $action.id eq \'delete\'}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("{gt text=\'Really delete this ");
    String _name = it.getName();
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(_name);
    _builder.append(_formatForDisplay, "        ");
    _builder.append("?\' assign=\'deleteConfirmMsg\'}");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("{formbutton id=\"btn`$actionIdCapital`\" commandName=$action.id text=$actionTitle class=$action.buttonClass confirmMessage=$deleteConfirmMsg}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{else}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("{formbutton id=\"btn`$actionIdCapital`\" commandName=$action.id text=$actionTitle class=$action.buttonClass}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{/if}");
    _builder.newLine();
    _builder.append("{/foreach}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{formbutton id=\'btnCancel\' commandName=\'cancel\' __text=\'Cancel\' class=\'");
    {
      Models _container_2 = it.getContainer();
      Application _application_2 = _container_2.getApplication();
      boolean _targets_2 = this._utils.targets(_application_2, "1.3.5");
      if (_targets_2) {
        _builder.append("z-bt-cancel");
      } else {
        _builder.append("btn btn-default");
      }
    }
    _builder.append("\'}");
    _builder.newLineIfNotEmpty();
    {
      Models _container_3 = it.getContainer();
      Application _application_3 = _container_3.getApplication();
      boolean _targets_3 = this._utils.targets(_application_3, "1.3.5");
      boolean _not_1 = (!_targets_3);
      if (_not_1) {
        _builder.append("</div>");
        _builder.newLine();
      }
    }
    _builder.append("</div>");
    _builder.newLine();
    return _builder;
  }
}
