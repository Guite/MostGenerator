package org.zikula.modulestudio.generator.cartridges.zclassic.models.event;

import de.guite.modulestudio.metamodel.Application;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.xbase.lib.Extension;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class EventAction {
  @Extension
  private FormattingExtensions _formattingExtensions = new FormattingExtensions();
  
  @Extension
  private ModelExtensions _modelExtensions = new ModelExtensions();
  
  @Extension
  private NamingExtensions _namingExtensions = new NamingExtensions();
  
  @Extension
  private Utils _utils = new Utils();
  
  private String entityVar;
  
  public EventAction(final String entityVar) {
    this.entityVar = entityVar;
  }
  
  public CharSequence postLoad(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.newLine();
    _builder.append("// create the filter event and dispatch it");
    _builder.newLine();
    _builder.append("$filterEventClass = \'\\\\");
    String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(it.getVendor());
    _builder.append(_formatForCodeCapital);
    _builder.append("\\\\");
    String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital_1);
    _builder.append("Module\\\\Event\\\\Filter\' . ucfirst(");
    _builder.append(this.entityVar);
    _builder.append("->get_objectType()) . \'Event\';");
    _builder.newLineIfNotEmpty();
    _builder.append("$event = new $filterEventClass(");
    _builder.append(this.entityVar);
    _builder.append(");");
    _builder.newLineIfNotEmpty();
    _builder.append("$this->container->get(\'event_dispatcher\')->dispatch(constant(\'\\\\");
    String _formatForCodeCapital_2 = this._formattingExtensions.formatForCodeCapital(it.getVendor());
    _builder.append(_formatForCodeCapital_2);
    _builder.append("\\\\");
    String _formatForCodeCapital_3 = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital_3);
    _builder.append("Module\\\\");
    String _formatForCodeCapital_4 = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital_4);
    _builder.append("Events::\' . strtoupper(");
    _builder.append(this.entityVar);
    _builder.append("->get_objectType()) . \'_POST_LOAD\'), $event);");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  public CharSequence prePersist(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _hasUploads = this._modelExtensions.hasUploads(it);
      if (_hasUploads) {
        _builder.append("$uploadFields = $this->getUploadFields($entity->get_objectType());");
        _builder.newLine();
        _builder.append("foreach ($uploadFields as $uploadField) {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("if (empty(");
        _builder.append(this.entityVar, "    ");
        _builder.append("[$uploadField])) {");
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        _builder.append("continue;");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("if (!($entity[$uploadField] instanceof File)) {");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("$entity[$uploadField] = new File($entity[$uploadField]);");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append(this.entityVar, "    ");
        _builder.append("[$uploadField] = ");
        _builder.append(this.entityVar, "    ");
        _builder.append("[$uploadField]->getFilename();");
        _builder.newLineIfNotEmpty();
        _builder.append("}");
        _builder.newLine();
        _builder.newLine();
      }
    }
    _builder.newLine();
    _builder.append("// create the filter event and dispatch it");
    _builder.newLine();
    _builder.append("$filterEventClass = \'\\\\");
    String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(it.getVendor());
    _builder.append(_formatForCodeCapital);
    _builder.append("\\\\");
    String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital_1);
    _builder.append("Module\\\\Event\\\\Filter\' . ucfirst(");
    _builder.append(this.entityVar);
    _builder.append("->get_objectType()) . \'Event\';");
    _builder.newLineIfNotEmpty();
    _builder.append("$event = new $filterEventClass(");
    _builder.append(this.entityVar);
    _builder.append(");");
    _builder.newLineIfNotEmpty();
    _builder.append("$this->container->get(\'event_dispatcher\')->dispatch(constant(\'\\\\");
    String _formatForCodeCapital_2 = this._formattingExtensions.formatForCodeCapital(it.getVendor());
    _builder.append(_formatForCodeCapital_2);
    _builder.append("\\\\");
    String _formatForCodeCapital_3 = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital_3);
    _builder.append("Module\\\\");
    String _formatForCodeCapital_4 = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital_4);
    _builder.append("Events::\' . strtoupper(");
    _builder.append(this.entityVar);
    _builder.append("->get_objectType()) . \'_PRE_PERSIST\'), $event);");
    _builder.newLineIfNotEmpty();
    _builder.append("if ($event->isPropagationStopped()) {");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return false;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  public CharSequence postPersist(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("$objectId = ");
    _builder.append(this.entityVar);
    _builder.append("->createCompositeIdentifier();");
    _builder.newLineIfNotEmpty();
    _builder.append("$logger = $this->container->get(\'logger\');");
    _builder.newLine();
    _builder.append("$logArgs = [\'app\' => \'");
    String _appName = this._utils.appName(it);
    _builder.append(_appName);
    _builder.append("\', \'user\' => $this->container->get(\'zikula_users_module.current_user\')->get(\'uname\'), \'entity\' => ");
    _builder.append(this.entityVar);
    _builder.append("->get_objectType(), \'id\' => $objectId];");
    _builder.newLineIfNotEmpty();
    _builder.append("$logger->debug(\'{app}: User {user} created the {entity} with id {id}.\', $logArgs);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("// create the filter event and dispatch it");
    _builder.newLine();
    _builder.append("$filterEventClass = \'\\\\");
    String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(it.getVendor());
    _builder.append(_formatForCodeCapital);
    _builder.append("\\\\");
    String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital_1);
    _builder.append("Module\\\\Event\\\\Filter\' . ucfirst(");
    _builder.append(this.entityVar);
    _builder.append("->get_objectType()) . \'Event\';");
    _builder.newLineIfNotEmpty();
    _builder.append("$event = new $filterEventClass(");
    _builder.append(this.entityVar);
    _builder.append(");");
    _builder.newLineIfNotEmpty();
    _builder.append("$this->container->get(\'event_dispatcher\')->dispatch(constant(\'\\\\");
    String _formatForCodeCapital_2 = this._formattingExtensions.formatForCodeCapital(it.getVendor());
    _builder.append(_formatForCodeCapital_2);
    _builder.append("\\\\");
    String _formatForCodeCapital_3 = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital_3);
    _builder.append("Module\\\\");
    String _formatForCodeCapital_4 = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital_4);
    _builder.append("Events::\' . strtoupper(");
    _builder.append(this.entityVar);
    _builder.append("->get_objectType()) . \'_POST_PERSIST\'), $event);");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  public CharSequence preRemove(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("// create the filter event and dispatch it");
    _builder.newLine();
    _builder.append("$filterEventClass = \'\\\\");
    String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(it.getVendor());
    _builder.append(_formatForCodeCapital);
    _builder.append("\\\\");
    String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital_1);
    _builder.append("Module\\\\Event\\\\Filter\' . ucfirst(");
    _builder.append(this.entityVar);
    _builder.append("->get_objectType()) . \'Event\';");
    _builder.newLineIfNotEmpty();
    _builder.append("$event = new $filterEventClass(");
    _builder.append(this.entityVar);
    _builder.append(");");
    _builder.newLineIfNotEmpty();
    _builder.append("$this->container->get(\'event_dispatcher\')->dispatch(constant(\'\\\\");
    String _formatForCodeCapital_2 = this._formattingExtensions.formatForCodeCapital(it.getVendor());
    _builder.append(_formatForCodeCapital_2);
    _builder.append("\\\\");
    String _formatForCodeCapital_3 = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital_3);
    _builder.append("Module\\\\");
    String _formatForCodeCapital_4 = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital_4);
    _builder.append("Events::\' . strtoupper(");
    _builder.append(this.entityVar);
    _builder.append("->get_objectType()) . \'_PRE_REMOVE\'), $event);");
    _builder.newLineIfNotEmpty();
    _builder.append("if ($event->isPropagationStopped()) {");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return false;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    {
      Boolean _targets = this._utils.targets(it, "1.5");
      boolean _not = (!(_targets).booleanValue());
      if (_not) {
        _builder.newLine();
        _builder.append("// delete workflow for this entity");
        _builder.newLine();
        _builder.append("$workflowHelper = $this->container->get(\'");
        String _appService = this._utils.appService(it);
        _builder.append(_appService);
        _builder.append(".workflow_helper\');");
        _builder.newLineIfNotEmpty();
        _builder.append("$workflowHelper->normaliseWorkflowData(");
        _builder.append(this.entityVar);
        _builder.append(");");
        _builder.newLineIfNotEmpty();
        _builder.append("$workflow = ");
        _builder.append(this.entityVar);
        _builder.append("[\'__WORKFLOW__\'];");
        _builder.newLineIfNotEmpty();
        _builder.append("if ($workflow[\'id\'] > 0) {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$entityManager = $this->container->get(\'");
        String _entityManagerService = this._namingExtensions.entityManagerService(it);
        _builder.append(_entityManagerService, "    ");
        _builder.append("\');");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("$result = true;");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("try {");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("$workflow = $entityManager->find(\'Zikula\\Core\\Doctrine\\Entity\\WorkflowEntity\', $workflow[\'id\']);");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("$entityManager->remove($workflow);");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("$entityManager->flush();");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("} catch (\\Exception $e) {");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("$result = false;");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("if (false === $result) {");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("$flashBag = $this->container->get(\'session\')->getFlashBag();");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("$flashBag->add(\'error\', $this->container->get(\'translator.default\')->__(\'Error! Could not remove stored workflow. Deletion has been aborted.\'));");
        _builder.newLine();
        _builder.newLine();
        _builder.append("        ");
        _builder.append("return false;");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
        _builder.append("}");
        _builder.newLine();
      }
    }
    return _builder;
  }
  
  public CharSequence postRemove(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("$objectType = ");
    _builder.append(this.entityVar);
    _builder.append("->get_objectType();");
    _builder.newLineIfNotEmpty();
    _builder.append("$objectId = ");
    _builder.append(this.entityVar);
    _builder.append("->createCompositeIdentifier();");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    {
      boolean _hasUploads = this._modelExtensions.hasUploads(it);
      if (_hasUploads) {
        _builder.append("$uploadHelper = $this->container->get(\'");
        String _appService = this._utils.appService(it);
        _builder.append(_appService);
        _builder.append(".upload_helper\');");
        _builder.newLineIfNotEmpty();
        _builder.append("$uploadFields = $this->getUploadFields($objectType);");
        _builder.newLine();
        _builder.append("foreach ($uploadFields as $uploadField) {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("if (empty(");
        _builder.append(this.entityVar, "    ");
        _builder.append("[$uploadField])) {");
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        _builder.append("continue;");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("// remove upload file");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$uploadHelper->deleteUploadFile(");
        _builder.append(this.entityVar, "    ");
        _builder.append(", $uploadField);");
        _builder.newLineIfNotEmpty();
        _builder.append("}");
        _builder.newLine();
      }
    }
    _builder.newLine();
    _builder.append("$logger = $this->container->get(\'logger\');");
    _builder.newLine();
    _builder.append("$logArgs = [\'app\' => \'");
    String _appName = this._utils.appName(it);
    _builder.append(_appName);
    _builder.append("\', \'user\' => $this->container->get(\'zikula_users_module.current_user\')->get(\'uname\'), \'entity\' => $objectType, \'id\' => $objectId];");
    _builder.newLineIfNotEmpty();
    _builder.append("$logger->debug(\'{app}: User {user} removed the {entity} with id {id}.\', $logArgs);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("// create the filter event and dispatch it");
    _builder.newLine();
    _builder.append("$filterEventClass = \'\\\\");
    String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(it.getVendor());
    _builder.append(_formatForCodeCapital);
    _builder.append("\\\\");
    String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital_1);
    _builder.append("Module\\\\Event\\\\Filter\' . ucfirst($objectType) . \'Event\';");
    _builder.newLineIfNotEmpty();
    _builder.append("$event = new $filterEventClass(");
    _builder.append(this.entityVar);
    _builder.append(");");
    _builder.newLineIfNotEmpty();
    _builder.append("$this->container->get(\'event_dispatcher\')->dispatch(constant(\'\\\\");
    String _formatForCodeCapital_2 = this._formattingExtensions.formatForCodeCapital(it.getVendor());
    _builder.append(_formatForCodeCapital_2);
    _builder.append("\\\\");
    String _formatForCodeCapital_3 = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital_3);
    _builder.append("Module\\\\");
    String _formatForCodeCapital_4 = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital_4);
    _builder.append("Events::\' . strtoupper($objectType) . \'_POST_REMOVE\'), $event);");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  public CharSequence preUpdate(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _hasUploads = this._modelExtensions.hasUploads(it);
      if (_hasUploads) {
        _builder.append("$uploadFields = $this->getUploadFields($entity->get_objectType());");
        _builder.newLine();
        _builder.append("foreach ($uploadFields as $uploadField) {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("if (empty(");
        _builder.append(this.entityVar, "    ");
        _builder.append("[$uploadField])) {");
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        _builder.append("continue;");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("if (!($entity[$uploadField] instanceof File)) {");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("$entity[$uploadField] = new File($entity[$uploadField]);");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append(this.entityVar, "    ");
        _builder.append("[$uploadField] = ");
        _builder.append(this.entityVar, "    ");
        _builder.append("[$uploadField]->getFilename();");
        _builder.newLineIfNotEmpty();
        _builder.append("}");
        _builder.newLine();
        _builder.newLine();
      }
    }
    _builder.newLine();
    _builder.append("// create the filter event and dispatch it");
    _builder.newLine();
    _builder.append("$filterEventClass = \'\\\\");
    String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(it.getVendor());
    _builder.append(_formatForCodeCapital);
    _builder.append("\\\\");
    String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital_1);
    _builder.append("Module\\\\Event\\\\Filter\' . ucfirst(");
    _builder.append(this.entityVar);
    _builder.append("->get_objectType()) . \'Event\';");
    _builder.newLineIfNotEmpty();
    _builder.append("$event = new $filterEventClass(");
    _builder.append(this.entityVar);
    _builder.append(", $args->getEntityChangeSet());");
    _builder.newLineIfNotEmpty();
    _builder.append("$this->container->get(\'event_dispatcher\')->dispatch(constant(\'\\\\");
    String _formatForCodeCapital_2 = this._formattingExtensions.formatForCodeCapital(it.getVendor());
    _builder.append(_formatForCodeCapital_2);
    _builder.append("\\\\");
    String _formatForCodeCapital_3 = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital_3);
    _builder.append("Module\\\\");
    String _formatForCodeCapital_4 = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital_4);
    _builder.append("Events::\' . strtoupper(");
    _builder.append(this.entityVar);
    _builder.append("->get_objectType()) . \'_PRE_UPDATE\'), $event);");
    _builder.newLineIfNotEmpty();
    _builder.append("if ($event->isPropagationStopped()) {");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return false;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  public CharSequence postUpdate(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("$objectId = ");
    _builder.append(this.entityVar);
    _builder.append("->createCompositeIdentifier();");
    _builder.newLineIfNotEmpty();
    _builder.append("$logger = $this->container->get(\'logger\');");
    _builder.newLine();
    _builder.append("$logArgs = [\'app\' => \'");
    String _appName = this._utils.appName(it);
    _builder.append(_appName);
    _builder.append("\', \'user\' => $this->container->get(\'zikula_users_module.current_user\')->get(\'uname\'), \'entity\' => ");
    _builder.append(this.entityVar);
    _builder.append("->get_objectType(), \'id\' => $objectId];");
    _builder.newLineIfNotEmpty();
    _builder.append("$logger->debug(\'{app}: User {user} updated the {entity} with id {id}.\', $logArgs);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("// create the filter event and dispatch it");
    _builder.newLine();
    _builder.append("$filterEventClass = \'\\\\");
    String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(it.getVendor());
    _builder.append(_formatForCodeCapital);
    _builder.append("\\\\");
    String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital_1);
    _builder.append("Module\\\\Event\\\\Filter\' . ucfirst(");
    _builder.append(this.entityVar);
    _builder.append("->get_objectType()) . \'Event\';");
    _builder.newLineIfNotEmpty();
    _builder.append("$event = new $filterEventClass(");
    _builder.append(this.entityVar);
    _builder.append(");");
    _builder.newLineIfNotEmpty();
    _builder.append("$this->container->get(\'event_dispatcher\')->dispatch(constant(\'\\\\");
    String _formatForCodeCapital_2 = this._formattingExtensions.formatForCodeCapital(it.getVendor());
    _builder.append(_formatForCodeCapital_2);
    _builder.append("\\\\");
    String _formatForCodeCapital_3 = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital_3);
    _builder.append("Module\\\\");
    String _formatForCodeCapital_4 = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital_4);
    _builder.append("Events::\' . strtoupper(");
    _builder.append(this.entityVar);
    _builder.append("->get_objectType()) . \'_POST_UPDATE\'), $event);");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
}
