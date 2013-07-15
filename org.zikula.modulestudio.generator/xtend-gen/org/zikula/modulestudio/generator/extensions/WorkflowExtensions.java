package org.zikula.modulestudio.generator.extensions;

import com.google.common.base.Objects;
import com.google.common.collect.Iterables;
import com.google.inject.Inject;
import de.guite.modulestudio.metamodel.modulestudio.Application;
import de.guite.modulestudio.metamodel.modulestudio.Entity;
import de.guite.modulestudio.metamodel.modulestudio.EntityField;
import de.guite.modulestudio.metamodel.modulestudio.EntityWorkflowType;
import de.guite.modulestudio.metamodel.modulestudio.ListField;
import de.guite.modulestudio.metamodel.modulestudio.ListFieldItem;
import java.util.ArrayList;
import org.eclipse.emf.common.util.EList;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.zikula.modulestudio.generator.extensions.ModelWorkflowExtensions;

@SuppressWarnings("all")
public class WorkflowExtensions {
  /**
   * Extensions related to the model layer.
   */
  @Inject
  @Extension
  private ModelWorkflowExtensions _modelWorkflowExtensions = new Function0<ModelWorkflowExtensions>() {
    public ModelWorkflowExtensions apply() {
      ModelWorkflowExtensions _modelWorkflowExtensions = new ModelWorkflowExtensions();
      return _modelWorkflowExtensions;
    }
  }.apply();
  
  /**
   * Determines whether any entity in the given application uses a certain workflow type.
   */
  public boolean hasWorkflow(final Application it, final EntityWorkflowType wfType) {
    Iterable<Entity> _entitiesForWorkflow = this.getEntitiesForWorkflow(it, wfType);
    boolean _isEmpty = IterableExtensions.isEmpty(_entitiesForWorkflow);
    boolean _not = (!_isEmpty);
    return _not;
  }
  
  /**
   * Returns all entities using the given workflow type.
   */
  public Iterable<Entity> getEntitiesForWorkflow(final Application it, final EntityWorkflowType wfType) {
    EList<Entity> _allEntities = this._modelWorkflowExtensions.getAllEntities(it);
    final Function1<Entity,Boolean> _function = new Function1<Entity,Boolean>() {
        public Boolean apply(final Entity e) {
          EntityWorkflowType _workflow = e.getWorkflow();
          boolean _equals = Objects.equal(_workflow, wfType);
          return Boolean.valueOf(_equals);
        }
      };
    Iterable<Entity> _filter = IterableExtensions.<Entity>filter(_allEntities, _function);
    return _filter;
  }
  
  /**
   * Checks whether any entity has another workflow than none.
   */
  public boolean needsApproval(final Application it) {
    boolean _or = false;
    boolean _hasWorkflow = this.hasWorkflow(it, EntityWorkflowType.STANDARD);
    if (_hasWorkflow) {
      _or = true;
    } else {
      boolean _hasWorkflow_1 = this.hasWorkflow(it, EntityWorkflowType.ENTERPRISE);
      _or = (_hasWorkflow || _hasWorkflow_1);
    }
    return _or;
  }
  
  /**
   * Returns all states using by ANY entity using the given workflow type.
   */
  public ArrayList<ListFieldItem> getRequiredStateList(final Application it, final EntityWorkflowType wfType) {
    ArrayList<ListFieldItem> _xblockexpression = null;
    {
      ArrayList<ListFieldItem> _arrayList = new ArrayList<ListFieldItem>();
      ArrayList<ListFieldItem> states = _arrayList;
      ArrayList<String> _arrayList_1 = new ArrayList<String>();
      ArrayList<String> stateIds = _arrayList_1;
      Iterable<Entity> _entitiesForWorkflow = this.getEntitiesForWorkflow(it, wfType);
      for (final Entity entity : _entitiesForWorkflow) {
        ListField _workflowStateField = this.getWorkflowStateField(entity);
        EList<ListFieldItem> _items = _workflowStateField.getItems();
        for (final ListFieldItem item : _items) {
          String _value = item.getValue();
          boolean _contains = stateIds.contains(_value);
          boolean _not = (!_contains);
          if (_not) {
            states.add(item);
            String _value_1 = item.getValue();
            stateIds.add(_value_1);
          }
        }
      }
      _xblockexpression = (states);
    }
    return _xblockexpression;
  }
  
  /**
   * Returns all states using by ANY entity using any workflow type.
   */
  public ArrayList<ListFieldItem> getRequiredStateList(final Application it) {
    ArrayList<ListFieldItem> _xblockexpression = null;
    {
      ArrayList<ListFieldItem> _arrayList = new ArrayList<ListFieldItem>();
      ArrayList<ListFieldItem> states = _arrayList;
      ArrayList<String> _arrayList_1 = new ArrayList<String>();
      ArrayList<String> stateIds = _arrayList_1;
      EList<Entity> _allEntities = this._modelWorkflowExtensions.getAllEntities(it);
      for (final Entity entity : _allEntities) {
        ListField _workflowStateField = this.getWorkflowStateField(entity);
        EList<ListFieldItem> _items = _workflowStateField.getItems();
        for (final ListFieldItem item : _items) {
          String _value = item.getValue();
          boolean _contains = stateIds.contains(_value);
          boolean _not = (!_contains);
          if (_not) {
            states.add(item);
            String _value_1 = item.getValue();
            stateIds.add(_value_1);
          }
        }
      }
      _xblockexpression = (states);
    }
    return _xblockexpression;
  }
  
  /**
   * Determines whether any entity in the given application using a certain workflow can have the given state.
   */
  public boolean hasWorkflowState(final Application it, final EntityWorkflowType wfType, final String state) {
    boolean _and = false;
    boolean _hasWorkflow = this.hasWorkflow(it, wfType);
    if (!_hasWorkflow) {
      _and = false;
    } else {
      Iterable<Entity> _entitiesForWorkflow = this.getEntitiesForWorkflow(it, wfType);
      final Function1<Entity,Boolean> _function = new Function1<Entity,Boolean>() {
          public Boolean apply(final Entity e) {
            boolean _hasWorkflowStateEntity = WorkflowExtensions.this.hasWorkflowStateEntity(e, state);
            return Boolean.valueOf(_hasWorkflowStateEntity);
          }
        };
      Iterable<Entity> _filter = IterableExtensions.<Entity>filter(_entitiesForWorkflow, _function);
      boolean _isEmpty = IterableExtensions.isEmpty(_filter);
      boolean _not = (!_isEmpty);
      _and = (_hasWorkflow && _not);
    }
    return _and;
  }
  
  /**
   * Determines whether any entity in the given application can have the given state.
   */
  public boolean hasWorkflowState(final Application it, final String state) {
    EList<Entity> _allEntities = this._modelWorkflowExtensions.getAllEntities(it);
    final Function1<Entity,Boolean> _function = new Function1<Entity,Boolean>() {
        public Boolean apply(final Entity e) {
          boolean _hasWorkflowStateEntity = WorkflowExtensions.this.hasWorkflowStateEntity(e, state);
          return Boolean.valueOf(_hasWorkflowStateEntity);
        }
      };
    Iterable<Entity> _filter = IterableExtensions.<Entity>filter(_allEntities, _function);
    boolean _isEmpty = IterableExtensions.isEmpty(_filter);
    boolean _not = (!_isEmpty);
    return _not;
  }
  
  /**
   * Prints an output string corresponding to the given workflow type.
   */
  public String textualName(final EntityWorkflowType wfType) {
    String _switchResult = null;
    boolean _matched = false;
    if (!_matched) {
      if (Objects.equal(wfType,EntityWorkflowType.NONE)) {
        _matched=true;
        _switchResult = "none";
      }
    }
    if (!_matched) {
      if (Objects.equal(wfType,EntityWorkflowType.STANDARD)) {
        _matched=true;
        _switchResult = "standard";
      }
    }
    if (!_matched) {
      if (Objects.equal(wfType,EntityWorkflowType.ENTERPRISE)) {
        _matched=true;
        _switchResult = "enterprise";
      }
    }
    if (!_matched) {
      _switchResult = "";
    }
    return _switchResult;
  }
  
  /**
   * Prints an output string regarding the approvals needed by a certain workflow type.
   */
  public String approvalType(final EntityWorkflowType wfType) {
    String _switchResult = null;
    boolean _matched = false;
    if (!_matched) {
      if (Objects.equal(wfType,EntityWorkflowType.NONE)) {
        _matched=true;
        _switchResult = "no";
      }
    }
    if (!_matched) {
      if (Objects.equal(wfType,EntityWorkflowType.STANDARD)) {
        _matched=true;
        _switchResult = "single";
      }
    }
    if (!_matched) {
      if (Objects.equal(wfType,EntityWorkflowType.ENTERPRISE)) {
        _matched=true;
        _switchResult = "double";
      }
    }
    if (!_matched) {
      _switchResult = "";
    }
    return _switchResult;
  }
  
  /**
   * Returns the list field storing the possible workflow states for the given entity.
   */
  public ListField getWorkflowStateField(final Entity it) {
    EList<EntityField> _fields = it.getFields();
    Iterable<ListField> _filter = Iterables.<ListField>filter(_fields, ListField.class);
    final Function1<ListField,Boolean> _function = new Function1<ListField,Boolean>() {
        public Boolean apply(final ListField e) {
          String _name = e.getName();
          boolean _equals = Objects.equal(_name, "workflowState");
          return Boolean.valueOf(_equals);
        }
      };
    Iterable<ListField> _filter_1 = IterableExtensions.<ListField>filter(_filter, _function);
    ListField _head = IterableExtensions.<ListField>head(_filter_1);
    return _head;
  }
  
  /**
   * Determines whether the given entity has the given workflow state or not.
   */
  public boolean hasWorkflowStateEntity(final Entity it, final String state) {
    Iterable<ListFieldItem> _workflowStateItems = this.getWorkflowStateItems(it, state);
    boolean _isEmpty = IterableExtensions.isEmpty(_workflowStateItems);
    boolean _not = (!_isEmpty);
    return _not;
  }
  
  /**
   * Retrieves a certain workflow state.
   */
  public ListFieldItem getWorkflowStateItem(final Entity it, final String state) {
    Iterable<ListFieldItem> _workflowStateItems = this.getWorkflowStateItems(it, state);
    ListFieldItem _head = IterableExtensions.<ListFieldItem>head(_workflowStateItems);
    return _head;
  }
  
  /**
   * Determines a list of desired workflow states.
   */
  private Iterable<ListFieldItem> getWorkflowStateItems(final Entity it, final String state) {
    ListField _workflowStateField = this.getWorkflowStateField(it);
    EList<ListFieldItem> _items = _workflowStateField.getItems();
    final Function1<ListFieldItem,Boolean> _function = new Function1<ListFieldItem,Boolean>() {
        public Boolean apply(final ListFieldItem e) {
          String _value = e.getValue();
          String _lowerCase = state.toLowerCase();
          boolean _equals = Objects.equal(_value, _lowerCase);
          return Boolean.valueOf(_equals);
        }
      };
    Iterable<ListFieldItem> _filter = IterableExtensions.<ListFieldItem>filter(_items, _function);
    return _filter;
  }
  
  /**
   * Returns the description for a given workflow action.
   */
  public String getWorkflowActionDescription(final EntityWorkflowType wfType, final String actionTitle) {
    boolean _matched = false;
    if (!_matched) {
      if (Objects.equal(actionTitle,"Defer")) {
        _matched=true;
        return "Defer content for later submission.";
      }
    }
    if (!_matched) {
      if (Objects.equal(actionTitle,"Submit")) {
        _matched=true;
        String _xifexpression = null;
        boolean _equals = Objects.equal(wfType, EntityWorkflowType.NONE);
        if (_equals) {
          _xifexpression = "Submit content.";
        } else {
          _xifexpression = "Submit content for acceptance by a moderator.";
        }
        return _xifexpression;
      }
    }
    if (!_matched) {
      if (Objects.equal(actionTitle,"Update")) {
        _matched=true;
        return "Update content.";
      }
    }
    if (!_matched) {
      if (Objects.equal(actionTitle,"Reject")) {
        _matched=true;
        return "Reject content and require improvements.";
      }
    }
    if (!_matched) {
      if (Objects.equal(actionTitle,"Accept")) {
        _matched=true;
        return "Accept content for editors approval.";
      }
    }
    if (!_matched) {
      if (Objects.equal(actionTitle,"Approve")) {
        _matched=true;
        return "Update content and approve for immediate publishing.";
      }
    }
    if (!_matched) {
      if (Objects.equal(actionTitle,"Submit and Accept")) {
        _matched=true;
        return "Submit content and accept immediately.";
      }
    }
    if (!_matched) {
      if (Objects.equal(actionTitle,"Submit and Approve")) {
        _matched=true;
        return "Submit content and approve immediately.";
      }
    }
    if (!_matched) {
      if (Objects.equal(actionTitle,"Demote")) {
        _matched=true;
        return "Disapprove content.";
      }
    }
    if (!_matched) {
      if (Objects.equal(actionTitle,"Unpublish")) {
        _matched=true;
        return "Hide content temporarily.";
      }
    }
    if (!_matched) {
      if (Objects.equal(actionTitle,"Publish")) {
        _matched=true;
        return "Make content available again.";
      }
    }
    if (!_matched) {
      if (Objects.equal(actionTitle,"Archive")) {
        _matched=true;
        return "Move content into the archive.";
      }
    }
    if (!_matched) {
      if (Objects.equal(actionTitle,"Trash")) {
        _matched=true;
        return "Move content into the recycle bin.";
      }
    }
    if (!_matched) {
      if (Objects.equal(actionTitle,"Recover")) {
        _matched=true;
        return "Recover content from the recycle bin.";
      }
    }
    if (!_matched) {
      if (Objects.equal(actionTitle,"Delete")) {
        _matched=true;
        return "Delete content permanently.";
      }
    }
    return "";
  }
  
  /**
   * Determines whether workflow state field should be visible for the given entity or not.
   */
  public boolean hasVisibleWorkflow(final Entity it) {
    boolean _or = false;
    boolean _or_1 = false;
    boolean _or_2 = false;
    boolean _or_3 = false;
    EntityWorkflowType _workflow = it.getWorkflow();
    boolean _notEquals = (!Objects.equal(_workflow, EntityWorkflowType.NONE));
    if (_notEquals) {
      _or_3 = true;
    } else {
      boolean _isOwnerPermission = it.isOwnerPermission();
      _or_3 = (_notEquals || _isOwnerPermission);
    }
    if (_or_3) {
      _or_2 = true;
    } else {
      boolean _isHasTray = it.isHasTray();
      _or_2 = (_or_3 || _isHasTray);
    }
    if (_or_2) {
      _or_1 = true;
    } else {
      boolean _isHasArchive = it.isHasArchive();
      _or_1 = (_or_2 || _isHasArchive);
    }
    if (_or_1) {
      _or = true;
    } else {
      boolean _isSoftDeleteable = it.isSoftDeleteable();
      _or = (_or_1 || _isSoftDeleteable);
    }
    return _or;
  }
}
