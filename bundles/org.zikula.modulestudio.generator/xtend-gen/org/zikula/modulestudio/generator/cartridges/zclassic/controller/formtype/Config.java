package org.zikula.modulestudio.generator.cartridges.zclassic.controller.formtype;

import com.google.common.base.Objects;
import com.google.common.collect.Iterables;
import de.guite.modulestudio.metamodel.Application;
import de.guite.modulestudio.metamodel.BoolVar;
import de.guite.modulestudio.metamodel.IntVar;
import de.guite.modulestudio.metamodel.ListVar;
import de.guite.modulestudio.metamodel.ListVarItem;
import de.guite.modulestudio.metamodel.TextVar;
import de.guite.modulestudio.metamodel.Variable;
import de.guite.modulestudio.metamodel.Variables;
import java.util.Arrays;
import org.eclipse.emf.common.util.EList;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper;
import org.zikula.modulestudio.generator.extensions.ControllerExtensions;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class Config {
  @Extension
  private ControllerExtensions _controllerExtensions = new ControllerExtensions();
  
  @Extension
  private FormattingExtensions _formattingExtensions = new FormattingExtensions();
  
  @Extension
  private ModelBehaviourExtensions _modelBehaviourExtensions = new ModelBehaviourExtensions();
  
  @Extension
  private NamingExtensions _namingExtensions = new NamingExtensions();
  
  @Extension
  private Utils _utils = new Utils();
  
  private FileHelper fh = new FileHelper();
  
  private String nsSymfonyFormType = "Symfony\\Component\\Form\\Extension\\Core\\Type\\";
  
  /**
   * Entry point for config form type.
   */
  public void generate(final Application it, final IFileSystemAccess fsa) {
    boolean _needsConfig = this._utils.needsConfig(it);
    boolean _not = (!_needsConfig);
    if (_not) {
      return;
    }
    String _appSourceLibPath = this._namingExtensions.getAppSourceLibPath(it);
    String _plus = (_appSourceLibPath + "Form/AppSettingsType.php");
    this._namingExtensions.generateClassPair(it, fsa, _plus, 
      this.fh.phpFileContent(it, this.configTypeBaseImpl(it)), this.fh.phpFileContent(it, this.configTypeImpl(it)));
  }
  
  private CharSequence configTypeBaseImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("namespace ");
    String _appNamespace = this._utils.appNamespace(it);
    _builder.append(_appNamespace);
    _builder.append("\\Form\\Base;");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("use Symfony\\Component\\Form\\AbstractType;");
    _builder.newLine();
    {
      Boolean _targets = this._utils.targets(it, "1.5");
      if ((_targets).booleanValue()) {
        {
          boolean _hasUserGroupSelectors = this._controllerExtensions.hasUserGroupSelectors(it);
          if (_hasUserGroupSelectors) {
            _builder.append("use Symfony\\Bridge\\Doctrine\\Form\\Type\\EntityType;");
            _builder.newLine();
          }
        }
        {
          boolean _isEmpty = IterableExtensions.isEmpty(Iterables.<BoolVar>filter(this._utils.getAllVariables(it), BoolVar.class));
          boolean _not = (!_isEmpty);
          if (_not) {
            _builder.append("use ");
            _builder.append(this.nsSymfonyFormType);
            _builder.append("CheckboxType;");
            _builder.newLineIfNotEmpty();
          }
        }
        {
          boolean _isEmpty_1 = IterableExtensions.isEmpty(Iterables.<ListVar>filter(this._utils.getAllVariables(it), ListVar.class));
          boolean _not_1 = (!_isEmpty_1);
          if (_not_1) {
            _builder.append("use ");
            _builder.append(this.nsSymfonyFormType);
            _builder.append("ChoiceType;");
            _builder.newLineIfNotEmpty();
          }
        }
        {
          final Function1<IntVar, Boolean> _function = (IntVar it_1) -> {
            boolean _isUserGroupSelector = this._controllerExtensions.isUserGroupSelector(it_1);
            return Boolean.valueOf((!_isUserGroupSelector));
          };
          boolean _isEmpty_2 = IterableExtensions.isEmpty(IterableExtensions.<IntVar>filter(Iterables.<IntVar>filter(this._utils.getAllVariables(it), IntVar.class), _function));
          boolean _not_2 = (!_isEmpty_2);
          if (_not_2) {
            _builder.append("use ");
            _builder.append(this.nsSymfonyFormType);
            _builder.append("IntegerType;");
            _builder.newLineIfNotEmpty();
          }
        }
        {
          final Function1<TextVar, Boolean> _function_1 = (TextVar it_1) -> {
            return Boolean.valueOf(it_1.isMultiline());
          };
          boolean _isEmpty_3 = IterableExtensions.isEmpty(IterableExtensions.<TextVar>filter(Iterables.<TextVar>filter(this._utils.getAllVariables(it), TextVar.class), _function_1));
          boolean _not_3 = (!_isEmpty_3);
          if (_not_3) {
            _builder.append("use ");
            _builder.append(this.nsSymfonyFormType);
            _builder.append("TextareaType;");
            _builder.newLineIfNotEmpty();
          }
        }
        {
          final Function1<TextVar, Boolean> _function_2 = (TextVar it_1) -> {
            boolean _isMultiline = it_1.isMultiline();
            return Boolean.valueOf((!_isMultiline));
          };
          boolean _isEmpty_4 = IterableExtensions.isEmpty(IterableExtensions.<TextVar>filter(Iterables.<TextVar>filter(this._utils.getAllVariables(it), TextVar.class), _function_2));
          boolean _not_4 = (!_isEmpty_4);
          if (_not_4) {
            _builder.append("use ");
            _builder.append(this.nsSymfonyFormType);
            _builder.append("TextType;");
            _builder.newLineIfNotEmpty();
          }
        }
        _builder.append("use ");
        _builder.append(this.nsSymfonyFormType);
        _builder.append("SubmitType;");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("use Symfony\\Component\\Form\\FormBuilderInterface;");
    _builder.newLine();
    _builder.append("use Zikula\\Common\\Translator\\TranslatorInterface;");
    _builder.newLine();
    _builder.append("use Zikula\\Common\\Translator\\TranslatorTrait;");
    _builder.newLine();
    _builder.append("use Zikula\\ExtensionsModule\\Api\\");
    {
      Boolean _targets_1 = this._utils.targets(it, "1.5");
      if ((_targets_1).booleanValue()) {
        _builder.append("ApiInterface\\VariableApiInterface");
      } else {
        _builder.append("VariableApi");
      }
    }
    _builder.append(";");
    _builder.newLineIfNotEmpty();
    {
      boolean _hasUserGroupSelectors_1 = this._controllerExtensions.hasUserGroupSelectors(it);
      if (_hasUserGroupSelectors_1) {
        _builder.append("use Zikula\\GroupsModule\\Entity\\RepositoryInterface\\GroupRepositoryInterface;");
        _builder.newLine();
      }
    }
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Configuration form type base class.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("abstract class AbstractAppSettingsType extends AbstractType");
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
    _builder.append("* @var array");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("protected $modVars;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* AppSettingsType constructor.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*");
    _builder.newLine();
    {
      boolean _hasUserGroupSelectors_2 = this._controllerExtensions.hasUserGroupSelectors(it);
      if (_hasUserGroupSelectors_2) {
        _builder.append("     ");
        _builder.append("* @param TranslatorInterface      $translator      Translator service instance");
        _builder.newLine();
        _builder.append("     ");
        _builder.append("* @param VariableApi");
        {
          Boolean _targets_3 = this._utils.targets(it, "1.5");
          if ((_targets_3).booleanValue()) {
            _builder.append("Interface");
          } else {
            _builder.append("         ");
          }
        }
        _builder.append("     $variableApi     VariableApi service instance");
        _builder.newLineIfNotEmpty();
        _builder.append("     ");
        _builder.append("* @param GroupRepositoryInterface $groupRepository GroupRepository service instance");
        _builder.newLine();
      } else {
        _builder.append("     ");
        _builder.append("* @param TranslatorInterface  $translator  Translator service instance");
        _builder.newLine();
        _builder.append("     ");
        _builder.append("* @param VariableApi");
        {
          Boolean _targets_4 = this._utils.targets(it, "1.5");
          if ((_targets_4).booleanValue()) {
            _builder.append("Interface");
          } else {
            _builder.append("         ");
          }
        }
        _builder.append(" $variableApi VariableApi service instance");
        _builder.newLineIfNotEmpty();
      }
    }
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
    _builder.append("VariableApi");
    {
      Boolean _targets_5 = this._utils.targets(it, "1.5");
      if ((_targets_5).booleanValue()) {
        _builder.append("Interface");
      }
    }
    _builder.append(" $variableApi");
    {
      boolean _hasUserGroupSelectors_3 = this._controllerExtensions.hasUserGroupSelectors(it);
      if (_hasUserGroupSelectors_3) {
        _builder.append(",");
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        _builder.append("GroupRepositoryInterface $groupRepository");
      }
    }
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append(") {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$this->setTranslator($translator);");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$this->variableApi = $variableApi;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$this->modVars = $this->variableApi->getAll(\'");
    String _appName = this._utils.appName(it);
    _builder.append(_appName, "        ");
    _builder.append("\');");
    _builder.newLineIfNotEmpty();
    {
      boolean _hasUserGroupSelectors_4 = this._controllerExtensions.hasUserGroupSelectors(it);
      if (_hasUserGroupSelectors_4) {
        _builder.newLine();
        _builder.append("        ");
        _builder.append("foreach ([\'");
        final Function1<IntVar, String> _function_3 = (IntVar it_1) -> {
          return this._formattingExtensions.formatForCode(it_1.getName());
        };
        String _join = IterableExtensions.join(IterableExtensions.<IntVar, String>map(this._controllerExtensions.getUserGroupSelectors(it), _function_3), "\', \'");
        _builder.append(_join, "        ");
        _builder.append("\'] as $groupFieldName) {");
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("$groupId = intval($this->modVars[$groupFieldName]);");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("if ($groupId < 1) {");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("        ");
        _builder.append("$groupId = 2; // fallback to admin group");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("$this->modVars[$groupFieldName] = $groupRepository->find($groupId);");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("}");
        _builder.newLine();
      }
    }
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
    {
      EList<Variables> _variables = it.getVariables();
      for(final Variables varContainer : _variables) {
        _builder.append("        ");
        _builder.append("$this->add");
        String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(varContainer.getName());
        _builder.append(_formatForCodeCapital, "        ");
        _builder.append("Fields($builder, $options);");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$builder");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("->add(\'save\', ");
    {
      Boolean _targets_6 = this._utils.targets(it, "1.5");
      if ((_targets_6).booleanValue()) {
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
    _builder.append("\'label\' => $this->__(\'Update configuration\'),");
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
      Boolean _targets_7 = this._utils.targets(it, "1.5");
      if ((_targets_7).booleanValue()) {
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
      EList<Variables> _variables_1 = it.getVariables();
      for(final Variables varContainer_1 : _variables_1) {
        _builder.append("    ");
        CharSequence _addFieldsMethod = this.addFieldsMethod(varContainer_1);
        _builder.append(_addFieldsMethod, "    ");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
      }
    }
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
    _builder.append("_appsettings\';");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence addFieldsMethod(final Variables it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Adds fields for ");
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(it.getName());
    _builder.append(_formatForDisplay, " ");
    _builder.append(" fields.");
    _builder.newLineIfNotEmpty();
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
    _builder.append("public function add");
    String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital);
    _builder.append("Fields(FormBuilderInterface $builder, array $options)");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$builder");
    _builder.newLine();
    _builder.append("        ");
    {
      EList<Variable> _vars = it.getVars();
      for(final Variable modvar : _vars) {
        CharSequence _definition = this.definition(modvar);
        _builder.append(_definition, "        ");
      }
    }
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append(";");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence definition(final Variable it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("->add(\'");
    String _formatForCode = this._formattingExtensions.formatForCode(it.getName());
    _builder.append(_formatForCode);
    _builder.append("\', ");
    {
      Boolean _targets = this._utils.targets(it.getContainer().getApplication(), "1.5");
      if ((_targets).booleanValue()) {
        CharSequence _fieldType = this.fieldType(it);
        _builder.append(_fieldType);
        _builder.append("Type::class");
      } else {
        _builder.append("\'");
        CharSequence _fieldType_1 = this.fieldType(it);
        _builder.append(_fieldType_1);
        _builder.append("Type\'");
      }
    }
    _builder.append(", [");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("\'label\' => $this->__(\'");
    String _labelText = this.labelText(it);
    _builder.append(_labelText, "    ");
    _builder.append("\') . \':\',");
    _builder.newLineIfNotEmpty();
    {
      if (((null != it.getDocumentation()) && (!Objects.equal(it.getDocumentation(), "")))) {
        _builder.append("    ");
        _builder.append("\'label_attr\' => [");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("\'class\' => \'tooltips\',");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("\'title\' => $this->__(\'");
        String _replace = it.getDocumentation().replace("\'", "\"");
        _builder.append(_replace, "        ");
        _builder.append("\')");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("],");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("\'help\' => $this->__(\'");
        String _replace_1 = it.getDocumentation().replace("\'", "\"");
        _builder.append(_replace_1, "    ");
        _builder.append("\'),");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      boolean _not = (!((it instanceof IntVar) && this._controllerExtensions.isUserGroupSelector(((IntVar) it))));
      if (_not) {
        _builder.append("    ");
        _builder.append("\'required\' => false,");
        _builder.newLine();
      }
    }
    _builder.append("    ");
    _builder.append("\'data\' => ");
    {
      if ((it instanceof BoolVar)) {
        _builder.append("(bool)(");
      }
    }
    _builder.append("isset($this->modVars[\'");
    String _formatForCode_1 = this._formattingExtensions.formatForCode(it.getName());
    _builder.append(_formatForCode_1, "    ");
    _builder.append("\']) ? $this->modVars[\'");
    String _formatForCode_2 = this._formattingExtensions.formatForCode(it.getName());
    _builder.append(_formatForCode_2, "    ");
    _builder.append("\'] : ");
    {
      if ((it instanceof BoolVar)) {
        String _value = ((BoolVar)it).getValue();
        String _displayBool = this._formattingExtensions.displayBool(Boolean.valueOf(Objects.equal(_value, "true")));
        _builder.append(_displayBool, "    ");
        _builder.append(")");
      } else {
        _builder.append("\'\'");
      }
    }
    _builder.append(",");
    _builder.newLineIfNotEmpty();
    {
      if ((!(it instanceof BoolVar))) {
        {
          boolean _not_1 = (!((it instanceof IntVar) && this._controllerExtensions.isUserGroupSelector(((IntVar) it))));
          if (_not_1) {
            _builder.append("    ");
            _builder.append("\'empty_data\' => ");
            {
              if ((it instanceof IntVar)) {
                _builder.append("intval(\'");
                String _value_1 = ((IntVar)it).getValue();
                _builder.append(_value_1, "    ");
                _builder.append("\')");
              } else {
                _builder.append("\'");
                String _value_2 = it.getValue();
                _builder.append(_value_2, "    ");
                _builder.append("\'");
              }
            }
            _builder.append(",");
            _builder.newLineIfNotEmpty();
          }
        }
      }
    }
    _builder.append("    ");
    _builder.append("\'attr\' => [");
    _builder.newLine();
    _builder.append("        ");
    CharSequence _additionalAttributes = this.additionalAttributes(it);
    _builder.append(_additionalAttributes, "        ");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("\'title\' => $this->__(\'");
    CharSequence _titleAttribute = this.titleAttribute(it);
    _builder.append(_titleAttribute, "        ");
    _builder.append("\')");
    {
      boolean _isShrinkDimensionField = this.isShrinkDimensionField(it);
      if (_isShrinkDimensionField) {
        _builder.append(",");
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        _builder.append("\'class\' => \'shrinkdimension-");
        String _lowerCase = this._formattingExtensions.formatForCode(it.getName()).toLowerCase();
        _builder.append(_lowerCase, "        ");
        _builder.append("\'");
      } else {
        boolean _isShrinkEnableField = this.isShrinkEnableField(it);
        if (_isShrinkEnableField) {
          _builder.append(",");
          _builder.newLineIfNotEmpty();
          _builder.append("        ");
          _builder.append("\'class\' => \'shrink-enabler\'");
        }
      }
    }
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("],");
    CharSequence _additionalOptions = this.additionalOptions(it);
    _builder.append(_additionalOptions, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("])");
    _builder.newLine();
    return _builder;
  }
  
  private String labelText(final Variable it) {
    String _xblockexpression = null;
    {
      boolean _isShrinkEnableField = this.isShrinkEnableField(it);
      if (_isShrinkEnableField) {
        return "Enable shrinking";
      }
      boolean _isShrinkDimensionField = this.isShrinkDimensionField(it);
      if (_isShrinkDimensionField) {
        boolean _startsWith = it.getName().startsWith("shrinkWidth");
        if (_startsWith) {
          return "Shrink width";
        }
        boolean _startsWith_1 = it.getName().startsWith("shrinkHeight");
        if (_startsWith_1) {
          return "Shrink height";
        }
      }
      boolean _isThumbModeField = this.isThumbModeField(it);
      if (_isThumbModeField) {
        return "Thumbnail mode";
      }
      boolean _isThumbDimensionField = this.isThumbDimensionField(it);
      if (_isThumbDimensionField) {
        String suffix = "";
        boolean _endsWith = it.getName().endsWith("View");
        if (_endsWith) {
          suffix = " view";
        } else {
          boolean _endsWith_1 = it.getName().endsWith("Display");
          if (_endsWith_1) {
            suffix = " display";
          } else {
            boolean _endsWith_2 = it.getName().endsWith("Edit");
            if (_endsWith_2) {
              suffix = " edit";
            }
          }
        }
        boolean _startsWith_2 = it.getName().startsWith("thumbnailWidth");
        if (_startsWith_2) {
          return ("Thumbnail width" + suffix);
        }
        boolean _startsWith_3 = it.getName().startsWith("thumbnailHeight");
        if (_startsWith_3) {
          return ("Thumbnail height" + suffix);
        }
      }
      _xblockexpression = this._formattingExtensions.formatForDisplayCapital(it.getName());
    }
    return _xblockexpression;
  }
  
  private CharSequence _fieldType(final Variable it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      Boolean _targets = this._utils.targets(it.getContainer().getApplication(), "1.5");
      boolean _not = (!(_targets).booleanValue());
      if (_not) {
        _builder.append(this.nsSymfonyFormType);
      }
    }
    _builder.append("Text");
    return _builder;
  }
  
  private CharSequence _titleAttribute(final Variable it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("Enter the ");
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(it.getName());
    _builder.append(_formatForDisplay);
    _builder.append(".");
    return _builder;
  }
  
  private CharSequence _additionalAttributes(final Variable it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("\'maxlength\' => 255,");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence _additionalOptions(final Variable it) {
    StringConcatenation _builder = new StringConcatenation();
    return _builder;
  }
  
  private CharSequence _fieldType(final IntVar it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _isUserGroupSelector = this._controllerExtensions.isUserGroupSelector(it);
      if (_isUserGroupSelector) {
        {
          Boolean _targets = this._utils.targets(it.getContainer().getApplication(), "1.5");
          boolean _not = (!(_targets).booleanValue());
          if (_not) {
            _builder.append("Symfony\\Bridge\\Doctrine\\Form\\Type\\");
          }
        }
        _builder.append("Entity");
      } else {
        {
          Boolean _targets_1 = this._utils.targets(it.getContainer().getApplication(), "1.5");
          boolean _not_1 = (!(_targets_1).booleanValue());
          if (_not_1) {
            _builder.append(this.nsSymfonyFormType);
          }
        }
        _builder.append("Integer");
      }
    }
    return _builder;
  }
  
  private CharSequence _titleAttribute(final IntVar it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _isUserGroupSelector = this._controllerExtensions.isUserGroupSelector(it);
      if (_isUserGroupSelector) {
        _builder.append("Choose the ");
        String _formatForDisplay = this._formattingExtensions.formatForDisplay(it.getName());
        _builder.append(_formatForDisplay);
        _builder.append(".");
      } else {
        {
          if ((this.isShrinkDimensionField(it) || this.isThumbDimensionField(it))) {
            _builder.append("Enter the ");
            String _lowerCase = this.labelText(it).toLowerCase();
            _builder.append(_lowerCase);
            _builder.append(".");
          } else {
            _builder.append("Enter the ");
            String _formatForDisplay_1 = this._formattingExtensions.formatForDisplay(it.getName());
            _builder.append(_formatForDisplay_1);
            _builder.append(".");
          }
        }
        _builder.append("\') . \' \' . $this->__(\'Only digits are allowed.");
      }
    }
    return _builder;
  }
  
  private CharSequence _additionalAttributes(final IntVar it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _isUserGroupSelector = this._controllerExtensions.isUserGroupSelector(it);
      if (_isUserGroupSelector) {
        _builder.append("\'maxlength\' => 255,");
        _builder.newLine();
      } else {
        _builder.append("\'maxlength\' => ");
        {
          if ((this.isShrinkDimensionField(it) || this.isThumbDimensionField(it))) {
            _builder.append("4");
          } else {
            _builder.append("255");
          }
        }
        _builder.append(",");
        _builder.newLineIfNotEmpty();
      }
    }
    return _builder;
  }
  
  private CharSequence _additionalOptions(final IntVar it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _isUserGroupSelector = this._controllerExtensions.isUserGroupSelector(it);
      if (_isUserGroupSelector) {
        _builder.append("// Zikula core should provide a form type for this to hide entity details");
        _builder.newLine();
        _builder.append("\'class\' => \'ZikulaGroupsModule:GroupEntity\',");
        _builder.newLine();
        _builder.append("\'choice_label\' => \'name\',");
        _builder.newLine();
        _builder.append("\'choice_value\' => \'gid\'");
        _builder.newLine();
      } else {
        _builder.append("\'scale\' => 0");
        {
          if ((this.isShrinkDimensionField(it) || this.isThumbDimensionField(it))) {
            _builder.append(",");
            _builder.newLineIfNotEmpty();
            _builder.append("\'input_group\' => [\'right\' => $this->__(\'pixels\')]");
          }
        }
        _builder.newLineIfNotEmpty();
      }
    }
    return _builder;
  }
  
  private boolean isShrinkEnableField(final Variable it) {
    return ((it instanceof BoolVar) && it.getName().startsWith("enableShrinkingFor"));
  }
  
  private boolean isShrinkDimensionField(final Variable it) {
    return (it.getName().startsWith("shrinkWidth") || it.getName().startsWith("shrinkHeight"));
  }
  
  private boolean isThumbModeField(final Variable it) {
    return it.getName().startsWith("thumbnailMode");
  }
  
  private boolean isThumbDimensionField(final Variable it) {
    return (it.getName().startsWith("thumbnailWidth") || it.getName().startsWith("thumbnailHeight"));
  }
  
  private CharSequence _fieldType(final TextVar it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      Boolean _targets = this._utils.targets(it.getContainer().getApplication(), "1.5");
      boolean _not = (!(_targets).booleanValue());
      if (_not) {
        _builder.append(this.nsSymfonyFormType);
      }
    }
    _builder.append("Text");
    {
      boolean _isMultiline = it.isMultiline();
      if (_isMultiline) {
        _builder.append("area");
      }
    }
    return _builder;
  }
  
  private CharSequence _additionalAttributes(final TextVar it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      if (((it.getMaxLength() > 0) || (!it.isMultiline()))) {
        _builder.append("\'maxlength\' => ");
        {
          int _maxLength = it.getMaxLength();
          boolean _greaterThan = (_maxLength > 0);
          if (_greaterThan) {
            int _maxLength_1 = it.getMaxLength();
            _builder.append(_maxLength_1);
          } else {
            boolean _isMultiline = it.isMultiline();
            boolean _not = (!_isMultiline);
            if (_not) {
              _builder.append("255");
            }
          }
        }
        _builder.append(",");
        _builder.newLineIfNotEmpty();
      }
    }
    return _builder;
  }
  
  private CharSequence _fieldType(final BoolVar it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      Boolean _targets = this._utils.targets(it.getContainer().getApplication(), "1.5");
      boolean _not = (!(_targets).booleanValue());
      if (_not) {
        _builder.append(this.nsSymfonyFormType);
      }
    }
    _builder.append("Checkbox");
    return _builder;
  }
  
  private CharSequence _titleAttribute(final BoolVar it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("The ");
    {
      boolean _isShrinkEnableField = this.isShrinkEnableField(it);
      if (_isShrinkEnableField) {
        _builder.append("enable shrinking");
      } else {
        String _formatForDisplay = this._formattingExtensions.formatForDisplay(it.getName());
        _builder.append(_formatForDisplay);
      }
    }
    _builder.append(" option.");
    return _builder;
  }
  
  private CharSequence _additionalAttributes(final BoolVar it) {
    StringConcatenation _builder = new StringConcatenation();
    return _builder;
  }
  
  private CharSequence _fieldType(final ListVar it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      Boolean _targets = this._utils.targets(it.getContainer().getApplication(), "1.5");
      boolean _not = (!(_targets).booleanValue());
      if (_not) {
        _builder.append(this.nsSymfonyFormType);
      }
    }
    _builder.append("Choice");
    return _builder;
  }
  
  private CharSequence _titleAttribute(final ListVar it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("Choose the ");
    {
      boolean _isThumbModeField = this.isThumbModeField(it);
      if (_isThumbModeField) {
        _builder.append("thumbnail mode");
      } else {
        String _formatForDisplay = this._formattingExtensions.formatForDisplay(it.getName());
        _builder.append(_formatForDisplay);
      }
    }
    _builder.append(".");
    return _builder;
  }
  
  private CharSequence _additionalAttributes(final ListVar it) {
    StringConcatenation _builder = new StringConcatenation();
    return _builder;
  }
  
  private CharSequence _additionalOptions(final ListVar it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("\'choices\' => [");
    _builder.newLine();
    _builder.append("    ");
    {
      EList<ListVarItem> _items = it.getItems();
      for(final ListVarItem item : _items) {
        CharSequence _itemDefinition = this.itemDefinition(item);
        _builder.append(_itemDefinition, "    ");
        {
          ListVarItem _last = IterableExtensions.<ListVarItem>last(it.getItems());
          boolean _notEquals = (!Objects.equal(item, _last));
          if (_notEquals) {
            _builder.append(",");
          }
        }
      }
    }
    _builder.newLineIfNotEmpty();
    _builder.append("],");
    _builder.newLine();
    _builder.append("\'choices_as_values\' => true,");
    _builder.newLine();
    _builder.append("\'multiple\' => ");
    String _displayBool = this._formattingExtensions.displayBool(Boolean.valueOf(it.isMultiple()));
    _builder.append(_displayBool);
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence itemDefinition(final ListVarItem it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("$this->__(\'");
    String _formatForDisplayCapital = this._formattingExtensions.formatForDisplayCapital(it.getName());
    _builder.append(_formatForDisplayCapital);
    _builder.append("\') => \'");
    String _formatForCode = this._formattingExtensions.formatForCode(it.getName());
    _builder.append(_formatForCode);
    _builder.append("\'");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence configTypeImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("namespace ");
    String _appNamespace = this._utils.appNamespace(it);
    _builder.append(_appNamespace);
    _builder.append("\\Form;");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("use ");
    String _appNamespace_1 = this._utils.appNamespace(it);
    _builder.append(_appNamespace_1);
    _builder.append("\\Form\\Base\\AbstractAppSettingsType;");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Configuration form type implementation class.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("class AppSettingsType extends AbstractAppSettingsType");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// feel free to extend the base form type class here");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence fieldType(final Variable it) {
    if (it instanceof BoolVar) {
      return _fieldType((BoolVar)it);
    } else if (it instanceof IntVar) {
      return _fieldType((IntVar)it);
    } else if (it instanceof ListVar) {
      return _fieldType((ListVar)it);
    } else if (it instanceof TextVar) {
      return _fieldType((TextVar)it);
    } else if (it != null) {
      return _fieldType(it);
    } else {
      throw new IllegalArgumentException("Unhandled parameter types: " +
        Arrays.<Object>asList(it).toString());
    }
  }
  
  private CharSequence titleAttribute(final Variable it) {
    if (it instanceof BoolVar) {
      return _titleAttribute((BoolVar)it);
    } else if (it instanceof IntVar) {
      return _titleAttribute((IntVar)it);
    } else if (it instanceof ListVar) {
      return _titleAttribute((ListVar)it);
    } else if (it != null) {
      return _titleAttribute(it);
    } else {
      throw new IllegalArgumentException("Unhandled parameter types: " +
        Arrays.<Object>asList(it).toString());
    }
  }
  
  private CharSequence additionalAttributes(final Variable it) {
    if (it instanceof BoolVar) {
      return _additionalAttributes((BoolVar)it);
    } else if (it instanceof IntVar) {
      return _additionalAttributes((IntVar)it);
    } else if (it instanceof ListVar) {
      return _additionalAttributes((ListVar)it);
    } else if (it instanceof TextVar) {
      return _additionalAttributes((TextVar)it);
    } else if (it != null) {
      return _additionalAttributes(it);
    } else {
      throw new IllegalArgumentException("Unhandled parameter types: " +
        Arrays.<Object>asList(it).toString());
    }
  }
  
  private CharSequence additionalOptions(final Variable it) {
    if (it instanceof IntVar) {
      return _additionalOptions((IntVar)it);
    } else if (it instanceof ListVar) {
      return _additionalOptions((ListVar)it);
    } else if (it != null) {
      return _additionalOptions(it);
    } else {
      throw new IllegalArgumentException("Unhandled parameter types: " +
        Arrays.<Object>asList(it).toString());
    }
  }
}
