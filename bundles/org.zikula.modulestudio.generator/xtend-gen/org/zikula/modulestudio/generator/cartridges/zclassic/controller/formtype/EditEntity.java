package org.zikula.modulestudio.generator.cartridges.zclassic.controller.formtype;

import com.google.common.base.Objects;
import com.google.common.collect.Iterables;
import de.guite.modulestudio.metamodel.AbstractDateField;
import de.guite.modulestudio.metamodel.Application;
import de.guite.modulestudio.metamodel.ArrayField;
import de.guite.modulestudio.metamodel.BooleanField;
import de.guite.modulestudio.metamodel.DataObject;
import de.guite.modulestudio.metamodel.DateField;
import de.guite.modulestudio.metamodel.DatetimeField;
import de.guite.modulestudio.metamodel.DecimalField;
import de.guite.modulestudio.metamodel.DerivedField;
import de.guite.modulestudio.metamodel.EmailField;
import de.guite.modulestudio.metamodel.Entity;
import de.guite.modulestudio.metamodel.EntityWorkflowType;
import de.guite.modulestudio.metamodel.FloatField;
import de.guite.modulestudio.metamodel.InheritanceRelationship;
import de.guite.modulestudio.metamodel.IntegerField;
import de.guite.modulestudio.metamodel.JoinRelationship;
import de.guite.modulestudio.metamodel.ListField;
import de.guite.modulestudio.metamodel.ManyToManyRelationship;
import de.guite.modulestudio.metamodel.MappedSuperClass;
import de.guite.modulestudio.metamodel.RelationAutoCompletionUsage;
import de.guite.modulestudio.metamodel.StringField;
import de.guite.modulestudio.metamodel.TextField;
import de.guite.modulestudio.metamodel.TimeField;
import de.guite.modulestudio.metamodel.UploadField;
import de.guite.modulestudio.metamodel.UrlField;
import de.guite.modulestudio.metamodel.UserField;
import java.math.BigInteger;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.CollectionLiterals;
import org.eclipse.xtext.xbase.lib.Conversions;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.eclipse.xtext.xbase.lib.StringExtensions;
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper;
import org.zikula.modulestudio.generator.cartridges.zclassic.view.formcomponents.Validation;
import org.zikula.modulestudio.generator.extensions.ControllerExtensions;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class EditEntity {
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
  
  private Validation validationHelper = new Validation();
  
  private Application app;
  
  private String nsSymfonyFormType = "Symfony\\Component\\Form\\Extension\\Core\\Type\\";
  
  private List<String> extensions = CollectionLiterals.<String>newArrayList();
  
  private Iterable<JoinRelationship> incomingRelations;
  
  private Iterable<JoinRelationship> outgoingRelations;
  
  /**
   * Entry point for entity editing form type.
   */
  public void generate(final DataObject it, final IFileSystemAccess fsa) {
    if (((!(it instanceof MappedSuperClass)) && (!this._controllerExtensions.hasEditAction(((Entity) it))))) {
      return;
    }
    if ((it instanceof Entity)) {
      boolean _hasTranslatableFields = this._modelBehaviourExtensions.hasTranslatableFields(((Entity)it));
      if (_hasTranslatableFields) {
        this.extensions.add("translatable");
      }
      boolean _isAttributable = ((Entity)it).isAttributable();
      if (_isAttributable) {
        this.extensions.add("attributes");
      }
      boolean _isCategorisable = ((Entity)it).isCategorisable();
      if (_isCategorisable) {
        this.extensions.add("categories");
      }
    }
    this.app = it.getApplication();
    final Function1<JoinRelationship, Boolean> _function = (JoinRelationship it_1) -> {
      int _editStageCode = this._controllerExtensions.getEditStageCode(it_1, Boolean.valueOf(true));
      return Boolean.valueOf((_editStageCode > 0));
    };
    this.incomingRelations = IterableExtensions.<JoinRelationship>filter(this._modelJoinExtensions.getEditableJoinRelations(it, Boolean.valueOf(true)), _function);
    final Function1<JoinRelationship, Boolean> _function_1 = (JoinRelationship it_1) -> {
      int _editStageCode = this._controllerExtensions.getEditStageCode(it_1, Boolean.valueOf(false));
      return Boolean.valueOf((_editStageCode > 0));
    };
    this.outgoingRelations = IterableExtensions.<JoinRelationship>filter(this._modelJoinExtensions.getEditableJoinRelations(it, Boolean.valueOf(false)), _function_1);
    String _appSourceLibPath = this._namingExtensions.getAppSourceLibPath(this.app);
    String _plus = (_appSourceLibPath + "Form/Type/");
    String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(it.getName());
    String _plus_1 = (_plus + _formatForCodeCapital);
    String _plus_2 = (_plus_1 + "Type.php");
    this._namingExtensions.generateClassPair(this.app, fsa, _plus_2, 
      this.fh.phpFileContent(this.app, this.editTypeBaseImpl(it)), this.fh.phpFileContent(this.app, this.editTypeImpl(it)));
  }
  
  private CharSequence editTypeBaseImpl(final DataObject it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("namespace ");
    String _appNamespace = this._utils.appNamespace(this.app);
    _builder.append(_appNamespace);
    _builder.append("\\Form\\Type\\Base;");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    {
      if (((!IterableExtensions.isEmpty(this.incomingRelations)) || (!IterableExtensions.isEmpty(this.outgoingRelations)))) {
        _builder.append("use Doctrine\\ORM\\EntityRepository;");
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
        _builder.append("CheckboxType;");
        _builder.newLineIfNotEmpty();
        {
          final Function1<ListField, Boolean> _function = (ListField it_1) -> {
            boolean _isMultiple = it_1.isMultiple();
            return Boolean.valueOf((!_isMultiple));
          };
          boolean _isEmpty = IterableExtensions.isEmpty(IterableExtensions.<ListField>filter(Iterables.<ListField>filter(it.getFields(), ListField.class), _function));
          boolean _not = (!_isEmpty);
          if (_not) {
            _builder.append("use ");
            _builder.append(this.nsSymfonyFormType);
            _builder.append("ChoiceType;");
            _builder.newLineIfNotEmpty();
          }
        }
        {
          final Function1<StringField, Boolean> _function_1 = (StringField it_1) -> {
            return Boolean.valueOf(it_1.isCountry());
          };
          boolean _isEmpty_1 = IterableExtensions.isEmpty(IterableExtensions.<StringField>filter(Iterables.<StringField>filter(it.getFields(), StringField.class), _function_1));
          boolean _not_1 = (!_isEmpty_1);
          if (_not_1) {
            _builder.append("use ");
            _builder.append(this.nsSymfonyFormType);
            _builder.append("CountryType;");
            _builder.newLineIfNotEmpty();
          }
        }
        {
          final Function1<StringField, Boolean> _function_2 = (StringField it_1) -> {
            return Boolean.valueOf(it_1.isCurrency());
          };
          boolean _isEmpty_2 = IterableExtensions.isEmpty(IterableExtensions.<StringField>filter(Iterables.<StringField>filter(it.getFields(), StringField.class), _function_2));
          boolean _not_2 = (!_isEmpty_2);
          if (_not_2) {
            _builder.append("use ");
            _builder.append(this.nsSymfonyFormType);
            _builder.append("CurrencyType;");
            _builder.newLineIfNotEmpty();
          }
        }
        {
          if (((!IterableExtensions.isEmpty(Iterables.<UserField>filter(it.getFields(), UserField.class))) || ((it instanceof Entity) && ((Entity) it).isStandardFields()))) {
            _builder.append("use ");
            _builder.append(this.nsSymfonyFormType);
            _builder.append("DateTimeType;");
            _builder.newLineIfNotEmpty();
          }
        }
        {
          boolean _isEmpty_3 = IterableExtensions.isEmpty(Iterables.<DateField>filter(it.getFields(), DateField.class));
          boolean _not_3 = (!_isEmpty_3);
          if (_not_3) {
            _builder.append("use ");
            _builder.append(this.nsSymfonyFormType);
            _builder.append("DateType;");
            _builder.newLineIfNotEmpty();
          }
        }
        {
          boolean _isEmpty_4 = IterableExtensions.isEmpty(Iterables.<EmailField>filter(it.getFields(), EmailField.class));
          boolean _not_4 = (!_isEmpty_4);
          if (_not_4) {
            _builder.append("use ");
            _builder.append(this.nsSymfonyFormType);
            _builder.append("EmailType;");
            _builder.newLineIfNotEmpty();
          }
        }
        {
          final Function1<IntegerField, Boolean> _function_3 = (IntegerField it_1) -> {
            return Boolean.valueOf(((!it_1.isPercentage()) && (!it_1.isRange())));
          };
          boolean _isEmpty_5 = IterableExtensions.isEmpty(IterableExtensions.<IntegerField>filter(Iterables.<IntegerField>filter(it.getFields(), IntegerField.class), _function_3));
          boolean _not_5 = (!_isEmpty_5);
          if (_not_5) {
            _builder.append("use ");
            _builder.append(this.nsSymfonyFormType);
            _builder.append("IntegerType;");
            _builder.newLineIfNotEmpty();
          }
        }
        {
          final Function1<StringField, Boolean> _function_4 = (StringField it_1) -> {
            return Boolean.valueOf(it_1.isLanguage());
          };
          boolean _isEmpty_6 = IterableExtensions.isEmpty(IterableExtensions.<StringField>filter(Iterables.<StringField>filter(it.getFields(), StringField.class), _function_4));
          boolean _not_6 = (!_isEmpty_6);
          if (_not_6) {
            _builder.append("use ");
            _builder.append(this.nsSymfonyFormType);
            _builder.append("LanguageType;");
            _builder.newLineIfNotEmpty();
          }
        }
        {
          if (((!IterableExtensions.isEmpty(IterableExtensions.<DecimalField>filter(Iterables.<DecimalField>filter(it.getFields(), DecimalField.class), ((Function1<DecimalField, Boolean>) (DecimalField it_1) -> {
            return Boolean.valueOf(it_1.isCurrency());
          })))) || (!IterableExtensions.isEmpty(IterableExtensions.<FloatField>filter(Iterables.<FloatField>filter(it.getFields(), FloatField.class), ((Function1<FloatField, Boolean>) (FloatField it_1) -> {
            return Boolean.valueOf(it_1.isCurrency());
          })))))) {
            _builder.append("use ");
            _builder.append(this.nsSymfonyFormType);
            _builder.append("MoneyType;");
            _builder.newLineIfNotEmpty();
          }
        }
        {
          if (((!IterableExtensions.isEmpty(IterableExtensions.<DecimalField>filter(Iterables.<DecimalField>filter(it.getFields(), DecimalField.class), ((Function1<DecimalField, Boolean>) (DecimalField it_1) -> {
            return Boolean.valueOf(((!it_1.isPercentage()) && (!it_1.isCurrency())));
          })))) || (!IterableExtensions.isEmpty(IterableExtensions.<FloatField>filter(Iterables.<FloatField>filter(it.getFields(), FloatField.class), ((Function1<FloatField, Boolean>) (FloatField it_1) -> {
            return Boolean.valueOf(((!it_1.isPercentage()) && (!it_1.isCurrency())));
          })))))) {
            _builder.append("use ");
            _builder.append(this.nsSymfonyFormType);
            _builder.append("NumberType;");
            _builder.newLineIfNotEmpty();
          }
        }
        {
          final Function1<StringField, Boolean> _function_5 = (StringField it_1) -> {
            return Boolean.valueOf(it_1.isPassword());
          };
          boolean _isEmpty_7 = IterableExtensions.isEmpty(IterableExtensions.<StringField>filter(Iterables.<StringField>filter(it.getFields(), StringField.class), _function_5));
          boolean _not_7 = (!_isEmpty_7);
          if (_not_7) {
            _builder.append("use ");
            _builder.append(this.nsSymfonyFormType);
            _builder.append("PasswordType;");
            _builder.newLineIfNotEmpty();
          }
        }
        {
          if ((((!IterableExtensions.isEmpty(IterableExtensions.<IntegerField>filter(Iterables.<IntegerField>filter(it.getFields(), IntegerField.class), ((Function1<IntegerField, Boolean>) (IntegerField it_1) -> {
            return Boolean.valueOf(it_1.isPercentage());
          })))) || (!IterableExtensions.isEmpty(IterableExtensions.<DecimalField>filter(Iterables.<DecimalField>filter(it.getFields(), DecimalField.class), ((Function1<DecimalField, Boolean>) (DecimalField it_1) -> {
            return Boolean.valueOf(it_1.isPercentage());
          }))))) || (!IterableExtensions.isEmpty(IterableExtensions.<FloatField>filter(Iterables.<FloatField>filter(it.getFields(), FloatField.class), ((Function1<FloatField, Boolean>) (FloatField it_1) -> {
            return Boolean.valueOf(it_1.isPercentage());
          })))))) {
            _builder.append("use ");
            _builder.append(this.nsSymfonyFormType);
            _builder.append("PercentType;");
            _builder.newLineIfNotEmpty();
          }
        }
        {
          final Function1<IntegerField, Boolean> _function_6 = (IntegerField it_1) -> {
            return Boolean.valueOf(it_1.isRange());
          };
          boolean _isEmpty_8 = IterableExtensions.isEmpty(IterableExtensions.<IntegerField>filter(Iterables.<IntegerField>filter(it.getFields(), IntegerField.class), _function_6));
          boolean _not_8 = (!_isEmpty_8);
          if (_not_8) {
            _builder.append("use ");
            _builder.append(this.nsSymfonyFormType);
            _builder.append("RangeType;");
            _builder.newLineIfNotEmpty();
          }
        }
        _builder.append("use ");
        _builder.append(this.nsSymfonyFormType);
        _builder.append("ResetType;");
        _builder.newLineIfNotEmpty();
        _builder.append("use ");
        _builder.append(this.nsSymfonyFormType);
        _builder.append("SubmitType;");
        _builder.newLineIfNotEmpty();
        {
          if (((!IterableExtensions.isEmpty(Iterables.<TextField>filter(it.getFields(), TextField.class))) || ((it instanceof Entity) && (!Objects.equal(((Entity) it).getWorkflow(), EntityWorkflowType.NONE))))) {
            _builder.append("use ");
            _builder.append(this.nsSymfonyFormType);
            _builder.append("TextareaType;");
            _builder.newLineIfNotEmpty();
          }
        }
        {
          if (((this.extensions.contains("attributes") || (!IterableExtensions.isEmpty(IterableExtensions.<StringField>filter(Iterables.<StringField>filter(it.getFields(), StringField.class), ((Function1<StringField, Boolean>) (StringField it_1) -> {
            return Boolean.valueOf((((((((!it_1.isCountry()) && (!it_1.isLanguage())) && (!it_1.isLocale())) && (!it_1.isHtmlcolour())) && (!it_1.isPassword())) && (!it_1.isCurrency())) && (!it_1.isTimezone())));
          }))))) || ((((it instanceof Entity) && this._modelBehaviourExtensions.hasSluggableFields(((Entity) it))) && ((Entity) it).isSlugUpdatable()) && this._modelBehaviourExtensions.supportsSlugInputFields(it.getApplication())))) {
            _builder.append("use ");
            _builder.append(this.nsSymfonyFormType);
            _builder.append("TextType;");
            _builder.newLineIfNotEmpty();
          }
        }
        {
          boolean _isEmpty_9 = IterableExtensions.isEmpty(Iterables.<TimeField>filter(it.getFields(), TimeField.class));
          boolean _not_9 = (!_isEmpty_9);
          if (_not_9) {
            _builder.append("use ");
            _builder.append(this.nsSymfonyFormType);
            _builder.append("TimeType;");
            _builder.newLineIfNotEmpty();
          }
        }
        {
          final Function1<StringField, Boolean> _function_7 = (StringField it_1) -> {
            return Boolean.valueOf(it_1.isTimezone());
          };
          boolean _isEmpty_10 = IterableExtensions.isEmpty(IterableExtensions.<StringField>filter(Iterables.<StringField>filter(it.getFields(), StringField.class), _function_7));
          boolean _not_10 = (!_isEmpty_10);
          if (_not_10) {
            _builder.append("use ");
            _builder.append(this.nsSymfonyFormType);
            _builder.append("TimezoneType;");
            _builder.newLineIfNotEmpty();
          }
        }
        {
          boolean _isEmpty_11 = IterableExtensions.isEmpty(Iterables.<UrlField>filter(it.getFields(), UrlField.class));
          boolean _not_11 = (!_isEmpty_11);
          if (_not_11) {
            _builder.append("use ");
            _builder.append(this.nsSymfonyFormType);
            _builder.append("UrlType;");
            _builder.newLineIfNotEmpty();
          }
        }
      }
    }
    {
      boolean _hasUploadFieldsEntity = this._modelExtensions.hasUploadFieldsEntity(it);
      if (_hasUploadFieldsEntity) {
        _builder.append("use Symfony\\Component\\Form\\FormEvent;");
        _builder.newLine();
        _builder.append("use Symfony\\Component\\Form\\FormEvents;");
        _builder.newLine();
      }
    }
    _builder.append("use Symfony\\Component\\Form\\FormBuilderInterface;");
    _builder.newLine();
    _builder.append("use Symfony\\Component\\Form\\FormInterface;");
    _builder.newLine();
    {
      boolean _hasUploadFieldsEntity_1 = this._modelExtensions.hasUploadFieldsEntity(it);
      if (_hasUploadFieldsEntity_1) {
        _builder.append("use Symfony\\Component\\HttpFoundation\\File\\File;");
        _builder.newLine();
      }
    }
    _builder.append("use Symfony\\Component\\OptionsResolver\\OptionsResolver;");
    _builder.newLine();
    {
      if (((this._utils.targets(this.app, "1.5")).booleanValue() && (!IterableExtensions.isEmpty(IterableExtensions.<StringField>filter(Iterables.<StringField>filter(it.getFields(), StringField.class), ((Function1<StringField, Boolean>) (StringField it_1) -> {
        return Boolean.valueOf(it_1.isLocale());
      })))))) {
        _builder.append("use Zikula\\Bundle\\FormExtensionBundle\\Form\\Type\\LocaleType;");
        _builder.newLine();
      }
    }
    {
      if (((this._utils.targets(this.app, "1.5")).booleanValue() && this.extensions.contains("categories"))) {
        _builder.append("use Zikula\\CategoriesModule\\Form\\Type\\CategoriesType;");
        _builder.newLine();
      }
    }
    _builder.append("use Zikula\\Common\\Translator\\TranslatorInterface;");
    _builder.newLine();
    _builder.append("use Zikula\\Common\\Translator\\TranslatorTrait;");
    _builder.newLine();
    {
      boolean _isTranslatable = this.isTranslatable(it);
      if (_isTranslatable) {
        _builder.append("use Zikula\\ExtensionsModule\\Api\\");
        {
          Boolean _targets_1 = this._utils.targets(this.app, "1.5");
          if ((_targets_1).booleanValue()) {
            _builder.append("ApiInterface\\VariableApiInterface");
          } else {
            _builder.append("VariableApi");
          }
        }
        _builder.append(";");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      boolean _hasLocaleFieldsEntity = this._modelExtensions.hasLocaleFieldsEntity(it);
      if (_hasLocaleFieldsEntity) {
        _builder.append("use Zikula\\SettingsModule\\Api\\");
        {
          Boolean _targets_2 = this._utils.targets(this.app, "1.5");
          if ((_targets_2).booleanValue()) {
            _builder.append("ApiInterface\\LocaleApiInterface");
          } else {
            _builder.append("LocaleApi");
          }
        }
        _builder.append(";");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("use ");
    String _appNamespace_1 = this._utils.appNamespace(this.app);
    _builder.append(_appNamespace_1);
    _builder.append("\\Entity\\Factory\\");
    String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(this.app.getName());
    _builder.append(_formatForCodeCapital);
    _builder.append("Factory;");
    _builder.newLineIfNotEmpty();
    {
      Boolean _targets_3 = this._utils.targets(this.app, "1.5");
      if ((_targets_3).booleanValue()) {
        {
          boolean _isEmpty_12 = IterableExtensions.isEmpty(Iterables.<ArrayField>filter(it.getFields(), ArrayField.class));
          boolean _not_12 = (!_isEmpty_12);
          if (_not_12) {
            _builder.append("use ");
            String _appNamespace_2 = this._utils.appNamespace(this.app);
            _builder.append(_appNamespace_2);
            _builder.append("\\Form\\Type\\Field\\ArrayType;");
            _builder.newLineIfNotEmpty();
          }
        }
        {
          final Function1<StringField, Boolean> _function_8 = (StringField it_1) -> {
            return Boolean.valueOf(it_1.isHtmlcolour());
          };
          boolean _isEmpty_13 = IterableExtensions.isEmpty(IterableExtensions.<StringField>filter(Iterables.<StringField>filter(it.getFields(), StringField.class), _function_8));
          boolean _not_13 = (!_isEmpty_13);
          if (_not_13) {
            _builder.append("use ");
            String _appNamespace_3 = this._utils.appNamespace(this.app);
            _builder.append(_appNamespace_3);
            _builder.append("\\Form\\Type\\Field\\ColourType;");
            _builder.newLineIfNotEmpty();
          }
        }
        {
          if (((it instanceof Entity) && ((Entity) it).isGeographical())) {
            _builder.append("use ");
            String _appNamespace_4 = this._utils.appNamespace(this.app);
            _builder.append(_appNamespace_4);
            _builder.append("\\Form\\Type\\Field\\GeoType;");
            _builder.newLineIfNotEmpty();
          }
        }
        {
          final Function1<ListField, Boolean> _function_9 = (ListField it_1) -> {
            return Boolean.valueOf(it_1.isMultiple());
          };
          boolean _isEmpty_14 = IterableExtensions.isEmpty(IterableExtensions.<ListField>filter(Iterables.<ListField>filter(it.getFields(), ListField.class), _function_9));
          boolean _not_14 = (!_isEmpty_14);
          if (_not_14) {
            _builder.append("use ");
            String _appNamespace_5 = this._utils.appNamespace(this.app);
            _builder.append(_appNamespace_5);
            _builder.append("\\Form\\Type\\Field\\MultiListType;");
            _builder.newLineIfNotEmpty();
          }
        }
        {
          if (((it instanceof Entity) && this.isTranslatable(it))) {
            _builder.append("use ");
            String _appNamespace_6 = this._utils.appNamespace(this.app);
            _builder.append(_appNamespace_6);
            _builder.append("\\Form\\Type\\Field\\TranslationType;");
            _builder.newLineIfNotEmpty();
          }
        }
        {
          boolean _isEmpty_15 = IterableExtensions.isEmpty(Iterables.<UploadField>filter(it.getFields(), UploadField.class));
          boolean _not_15 = (!_isEmpty_15);
          if (_not_15) {
            _builder.append("use ");
            String _appNamespace_7 = this._utils.appNamespace(this.app);
            _builder.append(_appNamespace_7);
            _builder.append("\\Form\\Type\\Field\\UploadType;");
            _builder.newLineIfNotEmpty();
          }
        }
        {
          if (((!IterableExtensions.isEmpty(Iterables.<UserField>filter(it.getFields(), UserField.class))) || ((it instanceof Entity) && ((Entity) it).isStandardFields()))) {
            _builder.append("use ");
            String _appNamespace_8 = this._utils.appNamespace(this.app);
            _builder.append(_appNamespace_8);
            _builder.append("\\Form\\Type\\Field\\UserType;");
            _builder.newLineIfNotEmpty();
          }
        }
        {
          boolean _isEmpty_16 = this._modelExtensions.getParentDataObjects(it, Collections.<DataObject>unmodifiableList(CollectionLiterals.<DataObject>newArrayList())).isEmpty();
          boolean _not_16 = (!_isEmpty_16);
          if (_not_16) {
            _builder.append("use ");
            String _appNamespace_9 = this._utils.appNamespace(this.app);
            _builder.append(_appNamespace_9);
            _builder.append("\\Form\\Type\\");
            String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(IterableExtensions.<DataObject>head(this._modelExtensions.getParentDataObjects(it, Collections.<DataObject>unmodifiableList(CollectionLiterals.<DataObject>newArrayList()))).getName());
            _builder.append(_formatForCodeCapital_1);
            _builder.append("Type;");
            _builder.newLineIfNotEmpty();
          }
        }
      }
    }
    {
      boolean _needsFeatureActivationHelper = this._modelBehaviourExtensions.needsFeatureActivationHelper(this.app);
      if (_needsFeatureActivationHelper) {
        _builder.append("use ");
        String _appNamespace_10 = this._utils.appNamespace(this.app);
        _builder.append(_appNamespace_10);
        _builder.append("\\Helper\\FeatureActivationHelper;");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      boolean _hasListFieldsEntity = this._modelExtensions.hasListFieldsEntity(it);
      if (_hasListFieldsEntity) {
        _builder.append("use ");
        String _appNamespace_11 = this._utils.appNamespace(this.app);
        _builder.append(_appNamespace_11);
        _builder.append("\\Helper\\ListEntriesHelper;");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      boolean _isTranslatable_1 = this.isTranslatable(it);
      if (_isTranslatable_1) {
        _builder.append("use ");
        String _appNamespace_12 = this._utils.appNamespace(this.app);
        _builder.append(_appNamespace_12);
        _builder.append("\\Helper\\TranslatableHelper;");
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
    _builder.append(" editing form type base class.");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("abstract class Abstract");
    String _formatForCodeCapital_2 = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital_2);
    _builder.append("Type extends AbstractType");
    _builder.newLineIfNotEmpty();
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
    _builder.append("* @var ");
    String _formatForCodeCapital_3 = this._formattingExtensions.formatForCodeCapital(this.app.getName());
    _builder.append(_formatForCodeCapital_3, "     ");
    _builder.append("Factory");
    _builder.newLineIfNotEmpty();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("protected $entityFactory;");
    _builder.newLine();
    {
      boolean _isTranslatable_2 = this.isTranslatable(it);
      if (_isTranslatable_2) {
        _builder.newLine();
        _builder.append("    ");
        _builder.append("/**");
        _builder.newLine();
        _builder.append("    ");
        _builder.append(" ");
        _builder.append("* @var VariableApi");
        {
          Boolean _targets_4 = this._utils.targets(this.app, "1.5");
          if ((_targets_4).booleanValue()) {
            _builder.append("Interface");
          }
        }
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("protected $variableApi;");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("/**");
        _builder.newLine();
        _builder.append("    ");
        _builder.append(" ");
        _builder.append("* @var TranslatableHelper");
        _builder.newLine();
        _builder.append("    ");
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("protected $translatableHelper;");
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
          Boolean _targets_5 = this._utils.targets(this.app, "1.5");
          if ((_targets_5).booleanValue()) {
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
    String _formatForCodeCapital_4 = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital_4, "     ");
    _builder.append("Type constructor.");
    _builder.newLineIfNotEmpty();
    _builder.append("     ");
    _builder.append("*");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @param TranslatorInterface $translator ");
    {
      boolean _isTranslatable_3 = this.isTranslatable(it);
      if (_isTranslatable_3) {
        _builder.append(" ");
      }
    }
    _builder.append("   Translator service instance");
    _builder.newLineIfNotEmpty();
    _builder.append("     ");
    _builder.append("* @param ");
    String _formatForCodeCapital_5 = this._formattingExtensions.formatForCodeCapital(this.app.getName());
    _builder.append(_formatForCodeCapital_5, "     ");
    _builder.append("Factory        $entityFactory Entity factory service instance");
    _builder.newLineIfNotEmpty();
    {
      boolean _isTranslatable_4 = this.isTranslatable(it);
      if (_isTranslatable_4) {
        _builder.append("     ");
        _builder.append("* @param VariableApi");
        {
          Boolean _targets_6 = this._utils.targets(this.app, "1.5");
          if ((_targets_6).booleanValue()) {
            _builder.append("Interface");
          } else {
            _builder.append("        ");
          }
        }
        _builder.append(" $variableApi VariableApi service instance");
        _builder.newLineIfNotEmpty();
        _builder.append("     ");
        _builder.append("* @param TranslatableHelper  $translatableHelper TranslatableHelper service instance");
        _builder.newLine();
      }
    }
    {
      boolean _hasListFieldsEntity_2 = this._modelExtensions.hasListFieldsEntity(it);
      if (_hasListFieldsEntity_2) {
        _builder.append("     ");
        _builder.append("* @param ListEntriesHelper   $listHelper    ");
        {
          boolean _isTranslatable_5 = this.isTranslatable(it);
          if (_isTranslatable_5) {
            _builder.append(" ");
          }
        }
        _builder.append("ListEntriesHelper service instance");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      boolean _hasLocaleFieldsEntity_2 = this._modelExtensions.hasLocaleFieldsEntity(it);
      if (_hasLocaleFieldsEntity_2) {
        _builder.append("     ");
        _builder.append("* @param LocaleApi");
        {
          Boolean _targets_7 = this._utils.targets(this.app, "1.5");
          if ((_targets_7).booleanValue()) {
            _builder.append("Interface");
          } else {
            _builder.append("         ");
          }
        }
        _builder.append("   $localeApi     ");
        {
          boolean _isTranslatable_6 = this.isTranslatable(it);
          if (_isTranslatable_6) {
            _builder.append(" ");
          }
        }
        _builder.append("LocaleApi service instance");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      boolean _needsFeatureActivationHelper_2 = this._modelBehaviourExtensions.needsFeatureActivationHelper(this.app);
      if (_needsFeatureActivationHelper_2) {
        _builder.append("     ");
        _builder.append("* @param FeatureActivationHelper $featureActivationHelper FeatureActivationHelper service instance");
        _builder.newLine();
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
    String _formatForCodeCapital_6 = this._formattingExtensions.formatForCodeCapital(this.app.getName());
    _builder.append(_formatForCodeCapital_6, "        ");
    _builder.append("Factory $entityFactory");
    {
      boolean _isTranslatable_7 = this.isTranslatable(it);
      if (_isTranslatable_7) {
        _builder.append(",");
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        _builder.append("VariableApi");
        {
          Boolean _targets_8 = this._utils.targets(this.app, "1.5");
          if ((_targets_8).booleanValue()) {
            _builder.append("Interface");
          }
        }
        _builder.append(" $variableApi,");
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        _builder.append("TranslatableHelper $translatableHelper");
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
          Boolean _targets_9 = this._utils.targets(this.app, "1.5");
          if ((_targets_9).booleanValue()) {
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
    _builder.append("        ");
    _builder.append("$this->entityFactory = $entityFactory;");
    _builder.newLine();
    {
      boolean _isTranslatable_8 = this.isTranslatable(it);
      if (_isTranslatable_8) {
        _builder.append("        ");
        _builder.append("$this->variableApi = $variableApi;");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("$this->translatableHelper = $translatableHelper;");
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
    _builder.append("$this->addEntityFields($builder, $options);");
    _builder.newLine();
    _builder.append("        ");
    final List<DataObject> parents = this._modelExtensions.getParentDataObjects(it, Collections.<DataObject>unmodifiableList(CollectionLiterals.<DataObject>newArrayList()));
    _builder.newLineIfNotEmpty();
    {
      boolean _isEmpty_17 = parents.isEmpty();
      boolean _not_17 = (!_isEmpty_17);
      if (_not_17) {
        _builder.append("        ");
        _builder.append("$builder->add(\'parentFields\', ");
        {
          Boolean _targets_10 = this._utils.targets(this.app, "1.5");
          if ((_targets_10).booleanValue()) {
            String _formatForCodeCapital_7 = this._formattingExtensions.formatForCodeCapital(IterableExtensions.<DataObject>head(parents).getName());
            _builder.append(_formatForCodeCapital_7, "        ");
            _builder.append("Type::class");
          } else {
            _builder.append("\'");
            String _appNamespace_13 = this._utils.appNamespace(this.app);
            _builder.append(_appNamespace_13, "        ");
            _builder.append("\\Form\\Type\\");
            String _formatForCodeCapital_8 = this._formattingExtensions.formatForCodeCapital(IterableExtensions.<DataObject>head(parents).getName());
            _builder.append(_formatForCodeCapital_8, "        ");
            _builder.append("Type\'");
          }
        }
        _builder.append(", [");
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("\'data_class\' => \'");
        String _entityClassName = this._namingExtensions.entityClassName(it, "", Boolean.valueOf(false));
        _builder.append(_entityClassName, "            ");
        _builder.append("\'");
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        _builder.append("]);");
        _builder.newLine();
      }
    }
    {
      boolean _contains = this.extensions.contains("attributes");
      if (_contains) {
        _builder.append("        ");
        _builder.append("if ($this->featureActivationHelper->isEnabled(FeatureActivationHelper::ATTRIBUTES, \'");
        String _formatForCode = this._formattingExtensions.formatForCode(it.getName());
        _builder.append(_formatForCode, "        ");
        _builder.append("\')) {");
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("$this->addAttributeFields($builder, $options);");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("}");
        _builder.newLine();
      }
    }
    {
      boolean _contains_1 = this.extensions.contains("categories");
      if (_contains_1) {
        _builder.append("        ");
        _builder.append("if ($this->featureActivationHelper->isEnabled(FeatureActivationHelper::CATEGORIES, \'");
        String _formatForCode_1 = this._formattingExtensions.formatForCode(it.getName());
        _builder.append(_formatForCode_1, "        ");
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
      boolean _isEmpty_18 = IterableExtensions.isEmpty(this.incomingRelations);
      boolean _not_18 = (!_isEmpty_18);
      if (_not_18) {
        _builder.append("        ");
        _builder.append("$this->addIncomingRelationshipFields($builder, $options);");
        _builder.newLine();
      }
    }
    {
      boolean _isEmpty_19 = IterableExtensions.isEmpty(this.outgoingRelations);
      boolean _not_19 = (!_isEmpty_19);
      if (_not_19) {
        _builder.append("        ");
        _builder.append("$this->addOutgoingRelationshipFields($builder, $options);");
        _builder.newLine();
      }
    }
    {
      if (((it instanceof Entity) && (!Objects.equal(((Entity) it).getWorkflow(), EntityWorkflowType.NONE)))) {
        _builder.append("        ");
        _builder.append("$this->addAdditionalNotificationRemarksField($builder, $options);");
        _builder.newLine();
      }
    }
    {
      if (((it instanceof Entity) && ((Entity) it).isStandardFields())) {
        _builder.append("        ");
        _builder.append("$this->addModerationFields($builder, $options);");
        _builder.newLine();
      }
    }
    _builder.append("        ");
    _builder.append("$this->addReturnControlField($builder, $options);");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$this->addSubmitButtons($builder, $options);");
    _builder.newLine();
    {
      boolean _hasUploadFieldsEntity_2 = this._modelExtensions.hasUploadFieldsEntity(it);
      if (_hasUploadFieldsEntity_2) {
        _builder.newLine();
        _builder.append("        ");
        _builder.append("$builder->addEventListener(FormEvents::PRE_SET_DATA, function (FormEvent $event) {");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("$entity = $event->getData();");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("foreach ([\'");
        final Function1<UploadField, String> _function_10 = (UploadField f) -> {
          return this._formattingExtensions.formatForCode(f.getName());
        };
        String _join = IterableExtensions.join(IterableExtensions.<UploadField, String>map(this._modelExtensions.getUploadFieldsEntity(it), _function_10), "\', \'");
        _builder.append(_join, "            ");
        _builder.append("\'] as $uploadFieldName) {");
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        _builder.append("        ");
        _builder.append("$entity[$uploadFieldName] = [");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("            ");
        _builder.append("$uploadFieldName => $entity[$uploadFieldName] instanceof File ? $entity[$uploadFieldName]->getPathname() : null");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("        ");
        _builder.append("];");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("});");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("$builder->addEventListener(FormEvents::SUBMIT, function (FormEvent $event) {");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("$entity = $event->getData();");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("foreach ([\'");
        final Function1<UploadField, String> _function_11 = (UploadField f) -> {
          return this._formattingExtensions.formatForCode(f.getName());
        };
        String _join_1 = IterableExtensions.join(IterableExtensions.<UploadField, String>map(this._modelExtensions.getUploadFieldsEntity(it), _function_11), "\', \'");
        _builder.append(_join_1, "            ");
        _builder.append("\'] as $uploadFieldName) {");
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        _builder.append("        ");
        _builder.append("if (is_array($entity[$uploadFieldName])) {");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("            ");
        _builder.append("$entity[$uploadFieldName] = $entity[$uploadFieldName][$uploadFieldName];");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("        ");
        _builder.append("}");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("});");
        _builder.newLine();
      }
    }
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    CharSequence _addFields = this.addFields(it);
    _builder.append(_addFields, "    ");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    {
      if (((it instanceof Entity) && ((Entity) it).isGeographical())) {
        _builder.append("    ");
        CharSequence _addGeographicalFields = this.addGeographicalFields(((Entity) it));
        _builder.append(_addGeographicalFields, "    ");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
      }
    }
    {
      boolean _contains_2 = this.extensions.contains("attributes");
      if (_contains_2) {
        _builder.append("    ");
        CharSequence _addAttributeFields = this.addAttributeFields(((Entity) it));
        _builder.append(_addAttributeFields, "    ");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
      }
    }
    {
      boolean _contains_3 = this.extensions.contains("categories");
      if (_contains_3) {
        _builder.append("    ");
        CharSequence _addCategoriesField = this.addCategoriesField(((Entity) it));
        _builder.append(_addCategoriesField, "    ");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
      }
    }
    {
      boolean _isEmpty_20 = IterableExtensions.isEmpty(this.incomingRelations);
      boolean _not_20 = (!_isEmpty_20);
      if (_not_20) {
        _builder.append("    ");
        CharSequence _addIncomingRelationshipFields = this.addIncomingRelationshipFields(it);
        _builder.append(_addIncomingRelationshipFields, "    ");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
      }
    }
    {
      boolean _isEmpty_21 = IterableExtensions.isEmpty(this.outgoingRelations);
      boolean _not_21 = (!_isEmpty_21);
      if (_not_21) {
        _builder.append("    ");
        CharSequence _addOutgoingRelationshipFields = this.addOutgoingRelationshipFields(it);
        _builder.append(_addOutgoingRelationshipFields, "    ");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
      }
    }
    {
      if (((it instanceof Entity) && (!Objects.equal(((Entity) it).getWorkflow(), EntityWorkflowType.NONE)))) {
        _builder.append("    ");
        CharSequence _addAdditionalNotificationRemarksField = this.addAdditionalNotificationRemarksField(((Entity) it));
        _builder.append(_addAdditionalNotificationRemarksField, "    ");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
      }
    }
    {
      if (((it instanceof Entity) && ((Entity) it).isStandardFields())) {
        _builder.append("    ");
        CharSequence _addModerationFields = this.addModerationFields(((Entity) it));
        _builder.append(_addModerationFields, "    ");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
      }
    }
    {
      if ((it instanceof Entity)) {
        _builder.append("    ");
        CharSequence _addReturnControlField = this.addReturnControlField(((Entity)it));
        _builder.append(_addReturnControlField, "    ");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
        _builder.append("    ");
        CharSequence _addSubmitButtons = this.addSubmitButtons(((Entity)it));
        _builder.append(_addSubmitButtons, "    ");
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
    _builder.append("\';");
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
    _builder.append("// define class for underlying data (required for embedding forms)");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("\'data_class\' => \'");
    String _entityClassName_1 = this._namingExtensions.entityClassName(it, "", Boolean.valueOf(false));
    _builder.append(_entityClassName_1, "                ");
    _builder.append("\',");
    _builder.newLineIfNotEmpty();
    _builder.append("                ");
    _builder.append("\'empty_data\' => function (FormInterface $form) {");
    _builder.newLine();
    _builder.append("                    ");
    _builder.append("return $this->entityFactory->create");
    String _formatForCodeCapital_9 = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital_9, "                    ");
    _builder.append("();");
    _builder.newLineIfNotEmpty();
    _builder.append("                ");
    _builder.append("},");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("\'error_mapping\' => [");
    _builder.newLine();
    {
      final Function1<ListField, Boolean> _function_12 = (ListField it_1) -> {
        return Boolean.valueOf(it_1.isMultiple());
      };
      Iterable<ListField> _filter = IterableExtensions.<ListField>filter(Iterables.<ListField>filter(it.getFields(), ListField.class), _function_12);
      for(final ListField field : _filter) {
        _builder.append("                    ");
        _builder.append("\'is");
        String _formatForCodeCapital_10 = this._formattingExtensions.formatForCodeCapital(field.getName());
        _builder.append(_formatForCodeCapital_10, "                    ");
        _builder.append("ValueAllowed\' => \'");
        String _formatForCode_2 = this._formattingExtensions.formatForCode(field.getName());
        _builder.append(_formatForCode_2, "                    ");
        _builder.append("\',");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      Iterable<UserField> _filter_1 = Iterables.<UserField>filter(it.getFields(), UserField.class);
      for(final UserField field_1 : _filter_1) {
        _builder.append("                    ");
        _builder.append("\'is");
        String _formatForCodeCapital_11 = this._formattingExtensions.formatForCodeCapital(field_1.getName());
        _builder.append(_formatForCodeCapital_11, "                    ");
        _builder.append("UserValid\' => \'");
        String _formatForCode_3 = this._formattingExtensions.formatForCode(field_1.getName());
        _builder.append(_formatForCode_3, "                    ");
        _builder.append("\',");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      Iterable<UploadField> _filter_2 = Iterables.<UploadField>filter(it.getFields(), UploadField.class);
      for(final UploadField field_2 : _filter_2) {
        _builder.append("                    ");
        _builder.append("\'");
        String _formatForCode_4 = this._formattingExtensions.formatForCode(field_2.getName());
        _builder.append(_formatForCode_4, "                    ");
        _builder.append("\' => \'");
        String _formatForCode_5 = this._formattingExtensions.formatForCode(field_2.getName());
        _builder.append(_formatForCode_5, "                    ");
        _builder.append(".");
        String _formatForCode_6 = this._formattingExtensions.formatForCode(field_2.getName());
        _builder.append(_formatForCode_6, "                    ");
        _builder.append("\',");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      final Function1<TimeField, Boolean> _function_13 = (TimeField it_1) -> {
        return Boolean.valueOf((it_1.isMandatory() && (it_1.isPast() || it_1.isFuture())));
      };
      Iterable<TimeField> _filter_3 = IterableExtensions.<TimeField>filter(Iterables.<TimeField>filter(it.getFields(), TimeField.class), _function_13);
      for(final TimeField field_3 : _filter_3) {
        {
          boolean _isPast = field_3.isPast();
          if (_isPast) {
            _builder.append("                    ");
            _builder.append("\'is");
            String _formatForCodeCapital_12 = this._formattingExtensions.formatForCodeCapital(field_3.getName());
            _builder.append(_formatForCodeCapital_12, "                    ");
            _builder.append("TimeValidPast\' => \'");
            String _formatForCode_7 = this._formattingExtensions.formatForCode(field_3.getName());
            _builder.append(_formatForCode_7, "                    ");
            _builder.append("\',");
            _builder.newLineIfNotEmpty();
          } else {
            boolean _isFuture = field_3.isFuture();
            if (_isFuture) {
              _builder.append("                    ");
              _builder.append("\'is");
              String _formatForCodeCapital_13 = this._formattingExtensions.formatForCodeCapital(field_3.getName());
              _builder.append(_formatForCodeCapital_13, "                    ");
              _builder.append("TimeValidFuture\' => \'");
              String _formatForCode_8 = this._formattingExtensions.formatForCode(field_3.getName());
              _builder.append(_formatForCode_8, "                    ");
              _builder.append("\',");
              _builder.newLineIfNotEmpty();
            }
          }
        }
      }
    }
    {
      if (((null != this._modelExtensions.getStartDateField(it)) && (null != this._modelExtensions.getEndDateField(it)))) {
        _builder.append("                    ");
        _builder.append("\'is");
        String _formatForCodeCapital_14 = this._formattingExtensions.formatForCodeCapital(this._modelExtensions.getStartDateField(it).getName());
        _builder.append(_formatForCodeCapital_14, "                    ");
        _builder.append("Before");
        String _formatForCodeCapital_15 = this._formattingExtensions.formatForCodeCapital(this._modelExtensions.getEndDateField(it).getName());
        _builder.append(_formatForCodeCapital_15, "                    ");
        _builder.append("\' => \'");
        String _formatForCode_9 = this._formattingExtensions.formatForCode(this._modelExtensions.getStartDateField(it).getName());
        _builder.append(_formatForCode_9, "                    ");
        _builder.append("\',");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("                ");
    _builder.append("],");
    _builder.newLine();
    {
      boolean _isEmpty_22 = IterableExtensions.isEmpty(Iterables.<InheritanceRelationship>filter(it.getIncoming(), InheritanceRelationship.class));
      boolean _not_22 = (!_isEmpty_22);
      if (_not_22) {
        _builder.append("                ");
        _builder.append("\'inherit_data\' => true,");
        _builder.newLine();
      }
    }
    _builder.append("                ");
    _builder.append("\'mode\' => \'create\',");
    _builder.newLine();
    {
      boolean _contains_4 = this.extensions.contains("attributes");
      if (_contains_4) {
        _builder.append("                ");
        _builder.append("\'attributes\' => [],");
        _builder.newLine();
      }
    }
    {
      if (((it instanceof Entity) && (!Objects.equal(((Entity) it).getWorkflow(), EntityWorkflowType.NONE)))) {
        _builder.append("                ");
        _builder.append("\'is_moderator\' => false,");
        _builder.newLine();
        {
          if (((it instanceof Entity) && Objects.equal(((Entity) it).getWorkflow(), EntityWorkflowType.ENTERPRISE))) {
            _builder.append("                ");
            _builder.append("\'is_super_moderator\' => false,");
            _builder.newLine();
          }
        }
        _builder.append("                ");
        _builder.append("\'is_creator\' => false,");
        _builder.newLine();
      }
    }
    _builder.append("                ");
    _builder.append("\'actions\' => [],");
    _builder.newLine();
    {
      if (((it instanceof Entity) && ((Entity) it).isStandardFields())) {
        _builder.append("                ");
        _builder.append("\'has_moderate_permission\' => false,");
        _builder.newLine();
      }
    }
    {
      if (((it instanceof Entity) && this._modelBehaviourExtensions.hasTranslatableFields(((Entity) it)))) {
        _builder.append("                ");
        _builder.append("\'translations\' => [],");
        _builder.newLine();
      }
    }
    {
      if (((!it.getIncoming().isEmpty()) || (!it.getOutgoing().isEmpty()))) {
        _builder.append("                ");
        _builder.append("\'filter_by_ownership\' => true,");
        _builder.newLine();
        _builder.append("                ");
        _builder.append("\'inline_usage\' => false");
        _builder.newLine();
      }
    }
    _builder.append("            ");
    _builder.append("])");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("->setRequired([");
    {
      boolean _hasUploadFieldsEntity_3 = this._modelExtensions.hasUploadFieldsEntity(it);
      if (_hasUploadFieldsEntity_3) {
        _builder.append("\'entity\', ");
      }
    }
    _builder.append("\'mode\', \'actions\'])");
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    _builder.append("->setAllowedTypes([");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("\'mode\' => \'string\',");
    _builder.newLine();
    {
      boolean _contains_5 = this.extensions.contains("attributes");
      if (_contains_5) {
        _builder.append("                ");
        _builder.append("\'attributes\' => \'array\',");
        _builder.newLine();
      }
    }
    {
      if (((it instanceof Entity) && (!Objects.equal(((Entity) it).getWorkflow(), EntityWorkflowType.NONE)))) {
        _builder.append("                ");
        _builder.append("\'is_moderator\' => \'bool\',");
        _builder.newLine();
        {
          if (((it instanceof Entity) && Objects.equal(((Entity) it).getWorkflow(), EntityWorkflowType.ENTERPRISE))) {
            _builder.append("                ");
            _builder.append("\'is_super_moderator\' => \'bool\',");
            _builder.newLine();
          }
        }
        _builder.append("                ");
        _builder.append("\'is_creator\' => \'bool\',");
        _builder.newLine();
      }
    }
    _builder.append("                ");
    _builder.append("\'actions\' => \'array\',");
    _builder.newLine();
    {
      if (((it instanceof Entity) && ((Entity) it).isStandardFields())) {
        _builder.append("                ");
        _builder.append("\'has_moderate_permission\' => \'bool\',");
        _builder.newLine();
      }
    }
    {
      if (((it instanceof Entity) && this._modelBehaviourExtensions.hasTranslatableFields(((Entity) it)))) {
        _builder.append("                ");
        _builder.append("\'translations\' => \'array\',");
        _builder.newLine();
      }
    }
    {
      if (((!it.getIncoming().isEmpty()) || (!it.getOutgoing().isEmpty()))) {
        _builder.append("                ");
        _builder.append("\'filter_by_ownership\' => \'bool\',");
        _builder.newLine();
        _builder.append("                ");
        _builder.append("\'inline_usage\' => \'bool\'");
        _builder.newLine();
      }
    }
    _builder.append("            ");
    _builder.append("])");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("->setAllowedValues([");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("\'mode\' => [\'create\', \'edit\']");
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
  
  private CharSequence addFields(final DataObject it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Adds basic entity fields.");
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
    _builder.append("public function addEntityFields(FormBuilderInterface $builder, array $options)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    {
      if (((it instanceof Entity) && this.isTranslatable(it))) {
        _builder.append("    ");
        CharSequence _translatableFields = this.translatableFields(((Entity) it));
        _builder.append(_translatableFields, "    ");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("    ");
    CharSequence _fieldAdditions = this.fieldAdditions(it, Boolean.valueOf(this.isTranslatable(it)));
    _builder.append(_fieldAdditions, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private boolean isTranslatable(final DataObject it) {
    return this.extensions.contains("translatable");
  }
  
  private CharSequence translatableFields(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _translatableFieldSet = this.translatableFieldSet(it);
    _builder.append(_translatableFieldSet);
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("if ($this->variableApi->getSystemVar(\'multilingual\') && $this->featureActivationHelper->isEnabled(FeatureActivationHelper::TRANSLATIONS, \'");
    String _formatForCode = this._formattingExtensions.formatForCode(it.getName());
    _builder.append(_formatForCode);
    _builder.append("\')) {");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("$supportedLanguages = $this->translatableHelper->getSupportedLanguages(\'");
    String _formatForCode_1 = this._formattingExtensions.formatForCode(it.getName());
    _builder.append(_formatForCode_1, "    ");
    _builder.append("\');");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("if (is_array($supportedLanguages) && count($supportedLanguages) > 1) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$currentLanguage = $this->translatableHelper->getCurrentLanguage();");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$translatableFields = $this->translatableHelper->getTranslatableFields(\'");
    String _formatForCode_2 = this._formattingExtensions.formatForCode(it.getName());
    _builder.append(_formatForCode_2, "        ");
    _builder.append("\');");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("$mandatoryFields = $this->translatableHelper->getMandatoryFields(\'");
    String _formatForCode_3 = this._formattingExtensions.formatForCode(it.getName());
    _builder.append(_formatForCode_3, "        ");
    _builder.append("\');");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("foreach ($supportedLanguages as $language) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("if ($language == $currentLanguage) {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("continue;");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$builder->add(\'translations\' . $language, ");
    {
      Boolean _targets = this._utils.targets(this.app, "1.5");
      if ((_targets).booleanValue()) {
        _builder.append("TranslationType::class");
      } else {
        _builder.append("\'");
        String _appNamespace = this._utils.appNamespace(this.app);
        _builder.append(_appNamespace, "            ");
        _builder.append("\\Form\\Type\\Field\\TranslationType\'");
      }
    }
    _builder.append(", [");
    _builder.newLineIfNotEmpty();
    _builder.append("                ");
    _builder.append("\'fields\' => $translatableFields,");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("\'mandatory_fields\' => $mandatoryFields[$language],");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("\'values\' => isset($options[\'translations\'][$language]) ? $options[\'translations\'][$language] : []");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("]);");
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
  
  private CharSequence fieldAdditions(final DataObject it, final Boolean isTranslatable) {
    StringConcatenation _builder = new StringConcatenation();
    {
      if (((!(isTranslatable).booleanValue()) || (!IterableExtensions.isEmpty(this._modelBehaviourExtensions.getEditableNonTranslatableFields(it))))) {
        {
          if ((isTranslatable).booleanValue()) {
            {
              Iterable<DerivedField> _editableNonTranslatableFields = this._modelBehaviourExtensions.getEditableNonTranslatableFields(it);
              for(final DerivedField field : _editableNonTranslatableFields) {
                CharSequence _fieldImpl = this.fieldImpl(field);
                _builder.append(_fieldImpl);
              }
            }
            _builder.newLineIfNotEmpty();
          } else {
            {
              List<DerivedField> _editableFields = this._modelExtensions.getEditableFields(it);
              for(final DerivedField field_1 : _editableFields) {
                CharSequence _fieldImpl_1 = this.fieldImpl(field_1);
                _builder.append(_fieldImpl_1);
              }
            }
            _builder.newLineIfNotEmpty();
          }
        }
      }
    }
    {
      if ((it instanceof Entity)) {
        {
          if ((this._modelBehaviourExtensions.hasSluggableFields(((Entity)it)) && ((!(isTranslatable).booleanValue()) || (!this._modelBehaviourExtensions.hasTranslatableSlug(((Entity)it)))))) {
            _builder.newLine();
            CharSequence _slugField = this.slugField(((Entity)it));
            _builder.append(_slugField);
            _builder.newLineIfNotEmpty();
          }
        }
        {
          boolean _isGeographical = ((Entity)it).isGeographical();
          if (_isGeographical) {
            _builder.append("$this->addGeographicalFields($builder, $options);");
            _builder.newLine();
          }
        }
      }
    }
    return _builder;
  }
  
  private CharSequence translatableFieldSet(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      Iterable<DerivedField> _editableTranslatableFields = this._modelBehaviourExtensions.getEditableTranslatableFields(it);
      for(final DerivedField field : _editableTranslatableFields) {
        CharSequence _fieldImpl = this.fieldImpl(field);
        _builder.append(_fieldImpl);
      }
    }
    _builder.newLineIfNotEmpty();
    {
      boolean _hasTranslatableSlug = this._modelBehaviourExtensions.hasTranslatableSlug(it);
      if (_hasTranslatableSlug) {
        CharSequence _slugField = this.slugField(it);
        _builder.append(_slugField);
        _builder.newLineIfNotEmpty();
      }
    }
    return _builder;
  }
  
  private CharSequence slugField(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      if (((this._modelBehaviourExtensions.hasSluggableFields(it) && it.isSlugUpdatable()) && this._modelBehaviourExtensions.supportsSlugInputFields(it.getApplication()))) {
        _builder.append("$builder->add(\'slug\', ");
        {
          Boolean _targets = this._utils.targets(this.app, "1.5");
          if ((_targets).booleanValue()) {
            _builder.append("TextType::class");
          } else {
            _builder.append("\'");
            _builder.append(this.nsSymfonyFormType);
            _builder.append("TextType\'");
          }
        }
        _builder.append(", [");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("\'label\' => $this->__(\'Permalink\') . \':\',");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("\'required\' => false");
        _builder.append(",");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("\'empty_data\' => \'\',");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("\'attr\' => [");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("\'maxlength\' => 255,");
        _builder.newLine();
        {
          boolean _isSlugUnique = it.isSlugUnique();
          if (_isSlugUnique) {
            _builder.append("        ");
            _builder.append("\'class\' => \'validate-unique\',");
            _builder.newLine();
          }
        }
        _builder.append("        ");
        _builder.append("\'title\' => $this->__(\'You can input a custom permalink for the ");
        String _formatForDisplay = this._formattingExtensions.formatForDisplay(it.getName());
        _builder.append(_formatForDisplay, "        ");
        {
          boolean _isSlugUnique_1 = it.isSlugUnique();
          boolean _not = (!_isSlugUnique_1);
          if (_not) {
            _builder.append(" or let this field free to create one automatically");
          }
        }
        _builder.append("\')");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("],");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("\'help\' => $this->__(\'You can input a custom permalink for the ");
        String _formatForDisplay_1 = this._formattingExtensions.formatForDisplay(it.getName());
        _builder.append(_formatForDisplay_1, "    ");
        {
          boolean _isSlugUnique_2 = it.isSlugUnique();
          boolean _not_1 = (!_isSlugUnique_2);
          if (_not_1) {
            _builder.append(" or let this field free to create one automatically");
          }
        }
        _builder.append("\')");
        _builder.newLineIfNotEmpty();
        _builder.append("]);");
        _builder.newLine();
      }
    }
    return _builder;
  }
  
  private CharSequence fieldImpl(final DerivedField it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.newLine();
    {
      final Function1<JoinRelationship, Boolean> _function = (JoinRelationship e) -> {
        String _head = IterableExtensions.<String>head(((Iterable<String>)Conversions.doWrapArray(this._modelJoinExtensions.getSourceFields(e))));
        String _formatForDB = this._formattingExtensions.formatForDB(it.getName());
        return Boolean.valueOf(Objects.equal(_head, _formatForDB));
      };
      boolean _isEmpty = IterableExtensions.isEmpty(IterableExtensions.<JoinRelationship>filter(this._modelJoinExtensions.getIncomingJoinRelations(it.getEntity()), _function));
      if (_isEmpty) {
        {
          if ((it instanceof ListField)) {
            CharSequence _fetchListEntries = this.fetchListEntries(((ListField)it));
            _builder.append(_fetchListEntries);
            _builder.newLineIfNotEmpty();
          }
        }
        final boolean isExpandedListField = ((it instanceof ListField) && ((ListField) it).isExpanded());
        _builder.newLineIfNotEmpty();
        _builder.append("$builder->add(\'");
        String _formatForCode = this._formattingExtensions.formatForCode(it.getName());
        _builder.append(_formatForCode);
        _builder.append("\', ");
        {
          Boolean _targets = this._utils.targets(this.app, "1.5");
          if ((_targets).booleanValue()) {
            CharSequence _formType = this.formType(it);
            _builder.append(_formType);
            _builder.append("Type::class");
          } else {
            _builder.append("\'");
            CharSequence _formType_1 = this.formType(it);
            _builder.append(_formType_1);
            _builder.append("Type\'");
          }
        }
        _builder.append(", [");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("\'label\' => $this->__(\'");
        String _formatForDisplayCapital = this._formattingExtensions.formatForDisplayCapital(it.getName());
        _builder.append(_formatForDisplayCapital, "    ");
        _builder.append("\') . \':\',");
        _builder.newLineIfNotEmpty();
        {
          if (((null != it.getDocumentation()) && (!Objects.equal(it.getDocumentation(), "")))) {
            _builder.append("    ");
            _builder.append("\'label_attr\' => [");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("\'class\' => \'tooltips");
            {
              if (isExpandedListField) {
                _builder.append(" ");
                {
                  boolean _isMultiple = ((ListField) it).isMultiple();
                  if (_isMultiple) {
                    _builder.append("checkbox");
                  } else {
                    _builder.append("radio");
                  }
                }
                _builder.append("-inline");
              }
            }
            _builder.append("\',");
            _builder.newLineIfNotEmpty();
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
          } else {
            if (isExpandedListField) {
              _builder.append("    ");
              _builder.append("\'label_attr\' => [");
              _builder.newLine();
              _builder.append("    ");
              _builder.append("    ");
              _builder.append("\'class\' => \'");
              {
                boolean _isMultiple_1 = ((ListField) it).isMultiple();
                if (_isMultiple_1) {
                  _builder.append("checkbox");
                } else {
                  _builder.append("radio");
                }
              }
              _builder.append("-inline\'");
              _builder.newLineIfNotEmpty();
              _builder.append("    ");
              _builder.append("],");
              _builder.newLine();
            }
          }
        }
        _builder.append("    ");
        CharSequence _helpAttribute = this.helpAttribute(it);
        _builder.append(_helpAttribute, "    ");
        _builder.newLineIfNotEmpty();
        {
          boolean _isReadonly = it.isReadonly();
          if (_isReadonly) {
            _builder.append("    ");
            _builder.append("\'disabled\' => true,");
            _builder.newLine();
          }
        }
        {
          if ((!((it instanceof BooleanField) || (it instanceof UploadField)))) {
            _builder.append("    ");
            _builder.append("\'empty_data\' => \'");
            String _defaultValue = it.getDefaultValue();
            _builder.append(_defaultValue, "    ");
            _builder.append("\',");
            _builder.newLineIfNotEmpty();
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
        _builder.append("\'class\' => \'");
        CharSequence _fieldValidationCssClass = this.validationHelper.fieldValidationCssClass(it);
        _builder.append(_fieldValidationCssClass, "        ");
        _builder.append("\',");
        _builder.newLineIfNotEmpty();
        {
          boolean _isReadonly_1 = it.isReadonly();
          if (_isReadonly_1) {
            _builder.append("        ");
            _builder.append("\'readonly\' => \'readonly\',");
            _builder.newLine();
          }
        }
        {
          if (((it instanceof IntegerField) && ((IntegerField) it).isRange())) {
            _builder.append("        ");
            _builder.append("\'min\' => ");
            BigInteger _minValue = ((IntegerField) it).getMinValue();
            _builder.append(_minValue, "        ");
            _builder.append(",");
            _builder.newLineIfNotEmpty();
            _builder.append("        ");
            _builder.append("\'max\' => ");
            BigInteger _maxValue = ((IntegerField) it).getMaxValue();
            _builder.append(_maxValue, "        ");
            _builder.append(",");
            _builder.newLineIfNotEmpty();
          }
        }
        _builder.append("        ");
        _builder.append("\'title\' => $this->__(\'");
        CharSequence _titleAttribute = this.titleAttribute(it);
        _builder.append(_titleAttribute, "        ");
        _builder.append("\')");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("],");
        _builder.newLine();
        _builder.append("    ");
        CharSequence _requiredOption = this.requiredOption(it);
        _builder.append(_requiredOption, "    ");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        CharSequence _additionalOptions = this.additionalOptions(it);
        _builder.append(_additionalOptions, "    ");
        _builder.newLineIfNotEmpty();
        _builder.append("]);");
        _builder.newLine();
      }
    }
    return _builder;
  }
  
  private CharSequence helpAttribute(final DerivedField it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _isEmpty = this.helpMessages(it).isEmpty();
      boolean _not = (!_isEmpty);
      if (_not) {
        _builder.append("\'help\' => ");
        {
          int _length = ((Object[])Conversions.unwrapArray(this.helpMessages(it), Object.class)).length;
          boolean _greaterThan = (_length > 1);
          if (_greaterThan) {
            _builder.append("[");
          }
        }
        String _join = IterableExtensions.join(this.helpMessages(it), ", ");
        _builder.append(_join);
        {
          int _length_1 = ((Object[])Conversions.unwrapArray(this.helpMessages(it), Object.class)).length;
          boolean _greaterThan_1 = (_length_1 > 1);
          if (_greaterThan_1) {
            _builder.append("]");
          }
        }
        _builder.append(",");
      }
    }
    return _builder;
  }
  
  private ArrayList<String> helpDocumentation(final DerivedField it) {
    ArrayList<String> _xblockexpression = null;
    {
      final ArrayList<String> messages = CollectionLiterals.<String>newArrayList();
      if (((null != it.getDocumentation()) && (!Objects.equal(it.getDocumentation(), "")))) {
        String _replace = it.getDocumentation().replace("\'", "\"");
        String _plus = ("$this->__(\'" + _replace);
        String _plus_1 = (_plus + "\')");
        messages.add(_plus_1);
      }
      _xblockexpression = messages;
    }
    return _xblockexpression;
  }
  
  private ArrayList<String> _helpMessages(final DerivedField it) {
    ArrayList<String> _xblockexpression = null;
    {
      final ArrayList<String> messages = this.helpDocumentation(it);
      _xblockexpression = messages;
    }
    return _xblockexpression;
  }
  
  private ArrayList<String> _helpMessages(final IntegerField it) {
    ArrayList<String> _xblockexpression = null;
    {
      final ArrayList<String> messages = this.helpDocumentation(it);
      int _compareTo = it.getMinValue().compareTo(BigInteger.valueOf(0));
      final boolean hasMin = (_compareTo > 0);
      int _compareTo_1 = it.getMaxValue().compareTo(BigInteger.valueOf(0));
      final boolean hasMax = (_compareTo_1 > 0);
      if (((!it.isRange()) && (hasMin || hasMax))) {
        if ((hasMin && hasMax)) {
          BigInteger _minValue = it.getMinValue();
          BigInteger _maxValue = it.getMaxValue();
          boolean _equals = Objects.equal(_minValue, _maxValue);
          if (_equals) {
            StringConcatenation _builder = new StringConcatenation();
            _builder.append("$this->__f(\'Note: this value must exactly be %value%.\', [\'%value%\' => ");
            BigInteger _minValue_1 = it.getMinValue();
            _builder.append(_minValue_1);
            _builder.append("])");
            messages.add(_builder.toString());
          } else {
            StringConcatenation _builder_1 = new StringConcatenation();
            _builder_1.append("$this->__f(\'Note: this value must be between %minValue% and %maxValue%.\', [\'%minValue%\' => ");
            BigInteger _minValue_2 = it.getMinValue();
            _builder_1.append(_minValue_2);
            _builder_1.append(", \'%maxValue%\' => ");
            BigInteger _maxValue_1 = it.getMaxValue();
            _builder_1.append(_maxValue_1);
            _builder_1.append("])");
            messages.add(_builder_1.toString());
          }
        } else {
          if (hasMin) {
            StringConcatenation _builder_2 = new StringConcatenation();
            _builder_2.append("$this->__f(\'Note: this value must be greater than %minValue%.\', [\'%minValue%\' => ");
            BigInteger _minValue_3 = it.getMinValue();
            _builder_2.append(_minValue_3);
            _builder_2.append("])");
            messages.add(_builder_2.toString());
          } else {
            if (hasMax) {
              StringConcatenation _builder_3 = new StringConcatenation();
              _builder_3.append("$this->__f(\'Note: this value must be less than %maxValue%.\', [\'%maxValue%\' => ");
              BigInteger _maxValue_2 = it.getMaxValue();
              _builder_3.append(_maxValue_2);
              _builder_3.append("])");
              messages.add(_builder_3.toString());
            }
          }
        }
      }
      _xblockexpression = messages;
    }
    return _xblockexpression;
  }
  
  private ArrayList<String> _helpMessages(final DecimalField it) {
    ArrayList<String> _xblockexpression = null;
    {
      final ArrayList<String> messages = this.helpDocumentation(it);
      float _minValue = it.getMinValue();
      final boolean hasMin = (_minValue > 0);
      float _maxValue = it.getMaxValue();
      final boolean hasMax = (_maxValue > 0);
      if ((hasMin || hasMax)) {
        if ((hasMin && hasMax)) {
          float _minValue_1 = it.getMinValue();
          float _maxValue_1 = it.getMaxValue();
          boolean _equals = (_minValue_1 == _maxValue_1);
          if (_equals) {
            StringConcatenation _builder = new StringConcatenation();
            _builder.append("$this->__f(\'Note: this value must exactly be %value%.\', [\'%value%\' => ");
            float _minValue_2 = it.getMinValue();
            _builder.append(_minValue_2);
            _builder.append("])");
            messages.add(_builder.toString());
          } else {
            StringConcatenation _builder_1 = new StringConcatenation();
            _builder_1.append("$this->__f(\'Note: this value must be between %minValue% and %maxValue%.\', [\'%minValue%\' => ");
            float _minValue_3 = it.getMinValue();
            _builder_1.append(_minValue_3);
            _builder_1.append(", \'%maxValue%\' => ");
            float _maxValue_2 = it.getMaxValue();
            _builder_1.append(_maxValue_2);
            _builder_1.append("])");
            messages.add(_builder_1.toString());
          }
        } else {
          if (hasMin) {
            StringConcatenation _builder_2 = new StringConcatenation();
            _builder_2.append("$this->__f(\'Note: this value must be greater than %minValue%.\', [\'%minValue%\' => ");
            float _minValue_4 = it.getMinValue();
            _builder_2.append(_minValue_4);
            _builder_2.append("])");
            messages.add(_builder_2.toString());
          } else {
            if (hasMax) {
              StringConcatenation _builder_3 = new StringConcatenation();
              _builder_3.append("$this->__f(\'Note: this value must be less than %maxValue%.\', [\'%maxValue%\' => ");
              float _maxValue_3 = it.getMaxValue();
              _builder_3.append(_maxValue_3);
              _builder_3.append("])");
              messages.add(_builder_3.toString());
            }
          }
        }
      }
      _xblockexpression = messages;
    }
    return _xblockexpression;
  }
  
  private ArrayList<String> _helpMessages(final FloatField it) {
    ArrayList<String> _xblockexpression = null;
    {
      final ArrayList<String> messages = this.helpDocumentation(it);
      float _minValue = it.getMinValue();
      final boolean hasMin = (_minValue > 0);
      float _maxValue = it.getMaxValue();
      final boolean hasMax = (_maxValue > 0);
      if ((hasMin || hasMax)) {
        if ((hasMin && hasMax)) {
          float _minValue_1 = it.getMinValue();
          float _maxValue_1 = it.getMaxValue();
          boolean _equals = (_minValue_1 == _maxValue_1);
          if (_equals) {
            StringConcatenation _builder = new StringConcatenation();
            _builder.append("$this->__f(\'Note: this value must exactly be %value%.\', [\'%value%\' => ");
            float _minValue_2 = it.getMinValue();
            _builder.append(_minValue_2);
            _builder.append("])");
            messages.add(_builder.toString());
          } else {
            StringConcatenation _builder_1 = new StringConcatenation();
            _builder_1.append("$this->__f(\'Note: this value must be between %minValue% and %maxValue%.\', [\'%minValue%\' => ");
            float _minValue_3 = it.getMinValue();
            _builder_1.append(_minValue_3);
            _builder_1.append(", \'%maxValue%\' => ");
            float _maxValue_2 = it.getMaxValue();
            _builder_1.append(_maxValue_2);
            _builder_1.append("])");
            messages.add(_builder_1.toString());
          }
        } else {
          if (hasMin) {
            StringConcatenation _builder_2 = new StringConcatenation();
            _builder_2.append("$this->__f(\'Note: this value must be greater than %minValue%.\', [\'%minValue%\' => ");
            float _minValue_4 = it.getMinValue();
            _builder_2.append(_minValue_4);
            _builder_2.append("])");
            messages.add(_builder_2.toString());
          } else {
            if (hasMax) {
              StringConcatenation _builder_3 = new StringConcatenation();
              _builder_3.append("$this->__f(\'Note: this value must be less than %maxValue%.\', [\'%maxValue%\' => ");
              float _maxValue_3 = it.getMaxValue();
              _builder_3.append(_maxValue_3);
              _builder_3.append("])");
              messages.add(_builder_3.toString());
            }
          }
        }
      }
      _xblockexpression = messages;
    }
    return _xblockexpression;
  }
  
  private ArrayList<String> _helpMessages(final StringField it) {
    ArrayList<String> _xblockexpression = null;
    {
      final ArrayList<String> messages = this.helpDocumentation(it);
      if (((null != it.getRegexp()) && (!Objects.equal(it.getRegexp(), "")))) {
        StringConcatenation _builder = new StringConcatenation();
        _builder.append("$this->__f(\'Note: this value must");
        {
          boolean _isRegexpOpposite = it.isRegexpOpposite();
          if (_isRegexpOpposite) {
            _builder.append(" not");
          }
        }
        _builder.append(" conform to the regular expression \"%pattern%\".\', [\'%pattern%\' => \'");
        String _replace = it.getRegexp().replace("\'", "");
        _builder.append(_replace);
        _builder.append("\'])");
        messages.add(_builder.toString());
      }
      _xblockexpression = messages;
    }
    return _xblockexpression;
  }
  
  private ArrayList<String> _helpMessages(final TextField it) {
    ArrayList<String> _xblockexpression = null;
    {
      final ArrayList<String> messages = this.helpDocumentation(it);
      if (((null != it.getRegexp()) && (!Objects.equal(it.getRegexp(), "")))) {
        StringConcatenation _builder = new StringConcatenation();
        _builder.append("$this->__f(\'Note: this value must");
        {
          boolean _isRegexpOpposite = it.isRegexpOpposite();
          if (_isRegexpOpposite) {
            _builder.append(" not");
          }
        }
        _builder.append(" conform to the regular expression \"%pattern%\".\', [\'%pattern%\' => \'");
        String _replace = it.getRegexp().replace("\'", "");
        _builder.append(_replace);
        _builder.append("\'])");
        messages.add(_builder.toString());
      }
      _xblockexpression = messages;
    }
    return _xblockexpression;
  }
  
  private ArrayList<String> _helpMessages(final ListField it) {
    ArrayList<String> _xblockexpression = null;
    {
      final ArrayList<String> messages = this.helpDocumentation(it);
      if (((it.isMultiple() && (it.getMin() > 0)) && (it.getMax() > 0))) {
        int _min = it.getMin();
        int _max = it.getMax();
        boolean _equals = (_min == _max);
        if (_equals) {
          StringConcatenation _builder = new StringConcatenation();
          _builder.append("$this->__f(\'Note: you must select exactly %min% choices.\', [\'%min%\' => ");
          int _min_1 = it.getMin();
          _builder.append(_min_1);
          _builder.append("])");
          messages.add(_builder.toString());
        } else {
          StringConcatenation _builder_1 = new StringConcatenation();
          _builder_1.append("$this->__f(\'Note: you must select between %min% and %max% choices.\', [\'%min%\' => ");
          int _min_2 = it.getMin();
          _builder_1.append(_min_2);
          _builder_1.append(", \'%max%\' => ");
          int _max_1 = it.getMax();
          _builder_1.append(_max_1);
          _builder_1.append("])");
          messages.add(_builder_1.toString());
        }
      }
      _xblockexpression = messages;
    }
    return _xblockexpression;
  }
  
  private ArrayList<String> _helpMessages(final ArrayField it) {
    ArrayList<String> _xblockexpression = null;
    {
      final ArrayList<String> messages = this.helpDocumentation(it);
      StringConcatenation _builder = new StringConcatenation();
      _builder.append("$this->__(\'Enter one entry per line.\')");
      messages.add(_builder.toString());
      _xblockexpression = messages;
    }
    return _xblockexpression;
  }
  
  private ArrayList<String> _helpMessages(final AbstractDateField it) {
    ArrayList<String> _xblockexpression = null;
    {
      final ArrayList<String> messages = this.helpDocumentation(it);
      boolean _isPast = it.isPast();
      if (_isPast) {
        StringConcatenation _builder = new StringConcatenation();
        _builder.append("$this->__(\'Note: this value must be in the past.\')");
        messages.add(_builder.toString());
      } else {
        boolean _isFuture = it.isFuture();
        if (_isFuture) {
          StringConcatenation _builder_1 = new StringConcatenation();
          _builder_1.append("$this->__(\'Note: this value must be in the future.\')");
          messages.add(_builder_1.toString());
        }
      }
      _xblockexpression = messages;
    }
    return _xblockexpression;
  }
  
  private CharSequence _formType(final DerivedField it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append(this.nsSymfonyFormType);
    _builder.append("Text");
    return _builder;
  }
  
  private CharSequence _titleAttribute(final DerivedField it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("Enter the ");
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(it.getName());
    _builder.append(_formatForDisplay);
    _builder.append(" of the ");
    String _formatForDisplay_1 = this._formattingExtensions.formatForDisplay(it.getEntity().getName());
    _builder.append(_formatForDisplay_1);
    return _builder;
  }
  
  private CharSequence _additionalAttributes(final DerivedField it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("\'maxlength\' => 255,");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence _requiredOption(final DerivedField it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("\'required\' => ");
    String _displayBool = this._formattingExtensions.displayBool(Boolean.valueOf(it.isMandatory()));
    _builder.append(_displayBool);
    _builder.append(",");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence _additionalOptions(final DerivedField it) {
    StringConcatenation _builder = new StringConcatenation();
    return _builder;
  }
  
  private CharSequence _formType(final BooleanField it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      Boolean _targets = this._utils.targets(this.app, "1.5");
      boolean _not = (!(_targets).booleanValue());
      if (_not) {
        _builder.append(this.nsSymfonyFormType);
      }
    }
    _builder.append("Checkbox");
    return _builder;
  }
  
  private CharSequence _titleAttribute(final BooleanField it) {
    StringConcatenation _builder = new StringConcatenation();
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(it.getName());
    _builder.append(_formatForDisplay);
    _builder.append(" ?");
    return _builder;
  }
  
  private CharSequence _additionalAttributes(final BooleanField it) {
    StringConcatenation _builder = new StringConcatenation();
    return _builder;
  }
  
  private CharSequence _formType(final IntegerField it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      Boolean _targets = this._utils.targets(this.app, "1.5");
      boolean _not = (!(_targets).booleanValue());
      if (_not) {
        _builder.append(this.nsSymfonyFormType);
      }
    }
    {
      boolean _isPercentage = it.isPercentage();
      if (_isPercentage) {
        _builder.append("Percent");
      } else {
        boolean _isRange = it.isRange();
        if (_isRange) {
          _builder.append("Range");
        } else {
          _builder.append("Integer");
        }
      }
    }
    return _builder;
  }
  
  private CharSequence _titleAttribute(final IntegerField it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("Enter the ");
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(it.getName());
    _builder.append(_formatForDisplay);
    _builder.append(" of the ");
    String _formatForDisplay_1 = this._formattingExtensions.formatForDisplay(it.getEntity().getName());
    _builder.append(_formatForDisplay_1);
    _builder.append(".\') . \' \' . $this->__(\'Only digits are allowed.");
    return _builder;
  }
  
  private CharSequence _additionalAttributes(final IntegerField it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("\'maxlength\' => ");
    int _length = it.getLength();
    _builder.append(_length);
    _builder.append(",");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence _additionalOptions(final IntegerField it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _isPercentage = it.isPercentage();
      if (_isPercentage) {
        _builder.append("\'type\' => \'integer\',");
        _builder.newLine();
      }
    }
    {
      boolean _isRange = it.isRange();
      boolean _not = (!_isRange);
      if (_not) {
        _builder.append("\'scale\' => 0");
        _builder.newLine();
      }
    }
    return _builder;
  }
  
  private CharSequence _formType(final DecimalField it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      Boolean _targets = this._utils.targets(this.app, "1.5");
      boolean _not = (!(_targets).booleanValue());
      if (_not) {
        _builder.append(this.nsSymfonyFormType);
      }
    }
    {
      boolean _isPercentage = it.isPercentage();
      if (_isPercentage) {
        _builder.append("Percent");
      } else {
        boolean _isCurrency = it.isCurrency();
        if (_isCurrency) {
          _builder.append("Money");
        } else {
          _builder.append("Number");
        }
      }
    }
    return _builder;
  }
  
  private CharSequence _additionalAttributes(final DecimalField it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("\'maxlength\' => ");
    int _length = it.getLength();
    int _plus = (_length + 3);
    int _scale = it.getScale();
    int _plus_1 = (_plus + _scale);
    _builder.append(_plus_1);
    _builder.append(",");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence _additionalOptions(final DecimalField it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.newLine();
    _builder.newLine();
    _builder.append("\'scale\' => ");
    int _scale = it.getScale();
    _builder.append(_scale);
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence _formType(final FloatField it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      Boolean _targets = this._utils.targets(this.app, "1.5");
      boolean _not = (!(_targets).booleanValue());
      if (_not) {
        _builder.append(this.nsSymfonyFormType);
      }
    }
    {
      boolean _isPercentage = it.isPercentage();
      if (_isPercentage) {
        _builder.append("Percent");
      } else {
        boolean _isCurrency = it.isCurrency();
        if (_isCurrency) {
          _builder.append("Money");
        } else {
          _builder.append("Number");
        }
      }
    }
    return _builder;
  }
  
  private CharSequence _additionalAttributes(final FloatField it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("\'maxlength\' => ");
    int _length = it.getLength();
    int _plus = (_length + 3);
    int _plus_1 = (_plus + 2);
    _builder.append(_plus_1);
    _builder.append(",");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence _additionalOptions(final FloatField it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.newLine();
    _builder.newLine();
    _builder.append("\'scale\' => 2");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence _formType(final StringField it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _isCountry = it.isCountry();
      if (_isCountry) {
        {
          Boolean _targets = this._utils.targets(this.app, "1.5");
          boolean _not = (!(_targets).booleanValue());
          if (_not) {
            _builder.append(this.nsSymfonyFormType);
          }
        }
        _builder.append("Country");
      } else {
        boolean _isLanguage = it.isLanguage();
        if (_isLanguage) {
          {
            Boolean _targets_1 = this._utils.targets(this.app, "1.5");
            boolean _not_1 = (!(_targets_1).booleanValue());
            if (_not_1) {
              _builder.append(this.nsSymfonyFormType);
            }
          }
          _builder.append("Language");
        } else {
          boolean _isLocale = it.isLocale();
          if (_isLocale) {
            {
              Boolean _targets_2 = this._utils.targets(this.app, "1.5");
              boolean _not_2 = (!(_targets_2).booleanValue());
              if (_not_2) {
                _builder.append("Zikula\\Bundle\\FormExtensionBundle\\Form\\Type\\");
              }
            }
            _builder.append("Locale");
          } else {
            boolean _isHtmlcolour = it.isHtmlcolour();
            if (_isHtmlcolour) {
              {
                Boolean _targets_3 = this._utils.targets(this.app, "1.5");
                boolean _not_3 = (!(_targets_3).booleanValue());
                if (_not_3) {
                  String _appNamespace = this._utils.appNamespace(this.app);
                  _builder.append(_appNamespace);
                  _builder.append("\\Form\\Type\\Field\\");
                }
              }
              _builder.append("Colour");
            } else {
              boolean _isPassword = it.isPassword();
              if (_isPassword) {
                {
                  Boolean _targets_4 = this._utils.targets(this.app, "1.5");
                  boolean _not_4 = (!(_targets_4).booleanValue());
                  if (_not_4) {
                    _builder.append(this.nsSymfonyFormType);
                  }
                }
                _builder.append("Password");
              } else {
                boolean _isCurrency = it.isCurrency();
                if (_isCurrency) {
                  {
                    Boolean _targets_5 = this._utils.targets(this.app, "1.5");
                    boolean _not_5 = (!(_targets_5).booleanValue());
                    if (_not_5) {
                      _builder.append(this.nsSymfonyFormType);
                    }
                  }
                  _builder.append("Currency");
                } else {
                  boolean _isTimezone = it.isTimezone();
                  if (_isTimezone) {
                    {
                      Boolean _targets_6 = this._utils.targets(this.app, "1.5");
                      boolean _not_6 = (!(_targets_6).booleanValue());
                      if (_not_6) {
                        _builder.append(this.nsSymfonyFormType);
                      }
                    }
                    _builder.append("Timezone");
                  } else {
                    {
                      Boolean _targets_7 = this._utils.targets(this.app, "1.5");
                      boolean _not_7 = (!(_targets_7).booleanValue());
                      if (_not_7) {
                        _builder.append(this.nsSymfonyFormType);
                      }
                    }
                    _builder.append("Text");
                  }
                }
              }
            }
          }
        }
      }
    }
    return _builder;
  }
  
  private CharSequence _titleAttribute(final StringField it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      if ((((((it.isCountry() || it.isLanguage()) || it.isLocale()) || it.isHtmlcolour()) || it.isCurrency()) || it.isTimezone())) {
        _builder.append("Choose the ");
        String _formatForDisplay = this._formattingExtensions.formatForDisplay(it.getName());
        _builder.append(_formatForDisplay);
        _builder.append(" of the ");
        String _formatForDisplay_1 = this._formattingExtensions.formatForDisplay(it.getEntity().getName());
        _builder.append(_formatForDisplay_1);
      } else {
        _builder.append("Enter the ");
        String _formatForDisplay_2 = this._formattingExtensions.formatForDisplay(it.getName());
        _builder.append(_formatForDisplay_2);
        _builder.append(" of the ");
        String _formatForDisplay_3 = this._formattingExtensions.formatForDisplay(it.getEntity().getName());
        _builder.append(_formatForDisplay_3);
      }
    }
    return _builder;
  }
  
  private CharSequence _additionalAttributes(final StringField it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("\'maxlength\' => ");
    int _length = it.getLength();
    _builder.append(_length);
    _builder.append(",");
    _builder.newLineIfNotEmpty();
    {
      if (((null != it.getRegexp()) && (!Objects.equal(it.getRegexp(), "")))) {
        {
          boolean _isRegexpOpposite = it.isRegexpOpposite();
          boolean _not = (!_isRegexpOpposite);
          if (_not) {
            _builder.append("\'pattern\' => \'");
            String _replace = it.getRegexp().replace("\'", "");
            _builder.append(_replace);
            _builder.append("\',");
            _builder.newLineIfNotEmpty();
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
  
  private CharSequence _formType(final TextField it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      Boolean _targets = this._utils.targets(this.app, "1.5");
      boolean _not = (!(_targets).booleanValue());
      if (_not) {
        _builder.append(this.nsSymfonyFormType);
      }
    }
    _builder.append("Textarea");
    return _builder;
  }
  
  private CharSequence _additionalAttributes(final TextField it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("\'maxlength\' => ");
    int _length = it.getLength();
    _builder.append(_length);
    _builder.append(",");
    _builder.newLineIfNotEmpty();
    {
      if (((null != it.getRegexp()) && (!Objects.equal(it.getRegexp(), "")))) {
        {
          boolean _isRegexpOpposite = it.isRegexpOpposite();
          boolean _not = (!_isRegexpOpposite);
          if (_not) {
            _builder.append("\'pattern\' => \'");
            String _replace = it.getRegexp().replace("\'", "");
            _builder.append(_replace);
            _builder.append("\',");
            _builder.newLineIfNotEmpty();
          }
        }
      }
    }
    return _builder;
  }
  
  private CharSequence _formType(final EmailField it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      Boolean _targets = this._utils.targets(this.app, "1.5");
      boolean _not = (!(_targets).booleanValue());
      if (_not) {
        _builder.append(this.nsSymfonyFormType);
      }
    }
    _builder.append("Email");
    return _builder;
  }
  
  private CharSequence _additionalAttributes(final EmailField it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("\'maxlength\' => ");
    int _length = it.getLength();
    _builder.append(_length);
    _builder.append(",");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence _formType(final UrlField it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      Boolean _targets = this._utils.targets(this.app, "1.5");
      boolean _not = (!(_targets).booleanValue());
      if (_not) {
        _builder.append(this.nsSymfonyFormType);
      }
    }
    _builder.append("Url");
    return _builder;
  }
  
  private CharSequence _additionalAttributes(final UrlField it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("\'maxlength\' => ");
    int _length = it.getLength();
    _builder.append(_length);
    _builder.append(",");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence _additionalOptions(final UrlField it) {
    StringConcatenation _builder = new StringConcatenation();
    return _builder;
  }
  
  private CharSequence _formType(final UploadField it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      Boolean _targets = this._utils.targets(this.app, "1.5");
      boolean _not = (!(_targets).booleanValue());
      if (_not) {
        String _appNamespace = this._utils.appNamespace(this.app);
        _builder.append(_appNamespace);
        _builder.append("\\Form\\Type\\Field\\");
      }
    }
    _builder.append("Upload");
    return _builder;
  }
  
  private CharSequence _additionalAttributes(final UploadField it) {
    StringConcatenation _builder = new StringConcatenation();
    return _builder;
  }
  
  private CharSequence _requiredOption(final UploadField it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("\'required\' => ");
    String _displayBool = this._formattingExtensions.displayBool(Boolean.valueOf(it.isMandatory()));
    _builder.append(_displayBool);
    _builder.append(" && $options[\'mode\'] == \'create\',");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence _additionalOptions(final UploadField it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("\'entity\' => $options[\'entity\'],");
    _builder.newLine();
    _builder.append("\'allowed_extensions\' => \'");
    String _allowedExtensions = it.getAllowedExtensions();
    _builder.append(_allowedExtensions);
    _builder.append("\',");
    _builder.newLineIfNotEmpty();
    _builder.append("\'allowed_size\' => \'");
    String _maxSize = it.getMaxSize();
    _builder.append(_maxSize);
    _builder.append("\'");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence fetchListEntries(final ListField it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("$listEntries = $this->listHelper->getEntries(\'");
    String _formatForCode = this._formattingExtensions.formatForCode(it.getEntity().getName());
    _builder.append(_formatForCode);
    _builder.append("\', \'");
    String _formatForCode_1 = this._formattingExtensions.formatForCode(it.getName());
    _builder.append(_formatForCode_1);
    _builder.append("\');");
    _builder.newLineIfNotEmpty();
    _builder.append("$choices = [];");
    _builder.newLine();
    _builder.append("$choiceAttributes = [];");
    _builder.newLine();
    _builder.append("foreach ($listEntries as $entry) {");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$choices[$entry[\'text\']] = $entry[\'value\'];");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$choiceAttributes[$entry[\'text\']] = [\'title\' => $entry[\'title\']];");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence _formType(final ListField it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _isMultiple = it.isMultiple();
      if (_isMultiple) {
        {
          Boolean _targets = this._utils.targets(this.app, "1.5");
          boolean _not = (!(_targets).booleanValue());
          if (_not) {
            String _appNamespace = this._utils.appNamespace(this.app);
            _builder.append(_appNamespace);
            _builder.append("\\Form\\Type\\Field\\");
          }
        }
        _builder.append("MultiList");
      } else {
        {
          Boolean _targets_1 = this._utils.targets(this.app, "1.5");
          boolean _not_1 = (!(_targets_1).booleanValue());
          if (_not_1) {
            _builder.append(this.nsSymfonyFormType);
          }
        }
        _builder.append("Choice");
      }
    }
    return _builder;
  }
  
  private CharSequence _titleAttribute(final ListField it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("Choose the ");
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(it.getName());
    _builder.append(_formatForDisplay);
    return _builder;
  }
  
  private CharSequence _additionalAttributes(final ListField it) {
    StringConcatenation _builder = new StringConcatenation();
    return _builder;
  }
  
  private CharSequence _additionalOptions(final ListField it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      if (((!it.isExpanded()) && (!it.isMandatory()))) {
        _builder.append("\'placeholder\' => $this->__(\'Choose an option\'),");
        _builder.newLine();
      }
    }
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
    _builder.append("\'expanded\' => ");
    String _displayBool_1 = this._formattingExtensions.displayBool(Boolean.valueOf(it.isExpanded()));
    _builder.append(_displayBool_1);
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence _formType(final UserField it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      Boolean _targets = this._utils.targets(this.app, "1.5");
      boolean _not = (!(_targets).booleanValue());
      if (_not) {
        String _appNamespace = this._utils.appNamespace(this.app);
        _builder.append(_appNamespace);
        _builder.append("\\Form\\Type\\Field\\");
      }
    }
    _builder.append("User");
    return _builder;
  }
  
  private CharSequence _additionalAttributes(final UserField it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("\'maxlength\' => ");
    int _length = it.getLength();
    _builder.append(_length);
    _builder.append(",");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence _additionalOptions(final UserField it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      if (((!it.getEntity().getIncoming().isEmpty()) || (!it.getEntity().getOutgoing().isEmpty()))) {
        _builder.append("\'inline_usage\' => $options[\'inline_usage\']");
        _builder.newLine();
      }
    }
    return _builder;
  }
  
  private CharSequence _formType(final ArrayField it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      Boolean _targets = this._utils.targets(this.app, "1.5");
      boolean _not = (!(_targets).booleanValue());
      if (_not) {
        String _appNamespace = this._utils.appNamespace(this.app);
        _builder.append(_appNamespace);
        _builder.append("\\Form\\Type\\Field\\");
      }
    }
    _builder.append("Array");
    return _builder;
  }
  
  private CharSequence _additionalAttributes(final ArrayField it) {
    StringConcatenation _builder = new StringConcatenation();
    return _builder;
  }
  
  private CharSequence _formType(final DatetimeField it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      Boolean _targets = this._utils.targets(this.app, "1.5");
      boolean _not = (!(_targets).booleanValue());
      if (_not) {
        _builder.append(this.nsSymfonyFormType);
      }
    }
    _builder.append("DateTime");
    return _builder;
  }
  
  private CharSequence _formType(final DateField it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      Boolean _targets = this._utils.targets(this.app, "1.5");
      boolean _not = (!(_targets).booleanValue());
      if (_not) {
        _builder.append(this.nsSymfonyFormType);
      }
    }
    _builder.append("Date");
    return _builder;
  }
  
  private CharSequence _formType(final TimeField it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      Boolean _targets = this._utils.targets(this.app, "1.5");
      boolean _not = (!(_targets).booleanValue());
      if (_not) {
        _builder.append(this.nsSymfonyFormType);
      }
    }
    _builder.append("Time");
    return _builder;
  }
  
  private CharSequence _additionalAttributes(final AbstractDateField it) {
    StringConcatenation _builder = new StringConcatenation();
    return _builder;
  }
  
  private CharSequence _additionalOptions(final DatetimeField it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("\'empty_data\' => ");
    CharSequence _defaultData = this.defaultData(it);
    _builder.append(_defaultData);
    _builder.append(",");
    _builder.newLineIfNotEmpty();
    _builder.append("\'with_seconds\' => true,");
    _builder.newLine();
    _builder.append("\'date_widget\' => \'single_text\',");
    _builder.newLine();
    _builder.append("\'time_widget\' => \'single_text\'");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence _additionalOptions(final DateField it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("\'empty_data\' => ");
    CharSequence _defaultData = this.defaultData(it);
    _builder.append(_defaultData);
    _builder.append(",");
    _builder.newLineIfNotEmpty();
    _builder.append("\'widget\' => \'single_text\'");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence _defaultData(final DatetimeField it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      if ((((null != it.getDefaultValue()) && (!Objects.equal(it.getDefaultValue(), ""))) && (!Objects.equal(it.getDefaultValue(), "now")))) {
        _builder.append("\'");
        String _defaultValue = it.getDefaultValue();
        _builder.append(_defaultValue);
        _builder.append("\'");
      } else {
        boolean _isNullable = it.isNullable();
        if (_isNullable) {
          _builder.append("null");
        } else {
          _builder.append("date(\'Y-m-d H:i:s\')");
        }
      }
    }
    return _builder;
  }
  
  private CharSequence _defaultData(final DateField it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      if ((((null != it.getDefaultValue()) && (!Objects.equal(it.getDefaultValue(), ""))) && (!Objects.equal(it.getDefaultValue(), "now")))) {
        _builder.append("\'");
        String _defaultValue = it.getDefaultValue();
        _builder.append(_defaultValue);
        _builder.append("\'");
      } else {
        boolean _isNullable = it.isNullable();
        if (_isNullable) {
          _builder.append("null");
        } else {
          _builder.append("date(\'Y-m-d\')");
        }
      }
    }
    return _builder;
  }
  
  private CharSequence _additionalAttributes(final TimeField it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("\'maxlength\' => 8,");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence _additionalOptions(final TimeField it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("\'empty_data\' => \'");
    String _defaultValue = it.getDefaultValue();
    _builder.append(_defaultValue);
    _builder.append("\',");
    _builder.newLineIfNotEmpty();
    _builder.append("\'widget\' => \'single_text\'");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence addGeographicalFields(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Adds fields for coordinates.");
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
    _builder.append("public function addGeographicalFields(FormBuilderInterface $builder, array $options)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    {
      ArrayList<String> _newArrayList = CollectionLiterals.<String>newArrayList("latitude", "longitude");
      for(final String geoFieldName : _newArrayList) {
        _builder.append("    ");
        _builder.append("$builder->add(\'");
        _builder.append(geoFieldName, "    ");
        _builder.append("\', ");
        {
          Boolean _targets = this._utils.targets(this.app, "1.5");
          if ((_targets).booleanValue()) {
            _builder.append("GeoType::class");
          } else {
            _builder.append("\'");
            String _appNamespace = this._utils.appNamespace(this.app);
            _builder.append(_appNamespace, "    ");
            _builder.append("\\Form\\Type\\Field\\GeoType\'");
          }
        }
        _builder.append(", [");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("\'label\' => $this->__(\'");
        String _firstUpper = StringExtensions.toFirstUpper(geoFieldName);
        _builder.append(_firstUpper, "        ");
        _builder.append("\') . \':\',");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("\'attr\' => [");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("        ");
        _builder.append("\'class\' => \'validate-number\'");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("],");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("\'required\' => false");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("]);");
        _builder.newLine();
      }
    }
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence addAttributeFields(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Adds fields for attributes.");
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
    _builder.append("public function addAttributeFields(FormBuilderInterface $builder, array $options)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("foreach ($options[\'attributes\'] as $attributeName => $attributeValue) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$builder->add(\'attributes\' . $attributeName, ");
    {
      Boolean _targets = this._utils.targets(this.app, "1.5");
      if ((_targets).booleanValue()) {
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
    _builder.append("\'mapped\' => false,");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("\'label\' => $this->__($attributeName),");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("\'attr\' => [");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("\'maxlength\' => 255");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("],");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("\'data\' => $attributeValue,");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("\'required\' => false");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("]);");
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
    _builder.append("\'class\' => \'category-selector\'");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("],");
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
    _builder.append("\'entity\' => \'");
    String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital, "        ");
    _builder.append("Entity\',");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("\'entityCategoryClass\' => \'");
    String _appNamespace = this._utils.appNamespace(this.app);
    _builder.append(_appNamespace, "        ");
    _builder.append("\\Entity\\");
    String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital_1, "        ");
    _builder.append("CategoryEntity\'");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("]);");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence addIncomingRelationshipFields(final DataObject it) {
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
    {
      for(final JoinRelationship relation : this.incomingRelations) {
        _builder.append("    ");
        final boolean autoComplete = ((!Objects.equal(relation.getUseAutoCompletion(), RelationAutoCompletionUsage.NONE)) && (!Objects.equal(relation.getUseAutoCompletion(), RelationAutoCompletionUsage.ONLY_TARGET_SIDE)));
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        CharSequence _fieldImpl = this.fieldImpl(relation, Boolean.valueOf(false), Boolean.valueOf(autoComplete));
        _builder.append(_fieldImpl, "    ");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence addOutgoingRelationshipFields(final DataObject it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Adds fields for outgoing relationships.");
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
    _builder.append("public function addOutgoingRelationshipFields(FormBuilderInterface $builder, array $options)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    {
      for(final JoinRelationship relation : this.outgoingRelations) {
        _builder.append("    ");
        final boolean autoComplete = ((!Objects.equal(relation.getUseAutoCompletion(), RelationAutoCompletionUsage.NONE)) && (!Objects.equal(relation.getUseAutoCompletion(), RelationAutoCompletionUsage.ONLY_SOURCE_SIDE)));
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        CharSequence _fieldImpl = this.fieldImpl(relation, Boolean.valueOf(true), Boolean.valueOf(autoComplete));
        _builder.append(_fieldImpl, "    ");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence fieldImpl(final JoinRelationship it, final Boolean outgoing, final Boolean autoComplete) {
    StringConcatenation _builder = new StringConcatenation();
    final String aliasName = this._namingExtensions.getRelationAliasName(it, outgoing);
    _builder.newLineIfNotEmpty();
    DataObject _xifexpression = null;
    if ((outgoing).booleanValue()) {
      _xifexpression = it.getTarget();
    } else {
      _xifexpression = it.getSource();
    }
    final DataObject relatedEntity = _xifexpression;
    _builder.newLineIfNotEmpty();
    _builder.append("$queryBuilder = function(EntityRepository $er) {");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// select without joins");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $er->getListQueryBuilder(\'\', \'\', false);");
    _builder.newLine();
    _builder.append("};");
    _builder.newLine();
    {
      boolean _isOwnerPermission = ((Entity) relatedEntity).isOwnerPermission();
      if (_isOwnerPermission) {
        _builder.append("if (true === $options[\'filter_by_ownership\']) {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$queryBuilder = function(EntityRepository $er) {");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("// select without joins");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("$qb = $er->getListQueryBuilder(\'\', \'\', false);");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("$qb = $er->addCreatorFilter($qb);");
        _builder.newLine();
        _builder.newLine();
        _builder.append("        ");
        _builder.append("return $qb;");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("};");
        _builder.newLine();
        _builder.append("}");
        _builder.newLine();
      }
    }
    boolean _xifexpression_1 = false;
    if ((outgoing).booleanValue()) {
      _xifexpression_1 = it.isExpandedTarget();
    } else {
      _xifexpression_1 = it.isExpandedSource();
    }
    final boolean isExpanded = _xifexpression_1;
    _builder.newLineIfNotEmpty();
    _builder.append("$builder->add(\'");
    String _formatForCode = this._formattingExtensions.formatForCode(aliasName);
    _builder.append(_formatForCode);
    _builder.append("\', \'");
    CharSequence _formType = this.formType(it, autoComplete);
    _builder.append(_formType);
    _builder.append("Type\', [");
    _builder.newLineIfNotEmpty();
    {
      if ((autoComplete).booleanValue()) {
        _builder.append("    ");
        DataObject _xifexpression_2 = null;
        if ((outgoing).booleanValue()) {
          _xifexpression_2 = it.getSource();
        } else {
          _xifexpression_2 = it.getTarget();
        }
        boolean _isManySide = this._modelJoinExtensions.isManySide(it, (outgoing).booleanValue());
        Boolean _xifexpression_3 = null;
        boolean _isManyToMany = this.isManyToMany(it);
        boolean _not = (!_isManyToMany);
        if (_not) {
          _xifexpression_3 = outgoing;
        } else {
          _xifexpression_3 = Boolean.valueOf((!(outgoing).booleanValue()));
        }
        final String uniqueNameForJs = this._modelJoinExtensions.getUniqueRelationNameForJs(it, this.app, _xifexpression_2, Boolean.valueOf(_isManySide), _xifexpression_3, this._formattingExtensions.formatForCodeCapital(aliasName));
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("\'object_type\' => \'");
        String _formatForCode_1 = this._formattingExtensions.formatForCode(relatedEntity.getName());
        _builder.append(_formatForCode_1, "    ");
        _builder.append("\',");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("\'multiple\' => ");
        String _displayBool = this._formattingExtensions.displayBool(Boolean.valueOf(this._modelJoinExtensions.isManySide(it, (outgoing).booleanValue())));
        _builder.append(_displayBool, "    ");
        _builder.append(",");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("\'unique_name_for_js\' => \'");
        _builder.append(uniqueNameForJs, "    ");
        _builder.append("\',");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("\'allow_editing\' => ");
        int _editStageCode = this._controllerExtensions.getEditStageCode(it, Boolean.valueOf((!(outgoing).booleanValue())));
        String _displayBool_1 = this._formattingExtensions.displayBool(Boolean.valueOf((_editStageCode > 1)));
        _builder.append(_displayBool_1, "    ");
        _builder.append(",");
        _builder.newLineIfNotEmpty();
        {
          if (((outgoing).booleanValue() && it.isNullable())) {
            _builder.append("    ");
            _builder.append("\'required\' => false,");
            _builder.newLine();
          }
        }
      } else {
        _builder.append("    ");
        _builder.append("\'class\' => \'");
        String _appName = this._utils.appName(this.app);
        _builder.append(_appName, "    ");
        _builder.append(":");
        DataObject _xifexpression_4 = null;
        if ((outgoing).booleanValue()) {
          _xifexpression_4 = it.getTarget();
        } else {
          _xifexpression_4 = it.getSource();
        }
        String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(_xifexpression_4.getName());
        _builder.append(_formatForCodeCapital, "    ");
        _builder.append("Entity\',");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("\'choice_label\' => \'getTitleFromDisplayPattern\',");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("\'multiple\' => ");
        String _displayBool_2 = this._formattingExtensions.displayBool(Boolean.valueOf(this._modelJoinExtensions.isManySide(it, (outgoing).booleanValue())));
        _builder.append(_displayBool_2, "    ");
        _builder.append(",");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("\'expanded\' => ");
        String _displayBool_3 = this._formattingExtensions.displayBool(Boolean.valueOf(isExpanded));
        _builder.append(_displayBool_3, "    ");
        _builder.append(",");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("\'query_builder\' => $queryBuilder,");
        _builder.newLine();
        {
          boolean _isNullable = it.isNullable();
          if (_isNullable) {
            {
              boolean _isManySide_1 = this._modelJoinExtensions.isManySide(it, (outgoing).booleanValue());
              boolean _not_1 = (!_isManySide_1);
              if (_not_1) {
                _builder.append("    ");
                _builder.append("\'placeholder\' => $this->__(\'Please choose an option\'),");
                _builder.newLine();
              }
            }
            _builder.append("    ");
            _builder.append("\'required\' => false,");
            _builder.newLine();
          }
        }
      }
    }
    _builder.append("    ");
    _builder.append("\'label\' => $this->__(\'");
    String _formatForDisplayCapital = this._formattingExtensions.formatForDisplayCapital(aliasName);
    _builder.append(_formatForDisplayCapital, "    ");
    _builder.append("\'),");
    _builder.newLineIfNotEmpty();
    {
      if (((!(autoComplete).booleanValue()) && isExpanded)) {
        _builder.append("    ");
        _builder.append("\'label_attr\' => [");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("\'class\' => \'");
        {
          boolean _isManySide_2 = this._modelJoinExtensions.isManySide(it, (outgoing).booleanValue());
          if (_isManySide_2) {
            _builder.append("checkbox");
          } else {
            _builder.append("radio");
          }
        }
        _builder.append("-inline\'");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("],");
        _builder.newLine();
      }
    }
    _builder.append("    ");
    _builder.append("\'attr\' => [");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'title\' => $this->__(\'Choose the ");
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(aliasName);
    _builder.append(_formatForDisplay, "        ");
    _builder.append("\')");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("]");
    _builder.newLine();
    _builder.append("]);");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence formType(final JoinRelationship it, final Boolean autoComplete) {
    CharSequence _xifexpression = null;
    if ((autoComplete).booleanValue()) {
      StringConcatenation _builder = new StringConcatenation();
      String _appNamespace = this._utils.appNamespace(this.app);
      _builder.append(_appNamespace);
      _builder.append("\\Form\\Type\\Field\\AutoCompletionRelation");
      _xifexpression = _builder;
    } else {
      StringConcatenation _builder_1 = new StringConcatenation();
      _builder_1.append("Symfony\\Bridge\\Doctrine\\Form\\Type\\Entity");
      _xifexpression = _builder_1;
    }
    return _xifexpression;
  }
  
  private boolean isManyToMany(final JoinRelationship it) {
    boolean _switchResult = false;
    boolean _matched = false;
    if (it instanceof ManyToManyRelationship) {
      _matched=true;
      _switchResult = true;
    }
    if (!_matched) {
      _switchResult = false;
    }
    return _switchResult;
  }
  
  private CharSequence addReturnControlField(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Adds the return control field.");
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
    _builder.append("public function addReturnControlField(FormBuilderInterface $builder, array $options)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($options[\'mode\'] != \'create\') {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$builder->add(\'repeatCreation\', ");
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
    _builder.append("\'mapped\' => false,");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'label\' => $this->__(\'Create another item after save\'),");
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
  
  private CharSequence addAdditionalNotificationRemarksField(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Adds a field for additional notification remarks.");
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
    _builder.append("public function addAdditionalNotificationRemarksField(FormBuilderInterface $builder, array $options)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$helpText = \'\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($options[\'is_moderator\']");
    {
      EntityWorkflowType _workflow = it.getWorkflow();
      boolean _equals = Objects.equal(_workflow, EntityWorkflowType.ENTERPRISE);
      if (_equals) {
        _builder.append(" || $options[\'is_super_moderator\']");
      }
    }
    _builder.append(") {");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("$helpText = $this->__(\'These remarks (like a reason for deny) are not stored, but added to any notification emails send to the creator.\');");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("} elseif ($options[\'is_creator\']) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$helpText = $this->__(\'These remarks (like questions about conformance) are not stored, but added to any notification emails send to our moderators.\');");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$builder->add(\'additionalNotificationRemarks\', ");
    {
      Boolean _targets = this._utils.targets(this.app, "1.5");
      if ((_targets).booleanValue()) {
        _builder.append("TextareaType::class");
      } else {
        _builder.append("\'");
        _builder.append(this.nsSymfonyFormType, "    ");
        _builder.append("TextareaType\'");
      }
    }
    _builder.append(", [");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("\'mapped\' => false,");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'label\' => $this->__(\'Additional remarks\'),");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'label_attr\' => [");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("\'class\' => \'tooltips\',");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("\'title\' => $helpText");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("],");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'attr\' => [");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("\'title\' => $options[\'mode\'] == \'create\' ? $this->__(\'Enter any additions about your content\') : $this->__(\'Enter any additions about your changes\')");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("],");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'required\' => false,");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'help\' => $helpText");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("]);");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence addModerationFields(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Adds special fields for moderators.");
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
    _builder.append("public function addModerationFields(FormBuilderInterface $builder, array $options)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!$options[\'has_moderate_permission\']) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$builder->add(\'moderationSpecificCreator\', ");
    {
      Boolean _targets = this._utils.targets(this.app, "1.5");
      if ((_targets).booleanValue()) {
        _builder.append("UserType::class");
      } else {
        _builder.append("\'");
        String _appNamespace = this._utils.appNamespace(this.app);
        _builder.append(_appNamespace, "    ");
        _builder.append("\\Form\\Type\\Field\\UserType\'");
      }
    }
    _builder.append(", [");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("\'mapped\' => false,");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'label\' => $this->__(\'Creator\') . \':\',");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'attr\' => [");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("\'maxlength\' => 11,");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("\'class\' => \' validate-digits\',");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("\'title\' => $this->__(\'Here you can choose a user which will be set as creator\')");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("],");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'empty_data\' => 0,");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'required\' => false,");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'help\' => $this->__(\'Here you can choose a user which will be set as creator\')");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("]);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$builder->add(\'moderationSpecificCreationDate\', ");
    {
      Boolean _targets_1 = this._utils.targets(this.app, "1.5");
      if ((_targets_1).booleanValue()) {
        _builder.append("DateTimeType::class");
      } else {
        _builder.append("\'");
        _builder.append(this.nsSymfonyFormType, "    ");
        _builder.append("DateTimeType\'");
      }
    }
    _builder.append(", [");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("\'mapped\' => false,");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'label\' => $this->__(\'Creation date\') . \':\',");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'attr\' => [");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("\'class\' => \'\',");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("\'title\' => $this->__(\'Here you can choose a custom creation date\')");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("],");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'empty_data\' => \'\',");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'required\' => false,");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'with_seconds\' => true,");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'date_widget\' => \'single_text\',");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'time_widget\' => \'single_text\',");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'help\' => $this->__(\'Here you can choose a custom creation date\')");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("]);");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence addSubmitButtons(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Adds submit buttons.");
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
    _builder.append("public function addSubmitButtons(FormBuilderInterface $builder, array $options)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("foreach ($options[\'actions\'] as $action) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$builder->add($action[\'id\'], ");
    {
      Boolean _targets = this._utils.targets(this.app, "1.5");
      if ((_targets).booleanValue()) {
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
    _builder.append("\'label\' => ");
    {
      Boolean _targets_1 = this._utils.targets(this.app, "1.5");
      if ((_targets_1).booleanValue()) {
        _builder.append("$action[\'title\']");
      } else {
        _builder.append("$this->__(/** @Ignore */$action[\'title\'])");
      }
    }
    _builder.append(",");
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    _builder.append("\'icon\' => ($action[\'id\'] == \'delete\' ? \'fa-trash-o\' : \'\'),");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("\'attr\' => [");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("\'class\' => $action[\'buttonClass\']");
    {
      Boolean _targets_2 = this._utils.targets(this.app, "1.5");
      boolean _not = (!(_targets_2).booleanValue());
      if (_not) {
        _builder.append(",");
        _builder.newLineIfNotEmpty();
        _builder.append("                ");
        _builder.append("\'title\' => $this->__(/** @Ignore */$action[\'description\'])");
      }
    }
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    _builder.append("]");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("]);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$builder->add(\'reset\', ");
    {
      Boolean _targets_3 = this._utils.targets(this.app, "1.5");
      if ((_targets_3).booleanValue()) {
        _builder.append("ResetType::class");
      } else {
        _builder.append("\'");
        _builder.append(this.nsSymfonyFormType, "    ");
        _builder.append("ResetType\'");
      }
    }
    _builder.append(", [");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("\'label\' => $this->__(\'Reset\'),");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'icon\' => \'fa-refresh\',");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'attr\' => [");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("\'class\' => \'btn btn-default\',");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("\'formnovalidate\' => \'formnovalidate\'");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("]");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("]);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$builder->add(\'cancel\', ");
    {
      Boolean _targets_4 = this._utils.targets(this.app, "1.5");
      if ((_targets_4).booleanValue()) {
        _builder.append("SubmitType::class");
      } else {
        _builder.append("\'");
        _builder.append(this.nsSymfonyFormType, "    ");
        _builder.append("SubmitType\'");
      }
    }
    _builder.append(", [");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("\'label\' => $this->__(\'Cancel\'),");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'icon\' => \'fa-times\',");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'attr\' => [");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("\'class\' => \'btn btn-default\',");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("\'formnovalidate\' => \'formnovalidate\'");
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
  
  private CharSequence editTypeImpl(final DataObject it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("namespace ");
    String _appNamespace = this._utils.appNamespace(this.app);
    _builder.append(_appNamespace);
    _builder.append("\\Form\\Type;");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("use ");
    String _appNamespace_1 = this._utils.appNamespace(this.app);
    _builder.append(_appNamespace_1);
    _builder.append("\\Form\\Type\\Base\\Abstract");
    String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital);
    _builder.append("Type;");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* ");
    String _formatForDisplayCapital = this._formattingExtensions.formatForDisplayCapital(it.getName());
    _builder.append(_formatForDisplayCapital, " ");
    _builder.append(" editing form type implementation class.");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("class ");
    String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital_1);
    _builder.append("Type extends Abstract");
    String _formatForCodeCapital_2 = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital_2);
    _builder.append("Type");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// feel free to extend the ");
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(it.getName());
    _builder.append(_formatForDisplay, "    ");
    _builder.append(" editing form type class here");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private ArrayList<String> helpMessages(final DerivedField it) {
    if (it instanceof IntegerField) {
      return _helpMessages((IntegerField)it);
    } else if (it instanceof ListField) {
      return _helpMessages((ListField)it);
    } else if (it instanceof StringField) {
      return _helpMessages((StringField)it);
    } else if (it instanceof TextField) {
      return _helpMessages((TextField)it);
    } else if (it instanceof ArrayField) {
      return _helpMessages((ArrayField)it);
    } else if (it instanceof DecimalField) {
      return _helpMessages((DecimalField)it);
    } else if (it instanceof FloatField) {
      return _helpMessages((FloatField)it);
    } else if (it instanceof AbstractDateField) {
      return _helpMessages((AbstractDateField)it);
    } else if (it != null) {
      return _helpMessages(it);
    } else {
      throw new IllegalArgumentException("Unhandled parameter types: " +
        Arrays.<Object>asList(it).toString());
    }
  }
  
  private CharSequence formType(final DerivedField it) {
    if (it instanceof EmailField) {
      return _formType((EmailField)it);
    } else if (it instanceof IntegerField) {
      return _formType((IntegerField)it);
    } else if (it instanceof ListField) {
      return _formType((ListField)it);
    } else if (it instanceof StringField) {
      return _formType((StringField)it);
    } else if (it instanceof TextField) {
      return _formType((TextField)it);
    } else if (it instanceof UploadField) {
      return _formType((UploadField)it);
    } else if (it instanceof UrlField) {
      return _formType((UrlField)it);
    } else if (it instanceof UserField) {
      return _formType((UserField)it);
    } else if (it instanceof ArrayField) {
      return _formType((ArrayField)it);
    } else if (it instanceof DateField) {
      return _formType((DateField)it);
    } else if (it instanceof DatetimeField) {
      return _formType((DatetimeField)it);
    } else if (it instanceof DecimalField) {
      return _formType((DecimalField)it);
    } else if (it instanceof FloatField) {
      return _formType((FloatField)it);
    } else if (it instanceof TimeField) {
      return _formType((TimeField)it);
    } else if (it instanceof BooleanField) {
      return _formType((BooleanField)it);
    } else if (it != null) {
      return _formType(it);
    } else {
      throw new IllegalArgumentException("Unhandled parameter types: " +
        Arrays.<Object>asList(it).toString());
    }
  }
  
  private CharSequence titleAttribute(final DerivedField it) {
    if (it instanceof IntegerField) {
      return _titleAttribute((IntegerField)it);
    } else if (it instanceof ListField) {
      return _titleAttribute((ListField)it);
    } else if (it instanceof StringField) {
      return _titleAttribute((StringField)it);
    } else if (it instanceof BooleanField) {
      return _titleAttribute((BooleanField)it);
    } else if (it != null) {
      return _titleAttribute(it);
    } else {
      throw new IllegalArgumentException("Unhandled parameter types: " +
        Arrays.<Object>asList(it).toString());
    }
  }
  
  private CharSequence additionalAttributes(final DerivedField it) {
    if (it instanceof EmailField) {
      return _additionalAttributes((EmailField)it);
    } else if (it instanceof IntegerField) {
      return _additionalAttributes((IntegerField)it);
    } else if (it instanceof ListField) {
      return _additionalAttributes((ListField)it);
    } else if (it instanceof StringField) {
      return _additionalAttributes((StringField)it);
    } else if (it instanceof TextField) {
      return _additionalAttributes((TextField)it);
    } else if (it instanceof UploadField) {
      return _additionalAttributes((UploadField)it);
    } else if (it instanceof UrlField) {
      return _additionalAttributes((UrlField)it);
    } else if (it instanceof UserField) {
      return _additionalAttributes((UserField)it);
    } else if (it instanceof ArrayField) {
      return _additionalAttributes((ArrayField)it);
    } else if (it instanceof DecimalField) {
      return _additionalAttributes((DecimalField)it);
    } else if (it instanceof FloatField) {
      return _additionalAttributes((FloatField)it);
    } else if (it instanceof TimeField) {
      return _additionalAttributes((TimeField)it);
    } else if (it instanceof AbstractDateField) {
      return _additionalAttributes((AbstractDateField)it);
    } else if (it instanceof BooleanField) {
      return _additionalAttributes((BooleanField)it);
    } else if (it != null) {
      return _additionalAttributes(it);
    } else {
      throw new IllegalArgumentException("Unhandled parameter types: " +
        Arrays.<Object>asList(it).toString());
    }
  }
  
  private CharSequence requiredOption(final DerivedField it) {
    if (it instanceof UploadField) {
      return _requiredOption((UploadField)it);
    } else if (it != null) {
      return _requiredOption(it);
    } else {
      throw new IllegalArgumentException("Unhandled parameter types: " +
        Arrays.<Object>asList(it).toString());
    }
  }
  
  private CharSequence additionalOptions(final DerivedField it) {
    if (it instanceof IntegerField) {
      return _additionalOptions((IntegerField)it);
    } else if (it instanceof ListField) {
      return _additionalOptions((ListField)it);
    } else if (it instanceof StringField) {
      return _additionalOptions((StringField)it);
    } else if (it instanceof UploadField) {
      return _additionalOptions((UploadField)it);
    } else if (it instanceof UrlField) {
      return _additionalOptions((UrlField)it);
    } else if (it instanceof UserField) {
      return _additionalOptions((UserField)it);
    } else if (it instanceof DateField) {
      return _additionalOptions((DateField)it);
    } else if (it instanceof DatetimeField) {
      return _additionalOptions((DatetimeField)it);
    } else if (it instanceof DecimalField) {
      return _additionalOptions((DecimalField)it);
    } else if (it instanceof FloatField) {
      return _additionalOptions((FloatField)it);
    } else if (it instanceof TimeField) {
      return _additionalOptions((TimeField)it);
    } else if (it != null) {
      return _additionalOptions(it);
    } else {
      throw new IllegalArgumentException("Unhandled parameter types: " +
        Arrays.<Object>asList(it).toString());
    }
  }
  
  private CharSequence defaultData(final AbstractDateField it) {
    if (it instanceof DateField) {
      return _defaultData((DateField)it);
    } else if (it instanceof DatetimeField) {
      return _defaultData((DatetimeField)it);
    } else {
      throw new IllegalArgumentException("Unhandled parameter types: " +
        Arrays.<Object>asList(it).toString());
    }
  }
}
