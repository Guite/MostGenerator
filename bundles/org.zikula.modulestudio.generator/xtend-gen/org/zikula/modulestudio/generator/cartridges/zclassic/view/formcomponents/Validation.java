package org.zikula.modulestudio.generator.cartridges.zclassic.view.formcomponents;

import de.guite.modulestudio.metamodel.AbstractDateField;
import de.guite.modulestudio.metamodel.AbstractIntegerField;
import de.guite.modulestudio.metamodel.DateField;
import de.guite.modulestudio.metamodel.DatetimeField;
import de.guite.modulestudio.metamodel.DecimalField;
import de.guite.modulestudio.metamodel.DerivedField;
import de.guite.modulestudio.metamodel.EmailField;
import de.guite.modulestudio.metamodel.FloatField;
import de.guite.modulestudio.metamodel.ListField;
import de.guite.modulestudio.metamodel.StringField;
import de.guite.modulestudio.metamodel.TextField;
import de.guite.modulestudio.metamodel.TimeField;
import de.guite.modulestudio.metamodel.UploadField;
import de.guite.modulestudio.metamodel.UrlField;
import java.util.Arrays;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.xbase.lib.Extension;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class Validation {
  @Extension
  private FormattingExtensions _formattingExtensions = new FormattingExtensions();
  
  @Extension
  private ModelExtensions _modelExtensions = new ModelExtensions();
  
  @Extension
  private Utils _utils = new Utils();
  
  public CharSequence fieldValidationCssClass(final DerivedField it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _isUnique = it.isUnique();
      if (_isUnique) {
        _builder.append("validate-unique");
      }
    }
    {
      if (((null != it.getCssClass()) && (!it.getCssClass().equals("")))) {
        _builder.append(" ");
        String _cssClass = it.getCssClass();
        _builder.append(_cssClass);
      }
    }
    CharSequence _fieldValidationCssClassAdditions = this.fieldValidationCssClassAdditions(it);
    _builder.append(_fieldValidationCssClassAdditions);
    return _builder;
  }
  
  public CharSequence fieldValidationCssClassOptional(final UploadField it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _isUnique = it.isUnique();
      if (_isUnique) {
        _builder.append("validate-unique");
      }
    }
    {
      if (((null != it.getCssClass()) && (!it.getCssClass().equals("")))) {
        _builder.append(" ");
        String _cssClass = it.getCssClass();
        _builder.append(_cssClass);
      }
    }
    CharSequence _fieldValidationCssClassAdditions = this.fieldValidationCssClassAdditions(it);
    _builder.append(_fieldValidationCssClassAdditions);
    return _builder;
  }
  
  private CharSequence fieldValidationCssClassAdditions(final DerivedField it) {
    CharSequence _switchResult = null;
    boolean _matched = false;
    if (it instanceof AbstractIntegerField) {
      _matched=true;
      _switchResult = " validate-digits";
    }
    if (!_matched) {
      if (it instanceof DecimalField) {
        _matched=true;
        _switchResult = " validate-number";
      }
    }
    if (!_matched) {
      if (it instanceof FloatField) {
        _matched=true;
        _switchResult = " validate-number";
      }
    }
    if (!_matched) {
      if (it instanceof StringField) {
        boolean _isHtmlcolour = ((StringField)it).isHtmlcolour();
        if (_isHtmlcolour) {
          _matched=true;
          String _formatForDB = this._formattingExtensions.formatForDB(this._utils.appName(((StringField)it).getEntity().getApplication()));
          String _plus = (" validate-nospace validate-htmlcolour " + _formatForDB);
          _switchResult = (_plus + "ColourPicker");
        }
      }
    }
    if (!_matched) {
      if (it instanceof StringField) {
        boolean _isNospace = ((StringField)it).isNospace();
        if (_isNospace) {
          _matched=true;
          _switchResult = " validate-nospace";
        }
      }
    }
    if (!_matched) {
      if (it instanceof TextField) {
        boolean _isNospace = ((TextField)it).isNospace();
        if (_isNospace) {
          _matched=true;
          _switchResult = " validate-nospace";
        }
      }
    }
    if (!_matched) {
      if (it instanceof EmailField) {
        boolean _isNospace = ((EmailField)it).isNospace();
        if (_isNospace) {
          _matched=true;
          _switchResult = " validate-nospace validate-email";
        }
      }
    }
    if (!_matched) {
      if (it instanceof EmailField) {
        _matched=true;
        _switchResult = " validate-email";
      }
    }
    if (!_matched) {
      if (it instanceof UrlField) {
        boolean _isNospace = ((UrlField)it).isNospace();
        if (_isNospace) {
          _matched=true;
          _switchResult = " validate-nospace validate-url";
        }
      }
    }
    if (!_matched) {
      if (it instanceof UrlField) {
        _matched=true;
        _switchResult = " validate-url";
      }
    }
    if (!_matched) {
      if (it instanceof UploadField) {
        boolean _isNospace = ((UploadField)it).isNospace();
        if (_isNospace) {
          _matched=true;
          _switchResult = " validate-nospace validate-upload";
        }
      }
    }
    if (!_matched) {
      if (it instanceof UploadField) {
        _matched=true;
        _switchResult = " validate-upload";
      }
    }
    if (!_matched) {
      if (it instanceof ListField) {
        boolean _isNospace = ((ListField)it).isNospace();
        if (_isNospace) {
          _matched=true;
          _switchResult = " validate-nospace";
        }
      }
    }
    if (!_matched) {
      if (it instanceof ListField) {
        _matched=true;
        _switchResult = "";
      }
    }
    if (!_matched) {
      if (it instanceof TimeField) {
        _matched=true;
        _switchResult = this.fieldValidationCssClassAdditionsDefault(((AbstractDateField)it));
      }
    }
    if (!_matched) {
      if (it instanceof AbstractDateField) {
        _matched=true;
        StringConcatenation _builder = new StringConcatenation();
        CharSequence _fieldValidationCssClassAdditionsDefault = this.fieldValidationCssClassAdditionsDefault(((AbstractDateField)it));
        _builder.append(_fieldValidationCssClassAdditionsDefault);
        CharSequence _fieldValidationCssClassDateRange = this.fieldValidationCssClassDateRange(((AbstractDateField)it));
        _builder.append(_fieldValidationCssClassDateRange);
        _switchResult = _builder;
      }
    }
    return _switchResult;
  }
  
  private CharSequence fieldValidationCssClassAdditionsDefault(final AbstractDateField it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _isPast = it.isPast();
      if (_isPast) {
        _builder.append(" validate-");
        String _lowerCase = this._modelExtensions.fieldTypeAsString(it).toLowerCase();
        _builder.append(_lowerCase);
        _builder.append("-past");
      } else {
        boolean _isFuture = it.isFuture();
        if (_isFuture) {
          _builder.append(" validate-");
          String _lowerCase_1 = this._modelExtensions.fieldTypeAsString(it).toLowerCase();
          _builder.append(_lowerCase_1);
          _builder.append("-future");
        }
      }
    }
    return _builder;
  }
  
  private CharSequence _fieldValidationCssClassDateRange(final DatetimeField it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      if (((null != this._modelExtensions.getStartDateField(it.getEntity())) && (null != this._modelExtensions.getEndDateField(it.getEntity())))) {
        _builder.append(" validate-daterange-");
        String _formatForDB = this._formattingExtensions.formatForDB(it.getEntity().getName());
        _builder.append(_formatForDB);
      }
    }
    return _builder;
  }
  
  private CharSequence _fieldValidationCssClassDateRange(final DateField it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      if (((null != this._modelExtensions.getStartDateField(it.getEntity())) && (null != this._modelExtensions.getEndDateField(it.getEntity())))) {
        _builder.append(" validate-daterange-");
        String _formatForDB = this._formattingExtensions.formatForDB(it.getEntity().getName());
        _builder.append(_formatForDB);
      }
    }
    return _builder;
  }
  
  private CharSequence fieldValidationCssClassDateRange(final AbstractDateField it) {
    if (it instanceof DateField) {
      return _fieldValidationCssClassDateRange((DateField)it);
    } else if (it instanceof DatetimeField) {
      return _fieldValidationCssClassDateRange((DatetimeField)it);
    } else {
      throw new IllegalArgumentException("Unhandled parameter types: " +
        Arrays.<Object>asList(it).toString());
    }
  }
}
