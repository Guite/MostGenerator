package org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.form;

import com.google.inject.Inject;
import de.guite.modulestudio.metamodel.modulestudio.Application;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class TreeSelector {
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
  private ModelBehaviourExtensions _modelBehaviourExtensions = new Function0<ModelBehaviourExtensions>() {
    public ModelBehaviourExtensions apply() {
      ModelBehaviourExtensions _modelBehaviourExtensions = new ModelBehaviourExtensions();
      return _modelBehaviourExtensions;
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
  
  private FileHelper fh = new Function0<FileHelper>() {
    public FileHelper apply() {
      FileHelper _fileHelper = new FileHelper();
      return _fileHelper;
    }
  }.apply();
  
  public void generate(final Application it, final IFileSystemAccess fsa) {
    boolean _hasTrees = this._modelBehaviourExtensions.hasTrees(it);
    if (_hasTrees) {
      String _appSourceLibPath = this._namingExtensions.getAppSourceLibPath(it);
      final String formPluginPath = (_appSourceLibPath + "Form/Plugin/");
      String _plus = (formPluginPath + "Base/TreeSelector.php");
      CharSequence _treeSelectorBaseFile = this.treeSelectorBaseFile(it);
      fsa.generateFile(_plus, _treeSelectorBaseFile);
      String _plus_1 = (formPluginPath + "TreeSelector.php");
      CharSequence _treeSelectorFile = this.treeSelectorFile(it);
      fsa.generateFile(_plus_1, _treeSelectorFile);
      String _viewPluginFilePath = this._namingExtensions.viewPluginFilePath(it, "function", "TreeSelector");
      CharSequence _treeSelectorPluginFile = this.treeSelectorPluginFile(it);
      fsa.generateFile(_viewPluginFilePath, _treeSelectorPluginFile);
    }
  }
  
  private CharSequence treeSelectorBaseFile(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _phpFileHeader = this.fh.phpFileHeader(it);
    _builder.append(_phpFileHeader, "");
    _builder.newLineIfNotEmpty();
    CharSequence _treeSelectorBaseImpl = this.treeSelectorBaseImpl(it);
    _builder.append(_treeSelectorBaseImpl, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence treeSelectorFile(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _phpFileHeader = this.fh.phpFileHeader(it);
    _builder.append(_phpFileHeader, "");
    _builder.newLineIfNotEmpty();
    CharSequence _treeSelectorImpl = this.treeSelectorImpl(it);
    _builder.append(_treeSelectorImpl, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence treeSelectorPluginFile(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _phpFileHeader = this.fh.phpFileHeader(it);
    _builder.append(_phpFileHeader, "");
    _builder.newLineIfNotEmpty();
    CharSequence _treeSelectorPluginImpl = this.treeSelectorPluginImpl(it);
    _builder.append(_treeSelectorPluginImpl, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence treeSelectorBaseImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _targets = this._utils.targets(it, "1.3.5");
      boolean _not = (!_targets);
      if (_not) {
        _builder.append("namespace ");
        String _appNamespace = this._utils.appNamespace(it);
        _builder.append(_appNamespace, "");
        _builder.append("\\Form\\Plugin\\Base;");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
        _builder.append("use ");
        String _vendor = it.getVendor();
        String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(_vendor);
        _builder.append(_formatForCodeCapital, "");
        _builder.append("\\");
        String _name = it.getName();
        String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(_name);
        _builder.append(_formatForCodeCapital_1, "");
        _builder.append("Module\\Form\\Plugin\\AbstractObjectSelector as BaseAbstractObjectSelector;");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
        _builder.append("use ModUtil;");
        _builder.newLine();
        _builder.append("use ServiceUtil;");
        _builder.newLine();
        _builder.append("use Zikula_Form_View;");
        _builder.newLine();
        _builder.newLine();
      }
    }
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Tree selector.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* This plugin creates a nested tree selector using a dropdown list.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* The selected value of the base dropdown list will be set to ID of the selected tree node.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    {
      boolean _targets_1 = this._utils.targets(it, "1.3.5");
      if (_targets_1) {
        _builder.append("class ");
        String _appName = this._utils.appName(it);
        _builder.append(_appName, "");
        _builder.append("_Form_Plugin_Base_TreeSelector extends ");
        String _appName_1 = this._utils.appName(it);
        _builder.append(_appName_1, "");
        _builder.append("_Form_Plugin_AbstractObjectSelector");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("class TreeSelector extends BaseAbstractObjectSelector");
        _builder.newLine();
      }
    }
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* Root node id (when using multiple roots).");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @var integer");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("public $root;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* Whether leaf nodes should be included or not.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @var boolean");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("public $includeLeafNodes = true;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* Whether the root node should be included or not.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @var boolean");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("public $includeRootNode = false;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* Reference to the tree repository.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @var Doctrine\\ORM\\EntityRepository");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("public $repository = null;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* Get filename of this file.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @return string");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("public function getFilename()");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return __FILE__;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* Create event handler.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @param Zikula_Form_View $view    Reference to Zikula_Form_View object.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @param array            &$params Parameters passed from the Smarty plugin function.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @see    Zikula_Form_Plugin");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @return void");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("public function create($view, &$params)");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$this->root = (isset($params[\'root\']) && is_numeric($params[\'root\']) && $params[\'root\'] > 0) ? $params[\'root\'] : 1;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$this->includeLeafNodes = isset($params[\'includeLeaf\']) ? $params[\'includeLeaf\'] : true;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$this->includeRootNode = isset($params[\'includeRoot\']) ? $params[\'includeRoot\'] : false;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("parent::create($view, $params);");
    _builder.newLine();
    _builder.newLine();
    {
      boolean _targets_2 = this._utils.targets(it, "1.3.5");
      if (_targets_2) {
        _builder.append("        ");
        _builder.append("$entityClass = $this->name . \'_Entity_\' . ucwords($this->objectType);");
        _builder.newLine();
      } else {
        _builder.append("        ");
        _builder.append("$entityClass = \'\\\\");
        String _vendor_1 = it.getVendor();
        String _formatForCodeCapital_2 = this._formattingExtensions.formatForCodeCapital(_vendor_1);
        _builder.append(_formatForCodeCapital_2, "        ");
        _builder.append("\\\\");
        String _name_1 = it.getName();
        String _formatForCodeCapital_3 = this._formattingExtensions.formatForCodeCapital(_name_1);
        _builder.append(_formatForCodeCapital_3, "        ");
        _builder.append("Module\\\\Entity\\\\\' . ucwords($this->objectType) . \'Entity\';");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("        ");
    _builder.append("$entityManager = ServiceUtil::getManager()->getService(\'doctrine.entitymanager\');");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$this->repository = $entityManager->getRepository($entityClass);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* Entry point for customised css class.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("protected function getStyleClass()");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return \'z-form-nestedsetlist\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* Performs the actual data selection.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @param array &$params Parameters passed from the Smarty plugin function.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @return array List of selected objects.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("protected function loadItems(&$params)");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$apiArgs = array(\'ot\' => $this->objectType");
    _builder.newLine();
    _builder.append("                         ");
    _builder.append("\'rootId\' => $this->root);");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$treeNodes = ModUtil::apiFunc($this->name, \'selection\', \'getTree\', $apiArgs);");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if (!$treeNodes) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("return array();");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return $treeNodes;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* Determines whether a certain list item should be included or not.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* Allows to exclude undesired items after the selection has happened.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @param Doctrine\\ORM\\Entity $item The treated entity.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @return boolean Whether this entity should be included into the list.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("protected function isIncluded($item)");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$nodeLevel = $item->getLvl();");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if (!$this->includeRootNode && $nodeLevel == 0) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("// if we do not include the root node skip it");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("return false;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if (!$this->includeLeafNodes && $this->repository->childCount($item) == 0) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("// if we do not include leaf nodes skip them");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("return false;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return true;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* Calculates the label for a certain list item.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @param Doctrine\\ORM\\Entity $item The treated entity.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @return string The created label string.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("protected function createItemLabel($item)");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// determine current list hierarchy level depending on root node inclusion");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$shownLevel = $item->getLvl();");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if (!$this->includeRootNode) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$shownLevel--;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$praefix = str_repeat(\'- - \', $shownLevel);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$itemLabel = $praefix . parent::createItemLabel($item);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return $itemLabel;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence treeSelectorImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _targets = this._utils.targets(it, "1.3.5");
      boolean _not = (!_targets);
      if (_not) {
        _builder.append("namespace ");
        String _appNamespace = this._utils.appNamespace(it);
        _builder.append(_appNamespace, "");
        _builder.append("\\Form\\Plugin;");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
        _builder.append("use Base\\TreeSelector as BaseTreeSelector;");
        _builder.newLine();
        _builder.newLine();
      }
    }
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Tree selector.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* This plugin creates a nested tree selector using a dropdown list.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* The selected value of the base dropdown list will be set to ID of the selected tree node.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    {
      boolean _targets_1 = this._utils.targets(it, "1.3.5");
      if (_targets_1) {
        _builder.append("class ");
        String _appName = this._utils.appName(it);
        _builder.append(_appName, "");
        _builder.append("_Form_Plugin_TreeSelector extends ");
        String _appName_1 = this._utils.appName(it);
        _builder.append(_appName_1, "");
        _builder.append("_Form_Plugin_Base_TreeSelector");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("class TreeSelector extends BaseTreeSelector");
        _builder.newLine();
      }
    }
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// feel free to add your customisation here");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence treeSelectorPluginImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* The ");
    String _appName = this._utils.appName(it);
    String _formatForDB = this._formattingExtensions.formatForDB(_appName);
    _builder.append(_formatForDB, " ");
    _builder.append("TreeSelector plugin cares for handling a dropdown list");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("* for an entity with tree structure.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param array            $params Parameters passed to this function from the template.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param Zikula_Form_View $view   Reference to Form render object.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return string The rendered output.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("function smarty_function_");
    String _appName_1 = this._utils.appName(it);
    String _formatForDB_1 = this._formattingExtensions.formatForDB(_appName_1);
    _builder.append(_formatForDB_1, "");
    _builder.append("TreeSelector($params, $view)");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $view->registerPlugin(\'");
    {
      boolean _targets = this._utils.targets(it, "1.3.5");
      if (_targets) {
        String _appName_2 = this._utils.appName(it);
        _builder.append(_appName_2, "    ");
        _builder.append("_Form_Plugin_TreeSelector");
      } else {
        _builder.append("\\\\");
        String _vendor = it.getVendor();
        String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(_vendor);
        _builder.append(_formatForCodeCapital, "    ");
        _builder.append("\\\\");
        String _name = it.getName();
        String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(_name);
        _builder.append(_formatForCodeCapital_1, "    ");
        _builder.append("Module\\\\Form\\\\Plugin\\\\TreeSelector");
      }
    }
    _builder.append("\', $params);");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
}
