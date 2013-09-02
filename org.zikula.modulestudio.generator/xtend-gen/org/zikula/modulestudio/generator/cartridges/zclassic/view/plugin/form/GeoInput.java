package org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.form;

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
public class GeoInput {
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
  
  private FileHelper fh = new Function0<FileHelper>() {
    public FileHelper apply() {
      FileHelper _fileHelper = new FileHelper();
      return _fileHelper;
    }
  }.apply();
  
  public void generate(final Application it, final IFileSystemAccess fsa) {
    String _appSourceLibPath = this._namingExtensions.getAppSourceLibPath(it);
    final String formPluginPath = (_appSourceLibPath + "Form/Plugin/");
    String _plus = (formPluginPath + "Base/GeoInput.php");
    CharSequence _formGeoInputBaseFile = this.formGeoInputBaseFile(it);
    fsa.generateFile(_plus, _formGeoInputBaseFile);
    String _plus_1 = (formPluginPath + "GeoInput.php");
    CharSequence _formGeoInputFile = this.formGeoInputFile(it);
    fsa.generateFile(_plus_1, _formGeoInputFile);
    String _viewPluginFilePath = this._namingExtensions.viewPluginFilePath(it, "function", "GeoInput");
    CharSequence _formGeoInputPluginFile = this.formGeoInputPluginFile(it);
    fsa.generateFile(_viewPluginFilePath, _formGeoInputPluginFile);
  }
  
  private CharSequence formGeoInputBaseFile(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _phpFileHeader = this.fh.phpFileHeader(it);
    _builder.append(_phpFileHeader, "");
    _builder.newLineIfNotEmpty();
    CharSequence _formGeoInputBaseImpl = this.formGeoInputBaseImpl(it);
    _builder.append(_formGeoInputBaseImpl, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence formGeoInputFile(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _phpFileHeader = this.fh.phpFileHeader(it);
    _builder.append(_phpFileHeader, "");
    _builder.newLineIfNotEmpty();
    CharSequence _formGeoInputImpl = this.formGeoInputImpl(it);
    _builder.append(_formGeoInputImpl, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence formGeoInputPluginFile(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _phpFileHeader = this.fh.phpFileHeader(it);
    _builder.append(_phpFileHeader, "");
    _builder.newLineIfNotEmpty();
    CharSequence _formGeoInputPluginImpl = this.formGeoInputPluginImpl(it);
    _builder.append(_formGeoInputPluginImpl, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence formGeoInputBaseImpl(final Application it) {
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
        _builder.append("use Zikula_Form_Plugin_TextInput;");
        _builder.newLine();
        _builder.append("use Zikula_Form_View;");
        _builder.newLine();
        _builder.newLine();
      }
    }
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Geo value input.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* You can also use all of the features from the Zikula_Form_Plugin_TextInput plugin since");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* the geo input inherits from it.");
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
        _builder.append("_Form_Plugin_Base_");
      }
    }
    _builder.append("GeoInput extends Zikula_Form_Plugin_TextInput");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* Get filename of this file.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* The information is used to re-establish the plugins on postback.");
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
    _builder.append("* @see    Zikula_Form_AbstractPlugin");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @return void");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("public function create(Zikula_Form_View $view, &$params)");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$params[\'maxLength\'] = 11;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$params[\'width\'] = \'6em\';");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// let parent plugin do the work in detail");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("parent::create($view, $params);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* Helper method to determine css class.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @see Zikula_Form_Plugin_TextInput");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @return string the list of css classes to apply");
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
    _builder.append("$class = parent::getStyleClass();");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return str_replace(\'z-form-text\', \'z-form-geo\', $class);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* Validates the input.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @param Zikula_Form_View $view Reference to Zikula_Form_View object.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @return void");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("public function validate(Zikula_Form_View $view)");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("parent::validate($view);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if (!$this->isValid) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("return;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if ($this->text !== \'\') {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$this->text = number_format($this->text, 7, \'.\', \'\');");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("if (!is_numeric($this->text)) {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("$this->setError(__(\'Error! Invalid number.\'));");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* Parses a value.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @param Zikula_Form_View $view Reference to Zikula_Form_View object.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @param string           $text Text.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @return string Parsed Text.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("public function parseValue(Zikula_Form_View $view, $text)");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if ($text === \'\') {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("return null;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// process float value");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$text = floatval($text);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return $text;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* Format the value to specific format.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @param Zikula_Form_View $view  Reference to Zikula_Form_View object.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @param string           $value The value to format.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @return string Formatted value.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("public function formatValue(Zikula_Form_View $view, $value)");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return number_format($value, 7, \'.\', \'\');");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence formGeoInputImpl(final Application it) {
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
        _builder.append("use Base\\GeoInput as BaseGeoInput;");
        _builder.newLine();
        _builder.newLine();
      }
    }
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Geo value input.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* You can also use all of the features from the Zikula_Form_Plugin_TextInput plugin since");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* the geo input inherits from it.");
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
        _builder.append("_Form_Plugin_GeoInput extends ");
        String _appName_1 = this._utils.appName(it);
        _builder.append(_appName_1, "");
        _builder.append("_Form_Plugin_Base_GeoInput");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("class GeoInput extends BaseGeoInput");
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
  
  private CharSequence formGeoInputPluginImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* The ");
    String _appName = this._utils.appName(it);
    String _formatForDB = this._formattingExtensions.formatForDB(_appName);
    _builder.append(_formatForDB, " ");
    _builder.append("GeoInput plugin handles fields carrying geo data.");
    _builder.newLineIfNotEmpty();
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
    _builder.append("GeoInput($params, $view)");
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
        _builder.append("_Form_Plugin_GeoInput");
      } else {
        _builder.append("\\\\");
        String _vendor = it.getVendor();
        String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(_vendor);
        _builder.append(_formatForCodeCapital, "    ");
        _builder.append("\\\\");
        String _name = it.getName();
        String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(_name);
        _builder.append(_formatForCodeCapital_1, "    ");
        _builder.append("Module\\\\Form\\\\Plugin\\\\GeoInput");
      }
    }
    _builder.append("\', $params);");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
}
