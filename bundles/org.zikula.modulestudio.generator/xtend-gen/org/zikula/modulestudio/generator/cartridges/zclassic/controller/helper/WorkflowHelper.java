package org.zikula.modulestudio.generator.cartridges.zclassic.controller.helper;

import com.google.common.base.Objects;
import com.google.common.collect.Iterables;
import de.guite.modulestudio.metamodel.Application;
import de.guite.modulestudio.metamodel.Entity;
import de.guite.modulestudio.metamodel.EntityWorkflowType;
import de.guite.modulestudio.metamodel.ListFieldItem;
import java.util.ArrayList;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
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
public class WorkflowHelper {
  @Extension
  private FormattingExtensions _formattingExtensions = new FormattingExtensions();
  
  @Extension
  private ModelExtensions _modelExtensions = new ModelExtensions();
  
  @Extension
  private NamingExtensions _namingExtensions = new NamingExtensions();
  
  @Extension
  private Utils _utils = new Utils();
  
  @Extension
  private WorkflowExtensions _workflowExtensions = new WorkflowExtensions();
  
  /**
   * Entry point for the helper class creation.
   */
  public void generate(final Application it, final IFileSystemAccess fsa) {
    InputOutput.<String>println("Generating helper class for workflows");
    final FileHelper fh = new FileHelper();
    String _appSourceLibPath = this._namingExtensions.getAppSourceLibPath(it);
    String _plus = (_appSourceLibPath + "Helper/WorkflowHelper.php");
    this._namingExtensions.generateClassPair(it, fsa, _plus, 
      fh.phpFileContent(it, this.workflowFunctionsBaseImpl(it)), fh.phpFileContent(it, this.workflowFunctionsImpl(it)));
  }
  
  private CharSequence workflowFunctionsBaseImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("namespace ");
    String _appNamespace = this._utils.appNamespace(it);
    _builder.append(_appNamespace);
    _builder.append("\\Helper\\Base;");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    {
      if (((this._utils.targets(it, "1.5")).booleanValue() || this._workflowExtensions.needsApproval(it))) {
        _builder.append("use Psr\\Log\\LoggerInterface;");
        _builder.newLine();
      }
    }
    {
      Boolean _targets = this._utils.targets(it, "1.5");
      if ((_targets).booleanValue()) {
        _builder.append("use Symfony\\Component\\Workflow\\Registry;");
        _builder.newLine();
      }
    }
    _builder.append("use Zikula\\Common\\Translator\\TranslatorInterface;");
    _builder.newLine();
    _builder.append("use Zikula\\Core\\Doctrine\\EntityAccess;");
    _builder.newLine();
    {
      if (((this._utils.targets(it, "1.5")).booleanValue() || this._workflowExtensions.needsApproval(it))) {
        _builder.append("use Zikula\\PermissionsModule\\Api\\");
        {
          Boolean _targets_1 = this._utils.targets(it, "1.5");
          if ((_targets_1).booleanValue()) {
            _builder.append("ApiInterface\\PermissionApiInterface");
          } else {
            _builder.append("PermissionApi");
          }
        }
        _builder.append(";");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      Boolean _targets_2 = this._utils.targets(it, "1.5");
      if ((_targets_2).booleanValue()) {
        _builder.append("use Zikula\\UsersModule\\Api\\ApiInterface\\CurrentUserApiInterface;");
        _builder.newLine();
      }
    }
    {
      Boolean _targets_3 = this._utils.targets(it, "1.5");
      boolean _not = (!(_targets_3).booleanValue());
      if (_not) {
        _builder.append("use Zikula_Workflow_Util;");
        _builder.newLine();
      }
    }
    {
      if (((this._utils.targets(it, "1.5")).booleanValue() || this._workflowExtensions.needsApproval(it))) {
        _builder.append("use ");
        String _appNamespace_1 = this._utils.appNamespace(it);
        _builder.append(_appNamespace_1);
        _builder.append("\\Entity\\Factory\\");
        String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(it.getName());
        _builder.append(_formatForCodeCapital);
        _builder.append("Factory;");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("use ");
    String _appNamespace_2 = this._utils.appNamespace(it);
    _builder.append(_appNamespace_2);
    _builder.append("\\Helper\\ListEntriesHelper;");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Helper base class for workflow methods.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("abstract class AbstractWorkflowHelper");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    {
      Boolean _targets_4 = this._utils.targets(it, "1.5");
      boolean _not_1 = (!(_targets_4).booleanValue());
      if (_not_1) {
        _builder.append("    ");
        _builder.append("/**");
        _builder.newLine();
        _builder.append("    ");
        _builder.append(" ");
        _builder.append("* Name of the application.");
        _builder.newLine();
        _builder.append("    ");
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append("    ");
        _builder.append(" ");
        _builder.append("* @var string");
        _builder.newLine();
        _builder.append("    ");
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("protected $name;");
        _builder.newLine();
        _builder.newLine();
      }
    }
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @var TranslatorInterface");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("protected $translator;");
    _builder.newLine();
    {
      Boolean _targets_5 = this._utils.targets(it, "1.5");
      if ((_targets_5).booleanValue()) {
        _builder.newLine();
        _builder.append("    ");
        _builder.append("/**");
        _builder.newLine();
        _builder.append("    ");
        _builder.append(" ");
        _builder.append("* @var Registry");
        _builder.newLine();
        _builder.append("    ");
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("protected $workflowRegistry;");
        _builder.newLine();
      }
    }
    {
      if (((this._utils.targets(it, "1.5")).booleanValue() || this._workflowExtensions.needsApproval(it))) {
        _builder.newLine();
        _builder.append("    ");
        _builder.append("/**");
        _builder.newLine();
        _builder.append("    ");
        _builder.append(" ");
        _builder.append("* @var LoggerInterface");
        _builder.newLine();
        _builder.append("    ");
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("protected $logger;");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("/**");
        _builder.newLine();
        _builder.append("    ");
        _builder.append(" ");
        _builder.append("* @var PermissionApi");
        {
          Boolean _targets_6 = this._utils.targets(it, "1.5");
          if ((_targets_6).booleanValue()) {
            _builder.append("Interface");
          }
        }
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("protected $permissionApi;");
        _builder.newLine();
        {
          Boolean _targets_7 = this._utils.targets(it, "1.5");
          if ((_targets_7).booleanValue()) {
            _builder.newLine();
            _builder.append("    ");
            _builder.append("/**");
            _builder.newLine();
            _builder.append("    ");
            _builder.append(" ");
            _builder.append("* @var CurrentUserApiInterface");
            _builder.newLine();
            _builder.append("    ");
            _builder.append(" ");
            _builder.append("*/");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("private $currentUserApi;");
            _builder.newLine();
          }
        }
        _builder.newLine();
        _builder.append("    ");
        _builder.append("/**");
        _builder.newLine();
        _builder.append("    ");
        _builder.append(" ");
        _builder.append("* @var ");
        String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(it.getName());
        _builder.append(_formatForCodeCapital_1, "     ");
        _builder.append("Factory");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("protected $entityFactory;");
        _builder.newLine();
      }
    }
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @var ListEntriesHelper");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("protected $listEntriesHelper;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* WorkflowHelper constructor.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @param TranslatorInterface $translator        Translator service instance");
    _builder.newLine();
    {
      Boolean _targets_8 = this._utils.targets(it, "1.5");
      if ((_targets_8).booleanValue()) {
        _builder.append("     ");
        _builder.append("* @param Registry            $registry          Workflow registry service instance");
        _builder.newLine();
      }
    }
    {
      if (((this._utils.targets(it, "1.5")).booleanValue() || this._workflowExtensions.needsApproval(it))) {
        _builder.append("     ");
        _builder.append("* @param LoggerInterface     $logger            Logger service instance");
        _builder.newLine();
        _builder.append("     ");
        _builder.append("* @param PermissionApi");
        {
          Boolean _targets_9 = this._utils.targets(it, "1.5");
          if ((_targets_9).booleanValue()) {
            _builder.append("Interface");
          }
        }
        _builder.append("       $permissionApi     PermissionApi service instance");
        _builder.newLineIfNotEmpty();
        {
          Boolean _targets_10 = this._utils.targets(it, "1.5");
          if ((_targets_10).booleanValue()) {
            _builder.append("     ");
            _builder.append("* @param CurrentUserApiInterface $currentUserApi    CurrentUserApi service instance");
            _builder.newLine();
          }
        }
        _builder.append("     ");
        _builder.append("* @param ");
        String _formatForCodeCapital_2 = this._formattingExtensions.formatForCodeCapital(it.getName());
        _builder.append(_formatForCodeCapital_2, "     ");
        _builder.append("Factory $entityFactory ");
        String _formatForCodeCapital_3 = this._formattingExtensions.formatForCodeCapital(it.getName());
        _builder.append(_formatForCodeCapital_3, "     ");
        _builder.append("Factory service instance");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("     ");
    _builder.append("* @param ListEntriesHelper   $listEntriesHelper ListEntriesHelper service instance");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @return void");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("public function __construct(");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("TranslatorInterface $translator,");
    _builder.newLine();
    {
      Boolean _targets_11 = this._utils.targets(it, "1.5");
      if ((_targets_11).booleanValue()) {
        _builder.append("        ");
        _builder.append("Registry $registry,");
        _builder.newLine();
      }
    }
    {
      if (((this._utils.targets(it, "1.5")).booleanValue() || this._workflowExtensions.needsApproval(it))) {
        _builder.append("        ");
        _builder.append("LoggerInterface $logger,");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("PermissionApi");
        {
          Boolean _targets_12 = this._utils.targets(it, "1.5");
          if ((_targets_12).booleanValue()) {
            _builder.append("Interface");
          }
        }
        _builder.append(" $permissionApi,");
        _builder.newLineIfNotEmpty();
        {
          Boolean _targets_13 = this._utils.targets(it, "1.5");
          if ((_targets_13).booleanValue()) {
            _builder.append("        ");
            _builder.append("CurrentUserApiInterface $currentUserApi,");
            _builder.newLine();
          }
        }
        _builder.append("        ");
        String _formatForCodeCapital_4 = this._formattingExtensions.formatForCodeCapital(it.getName());
        _builder.append(_formatForCodeCapital_4, "        ");
        _builder.append("Factory $entityFactory,");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("        ");
    _builder.append("ListEntriesHelper $listEntriesHelper");
    _builder.newLine();
    _builder.append("    ");
    _builder.append(") {");
    _builder.newLine();
    {
      Boolean _targets_14 = this._utils.targets(it, "1.5");
      boolean _not_2 = (!(_targets_14).booleanValue());
      if (_not_2) {
        _builder.append("        ");
        _builder.append("$this->name = \'");
        String _appName = this._utils.appName(it);
        _builder.append(_appName, "        ");
        _builder.append("\';");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("        ");
    _builder.append("$this->translator = $translator;");
    _builder.newLine();
    {
      Boolean _targets_15 = this._utils.targets(it, "1.5");
      if ((_targets_15).booleanValue()) {
        _builder.append("        ");
        _builder.append("$this->workflowRegistry = $registry;");
        _builder.newLine();
      }
    }
    {
      if (((this._utils.targets(it, "1.5")).booleanValue() || this._workflowExtensions.needsApproval(it))) {
        _builder.append("        ");
        _builder.append("$this->logger = $logger;");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("$this->permissionApi = $permissionApi;");
        _builder.newLine();
        {
          Boolean _targets_16 = this._utils.targets(it, "1.5");
          if ((_targets_16).booleanValue()) {
            _builder.append("        ");
            _builder.append("$this->currentUserApi = $currentUserApi;");
            _builder.newLine();
          }
        }
        _builder.append("        ");
        _builder.append("$this->entityFactory = $entityFactory;");
        _builder.newLine();
      }
    }
    _builder.append("        ");
    _builder.append("$this->listEntriesHelper = $listEntriesHelper;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    CharSequence _objectStates = this.getObjectStates(it);
    _builder.append(_objectStates, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    CharSequence _stateInfo = this.getStateInfo(it);
    _builder.append(_stateInfo, "    ");
    _builder.newLineIfNotEmpty();
    {
      Boolean _targets_17 = this._utils.targets(it, "1.5");
      boolean _not_3 = (!(_targets_17).booleanValue());
      if (_not_3) {
        _builder.append("    ");
        CharSequence _workflowName = this.getWorkflowName(it);
        _builder.append(_workflowName, "    ");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("    ");
    CharSequence _actionsForObject = this.getActionsForObject(it);
    _builder.append(_actionsForObject, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    CharSequence _executeAction = this.executeAction(it);
    _builder.append(_executeAction, "    ");
    _builder.newLineIfNotEmpty();
    {
      Boolean _targets_18 = this._utils.targets(it, "1.5");
      boolean _not_4 = (!(_targets_18).booleanValue());
      if (_not_4) {
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
    _builder.append("* @return array List of collected state information");
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
    _builder.append("$states = [];");
    _builder.newLine();
    _builder.append("     ");
    final ArrayList<ListFieldItem> states = this._workflowExtensions.getRequiredStateList(it);
    _builder.newLineIfNotEmpty();
    {
      for(final ListFieldItem state : states) {
        _builder.append("     ");
        CharSequence _stateInfo = this.stateInfo(it, state);
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
  
  private CharSequence stateInfo(final Application it, final ListFieldItem item) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("$states[] = [");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("\'value\' => \'");
    String _value = item.getValue();
    _builder.append(_value, "    ");
    _builder.append("\',");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("\'text\' => $this->translator->__(\'");
    String _name = item.getName();
    _builder.append(_name, "    ");
    _builder.append("\'),");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("\'ui\' => \'");
    String _uiFeedback = this.uiFeedback(it, item);
    _builder.append(_uiFeedback, "    ");
    _builder.append("\'");
    _builder.newLineIfNotEmpty();
    _builder.append("];");
    _builder.newLine();
    return _builder;
  }
  
  private String uiFeedback(final Application it, final ListFieldItem item) {
    return this.stateLabel(item);
  }
  
  private String stateLabel(final ListFieldItem it) {
    String _switchResult = null;
    String _value = it.getValue();
    if (_value != null) {
      switch (_value) {
        case "initial":
          _switchResult = "danger";
          break;
        case "deferred":
          _switchResult = "danger";
          break;
        case "waiting":
          _switchResult = "warning";
          break;
        case "accepted":
          _switchResult = "warning";
          break;
        case "approved":
          _switchResult = "success";
          break;
        case "suspended":
          _switchResult = "primary";
          break;
        case "archived":
          _switchResult = "info";
          break;
        case "trashed":
          _switchResult = "danger";
          break;
        case "deleted":
          _switchResult = "danger";
          break;
        default:
          _switchResult = "default";
          break;
      }
    } else {
      _switchResult = "default";
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
    _builder.append("* @param string $state The given state value");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return array|null The corresponding state information");
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
    _builder.append("* @param string $objectType Name of treated object type");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return string Name of the corresponding workflow");
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
      Iterable<Entity> _allEntities = this._modelExtensions.getAllEntities(it);
      for(final Entity entity : _allEntities) {
        _builder.append("        ");
        _builder.append("case \'");
        String _formatForCode = this._formattingExtensions.formatForCode(entity.getName());
        _builder.append(_formatForCode, "        ");
        _builder.append("\':");
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("$result = \'");
        String _textualName = this._workflowExtensions.textualName(entity.getWorkflow());
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
    _builder.append("* @param EntityAccess $entity The given entity instance");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return array List of available workflow actions");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function getActionsForObject($entity)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    {
      Boolean _targets = this._utils.targets(it, "1.5");
      if ((_targets).booleanValue()) {
        _builder.append("    ");
        _builder.append("$workflow = $this->workflowRegistry->get($entity);");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$wfActions = $workflow->getEnabledTransitions($entity);");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$currentState = $entity->getWorkflowState();");
        _builder.newLine();
      } else {
        _builder.append("    ");
        _builder.append("// get possible actions for this object in it\'s current workflow state");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$objectType = $entity[\'_objectType\'];");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$this->normaliseWorkflowData($entity);");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$idColumn = $entity[\'__WORKFLOW__\'][\'obj_idcolumn\'];");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$wfActions = Zikula_Workflow_Util::getActionsForObject($entity, $objectType, $idColumn, $this->name);");
        _builder.newLine();
      }
    }
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// as we use the workflows for multiple object types we must maybe filter out some actions");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$states = $this->listEntriesHelper->getEntries(");
    {
      Boolean _targets_1 = this._utils.targets(it, "1.5");
      if ((_targets_1).booleanValue()) {
        _builder.append("$entity->get_objectType()");
      } else {
        _builder.append("$objectType");
      }
    }
    _builder.append(", \'workflowState\');");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("$allowedStates = [];");
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
    _builder.append("$actions = [];");
    _builder.newLine();
    {
      Boolean _targets_2 = this._utils.targets(it, "1.5");
      if ((_targets_2).booleanValue()) {
        _builder.append("    ");
        _builder.append("foreach ($wfActions as $action) {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("$actionId = $action->getName();");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("$actions[$actionId] = [");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("        ");
        _builder.append("\'id\' => $actionId,");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("        ");
        _builder.append("\'title\' => $this->getTitleForAction($currentState, $actionId),");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("        ");
        _builder.append("\'buttonClass\' => $this->getButtonClassForAction($actionId)");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("];");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
      } else {
        _builder.append("    ");
        _builder.append("foreach ($wfActions as $actionId => $action) {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("$nextState = isset($action[\'nextState\']) ? $action[\'nextState\'] : \'\';");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("if (!in_array($nextState, [\'\', \'deleted\']) && !in_array($nextState, $allowedStates)) {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("        ");
        _builder.append("continue;");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("$actions[$actionId] = $action;");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("$actions[$actionId][\'buttonClass\'] = $this->getButtonClassForAction($actionId);");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
      }
    }
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $actions;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    {
      Boolean _targets_3 = this._utils.targets(it, "1.5");
      if ((_targets_3).booleanValue()) {
        _builder.newLine();
        _builder.append("/**");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Returns a translatable title for a certain action.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @param string $currentState Current state of the entity");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @param string $actionId     Id of the treated action");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @return string The action title");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
        _builder.append("protected function getTitleForAction($currentState, $actionId)");
        _builder.newLine();
        _builder.append("{");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$title = \'\';");
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
            _builder.append("$title = $this->translator->__(\'Defer\');");
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
        _builder.append("$title = $this->translator->__(\'Submit\');");
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
            _builder.append("$title = $this->translator->__(\'Reject\');");
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
            _builder.append("$title = $currentState == \'initial\' ? $this->translator->__(\'Submit and accept\') : $this->translator->__(\'Accept\');");
            _builder.newLine();
            _builder.append("        ");
            _builder.append("    ");
            _builder.append("break;");
            _builder.newLine();
          }
        }
        {
          if ((this._workflowExtensions.hasWorkflow(it, EntityWorkflowType.STANDARD) || this._workflowExtensions.hasWorkflow(it, EntityWorkflowType.ENTERPRISE))) {
            _builder.append("        ");
            _builder.append("case \'approve\':");
            _builder.newLine();
            _builder.append("        ");
            _builder.append("    ");
            _builder.append("$title = $currentState == \'initial\' ? $this->translator->__(\'Submit and approve\') : $this->translator->__(\'Approve\');");
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
            _builder.append("$title = $this->translator->__(\'Demote\');");
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
            _builder.append("$title = $this->translator->__(\'Unpublish\');");
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
            _builder.append("$title = $this->translator->__(\'Publish\');");
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
            _builder.append("$title = $this->translator->__(\'Archive\');");
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
            _builder.append("$title = $this->translator->__(\'Trash\');");
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
            _builder.append("$title = $this->translator->__(\'Recover\');");
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
        _builder.append("$title = $this->translator->__(\'Delete\');");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("break;");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("if ($title == \'\' && substr($actionId, 0, 6) == \'update\') {");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("$title = $this->translator->__(\'Update\');");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("return $title;");
        _builder.newLine();
        _builder.append("}");
        _builder.newLine();
      }
    }
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
    _builder.append("* @param string $actionId Id of the treated action");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return string The button class");
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
      boolean _hasWorkflowState_7 = this._workflowExtensions.hasWorkflowState(it, "deferred");
      if (_hasWorkflowState_7) {
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
    _builder.append("$buttonClass = \'success\';");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("break;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("case \'update\':");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$buttonClass = \'success\';");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("break;");
    _builder.newLine();
    {
      boolean _hasWorkflowState_8 = this._workflowExtensions.hasWorkflowState(it, "deferred");
      if (_hasWorkflowState_8) {
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
      boolean _hasWorkflowState_9 = this._workflowExtensions.hasWorkflowState(it, "accepted");
      if (_hasWorkflowState_9) {
        _builder.append("        ");
        _builder.append("case \'accept\':");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("$buttonClass = \'default\';");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("break;");
        _builder.newLine();
      }
    }
    {
      if ((this._workflowExtensions.hasWorkflow(it, EntityWorkflowType.STANDARD) || this._workflowExtensions.hasWorkflow(it, EntityWorkflowType.ENTERPRISE))) {
        _builder.append("        ");
        _builder.append("case \'approve\':");
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
      boolean _hasWorkflowState_10 = this._workflowExtensions.hasWorkflowState(it, "accepted");
      if (_hasWorkflowState_10) {
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
      boolean _hasWorkflowState_11 = this._workflowExtensions.hasWorkflowState(it, "suspended");
      if (_hasWorkflowState_11) {
        _builder.append("        ");
        _builder.append("case \'unpublish\':");
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
        _builder.append("case \'publish\':");
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
      boolean _hasWorkflowState_12 = this._workflowExtensions.hasWorkflowState(it, "archived");
      if (_hasWorkflowState_12) {
        _builder.append("        ");
        _builder.append("case \'archive\':");
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
      boolean _hasWorkflowState_13 = this._workflowExtensions.hasWorkflowState(it, "trashed");
      if (_hasWorkflowState_13) {
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
        _builder.append("$buttonClass = \'\';");
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
    _builder.append("$buttonClass = \'danger\';");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("break;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (empty($buttonClass)) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$buttonClass = \'default\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return \'btn btn-\' . $buttonClass;");
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
    _builder.append("* @param EntityAccess $entity    The given entity instance");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string       $actionId  Name of action to be executed");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param bool         $recursive True if the function called itself");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return bool False on error or true if everything worked well");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function executeAction($entity, $actionId = \'\', $recursive = false)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    {
      Boolean _targets = this._utils.targets(it, "1.5");
      if ((_targets).booleanValue()) {
        _builder.append("    ");
        _builder.append("$workflow = $this->workflowRegistry->get($entity);");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("if (!$workflow->can($entity, $actionId)) {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("return false;");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("// get entity manager");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$entityManager = $this->entityFactory->getObjectManager();");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$logArgs = [\'app\' => \'");
        String _appName = this._utils.appName(it);
        _builder.append(_appName, "    ");
        _builder.append("\', \'user\' => $this->currentUserApi->get(\'uname\')];");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$result = false;");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("try {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("$workflow->apply($entity, $actionId);");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("//$entityManager->transactional(function($entityManager) {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("if ($actionId == \'delete\') {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("        ");
        _builder.append("$entityManager->remove($entity);");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("} else {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("        ");
        _builder.append("$entityManager->persist($entity);");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("$entityManager->flush();");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("//});");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("$result = true;");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("if ($actionId == \'delete\') {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("        ");
        _builder.append("$this->logger->notice(\'{app}: User {user} deleted an entity.\', $logArgs);");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("} else {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("        ");
        _builder.append("$this->logger->notice(\'{app}: User {user} updated an entity.\', $logArgs);");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("} catch (\\Exception $e) {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("if ($actionId == \'delete\') {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("        ");
        _builder.append("$this->logger->error(\'{app}: User {user} tried to delete an entity, but failed.\', $logArgs);");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("} else {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("        ");
        _builder.append("$this->logger->error(\'{app}: User {user} tried to update an entity, but failed.\', $logArgs);");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("throw new \\RuntimeException($e->getMessage());");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
      } else {
        _builder.append("    ");
        _builder.append("$objectType = $entity[\'_objectType\'];");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$schemaName = $this->getWorkflowName($objectType);");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$entity->initWorkflow(true);");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$idColumn = $entity[\'__WORKFLOW__\'][\'obj_idcolumn\'];");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$this->normaliseWorkflowData($entity);");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$result = Zikula_Workflow_Util::executeAction($schemaName, $entity, $actionId, $objectType, \'");
        String _appName_1 = this._utils.appName(it);
        _builder.append(_appName_1, "    ");
        _builder.append("\', $idColumn);");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (false !== $result && !$recursive) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$entities = $entity->getRelatedObjectsToPersist();");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("foreach ($entities as $rel) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("if ($rel->getWorkflowState() == \'initial\') {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("$this->executeAction($rel, $actionId, true);");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return (false !== $result);");
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
    _builder.append("* @param EntityAccess $entity The given entity instance (excplicitly assigned by reference as form handlers use arrays)");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return bool False on error or true if everything worked well");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function normaliseWorkflowData(&$entity)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$workflow = $entity[\'__WORKFLOW__\'];");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!isset($workflow[0]) && isset($workflow[\'module\'])) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return true;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (isset($workflow[0])) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$workflow = $workflow[0];");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!is_object($workflow)) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$workflow[\'module\'] = \'");
    String _appName = this._utils.appName(it);
    _builder.append(_appName, "        ");
    _builder.append("\';");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("$entity[\'__WORKFLOW__\'] = $workflow;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return true;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$entity[\'__WORKFLOW__\'] = [");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'module\'        => \'");
    String _appName_1 = this._utils.appName(it);
    _builder.append(_appName_1, "        ");
    _builder.append("\',");
    _builder.newLineIfNotEmpty();
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
    _builder.append("];");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return true;");
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
    _builder.append("* @return array List of collected amounts");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function collectAmountOfModerationItems()");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$amounts = [];");
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
    String _formatForCode = this._formattingExtensions.formatForCode(it.getName());
    _builder.append(_formatForCode);
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
    _builder.append("if ($this->permissionApi->hasPermission(\'");
    String _appName = this._utils.appName(it.getApplication());
    _builder.append(_appName);
    _builder.append(":\' . ucfirst($objectType) . \':\', \'::\', ACCESS_");
    _builder.append(permissionLevel);
    _builder.append(")) {");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("$amount = $this->getAmountOfModerationItems($objectType, $state);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($amount > 0) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$amounts[] = [");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("\'aggregateType\' => \'");
    String _formatForCode_1 = this._formattingExtensions.formatForCode(it.getNameMultiple());
    _builder.append(_formatForCode_1, "            ");
    String _firstUpper = StringExtensions.toFirstUpper(requiredAction);
    _builder.append(_firstUpper, "            ");
    _builder.append("\',");
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    _builder.append("\'description\' => $this->translator->__(\'");
    String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(it.getNameMultiple());
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
    _builder.append("\'message\' => $this->translator->_fn(\'One ");
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(it.getName());
    _builder.append(_formatForDisplay, "            ");
    _builder.append(" is waiting for ");
    _builder.append(requiredAction, "            ");
    _builder.append(".\', \'%amount% ");
    String _formatForDisplay_1 = this._formattingExtensions.formatForDisplay(it.getNameMultiple());
    _builder.append(_formatForDisplay_1, "            ");
    _builder.append(" are waiting for ");
    _builder.append(requiredAction, "            ");
    _builder.append(".\', $amount, [\'%amount%\' => $amount])");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("];");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$this->logger->info(\'{app}: There are {amount} {entities} waiting for approval.\', [\'app\' => \'");
    String _appName_1 = this._utils.appName(it.getApplication());
    _builder.append(_appName_1, "        ");
    _builder.append("\', \'amount\' => $amount, \'entities\' => \'");
    String _formatForDisplay_2 = this._formattingExtensions.formatForDisplay(it.getNameMultiple());
    _builder.append(_formatForDisplay_2, "        ");
    _builder.append("\']);");
    _builder.newLineIfNotEmpty();
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
    _builder.append("* @param string $objectType Name of treated object type");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $state The given state value");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return integer The affected amount of objects");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function getAmountOfModerationItems($objectType, $state)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$repository = $this->entityFactory->getRepository($objectType);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$where = \'tbl.workflowState:eq:\' . $state;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$parameters = [\'workflowState\' => $state];");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $repository->selectCount($where, false, $parameters);");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence workflowFunctionsImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("namespace ");
    String _appNamespace = this._utils.appNamespace(it);
    _builder.append(_appNamespace);
    _builder.append("\\Helper;");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("use ");
    String _appNamespace_1 = this._utils.appNamespace(it);
    _builder.append(_appNamespace_1);
    _builder.append("\\Helper\\Base\\AbstractWorkflowHelper;");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Helper implementation class for workflow methods.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("class WorkflowHelper extends AbstractWorkflowHelper");
    _builder.newLine();
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
