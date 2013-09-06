package org.zikula.modulestudio.generator.cartridges.zclassic.controller.javascript;

import com.google.common.collect.Iterables;
import com.google.inject.Inject;
import de.guite.modulestudio.metamodel.modulestudio.AbstractDateField;
import de.guite.modulestudio.metamodel.modulestudio.Application;
import de.guite.modulestudio.metamodel.modulestudio.DateField;
import de.guite.modulestudio.metamodel.modulestudio.DatetimeField;
import de.guite.modulestudio.metamodel.modulestudio.DerivedField;
import de.guite.modulestudio.metamodel.modulestudio.Entity;
import de.guite.modulestudio.metamodel.modulestudio.EntityField;
import de.guite.modulestudio.metamodel.modulestudio.TimeField;
import java.util.List;
import org.eclipse.emf.common.util.EList;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.InputOutput;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
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
  private NamingExtensions _namingExtensions = new Function0<NamingExtensions>() {
    public NamingExtensions apply() {
      NamingExtensions _namingExtensions = new NamingExtensions();
      return _namingExtensions;
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
  
  /**
   * Entry point for the javascript file with validation functionality.
   */
  public void generate(final Application it, final IFileSystemAccess fsa) {
    InputOutput.<String>println("Generating javascript for validation");
    String _appJsPath = this._namingExtensions.getAppJsPath(it);
    String _appName = this._utils.appName(it);
    String _plus = (_appJsPath + _appName);
    String _plus_1 = (_plus + "_validation.js");
    CharSequence _generate = this.generate(it);
    fsa.generateFile(_plus_1, _generate);
  }
  
  private CharSequence generate(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("\'use strict\';");
    _builder.newLine();
    _builder.newLine();
    _builder.append("function ");
    String _prefix = it.getPrefix();
    _builder.append(_prefix, "");
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
    _builder.append("    ");
    _builder.append("return todayDate;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("// returns YYYY-MM-DD even if date is in DD.MM.YYYY");
    _builder.newLine();
    _builder.append("function ");
    String _prefix_1 = it.getPrefix();
    _builder.append(_prefix_1, "");
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
    _builder.append("if (val.substr(2, 1) === \'.\' && val.substr(4, 1) === \'.\') {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("var newVal = val.substr(6, 4) + \'-\' + val.substr(3, 2) + \'-\' + val.substr(0, 2);");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if (includeTime === true) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("newVal += \' \' + val.substr(11, 5);");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
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
      EList<Entity> _allEntities = this._modelExtensions.getAllEntities(it);
      final Function1<Entity,Boolean> _function = new Function1<Entity,Boolean>() {
        public Boolean apply(final Entity e) {
          Iterable<DerivedField> _uniqueDerivedFields = Validation.this._modelExtensions.getUniqueDerivedFields(e);
          final Function1<DerivedField,Boolean> _function = new Function1<DerivedField,Boolean>() {
            public Boolean apply(final DerivedField f) {
              boolean _isPrimaryKey = f.isPrimaryKey();
              boolean _not = (!_isPrimaryKey);
              return Boolean.valueOf(_not);
            }
          };
          Iterable<DerivedField> _filter = IterableExtensions.<DerivedField>filter(_uniqueDerivedFields, _function);
          int _size = IterableExtensions.size(_filter);
          boolean _greaterThan = (_size > 0);
          return Boolean.valueOf(_greaterThan);
        }
      };
      boolean _exists = IterableExtensions.<Entity>exists(_allEntities, _function);
      if (_exists) {
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
        String _prefix_2 = it.getPrefix();
        _builder.append(_prefix_2, "");
        _builder.append("UniqueCheck(ucOt, val, elem, ucEx)");
        _builder.newLineIfNotEmpty();
        _builder.append("{");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("var params, request;");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$(\'advice-validate-unique-\' + elem.id).hide();");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("elem.removeClassName(\'validation-failed\').removeClassName(\'validation-passed\');");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("// build parameters object");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("params = {ot: ucOt, fn: encodeURIComponent(elem.id), v: encodeURIComponent(val), ex: ucEx};");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("/** TODO fix the following call to work within validation context */");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("return true;");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("request = new Zikula.Ajax.Request(Zikula.Config.baseURL + \'ajax.php?module=");
        String _appName = this._utils.appName(it);
        _builder.append(_appName, "    ");
        {
          boolean _targets = this._utils.targets(it, "1.3.5");
          boolean _not = (!_targets);
          if (_not) {
            _builder.append("&type=ajax");
          }
        }
        _builder.append("&func=checkForDuplicate\', {");
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        _builder.append("method: \'post\',");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("parameters: params,");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("authid: \'FormAuthid\',");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("onComplete: function(req) {");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("// check if request was successful");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("if (!req.isSuccess()) {");
        _builder.newLine();
        _builder.append("                ");
        _builder.append("Zikula.showajaxerror(req.getMessage());");
        _builder.newLine();
        _builder.append("                ");
        _builder.append("return;");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("}");
        _builder.newLine();
        _builder.newLine();
        _builder.append("            ");
        _builder.append("// get data returned by module");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("var data = req.getData();");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("if (data.isDuplicate !== \'1\') {");
        _builder.newLine();
        _builder.append("                ");
        _builder.append("$(\'advice-validate-unique-\' + elem.id).hide();");
        _builder.newLine();
        _builder.append("                ");
        _builder.append("elem.removeClassName(\'validation-failed\').addClassName(\'validation-passed\');");
        _builder.newLine();
        _builder.append("                ");
        _builder.append("return true;");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("} else {");
        _builder.newLine();
        _builder.append("                ");
        _builder.append("$(\'advice-validate-unique-\' + elem.id).show();");
        _builder.newLine();
        _builder.append("                ");
        _builder.append("elem.removeClassName(\'validation-passed\').addClassName(\'validation-failed\');");
        _builder.newLine();
        _builder.append("                ");
        _builder.append("return false;");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("}");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("});");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("return true;");
        _builder.newLine();
        _builder.append("}");
        _builder.newLine();
      }
    }
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Add special validation rules.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("function ");
    String _prefix_3 = it.getPrefix();
    _builder.append(_prefix_3, "");
    _builder.append("AddCommonValidationRules(objectType, id)");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("Validation.addAllThese([");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("[\'validate-nospace\', Zikula.__(\'No spaces\', \'module_");
    String _appName_1 = this._utils.appName(it);
    String _formatForDB = this._formattingExtensions.formatForDB(_appName_1);
    _builder.append(_formatForDB, "        ");
    _builder.append("_js\'), function(val, elem) {");
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    _builder.append("var valStr;");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("valStr = new String(val);");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("return (valStr.indexOf(\' \') === -1);");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}],");
    _builder.newLine();
    {
      boolean _hasColourFields = this._modelExtensions.hasColourFields(it);
      if (_hasColourFields) {
        _builder.append("        ");
        _builder.append("[\'validate-htmlcolour\', Zikula.__(\'Please select a valid html colour code.\', \'module_");
        String _appName_2 = this._utils.appName(it);
        String _formatForDB_1 = this._formattingExtensions.formatForDB(_appName_2);
        _builder.append(_formatForDB_1, "        ");
        _builder.append("_js\'), function(val, elem) {");
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("var valStr;");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("valStr = new String(val);");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("return Validation.get(\'IsEmpty\').test(val) || (/^#[0-9a-f]{3}([0-9a-f]{3})?$/i.test(valStr));");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("}],");
        _builder.newLine();
      }
    }
    {
      boolean _hasUploads = this._modelExtensions.hasUploads(it);
      if (_hasUploads) {
        _builder.append("        ");
        _builder.append("[\'validate-upload\', Zikula.__(\'Please select a valid file extension.\', \'module_");
        String _appName_3 = this._utils.appName(it);
        String _formatForDB_2 = this._formattingExtensions.formatForDB(_appName_3);
        _builder.append(_formatForDB_2, "        ");
        _builder.append("_js\'), function(val, elem) {");
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("var allowedExtensions;");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("if (val === \'\') {");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("        ");
        _builder.append("return true;");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("var fileExtension = \'.\' + val.substr(val.lastIndexOf(\'.\') + 1);");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("allowedExtensions = $(\'fileextensions\' + elem.id).innerHTML;");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("allowedExtensions = \'(.\' + allowedExtensions.replace(/, /g, \'|.\').replace(/,/g, \'|.\') + \')$\';");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("allowedExtensions = new RegExp(allowedExtensions, \'i\');");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("return allowedExtensions.test(val);");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("}],");
        _builder.newLine();
      }
    }
    _builder.append("        ");
    List<EntityField> _allEntityFields = this._modelExtensions.getAllEntityFields(it);
    final Iterable<DatetimeField> datetimeFields = Iterables.<DatetimeField>filter(_allEntityFields, DatetimeField.class);
    _builder.newLineIfNotEmpty();
    {
      boolean _isEmpty = IterableExtensions.isEmpty(datetimeFields);
      boolean _not_1 = (!_isEmpty);
      if (_not_1) {
        {
          final Function1<DatetimeField,Boolean> _function_1 = new Function1<DatetimeField,Boolean>() {
            public Boolean apply(final DatetimeField e) {
              boolean _isPast = e.isPast();
              return Boolean.valueOf(_isPast);
            }
          };
          boolean _exists_1 = IterableExtensions.<DatetimeField>exists(datetimeFields, _function_1);
          if (_exists_1) {
            _builder.append("        ");
            _builder.append("[\'validate-datetime-past\', Zikula.__(\'Please select a value in the past.\', \'module_");
            String _appName_4 = this._utils.appName(it);
            String _formatForDB_3 = this._formattingExtensions.formatForDB(_appName_4);
            _builder.append(_formatForDB_3, "        ");
            _builder.append("_js\'), function(val, elem) {");
            _builder.newLineIfNotEmpty();
            _builder.append("        ");
            _builder.append("    ");
            _builder.append("var valStr, cmpVal;");
            _builder.newLine();
            _builder.append("        ");
            _builder.append("    ");
            _builder.append("valStr = new String(val);");
            _builder.newLine();
            _builder.append("        ");
            _builder.append("    ");
            _builder.append("cmpVal = ");
            String _prefix_4 = it.getPrefix();
            _builder.append(_prefix_4, "            ");
            _builder.append("ReadDate(valStr, true);");
            _builder.newLineIfNotEmpty();
            _builder.append("        ");
            _builder.append("    ");
            _builder.append("return Validation.get(\'IsEmpty\').test(val) || (cmpVal < ");
            String _prefix_5 = it.getPrefix();
            _builder.append(_prefix_5, "            ");
            _builder.append("Today(\'datetime\'));");
            _builder.newLineIfNotEmpty();
            _builder.append("        ");
            _builder.append("}],");
            _builder.newLine();
          }
        }
        {
          final Function1<DatetimeField,Boolean> _function_2 = new Function1<DatetimeField,Boolean>() {
            public Boolean apply(final DatetimeField e) {
              boolean _isFuture = e.isFuture();
              return Boolean.valueOf(_isFuture);
            }
          };
          boolean _exists_2 = IterableExtensions.<DatetimeField>exists(datetimeFields, _function_2);
          if (_exists_2) {
            _builder.append("        ");
            _builder.append("[\'validate-datetime-future\', Zikula.__(\'Please select a value in the future.\', \'module_");
            String _appName_5 = this._utils.appName(it);
            String _formatForDB_4 = this._formattingExtensions.formatForDB(_appName_5);
            _builder.append(_formatForDB_4, "        ");
            _builder.append("_js\'), function(val, elem) {");
            _builder.newLineIfNotEmpty();
            _builder.append("        ");
            _builder.append("    ");
            _builder.append("var valStr, cmpVal;");
            _builder.newLine();
            _builder.append("        ");
            _builder.append("    ");
            _builder.append("valStr = new String(val);");
            _builder.newLine();
            _builder.append("        ");
            _builder.append("    ");
            _builder.append("cmpVal = ");
            String _prefix_6 = it.getPrefix();
            _builder.append(_prefix_6, "            ");
            _builder.append("ReadDate(valStr, true);");
            _builder.newLineIfNotEmpty();
            _builder.append("        ");
            _builder.append("    ");
            _builder.append("return Validation.get(\'IsEmpty\').test(val) || (cmpVal >= ");
            String _prefix_7 = it.getPrefix();
            _builder.append(_prefix_7, "            ");
            _builder.append("Today(\'datetime\'));");
            _builder.newLineIfNotEmpty();
            _builder.append("        ");
            _builder.append("}],");
            _builder.newLine();
          }
        }
      }
    }
    _builder.append("        ");
    List<EntityField> _allEntityFields_1 = this._modelExtensions.getAllEntityFields(it);
    final Iterable<DateField> dateFields = Iterables.<DateField>filter(_allEntityFields_1, DateField.class);
    _builder.newLineIfNotEmpty();
    {
      boolean _isEmpty_1 = IterableExtensions.isEmpty(dateFields);
      boolean _not_2 = (!_isEmpty_1);
      if (_not_2) {
        {
          final Function1<DateField,Boolean> _function_3 = new Function1<DateField,Boolean>() {
            public Boolean apply(final DateField e) {
              boolean _isPast = e.isPast();
              return Boolean.valueOf(_isPast);
            }
          };
          boolean _exists_3 = IterableExtensions.<DateField>exists(dateFields, _function_3);
          if (_exists_3) {
            _builder.append("        ");
            _builder.append("[\'validate-date-past\', Zikula.__(\'Please select a value in the past.\', \'module_");
            String _appName_6 = this._utils.appName(it);
            String _formatForDB_5 = this._formattingExtensions.formatForDB(_appName_6);
            _builder.append(_formatForDB_5, "        ");
            _builder.append("_js\'), function(val, elem) {");
            _builder.newLineIfNotEmpty();
            _builder.append("        ");
            _builder.append("    ");
            _builder.append("var valStr, cmpVal;");
            _builder.newLine();
            _builder.append("        ");
            _builder.append("    ");
            _builder.append("valStr = new String(val);");
            _builder.newLine();
            _builder.append("        ");
            _builder.append("    ");
            _builder.append("cmpVal = ");
            String _prefix_8 = it.getPrefix();
            _builder.append(_prefix_8, "            ");
            _builder.append("ReadDate(valStr, false);");
            _builder.newLineIfNotEmpty();
            _builder.append("        ");
            _builder.append("    ");
            _builder.append("return Validation.get(\'IsEmpty\').test(val) || (cmpVal < ");
            String _prefix_9 = it.getPrefix();
            _builder.append(_prefix_9, "            ");
            _builder.append("Today(\'date\'));");
            _builder.newLineIfNotEmpty();
            _builder.append("        ");
            _builder.append("}],");
            _builder.newLine();
          }
        }
        {
          final Function1<DateField,Boolean> _function_4 = new Function1<DateField,Boolean>() {
            public Boolean apply(final DateField e) {
              boolean _isFuture = e.isFuture();
              return Boolean.valueOf(_isFuture);
            }
          };
          boolean _exists_4 = IterableExtensions.<DateField>exists(dateFields, _function_4);
          if (_exists_4) {
            _builder.append("        ");
            _builder.append("[\'validate-date-future\', Zikula.__(\'Please select a value in the future.\', \'module_");
            String _appName_7 = this._utils.appName(it);
            String _formatForDB_6 = this._formattingExtensions.formatForDB(_appName_7);
            _builder.append(_formatForDB_6, "        ");
            _builder.append("_js\'), function(val, elem) {");
            _builder.newLineIfNotEmpty();
            _builder.append("        ");
            _builder.append("    ");
            _builder.append("var valStr, cmpVal;");
            _builder.newLine();
            _builder.append("        ");
            _builder.append("    ");
            _builder.append("valStr = new String(val);");
            _builder.newLine();
            _builder.append("        ");
            _builder.append("    ");
            _builder.append("cmpVal = ");
            String _prefix_10 = it.getPrefix();
            _builder.append(_prefix_10, "            ");
            _builder.append("ReadDate(valStr, false);");
            _builder.newLineIfNotEmpty();
            _builder.append("        ");
            _builder.append("    ");
            _builder.append("return Validation.get(\'IsEmpty\').test(val) || (cmpVal >= ");
            String _prefix_11 = it.getPrefix();
            _builder.append(_prefix_11, "            ");
            _builder.append("Today(\'date\'));");
            _builder.newLineIfNotEmpty();
            _builder.append("        ");
            _builder.append("}],");
            _builder.newLine();
          }
        }
      }
    }
    _builder.append("        ");
    List<EntityField> _allEntityFields_2 = this._modelExtensions.getAllEntityFields(it);
    final Iterable<TimeField> timeFields = Iterables.<TimeField>filter(_allEntityFields_2, TimeField.class);
    _builder.newLineIfNotEmpty();
    {
      boolean _isEmpty_2 = IterableExtensions.isEmpty(timeFields);
      boolean _not_3 = (!_isEmpty_2);
      if (_not_3) {
        {
          final Function1<TimeField,Boolean> _function_5 = new Function1<TimeField,Boolean>() {
            public Boolean apply(final TimeField e) {
              boolean _isPast = e.isPast();
              return Boolean.valueOf(_isPast);
            }
          };
          boolean _exists_5 = IterableExtensions.<TimeField>exists(timeFields, _function_5);
          if (_exists_5) {
            _builder.append("        ");
            _builder.append("[\'validate-time-past\', Zikula.__(\'Please select a value in the past.\', \'module_");
            String _appName_8 = this._utils.appName(it);
            String _formatForDB_7 = this._formattingExtensions.formatForDB(_appName_8);
            _builder.append(_formatForDB_7, "        ");
            _builder.append("_js\'), function(val, elem) {");
            _builder.newLineIfNotEmpty();
            _builder.append("        ");
            _builder.append("    ");
            _builder.append("var cmpVal;");
            _builder.newLine();
            _builder.append("        ");
            _builder.append("    ");
            _builder.append("cmpVal = new String(val);");
            _builder.newLine();
            _builder.append("        ");
            _builder.append("    ");
            _builder.append("return Validation.get(\'IsEmpty\').test(val) || (cmpVal < ");
            String _prefix_12 = it.getPrefix();
            _builder.append(_prefix_12, "            ");
            _builder.append("Today(\'time\'));");
            _builder.newLineIfNotEmpty();
            _builder.append("        ");
            _builder.append("}],");
            _builder.newLine();
          }
        }
        {
          final Function1<TimeField,Boolean> _function_6 = new Function1<TimeField,Boolean>() {
            public Boolean apply(final TimeField e) {
              boolean _isFuture = e.isFuture();
              return Boolean.valueOf(_isFuture);
            }
          };
          boolean _exists_6 = IterableExtensions.<TimeField>exists(timeFields, _function_6);
          if (_exists_6) {
            _builder.append("        ");
            _builder.append("[\'validate-time-future\', Zikula.__(\'Please select a value in the future.\', \'module_");
            String _appName_9 = this._utils.appName(it);
            String _formatForDB_8 = this._formattingExtensions.formatForDB(_appName_9);
            _builder.append(_formatForDB_8, "        ");
            _builder.append("_js\'), function(val, elem) {");
            _builder.newLineIfNotEmpty();
            _builder.append("        ");
            _builder.append("    ");
            _builder.append("var cmpVal;");
            _builder.newLine();
            _builder.append("        ");
            _builder.append("    ");
            _builder.append("cmpVal = new String(val);");
            _builder.newLine();
            _builder.append("        ");
            _builder.append("    ");
            _builder.append("return Validation.get(\'IsEmpty\').test(val) || (cmpVal >= ");
            String _prefix_13 = this._utils.prefix(it);
            _builder.append(_prefix_13, "            ");
            _builder.append("Today(\'time\'));");
            _builder.newLineIfNotEmpty();
            _builder.append("        ");
            _builder.append("}],");
            _builder.newLine();
          }
        }
      }
    }
    {
      EList<Entity> _allEntities_1 = this._modelExtensions.getAllEntities(it);
      for(final Entity entity : _allEntities_1) {
        _builder.append("        ");
        final AbstractDateField startDateField = this._modelExtensions.getStartDateField(entity);
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        final AbstractDateField endDateField = this._modelExtensions.getEndDateField(entity);
        _builder.newLineIfNotEmpty();
        {
          boolean _and = false;
          boolean _tripleNotEquals = (startDateField != null);
          if (!_tripleNotEquals) {
            _and = false;
          } else {
            boolean _tripleNotEquals_1 = (endDateField != null);
            _and = (_tripleNotEquals && _tripleNotEquals_1);
          }
          if (_and) {
            _builder.append("        ");
            String _name = entity.getName();
            String _formatForDB_9 = this._formattingExtensions.formatForDB(_name);
            final String validateClass = ("validate-daterange-" + _formatForDB_9);
            _builder.newLineIfNotEmpty();
            _builder.append("        ");
            String _name_1 = startDateField.getName();
            final String startFieldName = this._formattingExtensions.formatForCode(_name_1);
            _builder.newLineIfNotEmpty();
            _builder.append("        ");
            String _name_2 = endDateField.getName();
            final String endFieldName = this._formattingExtensions.formatForCode(_name_2);
            _builder.newLineIfNotEmpty();
            _builder.append("        ");
            _builder.append("[\'");
            _builder.append(validateClass, "        ");
            _builder.append("\', Zikula.__(\'The start must be before the end.\', \'module_");
            String _appName_10 = this._utils.appName(it);
            String _formatForDB_10 = this._formattingExtensions.formatForDB(_appName_10);
            _builder.append(_formatForDB_10, "        ");
            _builder.append("_js\'), function(val, elem) {");
            _builder.newLineIfNotEmpty();
            _builder.append("        ");
            _builder.append("    ");
            _builder.append("var cmpVal, cmpVal2, result;");
            _builder.newLine();
            _builder.newLine();
            _builder.append("        ");
            _builder.append("    ");
            _builder.append("cmpVal = ");
            String _prefix_14 = it.getPrefix();
            _builder.append(_prefix_14, "            ");
            _builder.append("ReadDate($F(\'");
            _builder.append(startFieldName, "            ");
            _builder.append("\'), ");
            String _displayBool = this._formattingExtensions.displayBool(Boolean.valueOf((startDateField instanceof DatetimeField)));
            _builder.append(_displayBool, "            ");
            _builder.append(");");
            _builder.newLineIfNotEmpty();
            _builder.append("        ");
            _builder.append("    ");
            _builder.append("cmpVal2 = ");
            String _prefix_15 = it.getPrefix();
            _builder.append(_prefix_15, "            ");
            _builder.append("ReadDate($F(\'");
            _builder.append(endFieldName, "            ");
            _builder.append("\'), ");
            String _displayBool_1 = this._formattingExtensions.displayBool(Boolean.valueOf((endDateField instanceof DatetimeField)));
            _builder.append(_displayBool_1, "            ");
            _builder.append(");");
            _builder.newLineIfNotEmpty();
            _builder.append("        ");
            _builder.append("    ");
            _builder.append("result = (cmpVal <= cmpVal2);");
            _builder.newLine();
            _builder.append("        ");
            _builder.append("    ");
            _builder.append("if (result) {");
            _builder.newLine();
            _builder.append("        ");
            _builder.append("        ");
            _builder.append("$(\'advice-");
            _builder.append(validateClass, "                ");
            _builder.append("-");
            _builder.append(startFieldName, "                ");
            _builder.append("\').hide();");
            _builder.newLineIfNotEmpty();
            _builder.append("        ");
            _builder.append("        ");
            _builder.append("$(\'advice-");
            _builder.append(validateClass, "                ");
            _builder.append("-");
            _builder.append(endFieldName, "                ");
            _builder.append("\').hide();");
            _builder.newLineIfNotEmpty();
            _builder.append("        ");
            _builder.append("        ");
            _builder.append("$(\'");
            _builder.append(startFieldName, "                ");
            _builder.append("\').removeClassName(\'validation-failed\').addClassName(\'validation-passed\');");
            _builder.newLineIfNotEmpty();
            _builder.append("        ");
            _builder.append("        ");
            _builder.append("$(\'");
            _builder.append(endFieldName, "                ");
            _builder.append("\').removeClassName(\'validation-failed\').addClassName(\'validation-passed\');");
            _builder.newLineIfNotEmpty();
            _builder.append("        ");
            _builder.append("    ");
            _builder.append("}");
            _builder.newLine();
            _builder.newLine();
            _builder.append("        ");
            _builder.append("    ");
            _builder.append("return false;");
            _builder.newLine();
            _builder.append("        ");
            _builder.append("}],");
            _builder.newLine();
          }
        }
      }
    }
    {
      EList<Entity> _allEntities_2 = this._modelExtensions.getAllEntities(it);
      final Function1<Entity,Boolean> _function_7 = new Function1<Entity,Boolean>() {
        public Boolean apply(final Entity e) {
          Iterable<DerivedField> _uniqueDerivedFields = Validation.this._modelExtensions.getUniqueDerivedFields(e);
          final Function1<DerivedField,Boolean> _function = new Function1<DerivedField,Boolean>() {
            public Boolean apply(final DerivedField f) {
              boolean _isPrimaryKey = f.isPrimaryKey();
              boolean _not = (!_isPrimaryKey);
              return Boolean.valueOf(_not);
            }
          };
          Iterable<DerivedField> _filter = IterableExtensions.<DerivedField>filter(_uniqueDerivedFields, _function);
          int _size = IterableExtensions.size(_filter);
          boolean _greaterThan = (_size > 0);
          return Boolean.valueOf(_greaterThan);
        }
      };
      boolean _exists_7 = IterableExtensions.<Entity>exists(_allEntities_2, _function_7);
      if (_exists_7) {
        _builder.append("        ");
        _builder.append("[\'validate-unique\', Zikula.__(\'This value is already assigned, but must be unique. Please change it.\', \'module_");
        String _appName_11 = this._utils.appName(it);
        String _formatForDB_11 = this._formattingExtensions.formatForDB(_appName_11);
        _builder.append(_formatForDB_11, "        ");
        _builder.append("_js\'), function(val, elem) {");
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("return ");
        String _prefix_16 = it.getPrefix();
        _builder.append(_prefix_16, "            ");
        _builder.append("UniqueCheck(\'");
        String _name_3 = it.getName();
        String _formatForCode = this._formattingExtensions.formatForCode(_name_3);
        _builder.append(_formatForCode, "            ");
        _builder.append("\', val, elem, id);");
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        _builder.append("}]");
        _builder.newLine();
      }
    }
    _builder.append("    ");
    _builder.append("]);");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
}
