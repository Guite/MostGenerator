package org.zikula.modulestudio.generator.cartridges.zclassic.controller.installer;

import com.google.common.base.Objects;
import com.google.inject.Inject;
import de.guite.modulestudio.metamodel.modulestudio.BoolVar;
import de.guite.modulestudio.metamodel.modulestudio.IntVar;
import de.guite.modulestudio.metamodel.modulestudio.ListVar;
import de.guite.modulestudio.metamodel.modulestudio.ListVarItem;
import de.guite.modulestudio.metamodel.modulestudio.Variable;
import java.util.Arrays;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;

/**
 * Utility methods for the installer.
 */
@SuppressWarnings("all")
public class ModVars {
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
  
  public CharSequence valFromSession(final Variable it) {
    CharSequence _switchResult = null;
    boolean _matched = false;
    if (!_matched) {
      if (it instanceof ListVar) {
        final ListVar _listVar = (ListVar)it;
        _matched=true;
        StringConcatenation _builder = new StringConcatenation();
        {
          boolean _isMultiple = _listVar.isMultiple();
          if (_isMultiple) {
            _builder.append("serialize(");
          }
        }
        _builder.append("$sessionValue");
        {
          boolean _isMultiple_1 = _listVar.isMultiple();
          if (_isMultiple_1) {
            _builder.append(")");
          }
        }
        _switchResult = _builder;
      }
    }
    if (!_matched) {
      StringConcatenation _builder = new StringConcatenation();
      _builder.append("$sessionValue");
      _switchResult = _builder;
    }
    return _switchResult;
  }
  
  protected CharSequence _valSession2Mod(final Variable it) {
    CharSequence _switchResult = null;
    boolean _matched = false;
    if (!_matched) {
      if (it instanceof BoolVar) {
        final BoolVar _boolVar = (BoolVar)it;
        _matched=true;
        StringConcatenation _builder = new StringConcatenation();
        {
          boolean _and = false;
          String _value = _boolVar.getValue();
          boolean _tripleNotEquals = (_value != null);
          if (!_tripleNotEquals) {
            _and = false;
          } else {
            String _value_1 = _boolVar.getValue();
            boolean _equals = Objects.equal(_value_1, "true");
            _and = (_tripleNotEquals && _equals);
          }
          if (_and) {
            _builder.append("true");
          } else {
            _builder.append("false");
          }
        }
        _switchResult = _builder;
      }
    }
    if (!_matched) {
      if (it instanceof IntVar) {
        final IntVar _intVar = (IntVar)it;
        _matched=true;
        StringConcatenation _builder = new StringConcatenation();
        {
          boolean _and = false;
          String _value = _intVar.getValue();
          boolean _tripleNotEquals = (_value != null);
          if (!_tripleNotEquals) {
            _and = false;
          } else {
            String _value_1 = _intVar.getValue();
            boolean _notEquals = (!Objects.equal(_value_1, ""));
            _and = (_tripleNotEquals && _notEquals);
          }
          if (_and) {
            String _value_2 = _intVar.getValue();
            _builder.append(_value_2, "");
          } else {
            _builder.append("0");
          }
        }
        _switchResult = _builder;
      }
    }
    if (!_matched) {
      if (it instanceof ListVar) {
        final ListVar _listVar = (ListVar)it;
        _matched=true;
        StringConcatenation _builder = new StringConcatenation();
        {
          boolean _isMultiple = _listVar.isMultiple();
          if (_isMultiple) {
            _builder.append("array(");
          }
        }
        {
          Iterable<ListVarItem> _defaultItems = this._modelExtensions.getDefaultItems(_listVar);
          boolean _hasElements = false;
          for(final ListVarItem item : _defaultItems) {
            if (!_hasElements) {
              _hasElements = true;
            } else {
              _builder.appendImmediate(", ", "");
            }
            CharSequence _valSession2Mod = this.valSession2Mod(item);
            _builder.append(_valSession2Mod, "");
          }
        }
        {
          boolean _isMultiple_1 = _listVar.isMultiple();
          if (_isMultiple_1) {
            _builder.append(")");
          }
        }
        _switchResult = _builder;
      }
    }
    if (!_matched) {
      String _value = it.getValue();
      String _plus = ("\'" + _value);
      String _plus_1 = (_plus + "\'");
      _switchResult = _plus_1;
    }
    return _switchResult;
  }
  
  protected CharSequence _valSession2Mod(final ListVarItem it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _isDefault = it.isDefault();
      boolean _equals = (_isDefault == true);
      if (_equals) {
        _builder.append("\'");
        String _name = it.getName();
        String _formatForCode = this._formattingExtensions.formatForCode(_name);
        _builder.append(_formatForCode, "");
        _builder.append("\'");
      }
    }
    return _builder;
  }
  
  protected CharSequence _valDirect2Mod(final Variable it) {
    CharSequence _switchResult = null;
    boolean _matched = false;
    if (!_matched) {
      if (it instanceof BoolVar) {
        final BoolVar _boolVar = (BoolVar)it;
        _matched=true;
        StringConcatenation _builder = new StringConcatenation();
        {
          boolean _and = false;
          String _value = _boolVar.getValue();
          boolean _tripleNotEquals = (_value != null);
          if (!_tripleNotEquals) {
            _and = false;
          } else {
            String _value_1 = _boolVar.getValue();
            boolean _equals = Objects.equal(_value_1, "true");
            _and = (_tripleNotEquals && _equals);
          }
          if (_and) {
            _builder.append("true");
          } else {
            _builder.append("false");
          }
        }
        _switchResult = _builder;
      }
    }
    if (!_matched) {
      if (it instanceof IntVar) {
        final IntVar _intVar = (IntVar)it;
        _matched=true;
        StringConcatenation _builder = new StringConcatenation();
        {
          boolean _and = false;
          String _value = _intVar.getValue();
          boolean _tripleNotEquals = (_value != null);
          if (!_tripleNotEquals) {
            _and = false;
          } else {
            String _value_1 = _intVar.getValue();
            boolean _notEquals = (!Objects.equal(_value_1, ""));
            _and = (_tripleNotEquals && _notEquals);
          }
          if (_and) {
            String _value_2 = _intVar.getValue();
            _builder.append(_value_2, "");
          } else {
            _builder.append("0");
          }
        }
        _switchResult = _builder;
      }
    }
    if (!_matched) {
      if (it instanceof ListVar) {
        final ListVar _listVar = (ListVar)it;
        _matched=true;
        StringConcatenation _builder = new StringConcatenation();
        {
          boolean _isMultiple = _listVar.isMultiple();
          if (_isMultiple) {
            _builder.append("array(");
          }
        }
        {
          Iterable<ListVarItem> _defaultItems = this._modelExtensions.getDefaultItems(_listVar);
          boolean _hasElements = false;
          for(final ListVarItem item : _defaultItems) {
            if (!_hasElements) {
              _hasElements = true;
            } else {
              _builder.appendImmediate(", ", "");
            }
            CharSequence _valDirect2Mod = this.valDirect2Mod(item);
            _builder.append(_valDirect2Mod, "");
          }
        }
        {
          boolean _isMultiple_1 = _listVar.isMultiple();
          if (_isMultiple_1) {
            _builder.append(")");
          }
        }
        _switchResult = _builder;
      }
    }
    if (!_matched) {
      String _xifexpression = null;
      String _value = it.getValue();
      boolean _tripleNotEquals = (_value != null);
      if (_tripleNotEquals) {
        String _value_1 = it.getValue();
        _xifexpression = _value_1;
      } else {
        _xifexpression = "";
      }
      String _plus = ("\'" + _xifexpression);
      String _plus_1 = (_plus + "\'");
      _switchResult = _plus_1;
    }
    return _switchResult;
  }
  
  protected CharSequence _valDirect2Mod(final ListVarItem it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append(" ");
    _builder.append("\'");
    String _name = it.getName();
    String _formatForCode = this._formattingExtensions.formatForCode(_name);
    _builder.append(_formatForCode, " ");
    _builder.append("\' ");
    return _builder;
  }
  
  protected CharSequence _valForm2SessionDefault(final Variable it) {
    CharSequence _switchResult = null;
    boolean _matched = false;
    if (!_matched) {
      if (it instanceof ListVar) {
        final ListVar _listVar = (ListVar)it;
        _matched=true;
        StringConcatenation _builder = new StringConcatenation();
        {
          boolean _isMultiple = _listVar.isMultiple();
          if (_isMultiple) {
            _builder.append("serialize(array(");
          }
        }
        {
          Iterable<ListVarItem> _defaultItems = this._modelExtensions.getDefaultItems(_listVar);
          boolean _hasElements = false;
          for(final ListVarItem item : _defaultItems) {
            if (!_hasElements) {
              _hasElements = true;
            } else {
              _builder.appendImmediate(", ", "");
            }
            CharSequence _valForm2SessionDefault = this.valForm2SessionDefault(item);
            _builder.append(_valForm2SessionDefault, "");
          }
        }
        {
          boolean _isMultiple_1 = _listVar.isMultiple();
          if (_isMultiple_1) {
            _builder.append("))");
          }
        }
        _switchResult = _builder;
      }
    }
    if (!_matched) {
      String _value = it.getValue();
      String _formatForCode = this._formattingExtensions.formatForCode(_value);
      String _plus = ("\'" + _formatForCode);
      String _plus_1 = (_plus + "\'");
      _switchResult = _plus_1;
    }
    return _switchResult;
  }
  
  protected CharSequence _valForm2SessionDefault(final ListVarItem it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append(" ");
    _builder.append("\'");
    String _name = it.getName();
    String _formatForCode = this._formattingExtensions.formatForCode(_name);
    _builder.append(_formatForCode, " ");
    _builder.append("\' ");
    return _builder;
  }
  
  public CharSequence valSession2Mod(final EObject it) {
    if (it instanceof Variable) {
      return _valSession2Mod((Variable)it);
    } else if (it instanceof ListVarItem) {
      return _valSession2Mod((ListVarItem)it);
    } else {
      throw new IllegalArgumentException("Unhandled parameter types: " +
        Arrays.<Object>asList(it).toString());
    }
  }
  
  public CharSequence valDirect2Mod(final EObject it) {
    if (it instanceof Variable) {
      return _valDirect2Mod((Variable)it);
    } else if (it instanceof ListVarItem) {
      return _valDirect2Mod((ListVarItem)it);
    } else {
      throw new IllegalArgumentException("Unhandled parameter types: " +
        Arrays.<Object>asList(it).toString());
    }
  }
  
  public CharSequence valForm2SessionDefault(final EObject it) {
    if (it instanceof Variable) {
      return _valForm2SessionDefault((Variable)it);
    } else if (it instanceof ListVarItem) {
      return _valForm2SessionDefault((ListVarItem)it);
    } else {
      throw new IllegalArgumentException("Unhandled parameter types: " +
        Arrays.<Object>asList(it).toString());
    }
  }
}
