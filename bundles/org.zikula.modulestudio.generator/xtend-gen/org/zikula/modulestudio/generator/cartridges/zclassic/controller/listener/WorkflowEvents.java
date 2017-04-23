package org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener;

import com.google.common.base.Objects;
import de.guite.modulestudio.metamodel.Application;
import de.guite.modulestudio.metamodel.Entity;
import de.guite.modulestudio.metamodel.EntityWorkflowType;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener.CommonExample;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;
import org.zikula.modulestudio.generator.extensions.WorkflowExtensions;

@SuppressWarnings("all")
public class WorkflowEvents {
  @Extension
  private FormattingExtensions _formattingExtensions = new FormattingExtensions();
  
  @Extension
  private ModelExtensions _modelExtensions = new ModelExtensions();
  
  @Extension
  private Utils _utils = new Utils();
  
  @Extension
  private WorkflowExtensions _workflowExtensions = new WorkflowExtensions();
  
  public CharSequence generate(final Application it, final Boolean isBase) {
    StringConcatenation _builder = new StringConcatenation();
    {
      if ((isBase).booleanValue()) {
        _builder.append("/**");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @var PermissionApiInterface");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
        _builder.append("protected $permissionApi;");
        _builder.newLine();
        {
          boolean _needsApproval = this._workflowExtensions.needsApproval(it);
          if (_needsApproval) {
            _builder.newLine();
            _builder.append("/**");
            _builder.newLine();
            _builder.append(" ");
            _builder.append("* @var NotificationHelper");
            _builder.newLine();
            _builder.append(" ");
            _builder.append("*/");
            _builder.newLine();
            _builder.append("protected $notificationHelper;");
            _builder.newLine();
          }
        }
        _builder.newLine();
        _builder.append("/**");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* WorkflowEventsListener constructor.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @param PermissionApiInterface $permissionApi ");
        {
          boolean _needsApproval_1 = this._workflowExtensions.needsApproval(it);
          if (_needsApproval_1) {
            _builder.append("     ");
          }
        }
        _builder.append("PermissionApi service instance");
        _builder.newLineIfNotEmpty();
        {
          boolean _needsApproval_2 = this._workflowExtensions.needsApproval(it);
          if (_needsApproval_2) {
            _builder.append(" ");
            _builder.append("* @param NotificationHelper     $notificationHelper NotificationHelper service instance");
            _builder.newLine();
          }
        }
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
        _builder.append("public function __construct(PermissionApiInterface $permissionApi");
        {
          boolean _needsApproval_3 = this._workflowExtensions.needsApproval(it);
          if (_needsApproval_3) {
            _builder.append(", NotificationHelper $notificationHelper");
          }
        }
        _builder.append(")");
        _builder.newLineIfNotEmpty();
        _builder.append("{");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$this->permissionApi = $permissionApi;");
        _builder.newLine();
        {
          boolean _needsApproval_4 = this._workflowExtensions.needsApproval(it);
          if (_needsApproval_4) {
            _builder.append("    ");
            _builder.append("$this->notificationHelper = $notificationHelper;");
            _builder.newLine();
          }
        }
        _builder.append("}");
        _builder.newLine();
        _builder.newLine();
        _builder.append("/**");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Makes our handlers known to the event system.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
      } else {
        _builder.append("/**");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @inheritDoc");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
      }
    }
    _builder.append("public static function getSubscribedEvents()");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    {
      if ((isBase).booleanValue()) {
        _builder.append("    ");
        _builder.append("return [");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("\'workflow.guard\' => [\'onGuard\', 5],");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("\'workflow.leave\' => [\'onLeave\', 5],");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("\'workflow.transition\' => [\'onTransition\', 5],");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("\'workflow.enter\' => [\'onEnter\', 5]");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("];");
        _builder.newLine();
      } else {
        _builder.append("    ");
        _builder.append("return parent::getSubscribedEvents();");
        _builder.newLine();
      }
    }
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    {
      if ((isBase).booleanValue()) {
        _builder.append("/**");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Listener for the `workflow.guard` event.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Occurs just before a transition is started and when testing which transitions are available.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Allows to define that the transition is not allowed by calling `$event->setBlocked(true);`.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* This event is also triggered for each workflow individually, so you can react only to the events");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* of a specific workflow by listening to `workflow.<workflow_name>.guard` instead.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* You can even listen to some specific transitions or states for a specific workflow");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* using `workflow.<workflow_name>.guard.<transition_name>`.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @param GuardEvent $event The event instance");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
      } else {
        _builder.append("/**");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @inheritDoc");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
      }
    }
    _builder.append("public function onGuard(GuardEvent $event)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    {
      if ((isBase).booleanValue()) {
        _builder.append("    ");
        _builder.append("$entity = $event->getSubject();");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("if (!$this->isEntityManagedByThisBundle($entity) || !method_exists($entity, \'get_objectType\')) {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("return;");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$permissionLevel = ACCESS_READ;");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$transitionName = $event->getTransition()->getName();");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("if (substr($transitionName, 0, 6) == \'update\') {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("$transitionName = \'update\';");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$targetState = $event->getTransition()->getTos()[0];");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$hasApproval = ");
        {
          boolean _needsApproval_5 = this._workflowExtensions.needsApproval(it);
          if (_needsApproval_5) {
            _builder.append("in_array($entity->get_objectType(), [\'");
            final Function1<Entity, Boolean> _function = (Entity it_1) -> {
              EntityWorkflowType _workflow = it_1.getWorkflow();
              return Boolean.valueOf((!Objects.equal(_workflow, EntityWorkflowType.NONE)));
            };
            final Function1<Entity, String> _function_1 = (Entity it_1) -> {
              return this._formattingExtensions.formatForCode(it_1.getName());
            };
            String _join = IterableExtensions.join(IterableExtensions.<Entity, String>map(IterableExtensions.<Entity>filter(this._modelExtensions.getAllEntities(it), _function), _function_1), "\', \'");
            _builder.append(_join, "    ");
            _builder.append("\'])");
          } else {
            _builder.append("false");
          }
        }
        _builder.append(";");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("switch ($transitionName) {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("case \'defer\':");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("case \'submit\':");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("        ");
        _builder.append("$permissionLevel = $hasApproval ? ACCESS_COMMENT : ACCESS_EDIT;");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("        ");
        _builder.append("break;");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("case \'update\':");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("case \'reject\':");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("case \'accept\':");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("case \'publish\':");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("case \'unpublish\':");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("case \'archive\':");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("case \'trash\':");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("case \'recover\':");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("        ");
        _builder.append("$permissionLevel = ACCESS_EDIT;");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("        ");
        _builder.append("break;");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("case \'approve\':");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("case \'demote\':");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("        ");
        _builder.append("$permissionLevel = ACCESS_ADD;");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("        ");
        _builder.append("break;");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("case \'delete\':");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("        ");
        _builder.append("$permissionLevel = ACCESS_DELETE;");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("        ");
        _builder.append("break;");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$instanceId = $entity->createCompositeIdentifier();");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("if (!$this->permissionApi->hasPermission(\'");
        String _appName = this._utils.appName(it);
        _builder.append(_appName, "    ");
        _builder.append(":\' . ucfirst($entity->get_objectType()) . \':\', $instanceId . \'::\', $permissionLevel)) {");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("// no permission for this transition, so disallow it");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("$event->setBlocked(true);");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
      } else {
        _builder.append("    ");
        _builder.append("parent::onGuard($event);");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        CharSequence _exampleCode = this.exampleCode(it);
        _builder.append(_exampleCode, "    ");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("// example for preventing a transition");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("// if (!$event->isBlocked()) {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("//     $event->setBlocked(true);");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("// }");
        _builder.newLine();
      }
    }
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    {
      if ((isBase).booleanValue()) {
        _builder.append("/**");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Listener for the `workflow.leave` event.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Occurs just after an object has left it\'s current state.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Carries the marking with the initial places.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* This event is also triggered for each workflow individually, so you can react only to the events");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* of a specific workflow by listening to `workflow.<workflow_name>.leave` instead.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* You can even listen to some specific transitions or states for a specific workflow");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* using `workflow.<workflow_name>.leave.<state_name>`.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @param Event $event The event instance");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
      } else {
        _builder.append("/**");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @inheritDoc");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
      }
    }
    _builder.append("public function onLeave(Event $event)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    {
      if ((isBase).booleanValue()) {
        _builder.append("    ");
        _builder.append("$entity = $event->getSubject();");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("if (!$this->isEntityManagedByThisBundle($entity) || !method_exists($entity, \'get_objectType\')) {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("return;");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
      } else {
        _builder.append("    ");
        _builder.append("parent::onLeave($event);");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        CharSequence _exampleCode_1 = this.exampleCode(it);
        _builder.append(_exampleCode_1, "    ");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    {
      if ((isBase).booleanValue()) {
        _builder.append("/**");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Listener for the `workflow.transition` event.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Occurs just before starting to transition to the new state.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Carries the marking with the current places.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* This event is also triggered for each workflow individually, so you can react only to the events");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* of a specific workflow by listening to `workflow.<workflow_name>.transition` instead.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* You can even listen to some specific transitions or states for a specific workflow");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* using `workflow.<workflow_name>.transition.<transition_name>`.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @param Event $event The event instance");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
      } else {
        _builder.append("/**");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @inheritDoc");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
      }
    }
    _builder.append("public function onTransition(Event $event)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    {
      if ((isBase).booleanValue()) {
        _builder.append("    ");
        _builder.append("$entity = $event->getSubject();");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("if (!$this->isEntityManagedByThisBundle($entity) || !method_exists($entity, \'get_objectType\')) {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("return;");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
      } else {
        _builder.append("    ");
        _builder.append("parent::onTransition($event);");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        CharSequence _exampleCode_2 = this.exampleCode(it);
        _builder.append(_exampleCode_2, "    ");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    {
      if ((isBase).booleanValue()) {
        _builder.append("/**");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Listener for the `workflow.enter` event.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Occurs just after the object has entered into the new state.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Carries the marking with the new places.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* This event is also triggered for each workflow individually, so you can react only to the events");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* of a specific workflow by listening to `workflow.<workflow_name>.enter` instead.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* You can even listen to some specific transitions or states for a specific workflow");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* using `workflow.<workflow_name>.enter.<state_name>`.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @param Event $event The event instance");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
      } else {
        _builder.append("/**");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @inheritDoc");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
      }
    }
    _builder.append("public function onEnter(Event $event)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    {
      if ((isBase).booleanValue()) {
        _builder.append("    ");
        _builder.append("$entity = $event->getSubject();");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("if (!$this->isEntityManagedByThisBundle($entity) || !method_exists($entity, \'get_objectType\')) {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("return;");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
        {
          boolean _needsApproval_6 = this._workflowExtensions.needsApproval(it);
          if (_needsApproval_6) {
            _builder.newLine();
            _builder.append("    ");
            _builder.append("$workflowShortName = \'none\';");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("if (in_array($entity->get_objectType(), [\'");
            final Function1<Entity, Boolean> _function_2 = (Entity it_1) -> {
              EntityWorkflowType _workflow = it_1.getWorkflow();
              return Boolean.valueOf(Objects.equal(_workflow, EntityWorkflowType.STANDARD));
            };
            final Function1<Entity, String> _function_3 = (Entity it_1) -> {
              return this._formattingExtensions.formatForCode(it_1.getName());
            };
            String _join_1 = IterableExtensions.join(IterableExtensions.<Entity, String>map(IterableExtensions.<Entity>filter(this._modelExtensions.getAllEntities(it), _function_2), _function_3), "\', \'");
            _builder.append(_join_1, "    ");
            _builder.append("\'])) {");
            _builder.newLineIfNotEmpty();
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("$workflowShortName = \'standard\';");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("} elseif (in_array($entity->get_objectType(), [\'");
            final Function1<Entity, Boolean> _function_4 = (Entity it_1) -> {
              EntityWorkflowType _workflow = it_1.getWorkflow();
              return Boolean.valueOf(Objects.equal(_workflow, EntityWorkflowType.ENTERPRISE));
            };
            final Function1<Entity, String> _function_5 = (Entity it_1) -> {
              return this._formattingExtensions.formatForCode(it_1.getName());
            };
            String _join_2 = IterableExtensions.join(IterableExtensions.<Entity, String>map(IterableExtensions.<Entity>filter(this._modelExtensions.getAllEntities(it), _function_4), _function_5), "\', \'");
            _builder.append(_join_2, "    ");
            _builder.append("\'])) {");
            _builder.newLineIfNotEmpty();
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("$workflowShortName = \'enterprise\';");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("}");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("if ($workflowShortName != \'none\') {");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("$this->sendNotifications($entity, $event->getTransition()->getName(), $workflowShortName);");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("}");
            _builder.newLine();
          }
        }
      } else {
        _builder.append("    ");
        _builder.append("parent::onEnter($event);");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        CharSequence _exampleCode_3 = this.exampleCode(it);
        _builder.append(_exampleCode_3, "    ");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("}");
    _builder.newLine();
    {
      if ((isBase).booleanValue()) {
        _builder.newLine();
        CharSequence _isEntityManagedByThisBundle = this.isEntityManagedByThisBundle(it);
        _builder.append(_isEntityManagedByThisBundle);
        _builder.newLineIfNotEmpty();
        {
          boolean _needsApproval_7 = this._workflowExtensions.needsApproval(it);
          if (_needsApproval_7) {
            _builder.newLine();
            CharSequence _sendNotifications = this.sendNotifications(it);
            _builder.append(_sendNotifications);
            _builder.newLineIfNotEmpty();
          }
        }
      }
    }
    return _builder;
  }
  
  private CharSequence exampleCode(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _generalEventProperties = new CommonExample().generalEventProperties(it);
    _builder.append(_generalEventProperties);
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("// access the entity");
    _builder.newLine();
    _builder.append("// $entity = $event->getSubject();");
    _builder.newLine();
    _builder.newLine();
    _builder.append("// access the marking");
    _builder.newLine();
    _builder.append("// $marking = $event->getMarking();");
    _builder.newLine();
    _builder.newLine();
    _builder.append("// access the transition");
    _builder.newLine();
    _builder.append("// $transition = $event->getTransition();");
    _builder.newLine();
    _builder.newLine();
    _builder.append("// starting from Symfony 3.3.0 you can also access the workflow name");
    _builder.newLine();
    _builder.append("// $workflowName = $event->getWorkflowName();");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence isEntityManagedByThisBundle(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Checks whether this listener is responsible for the given entity or not.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param EntityAccess $entity The given entity");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return boolean True if entity is managed by this listener, false otherwise");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected function isEntityManagedByThisBundle($entity)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!($entity instanceof EntityAccess)) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return false;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$entityClassParts = explode(\'\\\\\', get_class($entity));");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return ($entityClassParts[0] == \'");
    String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(it.getVendor());
    _builder.append(_formatForCodeCapital, "    ");
    _builder.append("\' && $entityClassParts[1] == \'");
    String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital_1, "    ");
    _builder.append("Module\');");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence sendNotifications(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Sends email notifications.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param object $entity            Processed entity");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $actionId          Name of performed transition");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $workflowShortName Name of workflow (none, standard, enterprise)");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected function sendNotifications($entity, $actionId, $workflowShortName)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$newState = $entity->getWorkflowState();");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// by default send only to creator");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$sendToCreator = true;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$sendToModerator = false;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$sendToSuperModerator = false;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($actionId == \'submit\' && $newState == \'waiting\'");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("|| $actionId == \'demote\' && $newState == \'accepted\') {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// only to moderator");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$sendToCreator = false;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$sendToModerator = true;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("} elseif ($actionId == \'accept\' && $newState == \'accepted\') {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// to creator and super moderator");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$sendToSuperModerator = true;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("} elseif ($actionId == \'approve\' && $newState == \'approved\' && $workflowShortName == \'enterprise\') {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// to creator and moderator");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$sendToModerator = true;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$recipientTypes = [];");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (true === $sendToCreator) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$recipientTypes[] = \'creator\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (true === $sendToModerator) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$recipientTypes[] = \'moderator\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (true === $sendToSuperModerator) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$recipientTypes[] = \'superModerator\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("foreach ($recipientTypes as $recipientType) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$notifyArgs = [");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("\'recipientType\' => $recipientType,");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("\'action\' => $actionId,");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("\'entity\' => $entity");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("];");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$result = $this->notificationHelper->process($notifyArgs);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// example for custom recipient type using designated entity fields:");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// recipientType => \'field-email^lastname\'");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
}
