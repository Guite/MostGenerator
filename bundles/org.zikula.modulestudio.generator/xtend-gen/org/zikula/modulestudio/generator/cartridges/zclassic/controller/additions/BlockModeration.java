package org.zikula.modulestudio.generator.cartridges.zclassic.controller.additions;

import de.guite.modulestudio.metamodel.Application;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.InputOutput;
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper;
import org.zikula.modulestudio.generator.cartridges.zclassic.view.additions.BlockModerationView;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class BlockModeration {
  @Extension
  private NamingExtensions _namingExtensions = new NamingExtensions();
  
  @Extension
  private Utils _utils = new Utils();
  
  private FileHelper fh = new FileHelper();
  
  public void generate(final Application it, final IFileSystemAccess fsa) {
    InputOutput.<String>println("Generating block for moderation");
    String _appSourceLibPath = this._namingExtensions.getAppSourceLibPath(it);
    String _plus = (_appSourceLibPath + "Block/ModerationBlock.php");
    this._namingExtensions.generateClassPair(it, fsa, _plus, 
      this.fh.phpFileContent(it, this.moderationBlockBaseClass(it)), this.fh.phpFileContent(it, this.moderationBlockImpl(it)));
    new BlockModerationView().generate(it, fsa);
  }
  
  private CharSequence moderationBlockBaseClass(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("namespace ");
    String _appNamespace = this._utils.appNamespace(it);
    _builder.append(_appNamespace);
    _builder.append("\\Block\\Base;");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("use Zikula\\BlocksModule\\AbstractBlockHandler;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Moderation block base class.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("abstract class AbstractModerationBlock extends AbstractBlockHandler");
    _builder.newLine();
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
    CharSequence _display = this.display(it);
    _builder.append(_display);
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    CharSequence _displayTemplate = this.getDisplayTemplate(it);
    _builder.append(_displayTemplate);
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence display(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Display the block content.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param array $properties The block properties array");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return array|string");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function display(array $properties)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// only show block content if the user has the required permissions");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!$this->hasPermission(\'");
    String _appName = this._utils.appName(it);
    _builder.append(_appName, "    ");
    _builder.append(":ModerationBlock:\', \"$properties[title]::\", ACCESS_OVERVIEW)) {");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("return false;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$currentUserApi = $this->get(\'zikula_users_module.current_user\');");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!$currentUserApi->isLoggedIn()) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return false;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$template = $this->getDisplayTemplate();");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$workflowHelper = $this->get(\'");
    String _appService = this._utils.appService(it);
    _builder.append(_appService, "    ");
    _builder.append(".workflow_helper\');");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("$amounts = $workflowHelper->collectAmountOfModerationItems();");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// set a block title");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (empty($properties[\'title\'])) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$properties[\'title\'] = $this->__(\'Moderation\');");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $this->renderView($template, [");
    _builder.append("\'moderationObjects\' => $amounts]);");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence getDisplayTemplate(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Returns the template used for output.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return string the template path");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected function getDisplayTemplate()");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return \'@");
    String _appName = this._utils.appName(it);
    _builder.append(_appName, "    ");
    _builder.append("/Block/moderation.html.twig\';");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence moderationBlockImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("namespace ");
    String _appNamespace = this._utils.appNamespace(it);
    _builder.append(_appNamespace);
    _builder.append("\\Block;");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("use ");
    String _appNamespace_1 = this._utils.appNamespace(it);
    _builder.append(_appNamespace_1);
    _builder.append("\\Block\\Base\\AbstractModerationBlock;");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Moderation block implementation class.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("class ModerationBlock extends AbstractModerationBlock");
    _builder.newLine();
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
