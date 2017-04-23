package org.zikula.modulestudio.generator.cartridges.zclassic.controller.action;

import de.guite.modulestudio.metamodel.Entity;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.xbase.lib.Extension;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class MassHandling {
  @Extension
  private FormattingExtensions _formattingExtensions = new FormattingExtensions();
  
  @Extension
  private Utils _utils = new Utils();
  
  public CharSequence generate(final Entity it, final Boolean isBase) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _handleSelectedObjects = this.handleSelectedObjects(it, isBase, Boolean.valueOf(true));
    _builder.append(_handleSelectedObjects);
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    CharSequence _handleSelectedObjects_1 = this.handleSelectedObjects(it, isBase, Boolean.valueOf(false));
    _builder.append(_handleSelectedObjects_1);
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence handleSelectedObjects(final Entity it, final Boolean isBase, final Boolean isAdmin) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _handleSelectedObjectsDocBlock = this.handleSelectedObjectsDocBlock(it, isBase, isAdmin);
    _builder.append(_handleSelectedObjectsDocBlock);
    _builder.newLineIfNotEmpty();
    _builder.append("public function ");
    {
      if ((isAdmin).booleanValue()) {
        _builder.append("adminH");
      } else {
        _builder.append("h");
      }
    }
    _builder.append("andleSelectedEntriesAction(Request $request)");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    {
      if ((isBase).booleanValue()) {
        _builder.append("    ");
        _builder.append("return $this->handleSelectedEntriesActionInternal($request, ");
        String _displayBool = this._formattingExtensions.displayBool(isAdmin);
        _builder.append(_displayBool, "    ");
        _builder.append(");");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("    ");
        _builder.append("return parent::");
        {
          if ((isAdmin).booleanValue()) {
            _builder.append("adminH");
          } else {
            _builder.append("h");
          }
        }
        _builder.append("andleSelectedEntriesAction($request);");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("}");
    _builder.newLine();
    {
      if (((isBase).booleanValue() && (!(isAdmin).booleanValue()))) {
        _builder.newLine();
        _builder.append("/**");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* This method includes the common implementation code for adminHandleSelectedEntriesAction() and handleSelectedEntriesAction().");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @param Request $request Current request instance");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @param Boolean $isAdmin Whether the admin area is used or not");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
        _builder.append("protected function handleSelectedEntriesActionInternal(Request $request, $isAdmin = false)");
        _builder.newLine();
        _builder.append("{");
        _builder.newLine();
        _builder.append("    ");
        CharSequence _handleSelectedObjectsBaseImpl = this.handleSelectedObjectsBaseImpl(it);
        _builder.append(_handleSelectedObjectsBaseImpl, "    ");
        _builder.newLineIfNotEmpty();
        _builder.append("}");
        _builder.newLine();
      }
    }
    return _builder;
  }
  
  private CharSequence handleSelectedObjectsDocBlock(final Entity it, final Boolean isBase, final Boolean isAdmin) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Process status changes for multiple items.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* This function processes the items selected in the admin view page.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Multiple items may have their state changed or be deleted.");
    _builder.newLine();
    {
      if ((!(isBase).booleanValue())) {
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @Route(\"/");
        {
          if ((isAdmin).booleanValue()) {
            _builder.append("admin/");
          }
        }
        String _formatForCode = this._formattingExtensions.formatForCode(it.getNameMultiple());
        _builder.append(_formatForCode, " ");
        _builder.append("/handleSelectedEntries\",");
        _builder.newLineIfNotEmpty();
        _builder.append(" ");
        _builder.append("*        methods = {\"POST\"}");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* )");
        _builder.newLine();
        {
          if ((isAdmin).booleanValue()) {
            _builder.append(" ");
            _builder.append("* @Theme(\"admin\")");
            _builder.newLine();
          }
        }
      }
    }
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param Request $request Current request instance");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return RedirectResponse");
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
    return _builder;
  }
  
  private CharSequence handleSelectedObjectsBaseImpl(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("$objectType = \'");
    String _formatForCode = this._formattingExtensions.formatForCode(it.getName());
    _builder.append(_formatForCode);
    _builder.append("\';");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("// Get parameters");
    _builder.newLine();
    _builder.append("$action = $request->request->get(\'action\', null);");
    _builder.newLine();
    _builder.append("$items = $request->request->get(\'items\', null);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("$action = strtolower($action);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("$repository = $this->get(\'");
    String _appService = this._utils.appService(it.getApplication());
    _builder.append(_appService);
    _builder.append(".entity_factory\')->getRepository($objectType);");
    _builder.newLineIfNotEmpty();
    _builder.append("$workflowHelper = $this->get(\'");
    String _appService_1 = this._utils.appService(it.getApplication());
    _builder.append(_appService_1);
    _builder.append(".workflow_helper\');");
    _builder.newLineIfNotEmpty();
    {
      boolean _isSkipHookSubscribers = it.isSkipHookSubscribers();
      boolean _not = (!_isSkipHookSubscribers);
      if (_not) {
        _builder.append("$hookHelper = $this->get(\'");
        String _appService_2 = this._utils.appService(it.getApplication());
        _builder.append(_appService_2);
        _builder.append(".hook_helper\');");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("$logger = $this->get(\'logger\');");
    _builder.newLine();
    _builder.append("$userName = $this->get(\'zikula_users_module.current_user\')->get(\'uname\');");
    _builder.newLine();
    _builder.newLine();
    _builder.append("// process each item");
    _builder.newLine();
    _builder.append("foreach ($items as $itemId) {");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// check if item exists, and get record instance");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$entity = $repository->selectById($itemId, false);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (null === $entity) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("continue;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    {
      Boolean _targets = this._utils.targets(it.getApplication(), "1.5");
      boolean _not_1 = (!(_targets).booleanValue());
      if (_not_1) {
        _builder.append("    ");
        _builder.append("$entity->initWorkflow();");
        _builder.newLine();
      }
    }
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// check if $action can be applied to this entity (may depend on it\'s current workflow state)");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$allowedActions = $workflowHelper->getActionsForObject($entity);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$actionIds = array_keys($allowedActions);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!in_array($action, $actionIds)) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// action not allowed, skip this object");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("continue;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    {
      boolean _isSkipHookSubscribers_1 = it.isSkipHookSubscribers();
      boolean _not_2 = (!_isSkipHookSubscribers_1);
      if (_not_2) {
        _builder.append("    ");
        _builder.append("// Let any hooks perform additional validation actions");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$hookType = $action == \'delete\' ? \'validate_delete\' : \'validate_edit\';");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$validationHooksPassed = $hookHelper->callValidationHooks($entity, $hookType);");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("if (!$validationHooksPassed) {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("continue;");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
        _builder.newLine();
      }
    }
    _builder.append("    ");
    _builder.append("$success = false;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("try {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// execute the workflow action");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$success = $workflowHelper->executeAction($entity, $action);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("} catch(\\Exception $e) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$this->addFlash(\'error\', $this->__f(\'Sorry, but an error occured during the %action% action.\', [\'%action%\' => $action]) . \'  \' . $e->getMessage());");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$logger->error(\'{app}: User {user} tried to execute the {action} workflow action for the {entity} with id {id}, but failed. Error details: {errorMessage}.\', [\'app\' => \'");
    String _appName = this._utils.appName(it.getApplication());
    _builder.append(_appName, "        ");
    _builder.append("\', \'user\' => $userName, \'action\' => $action, \'entity\' => \'");
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(it.getName());
    _builder.append(_formatForDisplay, "        ");
    _builder.append("\', \'id\' => $itemId, \'errorMessage\' => $e->getMessage()]);");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!$success) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("continue;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($action == \'delete\') {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$this->addFlash(\'status\', $this->__(\'Done! Item deleted.\'));");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$logger->notice(\'{app}: User {user} deleted the {entity} with id {id}.\', [\'app\' => \'");
    String _appName_1 = this._utils.appName(it.getApplication());
    _builder.append(_appName_1, "        ");
    _builder.append("\', \'user\' => $userName, \'entity\' => \'");
    String _formatForDisplay_1 = this._formattingExtensions.formatForDisplay(it.getName());
    _builder.append(_formatForDisplay_1, "        ");
    _builder.append("\', \'id\' => $itemId]);");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("} else {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$this->addFlash(\'status\', $this->__(\'Done! Item updated.\'));");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$logger->notice(\'{app}: User {user} executed the {action} workflow action for the {entity} with id {id}.\', [\'app\' => \'");
    String _appName_2 = this._utils.appName(it.getApplication());
    _builder.append(_appName_2, "        ");
    _builder.append("\', \'user\' => $userName, \'action\' => $action, \'entity\' => \'");
    String _formatForDisplay_2 = this._formattingExtensions.formatForDisplay(it.getName());
    _builder.append(_formatForDisplay_2, "        ");
    _builder.append("\', \'id\' => $itemId]);");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    {
      boolean _isSkipHookSubscribers_2 = it.isSkipHookSubscribers();
      boolean _not_3 = (!_isSkipHookSubscribers_2);
      if (_not_3) {
        _builder.newLine();
        _builder.append("    ");
        _builder.append("// Let any hooks know that we have updated or deleted an item");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$hookType = $action == \'delete\' ? \'process_delete\' : \'process_edit\';");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$url = null;");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("if ($action != \'delete\') {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("$urlArgs = $entity->createUrlArgs();");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("$urlArgs[\'_locale\'] = $request->getLocale();");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("$url = new RouteUrl(\'");
        String _formatForDB = this._formattingExtensions.formatForDB(this._utils.appName(it.getApplication()));
        _builder.append(_formatForDB, "        ");
        _builder.append("_");
        String _formatForCode_1 = this._formattingExtensions.formatForCode(it.getName());
        _builder.append(_formatForCode_1, "        ");
        _builder.append("_\' . /*($isAdmin ? \'admin\' : \'\') . */\'display\', $urlArgs);");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$hookHelper->callProcessHooks($entity, $hookType, $url);");
        _builder.newLine();
      }
    }
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("return $this->redirectToRoute(\'");
    String _formatForDB_1 = this._formattingExtensions.formatForDB(this._utils.appName(it.getApplication()));
    _builder.append(_formatForDB_1);
    _builder.append("_");
    String _formatForDB_2 = this._formattingExtensions.formatForDB(it.getName());
    _builder.append(_formatForDB_2);
    _builder.append("_\' . ($isAdmin ? \'admin\' : \'\') . \'index\');");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
}
