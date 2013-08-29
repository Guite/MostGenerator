package org.zikula.modulestudio.generator.cartridges.zclassic.controller.additions;

import com.google.inject.Inject;
import de.guite.modulestudio.metamodel.modulestudio.Application;
import de.guite.modulestudio.metamodel.modulestudio.Entity;
import de.guite.modulestudio.metamodel.modulestudio.UserController;
import org.eclipse.emf.common.util.EList;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Conversions;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper;
import org.zikula.modulestudio.generator.cartridges.zclassic.view.additions.NewsletterView;
import org.zikula.modulestudio.generator.extensions.ControllerExtensions;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class Newsletter {
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
    String _appSourceLibPath = this._namingExtensions.getAppSourceLibPath(it);
    final String pluginPath = (_appSourceLibPath + "NewsletterPlugin/");
    String _xifexpression = null;
    boolean _targets = this._utils.targets(it, "1.3.5");
    boolean _not = (!_targets);
    if (_not) {
      _xifexpression = "Plugin";
    } else {
      _xifexpression = "";
    }
    final String pluginClassSuffix = _xifexpression;
    String _plus = ("ItemList" + pluginClassSuffix);
    final String pluginFileName = (_plus + ".php");
    String _plus_1 = (pluginPath + pluginFileName);
    CharSequence _newsletterFile = this.newsletterFile(it);
    fsa.generateFile(_plus_1, _newsletterFile);
    NewsletterView _newsletterView = new NewsletterView();
    _newsletterView.generate(it, fsa);
  }
  
  private CharSequence newsletterFile(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _phpFileHeader = this.fh.phpFileHeader(it);
    _builder.append(_phpFileHeader, "");
    _builder.newLineIfNotEmpty();
    CharSequence _newsletterClass = this.newsletterClass(it);
    _builder.append(_newsletterClass, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence newsletterClass(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _targets = this._utils.targets(it, "1.3.5");
      boolean _not = (!_targets);
      if (_not) {
        _builder.append("namespace ");
        String _appNamespace = this._utils.appNamespace(it);
        _builder.append(_appNamespace, "");
        _builder.append("\\NewsletterPlugin;");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
        _builder.append("use DataUtil;");
        _builder.newLine();
        _builder.append("use ModUtil;");
        _builder.newLine();
        _builder.append("use SecurityUtil;");
        _builder.newLine();
        _builder.append("use ServiceUtil;");
        _builder.newLine();
      }
    }
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Newsletter plugin class.");
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
        _builder.append("_NewsletterPlugin_ItemList");
      } else {
        _builder.append("ItemListPlugin");
      }
    }
    _builder.append(" extends Newsletter_AbstractPlugin");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    CharSequence _newsletterImpl = this.newsletterImpl(it);
    _builder.append(_newsletterImpl, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence newsletterImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    Entity _leadingEntity = this._modelExtensions.getLeadingEntity(it);
    String _nameMultiple = _leadingEntity.getNameMultiple();
    final String itemDesc = this._formattingExtensions.formatForDisplay(_nameMultiple);
    _builder.newLineIfNotEmpty();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Returns a title being used in the newsletter. Should be short.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return string Title in newsletter.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function getTitle()");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $this->__(\'Latest ");
    {
      EList<Entity> _allEntities = this._modelExtensions.getAllEntities(it);
      int _length = ((Object[])Conversions.unwrapArray(_allEntities, Object.class)).length;
      boolean _lessThan = (_length < 2);
      if (_lessThan) {
        _builder.append(itemDesc, "    ");
      } else {
        String _appName = this._utils.appName(it);
        _builder.append(_appName, "    ");
        _builder.append(" items");
      }
    }
    _builder.append("\');");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Returns a display name for the admin interface.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return string Display name in admin area.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function getDisplayName()");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $this->__(\'List of ");
    _builder.append(itemDesc, "    ");
    {
      EList<Entity> _allEntities_1 = this._modelExtensions.getAllEntities(it);
      int _length_1 = ((Object[])Conversions.unwrapArray(_allEntities_1, Object.class)).length;
      boolean _greaterThan = (_length_1 > 1);
      if (_greaterThan) {
        _builder.append(" and other ");
        String _appName_1 = this._utils.appName(it);
        _builder.append(_appName_1, "    ");
        _builder.append(" items");
      }
    }
    _builder.append("\');");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Returns a description for the admin interface.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return string Description in admin area.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function getDescription()");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $this->__(\'This plugin shows a list of ");
    _builder.append(itemDesc, "    ");
    {
      EList<Entity> _allEntities_2 = this._modelExtensions.getAllEntities(it);
      int _length_2 = ((Object[])Conversions.unwrapArray(_allEntities_2, Object.class)).length;
      boolean _greaterThan_1 = (_length_2 > 1);
      if (_greaterThan_1) {
        _builder.append(" and other items");
      }
    }
    _builder.append(" of the ");
    String _appName_2 = this._utils.appName(it);
    _builder.append(_appName_2, "    ");
    _builder.append(" module.\');");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Determines whether this plugin is active or not.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* An inactive plugin is not shown in the newsletter.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return boolean Whether the plugin is available or not.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function pluginAvailable()");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return ModUtil::available($this->modname);");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Returns custom plugin variables.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return array List of variables.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function getParameters()");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$objectTypes = array();");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (ModUtil::available($this->modname) && ModUtil::loadApi($this->modname)) {");
    _builder.newLine();
    {
      EList<Entity> _allEntities_3 = this._modelExtensions.getAllEntities(it);
      for(final Entity entity : _allEntities_3) {
        _builder.append("        ");
        _builder.append("$objectTypes[\'");
        String _name = entity.getName();
        String _formatForCode = this._formattingExtensions.formatForCode(_name);
        _builder.append(_formatForCode, "        ");
        _builder.append("\'] = array(\'name\' => $this->__(\'");
        String _nameMultiple_1 = entity.getNameMultiple();
        String _formatForDisplayCapital = this._formattingExtensions.formatForDisplayCapital(_nameMultiple_1);
        _builder.append(_formatForDisplayCapital, "        ");
        _builder.append("\'));");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$active = $this->getPluginVar(\'ObjectTypes\', array());");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("foreach ($objectTypes as $k => $v) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$objectTypes[$k][\'nwactive\'] = in_array($k, $active);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$args = $this->getPluginVar(\'Args\', array());");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return array(\'number\' => 1,");
    _builder.newLine();
    _builder.append("                 ");
    _builder.append("\'param\'  => array(");
    _builder.newLine();
    _builder.append("                       ");
    _builder.append("\'ObjectTypes\'=> $objectTypes,");
    _builder.newLine();
    _builder.append("                       ");
    _builder.append("\'Args\' => $args));");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Sets custom plugin variables.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function setParameters()");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// Object types to be used in the newsletter");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$objectTypes = FormUtil::getPassedValue($this->modname . \'ObjectTypes\', array(), \'POST\');");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$this->setPluginVar(\'ObjectTypes\', array_keys($objectTypes));");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// Additional arguments");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$args = FormUtil::getPassedValue($this->modname . \'Args\', array(), \'POST\');");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$this->setPluginVar(\'Args\', $args);");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Returns data for the Newsletter plugin.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param datetime $filtAfterDate Optional date filter (items should be newer), format yyyy-mm-dd hh:mm:ss or null if not set");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return array List of affected content items.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function getPluginData($filtAfterDate = null)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!$this->pluginAvailable()) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return array();");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("ModUtil::initOOModule($this->modname);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// collect data for each activated object type");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$itemsGrouped = $this->getItemsPerObjectType();");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// now flatten for presentation");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$items = array();");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($itemsGrouped) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("foreach ($itemsGrouped as $objectTypes => $itemList) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("foreach ($itemList as $item) {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("$items[] = $item;");
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
    _builder.append("return $items;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Collects newsletter data for each activated object type.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return array Data grouped by object type.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected function getItemsPerObjectType()");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$objectTypes = $this->getPluginVar(\'ObjectTypes\', array());");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$args = $this->getPluginVar(\'Args\', array());");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$output = array();");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("foreach ($objectTypes as $objectType) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if (!SecurityUtil::checkPermission($this->modname . \':\' . ucwords($objectType) . \':\', \'::\', ACCESS_READ, $this->userNewsletter)) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("// the newsletter has no permission for these items");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("continue;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$otArgs = isset($args[$objectType]) ? $args[$objectType] : array();");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$otArgs[\'objectType\'] = $objectType;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// perform the data selection");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$output[$objectType] = $this->selectPluginData($otArgs, $filtAfterDate);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $output;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Performs the internal data selection.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param array    $args          Arguments array (contains object type).");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param datetime $filtAfterDate Optional date filter (items should be newer), format yyyy-mm-dd hh:mm:ss or null if not set");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return array List of selected items.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected function selectPluginData($args, $filtAfterDate = null)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$objectType = $args[\'objectType\'];");
    _builder.newLine();
    {
      boolean _targets = this._utils.targets(it, "1.3.5");
      if (_targets) {
        _builder.append("    ");
        _builder.append("$entityClass = \'");
        String _appName_3 = this._utils.appName(it);
        _builder.append(_appName_3, "    ");
        _builder.append("_Entity_\' . ucwords($objectType);");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("    ");
        _builder.append("$entityClass = \'\\\\");
        String _appNamespace = this._utils.appNamespace(it);
        _builder.append(_appNamespace, "    ");
        _builder.append("\\\\Entity\\\\\' . ucwords($objectType) . \'Entity\';");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("    ");
    _builder.append("$serviceManager = ServiceUtil::getManager();");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$entityManager = $serviceManager->getService(\'doctrine.entitymanager\');");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$repository = $entityManager->getRepository($entityClass);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$where = (isset($args[\'filter\']) ? $args[\'filter\'] : \'\');");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($filtAfterDate) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$startDateFieldName = $repository->getStartDateFieldName();");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if ($startDateFieldName == \'createdDate\') {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$where .= (!empty($where) ? \' AND \' : \'\') . \'tbl.createdDate > \' . DataUtil::formatForStore($filtAfterDate);");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// get objects from database");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$selectionArgs = array(");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'ot\' => $objectType,");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'where\' => $where,");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'orderBy\' => $this->getSortParam($args, $repository),");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'currentPage\' => 1,");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'resultsPerPage\' => isset($args[\'amount\']) && is_numeric($args[\'amount\']) ? $args[\'amount\'] : $this->nItems");
    _builder.newLine();
    _builder.append("    ");
    _builder.append(");");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("list($entities, $objectCount) = ModUtil::apiFunc($this->modname, \'selection\', \'getEntitiesPaginated\', $selectionArgs);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// post processing");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$titleFieldName = $repository->getTitleFieldName();");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$descriptionFieldName = $repository->getDescriptionFieldName();");
    _builder.newLine();
    {
      boolean _hasImageFields = this._modelExtensions.hasImageFields(it);
      if (_hasImageFields) {
        _builder.append("    ");
        _builder.append("$previewFieldName = $repository->getPreviewFieldName();");
        _builder.newLine();
      }
    }
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$items = array();");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("foreach ($entities as $k => $item) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$items[$k] = array();");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// Set title of this item.");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$items[$k][\'nl_title\'] = $titleFieldName ? $item[$titleFieldName] : \'\';");
    _builder.newLine();
    _builder.newLine();
    {
      boolean _and = false;
      boolean _hasUserController = this._controllerExtensions.hasUserController(it);
      if (!_hasUserController) {
        _and = false;
      } else {
        UserController _mainUserController = this._controllerExtensions.getMainUserController(it);
        boolean _hasActions = this._controllerExtensions.hasActions(_mainUserController, "display");
        _and = (_hasUserController && _hasActions);
      }
      if (_and) {
        _builder.append("        ");
        _builder.append("// Set (full qualified) link of title");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("$urlArgs = $item->createUrlArgs();");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("$urlArgs[\'lang\'] = $this->lang;");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("$items[$k][\'nl_url_title\'] = ModUtil::url($this->modname, \'user\', \'display\', $urlArgs, null, null, true);");
        _builder.newLine();
      } else {
        _builder.append("        ");
        _builder.append("$items[$k][\'nl_url_title\'] = null;");
        _builder.newLine();
      }
    }
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// Set main content of the item.");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$items[$k][\'nl_content\'] = $descriptionFieldName ? $item[$descriptionFieldName] : \'\';");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// Url for further reading. In this case it is the same as used for the title.");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$items[$k][\'nl_url_readmore\'] = $items[$k][\'nl_url_title\'];");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// A picture to display in Newsletter next to the item");
    _builder.newLine();
    {
      boolean _hasImageFields_1 = this._modelExtensions.hasImageFields(it);
      if (_hasImageFields_1) {
        _builder.append("        ");
        _builder.append("$items[$k][\'nl_picture\'] = $previewFieldName != \'\' ? $item[$previewFieldName . \'FullPath\'] : null;");
        _builder.newLine();
      } else {
        _builder.append("        ");
        _builder.append("$items[$k][\'nl_picture\'] = \'\';");
        _builder.newLine();
      }
    }
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $items;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Determines the order by parameter for item selection.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param array               $args       List of plugin variables.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param Doctrine_Repository $repository The repository used for data fetching.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return string the sorting clause.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected function getSortParam($args, $repository)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($args[\'sorting\'] == \'random\') {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return \'RAND()\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$sortParam = \'\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($args[\'sorting\'] == \'newest\') {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$idFields = ModUtil::apiFunc($this->modname, \'selection\', \'getIdFields\', array(\'ot\' => $args[\'objectType\']));");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if (count($idFields) == 1) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$sortParam = $idFields[0] . \' DESC\';");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("} else {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("foreach ($idFields as $idField) {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("if (!empty($sortParam)) {");
    _builder.newLine();
    _builder.append("                    ");
    _builder.append("$sortParam .= \', \';");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("$sortParam .= $idField . \' ASC\';");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("} elseif ($args[\'sorting\'] == \'default\') {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$sortParam = $repository->getDefaultSortingField() . \' ASC\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $sortParam;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
}
