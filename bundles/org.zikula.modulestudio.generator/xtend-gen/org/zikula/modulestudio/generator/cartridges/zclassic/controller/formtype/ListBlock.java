package org.zikula.modulestudio.generator.cartridges.zclassic.controller.formtype;

import com.google.common.base.Objects;
import de.guite.modulestudio.metamodel.Application;
import de.guite.modulestudio.metamodel.Entity;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.GeneratorSettingsExtensions;
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class ListBlock {
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
   * Entry point for list block form type.
   */
  public void generate(final Application it, final IFileSystemAccess fsa) {
    boolean _generateListBlock = this._generatorSettingsExtensions.generateListBlock(it);
    boolean _not = (!_generateListBlock);
    if (_not) {
      return;
    }
    this.app = it;
    String _appSourceLibPath = this._namingExtensions.getAppSourceLibPath(it);
    String _plus = (_appSourceLibPath + "Block/Form/Type/ItemListBlockType.php");
    this._namingExtensions.generateClassPair(it, fsa, _plus, 
      this.fh.phpFileContent(it, this.listBlockTypeBaseImpl(it)), this.fh.phpFileContent(it, this.listBlockTypeImpl(it)));
  }
  
  private CharSequence listBlockTypeBaseImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("namespace ");
    String _appNamespace = this._utils.appNamespace(it);
    _builder.append(_appNamespace);
    _builder.append("\\Block\\Form\\Type\\Base;");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("use Symfony\\Component\\Form\\AbstractType;");
    _builder.newLine();
    {
      Boolean _targets = this._utils.targets(it, "1.5");
      if ((_targets).booleanValue()) {
        _builder.append("use ");
        _builder.append(this.nsSymfonyFormType);
        _builder.append("ChoiceType;");
        _builder.newLineIfNotEmpty();
        {
          int _size = IterableExtensions.size(this._modelExtensions.getAllEntities(it));
          boolean _equals = (_size == 1);
          if (_equals) {
            _builder.append("use ");
            _builder.append(this.nsSymfonyFormType);
            _builder.append("HiddenType;");
            _builder.newLineIfNotEmpty();
          }
        }
        _builder.append("use ");
        _builder.append(this.nsSymfonyFormType);
        _builder.append("IntegerType;");
        _builder.newLineIfNotEmpty();
        _builder.append("use ");
        _builder.append(this.nsSymfonyFormType);
        _builder.append("TextType;");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("use Symfony\\Component\\Form\\FormBuilderInterface;");
    _builder.newLine();
    {
      boolean _hasCategorisableEntities = this._modelBehaviourExtensions.hasCategorisableEntities(it);
      if (_hasCategorisableEntities) {
        _builder.append("use Symfony\\Component\\Form\\FormInterface;");
        _builder.newLine();
        _builder.append("use Symfony\\Component\\Form\\FormView;");
        _builder.newLine();
      }
    }
    _builder.append("use Symfony\\Component\\OptionsResolver\\OptionsResolver;");
    _builder.newLine();
    {
      if (((this._utils.targets(it, "1.5")).booleanValue() && this._modelBehaviourExtensions.hasCategorisableEntities(it))) {
        _builder.append("use Zikula\\CategoriesModule\\Form\\Type\\CategoriesType;");
        _builder.newLine();
      }
    }
    _builder.append("use Zikula\\Common\\Translator\\TranslatorInterface;");
    _builder.newLine();
    _builder.append("use Zikula\\Common\\Translator\\TranslatorTrait;");
    _builder.newLine();
    {
      boolean _hasCategorisableEntities_1 = this._modelBehaviourExtensions.hasCategorisableEntities(it);
      if (_hasCategorisableEntities_1) {
        _builder.append("use ");
        String _appNamespace_1 = this._utils.appNamespace(it);
        _builder.append(_appNamespace_1);
        _builder.append("\\Helper\\FeatureActivationHelper;");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* List block form type base class.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("abstract class AbstractItemListBlockType extends AbstractType");
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
    _builder.append("* ItemListBlockType constructor.");
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
    _builder.append("$this->addObjectTypeField($builder, $options);");
    _builder.newLine();
    {
      boolean _hasCategorisableEntities_2 = this._modelBehaviourExtensions.hasCategorisableEntities(it);
      if (_hasCategorisableEntities_2) {
        _builder.append("        ");
        _builder.append("if ($options[\'feature_activation_helper\']->isEnabled(FeatureActivationHelper::CATEGORIES, $options[\'object_type\'])) {");
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
    _builder.append("        ");
    _builder.append("$this->addSortingField($builder, $options);");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$this->addAmountField($builder, $options);");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$this->addTemplateFields($builder, $options);");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$this->addFilterField($builder, $options);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    {
      boolean _hasCategorisableEntities_3 = this._modelBehaviourExtensions.hasCategorisableEntities(it);
      if (_hasCategorisableEntities_3) {
        _builder.newLine();
        _builder.append("    ");
        _builder.append("/**");
        _builder.newLine();
        _builder.append("    ");
        _builder.append(" ");
        _builder.append("* @inheritDoc");
        _builder.newLine();
        _builder.append("    ");
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("public function buildView(FormView $view, FormInterface $form, array $options)");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("{");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("$view->vars[\'isCategorisable\'] = $options[\'is_categorisable\'];");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
      }
    }
    _builder.newLine();
    _builder.append("    ");
    CharSequence _addObjectTypeField = this.addObjectTypeField(it);
    _builder.append(_addObjectTypeField, "    ");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    {
      boolean _hasCategorisableEntities_4 = this._modelBehaviourExtensions.hasCategorisableEntities(it);
      if (_hasCategorisableEntities_4) {
        _builder.append("    ");
        CharSequence _addCategoriesField = this.addCategoriesField(it);
        _builder.append(_addCategoriesField, "    ");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
      }
    }
    _builder.append("    ");
    CharSequence _addSortingField = this.addSortingField(it);
    _builder.append(_addSortingField, "    ");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    CharSequence _addAmountField = this.addAmountField(it);
    _builder.append(_addAmountField, "    ");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    CharSequence _addTemplateFields = this.addTemplateFields(it);
    _builder.append(_addTemplateFields, "    ");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    CharSequence _addFilterField = this.addFilterField(it);
    _builder.append(_addFilterField, "    ");
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
    String _formatForDB = this._formattingExtensions.formatForDB(this._utils.appName(it));
    _builder.append(_formatForDB, "        ");
    _builder.append("_listblock\';");
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
    _builder.append("\'object_type\' => \'");
    String _formatForCode = this._formattingExtensions.formatForCode(this._modelExtensions.getLeadingEntity(it).getName());
    _builder.append(_formatForCode, "                ");
    _builder.append("\'");
    {
      boolean _hasCategorisableEntities_5 = this._modelBehaviourExtensions.hasCategorisableEntities(it);
      if (_hasCategorisableEntities_5) {
        _builder.append(",");
        _builder.newLineIfNotEmpty();
        _builder.append("                ");
        _builder.append("\'is_categorisable\' => false,");
        _builder.newLine();
        _builder.append("                ");
        _builder.append("\'category_helper\' => null,");
        _builder.newLine();
        _builder.append("                ");
        _builder.append("\'feature_activation_helper\' => null");
      }
    }
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    _builder.append("])");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("->setRequired([\'object_type\'])");
    _builder.newLine();
    {
      boolean _hasCategorisableEntities_6 = this._modelBehaviourExtensions.hasCategorisableEntities(it);
      if (_hasCategorisableEntities_6) {
        _builder.append("            ");
        _builder.append("->setOptional([\'is_categorisable\', \'category_helper\', \'feature_activation_helper\'])");
        _builder.newLine();
      }
    }
    _builder.append("            ");
    _builder.append("->setAllowedTypes([");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("\'object_type\' => \'string\'");
    {
      boolean _hasCategorisableEntities_7 = this._modelBehaviourExtensions.hasCategorisableEntities(it);
      if (_hasCategorisableEntities_7) {
        _builder.append(",");
        _builder.newLineIfNotEmpty();
        _builder.append("                ");
        _builder.append("\'is_categorisable\' => \'bool\',");
        _builder.newLine();
        _builder.append("                ");
        _builder.append("\'category_helper\' => \'object\',");
        _builder.newLine();
        _builder.append("                ");
        _builder.append("\'feature_activation_helper\' => \'object\'");
      }
    }
    _builder.newLineIfNotEmpty();
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
  
  private CharSequence addObjectTypeField(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Adds an object type field.");
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
    _builder.append("public function addObjectTypeField(FormBuilderInterface $builder, array $options)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$builder->add(\'objectType\', ");
    {
      Boolean _targets = this._utils.targets(it, "1.5");
      if ((_targets).booleanValue()) {
        {
          int _size = IterableExtensions.size(this._modelExtensions.getAllEntities(it));
          boolean _equals = (_size == 1);
          if (_equals) {
            _builder.append("Hidden");
          } else {
            _builder.append("Choice");
          }
        }
        _builder.append("Type::class");
      } else {
        _builder.append("\'");
        _builder.append(this.nsSymfonyFormType, "    ");
        {
          int _size_1 = IterableExtensions.size(this._modelExtensions.getAllEntities(it));
          boolean _equals_1 = (_size_1 == 1);
          if (_equals_1) {
            _builder.append("Hidden");
          } else {
            _builder.append("Choice");
          }
        }
        _builder.append("Type\'");
      }
    }
    _builder.append(", [");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("\'label\' => $this->__(\'Object type\') . \':\',");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'empty_data\' => \'");
    String _formatForCode = this._formattingExtensions.formatForCode(this._modelExtensions.getLeadingEntity(this.app).getName());
    _builder.append(_formatForCode, "        ");
    _builder.append("\',");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("\'attr\' => [");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("\'title\' => $this->__(\'If you change this please save the block once to reload the parameters below.\')");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("],");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'help\' => $this->__(\'If you change this please save the block once to reload the parameters below.\'),");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'choices\' => [");
    _builder.newLine();
    {
      Iterable<Entity> _allEntities = this._modelExtensions.getAllEntities(it);
      for(final Entity entity : _allEntities) {
        _builder.append("            ");
        _builder.append("$this->__(\'");
        String _formatForDisplayCapital = this._formattingExtensions.formatForDisplayCapital(entity.getNameMultiple());
        _builder.append(_formatForDisplayCapital, "            ");
        _builder.append("\') => \'");
        String _formatForCode_1 = this._formattingExtensions.formatForCode(entity.getName());
        _builder.append(_formatForCode_1, "            ");
        _builder.append("\'");
        {
          Entity _last = IterableExtensions.<Entity>last(this._modelExtensions.getAllEntities(it));
          boolean _notEquals = (!Objects.equal(entity, _last));
          if (_notEquals) {
            _builder.append(",");
          }
        }
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
  
  private CharSequence addCategoriesField(final Application it) {
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
    _builder.append("if (!$options[\'is_categorisable\'] || null === $options[\'category_helper\']) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$hasMultiSelection = $options[\'category_helper\']->hasMultipleSelection($options[\'object_type\']);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$builder->add(\'categories\', ");
    {
      Boolean _targets = this._utils.targets(it, "1.5");
      if ((_targets).booleanValue()) {
        _builder.append("CategoriesType::class");
      } else {
        _builder.append("\'Zikula\\CategoriesModule\\Form\\Type\\CategoriesType\'");
      }
    }
    _builder.append(", [");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("\'label\' => ($hasMultiSelection ? $this->__(\'Categories\') : $this->__(\'Category\')) . \':\',");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'empty_data\' => $hasMultiSelection ? [] : null,");
    _builder.newLine();
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
    _builder.append("\'multiple\' => $hasMultiSelection,");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'module\' => \'");
    String _appName = this._utils.appName(it);
    _builder.append(_appName, "        ");
    _builder.append("\',");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("\'entity\' => ucfirst($options[\'object_type\']) . \'Entity\',");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'entityCategoryClass\' => \'");
    String _appNamespace = this._utils.appNamespace(this.app);
    _builder.append(_appNamespace, "        ");
    _builder.append("\\Entity\\\\\' . ucfirst($options[\'object_type\']) . \'CategoryEntity\'");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("]);");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence addSortingField(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Adds a sorting field.");
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
    _builder.append("public function addSortingField(FormBuilderInterface $builder, array $options)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$builder->add(\'sorting\', ");
    {
      Boolean _targets = this._utils.targets(it, "1.5");
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
    _builder.append("\'label\' => $this->__(\'Sorting\') . \':\',");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'empty_data\' => \'default\',");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'choices\' => [");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$this->__(\'Random\') => \'random\',");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$this->__(\'Newest\') => \'newest\',");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$this->__(\'Default\') => \'default\'");
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
  
  private CharSequence addAmountField(final Application it) {
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
    _builder.append("$builder->add(\'amount\', ");
    {
      Boolean _targets = this._utils.targets(it, "1.5");
      if ((_targets).booleanValue()) {
        _builder.append("IntegerType::class");
      } else {
        _builder.append("\'");
        _builder.append(this.nsSymfonyFormType, "    ");
        _builder.append("IntegerType\'");
      }
    }
    _builder.append(", [");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("\'label\' => $this->__(\'Amount\') . \':\',");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'attr\' => [");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("\'maxlength\' => 2,");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("\'title\' => $this->__(\'The maximum amount of items to be shown.\') . \' \' . $this->__(\'Only digits are allowed.\')");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("],");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'help\' => $this->__(\'The maximum amount of items to be shown.\') . \' \' . $this->__(\'Only digits are allowed.\'),");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'empty_data\' => 5,");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'scale\' => 0");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("]);");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence addTemplateFields(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Adds template fields.");
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
    _builder.append("public function addTemplateFields(FormBuilderInterface $builder, array $options)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$builder");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("->add(\'template\', ");
    {
      Boolean _targets = this._utils.targets(it, "1.5");
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
    _builder.append("\'label\' => $this->__(\'Template\') . \':\',");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("\'empty_data\' => \'itemlist_display.html.twig\',");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("\'choices\' => [");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("$this->__(\'Only item titles\') => \'itemlist_display.html.twig\',");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("$this->__(\'With description\') => \'itemlist_display_description.html.twig\',");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("$this->__(\'Custom template\') => \'custom\'");
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
    _builder.append("        ");
    _builder.append("->add(\'customTemplate\', ");
    {
      Boolean _targets_1 = this._utils.targets(it, "1.5");
      if ((_targets_1).booleanValue()) {
        _builder.append("TextType::class");
      } else {
        _builder.append("\'");
        _builder.append(this.nsSymfonyFormType, "        ");
        _builder.append("TextType\'");
      }
    }
    _builder.append(", [");
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    _builder.append("\'label\' => $this->__(\'Custom template\') . \':\',");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("\'required\' => false,");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("\'attr\' => [");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("\'maxlength\' => 80,");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("\'title\' => $this->__(\'Example\') . \': itemlist_[objectType]_display.html.twig\'");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("],");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("\'help\' => $this->__(\'Example\') . \': <em>itemlist_[objectType]_display.html.twig</em>\'");
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
  
  private CharSequence addFilterField(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Adds a filter field.");
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
    _builder.append("public function addFilterField(FormBuilderInterface $builder, array $options)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$builder->add(\'filter\', ");
    {
      Boolean _targets = this._utils.targets(it, "1.5");
      if ((_targets).booleanValue()) {
        _builder.append("TextType::class");
      } else {
        _builder.append("\'");
        _builder.append(this.nsSymfonyFormType, "    ");
        _builder.append("TextType\'");
      }
    }
    _builder.append(", [");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("\'label\' => $this->__(\'Filter (expert option)\') . \':\',");
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
  
  private CharSequence listBlockTypeImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("namespace ");
    String _appNamespace = this._utils.appNamespace(it);
    _builder.append(_appNamespace);
    _builder.append("\\Block\\Form\\Type;");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("use ");
    String _appNamespace_1 = this._utils.appNamespace(it);
    _builder.append(_appNamespace_1);
    _builder.append("\\Block\\Form\\Type\\Base\\AbstractItemListBlockType;");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* List block form type implementation class.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("class ItemListBlockType extends AbstractItemListBlockType");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// feel free to extend the list block form type class here");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
}
