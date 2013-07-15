package org.zikula.modulestudio.generator.cartridges.zclassic.view.formcomponents;

import com.google.inject.Inject;
import de.guite.modulestudio.metamodel.modulestudio.AbstractDateField;
import de.guite.modulestudio.metamodel.modulestudio.AbstractIntegerField;
import de.guite.modulestudio.metamodel.modulestudio.AbstractStringField;
import de.guite.modulestudio.metamodel.modulestudio.Application;
import de.guite.modulestudio.metamodel.modulestudio.DateField;
import de.guite.modulestudio.metamodel.modulestudio.DatetimeField;
import de.guite.modulestudio.metamodel.modulestudio.DecimalField;
import de.guite.modulestudio.metamodel.modulestudio.DerivedField;
import de.guite.modulestudio.metamodel.modulestudio.EmailField;
import de.guite.modulestudio.metamodel.modulestudio.Entity;
import de.guite.modulestudio.metamodel.modulestudio.FloatField;
import de.guite.modulestudio.metamodel.modulestudio.ListField;
import de.guite.modulestudio.metamodel.modulestudio.Models;
import de.guite.modulestudio.metamodel.modulestudio.StringField;
import de.guite.modulestudio.metamodel.modulestudio.UploadField;
import de.guite.modulestudio.metamodel.modulestudio.UrlField;
import de.guite.modulestudio.metamodel.modulestudio.UserField;
import java.util.Arrays;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class Validation {
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
  
  protected CharSequence _mandatoryValidationMessage(final DerivedField it, final String idSuffix) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _isMandatory = it.isMandatory();
      if (_isMandatory) {
        _builder.append("{");
        Entity _entity = it.getEntity();
        Models _container = _entity.getContainer();
        Application _application = _container.getApplication();
        String _appName = this._utils.appName(_application);
        String _formatForDB = this._formattingExtensions.formatForDB(_appName);
        _builder.append(_formatForDB, "");
        _builder.append("ValidationError id=");
        String _name = it.getName();
        String _formatForCode = this._formattingExtensions.formatForCode(_name);
        String _templateIdWithSuffix = this._utils.templateIdWithSuffix(_formatForCode, idSuffix);
        _builder.append(_templateIdWithSuffix, "");
        _builder.append(" class=\'required\'}");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      boolean _isUnique = it.isUnique();
      if (_isUnique) {
        _builder.append("{");
        Entity _entity_1 = it.getEntity();
        Models _container_1 = _entity_1.getContainer();
        Application _application_1 = _container_1.getApplication();
        String _appName_1 = this._utils.appName(_application_1);
        String _formatForDB_1 = this._formattingExtensions.formatForDB(_appName_1);
        _builder.append(_formatForDB_1, "");
        _builder.append("ValidationError id=");
        String _name_1 = it.getName();
        String _formatForCode_1 = this._formattingExtensions.formatForCode(_name_1);
        String _templateIdWithSuffix_1 = this._utils.templateIdWithSuffix(_formatForCode_1, idSuffix);
        _builder.append(_templateIdWithSuffix_1, "");
        _builder.append(" class=\'validate-unique\'}");
        _builder.newLineIfNotEmpty();
      }
    }
    return _builder;
  }
  
  protected CharSequence _mandatoryValidationMessage(final ListField it, final String idSuffix) {
    return null;
  }
  
  protected CharSequence _additionalValidationMessages(final DerivedField it, final String idSuffix) {
    return null;
  }
  
  protected CharSequence _additionalValidationMessages(final AbstractIntegerField it, final String idSuffix) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{");
    Entity _entity = it.getEntity();
    Models _container = _entity.getContainer();
    Application _application = _container.getApplication();
    String _appName = this._utils.appName(_application);
    String _formatForDB = this._formattingExtensions.formatForDB(_appName);
    _builder.append(_formatForDB, "");
    _builder.append("ValidationError id=");
    String _name = it.getName();
    String _formatForCode = this._formattingExtensions.formatForCode(_name);
    String _templateIdWithSuffix = this._utils.templateIdWithSuffix(_formatForCode, idSuffix);
    _builder.append(_templateIdWithSuffix, "");
    _builder.append(" class=\'validate-digits\'}");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  protected CharSequence _additionalValidationMessages(final UserField it, final String idSuffix) {
    StringConcatenation _builder = new StringConcatenation();
    return _builder;
  }
  
  protected CharSequence _additionalValidationMessages(final DecimalField it, final String idSuffix) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{");
    Entity _entity = it.getEntity();
    Models _container = _entity.getContainer();
    Application _application = _container.getApplication();
    String _appName = this._utils.appName(_application);
    String _formatForDB = this._formattingExtensions.formatForDB(_appName);
    _builder.append(_formatForDB, "");
    _builder.append("ValidationError id=");
    String _name = it.getName();
    String _formatForCode = this._formattingExtensions.formatForCode(_name);
    String _templateIdWithSuffix = this._utils.templateIdWithSuffix(_formatForCode, idSuffix);
    _builder.append(_templateIdWithSuffix, "");
    _builder.append(" class=\'validate-number\'}");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  protected CharSequence _additionalValidationMessages(final FloatField it, final String idSuffix) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{");
    Entity _entity = it.getEntity();
    Models _container = _entity.getContainer();
    Application _application = _container.getApplication();
    String _appName = this._utils.appName(_application);
    String _formatForDB = this._formattingExtensions.formatForDB(_appName);
    _builder.append(_formatForDB, "");
    _builder.append("ValidationError id=");
    String _name = it.getName();
    String _formatForCode = this._formattingExtensions.formatForCode(_name);
    String _templateIdWithSuffix = this._utils.templateIdWithSuffix(_formatForCode, idSuffix);
    _builder.append(_templateIdWithSuffix, "");
    _builder.append(" class=\'validate-number\'}");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  protected CharSequence _additionalValidationMessages(final AbstractStringField it, final String idSuffix) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _isNospace = it.isNospace();
      if (_isNospace) {
        _builder.append("{");
        Entity _entity = it.getEntity();
        Models _container = _entity.getContainer();
        Application _application = _container.getApplication();
        String _appName = this._utils.appName(_application);
        String _formatForDB = this._formattingExtensions.formatForDB(_appName);
        _builder.append(_formatForDB, "");
        _builder.append("ValidationError id=");
        String _name = it.getName();
        String _formatForCode = this._formattingExtensions.formatForCode(_name);
        String _templateIdWithSuffix = this._utils.templateIdWithSuffix(_formatForCode, idSuffix);
        _builder.append(_templateIdWithSuffix, "");
        _builder.append(" class=\'validate-nospace\'}");
        _builder.newLineIfNotEmpty();
      }
    }
    return _builder;
  }
  
  protected CharSequence _additionalValidationMessages(final StringField it, final String idSuffix) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _and = false;
      boolean _and_1 = false;
      boolean _isNospace = it.isNospace();
      if (!_isNospace) {
        _and_1 = false;
      } else {
        boolean _isCountry = it.isCountry();
        boolean _not = (!_isCountry);
        _and_1 = (_isNospace && _not);
      }
      if (!_and_1) {
        _and = false;
      } else {
        boolean _isLanguage = it.isLanguage();
        boolean _not_1 = (!_isLanguage);
        _and = (_and_1 && _not_1);
      }
      if (_and) {
        _builder.append("{");
        Entity _entity = it.getEntity();
        Models _container = _entity.getContainer();
        Application _application = _container.getApplication();
        String _appName = this._utils.appName(_application);
        String _formatForDB = this._formattingExtensions.formatForDB(_appName);
        _builder.append(_formatForDB, "");
        _builder.append("ValidationError id=");
        String _name = it.getName();
        String _formatForCode = this._formattingExtensions.formatForCode(_name);
        String _templateIdWithSuffix = this._utils.templateIdWithSuffix(_formatForCode, idSuffix);
        _builder.append(_templateIdWithSuffix, "");
        _builder.append(" class=\'validate-nospace\'}");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      boolean _isHtmlcolour = it.isHtmlcolour();
      if (_isHtmlcolour) {
        _builder.append("{");
        Entity _entity_1 = it.getEntity();
        Models _container_1 = _entity_1.getContainer();
        Application _application_1 = _container_1.getApplication();
        String _appName_1 = this._utils.appName(_application_1);
        String _formatForDB_1 = this._formattingExtensions.formatForDB(_appName_1);
        _builder.append(_formatForDB_1, "");
        _builder.append("ValidationError id=");
        String _name_1 = it.getName();
        String _formatForCode_1 = this._formattingExtensions.formatForCode(_name_1);
        String _templateIdWithSuffix_1 = this._utils.templateIdWithSuffix(_formatForCode_1, idSuffix);
        _builder.append(_templateIdWithSuffix_1, "");
        _builder.append(" class=\'validate-htmlcolour\'}");
        _builder.newLineIfNotEmpty();
      }
    }
    return _builder;
  }
  
  protected CharSequence _additionalValidationMessages(final EmailField it, final String idSuffix) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{");
    Entity _entity = it.getEntity();
    Models _container = _entity.getContainer();
    Application _application = _container.getApplication();
    String _appName = this._utils.appName(_application);
    String _formatForDB = this._formattingExtensions.formatForDB(_appName);
    _builder.append(_formatForDB, "");
    _builder.append("ValidationError id=");
    String _name = it.getName();
    String _formatForCode = this._formattingExtensions.formatForCode(_name);
    String _templateIdWithSuffix = this._utils.templateIdWithSuffix(_formatForCode, idSuffix);
    _builder.append(_templateIdWithSuffix, "");
    _builder.append(" class=\'validate-email\'}");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  protected CharSequence _additionalValidationMessages(final UrlField it, final String idSuffix) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{");
    Entity _entity = it.getEntity();
    Models _container = _entity.getContainer();
    Application _application = _container.getApplication();
    String _appName = this._utils.appName(_application);
    String _formatForDB = this._formattingExtensions.formatForDB(_appName);
    _builder.append(_formatForDB, "");
    _builder.append("ValidationError id=");
    String _name = it.getName();
    String _formatForCode = this._formattingExtensions.formatForCode(_name);
    String _templateIdWithSuffix = this._utils.templateIdWithSuffix(_formatForCode, idSuffix);
    _builder.append(_templateIdWithSuffix, "");
    _builder.append(" class=\'validate-url\'}");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  protected CharSequence _additionalValidationMessages(final UploadField it, final String idSuffix) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{");
    Entity _entity = it.getEntity();
    Models _container = _entity.getContainer();
    Application _application = _container.getApplication();
    String _appName = this._utils.appName(_application);
    String _formatForDB = this._formattingExtensions.formatForDB(_appName);
    _builder.append(_formatForDB, "");
    _builder.append("ValidationError id=");
    String _name = it.getName();
    String _formatForCode = this._formattingExtensions.formatForCode(_name);
    String _templateIdWithSuffix = this._utils.templateIdWithSuffix(_formatForCode, idSuffix);
    _builder.append(_templateIdWithSuffix, "");
    _builder.append(" class=\'validate-upload\'}");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  protected CharSequence _additionalValidationMessages(final ListField it, final String idSuffix) {
    return null;
  }
  
  protected CharSequence _additionalValidationMessages(final AbstractDateField it, final String idSuffix) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _additionalValidationMessagesDefault = this.additionalValidationMessagesDefault(it, idSuffix);
    _builder.append(_additionalValidationMessagesDefault, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  protected CharSequence _additionalValidationMessages(final DatetimeField it, final String idSuffix) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _additionalValidationMessagesDefault = this.additionalValidationMessagesDefault(it, idSuffix);
    _builder.append(_additionalValidationMessagesDefault, "");
    _builder.newLineIfNotEmpty();
    CharSequence _additionalValidationMessagesDateRange = this.additionalValidationMessagesDateRange(it, idSuffix);
    _builder.append(_additionalValidationMessagesDateRange, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  protected CharSequence _additionalValidationMessages(final DateField it, final String idSuffix) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _additionalValidationMessagesDefault = this.additionalValidationMessagesDefault(it, idSuffix);
    _builder.append(_additionalValidationMessagesDefault, "");
    _builder.newLineIfNotEmpty();
    CharSequence _additionalValidationMessagesDateRange = this.additionalValidationMessagesDateRange(it, idSuffix);
    _builder.append(_additionalValidationMessagesDateRange, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence additionalValidationMessagesDefault(final AbstractDateField it, final String idSuffix) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _isPast = it.isPast();
      if (_isPast) {
        _builder.append("{");
        Entity _entity = it.getEntity();
        Models _container = _entity.getContainer();
        Application _application = _container.getApplication();
        String _appName = this._utils.appName(_application);
        String _formatForDB = this._formattingExtensions.formatForDB(_appName);
        _builder.append(_formatForDB, "");
        _builder.append("ValidationError id=");
        String _name = it.getName();
        String _formatForCode = this._formattingExtensions.formatForCode(_name);
        String _templateIdWithSuffix = this._utils.templateIdWithSuffix(_formatForCode, idSuffix);
        _builder.append(_templateIdWithSuffix, "");
        _builder.append(" class=\'validate-");
        String _fieldTypeAsString = this._modelExtensions.fieldTypeAsString(it);
        _builder.append(_fieldTypeAsString, "");
        _builder.append("-past\'}");
        _builder.newLineIfNotEmpty();
      } else {
        boolean _isFuture = it.isFuture();
        if (_isFuture) {
          _builder.append("{");
          Entity _entity_1 = it.getEntity();
          Models _container_1 = _entity_1.getContainer();
          Application _application_1 = _container_1.getApplication();
          String _appName_1 = this._utils.appName(_application_1);
          String _formatForDB_1 = this._formattingExtensions.formatForDB(_appName_1);
          _builder.append(_formatForDB_1, "");
          _builder.append("ValidationError id=");
          String _name_1 = it.getName();
          String _formatForCode_1 = this._formattingExtensions.formatForCode(_name_1);
          String _templateIdWithSuffix_1 = this._utils.templateIdWithSuffix(_formatForCode_1, idSuffix);
          _builder.append(_templateIdWithSuffix_1, "");
          _builder.append(" class=\'validate-");
          String _fieldTypeAsString_1 = this._modelExtensions.fieldTypeAsString(it);
          _builder.append(_fieldTypeAsString_1, "");
          _builder.append("-past\'}");
          _builder.newLineIfNotEmpty();
        }
      }
    }
    return _builder;
  }
  
  private CharSequence _additionalValidationMessagesDateRange(final DatetimeField it, final String idSuffix) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _and = false;
      Entity _entity = it.getEntity();
      AbstractDateField _startDateField = this._modelExtensions.getStartDateField(_entity);
      boolean _tripleNotEquals = (_startDateField != null);
      if (!_tripleNotEquals) {
        _and = false;
      } else {
        Entity _entity_1 = it.getEntity();
        AbstractDateField _endDateField = this._modelExtensions.getEndDateField(_entity_1);
        boolean _tripleNotEquals_1 = (_endDateField != null);
        _and = (_tripleNotEquals && _tripleNotEquals_1);
      }
      if (_and) {
        _builder.append("{");
        Entity _entity_2 = it.getEntity();
        Models _container = _entity_2.getContainer();
        Application _application = _container.getApplication();
        String _appName = this._utils.appName(_application);
        String _formatForDB = this._formattingExtensions.formatForDB(_appName);
        _builder.append(_formatForDB, "");
        _builder.append("ValidationError id=");
        String _name = it.getName();
        String _formatForCode = this._formattingExtensions.formatForCode(_name);
        String _templateIdWithSuffix = this._utils.templateIdWithSuffix(_formatForCode, idSuffix);
        _builder.append(_templateIdWithSuffix, "");
        _builder.append(" class=\'validate-daterange-");
        Entity _entity_3 = it.getEntity();
        String _name_1 = _entity_3.getName();
        String _formatForDB_1 = this._formattingExtensions.formatForDB(_name_1);
        _builder.append(_formatForDB_1, "");
        _builder.append("\'}");
        _builder.newLineIfNotEmpty();
      }
    }
    return _builder;
  }
  
  private CharSequence _additionalValidationMessagesDateRange(final DateField it, final String idSuffix) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _and = false;
      Entity _entity = it.getEntity();
      AbstractDateField _startDateField = this._modelExtensions.getStartDateField(_entity);
      boolean _tripleNotEquals = (_startDateField != null);
      if (!_tripleNotEquals) {
        _and = false;
      } else {
        Entity _entity_1 = it.getEntity();
        AbstractDateField _endDateField = this._modelExtensions.getEndDateField(_entity_1);
        boolean _tripleNotEquals_1 = (_endDateField != null);
        _and = (_tripleNotEquals && _tripleNotEquals_1);
      }
      if (_and) {
        _builder.append("{");
        Entity _entity_2 = it.getEntity();
        Models _container = _entity_2.getContainer();
        Application _application = _container.getApplication();
        String _appName = this._utils.appName(_application);
        String _formatForDB = this._formattingExtensions.formatForDB(_appName);
        _builder.append(_formatForDB, "");
        _builder.append("ValidationError id=");
        String _name = it.getName();
        String _formatForCode = this._formattingExtensions.formatForCode(_name);
        String _templateIdWithSuffix = this._utils.templateIdWithSuffix(_formatForCode, idSuffix);
        _builder.append(_templateIdWithSuffix, "");
        _builder.append(" class=\'validate-daterange-");
        Entity _entity_3 = it.getEntity();
        String _name_1 = _entity_3.getName();
        String _formatForDB_1 = this._formattingExtensions.formatForDB(_name_1);
        _builder.append(_formatForDB_1, "");
        _builder.append("\'}");
        _builder.newLineIfNotEmpty();
      }
    }
    return _builder;
  }
  
  public CharSequence fieldValidationCssClass(final DerivedField it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append(" ");
    _builder.append("cssClass=\'");
    {
      boolean _isMandatory = it.isMandatory();
      if (_isMandatory) {
        _builder.append("required");
        {
          boolean _isUnique = it.isUnique();
          if (_isUnique) {
            _builder.append(" ");
          }
        }
      }
    }
    {
      boolean _isUnique_1 = it.isUnique();
      if (_isUnique_1) {
        _builder.append("validate-unique");
      }
    }
    CharSequence _fieldValidationCssClassAdditions = this.fieldValidationCssClassAdditions(it);
    _builder.append(_fieldValidationCssClassAdditions, " ");
    _builder.append("\' ");
    return _builder;
  }
  
  public CharSequence fieldValidationCssClassEdit(final UploadField it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append(" ");
    _builder.append("cssClass=\'");
    {
      boolean _isUnique = it.isUnique();
      if (_isUnique) {
        _builder.append("validate-unique");
      }
    }
    CharSequence _fieldValidationCssClassAdditions = this.fieldValidationCssClassAdditions(it);
    _builder.append(_fieldValidationCssClassAdditions, " ");
    _builder.append("\' ");
    return _builder;
  }
  
  private CharSequence fieldValidationCssClassAdditions(final DerivedField it) {
    CharSequence _switchResult = null;
    boolean _matched = false;
    if (!_matched) {
      if (it instanceof AbstractIntegerField) {
        final AbstractIntegerField _abstractIntegerField = (AbstractIntegerField)it;
        _matched=true;
        _switchResult = " validate-digits";
      }
    }
    if (!_matched) {
      if (it instanceof DecimalField) {
        final DecimalField _decimalField = (DecimalField)it;
        _matched=true;
        _switchResult = " validate-number";
      }
    }
    if (!_matched) {
      if (it instanceof FloatField) {
        final FloatField _floatField = (FloatField)it;
        _matched=true;
        _switchResult = " validate-number";
      }
    }
    if (!_matched) {
      if (it instanceof AbstractStringField) {
        final AbstractStringField _abstractStringField = (AbstractStringField)it;
        boolean _isNospace = _abstractStringField.isNospace();
        if (_isNospace) {
          _matched=true;
          _switchResult = " validate-nospace";
        }
      }
    }
    if (!_matched) {
      if (it instanceof StringField) {
        final StringField _stringField = (StringField)it;
        boolean _isNospace = _stringField.isNospace();
        if (_isNospace) {
          _matched=true;
          _switchResult = " validate-nospace";
        }
      }
    }
    if (!_matched) {
      if (it instanceof StringField) {
        final StringField _stringField = (StringField)it;
        boolean _isHtmlcolour = _stringField.isHtmlcolour();
        if (_isHtmlcolour) {
          _matched=true;
          Entity _entity = _stringField.getEntity();
          Models _container = _entity.getContainer();
          Application _application = _container.getApplication();
          String _appName = this._utils.appName(_application);
          String _formatForDB = this._formattingExtensions.formatForDB(_appName);
          String _plus = (" validate-htmlcolour " + _formatForDB);
          String _plus_1 = (_plus + "ColourPicker");
          _switchResult = _plus_1;
        }
      }
    }
    if (!_matched) {
      if (it instanceof EmailField) {
        final EmailField _emailField = (EmailField)it;
        _matched=true;
        _switchResult = " validate-email";
      }
    }
    if (!_matched) {
      if (it instanceof UrlField) {
        final UrlField _urlField = (UrlField)it;
        _matched=true;
        _switchResult = " validate-url";
      }
    }
    if (!_matched) {
      if (it instanceof UploadField) {
        final UploadField _uploadField = (UploadField)it;
        _matched=true;
        _switchResult = " validate-upload";
      }
    }
    if (!_matched) {
      if (it instanceof ListField) {
        final ListField _listField = (ListField)it;
        _matched=true;
        _switchResult = "";
      }
    }
    if (!_matched) {
      if (it instanceof AbstractDateField) {
        final AbstractDateField _abstractDateField = (AbstractDateField)it;
        _matched=true;
        CharSequence _fieldValidationCssClassAdditionsDefault = this.fieldValidationCssClassAdditionsDefault(_abstractDateField);
        _switchResult = _fieldValidationCssClassAdditionsDefault;
      }
    }
    if (!_matched) {
      if (it instanceof DatetimeField) {
        final DatetimeField _datetimeField = (DatetimeField)it;
        _matched=true;
        StringConcatenation _builder = new StringConcatenation();
        CharSequence _fieldValidationCssClassAdditionsDefault = this.fieldValidationCssClassAdditionsDefault(_datetimeField);
        _builder.append(_fieldValidationCssClassAdditionsDefault, "");
        CharSequence _fieldValidationCssClassDateRange = this.fieldValidationCssClassDateRange(_datetimeField);
        _builder.append(_fieldValidationCssClassDateRange, "");
        _switchResult = _builder;
      }
    }
    if (!_matched) {
      if (it instanceof DateField) {
        final DateField _dateField = (DateField)it;
        _matched=true;
        StringConcatenation _builder = new StringConcatenation();
        CharSequence _fieldValidationCssClassAdditionsDefault = this.fieldValidationCssClassAdditionsDefault(_dateField);
        _builder.append(_fieldValidationCssClassAdditionsDefault, "");
        CharSequence _fieldValidationCssClassDateRange = this.fieldValidationCssClassDateRange(_dateField);
        _builder.append(_fieldValidationCssClassDateRange, "");
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
        String _fieldTypeAsString = this._modelExtensions.fieldTypeAsString(it);
        _builder.append(_fieldTypeAsString, "");
        _builder.append("-past");
      } else {
        boolean _isFuture = it.isFuture();
        if (_isFuture) {
          _builder.append(" validate-");
          String _fieldTypeAsString_1 = this._modelExtensions.fieldTypeAsString(it);
          _builder.append(_fieldTypeAsString_1, "");
          _builder.append("-future");
        }
      }
    }
    return _builder;
  }
  
  private CharSequence _fieldValidationCssClassDateRange(final DatetimeField it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _and = false;
      Entity _entity = it.getEntity();
      AbstractDateField _startDateField = this._modelExtensions.getStartDateField(_entity);
      boolean _tripleNotEquals = (_startDateField != null);
      if (!_tripleNotEquals) {
        _and = false;
      } else {
        Entity _entity_1 = it.getEntity();
        AbstractDateField _endDateField = this._modelExtensions.getEndDateField(_entity_1);
        boolean _tripleNotEquals_1 = (_endDateField != null);
        _and = (_tripleNotEquals && _tripleNotEquals_1);
      }
      if (_and) {
        _builder.append(" validate-daterange-");
        Entity _entity_2 = it.getEntity();
        String _name = _entity_2.getName();
        String _formatForDB = this._formattingExtensions.formatForDB(_name);
        _builder.append(_formatForDB, "");
      }
    }
    return _builder;
  }
  
  private CharSequence _fieldValidationCssClassDateRange(final DateField it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _and = false;
      Entity _entity = it.getEntity();
      AbstractDateField _startDateField = this._modelExtensions.getStartDateField(_entity);
      boolean _tripleNotEquals = (_startDateField != null);
      if (!_tripleNotEquals) {
        _and = false;
      } else {
        Entity _entity_1 = it.getEntity();
        AbstractDateField _endDateField = this._modelExtensions.getEndDateField(_entity_1);
        boolean _tripleNotEquals_1 = (_endDateField != null);
        _and = (_tripleNotEquals && _tripleNotEquals_1);
      }
      if (_and) {
        _builder.append(" validate-daterange-");
        Entity _entity_2 = it.getEntity();
        String _name = _entity_2.getName();
        String _formatForDB = this._formattingExtensions.formatForDB(_name);
        _builder.append(_formatForDB, "");
      }
    }
    return _builder;
  }
  
  public CharSequence mandatoryValidationMessage(final DerivedField it, final String idSuffix) {
    if (it instanceof ListField) {
      return _mandatoryValidationMessage((ListField)it, idSuffix);
    } else if (it != null) {
      return _mandatoryValidationMessage(it, idSuffix);
    } else {
      throw new IllegalArgumentException("Unhandled parameter types: " +
        Arrays.<Object>asList(it, idSuffix).toString());
    }
  }
  
  public CharSequence additionalValidationMessages(final DerivedField it, final String idSuffix) {
    if (it instanceof EmailField) {
      return _additionalValidationMessages((EmailField)it, idSuffix);
    } else if (it instanceof ListField) {
      return _additionalValidationMessages((ListField)it, idSuffix);
    } else if (it instanceof StringField) {
      return _additionalValidationMessages((StringField)it, idSuffix);
    } else if (it instanceof UploadField) {
      return _additionalValidationMessages((UploadField)it, idSuffix);
    } else if (it instanceof UrlField) {
      return _additionalValidationMessages((UrlField)it, idSuffix);
    } else if (it instanceof UserField) {
      return _additionalValidationMessages((UserField)it, idSuffix);
    } else if (it instanceof AbstractIntegerField) {
      return _additionalValidationMessages((AbstractIntegerField)it, idSuffix);
    } else if (it instanceof AbstractStringField) {
      return _additionalValidationMessages((AbstractStringField)it, idSuffix);
    } else if (it instanceof DateField) {
      return _additionalValidationMessages((DateField)it, idSuffix);
    } else if (it instanceof DatetimeField) {
      return _additionalValidationMessages((DatetimeField)it, idSuffix);
    } else if (it instanceof DecimalField) {
      return _additionalValidationMessages((DecimalField)it, idSuffix);
    } else if (it instanceof FloatField) {
      return _additionalValidationMessages((FloatField)it, idSuffix);
    } else if (it instanceof AbstractDateField) {
      return _additionalValidationMessages((AbstractDateField)it, idSuffix);
    } else if (it != null) {
      return _additionalValidationMessages(it, idSuffix);
    } else {
      throw new IllegalArgumentException("Unhandled parameter types: " +
        Arrays.<Object>asList(it, idSuffix).toString());
    }
  }
  
  private CharSequence additionalValidationMessagesDateRange(final AbstractDateField it, final String idSuffix) {
    if (it instanceof DateField) {
      return _additionalValidationMessagesDateRange((DateField)it, idSuffix);
    } else if (it instanceof DatetimeField) {
      return _additionalValidationMessagesDateRange((DatetimeField)it, idSuffix);
    } else {
      throw new IllegalArgumentException("Unhandled parameter types: " +
        Arrays.<Object>asList(it, idSuffix).toString());
    }
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
