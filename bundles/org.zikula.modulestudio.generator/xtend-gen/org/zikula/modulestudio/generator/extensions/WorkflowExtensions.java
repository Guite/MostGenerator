package org.zikula.modulestudio.generator.extensions;

import com.google.common.base.Objects;
import com.google.common.collect.Iterables;
import de.guite.modulestudio.metamodel.Application;
import de.guite.modulestudio.metamodel.Entity;
import de.guite.modulestudio.metamodel.EntityWorkflowType;
import de.guite.modulestudio.metamodel.ListField;
import de.guite.modulestudio.metamodel.ListFieldItem;
import java.util.ArrayList;
import org.eclipse.emf.common.util.EList;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.IterableExtensions;

@SuppressWarnings("all")
public class WorkflowExtensions {
  /**
   * Determines whether any entity in the given application uses a certain workflow type.
   */
  public boolean hasWorkflow(final Application it, final EntityWorkflowType wfType) {
    boolean _isEmpty = IterableExtensions.isEmpty(this.getEntitiesForWorkflow(it, wfType));
    return (!_isEmpty);
  }
  
  /**
   * Returns all entities using the given workflow type.
   */
  public Iterable<Entity> getEntitiesForWorkflow(final Application it, final EntityWorkflowType wfType) {
    final Function1<Entity, Boolean> _function = (Entity it_1) -> {
      EntityWorkflowType _workflow = it_1.getWorkflow();
      return Boolean.valueOf(Objects.equal(_workflow, wfType));
    };
    return IterableExtensions.<Entity>filter(Iterables.<Entity>filter(it.getEntities(), Entity.class), _function);
  }
  
  /**
   * Checks whether any entity has another workflow than none.
   */
  public boolean needsApproval(final Application it) {
    return (this.hasWorkflow(it, EntityWorkflowType.STANDARD) || this.hasWorkflow(it, EntityWorkflowType.ENTERPRISE));
  }
  
  /**
   * Returns all states using by ANY entity using the given workflow type.
   */
  public ArrayList<ListFieldItem> getRequiredStateList(final Application it, final EntityWorkflowType wfType) {
    ArrayList<ListFieldItem> _xblockexpression = null;
    {
      ArrayList<ListFieldItem> states = new ArrayList<ListFieldItem>();
      ArrayList<String> stateIds = new ArrayList<String>();
      Iterable<Entity> _entitiesForWorkflow = this.getEntitiesForWorkflow(it, wfType);
      for (final Entity entity : _entitiesForWorkflow) {
        EList<ListFieldItem> _items = this.getWorkflowStateField(entity).getItems();
        for (final ListFieldItem item : _items) {
          boolean _contains = stateIds.contains(item.getValue());
          boolean _not = (!_contains);
          if (_not) {
            states.add(item);
            stateIds.add(item.getValue());
          }
        }
      }
      _xblockexpression = states;
    }
    return _xblockexpression;
  }
  
  /**
   * Returns all states using by ANY entity using any workflow type.
   */
  public ArrayList<ListFieldItem> getRequiredStateList(final Application it) {
    ArrayList<ListFieldItem> _xblockexpression = null;
    {
      ArrayList<ListFieldItem> states = new ArrayList<ListFieldItem>();
      ArrayList<String> stateIds = new ArrayList<String>();
      Iterable<Entity> _filter = Iterables.<Entity>filter(it.getEntities(), Entity.class);
      for (final Entity entity : _filter) {
        EList<ListFieldItem> _items = this.getWorkflowStateField(entity).getItems();
        for (final ListFieldItem item : _items) {
          boolean _contains = stateIds.contains(item.getValue());
          boolean _not = (!_contains);
          if (_not) {
            states.add(item);
            stateIds.add(item.getValue());
          }
        }
      }
      _xblockexpression = states;
    }
    return _xblockexpression;
  }
  
  /**
   * Determines whether any entity in the given application using a certain workflow can have the given state.
   */
  public boolean hasWorkflowState(final Application it, final EntityWorkflowType wfType, final String state) {
    return (this.hasWorkflow(it, wfType) && (!IterableExtensions.isEmpty(IterableExtensions.<Entity>filter(this.getEntitiesForWorkflow(it, wfType), ((Function1<Entity, Boolean>) (Entity it_1) -> {
      return Boolean.valueOf(this.hasWorkflowStateEntity(it_1, state));
    })))));
  }
  
  /**
   * Determines whether any entity in the given application can have the given state.
   */
  public boolean hasWorkflowState(final Application it, final String state) {
    final Function1<Entity, Boolean> _function = (Entity it_1) -> {
      return Boolean.valueOf(this.hasWorkflowStateEntity(it_1, state));
    };
    boolean _isEmpty = IterableExtensions.isEmpty(IterableExtensions.<Entity>filter(Iterables.<Entity>filter(it.getEntities(), Entity.class), _function));
    return (!_isEmpty);
  }
  
  /**
   * Prints an output string corresponding to the given workflow type.
   */
  public String textualName(final EntityWorkflowType wfType) {
    String _switchResult = null;
    if (wfType != null) {
      switch (wfType) {
        case NONE:
          _switchResult = "none";
          break;
        case STANDARD:
          _switchResult = "standard";
          break;
        case ENTERPRISE:
          _switchResult = "enterprise";
          break;
        default:
          _switchResult = "";
          break;
      }
    } else {
      _switchResult = "";
    }
    return _switchResult;
  }
  
  /**
   * Prints an output string regarding the approvals needed by a certain workflow type.
   */
  public String approvalType(final EntityWorkflowType wfType) {
    String _switchResult = null;
    if (wfType != null) {
      switch (wfType) {
        case NONE:
          _switchResult = "no";
          break;
        case STANDARD:
          _switchResult = "single";
          break;
        case ENTERPRISE:
          _switchResult = "double";
          break;
        default:
          _switchResult = "";
          break;
      }
    } else {
      _switchResult = "";
    }
    return _switchResult;
  }
  
  /**
   * Returns the list field storing the possible workflow states for the given entity.
   */
  public ListField getWorkflowStateField(final Entity it) {
    final Function1<ListField, Boolean> _function = (ListField it_1) -> {
      String _name = it_1.getName();
      return Boolean.valueOf(Objects.equal(_name, "workflowState"));
    };
    return IterableExtensions.<ListField>head(IterableExtensions.<ListField>filter(Iterables.<ListField>filter(it.getFields(), ListField.class), _function));
  }
  
  /**
   * Determines whether the given entity has the given workflow state or not.
   */
  public boolean hasWorkflowStateEntity(final Entity it, final String state) {
    boolean _isEmpty = IterableExtensions.isEmpty(this.getWorkflowStateItems(it, state));
    return (!_isEmpty);
  }
  
  /**
   * Retrieves a certain workflow state.
   */
  public ListFieldItem getWorkflowStateItem(final Entity it, final String state) {
    return IterableExtensions.<ListFieldItem>head(this.getWorkflowStateItems(it, state));
  }
  
  /**
   * Determines a list of desired workflow states.
   */
  private Iterable<ListFieldItem> getWorkflowStateItems(final Entity it, final String state) {
    final Function1<ListFieldItem, Boolean> _function = (ListFieldItem it_1) -> {
      String _value = it_1.getValue();
      String _lowerCase = state.toLowerCase();
      return Boolean.valueOf(Objects.equal(_value, _lowerCase));
    };
    return IterableExtensions.<ListFieldItem>filter(this.getWorkflowStateField(it).getItems(), _function);
  }
  
  /**
   * Returns the description for a given workflow action.
   */
  public String getWorkflowActionDescription(final EntityWorkflowType wfType, final String actionTitle) {
    if (actionTitle != null) {
      switch (actionTitle) {
        case "Defer":
          return "Defer content for later submission.";
        case "Submit":
          String _xifexpression = null;
          boolean _equals = Objects.equal(wfType, EntityWorkflowType.NONE);
          if (_equals) {
            _xifexpression = "Submit content.";
          } else {
            _xifexpression = "Submit content for acceptance by a moderator.";
          }
          return _xifexpression;
        case "Update":
          return "Update content.";
        case "Reject":
          return "Reject content and require improvements.";
        case "Accept":
          return "Accept content for editors approval.";
        case "Approve":
          return "Update content and approve for immediate publishing.";
        case "Submit and Accept":
          return "Submit content and accept immediately.";
        case "Submit and Approve":
          return "Submit content and approve immediately.";
        case "Demote":
          return "Disapprove content.";
        case "Unpublish":
          return "Hide content temporarily.";
        case "Publish":
          return "Make content available again.";
        case "Archive":
          return "Move content into the archive.";
        case "Trash":
          return "Move content into the recycle bin.";
        case "Recover":
          return "Recover content from the recycle bin.";
        case "Delete":
          return "Delete content permanently.";
      }
    }
    return "";
  }
  
  /**
   * Determines whether workflow state field should be visible for the given entity or not.
   */
  public boolean hasVisibleWorkflow(final Entity it) {
    return ((((!Objects.equal(it.getWorkflow(), EntityWorkflowType.NONE)) || it.isOwnerPermission()) || it.isHasTray()) || it.isHasArchive());
  }
}
