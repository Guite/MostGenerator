package org.zikula.modulestudio.generator.cartridges.zclassic.models.entity;

import com.google.common.base.Objects;
import de.guite.modulestudio.metamodel.AbstractDateField;
import de.guite.modulestudio.metamodel.AbstractIntegerField;
import de.guite.modulestudio.metamodel.AbstractStringField;
import de.guite.modulestudio.metamodel.ArrayField;
import de.guite.modulestudio.metamodel.BooleanField;
import de.guite.modulestudio.metamodel.DataObject;
import de.guite.modulestudio.metamodel.DatetimeField;
import de.guite.modulestudio.metamodel.DecimalField;
import de.guite.modulestudio.metamodel.DerivedField;
import de.guite.modulestudio.metamodel.EmailField;
import de.guite.modulestudio.metamodel.Entity;
import de.guite.modulestudio.metamodel.EntityField;
import de.guite.modulestudio.metamodel.EntityIdentifierStrategy;
import de.guite.modulestudio.metamodel.FloatField;
import de.guite.modulestudio.metamodel.IntegerField;
import de.guite.modulestudio.metamodel.ListField;
import de.guite.modulestudio.metamodel.ObjectField;
import de.guite.modulestudio.metamodel.StringField;
import de.guite.modulestudio.metamodel.TextField;
import de.guite.modulestudio.metamodel.UploadField;
import de.guite.modulestudio.metamodel.UrlField;
import de.guite.modulestudio.metamodel.UserField;
import java.util.Arrays;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.xbase.lib.Extension;
import org.zikula.modulestudio.generator.cartridges.zclassic.models.business.ValidationConstraints;
import org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.ExtensionManager;
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions;

@SuppressWarnings("all")
public class Property {
  @Extension
  private FormattingExtensions _formattingExtensions = new FormattingExtensions();
  
  @Extension
  private ModelExtensions _modelExtensions = new ModelExtensions();
  
  @Extension
  private ModelJoinExtensions _modelJoinExtensions = new ModelJoinExtensions();
  
  private FileHelper fh = new FileHelper();
  
  private ExtensionManager extMan;
  
  private ValidationConstraints thVal = new ValidationConstraints();
  
  public Property(final ExtensionManager extMan) {
    this.extMan = extMan;
  }
  
  protected CharSequence _persistentProperty(final DerivedField it) {
    return this.persistentProperty(it, this._formattingExtensions.formatForCode(it.getName()), this._modelExtensions.fieldTypeAsString(it), "");
  }
  
  protected CharSequence _persistentProperty(final UploadField it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* ");
    String _formatForDisplayCapital = this._formattingExtensions.formatForDisplayCapital(it.getName());
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
    _builder.append("* @Assert\\Type(type=\"array\")");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @var array $");
    String _formatForCode = this._formattingExtensions.formatForCode(it.getName());
    _builder.append(_formatForCode, " ");
    _builder.append("Meta");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected $");
    String _formatForCode_1 = this._formattingExtensions.formatForCode(it.getName());
    _builder.append(_formatForCode_1);
    _builder.append("Meta = [];");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    CharSequence _persistentProperty = this.persistentProperty(it, this._formattingExtensions.formatForCode(it.getName()), this._modelExtensions.fieldTypeAsString(it), "");
    _builder.append(_persistentProperty);
    _builder.newLineIfNotEmpty();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Full ");
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(it.getName());
    _builder.append(_formatForDisplay, " ");
    _builder.append(" path as url.");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @Assert\\Type(type=\"string\")");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @var string $");
    String _formatForCode_2 = this._formattingExtensions.formatForCode(it.getName());
    _builder.append(_formatForCode_2, " ");
    _builder.append("Url");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected $");
    String _formatForCode_3 = this._formattingExtensions.formatForCode(it.getName());
    _builder.append(_formatForCode_3);
    _builder.append("Url = \'\';");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    return _builder;
  }
  
  protected CharSequence _persistentProperty(final ArrayField it) {
    return this.persistentProperty(it, this._formattingExtensions.formatForCode(it.getName()), this._modelExtensions.fieldTypeAsString(it), " = []");
  }
  
  /**
   * Note we use protected and not private to let the dev change things in
   * concrete implementations
   */
  public CharSequence persistentProperty(final DerivedField it, final String name, final String type, final String init) {
    return this.persistentProperty(it, name, type, init, "protected");
  }
  
  public CharSequence persistentProperty(final DerivedField it, final String name, final String type, final String init, final String modifier) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    {
      if (((null != it.getDocumentation()) && (!Objects.equal(it.getDocumentation(), "")))) {
        _builder.append(" ");
        _builder.append("* ");
        String _documentation = it.getDocumentation();
        _builder.append(_documentation, " ");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      boolean _isPrimaryKey = it.isPrimaryKey();
      if (_isPrimaryKey) {
        {
          boolean _hasCompositeKeys = this._modelExtensions.hasCompositeKeys(it.getEntity());
          boolean _not = (!_hasCompositeKeys);
          if (_not) {
            _builder.append(" ");
            _builder.append("* @ORM\\Id");
            _builder.newLine();
            {
              if (((it.getEntity() instanceof Entity) && (!Objects.equal(((Entity) it.getEntity()).getIdentifierStrategy(), EntityIdentifierStrategy.NONE)))) {
                _builder.append(" ");
                _builder.append("* @ORM\\GeneratedValue(strategy=\"");
                DataObject _entity = it.getEntity();
                String _literal = ((Entity) _entity).getIdentifierStrategy().getLiteral();
                _builder.append(_literal, " ");
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
    CharSequence _columnAnnotations = this.extMan.columnAnnotations(it);
    _builder.append(_columnAnnotations);
    _builder.newLineIfNotEmpty();
    {
      if ((!(it instanceof UserField))) {
        _builder.append(" ");
        _builder.append("* @ORM\\Column(");
        {
          if (((null != it.getDbName()) && (!Objects.equal(it.getDbName(), "")))) {
            _builder.append("name=\"");
            String _formatForCode = this._formattingExtensions.formatForCode(it.getDbName());
            _builder.append(_formatForCode, " ");
            _builder.append("\", ");
          }
        }
        CharSequence _persistentPropertyImpl = this.persistentPropertyImpl(it, type.toLowerCase());
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
      }
    }
    CharSequence _persistentPropertyAdditions = this.persistentPropertyAdditions(it);
    _builder.append(_persistentPropertyAdditions);
    _builder.newLineIfNotEmpty();
    CharSequence _fieldAnnotations = this.thVal.fieldAnnotations(it);
    _builder.append(_fieldAnnotations);
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("* @var ");
    {
      if ((Objects.equal(type, "bigint") || Objects.equal(type, "smallint"))) {
        _builder.append("integer");
      } else {
        boolean _equals = Objects.equal(type, "datetime");
        if (_equals) {
          _builder.append("\\DateTime");
        } else {
          _builder.append(type, " ");
        }
      }
    }
    _builder.append(" $");
    String _formatForCode_1 = this._formattingExtensions.formatForCode(name);
    _builder.append(_formatForCode_1, " ");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append(modifier);
    _builder.append(" $");
    String _formatForCode_2 = this._formattingExtensions.formatForCode(name);
    _builder.append(_formatForCode_2);
    {
      boolean _notEquals = (!Objects.equal(init, ""));
      if (_notEquals) {
        _builder.append(init);
      } else {
        {
          if ((!(it instanceof AbstractDateField))) {
            _builder.append(" = ");
            String _defaultFieldData = this.defaultFieldData(it);
            _builder.append(_defaultFieldData);
          }
        }
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
    if (it instanceof DecimalField) {
      _matched=true;
      StringConcatenation _builder = new StringConcatenation();
      _builder.append("type=\"");
      _builder.append(type);
      _builder.append("\", precision=");
      int _length = ((DecimalField)it).getLength();
      _builder.append(_length);
      _builder.append(", scale=");
      int _scale = ((DecimalField)it).getScale();
      _builder.append(_scale);
      _switchResult = _builder;
    }
    if (!_matched) {
      if (it instanceof TextField) {
        _matched=true;
        StringConcatenation _builder = new StringConcatenation();
        _builder.append("type=\"");
        _builder.append(type);
        _builder.append("\", length=");
        int _length = ((TextField)it).getLength();
        _builder.append(_length);
        _switchResult = _builder;
      }
    }
    if (!_matched) {
      if (it instanceof StringField) {
        _matched=true;
        StringConcatenation _builder = new StringConcatenation();
        _builder.append("length=");
        int _length = ((StringField)it).getLength();
        _builder.append(_length);
        _switchResult = _builder;
      }
    }
    if (!_matched) {
      if (it instanceof EmailField) {
        _matched=true;
        StringConcatenation _builder = new StringConcatenation();
        _builder.append("length=");
        int _length = ((EmailField)it).getLength();
        _builder.append(_length);
        _switchResult = _builder;
      }
    }
    if (!_matched) {
      if (it instanceof UrlField) {
        _matched=true;
        StringConcatenation _builder = new StringConcatenation();
        _builder.append("length=");
        int _length = ((UrlField)it).getLength();
        _builder.append(_length);
        _switchResult = _builder;
      }
    }
    if (!_matched) {
      if (it instanceof ArrayField) {
        _matched=true;
        StringConcatenation _builder = new StringConcatenation();
        _builder.append("type=\"");
        String _lowerCase = ((ArrayField)it).getArrayType().getLiteral().toLowerCase();
        _builder.append(_lowerCase);
        _builder.append("\"");
        _switchResult = _builder;
      }
    }
    if (!_matched) {
      if (it instanceof UploadField) {
        _matched=true;
        StringConcatenation _builder = new StringConcatenation();
        _builder.append("length=");
        int _length = ((UploadField)it).getLength();
        _builder.append(_length);
        _switchResult = _builder;
      }
    }
    if (!_matched) {
      if (it instanceof ListField) {
        _matched=true;
        StringConcatenation _builder = new StringConcatenation();
        _builder.append("length=");
        int _length = ((ListField)it).getLength();
        _builder.append(_length);
        _switchResult = _builder;
      }
    }
    if (!_matched) {
      if (it instanceof DatetimeField) {
        _matched=true;
        StringConcatenation _builder = new StringConcatenation();
        _builder.append("type=\"");
        _builder.append(type);
        _builder.append("\"");
        _switchResult = _builder;
      }
    }
    if (!_matched) {
      StringConcatenation _builder = new StringConcatenation();
      _builder.append("type=\"");
      _builder.append(type);
      _builder.append("\"");
      _switchResult = _builder;
    }
    return _switchResult;
  }
  
  private CharSequence persistentPropertyAdditions(final DerivedField it) {
    CharSequence _switchResult = null;
    boolean _matched = false;
    if (it instanceof IntegerField) {
      _matched=true;
      CharSequence _xifexpression = null;
      if (((((IntegerField)it).isVersion() && (((IntegerField)it).getEntity() instanceof Entity)) && this._modelExtensions.hasOptimisticLock(((Entity) ((IntegerField)it).getEntity())))) {
        StringConcatenation _builder = new StringConcatenation();
        _builder.append(" * @ORM\\Version");
        _builder.newLineIfNotEmpty();
        _xifexpression = _builder;
      }
      _switchResult = _xifexpression;
    }
    if (!_matched) {
      if (it instanceof UserField) {
        _matched=true;
        StringConcatenation _builder = new StringConcatenation();
        _builder.append(" ");
        _builder.append("* @ORM\\ManyToOne(targetEntity=\"Zikula\\UsersModule\\Entity\\UserEntity\")");
        _builder.newLineIfNotEmpty();
        _builder.append(" ");
        _builder.append("* @ORM\\JoinColumn(referencedColumnName=\"uid\")");
        _builder.newLineIfNotEmpty();
        _switchResult = _builder;
      }
    }
    if (!_matched) {
      if (it instanceof DatetimeField) {
        _matched=true;
        CharSequence _xifexpression = null;
        if (((((DatetimeField)it).isVersion() && (((DatetimeField)it).getEntity() instanceof Entity)) && this._modelExtensions.hasOptimisticLock(((Entity) ((DatetimeField)it).getEntity())))) {
          StringConcatenation _builder = new StringConcatenation();
          _builder.append(" * @ORM\\Version");
          _builder.newLineIfNotEmpty();
          _xifexpression = _builder;
        }
        _switchResult = _xifexpression;
      }
    }
    return _switchResult;
  }
  
  public String defaultFieldData(final EntityField it) {
    String _switchResult = null;
    boolean _matched = false;
    if (it instanceof BooleanField) {
      _matched=true;
      String _xifexpression = null;
      String _defaultValue = ((BooleanField)it).getDefaultValue();
      boolean _equals = Objects.equal(_defaultValue, "true");
      if (_equals) {
        _xifexpression = "true";
      } else {
        _xifexpression = "false";
      }
      _switchResult = _xifexpression;
    }
    if (!_matched) {
      if (it instanceof AbstractIntegerField) {
        _matched=true;
        String _xifexpression = null;
        if (((it instanceof IntegerField) && ((IntegerField) it).isVersion())) {
          _xifexpression = "1";
        } else {
          String _xifexpression_1 = null;
          if (((null != ((AbstractIntegerField)it).getDefaultValue()) && (((AbstractIntegerField)it).getDefaultValue().length() > 0))) {
            _xifexpression_1 = ((AbstractIntegerField)it).getDefaultValue();
          } else {
            String _xifexpression_2 = null;
            if ((it instanceof UserField)) {
              _xifexpression_2 = "null";
            } else {
              _xifexpression_2 = "0";
            }
            _xifexpression_1 = _xifexpression_2;
          }
          _xifexpression = _xifexpression_1;
        }
        _switchResult = _xifexpression;
      }
    }
    if (!_matched) {
      if (it instanceof DecimalField) {
        _matched=true;
        String _xifexpression = null;
        if (((null != ((DecimalField)it).getDefaultValue()) && (((DecimalField)it).getDefaultValue().length() > 0))) {
          _xifexpression = ((DecimalField)it).getDefaultValue();
        } else {
          _xifexpression = "0.00";
        }
        _switchResult = _xifexpression;
      }
    }
    if (!_matched) {
      if (it instanceof ArrayField) {
        _matched=true;
        _switchResult = "[]";
      }
    }
    if (!_matched) {
      if (it instanceof UploadField) {
        _matched=true;
        _switchResult = "null";
      }
    }
    if (!_matched) {
      if (it instanceof ObjectField) {
        _matched=true;
        _switchResult = "null";
      }
    }
    if (!_matched) {
      if (it instanceof ListField) {
        _matched=true;
        String _xifexpression = null;
        if (((null != ((ListField)it).getDefaultValue()) && (((ListField)it).getDefaultValue().length() > 0))) {
          String _defaultValue = ((ListField)it).getDefaultValue();
          String _plus = ("\'" + _defaultValue);
          _xifexpression = (_plus + "\'");
        } else {
          String _xifexpression_1 = null;
          boolean _isNullable = ((ListField)it).isNullable();
          if (_isNullable) {
            _xifexpression_1 = "null";
          } else {
            _xifexpression_1 = "\'\'";
          }
          _xifexpression = _xifexpression_1;
        }
        _switchResult = _xifexpression;
      }
    }
    if (!_matched) {
      if (it instanceof AbstractStringField) {
        _matched=true;
        String _xifexpression = null;
        if (((null != ((AbstractStringField)it).getDefaultValue()) && (((AbstractStringField)it).getDefaultValue().length() > 0))) {
          String _defaultValue = ((AbstractStringField)it).getDefaultValue();
          String _plus = ("\'" + _defaultValue);
          _xifexpression = (_plus + "\'");
        } else {
          _xifexpression = "\'\'";
        }
        _switchResult = _xifexpression;
      }
    }
    if (!_matched) {
      if (it instanceof FloatField) {
        _matched=true;
        String _xifexpression = null;
        if (((null != ((FloatField)it).getDefaultValue()) && (((FloatField)it).getDefaultValue().length() > 0))) {
          _xifexpression = ((FloatField)it).getDefaultValue();
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
  
  private CharSequence fieldAccessorDefault(final DerivedField it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _isIndexByField = this._modelJoinExtensions.isIndexByField(it);
      if (_isIndexByField) {
        CharSequence _terMethod = this.fh.getterMethod(it, this._formattingExtensions.formatForCode(it.getName()), this._modelExtensions.fieldTypeAsString(it), Boolean.valueOf(false));
        _builder.append(_terMethod);
        _builder.newLineIfNotEmpty();
      } else {
        CharSequence _terAndSetterMethods = this.fh.getterAndSetterMethods(it, this._formattingExtensions.formatForCode(it.getName()), this._modelExtensions.fieldTypeAsString(it), Boolean.valueOf(false), Boolean.valueOf(it.isNullable()), Boolean.valueOf(false), "", "");
        _builder.append(_terAndSetterMethods);
        _builder.newLineIfNotEmpty();
      }
    }
    return _builder;
  }
  
  protected CharSequence _fieldAccessor(final DerivedField it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _fieldAccessorDefault = this.fieldAccessorDefault(it);
    _builder.append(_fieldAccessorDefault);
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  protected CharSequence _fieldAccessor(final IntegerField it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _isIndexByField = this._modelJoinExtensions.isIndexByField(it);
      if (_isIndexByField) {
        CharSequence _terMethod = this.fh.getterMethod(it, this._formattingExtensions.formatForCode(it.getName()), this._modelExtensions.fieldTypeAsString(it), Boolean.valueOf(false));
        _builder.append(_terMethod);
        _builder.newLineIfNotEmpty();
      } else {
        CharSequence _terAndSetterMethods = this.fh.getterAndSetterMethods(it, this._formattingExtensions.formatForCode(it.getName()), this._modelExtensions.fieldTypeAsString(it), Boolean.valueOf(false), Boolean.valueOf(it.isNullable()), Boolean.valueOf(false), "", "");
        _builder.append(_terAndSetterMethods);
        _builder.newLineIfNotEmpty();
      }
    }
    return _builder;
  }
  
  protected CharSequence _fieldAccessor(final UploadField it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _fieldAccessorDefault = this.fieldAccessorDefault(it);
    _builder.append(_fieldAccessorDefault);
    _builder.newLineIfNotEmpty();
    String _formatForCode = this._formattingExtensions.formatForCode(it.getName());
    String _plus = (_formatForCode + "Url");
    CharSequence _terAndSetterMethods = this.fh.getterAndSetterMethods(it, _plus, "string", Boolean.valueOf(false), Boolean.valueOf(true), Boolean.valueOf(false), "", "");
    _builder.append(_terAndSetterMethods);
    _builder.newLineIfNotEmpty();
    String _formatForCode_1 = this._formattingExtensions.formatForCode(it.getName());
    String _plus_1 = (_formatForCode_1 + "Meta");
    CharSequence _terAndSetterMethods_1 = this.fh.getterAndSetterMethods(it, _plus_1, "array", Boolean.valueOf(true), Boolean.valueOf(true), Boolean.valueOf(true), "[]", "");
    _builder.append(_terAndSetterMethods_1);
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  public CharSequence persistentProperty(final DerivedField it) {
    if (it instanceof UploadField) {
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
