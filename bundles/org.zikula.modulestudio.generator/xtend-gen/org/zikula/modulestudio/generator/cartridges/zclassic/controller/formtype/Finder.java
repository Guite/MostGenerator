package org.zikula.modulestudio.generator.cartridges.zclassic.controller.formtype;

import com.google.common.base.Objects;
import de.guite.modulestudio.metamodel.Application;
import de.guite.modulestudio.metamodel.DerivedField;
import de.guite.modulestudio.metamodel.Entity;
import de.guite.modulestudio.metamodel.EntityField;
import de.guite.modulestudio.metamodel.EntityWorkflowType;
import de.guite.modulestudio.metamodel.UploadField;
import java.util.List;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper;
import org.zikula.modulestudio.generator.extensions.ControllerExtensions;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.GeneratorSettingsExtensions;
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class Finder {
  @Extension
  private ControllerExtensions _controllerExtensions = new ControllerExtensions();
  
  @Extension
  private FormattingExtensions _formattingExtensions = new FormattingExtensions();
  
  @Extension
  private GeneratorSettingsExtensions _generatorSettingsExtensions = new GeneratorSettingsExtensions();
  
  @Extension
  private ModelBehaviourExtensions _modelBehaviourExtensions = new ModelBehaviourExtensions();
  
  @Extension
  private ModelExtensions _modelExtensions = new ModelExtensions();
  
  @Extension
  private NamingExtensions _namingExtensions = new NamingExtensions();
  
  @Extension
  private Utils _utils = new Utils();
  
  private FileHelper fh = new FileHelper();
  
  private Application app;
  
  private String nsSymfonyFormType = "Symfony\\Component\\Form\\Extension\\Core\\Type\\";
  
  /**
   * Entry point for entity finder form type.
   */
  public void generate(final Application it, final IFileSystemAccess fsa) {
    boolean _generateExternalControllerAndFinder = this._generatorSettingsExtensions.generateExternalControllerAndFinder(it);
    boolean _not = (!_generateExternalControllerAndFinder);
    if (_not) {
      return;
    }
    this.app = it;
    final Function1<Entity, Boolean> _function = (Entity it_1) -> {
      return Boolean.valueOf(this._controllerExtensions.hasDisplayAction(it_1));
    };
    Iterable<Entity> _filter = IterableExtensions.<Entity>filter(this._modelExtensions.getAllEntities(it), _function);
    for (final Entity entity : _filter) {
      String _appSourceLibPath = this._namingExtensions.getAppSourceLibPath(it);
      String _plus = (_appSourceLibPath + "Form/Type/Finder/");
      String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(entity.getName());
      String _plus_1 = (_plus + _formatForCodeCapital);
      String _plus_2 = (_plus_1 + "FinderType.php");
      this._namingExtensions.generateClassPair(it, fsa, _plus_2, 
        this.fh.phpFileContent(it, this.finderTypeBaseImpl(entity)), this.fh.phpFileContent(it, this.finderTypeImpl(entity)));
    }
  }
  
  private CharSequence finderTypeBaseImpl(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("namespace ");
    String _appNamespace = this._utils.appNamespace(this.app);
    _builder.append(_appNamespace);
    _builder.append("\\Form\\Type\\Finder\\Base;");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("use Symfony\\Component\\Form\\AbstractType;");
    _builder.newLine();
    {
      Boolean _targets = this._utils.targets(this.app, "1.5");
      if ((_targets).booleanValue()) {
        {
          boolean _hasImageFieldsEntity = this._modelExtensions.hasImageFieldsEntity(it);
          if (_hasImageFieldsEntity) {
            _builder.append("use ");
            _builder.append(this.nsSymfonyFormType);
            _builder.append("CheckboxType;");
            _builder.newLineIfNotEmpty();
          }
        }
        _builder.append("use ");
        _builder.append(this.nsSymfonyFormType);
        _builder.append("ChoiceType;");
        _builder.newLineIfNotEmpty();
        _builder.append("use ");
        _builder.append(this.nsSymfonyFormType);
        _builder.append("HiddenType;");
        _builder.newLineIfNotEmpty();
        _builder.append("use ");
        _builder.append(this.nsSymfonyFormType);
        _builder.append("SearchType;");
        _builder.newLineIfNotEmpty();
        _builder.append("use ");
        _builder.append(this.nsSymfonyFormType);
        _builder.append("SubmitType;");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("use Symfony\\Component\\Form\\FormBuilderInterface;");
    _builder.newLine();
    _builder.append("use Symfony\\Component\\OptionsResolver\\OptionsResolver;");
    _builder.newLine();
    {
      if (((this._utils.targets(this.app, "1.5")).booleanValue() && it.isCategorisable())) {
        _builder.append("use Zikula\\CategoriesModule\\Form\\Type\\CategoriesType;");
        _builder.newLine();
      }
    }
    _builder.append("use Zikula\\Common\\Translator\\TranslatorInterface;");
    _builder.newLine();
    _builder.append("use Zikula\\Common\\Translator\\TranslatorTrait;");
    _builder.newLine();
    {
      boolean _needsFeatureActivationHelper = this._modelBehaviourExtensions.needsFeatureActivationHelper(this.app);
      if (_needsFeatureActivationHelper) {
        _builder.append("use ");
        String _appNamespace_1 = this._utils.appNamespace(this.app);
        _builder.append(_appNamespace_1);
        _builder.append("\\Helper\\FeatureActivationHelper;");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* ");
    String _formatForDisplayCapital = this._formattingExtensions.formatForDisplayCapital(it.getName());
    _builder.append(_formatForDisplayCapital, " ");
    _builder.append(" finder form type base class.");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("abstract class Abstract");
    String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital);
    _builder.append("FinderType extends AbstractType");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("use TranslatorTrait;");
    _builder.newLine();
    {
      boolean _needsFeatureActivationHelper_1 = this._modelBehaviourExtensions.needsFeatureActivationHelper(this.app);
      if (_needsFeatureActivationHelper_1) {
        _builder.newLine();
        _builder.append("    ");
        _builder.append("/**");
        _builder.newLine();
        _builder.append("    ");
        _builder.append(" ");
        _builder.append("* @var FeatureActivationHelper");
        _builder.newLine();
        _builder.append("    ");
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("protected $featureActivationHelper;");
        _builder.newLine();
      }
    }
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* ");
    String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital_1, "     ");
    _builder.append("FinderType constructor.");
    _builder.newLineIfNotEmpty();
    _builder.append("     ");
    _builder.append("*");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @param TranslatorInterface $translator Translator service instance");
    _builder.newLine();
    {
      boolean _needsFeatureActivationHelper_2 = this._modelBehaviourExtensions.needsFeatureActivationHelper(this.app);
      if (_needsFeatureActivationHelper_2) {
        _builder.append("    ");
        _builder.append(" ", "    ");
        _builder.append("* @param FeatureActivationHelper $featureActivationHelper FeatureActivationHelper service instance");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("public function __construct(TranslatorInterface $translator");
    {
      boolean _needsFeatureActivationHelper_3 = this._modelBehaviourExtensions.needsFeatureActivationHelper(this.app);
      if (_needsFeatureActivationHelper_3) {
        _builder.append(", FeatureActivationHelper $featureActivationHelper");
      }
    }
    _builder.append(")");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("{");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$this->setTranslator($translator);");
    _builder.newLine();
    {
      boolean _needsFeatureActivationHelper_4 = this._modelBehaviourExtensions.needsFeatureActivationHelper(this.app);
      if (_needsFeatureActivationHelper_4) {
        _builder.append("        ");
        _builder.append("$this->featureActivationHelper = $featureActivationHelper;");
        _builder.newLine();
      }
    }
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    CharSequence _setTranslatorMethod = this._modelBehaviourExtensions.setTranslatorMethod(this.app);
    _builder.append(_setTranslatorMethod, "    ");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @inheritDoc");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("public function buildForm(FormBuilderInterface $builder, array $options)");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$builder");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("->setMethod(\'GET\')");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("->add(\'objectType\', ");
    {
      Boolean _targets_1 = this._utils.targets(this.app, "1.5");
      if ((_targets_1).booleanValue()) {
        _builder.append("HiddenType::class");
      } else {
        _builder.append("\'");
        _builder.append(this.nsSymfonyFormType, "            ");
        _builder.append("HiddenType\'");
      }
    }
    _builder.append(", [");
    _builder.newLineIfNotEmpty();
    _builder.append("                ");
    _builder.append("\'data\' => $options[\'objectType\']");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("])");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("->add(\'editor\', ");
    {
      Boolean _targets_2 = this._utils.targets(this.app, "1.5");
      if ((_targets_2).booleanValue()) {
        _builder.append("HiddenType::class");
      } else {
        _builder.append("\'");
        _builder.append(this.nsSymfonyFormType, "            ");
        _builder.append("HiddenType\'");
      }
    }
    _builder.append(", [");
    _builder.newLineIfNotEmpty();
    _builder.append("                ");
    _builder.append("\'data\' => $options[\'editorName\']");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("])");
    _builder.newLine();
    _builder.append("        ");
    _builder.append(";");
    _builder.newLine();
    _builder.newLine();
    {
      boolean _isCategorisable = it.isCategorisable();
      if (_isCategorisable) {
        _builder.append("        ");
        _builder.append("if ($this->featureActivationHelper->isEnabled(FeatureActivationHelper::CATEGORIES, $options[\'objectType\'])) {");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("$this->addCategoriesField($builder, $options);");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("}");
        _builder.newLine();
      }
    }
    {
      boolean _hasImageFieldsEntity_1 = this._modelExtensions.hasImageFieldsEntity(it);
      if (_hasImageFieldsEntity_1) {
        _builder.append("        ");
        _builder.append("$this->addImageFields($builder, $options);");
        _builder.newLine();
      }
    }
    _builder.append("        ");
    _builder.append("$this->addPasteAsField($builder, $options);");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$this->addSortingFields($builder, $options);");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$this->addAmountField($builder, $options);");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$this->addSearchField($builder, $options);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$builder");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("->add(\'update\', ");
    {
      Boolean _targets_3 = this._utils.targets(this.app, "1.5");
      if ((_targets_3).booleanValue()) {
        _builder.append("SubmitType::class");
      } else {
        _builder.append("\'");
        _builder.append(this.nsSymfonyFormType, "            ");
        _builder.append("SubmitType\'");
      }
    }
    _builder.append(", [");
    _builder.newLineIfNotEmpty();
    _builder.append("                ");
    _builder.append("\'label\' => $this->__(\'Change selection\'),");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("\'icon\' => \'fa-check\',");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("\'attr\' => [");
    _builder.newLine();
    _builder.append("                    ");
    _builder.append("\'class\' => \'btn btn-success\'");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("]");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("])");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("->add(\'cancel\', ");
    {
      Boolean _targets_4 = this._utils.targets(this.app, "1.5");
      if ((_targets_4).booleanValue()) {
        _builder.append("SubmitType::class");
      } else {
        _builder.append("\'");
        _builder.append(this.nsSymfonyFormType, "            ");
        _builder.append("SubmitType\'");
      }
    }
    _builder.append(", [");
    _builder.newLineIfNotEmpty();
    _builder.append("                ");
    _builder.append("\'label\' => $this->__(\'Cancel\'),");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("\'icon\' => \'fa-times\',");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("\'attr\' => [");
    _builder.newLine();
    _builder.append("                    ");
    _builder.append("\'class\' => \'btn btn-default\',");
    _builder.newLine();
    _builder.append("                    ");
    _builder.append("\'formnovalidate\' => \'formnovalidate\'");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("]");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("])");
    _builder.newLine();
    _builder.append("        ");
    _builder.append(";");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    {
      boolean _isCategorisable_1 = it.isCategorisable();
      if (_isCategorisable_1) {
        _builder.append("    ");
        CharSequence _addCategoriesField = this.addCategoriesField(it);
        _builder.append(_addCategoriesField, "    ");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
      }
    }
    {
      boolean _hasImageFieldsEntity_2 = this._modelExtensions.hasImageFieldsEntity(it);
      if (_hasImageFieldsEntity_2) {
        _builder.append("    ");
        CharSequence _addImageFields = this.addImageFields(it);
        _builder.append(_addImageFields, "    ");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
      }
    }
    _builder.append("    ");
    CharSequence _addPasteAsField = this.addPasteAsField(it);
    _builder.append(_addPasteAsField, "    ");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    CharSequence _addSortingFields = this.addSortingFields(it);
    _builder.append(_addSortingFields, "    ");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    CharSequence _addAmountField = this.addAmountField(it);
    _builder.append(_addAmountField, "    ");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    CharSequence _addSearchField = this.addSearchField(it);
    _builder.append(_addSearchField, "    ");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @inheritDoc");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("public function getBlockPrefix()");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return \'");
    String _formatForDB = this._formattingExtensions.formatForDB(this._utils.appName(this.app));
    _builder.append(_formatForDB, "        ");
    _builder.append("_");
    String _formatForDB_1 = this._formattingExtensions.formatForDB(it.getName());
    _builder.append(_formatForDB_1, "        ");
    _builder.append("finder\';");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @inheritDoc");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("public function configureOptions(OptionsResolver $resolver)");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$resolver");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("->setDefaults([");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("\'objectType\' => \'");
    String _formatForCode = this._formattingExtensions.formatForCode(this._modelExtensions.getLeadingEntity(this.app).getName());
    _builder.append(_formatForCode, "                ");
    _builder.append("\',");
    _builder.newLineIfNotEmpty();
    _builder.append("                ");
    _builder.append("\'editorName\' => \'ckeditor\'");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("])");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("->setRequired([\'objectType\', \'editorName\'])");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("->setAllowedTypes([");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("\'objectType\' => \'string\',");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("\'editorName\' => \'string\'");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("])");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("->setAllowedValues([");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("\'editorName\' => [\'tinymce\', \'ckeditor\']");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("])");
    _builder.newLine();
    _builder.append("        ");
    _builder.append(";");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence addCategoriesField(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Adds a categories field.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param FormBuilderInterface $builder The form builder");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param array                $options The options");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function addCategoriesField(FormBuilderInterface $builder, array $options)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$builder->add(\'categories\', ");
    {
      Boolean _targets = this._utils.targets(this.app, "1.5");
      if ((_targets).booleanValue()) {
        _builder.append("CategoriesType::class");
      } else {
        _builder.append("\'Zikula\\CategoriesModule\\Form\\Type\\CategoriesType\'");
      }
    }
    _builder.append(", [");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("\'label\' => $this->__(\'");
    {
      boolean _isCategorisableMultiSelection = it.isCategorisableMultiSelection();
      if (_isCategorisableMultiSelection) {
        _builder.append("Categories");
      } else {
        _builder.append("Category");
      }
    }
    _builder.append("\') . \':\',");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("\'empty_data\' => ");
    {
      boolean _isCategorisableMultiSelection_1 = it.isCategorisableMultiSelection();
      if (_isCategorisableMultiSelection_1) {
        _builder.append("[]");
      } else {
        _builder.append("null");
      }
    }
    _builder.append(",");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("\'attr\' => [");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("\'class\' => \'category-selector\',");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("\'title\' => $this->__(\'This is an optional filter.\')");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("],");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'help\' => $this->__(\'This is an optional filter.\'),");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'required\' => false,");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'multiple\' => ");
    String _displayBool = this._formattingExtensions.displayBool(Boolean.valueOf(it.isCategorisableMultiSelection()));
    _builder.append(_displayBool, "        ");
    _builder.append(",");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("\'module\' => \'");
    String _appName = this._utils.appName(this.app);
    _builder.append(_appName, "        ");
    _builder.append("\',");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("\'entity\' => ucfirst($options[\'objectType\']) . \'Entity\',");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'entityCategoryClass\' => \'");
    String _appNamespace = this._utils.appNamespace(this.app);
    _builder.append(_appNamespace, "        ");
    _builder.append("\\Entity\\\\\' . ucfirst($options[\'objectType\']) . \'CategoryEntity\'");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("]);");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence addImageFields(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Adds fields for image insertion options.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param FormBuilderInterface $builder The form builder");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param array                $options The options");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function addImageFields(FormBuilderInterface $builder, array $options)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$builder->add(\'onlyImages\', ");
    {
      Boolean _targets = this._utils.targets(this.app, "1.5");
      if ((_targets).booleanValue()) {
        _builder.append("CheckboxType::class");
      } else {
        _builder.append("\'");
        _builder.append(this.nsSymfonyFormType, "    ");
        _builder.append("CheckboxType\'");
      }
    }
    _builder.append(", [");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("\'label\' => $this->__(\'Only images\'),");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'empty_data\' => false,");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'help\' => $this->__(\'Enable this option to insert images\'),");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'required\' => false");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("]);");
    _builder.newLine();
    {
      int _size = IterableExtensions.size(this._modelExtensions.getImageFieldsEntity(it));
      boolean _greaterThan = (_size > 1);
      if (_greaterThan) {
        _builder.append("    ");
        _builder.append("$builder->add(\'imageField\', ");
        {
          Boolean _targets_1 = this._utils.targets(this.app, "1.5");
          if ((_targets_1).booleanValue()) {
            _builder.append("ChoiceType::class");
          } else {
            _builder.append("\'");
            _builder.append(this.nsSymfonyFormType, "    ");
            _builder.append("ChoiceType\'");
          }
        }
        _builder.append(", [");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("\'label\' => $this->__(\'Image field\'),");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("\'empty_data\' => \'");
        String _formatForCode = this._formattingExtensions.formatForCode(IterableExtensions.<UploadField>head(this._modelExtensions.getImageFieldsEntity(it)).getName());
        _builder.append(_formatForCode, "        ");
        _builder.append("\',");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("\'help\' => $this->__(\'You can switch between different image fields\'),");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("\'choices\' => [");
        _builder.newLine();
        {
          Iterable<UploadField> _imageFieldsEntity = this._modelExtensions.getImageFieldsEntity(it);
          for(final UploadField imageField : _imageFieldsEntity) {
            _builder.append("    ");
            _builder.append("        ");
            _builder.append("$this->__(\'");
            String _formatForDisplayCapital = this._formattingExtensions.formatForDisplayCapital(imageField.getName());
            _builder.append(_formatForDisplayCapital, "            ");
            _builder.append("\') => \'");
            String _formatForCode_1 = this._formattingExtensions.formatForCode(imageField.getName());
            _builder.append(_formatForCode_1, "            ");
            _builder.append("\'");
            {
              UploadField _last = IterableExtensions.<UploadField>last(this._modelExtensions.getImageFieldsEntity(it));
              boolean _notEquals = (!Objects.equal(imageField, _last));
              if (_notEquals) {
                _builder.append(",");
              }
            }
            _builder.newLineIfNotEmpty();
          }
        }
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("],");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("\'choices_as_values\' => true,");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("\'multiple\' => false,");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("\'expanded\' => false");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("]);");
        _builder.newLine();
      } else {
        _builder.append("    ");
        _builder.append("$builder->add(\'imageField\', ");
        {
          Boolean _targets_2 = this._utils.targets(this.app, "1.5");
          if ((_targets_2).booleanValue()) {
            _builder.append("HiddenType::class");
          } else {
            _builder.append("\'");
            _builder.append(this.nsSymfonyFormType, "    ");
            _builder.append("HiddenType\'");
          }
        }
        _builder.append(", [");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("\'data\' => \'");
        String _formatForCode_2 = this._formattingExtensions.formatForCode(IterableExtensions.<UploadField>head(this._modelExtensions.getImageFieldsEntity(it)).getName());
        _builder.append(_formatForCode_2, "        ");
        _builder.append("\'");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("]);");
        _builder.newLine();
      }
    }
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence addPasteAsField(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Adds a \"paste as\" field.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param FormBuilderInterface $builder The form builder");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param array                $options The options");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function addPasteAsField(FormBuilderInterface $builder, array $options)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$builder->add(\'pasteAs\', ");
    {
      Boolean _targets = this._utils.targets(this.app, "1.5");
      if ((_targets).booleanValue()) {
        _builder.append("ChoiceType::class");
      } else {
        _builder.append("\'");
        _builder.append(this.nsSymfonyFormType, "    ");
        _builder.append("ChoiceType\'");
      }
    }
    _builder.append(", [");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("\'label\' => $this->__(\'Paste as\') . \':\',");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'empty_data\' => 1,");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'choices\' => [");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$this->__(\'Relative link to the ");
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(it.getName());
    _builder.append(_formatForDisplay, "            ");
    _builder.append("\') => 1,");
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    _builder.append("$this->__(\'Absolute url to the ");
    String _formatForDisplay_1 = this._formattingExtensions.formatForDisplay(it.getName());
    _builder.append(_formatForDisplay_1, "            ");
    _builder.append("\') => 2,");
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    _builder.append("$this->__(\'ID of ");
    String _formatForDisplay_2 = this._formattingExtensions.formatForDisplay(it.getName());
    _builder.append(_formatForDisplay_2, "            ");
    _builder.append("\') => 3");
    {
      boolean _hasImageFieldsEntity = this._modelExtensions.hasImageFieldsEntity(it);
      if (_hasImageFieldsEntity) {
        _builder.append(",");
      }
    }
    _builder.newLineIfNotEmpty();
    {
      boolean _hasImageFieldsEntity_1 = this._modelExtensions.hasImageFieldsEntity(it);
      if (_hasImageFieldsEntity_1) {
        _builder.append("            ");
        _builder.append("$this->__(\'Relative link to the image\') => 6,");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("$this->__(\'Image\') => 7,");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("$this->__(\'Image with relative link to the ");
        String _formatForDisplay_3 = this._formattingExtensions.formatForDisplay(it.getName());
        _builder.append(_formatForDisplay_3, "            ");
        _builder.append("\') => 8,");
        _builder.newLineIfNotEmpty();
        _builder.append("            ");
        _builder.append("$this->__(\'Image with absolute url to the ");
        String _formatForDisplay_4 = this._formattingExtensions.formatForDisplay(it.getName());
        _builder.append(_formatForDisplay_4, "            ");
        _builder.append("\') => 9");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("        ");
    _builder.append("],");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'choices_as_values\' => true,");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'multiple\' => false,");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'expanded\' => false");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("]);");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence addSortingFields(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Adds sorting fields.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param FormBuilderInterface $builder The form builder");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param array                $options The options");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function addSortingFields(FormBuilderInterface $builder, array $options)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$builder");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("->add(\'sort\', ");
    {
      Boolean _targets = this._utils.targets(this.app, "1.5");
      if ((_targets).booleanValue()) {
        _builder.append("ChoiceType::class");
      } else {
        _builder.append("\'");
        _builder.append(this.nsSymfonyFormType, "        ");
        _builder.append("ChoiceType\'");
      }
    }
    _builder.append(", [");
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    _builder.append("\'label\' => $this->__(\'Sort by\') . \':\',");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("\'empty_data\' => \'\',");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("\'choices\' => [");
    _builder.newLine();
    {
      List<EntityField> _sortingFields = this._modelExtensions.getSortingFields(it);
      for(final EntityField field : _sortingFields) {
        {
          if (((!Objects.equal(this._formattingExtensions.formatForCode(field.getName()), "workflowState")) || (!Objects.equal(it.getWorkflow(), EntityWorkflowType.NONE)))) {
            _builder.append("                ");
            _builder.append("$this->__(\'");
            String _formatForDisplayCapital = this._formattingExtensions.formatForDisplayCapital(field.getName());
            _builder.append(_formatForDisplayCapital, "                ");
            _builder.append("\') => \'");
            String _formatForCode = this._formattingExtensions.formatForCode(field.getName());
            _builder.append(_formatForCode, "                ");
            _builder.append("\'");
            {
              if ((it.isStandardFields() || (!Objects.equal(field, IterableExtensions.<DerivedField>last(this._modelExtensions.getDerivedFields(it)))))) {
                _builder.append(",");
              }
            }
            _builder.newLineIfNotEmpty();
          }
        }
      }
    }
    {
      boolean _isStandardFields = it.isStandardFields();
      if (_isStandardFields) {
        _builder.append("                ");
        _builder.append("$this->__(\'Creation date\') => \'createdDate\',");
        _builder.newLine();
        _builder.append("                ");
        _builder.append("$this->__(\'Creator\') => \'createdBy\',");
        _builder.newLine();
        _builder.append("                ");
        _builder.append("$this->__(\'Update date\') => \'updatedDate\',");
        _builder.newLine();
        _builder.append("                ");
        _builder.append("$this->__(\'Updater\') => \'updatedBy\'");
        _builder.newLine();
      }
    }
    _builder.append("            ");
    _builder.append("],");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("\'choices_as_values\' => true,");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("\'multiple\' => false,");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("\'expanded\' => false");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("])");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("->add(\'sortdir\', ");
    {
      Boolean _targets_1 = this._utils.targets(this.app, "1.5");
      if ((_targets_1).booleanValue()) {
        _builder.append("ChoiceType::class");
      } else {
        _builder.append("\'");
        _builder.append(this.nsSymfonyFormType, "        ");
        _builder.append("ChoiceType\'");
      }
    }
    _builder.append(", [");
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    _builder.append("\'label\' => $this->__(\'Sort direction\') . \':\',");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("\'empty_data\' => \'asc\',");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("\'choices\' => [");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("$this->__(\'Ascending\') => \'asc\',");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("$this->__(\'Descending\') => \'desc\'");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("],");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("\'choices_as_values\' => true,");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("\'multiple\' => false,");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("\'expanded\' => false");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("])");
    _builder.newLine();
    _builder.append("    ");
    _builder.append(";");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence addAmountField(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Adds a page size field.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param FormBuilderInterface $builder The form builder");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param array                $options The options");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function addAmountField(FormBuilderInterface $builder, array $options)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$builder->add(\'num\', ");
    {
      Boolean _targets = this._utils.targets(this.app, "1.5");
      if ((_targets).booleanValue()) {
        _builder.append("ChoiceType::class");
      } else {
        _builder.append("\'");
        _builder.append(this.nsSymfonyFormType, "    ");
        _builder.append("ChoiceType\'");
      }
    }
    _builder.append(", [");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("\'label\' => $this->__(\'Page size\') . \':\',");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'empty_data\' => 20,");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'attr\' => [");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("\'class\' => \'text-right\'");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("],");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'choices\' => [");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$this->__(\'5\') => 5,");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$this->__(\'10\') => 10,");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$this->__(\'15\') => 15,");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$this->__(\'20\') => 20,");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$this->__(\'30\') => 30,");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$this->__(\'50\') => 50,");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$this->__(\'100\') => 100");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("],");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'choices_as_values\' => true,");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'multiple\' => false,");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'expanded\' => false");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("]);");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence addSearchField(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Adds a search field.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param FormBuilderInterface $builder The form builder");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param array                $options The options");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function addSearchField(FormBuilderInterface $builder, array $options)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$builder->add(\'q\', ");
    {
      Boolean _targets = this._utils.targets(this.app, "1.5");
      if ((_targets).booleanValue()) {
        _builder.append("SearchType::class");
      } else {
        _builder.append("\'");
        _builder.append(this.nsSymfonyFormType, "    ");
        _builder.append("SearchType\'");
      }
    }
    _builder.append(", [");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("\'label\' => $this->__(\'Search for\') . \':\',");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'required\' => false,");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'attr\' => [");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("\'maxlength\' => 255");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("]");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("]);");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence finderTypeImpl(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("namespace ");
    String _appNamespace = this._utils.appNamespace(this.app);
    _builder.append(_appNamespace);
    _builder.append("\\Form\\Type\\Finder;");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("use ");
    String _appNamespace_1 = this._utils.appNamespace(this.app);
    _builder.append(_appNamespace_1);
    _builder.append("\\Form\\Type\\Finder\\Base\\Abstract");
    String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital);
    _builder.append("FinderType;");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* ");
    String _formatForDisplayCapital = this._formattingExtensions.formatForDisplayCapital(it.getName());
    _builder.append(_formatForDisplayCapital, " ");
    _builder.append(" finder form type implementation class.");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("class ");
    String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital_1);
    _builder.append("FinderType extends Abstract");
    String _formatForCodeCapital_2 = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital_2);
    _builder.append("FinderType");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// feel free to extend the base form type class here");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
}
