package org.zikula.modulestudio.generator.cartridges.zclassic.controller.util;

import com.google.common.base.Objects;
import com.google.inject.Inject;
import de.guite.modulestudio.metamodel.modulestudio.AbstractDateField;
import de.guite.modulestudio.metamodel.modulestudio.AbstractIntegerField;
import de.guite.modulestudio.metamodel.modulestudio.Application;
import de.guite.modulestudio.metamodel.modulestudio.ArrayField;
import de.guite.modulestudio.metamodel.modulestudio.BooleanField;
import de.guite.modulestudio.metamodel.modulestudio.CalculatedField;
import de.guite.modulestudio.metamodel.modulestudio.DecimalField;
import de.guite.modulestudio.metamodel.modulestudio.DerivedField;
import de.guite.modulestudio.metamodel.modulestudio.Entity;
import de.guite.modulestudio.metamodel.modulestudio.EntityField;
import de.guite.modulestudio.metamodel.modulestudio.FloatField;
import de.guite.modulestudio.metamodel.modulestudio.ObjectField;
import de.guite.modulestudio.metamodel.modulestudio.UploadField;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.eclipse.xtext.xbase.lib.InputOutput;
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class Translatable {
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
  private ModelBehaviourExtensions _modelBehaviourExtensions = new Function0<ModelBehaviourExtensions>() {
    public ModelBehaviourExtensions apply() {
      ModelBehaviourExtensions _modelBehaviourExtensions = new ModelBehaviourExtensions();
      return _modelBehaviourExtensions;
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
    InputOutput.<String>println("Generating utility class for translatable entities");
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
    String _plus = (utilPath + "Base/Translatable");
    String _plus_1 = (_plus + utilSuffix);
    String _plus_2 = (_plus_1 + ".php");
    CharSequence _translatableFunctionsBaseFile = this.translatableFunctionsBaseFile(it);
    fsa.generateFile(_plus_2, _translatableFunctionsBaseFile);
    String _plus_3 = (utilPath + "Translatable");
    String _plus_4 = (_plus_3 + utilSuffix);
    String _plus_5 = (_plus_4 + ".php");
    CharSequence _translatableFunctionsFile = this.translatableFunctionsFile(it);
    fsa.generateFile(_plus_5, _translatableFunctionsFile);
  }
  
  private CharSequence translatableFunctionsBaseFile(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _phpFileHeader = this.fh.phpFileHeader(it);
    _builder.append(_phpFileHeader, "");
    _builder.newLineIfNotEmpty();
    CharSequence _translatableFunctionsBaseImpl = this.translatableFunctionsBaseImpl(it);
    _builder.append(_translatableFunctionsBaseImpl, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence translatableFunctionsFile(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _phpFileHeader = this.fh.phpFileHeader(it);
    _builder.append(_phpFileHeader, "");
    _builder.newLineIfNotEmpty();
    CharSequence _translatableFunctionsImpl = this.translatableFunctionsImpl(it);
    _builder.append(_translatableFunctionsImpl, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence translatableFunctionsBaseImpl(final Application it) {
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
        _builder.append("use ServiceUtil;");
        _builder.newLine();
        _builder.append("use System;");
        _builder.newLine();
        _builder.append("use Zikula_AbstractBase;");
        _builder.newLine();
        _builder.append("use ZLanguage;");
        _builder.newLine();
        _builder.newLine();
      }
    }
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Utility base class for translatable helper methods.");
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
        _builder.append("_Util_Base_Translatable");
      } else {
        _builder.append("TranslatableUtil");
      }
    }
    _builder.append(" extends Zikula_AbstractBase");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    CharSequence _translatableFieldsImpl = this.getTranslatableFieldsImpl(it);
    _builder.append(_translatableFieldsImpl, "    ");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    CharSequence _prepareEntityForEdit = this.prepareEntityForEdit(it);
    _builder.append(_prepareEntityForEdit, "    ");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    CharSequence _processEntityAfterEdit = this.processEntityAfterEdit(it);
    _builder.append(_processEntityAfterEdit, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence getTranslatableFieldsImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Return list of translatable fields per entity.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* These are required to be determined to recognize");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* that they have to be selected from according translation tables.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $objectType The currently treated object type.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return array list of translatable fields");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function getTranslatableFields($objectType)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$fields = array();");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("switch ($objectType) {");
    _builder.newLine();
    {
      Iterable<Entity> _translatableEntities = this._modelBehaviourExtensions.getTranslatableEntities(it);
      for(final Entity entity : _translatableEntities) {
        _builder.append("        ");
        CharSequence _translatableFieldList = this.translatableFieldList(entity);
        _builder.append(_translatableFieldList, "        ");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $fields;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence prepareEntityForEdit(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Post-processing method copying all translations to corresponding arrays.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* This ensures easy compatibility to the Forms plugins where it");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* it is not possible yet to define sub arrays in the group attribute.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string              $objectType The currently treated object type.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param Zikula_EntityAccess $entity     The entity being edited.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return array collected translations having the locales as keys");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function prepareEntityForEdit($objectType, $entity)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$translations = array();");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// check arguments");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!$objectType || !$entity) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return $translations;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// check if we have translated fields registered for the given object type");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$fields = $this->getTranslatableFields($objectType);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!count($fields)) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return $translations;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (System::getVar(\'multilingual\') != 1) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// Translatable extension did already fetch current translation");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return $translations;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// prepare form data to edit multiple translations at once");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$serviceManager = ServiceUtil::getManager();");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$entityManager = $serviceManager->getService(\'doctrine.entitymanager\');");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// get translations");
    _builder.newLine();
    {
      boolean _targets = this._utils.targets(it, "1.3.5");
      if (_targets) {
        _builder.append("    ");
        _builder.append("$entityClass = \'");
        String _appName = this._utils.appName(it);
        _builder.append(_appName, "    ");
        _builder.append("_Entity_\' . ucwords($objectType) . \'Translation\';");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("    ");
        _builder.append("$entityClass = \'\\\\");
        String _appName_1 = this._utils.appName(it);
        _builder.append(_appName_1, "    ");
        _builder.append("\\\\Entity\\\\\' . ucwords($objectType) . \'TranslationEntity\';");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("    ");
    _builder.append("$repository = $entityManager->getRepository($entityClass);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$entityTranslations = $repository->findTranslations($entity);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$supportedLocales = ZLanguage::getInstalledLanguages();");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$currentLanguage = ZLanguage::getLanguageCode();");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("foreach ($supportedLocales as $locale) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if ($locale == $currentLanguage) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("// Translatable extension did already fetch current translation");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("continue;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$translationData = array();");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("foreach ($fields as $field) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$translationData[$field[\'name\'] . $locale] = isset($entityTranslations[$locale]) ? $entityTranslations[$locale][$field[\'name\']] : \'\';");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// add data to collected translations");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$translations[$locale] = $translationData;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $translations;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence processEntityAfterEdit(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Post-editing method copying all translated fields back to their subarrays.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* This ensures easy compatibility to the Forms plugins where it");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* it is not possible yet to define sub arrays in the group attribute.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $objectType The currently treated object type.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param array  $formData   Form data containing translations.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return array collected translations having the locales as keys");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function processEntityAfterEdit($objectType, $formData)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$translations = array();");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// check arguments");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!$objectType || !is_array($formData)) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return $translations;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$fields = $this->getTranslatableFields($objectType);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!count($fields)) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return $translations;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$supportedLocales = ZLanguage::getInstalledLanguages();");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$useOnlyCurrentLocale = true;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (System::getVar(\'multilingual\') == 1) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$useOnlyCurrentLocale = false;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$currentLanguage = ZLanguage::getLanguageCode();");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("foreach ($supportedLocales as $locale) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("if ($locale == $currentLanguage) {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("// skip current language as this is not treated as translation on controller level");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("continue;");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$translations[$locale] = array(\'locale\' => $locale, \'fields\' => array());");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$translationData = $formData[strtolower($objectType) . $locale];");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("foreach ($fields as $field) {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("$translations[$locale][\'fields\'][$field[\'name\']] = isset($translationData[$field[\'name\'] . $locale]) ? $translationData[$field[\'name\'] . $locale] : \'\';");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("unset($formData[$field[\'name\'] . $locale]);");
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
    _builder.append("    ");
    _builder.append("if ($useOnlyCurrentLocale === true) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$locale = ZLanguage::getLanguageCode();");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$translations[$locale] = array(\'locale\' => $locale, \'fields\' => array());");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$translationData = $formData[strtolower($objectType) . $locale];");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("foreach ($fields as $field) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$translations[$locale][\'fields\'][$field[\'name\']] = isset($translationData[$field[\'name\'] . $locale]) ? $translationData[$field[\'name\'] . $locale] : \'\';");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("unset($formData[$field[\'name\'] . $locale]);");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $translations;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence translatableFieldList(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("case \'");
    String _name = it.getName();
    String _formatForCode = this._formattingExtensions.formatForCode(_name);
    _builder.append(_formatForCode, "");
    _builder.append("\':");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("$fields = array(");
    _builder.newLine();
    _builder.append("        ");
    CharSequence _translatableFieldDefinition = this.translatableFieldDefinition(it);
    _builder.append(_translatableFieldDefinition, "        ");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append(");");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("break;");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence translatableFieldDefinition(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      Iterable<DerivedField> _translatableFields = this._modelBehaviourExtensions.getTranslatableFields(it);
      boolean _hasElements = false;
      for(final DerivedField field : _translatableFields) {
        if (!_hasElements) {
          _hasElements = true;
        } else {
          _builder.appendImmediate(",", "");
        }
        CharSequence _translatableFieldDefinition = this.translatableFieldDefinition(field);
        _builder.append(_translatableFieldDefinition, "");
      }
    }
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence translatableFieldDefinition(final EntityField it) {
    CharSequence _switchResult = null;
    boolean _matched = false;
    if (!_matched) {
      if (it instanceof BooleanField) {
        final BooleanField _booleanField = (BooleanField)it;
        _matched=true;
        StringConcatenation _builder = new StringConcatenation();
        _builder.append("array(\'name\' => \'");
        String _name = _booleanField.getName();
        _builder.append(_name, "");
        _builder.append("\',");
        _builder.newLineIfNotEmpty();
        _builder.append("      ");
        _builder.append("\'default\' => ");
        {
          boolean _and = false;
          String _defaultValue = _booleanField.getDefaultValue();
          boolean _tripleNotEquals = (_defaultValue != null);
          if (!_tripleNotEquals) {
            _and = false;
          } else {
            String _defaultValue_1 = _booleanField.getDefaultValue();
            boolean _notEquals = (!Objects.equal(_defaultValue_1, ""));
            _and = (_tripleNotEquals && _notEquals);
          }
          if (_and) {
            String _defaultValue_2 = _booleanField.getDefaultValue();
            boolean _equals = Objects.equal(_defaultValue_2, "true");
            String _displayBool = this._formattingExtensions.displayBool(Boolean.valueOf(_equals));
            _builder.append(_displayBool, "      ");
          } else {
            _builder.append("false");
          }
        }
        _builder.append(")");
        _switchResult = _builder;
      }
    }
    if (!_matched) {
      if (it instanceof AbstractIntegerField) {
        final AbstractIntegerField _abstractIntegerField = (AbstractIntegerField)it;
        _matched=true;
        CharSequence _translatableFieldDefinitionNumeric = this.translatableFieldDefinitionNumeric(_abstractIntegerField);
        _switchResult = _translatableFieldDefinitionNumeric;
      }
    }
    if (!_matched) {
      if (it instanceof DecimalField) {
        final DecimalField _decimalField = (DecimalField)it;
        _matched=true;
        CharSequence _translatableFieldDefinitionNumeric = this.translatableFieldDefinitionNumeric(_decimalField);
        _switchResult = _translatableFieldDefinitionNumeric;
      }
    }
    if (!_matched) {
      if (it instanceof FloatField) {
        final FloatField _floatField = (FloatField)it;
        _matched=true;
        CharSequence _translatableFieldDefinitionNumeric = this.translatableFieldDefinitionNumeric(_floatField);
        _switchResult = _translatableFieldDefinitionNumeric;
      }
    }
    if (!_matched) {
      if (it instanceof UploadField) {
        final UploadField _uploadField = (UploadField)it;
        _matched=true;
        CharSequence _translatableFieldDefinitionNoDefault = this.translatableFieldDefinitionNoDefault(_uploadField);
        _switchResult = _translatableFieldDefinitionNoDefault;
      }
    }
    if (!_matched) {
      if (it instanceof ArrayField) {
        final ArrayField _arrayField = (ArrayField)it;
        _matched=true;
        CharSequence _translatableFieldDefinitionNoDefault = this.translatableFieldDefinitionNoDefault(_arrayField);
        _switchResult = _translatableFieldDefinitionNoDefault;
      }
    }
    if (!_matched) {
      if (it instanceof ObjectField) {
        final ObjectField _objectField = (ObjectField)it;
        _matched=true;
        CharSequence _translatableFieldDefinitionNoDefault = this.translatableFieldDefinitionNoDefault(_objectField);
        _switchResult = _translatableFieldDefinitionNoDefault;
      }
    }
    if (!_matched) {
      if (it instanceof AbstractDateField) {
        final AbstractDateField _abstractDateField = (AbstractDateField)it;
        _matched=true;
        StringConcatenation _builder = new StringConcatenation();
        _builder.append("array(\'name\' => \'");
        String _name = _abstractDateField.getName();
        _builder.append(_name, "");
        _builder.append("\',");
        _builder.newLineIfNotEmpty();
        _builder.append("      ");
        _builder.append("\'default\' => \'");
        {
          boolean _and = false;
          String _defaultValue = _abstractDateField.getDefaultValue();
          boolean _tripleNotEquals = (_defaultValue != null);
          if (!_tripleNotEquals) {
            _and = false;
          } else {
            String _defaultValue_1 = _abstractDateField.getDefaultValue();
            boolean _notEquals = (!Objects.equal(_defaultValue_1, ""));
            _and = (_tripleNotEquals && _notEquals);
          }
          if (_and) {
            String _defaultValue_2 = _abstractDateField.getDefaultValue();
            _builder.append(_defaultValue_2, "      ");
          }
        }
        _builder.append("\')");
        _switchResult = _builder;
      }
    }
    if (!_matched) {
      if (it instanceof DerivedField) {
        final DerivedField _derivedField = (DerivedField)it;
        _matched=true;
        StringConcatenation _builder = new StringConcatenation();
        _builder.append("array(\'name\' => \'");
        String _name = _derivedField.getName();
        _builder.append(_name, "");
        _builder.append("\',");
        _builder.newLineIfNotEmpty();
        _builder.append("      ");
        _builder.append("\'default\' => $this->__(\'");
        {
          boolean _and = false;
          String _defaultValue = _derivedField.getDefaultValue();
          boolean _tripleNotEquals = (_defaultValue != null);
          if (!_tripleNotEquals) {
            _and = false;
          } else {
            String _defaultValue_1 = _derivedField.getDefaultValue();
            boolean _notEquals = (!Objects.equal(_defaultValue_1, ""));
            _and = (_tripleNotEquals && _notEquals);
          }
          if (_and) {
            String _defaultValue_2 = _derivedField.getDefaultValue();
            _builder.append(_defaultValue_2, "      ");
          } else {
            String _name_1 = _derivedField.getName();
            String _formatForDisplayCapital = this._formattingExtensions.formatForDisplayCapital(_name_1);
            _builder.append(_formatForDisplayCapital, "      ");
          }
        }
        _builder.append("\'))");
        _switchResult = _builder;
      }
    }
    if (!_matched) {
      if (it instanceof CalculatedField) {
        final CalculatedField _calculatedField = (CalculatedField)it;
        _matched=true;
        StringConcatenation _builder = new StringConcatenation();
        _builder.append("array(\'name\'    => \'");
        String _name = _calculatedField.getName();
        _builder.append(_name, "");
        _builder.append("\',");
        _builder.newLineIfNotEmpty();
        _builder.append("      ");
        _builder.append("\'default\' => $this->__(\'");
        String _name_1 = _calculatedField.getName();
        String _formatForDisplayCapital = this._formattingExtensions.formatForDisplayCapital(_name_1);
        _builder.append(_formatForDisplayCapital, "      ");
        _builder.append("\'))");
        _switchResult = _builder;
      }
    }
    return _switchResult;
  }
  
  private CharSequence translatableFieldDefinitionNumeric(final DerivedField it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("array(\'name\' => \'");
    String _name = it.getName();
    _builder.append(_name, "");
    _builder.append("\',");
    _builder.newLineIfNotEmpty();
    _builder.append("      ");
    _builder.append("\'default\' => 0)");
    return _builder;
  }
  
  private CharSequence translatableFieldDefinitionNoDefault(final DerivedField it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("array(\'name\' => \'");
    String _name = it.getName();
    _builder.append(_name, "");
    _builder.append("\',");
    _builder.newLineIfNotEmpty();
    _builder.append("      ");
    _builder.append("\'default\' => \'\')");
    return _builder;
  }
  
  private CharSequence translatableFunctionsImpl(final Application it) {
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
    _builder.append("* Utility implementation class for translatable helper methods.");
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
        _builder.append("_Util_Translatable extends ");
        String _appName_2 = this._utils.appName(it);
        _builder.append(_appName_2, "");
        _builder.append("_Util_Base_Translatable");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("class TranslatableUtil extends Base\\TranslatableUtil");
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
