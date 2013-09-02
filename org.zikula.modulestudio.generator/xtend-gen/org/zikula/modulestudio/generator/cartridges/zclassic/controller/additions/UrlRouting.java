package org.zikula.modulestudio.generator.cartridges.zclassic.controller.additions;

import com.google.inject.Inject;
import de.guite.modulestudio.metamodel.modulestudio.Application;
import de.guite.modulestudio.metamodel.modulestudio.Entity;
import de.guite.modulestudio.metamodel.modulestudio.Models;
import de.guite.modulestudio.metamodel.modulestudio.UserController;
import org.eclipse.emf.common.util.EList;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.eclipse.xtext.xbase.lib.InputOutput;
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper;
import org.zikula.modulestudio.generator.extensions.ControllerExtensions;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class UrlRouting {
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
  
  /**
   * Start point for the router creation.
   */
  public void generate(final Application it, final IFileSystemAccess fsa) {
    InputOutput.<String>println("Generating router facade for short url resolution");
    String _appSourceLibPath = this._namingExtensions.getAppSourceLibPath(it);
    String _plus = (_appSourceLibPath + "Base/RouterFacade.php");
    CharSequence _routerFacadeBaseFile = this.routerFacadeBaseFile(it);
    fsa.generateFile(_plus, _routerFacadeBaseFile);
    String _appSourceLibPath_1 = this._namingExtensions.getAppSourceLibPath(it);
    String _plus_1 = (_appSourceLibPath_1 + "RouterFacade.php");
    CharSequence _routerFacadeFile = this.routerFacadeFile(it);
    fsa.generateFile(_plus_1, _routerFacadeFile);
  }
  
  private CharSequence routerFacadeBaseFile(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _phpFileHeader = this.fh.phpFileHeader(it);
    _builder.append(_phpFileHeader, "");
    _builder.newLineIfNotEmpty();
    CharSequence _routerFacadeBaseImpl = this.routerFacadeBaseImpl(it);
    _builder.append(_routerFacadeBaseImpl, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence routerFacadeFile(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _phpFileHeader = this.fh.phpFileHeader(it);
    _builder.append(_phpFileHeader, "");
    _builder.newLineIfNotEmpty();
    CharSequence _routerFacadeImpl = this.routerFacadeImpl(it);
    _builder.append(_routerFacadeImpl, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence routerFacadeBaseImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _targets = this._utils.targets(it, "1.3.5");
      boolean _not = (!_targets);
      if (_not) {
        _builder.append("namespace ");
        String _appNamespace = this._utils.appNamespace(it);
        _builder.append(_appNamespace, "");
        _builder.append("\\Base;");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
        _builder.append("use ModUtil;");
        _builder.newLine();
        _builder.append("use System;");
        _builder.newLine();
        _builder.append("use Zikula\\Routing\\UrlRoute;");
        _builder.newLine();
        _builder.append("use Zikula\\Routing\\UrlRouter;");
        _builder.newLine();
        _builder.newLine();
      }
    }
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Url router facade base class");
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
        _builder.append("_Base_RouterFacade");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("class RouterFacade");
        _builder.newLine();
      }
    }
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @var ");
    {
      boolean _targets_2 = this._utils.targets(it, "1.3.5");
      if (_targets_2) {
        _builder.append("Zikula_Routing_");
      }
    }
    _builder.append("UrlRouter The router which is used internally");
    _builder.newLineIfNotEmpty();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("protected $router;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @var array Common requirement definitions");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("protected $requirements;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* Constructor.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("function __construct()");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$displayDefaultEnding = System::getVar(\'shorturlsext\', \'html\');");
    _builder.newLine();
    _builder.append("        ");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$this->requirements = array(");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("\'func\'          => \'\\w+\',");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("\'ot\'            => \'\\w+\',");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("\'slug\'          => \'[^/.]+\', // slugs ([^/.]+ = all chars except / and .)");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("\'displayending\' => \'(?:\' . $displayDefaultEnding . \'|xml|pdf|json|kml)\',");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("\'viewending\'    => \'(?:\\.csv|\\.rss|\\.atom|\\.xml|\\.pdf|\\.json|\\.kml)?\',");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("\'id\'            => \'\\d+\'");
    _builder.newLine();
    _builder.append("        ");
    _builder.append(");");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// initialise and reference router instance");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$this->router = new ");
    {
      boolean _targets_3 = this._utils.targets(it, "1.3.5");
      if (_targets_3) {
        _builder.append("Zikula_Routing_");
      }
    }
    _builder.append("UrlRouter();");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// add generic routes");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return $this->initUrlRoutes();");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    CharSequence _initUrlRoutes = this.initUrlRoutes(it);
    _builder.append(_initUrlRoutes, "    ");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    CharSequence _groupingFolderFromObjectType = this.getGroupingFolderFromObjectType(it);
    _builder.append(_groupingFolderFromObjectType, "    ");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    CharSequence _objectTypeFromGroupingFolder = this.getObjectTypeFromGroupingFolder(it);
    _builder.append(_objectTypeFromGroupingFolder, "    ");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    CharSequence _formattedSlug = this.getFormattedSlug(it);
    _builder.append(_formattedSlug, "    ");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    {
      boolean _targets_4 = this._utils.targets(it, "1.3.5");
      if (_targets_4) {
        _builder.append("    ");
        CharSequence _terAndSetterMethods = this.fh.getterAndSetterMethods(it, "router", "Zikula_Routing_UrlRouter", Boolean.valueOf(false), Boolean.valueOf(true), "null", "");
        _builder.append(_terAndSetterMethods, "    ");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("    ");
        CharSequence _terAndSetterMethods_1 = this.fh.getterAndSetterMethods(it, "router", "\\Zikula\\Routing\\UrlRouter", Boolean.valueOf(false), Boolean.valueOf(true), "null", "");
        _builder.append(_terAndSetterMethods_1, "    ");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence initUrlRoutes(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    final UserController userController = this._controllerExtensions.getMainUserController(it);
    _builder.newLineIfNotEmpty();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Initialise the url routes for this application.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return ");
    {
      boolean _targets = this._utils.targets(it, "1.3.5");
      if (_targets) {
        _builder.append("Zikula_Routing_UrlRouter");
      }
    }
    _builder.append("UrlRouter The router instance treating all initialised routes");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected function initUrlRoutes()");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$fieldRequirements = $this->requirements;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$isDefaultModule = (System::getVar(\'shorturlsdefaultmodule\', \'\') == \'");
    String _appName = this._utils.appName(it);
    _builder.append(_appName, "    ");
    _builder.append("\');");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$defaults = array();");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$modulePrefix = \'\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!$isDefaultModule) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$defaults[\'module\'] = \'");
    String _appName_1 = this._utils.appName(it);
    _builder.append(_appName_1, "        ");
    _builder.append("\';");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("$modulePrefix = \':module/\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    {
      boolean _hasActions = this._controllerExtensions.hasActions(userController, "view");
      if (_hasActions) {
        _builder.append("    ");
        _builder.append("$defaults[\'func\'] = \'view\';");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$viewFolder = \'view\';");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("// normal views (e.g. orders/ or customers.xml)");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$this->router->set(\'va\', new ");
        {
          boolean _targets_1 = this._utils.targets(it, "1.3.5");
          if (_targets_1) {
            _builder.append("Zikula_Routing_");
          }
        }
        _builder.append("UrlRoute($modulePrefix . $viewFolder . \'/:ot:viewending\', $defaults, $fieldRequirements));");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("// TODO filter views (e.g. /orders/customer/mr-smith.csv)");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("// $this->initRouteForEachSlugType(\'vn\', $modulePrefix . $viewFolder . \'/:ot/:filterot/\', \':viewending\', $defaults, $fieldRequirements);");
        _builder.newLine();
      }
    }
    _builder.newLine();
    {
      boolean _hasActions_1 = this._controllerExtensions.hasActions(userController, "display");
      if (_hasActions_1) {
        _builder.append("    ");
        _builder.append("$defaults[\'func\'] = \'display\';");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("// normal display pages including the group folder corresponding to the object type");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$this->initRouteForEachSlugType(\'dn\', $modulePrefix . \':ot/\', \':displayending\', $defaults, $fieldRequirements);");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("// additional rules for the leading object type (where ot is omitted)");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$defaults[\'ot\'] = \'");
        Entity _leadingEntity = this._modelExtensions.getLeadingEntity(it);
        String _name = _leadingEntity.getName();
        String _formatForCode = this._formattingExtensions.formatForCode(_name);
        _builder.append(_formatForCode, "    ");
        _builder.append("\';");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("$this->initRouteForEachSlugType(\'dl\', $modulePrefix . \'\', \':displayending\', $defaults, $fieldRequirements);");
        _builder.newLine();
      }
    }
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $this->router;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Helper function to route permalinks for different slug types.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $prefix");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $patternStart");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $patternEnd");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $defaults");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $fieldRequirements");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected function initRouteForEachSlugType($prefix, $patternStart, $patternEnd, $defaults, $fieldRequirements)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// entities with unique slug (slug only)");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$this->router->set($prefix . \'a\', new ");
    {
      boolean _targets_2 = this._utils.targets(it, "1.3.5");
      if (_targets_2) {
        _builder.append("Zikula_Routing_");
      }
    }
    _builder.append("UrlRoute($patternStart . \':slug.\' . $patternEnd,        $defaults, $fieldRequirements));");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("// entities with non-unique slug (slug and id)");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$this->router->set($prefix . \'b\', new ");
    {
      boolean _targets_3 = this._utils.targets(it, "1.3.5");
      if (_targets_3) {
        _builder.append("Zikula_Routing_");
      }
    }
    _builder.append("UrlRoute($patternStart . \':slug.:id.\' . $patternEnd,    $defaults, $fieldRequirements));");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("// entities without slug (id)");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$this->router->set($prefix . \'c\', new ");
    {
      boolean _targets_4 = this._utils.targets(it, "1.3.5");
      if (_targets_4) {
        _builder.append("Zikula_Routing_");
      }
    }
    _builder.append("UrlRoute($patternStart . \'id.:id.\' . $patternEnd,        $defaults, $fieldRequirements));");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence getGroupingFolderFromObjectType(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Get name of grouping folder for given object type and function.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $objectType Name of treated entity type.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $func       Name of function.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return string Name of the group folder");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function getGroupingFolderFromObjectType($objectType, $func)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// object type will be used as a fallback");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$groupFolder = $objectType;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($func == \'view\') {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("switch ($objectType) {");
    _builder.newLine();
    _builder.append("            ");
    {
      EList<Entity> _allEntities = this._modelExtensions.getAllEntities(it);
      for(final Entity entity : _allEntities) {
        CharSequence _groupingFolderFromObjectType = this.getGroupingFolderFromObjectType(entity, Boolean.valueOf(true));
        _builder.append(_groupingFolderFromObjectType, "            ");
      }
    }
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    _builder.append("default: return \'\';");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("} else if ($func == \'display\') {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("switch ($objectType) {");
    _builder.newLine();
    _builder.append("            ");
    {
      EList<Entity> _allEntities_1 = this._modelExtensions.getAllEntities(it);
      for(final Entity entity_1 : _allEntities_1) {
        CharSequence _groupingFolderFromObjectType_1 = this.getGroupingFolderFromObjectType(entity_1, Boolean.valueOf(false));
        _builder.append(_groupingFolderFromObjectType_1, "            ");
      }
    }
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    _builder.append("default: return \'\';");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $groupFolder;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence getObjectTypeFromGroupingFolder(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Get name of object type based on given grouping folder.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $groupFolder Name of group folder.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $func        Name of function.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return string Name of the object type.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function getObjectTypeFromGroupingFolder($groupFolder, $func)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// group folder will be used as a fallback");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$objectType = $groupFolder;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($func == \'view\') {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("switch ($groupFolder) {");
    _builder.newLine();
    _builder.append("            ");
    {
      EList<Entity> _allEntities = this._modelExtensions.getAllEntities(it);
      for(final Entity entity : _allEntities) {
        CharSequence _objectTypeFromGroupingFolder = this.getObjectTypeFromGroupingFolder(entity, Boolean.valueOf(true));
        _builder.append(_objectTypeFromGroupingFolder, "            ");
      }
    }
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    _builder.append("default: return \'\';");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("} else if ($func == \'display\') {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("switch ($groupFolder) {");
    _builder.newLine();
    _builder.append("            ");
    {
      EList<Entity> _allEntities_1 = this._modelExtensions.getAllEntities(it);
      for(final Entity entity_1 : _allEntities_1) {
        CharSequence _objectTypeFromGroupingFolder_1 = this.getObjectTypeFromGroupingFolder(entity_1, Boolean.valueOf(false));
        _builder.append(_objectTypeFromGroupingFolder_1, "            ");
      }
    }
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    _builder.append("default: return \'\';");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $objectType;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence getGroupingFolderFromObjectType(final Entity it, final Boolean plural) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("case \'");
    String _name = it.getName();
    String _formatForCode = this._formattingExtensions.formatForCode(_name);
    _builder.append(_formatForCode, "");
    _builder.append("\':");
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    _builder.append("$groupFolder = \'");
    String _entityNameSingularPlural = this._modelExtensions.getEntityNameSingularPlural(it, plural);
    String _formatForDB = this._formattingExtensions.formatForDB(_entityNameSingularPlural);
    _builder.append(_formatForDB, "            ");
    _builder.append("\';");
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    _builder.append("break;");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence getObjectTypeFromGroupingFolder(final Entity it, final Boolean plural) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("case \'");
    String _entityNameSingularPlural = this._modelExtensions.getEntityNameSingularPlural(it, plural);
    String _formatForDB = this._formattingExtensions.formatForDB(_entityNameSingularPlural);
    _builder.append(_formatForDB, "");
    _builder.append("\':");
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    _builder.append("$objectType = \'");
    String _name = it.getName();
    String _formatForCode = this._formattingExtensions.formatForCode(_name);
    _builder.append(_formatForCode, "            ");
    _builder.append("\';");
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    _builder.append("break;");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence getFormattedSlug(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Get permalink value based on slug properties.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string  $objectType Name of treated entity type.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string  $func       Name of function.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param array   $args       Additional parameters.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param integer $itemid     Identifier of treated item.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return string The resulting url ending.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function getFormattedSlug($objectType, $func, $args, $itemid)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$slug = \'\';");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("switch ($objectType) {");
    _builder.newLine();
    _builder.append("        ");
    {
      EList<Entity> _allEntities = this._modelExtensions.getAllEntities(it);
      for(final Entity entity : _allEntities) {
        CharSequence _slugForItem = this.getSlugForItem(entity);
        _builder.append(_slugForItem, "        ");
      }
    }
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $slug;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence getSlugForItem(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("case \'");
    String _name = it.getName();
    String _formatForCode = this._formattingExtensions.formatForCode(_name);
    _builder.append(_formatForCode, "");
    _builder.append("\':");
    _builder.newLineIfNotEmpty();
    {
      boolean _hasSluggableFields = this._modelBehaviourExtensions.hasSluggableFields(it);
      if (_hasSluggableFields) {
        _builder.append("    ");
        _builder.append("$item = ModUtil::apiFunc(\'");
        Models _container = it.getContainer();
        Application _application = _container.getApplication();
        String _appName = this._utils.appName(_application);
        _builder.append(_appName, "    ");
        _builder.append("\', \'selection\', \'getEntity\', array(\'ot\' => $objectType, \'id\' => $itemid, \'slimMode\' => true));");
        _builder.newLineIfNotEmpty();
        {
          boolean _isSlugUnique = it.isSlugUnique();
          if (_isSlugUnique) {
            _builder.append("    ");
            _builder.append("$slug = $item[\'slug\'];");
            _builder.newLine();
          } else {
            _builder.append("    ");
            _builder.append("// make non-unique slug unique by adding the identifier");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("$idFields = ModUtil::apiFunc(\'");
            Models _container_1 = it.getContainer();
            Application _application_1 = _container_1.getApplication();
            String _appName_1 = this._utils.appName(_application_1);
            _builder.append(_appName_1, "    ");
            _builder.append("\', \'selection\', \'getIdFields\', array(\'ot\' => $objectType));");
            _builder.newLineIfNotEmpty();
            _builder.newLine();
            _builder.append("    ");
            _builder.append("// concatenate identifiers (for composite keys)");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("$itemId = \'\';");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("foreach ($idFields as $idField) {");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("$itemId .= ((!empty($itemId)) ? \'_\' : \'\') . $item[$idField];");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("}");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("$slug = $item[\'slug\'] . \'.\' . $itemId;");
            _builder.newLine();
          }
        }
      } else {
        _builder.append("    ");
        _builder.append("$slug = $itemid;");
        _builder.newLine();
      }
    }
    _builder.append("            ");
    _builder.append("break;");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence routerFacadeImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _targets = this._utils.targets(it, "1.3.5");
      boolean _not = (!_targets);
      if (_not) {
        _builder.append("namespace ");
        String _appNamespace = this._utils.appNamespace(it);
        _builder.append(_appNamespace, "");
        _builder.append(";");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
        _builder.append("use Base\\RouterFacade as BaseRouterFacade;");
        _builder.newLine();
        _builder.newLine();
      }
    }
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Url router facade implementation class.");
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
        _builder.append("_RouterFacade extends ");
        String _appName_1 = this._utils.appName(it);
        _builder.append(_appName_1, "");
        _builder.append("_Base_RouterFacade");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("class RouterFacade extends BaseRouterFacade");
        _builder.newLine();
      }
    }
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// here you can customise the data which is provided to the url router.");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
}
