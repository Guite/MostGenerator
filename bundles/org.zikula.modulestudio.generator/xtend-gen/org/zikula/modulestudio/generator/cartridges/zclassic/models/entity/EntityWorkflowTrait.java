package org.zikula.modulestudio.generator.cartridges.zclassic.models.entity;

import de.guite.modulestudio.metamodel.Application;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.GeneratorSettingsExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;
import org.zikula.modulestudio.generator.extensions.WorkflowExtensions;

@SuppressWarnings("all")
public class EntityWorkflowTrait {
  @Extension
  private FormattingExtensions _formattingExtensions = new FormattingExtensions();
  
  @Extension
  private GeneratorSettingsExtensions _generatorSettingsExtensions = new GeneratorSettingsExtensions();
  
  @Extension
  private NamingExtensions _namingExtensions = new NamingExtensions();
  
  @Extension
  private Utils _utils = new Utils();
  
  @Extension
  private WorkflowExtensions _workflowExtensions = new WorkflowExtensions();
  
  private FileHelper fh = new FileHelper();
  
  public void generate(final Application it, final IFileSystemAccess fsa) {
    Boolean _targets = this._utils.targets(it, "1.5");
    if ((_targets).booleanValue()) {
      return;
    }
    String _appSourceLibPath = this._namingExtensions.getAppSourceLibPath(it);
    final String filePath = (_appSourceLibPath + "Traits/EntityWorkflowTrait.php");
    boolean _shouldBeSkipped = this._namingExtensions.shouldBeSkipped(it, filePath);
    boolean _not = (!_shouldBeSkipped);
    if (_not) {
      boolean _shouldBeMarked = this._namingExtensions.shouldBeMarked(it, filePath);
      if (_shouldBeMarked) {
        fsa.generateFile(filePath.replace(".php", ".generated.php"), this.fh.phpFileContent(it, this.traitFile(it)));
      } else {
        fsa.generateFile(filePath, this.fh.phpFileContent(it, this.traitFile(it)));
      }
    }
  }
  
  private CharSequence traitFile(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("namespace ");
    String _appNamespace = this._utils.appNamespace(it);
    _builder.append(_appNamespace);
    _builder.append("\\Traits;");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("use ServiceUtil;");
    _builder.newLine();
    _builder.append("use Zikula_Workflow_Util;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Workflow trait implementation class.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("trait EntityWorkflowTrait");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    CharSequence _traitImpl = this.traitImpl(it);
    _builder.append(_traitImpl, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence traitImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @var array The current workflow data of this object");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected $__WORKFLOW__ = [];");
    _builder.newLine();
    _builder.newLine();
    CharSequence _terAndSetterMethods = this.fh.getterAndSetterMethods(it, "__WORKFLOW__", "array", Boolean.valueOf(false), Boolean.valueOf(true), Boolean.valueOf(true), "[]", "");
    _builder.append(_terAndSetterMethods);
    _builder.newLineIfNotEmpty();
    CharSequence _workflowIdColumn = this.getWorkflowIdColumn(it);
    _builder.append(_workflowIdColumn);
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    CharSequence _initWorkflow = this.initWorkflow(it);
    _builder.append(_initWorkflow);
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    CharSequence _resetWorkflow = this.resetWorkflow(it);
    _builder.append(_resetWorkflow);
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence getWorkflowIdColumn(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Returns the name of the primary identifier field.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* For entities with composite keys the first identifier field is used.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return string Identifier field name");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function getWorkflowIdColumn()");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$entityClass = \'");
    String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(it.getVendor());
    _builder.append(_formatForCodeCapital, "    ");
    String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital_1, "    ");
    _builder.append("Module:\' . ucfirst($this->get_objectType()) . \'Entity\';");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$entityManager = ServiceUtil::get(\'");
    String _entityManagerService = this._namingExtensions.entityManagerService(it);
    _builder.append(_entityManagerService, "    ");
    _builder.append("\');");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("$meta = $entityManager->getClassMetadata($entityClass);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $meta->getSingleIdentifierFieldName();");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence initWorkflow(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Sets/retrieves the workflow details.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param boolean $forceLoading load the workflow record");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @throws RuntimeException Thrown if retrieving the workflow object fails");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function initWorkflow($forceLoading = false)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$request = ServiceUtil::get(\'request_stack\')->getCurrentRequest();");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$routeName = $request->get(\'_route\');");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$loadingRequired = false !== strpos($routeName, \'edit\') || false !== strpos($routeName, \'delete\');");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$isReuse = $request->query->getBoolean(\'astemplate\', false);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    CharSequence _loadWorkflow = this.loadWorkflow(it);
    _builder.append(_loadWorkflow, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence loadWorkflow(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("$container = ServiceUtil::get(\'service_container\');");
    _builder.newLine();
    _builder.append("$translator = $container->get(\'translator.default\');");
    _builder.newLine();
    {
      int _amountOfExampleRows = this._generatorSettingsExtensions.amountOfExampleRows(it);
      boolean _greaterThan = (_amountOfExampleRows > 0);
      if (_greaterThan) {
        {
          boolean _needsApproval = this._workflowExtensions.needsApproval(it);
          if (_needsApproval) {
            _builder.append("$logger = $container->get(\'logger\');");
            _builder.newLine();
            _builder.append("$permissionApi = $container->get(\'zikula_permissions_module.api.permission\');");
            _builder.newLine();
            _builder.append("$entityFactory = $container->get(\'");
            String _appService = this._utils.appService(it);
            _builder.append(_appService);
            _builder.append(".entity_factory\');");
            _builder.newLineIfNotEmpty();
          }
        }
        _builder.append("$listEntriesHelper = $container->get(\'");
        String _appService_1 = this._utils.appService(it);
        _builder.append(_appService_1);
        _builder.append(".listentries_helper\');");
        _builder.newLineIfNotEmpty();
        _builder.append("$workflowHelper = new \\");
        String _appNamespace = this._utils.appNamespace(it);
        _builder.append(_appNamespace);
        _builder.append("\\Helper\\WorkflowHelper($translator");
        {
          boolean _needsApproval_1 = this._workflowExtensions.needsApproval(it);
          if (_needsApproval_1) {
            _builder.append(", $logger, $permissionApi, $entityFactory");
          }
        }
        _builder.append(", $listEntriesHelper);");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("$workflowHelper = $container->get(\'");
        String _appService_2 = this._utils.appService(it);
        _builder.append(_appService_2);
        _builder.append(".workflow_helper\');");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.newLine();
    _builder.append("$objectType = $this->get_objectType();");
    _builder.newLine();
    _builder.append("$idColumn = $this->getWorkflowIdColumn();");
    _builder.newLine();
    _builder.newLine();
    _builder.append("// apply workflow with most important information");
    _builder.newLine();
    _builder.append("$schemaName = $workflowHelper->getWorkflowName($objectType);");
    _builder.newLine();
    _builder.append("$this[\'__WORKFLOW__\'] = [");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("\'module\' => \'");
    String _appName = this._utils.appName(it);
    _builder.append(_appName, "    ");
    _builder.append("\',");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("\'state\' => $this->getWorkflowState(),");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("\'obj_table\' => $objectType,");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("\'obj_idcolumn\' => $idColumn,");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("\'obj_id\' => $this[$idColumn],");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("\'schemaname\' => $schemaName");
    _builder.newLine();
    _builder.append("];");
    _builder.newLine();
    _builder.newLine();
    _builder.append("// load the real workflow only when required (e. g. when func is edit or delete)");
    _builder.newLine();
    _builder.append("if (($loadingRequired && !$isReuse) || $forceLoading) {");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$result = Zikula_Workflow_Util::getWorkflowForObject($this, $objectType, $idColumn, \'");
    String _appName_1 = this._utils.appName(it);
    _builder.append(_appName_1, "    ");
    _builder.append("\');");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("if (!$result) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$flashBag = $container->get(\'session\')->getFlashBag();");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$flashBag->add(\'error\', $translator->__(\'Error! Could not load the associated workflow.\'));");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("if (!is_object($this[\'__WORKFLOW__\']) && !isset($this[\'__WORKFLOW__\'][\'schemaname\'])) {");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$workflow = $this[\'__WORKFLOW__\'];");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$workflow[\'schemaname\'] = $schemaName;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$this[\'__WORKFLOW__\'] = $workflow;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence resetWorkflow(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Resets workflow data back to initial state.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* This is for example used during cloning an entity object.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function resetWorkflow()");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$this->setWorkflowState(\'initial\');");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$workflowHelper = ServiceUtil::get(\'");
    String _appService = this._utils.appService(it);
    _builder.append(_appService, "    ");
    _builder.append(".workflow_helper\');");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$schemaName = $workflowHelper->getWorkflowName($this->get_objectType());");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$this[\'__WORKFLOW__\'] = [");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'module\' => \'");
    String _appName = this._utils.appName(it);
    _builder.append(_appName, "        ");
    _builder.append("\',");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("\'state\' => $this->getWorkflowState(),");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'obj_table\' => $this->get_objectType(),");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'obj_idcolumn\' => $this->getWorkflowIdColumn(),");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'obj_id\' => 0,");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'schemaname\' => $schemaName");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("];");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
}
