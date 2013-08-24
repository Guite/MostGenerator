package org.zikula.modulestudio.generator.cartridges.zclassic.controller.apis;

import com.google.inject.Inject;
import de.guite.modulestudio.metamodel.modulestudio.Application;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.eclipse.xtext.xbase.lib.InputOutput;
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper;
import org.zikula.modulestudio.generator.cartridges.zclassic.view.additions.BlockModerationView;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class BlockModeration {
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
    InputOutput.<String>println("Generating block for moderation");
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
    String _plus = ("Moderation" + blockClassSuffix);
    final String blockFileName = (_plus + ".php");
    String _plus_1 = (blockPath + "Base/");
    String _plus_2 = (_plus_1 + blockFileName);
    CharSequence _moderationBlockBaseFile = this.moderationBlockBaseFile(it);
    fsa.generateFile(_plus_2, _moderationBlockBaseFile);
    String _plus_3 = (blockPath + blockFileName);
    CharSequence _moderationBlockFile = this.moderationBlockFile(it);
    fsa.generateFile(_plus_3, _moderationBlockFile);
    BlockModerationView _blockModerationView = new BlockModerationView();
    _blockModerationView.generate(it, fsa);
  }
  
  private CharSequence moderationBlockBaseFile(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _phpFileHeader = this.fh.phpFileHeader(it);
    _builder.append(_phpFileHeader, "");
    _builder.newLineIfNotEmpty();
    CharSequence _moderationBlockBaseClass = this.moderationBlockBaseClass(it);
    _builder.append(_moderationBlockBaseClass, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence moderationBlockFile(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _phpFileHeader = this.fh.phpFileHeader(it);
    _builder.append(_phpFileHeader, "");
    _builder.newLineIfNotEmpty();
    CharSequence _moderationBlockImpl = this.moderationBlockImpl(it);
    _builder.append(_moderationBlockImpl, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence moderationBlockBaseClass(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _targets = this._utils.targets(it, "1.3.5");
      boolean _not = (!_targets);
      if (_not) {
        _builder.append("namespace ");
        String _appNamespace = this._utils.appNamespace(it);
        _builder.append(_appNamespace, "");
        _builder.append("\\Block\\Base;");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
        _builder.append("use ");
        String _appNamespace_1 = this._utils.appNamespace(it);
        _builder.append(_appNamespace_1, "");
        _builder.append("\\Util\\WorkflowUtil;");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
        _builder.append("use BlockUtil;");
        _builder.newLine();
        _builder.append("use ModUtil;");
        _builder.newLine();
        _builder.append("use SecurityUtil;");
        _builder.newLine();
        _builder.append("use UserUtil;");
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
    _builder.append("* Moderation block base class.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("class ");
    {
      boolean _targets_1 = this._utils.targets(it, "1.3.5");
      if (_targets_1) {
        String _appName = this._utils.appName(it);
        _builder.append(_appName, "");
        _builder.append("_Block_Base_Moderation");
      } else {
        _builder.append("ModerationBlock");
      }
    }
    _builder.append(" extends Zikula_Controller_AbstractBlock");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    CharSequence _moderationBlockBaseImpl = this.moderationBlockBaseImpl(it);
    _builder.append(_moderationBlockBaseImpl, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence moderationBlockBaseImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
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
    _builder.append(":ModerationBlock:\', \'Block title::\');");
    _builder.newLineIfNotEmpty();
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
    _builder.append("\'text_type\'       => $this->__(\'Moderation\'),");
    _builder.newLine();
    _builder.append("                 ");
    _builder.append("\'text_type_long\'  => $this->__(\'Show a list of pending tasks to moderators.\'),");
    _builder.newLine();
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
    _builder.append("\'show_preview\'    => false,");
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
    String _appName_4 = this._utils.appName(it);
    _builder.append(_appName_4, "    ");
    _builder.append(":ModerationBlock:\', \"$blockinfo[title]::\", ACCESS_OVERVIEW)) {");
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
    String _appName_5 = this._utils.appName(it);
    _builder.append(_appName_5, "    ");
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
    _builder.append("if (!UserUtil::isLoggedIn()) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return false;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("ModUtil::initOOModule(\'");
    String _appName_6 = this._utils.appName(it);
    _builder.append(_appName_6, "    ");
    _builder.append("\');");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$this->view->setCaching(Zikula_View::CACHE_DISABLED);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$template = $this->getDisplayTemplate($vars);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$workflowHelper = new ");
    {
      boolean _targets = this._utils.targets(it, "1.3.5");
      if (_targets) {
        String _appName_7 = this._utils.appName(it);
        _builder.append(_appName_7, "    ");
        _builder.append("_Util_Workflow");
      } else {
        _builder.append("WorkflowUtil");
      }
    }
    _builder.append("($this->serviceManager");
    {
      boolean _targets_1 = this._utils.targets(it, "1.3.5");
      boolean _not = (!_targets_1);
      if (_not) {
        _builder.append(", ModUtil::getModule($this->name)");
      }
    }
    _builder.append(");");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("$amounts = $workflowHelper->collectAmountOfModerationItems();");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// assign block vars and fetched data");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$this->view->assign(\'moderationObjects\', $amounts);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// set a block title");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (empty($blockinfo[\'title\'])) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$blockinfo[\'title\'] = $this->__(\'Moderation\');");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$blockinfo[\'content\'] = $this->view->fetch($template);");
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
    _builder.append("$template = \'");
    {
      boolean _targets_2 = this._utils.targets(it, "1.3.5");
      if (_targets_2) {
        _builder.append("block");
      } else {
        _builder.append("Block");
      }
    }
    _builder.append("/moderation.tpl\';");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $template;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence moderationBlockImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _targets = this._utils.targets(it, "1.3.5");
      boolean _not = (!_targets);
      if (_not) {
        _builder.append("namespace ");
        String _appNamespace = this._utils.appNamespace(it);
        _builder.append(_appNamespace, "");
        _builder.append("\\Block;");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
      }
    }
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Moderation block implementation class.");
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
        _builder.append("_Block_Moderation extends ");
        String _appName_1 = this._utils.appName(it);
        _builder.append(_appName_1, "");
        _builder.append("_Block_Base_Moderation");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("class ModerationBlock extends Base\\ModerationBlock");
        _builder.newLine();
      }
    }
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// feel free to extend the moderation block here");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
}
