package org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin;

import com.google.inject.Inject;
import de.guite.modulestudio.metamodel.modulestudio.Application;
import de.guite.modulestudio.metamodel.modulestudio.Controller;
import org.eclipse.emf.common.util.EList;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper;
import org.zikula.modulestudio.generator.extensions.ControllerExtensions;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class TreeJS {
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
    String _viewPluginFilePath = this._namingExtensions.viewPluginFilePath(it, "function", "TreeJS");
    CharSequence _treeJsFile = this.treeJsFile(it);
    fsa.generateFile(_viewPluginFilePath, _treeJsFile);
  }
  
  private CharSequence treeJsFile(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    FileHelper _fileHelper = new FileHelper();
    CharSequence _phpFileHeader = _fileHelper.phpFileHeader(it);
    _builder.append(_phpFileHeader, "");
    _builder.newLineIfNotEmpty();
    CharSequence _treeJsImpl = this.treeJsImpl(it);
    _builder.append(_treeJsImpl, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence treeJsImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* The ");
    String _appName = this._utils.appName(it);
    String _formatForDB = this._formattingExtensions.formatForDB(_appName);
    _builder.append(_formatForDB, " ");
    _builder.append("TreeJS plugin delivers the html output for a JS tree");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("* based on given tree entities.");
    _builder.newLine();
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
    _builder.append("*   - tree:       Object collection with tree items.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*   - controller: Optional name of controller, defaults to \'user\'.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*   - root:       Optional id of root node, defaults to 1.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*   - assign:     If set, the results are assigned to the corresponding variable instead of printed out.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param  array       $params  All attributes passed to this function from the template.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param  Zikula_View $view    Reference to the view object.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return string The output of the plugin.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("function smarty_function_");
    String _appName_1 = this._utils.appName(it);
    String _formatForDB_1 = this._formattingExtensions.formatForDB(_appName_1);
    _builder.append(_formatForDB_1, "");
    _builder.append("TreeJS($params, $view)");
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
    _builder.append("TreeJS\', \'objectType\')));");
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
    _builder.append("if (!isset($params[\'tree\']) || empty($params[\'tree\'])) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$view->trigger_error(__f(\'Error! in %1$s: the %2$s parameter must be specified.\', array(\'");
    String _appName_3 = this._utils.appName(it);
    String _formatForDB_3 = this._formattingExtensions.formatForDB(_appName_3);
    _builder.append(_formatForDB_3, "        ");
    _builder.append("TreeJS\', \'tree\')));");
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
    _builder.append("if (!isset($params[\'controller\']) || empty($params[\'controller\'])) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$params[\'controller\'] = \'user\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!isset($params[\'root\']) || empty($params[\'root\'])) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$params[\'root\'] = 1;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// check whether an edit action is available");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$controllerHasEditAction = false;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("switch ($params[\'controller\']) {");
    _builder.newLine();
    _builder.append("        ");
    CharSequence _controllerEditActionFlags = this.controllerEditActionFlags(it);
    _builder.append(_controllerEditActionFlags, "        ");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    {
      boolean _targets = this._utils.targets(it, "1.3.5");
      if (_targets) {
        _builder.append("    ");
        _builder.append("$entityClass = \'");
        String _appName_4 = this._utils.appName(it);
        _builder.append(_appName_4, "    ");
        _builder.append("_Entity_\' . ucwords($params[\'objectType\']);");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("    ");
        _builder.append("$entityClass = \'\\\\");
        String _vendor = it.getVendor();
        String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(_vendor);
        _builder.append(_formatForCodeCapital, "    ");
        _builder.append("\\\\");
        String _name = it.getName();
        String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(_name);
        _builder.append(_formatForCodeCapital_1, "    ");
        _builder.append("Module\\\\Entity\\\\\' . ucwords($params[\'objectType\']) . \'Entity\';");
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
    _builder.append("    ");
    _builder.append("$descriptionFieldName = $repository->getDescriptionFieldName();");
    _builder.newLine();
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$idField = \'id\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$result = array();");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("foreach ($params[\'tree\'] as $item) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$url = (($controllerHasEditAction) ? ModUtil::url(\'");
    String _appName_5 = this._utils.appName(it);
    _builder.append(_appName_5, "        ");
    _builder.append("\', $params[\'controller\'], \'edit\', array(\'ot\' => $params[\'objectType\'], $idField => $item[$idField])) : \'\');");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$parentItem = $item->getParent();");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$result[] = array(\'id\' => $item[$idField],");
    _builder.newLine();
    _builder.append("                          ");
    _builder.append("\'parent_id\' => $parentItem[$idField],");
    _builder.newLine();
    _builder.append("                          ");
    _builder.append("\'name\' => (($titleFieldName != \'\') ? $item[$titleFieldName] : \'\'),");
    _builder.newLine();
    _builder.append("                          ");
    _builder.append("\'title\' => (($descriptionFieldName != \'\') ? strip_tags($item[$descriptionFieldName]) : \'\'),");
    _builder.newLine();
    _builder.append("                        ");
    _builder.append("//\'icon\' => \'\',");
    _builder.newLine();
    _builder.append("                        ");
    _builder.append("//\'class\' => \'\',");
    _builder.newLine();
    _builder.append("                          ");
    _builder.append("\'active\' => true,");
    _builder.newLine();
    _builder.append("                        ");
    _builder.append("//\'expanded\' => null,");
    _builder.newLine();
    _builder.append("                          ");
    _builder.append("\'href\' => $url);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// instantiate and initialise the output tree object");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$tree = new Zikula_Tree();");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$tree->setOption(\'id\', \'itemtree\' . $params[\'root\']);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("//$tree->setOption(\'objid\', $idField);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$tree->setOption(\'treeClass\', \'z-nestedsetlist\');");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$tree->setOption(\'nodePrefix\', \'tree\' . $params[\'root\'] . \'node_\');");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$tree->setOption(\'sortable\', ((isset($params[\'sortable\']) && $params[\'sortable\']) ? true : false));");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$tree->setOption(\'withWraper\', true);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// disable drag and drop for root category");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$tree->setOption(\'disabled\', array(1));");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// put data into output tree");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$tree->loadArrayData($result);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// get output result");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$result = $tree->getHTML();");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (array_key_exists(\'assign\', $params)) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$view->assign($params[\'assign\'], $result);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $result;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence controllerEditActionFlags(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      EList<Controller> _allControllers = this._controllerExtensions.getAllControllers(it);
      final Function1<Controller,Boolean> _function = new Function1<Controller,Boolean>() {
          public Boolean apply(final Controller e) {
            boolean _hasActions = TreeJS.this._controllerExtensions.hasActions(e, "edit");
            return Boolean.valueOf(_hasActions);
          }
        };
      Iterable<Controller> _filter = IterableExtensions.<Controller>filter(_allControllers, _function);
      for(final Controller controller : _filter) {
        _builder.append("case \'");
        String _formattedName = this._controllerExtensions.formattedName(controller);
        _builder.append(_formattedName, "");
        _builder.append("\': $controllerHasEditAction = true; break;");
        _builder.newLineIfNotEmpty();
      }
    }
    return _builder;
  }
}
