package org.zikula.modulestudio.generator.cartridges.zclassic.controller.workflows;

import com.google.common.base.Objects;
import com.google.inject.Inject;
import de.guite.modulestudio.metamodel.modulestudio.Application;
import de.guite.modulestudio.metamodel.modulestudio.Entity;
import de.guite.modulestudio.metamodel.modulestudio.EntityWorkflowType;
import de.guite.modulestudio.metamodel.modulestudio.ListFieldItem;
import java.util.ArrayList;
import org.eclipse.emf.common.util.EList;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.workflows.Definition;
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;
import org.zikula.modulestudio.generator.extensions.WorkflowExtensions;

/**
 * Workflow permission checks.
 */
@SuppressWarnings("all")
public class PermissionCheck {
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
  
  private FileHelper fh = new Function0<FileHelper>() {
    public FileHelper apply() {
      FileHelper _fileHelper = new FileHelper();
      return _fileHelper;
    }
  }.apply();
  
  /**
   * Entry point for workflow permission checks.
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
    String _plus = (this.outputPath + "function.");
    String _textualName = this._workflowExtensions.textualName(wfType);
    String _plus_1 = (_plus + _textualName);
    String _plus_2 = (_plus_1 + "_permissioncheck.php");
    CharSequence _permissionCheckFile = this.permissionCheckFile();
    this.fsa.generateFile(_plus_2, _permissionCheckFile);
  }
  
  private CharSequence permissionCheckFile() {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _phpFileHeader = this.fh.phpFileHeader(this.app);
    _builder.append(_phpFileHeader, "");
    _builder.newLineIfNotEmpty();
    CharSequence _permissionCheckImpl = this.permissionCheckImpl();
    _builder.append(_permissionCheckImpl, "");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    CharSequence _textStrings = this.gettextStrings();
    _builder.append(_textStrings, "");
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
    _builder.append("* @param array  $obj         The currently treated object.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param int    $permLevel   The required workflow permission level.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param int    $currentUser Id of current user.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $actionId    Id of the workflow action to be executed.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return bool Whether the current user is allowed to execute the action or not.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("function ");
    String _appName = this._utils.appName(this.app);
    _builder.append(_appName, "");
    _builder.append("_workflow_");
    String _textualName_1 = this._workflowExtensions.textualName(this.wfType);
    _builder.append(_textualName_1, "");
    _builder.append("_permissioncheck($obj, $permLevel, $currentUser, $actionId)");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// calculate the permission component");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$objectType = $obj[\'_objectType\'];");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$component = \'");
    String _appName_1 = this._utils.appName(this.app);
    _builder.append(_appName_1, "    ");
    _builder.append(":\' . ucwords($objectType) . \':\';");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// calculate the permission instance");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$idFields = ModUtil::apiFunc(\'");
    String _appName_2 = this._utils.appName(this.app);
    _builder.append(_appName_2, "    ");
    _builder.append("\', \'selection\', \'getIdFields\', array(\'ot\' => $objectType));");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("$instanceId = \'\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("foreach ($idFields as $idField) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if (!empty($instanceId)) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$instanceId .= \'_\';");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$instanceId .= $obj[$idField];");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$instance = $instanceId . \'::\';");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// now perform the permission check");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$result = SecurityUtil::checkPermission($component, $instance, $permLevel, $currentUser);");
    _builder.newLine();
    _builder.append("    ");
    EList<Entity> _allEntities = this._modelExtensions.getAllEntities(this.app);
    final Function1<Entity,Boolean> _function = new Function1<Entity,Boolean>() {
      public Boolean apply(final Entity it) {
        boolean _and = false;
        boolean _isStandardFields = it.isStandardFields();
        if (!_isStandardFields) {
          _and = false;
        } else {
          boolean _isOwnerPermission = it.isOwnerPermission();
          _and = (_isStandardFields && _isOwnerPermission);
        }
        return Boolean.valueOf(_and);
      }
    };
    final Iterable<Entity> entitiesWithOwnerPermission = IterableExtensions.<Entity>filter(_allEntities, _function);
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
        _builder.append("if (!$result && isset($obj[\'createdUserId\']) && $obj[\'createdUserId\'] == $currentUser) {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("// allow author update operations for all states which occur before \'approved\' in the object\'s life cycle.");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("$result = in_array($actionId, array(\'initial\'");
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
        _builder.append(", \'accepted\'));");
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
    _builder.append(_appName, "");
    _builder.append("_workflow_");
    String _textualName = this._workflowExtensions.textualName(this.wfType);
    _builder.append(_textualName, "");
    _builder.append("_gettextstrings()");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    Definition _definition = new Definition();
    final Definition wfDefinition = _definition;
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("return array(");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'title\' => no__(\'");
    String _textualName_1 = this._workflowExtensions.textualName(this.wfType);
    String _formatForDisplayCapital = this._formattingExtensions.formatForDisplayCapital(_textualName_1);
    _builder.append(_formatForDisplayCapital, "        ");
    _builder.append(" workflow (");
    String _approvalType = this._workflowExtensions.approvalType(this.wfType);
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(_approvalType);
    _builder.append(_formatForDisplay, "        ");
    _builder.append(" approval)\'),");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("\'description\' => no__(\'");
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
    _builder.append(");");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence gettextStates(final ListFieldItem lastState) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("// state titles");
    _builder.newLine();
    _builder.append("\'states\' => array(");
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
    _builder.append("),");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence gettextState(final ListFieldItem it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("no__(\'");
    String _name = it.getName();
    _builder.append(_name, "");
    _builder.append("\') => no__(\'");
    String _documentation = it.getDocumentation();
    _builder.append(_documentation, "");
    _builder.append("\')");
    return _builder;
  }
  
  private CharSequence gettextActionsPerState(final ListFieldItem lastState) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("// action titles and descriptions for each state");
    _builder.newLine();
    _builder.append("\'actions\' => array(");
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
    _builder.append(")");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence gettextActionsForState(final ListFieldItem it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("\'");
    String _value = it.getValue();
    _builder.append(_value, "");
    _builder.append("\' => array(");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    CharSequence _actionsForStateImpl = this.actionsForStateImpl(it);
    _builder.append(_actionsForStateImpl, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    CharSequence _actionsForDestructionImpl = this.actionsForDestructionImpl(it);
    _builder.append(_actionsForDestructionImpl, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append(")");
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
    CharSequence _submitAction = this.submitAction(it);
    _builder.append(_submitAction, "");
    _builder.newLineIfNotEmpty();
    CharSequence _submitAndAcceptAction = this.submitAndAcceptAction(it);
    _builder.append(_submitAndAcceptAction, "");
    _builder.newLineIfNotEmpty();
    CharSequence _submitAndApproveAction = this.submitAndApproveAction(it);
    _builder.append(_submitAndApproveAction, "");
    _builder.newLineIfNotEmpty();
    CharSequence _deferAction = this.deferAction(it);
    _builder.append(_deferAction, "");
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
        CharSequence _actionImpl = this.actionImpl("Defer");
        _builder.append(_actionImpl, "");
        _builder.newLineIfNotEmpty();
      }
    }
    return _builder;
  }
  
  private CharSequence submitAction(final ListFieldItem it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _actionImpl = this.actionImpl("Submit");
    _builder.append(_actionImpl, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence updateAction(final ListFieldItem it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _actionImpl = this.actionImpl("Update");
    _builder.append(_actionImpl, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence rejectAction(final ListFieldItem it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _hasWorkflowState = this._workflowExtensions.hasWorkflowState(this.app, this.wfType, "deferred");
      if (_hasWorkflowState) {
        CharSequence _actionImpl = this.actionImpl("Reject");
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
        CharSequence _actionImpl = this.actionImpl("Accept");
        _builder.append(_actionImpl, "");
        _builder.newLineIfNotEmpty();
      }
    }
    return _builder;
  }
  
  private CharSequence approveAction(final ListFieldItem it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _actionImpl = this.actionImpl("Approve");
    _builder.append(_actionImpl, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence submitAndAcceptAction(final ListFieldItem it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _hasWorkflowState = this._workflowExtensions.hasWorkflowState(this.app, this.wfType, "accepted");
      if (_hasWorkflowState) {
        CharSequence _actionImpl = this.actionImpl("Submit and Accept");
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
        CharSequence _actionImpl = this.actionImpl("Submit and Approve");
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
        CharSequence _actionImpl = this.actionImpl("Demote");
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
        CharSequence _actionImpl = this.actionImpl("Unpublish");
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
        CharSequence _actionImpl = this.actionImpl("Publish");
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
        CharSequence _actionImpl = this.actionImpl("Archive");
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
    CharSequence _actionImpl = this.actionImpl("Trash");
    _builder.append(_actionImpl, "");
    _builder.newLineIfNotEmpty();
    CharSequence _actionImpl_1 = this.actionImpl("Recover");
    _builder.append(_actionImpl_1, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence deleteAction(final ListFieldItem it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _actionImpl = this.actionImpl("Delete");
    _builder.append(_actionImpl, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence actionImpl(final String title) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("no__(\'");
    _builder.append(title, "");
    _builder.append("\') => no__(\'");
    String _workflowActionDescription = this._workflowExtensions.getWorkflowActionDescription(this.wfType, title);
    _builder.append(_workflowActionDescription, "");
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
}
