package org.zikula.modulestudio.generator.cartridges.zclassic.controller.workflows;

import com.google.common.base.Objects;
import de.guite.modulestudio.metamodel.Application;
import de.guite.modulestudio.metamodel.Entity;
import de.guite.modulestudio.metamodel.EntityWorkflowType;
import de.guite.modulestudio.metamodel.ListFieldItem;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Set;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.CollectionLiterals;
import org.eclipse.xtext.xbase.lib.Conversions;
import org.eclipse.xtext.xbase.lib.Exceptions;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;
import org.zikula.modulestudio.generator.extensions.WorkflowExtensions;

/**
 * Workflow definitions in YAML format.
 */
@SuppressWarnings("all")
public class Definition {
  @Extension
  private FormattingExtensions _formattingExtensions = new FormattingExtensions();
  
  @Extension
  private NamingExtensions _namingExtensions = new NamingExtensions();
  
  @Extension
  private Utils _utils = new Utils();
  
  @Extension
  private WorkflowExtensions _workflowExtensions = new WorkflowExtensions();
  
  private Application app;
  
  private EntityWorkflowType wfType;
  
  private ArrayList<ListFieldItem> states;
  
  private HashMap<String, ArrayList<String>> transitionsFrom;
  
  private HashMap<String, String> transitionsTo;
  
  private IFileSystemAccess fsa;
  
  private String outputPath;
  
  /**
   * Entry point for workflow definitions.
   * This generates YML files describing the workflows used in the application.
   */
  public void generate(final Application it, final IFileSystemAccess fsa) {
    Boolean _targets = this._utils.targets(it, "1.5");
    boolean _not = (!(_targets).booleanValue());
    if (_not) {
      return;
    }
    this.app = it;
    this.fsa = fsa;
    String _resourcesPath = this._namingExtensions.getResourcesPath(it);
    String _plus = (_resourcesPath + "workflows/");
    this.outputPath = _plus;
    this.generate(EntityWorkflowType.NONE);
    this.generate(EntityWorkflowType.STANDARD);
    this.generate(EntityWorkflowType.ENTERPRISE);
  }
  
  private void generate(final EntityWorkflowType wfType) {
    boolean _hasWorkflow = this._workflowExtensions.hasWorkflow(this.app, wfType);
    boolean _not = (!_hasWorkflow);
    if (_not) {
      return;
    }
    String _textualName = this._workflowExtensions.textualName(wfType);
    String fileName = (_textualName + ".yml");
    boolean _shouldBeSkipped = this._namingExtensions.shouldBeSkipped(this.app, (this.outputPath + fileName));
    if (_shouldBeSkipped) {
      return;
    }
    this.wfType = wfType;
    this.states = this._workflowExtensions.getRequiredStateList(this.app, wfType);
    this.collectTransitions();
    boolean _shouldBeMarked = this._namingExtensions.shouldBeMarked(this.app, (this.outputPath + fileName));
    if (_shouldBeMarked) {
      String _textualName_1 = this._workflowExtensions.textualName(wfType);
      String _plus = (_textualName_1 + ".generated.yml");
      fileName = _plus;
    }
    this.fsa.generateFile((this.outputPath + fileName), this.workflowDefinition());
  }
  
  private CharSequence workflowDefinition() {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("workflow:");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("workflows:");
    _builder.newLine();
    _builder.append("        ");
    String _formatForDB = this._formattingExtensions.formatForDB(this._utils.appName(this.app));
    _builder.append(_formatForDB, "        ");
    _builder.append("_");
    String _formatForDB_1 = this._formattingExtensions.formatForDB(this._workflowExtensions.textualName(this.wfType));
    _builder.append(_formatForDB_1, "        ");
    _builder.append(":");
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    _builder.append("type: state_machine");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("marking_store:");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("type: single_state");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("arguments:");
    _builder.newLine();
    _builder.append("                    ");
    _builder.append("- workflowState");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("supports:");
    _builder.newLine();
    {
      Iterable<Entity> _entitiesForWorkflow = this._workflowExtensions.getEntitiesForWorkflow(this.app, this.wfType);
      for(final Entity entity : _entitiesForWorkflow) {
        _builder.append("                ");
        _builder.append("- ");
        String _appNamespace = this._utils.appNamespace(this.app);
        _builder.append(_appNamespace, "                ");
        _builder.append("\\Entity\\");
        String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(entity.getName());
        _builder.append(_formatForCodeCapital, "                ");
        _builder.append("Entity");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("            ");
    CharSequence _statesImpl = this.statesImpl();
    _builder.append(_statesImpl, "            ");
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    CharSequence _actionsImpl = this.actionsImpl();
    _builder.append(_actionsImpl, "            ");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence statesImpl() {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("places:");
    _builder.newLine();
    {
      for(final ListFieldItem state : this.states) {
        _builder.append("    ");
        _builder.append("- ");
        String _value = state.getValue();
        _builder.append(_value, "    ");
        _builder.newLineIfNotEmpty();
      }
    }
    return _builder;
  }
  
  private CharSequence actionsImpl() {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("transitions:");
    _builder.newLine();
    {
      Set<String> _keySet = this.transitionsFrom.keySet();
      for(final String transitionKey : _keySet) {
        _builder.append("    ");
        _builder.append(transitionKey, "    ");
        _builder.append(":");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("from: ");
        {
          int _length = ((Object[])Conversions.unwrapArray(this.transitionsFrom.get(transitionKey), Object.class)).length;
          boolean _greaterThan = (_length > 1);
          if (_greaterThan) {
            _builder.append("[");
            String _join = IterableExtensions.join(this.transitionsFrom.get(transitionKey), ", ");
            _builder.append(_join, "        ");
            _builder.append("]");
          } else {
            String _join_1 = IterableExtensions.join(this.transitionsFrom.get(transitionKey), ", ");
            _builder.append(_join_1, "        ");
          }
        }
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("to: ");
        String _get = this.transitionsTo.get(transitionKey);
        _builder.append(_get, "        ");
        _builder.newLineIfNotEmpty();
      }
    }
    return _builder;
  }
  
  private void collectTransitions() {
    HashMap<String, ArrayList<String>> _hashMap = new HashMap<String, ArrayList<String>>();
    this.transitionsFrom = _hashMap;
    HashMap<String, String> _hashMap_1 = new HashMap<String, String>();
    this.transitionsTo = _hashMap_1;
    for (final ListFieldItem state : this.states) {
      this.actionsForStateImpl(state);
    }
    for (final ListFieldItem state_1 : this.states) {
      this.actionsForDestructionImpl(state_1);
    }
  }
  
  private CharSequence actionsForStateImpl(final ListFieldItem it) {
    CharSequence _switchResult = null;
    String _value = it.getValue();
    if (_value != null) {
      switch (_value) {
        case "initial":
          _switchResult = this.actionsForInitial(it);
          break;
        case "deferred":
          _switchResult = this.actionsForDeferred(it);
          break;
        case "waiting":
          _switchResult = this.actionsForWaiting(it);
          break;
        case "accepted":
          _switchResult = this.actionsForAccepted(it);
          break;
        case "approved":
          _switchResult = this.actionsForApproved(it);
          break;
        case "suspended":
          _switchResult = this.actionsForSuspended(it);
          break;
        case "archived":
          _switchResult = this.updateAction(it);
          break;
        case "trashed":
          _switchResult = "";
          break;
        case "deleted":
          _switchResult = "";
          break;
      }
    }
    return _switchResult;
  }
  
  private CharSequence actionsForInitial(final ListFieldItem it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _deferAction = this.deferAction(it);
    _builder.append(_deferAction);
    _builder.newLineIfNotEmpty();
    CharSequence _submitAction = this.submitAction(it);
    _builder.append(_submitAction);
    _builder.newLineIfNotEmpty();
    CharSequence _submitAndAcceptAction = this.submitAndAcceptAction(it);
    _builder.append(_submitAndAcceptAction);
    _builder.newLineIfNotEmpty();
    CharSequence _submitAndApproveAction = this.submitAndApproveAction(it);
    _builder.append(_submitAndApproveAction);
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence actionsForDeferred(final ListFieldItem it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _submitAction = this.submitAction(it);
    _builder.append(_submitAction);
    _builder.newLineIfNotEmpty();
    CharSequence _updateAction = this.updateAction(it);
    _builder.append(_updateAction);
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence actionsForWaiting(final ListFieldItem it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _updateAction = this.updateAction(it);
    _builder.append(_updateAction);
    _builder.newLineIfNotEmpty();
    CharSequence _rejectAction = this.rejectAction(it);
    _builder.append(_rejectAction);
    _builder.newLineIfNotEmpty();
    CharSequence _acceptAction = this.acceptAction(it);
    _builder.append(_acceptAction);
    _builder.newLineIfNotEmpty();
    CharSequence _approveAction = this.approveAction(it);
    _builder.append(_approveAction);
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence actionsForAccepted(final ListFieldItem it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _updateAction = this.updateAction(it);
    _builder.append(_updateAction);
    _builder.newLineIfNotEmpty();
    CharSequence _approveAction = this.approveAction(it);
    _builder.append(_approveAction);
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence actionsForApproved(final ListFieldItem it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _updateAction = this.updateAction(it);
    _builder.append(_updateAction);
    _builder.newLineIfNotEmpty();
    CharSequence _demoteAction = this.demoteAction(it);
    _builder.append(_demoteAction);
    _builder.newLineIfNotEmpty();
    CharSequence _suspendAction = this.suspendAction(it);
    _builder.append(_suspendAction);
    _builder.newLineIfNotEmpty();
    CharSequence _archiveAction = this.archiveAction(it);
    _builder.append(_archiveAction);
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence actionsForSuspended(final ListFieldItem it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _updateAction = this.updateAction(it);
    _builder.append(_updateAction);
    _builder.newLineIfNotEmpty();
    CharSequence _unsuspendAction = this.unsuspendAction(it);
    _builder.append(_unsuspendAction);
    _builder.newLineIfNotEmpty();
    CharSequence _archiveAction = this.archiveAction(it);
    _builder.append(_archiveAction);
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence deferAction(final ListFieldItem it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _hasWorkflowState = this._workflowExtensions.hasWorkflowState(this.app, this.wfType, "deferred");
      if (_hasWorkflowState) {
        String _addTransition = this.addTransition("defer", it.getValue(), "deferred");
        _builder.append(_addTransition);
        _builder.newLineIfNotEmpty();
      }
    }
    return _builder;
  }
  
  private CharSequence submitAction(final ListFieldItem it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _equals = Objects.equal(this.wfType, EntityWorkflowType.NONE);
      if (_equals) {
        String _addTransition = this.addTransition("submit", it.getValue(), "approved");
        _builder.append(_addTransition);
        _builder.newLineIfNotEmpty();
      } else {
        String _addTransition_1 = this.addTransition("submit", it.getValue(), "waiting");
        _builder.append(_addTransition_1);
        _builder.newLineIfNotEmpty();
      }
    }
    return _builder;
  }
  
  private CharSequence updateAction(final ListFieldItem it) {
    StringConcatenation _builder = new StringConcatenation();
    String _value = it.getValue();
    String _plus = ("update" + _value);
    String _addTransition = this.addTransition(_plus, it.getValue(), it.getValue());
    _builder.append(_addTransition);
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence rejectAction(final ListFieldItem it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _hasWorkflowState = this._workflowExtensions.hasWorkflowState(this.app, this.wfType, "deferred");
      if (_hasWorkflowState) {
        String _addTransition = this.addTransition("reject", it.getValue(), "deferred");
        _builder.append(_addTransition);
        _builder.newLineIfNotEmpty();
      }
    }
    return _builder;
  }
  
  private CharSequence acceptAction(final ListFieldItem it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _hasWorkflowState = this._workflowExtensions.hasWorkflowState(this.app, this.wfType, "accepted");
      if (_hasWorkflowState) {
        String _addTransition = this.addTransition("accept", it.getValue(), "accepted");
        _builder.append(_addTransition);
        _builder.newLineIfNotEmpty();
      }
    }
    return _builder;
  }
  
  private CharSequence approveAction(final ListFieldItem it) {
    StringConcatenation _builder = new StringConcatenation();
    String _addTransition = this.addTransition("approve", it.getValue(), "approved");
    _builder.append(_addTransition);
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence submitAndAcceptAction(final ListFieldItem it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _hasWorkflowState = this._workflowExtensions.hasWorkflowState(this.app, this.wfType, "accepted");
      if (_hasWorkflowState) {
        String _addTransition = this.addTransition("accept", it.getValue(), "accepted");
        _builder.append(_addTransition);
        _builder.newLineIfNotEmpty();
      }
    }
    return _builder;
  }
  
  private CharSequence submitAndApproveAction(final ListFieldItem it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _hasWorkflowState = this._workflowExtensions.hasWorkflowState(this.app, this.wfType, "waiting");
      if (_hasWorkflowState) {
        String _addTransition = this.addTransition("approve", it.getValue(), "approved");
        _builder.append(_addTransition);
        _builder.newLineIfNotEmpty();
      }
    }
    return _builder;
  }
  
  private CharSequence demoteAction(final ListFieldItem it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _hasWorkflowState = this._workflowExtensions.hasWorkflowState(this.app, this.wfType, "accepted");
      if (_hasWorkflowState) {
        String _addTransition = this.addTransition("demote", it.getValue(), "accepted");
        _builder.append(_addTransition);
        _builder.newLineIfNotEmpty();
      }
    }
    return _builder;
  }
  
  private CharSequence suspendAction(final ListFieldItem it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _hasWorkflowState = this._workflowExtensions.hasWorkflowState(this.app, this.wfType, "suspended");
      if (_hasWorkflowState) {
        String _addTransition = this.addTransition("unpublish", it.getValue(), "suspended");
        _builder.append(_addTransition);
        _builder.newLineIfNotEmpty();
      }
    }
    return _builder;
  }
  
  private CharSequence unsuspendAction(final ListFieldItem it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      String _value = it.getValue();
      boolean _equals = Objects.equal(_value, "suspended");
      if (_equals) {
        String _addTransition = this.addTransition("publish", it.getValue(), "approved");
        _builder.append(_addTransition);
        _builder.newLineIfNotEmpty();
      }
    }
    return _builder;
  }
  
  private CharSequence archiveAction(final ListFieldItem it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _hasWorkflowState = this._workflowExtensions.hasWorkflowState(this.app, this.wfType, "archived");
      if (_hasWorkflowState) {
        String _addTransition = this.addTransition("archive", it.getValue(), "archived");
        _builder.append(_addTransition);
        _builder.newLineIfNotEmpty();
      }
    }
    return _builder;
  }
  
  private CharSequence actionsForDestructionImpl(final ListFieldItem it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      if (((!Objects.equal(it.getValue(), "initial")) && (!Objects.equal(it.getValue(), "deleted")))) {
        {
          if (((!Objects.equal(it.getValue(), "trashed")) && this._workflowExtensions.hasWorkflowState(this.app, this.wfType, "trashed"))) {
            CharSequence _trashAndRecoverActions = this.trashAndRecoverActions(it);
            _builder.append(_trashAndRecoverActions);
            _builder.newLineIfNotEmpty();
          }
        }
        CharSequence _deleteAction = this.deleteAction(it);
        _builder.append(_deleteAction);
        _builder.newLineIfNotEmpty();
      }
    }
    return _builder;
  }
  
  private CharSequence trashAndRecoverActions(final ListFieldItem it) {
    StringConcatenation _builder = new StringConcatenation();
    String _addTransition = this.addTransition("trash", it.getValue(), "trashed");
    _builder.append(_addTransition);
    _builder.newLineIfNotEmpty();
    String _addTransition_1 = this.addTransition("recover", "trashed", it.getValue());
    _builder.append(_addTransition_1);
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence deleteAction(final ListFieldItem it) {
    StringConcatenation _builder = new StringConcatenation();
    String _addTransition = this.addTransition("delete", it.getValue(), "deleted");
    _builder.append(_addTransition);
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private String addTransition(final String id, final String state, final String nextState) {
    String _xblockexpression = null;
    {
      boolean _containsKey = this.transitionsFrom.containsKey(id);
      boolean _not = (!_containsKey);
      if (_not) {
        this.transitionsFrom.put(id, CollectionLiterals.<String>newArrayList());
      }
      this.transitionsFrom.get(id).add(state);
      String _xifexpression = null;
      boolean _containsKey_1 = this.transitionsTo.containsKey(id);
      boolean _not_1 = (!_containsKey_1);
      if (_not_1) {
        _xifexpression = this.transitionsTo.put(id, nextState);
      } else {
        String _get = this.transitionsTo.get(id);
        boolean _notEquals = (!Objects.equal(_get, nextState));
        if (_notEquals) {
          try {
            String _get_1 = this.transitionsTo.get(id);
            String _plus = ((((("Invalid workflow structure: transition \"" + id) + "\" has two different target states (") + nextState) + ", ") + _get_1);
            String _plus_1 = (_plus + ").");
            throw new Exception(_plus_1);
          } catch (final Throwable _t) {
            if (_t instanceof Exception) {
              final Exception exc = (Exception)_t;
              String _get_2 = this.transitionsTo.get(id);
              String _plus_2 = ((((("Invalid workflow structure detected: transition \"" + id) + "\" has two different target states (") + nextState) + ", ") + _get_2);
              String _plus_3 = (_plus_2 + ").");
              throw new RuntimeException(_plus_3, exc);
            } else {
              throw Exceptions.sneakyThrow(_t);
            }
          }
        }
      }
      _xblockexpression = _xifexpression;
    }
    return _xblockexpression;
  }
}
