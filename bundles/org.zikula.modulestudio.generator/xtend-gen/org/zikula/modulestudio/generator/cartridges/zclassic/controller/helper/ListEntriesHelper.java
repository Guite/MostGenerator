package org.zikula.modulestudio.generator.cartridges.zclassic.controller.helper;

import com.google.common.base.Objects;
import de.guite.modulestudio.metamodel.Application;
import de.guite.modulestudio.metamodel.DataObject;
import de.guite.modulestudio.metamodel.ListField;
import de.guite.modulestudio.metamodel.ListFieldItem;
import org.eclipse.emf.common.util.EList;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.InputOutput;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class ListEntriesHelper {
  @Extension
  private FormattingExtensions _formattingExtensions = new FormattingExtensions();
  
  @Extension
  private ModelBehaviourExtensions _modelBehaviourExtensions = new ModelBehaviourExtensions();
  
  @Extension
  private ModelExtensions _modelExtensions = new ModelExtensions();
  
  @Extension
  private NamingExtensions _namingExtensions = new NamingExtensions();
  
  @Extension
  private Utils _utils = new Utils();
  
  /**
   * Entry point for the helper class creation.
   */
  public void generate(final Application it, final IFileSystemAccess fsa) {
    InputOutput.<String>println("Generating helper class for list entries");
    final FileHelper fh = new FileHelper();
    String _appSourceLibPath = this._namingExtensions.getAppSourceLibPath(it);
    String _plus = (_appSourceLibPath + "Helper/ListEntriesHelper.php");
    this._namingExtensions.generateClassPair(it, fsa, _plus, 
      fh.phpFileContent(it, this.listFieldFunctionsBaseImpl(it)), fh.phpFileContent(it, this.listFieldFunctionsImpl(it)));
  }
  
  private CharSequence listFieldFunctionsBaseImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("namespace ");
    String _appNamespace = this._utils.appNamespace(it);
    _builder.append(_appNamespace);
    _builder.append("\\Helper\\Base;");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("use Zikula\\Common\\Translator\\TranslatorInterface;");
    _builder.newLine();
    _builder.append("use Zikula\\Common\\Translator\\TranslatorTrait;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Helper base class for list field entries related methods.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("abstract class AbstractListEntriesHelper");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("use TranslatorTrait;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* ListEntriesHelper constructor.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @param TranslatorInterface $translator Translator service instance");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("public function __construct(TranslatorInterface $translator)");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$this->setTranslator($translator);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    CharSequence _setTranslatorMethod = this._modelBehaviourExtensions.setTranslatorMethod(it);
    _builder.append(_setTranslatorMethod, "    ");
    _builder.newLineIfNotEmpty();
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
    _builder.append("* @param string $value      The dropdown value to process");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $objectType The treated object type");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $fieldName  The list field\'s name");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $delimiter  String used as separator for multiple selections");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return string List item name");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function resolve($value, $objectType = \'\', $fieldName = \'\', $delimiter = \', \')");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ((empty($value) && $value != \'0\') || empty($objectType) || empty($fieldName)) {");
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
    _builder.append("if (true === $isMulti) {");
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
    _builder.append("if (true === $isMulti) {");
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
    _builder.append("* @param string  $value The dropdown value to process");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return array List of single values");
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
    _builder.append("$amountOfValues = count($listValues);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($amountOfValues > 1 && $listValues[$amountOfValues - 1] == \'\') {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("unset($listValues[$amountOfValues - 1]);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($listValues[0] == \'\') {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// use array_shift instead of unset for proper key reindexing");
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
    _builder.append("* @param string $objectType The treated object type");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $fieldName  The list field\'s name");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return boolean True if this is a multi list false otherwise");
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
      final Function1<DataObject, Boolean> _function = (DataObject it_1) -> {
        return Boolean.valueOf(this._modelExtensions.hasListFieldsEntity(it_1));
      };
      Iterable<DataObject> _filter = IterableExtensions.<DataObject>filter(it.getEntities(), _function);
      for(final DataObject entity : _filter) {
        _builder.append("        ");
        _builder.append("case \'");
        String _formatForCode = this._formattingExtensions.formatForCode(entity.getName());
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
            String _formatForCode_1 = this._formattingExtensions.formatForCode(listField.getName());
            _builder.append(_formatForCode_1, "                ");
            _builder.append("\':");
            _builder.newLineIfNotEmpty();
            _builder.append("        ");
            _builder.append("        ");
            _builder.append("    ");
            _builder.append("$result = ");
            String _displayBool = this._formattingExtensions.displayBool(Boolean.valueOf(listField.isMultiple()));
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
    _builder.append("* @param string  $objectType The treated object type");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string  $fieldName  The list field\'s name");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return array Array with desired list entries");
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
    _builder.append("return [];");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$entries = [];");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("switch ($objectType) {");
    _builder.newLine();
    {
      final Function1<DataObject, Boolean> _function = (DataObject it_1) -> {
        return Boolean.valueOf(this._modelExtensions.hasListFieldsEntity(it_1));
      };
      Iterable<DataObject> _filter = IterableExtensions.<DataObject>filter(it.getEntities(), _function);
      for(final DataObject entity : _filter) {
        _builder.append("        ");
        _builder.append("case \'");
        String _formatForCode = this._formattingExtensions.formatForCode(entity.getName());
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
            String _formatForCode_1 = this._formattingExtensions.formatForCode(listField.getName());
            _builder.append(_formatForCode_1, "                ");
            _builder.append("\':");
            _builder.newLineIfNotEmpty();
            _builder.append("        ");
            _builder.append("        ");
            _builder.append("    ");
            _builder.append("$entries = $this->get");
            String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(listField.getName());
            _builder.append(_formatForCodeCapital, "                    ");
            _builder.append("EntriesFor");
            String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(entity.getName());
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
        _builder.append(_itemsImpl);
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
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(it.getName());
    _builder.append(_formatForDisplay, " ");
    _builder.append("\' list entries.");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return array Array with desired list entries");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function get");
    String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital);
    _builder.append("EntriesFor");
    String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(it.getEntity().getName());
    _builder.append(_formatForCodeCapital_1);
    _builder.append("()");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$states = [];");
    _builder.newLine();
    {
      String _name = it.getName();
      boolean _equals = Objects.equal(_name, "workflowState");
      if (_equals) {
        _builder.append("    ");
        final Function1<ListFieldItem, Boolean> _function = (ListFieldItem it_1) -> {
          return Boolean.valueOf(((!Objects.equal(it_1.getValue(), "initial")) && (!Objects.equal(it_1.getValue(), "deleted"))));
        };
        final Iterable<ListFieldItem> visibleStates = IterableExtensions.<ListFieldItem>filter(it.getItems(), _function);
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        {
          for(final ListFieldItem item : visibleStates) {
            CharSequence _entryInfo = this.entryInfo(item, it.getEntity().getApplication());
            _builder.append(_entryInfo, "    ");
          }
        }
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        {
          for(final ListFieldItem item_1 : visibleStates) {
            CharSequence _entryInfoNegative = this.entryInfoNegative(item_1, it.getEntity().getApplication());
            _builder.append(_entryInfoNegative, "    ");
          }
        }
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("    ");
        {
          EList<ListFieldItem> _items = it.getItems();
          for(final ListFieldItem item_2 : _items) {
            CharSequence _entryInfo_1 = this.entryInfo(item_2, it.getEntity().getApplication());
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
  
  private CharSequence entryInfo(final ListFieldItem it, final Application app) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("$states[] = [");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("\'value\'   => \'");
    {
      String _value = it.getValue();
      boolean _tripleNotEquals = (null != _value);
      if (_tripleNotEquals) {
        String _replace = it.getValue().replace("\'", "");
        _builder.append(_replace, "    ");
      } else {
        String _replace_1 = this._formattingExtensions.formatForCode(it.getName()).replace("\'", "");
        _builder.append(_replace_1, "    ");
      }
    }
    _builder.append("\',");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("\'text\'    => $this->__(\'");
    String _replace_2 = this._formattingExtensions.formatForDisplayCapital(it.getName()).replace("\'", "");
    _builder.append(_replace_2, "    ");
    _builder.append("\'),");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("\'title\'   => ");
    {
      if (((null != it.getDocumentation()) && (!Objects.equal(it.getDocumentation(), "")))) {
        _builder.append("$this->__(\'");
        String _replace_3 = it.getDocumentation().replace("\'", "");
        _builder.append(_replace_3, "    ");
        _builder.append("\')");
      } else {
        _builder.append("\'\'");
      }
    }
    _builder.append(",");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("\'image\'   => \'");
    {
      if (((null != it.getImage()) && (!Objects.equal(it.getImage(), "")))) {
        String _image = it.getImage();
        _builder.append(_image, "    ");
        _builder.append(".png");
      }
    }
    _builder.append("\',");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("\'default\' => ");
    String _displayBool = this._formattingExtensions.displayBool(Boolean.valueOf(it.isDefault()));
    _builder.append(_displayBool, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("];");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence entryInfoNegative(final ListFieldItem it, final Application app) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("$states[] = [");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("\'value\'   => \'!");
    {
      String _value = it.getValue();
      boolean _tripleNotEquals = (null != _value);
      if (_tripleNotEquals) {
        String _replace = it.getValue().replace("\'", "");
        _builder.append(_replace, "    ");
      } else {
        String _replace_1 = this._formattingExtensions.formatForCode(it.getName()).replace("\'", "");
        _builder.append(_replace_1, "    ");
      }
    }
    _builder.append("\',");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("\'text\'    => $this->__(\'All except ");
    String _replace_2 = this._formattingExtensions.formatForDisplay(it.getName()).replace("\'", "");
    _builder.append(_replace_2, "    ");
    _builder.append("\'),");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("\'title\'   => $this->__(\'Shows all items except these which are ");
    String _replace_3 = this._formattingExtensions.formatForDisplay(it.getName()).replace("\'", "");
    _builder.append(_replace_3, "    ");
    _builder.append("\'),");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("\'image\'   => \'\',");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("\'default\' => false");
    _builder.newLine();
    _builder.append("];");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence listFieldFunctionsImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("namespace ");
    String _appNamespace = this._utils.appNamespace(it);
    _builder.append(_appNamespace);
    _builder.append("\\Helper;");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("use ");
    String _appNamespace_1 = this._utils.appNamespace(it);
    _builder.append(_appNamespace_1);
    _builder.append("\\Helper\\Base\\AbstractListEntriesHelper;");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Helper implementation class for list field entries related methods.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("class ListEntriesHelper extends AbstractListEntriesHelper");
    _builder.newLine();
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
