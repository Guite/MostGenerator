package org.zikula.modulestudio.generator.cartridges.zclassic.controller.workflows;

import com.google.common.base.Objects;
import com.google.inject.Inject;
import de.guite.modulestudio.metamodel.modulestudio.Application;
import de.guite.modulestudio.metamodel.modulestudio.EntityWorkflowType;
import de.guite.modulestudio.metamodel.modulestudio.ListFieldItem;
import java.util.ArrayList;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.WorkflowExtensions;

/**
 * Workflow definitions in xml format.
 */
@SuppressWarnings("all")
public class Definition {
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
  private NamingExtensions _namingExtensions = new Function0<NamingExtensions>() {
    public NamingExtensions apply() {
      NamingExtensions _namingExtensions = new NamingExtensions();
      return _namingExtensions;
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
  
  private Application app;
  
  private EntityWorkflowType wfType;
  
  private ArrayList<ListFieldItem> states;
  
  private IFileSystemAccess fsa;
  
  private String outputPath;
  
  /**
   * Entry point for workflow definitions.
   * This generates xml files describing the workflows used in the application.
   */
  public void generate(final Application it, final IFileSystemAccess fsa) {
    this.app = it;
    this.fsa = fsa;
    String _appSourcePath = this._namingExtensions.getAppSourcePath(it);
    String _plus = (_appSourcePath + "workflows/");
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
    this.wfType = wfType;
    ArrayList<ListFieldItem> _requiredStateList = this._workflowExtensions.getRequiredStateList(this.app, wfType);
    this.states = _requiredStateList;
    String _textualName = this._workflowExtensions.textualName(wfType);
    String _plus = (this.outputPath + _textualName);
    String _plus_1 = (_plus + ".xml");
    CharSequence _xmlSchema = this.xmlSchema();
    this.fsa.generateFile(_plus_1, _xmlSchema);
  }
  
  private CharSequence xmlSchema() {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("<?xml version=\"1.0\" encoding=\"UTF-8\"?>");
    _builder.newLine();
    _builder.append("<workflow>");
    _builder.newLine();
    _builder.append("    ");
    CharSequence _workflowInfo = this.workflowInfo();
    _builder.append(_workflowInfo, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    CharSequence _statesImpl = this.statesImpl();
    _builder.append(_statesImpl, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    CharSequence _actionsImpl = this.actionsImpl();
    _builder.append(_actionsImpl, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("</workflow>");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence workflowInfo() {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("<title>");
    String _textualName = this._workflowExtensions.textualName(this.wfType);
    String _formatForDisplayCapital = this._formattingExtensions.formatForDisplayCapital(_textualName);
    _builder.append(_formatForDisplayCapital, "");
    _builder.append(" workflow (");
    String _approvalType = this._workflowExtensions.approvalType(this.wfType);
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(_approvalType);
    _builder.append(_formatForDisplay, "");
    _builder.append(" approval)</title>");
    _builder.newLineIfNotEmpty();
    _builder.append("<description>");
    String _workflowDescription = this.workflowDescription(this.wfType);
    _builder.append(_workflowDescription, "");
    _builder.append("</description>");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  public String workflowDescription(final EntityWorkflowType wfType) {
    String _switchResult = null;
    boolean _matched = false;
    if (!_matched) {
      if (Objects.equal(wfType,EntityWorkflowType.NONE)) {
        _matched=true;
        _switchResult = "This is like a non-existing workflow. Everything is online immediately after creation.";
      }
    }
    if (!_matched) {
      if (Objects.equal(wfType,EntityWorkflowType.STANDARD)) {
        _matched=true;
        _switchResult = "This is a two staged workflow with stages for untrusted submissions and finally approved publications. It does not allow corrections of non-editors to published pages.";
      }
    }
    if (!_matched) {
      if (Objects.equal(wfType,EntityWorkflowType.ENTERPRISE)) {
        _matched=true;
        _switchResult = "This is a three staged workflow with stages for untrusted submissions, acceptance by editors, and approval control by a superior editor; approved publications are handled by authors staff.";
      }
    }
    return _switchResult;
  }
  
  private CharSequence statesImpl() {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("<!-- define the available states -->");
    _builder.newLine();
    _builder.append("<states>");
    _builder.newLine();
    {
      for(final ListFieldItem state : this.states) {
        _builder.append("    ");
        CharSequence _stateImpl = this.stateImpl(state);
        _builder.append(_stateImpl, "    ");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("</states>");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence stateImpl(final ListFieldItem it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("<state id=\"");
    String _value = it.getValue();
    _builder.append(_value, "");
    _builder.append("\">");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("<title>");
    String _name = it.getName();
    _builder.append(_name, "    ");
    _builder.append("</title>");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("<description>");
    String _documentation = it.getDocumentation();
    _builder.append(_documentation, "    ");
    _builder.append("</description>");
    _builder.newLineIfNotEmpty();
    _builder.append("</state>");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence actionsImpl() {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("<!-- define actions and assign their availability to certain states -->");
    _builder.newLine();
    _builder.append("<!-- available permissions: overview, read, comment, moderate, edit, add, delete, admin -->");
    _builder.newLine();
    _builder.append("<actions>");
    _builder.newLine();
    {
      for(final ListFieldItem state : this.states) {
        _builder.append("    ");
        _builder.append("<!-- From state: ");
        String _name = state.getName();
        _builder.append(_name, "    ");
        _builder.append(" -->");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        CharSequence _actionsForStateImpl = this.actionsForStateImpl(state);
        _builder.append(_actionsForStateImpl, "    ");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.newLine();
    _builder.append("    ");
    _builder.append("<!-- Actions for destroying objects -->");
    _builder.newLine();
    {
      for(final ListFieldItem state_1 : this.states) {
        _builder.append("    ");
        CharSequence _actionsForDestructionImpl = this.actionsForDestructionImpl(state_1);
        _builder.append(_actionsForDestructionImpl, "    ");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("</actions>");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence actionsForStateImpl(final ListFieldItem it) {
    CharSequence _switchResult = null;
    String _value = it.getValue();
    final String _switchValue = _value;
    boolean _matched = false;
    if (!_matched) {
      if (Objects.equal(_switchValue,"initial")) {
        _matched=true;
        CharSequence _actionsForInitial = this.actionsForInitial(it);
        _switchResult = _actionsForInitial;
      }
    }
    if (!_matched) {
      if (Objects.equal(_switchValue,"deferred")) {
        _matched=true;
        CharSequence _actionsForDeferred = this.actionsForDeferred(it);
        _switchResult = _actionsForDeferred;
      }
    }
    if (!_matched) {
      if (Objects.equal(_switchValue,"waiting")) {
        _matched=true;
        CharSequence _actionsForWaiting = this.actionsForWaiting(it);
        _switchResult = _actionsForWaiting;
      }
    }
    if (!_matched) {
      if (Objects.equal(_switchValue,"accepted")) {
        _matched=true;
        CharSequence _actionsForAccepted = this.actionsForAccepted(it);
        _switchResult = _actionsForAccepted;
      }
    }
    if (!_matched) {
      if (Objects.equal(_switchValue,"approved")) {
        _matched=true;
        CharSequence _actionsForApproved = this.actionsForApproved(it);
        _switchResult = _actionsForApproved;
      }
    }
    if (!_matched) {
      if (Objects.equal(_switchValue,"suspended")) {
        _matched=true;
        CharSequence _actionsForSuspended = this.actionsForSuspended(it);
        _switchResult = _actionsForSuspended;
      }
    }
    if (!_matched) {
      if (Objects.equal(_switchValue,"archived")) {
        _matched=true;
        CharSequence _updateAction = this.updateAction(it);
        _switchResult = _updateAction;
      }
    }
    if (!_matched) {
      if (Objects.equal(_switchValue,"trashed")) {
        _matched=true;
        _switchResult = "";
      }
    }
    if (!_matched) {
      if (Objects.equal(_switchValue,"deleted")) {
        _matched=true;
        _switchResult = "";
      }
    }
    return _switchResult;
  }
  
  private CharSequence actionsForInitial(final ListFieldItem it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _deferAction = this.deferAction(it);
    _builder.append(_deferAction, "");
    _builder.newLineIfNotEmpty();
    CharSequence _submitAction = this.submitAction(it);
    _builder.append(_submitAction, "");
    _builder.newLineIfNotEmpty();
    CharSequence _submitAndAcceptAction = this.submitAndAcceptAction(it);
    _builder.append(_submitAndAcceptAction, "");
    _builder.newLineIfNotEmpty();
    CharSequence _submitAndApproveAction = this.submitAndApproveAction(it);
    _builder.append(_submitAndApproveAction, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence actionsForDeferred(final ListFieldItem it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _submitAction = this.submitAction(it);
    _builder.append(_submitAction, "");
    _builder.newLineIfNotEmpty();
    CharSequence _updateAction = this.updateAction(it);
    _builder.append(_updateAction, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence actionsForWaiting(final ListFieldItem it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _updateAction = this.updateAction(it);
    _builder.append(_updateAction, "");
    _builder.newLineIfNotEmpty();
    CharSequence _rejectAction = this.rejectAction(it);
    _builder.append(_rejectAction, "");
    _builder.newLineIfNotEmpty();
    CharSequence _acceptAction = this.acceptAction(it);
    _builder.append(_acceptAction, "");
    _builder.newLineIfNotEmpty();
    CharSequence _approveAction = this.approveAction(it);
    _builder.append(_approveAction, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence actionsForAccepted(final ListFieldItem it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _updateAction = this.updateAction(it);
    _builder.append(_updateAction, "");
    _builder.newLineIfNotEmpty();
    CharSequence _approveAction = this.approveAction(it);
    _builder.append(_approveAction, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence actionsForApproved(final ListFieldItem it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _updateAction = this.updateAction(it);
    _builder.append(_updateAction, "");
    _builder.newLineIfNotEmpty();
    CharSequence _demoteAction = this.demoteAction(it);
    _builder.append(_demoteAction, "");
    _builder.newLineIfNotEmpty();
    CharSequence _suspendAction = this.suspendAction(it);
    _builder.append(_suspendAction, "");
    _builder.newLineIfNotEmpty();
    CharSequence _archiveAction = this.archiveAction(it);
    _builder.append(_archiveAction, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence actionsForSuspended(final ListFieldItem it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _updateAction = this.updateAction(it);
    _builder.append(_updateAction, "");
    _builder.newLineIfNotEmpty();
    CharSequence _unsuspendAction = this.unsuspendAction(it);
    _builder.append(_unsuspendAction, "");
    _builder.newLineIfNotEmpty();
    CharSequence _archiveAction = this.archiveAction(it);
    _builder.append(_archiveAction, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence deferAction(final ListFieldItem it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _hasWorkflowState = this._workflowExtensions.hasWorkflowState(this.app, this.wfType, "deferred");
      if (_hasWorkflowState) {
        String _xifexpression = null;
        boolean _equals = Objects.equal(this.wfType, EntityWorkflowType.NONE);
        if (_equals) {
          _xifexpression = "edit";
        } else {
          _xifexpression = "comment";
        }
        final String permission = _xifexpression;
        _builder.newLineIfNotEmpty();
        String _value = it.getValue();
        CharSequence _actionImpl = this.actionImpl("defer", "Defer", permission, _value, "deferred");
        _builder.append(_actionImpl, "");
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
        String _value = it.getValue();
        CharSequence _actionImpl = this.actionImpl("submit", "Submit", "edit", _value, "approved");
        _builder.append(_actionImpl, "");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.newLine();
        String _value_1 = it.getValue();
        CharSequence _actionImpl_1 = this.actionImpl("submit", "Submit", "comment", _value_1, "waiting");
        _builder.append(_actionImpl_1, "");
        _builder.newLineIfNotEmpty();
      }
    }
    return _builder;
  }
  
  private CharSequence updateAction(final ListFieldItem it) {
    StringConcatenation _builder = new StringConcatenation();
    String _value = it.getValue();
    String _value_1 = it.getValue();
    CharSequence _actionImpl = this.actionImpl("update", "Update", "edit", _value, _value_1);
    _builder.append(_actionImpl, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence rejectAction(final ListFieldItem it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _hasWorkflowState = this._workflowExtensions.hasWorkflowState(this.app, this.wfType, "deferred");
      if (_hasWorkflowState) {
        _builder.newLine();
        String _value = it.getValue();
        CharSequence _actionImpl = this.actionImpl("reject", "Reject", "edit", _value, "deferred");
        _builder.append(_actionImpl, "");
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
        _builder.newLine();
        String _value = it.getValue();
        CharSequence _actionImpl = this.actionImpl("accept", "Accept", "edit", _value, "accepted");
        _builder.append(_actionImpl, "");
        _builder.newLineIfNotEmpty();
      }
    }
    return _builder;
  }
  
  private CharSequence approveAction(final ListFieldItem it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.newLine();
    String _value = it.getValue();
    CharSequence _actionImpl = this.actionImpl("approve", "Approve", "add", _value, "approved");
    _builder.append(_actionImpl, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence submitAndAcceptAction(final ListFieldItem it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _hasWorkflowState = this._workflowExtensions.hasWorkflowState(this.app, this.wfType, "accepted");
      if (_hasWorkflowState) {
        _builder.newLine();
        String _value = it.getValue();
        CharSequence _actionImpl = this.actionImpl("accept", "Submit and Accept", "edit", _value, "accepted");
        _builder.append(_actionImpl, "");
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
        _builder.newLine();
        String _value = it.getValue();
        CharSequence _actionImpl = this.actionImpl("approve", "Submit and Approve", "add", _value, "approved");
        _builder.append(_actionImpl, "");
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
        _builder.newLine();
        String _value = it.getValue();
        CharSequence _actionImpl = this.actionImpl("demote", "Demote", "add", _value, "accepted");
        _builder.append(_actionImpl, "");
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
        String _value = it.getValue();
        CharSequence _actionImpl = this.actionImpl("unpublish", "Unpublish", "edit", _value, "suspended");
        _builder.append(_actionImpl, "");
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
        String _value_1 = it.getValue();
        CharSequence _actionImpl = this.actionImpl("publish", "Publish", "edit", _value_1, "approved");
        _builder.append(_actionImpl, "");
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
        String _value = it.getValue();
        CharSequence _actionImpl = this.actionImpl("archive", "Archive", "edit", _value, "archived");
        _builder.append(_actionImpl, "");
        _builder.newLineIfNotEmpty();
      }
    }
    return _builder;
  }
  
  private CharSequence actionsForDestructionImpl(final ListFieldItem it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _and = false;
      String _value = it.getValue();
      boolean _notEquals = (!Objects.equal(_value, "initial"));
      if (!_notEquals) {
        _and = false;
      } else {
        String _value_1 = it.getValue();
        boolean _notEquals_1 = (!Objects.equal(_value_1, "deleted"));
        _and = (_notEquals && _notEquals_1);
      }
      if (_and) {
        {
          boolean _and_1 = false;
          String _value_2 = it.getValue();
          boolean _notEquals_2 = (!Objects.equal(_value_2, "trashed"));
          if (!_notEquals_2) {
            _and_1 = false;
          } else {
            boolean _hasWorkflowState = this._workflowExtensions.hasWorkflowState(this.app, this.wfType, "trashed");
            _and_1 = (_notEquals_2 && _hasWorkflowState);
          }
          if (_and_1) {
            CharSequence _trashAndRecoverActions = this.trashAndRecoverActions(it);
            _builder.append(_trashAndRecoverActions, "");
            _builder.newLineIfNotEmpty();
          }
        }
        CharSequence _deleteAction = this.deleteAction(it);
        _builder.append(_deleteAction, "");
        _builder.newLineIfNotEmpty();
      }
    }
    return _builder;
  }
  
  private CharSequence trashAndRecoverActions(final ListFieldItem it) {
    StringConcatenation _builder = new StringConcatenation();
    String _value = it.getValue();
    CharSequence _actionImpl = this.actionImpl("trash", "Trash", "edit", _value, "trashed");
    _builder.append(_actionImpl, "");
    _builder.newLineIfNotEmpty();
    String _value_1 = it.getValue();
    CharSequence _actionImpl_1 = this.actionImpl("recover", "Recover", "edit", "trashed", _value_1);
    _builder.append(_actionImpl_1, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence deleteAction(final ListFieldItem it) {
    StringConcatenation _builder = new StringConcatenation();
    String _value = it.getValue();
    CharSequence _actionImpl = this.actionImpl("delete", "Delete", "delete", _value, "");
    _builder.append(_actionImpl, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence actionImpl(final String id, final String title, final String permission, final String state, final String nextState) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("<action id=\"");
    _builder.append(id, "");
    _builder.append("\">");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("<title>");
    _builder.append(title, "    ");
    _builder.append("</title>");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("<description>");
    String _workflowActionDescription = this._workflowExtensions.getWorkflowActionDescription(this.wfType, title);
    _builder.append(_workflowActionDescription, "    ");
    _builder.append("</description>");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("<permission>");
    _builder.append(permission, "    ");
    _builder.append("</permission>");
    _builder.newLineIfNotEmpty();
    {
      boolean _and = false;
      boolean _notEquals = (!Objects.equal(state, ""));
      if (!_notEquals) {
        _and = false;
      } else {
        boolean _notEquals_1 = (!Objects.equal(state, "initial"));
        _and = (_notEquals && _notEquals_1);
      }
      if (_and) {
        _builder.append("    ");
        _builder.append("<state>");
        _builder.append(state, "    ");
        _builder.append("</state>");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      boolean _and_1 = false;
      boolean _notEquals_2 = (!Objects.equal(nextState, ""));
      if (!_notEquals_2) {
        _and_1 = false;
      } else {
        boolean _notEquals_3 = (!Objects.equal(nextState, state));
        _and_1 = (_notEquals_2 && _notEquals_3);
      }
      if (_and_1) {
        _builder.append("    ");
        _builder.append("<nextState>");
        _builder.append(nextState, "    ");
        _builder.append("</nextState>");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.newLine();
    {
      boolean _equals = Objects.equal(id, "delete");
      if (_equals) {
        _builder.append("    ");
        _builder.append("<operation>delete</operation>");
        _builder.newLine();
      } else {
        _builder.append("    ");
        _builder.append("<operation>update</operation>");
        _builder.newLine();
      }
    }
    _builder.append("</action>");
    _builder.newLine();
    _builder.newLine();
    return _builder;
  }
}
