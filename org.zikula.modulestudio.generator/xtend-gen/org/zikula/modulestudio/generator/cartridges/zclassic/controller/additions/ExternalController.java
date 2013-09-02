package org.zikula.modulestudio.generator.cartridges.zclassic.controller.additions;

import com.google.inject.Inject;
import de.guite.modulestudio.metamodel.modulestudio.Application;
import de.guite.modulestudio.metamodel.modulestudio.Entity;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.eclipse.xtext.xbase.lib.InputOutput;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.ControllerHelper;
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper;
import org.zikula.modulestudio.generator.cartridges.zclassic.view.additions.ExternalView;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class ExternalController {
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
  private ModelBehaviourExtensions _modelBehaviourExtensions = new Function0<ModelBehaviourExtensions>() {
    public ModelBehaviourExtensions apply() {
      ModelBehaviourExtensions _modelBehaviourExtensions = new ModelBehaviourExtensions();
      return _modelBehaviourExtensions;
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
    InputOutput.<String>println("Generating external controller");
    String _appSourceLibPath = this._namingExtensions.getAppSourceLibPath(it);
    final String controllerPath = (_appSourceLibPath + "Controller/");
    String _xifexpression = null;
    boolean _targets = this._utils.targets(it, "1.3.5");
    boolean _not = (!_targets);
    if (_not) {
      _xifexpression = "Controller";
    } else {
      _xifexpression = "";
    }
    final String controllerClassSuffix = _xifexpression;
    String _plus = ("External" + controllerClassSuffix);
    final String controllerFileName = (_plus + ".php");
    String _plus_1 = (controllerPath + "Base/");
    String _plus_2 = (_plus_1 + controllerFileName);
    CharSequence _externalBaseFile = this.externalBaseFile(it);
    fsa.generateFile(_plus_2, _externalBaseFile);
    String _plus_3 = (controllerPath + controllerFileName);
    CharSequence _externalFile = this.externalFile(it);
    fsa.generateFile(_plus_3, _externalFile);
    ExternalView _externalView = new ExternalView();
    _externalView.generate(it, fsa);
  }
  
  private CharSequence externalBaseFile(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _phpFileHeader = this.fh.phpFileHeader(it);
    _builder.append(_phpFileHeader, "");
    _builder.newLineIfNotEmpty();
    CharSequence _externalBaseClass = this.externalBaseClass(it);
    _builder.append(_externalBaseClass, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence externalFile(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _phpFileHeader = this.fh.phpFileHeader(it);
    _builder.append(_phpFileHeader, "");
    _builder.newLineIfNotEmpty();
    CharSequence _externalImpl = this.externalImpl(it);
    _builder.append(_externalImpl, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence externalBaseClass(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _targets = this._utils.targets(it, "1.3.5");
      boolean _not = (!_targets);
      if (_not) {
        _builder.append("namespace ");
        String _appNamespace = this._utils.appNamespace(it);
        _builder.append(_appNamespace, "");
        _builder.append("\\Controller\\Base;");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
        _builder.append("use ");
        String _appNamespace_1 = this._utils.appNamespace(it);
        _builder.append(_appNamespace_1, "");
        _builder.append("\\Util\\ControllerUtil;");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
        _builder.append("use LogUtil;");
        _builder.newLine();
        _builder.append("use ModUtil;");
        _builder.newLine();
        _builder.append("use PageUtil;");
        _builder.newLine();
        _builder.append("use SecurityUtil;");
        _builder.newLine();
        _builder.append("use ThemeUtil;");
        _builder.newLine();
        _builder.append("use Zikula_AbstractController;");
        _builder.newLine();
        _builder.append("use Zikula_View;");
        _builder.newLine();
        _builder.append("use Zikula\\Core\\Response\\PlainResponse;");
        _builder.newLine();
        _builder.newLine();
      }
    }
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Controller for external calls base class.");
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
        _builder.append("_Controller_Base_External");
      } else {
        _builder.append("ExternalController");
      }
    }
    _builder.append(" extends Zikula_AbstractController");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    {
      boolean _hasCategorisableEntities = this._modelBehaviourExtensions.hasCategorisableEntities(it);
      if (_hasCategorisableEntities) {
        _builder.append("    ");
        _builder.append("/**");
        _builder.newLine();
        _builder.append("    ");
        _builder.append(" ");
        _builder.append("* List of object types allowing categorisation.");
        _builder.newLine();
        _builder.append("    ");
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append("    ");
        _builder.append(" ");
        _builder.append("* @var array");
        _builder.newLine();
        _builder.append("    ");
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("protected $categorisableObjectTypes;");
        _builder.newLine();
        _builder.newLine();
      }
    }
    _builder.append("    ");
    CharSequence _xifexpression = null;
    boolean _hasCategorisableEntities_1 = this._modelBehaviourExtensions.hasCategorisableEntities(it);
    if (_hasCategorisableEntities_1) {
      CharSequence _categoryInitialisation = this.categoryInitialisation(it);
      _xifexpression = _categoryInitialisation;
    } else {
      _xifexpression = "";
    }
    final CharSequence additionalCommands = _xifexpression;
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    ControllerHelper _controllerHelper = new ControllerHelper();
    String _string = additionalCommands.toString();
    CharSequence _controllerPostInitialize = _controllerHelper.controllerPostInitialize(it, Boolean.valueOf(false), _string);
    _builder.append(_controllerPostInitialize, "    ");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    CharSequence _externalBaseImpl = this.externalBaseImpl(it);
    _builder.append(_externalBaseImpl, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence categoryInitialisation(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("$this->categorisableObjectTypes = array(");
    {
      Iterable<Entity> _categorisableEntities = this._modelBehaviourExtensions.getCategorisableEntities(it);
      boolean _hasElements = false;
      for(final Entity entity : _categorisableEntities) {
        if (!_hasElements) {
          _hasElements = true;
        } else {
          _builder.appendImmediate(", ", "");
        }
        _builder.append("\'");
        String _name = entity.getName();
        String _formatForCode = this._formattingExtensions.formatForCode(_name);
        _builder.append(_formatForCode, "");
        _builder.append("\'");
      }
    }
    _builder.append(");");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence externalBaseImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Displays one item of a certain object type using a separate template for external usages.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param array  $args              List of arguments.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $args[ot]          The object type");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param int    $args[id]          Identifier of the item to be shown");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $args[source]      Source of this call (contentType or scribite)");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $args[displayMode] Display mode (link or embed)");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return string Desired data output.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function display");
    {
      boolean _targets = this._utils.targets(it, "1.3.5");
      boolean _not = (!_targets);
      if (_not) {
        _builder.append("Action");
      }
    }
    _builder.append("(array $args = array())");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$getData = $this->request->query;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$controllerHelper = new ");
    {
      boolean _targets_1 = this._utils.targets(it, "1.3.5");
      if (_targets_1) {
        String _appName = this._utils.appName(it);
        _builder.append(_appName, "    ");
        _builder.append("_Util_Controller");
      } else {
        _builder.append("ControllerUtil");
      }
    }
    _builder.append("($this->serviceManager");
    {
      boolean _targets_2 = this._utils.targets(it, "1.3.5");
      boolean _not_1 = (!_targets_2);
      if (_not_1) {
        _builder.append(", ModUtil::getModule($this->name)");
      }
    }
    _builder.append(");");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$objectType = isset($args[\'objectType\']) ? $args[\'objectType\'] : \'\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$utilArgs = array(\'controller\' => \'external\', \'action\' => \'display\');");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!in_array($objectType, $controllerHelper->getObjectTypes(\'controller\', $utilArgs))) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$objectType = $controllerHelper->getDefaultObjectType(\'controllerType\', $utilArgs);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$id = (isset($args[\'id\'])) ? $args[\'id\'] : $getData->filter(\'id\', null, FILTER_SANITIZE_STRING);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$component = $this->name . \':\' . ucwords($objectType) . \':\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!SecurityUtil::checkPermission($component, $id . \'::\', ACCESS_READ)) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return \'\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$source = (isset($args[\'source\'])) ? $args[\'source\'] : $getData->filter(\'source\', \'\', FILTER_SANITIZE_STRING);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!in_array($source, array(\'contentType\', \'scribite\'))) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$source = \'contentType\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$displayMode = (isset($args[\'displayMode\'])) ? $args[\'displayMode\'] : $getData->filter(\'displayMode\', \'embed\', FILTER_SANITIZE_STRING);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!in_array($displayMode, array(\'link\', \'embed\'))) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$displayMode = \'embed\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("unset($args);");
    _builder.newLine();
    _builder.newLine();
    {
      boolean _targets_3 = this._utils.targets(it, "1.3.5");
      if (_targets_3) {
        _builder.append("    ");
        _builder.append("$entityClass = \'");
        String _appName_1 = this._utils.appName(it);
        _builder.append(_appName_1, "    ");
        _builder.append("_Entity_\' . ucwords($objectType);");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("    ");
        _builder.append("$entityClass = \'\\\\");
        String _vendor = it.getVendor();
        String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(_vendor);
        _builder.append(_formatForCodeCapital, "    ");
        _builder.append("\\\\");
        String _name = it.getName();
        String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(_name);
        _builder.append(_formatForCodeCapital_1, "    ");
        _builder.append("Module\\\\Entity\\\\\' . ucwords($objectType) . \'Entity\';");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("    ");
    _builder.append("$repository = $this->entityManager->getRepository($entityClass);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$repository->setControllerArguments($args);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$idFields = ModUtil::apiFunc(\'");
    String _appName_2 = this._utils.appName(it);
    _builder.append(_appName_2, "    ");
    _builder.append("\', \'selection\', \'getIdFields\', array(\'ot\' => $objectType));");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("$idValues = array(\'id\' => $id);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$hasIdentifier = $controllerHelper->isValidIdentifier($idValues);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("//$this->throwNotFoundUnless($hasIdentifier, $this->__(\'Error! Invalid identifier received.\'));");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!$hasIdentifier) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return $this->__(\'Error! Invalid identifier received.\');");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// assign object data fetched from the database");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$entity = $repository->selectById($idValues);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ((!is_array($entity) && !is_object($entity)) || !isset($entity[$idFields[0]])) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("//$this->throwNotFound($this->__(\'No such item.\'));");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return $this->__(\'No such item.\');");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$entity->initWorkflow();");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$instance = $id . \'::\';");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$this->view->setCaching(Zikula_View::CACHE_ENABLED);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// set cache id");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$accessLevel = ACCESS_READ;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (SecurityUtil::checkPermission($component, $instance, ACCESS_COMMENT)) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$accessLevel = ACCESS_COMMENT;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (SecurityUtil::checkPermission($component, $instance, ACCESS_EDIT)) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$accessLevel = ACCESS_EDIT;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$this->view->setCacheId($objectType . \'|\' . $id . \'|a\' . $accessLevel);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$this->view->assign(\'objectType\', $objectType)");
    _builder.newLine();
    _builder.append("              ");
    _builder.append("->assign(\'source\', $source)");
    _builder.newLine();
    _builder.append("              ");
    _builder.append("->assign($objectType, $entity)");
    _builder.newLine();
    _builder.append("              ");
    _builder.append("->assign(\'displayMode\', $displayMode);");
    _builder.newLine();
    _builder.newLine();
    {
      boolean _targets_4 = this._utils.targets(it, "1.3.5");
      if (_targets_4) {
        _builder.append("    ");
        _builder.append("return $this->view->fetch(\'external/\' . $objectType . \'/display.tpl\');");
        _builder.newLine();
      } else {
        _builder.append("    ");
        _builder.append("return $this->response($this->view->fetch(\'External/\' . ucwords($objectType) . \'/display.tpl\'));");
        _builder.newLine();
      }
    }
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Popup selector for scribite plugins.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Finds items of a certain object type.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param array $args List of arguments.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return output The external item finder page");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function finder");
    {
      boolean _targets_5 = this._utils.targets(it, "1.3.5");
      boolean _not_2 = (!_targets_5);
      if (_not_2) {
        _builder.append("Action");
      }
    }
    _builder.append("(array $args = array())");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("PageUtil::addVar(\'stylesheet\', ThemeUtil::getModuleStylesheet(\'");
    String _appName_3 = this._utils.appName(it);
    _builder.append(_appName_3, "    ");
    _builder.append("\'));");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$getData = $this->request->query;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$controllerHelper = new ");
    {
      boolean _targets_6 = this._utils.targets(it, "1.3.5");
      if (_targets_6) {
        String _appName_4 = this._utils.appName(it);
        _builder.append(_appName_4, "    ");
        _builder.append("_Util_Controller");
      } else {
        _builder.append("ControllerUtil");
      }
    }
    _builder.append("($this->serviceManager");
    {
      boolean _targets_7 = this._utils.targets(it, "1.3.5");
      boolean _not_3 = (!_targets_7);
      if (_not_3) {
        _builder.append(", ModUtil::getModule($this->name)");
      }
    }
    _builder.append(");");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$objectType = isset($args[\'objectType\']) ? $args[\'objectType\'] : $getData->filter(\'objectType\', \'");
    Entity _leadingEntity = this._modelExtensions.getLeadingEntity(it);
    String _name_1 = _leadingEntity.getName();
    String _formatForCode = this._formattingExtensions.formatForCode(_name_1);
    _builder.append(_formatForCode, "    ");
    _builder.append("\', FILTER_SANITIZE_STRING);");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("$utilArgs = array(\'controller\' => \'external\', \'action\' => \'finder\');");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!in_array($objectType, $controllerHelper->getObjectTypes(\'controller\', $utilArgs))) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$objectType = $controllerHelper->getDefaultObjectType(\'controllerType\', $utilArgs);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$this->throwForbiddenUnless(SecurityUtil::checkPermission(\'");
    String _appName_5 = this._utils.appName(it);
    _builder.append(_appName_5, "    ");
    _builder.append(":\' . ucwords($objectType) . \':\', \'::\', ACCESS_COMMENT), LogUtil::getErrorMsgPermission());");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    {
      boolean _targets_8 = this._utils.targets(it, "1.3.5");
      if (_targets_8) {
        _builder.append("    ");
        _builder.append("$entityClass = \'");
        String _appName_6 = this._utils.appName(it);
        _builder.append(_appName_6, "    ");
        _builder.append("_Entity_\' . ucwords($objectType);");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("    ");
        _builder.append("$entityClass = \'\\\\");
        String _vendor_1 = it.getVendor();
        String _formatForCodeCapital_2 = this._formattingExtensions.formatForCodeCapital(_vendor_1);
        _builder.append(_formatForCodeCapital_2, "    ");
        _builder.append("\\\\");
        String _name_2 = it.getName();
        String _formatForCodeCapital_3 = this._formattingExtensions.formatForCodeCapital(_name_2);
        _builder.append(_formatForCodeCapital_3, "    ");
        _builder.append("Module\\\\Entity\\\\\' . ucwords($objectType) . \'Entity\';");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("    ");
    _builder.append("$repository = $this->entityManager->getRepository($entityClass);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$repository->setControllerArguments($args);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$editor = (isset($args[\'editor\']) && !empty($args[\'editor\'])) ? $args[\'editor\'] : $getData->filter(\'editor\', \'\', FILTER_SANITIZE_STRING);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (empty($editor) || !in_array($editor, array(\'xinha\', \'tinymce\'/*, \'ckeditor\'*/))) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return \'Error: Invalid editor context given for external controller action.\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    {
      boolean _hasCategorisableEntities = this._modelBehaviourExtensions.hasCategorisableEntities(it);
      if (_hasCategorisableEntities) {
        _builder.newLine();
        _builder.append("    ");
        _builder.append("// fetch selected categories to reselect them in the output");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("// the actual filtering is done inside the repository class");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$categoryIds = ModUtil::apiFunc(\'");
        String _appName_7 = this._utils.appName(it);
        _builder.append(_appName_7, "    ");
        _builder.append("\', \'category\', \'retrieveCategoriesFromRequest\', array(\'ot\' => $objectType, \'source\' => \'GET\', \'controllerArgs\' => $args));");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("    ");
    _builder.append("$sort = (isset($args[\'sort\']) && !empty($args[\'sort\'])) ? $args[\'sort\'] : $getData->filter(\'sort\', \'\', FILTER_SANITIZE_STRING);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (empty($sort) || !in_array($sort, $repository->getAllowedSortingFields())) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$sort = $repository->getDefaultSortingField();");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$sdir = (isset($args[\'sortdir\']) && !empty($args[\'sortdir\'])) ? $args[\'sortdir\'] : $getData->filter(\'sortdir\', \'\', FILTER_SANITIZE_STRING);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$sdir = strtolower($sdir);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($sdir != \'asc\' && $sdir != \'desc\') {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$sdir = \'asc\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$sortParam = $sort . \' \' . $sdir;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// the current offset which is used to calculate the pagination");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$currentPage = (int) (isset($args[\'pos\']) && !empty($args[\'pos\'])) ? $args[\'pos\'] : $getData->filter(\'pos\', 1, FILTER_VALIDATE_INT);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// the number of items displayed on a page for pagination");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$resultsPerPage = (int) (isset($args[\'num\']) && !empty($args[\'num\'])) ? $args[\'num\'] : $getData->filter(\'num\', 0, FILTER_VALIDATE_INT);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($resultsPerPage == 0) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$resultsPerPage = $this->getVar(\'pageSize\', 20);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$where = \'\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("list($entities, $objectCount) = $repository->selectWherePaginated($where, $sortParam, $currentPage, $resultsPerPage);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("foreach ($entities as $k => $entity) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$entity->initWorkflow();");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$view = Zikula_View::getInstance(\'");
    String _appName_8 = this._utils.appName(it);
    _builder.append(_appName_8, "    ");
    _builder.append("\', false);");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$view->assign(\'editorName\', $editor)");
    _builder.newLine();
    _builder.append("         ");
    _builder.append("->assign(\'objectType\', $objectType)");
    _builder.newLine();
    _builder.append("         ");
    _builder.append("->assign(\'items\', $entities)");
    _builder.newLine();
    _builder.append("         ");
    _builder.append("->assign(\'sort\', $sort)");
    _builder.newLine();
    _builder.append("         ");
    _builder.append("->assign(\'sortdir\', $sdir)");
    _builder.newLine();
    _builder.append("         ");
    _builder.append("->assign(\'currentPage\', $currentPage)");
    _builder.newLine();
    _builder.append("         ");
    _builder.append("->assign(\'pager\', array(\'numitems\'     => $objectCount,");
    _builder.newLine();
    _builder.append("                                 ");
    _builder.append("\'itemsperpage\' => $resultsPerPage));");
    _builder.newLine();
    {
      boolean _hasCategorisableEntities_1 = this._modelBehaviourExtensions.hasCategorisableEntities(it);
      if (_hasCategorisableEntities_1) {
        _builder.newLine();
        _builder.append("    ");
        _builder.append("// assign category properties");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$properties = null;");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("if (in_array($objectType, $this->categorisableObjectTypes)) {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("$properties = ModUtil::apiFunc(\'");
        String _appName_9 = this._utils.appName(it);
        _builder.append(_appName_9, "        ");
        _builder.append("\', \'category\', \'getAllProperties\', array(\'ot\' => $objectType));");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$view->assign(\'properties\', $properties)");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("     ");
        _builder.append("->assign(\'catIds\', $categoryIds);");
        _builder.newLine();
      }
    }
    _builder.newLine();
    {
      boolean _targets_9 = this._utils.targets(it, "1.3.5");
      if (_targets_9) {
        _builder.append("    ");
        _builder.append("return $view->display(\'external/\' . $objectType . \'/find.tpl\');");
        _builder.newLine();
      } else {
        _builder.append("    ");
        _builder.append("return new PlainResponse($view->display(\'External/\' . ucwords($objectType) . \'/find.tpl\'));");
        _builder.newLine();
      }
    }
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence externalImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _targets = this._utils.targets(it, "1.3.5");
      boolean _not = (!_targets);
      if (_not) {
        _builder.append("namespace ");
        String _appNamespace = this._utils.appNamespace(it);
        _builder.append(_appNamespace, "");
        _builder.append("\\Controller;");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
        _builder.append("use Base\\ExternalController as BaseExternalController;");
        _builder.newLine();
        _builder.newLine();
      }
    }
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Controller for external calls implementation class.");
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
        _builder.append("_Controller_External extends ");
        String _appName_1 = this._utils.appName(it);
        _builder.append(_appName_1, "");
        _builder.append("_Controller_Base_External");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("class ExternalController extends BaseExternalController");
        _builder.newLine();
      }
    }
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// feel free to extend the external controller here");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
}
