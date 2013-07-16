package org.zikula.modulestudio.generator.cartridges.zclassic.controller.util;

import com.google.common.base.Objects;
import com.google.inject.Inject;
import de.guite.modulestudio.metamodel.modulestudio.Application;
import de.guite.modulestudio.metamodel.modulestudio.Entity;
import de.guite.modulestudio.metamodel.modulestudio.ListField;
import de.guite.modulestudio.metamodel.modulestudio.ListFieldItem;
import org.eclipse.emf.common.util.EList;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.InputOutput;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class ListEntries {
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
  
  private FileHelper fh = new Function0<FileHelper>() {
    public FileHelper apply() {
      FileHelper _fileHelper = new FileHelper();
      return _fileHelper;
    }
  }.apply();
  
  /**
   * Entry point for the utility class creation.
   */
  public void generate(final Application it, final IFileSystemAccess fsa) {
    InputOutput.<String>println("Generating utility class for list entries");
    String _appSourceLibPath = this._namingExtensions.getAppSourceLibPath(it);
    final String utilPath = (_appSourceLibPath + "Util/");
    String _xifexpression = null;
    boolean _targets = this._utils.targets(it, "1.3.5");
    if (_targets) {
      _xifexpression = "";
    } else {
      _xifexpression = "Util";
    }
    final String utilSuffix = _xifexpression;
    String _plus = (utilPath + "Base/ListEntries");
    String _plus_1 = (_plus + utilSuffix);
    String _plus_2 = (_plus_1 + ".php");
    CharSequence _listFieldFunctionsBaseFile = this.listFieldFunctionsBaseFile(it);
    fsa.generateFile(_plus_2, _listFieldFunctionsBaseFile);
    String _plus_3 = (utilPath + "ListEntries");
    String _plus_4 = (_plus_3 + utilSuffix);
    String _plus_5 = (_plus_4 + ".php");
    CharSequence _listFieldFunctionsFile = this.listFieldFunctionsFile(it);
    fsa.generateFile(_plus_5, _listFieldFunctionsFile);
  }
  
  private CharSequence listFieldFunctionsBaseFile(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _phpFileHeader = this.fh.phpFileHeader(it);
    _builder.append(_phpFileHeader, "");
    _builder.newLineIfNotEmpty();
    CharSequence _listFieldFunctionsBaseImpl = this.listFieldFunctionsBaseImpl(it);
    _builder.append(_listFieldFunctionsBaseImpl, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence listFieldFunctionsFile(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _phpFileHeader = this.fh.phpFileHeader(it);
    _builder.append(_phpFileHeader, "");
    _builder.newLineIfNotEmpty();
    CharSequence _listFieldFunctionsImpl = this.listFieldFunctionsImpl(it);
    _builder.append(_listFieldFunctionsImpl, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence listFieldFunctionsBaseImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _targets = this._utils.targets(it, "1.3.5");
      boolean _not = (!_targets);
      if (_not) {
        _builder.append("namespace ");
        String _appName = this._utils.appName(it);
        _builder.append(_appName, "");
        _builder.append("\\Util\\Base;");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
        _builder.append("use Zikula_AbstractBase;");
        _builder.newLine();
      }
    }
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Utility base class for list field entries related methods.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("class ");
    {
      boolean _targets_1 = this._utils.targets(it, "1.3.5");
      if (_targets_1) {
        String _appName_1 = this._utils.appName(it);
        _builder.append(_appName_1, "");
        _builder.append("_Util_Base_ListEntries");
      } else {
        _builder.append("ListEntriesUtil");
      }
    }
    _builder.append(" extends Zikula_AbstractBase");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    CharSequence _resolve = this.resolve(it);
    _builder.append(_resolve, "    ");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    CharSequence _extractMultiList = this.extractMultiList(it);
    _builder.append(_extractMultiList, "    ");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    CharSequence _hasMultipleSelection = this.hasMultipleSelection(it);
    _builder.append(_hasMultipleSelection, "    ");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    CharSequence _entries = this.getEntries(it);
    _builder.append(_entries, "    ");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    CharSequence _additions = this.additions(it);
    _builder.append(_additions, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence resolve(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Return the name or names for a given list item.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $value      The dropdown value to process.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $objectType The treated object type.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $fieldName  The list field\'s name.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $delimiter  String used as separator for multiple selections.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return string List item name.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function resolve($value, $objectType = \'\', $fieldName = \'\', $delimiter = \', \')");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (empty($value) || empty($objectType) || empty($fieldName)) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return $value;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$isMulti = $this->hasMultipleSelection($objectType, $fieldName);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($isMulti === true) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$value = $this->extractMultiList($value);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$options = $this->getEntries($objectType, $fieldName);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$result = \'\';");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($isMulti === true) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("foreach ($options as $option) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("if (!in_array($option[\'value\'], $value)) {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("continue;");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("if (!empty($result)) {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("$result .= $delimiter;");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$result .= $option[\'text\'];");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("} else {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("foreach ($options as $option) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("if ($option[\'value\'] != $value) {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("continue;");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$result = $option[\'text\'];");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("break;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $result;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence extractMultiList(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Extract concatenated multi selection.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string  $value The dropdown value to process.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return array List of single values.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function extractMultiList($value)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$listValues = explode(\'###\', $value);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$numValues = count($listValues);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($numValues > 1 && $listValues[$numValues-1] == \'\') {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("unset($listValues[$numValues-1]);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($listValues[0] == \'\') {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// use array_shift insteaf of unset for proper key reindexing");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// keys must start with 0, otherwise the dropdownlist form plugin gets confused");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("array_shift($listValues);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $listValues;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence hasMultipleSelection(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Determine whether a certain dropdown field has a multi selection or not.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $objectType The treated object type.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $fieldName  The list field\'s name.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return boolean True if this is a multi list false otherwise.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function hasMultipleSelection($objectType, $fieldName)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (empty($objectType) || empty($fieldName)) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return false;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$result = false;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("switch ($objectType) {");
    _builder.newLine();
    {
      EList<Entity> _allEntities = this._modelExtensions.getAllEntities(it);
      final Function1<Entity,Boolean> _function = new Function1<Entity,Boolean>() {
          public Boolean apply(final Entity e) {
            boolean _hasListFieldsEntity = ListEntries.this._modelExtensions.hasListFieldsEntity(e);
            return Boolean.valueOf(_hasListFieldsEntity);
          }
        };
      Iterable<Entity> _filter = IterableExtensions.<Entity>filter(_allEntities, _function);
      for(final Entity entity : _filter) {
        _builder.append("        ");
        _builder.append("case \'");
        String _name = entity.getName();
        String _formatForCode = this._formattingExtensions.formatForCode(_name);
        _builder.append(_formatForCode, "        ");
        _builder.append("\':");
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("switch ($fieldName) {");
        _builder.newLine();
        {
          Iterable<ListField> _listFieldsEntity = this._modelExtensions.getListFieldsEntity(entity);
          for(final ListField listField : _listFieldsEntity) {
            _builder.append("        ");
            _builder.append("        ");
            _builder.append("case \'");
            String _name_1 = listField.getName();
            String _formatForCode_1 = this._formattingExtensions.formatForCode(_name_1);
            _builder.append(_formatForCode_1, "                ");
            _builder.append("\':");
            _builder.newLineIfNotEmpty();
            _builder.append("        ");
            _builder.append("        ");
            _builder.append("    ");
            _builder.append("$result = ");
            boolean _isMultiple = listField.isMultiple();
            String _displayBool = this._formattingExtensions.displayBool(Boolean.valueOf(_isMultiple));
            _builder.append(_displayBool, "                    ");
            _builder.append(";");
            _builder.newLineIfNotEmpty();
            _builder.append("        ");
            _builder.append("        ");
            _builder.append("    ");
            _builder.append("break;");
            _builder.newLine();
          }
        }
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("break;");
        _builder.newLine();
      }
    }
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $result;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence getEntries(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Get entries for a certain dropdown field.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string  $objectType The treated object type.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string  $fieldName  The list field\'s name.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return array Array with desired list entries.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function getEntries($objectType, $fieldName)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (empty($objectType) || empty($fieldName)) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return array();");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$entries = array();");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("switch ($objectType) {");
    _builder.newLine();
    {
      EList<Entity> _allEntities = this._modelExtensions.getAllEntities(it);
      final Function1<Entity,Boolean> _function = new Function1<Entity,Boolean>() {
          public Boolean apply(final Entity e) {
            boolean _hasListFieldsEntity = ListEntries.this._modelExtensions.hasListFieldsEntity(e);
            return Boolean.valueOf(_hasListFieldsEntity);
          }
        };
      Iterable<Entity> _filter = IterableExtensions.<Entity>filter(_allEntities, _function);
      for(final Entity entity : _filter) {
        _builder.append("        ");
        _builder.append("case \'");
        String _name = entity.getName();
        String _formatForCode = this._formattingExtensions.formatForCode(_name);
        _builder.append(_formatForCode, "        ");
        _builder.append("\':");
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("switch ($fieldName) {");
        _builder.newLine();
        {
          Iterable<ListField> _listFieldsEntity = this._modelExtensions.getListFieldsEntity(entity);
          for(final ListField listField : _listFieldsEntity) {
            _builder.append("        ");
            _builder.append("        ");
            _builder.append("case \'");
            String _name_1 = listField.getName();
            String _formatForCode_1 = this._formattingExtensions.formatForCode(_name_1);
            _builder.append(_formatForCode_1, "                ");
            _builder.append("\':");
            _builder.newLineIfNotEmpty();
            _builder.append("        ");
            _builder.append("        ");
            _builder.append("    ");
            _builder.append("$entries = $this->get");
            String _name_2 = listField.getName();
            String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(_name_2);
            _builder.append(_formatForCodeCapital, "                    ");
            _builder.append("EntriesFor");
            String _name_3 = entity.getName();
            String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(_name_3);
            _builder.append(_formatForCodeCapital_1, "                    ");
            _builder.append("();");
            _builder.newLineIfNotEmpty();
            _builder.append("        ");
            _builder.append("        ");
            _builder.append("    ");
            _builder.append("break;");
            _builder.newLine();
          }
        }
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("break;");
        _builder.newLine();
      }
    }
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $entries;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence additions(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      Iterable<ListField> _allListFields = this._modelExtensions.getAllListFields(it);
      for(final ListField listField : _allListFields) {
        _builder.newLine();
        CharSequence _itemsImpl = this.getItemsImpl(listField);
        _builder.append(_itemsImpl, "");
        _builder.newLineIfNotEmpty();
      }
    }
    return _builder;
  }
  
  private CharSequence getItemsImpl(final ListField it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Get \'");
    String _name = it.getName();
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(_name);
    _builder.append(_formatForDisplay, " ");
    _builder.append("\' list entries.");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return array Array with desired list entries.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function get");
    String _name_1 = it.getName();
    String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(_name_1);
    _builder.append(_formatForCodeCapital, "");
    _builder.append("EntriesFor");
    Entity _entity = it.getEntity();
    String _name_2 = _entity.getName();
    String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(_name_2);
    _builder.append(_formatForCodeCapital_1, "");
    _builder.append("()");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$states = array();");
    _builder.newLine();
    {
      String _name_3 = it.getName();
      boolean _equals = Objects.equal(_name_3, "workflowState");
      if (_equals) {
        _builder.append("    ");
        EList<ListFieldItem> _items = it.getItems();
        final Function1<ListFieldItem,Boolean> _function = new Function1<ListFieldItem,Boolean>() {
            public Boolean apply(final ListFieldItem e) {
              boolean _and = false;
              String _value = e.getValue();
              boolean _notEquals = (!Objects.equal(_value, "initial"));
              if (!_notEquals) {
                _and = false;
              } else {
                String _value_1 = e.getValue();
                boolean _notEquals_1 = (!Objects.equal(_value_1, "deleted"));
                _and = (_notEquals && _notEquals_1);
              }
              return Boolean.valueOf(_and);
            }
          };
        final Iterable<ListFieldItem> visibleStates = IterableExtensions.<ListFieldItem>filter(_items, _function);
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        {
          for(final ListFieldItem item : visibleStates) {
            CharSequence _entryInfo = this.entryInfo(item);
            _builder.append(_entryInfo, "    ");
          }
        }
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        {
          for(final ListFieldItem item_1 : visibleStates) {
            CharSequence _entryInfoNegative = this.entryInfoNegative(item_1);
            _builder.append(_entryInfoNegative, "    ");
          }
        }
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("    ");
        {
          EList<ListFieldItem> _items_1 = it.getItems();
          for(final ListFieldItem item_2 : _items_1) {
            CharSequence _entryInfo_1 = this.entryInfo(item_2);
            _builder.append(_entryInfo_1, "    ");
          }
        }
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $states;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence entryInfo(final ListFieldItem it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("$states[] = array(\'value\' => \'");
    String _value = it.getValue();
    String _replaceAll = _value.replaceAll("\'", "");
    _builder.append(_replaceAll, "");
    _builder.append("\',");
    _builder.newLineIfNotEmpty();
    _builder.append("                  ");
    _builder.append("\'text\'  => $this->__(\'");
    String _name = it.getName();
    String _formatForDisplayCapital = this._formattingExtensions.formatForDisplayCapital(_name);
    String _replaceAll_1 = _formatForDisplayCapital.replaceAll("\'", "");
    _builder.append(_replaceAll_1, "                  ");
    _builder.append("\'),");
    _builder.newLineIfNotEmpty();
    _builder.append("                  ");
    _builder.append("\'title\' => ");
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
        _builder.append("$this->__(\'");
        String _documentation_2 = it.getDocumentation();
        String _replaceAll_2 = _documentation_2.replaceAll("\'", "");
        _builder.append(_replaceAll_2, "                  ");
        _builder.append("\')");
      } else {
        _builder.append("\'\'");
      }
    }
    _builder.append(",");
    _builder.newLineIfNotEmpty();
    _builder.append("                  ");
    _builder.append("\'image\' => \'");
    {
      boolean _and_1 = false;
      String _image = it.getImage();
      boolean _tripleNotEquals_1 = (_image != null);
      if (!_tripleNotEquals_1) {
        _and_1 = false;
      } else {
        String _image_1 = it.getImage();
        boolean _notEquals_1 = (!Objects.equal(_image_1, ""));
        _and_1 = (_tripleNotEquals_1 && _notEquals_1);
      }
      if (_and_1) {
        String _image_2 = it.getImage();
        _builder.append(_image_2, "                  ");
        _builder.append(".png");
      }
    }
    _builder.append("\');");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence entryInfoNegative(final ListFieldItem it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("$states[] = array(\'value\' => \'!");
    String _value = it.getValue();
    String _replaceAll = _value.replaceAll("\'", "");
    _builder.append(_replaceAll, "");
    _builder.append("\',");
    _builder.newLineIfNotEmpty();
    _builder.append("                  ");
    _builder.append("\'text\'  => $this->__(\'All except ");
    String _name = it.getName();
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(_name);
    String _replaceAll_1 = _formatForDisplay.replaceAll("\'", "");
    _builder.append(_replaceAll_1, "                  ");
    _builder.append("\'),");
    _builder.newLineIfNotEmpty();
    _builder.append("                  ");
    _builder.append("\'title\' => $this->__(\'Shows all items except these which are ");
    String _name_1 = it.getName();
    String _formatForDisplay_1 = this._formattingExtensions.formatForDisplay(_name_1);
    String _replaceAll_2 = _formatForDisplay_1.replaceAll("\'", "");
    _builder.append(_replaceAll_2, "                  ");
    _builder.append("\'),");
    _builder.newLineIfNotEmpty();
    _builder.append("                  ");
    _builder.append("\'image\' => \'\');");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence listFieldFunctionsImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _targets = this._utils.targets(it, "1.3.5");
      boolean _not = (!_targets);
      if (_not) {
        _builder.append("namespace ");
        String _appName = this._utils.appName(it);
        _builder.append(_appName, "");
        _builder.append("\\Util;");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
      }
    }
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Utility implementation class for list field entries related methods.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    {
      boolean _targets_1 = this._utils.targets(it, "1.3.5");
      if (_targets_1) {
        _builder.append("class ");
        String _appName_1 = this._utils.appName(it);
        _builder.append(_appName_1, "");
        _builder.append("_Util_ListEntries extends ");
        String _appName_2 = this._utils.appName(it);
        _builder.append(_appName_2, "");
        _builder.append("_Util_Base_ListEntries");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("class ListEntriesUtil extends Base\\ListEntriesUtil");
        _builder.newLine();
      }
    }
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// feel free to add your own convenience methods here");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
}
