package org.zikula.modulestudio.generator.cartridges.zclassic.controller;

import com.google.inject.Inject;
import de.guite.modulestudio.metamodel.modulestudio.Action;
import de.guite.modulestudio.metamodel.modulestudio.Application;
import de.guite.modulestudio.metamodel.modulestudio.Controller;
import de.guite.modulestudio.metamodel.modulestudio.Controllers;
import de.guite.modulestudio.metamodel.modulestudio.DerivedField;
import de.guite.modulestudio.metamodel.modulestudio.EditAction;
import de.guite.modulestudio.metamodel.modulestudio.Entity;
import de.guite.modulestudio.metamodel.modulestudio.EntityLockType;
import de.guite.modulestudio.metamodel.modulestudio.ListField;
import de.guite.modulestudio.metamodel.modulestudio.Models;
import de.guite.modulestudio.metamodel.modulestudio.UploadField;
import de.guite.modulestudio.metamodel.modulestudio.UserField;
import org.eclipse.emf.common.util.EList;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.InputOutput;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.eclipse.xtext.xbase.lib.StringExtensions;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.actionHandler.Config;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.actionHandler.Redirect;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.actionHandler.RelationPresets;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.actionHandler.UploadProcessing;
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper;
import org.zikula.modulestudio.generator.extensions.ControllerExtensions;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;
import org.zikula.modulestudio.generator.extensions.WorkflowExtensions;

@SuppressWarnings("all")
public class FormHandler {
  @Inject
  @Extension
  private ControllerExtensions _controllerExtensions = new Function0<ControllerExtensions>() {
    public ControllerExtensions apply() {
      ControllerExtensions _controllerExtensions = new ControllerExtensions();
      return _controllerExtensions;
    }
  }.apply();
  
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
  
  @Inject
  @Extension
  private WorkflowExtensions _workflowExtensions = new Function0<WorkflowExtensions>() {
    public WorkflowExtensions apply() {
      WorkflowExtensions _workflowExtensions = new WorkflowExtensions();
      return _workflowExtensions;
    }
  }.apply();
  
  private FileHelper fh = new Function0<FileHelper>() {
    public FileHelper apply() {
      FileHelper _fileHelper = new FileHelper();
      return _fileHelper;
    }
  }.apply();
  
  private Redirect redirectHelper = new Function0<Redirect>() {
    public Redirect apply() {
      Redirect _redirect = new Redirect();
      return _redirect;
    }
  }.apply();
  
  private RelationPresets relationPresetsHelper = new Function0<RelationPresets>() {
    public RelationPresets apply() {
      RelationPresets _relationPresets = new RelationPresets();
      return _relationPresets;
    }
  }.apply();
  
  private Application app;
  
  private Controller controller;
  
  /**
   * Entry point for Form handler classes.
   */
  public void generate(final Application it, final IFileSystemAccess fsa) {
    this.app = it;
    Iterable<EditAction> _editActions = this._controllerExtensions.getEditActions(it);
    for (final EditAction action : _editActions) {
      this.generate(action, fsa);
    }
    Config _config = new Config();
    _config.generate(it, fsa);
  }
  
  private void generate(final Action it, final IFileSystemAccess fsa) {
    Controller _controller = it.getController();
    this.controller = _controller;
    this.generate(this.controller, "edit", fsa);
    EList<Entity> _allEntities = this._modelExtensions.getAllEntities(this.app);
    for (final Entity entity : _allEntities) {
      this.generate(entity, "edit", fsa);
    }
  }
  
  public CharSequence formCreate(final Action it, final String appName, final Controller controller, final String actionName) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("// Create new Form reference");
    _builder.newLine();
    _builder.append("$view = FormUtil::newForm(\'");
    String _formatForCode = this._formattingExtensions.formatForCode(appName);
    _builder.append(_formatForCode, "");
    _builder.append("\', $this);");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    {
      Controllers _container = controller.getContainer();
      Application _application = _container.getApplication();
      boolean _targets = this._utils.targets(_application, "1.3.5");
      if (_targets) {
        _builder.append("$handlerClass = \'");
        _builder.append(appName, "");
        _builder.append("_Form_Handler_");
        String _name = controller.getName();
        String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(_name);
        _builder.append(_formatForCodeCapital, "");
        _builder.append("_");
        String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(actionName);
        _builder.append(_formatForCodeCapital_1, "");
        _builder.append("\';");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("$handlerClass = \'\\\\");
        String _vendor = this.app.getVendor();
        String _formatForCodeCapital_2 = this._formattingExtensions.formatForCodeCapital(_vendor);
        _builder.append(_formatForCodeCapital_2, "");
        _builder.append("\\\\");
        String _name_1 = this.app.getName();
        String _formatForCodeCapital_3 = this._formattingExtensions.formatForCodeCapital(_name_1);
        _builder.append(_formatForCodeCapital_3, "");
        _builder.append("Module\\\\Form\\\\Handler\\\\");
        String _name_2 = controller.getName();
        String _formatForCodeCapital_4 = this._formattingExtensions.formatForCodeCapital(_name_2);
        _builder.append(_formatForCodeCapital_4, "");
        _builder.append("\\\\");
        String _formatForCodeCapital_5 = this._formattingExtensions.formatForCodeCapital(actionName);
        _builder.append(_formatForCodeCapital_5, "");
        _builder.append("Handler\';");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.newLine();
    _builder.append("// Execute form using supplied template and page event handler");
    _builder.newLine();
    _builder.append("return $view->execute(\'");
    String _formattedName = this._controllerExtensions.formattedName(controller);
    String _firstUpper = StringExtensions.toFirstUpper(_formattedName);
    _builder.append(_firstUpper, "");
    _builder.append("/");
    String _formatForCode_1 = this._formattingExtensions.formatForCode(actionName);
    String _firstLower = StringExtensions.toFirstLower(_formatForCode_1);
    _builder.append(_firstLower, "");
    _builder.append(".tpl\', new $handlerClass());");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  /**
   * Entry point for generic Form handler base classes.
   */
  private void generate(final Controller it, final String actionName, final IFileSystemAccess fsa) {
    String _name = it.getName();
    String _plus = ("Generating \"" + _name);
    String _plus_1 = (_plus + "\" form handler base class");
    InputOutput.<String>println(_plus_1);
    String _xifexpression = null;
    boolean _targets = this._utils.targets(this.app, "1.3.5");
    if (_targets) {
      _xifexpression = "";
    } else {
      _xifexpression = "Handler";
    }
    final String handlerSuffix = _xifexpression;
    String _appSourceLibPath = this._namingExtensions.getAppSourceLibPath(this.app);
    String _plus_2 = (_appSourceLibPath + "Form/Handler/");
    String _name_1 = it.getName();
    String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(_name_1);
    String _plus_3 = (_plus_2 + _formatForCodeCapital);
    final String formHandlerFolder = (_plus_3 + "/");
    String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(actionName);
    String _plus_4 = (_formatForCodeCapital_1 + handlerSuffix);
    final String formHandlerFileName = (_plus_4 + ".php");
    String _plus_5 = (formHandlerFolder + "Base/");
    String _plus_6 = (_plus_5 + formHandlerFileName);
    CharSequence _formHandlerCommonBaseFile = this.formHandlerCommonBaseFile(it, this.app, actionName);
    fsa.generateFile(_plus_6, _formHandlerCommonBaseFile);
    String _plus_7 = (formHandlerFolder + formHandlerFileName);
    CharSequence _formHandlerCommonFile = this.formHandlerCommonFile(it, this.app, actionName);
    fsa.generateFile(_plus_7, _formHandlerCommonFile);
  }
  
  private CharSequence formHandlerCommonBaseFile(final Controller it, final Application app, final String actionName) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _phpFileHeader = this.fh.phpFileHeader(app);
    _builder.append(_phpFileHeader, "");
    _builder.newLineIfNotEmpty();
    CharSequence _formHandlerCommonBaseImpl = this.formHandlerCommonBaseImpl(it, actionName);
    _builder.append(_formHandlerCommonBaseImpl, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence formHandlerCommonFile(final Controller it, final Application app, final String actionName) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _phpFileHeader = this.fh.phpFileHeader(app);
    _builder.append(_phpFileHeader, "");
    _builder.newLineIfNotEmpty();
    CharSequence _formHandlerCommonImpl = this.formHandlerCommonImpl(it, actionName);
    _builder.append(_formHandlerCommonImpl, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  /**
   * Entry point for Form handler classes per entity.
   */
  private void generate(final Entity it, final String actionName, final IFileSystemAccess fsa) {
    String _formattedName = this._controllerExtensions.formattedName(this.controller);
    String _plus = ("Generating \"" + _formattedName);
    String _plus_1 = (_plus + "\" form handler classes for \"");
    String _name = it.getName();
    String _plus_2 = (_plus_1 + _name);
    String _plus_3 = (_plus_2 + "_");
    String _plus_4 = (_plus_3 + actionName);
    String _plus_5 = (_plus_4 + "\"");
    InputOutput.<String>println(_plus_5);
    String _xifexpression = null;
    boolean _targets = this._utils.targets(this.app, "1.3.5");
    if (_targets) {
      _xifexpression = "";
    } else {
      _xifexpression = "Handler";
    }
    final String handlerSuffix = _xifexpression;
    String _appSourceLibPath = this._namingExtensions.getAppSourceLibPath(this.app);
    String _plus_6 = (_appSourceLibPath + "Form/Handler/");
    String _name_1 = this.controller.getName();
    String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(_name_1);
    String _plus_7 = (_plus_6 + _formatForCodeCapital);
    String _plus_8 = (_plus_7 + "/");
    String _name_2 = it.getName();
    String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(_name_2);
    String _plus_9 = (_plus_8 + _formatForCodeCapital_1);
    final String formHandlerFolder = (_plus_9 + "/");
    String _formatForCodeCapital_2 = this._formattingExtensions.formatForCodeCapital(actionName);
    String _plus_10 = (_formatForCodeCapital_2 + handlerSuffix);
    final String formHandlerFileName = (_plus_10 + ".php");
    String _plus_11 = (formHandlerFolder + "Base/");
    String _plus_12 = (_plus_11 + formHandlerFileName);
    CharSequence _formHandlerBaseFile = this.formHandlerBaseFile(it, actionName);
    fsa.generateFile(_plus_12, _formHandlerBaseFile);
    String _plus_13 = (formHandlerFolder + formHandlerFileName);
    CharSequence _formHandlerFile = this.formHandlerFile(it, actionName);
    fsa.generateFile(_plus_13, _formHandlerFile);
  }
  
  private CharSequence formHandlerBaseFile(final Entity it, final String actionName) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _phpFileHeader = this.fh.phpFileHeader(this.app);
    _builder.append(_phpFileHeader, "");
    _builder.newLineIfNotEmpty();
    CharSequence _formHandlerBaseImpl = this.formHandlerBaseImpl(it, actionName);
    _builder.append(_formHandlerBaseImpl, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence formHandlerFile(final Entity it, final String actionName) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _phpFileHeader = this.fh.phpFileHeader(this.app);
    _builder.append(_phpFileHeader, "");
    _builder.newLineIfNotEmpty();
    CharSequence _formHandlerImpl = this.formHandlerImpl(it, actionName);
    _builder.append(_formHandlerImpl, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence formHandlerCommonBaseImpl(final Controller it, final String actionName) {
    StringConcatenation _builder = new StringConcatenation();
    Controllers _container = it.getContainer();
    final Application app = _container.getApplication();
    _builder.newLineIfNotEmpty();
    {
      boolean _targets = this._utils.targets(app, "1.3.5");
      boolean _not = (!_targets);
      if (_not) {
        _builder.append("namespace ");
        String _appNamespace = this._utils.appNamespace(app);
        _builder.append(_appNamespace, "");
        _builder.append("\\Form\\Handler\\");
        String _name = it.getName();
        String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(_name);
        _builder.append(_formatForCodeCapital, "");
        _builder.append("\\Base;");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
        _builder.append("use ");
        String _appNamespace_1 = this._utils.appNamespace(app);
        _builder.append(_appNamespace_1, "");
        _builder.append("\\Form\\Plugin\\AbstractObjectSelector;");
        _builder.newLineIfNotEmpty();
        {
          boolean _hasUploads = this._modelExtensions.hasUploads(app);
          if (_hasUploads) {
            _builder.append("use ");
            String _appNamespace_2 = this._utils.appNamespace(app);
            _builder.append(_appNamespace_2, "");
            _builder.append("\\UploadHandler;");
            _builder.newLineIfNotEmpty();
          }
        }
        _builder.append("use ");
        String _appNamespace_3 = this._utils.appNamespace(app);
        _builder.append(_appNamespace_3, "");
        _builder.append("\\Util\\ControllerUtil;");
        _builder.newLineIfNotEmpty();
        {
          boolean _hasTranslatable = this._modelBehaviourExtensions.hasTranslatable(app);
          if (_hasTranslatable) {
            _builder.append("use ");
            String _appNamespace_4 = this._utils.appNamespace(app);
            _builder.append(_appNamespace_4, "");
            _builder.append("\\Util\\TranslatableUtil;");
            _builder.newLineIfNotEmpty();
          }
        }
        _builder.append("use ");
        String _appNamespace_5 = this._utils.appNamespace(app);
        _builder.append(_appNamespace_5, "");
        _builder.append("\\Util\\WorkflowUtil;");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
        _builder.append("use LogUtil;");
        _builder.newLine();
        _builder.append("use ModUtil;");
        _builder.newLine();
        _builder.append("use SecurityUtil;");
        _builder.newLine();
        _builder.append("use System;");
        _builder.newLine();
        _builder.append("use UserUtil;");
        _builder.newLine();
        _builder.append("use Zikula_Form_AbstractHandler;");
        _builder.newLine();
        _builder.append("use Zikula_Form_View;");
        _builder.newLine();
        _builder.append("use ZLanguage;");
        _builder.newLine();
        _builder.append("use Zikula\\Core\\Hook\\ProcessHook;");
        _builder.newLine();
        _builder.append("use Zikula\\Core\\Hook\\ValidationHook;");
        _builder.newLine();
        _builder.append("use Zikula\\Core\\Hook\\ValidationProviders;");
        _builder.newLine();
        _builder.append("use Zikula\\Core\\ModUrl;");
        _builder.newLine();
        _builder.newLine();
      }
    }
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* This handler class handles the page events of the Form called by the ");
    String _appName = this._utils.appName(app);
    String _plus = (_appName + "_");
    String _formattedName = this._controllerExtensions.formattedName(it);
    String _plus_1 = (_plus + _formattedName);
    String _plus_2 = (_plus_1 + "_");
    String _plus_3 = (_plus_2 + actionName);
    String _formatForCode = this._formattingExtensions.formatForCode(_plus_3);
    _builder.append(_formatForCode, " ");
    _builder.append("() function.");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("* It collects common functionality required by different object types.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Member variables in a form handler object are persisted across different page requests. This means");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* a member variable $this->X can be set on one request and on the next request it will still contain");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* the same value.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* A form handler will be notified of various events happening during it\'s life-cycle.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* When a specific event occurs then the corresponding event handler (class method) will be executed. Handlers");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* are named exactly like their events - this is how the framework knows which methods to call.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* The list of events is:");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* - <b>initialize</b>: this event fires before any of the events for the plugins and can be used to setup");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*   the form handler. The event handler typically takes care of reading URL variables, access control");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*   and reading of data from the database.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* - <b>handleCommand</b>: this event is fired by various plugins on the page. Typically it is done by the");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*   Zikula_Form_Plugin_Button plugin to signal that the user activated a button.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    {
      boolean _targets_1 = this._utils.targets(app, "1.3.5");
      if (_targets_1) {
        _builder.append("class ");
        String _appName_1 = this._utils.appName(app);
        _builder.append(_appName_1, "");
        _builder.append("_Form_Handler_");
        String _name_1 = it.getName();
        String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(_name_1);
        _builder.append(_formatForCodeCapital_1, "");
        _builder.append("_Base_");
        String _formatForCodeCapital_2 = this._formattingExtensions.formatForCodeCapital(actionName);
        _builder.append(_formatForCodeCapital_2, "");
        _builder.append(" extends Zikula_Form_AbstractHandler");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("class ");
        String _formatForCodeCapital_3 = this._formattingExtensions.formatForCodeCapital(actionName);
        _builder.append(_formatForCodeCapital_3, "");
        _builder.append("Handler extends Zikula_Form_AbstractHandler");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("{");
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
    _builder.append("* @var Zikula_EntityAccess");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("protected $entityRef = false;");
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
    _builder.append("protected $idFields = array();");
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
    _builder.append("protected $idValues = array();");
    _builder.newLine();
    _builder.append("    ");
    CharSequence _memberFields = this.relationPresetsHelper.memberFields(it);
    _builder.append(_memberFields, "    ");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* One of \"create\" or \"edit\".");
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
    _builder.append("protected $mode;");
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
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* Whether this form is being used inline within a window.");
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
    _builder.append("protected $inlineUsage = false;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* Full prefix for related items.");
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
    _builder.append("protected $idPrefix = \'\';");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @Whether an existing item is used as template for a new one.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* var boolean");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("protected $hasTemplateId = false;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* Whether the PageLock extension is used for this entity type or not.");
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
    _builder.append("protected $hasPageLockSupport = false;");
    _builder.newLine();
    {
      boolean _hasAttributableEntities = this._modelBehaviourExtensions.hasAttributableEntities(app);
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
      boolean _hasCategorisableEntities = this._modelBehaviourExtensions.hasCategorisableEntities(app);
      if (_hasCategorisableEntities) {
        _builder.newLine();
        _builder.append("    ");
        _builder.append("/**");
        _builder.newLine();
        _builder.append("    ");
        _builder.append(" ");
        _builder.append("* Whether the entity is categorisable or not.");
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
        _builder.append("protected $hasCategories = false;");
        _builder.newLine();
      }
    }
    {
      boolean _hasMetaDataEntities = this._modelBehaviourExtensions.hasMetaDataEntities(app);
      if (_hasMetaDataEntities) {
        _builder.newLine();
        _builder.append("    ");
        _builder.append("/**");
        _builder.newLine();
        _builder.append("    ");
        _builder.append(" ");
        _builder.append("* Whether the entity has meta data or not.");
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
        _builder.append("protected $hasMetaData = false;");
        _builder.newLine();
      }
    }
    {
      boolean _hasSluggable = this._modelBehaviourExtensions.hasSluggable(app);
      if (_hasSluggable) {
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
      boolean _hasTranslatable_1 = this._modelBehaviourExtensions.hasTranslatable(app);
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
    {
      boolean _hasUploads_1 = this._modelExtensions.hasUploads(app);
      if (_hasUploads_1) {
        _builder.newLine();
        _builder.append("    ");
        _builder.append("/**");
        _builder.newLine();
        _builder.append("    ");
        _builder.append(" ");
        _builder.append("* Array with upload field names and mandatory flags.");
        _builder.newLine();
        _builder.append("    ");
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append("    ");
        _builder.append(" ");
        _builder.append("* @var array");
        _builder.newLine();
        _builder.append("    ");
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("protected $uploadFields = array();");
        _builder.newLine();
      }
    }
    {
      boolean _hasUserFields = this._modelExtensions.hasUserFields(app);
      if (_hasUserFields) {
        _builder.newLine();
        _builder.append("    ");
        _builder.append("/**");
        _builder.newLine();
        _builder.append("    ");
        _builder.append(" ");
        _builder.append("* Array with user field names and mandatory flags.");
        _builder.newLine();
        _builder.append("    ");
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append("    ");
        _builder.append(" ");
        _builder.append("* @var array");
        _builder.newLine();
        _builder.append("    ");
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("protected $userFields = array();");
        _builder.newLine();
      }
    }
    {
      boolean _hasListFields = this._modelExtensions.hasListFields(app);
      if (_hasListFields) {
        _builder.newLine();
        _builder.append("    ");
        _builder.append("/**");
        _builder.newLine();
        _builder.append("    ");
        _builder.append(" ");
        _builder.append("* Array with list field names and multiple flags.");
        _builder.newLine();
        _builder.append("    ");
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append("    ");
        _builder.append(" ");
        _builder.append("* @var array");
        _builder.newLine();
        _builder.append("    ");
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("protected $listFields = array();");
        _builder.newLine();
      }
    }
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* Post construction hook.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @return mixed");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("public function setup()");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* Pre-initialise hook.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @return void");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("public function preInitialize()");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    CharSequence _initialize = this.initialize(it, actionName);
    _builder.append(_initialize, "    ");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* Post-initialise hook.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @return void");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("public function postInitialize()");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{");
    _builder.newLine();
    {
      boolean _targets_2 = this._utils.targets(app, "1.3.5");
      if (_targets_2) {
        _builder.append("        ");
        _builder.append("$entityClass = $this->name . \'_Entity_\' . ucwords($this->objectType);");
        _builder.newLine();
      } else {
        _builder.append("        ");
        _builder.append("$entityClass = \'\\\\");
        String _vendor = app.getVendor();
        String _formatForCodeCapital_4 = this._formattingExtensions.formatForCodeCapital(_vendor);
        _builder.append(_formatForCodeCapital_4, "        ");
        _builder.append("\\\\");
        String _name_2 = app.getName();
        String _formatForCodeCapital_5 = this._formattingExtensions.formatForCodeCapital(_name_2);
        _builder.append(_formatForCodeCapital_5, "        ");
        _builder.append("Module\\\\Entity\\\\\' . ucwords($this->objectType) . \'Entity\';");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("        ");
    _builder.append("$repository = $this->entityManager->getRepository($entityClass);");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$utilArgs = array(\'controller\' => \'");
    String _formattedName_1 = this._controllerExtensions.formattedName(it);
    _builder.append(_formattedName_1, "        ");
    _builder.append("\', \'action\' => \'");
    String _formatForCode_1 = this._formattingExtensions.formatForCode(actionName);
    String _firstLower = StringExtensions.toFirstLower(_formatForCode_1);
    _builder.append(_firstLower, "        ");
    _builder.append("\', \'mode\' => $this->mode);");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("$this->view->assign($repository->getAdditionalTemplateParameters(\'controllerAction\', $utilArgs));");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    CharSequence _redirectCodes = this.redirectHelper.getRedirectCodes(it, app, actionName);
    _builder.append(_redirectCodes, "    ");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    CharSequence _handleCommand = this.handleCommand(it, actionName);
    _builder.append(_handleCommand, "    ");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    CharSequence _fetchInputData = this.fetchInputData(it, actionName);
    _builder.append(_fetchInputData, "    ");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    CharSequence _applyAction = this.applyAction(it, actionName);
    _builder.append(_applyAction, "    ");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    UploadProcessing _uploadProcessing = new UploadProcessing();
    CharSequence _generate = _uploadProcessing.generate(it);
    _builder.append(_generate, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence initialize(final Controller it, final String actionName) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Initialize form handler.");
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
    _builder.append("* @param Zikula_Form_View $view The form view instance.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return boolean False in case of initialization errors, otherwise true.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function initialize(Zikula_Form_View $view)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$this->inlineUsage = ((UserUtil::getTheme() == \'Printer\') ? true : false);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$this->idPrefix = $this->request->query->filter(\'idp\', \'\', FILTER_SANITIZE_STRING);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// initialise redirect goal");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$this->returnTo = $this->request->query->filter(\'returnTo\', null, FILTER_SANITIZE_STRING);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// store current uri for repeated creations");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$this->repeatReturnUrl = System::getCurrentURI();");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$this->permissionComponent = $this->name . \':\' . $this->objectTypeCapital . \':\';");
    _builder.newLine();
    _builder.newLine();
    {
      boolean _targets = this._utils.targets(this.app, "1.3.5");
      if (_targets) {
        _builder.append("    ");
        _builder.append("$entityClass = $this->name . \'_Entity_\' . ucfirst($this->objectType);");
        _builder.newLine();
      } else {
        _builder.append("    ");
        _builder.append("$entityClass = \'\\\\");
        String _vendor = this.app.getVendor();
        String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(_vendor);
        _builder.append(_formatForCodeCapital, "    ");
        _builder.append("\\\\");
        String _name = this.app.getName();
        String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(_name);
        _builder.append(_formatForCodeCapital_1, "    ");
        _builder.append("Module\\\\Entity\\\\\' . ucwords($this->objectType) . \'Entity\';");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("    ");
    _builder.append("$objectTemp = new $entityClass();");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$this->idFields = $objectTemp->get_idFields();");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// retrieve identifier of the object we wish to view");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$controllerHelper = new ");
    {
      boolean _targets_1 = this._utils.targets(this.app, "1.3.5");
      if (_targets_1) {
        String _appName = this._utils.appName(this.app);
        _builder.append(_appName, "    ");
        _builder.append("_Util_Controller");
      } else {
        _builder.append("ControllerUtil");
      }
    }
    _builder.append("($this->view->getServiceManager()");
    {
      boolean _targets_2 = this._utils.targets(this.app, "1.3.5");
      boolean _not = (!_targets_2);
      if (_not) {
        _builder.append(", ModUtil::getModule($this->name)");
      }
    }
    _builder.append(");");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("$this->idValues = $controllerHelper->retrieveIdentifier($this->request, array(), $this->objectType, $this->idFields);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$hasIdentifier = $controllerHelper->isValidIdentifier($this->idValues);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$entity = null;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$this->mode = ($hasIdentifier) ? \'edit\' : \'create\';");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($this->mode == \'edit\') {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if (!SecurityUtil::checkPermission($this->permissionComponent, $this->createCompositeIdentifier() . \'::\', ACCESS_EDIT)) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("return LogUtil::registerPermissionError();");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$entity = $this->initEntityForEdit();");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if ($this->hasPageLockSupport === true && ModUtil::available(\'PageLock\')) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("// try to guarantee that only one person at a time can be editing this entity");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("ModUtil::apiFunc(\'PageLock\', \'user\', \'pageLock\',");
    _builder.newLine();
    _builder.append("                                     ");
    _builder.append("array(\'lockName\' => $this->name . $this->objectTypeCapital . $this->createCompositeIdentifier(),");
    _builder.newLine();
    _builder.append("                                           ");
    _builder.append("\'returnUrl\' => $this->getRedirectUrl(null)));");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("} else {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if (!SecurityUtil::checkPermission($this->permissionComponent, \'::\', ACCESS_EDIT)) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("return LogUtil::registerPermissionError();");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$entity = $this->initEntityForCreation();");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$this->view->assign(\'mode\', $this->mode)");
    _builder.newLine();
    _builder.append("               ");
    _builder.append("->assign(\'inlineUsage\', $this->inlineUsage);");
    _builder.newLine();
    {
      boolean _hasAttributableEntities = this._modelBehaviourExtensions.hasAttributableEntities(this.app);
      if (_hasAttributableEntities) {
        _builder.newLine();
        _builder.append("    ");
        _builder.append("if ($this->hasAttributes === true) {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("$this->initAttributesForEdit($entity);");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
      }
    }
    {
      boolean _hasCategorisableEntities = this._modelBehaviourExtensions.hasCategorisableEntities(this.app);
      if (_hasCategorisableEntities) {
        _builder.newLine();
        _builder.append("    ");
        _builder.append("if ($this->hasCategories === true) {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("$this->initCategoriesForEdit($entity);");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
      }
    }
    {
      boolean _hasMetaDataEntities = this._modelBehaviourExtensions.hasMetaDataEntities(this.app);
      if (_hasMetaDataEntities) {
        _builder.newLine();
        _builder.append("    ");
        _builder.append("if ($this->hasMetaData === true) {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("$this->initMetaDataForEdit($entity);");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
      }
    }
    {
      boolean _hasTranslatable = this._modelBehaviourExtensions.hasTranslatable(this.app);
      if (_hasTranslatable) {
        _builder.newLine();
        _builder.append("    ");
        _builder.append("if ($this->hasTranslatableFields === true) {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("$this->initTranslationsForEdit($entity);");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
      }
    }
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// save entity reference for later reuse");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$this->entityRef = $entity;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$workflowHelper = new ");
    {
      boolean _targets_3 = this._utils.targets(this.app, "1.3.5");
      if (_targets_3) {
        String _appName_1 = this._utils.appName(this.app);
        _builder.append(_appName_1, "    ");
        _builder.append("_Util_Workflow");
      } else {
        _builder.append("WorkflowUtil");
      }
    }
    _builder.append("($this->view->getServiceManager()");
    {
      boolean _targets_4 = this._utils.targets(this.app, "1.3.5");
      boolean _not_1 = (!_targets_4);
      if (_not_1) {
        _builder.append(", ModUtil::getModule($this->name)");
      }
    }
    _builder.append(");");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("$actions = $workflowHelper->getActionsForObject($entity);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($actions === false || !is_array($actions)) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return LogUtil::registerError($this->__(\'Error! Could not determine workflow actions.\'));");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// assign list of allowed actions to the view for further processing");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$this->view->assign(\'actions\', $actions);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// everything okay, no initialization errors occured");
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
    _builder.append("* Create concatenated identifier string (for composite keys).");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return String concatenated identifiers. ");
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
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Enrich a given args array for easy creation of display urls with composite keys.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param Array $args List of arguments to be extended.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return Array Enriched arguments list. ");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected function addIdentifiersToUrlArgs($args = array())");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("foreach ($this->idFields as $idField) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$args[$idField] = $this->idValues[$idField];");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $args;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Initialise existing entity for editing.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return Zikula_EntityAccess desired entity instance or null");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected function initEntityForEdit()");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$entity = ModUtil::apiFunc($this->name, \'selection\', \'getEntity\', array(\'ot\' => $this->objectType, \'id\' => $this->idValues));");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($entity == null) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return LogUtil::registerError($this->__(\'No such item.\'));");
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
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Initialise new entity for creation.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return Zikula_EntityAccess desired entity instance or null");
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
    _builder.append("if (!empty($templateId)) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$templateIdValueParts = explode(\'_\', $templateId);");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$this->hasTemplateId = (count($templateIdValueParts) == count($this->idFields));");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($this->hasTemplateId === true) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$templateIdValues = array();");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$i = 0;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("foreach ($this->idFields as $idField) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$templateIdValues[$idField] = $templateIdValueParts[$i];");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$i++;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// reuse existing entity");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$entityT = ModUtil::apiFunc($this->name, \'selection\', \'getEntity\', array(\'ot\' => $this->objectType, \'id\' => $templateIdValues));");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if ($entityT == null) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("return LogUtil::registerError($this->__(\'No such item.\'));");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$entity = clone $entityT;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$entity->resetWorkflow();");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("} else {");
    _builder.newLine();
    {
      boolean _targets_5 = this._utils.targets(this.app, "1.3.5");
      if (_targets_5) {
        _builder.append("        ");
        _builder.append("$entityClass = $this->name . \'_Entity_\' . ucfirst($this->objectType);");
        _builder.newLine();
      } else {
        _builder.append("        ");
        _builder.append("$entityClass = \'\\\\");
        String _vendor_1 = this.app.getVendor();
        String _formatForCodeCapital_2 = this._formattingExtensions.formatForCodeCapital(_vendor_1);
        _builder.append(_formatForCodeCapital_2, "        ");
        _builder.append("\\\\");
        String _name_1 = this.app.getName();
        String _formatForCodeCapital_3 = this._formattingExtensions.formatForCodeCapital(_name_1);
        _builder.append(_formatForCodeCapital_3, "        ");
        _builder.append("Module\\\\Entity\\\\\' . ucwords($this->objectType) . \'Entity\';");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("        ");
    _builder.append("$entity = new $entityClass();");
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
    {
      boolean _hasTranslatable_1 = this._modelBehaviourExtensions.hasTranslatable(this.app);
      if (_hasTranslatable_1) {
        _builder.newLine();
        _builder.append("/**");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Initialise translations.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @param Zikula_EntityAccess $entity treated entity instance.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
        _builder.append("protected function initTranslationsForEdit($entity)");
        _builder.newLine();
        _builder.append("{");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("// retrieve translated fields");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$translatableHelper = new ");
        {
          boolean _targets_6 = this._utils.targets(this.app, "1.3.5");
          if (_targets_6) {
            String _appName_2 = this._utils.appName(this.app);
            _builder.append(_appName_2, "    ");
            _builder.append("_Util_Translatable");
          } else {
            _builder.append("TranslatableUtil");
          }
        }
        _builder.append("($this->view->getServiceManager()");
        {
          boolean _targets_7 = this._utils.targets(this.app, "1.3.5");
          boolean _not_2 = (!_targets_7);
          if (_not_2) {
            _builder.append(", ModUtil::getModule($this->name)");
          }
        }
        _builder.append(");");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("$translations = $translatableHelper->prepareEntityForEdit($this->objectType, $entity);");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("// assign translations");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("foreach ($translations as $locale => $translationData) {");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("$this->view->assign($this->objectTypeLower . $locale, $translationData);");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("// assign list of installed languages for translatable extension");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$this->view->assign(\'supportedLocales\', ZLanguage::getInstalledLanguages());");
        _builder.newLine();
        _builder.append("}");
        _builder.newLine();
      }
    }
    {
      boolean _hasAttributableEntities_1 = this._modelBehaviourExtensions.hasAttributableEntities(this.app);
      if (_hasAttributableEntities_1) {
        _builder.newLine();
        _builder.append("/**");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Initialise attributes.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @param Zikula_EntityAccess $entity treated entity instance.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
        _builder.append("protected function initAttributesForEdit($entity)");
        _builder.newLine();
        _builder.append("{");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$entityData = array();");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("// overwrite attributes array entry with a form compatible format");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$attributes = array();");
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
        _builder.append("$this->view->assign($entityData);");
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
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @return array list of attribute names.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
        _builder.append("protected function getAttributeFieldNames()");
        _builder.newLine();
        _builder.append("{");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("return array(\'field1\', \'field2\', \'field3\');");
        _builder.newLine();
        _builder.append("}");
        _builder.newLine();
      }
    }
    {
      boolean _hasCategorisableEntities_1 = this._modelBehaviourExtensions.hasCategorisableEntities(this.app);
      if (_hasCategorisableEntities_1) {
        _builder.newLine();
        _builder.append("/**");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Initialise categories.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @param Zikula_EntityAccess $entity treated entity instance.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
        _builder.append("protected function initCategoriesForEdit($entity)");
        _builder.newLine();
        _builder.append("{");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("// assign the actual object for categories listener");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$this->view->assign($this->objectTypeLower . \'Obj\', $entity);");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("// load and assign registered categories");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$registries = ModUtil::apiFunc($this->name, \'category\', \'getAllPropertiesWithMainCat\', array(\'ot\' => $this->objectType, \'arraykey\' => $this->idFields[0]));");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("// check if multiple selection is allowed for this object type");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$multiSelectionPerRegistry = array();");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("foreach ($registries as $registryId => $registryCid) {");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("$multiSelectionPerRegistry[$registryId] = ModUtil::apiFunc($this->name, \'category\', \'hasMultipleSelection\', array(\'ot\' => $this->objectType, \'registry\' => $registryId));");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$this->view->assign(\'registries\', $registries)");
        _builder.newLine();
        _builder.append("               ");
        _builder.append("->assign(\'multiSelectionPerRegistry\', $multiSelectionPerRegistry);");
        _builder.newLine();
        _builder.append("}");
        _builder.newLine();
      }
    }
    {
      boolean _hasMetaDataEntities_1 = this._modelBehaviourExtensions.hasMetaDataEntities(this.app);
      if (_hasMetaDataEntities_1) {
        _builder.newLine();
        _builder.append("/**");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Initialise meta data.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @param Zikula_EntityAccess $entity treated entity instance.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
        _builder.append("protected function initMetaDataForEdit($entity)");
        _builder.newLine();
        _builder.append("{");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$metaData = $entity->getMetadata() != null? $entity->getMetadata()->toArray() : array();");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$this->view->assign(\'meta\', $metaData);");
        _builder.newLine();
        _builder.append("}");
        _builder.newLine();
      }
    }
    return _builder;
  }
  
  private CharSequence handleCommand(final Controller it, final String actionName) {
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
    _builder.append("* This event handler is called when a command is issued by the user. Commands are typically something");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* that originates from a {@link Zikula_Form_Plugin_Button} plugin. The passed args contains different properties");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* depending on the command source, but you should at least find a <var>$args[\'commandName\']</var>");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* value indicating the name of the command. The command name is normally specified by the plugin");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* that initiated the command.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param Zikula_Form_View $view The form view instance.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param array            $args Additional arguments.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @see Zikula_Form_Plugin_Button");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @see Zikula_Form_Plugin_ImageButton");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return mixed Redirect or false on errors.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function handleCommand(Zikula_Form_View $view, &$args)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$action = $args[\'commandName\'];");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$isRegularAction = !in_array($action, array(\'delete\', \'cancel\'));");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($isRegularAction) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// do forms validation including checking all validators on the page to validate their input");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if (!$this->view->isValid()) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("return false;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($action != \'cancel\') {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$otherFormData = $this->fetchInputData($view, $args);");
    _builder.newLine();
    _builder.append("    \t");
    _builder.append("if ($otherFormData === false) {");
    _builder.newLine();
    _builder.append("        \t");
    _builder.append("return false;");
    _builder.newLine();
    _builder.append("    \t");
    _builder.append("}");
    _builder.newLine();
    _builder.append("\t");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// get treated entity reference from persisted member var");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$entity = $this->entityRef;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$hookAreaPrefix = $entity->getHookAreaPrefix();");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($action != \'cancel\') {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$hookType = $action == \'delete\' ? \'validate_delete\' : \'validate_edit\';");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// Let any hooks perform additional validation actions");
    _builder.newLine();
    {
      boolean _targets = this._utils.targets(this.app, "1.3.5");
      if (_targets) {
        _builder.append("        ");
        _builder.append("$hook = new Zikula_ValidationHook($hookAreaPrefix . \'.\' . $hookType, new Zikula_Hook_ValidationProviders());");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("$validators = $this->notifyHooks($hook)->getValidators();");
        _builder.newLine();
      } else {
        _builder.append("        ");
        _builder.append("$hook = new ValidationHook(new ValidationProviders());");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("$validators = $this->dispatchHooks($hookAreaPrefix . \'.\' . $hookType, $hook)->getValidators();");
        _builder.newLine();
      }
    }
    _builder.append("        ");
    _builder.append("if ($validators->hasErrors()) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("return false;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    {
      boolean _hasTranslatable = this._modelBehaviourExtensions.hasTranslatable(this.app);
      if (_hasTranslatable) {
        _builder.newLine();
        _builder.append("    ");
        _builder.append("if ($isRegularAction && $this->hasTranslatableFields === true) {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("$this->processTranslationsForUpdate($entity, $otherFormData);");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
      }
    }
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($action != \'cancel\') {");
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
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// Let any hooks know that we have created, updated or deleted an item");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$hookType = $action == \'delete\' ? \'process_delete\' : \'process_edit\';");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$url = null;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if ($action != \'delete\') {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$urlArgs = array(\'ot\' => $this->objectType);");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$urlArgs = $this->addIdentifiersToUrlArgs($urlArgs);");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("if (isset($this->entityRef[\'slug\'])) {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("$urlArgs[\'slug\'] = $this->entityRef[\'slug\'];");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$url = new ");
    {
      boolean _targets_1 = this._utils.targets(this.app, "1.3.5");
      if (_targets_1) {
        _builder.append("Zikula_");
      }
    }
    _builder.append("ModUrl($this->name, \'");
    String _formattedName = this._controllerExtensions.formattedName(it);
    _builder.append(_formattedName, "            ");
    _builder.append("\', \'display\', ZLanguage::getLanguageCode(), $urlArgs);");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    {
      boolean _targets_2 = this._utils.targets(this.app, "1.3.5");
      if (_targets_2) {
        _builder.append("        ");
        _builder.append("$hook = new Zikula_ProcessHook($hookAreaPrefix . \'.\' . $hookType, $this->createCompositeIdentifier(), $url);");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("$this->notifyHooks($hook);");
        _builder.newLine();
      } else {
        _builder.append("        ");
        _builder.append("$hook = new ProcessHook($this->createCompositeIdentifier(), $url);");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("$this->dispatchHooks($hookAreaPrefix . \'.\' . $hookType, $hook);");
        _builder.newLine();
      }
    }
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// An item was created, updated or deleted, so we clear all cached pages for this item.");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$cacheArgs = array(\'ot\' => $this->objectType, \'item\' => $entity);");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("ModUtil::apiFunc($this->name, \'cache\', \'clearItemCache\', $cacheArgs);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// clear view cache to reflect our changes");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$this->view->clear_cache();");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($this->hasPageLockSupport === true && $this->mode == \'edit\' && ModUtil::available(\'PageLock\')) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("ModUtil::apiFunc(\'PageLock\', \'user\', \'releaseLock\',");
    _builder.newLine();
    _builder.append("                         ");
    _builder.append("array(\'lockName\' => $this->name . $this->objectTypeCapital . $this->createCompositeIdentifier()));");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $this->view->redirect($this->getRedirectUrl($args));");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    {
      boolean _hasAttributableEntities = this._modelBehaviourExtensions.hasAttributableEntities(this.app);
      if (_hasAttributableEntities) {
        _builder.newLine();
        _builder.append("/**");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Prepare update of attributes.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @param Zikula_EntityAccess $entity   currently treated entity instance.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @param Array               $formData form data to be merged.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
        _builder.append("protected function processAttributesForUpdate($entity, $formData)");
        _builder.newLine();
        _builder.append("{");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("if (!isset($formData[\'attributes\'])) {");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("return;");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("foreach($formData[\'attributes\'] as $name => $value) {");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("$entity->setAttribute($name, $value);");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
        _builder.append("    ");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("unset($formData[\'attributes\']);");
        _builder.newLine();
        _builder.append("}");
        _builder.newLine();
      }
    }
    {
      boolean _hasCategorisableEntities = this._modelBehaviourExtensions.hasCategorisableEntities(this.app);
      if (_hasCategorisableEntities) {
        _builder.newLine();
        _builder.append("/**");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Prepare update of categories.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @param Zikula_EntityAccess $entity     currently treated entity instance.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @param Array               $entityData form data to be merged.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
        _builder.append("protected function processCategoriesForUpdate($entity, $entityData)");
        _builder.newLine();
        _builder.append("{");
        _builder.newLine();
        _builder.append("}");
        _builder.newLine();
      }
    }
    {
      boolean _hasMetaDataEntities = this._modelBehaviourExtensions.hasMetaDataEntities(this.app);
      if (_hasMetaDataEntities) {
        _builder.newLine();
        _builder.append("/**");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Prepare update of meta data.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @param Zikula_EntityAccess $entity     currently treated entity instance.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @param Array               $entityData form data to be merged.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
        _builder.append("protected function processMetaDataForUpdate($entity, $entityData)");
        _builder.newLine();
        _builder.append("{");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$metaData = $entity->getMetadata();");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("if (is_null($metaData)) {");
        _builder.newLine();
        {
          boolean _targets_3 = this._utils.targets(this.app, "1.3.5");
          if (_targets_3) {
            _builder.append("        ");
            _builder.append("$metaDataEntityClass = $this->name . \'_Entity_\' . ucfirst($this->objectType) . \'MetaData\';");
            _builder.newLine();
          } else {
            _builder.append("        ");
            _builder.append("$metaDataEntityClass = \'\\\\\' . $this->name . \'\\\\Entity\\\\\' . ucfirst($this->objectType) . \'MetaDataEntity\';");
            _builder.newLine();
          }
        }
        _builder.append("        ");
        _builder.append("$metaData = new $metaDataEntityClass($entity);");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$metaData->merge($entityData[\'meta\']);");
        _builder.newLine();
        _builder.append("    ");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$entity->setMetadata($metaData);");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("unset($entityData[\'meta\']);");
        _builder.newLine();
        _builder.append("}");
        _builder.newLine();
      }
    }
    {
      boolean _hasTranslatable_1 = this._modelBehaviourExtensions.hasTranslatable(this.app);
      if (_hasTranslatable_1) {
        _builder.newLine();
        _builder.append("/**");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Prepare update of translations.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @param Zikula_EntityAccess $entity   currently treated entity instance.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @param Array               $formData additional form data outside the entity scope.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
        _builder.append("protected function processTranslationsForUpdate($entity, $formData)");
        _builder.newLine();
        _builder.append("{");
        _builder.newLine();
        {
          boolean _targets_4 = this._utils.targets(this.app, "1.3.5");
          if (_targets_4) {
            _builder.append("    ");
            _builder.append("$entityTransClass = $this->name . \'_Entity_\' . ucwords($this->objectType) . \'Translation\';");
            _builder.newLine();
          } else {
            _builder.append("    ");
            _builder.append("$entityTransClass = \'\\\\\' . $this->name . \'\\\\Entity\\\\\' . ucwords($this->objectType) . \'TranslationEntity\';");
            _builder.newLine();
          }
        }
        _builder.append("    ");
        _builder.append("$transRepository = $this->entityManager->getRepository($entityTransClass);");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$translatableHelper = new ");
        {
          boolean _targets_5 = this._utils.targets(this.app, "1.3.5");
          if (_targets_5) {
            Controllers _container = it.getContainer();
            Application _application = _container.getApplication();
            String _appName = this._utils.appName(_application);
            _builder.append(_appName, "    ");
            _builder.append("_Util_Translatable");
          } else {
            _builder.append("TranslatableUtil");
          }
        }
        _builder.append("($this->view->getServiceManager()");
        {
          boolean _targets_6 = this._utils.targets(this.app, "1.3.5");
          boolean _not = (!_targets_6);
          if (_not) {
            _builder.append(", ModUtil::getModule($this->name)");
          }
        }
        _builder.append(");");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("$translations = $translatableHelper->processEntityAfterEdit($this->objectType, $formData);");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("foreach ($translations as $translation) {");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("foreach ($translation[\'fields\'] as $fieldName => $value) {");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("$transRepository->translate($entity, $fieldName, $translation[\'locale\'], $value);");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("// save updated entity");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$this->entityRef = $entity;");
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
    _builder.append("* @param Array   $args    arguments from handleCommand method.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param Boolean $success true if this is a success, false for default error.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return String desired status or error message.");
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
    _builder.append("                ");
    _builder.append("if ($success === true) {");
    _builder.newLine();
    _builder.append("                    ");
    _builder.append("$message = $this->__(\'Done! Item created.\');");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("} else {");
    _builder.newLine();
    _builder.append("                    ");
    _builder.append("$message = $this->__(\'Error! Creation attempt failed.\');");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("break;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("case \'update\':");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("if ($success === true) {");
    _builder.newLine();
    _builder.append("                    ");
    _builder.append("$message = $this->__(\'Done! Item updated.\');");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("} else {");
    _builder.newLine();
    _builder.append("                    ");
    _builder.append("$message = $this->__(\'Error! Update attempt failed.\');");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("break;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("case \'delete\':");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("if ($success === true) {");
    _builder.newLine();
    _builder.append("                    ");
    _builder.append("$message = $this->__(\'Done! Item deleted.\');");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("} else {");
    _builder.newLine();
    _builder.append("                    ");
    _builder.append("$message = $this->__(\'Error! Deletion attempt failed.\');");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("                ");
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
    _builder.append("* @param Array   $args    arguments from handleCommand method.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param Boolean $success true if this is a success, false for default error.");
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
    _builder.append("if (!empty($message)) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if ($success === true) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("LogUtil::registerStatus($message);");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("} else {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("LogUtil::registerError($message);");
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
  
  private CharSequence fetchInputData(final Controller it, final String actionName) {
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
    _builder.append("* @param Zikula_Form_View $view The form view instance.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param array            $args Additional arguments.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return array form data after processing.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function fetchInputData(Zikula_Form_View $view, &$args)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// fetch posted data input values as an associative array");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$formData = $this->view->getValues();");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// we want the array with our field values");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$entityData = $formData[$this->objectTypeLower];");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("unset($formData[$this->objectTypeLower]);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// get treated entity reference from persisted member var");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$entity = $this->entityRef;");
    _builder.newLine();
    _builder.newLine();
    {
      boolean _or = false;
      boolean _or_1 = false;
      boolean _or_2 = false;
      boolean _hasUserFields = this._modelExtensions.hasUserFields(this.app);
      if (_hasUserFields) {
        _or_2 = true;
      } else {
        boolean _hasUploads = this._modelExtensions.hasUploads(this.app);
        _or_2 = (_hasUserFields || _hasUploads);
      }
      if (_or_2) {
        _or_1 = true;
      } else {
        boolean _hasListFields = this._modelExtensions.hasListFields(this.app);
        _or_1 = (_or_2 || _hasListFields);
      }
      if (_or_1) {
        _or = true;
      } else {
        boolean _and = false;
        boolean _hasSluggable = this._modelBehaviourExtensions.hasSluggable(this.app);
        if (!_hasSluggable) {
          _and = false;
        } else {
          EList<Entity> _allEntities = this._modelExtensions.getAllEntities(this.app);
          final Function1<Entity,Boolean> _function = new Function1<Entity,Boolean>() {
              public Boolean apply(final Entity e) {
                boolean _isSlugUpdatable = e.isSlugUpdatable();
                return Boolean.valueOf(_isSlugUpdatable);
              }
            };
          Iterable<Entity> _filter = IterableExtensions.<Entity>filter(_allEntities, _function);
          boolean _isEmpty = IterableExtensions.isEmpty(_filter);
          boolean _not = (!_isEmpty);
          _and = (_hasSluggable && _not);
        }
        _or = (_or_1 || _and);
      }
      if (_or) {
        _builder.newLine();
        _builder.append("    ");
        _builder.append("if ($args[\'commandName\'] != \'cancel\') {");
        _builder.newLine();
        {
          boolean _hasUserFields_1 = this._modelExtensions.hasUserFields(this.app);
          if (_hasUserFields_1) {
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("if (count($this->userFields) > 0) {");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("foreach ($this->userFields as $userField => $isMandatory) {");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("        ");
            _builder.append("$entityData[$userField] = (int) $this->request->request->filter($userField, 0, FILTER_VALIDATE_INT);");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("        ");
            _builder.append("unset($entityData[$userField . \'Selector\']);");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("}");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("}");
            _builder.newLine();
            _builder.newLine();
          }
        }
        {
          boolean _hasUploads_1 = this._modelExtensions.hasUploads(this.app);
          if (_hasUploads_1) {
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("if (count($this->uploadFields) > 0) {");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("$entityData = $this->handleUploads($entityData, $entity);");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("if ($entityData == false) {");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("        ");
            _builder.append("return false;");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("}");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("}");
            _builder.newLine();
            _builder.newLine();
          }
        }
        {
          boolean _hasListFields_1 = this._modelExtensions.hasListFields(this.app);
          if (_hasListFields_1) {
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("if (count($this->listFields) > 0) {");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("foreach ($this->listFields as $listField => $multiple) {");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("        ");
            _builder.append("if (!$multiple) {");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("            ");
            _builder.append("continue;");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("        ");
            _builder.append("}");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("        ");
            _builder.append("if (is_array($entityData[$listField])) { ");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("            ");
            _builder.append("$values = $entityData[$listField];");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("            ");
            _builder.append("$entityData[$listField] = \'\';");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("            ");
            _builder.append("if (count($values) > 0) {");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("                ");
            _builder.append("$entityData[$listField] = \'###\' . implode(\'###\', $values) . \'###\';");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("            ");
            _builder.append("}");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("        ");
            _builder.append("}");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("}");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("}");
            _builder.newLine();
          }
        }
        {
          boolean _and_1 = false;
          boolean _targets = this._utils.targets(this.app, "1.3.5");
          boolean _not_1 = (!_targets);
          if (!_not_1) {
            _and_1 = false;
          } else {
            boolean _hasSluggable_1 = this._modelBehaviourExtensions.hasSluggable(this.app);
            _and_1 = (_not_1 && _hasSluggable_1);
          }
          if (_and_1) {
            _builder.newLine();
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("if ($this->hasSlugUpdatableField === true && isset($entityData[\'slug\'])) {");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("$controllerHelper = new ControllerUtil($this->view->getServiceManager());");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("$entityData[\'slug\'] = $controllerHelper->formatPermalink($entityData[\'slug\']);");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("}");
            _builder.newLine();
          }
        }
        {
          boolean _hasUploads_2 = this._modelExtensions.hasUploads(this.app);
          if (_hasUploads_2) {
            _builder.append("    ");
            _builder.append("} else {");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("// remove fields for form options to prevent them being merged into the entity object");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("if (count($this->uploadFields) > 0) {");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("        ");
            _builder.append("foreach ($this->uploadFields as $uploadField => $isMandatory) {");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("            ");
            _builder.append("if (isset($entityData[$uploadField . \'DeleteFile\'])) {");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("                ");
            _builder.append("unset($entityData[$uploadField . \'DeleteFile\']);");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("            ");
            _builder.append("}");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("        ");
            _builder.append("}");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("}");
            _builder.newLine();
          }
        }
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
      }
    }
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (isset($entityData[\'repeatcreation\'])) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if ($this->mode == \'create\') {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$this->repeatCreateAction = $entityData[\'repeatcreation\'];");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("unset($entityData[\'repeatcreation\']);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    {
      boolean _hasAttributableEntities = this._modelBehaviourExtensions.hasAttributableEntities(this.app);
      if (_hasAttributableEntities) {
        _builder.newLine();
        _builder.append("    ");
        _builder.append("if ($this->hasAttributes === true) {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("$this->processAttributesForUpdate($entity, $formData);");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
      }
    }
    {
      boolean _hasMetaDataEntities = this._modelBehaviourExtensions.hasMetaDataEntities(this.app);
      if (_hasMetaDataEntities) {
        _builder.newLine();
        _builder.append("    ");
        _builder.append("if ($this->hasMetaData === true) {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("$this->processMetaDataForUpdate($entity, $entityData);");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
      }
    }
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// search for relationship plugins to update the corresponding data");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$entityData = $this->writeRelationDataToEntity($view, $entity, $entityData);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// assign fetched data");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$entity->merge($entityData);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// we must persist related items now (after the merge) to avoid validation errors");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// if cascades cause the main entity becoming persisted automatically, too");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$this->persistRelationData($view);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// save updated entity");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$this->entityRef = $entity;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// return remaining form data");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $formData;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Updates the entity with new relationship data.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param Zikula_Form_View    $view       The form view instance.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param Zikula_EntityAccess $entity     Reference to the updated entity.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param array               $entityData Entity related form data.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return array form data after processing.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected function writeRelationDataToEntity(Zikula_Form_View $view, $entity, $entityData)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$entityData = $this->writeRelationDataToEntity_rec($entity, $entityData, $view->plugins);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $entityData;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Searches for relationship plugins to write their updated values");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* back to the given entity.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param Zikula_EntityAccess $entity     Reference to the updated entity.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param array               $entityData Entity related form data.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param array               $plugins    List of form plugin which are searched.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return array form data after processing.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected function writeRelationDataToEntity_rec($entity, $entityData, $plugins)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("foreach ($plugins as $plugin) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if ($plugin instanceof ");
    {
      boolean _targets_1 = this._utils.targets(this.app, "1.3.5");
      if (_targets_1) {
        String _appName = this._utils.appName(this.app);
        _builder.append(_appName, "        ");
        _builder.append("_Form_Plugin_AbstractObjectSelector");
      } else {
        _builder.append("AbstractObjectSelector");
      }
    }
    _builder.append(" && method_exists($plugin, \'assignRelatedItemsToEntity\')) {");
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    _builder.append("$entityData = $plugin->assignRelatedItemsToEntity($entity, $entityData);");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$entityData = $this->writeRelationDataToEntity_rec($entity, $entityData, $plugin->plugins);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $entityData;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Persists any related items.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param Zikula_Form_View $view The form view instance.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected function persistRelationData(Zikula_Form_View $view)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$this->persistRelationData_rec($view->plugins);");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Searches for relationship plugins to persist their related items.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected function persistRelationData_rec($plugins)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("foreach ($plugins as $plugin) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if ($plugin instanceof ");
    {
      boolean _targets_2 = this._utils.targets(this.app, "1.3.5");
      if (_targets_2) {
        String _appName_1 = this._utils.appName(this.app);
        _builder.append(_appName_1, "        ");
        _builder.append("_Form_Plugin_AbstractObjectSelector");
      } else {
        _builder.append("AbstractObjectSelector");
      }
    }
    _builder.append(" && method_exists($plugin, \'persistRelatedItems\')) {");
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    _builder.append("$plugin->persistRelatedItems();");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$this->persistRelationData_rec($plugin->plugins);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence applyAction(final Controller it, final String actionName) {
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
    _builder.append("* @param Array $args Arguments from handleCommand method.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return bool Whether everything worked well or not.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function applyAction(array $args = array())");
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
  
  private CharSequence formHandlerCommonImpl(final Controller it, final String actionName) {
    StringConcatenation _builder = new StringConcatenation();
    Controllers _container = it.getContainer();
    final Application app = _container.getApplication();
    _builder.newLineIfNotEmpty();
    {
      boolean _targets = this._utils.targets(app, "1.3.5");
      boolean _not = (!_targets);
      if (_not) {
        _builder.append("namespace ");
        String _appNamespace = this._utils.appNamespace(app);
        _builder.append(_appNamespace, "");
        _builder.append("\\Form\\Handler\\");
        String _name = it.getName();
        String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(_name);
        _builder.append(_formatForCodeCapital, "");
        _builder.append(";");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
      }
    }
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* This handler class handles the page events of the Form called by the ");
    String _appName = this._utils.appName(app);
    String _plus = (_appName + "_");
    String _formattedName = this._controllerExtensions.formattedName(it);
    String _plus_1 = (_plus + _formattedName);
    String _plus_2 = (_plus_1 + "_");
    String _plus_3 = (_plus_2 + actionName);
    String _formatForCode = this._formattingExtensions.formatForCode(_plus_3);
    _builder.append(_formatForCode, " ");
    _builder.append("() function.");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("* It collects common functionality required by different object types.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    {
      boolean _targets_1 = this._utils.targets(app, "1.3.5");
      if (_targets_1) {
        _builder.append("class ");
        String _appName_1 = this._utils.appName(app);
        _builder.append(_appName_1, "");
        _builder.append("_Form_Handler_");
        String _name_1 = it.getName();
        String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(_name_1);
        _builder.append(_formatForCodeCapital_1, "");
        _builder.append("_");
        String _formatForCodeCapital_2 = this._formattingExtensions.formatForCodeCapital(actionName);
        _builder.append(_formatForCodeCapital_2, "");
        _builder.append(" extends ");
        String _appName_2 = this._utils.appName(app);
        _builder.append(_appName_2, "");
        _builder.append("_Form_Handler_");
        String _name_2 = it.getName();
        String _formatForCodeCapital_3 = this._formattingExtensions.formatForCodeCapital(_name_2);
        _builder.append(_formatForCodeCapital_3, "");
        _builder.append("_Base_");
        String _formatForCodeCapital_4 = this._formattingExtensions.formatForCodeCapital(actionName);
        _builder.append(_formatForCodeCapital_4, "");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("class ");
        String _formatForCodeCapital_5 = this._formattingExtensions.formatForCodeCapital(actionName);
        _builder.append(_formatForCodeCapital_5, "");
        _builder.append("Handler extends Base\\");
        String _formatForCodeCapital_6 = this._formattingExtensions.formatForCodeCapital(actionName);
        _builder.append(_formatForCodeCapital_6, "");
        _builder.append("Handler");
        _builder.newLineIfNotEmpty();
      }
    }
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
    Models _container = it.getContainer();
    final Application app = _container.getApplication();
    _builder.newLineIfNotEmpty();
    {
      boolean _targets = this._utils.targets(app, "1.3.5");
      boolean _not = (!_targets);
      if (_not) {
        _builder.append("namespace ");
        String _appNamespace = this._utils.appNamespace(app);
        _builder.append(_appNamespace, "");
        _builder.append("\\Form\\Handler\\");
        String _name = this.controller.getName();
        String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(_name);
        _builder.append(_formatForCodeCapital, "");
        _builder.append("\\");
        String _name_1 = it.getName();
        String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(_name_1);
        _builder.append(_formatForCodeCapital_1, "");
        _builder.append("\\Base;");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
        _builder.append("use ");
        String _appNamespace_1 = this._utils.appNamespace(app);
        _builder.append(_appNamespace_1, "");
        _builder.append("\\Util\\ControllerUtil;");
        _builder.newLineIfNotEmpty();
        {
          boolean _hasListFields = this._modelExtensions.hasListFields(app);
          if (_hasListFields) {
            _builder.append("use ");
            String _appNamespace_2 = this._utils.appNamespace(app);
            _builder.append(_appNamespace_2, "");
            _builder.append("\\Util\\ListEntriesUtil;");
            _builder.newLineIfNotEmpty();
          }
        }
        _builder.append("use ");
        String _appNamespace_3 = this._utils.appNamespace(app);
        _builder.append(_appNamespace_3, "");
        _builder.append("\\Util\\WorkflowUtil;");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
      }
    }
    {
      boolean _or = false;
      boolean _or_1 = false;
      boolean _hasOptimisticLock = this._modelExtensions.hasOptimisticLock(it);
      if (_hasOptimisticLock) {
        _or_1 = true;
      } else {
        boolean _hasPessimisticReadLock = this._modelExtensions.hasPessimisticReadLock(it);
        _or_1 = (_hasOptimisticLock || _hasPessimisticReadLock);
      }
      if (_or_1) {
        _or = true;
      } else {
        boolean _hasPessimisticWriteLock = this._modelExtensions.hasPessimisticWriteLock(it);
        _or = (_or_1 || _hasPessimisticWriteLock);
      }
      if (_or) {
        _builder.append("use Doctrine\\DBAL\\LockMode;");
        _builder.newLine();
        {
          boolean _hasOptimisticLock_1 = this._modelExtensions.hasOptimisticLock(it);
          if (_hasOptimisticLock_1) {
            _builder.append("use Doctrine\\ORM\\OptimisticLockException;");
            _builder.newLine();
          }
        }
      }
    }
    {
      boolean _targets_1 = this._utils.targets(app, "1.3.5");
      boolean _not_1 = (!_targets_1);
      if (_not_1) {
        _builder.newLine();
        _builder.append("use FormUtil;");
        _builder.newLine();
        _builder.append("use LogUtil;");
        _builder.newLine();
        _builder.append("use ModUtil;");
        _builder.newLine();
        _builder.append("use SecurityUtil;");
        _builder.newLine();
        {
          boolean _hasOptimisticLock_2 = this._modelExtensions.hasOptimisticLock(it);
          if (_hasOptimisticLock_2) {
            _builder.append("use SessionUtil;");
            _builder.newLine();
          }
        }
        _builder.append("use System;");
        _builder.newLine();
        _builder.append("use UserUtil;");
        _builder.newLine();
        _builder.append("use Zikula_Form_View;");
        _builder.newLine();
      }
    }
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* This handler class handles the page events of the Form called by the ");
    String _appName = this._utils.appName(app);
    String _plus = (_appName + "_");
    String _formattedName = this._controllerExtensions.formattedName(this.controller);
    String _plus_1 = (_plus + _formattedName);
    String _plus_2 = (_plus_1 + "_");
    String _plus_3 = (_plus_2 + actionName);
    String _formatForCode = this._formattingExtensions.formatForCode(_plus_3);
    _builder.append(_formatForCode, " ");
    _builder.append("() function.");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("* It aims on the ");
    String _name_2 = it.getName();
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(_name_2);
    _builder.append(_formatForDisplay, " ");
    _builder.append(" object type.");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* More documentation is provided in the parent class.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    {
      boolean _targets_2 = this._utils.targets(app, "1.3.5");
      if (_targets_2) {
        _builder.append("class ");
        String _appName_1 = this._utils.appName(app);
        _builder.append(_appName_1, "");
        _builder.append("_Form_Handler_");
        String _name_3 = this.controller.getName();
        String _formatForCodeCapital_2 = this._formattingExtensions.formatForCodeCapital(_name_3);
        _builder.append(_formatForCodeCapital_2, "");
        _builder.append("_");
        String _name_4 = it.getName();
        String _formatForCodeCapital_3 = this._formattingExtensions.formatForCodeCapital(_name_4);
        _builder.append(_formatForCodeCapital_3, "");
        _builder.append("_Base_");
        String _formatForCodeCapital_4 = this._formattingExtensions.formatForCodeCapital(actionName);
        _builder.append(_formatForCodeCapital_4, "");
        _builder.append(" extends ");
        String _appName_2 = this._utils.appName(app);
        _builder.append(_appName_2, "");
        _builder.append("_Form_Handler_");
        String _name_5 = this.controller.getName();
        String _formatForCodeCapital_5 = this._formattingExtensions.formatForCodeCapital(_name_5);
        _builder.append(_formatForCodeCapital_5, "");
        _builder.append("_");
        String _formatForCodeCapital_6 = this._formattingExtensions.formatForCodeCapital(actionName);
        _builder.append(_formatForCodeCapital_6, "");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("class ");
        String _formatForCodeCapital_7 = this._formattingExtensions.formatForCodeCapital(actionName);
        _builder.append(_formatForCodeCapital_7, "");
        _builder.append("Handler extends \\");
        String _appName_3 = this._utils.appName(app);
        _builder.append(_appName_3, "");
        _builder.append("\\Form\\Handler\\");
        String _formattedName_1 = this._controllerExtensions.formattedName(this.controller);
        String _firstUpper = StringExtensions.toFirstUpper(_formattedName_1);
        _builder.append(_firstUpper, "");
        _builder.append("\\");
        String _formatForCodeCapital_8 = this._formattingExtensions.formatForCodeCapital(actionName);
        _builder.append(_formatForCodeCapital_8, "");
        _builder.append("Handler");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* Pre-initialise hook.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @return void");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("public function preInitialize()");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("parent::preInitialize();");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$this->objectType = \'");
    String _name_6 = it.getName();
    String _formatForCode_1 = this._formattingExtensions.formatForCode(_name_6);
    _builder.append(_formatForCode_1, "        ");
    _builder.append("\';");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("$this->objectTypeCapital = \'");
    String _name_7 = it.getName();
    String _formatForCodeCapital_9 = this._formattingExtensions.formatForCodeCapital(_name_7);
    _builder.append(_formatForCodeCapital_9, "        ");
    _builder.append("\';");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("$this->objectTypeLower = \'");
    String _name_8 = it.getName();
    String _formatForDB = this._formattingExtensions.formatForDB(_name_8);
    _builder.append(_formatForDB, "        ");
    _builder.append("\';");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$this->hasPageLockSupport = ");
    boolean _hasPageLockSupport = this._modelExtensions.hasPageLockSupport(it);
    String _displayBool = this._formattingExtensions.displayBool(Boolean.valueOf(_hasPageLockSupport));
    _builder.append(_displayBool, "        ");
    _builder.append(";");
    _builder.newLineIfNotEmpty();
    {
      boolean _hasAttributableEntities = this._modelBehaviourExtensions.hasAttributableEntities(app);
      if (_hasAttributableEntities) {
        _builder.append("        ");
        _builder.append("$this->hasAttributes = ");
        boolean _isAttributable = it.isAttributable();
        String _displayBool_1 = this._formattingExtensions.displayBool(Boolean.valueOf(_isAttributable));
        _builder.append(_displayBool_1, "        ");
        _builder.append(";");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      boolean _hasCategorisableEntities = this._modelBehaviourExtensions.hasCategorisableEntities(app);
      if (_hasCategorisableEntities) {
        _builder.append("        ");
        _builder.append("$this->hasCategories = ");
        boolean _isCategorisable = it.isCategorisable();
        String _displayBool_2 = this._formattingExtensions.displayBool(Boolean.valueOf(_isCategorisable));
        _builder.append(_displayBool_2, "        ");
        _builder.append(";");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      boolean _hasMetaDataEntities = this._modelBehaviourExtensions.hasMetaDataEntities(app);
      if (_hasMetaDataEntities) {
        _builder.append("        ");
        _builder.append("$this->hasMetaData = ");
        boolean _isMetaData = it.isMetaData();
        String _displayBool_3 = this._formattingExtensions.displayBool(Boolean.valueOf(_isMetaData));
        _builder.append(_displayBool_3, "        ");
        _builder.append(";");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      boolean _hasSluggable = this._modelBehaviourExtensions.hasSluggable(app);
      if (_hasSluggable) {
        _builder.append("        ");
        _builder.append("$this->hasSlugUpdatableField = ");
        boolean _and = false;
        boolean _and_1 = false;
        boolean _targets_3 = this._utils.targets(app, "1.3.5");
        boolean _not_2 = (!_targets_3);
        if (!_not_2) {
          _and_1 = false;
        } else {
          boolean _hasSluggableFields = this._modelBehaviourExtensions.hasSluggableFields(it);
          _and_1 = (_not_2 && _hasSluggableFields);
        }
        if (!_and_1) {
          _and = false;
        } else {
          boolean _isSlugUpdatable = it.isSlugUpdatable();
          _and = (_and_1 && _isSlugUpdatable);
        }
        String _displayBool_4 = this._formattingExtensions.displayBool(Boolean.valueOf(_and));
        _builder.append(_displayBool_4, "        ");
        _builder.append(";");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      boolean _hasTranslatable = this._modelBehaviourExtensions.hasTranslatable(app);
      if (_hasTranslatable) {
        _builder.append("        ");
        _builder.append("$this->hasTranslatableFields = ");
        boolean _hasTranslatableFields = this._modelBehaviourExtensions.hasTranslatableFields(it);
        String _displayBool_5 = this._formattingExtensions.displayBool(Boolean.valueOf(_hasTranslatableFields));
        _builder.append(_displayBool_5, "        ");
        _builder.append(";");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      boolean _hasUploadFieldsEntity = this._modelExtensions.hasUploadFieldsEntity(it);
      if (_hasUploadFieldsEntity) {
        _builder.append("        ");
        _builder.append("// array with upload fields and mandatory flags");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("$this->uploadFields = array(");
        {
          Iterable<UploadField> _uploadFieldsEntity = this._modelExtensions.getUploadFieldsEntity(it);
          boolean _hasElements = false;
          for(final UploadField uploadField : _uploadFieldsEntity) {
            if (!_hasElements) {
              _hasElements = true;
            } else {
              _builder.appendImmediate(", ", "        ");
            }
            _builder.append("\'");
            String _name_9 = uploadField.getName();
            String _formatForCode_2 = this._formattingExtensions.formatForCode(_name_9);
            _builder.append(_formatForCode_2, "        ");
            _builder.append("\' => ");
            boolean _isMandatory = uploadField.isMandatory();
            String _displayBool_6 = this._formattingExtensions.displayBool(Boolean.valueOf(_isMandatory));
            _builder.append(_displayBool_6, "        ");
          }
        }
        _builder.append(");");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      boolean _hasUserFieldsEntity = this._modelExtensions.hasUserFieldsEntity(it);
      if (_hasUserFieldsEntity) {
        _builder.append("        ");
        _builder.append("// array with user fields and mandatory flags");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("$this->userFields = array(");
        {
          Iterable<UserField> _userFieldsEntity = this._modelExtensions.getUserFieldsEntity(it);
          boolean _hasElements_1 = false;
          for(final UserField userField : _userFieldsEntity) {
            if (!_hasElements_1) {
              _hasElements_1 = true;
            } else {
              _builder.appendImmediate(", ", "        ");
            }
            _builder.append("\'");
            String _name_10 = userField.getName();
            String _formatForCode_3 = this._formattingExtensions.formatForCode(_name_10);
            _builder.append(_formatForCode_3, "        ");
            _builder.append("\' => ");
            boolean _isMandatory_1 = userField.isMandatory();
            String _displayBool_7 = this._formattingExtensions.displayBool(Boolean.valueOf(_isMandatory_1));
            _builder.append(_displayBool_7, "        ");
          }
        }
        _builder.append(");");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      boolean _hasListFieldsEntity = this._modelExtensions.hasListFieldsEntity(it);
      if (_hasListFieldsEntity) {
        _builder.append("        ");
        _builder.append("// array with list fields and multiple flags");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("$this->listFields = array(");
        {
          Iterable<ListField> _listFieldsEntity = this._modelExtensions.getListFieldsEntity(it);
          boolean _hasElements_2 = false;
          for(final ListField listField : _listFieldsEntity) {
            if (!_hasElements_2) {
              _hasElements_2 = true;
            } else {
              _builder.appendImmediate(", ", "        ");
            }
            _builder.append("\'");
            String _name_11 = listField.getName();
            String _formatForCode_4 = this._formattingExtensions.formatForCode(_name_11);
            _builder.append(_formatForCode_4, "        ");
            _builder.append("\' => ");
            boolean _isMultiple = listField.isMultiple();
            String _displayBool_8 = this._formattingExtensions.displayBool(Boolean.valueOf(_isMultiple));
            _builder.append(_displayBool_8, "        ");
          }
        }
        _builder.append(");");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    CharSequence _initialize = this.initialize(it, actionName);
    _builder.append(_initialize, "    ");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* Post-initialise hook.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @return void");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("public function postInitialize()");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("parent::postInitialize();");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    {
      boolean _and_2 = false;
      boolean _isOwnerPermission = it.isOwnerPermission();
      if (!_isOwnerPermission) {
        _and_2 = false;
      } else {
        boolean _isStandardFields = it.isStandardFields();
        _and_2 = (_isOwnerPermission && _isStandardFields);
      }
      if (_and_2) {
        _builder.newLine();
        _builder.append("    ");
        _builder.append("/**");
        _builder.newLine();
        _builder.append("    ");
        _builder.append(" ");
        _builder.append("* Initialise existing entity for editing.");
        _builder.newLine();
        _builder.append("    ");
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append("    ");
        _builder.append(" ");
        _builder.append("* @return Zikula_EntityAccess desired entity instance or null");
        _builder.newLine();
        _builder.append("    ");
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("protected function initEntityForEdit()");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("{");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("$entity = parent::initEntityForEdit();");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("// only allow editing for the owner or people with higher permissions");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("if (isset($entity[\'createdUserId\']) && $entity[\'createdUserId\'] != UserUtil::getVar(\'uid\')) {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("        ");
        _builder.append("if (!SecurityUtil::checkPermission($this->permissionComponent, $this->createCompositeIdentifier() . \'::\', ACCESS_ADD)) {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("            ");
        _builder.append("return LogUtil::registerPermissionError();");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("        ");
        _builder.append("}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("return $entity;");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
      }
    }
    _builder.newLine();
    _builder.append("    ");
    CharSequence _redirectCodes = this.redirectHelper.getRedirectCodes(it, app, this.controller, actionName);
    _builder.append(_redirectCodes, "    ");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    CharSequence _defaultReturnUrl = this.redirectHelper.getDefaultReturnUrl(it, app, this.controller, actionName);
    _builder.append(_defaultReturnUrl, "    ");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    CharSequence _handleCommand = this.handleCommand(it, actionName);
    _builder.append(_handleCommand, "    ");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    CharSequence _applyAction = this.applyAction(it, actionName);
    _builder.append(_applyAction, "    ");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    CharSequence _redirectUrl = this.redirectHelper.getRedirectUrl(it, app, this.controller, actionName);
    _builder.append(_redirectUrl, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence formHandlerImpl(final Entity it, final String actionName) {
    StringConcatenation _builder = new StringConcatenation();
    Models _container = it.getContainer();
    final Application app = _container.getApplication();
    _builder.newLineIfNotEmpty();
    {
      boolean _targets = this._utils.targets(app, "1.3.5");
      boolean _not = (!_targets);
      if (_not) {
        _builder.append("namespace ");
        String _appNamespace = this._utils.appNamespace(app);
        _builder.append(_appNamespace, "");
        _builder.append("\\Form\\Handler\\");
        String _name = this.controller.getName();
        String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(_name);
        _builder.append(_formatForCodeCapital, "");
        _builder.append("\\");
        String _name_1 = it.getName();
        String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(_name_1);
        _builder.append(_formatForCodeCapital_1, "");
        _builder.append(";");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
      }
    }
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* This handler class handles the page events of the Form called by the ");
    String _appName = this._utils.appName(app);
    String _plus = (_appName + "_");
    String _formattedName = this._controllerExtensions.formattedName(this.controller);
    String _plus_1 = (_plus + _formattedName);
    String _plus_2 = (_plus_1 + "_");
    String _plus_3 = (_plus_2 + actionName);
    String _formatForCode = this._formattingExtensions.formatForCode(_plus_3);
    _builder.append(_formatForCode, " ");
    _builder.append("() function.");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("* It aims on the ");
    String _name_2 = it.getName();
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(_name_2);
    _builder.append(_formatForDisplay, " ");
    _builder.append(" object type.");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    {
      boolean _targets_1 = this._utils.targets(app, "1.3.5");
      if (_targets_1) {
        _builder.append("class ");
        String _appName_1 = this._utils.appName(app);
        _builder.append(_appName_1, "");
        _builder.append("_Form_Handler_");
        String _name_3 = this.controller.getName();
        String _formatForCodeCapital_2 = this._formattingExtensions.formatForCodeCapital(_name_3);
        _builder.append(_formatForCodeCapital_2, "");
        _builder.append("_");
        String _name_4 = it.getName();
        String _formatForCodeCapital_3 = this._formattingExtensions.formatForCodeCapital(_name_4);
        _builder.append(_formatForCodeCapital_3, "");
        _builder.append("_");
        String _formatForCodeCapital_4 = this._formattingExtensions.formatForCodeCapital(actionName);
        _builder.append(_formatForCodeCapital_4, "");
        _builder.append(" extends ");
        String _appName_2 = this._utils.appName(app);
        _builder.append(_appName_2, "");
        _builder.append("_Form_Handler_");
        String _name_5 = this.controller.getName();
        String _formatForCodeCapital_5 = this._formattingExtensions.formatForCodeCapital(_name_5);
        _builder.append(_formatForCodeCapital_5, "");
        _builder.append("_");
        String _name_6 = it.getName();
        String _formatForCodeCapital_6 = this._formattingExtensions.formatForCodeCapital(_name_6);
        _builder.append(_formatForCodeCapital_6, "");
        _builder.append("_Base_");
        String _formatForCodeCapital_7 = this._formattingExtensions.formatForCodeCapital(actionName);
        _builder.append(_formatForCodeCapital_7, "");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("class ");
        String _formatForCodeCapital_8 = this._formattingExtensions.formatForCodeCapital(actionName);
        _builder.append(_formatForCodeCapital_8, "");
        _builder.append("Handler extends Base\\");
        String _formatForCodeCapital_9 = this._formattingExtensions.formatForCodeCapital(actionName);
        _builder.append(_formatForCodeCapital_9, "");
        _builder.append("Handler");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// feel free to extend the base handler class here");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence initialize(final Entity it, final String actionName) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Initialize form handler.");
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
    _builder.append("* @param Zikula_Form_View $view The form view instance.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return boolean False in case of initialization errors, otherwise true.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function initialize(Zikula_Form_View $view)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("parent::initialize($view);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$entity = $this->entityRef;");
    _builder.newLine();
    {
      boolean _hasOptimisticLock = this._modelExtensions.hasOptimisticLock(it);
      if (_hasOptimisticLock) {
        _builder.newLine();
        _builder.append("    ");
        _builder.append("if ($this->mode == \'edit\') {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("SessionUtil::setVar($this->name . \'EntityVersion\', $entity->get");
        DerivedField _versionField = this._modelExtensions.getVersionField(it);
        String _name = _versionField.getName();
        String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(_name);
        _builder.append(_formatForCodeCapital, "        ");
        _builder.append("());");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
      }
    }
    _builder.append("    ");
    CharSequence _initPresets = this.relationPresetsHelper.initPresets(it);
    _builder.append(_initPresets, "    ");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// save entity reference for later reuse");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$this->entityRef = $entity;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$entityData = $entity->toArray();");
    _builder.newLine();
    {
      boolean _hasListFields = this._modelExtensions.hasListFields(this.app);
      if (_hasListFields) {
        _builder.newLine();
        _builder.append("    ");
        _builder.append("if (count($this->listFields) > 0) {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("$helper = new ");
        {
          boolean _targets = this._utils.targets(this.app, "1.3.5");
          if (_targets) {
            String _appName = this._utils.appName(this.app);
            _builder.append(_appName, "        ");
            _builder.append("_Util_ListEntries");
          } else {
            _builder.append("ListEntriesUtil");
          }
        }
        _builder.append("($this->view->getServiceManager()");
        {
          boolean _targets_1 = this._utils.targets(this.app, "1.3.5");
          boolean _not = (!_targets_1);
          if (_not) {
            _builder.append(", ModUtil::getModule($this->name)");
          }
        }
        _builder.append(");");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("foreach ($this->listFields as $listField => $isMultiple) {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("        ");
        _builder.append("$entityData[$listField . \'Items\'] = $helper->getEntries($this->objectType, $listField);");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("        ");
        _builder.append("if ($isMultiple) {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("            ");
        _builder.append("$entityData[$listField] = $helper->extractMultiList($entityData[$listField]);");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("        ");
        _builder.append("}");
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
    _builder.append("// assign data to template as array (makes translatable support easier)");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$this->view->assign($this->objectTypeLower, $entityData);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// everything okay, no initialization errors occured");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return true;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence handleCommand(final Entity it, final String actionName) {
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
    _builder.append("* @param Zikula_Form_View $view The form view instance.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param array            $args Additional arguments.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return mixed Redirect or false on errors.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function handleCommand(Zikula_Form_View $view, &$args)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$result = parent::handleCommand($view, $args);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($result === false) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return $result;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $this->view->redirect($this->getRedirectUrl($args));");
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
    _builder.append("* @param Array   $args    Arguments from handleCommand method.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param Boolean $success Becomes true if this is a success, false for default error.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return String desired status or error message.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected function getDefaultMessage($args, $success = false)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($success !== true) {");
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
    _builder.append("                    ");
    _builder.append("if ($this->mode == \'create\') {");
    _builder.newLine();
    _builder.append("                        ");
    _builder.append("$message = $this->__(\'Done! ");
    String _name = it.getName();
    String _formatForDisplayCapital = this._formattingExtensions.formatForDisplayCapital(_name);
    _builder.append(_formatForDisplayCapital, "                        ");
    _builder.append(" created.\');");
    _builder.newLineIfNotEmpty();
    _builder.append("                    ");
    _builder.append("} else {");
    _builder.newLine();
    _builder.append("                        ");
    _builder.append("$message = $this->__(\'Done! ");
    String _name_1 = it.getName();
    String _formatForDisplayCapital_1 = this._formattingExtensions.formatForDisplayCapital(_name_1);
    _builder.append(_formatForDisplayCapital_1, "                        ");
    _builder.append(" updated.\');");
    _builder.newLineIfNotEmpty();
    _builder.append("                    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("                    ");
    _builder.append("break;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("case \'delete\':");
    _builder.newLine();
    _builder.append("                    ");
    _builder.append("$message = $this->__(\'Done! ");
    String _name_2 = it.getName();
    String _formatForDisplayCapital_2 = this._formattingExtensions.formatForDisplayCapital(_name_2);
    _builder.append(_formatForDisplayCapital_2, "                    ");
    _builder.append(" deleted.\');");
    _builder.newLineIfNotEmpty();
    _builder.append("                    ");
    _builder.append("break;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("default:");
    _builder.newLine();
    _builder.append("                    ");
    _builder.append("$message = $this->__(\'Done! ");
    String _name_3 = it.getName();
    String _formatForDisplayCapital_3 = this._formattingExtensions.formatForDisplayCapital(_name_3);
    _builder.append(_formatForDisplayCapital_3, "                    ");
    _builder.append(" updated.\');");
    _builder.newLineIfNotEmpty();
    _builder.append("                    ");
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
  
  private CharSequence applyAction(final Entity it, final String actionName) {
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
    _builder.append("* @param Array $args Arguments from handleCommand method.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return bool Whether everything worked well or not.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function applyAction(array $args = array())");
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
    {
      boolean _or = false;
      boolean _hasOptimisticLock = this._modelExtensions.hasOptimisticLock(it);
      if (_hasOptimisticLock) {
        _or = true;
      } else {
        boolean _hasPessimisticWriteLock = this._modelExtensions.hasPessimisticWriteLock(it);
        _or = (_hasOptimisticLock || _hasPessimisticWriteLock);
      }
      if (_or) {
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$applyLock = ($this->mode != \'create\' && $action != \'delete\');");
        _builder.newLine();
        {
          boolean _hasOptimisticLock_1 = this._modelExtensions.hasOptimisticLock(it);
          if (_hasOptimisticLock_1) {
            _builder.append("    ");
            _builder.append("$expectedVersion = SessionUtil::getVar($this->name . \'EntityVersion\', 1);");
            _builder.newLine();
          }
        }
      }
    }
    _builder.newLine();
    _builder.append("    ");
    _builder.append("try {");
    _builder.newLine();
    {
      boolean _or_1 = false;
      boolean _hasOptimisticLock_2 = this._modelExtensions.hasOptimisticLock(it);
      if (_hasOptimisticLock_2) {
        _or_1 = true;
      } else {
        boolean _hasPessimisticWriteLock_1 = this._modelExtensions.hasPessimisticWriteLock(it);
        _or_1 = (_hasOptimisticLock_2 || _hasPessimisticWriteLock_1);
      }
      if (_or_1) {
        _builder.append("        ");
        _builder.append("if ($applyLock) {");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("// assert version");
        _builder.newLine();
        {
          boolean _hasOptimisticLock_3 = this._modelExtensions.hasOptimisticLock(it);
          if (_hasOptimisticLock_3) {
            _builder.append("        ");
            _builder.append("    ");
            _builder.append("$this->entityManager->lock($entity, LockMode::OPTIMISTIC, $expectedVersion);");
            _builder.newLine();
          } else {
            boolean _hasPessimisticWriteLock_2 = this._modelExtensions.hasPessimisticWriteLock(it);
            if (_hasPessimisticWriteLock_2) {
              _builder.append("        ");
              _builder.append("    ");
              _builder.append("$this->entityManager->lock($entity, LockMode::");
              EntityLockType _lockType = it.getLockType();
              String _asConstant = this._modelExtensions.asConstant(_lockType);
              _builder.append(_asConstant, "            ");
              _builder.append(");");
              _builder.newLineIfNotEmpty();
            }
          }
        }
        _builder.append("        ");
        _builder.append("}");
        _builder.newLine();
        _builder.newLine();
      }
    }
    _builder.append("        ");
    _builder.append("// execute the workflow action");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$workflowHelper = new ");
    {
      boolean _targets = this._utils.targets(this.app, "1.3.5");
      if (_targets) {
        String _appName = this._utils.appName(this.app);
        _builder.append(_appName, "        ");
        _builder.append("_Util_Workflow");
      } else {
        _builder.append("WorkflowUtil");
      }
    }
    _builder.append("($this->view->getServiceManager()");
    {
      boolean _targets_1 = this._utils.targets(this.app, "1.3.5");
      boolean _not = (!_targets_1);
      if (_not) {
        _builder.append(", ModUtil::getModule($this->name)");
      }
    }
    _builder.append(");");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("$success = $workflowHelper->executeAction($entity, $action);");
    _builder.newLine();
    {
      boolean _hasOptimisticLock_4 = this._modelExtensions.hasOptimisticLock(it);
      if (_hasOptimisticLock_4) {
        _builder.append("    ");
        _builder.append("} catch(OptimisticLockException $e) {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("LogUtil::registerError($this->__(\'Sorry, but someone else has already changed this record. Please apply the changes again!\'));");
        _builder.newLine();
      }
    }
    _builder.append("    ");
    _builder.append("} catch(\\Exception $e) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("LogUtil::registerError($this->__f(\'Sorry, but an unknown error occured during the %s action. Please apply the changes again!\', array($action)));");
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
    _builder.append("if ($success && $this->mode == \'create\') {");
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
    _builder.append("            ");
    _builder.append("/* deprecated: check if the insert has worked, might become obsolete due to exception usage");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("if (!$this->idValues[$idField]) {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("$success = false;");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("break;");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("}*/");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    CharSequence _saveNonEditablePresets = this.relationPresetsHelper.saveNonEditablePresets(it, this.app);
    _builder.append(_saveNonEditablePresets, "    ");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $success;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
}
