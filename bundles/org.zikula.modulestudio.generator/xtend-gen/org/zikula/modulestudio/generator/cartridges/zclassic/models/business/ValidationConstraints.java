package org.zikula.modulestudio.generator.cartridges.zclassic.models.business;

import com.google.common.base.Objects;
import com.google.common.collect.Iterables;
import de.guite.modulestudio.metamodel.AbstractDateField;
import de.guite.modulestudio.metamodel.AbstractIntegerField;
import de.guite.modulestudio.metamodel.AbstractStringField;
import de.guite.modulestudio.metamodel.ArrayField;
import de.guite.modulestudio.metamodel.BooleanField;
import de.guite.modulestudio.metamodel.DataObject;
import de.guite.modulestudio.metamodel.DateField;
import de.guite.modulestudio.metamodel.DatetimeField;
import de.guite.modulestudio.metamodel.DecimalField;
import de.guite.modulestudio.metamodel.DerivedField;
import de.guite.modulestudio.metamodel.EmailField;
import de.guite.modulestudio.metamodel.Entity;
import de.guite.modulestudio.metamodel.EntityIndex;
import de.guite.modulestudio.metamodel.EntityIndexItem;
import de.guite.modulestudio.metamodel.FloatField;
import de.guite.modulestudio.metamodel.IntegerField;
import de.guite.modulestudio.metamodel.IpAddressScope;
import de.guite.modulestudio.metamodel.JoinRelationship;
import de.guite.modulestudio.metamodel.ListField;
import de.guite.modulestudio.metamodel.ObjectField;
import de.guite.modulestudio.metamodel.StringField;
import de.guite.modulestudio.metamodel.StringIsbnStyle;
import de.guite.modulestudio.metamodel.StringIssnStyle;
import de.guite.modulestudio.metamodel.TextField;
import de.guite.modulestudio.metamodel.TimeField;
import de.guite.modulestudio.metamodel.UploadField;
import de.guite.modulestudio.metamodel.UrlField;
import de.guite.modulestudio.metamodel.UserField;
import java.math.BigInteger;
import java.util.ArrayList;
import java.util.Arrays;
import org.eclipse.emf.common.util.EList;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.xbase.lib.CollectionLiterals;
import org.eclipse.xtext.xbase.lib.Conversions;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.eclipse.xtext.xbase.lib.StringExtensions;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class ValidationConstraints {
  @Extension
  private FormattingExtensions _formattingExtensions = new FormattingExtensions();
  
  @Extension
  private ModelExtensions _modelExtensions = new ModelExtensions();
  
  @Extension
  private ModelBehaviourExtensions _modelBehaviourExtensions = new ModelBehaviourExtensions();
  
  @Extension
  private ModelJoinExtensions _modelJoinExtensions = new ModelJoinExtensions();
  
  @Extension
  private NamingExtensions _namingExtensions = new NamingExtensions();
  
  @Extension
  private Utils _utils = new Utils();
  
  protected CharSequence _fieldAnnotations(final DerivedField it) {
    return null;
  }
  
  private CharSequence fieldAnnotationsMandatory(final DerivedField it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _isMandatory = it.isMandatory();
      if (_isMandatory) {
        _builder.append(" ");
        _builder.append("* @Assert\\NotBlank()");
        _builder.newLineIfNotEmpty();
      } else {
        boolean _isNullable = it.isNullable();
        boolean _not = (!_isNullable);
        if (_not) {
          _builder.append(" ");
          _builder.append("* @Assert\\NotNull()");
          _builder.newLineIfNotEmpty();
        }
      }
    }
    return _builder;
  }
  
  protected CharSequence _fieldAnnotations(final BooleanField it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _isMandatory = it.isMandatory();
      if (_isMandatory) {
        _builder.append(" ");
        _builder.append("* @Assert\\IsTrue(message=\"This option is mandatory.\")");
        _builder.newLineIfNotEmpty();
      } else {
        boolean _isNullable = it.isNullable();
        boolean _not = (!_isNullable);
        if (_not) {
          _builder.append(" ");
          _builder.append("* @Assert\\NotNull()");
          _builder.newLineIfNotEmpty();
        }
      }
    }
    _builder.append(" ");
    _builder.append("* @Assert\\Type(type=\"bool\")");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence fieldAnnotationsNumeric(final DerivedField it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append(" ");
    _builder.append("* @Assert\\Type(type=\"numeric\")");
    _builder.newLineIfNotEmpty();
    {
      boolean _isMandatory = it.isMandatory();
      if (_isMandatory) {
        _builder.append(" ");
        _builder.append("* @Assert\\NotBlank()");
        _builder.newLineIfNotEmpty();
        _builder.append(" ");
        _builder.append("* @Assert\\NotEqualTo(value=0)");
        _builder.newLineIfNotEmpty();
      } else {
        boolean _isNullable = it.isNullable();
        boolean _not = (!_isNullable);
        if (_not) {
          _builder.append(" ");
          _builder.append("* @Assert\\NotNull()");
          _builder.newLineIfNotEmpty();
        }
      }
    }
    return _builder;
  }
  
  private CharSequence fieldAnnotationsInteger(final AbstractIntegerField it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      if ((!(it instanceof UserField))) {
        _builder.append(" ");
        _builder.append("* @Assert\\Type(type=\"integer\")");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      if ((it.isMandatory() && (((!it.isPrimaryKey()) || this._modelExtensions.hasCompositeKeys(it.getEntity())) || Objects.equal(this._modelExtensions.getVersionField(it.getEntity()), this)))) {
        _builder.append(" ");
        _builder.append("* @Assert\\NotBlank()");
        _builder.newLineIfNotEmpty();
        {
          if ((!(it instanceof UserField))) {
            _builder.append(" ");
            _builder.append("* @Assert\\NotEqualTo(value=0)");
            _builder.newLineIfNotEmpty();
          }
        }
      } else {
        boolean _isNullable = it.isNullable();
        boolean _not = (!_isNullable);
        if (_not) {
          _builder.append(" ");
          _builder.append("* @Assert\\NotNull()");
          _builder.newLineIfNotEmpty();
        }
      }
    }
    return _builder;
  }
  
  protected CharSequence _fieldAnnotations(final AbstractIntegerField it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      if ((IterableExtensions.isEmpty(IterableExtensions.<JoinRelationship>filter(Iterables.<JoinRelationship>filter(it.getEntity().getIncoming(), JoinRelationship.class), ((Function1<JoinRelationship, Boolean>) (JoinRelationship e) -> {
        String _targetField = e.getTargetField();
        String _name = it.getName();
        return Boolean.valueOf(Objects.equal(_targetField, _name));
      }))) && IterableExtensions.isEmpty(IterableExtensions.<JoinRelationship>filter(Iterables.<JoinRelationship>filter(it.getEntity().getOutgoing(), JoinRelationship.class), ((Function1<JoinRelationship, Boolean>) (JoinRelationship e) -> {
        String _sourceField = e.getSourceField();
        String _name = it.getName();
        return Boolean.valueOf(Objects.equal(_sourceField, _name));
      }))))) {
        CharSequence _fieldAnnotationsInteger = this.fieldAnnotationsInteger(it);
        _builder.append(_fieldAnnotationsInteger);
        _builder.newLineIfNotEmpty();
      }
    }
    return _builder;
  }
  
  protected CharSequence _fieldAnnotations(final IntegerField it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      if ((IterableExtensions.isEmpty(IterableExtensions.<JoinRelationship>filter(Iterables.<JoinRelationship>filter(it.getEntity().getIncoming(), JoinRelationship.class), ((Function1<JoinRelationship, Boolean>) (JoinRelationship e) -> {
        String _targetField = e.getTargetField();
        String _name = it.getName();
        return Boolean.valueOf(Objects.equal(_targetField, _name));
      }))) && IterableExtensions.isEmpty(IterableExtensions.<JoinRelationship>filter(Iterables.<JoinRelationship>filter(it.getEntity().getOutgoing(), JoinRelationship.class), ((Function1<JoinRelationship, Boolean>) (JoinRelationship e) -> {
        String _sourceField = e.getSourceField();
        String _name = it.getName();
        return Boolean.valueOf(Objects.equal(_sourceField, _name));
      }))))) {
        CharSequence _fieldAnnotationsInteger = this.fieldAnnotationsInteger(it);
        _builder.append(_fieldAnnotationsInteger);
        _builder.newLineIfNotEmpty();
        {
          if (((!Objects.equal(it.getMinValue().toString(), "0")) && (!Objects.equal(it.getMaxValue().toString(), "0")))) {
            _builder.append(" ");
            _builder.append("* @Assert\\Range(min=");
            BigInteger _minValue = it.getMinValue();
            _builder.append(_minValue);
            _builder.append(", max=");
            BigInteger _maxValue = it.getMaxValue();
            _builder.append(_maxValue);
            _builder.append(")");
            _builder.newLineIfNotEmpty();
          } else {
            String _string = it.getMinValue().toString();
            boolean _notEquals = (!Objects.equal(_string, "0"));
            if (_notEquals) {
              _builder.append(" ");
              _builder.append("* @Assert\\GreaterThanOrEqual(value=");
              BigInteger _minValue_1 = it.getMinValue();
              _builder.append(_minValue_1);
              _builder.append(")");
              _builder.newLineIfNotEmpty();
            } else {
              String _string_1 = it.getMaxValue().toString();
              boolean _notEquals_1 = (!Objects.equal(_string_1, "0"));
              if (_notEquals_1) {
                _builder.append(" ");
                _builder.append("* @Assert\\LessThanOrEqual(value=");
                BigInteger _maxValue_1 = it.getMaxValue();
                _builder.append(_maxValue_1);
                _builder.append(")");
                _builder.newLineIfNotEmpty();
              } else {
                _builder.append(" ");
                _builder.append("* @Assert\\LessThan(value=");
                int _length = it.getLength();
                double _power = Math.pow(10, _length);
                BigInteger _valueOf = BigInteger.valueOf(((long) _power));
                _builder.append(_valueOf);
                _builder.append(")");
                _builder.newLineIfNotEmpty();
              }
            }
          }
        }
      }
    }
    return _builder;
  }
  
  protected CharSequence _fieldAnnotations(final DecimalField it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _fieldAnnotationsNumeric = this.fieldAnnotationsNumeric(it);
    _builder.append(_fieldAnnotationsNumeric);
    _builder.newLineIfNotEmpty();
    {
      String _string = Float.valueOf(it.getMinValue()).toString();
      boolean _notEquals = (!Objects.equal(_string, "0.0"));
      if (_notEquals) {
        _builder.append(" ");
        _builder.append("* @Assert\\GreaterThanOrEqual(value=");
        float _minValue = it.getMinValue();
        _builder.append(_minValue);
        _builder.append(")");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      String _string_1 = Float.valueOf(it.getMaxValue()).toString();
      boolean _notEquals_1 = (!Objects.equal(_string_1, "0.0"));
      if (_notEquals_1) {
        _builder.append(" ");
        _builder.append("* @Assert\\LessThanOrEqual(value=");
        float _maxValue = it.getMaxValue();
        _builder.append(_maxValue);
        _builder.append(")");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append(" ");
        _builder.append("* @Assert\\LessThan(value=");
        int _length = it.getLength();
        double _power = Math.pow(10, _length);
        BigInteger _valueOf = BigInteger.valueOf(((long) _power));
        _builder.append(_valueOf);
        _builder.append(")");
        _builder.newLineIfNotEmpty();
      }
    }
    return _builder;
  }
  
  protected CharSequence _fieldAnnotations(final FloatField it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _fieldAnnotationsNumeric = this.fieldAnnotationsNumeric(it);
    _builder.append(_fieldAnnotationsNumeric);
    _builder.newLineIfNotEmpty();
    {
      String _string = Float.valueOf(it.getMinValue()).toString();
      boolean _notEquals = (!Objects.equal(_string, "0.0"));
      if (_notEquals) {
        _builder.append(" ");
        _builder.append("* @Assert\\GreaterThanOrEqual(value=");
        float _minValue = it.getMinValue();
        _builder.append(_minValue);
        _builder.append(")");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      String _string_1 = Float.valueOf(it.getMaxValue()).toString();
      boolean _notEquals_1 = (!Objects.equal(_string_1, "0.0"));
      if (_notEquals_1) {
        _builder.append(" ");
        _builder.append("* @Assert\\LessThanOrEqual(value=");
        float _maxValue = it.getMaxValue();
        _builder.append(_maxValue);
        _builder.append(")");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append(" ");
        _builder.append("* @Assert\\LessThan(value=");
        int _length = it.getLength();
        double _power = Math.pow(10, _length);
        BigInteger _valueOf = BigInteger.valueOf(((long) _power));
        _builder.append(_valueOf);
        _builder.append(")");
        _builder.newLineIfNotEmpty();
      }
    }
    return _builder;
  }
  
  protected CharSequence _fieldAnnotations(final UserField it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _fieldAnnotationsInteger = this.fieldAnnotationsInteger(it);
    _builder.append(_fieldAnnotationsInteger);
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence fieldAnnotationsString(final AbstractStringField it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _fieldAnnotationsMandatory = this.fieldAnnotationsMandatory(it);
    _builder.append(_fieldAnnotationsMandatory);
    _builder.newLineIfNotEmpty();
    {
      boolean _isNospace = it.isNospace();
      if (_isNospace) {
        _builder.append(" ");
        _builder.append("* @Assert\\Regex(pattern=\"/\\s/\", match=false, message=\"This value must not contain space chars.\")");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      if (((null != it.getRegexp()) && (!Objects.equal(it.getRegexp(), "")))) {
        _builder.append(" ");
        _builder.append("* @Assert\\Regex(pattern=\"");
        String _regexp = it.getRegexp();
        _builder.append(_regexp);
        _builder.append("\"");
        {
          boolean _isRegexpOpposite = it.isRegexpOpposite();
          if (_isRegexpOpposite) {
            _builder.append(", match=false");
          }
        }
        _builder.append(")");
        _builder.newLineIfNotEmpty();
      }
    }
    return _builder;
  }
  
  protected CharSequence _fieldAnnotations(final AbstractStringField it) {
    return null;
  }
  
  protected CharSequence _fieldAnnotations(final StringField it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _fieldAnnotationsString = this.fieldAnnotationsString(it);
    _builder.append(_fieldAnnotationsString);
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("* @Assert\\Length(min=\"");
    int _minLength = it.getMinLength();
    _builder.append(_minLength);
    _builder.append("\", max=\"");
    int _length = it.getLength();
    _builder.append(_length);
    _builder.append("\")");
    _builder.newLineIfNotEmpty();
    {
      boolean _isFixed = it.isFixed();
      if (_isFixed) {
        _builder.append(" ");
        _builder.append("@Assert\\Length(min=\"");
        int _length_1 = it.getLength();
        _builder.append(_length_1);
        _builder.append("\", max=\"");
        int _length_2 = it.getLength();
        _builder.append(_length_2);
        _builder.append("\")");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      boolean _isBic = it.isBic();
      if (_isBic) {
        _builder.append(" ");
        _builder.append("* @Assert\\Bic()");
        _builder.newLineIfNotEmpty();
      } else {
        boolean _isCountry = it.isCountry();
        if (_isCountry) {
          _builder.append(" ");
          _builder.append("* @Assert\\Country()");
          _builder.newLineIfNotEmpty();
        } else {
          boolean _isCreditCard = it.isCreditCard();
          if (_isCreditCard) {
            _builder.append(" ");
            _builder.append("* @Assert\\Luhn(message=\"Please check your credit card number.\")");
            _builder.newLineIfNotEmpty();
            _builder.append(" ");
            _builder.append("* @Assert\\CardScheme(schemes={\"AMEX\", \"CHINA_UNIONPAY\", \"DINERS\", \"DISCOVER\", \"INSTAPAYMENT\", \"JCB\", \"LASER\", \"MAESTRO\", \"MASTERCARD\", \"VISA\"})");
            _builder.newLineIfNotEmpty();
          } else {
            boolean _isCurrency = it.isCurrency();
            if (_isCurrency) {
              _builder.append(" ");
              _builder.append("* @Assert\\Currency()");
              _builder.newLineIfNotEmpty();
            } else {
              boolean _isLanguage = it.isLanguage();
              if (_isLanguage) {
                _builder.append(" ");
                _builder.append("* @Assert\\Language()");
                _builder.newLineIfNotEmpty();
              } else {
                boolean _isLocale = it.isLocale();
                if (_isLocale) {
                  _builder.append(" ");
                  _builder.append("* @Assert\\Locale()");
                  _builder.newLineIfNotEmpty();
                } else {
                  boolean _isHtmlcolour = it.isHtmlcolour();
                  if (_isHtmlcolour) {
                    _builder.append(" ");
                    _builder.append("* @Assert\\Regex(pattern=\"/^#?(([a-fA-F0-9]{3}){1,2})$/\", message=\"This value must be a valid html colour code [#123 or #123456].\")");
                    _builder.newLineIfNotEmpty();
                  } else {
                    boolean _isIban = it.isIban();
                    if (_isIban) {
                      _builder.append(" ");
                      _builder.append("* @Assert\\Iban()");
                      _builder.newLineIfNotEmpty();
                    } else {
                      StringIsbnStyle _isbn = it.getIsbn();
                      boolean _notEquals = (!Objects.equal(_isbn, StringIsbnStyle.NONE));
                      if (_notEquals) {
                        _builder.append(" ");
                        _builder.append("* @Assert\\Isbn(isbn10=");
                        String _displayBool = this._formattingExtensions.displayBool(Boolean.valueOf((Objects.equal(it.getIsbn(), StringIsbnStyle.ISBN10) || Objects.equal(it.getIsbn(), StringIsbnStyle.ALL))));
                        _builder.append(_displayBool);
                        _builder.append(", isbn13=");
                        String _displayBool_1 = this._formattingExtensions.displayBool(Boolean.valueOf((Objects.equal(it.getIsbn(), StringIsbnStyle.ISBN13) || Objects.equal(it.getIsbn(), StringIsbnStyle.ALL))));
                        _builder.append(_displayBool_1);
                        _builder.append(")");
                        _builder.newLineIfNotEmpty();
                      } else {
                        StringIssnStyle _issn = it.getIssn();
                        boolean _notEquals_1 = (!Objects.equal(_issn, StringIssnStyle.NONE));
                        if (_notEquals_1) {
                          _builder.append(" ");
                          _builder.append("* @Assert\\Issn(caseSensitive=");
                          String _displayBool_2 = this._formattingExtensions.displayBool(Boolean.valueOf((Objects.equal(it.getIssn(), StringIssnStyle.CASE_SENSITIVE) || Objects.equal(it.getIssn(), StringIssnStyle.STRICT))));
                          _builder.append(_displayBool_2);
                          _builder.append(", requireHyphen=");
                          String _displayBool_3 = this._formattingExtensions.displayBool(Boolean.valueOf((Objects.equal(it.getIssn(), StringIssnStyle.REQUIRE_HYPHEN) || Objects.equal(it.getIssn(), StringIssnStyle.STRICT))));
                          _builder.append(_displayBool_3);
                          _builder.append(")");
                          _builder.newLineIfNotEmpty();
                        } else {
                          IpAddressScope _ipAddress = it.getIpAddress();
                          boolean _notEquals_2 = (!Objects.equal(_ipAddress, IpAddressScope.NONE));
                          if (_notEquals_2) {
                            _builder.append(" ");
                            _builder.append("* @Assert\\Ip(version=\"");
                            String _ipScopeAsConstant = this._modelExtensions.ipScopeAsConstant(it.getIpAddress());
                            _builder.append(_ipScopeAsConstant);
                            _builder.append("\")");
                            _builder.newLineIfNotEmpty();
                          } else {
                            boolean _isUuid = it.isUuid();
                            if (_isUuid) {
                              _builder.append(" ");
                              _builder.append("* @Assert\\Uuid(strict=true)");
                              _builder.newLineIfNotEmpty();
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
    return _builder;
  }
  
  protected CharSequence _fieldAnnotations(final TextField it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _fieldAnnotationsString = this.fieldAnnotationsString(it);
    _builder.append(_fieldAnnotationsString);
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("* @Assert\\Length(min=\"");
    int _minLength = it.getMinLength();
    _builder.append(_minLength);
    _builder.append("\", max=\"");
    int _length = it.getLength();
    _builder.append(_length);
    _builder.append("\")");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  protected CharSequence _fieldAnnotations(final EmailField it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _fieldAnnotationsString = this.fieldAnnotationsString(it);
    _builder.append(_fieldAnnotationsString);
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("* @Assert\\Length(min=\"");
    int _minLength = it.getMinLength();
    _builder.append(_minLength);
    _builder.append("\", max=\"");
    int _length = it.getLength();
    _builder.append(_length);
    _builder.append("\")");
    _builder.newLineIfNotEmpty();
    {
      boolean _isMandatory = it.isMandatory();
      if (_isMandatory) {
        _builder.append(" ");
        _builder.append("* @Assert\\Email(checkMX=");
        String _displayBool = this._formattingExtensions.displayBool(Boolean.valueOf(it.isCheckMX()));
        _builder.append(_displayBool);
        _builder.append(", checkHost=");
        String _displayBool_1 = this._formattingExtensions.displayBool(Boolean.valueOf(it.isCheckHost()));
        _builder.append(_displayBool_1);
        _builder.append(")");
        _builder.newLineIfNotEmpty();
      }
    }
    return _builder;
  }
  
  protected CharSequence _fieldAnnotations(final UrlField it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _fieldAnnotationsString = this.fieldAnnotationsString(it);
    _builder.append(_fieldAnnotationsString);
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("* @Assert\\Length(min=\"");
    int _minLength = it.getMinLength();
    _builder.append(_minLength);
    _builder.append("\", max=\"");
    int _length = it.getLength();
    _builder.append(_length);
    _builder.append("\")");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("* @Assert\\Url(checkDNS=");
    String _displayBool = this._formattingExtensions.displayBool(Boolean.valueOf(it.isCheckDNS()));
    _builder.append(_displayBool);
    {
      boolean _isCheckDNS = it.isCheckDNS();
      if (_isCheckDNS) {
        _builder.append(", dnsMessage = \"The host \'{{ value }}\' could not be resolved.\"");
      }
    }
    _builder.append(")");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  protected CharSequence _fieldAnnotations(final UploadField it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _fieldAnnotationsString = this.fieldAnnotationsString(it);
    _builder.append(_fieldAnnotationsString);
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("* @Assert\\Length(min=\"");
    int _minLength = it.getMinLength();
    _builder.append(_minLength);
    _builder.append("\", max=\"");
    int _length = it.getLength();
    _builder.append(_length);
    _builder.append("\")");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("* @Assert\\File(");
    _builder.newLineIfNotEmpty();
    {
      ArrayList<String> _uploadConstraints = this.getUploadConstraints(it);
      for(final String constraint : _uploadConstraints) {
        _builder.append(" ");
        _builder.append("*    ");
        _builder.append(constraint);
        {
          String _last = IterableExtensions.<String>last(this.getUploadConstraints(it));
          boolean _notEquals = (!Objects.equal(constraint, _last));
          if (_notEquals) {
            _builder.append(",");
          }
        }
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append(" ");
    _builder.append("* )");
    _builder.newLineIfNotEmpty();
    {
      boolean _isOnlyImageField = this._modelExtensions.isOnlyImageField(it);
      if (_isOnlyImageField) {
        _builder.append(" ");
        _builder.append("* @Assert\\Image(");
        _builder.newLineIfNotEmpty();
        {
          ArrayList<String> _uploadImageConstraints = this.getUploadImageConstraints(it);
          for(final String constraint_1 : _uploadImageConstraints) {
            _builder.append(" ");
            _builder.append("*    ");
            _builder.append(constraint_1);
            {
              String _last_1 = IterableExtensions.<String>last(this.getUploadImageConstraints(it));
              boolean _notEquals_1 = (!Objects.equal(constraint_1, _last_1));
              if (_notEquals_1) {
                _builder.append(",");
              }
            }
            _builder.newLineIfNotEmpty();
          }
        }
        _builder.append(" ");
        _builder.append("* )");
        _builder.newLineIfNotEmpty();
      }
    }
    return _builder;
  }
  
  private ArrayList<String> getUploadConstraints(final UploadField it) {
    ArrayList<String> _xblockexpression = null;
    {
      final ArrayList<String> constraints = CollectionLiterals.<String>newArrayList();
      String _maxSize = it.getMaxSize();
      boolean _notEquals = (!Objects.equal(_maxSize, ""));
      if (_notEquals) {
        StringConcatenation _builder = new StringConcatenation();
        _builder.append("maxSize = \"");
        String _maxSize_1 = it.getMaxSize();
        _builder.append(_maxSize_1);
        _builder.append("\"");
        constraints.add(_builder.toString());
      }
      String _mimeTypes = it.getMimeTypes();
      boolean _notEquals_1 = (!Objects.equal(_mimeTypes, ""));
      if (_notEquals_1) {
        final String[] mimeTypesList = it.getMimeTypes().replaceAll(", ", ",").split(",");
        String _join = IterableExtensions.join(((Iterable<?>)Conversions.doWrapArray(mimeTypesList)), "\", \"");
        String _plus = ("\"" + _join);
        String mimeTypeString = (_plus + "\"");
        StringConcatenation _builder_1 = new StringConcatenation();
        _builder_1.append("mimeTypes = {");
        _builder_1.append(mimeTypeString);
        _builder_1.append("}");
        constraints.add(_builder_1.toString());
      }
      _xblockexpression = constraints;
    }
    return _xblockexpression;
  }
  
  private ArrayList<String> getUploadImageConstraints(final UploadField it) {
    ArrayList<String> _xblockexpression = null;
    {
      final ArrayList<String> constraints = CollectionLiterals.<String>newArrayList();
      int _minWidth = it.getMinWidth();
      boolean _greaterThan = (_minWidth > 0);
      if (_greaterThan) {
        StringConcatenation _builder = new StringConcatenation();
        _builder.append("minWidth = ");
        int _minWidth_1 = it.getMinWidth();
        _builder.append(_minWidth_1);
        constraints.add(_builder.toString());
      }
      int _maxWidth = it.getMaxWidth();
      boolean _greaterThan_1 = (_maxWidth > 0);
      if (_greaterThan_1) {
        StringConcatenation _builder_1 = new StringConcatenation();
        _builder_1.append("maxWidth = ");
        int _maxWidth_1 = it.getMaxWidth();
        _builder_1.append(_maxWidth_1);
        constraints.add(_builder_1.toString());
      }
      int _minHeight = it.getMinHeight();
      boolean _greaterThan_2 = (_minHeight > 0);
      if (_greaterThan_2) {
        StringConcatenation _builder_2 = new StringConcatenation();
        _builder_2.append("minHeight = ");
        int _minHeight_1 = it.getMinHeight();
        _builder_2.append(_minHeight_1);
        constraints.add(_builder_2.toString());
      }
      int _maxHeight = it.getMaxHeight();
      boolean _greaterThan_3 = (_maxHeight > 0);
      if (_greaterThan_3) {
        StringConcatenation _builder_3 = new StringConcatenation();
        _builder_3.append("maxHeight = ");
        int _maxHeight_1 = it.getMaxHeight();
        _builder_3.append(_maxHeight_1);
        constraints.add(_builder_3.toString());
      }
      float _minRatio = it.getMinRatio();
      boolean _greaterThan_4 = (_minRatio > 0);
      if (_greaterThan_4) {
        StringConcatenation _builder_4 = new StringConcatenation();
        _builder_4.append("minRatio = ");
        float _minRatio_1 = it.getMinRatio();
        _builder_4.append(_minRatio_1);
        constraints.add(_builder_4.toString());
      }
      float _maxRatio = it.getMaxRatio();
      boolean _greaterThan_5 = (_maxRatio > 0);
      if (_greaterThan_5) {
        StringConcatenation _builder_5 = new StringConcatenation();
        _builder_5.append("maxRatio = ");
        float _maxRatio_1 = it.getMaxRatio();
        _builder_5.append(_maxRatio_1);
        constraints.add(_builder_5.toString());
      }
      boolean _isAllowSquare = it.isAllowSquare();
      boolean _not = (!_isAllowSquare);
      if (_not) {
        constraints.add("allowSquare = false");
      }
      boolean _isAllowLandscape = it.isAllowLandscape();
      boolean _not_1 = (!_isAllowLandscape);
      if (_not_1) {
        constraints.add("allowLandscape = false");
      }
      boolean _isAllowPortrait = it.isAllowPortrait();
      boolean _not_2 = (!_isAllowPortrait);
      if (_not_2) {
        constraints.add("allowPortrait = false");
      }
      if ((it.isDetectCorrupted() && (this._utils.targets(it.getEntity().getApplication(), "2.0")).booleanValue())) {
        constraints.add("detectCorrupted = true");
      }
      _xblockexpression = constraints;
    }
    return _xblockexpression;
  }
  
  protected CharSequence _fieldAnnotations(final ListField it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _fieldAnnotationsMandatory = this.fieldAnnotationsMandatory(it);
    _builder.append(_fieldAnnotationsMandatory);
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("* @");
    String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(it.getEntity().getApplication().getName());
    _builder.append(_formatForCodeCapital);
    _builder.append("Assert\\ListEntry(entityName=\"");
    String _formatForCode = this._formattingExtensions.formatForCode(it.getEntity().getName());
    _builder.append(_formatForCode);
    _builder.append("\", propertyName=\"");
    String _formatForCode_1 = this._formattingExtensions.formatForCode(it.getName());
    _builder.append(_formatForCode_1);
    _builder.append("\", multiple=");
    String _displayBool = this._formattingExtensions.displayBool(Boolean.valueOf(it.isMultiple()));
    _builder.append(_displayBool);
    {
      boolean _isMultiple = it.isMultiple();
      if (_isMultiple) {
        {
          int _min = it.getMin();
          boolean _greaterThan = (_min > 0);
          if (_greaterThan) {
            _builder.append(", min=");
            int _min_1 = it.getMin();
            _builder.append(_min_1);
          }
        }
        {
          int _max = it.getMax();
          boolean _greaterThan_1 = (_max > 0);
          if (_greaterThan_1) {
            _builder.append(", max=");
            int _max_1 = it.getMax();
            _builder.append(_max_1);
          }
        }
      }
    }
    _builder.append(")");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  protected CharSequence _fieldAnnotations(final ArrayField it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _fieldAnnotationsMandatory = this.fieldAnnotationsMandatory(it);
    _builder.append(_fieldAnnotationsMandatory);
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("* @Assert\\Type(type=\"array\")");
    _builder.newLineIfNotEmpty();
    {
      int _max = it.getMax();
      boolean _greaterThan = (_max > 0);
      if (_greaterThan) {
        _builder.append(" ");
        _builder.append("* @Assert\\Count(min=\"");
        int _min = it.getMin();
        _builder.append(_min);
        _builder.append("\", max=\"");
        int _max_1 = it.getMax();
        _builder.append(_max_1);
        _builder.append("\")");
        _builder.newLineIfNotEmpty();
      }
    }
    return _builder;
  }
  
  protected CharSequence _fieldAnnotations(final ObjectField it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _fieldAnnotationsMandatory = this.fieldAnnotationsMandatory(it);
    _builder.append(_fieldAnnotationsMandatory);
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  protected CharSequence _fieldAnnotations(final AbstractDateField it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _fieldAnnotationsMandatory = this.fieldAnnotationsMandatory(it);
    _builder.append(_fieldAnnotationsMandatory);
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  protected CharSequence _fieldAnnotations(final DatetimeField it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _fieldAnnotationsMandatory = this.fieldAnnotationsMandatory(it);
    _builder.append(_fieldAnnotationsMandatory);
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("* @Assert\\DateTime()");
    _builder.newLineIfNotEmpty();
    {
      boolean _isPast = it.isPast();
      if (_isPast) {
        _builder.append(" ");
        _builder.append("* @Assert\\LessThan(\"now\")");
        _builder.newLineIfNotEmpty();
      } else {
        boolean _isFuture = it.isFuture();
        if (_isFuture) {
          _builder.append(" ");
          _builder.append("* @Assert\\GreaterThan(\"now\")");
          _builder.newLineIfNotEmpty();
        }
      }
    }
    {
      if ((it.isEndDate() && (null != this._modelExtensions.getStartDateField(it.getEntity())))) {
        _builder.append(" ");
        _builder.append("* @Assert\\Expression(\"value > this.get");
        String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(this._modelExtensions.getStartDateField(it.getEntity()).getName());
        _builder.append(_formatForCodeCapital);
        _builder.append("()\")");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      if (((null != it.getValidatorAddition()) && (!Objects.equal(it.getValidatorAddition(), "")))) {
        _builder.append(" ");
        _builder.append("* @Assert\\");
        String _validatorAddition = it.getValidatorAddition();
        _builder.append(_validatorAddition);
        _builder.newLineIfNotEmpty();
      }
    }
    return _builder;
  }
  
  protected CharSequence _fieldAnnotations(final DateField it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _fieldAnnotationsMandatory = this.fieldAnnotationsMandatory(it);
    _builder.append(_fieldAnnotationsMandatory);
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("* @Assert\\Date()");
    _builder.newLineIfNotEmpty();
    {
      boolean _isPast = it.isPast();
      if (_isPast) {
        _builder.append(" ");
        _builder.append("* @Assert\\LessThan(\"now\")");
        _builder.newLineIfNotEmpty();
      } else {
        boolean _isFuture = it.isFuture();
        if (_isFuture) {
          _builder.append(" ");
          _builder.append("* @Assert\\GreaterThan(\"now\")");
          _builder.newLineIfNotEmpty();
        }
      }
    }
    {
      if ((it.isEndDate() && (null != this._modelExtensions.getStartDateField(it.getEntity())))) {
        _builder.append(" ");
        _builder.append("* @Assert\\Expression(\"value > this.get");
        String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(this._modelExtensions.getStartDateField(it.getEntity()).getName());
        _builder.append(_formatForCodeCapital);
        _builder.append("()\")");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      if (((null != it.getValidatorAddition()) && (!Objects.equal(it.getValidatorAddition(), "")))) {
        _builder.append(" ");
        _builder.append("* @Assert\\");
        String _validatorAddition = it.getValidatorAddition();
        _builder.append(_validatorAddition);
        _builder.newLineIfNotEmpty();
      }
    }
    return _builder;
  }
  
  protected CharSequence _fieldAnnotations(final TimeField it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _fieldAnnotationsMandatory = this.fieldAnnotationsMandatory(it);
    _builder.append(_fieldAnnotationsMandatory);
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("* @Assert\\Time()");
    _builder.newLineIfNotEmpty();
    {
      if (((null != it.getValidatorAddition()) && (!Objects.equal(it.getValidatorAddition(), "")))) {
        _builder.append(" ");
        _builder.append("* @Assert\\");
        String _validatorAddition = it.getValidatorAddition();
        _builder.append(_validatorAddition);
        _builder.newLineIfNotEmpty();
      }
    }
    return _builder;
  }
  
  protected CharSequence _validationMethods(final UserField it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Checks whether the ");
    String _formatForCode = this._formattingExtensions.formatForCode(it.getName());
    _builder.append(_formatForCode, " ");
    _builder.append(" field contains a valid user reference.");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("* This method is used for validation.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @Assert\\IsTrue(message=\"This value must be a valid user id.\")");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return boolean True if data is valid else false");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function is");
    String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital);
    _builder.append("UserValid()");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return ");
    {
      boolean _isMandatory = it.isMandatory();
      boolean _not = (!_isMandatory);
      if (_not) {
        _builder.append("null === $this[\'");
        String _formatForCode_1 = this._formattingExtensions.formatForCode(it.getName());
        _builder.append(_formatForCode_1, "    ");
        _builder.append("\'] || ");
      }
    }
    _builder.append("$this[\'");
    String _formatForCode_2 = this._formattingExtensions.formatForCode(it.getName());
    _builder.append(_formatForCode_2, "    ");
    _builder.append("\'] instanceof UserEntity;");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  protected CharSequence _validationMethods(final TimeField it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _isPast = it.isPast();
      if (_isPast) {
        _builder.append("/**");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Checks whether the ");
        String _formatForCode = this._formattingExtensions.formatForCode(it.getName());
        _builder.append(_formatForCode, " ");
        _builder.append(" field value is in the past.");
        _builder.newLineIfNotEmpty();
        _builder.append(" ");
        _builder.append("* This method is used for validation.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @Assert\\IsTrue(message=\"This value must be a time in the past.\")");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @return boolean True if data is valid else false");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
        _builder.append("public function is");
        String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(it.getName());
        _builder.append(_formatForCodeCapital);
        _builder.append("TimeValidPast()");
        _builder.newLineIfNotEmpty();
        _builder.append("{");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$format = \'His\';");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("return ");
        {
          boolean _isMandatory = it.isMandatory();
          boolean _not = (!_isMandatory);
          if (_not) {
            _builder.append("!$this[\'");
            String _formatForCode_1 = this._formattingExtensions.formatForCode(it.getName());
            _builder.append(_formatForCode_1, "    ");
            _builder.append("\'] || ");
          }
        }
        _builder.append("$this[\'");
        String _formatForCode_2 = this._formattingExtensions.formatForCode(it.getName());
        _builder.append(_formatForCode_2, "    ");
        _builder.append("\']->format($format) < date($format);");
        _builder.newLineIfNotEmpty();
        _builder.append("}");
        _builder.newLine();
      } else {
        boolean _isFuture = it.isFuture();
        if (_isFuture) {
          _builder.append("/**");
          _builder.newLine();
          _builder.append(" ");
          _builder.append("* Checks whether the ");
          String _formatForCode_3 = this._formattingExtensions.formatForCode(it.getName());
          _builder.append(_formatForCode_3, " ");
          _builder.append(" field value is in the future.");
          _builder.newLineIfNotEmpty();
          _builder.append(" ");
          _builder.append("* This method is used for validation.");
          _builder.newLine();
          _builder.append(" ");
          _builder.append("*");
          _builder.newLine();
          _builder.append(" ");
          _builder.append("* @Assert\\IsTrue(message=\"This value must be a time in the future.\")");
          _builder.newLine();
          _builder.append(" ");
          _builder.append("*");
          _builder.newLine();
          _builder.append(" ");
          _builder.append("* @return boolean True if data is valid else false");
          _builder.newLine();
          _builder.append(" ");
          _builder.append("*/");
          _builder.newLine();
          _builder.append("public function is");
          String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(it.getName());
          _builder.append(_formatForCodeCapital_1);
          _builder.append("TimeValidFuture()");
          _builder.newLineIfNotEmpty();
          _builder.append("{");
          _builder.newLine();
          _builder.append("    ");
          _builder.append("$format = \'His\';");
          _builder.newLine();
          _builder.newLine();
          _builder.append("    ");
          _builder.append("return ");
          {
            boolean _isMandatory_1 = it.isMandatory();
            boolean _not_1 = (!_isMandatory_1);
            if (_not_1) {
              _builder.append("!$this[\'");
              String _formatForCode_4 = this._formattingExtensions.formatForCode(it.getName());
              _builder.append(_formatForCode_4, "    ");
              _builder.append("\'] || ");
            }
          }
          _builder.append("$this[\'");
          String _formatForCode_5 = this._formattingExtensions.formatForCode(it.getName());
          _builder.append(_formatForCode_5, "    ");
          _builder.append("\']->format($format) > date($format);");
          _builder.newLineIfNotEmpty();
          _builder.append("}");
          _builder.newLine();
        }
      }
    }
    return _builder;
  }
  
  public CharSequence classAnnotations(final DataObject it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      final Function1<DerivedField, Boolean> _function = (DerivedField it_1) -> {
        boolean _isPrimaryKey = it_1.isPrimaryKey();
        return Boolean.valueOf((!_isPrimaryKey));
      };
      boolean _isEmpty = IterableExtensions.isEmpty(IterableExtensions.<DerivedField>filter(this._modelExtensions.getUniqueDerivedFields(it), _function));
      boolean _not = (!_isEmpty);
      if (_not) {
        {
          final Function1<DerivedField, Boolean> _function_1 = (DerivedField it_1) -> {
            boolean _isPrimaryKey = it_1.isPrimaryKey();
            return Boolean.valueOf((!_isPrimaryKey));
          };
          Iterable<DerivedField> _filter = IterableExtensions.<DerivedField>filter(this._modelExtensions.getUniqueDerivedFields(it), _function_1);
          for(final DerivedField udf : _filter) {
            _builder.append(" ");
            _builder.append("* @UniqueEntity(fields=\"");
            String _formatForCode = this._formattingExtensions.formatForCode(udf.getName());
            _builder.append(_formatForCode);
            _builder.append("\", ignoreNull=\"");
            String _displayBool = this._formattingExtensions.displayBool(Boolean.valueOf(udf.isNullable()));
            _builder.append(_displayBool);
            _builder.append("\")");
            _builder.newLineIfNotEmpty();
          }
        }
      }
    }
    {
      if ((((it instanceof Entity) && ((Entity) it).isSlugUnique()) && this._modelBehaviourExtensions.hasSluggableFields(((Entity) it)))) {
        _builder.append(" ");
        _builder.append("* @UniqueEntity(fields=\"slug\", ignoreNull=\"false\")");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      final Function1<JoinRelationship, Boolean> _function_2 = (JoinRelationship it_1) -> {
        return Boolean.valueOf(it_1.isUnique());
      };
      boolean _isEmpty_1 = IterableExtensions.isEmpty(IterableExtensions.<JoinRelationship>filter(this._modelJoinExtensions.getIncomingJoinRelations(it), _function_2));
      boolean _not_1 = (!_isEmpty_1);
      if (_not_1) {
        {
          final Function1<JoinRelationship, Boolean> _function_3 = (JoinRelationship it_1) -> {
            return Boolean.valueOf(it_1.isUnique());
          };
          Iterable<JoinRelationship> _filter_1 = IterableExtensions.<JoinRelationship>filter(this._modelJoinExtensions.getIncomingJoinRelations(it), _function_3);
          for(final JoinRelationship rel : _filter_1) {
            final String aliasName = StringExtensions.toFirstLower(this._namingExtensions.getRelationAliasName(rel, Boolean.valueOf(false)));
            _builder.newLineIfNotEmpty();
            _builder.append(" ");
            _builder.append("* @UniqueEntity(fields=\"");
            String _formatForCode_1 = this._formattingExtensions.formatForCode(aliasName);
            _builder.append(_formatForCode_1);
            _builder.append("\", ignoreNull=\"");
            String _displayBool_1 = this._formattingExtensions.displayBool(Boolean.valueOf(rel.isNullable()));
            _builder.append(_displayBool_1);
            _builder.append("\")");
            _builder.newLineIfNotEmpty();
          }
        }
      }
    }
    {
      final Function1<JoinRelationship, Boolean> _function_4 = (JoinRelationship it_1) -> {
        return Boolean.valueOf(it_1.isUnique());
      };
      boolean _isEmpty_2 = IterableExtensions.isEmpty(IterableExtensions.<JoinRelationship>filter(this._modelJoinExtensions.getOutgoingJoinRelations(it), _function_4));
      boolean _not_2 = (!_isEmpty_2);
      if (_not_2) {
        {
          final Function1<JoinRelationship, Boolean> _function_5 = (JoinRelationship it_1) -> {
            return Boolean.valueOf(it_1.isUnique());
          };
          Iterable<JoinRelationship> _filter_2 = IterableExtensions.<JoinRelationship>filter(this._modelJoinExtensions.getOutgoingJoinRelations(it), _function_5);
          for(final JoinRelationship rel_1 : _filter_2) {
            final String aliasName_1 = StringExtensions.toFirstLower(this._namingExtensions.getRelationAliasName(rel_1, Boolean.valueOf(true)));
            _builder.newLineIfNotEmpty();
            _builder.append(" ");
            _builder.append("* @UniqueEntity(fields=\"");
            String _formatForCode_2 = this._formattingExtensions.formatForCode(aliasName_1);
            _builder.append(_formatForCode_2);
            _builder.append("\", ignoreNull=\"");
            String _displayBool_2 = this._formattingExtensions.displayBool(Boolean.valueOf(rel_1.isNullable()));
            _builder.append(_displayBool_2);
            _builder.append("\")");
            _builder.newLineIfNotEmpty();
          }
        }
      }
    }
    {
      if (((it instanceof Entity) && (!IterableExtensions.isEmpty(this._modelExtensions.getUniqueIndexes(((Entity) it)))))) {
        {
          Iterable<EntityIndex> _uniqueIndexes = this._modelExtensions.getUniqueIndexes(((Entity) it));
          for(final EntityIndex index : _uniqueIndexes) {
            CharSequence _uniqueAnnotation = this.uniqueAnnotation(index);
            _builder.append(_uniqueAnnotation);
            _builder.newLineIfNotEmpty();
          }
        }
      }
    }
    return _builder;
  }
  
  private CharSequence uniqueAnnotation(final EntityIndex it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append(" ");
    _builder.append("* @UniqueEntity(fields={");
    {
      EList<EntityIndexItem> _items = it.getItems();
      boolean _hasElements = false;
      for(final EntityIndexItem item : _items) {
        if (!_hasElements) {
          _hasElements = true;
        } else {
          _builder.appendImmediate(", ", "");
        }
        _builder.append("\"");
        String _formatForCode = this._formattingExtensions.formatForCode(item.getName());
        _builder.append(_formatForCode);
        _builder.append("\"");
      }
    }
    _builder.append("}, ignoreNull=\"");
    boolean _includesNotNullableField = this.includesNotNullableField(it);
    String _displayBool = this._formattingExtensions.displayBool(Boolean.valueOf((!_includesNotNullableField)));
    _builder.append(_displayBool);
    _builder.append("\")");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private boolean includesNotNullableField(final EntityIndex it) {
    boolean _xblockexpression = false;
    {
      final Function1<DerivedField, Boolean> _function = (DerivedField it_1) -> {
        boolean _isNullable = it_1.isNullable();
        return Boolean.valueOf((!_isNullable));
      };
      final Iterable<DerivedField> nonNullableFields = IterableExtensions.<DerivedField>filter(this._modelExtensions.getDerivedFields(it.getEntity()), _function);
      EList<EntityIndexItem> _items = it.getItems();
      for (final EntityIndexItem item : _items) {
        final Function1<DerivedField, Boolean> _function_1 = (DerivedField it_1) -> {
          return Boolean.valueOf(item.getName().equals(it_1.getName()));
        };
        boolean _isEmpty = IterableExtensions.isEmpty(IterableExtensions.<DerivedField>filter(nonNullableFields, _function_1));
        boolean _not = (!_isEmpty);
        if (_not) {
          return true;
        }
      }
      _xblockexpression = false;
    }
    return _xblockexpression;
  }
  
  public CharSequence fieldAnnotations(final DerivedField it) {
    if (it instanceof EmailField) {
      return _fieldAnnotations((EmailField)it);
    } else if (it instanceof IntegerField) {
      return _fieldAnnotations((IntegerField)it);
    } else if (it instanceof ListField) {
      return _fieldAnnotations((ListField)it);
    } else if (it instanceof StringField) {
      return _fieldAnnotations((StringField)it);
    } else if (it instanceof TextField) {
      return _fieldAnnotations((TextField)it);
    } else if (it instanceof UploadField) {
      return _fieldAnnotations((UploadField)it);
    } else if (it instanceof UrlField) {
      return _fieldAnnotations((UrlField)it);
    } else if (it instanceof UserField) {
      return _fieldAnnotations((UserField)it);
    } else if (it instanceof AbstractIntegerField) {
      return _fieldAnnotations((AbstractIntegerField)it);
    } else if (it instanceof AbstractStringField) {
      return _fieldAnnotations((AbstractStringField)it);
    } else if (it instanceof ArrayField) {
      return _fieldAnnotations((ArrayField)it);
    } else if (it instanceof DateField) {
      return _fieldAnnotations((DateField)it);
    } else if (it instanceof DatetimeField) {
      return _fieldAnnotations((DatetimeField)it);
    } else if (it instanceof DecimalField) {
      return _fieldAnnotations((DecimalField)it);
    } else if (it instanceof FloatField) {
      return _fieldAnnotations((FloatField)it);
    } else if (it instanceof TimeField) {
      return _fieldAnnotations((TimeField)it);
    } else if (it instanceof AbstractDateField) {
      return _fieldAnnotations((AbstractDateField)it);
    } else if (it instanceof BooleanField) {
      return _fieldAnnotations((BooleanField)it);
    } else if (it instanceof ObjectField) {
      return _fieldAnnotations((ObjectField)it);
    } else if (it != null) {
      return _fieldAnnotations(it);
    } else {
      throw new IllegalArgumentException("Unhandled parameter types: " +
        Arrays.<Object>asList(it).toString());
    }
  }
  
  public CharSequence validationMethods(final DerivedField it) {
    if (it instanceof UserField) {
      return _validationMethods((UserField)it);
    } else if (it instanceof TimeField) {
      return _validationMethods((TimeField)it);
    } else {
      throw new IllegalArgumentException("Unhandled parameter types: " +
        Arrays.<Object>asList(it).toString());
    }
  }
}
