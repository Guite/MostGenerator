package org.zikula.modulestudio.generator.cartridges.zclassic.controller.action;

import de.guite.modulestudio.metamodel.Entity;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.StringExtensions;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.UrlExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class LoggableHistory {
  @Extension
  private FormattingExtensions _formattingExtensions = new FormattingExtensions();
  
  @Extension
  private UrlExtensions _urlExtensions = new UrlExtensions();
  
  @Extension
  private Utils _utils = new Utils();
  
  public CharSequence generate(final Entity it, final Boolean isBase) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _loggableHistory = this.loggableHistory(it, isBase, Boolean.valueOf(true));
    _builder.append(_loggableHistory);
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    CharSequence _loggableHistory_1 = this.loggableHistory(it, isBase, Boolean.valueOf(false));
    _builder.append(_loggableHistory_1);
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence loggableHistory(final Entity it, final Boolean isBase, final Boolean isAdmin) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _loggableHistoryDocBlock = this.loggableHistoryDocBlock(it, isBase, isAdmin);
    _builder.append(_loggableHistoryDocBlock);
    _builder.newLineIfNotEmpty();
    _builder.append("public function ");
    {
      if ((isAdmin).booleanValue()) {
        _builder.append("adminL");
      } else {
        _builder.append("l");
      }
    }
    _builder.append("oggableHistoryAction(Request $request, $id = 0)");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    {
      if ((isBase).booleanValue()) {
        _builder.append("    ");
        _builder.append("return $this->loggableHistoryActionInternal($request, $id, ");
        String _displayBool = this._formattingExtensions.displayBool(isAdmin);
        _builder.append(_displayBool, "    ");
        _builder.append(");");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("    ");
        _builder.append("return parent::");
        {
          if ((isAdmin).booleanValue()) {
            _builder.append("adminL");
          } else {
            _builder.append("l");
          }
        }
        _builder.append("oggableHistoryAction($request, $id);");
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
        _builder.append("* This method includes the common implementation code for adminLoggableHistoryAction() and loggableHistoryAction().");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @param Request $request Current request instance");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @param integer $id      Identifier of ");
        String _formatForDisplay = this._formattingExtensions.formatForDisplay(it.getName());
        _builder.append(_formatForDisplay, " ");
        _builder.newLineIfNotEmpty();
        _builder.append(" ");
        _builder.append("* @param Boolean $isAdmin Whether the admin area is used or not");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
        _builder.append("protected function loggableHistoryActionInternal(Request $request, $id = 0, $isAdmin = false)");
        _builder.newLine();
        _builder.append("{");
        _builder.newLine();
        _builder.append("    ");
        CharSequence _loggableHistoryBaseImpl = this.loggableHistoryBaseImpl(it);
        _builder.append(_loggableHistoryBaseImpl, "    ");
        _builder.newLineIfNotEmpty();
        _builder.append("}");
        _builder.newLine();
      }
    }
    return _builder;
  }
  
  private CharSequence loggableHistoryDocBlock(final Entity it, final Boolean isBase, final Boolean isAdmin) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* This method provides a change history for a given ");
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(it.getName());
    _builder.append(_formatForDisplay, " ");
    _builder.append(".");
    _builder.newLineIfNotEmpty();
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
        String _formatForCode = this._formattingExtensions.formatForCode(it.getName());
        _builder.append(_formatForCode, " ");
        _builder.append("/history/{id}\",");
        _builder.newLineIfNotEmpty();
        _builder.append(" ");
        _builder.append("*        requirements = {\"id\" = \"\\d+\"},");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*        defaults = {\"id\" = 0},");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*        methods = {\"GET\"}");
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
    _builder.append("* @param integer $id      Identifier of ");
    String _formatForDisplay_1 = this._formattingExtensions.formatForDisplay(it.getName());
    _builder.append(_formatForDisplay_1, " ");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return Response Output");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @throws NotFoundHttpException Thrown if invalid identifier is given or the ");
    String _formatForDisplay_2 = this._formattingExtensions.formatForDisplay(it.getName());
    _builder.append(_formatForDisplay_2, " ");
    _builder.append(" isn\'t found");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence loggableHistoryBaseImpl(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("if (empty($id)) {");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("throw new NotFoundHttpException($this->__(\'No such ");
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(it.getName());
    _builder.append(_formatForDisplay, "    ");
    _builder.append(" found.\'));");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("$entityFactory = $this->get(\'");
    String _appService = this._utils.appService(it.getApplication());
    _builder.append(_appService);
    _builder.append(".entity_factory\');");
    _builder.newLineIfNotEmpty();
    _builder.append("$");
    String _formatForCode = this._formattingExtensions.formatForCode(it.getName());
    _builder.append(_formatForCode);
    _builder.append(" = $entityFactory->getRepository(\'");
    String _formatForCode_1 = this._formattingExtensions.formatForCode(it.getName());
    _builder.append(_formatForCode_1);
    _builder.append("\')->selectById($id);");
    _builder.newLineIfNotEmpty();
    _builder.append("if (null === $");
    String _formatForCode_2 = this._formattingExtensions.formatForCode(it.getName());
    _builder.append(_formatForCode_2);
    _builder.append(") {");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("throw new NotFoundHttpException($this->__(\'No such ");
    String _formatForDisplay_1 = this._formattingExtensions.formatForDisplay(it.getName());
    _builder.append(_formatForDisplay_1, "    ");
    _builder.append(" found.\'));");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("$routeArea = $isAdmin ? \'admin\' : \'\';");
    _builder.newLine();
    _builder.append("$entityManager = $entityFactory->getObjectManager();");
    _builder.newLine();
    _builder.append("$logEntriesRepository = $entityManager->getRepository(\'");
    String _appName = this._utils.appName(it.getApplication());
    _builder.append(_appName);
    _builder.append(":");
    String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital);
    _builder.append("LogEntryEntity\');");
    _builder.newLineIfNotEmpty();
    _builder.append("$logEntries = $logEntriesRepository->getLogEntries($");
    String _formatForCode_3 = this._formattingExtensions.formatForCode(it.getName());
    _builder.append(_formatForCode_3);
    _builder.append(");");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("$revertToVersion = $request->query->getInt(\'revert\', 0);");
    _builder.newLine();
    _builder.append("if ($revertToVersion > 0 && count($logEntries) > 1) {");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// revert to requested version");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$logEntriesRepository->revert($");
    String _formatForCode_4 = this._formattingExtensions.formatForCode(it.getName());
    _builder.append(_formatForCode_4, "    ");
    _builder.append(", $revertToVersion);");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("try {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// execute the workflow action");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$workflowHelper = $this->get(\'");
    String _appService_1 = this._utils.appService(it.getApplication());
    _builder.append(_appService_1, "        ");
    _builder.append(".workflow_helper\');");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("$success = $workflowHelper->executeAction($");
    String _formatForCode_5 = this._formattingExtensions.formatForCode(it.getName());
    _builder.append(_formatForCode_5, "        ");
    _builder.append(", \'update\'");
    {
      Boolean _targets = this._utils.targets(it.getApplication(), "1.5");
      if ((_targets).booleanValue()) {
        _builder.append(" . $");
        String _formatForCode_6 = this._formattingExtensions.formatForCode(it.getName());
        _builder.append(_formatForCode_6, "        ");
        _builder.append("->getWorkflowState()");
      }
    }
    _builder.append(");");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if ($success) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$this->addFlash(\'status\', $this->__f(\'Done! Reverted ");
    String _formatForDisplay_2 = this._formattingExtensions.formatForDisplay(it.getName());
    _builder.append(_formatForDisplay_2, "            ");
    _builder.append(" to version %version%.\', [\'%version%\' => $revertToVersion]));");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("} else {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$this->addFlash(\'error\', $this->__f(\'Error! Reverting ");
    String _formatForDisplay_3 = this._formattingExtensions.formatForDisplay(it.getName());
    _builder.append(_formatForDisplay_3, "            ");
    _builder.append(" to version %version% failed.\', [\'%version%\' => $revertToVersion]));");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("} catch(\\Exception $e) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$this->addFlash(\'error\', $this->__f(\'Sorry, but an error occured during the %action% action. Please apply the changes again!\', [\'%action%\' => \'update\']) . \'  \' . $e->getMessage());");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $this->redirectToRoute(\'");
    String _formatForDB = this._formattingExtensions.formatForDB(this._utils.appName(it.getApplication()));
    _builder.append(_formatForDB, "    ");
    _builder.append("_");
    String _formatForDB_1 = this._formattingExtensions.formatForDB(it.getName());
    _builder.append(_formatForDB_1, "    ");
    _builder.append("_\' . $routeArea . \'loggablehistory\', [");
    CharSequence _routeParams = this._urlExtensions.routeParams(it, this._formattingExtensions.formatForCode(it.getName()), Boolean.valueOf(false));
    _builder.append(_routeParams, "    ");
    _builder.append("]);");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("$isDiffView = false;");
    _builder.newLine();
    _builder.append("$versions = $request->query->get(\'versions\', []);");
    _builder.newLine();
    _builder.append("if (is_array($versions) && count($versions) == 2) {");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$isDiffView = true;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$allVersionsExist = true;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("foreach ($versions as $versionNumber) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$versionExists = false;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("foreach ($logEntries as $logEntry) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("if ($versionNumber == $logEntry->getVersion()) {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("$versionExists = true;");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("break;");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if (!$versionExists) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$allVersionsExist = false;");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("break;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!$allVersionsExist) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$isDiffView = false;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("$templateParameters = [");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("\'routeArea\' => $routeArea,");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("\'");
    String _formatForCode_7 = this._formattingExtensions.formatForCode(it.getName());
    _builder.append(_formatForCode_7, "    ");
    _builder.append("\' => $");
    String _formatForCode_8 = this._formattingExtensions.formatForCode(it.getName());
    _builder.append(_formatForCode_8, "    ");
    _builder.append(",");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("\'logEntries\' => $logEntries,");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("\'isDiffView\' => $isDiffView");
    _builder.newLine();
    _builder.append("];");
    _builder.newLine();
    _builder.newLine();
    _builder.append("if (true === $isDiffView) {");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$minVersion = $maxVersion = 0;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($versions[0] < $versions[1]) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$minVersion = $versions[0];");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$maxVersion = $versions[1];");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("} else {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$minVersion = $versions[1];");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$maxVersion = $versions[0];");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$logEntries = array_reverse($logEntries);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$diffValues = [];");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("foreach ($logEntries as $logEntry) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("foreach ($logEntry->getData() as $field => $value) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("if (!isset($diffValues[$field])) {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("$diffValues[$field] = [");
    _builder.newLine();
    _builder.append("                    ");
    _builder.append("\'old\' => \'\',");
    _builder.newLine();
    _builder.append("                    ");
    _builder.append("\'new\' => \'\',");
    _builder.newLine();
    _builder.append("                    ");
    _builder.append("\'changed\' => false");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("];");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("if (is_array($value)) {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("$value = implode(\', \', $value);");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("if ($logEntry->getVersion() <= $minVersion) {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("$diffValues[$field][\'old\'] = $value;");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("$diffValues[$field][\'new\'] = $value;");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("} elseif ($logEntry->getVersion() <= $maxVersion) {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("$diffValues[$field][\'new\'] = $value;");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("$diffValues[$field][\'changed\'] = $diffValues[$field][\'new\'] != $diffValues[$field][\'old\'];");
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
    _builder.append("    ");
    _builder.append("$templateParameters[\'minVersion\'] = $minVersion;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$templateParameters[\'maxVersion\'] = $maxVersion;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$templateParameters[\'diffValues\'] = $diffValues;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("return $this->render(\'@");
    String _appName_1 = this._utils.appName(it.getApplication());
    _builder.append(_appName_1);
    _builder.append("/");
    String _firstUpper = StringExtensions.toFirstUpper(this._formattingExtensions.formatForCode(it.getName()));
    _builder.append(_firstUpper);
    _builder.append("/history.html.twig\', $templateParameters);");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
}
