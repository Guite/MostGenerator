package org.zikula.modulestudio.generator.cartridges.zclassic.models.entity;

import com.google.common.base.Objects;
import com.google.inject.Inject;
import de.guite.modulestudio.metamodel.modulestudio.AbstractDateField;
import de.guite.modulestudio.metamodel.modulestudio.AbstractIntegerField;
import de.guite.modulestudio.metamodel.modulestudio.AbstractStringField;
import de.guite.modulestudio.metamodel.modulestudio.Application;
import de.guite.modulestudio.metamodel.modulestudio.ArrayField;
import de.guite.modulestudio.metamodel.modulestudio.BooleanField;
import de.guite.modulestudio.metamodel.modulestudio.DatetimeField;
import de.guite.modulestudio.metamodel.modulestudio.DecimalField;
import de.guite.modulestudio.metamodel.modulestudio.DerivedField;
import de.guite.modulestudio.metamodel.modulestudio.EmailField;
import de.guite.modulestudio.metamodel.modulestudio.Entity;
import de.guite.modulestudio.metamodel.modulestudio.EntityField;
import de.guite.modulestudio.metamodel.modulestudio.EntityIdentifierStrategy;
import de.guite.modulestudio.metamodel.modulestudio.FloatField;
import de.guite.modulestudio.metamodel.modulestudio.IntegerField;
import de.guite.modulestudio.metamodel.modulestudio.ListField;
import de.guite.modulestudio.metamodel.modulestudio.ListFieldItem;
import de.guite.modulestudio.metamodel.modulestudio.Models;
import de.guite.modulestudio.metamodel.modulestudio.ObjectField;
import de.guite.modulestudio.metamodel.modulestudio.StringField;
import de.guite.modulestudio.metamodel.modulestudio.TextField;
import de.guite.modulestudio.metamodel.modulestudio.UploadField;
import de.guite.modulestudio.metamodel.modulestudio.UrlField;
import java.util.Arrays;
import org.eclipse.emf.common.util.EList;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.Extensions;
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class Property {
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
  private Utils _utils = new Function0<Utils>() {
    public Utils apply() {
      Utils _utils = new Utils();
      return _utils;
    }
  }.apply();
  
  private FileHelper fh = new Function0<FileHelper>() {
    public FileHelper apply() {
      FileHelper _fileHelper = new FileHelper();
      return _fileHelper;
    }
  }.apply();
  
  protected CharSequence _persistentProperty(final DerivedField it) {
    String _name = it.getName();
    String _formatForCode = this._formattingExtensions.formatForCode(_name);
    String _fieldTypeAsString = this._modelExtensions.fieldTypeAsString(it);
    CharSequence _persistentProperty = this.persistentProperty(it, _formatForCode, _fieldTypeAsString, "");
    return _persistentProperty;
  }
  
  /**
   * Do only use integer (no smallint or bigint) for version fields.
   * This is just a hack for a minor bug in Doctrine 2.1 (fixed in 2.2).
   * After we dropped support for Zikula 1.3.5 the following define for IntegerField
   * can be removed completely as the define for DerivedField can be used then instead.
   */
  protected CharSequence _persistentProperty(final IntegerField it) {
    CharSequence _xifexpression = null;
    boolean _and = false;
    boolean _and_1 = false;
    boolean _isVersion = it.isVersion();
    if (!_isVersion) {
      _and_1 = false;
    } else {
      Entity _entity = it.getEntity();
      boolean _hasOptimisticLock = this._modelExtensions.hasOptimisticLock(_entity);
      _and_1 = (_isVersion && _hasOptimisticLock);
    }
    if (!_and_1) {
      _and = false;
    } else {
      Entity _entity_1 = it.getEntity();
      Models _container = _entity_1.getContainer();
      Application _application = _container.getApplication();
      boolean _targets = this._utils.targets(_application, "1.3.5");
      _and = (_and_1 && _targets);
    }
    if (_and) {
      String _name = it.getName();
      String _formatForCode = this._formattingExtensions.formatForCode(_name);
      CharSequence _persistentProperty = this.persistentProperty(it, _formatForCode, "integer", "");
      _xifexpression = _persistentProperty;
    } else {
      String _name_1 = it.getName();
      String _formatForCode_1 = this._formattingExtensions.formatForCode(_name_1);
      String _fieldTypeAsString = this._modelExtensions.fieldTypeAsString(it);
      CharSequence _persistentProperty_1 = this.persistentProperty(it, _formatForCode_1, _fieldTypeAsString, "");
      _xifexpression = _persistentProperty_1;
    }
    return _xifexpression;
  }
  
  protected CharSequence _persistentProperty(final UploadField it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* ");
    String _name = it.getName();
    String _formatForDisplayCapital = this._formattingExtensions.formatForDisplayCapital(_name);
    _builder.append(_formatForDisplayCapital, " ");
    _builder.append(" meta data array.");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @ORM\\Column(type=\"array\")");
    _builder.newLine();
    {
      boolean _isTranslatable = it.isTranslatable();
      if (_isTranslatable) {
        _builder.append(" ");
        _builder.append("* @Gedmo\\Translatable");
        _builder.newLine();
      }
    }
    _builder.append(" ");
    _builder.append("* @var array $");
    String _name_1 = it.getName();
    String _formatForCode = this._formattingExtensions.formatForCode(_name_1);
    _builder.append(_formatForCode, " ");
    _builder.append("Meta.");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected $");
    String _name_2 = it.getName();
    String _formatForCode_1 = this._formattingExtensions.formatForCode(_name_2);
    _builder.append(_formatForCode_1, "");
    _builder.append("Meta = array();");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    String _name_3 = it.getName();
    String _formatForCode_2 = this._formattingExtensions.formatForCode(_name_3);
    String _fieldTypeAsString = this._modelExtensions.fieldTypeAsString(it);
    CharSequence _persistentProperty = this.persistentProperty(it, _formatForCode_2, _fieldTypeAsString, "");
    _builder.append(_persistentProperty, "");
    _builder.newLineIfNotEmpty();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* The full path to the ");
    String _name_4 = it.getName();
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(_name_4);
    _builder.append(_formatForDisplay, " ");
    _builder.append(".");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @var string $");
    String _name_5 = it.getName();
    String _formatForCode_3 = this._formattingExtensions.formatForCode(_name_5);
    _builder.append(_formatForCode_3, " ");
    _builder.append("FullPath.");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected $");
    String _name_6 = it.getName();
    String _formatForCode_4 = this._formattingExtensions.formatForCode(_name_6);
    _builder.append(_formatForCode_4, "");
    _builder.append("FullPath = \'\';");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Full ");
    String _name_7 = it.getName();
    String _formatForDisplay_1 = this._formattingExtensions.formatForDisplay(_name_7);
    _builder.append(_formatForDisplay_1, " ");
    _builder.append(" path as url.");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @var string $");
    String _name_8 = it.getName();
    String _formatForCode_5 = this._formattingExtensions.formatForCode(_name_8);
    _builder.append(_formatForCode_5, " ");
    _builder.append("FullPathUrl.");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected $");
    String _name_9 = it.getName();
    String _formatForCode_6 = this._formattingExtensions.formatForCode(_name_9);
    _builder.append(_formatForCode_6, "");
    _builder.append("FullPathUrl = \'\';");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  protected CharSequence _persistentProperty(final ArrayField it) {
    String _name = it.getName();
    String _formatForCode = this._formattingExtensions.formatForCode(_name);
    String _fieldTypeAsString = this._modelExtensions.fieldTypeAsString(it);
    CharSequence _persistentProperty = this.persistentProperty(it, _formatForCode, _fieldTypeAsString, " = array()");
    return _persistentProperty;
  }
  
  /**
   * Note we use protected and not private to let the dev change things in
   * concrete implementations
   */
  public CharSequence persistentProperty(final DerivedField it, final String name, final String type, final String init) {
    CharSequence _persistentProperty = this.persistentProperty(it, name, type, init, "protected");
    return _persistentProperty;
  }
  
  public CharSequence persistentProperty(final DerivedField it, final String name, final String type, final String init, final String modifier) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    {
      boolean _isPrimaryKey = it.isPrimaryKey();
      if (_isPrimaryKey) {
        {
          Entity _entity = it.getEntity();
          boolean _hasCompositeKeys = this._modelExtensions.hasCompositeKeys(_entity);
          boolean _not = (!_hasCompositeKeys);
          if (_not) {
            _builder.append(" ");
            _builder.append("* @ORM\\Id");
            _builder.newLine();
            {
              Entity _entity_1 = it.getEntity();
              EntityIdentifierStrategy _identifierStrategy = _entity_1.getIdentifierStrategy();
              boolean _notEquals = (!Objects.equal(_identifierStrategy, EntityIdentifierStrategy.NONE));
              if (_notEquals) {
                _builder.append(" ");
                _builder.append("* @ORM\\GeneratedValue(strategy=\"");
                Entity _entity_2 = it.getEntity();
                EntityIdentifierStrategy _identifierStrategy_1 = _entity_2.getIdentifierStrategy();
                String _asConstant = this._modelExtensions.asConstant(_identifierStrategy_1);
                _builder.append(_asConstant, " ");
                _builder.append("\")");
                _builder.newLineIfNotEmpty();
              }
            }
          } else {
            _builder.append(" ");
            _builder.append("* @ORM\\Id");
            _builder.newLine();
          }
        }
      }
    }
    Extensions _extensions = new Extensions();
    CharSequence _columnExtensions = _extensions.columnExtensions(it);
    _builder.append(_columnExtensions, "");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("* @ORM\\Column(");
    CharSequence _persistentPropertyImpl = this.persistentPropertyImpl(it, type);
    _builder.append(_persistentPropertyImpl, " ");
    {
      boolean _isUnique = it.isUnique();
      if (_isUnique) {
        _builder.append(", unique=true");
      }
    }
    {
      boolean _isNullable = it.isNullable();
      if (_isNullable) {
        _builder.append(", nullable=true");
      }
    }
    _builder.append(")");
    _builder.newLineIfNotEmpty();
    CharSequence _persistentPropertyAdditions = this.persistentPropertyAdditions(it);
    _builder.append(_persistentPropertyAdditions, "");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("* @var ");
    _builder.append(type, " ");
    _builder.append(" $");
    String _formatForCode = this._formattingExtensions.formatForCode(name);
    _builder.append(_formatForCode, " ");
    _builder.append(".");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append(modifier, "");
    _builder.append(" $");
    String _formatForCode_1 = this._formattingExtensions.formatForCode(name);
    _builder.append(_formatForCode_1, "");
    {
      boolean _notEquals_1 = (!Objects.equal(init, ""));
      if (_notEquals_1) {
        _builder.append(init, "");
      } else {
        _builder.append(" = ");
        String _defaultFieldData = this.defaultFieldData(it);
        _builder.append(_defaultFieldData, "");
      }
    }
    _builder.append(";");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence persistentPropertyImpl(final DerivedField it, final String type) {
    CharSequence _switchResult = null;
    boolean _matched = false;
    if (!_matched) {
      if (it instanceof DecimalField) {
        final DecimalField _decimalField = (DecimalField)it;
        _matched=true;
        StringConcatenation _builder = new StringConcatenation();
        _builder.append("type=\"");
        _builder.append(type, "");
        _builder.append("\", precision=");
        int _length = _decimalField.getLength();
        _builder.append(_length, "");
        _builder.append(", scale=");
        int _scale = _decimalField.getScale();
        _builder.append(_scale, "");
        _switchResult = _builder;
      }
    }
    if (!_matched) {
      if (it instanceof TextField) {
        final TextField _textField = (TextField)it;
        _matched=true;
        StringConcatenation _builder = new StringConcatenation();
        _builder.append("type=\"");
        _builder.append(type, "");
        _builder.append("\", length=");
        int _length = _textField.getLength();
        _builder.append(_length, "");
        _switchResult = _builder;
      }
    }
    if (!_matched) {
      if (it instanceof StringField) {
        final StringField _stringField = (StringField)it;
        _matched=true;
        StringConcatenation _builder = new StringConcatenation();
        _builder.append("length=");
        int _length = _stringField.getLength();
        _builder.append(_length, "");
        _switchResult = _builder;
      }
    }
    if (!_matched) {
      if (it instanceof EmailField) {
        final EmailField _emailField = (EmailField)it;
        _matched=true;
        StringConcatenation _builder = new StringConcatenation();
        _builder.append("length=");
        int _length = _emailField.getLength();
        _builder.append(_length, "");
        _switchResult = _builder;
      }
    }
    if (!_matched) {
      if (it instanceof UrlField) {
        final UrlField _urlField = (UrlField)it;
        _matched=true;
        StringConcatenation _builder = new StringConcatenation();
        _builder.append("length=");
        int _length = _urlField.getLength();
        _builder.append(_length, "");
        _switchResult = _builder;
      }
    }
    if (!_matched) {
      if (it instanceof UploadField) {
        final UploadField _uploadField = (UploadField)it;
        _matched=true;
        StringConcatenation _builder = new StringConcatenation();
        _builder.append("length=");
        int _length = _uploadField.getLength();
        _builder.append(_length, "");
        _switchResult = _builder;
      }
    }
    if (!_matched) {
      if (it instanceof ListField) {
        final ListField _listField = (ListField)it;
        _matched=true;
        StringConcatenation _builder = new StringConcatenation();
        _builder.append("length=");
        int _length = _listField.getLength();
        _builder.append(_length, "");
        _switchResult = _builder;
      }
    }
    if (!_matched) {
      StringConcatenation _builder = new StringConcatenation();
      _builder.append("type=\"");
      _builder.append(type, "");
      _builder.append("\"");
      _switchResult = _builder;
    }
    return _switchResult;
  }
  
  private CharSequence persistentPropertyAdditions(final DerivedField it) {
    CharSequence _switchResult = null;
    boolean _matched = false;
    if (!_matched) {
      if (it instanceof IntegerField) {
        final IntegerField _integerField = (IntegerField)it;
        _matched=true;
        CharSequence _xifexpression = null;
        boolean _and = false;
        boolean _isVersion = _integerField.isVersion();
        if (!_isVersion) {
          _and = false;
        } else {
          Entity _entity = _integerField.getEntity();
          boolean _hasOptimisticLock = this._modelExtensions.hasOptimisticLock(_entity);
          _and = (_isVersion && _hasOptimisticLock);
        }
        if (_and) {
          StringConcatenation _builder = new StringConcatenation();
          _builder.append("* @ORM\\Version");
          _builder.newLine();
          _xifexpression = _builder;
        }
        _switchResult = _xifexpression;
      }
    }
    if (!_matched) {
      if (it instanceof DatetimeField) {
        final DatetimeField _datetimeField = (DatetimeField)it;
        _matched=true;
        CharSequence _xifexpression = null;
        boolean _and = false;
        boolean _isVersion = _datetimeField.isVersion();
        if (!_isVersion) {
          _and = false;
        } else {
          Entity _entity = _datetimeField.getEntity();
          boolean _hasOptimisticLock = this._modelExtensions.hasOptimisticLock(_entity);
          _and = (_isVersion && _hasOptimisticLock);
        }
        if (_and) {
          StringConcatenation _builder = new StringConcatenation();
          _builder.append("* @ORM\\Version");
          _builder.newLine();
          _xifexpression = _builder;
        }
        _switchResult = _xifexpression;
      }
    }
    return _switchResult;
  }
  
  private String defaultFieldData(final EntityField it) {
    String _switchResult = null;
    boolean _matched = false;
    if (!_matched) {
      if (it instanceof BooleanField) {
        final BooleanField _booleanField = (BooleanField)it;
        _matched=true;
        String _xifexpression = null;
        boolean _or = false;
        String _defaultValue = _booleanField.getDefaultValue();
        boolean _equals = Objects.equal(_defaultValue, Boolean.valueOf(true));
        if (_equals) {
          _or = true;
        } else {
          String _defaultValue_1 = _booleanField.getDefaultValue();
          boolean _equals_1 = Objects.equal(_defaultValue_1, "true");
          _or = (_equals || _equals_1);
        }
        if (_or) {
          _xifexpression = "true";
        } else {
          _xifexpression = "false";
        }
        _switchResult = _xifexpression;
      }
    }
    if (!_matched) {
      if (it instanceof AbstractIntegerField) {
        final AbstractIntegerField _abstractIntegerField = (AbstractIntegerField)it;
        _matched=true;
        String _xifexpression = null;
        boolean _and = false;
        String _defaultValue = _abstractIntegerField.getDefaultValue();
        boolean _tripleNotEquals = (_defaultValue != null);
        if (!_tripleNotEquals) {
          _and = false;
        } else {
          String _defaultValue_1 = _abstractIntegerField.getDefaultValue();
          int _length = _defaultValue_1.length();
          boolean _greaterThan = (_length > 0);
          _and = (_tripleNotEquals && _greaterThan);
        }
        if (_and) {
          String _defaultValue_2 = _abstractIntegerField.getDefaultValue();
          _xifexpression = _defaultValue_2;
        } else {
          _xifexpression = "0";
        }
        _switchResult = _xifexpression;
      }
    }
    if (!_matched) {
      if (it instanceof DecimalField) {
        final DecimalField _decimalField = (DecimalField)it;
        _matched=true;
        String _xifexpression = null;
        boolean _and = false;
        String _defaultValue = _decimalField.getDefaultValue();
        boolean _tripleNotEquals = (_defaultValue != null);
        if (!_tripleNotEquals) {
          _and = false;
        } else {
          String _defaultValue_1 = _decimalField.getDefaultValue();
          int _length = _defaultValue_1.length();
          boolean _greaterThan = (_length > 0);
          _and = (_tripleNotEquals && _greaterThan);
        }
        if (_and) {
          String _defaultValue_2 = _decimalField.getDefaultValue();
          _xifexpression = _defaultValue_2;
        } else {
          _xifexpression = "0.00";
        }
        _switchResult = _xifexpression;
      }
    }
    if (!_matched) {
      if (it instanceof ArrayField) {
        final ArrayField _arrayField = (ArrayField)it;
        _matched=true;
        _switchResult = "array()";
      }
    }
    if (!_matched) {
      if (it instanceof ObjectField) {
        final ObjectField _objectField = (ObjectField)it;
        _matched=true;
        _switchResult = "null";
      }
    }
    if (!_matched) {
      if (it instanceof ListField) {
        final ListField _listField = (ListField)it;
        _matched=true;
        String _xifexpression = null;
        boolean _and = false;
        String _defaultValue = _listField.getDefaultValue();
        boolean _tripleNotEquals = (_defaultValue != null);
        if (!_tripleNotEquals) {
          _and = false;
        } else {
          String _defaultValue_1 = _listField.getDefaultValue();
          int _length = _defaultValue_1.length();
          boolean _greaterThan = (_length > 0);
          _and = (_tripleNotEquals && _greaterThan);
        }
        if (_and) {
          String _defaultValue_2 = _listField.getDefaultValue();
          String _plus = ("\'" + _defaultValue_2);
          String _plus_1 = (_plus + "\'");
          _xifexpression = _plus_1;
        } else {
          CharSequence _defaultFieldDataItems = this.defaultFieldDataItems(_listField);
          String _plus_2 = ("\'" + _defaultFieldDataItems);
          String _plus_3 = (_plus_2 + "\'");
          _xifexpression = _plus_3;
        }
        _switchResult = _xifexpression;
      }
    }
    if (!_matched) {
      if (it instanceof AbstractStringField) {
        final AbstractStringField _abstractStringField = (AbstractStringField)it;
        _matched=true;
        String _xifexpression = null;
        boolean _and = false;
        String _defaultValue = _abstractStringField.getDefaultValue();
        boolean _tripleNotEquals = (_defaultValue != null);
        if (!_tripleNotEquals) {
          _and = false;
        } else {
          String _defaultValue_1 = _abstractStringField.getDefaultValue();
          int _length = _defaultValue_1.length();
          boolean _greaterThan = (_length > 0);
          _and = (_tripleNotEquals && _greaterThan);
        }
        if (_and) {
          String _defaultValue_2 = _abstractStringField.getDefaultValue();
          String _plus = ("\'" + _defaultValue_2);
          String _plus_1 = (_plus + "\'");
          _xifexpression = _plus_1;
        } else {
          _xifexpression = "\'\'";
        }
        _switchResult = _xifexpression;
      }
    }
    if (!_matched) {
      if (it instanceof AbstractDateField) {
        final AbstractDateField _abstractDateField = (AbstractDateField)it;
        _matched=true;
        String _xifexpression = null;
        boolean _and = false;
        boolean _and_1 = false;
        boolean _and_2 = false;
        boolean _isMandatory = _abstractDateField.isMandatory();
        if (!_isMandatory) {
          _and_2 = false;
        } else {
          String _defaultValue = _abstractDateField.getDefaultValue();
          boolean _tripleNotEquals = (_defaultValue != null);
          _and_2 = (_isMandatory && _tripleNotEquals);
        }
        if (!_and_2) {
          _and_1 = false;
        } else {
          String _defaultValue_1 = _abstractDateField.getDefaultValue();
          int _length = _defaultValue_1.length();
          boolean _greaterThan = (_length > 0);
          _and_1 = (_and_2 && _greaterThan);
        }
        if (!_and_1) {
          _and = false;
        } else {
          String _defaultValue_2 = _abstractDateField.getDefaultValue();
          boolean _notEquals = (!Objects.equal(_defaultValue_2, "now"));
          _and = (_and_1 && _notEquals);
        }
        if (_and) {
          String _defaultValue_3 = _abstractDateField.getDefaultValue();
          String _plus = ("\'" + _defaultValue_3);
          String _plus_1 = (_plus + "\'");
          _xifexpression = _plus_1;
        } else {
          _xifexpression = "null";
        }
        _switchResult = _xifexpression;
      }
    }
    if (!_matched) {
      if (it instanceof FloatField) {
        final FloatField _floatField = (FloatField)it;
        _matched=true;
        String _xifexpression = null;
        boolean _and = false;
        String _defaultValue = _floatField.getDefaultValue();
        boolean _tripleNotEquals = (_defaultValue != null);
        if (!_tripleNotEquals) {
          _and = false;
        } else {
          String _defaultValue_1 = _floatField.getDefaultValue();
          int _length = _defaultValue_1.length();
          boolean _greaterThan = (_length > 0);
          _and = (_tripleNotEquals && _greaterThan);
        }
        if (_and) {
          String _defaultValue_2 = _floatField.getDefaultValue();
          _xifexpression = _defaultValue_2;
        } else {
          _xifexpression = "0";
        }
        _switchResult = _xifexpression;
      }
    }
    if (!_matched) {
      _switchResult = "\'\'";
    }
    return _switchResult;
  }
  
  private CharSequence defaultFieldDataItems(final ListField it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      EList<ListFieldItem> _items = it.getItems();
      final Function1<ListFieldItem,Boolean> _function = new Function1<ListFieldItem,Boolean>() {
          public Boolean apply(final ListFieldItem e) {
            boolean _isDefault = e.isDefault();
            return Boolean.valueOf(_isDefault);
          }
        };
      Iterable<ListFieldItem> _filter = IterableExtensions.<ListFieldItem>filter(_items, _function);
      boolean _hasElements = false;
      for(final ListFieldItem defaultItem : _filter) {
        if (!_hasElements) {
          _hasElements = true;
        } else {
          _builder.appendImmediate("###", "");
        }
        String _value = defaultItem.getValue();
        _builder.append(_value, "");
      }
    }
    return _builder;
  }
  
  private CharSequence fieldAccessorDefault(final DerivedField it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _isIndexByField = this._modelJoinExtensions.isIndexByField(it);
      if (_isIndexByField) {
        String _name = it.getName();
        String _formatForCode = this._formattingExtensions.formatForCode(_name);
        String _fieldTypeAsString = this._modelExtensions.fieldTypeAsString(it);
        CharSequence _terMethod = this.fh.getterMethod(it, _formatForCode, _fieldTypeAsString, Boolean.valueOf(false));
        _builder.append(_terMethod, "");
        _builder.newLineIfNotEmpty();
      } else {
        String _name_1 = it.getName();
        String _formatForCode_1 = this._formattingExtensions.formatForCode(_name_1);
        String _fieldTypeAsString_1 = this._modelExtensions.fieldTypeAsString(it);
        CharSequence _terAndSetterMethods = this.fh.getterAndSetterMethods(it, _formatForCode_1, _fieldTypeAsString_1, Boolean.valueOf(false), Boolean.valueOf(false), "", "");
        _builder.append(_terAndSetterMethods, "");
        _builder.newLineIfNotEmpty();
      }
    }
    return _builder;
  }
  
  protected CharSequence _fieldAccessor(final DerivedField it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _fieldAccessorDefault = this.fieldAccessorDefault(it);
    _builder.append(_fieldAccessorDefault, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  protected CharSequence _fieldAccessor(final IntegerField it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _isIndexByField = this._modelJoinExtensions.isIndexByField(it);
      if (_isIndexByField) {
        String _name = it.getName();
        String _formatForCode = this._formattingExtensions.formatForCode(_name);
        String _fieldTypeAsString = this._modelExtensions.fieldTypeAsString(it);
        CharSequence _terMethod = this.fh.getterMethod(it, _formatForCode, _fieldTypeAsString, Boolean.valueOf(false));
        _builder.append(_terMethod, "");
        _builder.newLineIfNotEmpty();
      } else {
        String _name_1 = it.getName();
        String _formatForCode_1 = this._formattingExtensions.formatForCode(_name_1);
        String _fieldTypeAsString_1 = this._modelExtensions.fieldTypeAsString(it);
        CharSequence _terAndSetterMethods = this.fh.getterAndSetterMethods(it, _formatForCode_1, _fieldTypeAsString_1, Boolean.valueOf(false), Boolean.valueOf(false), "", "");
        _builder.append(_terAndSetterMethods, "");
        _builder.newLineIfNotEmpty();
      }
    }
    return _builder;
  }
  
  protected CharSequence _fieldAccessor(final UploadField it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _fieldAccessorDefault = this.fieldAccessorDefault(it);
    _builder.append(_fieldAccessorDefault, "");
    _builder.newLineIfNotEmpty();
    String _name = it.getName();
    String _formatForCode = this._formattingExtensions.formatForCode(_name);
    String _plus = (_formatForCode + "FullPath");
    CharSequence _terAndSetterMethods = this.fh.getterAndSetterMethods(it, _plus, "string", Boolean.valueOf(false), Boolean.valueOf(false), "", "");
    _builder.append(_terAndSetterMethods, "");
    _builder.newLineIfNotEmpty();
    String _name_1 = it.getName();
    String _formatForCode_1 = this._formattingExtensions.formatForCode(_name_1);
    String _plus_1 = (_formatForCode_1 + "FullPathUrl");
    CharSequence _terAndSetterMethods_1 = this.fh.getterAndSetterMethods(it, _plus_1, "string", Boolean.valueOf(false), Boolean.valueOf(false), "", "");
    _builder.append(_terAndSetterMethods_1, "");
    _builder.newLineIfNotEmpty();
    String _name_2 = it.getName();
    String _formatForCode_2 = this._formattingExtensions.formatForCode(_name_2);
    String _plus_2 = (_formatForCode_2 + "Meta");
    CharSequence _terAndSetterMethods_2 = this.fh.getterAndSetterMethods(it, _plus_2, "array", Boolean.valueOf(true), Boolean.valueOf(false), "Array()", "");
    _builder.append(_terAndSetterMethods_2, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  public CharSequence persistentProperty(final DerivedField it) {
    if (it instanceof IntegerField) {
      return _persistentProperty((IntegerField)it);
    } else if (it instanceof UploadField) {
      return _persistentProperty((UploadField)it);
    } else if (it instanceof ArrayField) {
      return _persistentProperty((ArrayField)it);
    } else if (it != null) {
      return _persistentProperty(it);
    } else {
      throw new IllegalArgumentException("Unhandled parameter types: " +
        Arrays.<Object>asList(it).toString());
    }
  }
  
  public CharSequence fieldAccessor(final DerivedField it) {
    if (it instanceof IntegerField) {
      return _fieldAccessor((IntegerField)it);
    } else if (it instanceof UploadField) {
      return _fieldAccessor((UploadField)it);
    } else if (it != null) {
      return _fieldAccessor(it);
    } else {
      throw new IllegalArgumentException("Unhandled parameter types: " +
        Arrays.<Object>asList(it).toString());
    }
  }
}
