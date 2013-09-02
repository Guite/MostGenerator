package org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.form;

import com.google.inject.Inject;
import de.guite.modulestudio.metamodel.modulestudio.Application;
import de.guite.modulestudio.metamodel.modulestudio.Entity;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class ItemSelector {
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
  private ModelBehaviourExtensions _modelBehaviourExtensions = new Function0<ModelBehaviourExtensions>() {
    public ModelBehaviourExtensions apply() {
      ModelBehaviourExtensions _modelBehaviourExtensions = new ModelBehaviourExtensions();
      return _modelBehaviourExtensions;
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
    String _plus = (formPluginPath + "Base/ItemSelector.php");
    CharSequence _itemSelectorBaseFile = this.itemSelectorBaseFile(it);
    fsa.generateFile(_plus, _itemSelectorBaseFile);
    String _plus_1 = (formPluginPath + "ItemSelector.php");
    CharSequence _itemSelectorFile = this.itemSelectorFile(it);
    fsa.generateFile(_plus_1, _itemSelectorFile);
    String _viewPluginFilePath = this._namingExtensions.viewPluginFilePath(it, "function", "ItemSelector");
    CharSequence _itemSelectorPluginFile = this.itemSelectorPluginFile(it);
    fsa.generateFile(_viewPluginFilePath, _itemSelectorPluginFile);
  }
  
  private CharSequence itemSelectorBaseFile(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _phpFileHeader = this.fh.phpFileHeader(it);
    _builder.append(_phpFileHeader, "");
    _builder.newLineIfNotEmpty();
    CharSequence _itemSelectorBaseImpl = this.itemSelectorBaseImpl(it);
    _builder.append(_itemSelectorBaseImpl, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence itemSelectorFile(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _phpFileHeader = this.fh.phpFileHeader(it);
    _builder.append(_phpFileHeader, "");
    _builder.newLineIfNotEmpty();
    CharSequence _itemSelectorImpl = this.itemSelectorImpl(it);
    _builder.append(_itemSelectorImpl, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence itemSelectorPluginFile(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _phpFileHeader = this.fh.phpFileHeader(it);
    _builder.append(_phpFileHeader, "");
    _builder.newLineIfNotEmpty();
    CharSequence _itemSelectorPluginImpl = this.itemSelectorPluginImpl(it);
    _builder.append(_itemSelectorPluginImpl, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence itemSelectorBaseImpl(final Application it) {
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
        _builder.append("use ModUtil;");
        _builder.newLine();
        _builder.append("use PageUtil;");
        _builder.newLine();
        _builder.append("use SecurityUtil;");
        _builder.newLine();
        _builder.append("use ServiceUtil;");
        _builder.newLine();
        _builder.append("use ThemeUtil;");
        _builder.newLine();
        _builder.append("use Zikula_Form_Plugin_TextInput;");
        _builder.newLine();
        _builder.append("use Zikula_Form_View;");
        _builder.newLine();
        _builder.append("use Zikula_View;");
        _builder.newLine();
        _builder.newLine();
      }
    }
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Item selector plugin base class.");
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
    _builder.append("ItemSelector extends Zikula_Form_Plugin_TextInput");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* The treated object type.");
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
    _builder.append("public $objectType = \'\';");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* Identifier of selected object.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @var integer");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("public $selectedItemId = 0;");
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
    _builder.append("/*$params[\'width\'] = \'8em\';*/");
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
    _builder.append("* @see    Zikula_Form_Plugin_TextInput");
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
    _builder.append("return str_replace(\'z-form-text\', \'z-form-itemlist \' . strtolower($this->objectType), $class);");
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
    _builder.append("static $firstTime = true;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if ($firstTime) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("PageUtil::addVar(\'javascript\', \'prototype\');");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("PageUtil::addVar(\'javascript\', \'Zikula.UI\'); // imageviewer");
    _builder.newLine();
    {
      boolean _targets_2 = this._utils.targets(it, "1.3.5");
      if (_targets_2) {
        _builder.append("            ");
        _builder.append("PageUtil::addVar(\'javascript\', \'modules/");
        String _appName_1 = this._utils.appName(it);
        _builder.append(_appName_1, "            ");
        _builder.append("/javascript/");
        String _appName_2 = this._utils.appName(it);
        _builder.append(_appName_2, "            ");
        _builder.append("_finder.js\');");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("            ");
        _builder.append("PageUtil::addVar(\'javascript\', \'");
        String _appJsPath = this._namingExtensions.getAppJsPath(it);
        _builder.append(_appJsPath, "            ");
        String _appName_3 = this._utils.appName(it);
        _builder.append(_appName_3, "            ");
        _builder.append("_finder.js\');");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("            ");
    _builder.append("PageUtil::addVar(\'stylesheet\', ThemeUtil::getModuleStylesheet(\'");
    String _appName_4 = this._utils.appName(it);
    _builder.append(_appName_4, "            ");
    _builder.append("\'));");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$firstTime = false;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if (!SecurityUtil::checkPermission(\'");
    String _appName_5 = this._utils.appName(it);
    _builder.append(_appName_5, "        ");
    _builder.append(":\' . ucwords($this->objectType) . \':\', \'::\', ACCESS_COMMENT)) {");
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    _builder.append("return false;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    {
      boolean _hasCategorisableEntities = this._modelBehaviourExtensions.hasCategorisableEntities(it);
      if (_hasCategorisableEntities) {
        _builder.newLine();
        _builder.append("        ");
        _builder.append("$categorisableObjectTypes = array(");
        {
          Iterable<Entity> _categorisableEntities = this._modelBehaviourExtensions.getCategorisableEntities(it);
          boolean _hasElements = false;
          for(final Entity entity : _categorisableEntities) {
            if (!_hasElements) {
              _hasElements = true;
            } else {
              _builder.appendImmediate(", ", "        ");
            }
            _builder.append("\'");
            String _name = entity.getName();
            String _formatForCode = this._formattingExtensions.formatForCode(_name);
            _builder.append(_formatForCode, "        ");
            _builder.append("\'");
          }
        }
        _builder.append(");");
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        _builder.append("$catIds = array();");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("if (in_array($this->objectType, $categorisableObjectTypes)) {");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("// fetch selected categories to reselect them in the output");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("// the actual filtering is done inside the repository class");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("$catIds = ModUtil::apiFunc(\'");
        String _appName_6 = this._utils.appName(it);
        _builder.append(_appName_6, "            ");
        _builder.append("\', \'category\', \'retrieveCategoriesFromRequest\', array(\'ot\' => $this->objectType));");
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        _builder.append("}");
        _builder.newLine();
      }
    }
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$this->selectedItemId = $this->text;");
    _builder.newLine();
    _builder.newLine();
    {
      boolean _targets_3 = this._utils.targets(it, "1.3.5");
      if (_targets_3) {
        _builder.append("        ");
        _builder.append("$entityClass = \'");
        String _appName_7 = this._utils.appName(it);
        _builder.append(_appName_7, "        ");
        _builder.append("_Entity_\' . ucwords($this->objectType);");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("        ");
        _builder.append("$entityClass = \'\\\\");
        String _vendor = it.getVendor();
        String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(_vendor);
        _builder.append(_formatForCodeCapital, "        ");
        _builder.append("\\\\");
        String _name_1 = it.getName();
        String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(_name_1);
        _builder.append(_formatForCodeCapital_1, "        ");
        _builder.append("Module\\\\Entity\\\\\' . ucwords($this->objectType) . \'Entity\';");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("        ");
    _builder.append("$serviceManager = ServiceUtil::getManager();");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$entityManager = $serviceManager->getService(\'doctrine.entitymanager\');");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$repository = $entityManager->getRepository($entityClass);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$sort = $repository->getDefaultSortingField();");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$sdir = \'asc\';");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// convenience vars to make code clearer");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$where = \'\';");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$sortParam = $sort . \' \' . $sdir;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$entities = $repository->selectWhere($where, $sortParam);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$view = Zikula_View::getInstance(\'");
    String _appName_8 = this._utils.appName(it);
    _builder.append(_appName_8, "        ");
    _builder.append("\', false);");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("$view->assign(\'objectType\', $this->objectType)");
    _builder.newLine();
    _builder.append("             ");
    _builder.append("->assign(\'items\', $entities)");
    _builder.newLine();
    _builder.append("             ");
    _builder.append("->assign(\'selectedId\', $this->selectedItemId);");
    _builder.newLine();
    {
      boolean _hasCategorisableEntities_1 = this._modelBehaviourExtensions.hasCategorisableEntities(it);
      if (_hasCategorisableEntities_1) {
        _builder.newLine();
        _builder.append("        ");
        _builder.append("// assign category properties");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("$properties = null;");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("if (in_array($this->objectType, $categorisableObjectTypes)) {");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("$properties = ModUtil::apiFunc(\'");
        String _appName_9 = this._utils.appName(it);
        _builder.append(_appName_9, "            ");
        _builder.append("\', \'category\', \'getAllProperties\', array(\'ot\' => $this->objectType));");
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        _builder.append("}");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("$view->assign(\'properties\', $properties)");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("     ");
        _builder.append("->assign(\'catIds\', $catIds);");
        _builder.newLine();
      }
    }
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return $view->fetch(");
    {
      boolean _targets_4 = this._utils.targets(it, "1.3.5");
      if (_targets_4) {
        _builder.append("\'external/\' . $this->objectType");
      } else {
        _builder.append("\'External/\' . ucwords($this->objectType)");
      }
    }
    _builder.append(" . \'/select.tpl\');");
    _builder.newLineIfNotEmpty();
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
    _builder.append("* @param Zikula_Form_View $view Zikula_Form_View object.");
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
    _builder.append("        ");
    _builder.append("$this->objectType = FormUtil::getPassedValue(\'");
    String _appName_10 = this._utils.appName(it);
    _builder.append(_appName_10, "        ");
    _builder.append("_objecttype\', \'");
    Entity _leadingEntity = this._modelExtensions.getLeadingEntity(it);
    String _name_2 = _leadingEntity.getName();
    String _formatForCode_1 = this._formattingExtensions.formatForCode(_name_2);
    _builder.append(_formatForCode_1, "        ");
    _builder.append("\', \'POST\');");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("$this->selectedItemId = $this->text;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence itemSelectorImpl(final Application it) {
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
    _builder.append("* Item selector plugin implementation class.");
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
        _builder.append("_Form_Plugin_ItemSelector extends ");
        String _appName_1 = this._utils.appName(it);
        _builder.append(_appName_1, "");
        _builder.append("_Form_Plugin_Base_ItemSelector");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("class ItemSelector extends Base\\ItemSelector");
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
  
  private CharSequence itemSelectorPluginImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* The ");
    String _appName = this._utils.appName(it);
    String _formatForDB = this._formattingExtensions.formatForDB(_appName);
    _builder.append(_formatForDB, " ");
    _builder.append("ItemSelector plugin provides items for a dropdown selector.");
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
    _builder.append("ItemSelector($params, $view)");
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
        _builder.append("_Form_Plugin_ItemSelector");
      } else {
        _builder.append("\\\\");
        String _vendor = it.getVendor();
        String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(_vendor);
        _builder.append(_formatForCodeCapital, "    ");
        _builder.append("\\\\");
        String _name = it.getName();
        String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(_name);
        _builder.append(_formatForCodeCapital_1, "    ");
        _builder.append("Module\\\\Form\\\\Plugin\\\\ItemSelector");
      }
    }
    _builder.append("\', $params);");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
}
