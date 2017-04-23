package org.zikula.modulestudio.generator.cartridges.zclassic.controller.javascript;

import com.google.common.collect.Iterables;
import de.guite.modulestudio.metamodel.AbstractDateField;
import de.guite.modulestudio.metamodel.Application;
import de.guite.modulestudio.metamodel.DataObject;
import de.guite.modulestudio.metamodel.DateField;
import de.guite.modulestudio.metamodel.DatetimeField;
import de.guite.modulestudio.metamodel.DerivedField;
import de.guite.modulestudio.metamodel.TimeField;
import org.eclipse.emf.common.util.EList;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.InputOutput;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class Validation {
  @Extension
  private FormattingExtensions _formattingExtensions = new FormattingExtensions();
  
  @Extension
  private ModelExtensions _modelExtensions = new ModelExtensions();
  
  @Extension
  private NamingExtensions _namingExtensions = new NamingExtensions();
  
  @Extension
  private Utils _utils = new Utils();
  
  /**
   * Entry point for the JavaScript file with validation functionality.
   */
  public void generate(final Application it, final IFileSystemAccess fsa) {
    String _appName = this._utils.appName(it);
    String fileName = (_appName + ".Validation.js");
    String _appJsPath = this._namingExtensions.getAppJsPath(it);
    String _plus = (_appJsPath + fileName);
    boolean _shouldBeSkipped = this._namingExtensions.shouldBeSkipped(it, _plus);
    boolean _not = (!_shouldBeSkipped);
    if (_not) {
      InputOutput.<String>println("Generating JavaScript for validation");
      String _appJsPath_1 = this._namingExtensions.getAppJsPath(it);
      String _plus_1 = (_appJsPath_1 + fileName);
      boolean _shouldBeMarked = this._namingExtensions.shouldBeMarked(it, _plus_1);
      if (_shouldBeMarked) {
        String _appName_1 = this._utils.appName(it);
        String _plus_2 = (_appName_1 + ".Validation.generated.js");
        fileName = _plus_2;
      }
      String _appJsPath_2 = this._namingExtensions.getAppJsPath(it);
      String _plus_3 = (_appJsPath_2 + fileName);
      fsa.generateFile(_plus_3, this.generate(it));
    }
  }
  
  private CharSequence generate(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("\'use strict\';");
    _builder.newLine();
    _builder.newLine();
    _builder.append("function ");
    String _vendorAndName = this._utils.vendorAndName(it);
    _builder.append(_vendorAndName);
    _builder.append("Today(format)");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("var timestamp, todayDate, month, day, hours, minutes, seconds;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("timestamp = new Date();");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("todayDate = \'\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (format !== \'time\') {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("month = new String((parseInt(timestamp.getMonth()) + 1));");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if (month.length === 1) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("month = \'0\' + month;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("day = new String(timestamp.getDate());");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if (day.length === 1) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("day = \'0\' + day;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("todayDate += timestamp.getFullYear() + \'-\' + month + \'-\' + day;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (format === \'datetime\') {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("todayDate += \' \';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (format != \'date\') {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("hours = new String(timestamp.getHours());");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if (hours.length === 1) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("hours = \'0\' + hours;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("minutes = new String(timestamp.getMinutes());");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if (minutes.length === 1) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("minutes = \'0\' + minutes;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("seconds = new String(timestamp.getSeconds());");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if (seconds.length === 1) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("seconds = \'0\' + seconds;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("todayDate += hours + \':\' + minutes;// + \':\' + seconds;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return todayDate;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("// returns YYYY-MM-DD even if date is in DD.MM.YYYY");
    _builder.newLine();
    _builder.append("function ");
    String _vendorAndName_1 = this._utils.vendorAndName(it);
    _builder.append(_vendorAndName_1);
    _builder.append("ReadDate(val, includeTime)");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// look if we have YYYY-MM-DD");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (val.substr(4, 1) === \'-\' && val.substr(7, 1) === \'-\') {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return val;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// look if we have DD.MM.YYYY");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (val.substr(2, 1) === \'.\' && val.substr(5, 1) === \'.\') {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("var newVal = val.substr(6, 4) + \'-\' + val.substr(3, 2) + \'-\' + val.substr(0, 2);");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if (true === includeTime) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("newVal += \' \' + val.substr(11, 7);");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return newVal;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    {
      final Function1<DataObject, Boolean> _function = (DataObject it_1) -> {
        final Function1<DerivedField, Boolean> _function_1 = (DerivedField it_2) -> {
          boolean _isPrimaryKey = it_2.isPrimaryKey();
          return Boolean.valueOf((!_isPrimaryKey));
        };
        int _size = IterableExtensions.size(IterableExtensions.<DerivedField>filter(this._modelExtensions.getUniqueDerivedFields(it_1), _function_1));
        return Boolean.valueOf((_size > 0));
      };
      boolean _exists = IterableExtensions.<DataObject>exists(it.getEntities(), _function);
      if (_exists) {
        _builder.newLine();
        {
          EList<DataObject> _entities = it.getEntities();
          for(final DataObject entity : _entities) {
            {
              final Function1<DerivedField, Boolean> _function_1 = (DerivedField it_1) -> {
                boolean _isPrimaryKey = it_1.isPrimaryKey();
                return Boolean.valueOf((!_isPrimaryKey));
              };
              Iterable<DerivedField> _filter = IterableExtensions.<DerivedField>filter(this._modelExtensions.getUniqueDerivedFields(entity), _function_1);
              for(final DerivedField field : _filter) {
                _builder.append("var last");
                String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(entity.getName());
                _builder.append(_formatForCodeCapital);
                String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(field.getName());
                _builder.append(_formatForCodeCapital_1);
                _builder.append(" = \'\';");
                _builder.newLineIfNotEmpty();
              }
            }
          }
        }
        _builder.newLine();
        _builder.append("/**");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Performs a duplicate check for unique fields");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
        _builder.append("function ");
        String _vendorAndName_2 = this._utils.vendorAndName(it);
        _builder.append(_vendorAndName_2);
        _builder.append("UniqueCheck(ucOt, val, elem, ucEx)");
        _builder.newLineIfNotEmpty();
        _builder.append("{");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("if (elem.val() == window[\'last\' + ");
        String _vendorAndName_3 = this._utils.vendorAndName(it);
        _builder.append(_vendorAndName_3, "    ");
        _builder.append("CapitaliseFirstLetter(ucOt) + ");
        String _vendorAndName_4 = this._utils.vendorAndName(it);
        _builder.append(_vendorAndName_4, "    ");
        _builder.append("CapitaliseFirstLetter(elem.attr(\'id\')) ]) {");
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        _builder.append("return true;");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("window[\'last\' + ");
        String _vendorAndName_5 = this._utils.vendorAndName(it);
        _builder.append(_vendorAndName_5, "    ");
        _builder.append("CapitaliseFirstLetter(ucOt) + ");
        String _vendorAndName_6 = this._utils.vendorAndName(it);
        _builder.append(_vendorAndName_6, "    ");
        _builder.append("CapitaliseFirstLetter(elem.attr(\'id\')) ] = elem.val();");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("var result = true;");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("jQuery.ajax({");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("type: \'POST\',");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("url: Routing.generate(\'");
        String _formatForDB = this._formattingExtensions.formatForDB(this._utils.appName(it));
        _builder.append(_formatForDB, "        ");
        _builder.append("_ajax_checkforduplicate\'),");
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        _builder.append("data: {");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("ot: ucOt,");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("fn: encodeURIComponent(elem.attr(\'id\')),");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("v: encodeURIComponent(val),");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("ex: ucEx");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("},");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("async: false");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("}).done(function(res) {");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("if (null == res.data || true === res.data.isDuplicate) {");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("result = false;");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("})");
        _builder.append(";");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("return result;");
        _builder.newLine();
        _builder.append("}");
        _builder.newLine();
      }
    }
    _builder.newLine();
    _builder.append("function ");
    String _vendorAndName_7 = this._utils.vendorAndName(it);
    _builder.append(_vendorAndName_7);
    _builder.append("ValidateNoSpace(val)");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("var valStr;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("valStr = new String(val);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return (valStr.indexOf(\' \') === -1);");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    {
      boolean _hasColourFields = this._modelExtensions.hasColourFields(it);
      if (_hasColourFields) {
        _builder.newLine();
        _builder.append("function ");
        String _vendorAndName_8 = this._utils.vendorAndName(it);
        _builder.append(_vendorAndName_8);
        _builder.append("ValidateHtmlColour(val)");
        _builder.newLineIfNotEmpty();
        _builder.append("{");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("var valStr;");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("valStr = new String(val);");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("return valStr === \'\' || (/^#[0-9a-f]{3}([0-9a-f]{3})?$/i.test(valStr));");
        _builder.newLine();
        _builder.append("}");
        _builder.newLine();
      }
    }
    {
      boolean _hasUploads = this._modelExtensions.hasUploads(it);
      if (_hasUploads) {
        _builder.newLine();
        _builder.append("function ");
        String _vendorAndName_9 = this._utils.vendorAndName(it);
        _builder.append(_vendorAndName_9);
        _builder.append("ValidateUploadExtension(val, elem)");
        _builder.newLineIfNotEmpty();
        _builder.append("{");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("var fileExtension, allowedExtensions;");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("if (val === \'\') {");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("return true;");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("fileExtension = \'.\' + val.substr(val.lastIndexOf(\'.\') + 1);");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("allowedExtensions = jQuery(\'#\' + elem.attr(\'id\') + \'FileExtensions\').text();");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("allowedExtensions = \'(.\' + allowedExtensions.replace(/, /g, \'|.\').replace(/,/g, \'|.\') + \')$\';");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("allowedExtensions = new RegExp(allowedExtensions, \'i\');");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("return allowedExtensions.test(val);");
        _builder.newLine();
        _builder.append("}");
        _builder.newLine();
      }
    }
    final Iterable<DatetimeField> datetimeFields = Iterables.<DatetimeField>filter(this._modelExtensions.getAllEntityFields(it), DatetimeField.class);
    _builder.newLineIfNotEmpty();
    {
      boolean _isEmpty = IterableExtensions.isEmpty(datetimeFields);
      boolean _not = (!_isEmpty);
      if (_not) {
        {
          final Function1<DatetimeField, Boolean> _function_2 = (DatetimeField it_1) -> {
            return Boolean.valueOf(it_1.isPast());
          };
          boolean _exists_1 = IterableExtensions.<DatetimeField>exists(datetimeFields, _function_2);
          if (_exists_1) {
            _builder.newLine();
            _builder.append("function ");
            String _vendorAndName_10 = this._utils.vendorAndName(it);
            _builder.append(_vendorAndName_10);
            _builder.append("ValidateDatetimePast(val)");
            _builder.newLineIfNotEmpty();
            _builder.append("{");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("var valStr, cmpVal;");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("valStr = new String(val);");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("cmpVal = ");
            String _vendorAndName_11 = this._utils.vendorAndName(it);
            _builder.append(_vendorAndName_11, "    ");
            _builder.append("ReadDate(valStr, true);");
            _builder.newLineIfNotEmpty();
            _builder.newLine();
            _builder.append("    ");
            _builder.append("return valStr === \'\' || (cmpVal < ");
            String _vendorAndName_12 = this._utils.vendorAndName(it);
            _builder.append(_vendorAndName_12, "    ");
            _builder.append("Today(\'datetime\'));");
            _builder.newLineIfNotEmpty();
            _builder.append("}");
            _builder.newLine();
          }
        }
        {
          final Function1<DatetimeField, Boolean> _function_3 = (DatetimeField it_1) -> {
            return Boolean.valueOf(it_1.isFuture());
          };
          boolean _exists_2 = IterableExtensions.<DatetimeField>exists(datetimeFields, _function_3);
          if (_exists_2) {
            _builder.newLine();
            _builder.append("function ");
            String _vendorAndName_13 = this._utils.vendorAndName(it);
            _builder.append(_vendorAndName_13);
            _builder.append("ValidateDatetimeFuture(val)");
            _builder.newLineIfNotEmpty();
            _builder.append("{");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("var valStr, cmpVal;");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("valStr = new String(val);");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("cmpVal = ");
            String _vendorAndName_14 = this._utils.vendorAndName(it);
            _builder.append(_vendorAndName_14, "    ");
            _builder.append("ReadDate(valStr, true);");
            _builder.newLineIfNotEmpty();
            _builder.newLine();
            _builder.append("    ");
            _builder.append("return valStr === \'\' || (cmpVal > ");
            String _vendorAndName_15 = this._utils.vendorAndName(it);
            _builder.append(_vendorAndName_15, "    ");
            _builder.append("Today(\'datetime\'));");
            _builder.newLineIfNotEmpty();
            _builder.append("}");
            _builder.newLine();
          }
        }
      }
    }
    final Iterable<DateField> dateFields = Iterables.<DateField>filter(this._modelExtensions.getAllEntityFields(it), DateField.class);
    _builder.newLineIfNotEmpty();
    {
      boolean _isEmpty_1 = IterableExtensions.isEmpty(dateFields);
      boolean _not_1 = (!_isEmpty_1);
      if (_not_1) {
        {
          final Function1<DateField, Boolean> _function_4 = (DateField it_1) -> {
            return Boolean.valueOf(it_1.isPast());
          };
          boolean _exists_3 = IterableExtensions.<DateField>exists(dateFields, _function_4);
          if (_exists_3) {
            _builder.newLine();
            _builder.append("function ");
            String _vendorAndName_16 = this._utils.vendorAndName(it);
            _builder.append(_vendorAndName_16);
            _builder.append("ValidateDatePast(val)");
            _builder.newLineIfNotEmpty();
            _builder.append("{");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("var valStr, cmpVal;");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("valStr = new String(val);");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("cmpVal = ");
            String _vendorAndName_17 = this._utils.vendorAndName(it);
            _builder.append(_vendorAndName_17, "    ");
            _builder.append("ReadDate(valStr, false);");
            _builder.newLineIfNotEmpty();
            _builder.newLine();
            _builder.append("    ");
            _builder.append("return valStr === \'\' || (cmpVal < ");
            String _vendorAndName_18 = this._utils.vendorAndName(it);
            _builder.append(_vendorAndName_18, "    ");
            _builder.append("Today(\'date\'));");
            _builder.newLineIfNotEmpty();
            _builder.append("}");
            _builder.newLine();
          }
        }
        {
          final Function1<DateField, Boolean> _function_5 = (DateField it_1) -> {
            return Boolean.valueOf(it_1.isFuture());
          };
          boolean _exists_4 = IterableExtensions.<DateField>exists(dateFields, _function_5);
          if (_exists_4) {
            _builder.newLine();
            _builder.append("function ");
            String _vendorAndName_19 = this._utils.vendorAndName(it);
            _builder.append(_vendorAndName_19);
            _builder.append("ValidateDateFuture(val)");
            _builder.newLineIfNotEmpty();
            _builder.append("{");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("var valStr, cmpVal;");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("valStr = new String(val);");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("cmpVal = ");
            String _vendorAndName_20 = this._utils.vendorAndName(it);
            _builder.append(_vendorAndName_20, "    ");
            _builder.append("ReadDate(valStr, false);");
            _builder.newLineIfNotEmpty();
            _builder.newLine();
            _builder.append("    ");
            _builder.append("return valStr === \'\' || (cmpVal > ");
            String _vendorAndName_21 = this._utils.vendorAndName(it);
            _builder.append(_vendorAndName_21, "    ");
            _builder.append("Today(\'date\'));");
            _builder.newLineIfNotEmpty();
            _builder.append("}");
            _builder.newLine();
          }
        }
      }
    }
    final Iterable<TimeField> timeFields = Iterables.<TimeField>filter(this._modelExtensions.getAllEntityFields(it), TimeField.class);
    _builder.newLineIfNotEmpty();
    {
      boolean _isEmpty_2 = IterableExtensions.isEmpty(timeFields);
      boolean _not_2 = (!_isEmpty_2);
      if (_not_2) {
        {
          final Function1<TimeField, Boolean> _function_6 = (TimeField it_1) -> {
            return Boolean.valueOf(it_1.isPast());
          };
          boolean _exists_5 = IterableExtensions.<TimeField>exists(timeFields, _function_6);
          if (_exists_5) {
            _builder.newLine();
            _builder.append("function ");
            String _vendorAndName_22 = this._utils.vendorAndName(it);
            _builder.append(_vendorAndName_22);
            _builder.append("ValidateTimePast(val)");
            _builder.newLineIfNotEmpty();
            _builder.append("{");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("var cmpVal;");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("cmpVal = new String(val);");
            _builder.newLine();
            _builder.newLine();
            _builder.append("    ");
            _builder.append("return cmpVal === \'\' || (cmpVal < ");
            String _vendorAndName_23 = this._utils.vendorAndName(it);
            _builder.append(_vendorAndName_23, "    ");
            _builder.append("Today(\'time\'));");
            _builder.newLineIfNotEmpty();
            _builder.append("}");
            _builder.newLine();
          }
        }
        {
          final Function1<TimeField, Boolean> _function_7 = (TimeField it_1) -> {
            return Boolean.valueOf(it_1.isFuture());
          };
          boolean _exists_6 = IterableExtensions.<TimeField>exists(timeFields, _function_7);
          if (_exists_6) {
            _builder.newLine();
            _builder.append("function ");
            String _vendorAndName_24 = this._utils.vendorAndName(it);
            _builder.append(_vendorAndName_24);
            _builder.append("ValidateTimeFuture(val)");
            _builder.newLineIfNotEmpty();
            _builder.append("{");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("var cmpVal;");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("cmpVal = new String(val);");
            _builder.newLine();
            _builder.newLine();
            _builder.append("    ");
            _builder.append("return cmpVal === \'\' || (cmpVal > ");
            String _vendorAndName_25 = this._utils.vendorAndName(it);
            _builder.append(_vendorAndName_25, "    ");
            _builder.append("Today(\'time\'));");
            _builder.newLineIfNotEmpty();
            _builder.append("}");
            _builder.newLine();
          }
        }
      }
    }
    {
      EList<DataObject> _entities_1 = it.getEntities();
      for(final DataObject entity_1 : _entities_1) {
        final AbstractDateField startDateField = this._modelExtensions.getStartDateField(entity_1);
        _builder.newLineIfNotEmpty();
        final AbstractDateField endDateField = this._modelExtensions.getEndDateField(entity_1);
        _builder.newLineIfNotEmpty();
        {
          if (((null != startDateField) && (null != endDateField))) {
            _builder.newLine();
            _builder.append("function ");
            String _vendorAndName_26 = this._utils.vendorAndName(it);
            _builder.append(_vendorAndName_26);
            _builder.append("ValidateDateRange");
            String _formatForCodeCapital_2 = this._formattingExtensions.formatForCodeCapital(entity_1.getName());
            _builder.append(_formatForCodeCapital_2);
            _builder.append("(val)");
            _builder.newLineIfNotEmpty();
            _builder.append("{");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("var cmpVal, cmpVal2, result;");
            _builder.newLine();
            _builder.append("    ");
            final String startFieldName = this._formattingExtensions.formatForCode(startDateField.getName());
            _builder.newLineIfNotEmpty();
            _builder.append("    ");
            final String endFieldName = this._formattingExtensions.formatForCode(endDateField.getName());
            _builder.newLineIfNotEmpty();
            _builder.append("    ");
            _builder.append("cmpVal = ");
            String _vendorAndName_27 = this._utils.vendorAndName(it);
            _builder.append(_vendorAndName_27, "    ");
            _builder.append("ReadDate(jQuery(\"[id$=\'");
            _builder.append(startFieldName, "    ");
            _builder.append("\']\").val(), ");
            String _displayBool = this._formattingExtensions.displayBool(Boolean.valueOf((startDateField instanceof DatetimeField)));
            _builder.append(_displayBool, "    ");
            _builder.append(");");
            _builder.newLineIfNotEmpty();
            _builder.append("    ");
            _builder.append("cmpVal2 = ");
            String _vendorAndName_28 = this._utils.vendorAndName(it);
            _builder.append(_vendorAndName_28, "    ");
            _builder.append("ReadDate(jQuery(\"[id$=\'");
            _builder.append(endFieldName, "    ");
            _builder.append("\']\").val(), ");
            String _displayBool_1 = this._formattingExtensions.displayBool(Boolean.valueOf((endDateField instanceof DatetimeField)));
            _builder.append(_displayBool_1, "    ");
            _builder.append(");");
            _builder.newLineIfNotEmpty();
            _builder.newLine();
            _builder.append("    ");
            _builder.append("if (typeof cmpVal == \'undefined\' && typeof cmpVal2 == \'undefined\') {");
            _builder.newLine();
            _builder.append("        ");
            _builder.append("result = true;");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("} else {");
            _builder.newLine();
            _builder.append("        ");
            _builder.append("result = (cmpVal <= cmpVal2);");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("}");
            _builder.newLine();
            _builder.newLine();
            _builder.append("    ");
            _builder.append("return result;");
            _builder.newLine();
            _builder.append("}");
            _builder.newLine();
          }
        }
      }
    }
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Runs special validation rules.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("function ");
    String _vendorAndName_29 = this._utils.vendorAndName(it);
    _builder.append(_vendorAndName_29);
    _builder.append("ExecuteCustomValidationConstraints(objectType, currentEntityId)");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("jQuery(\'.validate-nospace\').each( function() {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if (!");
    String _vendorAndName_30 = this._utils.vendorAndName(it);
    _builder.append(_vendorAndName_30, "        ");
    _builder.append("ValidateNoSpace(jQuery(this).val())) {");
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    _builder.append("document.getElementById(jQuery(this).attr(\'id\')).setCustomValidity(Translator.__(\'This value must not contain spaces.\'));");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("} else {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("document.getElementById(jQuery(this).attr(\'id\')).setCustomValidity(\'\');");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("});");
    _builder.newLine();
    {
      boolean _hasColourFields_1 = this._modelExtensions.hasColourFields(it);
      if (_hasColourFields_1) {
        _builder.append("    ");
        _builder.append("jQuery(\'.validate-htmlcolour\').each( function() {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("if (!");
        String _vendorAndName_31 = this._utils.vendorAndName(it);
        _builder.append(_vendorAndName_31, "        ");
        _builder.append("ValidateHtmlColour(jQuery(this).val())) {");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("        ");
        _builder.append("document.getElementById(jQuery(this).attr(\'id\')).setCustomValidity(Translator.__(\'Please select a valid html colour code.\'));");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("} else {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("        ");
        _builder.append("document.getElementById(jQuery(this).attr(\'id\')).setCustomValidity(\'\');");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("});");
        _builder.newLine();
      }
    }
    {
      boolean _hasUploads_1 = this._modelExtensions.hasUploads(it);
      if (_hasUploads_1) {
        _builder.append("    ");
        _builder.append("jQuery(\'.validate-upload\').each( function() {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("if (!");
        String _vendorAndName_32 = this._utils.vendorAndName(it);
        _builder.append(_vendorAndName_32, "        ");
        _builder.append("ValidateUploadExtension(jQuery(this).val(), jQuery(this))) {");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("        ");
        _builder.append("document.getElementById(jQuery(this).attr(\'id\')).setCustomValidity(Translator.__(\'Please select a valid file extension.\'));");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("} else {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("        ");
        _builder.append("document.getElementById(jQuery(this).attr(\'id\')).setCustomValidity(\'\');");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("});");
        _builder.newLine();
      }
    }
    {
      boolean _isEmpty_3 = IterableExtensions.isEmpty(datetimeFields);
      boolean _not_3 = (!_isEmpty_3);
      if (_not_3) {
        {
          final Function1<DatetimeField, Boolean> _function_8 = (DatetimeField it_1) -> {
            return Boolean.valueOf(it_1.isPast());
          };
          boolean _exists_7 = IterableExtensions.<DatetimeField>exists(datetimeFields, _function_8);
          if (_exists_7) {
            _builder.append("    ");
            _builder.append("jQuery(\'.validate-datetime-past\').each( function() {");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("if (!");
            String _vendorAndName_33 = this._utils.vendorAndName(it);
            _builder.append(_vendorAndName_33, "        ");
            _builder.append("ValidateDatetimePast(jQuery(jQuery(this).attr(\'id\') + \'_date\').val() + \' \' + jQuery(jQuery(this).attr(\'id\') + \'_time\').val())) {");
            _builder.newLineIfNotEmpty();
            _builder.append("    ");
            _builder.append("        ");
            _builder.append("document.getElementById(jQuery(this).attr(\'id\') + \'_date\').setCustomValidity(Translator.__(\'Please select a value in the past.\'));");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("        ");
            _builder.append("document.getElementById(jQuery(this).attr(\'id\') + \'_time\').setCustomValidity(Translator.__(\'Please select a value in the past.\'));");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("} else {");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("        ");
            _builder.append("document.getElementById(jQuery(this).attr(\'id\') + \'_date\').setCustomValidity(\'\');");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("        ");
            _builder.append("document.getElementById(jQuery(this).attr(\'id\') + \'_time\').setCustomValidity(\'\');");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("}");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("});");
            _builder.newLine();
          }
        }
        {
          final Function1<DatetimeField, Boolean> _function_9 = (DatetimeField it_1) -> {
            return Boolean.valueOf(it_1.isFuture());
          };
          boolean _exists_8 = IterableExtensions.<DatetimeField>exists(datetimeFields, _function_9);
          if (_exists_8) {
            _builder.append("    ");
            _builder.append("jQuery(\'.validate-datetime-future\').each( function() {");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("if (!");
            String _vendorAndName_34 = this._utils.vendorAndName(it);
            _builder.append(_vendorAndName_34, "        ");
            _builder.append("ValidateDatetimeFuture(jQuery(jQuery(this).attr(\'id\') + \'_date\').val() + \' \' + jQuery(jQuery(this).attr(\'id\') + \'_time\').val())) {");
            _builder.newLineIfNotEmpty();
            _builder.append("    ");
            _builder.append("        ");
            _builder.append("document.getElementById(jQuery(this).attr(\'id\') + \'_date\').setCustomValidity(Translator.__(\'Please select a value in the future.\'));");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("        ");
            _builder.append("document.getElementById(jQuery(this).attr(\'id\') + \'_time\').setCustomValidity(Translator.__(\'Please select a value in the future.\'));");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("} else {");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("        ");
            _builder.append("document.getElementById(jQuery(this).attr(\'id\') + \'_date\').setCustomValidity(\'\');");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("        ");
            _builder.append("document.getElementById(jQuery(this).attr(\'id\') + \'_time\').setCustomValidity(\'\');");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("}");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("});");
            _builder.newLine();
          }
        }
      }
    }
    {
      boolean _isEmpty_4 = IterableExtensions.isEmpty(dateFields);
      boolean _not_4 = (!_isEmpty_4);
      if (_not_4) {
        {
          final Function1<DateField, Boolean> _function_10 = (DateField it_1) -> {
            return Boolean.valueOf(it_1.isPast());
          };
          boolean _exists_9 = IterableExtensions.<DateField>exists(dateFields, _function_10);
          if (_exists_9) {
            _builder.append("    ");
            _builder.append("jQuery(\'.validate-date-past\').each( function() {");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("if (!");
            String _vendorAndName_35 = this._utils.vendorAndName(it);
            _builder.append(_vendorAndName_35, "        ");
            _builder.append("ValidateDatePast(jQuery(this).val())) {");
            _builder.newLineIfNotEmpty();
            _builder.append("    ");
            _builder.append("        ");
            _builder.append("document.getElementById(jQuery(this).attr(\'id\')).setCustomValidity(Translator.__(\'Please select a value in the past.\'));");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("} else {");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("        ");
            _builder.append("document.getElementById(jQuery(this).attr(\'id\')).setCustomValidity(\'\');");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("}");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("});");
            _builder.newLine();
          }
        }
        {
          final Function1<DateField, Boolean> _function_11 = (DateField it_1) -> {
            return Boolean.valueOf(it_1.isFuture());
          };
          boolean _exists_10 = IterableExtensions.<DateField>exists(dateFields, _function_11);
          if (_exists_10) {
            _builder.append("    ");
            _builder.append("jQuery(\'.validate-date-future\').each( function() {");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("if (!");
            String _vendorAndName_36 = this._utils.vendorAndName(it);
            _builder.append(_vendorAndName_36, "        ");
            _builder.append("ValidateDateFuture(jQuery(this).val())) {");
            _builder.newLineIfNotEmpty();
            _builder.append("    ");
            _builder.append("        ");
            _builder.append("document.getElementById(jQuery(this).attr(\'id\')).setCustomValidity(Translator.__(\'Please select a value in the future.\'));");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("} else {");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("        ");
            _builder.append("document.getElementById(jQuery(this).attr(\'id\')).setCustomValidity(\'\');");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("}");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("});");
            _builder.newLine();
          }
        }
      }
    }
    {
      boolean _isEmpty_5 = IterableExtensions.isEmpty(timeFields);
      boolean _not_5 = (!_isEmpty_5);
      if (_not_5) {
        {
          final Function1<TimeField, Boolean> _function_12 = (TimeField it_1) -> {
            return Boolean.valueOf(it_1.isPast());
          };
          boolean _exists_11 = IterableExtensions.<TimeField>exists(timeFields, _function_12);
          if (_exists_11) {
            _builder.append("    ");
            _builder.append("jQuery(\'.validate-time-past\').each( function() {");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("if (!");
            String _vendorAndName_37 = this._utils.vendorAndName(it);
            _builder.append(_vendorAndName_37, "        ");
            _builder.append("ValidateTimePast(jQuery(this).val())) {");
            _builder.newLineIfNotEmpty();
            _builder.append("    ");
            _builder.append("        ");
            _builder.append("document.getElementById(jQuery(this).attr(\'id\')).setCustomValidity(Translator.__(\'Please select a value in the past.\'));");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("} else {");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("        ");
            _builder.append("document.getElementById(jQuery(this).attr(\'id\')).setCustomValidity(\'\');");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("}");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("});");
            _builder.newLine();
          }
        }
        {
          final Function1<TimeField, Boolean> _function_13 = (TimeField it_1) -> {
            return Boolean.valueOf(it_1.isFuture());
          };
          boolean _exists_12 = IterableExtensions.<TimeField>exists(timeFields, _function_13);
          if (_exists_12) {
            _builder.append("    ");
            _builder.append("jQuery(\'.validate-time-future\').each( function() {");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("if (!");
            String _vendorAndName_38 = this._utils.vendorAndName(it);
            _builder.append(_vendorAndName_38, "        ");
            _builder.append("ValidateTimeFuture(jQuery(this).val())) {");
            _builder.newLineIfNotEmpty();
            _builder.append("    ");
            _builder.append("        ");
            _builder.append("document.getElementById(jQuery(this).attr(\'id\')).setCustomValidity(Translator.__(\'Please select a value in the future.\'));");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("} else {");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("        ");
            _builder.append("document.getElementById(jQuery(this).attr(\'id\')).setCustomValidity(\'\');");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("}");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("});");
            _builder.newLine();
          }
        }
      }
    }
    {
      EList<DataObject> _entities_2 = it.getEntities();
      for(final DataObject entity_2 : _entities_2) {
        {
          if (((null != this._modelExtensions.getStartDateField(entity_2)) && (null != this._modelExtensions.getEndDateField(entity_2)))) {
            _builder.append("    ");
            _builder.append("jQuery(\'.validate-daterange-");
            String _formatForDB_1 = this._formattingExtensions.formatForDB(entity_2.getName());
            _builder.append(_formatForDB_1, "    ");
            _builder.append("\').each( function() {");
            _builder.newLineIfNotEmpty();
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("if (typeof jQuery(this).attr(\'id\') != \'undefined\') {");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("        ");
            _builder.append("if (jQuery(this).prop(\'tagName\') == \'DIV\') {");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("            ");
            _builder.append("if (!");
            String _vendorAndName_39 = this._utils.vendorAndName(it);
            _builder.append(_vendorAndName_39, "                ");
            _builder.append("ValidateDateRange");
            String _formatForCodeCapital_3 = this._formattingExtensions.formatForCodeCapital(entity_2.getName());
            _builder.append(_formatForCodeCapital_3, "                ");
            _builder.append("()) {");
            _builder.newLineIfNotEmpty();
            _builder.append("    ");
            _builder.append("                ");
            _builder.append("document.getElementById(jQuery(this).attr(\'id\') + \'_date\').setCustomValidity(Translator.__(\'The start must be before the end.\'));");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("                ");
            _builder.append("document.getElementById(jQuery(this).attr(\'id\') + \'_time\').setCustomValidity(Translator.__(\'The start must be before the end.\'));");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("            ");
            _builder.append("} else {");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("                ");
            _builder.append("document.getElementById(jQuery(this).attr(\'id\') + \'_date\').setCustomValidity(\'\');");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("                ");
            _builder.append("document.getElementById(jQuery(this).attr(\'id\') + \'_time\').setCustomValidity(\'\');");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("            ");
            _builder.append("}");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("    \t");
            _builder.append("} else {");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("            ");
            _builder.append("if (!");
            String _vendorAndName_40 = this._utils.vendorAndName(it);
            _builder.append(_vendorAndName_40, "                ");
            _builder.append("ValidateDateRange");
            String _formatForCodeCapital_4 = this._formattingExtensions.formatForCodeCapital(entity_2.getName());
            _builder.append(_formatForCodeCapital_4, "                ");
            _builder.append("()) {");
            _builder.newLineIfNotEmpty();
            _builder.append("    ");
            _builder.append("                ");
            _builder.append("document.getElementById(jQuery(this).attr(\'id\')).setCustomValidity(Translator.__(\'The start must be before the end.\'));");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("            ");
            _builder.append("} else {");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("                ");
            _builder.append("document.getElementById(jQuery(this).attr(\'id\')).setCustomValidity(\'\');");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("            ");
            _builder.append("}");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("\t\t");
            _builder.append("}");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("}");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("});");
            _builder.newLine();
          }
        }
      }
    }
    {
      final Function1<DataObject, Boolean> _function_14 = (DataObject it_1) -> {
        final Function1<DerivedField, Boolean> _function_15 = (DerivedField it_2) -> {
          boolean _isPrimaryKey = it_2.isPrimaryKey();
          return Boolean.valueOf((!_isPrimaryKey));
        };
        int _size = IterableExtensions.size(IterableExtensions.<DerivedField>filter(this._modelExtensions.getUniqueDerivedFields(it_1), _function_15));
        return Boolean.valueOf((_size > 0));
      };
      boolean _exists_13 = IterableExtensions.<DataObject>exists(it.getEntities(), _function_14);
      if (_exists_13) {
        _builder.append("    ");
        _builder.append("jQuery(\'.validate-unique\').each( function() {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("if (!");
        String _vendorAndName_41 = this._utils.vendorAndName(it);
        _builder.append(_vendorAndName_41, "        ");
        _builder.append("UniqueCheck(jQuery(this).attr(\'id\'), jQuery(this).val(), jQuery(this), currentEntityId)) {");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("        ");
        _builder.append("document.getElementById(jQuery(this).attr(\'id\')).setCustomValidity(Translator.__(\'This value is already assigned, but must be unique. Please change it.\'));");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("} else {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("        ");
        _builder.append("document.getElementById(jQuery(this).attr(\'id\')).setCustomValidity(\'\');");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("});");
        _builder.newLine();
      }
    }
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
}
