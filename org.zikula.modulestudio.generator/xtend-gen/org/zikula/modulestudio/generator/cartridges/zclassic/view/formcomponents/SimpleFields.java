package org.zikula.modulestudio.generator.cartridges.zclassic.view.formcomponents;

import com.google.common.base.Objects;
import com.google.inject.Inject;
import de.guite.modulestudio.metamodel.modulestudio.AbstractDateField;
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
import de.guite.modulestudio.metamodel.modulestudio.IntegerField;
import de.guite.modulestudio.metamodel.modulestudio.ListField;
import de.guite.modulestudio.metamodel.modulestudio.Models;
import de.guite.modulestudio.metamodel.modulestudio.StringField;
import de.guite.modulestudio.metamodel.modulestudio.TextField;
import de.guite.modulestudio.metamodel.modulestudio.TimeField;
import de.guite.modulestudio.metamodel.modulestudio.UploadField;
import de.guite.modulestudio.metamodel.modulestudio.UrlField;
import de.guite.modulestudio.metamodel.modulestudio.UserField;
import java.math.BigInteger;
import java.util.Arrays;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.zikula.modulestudio.generator.cartridges.zclassic.view.formcomponents.Validation;
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
  
  private Validation validationHelper = new Function0<Validation>() {
    public Validation apply() {
      Validation _validation = new Validation();
      return _validation;
    }
  }.apply();
  
  public CharSequence formRow(final DerivedField it, final String groupSuffix, final String idSuffix) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _formLabel = this.formLabel(it, groupSuffix, idSuffix);
    _builder.append(_formLabel, "");
    _builder.newLineIfNotEmpty();
    CharSequence _formField = this.formField(it, groupSuffix, idSuffix);
    _builder.append(_formField, "");
    _builder.newLineIfNotEmpty();
    CharSequence _mandatoryValidationMessage = this.validationHelper.mandatoryValidationMessage(it, idSuffix);
    _builder.append(_mandatoryValidationMessage, "");
    _builder.newLineIfNotEmpty();
    CharSequence _additionalValidationMessages = this.validationHelper.additionalValidationMessages(it, idSuffix);
    _builder.append(_additionalValidationMessages, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence _formLabel(final DerivedField it, final String groupSuffix, final String idSuffix) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _initDocumentationToolTip = this.initDocumentationToolTip(it);
    _builder.append(_initDocumentationToolTip, "");
    _builder.newLineIfNotEmpty();
    _builder.append("{formlabel for=");
    String _name = it.getName();
    String _formatForCode = this._formattingExtensions.formatForCode(_name);
    String _templateIdWithSuffix = this._utils.templateIdWithSuffix(_formatForCode, idSuffix);
    _builder.append(_templateIdWithSuffix, "");
    _builder.append(" __text=\'");
    String _formLabelText = this.formLabelText(it);
    _builder.append(_formLabelText, "");
    _builder.append("\'");
    {
      boolean _isMandatory = it.isMandatory();
      if (_isMandatory) {
        _builder.append(" mandatorysym=\'1\'");
      }
    }
    CharSequence _formLabelAdditions = this.formLabelAdditions(it);
    _builder.append(_formLabelAdditions, "");
    _builder.append("}");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence _formLabel(final UploadField it, final String groupSuffix, final String idSuffix) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _initDocumentationToolTip = this.initDocumentationToolTip(it);
    _builder.append(_initDocumentationToolTip, "");
    _builder.newLineIfNotEmpty();
    {
      boolean _isMandatory = it.isMandatory();
      if (_isMandatory) {
        _builder.append("{assign var=\'mandatorySym\' value=\'1\'}");
        _builder.newLine();
        _builder.append("{if $mode ne \'create\'}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("{assign var=\'mandatorySym\' value=\'0\'}");
        _builder.newLine();
        _builder.append("{/if}");
        _builder.newLine();
      }
    }
    _builder.append("{formlabel for=");
    String _name = it.getName();
    String _formatForCode = this._formattingExtensions.formatForCode(_name);
    String _templateIdWithSuffix = this._utils.templateIdWithSuffix(_formatForCode, idSuffix);
    _builder.append(_templateIdWithSuffix, "");
    _builder.append(" __text=\'");
    String _formLabelText = this.formLabelText(it);
    _builder.append(_formLabelText, "");
    _builder.append("\'");
    {
      boolean _isMandatory_1 = it.isMandatory();
      if (_isMandatory_1) {
        _builder.append(" mandatorysym=$mandatorySym");
      }
    }
    CharSequence _formLabelAdditions = this.formLabelAdditions(it);
    _builder.append(_formLabelAdditions, "");
    _builder.append("}<br />{* break required for Google Chrome *}");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence initDocumentationToolTip(final DerivedField it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _and = false;
      String _documentation = it.getDocumentation();
      boolean _tripleNotEquals = (_documentation != null);
      if (!_tripleNotEquals) {
        _and = false;
      } else {
        String _documentation_1 = it.getDocumentation();
        boolean _notEquals = (!Objects.equal(_documentation_1, ""));
        _and = (_tripleNotEquals && _notEquals);
      }
      if (_and) {
        _builder.append("{gt text=\'");
        String _documentation_2 = it.getDocumentation();
        String _replaceAll = _documentation_2.replaceAll("\'", "\"");
        _builder.append(_replaceAll, "");
        _builder.append("\' assign=\'toolTip\'}");
        _builder.newLineIfNotEmpty();
      }
    }
    return _builder;
  }
  
  private CharSequence formLabelAdditions(final DerivedField it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("cssClass=\'");
    {
      boolean _and = false;
      String _documentation = it.getDocumentation();
      boolean _tripleNotEquals = (_documentation != null);
      if (!_tripleNotEquals) {
        _and = false;
      } else {
        String _documentation_1 = it.getDocumentation();
        boolean _notEquals = (!Objects.equal(_documentation_1, ""));
        _and = (_tripleNotEquals && _notEquals);
      }
      if (_and) {
        Entity _entity = it.getEntity();
        Models _container = _entity.getContainer();
        Application _application = _container.getApplication();
        String _appName = this._utils.appName(_application);
        String _formatForDB = this._formattingExtensions.formatForDB(_appName);
        _builder.append(_formatForDB, "");
        _builder.append("FormTooltips");
      }
    }
    {
      Entity _entity_1 = it.getEntity();
      Models _container_1 = _entity_1.getContainer();
      Application _application_1 = _container_1.getApplication();
      boolean _targets = this._utils.targets(_application_1, "1.3.5");
      boolean _not = (!_targets);
      if (_not) {
        _builder.append(" col-lg-3 control-label");
      }
    }
    _builder.append("\'");
    {
      boolean _and_1 = false;
      String _documentation_2 = it.getDocumentation();
      boolean _tripleNotEquals_1 = (_documentation_2 != null);
      if (!_tripleNotEquals_1) {
        _and_1 = false;
      } else {
        String _documentation_3 = it.getDocumentation();
        boolean _notEquals_1 = (!Objects.equal(_documentation_3, ""));
        _and_1 = (_tripleNotEquals_1 && _notEquals_1);
      }
      if (_and_1) {
        _builder.append(" title=$toolTip");
      }
    }
    return _builder;
  }
  
  private String formLabelText(final DerivedField it) {
    String _name = it.getName();
    String _formatForDisplayCapital = this._formattingExtensions.formatForDisplayCapital(_name);
    return _formatForDisplayCapital;
  }
  
  private CharSequence groupAndId(final EntityField it, final String groupSuffix, final String idSuffix) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("group=");
    Entity _entity = it.getEntity();
    String _name = _entity.getName();
    String _formatForDB = this._formattingExtensions.formatForDB(_name);
    String _templateIdWithSuffix = this._utils.templateIdWithSuffix(_formatForDB, groupSuffix);
    _builder.append(_templateIdWithSuffix, "");
    _builder.append(" id=");
    String _name_1 = it.getName();
    String _formatForCode = this._formattingExtensions.formatForCode(_name_1);
    String _templateIdWithSuffix_1 = this._utils.templateIdWithSuffix(_formatForCode, idSuffix);
    _builder.append(_templateIdWithSuffix_1, "");
    return _builder;
  }
  
  private CharSequence _formField(final BooleanField it, final String groupSuffix, final String idSuffix) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{formcheckbox ");
    CharSequence _groupAndId = this.groupAndId(it, groupSuffix, idSuffix);
    _builder.append(_groupAndId, "");
    _builder.append(" readOnly=");
    boolean _isReadonly = it.isReadonly();
    String _displayBool = this._formattingExtensions.displayBool(Boolean.valueOf(_isReadonly));
    _builder.append(_displayBool, "");
    _builder.append(" __title=\'");
    String _name = it.getName();
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(_name);
    _builder.append(_formatForDisplay, "");
    _builder.append(" ?\'");
    CharSequence _fieldValidationCssClass = this.validationHelper.fieldValidationCssClass(it);
    _builder.append(_fieldValidationCssClass, "");
    _builder.append("}");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence _formField(final IntegerField it, final String groupSuffix, final String idSuffix) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{formintinput ");
    CharSequence _groupAndId = this.groupAndId(it, groupSuffix, idSuffix);
    _builder.append(_groupAndId, "");
    _builder.append(" mandatory=");
    boolean _isMandatory = it.isMandatory();
    String _displayBool = this._formattingExtensions.displayBool(Boolean.valueOf(_isMandatory));
    _builder.append(_displayBool, "");
    _builder.append(" __title=\'Enter the ");
    String _name = it.getName();
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(_name);
    _builder.append(_formatForDisplay, "");
    _builder.append(" of the ");
    Entity _entity = it.getEntity();
    String _name_1 = _entity.getName();
    String _formatForDisplay_1 = this._formattingExtensions.formatForDisplay(_name_1);
    _builder.append(_formatForDisplay_1, "");
    _builder.append("\' maxLength=");
    int _length = it.getLength();
    _builder.append(_length, "");
    {
      BigInteger _minValue = it.getMinValue();
      String _string = _minValue.toString();
      boolean _notEquals = (!Objects.equal(_string, "0"));
      if (_notEquals) {
        _builder.append(" minValue=");
        BigInteger _minValue_1 = it.getMinValue();
        _builder.append(_minValue_1, "");
      }
    }
    {
      BigInteger _maxValue = it.getMaxValue();
      String _string_1 = _maxValue.toString();
      boolean _notEquals_1 = (!Objects.equal(_string_1, "0"));
      if (_notEquals_1) {
        _builder.append(" maxValue=");
        BigInteger _maxValue_1 = it.getMaxValue();
        _builder.append(_maxValue_1, "");
      }
    }
    _builder.append(" cssClass=\'");
    CharSequence _fieldValidationCssClass = this.validationHelper.fieldValidationCssClass(it);
    _builder.append(_fieldValidationCssClass, "");
    {
      Entity _entity_1 = it.getEntity();
      Models _container = _entity_1.getContainer();
      Application _application = _container.getApplication();
      boolean _targets = this._utils.targets(_application, "1.3.5");
      boolean _not = (!_targets);
      if (_not) {
        _builder.append(" form-control");
      }
    }
    _builder.append("\'}");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence _formField(final DecimalField it, final String groupSuffix, final String idSuffix) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _and = false;
      Entity _entity = it.getEntity();
      Models _container = _entity.getContainer();
      Application _application = _container.getApplication();
      boolean _targets = this._utils.targets(_application, "1.3.5");
      boolean _not = (!_targets);
      if (!_not) {
        _and = false;
      } else {
        boolean _isCurrency = it.isCurrency();
        _and = (_not && _isCurrency);
      }
      if (_and) {
        _builder.append("<div class=\"input-group\">");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("<span class=\"input-group-addon\">{gt text=\'$\' comment=\'Currency symbol\'}</span>");
        _builder.newLine();
      }
    }
    _builder.append("    ");
    _builder.append("{formfloatinput ");
    CharSequence _groupAndId = this.groupAndId(it, groupSuffix, idSuffix);
    _builder.append(_groupAndId, "    ");
    _builder.append(" mandatory=");
    boolean _isMandatory = it.isMandatory();
    String _displayBool = this._formattingExtensions.displayBool(Boolean.valueOf(_isMandatory));
    _builder.append(_displayBool, "    ");
    _builder.append(" __title=\'Enter the ");
    String _name = it.getName();
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(_name);
    _builder.append(_formatForDisplay, "    ");
    _builder.append(" of the ");
    Entity _entity_1 = it.getEntity();
    String _name_1 = _entity_1.getName();
    String _formatForDisplay_1 = this._formattingExtensions.formatForDisplay(_name_1);
    _builder.append(_formatForDisplay_1, "    ");
    _builder.append("\'");
    {
      boolean _and_1 = false;
      boolean _and_2 = false;
      float _minValue = it.getMinValue();
      boolean _notEquals = (_minValue != 0);
      if (!_notEquals) {
        _and_2 = false;
      } else {
        float _minValue_1 = it.getMinValue();
        String _string = Float.valueOf(_minValue_1).toString();
        boolean _notEquals_1 = (!Objects.equal(_string, "0.0"));
        _and_2 = (_notEquals && _notEquals_1);
      }
      if (!_and_2) {
        _and_1 = false;
      } else {
        float _minValue_2 = it.getMinValue();
        String _string_1 = Float.valueOf(_minValue_2).toString();
        boolean _notEquals_2 = (!Objects.equal(_string_1, "0.00"));
        _and_1 = (_and_2 && _notEquals_2);
      }
      if (_and_1) {
        _builder.append(" minValue=");
        float _minValue_3 = it.getMinValue();
        _builder.append(_minValue_3, "    ");
      }
    }
    {
      boolean _and_3 = false;
      boolean _and_4 = false;
      float _maxValue = it.getMaxValue();
      boolean _notEquals_3 = (_maxValue != 0);
      if (!_notEquals_3) {
        _and_4 = false;
      } else {
        float _maxValue_1 = it.getMaxValue();
        String _string_2 = Float.valueOf(_maxValue_1).toString();
        boolean _notEquals_4 = (!Objects.equal(_string_2, "0.0"));
        _and_4 = (_notEquals_3 && _notEquals_4);
      }
      if (!_and_4) {
        _and_3 = false;
      } else {
        float _maxValue_2 = it.getMaxValue();
        String _string_3 = Float.valueOf(_maxValue_2).toString();
        boolean _notEquals_5 = (!Objects.equal(_string_3, "0.00"));
        _and_3 = (_and_4 && _notEquals_5);
      }
      if (_and_3) {
        _builder.append(" maxValue=");
        float _maxValue_3 = it.getMaxValue();
        _builder.append(_maxValue_3, "    ");
      }
    }
    _builder.append(" maxLength=");
    int _length = it.getLength();
    int _plus = (_length + 3);
    int _scale = it.getScale();
    int _plus_1 = (_plus + _scale);
    _builder.append(_plus_1, "    ");
    {
      int _scale_1 = it.getScale();
      boolean _notEquals_6 = (_scale_1 != 2);
      if (_notEquals_6) {
        _builder.append(" precision=");
        int _scale_2 = it.getScale();
        _builder.append(_scale_2, "    ");
      }
    }
    _builder.append(" cssClass=\'");
    CharSequence _fieldValidationCssClass = this.validationHelper.fieldValidationCssClass(it);
    _builder.append(_fieldValidationCssClass, "    ");
    {
      Entity _entity_2 = it.getEntity();
      Models _container_1 = _entity_2.getContainer();
      Application _application_1 = _container_1.getApplication();
      boolean _targets_1 = this._utils.targets(_application_1, "1.3.5");
      boolean _not_1 = (!_targets_1);
      if (_not_1) {
        _builder.append(" form-control");
      }
    }
    _builder.append("\'}");
    _builder.newLineIfNotEmpty();
    {
      boolean _and_5 = false;
      Entity _entity_3 = it.getEntity();
      Models _container_2 = _entity_3.getContainer();
      Application _application_2 = _container_2.getApplication();
      boolean _targets_2 = this._utils.targets(_application_2, "1.3.5");
      boolean _not_2 = (!_targets_2);
      if (!_not_2) {
        _and_5 = false;
      } else {
        boolean _isCurrency_1 = it.isCurrency();
        _and_5 = (_not_2 && _isCurrency_1);
      }
      if (_and_5) {
        _builder.append("</div>");
        _builder.newLine();
      }
    }
    return _builder;
  }
  
  private CharSequence _formField(final FloatField it, final String groupSuffix, final String idSuffix) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _and = false;
      Entity _entity = it.getEntity();
      Models _container = _entity.getContainer();
      Application _application = _container.getApplication();
      boolean _targets = this._utils.targets(_application, "1.3.5");
      boolean _not = (!_targets);
      if (!_not) {
        _and = false;
      } else {
        boolean _isCurrency = it.isCurrency();
        _and = (_not && _isCurrency);
      }
      if (_and) {
        _builder.append("<div class=\"input-group\">");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("<span class=\"input-group-addon\">{gt text=\'$\' comment=\'Currency symbol\'}</span>");
        _builder.newLine();
      }
    }
    _builder.append("    ");
    _builder.append("{formfloatinput ");
    CharSequence _groupAndId = this.groupAndId(it, groupSuffix, idSuffix);
    _builder.append(_groupAndId, "    ");
    _builder.append(" mandatory=");
    boolean _isMandatory = it.isMandatory();
    String _displayBool = this._formattingExtensions.displayBool(Boolean.valueOf(_isMandatory));
    _builder.append(_displayBool, "    ");
    _builder.append(" __title=\'Enter the ");
    String _name = it.getName();
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(_name);
    _builder.append(_formatForDisplay, "    ");
    _builder.append(" of the ");
    Entity _entity_1 = it.getEntity();
    String _name_1 = _entity_1.getName();
    String _formatForDisplay_1 = this._formattingExtensions.formatForDisplay(_name_1);
    _builder.append(_formatForDisplay_1, "    ");
    _builder.append("\'");
    {
      boolean _and_1 = false;
      boolean _and_2 = false;
      float _minValue = it.getMinValue();
      boolean _notEquals = (_minValue != 0);
      if (!_notEquals) {
        _and_2 = false;
      } else {
        float _minValue_1 = it.getMinValue();
        String _string = Float.valueOf(_minValue_1).toString();
        boolean _notEquals_1 = (!Objects.equal(_string, "0.0"));
        _and_2 = (_notEquals && _notEquals_1);
      }
      if (!_and_2) {
        _and_1 = false;
      } else {
        float _minValue_2 = it.getMinValue();
        String _string_1 = Float.valueOf(_minValue_2).toString();
        boolean _notEquals_2 = (!Objects.equal(_string_1, "0.00"));
        _and_1 = (_and_2 && _notEquals_2);
      }
      if (_and_1) {
        _builder.append(" minValue=");
        float _minValue_3 = it.getMinValue();
        _builder.append(_minValue_3, "    ");
      }
    }
    {
      boolean _and_3 = false;
      boolean _and_4 = false;
      float _maxValue = it.getMaxValue();
      boolean _notEquals_3 = (_maxValue != 0);
      if (!_notEquals_3) {
        _and_4 = false;
      } else {
        float _maxValue_1 = it.getMaxValue();
        String _string_2 = Float.valueOf(_maxValue_1).toString();
        boolean _notEquals_4 = (!Objects.equal(_string_2, "0.0"));
        _and_4 = (_notEquals_3 && _notEquals_4);
      }
      if (!_and_4) {
        _and_3 = false;
      } else {
        float _maxValue_2 = it.getMaxValue();
        String _string_3 = Float.valueOf(_maxValue_2).toString();
        boolean _notEquals_5 = (!Objects.equal(_string_3, "0.00"));
        _and_3 = (_and_4 && _notEquals_5);
      }
      if (_and_3) {
        _builder.append(" maxValue=");
        float _maxValue_3 = it.getMaxValue();
        _builder.append(_maxValue_3, "    ");
      }
    }
    _builder.append(" cssClass=\'");
    CharSequence _fieldValidationCssClass = this.validationHelper.fieldValidationCssClass(it);
    _builder.append(_fieldValidationCssClass, "    ");
    {
      Entity _entity_2 = it.getEntity();
      Models _container_1 = _entity_2.getContainer();
      Application _application_1 = _container_1.getApplication();
      boolean _targets_1 = this._utils.targets(_application_1, "1.3.5");
      boolean _not_1 = (!_targets_1);
      if (_not_1) {
        _builder.append(" form-control");
      }
    }
    _builder.append("\'}");
    _builder.newLineIfNotEmpty();
    {
      boolean _and_5 = false;
      Entity _entity_3 = it.getEntity();
      Models _container_2 = _entity_3.getContainer();
      Application _application_2 = _container_2.getApplication();
      boolean _targets_2 = this._utils.targets(_application_2, "1.3.5");
      boolean _not_2 = (!_targets_2);
      if (!_not_2) {
        _and_5 = false;
      } else {
        boolean _isCurrency_1 = it.isCurrency();
        _and_5 = (_not_2 && _isCurrency_1);
      }
      if (_and_5) {
        _builder.append("</div>");
        _builder.newLine();
      }
    }
    return _builder;
  }
  
  private CharSequence _formField(final StringField it, final String groupSuffix, final String idSuffix) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _isCountry = it.isCountry();
      if (_isCountry) {
        _builder.append("{");
        Entity _entity = it.getEntity();
        Models _container = _entity.getContainer();
        Application _application = _container.getApplication();
        String _appName = this._utils.appName(_application);
        String _formatForDB = this._formattingExtensions.formatForDB(_appName);
        _builder.append(_formatForDB, "");
        _builder.append("CountrySelector ");
        CharSequence _groupAndId = this.groupAndId(it, groupSuffix, idSuffix);
        _builder.append(_groupAndId, "");
        _builder.append(" mandatory=");
        boolean _isMandatory = it.isMandatory();
        String _displayBool = this._formattingExtensions.displayBool(Boolean.valueOf(_isMandatory));
        _builder.append(_displayBool, "");
        _builder.append(" __title=\'Choose the ");
        String _name = it.getName();
        String _formatForDisplay = this._formattingExtensions.formatForDisplay(_name);
        _builder.append(_formatForDisplay, "");
        _builder.append(" of the ");
        Entity _entity_1 = it.getEntity();
        String _name_1 = _entity_1.getName();
        String _formatForDisplay_1 = this._formattingExtensions.formatForDisplay(_name_1);
        _builder.append(_formatForDisplay_1, "");
        _builder.append("\'");
        {
          Entity _entity_2 = it.getEntity();
          Models _container_1 = _entity_2.getContainer();
          Application _application_1 = _container_1.getApplication();
          boolean _targets = this._utils.targets(_application_1, "1.3.5");
          boolean _not = (!_targets);
          if (_not) {
            _builder.append(" cssClass=\'form-control\'");
          }
        }
        _builder.append("}");
        _builder.newLineIfNotEmpty();
      } else {
        boolean _isLanguage = it.isLanguage();
        if (_isLanguage) {
          _builder.append("{formlanguageselector ");
          CharSequence _groupAndId_1 = this.groupAndId(it, groupSuffix, idSuffix);
          _builder.append(_groupAndId_1, "");
          _builder.append(" mandatory=");
          boolean _isMandatory_1 = it.isMandatory();
          String _displayBool_1 = this._formattingExtensions.displayBool(Boolean.valueOf(_isMandatory_1));
          _builder.append(_displayBool_1, "");
          {
            boolean _isMandatory_2 = it.isMandatory();
            if (_isMandatory_2) {
              _builder.append(" addAllOption=false");
            }
          }
          _builder.append(" __title=\'Choose the ");
          String _name_2 = it.getName();
          String _formatForDisplay_2 = this._formattingExtensions.formatForDisplay(_name_2);
          _builder.append(_formatForDisplay_2, "");
          _builder.append(" of the ");
          Entity _entity_3 = it.getEntity();
          String _name_3 = _entity_3.getName();
          String _formatForDisplay_3 = this._formattingExtensions.formatForDisplay(_name_3);
          _builder.append(_formatForDisplay_3, "");
          _builder.append("\'");
          {
            Entity _entity_4 = it.getEntity();
            Models _container_2 = _entity_4.getContainer();
            Application _application_2 = _container_2.getApplication();
            boolean _targets_1 = this._utils.targets(_application_2, "1.3.5");
            boolean _not_1 = (!_targets_1);
            if (_not_1) {
              _builder.append(" cssClass=\'form-control\'");
            }
          }
          _builder.append("}");
          _builder.newLineIfNotEmpty();
        } else {
          boolean _isHtmlcolour = it.isHtmlcolour();
          if (_isHtmlcolour) {
            _builder.append("{");
            Entity _entity_5 = it.getEntity();
            Models _container_3 = _entity_5.getContainer();
            Application _application_3 = _container_3.getApplication();
            String _appName_1 = this._utils.appName(_application_3);
            String _formatForDB_1 = this._formattingExtensions.formatForDB(_appName_1);
            _builder.append(_formatForDB_1, "");
            _builder.append("ColourInput ");
            CharSequence _groupAndId_2 = this.groupAndId(it, groupSuffix, idSuffix);
            _builder.append(_groupAndId_2, "");
            _builder.append(" mandatory=");
            boolean _isMandatory_3 = it.isMandatory();
            String _displayBool_2 = this._formattingExtensions.displayBool(Boolean.valueOf(_isMandatory_3));
            _builder.append(_displayBool_2, "");
            _builder.append(" __title=\'Choose the ");
            String _name_4 = it.getName();
            String _formatForDisplay_4 = this._formattingExtensions.formatForDisplay(_name_4);
            _builder.append(_formatForDisplay_4, "");
            _builder.append(" of the ");
            Entity _entity_6 = it.getEntity();
            String _name_5 = _entity_6.getName();
            String _formatForDisplay_5 = this._formattingExtensions.formatForDisplay(_name_5);
            _builder.append(_formatForDisplay_5, "");
            _builder.append("\' cssClass=\'");
            CharSequence _fieldValidationCssClass = this.validationHelper.fieldValidationCssClass(it);
            _builder.append(_fieldValidationCssClass, "");
            {
              Entity _entity_7 = it.getEntity();
              Models _container_4 = _entity_7.getContainer();
              Application _application_4 = _container_4.getApplication();
              boolean _targets_2 = this._utils.targets(_application_4, "1.3.5");
              boolean _not_2 = (!_targets_2);
              if (_not_2) {
                _builder.append(" form-control");
              }
            }
            _builder.append("\'}");
            _builder.newLineIfNotEmpty();
          } else {
            _builder.append("{formtextinput ");
            CharSequence _groupAndId_3 = this.groupAndId(it, groupSuffix, idSuffix);
            _builder.append(_groupAndId_3, "");
            _builder.append(" mandatory=");
            boolean _isMandatory_4 = it.isMandatory();
            String _displayBool_3 = this._formattingExtensions.displayBool(Boolean.valueOf(_isMandatory_4));
            _builder.append(_displayBool_3, "");
            _builder.append(" readOnly=");
            boolean _isReadonly = it.isReadonly();
            String _displayBool_4 = this._formattingExtensions.displayBool(Boolean.valueOf(_isReadonly));
            _builder.append(_displayBool_4, "");
            _builder.append(" __title=\'Enter the ");
            String _name_6 = it.getName();
            String _formatForDisplay_6 = this._formattingExtensions.formatForDisplay(_name_6);
            _builder.append(_formatForDisplay_6, "");
            _builder.append(" of the ");
            Entity _entity_8 = it.getEntity();
            String _name_7 = _entity_8.getName();
            String _formatForDisplay_7 = this._formattingExtensions.formatForDisplay(_name_7);
            _builder.append(_formatForDisplay_7, "");
            _builder.append("\' textMode=\'");
            {
              boolean _isPassword = it.isPassword();
              if (_isPassword) {
                _builder.append("password");
              } else {
                _builder.append("singleline");
              }
            }
            _builder.append("\'");
            {
              int _minLength = it.getMinLength();
              boolean _greaterThan = (_minLength > 0);
              if (_greaterThan) {
                _builder.append(" minLength=");
                int _minLength_1 = it.getMinLength();
                _builder.append(_minLength_1, "");
              }
            }
            _builder.append(" maxLength=");
            int _length = it.getLength();
            _builder.append(_length, "");
            _builder.append(" cssClass=\'");
            CharSequence _fieldValidationCssClass_1 = this.validationHelper.fieldValidationCssClass(it);
            _builder.append(_fieldValidationCssClass_1, "");
            {
              Entity _entity_9 = it.getEntity();
              Models _container_5 = _entity_9.getContainer();
              Application _application_5 = _container_5.getApplication();
              boolean _targets_3 = this._utils.targets(_application_5, "1.3.5");
              boolean _not_3 = (!_targets_3);
              if (_not_3) {
                _builder.append(" form-control");
              }
            }
            _builder.append("\'}");
            _builder.newLineIfNotEmpty();
          }
        }
      }
    }
    return _builder;
  }
  
  private CharSequence _formField(final TextField it, final String groupSuffix, final String idSuffix) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{formtextinput ");
    CharSequence _groupAndId = this.groupAndId(it, groupSuffix, idSuffix);
    _builder.append(_groupAndId, "");
    _builder.append(" mandatory=");
    boolean _isMandatory = it.isMandatory();
    String _displayBool = this._formattingExtensions.displayBool(Boolean.valueOf(_isMandatory));
    _builder.append(_displayBool, "");
    _builder.append(" __title=\'Enter the ");
    String _name = it.getName();
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(_name);
    _builder.append(_formatForDisplay, "");
    _builder.append(" of the ");
    Entity _entity = it.getEntity();
    String _name_1 = _entity.getName();
    String _formatForDisplay_1 = this._formattingExtensions.formatForDisplay(_name_1);
    _builder.append(_formatForDisplay_1, "");
    _builder.append("\' textMode=\'multiline\'");
    {
      int _minLength = it.getMinLength();
      boolean _greaterThan = (_minLength > 0);
      if (_greaterThan) {
        _builder.append(" minLength=");
        int _minLength_1 = it.getMinLength();
        _builder.append(_minLength_1, "");
      }
    }
    _builder.append(" rows=\'6");
    _builder.append("\'");
    {
      Entity _entity_1 = it.getEntity();
      Models _container = _entity_1.getContainer();
      Application _application = _container.getApplication();
      boolean _targets = this._utils.targets(_application, "1.3.5");
      if (_targets) {
        _builder.append(" cols=\'50\'");
      }
    }
    _builder.append(" cssClass=\'");
    CharSequence _fieldValidationCssClass = this.validationHelper.fieldValidationCssClass(it);
    _builder.append(_fieldValidationCssClass, "");
    {
      Entity _entity_2 = it.getEntity();
      Models _container_1 = _entity_2.getContainer();
      Application _application_1 = _container_1.getApplication();
      boolean _targets_1 = this._utils.targets(_application_1, "1.3.5");
      boolean _not = (!_targets_1);
      if (_not) {
        _builder.append(" form-control");
      }
    }
    _builder.append("\'}");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence _formField(final EmailField it, final String groupSuffix, final String idSuffix) {
    StringConcatenation _builder = new StringConcatenation();
    {
      Entity _entity = it.getEntity();
      Models _container = _entity.getContainer();
      Application _application = _container.getApplication();
      boolean _targets = this._utils.targets(_application, "1.3.5");
      boolean _not = (!_targets);
      if (_not) {
        _builder.append("<div class=\"input-group\">");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("<span class=\"input-group-addon\">@</span>");
        _builder.newLine();
      }
    }
    _builder.append("    ");
    _builder.append("{formemailinput ");
    CharSequence _groupAndId = this.groupAndId(it, groupSuffix, idSuffix);
    _builder.append(_groupAndId, "    ");
    _builder.append(" mandatory=");
    boolean _isMandatory = it.isMandatory();
    String _displayBool = this._formattingExtensions.displayBool(Boolean.valueOf(_isMandatory));
    _builder.append(_displayBool, "    ");
    _builder.append(" readOnly=");
    boolean _isReadonly = it.isReadonly();
    String _displayBool_1 = this._formattingExtensions.displayBool(Boolean.valueOf(_isReadonly));
    _builder.append(_displayBool_1, "    ");
    _builder.append(" __title=\'Enter the ");
    String _name = it.getName();
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(_name);
    _builder.append(_formatForDisplay, "    ");
    _builder.append(" of the ");
    Entity _entity_1 = it.getEntity();
    String _name_1 = _entity_1.getName();
    String _formatForDisplay_1 = this._formattingExtensions.formatForDisplay(_name_1);
    _builder.append(_formatForDisplay_1, "    ");
    _builder.append("\' textMode=\'singleline\'");
    {
      int _minLength = it.getMinLength();
      boolean _greaterThan = (_minLength > 0);
      if (_greaterThan) {
        _builder.append(" minLength=");
        int _minLength_1 = it.getMinLength();
        _builder.append(_minLength_1, "    ");
      }
    }
    _builder.append(" maxLength=");
    int _length = it.getLength();
    _builder.append(_length, "    ");
    _builder.append(" cssClass=\'");
    CharSequence _fieldValidationCssClass = this.validationHelper.fieldValidationCssClass(it);
    _builder.append(_fieldValidationCssClass, "    ");
    {
      Entity _entity_2 = it.getEntity();
      Models _container_1 = _entity_2.getContainer();
      Application _application_1 = _container_1.getApplication();
      boolean _targets_1 = this._utils.targets(_application_1, "1.3.5");
      boolean _not_1 = (!_targets_1);
      if (_not_1) {
        _builder.append(" form-control");
      }
    }
    _builder.append("\'}");
    _builder.newLineIfNotEmpty();
    {
      Entity _entity_3 = it.getEntity();
      Models _container_2 = _entity_3.getContainer();
      Application _application_2 = _container_2.getApplication();
      boolean _targets_2 = this._utils.targets(_application_2, "1.3.5");
      boolean _not_2 = (!_targets_2);
      if (_not_2) {
        _builder.append("</div>");
        _builder.newLine();
      }
    }
    return _builder;
  }
  
  private CharSequence _formField(final UrlField it, final String groupSuffix, final String idSuffix) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{formurlinput ");
    CharSequence _groupAndId = this.groupAndId(it, groupSuffix, idSuffix);
    _builder.append(_groupAndId, "");
    _builder.append(" mandatory=");
    boolean _isMandatory = it.isMandatory();
    String _displayBool = this._formattingExtensions.displayBool(Boolean.valueOf(_isMandatory));
    _builder.append(_displayBool, "");
    _builder.append(" readOnly=");
    boolean _isReadonly = it.isReadonly();
    String _displayBool_1 = this._formattingExtensions.displayBool(Boolean.valueOf(_isReadonly));
    _builder.append(_displayBool_1, "");
    _builder.append(" __title=\'Enter the ");
    String _name = it.getName();
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(_name);
    _builder.append(_formatForDisplay, "");
    _builder.append(" of the ");
    Entity _entity = it.getEntity();
    String _name_1 = _entity.getName();
    String _formatForDisplay_1 = this._formattingExtensions.formatForDisplay(_name_1);
    _builder.append(_formatForDisplay_1, "");
    _builder.append("\' textMode=\'singleline\'");
    {
      int _minLength = it.getMinLength();
      boolean _greaterThan = (_minLength > 0);
      if (_greaterThan) {
        _builder.append(" minLength=");
        int _minLength_1 = it.getMinLength();
        _builder.append(_minLength_1, "");
      }
    }
    _builder.append(" maxLength=");
    int _length = it.getLength();
    _builder.append(_length, "");
    _builder.append(" cssClass=\'");
    CharSequence _fieldValidationCssClass = this.validationHelper.fieldValidationCssClass(it);
    _builder.append(_fieldValidationCssClass, "");
    {
      Entity _entity_1 = it.getEntity();
      Models _container = _entity_1.getContainer();
      Application _application = _container.getApplication();
      boolean _targets = this._utils.targets(_application, "1.3.5");
      boolean _not = (!_targets);
      if (_not) {
        _builder.append(" form-control");
      }
    }
    _builder.append("\'}");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence _formField(final UploadField it, final String groupSuffix, final String idSuffix) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _isMandatory = it.isMandatory();
      if (_isMandatory) {
        _builder.append("{if $mode eq \'create\'}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("{formuploadinput ");
        CharSequence _groupAndId = this.groupAndId(it, groupSuffix, idSuffix);
        _builder.append(_groupAndId, "    ");
        _builder.append(" mandatory=");
        boolean _isMandatory_1 = it.isMandatory();
        String _displayBool = this._formattingExtensions.displayBool(Boolean.valueOf(_isMandatory_1));
        _builder.append(_displayBool, "    ");
        _builder.append(" readOnly=");
        boolean _isReadonly = it.isReadonly();
        String _displayBool_1 = this._formattingExtensions.displayBool(Boolean.valueOf(_isReadonly));
        _builder.append(_displayBool_1, "    ");
        _builder.append(" cssClass=\'");
        CharSequence _fieldValidationCssClass = this.validationHelper.fieldValidationCssClass(it);
        _builder.append(_fieldValidationCssClass, "    ");
        {
          Entity _entity = it.getEntity();
          Models _container = _entity.getContainer();
          Application _application = _container.getApplication();
          boolean _targets = this._utils.targets(_application, "1.3.5");
          boolean _not = (!_targets);
          if (_not) {
            _builder.append(" form-control");
          }
        }
        _builder.append("\'}");
        _builder.newLineIfNotEmpty();
        _builder.append("{else}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("{formuploadinput ");
        CharSequence _groupAndId_1 = this.groupAndId(it, groupSuffix, idSuffix);
        _builder.append(_groupAndId_1, "    ");
        _builder.append(" mandatory=false readOnly=");
        boolean _isReadonly_1 = it.isReadonly();
        String _displayBool_2 = this._formattingExtensions.displayBool(Boolean.valueOf(_isReadonly_1));
        _builder.append(_displayBool_2, "    ");
        _builder.append(" cssClass=\'");
        CharSequence _fieldValidationCssClass_1 = this.validationHelper.fieldValidationCssClass(it);
        _builder.append(_fieldValidationCssClass_1, "    ");
        {
          Entity _entity_1 = it.getEntity();
          Models _container_1 = _entity_1.getContainer();
          Application _application_1 = _container_1.getApplication();
          boolean _targets_1 = this._utils.targets(_application_1, "1.3.5");
          boolean _not_1 = (!_targets_1);
          if (_not_1) {
            _builder.append(" form-control");
          }
        }
        _builder.append("\'}");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("<span class=\"");
        {
          Entity _entity_2 = it.getEntity();
          Models _container_2 = _entity_2.getContainer();
          Application _application_2 = _container_2.getApplication();
          boolean _targets_2 = this._utils.targets(_application_2, "1.3.5");
          if (_targets_2) {
            _builder.append("z-formnote");
          } else {
            _builder.append("help-block");
          }
        }
        _builder.append("\"><a id=\"reset");
        String _name = it.getName();
        String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(_name);
        _builder.append(_formatForCodeCapital, "    ");
        _builder.append("Val\" href=\"javascript:void(0);\" class=\"");
        {
          Entity _entity_3 = it.getEntity();
          Models _container_3 = _entity_3.getContainer();
          Application _application_3 = _container_3.getApplication();
          boolean _targets_3 = this._utils.targets(_application_3, "1.3.5");
          if (_targets_3) {
            _builder.append("z-");
          }
        }
        _builder.append("hide\">{gt text=\'Reset to empty value\'}</a></span>");
        _builder.newLineIfNotEmpty();
        _builder.append("{/if}");
        _builder.newLine();
      } else {
        _builder.append("{formuploadinput ");
        CharSequence _groupAndId_2 = this.groupAndId(it, groupSuffix, idSuffix);
        _builder.append(_groupAndId_2, "");
        _builder.append(" mandatory=false readOnly=");
        boolean _isReadonly_2 = it.isReadonly();
        String _displayBool_3 = this._formattingExtensions.displayBool(Boolean.valueOf(_isReadonly_2));
        _builder.append(_displayBool_3, "");
        _builder.append(" cssClass=\'");
        CharSequence _fieldValidationCssClass_2 = this.validationHelper.fieldValidationCssClass(it);
        _builder.append(_fieldValidationCssClass_2, "");
        {
          Entity _entity_4 = it.getEntity();
          Models _container_4 = _entity_4.getContainer();
          Application _application_4 = _container_4.getApplication();
          boolean _targets_4 = this._utils.targets(_application_4, "1.3.5");
          boolean _not_2 = (!_targets_4);
          if (_not_2) {
            _builder.append(" form-control");
          }
        }
        _builder.append("\'}");
        _builder.newLineIfNotEmpty();
        _builder.append("<span class=\"");
        {
          Entity _entity_5 = it.getEntity();
          Models _container_5 = _entity_5.getContainer();
          Application _application_5 = _container_5.getApplication();
          boolean _targets_5 = this._utils.targets(_application_5, "1.3.5");
          if (_targets_5) {
            _builder.append("z-formnote");
          } else {
            _builder.append("help-block");
          }
        }
        _builder.append("\"><a id=\"reset");
        String _name_1 = it.getName();
        String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(_name_1);
        _builder.append(_formatForCodeCapital_1, "");
        _builder.append("Val\" href=\"javascript:void(0);\" class=\"");
        {
          Entity _entity_6 = it.getEntity();
          Models _container_6 = _entity_6.getContainer();
          Application _application_6 = _container_6.getApplication();
          boolean _targets_6 = this._utils.targets(_application_6, "1.3.5");
          if (_targets_6) {
            _builder.append("z-");
          }
        }
        _builder.append("hide\">{gt text=\'Reset to empty value\'}</a></span>");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<span class=\"");
    {
      Entity _entity_7 = it.getEntity();
      Models _container_7 = _entity_7.getContainer();
      Application _application_7 = _container_7.getApplication();
      boolean _targets_7 = this._utils.targets(_application_7, "1.3.5");
      if (_targets_7) {
        _builder.append("z-formnote");
      } else {
        _builder.append("help-block");
      }
    }
    _builder.append("\">{gt text=\'Allowed file extensions:\'} <span id=\"fileextensions");
    String _name_2 = it.getName();
    String _formatForCode = this._formattingExtensions.formatForCode(_name_2);
    _builder.append(_formatForCode, "    ");
    _builder.append("\">");
    String _allowedExtensions = it.getAllowedExtensions();
    _builder.append(_allowedExtensions, "    ");
    _builder.append("</span></span>");
    _builder.newLineIfNotEmpty();
    {
      int _allowedFileSize = it.getAllowedFileSize();
      boolean _greaterThan = (_allowedFileSize > 0);
      if (_greaterThan) {
        _builder.append("<span class=\"");
        {
          Entity _entity_8 = it.getEntity();
          Models _container_8 = _entity_8.getContainer();
          Application _application_8 = _container_8.getApplication();
          boolean _targets_8 = this._utils.targets(_application_8, "1.3.5");
          if (_targets_8) {
            _builder.append("z-formnote");
          } else {
            _builder.append("help-block");
          }
        }
        _builder.append("\">{gt text=\'Allowed file size:\'} {\'");
        int _allowedFileSize_1 = it.getAllowedFileSize();
        _builder.append(_allowedFileSize_1, "");
        _builder.append("\'|");
        Entity _entity_9 = it.getEntity();
        Models _container_9 = _entity_9.getContainer();
        Application _application_9 = _container_9.getApplication();
        String _appName = this._utils.appName(_application_9);
        String _formatForDB = this._formattingExtensions.formatForDB(_appName);
        _builder.append(_formatForDB, "");
        _builder.append("GetFileSize:\'\':false:false}</span>");
        _builder.newLineIfNotEmpty();
      }
    }
    CharSequence _decideWhetherToShowCurrentFile = this.decideWhetherToShowCurrentFile(it);
    _builder.append(_decideWhetherToShowCurrentFile, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence decideWhetherToShowCurrentFile(final UploadField it) {
    StringConcatenation _builder = new StringConcatenation();
    Entity _entity = it.getEntity();
    String _name = _entity.getName();
    String _formatForDB = this._formattingExtensions.formatForDB(_name);
    String _plus = (_formatForDB + ".");
    String _name_1 = it.getName();
    String _formatForCode = this._formattingExtensions.formatForCode(_name_1);
    final String fieldName = (_plus + _formatForCode);
    _builder.newLineIfNotEmpty();
    _builder.append("{if $mode ne \'create\'}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{if $");
    _builder.append(fieldName, "    ");
    _builder.append(" ne \'\'}");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    CharSequence _showCurrentFile = this.showCurrentFile(it);
    _builder.append(_showCurrentFile, "        ");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("{/if}");
    _builder.newLine();
    _builder.append("{/if}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence showCurrentFile(final UploadField it) {
    StringConcatenation _builder = new StringConcatenation();
    Entity _entity = it.getEntity();
    Models _container = _entity.getContainer();
    Application _application = _container.getApplication();
    String _appName = this._utils.appName(_application);
    final String appNameSmall = this._formattingExtensions.formatForDB(_appName);
    _builder.newLineIfNotEmpty();
    Entity _entity_1 = it.getEntity();
    String _name = _entity_1.getName();
    final String objName = this._formattingExtensions.formatForDB(_name);
    _builder.newLineIfNotEmpty();
    String _plus = (objName + ".");
    String _name_1 = it.getName();
    String _formatForCode = this._formattingExtensions.formatForCode(_name_1);
    final String realName = (_plus + _formatForCode);
    _builder.newLineIfNotEmpty();
    _builder.append("<span class=\"");
    {
      Entity _entity_2 = it.getEntity();
      Models _container_1 = _entity_2.getContainer();
      Application _application_1 = _container_1.getApplication();
      boolean _targets = this._utils.targets(_application_1, "1.3.5");
      if (_targets) {
        _builder.append("z-formnote");
      } else {
        _builder.append("help-block");
      }
    }
    _builder.append("\">");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("{gt text=\'Current file\'}:");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<a href=\"{$");
    _builder.append(realName, "    ");
    _builder.append("FullPathUrl}\" title=\"{$");
    _builder.append(objName, "    ");
    _builder.append(".");
    Entity _entity_3 = it.getEntity();
    DerivedField _leadingField = this._modelExtensions.getLeadingField(_entity_3);
    String _name_2 = _leadingField.getName();
    String _formatForCode_1 = this._formattingExtensions.formatForCode(_name_2);
    _builder.append(_formatForCode_1, "    ");
    _builder.append("|replace:\"\\\"\":\"\"}\"{if $");
    _builder.append(realName, "    ");
    _builder.append("Meta.isImage} rel=\"imageviewer[");
    Entity _entity_4 = it.getEntity();
    String _name_3 = _entity_4.getName();
    String _formatForDB = this._formattingExtensions.formatForDB(_name_3);
    _builder.append(_formatForDB, "    ");
    _builder.append("]\"{/if}>");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("{if $");
    _builder.append(realName, "    ");
    _builder.append("Meta.isImage}");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("{thumb image=$");
    _builder.append(realName, "        ");
    _builder.append("FullPath objectid=\"");
    Entity _entity_5 = it.getEntity();
    String _name_4 = _entity_5.getName();
    String _formatForCode_2 = this._formattingExtensions.formatForCode(_name_4);
    _builder.append(_formatForCode_2, "        ");
    {
      Entity _entity_6 = it.getEntity();
      boolean _hasCompositeKeys = this._modelExtensions.hasCompositeKeys(_entity_6);
      if (_hasCompositeKeys) {
        {
          Entity _entity_7 = it.getEntity();
          Iterable<DerivedField> _primaryKeyFields = this._modelExtensions.getPrimaryKeyFields(_entity_7);
          for(final DerivedField pkField : _primaryKeyFields) {
            _builder.append("-`$");
            _builder.append(objName, "        ");
            _builder.append(".");
            String _name_5 = pkField.getName();
            String _formatForCode_3 = this._formattingExtensions.formatForCode(_name_5);
            _builder.append(_formatForCode_3, "        ");
            _builder.append("`");
          }
        }
      } else {
        _builder.append("-`$");
        _builder.append(objName, "        ");
        _builder.append(".");
        Entity _entity_8 = it.getEntity();
        Iterable<DerivedField> _primaryKeyFields_1 = this._modelExtensions.getPrimaryKeyFields(_entity_8);
        DerivedField _head = IterableExtensions.<DerivedField>head(_primaryKeyFields_1);
        String _name_6 = _head.getName();
        String _formatForCode_4 = this._formattingExtensions.formatForCode(_name_6);
        _builder.append(_formatForCode_4, "        ");
        _builder.append("`");
      }
    }
    _builder.append("\" preset=$");
    Entity _entity_9 = it.getEntity();
    String _name_7 = _entity_9.getName();
    String _formatForCode_5 = this._formattingExtensions.formatForCode(_name_7);
    _builder.append(_formatForCode_5, "        ");
    _builder.append("ThumbPreset");
    String _name_8 = it.getName();
    String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(_name_8);
    _builder.append(_formatForCodeCapital, "        ");
    _builder.append(" tag=true img_alt=$");
    _builder.append(objName, "        ");
    _builder.append(".");
    Entity _entity_10 = it.getEntity();
    DerivedField _leadingField_1 = this._modelExtensions.getLeadingField(_entity_10);
    String _name_9 = _leadingField_1.getName();
    String _formatForCode_6 = this._formattingExtensions.formatForCode(_name_9);
    _builder.append(_formatForCode_6, "        ");
    {
      Entity _entity_11 = it.getEntity();
      Models _container_2 = _entity_11.getContainer();
      Application _application_2 = _container_2.getApplication();
      boolean _targets_1 = this._utils.targets(_application_2, "1.3.5");
      boolean _not = (!_targets_1);
      if (_not) {
        _builder.append(" img_class=\'img-thumbnail\'");
      }
    }
    _builder.append("}");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("{else}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("{gt text=\'Download\'} ({$");
    _builder.append(realName, "        ");
    _builder.append("Meta.size|");
    _builder.append(appNameSmall, "        ");
    _builder.append("GetFileSize:$");
    _builder.append(realName, "        ");
    _builder.append("FullPath:false:false})");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("{/if}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("</a>");
    _builder.newLine();
    _builder.append("</span>");
    _builder.newLine();
    {
      boolean _isMandatory = it.isMandatory();
      boolean _not_1 = (!_isMandatory);
      if (_not_1) {
        _builder.append("<span class=\"");
        {
          Entity _entity_12 = it.getEntity();
          Models _container_3 = _entity_12.getContainer();
          Application _application_3 = _container_3.getApplication();
          boolean _targets_2 = this._utils.targets(_application_3, "1.3.5");
          if (_targets_2) {
            _builder.append("z-formnote");
          } else {
            _builder.append("help-block");
          }
        }
        _builder.append("\">");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("{formcheckbox group=\'");
        Entity _entity_13 = it.getEntity();
        String _name_10 = _entity_13.getName();
        String _formatForDB_1 = this._formattingExtensions.formatForDB(_name_10);
        _builder.append(_formatForDB_1, "    ");
        _builder.append("\' id=\'");
        String _name_11 = it.getName();
        String _formatForCode_7 = this._formattingExtensions.formatForCode(_name_11);
        _builder.append(_formatForCode_7, "    ");
        _builder.append("DeleteFile\' readOnly=false __title=\'Delete ");
        String _name_12 = it.getName();
        String _formatForDisplay = this._formattingExtensions.formatForDisplay(_name_12);
        _builder.append(_formatForDisplay, "    ");
        _builder.append(" ?\'}");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("{formlabel for=\'");
        String _name_13 = it.getName();
        String _formatForCode_8 = this._formattingExtensions.formatForCode(_name_13);
        _builder.append(_formatForCode_8, "    ");
        _builder.append("DeleteFile\' __text=\'Delete existing file\'}");
        _builder.newLineIfNotEmpty();
        _builder.append("</span>");
        _builder.newLine();
      }
    }
    return _builder;
  }
  
  private CharSequence _formField(final ListField it, final String groupSuffix, final String idSuffix) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _and = false;
      boolean _isMultiple = it.isMultiple();
      boolean _equals = (_isMultiple == true);
      if (!_equals) {
        _and = false;
      } else {
        boolean _isUseChecks = it.isUseChecks();
        boolean _equals_1 = (_isUseChecks == true);
        _and = (_equals && _equals_1);
      }
      if (_and) {
        _builder.append("{formcheckboxlist ");
        CharSequence _groupAndId = this.groupAndId(it, groupSuffix, idSuffix);
        _builder.append(_groupAndId, "");
        _builder.append(" mandatory=");
        boolean _isMandatory = it.isMandatory();
        String _displayBool = this._formattingExtensions.displayBool(Boolean.valueOf(_isMandatory));
        _builder.append(_displayBool, "");
        _builder.append(" __title=\'Choose the ");
        String _name = it.getName();
        String _formatForDisplay = this._formattingExtensions.formatForDisplay(_name);
        _builder.append(_formatForDisplay, "");
        _builder.append("\' repeatColumns=2");
        {
          Entity _entity = it.getEntity();
          Models _container = _entity.getContainer();
          Application _application = _container.getApplication();
          boolean _targets = this._utils.targets(_application, "1.3.5");
          boolean _not = (!_targets);
          if (_not) {
            _builder.append(" cssClass=\'form-control\'");
          }
        }
        _builder.append("}");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("{formdropdownlist ");
        CharSequence _groupAndId_1 = this.groupAndId(it, groupSuffix, idSuffix);
        _builder.append(_groupAndId_1, "");
        _builder.append(" mandatory=");
        boolean _isMandatory_1 = it.isMandatory();
        String _displayBool_1 = this._formattingExtensions.displayBool(Boolean.valueOf(_isMandatory_1));
        _builder.append(_displayBool_1, "");
        _builder.append(" __title=\'Choose the ");
        String _name_1 = it.getName();
        String _formatForDisplay_1 = this._formattingExtensions.formatForDisplay(_name_1);
        _builder.append(_formatForDisplay_1, "");
        _builder.append("\' selectionMode=\'");
        {
          boolean _isMultiple_1 = it.isMultiple();
          if (_isMultiple_1) {
            _builder.append("multiple");
          } else {
            _builder.append("single");
          }
        }
        _builder.append("\'");
        {
          Entity _entity_1 = it.getEntity();
          Models _container_1 = _entity_1.getContainer();
          Application _application_1 = _container_1.getApplication();
          boolean _targets_1 = this._utils.targets(_application_1, "1.3.5");
          boolean _not_1 = (!_targets_1);
          if (_not_1) {
            _builder.append(" cssClass=\'form-control\'");
          }
        }
        _builder.append("}");
        _builder.newLineIfNotEmpty();
      }
    }
    return _builder;
  }
  
  private CharSequence _formField(final UserField it, final String groupSuffix, final String idSuffix) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{");
    Entity _entity = it.getEntity();
    Models _container = _entity.getContainer();
    Application _application = _container.getApplication();
    String _appName = this._utils.appName(_application);
    String _formatForDB = this._formattingExtensions.formatForDB(_appName);
    _builder.append(_formatForDB, "");
    _builder.append("UserInput ");
    CharSequence _groupAndId = this.groupAndId(it, groupSuffix, idSuffix);
    _builder.append(_groupAndId, "");
    _builder.append(" mandatory=");
    boolean _isMandatory = it.isMandatory();
    String _displayBool = this._formattingExtensions.displayBool(Boolean.valueOf(_isMandatory));
    _builder.append(_displayBool, "");
    _builder.append(" readOnly=");
    boolean _isReadonly = it.isReadonly();
    String _displayBool_1 = this._formattingExtensions.displayBool(Boolean.valueOf(_isReadonly));
    _builder.append(_displayBool_1, "");
    _builder.append(" __title=\'Enter a part of the user name to search\' cssClass=\'");
    {
      boolean _isMandatory_1 = it.isMandatory();
      if (_isMandatory_1) {
        _builder.append("required");
      }
    }
    {
      Entity _entity_1 = it.getEntity();
      Models _container_1 = _entity_1.getContainer();
      Application _application_1 = _container_1.getApplication();
      boolean _targets = this._utils.targets(_application_1, "1.3.5");
      boolean _not = (!_targets);
      if (_not) {
        {
          boolean _isMandatory_2 = it.isMandatory();
          if (_isMandatory_2) {
            _builder.append(" ");
          }
        }
        _builder.append("form-control");
      }
    }
    _builder.append("\'}");
    _builder.newLineIfNotEmpty();
    _builder.append("{if $mode ne \'create\' && $");
    Entity _entity_2 = it.getEntity();
    String _name = _entity_2.getName();
    String _formatForDB_1 = this._formattingExtensions.formatForDB(_name);
    _builder.append(_formatForDB_1, "");
    _builder.append(".");
    String _name_1 = it.getName();
    String _formatForDB_2 = this._formattingExtensions.formatForDB(_name_1);
    _builder.append(_formatForDB_2, "");
    _builder.append(" && !$inlineUsage}");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("{checkpermissionblock component=\'Users::\' instance=\'::\' level=\'ACCESS_ADMIN\'}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<span class=\"");
    {
      Entity _entity_3 = it.getEntity();
      Models _container_2 = _entity_3.getContainer();
      Application _application_2 = _container_2.getApplication();
      boolean _targets_1 = this._utils.targets(_application_2, "1.3.5");
      if (_targets_1) {
        _builder.append("z-formnote");
      } else {
        _builder.append("help-block");
      }
    }
    _builder.append("\"><a href=\"{modurl modname=\'");
    {
      Entity _entity_4 = it.getEntity();
      Models _container_3 = _entity_4.getContainer();
      Application _application_3 = _container_3.getApplication();
      boolean _targets_2 = this._utils.targets(_application_3, "1.3.5");
      if (_targets_2) {
        _builder.append("Users");
      } else {
        _builder.append("ZikulaUsersModule");
      }
    }
    _builder.append("\' type=\'admin\' func=\'modify\' userid=$");
    Entity _entity_5 = it.getEntity();
    String _name_2 = _entity_5.getName();
    String _formatForDB_3 = this._formattingExtensions.formatForDB(_name_2);
    _builder.append(_formatForDB_3, "    ");
    _builder.append(".");
    String _name_3 = it.getName();
    String _formatForDB_4 = this._formattingExtensions.formatForDB(_name_3);
    _builder.append(_formatForDB_4, "    ");
    _builder.append("}\" title=\"{gt text=\'Switch to users administration\'}\">{gt text=\'Manage user\'}</a></span>");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("{/checkpermissionblock}");
    _builder.newLine();
    _builder.append("{/if}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence _formField(final AbstractDateField it, final String groupSuffix, final String idSuffix) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _formFieldDetails = this.formFieldDetails(it, groupSuffix, idSuffix);
    _builder.append(_formFieldDetails, "");
    _builder.newLineIfNotEmpty();
    {
      boolean _isPast = it.isPast();
      if (_isPast) {
        _builder.append("<span class=\"");
        {
          Entity _entity = it.getEntity();
          Models _container = _entity.getContainer();
          Application _application = _container.getApplication();
          boolean _targets = this._utils.targets(_application, "1.3.5");
          if (_targets) {
            _builder.append("z-formnote");
          } else {
            _builder.append("help-block");
          }
        }
        _builder.append("\">{gt text=\'Note: this value must be in the past.\'}</span>");
        _builder.newLineIfNotEmpty();
      } else {
        boolean _isFuture = it.isFuture();
        if (_isFuture) {
          _builder.append("<span class=\"");
          {
            Entity _entity_1 = it.getEntity();
            Models _container_1 = _entity_1.getContainer();
            Application _application_1 = _container_1.getApplication();
            boolean _targets_1 = this._utils.targets(_application_1, "1.3.5");
            if (_targets_1) {
              _builder.append("z-formnote");
            } else {
              _builder.append("help-block");
            }
          }
          _builder.append("\">{gt text=\'Note: this value must be in the future.\'}</span>");
          _builder.newLineIfNotEmpty();
        }
      }
    }
    return _builder;
  }
  
  private CharSequence _formFieldDetails(final AbstractDateField it, final String groupSuffix, final String idSuffix) {
    return null;
  }
  
  private CharSequence _formFieldDetails(final DatetimeField it, final String groupSuffix, final String idSuffix) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{if $mode ne \'create\'}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{formdateinput ");
    CharSequence _groupAndId = this.groupAndId(it, groupSuffix, idSuffix);
    _builder.append(_groupAndId, "    ");
    _builder.append(" mandatory=");
    boolean _isMandatory = it.isMandatory();
    String _displayBool = this._formattingExtensions.displayBool(Boolean.valueOf(_isMandatory));
    _builder.append(_displayBool, "    ");
    _builder.append(" __title=\'Enter the ");
    String _name = it.getName();
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(_name);
    _builder.append(_formatForDisplay, "    ");
    _builder.append(" of the ");
    Entity _entity = it.getEntity();
    String _name_1 = _entity.getName();
    String _formatForDisplay_1 = this._formattingExtensions.formatForDisplay(_name_1);
    _builder.append(_formatForDisplay_1, "    ");
    _builder.append("\' includeTime=true cssClass=\'");
    CharSequence _fieldValidationCssClass = this.validationHelper.fieldValidationCssClass(it);
    _builder.append(_fieldValidationCssClass, "    ");
    {
      Entity _entity_1 = it.getEntity();
      Models _container = _entity_1.getContainer();
      Application _application = _container.getApplication();
      boolean _targets = this._utils.targets(_application, "1.3.5");
      boolean _not = (!_targets);
      if (_not) {
        _builder.append(" form-control");
      }
    }
    _builder.append("\'}");
    _builder.newLineIfNotEmpty();
    _builder.append("{else}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{formdateinput ");
    CharSequence _groupAndId_1 = this.groupAndId(it, groupSuffix, idSuffix);
    _builder.append(_groupAndId_1, "    ");
    _builder.append(" mandatory=");
    boolean _isMandatory_1 = it.isMandatory();
    String _displayBool_1 = this._formattingExtensions.displayBool(Boolean.valueOf(_isMandatory_1));
    _builder.append(_displayBool_1, "    ");
    _builder.append(" __title=\'Enter the ");
    String _name_2 = it.getName();
    String _formatForDisplay_2 = this._formattingExtensions.formatForDisplay(_name_2);
    _builder.append(_formatForDisplay_2, "    ");
    _builder.append(" of the ");
    Entity _entity_2 = it.getEntity();
    String _name_3 = _entity_2.getName();
    String _formatForDisplay_3 = this._formattingExtensions.formatForDisplay(_name_3);
    _builder.append(_formatForDisplay_3, "    ");
    _builder.append("\' includeTime=true");
    {
      boolean _and = false;
      boolean _and_1 = false;
      String _defaultValue = it.getDefaultValue();
      boolean _tripleNotEquals = (_defaultValue != null);
      if (!_tripleNotEquals) {
        _and_1 = false;
      } else {
        String _defaultValue_1 = it.getDefaultValue();
        boolean _notEquals = (!Objects.equal(_defaultValue_1, ""));
        _and_1 = (_tripleNotEquals && _notEquals);
      }
      if (!_and_1) {
        _and = false;
      } else {
        String _defaultValue_2 = it.getDefaultValue();
        boolean _notEquals_1 = (!Objects.equal(_defaultValue_2, "now"));
        _and = (_and_1 && _notEquals_1);
      }
      if (_and) {
        _builder.append(" defaultValue=\'");
        String _defaultValue_3 = it.getDefaultValue();
        _builder.append(_defaultValue_3, "    ");
        _builder.append("\'");
      } else {
        boolean _or = false;
        boolean _isMandatory_2 = it.isMandatory();
        if (_isMandatory_2) {
          _or = true;
        } else {
          boolean _isNullable = it.isNullable();
          boolean _not_1 = (!_isNullable);
          _or = (_isMandatory_2 || _not_1);
        }
        if (_or) {
          _builder.append(" defaultValue=\'now\'");
        }
      }
    }
    _builder.append(" cssClass=\'");
    CharSequence _fieldValidationCssClass_1 = this.validationHelper.fieldValidationCssClass(it);
    _builder.append(_fieldValidationCssClass_1, "    ");
    {
      Entity _entity_3 = it.getEntity();
      Models _container_1 = _entity_3.getContainer();
      Application _application_1 = _container_1.getApplication();
      boolean _targets_1 = this._utils.targets(_application_1, "1.3.5");
      boolean _not_2 = (!_targets_1);
      if (_not_2) {
        _builder.append(" form-control");
      }
    }
    _builder.append("\'}");
    _builder.newLineIfNotEmpty();
    _builder.append("{/if}");
    _builder.newLine();
    _builder.newLine();
    {
      boolean _and_2 = false;
      boolean _isMandatory_3 = it.isMandatory();
      boolean _not_3 = (!_isMandatory_3);
      if (!_not_3) {
        _and_2 = false;
      } else {
        boolean _isNullable_1 = it.isNullable();
        _and_2 = (_not_3 && _isNullable_1);
      }
      if (_and_2) {
        _builder.append("<span class=\"");
        {
          Entity _entity_4 = it.getEntity();
          Models _container_2 = _entity_4.getContainer();
          Application _application_2 = _container_2.getApplication();
          boolean _targets_2 = this._utils.targets(_application_2, "1.3.5");
          if (_targets_2) {
            _builder.append("z-formnote");
          } else {
            _builder.append("help-block");
          }
        }
        _builder.append("\"><a id=\"reset");
        String _name_4 = it.getName();
        String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(_name_4);
        _builder.append(_formatForCodeCapital, "");
        _builder.append("Val\" href=\"javascript:void(0);\" class=\"");
        {
          Entity _entity_5 = it.getEntity();
          Models _container_3 = _entity_5.getContainer();
          Application _application_3 = _container_3.getApplication();
          boolean _targets_3 = this._utils.targets(_application_3, "1.3.5");
          if (_targets_3) {
            _builder.append("z-");
          }
        }
        _builder.append("hide\">{gt text=\'Reset to empty value\'}</a></span>");
        _builder.newLineIfNotEmpty();
      }
    }
    return _builder;
  }
  
  private CharSequence _formFieldDetails(final DateField it, final String groupSuffix, final String idSuffix) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{if $mode ne \'create\'}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{formdateinput ");
    CharSequence _groupAndId = this.groupAndId(it, groupSuffix, idSuffix);
    _builder.append(_groupAndId, "    ");
    _builder.append(" mandatory=");
    boolean _isMandatory = it.isMandatory();
    String _displayBool = this._formattingExtensions.displayBool(Boolean.valueOf(_isMandatory));
    _builder.append(_displayBool, "    ");
    _builder.append(" __title=\'Enter the ");
    String _name = it.getName();
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(_name);
    _builder.append(_formatForDisplay, "    ");
    _builder.append(" of the ");
    Entity _entity = it.getEntity();
    String _name_1 = _entity.getName();
    String _formatForDisplay_1 = this._formattingExtensions.formatForDisplay(_name_1);
    _builder.append(_formatForDisplay_1, "    ");
    _builder.append("\' useSelectionMode=true cssClass=\'");
    CharSequence _fieldValidationCssClass = this.validationHelper.fieldValidationCssClass(it);
    _builder.append(_fieldValidationCssClass, "    ");
    {
      Entity _entity_1 = it.getEntity();
      Models _container = _entity_1.getContainer();
      Application _application = _container.getApplication();
      boolean _targets = this._utils.targets(_application, "1.3.5");
      boolean _not = (!_targets);
      if (_not) {
        _builder.append(" form-control");
      }
    }
    _builder.append("\'}");
    _builder.newLineIfNotEmpty();
    _builder.append("{else}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{formdateinput ");
    CharSequence _groupAndId_1 = this.groupAndId(it, groupSuffix, idSuffix);
    _builder.append(_groupAndId_1, "    ");
    _builder.append(" mandatory=");
    boolean _isMandatory_1 = it.isMandatory();
    String _displayBool_1 = this._formattingExtensions.displayBool(Boolean.valueOf(_isMandatory_1));
    _builder.append(_displayBool_1, "    ");
    _builder.append(" __title=\'Enter the ");
    String _name_2 = it.getName();
    String _formatForDisplay_2 = this._formattingExtensions.formatForDisplay(_name_2);
    _builder.append(_formatForDisplay_2, "    ");
    _builder.append(" of the ");
    Entity _entity_2 = it.getEntity();
    String _name_3 = _entity_2.getName();
    String _formatForDisplay_3 = this._formattingExtensions.formatForDisplay(_name_3);
    _builder.append(_formatForDisplay_3, "    ");
    _builder.append("\' useSelectionMode=true");
    {
      boolean _and = false;
      boolean _and_1 = false;
      String _defaultValue = it.getDefaultValue();
      boolean _tripleNotEquals = (_defaultValue != null);
      if (!_tripleNotEquals) {
        _and_1 = false;
      } else {
        String _defaultValue_1 = it.getDefaultValue();
        boolean _notEquals = (!Objects.equal(_defaultValue_1, ""));
        _and_1 = (_tripleNotEquals && _notEquals);
      }
      if (!_and_1) {
        _and = false;
      } else {
        String _defaultValue_2 = it.getDefaultValue();
        boolean _notEquals_1 = (!Objects.equal(_defaultValue_2, "now"));
        _and = (_and_1 && _notEquals_1);
      }
      if (_and) {
        _builder.append(" defaultValue=\'");
        String _defaultValue_3 = it.getDefaultValue();
        _builder.append(_defaultValue_3, "    ");
        _builder.append("\'");
      } else {
        boolean _or = false;
        boolean _isMandatory_2 = it.isMandatory();
        if (_isMandatory_2) {
          _or = true;
        } else {
          boolean _isNullable = it.isNullable();
          boolean _not_1 = (!_isNullable);
          _or = (_isMandatory_2 || _not_1);
        }
        if (_or) {
          _builder.append(" defaultValue=\'today\'");
        }
      }
    }
    _builder.append(" cssClass=\'");
    CharSequence _fieldValidationCssClass_1 = this.validationHelper.fieldValidationCssClass(it);
    _builder.append(_fieldValidationCssClass_1, "    ");
    {
      Entity _entity_3 = it.getEntity();
      Models _container_1 = _entity_3.getContainer();
      Application _application_1 = _container_1.getApplication();
      boolean _targets_1 = this._utils.targets(_application_1, "1.3.5");
      boolean _not_2 = (!_targets_1);
      if (_not_2) {
        _builder.append(" form-control");
      }
    }
    _builder.append("\'}");
    _builder.newLineIfNotEmpty();
    _builder.append("{/if}");
    _builder.newLine();
    {
      boolean _and_2 = false;
      boolean _isMandatory_3 = it.isMandatory();
      boolean _not_3 = (!_isMandatory_3);
      if (!_not_3) {
        _and_2 = false;
      } else {
        boolean _isNullable_1 = it.isNullable();
        _and_2 = (_not_3 && _isNullable_1);
      }
      if (_and_2) {
        _builder.append("<span class=\"");
        {
          Entity _entity_4 = it.getEntity();
          Models _container_2 = _entity_4.getContainer();
          Application _application_2 = _container_2.getApplication();
          boolean _targets_2 = this._utils.targets(_application_2, "1.3.5");
          if (_targets_2) {
            _builder.append("z-formnote");
          } else {
            _builder.append("help-block");
          }
        }
        _builder.append("\"><a id=\"reset");
        String _name_4 = it.getName();
        String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(_name_4);
        _builder.append(_formatForCodeCapital, "");
        _builder.append("Val\" href=\"javascript:void(0);\" class=\"");
        {
          Entity _entity_5 = it.getEntity();
          Models _container_3 = _entity_5.getContainer();
          Application _application_3 = _container_3.getApplication();
          boolean _targets_3 = this._utils.targets(_application_3, "1.3.5");
          if (_targets_3) {
            _builder.append("z-");
          }
        }
        _builder.append("hide\">{gt text=\'Reset to empty value\'}</a></span>");
        _builder.newLineIfNotEmpty();
      }
    }
    return _builder;
  }
  
  private CharSequence _formFieldDetails(final TimeField it, final String groupSuffix, final String idSuffix) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("{* TODO: support time fields in Zikula (see https://github.com/Guite/MostGenerator/issues/87 for more information) *}");
    _builder.newLine();
    _builder.append("{formtextinput ");
    CharSequence _groupAndId = this.groupAndId(it, groupSuffix, idSuffix);
    _builder.append(_groupAndId, "");
    _builder.append(" mandatory=");
    boolean _isMandatory = it.isMandatory();
    String _displayBool = this._formattingExtensions.displayBool(Boolean.valueOf(_isMandatory));
    _builder.append(_displayBool, "");
    _builder.append(" readOnly=");
    boolean _isReadonly = it.isReadonly();
    String _displayBool_1 = this._formattingExtensions.displayBool(Boolean.valueOf(_isReadonly));
    _builder.append(_displayBool_1, "");
    _builder.append(" __title=\'Enter the ");
    String _name = it.getName();
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(_name);
    _builder.append(_formatForDisplay, "");
    _builder.append(" of the ");
    Entity _entity = it.getEntity();
    String _name_1 = _entity.getName();
    String _formatForDisplay_1 = this._formattingExtensions.formatForDisplay(_name_1);
    _builder.append(_formatForDisplay_1, "");
    _builder.append("\' textMode=\'singleline\' maxLength=8 cssClass=\'");
    CharSequence _fieldValidationCssClass = this.validationHelper.fieldValidationCssClass(it);
    _builder.append(_fieldValidationCssClass, "");
    {
      Entity _entity_1 = it.getEntity();
      Models _container = _entity_1.getContainer();
      Application _application = _container.getApplication();
      boolean _targets = this._utils.targets(_application, "1.3.5");
      boolean _not = (!_targets);
      if (_not) {
        _builder.append(" form-control");
      }
    }
    _builder.append("\'}");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence formLabel(final DerivedField it, final String groupSuffix, final String idSuffix) {
    if (it instanceof UploadField) {
      return _formLabel((UploadField)it, groupSuffix, idSuffix);
    } else if (it != null) {
      return _formLabel(it, groupSuffix, idSuffix);
    } else {
      throw new IllegalArgumentException("Unhandled parameter types: " +
        Arrays.<Object>asList(it, groupSuffix, idSuffix).toString());
    }
  }
  
  private CharSequence formField(final DerivedField it, final String groupSuffix, final String idSuffix) {
    if (it instanceof EmailField) {
      return _formField((EmailField)it, groupSuffix, idSuffix);
    } else if (it instanceof IntegerField) {
      return _formField((IntegerField)it, groupSuffix, idSuffix);
    } else if (it instanceof ListField) {
      return _formField((ListField)it, groupSuffix, idSuffix);
    } else if (it instanceof StringField) {
      return _formField((StringField)it, groupSuffix, idSuffix);
    } else if (it instanceof TextField) {
      return _formField((TextField)it, groupSuffix, idSuffix);
    } else if (it instanceof UploadField) {
      return _formField((UploadField)it, groupSuffix, idSuffix);
    } else if (it instanceof UrlField) {
      return _formField((UrlField)it, groupSuffix, idSuffix);
    } else if (it instanceof UserField) {
      return _formField((UserField)it, groupSuffix, idSuffix);
    } else if (it instanceof DecimalField) {
      return _formField((DecimalField)it, groupSuffix, idSuffix);
    } else if (it instanceof FloatField) {
      return _formField((FloatField)it, groupSuffix, idSuffix);
    } else if (it instanceof AbstractDateField) {
      return _formField((AbstractDateField)it, groupSuffix, idSuffix);
    } else if (it instanceof BooleanField) {
      return _formField((BooleanField)it, groupSuffix, idSuffix);
    } else {
      throw new IllegalArgumentException("Unhandled parameter types: " +
        Arrays.<Object>asList(it, groupSuffix, idSuffix).toString());
    }
  }
  
  private CharSequence formFieldDetails(final AbstractDateField it, final String groupSuffix, final String idSuffix) {
    if (it instanceof DateField) {
      return _formFieldDetails((DateField)it, groupSuffix, idSuffix);
    } else if (it instanceof DatetimeField) {
      return _formFieldDetails((DatetimeField)it, groupSuffix, idSuffix);
    } else if (it instanceof TimeField) {
      return _formFieldDetails((TimeField)it, groupSuffix, idSuffix);
    } else if (it != null) {
      return _formFieldDetails(it, groupSuffix, idSuffix);
    } else {
      throw new IllegalArgumentException("Unhandled parameter types: " +
        Arrays.<Object>asList(it, groupSuffix, idSuffix).toString());
    }
  }
}
