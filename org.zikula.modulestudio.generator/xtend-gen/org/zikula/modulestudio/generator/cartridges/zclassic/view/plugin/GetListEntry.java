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
public class GetListEntry {
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
    String _viewPluginFilePath = this._namingExtensions.viewPluginFilePath(it, "modifier", "GetListEntry");
    CharSequence _listEntryFile = this.getListEntryFile(it);
    fsa.generateFile(_viewPluginFilePath, _listEntryFile);
  }
  
  private CharSequence getListEntryFile(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    FileHelper _fileHelper = new FileHelper();
    CharSequence _phpFileHeader = _fileHelper.phpFileHeader(it);
    _builder.append(_phpFileHeader, "");
    _builder.newLineIfNotEmpty();
    CharSequence _listEntryImpl = this.getListEntryImpl(it);
    _builder.append(_listEntryImpl, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence getListEntryImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* The ");
    String _appName = this._utils.appName(it);
    String _formatForDB = this._formattingExtensions.formatForDB(_appName);
    _builder.append(_formatForDB, " ");
    _builder.append("GetListEntry modifier displays the name");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("* or names for a given list item.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $value      The dropdown value to process.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $objectType The treated object type.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $fieldName  The list field\'s name.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $delimiter  String used as separator for multiple selections.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return string List item name.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("function smarty_modifier_");
    String _appName_1 = this._utils.appName(it);
    String _formatForDB_1 = this._formattingExtensions.formatForDB(_appName_1);
    _builder.append(_formatForDB_1, "");
    _builder.append("GetListEntry($value, $objectType = \'\', $fieldName = \'\', $delimiter = \', \')");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (empty($value) || empty($objectType) || empty($fieldName)) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return $value;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$serviceManager = ServiceUtil::getManager();");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$helper = new ");
    String _appName_2 = this._utils.appName(it);
    _builder.append(_appName_2, "    ");
    {
      boolean _targets = this._utils.targets(it, "1.3.5");
      if (_targets) {
        _builder.append("_Util_ListEntries");
      } else {
        _builder.append("\\Util\\ListEntriesUtil");
      }
    }
    _builder.append("($serviceManager");
    {
      boolean _targets_1 = this._utils.targets(it, "1.3.5");
      boolean _not = (!_targets_1);
      if (_not) {
        _builder.append(", ModUtil::getModule(\'");
        String _appName_3 = this._utils.appName(it);
        _builder.append(_appName_3, "    ");
        _builder.append("\')");
      }
    }
    _builder.append(");");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $helper->resolve($value, $objectType, $fieldName, $delimiter);");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
}
