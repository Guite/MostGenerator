package org.zikula.modulestudio.generator.cartridges.zclassic.controller.additions;

import de.guite.modulestudio.metamodel.Application;
import de.guite.modulestudio.metamodel.Entity;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper;
import org.zikula.modulestudio.generator.extensions.ControllerExtensions;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class MultiHook {
  @Extension
  private ControllerExtensions _controllerExtensions = new ControllerExtensions();
  
  @Extension
  private FormattingExtensions _formattingExtensions = new FormattingExtensions();
  
  @Extension
  private ModelExtensions _modelExtensions = new ModelExtensions();
  
  @Extension
  private NamingExtensions _namingExtensions = new NamingExtensions();
  
  @Extension
  private Utils _utils = new Utils();
  
  private FileHelper fh = new FileHelper();
  
  private Application app;
  
  public void generate(final Application it, final IFileSystemAccess fsa) {
    this.app = it;
    final Function1<Entity, Boolean> _function = (Entity it_1) -> {
      return Boolean.valueOf((this._controllerExtensions.hasViewAction(it_1) || this._controllerExtensions.hasDisplayAction(it_1)));
    };
    Iterable<Entity> _filter = IterableExtensions.<Entity>filter(this._modelExtensions.getAllEntities(it), _function);
    for (final Entity entity : _filter) {
      this.generateNeedle(entity, fsa);
    }
  }
  
  private void generateNeedle(final Entity it, final IFileSystemAccess fsa) {
    String _appSourceLibPath = this._namingExtensions.getAppSourceLibPath(this.app);
    String _plus = (_appSourceLibPath + "Needles/");
    String _formatForDB = this._formattingExtensions.formatForDB(it.getName());
    String _plus_1 = (_plus + _formatForDB);
    String _plus_2 = (_plus_1 + "_info.php");
    this._namingExtensions.generateClassPair(this.app, fsa, _plus_2, 
      this.fh.phpFileContent(this.app, this.needleBaseInfo(it)), this.fh.phpFileContent(this.app, this.needleInfo(it)));
    String _appSourceLibPath_1 = this._namingExtensions.getAppSourceLibPath(this.app);
    String _plus_3 = (_appSourceLibPath_1 + "Needles/");
    String _formatForDB_1 = this._formattingExtensions.formatForDB(it.getName());
    String _plus_4 = (_plus_3 + _formatForDB_1);
    String _plus_5 = (_plus_4 + ".php");
    this._namingExtensions.generateClassPair(this.app, fsa, _plus_5, 
      this.fh.phpFileContent(this.app, this.needleBaseImpl(it)), this.fh.phpFileContent(this.app, this.needleImpl(it)));
  }
  
  private CharSequence needleBaseInfo(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* ");
    String _appName = this._utils.appName(this.app);
    _builder.append(_appName, " ");
    _builder.append(" ");
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(it.getName());
    _builder.append(_formatForDisplay, " ");
    _builder.append(" needle information.");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param none");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return string with short usage description");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("function ");
    String _appName_1 = this._utils.appName(this.app);
    _builder.append(_appName_1);
    _builder.append("_needleapi_");
    String _formatForDB = this._formattingExtensions.formatForDB(it.getName());
    _builder.append(_formatForDB);
    _builder.append("_baseInfo()");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$info = [");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// module name");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'module\'  => \'");
    String _appName_2 = this._utils.appName(this.app);
    _builder.append(_appName_2, "        ");
    _builder.append("\',");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("// possible needles");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'info\'    => \'");
    String _upperCase = this.app.getPrefix().toUpperCase();
    _builder.append(_upperCase, "        ");
    _builder.append("{");
    {
      boolean _hasViewAction = this._controllerExtensions.hasViewAction(it);
      if (_hasViewAction) {
        String _upperCase_1 = this._formattingExtensions.formatForCode(it.getNameMultiple()).toUpperCase();
        _builder.append(_upperCase_1, "        ");
      }
    }
    {
      boolean _hasDisplayAction = this._controllerExtensions.hasDisplayAction(it);
      if (_hasDisplayAction) {
        {
          boolean _hasViewAction_1 = this._controllerExtensions.hasViewAction(it);
          if (_hasViewAction_1) {
            _builder.append("|");
          }
        }
        String _upperCase_2 = this._formattingExtensions.formatForCode(it.getName()).toUpperCase();
        _builder.append(_upperCase_2, "        ");
        _builder.append("-");
        String _formatForCode = this._formattingExtensions.formatForCode(it.getName());
        _builder.append(_formatForCode, "        ");
        _builder.append("Id");
      }
    }
    _builder.append("}\',");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("// whether a reverse lookup is possible, needs ");
    String _appName_3 = this._utils.appName(this.app);
    _builder.append(_appName_3, "        ");
    _builder.append("_needleapi_");
    String _formatForDisplay_1 = this._formattingExtensions.formatForDisplay(it.getName());
    _builder.append(_formatForDisplay_1, "        ");
    _builder.append("_inspect() function");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("\'inspect\' => false");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("];");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $info;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence needleBaseImpl(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Replaces a given needle id by the corresponding content.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param array $args Arguments array");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*     int nid The needle id");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return string Replaced value for the needle");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("function ");
    String _appName = this._utils.appName(this.app);
    _builder.append(_appName);
    _builder.append("_needleapi_");
    String _formatForDB = this._formattingExtensions.formatForDB(it.getName());
    _builder.append(_formatForDB);
    _builder.append("_base($args)");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// Get arguments from argument array");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$nid = $args[\'nid\'];");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("unset($args);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// cache the results");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("static $cache;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!isset($cache)) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$cache = [];");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$container = \\ServiceUtil::getManager();");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$translator = $container->get(\'translator.default\');");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (empty($nid)) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return \'<em>\' . htmlspecialchars(__(\'No correct needle id given.\')) . \'</em>\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (isset($cache[$nid])) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// needle is already in cache array");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return $cache[$nid];");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!$container->get(\'kernel\')->isBundle(\'");
    String _appName_1 = this._utils.appName(this.app);
    _builder.append(_appName_1, "    ");
    _builder.append("\')) {");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("$cache[$nid] = \'<em>\' . htmlspecialchars($translator->__f(\'Module \"%moduleName%\" is not available.\', [\'%moduleName%\' => ");
    String _appName_2 = this._utils.appName(this.app);
    _builder.append(_appName_2, "        ");
    _builder.append("\'])) . \'</em>\';");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return $cache[$nid];");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// strip application prefix from needle");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$needleId = str_replace(\'");
    String _upperCase = this.app.getPrefix().toUpperCase();
    _builder.append(_upperCase, "    ");
    _builder.append("\', \'\', $nid);");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$permissionApi = $container->get(\'zikula_permissions_module.api.permission\');");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$router = $container->getService(\'router\');");
    _builder.newLine();
    _builder.newLine();
    {
      boolean _hasViewAction = this._controllerExtensions.hasViewAction(it);
      if (_hasViewAction) {
        _builder.append("    ");
        _builder.append("if ($needleId == \'");
        String _upperCase_1 = this._formattingExtensions.formatForCode(it.getNameMultiple()).toUpperCase();
        _builder.append(_upperCase_1, "    ");
        _builder.append("\') {");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("if (!$permissionApi->hasPermission(\'");
        String _appName_3 = this._utils.appName(this.app);
        _builder.append(_appName_3, "        ");
        _builder.append(":");
        String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(it.getName());
        _builder.append(_formatForCodeCapital, "        ");
        _builder.append(":\', \'::\', ACCESS_READ)) {");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("        ");
        _builder.append("$cache[$nid] = \'\';");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("        ");
        _builder.append("return $cache[$nid];");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$cache[$nid] = \'<a href=\"\' . $router->generate(\'");
        String _formatForDB_1 = this._formattingExtensions.formatForDB(this._utils.appName(this.app));
        _builder.append(_formatForDB_1, "    ");
        _builder.append("_");
        String _formatForDB_2 = this._formattingExtensions.formatForDB(it.getNameMultiple());
        _builder.append(_formatForDB_2, "    ");
        _builder.append("_view\') . \'\" title=\"\' . $translator->__(\'View ");
        String _formatForDisplay = this._formattingExtensions.formatForDisplay(it.getNameMultiple());
        _builder.append(_formatForDisplay, "    ");
        _builder.append("\') . \'\">\' . $translator->__(\'");
        String _formatForDisplayCapital = this._formattingExtensions.formatForDisplayCapital(it.getNameMultiple());
        _builder.append(_formatForDisplayCapital, "    ");
        _builder.append("\') . \'</a>\';");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      boolean _hasDisplayAction = this._controllerExtensions.hasDisplayAction(it);
      if (_hasDisplayAction) {
        _builder.append("    ");
        _builder.append("$needleParts = explode(\'-\', $needleId);");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("if ($needleParts[0] != \'");
        String _upperCase_2 = this._formattingExtensions.formatForCode(it.getName()).toUpperCase();
        _builder.append(_upperCase_2, "    ");
        _builder.append("\' || count($needleParts) < 2) {");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("$cache[$nid] = \'\';");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("return $cache[$nid];");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$entityId = (int)$needleParts[1];");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("if (!$permissionApi->hasPermission(\'");
        String _appName_4 = this._utils.appName(this.app);
        _builder.append(_appName_4, "    ");
        _builder.append(":");
        String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(it.getName());
        _builder.append(_formatForCodeCapital_1, "    ");
        _builder.append(":\', $entityId . \'::\', ACCESS_READ)) {");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("$cache[$nid] = \'\';");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("return $cache[$nid];");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$repository = $container->get(\'");
        String _appService = this._utils.appService(this.app);
        _builder.append(_appService, "    ");
        _builder.append(".entity_factory\')->getRepository(\'");
        String _formatForCode = this._formattingExtensions.formatForCode(it.getName());
        _builder.append(_formatForCode, "    ");
        _builder.append("\');");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("$entity = $repository->selectById($entityId);");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("if (null === $entity) {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("$cache[$nid] = \'<em>\' . $translator->__f(\'");
        String _formatForDisplayCapital_1 = this._formattingExtensions.formatForDisplayCapital(it.getName());
        _builder.append(_formatForDisplayCapital_1, "        ");
        _builder.append(" with id %id% could not be found\', [\'%id%\' => $entityId]) . \'</em>\';");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("return $cache[$nid];");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$title = $entity->getTitleFromDisplayPattern();");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$cache[$nid] = \'<a href=\"\' . $router->generate(\'");
        String _formatForDB_3 = this._formattingExtensions.formatForDB(this._utils.appName(this.app));
        _builder.append(_formatForDB_3, "    ");
        _builder.append("_");
        String _formatForDB_4 = this._formattingExtensions.formatForDB(it.getNameMultiple());
        _builder.append(_formatForDB_4, "    ");
        _builder.append("_display\', [\'id\' => $entityId]) . \'\" title=\"\' . str_replace(\'\"\', \'\', $title) . \'\">\' . $title . \'</a>\';");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $cache[$nid];");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence needleInfo(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("include_once \'Needles/Base/Abstract");
    String _formatForDB = this._formattingExtensions.formatForDB(it.getName());
    _builder.append(_formatForDB);
    _builder.append("_info.php\';");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* ");
    String _appName = this._utils.appName(this.app);
    _builder.append(_appName, " ");
    _builder.append(" ");
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(it.getName());
    _builder.append(_formatForDisplay, " ");
    _builder.append(" needle information.");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param none");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return string with short usage description");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("function ");
    String _appName_1 = this._utils.appName(this.app);
    _builder.append(_appName_1);
    _builder.append("_needleapi_");
    String _formatForDB_1 = this._formattingExtensions.formatForDB(it.getName());
    _builder.append(_formatForDB_1);
    _builder.append("_info()");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return ");
    String _appName_2 = this._utils.appName(this.app);
    _builder.append(_appName_2, "    ");
    _builder.append("_needleapi_");
    String _formatForDB_2 = this._formattingExtensions.formatForDB(it.getName());
    _builder.append(_formatForDB_2, "    ");
    _builder.append("_baseInfo();");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence needleImpl(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("include_once \'Needles/Base/Abstract");
    String _formatForDB = this._formattingExtensions.formatForDB(it.getName());
    _builder.append(_formatForDB);
    _builder.append(".php\';");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Replaces a given needle id by the corresponding content.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param array $args Arguments array");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*     int nid The needle id");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return string Replaced value for the needle");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("function ");
    String _appName = this._utils.appName(this.app);
    _builder.append(_appName);
    _builder.append("_needleapi_");
    String _formatForDB_1 = this._formattingExtensions.formatForDB(it.getName());
    _builder.append(_formatForDB_1);
    _builder.append("($args)");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return ");
    String _appName_1 = this._utils.appName(this.app);
    _builder.append(_appName_1, "    ");
    _builder.append("_needleapi_");
    String _formatForDB_2 = this._formattingExtensions.formatForDB(it.getName());
    _builder.append(_formatForDB_2, "    ");
    _builder.append("_base($args);");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
}
