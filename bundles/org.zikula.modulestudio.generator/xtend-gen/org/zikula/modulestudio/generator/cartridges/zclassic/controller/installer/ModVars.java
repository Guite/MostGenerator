package org.zikula.modulestudio.generator.cartridges.zclassic.controller.installer;

import com.google.common.base.Objects;
import de.guite.modulestudio.metamodel.BoolVar;
import de.guite.modulestudio.metamodel.IntVar;
import de.guite.modulestudio.metamodel.ListVar;
import de.guite.modulestudio.metamodel.ListVarItem;
import de.guite.modulestudio.metamodel.Variable;
import java.util.Arrays;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;

/**
 * Utility methods for the installer.
 */
@SuppressWarnings("all")
public class ModVars {
  @Extension
  private FormattingExtensions _formattingExtensions = new FormattingExtensions();
  
  @Extension
  private ModelExtensions _modelExtensions = new ModelExtensions();
  
  protected CharSequence _valDirect2Mod(final Variable it) {
    CharSequence _switchResult = null;
    boolean _matched = false;
    if (it instanceof BoolVar) {
      _matched=true;
      StringConcatenation _builder = new StringConcatenation();
      {
        if (((null != ((BoolVar)it).getValue()) && Objects.equal(((BoolVar)it).getValue(), "true"))) {
          _builder.append("true");
        } else {
          _builder.append("false");
        }
      }
      _switchResult = _builder;
    }
    if (!_matched) {
      if (it instanceof IntVar) {
        _matched=true;
        StringConcatenation _builder = new StringConcatenation();
        {
          if (((null != ((IntVar)it).getValue()) && (!Objects.equal(((IntVar)it).getValue(), "")))) {
            _builder.append("\'");
            String _value = ((IntVar)it).getValue();
            _builder.append(_value);
            _builder.append("\'");
          } else {
            _builder.append("0");
          }
        }
        _switchResult = _builder;
      }
    }
    if (!_matched) {
      if (it instanceof ListVar) {
        _matched=true;
        StringConcatenation _builder = new StringConcatenation();
        {
          boolean _isMultiple = ((ListVar)it).isMultiple();
          if (_isMultiple) {
            _builder.append("[");
          }
        }
        {
          Iterable<ListVarItem> _defaultItems = this._modelExtensions.getDefaultItems(((ListVar)it));
          boolean _hasElements = false;
          for(final ListVarItem item : _defaultItems) {
            if (!_hasElements) {
              _hasElements = true;
            } else {
              _builder.appendImmediate(", ", "");
            }
            CharSequence _valDirect2Mod = this.valDirect2Mod(item);
            _builder.append(_valDirect2Mod);
          }
        }
        {
          boolean _isMultiple_1 = ((ListVar)it).isMultiple();
          if (_isMultiple_1) {
            _builder.append("]");
          } else {
            if (((!((ListVar)it).isMultiple()) && IterableExtensions.isEmpty(this._modelExtensions.getDefaultItems(((ListVar)it))))) {
              _builder.append("\'\'");
            }
          }
        }
        _switchResult = _builder;
      }
    }
    if (!_matched) {
      String _xifexpression = null;
      String _value = it.getValue();
      boolean _tripleNotEquals = (null != _value);
      if (_tripleNotEquals) {
        _xifexpression = it.getValue();
      } else {
        _xifexpression = "";
      }
      String _plus = ("\'" + _xifexpression);
      _switchResult = (_plus + "\'");
    }
    return _switchResult;
  }
  
  protected CharSequence _valDirect2Mod(final ListVarItem it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append(" ");
    _builder.append("\'");
    String _formatForCode = this._formattingExtensions.formatForCode(it.getName());
    _builder.append(_formatForCode, " ");
    _builder.append("\' ");
    return _builder;
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
}
