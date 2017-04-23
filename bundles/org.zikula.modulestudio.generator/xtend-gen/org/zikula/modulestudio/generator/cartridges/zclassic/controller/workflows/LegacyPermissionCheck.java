package org.zikula.modulestudio.generator.cartridges.zclassic.controller.workflows;

import com.google.common.base.Objects;
import de.guite.modulestudio.metamodel.Application;
import de.guite.modulestudio.metamodel.Entity;
import de.guite.modulestudio.metamodel.EntityWorkflowType;
import de.guite.modulestudio.metamodel.ListFieldItem;
import java.util.ArrayList;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.workflows.LegacyDefinition;
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;
import org.zikula.modulestudio.generator.extensions.WorkflowExtensions;

/**
 * Workflow permission checks.
 */
@SuppressWarnings("all")
public class LegacyPermissionCheck {
  @Extension
  private FormattingExtensions _formattingExtensions = new FormattingExtensions();
  
  @Extension
  private ModelBehaviourExtensions _modelBehaviourExtensions = new ModelBehaviourExtensions();
  
  @Extension
  private ModelExtensions _modelExtensions = new ModelExtensions();
  
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
  
  private FileHelper fh = new FileHelper();
  
  /**
   * Entry point for workflow permission checks.
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
    this.wfType = wfType;
    this.states = this._workflowExtensions.getRequiredStateList(this.app, wfType);
    String _textualName = this._workflowExtensions.textualName(wfType);
    String _plus = ("function." + _textualName);
    String fileName = (_plus + "_permissioncheck.php");
    boolean _shouldBeSkipped = this._namingExtensions.shouldBeSkipped(this.app, (this.outputPath + fileName));
    boolean _not_1 = (!_shouldBeSkipped);
    if (_not_1) {
      boolean _shouldBeMarked = this._namingExtensions.shouldBeMarked(this.app, (this.outputPath + fileName));
      if (_shouldBeMarked) {
        String _textualName_1 = this._workflowExtensions.textualName(wfType);
        String _plus_1 = ("function." + _textualName_1);
        String _plus_2 = (_plus_1 + "_permissioncheck.generated.php");
        fileName = _plus_2;
      }
      this.fsa.generateFile((this.outputPath + fileName), this.fh.phpFileContent(this.app, this.permissionCheckFile()));
    }
  }
  
  private CharSequence permissionCheckFile() {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _permissionCheckImpl = this.permissionCheckImpl();
    _builder.append(_permissionCheckImpl);
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    CharSequence _textStrings = this.gettextStrings();
    _builder.append(_textStrings);
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence permissionCheckImpl() {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Permission check for workflow schema \'");
    String _textualName = this._workflowExtensions.textualName(this.wfType);
    _builder.append(_textualName, " ");
    _builder.append("\'.");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("* This function allows to calculate complex permission checks.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* It receives the object the workflow engine is being asked to process and the permission level the action requires.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param array  $obj         The currently treated object");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param int    $permLevel   The required workflow permission level");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param int    $currentUser Id of current user");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $actionId    Id of the workflow action to be executed");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return bool Whether the current user is allowed to execute the action or not");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("function ");
    String _appName = this._utils.appName(this.app);
    _builder.append(_appName);
    _builder.append("_workflow_");
    String _textualName_1 = this._workflowExtensions.textualName(this.wfType);
    _builder.append(_textualName_1);
    _builder.append("_permissioncheck($obj, $permLevel, $currentUser, $actionId)");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    {
      boolean _hasAutomaticArchiving = this._modelBehaviourExtensions.hasAutomaticArchiving(this.app);
      if (_hasAutomaticArchiving) {
        _builder.append("    ");
        _builder.append("// every user is allowed to perform automatic archiving ");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("if (true === \\SessionUtil::getVar(\'");
        String _appName_1 = this._utils.appName(this.app);
        _builder.append(_appName_1, "    ");
        _builder.append("AutomaticArchiving\', false)) {");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("return true;");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
        _builder.newLine();
      }
    }
    _builder.append("    ");
    _builder.append("// calculate the permission component");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$objectType = $obj[\'_objectType\'];");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$component = \'");
    String _appName_2 = this._utils.appName(this.app);
    _builder.append(_appName_2, "    ");
    _builder.append(":\' . ucfirst($objectType) . \':\';");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// calculate the permission instance");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$instance = $obj->createCompositeIdentifier() . \'::\';");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// now perform the permission check");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$result = SecurityUtil::checkPermission($component, $instance, $permLevel, $currentUser);");
    _builder.newLine();
    _builder.append("    ");
    final Function1<Entity, Boolean> _function = (Entity it) -> {
      return Boolean.valueOf((it.isStandardFields() && it.isOwnerPermission()));
    };
    final Iterable<Entity> entitiesWithOwnerPermission = IterableExtensions.<Entity>filter(this._modelExtensions.getAllEntities(this.app), _function);
    _builder.newLineIfNotEmpty();
    {
      boolean _isEmpty = IterableExtensions.isEmpty(entitiesWithOwnerPermission);
      boolean _not = (!_isEmpty);
      if (_not) {
        _builder.newLine();
        _builder.append("    ");
        _builder.append("// check whether the current user is the owner");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("if (!$result && isset($obj[\'createdBy\']) && $obj[\'createdBy\']->getUid() == $currentUser) {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("// allow author update operations for all states which occur before \'approved\' in the object\'s life cycle.");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("$result = in_array($actionId, [\'initial\'");
        {
          boolean _hasWorkflowState = this._workflowExtensions.hasWorkflowState(this.app, this.wfType, "deferred");
          if (_hasWorkflowState) {
            _builder.append(", \'deferred\'");
          }
        }
        {
          boolean _notEquals = (!Objects.equal(this.wfType, EntityWorkflowType.NONE));
          if (_notEquals) {
            _builder.append(", \'waiting\'");
          }
        }
        _builder.append(", \'accepted\']);");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
      }
    }
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $result;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence gettextStrings() {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* This helper functions cares for including the strings used in the workflow into translation.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("function ");
    String _appName = this._utils.appName(this.app);
    _builder.append(_appName);
    _builder.append("_workflow_");
    String _textualName = this._workflowExtensions.textualName(this.wfType);
    _builder.append(_textualName);
    _builder.append("_gettextstrings()");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    final LegacyDefinition wfDefinition = new LegacyDefinition();
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("$translator = \\ServiceUtil::get(\'translator.default\');");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return [");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'title\' => ");
    CharSequence _textCall = this.gettextCall(this.app);
    _builder.append(_textCall, "        ");
    _builder.append("(\'");
    String _formatForDisplayCapital = this._formattingExtensions.formatForDisplayCapital(this._workflowExtensions.textualName(this.wfType));
    _builder.append(_formatForDisplayCapital, "        ");
    _builder.append(" workflow (");
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(this._workflowExtensions.approvalType(this.wfType));
    _builder.append(_formatForDisplay, "        ");
    _builder.append(" approval)\'),");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("\'description\' => ");
    CharSequence _textCall_1 = this.gettextCall(this.app);
    _builder.append(_textCall_1, "        ");
    _builder.append("(\'");
    String _workflowDescription = wfDefinition.workflowDescription(this.wfType);
    _builder.append(_workflowDescription, "        ");
    _builder.append("\'),");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("        ");
    final ListFieldItem lastState = IterableExtensions.<ListFieldItem>last(this.states);
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    CharSequence _textStates = this.gettextStates(lastState);
    _builder.append(_textStates, "        ");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("        ");
    CharSequence _textActionsPerState = this.gettextActionsPerState(lastState);
    _builder.append(_textActionsPerState, "        ");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("];");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence gettextStates(final ListFieldItem lastState) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("// state titles");
    _builder.newLine();
    _builder.append("\'states\' => [");
    _builder.newLine();
    {
      for(final ListFieldItem state : this.states) {
        _builder.append("    ");
        CharSequence _textState = this.gettextState(state);
        _builder.append(_textState, "    ");
        {
          boolean _notEquals = (!Objects.equal(state, lastState));
          if (_notEquals) {
            _builder.append(",");
          }
        }
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("],");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence gettextState(final ListFieldItem it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _textCall = this.gettextCall(this.app);
    _builder.append(_textCall);
    _builder.append("(\'");
    String _name = it.getName();
    _builder.append(_name);
    _builder.append("\') => ");
    CharSequence _textCall_1 = this.gettextCall(this.app);
    _builder.append(_textCall_1);
    _builder.append("(\'");
    String _documentation = it.getDocumentation();
    _builder.append(_documentation);
    _builder.append("\')");
    return _builder;
  }
  
  private CharSequence gettextActionsPerState(final ListFieldItem lastState) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("// action titles and descriptions for each state");
    _builder.newLine();
    _builder.append("\'actions\' => [");
    _builder.newLine();
    {
      for(final ListFieldItem state : this.states) {
        _builder.append("    ");
        CharSequence _textActionsForState = this.gettextActionsForState(state);
        _builder.append(_textActionsForState, "    ");
        {
          boolean _notEquals = (!Objects.equal(state, lastState));
          if (_notEquals) {
            _builder.append(",");
          }
        }
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("]");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence gettextActionsForState(final ListFieldItem it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("\'");
    String _value = it.getValue();
    _builder.append(_value);
    _builder.append("\' => [");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    CharSequence _actionsForStateImpl = this.actionsForStateImpl(it);
    _builder.append(_actionsForStateImpl, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    CharSequence _actionsForDestructionImpl = this.actionsForDestructionImpl(it);
    _builder.append(_actionsForDestructionImpl, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("]");
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
    CharSequence _submitAction = this.submitAction(it);
    _builder.append(_submitAction);
    _builder.newLineIfNotEmpty();
    CharSequence _submitAndAcceptAction = this.submitAndAcceptAction(it);
    _builder.append(_submitAndAcceptAction);
    _builder.newLineIfNotEmpty();
    CharSequence _submitAndApproveAction = this.submitAndApproveAction(it);
    _builder.append(_submitAndApproveAction);
    _builder.newLineIfNotEmpty();
    CharSequence _deferAction = this.deferAction(it);
    _builder.append(_deferAction);
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
        CharSequence _actionImpl = this.actionImpl("Defer");
        _builder.append(_actionImpl);
        _builder.newLineIfNotEmpty();
      }
    }
    return _builder;
  }
  
  private CharSequence submitAction(final ListFieldItem it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _actionImpl = this.actionImpl("Submit");
    _builder.append(_actionImpl);
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence updateAction(final ListFieldItem it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _actionImpl = this.actionImpl("Update");
    _builder.append(_actionImpl);
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence rejectAction(final ListFieldItem it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _hasWorkflowState = this._workflowExtensions.hasWorkflowState(this.app, this.wfType, "deferred");
      if (_hasWorkflowState) {
        CharSequence _actionImpl = this.actionImpl("Reject");
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
        CharSequence _actionImpl = this.actionImpl("Accept");
        _builder.append(_actionImpl);
        _builder.newLineIfNotEmpty();
      }
    }
    return _builder;
  }
  
  private CharSequence approveAction(final ListFieldItem it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _actionImpl = this.actionImpl("Approve");
    _builder.append(_actionImpl);
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence submitAndAcceptAction(final ListFieldItem it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _hasWorkflowState = this._workflowExtensions.hasWorkflowState(this.app, this.wfType, "accepted");
      if (_hasWorkflowState) {
        CharSequence _actionImpl = this.actionImpl("Submit and Accept");
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
        CharSequence _actionImpl = this.actionImpl("Submit and Approve");
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
        CharSequence _actionImpl = this.actionImpl("Demote");
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
        CharSequence _actionImpl = this.actionImpl("Unpublish");
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
        CharSequence _actionImpl = this.actionImpl("Publish");
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
        CharSequence _actionImpl = this.actionImpl("Archive");
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
    CharSequence _actionImpl = this.actionImpl("Trash");
    _builder.append(_actionImpl);
    _builder.newLineIfNotEmpty();
    CharSequence _actionImpl_1 = this.actionImpl("Recover");
    _builder.append(_actionImpl_1);
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence deleteAction(final ListFieldItem it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _actionImpl = this.actionImpl("Delete");
    _builder.append(_actionImpl);
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence actionImpl(final String title) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _textCall = this.gettextCall(this.app);
    _builder.append(_textCall);
    _builder.append("(\'");
    _builder.append(title);
    _builder.append("\') => ");
    CharSequence _textCall_1 = this.gettextCall(this.app);
    _builder.append(_textCall_1);
    _builder.append("(\'");
    String _workflowActionDescription = this._workflowExtensions.getWorkflowActionDescription(this.wfType, title);
    _builder.append(_workflowActionDescription);
    _builder.append("\')");
    {
      boolean _notEquals = (!Objects.equal(title, "Delete"));
      if (_notEquals) {
        _builder.append(",");
      }
    }
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence gettextCall(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("$translator->__");
    return _builder;
  }
}
