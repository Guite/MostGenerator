package org.zikula.modulestudio.generator.cartridges.zclassic.view.pagecomponents;

import com.google.common.base.Objects;
import com.google.inject.Inject;
import de.guite.modulestudio.metamodel.modulestudio.Application;
import de.guite.modulestudio.metamodel.modulestudio.BooleanField;
import de.guite.modulestudio.metamodel.modulestudio.DateField;
import de.guite.modulestudio.metamodel.modulestudio.DatetimeField;
import de.guite.modulestudio.metamodel.modulestudio.DecimalField;
import de.guite.modulestudio.metamodel.modulestudio.DerivedField;
import de.guite.modulestudio.metamodel.modulestudio.EmailField;
import de.guite.modulestudio.metamodel.modulestudio.Entity;
import de.guite.modulestudio.metamodel.modulestudio.EntityField;
import de.guite.modulestudio.metamodel.modulestudio.FloatField;
import de.guite.modulestudio.metamodel.modulestudio.ListField;
import de.guite.modulestudio.metamodel.modulestudio.Models;
import de.guite.modulestudio.metamodel.modulestudio.StringField;
import de.guite.modulestudio.metamodel.modulestudio.TimeField;
import de.guite.modulestudio.metamodel.modulestudio.UploadField;
import de.guite.modulestudio.metamodel.modulestudio.UrlField;
import de.guite.modulestudio.metamodel.modulestudio.UserField;
import java.util.Arrays;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class SimpleFields {
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
  private Utils _utils = new Function0<Utils>() {
    public Utils apply() {
      Utils _utils = new Utils();
      return _utils;
    }
  }.apply();
  
  protected CharSequence _displayField(final EntityField it, final String objName, final String page) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{$");
    _builder.append(objName, "");
    _builder.append(".");
    String _name = it.getName();
    String _formatForCode = this._formattingExtensions.formatForCode(_name);
    _builder.append(_formatForCode, "");
    {
      boolean _equals = Objects.equal(page, "viewcsv");
      if (_equals) {
        _builder.append("|replace:\"\\\"\":\"\"");
      }
    }
    _builder.append("}");
    return _builder;
  }
  
  protected CharSequence _displayField(final BooleanField it, final String objName, final String page) {
    CharSequence _xifexpression = null;
    boolean _and = false;
    boolean _isAjaxTogglability = it.isAjaxTogglability();
    if (!_isAjaxTogglability) {
      _and = false;
    } else {
      boolean _or = false;
      boolean _equals = Objects.equal(page, "view");
      if (_equals) {
        _or = true;
      } else {
        boolean _equals_1 = Objects.equal(page, "display");
        _or = (_equals || _equals_1);
      }
      _and = (_isAjaxTogglability && _or);
    }
    if (_and) {
      StringConcatenation _builder = new StringConcatenation();
      _builder.append("{assign var=\'itemid\' value=$");
      _builder.append(objName, "");
      _builder.append(".");
      Entity _entity = it.getEntity();
      DerivedField _firstPrimaryKey = this._modelExtensions.getFirstPrimaryKey(_entity);
      String _name = _firstPrimaryKey.getName();
      String _formatForCode = this._formattingExtensions.formatForCode(_name);
      _builder.append(_formatForCode, "");
      _builder.append("}");
      _builder.newLineIfNotEmpty();
      _builder.append("<a id=\"toggle");
      String _name_1 = it.getName();
      String _formatForDB = this._formattingExtensions.formatForDB(_name_1);
      _builder.append(_formatForDB, "");
      _builder.append("{$itemid}\" href=\"javascript:void(0);\" class=\"z-hide\">");
      _builder.newLineIfNotEmpty();
      _builder.append("{if $");
      _builder.append(objName, "");
      _builder.append(".");
      String _name_2 = it.getName();
      String _formatForCode_1 = this._formattingExtensions.formatForCode(_name_2);
      _builder.append(_formatForCode_1, "");
      _builder.append("}");
      _builder.newLineIfNotEmpty();
      _builder.append("    ");
      _builder.append("{icon type=\'ok\' size=\'extrasmall\' __alt=\'Yes\' id=\"yes");
      String _name_3 = it.getName();
      String _formatForDB_1 = this._formattingExtensions.formatForDB(_name_3);
      _builder.append(_formatForDB_1, "    ");
      _builder.append("_`$itemid`\" __title=\'This setting is enabled. Click here to disable it.\'}");
      _builder.newLineIfNotEmpty();
      _builder.append("    ");
      _builder.append("{icon type=\'cancel\' size=\'extrasmall\' __alt=\'No\' id=\"no");
      String _name_4 = it.getName();
      String _formatForDB_2 = this._formattingExtensions.formatForDB(_name_4);
      _builder.append(_formatForDB_2, "    ");
      _builder.append("_`$itemid`\" __title=\'This setting is disabled. Click here to enable it.\' class=\'z-hide\'}");
      _builder.newLineIfNotEmpty();
      _builder.append("{else}");
      _builder.newLine();
      _builder.append("    ");
      _builder.append("{icon type=\'ok\' size=\'extrasmall\' __alt=\'Yes\' id=\"yes");
      String _name_5 = it.getName();
      String _formatForDB_3 = this._formattingExtensions.formatForDB(_name_5);
      _builder.append(_formatForDB_3, "    ");
      _builder.append("_`$itemid`\" __title=\'This setting is enabled. Click here to disable it.\' class=\'z-hide\'}");
      _builder.newLineIfNotEmpty();
      _builder.append("    ");
      _builder.append("{icon type=\'cancel\' size=\'extrasmall\' __alt=\'No\' id=\"no");
      String _name_6 = it.getName();
      String _formatForDB_4 = this._formattingExtensions.formatForDB(_name_6);
      _builder.append(_formatForDB_4, "    ");
      _builder.append("_`$itemid`\" __title=\'This setting is disabled. Click here to enable it.\'}");
      _builder.newLineIfNotEmpty();
      _builder.append("{/if}");
      _builder.newLine();
      _builder.append("</a>");
      _builder.newLine();
      _builder.append("<noscript><div id=\"noscript");
      String _name_7 = it.getName();
      String _formatForDB_5 = this._formattingExtensions.formatForDB(_name_7);
      _builder.append(_formatForDB_5, "");
      _builder.append("{$itemid}\">");
      _builder.newLineIfNotEmpty();
      _builder.append("    ");
      _builder.append("{$");
      _builder.append(objName, "    ");
      _builder.append(".");
      String _name_8 = it.getName();
      String _formatForCode_2 = this._formattingExtensions.formatForCode(_name_8);
      _builder.append(_formatForCode_2, "    ");
      _builder.append("|yesno:true}");
      _builder.newLineIfNotEmpty();
      _builder.append("</div></noscript>");
      _builder.newLine();
      _xifexpression = _builder;
    } else {
      StringConcatenation _builder_1 = new StringConcatenation();
      _builder_1.append("{$");
      _builder_1.append(objName, "");
      _builder_1.append(".");
      String _name_9 = it.getName();
      String _formatForCode_3 = this._formattingExtensions.formatForCode(_name_9);
      _builder_1.append(_formatForCode_3, "");
      _builder_1.append("|yesno:true}");
      _xifexpression = _builder_1;
    }
    return _xifexpression;
  }
  
  protected CharSequence _displayField(final DecimalField it, final String objName, final String page) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{$");
    _builder.append(objName, "");
    _builder.append(".");
    String _name = it.getName();
    String _formatForCode = this._formattingExtensions.formatForCode(_name);
    _builder.append(_formatForCode, "");
    _builder.append("|format");
    {
      boolean _isCurrency = it.isCurrency();
      if (_isCurrency) {
        _builder.append("currency");
      } else {
        _builder.append("number");
      }
    }
    _builder.append("}");
    return _builder;
  }
  
  protected CharSequence _displayField(final FloatField it, final String objName, final String page) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{$");
    _builder.append(objName, "");
    _builder.append(".");
    String _name = it.getName();
    String _formatForCode = this._formattingExtensions.formatForCode(_name);
    _builder.append(_formatForCode, "");
    _builder.append("|format");
    {
      boolean _isCurrency = it.isCurrency();
      if (_isCurrency) {
        _builder.append("currency");
      } else {
        _builder.append("number");
      }
    }
    _builder.append("}");
    return _builder;
  }
  
  protected CharSequence _displayField(final UserField it, final String objName, final String page) {
    CharSequence _xblockexpression = null;
    {
      String _plus = (objName + ".");
      String _name = it.getName();
      String _formatForCode = this._formattingExtensions.formatForCode(_name);
      final String realName = (_plus + _formatForCode);
      CharSequence _xifexpression = null;
      boolean _or = false;
      boolean _equals = Objects.equal(page, "viewcsv");
      if (_equals) {
        _or = true;
      } else {
        boolean _equals_1 = Objects.equal(page, "viewxml");
        _or = (_equals || _equals_1);
      }
      if (_or) {
        StringConcatenation _builder = new StringConcatenation();
        _builder.append("{usergetvar name=\'uname\' uid=$");
        _builder.append(realName, "");
        _builder.append("}");
        _xifexpression = _builder;
      } else {
        StringConcatenation _builder_1 = new StringConcatenation();
        {
          boolean _isMandatory = it.isMandatory();
          boolean _not = (!_isMandatory);
          if (_not) {
            _builder_1.append("{if $");
            _builder_1.append(realName, "");
            _builder_1.append(" gt 0}");
            _builder_1.newLineIfNotEmpty();
          }
        }
        {
          boolean _equals_2 = Objects.equal(page, "display");
          if (_equals_2) {
            _builder_1.append("{if !isset($smarty.get.theme) || $smarty.get.theme ne \'Printer\'}");
            _builder_1.newLine();
          }
        }
        _builder_1.append("    ");
        _builder_1.append("{$");
        _builder_1.append(realName, "    ");
        _builder_1.append("|profilelinkbyuid}");
        _builder_1.newLineIfNotEmpty();
        {
          boolean _equals_3 = Objects.equal(page, "display");
          if (_equals_3) {
            _builder_1.append("{else}");
            _builder_1.newLine();
            _builder_1.append("  ");
            _builder_1.append("{usergetvar name=\'uname\' uid=$");
            _builder_1.append(realName, "  ");
            _builder_1.append("}");
            _builder_1.newLineIfNotEmpty();
            _builder_1.append("{/if}");
            _builder_1.newLine();
          }
        }
        {
          boolean _isMandatory_1 = it.isMandatory();
          boolean _not_1 = (!_isMandatory_1);
          if (_not_1) {
            _builder_1.append("{else}&nbsp;{/if}");
            _builder_1.newLine();
          }
        }
        _xifexpression = _builder_1;
      }
      _xblockexpression = (_xifexpression);
    }
    return _xblockexpression;
  }
  
  protected CharSequence _displayField(final StringField it, final String objName, final String page) {
    CharSequence _xifexpression = null;
    boolean _isPassword = it.isPassword();
    boolean _not = (!_isPassword);
    if (_not) {
      StringConcatenation _builder = new StringConcatenation();
      _builder.append("{$");
      _builder.append(objName, "");
      _builder.append(".");
      String _name = it.getName();
      String _formatForCode = this._formattingExtensions.formatForCode(_name);
      _builder.append(_formatForCode, "");
      {
        boolean _isCountry = it.isCountry();
        if (_isCountry) {
          _builder.append("|");
          Entity _entity = it.getEntity();
          Models _container = _entity.getContainer();
          Application _application = _container.getApplication();
          String _appName = this._utils.appName(_application);
          String _formatForDB = this._formattingExtensions.formatForDB(_appName);
          _builder.append(_formatForDB, "");
          _builder.append("GetCountryName|safetext");
        } else {
          boolean _isLanguage = it.isLanguage();
          if (_isLanguage) {
            _builder.append("|getlanguagename|safetext");
          }
        }
      }
      {
        boolean _equals = Objects.equal(page, "viewcsv");
        if (_equals) {
          _builder.append("|replace:\"\\\"\":\"\"");
        }
      }
      _builder.append("}");
      _xifexpression = _builder;
    }
    return _xifexpression;
  }
  
  protected CharSequence _displayField(final EmailField it, final String objName, final String page) {
    CharSequence _xblockexpression = null;
    {
      String _plus = (objName + ".");
      String _name = it.getName();
      String _formatForCode = this._formattingExtensions.formatForCode(_name);
      final String realName = (_plus + _formatForCode);
      CharSequence _xifexpression = null;
      boolean _or = false;
      boolean _equals = Objects.equal(page, "viewcsv");
      if (_equals) {
        _or = true;
      } else {
        boolean _equals_1 = Objects.equal(page, "viewxml");
        _or = (_equals || _equals_1);
      }
      if (_or) {
        StringConcatenation _builder = new StringConcatenation();
        _builder.append("{$");
        _builder.append(realName, "");
        _builder.append("}");
        _xifexpression = _builder;
      } else {
        StringConcatenation _builder_1 = new StringConcatenation();
        {
          boolean _isMandatory = it.isMandatory();
          boolean _not = (!_isMandatory);
          if (_not) {
            _builder_1.append("{if $");
            _builder_1.append(realName, "");
            _builder_1.append(" ne \'\'}");
            _builder_1.newLineIfNotEmpty();
          }
        }
        {
          boolean _equals_2 = Objects.equal(page, "display");
          if (_equals_2) {
            _builder_1.append("{if !isset($smarty.get.theme) || $smarty.get.theme ne \'Printer\'}");
            _builder_1.newLine();
          }
        }
        _builder_1.append("    ");
        _builder_1.append("<a href=\"mailto:{$");
        _builder_1.append(realName, "    ");
        _builder_1.append("}\" title=\"{gt text=\'Send an email\'}\">{icon type=\'mail\' size=\'extrasmall\' __alt=\'Email\'}</a>");
        _builder_1.newLineIfNotEmpty();
        {
          boolean _equals_3 = Objects.equal(page, "display");
          if (_equals_3) {
            _builder_1.append("{else}");
            _builder_1.newLine();
            _builder_1.append("  ");
            _builder_1.append("{$");
            _builder_1.append(realName, "  ");
            _builder_1.append("}");
            _builder_1.newLineIfNotEmpty();
            _builder_1.append("{/if}");
            _builder_1.newLine();
          }
        }
        {
          boolean _isMandatory_1 = it.isMandatory();
          boolean _not_1 = (!_isMandatory_1);
          if (_not_1) {
            _builder_1.append("{else}&nbsp;{/if}");
            _builder_1.newLine();
          }
        }
        _xifexpression = _builder_1;
      }
      _xblockexpression = (_xifexpression);
    }
    return _xblockexpression;
  }
  
  protected CharSequence _displayField(final UrlField it, final String objName, final String page) {
    CharSequence _xblockexpression = null;
    {
      String _plus = (objName + ".");
      String _name = it.getName();
      String _formatForCode = this._formattingExtensions.formatForCode(_name);
      final String realName = (_plus + _formatForCode);
      CharSequence _xifexpression = null;
      boolean _or = false;
      boolean _equals = Objects.equal(page, "viewcsv");
      if (_equals) {
        _or = true;
      } else {
        boolean _equals_1 = Objects.equal(page, "viewxml");
        _or = (_equals || _equals_1);
      }
      if (_or) {
        StringConcatenation _builder = new StringConcatenation();
        _builder.append("{$");
        _builder.append(realName, "");
        _builder.append("}");
        _xifexpression = _builder;
      } else {
        StringConcatenation _builder_1 = new StringConcatenation();
        {
          boolean _isMandatory = it.isMandatory();
          boolean _not = (!_isMandatory);
          if (_not) {
            _builder_1.append("{if $");
            _builder_1.append(realName, "");
            _builder_1.append(" ne \'\'}");
            _builder_1.newLineIfNotEmpty();
          }
        }
        {
          boolean _equals_2 = Objects.equal(page, "display");
          if (_equals_2) {
            _builder_1.append("{if !isset($smarty.get.theme) || $smarty.get.theme ne \'Printer\'}");
            _builder_1.newLine();
          }
        }
        _builder_1.append("    ");
        _builder_1.append("<a href=\"{$");
        _builder_1.append(realName, "    ");
        _builder_1.append("}\" title=\"{gt text=\'Visit this page\'}\">{icon type=\'url\' size=\'extrasmall\' __alt=\'Homepage\'}</a>");
        _builder_1.newLineIfNotEmpty();
        {
          boolean _equals_3 = Objects.equal(page, "display");
          if (_equals_3) {
            _builder_1.append("{else}");
            _builder_1.newLine();
            _builder_1.append("  ");
            _builder_1.append("{$");
            _builder_1.append(realName, "  ");
            _builder_1.append("}");
            _builder_1.newLineIfNotEmpty();
            _builder_1.append("{/if}");
            _builder_1.newLine();
          }
        }
        {
          boolean _isMandatory_1 = it.isMandatory();
          boolean _not_1 = (!_isMandatory_1);
          if (_not_1) {
            _builder_1.append("{else}&nbsp;{/if}");
            _builder_1.newLine();
          }
        }
        _xifexpression = _builder_1;
      }
      _xblockexpression = (_xifexpression);
    }
    return _xblockexpression;
  }
  
  protected CharSequence _displayField(final UploadField it, final String objName, final String page) {
    CharSequence _xblockexpression = null;
    {
      Entity _entity = it.getEntity();
      Models _container = _entity.getContainer();
      Application _application = _container.getApplication();
      String _appName = this._utils.appName(_application);
      final String appNameSmall = this._formattingExtensions.formatForDB(_appName);
      String _plus = (objName + ".");
      String _name = it.getName();
      String _formatForCode = this._formattingExtensions.formatForCode(_name);
      final String realName = (_plus + _formatForCode);
      CharSequence _xifexpression = null;
      boolean _equals = Objects.equal(page, "viewcsv");
      if (_equals) {
        StringConcatenation _builder = new StringConcatenation();
        _builder.append("{$");
        _builder.append(realName, "");
        _builder.append("}");
        _xifexpression = _builder;
      } else {
        CharSequence _xifexpression_1 = null;
        boolean _equals_1 = Objects.equal(page, "viewxml");
        if (_equals_1) {
          StringConcatenation _builder_1 = new StringConcatenation();
          _builder_1.append("{if $");
          _builder_1.append(realName, "");
          _builder_1.append(" ne \'\'} extension=\"{$");
          _builder_1.append(realName, "");
          _builder_1.append("Meta.extension}\" size=\"{$");
          _builder_1.append(realName, "");
          _builder_1.append("Meta.size}\" isImage=\"{if $");
          _builder_1.append(realName, "");
          _builder_1.append("Meta.isImage}true{else}false{/if}\"{if $");
          _builder_1.append(realName, "");
          _builder_1.append("Meta.isImage} width=\"{$");
          _builder_1.append(realName, "");
          _builder_1.append("Meta.width}\" height=\"{$");
          _builder_1.append(realName, "");
          _builder_1.append("Meta.height}\" format=\"{$");
          _builder_1.append(realName, "");
          _builder_1.append("Meta.format}\"{/if}{/if}>{$");
          _builder_1.append(realName, "");
          _builder_1.append("}");
          _xifexpression_1 = _builder_1;
        } else {
          StringConcatenation _builder_2 = new StringConcatenation();
          {
            boolean _isMandatory = it.isMandatory();
            boolean _not = (!_isMandatory);
            if (_not) {
              _builder_2.append("{if $");
              _builder_2.append(realName, "");
              _builder_2.append(" ne \'\'}");
              _builder_2.newLineIfNotEmpty();
            }
          }
          _builder_2.append("  ");
          _builder_2.append("<a href=\"{$");
          _builder_2.append(realName, "  ");
          _builder_2.append("FullPathURL}\" title=\"{$");
          _builder_2.append(objName, "  ");
          _builder_2.append(".");
          Entity _entity_1 = it.getEntity();
          DerivedField _leadingField = this._modelExtensions.getLeadingField(_entity_1);
          String _name_1 = _leadingField.getName();
          String _formatForCode_1 = this._formattingExtensions.formatForCode(_name_1);
          _builder_2.append(_formatForCode_1, "  ");
          _builder_2.append("|replace:\"\\\"\":\"\"}\"{if $");
          _builder_2.append(realName, "  ");
          _builder_2.append("Meta.isImage} rel=\"imageviewer[");
          Entity _entity_2 = it.getEntity();
          String _name_2 = _entity_2.getName();
          String _formatForDB = this._formattingExtensions.formatForDB(_name_2);
          _builder_2.append(_formatForDB, "  ");
          _builder_2.append("]\"{/if}>");
          _builder_2.newLineIfNotEmpty();
          _builder_2.append("  ");
          _builder_2.append("{if $");
          _builder_2.append(realName, "  ");
          _builder_2.append("Meta.isImage}");
          _builder_2.newLineIfNotEmpty();
          _builder_2.append("      ");
          _builder_2.append("{thumb image=$");
          _builder_2.append(realName, "      ");
          _builder_2.append("FullPath objectid=\"");
          Entity _entity_3 = it.getEntity();
          String _name_3 = _entity_3.getName();
          String _formatForCode_2 = this._formattingExtensions.formatForCode(_name_3);
          _builder_2.append(_formatForCode_2, "      ");
          {
            Entity _entity_4 = it.getEntity();
            boolean _hasCompositeKeys = this._modelExtensions.hasCompositeKeys(_entity_4);
            if (_hasCompositeKeys) {
              {
                Entity _entity_5 = it.getEntity();
                Iterable<DerivedField> _primaryKeyFields = this._modelExtensions.getPrimaryKeyFields(_entity_5);
                for(final DerivedField pkField : _primaryKeyFields) {
                  _builder_2.append("-`$");
                  _builder_2.append(objName, "      ");
                  _builder_2.append(".");
                  String _name_4 = pkField.getName();
                  String _formatForCode_3 = this._formattingExtensions.formatForCode(_name_4);
                  _builder_2.append(_formatForCode_3, "      ");
                  _builder_2.append("`");
                }
              }
            } else {
              _builder_2.append("-`$");
              _builder_2.append(objName, "      ");
              _builder_2.append(".");
              Entity _entity_6 = it.getEntity();
              Iterable<DerivedField> _primaryKeyFields_1 = this._modelExtensions.getPrimaryKeyFields(_entity_6);
              DerivedField _head = IterableExtensions.<DerivedField>head(_primaryKeyFields_1);
              String _name_5 = _head.getName();
              String _formatForCode_4 = this._formattingExtensions.formatForCode(_name_5);
              _builder_2.append(_formatForCode_4, "      ");
              _builder_2.append("`");
            }
          }
          _builder_2.append("\" preset=$");
          Entity _entity_7 = it.getEntity();
          String _name_6 = _entity_7.getName();
          String _formatForCode_5 = this._formattingExtensions.formatForCode(_name_6);
          _builder_2.append(_formatForCode_5, "      ");
          _builder_2.append("ThumbPreset");
          String _name_7 = it.getName();
          String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(_name_7);
          _builder_2.append(_formatForCodeCapital, "      ");
          _builder_2.append(" tag=true img_alt=$");
          _builder_2.append(objName, "      ");
          _builder_2.append(".");
          Entity _entity_8 = it.getEntity();
          DerivedField _leadingField_1 = this._modelExtensions.getLeadingField(_entity_8);
          String _name_8 = _leadingField_1.getName();
          String _formatForCode_6 = this._formattingExtensions.formatForCode(_name_8);
          _builder_2.append(_formatForCode_6, "      ");
          _builder_2.append("}");
          _builder_2.newLineIfNotEmpty();
          _builder_2.append("  ");
          _builder_2.append("{else}");
          _builder_2.newLine();
          _builder_2.append("      ");
          _builder_2.append("{gt text=\'Download\'} ({$");
          _builder_2.append(realName, "      ");
          _builder_2.append("Meta.size|");
          _builder_2.append(appNameSmall, "      ");
          _builder_2.append("GetFileSize:$");
          _builder_2.append(realName, "      ");
          _builder_2.append("FullPath:false:false})");
          _builder_2.newLineIfNotEmpty();
          _builder_2.append("  ");
          _builder_2.append("{/if}");
          _builder_2.newLine();
          _builder_2.append("  ");
          _builder_2.append("</a>");
          _builder_2.newLine();
          {
            boolean _isMandatory_1 = it.isMandatory();
            boolean _not_1 = (!_isMandatory_1);
            if (_not_1) {
              _builder_2.append("{else}&nbsp;{/if}");
              _builder_2.newLine();
            }
          }
          _xifexpression_1 = _builder_2;
        }
        _xifexpression = _xifexpression_1;
      }
      _xblockexpression = (_xifexpression);
    }
    return _xblockexpression;
  }
  
  protected CharSequence _displayField(final ListField it, final String objName, final String page) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{$");
    _builder.append(objName, "");
    _builder.append(".");
    String _name = it.getName();
    String _formatForCode = this._formattingExtensions.formatForCode(_name);
    _builder.append(_formatForCode, "");
    _builder.append("|");
    Entity _entity = it.getEntity();
    Models _container = _entity.getContainer();
    Application _application = _container.getApplication();
    String _appName = this._utils.appName(_application);
    String _formatForDB = this._formattingExtensions.formatForDB(_appName);
    _builder.append(_formatForDB, "");
    _builder.append("GetListEntry:\'");
    Entity _entity_1 = it.getEntity();
    String _name_1 = _entity_1.getName();
    String _formatForCode_1 = this._formattingExtensions.formatForCode(_name_1);
    _builder.append(_formatForCode_1, "");
    _builder.append("\':\'");
    String _name_2 = it.getName();
    String _formatForCode_2 = this._formattingExtensions.formatForCode(_name_2);
    _builder.append(_formatForCode_2, "");
    _builder.append("\'|safetext");
    {
      boolean _equals = Objects.equal(page, "viewcsv");
      if (_equals) {
        _builder.append("|replace:\"\\\"\":\"\"");
      }
    }
    _builder.append("}");
    return _builder;
  }
  
  protected CharSequence _displayField(final DateField it, final String objName, final String page) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{$");
    _builder.append(objName, "");
    _builder.append(".");
    String _name = it.getName();
    String _formatForCode = this._formattingExtensions.formatForCode(_name);
    _builder.append(_formatForCode, "");
    _builder.append("|dateformat:\'datebrief\'}");
    return _builder;
  }
  
  protected CharSequence _displayField(final DatetimeField it, final String objName, final String page) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{$");
    _builder.append(objName, "");
    _builder.append(".");
    String _name = it.getName();
    String _formatForCode = this._formattingExtensions.formatForCode(_name);
    _builder.append(_formatForCode, "");
    _builder.append("|dateformat:\'datetimebrief\'}");
    return _builder;
  }
  
  protected CharSequence _displayField(final TimeField it, final String objName, final String page) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{$");
    _builder.append(objName, "");
    _builder.append(".");
    String _name = it.getName();
    String _formatForCode = this._formattingExtensions.formatForCode(_name);
    _builder.append(_formatForCode, "");
    _builder.append("|dateformat:\'timebrief\'}");
    return _builder;
  }
  
  public CharSequence displayField(final EntityField it, final String objName, final String page) {
    if (it instanceof EmailField) {
      return _displayField((EmailField)it, objName, page);
    } else if (it instanceof ListField) {
      return _displayField((ListField)it, objName, page);
    } else if (it instanceof StringField) {
      return _displayField((StringField)it, objName, page);
    } else if (it instanceof UploadField) {
      return _displayField((UploadField)it, objName, page);
    } else if (it instanceof UrlField) {
      return _displayField((UrlField)it, objName, page);
    } else if (it instanceof UserField) {
      return _displayField((UserField)it, objName, page);
    } else if (it instanceof DateField) {
      return _displayField((DateField)it, objName, page);
    } else if (it instanceof DatetimeField) {
      return _displayField((DatetimeField)it, objName, page);
    } else if (it instanceof DecimalField) {
      return _displayField((DecimalField)it, objName, page);
    } else if (it instanceof FloatField) {
      return _displayField((FloatField)it, objName, page);
    } else if (it instanceof TimeField) {
      return _displayField((TimeField)it, objName, page);
    } else if (it instanceof BooleanField) {
      return _displayField((BooleanField)it, objName, page);
    } else if (it != null) {
      return _displayField(it, objName, page);
    } else {
      throw new IllegalArgumentException("Unhandled parameter types: " +
        Arrays.<Object>asList(it, objName, page).toString());
    }
  }
}
