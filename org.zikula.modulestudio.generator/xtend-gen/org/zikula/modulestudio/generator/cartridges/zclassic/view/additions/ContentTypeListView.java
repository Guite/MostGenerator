package org.zikula.modulestudio.generator.cartridges.zclassic.view.additions;

import com.google.common.collect.Iterables;
import com.google.inject.Inject;
import de.guite.modulestudio.metamodel.modulestudio.Application;
import de.guite.modulestudio.metamodel.modulestudio.DerivedField;
import de.guite.modulestudio.metamodel.modulestudio.Entity;
import de.guite.modulestudio.metamodel.modulestudio.EntityField;
import de.guite.modulestudio.metamodel.modulestudio.StringField;
import de.guite.modulestudio.metamodel.modulestudio.TextField;
import de.guite.modulestudio.metamodel.modulestudio.UserController;
import org.eclipse.emf.common.util.EList;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.zikula.modulestudio.generator.extensions.ControllerExtensions;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.UrlExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class ContentTypeListView {
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
  
  public void generate(final Application it, final IFileSystemAccess fsa) {
    String _viewPath = this._namingExtensions.getViewPath(it);
    String _xifexpression = null;
    boolean _targets = this._utils.targets(it, "1.3.5");
    if (_targets) {
      _xifexpression = "contenttype";
    } else {
      _xifexpression = "ContentType";
    }
    String _plus = (_viewPath + _xifexpression);
    final String templatePath = (_plus + "/");
    EList<Entity> _allEntities = this._modelExtensions.getAllEntities(it);
    for (final Entity entity : _allEntities) {
      {
        String _plus_1 = (templatePath + "itemlist_");
        String _name = entity.getName();
        String _formatForCode = this._formattingExtensions.formatForCode(_name);
        String _plus_2 = (_plus_1 + _formatForCode);
        String _plus_3 = (_plus_2 + "_display_description.tpl");
        CharSequence _displayDescTemplate = this.displayDescTemplate(entity, it);
        fsa.generateFile(_plus_3, _displayDescTemplate);
        String _plus_4 = (templatePath + "itemlist_");
        String _name_1 = entity.getName();
        String _formatForCode_1 = this._formattingExtensions.formatForCode(_name_1);
        String _plus_5 = (_plus_4 + _formatForCode_1);
        String _plus_6 = (_plus_5 + "_display.tpl");
        CharSequence _displayTemplate = this.displayTemplate(entity, it);
        fsa.generateFile(_plus_6, _displayTemplate);
      }
    }
    String _plus_1 = (templatePath + "itemlist_edit.tpl");
    CharSequence _editTemplate = this.editTemplate(it);
    fsa.generateFile(_plus_1, _editTemplate);
  }
  
  private CharSequence displayDescTemplate(final Entity it, final Application app) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{* Purpose of this template: Display ");
    String _nameMultiple = it.getNameMultiple();
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(_nameMultiple);
    _builder.append(_formatForDisplay, "");
    _builder.append(" within an external context *}");
    _builder.newLineIfNotEmpty();
    _builder.append("<dl>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{foreach item=\'");
    String _name = it.getName();
    String _formatForCode = this._formattingExtensions.formatForCode(_name);
    _builder.append(_formatForCode, "    ");
    _builder.append("\' from=$items}");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    final DerivedField leadingField = this._modelExtensions.getLeadingField(it);
    _builder.newLineIfNotEmpty();
    {
      boolean _tripleNotEquals = (leadingField != null);
      if (_tripleNotEquals) {
        _builder.append("        ");
        _builder.append("<dt>{$");
        String _name_1 = it.getName();
        String _formatForCode_1 = this._formattingExtensions.formatForCode(_name_1);
        _builder.append(_formatForCode_1, "        ");
        _builder.append(".");
        String _name_2 = leadingField.getName();
        String _formatForCode_2 = this._formattingExtensions.formatForCode(_name_2);
        _builder.append(_formatForCode_2, "        ");
        _builder.append("}</dt>");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("        ");
        _builder.append("<dt>{gt text=\'");
        String _name_3 = it.getName();
        String _formatForDisplayCapital = this._formattingExtensions.formatForDisplayCapital(_name_3);
        _builder.append(_formatForDisplayCapital, "        ");
        _builder.append("\'}</dt>");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("        ");
    EList<EntityField> _fields = it.getFields();
    final Iterable<TextField> textFields = Iterables.<TextField>filter(_fields, TextField.class);
    _builder.newLineIfNotEmpty();
    {
      boolean _isEmpty = IterableExtensions.isEmpty(textFields);
      boolean _not = (!_isEmpty);
      if (_not) {
        _builder.append("        ");
        _builder.append("{if $");
        String _name_4 = it.getName();
        String _formatForCode_3 = this._formattingExtensions.formatForCode(_name_4);
        _builder.append(_formatForCode_3, "        ");
        _builder.append(".");
        TextField _head = IterableExtensions.<TextField>head(textFields);
        String _name_5 = _head.getName();
        String _formatForCode_4 = this._formattingExtensions.formatForCode(_name_5);
        _builder.append(_formatForCode_4, "        ");
        _builder.append("}");
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("<dd>{$");
        String _name_6 = it.getName();
        String _formatForCode_5 = this._formattingExtensions.formatForCode(_name_6);
        _builder.append(_formatForCode_5, "            ");
        _builder.append(".");
        TextField _head_1 = IterableExtensions.<TextField>head(textFields);
        String _name_7 = _head_1.getName();
        String _formatForCode_6 = this._formattingExtensions.formatForCode(_name_7);
        _builder.append(_formatForCode_6, "            ");
        _builder.append("|truncate:200:\"...\"}</dd>");
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        _builder.append("{/if}");
        _builder.newLine();
      } else {
        _builder.append("        ");
        EList<EntityField> _fields_1 = it.getFields();
        Iterable<StringField> _filter = Iterables.<StringField>filter(_fields_1, StringField.class);
        final Function1<StringField,Boolean> _function = new Function1<StringField,Boolean>() {
          public Boolean apply(final StringField e) {
            boolean _and = false;
            boolean _isLeading = e.isLeading();
            boolean _not = (!_isLeading);
            if (!_not) {
              _and = false;
            } else {
              boolean _isPassword = e.isPassword();
              boolean _not_1 = (!_isPassword);
              _and = (_not && _not_1);
            }
            return Boolean.valueOf(_and);
          }
        };
        final Iterable<StringField> stringFields = IterableExtensions.<StringField>filter(_filter, _function);
        _builder.newLineIfNotEmpty();
        {
          boolean _isEmpty_1 = IterableExtensions.isEmpty(stringFields);
          boolean _not_1 = (!_isEmpty_1);
          if (_not_1) {
            _builder.append("        ");
            _builder.append("{if $");
            String _name_8 = it.getName();
            String _formatForCode_7 = this._formattingExtensions.formatForCode(_name_8);
            _builder.append(_formatForCode_7, "        ");
            _builder.append(".");
            StringField _head_2 = IterableExtensions.<StringField>head(stringFields);
            String _name_9 = _head_2.getName();
            String _formatForCode_8 = this._formattingExtensions.formatForCode(_name_9);
            _builder.append(_formatForCode_8, "        ");
            _builder.append("}");
            _builder.newLineIfNotEmpty();
            _builder.append("        ");
            _builder.append("    ");
            _builder.append("<dd>{$");
            String _name_10 = it.getName();
            String _formatForCode_9 = this._formattingExtensions.formatForCode(_name_10);
            _builder.append(_formatForCode_9, "            ");
            _builder.append(".");
            StringField _head_3 = IterableExtensions.<StringField>head(stringFields);
            String _name_11 = _head_3.getName();
            String _formatForCode_10 = this._formattingExtensions.formatForCode(_name_11);
            _builder.append(_formatForCode_10, "            ");
            _builder.append("|truncate:200:\"...\"}</dd>");
            _builder.newLineIfNotEmpty();
            _builder.append("        ");
            _builder.append("{/if}");
            _builder.newLine();
          }
        }
      }
    }
    _builder.append("        ");
    _builder.append("<dd>");
    String _appName = this._utils.appName(app);
    CharSequence _detailLink = this.detailLink(it, _appName);
    _builder.append(_detailLink, "        ");
    _builder.append("</dd>");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("{foreachelse}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<dt>{gt text=\'No entries found.\'}</dt>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{/foreach}");
    _builder.newLine();
    _builder.append("</dl>");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence displayTemplate(final Entity it, final Application app) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{* Purpose of this template: Display ");
    String _nameMultiple = it.getNameMultiple();
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(_nameMultiple);
    _builder.append(_formatForDisplay, "");
    _builder.append(" within an external context *}");
    _builder.newLineIfNotEmpty();
    _builder.append("{foreach item=\'");
    String _name = it.getName();
    String _formatForCode = this._formattingExtensions.formatForCode(_name);
    _builder.append(_formatForCode, "");
    _builder.append("\' from=$items}");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    final DerivedField leadingField = this._modelExtensions.getLeadingField(it);
    _builder.newLineIfNotEmpty();
    {
      boolean _tripleNotEquals = (leadingField != null);
      if (_tripleNotEquals) {
        _builder.append("    ");
        _builder.append("<h3>{$");
        String _name_1 = it.getName();
        String _formatForCode_1 = this._formattingExtensions.formatForCode(_name_1);
        _builder.append(_formatForCode_1, "    ");
        _builder.append(".");
        String _name_2 = leadingField.getName();
        String _formatForCode_2 = this._formattingExtensions.formatForCode(_name_2);
        _builder.append(_formatForCode_2, "    ");
        _builder.append("}</h3>");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("    ");
        _builder.append("<h3>{gt text=\'");
        String _name_3 = it.getName();
        String _formatForDisplayCapital = this._formattingExtensions.formatForDisplayCapital(_name_3);
        _builder.append(_formatForDisplayCapital, "    ");
        _builder.append("\'}</h3>");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      boolean _and = false;
      boolean _hasUserController = this._controllerExtensions.hasUserController(app);
      if (!_hasUserController) {
        _and = false;
      } else {
        UserController _mainUserController = this._controllerExtensions.getMainUserController(app);
        boolean _hasActions = this._controllerExtensions.hasActions(_mainUserController, "display");
        _and = (_hasUserController && _hasActions);
      }
      if (_and) {
        _builder.append("    ");
        _builder.append("<p>");
        String _appName = this._utils.appName(app);
        CharSequence _detailLink = this.detailLink(it, _appName);
        _builder.append(_detailLink, "    ");
        _builder.append("</p>");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("{/foreach}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence editTemplate(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{* Purpose of this template: edit view of generic item list content type *}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("<div class=\"z-formrow\">");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{gt text=\'Object type\' domain=\'module_");
    String _appName = this._utils.appName(it);
    String _formatForDB = this._formattingExtensions.formatForDB(_appName);
    _builder.append(_formatForDB, "    ");
    _builder.append("\' assign=\'objectTypeSelectorLabel\'}");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("{formlabel for=\'");
    String _appName_1 = this._utils.appName(it);
    _builder.append(_appName_1, "    ");
    _builder.append("_objecttype\' text=$objectTypeSelectorLabel}");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("{");
    String _appName_2 = this._utils.appName(it);
    String _formatForDB_1 = this._formattingExtensions.formatForDB(_appName_2);
    _builder.append(_formatForDB_1, "    ");
    _builder.append("ObjectTypeSelector assign=\'allObjectTypes\'}");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("{formdropdownlist id=\'");
    String _appName_3 = this._utils.appName(it);
    _builder.append(_appName_3, "    ");
    _builder.append("_objecttype\' dataField=\'objectType\' group=\'data\' mandatory=true items=$allObjectTypes}");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("<span class=\"z-sub z-formnote\">{gt text=\'If you change this please save the element once to reload the parameters below.\' domain=\'module_");
    String _appName_4 = this._utils.appName(it);
    String _formatForDB_2 = this._formattingExtensions.formatForDB(_appName_4);
    _builder.append(_formatForDB_2, "    ");
    _builder.append("\'}</span>");
    _builder.newLineIfNotEmpty();
    _builder.append("</div>");
    _builder.newLine();
    _builder.newLine();
    _builder.append("{formvolatile}");
    _builder.newLine();
    _builder.append("{if $properties ne null && is_array($properties)}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{nocache}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{foreach key=\'registryId\' item=\'registryCid\' from=$registries}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("{assign var=\'propName\' value=\'\'}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("{foreach key=\'propertyName\' item=\'propertyId\' from=$properties}");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("{if $propertyId eq $registryId}");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("{assign var=\'propName\' value=$propertyName}");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("{/if}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("{/foreach}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("<div class=\"z-formrow\">");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("{modapifunc modname=\'");
    String _appName_5 = this._utils.appName(it);
    _builder.append(_appName_5, "            ");
    _builder.append("\' type=\'category\' func=\'hasMultipleSelection\' ot=$objectType registry=$propertyName assign=\'hasMultiSelection\'}");
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    _builder.append("{gt text=\'Category\' domain=\'module_");
    String _appName_6 = this._utils.appName(it);
    String _formatForDB_3 = this._formattingExtensions.formatForDB(_appName_6);
    _builder.append(_formatForDB_3, "            ");
    _builder.append("\' assign=\'categorySelectorLabel\'}");
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    _builder.append("{assign var=\'selectionMode\' value=\'single\'}");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("{if $hasMultiSelection eq true}");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("{gt text=\'Categories\' domain=\'module_");
    String _appName_7 = this._utils.appName(it);
    String _formatForDB_4 = this._formattingExtensions.formatForDB(_appName_7);
    _builder.append(_formatForDB_4, "                ");
    _builder.append("\' assign=\'categorySelectorLabel\'}");
    _builder.newLineIfNotEmpty();
    _builder.append("                ");
    _builder.append("{assign var=\'selectionMode\' value=\'multiple\'}");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("{/if}");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("{formlabel for=\"");
    String _appName_8 = this._utils.appName(it);
    _builder.append(_appName_8, "            ");
    _builder.append("_catids`$propertyName`\" text=$categorySelectorLabel}");
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    _builder.append("{formdropdownlist id=\"");
    String _appName_9 = this._utils.appName(it);
    _builder.append(_appName_9, "            ");
    _builder.append("_catids`$propName`\" items=$categories.$propName dataField=\"catids`$propName`\" group=\'data\' selectionMode=$selectionMode}");
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    _builder.append("<span class=\"z-sub z-formnote\">{gt text=\'This is an optional filter.\' domain=\'module_");
    String _appName_10 = this._utils.appName(it);
    String _formatForDB_5 = this._formattingExtensions.formatForDB(_appName_10);
    _builder.append(_formatForDB_5, "            ");
    _builder.append("\'}</span>");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("</div>");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{/foreach}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{/nocache}");
    _builder.newLine();
    _builder.append("{/if}");
    _builder.newLine();
    _builder.append("{/formvolatile}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("<div class=\"z-formrow\">");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{gt text=\'Sorting\' domain=\'module_");
    String _appName_11 = this._utils.appName(it);
    String _formatForDB_6 = this._formattingExtensions.formatForDB(_appName_11);
    _builder.append(_formatForDB_6, "    ");
    _builder.append("\' assign=\'sortingLabel\'}");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("{formlabel text=$sortingLabel}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<div>");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("{formradiobutton id=\'");
    String _appName_12 = this._utils.appName(it);
    _builder.append(_appName_12, "        ");
    _builder.append("_srandom\' value=\'random\' dataField=\'sorting\' group=\'data\' mandatory=true}");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("{gt text=\'Random\' domain=\'module_");
    String _appName_13 = this._utils.appName(it);
    String _formatForDB_7 = this._formattingExtensions.formatForDB(_appName_13);
    _builder.append(_formatForDB_7, "        ");
    _builder.append("\' assign=\'sortingRandomLabel\'}");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("{formlabel for=\'");
    String _appName_14 = this._utils.appName(it);
    _builder.append(_appName_14, "        ");
    _builder.append("_srandom\' text=$sortingRandomLabel}");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("{formradiobutton id=\'");
    String _appName_15 = this._utils.appName(it);
    _builder.append(_appName_15, "        ");
    _builder.append("_snewest\' value=\'newest\' dataField=\'sorting\' group=\'data\' mandatory=true}");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("{gt text=\'Newest\' domain=\'module_");
    String _appName_16 = this._utils.appName(it);
    String _formatForDB_8 = this._formattingExtensions.formatForDB(_appName_16);
    _builder.append(_formatForDB_8, "        ");
    _builder.append("\' assign=\'sortingNewestLabel\'}");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("{formlabel for=\'");
    String _appName_17 = this._utils.appName(it);
    _builder.append(_appName_17, "        ");
    _builder.append("_snewest\' text=$sortingNewestLabel}");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("{formradiobutton id=\'");
    String _appName_18 = this._utils.appName(it);
    _builder.append(_appName_18, "        ");
    _builder.append("_sdefault\' value=\'default\' dataField=\'sorting\' group=\'data\' mandatory=true}");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("{gt text=\'Default\' domain=\'module_");
    String _appName_19 = this._utils.appName(it);
    String _formatForDB_9 = this._formattingExtensions.formatForDB(_appName_19);
    _builder.append(_formatForDB_9, "        ");
    _builder.append("\' assign=\'sortingDefaultLabel\'}");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("{formlabel for=\'");
    String _appName_20 = this._utils.appName(it);
    _builder.append(_appName_20, "        ");
    _builder.append("_sdefault\' text=$sortingDefaultLabel}");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("</div>");
    _builder.newLine();
    _builder.append("</div>");
    _builder.newLine();
    _builder.newLine();
    _builder.append("<div class=\"z-formrow\">");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{gt text=\'Amount\' domain=\'module_");
    String _appName_21 = this._utils.appName(it);
    String _formatForDB_10 = this._formattingExtensions.formatForDB(_appName_21);
    _builder.append(_formatForDB_10, "    ");
    _builder.append("\' assign=\'amountLabel\'}");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("{formlabel for=\'");
    String _appName_22 = this._utils.appName(it);
    _builder.append(_appName_22, "    ");
    _builder.append("_amount\' text=$amountLabel}");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("{formintinput id=\'");
    String _appName_23 = this._utils.appName(it);
    _builder.append(_appName_23, "    ");
    _builder.append("_amount\' dataField=\'amount\' group=\'data\' mandatory=true maxLength=2}");
    _builder.newLineIfNotEmpty();
    _builder.append("</div>");
    _builder.newLine();
    _builder.newLine();
    _builder.append("<div class=\"z-formrow\">");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{gt text=\'Template\' domain=\'module_");
    String _appName_24 = this._utils.appName(it);
    String _formatForDB_11 = this._formattingExtensions.formatForDB(_appName_24);
    _builder.append(_formatForDB_11, "    ");
    _builder.append("\' assign=\'templateLabel\'}");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("{formlabel for=\'");
    String _appName_25 = this._utils.appName(it);
    _builder.append(_appName_25, "    ");
    _builder.append("_template\' text=$templateLabel}");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("{");
    String _appName_26 = this._utils.appName(it);
    String _formatForDB_12 = this._formattingExtensions.formatForDB(_appName_26);
    _builder.append(_formatForDB_12, "    ");
    _builder.append("TemplateSelector assign=\'allTemplates\'}");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("{formdropdownlist id=\'");
    String _appName_27 = this._utils.appName(it);
    _builder.append(_appName_27, "    ");
    _builder.append("_template\' dataField=\'template\' group=\'data\' mandatory=true items=$allTemplates}");
    _builder.newLineIfNotEmpty();
    _builder.append("</div>");
    _builder.newLine();
    _builder.newLine();
    _builder.append("<div id=\"customtemplatearea\" class=\"z-formrow z-hide\">");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{gt text=\'Custom template\' domain=\'module_");
    String _appName_28 = this._utils.appName(it);
    String _formatForDB_13 = this._formattingExtensions.formatForDB(_appName_28);
    _builder.append(_formatForDB_13, "    ");
    _builder.append("\' assign=\'customTemplateLabel\'}");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("{formlabel for=\'");
    String _appName_29 = this._utils.appName(it);
    _builder.append(_appName_29, "    ");
    _builder.append("_customtemplate\' text=$customTemplateLabel}");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("{formtextinput id=\'");
    String _appName_30 = this._utils.appName(it);
    _builder.append(_appName_30, "    ");
    _builder.append("_customtemplate\' dataField=\'customTemplate\' group=\'data\' mandatory=false maxLength=80}");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("<span class=\"z-sub z-formnote\">{gt text=\'Example\' domain=\'module_");
    String _appName_31 = this._utils.appName(it);
    String _formatForDB_14 = this._formattingExtensions.formatForDB(_appName_31);
    _builder.append(_formatForDB_14, "    ");
    _builder.append("\'}: <em>itemlist_[objecttype]_display.tpl</em></span>");
    _builder.newLineIfNotEmpty();
    _builder.append("</div>");
    _builder.newLine();
    _builder.newLine();
    _builder.append("<div class=\"z-formrow z-hide\"");
    _builder.append(">");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{gt text=\'Filter (expert option)\' domain=\'module_");
    String _appName_32 = this._utils.appName(it);
    String _formatForDB_15 = this._formattingExtensions.formatForDB(_appName_32);
    _builder.append(_formatForDB_15, "    ");
    _builder.append("\' assign=\'filterLabel\'}");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("{formlabel for=\'");
    String _appName_33 = this._utils.appName(it);
    _builder.append(_appName_33, "    ");
    _builder.append("_filter\' text=$filterLabel}");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("{formtextinput id=\'");
    String _appName_34 = this._utils.appName(it);
    _builder.append(_appName_34, "    ");
    _builder.append("_filter\' dataField=\'filter\' group=\'data\' mandatory=false maxLength=255}");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("<span class=\"z-sub z-formnote\">({gt text=\'Syntax examples\' domain=\'module_");
    String _appName_35 = this._utils.appName(it);
    String _formatForDB_16 = this._formattingExtensions.formatForDB(_appName_35);
    _builder.append(_formatForDB_16, "    ");
    _builder.append("\'}: <kbd>name:like:foobar</kbd> {gt text=\'or\' domain=\'module_");
    String _appName_36 = this._utils.appName(it);
    String _formatForDB_17 = this._formattingExtensions.formatForDB(_appName_36);
    _builder.append(_formatForDB_17, "    ");
    _builder.append("\'} <kbd>status:ne:3</kbd>)</span>");
    _builder.newLineIfNotEmpty();
    _builder.append("</div>");
    _builder.newLine();
    _builder.newLine();
    _builder.append("{pageaddvar name=\'javascript\' value=\'prototype\'}");
    _builder.newLine();
    _builder.append("<script type=\"text/javascript\">");
    _builder.newLine();
    _builder.append("/* <![CDATA[ */");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("function ");
    String _prefix = this._utils.prefix(it);
    _builder.append(_prefix, "    ");
    _builder.append("ToggleCustomTemplate() {");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("if ($F(\'");
    String _appName_37 = this._utils.appName(it);
    _builder.append(_appName_37, "        ");
    _builder.append("_template\') == \'custom\') {");
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    _builder.append("$(\'customtemplatearea\').removeClassName(\'z-hide\');");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("} else {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$(\'customtemplatearea\').addClassName(\'z-hide\');");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("document.observe(\'dom:loaded\', function() {");
    _builder.newLine();
    _builder.append("        ");
    String _prefix_1 = this._utils.prefix(it);
    _builder.append(_prefix_1, "        ");
    _builder.append("ToggleCustomTemplate();");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("$(\'");
    String _appName_38 = this._utils.appName(it);
    _builder.append(_appName_38, "        ");
    _builder.append("_template\').observe(\'change\', function(e) {");
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    String _prefix_2 = this._utils.prefix(it);
    _builder.append(_prefix_2, "            ");
    _builder.append("ToggleCustomTemplate();");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("});");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("});");
    _builder.newLine();
    _builder.append("/* ]]> */");
    _builder.newLine();
    _builder.append("</script>");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence detailLink(final Entity it, final String appName) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("<a href=\"{modurl modname=\'");
    _builder.append(appName, "");
    _builder.append("\' type=\'user\' ");
    String _name = it.getName();
    String _formatForCode = this._formattingExtensions.formatForCode(_name);
    String _modUrlDisplayWithFreeOt = this._urlExtensions.modUrlDisplayWithFreeOt(it, _formatForCode, Boolean.valueOf(true), "$objectType");
    _builder.append(_modUrlDisplayWithFreeOt, "");
    _builder.append("}\">{gt text=\'Read more\'}</a>");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
}
