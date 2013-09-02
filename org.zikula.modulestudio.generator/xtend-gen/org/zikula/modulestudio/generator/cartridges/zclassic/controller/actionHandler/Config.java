package org.zikula.modulestudio.generator.cartridges.zclassic.controller.actionHandler;

import com.google.inject.Inject;
import de.guite.modulestudio.metamodel.modulestudio.Application;
import de.guite.modulestudio.metamodel.modulestudio.ListVar;
import de.guite.modulestudio.metamodel.modulestudio.ListVarItem;
import de.guite.modulestudio.metamodel.modulestudio.Variable;
import java.util.Arrays;
import java.util.List;
import org.eclipse.emf.common.util.EList;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.eclipse.xtext.xbase.lib.StringExtensions;
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper;
import org.zikula.modulestudio.generator.extensions.ControllerExtensions;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class Config {
  @Inject
  @Extension
  private ControllerExtensions _controllerExtensions = new Function0<ControllerExtensions>() {
    public ControllerExtensions apply() {
      ControllerExtensions _controllerExtensions = new ControllerExtensions();
      return _controllerExtensions;
    }
  }.apply();
  
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
  
  /**
   * Entry point for config form handler.
   */
  public void generate(final Application it, final IFileSystemAccess fsa) {
    boolean _needsConfig = this._utils.needsConfig(it);
    if (_needsConfig) {
      String _appSourceLibPath = this._namingExtensions.getAppSourceLibPath(it);
      String _plus = (_appSourceLibPath + "Form/Handler/");
      String _configController = this._controllerExtensions.configController(it);
      String _firstUpper = StringExtensions.toFirstUpper(_configController);
      String _plus_1 = (_plus + _firstUpper);
      final String formHandlerFolder = (_plus_1 + "/");
      String _xifexpression = null;
      boolean _targets = this._utils.targets(it, "1.3.5");
      if (_targets) {
        _xifexpression = "";
      } else {
        _xifexpression = "Handler";
      }
      final String handlerSuffix = _xifexpression;
      String _plus_2 = (formHandlerFolder + "Base/Config");
      String _plus_3 = (_plus_2 + handlerSuffix);
      String _plus_4 = (_plus_3 + ".php");
      CharSequence _configHandlerBaseFile = this.configHandlerBaseFile(it);
      fsa.generateFile(_plus_4, _configHandlerBaseFile);
      String _plus_5 = (formHandlerFolder + "Config");
      String _plus_6 = (_plus_5 + handlerSuffix);
      String _plus_7 = (_plus_6 + ".php");
      CharSequence _configHandlerFile = this.configHandlerFile(it);
      fsa.generateFile(_plus_7, _configHandlerFile);
    }
  }
  
  private CharSequence configHandlerBaseFile(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _phpFileHeader = this.fh.phpFileHeader(it);
    _builder.append(_phpFileHeader, "");
    _builder.newLineIfNotEmpty();
    CharSequence _configHandlerBaseImpl = this.configHandlerBaseImpl(it);
    _builder.append(_configHandlerBaseImpl, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence configHandlerFile(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _phpFileHeader = this.fh.phpFileHeader(it);
    _builder.append(_phpFileHeader, "");
    _builder.newLineIfNotEmpty();
    CharSequence _configHandlerImpl = this.configHandlerImpl(it);
    _builder.append(_configHandlerImpl, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence configHandlerBaseImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _targets = this._utils.targets(it, "1.3.5");
      boolean _not = (!_targets);
      if (_not) {
        _builder.append("namespace ");
        String _appNamespace = this._utils.appNamespace(it);
        _builder.append(_appNamespace, "");
        _builder.append("\\Form\\Handler\\");
        String _configController = this._controllerExtensions.configController(it);
        String _firstUpper = StringExtensions.toFirstUpper(_configController);
        _builder.append(_firstUpper, "");
        _builder.append("\\Base;");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
        _builder.append("use LogUtil;");
        _builder.newLine();
        _builder.append("use ModUtil;");
        _builder.newLine();
        _builder.append("use SecurityUtil;");
        _builder.newLine();
        _builder.append("use Zikula_Form_AbstractHandler;");
        _builder.newLine();
        _builder.append("use Zikula_Form_View;");
        _builder.newLine();
        _builder.newLine();
      }
    }
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Configuration handler base class.");
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
        _builder.append("_Form_Handler_");
        String _configController_1 = this._controllerExtensions.configController(it);
        String _firstUpper_1 = StringExtensions.toFirstUpper(_configController_1);
        _builder.append(_firstUpper_1, "");
        _builder.append("_Base_Config");
      } else {
        _builder.append("ConfigHandler");
      }
    }
    _builder.append(" extends Zikula_Form_AbstractHandler");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* Post construction hook.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @return mixed");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("public function setup()");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* Initialize form handler.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* This method takes care of all necessary initialisation of our data and form states.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @param Zikula_Form_View $view The form view instance.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @return boolean False in case of initialization errors, otherwise true.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("public function initialize(Zikula_Form_View $view)");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// permission check");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if (!SecurityUtil::checkPermission($this->name . \'::\', \'::\', ACCESS_ADMIN)) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("return $view->registerError(LogUtil::registerPermissionError());");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// retrieve module vars");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$modVars = $this->getVars();");
    _builder.newLine();
    _builder.append("        ");
    {
      List<Variable> _allVariables = this._utils.getAllVariables(it);
      for(final Variable modvar : _allVariables) {
        CharSequence _init = this.init(modvar);
        _builder.append(_init, "        ");
      }
    }
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// assign all module vars");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$this->view->assign(\'config\', $modVars);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// custom initialisation aspects");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$this->initializeAdditions();");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// everything okay, no initialization errors occured");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return true;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* Method stub for own additions in subclasses.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("protected function initializeAdditions()");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* Pre-initialise hook.");
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
    _builder.append("public function preInitialize()");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* Post-initialise hook.");
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
    _builder.append("public function postInitialize()");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* Command event handler.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* This event handler is called when a command is issued by the user. Commands are typically something");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* that originates from a {@link Zikula_Form_Plugin_Button} plugin. The passed args contains different properties");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* depending on the command source, but you should at least find a <var>$args[\'commandName\']</var>");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* value indicating the name of the command. The command name is normally specified by the plugin");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* that initiated the command.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @param Zikula_Form_View $view The form view instance.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @param array            $args Additional arguments.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @see Zikula_Form_Plugin_Button");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @see Zikula_Form_Plugin_ImageButton");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @return mixed Redirect or false on errors.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("public function handleCommand(Zikula_Form_View $view, &$args)");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if ($args[\'commandName\'] == \'save\') {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("// check if all fields are valid");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("if (!$this->view->isValid()) {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("return false;");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("            ");
    _builder.append("// retrieve form data");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$data = $this->view->getValues();");
    _builder.newLine();
    _builder.newLine();
    _builder.append("            ");
    _builder.append("// update all module vars");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("if (!$this->setVars($data[\'config\'])) {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("return LogUtil::registerError($this->__(\'Error! Failed to set configuration variables.\'));");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("            ");
    _builder.append("LogUtil::registerStatus($this->__(\'Done! Module configuration updated.\'));");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("} else if ($args[\'commandName\'] == \'cancel\') {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("// nothing to do there");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// redirect back to the config page");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$url = ModUtil::url($this->name, \'");
    String _configController_2 = this._controllerExtensions.configController(it);
    String _formatForDB = this._formattingExtensions.formatForDB(_configController_2);
    _builder.append(_formatForDB, "        ");
    _builder.append("\', \'config\');");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return $this->view->redirect($url);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence _init(final Variable it) {
    return null;
  }
  
  private CharSequence _init(final ListVar it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("// initialise list entries for the \'");
    String _name = it.getName();
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(_name);
    _builder.append(_formatForDisplay, "");
    _builder.append("\' setting");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("$modVars[\'");
    String _name_1 = it.getName();
    String _formatForCode = this._formattingExtensions.formatForCode(_name_1);
    _builder.append(_formatForCode, "");
    _builder.append("Items\'] = array(");
    {
      EList<ListVarItem> _items = it.getItems();
      boolean _hasElements = false;
      for(final ListVarItem item : _items) {
        if (!_hasElements) {
          _hasElements = true;
        } else {
          _builder.appendImmediate(",", "");
        }
        CharSequence _itemDefinition = this.itemDefinition(item);
        _builder.append(_itemDefinition, "");
      }
    }
    _builder.newLineIfNotEmpty();
    _builder.append(");");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence itemDefinition(final ListVarItem it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("array(\'value\' => \'");
    String _name = it.getName();
    String _formatForCode = this._formattingExtensions.formatForCode(_name);
    _builder.append(_formatForCode, "");
    _builder.append("\', \'text\' => \'");
    String _name_1 = it.getName();
    String _formatForDisplayCapital = this._formattingExtensions.formatForDisplayCapital(_name_1);
    _builder.append(_formatForDisplayCapital, "");
    _builder.append("\')");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence configHandlerImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _targets = this._utils.targets(it, "1.3.5");
      boolean _not = (!_targets);
      if (_not) {
        _builder.append("namespace ");
        String _appNamespace = this._utils.appNamespace(it);
        _builder.append(_appNamespace, "");
        _builder.append("\\Form\\Handler\\");
        String _configController = this._controllerExtensions.configController(it);
        String _firstUpper = StringExtensions.toFirstUpper(_configController);
        _builder.append(_firstUpper, "");
        _builder.append(";");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
        _builder.append("use Base\\ConfigHandler as BaseConfigHandler;");
        _builder.newLine();
        _builder.newLine();
      }
    }
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Configuration handler implementation class.");
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
        _builder.append("_Form_Handler_");
        String _configController_1 = this._controllerExtensions.configController(it);
        String _firstUpper_1 = StringExtensions.toFirstUpper(_configController_1);
        _builder.append(_firstUpper_1, "");
        _builder.append("_Config extends ");
        String _appName_1 = this._utils.appName(it);
        _builder.append(_appName_1, "");
        _builder.append("_Form_Handler_");
        String _configController_2 = this._controllerExtensions.configController(it);
        String _firstUpper_2 = StringExtensions.toFirstUpper(_configController_2);
        _builder.append(_firstUpper_2, "");
        _builder.append("_Base_Config");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("class ConfigHandler extends BaseConfigHandler");
        _builder.newLine();
      }
    }
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// feel free to extend the base handler class here");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence init(final Variable it) {
    if (it instanceof ListVar) {
      return _init((ListVar)it);
    } else if (it != null) {
      return _init(it);
    } else {
      throw new IllegalArgumentException("Unhandled parameter types: " +
        Arrays.<Object>asList(it).toString());
    }
  }
}
