package org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin.form;

import de.guite.modulestudio.metamodel.Application;
import de.guite.modulestudio.metamodel.Entity;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class ItemSelector {
  @Extension
  private FormattingExtensions _formattingExtensions = new FormattingExtensions();
  
  @Extension
  private ModelExtensions _modelExtensions = new ModelExtensions();
  
  @Extension
  private ModelBehaviourExtensions _modelBehaviourExtensions = new ModelBehaviourExtensions();
  
  @Extension
  private NamingExtensions _namingExtensions = new NamingExtensions();
  
  @Extension
  private Utils _utils = new Utils();
  
  private FileHelper fh = new FileHelper();
  
  public void generate(final Application it, final IFileSystemAccess fsa) {
    String _appSourceLibPath = this._namingExtensions.getAppSourceLibPath(it);
    String _plus = (_appSourceLibPath + "Form/Plugin/ItemSelector.php");
    this._namingExtensions.generateClassPair(it, fsa, _plus, 
      this.fh.phpFileContent(it, this.itemSelectorBaseImpl(it)), this.fh.phpFileContent(it, this.itemSelectorImpl(it)));
    boolean _shouldBeSkipped = this._namingExtensions.shouldBeSkipped(it, this._namingExtensions.viewPluginFilePath(it, "function", "ItemSelector"));
    boolean _not = (!_shouldBeSkipped);
    if (_not) {
      fsa.generateFile(this._namingExtensions.viewPluginFilePath(it, "function", "ItemSelector"), this.fh.phpFileContent(it, this.itemSelectorPluginImpl(it)));
    }
  }
  
  private CharSequence itemSelectorBaseImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("namespace ");
    String _appNamespace = this._utils.appNamespace(it);
    _builder.append(_appNamespace);
    _builder.append("\\Form\\Plugin\\Base;");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("use Symfony\\Component\\DependencyInjection\\ContainerAwareInterface;");
    _builder.newLine();
    _builder.append("use Symfony\\Component\\DependencyInjection\\ContainerAwareTrait;");
    _builder.newLine();
    _builder.append("use Zikula_Form_Plugin_TextInput;");
    _builder.newLine();
    _builder.append("use Zikula_Form_View;");
    _builder.newLine();
    _builder.append("use Zikula_View;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Item selector plugin base class.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("class AbstractItemSelector extends Zikula_Form_Plugin_TextInput implements ContainerAwareInterface");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("use ContainerAwareTrait;");
    _builder.newLine();
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
    _builder.append("* ItemSelector constructor.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("public function __construct()");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$this->setContainer(\\ServiceUtil::getManager());");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
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
    _builder.append("* @param Zikula_Form_View $view    Reference to Zikula_Form_View object");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @param array            &$params Parameters passed from the Smarty plugin function");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @see    Zikula_Form_AbstractPlugin");
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
    _builder.append("* @param Zikula_Form_View $view Reference to Zikula_Form_View object");
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
    _builder.append("$assetHelper = $this->container->get(\'zikula_core.common.theme.asset_helper\');");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$cssAssetBag = $this->container->get(\'zikula_core.common.theme.assets_css\');");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$jsAssetBag = $this->container->get(\'zikula_core.common.theme.assets_js\');");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$homePath = $this->container->get(\'request_stack\')->getCurrentRequest()->getBasePath();");
    _builder.newLine();
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$jsAssetBag->add($homePath . \'/web/magnific-popup/jquery.magnific-popup.min.js\');");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$cssAssetBag->add($homePath . \'/web/magnific-popup/magnific-popup.css\');");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$jsAssetBag->add($assetHelper->resolve(\'@");
    String _appName = this._utils.appName(it);
    _builder.append(_appName, "            ");
    _builder.append(":js/");
    String _appName_1 = this._utils.appName(it);
    _builder.append(_appName_1, "            ");
    _builder.append(".js\'));");
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    _builder.append("$jsAssetBag->add($assetHelper->resolve(\'@");
    String _appName_2 = this._utils.appName(it);
    _builder.append(_appName_2, "            ");
    _builder.append(":js/");
    String _appName_3 = this._utils.appName(it);
    _builder.append(_appName_3, "            ");
    _builder.append(".Finder.js\'));");
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    _builder.append("$cssAssetBag->add($assetHelper->resolve(\'@");
    String _appName_4 = this._utils.appName(it);
    _builder.append(_appName_4, "            ");
    _builder.append(":css/style.css\'));");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$firstTime = false;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$permissionApi = $this->container->get(\'zikula_permissions_module.api.permission\');");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if (!$permissionApi->hasPermission(\'");
    String _appName_5 = this._utils.appName(it);
    _builder.append(_appName_5, "        ");
    _builder.append(":\' . ucfirst($this->objectType) . \':\', \'::\', ACCESS_COMMENT)) {");
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
        _builder.append("$categorisableObjectTypes = [");
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
            String _formatForCode = this._formattingExtensions.formatForCode(entity.getName());
            _builder.append(_formatForCode, "        ");
            _builder.append("\'");
          }
        }
        _builder.append("];");
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        _builder.append("$catIds = [];");
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
        _builder.append("$categoryHelper = $this->container->get(\'");
        String _appService = this._utils.appService(it);
        _builder.append(_appService, "            ");
        _builder.append(".category_helper\');");
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("$catIds = $categoryHelper->retrieveCategoriesFromRequest($this->objectType);");
        _builder.newLine();
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
    _builder.append("        ");
    _builder.append("$repository = $this->container->get(\'");
    String _appService_1 = this._utils.appService(it);
    _builder.append(_appService_1, "        ");
    _builder.append(".entity_factory\')->getRepository($this->objectType);");
    _builder.newLineIfNotEmpty();
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
    String _appName_6 = this._utils.appName(it);
    _builder.append(_appName_6, "        ");
    _builder.append("\', false);");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("$view->assign(\'objectType\', $this->objectType)");
    _builder.newLine();
    _builder.append("             ");
    _builder.append("->assign(\'items\', $entities)");
    _builder.newLine();
    _builder.append("             ");
    _builder.append("->assign(\'sort\', $sort)");
    _builder.newLine();
    _builder.append("             ");
    _builder.append("->assign(\'sortdir\', $sdir)");
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
        _builder.append("$properties = $categoryHelper->getAllProperties($this->objectType);");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("}");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("$view->assign(\'properties\', $properties)");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("     ");
        _builder.append("->assign(\'catIds\', $catIds)");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("     ");
        _builder.append("->assign(\'categoryHelper\', $categoryHelper);");
        _builder.newLine();
      }
    }
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return $view->fetch(\'External/\' . ucfirst($this->objectType) . \'/select.tpl\');");
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
    _builder.append("* @param Zikula_Form_View $view Zikula_Form_View object");
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
    _builder.append("$request = $this->container->get(\'request_stack\')->getCurrentRequest();");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$this->objectType = $request->request->get(\'");
    String _appName_7 = this._utils.appName(it);
    _builder.append(_appName_7, "        ");
    _builder.append("_objecttype\', \'");
    String _formatForCode_1 = this._formattingExtensions.formatForCode(this._modelExtensions.getLeadingEntity(it).getName());
    _builder.append(_formatForCode_1, "        ");
    _builder.append("\');");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("$this->selectedItemId = $this->text = $request->request->get($this->inputName, 0);");
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
    _builder.append("namespace ");
    String _appNamespace = this._utils.appNamespace(it);
    _builder.append(_appNamespace);
    _builder.append("\\Form\\Plugin;");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("use ");
    String _appNamespace_1 = this._utils.appNamespace(it);
    _builder.append(_appNamespace_1);
    _builder.append("\\Form\\Plugin\\Base\\AbstractItemSelector;");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Item selector plugin implementation class.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("class ItemSelector extends AbstractItemSelector");
    _builder.newLine();
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
    String _formatForDB = this._formattingExtensions.formatForDB(this._utils.appName(it));
    _builder.append(_formatForDB, " ");
    _builder.append("ItemSelector plugin provides items for a dropdown selector.");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param  array            $params All attributes passed to this function from the template");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param  Zikula_Form_View $view   Reference to the view object");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return string The output of the plugin");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("function smarty_function_");
    String _formatForDB_1 = this._formattingExtensions.formatForDB(this._utils.appName(it));
    _builder.append(_formatForDB_1);
    _builder.append("ItemSelector($params, $view)");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $view->registerPlugin(\'\\\\");
    String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(it.getVendor());
    _builder.append(_formatForCodeCapital, "    ");
    _builder.append("\\\\");
    String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital_1, "    ");
    _builder.append("Module\\\\Form\\\\Plugin\\\\ItemSelector\', $params);");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
}
