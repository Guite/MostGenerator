package org.zikula.modulestudio.generator.cartridges.zclassic.view.formcomponents;

import com.google.common.base.Objects;
import de.guite.modulestudio.metamodel.Application;
import de.guite.modulestudio.metamodel.DerivedField;
import de.guite.modulestudio.metamodel.Entity;
import de.guite.modulestudio.metamodel.EntityWorkflowType;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.zikula.modulestudio.generator.cartridges.zclassic.view.formcomponents.Relations;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;
import org.zikula.modulestudio.generator.extensions.ViewExtensions;

@SuppressWarnings("all")
public class Section {
  @Extension
  private FormattingExtensions _formattingExtensions = new FormattingExtensions();
  
  @Extension
  private ModelExtensions _modelExtensions = new ModelExtensions();
  
  @Extension
  private ViewExtensions _viewExtensions = new ViewExtensions();
  
  @Extension
  private Utils _utils = new Utils();
  
  private Relations relationHelper = new Relations();
  
  /**
   * Entry point for edit sections beside the actual fields.
   */
  public CharSequence generate(final Entity it, final Application app, final IFileSystemAccess fsa) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.newLine();
    CharSequence _extensionsAndRelations = this.extensionsAndRelations(it, app, fsa);
    _builder.append(_extensionsAndRelations);
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    {
      boolean _isSkipHookSubscribers = it.isSkipHookSubscribers();
      boolean _not = (!_isSkipHookSubscribers);
      if (_not) {
        CharSequence _displayHooks = this.displayHooks(it, app);
        _builder.append(_displayHooks);
        _builder.newLineIfNotEmpty();
        _builder.newLine();
      }
    }
    CharSequence _additionalRemark = this.additionalRemark(it);
    _builder.append(_additionalRemark);
    _builder.newLineIfNotEmpty();
    CharSequence _moderationFields = this.moderationFields(it);
    _builder.append(_moderationFields);
    _builder.newLineIfNotEmpty();
    CharSequence _returnControl = this.returnControl(it);
    _builder.append(_returnControl);
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence extensionsAndRelations(final Entity it, final Application app, final IFileSystemAccess fsa) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _isGeographical = it.isGeographical();
      if (_isGeographical) {
        {
          boolean _useGroupingTabs = this._viewExtensions.useGroupingTabs(it, "edit");
          if (_useGroupingTabs) {
            _builder.append("<div role=\"tabpanel\" class=\"tab-pane fade\" id=\"tabMap\" aria-labelledby=\"mapTab\">");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("<h3>{{ __(\'Map\') }}</h3>");
            _builder.newLine();
          } else {
            _builder.append("<fieldset class=\"");
            String _lowerCase = this._utils.appName(app).toLowerCase();
            _builder.append(_lowerCase);
            _builder.append("-map\">");
            _builder.newLineIfNotEmpty();
          }
        }
        _builder.append("    ");
        _builder.append("<legend>{{ __(\'Map\') }}</legend>");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("<div id=\"mapContainer\" class=\"");
        String _lowerCase_1 = this._utils.appName(app).toLowerCase();
        _builder.append(_lowerCase_1, "    ");
        _builder.append("-mapcontainer\">");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("</div>");
        _builder.newLine();
        {
          boolean _useGroupingTabs_1 = this._viewExtensions.useGroupingTabs(it, "edit");
          if (_useGroupingTabs_1) {
            _builder.append("</div>");
            _builder.newLine();
          } else {
            _builder.append("</fieldset>");
            _builder.newLine();
          }
        }
        _builder.newLine();
      }
    }
    CharSequence _generateIncludeStatement = this.relationHelper.generateIncludeStatement(it, app, fsa);
    _builder.append(_generateIncludeStatement);
    _builder.newLineIfNotEmpty();
    {
      boolean _isAttributable = it.isAttributable();
      if (_isAttributable) {
        _builder.append("{% if featureActivationHelper.isEnabled(constant(\'");
        String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(app.getVendor());
        _builder.append(_formatForCodeCapital);
        _builder.append("\\\\");
        String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(app.getName());
        _builder.append(_formatForCodeCapital_1);
        _builder.append("Module\\\\Helper\\\\FeatureActivationHelper::ATTRIBUTES\'), \'");
        String _formatForCode = this._formattingExtensions.formatForCode(it.getName());
        _builder.append(_formatForCode);
        _builder.append("\') %}");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("{{ include(\'@");
        String _appName = this._utils.appName(app);
        _builder.append(_appName, "    ");
        _builder.append("/Helper/includeAttributesEdit.html.twig\', { obj: ");
        String _formatForDB = this._formattingExtensions.formatForDB(it.getName());
        _builder.append(_formatForDB, "    ");
        {
          boolean _useGroupingTabs_2 = this._viewExtensions.useGroupingTabs(it, "edit");
          if (_useGroupingTabs_2) {
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
        String _formatForCodeCapital_2 = this._formattingExtensions.formatForCodeCapital(app.getVendor());
        _builder.append(_formatForCodeCapital_2);
        _builder.append("\\\\");
        String _formatForCodeCapital_3 = this._formattingExtensions.formatForCodeCapital(app.getName());
        _builder.append(_formatForCodeCapital_3);
        _builder.append("Module\\\\Helper\\\\FeatureActivationHelper::CATEGORIES\'), \'");
        String _formatForCode_1 = this._formattingExtensions.formatForCode(it.getName());
        _builder.append(_formatForCode_1);
        _builder.append("\') %}");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("{{ include(\'@");
        String _appName_1 = this._utils.appName(app);
        _builder.append(_appName_1, "    ");
        _builder.append("/Helper/includeCategoriesEdit.html.twig\', { obj: ");
        String _formatForDB_1 = this._formattingExtensions.formatForDB(it.getName());
        _builder.append(_formatForDB_1, "    ");
        {
          boolean _useGroupingTabs_3 = this._viewExtensions.useGroupingTabs(it, "edit");
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
      boolean _isStandardFields = it.isStandardFields();
      if (_isStandardFields) {
        _builder.append("{% if mode != \'create\' %}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("{{ include(\'@");
        String _appName_2 = this._utils.appName(app);
        _builder.append(_appName_2, "    ");
        _builder.append("/Helper/includeStandardFieldsEdit.html.twig\', { obj: ");
        String _formatForDB_2 = this._formattingExtensions.formatForDB(it.getName());
        _builder.append(_formatForDB_2, "    ");
        {
          boolean _useGroupingTabs_4 = this._viewExtensions.useGroupingTabs(it, "edit");
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
    return _builder;
  }
  
  private CharSequence displayHooks(final Entity it, final Application app) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _useGroupingTabs = this._viewExtensions.useGroupingTabs(it, "edit");
      if (_useGroupingTabs) {
        _builder.append("<div role=\"tabpanel\" class=\"tab-pane fade\" id=\"tabHooks\" aria-labelledby=\"hooksTab\">");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("<h3>{{ __(\'Hooks\') }}</h3>");
        _builder.newLine();
      }
    }
    _builder.append("{% set hookId = mode != \'create\' ? ");
    {
      Iterable<DerivedField> _primaryKeyFields = this._modelExtensions.getPrimaryKeyFields(it);
      boolean _hasElements = false;
      for(final DerivedField pkField : _primaryKeyFields) {
        if (!_hasElements) {
          _hasElements = true;
        } else {
          _builder.appendImmediate(" ~ ", "");
        }
        String _formatForDB = this._formattingExtensions.formatForDB(it.getName());
        _builder.append(_formatForDB);
        _builder.append(".");
        String _formatForCode = this._formattingExtensions.formatForCode(pkField.getName());
        _builder.append(_formatForCode);
      }
    }
    _builder.append(" : null %}");
    _builder.newLineIfNotEmpty();
    _builder.append("{% set hooks = notifyDisplayHooks(eventName=\'");
    String _formatForDB_1 = this._formattingExtensions.formatForDB(this._utils.appName(app));
    _builder.append(_formatForDB_1);
    _builder.append(".ui_hooks.");
    String _formatForDB_2 = this._formattingExtensions.formatForDB(it.getNameMultiple());
    _builder.append(_formatForDB_2);
    _builder.append(".form_edit\', id=hookId) %}");
    _builder.newLineIfNotEmpty();
    _builder.append("{% if hooks is iterable and hooks|length > 0 %}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{% for providerArea, hook in hooks if providerArea != \'provider.scribite.ui_hooks.editor\' %}");
    _builder.newLine();
    {
      boolean _useGroupingTabs_1 = this._viewExtensions.useGroupingTabs(it, "edit");
      if (_useGroupingTabs_1) {
        _builder.append("        ");
        _builder.append("<h4>{{ providerArea }}</h4>");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("{{ hook }}");
        _builder.newLine();
      } else {
        _builder.append("        ");
        _builder.append("<fieldset>");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("<legend>{{ providerArea }}</legend>");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("{{ hook }}");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("</fieldset>");
        _builder.newLine();
      }
    }
    _builder.append("    ");
    _builder.append("{% endfor %}");
    _builder.newLine();
    _builder.append("{% endif %}");
    _builder.newLine();
    {
      boolean _useGroupingTabs_2 = this._viewExtensions.useGroupingTabs(it, "edit");
      if (_useGroupingTabs_2) {
        _builder.append("</div>");
        _builder.newLine();
      }
    }
    return _builder;
  }
  
  private CharSequence additionalRemark(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      EntityWorkflowType _workflow = it.getWorkflow();
      boolean _notEquals = (!Objects.equal(_workflow, EntityWorkflowType.NONE));
      if (_notEquals) {
        _builder.append("<fieldset>");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("<legend>{{ __(\'Communication\') }}</legend>");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("{{ form_row(form.additionalNotificationRemarks) }}");
        _builder.newLine();
        _builder.append("</fieldset>");
        _builder.newLine();
        _builder.newLine();
      }
    }
    return _builder;
  }
  
  private CharSequence moderationFields(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _isStandardFields = it.isStandardFields();
      if (_isStandardFields) {
        _builder.append("{% if form.moderationSpecificCreator is defined %}");
        _builder.newLine();
        {
          boolean _useGroupingTabs = this._viewExtensions.useGroupingTabs(it, "edit");
          if (_useGroupingTabs) {
            _builder.append("    ");
            _builder.append("<div role=\"tabpanel\" class=\"tab-pane fade\" id=\"tabModeration\" aria-labelledby=\"moderationTab\">");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("<h3>{{ __(\'Moderation\') }}</h3>");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("{{ form_row(form.moderationSpecificCreator) }}");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("{{ form_row(form.moderationSpecificCreationDate) }}");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("</div>");
            _builder.newLine();
          } else {
            _builder.append("    ");
            _builder.append("<fieldset id=\"moderationFieldsSection\">");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("<legend>{{ __(\'Moderation\') }} <i class=\"fa fa-expand\"></i></legend>");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("<div id=\"moderationFieldsContent\">");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("        ");
            _builder.append("{{ form_row(form.moderationSpecificCreator) }}");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("        ");
            _builder.append("{{ form_row(form.moderationSpecificCreationDate) }}");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("</div>");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("</fieldset>");
            _builder.newLine();
          }
        }
        _builder.append("{% endif %}");
        _builder.newLine();
        _builder.newLine();
      }
    }
    return _builder;
  }
  
  private CharSequence returnControl(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{# include return control #}");
    _builder.newLine();
    _builder.append("{% if mode == \'create\' %}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<fieldset>");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<legend>{{ __(\'Return control\') }}</legend>");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("{{ form_row(form.repeatCreation) }}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("</fieldset>");
    _builder.newLine();
    _builder.append("{% endif %}");
    _builder.newLine();
    return _builder;
  }
}
