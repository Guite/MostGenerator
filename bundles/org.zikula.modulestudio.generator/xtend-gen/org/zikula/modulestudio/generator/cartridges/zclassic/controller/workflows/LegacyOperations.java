package org.zikula.modulestudio.generator.cartridges.zclassic.controller.workflows;

import com.google.common.base.Objects;
import de.guite.modulestudio.metamodel.Application;
import de.guite.modulestudio.metamodel.EntityWorkflowType;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;
import org.zikula.modulestudio.generator.extensions.WorkflowExtensions;

/**
 * Workflow operations.
 */
@SuppressWarnings("all")
public class LegacyOperations {
  @Extension
  private FormattingExtensions _formattingExtensions = new FormattingExtensions();
  
  @Extension
  private NamingExtensions _namingExtensions = new NamingExtensions();
  
  @Extension
  private WorkflowExtensions _workflowExtensions = new WorkflowExtensions();
  
  @Extension
  private Utils _utils = new Utils();
  
  private Application app;
  
  private IFileSystemAccess fsa;
  
  private String outputPath;
  
  private FileHelper fh = new FileHelper();
  
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
    boolean _needsApproval = this._workflowExtensions.needsApproval(this.app);
    if (_needsApproval) {
      this.operation("notify");
    }
  }
  
  private void operation(final String opName) {
    String fileName = (("function." + opName) + ".php");
    boolean _shouldBeSkipped = this._namingExtensions.shouldBeSkipped(this.app, (this.outputPath + fileName));
    boolean _not = (!_shouldBeSkipped);
    if (_not) {
      boolean _shouldBeMarked = this._namingExtensions.shouldBeMarked(this.app, (this.outputPath + fileName));
      if (_shouldBeMarked) {
        fileName = (("function." + opName) + ".generated.php");
      }
      this.fsa.generateFile((this.outputPath + fileName), this.fh.phpFileContent(this.app, this.operationFile(opName)));
    }
  }
  
  private CharSequence operationFile(final String opName) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* ");
    String _formatForDisplayCapital = this._formattingExtensions.formatForDisplayCapital(opName);
    _builder.append(_formatForDisplayCapital, " ");
    _builder.append(" operation.");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param object $entity The treated object");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param array  $params Additional arguments");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return bool False on failure or true if everything worked well");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @throws RuntimeException Thrown if executing the workflow action fails");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("function ");
    String _appName = this._utils.appName(this.app);
    _builder.append(_appName);
    _builder.append("_operation_");
    _builder.append(opName);
    _builder.append("(&$entity, $params)");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
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
        _builder.append(_updateImpl);
        _builder.newLineIfNotEmpty();
      } else {
        boolean _equals_1 = Objects.equal(opName, "delete");
        if (_equals_1) {
          CharSequence _deleteImpl = this.deleteImpl();
          _builder.append(_deleteImpl);
          _builder.newLineIfNotEmpty();
        } else {
          boolean _equals_2 = Objects.equal(opName, "notify");
          if (_equals_2) {
            CharSequence _notifyImpl = this.notifyImpl();
            _builder.append(_notifyImpl);
            _builder.newLineIfNotEmpty();
          }
        }
      }
    }
    return _builder;
  }
  
  private CharSequence updateImpl() {
    StringConcatenation _builder = new StringConcatenation();
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
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("// get entity manager");
    _builder.newLine();
    _builder.append("$container = \\ServiceUtil::get(\'service_container\');");
    _builder.newLine();
    _builder.append("$entityManager = $container->get(\'");
    String _entityManagerService = this._namingExtensions.entityManagerService(this.app);
    _builder.append(_entityManagerService);
    _builder.append("\');");
    _builder.newLineIfNotEmpty();
    _builder.append("$logger = $container->get(\'logger\');");
    _builder.newLine();
    _builder.append("$logArgs = [\'app\' => \'");
    String _appName = this._utils.appName(this.app);
    _builder.append(_appName);
    _builder.append("\', \'user\' => $container->get(\'zikula_users_module.current_user\')->get(\'uname\')];");
    _builder.newLineIfNotEmpty();
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
    _builder.append("    ");
    _builder.append("$logger->notice(\'{app}: User {user} updated an entity.\', $logArgs);");
    _builder.newLine();
    _builder.append("} catch (\\Exception $e) {");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$logger->error(\'{app}: User {user} tried to update an entity, but failed.\', $logArgs);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("throw new \\RuntimeException($e->getMessage());");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence deleteImpl() {
    StringConcatenation _builder = new StringConcatenation();
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
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("// get entity manager");
    _builder.newLine();
    _builder.append("$container = \\ServiceUtil::get(\'service_container\');");
    _builder.newLine();
    _builder.append("$entityManager = $container->get(\'");
    String _entityManagerService = this._namingExtensions.entityManagerService(this.app);
    _builder.append(_entityManagerService);
    _builder.append("\');");
    _builder.newLineIfNotEmpty();
    _builder.append("$logger = $container->get(\'logger\');");
    _builder.newLine();
    _builder.append("$logArgs = [\'app\' => \'");
    String _appName = this._utils.appName(this.app);
    _builder.append(_appName);
    _builder.append("\', \'user\' => $container->get(\'zikula_users_module.current_user\')->get(\'uname\')];");
    _builder.newLineIfNotEmpty();
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
    _builder.append("    ");
    _builder.append("$logger->notice(\'{app}: User {user} deleted an entity.\', $logArgs);");
    _builder.newLine();
    _builder.append("} catch (\\Exception $e) {");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$logger->error(\'{app}: User {user} tried to delete an entity, but failed.\', $logArgs);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("throw new \\RuntimeException($e->getMessage());");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence notifyImpl() {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("// workflow parameters are always lower-cased (#656)");
    _builder.newLine();
    _builder.append("$recipientType = isset($params[\'recipientType\']) ? $params[\'recipientType\'] : $params[\'recipienttype\'];");
    _builder.newLine();
    _builder.newLine();
    _builder.append("$notifyArgs = [");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("\'recipientType\' => $recipientType,");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("\'action\' => $params[\'action\'],");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("\'entity\' => $entity");
    _builder.newLine();
    _builder.append("];");
    _builder.newLine();
    _builder.newLine();
    _builder.append("$result = \\ServiceUtil::get(\'");
    String _appService = this._utils.appService(this.app);
    _builder.append(_appService);
    _builder.append(".notification_helper\')->process($notifyArgs);");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
}
