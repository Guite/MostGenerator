package org.zikula.modulestudio.generator.cartridges.zclassic.controller.formtype;

import com.google.common.base.Objects;
import com.google.common.collect.Iterables;
import de.guite.modulestudio.metamodel.Application;
import de.guite.modulestudio.metamodel.BooleanField;
import de.guite.modulestudio.metamodel.DataObject;
import de.guite.modulestudio.metamodel.DerivedField;
import de.guite.modulestudio.metamodel.Entity;
import de.guite.modulestudio.metamodel.EntityField;
import de.guite.modulestudio.metamodel.EntityWorkflowType;
import de.guite.modulestudio.metamodel.JoinRelationship;
import de.guite.modulestudio.metamodel.ListField;
import de.guite.modulestudio.metamodel.StringField;
import de.guite.modulestudio.metamodel.UserField;
import java.util.Arrays;
import java.util.List;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper;
import org.zikula.modulestudio.generator.extensions.ControllerExtensions;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class QuickNavigation {
  @Extension
  private ControllerExtensions _controllerExtensions = new ControllerExtensions();
  
  @Extension
  private FormattingExtensions _formattingExtensions = new FormattingExtensions();
  
  @Extension
  private ModelBehaviourExtensions _modelBehaviourExtensions = new ModelBehaviourExtensions();
  
  @Extension
  private ModelExtensions _modelExtensions = new ModelExtensions();
  
  @Extension
  private ModelJoinExtensions _modelJoinExtensions = new ModelJoinExtensions();
  
  @Extension
  private NamingExtensions _namingExtensions = new NamingExtensions();
  
  @Extension
  private Utils _utils = new Utils();
  
  private FileHelper fh = new FileHelper();
  
  private Application app;
  
  private String nsSymfonyFormType = "Symfony\\Component\\Form\\Extension\\Core\\Type\\";
  
  private Iterable<JoinRelationship> incomingRelations;
  
  /**
   * Entry point for quick navigation form type.
   */
  public void generate(final Application it, final IFileSystemAccess fsa) {
    boolean _hasViewActions = this._controllerExtensions.hasViewActions(it);
    boolean _not = (!_hasViewActions);
    if (_not) {
      return;
    }
    this.app = it;
    final Function1<Entity, Boolean> _function = (Entity it_1) -> {
      return Boolean.valueOf(this._controllerExtensions.hasViewAction(it_1));
    };
    Iterable<Entity> _filter = IterableExtensions.<Entity>filter(this._modelExtensions.getAllEntities(it), _function);
    for (final Entity entity : _filter) {
      {
        final Function1<JoinRelationship, Boolean> _function_1 = (JoinRelationship it_1) -> {
          DataObject _source = it_1.getSource();
          return Boolean.valueOf((_source instanceof Entity));
        };
        this.incomingRelations = IterableExtensions.<JoinRelationship>filter(this._modelJoinExtensions.getBidirectionalIncomingJoinRelationsWithOneSource(entity), _function_1);
        String _appSourceLibPath = this._namingExtensions.getAppSourceLibPath(it);
        String _plus = (_appSourceLibPath + "Form/Type/QuickNavigation/");
        String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(entity.getName());
        String _plus_1 = (_plus + _formatForCodeCapital);
        String _plus_2 = (_plus_1 + "QuickNavType.php");
        this._namingExtensions.generateClassPair(it, fsa, _plus_2, 
          this.fh.phpFileContent(it, this.quickNavTypeBaseImpl(entity)), this.fh.phpFileContent(it, this.quickNavTypeImpl(entity)));
      }
    }
  }
  
  private CharSequence quickNavTypeBaseImpl(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("namespace ");
    String _appNamespace = this._utils.appNamespace(this.app);
    _builder.append(_appNamespace);
    _builder.append("\\Form\\Type\\QuickNavigation\\Base;");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    {
      if (((this._utils.targets(this.app, "1.5")).booleanValue() && ((!IterableExtensions.isEmpty(this.incomingRelations)) || (!IterableExtensions.isEmpty(Iterables.<UserField>filter(it.getFields(), UserField.class)))))) {
        _builder.append("use Symfony\\Bridge\\Doctrine\\Form\\Type\\EntityType;");
        _builder.newLine();
      }
    }
    _builder.append("use Symfony\\Component\\Form\\AbstractType;");
    _builder.newLine();
    {
      Boolean _targets = this._utils.targets(this.app, "1.5");
      if ((_targets).booleanValue()) {
        _builder.append("use ");
        _builder.append(this.nsSymfonyFormType);
        _builder.append("ChoiceType;");
        _builder.newLineIfNotEmpty();
        {
          boolean _hasCountryFieldsEntity = this._modelExtensions.hasCountryFieldsEntity(it);
          if (_hasCountryFieldsEntity) {
            _builder.append("use ");
            _builder.append(this.nsSymfonyFormType);
            _builder.append("CountryType;");
            _builder.newLineIfNotEmpty();
          }
        }
        {
          boolean _hasCurrencyFieldsEntity = this._modelExtensions.hasCurrencyFieldsEntity(it);
          if (_hasCurrencyFieldsEntity) {
            _builder.append("use ");
            _builder.append(this.nsSymfonyFormType);
            _builder.append("CurrencyType;");
            _builder.newLineIfNotEmpty();
          }
        }
        _builder.append("use ");
        _builder.append(this.nsSymfonyFormType);
        _builder.append("HiddenType;");
        _builder.newLineIfNotEmpty();
        {
          boolean _hasLanguageFieldsEntity = this._modelExtensions.hasLanguageFieldsEntity(it);
          if (_hasLanguageFieldsEntity) {
            _builder.append("use ");
            _builder.append(this.nsSymfonyFormType);
            _builder.append("LanguageType;");
            _builder.newLineIfNotEmpty();
          }
        }
        {
          boolean _hasAbstractStringFieldsEntity = this._modelExtensions.hasAbstractStringFieldsEntity(it);
          if (_hasAbstractStringFieldsEntity) {
            _builder.append("use ");
            _builder.append(this.nsSymfonyFormType);
            _builder.append("SearchType;");
            _builder.newLineIfNotEmpty();
          }
        }
        _builder.append("use ");
        _builder.append(this.nsSymfonyFormType);
        _builder.append("SubmitType;");
        _builder.newLineIfNotEmpty();
        {
          boolean _hasTimezoneFieldsEntity = this._modelExtensions.hasTimezoneFieldsEntity(it);
          if (_hasTimezoneFieldsEntity) {
            _builder.append("use ");
            _builder.append(this.nsSymfonyFormType);
            _builder.append("TimezoneType;");
            _builder.newLineIfNotEmpty();
          }
        }
      }
    }
    _builder.append("use Symfony\\Component\\Form\\FormBuilderInterface;");
    _builder.newLine();
    {
      boolean _isEmpty = IterableExtensions.isEmpty(this.incomingRelations);
      boolean _not = (!_isEmpty);
      if (_not) {
        _builder.append("use Symfony\\Component\\HttpFoundation\\Request;");
        _builder.newLine();
        _builder.append("use Symfony\\Component\\HttpFoundation\\RequestStack;");
        _builder.newLine();
      }
    }
    {
      if (((this._utils.targets(this.app, "1.5")).booleanValue() && this._modelExtensions.hasLocaleFieldsEntity(it))) {
        _builder.append("use Zikula\\Bundle\\FormExtensionBundle\\Form\\Type\\LocaleType;");
        _builder.newLine();
      }
    }
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
      boolean _hasLocaleFieldsEntity = this._modelExtensions.hasLocaleFieldsEntity(it);
      if (_hasLocaleFieldsEntity) {
        _builder.append("use Zikula\\SettingsModule\\Api\\");
        {
          Boolean _targets_1 = this._utils.targets(this.app, "1.5");
          if ((_targets_1).booleanValue()) {
            _builder.append("ApiInterface\\LocaleApiInterface");
          } else {
            _builder.append("LocaleApi");
          }
        }
        _builder.append(";");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      if (((this._utils.targets(this.app, "1.5")).booleanValue() && (!IterableExtensions.isEmpty(IterableExtensions.<ListField>filter(Iterables.<ListField>filter(it.getFields(), ListField.class), ((Function1<ListField, Boolean>) (ListField it_1) -> {
        return Boolean.valueOf(it_1.isMultiple());
      })))))) {
        _builder.append("use ");
        String _appNamespace_1 = this._utils.appNamespace(this.app);
        _builder.append(_appNamespace_1);
        _builder.append("\\Form\\Type\\Field\\MultiListType;");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      boolean _needsFeatureActivationHelper = this._modelBehaviourExtensions.needsFeatureActivationHelper(this.app);
      if (_needsFeatureActivationHelper) {
        _builder.append("use ");
        String _appNamespace_2 = this._utils.appNamespace(this.app);
        _builder.append(_appNamespace_2);
        _builder.append("\\Helper\\FeatureActivationHelper;");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      boolean _hasListFieldsEntity = this._modelExtensions.hasListFieldsEntity(it);
      if (_hasListFieldsEntity) {
        _builder.append("use ");
        String _appNamespace_3 = this._utils.appNamespace(this.app);
        _builder.append(_appNamespace_3);
        _builder.append("\\Helper\\ListEntriesHelper;");
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
    _builder.append(" quick navigation form type base class.");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("abstract class Abstract");
    String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital);
    _builder.append("QuickNavType extends AbstractType");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("use TranslatorTrait;");
    _builder.newLine();
    {
      boolean _isEmpty_1 = IterableExtensions.isEmpty(this.incomingRelations);
      boolean _not_1 = (!_isEmpty_1);
      if (_not_1) {
        _builder.newLine();
        _builder.append("    ");
        _builder.append("/**");
        _builder.newLine();
        _builder.append("    ");
        _builder.append(" ");
        _builder.append("* @var Request");
        _builder.newLine();
        _builder.append("    ");
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("protected $request;");
        _builder.newLine();
      }
    }
    {
      boolean _hasListFieldsEntity_1 = this._modelExtensions.hasListFieldsEntity(it);
      if (_hasListFieldsEntity_1) {
        _builder.newLine();
        _builder.append("    ");
        _builder.append("/**");
        _builder.newLine();
        _builder.append("    ");
        _builder.append(" ");
        _builder.append("* @var ListEntriesHelper");
        _builder.newLine();
        _builder.append("    ");
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("protected $listHelper;");
        _builder.newLine();
      }
    }
    {
      boolean _hasLocaleFieldsEntity_1 = this._modelExtensions.hasLocaleFieldsEntity(it);
      if (_hasLocaleFieldsEntity_1) {
        _builder.newLine();
        _builder.append("    ");
        _builder.append("/**");
        _builder.newLine();
        _builder.append("    ");
        _builder.append(" ");
        _builder.append("* @var LocaleApi");
        {
          Boolean _targets_2 = this._utils.targets(this.app, "1.5");
          if ((_targets_2).booleanValue()) {
            _builder.append("Interface");
          }
        }
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("protected $localeApi;");
        _builder.newLine();
      }
    }
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
    _builder.append("QuickNavType constructor.");
    _builder.newLineIfNotEmpty();
    _builder.append("     ");
    _builder.append("*");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @param TranslatorInterface $translator   Translator service instance");
    _builder.newLine();
    {
      boolean _isEmpty_2 = IterableExtensions.isEmpty(this.incomingRelations);
      boolean _not_2 = (!_isEmpty_2);
      if (_not_2) {
        _builder.append("    ");
        _builder.append("* @param RequestStack        $requestStack RequestStack service instance");
        _builder.newLine();
      }
    }
    {
      boolean _hasListFieldsEntity_2 = this._modelExtensions.hasListFieldsEntity(it);
      if (_hasListFieldsEntity_2) {
        _builder.append("    ");
        _builder.append(" ", "    ");
        _builder.append("* @param ListEntriesHelper   $listHelper   ListEntriesHelper service instance");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      boolean _hasLocaleFieldsEntity_2 = this._modelExtensions.hasLocaleFieldsEntity(it);
      if (_hasLocaleFieldsEntity_2) {
        _builder.append("    ");
        _builder.append(" ", "    ");
        _builder.append("* @param LocaleApi");
        {
          Boolean _targets_3 = this._utils.targets(this.app, "1.5");
          if ((_targets_3).booleanValue()) {
            _builder.append("Interface");
          } else {
            _builder.append("         ");
          }
        }
        _builder.append("  $localeApi    LocaleApi service instance");
        _builder.newLineIfNotEmpty();
      }
    }
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
    _builder.append("public function __construct(");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("TranslatorInterface $translator");
    {
      boolean _isEmpty_3 = IterableExtensions.isEmpty(this.incomingRelations);
      boolean _not_3 = (!_isEmpty_3);
      if (_not_3) {
        _builder.append(",");
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        _builder.append("RequestStack $requestStack");
      }
    }
    {
      boolean _hasListFieldsEntity_3 = this._modelExtensions.hasListFieldsEntity(it);
      if (_hasListFieldsEntity_3) {
        _builder.append(",");
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        _builder.append("ListEntriesHelper $listHelper");
      }
    }
    {
      boolean _hasLocaleFieldsEntity_3 = this._modelExtensions.hasLocaleFieldsEntity(it);
      if (_hasLocaleFieldsEntity_3) {
        _builder.append(",");
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        _builder.append("LocaleApi");
        {
          Boolean _targets_4 = this._utils.targets(this.app, "1.5");
          if ((_targets_4).booleanValue()) {
            _builder.append("Interface");
          }
        }
        _builder.append(" $localeApi");
      }
    }
    {
      boolean _needsFeatureActivationHelper_3 = this._modelBehaviourExtensions.needsFeatureActivationHelper(this.app);
      if (_needsFeatureActivationHelper_3) {
        _builder.append(",");
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        _builder.append("FeatureActivationHelper $featureActivationHelper");
      }
    }
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append(") {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$this->setTranslator($translator);");
    _builder.newLine();
    {
      boolean _isEmpty_4 = IterableExtensions.isEmpty(this.incomingRelations);
      boolean _not_4 = (!_isEmpty_4);
      if (_not_4) {
        _builder.append("        ");
        _builder.append("$this->request = $requestStack->getCurrentRequest();");
        _builder.newLine();
      }
    }
    {
      boolean _hasListFieldsEntity_4 = this._modelExtensions.hasListFieldsEntity(it);
      if (_hasListFieldsEntity_4) {
        _builder.append("        ");
        _builder.append("$this->listHelper = $listHelper;");
        _builder.newLine();
      }
    }
    {
      boolean _hasLocaleFieldsEntity_4 = this._modelExtensions.hasLocaleFieldsEntity(it);
      if (_hasLocaleFieldsEntity_4) {
        _builder.append("        ");
        _builder.append("$this->localeApi = $localeApi;");
        _builder.newLine();
      }
    }
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
    _builder.append("->add(\'all\', ");
    {
      Boolean _targets_5 = this._utils.targets(this.app, "1.5");
      if ((_targets_5).booleanValue()) {
        _builder.append("HiddenType::class");
      } else {
        _builder.append("\'");
        _builder.append(this.nsSymfonyFormType, "            ");
        _builder.append("HiddenType\'");
      }
    }
    _builder.append(")");
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    _builder.append("->add(\'own\', ");
    {
      Boolean _targets_6 = this._utils.targets(this.app, "1.5");
      if ((_targets_6).booleanValue()) {
        _builder.append("HiddenType::class");
      } else {
        _builder.append("\'");
        _builder.append(this.nsSymfonyFormType, "            ");
        _builder.append("HiddenType\'");
      }
    }
    _builder.append(")");
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    _builder.append("->add(\'tpl\', ");
    {
      Boolean _targets_7 = this._utils.targets(this.app, "1.5");
      if ((_targets_7).booleanValue()) {
        _builder.append("HiddenType::class");
      } else {
        _builder.append("\'");
        _builder.append(this.nsSymfonyFormType, "            ");
        _builder.append("HiddenType\'");
      }
    }
    _builder.append(")");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append(";");
    _builder.newLine();
    _builder.newLine();
    {
      boolean _isCategorisable = it.isCategorisable();
      if (_isCategorisable) {
        _builder.append("        ");
        _builder.append("if ($this->featureActivationHelper->isEnabled(FeatureActivationHelper::CATEGORIES, \'");
        String _formatForCode = this._formattingExtensions.formatForCode(it.getName());
        _builder.append(_formatForCode, "        ");
        _builder.append("\')) {");
        _builder.newLineIfNotEmpty();
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
      boolean _isEmpty_5 = IterableExtensions.isEmpty(this.incomingRelations);
      boolean _not_5 = (!_isEmpty_5);
      if (_not_5) {
        _builder.append("        ");
        _builder.append("$this->addIncomingRelationshipFields($builder, $options);");
        _builder.newLine();
      }
    }
    {
      boolean _hasListFieldsEntity_5 = this._modelExtensions.hasListFieldsEntity(it);
      if (_hasListFieldsEntity_5) {
        _builder.append("        ");
        _builder.append("$this->addListFields($builder, $options);");
        _builder.newLine();
      }
    }
    {
      boolean _hasUserFieldsEntity = this._modelExtensions.hasUserFieldsEntity(it);
      if (_hasUserFieldsEntity) {
        _builder.append("        ");
        _builder.append("$this->addUserFields($builder, $options);");
        _builder.newLine();
      }
    }
    {
      boolean _hasCountryFieldsEntity_1 = this._modelExtensions.hasCountryFieldsEntity(it);
      if (_hasCountryFieldsEntity_1) {
        _builder.append("        ");
        _builder.append("$this->addCountryFields($builder, $options);");
        _builder.newLine();
      }
    }
    {
      boolean _hasLanguageFieldsEntity_1 = this._modelExtensions.hasLanguageFieldsEntity(it);
      if (_hasLanguageFieldsEntity_1) {
        _builder.append("        ");
        _builder.append("$this->addLanguageFields($builder, $options);");
        _builder.newLine();
      }
    }
    {
      boolean _hasLocaleFieldsEntity_5 = this._modelExtensions.hasLocaleFieldsEntity(it);
      if (_hasLocaleFieldsEntity_5) {
        _builder.append("        ");
        _builder.append("$this->addLocaleFields($builder, $options);");
        _builder.newLine();
      }
    }
    {
      boolean _hasCurrencyFieldsEntity_1 = this._modelExtensions.hasCurrencyFieldsEntity(it);
      if (_hasCurrencyFieldsEntity_1) {
        _builder.append("        ");
        _builder.append("$this->addCurrencyFields($builder, $options);");
        _builder.newLine();
      }
    }
    {
      boolean _hasAbstractStringFieldsEntity_1 = this._modelExtensions.hasAbstractStringFieldsEntity(it);
      if (_hasAbstractStringFieldsEntity_1) {
        {
          boolean _hasTimezoneFieldsEntity_1 = this._modelExtensions.hasTimezoneFieldsEntity(it);
          if (_hasTimezoneFieldsEntity_1) {
            _builder.append("        ");
            _builder.append("$this->addTimeZoneFields($builder, $options);");
            _builder.newLine();
          }
        }
        _builder.append("        ");
        _builder.append("$this->addSearchField($builder, $options);");
        _builder.newLine();
      }
    }
    _builder.append("        ");
    _builder.append("$this->addSortingFields($builder, $options);");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$this->addAmountField($builder, $options);");
    _builder.newLine();
    {
      boolean _hasBooleanFieldsEntity = this._modelExtensions.hasBooleanFieldsEntity(it);
      if (_hasBooleanFieldsEntity) {
        _builder.append("        ");
        _builder.append("$this->addBooleanFields($builder, $options);");
        _builder.newLine();
      }
    }
    _builder.append("        ");
    _builder.append("$builder->add(\'updateview\', ");
    {
      Boolean _targets_8 = this._utils.targets(this.app, "1.5");
      if ((_targets_8).booleanValue()) {
        _builder.append("SubmitType::class");
      } else {
        _builder.append("\'");
        _builder.append(this.nsSymfonyFormType, "        ");
        _builder.append("SubmitType\'");
      }
    }
    _builder.append(", [");
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    _builder.append("\'label\' => $this->__(\'OK\'),");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("\'attr\' => [");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("\'class\' => \'btn btn-default btn-sm\'");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("]");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("]);");
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
      boolean _isEmpty_6 = IterableExtensions.isEmpty(this.incomingRelations);
      boolean _not_6 = (!_isEmpty_6);
      if (_not_6) {
        _builder.append("    ");
        CharSequence _addIncomingRelationshipFields = this.addIncomingRelationshipFields(it);
        _builder.append(_addIncomingRelationshipFields, "    ");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
      }
    }
    {
      boolean _hasListFieldsEntity_6 = this._modelExtensions.hasListFieldsEntity(it);
      if (_hasListFieldsEntity_6) {
        _builder.append("    ");
        CharSequence _addListFields = this.addListFields(it);
        _builder.append(_addListFields, "    ");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
      }
    }
    {
      boolean _hasUserFieldsEntity_1 = this._modelExtensions.hasUserFieldsEntity(it);
      if (_hasUserFieldsEntity_1) {
        _builder.append("    ");
        CharSequence _addUserFields = this.addUserFields(it);
        _builder.append(_addUserFields, "    ");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
      }
    }
    {
      boolean _hasCountryFieldsEntity_2 = this._modelExtensions.hasCountryFieldsEntity(it);
      if (_hasCountryFieldsEntity_2) {
        _builder.append("    ");
        CharSequence _addCountryFields = this.addCountryFields(it);
        _builder.append(_addCountryFields, "    ");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
      }
    }
    {
      boolean _hasLanguageFieldsEntity_2 = this._modelExtensions.hasLanguageFieldsEntity(it);
      if (_hasLanguageFieldsEntity_2) {
        _builder.append("    ");
        CharSequence _addLanguageFields = this.addLanguageFields(it);
        _builder.append(_addLanguageFields, "    ");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
      }
    }
    {
      boolean _hasLocaleFieldsEntity_6 = this._modelExtensions.hasLocaleFieldsEntity(it);
      if (_hasLocaleFieldsEntity_6) {
        _builder.append("    ");
        CharSequence _addLocaleFields = this.addLocaleFields(it);
        _builder.append(_addLocaleFields, "    ");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
      }
    }
    {
      boolean _hasCurrencyFieldsEntity_2 = this._modelExtensions.hasCurrencyFieldsEntity(it);
      if (_hasCurrencyFieldsEntity_2) {
        _builder.append("    ");
        CharSequence _addCurrencyFields = this.addCurrencyFields(it);
        _builder.append(_addCurrencyFields, "    ");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
      }
    }
    {
      boolean _hasAbstractStringFieldsEntity_2 = this._modelExtensions.hasAbstractStringFieldsEntity(it);
      if (_hasAbstractStringFieldsEntity_2) {
        {
          boolean _hasTimezoneFieldsEntity_2 = this._modelExtensions.hasTimezoneFieldsEntity(it);
          if (_hasTimezoneFieldsEntity_2) {
            _builder.append("    ");
            CharSequence _addTimezoneFields = this.addTimezoneFields(it);
            _builder.append(_addTimezoneFields, "    ");
            _builder.newLineIfNotEmpty();
            _builder.newLine();
          }
        }
        _builder.append("    ");
        CharSequence _addSearchField = this.addSearchField(it);
        _builder.append(_addSearchField, "    ");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
      }
    }
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
    {
      boolean _hasBooleanFieldsEntity_1 = this._modelExtensions.hasBooleanFieldsEntity(it);
      if (_hasBooleanFieldsEntity_1) {
        _builder.append("    ");
        CharSequence _addBooleanFields = this.addBooleanFields(it);
        _builder.append(_addBooleanFields, "    ");
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
    String _formatForDB = this._formattingExtensions.formatForDB(this._utils.appName(this.app));
    _builder.append(_formatForDB, "        ");
    _builder.append("_");
    String _formatForDB_1 = this._formattingExtensions.formatForDB(it.getName());
    _builder.append(_formatForDB_1, "        ");
    _builder.append("quicknav\';");
    _builder.newLineIfNotEmpty();
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
    _builder.append("$objectType = \'");
    String _formatForCode = this._formattingExtensions.formatForCode(it.getName());
    _builder.append(_formatForCode, "    ");
    _builder.append("\';");
    _builder.newLineIfNotEmpty();
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
    _builder.append("\'),");
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
    _builder.append("\'class\' => \'input-sm category-selector\',");
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
    _builder.append("\'entity\' => ucfirst($objectType) . \'Entity\',");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'entityCategoryClass\' => \'");
    String _appNamespace = this._utils.appNamespace(this.app);
    _builder.append(_appNamespace, "        ");
    _builder.append("\\Entity\\\\\' . ucfirst($objectType) . \'CategoryEntity\'");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("]);");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence addIncomingRelationshipFields(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Adds fields for incoming relationships.");
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
    _builder.append("public function addIncomingRelationshipFields(FormBuilderInterface $builder, array $options)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$mainSearchTerm = \'\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($this->request->query->has(\'q\')) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// remove current search argument from request to avoid filtering related items");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$mainSearchTerm = $this->request->query->get(\'q\');");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$this->request->query->remove(\'q\');");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    {
      for(final JoinRelationship relation : this.incomingRelations) {
        _builder.append("    ");
        CharSequence _fieldImpl = this.fieldImpl(relation);
        _builder.append(_fieldImpl, "    ");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($mainSearchTerm != \'\') {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// readd current search argument");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$this->request->query->set(\'q\', $mainSearchTerm);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence addListFields(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Adds list fields.");
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
    _builder.append("public function addListFields(FormBuilderInterface $builder, array $options)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    {
      Iterable<ListField> _listFieldsEntity = this._modelExtensions.getListFieldsEntity(it);
      for(final ListField field : _listFieldsEntity) {
        _builder.append("    ");
        _builder.append("$listEntries = $this->listHelper->getEntries(\'");
        String _formatForCode = this._formattingExtensions.formatForCode(it.getName());
        _builder.append(_formatForCode, "    ");
        _builder.append("\', \'");
        String _formatForCode_1 = this._formattingExtensions.formatForCode(field.getName());
        _builder.append(_formatForCode_1, "    ");
        _builder.append("\');");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("$choices = [];");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$choiceAttributes = [];");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("foreach ($listEntries as $entry) {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("$choices[$entry[\'text\']] = $entry[\'value\'];");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("$choiceAttributes[$entry[\'text\']] = [\'title\' => $entry[\'title\']];");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
        _builder.append("    ");
        CharSequence _fieldImpl = this.fieldImpl(field);
        _builder.append(_fieldImpl, "    ");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence addUserFields(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Adds user fields.");
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
    _builder.append("public function addUserFields(FormBuilderInterface $builder, array $options)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    {
      Iterable<UserField> _userFieldsEntity = this._modelExtensions.getUserFieldsEntity(it);
      for(final UserField field : _userFieldsEntity) {
        _builder.append("    ");
        CharSequence _fieldImpl = this.fieldImpl(field);
        _builder.append(_fieldImpl, "    ");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence addCountryFields(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Adds country fields.");
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
    _builder.append("public function addCountryFields(FormBuilderInterface $builder, array $options)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    {
      Iterable<StringField> _countryFieldsEntity = this._modelExtensions.getCountryFieldsEntity(it);
      for(final StringField field : _countryFieldsEntity) {
        _builder.append("    ");
        CharSequence _fieldImpl = this.fieldImpl(field);
        _builder.append(_fieldImpl, "    ");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence addLanguageFields(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Adds language fields.");
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
    _builder.append("public function addLanguageFields(FormBuilderInterface $builder, array $options)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    {
      Iterable<StringField> _languageFieldsEntity = this._modelExtensions.getLanguageFieldsEntity(it);
      for(final StringField field : _languageFieldsEntity) {
        _builder.append("    ");
        CharSequence _fieldImpl = this.fieldImpl(field);
        _builder.append(_fieldImpl, "    ");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence addLocaleFields(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Adds locale fields.");
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
    _builder.append("public function addLocaleFields(FormBuilderInterface $builder, array $options)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    {
      Iterable<StringField> _localeFieldsEntity = this._modelExtensions.getLocaleFieldsEntity(it);
      for(final StringField field : _localeFieldsEntity) {
        _builder.append("    ");
        CharSequence _fieldImpl = this.fieldImpl(field);
        _builder.append(_fieldImpl, "    ");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence addCurrencyFields(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Adds currency fields.");
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
    _builder.append("public function addCurrencyFields(FormBuilderInterface $builder, array $options)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    {
      Iterable<StringField> _currencyFieldsEntity = this._modelExtensions.getCurrencyFieldsEntity(it);
      for(final StringField field : _currencyFieldsEntity) {
        _builder.append("    ");
        CharSequence _fieldImpl = this.fieldImpl(field);
        _builder.append(_fieldImpl, "    ");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence addTimezoneFields(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Adds time zone fields.");
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
    _builder.append("public function addTimezoneFields(FormBuilderInterface $builder, array $options)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    {
      Iterable<StringField> _timezoneFieldsEntity = this._modelExtensions.getTimezoneFieldsEntity(it);
      for(final StringField field : _timezoneFieldsEntity) {
        _builder.append("    ");
        CharSequence _fieldImpl = this.fieldImpl(field);
        _builder.append(_fieldImpl, "    ");
        _builder.newLineIfNotEmpty();
      }
    }
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
    _builder.append("\'label\' => $this->__(\'Search\'),");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'attr\' => [");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("\'maxlength\' => 255,");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("\'class\' => \'input-sm\'");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("],");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'required\' => false");
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
    _builder.append("\'label\' => $this->__(\'Sort by\'),");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("\'attr\' => [");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("\'class\' => \'input-sm\'");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("],");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("\'choices\' =>             [");
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
    _builder.append("\'required\' => true,");
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
    _builder.append("\'label\' => $this->__(\'Sort direction\'),");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("\'empty_data\' => \'asc\',");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("\'attr\' => [");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("\'class\' => \'input-sm\'");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("],");
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
    _builder.append("\'required\' => true,");
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
    _builder.append("\'label\' => $this->__(\'Page size\'),");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'empty_data\' => 20,");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'attr\' => [");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("\'class\' => \'input-sm text-right\'");
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
    _builder.append("\'required\' => false,");
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
  
  private CharSequence addBooleanFields(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Adds boolean fields.");
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
    _builder.append("public function addBooleanFields(FormBuilderInterface $builder, array $options)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    {
      Iterable<BooleanField> _booleanFieldsEntity = this._modelExtensions.getBooleanFieldsEntity(it);
      for(final BooleanField field : _booleanFieldsEntity) {
        _builder.append("    ");
        CharSequence _fieldImpl = this.fieldImpl(field);
        _builder.append(_fieldImpl, "    ");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence _fieldImpl(final DerivedField it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("$builder->add(\'");
    String _formatForCode = this._formattingExtensions.formatForCode(it.getName());
    _builder.append(_formatForCode);
    _builder.append("\', ");
    {
      Boolean _targets = this._utils.targets(this.app, "1.5");
      if ((_targets).booleanValue()) {
        {
          if (((it instanceof StringField) && ((StringField) it).isLocale())) {
            _builder.append("Locale");
          } else {
            if (((it instanceof ListField) && ((ListField) it).isMultiple())) {
              _builder.append("MultiList");
            } else {
              if ((it instanceof UserField)) {
                _builder.append("Entity");
              } else {
                CharSequence _fieldType = this.fieldType(it);
                _builder.append(_fieldType);
              }
            }
          }
        }
        _builder.append("Type::class");
      } else {
        _builder.append("\'");
        {
          if (((it instanceof StringField) && ((StringField) it).isLocale())) {
            _builder.append("Zikula\\Bundle\\FormExtensionBundle\\Form\\Type\\Locale");
          } else {
            if (((it instanceof ListField) && ((ListField) it).isMultiple())) {
              String _appNamespace = this._utils.appNamespace(this.app);
              _builder.append(_appNamespace);
              _builder.append("\\Form\\Type\\Field\\MultiList");
            } else {
              if ((it instanceof UserField)) {
                _builder.append("Symfony\\Bridge\\Doctrine\\Form\\Type\\Entity");
              } else {
                _builder.append(this.nsSymfonyFormType);
                CharSequence _fieldType_1 = this.fieldType(it);
                _builder.append(_fieldType_1);
              }
            }
          }
        }
        _builder.append("Type\'");
      }
    }
    _builder.append(", [");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("\'label\' => $this->__(\'");
    {
      String _name = it.getName();
      boolean _equals = Objects.equal(_name, "workflowState");
      if (_equals) {
        _builder.append("State");
      } else {
        String _formatForDisplayCapital = this._formattingExtensions.formatForDisplayCapital(it.getName());
        _builder.append(_formatForDisplayCapital, "    ");
      }
    }
    _builder.append("\'),");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("\'attr\' => [");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'class\' => \'input-sm\'");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("],");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("\'required\' => false,");
    _builder.newLine();
    _builder.append("    ");
    CharSequence _additionalOptions = this.additionalOptions(it);
    _builder.append(_additionalOptions, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("]);");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence _fieldType(final DerivedField it) {
    StringConcatenation _builder = new StringConcatenation();
    return _builder;
  }
  
  private CharSequence _additionalOptions(final DerivedField it) {
    StringConcatenation _builder = new StringConcatenation();
    return _builder;
  }
  
  private CharSequence _fieldType(final StringField it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _isCountry = it.isCountry();
      if (_isCountry) {
        _builder.append("Country");
      } else {
        boolean _isLanguage = it.isLanguage();
        if (_isLanguage) {
          _builder.append("Language");
        } else {
          boolean _isLocale = it.isLocale();
          if (_isLocale) {
            _builder.append("Locale");
          } else {
            boolean _isCurrency = it.isCurrency();
            if (_isCurrency) {
              _builder.append("Currency");
            } else {
              boolean _isTimezone = it.isTimezone();
              if (_isTimezone) {
                _builder.append("Timezone");
              }
            }
          }
        }
      }
    }
    return _builder;
  }
  
  private CharSequence _additionalOptions(final StringField it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      if (((!it.isMandatory()) && ((((it.isCountry() || it.isLanguage()) || it.isLocale()) || it.isCurrency()) || it.isTimezone()))) {
        _builder.append("\'placeholder\' => $this->__(\'All\')");
        {
          boolean _isLocale = it.isLocale();
          if (_isLocale) {
            _builder.append(",");
          }
        }
        _builder.newLineIfNotEmpty();
      }
    }
    {
      boolean _isLocale_1 = it.isLocale();
      if (_isLocale_1) {
        _builder.append("\'choices\' => $this->localeApi->getSupportedLocaleNames(),");
        _builder.newLine();
        _builder.append("\'choices_as_values\' => true");
        _builder.newLine();
      }
    }
    return _builder;
  }
  
  private CharSequence _additionalOptions(final UserField it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("\'placeholder\' => $this->__(\'All\'),");
    _builder.newLine();
    _builder.append("// Zikula core should provide a form type for this to hide entity details");
    _builder.newLine();
    _builder.append("\'class\' => \'Zikula\\UsersModule\\Entity\\UserEntity\',");
    _builder.newLine();
    _builder.append("\'choice_label\' => \'uname\'");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence _fieldType(final ListField it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("Choice");
    return _builder;
  }
  
  private CharSequence _additionalOptions(final ListField it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("\'placeholder\' => $this->__(\'All\'),");
    _builder.newLine();
    _builder.append("\'choices\' => $choices,");
    _builder.newLine();
    _builder.append("\'choices_as_values\' => true,");
    _builder.newLine();
    _builder.append("\'choice_attr\' => $choiceAttributes,");
    _builder.newLine();
    _builder.append("\'multiple\' => ");
    String _displayBool = this._formattingExtensions.displayBool(Boolean.valueOf(it.isMultiple()));
    _builder.append(_displayBool);
    _builder.append(",");
    _builder.newLineIfNotEmpty();
    _builder.append("\'expanded\' => false");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence _fieldType(final BooleanField it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("Choice");
    return _builder;
  }
  
  private CharSequence _additionalOptions(final BooleanField it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("\'placeholder\' => $this->__(\'All\'),");
    _builder.newLine();
    _builder.append("\'choices\' => [");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$this->__(\'No\') => \'no\',");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$this->__(\'Yes\') => \'yes\'");
    _builder.newLine();
    _builder.append("],");
    _builder.newLine();
    _builder.append("\'choices_as_values\' => true");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence _fieldImpl(final JoinRelationship it) {
    StringConcatenation _builder = new StringConcatenation();
    final String sourceAliasName = this._namingExtensions.getRelationAliasName(it, Boolean.valueOf(false));
    _builder.newLineIfNotEmpty();
    _builder.append("$builder->add(\'");
    String _formatForCode = this._formattingExtensions.formatForCode(sourceAliasName);
    _builder.append(_formatForCode);
    _builder.append("\', ");
    {
      Boolean _targets = this._utils.targets(this.app, "1.5");
      if ((_targets).booleanValue()) {
        _builder.append("EntityType::class");
      } else {
        _builder.append("\'Symfony\\Bridge\\Doctrine\\Form\\Type\\EntityType\'");
      }
    }
    _builder.append(", [");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("\'class\' => \'");
    String _appName = this._utils.appName(this.app);
    _builder.append(_appName, "    ");
    _builder.append(":");
    String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(it.getSource().getName());
    _builder.append(_formatForCodeCapital, "    ");
    _builder.append("Entity\',");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("\'choice_label\' => \'getTitleFromDisplayPattern\',");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("\'placeholder\' => $this->__(\'All\'),");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("\'required\' => false,");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("\'label\' => $this->__(\'");
    String _formatForDisplayCapital = this._formattingExtensions.formatForDisplayCapital(sourceAliasName);
    _builder.append(_formatForDisplayCapital, "    ");
    _builder.append("\'),");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("\'attr\' => [");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'class\' => \'input-sm\'");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("]");
    _builder.newLine();
    _builder.append("]);");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence quickNavTypeImpl(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("namespace ");
    String _appNamespace = this._utils.appNamespace(this.app);
    _builder.append(_appNamespace);
    _builder.append("\\Form\\Type\\QuickNavigation;");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("use ");
    String _appNamespace_1 = this._utils.appNamespace(this.app);
    _builder.append(_appNamespace_1);
    _builder.append("\\Form\\Type\\QuickNavigation\\Base\\Abstract");
    String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital);
    _builder.append("QuickNavType;");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* ");
    String _formatForDisplayCapital = this._formattingExtensions.formatForDisplayCapital(it.getName());
    _builder.append(_formatForDisplayCapital, " ");
    _builder.append(" quick navigation form type implementation class.");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("class ");
    String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital_1);
    _builder.append("QuickNavType extends Abstract");
    String _formatForCodeCapital_2 = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital_2);
    _builder.append("QuickNavType");
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
  
  private CharSequence fieldImpl(final EObject it) {
    if (it instanceof DerivedField) {
      return _fieldImpl((DerivedField)it);
    } else if (it instanceof JoinRelationship) {
      return _fieldImpl((JoinRelationship)it);
    } else {
      throw new IllegalArgumentException("Unhandled parameter types: " +
        Arrays.<Object>asList(it).toString());
    }
  }
  
  private CharSequence fieldType(final DerivedField it) {
    if (it instanceof ListField) {
      return _fieldType((ListField)it);
    } else if (it instanceof StringField) {
      return _fieldType((StringField)it);
    } else if (it instanceof BooleanField) {
      return _fieldType((BooleanField)it);
    } else if (it != null) {
      return _fieldType(it);
    } else {
      throw new IllegalArgumentException("Unhandled parameter types: " +
        Arrays.<Object>asList(it).toString());
    }
  }
  
  private CharSequence additionalOptions(final DerivedField it) {
    if (it instanceof ListField) {
      return _additionalOptions((ListField)it);
    } else if (it instanceof StringField) {
      return _additionalOptions((StringField)it);
    } else if (it instanceof UserField) {
      return _additionalOptions((UserField)it);
    } else if (it instanceof BooleanField) {
      return _additionalOptions((BooleanField)it);
    } else if (it != null) {
      return _additionalOptions(it);
    } else {
      throw new IllegalArgumentException("Unhandled parameter types: " +
        Arrays.<Object>asList(it).toString());
    }
  }
}
