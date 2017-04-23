package org.zikula.modulestudio.generator.extensions;

import com.google.common.collect.Iterables;
import de.guite.modulestudio.metamodel.Action;
import de.guite.modulestudio.metamodel.Application;
import de.guite.modulestudio.metamodel.CustomAction;
import de.guite.modulestudio.metamodel.DeleteAction;
import de.guite.modulestudio.metamodel.DisplayAction;
import de.guite.modulestudio.metamodel.EditAction;
import de.guite.modulestudio.metamodel.Entity;
import de.guite.modulestudio.metamodel.IntVar;
import de.guite.modulestudio.metamodel.JoinRelationship;
import de.guite.modulestudio.metamodel.MainAction;
import de.guite.modulestudio.metamodel.ManyToManyRelationship;
import de.guite.modulestudio.metamodel.ManyToOneRelationship;
import de.guite.modulestudio.metamodel.OneToManyRelationship;
import de.guite.modulestudio.metamodel.OneToOneRelationship;
import de.guite.modulestudio.metamodel.RelationEditType;
import de.guite.modulestudio.metamodel.ViewAction;
import java.util.Arrays;
import org.eclipse.emf.common.util.EList;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

/**
 * This class contains controller related extension methods.
 */
@SuppressWarnings("all")
public class ControllerExtensions {
  @Extension
  private FormattingExtensions _formattingExtensions = new FormattingExtensions();
  
  @Extension
  private ModelExtensions _modelExtensions = new ModelExtensions();
  
  @Extension
  private Utils _utils = new Utils();
  
  /**
   * Returns name of container (entity).
   */
  public String controllerName(final Action it) {
    String _xblockexpression = null;
    {
      Entity _entity = it.getEntity();
      boolean _tripleNotEquals = (null != _entity);
      if (_tripleNotEquals) {
        this._formattingExtensions.formatForCode(it.getEntity().getName());
      }
      _xblockexpression = this._formattingExtensions.formatForDB(it.getName());
    }
    return _xblockexpression;
  }
  
  /**
   * Checks whether an entity owns an index action.
   */
  public boolean hasIndexAction(final Entity it) {
    boolean _isEmpty = IterableExtensions.isEmpty(Iterables.<MainAction>filter(it.getActions(), MainAction.class));
    return (!_isEmpty);
  }
  
  /**
   * Checks whether an entity owns a view action.
   */
  public boolean hasViewAction(final Entity it) {
    boolean _isEmpty = IterableExtensions.isEmpty(Iterables.<ViewAction>filter(it.getActions(), ViewAction.class));
    return (!_isEmpty);
  }
  
  /**
   * Checks whether an entity owns a display action.
   */
  public boolean hasDisplayAction(final Entity it) {
    boolean _isEmpty = IterableExtensions.isEmpty(Iterables.<DisplayAction>filter(it.getActions(), DisplayAction.class));
    return (!_isEmpty);
  }
  
  /**
   * Checks whether an entity owns an edit action.
   */
  public boolean hasEditAction(final Entity it) {
    boolean _isEmpty = IterableExtensions.isEmpty(Iterables.<EditAction>filter(it.getActions(), EditAction.class));
    return (!_isEmpty);
  }
  
  /**
   * Checks whether an entity owns a delete action.
   */
  public boolean hasDeleteAction(final Entity it) {
    boolean _isEmpty = IterableExtensions.isEmpty(Iterables.<DeleteAction>filter(it.getActions(), DeleteAction.class));
    return (!_isEmpty);
  }
  
  /**
   * Checks whether an entity owns a custom action.
   */
  public boolean hasCustomAction(final Entity it) {
    boolean _isEmpty = IterableExtensions.isEmpty(Iterables.<CustomAction>filter(it.getActions(), CustomAction.class));
    return (!_isEmpty);
  }
  
  /**
   * Determines the default action used for linking to a certain entity.
   */
  public CharSequence defaultAction(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _hasDisplayAction = this.hasDisplayAction(it);
      if (_hasDisplayAction) {
        _builder.append("display");
      } else {
        boolean _hasViewAction = this.hasViewAction(it);
        if (_hasViewAction) {
          _builder.append("view");
        } else {
          boolean _hasIndexAction = this.hasIndexAction(it);
          if (_hasIndexAction) {
            _builder.append("index");
          } else {
            String _formatForCode = this._formattingExtensions.formatForCode(IterableExtensions.<Action>head(it.getActions()).getName());
            _builder.append(_formatForCode);
          }
        }
      }
    }
    return _builder;
  }
  
  public String getPrimaryAction(final Entity it) {
    boolean _hasIndexAction = this.hasIndexAction(it);
    if (_hasIndexAction) {
      return "index";
    }
    boolean _hasViewAction = this.hasViewAction(it);
    if (_hasViewAction) {
      return "view";
    }
    return this._formattingExtensions.formatForDB(IterableExtensions.<Action>head(it.getActions()).getName());
  }
  
  /**
   * Checks whether the application has at least one view action or not.
   */
  public boolean hasViewActions(final Application it) {
    boolean _isEmpty = IterableExtensions.isEmpty(this.getViewActions(it));
    return (!_isEmpty);
  }
  
  /**
   * Returns a list of all view actions in the given application.
   */
  public Iterable<ViewAction> getViewActions(final Application it) {
    final Function1<Entity, EList<Action>> _function = (Entity it_1) -> {
      return it_1.getActions();
    };
    return Iterables.<ViewAction>filter(Iterables.<Action>concat(IterableExtensions.<Entity, EList<Action>>map(this._modelExtensions.getAllEntities(it), _function)), ViewAction.class);
  }
  
  /**
   * Checks whether the application has at least one display action or not.
   */
  public boolean hasDisplayActions(final Application it) {
    boolean _isEmpty = IterableExtensions.isEmpty(this.getDisplayActions(it));
    return (!_isEmpty);
  }
  
  /**
   * Returns a list of all display actions in the given application.
   */
  public Iterable<DisplayAction> getDisplayActions(final Application it) {
    final Function1<Entity, EList<Action>> _function = (Entity it_1) -> {
      return it_1.getActions();
    };
    return Iterables.<DisplayAction>filter(Iterables.<Action>concat(IterableExtensions.<Entity, EList<Action>>map(this._modelExtensions.getAllEntities(it), _function)), DisplayAction.class);
  }
  
  /**
   * Checks whether the application has at least one edit action or not.
   */
  public boolean hasEditActions(final Application it) {
    boolean _isEmpty = IterableExtensions.isEmpty(this.getEditActions(it));
    return (!_isEmpty);
  }
  
  /**
   * Returns a list of all edit actions in the given application.
   */
  public Iterable<EditAction> getEditActions(final Application it) {
    final Function1<Entity, EList<Action>> _function = (Entity it_1) -> {
      return it_1.getActions();
    };
    return Iterables.<EditAction>filter(Iterables.<Action>concat(IterableExtensions.<Entity, EList<Action>>map(this._modelExtensions.getAllEntities(it), _function)), EditAction.class);
  }
  
  /**
   * Checks whether the application has at least one delete action or not.
   */
  public boolean hasDeleteActions(final Application it) {
    boolean _isEmpty = IterableExtensions.isEmpty(this.getDeleteActions(it));
    return (!_isEmpty);
  }
  
  /**
   * Returns a list of all delete actions in the given application.
   */
  public Iterable<DeleteAction> getDeleteActions(final Application it) {
    final Function1<Entity, EList<Action>> _function = (Entity it_1) -> {
      return it_1.getActions();
    };
    return Iterables.<DeleteAction>filter(Iterables.<Action>concat(IterableExtensions.<Entity, EList<Action>>map(this._modelExtensions.getAllEntities(it), _function)), DeleteAction.class);
  }
  
  /**
   * Returns whether variables contain any user group selectors or not.
   */
  public boolean hasUserGroupSelectors(final Application it) {
    boolean _isEmpty = IterableExtensions.isEmpty(this.getUserGroupSelectors(it));
    return (!_isEmpty);
  }
  
  /**
   * Returns all variables acting as user group selectors.
   */
  public Iterable<IntVar> getUserGroupSelectors(final Application it) {
    final Function1<IntVar, Boolean> _function = (IntVar it_1) -> {
      return Boolean.valueOf(this.isUserGroupSelector(it_1));
    };
    return IterableExtensions.<IntVar>filter(Iterables.<IntVar>filter(this._utils.getAllVariables(it), IntVar.class), _function);
  }
  
  /**
   * Determines whether the given integer variable instance represents a user group
   * selector for moderation purposes.
   */
  public boolean isUserGroupSelector(final IntVar it) {
    boolean _xblockexpression = false;
    {
      if ((it.getName().contains("moderationGroupFor") || it.getName().contains("superModerationGroupFor"))) {
        return true;
      }
      _xblockexpression = false;
    }
    return _xblockexpression;
  }
  
  /**
   * Returns a list of all custom actions contained by a given entity.
   */
  public Iterable<CustomAction> getCustomActions(final Entity it) {
    return Iterables.<CustomAction>filter(it.getActions(), CustomAction.class);
  }
  
  public RelationEditType getEditingType(final JoinRelationship it) {
    RelationEditType _xblockexpression = null;
    {
      boolean _matched = false;
      if (it instanceof OneToOneRelationship) {
        _matched=true;
        return ((OneToOneRelationship)it).getEditType();
      }
      if (!_matched) {
        if (it instanceof OneToManyRelationship) {
          _matched=true;
          return ((OneToManyRelationship)it).getEditType();
        }
      }
      if (!_matched) {
        if (it instanceof ManyToOneRelationship) {
          _matched=true;
          return ((ManyToOneRelationship)it).getEditType();
        }
      }
      if (!_matched) {
        if (it instanceof ManyToManyRelationship) {
          _matched=true;
          return ((ManyToManyRelationship)it).getEditType();
        }
      }
      _xblockexpression = RelationEditType.ACTIVE_NONE_PASSIVE_CHOOSE;
    }
    return _xblockexpression;
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
    RelationEditType _editingType = this.getEditingType(it);
    if (_editingType != null) {
      switch (_editingType) {
        case ACTIVE_NONE_PASSIVE_CHOOSE:
          int _xifexpression = (int) 0;
          if ((!(incoming).booleanValue())) {
            _xifexpression = 0;
          } else {
            _xifexpression = 1;
          }
          _switchResult = _xifexpression;
          break;
        case ACTIVE_NONE_PASSIVE_EDIT:
          int _xifexpression_1 = (int) 0;
          if ((!(incoming).booleanValue())) {
            _xifexpression_1 = 0;
          } else {
            _xifexpression_1 = 3;
          }
          _switchResult = _xifexpression_1;
          break;
        case ACTIVE_CHOOSE_PASSIVE_NONE:
          int _xifexpression_2 = (int) 0;
          if ((!(incoming).booleanValue())) {
            _xifexpression_2 = 2;
          } else {
            _xifexpression_2 = 3;
          }
          _switchResult = _xifexpression_2;
          break;
        case ACTIVE_EDIT_PASSIVE_CHOOSE:
          int _xifexpression_3 = (int) 0;
          if ((!(incoming).booleanValue())) {
            _xifexpression_3 = 2;
          } else {
            _xifexpression_3 = 1;
          }
          _switchResult = _xifexpression_3;
          break;
        case ACTIVE_EDIT_PASSIVE_EDIT:
          int _xifexpression_4 = (int) 0;
          if ((!(incoming).booleanValue())) {
            _xifexpression_4 = 2;
          } else {
            _xifexpression_4 = 3;
          }
          _switchResult = _xifexpression_4;
          break;
        case ACTIVE_EDIT_PASSIVE_NONE:
          int _xifexpression_5 = (int) 0;
          if ((!(incoming).booleanValue())) {
            _xifexpression_5 = 2;
          } else {
            _xifexpression_5 = 3;
          }
          _switchResult = _xifexpression_5;
          break;
        default:
          int _xifexpression_6 = (int) 0;
          if ((!(incoming).booleanValue())) {
            _xifexpression_6 = 2;
          } else {
            _xifexpression_6 = 3;
          }
          _switchResult = _xifexpression_6;
          break;
      }
    } else {
      int _xifexpression_6 = (int) 0;
      if ((!(incoming).booleanValue())) {
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
    if (_editType != null) {
      switch (_editType) {
        case ACTIVE_NONE_PASSIVE_CHOOSE:
          int _xifexpression = (int) 0;
          if ((!(incoming).booleanValue())) {
            _xifexpression = 0;
          } else {
            _xifexpression = 1;
          }
          _switchResult = _xifexpression;
          break;
        case ACTIVE_NONE_PASSIVE_EDIT:
          int _xifexpression_1 = (int) 0;
          if ((!(incoming).booleanValue())) {
            _xifexpression_1 = 0;
          } else {
            _xifexpression_1 = 3;
          }
          _switchResult = _xifexpression_1;
          break;
        case ACTIVE_CHOOSE_PASSIVE_NONE:
          int _xifexpression_2 = (int) 0;
          if ((!(incoming).booleanValue())) {
            _xifexpression_2 = 1;
          } else {
            _xifexpression_2 = 0;
          }
          _switchResult = _xifexpression_2;
          break;
        case ACTIVE_EDIT_PASSIVE_CHOOSE:
          int _xifexpression_3 = (int) 0;
          if ((!(incoming).booleanValue())) {
            _xifexpression_3 = 3;
          } else {
            _xifexpression_3 = 1;
          }
          _switchResult = _xifexpression_3;
          break;
        case ACTIVE_EDIT_PASSIVE_EDIT:
          int _xifexpression_4 = (int) 0;
          if ((!(incoming).booleanValue())) {
            _xifexpression_4 = 3;
          } else {
            _xifexpression_4 = 3;
          }
          _switchResult = _xifexpression_4;
          break;
        case ACTIVE_EDIT_PASSIVE_NONE:
          int _xifexpression_5 = (int) 0;
          if ((!(incoming).booleanValue())) {
            _xifexpression_5 = 3;
          } else {
            _xifexpression_5 = 0;
          }
          _switchResult = _xifexpression_5;
          break;
        default:
          int _xifexpression_6 = (int) 0;
          if ((!(incoming).booleanValue())) {
            _xifexpression_6 = 3;
          } else {
            _xifexpression_6 = 3;
          }
          _switchResult = _xifexpression_6;
          break;
      }
    } else {
      int _xifexpression_6 = (int) 0;
      if ((!(incoming).booleanValue())) {
        _xifexpression_6 = 3;
      } else {
        _xifexpression_6 = 3;
      }
      _switchResult = _xifexpression_6;
    }
    return _switchResult;
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
