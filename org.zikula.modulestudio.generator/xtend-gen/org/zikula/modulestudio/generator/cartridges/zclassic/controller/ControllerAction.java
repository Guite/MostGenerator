package org.zikula.modulestudio.generator.cartridges.zclassic.controller;

import com.google.common.base.Objects;
import com.google.inject.Inject;
import de.guite.modulestudio.metamodel.modulestudio.Action;
import de.guite.modulestudio.metamodel.modulestudio.AdminController;
import de.guite.modulestudio.metamodel.modulestudio.AjaxController;
import de.guite.modulestudio.metamodel.modulestudio.Application;
import de.guite.modulestudio.metamodel.modulestudio.Controller;
import de.guite.modulestudio.metamodel.modulestudio.CustomAction;
import de.guite.modulestudio.metamodel.modulestudio.CustomController;
import de.guite.modulestudio.metamodel.modulestudio.DeleteAction;
import de.guite.modulestudio.metamodel.modulestudio.DisplayAction;
import de.guite.modulestudio.metamodel.modulestudio.EditAction;
import de.guite.modulestudio.metamodel.modulestudio.Entity;
import de.guite.modulestudio.metamodel.modulestudio.ListField;
import de.guite.modulestudio.metamodel.modulestudio.MainAction;
import de.guite.modulestudio.metamodel.modulestudio.UserController;
import de.guite.modulestudio.metamodel.modulestudio.ViewAction;
import java.util.Arrays;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.eclipse.xtext.xbase.lib.StringExtensions;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.ControllerHelper;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.FormHandler;
import org.zikula.modulestudio.generator.extensions.ControllerExtensions;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class ControllerAction {
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
  private ModelBehaviourExtensions _modelBehaviourExtensions = new Function0<ModelBehaviourExtensions>() {
    public ModelBehaviourExtensions apply() {
      ModelBehaviourExtensions _modelBehaviourExtensions = new ModelBehaviourExtensions();
      return _modelBehaviourExtensions;
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
  private Utils _utils = new Function0<Utils>() {
    public Utils apply() {
      Utils _utils = new Utils();
      return _utils;
    }
  }.apply();
  
  private Application app;
  
  public ControllerAction(final Application app) {
    this.app = app;
  }
  
  protected CharSequence _generate(final Action it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _actionDoc = this.actionDoc(it);
    _builder.append(_actionDoc, "");
    _builder.newLineIfNotEmpty();
    _builder.append("public function ");
    String _name = it.getName();
    String _formatForCode = this._formattingExtensions.formatForCode(_name);
    String _firstLower = StringExtensions.toFirstLower(_formatForCode);
    _builder.append(_firstLower, "");
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
    {
      boolean _and = false;
      boolean _hasSoftDeleteable = this._modelBehaviourExtensions.hasSoftDeleteable(this.app);
      if (!_hasSoftDeleteable) {
        _and = false;
      } else {
        boolean _targets_1 = this._utils.targets(this.app, "1.3.5");
        boolean _not_1 = (!_targets_1);
        _and = (_hasSoftDeleteable && _not_1);
      }
      if (_and) {
        {
          Controller _controller = it.getController();
          boolean _tempIsAdminController = this.tempIsAdminController(_controller);
          if (_tempIsAdminController) {
            _builder.append("    ");
            _builder.append("//$this->entityManager->getFilters()->disable(\'soft-deleteable\');");
            _builder.newLine();
          } else {
            _builder.append("    ");
            _builder.append("$this->entityManager->getFilters()->enable(\'soft-deleteable\');");
            _builder.newLine();
          }
        }
      }
    }
    _builder.append("    ");
    CharSequence _actionImpl = this.actionImpl(it);
    _builder.append(_actionImpl, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    return _builder;
  }
  
  protected CharSequence _generate(final MainAction it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _actionDoc = this.actionDoc(it);
    _builder.append(_actionDoc, "");
    _builder.newLineIfNotEmpty();
    _builder.append("public function ");
    {
      boolean _targets = this._utils.targets(this.app, "1.3.5");
      boolean _not = (!_targets);
      if (_not) {
        _builder.append("indexAction");
      } else {
        _builder.append("main");
      }
    }
    _builder.append("(array $args = array())");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    {
      boolean _and = false;
      boolean _hasSoftDeleteable = this._modelBehaviourExtensions.hasSoftDeleteable(this.app);
      if (!_hasSoftDeleteable) {
        _and = false;
      } else {
        boolean _targets_1 = this._utils.targets(this.app, "1.3.5");
        boolean _not_1 = (!_targets_1);
        _and = (_hasSoftDeleteable && _not_1);
      }
      if (_and) {
        {
          Controller _controller = it.getController();
          boolean _tempIsAdminController = this.tempIsAdminController(_controller);
          if (_tempIsAdminController) {
            _builder.append("    ");
            _builder.append("//$this->entityManager->getFilters()->disable(\'soft-deleteable\');");
            _builder.newLine();
          } else {
            _builder.append("    ");
            _builder.append("$this->entityManager->getFilters()->enable(\'soft-deleteable\');");
            _builder.newLine();
          }
        }
      }
    }
    _builder.append("    ");
    CharSequence _actionImpl = this.actionImpl(it);
    _builder.append(_actionImpl, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence actionDoc(final Action it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* ");
    String _actionDocMethodDescription = this.actionDocMethodDescription(it);
    _builder.append(_actionDocMethodDescription, " ");
    _builder.newLineIfNotEmpty();
    String _actionDocMethodDocumentation = this.actionDocMethodDocumentation(it);
    _builder.append(_actionDocMethodDocumentation, "");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param array $args List of arguments.");
    _builder.newLine();
    String _actionDocMethodParams = this.actionDocMethodParams(it);
    _builder.append(_actionDocMethodParams, "");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return mixed Output.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    return _builder;
  }
  
  private String actionDocMethodDescription(final Action it) {
    String _switchResult = null;
    boolean _matched = false;
    if (!_matched) {
      if (it instanceof MainAction) {
        final MainAction _mainAction = (MainAction)it;
        _matched=true;
        Controller _controller = _mainAction.getController();
        String _formattedName = this._controllerExtensions.formattedName(_controller);
        String _plus = ("This method is the default function handling the " + _formattedName);
        String _plus_1 = (_plus + " area called without defining arguments.");
        _switchResult = _plus_1;
      }
    }
    if (!_matched) {
      if (it instanceof ViewAction) {
        final ViewAction _viewAction = (ViewAction)it;
        _matched=true;
        _switchResult = "This method provides a generic item list overview.";
      }
    }
    if (!_matched) {
      if (it instanceof DisplayAction) {
        final DisplayAction _displayAction = (DisplayAction)it;
        _matched=true;
        _switchResult = "This method provides a generic item detail view.";
      }
    }
    if (!_matched) {
      if (it instanceof EditAction) {
        final EditAction _editAction = (EditAction)it;
        _matched=true;
        _switchResult = "This method provides a generic handling of all edit requests.";
      }
    }
    if (!_matched) {
      if (it instanceof DeleteAction) {
        final DeleteAction _deleteAction = (DeleteAction)it;
        _matched=true;
        _switchResult = "This method provides a generic handling of simple delete requests.";
      }
    }
    if (!_matched) {
      if (it instanceof CustomAction) {
        final CustomAction _customAction = (CustomAction)it;
        _matched=true;
        _switchResult = "This is a custom method. Documentation for this will be improved in later versions.";
      }
    }
    if (!_matched) {
      _switchResult = "";
    }
    return _switchResult;
  }
  
  private String actionDocMethodDocumentation(final Action it) {
    String _xifexpression = null;
    boolean _and = false;
    String _documentation = it.getDocumentation();
    boolean _tripleNotEquals = (_documentation != null);
    if (!_tripleNotEquals) {
      _and = false;
    } else {
      String _documentation_1 = it.getDocumentation();
      boolean _notEquals = (!Objects.equal(_documentation_1, ""));
      _and = (_tripleNotEquals && _notEquals);
    }
    if (_and) {
      String _documentation_2 = it.getDocumentation();
      String _replaceAll = _documentation_2.replaceAll("*/", "*");
      String _plus = (" * " + _replaceAll);
      _xifexpression = _plus;
    } else {
      _xifexpression = "";
    }
    return _xifexpression;
  }
  
  private String actionDocMethodParams(final Action it) {
    String _xifexpression = null;
    boolean _and = false;
    boolean _tempIsIndexAction = this.tempIsIndexAction(it);
    boolean _not = (!_tempIsIndexAction);
    if (!_not) {
      _and = false;
    } else {
      boolean _tempIsCustomAction = this.tempIsCustomAction(it);
      boolean _not_1 = (!_tempIsCustomAction);
      _and = (_not && _not_1);
    }
    if (_and) {
      StringConcatenation _builder = new StringConcatenation();
      String _actionDocAdditionalParams = this.actionDocAdditionalParams(it);
      _builder.append(_actionDocAdditionalParams, "");
      String _plus = (" * @param string  $ot           Treated object type.\n" + _builder);
      String _plus_1 = (_plus + " * @param string  $tpl          Name of alternative template (for alternative display options, feeds and xml output)\n");
      String _plus_2 = (_plus_1 + " * @param boolean $raw          Optional way to display a template instead of fetching it (needed for standalone output)\n");
      _xifexpression = _plus_2;
    }
    return _xifexpression;
  }
  
  private String actionDocAdditionalParams(final Action it) {
    String _switchResult = null;
    boolean _matched = false;
    if (!_matched) {
      if (it instanceof ViewAction) {
        final ViewAction _viewAction = (ViewAction)it;
        _matched=true;
        String _plus = (" * @param string  $sort         Sorting field.\n" + " * @param string  $sortdir      Sorting direction.\n");
        String _plus_1 = (_plus + " * @param int     $pos          Current pager position.\n");
        String _plus_2 = (_plus_1 + " * @param int     $num          Amount of entries to display.\n");
        _switchResult = _plus_2;
      }
    }
    if (!_matched) {
      if (it instanceof DeleteAction) {
        final DeleteAction _deleteAction = (DeleteAction)it;
        _matched=true;
        String _plus = (" * @param int     $id           Identifier of entity to be deleted.\n" + " * @param boolean $confirmation Confirm the deletion, else a confirmation page is displayed.\n");
        _switchResult = _plus;
      }
    }
    if (!_matched) {
      _switchResult = "";
    }
    return _switchResult;
  }
  
  private boolean tempIsIndexAction(final Action it) {
    boolean _switchResult = false;
    boolean _matched = false;
    if (!_matched) {
      if (it instanceof MainAction) {
        final MainAction _mainAction = (MainAction)it;
        _matched=true;
        _switchResult = true;
      }
    }
    if (!_matched) {
      _switchResult = false;
    }
    return _switchResult;
  }
  
  private boolean tempIsCustomAction(final Action it) {
    boolean _switchResult = false;
    boolean _matched = false;
    if (!_matched) {
      if (it instanceof CustomAction) {
        final CustomAction _customAction = (CustomAction)it;
        _matched=true;
        _switchResult = true;
      }
    }
    if (!_matched) {
      _switchResult = false;
    }
    return _switchResult;
  }
  
  private CharSequence actionImpl(final Action it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _tempIsIndexAction = this.tempIsIndexAction(it);
      if (_tempIsIndexAction) {
        CharSequence _permissionCheck = this.permissionCheck(it, "", "");
        _builder.append(_permissionCheck, "");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("$controllerHelper = new ");
        {
          boolean _targets = this._utils.targets(this.app, "1.3.5");
          if (_targets) {
            String _appName = this._utils.appName(this.app);
            _builder.append(_appName, "");
            _builder.append("_Util_Controller");
          } else {
            _builder.append("ControllerUtil");
          }
        }
        _builder.append("($this->serviceManager");
        {
          boolean _targets_1 = this._utils.targets(this.app, "1.3.5");
          boolean _not = (!_targets_1);
          if (_not) {
            _builder.append(", ModUtil::getModule($this->name)");
          }
        }
        _builder.append(");");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
        _builder.append("// parameter specifying which type of objects we are treating");
        _builder.newLine();
        _builder.append("$objectType = (isset($args[\'ot\']) && !empty($args[\'ot\'])) ? $args[\'ot\'] : $this->request->query->filter(\'ot\', \'");
        Entity _leadingEntity = this._modelExtensions.getLeadingEntity(this.app);
        String _name = _leadingEntity.getName();
        String _formatForCode = this._formattingExtensions.formatForCode(_name);
        _builder.append(_formatForCode, "");
        _builder.append("\', FILTER_SANITIZE_STRING);");
        _builder.newLineIfNotEmpty();
        _builder.append("$utilArgs = array(\'controller\' => \'");
        Controller _controller = it.getController();
        String _formattedName = this._controllerExtensions.formattedName(_controller);
        _builder.append(_formattedName, "");
        _builder.append("\', \'action\' => \'");
        String _name_1 = it.getName();
        String _formatForCode_1 = this._formattingExtensions.formatForCode(_name_1);
        String _firstLower = StringExtensions.toFirstLower(_formatForCode_1);
        _builder.append(_firstLower, "");
        _builder.append("\');");
        _builder.newLineIfNotEmpty();
        _builder.append("if (!in_array($objectType, $controllerHelper->getObjectTypes(\'controllerAction\', $utilArgs))) {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$objectType = $controllerHelper->getDefaultObjectType(\'controllerAction\', $utilArgs);");
        _builder.newLine();
        _builder.append("}");
        _builder.newLine();
        _builder.append("if (!isset($args[\'skipPermissionCheck\']) || $args[\'skipPermissionCheck\'] != 1) {");
        _builder.newLine();
        _builder.append("    ");
        CharSequence _permissionCheck_1 = this.permissionCheck(it, "\' . ucwords($objectType) . \'", "");
        _builder.append(_permissionCheck_1, "    ");
        _builder.newLineIfNotEmpty();
        _builder.append("}");
        _builder.newLine();
      }
    }
    CharSequence _actionImplBody = this.actionImplBody(it);
    _builder.append(_actionImplBody, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  /**
   * Permission checks in system use cases.
   */
  private CharSequence permissionCheck(final Action it, final String objectTypeVar, final String instanceId) {
    CharSequence _switchResult = null;
    Controller _controller = it.getController();
    final Controller getController = _controller;
    boolean _matched = false;
    if (!_matched) {
      if (getController instanceof AdminController) {
        final AdminController _adminController = (AdminController)getController;
        _matched=true;
        StringConcatenation _builder = new StringConcatenation();
        _builder.append("$this->throwForbiddenUnless(SecurityUtil::checkPermission($this->name . \':");
        _builder.append(objectTypeVar, "");
        _builder.append(":\', ");
        _builder.append(instanceId, "");
        _builder.append("\'::\', ACCESS_ADMIN), LogUtil::getErrorMsgPermission());");
        _builder.newLineIfNotEmpty();
        _switchResult = _builder;
      }
    }
    if (!_matched) {
      StringConcatenation _builder = new StringConcatenation();
      _builder.append("$this->throwForbiddenUnless(SecurityUtil::checkPermission($this->name . \':");
      _builder.append(objectTypeVar, "");
      _builder.append(":\', ");
      _builder.append(instanceId, "");
      _builder.append("\'::\', ");
      String _permissionAccessLevel = this.getPermissionAccessLevel(it);
      _builder.append(_permissionAccessLevel, "");
      _builder.append("), LogUtil::getErrorMsgPermission());");
      _builder.newLineIfNotEmpty();
      _switchResult = _builder;
    }
    return _switchResult;
  }
  
  private String getPermissionAccessLevel(final Action it) {
    String _switchResult = null;
    boolean _matched = false;
    if (!_matched) {
      if (it instanceof MainAction) {
        final MainAction _mainAction = (MainAction)it;
        _matched=true;
        _switchResult = "ACCESS_OVERVIEW";
      }
    }
    if (!_matched) {
      if (it instanceof ViewAction) {
        final ViewAction _viewAction = (ViewAction)it;
        _matched=true;
        _switchResult = "ACCESS_READ";
      }
    }
    if (!_matched) {
      if (it instanceof DisplayAction) {
        final DisplayAction _displayAction = (DisplayAction)it;
        _matched=true;
        _switchResult = "ACCESS_READ";
      }
    }
    if (!_matched) {
      if (it instanceof EditAction) {
        final EditAction _editAction = (EditAction)it;
        _matched=true;
        _switchResult = "ACCESS_EDIT";
      }
    }
    if (!_matched) {
      if (it instanceof DeleteAction) {
        final DeleteAction _deleteAction = (DeleteAction)it;
        _matched=true;
        _switchResult = "ACCESS_DELETE";
      }
    }
    if (!_matched) {
      if (it instanceof CustomAction) {
        final CustomAction _customAction = (CustomAction)it;
        _matched=true;
        _switchResult = "ACCESS_OVERVIEW";
      }
    }
    if (!_matched) {
      _switchResult = "ACCESS_ADMIN";
    }
    return _switchResult;
  }
  
  private CharSequence _actionImplBody(final Action it) {
    return null;
  }
  
  private CharSequence _actionImplBody(final MainAction it) {
    CharSequence _switchResult = null;
    Controller _controller = it.getController();
    final Controller getController = _controller;
    boolean _matched = false;
    if (!_matched) {
      if (getController instanceof UserController) {
        final UserController _userController = (UserController)getController;
        _matched=true;
        StringConcatenation _builder = new StringConcatenation();
        _builder.append("// set caching id");
        _builder.newLine();
        _builder.append("$this->view->setCacheId(\'");
        {
          boolean _targets = this._utils.targets(this.app, "1.3.5");
          if (_targets) {
            _builder.append("main");
          } else {
            _builder.append("index");
          }
        }
        _builder.append("\');");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
        _builder.append("// return ");
        {
          boolean _targets_1 = this._utils.targets(this.app, "1.3.5");
          if (_targets_1) {
            _builder.append("main");
          } else {
            _builder.append("index");
          }
        }
        _builder.append(" template");
        _builder.newLineIfNotEmpty();
        {
          boolean _targets_2 = this._utils.targets(this.app, "1.3.5");
          if (_targets_2) {
            _builder.append("return $this->view->fetch(\'");
            Controller _controller_1 = it.getController();
            String _formattedName = this._controllerExtensions.formattedName(_controller_1);
            _builder.append(_formattedName, "");
            _builder.append("/main.tpl\');");
            _builder.newLineIfNotEmpty();
          } else {
            _builder.append("return $this->response($this->view->fetch(\'");
            Controller _controller_2 = it.getController();
            String _formattedName_1 = this._controllerExtensions.formattedName(_controller_2);
            String _firstUpper = StringExtensions.toFirstUpper(_formattedName_1);
            _builder.append(_firstUpper, "");
            _builder.append("/index.tpl\'));");
            _builder.newLineIfNotEmpty();
          }
        }
        _switchResult = _builder;
      }
    }
    if (!_matched) {
      if (getController instanceof AdminController) {
        final AdminController _adminController = (AdminController)getController;
        _matched=true;
        StringConcatenation _builder = new StringConcatenation();
        _builder.append("// set caching id");
        _builder.newLine();
        _builder.append("$this->view->setCacheId(\'");
        {
          boolean _targets = this._utils.targets(this.app, "1.3.5");
          if (_targets) {
            _builder.append("main");
          } else {
            _builder.append("index");
          }
        }
        _builder.append("\');");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
        _builder.newLine();
        _builder.append("// return ");
        {
          boolean _targets_1 = this._utils.targets(this.app, "1.3.5");
          if (_targets_1) {
            _builder.append("main");
          } else {
            _builder.append("index");
          }
        }
        _builder.append(" template");
        _builder.newLineIfNotEmpty();
        {
          boolean _targets_2 = this._utils.targets(this.app, "1.3.5");
          if (_targets_2) {
            _builder.append("return $this->view->fetch(\'");
            Controller _controller_1 = it.getController();
            String _formattedName = this._controllerExtensions.formattedName(_controller_1);
            _builder.append(_formattedName, "");
            _builder.append("/main.tpl\');");
            _builder.newLineIfNotEmpty();
          } else {
            _builder.append("return $this->response($this->view->fetch(\'");
            Controller _controller_2 = it.getController();
            String _formattedName_1 = this._controllerExtensions.formattedName(_controller_2);
            String _firstUpper = StringExtensions.toFirstUpper(_formattedName_1);
            _builder.append(_firstUpper, "");
            _builder.append("/index.tpl\'));");
            _builder.newLineIfNotEmpty();
          }
        }
        _builder.newLine();
        _switchResult = _builder;
      }
    }
    if (!_matched) {
      if (getController instanceof AjaxController) {
        final AjaxController _ajaxController = (AjaxController)getController;
        _matched=true;
        _switchResult = "";
      }
    }
    if (!_matched) {
      if (getController instanceof CustomController) {
        final CustomController _customController = (CustomController)getController;
        _matched=true;
        StringConcatenation _builder = new StringConcatenation();
        _builder.append("// set caching id");
        _builder.newLine();
        _builder.append("$this->view->setCacheId(\'");
        {
          boolean _targets = this._utils.targets(this.app, "1.3.5");
          if (_targets) {
            _builder.append("main");
          } else {
            _builder.append("index");
          }
        }
        _builder.append("\');");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
        _builder.append("// return ");
        {
          boolean _targets_1 = this._utils.targets(this.app, "1.3.5");
          if (_targets_1) {
            _builder.append("main");
          } else {
            _builder.append("index");
          }
        }
        _builder.append(" template");
        _builder.newLineIfNotEmpty();
        {
          boolean _targets_2 = this._utils.targets(this.app, "1.3.5");
          if (_targets_2) {
            _builder.append("return $this->view->fetch(\'");
            Controller _controller_1 = it.getController();
            String _formattedName = this._controllerExtensions.formattedName(_controller_1);
            _builder.append(_formattedName, "");
            _builder.append("/main.tpl\');");
            _builder.newLineIfNotEmpty();
          } else {
            _builder.append("return $this->response($this->view->fetch(\'");
            Controller _controller_2 = it.getController();
            String _formattedName_1 = this._controllerExtensions.formattedName(_controller_2);
            String _firstUpper = StringExtensions.toFirstUpper(_formattedName_1);
            _builder.append(_firstUpper, "");
            _builder.append("/index.tpl\'));");
            _builder.newLineIfNotEmpty();
          }
        }
        _switchResult = _builder;
      }
    }
    return _switchResult;
  }
  
  private CharSequence _actionImplBody(final ViewAction it) {
    StringConcatenation _builder = new StringConcatenation();
    Controller _controller = it.getController();
    boolean _isAjaxController = this._controllerExtensions.isAjaxController(_controller);
    final boolean hasView = (!_isAjaxController);
    _builder.newLineIfNotEmpty();
    {
      boolean _targets = this._utils.targets(this.app, "1.3.5");
      if (_targets) {
        _builder.append("$entityClass = $this->name . \'_Entity_\' . ucwords($objectType);");
        _builder.newLine();
      } else {
        _builder.append("$entityClass = \'\\\\");
        String _vendor = this.app.getVendor();
        String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(_vendor);
        _builder.append(_formatForCodeCapital, "");
        _builder.append("\\\\");
        String _name = this.app.getName();
        String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(_name);
        _builder.append(_formatForCodeCapital_1, "");
        _builder.append("Module\\\\Entity\\\\\' . ucwords($objectType) . \'Entity\';");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("$repository = $this->entityManager->getRepository($entityClass);");
    _builder.newLine();
    _builder.append("$repository->setControllerArguments($args);");
    _builder.newLine();
    {
      if (hasView) {
        _builder.append("$viewHelper = new ");
        {
          boolean _targets_1 = this._utils.targets(this.app, "1.3.5");
          if (_targets_1) {
            String _appName = this._utils.appName(this.app);
            _builder.append(_appName, "");
            _builder.append("_Util_View");
          } else {
            _builder.append("ViewUtil");
          }
        }
        _builder.append("($this->serviceManager");
        {
          boolean _targets_2 = this._utils.targets(this.app, "1.3.5");
          boolean _not = (!_targets_2);
          if (_not) {
            _builder.append(", ModUtil::getModule($this->name)");
          }
        }
        _builder.append(");");
        _builder.newLineIfNotEmpty();
        {
          boolean _hasTrees = this._modelBehaviourExtensions.hasTrees(this.app);
          if (_hasTrees) {
            _builder.newLine();
            _builder.append("$tpl = (isset($args[\'tpl\']) && !empty($args[\'tpl\'])) ? $args[\'tpl\'] : $this->request->query->filter(\'tpl\', \'\', FILTER_SANITIZE_STRING);");
            _builder.newLine();
            _builder.append("if ($tpl == \'tree\') {");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("$trees = ModUtil::apiFunc($this->name, \'selection\', \'getAllTrees\', array(\'ot\' => $objectType));");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("$this->view->assign(\'trees\', $trees)");
            _builder.newLine();
            _builder.append("               ");
            _builder.append("->assign($repository->getAdditionalTemplateParameters(\'controllerAction\', $utilArgs));");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("// fetch and return the appropriate template");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("return $viewHelper->processTemplate($this->view, \'");
            Controller _controller_1 = it.getController();
            String _formattedName = this._controllerExtensions.formattedName(_controller_1);
            _builder.append(_formattedName, "    ");
            _builder.append("\', $objectType, \'view\', $args);");
            _builder.newLineIfNotEmpty();
            _builder.append("}");
            _builder.newLine();
          }
        }
      }
    }
    _builder.newLine();
    _builder.append("// parameter for used sorting field");
    _builder.newLine();
    _builder.append("$sort = (isset($args[\'sort\']) && !empty($args[\'sort\'])) ? $args[\'sort\'] : $this->request->query->filter(\'sort\', \'\', FILTER_SANITIZE_STRING);");
    _builder.newLine();
    ControllerHelper _controllerHelper = new ControllerHelper();
    CharSequence _defaultSorting = _controllerHelper.defaultSorting(it);
    _builder.append(_defaultSorting, "");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("// parameter for used sort order");
    _builder.newLine();
    _builder.append("$sdir = (isset($args[\'sortdir\']) && !empty($args[\'sortdir\'])) ? $args[\'sortdir\'] : $this->request->query->filter(\'sortdir\', \'\', FILTER_SANITIZE_STRING);");
    _builder.newLine();
    _builder.append("$sdir = strtolower($sdir);");
    _builder.newLine();
    _builder.append("if ($sdir != \'asc\' && $sdir != \'desc\') {");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$sdir = \'asc\';");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("// convenience vars to make code clearer");
    _builder.newLine();
    _builder.append("$currentUrlArgs = array(\'ot\' => $objectType);");
    _builder.newLine();
    _builder.newLine();
    {
      Controller _controller_2 = it.getController();
      boolean _isAjaxController_1 = this._controllerExtensions.isAjaxController(_controller_2);
      if (_isAjaxController_1) {
        _builder.append("$where = (isset($args[\'where\']) && !empty($args[\'where\'])) ? $args[\'where\'] : $this->request->query->filter(\'where\', \'\');");
        _builder.newLine();
        _builder.append("$where = str_replace(\'\"\', \'\', $where);");
        _builder.newLine();
      } else {
        _builder.append("$where = \'\';");
        _builder.newLine();
      }
    }
    _builder.newLine();
    _builder.append("$selectionArgs = array(");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("\'ot\' => $objectType,");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("\'where\' => $where,");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("\'orderBy\' => $sort . \' \' . $sdir");
    _builder.newLine();
    _builder.append(");");
    _builder.newLine();
    _builder.newLine();
    _builder.append("$showOwnEntries = (int) (isset($args[\'own\']) && !empty($args[\'own\'])) ? $args[\'own\'] : $this->request->query->filter(\'own\', 0, FILTER_VALIDATE_INT);");
    _builder.newLine();
    _builder.append("$showAllEntries = (int) (isset($args[\'all\']) && !empty($args[\'all\'])) ? $args[\'all\'] : $this->request->query->filter(\'all\', 0, FILTER_VALIDATE_INT);");
    _builder.newLine();
    _builder.newLine();
    {
      if (hasView) {
        _builder.append("$this->view->assign(\'showOwnEntries\', $showOwnEntries)");
        _builder.newLine();
        _builder.append("           ");
        _builder.append("->assign(\'showAllEntries\', $showAllEntries);");
        _builder.newLine();
      }
    }
    _builder.append("if ($showOwnEntries == 1) {");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$currentUrlArgs[\'own\'] = 1;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.append("if ($showAllEntries == 1) {");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$currentUrlArgs[\'all\'] = 1;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("// prepare access level for cache id");
    _builder.newLine();
    _builder.append("$accessLevel = ACCESS_READ;");
    _builder.newLine();
    _builder.append("$component = \'");
    String _appName_1 = this._utils.appName(this.app);
    _builder.append(_appName_1, "");
    _builder.append(":\' . ucwords($objectType) . \':\';");
    _builder.newLineIfNotEmpty();
    _builder.append("$instance = \'::\';");
    _builder.newLine();
    _builder.append("if (SecurityUtil::checkPermission($component, $instance, ACCESS_COMMENT)) {");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$accessLevel = ACCESS_COMMENT;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.append("if (SecurityUtil::checkPermission($component, $instance, ACCESS_EDIT)) {");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$accessLevel = ACCESS_EDIT;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    {
      if (hasView) {
        _builder.append("$templateFile = $viewHelper->getViewTemplate($this->view, \'");
        Controller _controller_3 = it.getController();
        String _formattedName_1 = this._controllerExtensions.formattedName(_controller_3);
        _builder.append(_formattedName_1, "");
        _builder.append("\', $objectType, \'view\', $args);");
        _builder.newLineIfNotEmpty();
        _builder.append("$cacheId = \'view|ot_\' . $objectType . \'_sort_\' . $sort . \'_\' . $sdir;");
        _builder.newLine();
      }
    }
    _builder.append("$resultsPerPage = 0;");
    _builder.newLine();
    _builder.append("if ($showAllEntries == 1) {");
    _builder.newLine();
    {
      if (hasView) {
        _builder.append("    ");
        _builder.append("// set cache id");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$this->view->setCacheId($cacheId . \'_all_1_own_\' . $showOwnEntries . \'_\' . $accessLevel);");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("// if page is cached return cached content");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("if ($this->view->is_cached($templateFile)) {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("return $viewHelper->processTemplate($this->view, \'");
        Controller _controller_4 = it.getController();
        String _formattedName_2 = this._controllerExtensions.formattedName(_controller_4);
        _builder.append(_formattedName_2, "        ");
        _builder.append("\', $objectType, \'view\', $args, $templateFile);");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
        _builder.newLine();
      }
    }
    _builder.append("    ");
    _builder.append("// retrieve item list without pagination");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$entities = ModUtil::apiFunc($this->name, \'selection\', \'getEntities\', $selectionArgs);");
    _builder.newLine();
    {
      boolean _not_1 = (!hasView);
      if (_not_1) {
        _builder.append("    ");
        _builder.append("$objectCount = count($entities);");
        _builder.newLine();
      }
    }
    _builder.append("} else {");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// the current offset which is used to calculate the pagination");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$currentPage = (int) (isset($args[\'pos\']) && !empty($args[\'pos\'])) ? $args[\'pos\'] : $this->request->query->filter(\'pos\', 1, FILTER_VALIDATE_INT);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// the number of items displayed on a page for pagination");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$resultsPerPage = (int) (isset($args[\'num\']) && !empty($args[\'num\'])) ? $args[\'num\'] : $this->request->query->filter(\'num\', 0, FILTER_VALIDATE_INT);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($resultsPerPage == 0) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$csv = (int) (isset($args[\'usecsv\']) && !empty($args[\'usecsv\'])) ? $args[\'usecsv\'] : $this->request->query->filter(\'usecsvext\', 0, FILTER_VALIDATE_INT);");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$resultsPerPage = ($csv == 1) ? 999999 : $this->getVar(\'pageSize\', 10);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    {
      if (hasView) {
        _builder.append("    ");
        _builder.append("// set cache id");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$this->view->setCacheId($cacheId . \'_amount_\' . $resultsPerPage . \'_page_\' . $currentPage . \'_own_\' . $showOwnEntries . \'_\' . $accessLevel);");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("// if page is cached return cached content");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("if ($this->view->is_cached($templateFile)) {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("return $viewHelper->processTemplate($this->view, \'");
        Controller _controller_5 = it.getController();
        String _formattedName_3 = this._controllerExtensions.formattedName(_controller_5);
        _builder.append(_formattedName_3, "        ");
        _builder.append("\', $objectType, \'view\', $args, $templateFile);");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
        _builder.newLine();
      }
    }
    _builder.append("    ");
    _builder.append("// retrieve item list with pagination");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$selectionArgs[\'currentPage\'] = $currentPage;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$selectionArgs[\'resultsPerPage\'] = $resultsPerPage;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("list($entities, $objectCount) = ModUtil::apiFunc($this->name, \'selection\', \'getEntitiesPaginated\', $selectionArgs);");
    _builder.newLine();
    {
      if (hasView) {
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$this->view->assign(\'currentPage\', $currentPage)");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("           ");
        _builder.append("->assign(\'pager\', array(\'numitems\'     => $objectCount,");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("                                   ");
        _builder.append("\'itemsperpage\' => $resultsPerPage));");
        _builder.newLine();
      }
    }
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("foreach ($entities as $k => $entity) {");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$entity->initWorkflow();");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    {
      if (hasView) {
        _builder.newLine();
        _builder.append("// build ModUrl instance for display hooks");
        _builder.newLine();
        _builder.append("$currentUrlObject = new ");
        {
          boolean _targets_3 = this._utils.targets(this.app, "1.3.5");
          if (_targets_3) {
            _builder.append("Zikula_");
          }
        }
        _builder.append("ModUrl($this->name, \'");
        Controller _controller_6 = it.getController();
        String _formattedName_4 = this._controllerExtensions.formattedName(_controller_6);
        _builder.append(_formattedName_4, "");
        _builder.append("\', \'view\', ZLanguage::getLanguageCode(), $currentUrlArgs);");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
        _builder.append("// assign the object data, sorting information and details for creating the pager");
        _builder.newLine();
        _builder.append("$this->view->assign(\'items\', $entities)");
        _builder.newLine();
        _builder.append("           ");
        _builder.append("->assign(\'sort\', $sort)");
        _builder.newLine();
        _builder.append("           ");
        _builder.append("->assign(\'sdir\', $sdir)");
        _builder.newLine();
        _builder.append("           ");
        _builder.append("->assign(\'pageSize\', $resultsPerPage)");
        _builder.newLine();
        _builder.append("           ");
        _builder.append("->assign(\'currentUrlObject\', $currentUrlObject)");
        _builder.newLine();
        _builder.append("           ");
        _builder.append("->assign($repository->getAdditionalTemplateParameters(\'controllerAction\', $utilArgs));");
        _builder.newLine();
        _builder.newLine();
        _builder.append("// fetch and return the appropriate template");
        _builder.newLine();
        _builder.append("return $viewHelper->processTemplate($this->view, \'");
        Controller _controller_7 = it.getController();
        String _formattedName_5 = this._controllerExtensions.formattedName(_controller_7);
        _builder.append(_formattedName_5, "");
        _builder.append("\', $objectType, \'view\', $args, $templateFile);");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("$items = array();");
        _builder.newLine();
        {
          boolean _hasListFields = this._modelExtensions.hasListFields(this.app);
          if (_hasListFields) {
            _builder.append("$listHelper = new ");
            {
              boolean _targets_4 = this._utils.targets(this.app, "1.3.5");
              if (_targets_4) {
                String _appName_2 = this._utils.appName(this.app);
                _builder.append(_appName_2, "");
                _builder.append("_Util_ListEntries");
              } else {
                _builder.append("ListEntriesUtil");
              }
            }
            _builder.append("($this->serviceManager");
            {
              boolean _targets_5 = this._utils.targets(this.app, "1.3.5");
              boolean _not_2 = (!_targets_5);
              if (_not_2) {
                _builder.append(", ModUtil::getModule($this->name)");
              }
            }
            _builder.append(");");
            _builder.newLineIfNotEmpty();
            _builder.append("$listObjectTypes = array(");
            {
              Iterable<Entity> _listEntities = this._modelExtensions.getListEntities(this.app);
              boolean _hasElements = false;
              for(final Entity entity : _listEntities) {
                if (!_hasElements) {
                  _hasElements = true;
                } else {
                  _builder.appendImmediate(", ", "");
                }
                _builder.append("\'");
                String _name_1 = entity.getName();
                String _formatForCode = this._formattingExtensions.formatForCode(_name_1);
                _builder.append(_formatForCode, "");
                _builder.append("\'");
              }
            }
            _builder.append(");");
            _builder.newLineIfNotEmpty();
            _builder.append("$hasListFields = (in_array($objectType, $listObjectTypes));");
            _builder.newLine();
            _builder.newLine();
            _builder.append("foreach ($entities as $item) {");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("$currItem = $item->toArray();");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("if ($hasListFields) {");
            _builder.newLine();
            _builder.append("        ");
            _builder.append("// convert list field values to their corresponding labels");
            _builder.newLine();
            _builder.append("        ");
            _builder.append("switch ($objectType) {");
            _builder.newLine();
            {
              Iterable<Entity> _listEntities_1 = this._modelExtensions.getListEntities(this.app);
              for(final Entity entity_1 : _listEntities_1) {
                _builder.append("            ");
                _builder.append("case \'");
                String _name_2 = entity_1.getName();
                String _formatForCode_1 = this._formattingExtensions.formatForCode(_name_2);
                _builder.append(_formatForCode_1, "            ");
                _builder.append("\':");
                _builder.newLineIfNotEmpty();
                {
                  Iterable<ListField> _listFieldsEntity = this._modelExtensions.getListFieldsEntity(entity_1);
                  for(final ListField field : _listFieldsEntity) {
                    _builder.append("            ");
                    _builder.append("    ");
                    _builder.append("$currItem[\'");
                    String _name_3 = field.getName();
                    String _formatForCode_2 = this._formattingExtensions.formatForCode(_name_3);
                    _builder.append(_formatForCode_2, "                ");
                    _builder.append("\'] = $listHelper->resolve($currItem[\'");
                    String _name_4 = field.getName();
                    String _formatForCode_3 = this._formattingExtensions.formatForCode(_name_4);
                    _builder.append(_formatForCode_3, "                ");
                    _builder.append("\'], $objectType, \'");
                    String _name_5 = field.getName();
                    String _formatForCode_4 = this._formattingExtensions.formatForCode(_name_5);
                    _builder.append(_formatForCode_4, "                ");
                    _builder.append("\', \', \');");
                    _builder.newLineIfNotEmpty();
                  }
                }
                _builder.append("            ");
                _builder.append("    ");
                _builder.append("break;");
                _builder.newLine();
              }
            }
            _builder.append("        ");
            _builder.append("}");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("}");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("$items[] = $currItem;");
            _builder.newLine();
            _builder.append("}");
            _builder.newLine();
          } else {
            _builder.append("foreach ($entities as $item) {");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("$items[] = $item->toArray();");
            _builder.newLine();
            _builder.append("}");
            _builder.newLine();
          }
        }
        _builder.newLine();
        _builder.append("$result = array(\'objectCount\' => $objectCount, \'items\' => $items);");
        _builder.newLine();
        _builder.newLine();
        _builder.append("return new ");
        {
          boolean _targets_6 = this._utils.targets(this.app, "1.3.5");
          if (_targets_6) {
            _builder.append("Zikula_Response_Ajax");
          } else {
            _builder.append("AjaxResponse");
          }
        }
        _builder.append("($result);");
        _builder.newLineIfNotEmpty();
      }
    }
    return _builder;
  }
  
  private CharSequence _actionImplBody(final DisplayAction it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _targets = this._utils.targets(this.app, "1.3.5");
      if (_targets) {
        _builder.append("$entityClass = $this->name . \'_Entity_\' . ucwords($objectType);");
        _builder.newLine();
      } else {
        _builder.append("$entityClass = \'\\\\");
        String _vendor = this.app.getVendor();
        String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(_vendor);
        _builder.append(_formatForCodeCapital, "");
        _builder.append("\\\\");
        String _name = this.app.getName();
        String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(_name);
        _builder.append(_formatForCodeCapital_1, "");
        _builder.append("Module\\\\Entity\\\\\' . ucwords($objectType) . \'Entity\';");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("$repository = $this->entityManager->getRepository($entityClass);");
    _builder.newLine();
    _builder.append("$repository->setControllerArguments($args);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("$idFields = ModUtil::apiFunc($this->name, \'selection\', \'getIdFields\', array(\'ot\' => $objectType));");
    _builder.newLine();
    _builder.newLine();
    _builder.append("// retrieve identifier of the object we wish to view");
    _builder.newLine();
    _builder.append("$idValues = $controllerHelper->retrieveIdentifier($this->request, $args, $objectType, $idFields);");
    _builder.newLine();
    _builder.append("$hasIdentifier = $controllerHelper->isValidIdentifier($idValues);");
    _builder.newLine();
    Controller _controller = it.getController();
    CharSequence _checkForSlug = this.checkForSlug(_controller);
    _builder.append(_checkForSlug, "");
    _builder.newLineIfNotEmpty();
    _builder.append("$this->throwNotFoundUnless($hasIdentifier, $this->__(\'Error! Invalid identifier received.\'));");
    _builder.newLine();
    _builder.newLine();
    _builder.append("$entity = ModUtil::apiFunc($this->name, \'selection\', \'getEntity\', array(\'ot\' => $objectType, \'id\' => $idValues");
    Controller _controller_1 = it.getController();
    String _addSlugToSelection = this.addSlugToSelection(_controller_1);
    _builder.append(_addSlugToSelection, "");
    _builder.append("));");
    _builder.newLineIfNotEmpty();
    _builder.append("$this->throwNotFoundUnless($entity != null, $this->__(\'No such item.\'));");
    _builder.newLine();
    _builder.append("unset($idValues);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("$entity->initWorkflow();");
    _builder.newLine();
    _builder.newLine();
    Controller _controller_2 = it.getController();
    CharSequence _prepareDisplayPermissionCheck = this.prepareDisplayPermissionCheck(_controller_2);
    _builder.append(_prepareDisplayPermissionCheck, "");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("if (!isset($args[\'skipPermissionCheck\']) || $args[\'skipPermissionCheck\'] != 1) {");
    _builder.newLine();
    _builder.append("    ");
    CharSequence _permissionCheck = this.permissionCheck(it, "\' . ucwords($objectType) . \'", "$instanceId . ");
    _builder.append(_permissionCheck, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    Controller _controller_3 = it.getController();
    CharSequence _processDisplayOutput = this.processDisplayOutput(_controller_3);
    _builder.append(_processDisplayOutput, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence checkForSlug(final Controller it) {
    CharSequence _switchResult = null;
    boolean _matched = false;
    if (!_matched) {
      if (it instanceof UserController) {
        final UserController _userController = (UserController)it;
        _matched=true;
        StringConcatenation _builder = new StringConcatenation();
        _builder.newLine();
        _builder.append("// check for unique permalinks (without id)");
        _builder.newLine();
        _builder.append("$hasSlug = false;");
        _builder.newLine();
        _builder.append("$slug = \'\';");
        _builder.newLine();
        _builder.append("if ($hasIdentifier === false) {");
        _builder.newLine();
        {
          boolean _targets = this._utils.targets(this.app, "1.3.5");
          if (_targets) {
            _builder.append("    ");
            _builder.append("$entityClass = $this->name . \'_Entity_\' . ucwords($objectType);");
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
            _builder.append("Module\\\\Entity\\\\\' . ucwords($objectType) . \'Entity\';");
            _builder.newLineIfNotEmpty();
          }
        }
        _builder.append("    ");
        _builder.append("$objectTemp = new $entityClass();");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$hasSlug = $objectTemp->get_hasUniqueSlug();");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("if ($hasSlug) {");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("$slug = (isset($args[\'slug\']) && !empty($args[\'slug\'])) ? $args[\'slug\'] : $this->request->query->filter(\'slug\', \'\', FILTER_SANITIZE_STRING);");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("$hasSlug = (!empty($slug));");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
        _builder.append("}");
        _builder.newLine();
        _builder.append("$hasIdentifier |= $hasSlug;");
        _builder.newLine();
        _switchResult = _builder;
      }
    }
    if (!_matched) {
      _switchResult = "";
    }
    return _switchResult;
  }
  
  private String addSlugToSelection(final Controller it) {
    String _switchResult = null;
    boolean _matched = false;
    if (!_matched) {
      if (it instanceof UserController) {
        final UserController _userController = (UserController)it;
        _matched=true;
        _switchResult = ", \'slug\' => $slug";
      }
    }
    if (!_matched) {
      _switchResult = "";
    }
    return _switchResult;
  }
  
  private CharSequence prepareDisplayPermissionCheckWithoutCurrentUrlArgs() {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("// create identifier for permission check");
    _builder.newLine();
    _builder.append("$instanceId = \'\';");
    _builder.newLine();
    _builder.append("foreach ($idFields as $idField) {");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!empty($instanceId)) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$instanceId .= \'_\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$instanceId .= $entity[$idField];");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence prepareDisplayPermissionCheck(final Controller it) {
    CharSequence _switchResult = null;
    boolean _matched = false;
    if (!_matched) {
      if (it instanceof AjaxController) {
        final AjaxController _ajaxController = (AjaxController)it;
        _matched=true;
        CharSequence _prepareDisplayPermissionCheckWithoutCurrentUrlArgs = this.prepareDisplayPermissionCheckWithoutCurrentUrlArgs();
        _switchResult = _prepareDisplayPermissionCheckWithoutCurrentUrlArgs;
      }
    }
    if (!_matched) {
      StringConcatenation _builder = new StringConcatenation();
      _builder.append("// build ModUrl instance for display hooks; also create identifier for permission check");
      _builder.newLine();
      _builder.append("$currentUrlArgs = array(\'ot\' => $objectType);");
      _builder.newLine();
      _builder.append("$instanceId = \'\';");
      _builder.newLine();
      _builder.append("foreach ($idFields as $idField) {");
      _builder.newLine();
      _builder.append("    ");
      _builder.append("$currentUrlArgs[$idField] = $entity[$idField];");
      _builder.newLine();
      _builder.append("    ");
      _builder.append("if (!empty($instanceId)) {");
      _builder.newLine();
      _builder.append("        ");
      _builder.append("$instanceId .= \'_\';");
      _builder.newLine();
      _builder.append("    ");
      _builder.append("}");
      _builder.newLine();
      _builder.append("    ");
      _builder.append("$instanceId .= $entity[$idField];");
      _builder.newLine();
      _builder.append("}");
      _builder.newLine();
      _builder.append("$currentUrlArgs[\'id\'] = $instanceId;");
      _builder.newLine();
      _builder.append("if (isset($entity[\'slug\'])) {");
      _builder.newLine();
      _builder.append("    ");
      _builder.append("$currentUrlArgs[\'slug\'] = $entity[\'slug\'];");
      _builder.newLine();
      _builder.append("}");
      _builder.newLine();
      _builder.append("$currentUrlObject = new ");
      {
        boolean _targets = this._utils.targets(this.app, "1.3.5");
        if (_targets) {
          _builder.append("Zikula_");
        }
      }
      _builder.append("ModUrl($this->name, \'");
      String _formattedName = this._controllerExtensions.formattedName(it);
      _builder.append(_formattedName, "");
      _builder.append("\', \'display\', ZLanguage::getLanguageCode(), $currentUrlArgs);");
      _builder.newLineIfNotEmpty();
      _switchResult = _builder;
    }
    return _switchResult;
  }
  
  private CharSequence processDisplayOutput(final Controller it) {
    CharSequence _switchResult = null;
    boolean _matched = false;
    if (!_matched) {
      if (it instanceof AjaxController) {
        final AjaxController _ajaxController = (AjaxController)it;
        _matched=true;
        StringConcatenation _builder = new StringConcatenation();
        _builder.append("return new ");
        {
          boolean _targets = this._utils.targets(this.app, "1.3.5");
          if (_targets) {
            _builder.append("Zikula_Response_Ajax");
          } else {
            _builder.append("AjaxResponse");
          }
        }
        _builder.append("(array(\'result\' => true, $objectType => $entity->toArray()));");
        _builder.newLineIfNotEmpty();
        _switchResult = _builder;
      }
    }
    if (!_matched) {
      StringConcatenation _builder = new StringConcatenation();
      _builder.append("$viewHelper = new ");
      {
        boolean _targets = this._utils.targets(this.app, "1.3.5");
        if (_targets) {
          String _appName = this._utils.appName(this.app);
          _builder.append(_appName, "");
          _builder.append("_Util_View");
        } else {
          _builder.append("ViewUtil");
        }
      }
      _builder.append("($this->serviceManager");
      {
        boolean _targets_1 = this._utils.targets(this.app, "1.3.5");
        boolean _not = (!_targets_1);
        if (_not) {
          _builder.append(", ModUtil::getModule($this->name)");
        }
      }
      _builder.append(");");
      _builder.newLineIfNotEmpty();
      _builder.append("$templateFile = $viewHelper->getViewTemplate($this->view, \'");
      String _formattedName = this._controllerExtensions.formattedName(it);
      _builder.append(_formattedName, "");
      _builder.append("\', $objectType, \'display\', $args);");
      _builder.newLineIfNotEmpty();
      _builder.newLine();
      _builder.append("// set cache id");
      _builder.newLine();
      _builder.append("$component = $this->name . \':\' . ucwords($objectType) . \':\';");
      _builder.newLine();
      _builder.append("$instance = $instanceId . \'::\';");
      _builder.newLine();
      _builder.append("$accessLevel = ACCESS_READ;");
      _builder.newLine();
      _builder.append("if (SecurityUtil::checkPermission($component, $instance, ACCESS_COMMENT)) {");
      _builder.newLine();
      _builder.append("    ");
      _builder.append("$accessLevel = ACCESS_COMMENT;");
      _builder.newLine();
      _builder.append("}");
      _builder.newLine();
      _builder.append("if (SecurityUtil::checkPermission($component, $instance, ACCESS_EDIT)) {");
      _builder.newLine();
      _builder.append("    ");
      _builder.append("$accessLevel = ACCESS_EDIT;");
      _builder.newLine();
      _builder.append("}");
      _builder.newLine();
      _builder.append("$this->view->setCacheId($objectType . \'|\' . $instanceId . \'|a\' . $accessLevel);");
      _builder.newLine();
      _builder.newLine();
      _builder.append("// assign output data to view object.");
      _builder.newLine();
      _builder.append("$this->view->assign($objectType, $entity)");
      _builder.newLine();
      _builder.append("           ");
      _builder.append("->assign(\'currentUrlObject\', $currentUrlObject)");
      _builder.newLine();
      _builder.append("           ");
      _builder.append("->assign($repository->getAdditionalTemplateParameters(\'controllerAction\', $utilArgs));");
      _builder.newLine();
      _builder.newLine();
      _builder.append("// fetch and return the appropriate template");
      _builder.newLine();
      _builder.append("return $viewHelper->processTemplate($this->view, \'");
      String _formattedName_1 = this._controllerExtensions.formattedName(it);
      _builder.append(_formattedName_1, "");
      _builder.append("\', $objectType, \'display\', $args, $templateFile);");
      _builder.newLineIfNotEmpty();
      _switchResult = _builder;
    }
    return _switchResult;
  }
  
  private CharSequence _actionImplBody(final EditAction it) {
    CharSequence _switchResult = null;
    Controller _controller = it.getController();
    final Controller getController = _controller;
    boolean _matched = false;
    if (!_matched) {
      if (getController instanceof AjaxController) {
        final AjaxController _ajaxController = (AjaxController)getController;
        _matched=true;
        StringConcatenation _builder = new StringConcatenation();
        _builder.append("$this->checkAjaxToken();");
        _builder.newLine();
        _builder.append("$idFields = ModUtil::apiFunc($this->name, \'selection\', \'getIdFields\', array(\'ot\' => $objectType));");
        _builder.newLine();
        _builder.newLine();
        _builder.append("$data = (isset($args[\'data\']) && !empty($args[\'data\'])) ? $args[\'data\'] : $this->request->query->filter(\'data\', null);");
        _builder.newLine();
        _builder.append("$data = json_decode($data, true);");
        _builder.newLine();
        _builder.newLine();
        _builder.append("$idValues = array();");
        _builder.newLine();
        _builder.append("foreach ($idFields as $idField) {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$idValues[$idField] = isset($data[$idField]) ? $data[$idField] : \'\';");
        _builder.newLine();
        _builder.append("}");
        _builder.newLine();
        _builder.append("$hasIdentifier = $controllerHelper->isValidIdentifier($idValues);");
        _builder.newLine();
        _builder.append("$this->throwNotFoundUnless($hasIdentifier, $this->__(\'Error! Invalid identifier received.\'));");
        _builder.newLine();
        _builder.newLine();
        _builder.append("$entity = ModUtil::apiFunc($this->name, \'selection\', \'getEntity\', array(\'ot\' => $objectType, \'id\' => $idValues));");
        _builder.newLine();
        _builder.append("$this->throwNotFoundUnless($entity != null, $this->__(\'No such item.\'));");
        _builder.newLine();
        _builder.append("unset($idValues);");
        _builder.newLine();
        _builder.newLine();
        CharSequence _prepareDisplayPermissionCheckWithoutCurrentUrlArgs = this.prepareDisplayPermissionCheckWithoutCurrentUrlArgs();
        _builder.append(_prepareDisplayPermissionCheckWithoutCurrentUrlArgs, "");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
        CharSequence _permissionCheck = this.permissionCheck(it, "\' . ucwords($objectType) . \'", "$instanceId . ");
        _builder.append(_permissionCheck, "");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
        _builder.append("// TODO: call pre edit validate hooks");
        _builder.newLine();
        _builder.append("foreach ($idFields as $idField) {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("unset($data[$idField]);");
        _builder.newLine();
        _builder.append("}");
        _builder.newLine();
        _builder.append("foreach ($data as $key => $value) {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$entity[$key] = $value;");
        _builder.newLine();
        _builder.append("}");
        _builder.newLine();
        _builder.append("$this->entityManager->persist($entity);");
        _builder.newLine();
        _builder.append("$this->entityManager->flush();");
        _builder.newLine();
        _builder.append("// TODO: call post edit process hooks");
        _builder.newLine();
        _builder.newLine();
        _builder.append("return new ");
        {
          boolean _targets = this._utils.targets(this.app, "1.3.5");
          if (_targets) {
            _builder.append("Zikula_Response_Ajax");
          } else {
            _builder.append("AjaxResponse");
          }
        }
        _builder.append("(array(\'result\' => true, $objectType => $entity->toArray()));");
        _builder.newLineIfNotEmpty();
        _switchResult = _builder;
      }
    }
    if (!_matched) {
      StringConcatenation _builder = new StringConcatenation();
      _builder.newLine();
      _builder.append("// create new Form reference");
      _builder.newLine();
      _builder.append("$view = FormUtil::newForm($this->name, $this);");
      _builder.newLine();
      _builder.newLine();
      _builder.append("// build form handler class name");
      _builder.newLine();
      {
        boolean _targets = this._utils.targets(this.app, "1.3.5");
        if (_targets) {
          _builder.append("$handlerClass = $this->name . \'_Form_Handler_");
          Controller _controller_1 = it.getController();
          String _formattedName = this._controllerExtensions.formattedName(_controller_1);
          String _firstUpper = StringExtensions.toFirstUpper(_formattedName);
          _builder.append(_firstUpper, "");
          _builder.append("_\' . ucfirst($objectType) . \'_Edit\';");
          _builder.newLineIfNotEmpty();
        } else {
          _builder.append("$handlerClass = \'\\\\");
          String _vendor = this.app.getVendor();
          String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(_vendor);
          _builder.append(_formatForCodeCapital, "");
          _builder.append("\\\\");
          String _name = this.app.getName();
          String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(_name);
          _builder.append(_formatForCodeCapital_1, "");
          _builder.append("Module\\\\Form\\\\Handler\\\\");
          Controller _controller_2 = it.getController();
          String _formattedName_1 = this._controllerExtensions.formattedName(_controller_2);
          String _firstUpper_1 = StringExtensions.toFirstUpper(_formattedName_1);
          _builder.append(_firstUpper_1, "");
          _builder.append("\\\\\' . ucfirst($objectType) . \'\\\\EditHandler\';");
          _builder.newLineIfNotEmpty();
        }
      }
      _builder.newLine();
      _builder.append("// determine the output template");
      _builder.newLine();
      _builder.append("$viewHelper = new ");
      {
        boolean _targets_1 = this._utils.targets(this.app, "1.3.5");
        if (_targets_1) {
          String _appName = this._utils.appName(this.app);
          _builder.append(_appName, "");
          _builder.append("_Util_View");
        } else {
          _builder.append("ViewUtil");
        }
      }
      _builder.append("($this->serviceManager");
      {
        boolean _targets_2 = this._utils.targets(this.app, "1.3.5");
        boolean _not = (!_targets_2);
        if (_not) {
          _builder.append(", ModUtil::getModule($this->name)");
        }
      }
      _builder.append(");");
      _builder.newLineIfNotEmpty();
      _builder.append("$template = $viewHelper->getViewTemplate($this->view, \'");
      Controller _controller_3 = it.getController();
      String _formattedName_2 = this._controllerExtensions.formattedName(_controller_3);
      _builder.append(_formattedName_2, "");
      _builder.append("\', $objectType, \'edit\', $args);");
      _builder.newLineIfNotEmpty();
      _builder.newLine();
      _builder.append("// execute form using supplied template and page event handler");
      _builder.newLine();
      _builder.append("return $view->execute($template, new $handlerClass());");
      _builder.newLine();
      _switchResult = _builder;
    }
    return _switchResult;
  }
  
  private CharSequence _actionImplBody(final DeleteAction it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("$idFields = ModUtil::apiFunc($this->name, \'selection\', \'getIdFields\', array(\'ot\' => $objectType));");
    _builder.newLine();
    _builder.newLine();
    _builder.append("// retrieve identifier of the object we wish to delete");
    _builder.newLine();
    _builder.append("$idValues = $controllerHelper->retrieveIdentifier($this->request, $args, $objectType, $idFields);");
    _builder.newLine();
    _builder.append("$hasIdentifier = $controllerHelper->isValidIdentifier($idValues);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("$this->throwNotFoundUnless($hasIdentifier, $this->__(\'Error! Invalid identifier received.\'));");
    _builder.newLine();
    _builder.newLine();
    _builder.append("$entity = ModUtil::apiFunc($this->name, \'selection\', \'getEntity\', array(\'ot\' => $objectType, \'id\' => $idValues));");
    _builder.newLine();
    _builder.append("$this->throwNotFoundUnless($entity != null, $this->__(\'No such item.\'));");
    _builder.newLine();
    _builder.newLine();
    _builder.append("$entity->initWorkflow();");
    _builder.newLine();
    _builder.newLine();
    _builder.append("$workflowHelper = new ");
    {
      boolean _targets = this._utils.targets(this.app, "1.3.5");
      if (_targets) {
        String _appName = this._utils.appName(this.app);
        _builder.append(_appName, "");
        _builder.append("_Util_Workflow");
      } else {
        _builder.append("WorkflowUtil");
      }
    }
    _builder.append("($this->serviceManager");
    {
      boolean _targets_1 = this._utils.targets(this.app, "1.3.5");
      boolean _not = (!_targets_1);
      if (_not) {
        _builder.append(", ModUtil::getModule($this->name)");
      }
    }
    _builder.append(");");
    _builder.newLineIfNotEmpty();
    _builder.append("$deleteActionId = \'delete\';");
    _builder.newLine();
    _builder.append("$deleteAllowed = false;");
    _builder.newLine();
    _builder.append("$actions = $workflowHelper->getActionsForObject($entity);");
    _builder.newLine();
    _builder.append("if ($actions === false || !is_array($actions)) {");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return LogUtil::registerError($this->__(\'Error! Could not determine workflow actions.\'));");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.append("foreach ($actions as $actionId => $action) {");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($actionId != $deleteActionId) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("continue;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$deleteAllowed = true;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("break;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.append("if (!$deleteAllowed) {");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return LogUtil::registerError($this->__(\'Error! It is not allowed to delete this entity.\'));");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("$confirmation = (bool) (isset($args[\'confirmation\']) && !empty($args[\'confirmation\'])) ? $args[\'confirmation\'] : $this->request->request->filter(\'confirmation\', false, FILTER_VALIDATE_BOOLEAN);");
    _builder.newLine();
    _builder.append("if ($confirmation) {");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$this->checkCsrfToken();");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$hookAreaPrefix = $entity->getHookAreaPrefix();");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$hookType = \'validate_delete\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// Let any hooks perform additional validation actions");
    _builder.newLine();
    {
      boolean _targets_2 = this._utils.targets(this.app, "1.3.5");
      if (_targets_2) {
        _builder.append("    ");
        _builder.append("$hook = new Zikula_ValidationHook($hookAreaPrefix . \'.\' . $hookType, new Zikula_Hook_ValidationProviders());");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$validators = $this->notifyHooks($hook)->getValidators();");
        _builder.newLine();
      } else {
        _builder.append("    ");
        _builder.append("$hook = new ValidationHook(new ValidationProviders());");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$validators = $this->dispatchHooks($hookAreaPrefix . \'.\' . $hookType, $hook)->getValidators();");
        _builder.newLine();
      }
    }
    _builder.append("    ");
    _builder.append("if (!$validators->hasErrors()) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// execute the workflow action");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$success = $workflowHelper->executeAction($entity, $deleteActionId);");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if ($success) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$this->registerStatus($this->__(\'Done! Item deleted.\'));");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// Let any hooks know that we have created, updated or deleted an item");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$hookType = \'process_delete\';");
    _builder.newLine();
    {
      boolean _targets_3 = this._utils.targets(this.app, "1.3.5");
      if (_targets_3) {
        _builder.append("        ");
        _builder.append("$hook = new Zikula_ProcessHook($hookAreaPrefix . \'.\' . $hookType, $entity->createCompositeIdentifier());");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("$this->notifyHooks($hook);");
        _builder.newLine();
      } else {
        _builder.append("        ");
        _builder.append("$hook = new ProcessHook($entity->createCompositeIdentifier());");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("$this->dispatchHooks($hookAreaPrefix . \'.\' . $hookType, $hook);");
        _builder.newLine();
      }
    }
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// An item was deleted, so we clear all cached pages this item.");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$cacheArgs = array(\'ot\' => $objectType, \'item\' => $entity);");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("ModUtil::apiFunc($this->name, \'cache\', \'clearItemCache\', $cacheArgs);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// redirect to the ");
    {
      Controller _controller = it.getController();
      boolean _hasActions = this._controllerExtensions.hasActions(_controller, "view");
      if (_hasActions) {
        _builder.append("list of the current object type");
      } else {
        {
          boolean _targets_4 = this._utils.targets(this.app, "1.3.5");
          if (_targets_4) {
            _builder.append("main");
          } else {
            _builder.append("index");
          }
        }
        _builder.append(" page");
      }
    }
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("$this->redirect(ModUtil::url($this->name, \'");
    Controller _controller_1 = it.getController();
    String _formattedName = this._controllerExtensions.formattedName(_controller_1);
    _builder.append(_formattedName, "        ");
    _builder.append("\', ");
    {
      Controller _controller_2 = it.getController();
      boolean _hasActions_1 = this._controllerExtensions.hasActions(_controller_2, "view");
      if (_hasActions_1) {
        _builder.append("\'view\',");
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        _builder.append("                                                                            ");
        _builder.append("array(\'ot\' => $objectType)");
      } else {
        _builder.append("\'");
        {
          boolean _targets_5 = this._utils.targets(this.app, "1.3.5");
          if (_targets_5) {
            _builder.append("main");
          } else {
            _builder.append("index");
          }
        }
        _builder.append("\'");
      }
    }
    _builder.append("));");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    {
      boolean _targets_6 = this._utils.targets(this.app, "1.3.5");
      if (_targets_6) {
        _builder.append("$entityClass = $this->name . \'_Entity_\' . ucwords($objectType);");
        _builder.newLine();
      } else {
        _builder.append("$entityClass = \'\\\\");
        String _vendor = this.app.getVendor();
        String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(_vendor);
        _builder.append(_formatForCodeCapital, "");
        _builder.append("\\\\");
        String _name = this.app.getName();
        String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(_name);
        _builder.append(_formatForCodeCapital_1, "");
        _builder.append("Module\\\\Entity\\\\\' . ucwords($objectType) . \'Entity\';");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("$repository = $this->entityManager->getRepository($entityClass);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("// set caching id");
    _builder.newLine();
    _builder.append("$this->view->setCaching(Zikula_View::CACHE_DISABLED);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("// assign the object we loaded above");
    _builder.newLine();
    _builder.append("$this->view->assign($objectType, $entity)");
    _builder.newLine();
    _builder.append("           ");
    _builder.append("->assign($repository->getAdditionalTemplateParameters(\'controllerAction\', $utilArgs));");
    _builder.newLine();
    _builder.newLine();
    _builder.append("// fetch and return the appropriate template");
    _builder.newLine();
    _builder.append("$viewHelper = new ");
    {
      boolean _targets_7 = this._utils.targets(this.app, "1.3.5");
      if (_targets_7) {
        String _appName_1 = this._utils.appName(this.app);
        _builder.append(_appName_1, "");
        _builder.append("_Util_View");
      } else {
        _builder.append("ViewUtil");
      }
    }
    _builder.append("($this->serviceManager");
    {
      boolean _targets_8 = this._utils.targets(this.app, "1.3.5");
      boolean _not_1 = (!_targets_8);
      if (_not_1) {
        _builder.append(", ModUtil::getModule($this->name)");
      }
    }
    _builder.append(");");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("return $viewHelper->processTemplate($this->view, \'");
    Controller _controller_3 = it.getController();
    String _formattedName_1 = this._controllerExtensions.formattedName(_controller_3);
    _builder.append(_formattedName_1, "");
    _builder.append("\', $objectType, \'delete\', $args);");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence _actionImplBody(final CustomAction it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _and = false;
      Controller _controller = it.getController();
      boolean _tempIsAdminController = this.tempIsAdminController(_controller);
      if (!_tempIsAdminController) {
        _and = false;
      } else {
        boolean _or = false;
        boolean _or_1 = false;
        String _name = it.getName();
        boolean _equals = Objects.equal(_name, "config");
        if (_equals) {
          _or_1 = true;
        } else {
          String _name_1 = it.getName();
          boolean _equals_1 = Objects.equal(_name_1, "modifyconfig");
          _or_1 = (_equals || _equals_1);
        }
        if (_or_1) {
          _or = true;
        } else {
          String _name_2 = it.getName();
          boolean _equals_2 = Objects.equal(_name_2, "preferences");
          _or = (_or_1 || _equals_2);
        }
        _and = (_tempIsAdminController && _or);
      }
      if (_and) {
        FormHandler _formHandler = new FormHandler();
        String _appName = this._utils.appName(this.app);
        Controller _controller_1 = it.getController();
        CharSequence _formCreate = _formHandler.formCreate(it, _appName, _controller_1, "modify");
        _builder.append(_formCreate, "");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("/** TODO: custom logic */");
        _builder.newLine();
      }
    }
    _builder.newLine();
    {
      Controller _controller_2 = it.getController();
      boolean _isAjaxController = this._controllerExtensions.isAjaxController(_controller_2);
      if (_isAjaxController) {
        _builder.append("return new ");
        {
          boolean _targets = this._utils.targets(this.app, "1.3.5");
          if (_targets) {
            _builder.append("Zikula_Response_Ajax");
          } else {
            _builder.append("AjaxResponse");
          }
        }
        _builder.append("(array(\'result\' => true));");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("// return template");
        _builder.newLine();
        {
          boolean _targets_1 = this._utils.targets(this.app, "1.3.5");
          if (_targets_1) {
            _builder.append("return $this->view->fetch(\'");
            Controller _controller_3 = it.getController();
            String _formattedName = this._controllerExtensions.formattedName(_controller_3);
            _builder.append(_formattedName, "");
            _builder.append("/");
            String _name_3 = it.getName();
            String _formatForCode = this._formattingExtensions.formatForCode(_name_3);
            String _firstLower = StringExtensions.toFirstLower(_formatForCode);
            _builder.append(_firstLower, "");
            _builder.append(".tpl\');");
            _builder.newLineIfNotEmpty();
          } else {
            _builder.append("return $this->response($this->view->fetch(\'");
            Controller _controller_4 = it.getController();
            String _formattedName_1 = this._controllerExtensions.formattedName(_controller_4);
            String _firstUpper = StringExtensions.toFirstUpper(_formattedName_1);
            _builder.append(_firstUpper, "");
            _builder.append("/");
            String _name_4 = it.getName();
            String _formatForCode_1 = this._formattingExtensions.formatForCode(_name_4);
            String _firstLower_1 = StringExtensions.toFirstLower(_formatForCode_1);
            _builder.append(_firstLower_1, "");
            _builder.append(".tpl\'));");
            _builder.newLineIfNotEmpty();
          }
        }
      }
    }
    return _builder;
  }
  
  private boolean tempIsAdminController(final Controller it) {
    boolean _switchResult = false;
    boolean _matched = false;
    if (!_matched) {
      if (it instanceof AdminController) {
        final AdminController _adminController = (AdminController)it;
        _matched=true;
        _switchResult = true;
      }
    }
    if (!_matched) {
      _switchResult = false;
    }
    return _switchResult;
  }
  
  public CharSequence generate(final Action it) {
    if (it instanceof MainAction) {
      return _generate((MainAction)it);
    } else if (it != null) {
      return _generate(it);
    } else {
      throw new IllegalArgumentException("Unhandled parameter types: " +
        Arrays.<Object>asList(it).toString());
    }
  }
  
  private CharSequence actionImplBody(final Action it) {
    if (it instanceof CustomAction) {
      return _actionImplBody((CustomAction)it);
    } else if (it instanceof DeleteAction) {
      return _actionImplBody((DeleteAction)it);
    } else if (it instanceof DisplayAction) {
      return _actionImplBody((DisplayAction)it);
    } else if (it instanceof EditAction) {
      return _actionImplBody((EditAction)it);
    } else if (it instanceof MainAction) {
      return _actionImplBody((MainAction)it);
    } else if (it instanceof ViewAction) {
      return _actionImplBody((ViewAction)it);
    } else if (it != null) {
      return _actionImplBody(it);
    } else {
      throw new IllegalArgumentException("Unhandled parameter types: " +
        Arrays.<Object>asList(it).toString());
    }
  }
}
