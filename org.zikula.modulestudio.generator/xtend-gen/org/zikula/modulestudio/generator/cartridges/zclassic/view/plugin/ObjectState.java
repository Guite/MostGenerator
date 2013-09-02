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
public class ObjectState {
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
    String _viewPluginFilePath = this._namingExtensions.viewPluginFilePath(it, "modifier", "ObjectState");
    CharSequence _objectStateFile = this.objectStateFile(it);
    fsa.generateFile(_viewPluginFilePath, _objectStateFile);
  }
  
  private CharSequence objectStateFile(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    FileHelper _fileHelper = new FileHelper();
    CharSequence _phpFileHeader = _fileHelper.phpFileHeader(it);
    _builder.append(_phpFileHeader, "");
    _builder.newLineIfNotEmpty();
    CharSequence _objectStateImpl = this.objectStateImpl(it);
    _builder.append(_objectStateImpl, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence objectStateImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* The ");
    String _appName = this._utils.appName(it);
    String _formatForDB = this._formattingExtensions.formatForDB(_appName);
    _builder.append(_formatForDB, " ");
    _builder.append("ObjectState modifier displays the name of a given object\'s workflow state.");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("* Examples:");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*    {$item.workflowState|");
    String _appName_1 = this._utils.appName(it);
    String _formatForDB_1 = this._formattingExtensions.formatForDB(_appName_1);
    _builder.append(_formatForDB_1, " ");
    _builder.append("ObjectState}       {* with led icon *}");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*    {$item.workflowState|");
    String _appName_2 = this._utils.appName(it);
    String _formatForDB_2 = this._formattingExtensions.formatForDB(_appName_2);
    _builder.append(_formatForDB_2, " ");
    _builder.append("ObjectState:false} {* no icon *}");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string  $state    Name of given workflow state.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param boolean $withIcon Whether a led icon should be displayed before the name.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return string Enriched and translated workflow state ready for display.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("function smarty_modifier_");
    String _appName_3 = this._utils.appName(it);
    String _formatForDB_3 = this._formattingExtensions.formatForDB(_appName_3);
    _builder.append(_formatForDB_3, "");
    _builder.append("ObjectState($state = \'initial\', $withIcon = true)");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$serviceManager = ServiceUtil::getManager();");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$workflowHelper = new ");
    {
      boolean _targets = this._utils.targets(it, "1.3.5");
      if (_targets) {
        String _appName_4 = this._utils.appName(it);
        _builder.append(_appName_4, "    ");
        _builder.append("_Util_Workflow");
      } else {
        String _appNamespace = this._utils.appNamespace(it);
        _builder.append(_appNamespace, "    ");
        _builder.append("\\Util\\WorkflowUtil");
      }
    }
    _builder.append("($serviceManager");
    {
      boolean _targets_1 = this._utils.targets(it, "1.3.5");
      boolean _not = (!_targets_1);
      if (_not) {
        _builder.append(", ModUtil::getModule(\'");
        String _appName_5 = this._utils.appName(it);
        _builder.append(_appName_5, "    ");
        _builder.append("\')");
      }
    }
    _builder.append(");");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("$stateInfo = $workflowHelper->getStateInfo($state);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$result = $stateInfo[\'text\'];");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($withIcon === true) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$result = \'<img src=\"\' . System::getBaseUrl() . \'images/icons/extrasmall/\' . $stateInfo[\'icon\'] . \'\" width=\"16\" height=\"16\" alt=\"\' . $result . \'\" />&nbsp;&nbsp;\' . $result;");
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
}
