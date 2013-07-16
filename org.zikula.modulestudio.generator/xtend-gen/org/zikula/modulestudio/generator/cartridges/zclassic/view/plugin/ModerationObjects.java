package org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin;

import com.google.inject.Inject;
import de.guite.modulestudio.metamodel.modulestudio.Application;
import de.guite.modulestudio.metamodel.modulestudio.EntityWorkflowType;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;
import org.zikula.modulestudio.generator.extensions.WorkflowExtensions;

@SuppressWarnings("all")
public class ModerationObjects {
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
  
  @Inject
  @Extension
  private WorkflowExtensions _workflowExtensions = new Function0<WorkflowExtensions>() {
    public WorkflowExtensions apply() {
      WorkflowExtensions _workflowExtensions = new WorkflowExtensions();
      return _workflowExtensions;
    }
  }.apply();
  
  public void generate(final Application it, final IFileSystemAccess fsa) {
    String _viewPluginFilePath = this._namingExtensions.viewPluginFilePath(it, "function", "ModerationObjects");
    CharSequence _moderationObjectsFile = this.moderationObjectsFile(it);
    fsa.generateFile(_viewPluginFilePath, _moderationObjectsFile);
  }
  
  private CharSequence moderationObjectsFile(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    FileHelper _fileHelper = new FileHelper();
    CharSequence _phpFileHeader = _fileHelper.phpFileHeader(it);
    _builder.append(_phpFileHeader, "");
    _builder.newLineIfNotEmpty();
    CharSequence _moderationObjectsImpl = this.moderationObjectsImpl(it);
    _builder.append(_moderationObjectsImpl, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence moderationObjectsImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* The ");
    String _appName = this._utils.appName(it);
    String _formatForDB = this._formattingExtensions.formatForDB(_appName);
    _builder.append(_formatForDB, " ");
    _builder.append("ModerationObjects plugin determines the amount of ");
    {
      boolean _hasWorkflow = this._workflowExtensions.hasWorkflow(it, EntityWorkflowType.ENTERPRISE);
      if (_hasWorkflow) {
        _builder.append("unaccepted and ");
      }
    }
    _builder.append("unapproved objects.");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("* It uses the same logic as the moderation block and the pending content listener.");
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
    _builder.append("ModerationObjects($params, $view)");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!isset($params[\'assign\']) || empty($params[\'assign\'])) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$view->trigger_error(__f(\'Error! in %1$s: the %2$s parameter must be specified.\', array(\'");
    String _appName_2 = this._utils.appName(it);
    String _formatForDB_2 = this._formattingExtensions.formatForDB(_appName_2);
    _builder.append(_formatForDB_2, "        ");
    _builder.append("ModerationObjects\', \'assign\')));");
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
    _builder.append("$serviceManager = $view->getServiceManager();");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$workflowHelper = new ");
    String _appName_3 = this._utils.appName(it);
    _builder.append(_appName_3, "    ");
    {
      boolean _targets = this._utils.targets(it, "1.3.5");
      if (_targets) {
        _builder.append("_Util_Workflow");
      } else {
        _builder.append("\\Util\\WorkflowUtil");
      }
    }
    _builder.append("($serviceManager);");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("$result = $workflowHelper->collectAmountOfModerationItems();");
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
