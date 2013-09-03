package org.zikula.modulestudio.generator.cartridges.zclassic.controller.util;

import com.google.common.base.Objects;
import com.google.common.collect.Iterables;
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
import org.eclipse.xtext.xbase.lib.InputOutput;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.eclipse.xtext.xbase.lib.StringExtensions;
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;
import org.zikula.modulestudio.generator.extensions.WorkflowExtensions;

@SuppressWarnings("all")
public class WorkflowUtil {
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
  
  private FileHelper fh = new Function0<FileHelper>() {
    public FileHelper apply() {
      FileHelper _fileHelper = new FileHelper();
      return _fileHelper;
    }
  }.apply();
  
  /**
   * Entry point for the utility class creation.
   */
  public void generate(final Application it, final IFileSystemAccess fsa) {
    InputOutput.<String>println("Generating utility class for workflows");
    String _appSourceLibPath = this._namingExtensions.getAppSourceLibPath(it);
    final String utilPath = (_appSourceLibPath + "Util/");
    String _xifexpression = null;
    boolean _targets = this._utils.targets(it, "1.3.5");
    if (_targets) {
      _xifexpression = "";
    } else {
      _xifexpression = "Util";
    }
    final String utilSuffix = _xifexpression;
    String _plus = (utilPath + "Base/Workflow");
    String _plus_1 = (_plus + utilSuffix);
    String _plus_2 = (_plus_1 + ".php");
    CharSequence _workflowFunctionsBaseFile = this.workflowFunctionsBaseFile(it);
    fsa.generateFile(_plus_2, _workflowFunctionsBaseFile);
    String _plus_3 = (utilPath + "Workflow");
    String _plus_4 = (_plus_3 + utilSuffix);
    String _plus_5 = (_plus_4 + ".php");
    CharSequence _workflowFunctionsFile = this.workflowFunctionsFile(it);
    fsa.generateFile(_plus_5, _workflowFunctionsFile);
  }
  
  private CharSequence workflowFunctionsBaseFile(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _phpFileHeader = this.fh.phpFileHeader(it);
    _builder.append(_phpFileHeader, "");
    _builder.newLineIfNotEmpty();
    CharSequence _workflowFunctionsBaseImpl = this.workflowFunctionsBaseImpl(it);
    _builder.append(_workflowFunctionsBaseImpl, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence workflowFunctionsFile(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _phpFileHeader = this.fh.phpFileHeader(it);
    _builder.append(_phpFileHeader, "");
    _builder.newLineIfNotEmpty();
    CharSequence _workflowFunctionsImpl = this.workflowFunctionsImpl(it);
    _builder.append(_workflowFunctionsImpl, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence workflowFunctionsBaseImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _targets = this._utils.targets(it, "1.3.5");
      boolean _not = (!_targets);
      if (_not) {
        _builder.append("namespace ");
        String _appNamespace = this._utils.appNamespace(it);
        _builder.append(_appNamespace, "");
        _builder.append("\\Util\\Base;");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
        _builder.append("use ModUtil;");
        _builder.newLine();
        _builder.append("use SecurityUtil;");
        _builder.newLine();
        _builder.append("use Zikula_AbstractBase;");
        _builder.newLine();
        _builder.append("use Zikula_Workflow_Util;");
        _builder.newLine();
        _builder.newLine();
      }
    }
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Utility base class for workflow helper methods.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("class ");
    {
      boolean _targets_1 = this._utils.targets(it, "1.3.5");
      if (_targets_1) {
        String _appName = this._utils.appName(it);
        _builder.append(_appName, "");
        _builder.append("_Util_Base_Workflow");
      } else {
        _builder.append("WorkflowUtil");
      }
    }
    _builder.append(" extends Zikula_AbstractBase");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    CharSequence _objectStates = this.getObjectStates(it);
    _builder.append(_objectStates, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    CharSequence _stateInfo = this.getStateInfo(it);
    _builder.append(_stateInfo, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    CharSequence _workflowName = this.getWorkflowName(it);
    _builder.append(_workflowName, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    CharSequence _workflowSchema = this.getWorkflowSchema(it);
    _builder.append(_workflowSchema, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    CharSequence _actionsForObject = this.getActionsForObject(it);
    _builder.append(_actionsForObject, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    CharSequence _executeAction = this.executeAction(it);
    _builder.append(_executeAction, "    ");
    _builder.newLineIfNotEmpty();
    {
      boolean _targets_2 = this._utils.targets(it, "1.3.5");
      boolean _not_1 = (!_targets_2);
      if (_not_1) {
        _builder.append("    ");
        CharSequence _normaliseWorkflowData = this.normaliseWorkflowData(it);
        _builder.append(_normaliseWorkflowData, "    ");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("    ");
    CharSequence _collectAmountOfModerationItems = this.collectAmountOfModerationItems(it);
    _builder.append(_collectAmountOfModerationItems, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    CharSequence _amountOfModerationItems = this.getAmountOfModerationItems(it);
    _builder.append(_amountOfModerationItems, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence getObjectStates(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append("  ");
    _builder.append("* This method returns a list of possible object states.");
    _builder.newLine();
    _builder.append("  ");
    _builder.append("*");
    _builder.newLine();
    _builder.append("  ");
    _builder.append("* @return array List of collected state information.");
    _builder.newLine();
    _builder.append("  ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("public function getObjectStates()");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("{");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("$states = array();");
    _builder.newLine();
    _builder.append("     ");
    final ArrayList<ListFieldItem> states = this._workflowExtensions.getRequiredStateList(it);
    _builder.newLineIfNotEmpty();
    {
      for(final ListFieldItem state : states) {
        _builder.append("     ");
        CharSequence _stateInfo = this.stateInfo(state);
        _builder.append(_stateInfo, "     ");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.newLine();
    _builder.append("     ");
    _builder.append("return $states;");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence stateInfo(final ListFieldItem it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("$states[] = array(\'value\' => \'");
    String _value = it.getValue();
    _builder.append(_value, "");
    _builder.append("\',");
    _builder.newLineIfNotEmpty();
    _builder.append("                  ");
    _builder.append("\'text\' => $this->__(\'");
    String _name = it.getName();
    _builder.append(_name, "                  ");
    _builder.append("\'),");
    _builder.newLineIfNotEmpty();
    _builder.append("                  ");
    _builder.append("\'icon\' => \'");
    String _stateIcon = this.stateIcon(it);
    _builder.append(_stateIcon, "                  ");
    _builder.append("led.png\');");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private String stateIcon(final ListFieldItem it) {
    String _switchResult = null;
    String _value = it.getValue();
    final String _switchValue = _value;
    boolean _matched = false;
    if (!_matched) {
      if (Objects.equal(_switchValue,"initial")) {
        _matched=true;
        _switchResult = "red";
      }
    }
    if (!_matched) {
      if (Objects.equal(_switchValue,"deferred")) {
        _matched=true;
        _switchResult = "red";
      }
    }
    if (!_matched) {
      if (Objects.equal(_switchValue,"waiting")) {
        _matched=true;
        _switchResult = "yellow";
      }
    }
    if (!_matched) {
      if (Objects.equal(_switchValue,"accepted")) {
        _matched=true;
        _switchResult = "yellow";
      }
    }
    if (!_matched) {
      if (Objects.equal(_switchValue,"approved")) {
        _matched=true;
        _switchResult = "green";
      }
    }
    if (!_matched) {
      if (Objects.equal(_switchValue,"suspended")) {
        _matched=true;
        _switchResult = "yellow";
      }
    }
    if (!_matched) {
      if (Objects.equal(_switchValue,"archived")) {
        _matched=true;
        _switchResult = "red";
      }
    }
    if (!_matched) {
      if (Objects.equal(_switchValue,"trashed")) {
        _matched=true;
        _switchResult = "red";
      }
    }
    if (!_matched) {
      if (Objects.equal(_switchValue,"deleted")) {
        _matched=true;
        _switchResult = "red";
      }
    }
    if (!_matched) {
      _switchResult = "red";
    }
    return _switchResult;
  }
  
  private CharSequence getStateInfo(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* This method returns information about a certain state.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $state The given state value.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return array|null The corresponding state information.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function getStateInfo($state = \'initial\')");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$result = null;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$stateList = $this->getObjectStates();");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("foreach ($stateList as $singleState) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if ($singleState[\'value\'] != $state) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("continue;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$result = $singleState;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("break;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $result;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence getWorkflowName(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* This method returns the workflow name for a certain object type.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $objectType Name of treated object type.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return string Name of the corresponding workflow.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function getWorkflowName($objectType = \'\')");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$result = \'\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("switch ($objectType) {");
    _builder.newLine();
    {
      EList<Entity> _allEntities = this._modelExtensions.getAllEntities(it);
      for(final Entity entity : _allEntities) {
        _builder.append("        ");
        _builder.append("case \'");
        String _name = entity.getName();
        String _formatForCode = this._formattingExtensions.formatForCode(_name);
        _builder.append(_formatForCode, "        ");
        _builder.append("\':");
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("$result = \'");
        EntityWorkflowType _workflow = entity.getWorkflow();
        String _textualName = this._workflowExtensions.textualName(_workflow);
        _builder.append(_textualName, "            ");
        _builder.append("\';");
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("break;");
        _builder.newLine();
      }
    }
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $result;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence getWorkflowSchema(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* This method returns the workflow schema for a certain object type.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $objectType Name of treated object type.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return array|null The resulting workflow schema");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function getWorkflowSchema($objectType = \'\')");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$schema = null;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$schemaName = $this->getWorkflowName($objectType);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($schemaName != \'\') {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$schema = Zikula_Workflow_Util::loadSchema($schemaName, $this->name);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $schema;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence getActionsForObject(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Retrieve the available actions for a given entity object.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param Zikula_EntityAccess $entity The given entity instance.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return array List of available workflow actions.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function getActionsForObject($entity)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// get possible actions for this object in it\'s current workflow state");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$objectType = $entity[\'_objectType\'];");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$schemaName = $this->getWorkflowName($objectType);");
    _builder.newLine();
    {
      boolean _targets = this._utils.targets(it, "1.3.5");
      boolean _not = (!_targets);
      if (_not) {
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$this->normaliseWorkflowData($entity);");
        _builder.newLine();
      }
    }
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$idcolumn = $entity[\'__WORKFLOW__\'][\'obj_idcolumn\'];");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$wfActions = Zikula_Workflow_Util::getActionsForObject($entity, $objectType, $idcolumn, $this->name);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// as we use the workflows for multiple object types we must maybe filter out some actions");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$listHelper = new ");
    {
      boolean _targets_1 = this._utils.targets(it, "1.3.5");
      if (_targets_1) {
        String _appName = this._utils.appName(it);
        _builder.append(_appName, "    ");
        _builder.append("_Util_ListEntries");
      } else {
        _builder.append("ListEntriesUtil");
      }
    }
    _builder.append("($this->serviceManager");
    {
      boolean _targets_2 = this._utils.targets(it, "1.3.5");
      boolean _not_1 = (!_targets_2);
      if (_not_1) {
        _builder.append(", ModUtil::getModule($this->name)");
      }
    }
    _builder.append(");");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("$states = $listHelper->getEntries($objectType, \'workflowState\');");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$allowedStates = array();");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("foreach ($states as $state) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$allowedStates[] = $state[\'value\'];");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$actions = array();");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("foreach ($wfActions as $actionId => $action) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$nextState = (isset($action[\'nextState\']) ? $action[\'nextState\'] : \'\');");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if ($nextState != \'\' && !in_array($nextState, $allowedStates)) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("continue;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$actions[$actionId] = $action;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$actions[$actionId][\'buttonClass\'] = $this->getButtonClassForAction($actionId);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $actions;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Returns a button class for a certain action.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $actionId Id of the treated action.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected function getButtonClassForAction($actionId)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$buttonClass = \'\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("switch ($actionId) {");
    _builder.newLine();
    {
      boolean _hasWorkflowState = this._workflowExtensions.hasWorkflowState(it, "deferred");
      if (_hasWorkflowState) {
        _builder.append("        ");
        _builder.append("case \'defer\':");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("$buttonClass = \'\';");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("break;");
        _builder.newLine();
      }
    }
    _builder.append("        ");
    _builder.append("case \'submit\':");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$buttonClass = \'ok\';//\'new\';");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("break;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("case \'update\':");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$buttonClass = \'save\';//\'edit\';");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("break;");
    _builder.newLine();
    {
      boolean _hasWorkflowState_1 = this._workflowExtensions.hasWorkflowState(it, "deferred");
      if (_hasWorkflowState_1) {
        _builder.append("        ");
        _builder.append("case \'reject\':");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("$buttonClass = \'\';");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("break;");
        _builder.newLine();
      }
    }
    {
      boolean _hasWorkflowState_2 = this._workflowExtensions.hasWorkflowState(it, "accepted");
      if (_hasWorkflowState_2) {
        _builder.append("        ");
        _builder.append("case \'accept\':");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("$buttonClass = \'ok\';");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("break;");
        _builder.newLine();
      }
    }
    {
      boolean _or = false;
      boolean _hasWorkflow = this._workflowExtensions.hasWorkflow(it, EntityWorkflowType.STANDARD);
      if (_hasWorkflow) {
        _or = true;
      } else {
        boolean _hasWorkflow_1 = this._workflowExtensions.hasWorkflow(it, EntityWorkflowType.ENTERPRISE);
        _or = (_hasWorkflow || _hasWorkflow_1);
      }
      if (_or) {
        _builder.append("        ");
        _builder.append("case \'approve\':");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("$buttonClass = \'ok\';");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("break;");
        _builder.newLine();
      }
    }
    {
      boolean _hasWorkflowState_3 = this._workflowExtensions.hasWorkflowState(it, "accepted");
      if (_hasWorkflowState_3) {
        _builder.append("        ");
        _builder.append("case \'demote\':");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("$buttonClass = \'\';");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("break;");
        _builder.newLine();
      }
    }
    {
      boolean _hasWorkflowState_4 = this._workflowExtensions.hasWorkflowState(it, "suspended");
      if (_hasWorkflowState_4) {
        _builder.append("        ");
        _builder.append("case \'unpublish\':");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("$buttonClass = \'\';//\'filter\';");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("break;");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("case \'publish\':");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("$buttonClass = \'ok\';");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("break;");
        _builder.newLine();
      }
    }
    {
      boolean _hasWorkflowState_5 = this._workflowExtensions.hasWorkflowState(it, "archived");
      if (_hasWorkflowState_5) {
        _builder.append("        ");
        _builder.append("case \'archive\':");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("$buttonClass = \'archive\';");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("break;");
        _builder.newLine();
      }
    }
    {
      boolean _hasWorkflowState_6 = this._workflowExtensions.hasWorkflowState(it, "trashed");
      if (_hasWorkflowState_6) {
        _builder.append("        ");
        _builder.append("case \'trash\':");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("$buttonClass = \'\';");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("break;");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("case \'recover\':");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("$buttonClass = \'ok\';");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("break;");
        _builder.newLine();
      }
    }
    _builder.append("        ");
    _builder.append("case \'delete\':");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$buttonClass = \'delete z-btred\';");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("break;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!empty($buttonClass)) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$buttonClass = \'z-bt-\' . $buttonClass;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $buttonClass;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence executeAction(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Executes a certain workflow action for a given entity object.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param Zikula_EntityAccess $entity   The given entity instance.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string              $actionId Name of action to be executed. ");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return bool False on error or true if everything worked well.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function executeAction($entity, $actionId = \'\')");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$objectType = $entity[\'_objectType\'];");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$schemaName = $this->getWorkflowName($objectType);");
    _builder.newLine();
    {
      boolean _targets = this._utils.targets(it, "1.3.5");
      boolean _not = (!_targets);
      if (_not) {
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$this->normaliseWorkflowData($entity);");
        _builder.newLine();
      }
    }
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$result = Zikula_Workflow_Util::executeAction($schemaName, $entity, $actionId, $objectType, $this->name, $idcolumn);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return ($result !== false);");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence normaliseWorkflowData(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Performs a conversion of the workflow object back to an array.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param Zikula_EntityAccess $entity The given entity instance.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return bool False on error or true if everything worked well.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function normaliseWorkflowData($entity)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$workflow = $entity[\'__WORKFLOW__\'];");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!isset($workflow[0])) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$workflow = $workflow[0];");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!is_object($workflow)) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$entity[\'__WORKFLOW__\'] = array(");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'id\'            => $workflow->getId(),");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'state\'         => $workflow->getState(),");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'obj_table\'     => $workflow->getObjTable(),");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'obj_idcolumn\'  => $workflow->getObjIdcolumn(),");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'obj_id\'        => $workflow->getObjId(),");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'schemaname\'    => $workflow->getSchemaname()");
    _builder.newLine();
    _builder.append("    ");
    _builder.append(");");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence collectAmountOfModerationItems(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Collects amount of moderation items foreach object type.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return array List of collected amounts.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function collectAmountOfModerationItems()");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$amounts = array();");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    final Iterable<Entity> entitiesStandard = this._workflowExtensions.getEntitiesForWorkflow(it, EntityWorkflowType.STANDARD);
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    final Iterable<Entity> entitiesEnterprise = this._workflowExtensions.getEntitiesForWorkflow(it, EntityWorkflowType.ENTERPRISE);
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    final Iterable<Entity> entitiesNotNone = Iterables.<Entity>concat(entitiesStandard, entitiesEnterprise);
    _builder.newLineIfNotEmpty();
    {
      boolean _isEmpty = IterableExtensions.isEmpty(entitiesNotNone);
      if (_isEmpty) {
        _builder.append("    ");
        _builder.append("// nothing required here as no entities use enhanced workflows including approval actions");
        _builder.newLine();
      } else {
        _builder.newLine();
        _builder.append("    ");
        _builder.append("// check if objects are waiting for");
        {
          boolean _isEmpty_1 = IterableExtensions.isEmpty(entitiesEnterprise);
          boolean _not = (!_isEmpty_1);
          if (_not) {
            _builder.append(" acceptance or");
          }
        }
        _builder.append(" approval");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("$state = \'waiting\';");
        _builder.newLine();
        {
          for(final Entity entity : entitiesStandard) {
            _builder.append("    ");
            CharSequence _readAmountForObjectTypeAndState = this.readAmountForObjectTypeAndState(entity, "approval");
            _builder.append(_readAmountForObjectTypeAndState, "    ");
            _builder.newLineIfNotEmpty();
          }
        }
        {
          for(final Entity entity_1 : entitiesEnterprise) {
            _builder.append("    ");
            CharSequence _readAmountForObjectTypeAndState_1 = this.readAmountForObjectTypeAndState(entity_1, "acceptance");
            _builder.append(_readAmountForObjectTypeAndState_1, "    ");
            _builder.newLineIfNotEmpty();
          }
        }
        {
          boolean _isEmpty_2 = IterableExtensions.isEmpty(entitiesEnterprise);
          boolean _not_1 = (!_isEmpty_2);
          if (_not_1) {
            _builder.append("    ");
            _builder.append("// check if objects are waiting for approval");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("$state = \'accepted\';");
            _builder.newLine();
            {
              for(final Entity entity_2 : entitiesEnterprise) {
                _builder.append("    ");
                CharSequence _readAmountForObjectTypeAndState_2 = this.readAmountForObjectTypeAndState(entity_2, "approval");
                _builder.append(_readAmountForObjectTypeAndState_2, "    ");
                _builder.newLineIfNotEmpty();
              }
            }
          }
        }
      }
    }
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $amounts;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence readAmountForObjectTypeAndState(final Entity it, final String requiredAction) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("$objectType = \'");
    String _name = it.getName();
    String _formatForCode = this._formattingExtensions.formatForCode(_name);
    _builder.append(_formatForCode, "");
    _builder.append("\';");
    _builder.newLineIfNotEmpty();
    String _xifexpression = null;
    boolean _equals = Objects.equal(requiredAction, "approval");
    if (_equals) {
      _xifexpression = "ADD";
    } else {
      String _xifexpression_1 = null;
      boolean _equals_1 = Objects.equal(requiredAction, "acceptance");
      if (_equals_1) {
        _xifexpression_1 = "EDIT";
      } else {
        _xifexpression_1 = "MODERATE";
      }
      _xifexpression = _xifexpression_1;
    }
    final String permissionLevel = _xifexpression;
    _builder.newLineIfNotEmpty();
    _builder.append("if (SecurityUtil::checkPermission($modname . \':\' . ucwords($objectType) . \':\', \'::\', ACCESS_");
    _builder.append(permissionLevel, "");
    _builder.append(")) {");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("$amount = $this->getAmountOfModerationItems($objectType, $state);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($amount > 0) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$amounts[] = array(");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("\'aggregateType\' => \'");
    String _nameMultiple = it.getNameMultiple();
    String _formatForCode_1 = this._formattingExtensions.formatForCode(_nameMultiple);
    _builder.append(_formatForCode_1, "            ");
    String _firstUpper = StringExtensions.toFirstUpper(requiredAction);
    _builder.append(_firstUpper, "            ");
    _builder.append("\',");
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    _builder.append("\'description\' => $this->__(\'");
    String _nameMultiple_1 = it.getNameMultiple();
    String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(_nameMultiple_1);
    _builder.append(_formatForCodeCapital, "            ");
    _builder.append(" pending ");
    _builder.append(requiredAction, "            ");
    _builder.append("\'),");
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    _builder.append("\'amount\' => $amount,");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("\'objectType\' => $objectType,");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("\'state\' => $state,");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("\'message\' => $this->_fn(\'One ");
    String _name_1 = it.getName();
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(_name_1);
    _builder.append(_formatForDisplay, "            ");
    _builder.append(" is waiting for ");
    _builder.append(requiredAction, "            ");
    _builder.append(".\', \'%s ");
    String _nameMultiple_2 = it.getNameMultiple();
    String _formatForDisplay_1 = this._formattingExtensions.formatForDisplay(_nameMultiple_2);
    _builder.append(_formatForDisplay_1, "            ");
    _builder.append(" are waiting for ");
    _builder.append(requiredAction, "            ");
    _builder.append(".\', $amount, array($amount))");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append(");");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence getAmountOfModerationItems(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Retrieves the amount of moderation items for a given object type");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* and a certain workflow state.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $objectType Name of treated object type.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $state The given state value.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return integer The affected amount of objects.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function getAmountOfModerationItems($objectType, $state)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    {
      boolean _targets = this._utils.targets(it, "1.3.5");
      if (_targets) {
        _builder.append("    ");
        _builder.append("$entityClass = $this->name . \'_Entity_\' . ucwords($objectType);");
        _builder.newLine();
      } else {
        _builder.append("    ");
        _builder.append("$entityClass = \'\\\\");
        String _vendor = it.getVendor();
        String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(_vendor);
        _builder.append(_formatForCodeCapital, "    ");
        _builder.append("\\\\");
        String _name = it.getName();
        String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(_name);
        _builder.append(_formatForCodeCapital_1, "    ");
        _builder.append("Module\\\\Entity\\\\\' . ucwords($objectType) . \'Entity\';");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("    ");
    _builder.append("$entityManager = $this->serviceManager->getService(\'doctrine.entitymanager\');");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$repository = $entityManager->getRepository($entityClass);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$where = \'tbl.workflowState = \\\'\' . $state . \'\\\'\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$useJoins = false;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$amount = $repository->selectCount($where, $useJoins);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $amount;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence workflowFunctionsImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _targets = this._utils.targets(it, "1.3.5");
      boolean _not = (!_targets);
      if (_not) {
        _builder.append("namespace ");
        String _appNamespace = this._utils.appNamespace(it);
        _builder.append(_appNamespace, "");
        _builder.append("\\Util;");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
        _builder.append("use ");
        String _appNamespace_1 = this._utils.appNamespace(it);
        _builder.append(_appNamespace_1, "");
        _builder.append("\\Util\\Base\\WorkflowUtil as BaseWorkflowUtil;");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
      }
    }
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Utility implementation class for workflow helper methods.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    {
      boolean _targets_1 = this._utils.targets(it, "1.3.5");
      if (_targets_1) {
        _builder.append("class ");
        String _appName = this._utils.appName(it);
        _builder.append(_appName, "");
        _builder.append("_Util_Workflow extends ");
        String _appName_1 = this._utils.appName(it);
        _builder.append(_appName_1, "");
        _builder.append("_Util_Base_Workflow");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("class WorkflowUtil extends BaseWorkflowUtil");
        _builder.newLine();
      }
    }
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// feel free to add your own convenience methods here");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
}
