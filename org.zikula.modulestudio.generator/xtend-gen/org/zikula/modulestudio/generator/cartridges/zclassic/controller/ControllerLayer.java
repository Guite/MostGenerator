package org.zikula.modulestudio.generator.cartridges.zclassic.controller;

import com.google.inject.Inject;
import de.guite.modulestudio.metamodel.modulestudio.Action;
import de.guite.modulestudio.metamodel.modulestudio.AdminController;
import de.guite.modulestudio.metamodel.modulestudio.AjaxController;
import de.guite.modulestudio.metamodel.modulestudio.Application;
import de.guite.modulestudio.metamodel.modulestudio.Controller;
import de.guite.modulestudio.metamodel.modulestudio.Controllers;
import de.guite.modulestudio.metamodel.modulestudio.Entity;
import de.guite.modulestudio.metamodel.modulestudio.UserController;
import de.guite.modulestudio.metamodel.modulestudio.UserField;
import org.eclipse.emf.common.util.EList;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.eclipse.xtext.xbase.lib.InputOutput;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.eclipse.xtext.xbase.lib.Procedures.Procedure1;
import org.eclipse.xtext.xbase.lib.StringExtensions;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.ControllerAction;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.ControllerHelper;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.UtilMethods;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.additions.Ajax;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.additions.ExternalController;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.additions.Scribite;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.additions.UrlRouting;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.apis.Category;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.apis.Selection;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.apis.ShortUrls;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.javascript.DisplayFunctions;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.javascript.EditFunctions;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.javascript.Finder;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.javascript.TreeFunctions;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.javascript.Validation;
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper;
import org.zikula.modulestudio.generator.extensions.ControllerExtensions;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class ControllerLayer {
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
  
  private FileHelper fh = new Function0<FileHelper>() {
    public FileHelper apply() {
      FileHelper _fileHelper = new FileHelper();
      return _fileHelper;
    }
  }.apply();
  
  private Application app;
  
  /**
   * Entry point for the controller creation.
   */
  public void generate(final Application it, final IFileSystemAccess fsa) {
    this.app = it;
    EList<Controller> _allControllers = this._controllerExtensions.getAllControllers(it);
    final Procedure1<Controller> _function = new Procedure1<Controller>() {
      public void apply(final Controller it) {
        ControllerLayer.this.generate(it, fsa);
      }
    };
    IterableExtensions.<Controller>forEach(_allControllers, _function);
    ExternalController _externalController = new ExternalController();
    _externalController.generate(it, fsa);
    Selection _selection = new Selection();
    _selection.generate(it, fsa);
    boolean _hasCategorisableEntities = this._modelBehaviourExtensions.hasCategorisableEntities(it);
    if (_hasCategorisableEntities) {
      Category _category = new Category();
      _category.generate(it, fsa);
    }
    UtilMethods _utilMethods = new UtilMethods();
    _utilMethods.generate(it, fsa);
    boolean _hasUserController = this._controllerExtensions.hasUserController(it);
    if (_hasUserController) {
      UrlRouting _urlRouting = new UrlRouting();
      _urlRouting.generate(it, fsa);
    }
    Scribite _scribite = new Scribite();
    _scribite.generate(it, fsa);
    Finder _finder = new Finder();
    _finder.generate(it, fsa);
    boolean _hasEditActions = this._controllerExtensions.hasEditActions(it);
    if (_hasEditActions) {
      EditFunctions _editFunctions = new EditFunctions();
      _editFunctions.generate(it, fsa);
    }
    DisplayFunctions _displayFunctions = new DisplayFunctions();
    _displayFunctions.generate(it, fsa);
    boolean _hasTrees = this._modelBehaviourExtensions.hasTrees(it);
    if (_hasTrees) {
      TreeFunctions _treeFunctions = new TreeFunctions();
      _treeFunctions.generate(it, fsa);
    }
    Validation _validation = new Validation();
    _validation.generate(it, fsa);
  }
  
  /**
   * Creates controller and api class files for every Controller instance.
   */
  private void generate(final Controller it, final IFileSystemAccess fsa) {
    String _formattedName = this._controllerExtensions.formattedName(it);
    String _plus = ("Generating \"" + _formattedName);
    String _plus_1 = (_plus + "\" controller classes");
    InputOutput.<String>println(_plus_1);
    String _appSourceLibPath = this._namingExtensions.getAppSourceLibPath(this.app);
    final String controllerPath = (_appSourceLibPath + "Controller/");
    String _xifexpression = null;
    boolean _targets = this._utils.targets(this.app, "1.3.5");
    boolean _not = (!_targets);
    if (_not) {
      _xifexpression = "Controller";
    } else {
      _xifexpression = "";
    }
    final String controllerClassSuffix = _xifexpression;
    String _name = it.getName();
    String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(_name);
    String _plus_2 = (_formatForCodeCapital + controllerClassSuffix);
    final String controllerFileName = (_plus_2 + ".php");
    String _plus_3 = (controllerPath + "Base/");
    String _plus_4 = (_plus_3 + controllerFileName);
    CharSequence _controllerBaseFile = this.controllerBaseFile(it);
    fsa.generateFile(_plus_4, _controllerBaseFile);
    String _plus_5 = (controllerPath + controllerFileName);
    CharSequence _controllerFile = this.controllerFile(it);
    fsa.generateFile(_plus_5, _controllerFile);
    String _formattedName_1 = this._controllerExtensions.formattedName(it);
    String _plus_6 = ("Generating \"" + _formattedName_1);
    String _plus_7 = (_plus_6 + "\" api classes");
    InputOutput.<String>println(_plus_7);
    String _appSourceLibPath_1 = this._namingExtensions.getAppSourceLibPath(this.app);
    final String apiPath = (_appSourceLibPath_1 + "Api/");
    String _xifexpression_1 = null;
    boolean _targets_1 = this._utils.targets(this.app, "1.3.5");
    boolean _not_1 = (!_targets_1);
    if (_not_1) {
      _xifexpression_1 = "Api";
    } else {
      _xifexpression_1 = "";
    }
    final String apiClassSuffix = _xifexpression_1;
    String _name_1 = it.getName();
    String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(_name_1);
    String _plus_8 = (_formatForCodeCapital_1 + apiClassSuffix);
    final String apiFileName = (_plus_8 + ".php");
    String _plus_9 = (apiPath + "Base/");
    String _plus_10 = (_plus_9 + apiFileName);
    CharSequence _apiBaseFile = this.apiBaseFile(it);
    fsa.generateFile(_plus_10, _apiBaseFile);
    String _plus_11 = (apiPath + apiFileName);
    CharSequence _apiFile = this.apiFile(it);
    fsa.generateFile(_plus_11, _apiFile);
  }
  
  private CharSequence controllerBaseFile(final Controller it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _phpFileHeader = this.fh.phpFileHeader(this.app);
    _builder.append(_phpFileHeader, "");
    _builder.newLineIfNotEmpty();
    CharSequence _controllerBaseImpl = this.controllerBaseImpl(it);
    _builder.append(_controllerBaseImpl, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence controllerFile(final Controller it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _phpFileHeader = this.fh.phpFileHeader(this.app);
    _builder.append(_phpFileHeader, "");
    _builder.newLineIfNotEmpty();
    CharSequence _controllerImpl = this.controllerImpl(it);
    _builder.append(_controllerImpl, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence apiBaseFile(final Controller it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _phpFileHeader = this.fh.phpFileHeader(this.app);
    _builder.append(_phpFileHeader, "");
    _builder.newLineIfNotEmpty();
    CharSequence _apiBaseImpl = this.apiBaseImpl(it);
    _builder.append(_apiBaseImpl, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence apiFile(final Controller it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _phpFileHeader = this.fh.phpFileHeader(this.app);
    _builder.append(_phpFileHeader, "");
    _builder.newLineIfNotEmpty();
    CharSequence _apiImpl = this.apiImpl(it);
    _builder.append(_apiImpl, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence controllerBaseImpl(final Controller it) {
    StringConcatenation _builder = new StringConcatenation();
    final boolean isAdminController = (it instanceof AdminController);
    _builder.newLineIfNotEmpty();
    final boolean isAjaxController = (it instanceof AjaxController);
    _builder.newLineIfNotEmpty();
    {
      boolean _targets = this._utils.targets(this.app, "1.3.5");
      boolean _not = (!_targets);
      if (_not) {
        _builder.append("namespace ");
        String _appNamespace = this._utils.appNamespace(this.app);
        _builder.append(_appNamespace, "");
        _builder.append("\\Controller\\Base;");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
        {
          boolean _and = false;
          boolean _needsConfig = this._utils.needsConfig(this.app);
          if (!_needsConfig) {
            _and = false;
          } else {
            boolean _isConfigController = this._controllerExtensions.isConfigController(it);
            _and = (_needsConfig && _isConfigController);
          }
          if (_and) {
            _builder.append("use ");
            String _appNamespace_1 = this._utils.appNamespace(this.app);
            _builder.append(_appNamespace_1, "");
            _builder.append("\\Form\\Handler\\");
            String _configController = this._controllerExtensions.configController(this.app);
            String _formatForDB = this._formattingExtensions.formatForDB(_configController);
            String _firstUpper = StringExtensions.toFirstUpper(_formatForDB);
            _builder.append(_firstUpper, "");
            _builder.append("\\ConfigHandler;");
            _builder.newLineIfNotEmpty();
          }
        }
        _builder.append("use ");
        String _appNamespace_2 = this._utils.appNamespace(this.app);
        _builder.append(_appNamespace_2, "");
        _builder.append("\\Util\\ControllerUtil;");
        _builder.newLineIfNotEmpty();
        {
          boolean _and_1 = false;
          if (!isAjaxController) {
            _and_1 = false;
          } else {
            boolean _hasImageFields = this._modelExtensions.hasImageFields(this.app);
            _and_1 = (isAjaxController && _hasImageFields);
          }
          if (_and_1) {
            _builder.append("use ");
            String _appNamespace_3 = this._utils.appNamespace(this.app);
            _builder.append(_appNamespace_3, "");
            _builder.append("\\Util\\ImageUtil;");
            _builder.newLineIfNotEmpty();
          }
        }
        {
          boolean _and_2 = false;
          if (!isAjaxController) {
            _and_2 = false;
          } else {
            boolean _hasListFields = this._modelExtensions.hasListFields(this.app);
            _and_2 = (isAjaxController && _hasListFields);
          }
          if (_and_2) {
            _builder.append("use ");
            String _appNamespace_4 = this._utils.appNamespace(this.app);
            _builder.append(_appNamespace_4, "");
            _builder.append("\\Util\\ListEntriesUtil;");
            _builder.newLineIfNotEmpty();
          }
        }
        _builder.append("use ");
        String _appNamespace_5 = this._utils.appNamespace(this.app);
        _builder.append(_appNamespace_5, "");
        _builder.append("\\Util\\ViewUtil;");
        _builder.newLineIfNotEmpty();
        {
          boolean _or = false;
          boolean _or_1 = false;
          boolean _and_3 = false;
          if (!isAjaxController) {
            _and_3 = false;
          } else {
            boolean _hasTrees = this._modelBehaviourExtensions.hasTrees(this.app);
            _and_3 = (isAjaxController && _hasTrees);
          }
          if (_and_3) {
            _or_1 = true;
          } else {
            boolean _and_4 = false;
            boolean _hasActions = this._controllerExtensions.hasActions(it, "view");
            if (!_hasActions) {
              _and_4 = false;
            } else {
              _and_4 = (_hasActions && isAdminController);
            }
            _or_1 = (_and_3 || _and_4);
          }
          if (_or_1) {
            _or = true;
          } else {
            boolean _hasActions_1 = this._controllerExtensions.hasActions(it, "delete");
            _or = (_or_1 || _hasActions_1);
          }
          if (_or) {
            _builder.append("use ");
            String _appNamespace_6 = this._utils.appNamespace(this.app);
            _builder.append(_appNamespace_6, "");
            _builder.append("\\Util\\WorkflowUtil;");
            _builder.newLineIfNotEmpty();
          }
        }
        _builder.newLine();
        {
          if (isAjaxController) {
            _builder.append("use DataUtil;");
            _builder.newLine();
            {
              Iterable<UserField> _allUserFields = this._modelExtensions.getAllUserFields(this.app);
              boolean _isEmpty = IterableExtensions.isEmpty(_allUserFields);
              boolean _not_1 = (!_isEmpty);
              if (_not_1) {
                _builder.append("use Doctrine\\ORM\\AbstractQuery;");
                _builder.newLine();
              }
            }
          }
        }
        _builder.append("use FormUtil;");
        _builder.newLine();
        {
          boolean _hasActions_2 = this._controllerExtensions.hasActions(it, "edit");
          if (_hasActions_2) {
            _builder.append("use JCSSUtil;");
            _builder.newLine();
          }
        }
        _builder.append("use LogUtil;");
        _builder.newLine();
        _builder.append("use ModUtil;");
        _builder.newLine();
        _builder.append("use SecurityUtil;");
        _builder.newLine();
        {
          boolean _and_5 = false;
          boolean _hasActions_3 = this._controllerExtensions.hasActions(it, "view");
          if (!_hasActions_3) {
            _and_5 = false;
          } else {
            _and_5 = (_hasActions_3 && isAdminController);
          }
          if (_and_5) {
            _builder.append("use System;");
            _builder.newLine();
          }
        }
        _builder.append("use Zikula_");
        {
          boolean _not_2 = (!isAjaxController);
          if (_not_2) {
            _builder.append("AbstractController");
          } else {
            _builder.append("Controller_AbstractAjax");
          }
        }
        _builder.append(";");
        _builder.newLineIfNotEmpty();
        _builder.append("use Zikula_View;");
        _builder.newLine();
        _builder.append("use ZLanguage;");
        _builder.newLine();
        {
          boolean _or_2 = false;
          boolean _and_6 = false;
          boolean _hasActions_4 = this._controllerExtensions.hasActions(it, "view");
          if (!_hasActions_4) {
            _and_6 = false;
          } else {
            _and_6 = (_hasActions_4 && isAdminController);
          }
          if (_and_6) {
            _or_2 = true;
          } else {
            boolean _hasActions_5 = this._controllerExtensions.hasActions(it, "delete");
            _or_2 = (_and_6 || _hasActions_5);
          }
          if (_or_2) {
            _builder.append("use Zikula\\Core\\Hook\\ProcessHook;");
            _builder.newLine();
            _builder.append("use Zikula\\Core\\Hook\\ValidationHook;");
            _builder.newLine();
            _builder.append("use Zikula\\Core\\Hook\\ValidationProviders;");
            _builder.newLine();
          }
        }
        _builder.append("use Zikula\\Core\\ModUrl;");
        _builder.newLine();
        {
          if (isAjaxController) {
            _builder.append("use Zikula\\Core\\Response\\Ajax\\AjaxResponse;");
            _builder.newLine();
            _builder.append("use Zikula\\Core\\Response\\Ajax\\BadDataResponse;");
            _builder.newLine();
            _builder.append("use Zikula\\Core\\Response\\Ajax\\FatalResponse;");
            _builder.newLine();
            _builder.append("use Zikula\\Core\\Response\\Ajax\\NotFoundResponse;");
            _builder.newLine();
            _builder.append("use Zikula\\Core\\Response\\Ajax\\Plain;");
            _builder.newLine();
          }
        }
        _builder.append("use Zikula\\Core\\Response\\PlainResponse;");
        _builder.newLine();
        _builder.newLine();
      }
    }
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* ");
    String _name = it.getName();
    _builder.append(_name, " ");
    _builder.append(" controller class.");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("class ");
    {
      boolean _targets_1 = this._utils.targets(this.app, "1.3.5");
      if (_targets_1) {
        String _appName = this._utils.appName(this.app);
        _builder.append(_appName, "");
        _builder.append("_Controller_Base_");
        String _name_1 = it.getName();
        String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(_name_1);
        _builder.append(_formatForCodeCapital, "");
      } else {
        String _name_2 = it.getName();
        String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(_name_2);
        _builder.append(_formatForCodeCapital_1, "");
        _builder.append("Controller");
      }
    }
    _builder.append(" extends Zikula_");
    {
      boolean _not_3 = (!isAjaxController);
      if (_not_3) {
        _builder.append("AbstractController");
      } else {
        _builder.append("Controller_AbstractAjax");
      }
    }
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    {
      if (isAjaxController) {
        _builder.newLine();
      } else {
        _builder.append("    ");
        final boolean isUserController = (it instanceof UserController);
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        ControllerHelper _controllerHelper = new ControllerHelper();
        CharSequence _controllerPostInitialize = _controllerHelper.controllerPostInitialize(it, Boolean.valueOf(isUserController), "");
        _builder.append(_controllerPostInitialize, "    ");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.newLine();
    _builder.append("    ");
    ControllerAction _controllerAction = new ControllerAction(this.app);
    final ControllerAction actionHelper = _controllerAction;
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    {
      EList<Action> _actions = it.getActions();
      for(final Action action : _actions) {
        CharSequence _generate = actionHelper.generate(action);
        _builder.append(_generate, "    ");
      }
    }
    _builder.newLineIfNotEmpty();
    {
      boolean _and_7 = false;
      boolean _hasActions_6 = this._controllerExtensions.hasActions(it, "view");
      if (!_hasActions_6) {
        _and_7 = false;
      } else {
        _and_7 = (_hasActions_6 && isAdminController);
      }
      if (_and_7) {
        _builder.newLine();
        _builder.append("    ");
        CharSequence _handleSelectedObjects = this.handleSelectedObjects(it);
        _builder.append(_handleSelectedObjects, "    ");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      boolean _hasActions_7 = this._controllerExtensions.hasActions(it, "edit");
      if (_hasActions_7) {
        _builder.newLine();
        _builder.append("    ");
        _builder.append("/**");
        _builder.newLine();
        _builder.append("    ");
        _builder.append(" ");
        _builder.append("* This method cares for a redirect within an inline frame.");
        _builder.newLine();
        _builder.append("    ");
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append("    ");
        _builder.append(" ");
        _builder.append("* @return boolean");
        _builder.newLine();
        _builder.append("    ");
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("public function handleInlineRedirect");
        {
          boolean _targets_2 = this._utils.targets(this.app, "1.3.5");
          boolean _not_4 = (!_targets_2);
          if (_not_4) {
            _builder.append("Action");
          }
        }
        _builder.append("()");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("{");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("$itemId = (int) $this->request->query->filter(\'id\', 0, ");
        {
          boolean _targets_3 = this._utils.targets(this.app, "1.3.5");
          boolean _not_5 = (!_targets_3);
          if (_not_5) {
            _builder.append("false, ");
          }
        }
        _builder.append("FILTER_VALIDATE_INT);");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("$idPrefix = $this->request->query->filter(\'idp\', \'\', ");
        {
          boolean _targets_4 = this._utils.targets(this.app, "1.3.5");
          boolean _not_6 = (!_targets_4);
          if (_not_6) {
            _builder.append("false, ");
          }
        }
        _builder.append("FILTER_SANITIZE_STRING);");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("$commandName = $this->request->query->filter(\'com\', \'\', ");
        {
          boolean _targets_5 = this._utils.targets(this.app, "1.3.5");
          boolean _not_7 = (!_targets_5);
          if (_not_7) {
            _builder.append("false, ");
          }
        }
        _builder.append("FILTER_SANITIZE_STRING);");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("if (empty($idPrefix)) {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("        ");
        _builder.append("return false;");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("$this->view->assign(\'itemId\', $itemId)");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("               ");
        _builder.append("->assign(\'idPrefix\', $idPrefix)");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("               ");
        _builder.append("->assign(\'commandName\', $commandName)");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("               ");
        _builder.append("->assign(\'jcssConfig\', JCSSUtil::getJSConfig());");
        _builder.newLine();
        _builder.newLine();
        {
          boolean _targets_6 = this._utils.targets(this.app, "1.3.5");
          if (_targets_6) {
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("$view->display(\'");
            String _formattedName = this._controllerExtensions.formattedName(it);
            _builder.append(_formattedName, "        ");
            _builder.append("/inlineRedirectHandler.tpl\');");
            _builder.newLineIfNotEmpty();
            _builder.newLine();
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("return true;");
            _builder.newLine();
          } else {
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("return new PlainResponse($view->display(\'");
            String _formattedName_1 = this._controllerExtensions.formattedName(it);
            String _firstUpper_1 = StringExtensions.toFirstUpper(_formattedName_1);
            _builder.append(_firstUpper_1, "        ");
            _builder.append("/inlineRedirectHandler.tpl\'));");
            _builder.newLineIfNotEmpty();
          }
        }
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
      }
    }
    {
      boolean _and_8 = false;
      boolean _needsConfig_1 = this._utils.needsConfig(this.app);
      if (!_needsConfig_1) {
        _and_8 = false;
      } else {
        boolean _isConfigController_1 = this._controllerExtensions.isConfigController(it);
        _and_8 = (_needsConfig_1 && _isConfigController_1);
      }
      if (_and_8) {
        _builder.newLine();
        _builder.append("    ");
        _builder.append("/**");
        _builder.newLine();
        _builder.append("    ");
        _builder.append(" ");
        _builder.append("* This method takes care of the application configuration.");
        _builder.newLine();
        _builder.append("    ");
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append("    ");
        _builder.append(" ");
        _builder.append("* @return string Output");
        _builder.newLine();
        _builder.append("    ");
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("public function config");
        {
          boolean _targets_7 = this._utils.targets(this.app, "1.3.5");
          boolean _not_8 = (!_targets_7);
          if (_not_8) {
            _builder.append("Action");
          }
        }
        _builder.append("()");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("{");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("$this->throwForbiddenUnless(SecurityUtil::checkPermission($this->name . \'::\', \'::\', ACCESS_ADMIN));");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("// Create new Form reference");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("$view = FormUtil::newForm($this->name, $this);");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("$templateName = \'");
        {
          boolean _targets_8 = this._utils.targets(this.app, "1.3.5");
          if (_targets_8) {
            String _configController_1 = this._controllerExtensions.configController(this.app);
            String _formatForDB_1 = this._formattingExtensions.formatForDB(_configController_1);
            _builder.append(_formatForDB_1, "        ");
          } else {
            String _configController_2 = this._controllerExtensions.configController(this.app);
            String _formatForCodeCapital_2 = this._formattingExtensions.formatForCodeCapital(_configController_2);
            _builder.append(_formatForCodeCapital_2, "        ");
          }
        }
        _builder.append("/config.tpl\';");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("// Execute form using supplied template and page event handler");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("return $view->execute($templateName, new ");
        {
          boolean _targets_9 = this._utils.targets(this.app, "1.3.5");
          if (_targets_9) {
            String _appName_1 = this._utils.appName(this.app);
            _builder.append(_appName_1, "        ");
            _builder.append("_Form_Handler_");
            String _configController_3 = this._controllerExtensions.configController(this.app);
            String _formatForDB_2 = this._formattingExtensions.formatForDB(_configController_3);
            String _firstUpper_2 = StringExtensions.toFirstUpper(_formatForDB_2);
            _builder.append(_firstUpper_2, "        ");
            _builder.append("_Config");
          } else {
            _builder.append("ConfigHandler");
          }
        }
        _builder.append("());");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
      }
    }
    _builder.append("    ");
    Ajax _ajax = new Ajax();
    CharSequence _additionalAjaxFunctions = _ajax.additionalAjaxFunctions(it, this.app);
    _builder.append(_additionalAjaxFunctions, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence handleSelectedObjects(final Controller it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Process status changes for multiple items.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* This function processes the items selected in the admin view page.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Multiple items may have their state changed or be deleted.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param array  items  Identifier list of the items to be processed.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string action The action to be executed.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return bool true on sucess, false on failure.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function handleselectedentries");
    {
      boolean _targets = this._utils.targets(this.app, "1.3.5");
      boolean _not = (!_targets);
      if (_not) {
        _builder.append("Action");
      }
    }
    _builder.append("(array $args = array())");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$this->checkCsrfToken();");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$returnUrl = ModUtil::url($this->name, \'admin\', \'");
    {
      boolean _targets_1 = this._utils.targets(this.app, "1.3.5");
      if (_targets_1) {
        _builder.append("main");
      } else {
        _builder.append("index");
      }
    }
    _builder.append("\');");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// Determine object type");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$objectType = isset($args[\'ot\']) ? $args[\'ot\'] : $this->request->request->get(\'ot\', \'\');");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!$objectType) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return System::redirect($returnUrl);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$returnUrl = ModUtil::url($this->name, \'admin\', \'view\', array(\'ot\' => $objectType));");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// Get other parameters");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$items = isset($args[\'items\']) ? $args[\'items\'] : $this->request->request->get(\'items\', null);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$action = isset($args[\'action\']) ? $args[\'action\'] : $this->request->request->get(\'action\', null);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$action = strtolower($action);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$workflowHelper = new ");
    {
      boolean _targets_2 = this._utils.targets(this.app, "1.3.5");
      if (_targets_2) {
        String _appName = this._utils.appName(this.app);
        _builder.append(_appName, "    ");
        _builder.append("_Util_Workflow");
      } else {
        _builder.append("WorkflowUtil");
      }
    }
    _builder.append("($this->serviceManager");
    {
      boolean _targets_3 = this._utils.targets(this.app, "1.3.5");
      boolean _not_1 = (!_targets_3);
      if (_not_1) {
        _builder.append(", ModUtil::getModule($this->name)");
      }
    }
    _builder.append(");");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// process each item");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("foreach ($items as $itemid) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// check if item exists, and get record instance");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$selectionArgs = array(\'ot\' => $objectType, \'id\' => $itemid, \'useJoins\' => false);");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$entity = ModUtil::apiFunc($this->name, \'selection\', \'getEntity\', $selectionArgs);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$entity->initWorkflow();");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// check if $action can be applied to this entity (may depend on it\'s current workflow state)");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$allowedActions = $workflowHelper->getActionsForObject($entity);");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$actionIds = array_keys($allowedActions);");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if (!in_array($action, $actionIds)) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("// action not allowed, skip this object");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("continue;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$hookAreaPrefix = $entity->getHookAreaPrefix();");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// Let any hooks perform additional validation actions");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$hookType = $action == \'delete\' ? \'validate_delete\' : \'validate_edit\';");
    _builder.newLine();
    {
      boolean _targets_4 = this._utils.targets(this.app, "1.3.5");
      if (_targets_4) {
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
    _builder.append("continue;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$success = false;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("try {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("// execute the workflow action");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$success = $workflowHelper->executeAction($entity, $action);");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("} catch(\\Exception $e) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("LogUtil::registerError($this->__f(\'Sorry, but an unknown error occured during the %s action. Please apply the changes again!\', array($action)));");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if (!$success) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("continue;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if ($action == \'delete\') {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("LogUtil::registerStatus($this->__(\'Done! Item deleted.\'));");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("} else {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("LogUtil::registerStatus($this->__(\'Done! Item updated.\'));");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// Let any hooks know that we have updated or deleted an item");
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
    _builder.append("$urlArgs = $entity->createUrlArgs();");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$url = new ");
    {
      boolean _targets_5 = this._utils.targets(this.app, "1.3.5");
      if (_targets_5) {
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
      boolean _targets_6 = this._utils.targets(this.app, "1.3.5");
      if (_targets_6) {
        _builder.append("        ");
        _builder.append("$hook = new Zikula_ProcessHook($hookAreaPrefix . \'.\' . $hookType, $entity->createCompositeIdentifier(), $url);");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("$this->notifyHooks($hook);");
        _builder.newLine();
      } else {
        _builder.append("        ");
        _builder.append("$hook = new ProcessHook($entity->createCompositeIdentifier(), $url);");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("$this->dispatchHooks($hookAreaPrefix . \'.\' . $hookType, $hook);");
        _builder.newLine();
      }
    }
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// An item was updated or deleted, so we clear all cached pages for this item.");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$cacheArgs = array(\'ot\' => $objectType, \'item\' => $entity);");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("ModUtil::apiFunc($this->name, \'cache\', \'clearItemCache\', $cacheArgs);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// clear view cache to reflect our changes");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$this->view->clear_cache();");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return System::redirect($returnUrl);");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence controllerImpl(final Controller it) {
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
        _builder.append("\\Controller;");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
        _builder.append("use ");
        String _appNamespace_1 = this._utils.appNamespace(app);
        _builder.append(_appNamespace_1, "");
        _builder.append("\\Controller\\Base\\");
        String _name = it.getName();
        String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(_name);
        _builder.append(_formatForCodeCapital, "");
        _builder.append("Controller as Base");
        String _name_1 = it.getName();
        String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(_name_1);
        _builder.append(_formatForCodeCapital_1, "");
        _builder.append("Controller;");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
      }
    }
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* This is the ");
    String _name_2 = it.getName();
    _builder.append(_name_2, " ");
    _builder.append(" controller class providing navigation and interaction functionality.");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    {
      boolean _targets_1 = this._utils.targets(app, "1.3.5");
      if (_targets_1) {
        _builder.append("class ");
        String _appName = this._utils.appName(app);
        _builder.append(_appName, "");
        _builder.append("_Controller_");
        String _name_3 = it.getName();
        String _formatForCodeCapital_2 = this._formattingExtensions.formatForCodeCapital(_name_3);
        _builder.append(_formatForCodeCapital_2, "");
        _builder.append(" extends ");
        String _appName_1 = this._utils.appName(app);
        _builder.append(_appName_1, "");
        _builder.append("_Controller_Base_");
        String _name_4 = it.getName();
        String _formatForCodeCapital_3 = this._formattingExtensions.formatForCodeCapital(_name_4);
        _builder.append(_formatForCodeCapital_3, "");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("class ");
        String _name_5 = it.getName();
        String _formatForCodeCapital_4 = this._formattingExtensions.formatForCodeCapital(_name_5);
        _builder.append(_formatForCodeCapital_4, "");
        _builder.append("Controller extends Base");
        String _name_6 = it.getName();
        String _formatForCodeCapital_5 = this._formattingExtensions.formatForCodeCapital(_name_6);
        _builder.append(_formatForCodeCapital_5, "");
        _builder.append("Controller");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// feel free to add your own controller methods here");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence apiBaseImpl(final Controller it) {
    StringConcatenation _builder = new StringConcatenation();
    Controllers _container = it.getContainer();
    final Application app = _container.getApplication();
    _builder.newLineIfNotEmpty();
    final boolean isUserController = (it instanceof UserController);
    _builder.newLineIfNotEmpty();
    final boolean isAjaxController = (it instanceof AjaxController);
    _builder.newLineIfNotEmpty();
    {
      boolean _targets = this._utils.targets(app, "1.3.5");
      boolean _not = (!_targets);
      if (_not) {
        _builder.append("namespace ");
        String _appNamespace = this._utils.appNamespace(app);
        _builder.append(_appNamespace, "");
        _builder.append("\\Api\\Base;");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
        {
          if (isUserController) {
            _builder.append("use ");
            String _appNamespace_1 = this._utils.appNamespace(app);
            _builder.append(_appNamespace_1, "");
            _builder.append("\\RouterFacade;");
            _builder.newLineIfNotEmpty();
          }
        }
        _builder.append("use ");
        String _appNamespace_2 = this._utils.appNamespace(app);
        _builder.append(_appNamespace_2, "");
        _builder.append("\\Util\\ControllerUtil;");
        _builder.newLineIfNotEmpty();
        _builder.append("use LogUtil;");
        _builder.newLine();
        _builder.append("use ModUtil;");
        _builder.newLine();
        _builder.append("use SecurityUtil;");
        _builder.newLine();
        {
          if (isUserController) {
            _builder.append("use System;");
            _builder.newLine();
          }
        }
        _builder.append("use Zikula_AbstractApi;");
        _builder.newLine();
        _builder.newLine();
      }
    }
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* This is the ");
    String _name = it.getName();
    _builder.append(_name, " ");
    _builder.append(" api helper class.");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("class ");
    {
      boolean _targets_1 = this._utils.targets(app, "1.3.5");
      if (_targets_1) {
        String _appName = this._utils.appName(app);
        _builder.append(_appName, "");
        _builder.append("_Api_Base_");
        String _name_1 = it.getName();
        String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(_name_1);
        _builder.append(_formatForCodeCapital, "");
      } else {
        String _name_2 = it.getName();
        String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(_name_2);
        _builder.append(_formatForCodeCapital_1, "");
        _builder.append("Api");
      }
    }
    _builder.append(" extends Zikula_AbstractApi");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    {
      boolean _not_1 = (!isAjaxController);
      if (_not_1) {
        _builder.append("    ");
        _builder.append("/**");
        _builder.newLine();
        _builder.append("    ");
        _builder.append(" ");
        _builder.append("* Returns available ");
        String _name_3 = it.getName();
        String _formatForDB = this._formattingExtensions.formatForDB(_name_3);
        _builder.append(_formatForDB, "     ");
        _builder.append(" panel links.");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append("    ");
        _builder.append(" ");
        _builder.append("* @return array Array of ");
        String _name_4 = it.getName();
        String _formatForDB_1 = this._formattingExtensions.formatForDB(_name_4);
        _builder.append(_formatForDB_1, "     ");
        _builder.append(" links.");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("public function getlinks()");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("{");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("$links = array();");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        CharSequence _menuLinksBetweenControllers = this.menuLinksBetweenControllers(it);
        _builder.append(_menuLinksBetweenControllers, "        ");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("$controllerHelper = new ");
        {
          boolean _targets_2 = this._utils.targets(app, "1.3.5");
          if (_targets_2) {
            String _appName_1 = this._utils.appName(app);
            _builder.append(_appName_1, "        ");
            _builder.append("_Util_Controller");
          } else {
            _builder.append("ControllerUtil");
          }
        }
        _builder.append("($this->serviceManager");
        {
          boolean _targets_3 = this._utils.targets(app, "1.3.5");
          boolean _not_2 = (!_targets_3);
          if (_not_2) {
            _builder.append(", ModUtil::getModule($this->name)");
          }
        }
        _builder.append(");");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("$utilArgs = array(\'api\' => \'");
        String _formattedName = this._controllerExtensions.formattedName(it);
        _builder.append(_formattedName, "        ");
        _builder.append("\', \'action\' => \'getlinks\');");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("$allowedObjectTypes = $controllerHelper->getObjectTypes(\'api\', $utilArgs);");
        _builder.newLine();
        _builder.newLine();
        {
          boolean _hasActions = this._controllerExtensions.hasActions(it, "view");
          if (_hasActions) {
            {
              EList<Entity> _allEntities = this._modelExtensions.getAllEntities(app);
              for(final Entity entity : _allEntities) {
                _builder.append("    ");
                _builder.append("    ");
                _builder.append("if (in_array(\'");
                String _name_5 = entity.getName();
                String _formatForCode = this._formattingExtensions.formatForCode(_name_5);
                _builder.append(_formatForCode, "        ");
                _builder.append("\', $allowedObjectTypes)");
                _builder.newLineIfNotEmpty();
                _builder.append("    ");
                _builder.append("    ");
                _builder.append("    ");
                _builder.append("&& SecurityUtil::checkPermission($this->name . \':");
                String _name_6 = entity.getName();
                String _formatForCodeCapital_2 = this._formattingExtensions.formatForCodeCapital(_name_6);
                _builder.append(_formatForCodeCapital_2, "            ");
                _builder.append(":\', \'::\', ACCESS_");
                String _menuLinksPermissionLevel = this.menuLinksPermissionLevel(it);
                _builder.append(_menuLinksPermissionLevel, "            ");
                _builder.append(")) {");
                _builder.newLineIfNotEmpty();
                _builder.append("    ");
                _builder.append("    ");
                _builder.append("    ");
                _builder.append("$links[] = array(\'url\' => ModUtil::url($this->name, \'");
                String _formattedName_1 = this._controllerExtensions.formattedName(it);
                _builder.append(_formattedName_1, "            ");
                _builder.append("\', \'view\', array(\'ot\' => \'");
                String _name_7 = entity.getName();
                String _formatForCode_1 = this._formattingExtensions.formatForCode(_name_7);
                _builder.append(_formatForCode_1, "            ");
                _builder.append("\')),");
                _builder.newLineIfNotEmpty();
                _builder.append("    ");
                _builder.append("    ");
                _builder.append("                     ");
                _builder.append("\'text\' => $this->__(\'");
                String _nameMultiple = entity.getNameMultiple();
                String _formatForDisplayCapital = this._formattingExtensions.formatForDisplayCapital(_nameMultiple);
                _builder.append(_formatForDisplayCapital, "                             ");
                _builder.append("\'),");
                _builder.newLineIfNotEmpty();
                _builder.append("    ");
                _builder.append("    ");
                _builder.append("                     ");
                _builder.append("\'title\' => $this->__(\'");
                String _name_8 = entity.getName();
                String _formatForDisplayCapital_1 = this._formattingExtensions.formatForDisplayCapital(_name_8);
                _builder.append(_formatForDisplayCapital_1, "                             ");
                _builder.append(" list\'));");
                _builder.newLineIfNotEmpty();
                _builder.append("    ");
                _builder.append("    ");
                _builder.append("}");
                _builder.newLine();
              }
            }
          }
        }
        {
          boolean _and = false;
          boolean _needsConfig = this._utils.needsConfig(app);
          if (!_needsConfig) {
            _and = false;
          } else {
            boolean _isConfigController = this._controllerExtensions.isConfigController(it);
            _and = (_needsConfig && _isConfigController);
          }
          if (_and) {
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("if (SecurityUtil::checkPermission($this->name . \'::\', \'::\', ACCESS_ADMIN)) {");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("$links[] = array(\'url\' => ModUtil::url($this->name, \'");
            String _configController = this._controllerExtensions.configController(app);
            String _formatForDB_2 = this._formattingExtensions.formatForDB(_configController);
            _builder.append(_formatForDB_2, "            ");
            _builder.append("\', \'config\'),");
            _builder.newLineIfNotEmpty();
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("                     ");
            _builder.append("\'text\' => $this->__(\'Configuration\'),");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("                     ");
            _builder.append("\'title\' => $this->__(\'Manage settings for this application\')");
            {
              boolean _targets_4 = this._utils.targets(app, "1.3.5");
              boolean _not_3 = (!_targets_4);
              if (_not_3) {
                _builder.append(",");
                _builder.newLineIfNotEmpty();
                _builder.append("    ");
                _builder.append("    ");
                _builder.append("                     ");
                _builder.append("\'icon\' => \'wrench\'");
              }
            }
            _builder.append(");");
            _builder.newLineIfNotEmpty();
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("}");
            _builder.newLine();
          }
        }
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("return $links;");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
      }
    }
    _builder.append("    ");
    CharSequence _additionalApiMethods = this.additionalApiMethods(it);
    _builder.append(_additionalApiMethods, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence menuLinksBetweenControllers(final Controller it) {
    CharSequence _switchResult = null;
    boolean _matched = false;
    if (!_matched) {
      if (it instanceof AdminController) {
        final AdminController _adminController = (AdminController)it;
        Controllers _container = _adminController.getContainer();
        Iterable<UserController> _userControllers = this._controllerExtensions.getUserControllers(_container);
        boolean _isEmpty = IterableExtensions.isEmpty(_userControllers);
        boolean _not = (!_isEmpty);
        if (_not) {
          _matched=true;
          StringConcatenation _builder = new StringConcatenation();
          Controllers _container_1 = _adminController.getContainer();
          Iterable<UserController> _userControllers_1 = this._controllerExtensions.getUserControllers(_container_1);
          final UserController userController = IterableExtensions.<UserController>head(_userControllers_1);
          _builder.newLineIfNotEmpty();
          _builder.append("if (SecurityUtil::checkPermission($this->name . \'::\', \'::\', ACCESS_READ)) {");
          _builder.newLine();
          _builder.append("    ");
          _builder.append("$links[] = array(\'url\' => ModUtil::url($this->name, \'");
          String _formattedName = this._controllerExtensions.formattedName(userController);
          _builder.append(_formattedName, "    ");
          _builder.append("\', ");
          String _indexUrlDetails = this.indexUrlDetails(userController);
          _builder.append(_indexUrlDetails, "    ");
          _builder.append("),");
          _builder.newLineIfNotEmpty();
          _builder.append("                     ");
          _builder.append("\'text\' => $this->__(\'Frontend\'),");
          _builder.newLine();
          _builder.append("                     ");
          _builder.append("\'title\' => $this->__(\'Switch to user area.\'),");
          _builder.newLine();
          _builder.append("                     ");
          {
            Controllers _container_2 = _adminController.getContainer();
            Application _application = _container_2.getApplication();
            boolean _targets = this._utils.targets(_application, "1.3.5");
            if (_targets) {
              _builder.append("\'class\' => \'z-icon-es-home\'");
            } else {
              _builder.append("\'icon\' => \'home\'");
            }
          }
          _builder.append(");");
          _builder.newLineIfNotEmpty();
          _builder.append("}");
          _builder.newLine();
          _switchResult = _builder;
        }
      }
    }
    if (!_matched) {
      if (it instanceof UserController) {
        final UserController _userController = (UserController)it;
        Controllers _container = _userController.getContainer();
        Iterable<AdminController> _adminControllers = this._controllerExtensions.getAdminControllers(_container);
        boolean _isEmpty = IterableExtensions.isEmpty(_adminControllers);
        boolean _not = (!_isEmpty);
        if (_not) {
          _matched=true;
          StringConcatenation _builder = new StringConcatenation();
          Controllers _container_1 = _userController.getContainer();
          Iterable<AdminController> _adminControllers_1 = this._controllerExtensions.getAdminControllers(_container_1);
          final AdminController adminController = IterableExtensions.<AdminController>head(_adminControllers_1);
          _builder.newLineIfNotEmpty();
          _builder.append("if (SecurityUtil::checkPermission($this->name . \'::\', \'::\', ACCESS_ADMIN)) {");
          _builder.newLine();
          _builder.append("    ");
          _builder.append("$links[] = array(\'url\' => ModUtil::url($this->name, \'");
          String _formattedName = this._controllerExtensions.formattedName(adminController);
          _builder.append(_formattedName, "    ");
          _builder.append("\', ");
          String _indexUrlDetails = this.indexUrlDetails(adminController);
          _builder.append(_indexUrlDetails, "    ");
          _builder.append("),");
          _builder.newLineIfNotEmpty();
          _builder.append("                     ");
          _builder.append("\'text\' => $this->__(\'Backend\'),");
          _builder.newLine();
          _builder.append("                     ");
          _builder.append("\'title\' => $this->__(\'Switch to administration area.\'),");
          _builder.newLine();
          _builder.append("                     ");
          {
            Controllers _container_2 = _userController.getContainer();
            Application _application = _container_2.getApplication();
            boolean _targets = this._utils.targets(_application, "1.3.5");
            if (_targets) {
              _builder.append("\'class\' => \'z-icon-es-options\'");
            } else {
              _builder.append("\'icon\' => \'wrench\'");
            }
          }
          _builder.append(");");
          _builder.newLineIfNotEmpty();
          _builder.append("}");
          _builder.newLine();
          _switchResult = _builder;
        }
      }
    }
    return _switchResult;
  }
  
  private String menuLinksPermissionLevel(final Controller it) {
    String _switchResult = null;
    boolean _matched = false;
    if (!_matched) {
      if (it instanceof AdminController) {
        final AdminController _adminController = (AdminController)it;
        Controllers _container = _adminController.getContainer();
        Iterable<UserController> _userControllers = this._controllerExtensions.getUserControllers(_container);
        boolean _isEmpty = IterableExtensions.isEmpty(_userControllers);
        boolean _not = (!_isEmpty);
        if (_not) {
          _matched=true;
          _switchResult = "ADMIN";
        }
      }
    }
    if (!_matched) {
      _switchResult = "READ";
    }
    return _switchResult;
  }
  
  private CharSequence additionalApiMethods(final Controller it) {
    CharSequence _switchResult = null;
    boolean _matched = false;
    if (!_matched) {
      if (it instanceof UserController) {
        final UserController _userController = (UserController)it;
        _matched=true;
        ShortUrls _shortUrls = new ShortUrls(this.app);
        CharSequence _generate = _shortUrls.generate(_userController);
        _switchResult = _generate;
      }
    }
    if (!_matched) {
      _switchResult = "";
    }
    return _switchResult;
  }
  
  private CharSequence apiImpl(final Controller it) {
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
        _builder.append("\\Api;");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
        _builder.append("use ");
        String _appNamespace_1 = this._utils.appNamespace(app);
        _builder.append(_appNamespace_1, "");
        _builder.append("\\Api\\Base\\");
        String _name = it.getName();
        String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(_name);
        _builder.append(_formatForCodeCapital, "");
        _builder.append("Api as Base");
        String _name_1 = it.getName();
        String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(_name_1);
        _builder.append(_formatForCodeCapital_1, "");
        _builder.append("Api;");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
      }
    }
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* This is the ");
    String _name_2 = it.getName();
    _builder.append(_name_2, " ");
    _builder.append(" api helper class.");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    {
      boolean _targets_1 = this._utils.targets(app, "1.3.5");
      if (_targets_1) {
        _builder.append("class ");
        String _appName = this._utils.appName(app);
        _builder.append(_appName, "");
        _builder.append("_Api_");
        String _name_3 = it.getName();
        String _formatForCodeCapital_2 = this._formattingExtensions.formatForCodeCapital(_name_3);
        _builder.append(_formatForCodeCapital_2, "");
        _builder.append(" extends ");
        String _appName_1 = this._utils.appName(app);
        _builder.append(_appName_1, "");
        _builder.append("_Api_Base_");
        String _name_4 = it.getName();
        String _formatForCodeCapital_3 = this._formattingExtensions.formatForCodeCapital(_name_4);
        _builder.append(_formatForCodeCapital_3, "");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("class ");
        String _name_5 = it.getName();
        String _formatForCodeCapital_4 = this._formattingExtensions.formatForCodeCapital(_name_5);
        _builder.append(_formatForCodeCapital_4, "");
        _builder.append("Api extends Base");
        String _name_6 = it.getName();
        String _formatForCodeCapital_5 = this._formattingExtensions.formatForCodeCapital(_name_6);
        _builder.append(_formatForCodeCapital_5, "");
        _builder.append("Api");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// feel free to add own api methods here");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private String indexUrlDetails(final Controller it) {
    String _xifexpression = null;
    boolean _hasActions = this._controllerExtensions.hasActions(it, "index");
    if (_hasActions) {
      String _xifexpression_1 = null;
      boolean _targets = this._utils.targets(this.app, "1.3.5");
      if (_targets) {
        _xifexpression_1 = "main";
      } else {
        _xifexpression_1 = "index";
      }
      String _plus = ("\'" + _xifexpression_1);
      String _plus_1 = (_plus + "\'");
      _xifexpression = _plus_1;
    } else {
      String _xifexpression_2 = null;
      boolean _hasActions_1 = this._controllerExtensions.hasActions(it, "view");
      if (_hasActions_1) {
        Controllers _container = it.getContainer();
        Application _application = _container.getApplication();
        Entity _leadingEntity = this._modelExtensions.getLeadingEntity(_application);
        String _name = _leadingEntity.getName();
        String _formatForCode = this._formattingExtensions.formatForCode(_name);
        String _plus_2 = ("\'view\', array(\'ot\' => \'" + _formatForCode);
        String _plus_3 = (_plus_2 + "\')");
        _xifexpression_2 = _plus_3;
      } else {
        String _xifexpression_3 = null;
        boolean _and = false;
        Controllers _container_1 = it.getContainer();
        Application _application_1 = _container_1.getApplication();
        boolean _needsConfig = this._utils.needsConfig(_application_1);
        if (!_needsConfig) {
          _and = false;
        } else {
          boolean _isConfigController = this._controllerExtensions.isConfigController(it);
          _and = (_needsConfig && _isConfigController);
        }
        if (_and) {
          _xifexpression_3 = "\'config\'";
        } else {
          _xifexpression_3 = "\'hooks\'";
        }
        _xifexpression_2 = _xifexpression_3;
      }
      _xifexpression = _xifexpression_2;
    }
    return _xifexpression;
  }
}
