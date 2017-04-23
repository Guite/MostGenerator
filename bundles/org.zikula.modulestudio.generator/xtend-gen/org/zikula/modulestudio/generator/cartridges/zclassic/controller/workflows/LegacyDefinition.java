package org.zikula.modulestudio.generator.cartridges.zclassic.controller.workflows;

import com.google.common.base.Objects;
import de.guite.modulestudio.metamodel.Application;
import de.guite.modulestudio.metamodel.EntityWorkflowType;
import de.guite.modulestudio.metamodel.ListFieldItem;
import java.util.ArrayList;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;
import org.zikula.modulestudio.generator.extensions.WorkflowExtensions;

/**
 * Legacy workflow definitions in XML format.
 */
@SuppressWarnings("all")
public class LegacyDefinition {
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
  
  private IFileSystemAccess fsa;
  
  private String outputPath;
  
  /**
   * Entry point for legacy workflow definitions.
   * This generates XML files describing the workflows used in the application.
   */
  public void generate(final Application it, final IFileSystemAccess fsa) {
    Boolean _targets = this._utils.targets(it, "1.5");
    if ((_targets).booleanValue()) {
      return;
    }
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
    String _textualName = this._workflowExtensions.textualName(wfType);
    String fileName = (_textualName + ".xml");
    boolean _shouldBeSkipped = this._namingExtensions.shouldBeSkipped(this.app, (this.outputPath + fileName));
    if (_shouldBeSkipped) {
      return;
    }
    this.wfType = wfType;
    this.states = this._workflowExtensions.getRequiredStateList(this.app, wfType);
    boolean _shouldBeMarked = this._namingExtensions.shouldBeMarked(this.app, (this.outputPath + fileName));
    if (_shouldBeMarked) {
      String _textualName_1 = this._workflowExtensions.textualName(wfType);
      String _plus = (_textualName_1 + ".generated.xml");
      fileName = _plus;
    }
    this.fsa.generateFile((this.outputPath + fileName), this.xmlSchema());
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
    String _formatForDisplayCapital = this._formattingExtensions.formatForDisplayCapital(this._workflowExtensions.textualName(this.wfType));
    _builder.append(_formatForDisplayCapital);
    _builder.append(" workflow (");
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(this._workflowExtensions.approvalType(this.wfType));
    _builder.append(_formatForDisplay);
    _builder.append(" approval)</title>");
    _builder.newLineIfNotEmpty();
    _builder.append("<description>");
    String _workflowDescription = this.workflowDescription(this.wfType);
    _builder.append(_workflowDescription);
    _builder.append("</description>");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  public String workflowDescription(final EntityWorkflowType wfType) {
    String _switchResult = null;
    if (wfType != null) {
      switch (wfType) {
        case NONE:
          _switchResult = "This is like a non-existing workflow. Everything is online immediately after creation.";
          break;
        case STANDARD:
          _switchResult = "This is a two staged workflow with stages for untrusted submissions and finally approved publications. It does not allow corrections of non-editors to published pages.";
          break;
        case ENTERPRISE:
          _switchResult = "This is a three staged workflow with stages for untrusted submissions, acceptance by editors, and approval control by a superior editor; approved publications are handled by authors staff.";
          break;
        default:
          break;
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
    _builder.append(_value);
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
        String _xifexpression = null;
        boolean _equals = Objects.equal(this.wfType, EntityWorkflowType.NONE);
        if (_equals) {
          _xifexpression = "edit";
        } else {
          _xifexpression = "comment";
        }
        final String permission = _xifexpression;
        _builder.newLineIfNotEmpty();
        CharSequence _actionImpl = this.actionImpl("defer", "Defer", permission, it.getValue(), "deferred");
        _builder.append(_actionImpl);
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
        CharSequence _actionImpl = this.actionImpl("submit", "Submit", "edit", it.getValue(), "approved");
        _builder.append(_actionImpl);
        _builder.newLineIfNotEmpty();
      } else {
        CharSequence _actionImpl_1 = this.actionImpl("submit", "Submit", "comment", it.getValue(), "waiting");
        _builder.append(_actionImpl_1);
        _builder.newLineIfNotEmpty();
      }
    }
    return _builder;
  }
  
  private CharSequence updateAction(final ListFieldItem it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _actionImpl = this.actionImpl("update", "Update", "edit", it.getValue(), it.getValue());
    _builder.append(_actionImpl);
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence rejectAction(final ListFieldItem it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _hasWorkflowState = this._workflowExtensions.hasWorkflowState(this.app, this.wfType, "deferred");
      if (_hasWorkflowState) {
        CharSequence _actionImpl = this.actionImpl("reject", "Reject", "edit", it.getValue(), "deferred");
        _builder.append(_actionImpl);
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
        CharSequence _actionImpl = this.actionImpl("accept", "Accept", "edit", it.getValue(), "accepted");
        _builder.append(_actionImpl);
        _builder.newLineIfNotEmpty();
      }
    }
    return _builder;
  }
  
  private CharSequence approveAction(final ListFieldItem it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _actionImpl = this.actionImpl("approve", "Approve", "add", it.getValue(), "approved");
    _builder.append(_actionImpl);
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence submitAndAcceptAction(final ListFieldItem it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _hasWorkflowState = this._workflowExtensions.hasWorkflowState(this.app, this.wfType, "accepted");
      if (_hasWorkflowState) {
        CharSequence _actionImpl = this.actionImpl("accept", "Submit and Accept", "edit", it.getValue(), "accepted");
        _builder.append(_actionImpl);
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
        CharSequence _actionImpl = this.actionImpl("approve", "Submit and Approve", "add", it.getValue(), "approved");
        _builder.append(_actionImpl);
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
        CharSequence _actionImpl = this.actionImpl("demote", "Demote", "add", it.getValue(), "accepted");
        _builder.append(_actionImpl);
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
        CharSequence _actionImpl = this.actionImpl("unpublish", "Unpublish", "edit", it.getValue(), "suspended");
        _builder.append(_actionImpl);
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
        CharSequence _actionImpl = this.actionImpl("publish", "Publish", "edit", it.getValue(), "approved");
        _builder.append(_actionImpl);
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
        CharSequence _actionImpl = this.actionImpl("archive", "Archive", "edit", it.getValue(), "archived");
        _builder.append(_actionImpl);
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
    CharSequence _actionImpl = this.actionImpl("trash", "Trash", "edit", it.getValue(), "trashed");
    _builder.append(_actionImpl);
    _builder.newLineIfNotEmpty();
    CharSequence _actionImpl_1 = this.actionImpl("recover", "Recover", "edit", "trashed", it.getValue());
    _builder.append(_actionImpl_1);
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence deleteAction(final ListFieldItem it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _actionImpl = this.actionImpl("delete", "Delete", "delete", it.getValue(), "deleted");
    _builder.append(_actionImpl);
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence actionImpl(final String id, final String title, final String permission, final String state, final String nextState) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("<action id=\"");
    _builder.append(id);
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
      if (((!Objects.equal(state, "")) && (!Objects.equal(state, "initial")))) {
        _builder.append("    ");
        _builder.append("<state>");
        _builder.append(state, "    ");
        _builder.append("</state>");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      if (((!Objects.equal(nextState, "")) && (!Objects.equal(nextState, state)))) {
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
    {
      boolean _notEquals = (!Objects.equal(this.wfType, EntityWorkflowType.NONE));
      if (_notEquals) {
        _builder.append("    ");
        CharSequence _notifyCall = this.notifyCall(id, nextState);
        _builder.append(_notifyCall, "    ");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("</action>");
    _builder.newLine();
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence notifyCall(final String id, final String state) {
    StringConcatenation _builder = new StringConcatenation();
    {
      if ((Objects.equal(id, "submit") && Objects.equal(state, "waiting"))) {
        _builder.append("<operation recipientType=\"moderator\" action=\"");
        _builder.append(id);
        _builder.append("\">notify</operation>");
        _builder.newLineIfNotEmpty();
      } else {
        if ((Objects.equal(id, "reject") && Objects.equal(state, "deferred"))) {
          _builder.append("<operation recipientType=\"creator\" action=\"");
          _builder.append(id);
          _builder.append("\">notify</operation>");
          _builder.newLineIfNotEmpty();
        } else {
          if ((Objects.equal(id, "accept") && Objects.equal(state, "accepted"))) {
            _builder.append("<operation recipientType=\"creator\" action=\"");
            _builder.append(id);
            _builder.append("\">notify</operation>");
            _builder.newLineIfNotEmpty();
            _builder.append("<operation recipientType=\"superModerator\" action=\"");
            _builder.append(id);
            _builder.append("\">notify</operation>");
            _builder.newLineIfNotEmpty();
          } else {
            if ((Objects.equal(id, "approve") && Objects.equal(state, "approved"))) {
              _builder.append("<operation recipientType=\"creator\" action=\"");
              _builder.append(id);
              _builder.append("\">notify</operation>");
              _builder.newLineIfNotEmpty();
              {
                boolean _equals = Objects.equal(this.wfType, EntityWorkflowType.ENTERPRISE);
                if (_equals) {
                  _builder.append("<operation recipientType=\"moderator\" action=\"");
                  _builder.append(id);
                  _builder.append("\">notify</operation>");
                  _builder.newLineIfNotEmpty();
                }
              }
            } else {
              if ((Objects.equal(id, "demote") && Objects.equal(state, "accepted"))) {
                _builder.append("<operation recipientType=\"moderator\" action=\"");
                _builder.append(id);
                _builder.append("\">notify</operation>");
                _builder.newLineIfNotEmpty();
              } else {
                if ((Objects.equal(id, "unpublish") && Objects.equal(state, "suspended"))) {
                  _builder.append("<operation recipientType=\"creator\" action=\"");
                  _builder.append(id);
                  _builder.append("\">notify</operation>");
                  _builder.newLineIfNotEmpty();
                } else {
                  if ((Objects.equal(id, "publish") && Objects.equal(state, "approved"))) {
                    _builder.append("<operation recipientType=\"creator\" action=\"");
                    _builder.append(id);
                    _builder.append("\">notify</operation>");
                    _builder.newLineIfNotEmpty();
                  } else {
                    if ((Objects.equal(id, "archive") && Objects.equal(state, "archived"))) {
                      _builder.append("<operation recipientType=\"creator\" action=\"");
                      _builder.append(id);
                      _builder.append("\">notify</operation>");
                      _builder.newLineIfNotEmpty();
                    } else {
                      if ((Objects.equal(id, "trash") && Objects.equal(state, "trashed"))) {
                        _builder.append("<operation recipientType=\"creator\" action=\"");
                        _builder.append(id);
                        _builder.append("\">notify</operation>");
                        _builder.newLineIfNotEmpty();
                      } else {
                        boolean _equals_1 = Objects.equal(id, "recover");
                        if (_equals_1) {
                          _builder.append("<operation recipientType=\"creator\" action=\"");
                          _builder.append(id);
                          _builder.append("\">notify</operation>");
                          _builder.newLineIfNotEmpty();
                        } else {
                          boolean _equals_2 = Objects.equal(id, "delete");
                          if (_equals_2) {
                            _builder.append("<operation recipientType=\"creator\" action=\"");
                            _builder.append(id);
                            _builder.append("\">notify</operation>");
                            _builder.newLineIfNotEmpty();
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
    _builder.newLine();
    _builder.append("<!-- example for custom recipient type using designated entity fields: -->");
    _builder.newLine();
    _builder.append("<!-- operation recipientType=\"field-email^lastname\" action=\"submit\">notify</operation -->");
    _builder.newLine();
    return _builder;
  }
}
