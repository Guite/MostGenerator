package org.zikula.modulestudio.generator.cartridges.zclassic.controller.apis;

import com.google.inject.Inject;
import de.guite.modulestudio.metamodel.modulestudio.Action;
import de.guite.modulestudio.metamodel.modulestudio.Application;
import de.guite.modulestudio.metamodel.modulestudio.Controller;
import de.guite.modulestudio.metamodel.modulestudio.Controllers;
import de.guite.modulestudio.metamodel.modulestudio.UserController;
import java.util.Arrays;
import org.eclipse.emf.common.util.EList;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.eclipse.xtext.xbase.lib.StringExtensions;
import org.zikula.modulestudio.generator.extensions.ControllerExtensions;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class ShortUrls {
  @Inject
  @Extension
  private ControllerExtensions _controllerExtensions = new Function0<ControllerExtensions>() {
    public ControllerExtensions apply() {
      ControllerExtensions _controllerExtensions = new ControllerExtensions();
      return _controllerExtensions;
    }
  }.apply();
  
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
  private Utils _utils = new Function0<Utils>() {
    public Utils apply() {
      Utils _utils = new Utils();
      return _utils;
    }
  }.apply();
  
  private Application app;
  
  public ShortUrls(final Application it) {
    this.app = it;
  }
  
  protected CharSequence _generate(final Controller it) {
    return null;
  }
  
  protected CharSequence _generate(final UserController it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.newLine();
    CharSequence _encodeUrl = this.encodeUrl(it);
    _builder.append(_encodeUrl, "");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    CharSequence _decodeUrl = this.decodeUrl(it);
    _builder.append(_decodeUrl, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  public CharSequence encodeUrl(final UserController it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Forms custom url string.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param array $args List of arguments.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return string custom url string");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function encodeurl(array $args = array())");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// check if we have the required input");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!isset($args[\'modname\']) || !isset($args[\'func\'])) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return LogUtil::registerArgsError();");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// set default values");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!isset($args[\'type\'])) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$args[\'type\'] = \'user\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!isset($args[\'args\'])) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$args[\'args\'] = array();");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// return if function url scheme is not being customised");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$customFuncs = array(");
    {
      boolean _hasActions = this._controllerExtensions.hasActions(it, "view");
      if (_hasActions) {
        _builder.append("\'view\'");
        {
          boolean _hasActions_1 = this._controllerExtensions.hasActions(it, "display");
          if (_hasActions_1) {
            _builder.append(", ");
          }
        }
      }
    }
    {
      boolean _hasActions_2 = this._controllerExtensions.hasActions(it, "display");
      if (_hasActions_2) {
        _builder.append("\'display\'");
      }
    }
    _builder.append(");");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("if (!in_array($args[\'func\'], $customFuncs)) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return false;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// initialise url routing rules");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$routerFacade = new ");
    {
      boolean _targets = this._utils.targets(this.app, "1.3.5");
      if (_targets) {
        String _appName = this._utils.appName(this.app);
        _builder.append(_appName, "    ");
        _builder.append("_");
      }
    }
    _builder.append("RouterFacade();");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("// get router itself for convenience");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$router = $routerFacade->getRouter();");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// initialise object type");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$controllerHelper = new ");
    {
      boolean _targets_1 = this._utils.targets(this.app, "1.3.5");
      if (_targets_1) {
        String _appName_1 = this._utils.appName(this.app);
        _builder.append(_appName_1, "    ");
        _builder.append("_Util_Controller");
      } else {
        _builder.append("ControllerUtil");
      }
    }
    _builder.append("($this->serviceManager");
    {
      boolean _targets_2 = this._utils.targets(this.app, "1.3.5");
      boolean _not = (!_targets_2);
      if (_not) {
        _builder.append(", ModUtil::getModule($this->name)");
      }
    }
    _builder.append(");");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("$utilArgs = array(\'controller\' => \'user\', \'action\' => \'encodeurl\');");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$allowedObjectTypes = $controllerHelper->getObjectTypes(\'api\', $utilArgs);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$objectType = ((isset($args[\'args\'][\'ot\']) && in_array($args[\'args\'][\'ot\'], $allowedObjectTypes)) ? $args[\'args\'][\'ot\'] : $controllerHelper->getDefaultObjectType(\'api\', $utilArgs));");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// initialise group folder");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$groupFolder = $routerFacade->getGroupingFolderFromObjectType($objectType, $args[\'func\'], $args[\'args\']);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// start pre processing");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// convert object type to group folder");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$args[\'args\'][\'ot\'] = $groupFolder;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// handle special templates");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$displayDefaultEnding = System::getVar(\'shorturlsext\', \'html\');");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$endingPrefix = ($args[\'func\'] == \'view\') ? \'.\' : \'\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("foreach (array(\'csv\', \'rss\', \'atom\', \'xml\', \'pdf\', \'json\', \'kml\') as $ending) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if (!isset($args[\'args\'][\'use\' . $ending . \'ext\'])) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("continue;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if ($args[\'args\'][\'use\' . $ending . \'ext\'] == \'1\') {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$args[\'args\'][$args[\'func\'] . \'ending\'] = $endingPrefix . $ending;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("unset($args[\'args\'][\'use\' . $ending . \'ext\']);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// fallback to default templates");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!isset($args[\'args\'][$args[\'func\'] . \'ending\'])) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if ($args[\'func\'] == \'view\') {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$args[\'args\'][$args[\'func\'] . \'ending\'] = \'\';//\'/\';");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("} else if ($args[\'func\'] == \'display\') {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$args[\'args\'][$args[\'func\'] . \'ending\'] = $displayDefaultEnding;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($args[\'func\'] == \'view\') {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// TODO filter views (e.g. /orders/customer/mr-smith.csv)");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$filterEntities = array(\'customer\', \'region\', \'federalstate\', \'country\');");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("foreach ($filterEntities as $filterEntity) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$filterField = $filterEntity . \'id\';");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("if (!isset($args[\'args\'][$filterField]) || !$args[\'args\'][$filterField]) {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("continue;");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$filterId = $args[\'args\'][$filterField];");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("unset($args[\'args\'][$filterField]);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$filterGroupFolder = $routerFacade->getGroupingFolderFromObjectType($filterEntity, \'display\', $args[\'args\']);");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$filterSlug = $routerFacade->getFormattedSlug($filterEntity, \'display\', $args[\'args\'], $filterId);");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$result .= $filterGroupFolder . \'/\' . $filterSlug .\'/\';");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("break;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("} elseif ($args[\'func\'] == \'display\') {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// determine given id");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$id = 0;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("foreach (array(\'id\', strtolower($objectType) . \'id\', \'objectid\') as $idFieldName) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("if (isset($args[\'args\'][$idFieldName])) {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("$id = $args[\'args\'][$idFieldName];");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("unset($args[\'args\'][$idFieldName]);");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// check if we have a valid slug given");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if (isset($args[\'args\'][\'slug\']) && (!$args[\'args\'][\'slug\'] || $args[\'args\'][\'slug\'] == $id)) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("unset($args[\'args\'][\'slug\']);");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// try to determine missing slug");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if (!isset($args[\'args\'][\'slug\'])) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$slug = \'\';");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("if ($id > 0) {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("$slug = $routerFacade->getFormattedSlug($objectType, $args[\'func\'], $args[\'args\'], $id);");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("if (!empty($slug) && $slug != $id) {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("// add slug expression");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("$args[\'args\'][\'slug\'] = $slug;");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// check if we have one now");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if (!isset($args[\'args\'][\'slug\'])) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("// readd id as fallback");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$args[\'args\'][\'id\'] = $id;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// add func as first argument");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$routerArgs = array_merge(array(\'func\' => $args[\'func\']), $args[\'args\']);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// now create url based on params");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$result = $router->generate(null, $routerArgs);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// post processing");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("($args[\'func\'] == \'view\' && !empty($args[\'args\'][\'viewending\']))");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("|| $args[\'func\'] == \'display\') {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// check if url ends with a trailing slash");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if (substr($result, -1) == \'/\') {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("// remove the trailing slash");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$result = substr($result, 0, strlen($result) - 1);");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// enforce url name of the module, but do only 1 replacement to avoid changing other params");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$modInfo = ModUtil::getInfoFromName(\'");
    String _appName_2 = this._utils.appName(this.app);
    _builder.append(_appName_2, "    ");
    _builder.append("\');");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("$result = preg_replace(\'/\' . $modInfo[\'name\'] . \'/\', $modInfo[\'url\'], $result, 1);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $result;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  public CharSequence decodeUrl(final UserController it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Decodes the custom url string.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param array $args List of arguments.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return bool true if successful, false otherwise");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function decodeurl(array $args = array())");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// check we actually have some vars to work with");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!is_array($args) || !isset($args[\'vars\']) || !is_array($args[\'vars\']) || !count($args[\'vars\'])) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return LogUtil::registerArgsError();");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// define the available user functions");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$funcs = array(");
    {
      EList<Action> _actions = it.getActions();
      boolean _hasElements = false;
      for(final Action action : _actions) {
        if (!_hasElements) {
          _hasElements = true;
        } else {
          _builder.appendImmediate(", ", "    ");
        }
        _builder.append("\'");
        String _name = action.getName();
        String _formatForCode = this._formattingExtensions.formatForCode(_name);
        String _firstLower = StringExtensions.toFirstLower(_formatForCode);
        _builder.append(_firstLower, "    ");
        _builder.append("\'");
      }
    }
    _builder.append(");");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// return if function url scheme is not being customised");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$customFuncs = array(");
    {
      boolean _hasActions = this._controllerExtensions.hasActions(it, "view");
      if (_hasActions) {
        _builder.append("\'view\'");
        {
          boolean _hasActions_1 = this._controllerExtensions.hasActions(it, "display");
          if (_hasActions_1) {
            _builder.append(", ");
          }
        }
      }
    }
    {
      boolean _hasActions_2 = this._controllerExtensions.hasActions(it, "display");
      if (_hasActions_2) {
        _builder.append("\'display\'");
      }
    }
    _builder.append(");");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// set the correct function name based on our input");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (empty($args[\'vars\'][2])) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// no func and no vars = ");
    {
      Controllers _container = it.getContainer();
      Application _application = _container.getApplication();
      boolean _targets = this._utils.targets(_application, "1.3.5");
      if (_targets) {
        _builder.append("main");
      } else {
        _builder.append("index");
      }
    }
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("System::queryStringSetVar(\'func\', \'");
    {
      Controllers _container_1 = it.getContainer();
      Application _application_1 = _container_1.getApplication();
      boolean _targets_1 = this._utils.targets(_application_1, "1.3.5");
      if (_targets_1) {
        _builder.append("main");
      } else {
        _builder.append("index");
      }
    }
    _builder.append("\');");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("return true;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("} else if (in_array($args[\'vars\'][2], $funcs) && !in_array($args[\'vars\'][2], $customFuncs)) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// normal url scheme, no need for special decoding");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return false;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$func = $args[\'vars\'][2];");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// usually the language is in $args[\'vars\'][0], except no mod name is in the url and we are set as start app");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$modInfo = ModUtil::getInfoFromName(\'");
    String _appName = this._utils.appName(this.app);
    _builder.append(_appName, "    ");
    _builder.append("\');");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("$lang = (strtolower($args[\'vars\'][0]) == $modInfo[\'url\']) ? $args[\'vars\'][1] : $args[\'vars\'][0];");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// remove some unrequired parameters");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("foreach ($_GET as $k => $v) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if (in_array($k, array(\'module\', \'type\', \'func\', \'lang\', \'ot\')) === false) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("unset($_GET[$k]);");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// process all args except language and module");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$urlVars = array_slice($args[\'vars\'], 2); // all except [0] and [1]");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// get arguments as string");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$url = implode(\'/\', $urlVars);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// check if default view urls end with a trailing slash");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($func == \'view\' && strpos($url, \'.\') === false && substr($url, -1) != \'/\') {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// add missing trailing slash");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$url .= \'/\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$isDefaultModule = (System::getVar(\'shorturlsdefaultmodule\', \'\') == $modInfo[\'name\']);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!$isDefaultModule) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$url = $modInfo[\'url\'] . \'/\' . $url;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// initialise url routing rules");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$routerFacade = new ");
    {
      boolean _targets_2 = this._utils.targets(this.app, "1.3.5");
      if (_targets_2) {
        String _appName_1 = this._utils.appName(this.app);
        _builder.append(_appName_1, "    ");
        _builder.append("_");
      }
    }
    _builder.append("RouterFacade();");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("// get router itself for convenience");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$router = $routerFacade->getRouter();");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// read params out of url");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$parameters = $router->parse($url);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("//var_dump($parameters);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!$parameters || !is_array($parameters)) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return false;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// post processing");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!isset($parameters[\'func\'])) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$parameters[\'func\'] = \'");
    {
      boolean _hasActions_3 = this._controllerExtensions.hasActions(it, "view");
      if (_hasActions_3) {
        _builder.append("view");
      } else {
        boolean _hasActions_4 = this._controllerExtensions.hasActions(it, "display");
        if (_hasActions_4) {
          _builder.append("display");
        } else {
          {
            Controllers _container_2 = it.getContainer();
            Application _application_2 = _container_2.getApplication();
            boolean _targets_3 = this._utils.targets(_application_2, "1.3.5");
            if (_targets_3) {
              _builder.append("main");
            } else {
              _builder.append("index");
            }
          }
        }
      }
    }
    _builder.append("\';");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$func = $parameters[\'func\'];");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// convert group folder to object type");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$parameters[\'ot\'] = $routerFacade->getObjectTypeFromGroupingFolder($parameters[\'ot\'], $func);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// handle special templates");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$displayDefaultEnding = System::getVar(\'shorturlsext\', \'html\');");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$endingPrefix = ($func == \'view\') ? \'.\' : \'\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (isset($parameters[$func . \'ending\']) && !empty($parameters[$func . \'ending\']) && $parameters[$func . \'ending\'] != ($endingPrefix . $displayDefaultEnding)) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if ($func == \'view\') {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$parameters[$func . \'ending\'] = str_replace($endingPrefix, \'\', $parameters[$func . \'ending\']);");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$parameters[\'use\' . $parameters[$func . \'ending\'] . \'ext\'] = \'1\';");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("unset($parameters[$func . \'ending\']);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// rename id to objid (primary key for display pages, optional filter id for view pages)");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/* may be obsolete now");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (isset($parameters[\'id\'])) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$parameters[strtolower($parameters[\'ot\']) . \'id\'] = $parameters[\'id\'];");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("unset($parameters[\'id\']);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}*/");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// write vars to GET");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("foreach ($parameters as $k => $v) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("System::queryStringSetVar($k, $v);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return true;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  public CharSequence generate(final Controller it) {
    if (it instanceof UserController) {
      return _generate((UserController)it);
    } else if (it != null) {
      return _generate(it);
    } else {
      throw new IllegalArgumentException("Unhandled parameter types: " +
        Arrays.<Object>asList(it).toString());
    }
  }
}
