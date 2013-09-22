package org.zikula.modulestudio.generator.cartridges.zclassic.controller.javascript;

import com.google.common.collect.Iterables;
import com.google.inject.Inject;
import de.guite.modulestudio.metamodel.modulestudio.AbstractDateField;
import de.guite.modulestudio.metamodel.modulestudio.Application;
import de.guite.modulestudio.metamodel.modulestudio.DerivedField;
import de.guite.modulestudio.metamodel.modulestudio.Entity;
import de.guite.modulestudio.metamodel.modulestudio.JoinRelationship;
import org.eclipse.emf.common.util.EList;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.InputOutput;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class EditFunctions {
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
  private ModelBehaviourExtensions _modelBehaviourExtensions = new Function0<ModelBehaviourExtensions>() {
    public ModelBehaviourExtensions apply() {
      ModelBehaviourExtensions _modelBehaviourExtensions = new ModelBehaviourExtensions();
      return _modelBehaviourExtensions;
    }
  }.apply();
  
  @Inject
  @Extension
  private ModelJoinExtensions _modelJoinExtensions = new Function0<ModelJoinExtensions>() {
    public ModelJoinExtensions apply() {
      ModelJoinExtensions _modelJoinExtensions = new ModelJoinExtensions();
      return _modelJoinExtensions;
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
   * Entry point for the javascript file with edit functionality.
   */
  public void generate(final Application it, final IFileSystemAccess fsa) {
    InputOutput.<String>println("Generating javascript for edit functions");
    String _appJsPath = this._namingExtensions.getAppJsPath(it);
    String _appName = this._utils.appName(it);
    String _plus = (_appJsPath + _appName);
    String _plus_1 = (_plus + "_editFunctions.js");
    CharSequence _generate = this.generate(it);
    fsa.generateFile(_plus_1, _generate);
  }
  
  private CharSequence generate(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("\'use strict\';");
    _builder.newLine();
    _builder.newLine();
    CharSequence _relationFunctionsPreparation = this.relationFunctionsPreparation(it);
    _builder.append(_relationFunctionsPreparation, "");
    _builder.newLineIfNotEmpty();
    CharSequence _initUserField = this.initUserField(it);
    _builder.append(_initUserField, "");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    {
      boolean _hasUploads = this._modelExtensions.hasUploads(it);
      if (_hasUploads) {
        CharSequence _resetUploadField = this.resetUploadField(it);
        _builder.append(_resetUploadField, "");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
        CharSequence _initUploadField = this.initUploadField(it);
        _builder.append(_initUploadField, "");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
      }
    }
    {
      EList<Entity> _allEntities = this._modelExtensions.getAllEntities(it);
      final Function1<Entity,Boolean> _function = new Function1<Entity,Boolean>() {
        public Boolean apply(final Entity it) {
          Iterable<DerivedField> _derivedFields = EditFunctions.this._modelExtensions.getDerivedFields(it);
          Iterable<AbstractDateField> _filter = Iterables.<AbstractDateField>filter(_derivedFields, AbstractDateField.class);
          boolean _isEmpty = IterableExtensions.isEmpty(_filter);
          boolean _not = (!_isEmpty);
          return Boolean.valueOf(_not);
        }
      };
      Iterable<Entity> _filter = IterableExtensions.<Entity>filter(_allEntities, _function);
      boolean _isEmpty = IterableExtensions.isEmpty(_filter);
      boolean _not = (!_isEmpty);
      if (_not) {
        CharSequence _resetDateField = this.resetDateField(it);
        _builder.append(_resetDateField, "");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
        CharSequence _initDateField = this.initDateField(it);
        _builder.append(_initDateField, "");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
      }
    }
    {
      boolean _hasGeographical = this._modelBehaviourExtensions.hasGeographical(it);
      if (_hasGeographical) {
        CharSequence _initGeoCoding = this.initGeoCoding(it);
        _builder.append(_initGeoCoding, "");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
      }
    }
    CharSequence _relationFunctions = this.relationFunctions(it);
    _builder.append(_relationFunctions, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence initUserField(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _hasUserFields = this._modelExtensions.hasUserFields(it);
      if (_hasUserFields) {
        _builder.append("/**");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Initialises a user field with auto completion.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
        _builder.append("function ");
        String _prefix = it.getPrefix();
        _builder.append(_prefix, "");
        _builder.append("InitUserField(fieldName, getterName)");
        _builder.newLineIfNotEmpty();
        _builder.append("{");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("if ($(fieldName + \'LiveSearch\') === undefined) {");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("return;");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$(fieldName + \'LiveSearch\').removeClassName(\'");
        {
          boolean _targets = this._utils.targets(it, "1.3.5");
          if (_targets) {
            _builder.append("z-");
          }
        }
        _builder.append("hide\');");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("new Ajax.Autocompleter(");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("fieldName + \'Selector\',");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("fieldName + \'SelectorChoices\',");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("Zikula.Config.baseURL + \'");
        {
          boolean _targets_1 = this._utils.targets(it, "1.3.5");
          if (_targets_1) {
            _builder.append("ajax");
          } else {
            _builder.append("index");
          }
        }
        _builder.append(".php?module=");
        String _appName = this._utils.appName(it);
        _builder.append(_appName, "        ");
        {
          boolean _targets_2 = this._utils.targets(it, "1.3.5");
          boolean _not = (!_targets_2);
          if (_not) {
            _builder.append("&type=ajax");
          }
        }
        _builder.append("&func=\' + getterName,");
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        _builder.append("{");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("paramName: \'fragment\',");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("minChars: 3,");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("indicator: fieldName + \'Indicator\',");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("afterUpdateElement: function(data) {");
        _builder.newLine();
        _builder.append("                ");
        _builder.append("$(fieldName).value = $($(data).value).value;");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("}");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append(");");
        _builder.newLine();
        _builder.append("}");
        _builder.newLine();
        _builder.newLine();
      }
    }
    return _builder;
  }
  
  private CharSequence resetUploadField(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Resets the value of an upload / file input field.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("function ");
    String _prefix = it.getPrefix();
    _builder.append(_prefix, "");
    _builder.append("ResetUploadField(fieldName)");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($(fieldName) != undefined) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$(fieldName).setAttribute(\'type\', \'input\');");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$(fieldName).setAttribute(\'type\', \'file\');");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence initUploadField(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Initialises the reset button for a certain upload input.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("function ");
    String _prefix = it.getPrefix();
    _builder.append(_prefix, "");
    _builder.append("InitUploadField(fieldName)");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($(\'reset\' + fieldName.capitalize() + \'Val\') != undefined) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$(\'reset\' + fieldName.capitalize() + \'Val\').observe(\'click\', function (evt) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("evt.preventDefault();");
    _builder.newLine();
    _builder.append("            ");
    String _prefix_1 = it.getPrefix();
    _builder.append(_prefix_1, "            ");
    _builder.append("ResetUploadField(fieldName);");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("}).removeClassName(\'");
    {
      boolean _targets = this._utils.targets(it, "1.3.5");
      if (_targets) {
        _builder.append("z-");
      }
    }
    _builder.append("hide\');");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence resetDateField(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Resets the value of a date or datetime input field.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("function ");
    String _prefix = it.getPrefix();
    _builder.append(_prefix, "");
    _builder.append("ResetDateField(fieldName)");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($(fieldName) != undefined) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$(fieldName).value = \'\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($(fieldName + \'cal\') != undefined) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$(fieldName + \'cal\').update(Zikula.__(\'No date set.\', \'module_");
    String _appName = this._utils.appName(it);
    _builder.append(_appName, "        ");
    _builder.append("\'));");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence initDateField(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Initialises the reset button for a certain date input.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("function ");
    String _prefix = it.getPrefix();
    _builder.append(_prefix, "");
    _builder.append("InitDateField(fieldName)");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($(\'reset\' + fieldName.capitalize() + \'Val\') != undefined) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$(\'reset\' + fieldName.capitalize() + \'Val\').observe(\'click\', function (evt) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("evt.preventDefault();");
    _builder.newLine();
    _builder.append("            ");
    String _prefix_1 = it.getPrefix();
    _builder.append(_prefix_1, "            ");
    _builder.append("ResetDateField(fieldName);");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("}).removeClassName(\'");
    {
      boolean _targets = this._utils.targets(it, "1.3.5");
      if (_targets) {
        _builder.append("z-");
      }
    }
    _builder.append("hide\');");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence initGeoCoding(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Example method for initialising geo coding functionality in JavaScript.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* In contrast to the map picker this one determines coordinates for a given address.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* To use this please customise the form field names to your needs.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* There is also a method on PHP level available in the \\");
    {
      boolean _targets = this._utils.targets(it, "1.3.5");
      if (_targets) {
        String _appName = this._utils.appName(it);
        _builder.append(_appName, " ");
        _builder.append("_Util_Controller");
      } else {
        String _vendor = it.getVendor();
        String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(_vendor);
        _builder.append(_formatForCodeCapital, " ");
        _builder.append("\\");
        String _name = it.getName();
        String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(_name);
        _builder.append(_formatForCodeCapital_1, " ");
        _builder.append("Module\\Util\\ControllerUtil");
      }
    }
    _builder.append(" class.");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("function ");
    String _prefix = it.getPrefix();
    _builder.append(_prefix, "");
    _builder.append("InitGeoCoding()");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$(\'linkGetCoordinates\').observe(\'click\', function (evt) {");
    _builder.newLine();
    _builder.append("        ");
    String _prefix_1 = it.getPrefix();
    _builder.append(_prefix_1, "        ");
    _builder.append("DoGeoCoding();");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("});");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("function ");
    String _prefix_2 = it.getPrefix();
    _builder.append(_prefix_2, "");
    _builder.append("DoGeoCoding()");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("var geocoder = new mxn.Geocoder(\'googlev3\', ");
    String _prefix_3 = it.getPrefix();
    _builder.append(_prefix_3, "    ");
    _builder.append("GeoCodeReturn, ");
    String _prefix_4 = it.getPrefix();
    _builder.append(_prefix_4, "    ");
    _builder.append("GeoCodeErrorCallback);");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("var address = {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("address : $F(\'street\') + \' \' + $F(\'houseNumber\') + \' \' + $F(\'zipcode\') + \' \' + $F(\'city\') + \' \' + $F(\'country\')");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("};");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("geocoder.geocode(address);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("function ");
    String _prefix_5 = it.getPrefix();
    _builder.append(_prefix_5, "    ");
    _builder.append("GeoCodeErrorCallback (status) {");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("Zikula.UI.Alert(Zikula.__(\'Error during geocoding:\', \'module_");
    String _appName_1 = this._utils.appName(it);
    _builder.append(_appName_1, "        ");
    _builder.append("\') + \' \' + status);");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("function ");
    String _prefix_6 = it.getPrefix();
    _builder.append(_prefix_6, "    ");
    _builder.append("GeoCodeReturn (location) {");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("Form.Element.setValue(\'latitude\', location.point.lat.toFixed(4));");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("Form.Element.setValue(\'longitude\', location.point.lng.toFixed(4));");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("newCoordinatesEventHandler();");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence relationFunctionsPreparation(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      Iterable<JoinRelationship> _joinRelations = this._modelJoinExtensions.getJoinRelations(it);
      boolean _isEmpty = IterableExtensions.isEmpty(_joinRelations);
      boolean _not = (!_isEmpty);
      if (_not) {
        _builder.newLine();
        _builder.append("/**");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Override method of Scriptaculous auto completer method.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Purpose: better feedback if no results are found (#247).");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* See http://stackoverflow.com/questions/657839/scriptaculous-ajax-autocomplete-empty-response for more information.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
        _builder.append("Ajax.Autocompleter.prototype.updateChoices = function (choices)");
        _builder.newLine();
        _builder.append("{");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("if (!this.changed && this.hasFocus) {");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("if (!choices || choices == \'<ul></ul>\') {");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("this.stopIndicator();");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("var idPrefix = this.options.indicator.replace(\'Indicator\', \'\');");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("if ($(idPrefix + \'NoResultsHint\') != undefined) {");
        _builder.newLine();
        _builder.append("                ");
        _builder.append("$(idPrefix + \'NoResultsHint\').removeClassName(\'");
        {
          boolean _targets = this._utils.targets(it, "1.3.5");
          if (_targets) {
            _builder.append("z-");
          }
        }
        _builder.append("hide\');");
        _builder.newLineIfNotEmpty();
        _builder.append("            ");
        _builder.append("}");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("} else {");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("this.update.innerHTML = choices;");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("Element.cleanWhitespace(this.update);");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("Element.cleanWhitespace(this.update.down());");
        _builder.newLine();
        _builder.newLine();
        _builder.append("            ");
        _builder.append("if (this.update.firstChild && this.update.down().childNodes) {");
        _builder.newLine();
        _builder.append("                ");
        _builder.append("this.entryCount = this.update.down().childNodes.length;");
        _builder.newLine();
        _builder.append("                ");
        _builder.append("for (var i = 0; i < this.entryCount; i++) {");
        _builder.newLine();
        _builder.append("                    ");
        _builder.append("var entry = this.getEntry(i);");
        _builder.newLine();
        _builder.append("                    ");
        _builder.append("entry.autocompleteIndex = i;");
        _builder.newLine();
        _builder.append("                    ");
        _builder.append("this.addObservers(entry);");
        _builder.newLine();
        _builder.append("                ");
        _builder.append("}");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("} else {");
        _builder.newLine();
        _builder.append("                ");
        _builder.append("this.entryCount = 0;");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("}");
        _builder.newLine();
        _builder.newLine();
        _builder.append("            ");
        _builder.append("this.stopIndicator();");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("this.index = 0;");
        _builder.newLine();
        _builder.newLine();
        _builder.append("            ");
        _builder.append("if (this.entryCount == 1 && this.options.autoSelect) {");
        _builder.newLine();
        _builder.append("                ");
        _builder.append("this.selectEntry();");
        _builder.newLine();
        _builder.append("                ");
        _builder.append("this.hide();");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("} else {");
        _builder.newLine();
        _builder.append("                ");
        _builder.append("this.render();");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("}");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
        _builder.append("}");
        _builder.newLine();
      }
    }
    return _builder;
  }
  
  private CharSequence relationFunctions(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      Iterable<JoinRelationship> _joinRelations = this._modelJoinExtensions.getJoinRelations(it);
      boolean _isEmpty = IterableExtensions.isEmpty(_joinRelations);
      boolean _not = (!_isEmpty);
      if (_not) {
        CharSequence _ggleRelatedItemForm = this.toggleRelatedItemForm(it);
        _builder.append(_ggleRelatedItemForm, "");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
        CharSequence _resetRelatedItemForm = this.resetRelatedItemForm(it);
        _builder.append(_resetRelatedItemForm, "");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
        CharSequence _createWindowInstance = this.createWindowInstance(it);
        _builder.append(_createWindowInstance, "");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
        CharSequence _initInlineWindow = this.initInlineWindow(it);
        _builder.append(_initInlineWindow, "");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
        CharSequence _removeRelatedItem = this.removeRelatedItem(it);
        _builder.append(_removeRelatedItem, "");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
        CharSequence _selectRelatedItem = this.selectRelatedItem(it);
        _builder.append(_selectRelatedItem, "");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
        String _prefix = it.getPrefix();
        CharSequence _initRelatedItemsForm = this.initRelatedItemsForm(it, _prefix);
        _builder.append(_initRelatedItemsForm, "");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
        CharSequence _closeWindowFromInside = this.closeWindowFromInside(it);
        _builder.append(_closeWindowFromInside, "");
        _builder.newLineIfNotEmpty();
      }
    }
    return _builder;
  }
  
  private CharSequence toggleRelatedItemForm(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Toggles the fields of an auto completion field.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("function ");
    String _prefix = it.getPrefix();
    _builder.append(_prefix, "");
    _builder.append("ToggleRelatedItemForm(idPrefix)");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// if we don\'t have a toggle link do nothing");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($(idPrefix + \'AddLink\') === undefined) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// show/hide the toggle link");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$(idPrefix + \'AddLink\').toggleClassName(\'");
    {
      boolean _targets = this._utils.targets(it, "1.3.5");
      if (_targets) {
        _builder.append("z-");
      }
    }
    _builder.append("hide\');");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// hide/show the fields");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$(idPrefix + \'AddFields\').toggleClassName(\'");
    {
      boolean _targets_1 = this._utils.targets(it, "1.3.5");
      if (_targets_1) {
        _builder.append("z-");
      }
    }
    _builder.append("hide\');");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence resetRelatedItemForm(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Resets an auto completion field.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("function ");
    String _prefix = it.getPrefix();
    _builder.append(_prefix, "");
    _builder.append("ResetRelatedItemForm(idPrefix)");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// hide the sub form");
    _builder.newLine();
    _builder.append("    ");
    String _prefix_1 = it.getPrefix();
    _builder.append(_prefix_1, "    ");
    _builder.append("ToggleRelatedItemForm(idPrefix);");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// reset value of the auto completion field");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$(idPrefix + \'Selector\').value = \'\';");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence createWindowInstance(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Helper function to create new Zikula.UI.Window instances.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* For edit forms we use \"iframe: true\" to ensure file uploads work without problems.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* For all other windows we use \"iframe: false\" because we want the escape key working.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("function ");
    String _prefix = it.getPrefix();
    _builder.append(_prefix, "");
    _builder.append("CreateWindowInstance(containerElem, useIframe)");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("var newWindow;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// define the new window instance");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("newWindow = new Zikula.UI.Window(");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("containerElem,");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("{");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("minmax: true,");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("resizable: true,");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("//title: containerElem.title,");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("width: 600,");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("initMaxHeight: 500,");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("modal: false,");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("iframe: useIframe");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append(");");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// open it");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("newWindow.openHandler();");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// return the instance");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return newWindow;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence initInlineWindow(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Observe a link for opening an inline window");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("function ");
    String _prefix = it.getPrefix();
    _builder.append(_prefix, "");
    _builder.append("InitInlineWindow(objectType, containerID)");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("var found, newItem;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// whether the handler has been found");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("found = false;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// search for the handler");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("relationHandler.each(function (relationHandler) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// is this the right one");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if (relationHandler.prefix === containerID) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("// yes, it is");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("found = true;");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("// look whether there is already a window instance");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("if (relationHandler.windowInstance !== null) {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("// unset it");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("relationHandler.windowInstance.destroy();");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("// create and assign the new window instance");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("relationHandler.windowInstance = ");
    String _prefix_1 = it.getPrefix();
    _builder.append(_prefix_1, "            ");
    _builder.append("CreateWindowInstance($(containerID), true);");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("});");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// if no handler was found");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (found === false) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// create a new one");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("newItem = new Object();");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("newItem.ot = objectType;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("newItem.alias = \'");
    _builder.append("\';");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("newItem.prefix = containerID;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("newItem.acInstance = null;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("newItem.windowInstance = ");
    String _prefix_2 = it.getPrefix();
    _builder.append(_prefix_2, "        ");
    _builder.append("CreateWindowInstance($(containerID), true);");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// add it to the list of handlers");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("relationHandler.push(newItem);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence removeRelatedItem(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Removes a related item from the list of selected ones.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("function ");
    String _prefix = it.getPrefix();
    _builder.append(_prefix, "");
    _builder.append("RemoveRelatedItem(idPrefix, removeId)");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("var itemIds, itemIdsArr;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("itemIds = $F(idPrefix + \'ItemList\');");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("itemIdsArr = itemIds.split(\',\');");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("itemIdsArr = itemIdsArr.without(removeId);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("itemIds = itemIdsArr.join(\',\');");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$(idPrefix + \'ItemList\').value = itemIds;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$(idPrefix + \'Reference_\' + removeId).remove();");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence selectRelatedItem(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Adds a related item to selection which has been chosen by auto completion.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("function ");
    String _prefix = it.getPrefix();
    _builder.append(_prefix, "");
    _builder.append("SelectRelatedItem(objectType, idPrefix, inputField, selectedListItem)");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("var newItemId, newTitle, includeEditing, editLink, removeLink, elemPrefix, itemPreview, li, editHref, fldPreview, itemIds, itemIdsArr;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("newItemId = selectedListItem.id;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("newTitle = $F(idPrefix + \'Selector\');");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("includeEditing = !!(($F(idPrefix + \'Mode\') == \'1\'));");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("elemPrefix = idPrefix + \'Reference_\' + newItemId;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("itemPreview = \'\';");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($(\'itempreview\' + selectedListItem.id) !== null) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("itemPreview = $(\'itempreview\' + selectedListItem.id).innerHTML;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("var li = Builder.node(\'li\', {id: elemPrefix}, newTitle);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (includeEditing === true) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("var editHref = $(idPrefix + \'SelectorDoNew\').href + \'&id=\' + newItemId;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("editLink = Builder.node(\'a\', {id: elemPrefix + \'Edit\', href: editHref}, \'edit\');");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("li.appendChild(editLink);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("removeLink = Builder.node(\'a\', {id: elemPrefix + \'Remove\', href: \'javascript:");
    String _prefix_1 = it.getPrefix();
    _builder.append(_prefix_1, "    ");
    _builder.append("RemoveRelatedItem(\\\'\' + idPrefix + \'\\\', \' + newItemId + \');\'}, \'remove\');");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("li.appendChild(removeLink);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (itemPreview !== \'\') {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("fldPreview = Builder.node(\'div\', {id: elemPrefix + \'preview\', name: idPrefix + \'preview\'}, \'\');");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("fldPreview.update(itemPreview);");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("li.appendChild(fldPreview);");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("itemPreview = \'\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$(idPrefix + \'ReferenceList\').appendChild(li);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (includeEditing === true) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("editLink.update(\' \' + editImage);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$(elemPrefix + \'Edit\').observe(\'click\', function (e) {");
    _builder.newLine();
    _builder.append("            ");
    String _prefix_2 = it.getPrefix();
    _builder.append(_prefix_2, "            ");
    _builder.append("InitInlineWindow(objectType, idPrefix + \'Reference_\' + newItemId + \'Edit\');");
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    _builder.append("e.stop();");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("});");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("removeLink.update(\' \' + removeImage);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("itemIds = $F(idPrefix + \'ItemList\');");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (itemIds !== \'\') {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if ($F(idPrefix + \'Scope\') === \'0\') {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("itemIdsArr = itemIds.split(\',\');");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("itemIdsArr.each(function (existingId) {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("if (existingId) {");
    _builder.newLine();
    _builder.append("                    ");
    String _prefix_3 = it.getPrefix();
    _builder.append(_prefix_3, "                    ");
    _builder.append("RemoveRelatedItem(idPrefix, existingId);");
    _builder.newLineIfNotEmpty();
    _builder.append("                ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("});");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("itemIds = \'\';");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("} else {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("itemIds += \',\';");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("itemIds += newItemId;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$(idPrefix + \'ItemList\').value = itemIds;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    String _prefix_4 = it.getPrefix();
    _builder.append(_prefix_4, "    ");
    _builder.append("ResetRelatedItemForm(idPrefix);");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence initRelatedItemsForm(final Application it, final String prefixSmall) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Initialise a relation field section with autocompletion and optional edit capabilities");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("function ");
    _builder.append(prefixSmall, "");
    _builder.append("InitRelationItemsForm(objectType, idPrefix, includeEditing)");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("var acOptions, itemIds, itemIdsArr;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// add handling for the toggle link if existing");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($(idPrefix + \'AddLink\') !== undefined) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$(idPrefix + \'AddLink\').observe(\'click\', function (e) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append(prefixSmall, "            ");
    _builder.append("ToggleRelatedItemForm(idPrefix);");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("});");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// add handling for the cancel button");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($(idPrefix + \'SelectorDoCancel\') !== undefined) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$(idPrefix + \'SelectorDoCancel\').observe(\'click\', function (e) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append(prefixSmall, "            ");
    _builder.append("ResetRelatedItemForm(idPrefix);");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("});");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// clear values and ensure starting state");
    _builder.newLine();
    _builder.append("    ");
    _builder.append(prefixSmall, "    ");
    _builder.append("ResetRelatedItemForm(idPrefix);");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("acOptions = {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("paramName: \'fragment\',");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("minChars: 2,");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("indicator: idPrefix + \'Indicator\',");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("callback: function (inputField, defaultQueryString) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("var queryString;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("            ");
    _builder.append("// modify the query string before the request");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("queryString = defaultQueryString + \'&ot=\' + objectType;");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("if ($(idPrefix + \'ItemList\') !== undefined) {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("queryString += \'&exclude=\' + $F(idPrefix + \'ItemList\');");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("            ");
    _builder.append("if ($(idPrefix + \'NoResultsHint\') != undefined) {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("$(idPrefix + \'NoResultsHint\').addClassName(\'");
    {
      boolean _targets = this._utils.targets(it, "1.3.5");
      if (_targets) {
        _builder.append("z-");
      }
    }
    _builder.append("hide\');");
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("            ");
    _builder.append("return queryString;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("},");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("afterUpdateElement: function (inputField, selectedListItem) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("// Called after the input element has been updated (i.e. when the user has selected an entry).");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("// This function is called after the built-in function that adds the list item text to the input field.");
    _builder.newLine();
    _builder.append("            ");
    _builder.append(prefixSmall, "            ");
    _builder.append("SelectRelatedItem(objectType, idPrefix, inputField, selectedListItem);");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("};");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("relationHandler.each(function (relationHandler) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if (relationHandler.prefix === (idPrefix + \'SelectorDoNew\') && relationHandler.acInstance === null) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("relationHandler.acInstance = new Ajax.Autocompleter(");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("idPrefix + \'Selector\',");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("idPrefix + \'SelectorChoices\',");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("Zikula.Config.baseURL + \'");
    {
      boolean _targets_1 = this._utils.targets(it, "1.3.5");
      if (_targets_1) {
        _builder.append("ajax");
      } else {
        _builder.append("index");
      }
    }
    _builder.append(".php?module=\' + relationHandler.moduleName + \'");
    {
      boolean _targets_2 = this._utils.targets(it, "1.3.5");
      boolean _not = (!_targets_2);
      if (_not) {
        _builder.append("&type=ajax");
      }
    }
    _builder.append("&func=getItemListAutoCompletion\',");
    _builder.newLineIfNotEmpty();
    _builder.append("                ");
    _builder.append("acOptions");
    _builder.newLine();
    _builder.append("            ");
    _builder.append(");");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("});");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!includeEditing || $(idPrefix + \'SelectorDoNew\') === undefined) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// from here inline editing will be handled");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$(idPrefix + \'SelectorDoNew\').href += \'&theme=Printer&idp=\' + idPrefix + \'SelectorDoNew\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$(idPrefix + \'SelectorDoNew\').observe(\'click\', function(e) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append(prefixSmall, "        ");
    _builder.append("InitInlineWindow(objectType, idPrefix + \'SelectorDoNew\');");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("e.stop();");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("});");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("itemIds = $F(idPrefix + \'ItemList\');");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("itemIdsArr = itemIds.split(\',\');");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("itemIdsArr.each(function (existingId) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("var elemPrefix;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if (existingId) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("elemPrefix = idPrefix + \'Reference_\' + existingId + \'Edit\';");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$(elemPrefix).href += \'&theme=Printer&idp=\' + elemPrefix;");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$(elemPrefix).observe(\'click\', function (e) {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append(prefixSmall, "                ");
    _builder.append("InitInlineWindow(objectType, elemPrefix);");
    _builder.newLineIfNotEmpty();
    _builder.append("                ");
    _builder.append("e.stop();");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("});");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("});");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence closeWindowFromInside(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Closes an iframe from the document displayed in it");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("function ");
    String _prefix = it.getPrefix();
    _builder.append(_prefix, "");
    _builder.append("CloseWindowFromInside(idPrefix, itemId)");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// if there is no parent window do nothing");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (window.parent === \'\') {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// search for the handler of the current window");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("window.parent.relationHandler.each(function (relationHandler) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// look if this handler is the right one");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if (relationHandler[\'prefix\'] === idPrefix) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("// do we have an item created");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("if (itemId > 0) {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("// look whether there is an auto completion instance");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("if (relationHandler.acInstance !== null) {");
    _builder.newLine();
    _builder.append("                    ");
    _builder.append("// activate it");
    _builder.newLine();
    _builder.append("                    ");
    _builder.append("relationHandler.acInstance.activate();");
    _builder.newLine();
    _builder.append("                    ");
    _builder.append("// show a message ");
    _builder.newLine();
    _builder.append("                    ");
    _builder.append("Zikula.UI.Alert(Zikula.__(\'Action has been completed.\', \'module_");
    String _appName = this._utils.appName(it);
    String _formatForDB = this._formattingExtensions.formatForDB(_appName);
    _builder.append(_formatForDB, "                    ");
    _builder.append("_js\'), Zikula.__(\'Information\',\'module_");
    String _appName_1 = this._utils.appName(it);
    String _formatForDB_1 = this._formattingExtensions.formatForDB(_appName_1);
    _builder.append(_formatForDB_1, "                    ");
    _builder.append("_js\'), {");
    _builder.newLineIfNotEmpty();
    _builder.append("                        ");
    _builder.append("autoClose: 3 // time in seconds");
    _builder.newLine();
    _builder.append("                    ");
    _builder.append("});");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("// look whether there is a windows instance");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("if (relationHandler.windowInstance !== null) {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("// close it");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("relationHandler.windowInstance.closeHandler();");
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
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
}
