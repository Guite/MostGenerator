package org.zikula.modulestudio.generator.cartridges.zclassic.controller.apis;

import com.google.inject.Inject;
import de.guite.modulestudio.metamodel.modulestudio.Application;
import de.guite.modulestudio.metamodel.modulestudio.Entity;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.eclipse.xtext.xbase.lib.InputOutput;
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper;
import org.zikula.modulestudio.generator.cartridges.zclassic.view.additions.ContentTypeSingleView;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class ContentTypeSingle {
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
  
  private FileHelper fh = new Function0<FileHelper>() {
    public FileHelper apply() {
      FileHelper _fileHelper = new FileHelper();
      return _fileHelper;
    }
  }.apply();
  
  public void generate(final Application it, final IFileSystemAccess fsa) {
    InputOutput.<String>println("Generating content type for single objects");
    String _appSourceLibPath = this._namingExtensions.getAppSourceLibPath(it);
    final String contentTypePath = (_appSourceLibPath + "ContentType/");
    String _plus = (contentTypePath + "Base/Item.php");
    CharSequence _contentTypeBaseFile = this.contentTypeBaseFile(it);
    fsa.generateFile(_plus, _contentTypeBaseFile);
    String _plus_1 = (contentTypePath + "Item.php");
    CharSequence _contentTypeFile = this.contentTypeFile(it);
    fsa.generateFile(_plus_1, _contentTypeFile);
    ContentTypeSingleView _contentTypeSingleView = new ContentTypeSingleView();
    _contentTypeSingleView.generate(it, fsa);
  }
  
  private CharSequence contentTypeBaseFile(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _phpFileHeader = this.fh.phpFileHeader(it);
    _builder.append(_phpFileHeader, "");
    _builder.newLineIfNotEmpty();
    CharSequence _contentTypeBaseClass = this.contentTypeBaseClass(it);
    _builder.append(_contentTypeBaseClass, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence contentTypeFile(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _phpFileHeader = this.fh.phpFileHeader(it);
    _builder.append(_phpFileHeader, "");
    _builder.newLineIfNotEmpty();
    CharSequence _contentTypeImpl = this.contentTypeImpl(it);
    _builder.append(_contentTypeImpl, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence contentTypeBaseClass(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _targets = this._utils.targets(it, "1.3.5");
      boolean _not = (!_targets);
      if (_not) {
        _builder.append("namespace ");
        String _appName = this._utils.appName(it);
        _builder.append(_appName, "");
        _builder.append("\\ContentType\\Base;");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
        _builder.append("use ");
        String _appName_1 = this._utils.appName(it);
        _builder.append(_appName_1, "");
        _builder.append("\\Util\\ControllerUtil;");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
        _builder.append("use ModUtil;");
        _builder.newLine();
        _builder.append("use ServiceUtil;");
        _builder.newLine();
        _builder.append("use ZLanguage;");
        _builder.newLine();
        _builder.newLine();
      }
    }
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Generic single item display content plugin base class.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    {
      boolean _targets_1 = this._utils.targets(it, "1.3.5");
      if (_targets_1) {
        _builder.append("class ");
        String _appName_2 = this._utils.appName(it);
        _builder.append(_appName_2, "");
        _builder.append("_ContentType_Base_Item extends Content_AbstractContentType");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("class Item extends \\Content_AbstractContentType");
        _builder.newLine();
      }
    }
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    CharSequence _contentTypeBaseImpl = this.contentTypeBaseImpl(it);
    _builder.append(_contentTypeBaseImpl, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence contentTypeBaseImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("protected $objectType;");
    _builder.newLine();
    _builder.append("protected $id;");
    _builder.newLine();
    _builder.append("protected $displayMode;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Returns the module providing this content type.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return string The module name.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function getModule()");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return \'");
    String _appName = this._utils.appName(it);
    _builder.append(_appName, "    ");
    _builder.append("\';");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Returns the name of this content type.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return string The content type name.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function getName()");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return \'Item\';");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Returns the title of this content type.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return string The content type title.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function getTitle()");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$dom = ZLanguage::getModuleDomain(\'");
    String _appName_1 = this._utils.appName(it);
    _builder.append(_appName_1, "    ");
    _builder.append("\');");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return __(\'");
    String _appName_2 = this._utils.appName(it);
    _builder.append(_appName_2, "    ");
    _builder.append(" detail view\', $dom);");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Returns the description of this content type.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return string The content type description.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function getDescription()");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$dom = ZLanguage::getModuleDomain(\'");
    String _appName_3 = this._utils.appName(it);
    _builder.append(_appName_3, "    ");
    _builder.append("\');");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return __(\'Display or link a single ");
    String _appName_4 = this._utils.appName(it);
    _builder.append(_appName_4, "    ");
    _builder.append(" object.\', $dom);");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Loads the data.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param array $data Data array with parameters.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function loadData(&$data)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$serviceManager = ServiceUtil::getManager();");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$controllerHelper = new ");
    {
      boolean _targets = this._utils.targets(it, "1.3.5");
      if (_targets) {
        String _appName_5 = this._utils.appName(it);
        _builder.append(_appName_5, "    ");
        _builder.append("_Util_Controller");
      } else {
        _builder.append("ControllerUtil");
      }
    }
    _builder.append("($serviceManager);");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$utilArgs = array(\'name\' => \'detail\');");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!isset($data[\'objectType\']) || !in_array($data[\'objectType\'], $controllerHelper->getObjectTypes(\'contentType\', $utilArgs))) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$data[\'objectType\'] = $controllerHelper->getDefaultObjectType(\'contentType\', $utilArgs);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$this->objectType = $data[\'objectType\'];");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!isset($data[\'id\'])) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$data[\'id\'] = null;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!isset($data[\'displayMode\'])) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$data[\'displayMode\'] = \'embed\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$this->id = $data[\'id\'];");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$this->displayMode = $data[\'displayMode\'];");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Displays the data.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return string The returned output.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function display()");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($this->id != null && !empty($this->displayMode)) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return ModUtil::func(\'");
    String _appName_6 = this._utils.appName(it);
    _builder.append(_appName_6, "        ");
    _builder.append("\', \'external\', \'display\', $this->getDisplayArguments());");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return \'\';");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Displays the data for editing.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function displayEditing()");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($this->id != null && !empty($this->displayMode)) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return ModUtil::func(\'");
    String _appName_7 = this._utils.appName(it);
    _builder.append(_appName_7, "        ");
    _builder.append("\', \'external\', \'display\', $this->getDisplayArguments());");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$dom = ZLanguage::getModuleDomain(\'");
    String _appName_8 = this._utils.appName(it);
    _builder.append(_appName_8, "    ");
    _builder.append("\');");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return __(\'No item selected.\', $dom);");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Returns common arguments for display data selection with the external api.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return array Display arguments.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected function getDisplayArguments()");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return array(\'objectType\' => $this->objectType,");
    _builder.newLine();
    _builder.append("                 ");
    _builder.append("\'source\' => \'contentType\',");
    _builder.newLine();
    _builder.append("                 ");
    _builder.append("\'displayMode\' => $this->displayMode,");
    _builder.newLine();
    _builder.append("                 ");
    _builder.append("\'id\' => $this->id");
    _builder.newLine();
    _builder.append("    ");
    _builder.append(");");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Returns the default data.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return array Default data and parameters.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function getDefaultData()");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return array(\'objectType\' => \'");
    Entity _leadingEntity = this._modelExtensions.getLeadingEntity(it);
    String _name = _leadingEntity.getName();
    String _formatForCode = this._formattingExtensions.formatForCode(_name);
    _builder.append(_formatForCode, "    ");
    _builder.append("\',");
    _builder.newLineIfNotEmpty();
    _builder.append("                 ");
    _builder.append("\'id\' => null,");
    _builder.newLine();
    _builder.append("                 ");
    _builder.append("\'displayMode\' => \'embed\');");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Executes additional actions for the editing mode.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function startEditing()");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// ensure our custom plugins are loaded");
    _builder.newLine();
    {
      boolean _targets_1 = this._utils.targets(it, "1.3.5");
      if (_targets_1) {
        _builder.append("    ");
        _builder.append("array_push($this->view->plugins_dir, \'modules/");
        String _appName_9 = this._utils.appName(it);
        _builder.append(_appName_9, "    ");
        _builder.append("/templates/plugins\');");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("    ");
        _builder.append("array_push($this->view->plugins_dir, \'modules/");
        String _appName_10 = this._utils.appName(it);
        _builder.append(_appName_10, "    ");
        _builder.append("/Resources/views/plugins\');");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// required as parameter for the item selector plugin");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$this->view->assign(\'objectType\', $this->objectType);");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence contentTypeImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _targets = this._utils.targets(it, "1.3.5");
      boolean _not = (!_targets);
      if (_not) {
        _builder.append("namespace ");
        String _appName = this._utils.appName(it);
        _builder.append(_appName, "");
        _builder.append("\\ContentType;");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
      }
    }
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Generic single item display content plugin implementation class.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    {
      boolean _targets_1 = this._utils.targets(it, "1.3.5");
      if (_targets_1) {
        _builder.append("class ");
        String _appName_1 = this._utils.appName(it);
        _builder.append(_appName_1, "");
        _builder.append("_ContentType_Item extends ");
        String _appName_2 = this._utils.appName(it);
        _builder.append(_appName_2, "");
        _builder.append("_ContentType_Base_Item");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("class Item extends Base\\Item");
        _builder.newLine();
      }
    }
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// feel free to extend the content type here");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("function ");
    String _appName_3 = this._utils.appName(it);
    _builder.append(_appName_3, "");
    _builder.append("_Api_ContentTypes_item($args)");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return new ");
    String _appName_4 = this._utils.appName(it);
    _builder.append(_appName_4, "    ");
    _builder.append("_Api_ContentTypes_itemPlugin();");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
}
