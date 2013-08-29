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
public class RelationSelectorAutoComplete {
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
    String _plus = (formPluginPath + "Base/RelationSelectorAutoComplete.php");
    CharSequence _relationSelectorBaseFile = this.relationSelectorBaseFile(it);
    fsa.generateFile(_plus, _relationSelectorBaseFile);
    String _plus_1 = (formPluginPath + "RelationSelectorAutoComplete.php");
    CharSequence _relationSelectorFile = this.relationSelectorFile(it);
    fsa.generateFile(_plus_1, _relationSelectorFile);
    String _viewPluginFilePath = this._namingExtensions.viewPluginFilePath(it, "function", "RelationSelectorAutoComplete");
    CharSequence _relationSelectorPluginFile = this.relationSelectorPluginFile(it);
    fsa.generateFile(_viewPluginFilePath, _relationSelectorPluginFile);
  }
  
  private CharSequence relationSelectorBaseFile(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _phpFileHeader = this.fh.phpFileHeader(it);
    _builder.append(_phpFileHeader, "");
    _builder.newLineIfNotEmpty();
    CharSequence _relationSelectorBaseImpl = this.relationSelectorBaseImpl(it);
    _builder.append(_relationSelectorBaseImpl, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence relationSelectorFile(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _phpFileHeader = this.fh.phpFileHeader(it);
    _builder.append(_phpFileHeader, "");
    _builder.newLineIfNotEmpty();
    CharSequence _relationSelectorImpl = this.relationSelectorImpl(it);
    _builder.append(_relationSelectorImpl, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence relationSelectorPluginFile(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _phpFileHeader = this.fh.phpFileHeader(it);
    _builder.append(_phpFileHeader, "");
    _builder.newLineIfNotEmpty();
    CharSequence _relationSelectorPluginImpl = this.relationSelectorPluginImpl(it);
    _builder.append(_relationSelectorPluginImpl, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence relationSelectorBaseImpl(final Application it) {
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
    _builder.append("* Relation selector plugin base class.");
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
        _builder.append("_Form_Plugin_Base_RelationSelectorAutoComplete extends ");
        String _appName_1 = this._utils.appName(it);
        _builder.append(_appName_1, "");
        _builder.append("_Form_Plugin_AbstractObjectSelector");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("class RelationSelectorAutoComplete extends \\");
        String _vendor = it.getVendor();
        String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(_vendor);
        _builder.append(_formatForCodeCapital, "");
        _builder.append("\\");
        String _name = it.getName();
        String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(_name);
        _builder.append(_formatForCodeCapital_1, "");
        _builder.append("\\Form\\Plugin\\AbstractObjectSelector");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* Identifier prefix (unique name for JS).");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @var string");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("public $idPrefix = \'\';");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* Url for inline creation of new related items (if allowed).");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @var string");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("public $createLink = \'\';");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* Name of entity to be selected.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @var string");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("public $selectedEntityName = \'\';");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* Whether the treated entity has an image field or not.");
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
    _builder.append("public $withImage = false;");
    _builder.newLine();
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
    _builder.append("* Load event handler.");
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
    _builder.append("* @return void");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("public function load(Zikula_Form_View $view, &$params)");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$this->processRequestData($view, \'GET\');");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// load list items");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("parent::load($view, $params);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if (isset($params[\'idPrefix\'])) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$this->idPrefix = $params[\'idPrefix\'];");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("unset($params[\'idPrefix\']);");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$this->inputName = $this->idPrefix . \'ItemList\';");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if (isset($params[\'createLink\'])) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$this->createLink = $params[\'createLink\'];");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("unset($params[\'createLink\']);");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if (isset($params[\'selectedEntityName\'])) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$this->selectedEntityName = $params[\'selectedEntityName\'];");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("unset($params[\'selectedEntityName\']);");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if (isset($params[\'withImage\'])) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$this->withImage = $params[\'withImage\'];");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("unset($params[\'withImage\']);");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// preprocess selection: collect id list for related items");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$this->preprocessIdentifiers($view, $params);");
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
    _builder.append("return \'z-form-relationlist autocomplete\';");
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
    String _appName_2 = this._utils.appName(it);
    _builder.append(_appName_2, "        ");
    _builder.append("\');");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("$many = ($this->selectionMode == \'multiple\');");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$entityName = $this->selectedEntityName;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$addLinkText = $many ? __f(\'Add %s\', array($entityName), $dom) : __f(\'Select %s\', array($entityName), $dom);");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$selectLabelText = __f(\'Find %s\', array($entityName), $dom);");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$searchIconText = __f(\'Search %s\', array($entityName), $dom);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$idPrefix = $this->idPrefix;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$addLink = \'<a id=\"\' . $idPrefix . \'AddLink\" href=\"javascript:void(0);\" class=\"z-hide\">\' . $addLinkText . \'</a>\';");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$createLink = \'\';");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if ($this->createLink != \'\') {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$createLink = \'<a id=\"\' . \'SelectorDoNew\" href=\"\' . DataUtil::formatForDisplay($this->createLink) . \'\" title=\"\' . __f(\'Create new %s\', array($entityName), $dom) . \'\" class=\"z-button ");
    String _prefix = this._utils.prefix(it);
    _builder.append(_prefix, "            ");
    _builder.append("InlineButton\">\' . __(\'Create\', $dom) . \'</a>\';");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$alias = $this->id;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$result = \'");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("<div class=\"");
    String _prefix_1 = this._utils.prefix(it);
    _builder.append(_prefix_1, "            ");
    _builder.append("RelationRightSide\">\'");
    _builder.newLineIfNotEmpty();
    _builder.append("                ");
    _builder.append(". $addLink . \'");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("<div id=\"\' . $idPrefix . \'AddFields\">");
    _builder.newLine();
    _builder.append("                    ");
    _builder.append("<label for=\"\' . $idPrefix . \'Selector\">\' . $selectLabelText . \'</label>");
    _builder.newLine();
    _builder.append("                    ");
    _builder.append("<br />");
    _builder.newLine();
    _builder.append("                    ");
    _builder.append("<img src=\"/images/icons/extrasmall/search.png\" width=\"16\" height=\"16\" alt=\"\' . $searchIconText . \'\" />");
    _builder.newLine();
    _builder.append("                    ");
    _builder.append("<input type=\"text\" name=\"\' . $idPrefix . \'Selector\" id=\"\' . $idPrefix . \'Selector\" value=\"\" />");
    _builder.newLine();
    _builder.append("                    ");
    _builder.append("<input type=\"hidden\" name=\"\' . $idPrefix . \'Scope\" id=\"\' . $idPrefix . \'Scope\" value=\"\' . ((!$many) ? \'0\' : \'1\') . \'\" />");
    _builder.newLine();
    _builder.append("                    ");
    _builder.append("<img src=\"/images/ajax/indicator_circle.gif\" width=\"16\" height=\"16\" alt=\"\" id=\"\' . $idPrefix . \'Indicator\" style=\"display: none\" />");
    _builder.newLine();
    _builder.append("                    ");
    _builder.append("<span id=\"\' . $idPrefix . \'NoResultsHint\" class=\"z-hide\">\' . __(\'No results found!\', $dom) . \'</span>");
    _builder.newLine();
    _builder.append("                    ");
    _builder.append("<div id=\"\' . $idPrefix . \'SelectorChoices\" class=\"");
    String _prefix_2 = this._utils.prefix(it);
    _builder.append(_prefix_2, "                    ");
    _builder.append("AutoComplete\' . (($this->withImage) ? \'WithImage\' : \'\') . \'\"></div>");
    _builder.newLineIfNotEmpty();
    _builder.append("                    ");
    _builder.append("<input type=\"button\" id=\"\' . $idPrefix . \'SelectorDoCancel\" name=\"\' . $idPrefix . \'SelectorDoCancel\" value=\"\' . __(\'Cancel\', $dom) . \'\" class=\"z-button ");
    String _prefix_3 = this._utils.prefix(it);
    _builder.append(_prefix_3, "                    ");
    _builder.append("InlineButton\" />\'");
    _builder.newLineIfNotEmpty();
    _builder.append("                    ");
    _builder.append(". $createLink . \'");
    _builder.newLine();
    _builder.append("                    ");
    _builder.append("<noscript><p>\' . __(\'This function requires JavaScript activated!\', $dom) . \'</p></noscript>");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("</div>");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("</div>\';");
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
    _builder.append("* Decode event handler.");
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
    _builder.append("public function decode(Zikula_Form_View $view)");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("parent::decode($view);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// postprocess selection: reinstantiate objects for identifiers");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$this->processRequestData($view, \'POST\');");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence relationSelectorImpl(final Application it) {
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
    _builder.append("* Relation selector plugin implementation class.");
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
        _builder.append("_Form_Plugin_RelationSelectorAutoComplete extends ");
        String _appName_1 = this._utils.appName(it);
        _builder.append(_appName_1, "");
        _builder.append("_Form_Plugin_Base_RelationSelectorAutoComplete");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("class RelationSelectorAutoComplete extends Base\\RelationSelectorAutoComplete");
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
  
  private CharSequence relationSelectorPluginImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* The ");
    String _appName = this._utils.appName(it);
    String _formatForDB = this._formattingExtensions.formatForDB(_appName);
    _builder.append(_formatForDB, " ");
    _builder.append("RelationSelectorAutoComplete plugin provides an autocompleter for related items.");
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
    _builder.append("RelationSelectorAutoComplete($params, $view)");
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
        _builder.append("_Form_Plugin_RelationSelectorAutoComplete");
      } else {
        _builder.append("\\\\");
        String _appNamespace = this._utils.appNamespace(it);
        _builder.append(_appNamespace, "    ");
        _builder.append("\\\\Form\\\\Plugin\\\\RelationSelectorAutoComplete");
      }
    }
    _builder.append("\', $params);");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
}
