package org.zikula.modulestudio.generator.cartridges.zclassic.view.pagecomponents;

import com.google.common.base.Objects;
import com.google.inject.Inject;
import de.guite.modulestudio.metamodel.modulestudio.Application;
import de.guite.modulestudio.metamodel.modulestudio.Controller;
import de.guite.modulestudio.metamodel.modulestudio.DateField;
import de.guite.modulestudio.metamodel.modulestudio.DatetimeField;
import de.guite.modulestudio.metamodel.modulestudio.DerivedField;
import de.guite.modulestudio.metamodel.modulestudio.Entity;
import de.guite.modulestudio.metamodel.modulestudio.JoinRelationship;
import de.guite.modulestudio.metamodel.modulestudio.ListField;
import de.guite.modulestudio.metamodel.modulestudio.Models;
import de.guite.modulestudio.metamodel.modulestudio.TimeField;
import de.guite.modulestudio.metamodel.modulestudio.UploadField;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.eclipse.xtext.xbase.lib.StringExtensions;
import org.zikula.modulestudio.generator.extensions.ControllerExtensions;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.UrlExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;
import org.zikula.modulestudio.generator.extensions.ViewExtensions;

@SuppressWarnings("all")
public class Relations {
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
  
  public void displayItemList(final Entity it, final Application app, final Controller controller, final Boolean many, final IFileSystemAccess fsa) {
    String _name = it.getName();
    String _xifexpression = null;
    if ((many).booleanValue()) {
      _xifexpression = "Many";
    } else {
      _xifexpression = "One";
    }
    String _plus = ("include_displayItemList" + _xifexpression);
    String _templateFile = this._namingExtensions.templateFile(controller, _name, _plus);
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{* purpose of this template: inclusion template for display of related ");
    String _nameMultiple = it.getNameMultiple();
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(_nameMultiple);
    _builder.append(_formatForDisplay, "");
    _builder.append(" in ");
    String _formattedName = this._controllerExtensions.formattedName(controller);
    _builder.append(_formattedName, "");
    _builder.append(" area *}");
    _builder.newLineIfNotEmpty();
    {
      boolean _hasActions = this._controllerExtensions.hasActions(controller, "display");
      if (_hasActions) {
        _builder.append("{if !isset($nolink)}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("{assign var=\'nolink\' value=false}");
        _builder.newLine();
        _builder.append("{/if}");
        _builder.newLine();
      }
    }
    {
      boolean _not = (!(many).booleanValue());
      if (_not) {
        _builder.append("<h4>");
        _builder.newLine();
      } else {
        _builder.append("{if isset($items) && $items ne null && count($items) gt 0}");
        _builder.newLine();
        _builder.append("<ul class=\"relatedItemList ");
        String _name_1 = it.getName();
        String _formatForCode = this._formattingExtensions.formatForCode(_name_1);
        _builder.append(_formatForCode, "");
        _builder.append("\">");
        _builder.newLineIfNotEmpty();
        _builder.append("{foreach name=\'relLoop\' item=\'item\' from=$items}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("<li>");
        _builder.newLine();
      }
    }
    {
      boolean _hasActions_1 = this._controllerExtensions.hasActions(controller, "display");
      if (_hasActions_1) {
        _builder.append("{strip}");
        _builder.newLine();
        _builder.append("{if !$nolink}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("<a href=\"{modurl modname=\'");
        String _appName = this._utils.appName(app);
        _builder.append(_appName, "    ");
        _builder.append("\' type=\'");
        String _formattedName_1 = this._controllerExtensions.formattedName(controller);
        _builder.append(_formattedName_1, "    ");
        _builder.append("\' ");
        String _modUrlDisplay = this._urlExtensions.modUrlDisplay(it, "item", Boolean.valueOf(true));
        _builder.append(_modUrlDisplay, "    ");
        _builder.append("}\" title=\"{$item.");
        DerivedField _leadingField = this._modelExtensions.getLeadingField(it);
        CharSequence _displayLeadingField = this.displayLeadingField(_leadingField);
        _builder.append(_displayLeadingField, "    ");
        _builder.append("|replace:\"\\\"\":\"\"}\">");
        _builder.newLineIfNotEmpty();
        _builder.append("{/if}");
        _builder.newLine();
      }
    }
    final DerivedField leadingField = this._modelExtensions.getLeadingField(it);
    _builder.newLineIfNotEmpty();
    {
      boolean _tripleNotEquals = (leadingField != null);
      if (_tripleNotEquals) {
        _builder.append("{$item.");
        CharSequence _displayLeadingField_1 = this.displayLeadingField(leadingField);
        _builder.append(_displayLeadingField_1, "");
        _builder.append("}");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("{gt text=\'");
        String _name_2 = it.getName();
        String _formatForDisplayCapital = this._formattingExtensions.formatForDisplayCapital(_name_2);
        _builder.append(_formatForDisplayCapital, "");
        _builder.append("\'}");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      boolean _hasActions_2 = this._controllerExtensions.hasActions(controller, "display");
      if (_hasActions_2) {
        _builder.append("{if !$nolink}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("</a>");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("<a id=\"");
        String _name_3 = it.getName();
        String _formatForCode_1 = this._formattingExtensions.formatForCode(_name_3);
        _builder.append(_formatForCode_1, "    ");
        _builder.append("Item");
        {
          Iterable<DerivedField> _primaryKeyFields = this._modelExtensions.getPrimaryKeyFields(it);
          boolean _hasElements = false;
          for(final DerivedField pkField : _primaryKeyFields) {
            if (!_hasElements) {
              _hasElements = true;
            } else {
              _builder.appendImmediate("_", "    ");
            }
            _builder.append("{$item.");
            String _name_4 = pkField.getName();
            String _formatForCode_2 = this._formattingExtensions.formatForCode(_name_4);
            _builder.append(_formatForCode_2, "    ");
            _builder.append("}");
          }
        }
        _builder.append("Display\" href=\"{modurl modname=\'");
        String _appName_1 = this._utils.appName(app);
        _builder.append(_appName_1, "    ");
        _builder.append("\' type=\'");
        String _formattedName_2 = this._controllerExtensions.formattedName(controller);
        _builder.append(_formattedName_2, "    ");
        _builder.append("\' ");
        String _modUrlDisplay_1 = this._urlExtensions.modUrlDisplay(it, "item", Boolean.valueOf(true));
        _builder.append(_modUrlDisplay_1, "    ");
        _builder.append(" theme=\'Printer\'");
        String _additionalUrlParametersForQuickViewLink = this._viewExtensions.additionalUrlParametersForQuickViewLink(controller);
        _builder.append(_additionalUrlParametersForQuickViewLink, "    ");
        _builder.append("}\" title=\"{gt text=\'Open quick view window\'}\" class=\"");
        {
          boolean _targets = this._utils.targets(app, "1.3.5");
          if (_targets) {
            _builder.append("z-");
          }
        }
        _builder.append("hide\">{icon type=\'view\' size=\'extrasmall\' __alt=\'Quick view\'}</a>");
        _builder.newLineIfNotEmpty();
        _builder.append("{/if}");
        _builder.newLine();
        _builder.append("{/strip}");
        _builder.newLine();
      }
    }
    {
      boolean _not_1 = (!(many).booleanValue());
      if (_not_1) {
        _builder.append("</h4>");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      boolean _hasActions_3 = this._controllerExtensions.hasActions(controller, "display");
      if (_hasActions_3) {
        _builder.append("{if !$nolink}");
        _builder.newLine();
        _builder.append("<script type=\"text/javascript\">");
        _builder.newLine();
        _builder.append("/* <![CDATA[ */");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("document.observe(\'dom:loaded\', function() {");
        _builder.newLine();
        {
          boolean _tripleNotEquals_1 = (leadingField != null);
          if (_tripleNotEquals_1) {
            _builder.append("        ");
            String _prefix = app.getPrefix();
            _builder.append(_prefix, "        ");
            _builder.append("InitInlineWindow($(\'");
            String _name_5 = it.getName();
            String _formatForCode_3 = this._formattingExtensions.formatForCode(_name_5);
            _builder.append(_formatForCode_3, "        ");
            _builder.append("Item");
            {
              Iterable<DerivedField> _primaryKeyFields_1 = this._modelExtensions.getPrimaryKeyFields(it);
              boolean _hasElements_1 = false;
              for(final DerivedField pkField_1 : _primaryKeyFields_1) {
                if (!_hasElements_1) {
                  _hasElements_1 = true;
                } else {
                  _builder.appendImmediate("_", "        ");
                }
                _builder.append("{{$item.");
                String _name_6 = pkField_1.getName();
                String _formatForCode_4 = this._formattingExtensions.formatForCode(_name_6);
                _builder.append(_formatForCode_4, "        ");
                _builder.append("}}");
              }
            }
            _builder.append("Display\'), \'{{$item.");
            String _name_7 = leadingField.getName();
            String _formatForCode_5 = this._formattingExtensions.formatForCode(_name_7);
            _builder.append(_formatForCode_5, "        ");
            _builder.append("|replace:\"\'\":\"\"}}\');");
            _builder.newLineIfNotEmpty();
          } else {
            _builder.append("        ");
            String _prefix_1 = app.getPrefix();
            _builder.append(_prefix_1, "        ");
            _builder.append("InitInlineWindow($(\'");
            String _name_8 = it.getName();
            String _formatForCode_6 = this._formattingExtensions.formatForCode(_name_8);
            _builder.append(_formatForCode_6, "        ");
            _builder.append("Item");
            {
              Iterable<DerivedField> _primaryKeyFields_2 = this._modelExtensions.getPrimaryKeyFields(it);
              boolean _hasElements_2 = false;
              for(final DerivedField pkField_2 : _primaryKeyFields_2) {
                if (!_hasElements_2) {
                  _hasElements_2 = true;
                } else {
                  _builder.appendImmediate("_", "        ");
                }
                _builder.append("{{$item.");
                String _name_9 = pkField_2.getName();
                String _formatForCode_7 = this._formattingExtensions.formatForCode(_name_9);
                _builder.append(_formatForCode_7, "        ");
                _builder.append("}}");
              }
            }
            _builder.append("Display\'), \'{{gt text=\'");
            String _name_10 = it.getName();
            String _formatForDisplayCapital_1 = this._formattingExtensions.formatForDisplayCapital(_name_10);
            _builder.append(_formatForDisplayCapital_1, "        ");
            _builder.append("\'|replace:\"\'\":\"\"}}\');");
            _builder.newLineIfNotEmpty();
          }
        }
        _builder.append("    ");
        _builder.append("});");
        _builder.newLine();
        _builder.append("/* ]]> */");
        _builder.newLine();
        _builder.append("</script>");
        _builder.newLine();
        _builder.append("{/if}");
        _builder.newLine();
      }
    }
    {
      boolean _hasImageFieldsEntity = this._modelExtensions.hasImageFieldsEntity(it);
      if (_hasImageFieldsEntity) {
        _builder.append("<br />");
        _builder.newLine();
        Iterable<UploadField> _imageFieldsEntity = this._modelExtensions.getImageFieldsEntity(it);
        UploadField _head = IterableExtensions.<UploadField>head(_imageFieldsEntity);
        String _name_11 = _head.getName();
        final String imageFieldName = this._formattingExtensions.formatForCode(_name_11);
        _builder.newLineIfNotEmpty();
        _builder.append("{if $item.");
        _builder.append(imageFieldName, "");
        _builder.append(" ne \'\' && isset($item.");
        _builder.append(imageFieldName, "");
        _builder.append("FullPath) && $item.");
        _builder.append(imageFieldName, "");
        _builder.append("Meta.isImage}");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("{thumb image=$item.");
        _builder.append(imageFieldName, "    ");
        _builder.append("FullPath objectid=\"");
        String _name_12 = it.getName();
        String _formatForCode_8 = this._formattingExtensions.formatForCode(_name_12);
        _builder.append(_formatForCode_8, "    ");
        {
          boolean _hasCompositeKeys = this._modelExtensions.hasCompositeKeys(it);
          if (_hasCompositeKeys) {
            {
              Iterable<DerivedField> _primaryKeyFields_3 = this._modelExtensions.getPrimaryKeyFields(it);
              for(final DerivedField pkField_3 : _primaryKeyFields_3) {
                _builder.append("-`$item.");
                String _name_13 = pkField_3.getName();
                String _formatForCode_9 = this._formattingExtensions.formatForCode(_name_13);
                _builder.append(_formatForCode_9, "    ");
                _builder.append("`");
              }
            }
          } else {
            _builder.append("-`$item.");
            Iterable<DerivedField> _primaryKeyFields_4 = this._modelExtensions.getPrimaryKeyFields(it);
            DerivedField _head_1 = IterableExtensions.<DerivedField>head(_primaryKeyFields_4);
            String _name_14 = _head_1.getName();
            String _formatForCode_10 = this._formattingExtensions.formatForCode(_name_14);
            _builder.append(_formatForCode_10, "    ");
            _builder.append("`");
          }
        }
        _builder.append("\" preset=$relationThumbPreset tag=true ");
        {
          boolean _tripleNotEquals_2 = (leadingField != null);
          if (_tripleNotEquals_2) {
            _builder.append("img_alt=$item.");
            String _name_15 = leadingField.getName();
            String _formatForCode_11 = this._formattingExtensions.formatForCode(_name_15);
            _builder.append(_formatForCode_11, "    ");
          } else {
            _builder.append("__img_alt=\'");
            String _name_16 = it.getName();
            String _formatForDisplayCapital_2 = this._formattingExtensions.formatForDisplayCapital(_name_16);
            _builder.append(_formatForDisplayCapital_2, "    ");
            _builder.append("\'");
          }
        }
        {
          Models _container = it.getContainer();
          Application _application = _container.getApplication();
          boolean _targets_1 = this._utils.targets(_application, "1.3.5");
          boolean _not_2 = (!_targets_1);
          if (_not_2) {
            _builder.append(" img_class=\'img-rounded\'");
          }
        }
        _builder.append("}");
        _builder.newLineIfNotEmpty();
        _builder.append("{/if}");
        _builder.newLine();
      }
    }
    {
      if ((many).booleanValue()) {
        _builder.append("    ");
        _builder.append("</li>");
        _builder.newLine();
        _builder.append("{/foreach}");
        _builder.newLine();
        _builder.append("</ul>");
        _builder.newLine();
        _builder.append("{/if}");
        _builder.newLine();
      }
    }
    fsa.generateFile(_templateFile, _builder);
  }
  
  private CharSequence displayLeadingField(final DerivedField it) {
    CharSequence _switchResult = null;
    boolean _matched = false;
    if (!_matched) {
      if (it instanceof ListField) {
        final ListField _listField = (ListField)it;
        _matched=true;
        StringConcatenation _builder = new StringConcatenation();
        String _name = _listField.getName();
        String _formatForCode = this._formattingExtensions.formatForCode(_name);
        _builder.append(_formatForCode, "");
        _builder.append("|");
        Entity _entity = _listField.getEntity();
        Models _container = _entity.getContainer();
        Application _application = _container.getApplication();
        String _appName = this._utils.appName(_application);
        String _formatForDB = this._formattingExtensions.formatForDB(_appName);
        _builder.append(_formatForDB, "");
        _builder.append("GetListEntry:\'");
        Entity _entity_1 = _listField.getEntity();
        String _name_1 = _entity_1.getName();
        String _formatForCode_1 = this._formattingExtensions.formatForCode(_name_1);
        _builder.append(_formatForCode_1, "");
        _builder.append("\':\'");
        String _name_2 = _listField.getName();
        String _formatForCode_2 = this._formattingExtensions.formatForCode(_name_2);
        _builder.append(_formatForCode_2, "");
        _builder.append("\'|safetext");
        _switchResult = _builder;
      }
    }
    if (!_matched) {
      if (it instanceof DateField) {
        final DateField _dateField = (DateField)it;
        _matched=true;
        StringConcatenation _builder = new StringConcatenation();
        String _name = _dateField.getName();
        String _formatForCode = this._formattingExtensions.formatForCode(_name);
        _builder.append(_formatForCode, "");
        _builder.append("|dateformat:\"datebrief\"");
        _switchResult = _builder;
      }
    }
    if (!_matched) {
      if (it instanceof DatetimeField) {
        final DatetimeField _datetimeField = (DatetimeField)it;
        _matched=true;
        StringConcatenation _builder = new StringConcatenation();
        String _name = _datetimeField.getName();
        String _formatForCode = this._formattingExtensions.formatForCode(_name);
        _builder.append(_formatForCode, "");
        _builder.append("|dateformat:\"datetimebrief\"");
        _switchResult = _builder;
      }
    }
    if (!_matched) {
      if (it instanceof TimeField) {
        final TimeField _timeField = (TimeField)it;
        _matched=true;
        StringConcatenation _builder = new StringConcatenation();
        String _name = _timeField.getName();
        String _formatForCode = this._formattingExtensions.formatForCode(_name);
        _builder.append(_formatForCode, "");
        _builder.append("|dateformat:\"timebrief\"");
        _switchResult = _builder;
      }
    }
    if (!_matched) {
      StringConcatenation _builder = new StringConcatenation();
      String _name = it.getName();
      String _formatForCode = this._formattingExtensions.formatForCode(_name);
      _builder.append(_formatForCode, "");
      _switchResult = _builder;
    }
    return _switchResult;
  }
  
  public CharSequence displayRelatedItems(final JoinRelationship it, final String appName, final Controller controller, final Entity relatedEntity) {
    StringConcatenation _builder = new StringConcatenation();
    boolean _xifexpression = false;
    Entity _target = it.getTarget();
    boolean _equals = Objects.equal(_target, relatedEntity);
    if (_equals) {
      _xifexpression = true;
    } else {
      _xifexpression = false;
    }
    final boolean incoming = _xifexpression;
    _builder.newLineIfNotEmpty();
    final boolean useTarget = (!incoming);
    _builder.newLineIfNotEmpty();
    String _relationAliasName = this._namingExtensions.getRelationAliasName(it, Boolean.valueOf(useTarget));
    String _formatForCode = this._formattingExtensions.formatForCode(_relationAliasName);
    final String relationAliasName = StringExtensions.toFirstLower(_formatForCode);
    _builder.newLineIfNotEmpty();
    boolean _not = (!useTarget);
    String _relationAliasName_1 = this._namingExtensions.getRelationAliasName(it, Boolean.valueOf(_not));
    final String relationAliasNameParam = this._formattingExtensions.formatForCodeCapital(_relationAliasName_1);
    _builder.newLineIfNotEmpty();
    Entity _xifexpression_1 = null;
    boolean _not_1 = (!useTarget);
    if (_not_1) {
      Entity _source = it.getSource();
      _xifexpression_1 = _source;
    } else {
      Entity _target_1 = it.getTarget();
      _xifexpression_1 = _target_1;
    }
    final Entity otherEntity = _xifexpression_1;
    _builder.newLineIfNotEmpty();
    final boolean many = this._modelJoinExtensions.isManySideDisplay(it, useTarget);
    _builder.newLineIfNotEmpty();
    {
      String _name = controller.getName();
      String _formatForDB = this._formattingExtensions.formatForDB(_name);
      boolean _equals_1 = Objects.equal(_formatForDB, "admin");
      if (_equals_1) {
        _builder.append("<h4>{gt text=\'");
        String _entityNameSingularPlural = this._modelExtensions.getEntityNameSingularPlural(otherEntity, Boolean.valueOf(many));
        String _formatForDisplayCapital = this._formattingExtensions.formatForDisplayCapital(_entityNameSingularPlural);
        _builder.append(_formatForDisplayCapital, "");
        _builder.append("\'}</h4>");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("<h3>{gt text=\'");
        String _entityNameSingularPlural_1 = this._modelExtensions.getEntityNameSingularPlural(otherEntity, Boolean.valueOf(many));
        String _formatForDisplayCapital_1 = this._formattingExtensions.formatForDisplayCapital(_entityNameSingularPlural_1);
        _builder.append(_formatForDisplayCapital_1, "");
        _builder.append("\'}</h3>");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.newLine();
    _builder.append("{if isset($");
    String _name_1 = relatedEntity.getName();
    String _formatForCode_1 = this._formattingExtensions.formatForCode(_name_1);
    _builder.append(_formatForCode_1, "");
    _builder.append(".");
    _builder.append(relationAliasName, "");
    _builder.append(") && $");
    String _name_2 = relatedEntity.getName();
    String _formatForCode_2 = this._formattingExtensions.formatForCode(_name_2);
    _builder.append(_formatForCode_2, "");
    _builder.append(".");
    _builder.append(relationAliasName, "");
    _builder.append(" ne null}");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("{include file=\'");
    {
      Models _container = it.getContainer();
      Application _application = _container.getApplication();
      boolean _targets = this._utils.targets(_application, "1.3.5");
      if (_targets) {
        String _formattedName = this._controllerExtensions.formattedName(controller);
        _builder.append(_formattedName, "    ");
        _builder.append("/");
        String _name_3 = otherEntity.getName();
        String _formatForCode_3 = this._formattingExtensions.formatForCode(_name_3);
        _builder.append(_formatForCode_3, "    ");
      } else {
        String _formattedName_1 = this._controllerExtensions.formattedName(controller);
        String _firstUpper = StringExtensions.toFirstUpper(_formattedName_1);
        _builder.append(_firstUpper, "    ");
        _builder.append("/");
        String _name_4 = otherEntity.getName();
        String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(_name_4);
        _builder.append(_formatForCodeCapital, "    ");
      }
    }
    _builder.append("/include_displayItemList");
    {
      if (many) {
        _builder.append("Many");
      } else {
        _builder.append("One");
      }
    }
    _builder.append(".tpl\' item");
    {
      if (many) {
        _builder.append("s");
      }
    }
    _builder.append("=$");
    String _name_5 = relatedEntity.getName();
    String _formatForCode_4 = this._formattingExtensions.formatForCode(_name_5);
    _builder.append(_formatForCode_4, "    ");
    _builder.append(".");
    _builder.append(relationAliasName, "    ");
    _builder.append("}");
    _builder.newLineIfNotEmpty();
    _builder.append("{/if}");
    _builder.newLine();
    _builder.newLine();
    {
      boolean _hasActions = this._controllerExtensions.hasActions(controller, "edit");
      if (_hasActions) {
        {
          boolean _not_2 = (!many);
          if (_not_2) {
            _builder.append("{if !isset($");
            String _name_6 = relatedEntity.getName();
            String _formatForCode_5 = this._formattingExtensions.formatForCode(_name_6);
            _builder.append(_formatForCode_5, "");
            _builder.append(".");
            _builder.append(relationAliasName, "");
            _builder.append(") || $");
            String _name_7 = relatedEntity.getName();
            String _formatForCode_6 = this._formattingExtensions.formatForCode(_name_7);
            _builder.append(_formatForCode_6, "");
            _builder.append(".");
            _builder.append(relationAliasName, "");
            _builder.append(" eq null}");
            _builder.newLineIfNotEmpty();
          }
        }
        _builder.append("{checkpermission component=\'");
        _builder.append(appName, "");
        _builder.append(":");
        String _name_8 = relatedEntity.getName();
        String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(_name_8);
        _builder.append(_formatForCodeCapital_1, "");
        _builder.append(":\' instance=\"");
        CharSequence _idFieldsAsParameterTemplate = this._modelExtensions.idFieldsAsParameterTemplate(relatedEntity);
        _builder.append(_idFieldsAsParameterTemplate, "");
        _builder.append("::\" level=\'ACCESS_ADMIN\' assign=\'authAdmin\'}");
        _builder.newLineIfNotEmpty();
        _builder.append("{if $authAdmin || (isset($uid) && isset($");
        String _name_9 = relatedEntity.getName();
        String _formatForCode_7 = this._formattingExtensions.formatForCode(_name_9);
        _builder.append(_formatForCode_7, "");
        _builder.append(".createdUserId) && $");
        String _name_10 = relatedEntity.getName();
        String _formatForCode_8 = this._formattingExtensions.formatForCode(_name_10);
        _builder.append(_formatForCode_8, "");
        _builder.append(".createdUserId eq $uid)}");
        _builder.newLineIfNotEmpty();
        _builder.append("<p class=\"manageLink\">");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("{gt text=\'Create ");
        String _name_11 = otherEntity.getName();
        String _formatForDisplay = this._formattingExtensions.formatForDisplay(_name_11);
        _builder.append(_formatForDisplay, "    ");
        _builder.append("\' assign=\'createTitle\'}");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("<a href=\"{modurl modname=\'");
        _builder.append(appName, "    ");
        _builder.append("\' type=\'");
        String _formattedName_2 = this._controllerExtensions.formattedName(controller);
        _builder.append(_formattedName_2, "    ");
        _builder.append("\' func=\'edit\' ot=\'");
        String _name_12 = otherEntity.getName();
        String _formatForCode_9 = this._formattingExtensions.formatForCode(_name_12);
        _builder.append(_formatForCode_9, "    ");
        _builder.append("\' ");
        String _formatForDB_1 = this._formattingExtensions.formatForDB(relationAliasNameParam);
        _builder.append(_formatForDB_1, "    ");
        _builder.append("=\"");
        CharSequence _idFieldsAsParameterTemplate_1 = this._modelExtensions.idFieldsAsParameterTemplate(relatedEntity);
        _builder.append(_idFieldsAsParameterTemplate_1, "    ");
        _builder.append("\" returnTo=\'");
        String _formattedName_3 = this._controllerExtensions.formattedName(controller);
        _builder.append(_formattedName_3, "    ");
        _builder.append("Display");
        String _name_13 = relatedEntity.getName();
        String _formatForCodeCapital_2 = this._formattingExtensions.formatForCodeCapital(_name_13);
        _builder.append(_formatForCodeCapital_2, "    ");
        _builder.append("\'}\" title=\"{$createTitle}\" class=\"z-icon-es-add\">{$createTitle}</a>");
        _builder.newLineIfNotEmpty();
        _builder.append("</p>");
        _builder.newLine();
        _builder.append("{/if}");
        _builder.newLine();
        {
          boolean _not_3 = (!many);
          if (_not_3) {
            _builder.append("{/if}");
            _builder.newLine();
          }
        }
      }
    }
    return _builder;
  }
}
