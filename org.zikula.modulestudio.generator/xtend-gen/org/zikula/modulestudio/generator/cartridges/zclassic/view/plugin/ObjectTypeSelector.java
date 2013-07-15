package org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin;

import com.google.inject.Inject;
import de.guite.modulestudio.metamodel.modulestudio.Application;
import de.guite.modulestudio.metamodel.modulestudio.Entity;
import org.eclipse.emf.common.util.EList;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class ObjectTypeSelector {
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
  
  public void generate(final Application it, final IFileSystemAccess fsa) {
    String _viewPluginFilePath = this._namingExtensions.viewPluginFilePath(it, "function", "ObjectTypeSelector");
    CharSequence _selectorObjectTypesFile = this.selectorObjectTypesFile(it);
    fsa.generateFile(_viewPluginFilePath, _selectorObjectTypesFile);
  }
  
  private CharSequence selectorObjectTypesFile(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    FileHelper _fileHelper = new FileHelper();
    CharSequence _phpFileHeader = _fileHelper.phpFileHeader(it);
    _builder.append(_phpFileHeader, "");
    _builder.newLineIfNotEmpty();
    CharSequence _selectorObjectTypesImpl = this.selectorObjectTypesImpl(it);
    _builder.append(_selectorObjectTypesImpl, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence selectorObjectTypesImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* The ");
    String _appName = this._utils.appName(it);
    String _formatForDB = this._formattingExtensions.formatForDB(_appName);
    _builder.append(_formatForDB, " ");
    _builder.append("ObjectTypeSelector plugin provides items for a dropdown selector.");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Available parameters:");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*   - assign: If set, the results are assigned to the corresponding variable instead of printed out.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param  array            $params All attributes passed to this function from the template.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param  Zikula_Form_View $view   Reference to the view object.");
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
    _builder.append("ObjectTypeSelector($params, $view)");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$dom = ");
    {
      boolean _targets = this._utils.targets(it, "1.3.5");
      boolean _not = (!_targets);
      if (_not) {
        _builder.append("\\");
      }
    }
    _builder.append("ZLanguage::getModuleDomain(\'");
    String _appName_2 = this._utils.appName(it);
    _builder.append(_appName_2, "    ");
    _builder.append("\');");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("$result = array();");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    CharSequence _entityEntries = this.entityEntries(it);
    _builder.append(_entityEntries, "    ");
    _builder.newLineIfNotEmpty();
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
  
  private CharSequence entityEntries(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      EList<Entity> _allEntities = this._modelExtensions.getAllEntities(it);
      for(final Entity entity : _allEntities) {
        _builder.append("$result[] = array(\'text\' => __(\'");
        String _nameMultiple = entity.getNameMultiple();
        String _formatForDisplayCapital = this._formattingExtensions.formatForDisplayCapital(_nameMultiple);
        _builder.append(_formatForDisplayCapital, "");
        _builder.append("\', $dom), \'value\' => \'");
        String _name = entity.getName();
        String _formatForCode = this._formattingExtensions.formatForCode(_name);
        _builder.append(_formatForCode, "");
        _builder.append("\');");
        _builder.newLineIfNotEmpty();
      }
    }
    return _builder;
  }
}
