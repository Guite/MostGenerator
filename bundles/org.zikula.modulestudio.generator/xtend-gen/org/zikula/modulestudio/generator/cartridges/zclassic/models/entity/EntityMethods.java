package org.zikula.modulestudio.generator.cartridges.zclassic.models.entity;

import com.google.common.base.Objects;
import com.google.common.collect.Iterables;
import de.guite.modulestudio.metamodel.Application;
import de.guite.modulestudio.metamodel.DataObject;
import de.guite.modulestudio.metamodel.DateField;
import de.guite.modulestudio.metamodel.DatetimeField;
import de.guite.modulestudio.metamodel.DecimalField;
import de.guite.modulestudio.metamodel.DerivedField;
import de.guite.modulestudio.metamodel.Entity;
import de.guite.modulestudio.metamodel.EntityField;
import de.guite.modulestudio.metamodel.FloatField;
import de.guite.modulestudio.metamodel.JoinRelationship;
import de.guite.modulestudio.metamodel.ListField;
import de.guite.modulestudio.metamodel.ManyToManyRelationship;
import de.guite.modulestudio.metamodel.TimeField;
import de.guite.modulestudio.metamodel.UploadField;
import de.guite.modulestudio.metamodel.UserField;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.xbase.lib.CollectionLiterals;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.eclipse.xtext.xbase.lib.StringExtensions;
import org.zikula.modulestudio.generator.cartridges.zclassic.models.business.ValidationConstraints;
import org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.Property;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.ModelInheritanceExtensions;
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class EntityMethods {
  @Extension
  private FormattingExtensions _formattingExtensions = new FormattingExtensions();
  
  @Extension
  private ModelExtensions _modelExtensions = new ModelExtensions();
  
  @Extension
  private ModelInheritanceExtensions _modelInheritanceExtensions = new ModelInheritanceExtensions();
  
  @Extension
  private ModelJoinExtensions _modelJoinExtensions = new ModelJoinExtensions();
  
  @Extension
  private NamingExtensions _namingExtensions = new NamingExtensions();
  
  @Extension
  private Utils _utils = new Utils();
  
  protected CharSequence _generate(final DataObject it, final Application app, final Property thProp) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _validationMethods = this.validationMethods(it);
    _builder.append(_validationMethods);
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    CharSequence _relatedObjectsImpl = this.relatedObjectsImpl(it, app);
    _builder.append(_relatedObjectsImpl);
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    CharSequence _stringImpl = this.toStringImpl(it, app);
    _builder.append(_stringImpl);
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    CharSequence _cloneImpl = this.cloneImpl(it, app, thProp);
    _builder.append(_cloneImpl);
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  protected CharSequence _generate(final Entity it, final Application app, final Property thProp) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _propertyChangedListener = this.propertyChangedListener(it);
    _builder.append(_propertyChangedListener);
    _builder.newLineIfNotEmpty();
    CharSequence _titleFromDisplayPattern = this.getTitleFromDisplayPattern(it, app);
    _builder.append(_titleFromDisplayPattern);
    _builder.newLineIfNotEmpty();
    CharSequence _validationMethods = this.validationMethods(it);
    _builder.append(_validationMethods);
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    CharSequence _json = this.toJson(it);
    _builder.append(_json);
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    CharSequence _createUrlArgs = this.createUrlArgs(it);
    _builder.append(_createUrlArgs);
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    CharSequence _createCompositeIdentifier = this.createCompositeIdentifier(it);
    _builder.append(_createCompositeIdentifier);
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    CharSequence _supportsHookSubscribers = this.supportsHookSubscribers(it);
    _builder.append(_supportsHookSubscribers);
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    {
      boolean _isSkipHookSubscribers = it.isSkipHookSubscribers();
      boolean _not = (!_isSkipHookSubscribers);
      if (_not) {
        CharSequence _hookAreaPrefix = this.getHookAreaPrefix(it);
        _builder.append(_hookAreaPrefix);
        _builder.newLineIfNotEmpty();
        _builder.newLine();
      }
    }
    CharSequence _relatedObjectsImpl = this.relatedObjectsImpl(it, app);
    _builder.append(_relatedObjectsImpl);
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    CharSequence _stringImpl = this.toStringImpl(it, app);
    _builder.append(_stringImpl);
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    CharSequence _cloneImpl = this.cloneImpl(it, app, thProp);
    _builder.append(_cloneImpl);
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  public CharSequence validationMethods(final DataObject it) {
    StringConcatenation _builder = new StringConcatenation();
    final ValidationConstraints thVal = new ValidationConstraints();
    _builder.newLineIfNotEmpty();
    {
      boolean _hasUserFieldsEntity = this._modelExtensions.hasUserFieldsEntity(it);
      if (_hasUserFieldsEntity) {
        {
          Iterable<UserField> _userFieldsEntity = this._modelExtensions.getUserFieldsEntity(it);
          for(final UserField userField : _userFieldsEntity) {
            _builder.newLine();
            CharSequence _validationMethods = thVal.validationMethods(userField);
            _builder.append(_validationMethods);
            _builder.newLineIfNotEmpty();
          }
        }
      }
    }
    final Iterable<TimeField> timeFields = Iterables.<TimeField>filter(it.getFields(), TimeField.class);
    _builder.newLineIfNotEmpty();
    {
      boolean _isEmpty = IterableExtensions.isEmpty(timeFields);
      boolean _not = (!_isEmpty);
      if (_not) {
        {
          for(final TimeField timeField : timeFields) {
            _builder.newLine();
            CharSequence _validationMethods_1 = thVal.validationMethods(timeField);
            _builder.append(_validationMethods_1);
            _builder.newLineIfNotEmpty();
          }
        }
      }
    }
    return _builder;
  }
  
  private CharSequence propertyChangedListener(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _hasNotifyPolicy = this._modelExtensions.hasNotifyPolicy(it);
      if (_hasNotifyPolicy) {
        _builder.append("/**");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Adds a property change listener.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @param PropertyChangedListener $listener The listener to be added");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
        _builder.append("public function addPropertyChangedListener(PropertyChangedListener $listener)");
        _builder.newLine();
        _builder.append("{");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$this->_propertyChangedListeners[] = $listener;");
        _builder.newLine();
        _builder.append("}");
        _builder.newLine();
        _builder.newLine();
        _builder.append("/**");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Notify all registered listeners about a changed property.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @param String $propName Name of property which has been changed");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @param mixed  $oldValue The old property value");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @param mixed  $newValue The new property value");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
        _builder.append("protected function _onPropertyChanged($propName, $oldValue, $newValue)");
        _builder.newLine();
        _builder.append("{");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("if ($this->_propertyChangedListeners) {");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("foreach ($this->_propertyChangedListeners as $listener) {");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("$listener->propertyChanged($this, $propName, $oldValue, $newValue);");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
        _builder.append("}");
        _builder.newLine();
        _builder.newLine();
      }
    }
    return _builder;
  }
  
  private CharSequence getTitleFromDisplayPattern(final Entity it, final Application app) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Returns the formatted title conforming to the display pattern");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* specified for this entity.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return string The display title");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function getTitleFromDisplayPattern()");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    {
      boolean _displayPatternContainsListField = this.displayPatternContainsListField(it);
      if (_displayPatternContainsListField) {
        _builder.append("    ");
        _builder.append("$listHelper = \\ServiceUtil::get(\'");
        String _appService = this._utils.appService(app);
        _builder.append(_appService, "    ");
        _builder.append(".listentries_helper\');");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
      }
    }
    _builder.append("    ");
    _builder.append("$formattedTitle = ");
    String _parseDisplayPattern = this.parseDisplayPattern(it);
    _builder.append(_parseDisplayPattern, "    ");
    _builder.append(";");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $formattedTitle;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private String parseDisplayPattern(final Entity it) {
    String _xblockexpression = null;
    {
      String result = "";
      final String[] patternParts = this.determineDisplayPatternParts(it);
      for (final String patternPart : patternParts) {
        {
          boolean _notEquals = (!Objects.equal(result, ""));
          if (_notEquals) {
            result = result.concat(("\n" + "        . "));
          }
          CharSequence formattedPart = "";
          final Function1<EntityField, Boolean> _function = (EntityField it_1) -> {
            String _name = it_1.getName();
            return Boolean.valueOf(Objects.equal(_name, patternPart));
          };
          Iterable<EntityField> matchedFields = IterableExtensions.<EntityField>filter(it.getFields(), _function);
          boolean _isEmpty = IterableExtensions.isEmpty(matchedFields);
          boolean _not = (!_isEmpty);
          if (_not) {
            EntityField _head = IterableExtensions.<EntityField>head(matchedFields);
            String _firstUpper = StringExtensions.toFirstUpper(patternPart);
            String _plus = ("$this->get" + _firstUpper);
            String _plus_1 = (_plus + "()");
            formattedPart = this.formatFieldValue(_head, _plus_1);
          } else {
            if ((it.isGeographical() && Collections.<String>unmodifiableList(CollectionLiterals.<String>newArrayList("latitude", "longitude")).contains(patternPart))) {
              String _firstUpper_1 = StringExtensions.toFirstUpper(patternPart);
              String _plus_2 = ("number_format($this->get" + _firstUpper_1);
              String _plus_3 = (_plus_2 + "(), 7, \'.\', \'\')");
              formattedPart = _plus_3;
            } else {
              String _replace = patternPart.replace("\'", "");
              String _plus_4 = ("\'" + _replace);
              String _plus_5 = (_plus_4 + "\'");
              formattedPart = _plus_5;
            }
          }
          result = result.concat(formattedPart.toString());
        }
      }
      _xblockexpression = result;
    }
    return _xblockexpression;
  }
  
  private boolean displayPatternContainsListField(final Entity it) {
    boolean _xblockexpression = false;
    {
      boolean _hasListFieldsEntity = this._modelExtensions.hasListFieldsEntity(it);
      boolean _not = (!_hasListFieldsEntity);
      if (_not) {
        return false;
      }
      final String[] patternParts = this.determineDisplayPatternParts(it);
      for (final String patternPart : patternParts) {
        {
          final Function1<EntityField, Boolean> _function = (EntityField it_1) -> {
            String _name = it_1.getName();
            return Boolean.valueOf(Objects.equal(_name, patternPart));
          };
          Iterable<EntityField> matchedFields = IterableExtensions.<EntityField>filter(it.getFields(), _function);
          boolean _isEmpty = IterableExtensions.isEmpty(matchedFields);
          boolean _not_1 = (!_isEmpty);
          if (_not_1) {
            EntityField _head = IterableExtensions.<EntityField>head(matchedFields);
            if ((_head instanceof ListField)) {
              return true;
            }
          }
        }
      }
      _xblockexpression = false;
    }
    return _xblockexpression;
  }
  
  private String[] determineDisplayPatternParts(final Entity it) {
    String[] _xblockexpression = null;
    {
      String usedDisplayPattern = it.getDisplayPattern();
      if ((this._modelInheritanceExtensions.isInheriting(it) && ((null == usedDisplayPattern) || Objects.equal(usedDisplayPattern, "")))) {
        DataObject _parentType = this._modelInheritanceExtensions.parentType(it);
        if ((_parentType instanceof Entity)) {
          DataObject _parentType_1 = this._modelInheritanceExtensions.parentType(it);
          usedDisplayPattern = ((Entity) _parentType_1).getDisplayPattern();
        }
      }
      if (((null == usedDisplayPattern) || Objects.equal(usedDisplayPattern, ""))) {
        usedDisplayPattern = this._formattingExtensions.formatForDisplay(it.getName());
      }
      _xblockexpression = usedDisplayPattern.split("#");
    }
    return _xblockexpression;
  }
  
  private CharSequence formatFieldValue(final EntityField it, final CharSequence value) {
    CharSequence _switchResult = null;
    boolean _matched = false;
    if (it instanceof DecimalField) {
      _matched=true;
      StringConcatenation _builder = new StringConcatenation();
      _builder.append("\\DataUtil::format");
      {
        boolean _isCurrency = ((DecimalField)it).isCurrency();
        if (_isCurrency) {
          _builder.append("Currency(");
          _builder.append(value);
          _builder.append(")");
        } else {
          _builder.append("Number(");
          _builder.append(value);
          _builder.append(", 2)");
        }
      }
      _switchResult = _builder;
    }
    if (!_matched) {
      if (it instanceof FloatField) {
        _matched=true;
        StringConcatenation _builder = new StringConcatenation();
        _builder.append("\\DataUtil::format");
        {
          boolean _isCurrency = ((FloatField)it).isCurrency();
          if (_isCurrency) {
            _builder.append("Currency(");
            _builder.append(value);
            _builder.append(")");
          } else {
            _builder.append("Number(");
            _builder.append(value);
            _builder.append(", 2)");
          }
        }
        _switchResult = _builder;
      }
    }
    if (!_matched) {
      if (it instanceof UserField) {
        _matched=true;
        StringConcatenation _builder = new StringConcatenation();
        _builder.append("(");
        _builder.append(value);
        _builder.append(" ? ");
        _builder.append(value);
        _builder.append("->getUname() : \'\')");
        _switchResult = _builder;
      }
    }
    if (!_matched) {
      if (it instanceof ListField) {
        _matched=true;
        StringConcatenation _builder = new StringConcatenation();
        _builder.append("$listHelper->resolve(");
        _builder.append(value);
        _builder.append(", \'");
        String _formatForCode = this._formattingExtensions.formatForCode(((ListField)it).getEntity().getName());
        _builder.append(_formatForCode);
        _builder.append("\', \'");
        String _formatForCode_1 = this._formattingExtensions.formatForCode(((ListField)it).getName());
        _builder.append(_formatForCode_1);
        _builder.append("\')");
        _switchResult = _builder;
      }
    }
    if (!_matched) {
      if (it instanceof DateField) {
        _matched=true;
        StringConcatenation _builder = new StringConcatenation();
        _builder.append("\\DateUtil::formatDatetime(");
        _builder.append(value);
        _builder.append(", \'datebrief\')");
        _switchResult = _builder;
      }
    }
    if (!_matched) {
      if (it instanceof DatetimeField) {
        _matched=true;
        StringConcatenation _builder = new StringConcatenation();
        _builder.append("\\DateUtil::formatDatetime(");
        _builder.append(value);
        _builder.append(", \'datetimebrief\')");
        _switchResult = _builder;
      }
    }
    if (!_matched) {
      if (it instanceof TimeField) {
        _matched=true;
        StringConcatenation _builder = new StringConcatenation();
        _builder.append("\\DateUtil::formatDatetime(");
        _builder.append(value);
        _builder.append(", \'timebrief\')");
        _switchResult = _builder;
      }
    }
    if (!_matched) {
      _switchResult = value;
    }
    return _switchResult;
  }
  
  private CharSequence toJson(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Return entity data in JSON format.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return string JSON-encoded data");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function toJson()");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return json_encode($this->toArray());");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence createUrlArgs(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Creates url arguments array for easy creation of display urls.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return array The resulting arguments list");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function createUrlArgs()");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$args = [];");
    _builder.newLine();
    _builder.newLine();
    {
      boolean _hasCompositeKeys = this._modelExtensions.hasCompositeKeys(it);
      if (_hasCompositeKeys) {
        {
          Iterable<DerivedField> _primaryKeyFields = this._modelExtensions.getPrimaryKeyFields(it);
          for(final DerivedField pkField : _primaryKeyFields) {
            _builder.append("    ");
            _builder.append("$args[\'");
            String _formatForCode = this._formattingExtensions.formatForCode(pkField.getName());
            _builder.append(_formatForCode, "    ");
            _builder.append("\'] = $this[\'");
            String _formatForCode_1 = this._formattingExtensions.formatForCode(pkField.getName());
            _builder.append(_formatForCode_1, "    ");
            _builder.append("\'];");
            _builder.newLineIfNotEmpty();
          }
        }
      } else {
        _builder.append("    ");
        _builder.append("$args[\'");
        String _formatForCode_2 = this._formattingExtensions.formatForCode(this._modelExtensions.getFirstPrimaryKey(it).getName());
        _builder.append(_formatForCode_2, "    ");
        _builder.append("\'] = $this[\'");
        String _formatForCode_3 = this._formattingExtensions.formatForCode(this._modelExtensions.getFirstPrimaryKey(it).getName());
        _builder.append(_formatForCode_3, "    ");
        _builder.append("\'];");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (property_exists($this, \'slug\')) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$args[\'slug\'] = $this[\'slug\'];");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $args;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence createCompositeIdentifier(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Create concatenated identifier string (for composite keys).");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return String concatenated identifiers");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function createCompositeIdentifier()");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    {
      boolean _hasCompositeKeys = this._modelExtensions.hasCompositeKeys(it);
      if (_hasCompositeKeys) {
        _builder.append("    ");
        _builder.append("$itemId = \'\';");
        _builder.newLine();
        {
          Iterable<DerivedField> _primaryKeyFields = this._modelExtensions.getPrimaryKeyFields(it);
          for(final DerivedField pkField : _primaryKeyFields) {
            _builder.append("    ");
            _builder.append("$itemId .= ((!empty($itemId)) ? \'_\' : \'\') . $this[\'");
            String _formatForCode = this._formattingExtensions.formatForCode(pkField.getName());
            _builder.append(_formatForCode, "    ");
            _builder.append("\'];");
            _builder.newLineIfNotEmpty();
          }
        }
      } else {
        _builder.append("    ");
        _builder.append("$itemId = $this[\'");
        String _formatForCode_1 = this._formattingExtensions.formatForCode(this._modelExtensions.getFirstPrimaryKey(it).getName());
        _builder.append(_formatForCode_1, "    ");
        _builder.append("\'];");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $itemId;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence supportsHookSubscribers(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Determines whether this entity supports hook subscribers or not.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return boolean");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function supportsHookSubscribers()");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return ");
    {
      boolean _isSkipHookSubscribers = it.isSkipHookSubscribers();
      boolean _not = (!_isSkipHookSubscribers);
      if (_not) {
        _builder.append("true");
      } else {
        _builder.append("false");
      }
    }
    _builder.append(";");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence getHookAreaPrefix(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Return lower case name of multiple items needed for hook areas.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return string");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function getHookAreaPrefix()");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return \'");
    String _formatForDB = this._formattingExtensions.formatForDB(this._utils.appName(it.getApplication()));
    _builder.append(_formatForDB, "    ");
    _builder.append(".ui_hooks.");
    String _formatForDB_1 = this._formattingExtensions.formatForDB(it.getNameMultiple());
    _builder.append(_formatForDB_1, "    ");
    _builder.append("\';");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence toStringImpl(final DataObject it, final Application app) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* ToString interceptor implementation.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* This method is useful for debugging purposes.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return string The output string for this entity");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function __toString()");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return \'");
    String _formatForDisplayCapital = this._formattingExtensions.formatForDisplayCapital(it.getName());
    _builder.append(_formatForDisplayCapital, "    ");
    _builder.append(" \' . $this->createCompositeIdentifier() . \': \' . $this->getTitleFromDisplayPattern();");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence relatedObjectsImpl(final DataObject it, final Application app) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Returns an array of all related objects that need to be persisted after clone.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* ");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param array $objects The objects are added to this array. Default: []");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* ");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return array of entity objects");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function getRelatedObjectsToPersist(&$objects = []) ");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    final Function1<JoinRelationship, Boolean> _function = (JoinRelationship it_1) -> {
      return Boolean.valueOf((!(it_1 instanceof ManyToManyRelationship)));
    };
    final Iterable<JoinRelationship> joinsIn = IterableExtensions.<JoinRelationship>filter(this._modelJoinExtensions.getIncomingJoinRelationsForCloning(it), _function);
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    final Function1<JoinRelationship, Boolean> _function_1 = (JoinRelationship it_1) -> {
      return Boolean.valueOf((!(it_1 instanceof ManyToManyRelationship)));
    };
    final Iterable<JoinRelationship> joinsOut = IterableExtensions.<JoinRelationship>filter(this._modelJoinExtensions.getOutgoingJoinRelationsForCloning(it), _function_1);
    _builder.newLineIfNotEmpty();
    {
      if (((!IterableExtensions.isEmpty(joinsIn)) || (!IterableExtensions.isEmpty(joinsOut)))) {
        {
          ArrayList<Boolean> _newArrayList = CollectionLiterals.<Boolean>newArrayList(Boolean.valueOf(false), Boolean.valueOf(true));
          for(final Boolean out : _newArrayList) {
            {
              Iterable<JoinRelationship> _xifexpression = null;
              if ((out).booleanValue()) {
                _xifexpression = joinsOut;
              } else {
                _xifexpression = joinsIn;
              }
              for(final JoinRelationship relation : _xifexpression) {
                _builder.append("    ");
                String aliasName = this._namingExtensions.getRelationAliasName(relation, out);
                _builder.newLineIfNotEmpty();
                _builder.append("    ");
                _builder.append("foreach ($this->");
                _builder.append(aliasName, "    ");
                _builder.append(" as $rel) {");
                _builder.newLineIfNotEmpty();
                _builder.append("    ");
                _builder.append("    ");
                _builder.append("if (!in_array($rel, $objects, true)) {");
                _builder.newLine();
                _builder.append("    ");
                _builder.append("        ");
                _builder.append("$objects[] = $rel;");
                _builder.newLine();
                _builder.append("    ");
                _builder.append("        ");
                _builder.append("$rel->getRelatedObjectsToPersist($objects);");
                _builder.newLine();
                _builder.append("    ");
                _builder.append("    ");
                _builder.append("}");
                _builder.newLine();
                _builder.append("    ");
                _builder.append("}");
                _builder.newLine();
              }
            }
          }
        }
        _builder.newLine();
        _builder.append("    ");
        _builder.append("return $objects;");
        _builder.newLine();
      } else {
        _builder.append("    ");
        _builder.append("return [];");
        _builder.newLine();
      }
    }
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence cloneImpl(final DataObject it, final Application app, final Property thProp) {
    StringConcatenation _builder = new StringConcatenation();
    final Iterable<JoinRelationship> joinsIn = this._modelJoinExtensions.getIncomingJoinRelationsForCloning(it);
    _builder.newLineIfNotEmpty();
    final Iterable<JoinRelationship> joinsOut = this._modelJoinExtensions.getOutgoingJoinRelationsForCloning(it);
    _builder.newLineIfNotEmpty();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Clone interceptor implementation.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* This method is for example called by the reuse functionality.");
    _builder.newLine();
    {
      if ((IterableExtensions.isEmpty(joinsIn) && IterableExtensions.isEmpty(joinsOut))) {
        _builder.append(" ");
        _builder.append("* Performs a quite simple shallow copy.");
        _builder.newLine();
      } else {
        _builder.append(" ");
        _builder.append("* Performs a deep copy.");
        _builder.newLine();
      }
    }
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* See also:");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* (1) http://docs.doctrine-project.org/en/latest/cookbook/implementing-wakeup-or-clone.html");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* (2) http://www.php.net/manual/en/language.oop5.cloning.php");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* (3) http://stackoverflow.com/questions/185934/how-do-i-create-a-copy-of-an-object-in-php");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function __clone()");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// if the entity has no identity do nothing, do NOT throw an exception");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!(");
    {
      Iterable<DerivedField> _primaryKeyFields = this._modelExtensions.getPrimaryKeyFields(it);
      boolean _hasElements = false;
      for(final DerivedField field : _primaryKeyFields) {
        if (!_hasElements) {
          _hasElements = true;
        } else {
          _builder.appendImmediate(" && ", "    ");
        }
        _builder.append("$this->");
        String _formatForCode = this._formattingExtensions.formatForCode(field.getName());
        _builder.append(_formatForCode, "    ");
      }
    }
    _builder.append(")) {");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("return;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// otherwise proceed");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// unset identifiers");
    _builder.newLine();
    {
      Iterable<DerivedField> _primaryKeyFields_1 = this._modelExtensions.getPrimaryKeyFields(it);
      for(final DerivedField field_1 : _primaryKeyFields_1) {
        _builder.append("    ");
        _builder.append("$this->set");
        String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(field_1.getName());
        _builder.append(_formatForCodeCapital, "    ");
        _builder.append("(");
        String _defaultFieldData = thProp.defaultFieldData(field_1);
        _builder.append(_defaultFieldData, "    ");
        _builder.append(");");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      Boolean _targets = this._utils.targets(app, "1.5");
      boolean _not = (!(_targets).booleanValue());
      if (_not) {
        _builder.newLine();
        _builder.append("    ");
        _builder.append("// reset workflow");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$this->resetWorkflow();");
        _builder.newLine();
      }
    }
    {
      boolean _hasUploadFieldsEntity = this._modelExtensions.hasUploadFieldsEntity(it);
      if (_hasUploadFieldsEntity) {
        _builder.newLine();
        _builder.append("    ");
        _builder.append("// reset upload fields");
        _builder.newLine();
        {
          Iterable<UploadField> _uploadFieldsEntity = this._modelExtensions.getUploadFieldsEntity(it);
          for(final UploadField field_2 : _uploadFieldsEntity) {
            _builder.append("    ");
            _builder.append("$this->set");
            String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(field_2.getName());
            _builder.append(_formatForCodeCapital_1, "    ");
            _builder.append("(null);");
            _builder.newLineIfNotEmpty();
            _builder.append("    ");
            _builder.append("$this->set");
            String _formatForCodeCapital_2 = this._formattingExtensions.formatForCodeCapital(field_2.getName());
            _builder.append(_formatForCodeCapital_2, "    ");
            _builder.append("Meta([]);");
            _builder.newLineIfNotEmpty();
            _builder.append("    ");
            _builder.append("$this->set");
            String _formatForCodeCapital_3 = this._formattingExtensions.formatForCodeCapital(field_2.getName());
            _builder.append(_formatForCodeCapital_3, "    ");
            _builder.append("Url(\'\');");
            _builder.newLineIfNotEmpty();
          }
        }
      }
    }
    {
      if (((it instanceof Entity) && ((Entity) it).isStandardFields())) {
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$this->setCreatedBy(null);");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$this->setCreatedDate(null);");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$this->setUpdatedBy(null);");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$this->setUpdatedDate(null);");
        _builder.newLine();
      }
    }
    _builder.newLine();
    {
      if (((!IterableExtensions.isEmpty(joinsIn)) || (!IterableExtensions.isEmpty(joinsOut)))) {
        _builder.append("    ");
        _builder.append("// handle related objects");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("// prevent shared references by doing a deep copy - see (2) and (3) for more information");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("// clone referenced objects only if a new record is necessary");
        _builder.newLine();
        {
          ArrayList<Boolean> _newArrayList = CollectionLiterals.<Boolean>newArrayList(Boolean.valueOf(false), Boolean.valueOf(true));
          for(final Boolean out : _newArrayList) {
            {
              Iterable<JoinRelationship> _xifexpression = null;
              if ((out).booleanValue()) {
                _xifexpression = joinsOut;
              } else {
                _xifexpression = joinsIn;
              }
              for(final JoinRelationship relation : _xifexpression) {
                _builder.append("    ");
                String aliasName = this._namingExtensions.getRelationAliasName(relation, out);
                _builder.newLineIfNotEmpty();
                _builder.append("    ");
                _builder.append("$collection = $this->");
                _builder.append(aliasName, "    ");
                _builder.append(";");
                _builder.newLineIfNotEmpty();
                _builder.append("    ");
                _builder.append("$this->");
                _builder.append(aliasName, "    ");
                _builder.append(" = new ArrayCollection();");
                _builder.newLineIfNotEmpty();
                _builder.append("    ");
                _builder.append("foreach ($collection as $rel) {");
                _builder.newLine();
                _builder.append("    ");
                _builder.append("    ");
                _builder.append("$this->add");
                String _formatForCodeCapital_4 = this._formattingExtensions.formatForCodeCapital(aliasName);
                _builder.append(_formatForCodeCapital_4, "        ");
                _builder.append("(");
                {
                  if ((!(relation instanceof ManyToManyRelationship))) {
                    _builder.append(" clone");
                  }
                }
                _builder.append(" $rel);");
                _builder.newLineIfNotEmpty();
                _builder.append("    ");
                _builder.append("}");
                _builder.newLine();
              }
            }
          }
        }
      }
    }
    {
      if ((it instanceof Entity)) {
        {
          boolean _isCategorisable = ((Entity)it).isCategorisable();
          if (_isCategorisable) {
            _builder.newLine();
            _builder.append("    ");
            _builder.append("// clone categories");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("$categories = $this->categories;");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("$this->categories = new ArrayCollection();");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("foreach ($categories as $c) {");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("$newCat = clone $c;");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("$this->categories->add($newCat);");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("$newCat->setEntity($this);");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("}");
            _builder.newLine();
          }
        }
        {
          boolean _isAttributable = ((Entity)it).isAttributable();
          if (_isAttributable) {
            _builder.newLine();
            _builder.append("    ");
            _builder.append("// clone attributes");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("$attributes = $this->attributes;");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("$this->attributes = new ArrayCollection();");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("foreach ($attributes as $a) {");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("$newAttr = clone $a;");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("$this->attributes->add($newAttr);");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("$newAttr->setEntity($this);");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("}");
            _builder.newLine();
          }
        }
      }
    }
    _builder.append("}");
    _builder.newLine();
    {
      if ((((it instanceof Entity) && ((Entity) it).isLoggable()) && this._modelExtensions.hasUploadFieldsEntity(it))) {
        _builder.newLine();
        _builder.append("/**");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Custom serialise method to process File objects during serialisation.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
        _builder.append("public function __sleep()");
        _builder.newLine();
        _builder.append("{");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$uploadFields = [\'");
        final Function1<UploadField, String> _function = (UploadField it_1) -> {
          return this._formattingExtensions.formatForCode(it_1.getName());
        };
        String _join = IterableExtensions.join(IterableExtensions.<UploadField, String>map(this._modelExtensions.getUploadFieldsEntity(it), _function), "\', \'");
        _builder.append(_join, "    ");
        _builder.append("\'];");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("foreach ($uploadFields as $uploadField) {");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("if ($this[$uploadField] instanceof File) {");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("$this[$uploadField] = $this[$uploadField]->getFilename();");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$ref = new \\ReflectionClass(__CLASS__);");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$props = $ref->getProperties();");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$serializeFields = [];");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("foreach ($props as $prop) {");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("$serializeFields[] = $prop->name;");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("return $serializeFields;");
        _builder.newLine();
        _builder.append("}");
        _builder.newLine();
      }
    }
    return _builder;
  }
  
  public CharSequence generate(final DataObject it, final Application app, final Property thProp) {
    if (it instanceof Entity) {
      return _generate((Entity)it, app, thProp);
    } else if (it != null) {
      return _generate(it, app, thProp);
    } else {
      throw new IllegalArgumentException("Unhandled parameter types: " +
        Arrays.<Object>asList(it, app, thProp).toString());
    }
  }
}
