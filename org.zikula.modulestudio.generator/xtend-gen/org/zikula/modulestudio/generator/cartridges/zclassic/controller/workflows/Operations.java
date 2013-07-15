package org.zikula.modulestudio.generator.cartridges.zclassic.controller.workflows;

import com.google.common.base.Objects;
import com.google.inject.Inject;
import de.guite.modulestudio.metamodel.modulestudio.Application;
import de.guite.modulestudio.metamodel.modulestudio.EntityWorkflowType;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;
import org.zikula.modulestudio.generator.extensions.WorkflowExtensions;

/**
 * Workflow operations.
 */
@SuppressWarnings("all")
public class Operations {
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
  
  @Inject
  @Extension
  private Utils _utils = new Function0<Utils>() {
    public Utils apply() {
      Utils _utils = new Utils();
      return _utils;
    }
  }.apply();
  
  private Application app;
  
  private IFileSystemAccess fsa;
  
  private String outputPath;
  
  private FileHelper fh = new Function0<FileHelper>() {
    public FileHelper apply() {
      FileHelper _fileHelper = new FileHelper();
      return _fileHelper;
    }
  }.apply();
  
  /**
   * Entry point for workflow operations.
   */
  public void generate(final Application it, final IFileSystemAccess fsa) {
    this.app = it;
    this.fsa = fsa;
    String _appSourcePath = this._namingExtensions.getAppSourcePath(it);
    String _plus = (_appSourcePath + "workflows/operations/");
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
    this.operation("update");
    this.operation("delete");
  }
  
  private void operation(final String opName) {
    String _plus = (this.outputPath + "function.");
    String _plus_1 = (_plus + opName);
    String _plus_2 = (_plus_1 + ".php");
    CharSequence _operationFile = this.operationFile(opName);
    this.fsa.generateFile(_plus_2, _operationFile);
  }
  
  private CharSequence operationFile(final String opName) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _phpFileHeader = this.fh.phpFileHeader(this.app);
    _builder.append(_phpFileHeader, "");
    _builder.newLineIfNotEmpty();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* ");
    String _formatForDisplayCapital = this._formattingExtensions.formatForDisplayCapital(opName);
    _builder.append(_formatForDisplayCapital, " ");
    _builder.append(" operation.");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("* @param object $entity The treated object.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param array  $params Additional arguments.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return bool False on failure or true if everything worked well.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("function ");
    String _appName = this._utils.appName(this.app);
    _builder.append(_appName, "");
    _builder.append("_operation_");
    _builder.append(opName, "");
    _builder.append("(&$entity, $params)");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$dom = ZLanguage::getModuleDomain(\'");
    String _appName_1 = this._utils.appName(this.app);
    _builder.append(_appName_1, "    ");
    _builder.append("\');");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// initialise the result flag");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$result = false;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    CharSequence _operationImpl = this.operationImpl(opName);
    _builder.append(_operationImpl, "    ");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// return result of this operation");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $result;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence operationImpl(final String opName) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _equals = Objects.equal(opName, "update");
      if (_equals) {
        CharSequence _updateImpl = this.updateImpl();
        _builder.append(_updateImpl, "");
        _builder.newLineIfNotEmpty();
      } else {
        boolean _equals_1 = Objects.equal(opName, "delete");
        if (_equals_1) {
          CharSequence _deleteImpl = this.deleteImpl();
          _builder.append(_deleteImpl, "");
          _builder.newLineIfNotEmpty();
        }
      }
    }
    return _builder;
  }
  
  private CharSequence updateImpl() {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("$objectType = $entity[\'_objectType\'];");
    _builder.newLine();
    _builder.append("$currentState = $entity[\'workflowState\'];");
    _builder.newLine();
    _builder.newLine();
    _builder.append("// get attributes read from the workflow");
    _builder.newLine();
    _builder.append("if (isset($params[\'nextstate\']) && !empty($params[\'nextstate\'])) {");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// assign value to the data object");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$entity[\'workflowState\'] = $params[\'nextstate\'];");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($params[\'nextstate\'] == \'archived\') {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// bypass validator (for example an end date could have lost it\'s \"value in future\")");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$entity[\'_bypassValidation\'] = true;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("// get entity manager");
    _builder.newLine();
    _builder.append("$serviceManager = ServiceUtil::getManager();");
    _builder.newLine();
    _builder.append("$entityManager = $serviceManager->getService(\'doctrine.entitymanager\');");
    _builder.newLine();
    _builder.newLine();
    _builder.append("// save entity data");
    _builder.newLine();
    _builder.append("try {");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("//$this->entityManager->transactional(function($entityManager) {");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$entityManager->persist($entity);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$entityManager->flush();");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("//});");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$result = true;");
    _builder.newLine();
    _builder.append("} catch (Exception $e) {");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("LogUtil::registerError($e->getMessage());");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence deleteImpl() {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("// get entity manager");
    _builder.newLine();
    _builder.append("$serviceManager = ServiceUtil::getManager();");
    _builder.newLine();
    _builder.append("$entityManager = $serviceManager->getService(\'doctrine.entitymanager\');");
    _builder.newLine();
    _builder.newLine();
    _builder.append("// delete entity");
    _builder.newLine();
    _builder.append("try {");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$entityManager->remove($entity);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$entityManager->flush();");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$result = true;");
    _builder.newLine();
    _builder.append("} catch (Exception $e) {");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("LogUtil::registerError($e->getMessage());");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
}
