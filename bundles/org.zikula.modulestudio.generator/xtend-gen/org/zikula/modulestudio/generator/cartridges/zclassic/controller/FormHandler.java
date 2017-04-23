package org.zikula.modulestudio.generator.cartridges.zclassic.controller;

import com.google.common.base.Objects;
import com.google.common.collect.Iterables;
import de.guite.modulestudio.metamodel.Application;
import de.guite.modulestudio.metamodel.ArrayField;
import de.guite.modulestudio.metamodel.DataObject;
import de.guite.modulestudio.metamodel.Entity;
import de.guite.modulestudio.metamodel.EntityWorkflowType;
import de.guite.modulestudio.metamodel.JoinRelationship;
import de.guite.modulestudio.metamodel.MappedSuperClass;
import de.guite.modulestudio.metamodel.NamedObject;
import java.util.Arrays;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.InputOutput;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.actionhandler.Locking;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.actionhandler.Redirect;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.actionhandler.RelationPresets;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.form.ArrayFieldTransformer;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.form.AutoCompletionRelationTransformer;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.form.ListFieldTransformer;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.form.TranslationListener;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.form.UploadFileTransformer;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.form.UserFieldTransformer;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.formtype.Config;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.formtype.DeleteEntity;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.formtype.EditEntity;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.formtype.field.ArrayType;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.formtype.field.AutoCompletionRelationType;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.formtype.field.ColourType;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.formtype.field.EntityTreeType;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.formtype.field.GeoType;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.formtype.field.MultiListType;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.formtype.field.TranslationType;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.formtype.field.UploadType;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.formtype.field.UserType;
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper;
import org.zikula.modulestudio.generator.extensions.ControllerExtensions;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;
import org.zikula.modulestudio.generator.extensions.WorkflowExtensions;

@SuppressWarnings("all")
public class FormHandler {
  @Extension
  private ControllerExtensions _controllerExtensions = new ControllerExtensions();
  
  @Extension
  private FormattingExtensions _formattingExtensions = new FormattingExtensions();
  
  @Extension
  private ModelExtensions _modelExtensions = new ModelExtensions();
  
  @Extension
  private ModelBehaviourExtensions _modelBehaviourExtensions = new ModelBehaviourExtensions();
  
  @Extension
  private ModelJoinExtensions _modelJoinExtensions = new ModelJoinExtensions();
  
  @Extension
  private NamingExtensions _namingExtensions = new NamingExtensions();
  
  @Extension
  private Utils _utils = new Utils();
  
  @Extension
  private WorkflowExtensions _workflowExtensions = new WorkflowExtensions();
  
  private FileHelper fh = new FileHelper();
  
  private Redirect redirectHelper = new Redirect();
  
  private RelationPresets relationPresetsHelper = new RelationPresets();
  
  private Locking locking = new Locking();
  
  private Application app;
  
  /**
   * Entry point for Form handler classes.
   */
  public void generate(final Application it, final IFileSystemAccess fsa) {
    this.app = it;
    boolean _hasEditActions = this._controllerExtensions.hasEditActions(it);
    if (_hasEditActions) {
      this.generateCommon(it, "edit", fsa);
      final Function1<Entity, Boolean> _function = (Entity it_1) -> {
        return Boolean.valueOf(this._controllerExtensions.hasEditAction(it_1));
      };
      Iterable<Entity> _filter = IterableExtensions.<Entity>filter(this._modelExtensions.getAllEntities(it), _function);
      for (final Entity entity : _filter) {
        this.generate(entity, "edit", fsa);
      }
      final Function1<DataObject, Boolean> _function_1 = (DataObject e) -> {
        return Boolean.valueOf(((e instanceof MappedSuperClass) || this._controllerExtensions.hasEditAction(((Entity) e))));
      };
      Iterable<DataObject> _filter_1 = IterableExtensions.<DataObject>filter(it.getEntities(), _function_1);
      for (final DataObject entity_1 : _filter_1) {
        new EditEntity().generate(entity_1, fsa);
      }
      final Function1<DataObject, Boolean> _function_2 = (DataObject e) -> {
        boolean _isEmpty = IterableExtensions.isEmpty(Iterables.<ArrayField>filter(e.getFields(), ArrayField.class));
        return Boolean.valueOf((!_isEmpty));
      };
      boolean _isEmpty = IterableExtensions.isEmpty(IterableExtensions.<DataObject>filter(it.getEntities(), _function_2));
      boolean _not = (!_isEmpty);
      if (_not) {
        new ArrayType().generate(it, fsa);
        new ArrayFieldTransformer().generate(it, fsa);
      }
      boolean _hasColourFields = this._modelExtensions.hasColourFields(it);
      if (_hasColourFields) {
        new ColourType().generate(it, fsa);
      }
      boolean _hasGeographical = this._modelBehaviourExtensions.hasGeographical(it);
      if (_hasGeographical) {
        new GeoType().generate(it, fsa);
      }
      boolean _hasTrees = this._modelBehaviourExtensions.hasTrees(it);
      if (_hasTrees) {
        new EntityTreeType().generate(it, fsa);
      }
      boolean _hasUploads = this._modelExtensions.hasUploads(it);
      if (_hasUploads) {
        new UploadType().generate(it, fsa);
        new UploadFileTransformer().generate(it, fsa);
      }
      boolean _needsUserAutoCompletion = this._modelBehaviourExtensions.needsUserAutoCompletion(it);
      if (_needsUserAutoCompletion) {
        new UserType().generate(it, fsa);
        new UserFieldTransformer().generate(it, fsa);
      }
      boolean _hasMultiListFields = this._modelExtensions.hasMultiListFields(it);
      if (_hasMultiListFields) {
        new MultiListType().generate(it, fsa);
        new ListFieldTransformer().generate(it, fsa);
      }
      boolean _needsAutoCompletion = this._modelJoinExtensions.needsAutoCompletion(it);
      if (_needsAutoCompletion) {
        new AutoCompletionRelationType().generate(it, fsa);
        new AutoCompletionRelationTransformer().generate(it, fsa);
      }
      boolean _hasTranslatable = this._modelBehaviourExtensions.hasTranslatable(it);
      if (_hasTranslatable) {
        new TranslationType().generate(it, fsa);
        new TranslationListener().generate(it, fsa);
      }
    }
    new DeleteEntity().generate(it, fsa);
    new Config().generate(it, fsa);
  }
  
  /**
   * Entry point for generic Form handler base classes.
   */
  private void generateCommon(final Application it, final String actionName, final IFileSystemAccess fsa) {
    String _name = it.getName();
    String _plus = ("Generating \"" + _name);
    String _plus_1 = (_plus + "\" form handler base class");
    InputOutput.<String>println(_plus_1);
    String _appSourceLibPath = this._namingExtensions.getAppSourceLibPath(it);
    final String formHandlerFolder = (_appSourceLibPath + "Form/Handler/Common/");
    String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(actionName);
    String _plus_2 = (formHandlerFolder + _formatForCodeCapital);
    String _plus_3 = (_plus_2 + "Handler.php");
    this._namingExtensions.generateClassPair(it, fsa, _plus_3, 
      this.fh.phpFileContent(it, this.formHandlerCommonBaseImpl(it, actionName)), this.fh.phpFileContent(this.app, this.formHandlerCommonImpl(it, actionName)));
  }
  
  /**
   * Entry point for Form handler classes per entity.
   */
  private void generate(final Entity it, final String actionName, final IFileSystemAccess fsa) {
    String _name = it.getName();
    String _plus = ("Generating form handler classes for \"" + _name);
    String _plus_1 = (_plus + "_");
    String _plus_2 = (_plus_1 + actionName);
    String _plus_3 = (_plus_2 + "\"");
    InputOutput.<String>println(_plus_3);
    String _appSourceLibPath = this._namingExtensions.getAppSourceLibPath(this.app);
    String _plus_4 = (_appSourceLibPath + "Form/Handler/");
    String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(it.getName());
    String _plus_5 = (_plus_4 + _formatForCodeCapital);
    final String formHandlerFolder = (_plus_5 + "/");
    String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(actionName);
    String _plus_6 = (formHandlerFolder + _formatForCodeCapital_1);
    String _plus_7 = (_plus_6 + "Handler.php");
    this._namingExtensions.generateClassPair(this.app, fsa, _plus_7, 
      this.fh.phpFileContent(this.app, this.formHandlerBaseImpl(it, actionName)), this.fh.phpFileContent(this.app, this.formHandlerImpl(it, actionName)));
  }
  
  private CharSequence formHandlerCommonBaseImpl(final Application it, final String actionName) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("namespace ");
    String _appNamespace = this._utils.appNamespace(it);
    _builder.append(_appNamespace);
    _builder.append("\\Form\\Handler\\Common\\Base;");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("use Psr\\Log\\LoggerInterface;");
    _builder.newLine();
    _builder.append("use RuntimeException;");
    _builder.newLine();
    _builder.append("use Symfony\\Component\\Form\\AbstractType;");
    _builder.newLine();
    _builder.append("use Symfony\\Component\\Form\\FormFactoryInterface;");
    _builder.newLine();
    _builder.append("use Symfony\\Component\\HttpFoundation\\RedirectResponse;");
    _builder.newLine();
    _builder.append("use Symfony\\Component\\HttpFoundation\\Request;");
    _builder.newLine();
    _builder.append("use Symfony\\Component\\HttpFoundation\\RequestStack;");
    _builder.newLine();
    _builder.append("use Symfony\\Component\\Routing\\RouterInterface;");
    _builder.newLine();
    _builder.append("use Symfony\\Component\\Security\\Core\\Exception\\AccessDeniedException;");
    _builder.newLine();
    _builder.append("use Zikula\\Bundle\\CoreBundle\\HttpKernel\\ZikulaHttpKernelInterface;");
    _builder.newLine();
    _builder.append("use Zikula\\Common\\Translator\\TranslatorInterface;");
    _builder.newLine();
    _builder.append("use Zikula\\Common\\Translator\\TranslatorTrait;");
    _builder.newLine();
    _builder.append("use Zikula\\Core\\Doctrine\\EntityAccess;");
    _builder.newLine();
    {
      boolean _hasHookSubscribers = this._modelExtensions.hasHookSubscribers(it);
      if (_hasHookSubscribers) {
        _builder.append("use Zikula\\Core\\RouteUrl;");
        _builder.newLine();
      }
    }
    {
      if ((this._modelBehaviourExtensions.hasTranslatable(it) || this._workflowExtensions.needsApproval(it))) {
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
      }
    }
    {
      boolean _needsApproval = this._workflowExtensions.needsApproval(it);
      if (_needsApproval) {
        _builder.append("use Zikula\\GroupsModule\\Entity\\Repository\\GroupApplicationRepository;");
        _builder.newLine();
      }
    }
    _builder.append("use Zikula\\PageLockModule\\Api\\");
    {
      Boolean _targets_1 = this._utils.targets(it, "1.5");
      if ((_targets_1).booleanValue()) {
        _builder.append("ApiInterface\\LockingApiInterface");
      } else {
        _builder.append("LockingApi");
      }
    }
    _builder.append(";");
    _builder.newLineIfNotEmpty();
    _builder.append("use Zikula\\PermissionsModule\\Api\\");
    {
      Boolean _targets_2 = this._utils.targets(it, "1.5");
      if ((_targets_2).booleanValue()) {
        _builder.append("ApiInterface\\PermissionApiInterface");
      } else {
        _builder.append("PermissionApi");
      }
    }
    _builder.append(";");
    _builder.newLineIfNotEmpty();
    _builder.append("use Zikula\\UsersModule\\Api\\");
    {
      Boolean _targets_3 = this._utils.targets(it, "1.5");
      if ((_targets_3).booleanValue()) {
        _builder.append("ApiInterface\\CurrentUserApiInterface");
      } else {
        _builder.append("CurrentUserApi");
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
    {
      boolean _needsFeatureActivationHelper = this._modelBehaviourExtensions.needsFeatureActivationHelper(it);
      if (_needsFeatureActivationHelper) {
        _builder.append("use ");
        String _appNamespace_2 = this._utils.appNamespace(it);
        _builder.append(_appNamespace_2);
        _builder.append("\\Helper\\FeatureActivationHelper;");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("use ");
    String _appNamespace_3 = this._utils.appNamespace(it);
    _builder.append(_appNamespace_3);
    _builder.append("\\Helper\\ControllerHelper;");
    _builder.newLineIfNotEmpty();
    {
      boolean _hasHookSubscribers_1 = this._modelExtensions.hasHookSubscribers(it);
      if (_hasHookSubscribers_1) {
        _builder.append("use ");
        String _appNamespace_4 = this._utils.appNamespace(it);
        _builder.append(_appNamespace_4);
        _builder.append("\\Helper\\HookHelper;");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("use ");
    String _appNamespace_5 = this._utils.appNamespace(it);
    _builder.append(_appNamespace_5);
    _builder.append("\\Helper\\ModelHelper;");
    _builder.newLineIfNotEmpty();
    {
      boolean _hasTranslatable = this._modelBehaviourExtensions.hasTranslatable(it);
      if (_hasTranslatable) {
        _builder.append("use ");
        String _appNamespace_6 = this._utils.appNamespace(it);
        _builder.append(_appNamespace_6);
        _builder.append("\\Helper\\TranslatableHelper;");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("use ");
    String _appNamespace_7 = this._utils.appNamespace(it);
    _builder.append(_appNamespace_7);
    _builder.append("\\Helper\\WorkflowHelper;");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* This handler class handles the page events of editing forms.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* It collects common functionality required by different object types.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("abstract class Abstract");
    String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(actionName);
    _builder.append(_formatForCodeCapital_1);
    _builder.append("Handler");
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
    _builder.append("* Name of treated object type.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @var string");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("protected $objectType;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* Name of treated object type starting with upper case.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @var string");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("protected $objectTypeCapital;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* Lower case version.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @var string");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("protected $objectTypeLower;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* Permission component based on object type.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @var string");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("protected $permissionComponent;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* Reference to treated entity instance.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @var EntityAccess");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("protected $entityRef = null;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* List of identifier names.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @var array");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("protected $idFields = [];");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* List of identifiers of treated entity.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @var array");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("protected $idValues = [];");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* Code defining the redirect goal after command handling.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @var string");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("protected $returnTo = null;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* Whether a create action is going to be repeated or not.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @var boolean");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("protected $repeatCreateAction = false;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* Url of current form with all parameters for multiple creations.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @var string");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("protected $repeatReturnUrl = null;");
    _builder.newLine();
    {
      boolean _isEmpty = IterableExtensions.isEmpty(Iterables.<JoinRelationship>filter(it.getRelations(), JoinRelationship.class));
      boolean _not = (!_isEmpty);
      if (_not) {
        _builder.append("    ");
        CharSequence _memberFields = this.relationPresetsHelper.memberFields(it);
        _builder.append(_memberFields, "    ");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("/**");
        _builder.newLine();
        _builder.append("    ");
        _builder.append(" ");
        _builder.append("* Full prefix for related items.");
        _builder.newLine();
        _builder.append("    ");
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append("    ");
        _builder.append(" ");
        _builder.append("* @var string");
        _builder.newLine();
        _builder.append("    ");
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("protected $idPrefix = \'\';");
        _builder.newLine();
      }
    }
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* Whether an existing item is used as template for a new one.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @var boolean");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("protected $hasTemplateId = false;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    CharSequence _memberVars = this.locking.memberVars();
    _builder.append(_memberVars, "    ");
    _builder.newLineIfNotEmpty();
    {
      boolean _hasAttributableEntities = this._modelBehaviourExtensions.hasAttributableEntities(it);
      if (_hasAttributableEntities) {
        _builder.newLine();
        _builder.append("    ");
        _builder.append("/**");
        _builder.newLine();
        _builder.append("    ");
        _builder.append(" ");
        _builder.append("* Whether the entity has attributes or not.");
        _builder.newLine();
        _builder.append("    ");
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append("    ");
        _builder.append(" ");
        _builder.append("* @var boolean");
        _builder.newLine();
        _builder.append("    ");
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("protected $hasAttributes = false;");
        _builder.newLine();
      }
    }
    {
      if ((this._modelBehaviourExtensions.hasSluggable(it) && (!IterableExtensions.isEmpty(IterableExtensions.<Entity>filter(this._modelExtensions.getAllEntities(it), ((Function1<Entity, Boolean>) (Entity it_1) -> {
        return Boolean.valueOf(it_1.isSlugUpdatable());
      })))))) {
        _builder.newLine();
        _builder.append("    ");
        _builder.append("/**");
        _builder.newLine();
        _builder.append("    ");
        _builder.append(" ");
        _builder.append("* Whether the entity has an editable slug or not.");
        _builder.newLine();
        _builder.append("    ");
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append("    ");
        _builder.append(" ");
        _builder.append("* @var boolean");
        _builder.newLine();
        _builder.append("    ");
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("protected $hasSlugUpdatableField = false;");
        _builder.newLine();
      }
    }
    {
      boolean _hasTranslatable_1 = this._modelBehaviourExtensions.hasTranslatable(it);
      if (_hasTranslatable_1) {
        _builder.newLine();
        _builder.append("    ");
        _builder.append("/**");
        _builder.newLine();
        _builder.append("    ");
        _builder.append(" ");
        _builder.append("* Whether the entity has translatable fields or not.");
        _builder.newLine();
        _builder.append("    ");
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append("    ");
        _builder.append(" ");
        _builder.append("* @var boolean");
        _builder.newLine();
        _builder.append("    ");
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("protected $hasTranslatableFields = false;");
        _builder.newLine();
      }
    }
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @var ZikulaHttpKernelInterface");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("protected $kernel;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @var FormFactoryInterface");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("protected $formFactory;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* The current request.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*");
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
    _builder.append("* The router.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @var RouterInterface");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("protected $router;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @var LoggerInterface");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("protected $logger;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @var PermissionApi");
    {
      Boolean _targets_4 = this._utils.targets(it, "1.5");
      if ((_targets_4).booleanValue()) {
        _builder.append("Interface");
      }
    }
    _builder.newLineIfNotEmpty();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("protected $permissionApi;");
    _builder.newLine();
    _builder.newLine();
    {
      if ((this._modelBehaviourExtensions.hasTranslatable(it) || this._workflowExtensions.needsApproval(it))) {
        _builder.append("    ");
        _builder.append("/**");
        _builder.newLine();
        _builder.append("    ");
        _builder.append(" ");
        _builder.append("* @var VariableApi");
        {
          Boolean _targets_5 = this._utils.targets(it, "1.5");
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
        _builder.append("protected $variableApi;");
        _builder.newLine();
        _builder.newLine();
      }
    }
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @var CurrentUserApi");
    {
      Boolean _targets_6 = this._utils.targets(it, "1.5");
      if ((_targets_6).booleanValue()) {
        _builder.append("Interface");
      }
    }
    _builder.newLineIfNotEmpty();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("protected $currentUserApi;");
    _builder.newLine();
    _builder.newLine();
    {
      boolean _needsApproval_1 = this._workflowExtensions.needsApproval(it);
      if (_needsApproval_1) {
        _builder.append("    ");
        _builder.append("/**");
        _builder.newLine();
        _builder.append("    ");
        _builder.append(" ");
        _builder.append("* @var GroupApplicationRepository");
        _builder.newLine();
        _builder.append("    ");
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("protected $groupApplicationRepository;");
        _builder.newLine();
        _builder.newLine();
      }
    }
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @var ");
    String _formatForCodeCapital_2 = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital_2, "     ");
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
    _builder.append("* @var ControllerHelper");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("protected $controllerHelper;");
    _builder.newLine();
    {
      boolean _hasHookSubscribers_2 = this._modelExtensions.hasHookSubscribers(it);
      if (_hasHookSubscribers_2) {
        _builder.newLine();
        _builder.append("    ");
        _builder.append("/**");
        _builder.newLine();
        _builder.append("    ");
        _builder.append(" ");
        _builder.append("* @var HookHelper");
        _builder.newLine();
        _builder.append("    ");
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("protected $hookHelper;");
        _builder.newLine();
      }
    }
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @var ModelHelper");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("protected $modelHelper;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @var WorkflowHelper");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("protected $workflowHelper;");
    _builder.newLine();
    {
      boolean _hasTranslatable_2 = this._modelBehaviourExtensions.hasTranslatable(it);
      if (_hasTranslatable_2) {
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
      boolean _needsFeatureActivationHelper_1 = this._modelBehaviourExtensions.needsFeatureActivationHelper(it);
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
    _builder.append("* Reference to optional locking api.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @var LockingApi");
    {
      Boolean _targets_7 = this._utils.targets(it, "1.5");
      if ((_targets_7).booleanValue()) {
        _builder.append("Interface");
      }
    }
    _builder.newLineIfNotEmpty();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("protected $lockingApi = null;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* The handled form type.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @var AbstractType");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("protected $form;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* Template parameters.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @var array");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("protected $templateParameters = [];");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* ");
    String _formatForCodeCapital_3 = this._formattingExtensions.formatForCodeCapital(actionName);
    _builder.append(_formatForCodeCapital_3, "     ");
    _builder.append("Handler constructor.");
    _builder.newLineIfNotEmpty();
    _builder.append("     ");
    _builder.append("*");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @param ZikulaHttpKernelInterface $kernel           Kernel service instance");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @param TranslatorInterface       $translator       Translator service instance");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @param FormFactoryInterface      $formFactory      FormFactory service instance");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @param RequestStack              $requestStack     RequestStack service instance");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @param RouterInterface           $router           Router service instance");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @param LoggerInterface           $logger           Logger service instance");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @param PermissionApi");
    {
      Boolean _targets_8 = this._utils.targets(it, "1.5");
      if ((_targets_8).booleanValue()) {
        _builder.append("Interface");
      }
    }
    _builder.append("             $permissionApi    PermissionApi service instance");
    _builder.newLineIfNotEmpty();
    {
      if ((this._modelBehaviourExtensions.hasTranslatable(it) || this._workflowExtensions.needsApproval(it))) {
        _builder.append("     ");
        _builder.append("* @param VariableApi");
        {
          Boolean _targets_9 = this._utils.targets(it, "1.5");
          if ((_targets_9).booleanValue()) {
            _builder.append("Interface");
          } else {
            _builder.append("         ");
          }
        }
        _builder.append("      $variableApi      VariableApi service instance");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("     ");
    _builder.append("* @param CurrentUserApi");
    {
      Boolean _targets_10 = this._utils.targets(it, "1.5");
      if ((_targets_10).booleanValue()) {
        _builder.append("Interface");
      } else {
        _builder.append("         ");
      }
    }
    _builder.append("   $currentUserApi   CurrentUserApi service instance");
    _builder.newLineIfNotEmpty();
    {
      boolean _needsApproval_2 = this._workflowExtensions.needsApproval(it);
      if (_needsApproval_2) {
        _builder.append("     ");
        _builder.append("* @param GroupApplicationRepository $groupApplicationRepository GroupApplicationRepository service instance.");
        _builder.newLine();
      }
    }
    _builder.append("     ");
    _builder.append("* @param ");
    String _formatForCodeCapital_4 = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital_4, "     ");
    _builder.append("Factory $entityFactory ");
    String _formatForCodeCapital_5 = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital_5, "     ");
    _builder.append("Factory service instance");
    _builder.newLineIfNotEmpty();
    _builder.append("     ");
    _builder.append("* @param ControllerHelper          $controllerHelper ControllerHelper service instance");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @param ModelHelper               $modelHelper      ModelHelper service instance");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @param WorkflowHelper            $workflowHelper   WorkflowHelper service instance");
    _builder.newLine();
    {
      boolean _hasHookSubscribers_3 = this._modelExtensions.hasHookSubscribers(it);
      if (_hasHookSubscribers_3) {
        _builder.append("     ");
        _builder.append("* @param HookHelper                $hookHelper       HookHelper service instance");
        _builder.newLine();
      }
    }
    {
      boolean _hasTranslatable_3 = this._modelBehaviourExtensions.hasTranslatable(it);
      if (_hasTranslatable_3) {
        _builder.append("     ");
        _builder.append("* @param TranslatableHelper        $translatableHelper TranslatableHelper service instance");
        _builder.newLine();
      }
    }
    {
      boolean _needsFeatureActivationHelper_2 = this._modelBehaviourExtensions.needsFeatureActivationHelper(it);
      if (_needsFeatureActivationHelper_2) {
        _builder.append("     ");
        _builder.append("* @param FeatureActivationHelper   $featureActivationHelper FeatureActivationHelper service instance");
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
    _builder.append("ZikulaHttpKernelInterface $kernel,");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("TranslatorInterface $translator,");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("FormFactoryInterface $formFactory,");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("RequestStack $requestStack,");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("RouterInterface $router,");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("LoggerInterface $logger,");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("PermissionApi");
    {
      Boolean _targets_11 = this._utils.targets(it, "1.5");
      if ((_targets_11).booleanValue()) {
        _builder.append("Interface");
      }
    }
    _builder.append(" $permissionApi,");
    _builder.newLineIfNotEmpty();
    {
      if ((this._modelBehaviourExtensions.hasTranslatable(it) || this._workflowExtensions.needsApproval(it))) {
        _builder.append("        ");
        _builder.append("VariableApi");
        {
          Boolean _targets_12 = this._utils.targets(it, "1.5");
          if ((_targets_12).booleanValue()) {
            _builder.append("Interface");
          }
        }
        _builder.append(" $variableApi,");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("        ");
    _builder.append("CurrentUserApi");
    {
      Boolean _targets_13 = this._utils.targets(it, "1.5");
      if ((_targets_13).booleanValue()) {
        _builder.append("Interface");
      }
    }
    _builder.append(" $currentUserApi,");
    _builder.newLineIfNotEmpty();
    {
      boolean _needsApproval_3 = this._workflowExtensions.needsApproval(it);
      if (_needsApproval_3) {
        _builder.append("        ");
        _builder.append("GroupApplicationRepository $groupApplicationRepository,");
        _builder.newLine();
      }
    }
    _builder.append("        ");
    String _formatForCodeCapital_6 = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital_6, "        ");
    _builder.append("Factory $entityFactory,");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("ControllerHelper $controllerHelper,");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("ModelHelper $modelHelper,");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("WorkflowHelper $workflowHelper");
    {
      boolean _hasHookSubscribers_4 = this._modelExtensions.hasHookSubscribers(it);
      if (_hasHookSubscribers_4) {
        _builder.append(",");
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        _builder.append("HookHelper $hookHelper");
      }
    }
    {
      boolean _hasTranslatable_4 = this._modelBehaviourExtensions.hasTranslatable(it);
      if (_hasTranslatable_4) {
        _builder.append(",");
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        _builder.append("TranslatableHelper $translatableHelper");
      }
    }
    {
      boolean _needsFeatureActivationHelper_3 = this._modelBehaviourExtensions.needsFeatureActivationHelper(it);
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
    _builder.append("$this->kernel = $kernel;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$this->setTranslator($translator);");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$this->formFactory = $formFactory;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$this->request = $requestStack->getCurrentRequest();");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$this->router = $router;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$this->logger = $logger;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$this->permissionApi = $permissionApi;");
    _builder.newLine();
    {
      if ((this._modelBehaviourExtensions.hasTranslatable(it) || this._workflowExtensions.needsApproval(it))) {
        _builder.append("        ");
        _builder.append("$this->variableApi = $variableApi;");
        _builder.newLine();
      }
    }
    _builder.append("        ");
    _builder.append("$this->currentUserApi = $currentUserApi;");
    _builder.newLine();
    {
      boolean _needsApproval_4 = this._workflowExtensions.needsApproval(it);
      if (_needsApproval_4) {
        _builder.append("        ");
        _builder.append("$this->groupApplicationRepository = $groupApplicationRepository;");
        _builder.newLine();
      }
    }
    _builder.append("        ");
    _builder.append("$this->entityFactory = $entityFactory;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$this->controllerHelper = $controllerHelper;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$this->modelHelper = $modelHelper;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$this->workflowHelper = $workflowHelper;");
    _builder.newLine();
    {
      boolean _hasHookSubscribers_5 = this._modelExtensions.hasHookSubscribers(it);
      if (_hasHookSubscribers_5) {
        _builder.append("        ");
        _builder.append("$this->hookHelper = $hookHelper;");
        _builder.newLine();
      }
    }
    {
      boolean _hasTranslatable_5 = this._modelBehaviourExtensions.hasTranslatable(it);
      if (_hasTranslatable_5) {
        _builder.append("        ");
        _builder.append("$this->translatableHelper = $translatableHelper;");
        _builder.newLine();
      }
    }
    {
      boolean _needsFeatureActivationHelper_4 = this._modelBehaviourExtensions.needsFeatureActivationHelper(it);
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
    CharSequence _setTranslatorMethod = this._modelBehaviourExtensions.setTranslatorMethod(it);
    _builder.append(_setTranslatorMethod, "    ");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    CharSequence _processForm = this.processForm(it);
    _builder.append(_processForm, "    ");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    CharSequence _redirectCodes = this.redirectHelper.getRedirectCodes(it);
    _builder.append(_redirectCodes, "    ");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    CharSequence _handleCommand = this.handleCommand(it);
    _builder.append(_handleCommand, "    ");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    CharSequence _fetchInputData = this.fetchInputData(it);
    _builder.append(_fetchInputData, "    ");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    CharSequence _applyAction = this.applyAction(it);
    _builder.append(_applyAction, "    ");
    _builder.newLineIfNotEmpty();
    {
      boolean _needsApproval_5 = this._workflowExtensions.needsApproval(it);
      if (_needsApproval_5) {
        _builder.newLine();
        _builder.append("    ");
        CharSequence _prepareWorkflowAdditions = this.prepareWorkflowAdditions(it);
        _builder.append(_prepareWorkflowAdditions, "    ");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* Sets optional locking api reference.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @param LockingApi");
    {
      Boolean _targets_14 = this._utils.targets(it, "1.5");
      if ((_targets_14).booleanValue()) {
        _builder.append("Interface");
      }
    }
    _builder.append(" $lockingApi");
    _builder.newLineIfNotEmpty();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("public function setLockingApi(LockingApi");
    {
      Boolean _targets_15 = this._utils.targets(it, "1.5");
      if ((_targets_15).booleanValue()) {
        _builder.append("Interface");
      }
    }
    _builder.append(" $lockingApi)");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("{");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$this->lockingApi = $lockingApi;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence _processForm(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Initialise form handler.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* This method takes care of all necessary initialisation of our data and form states.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param array $templateParameters List of preassigned template variables");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return boolean False in case of initialisation errors, otherwise true");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @throws RuntimeException Thrown if the workflow actions can not be determined");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function processForm(array $templateParameters)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$this->templateParameters = $templateParameters;");
    _builder.newLine();
    {
      boolean _needsAutoCompletion = this._modelJoinExtensions.needsAutoCompletion(this.app);
      if (_needsAutoCompletion) {
        _builder.append("    ");
        _builder.append("$this->templateParameters[\'inlineUsage\'] = $this->request->query->getBoolean(\'raw\', false);");
        _builder.newLine();
      }
    }
    {
      boolean _isEmpty = IterableExtensions.isEmpty(Iterables.<JoinRelationship>filter(it.getRelations(), JoinRelationship.class));
      boolean _not = (!_isEmpty);
      if (_not) {
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$this->idPrefix = $this->request->query->get(\'idp\', \'\');");
        _builder.newLine();
      }
    }
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// initialise redirect goal");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$this->returnTo = $this->request->query->get(\'returnTo\', null);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// default to referer");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$refererSessionVar = \'");
    String _formatForDB = this._formattingExtensions.formatForDB(this._utils.appName(it));
    _builder.append(_formatForDB, "    ");
    _builder.append("\' . $this->objectTypeCapital . \'Referer\';");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("if (null === $this->returnTo && $this->request->headers->has(\'referer\')) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$currentReferer = $this->request->headers->get(\'referer\');");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if ($currentReferer != $this->request->getUri()) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$this->returnTo = $currentReferer;");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$this->request->getSession()->set($refererSessionVar, $this->returnTo);");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (null === $this->returnTo && $this->request->getSession()->has($refererSessionVar)) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$this->returnTo = $this->request->getSession()->get($refererSessionVar);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// store current uri for repeated creations");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$this->repeatReturnUrl = $this->request->getSchemeAndHttpHost() . $this->request->getBasePath() . $this->request->getPathInfo();");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$this->permissionComponent = \'");
    String _appName = this._utils.appName(it);
    _builder.append(_appName, "    ");
    _builder.append(":\' . $this->objectTypeCapital . \':\';");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$this->idFields = $this->entityFactory->getIdFields($this->objectType);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// retrieve identifier of the object we wish to edit");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$this->idValues = $this->controllerHelper->retrieveIdentifier($this->request, [], $this->objectType);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$hasIdentifier = $this->controllerHelper->isValidIdentifier($this->idValues);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$entity = null;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$this->templateParameters[\'mode\'] = $hasIdentifier ? \'edit\' : \'create\';");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($this->templateParameters[\'mode\'] == \'edit\') {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if (!$this->permissionApi->hasPermission($this->permissionComponent, $this->createCompositeIdentifier() . \'::\', ACCESS_EDIT)) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("throw new AccessDeniedException();");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$entity = $this->initEntityForEditing();");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if (null !== $entity) {");
    _builder.newLine();
    _builder.append("            ");
    CharSequence _addPageLock = this.locking.addPageLock(it);
    _builder.append(_addPageLock, "            ");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("} else {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if (!$this->permissionApi->hasPermission($this->permissionComponent, \'::\', ACCESS_EDIT)) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("throw new AccessDeniedException();");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$entity = $this->initEntityForCreation();");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// set default values from request parameters");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("foreach ($this->request->query->all() as $key => $value) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("if (strlen($key) < 5 || substr($key, 0, 4) != \'set_\') {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("continue;");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$fieldName = str_replace(\'set_\', \'\', $key);");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$setterName = \'set\' . ucfirst($fieldName);");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("if (!method_exists($entity, $setterName)) {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("continue;");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$entity[$fieldName] = $value;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (null === $entity) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$this->request->getSession()->getFlashBag()->add(\'error\', $this->__(\'No such item found.\'));");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return new RedirectResponse($this->getRedirectUrl([\'commandName\' => \'cancel\']), 302);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// save entity reference for later reuse");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$this->entityRef = $entity;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    CharSequence _initialiseExtensions = this.initialiseExtensions(it);
    _builder.append(_initialiseExtensions, "    ");
    _builder.newLineIfNotEmpty();
    {
      boolean _isEmpty_1 = IterableExtensions.isEmpty(Iterables.<JoinRelationship>filter(it.getRelations(), JoinRelationship.class));
      boolean _not_1 = (!_isEmpty_1);
      if (_not_1) {
        _builder.append("    ");
        CharSequence _callBaseMethod = this.relationPresetsHelper.callBaseMethod(it);
        _builder.append(_callBaseMethod, "    ");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$actions = $this->workflowHelper->getActionsForObject($entity);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (false === $actions || !is_array($actions)) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$this->request->getSession()->getFlashBag()->add(\'error\', $this->__(\'Error! Could not determine workflow actions.\'));");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$logArgs = [\'app\' => \'");
    String _appName_1 = this._utils.appName(it);
    _builder.append(_appName_1, "        ");
    _builder.append("\', \'user\' => $this->currentUserApi->get(\'uname\'), \'entity\' => $this->objectType, \'id\' => $entity->createCompositeIdentifier()];");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("$this->logger->error(\'{app}: User {user} tried to edit the {entity} with id {id}, but failed to determine available workflow actions.\', $logArgs);");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("throw new \\RuntimeException($this->__(\'Error! Could not determine workflow actions.\'));");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$this->templateParameters[\'actions\'] = $actions;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$this->form = $this->createForm();");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!is_object($this->form)) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return false;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// handle form request and check validity constraints of edited entity");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($this->form->handleRequest($this->request) && $this->form->isSubmitted()) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if ($this->form->isValid()) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$result = $this->handleCommand();");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("if (false === $result) {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("$this->templateParameters[\'form\'] = $this->form->createView();");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("            ");
    _builder.append("return $result;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if ($this->form->get(\'cancel\')->isClicked()) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("return new RedirectResponse($this->getRedirectUrl([\'commandName\' => \'cancel\']), 302);");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$this->templateParameters[\'form\'] = $this->form->createView();");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// everything okay, no initialisation errors occured");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return true;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Creates the form type.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected function createForm()");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// to be customised in sub classes");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return null;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    {
      boolean _isEmpty_2 = IterableExtensions.isEmpty(Iterables.<JoinRelationship>filter(it.getRelations(), JoinRelationship.class));
      boolean _not_2 = (!_isEmpty_2);
      if (_not_2) {
        _builder.newLine();
        CharSequence _baseMethod = this.relationPresetsHelper.baseMethod(it);
        _builder.append(_baseMethod);
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.newLine();
    CharSequence _terMethod = this.fh.getterMethod(it, "templateParameters", "array", Boolean.valueOf(true));
    _builder.append(_terMethod);
    _builder.newLineIfNotEmpty();
    CharSequence _createCompositeIdentifier = this.createCompositeIdentifier(it);
    _builder.append(_createCompositeIdentifier);
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    CharSequence _initEntityForEditing = this.initEntityForEditing(it);
    _builder.append(_initEntityForEditing);
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    CharSequence _initEntityForCreation = this.initEntityForCreation(it);
    _builder.append(_initEntityForCreation);
    _builder.newLineIfNotEmpty();
    CharSequence _initTranslationsForEditing = this.initTranslationsForEditing(it);
    _builder.append(_initTranslationsForEditing);
    _builder.newLineIfNotEmpty();
    CharSequence _initAttributesForEditing = this.initAttributesForEditing(it);
    _builder.append(_initAttributesForEditing);
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence initialiseExtensions(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _hasAttributableEntities = this._modelBehaviourExtensions.hasAttributableEntities(it);
      if (_hasAttributableEntities) {
        _builder.newLine();
        _builder.append("if (true === $this->hasAttributes) {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("if ($this->featureActivationHelper->isEnabled(FeatureActivationHelper::ATTRIBUTES, $this->objectType)) {");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("$this->initAttributesForEditing();");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
        _builder.append("}");
        _builder.newLine();
      }
    }
    {
      boolean _hasTranslatable = this._modelBehaviourExtensions.hasTranslatable(it);
      if (_hasTranslatable) {
        _builder.newLine();
        _builder.append("if (true === $this->hasTranslatableFields) {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$this->initTranslationsForEditing();");
        _builder.newLine();
        _builder.append("}");
        _builder.newLine();
      }
    }
    return _builder;
  }
  
  private CharSequence createCompositeIdentifier(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Create concatenated identifier string (for composite keys).");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return String concatenated identifiers");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected function createCompositeIdentifier()");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$itemId = \'\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($this->templateParameters[\'mode\'] == \'create\') {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return $itemId;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("foreach ($this->idFields as $idField) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if (!empty($itemId)) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$itemId .= \'_\';");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$itemId .= $this->idValues[$idField];");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $itemId;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence initEntityForEditing(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Initialise existing entity for editing.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return EntityAccess|null Desired entity instance or null");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected function initEntityForEditing()");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    {
      Boolean _targets = this._utils.targets(it, "1.5");
      boolean _not = (!(_targets).booleanValue());
      if (_not) {
        _builder.append("    ");
        _builder.append("$entity = $this->entityFactory->getRepository($this->objectType)->selectById($this->idValues);");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("if (null === $entity) {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("return null;");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$entity->initWorkflow();");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("return $entity;");
        _builder.newLine();
      } else {
        _builder.append("    ");
        _builder.append("return $this->entityFactory->getRepository($this->objectType)->selectById($this->idValues);");
        _builder.newLine();
      }
    }
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence initEntityForCreation(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Initialise new entity for creation.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return EntityAccess|null Desired entity instance or null");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected function initEntityForCreation()");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$this->hasTemplateId = false;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$templateId = $this->request->query->get(\'astemplate\', \'\');");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$entity = null;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!empty($templateId)) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$templateIdValueParts = explode(\'_\', $templateId);");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$this->hasTemplateId = count($templateIdValueParts) == count($this->idFields);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if (true === $this->hasTemplateId) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$templateIdValues = [];");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$i = 0;");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("foreach ($this->idFields as $idField) {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("$templateIdValues[$idField] = $templateIdValueParts[$i];");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("$i++;");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("// reuse existing entity");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$entityT = $this->entityFactory->getRepository($this->objectType)->selectById($templateIdValues);");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("if (null === $entityT) {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("return null;");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$entity = clone $entityT;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (null === $entity) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$createMethod = \'create\' . ucfirst($this->objectType);");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$entity = $this->entityFactory->$createMethod();");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $entity;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence initTranslationsForEditing(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _hasTranslatable = this._modelBehaviourExtensions.hasTranslatable(it);
      if (_hasTranslatable) {
        _builder.newLine();
        _builder.append("/**");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Initialise translations.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
        _builder.append("protected function initTranslationsForEditing()");
        _builder.newLine();
        _builder.append("{");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$translationsEnabled = $this->featureActivationHelper->isEnabled(FeatureActivationHelper::TRANSLATIONS, $this->objectType);");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$this->templateParameters[\'translationsEnabled\'] = $translationsEnabled;");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$supportedLanguages = $this->translatableHelper->getSupportedLanguages($this->objectType);");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("// assign list of installed languages for translatable extension");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$this->templateParameters[\'supportedLanguages\'] = $supportedLanguages;");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("if (!$translationsEnabled) {");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("return;");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("if ($this->variableApi->getSystemVar(\'multilingual\') != 1) {");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("$this->templateParameters[\'translationsEnabled\'] = false;");
        _builder.newLine();
        _builder.newLine();
        _builder.append("        ");
        _builder.append("return;");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("if (count($supportedLanguages) < 2) {");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("$this->templateParameters[\'translationsEnabled\'] = false;");
        _builder.newLine();
        _builder.newLine();
        _builder.append("        ");
        _builder.append("return;");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$mandatoryFieldsPerLocale = $this->translatableHelper->getMandatoryFields($this->objectType);");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$localesWithMandatoryFields = [];");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("foreach ($mandatoryFieldsPerLocale as $locale => $fields) {");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("if (count($fields) > 0) {");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("$localesWithMandatoryFields[] = $locale;");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("if (!in_array($this->translatableHelper->getCurrentLanguage(), $localesWithMandatoryFields)) {");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("$localesWithMandatoryFields[] = $this->translatableHelper->getCurrentLanguage();");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$this->templateParameters[\'localesWithMandatoryFields\'] = $localesWithMandatoryFields;");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("// retrieve and assign translated fields");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$translations = $this->translatableHelper->prepareEntityForEditing($this->entityRef);");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("foreach ($translations as $language => $translationData) {");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("$this->templateParameters[$this->objectTypeLower . $language] = $translationData;");
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
  
  private CharSequence initAttributesForEditing(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _hasAttributableEntities = this._modelBehaviourExtensions.hasAttributableEntities(it);
      if (_hasAttributableEntities) {
        _builder.newLine();
        _builder.append("/**");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Initialise attributes.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
        _builder.append("protected function initAttributesForEditing()");
        _builder.newLine();
        _builder.append("{");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$entity = $this->entityRef;");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$entityData = [];");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("// overwrite attributes array entry with a form compatible format");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$attributes = [];");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("foreach ($this->getAttributeFieldNames() as $fieldName) {");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("$attributes[$fieldName] = $entity->getAttributes()->get($fieldName) ? $entity->getAttributes()->get($fieldName)->getValue() : \'\';");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$entityData[\'attributes\'] = $attributes;");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$this->templateParameters[\'attributes\'] = $attributes;");
        _builder.newLine();
        _builder.append("}");
        _builder.newLine();
        _builder.newLine();
        _builder.append("/**");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Return list of attribute field names.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* To be customised in sub classes as needed.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @return array list of attribute names");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
        _builder.append("protected function getAttributeFieldNames()");
        _builder.newLine();
        _builder.append("{");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("return [");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("\'field1\', \'field2\', \'field3\'");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("];");
        _builder.newLine();
        _builder.append("}");
        _builder.newLine();
      }
    }
    return _builder;
  }
  
  private CharSequence _handleCommand(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Command event handler.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param array $args List of arguments");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return mixed Redirect or false on errors");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function handleCommand($args = [])");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// build $args for BC (e.g. used by redirect handling)");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("foreach ($this->templateParameters[\'actions\'] as $action) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if ($this->form->get($action[\'id\'])->isClicked()) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$args[\'commandName\'] = $action[\'id\'];");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($this->form->get(\'cancel\')->isClicked()) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$args[\'commandName\'] = \'cancel\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$action = $args[\'commandName\'];");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$isRegularAction = !in_array($action, [\'delete\', \'cancel\']);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($isRegularAction || $action == \'delete\') {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$this->fetchInputData($args);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// get treated entity reference from persisted member var");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$entity = $this->entityRef;");
    _builder.newLine();
    {
      boolean _hasHookSubscribers = this._modelExtensions.hasHookSubscribers(it);
      if (_hasHookSubscribers) {
        _builder.newLine();
        _builder.append("    ");
        _builder.append("if ($entity->supportsHookSubscribers() && $action != \'cancel\') {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("// Let any hooks perform additional validation actions");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("$hookType = $action == \'delete\' ? \'validate_delete\' : \'validate_edit\';");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("$validationHooksPassed = $this->hookHelper->callValidationHooks($entity, $hookType);");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("if (!$validationHooksPassed) {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("        ");
        _builder.append("return false;");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
      }
    }
    {
      boolean _hasTranslatable = this._modelBehaviourExtensions.hasTranslatable(it);
      if (_hasTranslatable) {
        _builder.newLine();
        _builder.append("    ");
        _builder.append("if ($isRegularAction && true === $this->hasTranslatableFields) {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("if ($this->featureActivationHelper->isEnabled(FeatureActivationHelper::TRANSLATIONS, $this->objectType)) {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("        ");
        _builder.append("$this->processTranslationsForUpdate();");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
      }
    }
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($isRegularAction || $action == \'delete\') {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$success = $this->applyAction($args);");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if (!$success) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("// the workflow operation failed");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("return false;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    {
      boolean _hasHookSubscribers_1 = this._modelExtensions.hasHookSubscribers(it);
      if (_hasHookSubscribers_1) {
        _builder.newLine();
        _builder.append("        ");
        _builder.append("if ($entity->supportsHookSubscribers()) {");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("// Let any hooks know that we have created, updated or deleted an item");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("$hookType = $action == \'delete\' ? \'process_delete\' : \'process_edit\';");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("$url = null;");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("if ($action != \'delete\') {");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("        ");
        _builder.append("$urlArgs = $entity->createUrlArgs();");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("        ");
        _builder.append("$urlArgs[\'_locale\'] = $this->request->getLocale();");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("        ");
        _builder.append("$url = new RouteUrl(\'");
        String _formatForDB = this._formattingExtensions.formatForDB(this._utils.appName(it));
        _builder.append(_formatForDB, "                ");
        _builder.append("_\' . $this->objectType . \'_display\', $urlArgs);");
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("$this->hookHelper->callProcessHooks($entity, $hookType, $url);");
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
    CharSequence _releasePageLock = this.locking.releasePageLock(it);
    _builder.append(_releasePageLock, "    ");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return new RedirectResponse($this->getRedirectUrl($args), 302);");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    {
      boolean _hasAttributableEntities = this._modelBehaviourExtensions.hasAttributableEntities(it);
      if (_hasAttributableEntities) {
        _builder.newLine();
        _builder.append("/**");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Prepare update of attributes.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
        _builder.append("protected function processAttributesForUpdate()");
        _builder.newLine();
        _builder.append("{");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$entity = $this->entityRef;");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("foreach ($this->getAttributeFieldNames() as $fieldName) {");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("$value = $this->form[\'attributes\' . $fieldName]->getData();");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("$entity->setAttribute($fieldName, $value);");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
        _builder.append("    ");
        _builder.newLine();
        _builder.append("}");
        _builder.newLine();
      }
    }
    {
      boolean _hasTranslatable_1 = this._modelBehaviourExtensions.hasTranslatable(it);
      if (_hasTranslatable_1) {
        _builder.newLine();
        _builder.append("/**");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Prepare update of translations.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
        _builder.append("protected function processTranslationsForUpdate()");
        _builder.newLine();
        _builder.append("{");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("if (!$this->templateParameters[\'translationsEnabled\']) {");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("return;");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("// persist translated fields");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$this->translatableHelper->processEntityAfterEditing($this->entityRef, $this->form, $this->entityFactory->getObjectManager());");
        _builder.newLine();
        _builder.append("}");
        _builder.newLine();
      }
    }
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Get success or error message for default operations.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param array   $args    arguments from handleCommand method");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param Boolean $success true if this is a success, false for default error");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return String desired status or error message");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected function getDefaultMessage($args, $success = false)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$message = \'\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("switch ($args[\'commandName\']) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("case \'create\':");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("if (true === $success) {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("$message = $this->__(\'Done! Item created.\');");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("} else {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("$message = $this->__(\'Error! Creation attempt failed.\');");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("break;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("case \'update\':");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("if (true === $success) {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("$message = $this->__(\'Done! Item updated.\');");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("} else {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("$message = $this->__(\'Error! Update attempt failed.\');");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("break;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("case \'delete\':");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("if (true === $success) {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("$message = $this->__(\'Done! Item deleted.\');");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("} else {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("$message = $this->__(\'Error! Deletion attempt failed.\');");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("break;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $message;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Add success or error message to session.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param array   $args    arguments from handleCommand method");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param Boolean $success true if this is a success, false for default error");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @throws RuntimeException Thrown if executing the workflow action fails");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected function addDefaultMessage($args, $success = false)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$message = $this->getDefaultMessage($args, $success);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (empty($message)) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$flashType = true === $success ? \'status\' : \'error\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$this->request->getSession()->getFlashBag()->add($flashType, $message);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$logArgs = [\'app\' => \'");
    String _appName = this._utils.appName(it);
    _builder.append(_appName, "    ");
    _builder.append("\', \'user\' => $this->currentUserApi->get(\'uname\'), \'entity\' => $this->objectType, \'id\' => $this->entityRef->createCompositeIdentifier()];");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("if (true === $success) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$this->logger->notice(\'{app}: User {user} updated the {entity} with id {id}.\', $logArgs);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("} else {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$this->logger->error(\'{app}: User {user} tried to update the {entity} with id {id}, but failed.\', $logArgs);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence fetchInputData(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Input data processing called by handleCommand method.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param array $args Additional arguments");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function fetchInputData($args)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// fetch posted data input values as an associative array");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$formData = $this->form->getData();");
    _builder.newLine();
    {
      if ((this._modelBehaviourExtensions.hasSluggable(it) && (!IterableExtensions.isEmpty(IterableExtensions.<Entity>filter(this._modelExtensions.getAllEntities(it), ((Function1<Entity, Boolean>) (Entity it_1) -> {
        return Boolean.valueOf(it_1.isSlugUpdatable());
      })))))) {
        _builder.newLine();
        _builder.append("    ");
        _builder.append("if ($args[\'commandName\'] != \'cancel\') {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("if (true === $this->hasSlugUpdatableField && isset($entityData[\'slug\'])) {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("        ");
        _builder.append("$entityData[\'slug\'] = $this->controllerHelper->formatPermalink($entityData[\'slug\']);");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
      }
    }
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($this->templateParameters[\'mode\'] == \'create\' && isset($this->form[\'repeatCreation\']) && $this->form[\'repeatCreation\']->getData() == 1) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$this->repeatCreateAction = true;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    {
      boolean _hasStandardFieldEntities = this._modelBehaviourExtensions.hasStandardFieldEntities(it);
      if (_hasStandardFieldEntities) {
        _builder.newLine();
        _builder.append("    ");
        _builder.append("if (method_exists($this->entityRef, \'getCreatedBy\')) {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("if (isset($this->form[\'moderationSpecificCreator\']) && null !== $this->form[\'moderationSpecificCreator\']->getData()) {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("        ");
        _builder.append("$this->entityRef->setCreatedBy($this->form[\'moderationSpecificCreator\']->getData());");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("if (isset($this->form[\'moderationSpecificCreationDate\']) && $this->form[\'moderationSpecificCreationDate\']->getData() != \'\') {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("        ");
        _builder.append("$this->entityRef->setCreatedDate($this->form[\'moderationSpecificCreationDate\']->getData());");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
      }
    }
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (isset($this->form[\'additionalNotificationRemarks\']) && $this->form[\'additionalNotificationRemarks\']->getData() != \'\') {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$this->request->getSession()->set(\'");
    String _appName = this._utils.appName(it);
    _builder.append(_appName, "        ");
    _builder.append("AdditionalNotificationRemarks\', $this->form[\'additionalNotificationRemarks\']->getData());");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    {
      boolean _hasAttributableEntities = this._modelBehaviourExtensions.hasAttributableEntities(it);
      if (_hasAttributableEntities) {
        _builder.newLine();
        _builder.append("    ");
        _builder.append("if (true === $this->hasAttributes) {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("if ($this->featureActivationHelper->isEnabled(FeatureActivationHelper::ATTRIBUTES, $this->objectType)) {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("        ");
        _builder.append("$this->processAttributesForUpdate();");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
      }
    }
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// return remaining form data");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $formData;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence _applyAction(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* This method executes a certain workflow action.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param array $args Arguments from handleCommand method");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return bool Whether everything worked well or not");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function applyAction(array $args = [])");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// stub for subclasses");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return false;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence prepareWorkflowAdditions(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Prepares properties related to advanced workflows.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param bool $enterprise Whether the enterprise workflow is used instead of the standard workflow");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return array List of additional form options");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected function prepareWorkflowAdditions($enterprise = false)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$roles = [];");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$isLoggedIn = $this->currentUserApi->isLoggedIn();");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$currentUserId = $isLoggedIn ? $this->currentUserApi->get(\'uid\') : 1;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$roles[\'is_creator\'] = $this->templateParameters[\'mode\'] == \'create\'");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("|| (method_exists($this->entityRef, \'getCreatedBy\') && $this->entityRef->getCreatedBy()->getUid() == $currentUserId);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$groupApplicationArgs = [");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'user\' => $currentUserId,");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'group\' => $this->variableApi->get(\'");
    String _appName = this._utils.appName(it);
    _builder.append(_appName, "        ");
    _builder.append("\', \'moderationGroupFor\' . $this->objectTypeCapital, 2)");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("];");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$roles[\'is_moderator\'] = count($this->groupApplicationRepository->findBy($groupApplicationArgs)) > 0;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (true === $enterprise) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$groupApplicationArgs = [");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("\'user\' => $currentUserId,");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("\'group\' => $this->variableApi->get(\'");
    String _appName_1 = this._utils.appName(it);
    _builder.append(_appName_1, "            ");
    _builder.append("\', \'superModerationGroupFor\' . $this->objectTypeCapital, 2)");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("];");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$roles[\'is_super_moderator\'] = count($this->groupApplicationRepository->findBy($groupApplicationArgs)) > 0;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $roles;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence formHandlerCommonImpl(final Application it, final String actionName) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("namespace ");
    String _appNamespace = this._utils.appNamespace(it);
    _builder.append(_appNamespace);
    _builder.append("\\Form\\Handler\\Common;");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("use ");
    String _appNamespace_1 = this._utils.appNamespace(it);
    _builder.append(_appNamespace_1);
    _builder.append("\\Form\\Handler\\Common\\Base\\Abstract");
    String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(actionName);
    _builder.append(_formatForCodeCapital);
    _builder.append("Handler;");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* This handler class handles the page events of editing forms.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* It collects common functionality required by different object types.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("abstract class ");
    String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(actionName);
    _builder.append(_formatForCodeCapital_1);
    _builder.append("Handler extends Abstract");
    String _formatForCodeCapital_2 = this._formattingExtensions.formatForCodeCapital(actionName);
    _builder.append(_formatForCodeCapital_2);
    _builder.append("Handler");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// feel free to extend the base handler class here");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence formHandlerBaseImpl(final Entity it, final String actionName) {
    StringConcatenation _builder = new StringConcatenation();
    final Application app = it.getApplication();
    _builder.newLineIfNotEmpty();
    CharSequence _formHandlerBaseImports = this.formHandlerBaseImports(it, actionName);
    _builder.append(_formHandlerBaseImports);
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* This handler class handles the page events of editing forms.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* It aims on the ");
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(it.getName());
    _builder.append(_formatForDisplay, " ");
    _builder.append(" object type.");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("abstract class Abstract");
    String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(actionName);
    _builder.append(_formatForCodeCapital);
    _builder.append("Handler extends ");
    String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(actionName);
    _builder.append(_formatForCodeCapital_1);
    _builder.append("Handler");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    CharSequence _processForm = this.processForm(it);
    _builder.append(_processForm, "    ");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    {
      boolean _isOwnerPermission = it.isOwnerPermission();
      if (_isOwnerPermission) {
        _builder.newLine();
        _builder.append("    ");
        CharSequence _formHandlerBaseInitEntityForEditing = this.formHandlerBaseInitEntityForEditing(it);
        _builder.append(_formHandlerBaseInitEntityForEditing, "    ");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.newLine();
    _builder.append("    ");
    CharSequence _redirectCodes = this.redirectHelper.getRedirectCodes(it, app);
    _builder.append(_redirectCodes, "    ");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    CharSequence _defaultReturnUrl = this.redirectHelper.getDefaultReturnUrl(it, app);
    _builder.append(_defaultReturnUrl, "    ");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    CharSequence _handleCommand = this.handleCommand(it);
    _builder.append(_handleCommand, "    ");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    CharSequence _applyAction = this.applyAction(it);
    _builder.append(_applyAction, "    ");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    CharSequence _redirectUrl = this.redirectHelper.getRedirectUrl(it, app);
    _builder.append(_redirectUrl, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence formHandlerBaseImports(final Entity it, final String actionName) {
    StringConcatenation _builder = new StringConcatenation();
    final Application app = it.getApplication();
    _builder.newLineIfNotEmpty();
    _builder.append("namespace ");
    String _appNamespace = this._utils.appNamespace(app);
    _builder.append(_appNamespace);
    _builder.append("\\Form\\Handler\\");
    String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital);
    _builder.append("\\Base;");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("use ");
    String _appNamespace_1 = this._utils.appNamespace(app);
    _builder.append(_appNamespace_1);
    _builder.append("\\Form\\Handler\\Common\\");
    String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(actionName);
    _builder.append(_formatForCodeCapital_1);
    _builder.append("Handler;");
    _builder.newLineIfNotEmpty();
    {
      Boolean _targets = this._utils.targets(app, "1.5");
      if ((_targets).booleanValue()) {
        _builder.append("use ");
        String _appNamespace_2 = this._utils.appNamespace(app);
        _builder.append(_appNamespace_2);
        _builder.append("\\Form\\Type\\");
        String _formatForCodeCapital_2 = this._formattingExtensions.formatForCodeCapital(it.getName());
        _builder.append(_formatForCodeCapital_2);
        _builder.append("Type;");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.newLine();
    CharSequence _imports = this.locking.imports(it);
    _builder.append(_imports);
    _builder.newLineIfNotEmpty();
    _builder.append("use Symfony\\Component\\HttpFoundation\\RedirectResponse;");
    _builder.newLine();
    _builder.append("use Symfony\\Component\\Security\\Core\\Exception\\AccessDeniedException;");
    _builder.newLine();
    _builder.append("use RuntimeException;");
    _builder.newLine();
    {
      boolean _needsFeatureActivationHelper = this._modelBehaviourExtensions.needsFeatureActivationHelper(app);
      if (_needsFeatureActivationHelper) {
        _builder.append("use ");
        String _appNamespace_3 = this._utils.appNamespace(app);
        _builder.append(_appNamespace_3);
        _builder.append("\\Helper\\FeatureActivationHelper;");
        _builder.newLineIfNotEmpty();
      }
    }
    return _builder;
  }
  
  private CharSequence memberVarAssignments(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("$this->objectType = \'");
    String _formatForCode = this._formattingExtensions.formatForCode(it.getName());
    _builder.append(_formatForCode);
    _builder.append("\';");
    _builder.newLineIfNotEmpty();
    _builder.append("$this->objectTypeCapital = \'");
    String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital);
    _builder.append("\';");
    _builder.newLineIfNotEmpty();
    _builder.append("$this->objectTypeLower = \'");
    String _formatForDB = this._formattingExtensions.formatForDB(it.getName());
    _builder.append(_formatForDB);
    _builder.append("\';");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    CharSequence _memberVarAssignments = this.locking.memberVarAssignments(it);
    _builder.append(_memberVarAssignments);
    _builder.newLineIfNotEmpty();
    {
      boolean _hasAttributableEntities = this._modelBehaviourExtensions.hasAttributableEntities(this.app);
      if (_hasAttributableEntities) {
        _builder.append("$this->hasAttributes = ");
        String _displayBool = this._formattingExtensions.displayBool(Boolean.valueOf(it.isAttributable()));
        _builder.append(_displayBool);
        _builder.append(";");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      boolean _hasSluggable = this._modelBehaviourExtensions.hasSluggable(this.app);
      if (_hasSluggable) {
        _builder.append("$this->hasSlugUpdatableField = ");
        String _displayBool_1 = this._formattingExtensions.displayBool(Boolean.valueOf((this._modelBehaviourExtensions.hasSluggableFields(it) && it.isSlugUpdatable())));
        _builder.append(_displayBool_1);
        _builder.append(";");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      boolean _hasTranslatable = this._modelBehaviourExtensions.hasTranslatable(this.app);
      if (_hasTranslatable) {
        _builder.append("$this->hasTranslatableFields = ");
        String _displayBool_2 = this._formattingExtensions.displayBool(Boolean.valueOf(this._modelBehaviourExtensions.hasTranslatableFields(it)));
        _builder.append(_displayBool_2);
        _builder.append(";");
        _builder.newLineIfNotEmpty();
      }
    }
    return _builder;
  }
  
  private CharSequence formHandlerBaseInitEntityForEditing(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Initialise existing entity for editing.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return EntityAccess Desired entity instance or null");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected function initEntityForEditing()");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$entity = parent::initEntityForEditing();");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// only allow editing for the owner or people with higher permissions");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$currentUserId = $this->currentUserApi->isLoggedIn() ? $this->currentUserApi->get(\'uid\') : 1;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$isOwner = null !== $entity->getCreatedBy() && $currentUserId == $entity->getCreatedBy()->getUid();");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!$isOwner && !$this->permissionApi->hasPermission($this->permissionComponent, $this->createCompositeIdentifier() . \'::\', ACCESS_ADD)) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("throw new AccessDeniedException();");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $entity;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence formHandlerImpl(final Entity it, final String actionName) {
    StringConcatenation _builder = new StringConcatenation();
    final Application app = it.getApplication();
    _builder.newLineIfNotEmpty();
    _builder.append("namespace ");
    String _appNamespace = this._utils.appNamespace(app);
    _builder.append(_appNamespace);
    _builder.append("\\Form\\Handler\\");
    String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital);
    _builder.append(";");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("use ");
    String _appNamespace_1 = this._utils.appNamespace(app);
    _builder.append(_appNamespace_1);
    _builder.append("\\Form\\Handler\\");
    String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital_1);
    _builder.append("\\Base\\Abstract");
    String _formatForCodeCapital_2 = this._formattingExtensions.formatForCodeCapital(actionName);
    _builder.append(_formatForCodeCapital_2);
    _builder.append("Handler;");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* This handler class handles the page events of the Form called by the ");
    String _appName = this._utils.appName(app);
    String _plus = (_appName + "_");
    String _name = it.getName();
    String _plus_1 = (_plus + _name);
    String _plus_2 = (_plus_1 + "_");
    String _plus_3 = (_plus_2 + actionName);
    String _formatForCode = this._formattingExtensions.formatForCode(_plus_3);
    _builder.append(_formatForCode, " ");
    _builder.append("() function.");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("* It aims on the ");
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(it.getName());
    _builder.append(_formatForDisplay, " ");
    _builder.append(" object type.");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("class ");
    String _formatForCodeCapital_3 = this._formattingExtensions.formatForCodeCapital(actionName);
    _builder.append(_formatForCodeCapital_3);
    _builder.append("Handler extends Abstract");
    String _formatForCodeCapital_4 = this._formattingExtensions.formatForCodeCapital(actionName);
    _builder.append(_formatForCodeCapital_4);
    _builder.append("Handler");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// feel free to extend the base handler class here");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence _processForm(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Initialise form handler.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* This method takes care of all necessary initialisation of our data and form states.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param array $templateParameters List of preassigned template variables");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return boolean False in case of initialisation errors, otherwise true");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function processForm(array $templateParameters)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    CharSequence _memberVarAssignments = this.memberVarAssignments(it);
    _builder.append(_memberVarAssignments, "    ");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$result = parent::processForm($templateParameters);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($result instanceof RedirectResponse) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return $result;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($this->templateParameters[\'mode\'] == \'create\') {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if (!$this->modelHelper->canBeCreated($this->objectType)) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$this->request->getSession()->getFlashBag()->add(\'error\', $this->__(\'Sorry, but you can not create the ");
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(it.getName());
    _builder.append(_formatForDisplay, "            ");
    _builder.append(" yet as other items are required which must be created before!\'));");
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    _builder.append("$logArgs = [\'app\' => \'");
    String _appName = this._utils.appName(this.app);
    _builder.append(_appName, "            ");
    _builder.append("\', \'user\' => $this->currentUserApi->get(\'uname\'), \'entity\' => $this->objectType];");
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    _builder.append("$this->logger->notice(\'{app}: User {user} tried to create a new {entity}, but failed as it other items are required which must be created before.\', $logArgs);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("            ");
    _builder.append("return new RedirectResponse($this->getRedirectUrl([\'commandName\' => \'\']), 302);");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    CharSequence _setVersion = this.locking.setVersion(it);
    _builder.append(_setVersion, "    ");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$entityData = $this->entityRef->toArray();");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// assign data to template as array (for additions like standard fields)");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$this->templateParameters[$this->objectTypeLower] = $entityData;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $result;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    {
      if (((!it.getIncoming().isEmpty()) || (!it.getOutgoing().isEmpty()))) {
        CharSequence _childMethod = this.relationPresetsHelper.childMethod(it);
        _builder.append(_childMethod);
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Creates the form type.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected function createForm()");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$options = [");
    _builder.newLine();
    {
      boolean _hasUploadFieldsEntity = this._modelExtensions.hasUploadFieldsEntity(it);
      if (_hasUploadFieldsEntity) {
        _builder.append("        ");
        _builder.append("\'entity\' => $this->entityRef,");
        _builder.newLine();
      }
    }
    _builder.append("        ");
    _builder.append("\'mode\' => $this->templateParameters[\'mode\'],");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'actions\' => $this->templateParameters[\'actions\'],");
    _builder.newLine();
    {
      boolean _isStandardFields = it.isStandardFields();
      if (_isStandardFields) {
        _builder.append("        ");
        _builder.append("\'has_moderate_permission\' => $this->permissionApi->hasPermission($this->permissionComponent, $this->createCompositeIdentifier() . \'::\', ACCESS_MODERATE),");
        _builder.newLine();
      }
    }
    {
      if (((!it.getIncoming().isEmpty()) || (!it.getOutgoing().isEmpty()))) {
        _builder.append("        ");
        _builder.append("\'filter_by_ownership\' => !$this->permissionApi->hasPermission($this->permissionComponent, $this->createCompositeIdentifier() . \'::\', ACCESS_ADD)");
        {
          boolean _needsAutoCompletion = this._modelJoinExtensions.needsAutoCompletion(this.app);
          if (_needsAutoCompletion) {
            _builder.append(",");
            _builder.newLineIfNotEmpty();
            _builder.append("        ");
            _builder.append("\'inline_usage\' => $this->templateParameters[\'inlineUsage\']");
          }
        }
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("    ");
    _builder.append("];");
    _builder.newLine();
    {
      boolean _isAttributable = it.isAttributable();
      if (_isAttributable) {
        _builder.append("    ");
        _builder.append("if ($this->featureActivationHelper->isEnabled(FeatureActivationHelper::ATTRIBUTES, $this->objectType)) {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("$options[\'attributes\'] = $this->templateParameters[\'attributes\'];");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
      }
    }
    {
      EntityWorkflowType _workflow = it.getWorkflow();
      boolean _notEquals = (!Objects.equal(_workflow, EntityWorkflowType.NONE));
      if (_notEquals) {
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$workflowRoles = $this->prepareWorkflowAdditions(");
        EntityWorkflowType _workflow_1 = it.getWorkflow();
        String _displayBool = this._formattingExtensions.displayBool(Boolean.valueOf(Objects.equal(_workflow_1, EntityWorkflowType.ENTERPRISE)));
        _builder.append(_displayBool, "    ");
        _builder.append(");");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("$options = array_merge($options, $workflowRoles);");
        _builder.newLine();
      }
    }
    {
      boolean _hasTranslatableFields = this._modelBehaviourExtensions.hasTranslatableFields(it);
      if (_hasTranslatableFields) {
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$options[\'translations\'] = [];");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("foreach ($this->templateParameters[\'supportedLanguages\'] as $language) {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("$options[\'translations\'][$language] = isset($this->templateParameters[$this->objectTypeLower . $language]) ? $this->templateParameters[$this->objectTypeLower . $language] : [];");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
      }
    }
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $this->formFactory->create(");
    {
      Boolean _targets = this._utils.targets(this.app, "1.5");
      if ((_targets).booleanValue()) {
        String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(it.getName());
        _builder.append(_formatForCodeCapital, "    ");
        _builder.append("Type::class");
      } else {
        _builder.append("\'");
        String _appNamespace = this._utils.appNamespace(this.app);
        _builder.append(_appNamespace, "    ");
        _builder.append("\\Form\\Type\\");
        String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(it.getName());
        _builder.append(_formatForCodeCapital_1, "    ");
        _builder.append("Type\'");
      }
    }
    _builder.append(", $this->entityRef, $options);");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence _handleCommand(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Command event handler.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* This event handler is called when a command is issued by the user.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param array $args List of arguments");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return mixed Redirect or false on errors");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function handleCommand($args = [])");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$result = parent::handleCommand($args);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (false === $result) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return $result;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// build $args for BC (e.g. used by redirect handling)");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("foreach ($this->templateParameters[\'actions\'] as $action) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if ($this->form->get($action[\'id\'])->isClicked()) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$args[\'commandName\'] = $action[\'id\'];");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($this->form->get(\'cancel\')->isClicked()) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$args[\'commandName\'] = \'cancel\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return new RedirectResponse($this->getRedirectUrl($args), 302);");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Get success or error message for default operations.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param array   $args    Arguments from handleCommand method");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param Boolean $success Becomes true if this is a success, false for default error");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return String desired status or error message");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected function getDefaultMessage($args, $success = false)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (false === $success) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return parent::getDefaultMessage($args, $success);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$message = \'\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("switch ($args[\'commandName\']) {");
    _builder.newLine();
    {
      boolean _hasWorkflowState = this._workflowExtensions.hasWorkflowState(this.app, "deferred");
      if (_hasWorkflowState) {
        _builder.append("        ");
        _builder.append("case \'defer\':");
        _builder.newLine();
      }
    }
    _builder.append("        ");
    _builder.append("case \'submit\':");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("if ($this->templateParameters[\'mode\'] == \'create\') {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("$message = $this->__(\'Done! ");
    String _formatForDisplayCapital = this._formattingExtensions.formatForDisplayCapital(it.getName());
    _builder.append(_formatForDisplayCapital, "                ");
    _builder.append(" created.\');");
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    _builder.append("} else {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("$message = $this->__(\'Done! ");
    String _formatForDisplayCapital_1 = this._formattingExtensions.formatForDisplayCapital(it.getName());
    _builder.append(_formatForDisplayCapital_1, "                ");
    _builder.append(" updated.\');");
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("break;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("case \'delete\':");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$message = $this->__(\'Done! ");
    String _formatForDisplayCapital_2 = this._formattingExtensions.formatForDisplayCapital(it.getName());
    _builder.append(_formatForDisplayCapital_2, "            ");
    _builder.append(" deleted.\');");
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    _builder.append("break;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("default:");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$message = $this->__(\'Done! ");
    String _formatForDisplayCapital_3 = this._formattingExtensions.formatForDisplayCapital(it.getName());
    _builder.append(_formatForDisplayCapital_3, "            ");
    _builder.append(" updated.\');");
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    _builder.append("break;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $message;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence _applyAction(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* This method executes a certain workflow action.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param array $args Arguments from handleCommand method");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return bool Whether everything worked well or not");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @throws RuntimeException Thrown if concurrent editing is recognised or another error occurs");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function applyAction(array $args = [])");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// get treated entity reference from persisted member var");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$entity = $this->entityRef;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$action = $args[\'commandName\'];");
    _builder.newLine();
    _builder.append("    ");
    CharSequence _version = this.locking.getVersion(it);
    _builder.append(_version, "    ");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$success = false;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$flashBag = $this->request->getSession()->getFlashBag();");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("try {");
    _builder.newLine();
    _builder.append("        ");
    CharSequence _applyLock = this.locking.applyLock(it);
    _builder.append(_applyLock, "        ");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("// execute the workflow action");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$success = $this->workflowHelper->executeAction($entity, $action);");
    _builder.newLine();
    _builder.append("    ");
    CharSequence _catchException = this.locking.catchException(it);
    _builder.append(_catchException, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("} catch(\\Exception $e) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$flashBag->add(\'error\', $this->__f(\'Sorry, but an error occured during the %action% action. Please apply the changes again!\', [\'%action%\' => $action]) . \' \' . $e->getMessage());");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$logArgs = [\'app\' => \'");
    String _appName = this._utils.appName(this.app);
    _builder.append(_appName, "        ");
    _builder.append("\', \'user\' => $this->currentUserApi->get(\'uname\'), \'entity\' => \'");
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(it.getName());
    _builder.append(_formatForDisplay, "        ");
    _builder.append("\', \'id\' => $entity->createCompositeIdentifier(), \'errorMessage\' => $e->getMessage()];");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("$this->logger->error(\'{app}: User {user} tried to edit the {entity} with id {id}, but failed. Error details: {errorMessage}.\', $logArgs);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$this->addDefaultMessage($args, $success);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($success && $this->templateParameters[\'mode\'] == \'create\') {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// store new identifier");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("foreach ($this->idFields as $idField) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$this->idValues[$idField] = $entity[$idField];");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    {
      if (((!it.getIncoming().isEmpty()) || (!it.getOutgoing().isEmpty()))) {
        _builder.append("    ");
        CharSequence _saveNonEditablePresets = this.relationPresetsHelper.saveNonEditablePresets(it, this.app);
        _builder.append(_saveNonEditablePresets, "    ");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $success;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence processForm(final NamedObject it) {
    if (it instanceof Entity) {
      return _processForm((Entity)it);
    } else if (it instanceof Application) {
      return _processForm((Application)it);
    } else {
      throw new IllegalArgumentException("Unhandled parameter types: " +
        Arrays.<Object>asList(it).toString());
    }
  }
  
  private CharSequence handleCommand(final NamedObject it) {
    if (it instanceof Entity) {
      return _handleCommand((Entity)it);
    } else if (it instanceof Application) {
      return _handleCommand((Application)it);
    } else {
      throw new IllegalArgumentException("Unhandled parameter types: " +
        Arrays.<Object>asList(it).toString());
    }
  }
  
  private CharSequence applyAction(final NamedObject it) {
    if (it instanceof Entity) {
      return _applyAction((Entity)it);
    } else if (it instanceof Application) {
      return _applyAction((Application)it);
    } else {
      throw new IllegalArgumentException("Unhandled parameter types: " +
        Arrays.<Object>asList(it).toString());
    }
  }
}
