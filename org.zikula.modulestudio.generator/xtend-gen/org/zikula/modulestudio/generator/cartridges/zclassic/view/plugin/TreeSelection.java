package org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin;

import com.google.inject.Inject;
import de.guite.modulestudio.metamodel.modulestudio.Application;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class TreeSelection {
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
  private Utils _utils = new Function0<Utils>() {
    public Utils apply() {
      Utils _utils = new Utils();
      return _utils;
    }
  }.apply();
  
  public void generate(final Application it, final IFileSystemAccess fsa) {
    String _viewPluginFilePath = this._namingExtensions.viewPluginFilePath(it, "function", "TreeSelection");
    CharSequence _treeSelectionFile = this.treeSelectionFile(it);
    fsa.generateFile(_viewPluginFilePath, _treeSelectionFile);
  }
  
  private CharSequence treeSelectionFile(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    FileHelper _fileHelper = new FileHelper();
    CharSequence _phpFileHeader = _fileHelper.phpFileHeader(it);
    _builder.append(_phpFileHeader, "");
    _builder.newLineIfNotEmpty();
    CharSequence _treeSelectionImpl = this.treeSelectionImpl(it);
    _builder.append(_treeSelectionImpl, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence treeSelectionImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* The ");
    String _appName = this._utils.appName(it);
    String _formatForDB = this._formattingExtensions.formatForDB(_appName);
    _builder.append(_formatForDB, " ");
    _builder.append("TreeSelection plugin retrieves tree entities based on a given one.");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Available parameters:");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*   - objectType: Name of treated object type.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*   - node:       Given entity as tree entry point.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*   - target:     One of \'allParents\', \'directParent\', \'allChildren\', \'directChildren\', \'predecessors\', \'successors\', \'preandsuccessors\'");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*   - assign:     Variable where the results are assigned to.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param  array       $params All attributes passed to this function from the template.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param  Zikula_View $view   Reference to the view object.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("function smarty_function_");
    String _appName_1 = this._utils.appName(it);
    String _formatForDB_1 = this._formattingExtensions.formatForDB(_appName_1);
    _builder.append(_formatForDB_1, "");
    _builder.append("TreeSelection($params, $view)");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!isset($params[\'objectType\']) || empty($params[\'objectType\'])) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$view->trigger_error(__f(\'Error! in %1$s: the %2$s parameter must be specified.\', array(\'");
    String _appName_2 = this._utils.appName(it);
    String _formatForDB_2 = this._formattingExtensions.formatForDB(_appName_2);
    _builder.append(_formatForDB_2, "        ");
    _builder.append("TreeSelection\', \'objectType\')));");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return false;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!isset($params[\'node\']) || !is_object($params[\'node\'])) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$view->trigger_error(__f(\'Error! in %1$s: the %2$s parameter must be specified.\', array(\'");
    String _appName_3 = this._utils.appName(it);
    String _formatForDB_3 = this._formattingExtensions.formatForDB(_appName_3);
    _builder.append(_formatForDB_3, "        ");
    _builder.append("TreeSelection\', \'node\')));");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return false;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$allowedTargets = array(\'allParents\', \'directParent\', \'allChildren\', \'directChildren\', \'predecessors\', \'successors\', \'preandsuccessors\');");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!isset($params[\'target\']) || empty($params[\'target\']) || !in_array($params[\'target\'], $allowedTargets)) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$view->trigger_error(__f(\'Error! in %1$s: the %2$s parameter must be specified.\', array(\'");
    String _appName_4 = this._utils.appName(it);
    String _formatForDB_4 = this._formattingExtensions.formatForDB(_appName_4);
    _builder.append(_formatForDB_4, "        ");
    _builder.append("TreeSelection\', \'target\')));");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return false;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!isset($params[\'assign\']) || empty($params[\'assign\'])) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$view->trigger_error(__f(\'Error! in %1$s: the %2$s parameter must be specified.\', array(\'");
    String _appName_5 = this._utils.appName(it);
    String _formatForDB_5 = this._formattingExtensions.formatForDB(_appName_5);
    _builder.append(_formatForDB_5, "        ");
    _builder.append("TreeSelection\', \'assign\')));");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return false;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    {
      boolean _targets = this._utils.targets(it, "1.3.5");
      if (_targets) {
        _builder.append("    ");
        _builder.append("$entityClass = \'");
        String _appName_6 = this._utils.appName(it);
        _builder.append(_appName_6, "    ");
        _builder.append("_Entity_\' . ucwords($params[\'objectType\']);");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("    ");
        _builder.append("$entityClass = \'\\\\");
        String _appName_7 = this._utils.appName(it);
        _builder.append(_appName_7, "    ");
        _builder.append("\\\\Entity\\\\\' . ucwords($params[\'objectType\']) . \'Entity\';");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("    ");
    _builder.append("$serviceManager = ServiceUtil::getManager();");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$entityManager = $serviceManager->getService(\'doctrine.entitymanager\');");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$repository = $entityManager->getRepository($entityClass);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$titleFieldName = $repository->getTitleFieldName();");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$node = $params[\'node\'];");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$result = null;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("switch ($params[\'target\']) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("case \'allParents\':");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("case \'directParent\':");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$path = $repository->getPath($node);");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("if (count($path) > 0) {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("// remove $node");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("unset($path[count($path)-1]);");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("if (count($path) > 0) {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("// remove root level");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("array_shift($path);");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("if ($params[\'target\'] == \'allParents\') {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("$result = $path;");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("} elseif ($params[\'target\'] == \'directParent\' && count($path) > 0) {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("$result = $path[count($path)-1];");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("break;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("case \'allChildren\':");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("case \'directChildren\':");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$direct = ($params[\'target\'] == \'directChildren\');");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$sortByField = ($titleFieldName != \'\') ? $titleFieldName : null;");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$sortDirection = \'ASC\';");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$result = $repository->children($node, $direct, $sortByField, $sortDirection);");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("break;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("case \'predecessors\':");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$includeSelf = false;");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$result = $repository->getPrevSiblings($node, $includeSelf);");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("break;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("case \'successors\':");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$includeSelf = false;");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$result = $repository->getNextSiblings($node, $includeSelf);");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("break;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("case \'preandsuccessors\':");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$includeSelf = false;");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$result = array_merge($repository->getPrevSiblings($node, $includeSelf), $repository->getNextSiblings($node, $includeSelf));");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("break;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$view->assign($params[\'assign\'], $result);");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
}
