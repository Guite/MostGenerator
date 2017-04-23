package org.zikula.modulestudio.generator.cartridges.zclassic.controller.helper;

import de.guite.modulestudio.metamodel.Application;
import de.guite.modulestudio.metamodel.DerivedField;
import de.guite.modulestudio.metamodel.Entity;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.InputOutput;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class TranslatableHelper {
  @Extension
  private FormattingExtensions _formattingExtensions = new FormattingExtensions();
  
  @Extension
  private ModelBehaviourExtensions _modelBehaviourExtensions = new ModelBehaviourExtensions();
  
  @Extension
  private NamingExtensions _namingExtensions = new NamingExtensions();
  
  @Extension
  private Utils _utils = new Utils();
  
  /**
   * Entry point for the helper class creation.
   */
  public void generate(final Application it, final IFileSystemAccess fsa) {
    InputOutput.<String>println("Generating helper class for translatable entities");
    final FileHelper fh = new FileHelper();
    String _appSourceLibPath = this._namingExtensions.getAppSourceLibPath(it);
    String _plus = (_appSourceLibPath + "Helper/TranslatableHelper.php");
    this._namingExtensions.generateClassPair(it, fsa, _plus, 
      fh.phpFileContent(it, this.translatableFunctionsBaseImpl(it)), fh.phpFileContent(it, this.translatableFunctionsImpl(it)));
  }
  
  private CharSequence translatableFunctionsBaseImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("namespace ");
    String _appNamespace = this._utils.appNamespace(it);
    _builder.append(_appNamespace);
    _builder.append("\\Helper\\Base;");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("use Symfony\\Component\\Form\\FormInterface;");
    _builder.newLine();
    _builder.append("use Symfony\\Component\\HttpFoundation\\Request;");
    _builder.newLine();
    _builder.append("use Symfony\\Component\\HttpFoundation\\RequestStack;");
    _builder.newLine();
    _builder.append("use Zikula\\Common\\Translator\\TranslatorInterface;");
    _builder.newLine();
    _builder.append("use Zikula\\Core\\Doctrine\\EntityAccess;");
    _builder.newLine();
    _builder.append("use Zikula\\ExtensionsModule\\Api\\");
    {
      Boolean _targets = this._utils.targets(it, "1.5");
      if ((_targets).booleanValue()) {
        _builder.append("ApiInterface\\VariableApiInterface");
      } else {
        _builder.append("VariableApi");
      }
    }
    _builder.append(";");
    _builder.newLineIfNotEmpty();
    _builder.append("use Zikula\\SettingsModule\\Api\\");
    {
      Boolean _targets_1 = this._utils.targets(it, "1.5");
      if ((_targets_1).booleanValue()) {
        _builder.append("ApiInterface\\LocaleApiInterface");
      } else {
        _builder.append("LocaleApi");
      }
    }
    _builder.append(";");
    _builder.newLineIfNotEmpty();
    _builder.append("use ");
    String _appNamespace_1 = this._utils.appNamespace(it);
    _builder.append(_appNamespace_1);
    _builder.append("\\Entity\\Factory\\");
    String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital);
    _builder.append("Factory;");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Helper base class for translatable methods.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("abstract class AbstractTranslatableHelper");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @var TranslatorInterface");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("protected $translator;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @var Request");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("protected $request;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @var VariableApi");
    {
      Boolean _targets_2 = this._utils.targets(it, "1.5");
      if ((_targets_2).booleanValue()) {
        _builder.append("Interface");
      }
    }
    _builder.newLineIfNotEmpty();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("protected $variableApi;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @var LocaleApi");
    {
      Boolean _targets_3 = this._utils.targets(it, "1.5");
      if ((_targets_3).booleanValue()) {
        _builder.append("Interface");
      }
    }
    _builder.newLineIfNotEmpty();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("protected $localeApi;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @var ");
    String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital_1, "     ");
    _builder.append("Factory");
    _builder.newLineIfNotEmpty();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("protected $entityFactory;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* TranslatableHelper constructor.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @param TranslatorInterface $translator   Translator service instance");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @param RequestStack        $requestStack RequestStack service instance");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @param VariableApi");
    {
      Boolean _targets_4 = this._utils.targets(it, "1.5");
      if ((_targets_4).booleanValue()) {
        _builder.append("Interface");
      } else {
        _builder.append("        ");
      }
    }
    _builder.append(" $variableApi  VariableApi service instance");
    _builder.newLineIfNotEmpty();
    _builder.append("     ");
    _builder.append("* @param LocaleApi");
    {
      Boolean _targets_5 = this._utils.targets(it, "1.5");
      if ((_targets_5).booleanValue()) {
        _builder.append("Interface");
      } else {
        _builder.append("         ");
      }
    }
    _builder.append("  $localeApi    LocaleApi service instance");
    _builder.newLineIfNotEmpty();
    _builder.append("     ");
    _builder.append("* @param ");
    String _formatForCodeCapital_2 = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital_2, "     ");
    _builder.append("Factory $entityFactory ");
    String _formatForCodeCapital_3 = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital_3, "     ");
    _builder.append("Factory service instance");
    _builder.newLineIfNotEmpty();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("public function __construct(");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("TranslatorInterface $translator,");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("RequestStack $requestStack,");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("VariableApi");
    {
      Boolean _targets_6 = this._utils.targets(it, "1.5");
      if ((_targets_6).booleanValue()) {
        _builder.append("Interface");
      }
    }
    _builder.append(" $variableApi,");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("LocaleApi");
    {
      Boolean _targets_7 = this._utils.targets(it, "1.5");
      if ((_targets_7).booleanValue()) {
        _builder.append("Interface");
      }
    }
    _builder.append(" $localeApi,");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    String _formatForCodeCapital_4 = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital_4, "        ");
    _builder.append("Factory $entityFactory");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append(") {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$this->translator = $translator;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$this->request = $requestStack->getCurrentRequest();");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$this->variableApi = $variableApi;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$this->localeApi = $localeApi;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$this->entityFactory = $entityFactory;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    CharSequence _translatableFieldsImpl = this.getTranslatableFieldsImpl(it);
    _builder.append(_translatableFieldsImpl, "    ");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    CharSequence _currentLanguage = this.getCurrentLanguage(it);
    _builder.append(_currentLanguage, "    ");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    CharSequence _supportedLanguages = this.getSupportedLanguages(it);
    _builder.append(_supportedLanguages, "    ");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    CharSequence _mandatoryFields = this.getMandatoryFields(it);
    _builder.append(_mandatoryFields, "    ");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    CharSequence _prepareEntityForEditing = this.prepareEntityForEditing(it);
    _builder.append(_prepareEntityForEditing, "    ");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    CharSequence _processEntityAfterEditing = this.processEntityAfterEditing(it);
    _builder.append(_processEntityAfterEditing, "    ");
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
    _builder.append("* These are required to be determined to recognise");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* that they have to be selected from according translation tables.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $objectType The currently treated object type");
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
    _builder.append("$fields = [];");
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
  
  private CharSequence translatableFieldList(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("case \'");
    String _formatForCode = this._formattingExtensions.formatForCode(it.getName());
    _builder.append(_formatForCode);
    _builder.append("\':");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("$fields = [\'");
    final Function1<DerivedField, String> _function = (DerivedField it_1) -> {
      return this._formattingExtensions.formatForCode(it_1.getName());
    };
    String _join = IterableExtensions.join(IterableExtensions.<DerivedField, String>map(this._modelBehaviourExtensions.getTranslatableFields(it), _function), "\', \'");
    _builder.append(_join, "    ");
    _builder.append("\'");
    {
      if ((this._modelBehaviourExtensions.supportsSlugInputFields(it.getApplication()) && this._modelBehaviourExtensions.hasTranslatableSlug(it))) {
        _builder.append(", \'slug\'");
      }
    }
    _builder.append("];");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("break;");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence getCurrentLanguage(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Return the current language code.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return string code of current language");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function getCurrentLanguage()");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $this->request->getLocale();");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence getSupportedLanguages(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Return list of supported languages on the current system.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $objectType The currently treated object type");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return array list of language codes");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function getSupportedLanguages($objectType)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($this->variableApi->getSystemVar(\'multilingual\')) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return $this->localeApi->getSupportedLocales();");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// if multi language is disabled use only the current language");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return [$this->getCurrentLanguage()];");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence getMandatoryFields(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Returns a list of mandatory fields for each supported language.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $objectType The currently treated object type");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return array");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function getMandatoryFields($objectType)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$mandatoryFields = [];");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("foreach ($this->getSupportedLanguages($objectType) as $language) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$mandatoryFields[$language] = [];");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $mandatoryFields;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence prepareEntityForEditing(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Collects translated fields for editing.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param EntityAccess $entity The entity being edited");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return array collected translations having the language codes as keys");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function prepareEntityForEditing($entity)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$translations = [];");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$objectType = $entity->get_objectType();");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($this->variableApi->getSystemVar(\'multilingual\') != 1) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return $translations;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// check if there are any translated fields registered for the given object type");
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
    _builder.append("// get translations");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$repository = $this->entityFactory->getObjectManager()->getRepository(\'Gedmo\\Translatable\\Entity\\Translation\');");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$entityTranslations = $repository->findTranslations($entity);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$supportedLanguages = $this->getSupportedLanguages($objectType);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$currentLanguage = $this->getCurrentLanguage();");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("foreach ($supportedLanguages as $language) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if ($language == $currentLanguage) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("foreach ($fields as $fieldName) {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("if (null === $entity[$fieldName]) {");
    _builder.newLine();
    _builder.append("                    ");
    _builder.append("$entity[$fieldName] = \'\';");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("// skip current language as this is not treated as translation on controller level");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("continue;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$translationData = [];");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("foreach ($fields as $fieldName) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$translationData[$fieldName] = isset($entityTranslations[$language][$fieldName]) ? $entityTranslations[$language][$fieldName] : \'\';");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// add data to collected translations");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$translations[$language] = $translationData;");
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
  
  private CharSequence processEntityAfterEditing(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Post-editing method persisting translated fields.");
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
    _builder.append("* @param EntityAccess  $entity        The entity being edited");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param FormInterface $form          Form containing translations");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param EntityManager $entityManager Entity manager");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function processEntityAfterEditing($entity, $form, $entityManager)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$objectType = $entity->get_objectType();");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$entityTransClass = \'\\\\");
    String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(it.getVendor());
    _builder.append(_formatForCodeCapital, "    ");
    _builder.append("\\\\");
    String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital_1, "    ");
    _builder.append("Module\\\\Entity\\\\\' . ucfirst($objectType) . \'TranslationEntity\';");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("$repository = $entityManager->getRepository($entityTransClass);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$supportedLanguages = $this->getSupportedLanguages($objectType);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("foreach ($supportedLanguages as $language) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if (!isset($form[\'translations\' . $language])) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("continue;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$translatedFields = $form[\'translations\' . $language];");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("foreach ($translatedFields as $fieldName => $formField) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("if (!$formField->getData()) {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("// avoid persisting unrequired translations");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("continue;");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$repository->translate($entity, $fieldName, $language, $formField->getData());");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence translatableFunctionsImpl(final Application it) {
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
    _builder.append("\\Helper\\Base\\AbstractTranslatableHelper;");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Helper implementation class for translatable methods.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("class TranslatableHelper extends AbstractTranslatableHelper");
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
