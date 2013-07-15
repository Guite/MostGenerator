package org.zikula.modulestudio.generator.cartridges.zclassic.controller.apis;

import com.google.inject.Inject;
import de.guite.modulestudio.metamodel.modulestudio.Application;
import de.guite.modulestudio.metamodel.modulestudio.Entity;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.eclipse.xtext.xbase.lib.InputOutput;
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper;
import org.zikula.modulestudio.generator.cartridges.zclassic.view.additions.BlocksView;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class BlockList {
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
  private ModelExtensions _modelExtensions = new Function0<ModelExtensions>() {
    public ModelExtensions apply() {
      ModelExtensions _modelExtensions = new ModelExtensions();
      return _modelExtensions;
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
    InputOutput.<String>println("Generating block for multiple objects");
    String _appSourceLibPath = this._namingExtensions.getAppSourceLibPath(it);
    final String blockPath = (_appSourceLibPath + "Block/");
    String _xifexpression = null;
    boolean _targets = this._utils.targets(it, "1.3.5");
    boolean _not = (!_targets);
    if (_not) {
      _xifexpression = "Block";
    } else {
      _xifexpression = "";
    }
    final String blockClassSuffix = _xifexpression;
    String _plus = ("ItemList" + blockClassSuffix);
    final String blockFileName = (_plus + ".php");
    String _plus_1 = (blockPath + "Base/");
    String _plus_2 = (_plus_1 + blockFileName);
    CharSequence _listBlockBaseFile = this.listBlockBaseFile(it);
    fsa.generateFile(_plus_2, _listBlockBaseFile);
    String _plus_3 = (blockPath + blockFileName);
    CharSequence _listBlockFile = this.listBlockFile(it);
    fsa.generateFile(_plus_3, _listBlockFile);
    BlocksView _blocksView = new BlocksView();
    _blocksView.generate(it, fsa);
  }
  
  private CharSequence listBlockBaseFile(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _phpFileHeader = this.fh.phpFileHeader(it);
    _builder.append(_phpFileHeader, "");
    _builder.newLineIfNotEmpty();
    CharSequence _listBlockBaseClass = this.listBlockBaseClass(it);
    _builder.append(_listBlockBaseClass, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence listBlockFile(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _phpFileHeader = this.fh.phpFileHeader(it);
    _builder.append(_phpFileHeader, "");
    _builder.newLineIfNotEmpty();
    CharSequence _listBlockImpl = this.listBlockImpl(it);
    _builder.append(_listBlockImpl, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence listBlockBaseClass(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _targets = this._utils.targets(it, "1.3.5");
      boolean _not = (!_targets);
      if (_not) {
        _builder.append("namespace ");
        String _appName = this._utils.appName(it);
        _builder.append(_appName, "");
        _builder.append("\\Block\\Base;");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
        _builder.append("use ");
        String _appName_1 = this._utils.appName(it);
        _builder.append(_appName_1, "");
        _builder.append("\\Util\\ControllerUtil;");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
        _builder.append("use BlockUtil;");
        _builder.newLine();
        _builder.append("use DataUtil;");
        _builder.newLine();
        _builder.append("use ModUtil;");
        _builder.newLine();
        _builder.append("use SecurityUtil;");
        _builder.newLine();
        _builder.append("use Zikula_Controller_AbstractBlock;");
        _builder.newLine();
        _builder.append("use Zikula_View;");
        _builder.newLine();
        _builder.newLine();
      }
    }
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Generic item list block base class.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("class ");
    {
      boolean _targets_1 = this._utils.targets(it, "1.3.5");
      if (_targets_1) {
        String _appName_2 = this._utils.appName(it);
        _builder.append(_appName_2, "");
        _builder.append("_Block_Base_ItemList");
      } else {
        _builder.append("ItemListBlock");
      }
    }
    _builder.append(" extends Zikula_Controller_AbstractBlock");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    CharSequence _listBlockBaseImpl = this.listBlockBaseImpl(it);
    _builder.append(_listBlockBaseImpl, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence listBlockBaseImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _hasCategorisableEntities = this._modelBehaviourExtensions.hasCategorisableEntities(it);
      if (_hasCategorisableEntities) {
        _builder.append("/**");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* List of object types allowing categorisation.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @var array");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
        _builder.append("protected $categorisableObjectTypes;");
        _builder.newLine();
        _builder.newLine();
      }
    }
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Initialise the block.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function init()");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("SecurityUtil::registerPermissionSchema(\'");
    String _appName = this._utils.appName(it);
    _builder.append(_appName, "    ");
    _builder.append(":ItemListBlock:\', \'Block title::\');");
    _builder.newLineIfNotEmpty();
    {
      boolean _hasCategorisableEntities_1 = this._modelBehaviourExtensions.hasCategorisableEntities(it);
      if (_hasCategorisableEntities_1) {
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$this->categorisableObjectTypes = array(");
        {
          Iterable<Entity> _categorisableEntities = this._modelBehaviourExtensions.getCategorisableEntities(it);
          boolean _hasElements = false;
          for(final Entity entity : _categorisableEntities) {
            if (!_hasElements) {
              _hasElements = true;
            } else {
              _builder.appendImmediate(", ", "    ");
            }
            _builder.append("\'");
            String _name = entity.getName();
            String _formatForCode = this._formattingExtensions.formatForCode(_name);
            _builder.append(_formatForCode, "    ");
            _builder.append("\'");
          }
        }
        _builder.append(");");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Get information on the block.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return array The block information");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function info()");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$requirementMessage = \'\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// check if the module is available at all");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!ModUtil::available(\'");
    String _appName_1 = this._utils.appName(it);
    _builder.append(_appName_1, "    ");
    _builder.append("\')) {");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("$requirementMessage .= $this->__(\'Notice: This block will not be displayed until you activate the ");
    String _appName_2 = this._utils.appName(it);
    _builder.append(_appName_2, "        ");
    _builder.append(" module.\');");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return array(\'module\'          => \'");
    String _appName_3 = this._utils.appName(it);
    _builder.append(_appName_3, "    ");
    _builder.append("\',");
    _builder.newLineIfNotEmpty();
    _builder.append("                 ");
    _builder.append("\'text_type\'       => $this->__(\'");
    String _appName_4 = this._utils.appName(it);
    _builder.append(_appName_4, "                 ");
    _builder.append(" list view\'),");
    _builder.newLineIfNotEmpty();
    _builder.append("                 ");
    _builder.append("\'text_type_long\'  => $this->__(\'Display list of ");
    String _appName_5 = this._utils.appName(it);
    _builder.append(_appName_5, "                 ");
    _builder.append(" objects.\'),");
    _builder.newLineIfNotEmpty();
    _builder.append("                 ");
    _builder.append("\'allow_multiple\'  => true,");
    _builder.newLine();
    _builder.append("                 ");
    _builder.append("\'form_content\'    => false,");
    _builder.newLine();
    _builder.append("                 ");
    _builder.append("\'form_refresh\'    => false,");
    _builder.newLine();
    _builder.append("                 ");
    _builder.append("\'show_preview\'    => true,");
    _builder.newLine();
    _builder.append("                 ");
    _builder.append("\'admin_tableless\' => true,");
    _builder.newLine();
    _builder.append("                 ");
    _builder.append("\'requirement\'     => $requirementMessage);");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Display the block.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param array $blockinfo the blockinfo structure");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return string output of the rendered block");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function display($blockinfo)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// only show block content if the user has the required permissions");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!SecurityUtil::checkPermission(\'");
    String _appName_6 = this._utils.appName(it);
    _builder.append(_appName_6, "    ");
    _builder.append(":ItemListBlock:\', \"$blockinfo[title]::\", ACCESS_OVERVIEW)) {");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("return false;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// check if the module is available at all");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!ModUtil::available(\'");
    String _appName_7 = this._utils.appName(it);
    _builder.append(_appName_7, "    ");
    _builder.append("\')) {");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("return false;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// get current block content");
    _builder.newLine();
    {
      boolean _targets = this._utils.targets(it, "1.3.5");
      if (_targets) {
        _builder.append("    ");
        _builder.append("$vars = BlockUtil::varsFromContent($blockinfo[\'content\']);");
        _builder.newLine();
      } else {
        _builder.append("    ");
        _builder.append("//$vars = BlockUtil::varsFromContent($blockinfo[\'content\']);");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$vars = unserialize($blockinfo[\'content\']);");
        _builder.newLine();
      }
    }
    _builder.append("    ");
    _builder.append("$vars[\'bid\'] = $blockinfo[\'bid\'];");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// set default values for all params which are not properly set");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!isset($vars[\'objectType\']) || empty($vars[\'objectType\'])) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$vars[\'objectType\'] = \'");
    Entity _leadingEntity = this._modelExtensions.getLeadingEntity(it);
    String _name_1 = _leadingEntity.getName();
    String _formatForCode_1 = this._formattingExtensions.formatForCode(_name_1);
    _builder.append(_formatForCode_1, "        ");
    _builder.append("\';");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!isset($vars[\'sorting\']) || empty($vars[\'sorting\'])) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$vars[\'sorting\'] = \'default\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!isset($vars[\'amount\']) || !is_numeric($vars[\'amount\'])) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$vars[\'amount\'] = 5;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!isset($vars[\'template\'])) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$vars[\'template\'] = \'itemlist_\' . DataUtil::formatForOS($vars[\'objectType\']) . \'_display.tpl\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!isset($vars[\'customTemplate\'])) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$vars[\'customTemplate\'] = \'\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!isset($vars[\'filter\'])) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$vars[\'filter\'] = \'\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    {
      boolean _hasCategorisableEntities_2 = this._modelBehaviourExtensions.hasCategorisableEntities(it);
      if (_hasCategorisableEntities_2) {
        _builder.newLine();
        _builder.append("    ");
        _builder.append("if (!isset($vars[\'catIds\'])) {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("$primaryRegistry = ModUtil::apiFunc(\'");
        String _appName_8 = this._utils.appName(it);
        _builder.append(_appName_8, "        ");
        _builder.append("\', \'category\', \'getPrimaryProperty\', array(\'ot\' => $vars[\'objectType\']));");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("$vars[\'catIds\'] = array($primaryRegistry => array());");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("// backwards compatibility");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("if (isset($vars[\'catId\'])) {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("        ");
        _builder.append("$vars[\'catIds\'][$primaryRegistry][] = $vars[\'catId\'];");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("        ");
        _builder.append("unset($vars[\'catId\']);");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("} elseif (!is_array($vars[\'catIds\'])) {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("$vars[\'catIds\'] = explode(\',\', $vars[\'catIds\']);");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
      }
    }
    _builder.newLine();
    _builder.append("    ");
    _builder.append("ModUtil::initOOModule(\'");
    String _appName_9 = this._utils.appName(it);
    _builder.append(_appName_9, "    ");
    _builder.append("\');");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$controllerHelper = new ");
    {
      boolean _targets_1 = this._utils.targets(it, "1.3.5");
      if (_targets_1) {
        String _appName_10 = this._utils.appName(it);
        _builder.append(_appName_10, "    ");
        _builder.append("_Util_Controller");
      } else {
        _builder.append("ControllerUtil");
      }
    }
    _builder.append("($this->serviceManager);");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$utilArgs = array(\'name\' => \'list\');");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!isset($vars[\'objectType\']) || !in_array($vars[\'objectType\'], $controllerHelper->getObjectTypes(\'block\', $utilArgs))) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$vars[\'objectType\'] = $controllerHelper->getDefaultObjectType(\'block\', $utilArgs);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$objectType = $vars[\'objectType\'];");
    _builder.newLine();
    _builder.newLine();
    {
      boolean _targets_2 = this._utils.targets(it, "1.3.5");
      if (_targets_2) {
        _builder.append("    ");
        _builder.append("$entityClass = \'");
        String _appName_11 = this._utils.appName(it);
        _builder.append(_appName_11, "    ");
        _builder.append("_Entity_\' . ucwords($objectType);");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("    ");
        _builder.append("$entityClass = \'\\\\");
        String _appName_12 = this._utils.appName(it);
        _builder.append(_appName_12, "    ");
        _builder.append("\\\\Entity\\\\\' . ucwords($objectType) . \'Entity\';");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("    ");
    _builder.append("$entityManager = $this->serviceManager->getService(\'doctrine.entitymanager\');");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$repository = $entityManager->getRepository($entityClass);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$where = $vars[\'filter\'];");
    _builder.newLine();
    {
      boolean _hasCategorisableEntities_3 = this._modelBehaviourExtensions.hasCategorisableEntities(it);
      if (_hasCategorisableEntities_3) {
        _builder.append("    ");
        _builder.append("$properties = null;");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("if (in_array($vars[\'objectType\'], $this->categorisableObjectTypes)) {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("$properties = ModUtil::apiFunc(\'");
        String _appName_13 = this._utils.appName(it);
        _builder.append(_appName_13, "        ");
        _builder.append("\', \'category\', \'getAllProperties\', array(\'ot\' => $objectType));");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("// apply category filters");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("if (in_array($objectType, $this->categorisableObjectTypes)) {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("if (is_array($vars[\'catIds\']) && count($vars[\'catIds\']) > 0) {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("        ");
        _builder.append("$categoryFiltersPerRegistry = ModUtil::apiFunc(\'");
        String _appName_14 = this._utils.appName(it);
        _builder.append(_appName_14, "            ");
        _builder.append("\', \'category\', \'buildFilterClauses\', array(\'ot\' => $objectType, \'catids\' => $vars[\'catIds\']));");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("        ");
        _builder.append("if (count($categoryFiltersPerRegistry) > 0) {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("            ");
        _builder.append("if (!empty($where)) {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("                ");
        _builder.append("$where .= \' AND \';");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("            ");
        _builder.append("}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("            ");
        _builder.append("$where .= \'(\' . implode(\' OR \', $categoryFiltersPerRegistry) . \')\';");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("        ");
        _builder.append("}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
      }
    }
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$this->view->setCaching(Zikula_View::CACHE_ENABLED);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// set cache id");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$component = \'");
    String _appName_15 = this._utils.appName(it);
    _builder.append(_appName_15, "    ");
    _builder.append(":\' . ucwords($objectType) . \':\';");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("$instance = \'::\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$accessLevel = ACCESS_READ;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (SecurityUtil::checkPermission($component, $instance, ACCESS_COMMENT)) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$accessLevel = ACCESS_COMMENT;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (SecurityUtil::checkPermission($component, $instance, ACCESS_EDIT)) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$accessLevel = ACCESS_EDIT;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$this->view->setCacheId(\'view|ot_\' . $objectType . \'_sort_\' . $vars[\'sorting\'] . \'_amount_\' . $vars[\'amount\'] . \'_\' . $accessLevel);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$template = $this->getDisplayTemplate($vars);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// if page is cached return cached content");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($this->view->is_cached($template)) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$blockinfo[\'content\'] = $this->view->fetch($template);");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return BlockUtil::themeBlock($blockinfo);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// get objects from database");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$selectionArgs = array(");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'ot\' => $objectType,");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'where\' => $where,");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'orderBy\' => $this->getSortParam($vars, $repository),");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'currentPage\' => 1,");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'resultsPerPage\' => $vars[\'amount\']");
    _builder.newLine();
    _builder.append("    ");
    _builder.append(");");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("list($entities, $objectCount) = ModUtil::apiFunc(\'");
    String _appName_16 = this._utils.appName(it);
    _builder.append(_appName_16, "    ");
    _builder.append("\', \'selection\', \'getEntitiesPaginated\', $selectionArgs);");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// assign block vars and fetched data");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$this->view->assign(\'vars\', $vars)");
    _builder.newLine();
    _builder.append("               ");
    _builder.append("->assign(\'objectType\', $objectType)");
    _builder.newLine();
    _builder.append("               ");
    _builder.append("->assign(\'items\', $entities)");
    _builder.newLine();
    _builder.append("               ");
    _builder.append("->assign($repository->getAdditionalTemplateParameters(\'block\'));");
    _builder.newLine();
    {
      boolean _hasCategorisableEntities_4 = this._modelBehaviourExtensions.hasCategorisableEntities(it);
      if (_hasCategorisableEntities_4) {
        _builder.newLine();
        _builder.append("    ");
        _builder.append("// assign category properties");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$this->view->assign(\'properties\', $properties);");
        _builder.newLine();
      }
    }
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// set a block title");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (empty($blockinfo[\'title\'])) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$blockinfo[\'title\'] = $this->__(\'");
    String _appName_17 = this._utils.appName(it);
    _builder.append(_appName_17, "        ");
    _builder.append(" items\');");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$blockinfo[\'content\'] = $this->view->fetch($template);;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// return the block to the theme");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return BlockUtil::themeBlock($blockinfo);");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Returns the template used for output.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param array $vars List of block variables.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return string the template path.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected function getDisplayTemplate($vars)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$templateFile = $vars[\'template\'];");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($templateFile == \'custom\') {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$templateFile = $vars[\'customTemplate\'];");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$templateForObjectType = str_replace(\'itemlist_\', \'itemlist_\' . DataUtil::formatForOS($vars[\'objectType\']) . \'_\', $templateFile);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$template = \'\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($this->view->template_exists(\'");
    {
      boolean _targets_3 = this._utils.targets(it, "1.3.5");
      if (_targets_3) {
        _builder.append("contenttype");
      } else {
        _builder.append("ContentType");
      }
    }
    _builder.append("/\' . $templateForObjectType)) {");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("$template = \'");
    {
      boolean _targets_4 = this._utils.targets(it, "1.3.5");
      if (_targets_4) {
        _builder.append("contenttype");
      } else {
        _builder.append("ContentType");
      }
    }
    _builder.append("/\' . $templateForObjectType;");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("} elseif ($this->view->template_exists(\'");
    {
      boolean _targets_5 = this._utils.targets(it, "1.3.5");
      if (_targets_5) {
        _builder.append("block");
      } else {
        _builder.append("Block");
      }
    }
    _builder.append("/\' . $templateForObjectType)) {");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("$template = \'");
    {
      boolean _targets_6 = this._utils.targets(it, "1.3.5");
      if (_targets_6) {
        _builder.append("block");
      } else {
        _builder.append("Block");
      }
    }
    _builder.append("/\' . $templateForObjectType;");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("} elseif ($this->view->template_exists(\'");
    {
      boolean _targets_7 = this._utils.targets(it, "1.3.5");
      if (_targets_7) {
        _builder.append("contenttype");
      } else {
        _builder.append("ContentType");
      }
    }
    _builder.append("/\' . $templateFile)) {");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("$template = \'");
    {
      boolean _targets_8 = this._utils.targets(it, "1.3.5");
      if (_targets_8) {
        _builder.append("contenttype");
      } else {
        _builder.append("ContentType");
      }
    }
    _builder.append("/\' . $templateFile;");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("} elseif ($this->view->template_exists(\'");
    {
      boolean _targets_9 = this._utils.targets(it, "1.3.5");
      if (_targets_9) {
        _builder.append("block");
      } else {
        _builder.append("Block");
      }
    }
    _builder.append("/\' . $templateFile)) {");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("$template = \'");
    {
      boolean _targets_10 = this._utils.targets(it, "1.3.5");
      if (_targets_10) {
        _builder.append("block");
      } else {
        _builder.append("Block");
      }
    }
    _builder.append("/\' . $templateFile;");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("} else {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$template = \'");
    {
      boolean _targets_11 = this._utils.targets(it, "1.3.5");
      if (_targets_11) {
        _builder.append("block");
      } else {
        _builder.append("Block");
      }
    }
    _builder.append("/itemlist.tpl\';");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $template;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Determines the order by parameter for item selection.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param array               $vars       List of block variables.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param Doctrine_Repository $repository The repository used for data fetching.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return string the sorting clause.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected function getSortParam($vars, $repository)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($vars[\'sorting\'] == \'random\') {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return \'RAND()\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$sortParam = \'\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($vars[\'sorting\'] == \'newest\') {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$idFields = ModUtil::apiFunc(\'");
    String _appName_18 = this._utils.appName(it);
    _builder.append(_appName_18, "        ");
    _builder.append("\', \'selection\', \'getIdFields\', array(\'ot\' => $vars[\'objectType\']));");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("if (count($idFields) == 1) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$sortParam = $idFields[0] . \' DESC\';");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("} else {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("foreach ($idFields as $idField) {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("if (!empty($sortParam)) {");
    _builder.newLine();
    _builder.append("                    ");
    _builder.append("$sortParam .= \', \';");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("$sortParam .= $idField . \' ASC\';");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("} elseif ($vars[\'sorting\'] == \'default\') {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$sortParam = $repository->getDefaultSortingField() . \' ASC\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $sortParam;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Modify block settings.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param array $blockinfo the blockinfo structure");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return string output of the block editing form.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function modify($blockinfo)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// Get current content");
    _builder.newLine();
    {
      boolean _targets_12 = this._utils.targets(it, "1.3.5");
      if (_targets_12) {
        _builder.append("    ");
        _builder.append("$vars = BlockUtil::varsFromContent($blockinfo[\'content\']);");
        _builder.newLine();
      } else {
        _builder.append("    ");
        _builder.append("//$vars = BlockUtil::varsFromContent($blockinfo[\'content\']);");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$vars = unserialize($blockinfo[\'content\']);");
        _builder.newLine();
      }
    }
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// set default values for all params which are not properly set");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!isset($vars[\'objectType\']) || empty($vars[\'objectType\'])) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$vars[\'objectType\'] = \'");
    Entity _leadingEntity_1 = this._modelExtensions.getLeadingEntity(it);
    String _name_2 = _leadingEntity_1.getName();
    String _formatForCode_2 = this._formattingExtensions.formatForCode(_name_2);
    _builder.append(_formatForCode_2, "        ");
    _builder.append("\';");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!isset($vars[\'sorting\']) || empty($vars[\'sorting\'])) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$vars[\'sorting\'] = \'default\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!isset($vars[\'amount\']) || !is_numeric($vars[\'amount\'])) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$vars[\'amount\'] = 5;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!isset($vars[\'template\'])) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$vars[\'template\'] = \'itemlist_\' . DataUtil::formatForOS($vars[\'objectType\']) . \'_display.tpl\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!isset($vars[\'customTemplate\'])) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$vars[\'customTemplate\'] = \'\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!isset($vars[\'filter\'])) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$vars[\'filter\'] = \'\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    {
      boolean _hasCategorisableEntities_5 = this._modelBehaviourExtensions.hasCategorisableEntities(it);
      if (_hasCategorisableEntities_5) {
        _builder.newLine();
        _builder.append("    ");
        _builder.append("if (!isset($vars[\'catIds\'])) {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("$primaryRegistry = ModUtil::apiFunc(\'");
        String _appName_19 = this._utils.appName(it);
        _builder.append(_appName_19, "        ");
        _builder.append("\', \'category\', \'getPrimaryProperty\', array(\'ot\' => $vars[\'objectType\']));");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("$vars[\'catIds\'] = array($primaryRegistry => array());");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("// backwards compatibility");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("if (isset($vars[\'catId\'])) {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("        ");
        _builder.append("$vars[\'catIds\'][$primaryRegistry][] = $vars[\'catId\'];");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("        ");
        _builder.append("unset($vars[\'catId\']);");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("} elseif (!is_array($vars[\'catIds\'])) {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("$vars[\'catIds\'] = explode(\',\', $vars[\'catIds\']);");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
      }
    }
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$this->view->setCaching(Zikula_View::CACHE_DISABLED);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// assign the approriate values");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$this->view->assign($vars);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// clear the block cache");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$this->view->clear_cache(\'");
    {
      boolean _targets_13 = this._utils.targets(it, "1.3.5");
      if (_targets_13) {
        _builder.append("block");
      } else {
        _builder.append("Block");
      }
    }
    _builder.append("/itemlist_display.tpl\');");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("$this->view->clear_cache(\'");
    {
      boolean _targets_14 = this._utils.targets(it, "1.3.5");
      if (_targets_14) {
        _builder.append("block");
      } else {
        _builder.append("Block");
      }
    }
    _builder.append("/itemlist_\' . DataUtil::formatForOS($vars[\'objectType\']) . \'_display.tpl\');");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("$this->view->clear_cache(\'");
    {
      boolean _targets_15 = this._utils.targets(it, "1.3.5");
      if (_targets_15) {
        _builder.append("block");
      } else {
        _builder.append("Block");
      }
    }
    _builder.append("/itemlist_display_description.tpl\');");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("$this->view->clear_cache(\'");
    {
      boolean _targets_16 = this._utils.targets(it, "1.3.5");
      if (_targets_16) {
        _builder.append("block");
      } else {
        _builder.append("Block");
      }
    }
    _builder.append("/itemlist_\' . DataUtil::formatForOS($vars[\'objectType\']) . \'_display_description.tpl\');");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// Return the output that has been generated by this function");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $this->view->fetch(\'");
    {
      boolean _targets_17 = this._utils.targets(it, "1.3.5");
      if (_targets_17) {
        _builder.append("block");
      } else {
        _builder.append("Block");
      }
    }
    _builder.append("/itemlist_modify.tpl\');");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Update block settings.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param array $blockinfo the blockinfo structure");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return array the modified blockinfo structure.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function update($blockinfo)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// Get current content");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$vars = BlockUtil::varsFromContent($blockinfo[\'content\']);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$vars[\'objectType\'] = $this->request->request->filter(\'objecttype\', \'");
    Entity _leadingEntity_2 = this._modelExtensions.getLeadingEntity(it);
    String _name_3 = _leadingEntity_2.getName();
    String _formatForCode_3 = this._formattingExtensions.formatForCode(_name_3);
    _builder.append(_formatForCode_3, "    ");
    _builder.append("\', FILTER_SANITIZE_STRING);");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("$vars[\'sorting\'] = $this->request->request->filter(\'sorting\', \'default\', FILTER_SANITIZE_STRING);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$vars[\'amount\'] = (int) $this->request->request->filter(\'amount\', 5, FILTER_VALIDATE_INT);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$vars[\'template\'] = $this->request->request->get(\'template\', \'\');");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$vars[\'customTemplate\'] = $this->request->request->get(\'customtemplate\', \'\');");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$vars[\'filter\'] = $this->request->request->get(\'filter\', \'\');");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$controllerHelper = new ");
    {
      boolean _targets_18 = this._utils.targets(it, "1.3.5");
      if (_targets_18) {
        String _appName_20 = this._utils.appName(it);
        _builder.append(_appName_20, "    ");
        _builder.append("_Util_Controller");
      } else {
        _builder.append("ControllerUtil");
      }
    }
    _builder.append("($this->serviceManager);");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!in_array($vars[\'objectType\'], $controllerHelper->getObjectTypes(\'block\'))) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$vars[\'objectType\'] = $controllerHelper->getDefaultObjectType(\'block\');");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    {
      boolean _hasCategorisableEntities_6 = this._modelBehaviourExtensions.hasCategorisableEntities(it);
      if (_hasCategorisableEntities_6) {
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$primaryRegistry = ModUtil::apiFunc(\'");
        String _appName_21 = this._utils.appName(it);
        _builder.append(_appName_21, "    ");
        _builder.append("\', \'category\', \'getPrimaryProperty\', array(\'ot\' => $vars[\'objectType\']));");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("$vars[\'catIds\'] = array($primaryRegistry => array());");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("if (in_array($vars[\'objectType\'], $this->categorisableObjectTypes)) {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("$vars[\'catIds\'] = ModUtil::apiFunc(\'");
        String _appName_22 = this._utils.appName(it);
        _builder.append(_appName_22, "        ");
        _builder.append("\', \'category\', \'retrieveCategoriesFromRequest\', array(\'ot\' => $vars[\'objectType\']));");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
      }
    }
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// write back the new contents");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$blockinfo[\'content\'] = BlockUtil::varsToContent($vars);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// clear the block cache");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$this->view->clear_cache(\'");
    {
      boolean _targets_19 = this._utils.targets(it, "1.3.5");
      if (_targets_19) {
        _builder.append("block");
      } else {
        _builder.append("Block");
      }
    }
    _builder.append("/itemlist_display.tpl\');");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("$this->view->clear_cache(\'");
    {
      boolean _targets_20 = this._utils.targets(it, "1.3.5");
      if (_targets_20) {
        _builder.append("block");
      } else {
        _builder.append("Block");
      }
    }
    _builder.append("/itemlist_\' . ucwords($vars[\'objectType\']) . \'_display.tpl\');");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("$this->view->clear_cache(\'");
    {
      boolean _targets_21 = this._utils.targets(it, "1.3.5");
      if (_targets_21) {
        _builder.append("block");
      } else {
        _builder.append("Block");
      }
    }
    _builder.append("/itemlist_display_description.tpl\');");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("$this->view->clear_cache(\'");
    {
      boolean _targets_22 = this._utils.targets(it, "1.3.5");
      if (_targets_22) {
        _builder.append("block");
      } else {
        _builder.append("Block");
      }
    }
    _builder.append("/itemlist_\' . ucwords($vars[\'objectType\']) . \'_display_description.tpl\');");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $blockinfo;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence listBlockImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _targets = this._utils.targets(it, "1.3.5");
      boolean _not = (!_targets);
      if (_not) {
        _builder.append("namespace ");
        String _appName = this._utils.appName(it);
        _builder.append(_appName, "");
        _builder.append("\\Block;");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
      }
    }
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Generic item list block implementation class.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    {
      boolean _targets_1 = this._utils.targets(it, "1.3.5");
      if (_targets_1) {
        _builder.append("class ");
        String _appName_1 = this._utils.appName(it);
        _builder.append(_appName_1, "");
        _builder.append("_Block_ItemList extends ");
        String _appName_2 = this._utils.appName(it);
        _builder.append(_appName_2, "");
        _builder.append("_Block_Base_ItemList");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("class ItemListBlock extends Base\\ItemListBlock");
        _builder.newLine();
      }
    }
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// feel free to extend the item list block here");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
}
