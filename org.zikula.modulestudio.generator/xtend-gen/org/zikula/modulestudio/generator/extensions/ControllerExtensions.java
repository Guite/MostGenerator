package org.zikula.modulestudio.generator.extensions;

import com.google.common.base.Objects;
import com.google.common.collect.Iterables;
import com.google.inject.Inject;
import de.guite.modulestudio.metamodel.modulestudio.Action;
import de.guite.modulestudio.metamodel.modulestudio.AdminController;
import de.guite.modulestudio.metamodel.modulestudio.AjaxController;
import de.guite.modulestudio.metamodel.modulestudio.Application;
import de.guite.modulestudio.metamodel.modulestudio.Controller;
import de.guite.modulestudio.metamodel.modulestudio.Controllers;
import de.guite.modulestudio.metamodel.modulestudio.CustomAction;
import de.guite.modulestudio.metamodel.modulestudio.DeleteAction;
import de.guite.modulestudio.metamodel.modulestudio.DisplayAction;
import de.guite.modulestudio.metamodel.modulestudio.EditAction;
import de.guite.modulestudio.metamodel.modulestudio.Entity;
import de.guite.modulestudio.metamodel.modulestudio.JoinRelationship;
import de.guite.modulestudio.metamodel.modulestudio.MainAction;
import de.guite.modulestudio.metamodel.modulestudio.ManyToManyRelationship;
import de.guite.modulestudio.metamodel.modulestudio.Models;
import de.guite.modulestudio.metamodel.modulestudio.RelationEditType;
import de.guite.modulestudio.metamodel.modulestudio.UserController;
import de.guite.modulestudio.metamodel.modulestudio.ViewAction;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import org.eclipse.emf.common.util.EList;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.eclipse.xtext.xbase.lib.ListExtensions;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;

/**
 * This class contains controller related extension methods.
 */
@SuppressWarnings("all")
public class ControllerExtensions {
  @Inject
  @Extension
  private FormattingExtensions _formattingExtensions = new Function0<FormattingExtensions>() {
    public FormattingExtensions apply() {
      FormattingExtensions _formattingExtensions = new FormattingExtensions();
      return _formattingExtensions;
    }
  }.apply();
  
  /**
   * Makes a controller name lowercase.
   */
  public String formattedName(final Controller it) {
    String _name = it.getName();
    String _formatForDB = this._formattingExtensions.formatForDB(_name);
    return _formatForDB;
  }
  
  /**
   * Returns a list of all user controllers in the given application.
   */
  public Iterable<UserController> getAllUserControllers(final Application it) {
    EList<Controller> _allControllers = this.getAllControllers(it);
    Iterable<UserController> _filter = Iterables.<UserController>filter(_allControllers, UserController.class);
    return _filter;
  }
  
  /**
   * Checks whether the application has an user controller or not.
   */
  public boolean hasUserController(final Application it) {
    Iterable<UserController> _allUserControllers = this.getAllUserControllers(it);
    boolean _isEmpty = IterableExtensions.isEmpty(_allUserControllers);
    boolean _not = (!_isEmpty);
    return _not;
  }
  
  /**
   * Returns the default user controller.
   */
  public UserController getMainUserController(final Application it) {
    Iterable<UserController> _allUserControllers = this.getAllUserControllers(it);
    UserController _head = IterableExtensions.<UserController>head(_allUserControllers);
    return _head;
  }
  
  /**
   * Returns a list of all admin controllers in the given application.
   */
  public Iterable<AdminController> getAllAdminControllers(final Application it) {
    EList<Controller> _allControllers = this.getAllControllers(it);
    Iterable<AdminController> _filter = Iterables.<AdminController>filter(_allControllers, AdminController.class);
    return _filter;
  }
  
  /**
   * Returns a list of all user controllers in the given container.
   */
  public Iterable<UserController> getUserControllers(final Controllers it) {
    EList<Controller> _controllers = it.getControllers();
    Iterable<UserController> _filter = Iterables.<UserController>filter(_controllers, UserController.class);
    return _filter;
  }
  
  /**
   * Returns a list of all admin controllers in the given container.
   */
  public Iterable<AdminController> getAdminControllers(final Controllers it) {
    EList<Controller> _controllers = it.getControllers();
    Iterable<AdminController> _filter = Iterables.<AdminController>filter(_controllers, AdminController.class);
    return _filter;
  }
  
  /**
   * Checks whether a controller owns actions of a given type.
   */
  public boolean hasActions(final Controller it, final String type) {
    boolean _switchResult = false;
    boolean _matched = false;
    if (!_matched) {
      if (Objects.equal(type,"index")) {
        _matched=true;
        EList<Action> _actions = it.getActions();
        Iterable<MainAction> _filter = Iterables.<MainAction>filter(_actions, MainAction.class);
        boolean _isEmpty = IterableExtensions.isEmpty(_filter);
        boolean _not = (!_isEmpty);
        _switchResult = _not;
      }
    }
    if (!_matched) {
      if (Objects.equal(type,"view")) {
        _matched=true;
        EList<Action> _actions_1 = it.getActions();
        Iterable<ViewAction> _filter_1 = Iterables.<ViewAction>filter(_actions_1, ViewAction.class);
        boolean _isEmpty_1 = IterableExtensions.isEmpty(_filter_1);
        boolean _not_1 = (!_isEmpty_1);
        _switchResult = _not_1;
      }
    }
    if (!_matched) {
      if (Objects.equal(type,"display")) {
        _matched=true;
        EList<Action> _actions_2 = it.getActions();
        Iterable<DisplayAction> _filter_2 = Iterables.<DisplayAction>filter(_actions_2, DisplayAction.class);
        boolean _isEmpty_2 = IterableExtensions.isEmpty(_filter_2);
        boolean _not_2 = (!_isEmpty_2);
        _switchResult = _not_2;
      }
    }
    if (!_matched) {
      if (Objects.equal(type,"edit")) {
        _matched=true;
        EList<Action> _actions_3 = it.getActions();
        Iterable<EditAction> _filter_3 = Iterables.<EditAction>filter(_actions_3, EditAction.class);
        boolean _isEmpty_3 = IterableExtensions.isEmpty(_filter_3);
        boolean _not_3 = (!_isEmpty_3);
        _switchResult = _not_3;
      }
    }
    if (!_matched) {
      if (Objects.equal(type,"delete")) {
        _matched=true;
        EList<Action> _actions_4 = it.getActions();
        Iterable<DeleteAction> _filter_4 = Iterables.<DeleteAction>filter(_actions_4, DeleteAction.class);
        boolean _isEmpty_4 = IterableExtensions.isEmpty(_filter_4);
        boolean _not_4 = (!_isEmpty_4);
        _switchResult = _not_4;
      }
    }
    if (!_matched) {
      if (Objects.equal(type,"custom")) {
        _matched=true;
        EList<Action> _actions_5 = it.getActions();
        Iterable<CustomAction> _filter_5 = Iterables.<CustomAction>filter(_actions_5, CustomAction.class);
        boolean _isEmpty_5 = IterableExtensions.isEmpty(_filter_5);
        boolean _not_5 = (!_isEmpty_5);
        _switchResult = _not_5;
      }
    }
    if (!_matched) {
      _switchResult = false;
    }
    return _switchResult;
  }
  
  /**
   * Checks whether the application has at least one edit action or not.
   */
  public boolean hasEditActions(final Application it) {
    Iterable<EditAction> _editActions = this.getEditActions(it);
    boolean _isEmpty = IterableExtensions.isEmpty(_editActions);
    boolean _not = (!_isEmpty);
    return _not;
  }
  
  /**
   * Returns a list of all edit actions in the given application.
   */
  public Iterable<EditAction> getEditActions(final Application it) {
    EList<Controller> _allControllers = this.getAllControllers(it);
    final Function1<Controller,EList<Action>> _function = new Function1<Controller,EList<Action>>() {
        public EList<Action> apply(final Controller e) {
          EList<Action> _actions = e.getActions();
          return _actions;
        }
      };
    List<EList<Action>> _map = ListExtensions.<Controller, EList<Action>>map(_allControllers, _function);
    Iterable<Action> _flatten = Iterables.<Action>concat(_map);
    Iterable<EditAction> _filter = Iterables.<EditAction>filter(_flatten, EditAction.class);
    return _filter;
  }
  
  /**
   * Returns a list of all controllers in the given application.
   */
  public EList<Controller> getAllControllers(final Application it) {
    EList<Controller> _xblockexpression = null;
    {
      EList<Controllers> _controllers = it.getControllers();
      Controllers _head = IterableExtensions.<Controllers>head(_controllers);
      EList<Controller> allControllers = _head.getControllers();
      EList<Controllers> _controllers_1 = it.getControllers();
      Iterable<Controllers> _tail = IterableExtensions.<Controllers>tail(_controllers_1);
      for (final Controllers controllerContainer : _tail) {
        EList<Controller> _controllers_2 = controllerContainer.getControllers();
        allControllers.addAll(_controllers_2);
      }
      _xblockexpression = (allControllers);
    }
    return _xblockexpression;
  }
  
  /**
   * Get a list of only admin and user controllers.
   */
  public Iterable<Controller> getAdminAndUserControllers(final Application it) {
    Iterable<Controller> _xblockexpression = null;
    {
      EList<Controller> allControllers = this.getAllControllers(it);
      Iterable<AdminController> _filter = Iterables.<AdminController>filter(allControllers, AdminController.class);
      Iterable<UserController> _filter_1 = Iterables.<UserController>filter(allControllers, UserController.class);
      Iterable<Controller> _plus = Iterables.<Controller>concat(_filter, _filter_1);
      _xblockexpression = (_plus);
    }
    return _xblockexpression;
  }
  
  /**
   * Checks whether a given controller is instance of AjaxController.
   */
  public boolean isAjaxController(final Controller it) {
    boolean _switchResult = false;
    boolean _matched = false;
    if (!_matched) {
      if (it instanceof AjaxController) {
        final AjaxController _ajaxController = (AjaxController)it;
        _matched=true;
        _switchResult = true;
      }
    }
    if (!_matched) {
      _switchResult = false;
    }
    return _switchResult;
  }
  
  /**
   * Checks whether a given controller is instance of AdminController.
   */
  public boolean isAdminController(final Controller it) {
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
  
  /**
   * Checks whether a given controller is instance of UserController.
   */
  public boolean isUserController(final Controller it) {
    boolean _switchResult = false;
    boolean _matched = false;
    if (!_matched) {
      if (it instanceof UserController) {
        final UserController _userController = (UserController)it;
        _matched=true;
        _switchResult = true;
      }
    }
    if (!_matched) {
      _switchResult = false;
    }
    return _switchResult;
  }
  
  /**
   * Returns the controller instance to be used for linking to a display
   * page of a given entity.
   * The main purpose of this function is to consider joins from or to entities
   * of other models/modules properly.
   */
  public Controller getLinkController(final Application it, final Controller currentController, final Entity entity) {
    Controller _xblockexpression = null;
    {
      Models _container = entity.getContainer();
      final Application entityApp = _container.getApplication();
      Controller linkController = null;
      boolean _and = false;
      boolean _equals = Objects.equal(it, entityApp);
      if (!_equals) {
        _and = false;
      } else {
        boolean _hasActions = this.hasActions(currentController, "display");
        _and = (_equals && _hasActions);
      }
      if (_and) {
        linkController = currentController;
      } else {
        boolean _and_1 = false;
        boolean _hasUserController = this.hasUserController(entityApp);
        if (!_hasUserController) {
          _and_1 = false;
        } else {
          UserController _mainUserController = this.getMainUserController(entityApp);
          boolean _hasActions_1 = this.hasActions(_mainUserController, "display");
          _and_1 = (_hasUserController && _hasActions_1);
        }
        if (_and_1) {
          UserController _mainUserController_1 = this.getMainUserController(entityApp);
          linkController = _mainUserController_1;
        }
      }
      _xblockexpression = (linkController);
    }
    return _xblockexpression;
  }
  
  /**
   * Determines the controller in which the config action is living.
   */
  public String configController(final Application it) {
    String _xifexpression = null;
    Iterable<AdminController> _allAdminControllers = this.getAllAdminControllers(it);
    boolean _isEmpty = IterableExtensions.isEmpty(_allAdminControllers);
    boolean _not = (!_isEmpty);
    if (_not) {
      Iterable<AdminController> _allAdminControllers_1 = this.getAllAdminControllers(it);
      AdminController _head = IterableExtensions.<AdminController>head(_allAdminControllers_1);
      String _formattedName = this.formattedName(_head);
      _xifexpression = _formattedName;
    } else {
      String _xifexpression_1 = null;
      Iterable<UserController> _allUserControllers = this.getAllUserControllers(it);
      boolean _isEmpty_1 = IterableExtensions.isEmpty(_allUserControllers);
      boolean _not_1 = (!_isEmpty_1);
      if (_not_1) {
        UserController _mainUserController = this.getMainUserController(it);
        String _formattedName_1 = this.formattedName(_mainUserController);
        _xifexpression_1 = _formattedName_1;
      } else {
        EList<Controller> _allControllers = this.getAllControllers(it);
        Controller _head_1 = IterableExtensions.<Controller>head(_allControllers);
        String _formattedName_2 = this.formattedName(_head_1);
        _xifexpression_1 = _formattedName_2;
      }
      _xifexpression = _xifexpression_1;
    }
    return _xifexpression;
  }
  
  /**
   * Checks for whether the given controller is responsible for the config action.
   */
  public boolean isConfigController(final Controller it) {
    Controllers _container = it.getContainer();
    Application _application = _container.getApplication();
    String _configController = this.configController(_application);
    String _formattedName = this.formattedName(it);
    boolean _equals = Objects.equal(_configController, _formattedName);
    return _equals;
  }
  
  /**
   * Retrieves an integer value defining which relation edit type will be implemented.
   * This mapping is done to have a more appropriate logic inside the generator.
   * Possible values are:
   *    0    Nothing is being done
   *    1    Select related object
   *    2    Create and edit related object
   *    3    Combination of 1 and 2
   */
  protected int _getEditStageCode(final JoinRelationship it, final Boolean incoming) {
    int _switchResult = (int) 0;
    RelationEditType _editType = it.getEditType();
    final RelationEditType getEditType = _editType;
    boolean _matched = false;
    if (!_matched) {
      if (Objects.equal(getEditType,RelationEditType.ACTIVE_NONE_PASSIVE_CHOOSE)) {
        _matched=true;
        int _xifexpression = (int) 0;
        boolean _not = (!(incoming).booleanValue());
        if (_not) {
          _xifexpression = 0;
        } else {
          _xifexpression = 1;
        }
        _switchResult = _xifexpression;
      }
    }
    if (!_matched) {
      if (Objects.equal(getEditType,RelationEditType.ACTIVE_NONE_PASSIVE_EDIT)) {
        _matched=true;
        int _xifexpression_1 = (int) 0;
        boolean _not_1 = (!(incoming).booleanValue());
        if (_not_1) {
          _xifexpression_1 = 0;
        } else {
          _xifexpression_1 = 3;
        }
        _switchResult = _xifexpression_1;
      }
    }
    if (!_matched) {
      if (Objects.equal(getEditType,RelationEditType.ACTIVE_CHOOSE_PASSIVE_NONE)) {
        _matched=true;
        int _xifexpression_2 = (int) 0;
        boolean _not_2 = (!(incoming).booleanValue());
        if (_not_2) {
          _xifexpression_2 = 2;
        } else {
          _xifexpression_2 = 3;
        }
        _switchResult = _xifexpression_2;
      }
    }
    if (!_matched) {
      if (Objects.equal(getEditType,RelationEditType.ACTIVE_EDIT_PASSIVE_CHOOSE)) {
        _matched=true;
        int _xifexpression_3 = (int) 0;
        boolean _not_3 = (!(incoming).booleanValue());
        if (_not_3) {
          _xifexpression_3 = 2;
        } else {
          _xifexpression_3 = 1;
        }
        _switchResult = _xifexpression_3;
      }
    }
    if (!_matched) {
      if (Objects.equal(getEditType,RelationEditType.ACTIVE_EDIT_PASSIVE_EDIT)) {
        _matched=true;
        int _xifexpression_4 = (int) 0;
        boolean _not_4 = (!(incoming).booleanValue());
        if (_not_4) {
          _xifexpression_4 = 2;
        } else {
          _xifexpression_4 = 3;
        }
        _switchResult = _xifexpression_4;
      }
    }
    if (!_matched) {
      if (Objects.equal(getEditType,RelationEditType.ACTIVE_EDIT_PASSIVE_NONE)) {
        _matched=true;
        int _xifexpression_5 = (int) 0;
        boolean _not_5 = (!(incoming).booleanValue());
        if (_not_5) {
          _xifexpression_5 = 2;
        } else {
          _xifexpression_5 = 3;
        }
        _switchResult = _xifexpression_5;
      }
    }
    if (!_matched) {
      int _xifexpression_6 = (int) 0;
      boolean _not_6 = (!(incoming).booleanValue());
      if (_not_6) {
        _xifexpression_6 = 2;
      } else {
        _xifexpression_6 = 3;
      }
      _switchResult = _xifexpression_6;
    }
    return _switchResult;
  }
  
  /**
   * Retrieves an integer value defining which relation edit type will be implemented.
   * This mapping is done to have a more appropriate logic inside the generator.
   * Possible values are:
   *    0    Nothing is being done
   *    1    Select related object
   *    2    Create and edit related object
   *    3    Combination of 1 and 2
   */
  protected int _getEditStageCode(final ManyToManyRelationship it, final Boolean incoming) {
    int _switchResult = (int) 0;
    RelationEditType _editType = it.getEditType();
    final RelationEditType getEditType = _editType;
    boolean _matched = false;
    if (!_matched) {
      if (Objects.equal(getEditType,RelationEditType.ACTIVE_NONE_PASSIVE_CHOOSE)) {
        _matched=true;
        int _xifexpression = (int) 0;
        boolean _not = (!(incoming).booleanValue());
        if (_not) {
          _xifexpression = 0;
        } else {
          _xifexpression = 1;
        }
        _switchResult = _xifexpression;
      }
    }
    if (!_matched) {
      if (Objects.equal(getEditType,RelationEditType.ACTIVE_NONE_PASSIVE_EDIT)) {
        _matched=true;
        int _xifexpression_1 = (int) 0;
        boolean _not_1 = (!(incoming).booleanValue());
        if (_not_1) {
          _xifexpression_1 = 0;
        } else {
          _xifexpression_1 = 3;
        }
        _switchResult = _xifexpression_1;
      }
    }
    if (!_matched) {
      if (Objects.equal(getEditType,RelationEditType.ACTIVE_CHOOSE_PASSIVE_NONE)) {
        _matched=true;
        int _xifexpression_2 = (int) 0;
        boolean _not_2 = (!(incoming).booleanValue());
        if (_not_2) {
          _xifexpression_2 = 1;
        } else {
          _xifexpression_2 = 0;
        }
        _switchResult = _xifexpression_2;
      }
    }
    if (!_matched) {
      if (Objects.equal(getEditType,RelationEditType.ACTIVE_EDIT_PASSIVE_CHOOSE)) {
        _matched=true;
        int _xifexpression_3 = (int) 0;
        boolean _not_3 = (!(incoming).booleanValue());
        if (_not_3) {
          _xifexpression_3 = 3;
        } else {
          _xifexpression_3 = 1;
        }
        _switchResult = _xifexpression_3;
      }
    }
    if (!_matched) {
      if (Objects.equal(getEditType,RelationEditType.ACTIVE_EDIT_PASSIVE_EDIT)) {
        _matched=true;
        int _xifexpression_4 = (int) 0;
        boolean _not_4 = (!(incoming).booleanValue());
        if (_not_4) {
          _xifexpression_4 = 3;
        } else {
          _xifexpression_4 = 3;
        }
        _switchResult = _xifexpression_4;
      }
    }
    if (!_matched) {
      if (Objects.equal(getEditType,RelationEditType.ACTIVE_EDIT_PASSIVE_NONE)) {
        _matched=true;
        int _xifexpression_5 = (int) 0;
        boolean _not_5 = (!(incoming).booleanValue());
        if (_not_5) {
          _xifexpression_5 = 3;
        } else {
          _xifexpression_5 = 0;
        }
        _switchResult = _xifexpression_5;
      }
    }
    if (!_matched) {
      int _xifexpression_6 = (int) 0;
      boolean _not_6 = (!(incoming).booleanValue());
      if (_not_6) {
        _xifexpression_6 = 3;
      } else {
        _xifexpression_6 = 3;
      }
      _switchResult = _xifexpression_6;
    }
    return _switchResult;
  }
  
  /**
   * Returns a list of numbers based on a given count variable.
   * This is a helper method allowing a while loop inside the template syntax.
   * Used for creating a certain amount of example data.
   */
  public ArrayList<Integer> getListForCounter(final Integer amount) {
    ArrayList<Integer> _xblockexpression = null;
    {
      ArrayList<Integer> _arrayList = new ArrayList<Integer>();
      final ArrayList<Integer> theList = _arrayList;
      int i = 1;
      boolean _lessEqualsThan = (i <= (amount).intValue());
      boolean _while = _lessEqualsThan;
      while (_while) {
        {
          theList.add(Integer.valueOf(i));
          int _plus = (i + 1);
          i = _plus;
        }
        boolean _lessEqualsThan_1 = (i <= (amount).intValue());
        _while = _lessEqualsThan_1;
      }
      _xblockexpression = (theList);
    }
    return _xblockexpression;
  }
  
  public int getEditStageCode(final JoinRelationship it, final Boolean incoming) {
    if (it instanceof ManyToManyRelationship) {
      return _getEditStageCode((ManyToManyRelationship)it, incoming);
    } else if (it != null) {
      return _getEditStageCode(it, incoming);
    } else {
      throw new IllegalArgumentException("Unhandled parameter types: " +
        Arrays.<Object>asList(it, incoming).toString());
    }
  }
}
