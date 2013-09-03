package org.zikula.modulestudio.generator.cartridges.zclassic.controller.apis;

import com.google.inject.Inject;
import de.guite.modulestudio.metamodel.modulestudio.Application;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.eclipse.xtext.xbase.lib.InputOutput;
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class Selection {
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
    InputOutput.<String>println("Generating selection api");
    String _appSourceLibPath = this._namingExtensions.getAppSourceLibPath(it);
    final String apiPath = (_appSourceLibPath + "Api/");
    String _xifexpression = null;
    boolean _targets = this._utils.targets(it, "1.3.5");
    boolean _not = (!_targets);
    if (_not) {
      _xifexpression = "Api";
    } else {
      _xifexpression = "";
    }
    final String apiClassSuffix = _xifexpression;
    String _plus = ("Selection" + apiClassSuffix);
    final String apiFileName = (_plus + ".php");
    String _plus_1 = (apiPath + "Base/");
    String _plus_2 = (_plus_1 + apiFileName);
    CharSequence _selectionBaseFile = this.selectionBaseFile(it);
    fsa.generateFile(_plus_2, _selectionBaseFile);
    String _plus_3 = (apiPath + apiFileName);
    CharSequence _selectionFile = this.selectionFile(it);
    fsa.generateFile(_plus_3, _selectionFile);
  }
  
  private CharSequence selectionBaseFile(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _phpFileHeader = this.fh.phpFileHeader(it);
    _builder.append(_phpFileHeader, "");
    _builder.newLineIfNotEmpty();
    CharSequence _selectionBaseClass = this.selectionBaseClass(it);
    _builder.append(_selectionBaseClass, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence selectionFile(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _phpFileHeader = this.fh.phpFileHeader(it);
    _builder.append(_phpFileHeader, "");
    _builder.newLineIfNotEmpty();
    CharSequence _selectionImpl = this.selectionImpl(it);
    _builder.append(_selectionImpl, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence selectionBaseClass(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _targets = this._utils.targets(it, "1.3.5");
      boolean _not = (!_targets);
      if (_not) {
        _builder.append("namespace ");
        String _appNamespace = this._utils.appNamespace(it);
        _builder.append(_appNamespace, "");
        _builder.append("\\Api\\Base;");
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
        _builder.append("use Zikula_AbstractApi;");
        _builder.newLine();
        _builder.newLine();
      }
    }
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Selection api base class.");
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
        _builder.append("_Api_Base_Selection");
      } else {
        _builder.append("SelectionApi");
      }
    }
    _builder.append(" extends Zikula_AbstractApi");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    CharSequence _selectionBaseImpl = this.selectionBaseImpl(it);
    _builder.append(_selectionBaseImpl, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence selectionBaseImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Gets the list of identifier fields for a given object type.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $args[\'ot\'] The object type to be treated (optional).");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return array List of identifier field names.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function getIdFields(array $args = array())");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$objectType = $this->determineObjectType($args, \'getIdFields\');");
    _builder.newLine();
    {
      boolean _targets = this._utils.targets(it, "1.3.5");
      if (_targets) {
        _builder.append("    ");
        _builder.append("$entityClass = \'");
        String _appName = this._utils.appName(it);
        _builder.append(_appName, "    ");
        _builder.append("_Entity_\' . ucfirst($objectType);");
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
        _builder.append("Module\\\\Entity\\\\\' . ucfirst($objectType) . \'Entity\';");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("    ");
    _builder.append("$objectTemp = new $entityClass(); ");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$idFields = $objectTemp->get_idFields();");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $idFields;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Selects a single entity.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string  $args[\'ot\']       The object type to retrieve (optional).");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param mixed   $args[\'id\']       The id (or array of ids) to use to retrieve the object (default=null).");
    _builder.newLine();
    {
      boolean _hasSluggable = this._modelBehaviourExtensions.hasSluggable(it);
      if (_hasSluggable) {
        _builder.append(" ");
        _builder.append("* @param string  $args[\'slug\']     Slug to use as selection criteria instead of id (optional) (default=null).");
        _builder.newLine();
      }
    }
    _builder.append(" ");
    _builder.append("* @param boolean $args[\'useJoins\'] Whether to include joining related objects (optional) (default=true).");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param boolean $args[\'slimMode\'] If activated only some basic fields are selected without using any joins (optional) (default=false).");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return mixed Desired entity object or null.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function getEntity(array $args = array())");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!isset($args[\'id\'])");
    {
      boolean _hasSluggable_1 = this._modelBehaviourExtensions.hasSluggable(it);
      if (_hasSluggable_1) {
        _builder.append(" && !isset($args[\'slug\'])");
      }
    }
    _builder.append(") {");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("return LogUtil::registerArgsError();");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$objectType = $this->determineObjectType($args, \'getEntity\');");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$repository = $this->getRepository($objectType);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$idValues = $args[\'id\'];");
    _builder.newLine();
    {
      boolean _hasSluggable_2 = this._modelBehaviourExtensions.hasSluggable(it);
      if (_hasSluggable_2) {
        _builder.append("    ");
        _builder.append("$slug = isset($args[\'slug\']) ? $args[\'slug\'] : null;");
        _builder.newLine();
      }
    }
    _builder.append("    ");
    _builder.append("$useJoins = isset($args[\'useJoins\']) ? ((bool) $args[\'useJoins\']) : true;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$slimMode = isset($args[\'slimMode\']) ? ((bool) $args[\'slimMode\']) : false;");
    _builder.newLine();
    _builder.newLine();
    {
      boolean _hasSluggable_3 = this._modelBehaviourExtensions.hasSluggable(it);
      if (_hasSluggable_3) {
        _builder.append("    ");
        _builder.append("$entity = null;");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("if ($slug != null) {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("$entity = $repository->selectBySlug($slug, $useJoins, $slimMode);");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("} else {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("$entity = $repository->selectById($idValues, $useJoins, $slimMode);");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
      } else {
        _builder.append("    ");
        _builder.append("$entity = $repository->selectById($idValues, $useJoins, $slimMode);");
        _builder.newLine();
      }
    }
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $entity;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Selects a list of entities by different criteria.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string  $args[\'ot\']       The object type to retrieve (optional).");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string  $args[\'where\']    The where clause to use when retrieving the collection (optional) (default=\'\').");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string  $args[\'orderBy\']  The order-by clause to use when retrieving the collection (optional) (default=\'\').");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param boolean $args[\'useJoins\'] Whether to include joining related objects (optional) (default=true).");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param boolean $args[\'slimMode\'] If activated only some basic fields are selected without using any joins (optional) (default=false).");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return Array with retrieved collection.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function getEntities(array $args = array())");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$objectType = $this->determineObjectType($args, \'getEntities\');");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$repository = $this->getRepository($objectType);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$where = isset($args[\'where\']) ? $args[\'where\'] : \'\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$orderBy = isset($args[\'orderBy\']) ? $args[\'orderBy\'] : \'\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$useJoins = isset($args[\'useJoins\']) ? ((bool) $args[\'useJoins\']) : true;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$slimMode = isset($args[\'slimMode\']) ? ((bool) $args[\'slimMode\']) : false;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $repository->selectWhere($where, $orderBy, $useJoins, $slimMode);");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Selects a list of entities by different criteria.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string  $args[\'ot\']             The object type to retrieve (optional).");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string  $args[\'where\']          The where clause to use when retrieving the collection (optional) (default=\'\').");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string  $args[\'orderBy\']        The order-by clause to use when retrieving the collection (optional) (default=\'\').");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param integer $args[\'currentPage\']    Where to start selection.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param integer $args[\'resultsPerPage\'] Amount of items to select.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param boolean $args[\'useJoins\']       Whether to include joining related objects (optional) (default=true).");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param boolean $args[\'slimMode\']       If activated only some basic fields are selected without using any joins (optional) (default=false).");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return Array with retrieved collection and amount of total records affected by this query.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function getEntitiesPaginated(array $args = array())");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$objectType = $this->determineObjectType($args, \'getEntitiesPaginated\');");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$repository = $this->getRepository($objectType);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$where = isset($args[\'where\']) ? $args[\'where\'] : \'\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$orderBy = isset($args[\'orderBy\']) ? $args[\'orderBy\'] : \'\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$currentPage = isset($args[\'currentPage\']) ? $args[\'currentPage\'] : 1;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$resultsPerPage = isset($args[\'resultsPerPage\']) ? $args[\'resultsPerPage\'] : 25;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$useJoins = isset($args[\'useJoins\']) ? ((bool) $args[\'useJoins\']) : true;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$slimMode = isset($args[\'slimMode\']) ? ((bool) $args[\'slimMode\']) : false;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $repository->selectWherePaginated($where, $orderBy, $currentPage, $resultsPerPage, $useJoins, $slimMode);");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Determines object type using controller util methods.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $args[\'ot\'] The object type to retrieve (optional).");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $methodName Name of calling method.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return string the object type.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected function determineObjectType(array $args = array(), $methodName = \'\')");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$objectType = isset($args[\'ot\']) ? $args[\'ot\'] : \'\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$controllerHelper = new ");
    {
      boolean _targets_1 = this._utils.targets(it, "1.3.5");
      if (_targets_1) {
        String _appName_1 = this._utils.appName(it);
        _builder.append(_appName_1, "    ");
        _builder.append("_Util_Controller");
      } else {
        _builder.append("ControllerUtil");
      }
    }
    _builder.append("($this->serviceManager");
    {
      boolean _targets_2 = this._utils.targets(it, "1.3.5");
      boolean _not = (!_targets_2);
      if (_not) {
        _builder.append(", ModUtil::getModule($this->name)");
      }
    }
    _builder.append(");");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("$utilArgs = array(\'api\' => \'selection\', \'action\' => $methodName);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!in_array($objectType, $controllerHelper->getObjectTypes(\'api\', $utilArgs))) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$objectType = $controllerHelper->getDefaultObjectType(\'api\', $utilArgs);");
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
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Returns repository instance for a certain object type.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $objectType The desired object type.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return mixed Repository class instance or null.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected function getRepository($objectType = \'\')");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (empty($objectType)) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return LogUtil::registerArgsError();");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    {
      boolean _targets_3 = this._utils.targets(it, "1.3.5");
      if (_targets_3) {
        _builder.append("    ");
        _builder.append("$entityClass = \'");
        String _appName_2 = this._utils.appName(it);
        _builder.append(_appName_2, "    ");
        _builder.append("_Entity_\' . ucwords($objectType);");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("    ");
        _builder.append("$entityClass = \'\\\\");
        String _vendor_1 = it.getVendor();
        String _formatForCodeCapital_2 = this._formattingExtensions.formatForCodeCapital(_vendor_1);
        _builder.append(_formatForCodeCapital_2, "    ");
        _builder.append("\\\\");
        String _name_1 = it.getName();
        String _formatForCodeCapital_3 = this._formattingExtensions.formatForCodeCapital(_name_1);
        _builder.append(_formatForCodeCapital_3, "    ");
        _builder.append("Module\\\\Entity\\\\\' . ucwords($objectType) . \'Entity\';");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $this->entityManager->getRepository($entityClass);");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    {
      boolean _hasTrees = this._modelBehaviourExtensions.hasTrees(it);
      if (_hasTrees) {
        _builder.newLine();
        _builder.append("/**");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Selects tree of given object type.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @param string  $args[\'ot\']       The object type to retrieve (optional).");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @param integer $args[\'rootId\']   Optional id of root node to use as a branch, defaults to 0 which corresponds to the whole tree.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @param boolean $args[\'useJoins\'] Whether to include joining related objects (optional) (default=true).");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @return array|ArrayCollection retrieved data array or tree node objects.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
        _builder.append("public function getTree(array $args = array())");
        _builder.newLine();
        _builder.append("{");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("if (!isset($args[\'rootId\'])) {");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("return LogUtil::registerArgsError();");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$rootId = $args[\'rootId\'];");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$objectType = $this->determineObjectType($args, \'getTree\');");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$repository = $this->getRepository($objectType);");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$useJoins = isset($args[\'useJoins\']) ? ((bool) $args[\'useJoins\']) : true;");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("return $repository->selectTree($rootId, $useJoins);");
        _builder.newLine();
        _builder.append("}");
        _builder.newLine();
        _builder.newLine();
        _builder.append("/**");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Gets all trees at once.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @param string  $args[\'ot\']       The object type to retrieve (optional).");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @param boolean $args[\'useJoins\'] Whether to include joining related objects (optional) (default=true).");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @return array|ArrayCollection retrieved data array or tree node objects.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
        _builder.append("public function getAllTrees(array $args = array())");
        _builder.newLine();
        _builder.append("{");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$objectType = $this->determineObjectType($args, \'getTree\');");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$repository = $this->getRepository($objectType);");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$useJoins = isset($args[\'useJoins\']) ? ((bool) $args[\'useJoins\']) : true;");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("return $repository->selectAllTrees($useJoins);");
        _builder.newLine();
        _builder.append("}");
        _builder.newLine();
      }
    }
    return _builder;
  }
  
  private CharSequence selectionImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _targets = this._utils.targets(it, "1.3.5");
      boolean _not = (!_targets);
      if (_not) {
        _builder.append("namespace ");
        String _appNamespace = this._utils.appNamespace(it);
        _builder.append(_appNamespace, "");
        _builder.append("\\Api;");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
        _builder.append("use ");
        String _appNamespace_1 = this._utils.appNamespace(it);
        _builder.append(_appNamespace_1, "");
        _builder.append("\\Api\\Base\\SelectionApi as BaseSelectionApi;");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
      }
    }
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Selection api implementation class.");
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
        _builder.append("_Api_Selection extends ");
        String _appName_1 = this._utils.appName(it);
        _builder.append(_appName_1, "");
        _builder.append("_Api_Base_Selection");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("class SelectionApi extends BaseSelectionApi");
        _builder.newLine();
      }
    }
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// feel free to extend the selection api here");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
}
