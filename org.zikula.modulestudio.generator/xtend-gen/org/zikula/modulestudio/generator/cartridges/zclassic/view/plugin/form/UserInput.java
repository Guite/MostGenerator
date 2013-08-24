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
public class UserInput {
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
    String _plus = (formPluginPath + "Base/UserInput.php");
    CharSequence _formUserInputBaseFile = this.formUserInputBaseFile(it);
    fsa.generateFile(_plus, _formUserInputBaseFile);
    String _plus_1 = (formPluginPath + "UserInput.php");
    CharSequence _formUserInputFile = this.formUserInputFile(it);
    fsa.generateFile(_plus_1, _formUserInputFile);
    String _viewPluginFilePath = this._namingExtensions.viewPluginFilePath(it, "function", "UserInput");
    CharSequence _formUserInputPluginFile = this.formUserInputPluginFile(it);
    fsa.generateFile(_viewPluginFilePath, _formUserInputPluginFile);
  }
  
  private CharSequence formUserInputBaseFile(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _phpFileHeader = this.fh.phpFileHeader(it);
    _builder.append(_phpFileHeader, "");
    _builder.newLineIfNotEmpty();
    CharSequence _formUserInputBaseImpl = this.formUserInputBaseImpl(it);
    _builder.append(_formUserInputBaseImpl, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence formUserInputFile(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _phpFileHeader = this.fh.phpFileHeader(it);
    _builder.append(_phpFileHeader, "");
    _builder.newLineIfNotEmpty();
    CharSequence _formUserInputImpl = this.formUserInputImpl(it);
    _builder.append(_formUserInputImpl, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence formUserInputPluginFile(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _phpFileHeader = this.fh.phpFileHeader(it);
    _builder.append(_phpFileHeader, "");
    _builder.newLineIfNotEmpty();
    CharSequence _formUserInputPluginImpl = this.formUserInputPluginImpl(it);
    _builder.append(_formUserInputPluginImpl, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence formUserInputBaseImpl(final Application it) {
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
        _builder.append("use DataUtil;");
        _builder.newLine();
        _builder.append("use UserUtil;");
        _builder.newLine();
        _builder.append("use Zikula_Form_Plugin_TextInput;");
        _builder.newLine();
        _builder.append("use Zikula_Form_View;");
        _builder.newLine();
        _builder.append("use ZLanguage;");
        _builder.newLine();
        _builder.newLine();
      }
    }
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* User field plugin providing an autocomplete for user names.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* You can also use all of the features from the Zikula_Form_Plugin_TextInput plugin since");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* the user input inherits from it.");
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
    _builder.append("UserInput extends Zikula_Form_Plugin_TextInput");
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
    _builder.append("$params[\'maxLength\'] = 25;");
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
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return str_replace(\'z-form-text\', \'z-form-user\', $class);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* Render event handler.");
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
    _builder.append("* @return string The rendered output");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("public function render(Zikula_Form_View $view)");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$dom = ZLanguage::getModuleDomain(\'");
    String _appName_1 = this._utils.appName(it);
    _builder.append(_appName_1, "        ");
    _builder.append("\');");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("//$result = parent::render($view);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// start code from TextInput base class");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$titleHtml = ($this->toolTip != null ? \' title=\"\' . $view->translateForDisplay($this->toolTip) . \'\"\' : \'\');");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$readOnlyHtml = ($this->readOnly ? \' readonly=\"readonly\" tabindex=\"-1\"\' : \'\');");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$sizeHtml = ($this->size > 0 ? \" size=\\\"{$this->size}\\\"\" : \'\');");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$maxLengthHtml = ($this->maxLength > 0 ? \" maxlength=\\\"{$this->maxLength}\\\"\" : \'\');");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$class = $this->getStyleClass();");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$attributes = $this->renderAttributes($view);");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// end code from TextInput base class");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if ($this->readOnly) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("return $result;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$selectorDefaultValue = \'\';");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if (intval($this->text) > 0) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$selectorDefaultValue = UserUtil::getVar(\'uname\', intval($this->text));");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$searchTitle = __(\'Search user\', $dom);");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$selectorAttributes = $titleHtml . $sizeHtml . $maxLengthHtml . $readOnlyHtml . \' value=\"\' . $selectorDefaultValue . \'\" class=\"\' . $class . \'\"\' . $attributes;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$result = \'<div id=\"\' . $this->getId() . \'LiveSearch\" class=\"");
    String _prefix = it.getPrefix();
    _builder.append(_prefix, "        ");
    _builder.append("LiveSearchUser z-hide\">");
    _builder.newLineIfNotEmpty();
    _builder.append("                ");
    _builder.append("<img src=\"/images/icons/extrasmall/search.png\" width=\"16\" height=\"16\" alt=\"\' . $searchTitle . \'\" title=\"\' . $searchTitle . \'\" />");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("<input type=\"text\" id=\"\' . $this->getId() . \'Selector\" name=\"\' . $this->getId() . \'Selector\"\' . $selectorAttributes . \' />");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("<img src=\"/images/ajax/indicator_circle.gif\" width=\"16\" height=\"16\" alt=\"\" id=\"\' . $this->getId() . \'Indicator\" style=\"display: none\" />");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("<span id=\"\' . $this->getId() . \'NoResultsHint\" class=\"z-hide\">\' . __(\'No results found!\', $dom) . \'</span>");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("<div id=\"\' . $this->getId() . \'SelectorChoices\" class=\"");
    String _prefix_1 = it.getPrefix();
    _builder.append(_prefix_1, "                ");
    _builder.append("AutoCompleteUser\"></div>\';");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if ($this->mandatory && $this->mandatorysym) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$result .= \'<span class=\"z-form-mandatory-flag\">*</span>\';");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$result .= \'</div>\' . \"\\n\";");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$result .= \'<noscript><p>\' . __(\'This function requires JavaScript activated!\', $dom) . \'</p></noscript>\' . \"\\n\";");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$result .= \'<input type=\"hidden\" id=\"\' . $this->getId() . \'\" name=\"\' . $this->getId() . \'\" value=\"\' . DataUtil::formatForDisplay($this->text) . \'\" />\' . \"\\n\";");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return $result;");
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
    _builder.append("if (empty($text)) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("return 0;//null;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
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
    _builder.append("* Validates the input string.");
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
    _builder.append("* @return boolean");
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
    _builder.append("if (strlen($this->text) > 0) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$uid = intval($this->text);");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("if (UserUtil::getVar(\'uname\', $uid) == null) {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("$this->setError(__(\'Error! Invalid user.\'));");
    _builder.newLine();
    _builder.newLine();
    _builder.append("                ");
    _builder.append("return false;");
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
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence formUserInputImpl(final Application it) {
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
      }
    }
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* User field plugin providing an autocomplete for user names.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* You can also use all of the features from the Zikula_Form_Plugin_TextInput plugin since");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* the user input inherits from it.");
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
        _builder.append("_Form_Plugin_UserInput extends ");
        String _appName_1 = this._utils.appName(it);
        _builder.append(_appName_1, "");
        _builder.append("_Form_Plugin_Base_UserInput");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("class UserInput extends Base\\UserInput");
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
  
  private CharSequence formUserInputPluginImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* The ");
    String _appName = this._utils.appName(it);
    String _formatForDB = this._formattingExtensions.formatForDB(_appName);
    _builder.append(_formatForDB, " ");
    _builder.append("UserInput plugin handles fields carrying user ids.");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("* It provides an autocomplete for user names.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param array            $params  All attributes passed to this function from the template.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param Zikula_Form_View $view    Reference to the view object.");
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
    _builder.append("UserInput($params, $view)");
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
        _builder.append("_Form_Plugin_UserInput");
      } else {
        _builder.append("\\\\");
        String _appName_3 = this._utils.appName(it);
        _builder.append(_appName_3, "    ");
        _builder.append("\\\\Form\\\\Plugin\\\\UserInput");
      }
    }
    _builder.append("\', $params);");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
}
